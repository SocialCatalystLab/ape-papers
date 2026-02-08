##############################################################################
# 04_robustness.R - Robustness checks
# Revision of apep_0153: Medicaid Postpartum Coverage Extensions (v3)
# CHANGES: Added permutation inference, 2024-only post-period, attenuation
#          simulation, expanded HonestDiD with full M-bar grid
##############################################################################

source("00_packages.R")

# Set seed for reproducibility of all bootstrap/permutation procedures
set.seed(20240153)

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
# 3. Excluding PHE Period (2020-2022)
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
# 4. Post-PHE Specification (2017-2019 + 2023-2024 only)
# =========================================================

cat("\n--- Post-PHE Specification (2017-2019 + 2023-2024 only) ---\n")

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
# 4b. NEW: 2024-Only Post-Period (exclude mixed 2023)
# =========================================================

cat("\n--- NEW: 2024-Only Post-Period (2017-2019 + 2024 only) ---\n")
cat("This excludes the mixed 2023 year when PHE ended mid-year\n")

state_year_2024only <- state_year_pp %>%
  filter(year <= 2019 | year >= 2024)

cs_2024only <- tryCatch({
  att_gt(
    yname = "medicaid_rate",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = as.data.frame(state_year_2024only),
    control_group = "nevertreated",
    weightsname = "total_weight",
    bstrap = TRUE,
    cband = TRUE,
    biters = 1000
  )
}, error = function(e) {
  cat("  CS-DiD failed for 2024-only spec:", e$message, "\n")
  NULL
})

cs_agg_2024only <- NULL
if (!is.null(cs_2024only)) {
  cs_agg_2024only <- tryCatch({
    aggte(cs_2024only, type = "simple")
  }, error = function(e) {
    cat("  CS-DiD aggregation failed for 2024-only:", e$message, "\n")
    NULL
  })
  if (!is.null(cs_agg_2024only)) {
    cat(sprintf("2024-Only ATT (Medicaid): %.4f (SE: %.4f)\n",
                cs_agg_2024only$overall.att, cs_agg_2024only$overall.se))
  }
}

# Fallback to TWFE if CS-DiD aggregation fails (common with single post-period)
twfe_2024only <- NULL
if (is.null(cs_agg_2024only)) {
  cat("  Falling back to TWFE for 2024-only spec\n")
  twfe_2024only <- tryCatch({
    feols(
      medicaid_rate ~ treated | state_fips + year,
      data = state_year_2024only,
      weights = ~total_weight,
      cluster = ~state_fips
    )
  }, error = function(e) {
    cat("  TWFE 2024-only also failed:", e$message, "\n")
    NULL
  })
  if (!is.null(twfe_2024only)) {
    cat(sprintf("2024-Only TWFE ATT (Medicaid): %.4f (SE: %.4f)\n",
                coef(twfe_2024only)["treated"], se(twfe_2024only)["treated"]))
  }
}

# 2024-only uninsured
cs_2024only_unins <- tryCatch({
  att_gt(
    yname = "uninsured_rate",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = as.data.frame(state_year_2024only),
    control_group = "nevertreated",
    weightsname = "total_weight",
    bstrap = TRUE,
    biters = 1000
  )
}, error = function(e) NULL)

cs_agg_2024only_unins <- NULL
if (!is.null(cs_2024only_unins)) {
  cs_agg_2024only_unins <- tryCatch({
    aggte(cs_2024only_unins, type = "simple")
  }, error = function(e) NULL)
  if (!is.null(cs_agg_2024only_unins)) {
    cat(sprintf("2024-Only ATT (Uninsured): %.4f (SE: %.4f)\n",
                cs_agg_2024only_unins$overall.att, cs_agg_2024only_unins$overall.se))
  }
}

# =========================================================
# 5. Late-Adopter Specification
# =========================================================

cat("\n--- Late-Adopter Specification ---\n")

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
# 10. HonestDiD Sensitivity Analysis (expanded M-bar grid)
# =========================================================

cat("\n--- HonestDiD Sensitivity (Rambachan-Roth, expanded grid) ---\n")

honest_did_results <- NULL

tryCatch({
  cs_dyn <- results$cs_dyn$medicaid

  if (!is.null(cs_dyn)) {
    es_data <- data.frame(
      e = cs_dyn$egt,
      att = cs_dyn$att.egt,
      se = cs_dyn$se.egt
    )

    pre_data <- es_data %>% filter(e < 0)
    post_data <- es_data %>% filter(e >= 0)

    numPre <- nrow(pre_data)
    numPost <- nrow(post_data)

    cat(sprintf("  HonestDiD: %d pre-periods, %d post-periods\n", numPre, numPost))

    if (numPre >= 1 && numPost >= 1) {
      betahat <- c(pre_data$att, post_data$att)
      sigma <- diag(c(pre_data$se, post_data$se)^2)

      # Expanded M-bar grid for sensitivity figure
      Mbar_grid <- c(0, 0.5, 1, 1.5, 2)

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
    }
  }
}, error = function(e) {
  cat("  HonestDiD setup failed:", e$message, "\n")
})

# =========================================================
# 11. Post-PHE Heterogeneity
# =========================================================

cat("\n--- Post-PHE Heterogeneity ---\n")

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
# 12. Leave-One-Out Control State Analysis
# =========================================================

cat("\n--- Leave-One-Out Control State Analysis ---\n")

control_states <- c(5, 55, 16, 19)
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
# 13. MDE Calculation
# =========================================================

cat("\n--- Minimum Detectable Effect (MDE) ---\n")

main_se <- results$cs_agg$medicaid$overall.se
mde_80 <- 2.8 * main_se
cat(sprintf("Main CS-DiD SE (Medicaid): %.4f\n", main_se))
cat(sprintf("MDE at 80%% power (two-sided 5%%): %.4f (%.1f pp)\n",
            mde_80, mde_80 * 100))

# =========================================================
# 14. NEW: Permutation / Randomization Inference
# =========================================================

cat("\n--- NEW: Permutation / Randomization Inference ---\n")
cat("Randomly reassigning adoption years to states (500 permutations)\n")

set.seed(20240153)

# Get the actual adoption years (including 0 for never-treated)
actual_treats <- state_year_pp %>%
  distinct(state_id, first_treat) %>%
  arrange(state_id)

actual_att <- results$cs_agg$medicaid$overall.att
cat(sprintf("Actual CS-DiD ATT: %.4f\n", actual_att))

# Permutation: shuffle adoption years across states
n_perm <- 500
perm_atts <- numeric(n_perm)

# Get the distribution of adoption years to maintain cohort sizes
adopt_years_vec <- actual_treats$first_treat

for (p in seq_len(n_perm)) {
  if (p %% 50 == 0) cat(sprintf("  Permutation %d/%d\n", p, n_perm))

  # Shuffle adoption years across states
  shuffled_treats <- sample(adopt_years_vec)

  # Create permuted panel
  perm_panel <- state_year_pp %>%
    left_join(
      data.frame(state_id = actual_treats$state_id, perm_treat = shuffled_treats),
      by = "state_id"
    ) %>%
    mutate(
      perm_treated = as.integer(perm_treat > 0 & year >= perm_treat)
    )

  # Run TWFE on permuted data (faster than CS-DiD for permutation inference)
  perm_fit <- tryCatch({
    feols(
      medicaid_rate ~ perm_treated | state_fips + year,
      data = perm_panel,
      weights = ~total_weight,
      cluster = ~state_fips
    )
  }, error = function(e) NULL)

  if (!is.null(perm_fit)) {
    perm_atts[p] <- coef(perm_fit)["perm_treated"]
  } else {
    perm_atts[p] <- NA
  }
}

# Compute permutation p-value (two-sided)
perm_atts_clean <- perm_atts[!is.na(perm_atts)]

# Use the TWFE coefficient for fair comparison
twfe_actual_att <- coef(results$twfe$medicaid)["treated"]
perm_pval <- mean(abs(perm_atts_clean) >= abs(twfe_actual_att))

cat(sprintf("\nPermutation results (N = %d successful permutations):\n", length(perm_atts_clean)))
cat(sprintf("  Actual TWFE ATT: %.4f\n", twfe_actual_att))
cat(sprintf("  Permutation mean: %.4f\n", mean(perm_atts_clean)))
cat(sprintf("  Permutation SD: %.4f\n", sd(perm_atts_clean)))
cat(sprintf("  Permutation p-value (two-sided): %.3f\n", perm_pval))

# Save permutation distribution for figure
saveRDS(perm_atts_clean, file.path(data_dir, "permutation_distribution.rds"))

# =========================================================
# 15. NEW: Attenuation Bias Quantification
# =========================================================

cat("\n--- NEW: Attenuation Bias Quantification ---\n")
cat("Under uniform birth-month distribution and July 1 coding rule\n")

# The ACS FER variable identifies women who gave birth in past 12 months
# but doesn't include birth month. A state coded as "treated" in survey year t
# if adoption effective by July 1 of year t.
#
# For a woman surveyed in year t who gave birth in month m of year t:
#   - She is postpartum from month m to month m+12
#   - If extension effective July 1, she benefits only if birth month m
#     means she would lose coverage (>60 days) while extension is active
#
# Under uniform birth-month distribution (12 months equally likely):
# - A woman surveyed at random time in year t gave birth 1-12 months ago
# - She was postpartum for 60 days after birth, then "at risk"
# - If extension effective from month e onward, fraction fully exposed:
#   women who gave birth >2 months before effective date AND <12 months before survey

# Simple calculation:
# If extension effective July 1 (month 7) of year t:
# Women surveyed in year t who gave birth in past 12 months:
#   Birth months range from (survey_month - 12) to (survey_month - 1)
# For annual ACS (uniform survey month):
#   Average months of exposure to extension = fraction of year extension active
#   For July 1 start: 6/12 = 0.5 of year
# But the 60-day pregnancy coverage means first 2 months are covered anyway
# So relevant window is months 3-12 postpartum (10 months)
# Under July 1 adoption:
#   Women who gave birth Jan-Apr of year t: fully exposed (>2 months post birth by July 1)
#   Women who gave birth May-Jun: partially exposed
#   Women who gave birth Jul-Dec of previous year: fully exposed
# Approximate exposure fraction accounting for ACS timing and 60-day cliff:

# More precise calculation:
# For each month of survey, for each month of birth, compute whether
# the woman would have lost coverage under 60-day rule but retained it under extension

months <- 1:12  # survey months
birth_months_ago <- 1:12  # months since birth at time of survey

# For a state adopting in January of the survey year (simplest case):
# Extension active all 12 months. But 60-day cliff means months 1-2 postpartum
# are covered anyway. So the extension matters for months 3-12 postpartum.
# Under uniform distribution of birth timing within the year:
# All 12 birth-month-ago values equally likely
# Extension helps women at months 3-12 (10 of 12 months)
# But we also need to consider when in the year the extension started

# Back-of-envelope: for a July 1 effective date
# Expected fraction of FER=1 women fully exposed to extension benefit:
# = fraction whose 60-day cliff falls after July 1
# Under uniform birth timing over 12 months and uniform survey timing:

n_sim <- 100000
set.seed(42)
# Draw random survey month (1-12) and random months since birth (1-12)
sim_survey_month <- sample(1:12, n_sim, replace = TRUE)
sim_birth_month_ago <- sample(1:12, n_sim, replace = TRUE)

# Birth month in calendar
sim_birth_month <- (sim_survey_month - sim_birth_month_ago) %% 12 + 1

# 60-day cliff month (approximately birth month + 2)
sim_cliff_month <- (sim_birth_month + 2 - 1) %% 12 + 1

# Extension effective July 1 (month 7) of survey year
# A woman benefits if her cliff month >= 7 (i.e., she would have lost coverage
# at or after month 7, but the extension keeps her covered)
# More precisely: she benefits if she's past 60 days postpartum AND
# the extension is active AND she would otherwise be uncovered

# Fraction of FER=1 women for whom extension changes coverage:
# Woman benefits if:
# 1. She's >2 months postpartum (birth_month_ago >= 3), AND
# 2. The extension is active during her postpartum period
# For July 1 adoption: extension active months 7-12
# Woman at 3+ months postpartum and extension active:
sim_exposed <- (sim_birth_month_ago >= 3) &
  ((sim_birth_month + 2 - 1) %% 12 + 1 >= 7 | sim_survey_month >= 7)

# Simplified: fraction of women who are past 60-day cliff during extension period
exposure_fraction <- mean(sim_exposed)

# Even simpler analytic approximation:
# 10/12 women are past 60-day cliff (birth_month_ago >= 3)
# Of those, about 6/12 have their cliff fall after July 1 (uniform)
# So exposure fraction ~ 10/12 * 6/12 ≈ 0.42
# But this depends on exact timing assumptions

# Conservative estimate using analytic formula:
frac_past_cliff <- 10/12  # months 3-12 postpartum
frac_extension_active <- 6/12  # July-December for July 1 adoption
exposure_analytic <- frac_past_cliff * frac_extension_active

# For full-year adoption (Jan 1): all 10/12 exposed
exposure_full_year <- frac_past_cliff

cat(sprintf("\nAttenuation Bias Calculation:\n"))
cat(sprintf("  Fraction past 60-day cliff (month 3+): %.1f%%\n", frac_past_cliff * 100))
cat(sprintf("  Fraction with extension active (Jul 1 adoption): %.1f%%\n",
            frac_extension_active * 100))
cat(sprintf("  Exposure fraction (Jul 1 adoption, analytic): %.1f%%\n",
            exposure_analytic * 100))
cat(sprintf("  Exposure fraction (full-year adoption, analytic): %.1f%%\n",
            exposure_full_year * 100))
cat(sprintf("  Simulation-based exposure fraction: %.1f%%\n", exposure_fraction * 100))
cat(sprintf("\n  ITT scaling factor (Jul 1): %.2f (true effect = ITT / %.2f)\n",
            1/exposure_analytic, exposure_analytic))
cat(sprintf("  ITT scaling factor (full year): %.2f (true effect = ITT / %.2f)\n",
            1/exposure_full_year, exposure_full_year))

# If DDD CS-DiD ATT ~ 0.01 (1 pp), implied true effect:
ddd_att <- ifelse(!is.null(results$ddd$cs_agg_medicaid),
                  results$ddd$cs_agg_medicaid$overall.att,
                  coef(results$ddd$twfe_medicaid)[1])
cat(sprintf("\n  DDD estimate: %.4f (%.1f pp)\n", ddd_att, ddd_att * 100))
cat(sprintf("  Implied true effect (Jul 1 scaling): %.4f (%.1f pp)\n",
            ddd_att / exposure_analytic, (ddd_att / exposure_analytic) * 100))
cat(sprintf("  Implied true effect (full-year scaling): %.4f (%.1f pp)\n",
            ddd_att / exposure_full_year, (ddd_att / exposure_full_year) * 100))

attenuation_results <- list(
  frac_past_cliff = frac_past_cliff,
  frac_extension_active = frac_extension_active,
  exposure_analytic = exposure_analytic,
  exposure_full_year = exposure_full_year,
  exposure_simulation = exposure_fraction,
  scaling_july1 = 1/exposure_analytic,
  scaling_fullyear = 1/exposure_full_year
)

# =========================================================
# 16. Save robustness results
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
  post_2024only = cs_agg_2024only,
  post_2024only_twfe = if (exists("twfe_2024only")) twfe_2024only else NULL,
  post_2024only_unins = cs_agg_2024only_unins,
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
  mde = mde_80,
  permutation = list(
    distribution = perm_atts_clean,
    actual_att = twfe_actual_att,
    pval = perm_pval,
    n_perm = length(perm_atts_clean)
  ),
  attenuation = attenuation_results
)

saveRDS(robustness_results, file.path(data_dir, "robustness_results.rds"))

cat("\n=== Robustness checks complete ===\n")
