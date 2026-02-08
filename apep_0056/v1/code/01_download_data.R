# =============================================================================
# Paper 72: Download Natality Data
# =============================================================================
# Downloads CDC/NCHS Natality Public Use Files from NBER
# Focus on years 2011-2022 (ACA era)
# =============================================================================

library(tidyverse)
library(data.table)

# Output directory
data_dir <- "output/paper_72/data"
dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)

# NBER natality data base URL
base_url <- "https://data.nber.org/natality"

# Years to download (ACA went into effect for dependent coverage Sept 2010)
years <- 2011:2022

# Function to download natality data for a given year
download_natality_year <- function(year) {
  cat(sprintf("Downloading %d natality data...\n", year))

  # NBER provides CSV versions
  # Format: natality/YEAR/natYYYY.csv.zip
  url <- sprintf("%s/%d/natl%d.csv.zip", base_url, year, year)
  destfile <- file.path(data_dir, sprintf("natl%d.csv.zip", year))

  if (file.exists(destfile)) {
    cat(sprintf("  File already exists: %s\n", destfile))
    return(TRUE)
  }

  tryCatch({
    download.file(url, destfile, mode = "wb", quiet = FALSE)
    cat(sprintf("  Downloaded: %s\n", destfile))
    return(TRUE)
  }, error = function(e) {
    cat(sprintf("  ERROR: %s\n", e$message))
    # Try alternative format
    url_alt <- sprintf("%s/%d/natl%d.csv.gz", base_url, year, year)
    destfile_alt <- file.path(data_dir, sprintf("natl%d.csv.gz", year))
    tryCatch({
      download.file(url_alt, destfile_alt, mode = "wb", quiet = FALSE)
      cat(sprintf("  Downloaded (alt): %s\n", destfile_alt))
      return(TRUE)
    }, error = function(e2) {
      cat(sprintf("  ERROR (alt): %s\n", e2$message))
      return(FALSE)
    })
  })
}

# Download all years
cat("Starting download of natality data files...\n")
cat("Note: These are large files (500MB-1GB each). Download may take time.\n\n")

results <- sapply(years, download_natality_year)

cat("\n=============================================================================\n")
cat("Download Summary:\n")
cat(sprintf("  Successful: %d/%d years\n", sum(results), length(years)))
cat("=============================================================================\n")

# List downloaded files
cat("\nDownloaded files:\n")
list.files(data_dir, pattern = "natl.*", full.names = FALSE)
