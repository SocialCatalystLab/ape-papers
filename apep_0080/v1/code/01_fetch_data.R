# =============================================================================
# Paper 107: Spatial RDD of Primary Seatbelt Enforcement Laws
# 01_fetch_data.R - Fetch FARS crash data, state boundaries, policy dates
# =============================================================================

source(here::here("output/paper_107/code/00_packages.R"))

# =============================================================================
# 1. Primary Seatbelt Enforcement Law Dates (from IIHS)
# =============================================================================

# States and their primary enforcement effective dates
# Source: IIHS State Law Database (https://www.iihs.org/topics/seat-belts)
seatbelt_laws <- tribble(
  ~state, ~state_abbr, ~enforcement_type, ~primary_date,
  "Alabama", "AL", "primary", "1999-12-09",
  "Alaska", "AK", "primary", "2006-05-01",
  "Arizona", "AZ", "secondary", NA_character_,
  "Arkansas", "AR", "primary", "2009-06-30",
  "California", "CA", "primary", "1993-01-01",
  "Colorado", "CO", "secondary", NA_character_,
  "Connecticut", "CT", "primary", "1986-01-01",
  "Delaware", "DE", "primary", "2003-06-30",
  "District of Columbia", "DC", "primary", "1997-10-01",
  "Florida", "FL", "primary", "2009-06-30",
  "Georgia", "GA", "primary", "1996-07-01",
  "Hawaii", "HI", "primary", "1985-12-16",
  "Idaho", "ID", "secondary", NA_character_,
  "Illinois", "IL", "primary", "2003-07-03",
  "Indiana", "IN", "primary", "1998-07-01",
  "Iowa", "IA", "primary", "1986-07-01",
  "Kansas", "KS", "primary", "2010-06-10",
  "Kentucky", "KY", "primary", "2006-07-20",
  "Louisiana", "LA", "primary", "1995-09-01",
  "Maine", "ME", "primary", "2007-09-20",
  "Maryland", "MD", "primary", "1997-10-01",
  "Massachusetts", "MA", "secondary", NA_character_,
  "Michigan", "MI", "primary", "2000-04-01",
  "Minnesota", "MN", "primary", "2009-06-09",
  "Mississippi", "MS", "secondary", NA_character_,
  "Missouri", "MO", "secondary", NA_character_,
  "Montana", "MT", "secondary", NA_character_,
  "Nebraska", "NE", "secondary", NA_character_,
  "Nevada", "NV", "secondary", NA_character_,
  "New Hampshire", "NH", "none", NA_character_,  # No seatbelt law for adults
  "New Jersey", "NJ", "primary", "2000-05-01",
  "New Mexico", "NM", "primary", "1986-01-01",
  "New York", "NY", "primary", "1984-12-01",
  "North Carolina", "NC", "primary", "2006-12-01",
  "North Dakota", "ND", "primary", "2023-08-01",
  "Ohio", "OH", "secondary", NA_character_,
  "Oklahoma", "OK", "primary", "1997-11-01",
  "Oregon", "OR", "primary", "1990-12-07",
  "Pennsylvania", "PA", "secondary", NA_character_,
  "Rhode Island", "RI", "primary", "2011-06-30",
  "South Carolina", "SC", "primary", "2005-12-09",
  "South Dakota", "SD", "secondary", NA_character_,
  "Tennessee", "TN", "primary", "2004-07-01",
  "Texas", "TX", "primary", "1985-09-01",
  "Utah", "UT", "primary", "2015-05-12",
  "Vermont", "VT", "secondary", NA_character_,
  "Virginia", "VA", "secondary", NA_character_,
  "Washington", "WA", "primary", "2002-07-01",
  "West Virginia", "WV", "primary", "2013-07-01",
  "Wisconsin", "WI", "primary", "2009-06-30",
  "Wyoming", "WY", "secondary", NA_character_
) %>%
  mutate(primary_date = as.Date(primary_date))

# Add FIPS codes
state_fips <- tigris::fips_codes %>%
  select(state, state_code, state_name) %>%
  distinct() %>%
  filter(state_code <= "56") %>%  # Exclude territories
  rename(state_abbr = state, state_fips = state_code)

seatbelt_laws <- seatbelt_laws %>%
  left_join(state_fips, by = "state_abbr")

# Save policy data
saveRDS(seatbelt_laws, file.path(dir_data, "seatbelt_laws.rds"))
message("✓ Seatbelt law data compiled: ", nrow(filter(seatbelt_laws, enforcement_type == "primary")), " primary states")

# =============================================================================
# 2. State Boundaries from Census TIGER
# =============================================================================

message("Fetching state boundaries from Census TIGER...")

# Get state boundaries (cartographic boundary for cleaner edges)
states_sf <- states(cb = TRUE, year = 2020) %>%
  clean_names() %>%
  select(statefp, stusps, name, geometry) %>%
  rename(state_fips = statefp, state_abbr = stusps, state_name = name) %>%
  filter(!state_fips %in% c("02", "15", "60", "66", "69", "72", "78"))  # Lower 48 + DC

# Project to Albers Equal Area for distance calculations
states_sf <- st_transform(states_sf, crs = 5070)  # NAD83 / Conus Albers

# Join enforcement data
states_sf <- states_sf %>%
  left_join(seatbelt_laws %>% select(state_abbr, enforcement_type, primary_date),
            by = "state_abbr")

saveRDS(states_sf, file.path(dir_data, "states_sf.rds"))
message("✓ State boundaries downloaded: ", nrow(states_sf), " states")

# =============================================================================
# 3. Identify Border Segments (Primary vs Secondary States)
# =============================================================================

message("Computing state border segments...")

# Function to get borders between primary and secondary enforcement states
get_enforcement_borders <- function(states_sf, year) {
  # Determine enforcement status as of given year
  states_year <- states_sf %>%
    mutate(
      is_primary = case_when(
        enforcement_type == "primary" & (is.na(primary_date) | primary_date <= as.Date(paste0(year, "-12-31"))) ~ TRUE,
        enforcement_type == "primary" & primary_date > as.Date(paste0(year, "-12-31")) ~ FALSE,
        TRUE ~ FALSE
      )
    )

  # Get shared boundaries
  borders <- states_year %>%
    select(state_abbr, is_primary, geometry) %>%
    st_intersection(., .) %>%
    filter(state_abbr < state_abbr.1) %>%  # Avoid duplicates
    filter(is_primary != is_primary.1) %>%  # Only primary vs secondary borders
    mutate(
      primary_state = if_else(is_primary, state_abbr, state_abbr.1),
      secondary_state = if_else(!is_primary, state_abbr, state_abbr.1),
      border_id = paste(primary_state, secondary_state, sep = "-"),
      year = year
    ) %>%
    filter(st_geometry_type(.) %in% c("LINESTRING", "MULTILINESTRING"))  # Keep only linear borders

  return(borders)
}

# Get borders for each year 1990-2020
all_borders <- map_dfr(1990:2020, function(yr) {
  tryCatch({
    get_enforcement_borders(states_sf, yr)
  }, error = function(e) {
    message("  Year ", yr, ": ", e$message)
    return(NULL)
  })
})

# Simplify to unique border-years
border_summary <- all_borders %>%
  st_drop_geometry() %>%
  distinct(border_id, primary_state, secondary_state, year)

message("✓ Border segments identified: ", n_distinct(all_borders$border_id), " unique borders across years")

# Save a border file for 2020 (most recent configuration)
borders_2020 <- get_enforcement_borders(states_sf, 2020)
saveRDS(borders_2020, file.path(dir_data, "borders_2020.rds"))

# =============================================================================
# 4. Fetch FARS Crash Data
# =============================================================================

message("Fetching FARS data from NHTSA...")

# Function to download FARS data for a given year
fetch_fars_year <- function(year) {
  message("  Downloading FARS ", year, "...")

  # NHTSA FTP path
  base_url <- "https://static.nhtsa.gov/nhtsa/downloads/FARS"

  # Try to download accident file
  acc_url <- paste0(base_url, "/", year, "/National/FARS", year, "NationalCSV.zip")

  temp_zip <- tempfile(fileext = ".zip")
  temp_dir <- tempdir()

  tryCatch({
    download.file(acc_url, temp_zip, mode = "wb", quiet = TRUE)
    unzip(temp_zip, exdir = temp_dir)

    # Read accident file
    acc_file <- list.files(temp_dir, pattern = "accident", ignore.case = TRUE, full.names = TRUE)
    if (length(acc_file) == 0) {
      acc_file <- list.files(temp_dir, pattern = "ACCIDENT", full.names = TRUE)
    }

    if (length(acc_file) > 0) {
      acc <- read_csv(acc_file[1], show_col_types = FALSE) %>%
        clean_names() %>%
        mutate(year = year)

      # Read person file for fatality details
      per_file <- list.files(temp_dir, pattern = "person", ignore.case = TRUE, full.names = TRUE)
      if (length(per_file) == 0) {
        per_file <- list.files(temp_dir, pattern = "PERSON", full.names = TRUE)
      }

      if (length(per_file) > 0) {
        per <- read_csv(per_file[1], show_col_types = FALSE) %>%
          clean_names() %>%
          mutate(year = year)
      } else {
        per <- NULL
      }

      return(list(accident = acc, person = per))
    }

    return(NULL)
  }, error = function(e) {
    message("    Error: ", e$message)
    return(NULL)
  })
}

# Download years 2000-2020 (lat/long more reliable in modern years)
fars_years <- 2000:2020
fars_list <- map(fars_years, fetch_fars_year, .progress = TRUE)
names(fars_list) <- fars_years

# Combine accident files (convert all columns to character first to handle type mismatches)
fars_acc <- map_dfr(fars_list, function(x) {
  if (!is.null(x) && !is.null(x$accident)) {
    x$accident %>%
      mutate(across(everything(), as.character))
  } else {
    NULL
  }
})

# Convert numeric columns back
numeric_cols <- c("state", "st_case", "fatals", "persons", "ve_total", "drunk_dr",
                  "hour", "minute", "day_week", "month", "year")
for (col in intersect(numeric_cols, names(fars_acc))) {
  fars_acc[[col]] <- as.numeric(fars_acc[[col]])
}

# Handle latitude/longitude
if ("latitude" %in% names(fars_acc)) {
  fars_acc$latitude <- as.numeric(fars_acc$latitude)
}
if ("longitud" %in% names(fars_acc)) {
  fars_acc$longitude <- as.numeric(fars_acc$longitud)
  fars_acc$longitud <- NULL
}

# Combine person files
fars_per <- map_dfr(fars_list, function(x) {
  if (!is.null(x) && !is.null(x$person)) {
    x$person %>%
      mutate(across(everything(), as.character))
  } else {
    NULL
  }
})

# Convert numeric columns in person file
per_numeric_cols <- c("state", "st_case", "per_no", "inj_sev", "per_typ", "ejection",
                      "age", "sex", "year")
for (col in intersect(per_numeric_cols, names(fars_per))) {
  fars_per[[col]] <- as.numeric(fars_per[[col]])
}

message("✓ FARS accident data: ", nrow(fars_acc), " crashes")
message("✓ FARS person data: ", nrow(fars_per), " persons")

# Save raw files
saveRDS(fars_acc, file.path(dir_data, "fars_accident_raw.rds"))
saveRDS(fars_per, file.path(dir_data, "fars_person_raw.rds"))

# =============================================================================
# 5. Clean and Geocode FARS Data
# =============================================================================

message("Cleaning and geocoding FARS data...")

# Check what coordinate columns we have
message("Available columns: ", paste(names(fars_acc)[1:20], collapse = ", "), "...")

# Clean accident data
fars_clean <- fars_acc %>%
  # Select key variables (names vary by year, use common ones)
  select(
    st_case, state, year,
    any_of(c("latitude", "longitude", "longitud", "lat", "long")),
    matches("fatals"),
    matches("persons"),
    matches("ve_total"),  # Number of vehicles
    matches("drunk_dr"),  # Drunk drivers
    matches("lgt_cond|light"),  # Light conditions
    matches("weather"),
    matches("route|road_fnc|func_sys"),  # Road type
    matches("hour|minute"),
    matches("day_week")
  )

# Standardize coordinate column names
if ("longitud" %in% names(fars_clean) && !"longitude" %in% names(fars_clean)) {
  fars_clean <- fars_clean %>% rename(longitude = longitud)
}
if ("lat" %in% names(fars_clean) && !"latitude" %in% names(fars_clean)) {
  fars_clean <- fars_clean %>% rename(latitude = lat)
}
if ("long" %in% names(fars_clean) && !"longitude" %in% names(fars_clean)) {
  fars_clean <- fars_clean %>% rename(longitude = long)
}

# Convert to numeric if needed
fars_clean$latitude <- as.numeric(fars_clean$latitude)
fars_clean$longitude <- as.numeric(fars_clean$longitude)

message("Coordinate columns: latitude range ",
        round(min(fars_clean$latitude, na.rm = TRUE), 2), " to ",
        round(max(fars_clean$latitude, na.rm = TRUE), 2))

# Filter to valid coordinates
fars_clean <- fars_clean %>%
  filter(
    !is.na(latitude) & !is.na(longitude),
    latitude > 20 & latitude < 50,  # Continental US range
    longitude < -60 & longitude > -130
  )

# Add state FIPS
fars_clean <- fars_clean %>%
  mutate(state_fips = sprintf("%02d", state))

# Convert to spatial
fars_sf <- fars_clean %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326) %>%
  st_transform(crs = 5070)  # Same projection as state boundaries

message("✓ Geocoded crashes: ", nrow(fars_sf), " with valid coordinates")
message("  Years covered: ", min(fars_sf$year), "-", max(fars_sf$year))

# Join person-level fatality data
if (!is.null(fars_per)) {
  # Summarize fatalities by crash
  crash_fatals <- fars_per %>%
    group_by(st_case, state, year) %>%
    summarise(
      n_persons = n(),
      n_fatals = sum(inj_sev == 4, na.rm = TRUE),  # 4 = Fatal
      n_drivers = sum(per_typ == 1, na.rm = TRUE),
      n_passengers = sum(per_typ == 2, na.rm = TRUE),
      n_pedestrians = sum(per_typ == 5, na.rm = TRUE),
      n_cyclists = sum(per_typ == 6, na.rm = TRUE),
      n_ejected = sum(ejection %in% c(2, 3), na.rm = TRUE),  # 2=Partially, 3=Totally
      .groups = "drop"
    )

  # Merge with crash file
  fars_sf <- fars_sf %>%
    left_join(crash_fatals, by = c("st_case", "state", "year"))
}

# Save cleaned spatial data
saveRDS(fars_sf, file.path(dir_data, "fars_sf.rds"))
message("✓ Cleaned FARS spatial data saved")

# =============================================================================
# 6. Summary Statistics
# =============================================================================

message("\n=== FARS Data Summary ===")
message("Total crashes: ", format(nrow(fars_sf), big.mark = ","))
message("Years: ", min(fars_sf$year), " - ", max(fars_sf$year))
message("States: ", n_distinct(fars_sf$state_fips))

if ("n_fatals" %in% names(fars_sf)) {
  message("Total fatalities: ", format(sum(fars_sf$n_fatals, na.rm = TRUE), big.mark = ","))
  message("Fatalities per crash (mean): ", round(mean(fars_sf$n_fatals, na.rm = TRUE), 2))
}

message("\n✓ Data fetching complete!")
