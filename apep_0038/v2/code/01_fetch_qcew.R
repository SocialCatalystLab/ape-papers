# =============================================================================
# 01_fetch_qcew.R
# Fetch Quarterly Census of Employment and Wages from BLS API
# Sports Betting Employment Effects - Revision of apep_0038
# =============================================================================

source("00_packages.R")

# -----------------------------------------------------------------------------
# BLS QCEW API Configuration
# -----------------------------------------------------------------------------

# QCEW data is available via the BLS Open Data API
# No API key required for basic access, but rate-limited
# We'll fetch state-level data for NAICS 7132 (Gambling Industries)

# NAICS codes of interest:
# 7132   - Gambling Industries (4-digit, main outcome)
# 713210 - Casinos (except Casino Hotels)
# 713290 - Other Gambling Industries (includes sportsbooks)
# Also fetch some placebos:
# 31-33  - Manufacturing
# 11     - Agriculture

naics_codes <- c("7132", "713210", "713290", "31-33", "11")
years <- 2010:2024
quarters <- 1:4

# -----------------------------------------------------------------------------
# Fetch Function
# -----------------------------------------------------------------------------

fetch_qcew_quarter <- function(year, quarter, naics, area_type = "S") {
  # area_type: S = state
  # ownership: 5 = private

  base_url <- "https://data.bls.gov/cew/data/api"
  endpoint <- sprintf("%s/%d/%d/area/%s.csv", base_url, year, quarter, naics)

  message(sprintf("Fetching QCEW: %d Q%d, NAICS %s", year, quarter, naics))


  tryCatch({
    # Download CSV
    temp_file <- tempfile(fileext = ".csv")
    download.file(endpoint, temp_file, quiet = TRUE, mode = "wb")

    # Read and filter to state-level, private ownership
    df <- read_csv(temp_file, show_col_types = FALSE) %>%
      filter(
        own_code == 5,  # Private ownership
        str_length(area_fips) == 2 | area_fips == "US000"  # State level
      ) %>%
      mutate(
        year = year,
        quarter = quarter,
        naics = naics
      ) %>%
      select(
        year, quarter, naics,
        area_fips, area_title,
        qtrly_estabs,         # Quarterly establishments
        month1_emplvl,        # Month 1 employment
        month2_emplvl,        # Month 2 employment
        month3_emplvl,        # Month 3 employment
        total_qtrly_wages,    # Total quarterly wages
        avg_wkly_wage         # Average weekly wage
      )

    unlink(temp_file)
    Sys.sleep(0.5)  # Rate limiting

    return(df)

  }, error = function(e) {
    message(sprintf("  Error: %s", e$message))
    return(NULL)
  })
}

# Alternative: Use pre-aggregated annual files (faster, more reliable)
fetch_qcew_annual_file <- function(year, naics) {
  # BLS provides annual aggregated CSVs
  base_url <- "https://data.bls.gov/cew/data/files"
  filename <- sprintf("%d_annual_by_industry/%d_annual_%s.csv.zip", year, year, naics)
  url <- paste0(base_url, "/", year, "/csv/", filename)

  message(sprintf("Fetching annual QCEW: %d, NAICS %s", year, naics))

  tryCatch({
    temp_zip <- tempfile(fileext = ".zip")
    temp_dir <- tempdir()

    download.file(url, temp_zip, quiet = TRUE, mode = "wb")
    unzip(temp_zip, exdir = temp_dir)

    csv_file <- list.files(temp_dir, pattern = "\\.csv$", full.names = TRUE)[1]
    df <- read_csv(csv_file, show_col_types = FALSE)

    unlink(temp_zip)
    unlink(csv_file)
    Sys.sleep(0.3)

    return(df)

  }, error = function(e) {
    message(sprintf("  Error: %s", e$message))
    return(NULL)
  })
}

# -----------------------------------------------------------------------------
# Fetch QCEW using BLS series API (quarterly data)
# -----------------------------------------------------------------------------

fetch_qcew_series <- function(state_fips, naics, start_year = 2010, end_year = 2024) {
  # BLS series ID format for QCEW:
  # ENU + area_fips + ownership + establishment/wage/employment code + industry

  # Example: ENU0100010713210 = Alabama, private, all industries
  # We need: ENU{state_fips}1051{naics code}

  # For quarterly employment (month 3):
  # Data type 3 = monthly employment level

  # This approach may not work directly - BLS QCEW doesn't use the series API
  # Instead, use the direct CSV downloads

  message("BLS QCEW uses direct CSV downloads, not series API")
  return(NULL)
}

# -----------------------------------------------------------------------------
# Main Data Fetch
# -----------------------------------------------------------------------------

message(paste(rep("=", 60), collapse = ""))
message("Fetching QCEW Quarterly Data")
message(paste(rep("=", 60), collapse = ""))

# For quarterly data, we'll use a simpler approach:
# Fetch the quarterly CSVs directly from BLS

# Actually, BLS provides quarterly data by area, not by industry
# The most reliable approach is to use the county-level CSZip files
# and aggregate to state level ourselves

# Simpler approach: Use the Quarterly data via API endpoint for each state/industry combo

# Let's construct the data from the available endpoint
fetch_qcew_by_state <- function(year, quarter) {
  # Fetch all states for a given year-quarter
  url <- sprintf(
    "https://data.bls.gov/cew/data/api/%d/%d/industry/7132.csv",
    year, quarter
  )

  message(sprintf("Fetching: %d Q%d", year, quarter))

  tryCatch({
    df <- read_csv(url, show_col_types = FALSE)
    df$year <- year
    df$quarter <- quarter
    return(df)
  }, error = function(e) {
    message(sprintf("  Error: %s", e$message))
    return(NULL)
  })
}

# Fetch gambling industry (NAICS 7132) quarterly data
qcew_raw <- map2_dfr(
  rep(years, each = 4),
  rep(quarters, length(years)),
  ~fetch_qcew_by_state(.x, .y)
)

# If API fetch fails, create synthetic data structure for testing
if (is.null(qcew_raw) || nrow(qcew_raw) == 0) {
  message("\nAPI fetch unsuccessful. Creating data structure from available sources.")
  message("Will need to use BLS bulk download files.")

  # Document the expected structure
  qcew_template <- tibble(
    year = integer(),
    quarter = integer(),
    area_fips = character(),
    state_abbr = character(),
    own_code = integer(),
    industry_code = character(),
    qtrly_estabs = integer(),
    month1_emplvl = integer(),
    month2_emplvl = integer(),
    month3_emplvl = integer(),
    total_qtrly_wages = numeric(),
    avg_wkly_wage = numeric()
  )

  message("\nTo proceed, download QCEW data manually from:")
  message("  https://www.bls.gov/cew/downloadable-data-files.htm")
  message("  Select 'CSVs By Industry' -> 'Annual Averages'")
  message("  Download for NAICS 7132 for years 2010-2024")
}

# -----------------------------------------------------------------------------
# Alternative: Use annual QCEW files (more reliable)
# -----------------------------------------------------------------------------

message("\n" , paste(rep("=", 60), collapse = ""))
message("Fetching Annual QCEW Data (as fallback)")
message(paste(rep("=", 60), collapse = ""))

fetch_qcew_annual_singlefile <- function(year) {
  # Download the single-file annual averages
  url <- sprintf(
    "https://data.bls.gov/cew/data/files/%d/csv/%d_annual_singlefile.zip",
    year, year
  )

  message(sprintf("Fetching annual: %d", year))

  tryCatch({
    temp_zip <- tempfile(fileext = ".zip")
    download.file(url, temp_zip, quiet = TRUE, mode = "wb", timeout = 120)

    # Unzip and read
    temp_dir <- tempdir()
    unzip(temp_zip, exdir = temp_dir)

    csv_files <- list.files(temp_dir, pattern = "annual_singlefile\\.csv$",
                            full.names = TRUE, recursive = TRUE)

    if (length(csv_files) == 0) {
      message("  No CSV found in zip")
      return(NULL)
    }

    # Read only gambling industry rows to save memory
    df <- fread(csv_files[1], select = c(
      "area_fips", "own_code", "industry_code",
      "annual_avg_estabs", "annual_avg_emplvl", "total_annual_wages", "avg_annual_pay"
    ))

    df <- df[industry_code %in% c("7132", "713210", "713290", "31-33", "11")]
    df <- df[own_code == 5]  # Private only
    df <- df[nchar(area_fips) == 5 | area_fips == "US000"]  # County or national

    df$year <- year

    unlink(temp_zip)

    return(as_tibble(df))

  }, error = function(e) {
    message(sprintf("  Error: %s", e$message))
    return(NULL)
  })
}

# Fetch annual data for all years
qcew_annual_list <- map(years, fetch_qcew_annual_singlefile)
qcew_annual <- bind_rows(qcew_annual_list)

if (nrow(qcew_annual) > 0) {
  # Aggregate to state level
  qcew_annual <- qcew_annual %>%
    mutate(state_fips = substr(area_fips, 1, 2)) %>%
    group_by(year, state_fips, industry_code) %>%
    summarise(
      total_estabs = sum(annual_avg_estabs, na.rm = TRUE),
      total_empl = sum(annual_avg_emplvl, na.rm = TRUE),
      total_wages = sum(total_annual_wages, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    left_join(state_fips %>% select(state_fips, state_abbr), by = "state_fips")

  message(sprintf("\nLoaded %d state-year-industry observations", nrow(qcew_annual)))
}

# -----------------------------------------------------------------------------
# Save Data
# -----------------------------------------------------------------------------

if (exists("qcew_annual") && nrow(qcew_annual) > 0) {
  write_csv(qcew_annual, "../data/qcew_annual.csv")
  message("Saved: ../data/qcew_annual.csv")
}

if (exists("qcew_raw") && !is.null(qcew_raw) && nrow(qcew_raw) > 0) {
  write_csv(qcew_raw, "../data/qcew_quarterly.csv")
  message("Saved: ../data/qcew_quarterly.csv")
}

message("\nData fetch complete.")
