# ==============================================================================
# Paper 72: PDMP Mandatory Query Effects on Opioid Prescribing
# 01_fetch_arcos_data.R - Download ARCOS opioid dispensing data
# ==============================================================================

# Load packages
library(tidyverse)
library(httr)

# Create data directory
dir.create("../data_pdmp", showWarnings = FALSE)

# ------------------------------------------------------------------------------
# ARCOS API - Washington Post Data
# API Key: "WaPo"
# Data: Oxycodone and Hydrocodone pills by state/county, 2006-2019
# ------------------------------------------------------------------------------

# Function to query ARCOS API for state-level data
get_arcos_state_data <- function(year, key = "WaPo") {
  url <- sprintf(
    "https://arcos-api.ext.nile.works/v1/combined_buyer_annual?state=&year=%d&key=%s",
    year, key
  )

  response <- GET(url)
  if (status_code(response) == 200) {
    content(response, as = "parsed", type = "application/json")
  } else {
    warning(sprintf("Failed to fetch year %d: status %d", year, status_code(response)))
    NULL
  }
}

# Fetch all years 2006-2014 (publicly available range)
cat("Fetching ARCOS data by state-year from Washington Post API...\n")

all_data <- list()
for (year in 2006:2014) {
  cat(sprintf("  Fetching %d...\n", year))
  result <- get_arcos_state_data(year)
  if (!is.null(result)) {
    # Convert list to dataframe
    df <- bind_rows(lapply(result, as.data.frame))
    df$year <- year
    all_data[[as.character(year)]] <- df
  }
  Sys.sleep(1)  # Rate limiting
}

# Combine all years
if (length(all_data) > 0) {
  arcos_state <- bind_rows(all_data)
  cat(sprintf("\nDownloaded %d state-year observations\n", nrow(arcos_state)))

  # Save
  saveRDS(arcos_state, "../data_pdmp/arcos_state_year.rds")
  write_csv(arcos_state, "../data_pdmp/arcos_state_year.csv")
  cat("Saved to data_pdmp/arcos_state_year.rds\n")
} else {
  cat("No data retrieved from ARCOS API\n")
}

# Also try the summarized buyer endpoint for state totals
cat("\nAttempting alternative endpoint for state totals...\n")

# Alternative: Get total pills by state across all years
get_arcos_state_totals <- function(key = "WaPo") {
  url <- sprintf("https://arcos-api.ext.nile.works/v1/total_pills_state?key=%s", key)
  response <- GET(url, timeout(60))
  if (status_code(response) == 200) {
    content(response, as = "parsed", type = "application/json")
  } else {
    warning(sprintf("Failed to fetch state totals: status %d", status_code(response)))
    NULL
  }
}

state_totals <- get_arcos_state_totals()
if (!is.null(state_totals)) {
  state_totals_df <- bind_rows(lapply(state_totals, function(x) {
    data.frame(
      state = x$BUYER_STATE,
      total_pills = as.numeric(x$DOSAGE_UNIT),
      stringsAsFactors = FALSE
    )
  }))
  cat(sprintf("Got totals for %d states\n", nrow(state_totals_df)))
  saveRDS(state_totals_df, "../data_pdmp/arcos_state_totals.rds")
}

cat("\n=== ARCOS Data Collection Complete ===\n")
