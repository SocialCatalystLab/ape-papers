# 03_main_analysis.R
# Main DiD analysis: Promise Programs and College Enrollment

source("00_packages.R")

# =============================================================================
# 1. LOAD DATA
# =============================================================================

df <- readRDS("../data/clean_panel.rds")
event_df <- readRDS("../data/event_study_panel.rds")

message("Data loaded: ", nrow(df), " observations")
message("Treated states: ", n_distinct(df$state_fips[df$ever_treated]))
message("Control states: ", n_distinct(df$state_fips[!df$ever_treated]))

# =============================================================================
# 2. CALLAWAY-SANT'ANNA ESTIMATOR
# =============================================================================

message("\n=== CALLAWAY-SANT'ANNA DiD ===")

# Prepare data for did package
# first_treat must be 0 for never-treated units
cs_data <- df %>%
  mutate(
    first_treat = ifelse(first_treat == 0, 0, first_treat),
    log_enroll = log(total_college_enrolled + 1)
  ) %>%
  filter(!is.na(log_enroll))

# Run Callaway-Sant'Anna with never-treated as control group
cs_result <- att_gt(
  yname = "log_enroll",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = cs_data,
  control_group = "nevertreated",
  anticipation = 0,
  est_method = "dr",  # Doubly robust
  base_period = "universal",
  clustervars = "state_id",
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000
)

# Print group-time ATT
summary(cs_result)

# Save detailed results
saveRDS(cs_result, "../data/cs_result.rds")

# =============================================================================
# 3. AGGREGATE EFFECTS
# =============================================================================

# Overall ATT
att_overall <- aggte(cs_result, type = "simple")
message("\n=== OVERALL ATT ===")
print(att_overall)

# Dynamic effects (event study)
att_dynamic <- aggte(cs_result, type = "dynamic", min_e = -5, max_e = 7)
message("\n=== DYNAMIC EFFECTS ===")
print(att_dynamic)

# Group-specific ATT
att_group <- aggte(cs_result, type = "group")
message("\n=== GROUP-SPECIFIC EFFECTS ===")
print(att_group)

# Calendar time effects
att_calendar <- aggte(cs_result, type = "calendar")
message("\n=== CALENDAR TIME EFFECTS ===")
print(att_calendar)

# Save aggregated results
saveRDS(list(
  overall = att_overall,
  dynamic = att_dynamic,
  group = att_group,
  calendar = att_calendar
), "../data/cs_aggregates.rds")

# =============================================================================
# 4. TWFE COMPARISON (For Reference)
# =============================================================================

message("\n=== TWFE COMPARISON (potentially biased) ===")

# Standard TWFE for comparison
twfe_result <- feols(
  log_enroll ~ treated | state_id + year,
  data = cs_data,
  cluster = ~state_id
)

message("TWFE estimate:")
print(summary(twfe_result))

# Event study TWFE
event_df <- event_df %>%
  mutate(log_enroll = log(total_college_enrolled + 1))

twfe_event <- feols(
  log_enroll ~ i(rel_time_binned, ref = -1) | state_id + year,
  data = event_df %>% filter(!is.na(rel_time_binned)),
  cluster = ~state_id
)

message("\nTWFE Event Study:")
print(summary(twfe_event))

# =============================================================================
# 5. POWER ANALYSIS
# =============================================================================

message("\n=== POWER ANALYSIS ===")

# Calculate minimum detectable effect
n_treated <- n_distinct(cs_data$state_id[cs_data$first_treat > 0])
n_control <- n_distinct(cs_data$state_id[cs_data$first_treat == 0])
n_years <- n_distinct(cs_data$year)

# Pre-treatment outcome variance
pre_treat_var <- cs_data %>%
  filter(first_treat == 0 | year < first_treat) %>%
  summarize(
    sd_outcome = sd(log_enroll, na.rm = TRUE),
    mean_outcome = mean(log_enroll, na.rm = TRUE)
  )

# Rough MDE calculation (assumes 80% power, alpha = 0.05)
# MDE ≈ 2.8 * SE
# SE ≈ sd / sqrt(n_clusters * n_periods)
approx_se <- pre_treat_var$sd_outcome / sqrt(n_treated * n_years / 2)
mde <- 2.8 * approx_se

message("Treated clusters: ", n_treated)
message("Control clusters: ", n_control)
message("Years in panel: ", n_years)
message("Pre-treatment SD: ", round(pre_treat_var$sd_outcome, 3))
message("Approximate MDE (log points): ", round(mde, 3))
message("Approximate MDE (%): ", round((exp(mde) - 1) * 100, 1), "%")

# =============================================================================
# 6. EXPORT RESULTS FOR PAPER
# =============================================================================

# Create results table
cs_pvalue <- 2 * pnorm(-abs(att_overall$overall.att / att_overall$overall.se))
twfe_pvalue <- pvalue(twfe_result)["treatedTRUE"]

results_table <- tibble(
  Specification = c("CS DiD (Overall)", "TWFE"),
  Estimate = c(att_overall$overall.att, coef(twfe_result)["treatedTRUE"]),
  SE = c(att_overall$overall.se, se(twfe_result)["treatedTRUE"]),
  `95% CI Lower` = Estimate - 1.96 * SE,
  `95% CI Upper` = Estimate + 1.96 * SE,
  `P-value` = c(cs_pvalue, twfe_pvalue)
) %>%
  mutate(across(where(is.numeric), ~round(.x, 4)))

write_csv(results_table, "../tables/main_results.csv")

message("\n=== RESULTS SAVED ===")
message("Main results: ../tables/main_results.csv")
message("CS result object: ../data/cs_result.rds")
message("CS aggregates: ../data/cs_aggregates.rds")
