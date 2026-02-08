# =============================================================================
# 03_main_analysis.R
# Main RDD analysis: Effect of local referendum loss on subsequent turnout
# =============================================================================

source("00_packages.R")

# =============================================================================
# 1. Load data
# =============================================================================

cat("Loading data...\n")

focal_votes <- read_csv("../data/rdd_focal_votes.csv", show_col_types = FALSE)
muni_turnout <- read_csv("../data/muni_year_turnout.csv", show_col_types = FALSE)

cat("Focal votes:", nrow(focal_votes), "\n")

# =============================================================================
# 2. Construct outcome: Subsequent turnout
# =============================================================================

cat("\nConstructing subsequent turnout outcomes...\n")

# For each municipality-proposal pair, get turnout in subsequent votes
# Strategy: Use average turnout in years t+1, t+2, t+3 after focal vote

# Rename muni_turnout columns first
muni_future <- muni_turnout %>%
  select(muni_id, future_year = vote_year, subsequent_turnout = avg_turnout)

focal_with_outcome <- focal_votes %>%
  left_join(muni_future, by = "muni_id", relationship = "many-to-many") %>%
  filter(future_year > vote_year, future_year <= vote_year + 3) %>%
  group_by(vote_proposal_id, muni_id, vote_date, vote_year,
           yes_pct, running_var, local_win, turnout_pct, eligible_voters,
           kanton_name, language_region, policy_domain) %>%
  summarise(
    subsequent_turnout = mean(subsequent_turnout, na.rm = TRUE),
    n_future_years = n(),
    .groups = "drop"
  )

# Drop if no subsequent turnout data
focal_with_outcome <- focal_with_outcome %>%
  filter(!is.na(subsequent_turnout))

cat("Observations with subsequent turnout:", nrow(focal_with_outcome), "\n")

# =============================================================================
# 3. RDD Estimation: Primary specification
# =============================================================================

cat("\n=== PRIMARY RDD SPECIFICATION ===\n")

# Using rdrobust for MSE-optimal bandwidth and robust bias-corrected inference

rdd_result <- rdrobust(
  y = focal_with_outcome$subsequent_turnout,
  x = focal_with_outcome$running_var,
  c = 0,  # cutoff at 0 (centered at 50%)
  kernel = "triangular",
  bwselect = "mserd",
  cluster = focal_with_outcome$kanton_name
)

summary(rdd_result)

# Save key results (rdrobust stores results as matrices)
rdd_summary <- tibble(
  estimate = as.numeric(rdd_result$coef[1]),  # Conventional estimate
  se_robust = as.numeric(rdd_result$se[3]),   # Robust SE
  ci_lower = as.numeric(rdd_result$ci[3, 1]), # Robust CI lower
  ci_upper = as.numeric(rdd_result$ci[3, 2]), # Robust CI upper
  pvalue = as.numeric(rdd_result$pv[3]),      # Robust p-value
  bandwidth = as.numeric(rdd_result$bws[1, 1]),
  n_left = as.numeric(rdd_result$N_h[1]),
  n_right = as.numeric(rdd_result$N_h[2]),
  n_total = as.numeric(rdd_result$N[1])
)

print(rdd_summary)

# =============================================================================
# 4. Validity Test: McCrary Density Test
# =============================================================================

cat("\n=== MCCRARY DENSITY TEST ===\n")

density_test <- rddensity(
  X = focal_with_outcome$running_var,
  c = 0
)

summary(density_test)

# Save density test results
density_summary <- tibble(
  test_statistic = density_test$test$t_jk,
  p_value = density_test$test$p_jk,
  n_left = density_test$N$left,
  n_right = density_test$N$right,
  conclusion = ifelse(density_test$test$p_jk > 0.05,
                      "No evidence of manipulation",
                      "Potential manipulation detected")
)

print(density_summary)

# =============================================================================
# 5. Covariate Balance Tests
# =============================================================================

cat("\n=== COVARIATE BALANCE AT CUTOFF ===\n")

# Test for discontinuities in pre-determined characteristics

# Log eligible voters
if (sum(!is.na(focal_with_outcome$eligible_voters)) > 100) {
  balance_voters <- rdrobust(
    y = log(focal_with_outcome$eligible_voters + 1),
    x = focal_with_outcome$running_var,
    c = 0,
    kernel = "triangular"
  )
  cat("\nLog(eligible voters):\n")
  cat("  Estimate:", round(balance_voters$coef["Conventional"], 4),
      "p-value:", round(balance_voters$pv["Robust"], 4), "\n")
}

# Pre-treatment turnout (turnout in focal vote itself)
balance_turnout <- rdrobust(
  y = focal_with_outcome$turnout_pct,
  x = focal_with_outcome$running_var,
  c = 0,
  kernel = "triangular"
)
cat("\nFocal vote turnout (pre-outcome):\n")
cat("  Estimate:", round(balance_turnout$coef["Conventional"], 4),
    "p-value:", round(balance_turnout$pv["Robust"], 4), "\n")

# =============================================================================
# 6. Bandwidth Sensitivity
# =============================================================================

cat("\n=== BANDWIDTH SENSITIVITY ===\n")

optimal_bw <- rdd_result$bws["h", "left"]
bw_factors <- c(0.5, 0.75, 1, 1.25, 1.5)

bw_sensitivity <- map_dfr(bw_factors, function(factor) {
  bw <- optimal_bw * factor

  result <- rdrobust(
    y = focal_with_outcome$subsequent_turnout,
    x = focal_with_outcome$running_var,
    c = 0,
    h = bw,
    kernel = "triangular",
    cluster = focal_with_outcome$kanton_name
  )

  tibble(
    bw_factor = factor,
    bandwidth = bw,
    estimate = as.numeric(result$coef[1]),      # Conventional estimate
    se_robust = as.numeric(result$se[3]),       # Robust SE
    pvalue = as.numeric(result$pv[3]),          # Robust p-value
    n_effective = sum(result$N_h)
  )
})

print(bw_sensitivity)

# =============================================================================
# 7. Placebo Tests: Fake Cutoffs
# =============================================================================

cat("\n=== PLACEBO TESTS (FAKE CUTOFFS) ===\n")

placebo_cutoffs <- c(-20, -10, 10, 20)

placebo_results <- map_dfr(placebo_cutoffs, function(cutoff) {
  # Subset to observations away from true cutoff
  if (cutoff < 0) {
    subset_data <- focal_with_outcome %>% filter(running_var < 0)
  } else {
    subset_data <- focal_with_outcome %>% filter(running_var > 0)
  }

  result <- tryCatch({
    rdrobust(
      y = subset_data$subsequent_turnout,
      x = subset_data$running_var,
      c = cutoff,
      kernel = "triangular"
    )
  }, error = function(e) NULL)

  if (is.null(result)) {
    return(tibble(cutoff = cutoff, estimate = NA, pvalue = NA))
  }

  tibble(
    cutoff = cutoff,
    estimate = as.numeric(result$coef[1]),      # Conventional estimate
    pvalue = as.numeric(result$pv[3]),          # Robust p-value
    n_effective = sum(result$N_h)
  )
})

print(placebo_results)

# =============================================================================
# 8. Save Results
# =============================================================================

cat("\nSaving results...\n")

# Create results list
results <- list(
  primary = rdd_summary,
  density_test = density_summary,
  bandwidth_sensitivity = bw_sensitivity,
  placebo = placebo_results,
  rdrobust_object = rdd_result
)

saveRDS(results, "../data/rdd_results.rds")

# Also save as CSV for easy viewing
write_csv(rdd_summary, "../tables/rdd_primary_results.csv")
write_csv(bw_sensitivity, "../tables/rdd_bandwidth_sensitivity.csv")
write_csv(placebo_results, "../tables/rdd_placebo_tests.csv")

cat("\n=== SUMMARY ===\n")
cat("Primary estimate:", round(rdd_summary$estimate, 3), "\n")
cat("Robust SE:", round(rdd_summary$se_robust, 3), "\n")
cat("P-value:", round(rdd_summary$pvalue, 4), "\n")
cat("Bandwidth:", round(rdd_summary$bandwidth, 2), "pp\n")
cat("Effective N:", rdd_summary$n_left + rdd_summary$n_right, "\n")
cat("\nDone.\n")
