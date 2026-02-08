# ============================================================================
# 01_fetch_data.R
# Swedish School Transport (Skolskjuts) and Educational Equity
# Data acquisition from Swedish APIs
# ============================================================================

source("00_packages.R")

# ============================================================================
# 1. KOLADA API: Municipality-level educational outcomes
# ============================================================================

cat("\n=== Fetching Kolada data ===\n")

# Kolada API base URL
kolada_base <- "https://api.kolada.se/v2"

# KPIs to fetch (educational outcomes)
kpi_codes <- c(
  "N15504",  # Merit points, all schools in municipality
  "N15505",  # Merit points, municipal schools
  "N15506",  # Merit points, friskola (private schools)
  "N15507",  # Merit points, by home municipality
  "N15566",  # Merit points excl. newly arrived
  "U15415",  # SALSA model-calculated value
  "U15416",  # SALSA deviation
  "N15030",  # Teachers with formal qualifications
  "N15033",  # Student-teacher ratio
  "N07531"   # School accessibility (children within 2km)
)

# Years to fetch
years <- 2015:2024

# Function to fetch Kolada data
fetch_kolada <- function(kpi, years) {
  year_str <- paste(years, collapse = ",")
  url <- paste0(kolada_base, "/data/kpi/", kpi, "/year/", year_str)

  cat("  Fetching", kpi, "...")

  tryCatch({
    resp <- request(url) |>
      req_headers(Accept = "application/json") |>
      req_perform()

    data <- resp_body_json(resp)

    if (length(data$values) == 0) {
      cat(" no data\n")
      return(NULL)
    }

    # Parse response
    df <- map_dfr(data$values, function(x) {
      tibble(
        municipality_id = x$municipality,
        year = x$period,
        kpi = kpi,
        value = x$values[[1]]$value %||% NA_real_,
        gender = x$values[[1]]$gender %||% "T"
      )
    })

    cat(" done (", nrow(df), " rows)\n")
    return(df)

  }, error = function(e) {
    cat(" ERROR:", e$message, "\n")
    return(NULL)
  })
}

# Fetch all KPIs
kolada_data <- map_dfr(kpi_codes, ~fetch_kolada(.x, years))

# Pivot to wide format
kolada_wide <- kolada_data |>
  filter(gender == "T") |>  # Total (not gender-split)
  select(-gender) |>
  pivot_wider(names_from = kpi, values_from = value)

# Save
write_csv(kolada_data, "../data/raw/kolada_long.csv")
write_csv(kolada_wide, "../data/raw/kolada_wide.csv")

cat("Kolada data saved:", nrow(kolada_wide), "municipality-year observations\n")

# ============================================================================
# 2. KOLADA: Municipality metadata
# ============================================================================

cat("\n=== Fetching municipality metadata ===\n")

url <- paste0(kolada_base, "/municipality")
resp <- request(url) |>
  req_headers(Accept = "application/json") |>
  req_perform()

muni_data <- resp_body_json(resp)

municipalities <- map_dfr(muni_data$values, function(x) {
  tibble(
    municipality_id = x$id,
    municipality_name = x$title,
    municipality_type = x$type %||% NA_character_
  )
}) |>
  filter(municipality_type == "K")  # K = kommun (municipality)

write_csv(municipalities, "../data/raw/municipalities.csv")
cat("Municipality metadata saved:", nrow(municipalities), "municipalities\n")

# ============================================================================
# 3. SKOLENHETSREGISTRET: School unit data
# ============================================================================

cat("\n=== Fetching school data from Skolenhetsregistret ===\n")

# Skolverket API v1 base URL (v2 may have different structure)
skolverket_base <- "https://api.skolverket.se/skolenhetsregistret/v1/skolenhet"

# Try fetching schools - the API structure may differ
cat("  Attempting to fetch grundskola schools...\n")

tryCatch({
  # Try a simple query first
  test_url <- "https://api.skolverket.se/skolenhetsregistret/v1/skolenhet?size=10"

  resp <- request(test_url) |>
    req_headers(Accept = "application/json") |>
    req_timeout(30) |>
    req_perform()

  test_data <- resp_body_json(resp)

  cat("  API response structure:\n")
  cat("  - Keys:", paste(names(test_data), collapse = ", "), "\n")

  # Fetch all schools in batches
  all_schools <- list()
  page <- 0
  page_size <- 100

  repeat {
    page_url <- paste0(skolverket_base, "?page=", page, "&size=", page_size)

    resp <- request(page_url) |>
      req_headers(Accept = "application/json") |>
      req_timeout(60) |>
      req_perform()

    data <- resp_body_json(resp)

    # Check for different response structures
    items <- data$Skolenheter %||% data$content %||% data$items %||% data

    if (length(items) == 0) break

    all_schools <- c(all_schools, items)

    if (page %% 10 == 0) cat(".")
    page <- page + 1

    if (page > 100) break  # Safety limit
  }

  cat(" fetched", length(all_schools), "schools\n")

  # Parse school data based on actual structure
  if (length(all_schools) > 0) {
    # Check structure of first school
    first_school <- all_schools[[1]]
    cat("  School keys:", paste(names(first_school), collapse = ", "), "\n")

    # Generic parser
    schools_df <- map_dfr(all_schools, function(school) {
      tibble(
        school_id = school$Skolenhetskod %||% school$skolenhetskod %||% NA_character_,
        school_name = school$Namn %||% school$namn %||% NA_character_,
        municipality_id = school$Kommunkod %||%
                         (school$Kommun$kod %||% NA_character_) %||%
                         NA_character_,
        municipality_name = school$Kommun$namn %||%
                           school$kommunnamn %||%
                           NA_character_,
        principal_type = school$Huvudmannatyp$kod %||%
                        school$huvudmannatyp %||%
                        NA_character_,
        address_street = school$Gatuadress %||%
                        (school$Adress$gatuadress %||% NA_character_) %||%
                        NA_character_,
        address_postal = school$Postnummer %||%
                        (school$Adress$postnummer %||% NA_character_) %||%
                        NA_character_,
        address_city = school$Postort %||%
                      (school$Adress$postort %||% NA_character_) %||%
                      NA_character_,
        latitude = as.numeric(school$Position$latitud %||%
                             school$Latitud %||%
                             school$latitud %||%
                             NA),
        longitude = as.numeric(school$Position$longitud %||%
                              school$Longitud %||%
                              school$longitud %||%
                              NA)
      )
    })

    write_csv(schools_df, "../data/raw/schools_grundskola.csv")
    cat("School data saved:", nrow(schools_df), "schools\n")
  }

}, error = function(e) {
  cat("  ERROR fetching from Skolverket API:", e$message, "\n")
  cat("  Will use alternative data source (OpenStreetMap) instead...\n")

  # Create empty structure for fallback to OSM data
  schools_df <- tibble(
    school_id = character(),
    school_name = character(),
    municipality_id = character(),
    municipality_name = character(),
    principal_type = character(),
    address_street = character(),
    address_postal = character(),
    address_city = character(),
    latitude = numeric(),
    longitude = numeric()
  )

  write_csv(schools_df, "../data/raw/schools_grundskola.csv")
  cat("  Empty file created; OpenStreetMap will be used as primary source\n")
})

# ============================================================================
# 4. SCB API: DeSO-level demographics (alternative approach)
# ============================================================================

cat("\n=== Fetching DeSO proxy data ===\n")

# Since direct geodata download failed, use Kolada for DeSO-adjacent metrics
deso_proxy_kpis <- c("N15050", "N15051", "N15052")

deso_proxy <- map_dfr(deso_proxy_kpis, ~fetch_kolada(.x, 2020:2024))

if (nrow(deso_proxy) > 0) {
  write_csv(deso_proxy, "../data/raw/deso_proxy_demographics.csv")
  cat("DeSO proxy data saved:", nrow(deso_proxy), "rows\n")
}

# ============================================================================
# 5. Fetch school coordinates from OpenStreetMap
# ============================================================================

cat("\n=== Fetching school coordinates from OpenStreetMap via Overpass API ===\n")

# Overpass API query for Swedish schools
overpass_url <- "https://overpass-api.de/api/interpreter"

overpass_query <- '[out:json][timeout:120];
area["ISO3166-1"="SE"][admin_level=2];
(
  node["amenity"="school"](area);
  way["amenity"="school"](area);
  relation["amenity"="school"](area);
);
out center;'

cat("  Querying Overpass API for Swedish schools...\n")

tryCatch({
  resp <- request(overpass_url) |>
    req_body_form(data = overpass_query) |>
    req_timeout(180) |>
    req_perform()

  osm_data <- resp_body_json(resp)

  osm_schools <- map_dfr(osm_data$elements, function(elem) {
    # Get coordinates (either from node or center of way/relation)
    lat <- elem$lat %||% elem$center$lat %||% NA_real_
    lon <- elem$lon %||% elem$center$lon %||% NA_real_

    tags <- elem$tags %||% list()

    tibble(
      osm_id = as.character(elem$id),
      osm_type = elem$type,
      name = tags$name %||% NA_character_,
      latitude = lat,
      longitude = lon,
      school_type = tags$`school:type` %||% tags$isced %||% NA_character_,
      operator = tags$operator %||% NA_character_,
      addr_street = tags$`addr:street` %||% NA_character_,
      addr_city = tags$`addr:city` %||% NA_character_,
      addr_postcode = tags$`addr:postcode` %||% NA_character_
    )
  })

  write_csv(osm_schools, "../data/raw/osm_schools.csv")
  cat("  OSM schools fetched:", nrow(osm_schools), "locations\n")

}, error = function(e) {
  cat("  ERROR fetching from Overpass:", e$message, "\n")
  cat("  School coordinates will need to be geocoded from addresses\n")
})

# ============================================================================
# 6. SUMMARY
# ============================================================================

cat("\n=== Data fetch summary ===\n")
cat("Files saved to ../data/raw/:\n")

raw_files <- list.files("../data/raw", full.names = FALSE)
for (f in raw_files) {
  size <- file.size(paste0("../data/raw/", f))
  cat(sprintf("  %s (%.1f KB)\n", f, size / 1024))
}

cat("\nData acquisition complete.\n")
