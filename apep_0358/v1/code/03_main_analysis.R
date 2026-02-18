## ============================================================================
## 03_main_analysis.R — Callaway & Sant'Anna DiD and TWFE estimates
## Paper: Medicaid Postpartum Coverage Extensions and Provider Supply
## ============================================================================

source("00_packages.R")
library(did)

DATA <- "../data"
RESULTS <- "../data"
dir.create(RESULTS, showWarnings = FALSE)

## ---- 1. Load analysis panel ----
panel <- readRDS(file.path(DATA, "panel_analysis.rds"))
cat(sprintf("Analysis panel: %d rows, %d states, %d months\n",
            nrow(panel), uniqueN(panel$state), uniqueN(panel$month_date)))

## ---- 2. Callaway & Sant'Anna (2021) ----
# The `did` package requires:
#   yname: outcome variable name
#   tname: time period name (integer)
#   idname: unit identifier name
#   gname: treatment cohort (0 for never-treated)
#   data: data.frame

panel_df <- as.data.frame(panel)

# Set seed for reproducibility of bootstrap inference
set.seed(20240101)

# 2a. Primary outcome: Log postpartum claims
cat("\n=== CS-DiD: Log Postpartum Claims (59430) ===\n")
cs_pp_claims <- att_gt(
  yname  = "ln_claims_pp",
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
cat("Group-time ATTs computed.\n")

# Aggregate to simple ATT
agg_pp_claims <- aggte(cs_pp_claims, type = "simple")
cat(sprintf("ATT (simple): %.4f (SE: %.4f, p: %.4f)\n",
            agg_pp_claims$overall.att,
            agg_pp_claims$overall.se,
            2 * pnorm(-abs(agg_pp_claims$overall.att / agg_pp_claims$overall.se))))

# Dynamic/event-study aggregation
es_pp_claims <- aggte(cs_pp_claims, type = "dynamic",
                       min_e = -24, max_e = 24)
cat("Event-study aggregation computed.\n")

# 2b. Postpartum provider count (extensive margin)
cat("\n=== CS-DiD: Log Postpartum Providers ===\n")
cs_pp_providers <- att_gt(
  yname  = "ln_n_providers_pp",
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

agg_pp_providers <- aggte(cs_pp_providers, type = "simple")
cat(sprintf("ATT (simple): %.4f (SE: %.4f, p: %.4f)\n",
            agg_pp_providers$overall.att,
            agg_pp_providers$overall.se,
            2 * pnorm(-abs(agg_pp_providers$overall.att / agg_pp_providers$overall.se))))

es_pp_providers <- aggte(cs_pp_providers, type = "dynamic",
                          min_e = -24, max_e = 24)

# 2c. Contraceptive claims
cat("\n=== CS-DiD: Log Contraceptive Claims ===\n")
cs_contra <- att_gt(
  yname  = "ln_claims_contra",
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

agg_contra <- aggte(cs_contra, type = "simple")
cat(sprintf("ATT (simple): %.4f (SE: %.4f, p: %.4f)\n",
            agg_contra$overall.att,
            agg_contra$overall.se,
            2 * pnorm(-abs(agg_contra$overall.att / agg_contra$overall.se))))

es_contra <- aggte(cs_contra, type = "dynamic", min_e = -24, max_e = 24)

# 2d. OB/GYN extensive margin (any Medicaid billing)
cat("\n=== CS-DiD: Log OB/GYN Providers Billing Medicaid ===\n")
cs_obgyn <- att_gt(
  yname  = "ln_n_obgyn",
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

agg_obgyn <- aggte(cs_obgyn, type = "simple")
cat(sprintf("ATT (simple): %.4f (SE: %.4f, p: %.4f)\n",
            agg_obgyn$overall.att,
            agg_obgyn$overall.se,
            2 * pnorm(-abs(agg_obgyn$overall.att / agg_obgyn$overall.se))))

es_obgyn <- aggte(cs_obgyn, type = "dynamic", min_e = -24, max_e = 24)

## ---- 3. TWFE robustness ----
cat("\n=== TWFE Regressions (robustness) ===\n")

# TWFE: Postpartum claims
twfe_pp <- feols(ln_claims_pp ~ treated + phe | state_id + time_period,
                  data = panel, cluster = ~state_id)
cat("TWFE — Log Postpartum Claims:\n")
print(summary(twfe_pp))

# TWFE: Postpartum providers
twfe_providers <- feols(ln_n_providers_pp ~ treated + phe | state_id + time_period,
                         data = panel, cluster = ~state_id)
cat("TWFE — Log Postpartum Providers:\n")
print(summary(twfe_providers))

# TWFE: Contraceptive claims
twfe_contra <- feols(ln_claims_contra ~ treated + phe | state_id + time_period,
                      data = panel, cluster = ~state_id)
cat("TWFE — Log Contraceptive Claims:\n")
print(summary(twfe_contra))

# TWFE: OB/GYN extensive margin
twfe_obgyn <- feols(ln_n_obgyn ~ treated + phe | state_id + time_period,
                     data = panel, cluster = ~state_id)
cat("TWFE — Log OB/GYN Providers:\n")
print(summary(twfe_obgyn))

## ---- 4. Post-PHE only specification (preferred) ----
cat("\n=== Post-PHE Only (April 2023+) ===\n")
# This is the cleanest specification: postpartum extension creates NEW coverage
# only after the PHE continuous enrollment ends

# For CS-DiD on post-PHE adopters only
panel_post_phe <- panel[month_date >= as.Date("2020-01-01")]  # Keep some pre-period
# Re-code cohorts: states that adopted before April 2023 are "already treated"
# Focus on variation from post-PHE adopters vs. not-yet-treated
panel_post_phe_df <- as.data.frame(panel_post_phe)

# TWFE on post-PHE subsample
twfe_pp_post <- feols(ln_claims_pp ~ treated | state_id + time_period,
                       data = panel[month_date >= as.Date("2023-04-01")],
                       cluster = ~state_id)
cat("TWFE — Post-PHE Only, Log Postpartum Claims:\n")
print(summary(twfe_pp_post))

## ---- 5. Triple-difference: postpartum vs. antepartum ----
cat("\n=== Triple Difference: Postpartum vs Antepartum ===\n")

# Create stacked panel with postpartum and antepartum outcomes
triple_panel <- rbind(
  panel[, .(state, state_id, month_date, time_period, cohort, treated, phe,
            post_phe, population,
            ln_claims = ln_claims_pp,
            postpartum_ind = 1L)],
  panel[, .(state, state_id, month_date, time_period, cohort, treated, phe,
            post_phe, population,
            ln_claims = ln_claims_ante,
            postpartum_ind = 0L)]
)

# Triple-diff: treatment × postpartum_ind
twfe_triple <- feols(
  ln_claims ~ treated:i(postpartum_ind) + phe:i(postpartum_ind) |
    state_id^postpartum_ind + time_period^postpartum_ind,
  data = triple_panel, cluster = ~state_id
)
cat("Triple-Diff (Postpartum vs. Antepartum):\n")
print(summary(twfe_triple))

## ---- 6. Cohort heterogeneity ----
cat("\n=== Cohort-Specific Effects ===\n")
es_by_cohort <- aggte(cs_pp_claims, type = "group")
cat("Group-specific ATTs:\n")
print(summary(es_by_cohort))

## ---- 7. Save results ----
results <- list(
  cs_pp_claims    = cs_pp_claims,
  cs_pp_providers = cs_pp_providers,
  cs_contra       = cs_contra,
  cs_obgyn        = cs_obgyn,
  agg_pp_claims    = agg_pp_claims,
  agg_pp_providers = agg_pp_providers,
  agg_contra       = agg_contra,
  agg_obgyn        = agg_obgyn,
  es_pp_claims    = es_pp_claims,
  es_pp_providers = es_pp_providers,
  es_contra       = es_contra,
  es_obgyn        = es_obgyn,
  twfe_pp         = twfe_pp,
  twfe_providers  = twfe_providers,
  twfe_contra     = twfe_contra,
  twfe_obgyn      = twfe_obgyn,
  twfe_pp_post    = twfe_pp_post,
  twfe_triple     = twfe_triple,
  es_by_cohort    = es_by_cohort
)

saveRDS(results, file.path(RESULTS, "main_results.rds"))
cat("\n=== Main analysis complete. Results saved. ===\n")
