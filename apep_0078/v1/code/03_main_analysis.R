# ============================================================================
# 03_main_analysis.R
# State Minimum Wage and Business Establishments
# Main difference-in-differences analysis - ANNUAL FREQUENCY
# ============================================================================

source("00_packages.R")

data_dir <- "../data/"
tables_dir <- "../tables/"
dir.create(tables_dir, showWarnings = FALSE, recursive = TRUE)

# ============================================================================
# 1. Load analysis data
# ============================================================================

cat("Loading analysis data...\n")

analysis_panel <- read_csv(paste0(data_dir, "analysis_panel.csv"), show_col_types = FALSE) %>%
  mutate(
    state_fe = as.factor(state_abbr),
    year_fe = as.factor(year)
  )

treatment_timing <- read_csv(paste0(data_dir, "treatment_timing.csv"), show_col_types = FALSE)

cat("  State-year observations: ", nrow(analysis_panel), "\n")
cat("  States: ", n_distinct(analysis_panel$state_abbr), "\n")
cat("  Years: ", n_distinct(analysis_panel$year), "\n")

# ============================================================================
# 2. Two-Way Fixed Effects (TWFE) - Continuous Treatment
# ============================================================================

cat("\n=== TWFE Regressions: Continuous Treatment (Log Real MW) ===\n")

# Model 1: Basic TWFE - log MW on log establishments
m1_continuous <- feols(
  log_establishments ~ log_real_mw | state_fe + year_fe,
  data = analysis_panel,
  cluster = ~state_abbr
)

# Model 2: Add state-specific linear trends
m2_continuous <- feols(
  log_establishments ~ log_real_mw | state_fe + year_fe + state_fe[year],
  data = analysis_panel,
  cluster = ~state_abbr
)

# Display results
cat("\nContinuous Treatment Results:\n")
etable(m1_continuous, m2_continuous,
       headers = c("TWFE", "TWFE + Trends"),
       se.below = TRUE)

# Save to file
sink(paste0(tables_dir, "twfe_continuous.tex"))
etable(m1_continuous, m2_continuous,
       headers = c("(1) TWFE", "(2) TWFE + Trends"),
       tex = TRUE,
       title = "Effect of Minimum Wage on Business Establishments",
       label = "tab:twfe_continuous",
       notes = "Standard errors clustered at state level. Annual state-level data.")
sink()

# ============================================================================
# 3. Two-Way Fixed Effects (TWFE) - Binary Treatment
# ============================================================================

cat("\n=== TWFE Regressions: Binary Treatment (Above Federal) ===\n")

# Model 1: Basic TWFE
m1_binary <- feols(
  log_establishments ~ above_federal | state_fe + year_fe,
  data = analysis_panel,
  cluster = ~state_abbr
)

# Model 2: Add state-specific trends
m2_binary <- feols(
  log_establishments ~ above_federal | state_fe + year_fe + state_fe[year],
  data = analysis_panel,
  cluster = ~state_abbr
)

# Display results
cat("\nBinary Treatment Results:\n")
etable(m1_binary, m2_binary,
       headers = c("TWFE", "TWFE + Trends"),
       se.below = TRUE)

# ============================================================================
# 4. Callaway-Sant'Anna Estimator (EXCLUDING already-treated states)
# ============================================================================

cat("\n=== Callaway-Sant'Anna Estimator ===\n")

# Prepare data for CS - exclude states already treated at sample start
cs_data <- analysis_panel %>%
  filter(!already_treated_at_start | is.na(already_treated_at_start)) %>%
  # Create numeric state ID
  mutate(state_id = as.numeric(as.factor(state_abbr))) %>%
  # Cohort = 0 for never-treated
  mutate(
    cohort = if_else(is.na(cohort_year) | is.infinite(first_treat_year), 0, as.integer(cohort_year))
  )

cat("  CS sample excludes ", sum(analysis_panel$already_treated_at_start, na.rm = TRUE) / n_distinct(analysis_panel$year),
    " states already treated at sample start\n")
cat("  CS sample size: ", nrow(cs_data), " state-years\n")

# Run CS estimator
tryCatch({
  cs_result <- att_gt(
    yname = "log_establishments",
    tname = "year",
    idname = "state_id",
    gname = "cohort",
    data = cs_data,
    control_group = "nevertreated",
    base_period = "universal",
    clustervars = "state_id"
  )

  cat("\nGroup-Time ATT Summary:\n")
  print(summary(cs_result))

  # Aggregate to overall ATT
  cs_agg <- aggte(cs_result, type = "simple")
  cat("\nAggregate ATT:\n")
  print(summary(cs_agg))

  # Event study
  cs_event <- aggte(cs_result, type = "dynamic")
  cat("\nEvent Study ATT:\n")
  print(summary(cs_event))

  # Save CS results
  cs_summary <- data.frame(
    estimator = "Callaway-Sant'Anna",
    outcome = "log_establishments",
    att = cs_agg$overall.att,
    se = cs_agg$overall.se
  )
  write_csv(cs_summary, paste0(tables_dir, "cs_results.csv"))

  # Save event study coefficients
  if (!is.null(cs_event$egt)) {
    event_df <- tibble(
      rel_year = cs_event$egt,
      estimate = cs_event$att.egt,
      se = cs_event$se.egt
    ) %>%
      mutate(
        ci_lower = estimate - 1.96 * se,
        ci_upper = estimate + 1.96 * se
      )
    write_csv(event_df, paste0(tables_dir, "event_study_coefs.csv"))
  }

}, error = function(e) {
  cat("Error in CS estimation: ", e$message, "\n")
  cat("Proceeding with TWFE results only.\n")
})

# ============================================================================
# 5. Goodman-Bacon Decomposition
# ============================================================================

cat("\n=== Goodman-Bacon Decomposition ===\n")

# Prepare data
bacon_data <- cs_data %>%
  filter(!is.na(log_establishments)) %>%
  mutate(treated = if_else(cohort > 0 & year >= cohort, 1, 0))

tryCatch({
  bacon_result <- bacon(
    log_establishments ~ treated,
    data = bacon_data,
    id_var = "state_id",
    time_var = "year"
  )

  cat("\nBacon Decomposition:\n")
  print(summary(bacon_result))

  write_csv(bacon_result, paste0(tables_dir, "bacon_decomposition.csv"))

}, error = function(e) {
  cat("Error in Bacon decomposition: ", e$message, "\n")
})

# ============================================================================
# 6. Event Study - TWFE (excluding already-treated states)
# ============================================================================

cat("\n=== Event Study (excluding already-treated states) ===\n")

event_data <- analysis_panel %>%
  filter(!already_treated_at_start | is.na(already_treated_at_start)) %>%
  filter(!is.na(event_time)) %>%
  mutate(
    # Bin event time
    event_time_binned = case_when(
      event_time < -5 ~ -5,
      event_time > 5 ~ 5,
      TRUE ~ event_time
    )
  )

# Run event study regression
if (nrow(event_data) > 0) {
  event_study <- feols(
    log_establishments ~ i(event_time_binned, ref = -1) | state_abbr + year,
    data = event_data,
    cluster = ~state_abbr
  )

  cat("\nEvent Study Results:\n")
  etable(event_study)

  # Save event study coefficients
  event_coefs <- coef(event_study)
  event_se <- se(event_study)

  if (length(event_coefs) > 0) {
    event_df_twfe <- tibble(
      rel_year = as.numeric(gsub("event_time_binned::", "", names(event_coefs))),
      estimate = event_coefs,
      se = event_se
    ) %>%
      mutate(
        ci_lower = estimate - 1.96 * se,
        ci_upper = estimate + 1.96 * se
      ) %>%
      arrange(rel_year)

    write_csv(event_df_twfe, paste0(tables_dir, "event_study_twfe.csv"))
  }
}

# ============================================================================
# 7. Save main results table
# ============================================================================

cat("\n=== Saving Main Results ===\n")

main_results <- tibble(
  model = c("TWFE Continuous", "TWFE Continuous + Trends",
            "TWFE Binary", "TWFE Binary + Trends"),
  outcome = rep("log_establishments", 4),
  coefficient = c(coef(m1_continuous)["log_real_mw"],
                  coef(m2_continuous)["log_real_mw"],
                  coef(m1_binary)["above_federalTRUE"],
                  coef(m2_binary)["above_federalTRUE"]),
  se = c(se(m1_continuous)["log_real_mw"],
         se(m2_continuous)["log_real_mw"],
         se(m1_binary)["above_federalTRUE"],
         se(m2_binary)["above_federalTRUE"]),
  n_obs = c(nobs(m1_continuous), nobs(m2_continuous),
            nobs(m1_binary), nobs(m2_binary))
) %>%
  mutate(
    stars = case_when(
      abs(coefficient / se) > 2.576 ~ "***",
      abs(coefficient / se) > 1.96 ~ "**",
      abs(coefficient / se) > 1.645 ~ "*",
      TRUE ~ ""
    )
  )

print(main_results)
write_csv(main_results, paste0(tables_dir, "main_results.csv"))

cat("\nMain analysis complete!\n")
cat("Results saved to: ", tables_dir, "\n")
cat("NOTE: Analysis at STATE-YEAR level (", nrow(analysis_panel), " observations)\n")
