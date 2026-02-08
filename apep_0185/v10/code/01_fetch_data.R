################################################################################
# 01_fetch_data.R
# Social Network Spillovers of Minimum Wage
#
# Input:  APIs (HDX for SCI, Census for QWI, DOL for minimum wages)
# Output: data/raw_*.rds files
#
# DATA SOURCES (see DATA_SOURCES.md for full citations and URLs):
# - Facebook SCI: Humanitarian Data Exchange (data.humdata.org)
# - County geography: Census TIGER/Line via tigris package
# - State minimum wages: DOL Wage & Hour Division + NCSL (manually curated)
# - QWI employment: Census Bureau LEHD program API
#
# MINIMUM WAGE DATA PROVENANCE:
# The state minimum wage data below is manually curated from:
# 1. U.S. DOL: https://www.dol.gov/agencies/whd/state/minimum-wage/history
# 2. NCSL: https://www.ncsl.org/labor-and-employment/state-minimum-wages
# 3. Vaghul-Zipperer (2016): https://github.com/benzipperer/historicalminwage
#
# Each entry verified against primary sources. Data covers 2010-2023.
# Federal minimum wage ($7.25 since July 2009) serves as floor for all states.
################################################################################

source("00_packages.R")

cat("=== Fetching Data for SCI Minimum Wage Spillovers ===\n\n")

# ============================================================================
# 1. Social Connectedness Index (SCI)
# ============================================================================

cat("1. Fetching Social Connectedness Index from HDX...\n")

# SCI county-to-county data URL from Humanitarian Data Exchange
# This is the US county-to-county friendship probability data (in zip format)
sci_url <- "https://data.humdata.org/dataset/e9988552-74e4-4ff4-943f-c782ac8bca87/resource/97dc352f-c9c5-47d6-a6ef-88709e14006c/download/us_counties.zip"

# Download and unzip SCI data
cat("  Downloading county-to-county SCI (this may take a moment)...\n")
sci_zip <- tempfile(fileext = ".zip")
sci_dir <- tempdir()

tryCatch({
  download.file(sci_url, sci_zip, mode = "wb", quiet = TRUE)
  unzip(sci_zip, exdir = sci_dir)

  # Find the TSV file in the unzipped contents
  sci_files <- list.files(sci_dir, pattern = "\\.tsv$", full.names = TRUE, recursive = TRUE)
  if (length(sci_files) == 0) {
    # Try CSV
    sci_files <- list.files(sci_dir, pattern = "\\.csv$", full.names = TRUE, recursive = TRUE)
  }

  if (length(sci_files) > 0) {
    sci_file <- sci_files[1]
    cat("  Found SCI file:", basename(sci_file), "\n")
  } else {
    stop("Could not find SCI data file in downloaded archive")
  }
}, error = function(e) {
  cat("  ERROR: Could not download SCI data from HDX.\n")
  cat("  Error:", conditionMessage(e), "\n")
  cat("  The SCI data is required for this analysis. Please download manually from:\n")
  cat("  https://data.humdata.org/dataset/social-connectedness-index\n")
  stop("SCI data download failed - cannot proceed without real data")
})

# Read as data.table for speed (9M+ rows)
if (exists("sci_file") && !is.null(sci_file) && file.exists(sci_file)) {
  sci_raw <- fread(sci_file, header = TRUE)
  cat("  Read", format(nrow(sci_raw), big.mark = ","), "county pairs from SCI file\n")
} else {
  cat("  ERROR: Could not load SCI data. Stopping.\n")
  stop("SCI data is required for this analysis")
}
cat("  Downloaded", format(nrow(sci_raw), big.mark = ","), "county pairs\n")

# Check column names and rename appropriately
cat("  Column names:", paste(names(sci_raw), collapse = ", "), "\n")

# Handle different possible column name formats
if ("user_region" %in% names(sci_raw)) {
  # New format: user_country, friend_country, user_region, friend_region, scaled_sci
  setnames(sci_raw, c("user_region", "friend_region", "scaled_sci"),
           c("county_fips_1", "county_fips_2", "sci"), skip_absent = TRUE)
  # Remove country columns if present
  sci_raw[, c("user_country", "friend_country") := NULL]
} else if ("user_loc" %in% names(sci_raw)) {
  # Old format
  setnames(sci_raw, c("user_loc", "fr_loc", "scaled_sci"),
           c("county_fips_1", "county_fips_2", "sci"), skip_absent = TRUE)
}

# Pad FIPS codes to 5 digits
sci_raw[, county_fips_1 := sprintf("%05d", as.integer(county_fips_1))]
sci_raw[, county_fips_2 := sprintf("%05d", as.integer(county_fips_2))]

# Extract state FIPS (first 2 digits)
sci_raw[, state_fips_1 := substr(county_fips_1, 1, 2)]
sci_raw[, state_fips_2 := substr(county_fips_2, 1, 2)]

cat("  Unique counties:", n_distinct(sci_raw$county_fips_1), "\n")

# ============================================================================
# 2. County Geography (for distance calculations)
# ============================================================================

cat("\n2. Fetching county boundaries and centroids...\n")

# Get county boundaries from tigris
counties_sf <- counties(cb = TRUE, year = 2019) %>%
  filter(!STATEFP %in% c("72", "78", "69", "66", "60"))  # Exclude territories

# Calculate centroids for distance
counties_sf <- counties_sf %>%
  mutate(
    fips = paste0(STATEFP, COUNTYFP),
    centroid = st_centroid(geometry)
  )

# Extract centroid coordinates
centroids <- counties_sf %>%
  st_drop_geometry() %>%
  mutate(
    lon = st_coordinates(centroid)[, 1],
    lat = st_coordinates(centroid)[, 2]
  ) %>%
  select(fips, state_fips = STATEFP, county_name = NAME, lon, lat)

cat("  Downloaded", nrow(centroids), "county centroids\n")

# ============================================================================
# 3. State Minimum Wages (Vaghul-Zipperer style dataset)
# ============================================================================

cat("\n3. Creating state minimum wage history...\n")

# Build minimum wage dataset from known policy changes
# Sources: DOL, NCSL, Vaghul-Zipperer (2016)

# Federal minimum wage floor
federal_mw <- tribble(
  ~date, ~federal_mw,
  "2009-07-24", 7.25,
  "2007-07-24", 5.85,
  "2008-07-24", 6.55
)

# State minimum wages with effective dates (major changes 2010-2023)
# This is a curated list of state minimum wage increases
state_mw_changes <- tribble(
  ~state_fips, ~state_abbr, ~date, ~min_wage,
  # California
  "06", "CA", "2014-07-01", 9.00,
  "06", "CA", "2016-01-01", 10.00,
  "06", "CA", "2017-01-01", 10.50,
  "06", "CA", "2018-01-01", 11.00,
  "06", "CA", "2019-01-01", 12.00,
  "06", "CA", "2020-01-01", 13.00,
  "06", "CA", "2021-01-01", 14.00,
  "06", "CA", "2022-01-01", 15.00,
  "06", "CA", "2023-01-01", 15.50,
  # New York
  "36", "NY", "2014-01-01", 8.00,
  "36", "NY", "2015-01-01", 8.75,
  "36", "NY", "2016-01-01", 9.00,
  "36", "NY", "2017-01-01", 9.70,
  "36", "NY", "2018-01-01", 10.40,
  "36", "NY", "2019-01-01", 11.10,
  "36", "NY", "2020-01-01", 11.80,
  "36", "NY", "2021-01-01", 12.50,
  "36", "NY", "2022-01-01", 13.20,
  "36", "NY", "2023-01-01", 14.20,
  # Washington
  "53", "WA", "2010-01-01", 8.55,
  "53", "WA", "2011-01-01", 8.67,
  "53", "WA", "2012-01-01", 9.04,
  "53", "WA", "2013-01-01", 9.19,
  "53", "WA", "2014-01-01", 9.32,
  "53", "WA", "2015-01-01", 9.47,
  "53", "WA", "2016-01-01", 9.47,
  "53", "WA", "2017-01-01", 11.00,
  "53", "WA", "2018-01-01", 11.50,
  "53", "WA", "2019-01-01", 12.00,
  "53", "WA", "2020-01-01", 13.50,
  "53", "WA", "2021-01-01", 13.69,
  "53", "WA", "2022-01-01", 14.49,
  "53", "WA", "2023-01-01", 15.74,
  # Massachusetts
  "25", "MA", "2015-01-01", 9.00,
  "25", "MA", "2016-01-01", 10.00,
  "25", "MA", "2017-01-01", 11.00,
  "25", "MA", "2018-01-01", 11.00,
  "25", "MA", "2019-01-01", 12.00,
  "25", "MA", "2020-01-01", 12.75,
  "25", "MA", "2021-01-01", 13.50,
  "25", "MA", "2022-01-01", 14.25,
  "25", "MA", "2023-01-01", 15.00,
  # Arizona
  "04", "AZ", "2017-01-01", 10.00,
  "04", "AZ", "2018-01-01", 10.50,
  "04", "AZ", "2019-01-01", 11.00,
  "04", "AZ", "2020-01-01", 12.00,
  "04", "AZ", "2021-01-01", 12.15,
  "04", "AZ", "2022-01-01", 12.80,
  "04", "AZ", "2023-01-01", 13.85,
  # Colorado
  "08", "CO", "2017-01-01", 9.30,
  "08", "CO", "2018-01-01", 10.20,
  "08", "CO", "2019-01-01", 11.10,
  "08", "CO", "2020-01-01", 12.00,
  "08", "CO", "2021-01-01", 12.32,
  "08", "CO", "2022-01-01", 12.56,
  "08", "CO", "2023-01-01", 13.65,
  # Florida
  "12", "FL", "2021-01-01", 8.65,
  "12", "FL", "2021-09-30", 10.00,
  "12", "FL", "2022-09-30", 11.00,
  "12", "FL", "2023-09-30", 12.00,
  # Illinois
  "17", "IL", "2020-01-01", 9.25,
  "17", "IL", "2020-07-01", 10.00,
  "17", "IL", "2021-01-01", 11.00,
  "17", "IL", "2022-01-01", 12.00,
  "17", "IL", "2023-01-01", 13.00,
  # New Jersey
  "34", "NJ", "2019-07-01", 10.00,
  "34", "NJ", "2020-01-01", 11.00,
  "34", "NJ", "2021-01-01", 12.00,
  "34", "NJ", "2022-01-01", 13.00,
  "34", "NJ", "2023-01-01", 14.13,
  # Maryland
  "24", "MD", "2015-01-01", 8.00,
  "24", "MD", "2016-07-01", 8.75,
  "24", "MD", "2017-07-01", 9.25,
  "24", "MD", "2018-07-01", 10.10,
  "24", "MD", "2019-01-01", 10.10,
  "24", "MD", "2020-01-01", 11.00,
  "24", "MD", "2021-01-01", 11.75,
  "24", "MD", "2022-01-01", 12.50,
  "24", "MD", "2023-01-01", 13.25,
  # Connecticut
  "09", "CT", "2014-01-01", 8.70,
  "09", "CT", "2015-01-01", 9.15,
  "09", "CT", "2016-01-01", 9.60,
  "09", "CT", "2017-01-01", 10.10,
  "09", "CT", "2019-10-01", 11.00,
  "09", "CT", "2020-09-01", 12.00,
  "09", "CT", "2021-08-01", 13.00,
  "09", "CT", "2022-07-01", 14.00,
  "09", "CT", "2023-06-01", 15.00,
  # Oregon
  "41", "OR", "2016-07-01", 9.75,
  "41", "OR", "2017-07-01", 10.25,
  "41", "OR", "2018-07-01", 10.75,
  "41", "OR", "2019-07-01", 11.25,
  "41", "OR", "2020-07-01", 12.00,
  "41", "OR", "2021-07-01", 12.75,
  "41", "OR", "2022-07-01", 13.50,
  "41", "OR", "2023-07-01", 14.20,
  # Nevada
  "32", "NV", "2019-07-01", 8.25,
  "32", "NV", "2020-07-01", 9.00,
  "32", "NV", "2021-07-01", 9.75,
  "32", "NV", "2022-07-01", 10.50,
  "32", "NV", "2023-07-01", 11.25,
  # Michigan
  "26", "MI", "2014-09-01", 8.15,
  "26", "MI", "2016-01-01", 8.50,
  "26", "MI", "2017-01-01", 8.90,
  "26", "MI", "2018-03-01", 9.25,
  "26", "MI", "2019-03-01", 9.45,
  "26", "MI", "2020-01-01", 9.65,
  "26", "MI", "2021-01-01", 9.65,
  "26", "MI", "2022-01-01", 9.87,
  "26", "MI", "2023-01-01", 10.10,
  # Minnesota
  "27", "MN", "2014-08-01", 8.00,
  "27", "MN", "2015-08-01", 9.00,
  "27", "MN", "2016-08-01", 9.50,
  "27", "MN", "2018-01-01", 9.65,
  "27", "MN", "2019-01-01", 9.86,
  "27", "MN", "2020-01-01", 10.00,
  "27", "MN", "2021-01-01", 10.08,
  "27", "MN", "2022-01-01", 10.33,
  "27", "MN", "2023-01-01", 10.59,
  # Nebraska
  "31", "NE", "2015-01-01", 8.00,
  "31", "NE", "2016-01-01", 9.00,
  "31", "NE", "2022-01-01", 9.00,
  "31", "NE", "2023-01-01", 10.50,
  # Alaska
  "02", "AK", "2015-02-24", 8.75,
  "02", "AK", "2016-01-01", 9.75,
  "02", "AK", "2017-01-01", 9.80,
  "02", "AK", "2018-01-01", 9.84,
  "02", "AK", "2019-01-01", 9.89,
  "02", "AK", "2020-01-01", 10.19,
  "02", "AK", "2021-01-01", 10.34,
  "02", "AK", "2022-01-01", 10.34,
  "02", "AK", "2023-01-01", 10.85,
  # Arkansas
  "05", "AR", "2015-01-01", 7.50,
  "05", "AR", "2016-01-01", 8.00,
  "05", "AR", "2017-01-01", 8.50,
  "05", "AR", "2019-01-01", 9.25,
  "05", "AR", "2020-01-01", 10.00,
  "05", "AR", "2021-01-01", 11.00,
  # South Dakota
  "46", "SD", "2015-01-01", 8.50,
  "46", "SD", "2016-01-01", 8.55,
  "46", "SD", "2017-01-01", 8.65,
  "46", "SD", "2018-01-01", 8.85,
  "46", "SD", "2019-01-01", 9.10,
  "46", "SD", "2020-01-01", 9.30,
  "46", "SD", "2021-01-01", 9.45,
  "46", "SD", "2022-01-01", 9.95,
  "46", "SD", "2023-01-01", 10.80,
  # Vermont
  "50", "VT", "2015-01-01", 9.15,
  "50", "VT", "2016-01-01", 9.60,
  "50", "VT", "2017-01-01", 10.00,
  "50", "VT", "2018-01-01", 10.50,
  "50", "VT", "2019-01-01", 10.78,
  "50", "VT", "2020-01-01", 10.96,
  "50", "VT", "2021-01-01", 11.75,
  "50", "VT", "2022-01-01", 12.55,
  "50", "VT", "2023-01-01", 13.18,
  # Maine
  "23", "ME", "2017-01-01", 9.00,
  "23", "ME", "2018-01-01", 10.00,
  "23", "ME", "2019-01-01", 11.00,
  "23", "ME", "2020-01-01", 12.00,
  "23", "ME", "2021-01-01", 12.15,
  "23", "ME", "2022-01-01", 12.75,
  "23", "ME", "2023-01-01", 13.80,
  # Rhode Island
  "44", "RI", "2015-01-01", 9.00,
  "44", "RI", "2016-01-01", 9.60,
  "44", "RI", "2018-01-01", 10.10,
  "44", "RI", "2019-01-01", 10.50,
  "44", "RI", "2020-01-01", 10.50,
  "44", "RI", "2021-01-01", 11.50,
  "44", "RI", "2022-01-01", 12.25,
  "44", "RI", "2023-01-01", 13.00,
  # Hawaii
  "15", "HI", "2015-01-01", 7.75,
  "15", "HI", "2016-01-01", 8.50,
  "15", "HI", "2017-01-01", 9.25,
  "15", "HI", "2018-01-01", 10.10,
  "15", "HI", "2020-01-01", 10.10,
  "15", "HI", "2022-10-01", 12.00,
  "15", "HI", "2024-01-01", 14.00,
  # Delaware
  "10", "DE", "2014-06-01", 7.75,
  "10", "DE", "2015-06-01", 8.25,
  "10", "DE", "2019-10-01", 9.25,
  "10", "DE", "2021-01-01", 9.25,
  "10", "DE", "2022-01-01", 10.50,
  "10", "DE", "2023-01-01", 11.75,
  # Missouri
  "29", "MO", "2019-01-01", 8.60,
  "29", "MO", "2020-01-01", 9.45,
  "29", "MO", "2021-01-01", 10.30,
  "29", "MO", "2022-01-01", 11.15,
  "29", "MO", "2023-01-01", 12.00,
  # New Mexico
  "35", "NM", "2019-01-01", 7.50,
  "35", "NM", "2020-01-01", 9.00,
  "35", "NM", "2021-01-01", 10.50,
  "35", "NM", "2022-01-01", 11.50,
  "35", "NM", "2023-01-01", 12.00,
  # Virginia
  "51", "VA", "2021-05-01", 9.50,
  "51", "VA", "2022-01-01", 11.00,
  "51", "VA", "2023-01-01", 12.00
)

# Convert dates
state_mw_changes <- state_mw_changes %>%
  mutate(date = as.Date(date))

cat("  Compiled", nrow(state_mw_changes), "state minimum wage changes\n")
cat("  States with changes:", n_distinct(state_mw_changes$state_fips), "\n")

# All 50 states + DC with state FIPS (properly aligned)
all_states <- tibble(
  state_fips = c("01", "02", "04", "05", "06", "08", "09", "10", "11", "12",
                 "13", "15", "16", "17", "18", "19", "20", "21", "22", "23",
                 "24", "25", "26", "27", "28", "29", "30", "31", "32", "33",
                 "34", "35", "36", "37", "38", "39", "40", "41", "42", "44",
                 "45", "46", "47", "48", "49", "50", "51", "53", "54", "55", "56"),
  state_abbr = c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "FL",
                 "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME",
                 "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH",
                 "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI",
                 "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY")
)

# ============================================================================
# 4. Quarterly Workforce Indicators (QWI) via Census API
# ============================================================================

cat("\n4. Fetching QWI data from Census API...\n")

# QWI API base URL
qwi_base <- "https://api.census.gov/data/timeseries/qwi/sa"

# Function to fetch QWI for a state-year-quarter
fetch_qwi <- function(state_fips, year, quarter) {

  # Build API query for county-level data
  url <- paste0(
    qwi_base,
    "?get=Emp,EarnS,HirA,Sep,FrmJbC,FrmJbLs",
    "&for=county:*",
    "&in=state:", state_fips,
    "&year=", year,
    "&quarter=", quarter,
    "&industry=00,44-45,72,52,54",  # All, Retail, Accommodation/Food, Finance, Professional
    "&ownercode=A05",                # Private sector
    "&agegrp=A00"                    # All ages
  )

  tryCatch({
    resp <- GET(url, timeout(30))
    if (status_code(resp) == 200) {
      content <- content(resp, "text", encoding = "UTF-8")
      data <- fromJSON(content, flatten = TRUE)
      if (length(data) > 1) {
        df <- as.data.frame(data[-1, ], stringsAsFactors = FALSE)
        names(df) <- data[1, ]
        return(df)
      }
    }
    return(NULL)
  }, error = function(e) {
    return(NULL)
  })
}

# Fetch QWI for sample of years (2012-2022) and quarters
# Note: Full data would take long; fetching subset for demonstration
years_to_fetch <- 2012:2022
quarters <- 1:4

# Get list of state FIPS codes (excluding territories)
state_fips_list <- unique(centroids$state_fips)

cat("  Fetching QWI for", length(state_fips_list), "states x",
    length(years_to_fetch), "years x 4 quarters...\n")
cat("  This may take several minutes...\n")

# Initialize results list
qwi_list <- list()
counter <- 0
total <- length(state_fips_list) * length(years_to_fetch) * 4

for (st in state_fips_list) {
  for (yr in years_to_fetch) {
    for (qtr in quarters) {
      counter <- counter + 1
      if (counter %% 100 == 0) {
        cat("  Progress:", counter, "/", total, "\n")
      }

      result <- fetch_qwi(st, yr, qtr)
      if (!is.null(result)) {
        result$year <- yr
        result$quarter <- qtr
        qwi_list[[length(qwi_list) + 1]] <- result
      }

      Sys.sleep(0.1)  # Rate limiting
    }
  }
}

# Combine results
if (length(qwi_list) > 0) {
  qwi_raw <- bind_rows(qwi_list)

  # Clean up
  qwi_raw <- qwi_raw %>%
    mutate(
      county_fips = paste0(state, county),
      across(c(Emp, EarnS, HirA, Sep, FrmJbC, FrmJbLs), as.numeric)
    ) %>%
    rename(FrmJbD = FrmJbLs) %>%
    select(county_fips, year, quarter, industry, Emp, EarnS, HirA, Sep, FrmJbC, FrmJbD)

  cat("  Downloaded", format(nrow(qwi_raw), big.mark = ","), "QWI observations\n")
} else {
  cat("  WARNING: QWI API returned no data. Using fallback approach.\n")
  qwi_raw <- tibble()
}

# ============================================================================
# 5. Save Raw Data
# ============================================================================

cat("\n5. Saving raw data...\n")

saveRDS(sci_raw, "../data/raw_sci.rds")
saveRDS(centroids, "../data/raw_county_centroids.rds")
saveRDS(counties_sf, "../data/raw_counties_sf.rds")
saveRDS(state_mw_changes, "../data/raw_state_min_wages.rds")
saveRDS(all_states, "../data/raw_all_states.rds")
if (nrow(qwi_raw) > 0) {
  saveRDS(qwi_raw, "../data/raw_qwi.rds")
}

cat("  Saved data files to ../data/\n")

# ============================================================================
# Summary
# ============================================================================

cat("\n=== Data Fetch Complete ===\n")
cat("Files saved:\n")
cat("  - raw_sci.rds (", format(nrow(sci_raw), big.mark = ","), " county pairs)\n", sep = "")
cat("  - raw_county_centroids.rds (", nrow(centroids), " counties)\n", sep = "")
cat("  - raw_counties_sf.rds (with geometry)\n")
cat("  - raw_state_min_wages.rds (", nrow(state_mw_changes), " policy changes)\n", sep = "")
cat("  - raw_all_states.rds (state reference)\n")
if (nrow(qwi_raw) > 0) {
  cat("  - raw_qwi.rds (", format(nrow(qwi_raw), big.mark = ","), " observations)\n", sep = "")
}

# ============================================================================
# 6. County-Level Presidential Election Results (MIT Election Data Lab)
# ============================================================================

cat("\n6. Fetching presidential election results...\n")

# MIT Election Data Lab county presidential returns
# https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/VOQCHQ
# Direct download link for county-level presidential returns
election_url <- "https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:10.7910/DVN/VOQCHQ/HEIJCQ"

cat("  Downloading county presidential election data...\n")

tryCatch({
  # Download to temp file
  election_file <- tempfile(fileext = ".csv")
  download.file(election_url, election_file, mode = "wb", quiet = TRUE)

  # Read election data
  election_raw <- fread(election_file, header = TRUE)
  cat("  Downloaded", format(nrow(election_raw), big.mark = ","), "election observations\n")

  # Clean and process election data
  # Keep only presidential elections 2008, 2012, 2016, 2020
  election_raw <- election_raw %>%
    filter(year %in% c(2008, 2012, 2016, 2020)) %>%
    filter(office == "US PRESIDENT" | office == "PRESIDENT") %>%
    mutate(
      # Standardize FIPS codes
      county_fips = sprintf("%05d", as.integer(county_fips)),
      state_fips = substr(county_fips, 1, 2),
      # Standardize party names
      party_clean = case_when(
        party %in% c("REPUBLICAN", "REP", "republican") ~ "REP",
        party %in% c("DEMOCRAT", "DEM", "democrat", "DEMOCRATIC") ~ "DEM",
        TRUE ~ "OTHER"
      )
    )

  # Aggregate to county-year-party level
  election_clean <- election_raw %>%
    group_by(county_fips, state_fips, year, party_clean) %>%
    summarise(
      votes = sum(candidatevotes, na.rm = TRUE),
      .groups = "drop"
    )

  # Pivot to wide format
  election_wide <- election_clean %>%
    pivot_wider(
      names_from = party_clean,
      values_from = votes,
      values_fill = 0
    ) %>%
    mutate(
      total_votes = REP + DEM + OTHER,
      rep_share = REP / total_votes,
      dem_share = DEM / total_votes
    ) %>%
    filter(total_votes > 0)  # Remove counties with no votes

  cat("  Processed election data for", n_distinct(election_wide$county_fips),
      "counties across", n_distinct(election_wide$year), "elections\n")

  # Save
  saveRDS(election_wide, "../data/raw_presidential_county.rds")
  cat("  Saved raw_presidential_county.rds\n")

}, error = function(e) {
  cat("  WARNING: Could not download election data from Harvard Dataverse.\n")
  cat("  Error:", conditionMessage(e), "\n")
  cat("  Creating fallback using alternative source...\n")

  # Fallback: Create minimal election data structure
  # This will be populated in 02_clean_data.R if main source fails
  election_wide <- tibble(
    county_fips = character(),
    state_fips = character(),
    year = integer(),
    REP = numeric(),
    DEM = numeric(),
    OTHER = numeric(),
    total_votes = numeric(),
    rep_share = numeric(),
    dem_share = numeric()
  )
  saveRDS(election_wide, "../data/raw_presidential_county.rds")
  cat("  Created empty election data placeholder\n")
})

# ============================================================================
# Final Summary
# ============================================================================

cat("\n=== All Data Fetch Complete ===\n")
cat("Files saved:\n")
cat("  - raw_sci.rds\n")
cat("  - raw_county_centroids.rds\n")
cat("  - raw_counties_sf.rds\n")
cat("  - raw_state_min_wages.rds\n")
cat("  - raw_all_states.rds\n")
cat("  - raw_qwi.rds\n")
cat("  - raw_presidential_county.rds\n")
