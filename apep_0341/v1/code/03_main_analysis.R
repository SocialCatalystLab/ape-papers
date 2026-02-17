## ============================================================================
## 03_main_analysis.R — Primary DiD estimation
## apep_0328: Medicaid Reimbursement Rates and HCBS Provider Supply
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
  twfe_prov_ctrl <- twfe_providers  # Use uncontrolled as fallback
  twfe_bene_ctrl <- twfe_benes
}

## ---- 4. Callaway-Sant'Anna (2021) ----
cat("\n=== Callaway-Sant'Anna DiD ===\n")

## Use quarterly aggregation — monthly has too many time periods for CS-DiD
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

## Balance the panel: keep only states present in all quarters
state_counts <- panel_q[, .N, by = state_id]
max_q <- max(state_counts$N)
balanced_ids <- state_counts[N == max_q, state_id]
panel_q_bal <- panel_q[state_id %in% balanced_ids]

cat(sprintf("Balanced quarterly panel: %d states, %d quarters\n",
            uniqueN(panel_q_bal$state_id), uniqueN(panel_q_bal$quarter_num)))

## Merge early cohorts to reduce small-group issues
## Cohorts with first_treat_q <= 3 get merged into cohort 3
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

## ---- 5. Sun-Abraham event study (sensitivity check) ----
cat("\n=== Sun-Abraham Event Study ===\n")

## Need relative time variable
panel[, rel_time := ifelse(first_treat == 0, -1000,
                           time_period - first_treat)]

sa_providers <- feols(log_providers ~ sunab(first_treat, time_period) |
                        state + time_period,
                      data = panel[first_treat > 0 | first_treat == 0],
                      cluster = ~state)

cat("Sun-Abraham event study estimated.\n")

## ---- 6. Dose-response (treatment intensity) ----
cat("\n=== Dose-Response Analysis ===\n")

## pct_change already in panel from 02_clean_data.R merge
## Exclude Wyoming outlier (1,422% increase) from dose-response
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

## ---- 7. Save results ----
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
  att_overall_benes  = if (exists("att_overall_benes")) att_overall_benes else NULL
)
saveRDS(results, file.path(DATA, "main_results.rds"))

cat("\n=== Main analysis complete ===\n")
