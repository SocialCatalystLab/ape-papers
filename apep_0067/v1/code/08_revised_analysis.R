# ==============================================================================
# Paper 86: Minimum Wage and Teen Employment - REVISED ANALYSIS
# 08_revised_analysis.R - Addresses all reviewer concerns
# ==============================================================================
#
# Key revisions per reviewer feedback:
# 1. Modern DiD estimators: Callaway-Sant'Anna, Sun-Abraham
# 2. Year×month fixed effects for seasonality
# 3. Continuous treatment: log(real minimum wage)
# 4. Goodman-Bacon decomposition as diagnostic
# 5. Time-use mechanism outcomes
# 6. Formal heterogeneity tests with interactions
# ==============================================================================

source("00_packages.R")

# Load additional packages for modern DiD
if (!require("bacondecomp")) install.packages("bacondecomp")
library(bacondecomp)

cat("\n========================================\n")
cat("REVISED ANALYSIS - Addressing Reviewer Concerns\n")
cat("========================================\n")

# Load data
data_dir <- "../data"
df <- readRDS(file.path(data_dir, "analysis_data.rds"))
df <- df[YEAR >= 2010 & YEAR < 2024]

cat("Analysis sample:", nrow(df), "observations\n")
cat("Years:", min(df$YEAR), "-", max(df$YEAR), "\n")

# Create year-month identifier for FE
df[, year_month_fe := paste0(YEAR, "_", sprintf("%02d", MONTH))]
df[, month_of_year := factor(MONTH)]

# ==============================================================================
# PART 1: GOODMAN-BACON DECOMPOSITION (Diagnostic)
# ==============================================================================

cat("\n--- 1. Goodman-Bacon Decomposition ---\n")

# Collapse to state-year for decomposition (bacon requires balanced panel)
state_year <- df[, .(
  employed = weighted.mean(employed, weight, na.rm = TRUE),
  mw_above_federal = as.numeric(first(mw_above_federal)),
  log_mw = mean(log_mw, na.rm = TRUE)
), by = .(STATEFIP, YEAR)]

# Convert to integer treatment for bacon
state_year[, treat := as.integer(mw_above_federal)]

# Run decomposition
tryCatch({
  bacon_out <- bacon(employed ~ treat,
                     data = as.data.frame(state_year),
                     id_var = "STATEFIP",
                     time_var = "YEAR")

  cat("\nGoodman-Bacon Decomposition:\n")
  print(summary(bacon_out))

  # Save decomposition
  saveRDS(bacon_out, file.path(data_dir, "bacon_decomp.rds"))

  # What share of weight comes from problematic comparisons?
  cat("\nWeight by comparison type:\n")
  print(aggregate(weight ~ type, data = bacon_out, sum))

}, error = function(e) {
  cat("Bacon decomposition error:", conditionMessage(e), "\n")
})

# ==============================================================================
# PART 2: MODERN DiD ESTIMATORS
# ==============================================================================

cat("\n--- 2. Modern DiD Estimators ---\n")

# Prepare data for Callaway-Sant'Anna
# Need: panel at state-year level with first treatment year
cs_data <- state_year[, .(
  state_id = as.numeric(factor(STATEFIP)),
  year = YEAR,
  employed = employed,
  log_mw = log_mw
), by = .(STATEFIP, YEAR)]

# First treatment year
first_treat <- df[mw_above_federal == TRUE, .(first_treat = min(YEAR)), by = STATEFIP]
cs_data <- merge(cs_data, first_treat, by = "STATEFIP", all.x = TRUE)
cs_data[is.na(first_treat), first_treat := 0]  # Never treated = 0

cat("\nTreatment cohorts:\n")
print(table(cs_data[, .(first_treat = first(first_treat)), by = STATEFIP]$first_treat))

# 2a. Callaway-Sant'Anna
cat("\n--- 2a. Callaway-Sant'Anna ATT ---\n")

tryCatch({
  cs_out <- att_gt(
    yname = "employed",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = cs_data,
    control_group = "nevertreated",
    anticipation = 0,
    base_period = "varying"
  )

  cat("\nGroup-Time ATTs:\n")
  print(summary(cs_out))

  # Aggregate to overall ATT
  cs_simple <- aggte(cs_out, type = "simple")
  cat("\nSimple (overall) ATT:\n")
  print(summary(cs_simple))

  # Dynamic effects (event study)
  cs_dynamic <- aggte(cs_out, type = "dynamic", min_e = -5, max_e = 5)
  cat("\nDynamic Effects (Event Study):\n")
  print(summary(cs_dynamic))

  # Save
  saveRDS(cs_out, file.path(data_dir, "cs_att_gt.rds"))
  saveRDS(cs_simple, file.path(data_dir, "cs_simple.rds"))
  saveRDS(cs_dynamic, file.path(data_dir, "cs_dynamic.rds"))

}, error = function(e) {
  cat("CS estimator error:", conditionMessage(e), "\n")
})

# 2b. Sun-Abraham via fixest
cat("\n--- 2b. Sun-Abraham (Interaction-Weighted) ---\n")

# Create cohort variable
df[, cohort := first_treat_ym]
df[cohort == 0, cohort := Inf]  # Never treated
df[, cohort_year := floor(cohort / 12)]
df[cohort == Inf, cohort_year := 10000]  # Never treated marker

# Sun-Abraham using sunab() in fixest
sa_es <- feols(
  employed ~ sunab(cohort_year, YEAR) | STATEFIP + YEAR,
  data = df[cohort_year > 2009 | cohort_year == 10000],  # Exclude pre-2010 cohorts
  weights = ~weight,
  cluster = ~STATEFIP
)

cat("\nSun-Abraham Event Study:\n")
print(summary(sa_es))
saveRDS(sa_es, file.path(data_dir, "sun_abraham_es.rds"))

# ==============================================================================
# PART 3: SPECIFICATIONS WITH YEAR×MONTH FE AND CONTINUOUS TREATMENT
# ==============================================================================

cat("\n--- 3. Improved Specifications ---\n")

# 3a. Year×Month Fixed Effects (address seasonality)
cat("\n--- 3a. With Year×Month FE ---\n")

twfe_ym <- feols(
  employed ~ mw_above_federal | STATEFIP + year_month_fe,
  data = df,
  weights = ~weight,
  cluster = ~STATEFIP
)
cat("\nTWFE with Year×Month FE (binary treatment):\n")
print(summary(twfe_ym))

# 3b. Continuous treatment: log(real minimum wage)
cat("\n--- 3b. Continuous Treatment: log(MW) ---\n")

twfe_logmw <- feols(
  employed ~ log_mw | STATEFIP + YEAR,
  data = df,
  weights = ~weight,
  cluster = ~STATEFIP
)
cat("\nEffect of log(MW) on employment:\n")
print(summary(twfe_logmw))

twfe_logmw_ym <- feols(
  employed ~ log_mw | STATEFIP + year_month_fe,
  data = df,
  weights = ~weight,
  cluster = ~STATEFIP
)
cat("\nEffect of log(MW) with Year×Month FE:\n")
print(summary(twfe_logmw_ym))

# 3c. MW gap above federal ($ difference)
cat("\n--- 3c. MW Gap ($ above federal) ---\n")

twfe_gap <- feols(
  employed ~ mw_gap | STATEFIP + year_month_fe,
  data = df,
  weights = ~weight,
  cluster = ~STATEFIP
)
cat("\nEffect of MW gap ($ above federal):\n")
print(summary(twfe_gap))

# ==============================================================================
# PART 4: TIME-USE MECHANISM OUTCOMES
# ==============================================================================

cat("\n--- 4. Time-Use Mechanism Analysis (ATUS Advantage) ---\n")

# Key outcomes: educ_time, jobsearch_time, leisure_time
# These tell us HOW teens respond beyond just employment

outcomes <- c("educ_time", "jobsearch_time", "leisure_time", "work_time")

mechanism_results <- list()

for (outcome in outcomes) {
  cat("\nOutcome:", outcome, "\n")

  # Check for missing values
  n_valid <- sum(!is.na(df[[outcome]]))
  cat("  Valid observations:", n_valid, "\n")

  if (n_valid > 1000) {
    # Binary treatment
    mod_binary <- feols(
      as.formula(paste(outcome, "~ mw_above_federal | STATEFIP + year_month_fe")),
      data = df,
      weights = ~weight,
      cluster = ~STATEFIP
    )

    # Continuous treatment
    mod_cont <- feols(
      as.formula(paste(outcome, "~ log_mw | STATEFIP + year_month_fe")),
      data = df,
      weights = ~weight,
      cluster = ~STATEFIP
    )

    mechanism_results[[outcome]] <- list(binary = mod_binary, continuous = mod_cont)

    cat("  Binary (MW > federal): coef =", round(coef(mod_binary)[1], 2),
        ", SE =", round(se(mod_binary)[1], 2), "\n")
    cat("  Continuous (log MW): coef =", round(coef(mod_cont)[1], 2),
        ", SE =", round(se(mod_cont)[1], 2), "\n")
  }
}

saveRDS(mechanism_results, file.path(data_dir, "mechanism_results.rds"))

# ==============================================================================
# PART 5: FORMAL HETEROGENEITY TESTS
# ==============================================================================

cat("\n--- 5. Formal Heterogeneity Tests (Interaction Model) ---\n")

# Instead of separate regressions, use interactions and test equality
df[, age_factor := factor(AGE)]

# Interaction model
hetero_interact <- feols(
  employed ~ mw_above_federal * age_factor | STATEFIP + year_month_fe,
  data = df,
  weights = ~weight,
  cluster = ~STATEFIP
)

cat("\nInteraction Model (MW × Age):\n")
print(summary(hetero_interact))

# Test equality of age effects
cat("\nWald test: Are age effects equal?\n")
# H0: interaction coefficients are all zero
tryCatch({
  wald_test <- wald(hetero_interact, "mw_above_federal.*age_factor")
  print(wald_test)
}, error = function(e) {
  cat("Wald test error:", conditionMessage(e), "\n")
})

# Also test continuous treatment by age
hetero_logmw <- feols(
  employed ~ log_mw * age_factor | STATEFIP + year_month_fe,
  data = df,
  weights = ~weight,
  cluster = ~STATEFIP
)

cat("\nInteraction Model (log MW × Age):\n")
print(summary(hetero_logmw))

saveRDS(hetero_interact, file.path(data_dir, "hetero_interact.rds"))

# ==============================================================================
# PART 6: SUMMARY TABLE WITH 95% CIs
# ==============================================================================

cat("\n--- 6. Results Summary with 95% CIs ---\n")

# Function to extract results with CIs
extract_results <- function(mod, coef_name = NULL) {
  if (is.null(coef_name)) coef_name <- names(coef(mod))[1]
  est <- coef(mod)[coef_name]
  se_val <- se(mod)[coef_name]
  ci_low <- est - 1.96 * se_val
  ci_high <- est + 1.96 * se_val
  data.table(
    coef = round(est, 4),
    se = round(se_val, 4),
    ci_low = round(ci_low, 4),
    ci_high = round(ci_high, 4),
    ci_string = paste0("[", round(ci_low, 3), ", ", round(ci_high, 3), "]"),
    n = nobs(mod)
  )
}

# Main results table
results_summary <- rbind(
  cbind(spec = "TWFE Year FE (baseline)", extract_results(
    feols(employed ~ mw_above_federal | STATEFIP + YEAR, data = df, weights = ~weight, cluster = ~STATEFIP),
    "mw_above_federalTRUE"
  )),
  cbind(spec = "TWFE Year×Month FE", extract_results(twfe_ym, "mw_above_federalTRUE")),
  cbind(spec = "log(MW), Year FE", extract_results(twfe_logmw, "log_mw")),
  cbind(spec = "log(MW), Year×Month FE", extract_results(twfe_logmw_ym, "log_mw")),
  cbind(spec = "MW Gap ($), Year×Month FE", extract_results(twfe_gap, "mw_gap"))
)

cat("\nMain Results with 95% CIs:\n")
print(results_summary)

fwrite(results_summary, file.path(data_dir, "revised_main_results.csv"))

# ==============================================================================
# PART 7: EXPORT KEY ESTIMATES FOR PAPER
# ==============================================================================

cat("\n--- 7. Key Estimates for Paper ---\n")

key_estimates <- list(
  # Main effect (binary, year×month FE)
  main_binary = list(
    coef = coef(twfe_ym)["mw_above_federalTRUE"],
    se = se(twfe_ym)["mw_above_federalTRUE"]
  ),
  # Main effect (continuous)
  main_logmw = list(
    coef = coef(twfe_logmw_ym)["log_mw"],
    se = se(twfe_logmw_ym)["log_mw"]
  ),
  # CS aggregate ATT (if available)
  cs_att = tryCatch({
    cs_simple <- readRDS(file.path(data_dir, "cs_simple.rds"))
    list(coef = cs_simple$overall.att, se = cs_simple$overall.se)
  }, error = function(e) list(coef = NA, se = NA))
)

saveRDS(key_estimates, file.path(data_dir, "key_estimates.rds"))

cat("\nKey estimates saved.\n")
cat("\n========================================\n")
cat("REVISED ANALYSIS COMPLETE\n")
cat("========================================\n")
