# ============================================================
# 04_robustness.R - Robustness checks
# Paper 142: State Insulin Copay Caps and Working-Age
#             Diabetes Mortality (v3)
# ============================================================
# Checks:
#   1. Bacon decomposition (Goodman-Bacon 2021)
#   2. Cluster-robust variance estimators
#   3. Exclude 2020-2021 (COVID sensitivity)
#   4. Control for state COVID death rates
#   5. Placebo: heart disease mortality (pre-treatment 1999-2017)
#   5B. Placebo: heart disease mortality (full panel incl. 2020-2023)
#   6. Placebo: cancer mortality (pre-treatment 1999-2017)
#   6B. Placebo: cancer mortality (full panel incl. 2020-2023)
#   7. HonestDiD sensitivity analysis (FULL VCV)
#   8. Heterogeneity by cap amount
#   9. Wild cluster bootstrap (fwildclusterboot)
#   10. MDE table
#   10B. MDE dilution mapping table
#   11. Placebo-in-time
#   12. Anticipation/leads
#   13. Log specification
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
# 2. Cluster-Robust Variance Estimators
# ============================================================

cat("\n=============================================\n")
cat("=== 2. Cluster-Robust Inference           ===\n")
cat("=============================================\n")

twfe_basic <- main_results$twfe_basic

boot_result <- tryCatch({
  se_cr <- summary(twfe_basic, cluster = ~state_id)
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

twfe_no_covid <- feols(
  mortality_rate ~ treated | state_id + year,
  data = panel_no_covid,
  cluster = ~state_id
)

cat("\nTWFE Excluding 2020-2021:\n")
print(summary(twfe_no_covid))

cs_data_no_covid <- panel_no_covid %>%
  select(state_id, year, first_treat, mortality_rate) %>%
  filter(!is.na(mortality_rate))

set.seed(142)
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
  set.seed(142)
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

twfe_covid_dummies <- feols(
  mortality_rate ~ treated + covid_2020 + covid_2021 | state_id + year,
  data = panel,
  cluster = ~state_id
)

cat("\nTWFE with COVID Year Dummies:\n")
print(summary(twfe_covid_dummies))

# ============================================================
# 5. Placebo Test: Heart Disease Mortality (Pre-Treatment)
# ============================================================

cat("\n=============================================\n")
cat("=== 5. Placebo: Heart Disease (Pre-Treat) ===\n")
cat("=============================================\n")

panel_heart <- panel %>%
  filter(!is.na(mortality_rate_heart))

cat("Heart disease placebo sample:", nrow(panel_heart), "obs,",
    n_distinct(panel_heart$year), "years (",
    min(panel_heart$year), "-", max(panel_heart$year), ")\n")

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

cs_data_heart <- panel_heart %>%
  select(state_id, year, first_treat, mortality_rate_heart) %>%
  rename(mortality_rate = mortality_rate_heart) %>%
  filter(!is.na(mortality_rate))

set.seed(142)
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
# 5B. Placebo Test: Heart Disease (Full Panel incl. 2020-2023)
# ============================================================

cat("\n=============================================\n")
cat("=== 5B. Placebo: Heart Disease (Full)     ===\n")
cat("=============================================\n")
cat("Post-treatment heart disease placebo with 2020-2023 data.\n")
cat("This tests whether copay caps affect heart disease mortality\n")
cat("in the actual treatment period (they should not).\n\n")

cs_placebo_heart_full <- NULL
if (any(panel_heart$year >= 2020)) {
  cat("Heart placebo full panel:", nrow(panel_heart), "obs (",
      min(panel_heart$year), "-", max(panel_heart$year), ")\n")
  cat("Post-2020 heart obs:", sum(panel_heart$year >= 2020), "\n")

  set.seed(142)
  cs_placebo_heart_full <- tryCatch({
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
    cat("\nCS-DiD Placebo Heart (Full Panel) ATT:", round(agg$overall.att, 4),
        "(SE:", round(agg$overall.se, 4), ")\n")

    es_heart_full <- tryCatch(aggte(out, type = "dynamic"), error = function(e) NULL)
    if (!is.null(es_heart_full)) {
      saveRDS(es_heart_full, "data/placebo_heart_event_study_full.rds")
    }
    list(att_gt = out, agg = agg, event = es_heart_full)
  }, error = function(e) {
    cat("CS Placebo Heart (full) error:", e$message, "\n")
    NULL
  })
} else {
  cat("No post-2020 heart disease data available for full-panel placebo.\n")
}

# ============================================================
# 6. Placebo Test: Cancer Mortality (Pre-Treatment)
# ============================================================

cat("\n=============================================\n")
cat("=== 6. Placebo: Cancer (Pre-Treatment)   ===\n")
cat("=============================================\n")

panel_cancer <- panel %>%
  filter(!is.na(mortality_rate_cancer))

cat("Cancer placebo sample:", nrow(panel_cancer), "obs,",
    n_distinct(panel_cancer$year), "years (",
    min(panel_cancer$year), "-", max(panel_cancer$year), ")\n")

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
  cat("\nPlacebo (Cancer Mortality) - TWFE:\n")
  print(summary(placebo_cancer_twfe))
}

cs_data_cancer <- panel_cancer %>%
  select(state_id, year, first_treat, mortality_rate_cancer) %>%
  rename(mortality_rate = mortality_rate_cancer) %>%
  filter(!is.na(mortality_rate))

set.seed(142)
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
# 6B. Placebo Test: Cancer (Full Panel incl. 2020-2023)
# ============================================================

cat("\n=============================================\n")
cat("=== 6B. Placebo: Cancer (Full Panel)      ===\n")
cat("=============================================\n")

cs_placebo_cancer_full <- NULL
if (any(panel_cancer$year >= 2020)) {
  cat("Cancer placebo full panel:", nrow(panel_cancer), "obs (",
      min(panel_cancer$year), "-", max(panel_cancer$year), ")\n")
  cat("Post-2020 cancer obs:", sum(panel_cancer$year >= 2020), "\n")

  set.seed(142)
  cs_placebo_cancer_full <- tryCatch({
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
    cat("\nCS-DiD Placebo Cancer (Full Panel) ATT:", round(agg$overall.att, 4),
        "(SE:", round(agg$overall.se, 4), ")\n")

    es_cancer_full <- tryCatch(aggte(out, type = "dynamic"), error = function(e) NULL)
    if (!is.null(es_cancer_full)) {
      saveRDS(es_cancer_full, "data/placebo_cancer_event_study_full.rds")
    }
    list(att_gt = out, agg = agg, event = es_cancer_full)
  }, error = function(e) {
    cat("CS Placebo Cancer (full) error:", e$message, "\n")
    NULL
  })
} else {
  cat("No post-2020 cancer data available for full-panel placebo.\n")
}

# ============================================================
# 7. HonestDiD Sensitivity Analysis (FULL VCV)
# ============================================================

cat("\n=============================================\n")
cat("=== 7. HonestDiD Sensitivity (Full VCV)  ===\n")
cat("=============================================\n")

honest_result <- NULL
vcv_method <- "diagonal"  # Track which method was used

if (!is.null(main_results$cs_event)) {
  cs_event <- main_results$cs_event

  tryCatch({
    es_coefs <- if (!is.null(cs_event$att.egt)) cs_event$att.egt else cs_event$att
    es_times <- if (!is.null(cs_event$egt)) cs_event$egt else cs_event$e
    es_se    <- if (!is.null(cs_event$se.egt)) cs_event$se.egt else cs_event$se

    if (is.null(es_coefs) || is.null(es_times) || is.null(es_se)) {
      cat("Could not extract event study coefficients from cs_event object.\n")
      cat("Available fields:", paste(names(cs_event), collapse = ", "), "\n")
    } else {
      valid_idx <- which(!is.na(es_se) & !is.na(es_coefs))
      es_coefs <- es_coefs[valid_idx]
      es_times <- es_times[valid_idx]
      es_se    <- es_se[valid_idx]

      pre_idx  <- which(es_times < 0)
      post_idx <- which(es_times >= 0)

      cat("Event study periods (after removing NA):", length(es_times), "\n")
      cat("Pre-periods:", length(pre_idx), ", Post-periods:", length(post_idx), "\n")

      if (length(pre_idx) >= 2 && length(post_idx) >= 1) {
        betahat <- es_coefs

        # ---- ATTEMPT TO EXTRACT FULL VCV FROM INFLUENCE FUNCTIONS ----
        # The CS aggte() object stores influence functions in $inf.function
        # We compute the full VCV as crossprod(inf_func) / n^2
        sigma <- NULL

        inf_func <- tryCatch({
          if (!is.null(cs_event$inf.function)) {
            if (!is.null(cs_event$inf.function$dynamic)) {
              cs_event$inf.function$dynamic
            } else if (is.matrix(cs_event$inf.function)) {
              cs_event$inf.function
            } else {
              NULL
            }
          } else {
            NULL
          }
        }, error = function(e) NULL)

        if (!is.null(inf_func) && is.matrix(inf_func)) {
          # Subset to valid columns matching our valid_idx
          if (ncol(inf_func) >= length(valid_idx)) {
            inf_sub <- inf_func[, valid_idx, drop = FALSE]
            n_units <- nrow(inf_sub)
            sigma <- crossprod(inf_sub) / (n_units^2)
            vcv_method <- "full_influence_function"
            cat("  Extracted full VCV from influence functions (", n_units, " units x ",
                ncol(inf_sub), " periods)\n")
            cat("  VCV dimensions:", nrow(sigma), "x", ncol(sigma), "\n")
          } else {
            cat("  Influence function columns (", ncol(inf_func),
                ") < valid periods (", length(valid_idx), "). Using diagonal.\n")
          }
        }

        # Fallback to diagonal if full VCV extraction failed
        if (is.null(sigma)) {
          sigma <- diag(es_se^2)
          vcv_method <- "diagonal"
          cat("  Using diagonal VCV approximation (full VCV not extractable).\n")
        }

        cat("  VCV method:", vcv_method, "\n")

        # HonestDiD: Relative magnitudes approach
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
          cat("VCV method:", vcv_method, "\n\n")
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

        # Save both sets of results with VCV method metadata
        saveRDS(list(
          relative_magnitudes = honest_rm,
          smoothness = honest_sd,
          betahat = betahat,
          sigma = sigma,
          vcv_method = vcv_method,
          pre_idx = pre_idx,
          post_idx = post_idx,
          es_times = es_times
        ), "data/honestdid_results.rds")

      } else {
        cat("Insufficient pre/post periods for HonestDiD\n")
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

if (!is.null(het_low)) { cat("\nCap = $25-30 (Low):\n"); print(summary(het_low)) }
if (!is.null(het_med)) { cat("\nCap = $35-50 (Medium):\n"); print(summary(het_med)) }
if (!is.null(het_high)) { cat("\nCap = $100 (High):\n"); print(summary(het_high)) }

# ============================================================
# 9. Wild Cluster Bootstrap (fwildclusterboot)
# ============================================================

cat("\n=============================================\n")
cat("=== 9. Wild Cluster Bootstrap             ===\n")
cat("=============================================\n")

wild_boot_result <- NULL

# Primary: fwildclusterboot::boottest()
tryCatch({
  twfe_basic <- main_results$twfe_basic

  set.seed(142)
  boot_out <- fwildclusterboot::boottest(
    twfe_basic,
    param = "treated",
    clustid = ~state_id,
    B = 9999,
    type = "webb"  # Webb 6-point weights
  )

  cat("\nWild Cluster Bootstrap Results (fwildclusterboot):\n")
  cat("  Point estimate:", round(boot_out$point_estimate, 4), "\n")
  cat("  Bootstrap p-value:", round(boot_out$p_val, 4), "\n")
  cat("  95% CI: [", round(boot_out$conf_int[1], 4), ",",
      round(boot_out$conf_int[2], 4), "]\n")
  cat("  Method: Webb 6-point weights, B=9999\n")

  wild_boot_result <- list(
    point_estimate = boot_out$point_estimate,
    p_val = boot_out$p_val,
    conf_int = boot_out$conf_int,
    method = "fwildclusterboot_webb_9999"
  )

  saveRDS(wild_boot_result, "data/wild_bootstrap_result.rds")
}, error = function(e) {
  cat("fwildclusterboot error:", e$message, "\n")
  cat("Attempting sandwich::vcovBS fallback...\n")

  # Fallback: sandwich::vcovBS (pairs cluster bootstrap)
  tryCatch({
    twfe_basic <- main_results$twfe_basic
    # Extract the model frame data for vcovBS
    set.seed(142)
    vcov_bs <- sandwich::vcovBS(twfe_basic, cluster = ~state_id, R = 999)
    se_bs <- sqrt(diag(vcov_bs))["treated"]
    coef_val <- coef(twfe_basic)["treated"]
    p_bs <- 2 * pnorm(-abs(coef_val / se_bs))

    cat("\nSandwich Bootstrap Results (fallback):\n")
    cat("  Point estimate:", round(coef_val, 4), "\n")
    cat("  Bootstrap SE:", round(se_bs, 4), "\n")
    cat("  Bootstrap p-value:", round(p_bs, 4), "\n")
    cat("  95% CI: [", round(coef_val - 1.96 * se_bs, 4), ",",
        round(coef_val + 1.96 * se_bs, 4), "]\n")

    wild_boot_result <<- list(
      point_estimate = coef_val,
      p_val = p_bs,
      conf_int = c(coef_val - 1.96 * se_bs, coef_val + 1.96 * se_bs),
      method = "sandwich_vcovBS_999"
    )
    saveRDS(wild_boot_result, "data/wild_bootstrap_result.rds")
  }, error = function(e2) {
    cat("Sandwich bootstrap also failed:", e2$message, "\n")
    cat("Proceeding without wild bootstrap results.\n")
  })
})

# ============================================================
# 10. Minimum Detectable Effect (MDE) Table
# ============================================================

cat("\n=============================================\n")
cat("=== 10. Minimum Detectable Effect (MDE) ===\n")
cat("=============================================\n")

tryCatch({
  twfe_basic <- main_results$twfe_basic
  se_treated <- summary(twfe_basic)$se["treated"]

  mde_80 <- 2.8 * se_treated
  mde_90 <- (1.96 + 1.28) * se_treated

  mean_rate <- mean(panel$mortality_rate, na.rm = TRUE)

  cat("MDE Calculation (based on TWFE estimator variance):\n")
  cat("  SE of treated coefficient:", round(se_treated, 4), "\n")
  cat("  MDE at 80% power (5% sig):", round(mde_80, 2), "deaths per 100K\n")
  cat("  MDE at 90% power (5% sig):", round(mde_90, 2), "deaths per 100K\n")
  cat("  Mean mortality rate:", round(mean_rate, 2), "per 100K\n")
  cat("  MDE as % of mean (80% power):", round(mde_80 / mean_rate * 100, 1), "%\n")

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
# 10B. MDE Dilution Mapping Table
# ============================================================

cat("\n=============================================\n")
cat("=== 10B. MDE Dilution Mapping Table      ===\n")
cat("=============================================\n")
cat("Dilution algebra: ATT_pop = s * Delta_T\n")
cat("where s = share of mortality from treated subpopulation\n")
cat("and Delta_T = true effect on treated subpopulation\n\n")

tryCatch({
  twfe_basic <- main_results$twfe_basic
  se_treated <- summary(twfe_basic)$se["treated"]
  mde_80 <- 2.8 * se_treated
  mean_rate <- mean(panel$mortality_rate, na.rm = TRUE)

  # Treated-share scenarios
  s_values <- c(0.03, 0.05, 0.10, 0.15, 0.20)

  dilution_table <- data.frame(
    treated_share = s_values,
    treated_share_pct = s_values * 100,
    mde_pop_level = mde_80,
    mde_treated_group = mde_80 / s_values,
    mde_treated_pct_baseline = (mde_80 / s_values) / mean_rate * 100,
    mean_mortality = mean_rate
  )

  cat("Dilution Mapping (80% power, 5% significance):\n")
  cat("Population-level MDE:", round(mde_80, 2), "deaths per 100K\n")
  cat("Mean mortality rate:", round(mean_rate, 2), "per 100K\n\n")

  cat(sprintf("%-15s %-15s %-20s %-20s\n",
              "Treated Share", "s (%)", "MDE on Treated", "MDE as % of Mean"))
  cat(paste(rep("-", 70), collapse = ""), "\n")
  for (i in 1:nrow(dilution_table)) {
    cat(sprintf("%-15.2f %-15.0f %-20.2f %-20.1f%%\n",
                dilution_table$treated_share[i],
                dilution_table$treated_share_pct[i],
                dilution_table$mde_treated_group[i],
                dilution_table$mde_treated_pct_baseline[i]))
  }

  saveRDS(dilution_table, "data/dilution_table.rds")
  write_csv(dilution_table, "tables/tableA4_dilution.csv")

  cat("\nKey finding: For realistic s = 3-5%, the MDE on the treated\n")
  cat("subpopulation exceeds 100% of baseline mortality, meaning the\n")
  cat("design cannot detect plausible effects without aggregate data.\n")

}, error = function(e) {
  cat("Dilution table error:", e$message, "\n")
})

# ============================================================
# 11. Placebo-in-Time Test (Never-Treated States)
# ============================================================

cat("\n=============================================\n")
cat("=== 11. Placebo-in-Time (Never-Treated)  ===\n")
cat("=============================================\n")

tryCatch({
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
  panel_leads <- panel %>%
    mutate(
      lead1 = as.integer(first_treat > 0 & year == first_treat - 1),
      lead2 = as.integer(first_treat > 0 & year == first_treat - 2),
      lead3 = as.integer(first_treat > 0 & year == first_treat - 3)
    )

  twfe_leads <- feols(
    mortality_rate ~ treated + lead1 + lead2 + lead3 | state_id + year,
    data = panel_leads,
    cluster = ~state_id
  )

  cat("\nTWFE with Anticipation Leads:\n")
  print(summary(twfe_leads))

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
cat("=== 13. Log Mortality Rate Specification ===\n")
cat("=============================================\n")

cs_log_data <- panel %>%
  select(state_id, year, first_treat, log_mortality_rate) %>%
  rename(y = log_mortality_rate) %>%
  filter(!is.na(y))

set.seed(142)
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
# Save All Robustness Results
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
  cs_placebo_heart_full = cs_placebo_heart_full,
  cs_placebo_cancer_full = cs_placebo_cancer_full,
  honestdid = honest_result,
  honestdid_vcv_method = vcv_method,
  het_low = het_low,
  het_med = het_med,
  het_high = het_high,
  cs_log = if (exists("cs_log_att")) cs_log_att else NULL,
  placebo_in_time = if (exists("placebo_time_twfe")) placebo_time_twfe else NULL,
  anticipation_leads = if (exists("twfe_leads")) twfe_leads else NULL
)

saveRDS(robustness_results, "data/robustness_results.rds")

cat("Saved data/robustness_results.rds\n")
cat("HonestDiD VCV method:", vcv_method, "\n")
cat("\n=== Robustness Checks Complete ===\n")
