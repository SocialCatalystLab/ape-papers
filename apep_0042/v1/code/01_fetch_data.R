# =============================================================================
# 01_fetch_data.R
# Fetch CPS ASEC data from IPUMS for Auto-IRA analysis
# =============================================================================

source("00_packages.R")

# -----------------------------------------------------------------------------
# State Auto-IRA Mandate Treatment Data
# -----------------------------------------------------------------------------

# Treatment timing: Year program launched for largest employers (100+)
# This captures intent-to-treat at state level
treatment_data <- tibble(
  statefip = c(
    41,  # Oregon
    17,  # Illinois
    6,   # California
    9,   # Connecticut
    24,  # Maryland
    8,   # Colorado
    51,  # Virginia
    23,  # Maine
    10,  # Delaware
    34,  # New Jersey
    50   # Vermont
  ),
  state_abbr = c("OR", "IL", "CA", "CT", "MD", "CO", "VA", "ME", "DE", "NJ", "VT"),
  program_name = c(
    "OregonSaves", "Illinois Secure Choice", "CalSavers", "MyCTSavings",
    "MarylandSaves", "Colorado SecureSavings", "Virginia Saves",
    "Maine Retirement Savings", "Delaware Saves", "NJ Secure Choice",
    "Green Mountain Secure"
  ),
  first_treat_year = c(
    2017,  # Oregon - July 2017
    2018,  # Illinois - November 2018
    2019,  # California - July 2019
    2021,  # Connecticut - March 2021
    2022,  # Maryland - September 2022
    2023,  # Colorado - March 2023
    2023,  # Virginia - July 2023
    2024,  # Maine
    2024,  # Delaware
    2024,  # New Jersey
    2024   # Vermont
  )
)

cat("Treatment states:\n")
print(treatment_data)

# Save treatment data
write_csv(treatment_data, file.path(data_dir, "treatment_data.csv"))

# -----------------------------------------------------------------------------
# IPUMS CPS ASEC Extract Definition
# -----------------------------------------------------------------------------

cat("\n\nDefining IPUMS extract...\n")

# Define the extract
# Using CPS ASEC (March supplement) which has retirement coverage questions
extract_def <- define_extract_micro(
  collection = "cps",
  description = "CPS ASEC 2010-2024 for Auto-IRA analysis",
  samples = paste0("cps", 2010:2024, "_03s"),  # ASEC samples (March)
  variables = c(
    # Identifiers and weights
    "YEAR", "SERIAL", "PERNUM", "CPSID", "CPSIDP", "CPSIDV",
    "ASECWT", "ASECWTH",

    # Geography
    "STATEFIP", "METRO", "METAREA",

    # Demographics
    "AGE", "SEX", "RACE", "HISPAN", "EDUC", "MARST",

    # Employment
    "EMPSTAT", "LABFORCE", "CLASSWKR",
    "IND", "IND1990", "OCC", "OCC2010",
    "FIRMSIZE",

    # Income
    "INCTOT", "INCWAGE", "INCBUS", "INCSS",
    "HHINCOME", "POVERTY",

    # KEY OUTCOME: Retirement coverage
    "PENSION",

    # Health insurance (for balance)
    "HCOVANY", "HCOVPRIV", "HINSEMP"
  )
)

cat("Extract defined with", length(extract_def$variables), "variables\n")
cat("Years: 2010-2024 (15 years)\n")

# -----------------------------------------------------------------------------
# Submit Extract to IPUMS
# -----------------------------------------------------------------------------

cat("\nSubmitting extract to IPUMS...\n")

# Submit the extract
submitted <- submit_extract(extract_def)
cat("Extract submitted. Number:", submitted$number, "\n")

# Wait for extract to be ready (this can take several minutes)
cat("Waiting for extract to be ready...\n")
wait_for_extract(submitted, verbose = TRUE)

# -----------------------------------------------------------------------------
# Download Extract
# -----------------------------------------------------------------------------

cat("\nDownloading extract...\n")
download_extract(submitted, download_dir = data_dir)

# Find the downloaded files
files <- list.files(data_dir, pattern = "\\.dat\\.gz$|\\.xml$", full.names = TRUE)
cat("Downloaded files:\n")
print(files)

cat("\nData fetch complete!\n")
cat("Next: Run 02_clean_data.R\n")
