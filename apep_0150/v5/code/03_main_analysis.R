# ============================================================
# 03_main_analysis.R - Primary DiD analysis
# Paper 148: State Insulin Copay Caps and Working-Age
#             Diabetes Mortality (v5)
# Revision of apep_0161 (family apep_0150)
# ============================================================
# PROVENANCE:
#   Inputs:
#     data/analysis_panel.rds       (from 02_clean_data.R, PRIMARY working-age 25-64)
#     data/analysis_panel_allages.rds (from 02_clean_data.R, SECONDARY all-ages)
#   Outputs:
#     data/main_results_primary.rds  (working-age results)
#     data/main_results_allages.rds  (all-ages results)
#     data/cs_result.rds             (CS group-time ATT, working-age)
#     data/cs_event_study.rds        (CS dynamic event study, working-age)
#     data/es_coefficients.rds       (event study coefs, working-age)
#     data/cs_agg_group.rds          (CS group ATT, working-age)
#     data/cs_agg_calendar.rds       (CS calendar ATT, working-age)
#     data/sa_result.rds             (Sun-Abraham, working-age)
#     data/cs_result_allages.rds     (CS group-time ATT, all-ages)
#     data/cs_event_study_allages.rds (CS dynamic, all-ages)
#     data/sa_result_allages.rds     (Sun-Abraham, all-ages)
# ============================================================
# Estimators:
#   1. TWFE baseline (fixest)
#   2. Callaway-Sant'Anna (2021) group-time ATT
#   3. CS aggregate ATT (simple)
#   4. CS dynamic event study
#   5. Sun-Abraham (2021) interaction-weighted estimator
# ============================================================

source("code/00_packages.R")

# Verify input files exist
stopifnot(file.exists("data/analysis_panel.rds"))
stopifnot(file.exists("data/analysis_panel_allages.rds"))

# ============================================================
# HELPER: Run full analysis battery on a panel
# ============================================================

run_analysis <- function(panel, panel_label, seed_base = 145, save_suffix = "") {
  cat("\n########################################################\n")
  cat("### Analysis on:", panel_label, "\n")
  cat("########################################################\n")

  cat("Loaded panel:", nrow(panel), "observations\n")
  cat("States:", n_distinct(panel$state_fips), "\n")
  cat("Years:", min(panel$year), "-", max(panel$year), "\n")
  cat("Ever-treated:", n_distinct(panel$state_fips[panel$first_treat > 0]), "\n")
  cat("Never-treated:", n_distinct(panel$state_fips[panel$first_treat == 0]), "\n")

  # ============================================================
  # 1. TWFE Baseline Regressions
  # ============================================================

  cat("\n========================================\n")
  cat("=== 1. Two-Way Fixed Effects (TWFE) ===\n")
  cat("========================================\n")

  # Specification 1: Basic TWFE
  twfe_basic <- feols(
    mortality_rate ~ treated | state_id + year,
    data = panel,
    cluster = ~state_id
  )

  cat("\nSpecification 1: Basic TWFE\n")
  print(summary(twfe_basic))

  # Specification 2: TWFE with COVID controls
  twfe_covid <- feols(
    mortality_rate ~ treated + covid_year + covid_death_rate | state_id + year,
    data = panel,
    cluster = ~state_id
  )

  cat("\nSpecification 2: TWFE + COVID Controls\n")
  print(summary(twfe_covid))

  # Specification 3: TWFE on log outcome
  twfe_log <- feols(
    log_mortality_rate ~ treated | state_id + year,
    data = panel,
    cluster = ~state_id
  )

  cat("\nSpecification 3: TWFE (Log Mortality Rate)\n")
  print(summary(twfe_log))

  # Specification 4: TWFE with state-specific linear trends
  twfe_trends <- feols(
    mortality_rate ~ treated | state_id[time_trend] + year,
    data = panel,
    cluster = ~state_id
  )

  cat("\nSpecification 4: TWFE + State Linear Trends\n")
  print(summary(twfe_trends))

  # Specification 5: TWFE with Medicaid expansion control
  twfe_medicaid <- NULL
  if ("medicaid_expanded" %in% names(panel)) {
    twfe_medicaid <- tryCatch({
      feols(
        mortality_rate ~ treated + medicaid_expanded | state_id + year,
        data = panel,
        cluster = ~state_id
      )
    }, error = function(e) {
      cat("  TWFE + Medicaid expansion error:", e$message, "\n")
      NULL
    })

    if (!is.null(twfe_medicaid)) {
      cat("\nSpecification 5: TWFE + Medicaid Expansion Control\n")
      print(summary(twfe_medicaid))
    }
  }

  # ============================================================
  # 2. Callaway-Sant'Anna (2021) Group-Time ATT
  # ============================================================

  cat("\n=============================================\n")
  cat("=== 2. Callaway-Sant'Anna (2021) DiD     ===\n")
  cat("=============================================\n")

  cs_data <- panel %>%
    select(state_id, year, first_treat, mortality_rate) %>%
    filter(!is.na(mortality_rate))

  cat("\nCS estimation sample:", nrow(cs_data), "obs\n")
  cat("Treatment cohorts:\n")
  print(table(cs_data$first_treat[!duplicated(paste(cs_data$state_id, cs_data$first_treat))]))

  cs_est_method_used <- "dr"
  set.seed(seed_base)
  cs_result <- tryCatch({
    att_gt(
      yname       = "mortality_rate",
      tname       = "year",
      idname      = "state_id",
      gname       = "first_treat",
      data        = as.data.frame(cs_data),
      control_group = "nevertreated",
      est_method  = "dr",
      base_period = "universal",
      allow_unbalanced_panel = TRUE,
      bstrap      = TRUE,
      cband       = TRUE,
      biters      = 1000
    )
  }, error = function(e) {
    cat("WARNING: CS doubly robust ('dr') estimation failed:", e$message, "\n")
    cat("FALLING BACK to 'reg' estimation method.\n")
    cs_est_method_used <<- "reg"
    set.seed(seed_base)
    tryCatch({
      att_gt(
        yname       = "mortality_rate",
        tname       = "year",
        idname      = "state_id",
        gname       = "first_treat",
        data        = as.data.frame(cs_data),
        control_group = "nevertreated",
        est_method  = "reg",
        base_period = "universal",
        allow_unbalanced_panel = TRUE,
        bstrap      = TRUE,
        cband       = TRUE,
        biters      = 1000
      )
    }, error = function(e2) {
      cat("CS reg estimation also failed:", e2$message, "\n")
      NULL
    })
  })

  cat("CS estimation method actually used:", cs_est_method_used, "\n")

  if (!is.null(cs_result)) {
    cat("\n--- Group-Time ATT Estimates ---\n")
    print(summary(cs_result))
    saveRDS(cs_result, paste0("data/cs_result", save_suffix, ".rds"))
  }

  # ============================================================
  # 3. CS Aggregate ATT (Simple)
  # ============================================================

  cat("\n=============================================\n")
  cat("=== 3. Aggregate ATT (Simple)             ===\n")
  cat("=============================================\n")

  cs_agg_simple <- NULL
  cs_agg_group <- NULL
  cs_agg_calendar <- NULL
  if (!is.null(cs_result)) {
    cs_agg_simple <- tryCatch({
      aggte(cs_result, type = "simple")
    }, error = function(e) {
      cat("CS aggregation error:", e$message, "\n")
      NULL
    })

    if (!is.null(cs_agg_simple)) {
      cat("\nOverall ATT:", round(cs_agg_simple$overall.att, 4), "\n")
      cat("SE:         ", round(cs_agg_simple$overall.se, 4), "\n")
      cat("95% CI:     [",
          round(cs_agg_simple$overall.att - 1.96 * cs_agg_simple$overall.se, 4), ",",
          round(cs_agg_simple$overall.att + 1.96 * cs_agg_simple$overall.se, 4), "]\n")
      cat("p-value:    ", format_pval(2 * pnorm(-abs(cs_agg_simple$overall.att / cs_agg_simple$overall.se))), "\n")
    }

    # Group-specific ATT
    cs_agg_group <- tryCatch({
      aggte(cs_result, type = "group")
    }, error = function(e) {
      cat("Group aggregation error:", e$message, "\n")
      NULL
    })

    if (!is.null(cs_agg_group)) {
      cat("\n--- Group-Specific ATT ---\n")
      print(summary(cs_agg_group))
      saveRDS(cs_agg_group, paste0("data/cs_agg_group", save_suffix, ".rds"))
    }

    # Calendar-time ATT
    cs_agg_calendar <- tryCatch({
      aggte(cs_result, type = "calendar")
    }, error = function(e) {
      cat("Calendar aggregation error:", e$message, "\n")
      NULL
    })

    if (!is.null(cs_agg_calendar)) {
      cat("\n--- Calendar-Time ATT ---\n")
      print(summary(cs_agg_calendar))
      saveRDS(cs_agg_calendar, paste0("data/cs_agg_calendar", save_suffix, ".rds"))
    }
  }

  # ============================================================
  # 4. CS Dynamic Event Study
  # ============================================================

  cat("\n=============================================\n")
  cat("=== 4. Dynamic Event Study (CS-DiD)      ===\n")
  cat("=============================================\n")

  cs_event <- NULL
  es_df <- NULL
  if (!is.null(cs_result)) {
    cs_event <- tryCatch({
      aggte(cs_result, type = "dynamic", min_e = -10, max_e = 5)
    }, error = function(e) {
      cat("Dynamic aggregation error:", e$message, "\n")
      tryCatch({
        aggte(cs_result, type = "dynamic")
      }, error = function(e2) {
        cat("Dynamic aggregation (unbounded) also failed:", e2$message, "\n")
        NULL
      })
    })

    if (!is.null(cs_event)) {
      cat("\n--- Dynamic Event Study ATT ---\n")
      print(summary(cs_event))

      es_df <- data.frame(
        event_time = cs_event$egt,
        att = cs_event$att.egt,
        se = cs_event$se.egt
      ) %>%
        mutate(
          ci_lower = att - 1.96 * se,
          ci_upper = att + 1.96 * se
        )

      cat("\nEvent Study Coefficients:\n")
      print(es_df)

      saveRDS(cs_event, paste0("data/cs_event_study", save_suffix, ".rds"))
      saveRDS(es_df, paste0("data/es_coefficients", save_suffix, ".rds"))

      # Pre-trends test: joint significance of pre-treatment coefficients
      pre_coefs <- es_df %>% filter(event_time < 0)
      if (nrow(pre_coefs) > 0) {
        cat("\n--- Pre-Trends Test ---\n")
        cat("Pre-treatment coefficients:\n")
        cat("  Mean ATT:", round(mean(pre_coefs$att), 4), "\n")
        cat("  Max |ATT|:", round(max(abs(pre_coefs$att)), 4), "\n")
        cat("  All within 95% CI of zero:",
            all(pre_coefs$ci_lower <= 0 & pre_coefs$ci_upper >= 0), "\n")

        # Wald test for joint significance
        n_pre <- nrow(pre_coefs)
        wald_stat <- sum((pre_coefs$att / pre_coefs$se)^2)
        wald_pval <- 1 - pchisq(wald_stat, df = n_pre)
        cat("  Wald statistic:", round(wald_stat, 2),
            "(df =", n_pre, ", p =", format_pval(wald_pval), ")\n")
      }
    }
  }

  # ============================================================
  # 5. Sun-Abraham (2021) Interaction-Weighted Estimator
  # ============================================================

  cat("\n=============================================\n")
  cat("=== 5. Sun-Abraham (2021)                 ===\n")
  cat("=============================================\n")

  sa_data <- panel %>%
    mutate(
      cohort_sa = ifelse(first_treat == 0, Inf, first_treat)
    )

  sa_result <- tryCatch({
    feols(
      mortality_rate ~ sunab(cohort_sa, year) | state_id + year,
      data = sa_data,
      cluster = ~state_id
    )
  }, error = function(e) {
    cat("Sun-Abraham estimation error:", e$message, "\n")
    NULL
  })

  if (!is.null(sa_result)) {
    cat("\nSun-Abraham Event Study:\n")
    print(summary(sa_result))

    sa_agg <- tryCatch({
      summary(sa_result, agg = "ATT")
    }, error = function(e) {
      cat("SA aggregation error:", e$message, "\n")
      NULL
    })

    if (!is.null(sa_agg)) {
      cat("\nSun-Abraham Aggregate ATT:\n")
      print(sa_agg)
    }

    saveRDS(sa_result, paste0("data/sa_result", save_suffix, ".rds"))
  }

  # ============================================================
  # 6. Summary Comparison of Estimators
  # ============================================================

  cat("\n=================================================\n")
  cat("=== Summary: Comparison of ATT Estimates      ===\n")
  cat("=================================================\n")

  results_summary <- data.frame(
    Estimator = character(),
    ATT = numeric(),
    SE = numeric(),
    CI_lower = numeric(),
    CI_upper = numeric(),
    stringsAsFactors = FALSE
  )

  # TWFE Basic
  twfe_coef <- coef(twfe_basic)["treated"]
  twfe_se   <- summary(twfe_basic)$se["treated"]
  results_summary <- rbind(results_summary, data.frame(
    Estimator = "TWFE (Basic)",
    ATT = twfe_coef,
    SE = twfe_se,
    CI_lower = twfe_coef - 1.96 * twfe_se,
    CI_upper = twfe_coef + 1.96 * twfe_se
  ))

  # TWFE COVID
  twfe_covid_coef <- coef(twfe_covid)["treated"]
  twfe_covid_se   <- summary(twfe_covid)$se["treated"]
  results_summary <- rbind(results_summary, data.frame(
    Estimator = "TWFE (COVID Controls)",
    ATT = twfe_covid_coef,
    SE = twfe_covid_se,
    CI_lower = twfe_covid_coef - 1.96 * twfe_covid_se,
    CI_upper = twfe_covid_coef + 1.96 * twfe_covid_se
  ))

  # CS-DiD
  if (!is.null(cs_agg_simple)) {
    results_summary <- rbind(results_summary, data.frame(
      Estimator = "Callaway-Sant'Anna",
      ATT = cs_agg_simple$overall.att,
      SE = cs_agg_simple$overall.se,
      CI_lower = cs_agg_simple$overall.att - 1.96 * cs_agg_simple$overall.se,
      CI_upper = cs_agg_simple$overall.att + 1.96 * cs_agg_simple$overall.se
    ))
  }

  # Sun-Abraham
  if (!is.null(sa_result)) {
    sa_agg_coef <- tryCatch({
      sa_agg_res <- summary(sa_result, agg = "ATT")
      data.frame(
        Estimator = "Sun-Abraham",
        ATT = sa_agg_res$coeftable[1, 1],
        SE = sa_agg_res$coeftable[1, 2],
        CI_lower = sa_agg_res$coeftable[1, 1] - 1.96 * sa_agg_res$coeftable[1, 2],
        CI_upper = sa_agg_res$coeftable[1, 1] + 1.96 * sa_agg_res$coeftable[1, 2]
      )
    }, error = function(e) {
      NULL
    })

    if (!is.null(sa_agg_coef)) {
      results_summary <- rbind(results_summary, sa_agg_coef)
    }
  }

  cat("\n")
  print(results_summary, digits = 4, row.names = FALSE)

  # ============================================================
  # 7. Package results
  # ============================================================

  list(
    twfe_basic   = twfe_basic,
    twfe_covid   = twfe_covid,
    twfe_log     = twfe_log,
    twfe_trends  = twfe_trends,
    twfe_medicaid = twfe_medicaid,
    cs_result    = cs_result,
    cs_agg_simple = cs_agg_simple,
    cs_agg_group  = cs_agg_group,
    cs_agg_calendar = cs_agg_calendar,
    cs_event     = cs_event,
    sa_result    = sa_result,
    results_summary = results_summary,
    cs_est_method_used = cs_est_method_used,
    n_states     = n_distinct(panel$state_fips),
    n_treated    = n_distinct(panel$state_fips[panel$first_treat > 0]),
    n_control    = n_distinct(panel$state_fips[panel$first_treat == 0]),
    n_obs        = nrow(panel),
    panel_label  = panel_label
  )
}

# ============================================================
# RUN ON PRIMARY PANEL: Working-Age (25-64)
# ============================================================

panel_primary <- readRDS("data/analysis_panel.rds")
cat("=== PRIMARY PANEL: Working-Age (25-64) ===\n")
cat("Loaded panel:", nrow(panel_primary), "observations\n")

main_results_primary <- run_analysis(
  panel_primary,
  panel_label = "Working-Age (25-64)",
  seed_base = 145,
  save_suffix = ""
)

saveRDS(main_results_primary, "data/main_results_primary.rds")
# Also save as main_results.rds for backward compatibility
saveRDS(main_results_primary, "data/main_results.rds")
cat("\nSaved data/main_results_primary.rds (PRIMARY)\n")

# ============================================================
# RUN ON SECONDARY PANEL: All Ages
# ============================================================

panel_allages <- readRDS("data/analysis_panel_allages.rds")
cat("\n=== SECONDARY PANEL: All Ages ===\n")
cat("Loaded panel:", nrow(panel_allages), "observations\n")

main_results_allages <- run_analysis(
  panel_allages,
  panel_label = "All Ages (Age-Adjusted)",
  seed_base = 1450,
  save_suffix = "_allages"
)

saveRDS(main_results_allages, "data/main_results_allages.rds")
cat("\nSaved data/main_results_allages.rds (SECONDARY)\n")

# ============================================================
# INTERMEDIATE OUTCOME: Medicaid Insulin Prescriptions
# ============================================================
# Medicaid SDUD covers Medicaid beneficiaries, not commercial insurance.
# State copay caps primarily target commercial plans, making this either:
#   (a) Placebo-like test: Medicaid patients unaffected by commercial caps
#   (b) Spillover test: states enacting caps may improve Medicaid access
# Either interpretation is scientifically valuable.

cat("\n=== INTERMEDIATE OUTCOME: Medicaid Insulin Prescriptions ===\n")

insulin_results <- NULL

if ("total_prescriptions" %in% names(panel_primary) &&
    sum(!is.na(panel_primary$total_prescriptions)) > 50) {

  # Restrict to years where insulin data available (2015+)
  panel_insulin <- panel_primary %>%
    filter(!is.na(total_prescriptions) & year >= 2015)

  cat("Insulin prescription sample:", nrow(panel_insulin), "obs\n")
  cat("  States:", n_distinct(panel_insulin$state_fips), "\n")
  cat("  Years:", min(panel_insulin$year), "-", max(panel_insulin$year), "\n")
  cat("  Ever-treated:", n_distinct(panel_insulin$state_fips[panel_insulin$first_treat > 0]), "\n")

  # TWFE on log insulin prescriptions
  twfe_insulin <- tryCatch({
    feols(
      log_insulin_rx ~ treated | state_id + year,
      data = panel_insulin,
      cluster = ~state_id
    )
  }, error = function(e) {
    cat("TWFE insulin error:", e$message, "\n")
    NULL
  })

  if (!is.null(twfe_insulin)) {
    cat("\nTWFE: Log Insulin Prescriptions\n")
    print(summary(twfe_insulin))
  }

  # TWFE on levels
  twfe_insulin_level <- tryCatch({
    feols(
      total_prescriptions ~ treated | state_id + year,
      data = panel_insulin,
      cluster = ~state_id
    )
  }, error = function(e) {
    cat("TWFE insulin (level) error:", e$message, "\n")
    NULL
  })

  if (!is.null(twfe_insulin_level)) {
    cat("\nTWFE: Insulin Prescriptions (Levels)\n")
    print(summary(twfe_insulin_level))
  }

  # CS-DiD on log insulin prescriptions
  cs_insulin_data <- panel_insulin %>%
    select(state_id, year, first_treat, log_insulin_rx) %>%
    rename(y = log_insulin_rx) %>%
    filter(!is.na(y))

  set.seed(148)
  cs_insulin <- tryCatch({
    att_gt(
      yname       = "y",
      tname       = "year",
      idname      = "state_id",
      gname       = "first_treat",
      data        = as.data.frame(cs_insulin_data),
      control_group = "nevertreated",
      est_method  = "reg",
      base_period = "universal",
      allow_unbalanced_panel = TRUE,
      bstrap      = TRUE,
      biters      = 1000
    )
  }, error = function(e) {
    cat("CS insulin error:", e$message, "\n")
    NULL
  })

  cs_insulin_agg <- NULL
  cs_insulin_event <- NULL
  if (!is.null(cs_insulin)) {
    cs_insulin_agg <- tryCatch(aggte(cs_insulin, type = "simple"), error = function(e) NULL)
    cs_insulin_event <- tryCatch(aggte(cs_insulin, type = "dynamic"), error = function(e) NULL)

    if (!is.null(cs_insulin_agg)) {
      cat("\nCS-DiD ATT (log insulin Rx):", round(cs_insulin_agg$overall.att, 4),
          "(SE:", round(cs_insulin_agg$overall.se, 4), ")\n")
      cat("Implied % change:", round((exp(cs_insulin_agg$overall.att) - 1) * 100, 2), "%\n")
    }

    saveRDS(cs_insulin, "data/cs_result_insulin.rds")
    if (!is.null(cs_insulin_event)) {
      saveRDS(cs_insulin_event, "data/cs_event_study_insulin.rds")
    }
  }

  insulin_results <- list(
    twfe_log = twfe_insulin,
    twfe_level = twfe_insulin_level,
    cs_result = cs_insulin,
    cs_agg = cs_insulin_agg,
    cs_event = cs_insulin_event,
    n_obs = nrow(panel_insulin),
    n_states = n_distinct(panel_insulin$state_fips)
  )

  saveRDS(insulin_results, "data/insulin_results.rds")
  cat("Saved data/insulin_results.rds\n")

} else {
  cat("  Insulin prescription data insufficient — skipping\n")
  cat("  (Need >50 non-missing observations)\n")
}

cat("\n=== Main Analysis Complete (Both Panels + Insulin) ===\n")
