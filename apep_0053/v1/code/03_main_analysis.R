# ============================================================================
# Paper 66: Automatic Voter Registration
# Script 03: Main DiD Analysis
# ============================================================================

library(tidyverse)
library(did)
library(fixest)
library(modelsummary)

cat("============================================================\n")
cat("MAIN DiD ANALYSIS\n")
cat("============================================================\n\n")

# Load cleaned data
df_ind <- readRDS("data/cps_analysis_individual.rds")
df_state <- readRDS("data/state_year_panel.rds")

cat("Individual-level N:", nrow(df_ind), "\n")
cat("State-year panel N:", nrow(df_state), "\n\n")

# ============================================================================
# Callaway-Sant'Anna DiD Estimator
# ============================================================================

cat("Running Callaway-Sant'Anna DiD...\n")

# Prepare data for did package
df_cs <- df_ind %>%
  filter(!is.na(registered)) %>%
  mutate(
    gname = if_else(ever_treated, cohort, 0)
  )

# Estimate ATT(g,t) for registration
cs_reg <- att_gt(
  yname = "registered",
  tname = "year",
  idname = "state_fips",
  gname = "gname",
  data = df_cs,
  xformla = ~ age + female + college,
  panel = FALSE,
  control_group = "nevertreated",
  clustervars = "state_fips",
  anticipation = 0,
  est_method = "dr"  # Doubly-robust
)

# Aggregate ATT
att_simple_reg <- aggte(cs_reg, type = "simple")
att_dynamic_reg <- aggte(cs_reg, type = "dynamic")
att_group_reg <- aggte(cs_reg, type = "group")

cat("\n--- Registration Results ---\n")
cat("Overall ATT:", round(att_simple_reg$overall.att, 4), "\n")
cat("SE:", round(att_simple_reg$overall.se, 4), "\n")
cat("p-value:", round(att_simple_reg$overall.pval, 4), "\n\n")

# Estimate for turnout
cs_vote <- att_gt(
  yname = "voted",
  tname = "year",
  idname = "state_fips",
  gname = "gname",
  data = df_cs %>% filter(!is.na(voted)),
  xformla = ~ age + female + college,
  panel = FALSE,
  control_group = "nevertreated",
  clustervars = "state_fips"
)

att_simple_vote <- aggte(cs_vote, type = "simple")
att_dynamic_vote <- aggte(cs_vote, type = "dynamic")

cat("--- Turnout Results ---\n")
cat("Overall ATT:", round(att_simple_vote$overall.att, 4), "\n")
cat("SE:", round(att_simple_vote$overall.se, 4), "\n")
cat("p-value:", round(att_simple_vote$overall.pval, 4), "\n\n")

# ============================================================================
# Sun-Abraham (2021) Estimator - Robustness
# ============================================================================

cat("Running Sun-Abraham DiD (fixest)...\n")

# Need to create relative time dummies
df_sunab <- df_ind %>%
  filter(!is.na(registered), !is.na(cohort) | !ever_treated) %>%
  mutate(
    cohort_sunab = if_else(ever_treated, cohort, 10000)  # Large number for never-treated
  )

# Estimate with sunab()
sunab_reg <- feols(
  registered ~ sunab(cohort_sunab, year) + age + female + college | state_fips + year,
  data = df_sunab,
  cluster = ~ state_fips
)

cat("Sun-Abraham completed\n\n")

# ============================================================================
# Two-Way Fixed Effects (TWFE) - Comparison
# ============================================================================

cat("Running TWFE (for comparison)...\n")

twfe_reg <- feols(
  registered ~ treated + age + female + college | state_fips + year,
  data = df_ind %>% filter(!is.na(registered)),
  cluster = ~ state_fips
)

twfe_vote <- feols(
  voted ~ treated + age + female + college | state_fips + year,
  data = df_ind %>% filter(!is.na(voted)),
  cluster = ~ state_fips
)

cat("TWFE completed\n\n")

# ============================================================================
# Heterogeneity Analysis
# ============================================================================

cat("Analyzing heterogeneity by age...\n")

# Young voters (18-29)
df_young <- df_cs %>% filter(age >= 18 & age <= 29)
cs_reg_young <- att_gt(
  yname = "registered",
  tname = "year",
  idname = "state_fips",
  gname = "gname",
  data = df_young,
  xformla = ~ age + female + college,
  panel = FALSE,
  control_group = "nevertreated",
  clustervars = "state_fips"
)
att_young <- aggte(cs_reg_young, type = "simple")

# Middle age (30-44)
df_mid <- df_cs %>% filter(age >= 30 & age <= 44)
cs_reg_mid <- att_gt(
  yname = "registered",
  tname = "year",
  idname = "state_fips",
  gname = "gname",
  data = df_mid,
  xformla = ~ age + female + college,
  panel = FALSE,
  control_group = "nevertreated",
  clustervars = "state_fips"
)
att_mid <- aggte(cs_reg_mid, type = "simple")

# Older (45-64)
df_old <- df_cs %>% filter(age >= 45 & age <= 64)
cs_reg_old <- att_gt(
  yname = "registered",
  tname = "year",
  idname = "state_fips",
  gname = "gname",
  data = df_old,
  xformla = ~ age + female + college,
  panel = FALSE,
  control_group = "nevertreated",
  clustervars = "state_fips"
)
att_old <- aggte(cs_reg_old, type = "simple")

# Seniors (65+)
df_senior <- df_cs %>% filter(age >= 65)
cs_reg_senior <- att_gt(
  yname = "registered",
  tname = "year",
  idname = "state_fips",
  gname = "gname",
  data = df_senior,
  xformla = ~ age + female + college,
  panel = FALSE,
  control_group = "nevertreated",
  clustervars = "state_fips"
)
att_senior <- aggte(cs_reg_senior, type = "simple")

cat("Heterogeneity analysis completed\n\n")

# ============================================================================
# Save Results
# ============================================================================

results <- list(
  cs_reg = cs_reg,
  cs_vote = cs_vote,
  att_simple_reg = att_simple_reg,
  att_dynamic_reg = att_dynamic_reg,
  att_group_reg = att_group_reg,
  att_simple_vote = att_simple_vote,
  att_dynamic_vote = att_dynamic_vote,
  sunab_reg = sunab_reg,
  twfe_reg = twfe_reg,
  twfe_vote = twfe_vote,
  att_young = att_young,
  att_mid = att_mid,
  att_old = att_old,
  att_senior = att_senior
)

saveRDS(results, "data/did_results.rds")

cat("\n✓ Results saved to: data/did_results.rds\n")

# ============================================================================
# Summary Table
# ============================================================================

cat("\n============================================================\n")
cat("MAIN RESULTS SUMMARY\n")
cat("============================================================\n\n")

cat("REGISTRATION:\n")
cat(sprintf("  CS-DiD ATT: %.4f (SE: %.4f, p=%.4f)\n",
            att_simple_reg$overall.att, att_simple_reg$overall.se, att_simple_reg$overall.pval))
cat(sprintf("  TWFE:       %.4f (SE: %.4f)\n",
            coef(twfe_reg)["treated"], se(twfe_reg)["treated"]))

cat("\nTURNOUT:\n")
cat(sprintf("  CS-DiD ATT: %.4f (SE: %.4f, p=%.4f)\n",
            att_simple_vote$overall.att, att_simple_vote$overall.se, att_simple_vote$overall.pval))
cat(sprintf("  TWFE:       %.4f (SE: %.4f)\n",
            coef(twfe_vote)["treated"], se(twfe_vote)["treated"]))

cat("\nHETEROGENEITY (Registration ATT by Age):\n")
cat(sprintf("  18-29: %.4f (SE: %.4f)\n", att_young$overall.att, att_young$overall.se))
cat(sprintf("  30-44: %.4f (SE: %.4f)\n", att_mid$overall.att, att_mid$overall.se))
cat(sprintf("  45-64: %.4f (SE: %.4f)\n", att_old$overall.att, att_old$overall.se))
cat(sprintf("  65+:   %.4f (SE: %.4f)\n", att_senior$overall.att, att_senior$overall.se))

cat("\n============================================================\n")
cat("ANALYSIS COMPLETE\n")
cat("============================================================\n")
