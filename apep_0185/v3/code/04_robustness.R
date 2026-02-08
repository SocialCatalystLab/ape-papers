################################################################################
# 04_robustness.R
# Social Network Spillovers of Minimum Wage
#
# Input:  data/analysis_panel.rds, data/main_results.rds
# Output: Robustness checks including randomization inference
################################################################################

source("00_packages.R")

cat("=== Robustness Checks ===\n\n")

# ============================================================================
# 1. Load Data
# ============================================================================

panel <- readRDS("../data/analysis_panel.rds")
state_mw_panel <- readRDS("../data/state_mw_panel.rds")
main_results <- readRDS("../data/main_results.rds")

cat("Loaded panel with", format(nrow(panel), big.mark = ","), "observations\n")

# Check for QWI outcomes
has_qwi <- "log_emp" %in% names(panel)

# ============================================================================
# 2. Exposure Permutation Inference
# ============================================================================
# NOTE: This is an EXPOSURE PERMUTATION test, not a traditional timing
# permutation. We permute the cross-sectional assignment of exposure values
# across counties within each time period, holding the temporal structure
# fixed. This tests the null hypothesis that the coefficient reflects
# spurious cross-sectional correlation rather than a true relationship
# between network exposure and outcomes.
#
# The permutation breaks the county-specific network exposure link while
# preserving:
#   - The marginal distribution of exposures in each period
#   - The panel structure (same counties over time)
#   - The fixed effects structure
#
# Under the null of no effect, permuted coefficients should be centered at 0.
# ============================================================================

cat("\n2. Exposure permutation inference (500 permutations)...\n")

# Get actual coefficient from main specification
actual_coef <- coef(main_results$tier2_shiftshare)[1]
cat("  Actual coefficient:", round(actual_coef, 4), "\n")

# Get list of states that raised minimum wage
treated_states <- state_mw_panel %>%
  filter(min_wage > 7.25) %>%
  pull(state_fips) %>%
  unique()

cat("  States with MW > federal:", length(treated_states), "\n")

# Function to recompute exposure with permuted timing
compute_permuted_exposure <- function(panel, state_mw_panel, seed) {
  set.seed(seed)

  # Shuffle which states raised MW when
  # Keep magnitudes but reassign timing across states
  mw_changes <- state_mw_panel %>%
    filter(min_wage > 7.25) %>%
    select(state_fips, year, quarter, min_wage) %>%
    distinct()

  # Permute state assignment
  unique_states <- unique(mw_changes$state_fips)
  permuted_states <- sample(unique_states)
  state_map <- setNames(permuted_states, unique_states)

  # Create permuted state MW panel
  state_mw_perm <- state_mw_panel %>%
    mutate(state_fips_orig = state_fips) %>%
    left_join(
      mw_changes %>% mutate(perm_state = state_map[state_fips]),
      by = c("state_fips", "year", "quarter")
    )

  # This is a simplified version - in practice would need to
  # recompute full exposure. Here we approximate by permuting
  # the exposure values across counties within each time period

  panel_perm <- panel %>%
    group_by(yearq) %>%
    mutate(
      social_exposure_perm = sample(social_exposure)
    ) %>%
    ungroup()

  return(panel_perm)
}

# Run permutation inference
set.seed(42)
n_perms <- 500
perm_coefs <- numeric(n_perms)

for (i in 1:n_perms) {
  if (i %% 100 == 0) cat("  Permutation", i, "/", n_perms, "\n")

  # Simple permutation: shuffle exposure across counties within time
  panel_perm <- panel %>%
    group_by(yearq) %>%
    mutate(social_exposure_perm = sample(social_exposure)) %>%
    ungroup()

  # Re-estimate with permuted exposure
  perm_fit <- tryCatch({
    feols(
      log_emp ~ social_exposure_perm | county_fips + state_fips^yearq,
      data = panel_perm,
      cluster = ~state_fips
    )
  }, error = function(e) NULL)

  if (!is.null(perm_fit)) {
    perm_coefs[i] <- coef(perm_fit)[1]
  } else {
    perm_coefs[i] <- NA
  }
}

# Calculate RI p-value (two-sided)
perm_coefs <- perm_coefs[!is.na(perm_coefs)]
ri_pval <- mean(abs(perm_coefs) >= abs(actual_coef))

cat("\nExposure permutation inference results:\n")
cat("  Actual coefficient:", round(actual_coef, 4), "\n")
cat("  Permutation mean:", round(mean(perm_coefs), 4), "\n")
cat("  Permutation SD:", round(sd(perm_coefs), 4), "\n")
cat("  Permutation p-value (two-sided):", round(ri_pval, 4), "\n")

# ============================================================================
# 3. Leave-One-State-Out Jackknife
# ============================================================================

cat("\n3. Leave-one-state-out jackknife...\n")

# Re-estimate excluding each state with large MW changes
major_mw_states <- c("06", "36", "53", "25", "12")  # CA, NY, WA, MA, FL

loso_results <- list()

for (st in major_mw_states) {
  panel_loso <- panel %>%
    filter(state_fips != st)

  loso_fit <- tryCatch({
    feols(
      log_emp ~ social_exposure | county_fips + state_fips^yearq,
      data = panel_loso,
      cluster = ~state_fips
    )
  }, error = function(e) NULL)

  if (!is.null(loso_fit)) {
    loso_results[[st]] <- list(
      coef = coef(loso_fit)[1],
      se = se(loso_fit)[1]
    )
  }
}

cat("\nLeave-one-state-out results:\n")
for (st in names(loso_results)) {
  state_name <- case_when(
    st == "06" ~ "CA",
    st == "36" ~ "NY",
    st == "53" ~ "WA",
    st == "25" ~ "MA",
    st == "12" ~ "FL",
    TRUE ~ st
  )
  cat("  Excl.", state_name, ":", round(loso_results[[st]]$coef, 4),
      "(SE:", round(loso_results[[st]]$se, 4), ")\n")
}

# ============================================================================
# 4. Alternative Exposure Specifications
# ============================================================================

cat("\n4. Alternative exposure specifications...\n")

# 4a. Geographic exposure only
geo_only <- feols(
  log_emp ~ geo_exposure | county_fips + state_fips^yearq,
  data = panel,
  cluster = ~state_fips
)

cat("  Geography only:", round(coef(geo_only)[1], 4),
    "(SE:", round(se(geo_only)[1], 4), ")\n")

# 4b. Orthogonalized social exposure (residual from geo)
ortho_only <- feols(
  log_emp ~ social_exposure_resid | county_fips + state_fips^yearq,
  data = panel,
  cluster = ~state_fips
)

cat("  Orthogonal social only:", round(coef(ortho_only)[1], 4),
    "(SE:", round(se(ortho_only)[1], 4), ")\n")

# 4c. Horse race (from main results)
cat("  Horse race social:", round(coef(main_results$tier3_horserace)["social_exposure"], 4), "\n")
cat("  Horse race geo:", round(coef(main_results$tier3_horserace)["geo_exposure"], 4), "\n")

# ============================================================================
# 5. Lagged Exposure
# ============================================================================

cat("\n5. Lagged exposure effects...\n")

# Create lagged exposure
panel <- panel %>%
  group_by(county_fips) %>%
  arrange(yearq) %>%
  mutate(
    social_exposure_lag1 = lag(social_exposure, 1),
    social_exposure_lag2 = lag(social_exposure, 2),
    social_exposure_lag4 = lag(social_exposure, 4)
  ) %>%
  ungroup()

# Test different lags
lag1_fit <- feols(
  log_emp ~ social_exposure_lag1 | county_fips + state_fips^yearq,
  data = filter(panel, !is.na(social_exposure_lag1)),
  cluster = ~state_fips
)

lag2_fit <- feols(
  log_emp ~ social_exposure_lag2 | county_fips + state_fips^yearq,
  data = filter(panel, !is.na(social_exposure_lag2)),
  cluster = ~state_fips
)

lag4_fit <- feols(
  log_emp ~ social_exposure_lag4 | county_fips + state_fips^yearq,
  data = filter(panel, !is.na(social_exposure_lag4)),
  cluster = ~state_fips
)

cat("  Contemporaneous:", round(actual_coef, 4), "\n")
cat("  1-quarter lag:", round(coef(lag1_fit)[1], 4), "\n")
cat("  2-quarter lag:", round(coef(lag2_fit)[1], 4), "\n")
cat("  4-quarter lag:", round(coef(lag4_fit)[1], 4), "\n")

# ============================================================================
# 6. Industry Placebo (Low-Bite Industries)
# ============================================================================

cat("\n6. Industry placebo test...\n")

# Check if we have industry-level data with enough observations
n_high_bite <- sum(panel$industry_type == "High Bite", na.rm = TRUE)
n_low_bite <- sum(panel$industry_type == "Low Bite", na.rm = TRUE)

if (has_qwi && n_high_bite > 1000 && n_low_bite > 1000) {

  # High-bite should have effect
  high_bite_check <- feols(
    log_emp ~ social_exposure | county_fips + state_fips^yearq,
    data = filter(panel, industry_type == "High Bite"),
    cluster = ~state_fips
  )

  # Low-bite should have NO effect (placebo)
  low_bite_check <- feols(
    log_emp ~ social_exposure | county_fips + state_fips^yearq,
    data = filter(panel, industry_type == "Low Bite"),
    cluster = ~state_fips
  )

  cat("  High-bite industries:", round(coef(high_bite_check)[1], 4),
      "(p =", round(fixest::pvalue(high_bite_check)[1], 4), ")\n")
  cat("  Low-bite industries:", round(coef(low_bite_check)[1], 4),
      "(p =", round(fixest::pvalue(low_bite_check)[1], 4), ")\n")

  # Difference test
  if (fixest::pvalue(low_bite_check)[1] > 0.1) {
    cat("  --> Placebo passed: Low-bite industries show no significant effect\n")
  }

  placebo_industry <- list(high_bite = high_bite_check, low_bite = low_bite_check)
} else {
  cat("  Skipping (aggregate data only, no industry breakdown)\n")
  cat("  High-bite obs:", n_high_bite, ", Low-bite obs:", n_low_bite, "\n")
  placebo_industry <- NULL
}

# ============================================================================
# 7. Exposure Terciles (Nonlinearity Check)
# ============================================================================

cat("\n7. Nonlinearity check (exposure terciles)...\n")

# With county FE, we can't directly estimate tercile level effects (collinear)
# Instead, interact exposure with tercile to test for nonlinearity
nonlinear_fit <- tryCatch({
  feols(
    log_emp ~ social_exposure:social_exposure_cat | county_fips + state_fips^yearq,
    data = panel,
    cluster = ~state_fips
  )
}, error = function(e) {
  cat("  WARNING: Nonlinearity test failed -", e$message, "\n")
  NULL
})

if (!is.null(nonlinear_fit)) {
  cat("  Low tercile × exposure:", round(coef(nonlinear_fit)[1], 4), "\n")
  cat("  Medium tercile × exposure:", round(coef(nonlinear_fit)[2], 4), "\n")
  cat("  High tercile × exposure:", round(coef(nonlinear_fit)[3], 4), "\n")
} else {
  cat("  Skipping nonlinearity check\n")
}

# ============================================================================
# 8. Different Time Windows
# ============================================================================

cat("\n8. Different sample periods...\n")

# Pre-2020 (avoid COVID)
pre_covid <- feols(
  log_emp ~ social_exposure | county_fips + state_fips^yearq,
  data = filter(panel, year < 2020),
  cluster = ~state_fips
)

# Post-2015 (after major MW increases began)
post_2015 <- feols(
  log_emp ~ social_exposure | county_fips + state_fips^yearq,
  data = filter(panel, year >= 2015),
  cluster = ~state_fips
)

cat("  Full sample:", round(actual_coef, 4), "\n")
cat("  Pre-2020:", round(coef(pre_covid)[1], 4), "\n")
cat("  Post-2015:", round(coef(post_2015)[1], 4), "\n")

# ============================================================================
# 9. Conley Spatial Standard Errors (Approximation)
# ============================================================================

cat("\n9. Alternative clustering...\n")

# State clustering (baseline)
se_state <- se(main_results$tier2_shiftshare)[1]

# Network community clustering
if ("network_cluster" %in% names(panel)) {
  net_cluster_fit <- feols(
    log_emp ~ social_exposure | county_fips + state_fips^yearq,
    data = panel,
    cluster = ~network_cluster
  )
  se_network <- se(net_cluster_fit)[1]
} else {
  se_network <- NA
}

cat("  SE (state cluster):", round(se_state, 4), "\n")
if (!is.na(se_network)) {
  cat("  SE (network cluster):", round(se_network, 4), "\n")
}

# ============================================================================
# 10. Save Robustness Results
# ============================================================================

cat("\n10. Saving robustness results...\n")

robustness <- list(
  # Randomization inference
  ri_pval = ri_pval,
  perm_coefs = perm_coefs,

  # Leave-one-out
  loso_results = loso_results,

  # Alternative specifications
  geo_only = geo_only,
  ortho_only = ortho_only,

  # Lags
  lag1 = lag1_fit,
  lag2 = lag2_fit,
  lag4 = lag4_fit,

  # Industry placebo
  placebo_industry = placebo_industry,

  # Nonlinearity
  nonlinear_fit = nonlinear_fit,

  # Time windows
  pre_covid = pre_covid,
  post_2015 = post_2015
)

saveRDS(robustness, "../data/robustness_results.rds")

cat("  Saved robustness_results.rds\n")

# ============================================================================
# Summary
# ============================================================================

cat("\n=== Robustness Summary ===\n\n")

cat("Inference:\n")
cat("  Exposure permutation p-value:", round(ri_pval, 4), "\n")
cat("  State-clustered SE:", round(se_state, 4), "\n")

cat("\nLeave-One-Out (main coefficient:", round(actual_coef, 4), "):\n")
for (st in names(loso_results)) {
  cat("  Excl.", st, ":", round(loso_results[[st]]$coef, 4), "\n")
}

cat("\nMechanism (Horse Race):\n")
cat("  Social exposure adds info beyond geography: p =",
    round(wald(main_results$tier3_horserace, "social_exposure")$p, 4), "\n")

if (!is.null(placebo_industry)) {
  cat("\nPlacebo:\n")
  cat("  Low-bite industries (should be ~0):",
      round(coef(placebo_industry$low_bite)[1], 4), "\n")
}

cat("\nConclusion: Results are",
    ifelse(ri_pval < 0.1, "robust", "sensitive"),
    "to inference method.\n")
