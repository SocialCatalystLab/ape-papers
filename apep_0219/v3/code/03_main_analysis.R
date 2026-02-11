################################################################################
# 03_main_analysis.R — Main RDD Estimation
# ARC Distressed County Designation RDD (apep_0217)
#
# Estimates:
#   1. Pooled cross-sectional RDD (rdrobust on raw outcomes)
#   2. Panel RDD (residualize out year FE, then rdrobust)
#   3. First-stage: discontinuity in CIV index itself
################################################################################

source("00_packages.R")

data_dir <- "../data"
results_dir <- "../data"  # store intermediate results alongside data

################################################################################
# 1. Load data
################################################################################

arc <- readRDS(file.path(data_dir, "arc_analysis.rds"))
panel <- readRDS(file.path(data_dir, "arc_panel_full.rds"))

cat(sprintf("Analysis sample: %d county-years, %d counties, %d years\n",
            nrow(arc), n_distinct(arc$fips), n_distinct(arc$fiscal_year)))

# Define outcomes
outcomes <- c("unemp_rate_arc", "log_pcmi", "poverty_rate_arc")
outcome_labels <- c("Unemployment Rate (%)",
                     "Log Per Capita Market Income",
                     "Poverty Rate (%)")
names(outcome_labels) <- outcomes

################################################################################
# 2. Pooled Cross-Sectional RDD
################################################################################

cat("\n=== Pooled Cross-Sectional RDD ===\n")

pooled_results <- list()

for (yvar in outcomes) {
  cat(sprintf("\n--- Outcome: %s ---\n", yvar))

  # Drop missing
  d <- arc %>% filter(!is.na(.data[[yvar]]) & !is.na(civ_centered))

  # Run rdrobust with default MSE-optimal bandwidth
  fit <- rdrobust(
    y = d[[yvar]],
    x = d$civ_centered,
    c = 0,
    kernel = "triangular",
    bwselect = "mserd",
    all = TRUE
  )

  cat(sprintf("  Estimate: %.4f (SE: %.4f)\n", fit$coef[1], fit$se[3]))
  cat(sprintf("  p-value (robust): %.4f\n", fit$pv[3]))
  cat(sprintf("  Bandwidth (h): %.2f, Bias-band (b): %.2f\n", fit$bws[1,1], fit$bws[1,2]))
  cat(sprintf("  N_left: %d, N_right: %d\n", fit$N_h[1], fit$N_h[2]))

  summary(fit)

  pooled_results[[yvar]] <- list(
    outcome = yvar,
    label = outcome_labels[yvar],
    coef_conv = fit$coef[1],
    coef_bc = fit$coef[2],
    coef_robust = fit$coef[3],
    se_conv = fit$se[1],
    se_bc = fit$se[2],
    se_robust = fit$se[3],
    pv_conv = fit$pv[1],
    pv_bc = fit$pv[2],
    pv_robust = fit$pv[3],
    ci_robust_lower = fit$ci[3, 1],
    ci_robust_upper = fit$ci[3, 2],
    bw_h = fit$bws[1, 1],
    bw_b = fit$bws[1, 2],
    N_h_left = fit$N_h[1],
    N_h_right = fit$N_h[2],
    N_total = sum(fit$N_h),
    specification = "pooled"
  )
}

################################################################################
# 3. Panel RDD (Year FE via Residualization)
################################################################################

cat("\n=== Panel RDD (Year FE Residualized) ===\n")

panel_results <- list()

for (yvar in outcomes) {
  cat(sprintf("\n--- Outcome: %s (Panel) ---\n", yvar))

  d <- arc %>% filter(!is.na(.data[[yvar]]) & !is.na(civ_centered))

  # Residualize: regress outcome on year FE, take residuals
  fe_formula <- as.formula(paste0(yvar, " ~ factor(fiscal_year)"))
  fe_fit <- lm(fe_formula, data = d)
  d$y_resid <- residuals(fe_fit)

  # Also residualize the running variable (absorb year-level shifts in CIV)
  fe_x <- lm(civ_centered ~ factor(fiscal_year), data = d)
  d$x_resid <- residuals(fe_x)

  # Run rdrobust on residualized data
  fit <- rdrobust(
    y = d$y_resid,
    x = d$x_resid,
    c = 0,
    kernel = "triangular",
    bwselect = "mserd",
    all = TRUE
  )

  cat(sprintf("  Estimate: %.4f (SE: %.4f)\n", fit$coef[1], fit$se[3]))
  cat(sprintf("  p-value (robust): %.4f\n", fit$pv[3]))
  cat(sprintf("  Bandwidth (h): %.2f\n", fit$bws[1,1]))

  summary(fit)

  panel_results[[yvar]] <- list(
    outcome = yvar,
    label = outcome_labels[yvar],
    coef_conv = fit$coef[1],
    coef_bc = fit$coef[2],
    coef_robust = fit$coef[3],
    se_conv = fit$se[1],
    se_bc = fit$se[2],
    se_robust = fit$se[3],
    pv_conv = fit$pv[1],
    pv_bc = fit$pv[2],
    pv_robust = fit$pv[3],
    ci_robust_lower = fit$ci[3, 1],
    ci_robust_upper = fit$ci[3, 2],
    bw_h = fit$bws[1, 1],
    bw_b = fit$bws[1, 2],
    N_h_left = fit$N_h[1],
    N_h_right = fit$N_h[2],
    N_total = sum(fit$N_h),
    specification = "panel_fe"
  )
}

################################################################################
# 4. First Stage: Discontinuity in CIV Components
################################################################################

cat("\n=== First Stage: Effect on CIV Component Inputs ===\n")

# The CIV is constructed from 3 components: unemployment, PCMI, poverty
# Check that crossing the threshold produces a sharp jump in the treatment
# indicator (by construction) and examine the running variable density

# First stage: does crossing threshold actually flip the distressed indicator?
d <- arc %>% filter(!is.na(civ_centered))

fs_fit <- rdrobust(
  y = d$distressed,
  x = d$civ_centered,
  c = 0,
  kernel = "triangular",
  bwselect = "mserd",
  all = TRUE
)

cat(sprintf("\nFirst stage (Distressed indicator):\n"))
cat(sprintf("  Estimate: %.4f (SE: %.4f)\n", fs_fit$coef[1], fs_fit$se[3]))
cat(sprintf("  p-value (robust): %.4f\n", fs_fit$pv[3]))
summary(fs_fit)

first_stage <- list(
  outcome = "distressed",
  label = "Distressed Designation (0/1)",
  coef_conv = fs_fit$coef[1],
  coef_bc = fs_fit$coef[2],
  coef_robust = fs_fit$coef[3],
  se_conv = fs_fit$se[1],
  se_bc = fs_fit$se[2],
  se_robust = fs_fit$se[3],
  pv_conv = fs_fit$pv[1],
  pv_bc = fs_fit$pv[2],
  pv_robust = fs_fit$pv[3],
  ci_robust_lower = fs_fit$ci[3, 1],
  ci_robust_upper = fs_fit$ci[3, 2],
  bw_h = fs_fit$bws[1, 1],
  bw_b = fs_fit$bws[1, 2],
  N_h_left = fs_fit$N_h[1],
  N_h_right = fs_fit$N_h[2],
  N_total = sum(fs_fit$N_h),
  specification = "first_stage"
)

# Also test each CIV component as an outcome in the RDD
# These should show jumps since CIV is constructed from them
civ_components <- c("unemp_rate_arc", "pcmi", "poverty_rate_arc")
civ_comp_labels <- c("Unemployment Rate", "PCMI ($)", "Poverty Rate")

component_results <- list()
for (i in seq_along(civ_components)) {
  yvar <- civ_components[i]
  d <- arc %>% filter(!is.na(.data[[yvar]]) & !is.na(civ_centered))

  fit <- rdrobust(
    y = d[[yvar]],
    x = d$civ_centered,
    c = 0,
    kernel = "triangular",
    bwselect = "mserd",
    all = TRUE
  )

  component_results[[yvar]] <- list(
    outcome = yvar,
    label = civ_comp_labels[i],
    coef_robust = fit$coef[3],
    se_robust = fit$se[3],
    pv_robust = fit$pv[3],
    bw_h = fit$bws[1, 1]
  )

  cat(sprintf("  %s: coef=%.4f, se=%.4f, p=%.4f\n",
              civ_comp_labels[i], fit$coef[3], fit$se[3], fit$pv[3]))
}

################################################################################
# 5. Save All Results
################################################################################

main_results <- list(
  pooled = pooled_results,
  panel = panel_results,
  first_stage = first_stage,
  component_results = component_results,
  outcomes = outcomes,
  outcome_labels = outcome_labels,
  n_total = nrow(arc),
  n_counties = n_distinct(arc$fips),
  n_years = n_distinct(arc$fiscal_year),
  year_range = range(arc$fiscal_year)
)

saveRDS(main_results, file.path(results_dir, "main_results.rds"))
cat("\n=== Main Analysis Complete. Results saved to main_results.rds ===\n")
