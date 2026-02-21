# ============================================================================
# 04_robustness.R — Robustness checks for RDD analysis
# Multi-Level Political Alignment and Local Development in India
# ============================================================================

source("00_packages.R")
data_dir <- "../data"
load(file.path(data_dir, "analysis_data.RData"))
load(file.path(data_dir, "main_results.RData"))

cat("============================================================\n")
cat("ROBUSTNESS CHECKS\n")
cat("============================================================\n\n")

rdd_data_state <- results$rdd_data_state
rdd_data_center <- results$rdd_data_center

# ============================================================================
# 1. Bandwidth Sensitivity
# ============================================================================
cat("── 1. Bandwidth Sensitivity ──────────────────────────────\n\n")

bandwidths <- seq(0.03, 0.20, by = 0.01)
bw_results_state <- data.table()
bw_results_center <- data.table()

for (h in bandwidths) {
  # State alignment
  s <- rdd_data_state[abs(rdd_margin_state) <= h]
  if (nrow(s) >= 50 & sum(s$rdd_margin_state > 0) >= 20 & sum(s$rdd_margin_state <= 0) >= 20) {
    r <- tryCatch({
      rdrobust(y = s$post_log_nl, x = s$rdd_margin_state, c = 0, h = h, p = 1)
    }, error = function(e) NULL)
    if (!is.null(r)) {
      bw_results_state <- rbind(bw_results_state, data.table(
        h = h, n = nrow(s),
        est = r$coef[1], se = r$se[1], pval = r$pv[1],
        ci_lo = r$ci[1, 1], ci_hi = r$ci[1, 2]
      ))
    }
  }

  # Center alignment
  c_samp <- rdd_data_center[abs(rdd_margin_center) <= h]
  if (nrow(c_samp) >= 50 & sum(c_samp$rdd_margin_center > 0) >= 20 &
      sum(c_samp$rdd_margin_center <= 0) >= 20) {
    r <- tryCatch({
      rdrobust(y = c_samp$post_log_nl, x = c_samp$rdd_margin_center, c = 0, h = h, p = 1)
    }, error = function(e) NULL)
    if (!is.null(r)) {
      bw_results_center <- rbind(bw_results_center, data.table(
        h = h, n = nrow(c_samp),
        est = r$coef[1], se = r$se[1], pval = r$pv[1],
        ci_lo = r$ci[1, 1], ci_hi = r$ci[1, 2]
      ))
    }
  }
}

cat("State-alignment bandwidth sensitivity:\n")
print(bw_results_state[, .(h, n, est = round(est, 4), pval = round(pval, 3))])
cat("\nCenter-alignment bandwidth sensitivity:\n")
print(bw_results_center[, .(h, n, est = round(est, 4), pval = round(pval, 3))])

# ============================================================================
# 2. Donut RDD (drop ultra-close races)
# ============================================================================
cat("\n── 2. Donut RDD ───────────────────────────────────────────\n\n")

donut_holes <- c(0.005, 0.01, 0.02, 0.03)
donut_results <- data.table()

for (d in donut_holes) {
  s <- rdd_data_state[abs(rdd_margin_state) >= d]
  if (nrow(s) >= 100) {
    r <- tryCatch({
      rdrobust(y = s$post_log_nl, x = s$rdd_margin_state, c = 0, p = 1)
    }, error = function(e) NULL)
    if (!is.null(r)) {
      donut_results <- rbind(donut_results, data.table(
        donut = d, n = nrow(s),
        est = r$coef[1], se = r$se[1], pval = r$pv[1]
      ))
    }
  }
}

cat("Donut RDD results (state alignment):\n")
print(donut_results[, .(donut, n, est = round(est, 4), pval = round(pval, 3))])

# ============================================================================
# 3. Alternative Polynomials
# ============================================================================
cat("\n── 3. Alternative Polynomial Orders ───────────────────────\n\n")

poly_results <- data.table()
for (p_ord in 1:3) {
  r <- tryCatch({
    rdrobust(y = rdd_data_state$post_log_nl,
             x = rdd_data_state$rdd_margin_state,
             c = 0, p = p_ord, kernel = "triangular")
  }, error = function(e) NULL)
  if (!is.null(r)) {
    poly_results <- rbind(poly_results, data.table(
      p_ord = p_ord, est = r$coef[1], se = r$se[1], pval = r$pv[1],
      h = r$bws[1, 1], n_left = r$N_h[1], n_right = r$N_h[2]
    ))
    cat(sprintf("  p=%d: τ = %.4f (SE = %.4f, p = %.3f, h = %.4f, N = %d/%d)\n",
                p_ord, r$coef[1], r$se[1], r$pv[1],
                r$bws[1, 1], r$N_h[1], r$N_h[2]))
  }
}

# ============================================================================
# 4. Alternative Kernels
# ============================================================================
cat("\n── 4. Alternative Kernels ─────────────────────────────────\n\n")

kernel_results <- data.table()
for (kern in c("triangular", "uniform", "epanechnikov")) {
  r <- tryCatch({
    rdrobust(y = rdd_data_state$post_log_nl,
             x = rdd_data_state$rdd_margin_state,
             c = 0, p = 1, kernel = kern)
  }, error = function(e) NULL)
  if (!is.null(r)) {
    kernel_results <- rbind(kernel_results, data.table(
      kernel = kern, est = r$coef[1], se = r$se[1], pval = r$pv[1]
    ))
    cat(sprintf("  %-14s: τ = %.4f (SE = %.4f, p = %.3f)\n",
                kern, r$coef[1], r$se[1], r$pv[1]))
  }
}

# ============================================================================
# 5. Dynamic Effects (Year-by-Year)
# ============================================================================
cat("\n── 5. Dynamic Effects (Year-by-Year) ──────────────────────\n\n")

# For each relative year, run separate RDD
dynamic_state <- data.table()
dynamic_center <- data.table()

for (ry in -2:5) {
  # State alignment
  yr_data <- viirs_panel[rel_year == ry & !is.na(rdd_margin_state)]
  if (nrow(yr_data) >= 100) {
    r <- tryCatch({
      rdrobust(y = yr_data$log_nl, x = yr_data$rdd_margin_state,
               c = 0, p = 1, kernel = "triangular")
    }, error = function(e) NULL)
    if (!is.null(r)) {
      dynamic_state <- rbind(dynamic_state, data.table(
        rel_year = ry, est = r$coef[1], se = r$se[1], pval = r$pv[1],
        ci_lo = r$ci[1, 1], ci_hi = r$ci[1, 2], n = r$N_h[1] + r$N_h[2]
      ))
    }
  }

  # Center alignment
  yr_data_c <- viirs_panel[rel_year == ry & !is.na(rdd_margin_center)]
  if (nrow(yr_data_c) >= 100) {
    r <- tryCatch({
      rdrobust(y = yr_data_c$log_nl, x = yr_data_c$rdd_margin_center,
               c = 0, p = 1, kernel = "triangular")
    }, error = function(e) NULL)
    if (!is.null(r)) {
      dynamic_center <- rbind(dynamic_center, data.table(
        rel_year = ry, est = r$coef[1], se = r$se[1], pval = r$pv[1],
        ci_lo = r$ci[1, 1], ci_hi = r$ci[1, 2], n = r$N_h[1] + r$N_h[2]
      ))
    }
  }
}

cat("Dynamic effects — State alignment:\n")
print(dynamic_state[, .(rel_year, est = round(est, 4), se = round(se, 4),
                         pval = round(pval, 3), n)])
cat("\nDynamic effects — Center alignment:\n")
print(dynamic_center[, .(rel_year, est = round(est, 4), se = round(se, 4),
                          pval = round(pval, 3), n)])

# ============================================================================
# 6. Exclude Reserved Constituencies
# ============================================================================
cat("\n── 6. Exclude Reserved (SC/ST) Constituencies ─────────────\n\n")

# ac_type may not be in the aggregated RDD data; use panel to filter
ac_types <- results$panel[, .(ac_type = ac_type[1]), by = .(st_name, year, ac_no)]
rdd_with_type <- merge(rdd_data_state, ac_types, by = c("st_name", "year", "ac_no"), all.x = TRUE)
unreserved <- rdd_with_type[ac_type == "GEN" | is.na(ac_type)]
cat(sprintf("  General constituencies: %d / %d total\n",
            nrow(unreserved), nrow(rdd_data_state)))

gen_result <- NULL
if (nrow(unreserved) >= 100) {
  r <- tryCatch({
    rdrobust(y = unreserved$post_log_nl,
             x = unreserved$rdd_margin_state,
             c = 0, p = 1, kernel = "triangular")
  }, error = function(e) NULL)
  if (!is.null(r)) {
    gen_result <- data.table(est = r$coef[1], se = r$se[1], pval = r$pv[1])
    cat(sprintf("  General only: τ = %.4f (SE = %.4f, p = %.3f)\n",
                r$coef[1], r$se[1], r$pv[1]))
  }
}

# ============================================================================
# 7. Pre-2014 vs Post-2014 (Modi Era Split)
# ============================================================================
cat("\n── 7. Pre-2014 vs Post-2014 Split ─────────────────────────\n\n")

era_results <- data.table()
for (era in c("pre2014", "post2014")) {
  if (era == "pre2014") {
    era_data <- rdd_data_state[year < 2014]
  } else {
    era_data <- rdd_data_state[year >= 2014]
  }

  if (nrow(era_data) >= 100) {
    r <- tryCatch({
      rdrobust(y = era_data$post_log_nl,
               x = era_data$rdd_margin_state,
               c = 0, p = 1, kernel = "triangular")
    }, error = function(e) NULL)
    if (!is.null(r)) {
      era_results <- rbind(era_results, data.table(
        era = era, est = r$coef[1], se = r$se[1], pval = r$pv[1]
      ))
      cat(sprintf("  %s: τ = %.4f (SE = %.4f, p = %.3f, N = %d/%d)\n",
                  era, r$coef[1], r$se[1], r$pv[1],
                  r$N_h[1], r$N_h[2]))
    } else {
      cat(sprintf("  %s: insufficient data or estimation error\n", era))
    }
  } else {
    cat(sprintf("  %s: too few observations (%d)\n", era, nrow(era_data)))
  }
}

# ============================================================================
# 8. Randomization Inference
# ============================================================================
cat("\n── 8. Randomization Inference ──────────────────────────────\n\n")

# Permutation test: randomly assign treatment 500 times
set.seed(42)
n_perms <- 500
h_opt <- results$rdd_state$bws[1, 1]
bw_sample <- rdd_data_state[abs(rdd_margin_state) <= h_opt &
                              !is.na(post_log_nl) & !is.na(rdd_margin_state)]

# Observed statistic
obs_diff <- mean(bw_sample[rdd_margin_state > 0]$post_log_nl, na.rm = TRUE) -
            mean(bw_sample[rdd_margin_state <= 0]$post_log_nl, na.rm = TRUE)

perm_diffs <- numeric(n_perms)
for (i in seq_len(n_perms)) {
  shuffled <- sample(bw_sample$rdd_margin_state)
  perm_diffs[i] <- mean(bw_sample[shuffled > 0]$post_log_nl, na.rm = TRUE) -
                   mean(bw_sample[shuffled <= 0]$post_log_nl, na.rm = TRUE)
}

ri_pval <- mean(abs(perm_diffs) >= abs(obs_diff))
cat(sprintf("  Observed difference: %.4f\n", obs_diff))
cat(sprintf("  RI p-value (two-sided, %d permutations): %.4f\n", n_perms, ri_pval))

# ============================================================================
# 9. Covariate-Adjusted RDD
# ============================================================================
cat("\n── 9. Covariate-Adjusted RDD ───────────────────────────────\n\n")

# Adjust for population and SC share (the imbalanced covariates)
covadj_vars <- rdd_data_state[, .(pop, sc_share)]
valid_cov <- complete.cases(covadj_vars) & !is.na(rdd_data_state$post_log_nl) &
             !is.na(rdd_data_state$rdd_margin_state)

cov_adj_result <- NULL
if (sum(valid_cov) >= 100) {
  r <- tryCatch({
    rdrobust(y = rdd_data_state$post_log_nl[valid_cov],
             x = rdd_data_state$rdd_margin_state[valid_cov],
             c = 0, p = 1, kernel = "triangular",
             covs = as.matrix(covadj_vars[valid_cov]))
  }, error = function(e) {
    cat(sprintf("  ERROR: %s\n", e$message))
    NULL
  })
  if (!is.null(r)) {
    cov_adj_result <- data.table(est = r$coef[1], se = r$se[1], pval = r$pv[1])
    cat(sprintf("  Covariate-adjusted: τ = %.4f (SE = %.4f, p = %.3f)\n",
                r$coef[1], r$se[1], r$pv[1]))
  }
}

# ============================================================================
# 10. Complete-Window Subsample (Elections 2012+)
# ============================================================================
cat("\n── 10. Complete VIIRS Window (2012+ elections) ─────────────\n\n")

complete_window <- rdd_data_state[year >= 2012]
cw_result <- NULL
if (nrow(complete_window) >= 100) {
  r <- tryCatch({
    rdrobust(y = complete_window$post_log_nl,
             x = complete_window$rdd_margin_state,
             c = 0, p = 1, kernel = "triangular")
  }, error = function(e) {
    cat(sprintf("  ERROR: %s\n", e$message))
    NULL
  })
  if (!is.null(r)) {
    cw_result <- data.table(est = r$coef[1], se = r$se[1], pval = r$pv[1])
    cat(sprintf("  Complete window (2012+): τ = %.4f (SE = %.4f, p = %.3f, N = %d/%d)\n",
                r$coef[1], r$se[1], r$pv[1], r$N_h[1], r$N_h[2]))
  }
}

# ============================================================================
# 11. Save Robustness Results
# ============================================================================
robustness <- list(
  bw_results_state = bw_results_state,
  bw_results_center = bw_results_center,
  donut_results = donut_results,
  poly_results = poly_results,
  kernel_results = kernel_results,
  gen_result = gen_result,
  era_results = era_results,
  dynamic_state = dynamic_state,
  dynamic_center = dynamic_center,
  cov_adj_result = cov_adj_result,
  cw_result = cw_result,
  ri_pval = ri_pval,
  obs_diff = obs_diff,
  perm_diffs = perm_diffs
)

save(robustness, file = file.path(data_dir, "robustness_results.RData"))
cat("\nRobustness results saved.\n")
