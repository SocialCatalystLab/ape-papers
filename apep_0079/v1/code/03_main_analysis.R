# ==============================================================================
# 03_main_analysis.R
# Universal School Meals and Household Food Security
# Main difference-in-differences analysis
# ==============================================================================

source("output/paper_106/code/00_packages.R")

# ------------------------------------------------------------------------------
# Load analysis data
# ------------------------------------------------------------------------------

df <- read_csv(file.path(DATA_DIR, "cps_fss_analysis_school.csv"), show_col_types = FALSE)

cat("Analysis sample:", nrow(df), "household-years\n")
cat("Years:", paste(unique(df$year), collapse = ", "), "\n")
cat("Treatment states:", sum(df$treatment_group > 0), "obs\n")
cat("Control states:", sum(df$treatment_group == 0), "obs\n")

# ------------------------------------------------------------------------------
# Descriptive statistics
# ------------------------------------------------------------------------------

# Food insecurity rates by treatment status and year
desc_table <- df %>%
  mutate(treated_ever = treatment_group > 0) %>%
  group_by(year, treated_ever) %>%
  summarize(
    n = n(),
    mean_fi = mean(food_insecure, na.rm = TRUE),
    se_fi = sd(food_insecure, na.rm = TRUE) / sqrt(n()),
    mean_vlfs = mean(very_low_fs, na.rm = TRUE),
    .groups = "drop"
  )

print(desc_table)

# Save descriptives
write_csv(desc_table, file.path(TAB_DIR, "descriptive_stats.csv"))

# ------------------------------------------------------------------------------
# Simple Difference-in-Differences (TWFE)
# RESTRICTED SAMPLE: 2023 adopters + never-treated only
# This ensures identifying variation comes from switchers only
# ------------------------------------------------------------------------------

# Basic TWFE with state and year fixed effects
cat("\n=== TWFE Estimation (Restricted Sample: 2023 adopters + never-treated) ===\n")

# Create restricted sample: exclude 2022 adopters
# 2022 adopters have treatment_group == 2022
df_restricted <- df %>%
  filter(treatment_group != 2022)

cat("Restricted sample:", nrow(df_restricted), "obs\n")
cat("States/DC in restricted sample:", n_distinct(df_restricted$state_fips), "\n")
cat("  2023 adopters (CO, MI, MN, NM):", sum(df_restricted$treatment_group == 2023), "obs\n")
cat("  Never-treated:", sum(df_restricted$treatment_group == 0), "obs\n")

# Main outcome: food insecurity
twfe_fi <- feols(
  food_insecure ~ treated | state_fips + year,
  data = df_restricted,
  weights = ~weight,
  cluster = ~state_fips
)

# Very low food security
twfe_vlfs <- feols(
  very_low_fs ~ treated | state_fips + year,
  data = df_restricted,
  weights = ~weight,
  cluster = ~state_fips
)

# Print results
cat("\nFood Insecurity (TWFE, 2023 adopters + never-treated):\n")
summary(twfe_fi)

cat("\nVery Low Food Security (TWFE, 2023 adopters + never-treated):\n")
summary(twfe_vlfs)

# ------------------------------------------------------------------------------
# Callaway-Sant'Anna Estimator
# Note: CS requires panel data with multiple pre-treatment periods
# With only 2022-2024 data and 2022 adoption, we have limited pre-periods
# We'll demonstrate the approach but acknowledge the limitation
# ------------------------------------------------------------------------------

cat("\n=== Callaway-Sant'Anna Estimation ===\n")

# For CS, we need: id, time, group (first treatment year), outcome
# Create a pseudo-panel using state as the unit

# Aggregate to state-year level for CS
state_year <- df %>%
  group_by(state_fips, year, treatment_group) %>%
  summarize(
    food_insecure = weighted.mean(food_insecure, weight, na.rm = TRUE),
    very_low_fs = weighted.mean(very_low_fs, weight, na.rm = TRUE),
    n_hh = n(),
    total_weight = sum(weight, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  # CS group: 0 = never treated, otherwise first treatment year
  mutate(
    first_treat = if_else(treatment_group == 0, 0L, treatment_group)
  )

cat("State-year observations:", nrow(state_year), "\n")
cat("Treatment cohorts:", paste(unique(state_year$first_treat[state_year$first_treat > 0]), collapse = ", "), "\n")

# Check if we have enough variation for CS
n_pre_periods <- state_year %>%
  filter(first_treat > 0) %>%
  group_by(first_treat) %>%
  summarize(
    n_pre = sum(year < first_treat),
    n_post = sum(year >= first_treat)
  )

print(n_pre_periods)

# CS requires at least 1 pre-treatment period
# With 2022 adopters, year 2022 is the first treated year, so no true pre-period in our data
# With 2023 adopters, year 2022 is pre-treatment

cat("\n⚠️  WARNING: Limited pre-treatment periods available\n")
cat("2022 cohort has 0 pre-periods in this data extract\n")
cat("2023 cohort has 1 pre-period (2022)\n")
cat("\nFull analysis requires 2015-2021 data for proper pre-trend tests\n")

# Attempt CS with available data
# For 2023 adopters only (to have at least one pre-period)

df_2023_cohort <- state_year %>%
  filter(first_treat %in% c(0, 2023))

if (nrow(df_2023_cohort) > 0 && any(df_2023_cohort$first_treat == 2023)) {

  tryCatch({
    cs_out <- att_gt(
      yname = "food_insecure",
      tname = "year",
      idname = "state_fips",
      gname = "first_treat",
      data = df_2023_cohort,
      control_group = "nevertreated",
      bstrap = TRUE,
      biters = 1000,
      cband = TRUE
    )

    cat("\nCS Estimates (2023 cohort only):\n")
    print(summary(cs_out))

    # Aggregate to simple ATT
    cs_agg <- aggte(cs_out, type = "simple")
    cat("\nAggregated ATT:\n")
    print(summary(cs_agg))

    # Save
    saveRDS(cs_out, file.path(DATA_DIR, "cs_estimates.rds"))

  }, error = function(e) {
    cat("\nCS estimation failed:", conditionMessage(e), "\n")
    cat("This is expected with limited pre-treatment periods\n")
  })

} else {
  cat("\nInsufficient data for CS estimation\n")
}

# ------------------------------------------------------------------------------
# Alternative: Simple Difference-in-Means
# Given data limitations, report simple treated vs control comparison
# ------------------------------------------------------------------------------

cat("\n=== Simple Difference-in-Means ===\n")

# For post-treatment periods (2023-2024)
post_treatment <- df %>%
  filter(year >= 2023) %>%
  mutate(ever_treated = treatment_group > 0)

did_simple <- post_treatment %>%
  group_by(ever_treated) %>%
  summarize(
    mean_fi = weighted.mean(food_insecure, weight, na.rm = TRUE),
    se_fi = sqrt(sum(weight^2 * (food_insecure - weighted.mean(food_insecure, weight, na.rm = TRUE))^2, na.rm = TRUE)) /
            sum(weight, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  )

print(did_simple)

diff_in_means <- did_simple$mean_fi[2] - did_simple$mean_fi[1]
cat("\nDifference (Treated - Control):", round(diff_in_means * 100, 2), "percentage points\n")

# ------------------------------------------------------------------------------
# Event Study (with limited periods)
# ------------------------------------------------------------------------------

cat("\n=== Event Study (Limited Periods) ===\n")

# Create relative time variable
df_es <- df %>%
  mutate(
    rel_time = if_else(treatment_group > 0, year - treatment_group, NA_integer_),
    # For event study, need to bin
    rel_time_binned = case_when(
      treatment_group == 0 ~ "Never",
      rel_time <= -1 ~ "-1",
      rel_time == 0 ~ "0",
      rel_time == 1 ~ "1",
      rel_time >= 2 ~ "2+",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(rel_time_binned) | treatment_group == 0)

# Event study regression
# Note: Very limited power with few periods
es_reg <- feols(
  food_insecure ~ i(rel_time_binned, ref = "-1") | state_fips + year,
  data = df_es,
  weights = ~weight,
  cluster = ~state_fips
)

cat("\nEvent Study Coefficients:\n")
summary(es_reg)

# ------------------------------------------------------------------------------
# Save main results
# ------------------------------------------------------------------------------

# Create results summary
results_summary <- tibble(
  specification = c("TWFE", "TWFE Very Low FS", "Simple DiM"),
  estimate = c(coef(twfe_fi)["treated"],
               coef(twfe_vlfs)["treated"],
               diff_in_means),
  se = c(se(twfe_fi)["treated"],
         se(twfe_vlfs)["treated"],
         NA),
  n_obs = c(nobs(twfe_fi), nobs(twfe_vlfs), nrow(post_treatment))
)

print(results_summary)
write_csv(results_summary, file.path(TAB_DIR, "main_results.csv"))

# Save regression objects
saveRDS(twfe_fi, file.path(DATA_DIR, "twfe_fi.rds"))
saveRDS(twfe_vlfs, file.path(DATA_DIR, "twfe_vlfs.rds"))
saveRDS(es_reg, file.path(DATA_DIR, "event_study.rds"))

cat("\n=== 03_main_analysis.R complete ===\n")
cat("\n⚠️  IMPORTANT LIMITATION:\n")
cat("This analysis uses only 2022-2024 data\n")
cat("Full credibility requires 2015-2021 pre-treatment data\n")
cat("Results should be interpreted as suggestive, not causal\n")
