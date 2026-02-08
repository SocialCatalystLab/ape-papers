# ============================================================================
# Paper 74: Dental Therapy and Oral Health Access
# 03_main_analysis.R - Main DiD Analysis using Callaway-Sant'Anna
# ============================================================================

source("output/paper_74/code/00_packages.R")

# Load data
analysis_data <- readRDS("output/paper_74/data/analysis_data.rds")

cat("========================================\n")
cat("MAIN ANALYSIS: CALLAWAY-SANT'ANNA DiD\n")
cat("========================================\n\n")

# ============================================================================
# Step 1: Data Summary
# ============================================================================

cat("Data structure:\n")
cat(sprintf("  N state-years: %d\n", nrow(analysis_data)))
cat(sprintf("  N states: %d\n", n_distinct(analysis_data$state)))
n_treated <- length(unique(analysis_data$state[analysis_data$treated == 1]))
cat(sprintf("  N treated states: %d\n", n_treated))
cat(sprintf("  Years: %d-%d\n", min(analysis_data$year), max(analysis_data$year)))

# ============================================================================
# Step 2: Prepare Data for DiD
# ============================================================================

# For Callaway-Sant'Anna, we need:
# - Panel data (balanced if possible)
# - first_treat = 0 for never-treated
# - Numeric state ID for clustering

# Note: Data is bi-annual (2012, 2014, 2016, 2018, 2020)
# Treatment years need to map to these periods

# CRITICAL: Drop Minnesota entirely from the estimation sample.
# Minnesota (authorized 2009) is "always-treated" in the 2012-2020 window,
# so it cannot be used as a control (not "never-treated" or "not-yet-treated").
# Including it in any capacity would contaminate the estimation.

did_data <- analysis_data %>%
  filter(state != "MN") %>%  # DROP Minnesota entirely
  mutate(
    # Map treatment year to first post-treatment observation period
    #
    # Treatment timing to data period mapping:
    # - 2014 (ME) -> 2014 (first post-period = 2014)
    # - 2016 (VT) -> 2016 (first post-period = 2016)
    # - 2018 (AZ, NM, MI) -> 2018 (first post-period = 2018)
    # - 2019 (ID, NV) -> 2020 (first post-period = 2020, conservative)
    # - 2020 (OR, WA) -> 2020 (first post-period = 2020)
    # - 2021+ (CT, CO, WI) -> treated after data ends, coded as not-yet-treated
    first_treat_adj = case_when(
      treatment_year == 0 ~ 0L,
      treatment_year == 2014 ~ 2014L,
      treatment_year <= 2016 ~ 2016L,
      treatment_year <= 2018 ~ 2018L,
      treatment_year <= 2020 ~ 2020L,
      TRUE ~ 0L  # 2021+ treated after data ends (not-yet-treated in window)
    )
  ) %>%
  select(
    state_id, state, state_fips, year,
    dental_visit_rate, sample_size,
    first_treat = first_treat_adj,
    treatment_year_actual = treatment_year
  )

cat("\nAdjusted treatment timing (to match data years):\n")
did_data %>%
  distinct(state, first_treat, treatment_year_actual) %>%
  filter(first_treat > 0 | treatment_year_actual > 0) %>%
  arrange(first_treat) %>%
  print(n = 20)

# Check cohort sizes
cat("\nCohort sizes:\n")
did_data %>%
  distinct(state, first_treat) %>%
  count(first_treat, name = "n_states") %>%
  mutate(cohort = if_else(first_treat == 0, "Never-treated", as.character(first_treat))) %>%
  print()

# ============================================================================
# Step 3: Callaway-Sant'Anna Estimation
# ============================================================================

cat("\n========================================\n")
cat("Running Callaway-Sant'Anna estimation...\n")
cat("========================================\n")

# Note: We have few pre-treatment periods for early adopters
# Minnesota (2009) has no pre-treatment data
# Maine (2014) has only 1 pre-treatment period (2012)

# Using not-yet-treated comparison group

cs_result <- att_gt(
  yname = "dental_visit_rate",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = did_data,
  control_group = "notyettreated",
  anticipation = 0,
  base_period = "universal",
  clustervars = "state_id",
  print_details = FALSE
)

# Summary
cat("\nATT(g,t) Results:\n")
summary(cs_result)

# Save
saveRDS(cs_result, "output/paper_74/data/cs_result.rds")

# ============================================================================
# Step 4: Aggregate Results
# ============================================================================

cat("\n========================================\n")
cat("AGGREGATED RESULTS\n")
cat("========================================\n")

# Dynamic (event study) aggregation
es_result <- aggte(cs_result, type = "dynamic", min_e = -4, max_e = 4)
cat("\nEvent Study (Dynamic Aggregation):\n")
summary(es_result)

# Overall ATT
att_overall <- aggte(cs_result, type = "simple")
cat("\nOverall ATT:\n")
summary(att_overall)

# Group-specific effects
att_group <- aggte(cs_result, type = "group")
cat("\nGroup-specific ATT:\n")
summary(att_group)

# Save aggregated results
saveRDS(es_result, "output/paper_74/data/es_result.rds")
saveRDS(att_overall, "output/paper_74/data/att_overall.rds")
saveRDS(att_group, "output/paper_74/data/att_group.rds")

# ============================================================================
# Step 5: Event Study Plot
# ============================================================================

# Extract coefficients programmatically
es_data <- data.frame(
  event_time = es_result$egt,
  att = es_result$att.egt,
  se = es_result$se.egt
) %>%
  filter(!is.na(att)) %>%
  mutate(
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se,
    significant = (ci_lower > 0 | ci_upper < 0)
  )

cat("\nEvent study coefficients:\n")
print(es_data)

p_es <- ggplot(es_data, aes(x = event_time, y = att)) +
  # Confidence interval ribbon
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
              alpha = 0.2, fill = apep_colors[1]) +
  # Point estimates
  geom_point(size = 3.5, color = apep_colors[1]) +
  geom_line(color = apep_colors[1], linewidth = 1) +
  # Reference lines
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40", linewidth = 0.5) +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60", linewidth = 0.5) +
  # Labels
  labs(
    title = "Event Study: Effect of Dental Therapy Authorization on Dental Visits",
    subtitle = sprintf("Callaway-Sant'Anna estimator | Overall ATT: %.3f (SE: %.3f, p=%.3f)",
                       att_overall$overall.att, att_overall$overall.se,
                       2 * pnorm(-abs(att_overall$overall.att / att_overall$overall.se))),
    x = "Years Relative to Estimation Cohort Year",
    y = "Effect on Dental Visit Rate",
    caption = "Note: Reference period is t = -2 years (omitted). Comparison group: not-yet-treated states.\nShaded region shows 95% CI. Cohort year = first post-authorization BRFSS observation period."
  ) +
  scale_x_continuous(breaks = seq(-4, 4, 1)) +
  scale_y_continuous(labels = function(x) sprintf("%.1f pp", x * 100)) +
  theme_apep()

ggsave("output/paper_74/figures/event_study.pdf", p_es, width = 10, height = 6)
ggsave("output/paper_74/figures/event_study.png", p_es, width = 10, height = 6, dpi = 300)

cat("\nEvent study plot saved.\n")

# ============================================================================
# Step 6: Pre-Trends Assessment
# ============================================================================

cat("\n========================================\n")
cat("PRE-TRENDS ASSESSMENT\n")
cat("========================================\n")

pre_coefs <- es_data %>% filter(event_time < 0)

if (nrow(pre_coefs) > 0) {
  cat("\nPre-treatment coefficients:\n")
  print(pre_coefs)

  # Joint test
  pre_tstats <- pre_coefs$att / pre_coefs$se
  pre_chi2 <- sum(pre_tstats^2, na.rm = TRUE)
  pre_df <- sum(!is.na(pre_tstats))
  pre_pval <- 1 - pchisq(pre_chi2, df = pre_df)

  cat(sprintf("\nJoint test (H0: all pre-treatment ATT = 0):\n"))
  cat(sprintf("  Chi-squared(%d) = %.3f\n", pre_df, pre_chi2))
  cat(sprintf("  p-value = %.4f\n", pre_pval))

  if (pre_pval > 0.05) {
    cat("  -> Cannot reject parallel trends (supportive but not conclusive)\n")
  } else {
    cat("  -> Evidence of pre-trends violation (concern)\n")
  }
} else {
  cat("No pre-treatment coefficients available.\n")
}

# ============================================================================
# Step 7: Robustness - Never-Treated Comparison
# ============================================================================

cat("\n========================================\n")
cat("ROBUSTNESS: NEVER-TREATED COMPARISON\n")
cat("========================================\n")

cs_never <- att_gt(
  yname = "dental_visit_rate",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = did_data,
  control_group = "nevertreated",
  anticipation = 0,
  base_period = "universal",
  clustervars = "state_id",
  print_details = FALSE
)

att_never <- aggte(cs_never, type = "simple")
cat("\nOverall ATT (never-treated comparison):\n")
summary(att_never)

saveRDS(cs_never, "output/paper_74/data/cs_result_never.rds")
saveRDS(att_never, "output/paper_74/data/att_never.rds")

# ============================================================================
# Step 8: Summary Table
# ============================================================================

cat("\n========================================\n")
cat("SUMMARY OF MAIN RESULTS\n")
cat("========================================\n")

results_summary <- tibble(
  Specification = c(
    "Callaway-Sant'Anna (not-yet-treated)",
    "Callaway-Sant'Anna (never-treated)"
  ),
  ATT = c(
    att_overall$overall.att,
    att_never$overall.att
  ),
  SE = c(
    att_overall$overall.se,
    att_never$overall.se
  ),
  `p-value` = c(
    2 * pnorm(-abs(att_overall$overall.att / att_overall$overall.se)),
    2 * pnorm(-abs(att_never$overall.att / att_never$overall.se))
  )
) %>%
  mutate(
    `95% CI` = sprintf("[%.4f, %.4f]", ATT - 1.96*SE, ATT + 1.96*SE),
    `ATT (pp)` = sprintf("%.2f", ATT * 100),
    Significant = if_else(`p-value` < 0.05, "*", "")
  )

print(results_summary)

# Save summary
saveRDS(results_summary, "output/paper_74/data/results_summary.rds")
write_csv(results_summary, "output/paper_74/data/results_summary.csv")

cat("\n========================================\n")
cat("INTERPRETATION\n")
cat("========================================\n")

if (att_overall$overall.att > 0) {
  cat(sprintf("Dental therapy authorization is associated with a %.2f percentage point\n",
              att_overall$overall.att * 100))
  cat("INCREASE in the proportion of adults visiting a dentist.\n")
} else {
  cat(sprintf("Dental therapy authorization is associated with a %.2f percentage point\n",
              abs(att_overall$overall.att) * 100))
  cat("DECREASE in the proportion of adults visiting a dentist.\n")
}

pval <- 2 * pnorm(-abs(att_overall$overall.att / att_overall$overall.se))
if (pval < 0.05) {
  cat("This effect is statistically significant at the 5% level.\n")
} else {
  cat("This effect is NOT statistically significant at the 5% level.\n")
  cat("We cannot reject the null hypothesis of no effect.\n")
}

cat("\nAnalysis complete. Results saved to data/\n")
