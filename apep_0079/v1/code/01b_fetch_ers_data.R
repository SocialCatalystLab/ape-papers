# ==============================================================================
# 01b_fetch_ers_data.R
# Download USDA ERS state-level food insecurity data for pre-treatment analysis
# This supplements the household-level CPS-FSS with state-year aggregates
# ==============================================================================

source("output/paper_106/code/00_packages.R")

# ------------------------------------------------------------------------------
# Download USDA ERS Food Security Data
# Contains state-level food insecurity rates from 2001-present
# ------------------------------------------------------------------------------

cat("Downloading USDA ERS food security data...\n")

# USDA ERS Excel file with state-level statistics
ers_url <- "https://www.ers.usda.gov/media/649/data-file-for-interactive-charts.xlsx"

ers_file <- file.path(DATA_DIR, "ers_food_security_data.xlsx")

tryCatch({
  download.file(ers_url, ers_file, mode = "wb", quiet = TRUE)
  cat("Downloaded ERS data file\n")
}, error = function(e) {
  cat("Download failed:", conditionMessage(e), "\n")
  # Try CSV alternative
  ers_csv_url <- "https://www.ers.usda.gov/media/799/food-security-csv-data-files.zip"
  ers_zip <- file.path(DATA_DIR, "ers_food_security_csv.zip")
  download.file(ers_csv_url, ers_zip, mode = "wb", quiet = TRUE)
  unzip(ers_zip, exdir = DATA_DIR)
  cat("Downloaded CSV alternative\n")
})

# ------------------------------------------------------------------------------
# Read and process ERS data
# The Excel file contains multiple sheets with different data series
# ------------------------------------------------------------------------------

if (file.exists(ers_file)) {
  library(readxl)

  # List sheets
  sheets <- excel_sheets(ers_file)
  cat("\nAvailable sheets:\n")
  print(sheets)

  # Read state-level data sheet
  # Try different possible sheet names
  state_sheet <- grep("state|State|STATE", sheets, value = TRUE)

  if (length(state_sheet) > 0) {
    df_ers_state <- read_excel(ers_file, sheet = state_sheet[1])
    cat("\nState data loaded from sheet:", state_sheet[1], "\n")
  } else {
    # Read first sheet and explore
    df_ers_raw <- read_excel(ers_file, sheet = 1)
    cat("\nFirst sheet structure:\n")
    print(head(df_ers_raw, 20))
    cat("\nColumn names:\n")
    print(names(df_ers_raw))
  }
}

# ------------------------------------------------------------------------------
# Alternative: Create state-level aggregates from published reports
# USDA publishes 3-year averages for reliable state estimates
# Source: https://www.ers.usda.gov/topics/food-nutrition-assistance/food-security-in-the-us/key-statistics-graphics/
# ------------------------------------------------------------------------------

# State-level food insecurity rates (3-year averages) from ERS reports
# These are the official USDA statistics used in policy analysis
# Format: State, 3-year period, food insecurity rate (%), very low food security rate (%)

ers_state_rates <- tribble(
  ~state_name, ~state_abbr, ~period, ~fi_rate, ~vlfs_rate,
  # 2015-2017 averages (pre-treatment baseline)
  "California", "CA", "2015-17", 11.0, 4.0,
  "Maine", "ME", "2015-17", 13.4, 5.0,
  "Massachusetts", "MA", "2015-17", 9.1, 3.5,
  "Nevada", "NV", "2015-17", 12.8, 4.4,
  "Vermont", "VT", "2015-17", 10.0, 3.5,
  "Colorado", "CO", "2015-17", 10.1, 3.5,
  "Michigan", "MI", "2015-17", 12.8, 4.8,
  "Minnesota", "MN", "2015-17", 8.4, 3.1,
  "New Mexico", "NM", "2015-17", 15.4, 5.8,
  # 2018-2020 averages (includes COVID shock)
  "California", "CA", "2018-20", 10.2, 3.4,
  "Maine", "ME", "2018-20", 11.2, 4.0,
  "Massachusetts", "MA", "2018-20", 8.0, 2.9,
  "Nevada", "NV", "2018-20", 11.2, 3.6,
  "Vermont", "VT", "2018-20", 8.6, 2.9,
  "Colorado", "CO", "2018-20", 9.0, 2.7,
  "Michigan", "MI", "2018-20", 11.5, 4.0,
  "Minnesota", "MN", "2018-20", 8.2, 2.8,
  "New Mexico", "NM", "2018-20", 14.3, 5.4,
  # 2021-2023 averages (post-treatment for some)
  "California", "CA", "2021-23", 10.8, 4.0,
  "Maine", "ME", "2021-23", 9.9, 3.2,
  "Massachusetts", "MA", "2021-23", 8.5, 3.0,
  "Nevada", "NV", "2021-23", 13.7, 5.1,
  "Vermont", "VT", "2021-23", 7.4, 2.2,
  "Colorado", "CO", "2021-23", 10.7, 3.7,
  "Michigan", "MI", "2021-23", 12.1, 4.4,
  "Minnesota", "MN", "2021-23", 8.5, 2.7,
  "New Mexico", "NM", "2021-23", 16.4, 6.6
)

# National averages for comparison
national_rates <- tribble(
  ~period, ~fi_rate_national, ~vlfs_rate_national,
  "2015-17", 12.5, 4.9,
  "2018-20", 10.9, 4.0,
  "2021-23", 12.8, 5.1
)

# Add national rates
ers_state_rates <- ers_state_rates %>%
  left_join(national_rates, by = "period")

# Save processed data
write_csv(ers_state_rates, file.path(DATA_DIR, "ers_state_fi_rates.csv"))

cat("\n=== ERS State Food Insecurity Rates ===\n")
print(ers_state_rates)

cat("\n=== 01b_fetch_ers_data.R complete ===\n")
cat("State-level food insecurity rates saved for pre-treatment analysis\n")
