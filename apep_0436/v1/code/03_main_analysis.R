## ============================================================
## 03_main_analysis.R — Primary regressions
## MGNREGA and Structural Transformation
## ============================================================

source("00_packages.R")

data_dir  <- file.path("..", "data")

# Load panels
census <- fread(file.path(data_dir, "analysis_census_panel.csv"))
nl     <- fread(file.path(data_dir, "analysis_nightlights_panel.csv"))
gender <- fread(file.path(data_dir, "analysis_gender_panel.csv"))

# ── Summary statistics ───────────────────────────────────────
cat("\n========== SUMMARY STATISTICS ==========\n")

# Census panel summary by phase and year
sum_stats <- census[, .(
  n_districts = .N,
  mean_pop = mean(pop, na.rm = TRUE),
  mean_nonfarm_share = mean(nonfarm_share, na.rm = TRUE),
  mean_ag_share = mean(ag_share, na.rm = TRUE),
  mean_cult_share = mean(cult_share, na.rm = TRUE),
  mean_aglab_share = mean(aglab_share, na.rm = TRUE)
), by = .(mgnrega_phase, year)]

cat("\nCensus means by phase and year:\n")
print(sum_stats[order(mgnrega_phase, year)])

# ── ANALYSIS 1: TWFE DiD (Census Panel) ─────────────────────
cat("\n========== TWFE DiD: Census Panel ==========\n")

# Main specification: Phase I (early) vs Phase III (late)
# Using 2001 (pre) and 2011 (post)
# Phase I districts treated from 2006 (5 years exposure by 2011)
# Phase III districts treated from 2008 (3 years exposure by 2011)
# Comparison: Phase I was treated 2 years earlier → differential exposure

# Create "early treated" indicator (Phase I vs Phase III)
census_13 <- census[mgnrega_phase %in% c(1L, 3L) & year %in% c(2001L, 2011L)]
census_13[, early := as.integer(mgnrega_phase == 1L)]
census_13[, post := as.integer(year == 2011L)]
census_13[, early_post := early * post]

# (1) Non-farm share
twfe_nonfarm <- feols(nonfarm_share ~ early_post | dist_id + year,
                      data = census_13, cluster = ~pc11_state_id)

# (2) Cultivator share
twfe_cult <- feols(cult_share ~ early_post | dist_id + year,
                   data = census_13, cluster = ~pc11_state_id)

# (3) Agricultural laborer share
twfe_aglab <- feols(aglab_share ~ early_post | dist_id + year,
                    data = census_13, cluster = ~pc11_state_id)

# (4) Log population
twfe_pop <- feols(log_pop ~ early_post | dist_id + year,
                  data = census_13, cluster = ~pc11_state_id)

cat("\n--- TWFE Results (Phase I vs III, 2001-2011) ---\n")
cat("Non-farm share:\n"); print(summary(twfe_nonfarm))
cat("Cultivator share:\n"); print(summary(twfe_cult))
cat("Ag laborer share:\n"); print(summary(twfe_aglab))
cat("Log population:\n"); print(summary(twfe_pop))

# Also with Phase II
census_all <- census[year %in% c(2001L, 2011L)]
census_all[, post := as.integer(year == 2011L)]
census_all[, phase1 := as.integer(mgnrega_phase == 1L)]
census_all[, phase2 := as.integer(mgnrega_phase == 2L)]
census_all[, phase1_post := phase1 * post]
census_all[, phase2_post := phase2 * post]

twfe_all_nonfarm <- feols(nonfarm_share ~ phase1_post + phase2_post | dist_id + year,
                          data = census_all, cluster = ~pc11_state_id)
cat("\n--- TWFE with all phases (Phase III = reference) ---\n")
print(summary(twfe_all_nonfarm))

# ── ANALYSIS 2: Pre-Trend Test (1991-2001) ──────────────────
cat("\n========== PRE-TREND TEST (1991-2001) ==========\n")

# If parallel trends hold: Phase I and Phase III should have similar
# changes in worker composition between 1991 and 2001 (both pre-MGNREGA)
pretrend <- census[mgnrega_phase %in% c(1L, 3L) & year %in% c(1991L, 2001L)]
pretrend[, early := as.integer(mgnrega_phase == 1L)]
pretrend[, post := as.integer(year == 2001L)]
pretrend[, early_post := early * post]

pt_nonfarm <- feols(nonfarm_share ~ early_post | dist_id + year,
                    data = pretrend, cluster = ~pc11_state_id)
pt_cult <- feols(cult_share ~ early_post | dist_id + year,
                 data = pretrend, cluster = ~pc11_state_id)
pt_aglab <- feols(aglab_share ~ early_post | dist_id + year,
                  data = pretrend, cluster = ~pc11_state_id)

cat("Pre-trend test (1991-2001):\n")
cat("Non-farm share:", coef(pt_nonfarm)["early_post"], "p=",
    fixest::pvalue(pt_nonfarm)["early_post"], "\n")
cat("Cultivator share:", coef(pt_cult)["early_post"], "p=",
    fixest::pvalue(pt_cult)["early_post"], "\n")
cat("Ag laborer share:", coef(pt_aglab)["early_post"], "p=",
    fixest::pvalue(pt_aglab)["early_post"], "\n")

# ── ANALYSIS 3: Nightlights Event Study (CS-DiD) ────────────
cat("\n========== NIGHTLIGHTS EVENT STUDY (CS-DiD) ==========\n")

# Callaway-Sant'Anna requires: idname, tname, gname (first treated period), yname
# Here we have annual data with staggered treatment (2006, 2007, 2008)

# For CS-DiD: use not-yet-treated as control
# Note: no never-treated group exists (all treated by 2008)
# Set panel = FALSE because dist_num may have gaps
cs_nl <- att_gt(
  yname = "log_light",
  tname = "year",
  idname = "dist_num",
  gname = "first_treat_year",
  data = as.data.frame(nl),
  control_group = "notyettreated",
  base_period = "universal",
  panel = FALSE
)

cat("\nCallaway-Sant'Anna group-time ATTs:\n")
print(summary(cs_nl))

# Aggregate to event study
es_nl <- aggte(cs_nl, type = "dynamic", min_e = -8, max_e = 7)
cat("\nEvent study aggregation:\n")
print(summary(es_nl))

# Aggregate to overall ATT
overall_nl <- aggte(cs_nl, type = "simple")
cat("\nOverall ATT (nightlights):\n")
print(summary(overall_nl))

# ── ANALYSIS 4: Sun-Abraham estimator (nightlights) ─────────
cat("\n========== SUN-ABRAHAM (Nightlights) ==========\n")

# fixest::sunab requires cohort and relative period
nl[, cohort := first_treat_year]

sa_nl <- feols(log_light ~ sunab(cohort, year) | dist_num + year,
               data = nl, cluster = ~pc11_state_id)
cat("\nSun-Abraham estimates:\n")
print(summary(sa_nl))

# ── ANALYSIS 5: Gender-specific effects ──────────────────────
cat("\n========== GENDER EFFECTS ==========\n")

gender_13 <- gender[mgnrega_phase %in% c(1L, 3L)]
gender_13[, early := as.integer(mgnrega_phase == 1L)]
gender_13[, post := as.integer(year >= first_treat_year)]
gender_13[, early_post := early * post]

twfe_nonfarm_f <- feols(nonfarm_share_f ~ early_post | dist_id + year,
                        data = gender_13, cluster = ~pc11_state_id)

cat("Female non-farm share (Phase I vs III):\n")
print(summary(twfe_nonfarm_f))

# ── Save results ─────────────────────────────────────────────
results <- list(
  twfe_nonfarm = twfe_nonfarm,
  twfe_cult = twfe_cult,
  twfe_aglab = twfe_aglab,
  twfe_pop = twfe_pop,
  twfe_all_nonfarm = twfe_all_nonfarm,
  pt_nonfarm = pt_nonfarm,
  pt_cult = pt_cult,
  pt_aglab = pt_aglab,
  cs_nl = cs_nl,
  es_nl = es_nl,
  overall_nl = overall_nl,
  sa_nl = sa_nl,
  twfe_nonfarm_f = twfe_nonfarm_f
)
saveRDS(results, file.path(data_dir, "main_results.rds"))

cat("\nAll results saved to main_results.rds\n")
