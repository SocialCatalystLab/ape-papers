################################################################################
# 03_main_analysis.R
# Social Network Minimum Wage Exposure - REVISED IDENTIFICATION STRATEGY
#
# This script implements the INCREMENTAL identification strategy:
#
# STEP 1: OLS with Full Network MW
#   - Endogenous variable: SCI-weighted MW (leave-own-county-out)
#   - Show descriptive association
#
# STEP 2: IV with Out-of-State Network MW
#   - Instrument: SCI-weighted MW (leave-own-state-out)
#   - First stage: Does out-of-state MW predict full network MW?
#   - Balancedness: Are pre-treatment outcomes balanced by IV?
#
# STEP 3: Distance Robustness
#   - More aggressive: Out-of-state MW at distance >= X km
#   - Find X where first stage is strong AND balancedness passes
#
# STEP 4: Compare Estimates
#   - OLS vs 2SLS (basic) vs 2SLS (distant)
#   - Interpret differences for mechanism understanding
################################################################################

source("00_packages.R")

cat("=== Main Analysis: Revised IV Strategy ===\n\n")

# ============================================================================
# 1. Load Data
# ============================================================================

cat("1. Loading analysis panel...\n")

panel <- readRDS("../data/analysis_panel.rds")

cat("  Observations:", format(nrow(panel), big.mark = ","), "\n")
cat("  Counties:", n_distinct(panel$county_fips), "\n")
cat("  Quarters:", n_distinct(panel$yearq), "\n")

has_qwi <- "log_emp" %in% names(panel)
cat("  Has QWI outcomes:", has_qwi, "\n\n")

if (!has_qwi) {
  stop("QWI outcome data required for regression analysis")
}

# Filter to complete cases for analysis
panel_reg <- panel %>%
  filter(!is.na(network_mw_full) & !is.na(network_mw_out_state) &
         !is.na(log_emp) & !is.na(state_fips))

cat("  Regression sample:", format(nrow(panel_reg), big.mark = ","), "\n\n")

# ============================================================================
# STEP 1: OLS WITH FULL NETWORK MW
# ============================================================================

cat("=== STEP 1: OLS WITH FULL NETWORK MW ===\n\n")

# 1A. Simple OLS (no state×time FE)
cat("1A. Simple OLS (county FE only)...\n")
ols_simple <- feols(
  log_emp ~ network_mw_full | county_fips + yearq,
  data = panel_reg,
  cluster = ~state_fips
)
cat("  Coefficient:", round(coef(ols_simple)[1], 4),
    "(SE:", round(se(ols_simple)[1], 4), ", p =",
    round(fixest::pvalue(ols_simple)[1], 4), ")\n")

# 1B. OLS with state×time FE (absorbs own-state MW)
cat("\n1B. OLS with state×time FE...\n")
ols_statetime <- feols(
  log_emp ~ network_mw_full | county_fips + state_fips^yearq,
  data = panel_reg,
  cluster = ~state_fips
)
cat("  Coefficient:", round(coef(ols_statetime)[1], 4),
    "(SE:", round(se(ols_statetime)[1], 4), ", p =",
    round(fixest::pvalue(ols_statetime)[1], 4), ")\n")

# 1C. Horse race with geographic exposure
cat("\n1C. Horse race: Network vs Geographic exposure...\n")
ols_horserace <- feols(
  log_emp ~ network_mw_full + geo_exposure | county_fips + state_fips^yearq,
  data = panel_reg,
  cluster = ~state_fips
)
cat("  Network MW:", round(coef(ols_horserace)["network_mw_full"], 4),
    "(p =", round(fixest::pvalue(ols_horserace)["network_mw_full"], 4), ")\n")
cat("  Geographic:", round(coef(ols_horserace)["geo_exposure"], 4),
    "(p =", round(fixest::pvalue(ols_horserace)["geo_exposure"], 4), ")\n")

# ============================================================================
# STEP 2: IV WITH OUT-OF-STATE NETWORK MW
# ============================================================================

cat("\n\n=== STEP 2: IV WITH OUT-OF-STATE NETWORK MW ===\n\n")

# 2A. First Stage
cat("2A. First Stage: Out-of-State MW → Full Network MW...\n")

first_stage <- feols(
  network_mw_full ~ network_mw_out_state | county_fips + state_fips^yearq,
  data = panel_reg,
  cluster = ~state_fips
)

# Get F-statistic
first_stage_f <- (coef(first_stage)[1] / se(first_stage)[1])^2

cat("  First stage coefficient:", round(coef(first_stage)[1], 4),
    "(SE:", round(se(first_stage)[1], 4), ")\n")
cat("  First stage F-statistic:", round(first_stage_f, 2), "\n")

if (first_stage_f > 10) {
  cat("  --> STRONG INSTRUMENT (F > 10)\n")
  iv_valid <- TRUE
} else if (first_stage_f > 5) {
  cat("  --> MODERATE INSTRUMENT (5 < F < 10)\n")
  iv_valid <- TRUE
} else {
  cat("  --> WEAK INSTRUMENT (F < 5)\n")
  iv_valid <- FALSE
}

# 2B. Balancedness Tests
cat("\n2B. Balancedness: Pre-Treatment Outcomes by IV Quartile...\n")

# Get 2012 values for balance test
panel_2012 <- panel_reg %>%
  filter(year == 2012) %>%
  group_by(county_fips) %>%
  summarise(
    log_emp_2012 = mean(log_emp, na.rm = TRUE),
    log_earn_2012 = mean(log_earn, na.rm = TRUE),
    network_mw_out_state_2012 = mean(network_mw_out_state, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    iv_quartile = ntile(network_mw_out_state_2012, 4)
  )

# Test balance
balance_emp <- lm(log_emp_2012 ~ factor(iv_quartile), data = panel_2012)
balance_earn <- lm(log_earn_2012 ~ factor(iv_quartile), data = panel_2012)

f_emp <- summary(balance_emp)$fstatistic
f_earn <- summary(balance_earn)$fstatistic

p_emp <- if (!is.null(f_emp)) pf(f_emp[1], f_emp[2], f_emp[3], lower.tail = FALSE) else NA
p_earn <- if (!is.null(f_earn)) pf(f_earn[1], f_earn[2], f_earn[3], lower.tail = FALSE) else NA

cat("  Balance test p-values:\n")
cat("    Log employment (2012): p =", round(p_emp, 4),
    if(p_emp > 0.05) "(PASS)" else "(FAIL)", "\n")
cat("    Log earnings (2012): p =", round(p_earn, 4),
    if(p_earn > 0.05) "(PASS)" else "(FAIL)", "\n")

balance_pass <- (p_emp > 0.05) & (p_earn > 0.05)

# Table of means by quartile
cat("\n  Pre-period means by IV quartile:\n")
balance_table <- panel_2012 %>%
  group_by(iv_quartile) %>%
  summarise(
    n = n(),
    log_emp = round(mean(log_emp_2012, na.rm = TRUE), 3),
    log_earn = round(mean(log_earn_2012, na.rm = TRUE), 3),
    iv_value = round(mean(network_mw_out_state_2012, na.rm = TRUE), 3),
    .groups = "drop"
  )
print(as.data.frame(balance_table))

# 2C. 2SLS Estimation
cat("\n2C. 2SLS Estimation...\n")

if (iv_valid) {
  iv_2sls <- feols(
    log_emp ~ 1 | county_fips + state_fips^yearq | network_mw_full ~ network_mw_out_state,
    data = panel_reg,
    cluster = ~state_fips
  )

  cat("  2SLS coefficient:", round(coef(iv_2sls)[1], 4),
      "(SE:", round(se(iv_2sls)[1], 4), ", p =",
      round(fixest::pvalue(iv_2sls)[1], 4), ")\n")

  # Compare to OLS
  cat("\n  Comparison:\n")
  cat("    OLS coefficient:", round(coef(ols_statetime)[1], 4), "\n")
  cat("    2SLS coefficient:", round(coef(iv_2sls)[1], 4), "\n")

  if (abs(coef(iv_2sls)[1]) > abs(coef(ols_statetime)[1])) {
    cat("    --> 2SLS > OLS: Attenuation bias in OLS (measurement error or downward bias)\n")
  } else {
    cat("    --> 2SLS < OLS: Possible selection bias in OLS (positive selection)\n")
  }
} else {
  cat("  Skipping 2SLS due to weak first stage\n")
  iv_2sls <- NULL
}

# ============================================================================
# STEP 3: DISTANCE ROBUSTNESS
# ============================================================================

cat("\n\n=== STEP 3: DISTANCE ROBUSTNESS ===\n\n")

# Try different distance thresholds
distance_thresholds <- c(0, 100, 150, 200, 250, 300, 400, 500)

distance_results <- list()

for (d in distance_thresholds) {
  iv_col <- paste0("iv_dist_", d)

  if (!iv_col %in% names(panel_reg)) {
    next
  }

  # Filter to observations with this IV
  panel_d <- panel_reg %>%
    filter(!is.na(.data[[iv_col]]))

  if (nrow(panel_d) < 10000) next

  # First stage
  fs_formula <- as.formula(paste("network_mw_full ~", iv_col, "| county_fips + state_fips^yearq"))
  fs <- tryCatch({
    feols(fs_formula, data = panel_d, cluster = ~state_fips)
  }, error = function(e) NULL)

  if (is.null(fs)) next

  fs_f <- (coef(fs)[1] / se(fs)[1])^2

  # 2SLS if first stage is strong enough
  if (fs_f > 5) {
    tsls_formula <- as.formula(paste("log_emp ~ 1 | county_fips + state_fips^yearq | network_mw_full ~", iv_col))
    tsls <- tryCatch({
      feols(tsls_formula, data = panel_d, cluster = ~state_fips)
    }, error = function(e) NULL)
  } else {
    tsls <- NULL
  }

  # Balance test for this distance
  panel_2012_d <- panel_d %>%
    filter(year == 2012) %>%
    group_by(county_fips) %>%
    summarise(
      log_emp_2012 = mean(log_emp, na.rm = TRUE),
      iv_2012 = mean(.data[[iv_col]], na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(iv_q = ntile(iv_2012, 4))

  bal <- lm(log_emp_2012 ~ factor(iv_q), data = panel_2012_d)
  f_bal <- summary(bal)$fstatistic
  p_bal <- if (!is.null(f_bal)) pf(f_bal[1], f_bal[2], f_bal[3], lower.tail = FALSE) else NA

  distance_results[[as.character(d)]] <- list(
    threshold = d,
    n_obs = nrow(panel_d),
    first_stage_coef = coef(fs)[1],
    first_stage_se = se(fs)[1],
    first_stage_f = fs_f,
    balance_p = p_bal,
    tsls_coef = if (!is.null(tsls)) coef(tsls)[1] else NA,
    tsls_se = if (!is.null(tsls)) se(tsls)[1] else NA,
    tsls_p = if (!is.null(tsls)) fixest::pvalue(tsls)[1] else NA
  )
}

# Print distance results table
cat("Distance threshold results:\n\n")
cat(sprintf("%6s %10s %8s %8s %10s %10s\n",
            "Dist", "N", "FS F", "Bal p", "2SLS", "2SLS SE"))
cat(paste(rep("-", 60), collapse = ""), "\n")

for (d in names(distance_results)) {
  r <- distance_results[[d]]
  cat(sprintf("%4d km %9d %8.2f %8.3f %10.4f %10.4f\n",
              r$threshold, r$n_obs, r$first_stage_f, r$balance_p,
              ifelse(is.na(r$tsls_coef), NA, r$tsls_coef),
              ifelse(is.na(r$tsls_se), NA, r$tsls_se)))
}

# Find "best" distance threshold: strong first stage AND balance passes
best_d <- NULL
for (d in names(distance_results)) {
  r <- distance_results[[d]]
  if (r$first_stage_f > 10 && !is.na(r$balance_p) && r$balance_p > 0.05) {
    best_d <- d
    break
  }
}

if (!is.null(best_d)) {
  cat("\n  --> Best distance threshold:", best_d, "km\n")
  cat("      First stage F:", round(distance_results[[best_d]]$first_stage_f, 2), "\n")
  cat("      Balance p:", round(distance_results[[best_d]]$balance_p, 3), "\n")
  cat("      2SLS estimate:", round(distance_results[[best_d]]$tsls_coef, 4), "\n")
}

# ============================================================================
# STEP 4: SUMMARY TABLE
# ============================================================================

cat("\n\n=== STEP 4: SUMMARY OF ESTIMATES ===\n\n")

cat("Main Results Table:\n\n")
cat(sprintf("%25s %10s %10s %10s\n", "Specification", "Coef", "SE", "p-value"))
cat(paste(rep("-", 60), collapse = ""), "\n")

# OLS simple
cat(sprintf("%25s %10.4f %10.4f %10.4f\n",
            "OLS (county FE)",
            coef(ols_simple)[1], se(ols_simple)[1], fixest::pvalue(ols_simple)[1]))

# OLS with state×time
cat(sprintf("%25s %10.4f %10.4f %10.4f\n",
            "OLS (state×time FE)",
            coef(ols_statetime)[1], se(ols_statetime)[1], fixest::pvalue(ols_statetime)[1]))

# 2SLS basic
if (!is.null(iv_2sls)) {
  cat(sprintf("%25s %10.4f %10.4f %10.4f\n",
              "2SLS (out-of-state IV)",
              coef(iv_2sls)[1], se(iv_2sls)[1], fixest::pvalue(iv_2sls)[1]))
}

# 2SLS distant
if (!is.null(best_d)) {
  r <- distance_results[[best_d]]
  cat(sprintf("%25s %10.4f %10.4f %10.4f\n",
              paste0("2SLS (", best_d, "km IV)"),
              r$tsls_coef, r$tsls_se, r$tsls_p))
}

cat(paste(rep("-", 60), collapse = ""), "\n")

# ============================================================================
# STEP 5: EARNINGS OUTCOME
# ============================================================================

cat("\n\n=== STEP 5: EARNINGS OUTCOME ===\n\n")

if ("log_earn" %in% names(panel_reg)) {
  ols_earn <- feols(
    log_earn ~ network_mw_full | county_fips + state_fips^yearq,
    data = panel_reg,
    cluster = ~state_fips
  )

  cat("OLS (log earnings):", round(coef(ols_earn)[1], 4),
      "(SE:", round(se(ols_earn)[1], 4), ", p =",
      round(fixest::pvalue(ols_earn)[1], 4), ")\n")

  if (iv_valid) {
    iv_earn <- feols(
      log_earn ~ 1 | county_fips + state_fips^yearq | network_mw_full ~ network_mw_out_state,
      data = panel_reg,
      cluster = ~state_fips
    )
    cat("2SLS (log earnings):", round(coef(iv_earn)[1], 4),
        "(SE:", round(se(iv_earn)[1], 4), ", p =",
        round(fixest::pvalue(iv_earn)[1], 4), ")\n")
  }
}

# ============================================================================
# STEP 6: REDUCED FORM
# ============================================================================

cat("\n\n=== STEP 6: REDUCED FORM ===\n\n")

reduced_form <- feols(
  log_emp ~ network_mw_out_state | county_fips + state_fips^yearq,
  data = panel_reg,
  cluster = ~state_fips
)

cat("Reduced Form (Out-of-State MW → Employment):\n")
cat("  Coefficient:", round(coef(reduced_form)[1], 4),
    "(SE:", round(se(reduced_form)[1], 4), ", p =",
    round(fixest::pvalue(reduced_form)[1], 4), ")\n")

# Check: 2SLS = Reduced Form / First Stage
if (iv_valid) {
  implied_2sls <- coef(reduced_form)[1] / coef(first_stage)[1]
  cat("\n  Verification:\n")
  cat("    Reduced Form / First Stage =", round(implied_2sls, 4), "\n")
  cat("    2SLS coefficient =", round(coef(iv_2sls)[1], 4), "\n")
}

# ============================================================================
# 7. SAVE RESULTS
# ============================================================================

cat("\n\n=== SAVING RESULTS ===\n\n")

results <- list(
  # OLS
  ols_simple = ols_simple,
  ols_statetime = ols_statetime,
  ols_horserace = ols_horserace,

  # First stage
  first_stage = first_stage,
  first_stage_f = first_stage_f,

  # Balance
  balance_table = balance_table,
  balance_pass = balance_pass,

  # 2SLS
  iv_2sls = iv_2sls,

  # Distance results
  distance_results = distance_results,
  best_distance = best_d,

  # Reduced form
  reduced_form = reduced_form,

  # Earnings
  ols_earn = if (exists("ols_earn")) ols_earn else NULL,
  iv_earn = if (exists("iv_earn")) iv_earn else NULL
)

saveRDS(results, "../data/main_results.rds")
cat("Saved main_results.rds\n")

# ============================================================================
# INTERPRETATION
# ============================================================================

cat("\n\n=== INTERPRETATION ===\n\n")

cat("KEY FINDING:\n")
if (first_stage_f > 10) {
  cat("  The out-of-state network MW is a STRONG instrument for full network MW.\n")
  cat("  First stage F =", round(first_stage_f, 1), "\n\n")

  if (!is.null(iv_2sls)) {
    if (fixest::pvalue(iv_2sls)[1] < 0.05) {
      cat("  The 2SLS estimate is statistically significant:\n")
      cat("    A 10% increase in network MW exposure is associated with\n")
      cat("    a", round(coef(iv_2sls)[1] * 0.1 * 100, 2), "% change in employment.\n")
    } else {
      cat("  The 2SLS estimate is not statistically significant.\n")
      cat("  This is consistent with network MW not affecting local employment,\n")
      cat("  OR with the effect being too small to detect with this sample.\n")
    }
  }
} else {
  cat("  The out-of-state network MW is a WEAK instrument.\n")
  cat("  First stage F =", round(first_stage_f, 1), "\n")
  cat("  This suggests strong correlation between out-of-state and in-state networks.\n")
}

cat("\n=== Analysis Complete ===\n")
