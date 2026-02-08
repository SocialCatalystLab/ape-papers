################################################################################
# 03b_iv_validation.R
# Social Network Spillovers of Minimum Wage - IV Validation Tests
#
# Input:  data/analysis_panel.rds, data/iv_panel.rds
# Output: Goldsmith-Pinkham et al. (2020) validation tests for shift-share IV
#
# Tests implemented:
# 1. Variance decomposition - How concentrated is IV variation?
# 2. Balance tests - Are pre-treatment characteristics balanced by IV quartile?
# 3. Pre-trends by IV quartile - Differential pre-trends?
# 4. Leave-one-state-out - Robustness to dropping major shock states
################################################################################

source("00_packages.R")

cat("=== IV Validation: Goldsmith-Pinkham et al. (2020) Tests ===\n\n")

# ============================================================================
# 1. Load Data
# ============================================================================

cat("1. Loading data...\n")

panel <- readRDS("../data/analysis_panel.rds")
iv_panel <- readRDS("../data/iv_panel.rds")
state_mw_panel <- readRDS("../data/state_mw_panel.rds")

# Merge IV instruments with main panel
panel_iv <- panel %>%
  left_join(iv_panel %>% select(county_fips, year, quarter,
                                 iv_mw_200_400, iv_mw_400_600, iv_mw_600_800),
            by = c("county_fips", "year", "quarter")) %>%
  filter(!is.na(iv_mw_400_600))

cat("  Panel observations:", format(nrow(panel_iv), big.mark = ","), "\n")
cat("  Counties:", n_distinct(panel_iv$county_fips), "\n")

# Check for QWI outcomes
has_qwi <- "log_emp" %in% names(panel_iv)

# ============================================================================
# 2. Variance Decomposition
# ============================================================================

cat("\n2. Variance decomposition of IV...\n")

# How much of IV variation comes from different sources?

# Total variance
total_var <- var(panel_iv$iv_mw_400_600, na.rm = TRUE)

# Cross-sectional (between-county) variance
county_means <- panel_iv %>%
  group_by(county_fips) %>%
  summarise(mean_iv = mean(iv_mw_400_600, na.rm = TRUE)) %>%
  ungroup()
between_var <- var(county_means$mean_iv, na.rm = TRUE)

# Time-series (within-county) variance
panel_iv <- panel_iv %>%
  group_by(county_fips) %>%
  mutate(iv_demeaned = iv_mw_400_600 - mean(iv_mw_400_600, na.rm = TRUE)) %>%
  ungroup()
within_var <- var(panel_iv$iv_demeaned, na.rm = TRUE)

cat("  Total IV variance:", round(total_var, 6), "\n")
cat("  Between-county variance:", round(between_var, 6),
    "(", round(100*between_var/total_var, 1), "%)\n")
cat("  Within-county variance:", round(within_var, 6),
    "(", round(100*within_var/total_var, 1), "%)\n")

# Variance by state (how concentrated are the shocks?)
state_contrib <- panel_iv %>%
  group_by(state_fips) %>%
  summarise(
    var_iv = var(iv_mw_400_600, na.rm = TRUE),
    n_obs = n(),
    .groups = "drop"
  ) %>%
  mutate(
    weighted_var = var_iv * n_obs / sum(n_obs),
    pct_contrib = 100 * weighted_var / sum(weighted_var)
  ) %>%
  arrange(desc(pct_contrib))

cat("\n  Top 5 states by IV variance contribution:\n")
print(head(state_contrib %>% select(state_fips, pct_contrib), 5))

# ============================================================================
# 3. Balance Tests
# ============================================================================

cat("\n3. Balance tests (pre-period characteristics by IV quartile)...\n")

# Create IV quartiles based on pre-period (2012) values
pre_period_iv <- panel_iv %>%
  filter(year == 2012) %>%
  group_by(county_fips) %>%
  summarise(iv_2012 = mean(iv_mw_400_600, na.rm = TRUE), .groups = "drop")

pre_period_iv <- pre_period_iv %>%
  mutate(
    iv_quartile = ntile(iv_2012, 4),
    iv_quartile_f = factor(iv_quartile, labels = c("Q1 (Low)", "Q2", "Q3", "Q4 (High)"))
  )

# Merge quartiles back
panel_iv <- panel_iv %>%
  left_join(pre_period_iv %>% select(county_fips, iv_quartile, iv_quartile_f),
            by = "county_fips")

# Get pre-period (2012) characteristics
pre_chars <- panel_iv %>%
  filter(year == 2012) %>%
  group_by(county_fips, iv_quartile_f) %>%
  summarise(
    log_emp_pre = mean(log_emp, na.rm = TRUE),
    log_earn_pre = mean(log_earn, na.rm = TRUE),
    social_exposure_pre = mean(social_exposure, na.rm = TRUE),
    geo_exposure_pre = mean(geo_exposure, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(!is.na(iv_quartile_f))

# Balance table by quartile
balance_table <- pre_chars %>%
  group_by(iv_quartile_f) %>%
  summarise(
    N = n(),
    Mean_Log_Emp = mean(log_emp_pre, na.rm = TRUE),
    SD_Log_Emp = sd(log_emp_pre, na.rm = TRUE),
    Mean_Log_Earn = mean(log_earn_pre, na.rm = TRUE),
    Mean_Social_Exp = mean(social_exposure_pre, na.rm = TRUE),
    Mean_Geo_Exp = mean(geo_exposure_pre, na.rm = TRUE),
    .groups = "drop"
  )

cat("\n  Balance table (pre-period means by IV quartile):\n")
print(balance_table)

# F-tests for balance
cat("\n  F-tests for balance (H0: equal means across quartiles):\n")

balance_tests <- list()

if (has_qwi) {
  # Test for log employment
  bal_emp <- lm(log_emp_pre ~ iv_quartile_f, data = pre_chars)
  bal_emp_f <- anova(bal_emp)
  f_emp <- bal_emp_f$`F value`[1]
  p_emp <- bal_emp_f$`Pr(>F)`[1]
  cat("  Log Employment: F =", round(f_emp, 2), ", p =", round(p_emp, 4), "\n")
  balance_tests$log_emp <- list(f = f_emp, p = p_emp)

  # Test for log earnings
  bal_earn <- lm(log_earn_pre ~ iv_quartile_f, data = pre_chars)
  bal_earn_f <- anova(bal_earn)
  f_earn <- bal_earn_f$`F value`[1]
  p_earn <- bal_earn_f$`Pr(>F)`[1]
  cat("  Log Earnings: F =", round(f_earn, 2), ", p =", round(p_earn, 4), "\n")
  balance_tests$log_earn <- list(f = f_earn, p = p_earn)
}

# Test for social exposure
bal_social <- lm(social_exposure_pre ~ iv_quartile_f, data = pre_chars)
bal_social_f <- anova(bal_social)
f_social <- bal_social_f$`F value`[1]
p_social <- bal_social_f$`Pr(>F)`[1]
cat("  Social Exposure: F =", round(f_social, 2), ", p =", round(p_social, 4), "\n")
balance_tests$social_exposure <- list(f = f_social, p = p_social)

# ============================================================================
# 4. Pre-Trends by IV Quartile
# ============================================================================

cat("\n4. Pre-trends by IV quartile...\n")

if (has_qwi) {
  # Event study by IV quartile
  # For each quartile, estimate differential trends

  panel_iv$year_f <- factor(panel_iv$year)

  # Estimate event study for each quartile
  es_by_quartile <- list()

  for (q in 1:4) {
    es_q <- tryCatch({
      feols(
        log_emp ~ i(year_f, ref = 2012) | county_fips + state_fips^yearq,
        data = filter(panel_iv, iv_quartile == q),
        cluster = ~state_fips
      )
    }, error = function(e) NULL)

    if (!is.null(es_q)) {
      es_by_quartile[[q]] <- tibble(
        quartile = q,
        year = as.numeric(levels(panel_iv$year_f)[-1]),  # Exclude reference year
        coef = coef(es_q),
        se = se(es_q)
      )
    }
  }

  if (length(es_by_quartile) > 0) {
    es_combined <- bind_rows(es_by_quartile) %>%
      mutate(
        ci_low = coef - 1.96 * se,
        ci_high = coef + 1.96 * se
      )

    # Pre-2015 coefficients
    pre_trends <- es_combined %>%
      filter(year < 2015) %>%
      group_by(quartile) %>%
      summarise(
        mean_coef = mean(coef, na.rm = TRUE),
        max_coef = max(abs(coef), na.rm = TRUE),
        .groups = "drop"
      )

    cat("\n  Pre-period (2012-2014) coefficient summary by IV quartile:\n")
    print(pre_trends)

    # Test for differential pre-trends
    # Compare Q4 vs Q1
    pre_q1 <- es_combined %>% filter(quartile == 1 & year < 2015)
    pre_q4 <- es_combined %>% filter(quartile == 4 & year < 2015)

    if (nrow(pre_q1) > 0 & nrow(pre_q4) > 0) {
      diff_pre <- mean(pre_q4$coef, na.rm = TRUE) - mean(pre_q1$coef, na.rm = TRUE)
      cat("\n  Q4 - Q1 pre-period difference:", round(diff_pre, 4), "\n")
    }
  }
}

# ============================================================================
# 5. Leave-One-State-Out Robustness
# ============================================================================

cat("\n5. Leave-one-state-out robustness...\n")

# Major minimum wage shock states
major_mw_states <- c("06", "36", "53", "25", "12")  # CA, NY, WA, MA, FL
state_names <- c("California", "New York", "Washington", "Massachusetts", "Florida")

loso_results <- list()

# Full sample baseline
full_iv <- feols(
  log_emp ~ 1 | county_fips + state_fips^yearq | social_exposure ~ iv_mw_400_600,
  data = panel_iv,
  cluster = ~state_fips
)

loso_results[["Full Sample"]] <- list(
  coef = coef(full_iv)[1],
  se = se(full_iv)[1],
  n = nrow(panel_iv)
)

# Leave each state out
for (i in seq_along(major_mw_states)) {
  st <- major_mw_states[i]
  st_name <- state_names[i]

  panel_loso <- panel_iv %>%
    filter(state_fips != st)

  loso_fit <- tryCatch({
    feols(
      log_emp ~ 1 | county_fips + state_fips^yearq | social_exposure ~ iv_mw_400_600,
      data = panel_loso,
      cluster = ~state_fips
    )
  }, error = function(e) NULL)

  if (!is.null(loso_fit)) {
    loso_results[[paste0("Excl. ", st_name)]] <- list(
      coef = coef(loso_fit)[1],
      se = se(loso_fit)[1],
      n = nrow(panel_loso)
    )
  }
}

cat("\n  Leave-one-state-out IV results:\n")
for (name in names(loso_results)) {
  res <- loso_results[[name]]
  cat("  ", name, ":", round(res$coef, 4),
      "(SE:", round(res$se, 4), "), N =", format(res$n, big.mark = ","), "\n")
}

# ============================================================================
# 6. Overidentification Test (Multiple Instruments)
# ============================================================================

cat("\n6. Overidentification test (multiple instruments)...\n")

# Use all three distance windows as instruments
iv_overid <- tryCatch({
  feols(
    log_emp ~ 1 | county_fips + state_fips^yearq |
      social_exposure ~ iv_mw_200_400 + iv_mw_400_600 + iv_mw_600_800,
    data = panel_iv %>% filter(!is.na(iv_mw_200_400) & !is.na(iv_mw_600_800)),
    cluster = ~state_fips
  )
}, error = function(e) NULL)

if (!is.null(iv_overid)) {
  # Sargan-Hansen J test
  # Note: fixest computes this automatically for overidentified models
  cat("  Coefficient with 3 instruments:", round(coef(iv_overid)[1], 4),
      "(SE:", round(se(iv_overid)[1], 4), ")\n")

  # Compare single vs multiple instruments
  cat("  Compare to single instrument (400-600km):", round(coef(full_iv)[1], 4), "\n")
}

# ============================================================================
# 7. Save Validation Results
# ============================================================================

cat("\n7. Saving validation results...\n")

validation_results <- list(
  # Variance decomposition
  variance = list(
    total = total_var,
    between = between_var,
    within = within_var,
    state_contrib = state_contrib
  ),

  # Balance tests
  balance_table = balance_table,
  balance_tests = balance_tests,

  # Pre-trends
  es_by_quartile = if(exists("es_combined")) es_combined else NULL,

  # Leave-one-out
  loso_results = loso_results,

  # Overidentification
  iv_overid = iv_overid
)

saveRDS(validation_results, "../data/iv_validation_results.rds")
cat("  Saved iv_validation_results.rds\n")

# ============================================================================
# Summary
# ============================================================================

cat("\n=== IV Validation Complete ===\n\n")

cat("VALIDATION SUMMARY:\n")
cat("1. Variance decomposition:\n")
cat("   - Between-county:", round(100*between_var/total_var, 1), "%\n")
cat("   - Within-county:", round(100*within_var/total_var, 1), "%\n")

cat("2. Balance tests (p-values > 0.1 = PASS):\n")
if (has_qwi) {
  cat("   - Log Employment:", round(balance_tests$log_emp$p, 3),
      if(balance_tests$log_emp$p > 0.1) "PASS" else "FAIL", "\n")
}
cat("   - Social Exposure:", round(balance_tests$social_exposure$p, 3),
    if(balance_tests$social_exposure$p > 0.1) "PASS" else "CONCERN", "\n")

cat("3. Leave-one-state-out:\n")
coef_range <- range(sapply(loso_results, function(x) x$coef))
cat("   - Coefficient range: [", round(coef_range[1], 4), ", ",
    round(coef_range[2], 4), "]\n", sep = "")
cat("   - Stability:", if(diff(coef_range) < 0.1) "STABLE" else "SENSITIVE", "\n")
