# ==============================================================================
# Paper 68: Broadband Internet and Moral Foundations in Local Governance
# 01_fetch_data.R - Download ACS broadband data and terrain ruggedness
# ==============================================================================

source("code/00_packages.R")

# ==============================================================================
# 1. ACS BROADBAND DATA (Table B28002)
# ==============================================================================
cat("=== Fetching ACS Broadband Data ===\n")

#' Fetch ACS data from Census API
#' @param year ACS year
#' @param variables Character vector of variable codes
#' @param state State FIPS code (or "*" for all)
#' @param geography Geographic level ("place", "county", etc.)
fetch_acs <- function(year, variables, state = "*", geography = "place") {

  # Build variable string
  var_string <- paste(c("NAME", variables), collapse = ",")

  # Build URL
  base_url <- sprintf(
    "https://api.census.gov/data/%d/acs/acs5",
    year
  )

  url <- paste0(
    base_url, "?get=", var_string,
    "&for=", geography, ":*",
    "&in=state:", state
  )

  # Fetch
  response <- httr::GET(url)

  if (httr::status_code(response) != 200) {
    warning(sprintf("Failed to fetch ACS %d: HTTP %d", year, httr::status_code(response)))
    return(NULL)
  }

  # Parse JSON
  content <- httr::content(response, "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content)

  # Convert to data frame
  df <- as.data.frame(data[-1, ], stringsAsFactors = FALSE)
  colnames(df) <- data[1, ]

  # Add year
  df$year <- year

  return(df)
}

# Broadband variables
# B28002_001E: Total households
# B28002_004E: Households with a broadband internet subscription
broadband_vars <- c("B28002_001E", "B28002_004E")

# Fetch for all years 2013-2022
all_years <- 2013:2022
broadband_data <- list()

for (yr in all_years) {
  cat(sprintf("  Fetching ACS %d...", yr))
  df <- fetch_acs(yr, broadband_vars, state = "*", geography = "place")
  if (!is.null(df)) {
    broadband_data[[as.character(yr)]] <- df
    cat(sprintf(" %d places\n", nrow(df)))
  } else {
    cat(" FAILED\n")
  }
  Sys.sleep(0.5)  # Rate limiting
}

# Combine all years
broadband_raw <- bind_rows(broadband_data)

# Clean and compute broadband rate
broadband <- broadband_raw %>%
  mutate(
    total_hh = as.numeric(B28002_001E),
    broadband_hh = as.numeric(B28002_004E),
    broadband_rate = broadband_hh / total_hh,
    # Create consistent st_fips identifier
    st_fips = paste0(state, place)
  ) %>%
  filter(!is.na(broadband_rate), total_hh > 0) %>%
  select(st_fips, state, place, NAME, year, total_hh, broadband_hh, broadband_rate)

cat(sprintf("\nACS Broadband: %d observations across %d years\n",
            nrow(broadband), n_distinct(broadband$year)))

# Save
write_csv(broadband, "data/acs_broadband_place.csv")
arrow::write_parquet(broadband, "data/acs_broadband_place.parquet")

# ==============================================================================
# 2. TERRAIN RUGGEDNESS INDEX (Nunn-Puga)
# ==============================================================================
cat("\n=== Fetching Terrain Ruggedness Data ===\n")

# The Nunn-Puga terrain ruggedness data is at country level
# For US counties, we use the replication data from USGS/academic sources
# Here we download from a reliable source

# Alternative: Use USGS elevation data to compute ruggedness
# For now, we'll create a placeholder and note that full data needs download

ruggedness_url <- "https://diegopuga.org/data/rugged/rugged_data.dta"

tryCatch({
  cat("  Downloading terrain ruggedness data...\n")
  download.file(ruggedness_url, "data/rugged_data.dta", mode = "wb", quiet = TRUE)

  # Read the data (this is country-level, so we'll need US county-level separately)
  rugged <- haven::read_dta("data/rugged_data.dta")
  cat(sprintf("  Downloaded: %d countries\n", nrow(rugged)))

  # Note: This is country-level. For US county-level, we need a different source
  # The USGS provides elevation data that can be processed into ruggedness

}, error = function(e) {
  cat("  Terrain data download failed. Will use FCC distance-based alternative.\n")
})

# For US county-level ruggedness, we'll compute from elevation or use alternative
# Let's try the topographic ruggedness index from USGS
cat("\n  Note: US county-level ruggedness will be computed from elevation data.\n")
cat("  Alternative instrument: FCC central office distance (if available).\n")

# ==============================================================================
# 3. FCC FORM 477 DATA (County-level broadband, for robustness)
# ==============================================================================
cat("\n=== Fetching FCC Form 477 Data ===\n")

# FCC provides county-level broadband data going back to 2008
fcc_url_base <- "https://www.fcc.gov/sites/default/files/"

# Try to download recent data
tryCatch({
  fcc_2019_url <- "https://www.fcc.gov/sites/default/files/county_dec2019.csv"
  download.file(fcc_2019_url, "data/fcc_county_dec2019.csv", mode = "wb", quiet = TRUE)
  cat("  Downloaded FCC county data (Dec 2019)\n")
}, error = function(e) {
  cat("  FCC download failed - will proceed with ACS data only.\n")
})

# ==============================================================================
# 4. ACS DEMOGRAPHICS (Controls)
# ==============================================================================
cat("\n=== Fetching ACS Demographics ===\n")

# Variables for controls
demo_vars <- c(
  "B01003_001E",  # Total population
  "B19013_001E",  # Median household income
  "B15003_022E",  # Bachelor's degree
  "B15003_023E",  # Master's degree
  "B15003_024E",  # Professional degree
  "B15003_025E",  # Doctorate
  "B15003_001E",  # Total education
  "B02001_002E",  # White alone
  "B02001_001E",  # Total race
  "B01002_001E"   # Median age
)

# Fetch for 2018 as baseline (middle of our period)
cat("  Fetching ACS demographics (2018)...")
demo_raw <- fetch_acs(2018, demo_vars, state = "*", geography = "place")

if (!is.null(demo_raw)) {
  demographics <- demo_raw %>%
    mutate(
      st_fips = paste0(state, place),
      population = as.numeric(B01003_001E),
      median_income = as.numeric(B19013_001E),
      # Calculate college rate
      college_total = as.numeric(B15003_022E) + as.numeric(B15003_023E) +
                      as.numeric(B15003_024E) + as.numeric(B15003_025E),
      edu_total = as.numeric(B15003_001E),
      pct_college = college_total / edu_total * 100,
      # Race
      white = as.numeric(B02001_002E),
      race_total = as.numeric(B02001_001E),
      pct_white = white / race_total * 100,
      # Age
      median_age = as.numeric(B01002_001E)
    ) %>%
    select(st_fips, state, place, NAME, population, median_income,
           pct_college, pct_white, median_age)

  cat(sprintf(" %d places\n", nrow(demographics)))

  write_csv(demographics, "data/acs_demographics_2018.csv")
  arrow::write_parquet(demographics, "data/acs_demographics_2018.parquet")
}

# ==============================================================================
# 5. COUNTY FIPS CROSSWALK (for place-to-county mapping)
# ==============================================================================
cat("\n=== Creating Place-County Crosswalk ===\n")

# We need to map places to counties for ruggedness merge
# Census provides this via the Geocorr tool, or we can use tigris

tryCatch({
  # Get place geometries
  places_sf <- tigris::places(year = 2019, cb = TRUE)
  counties_sf <- tigris::counties(year = 2019, cb = TRUE)

  # Spatial join to get county for each place
  place_county <- st_join(
    st_centroid(places_sf),
    counties_sf %>% select(COUNTYFP, county_name = NAME, STATEFP),
    left = TRUE
  ) %>%
    st_drop_geometry() %>%
    mutate(
      st_fips = paste0(STATEFP.x, PLACEFP),
      county_fips = paste0(STATEFP.x, COUNTYFP)
    ) %>%
    select(st_fips, county_fips, place_name = NAME.x, county_name, STATEFP = STATEFP.x)

  write_csv(place_county, "data/place_county_crosswalk.csv")
  cat(sprintf("  Crosswalk created: %d places\n", nrow(place_county)))

}, error = function(e) {
  cat(sprintf("  Crosswalk creation failed: %s\n", e$message))
})

# ==============================================================================
# 6. LOAD LOCALVIEW DATA (already processed)
# ==============================================================================
cat("\n=== Loading LocalView Data ===\n")

localview <- arrow::read_parquet("data/localview/panel_place_month.parquet")

# Convert month to year for annual aggregation
localview <- localview %>%
  mutate(
    month_date = as.Date(month),
    year = year(month_date)
  )

# Aggregate to place-year
localview_annual <- localview %>%
  group_by(st_fips, state_name, place_name, year) %>%
  summarise(
    # Moral foundations (proportions)
    care_p = weighted.mean(care_p, n_mf_words, na.rm = TRUE),
    fairness_p = weighted.mean(fairness_p, n_mf_words, na.rm = TRUE),
    loyalty_p = weighted.mean(loyalty_p, n_mf_words, na.rm = TRUE),
    authority_p = weighted.mean(authority_p, n_mf_words, na.rm = TRUE),
    sanctity_p = weighted.mean(sanctity_p, n_mf_words, na.rm = TRUE),
    # Word counts
    n_meetings = sum(n_meetings, na.rm = TRUE),
    n_mf_words = sum(n_mf_words, na.rm = TRUE),
    n_total_words = sum(n_total_words, na.rm = TRUE),
    # Demographics (take first non-NA)
    acs_pop = first(na.omit(acs_pop)),
    acs_median_income = first(na.omit(acs_median_income)),
    .groups = "drop"
  ) %>%
  # Compute derived outcomes
  mutate(
    individualizing = (care_p + fairness_p) / 2,
    binding = (loyalty_p + authority_p + sanctity_p) / 3,
    univ_comm_ratio = individualizing / binding,
    # Log transform for ratio (avoid infinite values)
    log_univ_comm = log(individualizing + 0.001) - log(binding + 0.001)
  )

cat(sprintf("  LocalView annual: %d place-years (%d places, %d years)\n",
            nrow(localview_annual),
            n_distinct(localview_annual$st_fips),
            n_distinct(localview_annual$year)))

write_csv(localview_annual, "data/localview_annual.csv")
arrow::write_parquet(localview_annual, "data/localview_annual.parquet")

# ==============================================================================
# SUMMARY
# ==============================================================================
cat("\n=== Data Fetch Summary ===\n")
cat(sprintf("  ACS Broadband: %d observations\n", nrow(broadband)))
if (exists("demographics") && !is.null(demographics)) {
  cat(sprintf("  ACS Demographics: %d places\n", nrow(demographics)))
} else {
  cat("  ACS Demographics: Fetch failed - will use LocalView demographics\n")
  # Create placeholder demographics from LocalView
  demographics <- localview_annual %>%
    group_by(st_fips) %>%
    summarise(
      population = first(na.omit(acs_pop)),
      median_income = first(na.omit(acs_median_income)),
      pct_college = NA_real_,
      pct_white = NA_real_,
      median_age = NA_real_,
      .groups = "drop"
    )
  write_csv(demographics, "data/acs_demographics_2018.csv")
  arrow::write_parquet(demographics, "data/acs_demographics_2018.parquet")
}
cat(sprintf("  LocalView Annual: %d place-years\n", nrow(localview_annual)))
cat("\nData saved to output/paper_68/data/\n")
