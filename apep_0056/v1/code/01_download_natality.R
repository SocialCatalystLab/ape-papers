# =============================================================================
# Paper 72: Download Natality Data from NBER
# =============================================================================
# Downloads multiple years of natality data for RDD analysis
# =============================================================================

library(tidyverse)

# Output directory
data_dir <- "output/paper_72/data"
dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)

# NBER natality CSV base URL (new location as of 2024)
base_url <- "https://data.nber.org/nvss/natality/csv"

# Years to download: 2016-2022 (good ACA coverage, payment source available)
# Note: Files are large (1-2GB each)
years <- c(2016, 2017, 2018, 2019, 2020, 2021, 2022)

# Function to download a single year
download_year <- function(year) {
  url <- sprintf("%s/%d/natality%dus.csv", base_url, year, year)
  destfile <- file.path(data_dir, sprintf("natality%dus.csv", year))

  if (file.exists(destfile)) {
    cat(sprintf("Already exists: %s\n", destfile))
    return(TRUE)
  }

  cat(sprintf("Downloading %d data from: %s\n", year, url))
  cat("  (This is a large file, ~1.5GB, please wait...)\n")

  tryCatch({
    download.file(url, destfile, mode = "wb", quiet = FALSE)
    cat(sprintf("  SUCCESS: %s\n", destfile))
    return(TRUE)
  }, error = function(e) {
    cat(sprintf("  FAILED: %s\n", e$message))
    return(FALSE)
  })
}

# Download each year (or use a subset to save time)
cat("=============================================================================\n")
cat("Downloading Natality Public Use Files\n")
cat("Source: NBER (https://data.nber.org/nvss/natality)\n")
cat("=============================================================================\n\n")

# For initial development, just download 2019
# Uncomment the full list for complete analysis
years_to_download <- c(2019)  # Start with just 2019 for development
# years_to_download <- years  # Full set

results <- sapply(years_to_download, download_year)

cat("\n=============================================================================\n")
cat(sprintf("Downloaded: %d/%d files\n", sum(results), length(years_to_download)))
cat("=============================================================================\n")

# List files
cat("\nFiles in data directory:\n")
list.files(data_dir, pattern = "natality.*\\.csv$")
