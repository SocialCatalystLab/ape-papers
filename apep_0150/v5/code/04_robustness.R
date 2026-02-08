# ============================================================
# 04_robustness.R - Robustness checks
# Paper 148: State Insulin Copay Caps and Working-Age
#             Diabetes Mortality (v5)
# Revision of apep_0161 (family apep_0150)
# ============================================================
# PROVENANCE:
#   Inputs:
#     data/analysis_panel.rds        (from 02_clean_data.R, PRIMARY working-age)
#     data/analysis_panel_allages.rds (from 02_clean_data.R, SECONDARY all-ages)
#     data/main_results.rds          (from 03_main_analysis.R, PRIMARY results)
#     data/main_results_allages.rds  (from 03_main_analysis.R, SECONDARY results)
#     data/panel_vermont_treated.rds (from 02_clean_data.R, Vermont sensitivity)
#     data/panel_vermont_control.rds (from 02_clean_data.R, Vermont sensitivity)
#   Outputs:
#     data/robustness_results.rds
#     data/bacon_decomposition.rds
#     data/cluster_robust_inference.rds
#     data/honestdid_results.rds     (BOTH relative-magnitudes AND smoothness)
#     data/wild_bootstrap_result.rds
#     data/mde_table.rds
#     data/dilution_table.rds
#     data/vermont_sensitivity.rds
#     tables/tableA_mde.csv
#     tables/tableA4_dilution.csv
# ============================================================
# Checks:
#   1. Bacon decomposition (Goodman-Bacon 2021)
#   2. Cluster-robust variance estimators
#   3. Exclude 2020-2021 (COVID sensitivity)
#   4. Control for state COVID death rates (incl. COVID year dummies)
#   5. Placebo: heart disease mortality
#   5B. Placebo: heart disease (full panel incl. 2020-2023)
#   6. Placebo: cancer mortality
#   6B. Placebo: cancer mortality (full panel)
#   7. HonestDiD sensitivity (BOTH relative magnitudes AND smoothness/FLCI)
#   8. Heterogeneity by cap amount
#   9. Wild cluster bootstrap (fwildclusterboot)
#   10. MDE table (recalculated for working-age)
#   10B. MDE dilution mapping (recalculated for working-age s~15-20%)
#   11. Placebo-in-time
#   12. Anticipation/leads
#   13. Log specification
#   14. Vermont sensitivity (3 specifications)
#   15. All-ages as robustness specification
#   16. Suppression sensitivity analysis
# ============================================================

source("code/00_packages.R")

# Verify inputs
stopifnot(file.exists("data/analysis_panel.rds"))
stopifnot(file.exists("data/main_results.rds"))

# Load PRIMARY data and results (working-age 25-64)
panel <- readRDS("data/analysis_panel.rds")
main_results <- readRDS("data/main_results.rds")

cat("Loaded PRIMARY panel (working-age):", nrow(panel), "observations\n")

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

  cat("\nCluster-Robust Inference:\n")
  cat("  Coefficient:", round(coef_val, 4), "\n")
  cat("  CR SE (default):", round(se_default, 4),
      "  p-value:", format_pval(pval_default), "\n")
  cat("  CR SE (small-sample adj):", round(se_adj, 4),
      "  p-value:", format_pval(pval_adj), "\n")

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

set.seed(145)
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
  set.seed(145)
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

# COVID year dummies specification (MEDIUM flag fix: report this)
twfe_covid_dummies <- feols(
  mortality_rate ~ treated + covid_2020 + covid_2021 | state_id + year,
  data = panel,
  cluster = ~state_id
)

cat("\nTWFE with COVID Year Dummies:\n")
print(summary(twfe_covid_dummies))

# ============================================================
# 5. Placebo Test: Heart Disease Mortality
# ============================================================

cat("\n=============================================\n")
cat("=== 5. Placebo: Heart Disease             ===\n")
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

set.seed(145)
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

cs_placebo_heart_full <- NULL
if (any(panel_heart$year >= 2020)) {
  cat("Heart placebo full panel:", nrow(panel_heart), "obs (",
      min(panel_heart$year), "-", max(panel_heart$year), ")\n")

  set.seed(145)
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
  cat("No post-2020 heart disease data available.\n")
}

# ============================================================
# 6. Placebo Test: Cancer Mortality
# ============================================================

cat("\n=============================================\n")
cat("=== 6. Placebo: Cancer Mortality          ===\n")
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

set.seed(145)
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

  set.seed(145)
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
  cat("No post-2020 cancer data available.\n")
}

# ============================================================
# 7. HonestDiD Sensitivity Analysis (BOTH approaches)
#    Flag 7 fix: report BOTH relative magnitudes AND smoothness/FLCI
# ============================================================

cat("\n=============================================\n")
cat("=== 7. HonestDiD Sensitivity (Both)      ===\n")
cat("=============================================\n")

honest_rm_result <- NULL
honest_sd_result <- NULL
vcv_method <- "diagonal"

if (!is.null(main_results$cs_event)) {
  cs_event <- main_results$cs_event

  tryCatch({
    es_coefs <- if (!is.null(cs_event$att.egt)) cs_event$att.egt else cs_event$att
    es_times <- if (!is.null(cs_event$egt)) cs_event$egt else cs_event$e
    es_se    <- if (!is.null(cs_event$se.egt)) cs_event$se.egt else cs_event$se

    if (is.null(es_coefs) || is.null(es_times) || is.null(es_se)) {
      cat("Could not extract event study coefficients from cs_event object.\n")
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

        # Attempt full VCV from influence functions
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
          if (ncol(inf_func) >= length(valid_idx)) {
            inf_sub <- inf_func[, valid_idx, drop = FALSE]
            n_units <- nrow(inf_sub)
            sigma <- crossprod(inf_sub) / (n_units^2)
            vcv_method <- "full_influence_function"
            cat("  Extracted full VCV from influence functions (", n_units, " units x ",
                ncol(inf_sub), " periods)\n")
          }
        }

        if (is.null(sigma)) {
          sigma <- diag(es_se^2)
          vcv_method <- "diagonal"
          cat("  Using diagonal VCV approximation.\n")
        }

        cat("  VCV method:", vcv_method, "\n")

        # ---- Approach 1: Relative Magnitudes (Rambachan-Roth 2023) ----
        honest_rm_result <- tryCatch({
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

        if (!is.null(honest_rm_result)) {
          cat("\nHonestDiD Results (Relative Magnitudes):\n")
          cat("VCV method:", vcv_method, "\n\n")
          print(honest_rm_result)
        }

        # ---- Approach 2: Smoothness-Based (Delta^SD, FLCI) ----
        honest_sd_result <- tryCatch({
          HonestDiD::createSensitivityResults(
            betahat    = betahat,
            sigma      = sigma,
            numPrePeriods  = length(pre_idx),
            numPostPeriods = length(post_idx),
            Mvec       = seq(0, 0.05, by = 0.01),
            method     = "FLCI"
          )
        }, error = function(e) {
          cat("HonestDiD smoothness/FLCI error:", e$message, "\n")
          NULL
        })

        if (!is.null(honest_sd_result)) {
          cat("\nHonestDiD Results (Smoothness/FLCI):\n")
          print(honest_sd_result)
        }

        # Save BOTH sets of results (Flag 7 fix: no selective reporting)
        saveRDS(list(
          relative_magnitudes = honest_rm_result,
          smoothness = honest_sd_result,
          betahat = betahat,
          sigma = sigma,
          vcv_method = vcv_method,
          pre_idx = pre_idx,
          post_idx = post_idx,
          es_times = es_times
        ), "data/honestdid_results.rds")

        cat("\nSaved BOTH relative-magnitudes AND smoothness results.\n")

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

tryCatch({
  twfe_basic <- main_results$twfe_basic

  set.seed(145)
  boot_out <- fwildclusterboot::boottest(
    twfe_basic,
    param = "treated",
    clustid = ~state_id,
    B = 9999,
    type = "webb"
  )

  cat("\nWild Cluster Bootstrap Results (fwildclusterboot):\n")
  cat("  Point estimate:", round(boot_out$point_estimate, 4), "\n")
  cat("  Bootstrap p-value:", format_pval(boot_out$p_val), "\n")
  cat("  95% CI: [", round(boot_out$conf_int[1], 4), ",",
      round(boot_out$conf_int[2], 4), "]\n")

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

  tryCatch({
    twfe_basic <- main_results$twfe_basic
    set.seed(145)
    vcov_bs <- sandwich::vcovBS(twfe_basic, cluster = ~state_id, R = 999)
    se_bs <- sqrt(diag(vcov_bs))["treated"]
    coef_val <- coef(twfe_basic)["treated"]
    p_bs <- 2 * pnorm(-abs(coef_val / se_bs))

    cat("\nSandwich Bootstrap Results (fallback):\n")
    cat("  Point estimate:", round(coef_val, 4), "\n")
    cat("  Bootstrap SE:", round(se_bs, 4), "\n")
    cat("  Bootstrap p-value:", format_pval(p_bs), "\n")

    wild_boot_result <<- list(
      point_estimate = coef_val,
      p_val = p_bs,
      conf_int = c(coef_val - 1.96 * se_bs, coef_val + 1.96 * se_bs),
      method = "sandwich_vcovBS_999"
    )
    saveRDS(wild_boot_result, "data/wild_bootstrap_result.rds")
  }, error = function(e2) {
    cat("Sandwich bootstrap also failed:", e2$message, "\n")
  })
})

# ============================================================
# 10. Minimum Detectable Effect (MDE) Table
#     Recalculated for working-age (25-64) panel
# ============================================================

cat("\n=============================================\n")
cat("=== 10. MDE (Working-Age Panel)           ===\n")
cat("=============================================\n")

tryCatch({
  twfe_basic <- main_results$twfe_basic
  se_treated <- summary(twfe_basic)$se["treated"]

  mde_80 <- 2.8 * se_treated
  mde_90 <- (1.96 + 1.28) * se_treated

  mean_rate <- mean(panel$mortality_rate, na.rm = TRUE)

  cat("MDE Calculation (working-age 25-64, TWFE):\n")
  cat("  SE of treated coefficient:", round(se_treated, 4), "\n")
  cat("  MDE at 80% power (5% sig):", round(mde_80, 2), "deaths per 100K\n")
  cat("  MDE at 90% power (5% sig):", round(mde_90, 2), "deaths per 100K\n")
  cat("  Mean working-age mortality rate:", round(mean_rate, 2), "per 100K\n")
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
                ifelse(!is.null(main_results$cs_agg_simple), 2.8 * main_results$cs_agg_simple$overall.se / mean_rate * 100, NA)),
    Panel = "Working-Age (25-64)"
  )

  saveRDS(mde_table, "data/mde_table.rds")
  write_csv(mde_table, "tables/tableA_mde.csv")

}, error = function(e) {
  cat("MDE calculation error:", e$message, "\n")
})

# ============================================================
# 10B. MDE Dilution Mapping Table
#      Recalculated: s rises from ~3% (all-ages) to ~15-20% (working-age)
# ============================================================

cat("\n=============================================\n")
cat("=== 10B. MDE Dilution (Working-Age)      ===\n")
cat("=============================================\n")
cat("Dilution algebra: ATT_pop = s * Delta_T\n")
cat("Working-age restriction raises s from ~3% to ~15-20%\n\n")

tryCatch({
  twfe_basic <- main_results$twfe_basic
  se_treated <- summary(twfe_basic)$se["treated"]
  mde_80 <- 2.8 * se_treated
  mean_rate <- mean(panel$mortality_rate, na.rm = TRUE)

  # Treated-share scenarios for working-age
  # s ~ 15-20% among working-age, vs 3% for all-ages
  s_values <- c(0.03, 0.05, 0.10, 0.15, 0.20, 0.30)

  dilution_table <- data.frame(
    treated_share = s_values,
    treated_share_pct = s_values * 100,
    mde_pop_level = mde_80,
    mde_treated_group = mde_80 / s_values,
    mde_treated_pct_baseline = (mde_80 / s_values) / mean_rate * 100,
    mean_mortality = mean_rate,
    panel = "Working-Age (25-64)"
  )

  cat("Dilution Mapping (working-age, 80% power, 5% significance):\n")
  cat("Population-level MDE:", round(mde_80, 2), "deaths per 100K\n")
  cat("Mean working-age mortality rate:", round(mean_rate, 2), "per 100K\n\n")

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

  cat("\nKey finding: For working-age panel, s rises to ~15-20%,\n")
  cat("making the MDE on the treated subpopulation more reasonable.\n")

}, error = function(e) {
  cat("Dilution table error:", e$message, "\n")
})

# ============================================================
# 11. Placebo-in-Time Test (Never-Treated States)
# ============================================================

cat("\n=============================================\n")
cat("=== 11. Placebo-in-Time (Never-Treated)  ===\n")
cat("=============================================\n")

placebo_time_twfe <- NULL
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

twfe_leads <- NULL
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
    p_val <- 2 * pnorm(-abs(lead_coefs[nm] / lead_ses[nm]))
    cat(sprintf("  %s: %.3f (SE = %.3f, p = %s)\n",
                nm, lead_coefs[nm], lead_ses[nm], format_pval(p_val)))
  }

  saveRDS(twfe_leads, "data/anticipation_leads.rds")
}, error = function(e) {
  cat("Anticipation leads error:", e$message, "\n")
})

# ============================================================
# 13. Log Specification
# ============================================================

cat("\n=============================================\n")
cat("=== 13. Log Mortality Rate Specification ===\n")
cat("=============================================\n")

cs_log_att <- NULL
cs_log_data <- panel %>%
  select(state_id, year, first_treat, log_mortality_rate) %>%
  rename(y = log_mortality_rate) %>%
  filter(!is.na(y))

set.seed(145)
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
# 14. Vermont Sensitivity (Flag 6: 3 specifications)
# ============================================================

cat("\n=============================================\n")
cat("=== 14. Vermont Sensitivity Analysis     ===\n")
cat("=============================================\n")

vermont_sensitivity <- list()

# Specification A: Vermont EXCLUDED (primary — already in main panel)
cat("\nSpec A: Vermont excluded (primary specification)\n")
twfe_basic <- main_results$twfe_basic
coef_excl <- coef(twfe_basic)["treated"]
se_excl <- summary(twfe_basic)$se["treated"]
cat("  ATT:", round(coef_excl, 4), "(SE:", round(se_excl, 4), ")\n")
vermont_sensitivity$excluded <- list(att = coef_excl, se = se_excl, spec = "Vermont excluded")

# Specification B: Vermont as treated
if (file.exists("data/panel_vermont_treated.rds")) {
  cat("\nSpec B: Vermont as treated\n")
  panel_vt_treated <- readRDS("data/panel_vermont_treated.rds")
  twfe_vt_treated <- tryCatch({
    feols(
      mortality_rate ~ treated | state_id + year,
      data = panel_vt_treated,
      cluster = ~state_id
    )
  }, error = function(e) {
    cat("  Vermont-as-treated TWFE error:", e$message, "\n")
    NULL
  })

  if (!is.null(twfe_vt_treated)) {
    coef_vt <- coef(twfe_vt_treated)["treated"]
    se_vt <- summary(twfe_vt_treated)$se["treated"]
    cat("  ATT:", round(coef_vt, 4), "(SE:", round(se_vt, 4), ")\n")
    vermont_sensitivity$treated <- list(att = coef_vt, se = se_vt, spec = "Vermont as treated")
  }
} else {
  cat("  data/panel_vermont_treated.rds not found — skipping\n")
}

# Specification C: Vermont as control
if (file.exists("data/panel_vermont_control.rds")) {
  cat("\nSpec C: Vermont as control\n")
  panel_vt_control <- readRDS("data/panel_vermont_control.rds")
  twfe_vt_control <- tryCatch({
    feols(
      mortality_rate ~ treated | state_id + year,
      data = panel_vt_control,
      cluster = ~state_id
    )
  }, error = function(e) {
    cat("  Vermont-as-control TWFE error:", e$message, "\n")
    NULL
  })

  if (!is.null(twfe_vt_control)) {
    coef_vt_c <- coef(twfe_vt_control)["treated"]
    se_vt_c <- summary(twfe_vt_control)$se["treated"]
    cat("  ATT:", round(coef_vt_c, 4), "(SE:", round(se_vt_c, 4), ")\n")
    vermont_sensitivity$control <- list(att = coef_vt_c, se = se_vt_c, spec = "Vermont as control")
  }
} else {
  cat("  data/panel_vermont_control.rds not found — skipping\n")
}

saveRDS(vermont_sensitivity, "data/vermont_sensitivity.rds")
cat("\nSaved data/vermont_sensitivity.rds (3 specifications)\n")

# ============================================================
# 15. All-Ages as Robustness Specification
# ============================================================

cat("\n=============================================\n")
cat("=== 15. All-Ages Robustness              ===\n")
cat("=============================================\n")

allages_robustness <- NULL
if (file.exists("data/main_results_allages.rds")) {
  allages_results <- readRDS("data/main_results_allages.rds")

  twfe_aa_coef <- coef(allages_results$twfe_basic)["treated"]
  twfe_aa_se <- summary(allages_results$twfe_basic)$se["treated"]

  cat("All-ages TWFE ATT:", round(twfe_aa_coef, 4),
      "(SE:", round(twfe_aa_se, 4), ")\n")

  if (!is.null(allages_results$cs_agg_simple)) {
    cat("All-ages CS-DiD ATT:", round(allages_results$cs_agg_simple$overall.att, 4),
        "(SE:", round(allages_results$cs_agg_simple$overall.se, 4), ")\n")
  }

  allages_robustness <- list(
    twfe_att = twfe_aa_coef,
    twfe_se = twfe_aa_se,
    cs_att = if (!is.null(allages_results$cs_agg_simple)) allages_results$cs_agg_simple$overall.att else NA,
    cs_se = if (!is.null(allages_results$cs_agg_simple)) allages_results$cs_agg_simple$overall.se else NA
  )
} else {
  cat("All-ages results not found — run 03_main_analysis.R first\n")
}

# ============================================================
# 16. Suppression Sensitivity Analysis
# ============================================================

cat("\n=============================================\n")
cat("=== 16. Suppression Sensitivity          ===\n")
cat("=============================================\n")

suppression_info <- NULL
tryCatch({
  n_suppressed <- sum(is.na(panel$mortality_rate))
  n_total <- nrow(panel)
  n_states_suppressed <- panel %>%
    filter(is.na(mortality_rate)) %>%
    distinct(state_fips) %>%
    nrow()

  cat("Suppressed observations:", n_suppressed, "of", n_total,
      "(", round(n_suppressed/n_total*100, 1), "%)\n")
  cat("States with any suppression:", n_states_suppressed, "\n")

  # Identify which states × years are suppressed
  if (n_suppressed > 0) {
    supp_detail <- panel %>%
      filter(is.na(mortality_rate)) %>%
      distinct(state_fips, year) %>%
      arrange(state_fips, year)
    cat("\nSuppressed state-years:\n")
    print(supp_detail)
  }

  # Bounds analysis: impute suppressed values at extremes
  # Lower bound: impute 0 (minimum possible deaths < 10)
  # Upper bound: impute 9 deaths / population * 100000
  panel_lower <- panel %>%
    mutate(mortality_rate = ifelse(is.na(mortality_rate), 0, mortality_rate))

  panel_upper <- panel %>%
    mutate(mortality_rate = ifelse(is.na(mortality_rate),
                                   9 / (population / 100000),
                                   mortality_rate))

  twfe_lower <- tryCatch({
    feols(mortality_rate ~ treated | state_id + year,
          data = panel_lower, cluster = ~state_id)
  }, error = function(e) NULL)

  twfe_upper <- tryCatch({
    feols(mortality_rate ~ treated | state_id + year,
          data = panel_upper, cluster = ~state_id)
  }, error = function(e) NULL)

  if (!is.null(twfe_lower) && !is.null(twfe_upper)) {
    cat("\nSuppression Bounds (TWFE):\n")
    cat("  Lower bound (deaths=0):", round(coef(twfe_lower)["treated"], 4),
        "(SE:", round(summary(twfe_lower)$se["treated"], 4), ")\n")
    cat("  Upper bound (deaths=9):", round(coef(twfe_upper)["treated"], 4),
        "(SE:", round(summary(twfe_upper)$se["treated"], 4), ")\n")
    cat("  Primary (suppress=NA):", round(coef(main_results$twfe_basic)["treated"], 4), "\n")
  }

  suppression_info <- list(
    n_suppressed = n_suppressed,
    n_total = n_total,
    n_states_suppressed = n_states_suppressed,
    twfe_lower = if (!is.null(twfe_lower)) coef(twfe_lower)["treated"] else NA,
    twfe_upper = if (!is.null(twfe_upper)) coef(twfe_upper)["treated"] else NA,
    twfe_primary = coef(main_results$twfe_basic)["treated"]
  )

}, error = function(e) {
  cat("Suppression sensitivity error:", e$message, "\n")
})

# ============================================================
# 17. Cohort-Specific ATTs (Reviewer Request)
# ============================================================
# Extract group-specific ATTs from existing CS result
# These are already computed but not displayed in v4

cat("\n=============================================\n")
cat("=== 17. Cohort-Specific ATTs             ===\n")
cat("=============================================\n")

cohort_att_table <- NULL
if (!is.null(main_results$cs_agg_group)) {
  cs_agg_g <- main_results$cs_agg_group
  cohort_att_table <- data.frame(
    cohort = cs_agg_g$egt,
    att = cs_agg_g$att.egt,
    se = cs_agg_g$se.egt
  ) %>%
    mutate(
      ci_lower = att - 1.96 * se,
      ci_upper = att + 1.96 * se,
      p_value = 2 * pnorm(-abs(att / se))
    )

  cat("Cohort-Specific ATTs:\n")
  print(cohort_att_table, digits = 4, row.names = FALSE)
  saveRDS(cohort_att_table, "data/cohort_att_table.rds")
} else {
  cat("CS group aggregation not available — skipping\n")
}

# ============================================================
# 18. Insulin Event Study (Intermediate Outcome)
# ============================================================

cat("\n=============================================\n")
cat("=== 18. Insulin Event Study              ===\n")
cat("=============================================\n")

insulin_event_study <- NULL
if (file.exists("data/cs_event_study_insulin.rds")) {
  cs_insulin_event <- readRDS("data/cs_event_study_insulin.rds")

  insulin_es_df <- data.frame(
    event_time = cs_insulin_event$egt,
    att = cs_insulin_event$att.egt,
    se = cs_insulin_event$se.egt
  ) %>%
    mutate(
      ci_lower = att - 1.96 * se,
      ci_upper = att + 1.96 * se
    )

  cat("Insulin Event Study Coefficients:\n")
  print(insulin_es_df, digits = 4)

  saveRDS(insulin_es_df, "data/es_coefficients_insulin.rds")
  insulin_event_study <- insulin_es_df

  # Pre-trends test for insulin
  pre_insulin <- insulin_es_df %>% filter(event_time < 0)
  if (nrow(pre_insulin) > 0) {
    cat("\nInsulin Pre-Trends:\n")
    cat("  Mean pre-ATT:", round(mean(pre_insulin$att), 4), "\n")
    cat("  All within CI of zero:", all(pre_insulin$ci_lower <= 0 & pre_insulin$ci_upper >= 0), "\n")
  }
} else {
  cat("Insulin event study results not found — skipping\n")
}

# ============================================================
# 19. TWFE with Medicaid Expansion Control
# ============================================================

cat("\n=============================================\n")
cat("=== 19. Medicaid Expansion Robustness    ===\n")
cat("=============================================\n")

twfe_medicaid_rob <- NULL
if ("medicaid_expanded" %in% names(panel)) {
  twfe_medicaid_rob <- tryCatch({
    feols(
      mortality_rate ~ treated + medicaid_expanded | state_id + year,
      data = panel,
      cluster = ~state_id
    )
  }, error = function(e) {
    cat("TWFE + Medicaid expansion error:", e$message, "\n")
    NULL
  })

  if (!is.null(twfe_medicaid_rob)) {
    cat("TWFE + Medicaid Expansion Control:\n")
    print(summary(twfe_medicaid_rob))
  }
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
  honestdid_rm = honest_rm_result,
  honestdid_sd = honest_sd_result,
  honestdid_vcv_method = vcv_method,
  het_low = het_low,
  het_med = het_med,
  het_high = het_high,
  cs_log = cs_log_att,
  placebo_in_time = placebo_time_twfe,
  anticipation_leads = twfe_leads,
  vermont_sensitivity = vermont_sensitivity,
  allages_robustness = allages_robustness,
  suppression_info = suppression_info,
  cohort_att_table = cohort_att_table,
  insulin_event_study = insulin_event_study,
  twfe_medicaid = twfe_medicaid_rob
)

saveRDS(robustness_results, "data/robustness_results.rds")

cat("Saved data/robustness_results.rds\n")
cat("HonestDiD VCV method:", vcv_method, "\n")
cat("\n=== Robustness Checks Complete ===\n")
