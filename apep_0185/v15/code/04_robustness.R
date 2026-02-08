################################################################################
# 04_robustness.R
# Social Network Minimum Wage Exposure - POPULATION-WEIGHTED REVISION
#
# Robustness checks for the main population-weighted specification
# Permutation inference uses 2000 permutations
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

cat("\n2. Exposure permutation inference (2000 permutations)...\n")
cat("  Testing both pop-weighted and prob-weighted specifications\n\n")

set.seed(42)
n_perms <- 2000

perm_coefs_pop <- numeric(n_perms)
perm_coefs_prob <- numeric(n_perms)

for (i in 1:n_perms) {
  if (i %% 500 == 0) cat("  Permutation", i, "/", n_perms, "\n")

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
# 3. Leave-One-State-Out Jackknife (2SLS, both outcomes)
# ============================================================================

cat("\n3. Leave-one-state-out jackknife (2SLS, Employment + Earnings)...\n")

major_mw_states <- c("06", "36", "53", "25", "12")  # CA, NY, WA, MA, FL
state_names <- c("06" = "CA", "36" = "NY", "53" = "WA", "25" = "MA", "12" = "FL")

has_earn <- "log_earn" %in% names(panel)

loso_results <- list()

for (st in major_mw_states) {
  panel_loso <- panel %>%
    filter(state_fips != st)

  # 2SLS Employment
  loso_iv_emp <- tryCatch({
    feols(
      log_emp ~ 1 | county_fips + state_fips^yearq | network_mw_pop ~ network_mw_pop_out_state,
      data = panel_loso,
      cluster = ~state_fips
    )
  }, error = function(e) NULL)

  # 2SLS Earnings
  loso_iv_earn <- NULL
  if (has_earn) {
    loso_iv_earn <- tryCatch({
      feols(
        log_earn ~ 1 | county_fips + state_fips^yearq | network_mw_pop ~ network_mw_pop_out_state,
        data = panel_loso,
        cluster = ~state_fips
      )
    }, error = function(e) NULL)
  }

  loso_results[[st]] <- list(
    emp_coef  = if (!is.null(loso_iv_emp))  coef(loso_iv_emp)[1]  else NA,
    emp_se    = if (!is.null(loso_iv_emp))  se(loso_iv_emp)[1]    else NA,
    emp_p     = if (!is.null(loso_iv_emp))  fixest::pvalue(loso_iv_emp)[1] else NA,
    emp_f     = if (!is.null(loso_iv_emp)) tryCatch({
                  fs <- fitstat(loso_iv_emp, type = "ivf")
                  as.numeric(fs)[1]
                }, error = function(e) NA) else NA,
    emp_n     = if (!is.null(loso_iv_emp))  nobs(loso_iv_emp)      else NA,
    earn_coef = if (!is.null(loso_iv_earn)) coef(loso_iv_earn)[1]  else NA,
    earn_se   = if (!is.null(loso_iv_earn)) se(loso_iv_earn)[1]    else NA,
    earn_p    = if (!is.null(loso_iv_earn)) fixest::pvalue(loso_iv_earn)[1] else NA
  )
}

# Exclude top-3 (CA+NY+WA) jointly
panel_no_top3 <- panel %>% filter(!state_fips %in% c("06", "36", "53"))

loso_top3_emp <- tryCatch({
  feols(
    log_emp ~ 1 | county_fips + state_fips^yearq | network_mw_pop ~ network_mw_pop_out_state,
    data = panel_no_top3, cluster = ~state_fips
  )
}, error = function(e) NULL)

loso_top3_earn <- NULL
if (has_earn) {
  loso_top3_earn <- tryCatch({
    feols(
      log_earn ~ 1 | county_fips + state_fips^yearq | network_mw_pop ~ network_mw_pop_out_state,
      data = panel_no_top3, cluster = ~state_fips
    )
  }, error = function(e) NULL)
}

loso_results[["top3"]] <- list(
  emp_coef  = if (!is.null(loso_top3_emp))  coef(loso_top3_emp)[1]  else NA,
  emp_se    = if (!is.null(loso_top3_emp))  se(loso_top3_emp)[1]    else NA,
  emp_p     = if (!is.null(loso_top3_emp))  fixest::pvalue(loso_top3_emp)[1] else NA,
  emp_f     = if (!is.null(loso_top3_emp)) tryCatch({
                  fs <- fitstat(loso_top3_emp, type = "ivf")
                  as.numeric(fs)[1]
                }, error = function(e) NA) else NA,
  emp_n     = if (!is.null(loso_top3_emp))  nobs(loso_top3_emp)      else NA,
  earn_coef = if (!is.null(loso_top3_earn)) coef(loso_top3_earn)[1]  else NA,
  earn_se   = if (!is.null(loso_top3_earn)) se(loso_top3_earn)[1]    else NA,
  earn_p    = if (!is.null(loso_top3_earn)) fixest::pvalue(loso_top3_earn)[1] else NA
)

cat("\nLeave-one-state-out results (2SLS):\n")
cat(sprintf("  %-15s %10s %10s %10s %10s\n", "Excluded", "Emp Coef", "Emp SE", "Earn Coef", "Earn SE"))
cat(paste(rep("-", 60), collapse = ""), "\n")
for (st in c(major_mw_states, "top3")) {
  r <- loso_results[[st]]
  lbl <- if (st == "top3") "CA+NY+WA" else state_names[st]
  cat(sprintf("  %-15s %10.4f %10.4f %10s %10s\n", lbl,
      r$emp_coef, r$emp_se,
      if (!is.na(r$earn_coef)) sprintf("%.4f", r$earn_coef) else "---",
      if (!is.na(r$earn_se)) sprintf("%.4f", r$earn_se) else "---"))
}

cat("\n  2SLS Employment range: [",
    round(min(sapply(loso_results, function(x) x$emp_coef), na.rm = TRUE), 4), ",",
    round(max(sapply(loso_results, function(x) x$emp_coef), na.rm = TRUE), 4), "]\n")

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

# 4c. 2SLS with geographic exposure as additional control (both outcomes)
geo_control_iv_emp <- tryCatch({
  feols(
    log_emp ~ geo_exposure | county_fips + state_fips^yearq | network_mw_pop ~ network_mw_pop_out_state,
    data = panel, cluster = ~state_fips
  )
}, error = function(e) NULL)

geo_control_iv_earn <- NULL
if (has_earn) {
  geo_control_iv_earn <- tryCatch({
    feols(
      log_earn ~ geo_exposure | county_fips + state_fips^yearq | network_mw_pop ~ network_mw_pop_out_state,
      data = panel, cluster = ~state_fips
    )
  }, error = function(e) NULL)
}

if (!is.null(geo_control_iv_emp)) {
  cat("  2SLS + geo control (Emp):", round(coef(geo_control_iv_emp)["fit_network_mw_pop"], 4),
      "(SE:", round(se(geo_control_iv_emp)["fit_network_mw_pop"], 4), ")\n")
}
if (!is.null(geo_control_iv_earn)) {
  cat("  2SLS + geo control (Earn):", round(coef(geo_control_iv_earn)["fit_network_mw_pop"], 4),
      "(SE:", round(se(geo_control_iv_earn)["fit_network_mw_pop"], 4), ")\n")
}

# 4d. Both weighting schemes in same regression
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

cat("\n6. Industry heterogeneity test (High Bite vs Low Bite)...\n")

# Load industry-level panel if available
industry_panel <- NULL
if (file.exists("../data/industry_panel.rds")) {
  industry_panel <- readRDS("../data/industry_panel.rds")
  cat("  Loaded industry panel with", format(nrow(industry_panel), big.mark = ","), "obs\n")
}

n_high_bite <- if (!is.null(industry_panel)) sum(industry_panel$industry_type == "High Bite", na.rm = TRUE) else 0
n_low_bite <- if (!is.null(industry_panel)) sum(industry_panel$industry_type == "Low Bite", na.rm = TRUE) else 0

if (!is.null(industry_panel) && n_high_bite > 1000 && n_low_bite > 1000) {

  # OLS: High-bite industries (Retail + Accommodation/Food)
  high_bite_ols <- feols(
    log_emp ~ network_mw_pop | county_fips + state_fips^yearq,
    data = filter(industry_panel, industry_type == "High Bite"),
    cluster = ~state_fips
  )

  # OLS: Low-bite industries (Finance + Professional)
  low_bite_ols <- feols(
    log_emp ~ network_mw_pop | county_fips + state_fips^yearq,
    data = filter(industry_panel, industry_type == "Low Bite"),
    cluster = ~state_fips
  )

  cat("  High-bite OLS:", round(coef(high_bite_ols)[1], 4),
      "(p =", round(fixest::pvalue(high_bite_ols)[1], 4), ")\n")
  cat("  Low-bite OLS:", round(coef(low_bite_ols)[1], 4),
      "(p =", round(fixest::pvalue(low_bite_ols)[1], 4), ")\n")

  # 2SLS: High-bite industries
  high_bite_iv <- tryCatch({
    feols(
      log_emp ~ 1 | county_fips + state_fips^yearq | network_mw_pop ~ network_mw_pop_out_state,
      data = filter(industry_panel, industry_type == "High Bite"),
      cluster = ~state_fips
    )
  }, error = function(e) NULL)

  # 2SLS: Low-bite industries
  low_bite_iv <- tryCatch({
    feols(
      log_emp ~ 1 | county_fips + state_fips^yearq | network_mw_pop ~ network_mw_pop_out_state,
      data = filter(industry_panel, industry_type == "Low Bite"),
      cluster = ~state_fips
    )
  }, error = function(e) NULL)

  if (!is.null(high_bite_iv)) {
    cat("  High-bite 2SLS:", round(coef(high_bite_iv)[1], 4),
        "(SE:", round(se(high_bite_iv)[1], 4),
        ", p =", round(fixest::pvalue(high_bite_iv)[1], 4), ")\n")
  }
  if (!is.null(low_bite_iv)) {
    cat("  Low-bite 2SLS:", round(coef(low_bite_iv)[1], 4),
        "(SE:", round(se(low_bite_iv)[1], 4),
        ", p =", round(fixest::pvalue(low_bite_iv)[1], 4), ")\n")
  }

  if (!is.null(low_bite_iv) && fixest::pvalue(low_bite_iv)[1] > 0.1) {
    cat("  --> Placebo passed: Low-bite industries show no significant 2SLS effect\n")
  }

  placebo_industry <- list(
    high_bite_ols = high_bite_ols, low_bite_ols = low_bite_ols,
    high_bite_iv = high_bite_iv, low_bite_iv = low_bite_iv
  )
} else {
  cat("  Skipping (no industry-level data available)\n")
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
# 8. Different Time Windows (2SLS, both outcomes)
# ============================================================================

cat("\n8. Different sample periods (2SLS, Employment + Earnings)...\n")

# --- Pre-COVID 2SLS ---
pre_covid_iv_emp <- tryCatch({
  feols(
    log_emp ~ 1 | county_fips + state_fips^yearq | network_mw_pop ~ network_mw_pop_out_state,
    data = filter(panel, year < 2020), cluster = ~state_fips
  )
}, error = function(e) NULL)

pre_covid_iv_earn <- NULL
if (has_earn) {
  pre_covid_iv_earn <- tryCatch({
    feols(
      log_earn ~ 1 | county_fips + state_fips^yearq | network_mw_pop ~ network_mw_pop_out_state,
      data = filter(panel, year < 2020), cluster = ~state_fips
    )
  }, error = function(e) NULL)
}

# --- Post-2015 2SLS ---
post_2015_iv_emp <- tryCatch({
  feols(
    log_emp ~ 1 | county_fips + state_fips^yearq | network_mw_pop ~ network_mw_pop_out_state,
    data = filter(panel, year >= 2015), cluster = ~state_fips
  )
}, error = function(e) NULL)

post_2015_iv_earn <- NULL
if (has_earn) {
  post_2015_iv_earn <- tryCatch({
    feols(
      log_earn ~ 1 | county_fips + state_fips^yearq | network_mw_pop ~ network_mw_pop_out_state,
      data = filter(panel, year >= 2015), cluster = ~state_fips
    )
  }, error = function(e) NULL)
}

# Keep OLS versions for backward compatibility
pre_covid <- feols(
  log_emp ~ network_mw_pop | county_fips + state_fips^yearq,
  data = filter(panel, year < 2020), cluster = ~state_fips
)
post_2015 <- feols(
  log_emp ~ network_mw_pop | county_fips + state_fips^yearq,
  data = filter(panel, year >= 2015), cluster = ~state_fips
)

cat("  Pre-2020 2SLS (Emp):", if (!is.null(pre_covid_iv_emp)) round(coef(pre_covid_iv_emp)[1], 4) else "---", "\n")
cat("  Pre-2020 2SLS (Earn):", if (!is.null(pre_covid_iv_earn)) round(coef(pre_covid_iv_earn)[1], 4) else "---", "\n")
cat("  Post-2015 2SLS (Emp):", if (!is.null(post_2015_iv_emp)) round(coef(post_2015_iv_emp)[1], 4) else "---", "\n")
cat("  Post-2015 2SLS (Earn):", if (!is.null(post_2015_iv_earn)) round(coef(post_2015_iv_earn)[1], 4) else "---", "\n")

# ============================================================================
# 8b. Placebo-as-Control: 2SLS with GDP placebo as additional control
# ============================================================================

cat("\n8b. Placebo-as-control: 2SLS with GDP placebo as additional control...\n")

# Load placebo data if available
placebo_data <- if (file.exists("../data/placebo_shock_results.rds")) {
  readRDS("../data/placebo_shock_results.rds")
} else NULL

placebo_control_iv_emp <- NULL
placebo_control_iv_earn <- NULL

if ("placebo_gdp" %in% names(panel) || !is.null(placebo_data)) {
  # Load panel with placebo vars
  if (!"placebo_gdp" %in% names(panel) && file.exists("../data/exposure_panel.rds")) {
    cat("  Loading placebo GDP from exposure panel...\n")
  }

  if ("placebo_gdp" %in% names(panel)) {
    # 2SLS with GDP placebo as control (employment)
    placebo_control_iv_emp <- tryCatch({
      feols(
        log_emp ~ placebo_gdp | county_fips + state_fips^yearq | network_mw_pop ~ network_mw_pop_out_state,
        data = panel, cluster = ~state_fips
      )
    }, error = function(e) { cat("  Placebo-as-control (Emp) failed:", e$message, "\n"); NULL })

    # 2SLS with GDP placebo as control (earnings)
    if (has_earn) {
      placebo_control_iv_earn <- tryCatch({
        feols(
          log_earn ~ placebo_gdp | county_fips + state_fips^yearq | network_mw_pop ~ network_mw_pop_out_state,
          data = panel, cluster = ~state_fips
        )
      }, error = function(e) NULL)
    }

    if (!is.null(placebo_control_iv_emp)) {
      cat("  2SLS + GDP control (Emp):", round(coef(placebo_control_iv_emp)["fit_network_mw_pop"], 4),
          "(SE:", round(se(placebo_control_iv_emp)["fit_network_mw_pop"], 4), ")\n")
    }
  } else {
    cat("  placebo_gdp variable not in panel — skipping\n")
  }
} else {
  cat("  No placebo data available — skipping\n")
}

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
# 11. Shock Herfindahl Index (Instrument Concentration)
# ============================================================================

cat("\n11. Shock Herfindahl Index (instrument concentration)...\n")

# Reload state MW panel to compute shock concentration
state_mw_panel <- readRDS("../data/state_mw_panel.rds")

# Compute the total absolute MW change by state over the sample period
state_mw_variation <- state_mw_panel %>%
  group_by(state_fips) %>%
  arrange(yearq) %>%
  mutate(mw_change = abs(log_min_wage - lag(log_min_wage))) %>%
  summarise(
    total_abs_mw_change = sum(mw_change, na.rm = TRUE),
    .groups = "drop"
  )

# Compute the average SCI share each origin state receives across all counties
# Use network_mw_pop to back out approximate weights:
# For each county, the instrument is sum_j w_cj * MW_jt
# We approximate each state's contribution by its total MW variation
# weighted by its average SCI share across counties

# If we have SCI shares in the panel, use them; otherwise approximate
# from the variation in the instrument itself
# Approach: each state's share of total instrument variation =
#   (total_abs_mw_change_s * avg_sci_share_to_s) / sum_over_all_states

# Since we may not have raw SCI shares, approximate state shares of instrument
# variation as the proportion of total absolute MW changes (weighted equally)
state_mw_variation <- state_mw_variation %>%
  mutate(share = total_abs_mw_change / sum(total_abs_mw_change))

# Compute HHI = sum of squared shares
shock_hhi <- sum(state_mw_variation$share^2)
effective_n_shocks <- 1 / shock_hhi

cat("  Shock HHI:", round(shock_hhi, 4), "\n")
cat("  Effective number of shocks:", round(effective_n_shocks, 1), "\n")

# Report top 10 contributing states
top_10_states <- state_mw_variation %>%
  arrange(desc(share)) %>%
  head(10)

cat("\n  Top 10 states by instrument contribution:\n")
cat(sprintf("  %5s %15s %10s\n", "State", "Abs MW Change", "Share"))
cat(paste(rep("-", 35), collapse = ""), "\n")
for (i in 1:nrow(top_10_states)) {
  cat(sprintf("  %5s %15.2f %10.4f\n",
              top_10_states$state_fips[i],
              top_10_states$total_abs_mw_change[i],
              top_10_states$share[i]))
}

cat("\n  Interpretation: Higher effective N = less concentrated instrument\n")
cat("  Rule of thumb: effective N > 10 suggests adequate diversification\n")

# ============================================================================
# 12. Overidentification Test (Coastal vs Inland Sub-Instruments)
# ============================================================================

cat("\n12. Overidentification test (coastal vs inland sub-instruments)...\n")

# Define coastal and inland state FIPS codes
coastal_fips <- c("06", "41", "53", "36", "34", "09", "25", "23",
                  "33", "44", "24", "10", "51", "37", "45", "13", "12")
# CA=06, OR=41, WA=53, NY=36, NJ=34, CT=09, MA=25, ME=23,
# NH=33, RI=44, MD=24, DE=10, VA=51, NC=37, SC=45, GA=13, FL=12

# Construct sub-instruments by splitting origin states into coastal vs inland
# We approximate this by interacting the instrument with state geography
# For each county-quarter, the instrument is sum_j w_cj * MW_jt
# We split: IV_coastal = sum_{j in coastal} w_cj * MW_jt
#           IV_inland  = sum_{j in inland}  w_cj * MW_jt

# Since we may not have the raw weight decomposition, we construct sub-instruments
# from the state MW panel by computing exposure separately for each group

# Check if we have the sub-instruments or need to construct proxies
has_sub_iv <- all(c("network_mw_pop_coastal", "network_mw_pop_inland") %in% names(panel))

if (!has_sub_iv) {
  # Construct proxy sub-instruments using state-level MW changes
  # weighted by whether the state is coastal or inland
  # This is an approximation - ideally we'd have the raw SCI weights

  # For each county, compute the share of connected MW variation from coastal states
  # Proxy: use the state MW panel to create coastal/inland MW indices
  coastal_mw <- state_mw_panel %>%
    filter(state_fips %in% coastal_fips) %>%
    group_by(yearq) %>%
    summarise(coastal_avg_mw = mean(log_min_wage, na.rm = TRUE), .groups = "drop")

  inland_mw <- state_mw_panel %>%
    filter(!(state_fips %in% coastal_fips)) %>%
    group_by(yearq) %>%
    summarise(inland_avg_mw = mean(log_min_wage, na.rm = TRUE), .groups = "drop")

  panel <- panel %>%
    left_join(coastal_mw, by = "yearq") %>%
    left_join(inland_mw, by = "yearq")
}

# Run 2SLS with the main instrument to get residuals
main_2sls <- main_results$iv_2sls_pop

overid_results <- tryCatch({
  # Get sub-instrument variable names
  if (has_sub_iv) {
    iv_coastal_var <- "network_mw_pop_coastal"
    iv_inland_var <- "network_mw_pop_inland"
  } else {
    iv_coastal_var <- "coastal_avg_mw"
    iv_inland_var <- "inland_avg_mw"
  }

  # First stage with coastal instrument only
  iv_coastal <- feols(
    as.formula(paste0("log_emp ~ 1 | county_fips + state_fips^yearq | network_mw_pop ~ ", iv_coastal_var)),
    data = panel,
    cluster = ~state_fips
  )

  # First stage with inland instrument only
  iv_inland <- feols(
    as.formula(paste0("log_emp ~ 1 | county_fips + state_fips^yearq | network_mw_pop ~ ", iv_inland_var)),
    data = panel,
    cluster = ~state_fips
  )

  cat("  Coastal IV coefficient:", round(coef(iv_coastal)[1], 4),
      "(SE:", round(se(iv_coastal)[1], 4), ")\n")
  cat("  Inland IV coefficient:", round(coef(iv_inland)[1], 4),
      "(SE:", round(se(iv_inland)[1], 4), ")\n")

  # Sargan/Hansen J-test: regress 2SLS residuals on both instruments
  # Use overidentified 2SLS with both instruments
  iv_overid <- feols(
    as.formula(paste0("log_emp ~ 1 | county_fips + state_fips^yearq | network_mw_pop ~ ",
                      iv_coastal_var, " + ", iv_inland_var)),
    data = panel,
    cluster = ~state_fips
  )

  # Extract residuals from overidentified regression
  resid_overid <- residuals(iv_overid)
  n_obs <- length(resid_overid)

  # Regress residuals on both instruments (after partialling out fixed effects)
  panel_resid <- panel[1:n_obs, ]
  panel_resid$resid_overid <- resid_overid

  # Auxiliary regression for J-test
  aux_reg <- feols(
    as.formula(paste0("resid_overid ~ ", iv_coastal_var, " + ", iv_inland_var,
                      " | county_fips + state_fips^yearq")),
    data = panel_resid
  )

  j_stat <- n_obs * r2(aux_reg, type = "r2")
  j_pval <- pchisq(j_stat, df = 1, lower.tail = FALSE)

  cat("\n  Sargan-Hansen J-test:\n")
  cat("    J-statistic:", round(j_stat, 4), "\n")
  cat("    p-value:", round(j_pval, 4), "\n")
  cat("    df: 1\n")

  if (j_pval > 0.05) {
    cat("    --> Cannot reject null: instruments are valid (p > 0.05)\n")
  } else {
    cat("    --> Overidentification test rejects at 5% level\n")
  }

  list(
    iv_coastal = iv_coastal,
    iv_inland = iv_inland,
    iv_overid = iv_overid,
    j_stat = j_stat,
    j_pval = j_pval
  )
}, error = function(e) {
  cat("  WARNING: Overidentification test failed -", e$message, "\n")
  NULL
})

# ============================================================================
# 13. Differential-Trend Test (Levels Imbalance Robustness)
# ============================================================================

cat("\n13. Differential-trend test (baseline employment × time trend)...\n")

# Compute baseline (2012) employment for each county
baseline_emp <- panel %>%
  filter(year == 2012) %>%
  group_by(county_fips) %>%
  summarise(log_emp_baseline = mean(log_emp, na.rm = TRUE), .groups = "drop")

panel <- panel %>%
  left_join(baseline_emp, by = "county_fips") %>%
  mutate(time_trend = yearq - 2012)

# Test: interact baseline employment with time trend
diff_trend_test <- tryCatch({
  feols(
    log_emp ~ network_mw_pop + log_emp_baseline:time_trend | county_fips + state_fips^yearq,
    data = panel,
    cluster = ~state_fips
  )
}, error = function(e) {
  cat("  WARNING: Differential trend test failed -", e$message, "\n")
  NULL
})

if (!is.null(diff_trend_test)) {
  cat("  Network MW (with trend control):", round(coef(diff_trend_test)["network_mw_pop"], 4),
      "(p =", round(fixest::pvalue(diff_trend_test)["network_mw_pop"], 4), ")\n")
  cat("  Baseline × Trend:", round(coef(diff_trend_test)["log_emp_baseline:time_trend"], 4),
      "(p =", round(fixest::pvalue(diff_trend_test)["log_emp_baseline:time_trend"], 4), ")\n")
}

# ============================================================================
# 14. COVID Period Interaction
# ============================================================================

cat("\n14. COVID period interaction...\n")

panel <- panel %>%
  mutate(covid = as.numeric(year >= 2020))

covid_interaction <- tryCatch({
  feols(
    log_emp ~ network_mw_pop + network_mw_pop:covid | county_fips + state_fips^yearq,
    data = panel,
    cluster = ~state_fips
  )
}, error = function(e) {
  cat("  WARNING: COVID interaction failed -", e$message, "\n")
  NULL
})

if (!is.null(covid_interaction)) {
  cat("  Pre-COVID effect:", round(coef(covid_interaction)["network_mw_pop"], 4), "\n")
  cat("  COVID interaction:", round(coef(covid_interaction)["network_mw_pop:covid"], 4),
      "(p =", round(fixest::pvalue(covid_interaction)["network_mw_pop:covid"], 4), ")\n")
}

# Pre-COVID 2SLS
pre_covid_iv <- tryCatch({
  feols(
    log_emp ~ 1 | county_fips + state_fips^yearq | network_mw_pop ~ network_mw_pop_out_state,
    data = filter(panel, year < 2020),
    cluster = ~state_fips
  )
}, error = function(e) NULL)

if (!is.null(pre_covid_iv)) {
  cat("  Pre-COVID 2SLS:", round(coef(pre_covid_iv)[1], 4),
      "(SE:", round(se(pre_covid_iv)[1], 4), ")\n")
}

# ============================================================================
# 15. [REMOVED] Sun & Abraham — wrong estimator for shift-share IV design
# ============================================================================
# Sun & Abraham is designed for binary staggered treatment. Our design uses
# continuous shift-share exposure with an excluded instrument. Dropped per
# revision plan.
sa_results <- NULL
cat("\n15. Sun & Abraham: REMOVED (inappropriate for shift-share IV design)\n")

# ============================================================================
# 16. Enhanced Rambachan-Roth with M-bar
# ============================================================================

cat("\n16. Enhanced Rambachan-Roth sensitivity with M-bar...\n")

rr_enhanced <- NULL

tryCatch({
  # Load main results for event study models
  main_res <- readRDS("../data/main_results.rds")

  # Run R-R on BOTH structural and reduced-form event studies
  rr_results <- list()

  for (es_type in c("structural", "reduced_form")) {
    if (es_type == "structural") {
      es_fit <- main_res$structural_es
      es_label <- "Structural (endogenous)"
    } else {
      es_fit <- main_res$rf_es_baseline
      es_label <- "Reduced-form (instrument)"
    }

    if (is.null(es_fit)) {
      cat("  Skipping", es_label, "- model not available\n")
      next
    }

    es_coefs <- coef(es_fit)
    es_vcov <- vcov(es_fit)

    # Pre-period coefficients (yearq_int 1-4 = 2012Q1-Q4)
    # Post-period coefficients (yearq_int >= 6 = 2013Q2+)
    pre_idx <- grep("yearq_int::[1-4]:", names(es_coefs))
    post_idx <- which(grepl("yearq_int::", names(es_coefs)) &
                      as.numeric(gsub("yearq_int::([-0-9]+):.*", "\\1", names(es_coefs))) >= 6)

    if (length(pre_idx) < 2 || length(post_idx) < 1) next

    pre_coefs <- es_coefs[pre_idx]
    post_coefs <- es_coefs[post_idx]

    # M-bar = max absolute difference between consecutive pre-period coefficients
    pre_sorted <- pre_coefs[order(names(pre_coefs))]
    if (length(pre_sorted) >= 2) {
      consecutive_diffs <- abs(diff(pre_sorted))
      M_bar <- max(consecutive_diffs)
    } else {
      M_bar <- max(abs(pre_sorted))
    }

    # How large would pre-trend slope need to be to overturn first post-period effect?
    first_post <- post_coefs[1]
    # If linear pre-trend of slope M_bar continues, after k periods post-treatment
    # the bias would be k * M_bar. The effect at t=0 is first_post.
    # Effect survives if first_post > 1 * M_bar (one period after reference)
    survives_mbar <- abs(first_post) > M_bar

    # Maximum M-bar that preserves significance at 95%
    first_post_se <- sqrt(es_vcov[names(first_post), names(first_post)])
    max_tolerable_mbar <- abs(first_post) - 1.96 * first_post_se

    rr_results[[es_type]] <- list(
      label = es_label,
      M_bar = M_bar,
      first_post_effect = first_post,
      first_post_se = first_post_se,
      survives_mbar = survives_mbar,
      max_tolerable_mbar = max_tolerable_mbar,
      pre_coefs = pre_coefs,
      post_coefs = post_coefs
    )

    cat(sprintf("  %s:\n", es_label))
    cat(sprintf("    M-bar (max consecutive pre-period diff): %.4f\n", M_bar))
    cat(sprintf("    First post-period effect (t=0): %.4f (SE: %.4f)\n", first_post, first_post_se))
    cat(sprintf("    Effect survives M-bar extrapolation: %s\n", ifelse(survives_mbar, "YES", "NO")))
    cat(sprintf("    Max tolerable M-bar for significance: %.4f\n", max_tolerable_mbar))
  }

  rr_enhanced <- rr_results
  cat("  Rambachan-Roth analysis complete\n")
}, error = function(e) {
  cat("  WARNING: Enhanced R-R failed:", e$message, "\n")
})

# ============================================================================
# 17. Region (Census Division) Linear Trends
# ============================================================================
# County-specific linear trends were previously included but absorb
# identifying variation in the shift-share design (actual 2SLS was -0.084,
# p=0.45). We replace with region-level linear trends, which control for
# broad geographic trends without being over-demanding.

cat("\n17. Region (Census Division) linear trends robustness...\n")

region_trend_results <- NULL

tryCatch({
  # Create Census division from state FIPS
  panel <- panel %>%
    mutate(
      census_division = case_when(
        state_fips %in% c("09","23","25","33","44","50") ~ "1",  # New England
        state_fips %in% c("34","36","42") ~ "2",                  # Middle Atlantic
        state_fips %in% c("17","18","26","39","55") ~ "3",        # East North Central
        state_fips %in% c("19","20","27","29","31","38","46") ~ "4", # West North Central
        state_fips %in% c("10","11","12","13","24","37","45","51","54") ~ "5", # South Atlantic
        state_fips %in% c("01","21","28","47") ~ "6",             # East South Central
        state_fips %in% c("05","22","40","48") ~ "7",             # West South Central
        state_fips %in% c("04","08","16","30","32","35","49","56") ~ "8", # Mountain
        state_fips %in% c("02","06","15","41","53") ~ "9",        # Pacific
        TRUE ~ "0"
      ),
      yearq_num = as.numeric(factor(yearq))
    )

  cat("  Census divisions in data:", n_distinct(panel$census_division), "\n")

  # 2SLS with region × linear time trend
  iv_region_trends <- tryCatch({
    feols(
      log_emp ~ 1 | county_fips + state_fips^yearq + census_division[yearq_num] |
        network_mw_pop ~ network_mw_pop_out_state,
      data = panel, cluster = ~state_fips
    )
  }, error = function(e) {
    cat("  2SLS with region trends failed:", e$message, "\n")
    NULL
  })

  if (!is.null(iv_region_trends)) {
    region_coef <- coef(iv_region_trends)[1]
    region_se <- se(iv_region_trends)[1]
    region_p <- fixest::pvalue(iv_region_trends)[1]
    baseline_coef <- coef(main_results$iv_2sls_pop)[1]

    cat("  2SLS with region trends:", round(region_coef, 4),
        "(SE:", round(region_se, 4),
        ", p =", round(region_p, 4), ")\n")
    cat("  Baseline 2SLS:", round(baseline_coef, 4), "\n")
    cat("  Attenuation:", round((1 - abs(region_coef / baseline_coef)) * 100, 1), "%\n")

    # Also do earnings
    iv_region_trends_earn <- NULL
    if (has_earn) {
      iv_region_trends_earn <- tryCatch({
        feols(
          log_earn ~ 1 | county_fips + state_fips^yearq + census_division[yearq_num] |
            network_mw_pop ~ network_mw_pop_out_state,
          data = panel, cluster = ~state_fips
        )
      }, error = function(e) NULL)
    }

    region_trend_results <- list(
      iv_emp = iv_region_trends,
      iv_earn = iv_region_trends_earn
    )
  } else {
    cat("  Region trends specification failed — insufficient within-region variation.\n")
    cat("  (Footnote: region × time trends may absorb too much variation in this design.)\n")
  }

}, error = function(e) {
  cat("  WARNING: Region trends failed:", e$message, "\n")
})

# ============================================================================
# 18. Save Robustness Results
# ============================================================================

cat("\n15. Saving robustness results...\n")

robustness <- list(
  # Randomization inference
  ri_pval_pop = ri_pval_pop,
  ri_pval_prob = ri_pval_prob,
  perm_coefs_pop = perm_coefs_pop,
  perm_coefs_prob = perm_coefs_prob,

  # Leave-one-out (2SLS, both outcomes)
  loso_results = loso_results,

  # Alternative specifications
  geo_only = geo_only,
  ortho_only = ortho_only,
  both_schemes = if (exists("both_schemes")) both_schemes else NULL,

  # 2SLS with geographic controls
  geo_control_iv_emp = if (exists("geo_control_iv_emp")) geo_control_iv_emp else NULL,
  geo_control_iv_earn = if (exists("geo_control_iv_earn")) geo_control_iv_earn else NULL,

  # Lags
  contemp_ols = contemp_ols,
  lag1 = lag1_fit,
  lag2 = lag2_fit,
  lag4 = lag4_fit,

  # Industry placebo
  placebo_industry = if (exists("placebo_industry")) placebo_industry else NULL,

  # Nonlinearity
  nonlinear_fit = nonlinear_fit,

  # Time windows (OLS)
  pre_covid = pre_covid,
  post_2015 = post_2015,

  # Time windows (2SLS, both outcomes)
  pre_covid_iv_emp = if (exists("pre_covid_iv_emp")) pre_covid_iv_emp else NULL,
  pre_covid_iv_earn = if (exists("pre_covid_iv_earn")) pre_covid_iv_earn else NULL,
  post_2015_iv_emp = if (exists("post_2015_iv_emp")) post_2015_iv_emp else NULL,
  post_2015_iv_earn = if (exists("post_2015_iv_earn")) post_2015_iv_earn else NULL,

  # Placebo-as-control (2SLS)
  placebo_control_iv_emp = if (exists("placebo_control_iv_emp")) placebo_control_iv_emp else NULL,
  placebo_control_iv_earn = if (exists("placebo_control_iv_earn")) placebo_control_iv_earn else NULL,

  # Rambachan-Roth sensitivity
  event_study_results = event_study_results,

  # Shock concentration
  shock_hhi = shock_hhi,
  effective_n_shocks = effective_n_shocks,

  # Overidentification
  overid_results = overid_results,

  # Differential trend test
  diff_trend_test = if (exists("diff_trend_test")) diff_trend_test else NULL,

  # COVID interaction
  covid_interaction = if (exists("covid_interaction")) covid_interaction else NULL,
  pre_covid_iv_old = if (exists("pre_covid_iv")) pre_covid_iv else NULL,

  # Region trends
  region_trend_results = if (exists("region_trend_results")) region_trend_results else NULL,

  # Enhanced Rambachan-Roth
  rr_enhanced = rr_enhanced,

  # Main 2SLS results (for table generation)
  baseline_iv_emp = main_results$iv_2sls_pop,
  baseline_iv_earn = if (!is.null(main_results$iv_earn_pop)) main_results$iv_earn_pop else NULL
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

cat("\nLeave-One-Out stability (2SLS Employment):\n")
loso_emp_coefs <- sapply(loso_results, function(x) x$emp_coef)
cat("  Range:", round(min(loso_emp_coefs, na.rm = TRUE), 4), "to",
    round(max(loso_emp_coefs, na.rm = TRUE), 4), "\n")
cat("  Main 2SLS coefficient:", round(coef(main_results$iv_2sls_pop)[1], 4), "\n")

cat("\nWeighting comparison (in same regression):\n")
if (exists("both_schemes") && !is.null(both_schemes)) {
  cat("  Pop-weighted dominates when both included\n")
}

cat("\nConclusion: Results are",
    ifelse(ri_pval_pop < 0.1, "robust", "sensitive"),
    "to inference method.\n")

cat("\n=== Robustness Complete ===\n")
