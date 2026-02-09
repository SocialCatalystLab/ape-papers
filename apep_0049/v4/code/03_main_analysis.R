# ============================================================================
# APEP-0049 v4 - Transit Funding Discontinuity
# 03_main_analysis.R - RDD estimation and diagnostics
#
# Uses 2010 Census population (running variable) -> 2016-2020 ACS outcomes
# The first stage is SHARP by statute: eligibility at >= 50,000
# v4 additions: Fuzzy RD with real FTA funding, power analysis,
#               heterogeneity by baseline transit service
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

# ============================================================================
# 8. FUZZY RD WITH REAL FTA FUNDING DATA
# ============================================================================

cat("\n=== Fuzzy RD with Real FTA Apportionment Data ===\n")

fta_file <- file.path(data_dir, "ua_analysis_with_fta.csv")
if (file.exists(fta_file)) {
  fta_data <- read_csv(fta_file, show_col_types = FALSE)

  # Check how many eligible UZAs have FTA funding data
  fta_eligible <- fta_data %>% filter(eligible_5307 == 1, !is.na(fta_funding))
  cat("Eligible UZAs with FTA funding data:", nrow(fta_eligible), "\n")

  if (nrow(fta_eligible) > 50) {
    # First stage magnitude: funding jump at threshold
    cat("\nFirst stage (funding per capita at threshold):\n")
    fta_data_clean <- fta_data %>% filter(!is.na(fta_per_capita))

    if (nrow(fta_data_clean) > 100) {
      rd_first_stage <- rdrobust(
        y = fta_data_clean$fta_per_capita,
        x = fta_data_clean$running_var,
        c = 0,
        kernel = "triangular",
        bwselect = "mserd"
      )

      cat("  Estimate (per-capita funding jump): $",
          sprintf("%.1f", rd_first_stage$coef[1]), "\n")
      cat("  Robust SE: $", sprintf("%.1f", rd_first_stage$se[3]), "\n")
      cat("  Robust p-value:", sprintf("%.3f", rd_first_stage$pv[3]), "\n")

      first_stage_result <- tibble(
        outcome = "FTA Per-Capita Funding",
        estimate = rd_first_stage$coef[1],
        robust_se = rd_first_stage$se[3],
        p_value = rd_first_stage$pv[3],
        ci_lower = rd_first_stage$ci[3, 1],
        ci_upper = rd_first_stage$ci[3, 2],
        bandwidth = rd_first_stage$bws[1, 1],
        n_left = rd_first_stage$N[1],
        n_right = rd_first_stage$N[2]
      )
      write_csv(first_stage_result, file.path(data_dir, "first_stage_result.csv"))
    }

    # Fuzzy RD: Use per-capita funding as endogenous variable
    cat("\nFuzzy RD (transit share ~ per-capita funding):\n")
    fta_transit <- fta_data %>%
      filter(!is.na(fta_per_capita), !is.na(transit_share))

    if (nrow(fta_transit) > 100) {
      rd_fuzzy <- tryCatch(
        rdrobust(
          y = fta_transit$transit_share,
          x = fta_transit$running_var,
          fuzzy = fta_transit$fta_per_capita,
          c = 0,
          kernel = "triangular",
          bwselect = "mserd"
        ),
        error = function(e) {
          cat("  Fuzzy RD failed:", e$message, "\n")
          NULL
        }
      )

      if (!is.null(rd_fuzzy)) {
        cat("  TOT Estimate:", sprintf("%.6f", rd_fuzzy$coef[1]),
            "(effect per $1 funding per capita)\n")
        cat("  Robust SE:", sprintf("%.6f", rd_fuzzy$se[3]), "\n")
        cat("  Robust p-value:", sprintf("%.3f", rd_fuzzy$pv[3]), "\n")

        fuzzy_result <- tibble(
          outcome = "Transit Share (Fuzzy/TOT)",
          estimate = rd_fuzzy$coef[1],
          robust_se = rd_fuzzy$se[3],
          p_value = rd_fuzzy$pv[3],
          ci_lower = rd_fuzzy$ci[3, 1],
          ci_upper = rd_fuzzy$ci[3, 2],
          bandwidth = rd_fuzzy$bws[1, 1],
          n_left = rd_fuzzy$N[1],
          n_right = rd_fuzzy$N[2]
        )
        write_csv(fuzzy_result, file.path(data_dir, "fuzzy_rd_result.csv"))
      }
    }
  }
} else {
  cat("FTA data not found - skipping fuzzy RD (run 01b_fetch_fta_data.R first)\n")
}

# ============================================================================
# 9. FORMAL POWER ANALYSIS
# ============================================================================

cat("\n=== Formal Power Analysis ===\n")
cat("Computing minimum detectable effects at 80% power, alpha = 0.05\n")

# Power formula for RD: MDE = (z_alpha + z_beta) * SE
# where z_alpha = 1.96, z_beta = 0.842 for 80% power
z_alpha <- 1.96
z_beta <- 0.842

power_results <- tibble()

for (i in 1:nrow(results_table)) {
  outcome <- results_table$outcome[i]
  se <- results_table$robust_se[i]
  mde <- (z_alpha + z_beta) * se

  # Compute outcome mean for context
  outcome_var <- case_when(
    outcome == "Transit Share" ~ "transit_share",
    outcome == "Employment Rate" ~ "employment_rate",
    outcome == "No Vehicle Share" ~ "no_vehicle_share",
    outcome == "Long Commute Share" ~ "long_commute_share"
  )

  outcome_mean <- mean(analysis_data[[outcome_var]], na.rm = TRUE)
  outcome_sd <- sd(analysis_data[[outcome_var]], na.rm = TRUE)

  # MDE as fraction of mean and SD
  mde_pct_mean <- mde / outcome_mean * 100
  mde_pct_sd <- mde / outcome_sd * 100

  cat(sprintf("  %s: MDE = %.4f (%.1f%% of mean, %.1f%% of SD)\n",
              outcome, mde, mde_pct_mean, mde_pct_sd))

  power_results <- bind_rows(power_results, tibble(
    outcome = outcome,
    robust_se = se,
    mde_80 = mde,
    outcome_mean = outcome_mean,
    outcome_sd = outcome_sd,
    mde_pct_mean = mde_pct_mean,
    mde_pct_sd = mde_pct_sd
  ))
}

write_csv(power_results, file.path(data_dir, "power_analysis.csv"))

# ============================================================================
# 10. HETEROGENEITY BY BASELINE TRANSIT SERVICE
# ============================================================================

cat("\n=== Heterogeneity by Baseline Transit Service ===\n")

ntd_file <- file.path(data_dir, "ua_analysis_with_ntd.csv")
if (file.exists(ntd_file)) {
  ntd_data <- read_csv(ntd_file, show_col_types = FALSE)

  cat("UZAs with transit agencies:", sum(ntd_data$has_transit, na.rm = TRUE), "\n")
  cat("UZAs without transit agencies:", sum(!ntd_data$has_transit, na.rm = TRUE), "\n")

  hetero_results <- tibble()

  for (has_svc in c(TRUE, FALSE)) {
    subgroup <- ntd_data %>% filter(has_transit == has_svc)
    label <- ifelse(has_svc, "With Transit", "Without Transit")

    if (nrow(subgroup) > 50 && sum(subgroup$eligible_5307) > 10) {
      rd_sub <- tryCatch(
        rdrobust(
          y = subgroup$transit_share,
          x = subgroup$running_var,
          c = 0,
          kernel = "triangular",
          bwselect = "mserd"
        ),
        error = function(e) NULL
      )

      if (!is.null(rd_sub)) {
        cat(sprintf("  %s: est=%.5f, SE=%.5f, p=%.3f, N=%d/%d\n",
                    label, rd_sub$coef[1], rd_sub$se[3], rd_sub$pv[3],
                    rd_sub$N[1], rd_sub$N[2]))

        hetero_results <- bind_rows(hetero_results, tibble(
          subgroup = label,
          outcome = "Transit Share",
          estimate = rd_sub$coef[1],
          robust_se = rd_sub$se[3],
          p_value = rd_sub$pv[3],
          n_left = rd_sub$N[1],
          n_right = rd_sub$N[2]
        ))
      }
    } else {
      cat(sprintf("  %s: insufficient observations (N=%d)\n", label, nrow(subgroup)))
    }
  }

  if (nrow(hetero_results) > 0) {
    write_csv(hetero_results, file.path(data_dir, "heterogeneity_transit.csv"))
  }
} else {
  cat("NTD data not found - skipping (run 01c_fetch_ntd_data.R first)\n")
}

# ============================================================================
# 11. SAVE ALL RESULTS
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
cat("  - first_stage_result.csv (FTA funding first stage)\n")
cat("  - fuzzy_rd_result.csv (fuzzy RD with real funding)\n")
cat("  - power_analysis.csv (MDE calculations)\n")
cat("  - heterogeneity_transit.csv (by baseline transit service)\n")

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
