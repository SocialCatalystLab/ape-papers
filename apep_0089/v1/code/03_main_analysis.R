# ==============================================================================
# 03_main_analysis.R
# Primary DiD analysis using Callaway-Sant'Anna estimator
# Paper 111: NP Full Practice Authority and Physician Employment
# ==============================================================================

source("00_packages.R")

# Load cleaned data
analysis_main <- read_csv(file.path(data_dir, "analysis_main.csv"))
analysis_did <- read_csv(file.path(data_dir, "analysis_did.csv"))

cat("Main sample:", nrow(analysis_main), "observations\n")
cat("DiD sample:", nrow(analysis_did), "observations\n")

# ==============================================================================
# PART 1: Descriptive Evidence
# ==============================================================================

cat("\n=== PART 1: Descriptive Analysis ===\n")

# Aggregate trends by treatment status
trends <- analysis_main %>%
  group_by(year, ever_treated) %>%
  summarise(
    mean_emp = mean(employment, na.rm = TRUE),
    mean_log_emp = mean(log_emp, na.rm = TRUE),
    n_states = n_distinct(state_fips),
    .groups = "drop"
  ) %>%
  mutate(group = ifelse(ever_treated, "FPA States", "Non-FPA States"))

# Print summary
cat("\nMean Employment by Group:\n")
trends %>%
  group_by(group) %>%
  summarise(
    mean_emp = mean(mean_emp),
    min_year = min(year),
    max_year = max(year)
  ) %>%
  print()

# ==============================================================================
# PART 2: Callaway-Sant'Anna DiD Estimation
# ==============================================================================

cat("\n=== PART 2: Callaway-Sant'Anna Estimation ===\n")

# Prepare data for did package
# Requires: numeric id, numeric time, numeric group (0 for never-treated)
did_data <- analysis_did %>%
  mutate(
    id = as.numeric(factor(state_fips)),
    time = year,
    G = fpa_year  # 0 for never-treated, else treatment year
  ) %>%
  filter(!is.na(log_emp)) %>%
  arrange(id, time)

cat("DiD data prepared:\n")
cat("  Unique states:", n_distinct(did_data$id), "\n")
cat("  Time range:", min(did_data$time), "-", max(did_data$time), "\n")
cat("  Treatment cohorts:", length(unique(did_data$G[did_data$G > 0])), "\n")

# Estimate group-time average treatment effects
cat("\nEstimating ATT(g,t)...\n")

att_gt_result <- att_gt(
  yname = "log_emp",
  tname = "time",
  idname = "id",
  gname = "G",
  data = did_data,
  control_group = "nevertreated",  # Use never-treated as control
  anticipation = 0,                 # No anticipation effects
  est_method = "reg",               # Regression-based (OLS)
  clustervars = "id",               # Cluster SEs at state level
  print_details = FALSE
)

# Summary of group-time effects
summary(att_gt_result)

# ==============================================================================
# PART 3: Aggregate Treatment Effects
# ==============================================================================

cat("\n=== PART 3: Aggregate Treatment Effects ===\n")

# Simple aggregation (overall ATT)
agg_simple <- aggte(att_gt_result, type = "simple")
cat("\n--- Simple ATT (Overall) ---\n")
summary(agg_simple)

# Group-specific aggregation (by cohort)
agg_group <- aggte(att_gt_result, type = "group")
cat("\n--- Group-Specific ATT (by Cohort) ---\n")
summary(agg_group)

# Dynamic aggregation (event study)
agg_dynamic <- aggte(att_gt_result, type = "dynamic", min_e = -8, max_e = 8)
cat("\n--- Dynamic ATT (Event Study) ---\n")
summary(agg_dynamic)

# Calendar time aggregation
agg_calendar <- aggte(att_gt_result, type = "calendar")
cat("\n--- Calendar Time ATT ---\n")
summary(agg_calendar)

# ==============================================================================
# PART 4: Extract Key Results
# ==============================================================================

cat("\n=== PART 4: Key Results ===\n")

# Simple ATT
simple_att <- tibble(
  estimand = "Simple ATT",
  estimate = agg_simple$overall.att,
  se = agg_simple$overall.se,
  ci_lower = agg_simple$overall.att - 1.96 * agg_simple$overall.se,
  ci_upper = agg_simple$overall.att + 1.96 * agg_simple$overall.se,
  p_value = 2 * pnorm(-abs(agg_simple$overall.att / agg_simple$overall.se))
)

cat("\nSimple ATT:\n")
cat("  Estimate:", round(simple_att$estimate, 4), "\n")
cat("  SE:", round(simple_att$se, 4), "\n")
cat("  95% CI: [", round(simple_att$ci_lower, 4), ",", round(simple_att$ci_upper, 4), "]\n")
cat("  p-value:", round(simple_att$p_value, 4), "\n")

# Interpretation
pct_effect <- (exp(simple_att$estimate) - 1) * 100
cat("\n  Interpretation: FPA adoption is associated with a",
    round(pct_effect, 1), "% change in physician employment\n")

# Group-specific ATTs
group_atts <- tibble(
  cohort = agg_group$egt,
  att = agg_group$att.egt,
  se = agg_group$se.egt
) %>%
  mutate(
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se,
    significant = (ci_lower > 0) | (ci_upper < 0)
  )

cat("\nGroup-Specific ATTs:\n")
print(group_atts)

# ==============================================================================
# PART 5: Pre-Trends Test
# ==============================================================================

cat("\n=== PART 5: Pre-Trends Test ===\n")

# Extract event study coefficients
es_results <- tibble(
  event_time = agg_dynamic$egt,
  att = agg_dynamic$att.egt,
  se = agg_dynamic$se.egt
) %>%
  mutate(
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se
  )

# Pre-trend coefficients (event_time < 0)
pre_trend_coefs <- es_results %>%
  filter(event_time < 0)

cat("\nPre-treatment coefficients:\n")
print(pre_trend_coefs)

# Joint test for pre-trends (are all pre-treatment effects = 0?)
pre_trend_test <- pre_trend_coefs %>%
  summarise(
    n_periods = n(),
    mean_att = mean(att),
    max_abs_att = max(abs(att)),
    any_significant = any((ci_lower > 0) | (ci_upper < 0))
  )

cat("\nPre-trend summary:\n")
cat("  Pre-treatment periods:", pre_trend_test$n_periods, "\n")
cat("  Mean pre-treatment ATT:", round(pre_trend_test$mean_att, 4), "\n")
cat("  Max |ATT|:", round(pre_trend_test$max_abs_att, 4), "\n")
cat("  Any significant at 5%:", pre_trend_test$any_significant, "\n")

# ==============================================================================
# PART 6: Alternative Specifications (TWFE)
# ==============================================================================

cat("\n=== PART 6: Alternative Specifications ===\n")

# Traditional TWFE (for comparison - known to be biased with staggered adoption)
twfe_model <- feols(
  log_emp ~ post | state_fips + year,
  data = analysis_did,
  cluster = ~ state_fips
)

cat("\nTraditional TWFE (for comparison):\n")
summary(twfe_model)

# TWFE with controls
twfe_controls <- feols(
  log_emp ~ post + log(healthcare_emp) | state_fips + year,
  data = analysis_did,
  cluster = ~ state_fips
)

cat("\nTWFE with healthcare employment control:\n")
summary(twfe_controls)

# ==============================================================================
# PART 7: Save Results
# ==============================================================================

# Create results list
results <- list(
  att_gt = att_gt_result,
  agg_simple = agg_simple,
  agg_group = agg_group,
  agg_dynamic = agg_dynamic,
  agg_calendar = agg_calendar,
  es_results = es_results,
  simple_att = simple_att,
  group_atts = group_atts,
  twfe = twfe_model
)

saveRDS(results, file.path(data_dir, "main_results.rds"))
cat("\nResults saved to data/main_results.rds\n")

# Save event study results for plotting
write_csv(es_results, file.path(data_dir, "event_study_results.csv"))
cat("Event study results saved to data/event_study_results.csv\n")

# ==============================================================================
# PART 8: Results Summary
# ==============================================================================

cat("\n")
cat("=" %>% rep(60) %>% paste(collapse = ""), "\n")
cat("RESULTS SUMMARY\n")
cat("=" %>% rep(60) %>% paste(collapse = ""), "\n")

cat("\n1. Overall ATT (Callaway-Sant'Anna):\n")
cat("   Estimate:", round(simple_att$estimate, 4),
    " (SE:", round(simple_att$se, 4), ")\n")
cat("   Interpretation:", round(pct_effect, 1), "% change in physician employment\n")

cat("\n2. Pre-trends:\n")
if (!pre_trend_test$any_significant) {
  cat("   PASS: No significant pre-treatment effects\n")
} else {
  cat("   WARNING: Some significant pre-treatment effects detected\n")
}

cat("\n3. Traditional TWFE (comparison):\n")
cat("   Estimate:", round(coef(twfe_model)["postTRUE"], 4), "\n")
cat("   Note: TWFE may be biased with staggered adoption\n")

cat("\n")
