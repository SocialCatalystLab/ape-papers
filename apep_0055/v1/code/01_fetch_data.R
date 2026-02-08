# ============================================================================
# Paper 70: Age 26 RDD on Birth Insurance Coverage
# 01_fetch_data.R - Download and extract natality data from NBER
# ============================================================================

source("00_packages.R")

# ============================================================================
# Download Natality Public Use Files from NBER
# ============================================================================
# Files are large (~800 MB each in Stata format)
# We'll download 2016-2023 (8 years, all using 2003 certificate revision)
# URL format: https://data.nber.org/nvss/natality/dta/YYYY/natalityYYYYus.dta

years <- 2016:2023

for (year in years) {
  # Construct URL - Stata format from NBER
  url <- sprintf("https://data.nber.org/nvss/natality/dta/%d/natality%dus.dta", year, year)
  dest_file <- file.path(data_dir, sprintf("natality%dus.dta", year))

  # Skip if already downloaded
  if (file.exists(dest_file)) {
    cat(sprintf("Year %d: Already exists, skipping.\n", year))
    next
  }

  cat(sprintf("Year %d: Downloading from %s...\n", year, url))
  cat("  (This may take several minutes - files are ~800 MB each)\n")

  # Download
  tryCatch({
    download.file(url, dest_file, mode = "wb", quiet = FALSE)
    cat(sprintf("Year %d: Done. Size: %.1f MB\n", year, file.size(dest_file)/1e6))
  }, error = function(e) {
    cat(sprintf("Year %d: ERROR - %s\n", year, e$message))
  })
}

cat("\nData download complete.\n")
cat("Files in data directory:\n")
print(list.files(data_dir, pattern = "natality.*\\.dta"))

# ============================================================================
# Note on Variables
# ============================================================================
# Key variables we need from Natality Public Use Files:
#
# MAGER     - Mother's single year of age (our running variable)
# PAY       - Source of payment for delivery
#             1 = Medicaid
#             2 = Private insurance
#             3 = Self-pay (uninsured)
#             4 = Indian Health Service
#             5 = CHAMPUS/TRICARE
#             6 = Other Government
#             8 = Other
#             9 = Unknown/not stated
# PAY_REC   - Payment recode (4 categories: Medicaid, Private, Self-pay, Other)
#
# MRACE6    - Mother's race (6 categories)
# MRACEHISP - Mother's race/Hispanic origin
# MEDUC     - Mother's education
# DMAR      - Mother's marital status (1=Married, 2=Unmarried)
# LBO_REC   - Live birth order (recode)
# PRECARE5  - Month prenatal care began (recode)
# DBWT      - Birth weight in grams
# COMBGEST  - Combined gestation (weeks)
# BFACIL    - Birthplace (hospital, freestanding, home, etc.)
# DOB_YY    - Year of birth
# DOB_MM    - Month of birth
#
# See NBER User Guide for full codebook:
# https://ftp.cdc.gov/pub/Health_Statistics/NCHS/Dataset_Documentation/DVS/natality/
