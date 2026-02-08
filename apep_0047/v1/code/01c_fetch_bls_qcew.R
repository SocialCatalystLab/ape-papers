# ============================================================================
# Paper 64: The Pence Effect
# 01c_fetch_bls_qcew.R - Fetch BLS QCEW data (no API key required)
# ============================================================================

source("code/00_packages.R")

library(httr)
library(tidyverse)

# ============================================================================
# BLS QCEW Data Download
# Source: https://data.bls.gov/cew/data/files/
# ============================================================================

cat("Fetching BLS QCEW data...\n")
cat("This provides quarterly employment by industry, state, and ownership\n\n")

# Function to download and extract QCEW annual data
fetch_qcew_year <- function(year) {
  url <- sprintf(
    "https://data.bls.gov/cew/data/files/%d/csv/%d_annual_by_industry.zip",
    year, year
  )

  cat(sprintf("Downloading %d data...\n", year))

  # Download zip file
  temp_zip <- tempfile(fileext = ".zip")
  temp_dir <- tempdir()

  tryCatch({
    download.file(url, temp_zip, mode = "wb", quiet = TRUE)
    unzip(temp_zip, exdir = temp_dir)

    # Find the CSV file
    csv_files <- list.files(temp_dir, pattern = sprintf("%d.*\\.csv$", year),
                            full.names = TRUE)

    if (length(csv_files) == 0) {
      warning(sprintf("No CSV found for %d", year))
      return(NULL)
    }

    # Read the data
    df <- read_csv(csv_files[1], col_types = cols(.default = "c"), show_col_types = FALSE)

    # Clean up
    unlink(temp_zip)

    return(df)
  }, error = function(e) {
    warning(sprintf("Failed to fetch %d: %s", year, e$message))
    return(NULL)
  })
}

# ============================================================================
# Download Data for 2010-2023
# ============================================================================

years <- 2010:2023
all_data <- list()

for (yr in years) {
  df <- fetch_qcew_year(yr)
  if (!is.null(df)) {
    df$year <- yr
    all_data[[as.character(yr)]] <- df
  }
  Sys.sleep(1)  # Rate limiting
}

# Combine all years
cat("\nCombining data across years...\n")
qcew_raw <- bind_rows(all_data)

# ============================================================================
# Process QCEW Data
# ============================================================================

cat("Processing QCEW data...\n")

# Filter to:
# - Private ownership (own_code = 5)
# - NAICS 2-digit industries
# - Annual totals (qtr = A)

qcew_clean <- qcew_raw %>%
  filter(
    own_code == "5",  # Private
    agglvl_code %in% c("54", "55", "56"),  # 2-digit NAICS national/state
    qtr == "A"  # Annual
  ) %>%
  # Keep relevant columns
  select(
    area_fips,
    industry_code,
    year,
    annual_avg_emplvl,
    annual_avg_wkly_wage,
    annual_avg_estabs,
    total_annual_wages
  ) %>%
  # Convert to numeric
  mutate(
    across(c(annual_avg_emplvl, annual_avg_wkly_wage, annual_avg_estabs, total_annual_wages),
           as.numeric),
    year = as.integer(year),
    # State FIPS (first 2 digits)
    state_fips = substr(area_fips, 1, 2),
    # Map industry codes to NAICS 2-digit
    naics = case_when(
      industry_code == "11" ~ "11",
      industry_code == "21" ~ "21",
      industry_code == "22" ~ "22",
      industry_code == "23" ~ "23",
      industry_code %in% c("31", "32", "33", "1013") ~ "31-33",
      industry_code == "42" ~ "42",
      industry_code %in% c("44", "45", "1024") ~ "44-45",
      industry_code %in% c("48", "49", "1025") ~ "48-49",
      industry_code == "51" ~ "51",
      industry_code == "52" ~ "52",
      industry_code == "53" ~ "53",
      industry_code == "54" ~ "54",
      industry_code == "55" ~ "55",
      industry_code == "56" ~ "56",
      industry_code == "61" ~ "61",
      industry_code == "62" ~ "62",
      industry_code == "71" ~ "71",
      industry_code == "72" ~ "72",
      industry_code == "81" ~ "81",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(naics), state_fips != "US") %>%
  # Aggregate to state-industry-year
  group_by(state_fips, naics, year) %>%
  summarise(
    employment = sum(annual_avg_emplvl, na.rm = TRUE),
    avg_weekly_wage = weighted.mean(annual_avg_wkly_wage, annual_avg_emplvl, na.rm = TRUE),
    establishments = sum(annual_avg_estabs, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  # Add treatment indicators
  mutate(
    post_metoo = as.integer(year >= 2018),
    high_harassment = as.integer(naics %in% c("72", "44-45", "62", "71", "56"))
  )

# ============================================================================
# Save Data
# ============================================================================

saveRDS(qcew_clean, "data/qcew_clean.rds")
write_csv(qcew_clean, "data/qcew_clean.csv")

cat("\n=== QCEW Summary ===\n")
cat(sprintf("Observations: %d\n", nrow(qcew_clean)))
cat(sprintf("States: %d\n", n_distinct(qcew_clean$state_fips)))
cat(sprintf("Industries: %d\n", n_distinct(qcew_clean$naics)))
cat(sprintf("Years: %d (%d-%d)\n", n_distinct(qcew_clean$year),
            min(qcew_clean$year), max(qcew_clean$year)))

cat("\nData saved to data/qcew_clean.rds\n")
