# ==============================================================================
# Paper 86: Minimum Wage and Teen Time Allocation
# 09_modern_did.R - Modern DiD Estimators (CS, SA) vs TWFE Comparison
# ==============================================================================

source("00_packages.R")

# Install/load additional packages for modern DiD
if (!require("did")) install.packages("did")
if (!require("fixest")) install.packages("fixest")
if (!require("ggplot2")) install.packages("ggplot2")

library(did)
library(fixest)
library(ggplot2)
library(data.table)

cat("\n=== Modern DiD Estimators vs TWFE ===\n")
cat("Implementing Callaway-Sant'Anna and Sun-Abraham estimators\n")
cat("Comparing to TWFE to detect heterogeneous treatment effects bias\n\n")

# Load data
data_dir <- "../data"
df <- readRDS(file.path(data_dir, "analysis_data.rds"))

# Filter to analysis sample (2010-2023: federal MW constant at $7.25)
df <- df[YEAR >= 2010 & YEAR < 2024]

# Remove observations with missing weights
df <- df[!is.na(weight) & weight > 0]

cat("Analysis sample:", nrow(df), "observations\n")
cat("Years:", min(df$YEAR), "-", max(df$YEAR), "\n")
cat("States:", uniqueN(df$STATEFIP), "\n")

# ==============================================================================
# 1. Prepare Treatment Timing Variables
# ==============================================================================

cat("\n--- Preparing Treatment Timing ---\n")

# Create year-level first treatment
df[, year := YEAR]
df[first_treat_ym > 0, first_treat_year := floor(first_treat_ym / 12)]
df[first_treat_ym == 0, first_treat_year := 0]  # Never treated

# Cohort summary
cohorts <- df[, .(
  n_obs = .N,
  n_states = uniqueN(STATEFIP)
), by = first_treat_year][order(first_treat_year)]

cat("\nTreatment cohorts:\n")
print(cohorts)

# Count switchers vs always-treated vs never-treated
never_treated_states <- df[first_treat_year == 0, uniqueN(STATEFIP)]
always_treated_states <- df[first_treat_year > 0 & first_treat_year < 2010, uniqueN(STATEFIP)]
switcher_states <- df[first_treat_year >= 2010, uniqueN(STATEFIP)]

cat("\nTreatment groups:\n")
cat("  Never treated:", never_treated_states, "states\n")
cat("  Always treated (pre-2010):", always_treated_states, "states\n")
cat("  Switchers (2010-2023):", switcher_states, "states\n")

# ==============================================================================
# 2. Aggregate to State-Year Level (for CS estimator)
# ==============================================================================

cat("\n--- Aggregating to State-Year Panel ---\n")

# CS requires panel data; ATUS is repeated cross-section
# Aggregate outcomes to state-year level with proper weighting

state_year <- df[, .(
  # Employment outcomes
  employed = weighted.mean(employed, weight, na.rm = TRUE),
  employed_n = sum(employed * weight, na.rm = TRUE),
  total_weight = sum(weight, na.rm = TRUE),
  n_obs = .N,

  # Time use outcomes (if available)
  work_time = weighted.mean(work_time, weight, na.rm = TRUE),
  educ_time = weighted.mean(educ_time, weight, na.rm = TRUE),
  leisure_time = weighted.mean(leisure_time, weight, na.rm = TRUE),

  # Extensive margin for work time (any work > 0)
  any_work = weighted.mean(work_time > 0, weight, na.rm = TRUE),

  # Treatment
  mw_above_federal = max(mw_above_federal),
  effective_mw = max(effective_mw),
  log_mw = log(max(effective_mw)),
  mw_gap = max(mw_gap),
  first_treat_year = first(first_treat_year)
), by = .(STATEFIP, YEAR)]

# Add numeric state ID for CS
state_year[, state_id := as.numeric(factor(STATEFIP))]

cat("State-year panel:", nrow(state_year), "observations\n")
cat("States:", uniqueN(state_year$STATEFIP), "\n")
cat("Years:", min(state_year$YEAR), "-", max(state_year$YEAR), "\n")

# Check cell sizes
cat("\nObservations per state-year cell:\n")
print(summary(state_year$n_obs))

# ==============================================================================
# 3. TWFE Baseline Estimates
# ==============================================================================

cat("\n" , strrep("=", 60), "\n")
cat("3. TWFE BASELINE ESTIMATES\n")
cat(strrep("=", 60), "\n")

# --- Employment (EMPSTAT) ---
cat("\n--- A. Employment (EMPSTAT) ---\n")

# Individual-level TWFE
twfe_emp_ind <- feols(
  employed ~ mw_above_federal | STATEFIP + YEAR,
  data = df,
  weights = ~weight,
  cluster = ~STATEFIP
)

# With year x month FE
df[, year_month_fe := paste(YEAR, MONTH, sep = "_")]
twfe_emp_ym <- feols(
  employed ~ mw_above_federal | STATEFIP + year_month_fe,
  data = df,
  weights = ~weight,
  cluster = ~STATEFIP
)

cat("\nTWFE (Year FE):\n")
cat("  Coefficient:", round(coef(twfe_emp_ind)["mw_above_federalTRUE"], 4), "\n")
cat("  SE:", round(se(twfe_emp_ind)["mw_above_federalTRUE"], 4), "\n")

cat("\nTWFE (Year×Month FE):\n")
cat("  Coefficient:", round(coef(twfe_emp_ym)["mw_above_federalTRUE"], 4), "\n")
cat("  SE:", round(se(twfe_emp_ym)["mw_above_federalTRUE"], 4), "\n")

# State-year level TWFE (for comparison with CS)
twfe_emp_sy <- feols(
  employed ~ mw_above_federal | STATEFIP + YEAR,
  data = state_year,
  cluster = ~STATEFIP
)

cat("\nTWFE (State-Year aggregated):\n")
cat("  Coefficient:", round(coef(twfe_emp_sy)["mw_above_federalTRUE"], 4), "\n")
cat("  SE:", round(se(twfe_emp_sy)["mw_above_federalTRUE"], 4), "\n")

# --- Work Time (Diary-Day Minutes) ---
cat("\n--- B. Work Time (Diary-Day Minutes) ---\n")

# Check if work_time is available
if (all(is.na(df$work_time))) {
  cat("NOTE: work_time not available in data extract.\n")
  cat("Using employment as proxy for primary analysis.\n")
  has_work_time <- FALSE
} else {
  has_work_time <- TRUE

  twfe_wt_ind <- feols(
    work_time ~ mw_above_federal | STATEFIP + YEAR,
    data = df,
    weights = ~weight,
    cluster = ~STATEFIP
  )

  twfe_wt_ym <- feols(
    work_time ~ mw_above_federal | STATEFIP + year_month_fe,
    data = df,
    weights = ~weight,
    cluster = ~STATEFIP
  )

  cat("\nTWFE Work Time (Year FE):\n")
  cat("  Coefficient:", round(coef(twfe_wt_ind)["mw_above_federalTRUE"], 2), "minutes\n")
  cat("  SE:", round(se(twfe_wt_ind)["mw_above_federalTRUE"], 2), "\n")

  cat("\nTWFE Work Time (Year×Month FE):\n")
  cat("  Coefficient:", round(coef(twfe_wt_ym)["mw_above_federalTRUE"], 2), "minutes\n")
  cat("  SE:", round(se(twfe_wt_ym)["mw_above_federalTRUE"], 2), "\n")
}

# ==============================================================================
# 4. Callaway-Sant'Anna Estimator
# ==============================================================================

cat("\n" , strrep("=", 60), "\n")
cat("4. CALLAWAY-SANT'ANNA ESTIMATOR\n")
cat(strrep("=", 60), "\n")

# Prepare data for CS
# Need: panel with id, time, first_treat (0 for never-treated), outcome

# Filter to states with valid timing
# CS needs: never-treated (first_treat_year == 0) OR switchers within sample
cs_data <- state_year[first_treat_year == 0 | first_treat_year >= 2010]

cat("\nCS sample:\n")
cat("  States:", uniqueN(cs_data$STATEFIP), "\n")
cat("  State-years:", nrow(cs_data), "\n")

# Set first_treat_year to Inf for never-treated (CS convention)
# Actually CS uses 0 for never-treated, let's check
cat("\nCohort distribution in CS sample:\n")
print(cs_data[, .N, by = first_treat_year][order(first_treat_year)])

# --- Employment with CS ---
cat("\n--- A. Employment (Callaway-Sant'Anna) ---\n")

tryCatch({
  cs_emp <- att_gt(
    yname = "employed",
    tname = "YEAR",
    idname = "state_id",
    gname = "first_treat_year",
    data = cs_data,
    control_group = "nevertreated",  # Use only never-treated as controls
    anticipation = 0,
    base_period = "varying",
    print_details = FALSE
  )

  # Aggregate to overall ATT
  cs_emp_agg <- aggte(cs_emp, type = "simple")

  cat("\nCS Overall ATT (Employment):\n")
  cat("  ATT:", round(cs_emp_agg$overall.att, 4), "\n")
  cat("  SE:", round(cs_emp_agg$overall.se, 4), "\n")
  cat("  95% CI: [", round(cs_emp_agg$overall.att - 1.96*cs_emp_agg$overall.se, 4), ", ",
      round(cs_emp_agg$overall.att + 1.96*cs_emp_agg$overall.se, 4), "]\n")

  # Dynamic/event study aggregation
  cs_emp_dyn <- aggte(cs_emp, type = "dynamic", min_e = -5, max_e = 5)

  cat("\nCS Event Study (Employment):\n")
  print(data.frame(
    event_time = cs_emp_dyn$egt,
    att = round(cs_emp_dyn$att.egt, 4),
    se = round(cs_emp_dyn$se.egt, 4)
  ))

  # Group-time effects
  cs_emp_group <- aggte(cs_emp, type = "group")
  cat("\nCS Group-Specific ATTs:\n")
  print(data.frame(
    cohort = cs_emp_group$egt,
    att = round(cs_emp_group$att.egt, 4),
    se = round(cs_emp_group$se.egt, 4)
  ))

  # Save CS results
  saveRDS(cs_emp, file.path(data_dir, "cs_employment.rds"))
  saveRDS(cs_emp_dyn, file.path(data_dir, "cs_employment_dynamic.rds"))

  cs_emp_success <- TRUE

}, error = function(e) {
  cat("\nCS estimation failed:", conditionMessage(e), "\n")
  cat("This may be due to insufficient variation or unbalanced panel.\n")
  cs_emp_success <<- FALSE
})

# --- Work Time with CS (if available) ---
if (has_work_time) {
  cat("\n--- B. Work Time (Callaway-Sant'Anna) ---\n")

  tryCatch({
    cs_wt <- att_gt(
      yname = "work_time",
      tname = "YEAR",
      idname = "state_id",
      gname = "first_treat_year",
      data = cs_data[!is.na(work_time)],
      control_group = "nevertreated",
      anticipation = 0,
      base_period = "varying",
      print_details = FALSE
    )

    cs_wt_agg <- aggte(cs_wt, type = "simple")

    cat("\nCS Overall ATT (Work Time):\n")
    cat("  ATT:", round(cs_wt_agg$overall.att, 2), "minutes\n")
    cat("  SE:", round(cs_wt_agg$overall.se, 2), "\n")

    saveRDS(cs_wt, file.path(data_dir, "cs_worktime.rds"))

  }, error = function(e) {
    cat("\nCS work time estimation failed:", conditionMessage(e), "\n")
  })
}

# ==============================================================================
# 5. Sun-Abraham Estimator (via fixest::sunab)
# ==============================================================================

cat("\n" , strrep("=", 60), "\n")
cat("5. SUN-ABRAHAM ESTIMATOR\n")
cat(strrep("=", 60), "\n")

# Sun-Abraham uses interaction-weighted estimator
# fixest::sunab() implements this

# Prepare cohort variable for sunab
# sunab expects: cohort variable where never-treated = Inf (or large value)

df[, cohort := fifelse(first_treat_year == 0, 10000, first_treat_year)]

# Filter to exclude always-treated (no pre-period)
sa_data <- df[first_treat_year == 0 | first_treat_year >= 2010]

cat("\nSA sample:", nrow(sa_data), "observations\n")
cat("Cohorts in SA sample:\n")
print(sa_data[, .N, by = cohort][order(cohort)])

# --- Employment with Sun-Abraham ---
cat("\n--- A. Employment (Sun-Abraham) ---\n")

tryCatch({
  # Sun-Abraham via fixest
  sa_emp <- feols(
    employed ~ sunab(cohort, YEAR, ref.p = -1) | STATEFIP + YEAR,
    data = sa_data,
    weights = ~weight,
    cluster = ~STATEFIP
  )

  cat("\nSun-Abraham Event Study (Employment):\n")
  print(summary(sa_emp))

  # Extract aggregate ATT from SA
  # sunab returns coefficients for each cohort x relative-time
  sa_coefs <- coef(sa_emp)
  sa_ses <- se(sa_emp)

  # Get post-treatment coefficients (positive relative time)
  post_coefs <- sa_coefs[grep("cohort::", names(sa_coefs))]
  post_coefs <- post_coefs[!grepl("::-", names(post_coefs))]  # Exclude pre-treatment

  if (length(post_coefs) > 0) {
    sa_att <- mean(post_coefs, na.rm = TRUE)
    cat("\nSA Average Post-Treatment Effect:", round(sa_att, 4), "\n")
  }

  saveRDS(sa_emp, file.path(data_dir, "sa_employment.rds"))
  sa_emp_success <- TRUE

}, error = function(e) {
  cat("\nSA estimation failed:", conditionMessage(e), "\n")
  sa_emp_success <<- FALSE
})

# --- Work Time with Sun-Abraham ---
if (has_work_time) {
  cat("\n--- B. Work Time (Sun-Abraham) ---\n")

  tryCatch({
    sa_wt <- feols(
      work_time ~ sunab(cohort, YEAR, ref.p = -1) | STATEFIP + YEAR,
      data = sa_data[!is.na(work_time)],
      weights = ~weight,
      cluster = ~STATEFIP
    )

    cat("\nSun-Abraham Event Study (Work Time):\n")
    print(summary(sa_wt))

    saveRDS(sa_wt, file.path(data_dir, "sa_worktime.rds"))

  }, error = function(e) {
    cat("\nSA work time estimation failed:", conditionMessage(e), "\n")
  })
}

# ==============================================================================
# 6. TWFE Event Study (for comparison)
# ==============================================================================

cat("\n" , strrep("=", 60), "\n")
cat("6. TWFE EVENT STUDY (for comparison)\n")
cat(strrep("=", 60), "\n")

# Create event time
sa_data[first_treat_year > 0, event_time := YEAR - first_treat_year]
sa_data[first_treat_year == 0, event_time := NA]

# Bin event time
sa_data[, event_time_bin := event_time]
sa_data[event_time < -5, event_time_bin := -5]
sa_data[event_time > 5, event_time_bin := 5]

# TWFE event study
twfe_es <- feols(
  employed ~ i(event_time_bin, ref = -1) | STATEFIP + YEAR,
  data = sa_data[!is.na(event_time_bin)],
  weights = ~weight,
  cluster = ~STATEFIP
)

cat("\nTWFE Event Study:\n")
print(summary(twfe_es))

# ==============================================================================
# 7. Comparison Table: TWFE vs Modern DiD
# ==============================================================================

cat("\n" , strrep("=", 60), "\n")
cat("7. COMPARISON: TWFE vs MODERN DiD ESTIMATORS\n")
cat(strrep("=", 60), "\n")

comparison <- data.table(
  Estimator = character(),
  Outcome = character(),
  Coefficient = numeric(),
  SE = numeric(),
  CI_lower = numeric(),
  CI_upper = numeric()
)

# Add TWFE results
comparison <- rbind(comparison, data.table(
  Estimator = "TWFE (Year FE)",
  Outcome = "Employment",
  Coefficient = coef(twfe_emp_ind)["mw_above_federalTRUE"],
  SE = se(twfe_emp_ind)["mw_above_federalTRUE"],
  CI_lower = coef(twfe_emp_ind)["mw_above_federalTRUE"] - 1.96 * se(twfe_emp_ind)["mw_above_federalTRUE"],
  CI_upper = coef(twfe_emp_ind)["mw_above_federalTRUE"] + 1.96 * se(twfe_emp_ind)["mw_above_federalTRUE"]
))

comparison <- rbind(comparison, data.table(
  Estimator = "TWFE (Year×Month FE)",
  Outcome = "Employment",
  Coefficient = coef(twfe_emp_ym)["mw_above_federalTRUE"],
  SE = se(twfe_emp_ym)["mw_above_federalTRUE"],
  CI_lower = coef(twfe_emp_ym)["mw_above_federalTRUE"] - 1.96 * se(twfe_emp_ym)["mw_above_federalTRUE"],
  CI_upper = coef(twfe_emp_ym)["mw_above_federalTRUE"] + 1.96 * se(twfe_emp_ym)["mw_above_federalTRUE"]
))

# Add CS results if successful
if (exists("cs_emp_agg")) {
  comparison <- rbind(comparison, data.table(
    Estimator = "Callaway-Sant'Anna",
    Outcome = "Employment",
    Coefficient = cs_emp_agg$overall.att,
    SE = cs_emp_agg$overall.se,
    CI_lower = cs_emp_agg$overall.att - 1.96 * cs_emp_agg$overall.se,
    CI_upper = cs_emp_agg$overall.att + 1.96 * cs_emp_agg$overall.se
  ))
}

cat("\n--- Comparison Table ---\n")
print(comparison[, .(
  Estimator,
  Outcome,
  Coefficient = round(Coefficient, 4),
  SE = round(SE, 4),
  `95% CI` = paste0("[", round(CI_lower, 4), ", ", round(CI_upper, 4), "]")
)])

# Calculate difference between TWFE and CS
if (exists("cs_emp_agg")) {
  twfe_coef <- coef(twfe_emp_ind)["mw_above_federalTRUE"]
  cs_coef <- cs_emp_agg$overall.att
  diff <- twfe_coef - cs_coef

  cat("\n--- TWFE vs CS Comparison ---\n")
  cat("TWFE coefficient:", round(twfe_coef, 4), "\n")
  cat("CS coefficient:", round(cs_coef, 4), "\n")
  cat("Difference (TWFE - CS):", round(diff, 4), "\n")

  if (abs(diff) > 0.01) {
    cat("\nNOTE: Meaningful difference detected!\n")
    cat("This suggests potential bias from heterogeneous/dynamic treatment effects.\n")
  } else {
    cat("\nNOTE: Small difference suggests TWFE bias is minimal in this setting.\n")
  }
}

# ==============================================================================
# 8. Create Event Study Figure (Primary Outcome)
# ==============================================================================

cat("\n--- Creating Event Study Figure ---\n")

# Extract event study coefficients for plotting
if (exists("cs_emp_dyn")) {
  # CS event study
  cs_es_df <- data.frame(
    event_time = cs_emp_dyn$egt,
    estimate = cs_emp_dyn$att.egt,
    se = cs_emp_dyn$se.egt,
    estimator = "Callaway-Sant'Anna"
  )

  # TWFE event study
  twfe_coefs <- coef(twfe_es)
  twfe_ses <- se(twfe_es)
  twfe_es_df <- data.frame(
    event_time = as.numeric(gsub("event_time_bin::", "", names(twfe_coefs))),
    estimate = twfe_coefs,
    se = twfe_ses,
    estimator = "TWFE"
  )

  # Combine
  es_plot_df <- rbind(cs_es_df, twfe_es_df)
  es_plot_df$ci_lower <- es_plot_df$estimate - 1.96 * es_plot_df$se
  es_plot_df$ci_upper <- es_plot_df$estimate + 1.96 * es_plot_df$se

  # Create plot
  p_es <- ggplot(es_plot_df, aes(x = event_time, y = estimate, color = estimator)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "gray50") +
    geom_point(position = position_dodge(width = 0.3), size = 2) +
    geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper),
                  width = 0.2, position = position_dodge(width = 0.3)) +
    scale_color_manual(values = c("Callaway-Sant'Anna" = "#E69F00", "TWFE" = "#0072B2")) +
    labs(
      title = "Event Study: TWFE vs Callaway-Sant'Anna",
      subtitle = "Effect of Minimum Wage on Teen Employment",
      x = "Years Relative to First Treatment",
      y = "Effect on Employment Rate",
      color = "Estimator"
    ) +
    theme_minimal() +
    theme(
      legend.position = "bottom",
      panel.grid.minor = element_blank()
    )

  ggsave(file.path("../figures", "fig_modern_did_comparison.pdf"),
         p_es, width = 8, height = 6)

  cat("Event study figure saved to figures/fig_modern_did_comparison.pdf\n")
}

# ==============================================================================
# 9. Save Results Summary
# ==============================================================================

cat("\n--- Saving Results ---\n")

# Save comparison table
fwrite(comparison, file.path(data_dir, "modern_did_comparison.csv"))

# Save full results summary
results_summary <- list(
  twfe_emp_year = list(
    coef = coef(twfe_emp_ind)["mw_above_federalTRUE"],
    se = se(twfe_emp_ind)["mw_above_federalTRUE"],
    n = nobs(twfe_emp_ind)
  ),
  twfe_emp_yearmonth = list(
    coef = coef(twfe_emp_ym)["mw_above_federalTRUE"],
    se = se(twfe_emp_ym)["mw_above_federalTRUE"],
    n = nobs(twfe_emp_ym)
  )
)

if (exists("cs_emp_agg")) {
  results_summary$cs_emp <- list(
    att = cs_emp_agg$overall.att,
    se = cs_emp_agg$overall.se
  )
}

saveRDS(results_summary, file.path(data_dir, "modern_did_results.rds"))

cat("\nResults saved to data/modern_did_comparison.csv\n")

# ==============================================================================
# 10. Final Summary
# ==============================================================================

cat("\n", strrep("=", 60), "\n")
cat("SUMMARY: MODERN DiD vs TWFE\n")
cat(strrep("=", 60), "\n")

cat("\nKey findings:\n")
cat("1. TWFE (Year FE):", round(coef(twfe_emp_ind)["mw_above_federalTRUE"], 4),
    " (SE =", round(se(twfe_emp_ind)["mw_above_federalTRUE"], 4), ")\n")
cat("2. TWFE (Year×Month FE):", round(coef(twfe_emp_ym)["mw_above_federalTRUE"], 4),
    " (SE =", round(se(twfe_emp_ym)["mw_above_federalTRUE"], 4), ")\n")

if (exists("cs_emp_agg")) {
  cat("3. Callaway-Sant'Anna:", round(cs_emp_agg$overall.att, 4),
      " (SE =", round(cs_emp_agg$overall.se, 4), ")\n")

  cat("\nInterpretation:\n")
  twfe_c <- coef(twfe_emp_ind)["mw_above_federalTRUE"]
  cs_c <- cs_emp_agg$overall.att

  if (abs(twfe_c - cs_c) < 0.01) {
    cat("TWFE and CS estimates are similar, suggesting that bias from\n")
    cat("heterogeneous/dynamic treatment effects is not a major concern\n")
    cat("in this application.\n")
  } else {
    cat("TWFE and CS estimates differ meaningfully, suggesting potential\n")
    cat("bias from heterogeneous treatment effects. CS estimates should be\n")
    cat("preferred as the main specification.\n")
  }
}

cat("\n=== Modern DiD Analysis Complete ===\n")
