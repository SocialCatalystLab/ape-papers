# ============================================================================
# Paper 66: Salary Transparency Laws and Wage Outcomes
# 01_fetch_data.R - Fetch CPS MORG data from IPUMS
# ============================================================================

source("code/00_packages.R")

# ============================================================================
# Define IPUMS Extract
# ============================================================================

# For this analysis, we need CPS MORG (Merged Outgoing Rotation Groups)
# which contains the earnings supplement variables (EARNWEEK, HOURWAGE)

# IPUMS CPS variables needed:
cps_vars <- c(
  # Identifiers
  "YEAR", "MONTH", "SERIAL", "CPSID", "PERNUM", "CPSIDP",
  "STATEFIP", "COUNTY", "METRO",

  # Demographics
  "AGE", "SEX", "RACE", "HISPAN", "EDUC", "MARST",

  # Employment
  "EMPSTAT", "LABFORCE", "CLASSWKR", "OCC", "IND",
  "UHRSWORKT", "UHRSWORK1", "WKSTAT",

  # Earnings (MORG supplement)
  "EARNWEEK", "HOURWAGE", "PAIDHOUR", "EARNWT",

  # Weights
  "WTFINL", "EARNWT"
)

# ============================================================================
# Submit IPUMS Extract Request
# ============================================================================

# Check for API key
if (Sys.getenv("IPUMS_API_KEY") == "") {
  stop("IPUMS_API_KEY environment variable not set. ",
       "Set it with: Sys.setenv(IPUMS_API_KEY = 'your_key')")
}

set_ipums_api_key(Sys.getenv("IPUMS_API_KEY"))

# Define extract
extract_def <- define_extract_cps(
  description = "Paper 66: Salary Transparency DiD - CPS MORG 2016-2025",
  samples = paste0("cps", 2016:2025, "_01"),  # January samples
  variables = cps_vars
)

# Actually we need all months for MORG
# MORG = Merged Outgoing Rotation Groups (rotation groups 4 and 8)
# These have the earnings supplement

# Submit extract - this may take time
message("Submitting IPUMS CPS extract request...")
submitted_extract <- submit_extract(extract_def)
extract_id <- submitted_extract$number

message("Extract submitted. ID: ", extract_id)
message("Waiting for extract to be ready...")

# Wait for extract
wait_for_extract(submitted_extract)

# Download extract
message("Downloading extract...")
download_extract(submitted_extract, download_dir = "data")

# ============================================================================
# Alternative: Use Pre-downloaded MORG from NBER
# ============================================================================

# If IPUMS extract takes too long, we can use NBER MORG extracts
# https://www.nber.org/research/data/current-population-survey-cps-merged-outgoing-rotation-group-earnings-data

# Download MORG files from NBER
nber_morg_url <- "https://data.nber.org/morg/annual/"

years <- 2016:2024
morg_files <- paste0("morg", substr(years, 3, 4), ".dta")

for (i in seq_along(years)) {
  year <- years[i]
  file <- morg_files[i]
  dest <- file.path("data", file)

  if (!file.exists(dest)) {
    url <- paste0(nber_morg_url, file)
    message("Downloading ", year, " MORG: ", url)
    tryCatch({
      download.file(url, dest, mode = "wb")
    }, error = function(e) {
      message("Failed to download ", year, ": ", e$message)
    })
  } else {
    message("Already have: ", file)
  }
}

# ============================================================================
# Load and Combine MORG Data
# ============================================================================

message("Loading MORG data files...")

morg_list <- list()

for (i in seq_along(years)) {
  year <- years[i]
  file <- morg_files[i]
  path <- file.path("data", file)

  if (file.exists(path)) {
    message("Loading ", year, "...")
    df <- haven::read_dta(path)
    df$year <- year
    morg_list[[as.character(year)]] <- df
  }
}

# Combine all years
cps_raw <- bind_rows(morg_list)

message("Total observations: ", format(nrow(cps_raw), big.mark = ","))
message("Years covered: ", min(cps_raw$year), " - ", max(cps_raw$year))

# Save combined raw data
saveRDS(cps_raw, "data/cps_morg_raw.rds")
message("Saved: data/cps_morg_raw.rds")

# ============================================================================
# Data Dictionary
# ============================================================================

# Key MORG variables:
# earnwke  - Weekly earnings (not including overtime, tips, commissions)
# hourwage - Hourly wage (for hourly workers)
# earnhre  - Hourly earnings (alternative)
# paidhour - 1 if paid hourly
# hhid     - Household ID
# stfips   - State FIPS code
# age      - Age
# sex      - 1=Male, 2=Female
# race     - Race
# educ/grade92 - Education
# occ/docc03p - Occupation (various coding schemes)
# ind/dind03p - Industry (various coding schemes)
# uhourse  - Usual hours worked per week
# earnwt   - Earnings weight (for MORG supplement)

message("\n=== Data Fetch Complete ===")
