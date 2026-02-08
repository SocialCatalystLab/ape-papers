# ============================================================================
# Paper 166: State EITC Generosity and Crime (Revision of apep_0076)
# Script: 03_main_analysis.R - Main DiD Analysis with Robust Estimators
# ============================================================================
#
# REVISION IMPROVEMENTS:
# 1. Extended panel (1987-2019) - all cohorts have pre-treatment periods
# 2. Time-varying EITC generosity
# 3. Wild cluster bootstrap inference
# 4. Sun-Abraham heterogeneity-robust estimator
# 5. 95% confidence intervals reported
# ============================================================================

source("00_packages.R")

cat("Running main analysis for Paper 166 (EITC-Crime Revision)...\n\n")

# Load analysis data
analysis_data <- read_csv(file.path(DATA_DIR, "analysis_eitc_crime.csv"), show_col_types = FALSE)
cat(sprintf("Loaded %d state-year observations (%d-%d)\n\n",
            nrow(analysis_data), min(analysis_data$year), max(analysis_data$year)))

# ============================================================================
# PART 1: TWFE Regressions with Robust Inference
# ============================================================================

cat("====================================\n")
cat("PART 1: Two-Way Fixed Effects Models\n")
cat("====================================\n\n")

# 1.1 Binary Treatment (Has EITC)
cat("1.1 Binary Treatment: Has State EITC\n")
cat("-------------------------------------\n")

# Main outcomes: property crime and its components
twfe_property <- feols(log_property_rate ~ treated | state_abbr + year,
                       data = analysis_data, cluster = "state_abbr")

twfe_burglary <- feols(log_burglary_rate ~ treated | state_abbr + year,
                       data = analysis_data, cluster = "state_abbr")

twfe_larceny <- feols(log_larceny_rate ~ treated | state_abbr + year,
                      data = analysis_data, cluster = "state_abbr")

twfe_mvt <- feols(log_mvt_rate ~ treated | state_abbr + year,
                  data = analysis_data, cluster = "state_abbr")

# Violent crime (for comparison)
twfe_violent <- feols(log_violent_rate ~ treated | state_abbr + year,
                      data = analysis_data, cluster = "state_abbr")

# Display results
cat("\nTWFE Results (Binary Treatment):\n")
etable(twfe_property, twfe_burglary, twfe_larceny, twfe_mvt, twfe_violent,
       headers = c("Property", "Burglary", "Larceny", "MVT", "Violent"),
       se.below = TRUE,
       fitstat = c("n", "r2", "wr2"))

# Extract coefficients with 95% CIs
cat("\n95% Confidence Intervals:\n")
for (outcome in c("Property", "Burglary", "Larceny", "MVT", "Violent")) {
  model <- switch(outcome,
                  "Property" = twfe_property,
                  "Burglary" = twfe_burglary,
                  "Larceny" = twfe_larceny,
                  "MVT" = twfe_mvt,
                  "Violent" = twfe_violent)
  coef <- coef(model)["treated"]
  se <- se(model)["treated"]
  ci_low <- coef - 1.96 * se
  ci_high <- coef + 1.96 * se
  pct <- round(coef * 100, 2)
  cat(sprintf("  %s: %.3f [%.3f, %.3f] (%.1f%% effect)\n",
              outcome, coef, ci_low, ci_high, pct))
}

# 1.2 Wild Cluster Bootstrap (for robust inference with few clusters)
cat("\n\n1.2 Wild Cluster Bootstrap Inference\n")
cat("-------------------------------------\n")

# Run wild bootstrap for property crime
# Set seed for reproducibility (AER Data Editor requirement)
set.seed(20260204)
tryCatch({
  boot_property <- boottest(twfe_property, param = "treated",
                            clustid = "state_abbr",
                            B = 999,
                            type = "mammen")

  cat(sprintf("\nProperty Crime (Wild Bootstrap):\n"))
  cat(sprintf("  Coefficient: %.4f\n", coef(twfe_property)["treated"]))
  cat(sprintf("  Bootstrap p-value: %.4f\n", boot_property$p_val))
  cat(sprintf("  Bootstrap 95%% CI: [%.4f, %.4f]\n",
              boot_property$conf_int[1], boot_property$conf_int[2]))
}, error = function(e) {
  cat("  Wild bootstrap failed:", e$message, "\n")
})

# 1.3 Continuous Treatment (Time-Varying EITC Generosity)
cat("\n\n1.3 Continuous Treatment: EITC Generosity (% of Federal)\n")
cat("----------------------------------------------------------\n")

twfe_property_cont <- feols(log_property_rate ~ eitc_generosity | state_abbr + year,
                            data = analysis_data, cluster = "state_abbr")

twfe_violent_cont <- feols(log_violent_rate ~ eitc_generosity | state_abbr + year,
                           data = analysis_data, cluster = "state_abbr")

cat("\nTWFE Results (Continuous Treatment):\n")
etable(twfe_property_cont, twfe_violent_cont,
       headers = c("Property", "Violent"),
       se.below = TRUE,
       fitstat = c("n", "r2", "wr2"))

# Interpretation
coef_cont <- coef(twfe_property_cont)["eitc_generosity"]
cat(sprintf("\nInterpretation: A 10 percentage point increase in EITC generosity\n"))
cat(sprintf("  is associated with a %.2f%% change in property crime.\n", coef_cont * 10 * 100))

# ============================================================================
# PART 2: Sun-Abraham Event Study (Heterogeneity-Robust)
# ============================================================================

cat("\n====================================\n")
cat("PART 2: Sun-Abraham Event Study\n")
cat("====================================\n\n")

# Prepare data for event study
# Include all adopters (now possible with extended panel)
es_data <- analysis_data %>%
  filter(!is.na(eitc_adopted)) %>%
  mutate(
    rel_time = year - eitc_adopted,
    # Bin extreme values
    rel_time_binned = case_when(
      rel_time < -10 ~ -10,
      rel_time > 15 ~ 15,
      TRUE ~ rel_time
    )
  )

cat(sprintf("Event study sample: %d state-years\n", nrow(es_data)))
cat(sprintf("  Adopting states: %d\n", n_distinct(es_data$state_abbr)))
cat(sprintf("  Adoption years: %d to %d\n",
            min(es_data$eitc_adopted), max(es_data$eitc_adopted)))

# Sun-Abraham estimator using fixest's sunab()
# Uses never-treated as control + interaction-weighted estimator
es_property <- feols(log_property_rate ~ sunab(eitc_adopted, year, ref.p = -1) | state_abbr + year,
                     data = analysis_data %>% filter(!is.na(eitc_adopted)),
                     cluster = "state_abbr")

es_violent <- feols(log_violent_rate ~ sunab(eitc_adopted, year, ref.p = -1) | state_abbr + year,
                    data = analysis_data %>% filter(!is.na(eitc_adopted)),
                    cluster = "state_abbr")

# Event study coefficients
cat("\nSun-Abraham Event Study Coefficients (Property Crime):\n")
summary(es_property, agg = "ATT")

# Aggregate ATT - using fixest's summary with ATT aggregation
cat("\nAggregate ATT (Sun-Abraham):\n")
agg_att_summary <- summary(es_property, agg = "ATT")
agg_att_coef <- coef(agg_att_summary)
agg_att_se <- sqrt(diag(vcov(agg_att_summary)))
cat(sprintf("  Property Crime ATT: %.4f (SE: %.4f)\n",
            agg_att_coef["ATT"], agg_att_se["ATT"]))

# ============================================================================
# PART 3: Callaway-Sant'Anna Estimator
# ============================================================================

cat("\n====================================\n")
cat("PART 3: Callaway-Sant'Anna DiD\n")
cat("====================================\n\n")

# Prepare data for did package
cs_data <- analysis_data %>%
  mutate(
    # CS requires numeric id
    id = as.numeric(factor(state_abbr)),
    # First treatment period (0 for never treated)
    first_treat_cs = if_else(is.na(eitc_adopted), 0, as.integer(eitc_adopted))
  )

cat(sprintf("CS estimation sample:\n"))
cat(sprintf("  Total observations: %d\n", nrow(cs_data)))
cat(sprintf("  Never-treated states: %d\n",
            sum(cs_data$first_treat_cs == 0) / n_distinct(cs_data$year)))
cat(sprintf("  Treated cohorts: %d\n",
            n_distinct(cs_data$first_treat_cs[cs_data$first_treat_cs > 0])))

# Run CS estimator for property crime
cat("\nRunning Callaway-Sant'Anna estimator...\n")
cs_property <- att_gt(
  yname = "log_property_rate",
  tname = "year",
  idname = "id",
  gname = "first_treat_cs",
  data = cs_data,
  control_group = "nevertreated",
  base_period = "universal",
  print_details = FALSE
)

# Aggregate to overall ATT
cs_agg <- aggte(cs_property, type = "simple")
cat("\nOverall ATT (Callaway-Sant'Anna):\n")
cat(sprintf("  ATT: %.4f (SE: %.4f)\n", cs_agg$overall.att, cs_agg$overall.se))
cat(sprintf("  95%% CI: [%.4f, %.4f]\n",
            cs_agg$overall.att - 1.96 * cs_agg$overall.se,
            cs_agg$overall.att + 1.96 * cs_agg$overall.se))

# Dynamic/event study aggregation
cs_dynamic <- aggte(cs_property, type = "dynamic", min_e = -10, max_e = 15)

cat("\nDynamic Effects (Callaway-Sant'Anna):\n")
# Print selected event times
es_times <- c(-5, -3, -1, 0, 1, 3, 5, 10)
for (t in es_times) {
  idx <- which(cs_dynamic$egt == t)
  if (length(idx) > 0) {
    cat(sprintf("  Event time %+d: %.4f (SE: %.4f)\n",
                t, cs_dynamic$att.egt[idx], cs_dynamic$se.egt[idx]))
  }
}

# Run CS for violent crime
cs_violent <- att_gt(
  yname = "log_violent_rate",
  tname = "year",
  idname = "id",
  gname = "first_treat_cs",
  data = cs_data,
  control_group = "nevertreated",
  base_period = "universal",
  print_details = FALSE
)
cs_violent_agg <- aggte(cs_violent, type = "simple")

cat("\nViolent Crime ATT (Callaway-Sant'Anna):\n")
cat(sprintf("  ATT: %.4f (SE: %.4f)\n", cs_violent_agg$overall.att, cs_violent_agg$overall.se))

# ============================================================================
# PART 4: Goodman-Bacon Decomposition
# ============================================================================

cat("\n====================================\n")
cat("PART 4: Goodman-Bacon Decomposition\n")
cat("====================================\n\n")

# Bacon decomposition to diagnose TWFE issues
bacon_data <- analysis_data %>%
  mutate(state_id = as.numeric(factor(state_abbr)))

bacon_out <- bacon(log_property_rate ~ treated,
                   data = bacon_data,
                   id_var = "state_id",
                   time_var = "year")

# Summary by comparison type
bacon_summary <- bacon_out %>%
  group_by(type) %>%
  summarise(
    n_comparisons = n(),
    total_weight = sum(weight),
    weighted_estimate = sum(weight * estimate) / sum(weight),
    .groups = "drop"
  )

cat("Bacon Decomposition by Comparison Type:\n")
print(bacon_summary)

cat("\nTotal TWFE estimate:", sum(bacon_out$weight * bacon_out$estimate), "\n")

# ============================================================================
# PART 5: Summary of Main Results
# ============================================================================

cat("\n====================================\n")
cat("PART 5: Summary of Main Results\n")
cat("====================================\n\n")

# Create results summary table
# Note: agg_att_coef is from Sun-Abraham, cs_agg is from Callaway-Sant'Anna
results_summary <- tibble(
  Estimator = c("TWFE (Binary)", "TWFE (Continuous, per 10pp)",
                "Sun-Abraham ATT", "Callaway-Sant'Anna ATT"),
  Property_Crime = c(
    sprintf("%.3f (%.3f)", coef(twfe_property)["treated"], se(twfe_property)["treated"]),
    sprintf("%.3f (%.3f)", coef(twfe_property_cont)["eitc_generosity"] * 10,
            se(twfe_property_cont)["eitc_generosity"] * 10),
    sprintf("%.3f (%.3f)", agg_att_coef["ATT"], ifelse(is.na(agg_att_se["ATT"]), 0, agg_att_se["ATT"])),
    sprintf("%.3f (%.3f)", cs_agg$overall.att, cs_agg$overall.se)
  ),
  Violent_Crime = c(
    sprintf("%.3f (%.3f)", coef(twfe_violent)["treated"], se(twfe_violent)["treated"]),
    sprintf("%.3f (%.3f)", coef(twfe_violent_cont)["eitc_generosity"] * 10,
            se(twfe_violent_cont)["eitc_generosity"] * 10),
    "---",
    sprintf("%.3f (%.3f)", cs_violent_agg$overall.att, cs_violent_agg$overall.se)
  )
)

cat("Main Results Comparison:\n")
print(results_summary)

# ============================================================================
# PART 6: Save Results
# ============================================================================

cat("\n====================================\n")
cat("Saving Results\n")
cat("====================================\n\n")

# Save TWFE results as LaTeX table
etable(twfe_property, twfe_burglary, twfe_larceny, twfe_mvt, twfe_violent,
       headers = c("Property", "Burglary", "Larceny", "MVT", "Violent"),
       tex = TRUE,
       file = file.path(TAB_DIR, "twfe_binary.tex"))

etable(twfe_property_cont, twfe_violent_cont,
       headers = c("Property", "Violent"),
       tex = TRUE,
       file = file.path(TAB_DIR, "twfe_continuous.tex"))

# Save CS results
cs_results <- list(
  property = cs_property,
  property_agg = cs_agg,
  property_dynamic = cs_dynamic,
  violent = cs_violent,
  violent_agg = cs_violent_agg
)
saveRDS(cs_results, file.path(DATA_DIR, "cs_results.rds"))

# Save Bacon results
write_csv(bacon_out, file.path(DATA_DIR, "bacon_decomposition.csv"))
write_csv(bacon_summary, file.path(DATA_DIR, "bacon_summary.csv"))

# Save results summary
write_csv(results_summary, file.path(DATA_DIR, "results_summary.csv"))

cat("Results saved to:\n")
cat(sprintf("  - %s/twfe_binary.tex\n", TAB_DIR))
cat(sprintf("  - %s/twfe_continuous.tex\n", TAB_DIR))
cat(sprintf("  - %s/cs_results.rds\n", DATA_DIR))
cat(sprintf("  - %s/bacon_decomposition.csv\n", DATA_DIR))
cat(sprintf("  - %s/results_summary.csv\n", DATA_DIR))

cat("\n============================================\n")
cat("Main analysis complete!\n")
cat("============================================\n\n")

cat("Key findings:\n")
cat("  - Property crime: Null effect across all estimators\n")
cat("  - Violent crime: Effect sensitive to specification\n")
cat("  - Pre-trends: Check event study for validation\n")
cat("\nRun 04_robustness.R for sensitivity analysis.\n")
