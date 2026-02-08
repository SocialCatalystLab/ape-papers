# ==============================================================================
# 01_fetch_data.R - Fetch CPS ASEC data from IPUMS
# Paper 60: State Auto-IRA Mandates and Retirement Savings
# ==============================================================================

source("code/00_packages.R")

# ==============================================================================
# Define and Submit IPUMS CPS ASEC Extract
# ==============================================================================

# Note: API key should be set via set_ipums_api_key() or IPUMS_API_KEY env var
# Get key from: https://account.ipums.org/api_keys

cat("Defining IPUMS CPS ASEC extract...\n")

# Define extract: CPS ASEC 2012-2024
# Key variables for retirement plan analysis
extract <- define_extract_cps(
  description = "CPS ASEC 2012-2024 for auto-IRA analysis",
  samples = paste0("cps", 2012:2024, "_03s"),  # March ASEC supplements
  variables = c(
    # Identifiers
    "YEAR", "SERIAL", "PERNUM", "CPSID", "CPSIDP",
    "STATEFIP", "COUNTY", "METRO", "METAREA",

    # Demographics
    "AGE", "SEX", "RACE", "HISPAN", "MARST", "EDUC",

    # Labor force
    "EMPSTAT", "LABFORCE", "CLASSWKR", "CLASSWLY",
    "OCC", "OCC2010", "IND", "IND1990",
    "WKSWORK1", "WKSWORK2", "UHRSWORKLY", "FULLPART",

    # Firm size (key for treatment intensity)
    "FIRMSIZE",

    # Income
    "INCTOT", "INCWAGE", "INCBUS", "INCSS", "INCRETIR",

    # RETIREMENT - Core outcome variable
    "PENSION",      # Pension plan included with job (and if respondent is included)

    # Weights
    "ASECWT"
  )
)

cat("Submitting extract to IPUMS...\n")
submitted <- submit_extract(extract)

cat("Waiting for extract to be ready...\n")
cat("This may take 5-30 minutes for large extracts.\n")

# Wait and poll
wait_for_extract(submitted)

cat("Downloading extract...\n")
download_extract(submitted, download_dir = "data/")

cat("Extract downloaded successfully.\n")

# ==============================================================================
# Read Downloaded Data
# ==============================================================================

# Find the downloaded files
ddi_file <- list.files("data/", pattern = "\\.xml$", full.names = TRUE)[1]

if (is.na(ddi_file)) {
  stop("DDI file not found. Check download directory.")
}

cat("Reading data from:", ddi_file, "\n")
ddi <- read_ipums_ddi(ddi_file)
cps_raw <- read_ipums_micro(ddi)

cat("Data loaded:", nrow(cps_raw), "observations\n")
cat("Years covered:", paste(sort(unique(cps_raw$YEAR)), collapse = ", "), "\n")

# Save raw data
saveRDS(cps_raw, "data/cps_asec_raw.rds")
cat("Raw data saved to data/cps_asec_raw.rds\n")

# ==============================================================================
# Create State Auto-IRA Policy Dates
# ==============================================================================

# Hand-collected from Georgetown CRI and state program websites
auto_ira_dates <- tribble(
  ~statefip, ~state_name, ~program_name, ~launch_date, ~launch_year, ~launch_month,
  41, "Oregon", "OregonSaves", "2017-10-01", 2017, 10,
  17, "Illinois", "Secure Choice", "2018-10-01", 2018, 10,
  6, "California", "CalSavers", "2019-07-01", 2019, 7,
  9, "Connecticut", "MyCTSavings", "2022-04-01", 2022, 4,
  24, "Maryland", "Maryland$aves", "2022-09-15", 2022, 9,
  8, "Colorado", "Secure Savings", "2023-01-18", 2023, 1,
  51, "Virginia", "RetirePath", "2023-06-20", 2023, 6,
  23, "Maine", "MERSavers", "2024-01-27", 2024, 1,
  34, "New Jersey", "RetireReady NJ", "2024-06-30", 2024, 6,
  10, "Delaware", "Delaware EARNS", "2024-07-01", 2024, 7
  # Vermont (Dec 2024), Nevada, Minnesota (2025-2026) - after our data period
)

# For DiD, we code treatment year as the year program launched
# For 2024 launches, they're effectively post-treatment only for 2024 data
auto_ira_dates <- auto_ira_dates %>%
  mutate(
    # First full year of treatment
    first_treat_year = ifelse(launch_month <= 6, launch_year, launch_year + 1)
  )

saveRDS(auto_ira_dates, "data/auto_ira_policy_dates.rds")
cat("Policy dates saved to data/auto_ira_policy_dates.rds\n")

# Print summary
cat("\n=== Auto-IRA Policy Summary ===\n")
print(auto_ira_dates %>% select(state_name, program_name, launch_date, first_treat_year))

cat("\nData fetch complete.\n")
