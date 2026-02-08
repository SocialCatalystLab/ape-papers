# =============================================================================
# 04_robustness.R
# Robustness checks and sensitivity analysis
# Paper 102: Minimum Wage and Elderly Worker Employment
# =============================================================================

source("output/paper_102/code/00_packages.R")

# Load data
state_year <- read_csv(file.path(data_dir, "state_year_panel.csv"), show_col_types = FALSE)

# =============================================================================
# Part 1: Bacon Decomposition
# =============================================================================

message("Running Bacon decomposition...")

df_bacon <- state_year %>%
  filter(year >= 2010, year <= 2022) %>%
  filter(!is.na(emp_rate_lowwage)) %>%
  mutate(
    treated = as.integer(post)
  )

# Bacon decomposition requires balanced panel
# Identify states with complete data
complete_states <- df_bacon %>%
  group_by(state) %>%
  summarize(n_years = n(), .groups = "drop") %>%
  filter(n_years == max(n_years)) %>%
  pull(state)

df_bacon_balanced <- df_bacon %>%
  filter(state %in% complete_states)

# Run decomposition
bacon_out <- bacon(
  emp_rate_lowwage ~ treated,
  data = df_bacon_balanced,
  id_var = "state",
  time_var = "year"
)

# Summarize by comparison type
bacon_summary <- bacon_out %>%
  group_by(type) %>%
  summarize(
    n_comparisons = n(),
    total_weight = sum(weight),
    weighted_avg_estimate = sum(weight * estimate) / sum(weight),
    .groups = "drop"
  )

message("\nBacon Decomposition Summary:")
print(bacon_summary)

# Save
write_csv(bacon_out, file.path(data_dir, "bacon_decomposition.csv"))
write_csv(bacon_summary, file.path(data_dir, "bacon_summary.csv"))

# =============================================================================
# Part 2: Placebo Test - High-Education Workers
# =============================================================================

message("\nRunning placebo tests...")

# High-education workers should not be affected by minimum wage
placebo_highedu <- feols(
  emp_rate_highedu ~ post | state + year,
  data = state_year %>% filter(year >= 2010, year <= 2022),
  cluster = ~state
)

message("Placebo (High-Education 65+):")
summary(placebo_highedu)

# =============================================================================
# Part 3: Pre-Trends Test
# =============================================================================

message("\nTesting pre-trends...")

# Restrict to pre-treatment period for treated states
df_pretrends <- state_year %>%
  filter(year >= 2010, year <= 2022) %>%
  filter(ever_treated) %>%
  filter(year < first_treat_year) %>%
  mutate(
    years_to_treat = year - first_treat_year
  )

# Linear pre-trend test
pretrend_test <- feols(
  emp_rate_lowwage ~ years_to_treat | state,
  data = df_pretrends,
  cluster = ~state
)

message("Pre-trend coefficient (should be ~0):")
summary(pretrend_test)

# =============================================================================
# Part 4: Alternative Treatment Definitions
# =============================================================================

message("\nAlternative treatment definitions...")

# Treatment intensity: size of MW increase
df_intensity <- state_year %>%
  filter(year >= 2010, year <= 2022) %>%
  mutate(
    mw_gap = log_eff_mw - log(7.25),  # Gap above federal
    mw_gap_post = mw_gap * post
  )

m_intensity <- feols(
  emp_rate_lowwage ~ mw_gap | state + year,
  data = df_intensity,
  cluster = ~state
)

message("Continuous treatment (MW gap):")
summary(m_intensity)

# =============================================================================
# Part 5: Alternative Age Groups
# =============================================================================

message("\nAlternative age groups...")

# Would need individual-level data with finer age cuts
# Placeholder: Compare 65+ to 55-64 (near-elderly)
# Note: Need to re-run data fetch with 55-64 sample

# =============================================================================
# Part 6: Labor Force Participation (extensive margin alternative)
# =============================================================================

message("\nLabor force participation...")

m_lfp <- feols(
  lfp_rate_lowwage ~ post | state + year,
  data = state_year %>% filter(year >= 2010, year <= 2022),
  cluster = ~state
)

message("LFP results:")
summary(m_lfp)

# =============================================================================
# Part 7: Collect all robustness results
# =============================================================================

robustness_results <- data.frame(
  specification = c(
    "Main (Low-Wage Employment)",
    "Placebo (High-Education)",
    "Pre-trend test",
    "Continuous MW (gap)",
    "LFP (Low-Wage)"
  ),
  coefficient = c(
    coef(feols(emp_rate_lowwage ~ post | state + year,
               data = state_year %>% filter(year >= 2010, year <= 2022),
               cluster = ~state))["post"],
    coef(placebo_highedu)["post"],
    coef(pretrend_test)["years_to_treat"],
    coef(m_intensity)["mw_gap"],
    coef(m_lfp)["post"]
  ),
  std_error = c(
    se(feols(emp_rate_lowwage ~ post | state + year,
             data = state_year %>% filter(year >= 2010, year <= 2022),
             cluster = ~state))["post"],
    se(placebo_highedu)["post"],
    se(pretrend_test)["years_to_treat"],
    se(m_intensity)["mw_gap"],
    se(m_lfp)["post"]
  )
) %>%
  mutate(
    p_value = 2 * (1 - pnorm(abs(coefficient / std_error))),
    significant = p_value < 0.05
  )

write_csv(robustness_results, file.path(data_dir, "robustness_results.csv"))

message("\n=== Robustness Summary ===")
print(robustness_results)

message("\nRobustness checks complete.")
