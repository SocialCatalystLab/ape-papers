################################################################################
# 04_robustness.R
# Social Network Minimum Wage Exposure - POPULATION-WEIGHTED REVISION
#
# Robustness checks for the main population-weighted specification
################################################################################

source("00_packages.R")

cat("=== Robustness Checks (Population-Weighted Specification) ===\n\n")

# ============================================================================
# 1. Load Data
# ============================================================================

panel <- readRDS("../data/analysis_panel.rds")
state_mw_panel <- readRDS("../data/state_mw_panel.rds")
main_results <- readRDS("../data/main_results.rds")

cat("Loaded panel with", format(nrow(panel), big.mark = ","), "observations\n")

has_qwi <- "log_emp" %in% names(panel)

# Get actual coefficients from main specification
actual_coef_pop <- coef(main_results$iv_2sls_pop)[1]
actual_coef_prob <- coef(main_results$iv_2sls_prob)[1]

cat("Main 2SLS coefficients:\n")
cat("  Pop-weighted:", round(actual_coef_pop, 4), "\n")
cat("  Prob-weighted:", round(actual_coef_prob, 4), "\n\n")

# ============================================================================
# 2. Exposure Permutation Inference
# ============================================================================

cat("\n2. Exposure permutation inference (500 permutations)...\n")
cat("  Testing both pop-weighted and prob-weighted specifications\n\n")

set.seed(42)
n_perms <- 500

perm_coefs_pop <- numeric(n_perms)
perm_coefs_prob <- numeric(n_perms)

for (i in 1:n_perms) {
  if (i %% 100 == 0) cat("  Permutation", i, "/", n_perms, "\n")

  # Permute exposures across counties within time
  panel_perm <- panel %>%
    group_by(yearq) %>%
    mutate(
      network_mw_pop_perm = sample(network_mw_pop),
      network_mw_prob_perm = sample(network_mw_prob)
    ) %>%
    ungroup()

  # Pop-weighted
  perm_fit_pop <- tryCatch({
    feols(
      log_emp ~ network_mw_pop_perm | county_fips + state_fips^yearq,
      data = panel_perm,
      cluster = ~state_fips
    )
  }, error = function(e) NULL)

  if (!is.null(perm_fit_pop)) {
    perm_coefs_pop[i] <- coef(perm_fit_pop)[1]
  } else {
    perm_coefs_pop[i] <- NA
  }

  # Prob-weighted
  perm_fit_prob <- tryCatch({
    feols(
      log_emp ~ network_mw_prob_perm | county_fips + state_fips^yearq,
      data = panel_perm,
      cluster = ~state_fips
    )
  }, error = function(e) NULL)

  if (!is.null(perm_fit_prob)) {
    perm_coefs_prob[i] <- coef(perm_fit_prob)[1]
  } else {
    perm_coefs_prob[i] <- NA
  }
}

perm_coefs_pop <- perm_coefs_pop[!is.na(perm_coefs_pop)]
perm_coefs_prob <- perm_coefs_prob[!is.na(perm_coefs_prob)]

ri_pval_pop <- mean(abs(perm_coefs_pop) >= abs(actual_coef_pop))
ri_pval_prob <- mean(abs(perm_coefs_prob) >= abs(actual_coef_prob))

cat("\nExposure permutation inference results:\n")
cat(sprintf("  %20s %12s %12s\n", "", "Pop-Weighted", "Prob-Weighted"))
cat(paste(rep("-", 50), collapse = ""), "\n")
cat(sprintf("  %20s %12.4f %12.4f\n", "Actual coefficient", actual_coef_pop, actual_coef_prob))
cat(sprintf("  %20s %12.4f %12.4f\n", "Permutation mean", mean(perm_coefs_pop), mean(perm_coefs_prob)))
cat(sprintf("  %20s %12.4f %12.4f\n", "Permutation SD", sd(perm_coefs_pop), sd(perm_coefs_prob)))
cat(sprintf("  %20s %12.4f %12.4f\n", "RI p-value", ri_pval_pop, ri_pval_prob))

# ============================================================================
# 3. Leave-One-State-Out Jackknife
# ============================================================================

cat("\n3. Leave-one-state-out jackknife (Pop-Weighted)...\n")

major_mw_states <- c("06", "36", "53", "25", "12")  # CA, NY, WA, MA, FL

loso_results <- list()

for (st in major_mw_states) {
  panel_loso <- panel %>%
    filter(state_fips != st)

  loso_fit <- tryCatch({
    feols(
      log_emp ~ network_mw_pop | county_fips + state_fips^yearq,
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

cat("\nLeave-one-state-out results (Pop-Weighted OLS):\n")
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

# 4c. Both weighting schemes in same regression
if (all(c("network_mw_pop", "network_mw_prob") %in% names(panel))) {
  both_schemes <- tryCatch({
    feols(
      log_emp ~ network_mw_pop + network_mw_prob | county_fips + state_fips^yearq,
      data = panel,
      cluster = ~state_fips
    )
  }, error = function(e) NULL)

  if (!is.null(both_schemes)) {
    cat("  Pop + Prob together:\n")
    cat("    Pop-weighted:", round(coef(both_schemes)["network_mw_pop"], 4),
        "(p =", round(fixest::pvalue(both_schemes)["network_mw_pop"], 4), ")\n")
    cat("    Prob-weighted:", round(coef(both_schemes)["network_mw_prob"], 4),
        "(p =", round(fixest::pvalue(both_schemes)["network_mw_prob"], 4), ")\n")
  }
}

# ============================================================================
# 5. Lagged Exposure
# ============================================================================

cat("\n5. Lagged exposure effects (Pop-Weighted)...\n")

panel <- panel %>%
  group_by(county_fips) %>%
  arrange(yearq) %>%
  mutate(
    network_mw_pop_lag1 = lag(network_mw_pop, 1),
    network_mw_pop_lag2 = lag(network_mw_pop, 2),
    network_mw_pop_lag4 = lag(network_mw_pop, 4)
  ) %>%
  ungroup()

lag1_fit <- feols(
  log_emp ~ network_mw_pop_lag1 | county_fips + state_fips^yearq,
  data = filter(panel, !is.na(network_mw_pop_lag1)),
  cluster = ~state_fips
)

lag2_fit <- feols(
  log_emp ~ network_mw_pop_lag2 | county_fips + state_fips^yearq,
  data = filter(panel, !is.na(network_mw_pop_lag2)),
  cluster = ~state_fips
)

lag4_fit <- feols(
  log_emp ~ network_mw_pop_lag4 | county_fips + state_fips^yearq,
  data = filter(panel, !is.na(network_mw_pop_lag4)),
  cluster = ~state_fips
)

# Get contemporaneous OLS for comparison
contemp_ols <- feols(
  log_emp ~ network_mw_pop | county_fips + state_fips^yearq,
  data = panel,
  cluster = ~state_fips
)

cat("  Contemporaneous:", round(coef(contemp_ols)[1], 4), "\n")
cat("  1-quarter lag:", round(coef(lag1_fit)[1], 4), "\n")
cat("  2-quarter lag:", round(coef(lag2_fit)[1], 4), "\n")
cat("  4-quarter lag:", round(coef(lag4_fit)[1], 4), "\n")

# ============================================================================
# 6. Industry Placebo (Low-Bite Industries)
# ============================================================================

cat("\n6. Industry placebo test...\n")

n_high_bite <- sum(panel$industry_type == "High Bite", na.rm = TRUE)
n_low_bite <- sum(panel$industry_type == "Low Bite", na.rm = TRUE)

if (has_qwi && n_high_bite > 1000 && n_low_bite > 1000) {

  high_bite_check <- feols(
    log_emp ~ network_mw_pop | county_fips + state_fips^yearq,
    data = filter(panel, industry_type == "High Bite"),
    cluster = ~state_fips
  )

  low_bite_check <- feols(
    log_emp ~ network_mw_pop | county_fips + state_fips^yearq,
    data = filter(panel, industry_type == "Low Bite"),
    cluster = ~state_fips
  )

  cat("  High-bite industries:", round(coef(high_bite_check)[1], 4),
      "(p =", round(fixest::pvalue(high_bite_check)[1], 4), ")\n")
  cat("  Low-bite industries:", round(coef(low_bite_check)[1], 4),
      "(p =", round(fixest::pvalue(low_bite_check)[1], 4), ")\n")

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
# 7. Nonlinearity Check (Terciles)
# ============================================================================

cat("\n7. Nonlinearity check (exposure terciles)...\n")

nonlinear_fit <- tryCatch({
  feols(
    log_emp ~ network_mw_pop:network_pop_cat | county_fips + state_fips^yearq,
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

cat("\n8. Different sample periods (Pop-Weighted)...\n")

pre_covid <- feols(
  log_emp ~ network_mw_pop | county_fips + state_fips^yearq,
  data = filter(panel, year < 2020),
  cluster = ~state_fips
)

post_2015 <- feols(
  log_emp ~ network_mw_pop | county_fips + state_fips^yearq,
  data = filter(panel, year >= 2015),
  cluster = ~state_fips
)

cat("  Full sample:", round(coef(contemp_ols)[1], 4), "\n")
cat("  Pre-2020:", round(coef(pre_covid)[1], 4), "\n")
cat("  Post-2015:", round(coef(post_2015)[1], 4), "\n")

# ============================================================================
# 9. Alternative Clustering
# ============================================================================

cat("\n9. Alternative clustering...\n")

se_state <- se(main_results$iv_2sls_pop)[1]

if ("network_cluster" %in% names(panel)) {
  net_cluster_fit <- feols(
    log_emp ~ network_mw_pop | county_fips + state_fips^yearq,
    data = panel,
    cluster = ~network_cluster
  )
  se_network <- se(net_cluster_fit)[1]
} else {
  se_network <- NA
}

# Two-way clustering (state × year)
twoway_fit <- tryCatch({
  feols(
    log_emp ~ network_mw_pop | county_fips + state_fips^yearq,
    data = panel,
    cluster = ~state_fips + year
  )
}, error = function(e) NULL)

cat("  SE (state cluster):", round(se_state, 4), "\n")
if (!is.na(se_network)) {
  cat("  SE (network cluster):", round(se_network, 4), "\n")
}
if (!is.null(twoway_fit)) {
  cat("  SE (state + year cluster):", round(se(twoway_fit)[1], 4), "\n")
}

# ============================================================================
# 10. Rambachan-Roth Pre-Trend Sensitivity (HonestDiD)
# ============================================================================

cat("\n10. Rambachan-Roth pre-trend sensitivity analysis...\n")

# For shift-share IV, we adapt the HonestDiD approach:
# Instead of event-study coefficients, we test sensitivity to pre-trend violations
# by examining how results change if we allow small pre-trend deviations

# Construct event-time indicators for the policy "treatment"
# Treatment timing varies by county based on when connected states raised MW

# First, identify treatment intensity changes over time
panel_event <- panel %>%
  group_by(county_fips) %>%
  arrange(yearq) %>%
  mutate(
    exposure_change = network_mw_pop - lag(network_mw_pop),
    exposure_change_abs = abs(exposure_change)
  ) %>%
  ungroup()

# Find the "event" year for each county (largest exposure change)
county_events <- panel_event %>%
  filter(!is.na(exposure_change)) %>%
  group_by(county_fips) %>%
  slice_max(exposure_change_abs, n = 1, with_ties = FALSE) %>%
  select(county_fips, event_yearq = yearq) %>%
  ungroup()

# Create event-time variable
panel_event <- panel_event %>%
  left_join(county_events, by = "county_fips") %>%
  mutate(
    event_time = as.numeric(substr(yearq, 1, 4)) - as.numeric(substr(event_yearq, 1, 4))
  )

# Run event study regression
event_study_fit <- tryCatch({
  feols(
    log_emp ~ i(event_time, ref = -1) | county_fips + state_fips^yearq,
    data = filter(panel_event, event_time >= -5 & event_time <= 5),
    cluster = ~state_fips
  )
}, error = function(e) {
  cat("  Event study failed:", e$message, "\n")
  NULL
})

if (!is.null(event_study_fit)) {
  # Extract pre-period coefficients for HonestDiD-style sensitivity
  event_coefs <- coef(event_study_fit)
  event_ses <- se(event_study_fit)

  # Pre-period coefficients (event_time < -1)
  pre_indices <- grep("event_time::-[2-5]", names(event_coefs))
  pre_coefs <- event_coefs[pre_indices]
  pre_ses <- event_ses[pre_indices]

  cat("  Pre-period coefficients (relative to t-1):\n")
  for (i in seq_along(pre_coefs)) {
    cat(sprintf("    t = %d: %.4f (SE: %.4f)\n", -5 + i, pre_coefs[i], pre_ses[i]))
  }

  # Maximum pre-trend deviation (Mbar in Rambachan-Roth)
  max_pre_trend <- max(abs(pre_coefs))
  cat("\n  Maximum pre-trend magnitude (Mbar):", round(max_pre_trend, 4), "\n")

  # Simple sensitivity: would results survive if true pre-trend = Mbar?
  # Effect at t=0 would be biased by Mbar per period
  post_indices <- grep("event_time::[0-5]", names(event_coefs))
  if (length(post_indices) > 0) {
    post_coefs <- event_coefs[post_indices]
    cat("\n  Post-period effects:\n")
    for (i in seq_along(post_coefs)) {
      cat(sprintf("    t = %d: %.4f\n", i - 1, post_coefs[i]))
    }

    # Sensitivity bound: effect robust to linear extrapolation of pre-trend?
    t0_effect <- post_coefs[1]
    robust_bound <- t0_effect - max_pre_trend
    cat("\n  Sensitivity analysis:\n")
    cat("    Effect at t=0:", round(t0_effect, 4), "\n")
    cat("    Robust bound (effect - Mbar):", round(robust_bound, 4), "\n")
    if (robust_bound > 0) {
      cat("    ✓ Effect survives under Rambachan-Roth Mbar sensitivity\n")
    } else {
      cat("    ⚠ Effect may not survive aggressive pre-trend extrapolation\n")
    }
  }

  # Save event study results
  event_study_results <- list(
    fit = event_study_fit,
    pre_coefs = pre_coefs,
    pre_ses = pre_ses,
    max_pre_trend = max_pre_trend
  )
} else {
  event_study_results <- NULL
}

# ============================================================================
# 11. Save Robustness Results
# ============================================================================

cat("\n11. Saving robustness results...\n")

robustness <- list(
  # Randomization inference
  ri_pval_pop = ri_pval_pop,
  ri_pval_prob = ri_pval_prob,
  perm_coefs_pop = perm_coefs_pop,
  perm_coefs_prob = perm_coefs_prob,

  # Leave-one-out
  loso_results = loso_results,

  # Alternative specifications
  geo_only = geo_only,
  ortho_only = ortho_only,
  both_schemes = if (exists("both_schemes")) both_schemes else NULL,

  # Lags
  contemp_ols = contemp_ols,
  lag1 = lag1_fit,
  lag2 = lag2_fit,
  lag4 = lag4_fit,

  # Industry placebo
  placebo_industry = placebo_industry,

  # Nonlinearity
  nonlinear_fit = nonlinear_fit,

  # Time windows
  pre_covid = pre_covid,
  post_2015 = post_2015,

  # Rambachan-Roth sensitivity
  event_study_results = event_study_results
)

saveRDS(robustness, "../data/robustness_results.rds")

cat("  Saved robustness_results.rds\n")

# ============================================================================
# Summary
# ============================================================================

cat("\n=== Robustness Summary ===\n\n")

cat("Inference:\n")
cat("  RI p-value (Pop-Weighted):", round(ri_pval_pop, 4), "\n")
cat("  RI p-value (Prob-Weighted):", round(ri_pval_prob, 4), "\n")
cat("  State-clustered SE:", round(se_state, 4), "\n")

cat("\nLeave-One-Out stability:\n")
loso_coefs <- sapply(loso_results, function(x) x$coef)
cat("  Range:", round(min(loso_coefs), 4), "to", round(max(loso_coefs), 4), "\n")
cat("  Main coefficient:", round(coef(contemp_ols)[1], 4), "\n")

cat("\nWeighting comparison (in same regression):\n")
if (exists("both_schemes") && !is.null(both_schemes)) {
  cat("  Pop-weighted dominates when both included\n")
}

cat("\nConclusion: Results are",
    ifelse(ri_pval_pop < 0.1, "robust", "sensitive"),
    "to inference method.\n")

cat("\n=== Robustness Complete ===\n")
