# ==============================================================================
# 03_main_analysis.R
# Paper 96: Telehealth Parity Laws and Mental Health Treatment Utilization
# Description: Callaway-Sant'Anna DiD analysis
# ==============================================================================

source("00_packages.R")

# ==============================================================================
# Load Data
# ==============================================================================

message("=== Loading Analysis Data ===")

analysis_data <- read_csv("../data/analysis_panel.csv", show_col_types = FALSE)

# Filter to states with outcome data and valid observations
analysis_data <- analysis_data %>%
  filter(!is.na(depression_pct)) %>%
  # Ensure proper cohort coding (0 = never treated)
  mutate(
    cohort_cs = ifelse(is.na(cohort) | cohort == 0, 0, cohort),
    state_id = as.numeric(factor(state))
  )

message(paste("Analysis sample:", nrow(analysis_data), "state-years"))
message(paste("States:", n_distinct(analysis_data$state)))
message(paste("Years:", min(analysis_data$year), "-", max(analysis_data$year)))

# ==============================================================================
# Summary of Treatment Timing
# ==============================================================================

message("\n=== Treatment Summary ===")

treatment_summary <- analysis_data %>%
  group_by(state) %>%
  summarize(
    cohort = unique(cohort_cs),
    ever_treated = any(treated == 1),
    first_treated = ifelse(any(treated == 1), min(year[treated == 1]), NA),
    .groups = "drop"
  )

cohort_table <- treatment_summary %>%
  count(cohort, name = "n_states") %>%
  mutate(cohort_label = case_when(
    cohort == 0 ~ "Never treated",
    cohort <= 2011 ~ "Always treated (<=2011)",
    TRUE ~ paste("Treated in", cohort)
  )) %>%
  arrange(cohort)

print(cohort_table)

# ==============================================================================
# Callaway-Sant'Anna Estimation
# ==============================================================================

message("\n=== Callaway-Sant'Anna Estimation ===")

# Note: Outcome is depression_pct (% diagnosed with depression)
# Mechanism: If telehealth improves access, more diagnoses may occur

# Prepare data for did package
did_data <- analysis_data %>%
  select(state_id, year, depression_pct, cohort_cs) %>%
  rename(
    id = state_id,
    G = cohort_cs,
    Y = depression_pct,
    period = year
  ) %>%
  filter(!is.na(Y))

message(paste("DiD sample:", nrow(did_data), "observations"))
message(paste("Treated cohorts:", paste(sort(unique(did_data$G[did_data$G > 0])), collapse = ", ")))

# Estimate group-time ATTs
# Using not-yet-treated as comparison group
cs_att <- att_gt(
  yname = "Y",
  tname = "period",
  idname = "id",
  gname = "G",
  data = did_data,
  control_group = "notyettreated",
  anticipation = 0,
  base_period = "universal",
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000,
  clustervars = "id"
)

# Print summary
message("\n=== Group-Time ATT Summary ===")
print(summary(cs_att))

# ==============================================================================
# Aggregate to Overall ATT
# ==============================================================================

message("\n=== Overall ATT ===")

# Simple aggregation (equally weighted)
agg_simple <- aggte(cs_att, type = "simple")
print(summary(agg_simple))

# Group (cohort) specific effects
agg_group <- aggte(cs_att, type = "group")
message("\n=== Cohort-Specific Effects ===")
print(summary(agg_group))

# ==============================================================================
# Event Study (Dynamic Effects)
# ==============================================================================

message("\n=== Event Study ===")

agg_dynamic <- aggte(cs_att, type = "dynamic", min_e = -5, max_e = 5)
print(summary(agg_dynamic))

# ==============================================================================
# Save Results
# ==============================================================================

# Extract results for tables
results_list <- list(
  group_time = cs_att,
  overall = agg_simple,
  by_cohort = agg_group,
  dynamic = agg_dynamic
)

saveRDS(results_list, "../data/cs_results.rds")
message("\nResults saved to: ../data/cs_results.rds")

# ==============================================================================
# TWFE Comparison
# ==============================================================================

message("\n=== TWFE Comparison ===")

# Standard TWFE (biased with heterogeneous effects)
twfe_model <- feols(
  depression_pct ~ treated | state_id + year,
  data = analysis_data,
  cluster = ~state_id
)

message("TWFE Estimate:")
print(summary(twfe_model))

# Save TWFE results
saveRDS(twfe_model, "../data/twfe_results.rds")

# ==============================================================================
# Summary Table
# ==============================================================================

message("\n=== Main Results Summary ===")

main_results <- tibble(
  Estimator = c("Callaway-Sant'Anna (ATT)", "TWFE"),
  Estimate = c(agg_simple$overall.att, coef(twfe_model)["treated"]),
  SE = c(agg_simple$overall.se, se(twfe_model)["treated"]),
  CI_low = c(agg_simple$overall.att - 1.96 * agg_simple$overall.se,
             coef(twfe_model)["treated"] - 1.96 * se(twfe_model)["treated"]),
  CI_high = c(agg_simple$overall.att + 1.96 * agg_simple$overall.se,
              coef(twfe_model)["treated"] + 1.96 * se(twfe_model)["treated"]),
  p_value = c(2 * (1 - pnorm(abs(agg_simple$overall.att / agg_simple$overall.se))),
              2 * (1 - pnorm(abs(coef(twfe_model)["treated"] / se(twfe_model)["treated"]))))
)

print(main_results)

write_csv(main_results, "../tables/main_results.csv")
message("\nSaved: ../tables/main_results.csv")

# ==============================================================================
# Pre-Trends Test
# ==============================================================================

message("\n=== Pre-Trends Test ===")

# Extract pre-treatment coefficients from event study
dynamic_df <- data.frame(
  event_time = agg_dynamic$egt,
  att = agg_dynamic$att.egt,
  se = agg_dynamic$se.egt
) %>%
  mutate(
    ci_low = att - 1.96 * se,
    ci_high = att + 1.96 * se
  )

# Test: Are all pre-treatment coefficients jointly zero?
pre_treatment <- dynamic_df %>% filter(event_time < 0)

message("Pre-treatment coefficients:")
print(pre_treatment)

# Joint test (simple: check if CIs include zero)
all_include_zero <- all(pre_treatment$ci_low <= 0 & pre_treatment$ci_high >= 0)
message(paste("\nAll pre-treatment CIs include zero:", all_include_zero))

write_csv(dynamic_df, "../data/event_study_estimates.csv")
