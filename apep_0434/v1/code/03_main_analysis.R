## ============================================================
## 03_main_analysis.R — Main DiD analysis
## ============================================================

source("code/00_packages.R")

cat("=== Loading analysis data ===\n")
census   <- readRDS("data/census_panel.rds")
nl_dist  <- readRDS("data/nl_district_panel.rds")

# ============================================================
# A. Census Long-Difference Regressions (2001-2011)
# ============================================================
cat("\n=== A. Census Long-Difference Regressions ===\n")

# Controls: baseline (2001) characteristics
# Note: These are village-level pre-treatment controls
ctrl <- c("log(pmax(pop_01, 1))", "lit_rate_01", "sc_st_share_01",
          "aglabor_share_01")

# -- A1. Non-farm share (main outcome) --
cat("Running non-farm share regressions...\n")

# Specification 1: No controls, state FE
m1_nf <- feols(d_nonfarm_share ~ early_treat | pc11_state_id,
               data = census, cluster = ~dist_id)

# Specification 2: With baseline controls
m2_nf <- feols(d_nonfarm_share ~ early_treat + log(pmax(pop_01, 1)) +
                 lit_rate_01 + sc_st_share_01 + aglabor_share_01 | pc11_state_id,
               data = census, cluster = ~dist_id)

# Specification 3: Separate Phase I and Phase II effects
m3_nf <- feols(d_nonfarm_share ~ phase1 + phase2 +
                 log(pmax(pop_01, 1)) + lit_rate_01 + sc_st_share_01 +
                 aglabor_share_01 | pc11_state_id,
               data = census, cluster = ~dist_id)

cat("  Non-farm share results:\n")
cat(sprintf("  Early treat (no controls): %.4f (SE: %.4f)\n",
            coef(m1_nf)["early_treat"], se(m1_nf)["early_treat"]))
cat(sprintf("  Early treat (controls):    %.4f (SE: %.4f)\n",
            coef(m2_nf)["early_treat"], se(m2_nf)["early_treat"]))

# -- A2. Agricultural labor share --
cat("Running agricultural labor share regressions...\n")
m1_al <- feols(d_aglabor_share ~ early_treat | pc11_state_id,
               data = census, cluster = ~dist_id)
m2_al <- feols(d_aglabor_share ~ early_treat + log(pmax(pop_01, 1)) +
                 lit_rate_01 + sc_st_share_01 + aglabor_share_01 | pc11_state_id,
               data = census, cluster = ~dist_id)

# -- A3. Cultivator share --
cat("Running cultivator share regressions...\n")
m1_cl <- feols(d_cultivator_share ~ early_treat | pc11_state_id,
               data = census, cluster = ~dist_id)
m2_cl <- feols(d_cultivator_share ~ early_treat + log(pmax(pop_01, 1)) +
                 lit_rate_01 + sc_st_share_01 + cultivator_share_01 | pc11_state_id,
               data = census, cluster = ~dist_id)

# -- A4. Household industry share --
cat("Running household industry share regressions...\n")
m1_hh <- feols(d_hh_ind_share ~ early_treat | pc11_state_id,
               data = census, cluster = ~dist_id)
m2_hh <- feols(d_hh_ind_share ~ early_treat + log(pmax(pop_01, 1)) +
                 lit_rate_01 + sc_st_share_01 + hh_ind_share_01 | pc11_state_id,
               data = census, cluster = ~dist_id)

# -- A5. Work force participation rate --
cat("Running WFPR regressions...\n")
m1_wf <- feols(d_wfpr ~ early_treat | pc11_state_id,
               data = census, cluster = ~dist_id)
m2_wf <- feols(d_wfpr ~ early_treat + log(pmax(pop_01, 1)) +
                 lit_rate_01 + sc_st_share_01 + wfpr_01 | pc11_state_id,
               data = census, cluster = ~dist_id)

# -- A6. Literacy rate --
cat("Running literacy regressions...\n")
m1_lit <- feols(d_lit_rate ~ early_treat | pc11_state_id,
                data = census, cluster = ~dist_id)
m2_lit <- feols(d_lit_rate ~ early_treat + log(pmax(pop_01, 1)) +
                  lit_rate_01 + sc_st_share_01 + aglabor_share_01 | pc11_state_id,
                data = census, cluster = ~dist_id)

# ============================================================
# B. Callaway & Sant'Anna DiD (Nightlights Panel)
# ============================================================
cat("\n=== B. Callaway-Sant'Anna DiD (Nightlights) ===\n")

# For CS-DiD, we need never-treated or not-yet-treated as control
# Since Phase III (2008) is very close to Phase I/II, we use
# Phase III as not-yet-treated for 2006-2007

# Recode: Phase III first_treat = 0 (never treated in CS framework)
# This means Phase I (g=2006) and Phase II (g=2007) are treatment cohorts
# Phase III (g=0) is the comparison group
nl_cs <- copy(nl_dist)
nl_cs[nrega_phase == 3, first_treat := 0]  # not-yet-treated

cat("Running CS-DiD on log(nightlights)...\n")
cat(sprintf("  Districts: %d (Phase I: %d, Phase II: %d, Control: %d)\n",
            uniqueN(nl_cs$dist_num),
            uniqueN(nl_cs[first_treat == 2006]$dist_num),
            uniqueN(nl_cs[first_treat == 2007]$dist_num),
            uniqueN(nl_cs[first_treat == 0]$dist_num)))

set.seed(20240101)
cs_out <- tryCatch({
  att_gt(
    yname    = "log_light",
    tname    = "year",
    idname   = "dist_num",
    gname    = "first_treat",
    data     = as.data.frame(nl_cs),
    control_group = "nevertreated",
    est_method = "dr",
    bstrap   = TRUE,
    cband    = TRUE,
    biters   = 1000
  )
}, error = function(e) {
  cat(sprintf("  CS-DiD error: %s\n", e$message))
  NULL
})

if (!is.null(cs_out)) {
  # Aggregate to event study
  es_out <- aggte(cs_out, type = "dynamic")
  cat("  CS-DiD event study estimated successfully.\n")
  cat(sprintf("  Overall ATT: %.4f (SE: %.4f)\n",
              aggte(cs_out, type = "simple")$overall.att,
              aggte(cs_out, type = "simple")$overall.se))

  # Group-specific ATTs
  group_att <- aggte(cs_out, type = "group")
  cat("  Group-specific ATTs:\n")
  for (i in seq_along(group_att$egt)) {
    cat(sprintf("    Group %d: ATT = %.4f (SE: %.4f)\n",
                group_att$egt[i], group_att$att.egt[i], group_att$se.egt[i]))
  }
}

# ============================================================
# C. TWFE Benchmark (for comparison with CS-DiD)
# ============================================================
cat("\n=== C. TWFE Benchmark ===\n")

# Standard TWFE with district and year FE
twfe <- feols(log_light ~ post | dist_num + year,
              data = nl_dist, cluster = ~dist_id)

# Sun-Abraham decomposition
nl_dist[, cohort := fifelse(nrega_phase == 3, 10000L, first_treat)]
sa <- feols(log_light ~ sunab(cohort, year) | dist_num + year,
            data = nl_dist, cluster = ~dist_id)

cat(sprintf("  TWFE ATT: %.4f (SE: %.4f)\n",
            coef(twfe)["post"], se(twfe)["post"]))

# ============================================================
# Save results
# ============================================================
cat("\n=== Saving results ===\n")

results <- list(
  # Census long-diff
  m1_nf = m1_nf, m2_nf = m2_nf, m3_nf = m3_nf,
  m1_al = m1_al, m2_al = m2_al,
  m1_cl = m1_cl, m2_cl = m2_cl,
  m1_hh = m1_hh, m2_hh = m2_hh,
  m1_wf = m1_wf, m2_wf = m2_wf,
  m1_lit = m1_lit, m2_lit = m2_lit,
  # CS-DiD
  cs_out = cs_out, es_out = if (exists("es_out")) es_out else NULL,
  # TWFE
  twfe = twfe, sa = sa
)

saveRDS(results, "data/main_results.rds")
cat("Main analysis complete.\n")
