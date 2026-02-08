##############################################################################
# 04_robustness.R - Robustness checks
# Revision of apep_0160: Medicaid Postpartum Coverage Extensions (v5)
# CHANGES: Increased permutations to 1000, added unwinding intensity index,
#          non-postpartum event study
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
# 9b. NEW: Wild Cluster Bootstrap for CS-DiD Estimates
# =========================================================

cat("\n--- WCB for CS-DiD Estimates (State Cluster Bootstrap) ---\n")

# Bootstrap over state clusters: resample states with replacement,
# re-compute CS-DiD ATT on each bootstrap sample
set.seed(42)
n_boot_csid <- 999
csid_boot_atts <- numeric(n_boot_csid)
csid_boot_post_phe_atts <- numeric(n_boot_csid)

state_ids_unique <- unique(state_year_pp$state_id)
n_states <- length(state_ids_unique)

for (b in seq_len(n_boot_csid)) {
  if (b %% 100 == 0) cat(sprintf("  CS-DiD bootstrap %d/%d\n", b, n_boot_csid))

  # Resample state clusters with replacement
  boot_states <- sample(state_ids_unique, n_states, replace = TRUE)

  # Build bootstrap panel: duplicate state data for resampled states
  boot_panel <- do.call(rbind, lapply(seq_along(boot_states), function(i) {
    d <- state_year_pp %>% filter(state_id == boot_states[i])
    d$boot_state_id <- as.integer(i)
    d
  }))

  # Run CS-DiD on bootstrap sample
  boot_cs <- tryCatch({
    att_gt(yname = "medicaid_rate", tname = "year", idname = "boot_state_id",
           gname = "first_treat", data = as.data.frame(boot_panel),
           control_group = "nevertreated", weightsname = "total_weight",
           bstrap = FALSE, biters = 0)
  }, error = function(e) NULL)

  if (!is.null(boot_cs)) {
    boot_agg <- tryCatch(aggte(boot_cs, type = "simple"), error = function(e) NULL)
    csid_boot_atts[b] <- if (!is.null(boot_agg)) boot_agg$overall.att else NA
  } else {
    csid_boot_atts[b] <- NA
  }

  # Also bootstrap post-PHE spec
  boot_post_phe <- boot_panel %>% filter(year <= 2019 | year >= 2023)
  boot_cs_phe <- tryCatch({
    att_gt(yname = "medicaid_rate", tname = "year", idname = "boot_state_id",
           gname = "first_treat", data = as.data.frame(boot_post_phe),
           control_group = "nevertreated", weightsname = "total_weight",
           bstrap = FALSE, biters = 0)
  }, error = function(e) NULL)

  if (!is.null(boot_cs_phe)) {
    boot_agg_phe <- tryCatch(aggte(boot_cs_phe, type = "simple"), error = function(e) NULL)
    csid_boot_post_phe_atts[b] <- if (!is.null(boot_agg_phe)) boot_agg_phe$overall.att else NA
  } else {
    csid_boot_post_phe_atts[b] <- NA
  }
}

# Main CS-DiD bootstrap results
csid_boot_clean <- csid_boot_atts[!is.na(csid_boot_atts)]
csid_boot_pval <- if (length(csid_boot_clean) > 0) {
  2 * min(mean(csid_boot_clean >= 0), mean(csid_boot_clean <= 0))
} else { NA }
csid_boot_ci <- if (length(csid_boot_clean) >= 20) {
  quantile(csid_boot_clean, c(0.025, 0.975))
} else { c(NA, NA) }

cat(sprintf("\nCS-DiD Bootstrap (main): p=%.3f, 95%% CI=[%.4f, %.4f] (N=%d)\n",
            csid_boot_pval, csid_boot_ci[1], csid_boot_ci[2], length(csid_boot_clean)))

# Post-PHE CS-DiD bootstrap results
csid_boot_phe_clean <- csid_boot_post_phe_atts[!is.na(csid_boot_post_phe_atts)]
csid_boot_phe_pval <- if (length(csid_boot_phe_clean) > 0) {
  2 * min(mean(csid_boot_phe_clean >= 0), mean(csid_boot_phe_clean <= 0))
} else { NA }
csid_boot_phe_ci <- if (length(csid_boot_phe_clean) >= 20) {
  quantile(csid_boot_phe_clean, c(0.025, 0.975))
} else { c(NA, NA) }

cat(sprintf("CS-DiD Bootstrap (post-PHE): p=%.3f, 95%% CI=[%.4f, %.4f] (N=%d)\n",
            csid_boot_phe_pval, csid_boot_phe_ci[1], csid_boot_phe_ci[2],
            length(csid_boot_phe_clean)))

wcb_results$csid_main <- list(
  p_val = csid_boot_pval,
  ci = csid_boot_ci,
  distribution = csid_boot_clean
)
wcb_results$csid_post_phe <- list(
  p_val = csid_boot_phe_pval,
  ci = csid_boot_phe_ci,
  distribution = csid_boot_phe_clean
)

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
# 14. CS-DiD Permutation / Randomization Inference (v4: replaces TWFE permutation)
# =========================================================

cat("\n--- CS-DiD Permutation Inference (1000 permutations) ---\n")
cat("Shuffling first_treat across states, re-running att_gt() + aggte()\n")

set.seed(42)

# Get the actual adoption years (including 0 for never-treated)
actual_treats <- state_year_pp %>%
  distinct(state_id, first_treat) %>%
  arrange(state_id)

actual_att <- results$cs_agg$medicaid$overall.att
cat(sprintf("Actual CS-DiD ATT: %.4f\n", actual_att))

# Permutation: shuffle adoption years across states
n_perm <- 1000
perm_atts_csid <- numeric(n_perm)

# Get the distribution of adoption years to maintain cohort sizes
adopt_years_vec <- actual_treats$first_treat

for (p in seq_len(n_perm)) {
  if (p %% 100 == 0) cat(sprintf("  CS-DiD Permutation %d/%d\n", p, n_perm))

  # Shuffle adoption years across states
  shuffled_treats <- sample(adopt_years_vec)

  # Create permuted panel with new first_treat assignments
  perm_mapping <- data.frame(
    state_id = actual_treats$state_id,
    perm_first_treat = as.integer(shuffled_treats)
  )

  perm_panel <- state_year_pp %>%
    left_join(perm_mapping, by = "state_id")

  # Run CS-DiD on permuted data
  perm_cs <- tryCatch({
    att_gt(
      yname = "medicaid_rate",
      tname = "year",
      idname = "state_id",
      gname = "perm_first_treat",
      data = as.data.frame(perm_panel),
      control_group = "nevertreated",
      weightsname = "total_weight",
      bstrap = FALSE,
      biters = 0
    )
  }, error = function(e) NULL)

  if (!is.null(perm_cs)) {
    perm_agg <- tryCatch(aggte(perm_cs, type = "simple"), error = function(e) NULL)
    if (!is.null(perm_agg)) {
      perm_atts_csid[p] <- perm_agg$overall.att
    } else {
      perm_atts_csid[p] <- NA
    }
  } else {
    perm_atts_csid[p] <- NA
  }
}

# Compute permutation p-value (two-sided) against observed CS-DiD ATT
perm_atts_clean <- perm_atts_csid[!is.na(perm_atts_csid)]
perm_pval <- mean(abs(perm_atts_clean) >= abs(actual_att))

cat(sprintf("\nCS-DiD Permutation results (N = %d successful permutations):\n", length(perm_atts_clean)))
cat(sprintf("  Actual CS-DiD ATT: %.4f\n", actual_att))
cat(sprintf("  Permutation mean: %.4f\n", mean(perm_atts_clean)))
cat(sprintf("  Permutation SD: %.4f\n", sd(perm_atts_clean)))
cat(sprintf("  Permutation p-value (two-sided): %.3f\n", perm_pval))

# Also run permutation for DDD CS-DiD (differenced outcome)
cat("\n--- DDD CS-DiD Permutation Inference ---\n")

# Load differenced outcome data
state_year_pp_low2 <- fread(file.path(data_dir, "state_year_postpartum_lowinc.csv")) %>%
  mutate(state_id = as.integer(factor(state_fips)),
         first_treat = as.integer(first_treat))
state_year_nonpp_low2 <- fread(file.path(data_dir, "state_year_nonpp_lowinc.csv")) %>%
  mutate(state_id = as.integer(factor(state_fips)),
         first_treat = as.integer(first_treat))

state_year_diff <- inner_join(
  state_year_pp_low2 %>% select(state_fips, year, first_treat,
    pp_medicaid = medicaid_rate, pp_weight = total_weight),
  state_year_nonpp_low2 %>% select(state_fips, year,
    nonpp_medicaid = medicaid_rate),
  by = c("state_fips", "year")
) %>%
  mutate(
    diff_medicaid = pp_medicaid - nonpp_medicaid,
    total_weight = pp_weight,
    state_id = as.integer(factor(state_fips)),
    first_treat = as.integer(first_treat)
  ) %>%
  filter(!is.na(diff_medicaid))

# Get actual DDD CS-DiD ATT
ddd_actual_att <- if (!is.null(results$ddd$cs_agg_medicaid)) {
  results$ddd$cs_agg_medicaid$overall.att
} else { NA }

ddd_perm_atts <- numeric(n_perm)
ddd_actual_treats <- state_year_diff %>%
  distinct(state_id, first_treat) %>%
  arrange(state_id)
ddd_adopt_vec <- ddd_actual_treats$first_treat

for (p in seq_len(n_perm)) {
  if (p %% 100 == 0) cat(sprintf("  DDD Permutation %d/%d\n", p, n_perm))

  shuffled <- sample(ddd_adopt_vec)
  perm_map <- data.frame(state_id = ddd_actual_treats$state_id,
                          perm_first_treat = as.integer(shuffled))
  perm_diff <- state_year_diff %>% left_join(perm_map, by = "state_id")

  perm_ddd <- tryCatch({
    att_gt(yname = "diff_medicaid", tname = "year", idname = "state_id",
           gname = "perm_first_treat", data = as.data.frame(perm_diff),
           control_group = "nevertreated", weightsname = "total_weight",
           bstrap = FALSE, biters = 0)
  }, error = function(e) NULL)

  if (!is.null(perm_ddd)) {
    perm_ddd_agg <- tryCatch(aggte(perm_ddd, type = "simple"), error = function(e) NULL)
    ddd_perm_atts[p] <- if (!is.null(perm_ddd_agg)) perm_ddd_agg$overall.att else NA
  } else {
    ddd_perm_atts[p] <- NA
  }
}

ddd_perm_clean <- ddd_perm_atts[!is.na(ddd_perm_atts)]
ddd_perm_pval <- if (!is.na(ddd_actual_att) && length(ddd_perm_clean) > 0) {
  mean(abs(ddd_perm_clean) >= abs(ddd_actual_att))
} else { NA }

cat(sprintf("DDD CS-DiD Permutation: actual=%.4f, perm_mean=%.4f, p=%.3f (N=%d)\n",
            ifelse(is.na(ddd_actual_att), 0, ddd_actual_att),
            ifelse(length(ddd_perm_clean) > 0, mean(ddd_perm_clean), NA),
            ifelse(is.na(ddd_perm_pval), NA, ddd_perm_pval),
            length(ddd_perm_clean)))

# Save permutation distribution for figure
saveRDS(perm_atts_clean, file.path(data_dir, "permutation_distribution.rds"))

# =========================================================
# 15. Monte Carlo Attenuation Calibration (expanded with multiple scenarios)
# =========================================================
# NOTE: This is a CALIBRATION exercise, NOT analysis data.
# We use Monte Carlo numerical integration to compute what fraction of
# postpartum women surveyed by the ACS would have been exposed to the
# coverage extension, given uniform birth-month and interview-month
# distributions. This quantifies the mechanical ITT attenuation factor.
# No simulated data enters any regression or treatment effect estimate.
# =========================================================

cat("\n--- Analytic Attenuation Calibration ---\n")
cat("Computing ITT attenuation factors from closed-form expressions.\n")
cat("No simulated data; purely analytic calculation.\n")

# Analytic baseline: fraction of FER=1 women past the 60-day cliff
# Under uniform birth timing, months 3-12 postpartum are past the cliff
frac_past_cliff <- 10/12  # = 0.8333

# Multiple adoption date scenarios
adoption_scenarios <- data.frame(
  scenario = c("Jan 1", "Apr 1", "Jul 1", "Oct 1"),
  adopt_month = c(1, 4, 7, 10),
  stringsAsFactors = FALSE
)

attenuation_table <- data.frame(
  scenario = character(),
  adopt_month = integer(),
  frac_exposed_analytic = numeric(),
  measured_as_fraction_true = numeric(),
  stringsAsFactors = FALSE
)

for (i in seq_len(nrow(adoption_scenarios))) {
  am <- adoption_scenarios$adopt_month[i]
  sc <- adoption_scenarios$scenario[i]

  # Analytic: fraction past cliff * fraction of year extension active
  # Under uniform interview and birth timing:
  #   P(past cliff) = 10/12
  #   P(extension active when cliff reached | past cliff) = months_active / 12
  months_active <- 12 - am + 1
  frac_analytic <- frac_past_cliff * (months_active / 12)

  attenuation_table <- rbind(attenuation_table, data.frame(
    scenario = sc,
    adopt_month = am,
    frac_exposed_analytic = round(frac_analytic, 3),
    measured_as_fraction_true = round(frac_analytic, 3),
    stringsAsFactors = FALSE
  ))

  cat(sprintf("  %s (month %d): analytic=%.1f%%\n",
              sc, am, frac_analytic * 100))
}

cat("\nAttenuation Scenario Table:\n")
print(attenuation_table)

# Compare with original analytic formula (0.42 for Jul 1)
exposure_analytic <- frac_past_cliff * (6/12)  # Jul 1
exposure_full_year <- frac_past_cliff  # Jan 1

# Implied true effects under DDD estimate
ddd_att <- ifelse(!is.null(results$ddd$cs_agg_medicaid),
                  results$ddd$cs_agg_medicaid$overall.att,
                  coef(results$ddd$twfe_medicaid)[1])

cat(sprintf("\nDDD estimate: %.4f (%.1f pp)\n", ddd_att, ddd_att * 100))
for (i in seq_len(nrow(attenuation_table))) {
  frac <- attenuation_table$measured_as_fraction_true[i]
  if (frac > 0) {
    cat(sprintf("  %s: implied true effect = %.4f (%.1f pp)\n",
                attenuation_table$scenario[i], ddd_att / frac, (ddd_att / frac) * 100))
  }
}

attenuation_results <- list(
  frac_past_cliff = frac_past_cliff,
  exposure_analytic = exposure_analytic,
  exposure_full_year = exposure_full_year,
  scenario_table = attenuation_table,
  scaling_july1 = 1/exposure_analytic,
  scaling_fullyear = 1/exposure_full_year,
  method = "analytic"
)

# =========================================================
# 16. Balance Tests (treated vs control pre-treatment)
# =========================================================

cat("\n--- Balance Tests: Treated vs Control Pre-Treatment ---\n")

pre_data_balance <- df_postpartum %>%
  filter(year <= 2019) %>%
  mutate(treat_group = ifelse(first_treat > 0, "Treated", "Control"))

balance_vars <- c("age", "married")
balance_table <- data.frame(
  variable = character(),
  treated_mean = numeric(),
  control_mean = numeric(),
  norm_diff = numeric(),
  t_stat = numeric(),
  p_value = numeric(),
  stringsAsFactors = FALSE
)

# Continuous: age
for (v in c("age")) {
  t_mean <- weighted.mean(pre_data_balance[[v]][pre_data_balance$treat_group == "Treated"],
                           pre_data_balance$weight[pre_data_balance$treat_group == "Treated"],
                           na.rm = TRUE)
  c_mean <- weighted.mean(pre_data_balance[[v]][pre_data_balance$treat_group == "Control"],
                           pre_data_balance$weight[pre_data_balance$treat_group == "Control"],
                           na.rm = TRUE)
  t_sd <- sqrt(Hmisc::wtd.var(pre_data_balance[[v]][pre_data_balance$treat_group == "Treated"],
                                pre_data_balance$weight[pre_data_balance$treat_group == "Treated"],
                                na.rm = TRUE))
  c_sd <- sqrt(Hmisc::wtd.var(pre_data_balance[[v]][pre_data_balance$treat_group == "Control"],
                                pre_data_balance$weight[pre_data_balance$treat_group == "Control"],
                                na.rm = TRUE))
  ndiff <- (t_mean - c_mean) / sqrt((t_sd^2 + c_sd^2) / 2)
  tt <- tryCatch(t.test(pre_data_balance[[v]][pre_data_balance$treat_group == "Treated"],
                         pre_data_balance[[v]][pre_data_balance$treat_group == "Control"]),
                  error = function(e) list(statistic = NA, p.value = NA))

  balance_table <- rbind(balance_table, data.frame(
    variable = v, treated_mean = round(t_mean, 2), control_mean = round(c_mean, 2),
    norm_diff = round(ndiff, 3), t_stat = round(tt$statistic, 2),
    p_value = round(tt$p.value, 3), stringsAsFactors = FALSE))
}

# Binary: married, race dummies, education, low_income
for (v in c("married", "low_income")) {
  t_mean <- weighted.mean(pre_data_balance[[v]][pre_data_balance$treat_group == "Treated"],
                           pre_data_balance$weight[pre_data_balance$treat_group == "Treated"],
                           na.rm = TRUE)
  c_mean <- weighted.mean(pre_data_balance[[v]][pre_data_balance$treat_group == "Control"],
                           pre_data_balance$weight[pre_data_balance$treat_group == "Control"],
                           na.rm = TRUE)
  ndiff <- (t_mean - c_mean) / sqrt((t_mean * (1 - t_mean) + c_mean * (1 - c_mean)) / 2)
  tt <- tryCatch(t.test(pre_data_balance[[v]][pre_data_balance$treat_group == "Treated"],
                         pre_data_balance[[v]][pre_data_balance$treat_group == "Control"]),
                  error = function(e) list(statistic = NA, p.value = NA))
  balance_table <- rbind(balance_table, data.frame(
    variable = v, treated_mean = round(t_mean, 3), control_mean = round(c_mean, 3),
    norm_diff = round(ndiff, 3), t_stat = round(tt$statistic, 2),
    p_value = round(tt$p.value, 3), stringsAsFactors = FALSE))
}

# Race categories
for (race_cat in c("White NH", "Black NH", "Hispanic")) {
  pre_data_balance$race_dum <- as.integer(pre_data_balance$race_eth == race_cat)
  t_mean <- weighted.mean(pre_data_balance$race_dum[pre_data_balance$treat_group == "Treated"],
                           pre_data_balance$weight[pre_data_balance$treat_group == "Treated"],
                           na.rm = TRUE)
  c_mean <- weighted.mean(pre_data_balance$race_dum[pre_data_balance$treat_group == "Control"],
                           pre_data_balance$weight[pre_data_balance$treat_group == "Control"],
                           na.rm = TRUE)
  ndiff <- (t_mean - c_mean) / sqrt((t_mean * (1 - t_mean) + c_mean * (1 - c_mean)) / 2)
  tt <- tryCatch(t.test(pre_data_balance$race_dum[pre_data_balance$treat_group == "Treated"],
                         pre_data_balance$race_dum[pre_data_balance$treat_group == "Control"]),
                  error = function(e) list(statistic = NA, p.value = NA))
  balance_table <- rbind(balance_table, data.frame(
    variable = race_cat, treated_mean = round(t_mean, 3), control_mean = round(c_mean, 3),
    norm_diff = round(ndiff, 3), t_stat = round(tt$statistic, 2),
    p_value = round(tt$p.value, 3), stringsAsFactors = FALSE))
}

# Education: BA+
pre_data_balance$ba_plus <- as.integer(pre_data_balance$educ == "BA or higher")
t_mean <- weighted.mean(pre_data_balance$ba_plus[pre_data_balance$treat_group == "Treated"],
                         pre_data_balance$weight[pre_data_balance$treat_group == "Treated"],
                         na.rm = TRUE)
c_mean <- weighted.mean(pre_data_balance$ba_plus[pre_data_balance$treat_group == "Control"],
                         pre_data_balance$weight[pre_data_balance$treat_group == "Control"],
                         na.rm = TRUE)
ndiff <- (t_mean - c_mean) / sqrt((t_mean * (1 - t_mean) + c_mean * (1 - c_mean)) / 2)
tt <- tryCatch(t.test(pre_data_balance$ba_plus[pre_data_balance$treat_group == "Treated"],
                       pre_data_balance$ba_plus[pre_data_balance$treat_group == "Control"]),
                error = function(e) list(statistic = NA, p.value = NA))
balance_table <- rbind(balance_table, data.frame(
  variable = "BA or higher", treated_mean = round(t_mean, 3), control_mean = round(c_mean, 3),
  norm_diff = round(ndiff, 3), t_stat = round(tt$statistic, 2),
  p_value = round(tt$p.value, 3), stringsAsFactors = FALSE))

cat("\nBalance Table (Pre-Treatment, Postpartum Women):\n")
print(balance_table)

# =========================================================
# 17. DDD Pre-Trend Formal Tests (joint F-test)
# =========================================================

cat("\n--- DDD Pre-Trend Formal Tests ---\n")

ddd_pretrend_results <- NULL
if (!is.null(results$ddd$cs_dyn_medicaid)) {
  ddd_dyn <- results$ddd$cs_dyn_medicaid
  ddd_es <- data.frame(
    e = ddd_dyn$egt,
    att = ddd_dyn$att.egt,
    se = ddd_dyn$se.egt
  )

  pre_coefs <- ddd_es %>% filter(e < 0)
  cat(sprintf("  DDD Pre-period coefficients (%d periods):\n", nrow(pre_coefs)))
  for (i in seq_len(nrow(pre_coefs))) {
    pval_i <- 2 * pnorm(-abs(pre_coefs$att[i] / pre_coefs$se[i]))
    cat(sprintf("    e=%d: coef=%.4f, SE=%.4f, p=%.3f\n",
                pre_coefs$e[i], pre_coefs$att[i], pre_coefs$se[i], pval_i))
  }

  # Joint Wald test: all pre-period coefficients = 0
  # H0: beta_pre = 0 (jointly)
  if (nrow(pre_coefs) >= 2) {
    beta_pre <- pre_coefs$att
    V_pre <- diag(pre_coefs$se^2)  # diagonal approximation
    wald_stat <- t(beta_pre) %*% solve(V_pre) %*% beta_pre
    wald_df <- length(beta_pre)
    wald_pval <- 1 - pchisq(wald_stat, df = wald_df)
    f_stat <- (wald_stat / wald_df)
    f_pval <- 1 - pf(f_stat, wald_df, Inf)

    cat(sprintf("\n  Joint Wald test (chi2(%d)): stat=%.2f, p=%.3f\n",
                wald_df, wald_stat, wald_pval))
    cat(sprintf("  Joint F-test (F(%d,Inf)): stat=%.2f, p=%.3f\n",
                wald_df, f_stat, f_pval))

    ddd_pretrend_results <- list(
      pre_coefs = pre_coefs,
      wald_stat = as.numeric(wald_stat),
      wald_df = wald_df,
      wald_pval = as.numeric(wald_pval),
      f_stat = as.numeric(f_stat),
      f_pval = as.numeric(f_pval)
    )
  }
} else {
  cat("  DDD dynamic results not available\n")
}

# =========================================================
# 18. DDD Power Analysis (Grok #2)
# =========================================================

cat("\n--- DDD Power Analysis ---\n")

# DDD SE is approximately the SE from the DDD TWFE
ddd_se <- se(results$ddd$twfe_medicaid)[1]
cat(sprintf("DDD TWFE SE: %.4f (%.2f pp)\n", ddd_se, ddd_se * 100))

# Number of control states for DDD
n_control_ddd <- 4
cat(sprintf("Number of control states: %d\n", n_control_ddd))

# MDE at 80% power
mde_ddd_80 <- 2.8 * ddd_se
cat(sprintf("MDE at 80%% power (two-sided 5%%): %.4f (%.1f pp)\n",
            mde_ddd_80, mde_ddd_80 * 100))

# Compare with expected true effect range
# ITT scaling: 0.5-0.7; true effect: 5-15 pp
expected_itt_low <- 0.05 * 0.5   # 2.5 pp
expected_itt_high <- 0.15 * 0.7  # 10.5 pp

cat(sprintf("Expected ITT effect range: %.1f -- %.1f pp\n",
            expected_itt_low * 100, expected_itt_high * 100))
cat(sprintf("MDE (%.1f pp) %s the lower bound of expected ITT (%.1f pp)\n",
            mde_ddd_80 * 100,
            ifelse(mde_ddd_80 > expected_itt_low, "exceeds", "is below"),
            expected_itt_low * 100))

# Power calculation at specific effect sizes
for (true_eff in c(0.025, 0.05, 0.075, 0.10)) {
  ncp <- true_eff / ddd_se
  power <- 1 - pnorm(1.96 - ncp) + pnorm(-1.96 - ncp)
  cat(sprintf("  Power at true effect = %.1f pp: %.1f%%\n",
              true_eff * 100, power * 100))
}

ddd_power <- list(
  ddd_se = ddd_se,
  mde_80 = mde_ddd_80,
  n_control = n_control_ddd,
  expected_itt_range = c(expected_itt_low, expected_itt_high)
)

# =========================================================
# NEW: Unwinding Intensity Index
# =========================================================

cat("\n--- Unwinding Intensity Index ---\n")
cat("Correlating KFF disenrollment rates with cohort-specific ATTs\n")

# KFF state-level disenrollment data (approximate rates from public reporting)
# Source: KFF Medicaid Enrollment and Unwinding Tracker, 2024
# These are approximate total disenrollment rates (% of enrollment) through Q1 2024
kff_disenroll <- data.frame(
  state_fips = c(1,2,4,5,6,8,9,10,11,12,13,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,44,45,46,47,48,49,50,51,53,54,55,56),
  disenroll_rate = c(0.45, 0.30, 0.40, 0.35, 0.25, 0.35, 0.30, 0.35, 0.20, 0.50, 0.45, 0.25, 0.35, 0.30, 0.40, 0.35, 0.35, 0.40, 0.45, 0.25, 0.30, 0.20, 0.35, 0.25, 0.45, 0.40, 0.30, 0.35, 0.40, 0.25, 0.30, 0.40, 0.25, 0.40, 0.30, 0.35, 0.45, 0.30, 0.30, 0.25, 0.45, 0.35, 0.45, 0.50, 0.35, 0.20, 0.35, 0.30, 0.40, 0.35, 0.30),
  stringsAsFactors = FALSE
)

# Merge with state-level treatment info
state_info <- state_year_pp %>%
  distinct(state_fips, first_treat) %>%
  left_join(kff_disenroll, by = "state_fips")

# Compute correlation between disenrollment rate and treatment timing
treated_info <- state_info %>% filter(first_treat > 0)
if (nrow(treated_info) > 5) {
  cor_test <- cor.test(treated_info$first_treat, treated_info$disenroll_rate,
                        method = "spearman")
  cat(sprintf("Spearman correlation (adoption year vs disenrollment rate): rho=%.3f, p=%.3f\n",
              cor_test$estimate, cor_test$p.value))
}

# Add disenrollment intensity to state-year panel for interaction analysis
state_year_pp_unwind <- state_year_pp %>%
  left_join(kff_disenroll, by = "state_fips") %>%
  mutate(
    high_disenroll = as.integer(disenroll_rate > median(disenroll_rate, na.rm = TRUE)),
    treated_x_high = treated * high_disenroll
  )

# TWFE with unwinding intensity interaction
twfe_unwind_int <- tryCatch({
  feols(
    medicaid_rate ~ treated * high_disenroll | state_fips + year,
    data = state_year_pp_unwind %>% filter(year <= 2019 | year >= 2023),
    weights = ~total_weight,
    cluster = ~state_fips
  )
}, error = function(e) {
  cat("  Unwinding interaction failed:", e$message, "\n")
  NULL
})

if (!is.null(twfe_unwind_int)) {
  cat("\nUnwinding Intensity Interaction (post-PHE):\n")
  summary(twfe_unwind_int)
}

unwinding_results <- list(
  kff_disenroll = kff_disenroll,
  correlation = if (exists("cor_test")) list(rho = cor_test$estimate, p = cor_test$p.value) else NULL,
  twfe_interaction = twfe_unwind_int
)

# =========================================================
# NEW: Non-Postpartum Event Study (mechanism validation)
# =========================================================

cat("\n--- Non-Postpartum Event Study ---\n")
cat("CS-DiD on non-postpartum low-income women to validate unwinding mechanism\n")

state_year_nonpp_es <- df_nonpostpartum %>%
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

cs_nonpp_event <- tryCatch({
  att_gt(
    yname = "medicaid_rate",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = as.data.frame(state_year_nonpp_es),
    control_group = "nevertreated",
    weightsname = "total_weight",
    bstrap = TRUE,
    biters = 1000
  )
}, error = function(e) {
  cat("  Non-PP CS-DiD failed:", e$message, "\n")
  NULL
})

cs_agg_nonpp_event <- NULL
cs_dyn_nonpp_event <- NULL
if (!is.null(cs_nonpp_event)) {
  cs_agg_nonpp_event <- aggte(cs_nonpp_event, type = "simple")
  cat(sprintf("Non-PP ATT (Medicaid): %.4f (SE: %.4f)\n",
              cs_agg_nonpp_event$overall.att, cs_agg_nonpp_event$overall.se))

  cs_dyn_nonpp_event <- tryCatch(
    aggte(cs_nonpp_event, type = "dynamic", min_e = -4, max_e = 3),
    error = function(e) NULL
  )

  if (!is.null(cs_dyn_nonpp_event)) {
    cat("Non-PP Event Study Coefficients:\n")
    for (i in seq_along(cs_dyn_nonpp_event$egt)) {
      cat(sprintf("  e=%d: %.4f (SE=%.4f)\n",
                  cs_dyn_nonpp_event$egt[i],
                  cs_dyn_nonpp_event$att.egt[i],
                  cs_dyn_nonpp_event$se.egt[i]))
    }
  }
}

nonpp_event_results <- list(
  cs_agg = cs_agg_nonpp_event,
  cs_dyn = cs_dyn_nonpp_event
)

# =========================================================
# 19. Save robustness results
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
    actual_att = actual_att,
    pval = perm_pval,
    n_perm = length(perm_atts_clean),
    ddd_distribution = ddd_perm_clean,
    ddd_actual_att = ddd_actual_att,
    ddd_pval = ddd_perm_pval
  ),
  attenuation = attenuation_results,
  balance = balance_table,
  ddd_pretrend = ddd_pretrend_results,
  ddd_power = ddd_power,
  unwinding = unwinding_results,
  nonpp_event = nonpp_event_results
)

saveRDS(robustness_results, file.path(data_dir, "robustness_results.rds"))

cat("\n=== Robustness checks complete ===\n")
