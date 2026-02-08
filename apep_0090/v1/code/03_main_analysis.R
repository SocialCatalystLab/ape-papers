# ==============================================================================
# Paper 112: State Data Privacy Laws and Technology Sector Business Formation
# 03_main_analysis.R - Main DiD analysis using Callaway-Sant'Anna
# ==============================================================================

source("00_packages.R")

# Load analysis sample
analysis_sample <- read_csv(file.path(dir_data, "analysis_sample.csv"),
                            show_col_types = FALSE)

message("Loaded analysis sample: ", nrow(analysis_sample), " observations")

# ==============================================================================
# 1. Descriptive Statistics
# ==============================================================================

message("\n", strrep("=", 60))
message("DESCRIPTIVE STATISTICS")
message(strrep("=", 60))

# By treatment status
desc_stats <- analysis_sample %>%
  mutate(period = case_when(
    date < "2023-01-01" ~ "Pre-2023",
    TRUE ~ "Post-2023"
  )) %>%
  group_by(treated_ever, period) %>%
  summarise(
    n = n(),
    mean_apps = mean(business_apps, na.rm = TRUE),
    sd_apps = sd(business_apps, na.rm = TRUE),
    p25_apps = quantile(business_apps, 0.25, na.rm = TRUE),
    p75_apps = quantile(business_apps, 0.75, na.rm = TRUE),
    .groups = "drop"
  )

print(desc_stats)

# By cohort
cohort_stats <- analysis_sample %>%
  filter(treated_ever) %>%
  group_by(cohort) %>%
  summarise(
    n_states = n_distinct(state_abbr),
    states = paste(unique(state_abbr), collapse = ", "),
    effective_date = first(effective_date),
    .groups = "drop"
  ) %>%
  arrange(cohort)

message("\nTreatment cohorts:")
print(cohort_stats)

# ==============================================================================
# 2. Callaway-Sant'Anna Difference-in-Differences
# ==============================================================================

message("\n", strrep("=", 60))
message("CALLAWAY-SANT'ANNA DiD ESTIMATION")
message(strrep("=", 60))

# Prepare data for did package
# The did package requires:
# - yname: outcome variable
# - tname: time period (numeric)
# - idname: unit identifier
# - gname: cohort/group (0 for never-treated)

did_data <- analysis_sample %>%
  mutate(
    # Create numeric state ID
    state_id = as.numeric(factor(state_abbr)),
    # Ensure cohort is 0 for never-treated
    g = if_else(treated_ever, cohort, 0)
  ) %>%
  filter(!is.na(business_apps))

message("DiD data prepared: ", nrow(did_data), " observations")
message("  Treated cohorts: ", n_distinct(did_data$g[did_data$g > 0]))
message("  Never-treated states: ", n_distinct(did_data$state_id[did_data$g == 0]))

# Estimate group-time ATTs
cs_result <- tryCatch({
  att_gt(
    yname = "business_apps",
    tname = "time_period",
    idname = "state_id",
    gname = "g",
    data = did_data,
    control_group = "nevertreated",
    anticipation = 0,
    est_method = "dr",  # Doubly robust
    base_period = "universal"
  )
}, error = function(e) {
  message("Error in att_gt: ", e$message)
  message("Trying with simpler specification...")

  # Fallback: IPW only
  att_gt(
    yname = "business_apps",
    tname = "time_period",
    idname = "state_id",
    gname = "g",
    data = did_data,
    control_group = "nevertreated",
    anticipation = 0,
    est_method = "ipw",
    base_period = "universal"
  )
})

# Summary of group-time ATTs
message("\nGroup-time ATT summary:")
summary(cs_result)

# ==============================================================================
# 3. Aggregate to Overall ATT
# ==============================================================================

# Overall ATT (simple average)
agg_simple <- aggte(cs_result, type = "simple")
message("\nOverall ATT (simple):")
summary(agg_simple)

# Dynamic effects (event study)
agg_dynamic <- aggte(cs_result, type = "dynamic")
message("\nDynamic ATT (event study):")
summary(agg_dynamic)

# Group-specific effects
agg_group <- aggte(cs_result, type = "group")
message("\nGroup-specific ATTs:")
summary(agg_group)

# ==============================================================================
# 4. Event Study Plot
# ==============================================================================

message("\nGenerating event study plot...")

# Extract event study coefficients
es_data <- tibble(
  rel_time = agg_dynamic$egt,
  att = agg_dynamic$att.egt,
  se = agg_dynamic$se.egt
) %>%
  mutate(
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se
  )

# Event study plot
p_event_study <- ggplot(es_data, aes(x = rel_time, y = att)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "red", alpha = 0.5) +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, fill = "steelblue") +
  geom_line(color = "steelblue", linewidth = 1) +
  geom_point(color = "steelblue", size = 2) +
  labs(
    title = "Event Study: Effect of State Privacy Laws on Business Applications",
    subtitle = "Callaway-Sant'Anna estimator, 2023+ wave (excluding California)",
    x = "Months Relative to Privacy Law Effective Date",
    y = "ATT (Business Applications)",
    caption = "Notes: 95% confidence intervals shown. Vertical line indicates treatment timing."
  ) +
  theme(plot.title = element_text(size = 14))

ggsave(file.path(dir_figures, "event_study.pdf"), p_event_study,
       width = 10, height = 6)
ggsave(file.path(dir_figures, "event_study.png"), p_event_study,
       width = 10, height = 6, dpi = 300)

message("Saved: event_study.pdf")

# ==============================================================================
# 5. Pre-trend Test
# ==============================================================================

message("\nPre-trend analysis...")

# Pre-treatment coefficients
pre_coefs <- es_data %>%
  filter(rel_time < 0)

if (nrow(pre_coefs) > 0) {
  # Joint test that all pre-treatment coefficients = 0
  # Handle NA values
  pre_coefs_valid <- pre_coefs %>% filter(!is.na(att) & !is.na(se) & se > 0)

  if (nrow(pre_coefs_valid) > 0) {
    pre_wald <- sum((pre_coefs_valid$att / pre_coefs_valid$se)^2, na.rm = TRUE)
    pre_df <- nrow(pre_coefs_valid)
    pre_pvalue <- 1 - pchisq(pre_wald, df = pre_df)

    message("Pre-trend test (joint Wald):")
    message("  Chi-squared: ", round(pre_wald, 3))
    message("  df: ", pre_df)
    message("  p-value: ", round(pre_pvalue, 4))

    if (!is.na(pre_pvalue) && pre_pvalue > 0.05) {
      message("  -> Cannot reject null of parallel pre-trends (good!)")
    } else if (!is.na(pre_pvalue)) {
      message("  -> WARNING: Potential pre-trend violation")
    }
  } else {
    message("  Insufficient valid pre-trend coefficients for test")
  }
}

# ==============================================================================
# 6. Save Results
# ==============================================================================

# Main results table
results_main <- tibble(
  specification = c("Overall ATT", "Dynamic (average post)"),
  att = c(agg_simple$overall.att, mean(es_data$att[es_data$rel_time >= 0], na.rm = TRUE)),
  se = c(agg_simple$overall.se, NA),
  ci_lower = c(agg_simple$overall.att - 1.96 * agg_simple$overall.se, NA),
  ci_upper = c(agg_simple$overall.att + 1.96 * agg_simple$overall.se, NA)
)

write_csv(results_main, file.path(dir_tables, "main_results.csv"))
message("\nSaved main results to: main_results.csv")

# Event study data
write_csv(es_data, file.path(dir_tables, "event_study_data.csv"))

# Save R objects for later use
save(cs_result, agg_simple, agg_dynamic, agg_group, es_data,
     file = file.path(dir_data, "did_results.RData"))

message("\n", strrep("=", 60))
message("MAIN ANALYSIS COMPLETE")
message(strrep("=", 60))

message("\nKey findings:")
message("  Overall ATT: ", round(agg_simple$overall.att, 2),
        " (SE: ", round(agg_simple$overall.se, 2), ")")
message("  p-value: ", round(2 * (1 - pnorm(abs(agg_simple$overall.att / agg_simple$overall.se))), 4))
