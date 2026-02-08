##############################################################################
# 03_main_analysis.R - Primary DiD analysis
# Revision of apep_0156: Medicaid Postpartum Coverage Extensions (v4)
# CHANGES: Added cohort-specific ATTs extraction, DDD pre-trend coefficient export
##############################################################################

source("00_packages.R")

# Set seed for reproducibility of all bootstrap procedures
set.seed(20240153)

cat("=== Main Analysis ===\n")

# Load data
state_year_pp <- fread(file.path(data_dir, "state_year_postpartum.csv"))
state_year_pp_low <- fread(file.path(data_dir, "state_year_postpartum_lowinc.csv"))
df_postpartum <- fread(file.path(data_dir, "acs_postpartum.csv"))
df_pp_lowinc <- fread(file.path(data_dir, "acs_postpartum_lowinc.csv"))
df_nonpostpartum <- fread(file.path(data_dir, "acs_nonpostpartum_lowinc.csv"))
state_year_nonpp_low <- fread(file.path(data_dir, "state_year_nonpp_lowinc.csv"))

# =========================================================
# 1. TWFE Baseline (for comparison, known to be biased)
# =========================================================

cat("\n--- TWFE Baseline ---\n")

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

cs_agg_medicaid <- aggte(cs_medicaid, type = "simple")
cat("\nOverall ATT (Medicaid):\n")
summary(cs_agg_medicaid)

cs_dyn_medicaid <- aggte(cs_medicaid, type = "dynamic", min_e = -4, max_e = 3)
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

cs_dyn_uninsured <- aggte(cs_uninsured, type = "dynamic", min_e = -4, max_e = 3)

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

cs_dyn_employer <- aggte(cs_employer, type = "dynamic", min_e = -4, max_e = 3)

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

cs_dyn_medicaid_low <- aggte(cs_medicaid_low, type = "dynamic", min_e = -4, max_e = 3)

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

cs_dyn_uninsured_low <- aggte(cs_uninsured_low, type = "dynamic", min_e = -4, max_e = 3)

# =========================================================
# 4. Sun-Abraham TWFE Event Study (Alternative estimator)
# =========================================================

cat("\n--- Sun-Abraham Event Study ---\n")

sa_medicaid <- feols(
  medicaid ~ sunab(first_treat, year) | state_fips + year,
  data = df_postpartum %>% filter(first_treat > 0 | state_fips %in% c(5, 55, 16, 19)),
  weights = ~weight,
  cluster = ~state_fips
)

cat("Sun-Abraham Event Study (Medicaid):\n")
summary(sa_medicaid)

sa_uninsured <- feols(
  uninsured ~ sunab(first_treat, year) | state_fips + year,
  data = df_postpartum %>% filter(first_treat > 0 | state_fips %in% c(5, 55, 16, 19)),
  weights = ~weight,
  cluster = ~state_fips
)

# =========================================================
# 5. CS-DiD: Calendar-time aggregation (by PHE status)
# =========================================================

cat("\n--- Calendar-Time ATT (PHE vs Post-PHE) ---\n")

cs_cal_medicaid <- aggte(cs_medicaid, type = "calendar")
cat("Calendar-time ATT (Medicaid):\n")
summary(cs_cal_medicaid)

# =========================================================
# 6. Triple-Difference (DDD) Design
# =========================================================

cat("\n=== Triple-Difference (DDD) Design ===\n")

# --- 6a. Create stacked DDD dataset ---
pp_stack <- df_pp_lowinc %>%
  select(state_fips, year, first_treat, treated, medicaid, uninsured,
         employer_ins, weight, age, married, race_eth, educ) %>%
  mutate(postpartum_ind = 1L)

nonpp_stack <- df_nonpostpartum %>%
  select(state_fips, year, first_treat, treated, medicaid, uninsured,
         employer_ins, weight, age, married, race_eth, educ) %>%
  mutate(postpartum_ind = 0L)

ddd_data <- bind_rows(pp_stack, nonpp_stack) %>%
  mutate(
    postpartum_ind = as.integer(postpartum_ind),
    state_fips = as.integer(state_fips),
    year = as.integer(year)
  )

cat(sprintf("DDD sample: %d rows (pp: %d, non-pp: %d)\n",
            nrow(ddd_data), sum(ddd_data$postpartum_ind == 1),
            sum(ddd_data$postpartum_ind == 0)))

# --- 6b. DDD via fixest ---
ddd_medicaid <- feols(
  medicaid ~ treated:postpartum_ind | state_fips^postpartum_ind + year^postpartum_ind,
  data = ddd_data,
  weights = ~weight,
  cluster = ~state_fips
)

cat("\nDDD Result (Medicaid):\n")
summary(ddd_medicaid)

ddd_uninsured <- feols(
  uninsured ~ treated:postpartum_ind | state_fips^postpartum_ind + year^postpartum_ind,
  data = ddd_data,
  weights = ~weight,
  cluster = ~state_fips
)

cat("\nDDD Result (Uninsured):\n")
summary(ddd_uninsured)

ddd_employer <- feols(
  employer_ins ~ treated:postpartum_ind | state_fips^postpartum_ind + year^postpartum_ind,
  data = ddd_data,
  weights = ~weight,
  cluster = ~state_fips
)

cat("\nDDD Result (Employer - should be null under DDD):\n")
summary(ddd_employer)

# --- 6c. DDD CS-DiD: Differenced outcome approach ---
cat("\n--- DDD via CS-DiD on differenced outcome ---\n")

state_year_pp_low2 <- state_year_pp_low %>%
  select(state_fips, year, first_treat,
         pp_medicaid = medicaid_rate, pp_uninsured = uninsured_rate,
         pp_employer = employer_rate, pp_weight = total_weight)

state_year_nonpp_low2 <- state_year_nonpp_low %>%
  mutate(
    state_id = as.integer(factor(state_fips)),
    first_treat = as.integer(first_treat)
  ) %>%
  select(state_fips, year, first_treat,
         nonpp_medicaid = medicaid_rate, nonpp_uninsured = uninsured_rate,
         nonpp_employer = employer_rate, nonpp_weight = total_weight)

state_year_diff <- inner_join(state_year_pp_low2, state_year_nonpp_low2,
                               by = c("state_fips", "year", "first_treat")) %>%
  mutate(
    diff_medicaid = pp_medicaid - nonpp_medicaid,
    diff_uninsured = pp_uninsured - nonpp_uninsured,
    diff_employer = pp_employer - nonpp_employer,
    total_weight = pp_weight,
    state_id = as.integer(factor(state_fips)),
    first_treat = as.integer(first_treat)
  ) %>%
  filter(!is.na(diff_medicaid))

# CS-DiD on differenced Medicaid
cs_ddd_medicaid <- tryCatch({
  att_gt(
    yname = "diff_medicaid",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = as.data.frame(state_year_diff),
    control_group = "nevertreated",
    weightsname = "total_weight",
    bstrap = TRUE,
    cband = TRUE,
    biters = 1000
  )
}, error = function(e) {
  cat("  CS-DiD DDD failed:", e$message, "\n")
  NULL
})

cs_agg_ddd_medicaid <- NULL
cs_dyn_ddd_medicaid <- NULL
if (!is.null(cs_ddd_medicaid)) {
  cs_agg_ddd_medicaid <- aggte(cs_ddd_medicaid, type = "simple")
  cat("\nDDD CS-DiD ATT (diff Medicaid: pp - nonpp):\n")
  summary(cs_agg_ddd_medicaid)

  # DIAGNOSTIC: Print exact value to verify sign for text consistency
  cat(sprintf("\n*** DIAGNOSTIC: DDD CS-DiD ATT = %.4f (SE = %.4f) ***\n",
              cs_agg_ddd_medicaid$overall.att, cs_agg_ddd_medicaid$overall.se))
  cat(sprintf("*** In percentage points: %.2f pp ***\n",
              cs_agg_ddd_medicaid$overall.att * 100))

  cs_dyn_ddd_medicaid <- aggte(cs_ddd_medicaid, type = "dynamic", min_e = -4, max_e = 3)
  cat("\nDDD Dynamic ATT:\n")
  summary(cs_dyn_ddd_medicaid)
}

# =========================================================
# 6d. Cohort-Specific ATTs (GPT #9)
# =========================================================

cat("\n--- Cohort-Specific ATTs ---\n")

cs_group_medicaid <- tryCatch({
  aggte(cs_medicaid, type = "group")
}, error = function(e) {
  cat("  Cohort aggregation failed:", e$message, "\n")
  NULL
})

if (!is.null(cs_group_medicaid)) {
  cat("Cohort-specific ATTs (Medicaid):\n")
  cohort_table <- data.frame(
    cohort = cs_group_medicaid$egt,
    att = cs_group_medicaid$att.egt,
    se = cs_group_medicaid$se.egt
  )
  print(cohort_table)
}

# =========================================================
# 7. Save results
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
  cs_cal = list(medicaid = cs_cal_medicaid),
  sa = list(medicaid = sa_medicaid, uninsured = sa_uninsured),
  ddd = list(
    twfe_medicaid = ddd_medicaid, twfe_uninsured = ddd_uninsured, twfe_employer = ddd_employer,
    cs_agg_medicaid = cs_agg_ddd_medicaid,
    cs_dyn_medicaid = cs_dyn_ddd_medicaid,
    cs_att_gt = cs_ddd_medicaid
  ),
  cs_group = list(medicaid = cs_group_medicaid),
  # Store number of clusters for tables
  n_clusters = n_distinct(state_year_pp$state_fips),
  n_clusters_low = n_distinct(state_year_pp_low$state_fips),
  n_obs_pp = nrow(df_postpartum),
  n_obs_pp_low = nrow(df_pp_lowinc),
  n_obs_nonpp = nrow(df_nonpostpartum),
  n_obs_ddd = nrow(ddd_data)
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
cat(sprintf("DDD TWFE (Medicaid):                %.4f (SE: %.4f)\n",
            coef(ddd_medicaid)[1], se(ddd_medicaid)[1]))
if (!is.null(cs_agg_ddd_medicaid)) {
  cat(sprintf("DDD CS-DiD ATT (diff Medicaid):    %.4f (SE: %.4f)\n",
              cs_agg_ddd_medicaid$overall.att, cs_agg_ddd_medicaid$overall.se))
}
cat(sprintf("Number of clusters (states):        %d\n", n_distinct(state_year_pp$state_fips)))
cat("========================================\n")
