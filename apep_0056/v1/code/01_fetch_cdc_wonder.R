# ==============================================================================
# Paper 72: PDMP Mandatory Query Effects on Opioid Prescribing
# 01_fetch_cdc_wonder.R - Download CDC WONDER overdose mortality data
# ==============================================================================

# Load packages
library(tidyverse)
library(httr)

# Create data directory
dir.create("../data_pdmp", showWarnings = FALSE)

# ------------------------------------------------------------------------------
# CDC WONDER Mortality Data
# We'll use pre-aggregated state-year data from CDC WONDER
# ICD-10 codes for opioid overdose deaths: T40.0-T40.6
# ------------------------------------------------------------------------------

cat("=== CDC WONDER Opioid Mortality Data ===\n\n")

# CDC WONDER requires form submission, but there are publicly available
# aggregated datasets. Let's use the CDC's publicly available data.

# Alternative: Use CDC's precomputed drug overdose data at state level
# Available from: https://www.cdc.gov/nchs/pressroom/sosmap/drug_poisoning_mortality/drug_poisoning.htm

# The CDC provides state-level age-adjusted overdose death rates
# Let's fetch these directly

cat("Attempting to fetch CDC precomputed overdose data...\n")

# CDC provides CSV files for state-level drug overdose mortality
# URL pattern for recent data
cdc_url <- "https://data.cdc.gov/api/views/p56q-dnux/rows.csv?accessType=DOWNLOAD"

# Download
response <- tryCatch({
  GET(cdc_url, timeout(120))
}, error = function(e) {
  message("Error: ", e$message)
  NULL
})

if (!is.null(response) && status_code(response) == 200) {
  # Save raw data
  writeBin(content(response, "raw"), "../data_pdmp/cdc_overdose_raw.csv")
  cat("Downloaded CDC overdose data\n")

  # Read and process
  cdc_data <- read_csv("../data_pdmp/cdc_overdose_raw.csv", show_col_types = FALSE)
  cat(sprintf("Loaded %d rows\n", nrow(cdc_data)))
  print(head(cdc_data))
  print(names(cdc_data))

  # Save processed version
  saveRDS(cdc_data, "../data_pdmp/cdc_overdose.rds")
} else {
  cat("Failed to download from primary CDC endpoint\n")
  cat(sprintf("Status: %s\n", if(!is.null(response)) status_code(response) else "No response"))
}

# ------------------------------------------------------------------------------
# Alternative: CDC VSRR Provisional Drug Overdose Death Counts
# More recent data (2015-present)
# ------------------------------------------------------------------------------

cat("\nAttempting CDC VSRR endpoint...\n")

vsrr_url <- "https://data.cdc.gov/api/views/xkb8-kh2a/rows.csv?accessType=DOWNLOAD"

response2 <- tryCatch({
  GET(vsrr_url, timeout(120))
}, error = function(e) {
  message("Error: ", e$message)
  NULL
})

if (!is.null(response2) && status_code(response2) == 200) {
  writeBin(content(response2, "raw"), "../data_pdmp/cdc_vsrr_overdose.csv")
  cat("Downloaded CDC VSRR overdose data\n")

  vsrr_data <- read_csv("../data_pdmp/cdc_vsrr_overdose.csv", show_col_types = FALSE)
  cat(sprintf("Loaded %d rows\n", nrow(vsrr_data)))
  print(head(vsrr_data))

  saveRDS(vsrr_data, "../data_pdmp/cdc_vsrr.rds")
} else {
  cat("Failed to download CDC VSRR data\n")
}

cat("\n=== CDC Data Collection Complete ===\n")
