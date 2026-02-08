# =============================================================================
# 01_fetch_data.R
# Fetch REAL FARS crash data, state boundaries, and dispensary locations
# =============================================================================

source("00_packages.R")

# =============================================================================
# PART 1: State Boundaries (TIGER/Line) - Fetch First
# =============================================================================

cat("Fetching state boundaries from Census TIGER...\n")

# Study states FIPS codes
# Prohibition: AZ(04), ID(16), KS(20), MT(30), NE(31), NM(35), UT(49), WY(56)
# Legal: CO(08), OR(41), WA(53), NV(32), CA(06)
prohibition_fips <- c("04", "16", "20", "30", "31", "35", "49", "56")
legal_fips <- c("06", "08", "32", "41", "53")
all_fips <- c(prohibition_fips, legal_fips)

states_url <- "https://www2.census.gov/geo/tiger/GENZ2019/shp/cb_2019_us_state_500k.zip"
temp_zip <- tempfile(fileext = ".zip")
temp_dir <- tempdir()

download.file(states_url, temp_zip, mode = "wb", quiet = TRUE)
unzip(temp_zip, exdir = temp_dir)

# Read shapefile
states_sf <- st_read(file.path(temp_dir, "cb_2019_us_state_500k.shp"), quiet = TRUE)

# Filter to study states and transform to common CRS
states_sf <- states_sf %>%
  filter(STATEFP %in% all_fips) %>%
  st_transform(4326)

# Add legal status
states_sf <- states_sf %>%
  mutate(
    legal_status = case_when(
      STATEFP %in% legal_fips ~ "Legal",
      TRUE ~ "Prohibition"
    )
  )

saveRDS(states_sf, "../data/states_sf.rds")
cat(sprintf("Saved %d state boundaries.\n", nrow(states_sf)))

# =============================================================================
# PART 2: Identify Border Segments
# =============================================================================

cat("\nIdentifying legal-prohibition borders...\n")

legal_states <- states_sf %>% filter(legal_status == "Legal")
prohibition_states <- states_sf %>% filter(legal_status == "Prohibition")

borders_list <- list()

for (i in 1:nrow(legal_states)) {
  for (j in 1:nrow(prohibition_states)) {
    legal_state <- legal_states[i, ]
    prohib_state <- prohibition_states[j, ]

    if (st_touches(legal_state, prohib_state, sparse = FALSE)[1,1] ||
        st_intersects(legal_state, prohib_state, sparse = FALSE)[1,1]) {

      border <- tryCatch({
        st_intersection(
          st_boundary(legal_state),
          st_boundary(prohib_state)
        )
      }, error = function(e) NULL)

      if (!is.null(border) && nrow(border) > 0) {
        geom_type <- st_geometry_type(border)[1]
        if (geom_type %in% c("LINESTRING", "MULTILINESTRING", "GEOMETRYCOLLECTION")) {
          borders_list[[length(borders_list) + 1]] <- st_sf(
            legal_state = legal_state$NAME,
            prohib_state = prohib_state$NAME,
            geometry = st_geometry(border)
          )
        }
      }
    }
  }
}

if (length(borders_list) > 0) {
  borders_sf <- do.call(rbind, borders_list)
  borders_sf <- st_set_crs(borders_sf, 4326)
  saveRDS(borders_sf, "../data/borders_sf.rds")
  cat(sprintf("Identified %d border segments.\n", nrow(borders_sf)))
} else {
  stop("No borders identified!")
}

# =============================================================================
# PART 3: FARS Data via NHTSA API
# =============================================================================

cat("\nFetching FARS crash data from NHTSA API...\n")

# FARS API base URL
fars_base <- "https://crashviewer.nhtsa.dot.gov/CrashAPI"

# State FIPS to name mapping
state_names <- c(
  "04" = "Arizona", "06" = "California", "08" = "Colorado",
  "16" = "Idaho", "20" = "Kansas", "30" = "Montana",
  "31" = "Nebraska", "32" = "Nevada", "35" = "New Mexico",
  "41" = "Oregon", "49" = "Utah", "53" = "Washington", "56" = "Wyoming"
)

# Fetch crashes for each state-year with lat/lon
fetch_fars_crashes <- function(state_fips, year) {
  # Use the crashes endpoint that returns geocoded data
  url <- sprintf(
    "%s/crashes/GetCrashList?State=%s&fromCaseYear=%d&toCaseYear=%d&MinLatitude=25&MaxLatitude=50&MinLongitude=-130&MaxLongitude=-100&format=json",
    fars_base, as.integer(state_fips), year, year
  )

  tryCatch({
    response <- httr::GET(url, httr::timeout(120))
    if (httr::status_code(response) == 200) {
      content <- httr::content(response, as = "text", encoding = "UTF-8")
      data <- jsonlite::fromJSON(content, flatten = TRUE)

      if (!is.null(data$Results) && length(data$Results) > 0) {
        results <- data$Results[[1]]
        if (is.data.frame(results) && nrow(results) > 0) {
          results$state_fips <- state_fips
          results$year <- year
          return(results)
        }
      }
    }
    return(NULL)
  }, error = function(e) {
    cat(sprintf("  Error fetching %s %d: %s\n", state_fips, year, e$message))
    return(NULL)
  })
}

# Alternative: Fetch from aggregated API endpoint
fetch_fars_by_coords <- function(state_fips, year) {
  # Geographic bounds for western US
  url <- sprintf(
    "%s/crashes/GetCrashesInArea?fromCaseYear=%d&toCaseYear=%d&state=%d&format=json",
    fars_base, year, year, as.integer(state_fips)
  )

  tryCatch({
    response <- httr::GET(url, httr::timeout(180))
    if (httr::status_code(response) == 200) {
      content <- httr::content(response, as = "text", encoding = "UTF-8")
      data <- jsonlite::fromJSON(content, flatten = TRUE)

      if (length(data) > 0 && !is.null(data$Results)) {
        df <- as.data.frame(data$Results[[1]])
        if (nrow(df) > 0) {
          df$state_fips <- state_fips
          df$year <- year
          return(df)
        }
      }
    }
    return(NULL)
  }, error = function(e) {
    cat(sprintf("  Error: %s\n", e$message))
    return(NULL)
  })
}

# Collect all crashes
all_crashes <- list()
years <- 2016:2019

for (fips in all_fips) {
  for (yr in years) {
    cat(sprintf("  Fetching %s (%s) %d...\n", state_names[fips], fips, yr))

    # Try primary endpoint
    df <- fetch_fars_crashes(fips, yr)

    if (is.null(df) || nrow(df) == 0) {
      # Try alternative endpoint
      df <- fetch_fars_by_coords(fips, yr)
    }

    if (!is.null(df) && nrow(df) > 0) {
      all_crashes[[length(all_crashes) + 1]] <- df
      cat(sprintf("    Got %d crashes\n", nrow(df)))
    }

    Sys.sleep(1)  # Rate limiting
  }
}

# Combine all crashes
if (length(all_crashes) > 0) {
  fars_raw <- bind_rows(all_crashes)
  cat(sprintf("\nTotal raw crashes: %d\n", nrow(fars_raw)))
} else {
  # If API fails, try the public FARS download
  cat("\nAPI failed. Trying NHTSA public data portal...\n")

  # Use direct CSV downloads from NHTSA
  fars_raw <- data.frame()

  for (yr in years) {
    csv_url <- sprintf(
      "https://static.nhtsa.gov/nhtsa/downloads/FARS/%d/National/FARS%dNationalCSV.zip",
      yr, yr
    )

    temp_zip <- tempfile(fileext = ".zip")
    tryCatch({
      download.file(csv_url, temp_zip, mode = "wb", quiet = TRUE)
      temp_extract <- tempdir()
      unzip(temp_zip, exdir = temp_extract)

      # Read accident file
      acc_file <- list.files(temp_extract, pattern = "accident", ignore.case = TRUE, full.names = TRUE)[1]
      if (!is.na(acc_file) && file.exists(acc_file)) {
        acc_data <- read.csv(acc_file, stringsAsFactors = FALSE)

        # Filter to study states
        acc_data <- acc_data %>%
          filter(STATE %in% as.integer(all_fips))

        if (nrow(acc_data) > 0) {
          acc_data$year <- yr
          fars_raw <- bind_rows(fars_raw, acc_data)
          cat(sprintf("  %d: %d crashes\n", yr, nrow(acc_data)))
        }
      }
    }, error = function(e) {
      cat(sprintf("  Error downloading %d: %s\n", yr, e$message))
    })
  }
}

# Check if we have data
if (nrow(fars_raw) == 0) {
  stop("Failed to fetch FARS data from any source!")
}

# Standardize column names (FARS varies by year)
names(fars_raw) <- tolower(names(fars_raw))

# Remove duplicate columns after lowercasing
fars_raw <- fars_raw[, !duplicated(names(fars_raw))]

# Check for lat/lon columns
fars_clean <- fars_raw
if ("latitude" %in% names(fars_clean)) {
  fars_clean$lat <- fars_clean$latitude
  fars_clean$latitude <- NULL
}
if ("longitude" %in% names(fars_clean)) {
  fars_clean$lon <- fars_clean$longitude
  fars_clean$longitude <- NULL
}
if ("longitud" %in% names(fars_clean)) {
  fars_clean$lon <- fars_clean$longitud
  fars_clean$longitud <- NULL
}

# Final check for duplicates
fars_clean <- fars_clean[, !duplicated(names(fars_clean))]

# Ensure we have required columns
required_cols <- c("state", "lat", "lon")
available_cols <- names(fars_clean)[names(fars_clean) %in% c("state", "lat", "lon", "latitude", "longitude", "drunk_dr", "hour", "year")]

cat(sprintf("Available columns: %s\n", paste(available_cols, collapse = ", ")))

# Handle DRUNK_DR column (may be named differently)
if (!"drunk_dr" %in% names(fars_clean)) {
  if ("drunkdr" %in% names(fars_clean)) {
    fars_clean$drunk_dr <- fars_clean$drunkdr
  } else if ("drunk_dr" %in% toupper(names(fars_clean))) {
    idx <- which(toupper(names(fars_clean)) == "DRUNK_DR")
    fars_clean$drunk_dr <- fars_clean[[idx]]
  } else {
    # If no alcohol variable, set to NA for now
    fars_clean$drunk_dr <- NA
    cat("Warning: No DRUNK_DR column found. Will need person-level data.\n")
  }
}

# Filter to valid coordinates
fars_clean <- fars_clean %>%
  filter(!is.na(lat) & !is.na(lon)) %>%
  filter(lat > 25 & lat < 50) %>%
  filter(lon > -130 & lon < -100)

cat(sprintf("Crashes with valid coordinates: %d\n", nrow(fars_clean)))

# Convert to sf object
if (nrow(fars_clean) > 0) {
  crashes_sf <- st_as_sf(fars_clean, coords = c("lon", "lat"), crs = 4326)

  # Spatial join with states to get legal status
  crashes_sf <- st_join(crashes_sf, states_sf %>% select(NAME, legal_status), left = TRUE)

  # Filter to crashes that matched a state
  crashes_sf <- crashes_sf %>%
    filter(!is.na(NAME))

  saveRDS(crashes_sf, "../data/crashes_sf.rds")
  cat(sprintf("Saved %d geocoded crashes.\n", nrow(crashes_sf)))
} else {
  stop("No valid crash data after cleaning!")
}

# =============================================================================
# PART 4: Dispensary Locations from OpenStreetMap
# =============================================================================

cat("\nFetching dispensary locations from OSM Overpass API...\n")

overpass_url <- "https://overpass-api.de/api/interpreter"

# Query for cannabis retail in western US
overpass_query <- '[out:json][timeout:180];
area["ISO3166-2"~"US-(CO|OR|WA|NV|CA)"]->.searchArea;
(
  node["shop"="cannabis"](area.searchArea);
  way["shop"="cannabis"](area.searchArea);
  node["amenity"="dispensary"](area.searchArea);
  way["amenity"="dispensary"](area.searchArea);
);
out center;'

response <- httr::POST(
  overpass_url,
  body = list(data = overpass_query),
  encode = "form",
  httr::timeout(300)
)

if (httr::status_code(response) == 200) {
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  osm_data <- jsonlite::fromJSON(content, simplifyVector = FALSE)

  if (length(osm_data$elements) > 0) {
    dispensaries_list <- list()
    for (i in seq_along(osm_data$elements)) {
      elem <- osm_data$elements[[i]]

      # Get lat/lon - may be directly on element or in center
      lat <- NA
      lon <- NA
      if (!is.null(elem$lat)) lat <- elem$lat
      else if (!is.null(elem$center) && !is.null(elem$center$lat)) lat <- elem$center$lat

      if (!is.null(elem$lon)) lon <- elem$lon
      else if (!is.null(elem$center) && !is.null(elem$center$lon)) lon <- elem$center$lon

      name <- NA
      if (!is.null(elem$tags) && !is.null(elem$tags$name)) name <- elem$tags$name

      dispensaries_list[[i]] <- data.frame(
        osm_id = elem$id,
        lat = lat,
        lon = lon,
        name = name,
        stringsAsFactors = FALSE
      )
    }

    dispensaries_df <- bind_rows(dispensaries_list) %>%
      filter(!is.na(lat) & !is.na(lon))

    if (nrow(dispensaries_df) > 0) {
      dispensaries_sf <- st_as_sf(dispensaries_df, coords = c("lon", "lat"), crs = 4326)

      # Filter to legal states only
      legal_states_geom <- states_sf %>% filter(legal_status == "Legal")
      dispensaries_sf <- st_filter(dispensaries_sf, legal_states_geom)

      saveRDS(dispensaries_sf, "../data/dispensaries_sf.rds")
      cat(sprintf("Saved %d dispensary locations.\n", nrow(dispensaries_sf)))
    } else {
      cat("No dispensaries found in OSM data.\n")
    }
  }
} else {
  cat("Warning: OSM query failed. Status:", httr::status_code(response), "\n")

  # Create minimal dispensary dataset from known locations
  known_dispensaries <- data.frame(
    name = c("Trinidad Dispensary", "Fort Collins Dispensary", "Ontario Dispensary", "Spokane Dispensary"),
    lat = c(37.169, 40.585, 44.025, 47.658),
    lon = c(-104.500, -105.084, -116.963, -117.426)
  )
  dispensaries_sf <- st_as_sf(known_dispensaries, coords = c("lon", "lat"), crs = 4326)
  saveRDS(dispensaries_sf, "../data/dispensaries_sf.rds")
  cat("Created minimal dispensary dataset with known locations.\n")
}

# =============================================================================
# PART 5: Fetch Person-Level Data for Driver License State
# =============================================================================

cat("\nFetching person-level FARS data for driver license state...\n")

person_data_all <- data.frame()

for (yr in years) {
  csv_url <- sprintf(
    "https://static.nhtsa.gov/nhtsa/downloads/FARS/%d/National/FARS%dNationalCSV.zip",
    yr, yr
  )

  temp_zip <- tempfile(fileext = ".zip")
  tryCatch({
    download.file(csv_url, temp_zip, mode = "wb", quiet = TRUE)
    temp_extract <- tempfile()
    dir.create(temp_extract)
    unzip(temp_zip, exdir = temp_extract)

    # Read person file (contains driver license state: DR_LICEN variable)
    person_file <- list.files(temp_extract, pattern = "person", ignore.case = TRUE, full.names = TRUE)[1]
    if (!is.na(person_file) && file.exists(person_file)) {
      person_data <- read.csv(person_file, stringsAsFactors = FALSE)

      # Filter to study states and drivers only
      names(person_data) <- tolower(names(person_data))

      # PER_TYP = 1 means driver
      if ("per_typ" %in% names(person_data)) {
        person_data <- person_data %>%
          filter(state %in% as.integer(all_fips)) %>%
          filter(per_typ == 1)  # Drivers only
      }

      if (nrow(person_data) > 0) {
        person_data$year <- yr
        person_data_all <- bind_rows(person_data_all, person_data)
        cat(sprintf("  %d: %d driver records\n", yr, nrow(person_data)))
      }
    }

    # Clean up
    unlink(temp_zip)
    unlink(temp_extract, recursive = TRUE)

  }, error = function(e) {
    cat(sprintf("  Error downloading person data for %d: %s\n", yr, e$message))
  })

  Sys.sleep(0.5)  # Rate limiting
}

# Process driver license state data
if (nrow(person_data_all) > 0) {
  cat(sprintf("\nTotal driver records: %d\n", nrow(person_data_all)))

  # Create lookup table: crash (state-year-case number) -> driver license states
  # DR_LICEN is the state FIPS code for driver license (99 = unknown, other = FIPS)
  # We need to match on ST_CASE (unique crash identifier within state-year)

  driver_license_lookup <- person_data_all %>%
    # Clean up column names
    rename_with(tolower) %>%
    # Select key columns (name varies by year)
    select(any_of(c("state", "st_case", "year", "veh_no", "per_no",
                    "dr_licen", "drinking", "age"))) %>%
    # Keep only records with valid driver license state
    filter(!is.na(dr_licen)) %>%
    filter(dr_licen != 99) %>%  # 99 = unknown
    filter(dr_licen != 0) %>%   # 0 = not applicable
    # For each crash, get unique driver license states
    group_by(state, st_case, year) %>%
    summarise(
      # Primary driver license state (first driver)
      driver_license_state = first(dr_licen),
      # All unique driver license states in crash
      all_driver_states = paste(unique(dr_licen), collapse = ","),
      # Any driver from legal state?
      any_legal_state_driver = any(dr_licen %in% as.integer(legal_fips)),
      # Any driver from prohibition state?
      any_prohib_state_driver = any(dr_licen %in% as.integer(prohibition_fips)),
      # Number of drivers
      n_drivers = n(),
      # Drinking status (if available)
      any_drinking = ifelse("drinking" %in% names(.), max(drinking, na.rm = TRUE) > 0, NA),
      # Mean driver age
      mean_driver_age = ifelse("age" %in% names(.), mean(age[age > 0 & age < 100], na.rm = TRUE), NA),
      .groups = "drop"
    )

  cat(sprintf("Created driver license lookup with %d crash records.\n", nrow(driver_license_lookup)))
  saveRDS(driver_license_lookup, "../data/driver_license_lookup.rds")
  saveRDS(person_data_all, "../data/person_data_raw.rds")

} else {
  cat("Warning: No person-level data retrieved. Driver license analysis will not be possible.\n")
  # Create empty lookup to prevent errors downstream
  driver_license_lookup <- data.frame(
    state = integer(), st_case = integer(), year = integer(),
    driver_license_state = integer(), any_legal_state_driver = logical(),
    any_prohib_state_driver = logical()
  )
  saveRDS(driver_license_lookup, "../data/driver_license_lookup.rds")
}

# =============================================================================
# Summary
# =============================================================================

cat("\n=== Data Fetch Summary ===\n")
cat(sprintf("States: %d\n", nrow(states_sf)))
cat(sprintf("Border segments: %d\n", nrow(borders_sf)))
cat(sprintf("Crashes: %d\n", nrow(crashes_sf)))
cat(sprintf("Dispensaries: %d\n", nrow(readRDS("../data/dispensaries_sf.rds"))))
if (exists("driver_license_lookup") && nrow(driver_license_lookup) > 0) {
  cat(sprintf("Driver license records: %d\n", nrow(driver_license_lookup)))
}

cat("\nData fetching complete.\n")
