# ==============================================================================
# Paper 86: Minimum Wage and Teen Time Allocation
# 10_revised_analysis.R - Comprehensive Revision Addressing Reviewer Concerns
# ==============================================================================
#
# Key improvements:
# 1. CS at state-MONTH level (not state-year)
# 2. Continuous treatment (log MW, MW gap) alongside binary
# 3. Extensive margin decomposition (any work vs conditional minutes)
# 4. Event study for PRIMARY outcome (work minutes)
# 5. Wild cluster bootstrap for main outcomes
# ==============================================================================

source("00_packages.R")

# Additional packages
if (!require("did")) install.packages("did", repos = "https://cloud.r-project.org")

library(did)
library(data.table)
library(fixest)
library(ggplot2)

# Wild bootstrap is optional
has_fwildclusterboot <- require("fwildclusterboot", quietly = TRUE)

cat("\n", strrep("=", 70), "\n")
cat("REVISED ANALYSIS - Addressing Reviewer Concerns\n")
cat(strrep("=", 70), "\n")

# Load data
data_dir <- "../data"
df <- readRDS(file.path(data_dir, "analysis_data.rds"))

# Filter to analysis sample (2010-2023: federal MW constant at $7.25)
df <- df[YEAR >= 2010 & YEAR < 2024]
df <- df[!is.na(weight) & weight > 0]

cat("\nAnalysis sample:", nrow(df), "observations\n")
cat("Years:", min(df$YEAR), "-", max(df$YEAR), "\n")
cat("States:", uniqueN(df$STATEFIP), "\n")

# ==============================================================================
# 1. Create Extensive Margin Outcomes
# ==============================================================================

cat("\n--- Creating Extensive Margin Outcomes ---\n")

# Any work on diary day (extensive margin)
df[, any_work := as.numeric(work_time > 0)]

# Minutes conditional on working (intensive margin)
df[, work_time_cond := ifelse(work_time > 0, work_time, NA)]

# Summary stats
cat("\nWork time distribution:\n")
cat("  P(any work on diary day):", round(mean(df$any_work, na.rm = TRUE) * 100, 1), "%\n")
cat("  Mean work minutes (all):", round(mean(df$work_time, na.rm = TRUE), 1), "\n")
cat("  Mean work minutes (if working):", round(mean(df$work_time_cond, na.rm = TRUE), 1), "\n")
cat("  Zeros:", sum(df$work_time == 0), "/", nrow(df),
    "(", round(mean(df$work_time == 0) * 100, 1), "%)\n")

# ==============================================================================
# 2. Create Month-Level Time Variable
# ==============================================================================

cat("\n--- Creating Month-Level Variables ---\n")

# Calendar month (for state-month panel)
df[, calendar_month := (YEAR - 2010) * 12 + MONTH]  # 1 = Jan 2010, 168 = Dec 2023

# First treated month
df[, first_treat_month := first_treat_ym - (2010 * 12)]  # Relative to Jan 2010
df[first_treat_ym == 0, first_treat_month := 0]  # Never treated

cat("Calendar month range:", min(df$calendar_month), "to", max(df$calendar_month), "\n")

# Cohort counts at month level
cohort_months <- df[first_treat_month > 0, .(
  first_month = min(first_treat_month),
  n_obs = .N
), by = STATEFIP][order(first_month)]

cat("\nSwitcher states (first treated month > 0):\n")
print(cohort_months)
cat("Total switcher states:", nrow(cohort_months), "\n")

# ==============================================================================
# 3. Aggregate to State-Month Panel (for CS)
# ==============================================================================

cat("\n--- Aggregating to State-Month Panel ---\n")

state_month <- df[, .(
  # Outcomes
  any_work = weighted.mean(any_work, weight, na.rm = TRUE),
  work_time = weighted.mean(work_time, weight, na.rm = TRUE),
  educ_time = weighted.mean(educ_time, weight, na.rm = TRUE),
  leisure_time = weighted.mean(leisure_time, weight, na.rm = TRUE),
  employed = weighted.mean(employed, weight, na.rm = TRUE),

  # Sample size
  n_obs = .N,
  total_weight = sum(weight, na.rm = TRUE),

  # Treatment
  mw_above_federal = max(mw_above_federal),
  effective_mw = max(effective_mw),
  log_mw = log(max(effective_mw)),
  mw_gap = max(mw_gap),
  first_treat_month = first(first_treat_month)
), by = .(STATEFIP, YEAR, MONTH, calendar_month)]

# Add numeric state ID
state_month[, state_id := as.numeric(factor(STATEFIP))]

cat("State-month panel:", nrow(state_month), "cells\n")
cat("States:", uniqueN(state_month$STATEFIP), "\n")
cat("Mean obs per cell:", round(mean(state_month$n_obs), 1), "\n")

# ==============================================================================
# 4. TWFE with Continuous Treatment
# ==============================================================================

cat("\n", strrep("=", 60), "\n")
cat("4. TWFE WITH CONTINUOUS TREATMENT\n")
cat(strrep("=", 60), "\n")

# Create year-month FE
df[, year_month_fe := paste(YEAR, MONTH, sep = "_")]

# --- A. Binary Treatment ---
cat("\n--- A. Binary Treatment (MW > $7.25) ---\n")

twfe_binary_work <- feols(
  work_time ~ mw_above_federal | STATEFIP + year_month_fe,
  data = df, weights = ~weight, cluster = ~STATEFIP
)

twfe_binary_anywork <- feols(
  any_work ~ mw_above_federal | STATEFIP + year_month_fe,
  data = df, weights = ~weight, cluster = ~STATEFIP
)

cat("\nWork Time (binary treatment):\n")
cat("  Coef:", round(coef(twfe_binary_work)["mw_above_federalTRUE"], 2),
    "min, SE:", round(se(twfe_binary_work)["mw_above_federalTRUE"], 2), "\n")

cat("\nAny Work (binary treatment):\n")
cat("  Coef:", round(coef(twfe_binary_anywork)["mw_above_federalTRUE"], 4),
    ", SE:", round(se(twfe_binary_anywork)["mw_above_federalTRUE"], 4), "\n")

# --- B. Continuous Treatment: Log MW ---
cat("\n--- B. Continuous Treatment: log(MW) ---\n")

twfe_logmw_work <- feols(
  work_time ~ log_mw | STATEFIP + year_month_fe,
  data = df, weights = ~weight, cluster = ~STATEFIP
)

twfe_logmw_anywork <- feols(
  any_work ~ log_mw | STATEFIP + year_month_fe,
  data = df, weights = ~weight, cluster = ~STATEFIP
)

cat("\nWork Time (log MW):\n")
cat("  Coef:", round(coef(twfe_logmw_work)["log_mw"], 2),
    "min per 100% MW increase, SE:", round(se(twfe_logmw_work)["log_mw"], 2), "\n")

cat("\nAny Work (log MW):\n")
cat("  Coef:", round(coef(twfe_logmw_anywork)["log_mw"], 4),
    ", SE:", round(se(twfe_logmw_anywork)["log_mw"], 4), "\n")

# --- C. Continuous Treatment: MW Gap ($) ---
cat("\n--- C. Continuous Treatment: MW Gap ($) ---\n")

twfe_gap_work <- feols(
  work_time ~ mw_gap | STATEFIP + year_month_fe,
  data = df, weights = ~weight, cluster = ~STATEFIP
)

twfe_gap_anywork <- feols(
  any_work ~ mw_gap | STATEFIP + year_month_fe,
  data = df, weights = ~weight, cluster = ~STATEFIP
)

cat("\nWork Time (MW gap):\n")
cat("  Coef:", round(coef(twfe_gap_work)["mw_gap"], 2),
    "min per $1 above federal, SE:", round(se(twfe_gap_work)["mw_gap"], 2), "\n")

cat("\nAny Work (MW gap):\n")
cat("  Coef:", round(coef(twfe_gap_anywork)["mw_gap"], 4),
    ", SE:", round(se(twfe_gap_anywork)["mw_gap"], 4), "\n")

# ==============================================================================
# 5. Callaway-Sant'Anna at State-MONTH Level
# ==============================================================================

cat("\n", strrep("=", 60), "\n")
cat("5. CALLAWAY-SANT'ANNA AT STATE-MONTH LEVEL\n")
cat(strrep("=", 60), "\n")

# Filter to never-treated + switchers (exclude always-treated)
cs_data_month <- state_month[first_treat_month == 0 | first_treat_month > 0]

# For CS, set never-treated first_treat to 0
cs_data_month[first_treat_month == 0, gvar := 0]
cs_data_month[first_treat_month > 0, gvar := first_treat_month]

cat("\nCS sample (state-month):\n")
cat("  Total cells:", nrow(cs_data_month), "\n")
cat("  States:", uniqueN(cs_data_month$STATEFIP), "\n")
cat("  Never-treated states:", uniqueN(cs_data_month[gvar == 0]$STATEFIP), "\n")
cat("  Switcher states:", uniqueN(cs_data_month[gvar > 0]$STATEFIP), "\n")

# Run CS for work_time
cat("\n--- A. Work Time (CS at month level) ---\n")

tryCatch({
  cs_work_month <- att_gt(
    yname = "work_time",
    tname = "calendar_month",
    idname = "state_id",
    gname = "gvar",
    data = cs_data_month,
    control_group = "nevertreated",
    anticipation = 0,
    base_period = "varying",
    print_details = FALSE
  )

  # Aggregate
  cs_work_agg <- aggte(cs_work_month, type = "simple")

  cat("\nCS Overall ATT (Work Time, month-level):\n")
  cat("  ATT:", round(cs_work_agg$overall.att, 2), "minutes\n")
  cat("  SE:", round(cs_work_agg$overall.se, 2), "\n")
  cat("  95% CI: [", round(cs_work_agg$overall.att - 1.96*cs_work_agg$overall.se, 2),
      ", ", round(cs_work_agg$overall.att + 1.96*cs_work_agg$overall.se, 2), "]\n")

  # Event study
  cs_work_dyn <- aggte(cs_work_month, type = "dynamic", min_e = -12, max_e = 12)

  cat("\nCS Event Study (Work Time):\n")
  es_df <- data.frame(
    event_month = cs_work_dyn$egt,
    att = round(cs_work_dyn$att.egt, 2),
    se = round(cs_work_dyn$se.egt, 2)
  )
  print(head(es_df, 10))

  saveRDS(cs_work_month, file.path(data_dir, "cs_work_month.rds"))
  saveRDS(cs_work_dyn, file.path(data_dir, "cs_work_month_dynamic.rds"))

  cs_work_success <- TRUE

}, error = function(e) {
  cat("\nCS work time failed:", conditionMessage(e), "\n")
  cs_work_success <<- FALSE
})

# Run CS for any_work (extensive margin)
cat("\n--- B. Any Work (CS at month level) ---\n")

tryCatch({
  cs_anywork_month <- att_gt(
    yname = "any_work",
    tname = "calendar_month",
    idname = "state_id",
    gname = "gvar",
    data = cs_data_month,
    control_group = "nevertreated",
    anticipation = 0,
    base_period = "varying",
    print_details = FALSE
  )

  cs_anywork_agg <- aggte(cs_anywork_month, type = "simple")

  cat("\nCS Overall ATT (Any Work, month-level):\n")
  cat("  ATT:", round(cs_anywork_agg$overall.att, 4), "\n")
  cat("  SE:", round(cs_anywork_agg$overall.se, 4), "\n")

  saveRDS(cs_anywork_month, file.path(data_dir, "cs_anywork_month.rds"))

}, error = function(e) {
  cat("\nCS any work failed:", conditionMessage(e), "\n")
})

# ==============================================================================
# 6. Event Study for PRIMARY Outcome (Work Minutes)
# ==============================================================================

cat("\n", strrep("=", 60), "\n")
cat("6. EVENT STUDY FOR PRIMARY OUTCOME (WORK MINUTES)\n")
cat(strrep("=", 60), "\n")

# Create event time for work minutes
df[, first_treat_year := floor(first_treat_ym / 12)]
df[first_treat_ym == 0, first_treat_year := 0]

# Event time (years relative to first treatment)
df[first_treat_year > 0, event_time := YEAR - first_treat_year]
df[first_treat_year == 0, event_time := NA]  # Never treated excluded

# Exclude always-treated (first_treat_year < 2010)
df[first_treat_year > 0 & first_treat_year < 2010, event_time := NA]

# Bin event time
df[, event_time_bin := event_time]
df[event_time < -5, event_time_bin := -5]
df[event_time > 5, event_time_bin := 5]

cat("\nEvent study sample (work minutes):\n")
cat("  Observations with valid event time:", sum(!is.na(df$event_time_bin)), "\n")
cat("  Switcher states:", uniqueN(df[!is.na(event_time_bin)]$STATEFIP), "\n")

# TWFE event study for work minutes
es_work <- feols(
  work_time ~ i(event_time_bin, ref = -1) | STATEFIP + YEAR,
  data = df[!is.na(event_time_bin)],
  weights = ~weight,
  cluster = ~STATEFIP
)

cat("\nEvent Study Results (Work Minutes):\n")
print(summary(es_work))

# Event study for any work
es_anywork <- feols(
  any_work ~ i(event_time_bin, ref = -1) | STATEFIP + YEAR,
  data = df[!is.na(event_time_bin)],
  weights = ~weight,
  cluster = ~STATEFIP
)

cat("\nEvent Study Results (Any Work):\n")
print(summary(es_anywork))

# Save
saveRDS(es_work, file.path(data_dir, "event_study_work.rds"))
saveRDS(es_anywork, file.path(data_dir, "event_study_anywork.rds"))

# ==============================================================================
# 7. Wild Cluster Bootstrap for Main Outcomes (if package available)
# ==============================================================================

cat("\n", strrep("=", 60), "\n")
cat("7. WILD CLUSTER BOOTSTRAP FOR MAIN OUTCOMES\n")
cat(strrep("=", 60), "\n")

if (has_fwildclusterboot) {
  # Work time
  cat("\n--- Wild Bootstrap: Work Time ---\n")
  tryCatch({
    boot_work <- boottest(
      twfe_binary_work,
      param = "mw_above_federalTRUE",
      clustid = "STATEFIP",
      B = 999,
      type = "webb"
    )
    cat("  Bootstrap p-value:", round(boot_work$p_val, 4), "\n")
    cat("  Bootstrap 95% CI: [", round(boot_work$conf_int[1], 2), ", ",
        round(boot_work$conf_int[2], 2), "]\n")

    saveRDS(boot_work, file.path(data_dir, "bootstrap_work.rds"))
  }, error = function(e) {
    cat("  Bootstrap failed:", conditionMessage(e), "\n")
  })

  # Any work
  cat("\n--- Wild Bootstrap: Any Work ---\n")
  tryCatch({
    boot_anywork <- boottest(
      twfe_binary_anywork,
      param = "mw_above_federalTRUE",
      clustid = "STATEFIP",
      B = 999,
      type = "webb"
    )
    cat("  Bootstrap p-value:", round(boot_anywork$p_val, 4), "\n")
    cat("  Bootstrap 95% CI: [", round(boot_anywork$conf_int[1], 4), ", ",
        round(boot_anywork$conf_int[2], 4), "]\n")

    saveRDS(boot_anywork, file.path(data_dir, "bootstrap_anywork.rds"))
  }, error = function(e) {
    cat("  Bootstrap failed:", conditionMessage(e), "\n")
  })
} else {
  cat("\nNote: fwildclusterboot not available. Skipping bootstrap inference.\n")
  cat("Using clustered SEs from fixest instead.\n")
}

# ==============================================================================
# 8. Create Comparison Table
# ==============================================================================

cat("\n", strrep("=", 60), "\n")
cat("8. COMPREHENSIVE RESULTS TABLE\n")
cat(strrep("=", 60), "\n")

results <- data.table(
  Outcome = character(),
  Treatment = character(),
  Estimator = character(),
  Estimate = numeric(),
  SE = numeric(),
  N = numeric()
)

# Add all results
results <- rbind(results, data.table(
  Outcome = "Work Time (min)",
  Treatment = "Binary (MW > $7.25)",
  Estimator = "TWFE",
  Estimate = coef(twfe_binary_work)["mw_above_federalTRUE"],
  SE = se(twfe_binary_work)["mw_above_federalTRUE"],
  N = nobs(twfe_binary_work)
))

results <- rbind(results, data.table(
  Outcome = "Work Time (min)",
  Treatment = "log(MW)",
  Estimator = "TWFE",
  Estimate = coef(twfe_logmw_work)["log_mw"],
  SE = se(twfe_logmw_work)["log_mw"],
  N = nobs(twfe_logmw_work)
))

results <- rbind(results, data.table(
  Outcome = "Work Time (min)",
  Treatment = "MW Gap ($)",
  Estimator = "TWFE",
  Estimate = coef(twfe_gap_work)["mw_gap"],
  SE = se(twfe_gap_work)["mw_gap"],
  N = nobs(twfe_gap_work)
))

results <- rbind(results, data.table(
  Outcome = "Any Work (0/1)",
  Treatment = "Binary (MW > $7.25)",
  Estimator = "TWFE",
  Estimate = coef(twfe_binary_anywork)["mw_above_federalTRUE"],
  SE = se(twfe_binary_anywork)["mw_above_federalTRUE"],
  N = nobs(twfe_binary_anywork)
))

results <- rbind(results, data.table(
  Outcome = "Any Work (0/1)",
  Treatment = "log(MW)",
  Estimator = "TWFE",
  Estimate = coef(twfe_logmw_anywork)["log_mw"],
  SE = se(twfe_logmw_anywork)["log_mw"],
  N = nobs(twfe_logmw_anywork)
))

# Add CS results if available
if (exists("cs_work_agg")) {
  results <- rbind(results, data.table(
    Outcome = "Work Time (min)",
    Treatment = "Binary",
    Estimator = "CS (month)",
    Estimate = cs_work_agg$overall.att,
    SE = cs_work_agg$overall.se,
    N = nrow(cs_data_month)
  ))
}

cat("\nComprehensive Results:\n")
print(results[, .(
  Outcome, Treatment, Estimator,
  Estimate = round(Estimate, 3),
  SE = round(SE, 3),
  `95% CI` = paste0("[", round(Estimate - 1.96*SE, 3), ", ", round(Estimate + 1.96*SE, 3), "]"),
  N
)])

fwrite(results, file.path(data_dir, "revised_results.csv"))

# ==============================================================================
# 9. Create Event Study Figure for Work Time
# ==============================================================================

cat("\n--- Creating Event Study Figure ---\n")

# Extract coefficients
es_coef <- broom::tidy(es_work, conf.int = TRUE)
es_coef <- as.data.table(es_coef)
es_coef[, event_time := as.numeric(gsub("event_time_bin::", "", term))]

# Add reference period
ref_row <- data.table(
  term = "event_time_bin::-1",
  estimate = 0, std.error = 0,
  statistic = NA, p.value = NA,
  conf.low = 0, conf.high = 0,
  event_time = -1
)
es_coef <- rbind(es_coef, ref_row)
es_coef <- es_coef[order(event_time)]

# Plot
fig_es_work <- ggplot(es_coef, aes(x = event_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "gray50") +
  geom_point(size = 3, color = "#0072B2") +
  geom_errorbar(aes(ymin = conf.low, ymax = conf.high),
                width = 0.2, color = "#0072B2") +
  scale_x_continuous(breaks = -5:5) +
  labs(
    title = "Event Study: Effect of Minimum Wage on Diary-Day Work Time",
    subtitle = "Primary Outcome (TWFE with Year FE)",
    x = "Years Relative to First MW Increase Above Federal",
    y = "Effect on Work Time (minutes/day)",
    caption = "Notes: Reference period is t=-1. 95% confidence intervals from state-clustered SEs."
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 12),
    plot.subtitle = element_text(size = 10),
    panel.grid.minor = element_blank()
  )

ggsave(file.path("../figures", "fig_event_study_work.pdf"),
       fig_es_work, width = 9, height = 6)
ggsave(file.path("../figures", "fig_event_study_work.png"),
       fig_es_work, width = 9, height = 6, dpi = 300)

cat("Saved: fig_event_study_work.pdf\n")

# ==============================================================================
# 10. Summary
# ==============================================================================

cat("\n", strrep("=", 70), "\n")
cat("REVISED ANALYSIS SUMMARY\n")
cat(strrep("=", 70), "\n")

cat("\nKey improvements implemented:\n")
cat("1. ✓ Extensive margin decomposition (any_work indicator)\n")
cat("2. ✓ Continuous treatment specifications (log MW, MW gap)\n")
cat("3. ✓ Callaway-Sant'Anna at state-MONTH level\n")
cat("4. ✓ Event study for PRIMARY outcome (work minutes)\n")
cat("5. ✓ Wild cluster bootstrap for main outcomes\n")

cat("\nKey findings:\n")
cat("- Work time (binary TWFE):", round(coef(twfe_binary_work)["mw_above_federalTRUE"], 2),
    "min (SE =", round(se(twfe_binary_work)["mw_above_federalTRUE"], 2), ")\n")
cat("- Any work (binary TWFE):", round(coef(twfe_binary_anywork)["mw_above_federalTRUE"], 4),
    "(SE =", round(se(twfe_binary_anywork)["mw_above_federalTRUE"], 4), ")\n")
cat("- Work time (log MW TWFE):", round(coef(twfe_logmw_work)["log_mw"], 2),
    "min per 100% MW increase\n")

cat("\n=== Revised Analysis Complete ===\n")
