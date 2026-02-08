# ============================================================
# 04_robustness.R - Robustness checks
# Paper 135: State Insulin Copay Caps and Working-Age
#             Diabetes Mortality
# ============================================================
# Checks:
#   1. Bacon decomposition (Goodman-Bacon 2021)
#   2. Wild cluster bootstrap p-values
#   3. Exclude 2020-2021 (COVID sensitivity)
#   4. Control for state COVID death rates
#   5. Placebo: heart disease mortality (unrelated cause)
#   6. Placebo: cancer mortality ages 25-64
#   7. HonestDiD sensitivity analysis
#   8. Heterogeneity by cap amount
# ============================================================

source("code/00_packages.R")

# Load data and main results
panel <- readRDS("data/analysis_panel.rds")
main_results <- readRDS("data/main_results.rds")

cat("Loaded panel:", nrow(panel), "observations\n")

# ============================================================
# 1. Bacon Decomposition (Goodman-Bacon 2021)
# ============================================================

cat("\n=============================================\n")
cat("=== 1. Bacon Decomposition               ===\n")
cat("=============================================\n")

# bacondecomp requires balanced panel with binary treatment
# NOTE: Use the SAME sample as the main TWFE analysis for consistency.
# If Bacon requires balancing, document the subsample difference.
bacon_data <- panel %>%
  select(state_id, year, mortality_rate, treated) %>%
  filter(!is.na(mortality_rate))

cat("Bacon sample (before balancing):", nrow(bacon_data), "obs,",
    n_distinct(bacon_data$state_id), "states\n")

bacon_result <- tryCatch({
  bacon(
    mortality_rate ~ treated,
    data = as.data.frame(bacon_data),
    id_var = "state_id",
    time_var = "year"
  )
}, error = function(e) {
  cat("Bacon decomposition error:", e$message, "\n")
  cat("Trying with complete balanced panel...\n")

  # Ensure balanced panel — document the subsample
  complete_states <- bacon_data %>%
    group_by(state_id) %>%
    summarise(n_years = n()) %>%
    filter(n_years == max(n_years)) %>%
    pull(state_id)

  bacon_balanced <- bacon_data %>%
    filter(state_id %in% complete_states)

  n_dropped <- n_distinct(bacon_data$state_id) - n_distinct(bacon_balanced$state_id)
  if (n_dropped > 0) {
    cat("WARNING: Bacon decomposition uses a BALANCED subsample.\n")
    cat("  Dropped", n_dropped, "states with incomplete year coverage.\n")
    cat("  Bacon sample:", nrow(bacon_balanced), "obs,",
        n_distinct(bacon_balanced$state_id), "states\n")
    cat("  This differs from the main TWFE sample (unbalanced panel).\n")
  }

  tryCatch({
    bacon(
      mortality_rate ~ treated,
      data = as.data.frame(bacon_balanced),
      id_var = "state_id",
      time_var = "year"
    )
  }, error = function(e2) {
    cat("Bacon (balanced) also failed:", e2$message, "\n")
    NULL
  })
})

if (!is.null(bacon_result)) {
  cat("\nBacon Decomposition Results:\n")

  # Summarize by comparison type
  bacon_summary <- bacon_result %>%
    group_by(type) %>%
    summarise(
      n_comparisons = n(),
      avg_estimate = weighted.mean(estimate, weight),
      total_weight = sum(weight),
      .groups = "drop"
    )

  print(bacon_summary)
  saveRDS(bacon_result, "data/bacon_decomposition.rds")

  cat("\nWeighted average (should match TWFE):",
      round(weighted.mean(bacon_result$estimate, bacon_result$weight), 4), "\n")
}

# ============================================================
# 2. Wild Cluster Bootstrap P-Values
# ============================================================

cat("\n=============================================\n")
cat("=== 2. Wild Cluster Bootstrap             ===\n")
cat("=============================================\n")

# With 51 state-level clusters, cluster-robust SEs from fixest are reliable.
# We compare multiple variance estimators as a sensitivity check.
twfe_basic <- main_results$twfe_basic

boot_result <- tryCatch({
  # Standard cluster-robust (default in fixest)
  se_cr <- summary(twfe_basic, cluster = ~state_id)

  # Small-sample correction variants
  se_cr_adj <- summary(twfe_basic, cluster = ~state_id,
                        ssc = ssc(adj = TRUE, fixef.K = "full", cluster.adj = TRUE))

  coef_val <- coef(twfe_basic)["treated"]
  se_default <- se(se_cr)["treated"]
  se_adj <- se(se_cr_adj)["treated"]
  pval_default <- pvalue(se_cr)["treated"]
  pval_adj <- pvalue(se_cr_adj)["treated"]

  cat("\nCluster-Robust Inference (51 clusters):\n")
  cat("  Coefficient:", round(coef_val, 4), "\n")
  cat("  CR SE (default):", round(se_default, 4),
      "  p-value:", round(pval_default, 4), "\n")
  cat("  CR SE (small-sample adj):", round(se_adj, 4),
      "  p-value:", round(pval_adj, 4), "\n")
  cat("  95% CI (default): [",
      round(coef_val - 1.96 * se_default, 4), ",",
      round(coef_val + 1.96 * se_default, 4), "]\n")
  cat("  95% CI (adjusted): [",
      round(coef_val - 1.96 * se_adj, 4), ",",
      round(coef_val + 1.96 * se_adj, 4), "]\n")

  list(
    coef = coef_val,
    se_default = se_default,
    se_adj = se_adj,
    pval_default = pval_default,
    pval_adj = pval_adj
  )
}, error = function(e) {
  cat("Cluster-robust inference error:", e$message, "\n")
  NULL
})

if (!is.null(boot_result)) {
  saveRDS(boot_result, "data/cluster_robust_inference.rds")
}

# ============================================================
# 3. Exclude 2020-2021 (COVID Sensitivity)
# ============================================================

cat("\n=============================================\n")
cat("=== 3. COVID Sensitivity (Drop 2020-21)  ===\n")
cat("=============================================\n")

panel_no_covid <- panel %>%
  filter(!(year %in% c(2020, 2021)))

cat("Observations after dropping 2020-2021:", nrow(panel_no_covid), "\n")

# TWFE without COVID years
twfe_no_covid <- feols(
  mortality_rate ~ treated | state_id + year,
  data = panel_no_covid,
  cluster = ~state_id
)

cat("\nTWFE Excluding 2020-2021:\n")
print(summary(twfe_no_covid))

# CS-DiD without COVID years
cs_data_no_covid <- panel_no_covid %>%
  select(state_id, year, first_treat, mortality_rate) %>%
  filter(!is.na(mortality_rate))

set.seed(135)
cs_no_covid <- tryCatch({
  att_gt(
    yname       = "mortality_rate",
    tname       = "year",
    idname      = "state_id",
    gname       = "first_treat",
    data        = as.data.frame(cs_data_no_covid),
    control_group = "nevertreated",
    est_method  = "dr",
    base_period = "universal",
    allow_unbalanced_panel = TRUE,
    bstrap      = TRUE,
    biters      = 1000
  )
}, error = function(e) {
  cat("CS (no COVID) error:", e$message, "\n")
  set.seed(135)
  tryCatch({
    att_gt(
      yname       = "mortality_rate",
      tname       = "year",
      idname      = "state_id",
      gname       = "first_treat",
      data        = as.data.frame(cs_data_no_covid),
      control_group = "nevertreated",
      est_method  = "reg",
      base_period = "universal",
      allow_unbalanced_panel = TRUE,
      bstrap      = TRUE,
      biters      = 1000
    )
  }, error = function(e2) {
    cat("CS reg (no COVID) also failed:", e2$message, "\n")
    NULL
  })
})

cs_no_covid_att <- NULL
if (!is.null(cs_no_covid)) {
  cs_no_covid_att <- aggte(cs_no_covid, type = "simple")
  cat("\nCS-DiD ATT (no COVID):", round(cs_no_covid_att$overall.att, 4),
      "(SE:", round(cs_no_covid_att$overall.se, 4), ")\n")
}

# ============================================================
# 4. Control for State COVID Death Rates
# ============================================================

cat("\n=============================================\n")
cat("=== 4. COVID Death Rate Controls          ===\n")
cat("=============================================\n")

twfe_covid_control <- feols(
  mortality_rate ~ treated + covid_death_rate | state_id + year,
  data = panel,
  cluster = ~state_id
)

cat("\nTWFE with COVID Death Rate Control:\n")
print(summary(twfe_covid_control))

# Also with COVID year dummies
twfe_covid_dummies <- feols(
  mortality_rate ~ treated + covid_2020 + covid_2021 | state_id + year,
  data = panel,
  cluster = ~state_id
)

cat("\nTWFE with COVID Year Dummies:\n")
print(summary(twfe_covid_dummies))

# ============================================================
# 5. Placebo Test: Heart Disease Mortality (Placebo)
# ============================================================

cat("\n=============================================\n")
cat("=== 5. Placebo: Heart Disease Mortality   ===\n")
cat("=============================================\n")
cat("Rationale: Insulin copay caps should NOT affect\n")
cat("heart disease mortality rates.\n")
cat("Note: Heart disease placebo data covers 1999-2017 only.\n\n")

# Restrict to years with heart disease data (1999-2017)
panel_heart <- panel %>%
  filter(!is.na(mortality_rate_heart))

cat("Heart disease placebo sample:", nrow(panel_heart), "obs,",
    n_distinct(panel_heart$year), "years (",
    min(panel_heart$year), "-", max(panel_heart$year), ")\n")

# TWFE on heart disease outcome
placebo_heart_twfe <- tryCatch({
  feols(
    mortality_rate_heart ~ treated | state_id + year,
    data = panel_heart,
    cluster = ~state_id
  )
}, error = function(e) {
  cat("Placebo heart TWFE error:", e$message, "\n")
  NULL
})

if (!is.null(placebo_heart_twfe)) {
  cat("\nPlacebo (Heart Disease Mortality) - TWFE:\n")
  print(summary(placebo_heart_twfe))
}

# CS-DiD on heart disease outcome (restricted to 1999-2017)
cs_data_heart <- panel_heart %>%
  select(state_id, year, first_treat, mortality_rate_heart) %>%
  rename(mortality_rate = mortality_rate_heart) %>%
  filter(!is.na(mortality_rate))

set.seed(135)
cs_placebo_heart <- tryCatch({
  out <- att_gt(
    yname       = "mortality_rate",
    tname       = "year",
    idname      = "state_id",
    gname       = "first_treat",
    data        = as.data.frame(cs_data_heart),
    control_group = "nevertreated",
    est_method  = "reg",
    base_period = "universal",
    allow_unbalanced_panel = TRUE,
    bstrap      = TRUE,
    biters      = 1000
  )
  agg <- aggte(out, type = "simple")
  cat("\nCS-DiD Placebo (Heart Disease) ATT:", round(agg$overall.att, 4),
      "(SE:", round(agg$overall.se, 4), ")\n")

  # Event study for placebo
  es_heart <- tryCatch(aggte(out, type = "dynamic"), error = function(e) NULL)
  if (!is.null(es_heart)) {
    saveRDS(es_heart, "data/placebo_heart_event_study.rds")
  }
  list(att_gt = out, agg = agg, event = es_heart)
}, error = function(e) {
  cat("CS Placebo Heart error:", e$message, "\n")
  NULL
})

# ============================================================
# 6. Placebo Test: Cancer Mortality Ages 25-64
# ============================================================

cat("\n=============================================\n")
cat("=== 6. Placebo: Cancer Mortality 25-64   ===\n")
cat("=============================================\n")
cat("Rationale: Insulin copay caps should NOT affect\n")
cat("cancer mortality in the working-age population.\n")
cat("Note: Cancer placebo data covers 1999-2017 only.\n\n")

# Restrict to years with cancer data (1999-2017)
panel_cancer <- panel %>%
  filter(!is.na(mortality_rate_cancer))

cat("Cancer placebo sample:", nrow(panel_cancer), "obs,",
    n_distinct(panel_cancer$year), "years (",
    min(panel_cancer$year), "-", max(panel_cancer$year), ")\n")

# TWFE on cancer outcome
placebo_cancer_twfe <- tryCatch({
  feols(
    mortality_rate_cancer ~ treated | state_id + year,
    data = panel_cancer,
    cluster = ~state_id
  )
}, error = function(e) {
  cat("Placebo cancer TWFE error:", e$message, "\n")
  NULL
})

if (!is.null(placebo_cancer_twfe)) {
  cat("\nPlacebo (Cancer Mortality 25-64) - TWFE:\n")
  print(summary(placebo_cancer_twfe))
}

# CS-DiD on cancer outcome (restricted to 1999-2017)
cs_data_cancer <- panel_cancer %>%
  select(state_id, year, first_treat, mortality_rate_cancer) %>%
  rename(mortality_rate = mortality_rate_cancer) %>%
  filter(!is.na(mortality_rate))

set.seed(135)
cs_placebo_cancer <- tryCatch({
  out <- att_gt(
    yname       = "mortality_rate",
    tname       = "year",
    idname      = "state_id",
    gname       = "first_treat",
    data        = as.data.frame(cs_data_cancer),
    control_group = "nevertreated",
    est_method  = "reg",
    base_period = "universal",
    allow_unbalanced_panel = TRUE,
    bstrap      = TRUE,
    biters      = 1000
  )
  agg <- aggte(out, type = "simple")
  cat("\nCS-DiD Placebo (Cancer) ATT:", round(agg$overall.att, 4),
      "(SE:", round(agg$overall.se, 4), ")\n")

  es_cancer <- tryCatch(aggte(out, type = "dynamic"), error = function(e) NULL)
  if (!is.null(es_cancer)) {
    saveRDS(es_cancer, "data/placebo_cancer_event_study.rds")
  }
  list(att_gt = out, agg = agg, event = es_cancer)
}, error = function(e) {
  cat("CS Placebo Cancer error:", e$message, "\n")
  NULL
})

# ============================================================
# 7. HonestDiD Sensitivity Analysis
# ============================================================

cat("\n=============================================\n")
cat("=== 7. HonestDiD Sensitivity Analysis    ===\n")
cat("=============================================\n")

honest_result <- NULL

if (!is.null(main_results$cs_event)) {
  cs_event <- main_results$cs_event

  tryCatch({
    # Extract the event study for HonestDiD
    # Need: betahat (coefficients), sigma (variance-covariance matrix)
    # The CS event study provides these

    # Handle different possible field names in cs_event object
    es_coefs <- if (!is.null(cs_event$att.egt)) cs_event$att.egt else cs_event$att
    es_times <- if (!is.null(cs_event$egt)) cs_event$egt else cs_event$e
    es_se    <- if (!is.null(cs_event$se.egt)) cs_event$se.egt else cs_event$se

    if (is.null(es_coefs) || is.null(es_times) || is.null(es_se)) {
      cat("Could not extract event study coefficients from cs_event object.\n")
      cat("Available fields:", paste(names(cs_event), collapse = ", "), "\n")
    } else {
      # Remove periods with NA SE (base periods that are zero by construction)
      valid_idx <- which(!is.na(es_se) & !is.na(es_coefs))
      es_coefs <- es_coefs[valid_idx]
      es_times <- es_times[valid_idx]
      es_se    <- es_se[valid_idx]

      # Separate pre and post coefficients
      pre_idx  <- which(es_times < 0)
      post_idx <- which(es_times >= 0)

      cat("Event study periods (after removing NA):", length(es_times), "\n")
      cat("Pre-periods:", length(pre_idx), ", Post-periods:", length(post_idx), "\n")

      if (length(pre_idx) >= 2 && length(post_idx) >= 1) {
        # Construct the coefficient vector and VCV matrix
        betahat <- es_coefs
        # NOTE: Using diagonal VCV (ignoring off-diagonal covariances between
        # event-study coefficients). This is NOT necessarily conservative—it
        # ignores positive covariances that could narrow CIs, but also ignores
        # negative covariances that could widen them. The full VCV from the CS
        # bootstrap is not directly extractable in a compatible format.
        # This approximation is standard in applied HonestDiD usage.
        sigma   <- diag(es_se^2)  # Diagonal approximation

        # HonestDiD: Relative magnitudes approach
        # This relaxes parallel trends by allowing violations bounded
        # relative to pre-trend differences
        honest_rm <- tryCatch({
          HonestDiD::createSensitivityResults_relativeMagnitudes(
            betahat    = betahat,
            sigma      = sigma,
            numPrePeriods  = length(pre_idx),
            numPostPeriods = length(post_idx),
            Mbarvec    = seq(0, 2, by = 0.5)
          )
        }, error = function(e) {
          cat("HonestDiD relative magnitudes error:", e$message, "\n")
          NULL
        })

        if (!is.null(honest_rm)) {
          cat("\nHonestDiD Results (Relative Magnitudes):\n")
          cat("Mbar = Maximum pre-trend violation relative to max pre-period diff\n\n")
          print(honest_rm)
          honest_result <- honest_rm
        }

        # Smoothness-based approach (Delta^SD)
        honest_sd <- tryCatch({
          HonestDiD::createSensitivityResults(
            betahat    = betahat,
            sigma      = sigma,
            numPrePeriods  = length(pre_idx),
            numPostPeriods = length(post_idx),
            Mvec       = seq(0, 0.05, by = 0.01),
            method     = "FLCI"
          )
        }, error = function(e) {
          cat("HonestDiD smoothness error:", e$message, "\n")
          NULL
        })

        if (!is.null(honest_sd)) {
          cat("\nHonestDiD Results (Smoothness):\n")
          print(honest_sd)
        }

        # Save both sets of results
        saveRDS(list(
          relative_magnitudes = honest_rm,
          smoothness = honest_sd,
          betahat = betahat,
          sigma = sigma,
          pre_idx = pre_idx,
          post_idx = post_idx,
          es_times = es_times
        ), "data/honestdid_results.rds")

      } else {
        cat("Insufficient pre/post periods for HonestDiD\n")
        cat("Pre-periods:", length(pre_idx), ", Post-periods:", length(post_idx), "\n")
      }
    }

  }, error = function(e) {
    cat("HonestDiD analysis error:", e$message, "\n")
  })
} else {
  cat("CS event study results not available for HonestDiD\n")
}

# ============================================================
# 8. Heterogeneity by Cap Amount
# ============================================================

cat("\n=============================================\n")
cat("=== 8. Heterogeneity by Cap Amount       ===\n")
cat("=============================================\n")

cat("Cap categories:\n")
panel %>%
  filter(first_treat > 0) %>%
  distinct(state_fips, cap_category, cap_amount) %>%
  arrange(cap_amount) %>%
  print(n = 30)

# TWFE by cap category
het_low <- tryCatch({
  feols(
    mortality_rate ~ treated | state_id + year,
    data = panel %>% filter(cap_category %in% c("Low ($25-30)", "No Cap")),
    cluster = ~state_id
  )
}, error = function(e) NULL)

het_med <- tryCatch({
  feols(
    mortality_rate ~ treated | state_id + year,
    data = panel %>% filter(cap_category %in% c("Medium ($35-50)", "No Cap")),
    cluster = ~state_id
  )
}, error = function(e) NULL)

het_high <- tryCatch({
  feols(
    mortality_rate ~ treated | state_id + year,
    data = panel %>% filter(cap_category %in% c("High ($100)", "No Cap")),
    cluster = ~state_id
  )
}, error = function(e) NULL)

if (!is.null(het_low)) {
  cat("\nCap = $25-30 (Low):\n")
  print(summary(het_low))
}

if (!is.null(het_med)) {
  cat("\nCap = $35-50 (Medium):\n")
  print(summary(het_med))
}

if (!is.null(het_high)) {
  cat("\nCap = $100 (High):\n")
  print(summary(het_high))
}

# ============================================================
# 9. Wild Cluster Bootstrap P-Values (fwildclusterboot)
# ============================================================

cat("\n=============================================\n")
cat("=== 9. Wild Cluster Bootstrap (Actual)   ===\n")
cat("=============================================\n")

wild_boot_result <- NULL
tryCatch({
  if (!require("fwildclusterboot", quietly = TRUE)) {
    install.packages("fwildclusterboot")
    library(fwildclusterboot)
  }

  # Use the basic TWFE model for wild bootstrap
  twfe_basic <- main_results$twfe_basic

  set.seed(135)
  boot_out <- boottest(
    twfe_basic,
    param = "treated",
    clustid = ~state_id,
    B = 9999,
    type = "webb"  # Webb 6-point weights
  )

  cat("\nWild Cluster Bootstrap Results:\n")
  cat("  Point estimate:", round(boot_out$point_estimate, 4), "\n")
  cat("  Bootstrap p-value:", round(boot_out$p_val, 4), "\n")
  cat("  95% CI: [", round(boot_out$conf_int[1], 4), ",",
      round(boot_out$conf_int[2], 4), "]\n")

  wild_boot_result <- list(
    point_estimate = boot_out$point_estimate,
    p_val = boot_out$p_val,
    conf_int = boot_out$conf_int
  )

  saveRDS(wild_boot_result, "data/wild_bootstrap_result.rds")
}, error = function(e) {
  cat("Wild cluster bootstrap error:", e$message, "\n")
  cat("Proceeding without wild bootstrap results.\n")
})

# ============================================================
# 10. Minimum Detectable Effect (MDE) Table
# ============================================================

cat("\n=============================================\n")
cat("=== 10. Minimum Detectable Effect (MDE) ===\n")
cat("=============================================\n")

tryCatch({
  # Compute MDE using actual estimator variance
  twfe_basic <- main_results$twfe_basic
  se_treated <- summary(twfe_basic)$se["treated"]

  # MDE at 80% power, 5% significance (two-sided)
  # MDE = (z_alpha/2 + z_beta) * SE = (1.96 + 0.84) * SE = 2.8 * SE
  mde_80 <- 2.8 * se_treated
  mde_90 <- (1.96 + 1.28) * se_treated  # 90% power

  mean_rate <- mean(panel$mortality_rate, na.rm = TRUE)

  cat("MDE Calculation (based on TWFE estimator variance):\n")
  cat("  SE of treated coefficient:", round(se_treated, 4), "\n")
  cat("  MDE at 80% power (5% sig):", round(mde_80, 2), "deaths per 100K\n")
  cat("  MDE at 90% power (5% sig):", round(mde_90, 2), "deaths per 100K\n")
  cat("  Mean mortality rate:", round(mean_rate, 2), "per 100K\n")
  cat("  MDE as % of mean (80% power):", round(mde_80 / mean_rate * 100, 1), "%\n")
  cat("  MDE as % of mean (90% power):", round(mde_90 / mean_rate * 100, 1), "%\n")

  # CS estimator MDE
  if (!is.null(main_results$cs_agg_simple)) {
    cs_se <- main_results$cs_agg_simple$overall.se
    cs_mde_80 <- 2.8 * cs_se
    cat("\n  CS-DiD SE:", round(cs_se, 4), "\n")
    cat("  CS-DiD MDE at 80% power:", round(cs_mde_80, 2), "deaths per 100K\n")
    cat("  CS-DiD MDE as % of mean:", round(cs_mde_80 / mean_rate * 100, 1), "%\n")
  }

  mde_table <- data.frame(
    Estimator = c("TWFE", "TWFE", "CS-DiD"),
    Power = c("80%", "90%", "80%"),
    SE = c(se_treated, se_treated,
           ifelse(!is.null(main_results$cs_agg_simple), main_results$cs_agg_simple$overall.se, NA)),
    MDE = c(mde_80, mde_90,
            ifelse(!is.null(main_results$cs_agg_simple), 2.8 * main_results$cs_agg_simple$overall.se, NA)),
    MDE_pct = c(mde_80/mean_rate*100, mde_90/mean_rate*100,
                ifelse(!is.null(main_results$cs_agg_simple), 2.8 * main_results$cs_agg_simple$overall.se / mean_rate * 100, NA))
  )

  saveRDS(mde_table, "data/mde_table.rds")
  write_csv(mde_table, "tables/tableA_mde.csv")

}, error = function(e) {
  cat("MDE calculation error:", e$message, "\n")
})

# ============================================================
# 11. Placebo-in-Time Test (Never-Treated States)
# ============================================================

cat("\n=============================================\n")
cat("=== 11. Placebo-in-Time (Never-Treated)  ===\n")
cat("=============================================\n")

tryCatch({
  # Assign a fake treatment year (2015) to half of never-treated states
  never_treated <- panel %>%
    filter(first_treat == 0) %>%
    distinct(state_id) %>%
    mutate(fake_treat = ifelse(row_number() <= n()/2, 2015L, 0L))

  placebo_time_data <- panel %>%
    filter(first_treat == 0) %>%
    left_join(never_treated, by = "state_id") %>%
    mutate(
      fake_treated = as.integer(fake_treat > 0 & year >= fake_treat)
    )

  # TWFE with fake treatment
  placebo_time_twfe <- feols(
    mortality_rate ~ fake_treated | state_id + year,
    data = placebo_time_data,
    cluster = ~state_id
  )

  cat("\nPlacebo-in-Time TWFE (fake treatment at 2015 for half of never-treated):\n")
  print(summary(placebo_time_twfe))

  saveRDS(placebo_time_twfe, "data/placebo_in_time.rds")
}, error = function(e) {
  cat("Placebo-in-time error:", e$message, "\n")
})

# ============================================================
# 12. Anticipation/Leads Test
# ============================================================

cat("\n=============================================\n")
cat("=== 12. Anticipation/Leads Test          ===\n")
cat("=============================================\n")

tryCatch({
  # Create lead indicators (1-3 years before treatment)
  panel_leads <- panel %>%
    mutate(
      lead1 = as.integer(first_treat > 0 & year == first_treat - 1),
      lead2 = as.integer(first_treat > 0 & year == first_treat - 2),
      lead3 = as.integer(first_treat > 0 & year == first_treat - 3)
    )

  # TWFE with leads
  twfe_leads <- feols(
    mortality_rate ~ treated + lead1 + lead2 + lead3 | state_id + year,
    data = panel_leads,
    cluster = ~state_id
  )

  cat("\nTWFE with Anticipation Leads:\n")
  print(summary(twfe_leads))

  # Joint test of leads
  lead_coefs <- coef(twfe_leads)[c("lead1", "lead2", "lead3")]
  lead_ses <- summary(twfe_leads)$se[c("lead1", "lead2", "lead3")]
  cat("\nLead coefficients (should be ~0 under no anticipation):\n")
  for (nm in names(lead_coefs)) {
    cat(sprintf("  %s: %.3f (SE = %.3f, p = %.3f)\n",
                nm, lead_coefs[nm], lead_ses[nm],
                2 * pnorm(-abs(lead_coefs[nm] / lead_ses[nm]))))
  }

  saveRDS(twfe_leads, "data/anticipation_leads.rds")
}, error = function(e) {
  cat("Anticipation leads error:", e$message, "\n")
})

# ============================================================
# 13. Additional Robustness: Log Specification
# ============================================================

cat("\n=============================================\n")
cat("=== 9. Log Mortality Rate Specification  ===\n")
cat("=============================================\n")

cs_log_data <- panel %>%
  select(state_id, year, first_treat, log_mortality_rate) %>%
  rename(y = log_mortality_rate) %>%
  filter(!is.na(y))

set.seed(135)
cs_log <- tryCatch({
  att_gt(
    yname       = "y",
    tname       = "year",
    idname      = "state_id",
    gname       = "first_treat",
    data        = as.data.frame(cs_log_data),
    control_group = "nevertreated",
    est_method  = "reg",
    base_period = "universal",
    allow_unbalanced_panel = TRUE,
    bstrap      = TRUE,
    biters      = 1000
  )
}, error = function(e) {
  cat("CS (log) error:", e$message, "\n")
  NULL
})

if (!is.null(cs_log)) {
  cs_log_att <- aggte(cs_log, type = "simple")
  cat("CS-DiD ATT (log mortality):", round(cs_log_att$overall.att, 4),
      "(SE:", round(cs_log_att$overall.se, 4), ")\n")
  cat("Implied % change:", round((exp(cs_log_att$overall.att) - 1) * 100, 2), "%\n")
}

# ============================================================
# 10. Save All Robustness Results
# ============================================================

cat("\n=== Saving Robustness Results ===\n")

robustness_results <- list(
  bacon = bacon_result,
  cluster_robust = boot_result,
  wild_bootstrap = wild_boot_result,
  twfe_no_covid = twfe_no_covid,
  cs_no_covid_att = cs_no_covid_att,
  twfe_covid_control = twfe_covid_control,
  twfe_covid_dummies = twfe_covid_dummies,
  placebo_heart_twfe = placebo_heart_twfe,
  placebo_cancer_twfe = placebo_cancer_twfe,
  cs_placebo_heart = cs_placebo_heart,
  cs_placebo_cancer = cs_placebo_cancer,
  honestdid = honest_result,
  het_low = het_low,
  het_med = het_med,
  het_high = het_high,
  cs_log = if (exists("cs_log_att")) cs_log_att else NULL,
  placebo_in_time = if (exists("placebo_time_twfe")) placebo_time_twfe else NULL,
  anticipation_leads = if (exists("twfe_leads")) twfe_leads else NULL
)

saveRDS(robustness_results, "data/robustness_results.rds")

cat("Saved data/robustness_results.rds\n")
cat("\n=== Robustness Checks Complete ===\n")
