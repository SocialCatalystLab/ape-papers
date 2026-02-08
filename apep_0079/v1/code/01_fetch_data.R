# ==============================================================================
# 01_fetch_data.R
# Universal School Meals and Household Food Security
# Download CPS Food Security Supplement data from NBER/Census
# ==============================================================================

source("output/paper_106/code/00_packages.R")

# ------------------------------------------------------------------------------
# Treatment coding: Universal Free School Meals adoption
# ------------------------------------------------------------------------------

universal_meals <- tibble(
  state_fips = c(6, 23, 25, 32, 50, 8, 26, 27, 35),
  state_abbr = c("CA", "ME", "MA", "NV", "VT", "CO", "MI", "MN", "NM"),
  state_name = c("California", "Maine", "Massachusetts", "Nevada", "Vermont",
                 "Colorado", "Michigan", "Minnesota", "New Mexico"),
  first_treat_year = c(2022, 2022, 2022, 2022, 2022, 2023, 2023, 2023, 2023),
  treatment_cohort = c(2022, 2022, 2022, 2022, 2022, 2023, 2023, 2023, 2023)
)

# Save treatment data
write_csv(universal_meals, file.path(DATA_DIR, "treatment_timing.csv"))
cat("Treatment timing saved.\n")

# ------------------------------------------------------------------------------
# Download CPS-FSS data from NBER
# NBER hosts cleaned CPS supplement data with documentation
# ------------------------------------------------------------------------------

# NBER URLs for CPS Food Security Supplement (December supplement)
nber_urls <- list(
  "2015" = "http://data.nber.org/cps/cpsdec2015.zip",
  "2016" = "http://data.nber.org/cps/cpsdec2016.zip",
  "2017" = "http://data.nber.org/cps/cpsdec2017.zip",
  "2018" = "http://data.nber.org/cps_supp_1/raw/2018/supp/dec18pub.zip",
  "2019" = "http://data.nber.org/cps_supp_1/raw/2019/supp/dec19pub.zip",
  "2020" = "http://data.nber.org/cps_supp_1/raw/2020/supp/dec20pub.zip",
  "2021" = "http://data.nber.org/cps_supp_1/raw/2021/supp/dec21pub.zip"
)

# Census Bureau URLs for more recent years (2022-2024)
census_urls <- list(
  "2022" = "https://www2.census.gov/programs-surveys/cps/datasets/2022/supp/dec22pub.csv",
  "2023" = "https://www2.census.gov/programs-surveys/cps/datasets/2023/supp/dec23pub.csv",
  "2024" = "https://www2.census.gov/programs-surveys/cps/datasets/2024/supp/dec24pub.csv"
)

# Function to download and extract CPS-FSS data from NBER
download_nber_fss <- function(year) {

  url <- nber_urls[[as.character(year)]]
  if (is.null(url)) return(NULL)

  cat("Downloading year", year, "from NBER...\n")

  temp_file <- tempfile(fileext = ".zip")
  tryCatch({
    download.file(url, temp_file, mode = "wb", quiet = TRUE)

    # Unzip
    temp_dir <- tempdir()
    unzip(temp_file, exdir = temp_dir)

    # Find the data file (usually .dat or .csv)
    data_files <- list.files(temp_dir, pattern = "\\.(dat|csv)$",
                             full.names = TRUE, ignore.case = TRUE, recursive = TRUE)

    if (length(data_files) > 0) {
      # For .dat files, we need fixed-width format parsing
      # For now, save raw and process in clean step
      file.copy(data_files[1],
                file.path(DATA_DIR, sprintf("cps_fss_%d_raw.dat", year)))
      cat("  Saved raw data file\n")
      return(TRUE)
    }
    return(FALSE)
  }, error = function(e) {
    cat("  Download failed:", conditionMessage(e), "\n")
    return(FALSE)
  })
}

# Function to download CSV from Census
download_census_fss <- function(year) {

  url <- census_urls[[as.character(year)]]
  if (is.null(url)) return(NULL)

  cat("Downloading year", year, "from Census...\n")

  dest_file <- file.path(DATA_DIR, sprintf("cps_fss_%d_raw.csv", year))
  tryCatch({
    download.file(url, dest_file, mode = "wb", quiet = TRUE)
    cat("  Saved CSV file\n")
    return(TRUE)
  }, error = function(e) {
    cat("  Download failed:", conditionMessage(e), "\n")
    return(FALSE)
  })
}

# Download NBER years (2015-2021)
cat("\n=== Downloading NBER data (2015-2021) ===\n")
nber_results <- sapply(2015:2021, download_nber_fss)
names(nber_results) <- 2015:2021

# Download Census years (2022-2024)
cat("\n=== Downloading Census data (2022-2024) ===\n")
census_results <- sapply(2022:2024, download_census_fss)
names(census_results) <- 2022:2024

# Report results
cat("\n=== DOWNLOAD SUMMARY ===\n")
cat("NBER (2015-2021):\n")
print(data.frame(year = 2015:2021, success = nber_results))
cat("\nCensus (2022-2024):\n")
print(data.frame(year = 2022:2024, success = census_results))

# List downloaded files
cat("\n=== Downloaded files ===\n")
list.files(DATA_DIR, pattern = "cps_fss.*\\.(dat|csv)$")

cat("\n=== 01_fetch_data.R complete ===\n")
cat("Note: Raw .dat files require parsing with fixed-width format\n")
cat("See 02_clean_data.R for data processing\n")
