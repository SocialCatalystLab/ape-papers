# ==============================================================================
# 07_revision_robustness.R
# State Minimum Wage Increases and Young Adult Household Formation
# Purpose: Revision robustness analyses requested by reviewers
#   1. Population-weighted CS-DiD
#   2. Leave-one-cohort-out analysis
#   3. Exclude local-minimum-wage states
#   4. Unemployment balance test (negative control)
#   5. Joint pre-trend Wald test
#   6. Minimum detectable effect (MDE) calculation
# ==============================================================================

source("code/00_packages.R")

cat("\n========================================================\n")
cat("  07_revision_robustness.R: Revision robustness analyses\n")
cat("========================================================\n\n")

# ==============================================================================
# Load data and main results
# ==============================================================================

cat("--- Loading data ---\n")

panel <- read.csv(file.path(DATA_DIR, "analysis_panel.csv"),
                  stringsAsFactors = FALSE)
cat("  Panel:", nrow(panel), "obs,", length(unique(panel$state_fips)), "states,",
    length(unique(panel$year)), "years\n")

# Load main CS results for comparison
cs_out      <- readRDS(file.path(DATA_DIR, "cs_out.rds"))
es          <- readRDS(file.path(DATA_DIR, "cs_event_study.rds"))
main_att    <- readRDS(file.path(DATA_DIR, "cs_overall_att.rds"))
cat("  Main ATT:", sprintf("%.4f (SE: %.4f)", main_att$overall.att, main_att$overall.se), "\n\n")

# ==============================================================================
# SECTION 1: Population-weighted CS-DiD
# ==============================================================================

cat("--- (1) Population-weighted CS-DiD ---\n")

pop_weighted_cs <- tryCatch({
  att_gt(
    yname         = "pct_with_parents",
    tname         = "year",
    idname        = "state_fips",
    gname         = "first_treat",
    weightsname   = "ya_total",
    data          = panel,
    control_group = "nevertreated",
    base_period   = "universal",
    print_details = FALSE
  )
}, error = function(e) {
  cat("  ERROR:", conditionMessage(e), "\n")
  NULL
})

if (!is.null(pop_weighted_cs)) {
  pop_weighted_att <- aggte(pop_weighted_cs, type = "simple")

  cat(sprintf("  Population-weighted ATT: %.4f (SE: %.4f)\n",
              pop_weighted_att$overall.att, pop_weighted_att$overall.se))
  pval_pw <- 2 * pnorm(-abs(pop_weighted_att$overall.att / pop_weighted_att$overall.se))
  cat(sprintf("  p-value: %.4f\n", pval_pw))
  cat(sprintf("  Comparison — Unweighted ATT: %.4f (SE: %.4f)\n",
              main_att$overall.att, main_att$overall.se))

  saveRDS(pop_weighted_att, file.path(DATA_DIR, "pop_weighted_att.rds"))
  cat("  Saved: pop_weighted_att.rds\n")
} else {
  pop_weighted_att <- NULL
  cat("  SKIPPED: population-weighted CS-DiD failed.\n")
}
cat("\n")

# ==============================================================================
# SECTION 2: Leave-one-cohort-out analysis
# ==============================================================================

cat("--- (2) Leave-one-cohort-out analysis ---\n")

# Identify treatment cohorts
cohorts <- sort(unique(panel$first_treat[panel$first_treat > 0]))
cat("  Treatment cohorts:", paste(cohorts, collapse = ", "), "\n")

loco_results <- data.frame(
  dropped_cohort      = integer(),
  n_remaining_treated = integer(),
  att                 = numeric(),
  se                  = numeric(),
  stringsAsFactors    = FALSE
)

for (g in cohorts) {
  # States in this cohort
  cohort_states <- unique(panel$state_fips[panel$first_treat == g])
  cat(sprintf("  Dropping cohort %d (%d states)...", g, length(cohort_states)))

  # Drop these states entirely
  panel_loco <- panel %>% filter(!(state_fips %in% cohort_states))

  n_remaining_treated <- length(unique(panel_loco$state_fips[panel_loco$first_treat > 0]))
  n_remaining_never   <- length(unique(panel_loco$state_fips[panel_loco$first_treat == 0]))

  if (n_remaining_treated < 3 || n_remaining_never < 2) {
    cat(" SKIPPED (insufficient variation)\n")
    next
  }

  cs_loco <- tryCatch({
    att_gt(
      yname         = "pct_with_parents",
      tname         = "year",
      idname        = "state_fips",
      gname         = "first_treat",
      data          = panel_loco,
      control_group = "nevertreated",
      base_period   = "universal",
      print_details = FALSE
    )
  }, error = function(e) {
    cat(sprintf(" ERROR: %s\n", conditionMessage(e)))
    NULL
  })

  if (!is.null(cs_loco)) {
    att_loco <- aggte(cs_loco, type = "simple")
    cat(sprintf(" ATT: %.4f (SE: %.4f), remaining treated: %d\n",
                att_loco$overall.att, att_loco$overall.se, n_remaining_treated))

    loco_results <- rbind(loco_results, data.frame(
      dropped_cohort      = g,
      n_remaining_treated = n_remaining_treated,
      att                 = att_loco$overall.att,
      se                  = att_loco$overall.se,
      stringsAsFactors    = FALSE
    ))
  }
}

cat("\n  Leave-one-cohort-out summary:\n")
cat(sprintf("  %-15s %20s %10s %10s\n", "Dropped Cohort", "Remaining Treated", "ATT", "SE"))
cat(paste(rep("-", 58), collapse = ""), "\n")
cat(sprintf("  %-15s %20s %10.4f %10.4f\n",
            "None (baseline)", "",
            main_att$overall.att, main_att$overall.se))
for (i in seq_len(nrow(loco_results))) {
  cat(sprintf("  %-15d %20d %10.4f %10.4f\n",
              loco_results$dropped_cohort[i],
              loco_results$n_remaining_treated[i],
              loco_results$att[i],
              loco_results$se[i]))
}

saveRDS(loco_results, file.path(DATA_DIR, "leave_one_cohort_out.rds"))
cat("  Saved: leave_one_cohort_out.rds\n\n")

# ==============================================================================
# SECTION 3: Exclude local-minimum-wage states
# ==============================================================================

cat("--- (3) Exclude local-minimum-wage states ---\n")

# States with prominent local (city/county) minimum wages
local_mw_fips <- c(6, 53, 36, 8, 41)  # CA, WA, NY, CO, OR
local_mw_abbr <- c("CA", "WA", "NY", "CO", "OR")
cat("  Dropping:", paste(local_mw_abbr, collapse = ", "), "\n")

panel_no_local <- panel %>% filter(!(state_fips %in% local_mw_fips))

n_treated_noloc <- length(unique(panel_no_local$state_fips[panel_no_local$first_treat > 0]))
n_never_noloc   <- length(unique(panel_no_local$state_fips[panel_no_local$first_treat == 0]))
cat(sprintf("  Remaining: %d states (%d treated, %d never-treated)\n",
            length(unique(panel_no_local$state_fips)), n_treated_noloc, n_never_noloc))

cs_no_local <- tryCatch({
  att_gt(
    yname         = "pct_with_parents",
    tname         = "year",
    idname        = "state_fips",
    gname         = "first_treat",
    data          = panel_no_local,
    control_group = "nevertreated",
    base_period   = "universal",
    print_details = FALSE
  )
}, error = function(e) {
  cat("  ERROR:", conditionMessage(e), "\n")
  NULL
})

if (!is.null(cs_no_local)) {
  no_local_mw_att <- aggte(cs_no_local, type = "simple")
  cat(sprintf("  ATT (excl. local-MW states): %.4f (SE: %.4f)\n",
              no_local_mw_att$overall.att, no_local_mw_att$overall.se))
  pval_noloc <- 2 * pnorm(-abs(no_local_mw_att$overall.att / no_local_mw_att$overall.se))
  cat(sprintf("  p-value: %.4f\n", pval_noloc))
  cat(sprintf("  Comparison — Baseline ATT: %.4f (SE: %.4f)\n",
              main_att$overall.att, main_att$overall.se))

  saveRDS(no_local_mw_att, file.path(DATA_DIR, "no_local_mw_att.rds"))
  cat("  Saved: no_local_mw_att.rds\n")
} else {
  no_local_mw_att <- NULL
  cat("  SKIPPED: CS-DiD without local-MW states failed.\n")
}
cat("\n")

# ==============================================================================
# SECTION 4: Unemployment balance test (negative control)
# ==============================================================================

cat("--- (4) Unemployment balance test (negative control) ---\n")

# Check if unemployment_rate is available in the panel
has_unemp <- sum(!is.na(panel$unemployment_rate)) > 0

# If unemployment_rate is all NA, try to fetch from BLS LAUS API
if (!has_unemp) {
  cat("  unemployment_rate is all NA in panel. Attempting BLS LAUS fetch...\n")

  panel_years <- sort(unique(panel$year))
  panel_fips  <- sort(unique(panel$state_fips))

  # Use BLS public API v2 (POST)
  bls_base_url <- "https://api.bls.gov/publicAPI/v2/timeseries/data/"

  fetch_bls_batch <- function(series_ids, start_year, end_year) {
    payload <- list(
      seriesid  = series_ids,
      startyear = as.character(start_year),
      endyear   = as.character(end_year)
    )
    tryCatch({
      response <- httr::POST(
        bls_base_url,
        body = jsonlite::toJSON(payload, auto_unbox = TRUE),
        httr::content_type_json(),
        httr::timeout(60)
      )
      parsed <- jsonlite::fromJSON(httr::content(response, as = "text", encoding = "UTF-8"))
      if (parsed$status == "REQUEST_SUCCEEDED") return(parsed$Results$series)
      NULL
    }, error = function(e) {
      cat("    BLS API error:", conditionMessage(e), "\n")
      NULL
    })
  }

  # Build LAUS series IDs for state-level unemployment rate
  laus_series <- paste0("LASST", sprintf("%02d", panel_fips), "0000000000003")
  yr_min <- min(panel_years)
  yr_max <- max(panel_years)

  # BLS public API (no key) limits: 25 series per request, 10-year span
  # But empirically, smaller batches (10) are more reliable
  unemp_rows <- list()
  batch_size <- 10

  for (i in seq(1, length(laus_series), by = batch_size)) {
    batch_end <- min(i + batch_size - 1, length(laus_series))
    batch_ids <- laus_series[i:batch_end]
    cat(sprintf("    Fetching BLS batch %d-%d of %d...\n",
                i, batch_end, length(laus_series)))

    batch_result <- fetch_bls_batch(batch_ids, yr_min, yr_max)

    if (!is.null(batch_result)) {
      n_series_returned <- if (is.data.frame(batch_result)) nrow(batch_result) else 0
      cat(sprintf("      Got %d series.\n", n_series_returned))
      for (j in seq_len(n_series_returned)) {
        sid  <- batch_result$seriesID[j]
        drows <- batch_result$data[[j]]
        if (is.null(drows) || nrow(drows) == 0) next
        fips_val <- as.integer(substr(sid, 6, 7))
        # Keep annual averages (M13) or compute from monthly if M13 not available
        annual_rows <- drows %>% filter(period == "M13")
        if (nrow(annual_rows) == 0) {
          # Compute annual average from monthly data
          annual_rows <- drows %>%
            filter(grepl("^M[0-9]{2}$", period), period != "M13") %>%
            mutate(year = as.integer(year), value = as.numeric(value)) %>%
            group_by(year) %>%
            summarise(value = mean(value, na.rm = TRUE), .groups = "drop") %>%
            mutate(period = "M13")
        }
        annual <- annual_rows %>%
          transmute(
            state_fips     = fips_val,
            year           = as.integer(year),
            unemp_rate_bls = as.numeric(value)
          )
        unemp_rows[[length(unemp_rows) + 1]] <- annual
      }
    } else {
      cat("      No data returned.\n")
    }
    Sys.sleep(2)  # Conservative rate limiting
  }

  if (length(unemp_rows) > 0) {
    unemp_bls <- bind_rows(unemp_rows) %>%
      filter(year %in% panel_years) %>%
      arrange(state_fips, year)
    cat(sprintf("  Fetched %d BLS unemployment records.\n", nrow(unemp_bls)))

    # Merge into panel
    panel <- panel %>%
      left_join(unemp_bls, by = c("state_fips", "year")) %>%
      mutate(unemployment_rate = ifelse(is.na(unemployment_rate),
                                        unemp_rate_bls,
                                        unemployment_rate)) %>%
      select(-unemp_rate_bls)

    has_unemp <- sum(!is.na(panel$unemployment_rate)) > 0
    cat(sprintf("  Non-missing unemployment_rate after merge: %d\n",
                sum(!is.na(panel$unemployment_rate))))
  } else {
    cat("  BLS API returned no data.\n")
  }
}

# Now run balance test if we have data
panel_unemp <- panel %>% filter(!is.na(unemployment_rate))
cat(sprintf("  Observations with non-missing unemployment_rate: %d\n", nrow(panel_unemp)))

unemployment_balance <- NULL

if (nrow(panel_unemp) > 0 && length(unique(panel_unemp$unemployment_rate)) > 1) {
  # TWFE regression: unemployment_rate ~ treated | state_fips + year
  # This is a balance test: MW treatment should not mechanically predict
  # unemployment changes if our identification is sound
  unemp_model <- tryCatch({
    feols(unemployment_rate ~ treated | state_fips + year,
          data    = panel_unemp,
          cluster = ~state_fips)
  }, error = function(e) {
    cat("  ERROR:", conditionMessage(e), "\n")
    NULL
  })

  if (!is.null(unemp_model)) {
    coef_unemp <- coef(unemp_model)["treated"]
    se_unemp   <- se(unemp_model)["treated"]
    pval_unemp <- fixest::pvalue(unemp_model)["treated"]

    cat(sprintf("  TWFE: unemployment_rate ~ treated | state + year\n"))
    cat(sprintf("    Coefficient: %.4f\n", coef_unemp))
    cat(sprintf("    SE:          %.4f\n", se_unemp))
    cat(sprintf("    p-value:     %.4f\n", pval_unemp))
    cat(sprintf("    N:           %d\n", nobs(unemp_model)))

    if (pval_unemp > 0.05) {
      cat("  => Treatment does NOT predict unemployment changes (p > 0.05).\n")
      cat("     This supports the parallel trends assumption.\n")
    } else {
      cat("  => WARNING: Treatment significantly predicts unemployment (p <= 0.05).\n")
      cat("     Consider potential confounding.\n")
    }

    unemployment_balance <- list(
      model = unemp_model,
      coef  = coef_unemp,
      se    = se_unemp,
      pval  = pval_unemp,
      n     = nobs(unemp_model)
    )

    saveRDS(unemployment_balance, file.path(DATA_DIR, "unemployment_balance.rds"))
    cat("  Saved: unemployment_balance.rds\n")
  }
} else {
  cat("  SKIPPED: unemployment_rate not available or lacks variation.\n")
}
cat("\n")

# ==============================================================================
# SECTION 5: Joint pre-trend Wald test
# ==============================================================================

cat("--- (5) Joint pre-trend Wald test ---\n")

# Extract pre-treatment coefficients from event study
pre_idx_all <- which(es$egt < 0)
cat(sprintf("  All pre-treatment periods: %d (e = %s)\n",
            length(pre_idx_all), paste(es$egt[pre_idx_all], collapse = ", ")))

# Exclude the reference period (e = -1) which has SE = NA or 0
pre_idx <- pre_idx_all[!is.na(es$se.egt[pre_idx_all]) & es$se.egt[pre_idx_all] > 0]
cat(sprintf("  Testable pre-treatment periods: %d (e = %s)\n",
            length(pre_idx), paste(es$egt[pre_idx], collapse = ", ")))

pretrend_wald_test <- NULL

if (length(pre_idx) > 1) {
  tryCatch({
    pre_att <- es$att.egt[pre_idx]
    pre_se  <- es$se.egt[pre_idx]

    # Construct the variance-covariance matrix from the influence function
    # The did package stores IF in inf.function$dynamic.inf.func.e
    # Use IF correlations + reported SEs to build the full V matrix
    V_pre <- NULL

    if (!is.null(es$V.egt)) {
      # Direct V available
      V_pre <- es$V.egt[pre_idx, pre_idx, drop = FALSE]
      cat("  Using V.egt from event study object.\n")
    } else if (!is.null(es$inf.function$dynamic.inf.func.e)) {
      cat("  V.egt is NULL; constructing from influence function + reported SEs...\n")
      inf_mat <- es$inf.function$dynamic.inf.func.e
      inf_pre <- inf_mat[, pre_idx, drop = FALSE]
      n_cl    <- nrow(inf_pre)

      # Compute IF-based V for correlation structure
      inf_c  <- scale(inf_pre, center = TRUE, scale = FALSE)
      V_if   <- (n_cl / (n_cl - 1)) * crossprod(inf_c) / (n_cl^2)
      se_if  <- sqrt(pmax(diag(V_if), 1e-20))

      # Scale so diagonal matches the reported (bootstrap) SEs
      scale_vec <- pre_se / se_if
      D <- diag(scale_vec)
      V_pre <- D %*% V_if %*% D

      cat(sprintf("  Constructed V from %d cluster-level influence functions.\n", n_cl))
      cat(sprintf("  Diagonal check: max |V_diag - SE^2| = %.2e\n",
                  max(abs(diag(V_pre) - pre_se^2))))
    }

    if (!is.null(V_pre) && all(diag(V_pre) > 0)) {
      # Wald statistic: beta' * V^{-1} * beta ~ chi2(k)
      wald_stat <- as.numeric(t(pre_att) %*% solve(V_pre) %*% pre_att)
      wald_df   <- length(pre_att)
      wald_pval <- 1 - pchisq(wald_stat, df = wald_df)

      cat(sprintf("\n  Pre-treatment coefficients:\n"))
      for (j in seq_along(pre_idx)) {
        cat(sprintf("    e = %d: ATT = %.4f (SE = %.4f)\n",
                    es$egt[pre_idx[j]], pre_att[j], pre_se[j]))
      }
      cat(sprintf("\n  Joint Wald test: chi2(%d) = %.4f\n", wald_df, wald_stat))
      cat(sprintf("  p-value: %.4f\n", wald_pval))

      if (wald_pval > 0.10) {
        cat("  => Cannot reject joint null of zero pre-treatment effects (p > 0.10).\n")
        cat("     Pre-trends assumption supported.\n")
      } else if (wald_pval > 0.05) {
        cat("  => Marginal rejection at 10% but not 5%. Pre-trends weakly supported.\n")
      } else {
        cat("  => WARNING: Joint pre-trends test rejects at 5% level.\n")
      }

      pretrend_wald_test <- list(
        stat    = wald_stat,
        df      = wald_df,
        pval    = wald_pval,
        pre_att = pre_att,
        pre_V   = V_pre
      )

      saveRDS(pretrend_wald_test, file.path(DATA_DIR, "pretrend_wald_test.rds"))
      cat("  Saved: pretrend_wald_test.rds\n")
    } else {
      cat("  SKIPPED: Could not construct valid variance-covariance matrix.\n")
    }
  }, error = function(e) {
    cat("  ERROR:", conditionMessage(e), "\n")
    cat("  Wald test could not be computed.\n")
  })
} else {
  cat("  SKIPPED: Insufficient testable pre-periods for Wald test.\n")
}
cat("\n")

# ==============================================================================
# SECTION 6: Minimum Detectable Effect (MDE) calculation
# ==============================================================================

cat("--- (6) Minimum Detectable Effect (MDE) calculation ---\n")

# Use the main ATT SE
main_se <- main_att$overall.se
cat(sprintf("  Main ATT SE: %.4f\n", main_se))

# MDE at 80% power, alpha = 0.05, two-sided
# MDE = SE * (z_{alpha/2} + z_{beta}) = SE * (1.96 + 0.84) = SE * 2.8
z_alpha <- qnorm(0.975)  # 1.96
z_beta  <- qnorm(0.80)   # 0.84
mde_pp  <- main_se * (z_alpha + z_beta)

# Base rate for the outcome
base_rate <- 30.76  # percent
mde_frac  <- mde_pp / base_rate

cat(sprintf("  z_alpha/2 (0.025): %.4f\n", z_alpha))
cat(sprintf("  z_beta (0.80):     %.4f\n", z_beta))
cat(sprintf("  MDE (80%% power, alpha=0.05, two-sided):\n"))
cat(sprintf("    In percentage points: %.4f pp\n", mde_pp))
cat(sprintf("    As fraction of base rate (%.2f%%): %.4f (%.2f%%)\n",
            base_rate, mde_frac, mde_frac * 100))

if (mde_frac > 0.50) {
  cat("  => WARNING: MDE > 50% of base rate. Study may be underpowered.\n")
} else if (mde_frac > 0.20) {
  cat("  => MDE is 20-50% of base rate. Moderate power for meaningful effects.\n")
} else {
  cat("  => MDE < 20% of base rate. Study is well-powered.\n")
}

mde_results <- list(
  main_se    = main_se,
  z_alpha    = z_alpha,
  z_beta     = z_beta,
  mde_pp     = mde_pp,
  base_rate  = base_rate,
  mde_frac   = mde_frac,
  power      = 0.80,
  alpha      = 0.05
)

saveRDS(mde_results, file.path(DATA_DIR, "mde_results.rds"))
cat("  Saved: mde_results.rds\n\n")

# ==============================================================================
# SUMMARY
# ==============================================================================

cat("========================================================\n")
cat("  REVISION ROBUSTNESS SUMMARY\n")
cat("========================================================\n\n")

cat(sprintf("  %-45s %10s %10s\n", "Analysis", "Estimate", "SE"))
cat(paste(rep("-", 68), collapse = ""), "\n")

# Baseline
cat(sprintf("  %-45s %10.4f %10.4f\n",
            "Baseline CS-DiD ATT",
            main_att$overall.att, main_att$overall.se))

# 1. Population-weighted
if (!is.null(pop_weighted_att)) {
  cat(sprintf("  %-45s %10.4f %10.4f\n",
              "(1) Population-weighted CS-DiD",
              pop_weighted_att$overall.att, pop_weighted_att$overall.se))
}

# 2. Leave-one-cohort-out range
if (nrow(loco_results) > 0) {
  cat(sprintf("  %-45s %10s\n",
              "(2) Leave-one-cohort-out ATT range",
              sprintf("[%.4f, %.4f]", min(loco_results$att), max(loco_results$att))))
}

# 3. Exclude local-MW states
if (!is.null(no_local_mw_att)) {
  cat(sprintf("  %-45s %10.4f %10.4f\n",
              "(3) Exclude local-MW states (CA,WA,NY,CO,OR)",
              no_local_mw_att$overall.att, no_local_mw_att$overall.se))
}

# 4. Unemployment balance test
if (!is.null(unemployment_balance)) {
  cat(sprintf("  %-45s %10.4f %10.4f\n",
              "(4) Unemp. balance (coef on treated)",
              unemployment_balance$coef, unemployment_balance$se))
  cat(sprintf("  %-45s %10s\n",
              "    p-value",
              sprintf("%.4f", unemployment_balance$pval)))
}

# 5. Wald test
if (!is.null(pretrend_wald_test)) {
  cat(sprintf("  %-45s %10s\n",
              "(5) Pre-trend Wald chi2",
              sprintf("%.4f (df=%d)", pretrend_wald_test$stat, pretrend_wald_test$df)))
  cat(sprintf("  %-45s %10s\n",
              "    p-value",
              sprintf("%.4f", pretrend_wald_test$pval)))
}

# 6. MDE
cat(sprintf("  %-45s %10s\n",
            "(6) MDE (80% power, pp)",
            sprintf("%.4f pp", mde_results$mde_pp)))
cat(sprintf("  %-45s %10s\n",
            "    As fraction of base rate",
            sprintf("%.2f%%", mde_results$mde_frac * 100)))

cat("\n========================================================\n")
cat("  07_revision_robustness.R completed successfully.\n")
cat("========================================================\n")
