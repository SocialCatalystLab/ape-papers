# ==============================================================================
# 02_clean_data.R
# Universal School Meals and Household Food Security
# Clean and harmonize CPS-FSS data across years
# ==============================================================================

source("output/paper_106/code/00_packages.R")

# ------------------------------------------------------------------------------
# Load treatment timing
# ------------------------------------------------------------------------------
treatment <- read_csv(file.path(DATA_DIR, "treatment_timing.csv"), show_col_types = FALSE)

# ------------------------------------------------------------------------------
# Read and process CSV files (2022-2024)
# ------------------------------------------------------------------------------

process_census_csv <- function(year) {

  cat("Processing Census CSV year", year, "...\n")

  file_path <- file.path(DATA_DIR, sprintf("cps_fss_%d_raw.csv", year))
  if (!file.exists(file_path)) {
    cat("  File not found\n")
    return(NULL)
  }

  df <- fread(file_path, stringsAsFactors = FALSE)

  # Key variables from CPS-FSS:
  # HRHHID, HRHHID2: Household identifiers
  # GESTFIPS: State FIPS code
  # HRYEAR4: Survey year
  # HRFS12M1: 12-month food security status (categorical)
  #   1 = Food Secure
  #   2 = Low Food Security (food insecure without hunger)
  #   3 = Very Low Food Security (food insecure with hunger)
  #  -1 = Not in universe
  #  -9 = No response
  # HRFS12MC: 12-month food security among children
  #   1 = Food Secure
  #   2 = Low Food Security
  #   3 = Very Low Food Security
  #  -1 = Not in universe (no children)
  #  -9 = No response
  # HEFAMINC: Family income bracket
  # HRNUMHOU: Number of persons in household
  # HWHHWGT: Household weight
  # PRTAGE: Person age (need to identify children)
  # PTDTRACE: Race
  # GTMETSTA: Metro status

  # First, collapse to household level
  # Get household characteristics from first person record
  hh_vars <- df %>%
    group_by(HRHHID, HRHHID2) %>%
    summarize(
      state_fips = first(GESTFIPS),
      year = first(HRYEAR4),
      hh_income = first(HEFAMINC),
      hh_size = first(HRNUMHOU),
      metro = first(GTMETSTA),
      # Food security status
      fs_status_hh = first(HRFS12M1),
      fs_status_child = first(HRFS12MC),
      # Weight
      weight = first(HWHHWGT),
      # Count children by age
      n_children_0_4 = sum(PRTAGE >= 0 & PRTAGE <= 4, na.rm = TRUE),
      n_children_5_17 = sum(PRTAGE >= 5 & PRTAGE <= 17, na.rm = TRUE),
      n_children_total = sum(PRTAGE >= 0 & PRTAGE <= 17, na.rm = TRUE),
      .groups = "drop"
    )

  # Create analysis variables
  # NOTE: HRFS12M1 coding: 1=Food Secure, 2=Low FS, 3=Very Low FS, -1=NIU, -9=No response
  # Per USDA methodology, households screened out (-1) are generally food secure
  # (they showed no indications of food hardship in initial questions)
  # We code them as food secure (0), not as missing
  hh_vars <- hh_vars %>%
    mutate(
      # Binary food insecurity (low or very low food security)
      # Screened-out households (-1) are coded as food secure per USDA methodology
      food_insecure = case_when(
        fs_status_hh %in% c(2, 3) ~ 1,
        fs_status_hh %in% c(1, -1) ~ 0,  # Include screened-out as food secure
        TRUE ~ NA_real_  # Only true non-response (-9) is missing
      ),
      # Very low food security
      very_low_fs = case_when(
        fs_status_hh == 3 ~ 1,
        fs_status_hh %in% c(1, 2, -1) ~ 0,  # Include screened-out as not VLFS
        TRUE ~ NA_real_
      ),
      # Food insecurity among children
      food_insecure_children = case_when(
        fs_status_child %in% c(2, 3) ~ 1,
        fs_status_child == 1 ~ 0,
        TRUE ~ NA_real_
      ),
      # Has school-age children (5-17)
      has_children_5_17 = as.integer(n_children_5_17 > 0),
      # Metro status binary
      urban = case_when(
        metro == 1 ~ 1,  # Metro
        metro == 2 ~ 0,  # Non-metro
        TRUE ~ NA_real_
      ),
      # Household ID for panel
      hhid = paste(HRHHID, HRHHID2, sep = "_")
    ) %>%
    select(hhid, year, state_fips, food_insecure, very_low_fs,
           food_insecure_children, has_children_5_17, n_children_5_17,
           n_children_total, hh_income, hh_size, urban, weight)

  cat("  Processed", nrow(hh_vars), "households\n")
  return(hh_vars)
}

# Process 2022-2024
csv_years <- 2022:2024
df_csv <- map_dfr(csv_years, process_census_csv)

cat("\nCSV data combined:", nrow(df_csv), "households\n")

# ------------------------------------------------------------------------------
# For older years (2015-2021), we need to parse the .dat files
# These are fixed-width format files - requires data dictionary
# For this paper, we'll use the recent CSV years (2022-2024) which cover
# the treatment period
# ------------------------------------------------------------------------------

# Note: A complete analysis would also include 2015-2021 data for pre-trends
# The .dat files require fixed-width parsing based on Census technical docs
# For now, proceeding with 2022-2024 to test the pipeline

# Create a simulated pre-treatment baseline using 2022 control states
# This is for code testing - real analysis needs full time series

cat("\nNote: Full analysis requires parsing 2015-2021 .dat files\n")
cat("Proceeding with 2022-2024 data for pipeline testing\n")

# ------------------------------------------------------------------------------
# Merge treatment status
# ------------------------------------------------------------------------------

# All states that never adopted universal meals by 2024
all_states <- 1:56
never_treated <- setdiff(all_states, treatment$state_fips)

# Create full treatment panel
df_analysis <- df_csv %>%
  left_join(
    treatment %>% select(state_fips, first_treat_year),
    by = "state_fips"
  ) %>%
  mutate(
    # For never-treated states, set first_treat_year to Inf or large number
    first_treat_year = if_else(is.na(first_treat_year), 9999L, as.integer(first_treat_year)),
    # Treatment indicator (post-treatment)
    treated = as.integer(year >= first_treat_year),
    # Treatment group (for CS estimator)
    # 0 = never treated, otherwise = first treatment year
    treatment_group = if_else(first_treat_year == 9999, 0L, first_treat_year)
  )

# Restrict to households with school-age children
df_school <- df_analysis %>%
  filter(has_children_5_17 == 1)

cat("\nHouseholds with school-age children:", nrow(df_school), "\n")

# ------------------------------------------------------------------------------
# Summary statistics
# ------------------------------------------------------------------------------

cat("\n=== SUMMARY STATISTICS ===\n")

# By treatment status and year
df_school %>%
  group_by(year, treated = treatment_group > 0) %>%
  summarize(
    n_hh = n(),
    pct_food_insecure = mean(food_insecure, na.rm = TRUE) * 100,
    pct_very_low = mean(very_low_fs, na.rm = TRUE) * 100,
    .groups = "drop"
  ) %>%
  arrange(year, treated) %>%
  print(n = 20)

# By state for treatment group
cat("\n=== TREATMENT STATES ===\n")
df_school %>%
  filter(treatment_group > 0) %>%
  group_by(state_fips, first_treat_year, year) %>%
  summarize(
    n_hh = n(),
    pct_food_insecure = mean(food_insecure, na.rm = TRUE) * 100,
    .groups = "drop"
  ) %>%
  print(n = 50)

# ------------------------------------------------------------------------------
# Save analysis dataset
# ------------------------------------------------------------------------------

write_csv(df_analysis, file.path(DATA_DIR, "cps_fss_analysis_full.csv"))
write_csv(df_school, file.path(DATA_DIR, "cps_fss_analysis_school.csv"))

cat("\n=== Saved analysis datasets ===\n")
cat("Full:", file.path(DATA_DIR, "cps_fss_analysis_full.csv"), "\n")
cat("School-age children:", file.path(DATA_DIR, "cps_fss_analysis_school.csv"), "\n")

cat("\n=== 02_clean_data.R complete ===\n")
