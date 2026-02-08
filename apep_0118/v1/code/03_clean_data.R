# =============================================================================
# 03_clean_data.R
# Merge QCEW employment with policy data, construct analysis sample
# Paper 117: Sports Betting Employment Effects
# =============================================================================

source("00_packages.R")

# =============================================================================
# Load Data
# =============================================================================

message("Loading QCEW and policy data...")

qcew_gambling <- read_csv("../data/qcew_gambling.csv", show_col_types = FALSE)
policy_panel <- read_csv("../data/policy_panel.csv", show_col_types = FALSE)
state_year_panel <- read_csv("../data/state_year_panel.csv", show_col_types = FALSE)

message(sprintf("  QCEW gambling: %d rows", nrow(qcew_gambling)))
message(sprintf("  Policy panel: %d states", nrow(policy_panel)))
message(sprintf("  State-year panel: %d rows", nrow(state_year_panel)))

# =============================================================================
# Merge Employment with Policy
# =============================================================================

analysis_df <- qcew_gambling %>%
  select(state_abbr, year, employment, establishments, total_wages, avg_weekly_wage) %>%
  left_join(
    state_year_panel %>%
      select(state_abbr, year, treatment_year, treated_sb, treated_mobile,
             treated_igaming, has_igaming, never_treated, always_treated,
             sb_type, event_time),
    by = c("state_abbr", "year")
  ) %>%
  left_join(
    state_fips %>% select(state_abbr, state_fips),
    by = "state_abbr"
  ) %>%
  # Create additional variables
  mutate(
    # Log outcomes
    log_employment = log(employment + 1),
    log_wages = log(total_wages + 1),

    # Numeric state ID for fixed effects
    state_id = as.integer(factor(state_fips)),

    # Treatment year for did package (0 = never treated)
    g = if_else(is.na(treatment_year) | treatment_year == 0, 0L, treatment_year),

    # Sample restrictions
    in_main_sample = !always_treated & !is.na(employment),  # Exclude NV (always treated)
    in_restricted_sample = in_main_sample & !has_igaming    # Exclude iGaming states
  )

# =============================================================================
# Sample Summary
# =============================================================================

message("\n", paste(rep("=", 70), collapse = ""))
message("ANALYSIS SAMPLE SUMMARY")
message(paste(rep("=", 70), collapse = ""), "\n")

# Main sample
main_sample <- analysis_df %>% filter(in_main_sample)

message("Main sample (excluding Nevada):")
message(sprintf("  Total observations: %d", nrow(main_sample)))
message(sprintf("  States: %d", n_distinct(main_sample$state_abbr)))
message(sprintf("  Years: %d to %d", min(main_sample$year), max(main_sample$year)))

# Treatment group composition
treatment_summary <- main_sample %>%
  filter(year == 2024) %>%
  group_by(g > 0) %>%
  summarise(
    n_states = n_distinct(state_abbr),
    states = paste(sort(unique(state_abbr)), collapse = ", "),
    .groups = "drop"
  )

message("\nTreatment composition (as of 2024):")
message(sprintf("  Treated states: %d", treatment_summary$n_states[treatment_summary$`g > 0` == TRUE]))
message(sprintf("  Control states: %d", treatment_summary$n_states[treatment_summary$`g > 0` == FALSE]))

# Missing data check
missing_summary <- main_sample %>%
  summarise(
    missing_empl = sum(is.na(employment)),
    missing_wages = sum(is.na(total_wages)),
    zero_empl = sum(employment == 0, na.rm = TRUE)
  )

message("\nMissing/zero values:")
message(sprintf("  Missing employment: %d", missing_summary$missing_empl))
message(sprintf("  Missing wages: %d", missing_summary$missing_wages))
message(sprintf("  Zero employment: %d", missing_summary$zero_empl))

# =============================================================================
# Descriptive Statistics
# =============================================================================

# Pre-treatment period (2010-2017)
pre_treatment <- main_sample %>%
  filter(year <= 2017) %>%
  group_by(ever_treated = g > 0) %>%
  summarise(
    n_obs = n(),
    mean_empl = mean(employment, na.rm = TRUE),
    sd_empl = sd(employment, na.rm = TRUE),
    median_empl = median(employment, na.rm = TRUE),
    mean_estabs = mean(establishments, na.rm = TRUE),
    .groups = "drop"
  )

message("\nPre-treatment (2010-2017) descriptive statistics:")
print(pre_treatment)

# Employment trends by treatment group
trends <- main_sample %>%
  group_by(year, ever_treated = g > 0) %>%
  summarise(
    mean_empl = mean(employment, na.rm = TRUE),
    total_empl = sum(employment, na.rm = TRUE),
    n_states = n_distinct(state_abbr),
    .groups = "drop"
  )

message("\nEmployment trends by treatment status:")
print(trends %>% pivot_wider(names_from = ever_treated, values_from = c(mean_empl, total_empl, n_states)))

# =============================================================================
# Save Analysis Sample
# =============================================================================

# Main analysis sample
write_csv(
  main_sample %>% select(
    state_abbr, state_fips, state_id, year,
    employment, log_employment, establishments, total_wages, avg_weekly_wage,
    treatment_year, g, treated_sb, treated_mobile, treated_igaming,
    has_igaming, never_treated, event_time
  ),
  "../data/analysis_sample.csv"
)

message("\nSaved: ../data/analysis_sample.csv")
message(sprintf("  Rows: %d", nrow(main_sample)))

# Also save Callaway-Sant'Anna format
cs_data <- main_sample %>%
  select(state_id, year, log_employment, employment, g, state_abbr) %>%
  filter(!is.na(employment))

write_csv(cs_data, "../data/cs_analysis_data.csv")
message("Saved: ../data/cs_analysis_data.csv")

message("\n", paste(rep("=", 70), collapse = ""))
message("DATA CLEANING COMPLETE")
message(paste(rep("=", 70), collapse = ""))
