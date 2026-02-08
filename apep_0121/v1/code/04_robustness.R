# ==============================================================================
# 04_robustness.R
# State Minimum Wage Increases and Young Adult Household Formation
# Purpose: Robustness checks — thresholds, placebo, HonestDiD, Bacon, COVID
# ==============================================================================

source("code/00_packages.R")

cat("\n========================================================\n")
cat("  04_robustness.R: Robustness and sensitivity analysis\n")
cat("========================================================\n\n")

# ==============================================================================
# SECTION 1: Load data and main results
# ==============================================================================

cat("--- Loading data ---\n")

panel <- read.csv(file.path(DATA_DIR, "analysis_panel.csv"),
                  stringsAsFactors = FALSE)
cat("  Panel:", nrow(panel), "obs\n")

# Load main CS results for comparison
cs_out <- readRDS(file.path(DATA_DIR, "cs_out.rds"))
es     <- readRDS(file.path(DATA_DIR, "cs_event_study.rds"))
cat("  Loaded main CS-DiD results\n\n")

# Container for robustness results
robustness_results <- list()

# ==============================================================================
# SECTION 2: Alternative treatment thresholds
# ==============================================================================

cat("--- Alternative treatment thresholds ---\n\n")

thresholds <- c(0.50, 1.00, 1.50, 2.00)

for (thresh in thresholds) {
  cat(sprintf("  Threshold: MW gap > $%.2f\n", thresh))

  # Redefine treatment based on alternative threshold
  panel_alt <- panel %>%
    group_by(state_fips) %>%
    mutate(
      treated_alt   = as.integer(mw_gap >= thresh),
      first_treat_alt = {
        treat_years <- year[mw_gap >= thresh]
        if (length(treat_years) > 0) min(treat_years) else 0L
      }
    ) %>%
    ungroup()

  n_treated <- length(unique(panel_alt$state_fips[panel_alt$first_treat_alt > 0]))
  n_never   <- length(unique(panel_alt$state_fips[panel_alt$first_treat_alt == 0]))
  cat(sprintf("    Treated: %d states | Never-treated: %d states\n",
              n_treated, n_never))

  # Skip if insufficient variation
  if (n_treated < 5 || n_never < 3) {
    cat("    SKIPPED: insufficient variation\n\n")
    next
  }

  cs_alt <- tryCatch({
    att_gt(
      yname       = "pct_with_parents",
      tname       = "year",
      idname      = "state_fips",
      gname       = "first_treat_alt",
      data        = panel_alt,
      control_group = "nevertreated",
      base_period   = "universal",
      print_details = FALSE
    )
  }, error = function(e) {
    cat("    ERROR:", conditionMessage(e), "\n")
    NULL
  })

  if (!is.null(cs_alt)) {
    att_alt <- aggte(cs_alt, type = "simple")
    cat(sprintf("    ATT: %.4f (SE: %.4f)\n", att_alt$overall.att, att_alt$overall.se))

    robustness_results[[paste0("threshold_", gsub("\\.", "", sprintf("%.2f", thresh)))]] <- list(
      threshold   = thresh,
      att         = att_alt$overall.att,
      se          = att_alt$overall.se,
      n_treated   = n_treated,
      n_never     = n_never,
      cs_obj      = cs_alt,
      att_obj     = att_alt
    )
  }
  cat("\n")
}

# ==============================================================================
# SECTION 3: Continuous dose-response (MW gap as treatment intensity)
# ==============================================================================

cat("--- Continuous dose-response ---\n")

# Model 1: Linear MW gap
dose_linear <- feols(
  pct_with_parents ~ mw_gap_continuous | state_fips + year,
  data    = panel,
  cluster = ~state_fips
)

cat(sprintf("  Linear dose-response (mw_gap):\n"))
cat(sprintf("    Coefficient: %.4f (SE: %.4f, p: %.4f)\n",
            coef(dose_linear)["mw_gap_continuous"],
            se(dose_linear)["mw_gap_continuous"],
            fixest::pvalue(dose_linear)["mw_gap_continuous"]))

# Model 2: Quadratic MW gap
panel$mw_gap_sq <- panel$mw_gap_continuous^2

dose_quad <- feols(
  pct_with_parents ~ mw_gap_continuous + mw_gap_sq | state_fips + year,
  data    = panel,
  cluster = ~state_fips
)

cat(sprintf("  Quadratic dose-response:\n"))
cat(sprintf("    Linear:    %.4f (SE: %.4f)\n",
            coef(dose_quad)["mw_gap_continuous"],
            se(dose_quad)["mw_gap_continuous"]))
cat(sprintf("    Quadratic: %.4f (SE: %.4f)\n",
            coef(dose_quad)["mw_gap_sq"],
            se(dose_quad)["mw_gap_sq"]))

robustness_results$dose_linear <- dose_linear
robustness_results$dose_quad   <- dose_quad

saveRDS(dose_linear, file.path(DATA_DIR, "dose_linear.rds"))
saveRDS(dose_quad,   file.path(DATA_DIR, "dose_quad.rds"))
cat("  Saved: dose_linear.rds, dose_quad.rds\n\n")

# ==============================================================================
# SECTION 4: Placebo / Falsification test
# ==============================================================================

cat("--- Placebo / Falsification test ---\n")

# Use pct_other (other living arrangements) as a placebo outcome
# MW increases should not affect the "other arrangements" category
# (group quarters, etc.) if our identification is correct

cs_placebo <- tryCatch({
  att_gt(
    yname       = "pct_other",
    tname       = "year",
    idname      = "state_fips",
    gname       = "first_treat",
    data        = panel,
    control_group = "nevertreated",
    base_period   = "universal",
    print_details = FALSE
  )
}, error = function(e) {
  cat("  ERROR running placebo on pct_other:", conditionMessage(e), "\n")
  NULL
})

if (!is.null(cs_placebo)) {
  att_placebo <- aggte(cs_placebo, type = "simple")
  es_placebo  <- aggte(cs_placebo, type = "dynamic")

  cat(sprintf("  Placebo outcome (pct_other):\n"))
  cat(sprintf("    ATT: %.4f (SE: %.4f, p: %.4f)\n",
              att_placebo$overall.att, att_placebo$overall.se,
              2 * pnorm(-abs(att_placebo$overall.att / att_placebo$overall.se))))

  robustness_results$placebo <- list(
    cs_obj  = cs_placebo,
    att_obj = att_placebo,
    es_obj  = es_placebo
  )

  saveRDS(cs_placebo,  file.path(DATA_DIR, "cs_placebo.rds"))
  saveRDS(att_placebo, file.path(DATA_DIR, "cs_placebo_att.rds"))
  saveRDS(es_placebo,  file.path(DATA_DIR, "cs_placebo_es.rds"))
  cat("  Saved: cs_placebo.rds, cs_placebo_att.rds, cs_placebo_es.rds\n")
}
cat("\n")

# ==============================================================================
# SECTION 5: CS-DiD with covariates
# ==============================================================================

cat("--- CS-DiD with covariates ---\n")

panel_cov <- panel %>%
  filter(!is.na(unemployment_rate) & !is.na(log_rent))

cs_controls <- tryCatch({
  att_gt(
    yname       = "pct_with_parents",
    tname       = "year",
    idname      = "state_fips",
    gname       = "first_treat",
    data        = panel_cov,
    xformla     = ~ unemployment_rate + log_rent,
    control_group = "nevertreated",
    base_period   = "universal",
    print_details = FALSE
  )
}, error = function(e) {
  cat("  ERROR:", conditionMessage(e), "\n")
  NULL
})

if (!is.null(cs_controls)) {
  att_controls <- aggte(cs_controls, type = "simple")
  cat(sprintf("  ATT with controls: %.4f (SE: %.4f)\n",
              att_controls$overall.att, att_controls$overall.se))

  robustness_results$with_controls <- list(
    cs_obj  = cs_controls,
    att_obj = att_controls
  )
  saveRDS(cs_controls,  file.path(DATA_DIR, "cs_controls.rds"))
  saveRDS(att_controls, file.path(DATA_DIR, "cs_controls_att.rds"))
  cat("  Saved: cs_controls.rds, cs_controls_att.rds\n")
}
cat("\n")

# ==============================================================================
# SECTION 6: Alternative control group — not-yet-treated
# ==============================================================================

cat("--- Not-yet-treated control group ---\n")

cs_nyt <- tryCatch({
  att_gt(
    yname       = "pct_with_parents",
    tname       = "year",
    idname      = "state_fips",
    gname       = "first_treat",
    data        = panel,
    control_group = "notyettreated",
    base_period   = "universal",
    print_details = FALSE
  )
}, error = function(e) {
  cat("  ERROR:", conditionMessage(e), "\n")
  NULL
})

if (!is.null(cs_nyt)) {
  att_nyt <- aggte(cs_nyt, type = "simple")
  es_nyt  <- aggte(cs_nyt, type = "dynamic")
  cat(sprintf("  ATT (not-yet-treated): %.4f (SE: %.4f)\n",
              att_nyt$overall.att, att_nyt$overall.se))

  robustness_results$not_yet_treated <- list(
    cs_obj  = cs_nyt,
    att_obj = att_nyt,
    es_obj  = es_nyt
  )
  saveRDS(cs_nyt,  file.path(DATA_DIR, "cs_nyt.rds"))
  saveRDS(att_nyt, file.path(DATA_DIR, "cs_nyt_att.rds"))
  saveRDS(es_nyt,  file.path(DATA_DIR, "cs_nyt_es.rds"))
  cat("  Saved: cs_nyt.rds, cs_nyt_att.rds, cs_nyt_es.rds\n")
}
cat("\n")

# ==============================================================================
# SECTION 7: HonestDiD sensitivity analysis
# ==============================================================================

cat("--- HonestDiD sensitivity analysis ---\n")

honest_results <- tryCatch({
  # Extract event study estimates and variance-covariance matrix
  es_att  <- es$att.egt
  es_se   <- es$se.egt
  es_egt  <- es$egt

  # Identify pre- and post-treatment periods
  pre_idx  <- which(es_egt < 0)
  post_idx <- which(es_egt >= 0)

  if (length(pre_idx) < 2 || length(post_idx) < 1) {
    cat("  Insufficient pre/post periods for HonestDiD\n")
    NULL
  } else {
    # Get the full variance-covariance matrix
    V_full <- es$V.egt

    # Order: pre-treatment periods first, then post-treatment
    reorder <- c(pre_idx, post_idx)
    betahat <- es_att[reorder]
    sigma   <- V_full[reorder, reorder]

    n_pre  <- length(pre_idx)
    n_post <- length(post_idx)

    cat(sprintf("  Pre-treatment periods: %d | Post-treatment periods: %d\n",
                n_pre, n_post))

    # Relative magnitudes approach (Rambachan & Roth 2023)
    honest_rm <- createSensitivityResults_relativeMagnitudes(
      betahat        = betahat,
      sigma          = sigma,
      numPrePeriods  = n_pre,
      numPostPeriods = n_post,
      Mbarvec        = seq(0, 2, by = 0.5)
    )

    cat("  HonestDiD relative magnitudes bounds:\n")
    cat(sprintf("  %-6s %12s %12s\n", "Mbar", "Lower CI", "Upper CI"))
    cat(paste(rep("-", 34), collapse = ""), "\n")
    for (i in seq_len(nrow(honest_rm))) {
      cat(sprintf("  %-6.1f %12.4f %12.4f\n",
                  honest_rm$Mbar[i],
                  honest_rm$lb[i],
                  honest_rm$ub[i]))
    }

    # Smoothness-based approach (Delta-SD)
    honest_sd <- tryCatch({
      createSensitivityResults(
        betahat        = betahat,
        sigma          = sigma,
        numPrePeriods  = n_pre,
        numPostPeriods = n_post,
        Mvec           = seq(0, 0.05, by = 0.01)
      )
    }, error = function(e) {
      cat("  Note: Delta-SD approach failed:", conditionMessage(e), "\n")
      NULL
    })

    list(
      relative_magnitudes = honest_rm,
      smoothness          = honest_sd,
      betahat             = betahat,
      sigma               = sigma,
      n_pre               = n_pre,
      n_post              = n_post
    )
  }
}, error = function(e) {
  cat("  ERROR in HonestDiD:", conditionMessage(e), "\n")
  NULL
})

if (!is.null(honest_results)) {
  robustness_results$honest_did <- honest_results
  saveRDS(honest_results, file.path(DATA_DIR, "honest_did_results.rds"))
  cat("  Saved: honest_did_results.rds\n")

  # Determine breakdown value: largest Mbar where CI excludes zero
  rm_df <- honest_results$relative_magnitudes
  zero_excluded <- (rm_df$lb > 0) | (rm_df$ub < 0)
  if (any(zero_excluded)) {
    breakdown_val <- max(rm_df$Mbar[zero_excluded])
    cat(sprintf("  Breakdown value (relative magnitudes): Mbar = %.1f\n", breakdown_val))
  } else {
    cat("  No breakdown value found (CI includes zero at Mbar = 0)\n")
  }
}
cat("\n")

# ==============================================================================
# SECTION 8: Bacon decomposition
# ==============================================================================

cat("--- Bacon decomposition ---\n")

bacon_out <- tryCatch({
  bacon(
    pct_with_parents ~ treated,
    data     = panel,
    id_var   = "state_fips",
    time_var = "year"
  )
}, error = function(e) {
  cat("  ERROR:", conditionMessage(e), "\n")
  NULL
})

if (!is.null(bacon_out)) {
  cat("  Bacon decomposition results:\n")

  # Summarize by type
  bacon_summary <- bacon_out %>%
    group_by(type) %>%
    summarise(
      n_comparisons = n(),
      avg_estimate  = weighted.mean(estimate, weight),
      total_weight  = sum(weight),
      .groups = "drop"
    )

  cat(sprintf("  %-35s %8s %10s %10s\n",
              "Type", "N", "Wt.Avg.DD", "Weight"))
  cat(paste(rep("-", 67), collapse = ""), "\n")
  for (i in seq_len(nrow(bacon_summary))) {
    cat(sprintf("  %-35s %8d %10.4f %10.4f\n",
                bacon_summary$type[i],
                bacon_summary$n_comparisons[i],
                bacon_summary$avg_estimate[i],
                bacon_summary$total_weight[i]))
  }

  robustness_results$bacon <- bacon_out
  saveRDS(bacon_out, file.path(DATA_DIR, "bacon_decomposition.rds"))
  cat("\n  Saved: bacon_decomposition.rds\n")
}
cat("\n")

# ==============================================================================
# SECTION 9: COVID robustness — drop 2021 (immediate post-COVID)
# ==============================================================================
# NOTE: 2020 is already absent from the panel (ACS 1-year not released).
# So the meaningful COVID robustness check is dropping 2021, the first
# post-pandemic year, which may reflect temporary COVID-related boomerang
# effects on young adult living arrangements.

cat("--- COVID robustness: dropping 2021 ---\n")

panel_no2021 <- panel %>% filter(year != 2021)
cat("  Panel without 2021:", nrow(panel_no2021), "obs (", length(unique(panel_no2021$year)), "years )\n")

cs_no2021 <- tryCatch({
  att_gt(
    yname       = "pct_with_parents",
    tname       = "year",
    idname      = "state_fips",
    gname       = "first_treat",
    data        = panel_no2021,
    control_group = "nevertreated",
    base_period   = "universal",
    print_details = FALSE
  )
}, error = function(e) {
  cat("  ERROR:", conditionMessage(e), "\n")
  NULL
})

if (!is.null(cs_no2021)) {
  att_no2021 <- aggte(cs_no2021, type = "simple")
  es_no2021  <- aggte(cs_no2021, type = "dynamic")

  cat(sprintf("  ATT (drop 2021): %.4f (SE: %.4f)\n",
              att_no2021$overall.att, att_no2021$overall.se))

  robustness_results$no_2021 <- list(
    cs_obj  = cs_no2021,
    att_obj = att_no2021,
    es_obj  = es_no2021
  )
  saveRDS(cs_no2021,  file.path(DATA_DIR, "cs_no2021.rds"))
  saveRDS(att_no2021, file.path(DATA_DIR, "cs_no2021_att.rds"))
  saveRDS(es_no2021,  file.path(DATA_DIR, "cs_no2021_es.rds"))
  cat("  Saved: cs_no2021.rds, cs_no2021_att.rds, cs_no2021_es.rds\n")
}
cat("\n")

# ==============================================================================
# SECTION 10: Pre-pandemic only (2015-2019)
# ==============================================================================
# NOTE: Drop both 2021 and 2022, retaining only the pre-pandemic period.
# This tests whether results are driven by post-pandemic living arrangement shifts.

cat("--- Pre-pandemic only: 2015-2019 ---\n")

panel_prepandemic <- panel %>% filter(year <= 2019)
cat("  Pre-pandemic panel:", nrow(panel_prepandemic), "obs (", length(unique(panel_prepandemic$year)), "years )\n")

cs_prepandemic <- tryCatch({
  att_gt(
    yname       = "pct_with_parents",
    tname       = "year",
    idname      = "state_fips",
    gname       = "first_treat",
    data        = panel_prepandemic,
    control_group = "nevertreated",
    base_period   = "universal",
    print_details = FALSE
  )
}, error = function(e) {
  cat("  ERROR:", conditionMessage(e), "\n")
  NULL
})

if (!is.null(cs_prepandemic)) {
  att_prepandemic <- aggte(cs_prepandemic, type = "simple")
  cat(sprintf("  ATT (pre-pandemic): %.4f (SE: %.4f)\n",
              att_prepandemic$overall.att, att_prepandemic$overall.se))

  robustness_results$prepandemic <- list(
    cs_obj  = cs_prepandemic,
    att_obj = att_prepandemic
  )
  saveRDS(cs_prepandemic,  file.path(DATA_DIR, "cs_prepandemic.rds"))
  saveRDS(att_prepandemic, file.path(DATA_DIR, "cs_prepandemic_att.rds"))
  cat("  Saved: cs_prepandemic.rds, cs_prepandemic_att.rds\n")
}
cat("\n")

# ==============================================================================
# SECTION 11: Region heterogeneity
# ==============================================================================

cat("--- Heterogeneity by Census region ---\n")

regions <- unique(panel$region)
region_results <- list()

for (reg in regions) {
  panel_reg <- panel %>% filter(region == reg)
  n_states_reg <- length(unique(panel_reg$state_fips))
  n_treated_reg <- length(unique(panel_reg$state_fips[panel_reg$first_treat > 0]))
  n_never_reg   <- n_states_reg - n_treated_reg

  cat(sprintf("  %s: %d states (%d treated, %d never-treated)\n",
              reg, n_states_reg, n_treated_reg, n_never_reg))

  if (n_treated_reg < 3 || n_never_reg < 2) {
    cat("    SKIPPED: insufficient variation\n")
    next
  }

  cs_reg <- tryCatch({
    att_gt(
      yname       = "pct_with_parents",
      tname       = "year",
      idname      = "state_fips",
      gname       = "first_treat",
      data        = panel_reg,
      control_group = "nevertreated",
      base_period   = "universal",
      print_details = FALSE
    )
  }, error = function(e) {
    cat("    ERROR:", conditionMessage(e), "\n")
    NULL
  })

  if (!is.null(cs_reg)) {
    att_reg <- aggte(cs_reg, type = "simple")
    cat(sprintf("    ATT: %.4f (SE: %.4f)\n",
                att_reg$overall.att, att_reg$overall.se))

    region_results[[reg]] <- list(
      cs_obj    = cs_reg,
      att_obj   = att_reg,
      n_treated = n_treated_reg,
      n_never   = n_never_reg
    )
  }
}

robustness_results$by_region <- region_results
saveRDS(region_results, file.path(DATA_DIR, "region_heterogeneity.rds"))
cat("  Saved: region_heterogeneity.rds\n\n")

# ==============================================================================
# SECTION 12: Summary of all robustness results
# ==============================================================================

cat("========================================================\n")
cat("  ROBUSTNESS SUMMARY\n")
cat("========================================================\n\n")

cat(sprintf("  %-40s %10s %10s\n", "Specification", "ATT", "SE"))
cat(paste(rep("-", 64), collapse = ""), "\n")

# Main result (for comparison)
main_att <- readRDS(file.path(DATA_DIR, "cs_overall_att.rds"))
cat(sprintf("  %-40s %10.4f %10.4f\n",
            "Baseline (MW gap >= $1.00, never-treated)",
            main_att$overall.att, main_att$overall.se))

# Threshold results
for (nm in grep("^threshold_", names(robustness_results), value = TRUE)) {
  r <- robustness_results[[nm]]
  cat(sprintf("  %-40s %10.4f %10.4f\n",
              paste0("Threshold: MW gap >= $", sprintf("%.2f", r$threshold)),
              r$att, r$se))
}

# With controls
if (!is.null(robustness_results$with_controls)) {
  r <- robustness_results$with_controls$att_obj
  cat(sprintf("  %-40s %10.4f %10.4f\n",
              "With controls (unemp, log rent)", r$overall.att, r$overall.se))
}

# Not-yet-treated
if (!is.null(robustness_results$not_yet_treated)) {
  r <- robustness_results$not_yet_treated$att_obj
  cat(sprintf("  %-40s %10.4f %10.4f\n",
              "Not-yet-treated control group", r$overall.att, r$overall.se))
}

# Drop 2021
if (!is.null(robustness_results$no_2021)) {
  r <- robustness_results$no_2021$att_obj
  cat(sprintf("  %-40s %10.4f %10.4f\n",
              "Drop 2021", r$overall.att, r$overall.se))
}

# Pre-pandemic only
if (!is.null(robustness_results$prepandemic)) {
  r <- robustness_results$prepandemic$att_obj
  cat(sprintf("  %-40s %10.4f %10.4f\n",
              "Pre-pandemic (2015-2019)", r$overall.att, r$overall.se))
}

# Placebo
if (!is.null(robustness_results$placebo)) {
  r <- robustness_results$placebo$att_obj
  cat(sprintf("  %-40s %10.4f %10.4f\n",
              "Placebo: pct_other", r$overall.att, r$overall.se))
}

# Dose-response
cat(sprintf("  %-40s %10.4f %10.4f\n",
            "Continuous MW gap (linear)",
            coef(dose_linear)["mw_gap_continuous"],
            se(dose_linear)["mw_gap_continuous"]))

# Region heterogeneity
cat("\n  --- By region ---\n")
for (reg in names(region_results)) {
  r <- region_results[[reg]]
  cat(sprintf("  %-40s %10.4f %10.4f\n",
              paste0("Region: ", reg),
              r$att_obj$overall.att, r$att_obj$overall.se))
}

# Save full robustness bundle
saveRDS(robustness_results, file.path(DATA_DIR, "robustness_results.rds"))
cat("\n  Saved: robustness_results.rds\n")

cat("\n========================================================\n")
cat("  04_robustness.R completed successfully.\n")
cat("========================================================\n")
