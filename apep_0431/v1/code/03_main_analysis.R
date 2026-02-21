## ────────────────────────────────────────────────────────────────────────────
## 03_main_analysis.R — Main RDD estimation
## Primary specifications: rdrobust at 500 population threshold
## ────────────────────────────────────────────────────────────────────────────

source("00_packages.R")
load("../data/analysis_data.RData")

# Restrict to plain-area states (threshold = 500)
df <- panel[special_state == FALSE & !is.na(pop2001) & pop2001 > 0]
cat("Analysis sample (plain states):", nrow(df), "\n")

# ════════════════════════════════════════════════════════════════════════════
# PART 1: RDD VALIDITY CHECKS
# ════════════════════════════════════════════════════════════════════════════

# ── McCrary density test ────────────────────────────────────────────────────
cat("\n=== McCrary Density Test at 500 ===\n")
mccrary <- rddensity(X = df$pop2001, c = 500)
cat("  T-statistic:", round(mccrary$test$t_jk, 3), "\n")
cat("  P-value:", round(mccrary$test$p_jk, 4), "\n")
cat("  Interpretation:", ifelse(mccrary$test$p_jk > 0.05,
    "No evidence of manipulation (PASS)", "Possible manipulation (INVESTIGATE)"), "\n")

# Store result
mccrary_result <- list(
  t_stat = mccrary$test$t_jk,
  p_value = mccrary$test$p_jk,
  pass = mccrary$test$p_jk > 0.05
)

# ── Covariate balance tests ─────────────────────────────────────────────────
cat("\n=== Covariate Balance at 500 ===\n")
covariates <- c("lit_rate_01", "sc_share_01", "st_share_01",
                "female_share_01", "pc01_pca_no_hh")
covariate_names <- c("Literacy rate", "SC share", "ST share",
                     "Female share", "Number of households")

cov_balance <- data.table(
  Covariate = covariate_names,
  Estimate = NA_real_,
  SE = NA_real_,
  P_value = NA_real_,
  BW = NA_real_
)

for (i in seq_along(covariates)) {
  var <- covariates[i]
  y <- df[[var]]
  valid <- !is.na(y) & !is.na(df$pop2001)
  if (sum(valid) < 100) next

  tryCatch({
    rd <- rdrobust(y = y[valid], x = df$pop2001[valid], c = 500)
    cov_balance[i, `:=`(
      Estimate = rd$coef[1],
      SE = rd$se[3],  # robust SE
      P_value = rd$pv[3],  # robust p-value
      BW = rd$bws[1, 1]
    )]
    cat(sprintf("  %s: coef = %.4f, p = %.4f %s\n",
                covariate_names[i], rd$coef[1], rd$pv[3],
                ifelse(rd$pv[3] < 0.05, "***", "")))
  }, error = function(e) {
    cat(sprintf("  %s: FAILED (%s)\n", covariate_names[i], e$message))
  })
}

# ── Pre-PMGSY nightlights placebo ──────────────────────────────────────────
cat("\n=== Pre-PMGSY Nightlights Placebo (1994-1999) ===\n")

# Average pre-PMGSY nightlights for each village
pre_nl <- nl_combined[year <= 1999 & special_state == FALSE,
                      .(pre_nl = mean(nl, na.rm = TRUE)), by = shrid2]
df_nl <- merge(df, pre_nl, by = "shrid2", all.x = TRUE)

valid <- !is.na(df_nl$pre_nl) & !is.na(df_nl$pop2001)
if (sum(valid) > 100) {
  rd_pre <- rdrobust(y = df_nl$pre_nl[valid], x = df_nl$pop2001[valid], c = 500)
  cat(sprintf("  Pre-PMGSY NL: coef = %.4f, p = %.4f %s\n",
              rd_pre$coef[1], rd_pre$pv[3],
              ifelse(rd_pre$pv[3] < 0.05, "***", "")))
}

# ════════════════════════════════════════════════════════════════════════════
# PART 2: MAIN RDD ESTIMATES
# ════════════════════════════════════════════════════════════════════════════

cat("\n=== Main RDD Estimates: Gender-Differentiated Structural Transformation ===\n")

outcomes <- c("d_nonag_share_f", "d_nonag_share_m", "d_nonag_share_gap",
              "d_wfpr_f", "d_wfpr_m",
              "nonag_share_11_f", "nonag_share_11_m")
outcome_names <- c(
  "Change in female non-ag share",
  "Change in male non-ag share",
  "Gender gap change (F - M)",
  "Change in female WF participation",
  "Change in male WF participation",
  "Female non-ag share (2011)",
  "Male non-ag share (2011)"
)

main_results <- data.table(
  Outcome = outcome_names,
  Estimate = NA_real_,
  SE_robust = NA_real_,
  P_value = NA_real_,
  CI_lower = NA_real_,
  CI_upper = NA_real_,
  BW = NA_real_,
  N_eff = NA_integer_
)

for (i in seq_along(outcomes)) {
  var <- outcomes[i]
  y <- df[[var]]
  valid <- !is.na(y) & !is.na(df$pop2001)
  if (sum(valid) < 100) {
    cat(sprintf("  %s: insufficient observations\n", outcome_names[i]))
    next
  }

  tryCatch({
    rd <- rdrobust(y = y[valid], x = df$pop2001[valid], c = 500)
    main_results[i, `:=`(
      Estimate = rd$coef[1],
      SE_robust = rd$se[3],
      P_value = rd$pv[3],
      CI_lower = rd$ci[3, 1],
      CI_upper = rd$ci[3, 2],
      BW = rd$bws[1, 1],
      N_eff = rd$N_h[1] + rd$N_h[2]
    )]
    stars <- ifelse(rd$pv[3] < 0.01, "***",
             ifelse(rd$pv[3] < 0.05, "**",
             ifelse(rd$pv[3] < 0.10, "*", "")))
    cat(sprintf("  %s: %.4f (%.4f) [p=%.4f] %s  BW=%.0f  N=%d\n",
                outcome_names[i], rd$coef[1], rd$se[3], rd$pv[3],
                stars, rd$bws[1, 1], rd$N_h[1] + rd$N_h[2]))
  }, error = function(e) {
    cat(sprintf("  %s: FAILED (%s)\n", outcome_names[i], e$message))
  })
}

# ════════════════════════════════════════════════════════════════════════════
# PART 3: DYNAMIC RDD (Year-by-Year Nightlights)
# ════════════════════════════════════════════════════════════════════════════

cat("\n=== Dynamic RDD: Year-by-Year Nightlights Effects ===\n")

nl_plain <- nl_combined[special_state == FALSE]
years <- sort(unique(nl_plain$year))

dynamic_results <- data.table(
  year = years,
  estimate = NA_real_,
  se_robust = NA_real_,
  p_value = NA_real_,
  ci_lower = NA_real_,
  ci_upper = NA_real_,
  bw = NA_real_,
  n_eff = NA_integer_
)

for (yr in years) {
  yr_data <- nl_plain[year == yr]
  valid <- !is.na(yr_data$log_nl) & !is.na(yr_data$pop2001)
  if (sum(valid) < 100) next

  tryCatch({
    rd <- rdrobust(y = yr_data$log_nl[valid], x = yr_data$pop2001[valid], c = 500)
    idx <- which(dynamic_results$year == yr)
    dynamic_results[idx, `:=`(
      estimate = rd$coef[1],
      se_robust = rd$se[3],
      p_value = rd$pv[3],
      ci_lower = rd$ci[3, 1],
      ci_upper = rd$ci[3, 2],
      bw = rd$bws[1, 1],
      n_eff = rd$N_h[1] + rd$N_h[2]
    )]
    stars <- ifelse(rd$pv[3] < 0.01, "***",
             ifelse(rd$pv[3] < 0.05, "**",
             ifelse(rd$pv[3] < 0.10, "*", "")))
    cat(sprintf("  %d: %.4f (%.4f) [p=%.4f] %s\n",
                yr, rd$coef[1], rd$se[3], rd$pv[3], stars))
  }, error = function(e) {
    cat(sprintf("  %d: FAILED (%s)\n", yr, e$message))
  })
}

# Mark pre/post periods
dynamic_results[, period := ifelse(year < 2000, "Pre-PMGSY",
                            ifelse(year <= 2002, "Rollout", "Post-PMGSY"))]

# ── Save all results ────────────────────────────────────────────────────────
save(mccrary_result, cov_balance, main_results, dynamic_results,
     file = "../data/main_results.RData")

cat("\nAll main results saved to data/main_results.RData\n")
