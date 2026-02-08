# 02_clean_data.R
# Clean and prepare data for analysis

source("00_packages.R")

# =============================================================================
# 1. LOAD RAW DATA
# =============================================================================

analysis_panel <- read_csv("../data/analysis_panel.csv", show_col_types = FALSE)
treatment_timing <- read_csv("../data/promise_treatment_timing.csv", show_col_types = FALSE)

message("Loaded panel: ", nrow(analysis_panel), " state-years")

# =============================================================================
# 2. CREATE ANALYSIS VARIABLES
# =============================================================================

# Clean and create variables for DiD
clean_data <- analysis_panel %>%
  filter(!is.na(total_college_enrolled)) %>%
  mutate(
    # Log enrollment
    log_enrollment = log(total_college_enrolled + 1),

    # Enrollment rate already calculated in fetch script
    # enrollment_rate = total_college_enrolled / pop_3plus,

    # Undergraduate share of total enrollment
    undergrad_share = undergrad_enrolled / total_college_enrolled,

    # Treatment variables for did package
    # first_treat = 0 means never treated
    first_treat_did = ifelse(first_treat == 0, 0, first_treat),

    # State ID for clustering
    state_id = as.integer(factor(state_fips))
  )

# =============================================================================
# 3. PRE-TREATMENT BALANCE CHECK
# =============================================================================

pre_treat_balance <- clean_data %>%
  filter(year <= 2014) %>%  # Pre-treatment period
  group_by(ever_treated) %>%
  summarize(
    n_states = n_distinct(state_fips),
    mean_enrollment = mean(total_college_enrolled, na.rm = TRUE),
    sd_enrollment = sd(total_college_enrolled, na.rm = TRUE),
    mean_undergrad_share = mean(undergrad_share, na.rm = TRUE),
    .groups = "drop"
  )

message("\n=== PRE-TREATMENT BALANCE ===")
print(pre_treat_balance)

# =============================================================================
# 4. CREATE EVENT STUDY INDICATORS
# =============================================================================

# For event study, create indicators for years relative to treatment
# Cap at -5 to +7 relative years

event_study_data <- clean_data %>%
  mutate(
    # Relative time (NA for never-treated)
    rel_time = ifelse(first_treat > 0, year - first_treat, NA),

    # Binned relative time for event study
    rel_time_binned = case_when(
      is.na(rel_time) ~ NA_real_,
      rel_time < -5 ~ -5,
      rel_time > 7 ~ 7,
      TRUE ~ rel_time
    )
  )

# =============================================================================
# 5. SUMMARY STATISTICS
# =============================================================================

summary_stats <- clean_data %>%
  summarize(
    n_obs = n(),
    n_states = n_distinct(state_fips),
    n_years = n_distinct(year),
    mean_enrollment = mean(total_college_enrolled, na.rm = TRUE),
    sd_enrollment = sd(total_college_enrolled, na.rm = TRUE),
    mean_undergrad_share = mean(undergrad_share, na.rm = TRUE),
    n_treated_states = n_distinct(state_fips[ever_treated]),
    n_control_states = n_distinct(state_fips[!ever_treated])
  )

message("\n=== SUMMARY STATISTICS ===")
print(summary_stats)

# Treatment timing distribution
treat_timing_dist <- treatment_timing %>%
  filter(ever_treated) %>%
  count(first_cohort_year) %>%
  arrange(first_cohort_year)

message("\n=== TREATMENT TIMING DISTRIBUTION ===")
print(treat_timing_dist)

# =============================================================================
# 6. SAVE CLEANED DATA
# =============================================================================

write_csv(clean_data, "../data/clean_panel.csv")
write_csv(event_study_data, "../data/event_study_panel.csv")

# Also save as RDS for faster loading
saveRDS(clean_data, "../data/clean_panel.rds")
saveRDS(event_study_data, "../data/event_study_panel.rds")

message("\nCleaned data saved:")
message("  - clean_panel.csv/rds")
message("  - event_study_panel.csv/rds")
