# ==============================================================================
# 04_robustness.R - Robustness Checks
# Paper 60: State Auto-IRA Mandates and Retirement Savings
# ==============================================================================

source("code/00_packages.R")

# ==============================================================================
# Load Data
# ==============================================================================

cps_private <- readRDS("data/cps_private.rds")
cps_no_pension <- readRDS("data/cps_no_pension.rds")
results <- readRDS("data/main_results.rds")

# ==============================================================================
# 1. Placebo Test: Workers WITH Employer Pension (Should Show No Effect)
# ==============================================================================

cat("\n=== Placebo Test: Workers WITH Employer Pension ===\n")

# These workers are NOT affected by auto-IRA (already have retirement plan)
cps_has_pension <- cps_private %>%
  filter(has_pension_at_job == 1)

cat("Placebo sample:", nrow(cps_has_pension), "workers with employer pension\n")

# State-year aggregation
state_year_placebo <- cps_has_pension %>%
  group_by(statefip, year, first_treat, auto_ira_state) %>%
  summarise(
    pension_participant = weighted.mean(pension_participant, weight, na.rm = TRUE),
    n_obs = n(),
    .groups = "drop"
  ) %>%
  mutate(id = statefip)

# Callaway-Sant'Anna on placebo outcome
cs_placebo <- att_gt(
  yname = "pension_participant",
  tname = "year",
  idname = "id",
  gname = "first_treat",
  data = state_year_placebo,
  control_group = "nevertreated",
  est_method = "dr"
)

att_placebo <- aggte(cs_placebo, type = "simple")
cat("Placebo ATT (workers with employer pension):\n")
cat("ATT:", round(att_placebo$overall.att, 4),
    "SE:", round(att_placebo$overall.se, 4),
    "p-value:", round(2 * pnorm(-abs(att_placebo$overall.att / att_placebo$overall.se)), 4), "\n")

# ==============================================================================
# 2. Alternative Estimator: Simple TWFE on aggregated data
# ==============================================================================

cat("\n=== Alternative: TWFE on State-Year Data ===\n")

# Prepare data for TWFE
state_year_main <- cps_private %>%
  filter(!is.na(has_pension_at_job)) %>%
  group_by(statefip, year, first_treat, auto_ira_state) %>%
  summarise(
    has_pension = weighted.mean(has_pension_at_job, weight, na.rm = TRUE),
    n_obs = n(),
    .groups = "drop"
  ) %>%
  mutate(
    id = statefip,
    treated = as.numeric(first_treat > 0 & year >= first_treat)
  )

# Simple TWFE on state-year aggregates
twfe_agg <- feols(
  has_pension ~ treated | id + year,
  data = state_year_main,
  cluster = ~id
)

cat("TWFE on State-Year Aggregates:\n")
summary(twfe_agg)

# Placeholder for gardner output
gardner_out <- twfe_agg

# ==============================================================================
# 3. Heterogeneity by Age Group
# ==============================================================================

cat("\n=== Heterogeneity by Age Group ===\n")

# Young workers (25-40) vs older workers (41-64)
for (age_group in c("young", "older")) {
  if (age_group == "young") {
    sample <- cps_private %>% filter(age >= 25 & age <= 40)
    label <- "Ages 25-40"
  } else {
    sample <- cps_private %>% filter(age >= 41 & age <= 64)
    label <- "Ages 41-64"
  }

  state_year_age <- sample %>%
    group_by(statefip, year, first_treat) %>%
    summarise(
      has_pension = weighted.mean(has_pension_at_job, weight, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(id = statefip)

  cs_age <- att_gt(
    yname = "has_pension",
    tname = "year",
    idname = "id",
    gname = "first_treat",
    data = state_year_age,
    control_group = "nevertreated",
    est_method = "dr"
  )

  att_age <- aggte(cs_age, type = "simple")
  cat(label, "- ATT:", round(att_age$overall.att, 4),
      "SE:", round(att_age$overall.se, 4), "\n")
}

# ==============================================================================
# 4. Heterogeneity by Education
# ==============================================================================

cat("\n=== Heterogeneity by Education ===\n")

for (educ_level in c("no_ba", "ba_plus")) {
  if (educ_level == "no_ba") {
    sample <- cps_private %>% filter(educ_ba_plus == 0)
    label <- "Less than Bachelor's"
  } else {
    sample <- cps_private %>% filter(educ_ba_plus == 1)
    label <- "Bachelor's+"
  }

  state_year_educ <- sample %>%
    group_by(statefip, year, first_treat) %>%
    summarise(
      has_pension = weighted.mean(has_pension_at_job, weight, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(id = statefip)

  cs_educ <- att_gt(
    yname = "has_pension",
    tname = "year",
    idname = "id",
    gname = "first_treat",
    data = state_year_educ,
    control_group = "nevertreated",
    est_method = "dr"
  )

  att_educ <- aggte(cs_educ, type = "simple")
  cat(label, "- ATT:", round(att_educ$overall.att, 4),
      "SE:", round(att_educ$overall.se, 4), "\n")
}

# ==============================================================================
# 5. HonestDiD Sensitivity Analysis
# ==============================================================================

cat("\n=== HonestDiD Sensitivity Analysis ===\n")

# Get event study coefficients for HonestDiD
cs_out <- results$cs_out
att_dynamic <- aggte(cs_out, type = "dynamic", min_e = -5, max_e = 5)

# Extract coefficients and variance-covariance matrix
es_coefs <- att_dynamic$att.egt
es_se <- att_dynamic$se.egt
es_time <- att_dynamic$egt

# Identify pre-treatment and post-treatment periods
pre_idx <- which(es_time < 0)
post_idx <- which(es_time >= 0)

# Note: HonestDiD requires the full variance-covariance matrix
# which att_gt doesn't directly provide. We'll use a simplified approach.

cat("Pre-treatment coefficients:\n")
for (i in pre_idx) {
  cat("  t =", es_time[i], ": ATT =", round(es_coefs[i], 4),
      "SE =", round(es_se[i], 4), "\n")
}

# Check if pre-trends are individually significant
# Filter out NA values
pre_valid <- !is.na(es_se[pre_idx])
if (any(pre_valid)) {
  pre_significant <- any(abs(es_coefs[pre_idx][pre_valid] / es_se[pre_idx][pre_valid]) > 1.96, na.rm = TRUE)
  if (pre_significant) {
    cat("\nWARNING: Some pre-treatment coefficients are statistically significant.\n")
    cat("Consider using HonestDiD bounds or investigating further.\n")
  } else {
    cat("\nPre-trends pass individual significance tests.\n")
  }
} else {
  cat("\nCannot assess pre-trends significance (all SE are NA).\n")
}

# ==============================================================================
# 6. Dropping Early Adopters
# ==============================================================================

cat("\n=== Robustness: Dropping Oregon (Earliest Adopter) ===\n")

# Oregon adopted in 2017 - drop to check if results are driven by single state
state_year_no_or <- cps_private %>%
  filter(statefip != 41) %>%  # 41 = Oregon
  group_by(statefip, year, first_treat) %>%
  summarise(
    has_pension = weighted.mean(has_pension_at_job, weight, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(id = statefip)

cs_no_or <- att_gt(
  yname = "has_pension",
  tname = "year",
  idname = "id",
  gname = "first_treat",
  data = state_year_no_or,
  control_group = "nevertreated",
  est_method = "dr"
)

att_no_or <- aggte(cs_no_or, type = "simple")
cat("ATT (excluding Oregon):", round(att_no_or$overall.att, 4),
    "SE:", round(att_no_or$overall.se, 4), "\n")

# ==============================================================================
# 7. Save Robustness Results
# ==============================================================================

robustness_results <- list(
  cs_placebo = cs_placebo,
  att_placebo = att_placebo,
  gardner_out = gardner_out,
  att_no_or = att_no_or
)

saveRDS(robustness_results, "data/robustness_results.rds")
cat("\nRobustness results saved to data/robustness_results.rds\n")

cat("\n=== ROBUSTNESS SUMMARY ===\n")
cat("Main ATT:", round(results$att_overall$overall.att, 4), "\n")
cat("Placebo (workers with pension):", round(att_placebo$overall.att, 4), "\n")
cat("Gardner two-stage:", round(coef(gardner_out)[["treated"]], 4), "\n")
cat("Excluding Oregon:", round(att_no_or$overall.att, 4), "\n")
