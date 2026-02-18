## ============================================================================
## 04_robustness.R — Robustness checks and placebo tests
## Paper: Medicaid Postpartum Coverage Extensions and Provider Supply
## ============================================================================

source("00_packages.R")
library(did)

DATA <- "../data"

## ---- 1. Load data ----
panel   <- readRDS(file.path(DATA, "panel_analysis.rds"))
results <- readRDS(file.path(DATA, "main_results.rds"))

panel_df <- as.data.frame(panel)

# Set seed for reproducibility of bootstrap inference
set.seed(20240201)

## ---- 2. Placebo: Antepartum codes (should NOT respond) ----
cat("\n=== Placebo: Antepartum Claims (59425, 59426) ===\n")
cs_ante <- att_gt(
  yname  = "ln_claims_ante",
  tname  = "time_period",
  idname = "state_id",
  gname  = "cohort",
  data   = panel_df,
  control_group = "notyettreated",
  anticipation  = 0,
  est_method    = "dr",
  bstrap = TRUE,
  cband  = TRUE,
  biters = 1000
)

agg_ante <- aggte(cs_ante, type = "simple")
cat(sprintf("Placebo ATT (antepartum): %.4f (SE: %.4f, p: %.4f)\n",
            agg_ante$overall.att,
            agg_ante$overall.se,
            2 * pnorm(-abs(agg_ante$overall.att / agg_ante$overall.se))))

es_ante <- aggte(cs_ante, type = "dynamic", min_e = -24, max_e = 24)

## ---- 3. Placebo: Delivery codes (should NOT respond) ----
cat("\n=== Placebo: Delivery Claims ===\n")
cs_delivery <- att_gt(
  yname  = "ln_claims_delivery",
  tname  = "time_period",
  idname = "state_id",
  gname  = "cohort",
  data   = panel_df,
  control_group = "notyettreated",
  anticipation  = 0,
  est_method    = "dr",
  bstrap = TRUE,
  cband  = TRUE,
  biters = 1000
)

agg_delivery <- aggte(cs_delivery, type = "simple")
cat(sprintf("Placebo ATT (delivery): %.4f (SE: %.4f, p: %.4f)\n",
            agg_delivery$overall.att,
            agg_delivery$overall.se,
            2 * pnorm(-abs(agg_delivery$overall.att / agg_delivery$overall.se))))

es_delivery <- aggte(cs_delivery, type = "dynamic", min_e = -24, max_e = 24)

## ---- 4. State trends ----
cat("\n=== TWFE with State-Specific Linear Trends ===\n")
panel[, state_trend := state_id * time_period]

twfe_trend_pp <- feols(
  ln_claims_pp ~ treated + phe | state_id + time_period + state_id[time_period],
  data = panel, cluster = ~state_id
)
cat("TWFE with state trends — Log Postpartum Claims:\n")
print(summary(twfe_trend_pp))

twfe_trend_providers <- feols(
  ln_n_providers_pp ~ treated + phe | state_id + time_period + state_id[time_period],
  data = panel, cluster = ~state_id
)
cat("TWFE with state trends — Log Postpartum Providers:\n")
print(summary(twfe_trend_providers))

## ---- 5. Balanced panel restriction ----
cat("\n=== Balanced Panel (states with consistent reporting) ===\n")
# Keep states with non-zero postpartum claims in ≥90% of months
state_coverage <- panel[, .(
  pct_nonzero = mean(claims_postpartum > 0)
), by = state]

balanced_states <- state_coverage[pct_nonzero >= 0.90, state]
cat(sprintf("States with ≥90%% non-zero postpartum months: %d\n", length(balanced_states)))

panel_balanced <- panel[state %in% balanced_states]
panel_balanced_df <- as.data.frame(panel_balanced)

cs_balanced <- att_gt(
  yname  = "ln_claims_pp",
  tname  = "time_period",
  idname = "state_id",
  gname  = "cohort",
  data   = panel_balanced_df,
  control_group = "notyettreated",
  anticipation  = 0,
  est_method    = "dr",
  bstrap = TRUE,
  cband  = TRUE,
  biters = 1000
)

agg_balanced <- aggte(cs_balanced, type = "simple")
cat(sprintf("Balanced panel ATT: %.4f (SE: %.4f, p: %.4f)\n",
            agg_balanced$overall.att,
            agg_balanced$overall.se,
            2 * pnorm(-abs(agg_balanced$overall.att / agg_balanced$overall.se))))

## ---- 6. Randomization inference ----
cat("\n=== Randomization Inference (1000 permutations) ===\n")

# Get observed ATT
obs_att <- results$agg_pp_claims$overall.att

# Permute treatment assignment
set.seed(42)
n_perm <- 1000
perm_atts <- numeric(n_perm)

# Get unique state cohort assignments
state_cohorts <- unique(panel[, .(state_id, cohort)])
treated_states <- state_cohorts[cohort > 0, state_id]
n_treated <- length(treated_states)
all_states <- state_cohorts$state_id

for (i in seq_len(n_perm)) {
  if (i %% 200 == 0) cat(sprintf("  Permutation %d/%d\n", i, n_perm))

  # Randomly assign cohorts to states
  perm_cohorts <- state_cohorts$cohort
  perm_idx <- sample(length(perm_cohorts))
  perm_cohorts <- perm_cohorts[perm_idx]

  panel_perm <- copy(panel_df)
  perm_map <- data.frame(
    state_id = state_cohorts$state_id,
    perm_cohort = perm_cohorts
  )
  panel_perm <- merge(panel_perm, perm_map, by = "state_id")
  panel_perm$cohort <- panel_perm$perm_cohort

  tryCatch({
    cs_perm <- att_gt(
      yname  = "ln_claims_pp",
      tname  = "time_period",
      idname = "state_id",
      gname  = "cohort",
      data   = panel_perm,
      control_group = "notyettreated",
      anticipation  = 0,
      est_method    = "dr",
      bstrap = FALSE,
      cband  = FALSE
    )
    agg_perm <- aggte(cs_perm, type = "simple")
    perm_atts[i] <- agg_perm$overall.att
  }, error = function(e) {
    perm_atts[i] <<- NA
  })
}

perm_atts <- perm_atts[!is.na(perm_atts)]
if (length(perm_atts) > 0) {
  ri_pvalue <- mean(abs(perm_atts) >= abs(obs_att))
} else {
  ri_pvalue <- NA_real_
}
cat(sprintf("RI p-value (two-sided): %.4f (based on %d valid permutations)\n",
            ri_pvalue, length(perm_atts)))

## ---- 7. Honest DiD (Rambachan & Roth 2023) ----
cat("\n=== Honest DiD Sensitivity Analysis ===\n")

tryCatch({
  library(HonestDiD)

  # Extract event-study estimates from CS-DiD
  es_results <- results$es_pp_claims
  es_coefs <- es_results$att.egt
  es_se <- es_results$se.egt
  es_periods <- es_results$egt

  # Find reference period (period -1)
  pre_idx <- which(es_periods < 0)
  post_idx <- which(es_periods >= 0)

  if (length(pre_idx) >= 2 && length(post_idx) >= 1) {
    # Construct variance-covariance matrix
    V <- diag(es_se^2)

    # Run HonestDiD with relative magnitudes
    honest_results <- tryCatch({
      createSensitivityResults_relativeMagnitudes(
        betahat = es_coefs,
        sigma   = V,
        numPrePeriods  = length(pre_idx),
        numPostPeriods = length(post_idx),
        Mbarvec = seq(0, 2, by = 0.5)
      )
    }, error = function(e) {
      cat(sprintf("  HonestDiD error: %s\n", e$message))
      NULL
    })

    if (!is.null(honest_results)) {
      cat("Honest DiD sensitivity results:\n")
      print(honest_results)
    }
  } else {
    cat("  Insufficient pre/post periods for HonestDiD\n")
  }
}, error = function(e) {
  cat(sprintf("  HonestDiD not available: %s\n", e$message))
  cat("  Proceeding without Honest DiD analysis.\n")
})

## ---- 8. Heterogeneity: Medicaid expansion status ----
cat("\n=== Heterogeneity: Medicaid Expansion Status ===\n")
# Non-expansion states (as of data period): TX, WI, WY, MS, AL, GA, SC, TN, SD, NC, KS, FL
non_expansion <- c("TX", "WI", "WY", "MS", "AL", "GA", "SC", "TN", "SD", "NC", "KS", "FL")
panel[, expansion_state := fifelse(!(state %in% non_expansion), 1L, 0L)]

twfe_het_expansion <- feols(
  ln_claims_pp ~ treated * expansion_state + phe | state_id + time_period,
  data = panel, cluster = ~state_id
)
cat("Heterogeneity by Medicaid expansion:\n")
print(summary(twfe_het_expansion))

## ---- 9. Save robustness results ----
robust_results <- list(
  cs_ante        = cs_ante,
  agg_ante       = agg_ante,
  es_ante        = es_ante,
  cs_delivery    = cs_delivery,
  agg_delivery   = agg_delivery,
  es_delivery    = es_delivery,
  twfe_trend_pp  = twfe_trend_pp,
  twfe_trend_providers = twfe_trend_providers,
  agg_balanced   = agg_balanced,
  ri_pvalue      = ri_pvalue,
  perm_atts      = perm_atts,
  obs_att        = obs_att,
  twfe_het_expansion = twfe_het_expansion,
  balanced_states = balanced_states
)

saveRDS(robust_results, file.path(DATA, "robustness_results.rds"))
cat("\n=== Robustness checks complete. Results saved. ===\n")
