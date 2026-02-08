# ============================================================
# 01b_fetch_wonder_data.R - Fetch age-restricted mortality
#   from CDC WONDER
# Paper 148: State Insulin Copay Caps and Working-Age
#             Diabetes Mortality (v5)
# Revision of apep_0161 (family apep_0150)
# ============================================================
# Data Sources:
#   1. CDC WONDER D76 (Underlying Cause of Death, 1999-2020)
#      URL: https://wonder.cdc.gov/ucd-icd10.html
#      Ages 25-64, ICD-10 E10-E14, by state x year
#      This fills the 2018-2019 gap (D76 covers 1999-2020)
#   2. CDC WONDER D176 (Provisional Mortality, 2018-last month)
#      URL: https://wonder.cdc.gov/mcd-icd10-provisional.html
#      Ages 25-64, ICD-10 E10-E14, by state x year
#      For 2021-2023 data
#
# Outputs (saved to data/):
#   - mortality_working_age.rds  <- Combined 1999-2023 working-age panel
#   - wonder_d76_raw.rds         <- Raw D76 response
#   - wonder_d176_raw.rds        <- Raw D176 response
#
# Inputs (from 01_fetch_data.R):
#   - data/state_lookup.rds      <- State FIPS lookup
# ============================================================

source("code/00_packages.R")

stopifnot(file.exists("data/state_lookup.rds"))
all_states <- readRDS("data/state_lookup.rds")

dir.create("data", showWarnings = FALSE)

# ============================================================
# PART 1: Query CDC WONDER D76 (1999-2020)
# ============================================================
# CDC WONDER requires POST requests with specific form parameters
# The API endpoint accepts form-encoded data and returns tab-delimited text
#
# NOTE: CDC WONDER has rate limits and requires accepting data use
# restrictions. We add User-Agent, retry logic, and Sys.sleep.

cat("\n=== Querying CDC WONDER D76 (1999-2020, Ages 25-64) ===\n")

# D76 form parameters for:
#   - Group by: State, Year
#   - Age groups: 25-34, 35-44, 45-54, 55-64
#   - ICD-10 codes: E10-E14 (Diabetes mellitus)
#   - All years available (1999-2020)
wonder_d76_params <- list(
  `B_1` = "D76.V9-level1",     # Group by State
  `B_2` = "D76.V1-level1",     # Group by Year
  `M_1` = "D76.M1",            # Deaths measure
  `M_2` = "D76.M2",            # Population measure
  `M_3` = "D76.M3",            # Crude Rate measure
  `O_V1_fmode` = "freg",       # Year filter mode
  `O_V2_fmode` = "freg",       # ICD filter mode
  `O_V9_fmode` = "freg",       # State filter mode
  `O_V27_fmode` = "freg",      # Age group filter mode
  `O_age` = "D76.V27",         # Age group variable
  `O_javascript` = "off",
  `O_location` = "D76.V9",
  `O_ucd` = "D76.V2",
  `O_title` = "",
  `O_timeout` = "600",
  `O_precision` = "1",
  `O_show_totals` = "false",
  `O_show_zeros` = "false",
  `O_show_suppressed` = "true",
  # Year selection: all years 1999-2020
  `V_D76.V1` = paste0("*", 1999:2020, collapse = ""),
  # State: all states
  `V_D76.V9` = "",
  # ICD-10: E10-E14 (Diabetes mellitus)
  `V_D76.V2` = "E10 E10.0 E10.1 E10.2 E10.3 E10.4 E10.5 E10.6 E10.7 E10.8 E10.9 E11 E11.0 E11.1 E11.2 E11.3 E11.4 E11.5 E11.6 E11.7 E11.8 E11.9 E12 E12.0 E12.1 E12.2 E12.3 E12.4 E12.5 E12.6 E12.7 E12.8 E12.9 E13 E13.0 E13.1 E13.2 E13.3 E13.4 E13.5 E13.6 E13.7 E13.8 E13.9 E14 E14.0 E14.1 E14.2 E14.3 E14.4 E14.5 E14.6 E14.7 E14.8 E14.9",
  # Age: 25-34, 35-44, 45-54, 55-64
  `V_D76.V27` = "25-34 35-44 45-54 55-64",
  `action-Send` = "Send"
)

# Function to query WONDER with retry logic
query_wonder <- function(endpoint, params, max_retries = 3) {
  for (attempt in 1:max_retries) {
    cat("  Attempt", attempt, "of", max_retries, "...\n")
    resp <- tryCatch({
      POST(
        endpoint,
        body = params,
        encode = "form",
        add_headers(
          `User-Agent` = "APEP-Research/1.0 (scl@econ.uzh.ch; academic research)",
          `Accept` = "text/plain"
        ),
        timeout(300)
      )
    }, error = function(e) {
      cat("    HTTP error:", e$message, "\n")
      NULL
    })

    if (!is.null(resp) && status_code(resp) == 200) {
      return(resp)
    }

    if (attempt < max_retries) {
      wait_time <- 5 * attempt
      cat("    Retrying in", wait_time, "seconds...\n")
      Sys.sleep(wait_time)
    }
  }
  return(NULL)
}

# Parse WONDER tab-delimited response
parse_wonder_response <- function(resp_text) {
  # WONDER returns tab-delimited data with header rows
  # Skip lines starting with "---" or empty
  lines <- strsplit(resp_text, "\n")[[1]]

  # Find the data section (after "---" separator)
  data_start <- which(grepl("^\"", lines) & !grepl("^\"---", lines) &
                         !grepl("^\"Notes\"", lines) & !grepl("^\"Total", lines))

  if (length(data_start) == 0) {
    cat("  WARNING: No data rows found in WONDER response\n")
    cat("  First 10 lines:\n")
    cat(paste(head(lines, 10), collapse = "\n"), "\n")
    return(NULL)
  }

  # Try to read as tab-delimited
  df <- tryCatch({
    read_tsv(resp_text, show_col_types = FALSE, na = c("", "Suppressed", "Unreliable"))
  }, error = function(e) {
    cat("  Parse error:", e$message, "\n")
    NULL
  })

  return(df)
}

# Query D76
d76_resp <- query_wonder("https://wonder.cdc.gov/controller/datarequest/D76", wonder_d76_params)

d76_data <- NULL
if (!is.null(d76_resp)) {
  resp_text <- content(d76_resp, "text", encoding = "UTF-8")

  # Check if response indicates an error
  if (grepl("error|denied|unauthorized", tolower(resp_text)) && !grepl("Deaths", resp_text)) {
    cat("  D76 query returned error or access denied.\n")
    cat("  Response preview:", substr(resp_text, 1, 500), "\n")
  } else {
    d76_data <- parse_wonder_response(resp_text)
    if (!is.null(d76_data)) {
      cat("  D76 raw data:", nrow(d76_data), "rows\n")
      saveRDS(d76_data, "data/wonder_d76_raw.rds")
    }
  }
} else {
  cat("  D76 query failed after all retries.\n")
}

# ============================================================
# PART 2: Query CDC WONDER D176 (2021-2023, Provisional)
# ============================================================

cat("\n=== Querying CDC WONDER D176 (2021-2023, Ages 25-64) ===\n")

Sys.sleep(5)  # Rate limit between queries

wonder_d176_params <- list(
  `B_1` = "D176.V9-level1",     # Group by State
  `B_2` = "D176.V1-level1",     # Group by Year
  `M_1` = "D176.M1",            # Deaths measure
  `M_2` = "D176.M2",            # Population measure
  `M_3` = "D176.M3",            # Crude Rate measure
  `O_V1_fmode` = "freg",
  `O_V2_fmode` = "freg",
  `O_V9_fmode` = "freg",
  `O_V27_fmode` = "freg",
  `O_age` = "D176.V27",
  `O_javascript` = "off",
  `O_location` = "D176.V9",
  `O_ucd` = "D176.V2",
  `O_title` = "",
  `O_timeout` = "600",
  `O_precision` = "1",
  `O_show_totals` = "false",
  `O_show_zeros` = "false",
  `O_show_suppressed` = "true",
  # Years: 2021-2023
  `V_D176.V1` = "*2021 *2022 *2023",
  `V_D176.V9` = "",
  `V_D176.V2` = "E10 E10.0 E10.1 E10.2 E10.3 E10.4 E10.5 E10.6 E10.7 E10.8 E10.9 E11 E11.0 E11.1 E11.2 E11.3 E11.4 E11.5 E11.6 E11.7 E11.8 E11.9 E12 E12.0 E12.1 E12.2 E12.3 E12.4 E12.5 E12.6 E12.7 E12.8 E12.9 E13 E13.0 E13.1 E13.2 E13.3 E13.4 E13.5 E13.6 E13.7 E13.8 E13.9 E14 E14.0 E14.1 E14.2 E14.3 E14.4 E14.5 E14.6 E14.7 E14.8 E14.9",
  `V_D176.V27` = "25-34 35-44 45-54 55-64",
  `action-Send` = "Send"
)

d176_resp <- query_wonder("https://wonder.cdc.gov/controller/datarequest/D176", wonder_d176_params)

d176_data <- NULL
if (!is.null(d176_resp)) {
  resp_text <- content(d176_resp, "text", encoding = "UTF-8")

  if (grepl("error|denied|unauthorized", tolower(resp_text)) && !grepl("Deaths", resp_text)) {
    cat("  D176 query returned error or access denied.\n")
    cat("  Response preview:", substr(resp_text, 1, 500), "\n")
  } else {
    d176_data <- parse_wonder_response(resp_text)
    if (!is.null(d176_data)) {
      cat("  D176 raw data:", nrow(d176_data), "rows\n")
      saveRDS(d176_data, "data/wonder_d176_raw.rds")
    }
  }
} else {
  cat("  D176 query failed after all retries.\n")
}

# ============================================================
# PART 3: Process and Combine WONDER Data
# ============================================================

cat("\n=== Processing CDC WONDER Data ===\n")

process_wonder_data <- function(df, source_label) {
  if (is.null(df)) return(NULL)

  # Standardize column names (WONDER uses varying names)
  names_lower <- tolower(names(df))
  names(df) <- names_lower

  # Identify columns
  state_col <- names(df)[grepl("state$|^state$|residence", names(df))][1]
  year_col  <- names(df)[grepl("year$|^year$", names(df))][1]
  death_col <- names(df)[grepl("deaths$|^deaths$", names(df))][1]
  pop_col   <- names(df)[grepl("population$|^population$", names(df))][1]
  rate_col  <- names(df)[grepl("crude rate", names(df))][1]

  if (is.na(state_col) || is.na(year_col) || is.na(death_col)) {
    cat("  Could not identify required columns.\n")
    cat("  Available:", paste(names(df), collapse = ", "), "\n")
    return(NULL)
  }

  result <- df %>%
    select(
      state_name = all_of(state_col),
      year = all_of(year_col),
      deaths = all_of(death_col),
      population = all_of(pop_col)
    ) %>%
    mutate(
      year = as.integer(year),
      deaths = suppressWarnings(as.integer(deaths)),
      population = suppressWarnings(as.integer(population)),
      # Flag suppressed observations (deaths < 10 or "Suppressed")
      is_suppressed = is.na(deaths),
      # Compute crude rate per 100,000
      crude_rate = ifelse(!is.na(deaths) & !is.na(population) & population > 0,
                          (deaths / population) * 100000,
                          NA_real_),
      data_source = source_label
    ) %>%
    # Join to get state FIPS codes
    left_join(all_states, by = "state_name") %>%
    filter(!is.na(state_fips)) %>%
    select(state_fips, state_abbr, state_name, year, deaths, population,
           crude_rate, is_suppressed, data_source)

  cat("  Processed", source_label, ":", nrow(result), "state-year obs\n")
  cat("    Suppressed:", sum(result$is_suppressed), "cells\n")
  cat("    Year range:", min(result$year), "-", max(result$year), "\n")
  cat("    States:", n_distinct(result$state_fips), "\n")
  return(result)
}

d76_processed  <- process_wonder_data(d76_data, "CDC_WONDER_D76")
d176_processed <- process_wonder_data(d176_data, "CDC_WONDER_D176")

# ============================================================
# PART 4: Combine WONDER Data (No Fallback — Fail Loudly)
# ============================================================
# If CDC WONDER API is inaccessible, the script MUST fail.
# Working-age mortality must come from real age-restricted data.
# Scaling all-ages data by hard-coded constants would constitute
# data fabrication and is not permitted.

if (is.null(d76_processed) && is.null(d176_processed)) {
  # API unavailable — check for cached WONDER data from a previous successful run
  cached_file <- "data/mortality_working_age.rds"
  if (file.exists(cached_file)) {
    cached <- readRDS(cached_file)
    # Only accept cached data if it came from real WONDER queries (not the fabrication fallback)
    cached_sources <- unique(cached$data_source)
    fabricated_sources <- grepl("SCALED|FALLBACK|SIMULATED|SYNTHETIC", cached_sources, ignore.case = TRUE)
    if (any(fabricated_sources)) {
      stop("FATAL: CDC WONDER API unavailable and cached data is from fabrication fallback.\n",
           "Cached data sources: ", paste(cached_sources, collapse = ", "), "\n",
           "Cannot proceed without real age-restricted WONDER data.\n",
           "Re-run this script when CDC WONDER is accessible, or manually download\n",
           "age-restricted (25-64) diabetes mortality data from https://wonder.cdc.gov")
    }
    cat("\n  NOTE: Using cached WONDER data from previous successful run.\n")
    cat("  Cached sources:", paste(cached_sources, collapse = ", "), "\n")
    mortality_working_age <- cached
  } else {
    stop("FATAL: CDC WONDER API unavailable. Cannot construct working-age panel without real data.\n",
         "Both D76 and D176 queries returned no data. Check network access and CDC WONDER availability.\n",
         "Do NOT use scaled all-ages data as a proxy — this would constitute data fabrication.")
  }
} else {
  # Combine D76 (1999-2020) and D176 (2021-2023)
  # For overlapping years (2018-2020 in both), prefer D76 (final data)
  if (!is.null(d76_processed) && !is.null(d176_processed)) {
    # D176 only for years > 2020 (where D76 ends)
    d176_new <- d176_processed %>% filter(year > 2020)
    mortality_working_age <- bind_rows(d76_processed, d176_new) %>%
      arrange(state_fips, year) %>%
      distinct(state_fips, year, .keep_all = TRUE)
    cat("\n  Combined D76 + D176:", nrow(mortality_working_age), "obs\n")
  } else if (!is.null(d76_processed)) {
    mortality_working_age <- d76_processed
    cat("\n  Using D76 only:", nrow(mortality_working_age), "obs\n")
  } else {
    mortality_working_age <- d176_processed
    cat("\n  Using D176 only:", nrow(mortality_working_age), "obs\n")
  }
}

# ============================================================
# PART 5: Suppression Documentation
# ============================================================

cat("\n=== Suppression Analysis ===\n")

suppressed_cells <- mortality_working_age %>%
  filter(is_suppressed) %>%
  select(state_fips, state_abbr, year)

if (nrow(suppressed_cells) > 0) {
  cat("Suppressed state-year cells (deaths < 10):\n")
  print(suppressed_cells %>% arrange(state_abbr, year), n = 50)
  cat("\nTotal suppressed:", nrow(suppressed_cells), "of", nrow(mortality_working_age), "\n")

  # Count suppressed per state
  cat("\nSuppression by state:\n")
  suppressed_cells %>%
    count(state_abbr) %>%
    arrange(desc(n)) %>%
    print(n = 20)
} else {
  cat("No suppressed cells in working-age data.\n")
}

# ============================================================
# PART 6: Save Working-Age Mortality Data
# ============================================================

cat("\n=== Saving Working-Age Mortality Data ===\n")

saveRDS(mortality_working_age, "data/mortality_working_age.rds")
cat("Saved data/mortality_working_age.rds\n")
cat("  Rows:", nrow(mortality_working_age), "\n")
cat("  Year range:", min(mortality_working_age$year), "-", max(mortality_working_age$year), "\n")
cat("  States:", n_distinct(mortality_working_age$state_fips), "\n")
cat("  Suppressed:", sum(mortality_working_age$is_suppressed), "\n")
cat("  Data sources:\n")
print(table(mortality_working_age$data_source))

# Check for 2018-2019 gap fill
if (any(mortality_working_age$year %in% c(2018, 2019))) {
  cat("\n  SUCCESS: 2018-2019 gap is FILLED in working-age data.\n")
  cat("  2018 obs:", sum(mortality_working_age$year == 2018), "\n")
  cat("  2019 obs:", sum(mortality_working_age$year == 2019), "\n")
} else {
  cat("\n  NOTE: 2018-2019 gap persists in working-age data.\n")
}

cat("\n=== CDC WONDER Data Fetch Complete ===\n")
