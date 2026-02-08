################################################################################
# 03c_political_outcomes.R
# Social Network Spillovers of Minimum Wage - Political Economy Extension
#
# Input:  data/analysis_panel.rds, data/iv_panel.rds, data/raw_presidential_county.rds
# Output: Political economy results (GOP vote share as outcome)
#
# This analysis examines whether network minimum wage exposure affects
# Republican vote share at the county level. Two possible interpretations:
#   1. Null finding: Validates exclusion restriction (MW doesn't affect votes directly)
#   2. Significant finding: Novel political economy result (network information diffusion)
################################################################################

source("00_packages.R")

cat("=== Political Economy Extension: GOP Vote Share ===\n\n")

# ============================================================================
# 1. Load Data
# ============================================================================

cat("1. Loading data...\n")

panel <- readRDS("../data/analysis_panel.rds")
iv_panel <- readRDS("../data/iv_panel.rds")

# Load election data
if (!file.exists("../data/raw_presidential_county.rds")) {
  cat("  ERROR: Election data not found. Run 01_fetch_data.R first.\n")
  stop("Election data required for political outcomes analysis")
}

election <- readRDS("../data/raw_presidential_county.rds")

cat("  Panel observations:", format(nrow(panel), big.mark = ","), "\n")
cat("  Election observations:", format(nrow(election), big.mark = ","), "\n")

# Check if election data has actual content
if (nrow(election) == 0) {
  cat("\n  WARNING: Election data is empty. Cannot proceed with political analysis.\n")
  cat("  Please ensure 01_fetch_data.R successfully downloads election data.\n")

  # Create placeholder results
  political_results <- list(
    data_available = FALSE,
    error = "Election data not available"
  )
  saveRDS(political_results, "../data/political_results.rds")
  stop("Election data required")
}

# ============================================================================
# 2. Construct Election Panel
# ============================================================================

cat("\n2. Constructing election panel...\n")

# Election years: 2008, 2012, 2016, 2020
# Match to Q4 of election year (November elections)
election_years <- c(2008, 2012, 2016, 2020)

# Get Q4 exposure for each election year
exposure_election <- panel %>%
  filter(quarter == 4 & year %in% election_years) %>%
  group_by(county_fips, year) %>%
  summarise(
    state_fips = first(state_fips),
    social_exposure = mean(social_exposure, na.rm = TRUE),
    geo_exposure = mean(geo_exposure, na.rm = TRUE),
    own_log_mw = mean(own_log_mw, na.rm = TRUE),
    .groups = "drop"
  )

# Get IV values for election years
iv_election <- iv_panel %>%
  filter(quarter == 4 & year %in% election_years) %>%
  select(county_fips, year, iv_mw_200_400, iv_mw_400_600, iv_mw_600_800)

# Merge exposure with election data
panel_election <- election %>%
  left_join(exposure_election, by = c("county_fips", "year")) %>%
  left_join(iv_election, by = c("county_fips", "year")) %>%
  filter(!is.na(social_exposure) & !is.na(rep_share))

cat("  Merged election panel:", format(nrow(panel_election), big.mark = ","), "county-elections\n")
cat("  Counties:", n_distinct(panel_election$county_fips), "\n")
cat("  Elections:", n_distinct(panel_election$year), "\n")

# ============================================================================
# 3. Summary Statistics
# ============================================================================

cat("\n3. Summary statistics...\n")

election_summary <- panel_election %>%
  group_by(year) %>%
  summarise(
    N = n(),
    Mean_Rep_Share = mean(rep_share, na.rm = TRUE),
    SD_Rep_Share = sd(rep_share, na.rm = TRUE),
    Mean_Network_Exp = mean(social_exposure, na.rm = TRUE),
    SD_Network_Exp = sd(social_exposure, na.rm = TRUE),
    .groups = "drop"
  )

cat("\n  By election year:\n")
print(election_summary)

# ============================================================================
# 4. OLS: Network Exposure and GOP Vote Share
# ============================================================================

cat("\n4. OLS regressions...\n")

# Specification 1: County FE + Year FE
ols_baseline <- feols(
  rep_share ~ social_exposure | county_fips + year,
  data = panel_election,
  cluster = ~state_fips
)

cat("  Baseline (county + year FE):\n")
cat("    Coefficient:", round(coef(ols_baseline)[1], 4),
    "(SE:", round(se(ols_baseline)[1], 4), ")\n")
cat("    P-value:", round(pvalue(ols_baseline)[1], 4), "\n")

# Specification 2: County FE + State x Year FE
ols_stateyear <- feols(
  rep_share ~ social_exposure | county_fips + state_fips^year,
  data = panel_election,
  cluster = ~state_fips
)

cat("  State x Year FE:\n")
cat("    Coefficient:", round(coef(ols_stateyear)[1], 4),
    "(SE:", round(se(ols_stateyear)[1], 4), ")\n")
cat("    P-value:", round(pvalue(ols_stateyear)[1], 4), "\n")

# Specification 3: Horse race with geographic exposure
ols_horserace <- feols(
  rep_share ~ social_exposure + geo_exposure | county_fips + state_fips^year,
  data = panel_election,
  cluster = ~state_fips
)

cat("  Horse race:\n")
cat("    Social:", round(coef(ols_horserace)["social_exposure"], 4),
    "(SE:", round(se(ols_horserace)["social_exposure"], 4), ")\n")
cat("    Geographic:", round(coef(ols_horserace)["geo_exposure"], 4),
    "(SE:", round(se(ols_horserace)["geo_exposure"], 4), ")\n")

# ============================================================================
# 5. IV/2SLS: Instrumented Network Exposure
# ============================================================================

cat("\n5. IV/2SLS estimation...\n")

# Filter to non-missing IV
panel_election_iv <- panel_election %>%
  filter(!is.na(iv_mw_400_600))

cat("  IV sample:", format(nrow(panel_election_iv), big.mark = ","), "county-elections\n")

# First stage for election panel
first_stage_pol <- feols(
  social_exposure ~ iv_mw_400_600 | county_fips + state_fips^year,
  data = panel_election_iv,
  cluster = ~state_fips
)

first_stage_f_pol <- (coef(first_stage_pol)[1] / se(first_stage_pol)[1])^2

cat("  First stage coefficient:", round(coef(first_stage_pol)[1], 4),
    "(SE:", round(se(first_stage_pol)[1], 4), ")\n")
cat("  First stage F-stat:", round(first_stage_f_pol, 2), "\n")

# Reduced form
reduced_form_pol <- feols(
  rep_share ~ iv_mw_400_600 | county_fips + state_fips^year,
  data = panel_election_iv,
  cluster = ~state_fips
)

cat("  Reduced form coefficient:", round(coef(reduced_form_pol)[1], 4),
    "(SE:", round(se(reduced_form_pol)[1], 4), ")\n")
cat("  P-value:", round(pvalue(reduced_form_pol)[1], 4), "\n")

# 2SLS
iv_2sls_pol <- feols(
  rep_share ~ 1 | county_fips + state_fips^year | social_exposure ~ iv_mw_400_600,
  data = panel_election_iv,
  cluster = ~state_fips
)

cat("  2SLS coefficient:", round(coef(iv_2sls_pol)[1], 4),
    "(SE:", round(se(iv_2sls_pol)[1], 4), ")\n")
cat("  P-value:", round(pvalue(iv_2sls_pol)[1], 4), "\n")

# ============================================================================
# 6. Interpretation
# ============================================================================

cat("\n6. Interpretation...\n")

# Calculate 95% CI for 2SLS
ci_low <- coef(iv_2sls_pol)[1] - 1.96 * se(iv_2sls_pol)[1]
ci_high <- coef(iv_2sls_pol)[1] + 1.96 * se(iv_2sls_pol)[1]

cat("\n  2SLS estimate: ", round(coef(iv_2sls_pol)[1], 4),
    " [95% CI: ", round(ci_low, 4), ", ", round(ci_high, 4), "]\n", sep = "")

# Check if CI includes zero
if (ci_low < 0 & ci_high > 0) {
  cat("\n  INTERPRETATION: Cannot reject null hypothesis that network MW\n")
  cat("  exposure has no effect on Republican vote share.\n")
  cat("  This is CONSISTENT with the exclusion restriction:\n")
  cat("  -> Distant MW exposure affects outcomes only through local network exposure,\n")
  cat("  -> not through direct effects on voting behavior.\n")
} else {
  if (coef(iv_2sls_pol)[1] > 0) {
    cat("\n  INTERPRETATION: Higher network MW exposure associated with\n")
    cat("  HIGHER Republican vote share. Possible mechanisms:\n")
    cat("  -> Backlash against MW increases in connected states\n")
    cat("  -> Economic hardship from MW spillovers\n")
  } else {
    cat("\n  INTERPRETATION: Higher network MW exposure associated with\n")
    cat("  LOWER Republican vote share. Possible mechanisms:\n")
    cat("  -> Information diffusion about benefits of higher MW\n")
    cat("  -> Social influence from connections in high-MW states\n")
  }
}

# ============================================================================
# 7. Heterogeneity: 2016 vs 2020
# ============================================================================

cat("\n7. Heterogeneity by election year...\n")

for (yr in c(2016, 2020)) {
  iv_yr <- tryCatch({
    feols(
      rep_share ~ 1 | county_fips | social_exposure ~ iv_mw_400_600,
      data = filter(panel_election_iv, year == yr),
      cluster = ~state_fips
    )
  }, error = function(e) NULL)

  if (!is.null(iv_yr)) {
    cat("  ", yr, " election: ", round(coef(iv_yr)[1], 4),
        " (SE: ", round(se(iv_yr)[1], 4), ")\n", sep = "")
  }
}

# ============================================================================
# 8. Change Specification (First Differences)
# ============================================================================

cat("\n8. First-difference specification (change in vote share)...\n")

# Calculate changes between elections
panel_election_wide <- panel_election_iv %>%
  select(county_fips, state_fips, year, rep_share, social_exposure, iv_mw_400_600) %>%
  pivot_wider(
    names_from = year,
    values_from = c(rep_share, social_exposure, iv_mw_400_600)
  )

# 2012-2016 change
if ("rep_share_2012" %in% names(panel_election_wide) &
    "rep_share_2016" %in% names(panel_election_wide)) {

  panel_fd_1216 <- panel_election_wide %>%
    filter(!is.na(rep_share_2012) & !is.na(rep_share_2016)) %>%
    mutate(
      d_rep_share = rep_share_2016 - rep_share_2012,
      d_exposure = social_exposure_2016 - social_exposure_2012,
      d_iv = iv_mw_400_600_2016 - iv_mw_400_600_2012
    ) %>%
    filter(!is.na(d_iv))

  if (nrow(panel_fd_1216) > 100) {
    fd_ols_1216 <- lm(d_rep_share ~ d_exposure, data = panel_fd_1216)
    cat("  2012-2016 FD-OLS:", round(coef(fd_ols_1216)[2], 4), "\n")

    fd_iv_1216 <- ivreg(d_rep_share ~ d_exposure | d_iv, data = panel_fd_1216)
    cat("  2012-2016 FD-IV:", round(coef(fd_iv_1216)[2], 4), "\n")
  }
}

# 2016-2020 change
if ("rep_share_2016" %in% names(panel_election_wide) &
    "rep_share_2020" %in% names(panel_election_wide)) {

  panel_fd_1620 <- panel_election_wide %>%
    filter(!is.na(rep_share_2016) & !is.na(rep_share_2020)) %>%
    mutate(
      d_rep_share = rep_share_2020 - rep_share_2016,
      d_exposure = social_exposure_2020 - social_exposure_2016,
      d_iv = iv_mw_400_600_2020 - iv_mw_400_600_2016
    ) %>%
    filter(!is.na(d_iv))

  if (nrow(panel_fd_1620) > 100) {
    fd_ols_1620 <- lm(d_rep_share ~ d_exposure, data = panel_fd_1620)
    cat("  2016-2020 FD-OLS:", round(coef(fd_ols_1620)[2], 4), "\n")

    fd_iv_1620 <- tryCatch({
      ivreg(d_rep_share ~ d_exposure | d_iv, data = panel_fd_1620)
    }, error = function(e) NULL)
    if (!is.null(fd_iv_1620)) {
      cat("  2016-2020 FD-IV:", round(coef(fd_iv_1620)[2], 4), "\n")
    }
  }
}

# ============================================================================
# 9. Save Results
# ============================================================================

cat("\n9. Saving results...\n")

political_results <- list(
  data_available = TRUE,
  panel_election = panel_election,

  # OLS
  ols_baseline = ols_baseline,
  ols_stateyear = ols_stateyear,
  ols_horserace = ols_horserace,

  # IV
  first_stage = first_stage_pol,
  first_stage_f = first_stage_f_pol,
  reduced_form = reduced_form_pol,
  iv_2sls = iv_2sls_pol,

  # Summary
  election_summary = election_summary
)

saveRDS(political_results, "../data/political_results.rds")
cat("  Saved political_results.rds\n")

# ============================================================================
# Summary
# ============================================================================

cat("\n=== Political Economy Analysis Complete ===\n\n")

cat("KEY FINDINGS:\n")
cat("1. OLS (state x year FE):", round(coef(ols_stateyear)[1], 4),
    "(p =", round(pvalue(ols_stateyear)[1], 4), ")\n")
cat("2. First stage F-stat:", round(first_stage_f_pol, 2), "\n")
cat("3. Reduced form:", round(coef(reduced_form_pol)[1], 4),
    "(p =", round(pvalue(reduced_form_pol)[1], 4), ")\n")
cat("4. 2SLS:", round(coef(iv_2sls_pol)[1], 4),
    "(p =", round(pvalue(iv_2sls_pol)[1], 4), ")\n")

cat("\nCONCLUSION:\n")
if (pvalue(reduced_form_pol)[1] > 0.1) {
  cat("-> Reduced form is insignificant (p > 0.1)\n")
  cat("-> SUPPORTS exclusion restriction for employment IV analysis\n")
} else {
  cat("-> Reduced form is significant (p < 0.1)\n")
  cat("-> NOVEL political economy finding\n")
}
