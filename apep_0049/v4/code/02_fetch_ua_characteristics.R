# ============================================================================
# APEP-0049 v4 - Transit Funding Discontinuity
# 02_fetch_ua_characteristics.R - Fetch urbanized area-level characteristics
#
# Uses 2016-2020 ACS 5-year estimates (consistent with 01_fetch_data.R)
# and 2020 Census population for supplementary/robustness analysis
# ============================================================================

# Source packages from relative path (run from code/ or paper root)
if (file.exists("00_packages.R")) {
  source("00_packages.R")
} else if (file.exists("code/00_packages.R")) {
  source("code/00_packages.R")
} else {
  stop("Cannot find 00_packages.R - run from code/ directory or paper root")
}

# ============================================================================
# 1. FETCH URBANIZED AREA-LEVEL ACS DATA
# ============================================================================

# The Census API provides ACS data directly at the urban area level
# This is much cleaner than trying to match places to UAs

cat("Fetching ACS 5-year data at urban area level...\n")

acs_url <- "https://api.census.gov/data/2020/acs/acs5"

# Key variables for our analysis:
# Commute mode: B08301 (Means of Transportation to Work)
# B08301_001E: Total workers 16+
# B08301_010E: Public transit (excluding taxicab)
# B08301_019E: Worked at home

# Employment: B23025 (Employment Status)
# B23025_002E: In labor force
# B23025_003E: In labor force - civilian
# B23025_004E: Employed
# B23025_005E: Unemployed

# Vehicle ownership: B08201 (Household Size by Vehicles Available)
# B08201_001E: Total households
# B08201_002E: No vehicle available

# Income: B19013 (Median Household Income)
# B19013_001E: Median household income

# Commute time: B08303 (Travel Time to Work)
# B08303_001E: Total
# B08303_012E: 45 to 59 minutes
# B08303_013E: 60+ minutes

vars_to_fetch <- paste(
  "NAME",
  "B08301_001E", "B08301_010E", "B08301_019E",  # Commute mode
  "B23025_002E", "B23025_004E", "B23025_005E",  # Employment
  "B08201_001E", "B08201_002E",                  # Vehicles
  "B19013_001E",                                  # Income
  "B08303_001E", "B08303_012E", "B08303_013E",  # Commute time
  sep = ","
)

census_key <- Sys.getenv("CENSUS_API_KEY", "")

ua_acs_response <- NULL
for (attempt in 1:5) {
  acs_query <- list(get = vars_to_fetch, `for` = "urban area:*")
  if (nchar(census_key) > 0) acs_query$key <- census_key
  ua_acs_response <- tryCatch(
    GET(acs_url, query = acs_query, timeout(60)),
    error = function(e) NULL
  )
  if (!is.null(ua_acs_response) && status_code(ua_acs_response) == 200) break
  wait_secs <- 30 * attempt
  cat(sprintf("  Attempt %d failed (status %s), retrying in %ds...\n",
              attempt, ifelse(is.null(ua_acs_response), "error",
                              status_code(ua_acs_response)), wait_secs))
  Sys.sleep(wait_secs)
}

if (!is.null(ua_acs_response) && status_code(ua_acs_response) == 200) {
  ua_acs_raw <- content(ua_acs_response, "text", encoding = "UTF-8")
  ua_acs_json <- fromJSON(ua_acs_raw)

  ua_acs <- as.data.frame(ua_acs_json[-1, ], stringsAsFactors = FALSE)
  colnames(ua_acs) <- ua_acs_json[1, ]

  # Convert to numeric and calculate rates
  ua_acs <- ua_acs %>%
    rename(
      ua_name = NAME,
      ua_code = `urban area`,
      workers_total = B08301_001E,
      workers_transit = B08301_010E,
      workers_wfh = B08301_019E,
      labor_force = B23025_002E,
      employed = B23025_004E,
      unemployed = B23025_005E,
      households_total = B08201_001E,
      households_no_vehicle = B08201_002E,
      median_hh_income = B19013_001E,
      commute_total = B08303_001E,
      commute_45_59 = B08303_012E,
      commute_60plus = B08303_013E
    ) %>%
    mutate(across(c(workers_total:commute_60plus), as.numeric)) %>%
    mutate(
      # Outcome rates
      transit_share = workers_transit / workers_total,
      wfh_share = workers_wfh / workers_total,
      employment_rate = employed / labor_force,
      unemployment_rate = unemployed / labor_force,
      no_vehicle_share = households_no_vehicle / households_total,
      long_commute_share = (commute_45_59 + commute_60plus) / commute_total
    ) %>%
    filter(!is.na(workers_total))

  cat("  Found ACS data for", nrow(ua_acs), "urbanized areas\n")

} else {
  stop("Failed to fetch UA-level ACS data after retries. Last status: ",
       ifelse(is.null(ua_acs_response), "error", status_code(ua_acs_response)))
}

# ============================================================================
# 2. FETCH 2020 CENSUS POPULATION DATA
# ============================================================================

cat("Fetching 2020 Census population data at urban area level...\n")

# NOTE: This script provides supplementary analysis using 2020 Census classifications.
# The MAIN analysis in 03_main_analysis.R uses 2010 Census population (see 01_fetch_data.R)
# because the research design requires treatment (2010 classification) to precede outcomes.
# This 2020 data is for robustness checks and descriptive statistics only.

census_2020_url <- "https://api.census.gov/data/2020/dec/pl"

# Fetch 2020 population for urban areas with retry
ua_pop_response <- NULL
for (attempt in 1:5) {
  pop_query <- list(get = "NAME,P1_001N", `for` = "urban area:*")
  if (nchar(census_key) > 0) pop_query$key <- census_key
  ua_pop_response <- tryCatch(
    GET(census_2020_url, query = pop_query, timeout(60)),
    error = function(e) NULL
  )
  if (!is.null(ua_pop_response) && status_code(ua_pop_response) == 200) break
  wait_secs <- 30 * attempt
  cat(sprintf("  Attempt %d failed (status %s), retrying in %ds...\n",
              attempt, ifelse(is.null(ua_pop_response), "error",
                              status_code(ua_pop_response)), wait_secs))
  Sys.sleep(wait_secs)
}

if (!is.null(ua_pop_response) && status_code(ua_pop_response) == 200) {
  ua_pop_raw <- content(ua_pop_response, "text", encoding = "UTF-8")
  ua_pop_json <- fromJSON(ua_pop_raw)

  ua_pop <- as.data.frame(ua_pop_json[-1, ], stringsAsFactors = FALSE)
  colnames(ua_pop) <- ua_pop_json[1, ]

  ua_pop <- ua_pop %>%
    rename(
      ua_name_2020 = NAME,
      population_2020 = P1_001N,
      ua_code = `urban area`
    ) %>%
    mutate(
      population_2020 = as.numeric(population_2020)
    ) %>%
    filter(!is.na(population_2020))

  cat("  Found 2020 Census population for", nrow(ua_pop), "urban areas\n")

  # Save for documentation
  write_csv(ua_pop, file.path(data_dir, "ua_population_2020.csv"))
  cat("  Saved to:", file.path(data_dir, "ua_population_2020.csv"), "\n")
} else {
  cat("  WARNING: 2020 Census PL94 endpoint unavailable (status ",
      ifelse(is.null(ua_pop_response), "error", status_code(ua_pop_response)),
      "). Using ACS data as primary source.\n")
  # Create fallback using ACS data (which we already have)
  ua_pop <- ua_acs %>%
    select(ua_code, ua_name) %>%
    rename(ua_name_2020 = ua_name) %>%
    mutate(population_2020 = NA_real_)
  write_csv(ua_pop, file.path(data_dir, "ua_population_2020.csv"))
}

# Merge ACS characteristics with population
ua_combined <- ua_pop %>%
  left_join(ua_acs, by = "ua_code")

# If we have 2020 population, add running variable and treatment
if (any(!is.na(ua_combined$population_2020))) {
  ua_combined <- ua_combined %>%
    mutate(
      running_var = population_2020 - 50000,
      running_var_pct = (population_2020 - 50000) / 50000,
      above_threshold = as.integer(population_2020 >= 50000),
      in_bandwidth_30 = abs(running_var_pct) <= 0.30,
      in_bandwidth_20 = abs(running_var_pct) <= 0.20,
      in_bandwidth_40 = abs(running_var_pct) <= 0.40
    )
} else {
  # Fallback: no 2020 population available, skip threshold-based analysis
  cat("  Note: 2020 Census population not available. Saving ACS data only.\n")
  ua_combined <- ua_combined %>%
    mutate(
      running_var = NA_real_, running_var_pct = NA_real_,
      above_threshold = NA_integer_,
      in_bandwidth_30 = FALSE, in_bandwidth_20 = FALSE, in_bandwidth_40 = FALSE
    )
}

# Check merge success
merge_success <- sum(!is.na(ua_combined$transit_share))
cat("  Merged ACS data for", merge_success, "of", nrow(ua_combined), "areas\n")

# ============================================================================
# 3. SUMMARY STATISTICS
# ============================================================================

cat("\n=== SUMMARY STATISTICS ===\n")

# Full sample
cat("\nFull sample (all UAs):\n")
cat("  N:", nrow(ua_combined), "\n")
cat("  Mean population:", round(mean(ua_combined$population_2020), 0), "\n")
cat("  Median population:", round(median(ua_combined$population_2020), 0), "\n")

# Analysis sample (near threshold)
analysis_sample <- ua_combined %>% filter(in_bandwidth_30)

cat("\nAnalysis sample (35k-65k population):\n")
cat("  N:", nrow(analysis_sample), "\n")
cat("  Below threshold (control):", sum(analysis_sample$above_threshold == 0), "\n")
cat("  Above threshold (treated):", sum(analysis_sample$above_threshold == 1), "\n")

if (merge_success > 0) {
  analysis_with_acs <- analysis_sample %>% filter(!is.na(transit_share))

  cat("\nOutcome variables (analysis sample with ACS data):\n")
  cat("  Transit share: mean =", round(mean(analysis_with_acs$transit_share, na.rm = TRUE), 4),
      ", sd =", round(sd(analysis_with_acs$transit_share, na.rm = TRUE), 4), "\n")
  cat("  Employment rate: mean =", round(mean(analysis_with_acs$employment_rate, na.rm = TRUE), 4),
      ", sd =", round(sd(analysis_with_acs$employment_rate, na.rm = TRUE), 4), "\n")
  cat("  No vehicle share: mean =", round(mean(analysis_with_acs$no_vehicle_share, na.rm = TRUE), 4),
      ", sd =", round(sd(analysis_with_acs$no_vehicle_share, na.rm = TRUE), 4), "\n")
  cat("  Median HH income: mean =", round(mean(analysis_with_acs$median_hh_income, na.rm = TRUE), 0), "\n")
}

# ============================================================================
# 4. SAVE DATA
# ============================================================================

cat("\nSaving data...\n")

# Save combined dataset
write_csv(ua_combined, file.path(data_dir, "ua_combined.csv"))

# Save analysis sample
write_csv(analysis_sample, file.path(data_dir, "ua_analysis_sample.csv"))

cat("Data saved:\n")
cat("  - ua_combined.csv (full sample with ACS characteristics)\n")
cat("  - ua_analysis_sample.csv (analysis bandwidth only)\n")

cat("\n=== Data preparation complete ===\n")
