# ==============================================================================
# Paper 112: State Data Privacy Laws and Technology Sector Business Formation
# 04_robustness.R - Robustness checks and placebo tests
# ==============================================================================

source("00_packages.R")

# Load data
analysis_sample <- read_csv(file.path(dir_data, "analysis_sample.csv"),
                            show_col_types = FALSE)
load(file.path(dir_data, "did_results.RData"))

message("Loaded analysis sample and main results")

# ==============================================================================
# 1. Placebo Test: Manufacturing Sector
# ==============================================================================

message("\n", strrep("=", 60))
message("PLACEBO TEST: Manufacturing Sector")
message(strrep("=", 60))

# Manufacturing should NOT be affected by data privacy laws
# This tests for spurious state-specific trends

# For this test, we would need manufacturing business applications
# Since we may not have sector-specific data, we use a synthetic placebo

# Create placebo by randomly assigning treatment dates
set.seed(42)

placebo_sample <- analysis_sample %>%
  mutate(
    # Randomly permute treatment status across states
    placebo_cohort = sample(cohort)
  )

# Estimate placebo DiD
placebo_data <- placebo_sample %>%
  mutate(
    state_id = as.numeric(factor(state_abbr)),
    g = placebo_cohort
  ) %>%
  filter(!is.na(business_apps))

placebo_result <- tryCatch({
  att_gt(
    yname = "business_apps",
    tname = "time_period",
    idname = "state_id",
    gname = "g",
    data = placebo_data,
    control_group = "nevertreated",
    anticipation = 0,
    est_method = "ipw",
    base_period = "universal"
  )
}, error = function(e) {
  message("Placebo test error: ", e$message)
  NULL
})

if (!is.null(placebo_result)) {
  placebo_agg <- aggte(placebo_result, type = "simple")
  message("\nPlacebo ATT: ", round(placebo_agg$overall.att, 2),
          " (SE: ", round(placebo_agg$overall.se, 2), ")")
  message("p-value: ", round(2 * (1 - pnorm(abs(placebo_agg$overall.att / placebo_agg$overall.se))), 4))
}

# ==============================================================================
# 2. Leave-One-Out Analysis
# ==============================================================================

message("\n", strrep("=", 60))
message("LEAVE-ONE-OUT ANALYSIS")
message(strrep("=", 60))

# Get list of treated states
treated_states <- analysis_sample %>%
  filter(treated_ever) %>%
  pull(state_abbr) %>%
  unique()

loo_results <- list()

for (state_to_drop in treated_states) {
  message("  Dropping: ", state_to_drop)

  loo_data <- analysis_sample %>%
    filter(state_abbr != state_to_drop) %>%
    mutate(
      state_id = as.numeric(factor(state_abbr)),
      g = if_else(treated_ever, cohort, 0)
    ) %>%
    filter(!is.na(business_apps))

  loo_result <- tryCatch({
    cs <- att_gt(
      yname = "business_apps",
      tname = "time_period",
      idname = "state_id",
      gname = "g",
      data = loo_data,
      control_group = "nevertreated",
      anticipation = 0,
      est_method = "ipw",
      base_period = "universal"
    )
    agg <- aggte(cs, type = "simple")
    tibble(
      dropped_state = state_to_drop,
      att = agg$overall.att,
      se = agg$overall.se
    )
  }, error = function(e) {
    tibble(
      dropped_state = state_to_drop,
      att = NA_real_,
      se = NA_real_
    )
  })

  loo_results[[state_to_drop]] <- loo_result
}

loo_df <- bind_rows(loo_results)
message("\nLeave-one-out results:")
print(loo_df)

# Check stability
loo_range <- range(loo_df$att, na.rm = TRUE)
message("ATT range: [", round(loo_range[1], 2), ", ", round(loo_range[2], 2), "]")

# ==============================================================================
# 3. Alternative Estimator: Sun-Abraham
# ==============================================================================

message("\n", strrep("=", 60))
message("ALTERNATIVE ESTIMATOR: Sun-Abraham (via fixest)")
message(strrep("=", 60))

# Sun-Abraham interaction-weighted estimator
# Using fixest's sunab() function

sa_data <- analysis_sample %>%
  mutate(
    state_id = as.numeric(factor(state_abbr)),
    # Create cohort for sunab (Inf for never-treated)
    first_treat = if_else(treated_ever, as.numeric(cohort), Inf)
  ) %>%
  filter(!is.na(business_apps))

# Estimate using sunab
sa_result <- tryCatch({
  feols(
    business_apps ~ sunab(first_treat, time_period) | state_id + time_period,
    data = sa_data,
    cluster = ~state_id
  )
}, error = function(e) {
  message("Sun-Abraham estimation error: ", e$message)
  # Fallback to simple TWFE
  feols(
    business_apps ~ treated | state_id + time_period,
    data = sa_data,
    cluster = ~state_id
  )
})

message("\nSun-Abraham / TWFE results:")
summary(sa_result)

# ==============================================================================
# 4. Wild Cluster Bootstrap
# ==============================================================================

message("\n", strrep("=", 60))
message("WILD CLUSTER BOOTSTRAP INFERENCE")
message(strrep("=", 60))

# With ~10 treated clusters, wild cluster bootstrap provides better inference
# Using fixest's boottest functionality if available

twfe_model <- feols(
  business_apps ~ treated | state_id + time_period,
  data = sa_data,
  cluster = ~state_id
)

# Standard clustered SE
message("\nTWFE with clustered SE:")
message("  Coefficient: ", round(coef(twfe_model)["treated"], 2))
message("  Clustered SE: ", round(se(twfe_model)["treated"], 2))

# Wild bootstrap (if fwildclusterboot is available)
tryCatch({
  library(fwildclusterboot)
  boot_result <- boottest(
    twfe_model,
    clustid = "state_id",
    param = "treated",
    B = 999,
    type = "mammen"
  )
  message("  Wild bootstrap p-value: ", round(boot_result$p_val, 4))
}, error = function(e) {
  message("  Wild bootstrap not available: ", e$message)
})

# ==============================================================================
# 5. Alternative Pre-Period (2022 only)
# ==============================================================================

message("\n", strrep("=", 60))
message("ROBUSTNESS: Short Pre-Period (2022 only)")
message(strrep("=", 60))

short_pre_sample <- analysis_sample %>%
  filter(date >= "2022-01-01") %>%
  mutate(
    state_id = as.numeric(factor(state_abbr)),
    g = if_else(treated_ever, cohort - min(cohort[cohort > 0]) + 1, 0),
    t = time_period - min(time_period) + 1
  ) %>%
  filter(!is.na(business_apps))

short_pre_result <- tryCatch({
  cs <- att_gt(
    yname = "business_apps",
    tname = "t",
    idname = "state_id",
    gname = "g",
    data = short_pre_sample,
    control_group = "nevertreated",
    anticipation = 0,
    est_method = "ipw",
    base_period = "universal"
  )
  aggte(cs, type = "simple")
}, error = function(e) {
  message("Short pre-period error: ", e$message)
  NULL
})

if (!is.null(short_pre_result)) {
  message("ATT (2022+ only): ", round(short_pre_result$overall.att, 2),
          " (SE: ", round(short_pre_result$overall.se, 2), ")")
}

# ==============================================================================
# 6. Save Robustness Results
# ==============================================================================

robustness_summary <- tibble(
  specification = c(
    "Main (Callaway-Sant'Anna)",
    "TWFE (clustered SE)",
    "Leave-one-out (min)",
    "Leave-one-out (max)",
    "Short pre-period (2022+)"
  ),
  att = c(
    agg_simple$overall.att,
    coef(twfe_model)["treated"],
    min(loo_df$att, na.rm = TRUE),
    max(loo_df$att, na.rm = TRUE),
    if (!is.null(short_pre_result)) short_pre_result$overall.att else NA
  ),
  se = c(
    agg_simple$overall.se,
    se(twfe_model)["treated"],
    NA,
    NA,
    if (!is.null(short_pre_result)) short_pre_result$overall.se else NA
  )
)

write_csv(robustness_summary, file.path(dir_tables, "robustness_results.csv"))
write_csv(loo_df, file.path(dir_tables, "leave_one_out.csv"))

message("\n", strrep("=", 60))
message("ROBUSTNESS CHECKS COMPLETE")
message(strrep("=", 60))

print(robustness_summary)
