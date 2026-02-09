################################################################################
# 07_revision_analysis.R
# Social Network Minimum Wage Exposure - REVISION ANALYSIS
#
# This script runs additional 2SLS regressions for the revision:
# 1. Earnings 2SLS at each distance threshold (0, 100, 200, 300, 500 km)
# 2. Probability-weighted IV for earnings
# 3. Saves all results to revision_results.rds
#
# Input:  ../data/analysis_panel.rds
# Output: ../data/revision_results.rds
################################################################################

source("00_packages.R")

cat("=== Revision Analysis: Earnings Distance-Credibility + Prob-Weighted ===\n\n")

# ============================================================================
# 1. Load Data
# ============================================================================

cat("1. Loading analysis panel...\n")

panel <- readRDS("../data/analysis_panel.rds")

cat("  Observations:", format(nrow(panel), big.mark = ","), "\n")
cat("  Counties:", n_distinct(panel$county_fips), "\n")
cat("  Quarters:", n_distinct(panel$yearq), "\n")

# Verify required variables exist
required_vars <- c("log_earn", "network_mw_pop", "network_mw_pop_out_state",
                   "network_mw_prob", "county_fips", "state_fips", "yearq")
missing_vars <- setdiff(required_vars, names(panel))
if (length(missing_vars) > 0) {
  stop("Missing required variables: ", paste(missing_vars, collapse = ", "))
}

cat("  Has log_earn:", "log_earn" %in% names(panel), "\n")
cat("  Has log_emp:", "log_emp" %in% names(panel), "\n\n")

# Filter to complete cases for regression
panel_reg <- panel %>%
  filter(!is.na(network_mw_pop) & !is.na(network_mw_pop_out_state) &
         !is.na(network_mw_prob) & !is.na(log_earn) & !is.na(state_fips))

cat("  Regression sample (non-missing earnings):", format(nrow(panel_reg), big.mark = ","), "\n\n")

# ============================================================================
# 2. Earnings 2SLS at Each Distance Threshold
# ============================================================================

cat("==========================================================\n")
cat("  EARNINGS 2SLS BY DISTANCE THRESHOLD\n")
cat("==========================================================\n\n")

distance_thresholds <- c(0, 100, 200, 300, 500)
earnings_distance_results <- list()

for (d in distance_thresholds) {
  iv_col <- paste0("iv_pop_dist_", d)

  if (!iv_col %in% names(panel_reg)) {
    cat(sprintf("  %4d km: IV column '%s' not found, skipping.\n", d, iv_col))
    next
  }

  panel_d <- panel_reg %>%
    filter(!is.na(.data[[iv_col]]))

  if (nrow(panel_d) < 1000) {
    cat(sprintf("  %4d km: Too few observations (%d), skipping.\n", d, nrow(panel_d)))
    next
  }

  cat(sprintf("  %4d km: N = %s ...\n", d, format(nrow(panel_d), big.mark = ",")))

  # First stage
  fs_formula <- as.formula(paste("network_mw_pop ~", iv_col,
                                 "| county_fips + state_fips^yearq"))
  fs_fit <- tryCatch({
    feols(fs_formula, data = panel_d, cluster = ~state_fips)
  }, error = function(e) {
    cat(sprintf("    First stage failed: %s\n", e$message))
    NULL
  })

  if (is.null(fs_fit)) next

  fs_f <- (coef(fs_fit)[1] / se(fs_fit)[1])^2

  # 2SLS for earnings
  tsls_fit <- NULL
  if (fs_f > 5) {
    tsls_formula <- as.formula(paste(
      "log_earn ~ 1 | county_fips + state_fips^yearq | network_mw_pop ~", iv_col
    ))
    tsls_fit <- tryCatch({
      feols(tsls_formula, data = panel_d, cluster = ~state_fips)
    }, error = function(e) {
      cat(sprintf("    2SLS failed: %s\n", e$message))
      NULL
    })
  }

  earnings_distance_results[[as.character(d)]] <- list(
    threshold = d,
    n_obs = nrow(panel_d),
    first_stage_coef = coef(fs_fit)[1],
    first_stage_se = se(fs_fit)[1],
    first_stage_f = fs_f,
    tsls_coef = if (!is.null(tsls_fit)) coef(tsls_fit)[1] else NA,
    tsls_se = if (!is.null(tsls_fit)) se(tsls_fit)[1] else NA,
    tsls_p = if (!is.null(tsls_fit)) fixest::pvalue(tsls_fit)[1] else NA
  )

  cat(sprintf("    FS F = %.1f | 2SLS coef = %.4f (SE = %.4f, p = %.4f)\n",
              fs_f,
              ifelse(is.na(earnings_distance_results[[as.character(d)]]$tsls_coef), NA,
                     earnings_distance_results[[as.character(d)]]$tsls_coef),
              ifelse(is.na(earnings_distance_results[[as.character(d)]]$tsls_se), NA,
                     earnings_distance_results[[as.character(d)]]$tsls_se),
              ifelse(is.na(earnings_distance_results[[as.character(d)]]$tsls_p), NA,
                     earnings_distance_results[[as.character(d)]]$tsls_p)))
}

# Print summary table
cat("\n--- Earnings Distance-Credibility Summary ---\n")
cat(sprintf("%6s %10s %8s %10s %10s %10s\n",
            "Dist", "N", "FS F", "2SLS", "SE", "p-value"))
cat(paste(rep("-", 60), collapse = ""), "\n")

for (d_name in names(earnings_distance_results)) {
  r <- earnings_distance_results[[d_name]]
  cat(sprintf("%4d km %9d %8.1f %10.4f %10.4f %10.4f\n",
              r$threshold, r$n_obs, r$first_stage_f,
              ifelse(is.na(r$tsls_coef), NA, r$tsls_coef),
              ifelse(is.na(r$tsls_se), NA, r$tsls_se),
              ifelse(is.na(r$tsls_p), NA, r$tsls_p)))
}

# ============================================================================
# 3. Probability-Weighted IV for Earnings
# ============================================================================

cat("\n==========================================================\n")
cat("  PROBABILITY-WEIGHTED IV FOR EARNINGS\n")
cat("==========================================================\n\n")

# Identify the correct prob-weighted out-of-state IV column
# The panel may have network_mw_prob_out_state or network_mw_out_state_prob
prob_iv_col <- NULL
if ("network_mw_prob_out_state" %in% names(panel_reg)) {
  prob_iv_col <- "network_mw_prob_out_state"
} else if ("network_mw_out_state_prob" %in% names(panel_reg)) {
  prob_iv_col <- "network_mw_out_state_prob"
}

prob_earn_result <- NULL

if (!is.null(prob_iv_col)) {
  cat("  Using prob-weighted IV column:", prob_iv_col, "\n")

  panel_prob <- panel_reg %>%
    filter(!is.na(network_mw_prob) & !is.na(.data[[prob_iv_col]]))

  cat("  Regression sample:", format(nrow(panel_prob), big.mark = ","), "\n")

  # First stage
  fs_prob_formula <- as.formula(paste("network_mw_prob ~", prob_iv_col,
                                      "| county_fips + state_fips^yearq"))
  fs_prob <- tryCatch({
    feols(fs_prob_formula, data = panel_prob, cluster = ~state_fips)
  }, error = function(e) {
    cat("  First stage failed:", e$message, "\n")
    NULL
  })

  if (!is.null(fs_prob)) {
    fs_f_prob <- (coef(fs_prob)[1] / se(fs_prob)[1])^2
    cat("  First stage F:", round(fs_f_prob, 1), "\n")

    # 2SLS
    tsls_prob_formula <- as.formula(paste(
      "log_earn ~ 1 | county_fips + state_fips^yearq | network_mw_prob ~", prob_iv_col
    ))
    tsls_prob <- tryCatch({
      feols(tsls_prob_formula, data = panel_prob, cluster = ~state_fips)
    }, error = function(e) {
      cat("  2SLS failed:", e$message, "\n")
      NULL
    })

    if (!is.null(tsls_prob)) {
      cat("  2SLS Coefficient:", round(coef(tsls_prob)[1], 4),
          "(SE:", round(se(tsls_prob)[1], 4),
          ", p =", round(fixest::pvalue(tsls_prob)[1], 4), ")\n")

      prob_earn_result <- list(
        iv_col = prob_iv_col,
        n_obs = nrow(panel_prob),
        first_stage_coef = coef(fs_prob)[1],
        first_stage_se = se(fs_prob)[1],
        first_stage_f = fs_f_prob,
        tsls_coef = coef(tsls_prob)[1],
        tsls_se = se(tsls_prob)[1],
        tsls_p = fixest::pvalue(tsls_prob)[1]
      )
    }
  }
} else {
  cat("  WARNING: No probability-weighted out-of-state IV column found.\n")
  cat("  Looked for: network_mw_prob_out_state, network_mw_out_state_prob\n")
}

# ============================================================================
# 4. Save Results
# ============================================================================

cat("\n=== Saving Revision Results ===\n")

revision_results <- list(
  earnings_distance = earnings_distance_results,
  prob_earn = prob_earn_result,
  distance_thresholds = distance_thresholds,
  n_panel = nrow(panel_reg)
)

saveRDS(revision_results, "../data/revision_results.rds")
cat("  Saved ../data/revision_results.rds\n")

# ============================================================================
# Summary
# ============================================================================

cat("\n=== Revision Analysis Summary ===\n\n")

cat("Earnings 2SLS by distance threshold:\n")
for (d_name in names(earnings_distance_results)) {
  r <- earnings_distance_results[[d_name]]
  sig_flag <- if (!is.na(r$tsls_p) && r$tsls_p < 0.05) " ***" else
              if (!is.na(r$tsls_p) && r$tsls_p < 0.10) " *" else ""
  cat(sprintf("  %4d km: beta = %.4f (p = %.4f)%s\n",
              r$threshold,
              ifelse(is.na(r$tsls_coef), NA, r$tsls_coef),
              ifelse(is.na(r$tsls_p), NA, r$tsls_p),
              sig_flag))
}

cat("\nProbability-weighted earnings IV:\n")
if (!is.null(prob_earn_result)) {
  cat(sprintf("  beta = %.4f (SE = %.4f, p = %.4f, FS F = %.1f)\n",
              prob_earn_result$tsls_coef, prob_earn_result$tsls_se,
              prob_earn_result$tsls_p, prob_earn_result$first_stage_f))
} else {
  cat("  Not available\n")
}

cat("\n=== Revision Analysis Complete ===\n")
