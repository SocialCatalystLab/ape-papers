# ============================================================================
# Paper 129: Revision of APEP-0049 - Transit Funding Discontinuity
# 03_main_analysis.R - RDD estimation and diagnostics
#
# Uses 2010 Census population (running variable) -> 2016-2020 ACS outcomes
# The first stage is SHARP by statute: eligibility at >= 50,000
# ============================================================================

# Source packages from relative path (run from code/ or paper root)
if (file.exists("00_packages.R")) {
  source("00_packages.R")
} else if (file.exists("code/00_packages.R")) {
  source("code/00_packages.R")
} else {
  stop("Cannot find 00_packages.R - run from code/ directory or paper root")
}

# ============================================================================
# 1. LOAD DATA
# ============================================================================

cat("=== Loading Analysis Data ===\n")

analysis_data <- read_csv(file.path(data_dir, "ua_analysis.csv"), show_col_types = FALSE)

cat("Analysis sample:", nrow(analysis_data), "urban areas with complete data\n")
cat("  Above threshold (5307-eligible):", sum(analysis_data$eligible_5307), "\n")
cat("  Below threshold (not eligible):", sum(1 - analysis_data$eligible_5307), "\n")

# ============================================================================
# 2. MCCRARY DENSITY TEST
# ============================================================================

cat("\n=== McCrary Density Test ===\n")
cat("Testing for manipulation of the running variable at threshold...\n")

# Test for manipulation at the threshold using rddensity
density_test <- rddensity(X = analysis_data$running_var, c = 0)

cat("\nDensity Test Results:\n")
cat("  T-statistic:", round(density_test$test$t_jk, 3), "\n")
cat("  P-value:", round(density_test$test$p_jk, 3), "\n")

if (density_test$test$p_jk > 0.05) {
  cat("  Conclusion: No evidence of manipulation (p > 0.05)\n")
  cat("  This supports the validity of the RD design.\n")
} else {
  cat("  WARNING: Evidence of potential manipulation at threshold (p <= 0.05)\n")
  cat("  However, note that Census population is enumerated, not self-reported.\n")
}

# Save density test
mccrary_result <- tibble(
  t_stat = density_test$test$t_jk,
  p_value = density_test$test$p_jk,
  hl = density_test$h[1],
  hr = density_test$h[2]
)
write_csv(mccrary_result, file.path(data_dir, "mccrary_test.csv"))

# ============================================================================
# 3. COVARIATE BALANCE TESTS
# ============================================================================

cat("\n=== Covariate Balance at Threshold ===\n")
cat("Testing smoothness of predetermined covariates...\n")

# Test smoothness of median HH income (predetermined)
if (sum(!is.na(analysis_data$median_hh_income)) > 50) {
  balance_income <- rdrobust(
    y = analysis_data$median_hh_income,
    x = analysis_data$running_var,
    c = 0,
    kernel = "triangular",
    bwselect = "mserd"
  )

  cat("\nMedian Household Income at threshold:\n")
  cat("  RD estimate: $", round(balance_income$coef[1], 0), "\n")
  cat("  Robust SE: $", round(balance_income$se[3], 0), "\n")
  cat("  P-value:", round(balance_income$pv[3], 3), "\n")
  cat("  Bandwidth:", round(balance_income$bws[1, 1], 0), "\n")

  if (balance_income$pv[3] > 0.05) {
    cat("  Conclusion: Income is smooth at threshold (supports validity)\n")
  } else {
    cat("  WARNING: Discontinuity in income at threshold\n")
  }

  # Save balance test
  balance_result <- tibble(
    covariate = "median_hh_income",
    estimate = balance_income$coef[1],
    robust_se = balance_income$se[3],
    p_value = balance_income$pv[3],
    bandwidth = balance_income$bws[1, 1]
  )
  write_csv(balance_result, file.path(data_dir, "balance_test.csv"))
}

# ============================================================================
# 4. MAIN RDD ESTIMATES
# ============================================================================

cat("\n=== Main RDD Estimates ===\n")
cat("Estimating effect of Section 5307 eligibility on outcomes...\n")

# Store all results
results <- list()
results_table <- tibble()

# --- Transit Share ---
cat("\n--- Transit Share (Primary Outcome) ---\n")

rd_transit <- rdrobust(
  y = analysis_data$transit_share,
  x = analysis_data$running_var,
  c = 0,
  kernel = "triangular",
  bwselect = "mserd"
)

cat("  Estimate:", sprintf("%.5f", rd_transit$coef[1]), "\n")
cat("  Robust SE:", sprintf("%.5f", rd_transit$se[3]), "\n")
cat("  Robust p-value:", sprintf("%.3f", rd_transit$pv[3]), "\n")
cat("  95% CI: [", sprintf("%.5f", rd_transit$ci[3, 1]), ",",
    sprintf("%.5f", rd_transit$ci[3, 2]), "]\n")
cat("  Bandwidth:", round(rd_transit$bws[1, 1], 0), "\n")
cat("  N left:", rd_transit$N[1], ", N right:", rd_transit$N[2], "\n")

results$transit <- rd_transit
results_table <- bind_rows(results_table, tibble(
  outcome = "Transit Share",
  estimate = rd_transit$coef[1],
  robust_se = rd_transit$se[3],
  p_value = rd_transit$pv[3],
  ci_lower = rd_transit$ci[3, 1],
  ci_upper = rd_transit$ci[3, 2],
  bandwidth = rd_transit$bws[1, 1],
  n_left = rd_transit$N[1],
  n_right = rd_transit$N[2]
))

# --- Employment Rate ---
cat("\n--- Employment Rate ---\n")

rd_employment <- rdrobust(
  y = analysis_data$employment_rate,
  x = analysis_data$running_var,
  c = 0,
  kernel = "triangular",
  bwselect = "mserd"
)

cat("  Estimate:", sprintf("%.5f", rd_employment$coef[1]), "\n")
cat("  Robust SE:", sprintf("%.5f", rd_employment$se[3]), "\n")
cat("  Robust p-value:", sprintf("%.3f", rd_employment$pv[3]), "\n")
cat("  95% CI: [", sprintf("%.5f", rd_employment$ci[3, 1]), ",",
    sprintf("%.5f", rd_employment$ci[3, 2]), "]\n")
cat("  Bandwidth:", round(rd_employment$bws[1, 1], 0), "\n")
cat("  N left:", rd_employment$N[1], ", N right:", rd_employment$N[2], "\n")

results$employment <- rd_employment
results_table <- bind_rows(results_table, tibble(
  outcome = "Employment Rate",
  estimate = rd_employment$coef[1],
  robust_se = rd_employment$se[3],
  p_value = rd_employment$pv[3],
  ci_lower = rd_employment$ci[3, 1],
  ci_upper = rd_employment$ci[3, 2],
  bandwidth = rd_employment$bws[1, 1],
  n_left = rd_employment$N[1],
  n_right = rd_employment$N[2]
))

# --- No Vehicle Share ---
cat("\n--- No Vehicle Share ---\n")

rd_vehicle <- rdrobust(
  y = analysis_data$no_vehicle_share,
  x = analysis_data$running_var,
  c = 0,
  kernel = "triangular",
  bwselect = "mserd"
)

cat("  Estimate:", sprintf("%.5f", rd_vehicle$coef[1]), "\n")
cat("  Robust SE:", sprintf("%.5f", rd_vehicle$se[3]), "\n")
cat("  Robust p-value:", sprintf("%.3f", rd_vehicle$pv[3]), "\n")
cat("  95% CI: [", sprintf("%.5f", rd_vehicle$ci[3, 1]), ",",
    sprintf("%.5f", rd_vehicle$ci[3, 2]), "]\n")
cat("  Bandwidth:", round(rd_vehicle$bws[1, 1], 0), "\n")
cat("  N left:", rd_vehicle$N[1], ", N right:", rd_vehicle$N[2], "\n")

results$vehicle <- rd_vehicle
results_table <- bind_rows(results_table, tibble(
  outcome = "No Vehicle Share",
  estimate = rd_vehicle$coef[1],
  robust_se = rd_vehicle$se[3],
  p_value = rd_vehicle$pv[3],
  ci_lower = rd_vehicle$ci[3, 1],
  ci_upper = rd_vehicle$ci[3, 2],
  bandwidth = rd_vehicle$bws[1, 1],
  n_left = rd_vehicle$N[1],
  n_right = rd_vehicle$N[2]
))

# --- Long Commute Share ---
cat("\n--- Long Commute Share (45+ minutes) ---\n")

rd_commute <- rdrobust(
  y = analysis_data$long_commute_share,
  x = analysis_data$running_var,
  c = 0,
  kernel = "triangular",
  bwselect = "mserd"
)

cat("  Estimate:", sprintf("%.5f", rd_commute$coef[1]), "\n")
cat("  Robust SE:", sprintf("%.5f", rd_commute$se[3]), "\n")
cat("  Robust p-value:", sprintf("%.3f", rd_commute$pv[3]), "\n")
cat("  95% CI: [", sprintf("%.5f", rd_commute$ci[3, 1]), ",",
    sprintf("%.5f", rd_commute$ci[3, 2]), "]\n")
cat("  Bandwidth:", round(rd_commute$bws[1, 1], 0), "\n")
cat("  N left:", rd_commute$N[1], ", N right:", rd_commute$N[2], "\n")

results$commute <- rd_commute
results_table <- bind_rows(results_table, tibble(
  outcome = "Long Commute Share",
  estimate = rd_commute$coef[1],
  robust_se = rd_commute$se[3],
  p_value = rd_commute$pv[3],
  ci_lower = rd_commute$ci[3, 1],
  ci_upper = rd_commute$ci[3, 2],
  bandwidth = rd_commute$bws[1, 1],
  n_left = rd_commute$N[1],
  n_right = rd_commute$N[2]
))

# ============================================================================
# 5. BANDWIDTH SENSITIVITY
# ============================================================================

cat("\n=== Bandwidth Sensitivity Analysis ===\n")

optimal_bw <- rd_transit$bws[1, 1]
bw_multipliers <- c(0.5, 0.75, 1, 1.5, 2)
bandwidths <- bw_multipliers * optimal_bw

cat("\nTransit Share - Bandwidth Sensitivity:\n")
cat(sprintf("  Optimal bandwidth: %.0f\n", optimal_bw))

bw_results <- tibble()

for (i in seq_along(bandwidths)) {
  bw <- bandwidths[i]
  mult <- bw_multipliers[i]

  rd_bw <- rdrobust(
    y = analysis_data$transit_share,
    x = analysis_data$running_var,
    c = 0,
    h = bw,
    kernel = "triangular"
  )

  cat(sprintf("  %.2fx optimal (h=%6.0f): est=%9.5f, SE=%8.5f, p=%5.3f, N=%d/%d\n",
              mult, bw, rd_bw$coef[1], rd_bw$se[3], rd_bw$pv[3], rd_bw$N[1], rd_bw$N[2]))

  bw_results <- bind_rows(bw_results, tibble(
    multiplier = mult,
    bandwidth = bw,
    estimate = rd_bw$coef[1],
    robust_se = rd_bw$se[3],
    p_value = rd_bw$pv[3],
    n_left = rd_bw$N[1],
    n_right = rd_bw$N[2]
  ))
}

write_csv(bw_results, file.path(data_dir, "bandwidth_sensitivity.csv"))

# ============================================================================
# 6. PLACEBO THRESHOLD TESTS
# ============================================================================

cat("\n=== Placebo Threshold Tests ===\n")
cat("Testing for spurious discontinuities at non-threshold values...\n")

placebo_thresholds <- c(40000, 45000, 55000, 60000)

cat("\nTransit Share at Placebo Thresholds:\n")

placebo_results <- tibble()

for (threshold in placebo_thresholds) {
  # Shift running variable to center at placebo threshold
  placebo_running <- analysis_data$running_var - (threshold - 50000)

  rd_placebo <- try(rdrobust(
    y = analysis_data$transit_share,
    x = placebo_running,
    c = 0,
    kernel = "triangular",
    bwselect = "mserd"
  ), silent = TRUE)

  if (!inherits(rd_placebo, "try-error")) {
    cat(sprintf("  Threshold %d: est=%9.5f, SE=%8.5f, p=%5.3f\n",
                threshold, rd_placebo$coef[1], rd_placebo$se[3], rd_placebo$pv[3]))

    placebo_results <- bind_rows(placebo_results, tibble(
      threshold = threshold,
      estimate = rd_placebo$coef[1],
      robust_se = rd_placebo$se[3],
      p_value = rd_placebo$pv[3]
    ))
  } else {
    cat(sprintf("  Threshold %d: estimation failed\n", threshold))
  }
}

# Add actual threshold for comparison
placebo_results <- bind_rows(
  tibble(threshold = 50000, estimate = rd_transit$coef[1],
         robust_se = rd_transit$se[3], p_value = rd_transit$pv[3]),
  placebo_results
) %>% arrange(threshold)

write_csv(placebo_results, file.path(data_dir, "placebo_thresholds.csv"))

# ============================================================================
# 7. SAVE ALL RESULTS
# ============================================================================

cat("\n=== Saving Results ===\n")

# Main results table
write_csv(results_table, file.path(data_dir, "rdd_results.csv"))

cat("Results saved to:", data_dir, "\n")
cat("Files:\n")
cat("  - rdd_results.csv (main RDD estimates)\n")
cat("  - mccrary_test.csv (density test)\n")
cat("  - balance_test.csv (covariate balance)\n")
cat("  - bandwidth_sensitivity.csv (sensitivity analysis)\n")
cat("  - placebo_thresholds.csv (placebo tests)\n")

cat("\n=== Main Analysis Complete ===\n")

# Print summary
cat("\n=== RESULTS SUMMARY ===\n")
cat("Design: Sharp RD at 50,000 population threshold\n")
cat("Running variable: 2010 Census population\n")
cat("Outcomes: 2016-2020 ACS 5-year estimates\n")
cat("\nMain findings:\n")
for (i in 1:nrow(results_table)) {
  sig <- ifelse(results_table$p_value[i] < 0.05, "*", "")
  cat(sprintf("  %s: %.4f (p=%.3f)%s\n",
              results_table$outcome[i],
              results_table$estimate[i],
              results_table$p_value[i],
              sig))
}
