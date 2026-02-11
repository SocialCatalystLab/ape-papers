# =============================================================================
# 01_fetch_qcew.R
# Fetch Quarterly Census of Employment and Wages from BLS
# Sports Betting Employment Effects - Revision of apep_0038 (v3)
# =============================================================================

source("00_packages.R")

# -----------------------------------------------------------------------------
# BLS QCEW API Configuration
# -----------------------------------------------------------------------------

# BLS QCEW annual data API endpoint:
#   https://data.bls.gov/cew/data/api/{YEAR}/a/industry/{NAICS}.csv
# - Available from 2014 onward
# - NAICS 7132 and 11 work directly; "31-33" does not work as an API parameter
#
# For years 2010-2013 and NAICS 31-33, we use the bulk annual singlefile downloads:
#   https://data.bls.gov/cew/data/files/{YEAR}/csv/{YEAR}_annual_singlefile.zip

years_api <- 2014:2024       # Years with API access
years_bulk <- 2010:2013      # Years requiring bulk download
all_years <- 2010:2024

# NAICS codes fetched via API
api_naics <- c("7132", "11")

# NAICS codes requiring bulk download (multi-sector codes)
bulk_naics <- c("31-33")

# All industries we need
all_naics <- c("7132", "11", "31-33")

# -----------------------------------------------------------------------------
# Fetch Function: Annual API (for supported NAICS/years)
# -----------------------------------------------------------------------------

fetch_qcew_api <- function(year, naics) {
  url <- sprintf(
    "https://data.bls.gov/cew/data/api/%d/a/industry/%s.csv",
    year, naics
  )

  message(sprintf("  API: %d, NAICS %s ...", year, naics))

  tryCatch({
    temp_file <- tempfile(fileext = ".csv")
    download.file(url, temp_file, quiet = TRUE, mode = "wb", timeout = 120)

    df <- fread(temp_file, showProgress = FALSE)

    # Filter: private ownership (own_code == 5), state-level (5-char FIPS ending in 000)
    df <- df[own_code == 5]
    df <- df[nchar(as.character(area_fips)) == 5 & grepl("000$", area_fips)]
    df[, state_fips := substr(area_fips, 1, 2)]

    # Filter to valid US states
    valid_fips <- state_fips$state_fips
    df <- df[state_fips %in% valid_fips]

    df$year <- year
    df$industry_code <- naics

    unlink(temp_file)
    Sys.sleep(0.5)

    return(as_tibble(df))
  }, error = function(e) {
    message(sprintf("    Error: %s", substr(e$message, 1, 60)))
    return(NULL)
  })
}

# -----------------------------------------------------------------------------
# Fetch Function: Bulk Singlefile Download (for older years / multi-sector NAICS)
# -----------------------------------------------------------------------------

fetch_qcew_bulk <- function(year, target_naics = all_naics) {
  url <- sprintf(
    "https://data.bls.gov/cew/data/files/%d/csv/%d_annual_singlefile.zip",
    year, year
  )

  message(sprintf("  Bulk: %d (all industries) ...", year))

  tryCatch({
    temp_zip <- tempfile(fileext = ".zip")
    temp_dir <- tempdir()
    download.file(url, temp_zip, quiet = TRUE, mode = "wb", timeout = 300)
    unzip(temp_zip, exdir = temp_dir)

    csv_files <- list.files(temp_dir, pattern = "annual_singlefile\\.csv$",
                            full.names = TRUE, recursive = TRUE)

    if (length(csv_files) == 0) {
      message("    No CSV found in zip")
      return(NULL)
    }

    # Read only needed columns to save memory
    df <- fread(csv_files[1], select = c(
      "area_fips", "own_code", "industry_code",
      "annual_avg_estabs", "annual_avg_emplvl",
      "total_annual_wages", "annual_avg_wkly_wage"
    ), showProgress = FALSE)

    # Filter to target industries, private ownership, state-level
    df <- df[industry_code %in% target_naics]
    df <- df[own_code == 5]
    df <- df[nchar(as.character(area_fips)) == 5 & grepl("000$", area_fips)]
    df[, state_fips := substr(area_fips, 1, 2)]

    valid_fips <- state_fips$state_fips
    df <- df[state_fips %in% valid_fips]

    df$year <- year

    unlink(temp_zip)

    return(as_tibble(df))
  }, error = function(e) {
    message(sprintf("    Error: %s", substr(e$message, 1, 60)))
    return(NULL)
  })
}

# -----------------------------------------------------------------------------
# Main Data Fetch
# -----------------------------------------------------------------------------

message(paste(rep("=", 60), collapse = ""))
message("Fetching QCEW Data from BLS")
message(paste(rep("=", 60), collapse = ""))

all_data <- list()

# 1. Fetch via API for supported NAICS codes and years 2014+
message("\n--- Phase 1: API fetch (2014-2024, NAICS 7132 & 11) ---")
for (yr in years_api) {
  for (nc in api_naics) {
    result <- fetch_qcew_api(yr, nc)
    if (!is.null(result) && nrow(result) > 0) {
      # Standardize column names
      result <- result %>%
        select(
          year, industry_code, state_fips, area_fips,
          annual_avg_estabs, annual_avg_emplvl,
          total_annual_wages, annual_avg_wkly_wage
        )
      all_data[[length(all_data) + 1]] <- result
    }
  }
}

# 2. Bulk download for 2010-2013 (all NAICS) and 2014+ (NAICS 31-33 only)
message("\n--- Phase 2: Bulk download (2010-2013 all; 2014-2024 NAICS 31-33) ---")

# 2010-2013: fetch all target industries
for (yr in years_bulk) {
  result <- fetch_qcew_bulk(yr, all_naics)
  if (!is.null(result) && nrow(result) > 0) {
    result <- result %>%
      select(year, industry_code, state_fips, area_fips,
             annual_avg_estabs, annual_avg_emplvl,
             total_annual_wages, annual_avg_wkly_wage)
    all_data[[length(all_data) + 1]] <- result
  }
}

# 2014-2024: fetch only manufacturing (31-33) via bulk
for (yr in years_api) {
  result <- fetch_qcew_bulk(yr, "31-33")
  if (!is.null(result) && nrow(result) > 0) {
    result <- result %>%
      select(year, industry_code, state_fips, area_fips,
             annual_avg_estabs, annual_avg_emplvl,
             total_annual_wages, annual_avg_wkly_wage)
    all_data[[length(all_data) + 1]] <- result
  }
}

# Combine all data
qcew_raw <- bind_rows(all_data)

if (nrow(qcew_raw) == 0) {
  stop("QCEW data fetch failed completely. Cannot proceed.\n",
       "Check internet connection and BLS API availability.")
}

message(sprintf("\nFetched %d raw observations", nrow(qcew_raw)))

# Remove duplicates (in case API and bulk overlap)
qcew_raw <- qcew_raw %>%
  distinct(year, industry_code, state_fips, .keep_all = TRUE)

message(sprintf("After dedup: %d observations", nrow(qcew_raw)))

# -----------------------------------------------------------------------------
# Process and Clean
# -----------------------------------------------------------------------------

qcew_annual <- qcew_raw %>%
  rename(
    total_estabs = annual_avg_estabs,
    total_empl = annual_avg_emplvl,
    total_wages = total_annual_wages,
    avg_wkly_wage = annual_avg_wkly_wage
  ) %>%
  left_join(state_fips %>% select(state_fips, state_abbr), by = "state_fips") %>%
  filter(!is.na(state_abbr)) %>%
  select(year, industry_code, state_fips, state_abbr,
         total_estabs, total_empl, total_wages, avg_wkly_wage)

message(sprintf("Processed %d state-year-industry observations", nrow(qcew_annual)))

# Verify coverage
coverage <- qcew_annual %>%
  group_by(industry_code) %>%
  summarise(
    n_years = n_distinct(year),
    n_states = n_distinct(state_abbr),
    min_year = min(year),
    max_year = max(year),
    .groups = "drop"
  )

message("\nData coverage:")
print(coverage)

# -----------------------------------------------------------------------------
# Data Provenance: SHA256 Checksum
# -----------------------------------------------------------------------------

data_string <- paste(capture.output(write.csv(qcew_annual, row.names = FALSE)), collapse = "\n")
data_hash <- digest::digest(data_string, algo = "sha256")

provenance <- list(
  source = "BLS QCEW (API + bulk singlefile downloads)",
  api_endpoint = "https://data.bls.gov/cew/data/api/{YEAR}/a/industry/{NAICS}.csv",
  bulk_endpoint = "https://data.bls.gov/cew/data/files/{YEAR}/csv/{YEAR}_annual_singlefile.zip",
  fetch_date = as.character(Sys.time()),
  industries = all_naics,
  years = paste(min(all_years), max(all_years), sep = "-"),
  n_observations = nrow(qcew_annual),
  sha256 = data_hash
)

message(sprintf("\nData SHA256: %s", data_hash))

# -----------------------------------------------------------------------------
# Save Data
# -----------------------------------------------------------------------------

write_csv(qcew_annual, "../data/qcew_annual.csv")
message("Saved: ../data/qcew_annual.csv")

writeLines(
  jsonlite::toJSON(provenance, auto_unbox = TRUE, pretty = TRUE),
  "../data/qcew_provenance.json"
)
message("Saved: ../data/qcew_provenance.json")

# Quick summary
gambling_summary <- qcew_annual %>%
  filter(industry_code == "7132") %>%
  group_by(year) %>%
  summarise(
    n_states = n(),
    national_empl = sum(total_empl, na.rm = TRUE),
    mean_state_empl = mean(total_empl, na.rm = TRUE),
    mean_wkly_wage = weighted.mean(avg_wkly_wage, total_empl, na.rm = TRUE),
    .groups = "drop"
  )

message("\nGambling industry (NAICS 7132) summary:")
print(gambling_summary)

message("\nData fetch complete. All data sourced from BLS QCEW administrative records.")
