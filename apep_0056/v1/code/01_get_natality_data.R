# =============================================================================
# Paper 72: Get Natality Data from CDC WONDER
# =============================================================================
# Uses CDC WONDER API to get birth counts by mother's age and payment source
# =============================================================================

# Install required packages if needed
if (!require("httr")) install.packages("httr")
if (!require("xml2")) install.packages("xml2")
if (!require("tidyverse")) install.packages("tidyverse")

library(httr)
library(xml2)
library(tidyverse)

# Output directory
data_dir <- "output/paper_72/data"
dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)

# CDC WONDER API endpoint
wonder_url <- "https://wonder.cdc.gov/controller/datarequest/D149"

# Note: CDC WONDER API requires specific XML query format
# The expanded natality database (D149) has payment source data

# Function to build XML query for CDC WONDER
build_wonder_query <- function() {
  # This is a complex XML query - we'll use the simpler approach of downloading

  # pre-aggregated data from the WONDER web interface instead

  query <- '<?xml version="1.0" encoding="utf-8"?>
<request-parameters>
  <accept_datause_restrictions>true</accept_datause_restrictions>
  <parameter>
    <name>B_1</name>
    <value>D149.V7</value>
  </parameter>
  <parameter>
    <name>B_2</name>
    <value>D149.V23</value>
  </parameter>
  <parameter>
    <name>B_3</name>
    <value>*None*</value>
  </parameter>
  <parameter>
    <name>B_4</name>
    <value>*None*</value>
  </parameter>
  <parameter>
    <name>B_5</name>
    <value>*None*</value>
  </parameter>
  <parameter>
    <name>M_1</name>
    <value>D149.M1</value>
  </parameter>
  <parameter>
    <name>V_D149.V7</name>
    <value>*All*</value>
  </parameter>
  <parameter>
    <name>V_D149.V23</name>
    <value>*All*</value>
  </parameter>
  <parameter>
    <name>O_title</name>
    <value>Births by Mother Age and Payment Source</value>
  </parameter>
  <parameter>
    <name>O_location</name>
    <value>D149.V1</value>
  </parameter>
</request-parameters>'

  return(query)
}

# Since CDC WONDER API is complex, we'll manually create the data we need
# based on published statistics and NBER microdata samples

cat("=============================================================================\n")
cat("Note: CDC WONDER API has limitations for this analysis.\n")
cat("We will proceed with two approaches:\n")
cat("1. Download a sample year of NBER microdata for method development\n")
cat("2. Use CDC WONDER web interface exports for final analysis\n")
cat("=============================================================================\n\n")

# Approach 1: Download 2019 natality data (single year sample for development)
# 2019 is pre-pandemic, good ACA coverage, has payment source data

cat("Downloading 2019 natality data sample from NBER...\n")

# The NBER provides various formats - try the Stata data file (smaller)
# Or use the direct download CSV

# Download one year for initial analysis
year <- 2019
url <- sprintf("https://data.nber.org/natality/%d/natl%d.csv.gz", year, year)
destfile <- file.path(data_dir, sprintf("natl%d.csv.gz", year))

if (!file.exists(destfile)) {
  cat(sprintf("Attempting download from: %s\n", url))
  tryCatch({
    download.file(url, destfile, mode = "wb", quiet = FALSE)
    cat("Download successful!\n")
  }, error = function(e) {
    cat(sprintf("Download failed: %s\n", e$message))
    cat("Trying alternative source...\n")

    # Try zip format
    url_zip <- sprintf("https://data.nber.org/natality/%d/natl%d.csv.zip", year, year)
    destfile_zip <- file.path(data_dir, sprintf("natl%d.csv.zip", year))
    tryCatch({
      download.file(url_zip, destfile_zip, mode = "wb", quiet = FALSE)
      cat("Download successful (zip format)!\n")
    }, error = function(e2) {
      cat(sprintf("Alternative download also failed: %s\n", e2$message))
    })
  })
} else {
  cat("File already exists.\n")
}

# Check what files we have
cat("\nFiles in data directory:\n")
print(list.files(data_dir, full.names = FALSE))

cat("\n=============================================================================\n")
cat("Next steps:\n")
cat("1. If download succeeded, run 02_process_data.R to extract relevant variables\n")
cat("2. If download failed, manually download from:\n")
cat("   https://www.cdc.gov/nchs/data_access/vitalstatsonline.htm\n")
cat("=============================================================================\n")
