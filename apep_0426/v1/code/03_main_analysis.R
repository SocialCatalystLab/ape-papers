## ── 03_main_analysis.R ────────────────────────────────────────────────────
## Main econometric analysis for apep_0426
## ──────────────────────────────────────────────────────────────────────────

source("00_packages.R")

data_dir <- "../data"
panel <- fread(file.path(data_dir, "analysis_panel_clean.csv"))
cross <- fread(file.path(data_dir, "district_cross_section.csv"))

## ══════════════════════════════════════════════════════════════════════════
## 1. TWFE Specification (Baseline)
## ══════════════════════════════════════════════════════════════════════════
cat("=== TWFE Regressions ===\n")

## Simple TWFE
m1_twfe <- feols(log_light ~ treated | dist_code + year,
                  data = panel, cluster = ~state_code)

## TWFE with state × year FE
m2_twfe_sxy <- feols(log_light ~ treated | dist_code + state_code^year,
                      data = panel, cluster = ~state_code)

## TWFE with baseline controls × year
panel[, `:=`(
  lit_rate_x_year = lit_rate * year,
  pop_x_year      = log_pop_2001 * year
)]
m3_twfe_ctrl <- feols(log_light ~ treated + lit_rate_x_year + pop_x_year |
                        dist_code + year,
                      data = panel, cluster = ~state_code)

cat("TWFE results:\n")
etable(m1_twfe, m2_twfe_sxy, m3_twfe_ctrl,
       headers = c("TWFE", "State×Year FE", "Controls"),
       fitstat = c("n", "r2", "ar2"))

## ══════════════════════════════════════════════════════════════════════════
## 2. Callaway-Sant'Anna DiD
## ══════════════════════════════════════════════════════════════════════════
cat("\n=== Callaway-Sant'Anna DiD ===\n")

## Prepare data for did package
## The did package needs: yname, tname, idname, gname
## gname = first treatment period (cohort)
## For not-yet-treated: use the last cohort as the comparison

## Convert dist_code to numeric ID
panel[, did := as.integer(as.factor(dist_code))]

## Run CS-DiD (regression estimator to avoid overlap issues with 2006 cohort)
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

cat("Group-time ATTs:\n")
summary(cs_did)

## Aggregate to overall ATT
cs_agg <- aggte(cs_did, type = "simple", na.rm = TRUE)
cat("\nOverall ATT:\n")
summary(cs_agg)

## Dynamic treatment effects (event study)
cs_dynamic <- aggte(cs_did, type = "dynamic", min_e = -10, max_e = 15, na.rm = TRUE)
cat("\nDynamic ATT (event study):\n")
summary(cs_dynamic)

## Aggregate by cohort
cs_cohort <- aggte(cs_did, type = "group", na.rm = TRUE)
cat("\nATT by cohort:\n")
summary(cs_cohort)

## ══════════════════════════════════════════════════════════════════════════
## 3. Sun & Abraham (2021) Interaction-Weighted Estimator
## ══════════════════════════════════════════════════════════════════════════
cat("\n=== Sun & Abraham (2021) ===\n")

## Convert cohort to factor for fixest sunab
panel[, cohort_f := as.factor(cohort)]

m_sa <- feols(log_light ~ sunab(cohort, year) | dist_code + year,
              data = panel, cluster = ~state_code)

cat("Sun-Abraham results:\n")
summary(m_sa, agg = "att")

## ══════════════════════════════════════════════════════════════════════════
## 4. Cross-Sectional: Structural Transformation (Census 2001 vs 2011)
## ══════════════════════════════════════════════════════════════════════════
cat("\n=== Cross-Sectional Structural Transformation ===\n")

## Did earlier MGNREGA districts have faster structural transformation?
## Outcome: change in non-farm worker share (2001 → 2011)
cross[, state_code := substr(dist_code, 1, 2)]

m_struct <- feols(delta_nonfarm ~ i(nrega_phase, ref = 3) |
                    state_code,
                  data = cross, cluster = ~state_code)

cat("Structural transformation by MGNREGA phase:\n")
cat("(Outcome: change in non-farm worker share 2001-2011)\n")
summary(m_struct)

## Also: agricultural labor share change
m_agri <- feols(delta_agri ~ i(nrega_phase, ref = 3) |
                  state_code,
                data = cross, cluster = ~state_code)
cat("\nAgricultural share change:\n")
summary(m_agri)

## Population growth
m_pop <- feols(pop_growth ~ i(nrega_phase, ref = 3) |
                 state_code,
               data = cross, cluster = ~state_code)
cat("\nPopulation growth:\n")
summary(m_pop)

## ══════════════════════════════════════════════════════════════════════════
## 5. Save Results
## ══════════════════════════════════════════════════════════════════════════

results <- list(
  twfe = m1_twfe,
  twfe_sxy = m2_twfe_sxy,
  twfe_ctrl = m3_twfe_ctrl,
  cs_did = cs_did,
  cs_agg = cs_agg,
  cs_dynamic = cs_dynamic,
  cs_cohort = cs_cohort,
  sa = m_sa,
  struct = m_struct,
  agri = m_agri,
  pop = m_pop
)

saveRDS(results, file.path(data_dir, "main_results.rds"))
cat("\n✓ Main analysis results saved.\n")
