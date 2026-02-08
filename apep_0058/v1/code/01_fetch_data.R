# =============================================================================
# Paper 73: SOI Discrimination Laws and Housing Voucher Utilization
# 01_fetch_data.R - Download HUD and other data sources
# =============================================================================

source("code/00_packages.R")

# =============================================================================
# 1. SOI Law Treatment Data
# =============================================================================

# Source: PRRAC Appendix B, Urban Institute dataset, CBPP
# Manually compiled from legal databases

soi_laws <- tribble(
  ~state, ~state_abbr, ~effective_date, ~law_strength, ~source,
  # Early adopters (pre-2010) - treated in entire panel
  "Massachusetts", "MA", "1971-08-31", "strong", "PRRAC",
  "Wisconsin", "WI", "1980-01-01", "weak", "PRRAC",  # Does not cover Section 8
  "North Dakota", "ND", "1983-01-01", "moderate", "PRRAC",
  "Oklahoma", "OK", "1985-01-01", "moderate", "PRRAC",
  "Connecticut", "CT", "1989-01-01", "strong", "PRRAC",
  "Minnesota", "MN", "1990-01-01", "strong", "PRRAC",
  "New Jersey", "NJ", "2002-01-01", "strong", "PRRAC",
  "District of Columbia", "DC", "2005-02-09", "strong", "PRRAC",

  # Mid-period adopters (2010-2018)
  "Oregon", "OR", "2014-01-01", "strong", "PRRAC",  # Voucher exemption repealed
  "Utah", "UT", "2015-05-12", "moderate", "PRRAC",
  "Delaware", "DE", "2016-08-03", "moderate", "PRRAC",
  "Vermont", "VT", "2017-07-01", "strong", "PRRAC",
  "Washington", "WA", "2018-06-07", "strong", "PRRAC",

  # Recent wave (2019-2022) - main identification
  "New York", "NY", "2019-04-12", "strong", "PRRAC",
  "California", "CA", "2020-01-01", "strong", "PRRAC",
  "Maine", "ME", "2020-01-01", "moderate", "PRRAC",
  "Maryland", "MD", "2020-10-01", "strong", "PRRAC",
  "Virginia", "VA", "2021-07-01", "strong", "PRRAC",
  "Colorado", "CO", "2021-01-01", "strong", "PRRAC",
  "Rhode Island", "RI", "2021-07-01", "moderate", "PRRAC",
  "Illinois", "IL", "2022-01-01", "strong", "PRRAC",
  "Michigan", "MI", "2025-01-01", "strong", "PRRAC"  # Too recent for analysis
)

# Convert to date and calculate treatment timing
soi_laws <- soi_laws %>%
  mutate(
    effective_date = ymd(effective_date),
    treat_year = year(effective_date),
    treat_month = month(effective_date),
    treat_ym = year(effective_date) + (month(effective_date) - 1) / 12
  )

# Save treatment data
write_csv(soi_laws, "data/soi_laws.csv")
cat("SOI law data saved.\n")

# =============================================================================
# 2. HUD Voucher Utilization Data - CBPP Compiled
# =============================================================================

# CBPP provides annual state-level voucher utilization from 2004-present
# URL: https://www.cbpp.org/research/housing/national-and-state-housing-fact-sheets-data

# Note: This requires downloading Excel files manually or scraping
# For now, we'll create the expected structure and note data source

# State FIPS codes
state_fips <- tibble(
  state_abbr = c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "FL",
                 "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME",
                 "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH",
                 "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI",
                 "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"),
  state_fips = c("01", "02", "04", "05", "06", "08", "09", "10", "11", "12",
                 "13", "15", "16", "17", "18", "19", "20", "21", "22", "23",
                 "24", "25", "26", "27", "28", "29", "30", "31", "32", "33",
                 "34", "35", "36", "37", "38", "39", "40", "41", "42", "44",
                 "45", "46", "47", "48", "49", "50", "51", "53", "54", "55", "56")
)

# =============================================================================
# 3. Download HUD Picture of Subsidized Households
# =============================================================================

# HUD PIC data at state level
# Available at: https://www.huduser.gov/portal/datasets/assthsg.html

download_hud_picture <- function(year) {
  # State-level summary URL pattern
  base_url <- "https://www.huduser.gov/portal/datasets/assthsg/sts"

  # Different URL structure by year
  if (year >= 2018) {
    url <- sprintf("https://www.huduser.gov/portal/datasets/assthsg/sts/state%d.csv", year)
  } else {
    url <- sprintf("https://www.huduser.gov/portal/datasets/assthsg/sts/state%d.csv", year)
  }

  tryCatch({
    df <- read_csv(url, show_col_types = FALSE)
    df$year <- year
    return(df)
  }, error = function(e) {
    message(sprintf("Could not download data for %d: %s", year, e$message))
    return(NULL)
  })
}

# Download available years
cat("Downloading HUD Picture of Subsidized Households data...\n")
years_to_fetch <- 2010:2023

hud_data_list <- lapply(years_to_fetch, function(y) {
  cat(sprintf("  Fetching year %d...\n", y))
  Sys.sleep(1)  # Be nice to the server
  download_hud_picture(y)
})

# Combine non-null results
hud_data <- bind_rows(hud_data_list[!sapply(hud_data_list, is.null)])

if (nrow(hud_data) > 0) {
  write_csv(hud_data, "data/hud_picture_raw.csv")
  cat(sprintf("HUD Picture data saved: %d rows, %d years\n", nrow(hud_data), n_distinct(hud_data$year)))
} else {
  cat("Warning: Could not download HUD data. Will try alternate source.\n")
}

# =============================================================================
# 4. Alternative: Use Socrata API for HUD data
# =============================================================================

# HUD Open Data Portal has some datasets on Socrata
# Let's try the voucher by tract dataset for aggregation

hud_socrata_url <- "https://data.hud.gov/resource/y6mh-77wu.json"

# Function to fetch HUD data via Socrata
fetch_hud_socrata <- function(limit = 50000, offset = 0) {
  url <- sprintf("%s?$limit=%d&$offset=%d", hud_socrata_url, limit, offset)
  tryCatch({
    httr::GET(url) %>%
      httr::content(as = "text") %>%
      jsonlite::fromJSON() %>%
      as_tibble()
  }, error = function(e) {
    message(sprintf("Error fetching HUD Socrata data: %s", e$message))
    return(NULL)
  })
}

cat("Attempting to fetch HUD data via Socrata API...\n")
hud_socrata <- fetch_hud_socrata(limit = 100000)

if (!is.null(hud_socrata) && nrow(hud_socrata) > 0) {
  write_csv(hud_socrata, "data/hud_socrata_raw.csv")
  cat(sprintf("HUD Socrata data saved: %d rows\n", nrow(hud_socrata)))
}

# =============================================================================
# 5. Housing Market Controls - Zillow
# =============================================================================

# Zillow ZORI (Observed Rent Index) at state level
# Available at: https://www.zillow.com/research/data/

zillow_url <- "https://files.zillowstatic.com/research/public_csvs/zori/State_zori_sm_month.csv"

cat("Downloading Zillow rent data...\n")
tryCatch({
  zillow_data <- read_csv(zillow_url, show_col_types = FALSE)
  write_csv(zillow_data, "data/zillow_zori_raw.csv")
  cat(sprintf("Zillow data saved: %d states\n", nrow(zillow_data)))
}, error = function(e) {
  cat(sprintf("Could not download Zillow data: %s\n", e$message))
})

# =============================================================================
# 6. COVID-Era Controls
# =============================================================================

# Emergency Rental Assistance data from Treasury
# Will need to compile manually or find API

# For now, create placeholder structure
era_data <- tribble(
  ~state_abbr, ~era_total_disbursed, ~era_per_capita, ~source,
  "CA", 5200000000, 131.5, "Treasury ERA Dashboard",
  "NY", 2800000000, 143.7, "Treasury ERA Dashboard",
  "TX", 2100000000, 72.4, "Treasury ERA Dashboard"
  # ... to be completed with full state data
)

# Eviction moratorium data from Princeton Eviction Lab
eviction_lab_url <- "https://evictionlab.org/uploads/data/state_policies.csv"

cat("Downloading eviction moratorium data...\n")
tryCatch({
  eviction_data <- read_csv(eviction_lab_url, show_col_types = FALSE)
  write_csv(eviction_data, "data/eviction_moratoria_raw.csv")
  cat(sprintf("Eviction moratorium data saved: %d rows\n", nrow(eviction_data)))
}, error = function(e) {
  cat(sprintf("Could not download eviction data: %s\n", e$message))
})

# =============================================================================
# 7. Summary of Data Downloaded
# =============================================================================

cat("\n=== DATA ACQUISITION SUMMARY ===\n")
cat("1. SOI Laws: ", nrow(soi_laws), " states with treatment dates\n")
cat("2. HUD Picture: Check data/hud_picture_raw.csv\n")
cat("3. HUD Socrata: Check data/hud_socrata_raw.csv\n")
cat("4. Zillow ZORI: Check data/zillow_zori_raw.csv\n")
cat("5. Eviction Lab: Check data/eviction_moratoria_raw.csv\n")
cat("\nNext step: Run 02_clean_data.R to construct analysis sample\n")
