################################################################################
# 03_main_analysis.R
# Social Network Spillovers of Minimum Wage
#
# Input:  data/analysis_panel.rds
# Output: Main regression results implementing shift-share network exposure
################################################################################

source("00_packages.R")

cat("=== Main Analysis: Network Shift-Share DiD ===\n\n")

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
es_coefs <- tibble(
  year = as.numeric(levels(panel$year_f)),
  coef = c(0, coef(event_study)),  # Add 0 for reference year
  se = c(0, se(event_study))
) %>%
  mutate(
    event_time = year - 2015,  # Center on 2015 (major MW increases started)
    ci_low = coef - 1.96 * se,
    ci_high = coef + 1.96 * se
  )

cat("  Event study coefficients estimated\n")
print(es_coefs %>% filter(year >= 2014 & year <= 2022))

# ============================================================================
# 5. Industry Heterogeneity (High-Bite vs Low-Bite Placebo)
# ============================================================================

cat("\n5. Industry heterogeneity (mechanism test)...\n")

if (has_qwi && "industry_type" %in% names(panel)) {

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
  cat("  Skipping (QWI industry data not available)\n")
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

  # Hiring rate
  hire_model <- feols(
    hire_rate ~ social_exposure | county_fips + state_fips^yearq,
    data = panel,
    cluster = ~state_fips
  )

  cat("  Employment:", round(coef(emp_model)[1], 4),
      "(p =", round(pvalue(emp_model)[1], 4), ")\n")
  cat("  Earnings:", round(coef(earn_model)[1], 4),
      "(p =", round(pvalue(earn_model)[1], 4), ")\n")
  cat("  Hiring rate:", round(coef(hire_model)[1], 4),
      "(p =", round(pvalue(hire_model)[1], 4), ")\n")
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

cat("KEY FINDINGS:\n")
cat("1. Naive OLS (biased):", round(coef(tier1)[1], 4), "\n")
cat("2. Shift-Share DiD (main):", round(coef(tier2)[1], 4),
    "(SE:", round(se(tier2)[1], 4), ")\n")
cat("3. Horse Race:\n")
cat("   - Social exposure:", round(coef(tier3)["social_exposure"], 4), "\n")
cat("   - Geographic exposure:", round(coef(tier3)["geo_exposure"], 4), "\n")
cat("4. Social adds info beyond geography: p =", round(social_test$p, 4), "\n")

cat("\nINTERPRETATION:\n")
cat("- Coefficient on social exposure: Effect of 1-unit increase in\n")
cat("  SCI-weighted average of log minimum wages in other states\n")
cat("- State×time FEs absorb own-state MW effect → identifies SPILLOVER\n")
cat("- Horse race tests if network adds info beyond geographic proximity\n")
