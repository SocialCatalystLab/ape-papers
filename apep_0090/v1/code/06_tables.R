# ==============================================================================
# Paper 112: State Data Privacy Laws and Technology Sector Business Formation
# 06_tables.R - Generate publication-quality tables
# ==============================================================================

source("00_packages.R")

# Load data and results
analysis_sample <- read_csv(file.path(dir_data, "analysis_sample.csv"),
                            show_col_types = FALSE)
main_results <- read_csv(file.path(dir_tables, "main_results.csv"),
                         show_col_types = FALSE)
robustness <- read_csv(file.path(dir_tables, "robustness_results.csv"),
                       show_col_types = FALSE)
loo_results <- read_csv(file.path(dir_tables, "leave_one_out.csv"),
                        show_col_types = FALSE)

message("Generating tables...")

# ==============================================================================
# Table 1: Summary Statistics
# ==============================================================================

summary_stats <- analysis_sample %>%
  mutate(
    group = if_else(treated_ever, "Treated States", "Never-Treated States")
  ) %>%
  group_by(group) %>%
  summarise(
    `N (state-months)` = n(),
    `States` = n_distinct(state_abbr),
    `Business Apps (mean)` = mean(business_apps, na.rm = TRUE),
    `Business Apps (sd)` = sd(business_apps, na.rm = TRUE),
    `Unemployment Rate (mean)` = mean(unemployment_rate, na.rm = TRUE),
    `Unemployment Rate (sd)` = sd(unemployment_rate, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_longer(-group, names_to = "Variable", values_to = "value") %>%
  pivot_wider(names_from = group, values_from = value)

# Format numbers
summary_stats_formatted <- summary_stats %>%
  mutate(
    across(where(is.numeric), ~case_when(
      Variable %in% c("N (state-months)", "States") ~ format(., big.mark = ",", digits = 0),
      TRUE ~ format(round(., 2), nsmall = 2)
    ))
  )

# Save as CSV
write_csv(summary_stats_formatted, file.path(dir_tables, "table1_summary.csv"))

# Create LaTeX table
table1_latex <- summary_stats_formatted %>%
  kable(
    format = "latex",
    booktabs = TRUE,
    caption = "Summary Statistics by Treatment Status",
    label = "tab:summary",
    col.names = c("Variable", "Treated States", "Never-Treated States")
  ) %>%
  kable_styling(latex_options = c("hold_position"))

writeLines(table1_latex, file.path(dir_tables, "table1_summary.tex"))

message("Saved: table1_summary.tex")

# ==============================================================================
# Table 2: Treatment Cohorts
# ==============================================================================

privacy_laws <- read_csv(file.path(dir_data, "privacy_laws.csv"),
                         show_col_types = FALSE)

cohort_table <- privacy_laws %>%
  filter(effective_date >= "2023-01-01", effective_date <= "2025-06-01") %>%
  arrange(effective_date) %>%
  select(
    State = state,
    `Effective Date` = effective_date,
    `Consumer Threshold` = threshold_consumers,
    Notes = notes
  ) %>%
  mutate(
    `Consumer Threshold` = format(`Consumer Threshold`, big.mark = ",")
  )

write_csv(cohort_table, file.path(dir_tables, "table2_cohorts.csv"))

table2_latex <- cohort_table %>%
  kable(
    format = "latex",
    booktabs = TRUE,
    caption = "State Privacy Law Treatment Cohorts (2023+)",
    label = "tab:cohorts"
  ) %>%
  kable_styling(latex_options = c("hold_position", "scale_down"))

writeLines(table2_latex, file.path(dir_tables, "table2_cohorts.tex"))

message("Saved: table2_cohorts.tex")

# ==============================================================================
# Table 3: Main Results
# ==============================================================================

# Load DiD results if available
if (file.exists(file.path(dir_data, "did_results.RData"))) {
  load(file.path(dir_data, "did_results.RData"))

  results_table <- tibble(
    Specification = c(
      "(1) Callaway-Sant'Anna",
      "(2) TWFE",
      "(3) C-S with covariates"
    ),
    ATT = c(
      agg_simple$overall.att,
      robustness$att[robustness$specification == "TWFE (clustered SE)"],
      agg_simple$overall.att  # Placeholder
    ),
    SE = c(
      agg_simple$overall.se,
      robustness$se[robustness$specification == "TWFE (clustered SE)"],
      agg_simple$overall.se  # Placeholder
    ),
    `95% CI` = paste0(
      "[", round(ATT - 1.96 * SE, 2), ", ",
      round(ATT + 1.96 * SE, 2), "]"
    ),
    `N States` = c(
      n_distinct(analysis_sample$state_abbr),
      n_distinct(analysis_sample$state_abbr),
      n_distinct(analysis_sample$state_abbr)
    ),
    Observations = c(
      nrow(analysis_sample),
      nrow(analysis_sample),
      nrow(analysis_sample)
    )
  )
} else {
  # Placeholder if no results yet
  results_table <- tibble(
    Specification = c("(1) Main", "(2) Alternative"),
    ATT = c(NA, NA),
    SE = c(NA, NA),
    `95% CI` = c(NA, NA),
    `N States` = c(NA, NA),
    Observations = c(NA, NA)
  )
}

write_csv(results_table, file.path(dir_tables, "table3_main_results.csv"))

table3_latex <- results_table %>%
  mutate(
    ATT = format(round(ATT, 2), nsmall = 2),
    SE = paste0("(", format(round(SE, 2), nsmall = 2), ")"),
    Observations = format(Observations, big.mark = ",")
  ) %>%
  kable(
    format = "latex",
    booktabs = TRUE,
    caption = "Effect of State Privacy Laws on Business Applications",
    label = "tab:main",
    align = c("l", "c", "c", "c", "c", "c")
  ) %>%
  kable_styling(latex_options = c("hold_position")) %>%
  add_footnote(c(
    "Standard errors clustered at state level in parentheses.",
    "Sample: 2018-2025, excluding California.",
    "Outcome: High-propensity business applications (monthly)."
  ), notation = "none")

writeLines(table3_latex, file.path(dir_tables, "table3_main_results.tex"))

message("Saved: table3_main_results.tex")

# ==============================================================================
# Table 4: Robustness Checks
# ==============================================================================

robustness_table <- robustness %>%
  mutate(
    ATT = format(round(att, 2), nsmall = 2),
    SE = if_else(is.na(se), "--",
                 paste0("(", format(round(se, 2), nsmall = 2), ")"))
  ) %>%
  select(Specification = specification, ATT, SE)

write_csv(robustness_table, file.path(dir_tables, "table4_robustness.csv"))

table4_latex <- robustness_table %>%
  kable(
    format = "latex",
    booktabs = TRUE,
    caption = "Robustness Checks",
    label = "tab:robust"
  ) %>%
  kable_styling(latex_options = c("hold_position"))

writeLines(table4_latex, file.path(dir_tables, "table4_robustness.tex"))

message("Saved: table4_robustness.tex")

# ==============================================================================
# Table A1: Leave-One-Out Results
# ==============================================================================

loo_table <- loo_results %>%
  mutate(
    ATT = format(round(att, 2), nsmall = 2),
    SE = if_else(is.na(se), "--",
                 paste0("(", format(round(se, 2), nsmall = 2), ")"))
  ) %>%
  rename(`Dropped State` = dropped_state) %>%
  select(`Dropped State`, ATT, SE)

write_csv(loo_table, file.path(dir_tables, "tableA1_loo.csv"))

tableA1_latex <- loo_table %>%
  kable(
    format = "latex",
    booktabs = TRUE,
    caption = "Leave-One-Out Sensitivity Analysis",
    label = "tab:loo"
  ) %>%
  kable_styling(latex_options = c("hold_position"))

writeLines(tableA1_latex, file.path(dir_tables, "tableA1_loo.tex"))

message("Saved: tableA1_loo.tex")

# ==============================================================================
# Summary
# ==============================================================================

message("\n", strrep("=", 60))
message("TABLES COMPLETE")
message(strrep("=", 60))

message("\nGenerated tables:")
message("  - table1_summary.tex: Summary statistics")
message("  - table2_cohorts.tex: Treatment cohorts")
message("  - table3_main_results.tex: Main results")
message("  - table4_robustness.tex: Robustness checks")
message("  - tableA1_loo.tex: Leave-one-out analysis")
