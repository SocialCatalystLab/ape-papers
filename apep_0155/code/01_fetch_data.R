# ============================================================================
# 01_fetch_data.R
# Salary Transparency Laws and the Gender Wage Gap
# Data Acquisition from IPUMS CPS ASEC
# ============================================================================

source("code/00_packages.R")

# ============================================================================
# IPUMS CPS ASEC Extract Definition
# ============================================================================

# We need CPS ASEC data from 2015-2024 (income years 2014-2023)
# This gives us 6+ pre-treatment years for early adopters (Colorado 2021)

cat("Defining IPUMS CPS ASEC extract...\n")

# Define the extract
extract <- define_extract_cps(
  description = "Salary Transparency Laws - CPS ASEC 2015-2024",
  samples = paste0("cps", 2015:2024, "_03s"),  # March ASEC supplements
  variables = c(
    # Identifiers
    "YEAR",           # Survey year
    "SERIAL",         # Household serial number
    "PERNUM",         # Person number within household

    # Geographic
    "STATEFIP",       # State FIPS code
    "METRO",          # Metropolitan status
    "CBSASZ",         # CBSA size

    # Demographics
    "AGE",            # Age
    "SEX",            # Sex
    "RACE",           # Race
    "HISPAN",         # Hispanic origin
    "EDUC",           # Education
    "MARST",          # Marital status

    # Labor force
    "EMPSTAT",        # Employment status
    "CLASSWKR",       # Class of worker
    "OCC",            # Occupation (detailed)
    "OCC2010",        # Occupation (2010 basis)
    "IND",            # Industry (detailed)
    "IND1990",        # Industry (1990 basis)

    # Hours and weeks
    "UHRSWORKLY",     # Usual hours worked per week last year
    "WKSWORK1",       # Weeks worked last year (continuous)
    "WKSWORK2",       # Weeks worked last year (intervals)
    "FULLPART",       # Full/part-time status

    # Income
    "INCWAGE",        # Wage and salary income
    "INCTOT",         # Total personal income

    # Weights
    "ASECWT"          # ASEC person weight
  )
)

# ============================================================================
# Submit Extract to IPUMS
# ============================================================================

cat("Checking IPUMS API key...\n")
api_key <- Sys.getenv("IPUMS_API_KEY")
if (api_key == "") {
  stop("IPUMS_API_KEY environment variable not set.
        Get your key from https://account.ipums.org/api_keys")
}

# Check if we already have the data
data_files <- list.files("data", pattern = "cps_asec.*\\.rds$", full.names = TRUE)

if (length(data_files) > 0) {
  cat("Found existing CPS ASEC data file:", data_files[1], "\n")
  cat("Skipping IPUMS extract. Delete the file to re-download.\n")
} else {
  cat("Submitting extract to IPUMS...\n")

  # Submit the extract
  submitted <- submit_extract(extract)

  cat("Extract submitted. Extract number:", submitted$number, "\n")
  cat("Waiting for extract to be ready (this may take 10-30 minutes)...\n")

  # Wait for extract to complete
  ready <- wait_for_extract(submitted, verbose = TRUE)

  cat("Extract ready. Downloading...\n")

  # Download the extract
  download_extract(ready, download_dir = "data/")

  cat("Download complete.\n")
}

# ============================================================================
# Read the Downloaded Data
# ============================================================================

cat("Reading IPUMS data...\n")

# Find the DDI file
ddi_files <- list.files("data", pattern = "\\.xml$", full.names = TRUE)
if (length(ddi_files) == 0) {
  stop("No DDI file found in data/ directory. Check IPUMS download.")
}

# Read the data
ddi <- read_ipums_ddi(ddi_files[1])
df_raw <- read_ipums_micro(ddi)

cat("Read", nrow(df_raw), "observations.\n")

# ============================================================================
# Initial Processing
# ============================================================================

cat("Processing data...\n")

# Convert to data.table for speed
setDT(df_raw)

# Create income year variable
# CPS ASEC asks about income in the PREVIOUS calendar year
# So survey year 2024 = income year 2023
df_raw[, income_year := YEAR - 1]

# Quick summary
cat("\nSurvey years in data:", paste(sort(unique(df_raw$YEAR)), collapse = ", "), "\n")
cat("Income years in data:", paste(sort(unique(df_raw$income_year)), collapse = ", "), "\n")
cat("States in data:", length(unique(df_raw$STATEFIP)), "\n")

# ============================================================================
# Save Raw Data
# ============================================================================

saveRDS(df_raw, "data/cps_asec_raw.rds")
cat("\nRaw data saved to data/cps_asec_raw.rds\n")

# ============================================================================
# Fetch State-Level Controls
# ============================================================================

cat("\nFetching state-level control variables...\n")

# ---- State Minimum Wages ----
# Source: DOL / UC Berkeley Labor Center
# We'll use a simplified approach with known minimum wages

state_min_wage <- tibble(
  statefip = 1:56,
  state_abbr = c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "FL",
                 "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME",
                 "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH",
                 "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI",
                 "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI",
                 "WY", NA, NA, NA, NA, NA)
) %>%
  filter(!is.na(state_abbr))

# For now, we'll construct minimum wage data in the cleaning script
# using known values for the analysis period

# ---- State Unemployment Rates ----
# Would fetch from BLS LAUS API
# For now, we'll use state-year fixed effects which absorb this

cat("State control data prepared.\n")

cat("\n==== Data Fetch Complete ====\n")
cat("Next step: Run 02_clean_data.R\n")
