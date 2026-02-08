# ============================================================================
# Paper 65: Transit Funding Discontinuity at 50,000 Population Threshold
# 03_main_analysis.R - RDD estimation and diagnostics
# ============================================================================

source("output/paper_65/code/00_packages.R")

# ============================================================================
# 1. LOAD DATA
# ============================================================================

cat("Loading data...\n")

ua_data <- read_csv(file.path(data_dir, "ua_combined.csv"), show_col_types = FALSE)

# Filter to analysis sample with non-missing outcomes
analysis_data <- ua_data %>%
  filter(!is.na(transit_share), !is.na(employment_rate)) %>%
  arrange(running_var)

cat("Analysis sample: ", nrow(analysis_data), " urbanized areas with complete data\n")

# ============================================================================
# 2. MCCRARY DENSITY TEST
# ============================================================================

cat("\n=== McCrary Density Test ===\n")

# Test for manipulation at the threshold using rddensity
density_test <- rddensity(X = analysis_data$running_var, c = 0)

cat("\nDensity Test Results:\n")
cat("  T-statistic:", round(density_test$test$t_jk, 3), "\n")
cat("  P-value:", round(density_test$test$p_jk, 3), "\n")

if (density_test$test$p_jk > 0.05) {
  cat("  Conclusion: No evidence of manipulation (p > 0.05)\n")
} else {
  cat("  WARNING: Evidence of manipulation at threshold (p <= 0.05)\n")
}

# ============================================================================
# 3. COVARIATE BALANCE TESTS
# ============================================================================

cat("\n=== Covariate Balance at Threshold ===\n")

# Test smoothness of predetermined covariates
# Using median HH income as a key predetermined covariate

if (sum(!is.na(analysis_data$median_hh_income)) > 50) {
  balance_income <- rdrobust(
    y = analysis_data$median_hh_income,
    x = analysis_data$running_var,
    c = 0
  )

  cat("\nIncome at threshold:\n")
  cat("  RD estimate:", round(balance_income$coef[1], 0), "\n")
  cat("  Robust SE:", round(balance_income$se[3], 0), "\n")
  cat("  P-value:", round(balance_income$pv[3], 3), "\n")
}

# ============================================================================
# 4. MAIN RDD ESTIMATES
# ============================================================================

cat("\n=== Main RDD Estimates ===\n")

# --- Transit Share ---
cat("\n--- Transit Share (Primary Outcome) ---\n")

rd_transit <- rdrobust(
  y = analysis_data$transit_share,
  x = analysis_data$running_var,
  c = 0,
  kernel = "triangular",
  bwselect = "mserd"  # MSE-optimal bandwidth
)

cat("  Estimate:", round(rd_transit$coef[1], 5), "\n")
cat("  Robust SE:", round(rd_transit$se[3], 5), "\n")
cat("  Robust p-value:", round(rd_transit$pv[3], 3), "\n")
cat("  95% CI: [", round(rd_transit$ci[3, 1], 5), ",", round(rd_transit$ci[3, 2], 5), "]\n")
cat("  Bandwidth:", round(rd_transit$bws[1, 1], 0), "\n")
cat("  N left:", rd_transit$N[1], ", N right:", rd_transit$N[2], "\n")

# Store for later
results <- list()
results$transit <- rd_transit

# --- Employment Rate ---
cat("\n--- Employment Rate ---\n")

rd_employment <- rdrobust(
  y = analysis_data$employment_rate,
  x = analysis_data$running_var,
  c = 0,
  kernel = "triangular",
  bwselect = "mserd"
)

cat("  Estimate:", round(rd_employment$coef[1], 5), "\n")
cat("  Robust SE:", round(rd_employment$se[3], 5), "\n")
cat("  Robust p-value:", round(rd_employment$pv[3], 3), "\n")
cat("  95% CI: [", round(rd_employment$ci[3, 1], 5), ",", round(rd_employment$ci[3, 2], 5), "]\n")
cat("  Bandwidth:", round(rd_employment$bws[1, 1], 0), "\n")

results$employment <- rd_employment

# --- No Vehicle Share ---
cat("\n--- No Vehicle Share ---\n")

rd_vehicle <- rdrobust(
  y = analysis_data$no_vehicle_share,
  x = analysis_data$running_var,
  c = 0,
  kernel = "triangular",
  bwselect = "mserd"
)

cat("  Estimate:", round(rd_vehicle$coef[1], 5), "\n")
cat("  Robust SE:", round(rd_vehicle$se[3], 5), "\n")
cat("  Robust p-value:", round(rd_vehicle$pv[3], 3), "\n")
cat("  95% CI: [", round(rd_vehicle$ci[3, 1], 5), ",", round(rd_vehicle$ci[3, 2], 5), "]\n")
cat("  Bandwidth:", round(rd_vehicle$bws[1, 1], 0), "\n")

results$vehicle <- rd_vehicle

# --- Long Commute Share ---
cat("\n--- Long Commute Share (45+ minutes) ---\n")

rd_commute <- rdrobust(
  y = analysis_data$long_commute_share,
  x = analysis_data$running_var,
  c = 0,
  kernel = "triangular",
  bwselect = "mserd"
)

cat("  Estimate:", round(rd_commute$coef[1], 5), "\n")
cat("  Robust SE:", round(rd_commute$se[3], 5), "\n")
cat("  Robust p-value:", round(rd_commute$pv[3], 3), "\n")
cat("  95% CI: [", round(rd_commute$ci[3, 1], 5), ",", round(rd_commute$ci[3, 2], 5), "]\n")
cat("  Bandwidth:", round(rd_commute$bws[1, 1], 0), "\n")

results$commute <- rd_commute

# ============================================================================
# 5. BANDWIDTH SENSITIVITY
# ============================================================================

cat("\n=== Bandwidth Sensitivity ===\n")

# Transit share with different bandwidths
cat("\nTransit Share - Bandwidth Sensitivity:\n")

optimal_bw <- rd_transit$bws[1, 1]
bandwidths <- c(0.5, 0.75, 1, 1.5, 2) * optimal_bw

for (bw in bandwidths) {
  rd_bw <- rdrobust(
    y = analysis_data$transit_share,
    x = analysis_data$running_var,
    c = 0,
    h = bw,
    kernel = "triangular"
  )
  cat(sprintf("  h = %6.0f: est = %8.5f (SE = %8.5f), p = %5.3f, N = %d/%d\n",
              bw, rd_bw$coef[1], rd_bw$se[3], rd_bw$pv[3], rd_bw$N[1], rd_bw$N[2]))
}

# ============================================================================
# 6. PLACEBO THRESHOLD TESTS
# ============================================================================

cat("\n=== Placebo Threshold Tests ===\n")

placebo_thresholds <- c(40000, 45000, 55000, 60000) - 50000

cat("\nTransit Share at Placebo Thresholds:\n")

for (threshold in placebo_thresholds) {
  actual_threshold <- threshold + 50000

  # Subset data near placebo threshold
  placebo_data <- analysis_data %>%
    filter(abs(running_var - threshold) <= rd_transit$bws[1, 1])

  if (nrow(placebo_data) >= 20) {
    rd_placebo <- try(rdrobust(
      y = analysis_data$transit_share,
      x = analysis_data$running_var,
      c = threshold,
      kernel = "triangular"
    ), silent = TRUE)

    if (!inherits(rd_placebo, "try-error")) {
      cat(sprintf("  Threshold %d: est = %8.5f, p = %5.3f\n",
                  actual_threshold, rd_placebo$coef[1], rd_placebo$pv[3]))
    } else {
      cat(sprintf("  Threshold %d: insufficient data\n", actual_threshold))
    }
  } else {
    cat(sprintf("  Threshold %d: insufficient data\n", actual_threshold))
  }
}

# ============================================================================
# 7. SAVE RESULTS
# ============================================================================

cat("\nSaving results...\n")

# Create results summary table
results_table <- tibble(
  outcome = c("Transit Share", "Employment Rate", "No Vehicle Share", "Long Commute Share"),
  estimate = c(rd_transit$coef[1], rd_employment$coef[1], rd_vehicle$coef[1], rd_commute$coef[1]),
  robust_se = c(rd_transit$se[3], rd_employment$se[3], rd_vehicle$se[3], rd_commute$se[3]),
  p_value = c(rd_transit$pv[3], rd_employment$pv[3], rd_vehicle$pv[3], rd_commute$pv[3]),
  ci_lower = c(rd_transit$ci[3, 1], rd_employment$ci[3, 1], rd_vehicle$ci[3, 1], rd_commute$ci[3, 1]),
  ci_upper = c(rd_transit$ci[3, 2], rd_employment$ci[3, 2], rd_vehicle$ci[3, 2], rd_commute$ci[3, 2]),
  bandwidth = c(rd_transit$bws[1, 1], rd_employment$bws[1, 1], rd_vehicle$bws[1, 1], rd_commute$bws[1, 1]),
  n_left = c(rd_transit$N[1], rd_employment$N[1], rd_vehicle$N[1], rd_commute$N[1]),
  n_right = c(rd_transit$N[2], rd_employment$N[2], rd_vehicle$N[2], rd_commute$N[2])
)

write_csv(results_table, file.path(data_dir, "rdd_results.csv"))

# Save McCrary test result
mccrary_result <- tibble(
  t_stat = density_test$test$t_jk,
  p_value = density_test$test$p_jk
)
write_csv(mccrary_result, file.path(data_dir, "mccrary_test.csv"))

cat("Results saved to:", data_dir, "\n")

cat("\n=== Main Analysis Complete ===\n")
