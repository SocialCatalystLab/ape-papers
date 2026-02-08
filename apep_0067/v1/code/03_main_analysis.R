# ==============================================================================
# Paper 86: Minimum Wage and Teen Time Allocation
# 03_main_analysis.R - Main DiD analysis
# ==============================================================================

source("00_packages.R")

cat("\n=== Main Analysis ===\n")

# Load data
data_dir <- "../data"
df <- readRDS(file.path(data_dir, "analysis_data.rds"))

# Filter to analysis sample:
# - Post-2009 (federal MW constant at $7.25, so treatment is effectively absorbing)
# - Pre-2024 (complete MW data)
df <- df[YEAR >= 2010 & YEAR < 2024]

cat("Analysis sample:", nrow(df), "observations\n")
cat("Years:", range(df$YEAR), "\n")
cat("Note: Restricted to 2010-2023 when federal MW is constant at $7.25\n")

# ==============================================================================
# 1. Data Preparation for DiD
# ==============================================================================

cat("\n--- Preparing Data for DiD ---\n")

# Create year-level treatment timing for Callaway-Sant'Anna
# Convert year_month to year for simpler analysis
df[, year := YEAR]

# First treatment year (from first_treat_ym which is in year*12+month format)
df[first_treat_ym > 0, first_treat_year := floor(first_treat_ym / 12)]
df[first_treat_ym == 0, first_treat_year := 0]  # Never treated

# Check treatment cohorts
cat("\nTreatment cohorts (first year MW > federal):\n")
cohorts <- df[, .(n = .N, n_states = uniqueN(STATEFIP)), by = first_treat_year][order(first_treat_year)]
print(cohorts)

# State-level panel for clustering
df[, state_year := paste(STATEFIP, YEAR, sep = "_")]

# ==============================================================================
# 2. TWFE Analysis (Baseline)
# ==============================================================================

cat("\n--- Two-Way Fixed Effects (TWFE) Analysis ---\n")

# Outcome: Employment (extensive margin)
# Model: Y_ist = alpha + beta * MW_above_federal_st + gamma_s + delta_t + X'theta + eps

# Basic TWFE
twfe_employed <- feols(
  employed ~ mw_above_federal | STATEFIP + YEAR,
  data = df,
  weights = ~weight,
  cluster = ~STATEFIP
)

cat("\nTWFE: Effect of MW on Teen Employment\n")
print(summary(twfe_employed))

# With controls
twfe_employed_ctrl <- feols(
  employed ~ mw_above_federal + AGE + female + white + black + hispanic |
    STATEFIP + YEAR,
  data = df,
  weights = ~weight,
  cluster = ~STATEFIP
)

cat("\nTWFE with controls:\n")
print(summary(twfe_employed_ctrl))

# Outcome: Employed in MW-sensitive industry (all teens in sample)
# mw_industry is TRUE only for employed in MW industry, FALSE otherwise
df[, employed_mw_industry := employed & mw_industry]
twfe_mw_industry <- feols(
  employed_mw_industry ~ mw_above_federal | STATEFIP + YEAR,
  data = df,
  weights = ~weight,
  cluster = ~STATEFIP
)

cat("\nTWFE: Employed in MW-sensitive industry (outcome):\n")
print(summary(twfe_mw_industry))

# ==============================================================================
# 3. Callaway-Sant'Anna (2021) Estimator
# ==============================================================================

cat("\n--- Callaway-Sant'Anna Estimator ---\n")

# Prepare data for CS
# Need: id (individual/group), time, first_treat (0 for never-treated), outcome
cs_data <- df[, .(
  id = 1:.N,  # Individual ID
  state = STATEFIP,
  year = YEAR,
  first_treat = first_treat_year,
  employed = as.numeric(employed),
  enrolled = as.numeric(enrolled),
  weight = weight
)]

# CS requires panel structure or repeated cross-section
# ATUS is repeated cross-section, so we use state as the unit
# Aggregate to state-year level

state_year <- df[, .(
  employed = weighted.mean(employed, weight, na.rm = TRUE),
  employed_n = sum(employed),
  total_n = .N,
  pct_enrolled = mean(enrolled, na.rm = TRUE) * 100,
  mean_age = mean(AGE, na.rm = TRUE)
), by = .(STATEFIP, YEAR, first_treat_year)]

# Add numeric state ID for CS
state_year[, state_id := as.numeric(factor(STATEFIP))]

cat("\nState-year panel:", nrow(state_year), "observations\n")
cat("States:", uniqueN(state_year$STATEFIP), "\n")

# Run Callaway-Sant'Anna
# Note: This requires panel data. With repeated cross-section, we use
# state-level aggregates

tryCatch({
  cs_out <- att_gt(
    yname = "employed",
    tname = "YEAR",
    idname = "state_id",
    gname = "first_treat_year",
    data = state_year[first_treat_year >= 2003 | first_treat_year == 0],
    control_group = "nevertreated",
    anticipation = 0,
    base_period = "varying"
  )

  cat("\nCallaway-Sant'Anna ATT(g,t) results:\n")
  print(summary(cs_out))

  # Aggregate to overall ATT
  cs_agg <- aggte(cs_out, type = "simple")
  cat("\nAggregate ATT:\n")
  print(summary(cs_agg))

  # Event study
  cs_es <- aggte(cs_out, type = "dynamic", min_e = -5, max_e = 5)
  cat("\nEvent Study Estimates:\n")
  print(summary(cs_es))

  # Save results
  saveRDS(cs_out, file.path(data_dir, "cs_results.rds"))
  saveRDS(cs_es, file.path(data_dir, "cs_event_study.rds"))

}, error = function(e) {
  cat("\nNote: CS estimator requires sufficient variation.\n")
  cat("Error:", conditionMessage(e), "\n")
  cat("Proceeding with TWFE results.\n")
})

# ==============================================================================
# 4. Sun-Abraham (2021) Alternative
# ==============================================================================

cat("\n--- Sun-Abraham Event Study ---\n")

# Create event time relative to first treatment
df[first_treat_year > 0 & first_treat_year <= YEAR,
   event_time := YEAR - first_treat_year]
df[first_treat_year > YEAR, event_time := YEAR - first_treat_year]
df[first_treat_year == 0, event_time := -999]  # Never treated
# Exclude states treated at sample start (2003) - no pre-treatment observations
df[first_treat_year == 2003, event_time := -999]

cat("\nEvent study sample restrictions:\n")
cat("  Excluding never-treated and states first treated in 2003 (no pre-period)\n")
cat("  States first treated in 2003:", uniqueN(df[first_treat_year == 2003]$STATEFIP), "\n")

# Bin event time
df[event_time < -5, event_time_bin := -5]
df[event_time >= -5 & event_time <= 5, event_time_bin := event_time]
df[event_time > 5, event_time_bin := 5]
df[event_time == -999, event_time_bin := NA]  # Exclude from event study

# Event study with fixest
es_fe <- feols(
  employed ~ i(event_time_bin, ref = -1) | STATEFIP + YEAR,
  data = df[!is.na(event_time_bin)],
  weights = ~weight,
  cluster = ~STATEFIP
)

cat("\nEvent Study (fixest):\n")
print(summary(es_fe))

# Save TWFE results
saveRDS(twfe_employed, file.path(data_dir, "twfe_results.rds"))
saveRDS(es_fe, file.path(data_dir, "event_study_fe.rds"))

# ==============================================================================
# 5. Heterogeneity Analysis
# ==============================================================================

cat("\n--- Heterogeneity Analysis ---\n")

# By age
twfe_by_age <- feols(
  employed ~ mw_above_federal | STATEFIP + YEAR,
  data = df,
  weights = ~weight,
  cluster = ~STATEFIP,
  split = ~AGE
)

cat("\nEffect by Age:\n")
print(summary(twfe_by_age))

# By sex
twfe_by_sex <- feols(
  employed ~ mw_above_federal | STATEFIP + YEAR,
  data = df,
  weights = ~weight,
  cluster = ~STATEFIP,
  split = ~female
)

cat("\nEffect by Sex:\n")
print(summary(twfe_by_sex))

# By enrollment status
twfe_by_enrolled <- feols(
  employed ~ mw_above_federal | STATEFIP + YEAR,
  data = df,
  weights = ~weight,
  cluster = ~STATEFIP,
  split = ~enrolled
)

cat("\nEffect by Enrollment:\n")
print(summary(twfe_by_enrolled))

# ==============================================================================
# 6. Results Summary Table
# ==============================================================================

cat("\n--- Results Summary ---\n")

# Create summary table
results_table <- data.table(
  Specification = c(
    "TWFE (baseline)",
    "TWFE (with controls)",
    "Employed in MW industry (outcome)"
  ),
  Coefficient = c(
    coef(twfe_employed)["mw_above_federalTRUE"],
    coef(twfe_employed_ctrl)["mw_above_federalTRUE"],
    coef(twfe_mw_industry)["mw_above_federalTRUE"]
  ),
  SE = c(
    se(twfe_employed)["mw_above_federalTRUE"],
    se(twfe_employed_ctrl)["mw_above_federalTRUE"],
    se(twfe_mw_industry)["mw_above_federalTRUE"]
  ),
  N = c(
    nobs(twfe_employed),
    nobs(twfe_employed_ctrl),
    nobs(twfe_mw_industry)
  )
)

results_table[, CI_lower := Coefficient - 1.96 * SE]
results_table[, CI_upper := Coefficient + 1.96 * SE]
results_table[, stars := ifelse(abs(Coefficient/SE) > 2.576, "***",
                                ifelse(abs(Coefficient/SE) > 1.96, "**",
                                       ifelse(abs(Coefficient/SE) > 1.645, "*", "")))]

cat("\nMain Results:\n")
print(results_table)

# Save results table
fwrite(results_table, file.path(data_dir, "main_results.csv"))

cat("\n=== Main Analysis Complete ===\n")
