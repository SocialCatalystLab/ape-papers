## ── 04_robustness.R ───────────────────────────────────────────────────────
## Robustness checks for apep_0426
## ──────────────────────────────────────────────────────────────────────────

source("00_packages.R")

data_dir <- "../data"
panel <- fread(file.path(data_dir, "analysis_panel_clean.csv"))
cross <- fread(file.path(data_dir, "district_cross_section.csv"))

panel[, did := as.integer(as.factor(dist_code))]

## ══════════════════════════════════════════════════════════════════════════
## 1. Bacon Decomposition (TWFE Diagnostics)
## ══════════════════════════════════════════════════════════════════════════
cat("=== Bacon Decomposition ===\n")

## Prepare balanced panel for Bacon decomposition
## bacondecomp needs balanced panel
bacon_panel <- panel[, .(log_light = mean(log_light, na.rm = TRUE),
                          treated = max(treated)),
                      by = .(dist_code, year)]

## Convert to data.frame with numeric ID
bacon_panel[, id := as.integer(as.factor(dist_code))]

tryCatch({
  bacon_out <- bacon(log_light ~ treated,
                     data = as.data.frame(bacon_panel),
                     id_var = "id",
                     time_var = "year")
  cat("Bacon decomposition weights:\n")
  print(bacon_out)
  saveRDS(bacon_out, file.path(data_dir, "bacon_decomp.rds"))
}, error = function(e) {
  cat(sprintf("Bacon decomposition error: %s\n", e$message))
})

## ══════════════════════════════════════════════════════════════════════════
## 2. Pre-Trend Test (Formal)
## ══════════════════════════════════════════════════════════════════════════
cat("\n=== Pre-Trend Tests ===\n")

## CS-DiD pre-trend test
cs_did <- att_gt(
  yname = "log_light",
  tname = "year",
  idname = "did",
  gname = "cohort",
  xformla = ~ sc_st_share + lit_rate + log_pop_2001,
  control_group = "notyettreated",
  est_method = "reg",
  data = as.data.frame(panel),
  clustervars = "state_code",
  print_details = FALSE
)

cs_dynamic <- aggte(cs_did, type = "dynamic", min_e = -10, max_e = 15, na.rm = TRUE)

## Extract pre-treatment coefficients
pre_coefs <- data.table(
  event_time = cs_dynamic$egt,
  att = cs_dynamic$att.egt,
  se = cs_dynamic$se.egt
)
pre_coefs[, ci_lo := att - 1.96 * se]
pre_coefs[, ci_hi := att + 1.96 * se]

cat("Pre-treatment coefficients (should be near zero):\n")
print(pre_coefs[event_time < 0])

## Joint test: are all pre-treatment coefficients jointly zero?
pre_only <- pre_coefs[event_time < 0 & event_time >= -8]
if (nrow(pre_only) > 0) {
  wald_stat <- sum((pre_only$att / pre_only$se)^2)
  p_val <- pchisq(wald_stat, df = nrow(pre_only), lower.tail = FALSE)
  cat(sprintf("\nJoint pre-trend test: chi2(%d) = %.2f, p = %.4f\n",
              nrow(pre_only), wald_stat, p_val))
}

## ══════════════════════════════════════════════════════════════════════════
## 3. Heterogeneity: By Baseline Development
## ══════════════════════════════════════════════════════════════════════════
cat("\n=== Heterogeneity by Baseline Development ===\n")

## TWFE by development quartile
for (q in unique(na.omit(panel$dev_quartile))) {
  sub <- panel[dev_quartile == q]
  m <- feols(log_light ~ treated | dist_code + year,
             data = sub, cluster = ~state_code)
  cat(sprintf("  %s: coef = %.4f (se = %.4f), N = %d\n",
              q, coef(m)["treated"], se(m)["treated"], nobs(m)))
}

## ══════════════════════════════════════════════════════════════════════════
## 4. Heterogeneity: By SC/ST Intensity
## ══════════════════════════════════════════════════════════════════════════
cat("\n=== Heterogeneity by SC/ST Share ===\n")

for (q in unique(na.omit(panel$scst_quartile))) {
  sub <- panel[scst_quartile == q]
  m <- feols(log_light ~ treated | dist_code + year,
             data = sub, cluster = ~state_code)
  cat(sprintf("  %s: coef = %.4f (se = %.4f), N = %d\n",
              q, coef(m)["treated"], se(m)["treated"], nobs(m)))
}

## ══════════════════════════════════════════════════════════════════════════
## 5. Placebo: Pre-Treatment Fake Treatment
## ══════════════════════════════════════════════════════════════════════════
cat("\n=== Placebo Test: Fake Treatment 3 Years Early ===\n")

panel[, fake_treat := as.integer(year >= (treat_year - 3))]
m_placebo <- feols(log_light ~ fake_treat | dist_code + year,
                    data = panel[year < treat_year],
                    cluster = ~state_code)
cat("Placebo (treatment shifted 3 years earlier, using only pre-treatment data):\n")
summary(m_placebo)

## ══════════════════════════════════════════════════════════════════════════
## 6. Alternative Outcome: Level of Nightlights
## ══════════════════════════════════════════════════════════════════════════
cat("\n=== Alternative: Nightlights in Levels ===\n")

panel[, asinh_light := asinh(total_light)]
m_asinh <- feols(asinh_light ~ treated | dist_code + year,
                  data = panel, cluster = ~state_code)
cat("Inverse hyperbolic sine transformation:\n")
summary(m_asinh)

## ══════════════════════════════════════════════════════════════════════════
## 7. HonestDiD Sensitivity (Rambachan & Roth 2023)
## ══════════════════════════════════════════════════════════════════════════
cat("\n=== HonestDiD Sensitivity Analysis ===\n")

## Use TWFE event study for HonestDiD
m_es <- feols(log_light ~ i(event_time_binned, ref = -1) | dist_code + year,
              data = panel, cluster = ~state_code)

tryCatch({
  betahat <- coef(m_es)
  sigma <- vcov(m_es)

  ## Get indices for post-treatment and pre-treatment
  coef_names <- names(betahat)
  post_idx <- grep("event_time_binned::[0-9]", coef_names)
  pre_idx <- grep("event_time_binned::-[0-9]", coef_names)

  if (length(post_idx) > 0 && length(pre_idx) > 0) {
    honest <- HonestDiD::createSensitivityResults(
      betahat = betahat,
      sigma = sigma,
      numPrePeriods = length(pre_idx),
      numPostPeriods = length(post_idx),
      Mvec = seq(0, 0.05, by = 0.01)
    )
    cat("HonestDiD sensitivity bounds:\n")
    print(honest)
    saveRDS(honest, file.path(data_dir, "honest_did.rds"))
  }
}, error = function(e) {
  cat(sprintf("HonestDiD error: %s\n", e$message))
})

## ══════════════════════════════════════════════════════════════════════════
## 8. Save Robustness Results
## ══════════════════════════════════════════════════════════════════════════

robust_results <- list(
  pre_coefs = pre_coefs,
  placebo = m_placebo,
  asinh = m_asinh,
  event_study_twfe = m_es
)
saveRDS(robust_results, file.path(data_dir, "robustness_results.rds"))

cat("\n✓ Robustness checks complete.\n")
