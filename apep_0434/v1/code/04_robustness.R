## ============================================================
## 04_robustness.R — Robustness checks, placebos, heterogeneity
## ============================================================

source("code/00_packages.R")

cat("=== Loading analysis data ===\n")
census   <- readRDS("data/census_panel.rds")
nl_dist  <- readRDS("data/nl_district_panel.rds")
results  <- readRDS("data/main_results.rds")

# ============================================================
# 1. Pre-treatment Balance Test
# ============================================================
cat("\n=== 1. Pre-treatment Balance ===\n")

bal_vars <- c("pop_01", "lit_rate_01", "sc_st_share_01",
              "nonfarm_share_01", "aglabor_share_01", "cultivator_share_01",
              "hh_ind_share_01", "wfpr_01")

bal_table <- census[, lapply(.SD, function(x) {
  c(mean_early = mean(x[early_treat == 1], na.rm = TRUE),
    mean_late  = mean(x[early_treat == 0], na.rm = TRUE),
    diff       = mean(x[early_treat == 1], na.rm = TRUE) -
                 mean(x[early_treat == 0], na.rm = TRUE))
}), .SDcols = bal_vars]

cat("  Balance test (Early vs Late treatment):\n")
for (v in bal_vars) {
  vals <- bal_table[[v]]
  cat(sprintf("    %s: Early=%.3f, Late=%.3f, Diff=%.4f\n",
              v, vals[1], vals[2], vals[3]))
}

# ============================================================
# 2. Placebo Outcome: Population Growth
# ============================================================
cat("\n=== 2. Placebo: Population Growth ===\n")

# Population growth should not be affected by MGNREGA assignment
# (it's driven by demographics, not employment policy)
m_placebo_pop <- feols(d_log_pop ~ early_treat + log(pmax(pop_01, 1)) +
                         lit_rate_01 + sc_st_share_01 | pc11_state_id,
                       data = census, cluster = ~dist_id)
cat(sprintf("  Placebo (pop growth): %.4f (SE: %.4f, p=%.3f)\n",
            coef(m_placebo_pop)["early_treat"],
            se(m_placebo_pop)["early_treat"],
            pvalue(m_placebo_pop)["early_treat"]))

# ============================================================
# 3. Pre-trend Test (Nightlights 2000-2005)
# ============================================================
cat("\n=== 3. Pre-trend Test (Nightlights) ===\n")

# Test: Do Phase I/II districts show differential nightlight trends
# BEFORE MGNREGA implementation?
nl_dist[, early_treat := as.integer(nrega_phase <= 2)]
nl_pre <- nl_dist[year <= 2005]
nl_pre[, trend := year - 2000]

pre_trend <- feols(log_light ~ trend:early_treat + trend | dist_num,
                   data = nl_pre, cluster = ~dist_id)
cat(sprintf("  Pre-trend interaction (early × trend): %.5f (SE: %.5f, p=%.3f)\n",
            coef(pre_trend)["trend:early_treat"],
            se(pre_trend)["trend:early_treat"],
            pvalue(pre_trend)["trend:early_treat"]))

# ============================================================
# 4. Alternative Estimator: Sun & Abraham (2021)
# ============================================================
cat("\n=== 4. Sun & Abraham Estimator ===\n")

nl_dist[, cohort := fifelse(nrega_phase == 3, 10000L, first_treat)]
sa <- feols(log_light ~ sunab(cohort, year) | dist_num + year,
            data = nl_dist, cluster = ~dist_id)
sa_agg <- summary(sa, agg = "ATT")
cat(sprintf("  Sun-Abraham ATT: %.4f (SE: %.4f)\n",
            sa_agg$coeftable[1, 1], sa_agg$coeftable[1, 2]))

# ============================================================
# 5. Alternative Clustering: State Level
# ============================================================
cat("\n=== 5. Alternative Clustering (State) ===\n")

m_state_cl <- feols(d_nonfarm_share ~ early_treat + log(pmax(pop_01, 1)) +
                      lit_rate_01 + sc_st_share_01 + aglabor_share_01 | pc11_state_id,
                    data = census, cluster = ~pc11_state_id)
cat(sprintf("  Non-farm (state cluster): %.4f (SE: %.4f)\n",
            coef(m_state_cl)["early_treat"], se(m_state_cl)["early_treat"]))

# Wild cluster bootstrap for state-level inference
cat("  Running wild cluster bootstrap at state level...\n")
m_wcb <- feols(d_nonfarm_share ~ early_treat + log(pmax(pop_01, 1)) +
                 lit_rate_01 + sc_st_share_01 + aglabor_share_01 | pc11_state_id,
               data = census, cluster = ~pc11_state_id)
# Use boottest via fwildclusterboot if available, otherwise report standard
wcb_p <- tryCatch({
  library(fwildclusterboot)
  bt <- boottest(m_wcb, param = "early_treat", B = 9999, type = "rademacher",
                 clustid = "pc11_state_id")
  cat(sprintf("  WCB p-value: %.4f (CI: [%.4f, %.4f])\n",
              bt$p_val, bt$conf_int[1], bt$conf_int[2]))
  bt$p_val
}, error = function(e) {
  cat(sprintf("  WCB unavailable (%s), using analytical SE\n", e$message))
  pvalue(m_state_cl)["early_treat"]
})

# ============================================================
# 5b. Restricted Nightlights (2000-2007 only, clean control)
# ============================================================
cat("\n=== 5b. Restricted Nightlights (2000-2007, clean controls) ===\n")

# Restrict to years before Phase III treatment (April 2008)
nl_clean <- nl_dist[year <= 2007]
nl_clean[, first_treat_clean := fifelse(nrega_phase == 1, 2006L,
                                  fifelse(nrega_phase == 2, 2007L, 0L))]
set.seed(20240101)
cs_clean <- tryCatch({
  att_gt(
    yname    = "log_light",
    tname    = "year",
    idname   = "dist_num",
    gname    = "first_treat_clean",
    data     = as.data.frame(nl_clean),
    control_group = "nevertreated",
    est_method = "dr",
    bstrap   = TRUE,
    cband    = TRUE,
    biters   = 1000
  )
}, error = function(e) {
  cat(sprintf("  Restricted CS-DiD error: %s\n", e$message))
  NULL
})

if (!is.null(cs_clean)) {
  cs_clean_agg <- aggte(cs_clean, type = "simple")
  cat(sprintf("  Restricted ATT (2000-2007): %.4f (SE: %.4f)\n",
              cs_clean_agg$overall.att, cs_clean_agg$overall.se))
}

# ============================================================
# 6. Gender Heterogeneity
# ============================================================
cat("\n=== 6. Gender Heterogeneity ===\n")

# Female non-farm share
m_f_nf <- feols(d_f_nonfarm_share ~ early_treat + log(pmax(pop_01, 1)) +
                  lit_rate_01 + sc_st_share_01 + f_nonfarm_share_01 | pc11_state_id,
                data = census, cluster = ~dist_id)

# Female agricultural labor share
m_f_al <- feols(d_f_aglabor_share ~ early_treat + log(pmax(pop_01, 1)) +
                  lit_rate_01 + sc_st_share_01 + f_aglabor_share_01 | pc11_state_id,
                data = census, cluster = ~dist_id)

# Female literacy
m_f_lit <- feols(d_f_lit_rate ~ early_treat + log(pmax(pop_01, 1)) +
                   lit_rate_01 + sc_st_share_01 | pc11_state_id,
                 data = census, cluster = ~dist_id)

# Female WFPR
m_f_wf <- feols(d_f_wfpr ~ early_treat + log(pmax(pop_01, 1)) +
                  lit_rate_01 + sc_st_share_01 + f_wfpr_01 | pc11_state_id,
                data = census, cluster = ~dist_id)

cat(sprintf("  Female non-farm:  %.4f (SE: %.4f)\n",
            coef(m_f_nf)["early_treat"], se(m_f_nf)["early_treat"]))
cat(sprintf("  Female ag labor:  %.4f (SE: %.4f)\n",
            coef(m_f_al)["early_treat"], se(m_f_al)["early_treat"]))
cat(sprintf("  Female literacy:  %.4f (SE: %.4f)\n",
            coef(m_f_lit)["early_treat"], se(m_f_lit)["early_treat"]))

# ============================================================
# 7. Caste Heterogeneity (SC/ST interaction)
# ============================================================
cat("\n=== 7. Caste Heterogeneity ===\n")

# DDD: early_treat × high_sc_st
m_caste <- feols(d_nonfarm_share ~ early_treat * high_sc_st +
                   log(pmax(pop_01, 1)) + lit_rate_01 + aglabor_share_01 |
                   pc11_state_id,
                 data = census, cluster = ~dist_id)
cat(sprintf("  Early × High SC/ST: %.4f (SE: %.4f)\n",
            coef(m_caste)["early_treat:high_sc_st"],
            se(m_caste)["early_treat:high_sc_st"]))

# ============================================================
# 8. Baseline Ag-Labor Intensity Heterogeneity
# ============================================================
cat("\n=== 8. Ag-Labor Intensity Heterogeneity ===\n")

census[, high_ag := as.integer(aglabor_share_01 > median(aglabor_share_01,
                                                          na.rm = TRUE))]
m_ag_het <- feols(d_nonfarm_share ~ early_treat * high_ag +
                    log(pmax(pop_01, 1)) + lit_rate_01 + sc_st_share_01 |
                    pc11_state_id,
                  data = census, cluster = ~dist_id)
cat(sprintf("  Early × High Ag-Labor: %.4f (SE: %.4f)\n",
            coef(m_ag_het)["early_treat:high_ag"],
            se(m_ag_het)["early_treat:high_ag"]))

# ============================================================
# 9. Dose-Response: Phase I vs Phase II vs Phase III
# ============================================================
cat("\n=== 9. Dose-Response ===\n")

m_dose <- feols(d_nonfarm_share ~ phase1 + phase2 + log(pmax(pop_01, 1)) +
                  lit_rate_01 + sc_st_share_01 + aglabor_share_01 | pc11_state_id,
                data = census, cluster = ~dist_id)
cat(sprintf("  Phase I:  %.4f (SE: %.4f)\n",
            coef(m_dose)["phase1"], se(m_dose)["phase1"]))
cat(sprintf("  Phase II: %.4f (SE: %.4f)\n",
            coef(m_dose)["phase2"], se(m_dose)["phase2"]))

# ============================================================
# Save robustness results
# ============================================================
cat("\n=== Saving robustness results ===\n")

rob <- list(
  m_placebo_pop = m_placebo_pop,
  pre_trend = pre_trend,
  sa = sa,
  m_state_cl = m_state_cl,
  wcb_p = wcb_p,
  cs_clean = cs_clean,
  m_f_nf = m_f_nf, m_f_al = m_f_al, m_f_lit = m_f_lit, m_f_wf = m_f_wf,
  m_caste = m_caste,
  m_ag_het = m_ag_het,
  m_dose = m_dose
)

saveRDS(rob, "data/robustness_results.rds")
cat("Robustness analysis complete.\n")
