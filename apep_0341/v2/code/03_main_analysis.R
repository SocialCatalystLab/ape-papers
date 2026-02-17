## ============================================================================
## 03_main_analysis.R — Primary DiD estimation
## apep_0341 v2: Medicaid Reimbursement Rates and HCBS Provider Supply
## ============================================================================

source("00_packages.R")

## ---- 1. Load data ----
panel    <- readRDS(file.path(DATA, "did_panel_pc.rds"))
rc       <- readRDS(file.path(DATA, "rate_changes.rds"))
month_map <- readRDS(file.path(DATA, "month_map.rds"))

cat(sprintf("Panel: %d obs, %d states, %d time periods\n",
            nrow(panel), uniqueN(panel$state), uniqueN(panel$time_period)))
cat(sprintf("Treated: %d states, Never-treated: %d states\n",
            sum(rc$treated), sum(!rc$treated)))

## ---- 2. TWFE Baseline ----
cat("\n=== TWFE Estimates ===\n")

## Binary treatment indicator
panel[, post_treat := as.integer(treated == TRUE & month_date >= treat_date)]

## TWFE with state + month FEs, clustered at state level
twfe_providers <- feols(log_providers ~ post_treat | state + time_period,
                        data = panel, cluster = ~state)

twfe_claims <- feols(log_claims ~ post_treat | state + time_period,
                     data = panel, cluster = ~state)

twfe_benes <- feols(log_benes ~ post_treat | state + time_period,
                    data = panel, cluster = ~state)

twfe_paid <- feols(log_paid ~ post_treat | state + time_period,
                   data = panel, cluster = ~state)

cat("\nTWFE Results:\n")
cat(sprintf("  log(providers): %.4f (SE=%.4f, p=%.4f)\n",
            coef(twfe_providers)["post_treat"],
            se(twfe_providers)["post_treat"],
            pvalue(twfe_providers)["post_treat"]))
cat(sprintf("  log(claims):    %.4f (SE=%.4f, p=%.4f)\n",
            coef(twfe_claims)["post_treat"],
            se(twfe_claims)["post_treat"],
            pvalue(twfe_claims)["post_treat"]))
cat(sprintf("  log(benes):     %.4f (SE=%.4f, p=%.4f)\n",
            coef(twfe_benes)["post_treat"],
            se(twfe_benes)["post_treat"],
            pvalue(twfe_benes)["post_treat"]))
cat(sprintf("  log(paid):      %.4f (SE=%.4f, p=%.4f)\n",
            coef(twfe_paid)["post_treat"],
            se(twfe_paid)["post_treat"],
            pvalue(twfe_paid)["post_treat"]))

## ---- 2b. v2: Wild cluster bootstrap p-values ----
cat("\n=== Wild Cluster Bootstrap p-values ===\n")

## fwildclusterboot v0.14+ has compatibility issues with feols objects.
## Workaround: fit equivalent lm() models with explicit FE dummies for WCB only.
panel_wcb <- copy(panel)
panel_wcb[, state_f := factor(state)]
panel_wcb[, tp_f := factor(time_period)]

set.seed(20260217)  # Reproducibility seed for bootstrap inference
run_wcb <- function(outcome, label) {
  fml <- as.formula(paste0(outcome, " ~ post_treat + state_f + tp_f"))
  mod_lm <- lm(fml, data = panel_wcb)
  bt <- tryCatch({
    boottest(mod_lm, param = "post_treat", clustid = c("state_f"),
             B = 9999, type = "webb")
  }, error = function(e) { cat("WCB", label, "error:", conditionMessage(e), "\n"); NULL })
  if (!is.null(bt)) cat(sprintf("  WCB p-value (%s): %.4f\n", label, bt$p_val))
  bt
}

wcb_providers <- run_wcb("log_providers", "providers")
wcb_claims    <- run_wcb("log_claims", "claims")
wcb_benes     <- run_wcb("log_benes", "benes")
wcb_paid      <- run_wcb("log_paid", "paid")

## ---- 3. TWFE with controls (if available) ----
has_controls <- any(!is.na(panel$pop)) && any(!is.na(panel$unemp_rate))

if (has_controls) {
  twfe_prov_ctrl <- feols(log_providers ~ post_treat + unemp_rate + log(pop) |
                            state + time_period,
                          data = panel[!is.na(pop) & !is.na(unemp_rate)],
                          cluster = ~state)
  twfe_bene_ctrl <- feols(log_benes ~ post_treat + unemp_rate + log(pop) |
                            state + time_period,
                          data = panel[!is.na(pop) & !is.na(unemp_rate)],
                          cluster = ~state)
} else {
  cat("Controls unavailable — skipping controlled regressions.\n")
  twfe_prov_ctrl <- twfe_providers
  twfe_bene_ctrl <- twfe_benes
}

## ---- 4. Callaway-Sant'Anna (2021) ----
cat("\n=== Callaway-Sant'Anna DiD ===\n")

## Use quarterly aggregation
panel[, quarter_num := (year - 2018) * 4 + ceiling(month_num / 3)]

panel_q <- panel[, .(
  log_providers = log(mean(n_providers) + 1),
  log_claims    = log(sum(total_claims) + 1),
  log_benes     = log(mean(total_benes) + 1),
  n_providers   = mean(n_providers),
  total_claims  = sum(total_claims),
  total_benes   = mean(total_benes)
), by = .(state, state_id, quarter_num, first_treat, treated)]

## Convert first_treat to quarterly
panel_q[, first_treat_q := ifelse(first_treat == 0, 0,
                                   ceiling(first_treat / 3))]

## Balance the panel
state_counts <- panel_q[, .N, by = state_id]
max_q <- max(state_counts$N)
balanced_ids <- state_counts[N == max_q, state_id]
panel_q_bal <- panel_q[state_id %in% balanced_ids]

cat(sprintf("Balanced quarterly panel: %d states, %d quarters\n",
            uniqueN(panel_q_bal$state_id), uniqueN(panel_q_bal$quarter_num)))

## Merge early cohorts
panel_q_bal[, first_treat_merged := ifelse(first_treat_q > 0 & first_treat_q <= 3,
                                            3L, first_treat_q)]

## Run CS-DiD for provider counts
cs_providers <- tryCatch(
  att_gt(
    yname       = "log_providers",
    tname       = "quarter_num",
    idname      = "state_id",
    gname       = "first_treat_merged",
    data        = as.data.frame(panel_q_bal),
    control_group = "nevertreated",
    anticipation  = 0,
    base_period   = "universal"
  ),
  error = function(e) {
    cat("CS-DiD error:", conditionMessage(e), "\n")
    NULL
  }
)

if (!is.null(cs_providers)) {
  att_overall_prov <- aggte(cs_providers, type = "simple")
  cat(sprintf("\nCS-DiD Overall ATT (log providers): %.4f (SE=%.4f)\n",
              att_overall_prov$overall.att, att_overall_prov$overall.se))
  es_providers <- tryCatch(
    aggte(cs_providers, type = "dynamic", min_e = -8, max_e = 8),
    error = function(e) { cat("ES aggregation error\n"); NULL }
  )
  if (!is.null(es_providers)) cat("CS-DiD event study (providers) computed.\n")
}

## CS-DiD for claims
cs_claims <- tryCatch(
  att_gt(
    yname       = "log_claims",
    tname       = "quarter_num",
    idname      = "state_id",
    gname       = "first_treat_merged",
    data        = as.data.frame(panel_q_bal),
    control_group = "nevertreated",
    anticipation  = 0,
    base_period   = "universal"
  ),
  error = function(e) { cat("CS-DiD claims error:", conditionMessage(e), "\n"); NULL }
)

if (!is.null(cs_claims)) {
  att_overall_claims <- aggte(cs_claims, type = "simple")
  cat(sprintf("CS-DiD Overall ATT (log claims): %.4f (SE=%.4f)\n",
              att_overall_claims$overall.att, att_overall_claims$overall.se))
  es_claims <- tryCatch(
    aggte(cs_claims, type = "dynamic", min_e = -8, max_e = 8),
    error = function(e) { cat("ES claims aggregation error\n"); NULL }
  )
}

## CS-DiD for beneficiaries
cs_benes <- tryCatch(
  att_gt(
    yname       = "log_benes",
    tname       = "quarter_num",
    idname      = "state_id",
    gname       = "first_treat_merged",
    data        = as.data.frame(panel_q_bal),
    control_group = "nevertreated",
    anticipation  = 0,
    base_period   = "universal"
  ),
  error = function(e) { cat("CS-DiD benes error:", conditionMessage(e), "\n"); NULL }
)

if (!is.null(cs_benes)) {
  att_overall_benes <- aggte(cs_benes, type = "simple")
  cat(sprintf("CS-DiD Overall ATT (log benes): %.4f (SE=%.4f)\n",
              att_overall_benes$overall.att, att_overall_benes$overall.se))
  es_benes <- tryCatch(
    aggte(cs_benes, type = "dynamic", min_e = -8, max_e = 8),
    error = function(e) { cat("ES benes aggregation error\n"); NULL }
  )
}

## ---- 4b. v2: Formal pre-trend joint test from CS-DiD ----
cat("\n=== CS-DiD Pre-Trend Test ===\n")
if (!is.null(es_providers)) {
  pre_att <- es_providers$att.egt[es_providers$egt < 0]
  pre_se  <- es_providers$se.egt[es_providers$egt < 0]
  if (length(pre_att) > 0 && all(!is.na(pre_se)) && all(pre_se > 0)) {
    chi2_stat <- sum((pre_att / pre_se)^2)
    df_pre <- length(pre_att)
    pre_pval <- 1 - pchisq(chi2_stat, df = df_pre)
    cat(sprintf("Joint pre-trend test: chi2(%d) = %.2f, p = %.4f\n",
                df_pre, chi2_stat, pre_pval))
  }
}

## ---- 5. Sun-Abraham event study (sensitivity check) ----
cat("\n=== Sun-Abraham Event Study ===\n")

panel[, rel_time := ifelse(first_treat == 0, -1000,
                           time_period - first_treat)]

sa_providers <- feols(log_providers ~ sunab(first_treat, time_period) |
                        state + time_period,
                      data = panel[first_treat > 0 | first_treat == 0],
                      cluster = ~state)

cat("Sun-Abraham event study estimated.\n")

## ---- 6. Dose-response (treatment intensity) ----
cat("\n=== Dose-Response Analysis ===\n")

## Exclude Wyoming outlier
panel_dose <- panel[state != "WY"]
panel_dose[, dose := ifelse(treated == TRUE & !is.na(pct_change), pct_change, 0)]
panel_dose[is.na(dose), dose := 0]
panel_dose[, post_dose := as.integer(treated == TRUE & month_date >= treat_date) * dose]

twfe_dose_prov <- feols(log_providers ~ post_dose | state + time_period,
                        data = panel_dose, cluster = ~state)
twfe_dose_benes <- feols(log_benes ~ post_dose | state + time_period,
                         data = panel_dose, cluster = ~state)

cat(sprintf("Dose-response (log providers): %.4f (SE=%.4f, p=%.4f)\n",
            coef(twfe_dose_prov)["post_dose"],
            se(twfe_dose_prov)["post_dose"],
            pvalue(twfe_dose_prov)["post_dose"]))
cat(sprintf("Dose-response (log benes): %.4f (SE=%.4f, p=%.4f)\n",
            coef(twfe_dose_benes)["post_dose"],
            se(twfe_dose_benes)["post_dose"],
            pvalue(twfe_dose_benes)["post_dose"]))

## ---- 7. v2: ARPA-era subsample analysis ----
cat("\n=== ARPA-Era Subsample Analysis ===\n")

## ARPA cohorts: treated after April 2021
arpa_date <- as.Date("2021-04-01")
arpa_states <- rc[treated == TRUE & treat_date >= arpa_date, state]
pre_arpa_states <- rc[treated == TRUE & treat_date < arpa_date, state]
cat(sprintf("ARPA-era treated: %d states, Pre-ARPA treated: %d states\n",
            length(arpa_states), length(pre_arpa_states)))

## Subsample: ARPA cohorts + never-treated
panel_arpa <- panel[state %in% arpa_states | treated == FALSE]
panel_arpa[, post_treat := as.integer(treated == TRUE & month_date >= treat_date)]

twfe_arpa_prov <- feols(log_providers ~ post_treat | state + time_period,
                        data = panel_arpa, cluster = ~state)
twfe_arpa_benes <- feols(log_benes ~ post_treat | state + time_period,
                         data = panel_arpa, cluster = ~state)

cat(sprintf("ARPA-era TWFE (providers): %.4f (SE=%.4f, p=%.4f)\n",
            coef(twfe_arpa_prov)["post_treat"],
            se(twfe_arpa_prov)["post_treat"],
            pvalue(twfe_arpa_prov)["post_treat"]))
cat(sprintf("ARPA-era TWFE (benes): %.4f (SE=%.4f, p=%.4f)\n",
            coef(twfe_arpa_benes)["post_treat"],
            se(twfe_arpa_benes)["post_treat"],
            pvalue(twfe_arpa_benes)["post_treat"]))

## Pre-ARPA subsample (historical replication)
panel_prearpa <- panel[state %in% pre_arpa_states | treated == FALSE]
panel_prearpa[, post_treat := as.integer(treated == TRUE & month_date >= treat_date)]

twfe_prearpa_prov <- feols(log_providers ~ post_treat | state + time_period,
                           data = panel_prearpa, cluster = ~state)

cat(sprintf("Pre-ARPA TWFE (providers): %.4f (SE=%.4f, p=%.4f)\n",
            coef(twfe_prearpa_prov)["post_treat"],
            se(twfe_prearpa_prov)["post_treat"],
            pvalue(twfe_prearpa_prov)["post_treat"]))

## CS-DiD for ARPA-era subsample
panel_arpa_q <- panel_arpa[, .(
  log_providers = log(mean(n_providers) + 1),
  log_claims    = log(sum(total_claims) + 1),
  log_benes     = log(mean(total_benes) + 1),
  n_providers   = mean(n_providers)
), by = .(state, state_id, quarter_num = (year - 2018) * 4 + ceiling(month_num / 3),
          first_treat, treated)]

panel_arpa_q[, first_treat_q := ifelse(first_treat == 0, 0,
                                        ceiling(first_treat / 3))]
arpa_state_counts <- panel_arpa_q[, .N, by = state_id]
arpa_max_q <- max(arpa_state_counts$N)
arpa_balanced_ids <- arpa_state_counts[N == arpa_max_q, state_id]
panel_arpa_q_bal <- panel_arpa_q[state_id %in% arpa_balanced_ids]

cs_arpa_prov <- tryCatch(
  att_gt(
    yname       = "log_providers",
    tname       = "quarter_num",
    idname      = "state_id",
    gname       = "first_treat_q",
    data        = as.data.frame(panel_arpa_q_bal),
    control_group = "nevertreated",
    anticipation  = 0,
    base_period   = "universal"
  ),
  error = function(e) { cat("CS-DiD ARPA error:", conditionMessage(e), "\n"); NULL }
)

att_arpa_prov <- NULL
if (!is.null(cs_arpa_prov)) {
  att_arpa_prov <- aggte(cs_arpa_prov, type = "simple")
  cat(sprintf("CS-DiD ARPA ATT (log providers): %.4f (SE=%.4f)\n",
              att_arpa_prov$overall.att, att_arpa_prov$overall.se))
}

## ---- 8. v2: Consolidation mechanism tests ----
cat("\n=== Consolidation Mechanism Tests ===\n")

## Test 1: Type 2 (organizational) billing share
panel[, log_org_share := log(org_share + 0.01)]
mech_org_share <- feols(org_share ~ post_treat | state + time_period,
                        data = panel, cluster = ~state)
cat(sprintf("Org share effect: %.4f (SE=%.4f, p=%.4f)\n",
            coef(mech_org_share)["post_treat"],
            se(mech_org_share)["post_treat"],
            pvalue(mech_org_share)["post_treat"]))

## Test 2: Claims per provider (intensive margin)
mech_intensive <- feols(log_claims_per_provider ~ post_treat | state + time_period,
                        data = panel, cluster = ~state)
cat(sprintf("Log claims/provider effect: %.4f (SE=%.4f, p=%.4f)\n",
            coef(mech_intensive)["post_treat"],
            se(mech_intensive)["post_treat"],
            pvalue(mech_intensive)["post_treat"]))

## ---- 9. Save results ----
results <- list(
  twfe_providers   = twfe_providers,
  twfe_claims      = twfe_claims,
  twfe_benes       = twfe_benes,
  twfe_paid        = twfe_paid,
  twfe_prov_ctrl   = twfe_prov_ctrl,
  twfe_bene_ctrl   = twfe_bene_ctrl,
  twfe_dose_prov   = twfe_dose_prov,
  twfe_dose_benes  = twfe_dose_benes,
  sa_providers     = sa_providers,
  cs_providers     = if (exists("cs_providers")) cs_providers else NULL,
  cs_claims        = if (exists("cs_claims")) cs_claims else NULL,
  cs_benes         = if (exists("cs_benes")) cs_benes else NULL,
  es_providers     = if (exists("es_providers")) es_providers else NULL,
  es_claims        = if (exists("es_claims")) es_claims else NULL,
  es_benes         = if (exists("es_benes")) es_benes else NULL,
  att_overall_prov = if (exists("att_overall_prov")) att_overall_prov else NULL,
  att_overall_claims = if (exists("att_overall_claims")) att_overall_claims else NULL,
  att_overall_benes  = if (exists("att_overall_benes")) att_overall_benes else NULL,
  ## v2: Wild cluster bootstrap
  wcb_providers    = if (exists("wcb_providers")) wcb_providers else NULL,
  wcb_claims       = if (exists("wcb_claims")) wcb_claims else NULL,
  wcb_benes        = if (exists("wcb_benes")) wcb_benes else NULL,
  wcb_paid         = if (exists("wcb_paid")) wcb_paid else NULL,
  ## v2: ARPA-era subsample
  twfe_arpa_prov   = twfe_arpa_prov,
  twfe_arpa_benes  = twfe_arpa_benes,
  twfe_prearpa_prov = twfe_prearpa_prov,
  att_arpa_prov    = att_arpa_prov,
  cs_arpa_prov     = if (exists("cs_arpa_prov")) cs_arpa_prov else NULL,
  ## v2: Pre-trend test
  pre_pval         = if (exists("pre_pval")) pre_pval else NA,
  ## v2: Mechanism tests
  mech_org_share   = mech_org_share,
  mech_intensive   = mech_intensive
)
saveRDS(results, file.path(DATA, "main_results.rds"))

cat("\n=== Main analysis complete ===\n")
