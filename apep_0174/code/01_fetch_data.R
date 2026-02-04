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
#
# *** OFFICIAL PROVENANCE CITATIONS ***
#
# Oregon (OregonSaves):
#   - Enabling legislation: Oregon SB 164, signed 2015
#   - Program launch: July 2017 for employers with 100+ employees
#   - Source: https://www.oregonsaves.com/
#   - Reference: Oregon Treasury press release (July 2017)
#
# Illinois (Secure Choice):
#   - Enabling legislation: Illinois Public Act 098-1150, signed 2015
#   - Program launch: November 2018 for employers with 500+ employees
#   - Large employer deadline (100+): 2018
#   - Source: https://www.ilsecurechoice.com/
#   - Reference: Illinois State Treasurer announcement (2018)
#
# California (CalSavers):
#   - Enabling legislation: California SB 1234, signed 2016
#   - Program launch: July 2019 for employers with 100+ employees
#   - Source: https://www.calsavers.com/
#   - Reference: California State Controller's Office (2019)
#
# Connecticut (MyCTSavings):
#   - Enabling legislation: Connecticut Public Act 16-29, signed 2016
#   - Program launch: March 2021 for employers with 100+ employees
#   - Source: https://myctSavings.com/
#   - Reference: Connecticut Comptroller announcement (2021)
#
# Maryland (MarylandSaves):
#   - Enabling legislation: Maryland HB 1378 (2016), amended by SB 370 (2022)
#   - Program launch: September 2022 for employers with 100+ employees
#   - Source: https://marylandsaves.org/
#   - Reference: Maryland Comptroller (2022)
#
# Colorado (SecureSavings):
#   - Enabling legislation: Colorado SB 200 (2020), HB 22-1205 (2022)
#   - Program launch: March 2023 for employers with 50+ employees
#   - Source: https://coloradosecuresavings.com/
#   - Reference: Colorado PERA/Treasury (2023)
#
# Virginia (Virginia Saves):
#   - Enabling legislation: Virginia SB 1439 (2021)
#   - Program launch: July 2023 for employers with 25+ employees
#   - Source: Virginia Department of Treasury
#   - Reference: Virginia State announcement (2023)
#
# Maine (Retirement Savings):
#   - Enabling legislation: Maine LD 1622 (2021)
#   - Program launch: 2024 (phased by employer size)
#   - Source: https://savewithmaine.com/
#   - Reference: Maine Treasury (2024)
#
# Delaware (Delaware Saves):
#   - Enabling legislation: Delaware HB 205 (2022)
#   - Program launch: 2024 for employers with 100+ employees
#   - Source: Delaware Office of State Treasurer
#   - Reference: Delaware Treasury announcement (2024)
#
# New Jersey (Secure Choice):
#   - Enabling legislation: New Jersey S-2820 (2019), P.L. 2019, c.265
#   - Program launch: 2024 for employers with 25+ employees
#   - Source: https://njsecurechoice.nj.gov/
#   - Reference: NJ State Treasury (2024)
#
# Vermont (Green Mountain Secure):
#   - Enabling legislation: Vermont Act 107 (2022)
#   - Program launch: 2024
#   - Source: Vermont State Treasurer
#   - Reference: Vermont Treasury (2024)
#
# -----------------------------------------------------------------------------

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
  # Treatment year = year when program launched for largest employer tier
  # This is the first year CPS could potentially capture exposure
  first_treat_year = c(
    2017,  # Oregon - July 2017 (100+ employers)
    2018,  # Illinois - November 2018 (500+ initially, using 2018)
    2019,  # California - July 2019 (100+ employers)
    2021,  # Connecticut - March 2021 (100+ employers)
    2022,  # Maryland - September 2022 (100+ employers)
    2023,  # Colorado - March 2023 (50+ employers)
    2023,  # Virginia - July 2023 (25+ employers)
    2024,  # Maine
    2024,  # Delaware
    2024,  # New Jersey
    2024   # Vermont
  ),
  # Statute citation for each program
  enabling_statute = c(
    "Oregon SB 164 (2015)",
    "Illinois P.A. 098-1150 (2015)",
    "California SB 1234 (2016)",
    "Connecticut P.A. 16-29 (2016)",
    "Maryland HB 1378 (2016), SB 370 (2022)",
    "Colorado SB 200 (2020), HB 22-1205 (2022)",
    "Virginia SB 1439 (2021)",
    "Maine LD 1622 (2021)",
    "Delaware HB 205 (2022)",
    "New Jersey S-2820 (2019), P.L. 2019 c.265",
    "Vermont Act 107 (2022)"
  )
)

cat("Treatment states with provenance:\n")
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
