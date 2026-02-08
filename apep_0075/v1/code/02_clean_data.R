# =============================================================================
# 02_clean_data.R
# Additional data cleaning and variable construction
# Paper 102: Minimum Wage and Elderly Worker Employment
# =============================================================================

source("output/paper_102/code/00_packages.R")

# Load data
cps_full <- read_csv(file.path(data_dir, "cps_65plus_full.csv"), show_col_types = FALSE)
mw_data <- read_csv(file.path(data_dir, "minimum_wage.csv"), show_col_types = FALSE)

# =============================================================================
# Create state-level panel for main DiD analysis
# =============================================================================

message("Creating state-year panel...")

# State-year panel with employment rates
state_year <- cps_full %>%
  group_by(state, year) %>%
  summarize(
    # Sample sizes
    n_obs = n(),
    n_weighted = sum(weight, na.rm = TRUE),

    # Overall 65+ employment
    emp_rate_all = weighted.mean(employed, weight, na.rm = TRUE),
    lfp_rate_all = weighted.mean(in_lf, weight, na.rm = TRUE),

    # Low-education 65+ employment (HS or less)
    emp_rate_lowedu = weighted.mean(employed[hs_or_less], weight[hs_or_less], na.rm = TRUE),
    lfp_rate_lowedu = weighted.mean(in_lf[hs_or_less], weight[hs_or_less], na.rm = TRUE),
    n_lowedu = sum(hs_or_less, na.rm = TRUE),

    # Service occupation employment
    emp_rate_service = weighted.mean(employed[service_occ], weight[service_occ], na.rm = TRUE),
    n_service = sum(service_occ, na.rm = TRUE),

    # Low-wage likely sample
    emp_rate_lowwage = weighted.mean(employed[low_wage_likely], weight[low_wage_likely], na.rm = TRUE),
    lfp_rate_lowwage = weighted.mean(in_lf[low_wage_likely], weight[low_wage_likely], na.rm = TRUE),
    n_lowwage = sum(low_wage_likely, na.rm = TRUE),

    # Demographics
    pct_female = weighted.mean(female, weight, na.rm = TRUE),
    pct_black = weighted.mean(black, weight, na.rm = TRUE),
    pct_hispanic = weighted.mean(hispanic, weight, na.rm = TRUE),
    pct_married = weighted.mean(married, weight, na.rm = TRUE),
    pct_hs_or_less = weighted.mean(hs_or_less, weight, na.rm = TRUE),

    # Age distribution
    mean_age = weighted.mean(age, weight, na.rm = TRUE),

    # Policy variables (first observation)
    eff_mw = first(eff_mw),
    log_eff_mw = first(log_eff_mw),
    first_treat_year = first(first_treat_year),

    .groups = "drop"
  ) %>%
  # Create treatment variables
  mutate(
    # Treatment indicator (ever treated)
    ever_treated = (first_treat_year > 0),
    # Post indicator
    post = (year >= first_treat_year & first_treat_year > 0),
    # Relative time to treatment
    rel_time = ifelse(first_treat_year > 0, year - first_treat_year, NA),
    # Group variable for C&S (0 = never treated)
    group = ifelse(ever_treated, first_treat_year, 0)
  )

# =============================================================================
# Create placebo sample: High-education 65+ (should not be affected)
# =============================================================================

message("Creating placebo sample...")

state_year_placebo <- cps_full %>%
  filter(college_plus) %>%
  group_by(state, year) %>%
  summarize(
    emp_rate_highedu = weighted.mean(employed, weight, na.rm = TRUE),
    lfp_rate_highedu = weighted.mean(in_lf, weight, na.rm = TRUE),
    n_highedu = n(),
    .groups = "drop"
  )

state_year <- state_year %>%
  left_join(state_year_placebo, by = c("state", "year"))

# =============================================================================
# Add state-level controls (could be correlated with MW increases)
# =============================================================================

# For now, we use what's available from the data
# In production, would merge unemployment rate, EITC status, etc.

# =============================================================================
# Create analysis-ready datasets
# =============================================================================

# Main analysis: state-year panel for DiD
write_csv(state_year, file.path(data_dir, "state_year_panel.csv"))

# Balance checks: state characteristics
state_chars <- state_year %>%
  filter(year == 2010) %>%
  select(state, ever_treated, first_treat_year,
         pct_female, pct_black, pct_hispanic, pct_married,
         pct_hs_or_less, mean_age, emp_rate_all, emp_rate_lowedu)

write_csv(state_chars, file.path(data_dir, "state_characteristics_2010.csv"))

# =============================================================================
# Summary statistics
# =============================================================================

message("\n=== State-Year Panel Summary ===")
message("Total state-years: ", nrow(state_year))
message("States: ", n_distinct(state_year$state))
message("Years: ", min(state_year$year), " - ", max(state_year$year))

# Treatment summary
treat_sum <- state_year %>%
  filter(year == 2015) %>%
  group_by(ever_treated) %>%
  summarize(
    n_states = n(),
    mean_emp_lowwage = mean(emp_rate_lowwage, na.rm = TRUE),
    mean_emp_all = mean(emp_rate_all, na.rm = TRUE),
    .groups = "drop"
  )

message("\nTreatment status (as of 2015):")
print(treat_sum)

# Sample sizes in low-wage group
lowwage_sum <- state_year %>%
  group_by(year) %>%
  summarize(
    total_lowwage = sum(n_lowwage, na.rm = TRUE),
    mean_lowwage = mean(n_lowwage, na.rm = TRUE),
    .groups = "drop"
  )

message("\nLow-wage sample sizes by year:")
print(lowwage_sum)

message("\nData cleaning complete. Files saved to: ", data_dir)
