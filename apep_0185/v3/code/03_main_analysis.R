################################################################################
# 03_main_analysis.R
# Social Network Spillovers of Minimum Wage
#
# Input:  data/analysis_panel.rds
# Output: Main regression results implementing shift-share network exposure
################################################################################

source("00_packages.R")

cat("=== Main Analysis: Continuous Network Exposure Effects ===\n\n")

# ============================================================================
# METHODOLOGY NOTE:
# This analysis uses a CONTINUOUS EXPOSURE DESIGN, not a traditional DiD.
# The treatment variable (social_exposure) is a continuous SCI-weighted
# average of minimum wages in socially connected states, not a binary
# treatment indicator.
#
# The specification is:
#   log_emp_{c,t} = beta * NetworkExposure_{c,t} + alpha_c + gamma_{s,t} + eps
#
# Where:
#   - NetworkExposure is continuous (not 0/1)
#   - County FE (alpha_c) absorb time-invariant county characteristics
#   - State x Time FE (gamma_{s,t}) absorb own-state minimum wage effects
#   - beta captures the spillover effect through social networks
#
# This is similar to a shift-share design where:
#   - "Shares" = SCI weights to other states (pre-determined network)
#   - "Shifts" = minimum wage changes in those states
# ============================================================================

# ============================================================================
# 1. Load Data
# ============================================================================

cat("1. Loading analysis panel...\n")

panel <- readRDS("../data/analysis_panel.rds")

cat("  Observations:", format(nrow(panel), big.mark = ","), "\n")
cat("  Counties:", n_distinct(panel$county_fips), "\n")
cat("  Quarters:", n_distinct(panel$yearq), "\n")

# Check for QWI outcomes
has_qwi <- "log_emp" %in% names(panel)
cat("  Has QWI outcomes:", has_qwi, "\n")

# If we have QWI data, use it; otherwise use exposure variation only
if (has_qwi) {
  cat("  Industries:", n_distinct(panel$industry), "\n")
  outcome_var <- "log_emp"
} else {
  cat("  NOTE: This is a DESCRIPTIVE paper - no outcome regressions performed.\n")
  cat("  The analysis focuses on constructing and characterizing the exposure measure.\n")
  cat("  See 05_figures.R for the main descriptive outputs.\n")
  outcome_var <- NULL
}

# ============================================================================
# 2. Three-Tiered Estimation Strategy
# ============================================================================
# GUARD: Only run regressions if outcome data (QWI) is available
# ============================================================================

if (!has_qwi) {
  cat("\n2. Skipping regression analysis (QWI outcome data not available).\n")
  cat("   This is a DESCRIPTIVE paper - see 05_figures.R for main outputs.\n\n")

  # Create placeholder results for saving
  tier1 <- NULL
  tier2 <- NULL
  tier3 <- NULL
  tier3_ortho <- NULL
  event_study <- NULL
  es_coefs <- NULL
  high_bite <- NULL
  low_bite <- NULL
  emp_model <- NULL
  earn_model <- NULL
  hire_model <- NULL

} else {

cat("\n2. Three-tiered estimation strategy...\n")

# ----------------------------------------------------------------------------
# Tier 1: Naive OLS (Biased Baseline)
# ----------------------------------------------------------------------------

cat("\n  Tier 1: Naive OLS...\n")

tier1 <- feols(
  log_emp ~ social_exposure | county_fips + yearq,
  data = panel,
  cluster = ~state_fips
)

cat("  Social exposure effect:", round(coef(tier1)[1], 4),
    "(SE:", round(se(tier1)[1], 4), ")\n")

# ----------------------------------------------------------------------------
# Tier 2: Shift-Share with State × Time FEs (Main Specification)
# ----------------------------------------------------------------------------

cat("\n  Tier 2: Shift-Share with State x Time FEs...\n")

# State × time FEs absorb own-state minimum wage effect
# This isolates the SPILLOVER effect through networks

tier2 <- feols(
  log_emp ~ social_exposure | county_fips + state_fips^yearq,
  data = panel,
  cluster = ~state_fips
)

cat("  Social exposure effect:", round(coef(tier2)[1], 4),
    "(SE:", round(se(tier2)[1], 4), ")\n")

# ----------------------------------------------------------------------------
# Tier 3: Horse Race with Geography (Mechanism Separation)
# ----------------------------------------------------------------------------

cat("\n  Tier 3: Horse race (social vs. geographic exposure)...\n")

tier3 <- feols(
  log_emp ~ social_exposure + geo_exposure | county_fips + state_fips^yearq,
  data = panel,
  cluster = ~state_fips
)

cat("  Social exposure:", round(coef(tier3)["social_exposure"], 4),
    "(SE:", round(se(tier3)["social_exposure"], 4), ")\n")
cat("  Geographic exposure:", round(coef(tier3)["geo_exposure"], 4),
    "(SE:", round(se(tier3)["geo_exposure"], 4), ")\n")

# Test if social exposure adds information beyond geography
social_test <- wald(tier3, "social_exposure")
cat("  F-test for social | geo: F =", round(social_test$stat, 2),
    ", p =", round(social_test$p, 4), "\n")

# ============================================================================
# 3. Orthogonalized Exposure (Pure Network Effect)
# ============================================================================

cat("\n3. Orthogonalized exposure (residual from geography)...\n")

# Use the pre-computed residualized exposure
tier3_ortho <- feols(
  log_emp ~ social_exposure_resid + geo_exposure | county_fips + state_fips^yearq,
  data = panel,
  cluster = ~state_fips
)

cat("  Orthogonal social exposure:", round(coef(tier3_ortho)["social_exposure_resid"], 4),
    "(SE:", round(se(tier3_ortho)["social_exposure_resid"], 4), ")\n")

# ============================================================================
# 4. Event Study (Dynamics)
# ============================================================================

cat("\n4. Event study design...\n")

# Create exposure change relative to baseline (2012)
panel <- panel %>%
  group_by(county_fips) %>%
  mutate(
    social_exposure_base = social_exposure[yearq == 2012][1],
    social_exposure_change = social_exposure - social_exposure_base
  ) %>%
  ungroup()

# Create year dummies interacted with exposure change
panel$year_f <- factor(panel$year)

# Verify that mean_social_exposure exists (it is pre-computed in analysis_panel.rds)
if (!"mean_social_exposure" %in% names(panel)) {
  stop("mean_social_exposure not found in panel - ensure analysis_panel.rds was properly constructed")
}

# Event study: interact baseline exposure with year dummies
# NOTE: mean_social_exposure is pre-computed in 02_clean_data.R and stored in analysis_panel.rds
event_study <- feols(
  log_emp ~ i(year_f, mean_social_exposure, ref = 2012) | county_fips + state_fips^yearq,
  data = panel,
  cluster = ~state_fips
)

# Extract event study coefficients
# NOTE: Reference year (2012) is normalized to 0 by construction - it has
# no standard error because it is the baseline against which other years
# are compared. We use NA (not 0) to indicate this is undefined, not zero.
es_coefs <- tibble(
  year = as.numeric(levels(panel$year_f)),
  coef = c(0, coef(event_study)),  # Reference year normalized to 0
  se = c(NA_real_, se(event_study))  # SE undefined for reference year (NA, not 0)
) %>%
  mutate(
    event_time = year - 2015,  # Center on 2015 (major MW increases started)
    # CI is NA for reference year since SE is undefined
    ci_low = ifelse(is.na(se), NA_real_, coef - 1.96 * se),
    ci_high = ifelse(is.na(se), NA_real_, coef + 1.96 * se)
  )

cat("  Event study coefficients estimated\n")
print(es_coefs %>% filter(year >= 2014 & year <= 2022))

# ============================================================================
# 5. Industry Heterogeneity (High-Bite vs Low-Bite Placebo)
# ============================================================================

cat("\n5. Industry heterogeneity (mechanism test)...\n")

# Check if we have industry-level data (not just aggregate)
n_high_bite <- sum(panel$industry_type == "High Bite", na.rm = TRUE)
n_low_bite <- sum(panel$industry_type == "Low Bite", na.rm = TRUE)

if (has_qwi && n_high_bite > 1000 && n_low_bite > 1000) {

  # High-bite industries (Retail, Accommodation/Food)
  high_bite <- feols(
    log_emp ~ social_exposure | county_fips + state_fips^yearq,
    data = filter(panel, industry_type == "High Bite"),
    cluster = ~state_fips
  )

  # Low-bite industries (Finance, Professional Services) - PLACEBO
  low_bite <- feols(
    log_emp ~ social_exposure | county_fips + state_fips^yearq,
    data = filter(panel, industry_type == "Low Bite"),
    cluster = ~state_fips
  )

  cat("  High-bite industries:", round(coef(high_bite)[1], 4),
      "(SE:", round(se(high_bite)[1], 4), ")\n")
  cat("  Low-bite industries (placebo):", round(coef(low_bite)[1], 4),
      "(SE:", round(se(low_bite)[1], 4), ")\n")

  # Difference test
  cat("  Expected: Large effect in high-bite, small/zero in low-bite\n")

} else {
  cat("  Skipping (aggregate data only, no industry breakdown)\n")
  cat("  High-bite obs:", n_high_bite, ", Low-bite obs:", n_low_bite, "\n")
  high_bite <- NULL
  low_bite <- NULL
}

# ============================================================================
# 6. Multi-way Clustering (State + Network Community)
# ============================================================================

cat("\n6. Inference with network-based clustering...\n")

# Standard state clustering
se_state <- se(tier2)

# Try network community clustering if available
if ("network_cluster" %in% names(panel)) {
  tier2_netcluster <- feols(
    log_emp ~ social_exposure | county_fips + state_fips^yearq,
    data = panel,
    cluster = ~network_cluster
  )
  se_network <- se(tier2_netcluster)

  cat("  SE (state cluster):", round(se_state[1], 4), "\n")
  cat("  SE (network cluster):", round(se_network[1], 4), "\n")
} else {
  cat("  Network clusters not available\n")
  se_network <- NA
}

# ============================================================================
# 7. Different Outcome Variables
# ============================================================================

cat("\n7. Different outcome variables...\n")

if (has_qwi) {
  # Employment
  emp_model <- feols(
    log_emp ~ social_exposure | county_fips + state_fips^yearq,
    data = panel,
    cluster = ~state_fips
  )

  # Earnings
  earn_model <- feols(
    log_earn ~ social_exposure | county_fips + state_fips^yearq,
    data = panel,
    cluster = ~state_fips
  )

  cat("  Employment:", round(coef(emp_model)[1], 4),
      "(p =", round(fixest::pvalue(emp_model)[1], 4), ")\n")
  cat("  Earnings:", round(coef(earn_model)[1], 4),
      "(p =", round(fixest::pvalue(earn_model)[1], 4), ")\n")

  # Hiring rate (only if available)
  if ("hire_rate" %in% names(panel)) {
    hire_model <- feols(
      hire_rate ~ social_exposure | county_fips + state_fips^yearq,
      data = panel,
      cluster = ~state_fips
    )
    cat("  Hiring rate:", round(coef(hire_model)[1], 4),
        "(p =", round(fixest::pvalue(hire_model)[1], 4), ")\n")
  } else {
    hire_model <- NULL
    cat("  Hiring rate: Not available\n")
  }
} else {
  emp_model <- tier2
  earn_model <- NULL
  hire_model <- NULL
}

# ============================================================================
# 8. Pre-Trends Test (Event Study)
# ============================================================================

cat("\n8. Pre-trends test...\n")

# Test that pre-2015 coefficients are jointly zero
pre_years <- es_coefs %>% filter(year < 2015 & year != 2012)
if (nrow(pre_years) > 0) {
  pre_terms <- paste0("year_f::", pre_years$year, ":mean_social_exposure")
  pre_test <- tryCatch({
    wald(event_study, pre_terms)
  }, error = function(e) {
    list(stat = NA, p = NA)
  })

  if (!is.na(pre_test$stat)) {
    cat("  Joint F-test of pre-trends: F =", round(pre_test$stat, 2),
        ", p =", round(pre_test$p, 4), "\n")
    if (pre_test$p > 0.05) {
      cat("  --> Parallel trends assumption supported\n")
    } else {
      cat("  --> WARNING: Pre-trends may be violated\n")
    }
  }
}

} # End of has_qwi block

# ============================================================================
# 9. Save Results
# ============================================================================

cat("\n9. Saving results...\n")

results <- list(
  # Main specifications
  tier1_naive = tier1,
  tier2_shiftshare = tier2,
  tier3_horserace = tier3,
  tier3_ortho = tier3_ortho,

  # Event study
  event_study = event_study,
  es_coefs = es_coefs,

  # Industry heterogeneity
  high_bite = high_bite,
  low_bite = low_bite,

  # Different outcomes
  emp_model = emp_model,
  earn_model = earn_model,
  hire_model = hire_model
)

saveRDS(results, "../data/main_results.rds")

cat("  Saved main_results.rds\n")

# ============================================================================
# Summary
# ============================================================================

cat("\n=== Main Analysis Complete ===\n\n")

if (has_qwi && !is.null(tier1)) {
  cat("KEY FINDINGS:\n")
  cat("1. Naive OLS (biased):", round(coef(tier1)[1], 4), "\n")
  cat("2. Network Exposure (main):", round(coef(tier2)[1], 4),
      "(SE:", round(se(tier2)[1], 4), ")\n")
  cat("3. Horse Race:\n")
  cat("   - Social exposure:", round(coef(tier3)["social_exposure"], 4), "\n")
  cat("   - Geographic exposure:", round(coef(tier3)["geo_exposure"], 4), "\n")
  cat("4. Social adds info beyond geography: p =", round(social_test$p, 4), "\n")

  cat("\nINTERPRETATION:\n")
  cat("- Coefficient on social exposure: Effect of 1-unit increase in\n")
  cat("  SCI-weighted average of log minimum wages in other states\n")
  cat("- State x Time FEs absorb own-state MW effect -> identifies SPILLOVER\n")
  cat("- Horse race tests if network adds info beyond geographic proximity\n")
} else {
  cat("No regression results (QWI outcome data not available).\n")
  cat("This is a descriptive paper focusing on exposure measure construction.\n")
}

# ============================================================================
# 10. IV/2SLS ESTIMATION WITH DISTANCE-BASED INSTRUMENTS
# ============================================================================

cat("\n=== IV/2SLS Analysis with Distance-Based Instruments ===\n\n")

# Load IV panel
if (file.exists("../data/iv_panel.rds")) {
  iv_panel <- readRDS("../data/iv_panel.rds")
  cat("10. Loading IV instruments...\n")
  cat("  IV panel rows:", format(nrow(iv_panel), big.mark = ","), "\n")

  # Merge IV instruments with main panel
  panel_iv <- panel %>%
    left_join(iv_panel %>% select(county_fips, year, quarter,
                                   iv_mw_200_400, iv_mw_400_600, iv_mw_600_800),
              by = c("county_fips", "year", "quarter"))

  cat("  Merged panel rows:", format(nrow(panel_iv), big.mark = ","), "\n")
  cat("  Non-missing IV (200-400):", sum(!is.na(panel_iv$iv_mw_200_400)), "\n")

  # Use 400-600km as primary instrument (good balance of variation and exclusion)
  panel_iv <- panel_iv %>%
    filter(!is.na(iv_mw_400_600))

  cat("  Analysis sample (non-missing IV):", format(nrow(panel_iv), big.mark = ","), "\n")

  # --------------------------------------------------------------------------
  # 10.1 First Stage: Does distant MW predict local network MW?
  # --------------------------------------------------------------------------

  cat("\n10.1 First stage regression...\n")

  first_stage <- feols(
    social_exposure ~ iv_mw_400_600 | county_fips + state_fips^yearq,
    data = panel_iv,
    cluster = ~state_fips
  )

  # Get F-statistic (manual calculation for first stage regression)
  first_stage_f <- (coef(first_stage)[1] / se(first_stage)[1])^2

  cat("  First stage coefficient:", round(coef(first_stage)[1], 4),
      "(SE:", round(se(first_stage)[1], 4), ")\n")
  cat("  First stage F-statistic:", round(first_stage_f, 2), "\n")

  if (first_stage_f > 10) {
    cat("  --> STRONG INSTRUMENT (F > 10)\n")
  } else {
    cat("  --> WARNING: Weak instrument (F < 10)\n")
  }

  # --------------------------------------------------------------------------
  # 10.2 Reduced Form: Does distant MW directly affect employment?
  # --------------------------------------------------------------------------

  cat("\n10.2 Reduced form regression...\n")

  reduced_form <- feols(
    log_emp ~ iv_mw_400_600 | county_fips + state_fips^yearq,
    data = panel_iv,
    cluster = ~state_fips
  )

  cat("  Reduced form coefficient:", round(coef(reduced_form)[1], 4),
      "(SE:", round(se(reduced_form)[1], 4), ")\n")
  cat("  P-value:", round(fixest::pvalue(reduced_form)[1], 4), "\n")

  # --------------------------------------------------------------------------
  # 10.3 2SLS: Instrumented network exposure effect
  # --------------------------------------------------------------------------

  cat("\n10.3 2SLS estimation...\n")

  iv_2sls <- feols(
    log_emp ~ 1 | county_fips + state_fips^yearq | social_exposure ~ iv_mw_400_600,
    data = panel_iv,
    cluster = ~state_fips
  )

  cat("  2SLS coefficient:", round(coef(iv_2sls)[1], 4),
      "(SE:", round(se(iv_2sls)[1], 4), ")\n")
  cat("  P-value:", round(fixest::pvalue(iv_2sls)[1], 4), "\n")

  # Compare to OLS
  ols_compare <- feols(
    log_emp ~ social_exposure | county_fips + state_fips^yearq,
    data = panel_iv,
    cluster = ~state_fips
  )

  cat("\n  Comparison OLS vs 2SLS:\n")
  cat("    OLS coefficient:", round(coef(ols_compare)[1], 4), "\n")
  cat("    2SLS coefficient:", round(coef(iv_2sls)[1], 4), "\n")
  cat("    Ratio (2SLS/OLS):", round(coef(iv_2sls)[1] / coef(ols_compare)[1], 2), "\n")

  # --------------------------------------------------------------------------
  # 10.4 Distance Window Robustness
  # --------------------------------------------------------------------------

  cat("\n10.4 Distance window robustness...\n")

  # 200-400km window
  iv_2sls_200 <- tryCatch({
    feols(
      log_emp ~ 1 | county_fips + state_fips^yearq | social_exposure ~ iv_mw_200_400,
      data = panel_iv %>% filter(!is.na(iv_mw_200_400)),
      cluster = ~state_fips
    )
  }, error = function(e) NULL)

  # 600-800km window
  iv_2sls_600 <- tryCatch({
    feols(
      log_emp ~ 1 | county_fips + state_fips^yearq | social_exposure ~ iv_mw_600_800,
      data = panel_iv %>% filter(!is.na(iv_mw_600_800)),
      cluster = ~state_fips
    )
  }, error = function(e) NULL)

  cat("  200-400km window:", if(!is.null(iv_2sls_200)) round(coef(iv_2sls_200)[1], 4) else "NA", "\n")
  cat("  400-600km window:", round(coef(iv_2sls)[1], 4), "(main)\n")
  cat("  600-800km window:", if(!is.null(iv_2sls_600)) round(coef(iv_2sls_600)[1], 4) else "NA", "\n")

  # --------------------------------------------------------------------------
  # 10.5 First-Difference Specification
  # --------------------------------------------------------------------------

  cat("\n10.5 First-difference specification...\n")

  # Construct first differences
  panel_fd <- panel_iv %>%
    arrange(county_fips, yearq) %>%
    group_by(county_fips) %>%
    mutate(
      d_log_emp = log_emp - lag(log_emp),
      d_social_exposure = social_exposure - lag(social_exposure),
      d_iv_mw_400_600 = iv_mw_400_600 - lag(iv_mw_400_600)
    ) %>%
    ungroup() %>%
    filter(!is.na(d_log_emp) & !is.na(d_iv_mw_400_600))

  cat("  First-differenced panel:", format(nrow(panel_fd), big.mark = ","), "obs\n")

  # FD-OLS
  fd_ols <- feols(
    d_log_emp ~ d_social_exposure | yearq,
    data = panel_fd,
    cluster = ~state_fips
  )

  # FD-2SLS
  fd_iv <- feols(
    d_log_emp ~ 1 | yearq | d_social_exposure ~ d_iv_mw_400_600,
    data = panel_fd,
    cluster = ~state_fips
  )

  cat("  FD-OLS coefficient:", round(coef(fd_ols)[1], 4),
      "(SE:", round(se(fd_ols)[1], 4), ")\n")
  cat("  FD-2SLS coefficient:", round(coef(fd_iv)[1], 4),
      "(SE:", round(se(fd_iv)[1], 4), ")\n")

  # --------------------------------------------------------------------------
  # Save IV Results
  # --------------------------------------------------------------------------

  iv_results <- list(
    first_stage = first_stage,
    first_stage_f = first_stage_f,
    reduced_form = reduced_form,
    iv_2sls = iv_2sls,
    ols_compare = ols_compare,
    iv_2sls_200 = iv_2sls_200,
    iv_2sls_600 = iv_2sls_600,
    fd_ols = fd_ols,
    fd_iv = fd_iv
  )

  saveRDS(iv_results, "../data/iv_results.rds")
  cat("\n  Saved iv_results.rds\n")

  # Add to main results
  results$iv_results <- iv_results
  saveRDS(results, "../data/main_results.rds")

  cat("\n=== IV/2SLS Analysis Complete ===\n\n")

  cat("KEY IV FINDINGS:\n")
  cat("1. First stage F-stat:", round(first_stage_f, 2),
      if(first_stage_f > 10) "(STRONG)" else "(WEAK)", "\n")
  cat("2. 2SLS coefficient:", round(coef(iv_2sls)[1], 4),
      "(p =", round(fixest::pvalue(iv_2sls)[1], 4), ")\n")
  cat("3. OLS coefficient:", round(coef(ols_compare)[1], 4), "\n")
  cat("4. FD-2SLS coefficient:", round(coef(fd_iv)[1], 4), "\n")

} else {
  cat("10. IV panel not found - skipping IV analysis.\n")
  cat("    Run 02b_construct_iv.R first to create the instruments.\n")
}
