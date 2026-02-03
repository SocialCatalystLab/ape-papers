##############################################################################
# 04_robustness.R - Robustness checks
# Revision of apep_0149: Medicaid Postpartum Coverage Extensions
# CHANGES: Post-PHE spec, late-adopter spec, HonestDiD, extended WCB
##############################################################################

source("00_packages.R")

# Set seed for reproducibility of all bootstrap procedures
set.seed(20240137)

cat("=== Robustness Checks ===\n")

# Load data
state_year_pp <- fread(file.path(data_dir, "state_year_postpartum.csv"))
df_postpartum <- fread(file.path(data_dir, "acs_postpartum.csv"))
df_pp_lowinc <- fread(file.path(data_dir, "acs_postpartum_lowinc.csv"))
df_pp_highinc <- fread(file.path(data_dir, "acs_postpartum_highinc.csv"))
df_nonpostpartum <- fread(file.path(data_dir, "acs_nonpostpartum_lowinc.csv"))
results <- readRDS(file.path(data_dir, "main_results.rds"))

# Prepare state_year_pp for CS-DiD
state_year_pp <- state_year_pp %>%
  mutate(
    state_id = as.integer(factor(state_fips)),
    first_treat = as.integer(first_treat)
  ) %>%
  filter(!is.na(medicaid_rate))

# =========================================================
# 1. Placebo Test: High-Income Postpartum Women
# =========================================================

cat("\n--- Placebo: High-Income Postpartum Women ---\n")

state_year_highinc <- df_pp_highinc %>%
  group_by(state_fips, year, first_treat) %>%
  summarise(
    medicaid_rate = weighted.mean(medicaid, weight, na.rm = TRUE),
    uninsured_rate = weighted.mean(uninsured, weight, na.rm = TRUE),
    n_obs = n(),
    total_weight = sum(weight, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    state_id = as.integer(factor(state_fips)),
    first_treat = as.integer(first_treat)
  ) %>%
  filter(!is.na(medicaid_rate))

cs_placebo_highinc <- NULL
cs_agg_placebo_highinc <- NULL
if (n_distinct(state_year_highinc$state_id[state_year_highinc$first_treat == 0]) > 0) {
  cs_placebo_highinc <- tryCatch({
    att_gt(
      yname = "medicaid_rate",
      tname = "year",
      idname = "state_id",
      gname = "first_treat",
      data = as.data.frame(state_year_highinc),
      control_group = "nevertreated",
      weightsname = "total_weight",
      bstrap = TRUE,
      biters = 1000
    )
  }, error = function(e) {
    cat("  CS-DiD failed for high-income placebo:", e$message, "\n")
    NULL
  })

  if (!is.null(cs_placebo_highinc)) {
    cs_agg_placebo_highinc <- aggte(cs_placebo_highinc, type = "simple")
    cat(sprintf("Placebo ATT (Medicaid, High-Income PP): %.4f (SE: %.4f)\n",
                cs_agg_placebo_highinc$overall.att, cs_agg_placebo_highinc$overall.se))
  }
}

# =========================================================
# 2. Placebo Test: Non-Postpartum Low-Income Women
# =========================================================

cat("\n--- Placebo: Non-Postpartum Low-Income Women ---\n")

state_year_nonpp <- df_nonpostpartum %>%
  group_by(state_fips, year, first_treat) %>%
  summarise(
    medicaid_rate = weighted.mean(medicaid, weight, na.rm = TRUE),
    uninsured_rate = weighted.mean(uninsured, weight, na.rm = TRUE),
    n_obs = n(),
    total_weight = sum(weight, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    state_id = as.integer(factor(state_fips)),
    first_treat = as.integer(first_treat)
  ) %>%
  filter(!is.na(medicaid_rate))

cs_placebo_nonpp <- tryCatch({
  att_gt(
    yname = "medicaid_rate",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = as.data.frame(state_year_nonpp),
    control_group = "nevertreated",
    weightsname = "total_weight",
    bstrap = TRUE,
    biters = 1000
  )
}, error = function(e) {
  cat("  CS-DiD failed for non-postpartum placebo:", e$message, "\n")
  NULL
})

cs_agg_placebo_nonpp <- NULL
if (!is.null(cs_placebo_nonpp)) {
  cs_agg_placebo_nonpp <- aggte(cs_placebo_nonpp, type = "simple")
  cat(sprintf("Placebo ATT (Medicaid, Non-PP Low-Income): %.4f (SE: %.4f)\n",
              cs_agg_placebo_nonpp$overall.att, cs_agg_placebo_nonpp$overall.se))
}

# =========================================================
# 3. Excluding PHE Period (original spec, now broader)
# =========================================================

cat("\n--- Excluding PHE Period (2020-2022) ---\n")

state_year_no_phe <- state_year_pp %>%
  filter(year < 2020 | year > 2022)

cs_no_phe <- tryCatch({
  att_gt(
    yname = "medicaid_rate",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = as.data.frame(state_year_no_phe),
    control_group = "nevertreated",
    weightsname = "total_weight",
    bstrap = TRUE,
    biters = 1000
  )
}, error = function(e) {
  cat("  CS-DiD failed for no-PHE sample:", e$message, "\n")
  NULL
})

cs_agg_no_phe <- NULL
cs_dyn_no_phe <- NULL
if (!is.null(cs_no_phe)) {
  cs_agg_no_phe <- aggte(cs_no_phe, type = "simple")
  cat(sprintf("ATT (Medicaid, excl. PHE): %.4f (SE: %.4f)\n",
              cs_agg_no_phe$overall.att, cs_agg_no_phe$overall.se))
  cs_dyn_no_phe <- tryCatch(
    aggte(cs_no_phe, type = "dynamic", min_e = -4, max_e = 3),
    error = function(e) NULL
  )
}

# =========================================================
# 4. NEW: Post-PHE Specification (2017-2019 + 2023-2024 only)
# =========================================================

cat("\n--- NEW: Post-PHE Specification (2017-2019 + 2023-2024 only) ---\n")
cat("This is the cleanest identification: pre-period before PHE, post-period after PHE\n")

state_year_post_phe <- state_year_pp %>%
  filter(year <= 2019 | year >= 2023)

cs_post_phe <- tryCatch({
  att_gt(
    yname = "medicaid_rate",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = as.data.frame(state_year_post_phe),
    control_group = "nevertreated",
    weightsname = "total_weight",
    bstrap = TRUE,
    cband = TRUE,
    biters = 1000
  )
}, error = function(e) {
  cat("  CS-DiD failed for post-PHE spec:", e$message, "\n")
  NULL
})

cs_agg_post_phe <- NULL
cs_dyn_post_phe <- NULL
if (!is.null(cs_post_phe)) {
  cs_agg_post_phe <- aggte(cs_post_phe, type = "simple")
  cat(sprintf("Post-PHE ATT (Medicaid): %.4f (SE: %.4f)\n",
              cs_agg_post_phe$overall.att, cs_agg_post_phe$overall.se))
  cs_dyn_post_phe <- tryCatch(
    aggte(cs_post_phe, type = "dynamic", min_e = -4, max_e = 3),
    error = function(e) NULL
  )
}

# Post-PHE for uninsured
cs_post_phe_unins <- tryCatch({
  att_gt(
    yname = "uninsured_rate",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = as.data.frame(state_year_post_phe),
    control_group = "nevertreated",
    weightsname = "total_weight",
    bstrap = TRUE,
    biters = 1000
  )
}, error = function(e) NULL)

cs_agg_post_phe_unins <- NULL
if (!is.null(cs_post_phe_unins)) {
  cs_agg_post_phe_unins <- aggte(cs_post_phe_unins, type = "simple")
  cat(sprintf("Post-PHE ATT (Uninsured): %.4f (SE: %.4f)\n",
              cs_agg_post_phe_unins$overall.att, cs_agg_post_phe_unins$overall.se))
}

# Post-PHE for employer (placebo check)
cs_post_phe_emp <- tryCatch({
  att_gt(
    yname = "employer_rate",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = as.data.frame(state_year_post_phe),
    control_group = "nevertreated",
    weightsname = "total_weight",
    bstrap = TRUE,
    biters = 1000
  )
}, error = function(e) NULL)

cs_agg_post_phe_emp <- NULL
if (!is.null(cs_post_phe_emp)) {
  cs_agg_post_phe_emp <- aggte(cs_post_phe_emp, type = "simple")
  cat(sprintf("Post-PHE ATT (Employer, placebo): %.4f (SE: %.4f)\n",
              cs_agg_post_phe_emp$overall.att, cs_agg_post_phe_emp$overall.se))
}

# =========================================================
# 5. NEW: Late-Adopter Specification
# =========================================================

cat("\n--- NEW: Late-Adopter Specification ---\n")
cat("Only 2024 adopters (AK, NE, TX, UT, NV) vs AR/WI/ID/IA controls\n")
cat("Using 2017-2019 + 2023-2024, cleanest post-PHE identification\n")

# 2024 adopters: AK(2), NE(31), TX(48), UT(49), NV(32)
# Controls: AR(5), WI(55), ID(16), IA(19)
late_adopter_fips <- c(2, 31, 48, 49, 32)
control_fips <- c(5, 55, 16, 19)

state_year_late <- state_year_pp %>%
  filter(state_fips %in% c(late_adopter_fips, control_fips)) %>%
  filter(year <= 2019 | year >= 2023) %>%
  mutate(
    state_id = as.integer(factor(state_fips)),
    first_treat = as.integer(first_treat)
  )

cat(sprintf("Late-adopter sample: %d state-years, %d states\n",
            nrow(state_year_late), n_distinct(state_year_late$state_fips)))

cs_late_adopter <- tryCatch({
  att_gt(
    yname = "medicaid_rate",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = as.data.frame(state_year_late),
    control_group = "nevertreated",
    weightsname = "total_weight",
    bstrap = TRUE,
    biters = 1000
  )
}, error = function(e) {
  cat("  CS-DiD failed for late-adopter spec:", e$message, "\n")
  NULL
})

cs_agg_late_adopter <- NULL
if (!is.null(cs_late_adopter)) {
  cs_agg_late_adopter <- aggte(cs_late_adopter, type = "simple")
  cat(sprintf("Late-Adopter ATT (Medicaid): %.4f (SE: %.4f)\n",
              cs_agg_late_adopter$overall.att, cs_agg_late_adopter$overall.se))
}

# Fallback: TWFE for late-adopter if CS-DiD fails
twfe_late_adopter <- NULL
if (is.null(cs_agg_late_adopter)) {
  cat("  Falling back to TWFE for late-adopter spec\n")
  twfe_late_adopter <- tryCatch({
    feols(
      medicaid_rate ~ treated | state_fips + year,
      data = state_year_late,
      weights = ~total_weight,
      cluster = ~state_fips
    )
  }, error = function(e) {
    cat("  TWFE late-adopter also failed:", e$message, "\n")
    NULL
  })
  if (!is.null(twfe_late_adopter)) {
    cat(sprintf("Late-Adopter TWFE (Medicaid): %.4f (SE: %.4f)\n",
                coef(twfe_late_adopter)["treated"], se(twfe_late_adopter)["treated"]))
  }
}

# =========================================================
# 6. TWFE with controls (individual level)
# =========================================================

cat("\n--- TWFE with Individual Controls ---\n")

twfe_controls <- feols(
  medicaid ~ treated + age + I(age^2) + married + factor(educ) + factor(race_eth)
  | state_fips + year,
  data = df_postpartum,
  weights = ~weight,
  cluster = ~state_fips
)

cat("TWFE with controls:\n")
summary(twfe_controls)

# =========================================================
# 7. Goodman-Bacon Decomposition
# =========================================================

cat("\n--- Goodman-Bacon Decomposition ---\n")

balanced_panel <- state_year_pp %>%
  group_by(state_id) %>%
  filter(n() == max(state_year_pp %>% count(state_id) %>% pull(n))) %>%
  ungroup()

bacon_result <- NULL
if (requireNamespace("bacondecomp", quietly = TRUE)) {
  library(bacondecomp)
  bacon_result <- tryCatch({
    bacon(medicaid_rate ~ treated,
          data = as.data.frame(balanced_panel),
          id_var = "state_id",
          time_var = "year")
  }, error = function(e) {
    cat("  Bacon decomposition failed:", e$message, "\n")
    NULL
  })

  if (!is.null(bacon_result)) {
    cat("\nBacon Decomposition:\n")
    print(bacon_result %>%
            group_by(type) %>%
            summarise(
              n_comparisons = n(),
              mean_estimate = weighted.mean(estimate, weight),
              total_weight = sum(weight)
            ))
  }
}

# =========================================================
# 8. Medicaid Expansion Heterogeneity
# =========================================================

cat("\n--- Medicaid Expansion Heterogeneity ---\n")

expansion_states <- c(2, 4, 6, 8, 9, 10, 11, 15, 17, 18, 19, 20, 21, 22, 23,
                      24, 25, 26, 27, 29, 30, 31, 32, 33, 34, 35, 36, 38, 39,
                      40, 41, 42, 44, 46, 49, 50, 51, 53, 54)

state_year_pp <- state_year_pp %>%
  mutate(expansion = as.integer(state_fips %in% expansion_states))

twfe_expansion <- feols(
  medicaid_rate ~ treated * expansion | state_fips + year,
  data = state_year_pp,
  weights = ~total_weight,
  cluster = ~state_fips
)

cat("TWFE with Medicaid Expansion Interaction:\n")
summary(twfe_expansion)

# =========================================================
# 9. Wild Cluster Bootstrap (extended to all key specs)
# =========================================================

cat("\n--- Wild Cluster Bootstrap (Extended) ---\n")

wcb_results <- list()

if (requireNamespace("fwildclusterboot", quietly = TRUE)) {
  library(fwildclusterboot)

  # WCB for TWFE baseline
  twfe_base <- feols(
    medicaid_rate ~ treated | state_fips + year,
    data = state_year_pp,
    weights = ~total_weight,
    cluster = ~state_fips
  )

  wcb_results$twfe <- tryCatch({
    boottest(twfe_base,
             param = "treated",
             clustid = "state_fips",
             B = 9999,
             type = "rademacher")
  }, error = function(e) {
    cat("  WCB (TWFE) failed:", e$message, "\n")
    NULL
  })

  if (!is.null(wcb_results$twfe)) {
    cat("Wild Cluster Bootstrap p-value (TWFE):\n")
    print(summary(wcb_results$twfe))
  }

  # WCB for DDD
  ddd_data_for_wcb <- bind_rows(
    df_pp_lowinc %>%
      select(state_fips, year, treated, medicaid, weight) %>%
      mutate(postpartum_ind = 1L),
    df_nonpostpartum %>%
      select(state_fips, year, treated, medicaid, weight) %>%
      mutate(postpartum_ind = 0L)
  ) %>%
  mutate(treated_pp = treated * postpartum_ind)

  ddd_for_wcb <- feols(
    medicaid ~ treated_pp | state_fips^postpartum_ind + year^postpartum_ind,
    data = ddd_data_for_wcb,
    weights = ~weight,
    cluster = ~state_fips
  )

  wcb_results$ddd <- tryCatch({
    boottest(ddd_for_wcb,
             param = "treated_pp",
             clustid = "state_fips",
             B = 9999,
             type = "rademacher")
  }, error = function(e) {
    cat("  WCB (DDD) failed:", e$message, "\n")
    NULL
  })

  if (!is.null(wcb_results$ddd)) {
    cat("\nWild Cluster Bootstrap p-value (DDD):\n")
    print(summary(wcb_results$ddd))
  }

  # WCB for post-PHE TWFE
  state_year_post_phe_wcb <- state_year_pp %>%
    filter(year <= 2019 | year >= 2023)

  twfe_post_phe <- feols(
    medicaid_rate ~ treated | state_fips + year,
    data = state_year_post_phe_wcb,
    weights = ~total_weight,
    cluster = ~state_fips
  )

  wcb_results$post_phe <- tryCatch({
    boottest(twfe_post_phe,
             param = "treated",
             clustid = "state_fips",
             B = 9999,
             type = "rademacher")
  }, error = function(e) {
    cat("  WCB (Post-PHE) failed:", e$message, "\n")
    NULL
  })

  if (!is.null(wcb_results$post_phe)) {
    cat("\nWild Cluster Bootstrap p-value (Post-PHE):\n")
    print(summary(wcb_results$post_phe))
  }
} else {
  cat("  fwildclusterboot not installed, skipping WCB\n")
}

# =========================================================
# 10. NEW: HonestDiD Sensitivity Analysis (Rambachan-Roth)
# =========================================================

cat("\n--- NEW: HonestDiD Sensitivity (Rambachan-Roth) ---\n")

honest_did_results <- NULL

# Use the main CS-DiD event study for HonestDiD
# Extract from CS-DiD dynamic aggregation (more reliable than Sun-Abraham for this)
tryCatch({
  # Use the CS-DiD dynamic estimates from the main results
  cs_dyn <- results$cs_dyn$medicaid

  if (!is.null(cs_dyn)) {
    es_data <- data.frame(
      e = cs_dyn$egt,
      att = cs_dyn$att.egt,
      se = cs_dyn$se.egt
    )

    # Split into pre and post
    pre_data <- es_data %>% filter(e < 0)
    post_data <- es_data %>% filter(e >= 0)

    numPre <- nrow(pre_data)
    numPost <- nrow(post_data)

    cat(sprintf("  HonestDiD: %d pre-periods, %d post-periods\n", numPre, numPost))

    if (numPre >= 1 && numPost >= 1) {
      # Construct betahat (pre then post) and diagonal sigma
      betahat <- c(pre_data$att, post_data$att)
      # Use diagonal vcov from SEs (conservative approximation)
      sigma <- diag(c(pre_data$se, post_data$se)^2)

      Mbar_grid <- c(0.5, 1, 2)

      honest_results_list <- list()
      for (Mbar in Mbar_grid) {
        tryCatch({
          hd_result <- HonestDiD::createSensitivityResults_relativeMagnitudes(
            betahat = betahat,
            sigma = sigma,
            numPrePeriods = numPre,
            numPostPeriods = numPost,
            Mbarvec = Mbar,
            alpha = 0.05
          )
          honest_results_list[[as.character(Mbar)]] <- hd_result
          cat(sprintf("  HonestDiD (Mbar=%.1f): [%.4f, %.4f]\n",
                      Mbar, hd_result$lb[1], hd_result$ub[1]))
        }, error = function(e) {
          cat(sprintf("  HonestDiD (Mbar=%.1f) failed: %s\n", Mbar, e$message))
        })
      }
      honest_did_results <- honest_results_list
    } else {
      cat("  Not enough pre/post periods for HonestDiD\n")
    }
  } else {
    cat("  No CS-DiD dynamic results available for HonestDiD\n")
  }
}, error = function(e) {
  cat("  HonestDiD setup failed:", e$message, "\n")
})

# =========================================================
# 11. NEW: Post-PHE Heterogeneity
# =========================================================

cat("\n--- NEW: Post-PHE Heterogeneity ---\n")

# By cohort timing
cat("  By adoption cohort:\n")
cohort_het <- tryCatch({
  aggte(results$cs$medicaid, type = "group")
}, error = function(e) {
  cat("  Cohort aggregation failed:", e$message, "\n")
  NULL
})
if (!is.null(cohort_het)) {
  summary(cohort_het)
}

# By Medicaid expansion status (post-PHE only)
df_pp_post_phe <- df_pp_lowinc %>%
  filter(year <= 2019 | year >= 2023) %>%
  mutate(expansion = as.integer(state_fips %in% expansion_states))

twfe_expansion_post_phe <- tryCatch({
  feols(
    medicaid ~ treated * expansion | state_fips + year,
    data = df_pp_post_phe,
    weights = ~weight,
    cluster = ~state_fips
  )
}, error = function(e) {
  cat("  Post-PHE expansion heterogeneity failed:", e$message, "\n")
  NULL
})

if (!is.null(twfe_expansion_post_phe)) {
  cat("Post-PHE Expansion Heterogeneity:\n")
  summary(twfe_expansion_post_phe)
}

# By race/ethnicity (post-PHE)
race_het_results <- list()
for (race in c("White NH", "Black NH", "Hispanic")) {
  race_result <- tryCatch({
    feols(
      medicaid ~ treated | state_fips + year,
      data = df_pp_post_phe %>% filter(race_eth == race),
      weights = ~weight,
      cluster = ~state_fips
    )
  }, error = function(e) NULL)

  if (!is.null(race_result)) {
    race_het_results[[race]] <- race_result
    cat(sprintf("  %s: %.4f (SE: %.4f)\n", race,
                coef(race_result)["treated"], se(race_result)["treated"]))
  }
}

# =========================================================
# 12. NEW: Leave-One-Out Control State Analysis
# =========================================================

cat("\n--- Leave-One-Out Control State Analysis ---\n")

control_states <- c(5, 55, 16, 19)  # AR, WI, ID, IA
control_names <- c("AR", "WI", "ID", "IA")

loo_results <- list()
for (i in seq_along(control_states)) {
  drop_state <- control_states[i]
  drop_name <- control_names[i]

  state_year_loo <- state_year_pp %>%
    filter(state_fips != drop_state)

  cs_loo <- tryCatch({
    att_gt(
      yname = "medicaid_rate",
      tname = "year",
      idname = "state_id",
      gname = "first_treat",
      data = as.data.frame(state_year_loo %>%
        mutate(state_id = as.integer(factor(state_fips)))),
      control_group = "nevertreated",
      weightsname = "total_weight",
      bstrap = TRUE,
      biters = 1000
    )
  }, error = function(e) {
    cat(sprintf("  LOO (drop %s) CS-DiD failed: %s\n", drop_name, e$message))
    NULL
  })

  if (!is.null(cs_loo)) {
    cs_agg_loo <- aggte(cs_loo, type = "simple")
    loo_results[[drop_name]] <- list(
      att = cs_agg_loo$overall.att,
      se = cs_agg_loo$overall.se
    )
    cat(sprintf("  Drop %s: ATT = %.4f (SE = %.4f)\n",
                drop_name, cs_agg_loo$overall.att, cs_agg_loo$overall.se))
  }
}

# =========================================================
# 13. NEW: Minimum Detectable Effect (MDE) Calculation
# =========================================================

cat("\n--- Minimum Detectable Effect (MDE) ---\n")

# Use the main CS-DiD SE to compute MDE
# MDE = 2.8 * SE (for 80% power, 5% significance, two-sided)
main_se <- results$cs_agg$medicaid$overall.se
mde_80 <- 2.8 * main_se
cat(sprintf("Main CS-DiD SE (Medicaid): %.4f\n", main_se))
cat(sprintf("MDE at 80%% power (two-sided 5%%): %.4f (%.1f pp)\n",
            mde_80, mde_80 * 100))
cat(sprintf("For context: expected effect was 5-15 pp among all PP women\n"))
cat(sprintf("MDE/Expected midpoint ratio: %.1f%%\n", (mde_80 / 0.10) * 100))

# =========================================================
# 14. Save robustness results
# =========================================================

robustness_results <- list(
  placebo_highinc = cs_agg_placebo_highinc,
  placebo_nonpp = cs_agg_placebo_nonpp,
  no_phe = cs_agg_no_phe,
  no_phe_dyn = cs_dyn_no_phe,
  post_phe = cs_agg_post_phe,
  post_phe_dyn = cs_dyn_post_phe,
  post_phe_unins = cs_agg_post_phe_unins,
  post_phe_emp = cs_agg_post_phe_emp,
  late_adopter = cs_agg_late_adopter,
  late_adopter_twfe = if (exists("twfe_late_adopter")) twfe_late_adopter else NULL,
  twfe_controls = twfe_controls,
  twfe_expansion = twfe_expansion,
  twfe_expansion_post_phe = twfe_expansion_post_phe,
  bacon = bacon_result,
  wcb = wcb_results,
  honest_did = honest_did_results,
  cohort_het = cohort_het,
  race_het = race_het_results,
  loo = loo_results,
  mde = mde_80
)

saveRDS(robustness_results, file.path(data_dir, "robustness_results.rds"))

cat("\n=== Robustness checks complete ===\n")
