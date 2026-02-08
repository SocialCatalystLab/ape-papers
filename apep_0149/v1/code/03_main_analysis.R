##############################################################################
# 03_main_analysis.R - Primary DiD analysis
# Paper 137: Medicaid Postpartum Coverage Extensions
##############################################################################

source("00_packages.R")

# Set seed for reproducibility of all bootstrap procedures
set.seed(20240137)

cat("=== Main Analysis ===\n")

# Load data
state_year_pp <- fread(file.path(data_dir, "state_year_postpartum.csv"))
state_year_pp_low <- fread(file.path(data_dir, "state_year_postpartum_lowinc.csv"))
df_postpartum <- fread(file.path(data_dir, "acs_postpartum.csv"))
df_pp_lowinc <- fread(file.path(data_dir, "acs_postpartum_lowinc.csv"))

# =========================================================
# 1. TWFE Baseline (for comparison, known to be biased)
# =========================================================

cat("\n--- TWFE Baseline ---\n")

# State-year level TWFE
twfe_medicaid <- feols(
  medicaid_rate ~ treated | state_fips + year,
  data = state_year_pp,
  weights = ~total_weight,
  cluster = ~state_fips
)

twfe_uninsured <- feols(
  uninsured_rate ~ treated | state_fips + year,
  data = state_year_pp,
  weights = ~total_weight,
  cluster = ~state_fips
)

twfe_employer <- feols(
  employer_rate ~ treated | state_fips + year,
  data = state_year_pp,
  weights = ~total_weight,
  cluster = ~state_fips
)

cat("TWFE Results (state-year level, all postpartum women):\n")
etable(twfe_medicaid, twfe_uninsured, twfe_employer,
       headers = c("Medicaid", "Uninsured", "Employer Ins"),
       se.below = TRUE)

# =========================================================
# 2. Callaway-Sant'Anna Estimator (Primary)
# =========================================================

cat("\n--- Callaway-Sant'Anna DiD ---\n")

# Individual-level CS-DiD for Medicaid coverage
# Note: CS-DiD needs panel or repeated cross-section
# With ACS repeated cross-section, we use state-year panel

# Ensure proper types
state_year_pp <- state_year_pp %>%
  mutate(
    state_id = as.integer(factor(state_fips)),
    first_treat = as.integer(first_treat)
  ) %>%
  filter(!is.na(medicaid_rate))

# CS-DiD: Medicaid coverage
cs_medicaid <- att_gt(
  yname = "medicaid_rate",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = as.data.frame(state_year_pp),
  control_group = "nevertreated",
  weightsname = "total_weight",
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000
)

cat("CS-DiD: Medicaid Coverage Rate\n")
summary(cs_medicaid)

# Aggregate ATT
cs_agg_medicaid <- aggte(cs_medicaid, type = "simple")
cat("\nOverall ATT (Medicaid):\n")
summary(cs_agg_medicaid)

# Dynamic/event-study aggregation
cs_dyn_medicaid <- aggte(cs_medicaid, type = "dynamic", min_e = -4, max_e = 2)
cat("\nDynamic ATT (Medicaid):\n")
summary(cs_dyn_medicaid)

# CS-DiD: Uninsured rate
cs_uninsured <- att_gt(
  yname = "uninsured_rate",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = as.data.frame(state_year_pp),
  control_group = "nevertreated",
  weightsname = "total_weight",
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000
)

cs_agg_uninsured <- aggte(cs_uninsured, type = "simple")
cat("\nOverall ATT (Uninsured):\n")
summary(cs_agg_uninsured)

cs_dyn_uninsured <- aggte(cs_uninsured, type = "dynamic", min_e = -4, max_e = 2)

# CS-DiD: Employer insurance (placebo outcome)
cs_employer <- att_gt(
  yname = "employer_rate",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = as.data.frame(state_year_pp),
  control_group = "nevertreated",
  weightsname = "total_weight",
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000
)

cs_agg_employer <- aggte(cs_employer, type = "simple")
cat("\nOverall ATT (Employer Ins - Placebo):\n")
summary(cs_agg_employer)

cs_dyn_employer <- aggte(cs_employer, type = "dynamic", min_e = -4, max_e = 2)

# =========================================================
# 3. Low-income subgroup (most affected)
# =========================================================

cat("\n--- Low-Income Subgroup ---\n")

state_year_pp_low <- state_year_pp_low %>%
  mutate(
    state_id = as.integer(factor(state_fips)),
    first_treat = as.integer(first_treat)
  ) %>%
  filter(!is.na(medicaid_rate))

cs_medicaid_low <- att_gt(
  yname = "medicaid_rate",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = as.data.frame(state_year_pp_low),
  control_group = "nevertreated",
  weightsname = "total_weight",
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000
)

cs_agg_medicaid_low <- aggte(cs_medicaid_low, type = "simple")
cat("\nOverall ATT (Medicaid, Low-Income):\n")
summary(cs_agg_medicaid_low)

cs_dyn_medicaid_low <- aggte(cs_medicaid_low, type = "dynamic", min_e = -4, max_e = 2)

cs_uninsured_low <- att_gt(
  yname = "uninsured_rate",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = as.data.frame(state_year_pp_low),
  control_group = "nevertreated",
  weightsname = "total_weight",
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000
)

cs_agg_uninsured_low <- aggte(cs_uninsured_low, type = "simple")
cat("\nOverall ATT (Uninsured, Low-Income):\n")
summary(cs_agg_uninsured_low)

cs_dyn_uninsured_low <- aggte(cs_uninsured_low, type = "dynamic", min_e = -4, max_e = 2)

# =========================================================
# 4. Sun-Abraham TWFE Event Study (Alternative estimator)
# =========================================================

cat("\n--- Sun-Abraham Event Study ---\n")

# Individual-level Sun-Abraham
sa_medicaid <- feols(
  medicaid ~ sunab(first_treat, year) | state_fips + year,
  data = df_postpartum %>% filter(first_treat > 0 | state_fips %in% c(5, 55)),
  weights = ~weight,
  cluster = ~state_fips
)

cat("Sun-Abraham Event Study (Medicaid):\n")
summary(sa_medicaid)

sa_uninsured <- feols(
  uninsured ~ sunab(first_treat, year) | state_fips + year,
  data = df_postpartum %>% filter(first_treat > 0 | state_fips %in% c(5, 55)),
  weights = ~weight,
  cluster = ~state_fips
)

# =========================================================
# 5. Save results
# =========================================================

cat("\n--- Saving results ---\n")

results <- list(
  twfe = list(medicaid = twfe_medicaid, uninsured = twfe_uninsured, employer = twfe_employer),
  cs = list(
    medicaid = cs_medicaid, uninsured = cs_uninsured, employer = cs_employer,
    medicaid_low = cs_medicaid_low, uninsured_low = cs_uninsured_low
  ),
  cs_agg = list(
    medicaid = cs_agg_medicaid, uninsured = cs_agg_uninsured, employer = cs_agg_employer,
    medicaid_low = cs_agg_medicaid_low, uninsured_low = cs_agg_uninsured_low
  ),
  cs_dyn = list(
    medicaid = cs_dyn_medicaid, uninsured = cs_dyn_uninsured, employer = cs_dyn_employer,
    medicaid_low = cs_dyn_medicaid_low, uninsured_low = cs_dyn_uninsured_low
  ),
  sa = list(medicaid = sa_medicaid, uninsured = sa_uninsured)
)

saveRDS(results, file.path(data_dir, "main_results.rds"))

cat("\n=== Main analysis complete ===\n")

# Print summary table
cat("\n========================================\n")
cat("SUMMARY OF MAIN RESULTS\n")
cat("========================================\n")
cat(sprintf("CS-DiD ATT (Medicaid, All PP):     %.4f (SE: %.4f)\n",
            cs_agg_medicaid$overall.att, cs_agg_medicaid$overall.se))
cat(sprintf("CS-DiD ATT (Uninsured, All PP):    %.4f (SE: %.4f)\n",
            cs_agg_uninsured$overall.att, cs_agg_uninsured$overall.se))
cat(sprintf("CS-DiD ATT (Employer, All PP):      %.4f (SE: %.4f)\n",
            cs_agg_employer$overall.att, cs_agg_employer$overall.se))
cat(sprintf("CS-DiD ATT (Medicaid, Low-Inc PP): %.4f (SE: %.4f)\n",
            cs_agg_medicaid_low$overall.att, cs_agg_medicaid_low$overall.se))
cat(sprintf("CS-DiD ATT (Uninsured, Low-Inc PP): %.4f (SE: %.4f)\n",
            cs_agg_uninsured_low$overall.att, cs_agg_uninsured_low$overall.se))
cat("========================================\n")
