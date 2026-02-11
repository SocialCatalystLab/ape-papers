################################################################################
# 04_robustness.R — Robustness Checks for ARC RDD
# ARC Distressed County Designation RDD (apep_0217)
#
# Checks:
#   1. McCrary density test (rddensity)
#   2. Covariate balance (lagged outcomes)
#   3. Bandwidth sensitivity (0.5x to 1.5x optimal)
#   4. Placebo cutoffs (median, 25th percentile CIV)
#   5. Donut-hole RDD (drop |CIV| <= 2)
#   6. Polynomial order (linear vs quadratic)
#   7. Year-by-year RDD estimates
################################################################################

source("00_packages.R")

data_dir <- "../data"
results_dir <- "../data"

################################################################################
# 1. Load data
################################################################################

arc <- readRDS(file.path(data_dir, "arc_analysis.rds"))
panel <- readRDS(file.path(data_dir, "arc_panel_full.rds"))

outcomes <- c("unemp_rate_arc", "log_pcmi", "poverty_rate_arc")
outcome_labels <- c("Unemployment Rate (%)",
                     "Log Per Capita Market Income",
                     "Poverty Rate (%)")
names(outcome_labels) <- outcomes

cat("=== Robustness Checks ===\n")

################################################################################
# 2. McCrary Density Test
################################################################################

cat("\n--- McCrary Density Test ---\n")

density_test <- rddensity(X = arc$civ_centered, c = 0)

cat(sprintf("  T-statistic: %.3f\n", density_test$test$t_jk))
cat(sprintf("  P-value: %.4f\n", density_test$test$p_jk))
cat(sprintf("  N left: %d, N right: %d\n",
            density_test$N$eff_left, density_test$N$eff_right))

density_result <- list(
  t_stat = density_test$test$t_jk,
  p_value = density_test$test$p_jk,
  n_left = density_test$N$eff_left,
  n_right = density_test$N$eff_right,
  bw_left = density_test$h$left,
  bw_right = density_test$h$right,
  fit = density_test
)

################################################################################
# 3. Covariate Balance (Lagged Outcomes)
################################################################################

cat("\n--- Covariate Balance: Lagged Outcomes at Threshold ---\n")

# Merge lagged values: for each county-year, get the PREVIOUS year's outcomes
# This tests whether predetermined characteristics are smooth at the cutoff

panel_sorted <- panel %>%
  arrange(fips, fiscal_year)

# Create lagged variables
panel_lagged <- panel_sorted %>%
  group_by(fips) %>%
  mutate(
    lag_unemp = dplyr::lag(unemp_rate_arc, 1),
    lag_pcmi = dplyr::lag(pcmi, 1),
    lag_poverty = dplyr::lag(poverty_rate_arc, 1),
    lag_log_pcmi = dplyr::lag(log_pcmi, 1)
  ) %>%
  ungroup()

# Restrict to analysis window
balance_data <- panel_lagged %>%
  filter(abs(civ_centered) <= 50)

balance_vars <- c("lag_unemp", "lag_pcmi", "lag_poverty")
balance_labels <- c("Lagged Unemployment Rate",
                     "Lagged PCMI ($)",
                     "Lagged Poverty Rate")

balance_results <- list()

for (i in seq_along(balance_vars)) {
  bvar <- balance_vars[i]
  d <- balance_data %>% filter(!is.na(.data[[bvar]]) & !is.na(civ_centered))

  if (nrow(d) < 50) {
    cat(sprintf("  %s: insufficient data (n=%d)\n", balance_labels[i], nrow(d)))
    next
  }

  fit <- rdrobust(
    y = d[[bvar]],
    x = d$civ_centered,
    c = 0,
    kernel = "triangular",
    bwselect = "mserd",
    all = TRUE
  )

  balance_results[[bvar]] <- list(
    variable = bvar,
    label = balance_labels[i],
    coef_robust = fit$coef[3],
    se_robust = fit$se[3],
    pv_robust = fit$pv[3],
    ci_lower = fit$ci[3, 1],
    ci_upper = fit$ci[3, 2],
    bw_h = fit$bws[1, 1],
    N_left = fit$N_h[1],
    N_right = fit$N_h[2]
  )

  cat(sprintf("  %s: coef=%.4f (SE=%.4f), p=%.4f, bw=%.1f\n",
              balance_labels[i], fit$coef[3], fit$se[3], fit$pv[3], fit$bws[1,1]))
}

# Also test population and personal income if available
if ("population" %in% names(balance_data)) {
  pop_data <- balance_data %>%
    group_by(fips) %>%
    mutate(lag_pop = dplyr::lag(population, 1)) %>%
    ungroup() %>%
    filter(!is.na(lag_pop) & !is.na(civ_centered))

  if (nrow(pop_data) >= 50) {
    fit_pop <- rdrobust(
      y = pop_data$lag_pop,
      x = pop_data$civ_centered,
      c = 0,
      kernel = "triangular",
      bwselect = "mserd",
      all = TRUE
    )

    balance_results[["lag_pop"]] <- list(
      variable = "lag_pop",
      label = "Lagged Population",
      coef_robust = fit_pop$coef[3],
      se_robust = fit_pop$se[3],
      pv_robust = fit_pop$pv[3],
      ci_lower = fit_pop$ci[3, 1],
      ci_upper = fit_pop$ci[3, 2],
      bw_h = fit_pop$bws[1, 1],
      N_left = fit_pop$N_h[1],
      N_right = fit_pop$N_h[2]
    )
    cat(sprintf("  Lagged Population: coef=%.1f (SE=%.1f), p=%.4f\n",
                fit_pop$coef[3], fit_pop$se[3], fit_pop$pv[3]))
  }
}

################################################################################
# 4. Bandwidth Sensitivity
################################################################################

cat("\n--- Bandwidth Sensitivity ---\n")

bw_multipliers <- c(0.50, 0.75, 1.00, 1.25, 1.50)

bw_results <- list()

for (yvar in outcomes) {
  d <- arc %>% filter(!is.na(.data[[yvar]]) & !is.na(civ_centered))

  # Get optimal bandwidth first
  fit_opt <- rdrobust(
    y = d[[yvar]], x = d$civ_centered, c = 0,
    kernel = "triangular", bwselect = "mserd", all = TRUE
  )
  h_opt <- fit_opt$bws[1, 1]

  cat(sprintf("\n  %s (h_opt = %.2f):\n", outcome_labels[yvar], h_opt))

  for (mult in bw_multipliers) {
    h_use <- h_opt * mult

    fit <- rdrobust(
      y = d[[yvar]], x = d$civ_centered, c = 0,
      kernel = "triangular", h = h_use, all = TRUE
    )

    key <- paste0(yvar, "_bw_", mult)
    bw_results[[key]] <- list(
      outcome = yvar,
      label = outcome_labels[yvar],
      multiplier = mult,
      h = h_use,
      h_opt = h_opt,
      coef_conv = fit$coef[1],
      coef_robust = fit$coef[3],
      se_conv = fit$se[1],
      se_robust = fit$se[3],
      pv_robust = fit$pv[3],
      ci_lower = fit$ci[3, 1],
      ci_upper = fit$ci[3, 2],
      N_h_left = fit$N_h[1],
      N_h_right = fit$N_h[2]
    )

    cat(sprintf("    h=%.1f (%.0f%%): coef=%.4f (SE=%.4f), p=%.4f, N=%d\n",
                h_use, mult * 100, fit$coef[3], fit$se[3], fit$pv[3],
                sum(fit$N_h)))
  }
}

################################################################################
# 5. Placebo Cutoffs
################################################################################

cat("\n--- Placebo Cutoffs ---\n")

# Use median and 25th percentile of CIV as fake thresholds
# These should show no effect

civ_quantiles <- quantile(arc$civ_centered, probs = c(0.25, 0.50), na.rm = TRUE)
placebo_cutoffs <- civ_quantiles
names(placebo_cutoffs) <- c("25th_pctile", "median")

cat(sprintf("  Placebo cutoffs: 25th pctile = %.2f, Median = %.2f\n",
            placebo_cutoffs[1], placebo_cutoffs[2]))

placebo_results <- list()

for (cutoff_name in names(placebo_cutoffs)) {
  cutoff <- placebo_cutoffs[cutoff_name]

  for (yvar in outcomes) {
    d <- arc %>% filter(!is.na(.data[[yvar]]) & !is.na(civ_centered))

    fit <- tryCatch({
      rdrobust(
        y = d[[yvar]], x = d$civ_centered, c = cutoff,
        kernel = "triangular", bwselect = "mserd", all = TRUE
      )
    }, error = function(e) {
      cat(sprintf("    ERROR %s at %s: %s\n", yvar, cutoff_name, e$message))
      NULL
    })

    if (!is.null(fit)) {
      key <- paste0(yvar, "_", cutoff_name)
      placebo_results[[key]] <- list(
        outcome = yvar,
        label = outcome_labels[yvar],
        cutoff_name = cutoff_name,
        cutoff_value = cutoff,
        coef_robust = fit$coef[3],
        se_robust = fit$se[3],
        pv_robust = fit$pv[3],
        ci_lower = fit$ci[3, 1],
        ci_upper = fit$ci[3, 2],
        bw_h = fit$bws[1, 1],
        N_left = fit$N_h[1],
        N_right = fit$N_h[2]
      )

      cat(sprintf("    %s at %s (c=%.2f): coef=%.4f, p=%.4f\n",
                  yvar, cutoff_name, cutoff, fit$coef[3], fit$pv[3]))
    }
  }
}

################################################################################
# 6. Donut-Hole RDD
################################################################################

cat("\n--- Donut-Hole RDD (drop |CIV| <= 2) ---\n")

donut_results <- list()

for (yvar in outcomes) {
  d <- arc %>%
    filter(!is.na(.data[[yvar]]) & !is.na(civ_centered)) %>%
    filter(abs(civ_centered) > 2)

  fit <- rdrobust(
    y = d[[yvar]], x = d$civ_centered, c = 0,
    kernel = "triangular", bwselect = "mserd", all = TRUE
  )

  donut_results[[yvar]] <- list(
    outcome = yvar,
    label = outcome_labels[yvar],
    coef_conv = fit$coef[1],
    coef_robust = fit$coef[3],
    se_conv = fit$se[1],
    se_robust = fit$se[3],
    pv_robust = fit$pv[3],
    ci_lower = fit$ci[3, 1],
    ci_upper = fit$ci[3, 2],
    bw_h = fit$bws[1, 1],
    N_left = fit$N_h[1],
    N_right = fit$N_h[2],
    donut = 2
  )

  cat(sprintf("  %s: coef=%.4f (SE=%.4f), p=%.4f, N=%d\n",
              yvar, fit$coef[3], fit$se[3], fit$pv[3], sum(fit$N_h)))
}

################################################################################
# 7. Polynomial Order Comparison
################################################################################

cat("\n--- Polynomial Order: Linear vs Quadratic ---\n")

poly_results <- list()

for (yvar in outcomes) {
  d <- arc %>% filter(!is.na(.data[[yvar]]) & !is.na(civ_centered))

  for (p in c(1, 2)) {
    fit <- rdrobust(
      y = d[[yvar]], x = d$civ_centered, c = 0,
      p = p, kernel = "triangular", bwselect = "mserd", all = TRUE
    )

    key <- paste0(yvar, "_p", p)
    poly_results[[key]] <- list(
      outcome = yvar,
      label = outcome_labels[yvar],
      poly_order = p,
      coef_robust = fit$coef[3],
      se_robust = fit$se[3],
      pv_robust = fit$pv[3],
      ci_lower = fit$ci[3, 1],
      ci_upper = fit$ci[3, 2],
      bw_h = fit$bws[1, 1],
      N_left = fit$N_h[1],
      N_right = fit$N_h[2]
    )

    cat(sprintf("  %s (p=%d): coef=%.4f (SE=%.4f), p=%.4f, bw=%.1f\n",
                yvar, p, fit$coef[3], fit$se[3], fit$pv[3], fit$bws[1,1]))
  }
}

################################################################################
# 8. Year-by-Year Estimates
################################################################################

cat("\n--- Year-by-Year RDD Estimates ---\n")

yearly_results <- list()
years <- sort(unique(arc$fiscal_year))

for (yr in years) {
  cat(sprintf("\n  FY %d:\n", yr))

  for (yvar in outcomes) {
    d <- arc %>%
      filter(fiscal_year == yr) %>%
      filter(!is.na(.data[[yvar]]) & !is.na(civ_centered))

    if (nrow(d) < 30) {
      cat(sprintf("    %s: insufficient data (n=%d)\n", yvar, nrow(d)))
      next
    }

    fit <- tryCatch({
      rdrobust(
        y = d[[yvar]], x = d$civ_centered, c = 0,
        kernel = "triangular", bwselect = "mserd", all = TRUE
      )
    }, error = function(e) {
      cat(sprintf("    %s: ERROR - %s\n", yvar, e$message))
      NULL
    })

    if (!is.null(fit)) {
      key <- paste0(yvar, "_", yr)
      yearly_results[[key]] <- list(
        outcome = yvar,
        label = outcome_labels[yvar],
        year = yr,
        coef_conv = fit$coef[1],
        coef_robust = fit$coef[3],
        se_conv = fit$se[1],
        se_robust = fit$se[3],
        pv_robust = fit$pv[3],
        ci_lower = fit$ci[3, 1],
        ci_upper = fit$ci[3, 2],
        bw_h = fit$bws[1, 1],
        N_left = fit$N_h[1],
        N_right = fit$N_h[2]
      )

      cat(sprintf("    %s: coef=%.4f (SE=%.4f), p=%.4f, N=%d\n",
                  yvar, fit$coef[3], fit$se[3], fit$pv[3], sum(fit$N_h)))
    }
  }
}

################################################################################
# 9. Save All Robustness Results
################################################################################

robustness_results <- list(
  density = density_result,
  balance = balance_results,
  bandwidth = bw_results,
  placebo = placebo_results,
  donut = donut_results,
  polynomial = poly_results,
  yearly = yearly_results,
  balance_data = balance_data  # save for figure generation
)

saveRDS(robustness_results, file.path(results_dir, "robustness_results.rds"))

cat("\n=== Robustness Checks Complete. Results saved to robustness_results.rds ===\n")
