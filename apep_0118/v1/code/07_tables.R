# =============================================================================
# 07_tables.R
# Generate Publication-Quality Tables
# Paper 117: Sports Betting Employment Effects
# =============================================================================

source("00_packages.R")

# =============================================================================
# Load Results
# =============================================================================

message("Loading results...")
main_results <- readRDS("../data/main_results.rds")
robustness_results <- readRDS("../data/robustness_results.rds")
analysis_df <- read_csv("../data/analysis_sample.csv", show_col_types = FALSE)
policy_panel <- read_csv("../data/policy_panel.csv", show_col_types = FALSE)
event_coefs <- read_csv("../data/event_study_coefficients.csv", show_col_types = FALSE)

# =============================================================================
# Table 1: Summary Statistics
# =============================================================================

message("\nCreating Table 1: Summary Statistics...")

# Pre-treatment summary by treatment status
pre_summary <- analysis_df %>%
  filter(year <= 2017) %>%
  mutate(group = if_else(g > 0, "Eventually Treated", "Never Treated")) %>%
  group_by(group) %>%
  summarise(
    `N (state-years)` = n(),
    `States` = n_distinct(state_abbr),
    `Mean Employment` = sprintf("%.0f", mean(employment, na.rm = TRUE)),
    `SD Employment` = sprintf("%.0f", sd(employment, na.rm = TRUE)),
    `Mean Establishments` = sprintf("%.0f", mean(establishments, na.rm = TRUE)),
    `Mean Weekly Wage` = sprintf("$%.0f", mean(avg_weekly_wage, na.rm = TRUE)),
    .groups = "drop"
  )

# Full sample summary
full_summary <- analysis_df %>%
  summarise(
    `N (state-years)` = n(),
    `States` = n_distinct(state_abbr),
    `Mean Employment` = sprintf("%.0f", mean(employment, na.rm = TRUE)),
    `SD Employment` = sprintf("%.0f", sd(employment, na.rm = TRUE)),
    `Mean Establishments` = sprintf("%.0f", mean(establishments, na.rm = TRUE)),
    `Mean Weekly Wage` = sprintf("$%.0f", mean(avg_weekly_wage, na.rm = TRUE))
  ) %>%
  mutate(group = "Full Sample", .before = 1)

summary_table <- bind_rows(pre_summary, full_summary)

# Write LaTeX table
table1_tex <- kable(summary_table, format = "latex", booktabs = TRUE,
                    caption = "Summary Statistics: Gambling Industry Employment (NAICS 7132)",
                    label = "tab:summary") %>%
  kable_styling(latex_options = c("hold_position")) %>%
  add_header_above(c(" " = 1, "Pre-Treatment (2010-2017)" = 6))

writeLines(table1_tex, "../tables/table1_summary.tex")
message("Saved: table1_summary.tex")

# =============================================================================
# Table 2: Treatment Timing
# =============================================================================

message("\nCreating Table 2: Treatment Timing...")

timing_table <- policy_panel %>%
  filter(!is.na(sb_year) & sb_type == "new") %>%
  arrange(sb_year, state_abbr) %>%
  group_by(sb_year) %>%
  summarise(
    `N States` = n(),
    `States` = paste(state_abbr, collapse = ", "),
    .groups = "drop"
  ) %>%
  rename(`Year` = sb_year)

table2_tex <- kable(timing_table, format = "latex", booktabs = TRUE,
                    caption = "Sports Betting Legalization Timing",
                    label = "tab:timing") %>%
  kable_styling(latex_options = c("hold_position")) %>%
  column_spec(3, width = "8cm")

writeLines(table2_tex, "../tables/table2_timing.tex")
message("Saved: table2_timing.tex")

# =============================================================================
# Table 3: Main Results
# =============================================================================

message("\nCreating Table 3: Main Results...")

# Extract main results
cs_overall <- main_results$cs_overall
cs_nevertreated <- main_results$cs_nevertreated
twfe <- main_results$twfe_result

# Safe extraction
get_val <- function(x, default = NA) if (is.null(x) || is.na(x)) default else x

main_table <- tibble(
  Specification = c(
    "Callaway-Sant'Anna (not-yet-treated)",
    "TWFE (biased)"
  ),
  ATT = c(
    sprintf("%.4f", get_val(cs_overall$overall.att, 0)),
    sprintf("%.4f", coef(twfe)["treated_sb"])
  ),
  SE = c(
    sprintf("(%.4f)", get_val(cs_overall$overall.se, 0)),
    sprintf("(%.4f)", se(twfe)["treated_sb"])
  ),
  `Pct Change` = c(
    sprintf("%.1f%%", (exp(get_val(cs_overall$overall.att, 0)) - 1) * 100),
    sprintf("%.1f%%", (exp(coef(twfe)["treated_sb"]) - 1) * 100)
  )
)

table3_tex <- kable(main_table, format = "latex", booktabs = TRUE,
                    caption = "Main Results: Effect of Sports Betting on Gambling Employment",
                    label = "tab:main") %>%
  kable_styling(latex_options = c("hold_position")) %>%
  footnote(general = "Standard errors in parentheses. Outcome is log employment in NAICS 7132 (Gambling Industries). Callaway-Sant'Anna estimator uses doubly robust estimation. TWFE shown for comparison but is known to be biased with staggered adoption.",
           threeparttable = TRUE)

writeLines(table3_tex, "../tables/table3_main.tex")
message("Saved: table3_main.tex")

# =============================================================================
# Table 4: Event Study Coefficients
# =============================================================================

message("\nCreating Table 4: Event Study...")

event_table <- event_coefs %>%
  mutate(
    `Event Time` = event_time,
    ATT = sprintf("%.4f", att),
    SE = sprintf("(%.4f)", se),
    `95% CI` = sprintf("[%.4f, %.4f]", ci_lower, ci_upper),
    Significant = if_else(ci_lower > 0 | ci_upper < 0, "*", "")
  ) %>%
  select(`Event Time`, ATT, SE, `95% CI`, Significant)

table4_tex <- kable(event_table, format = "latex", booktabs = TRUE,
                    caption = "Event Study Coefficients",
                    label = "tab:eventstudy") %>%
  kable_styling(latex_options = c("hold_position")) %>%
  footnote(general = "* indicates 95% confidence interval excludes zero. Event time 0 is the year of first legal sports bet.",
           threeparttable = TRUE)

writeLines(table4_tex, "../tables/table4_eventstudy.tex")
message("Saved: table4_eventstudy.tex")

# =============================================================================
# Table 5: Robustness
# =============================================================================

message("\nCreating Table 5: Robustness...")

robust_table <- robustness_results$summary %>%
  mutate(
    Specification = specification,
    ATT = sprintf("%.4f", att),
    SE = sprintf("(%.4f)", se),
    `95% CI` = sprintf("[%.4f, %.4f]", ci_lower, ci_upper),
    `Pct Change` = sprintf("%.1f%%", pct_change)
  ) %>%
  select(Specification, ATT, SE, `95% CI`, `Pct Change`)

table5_tex <- kable(robust_table, format = "latex", booktabs = TRUE,
                    caption = "Robustness Checks",
                    label = "tab:robust") %>%
  kable_styling(latex_options = c("hold_position"))

writeLines(table5_tex, "../tables/table5_robustness.tex")
message("Saved: table5_robustness.tex")

# =============================================================================
# Table 6: Placebo Tests
# =============================================================================

message("\nCreating Table 6: Placebo Tests...")

if (file.exists("../data/placebo_results.csv")) {
  placebo_df <- read_csv("../data/placebo_results.csv", show_col_types = FALSE)

  placebo_table <- placebo_df %>%
    mutate(
      Industry = industry,
      NAICS = industry_code,
      ATT = sprintf("%.4f", att),
      SE = sprintf("(%.4f)", se),
      `p-value` = sprintf("%.3f", pvalue)
    ) %>%
    select(Industry, NAICS, ATT, SE, `p-value`)

  table6_tex <- kable(placebo_table, format = "latex", booktabs = TRUE,
                      caption = "Placebo Tests: Non-Gambling Industries",
                      label = "tab:placebo") %>%
    kable_styling(latex_options = c("hold_position")) %>%
    footnote(general = "Sports betting legalization should not affect employment in unrelated industries. Failure to reject null hypothesis supports identification.",
             threeparttable = TRUE)

  writeLines(table6_tex, "../tables/table6_placebo.tex")
  message("Saved: table6_placebo.tex")
}

# =============================================================================
# Summary
# =============================================================================

message("\n", paste(rep("=", 70), collapse = ""))
message("TABLES COMPLETE")
message(paste(rep("=", 70), collapse = ""))

message("\nTables created:")
message("  table1_summary.tex     - Summary statistics")
message("  table2_timing.tex      - Treatment timing")
message("  table3_main.tex        - Main results")
message("  table4_eventstudy.tex  - Event study coefficients")
message("  table5_robustness.tex  - Robustness checks")
message("  table6_placebo.tex     - Placebo tests")
