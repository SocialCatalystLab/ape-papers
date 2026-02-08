# =============================================================================
# 04_robustness.R
# Robustness Checks for Auto-IRA Analysis
# =============================================================================

source("00_packages.R")

# -----------------------------------------------------------------------------
# Load Data and Main Results
# -----------------------------------------------------------------------------

cat("Loading data and main results...\n")
df <- readRDS(file.path(data_dir, "cps_asec_clean.rds"))
cs_out <- readRDS(file.path(data_dir, "cs_results.rds"))

# Collapse to state-year
df_state_year <- df %>%
  group_by(statefip, year, first_treat) %>%
  summarise(
    pension_rate = weighted.mean(has_pension, weight, na.rm = TRUE),
    pct_female = weighted.mean(female, weight, na.rm = TRUE),
    pct_college = weighted.mean(college, weight, na.rm = TRUE),
    pct_married = weighted.mean(married, weight, na.rm = TRUE),
    pct_small_firm = weighted.mean(small_firm, weight, na.rm = TRUE),
    mean_age = weighted.mean(age, weight, na.rm = TRUE),
    n_obs = n(),
    sum_weight = sum(weight, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    state_id = as.numeric(factor(statefip)),
    first_treat = replace_na(first_treat, 0),
    post = ifelse(first_treat > 0 & year >= first_treat, 1, 0)
  )

# -----------------------------------------------------------------------------
# ROBUSTNESS 1: Not-Yet-Treated as Control Group
# -----------------------------------------------------------------------------

cat("\n", rep("=", 60), "\n")
cat("ROBUSTNESS 1: Not-Yet-Treated Control Group\n")
cat(rep("=", 60), "\n\n")

cs_nyt <- att_gt(
  yname = "pension_rate",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = df_state_year,
  control_group = "notyettreated",  # Not-yet-treated as control
  anticipation = 0,
  bstrap = TRUE,
  biters = 1000,
  clustervars = "statefip"
)

agg_nyt <- aggte(cs_nyt, type = "simple")
cat("ATT (Not-Yet-Treated control):", round(agg_nyt$overall.att, 4),
    "(SE:", round(agg_nyt$overall.se, 4), ")\n")

saveRDS(cs_nyt, file.path(data_dir, "cs_nyt.rds"))

# -----------------------------------------------------------------------------
# ROBUSTNESS 2: With Covariates
# -----------------------------------------------------------------------------

cat("\n", rep("=", 60), "\n")
cat("ROBUSTNESS 2: With Covariates (Conditional Parallel Trends)\n")
cat(rep("=", 60), "\n\n")

cs_cov <- att_gt(
  yname = "pension_rate",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = df_state_year,
  control_group = "nevertreated",
  xformla = ~ pct_female + pct_college + mean_age,  # Covariates
  anticipation = 0,
  est_method = "dr",
  bstrap = TRUE,
  biters = 1000,
  clustervars = "statefip"
)

agg_cov <- aggte(cs_cov, type = "simple")
cat("ATT (with covariates):", round(agg_cov$overall.att, 4),
    "(SE:", round(agg_cov$overall.se, 4), ")\n")

saveRDS(cs_cov, file.path(data_dir, "cs_covariates.rds"))

# -----------------------------------------------------------------------------
# ROBUSTNESS 3: Placebo Test - Large Employers (500+)
# -----------------------------------------------------------------------------

cat("\n", rep("=", 60), "\n")
cat("ROBUSTNESS 3: Placebo - Large Employers (Should Be Unaffected)\n")
cat(rep("=", 60), "\n\n")

# Workers at large firms should not be affected by auto-IRA mandates
# because their employers likely already offer plans

df_large <- df %>%
  filter(small_firm == 0) %>%  # Large firms only
  group_by(statefip, year, first_treat) %>%
  summarise(
    pension_rate = weighted.mean(has_pension, weight, na.rm = TRUE),
    n_obs = n(),
    .groups = "drop"
  ) %>%
  mutate(
    state_id = as.numeric(factor(statefip)),
    first_treat = replace_na(first_treat, 0)
  )

if (nrow(df_large) > 50) {
  cs_placebo <- att_gt(
    yname = "pension_rate",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = df_large,
    control_group = "nevertreated",
    anticipation = 0,
    bstrap = TRUE,
    biters = 1000,
    clustervars = "statefip"
  )

  agg_placebo <- aggte(cs_placebo, type = "simple")
  cat("Placebo ATT (large firms):", round(agg_placebo$overall.att, 4),
      "(SE:", round(agg_placebo$overall.se, 4), ")\n")
  cat("Expected: Near zero if mandate targets small employers\n")

  saveRDS(cs_placebo, file.path(data_dir, "cs_placebo_large.rds"))
} else {
  cat("Insufficient observations for large firm placebo test\n")
}

# -----------------------------------------------------------------------------
# ROBUSTNESS 4: Heterogeneity by Firm Size
# -----------------------------------------------------------------------------

cat("\n", rep("=", 60), "\n")
cat("ROBUSTNESS 4: Heterogeneity by Firm Size\n")
cat(rep("=", 60), "\n\n")

# Small firms (< 100 employees) - should see larger effects
df_small <- df %>%
  filter(small_firm == 1) %>%
  group_by(statefip, year, first_treat) %>%
  summarise(
    pension_rate = weighted.mean(has_pension, weight, na.rm = TRUE),
    n_obs = n(),
    .groups = "drop"
  ) %>%
  mutate(
    state_id = as.numeric(factor(statefip)),
    first_treat = replace_na(first_treat, 0)
  )

if (nrow(df_small) > 50) {
  cs_small <- att_gt(
    yname = "pension_rate",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = df_small,
    control_group = "nevertreated",
    anticipation = 0,
    bstrap = TRUE,
    biters = 1000,
    clustervars = "statefip"
  )

  agg_small <- aggte(cs_small, type = "simple")
  cat("ATT (small firms only):", round(agg_small$overall.att, 4),
      "(SE:", round(agg_small$overall.se, 4), ")\n")
  cat("Expected: Larger than overall effect\n")

  saveRDS(cs_small, file.path(data_dir, "cs_small_firms.rds"))
} else {
  cat("Insufficient observations for small firm analysis\n")
}

# -----------------------------------------------------------------------------
# ROBUSTNESS 5: Heterogeneity by Age Group
# -----------------------------------------------------------------------------

cat("\n", rep("=", 60), "\n")
cat("ROBUSTNESS 5: Heterogeneity by Age Group\n")
cat(rep("=", 60), "\n\n")

for (ag in c("18-29", "30-44", "45-54", "55-64")) {

  df_age <- df %>%
    filter(age_group == ag) %>%
    group_by(statefip, year, first_treat) %>%
    summarise(
      pension_rate = weighted.mean(has_pension, weight, na.rm = TRUE),
      n_obs = n(),
      .groups = "drop"
    ) %>%
    mutate(
      state_id = as.numeric(factor(statefip)),
      first_treat = replace_na(first_treat, 0)
    )

  if (nrow(df_age) > 50) {
    cs_age <- att_gt(
      yname = "pension_rate",
      tname = "year",
      idname = "state_id",
      gname = "first_treat",
      data = df_age,
      control_group = "nevertreated",
      anticipation = 0,
      bstrap = TRUE,
      biters = 500,
      clustervars = "statefip"
    )

    agg_age <- aggte(cs_age, type = "simple")
    cat("ATT (age", ag, "):", round(agg_age$overall.att, 4),
        "(SE:", round(agg_age$overall.se, 4), ")\n")
  }
}

# -----------------------------------------------------------------------------
# Summary Table
# -----------------------------------------------------------------------------

cat("\n", rep("=", 60), "\n")
cat("ROBUSTNESS SUMMARY\n")
cat(rep("=", 60), "\n\n")

# Load main result for comparison
agg_main <- aggte(cs_out, type = "simple")

results_summary <- tibble(
  Specification = c(
    "Main (Never-Treated Control)",
    "Not-Yet-Treated Control",
    "With Covariates",
    "Placebo: Large Firms"
  ),
  ATT = c(
    agg_main$overall.att,
    agg_nyt$overall.att,
    agg_cov$overall.att,
    ifelse(exists("agg_placebo"), agg_placebo$overall.att, NA)
  ),
  SE = c(
    agg_main$overall.se,
    agg_nyt$overall.se,
    agg_cov$overall.se,
    ifelse(exists("agg_placebo"), agg_placebo$overall.se, NA)
  )
) %>%
  mutate(
    CI_Lower = ATT - 1.96 * SE,
    CI_Upper = ATT + 1.96 * SE,
    Significant = ifelse(CI_Lower > 0 | CI_Upper < 0, "*", "")
  )

print(results_summary)

write_csv(results_summary, file.path(data_dir, "robustness_summary.csv"))

cat("\nRobustness checks complete.\n")
cat("Results saved to:", data_dir, "\n")
