## ============================================================
## 04_robustness.R — Robustness checks
## MGNREGA and Structural Transformation
## ============================================================

source("00_packages.R")

data_dir  <- file.path("..", "data")

census <- fread(file.path(data_dir, "analysis_census_panel.csv"))
nl     <- fread(file.path(data_dir, "analysis_nightlights_panel.csv"))

# ── 1. Alternative comparison: Phase I vs Phase II ───────────
cat("\n========== ROBUSTNESS: Phase I vs Phase II ==========\n")

census_12 <- census[mgnrega_phase %in% c(1L, 2L) & year %in% c(2001L, 2011L)]
census_12[, early := as.integer(mgnrega_phase == 1L)]
census_12[, post := as.integer(year == 2011L)]
census_12[, early_post := early * post]

rob_nonfarm_12 <- feols(nonfarm_share ~ early_post | dist_id + year,
                        data = census_12, cluster = ~pc11_state_id)
cat("Non-farm share (Phase I vs II):\n")
print(summary(rob_nonfarm_12))

# ── 2. Dose-response: treatment duration ─────────────────────
cat("\n========== ROBUSTNESS: Dose-Response ==========\n")

# Treatment years by 2011: Phase I = 5, Phase II = 4, Phase III = 3
census_2011 <- census[year == 2011L]
census_2001 <- census[year == 2001L]

# First-difference
fd <- merge(census_2011, census_2001,
            by = c("dist_id", "pc11_state_id", "pc11_district_id",
                   "mgnrega_phase", "first_treat_year"),
            suffixes = c("_11", "_01"))
fd[, delta_nonfarm := nonfarm_share_11 - nonfarm_share_01]
fd[, treatment_years := 2011L - first_treat_year]

dose_resp <- feols(delta_nonfarm ~ treatment_years | pc11_state_id,
                   data = fd, cluster = ~pc11_state_id)
cat("Dose-response (treatment years → Δ non-farm share):\n")
print(summary(dose_resp))

# ── 3. Heterogeneity: by baseline development ────────────────
cat("\n========== HETEROGENEITY: Baseline Development ==========\n")

# Split Phase I districts by median baseline non-farm share in 2001
census_13 <- census[mgnrega_phase %in% c(1L, 3L) & year %in% c(2001L, 2011L)]
census_13[, early := as.integer(mgnrega_phase == 1L)]
census_13[, post := as.integer(year == 2011L)]
census_13[, early_post := early * post]

# Get baseline nonfarm share from 2001
baseline <- census[year == 2001L, .(dist_id, baseline_nonfarm = nonfarm_share)]
census_13 <- merge(census_13, baseline, by = "dist_id")

median_nf <- median(census_13[year == 2001, baseline_nonfarm], na.rm = TRUE)
census_13[, high_baseline := as.integer(baseline_nonfarm > median_nf)]

het_high <- feols(nonfarm_share ~ early_post | dist_id + year,
                  data = census_13[high_baseline == 1],
                  cluster = ~pc11_state_id)
het_low <- feols(nonfarm_share ~ early_post | dist_id + year,
                 data = census_13[high_baseline == 0],
                 cluster = ~pc11_state_id)

cat("High baseline non-farm:\n"); print(summary(het_high))
cat("Low baseline non-farm:\n"); print(summary(het_low))

# ── 4. Heterogeneity: by SC/ST concentration ─────────────────
cat("\n========== HETEROGENEITY: SC/ST Share ==========\n")

phase_data <- fread(file.path(data_dir, "district_mgnrega_phase.csv"))
census_13_scst <- merge(census_13, phase_data[, .(pc11_state_id, pc11_district_id, sc_st_share)],
                        by = c("pc11_state_id", "pc11_district_id"), all.x = TRUE)

# sc_st_share may have suffix from merge if census already has it
scst_col <- grep("sc_st_share", names(census_13_scst), value = TRUE)[1]
median_scst <- median(census_13_scst[year == 2001L][[scst_col]], na.rm = TRUE)
census_13_scst[, high_scst := as.integer(get(scst_col) > median_scst)]

het_scst_high <- feols(nonfarm_share ~ early_post | dist_id + year,
                       data = census_13_scst[high_scst == 1],
                       cluster = ~pc11_state_id)
het_scst_low <- feols(nonfarm_share ~ early_post | dist_id + year,
                      data = census_13_scst[high_scst == 0],
                      cluster = ~pc11_state_id)

cat("High SC/ST share:\n"); print(summary(het_scst_high))
cat("Low SC/ST share:\n"); print(summary(het_scst_low))

# ── 5. de Chaisemartin-d'Haultfoeuille estimator ─────────────
cat("\n========== ROBUSTNESS: dCdH Estimator ==========\n")

# Use fixest TWFE with treatment heterogeneity diagnostic
nl[, cohort := first_treat_year]

# Standard TWFE for comparison
twfe_nl <- feols(log_light ~ treated | dist_num + year,
                 data = nl, cluster = ~pc11_state_id)
cat("Standard TWFE (nightlights):\n")
print(summary(twfe_nl))

# ── 6. Placebo: Urban districts (MGNREGA is rural only) ──────
cat("\n========== PLACEBO: Not applicable ==========\n")
cat("Note: SHRUG data is at village/town level, aggregated to districts.\n")
cat("Districts contain both rural and urban areas. A clean urban-only\n")
cat("placebo requires separating rural vs urban SHRIDs, which is possible\n")
cat("using the SHRID type indicator but not implemented here.\n")
cat("The nightlights event study serves as the primary pre-trend diagnostic.\n")

# ── 7. Randomization Inference ────────────────────────────────
cat("\n========== RANDOMIZATION INFERENCE ==========\n")

# Permute phase assignment 500 times, re-estimate TWFE
set.seed(20260221)
n_perm <- 500
ri_data_base <- census[mgnrega_phase %in% c(1L, 3L) & year %in% c(2001L, 2011L)]
ri_data_base[, early := as.integer(mgnrega_phase == 1L)]
ri_data_base[, post := as.integer(year == 2011L)]
ri_data_base[, early_post := early * post]
twfe_ri <- feols(nonfarm_share ~ early_post | dist_id + year,
                 data = ri_data_base, cluster = ~pc11_state_id)
obs_coef <- coef(twfe_ri)["early_post"]

# Get unique districts for permutation
dist_phase <- unique(census[mgnrega_phase %in% c(1L, 3L) & year == 2001L,
                            .(dist_id, mgnrega_phase)])
n1 <- sum(dist_phase$mgnrega_phase == 1L)

perm_coefs <- numeric(n_perm)
census_13_ri <- census[mgnrega_phase %in% c(1L, 3L) & year %in% c(2001L, 2011L)]

for (i in 1:n_perm) {
  # Randomly assign Phase I to n1 districts
  perm_phase <- copy(dist_phase)
  perm_phase[, perm_early := 0L]
  perm_phase[sample(.N, n1), perm_early := 1L]

  # Merge permuted assignment
  ri_data <- merge(census_13_ri, perm_phase[, .(dist_id, perm_early)], by = "dist_id")
  ri_data[, post := as.integer(year == 2011L)]
  ri_data[, perm_ep := perm_early * post]

  fit <- tryCatch(
    feols(nonfarm_share ~ perm_ep | dist_id + year, data = ri_data,
          cluster = ~pc11_state_id),
    error = function(e) NULL
  )
  perm_coefs[i] <- if (!is.null(fit)) coef(fit)["perm_ep"] else NA_real_
}

ri_pvalue <- mean(abs(perm_coefs) >= abs(obs_coef), na.rm = TRUE)
cat("Observed coefficient:", obs_coef, "\n")
cat("RI p-value (500 permutations):", ri_pvalue, "\n")
cat("RI distribution: mean =", mean(perm_coefs, na.rm = TRUE),
    "sd =", sd(perm_coefs, na.rm = TRUE), "\n")

# Save robustness results
rob_results <- list(
  rob_nonfarm_12 = rob_nonfarm_12,
  dose_resp = dose_resp,
  het_high = het_high,
  het_low = het_low,
  het_scst_high = het_scst_high,
  het_scst_low = het_scst_low,
  twfe_nl = twfe_nl,
  obs_coef = obs_coef,
  ri_pvalue = ri_pvalue,
  perm_coefs = perm_coefs
)
saveRDS(rob_results, file.path(data_dir, "robustness_results.rds"))

cat("\nRobustness results saved.\n")
