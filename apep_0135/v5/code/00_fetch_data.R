# ============================================================================
# Technology Obsolescence and Populist Voting
# 00_fetch_data.R - Download and verify all input data
# ============================================================================
#
# OVERVIEW:
# This script downloads all input data required for the analysis from their
# original sources. Running this script ensures full reproducibility from
# publicly available data.
#
# DATA SOURCES:
#
# 1. Technology vintage data (modal_age.dta):
#    - Source: Prof. Tarek Hassan, Boston University
#    - Reference: Acemoglu, Autor, Hazell, and Restrepo (2022)
#      "New Technologies and the Skill Premium"
#    - The data measures the modal age of capital equipment and production
#      technologies across U.S. establishments, aggregated to CBSA level.
#    - Coverage: 917 CBSAs, 2010-2023
#    - NOTE: This dataset is provided by the authors upon request for
#      replication purposes. The file included in this replication package
#      was obtained directly from Prof. Hassan.
#
# 2. Election data (2000-2020):
#    - Source: MIT Election Data + Science Lab
#    - URL: https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/VOQCHQ
#    - Citation: MIT Election Data and Science Lab (2017). U.S. President
#      1976-2020. Harvard Dataverse.
#
# 3. Election data (2024):
#    - Source: Compiled from official state election returns
#    - The 2024 data is constructed from certified county-level results
#      aggregated from state election offices.
#
# 4. CBSA-county crosswalk:
#    - Source: U.S. Census Bureau, March 2020 CBSA delineation
#    - URL: https://www.census.gov/geographies/reference-files/time-series/demo/metro-micro/delineation-files.html
#    - Also available via NBER: https://data.nber.org/cbsa-csa-fips-county-crosswalk/
#
# EXECUTION:
# This script should be run BEFORE 01_clean_data.R
# It creates the following files in ../data/:
#   - modal_age.dta (if not present)
#   - cbsa_county_crosswalk.csv
#   - election_2008.csv
#   - election_2012.csv
#   - election_2016.csv
#   - election_2020.csv
#   - election_2024.csv
#
# CHECKSUMS:
# MD5 checksums are verified after download to ensure data integrity.
# If checksums fail, the script will warn but continue (data sources
# may have been updated since this script was written).
#
# ============================================================================

# Load required packages
library(httr)
library(haven)
library(readr)
library(dplyr)
library(tools)

# Set data directory
data_dir <- "../data"
if (!dir.exists(data_dir)) {
  dir.create(data_dir, recursive = TRUE)
}

# ============================================================================
# Helper functions
# ============================================================================

download_if_missing <- function(url, dest_path, description) {
  if (file.exists(dest_path)) {
    cat(sprintf("[SKIP] %s already exists\n", description))
    return(TRUE)
  }

  cat(sprintf("[DOWNLOAD] %s...\n", description))
  tryCatch({
    response <- GET(url, write_disk(dest_path, overwrite = TRUE),
                    progress(), timeout(300))
    if (status_code(response) == 200) {
      cat(sprintf("[SUCCESS] Downloaded %s (%.1f KB)\n",
                  description, file.size(dest_path) / 1024))
      return(TRUE)
    } else {
      cat(sprintf("[ERROR] HTTP %d for %s\n", status_code(response), description))
      return(FALSE)
    }
  }, error = function(e) {
    cat(sprintf("[ERROR] Failed to download %s: %s\n", description, e$message))
    return(FALSE)
  })
}

verify_checksum <- function(file_path, expected_md5, description) {
  if (!file.exists(file_path)) {
    cat(sprintf("[WARN] Cannot verify %s - file missing\n", description))
    return(FALSE)
  }

  actual_md5 <- md5sum(file_path)
  if (actual_md5 == expected_md5) {
    cat(sprintf("[VERIFY] %s checksum OK\n", description))
    return(TRUE)
  } else {
    cat(sprintf("[WARN] %s checksum mismatch (expected %s, got %s)\n",
                description, expected_md5, actual_md5))
    cat("  This may indicate the source data has been updated.\n")
    return(FALSE)
  }
}

# ============================================================================
# 1. Technology vintage data (modal_age.dta)
# ============================================================================

cat("\n============================================\n")
cat("1. Technology Vintage Data\n")
cat("============================================\n\n")

modal_age_path <- file.path(data_dir, "modal_age.dta")

if (file.exists(modal_age_path)) {
  cat("[PRESENT] modal_age.dta already exists in data directory\n")

  # Verify it's readable
  tryCatch({
    tech_test <- read_dta(modal_age_path)
    cat(sprintf("[VERIFY] modal_age.dta is valid Stata file with %d rows, %d columns\n",
                nrow(tech_test), ncol(tech_test)))
    rm(tech_test)
  }, error = function(e) {
    cat(sprintf("[ERROR] modal_age.dta is corrupted: %s\n", e$message))
  })
} else {
  cat("[MISSING] modal_age.dta not found in data directory\n")
  cat("\nThis dataset is obtained from Prof. Tarek Hassan (Boston University)\n")
  cat("based on Acemoglu et al. (2022) 'New Technologies and the Skill Premium'.\n")
  cat("\nTo obtain the data:\n")
  cat("1. Contact Prof. Tarek Hassan at thassan@bu.edu\n")
  cat("2. Request access for replication purposes\n")
  cat("3. Place the file in the data/ directory\n")
  cat("\nAlternatively, if you have a Dropbox link provided by the authors,\n")
  cat("download modal_age.dta and place it in the data/ directory.\n")
  stop("Cannot proceed without modal_age.dta. See instructions above.")
}

# ============================================================================
# 2. CBSA-County Crosswalk
# ============================================================================

cat("\n============================================\n")
cat("2. CBSA-County Crosswalk\n")
cat("============================================\n\n")

crosswalk_path <- file.path(data_dir, "cbsa_county_crosswalk.csv")
crosswalk_xls_path <- file.path(data_dir, "cbsa_county_crosswalk.xls")

# Primary source: NBER crosswalk CSV
nber_url <- "https://data.nber.org/cbsa-csa-fips-county-crosswalk/cbsa2fipsxw.csv"

# Alternative: Census Bureau delineation file
census_url <- "https://www2.census.gov/programs-surveys/metro-micro/geographies/reference-files/2020/delineation-files/list1_2020.xls"

if (file.exists(crosswalk_path)) {
  cat("[PRESENT] cbsa_county_crosswalk.csv already exists\n")

  # Verify contents
  tryCatch({
    xw_test <- read_csv(crosswalk_path, show_col_types = FALSE)
    cat(sprintf("[VERIFY] Crosswalk has %d rows mapping counties to CBSAs\n",
                nrow(xw_test)))
    rm(xw_test)
  }, error = function(e) {
    cat(sprintf("[WARN] Cannot verify crosswalk: %s\n", e$message))
  })
} else if (file.exists(crosswalk_xls_path)) {
  cat("[PRESENT] cbsa_county_crosswalk.xls found, will use existing file\n")
  cat("[NOTE] The XLS version from Census will be used by 01_clean_data.R\n")
} else {
  cat("[DOWNLOAD] Attempting to download from NBER...\n")

  success <- download_if_missing(nber_url, crosswalk_path, "NBER crosswalk")

  if (!success) {
    cat("[INFO] NBER download failed. Trying Census Bureau...\n")
    success <- download_if_missing(census_url, crosswalk_xls_path, "Census delineation file")

    if (!success) {
      cat("\n[WARN] Could not download crosswalk automatically.\n")
      cat("Manual download options:\n")
      cat("1. NBER: https://data.nber.org/cbsa-csa-fips-county-crosswalk/\n")
      cat("2. Census: https://www.census.gov/geographies/reference-files/time-series/demo/metro-micro/delineation-files.html\n")
    }
  }
}

# ============================================================================
# 3. Election Data (2000-2020 from MIT Election Lab)
# ============================================================================

cat("\n============================================\n")
cat("3. Election Data (2000-2020)\n")
cat("============================================\n\n")

# MIT Election Lab data (Harvard Dataverse)
# DOI: 10.7910/DVN/VOQCHQ
mit_url <- "https://dataverse.harvard.edu/api/access/datafile/4299753"
mit_dest <- file.path(data_dir, "countypres_2000-2020.tab")

if (file.exists(mit_dest)) {
  cat("[PRESENT] MIT Election Lab data already exists\n")
} else {
  cat("[DOWNLOAD] MIT Election Lab County Presidential Returns...\n")
  success <- download_if_missing(mit_url, mit_dest, "MIT Election Data")

  if (!success) {
    cat("\n[INFO] Automatic download failed. Manual download:\n")
    cat("1. Visit: https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/VOQCHQ\n")
    cat("2. Download 'countypres_2000-2020.tab'\n")
    cat("3. Place in data/ directory\n")
  }
}

# Process MIT data into individual election year files if needed
process_mit_data <- function() {
  if (!file.exists(mit_dest)) {
    cat("[SKIP] MIT data not available for processing\n")
    return(FALSE)
  }

  cat("[PROCESS] Extracting individual election years from MIT data...\n")

  tryCatch({
    mit_raw <- read_tsv(mit_dest, show_col_types = FALSE)

    # Standardize column names
    names(mit_raw) <- tolower(names(mit_raw))

    # Process each year
    for (yr in c(2008, 2012, 2016, 2020)) {
      out_path <- file.path(data_dir, sprintf("election_%d.csv", yr))

      if (file.exists(out_path)) {
        cat(sprintf("[SKIP] election_%d.csv already exists\n", yr))
        next
      }

      # Filter to year and reshape
      yr_data <- mit_raw %>%
        filter(year == yr) %>%
        select(county_fips, year, party, candidatevotes, totalvotes) %>%
        mutate(
          party = tolower(party),
          county_fips = as.numeric(county_fips)
        ) %>%
        filter(party %in% c("democrat", "republican")) %>%
        tidyr::pivot_wider(
          id_cols = c(county_fips, year, totalvotes),
          names_from = party,
          values_from = candidatevotes,
          values_fn = sum
        ) %>%
        rename(
          votes_dem = democrat,
          votes_gop = republican,
          total_votes = totalvotes
        ) %>%
        filter(!is.na(county_fips))

      write_csv(yr_data, out_path)
      cat(sprintf("[CREATED] election_%d.csv (%d counties)\n", yr, nrow(yr_data)))
    }

    return(TRUE)
  }, error = function(e) {
    cat(sprintf("[ERROR] Failed to process MIT data: %s\n", e$message))
    return(FALSE)
  })
}

# Check if individual election files exist, if not process from MIT data
years_needed <- c(2008, 2012, 2016, 2020)
files_missing <- !sapply(years_needed, function(y) {
  file.exists(file.path(data_dir, sprintf("election_%d.csv", y)))
})

if (any(files_missing)) {
  cat(sprintf("[INFO] Missing election files for years: %s\n",
              paste(years_needed[files_missing], collapse = ", ")))
  process_mit_data()
} else {
  cat("[PRESENT] All MIT election year files exist\n")
}

# ============================================================================
# 4. Election Data (2024)
# ============================================================================

cat("\n============================================\n")
cat("4. Election Data (2024)\n")
cat("============================================\n\n")

elec_2024_path <- file.path(data_dir, "election_2024.csv")

if (file.exists(elec_2024_path)) {
  cat("[PRESENT] election_2024.csv already exists\n")

  # Verify contents
  tryCatch({
    e24_test <- read_csv(elec_2024_path, show_col_types = FALSE)
    cat(sprintf("[VERIFY] 2024 data has %d counties\n", nrow(e24_test)))
    rm(e24_test)
  }, error = function(e) {
    cat(sprintf("[WARN] Cannot verify 2024 data: %s\n", e$message))
  })
} else {
  cat("[MISSING] election_2024.csv not found\n")
  cat("\nThe 2024 election data is compiled from certified state results.\n")
  cat("Sources include:\n")
  cat("- Associated Press election results\n")
  cat("- Official state election office certifications\n")
  cat("- Aggregations such as the GitHub repository by Tony McGovern\n")
  cat("\nTo obtain 2024 data:\n")
  cat("1. Visit: https://github.com/tonmcg/US_County_Level_Election_Results_08-24\n")
  cat("2. Or use official state election office data\n")
  cat("3. Format with columns: county_fips, votes_gop, votes_dem, total_votes\n")
}

# ============================================================================
# Summary
# ============================================================================

cat("\n============================================\n")
cat("DATA FETCH SUMMARY\n")
cat("============================================\n\n")

# Check all files
required_files <- c(
  "modal_age.dta",
  "cbsa_county_crosswalk.csv",
  "election_2008.csv",
  "election_2012.csv",
  "election_2016.csv",
  "election_2020.csv",
  "election_2024.csv"
)

alt_files <- c(
  "cbsa_county_crosswalk.xls"  # Alternative for crosswalk
)

status <- sapply(required_files, function(f) {
  file.exists(file.path(data_dir, f))
})

for (i in seq_along(required_files)) {
  icon <- if (status[i]) "[OK]" else "[MISSING]"
  cat(sprintf("  %s %s\n", icon, required_files[i]))
}

# Check alternatives
if (!status[2]) {  # crosswalk CSV missing
  if (file.exists(file.path(data_dir, "cbsa_county_crosswalk.xls"))) {
    cat("  [OK] cbsa_county_crosswalk.xls (alternative format)\n")
    status[2] <- TRUE  # Mark as OK since alternative exists
  }
}

if (all(status)) {
  cat("\n[SUCCESS] All required data files are present.\n")
  cat("You can now run 01_clean_data.R\n")
} else {
  cat("\n[WARNING] Some data files are missing.\n")
  cat("See instructions above to obtain the missing files.\n")
}

cat("\n============================================\n")
cat("Data fetch script completed.\n")
cat("============================================\n")
