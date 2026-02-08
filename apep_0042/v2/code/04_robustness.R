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

# Load treatment data for state names
treatment_data <- read_csv(file.path(data_dir, "treatment_data.csv"),
                           show_col_types = FALSE)

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
# ROBUSTNESS 3: Placebo Test - Workers with Existing Plans
# -----------------------------------------------------------------------------

# IMPORTANT: Treatment timing targets large employers for REGISTRATION, but
# the COVERAGE EFFECT should concentrate at small firms (who lack existing plans).
# Large firm workers likely already have employer-sponsored plans and should
# NOT show coverage increases from auto-IRA mandates.
#
# This placebo tests: Do large firm workers (who already have plans) show
# spurious coverage changes? If so, suggests confounding.

cat("\n", rep("=", 60), "\n")
cat("ROBUSTNESS 3: Placebo - Large Firm Workers (Likely Already Covered)\n")
cat(rep("=", 60), "\n\n")

cat("Rationale: Auto-IRA mandates target employers WITHOUT existing plans.\n")
cat("Large firms (100+ employees) typically already offer retirement plans.\n")
cat("Effect on large firm workers should be near zero (placebo check).\n\n")

df_large <- df %>%
  filter(small_firm == 0) %>%  # Large firms only (100+ employees)
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
# ROBUSTNESS 4: Heterogeneity by Firm Size (Target Population)
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

age_results <- list()

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

    age_results[[ag]] <- tibble(
      age_group = ag,
      att = agg_age$overall.att,
      se = agg_age$overall.se
    )
  }
}

if (length(age_results) > 0) {
  age_het <- bind_rows(age_results)
  write_csv(age_het, file.path(data_dir, "heterogeneity_age.csv"))
}

# -----------------------------------------------------------------------------
# ROBUSTNESS 6: SYSTEMATIC LEAVE-ONE-OUT ANALYSIS
# -----------------------------------------------------------------------------

cat("\n", rep("=", 60), "\n")
cat("ROBUSTNESS 6: SYSTEMATIC LEAVE-ONE-OUT ANALYSIS\n")
cat(rep("=", 60), "\n\n")

# Get main result for comparison
agg_main <- aggte(cs_out, type = "simple")
main_att <- agg_main$overall.att
main_se <- agg_main$overall.se

cat("Full sample ATT:", round(main_att, 4), "(SE:", round(main_se, 4), ")\n\n")

# Get list of treated states
treated_states <- treatment_data %>%
  select(statefip, state_abbr, first_treat_year, program_name) %>%
  arrange(first_treat_year)

cat("Running leave-one-out for all", nrow(treated_states), "treated states...\n\n")

loo_results <- list()

for (i in 1:nrow(treated_states)) {
  exclude_state <- treated_states$statefip[i]
  exclude_abbr <- treated_states$state_abbr[i]
  exclude_year <- treated_states$first_treat_year[i]

  # Exclude this state
  df_loo <- df_state_year %>%
    filter(statefip != exclude_state) %>%
    mutate(state_id = as.numeric(factor(statefip)))  # Re-number states

  # Re-estimate
  cs_loo <- try(att_gt(
    yname = "pension_rate",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = df_loo,
    control_group = "nevertreated",
    anticipation = 0,
    bstrap = TRUE,
    biters = 500,
    clustervars = "statefip"
  ), silent = TRUE)

  if (!inherits(cs_loo, "try-error")) {
    agg_loo <- aggte(cs_loo, type = "simple")
    loo_att <- agg_loo$overall.att
    loo_se <- agg_loo$overall.se
    change <- loo_att - main_att

    cat(sprintf("Excluding %-2s (%d): ATT = %7.4f (SE = %6.4f)  Change = %+7.4f\n",
                exclude_abbr, exclude_year, loo_att, loo_se, change))

    loo_results[[exclude_abbr]] <- tibble(
      excluded_state = exclude_abbr,
      statefip = exclude_state,
      cohort = exclude_year,
      program = treated_states$program_name[i],
      att = loo_att,
      se = loo_se,
      change_from_full = change,
      pct_change = change / abs(main_att) * 100,
      significant = ifelse((loo_att - 1.96 * loo_se) > 0 |
                             (loo_att + 1.96 * loo_se) < 0, "*", "")
    )
  } else {
    cat(sprintf("Excluding %-2s (%d): FAILED\n", exclude_abbr, exclude_year))
  }
}

# Combine results
loo_df <- bind_rows(loo_results) %>%
  arrange(change_from_full)

cat("\n\n=== LEAVE-ONE-OUT SUMMARY ===\n\n")
print(loo_df %>% select(excluded_state, cohort, att, se, change_from_full, significant))

# Identify influential states
cat("\n\nInfluence Analysis:\n")
cat("-------------------\n")

# Most influential: largest absolute change
most_influential <- loo_df %>%
  arrange(desc(abs(change_from_full))) %>%
  head(3)

cat("\nMost Influential States (largest impact on ATT):\n")
for (i in 1:nrow(most_influential)) {
  cat(sprintf("  %d. %s: Excluding increases ATT by %+.4f pp (%.1f%% change)\n",
              i,
              most_influential$excluded_state[i],
              most_influential$change_from_full[i],
              most_influential$pct_change[i]))
}

# States that flip significance
if (main_att - 1.96 * main_se <= 0 & main_att + 1.96 * main_se >= 0) {
  # Main result is not significant
  sig_loo <- loo_df %>% filter(significant == "*")
  if (nrow(sig_loo) > 0) {
    cat("\nStates whose exclusion yields significant result:\n")
    for (i in 1:nrow(sig_loo)) {
      cat(sprintf("  - %s: ATT = %.4f (SE = %.4f)\n",
                  sig_loo$excluded_state[i],
                  sig_loo$att[i],
                  sig_loo$se[i]))
    }
  }
}

# Save results
write_csv(loo_df, file.path(data_dir, "leave_one_out_results.csv"))

# Add full sample row for comparison
loo_full <- bind_rows(
  tibble(
    excluded_state = "None (Full)",
    statefip = NA,
    cohort = NA,
    program = NA,
    att = main_att,
    se = main_se,
    change_from_full = 0,
    pct_change = 0,
    significant = ifelse((main_att - 1.96 * main_se) > 0 |
                           (main_att + 1.96 * main_se) < 0, "*", "")
  ),
  loo_df
)

write_csv(loo_full, file.path(data_dir, "leave_one_out_full.csv"))

# -----------------------------------------------------------------------------
# Summary Table
# -----------------------------------------------------------------------------

cat("\n", rep("=", 60), "\n")
cat("ROBUSTNESS SUMMARY\n")
cat(rep("=", 60), "\n\n")

results_summary <- tibble(
  Specification = c(
    "Main (Never-Treated Control)",
    "Not-Yet-Treated Control",
    "With Covariates",
    "Placebo: Large Firms (100+)"
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
