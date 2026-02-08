# =============================================================================
# 03_main_analysis.R
# Main DiD Analysis: Effect of State Auto-IRA Mandates on Retirement Coverage
# =============================================================================

source("00_packages.R")

# -----------------------------------------------------------------------------
# Load Data
# -----------------------------------------------------------------------------

cat("Loading cleaned data...\n")
df <- readRDS(file.path(data_dir, "cps_asec_clean.rds"))

cat("Observations:", nrow(df), "\n")
cat("Years:", min(df$year), "-", max(df$year), "\n")
cat("States:", n_distinct(df$statefip), "\n")

# -----------------------------------------------------------------------------
# Collapse to State-Year Level for Main Analysis
# -----------------------------------------------------------------------------

cat("\nCollapsing to state-year level...\n")

df_state_year <- df %>%
  group_by(statefip, year, first_treat) %>%
  summarise(
    # Outcome: retirement coverage rate
    pension_rate = weighted.mean(has_pension, weight, na.rm = TRUE),

    # Demographics (for covariates)
    pct_female = weighted.mean(female, weight, na.rm = TRUE),
    pct_college = weighted.mean(college, weight, na.rm = TRUE),
    pct_married = weighted.mean(married, weight, na.rm = TRUE),
    pct_white_nh = weighted.mean(white_nh, weight, na.rm = TRUE),
    mean_age = weighted.mean(age, weight, na.rm = TRUE),
    pct_small_firm = weighted.mean(small_firm, weight, na.rm = TRUE),

    # Sample size
    n_obs = n(),
    sum_weight = sum(weight, na.rm = TRUE),

    .groups = "drop"
  ) %>%
  # Create numeric state ID for panel
  mutate(
    state_id = as.numeric(factor(statefip)),
    # Ensure first_treat is 0 for never-treated
    first_treat = replace_na(first_treat, 0)
  )

cat("State-year observations:", nrow(df_state_year), "\n")

# Check treatment timing
cat("\nTreatment timing:\n")
df_state_year %>%
  filter(first_treat > 0) %>%
  distinct(statefip, first_treat) %>%
  arrange(first_treat) %>%
  print()

# -----------------------------------------------------------------------------
# MAIN ANALYSIS: Callaway-Sant'Anna (2021)
# -----------------------------------------------------------------------------

cat("\n" , rep("=", 60), "\n")
cat("CALLAWAY-SANT'ANNA DIFFERENCE-IN-DIFFERENCES\n")
cat(rep("=", 60), "\n\n")

# Run Callaway-Sant'Anna with never-treated as control
cs_out <- att_gt(
  yname = "pension_rate",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = df_state_year,
  control_group = "nevertreated",  # Use never-treated states as control
  anticipation = 0,                 # No anticipation effects
  base_period = "universal",        # Universal base period
  est_method = "dr",                # Doubly robust
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000,
  clustervars = "statefip"          # Cluster at state level
)

# Print group-time ATTs
cat("Group-Time ATTs:\n")
summary(cs_out)

# -----------------------------------------------------------------------------
# Aggregate Effects
# -----------------------------------------------------------------------------

# Simple aggregate ATT
agg_simple <- aggte(cs_out, type = "simple")
cat("\n\nSimple Aggregate ATT:\n")
summary(agg_simple)

# Dynamic effects (event study)
agg_dynamic <- aggte(cs_out, type = "dynamic", min_e = -5, max_e = 5)
cat("\n\nDynamic (Event Study) Effects:\n")
summary(agg_dynamic)

# Group-specific effects
agg_group <- aggte(cs_out, type = "group")
cat("\n\nGroup-Specific (Cohort) Effects:\n")
summary(agg_group)

# Calendar time effects
agg_calendar <- aggte(cs_out, type = "calendar")
cat("\n\nCalendar Time Effects:\n")
summary(agg_calendar)

# -----------------------------------------------------------------------------
# Save Results
# -----------------------------------------------------------------------------

# Extract event study coefficients
es_coefs <- data.frame(
  event_time = agg_dynamic$egt,
  att = agg_dynamic$att.egt,
  se = agg_dynamic$se.egt,
  ci_lower = agg_dynamic$att.egt - 1.96 * agg_dynamic$se.egt,
  ci_upper = agg_dynamic$att.egt + 1.96 * agg_dynamic$se.egt
)

# Save results
saveRDS(cs_out, file.path(data_dir, "cs_results.rds"))
saveRDS(agg_dynamic, file.path(data_dir, "cs_dynamic.rds"))
saveRDS(agg_simple, file.path(data_dir, "cs_simple.rds"))
write_csv(es_coefs, file.path(data_dir, "event_study_coefs.csv"))

# -----------------------------------------------------------------------------
# Alternative: TWFE with Sun-Abraham (fixest)
# -----------------------------------------------------------------------------

cat("\n", rep("=", 60), "\n")
cat("SUN-ABRAHAM EVENT STUDY (TWFE ROBUST)\n")
cat(rep("=", 60), "\n\n")

# Create event time variable
df_state_year <- df_state_year %>%
  mutate(
    event_time = ifelse(first_treat > 0, year - first_treat, NA_integer_),
    # Cohort for sunab
    cohort = ifelse(first_treat > 0, first_treat, 10000)  # Never-treated gets large value
  )

# Sun-Abraham event study using fixest
sunab_out <- feols(
  pension_rate ~ sunab(cohort, year) | state_id + year,
  data = df_state_year,
  cluster = ~statefip
)

cat("Sun-Abraham Results:\n")
print(summary(sunab_out))

# Extract Sun-Abraham coefficients
sunab_coefs <- broom::tidy(sunab_out) %>%
  filter(str_detect(term, "year::")) %>%
  mutate(
    event_time = as.numeric(str_extract(term, "-?\\d+$")),
    att = estimate,
    se = std.error,
    ci_lower = estimate - 1.96 * std.error,
    ci_upper = estimate + 1.96 * std.error
  ) %>%
  select(event_time, att, se, ci_lower, ci_upper)

saveRDS(sunab_out, file.path(data_dir, "sunab_results.rds"))
write_csv(sunab_coefs, file.path(data_dir, "sunab_coefs.csv"))

# -----------------------------------------------------------------------------
# Standard TWFE (for comparison/bias illustration)
# -----------------------------------------------------------------------------

cat("\n", rep("=", 60), "\n")
cat("STANDARD TWFE (POTENTIALLY BIASED)\n")
cat(rep("=", 60), "\n\n")

df_state_year <- df_state_year %>%
  mutate(
    post = ifelse(first_treat > 0 & year >= first_treat, 1, 0),
    treated = ifelse(first_treat > 0, 1, 0)
  )

twfe_out <- feols(
  pension_rate ~ post | state_id + year,
  data = df_state_year,
  cluster = ~statefip
)

cat("Standard TWFE Results:\n")
print(summary(twfe_out))

saveRDS(twfe_out, file.path(data_dir, "twfe_results.rds"))

# -----------------------------------------------------------------------------
# WILD CLUSTER BOOTSTRAP for Small-Cluster Inference
# -----------------------------------------------------------------------------

cat("\n", rep("=", 60), "\n")
cat("WILD CLUSTER BOOTSTRAP INFERENCE\n")
cat(rep("=", 60), "\n\n")

# Wild cluster bootstrap for TWFE specification
# Using Webb 6-point weights (better for small clusters)

cat("Running wild cluster bootstrap (9999 iterations)...\n")
cat("This may take a few minutes...\n")

# Bootstrap the main TWFE coefficient
boot_out <- boottest(
  twfe_out,
  param = "post",
  clustid = "statefip",
  B = 9999,
  type = "webb",        # Webb 6-point weights for small clusters
  impose_null = TRUE    # Impose null for better small-sample performance
)

cat("\nWild Bootstrap Results:\n")
print(boot_out)

# Extract bootstrap p-value
boot_pval <- boot_out$p_val
boot_ci <- confint(boot_out)

cat("\nWild Bootstrap Summary:\n")
cat("  Point estimate:", round(coef(twfe_out)["post"], 4), "\n")
cat("  Clustered SE:", round(se(twfe_out)["post"], 4), "\n")
cat("  Wild bootstrap p-value:", round(boot_pval, 4), "\n")
cat("  Wild bootstrap 95% CI: [", round(boot_ci[1], 4), ",", round(boot_ci[2], 4), "]\n")

# Save bootstrap results
saveRDS(boot_out, file.path(data_dir, "wild_bootstrap_results.rds"))

# Create summary table with both inference methods
inference_comparison <- tibble(
  Method = c("Clustered SE", "Wild Bootstrap (Webb)"),
  Coefficient = rep(round(coef(twfe_out)["post"], 4), 2),
  SE = c(round(se(twfe_out)["post"], 4), NA),
  p_value = c(
    round(2 * pt(-abs(coef(twfe_out)["post"] / se(twfe_out)["post"]),
                 df = n_distinct(df_state_year$statefip) - 1), 4),
    round(boot_pval, 4)
  ),
  CI_lower = c(
    round(coef(twfe_out)["post"] - qt(0.975, n_distinct(df_state_year$statefip) - 1) * se(twfe_out)["post"], 4),
    round(boot_ci[1], 4)
  ),
  CI_upper = c(
    round(coef(twfe_out)["post"] + qt(0.975, n_distinct(df_state_year$statefip) - 1) * se(twfe_out)["post"], 4),
    round(boot_ci[2], 4)
  )
)

print(inference_comparison)
write_csv(inference_comparison, file.path(data_dir, "inference_comparison.csv"))

# -----------------------------------------------------------------------------
# Pre-Trends Joint Wald Test
# -----------------------------------------------------------------------------

cat("\n", rep("=", 60), "\n")
cat("PRE-TRENDS JOINT TEST\n")
cat(rep("=", 60), "\n\n")

# Extract pre-treatment coefficients from event study
pre_coefs <- es_coefs %>% filter(event_time < 0)

if (nrow(pre_coefs) > 0) {
  # Joint test: H0: all pre-treatment coefficients = 0
  # Using Wald test statistic
  pre_att <- pre_coefs$att
  pre_se <- pre_coefs$se

  # Wald statistic (sum of squared t-stats)
  wald_stat <- sum((pre_att / pre_se)^2)
  df_wald <- nrow(pre_coefs)
  p_wald <- 1 - pchisq(wald_stat, df = df_wald)

  cat("Joint test of pre-treatment coefficients = 0:\n")
  cat("  Number of pre-treatment periods:", df_wald, "\n")
  cat("  Wald statistic:", round(wald_stat, 3), "\n")
  cat("  p-value (chi-sq):", round(p_wald, 4), "\n")

  if (p_wald > 0.10) {
    cat("  Interpretation: FAIL TO REJECT null (supports parallel trends)\n")
  } else {
    cat("  Interpretation: REJECT null (potential pre-trends concern)\n")
  }

  # Save test result
  pretrends_test <- tibble(
    test = "Joint Wald test: all pre-treatment ATT = 0",
    n_periods = df_wald,
    wald_stat = round(wald_stat, 3),
    p_value = round(p_wald, 4)
  )
  write_csv(pretrends_test, file.path(data_dir, "pretrends_test.csv"))
}

# -----------------------------------------------------------------------------
# Summary of Main Results
# -----------------------------------------------------------------------------

cat("\n", rep("=", 60), "\n")
cat("SUMMARY OF MAIN RESULTS\n")
cat(rep("=", 60), "\n\n")

cat("Callaway-Sant'Anna ATT:", round(agg_simple$overall.att, 4),
    "(SE:", round(agg_simple$overall.se, 4), ")\n")
cat("TWFE coefficient:", round(coef(twfe_out)["post"], 4),
    "(SE:", round(se(twfe_out)["post"], 4), ")\n")
cat("Wild bootstrap p-value:", round(boot_pval, 4), "\n")

cat("\nAnalysis complete. Results saved to:", data_dir, "\n")
cat("Next: Run 03b_ddd_analysis.R for triple-difference design\n")
cat("      Run 04_robustness.R for robustness checks\n")
cat("      Run 05_figures.R for publication figures\n")
