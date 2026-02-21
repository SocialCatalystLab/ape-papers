# ============================================================================
# 03_main_analysis.R — Main RDD analysis
# Multi-Level Political Alignment and Local Development in India
# ============================================================================

source("00_packages.R")
data_dir <- "../data"
load(file.path(data_dir, "analysis_data.RData"))

cat("============================================================\n")
cat("MAIN ANALYSIS: Close-Election RDD on Political Alignment\n")
cat("============================================================\n\n")

# ============================================================================
# 1. Descriptive Statistics
# ============================================================================
cat("── 1. Descriptive Statistics ──────────────────────────────\n\n")

# Summary of election data
cat("Election Data Coverage:\n")
cat(sprintf("  Total constituency-elections: %s\n", format(nrow(panel), big.mark = ",")))
cat(sprintf("  States: %d | Years: %d-%d\n",
            uniqueN(panel$st_name), min(panel$year), max(panel$year)))

# Post-2008 elections (2007 delimitation era, matching SHRUG ACs)
post08 <- panel[year >= 2008]
cat(sprintf("\n  Post-2008 elections: %s\n", format(nrow(post08), big.mark = ",")))
cat(sprintf("  States: %d | Unique ACs: %d\n",
            uniqueN(post08$st_name), uniqueN(post08$ac07_id)))

# Alignment breakdown
cat("\nAlignment Distribution (all years):\n")
cat(sprintf("  State-aligned:   %5d (%5.1f%%)\n",
            sum(panel$state_aligned, na.rm = TRUE),
            100 * mean(panel$state_aligned, na.rm = TRUE)))
cat(sprintf("  Center-aligned:  %5d (%5.1f%%)\n",
            sum(panel$center_aligned, na.rm = TRUE),
            100 * mean(panel$center_aligned, na.rm = TRUE)))
cat(sprintf("  Double-aligned:  %5d (%5.1f%%)\n",
            sum(panel$double_aligned, na.rm = TRUE),
            100 * mean(panel$double_aligned, na.rm = TRUE)))

# Margin distribution
cat(sprintf("\nVote Margin Distribution:\n"))
cat(sprintf("  Mean: %.3f | Median: %.3f | SD: %.3f\n",
            mean(panel$margin, na.rm = TRUE),
            median(panel$margin, na.rm = TRUE),
            sd(panel$margin, na.rm = TRUE)))
cat(sprintf("  Within 5%%: %d | Within 10%%: %d | Within 15%%: %d\n",
            sum(panel$margin <= 0.05, na.rm = TRUE),
            sum(panel$margin <= 0.10, na.rm = TRUE),
            sum(panel$margin <= 0.15, na.rm = TRUE)))

# ============================================================================
# 2. State-Alignment RDD (Primary Specification)
# ============================================================================
cat("\n── 2. State-Alignment RDD ─────────────────────────────────\n\n")

# Prepare RDD dataset: post-2008 elections with VIIRS data
# Collapse to election-level: average post-election nightlights (years 1-4)
rdd_data_state <- viirs_panel[
  rel_year >= 1 & rel_year <= 4 & !is.na(rdd_margin_state),
  .(post_nl_mean = mean(viirs_mean, na.rm = TRUE),
    post_log_nl = mean(log_nl, na.rm = TRUE),
    nl_growth = mean(nl_growth, na.rm = TRUE),
    n_years = .N),
  by = .(st_name, year, ac_no, ac07_id, rdd_margin_state,
         state_aligned, center_aligned, double_aligned,
         log_baseline, pop, lit_rate, sc_share, st_share,
         work_rate, ag_share)
]

# Also compute pre-election nightlights (years -2 to -1) for placebo
rdd_pre_state <- viirs_panel[
  rel_year %in% c(-2, -1) & !is.na(rdd_margin_state),
  .(pre_nl_mean = mean(viirs_mean, na.rm = TRUE),
    pre_log_nl = mean(log_nl, na.rm = TRUE)),
  by = .(st_name, year, ac_no, ac07_id, rdd_margin_state, state_aligned)
]

rdd_data_state <- merge(rdd_data_state, rdd_pre_state,
                         by = c("st_name", "year", "ac_no", "ac07_id",
                                "rdd_margin_state", "state_aligned"),
                         all.x = TRUE)

cat(sprintf("  RDD sample (state): %d constituency-elections\n", nrow(rdd_data_state)))
cat(sprintf("  State-aligned (treatment): %d | Unaligned (control): %d\n",
            sum(rdd_data_state$rdd_margin_state > 0, na.rm = TRUE),
            sum(rdd_data_state$rdd_margin_state <= 0, na.rm = TRUE)))

# Primary RDD: rdrobust
cat("\n  Primary RDD (MSE-optimal bandwidth, local linear):\n")
rdd_state <- tryCatch({
  rdrobust(y = rdd_data_state$post_log_nl,
           x = rdd_data_state$rdd_margin_state,
           c = 0, p = 1, kernel = "triangular",
           all = TRUE)
}, error = function(e) {
  cat(sprintf("  ERROR: %s\n", e$message))
  NULL
})

if (!is.null(rdd_state)) {
  cat(sprintf("  Bandwidth (h): %.4f | Effective N (left/right): %d / %d\n",
              rdd_state$bws[1, 1],
              rdd_state$N_h[1], rdd_state$N_h[2]))
  cat(sprintf("  Conventional estimate: %.4f (SE: %.4f, p: %.4f)\n",
              rdd_state$coef[1], rdd_state$se[1], rdd_state$pv[1]))
  cat(sprintf("  Bias-corrected:        %.4f (SE: %.4f, p: %.4f)\n",
              rdd_state$coef[2], rdd_state$se[3], rdd_state$pv[3]))
  cat(sprintf("  Robust CI: [%.4f, %.4f]\n",
              rdd_state$ci[3, 1], rdd_state$ci[3, 2]))
}

# ============================================================================
# 3. Center-Alignment RDD
# ============================================================================
cat("\n── 3. Center-Alignment RDD ────────────────────────────────\n\n")

rdd_data_center <- viirs_panel[
  rel_year >= 1 & rel_year <= 4 & !is.na(rdd_margin_center),
  .(post_nl_mean = mean(viirs_mean, na.rm = TRUE),
    post_log_nl = mean(log_nl, na.rm = TRUE),
    nl_growth = mean(nl_growth, na.rm = TRUE),
    n_years = .N),
  by = .(st_name, year, ac_no, ac07_id, rdd_margin_center,
         state_aligned, center_aligned, double_aligned,
         log_baseline, pop, lit_rate, sc_share, st_share,
         work_rate, ag_share)
]

rdd_pre_center <- viirs_panel[
  rel_year %in% c(-2, -1) & !is.na(rdd_margin_center),
  .(pre_nl_mean = mean(viirs_mean, na.rm = TRUE),
    pre_log_nl = mean(log_nl, na.rm = TRUE)),
  by = .(st_name, year, ac_no, ac07_id, rdd_margin_center, center_aligned)
]

rdd_data_center <- merge(rdd_data_center, rdd_pre_center,
                          by = c("st_name", "year", "ac_no", "ac07_id",
                                 "rdd_margin_center", "center_aligned"),
                          all.x = TRUE)

cat(sprintf("  RDD sample (center): %d constituency-elections\n", nrow(rdd_data_center)))

cat("\n  Primary RDD (MSE-optimal bandwidth, local linear):\n")
rdd_center <- tryCatch({
  rdrobust(y = rdd_data_center$post_log_nl,
           x = rdd_data_center$rdd_margin_center,
           c = 0, p = 1, kernel = "triangular",
           all = TRUE)
}, error = function(e) {
  cat(sprintf("  ERROR: %s\n", e$message))
  NULL
})

if (!is.null(rdd_center)) {
  cat(sprintf("  Bandwidth (h): %.4f | Effective N (left/right): %d / %d\n",
              rdd_center$bws[1, 1],
              rdd_center$N_h[1], rdd_center$N_h[2]))
  cat(sprintf("  Conventional estimate: %.4f (SE: %.4f, p: %.4f)\n",
              rdd_center$coef[1], rdd_center$se[1], rdd_center$pv[1]))
  cat(sprintf("  Bias-corrected:        %.4f (SE: %.4f, p: %.4f)\n",
              rdd_center$coef[2], rdd_center$se[3], rdd_center$pv[3]))
  cat(sprintf("  Robust CI: [%.4f, %.4f]\n",
              rdd_center$ci[3, 1], rdd_center$ci[3, 2]))
}

# ============================================================================
# 4. Double-Alignment Analysis (Interaction)
# ============================================================================
cat("\n── 4. Double-Alignment Analysis ───────────────────────────\n\n")

# For this, we use the state-alignment RDD sample and test whether
# the effect differs by center-alignment status
# (i.e., is the effect of state alignment LARGER when also center-aligned?)

rdd_data_state[, post_2014 := as.integer(year >= 2014)]
rdd_data_state[, bjp_center := as.integer(year >= 2014)]  # BJP controlled center from 2014

# Parametric approach within bandwidth
h_state <- if (!is.null(rdd_state)) rdd_state$bws[1, 1] else 0.10
bw_sample <- rdd_data_state[abs(rdd_margin_state) <= h_state]

cat(sprintf("  Bandwidth sample: %d obs (h = %.4f)\n", nrow(bw_sample), h_state))

# Triple interaction: state_aligned × center_aligned × margin
if (nrow(bw_sample) > 50) {
  fit_double <- tryCatch({
    feols(post_log_nl ~ state_aligned * center_aligned + rdd_margin_state |
            st_name + year,
          data = bw_sample,
          cluster = ~st_name)
  }, error = function(e) {
    cat(sprintf("  ERROR: %s\n", e$message))
    NULL
  })

  if (!is.null(fit_double)) {
    cat("\n  Double-alignment interaction (within RDD bandwidth):\n")
    print(summary(fit_double))
  }
}

# ============================================================================
# 5. McCrary Density Test (Manipulation Check)
# ============================================================================
cat("\n── 5. McCrary Density Test ────────────────────────────────\n\n")

# Test for bunching at the zero-margin threshold
density_state <- tryCatch({
  rddensity(X = rdd_data_state$rdd_margin_state, c = 0)
}, error = function(e) {
  cat(sprintf("  ERROR: %s\n", e$message))
  NULL
})

if (!is.null(density_state)) {
  cat(sprintf("  State-alignment: T-stat = %.3f, p-value = %.4f\n",
              density_state$test$t_jk, density_state$test$p_jk))
  cat(sprintf("  Interpretation: %s\n",
              ifelse(density_state$test$p_jk > 0.05,
                     "No evidence of manipulation (PASS)",
                     "WARNING: Possible manipulation")))
}

density_center <- tryCatch({
  rddensity(X = rdd_data_center$rdd_margin_center, c = 0)
}, error = function(e) {
  cat(sprintf("  ERROR: %s\n", e$message))
  NULL
})

if (!is.null(density_center)) {
  cat(sprintf("  Center-alignment: T-stat = %.3f, p-value = %.4f\n",
              density_center$test$t_jk, density_center$test$p_jk))
}

# ============================================================================
# 6. Covariate Balance at the Cutoff
# ============================================================================
cat("\n── 6. Covariate Balance Tests ──────────────────────────────\n\n")

covariates <- c("log_baseline", "pop", "lit_rate", "sc_share",
                "st_share", "work_rate", "ag_share", "pre_log_nl")

for (cv in covariates) {
  y <- rdd_data_state[[cv]]
  x <- rdd_data_state$rdd_margin_state
  valid <- !is.na(y) & !is.na(x) & is.finite(y)

  if (sum(valid) < 100) {
    cat(sprintf("  %s: insufficient data (%d obs)\n", cv, sum(valid)))
    next
  }

  bal <- tryCatch({
    rdrobust(y = y[valid], x = x[valid], c = 0, p = 1, kernel = "triangular")
  }, error = function(e) NULL)

  if (!is.null(bal)) {
    cat(sprintf("  %15s: τ = %7.4f (SE = %.4f, p = %.3f) %s\n",
                cv, bal$coef[1], bal$se[1], bal$pv[1],
                ifelse(bal$pv[1] < 0.05, " ***", "")))
  }
}

# ============================================================================
# 7. Placebo Test: Pre-Election Nightlights
# ============================================================================
cat("\n── 7. Placebo Test (Pre-Election NL) ──────────────────────\n\n")

placebo <- tryCatch({
  y <- rdd_data_state$pre_log_nl
  x <- rdd_data_state$rdd_margin_state
  valid <- !is.na(y) & !is.na(x) & is.finite(y)
  rdrobust(y = y[valid], x = x[valid], c = 0, p = 1, kernel = "triangular")
}, error = function(e) {
  cat(sprintf("  ERROR: %s\n", e$message))
  NULL
})

if (!is.null(placebo)) {
  cat(sprintf("  Pre-election NL (placebo): τ = %.4f (SE = %.4f, p = %.4f)\n",
              placebo$coef[1], placebo$se[1], placebo$pv[1]))
  cat(sprintf("  Interpretation: %s\n",
              ifelse(placebo$pv[1] > 0.10,
                     "No pre-existing discontinuity (PASS)",
                     "WARNING: Pre-existing discontinuity detected")))
}

# ============================================================================
# 8. Save Results
# ============================================================================
results <- list(
  rdd_state = rdd_state,
  rdd_center = rdd_center,
  density_state = density_state,
  density_center = density_center,
  rdd_data_state = rdd_data_state,
  rdd_data_center = rdd_data_center,
  bw_sample = bw_sample,
  panel = panel
)

save(results, file = file.path(data_dir, "main_results.RData"))
cat("\n\nResults saved to main_results.RData\n")
