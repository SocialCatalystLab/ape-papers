# 06_tables.R
# Generate LaTeX tables for Promise Program paper

source("00_packages.R")

# =============================================================================
# 1. LOAD DATA AND RESULTS
# =============================================================================

df <- readRDS("../data/clean_panel.rds")
treatment_timing <- read_csv("../data/promise_treatment_timing.csv", show_col_types = FALSE)
cs_aggregates <- readRDS("../data/cs_aggregates.rds")

message("Data and results loaded")

# =============================================================================
# 2. TABLE 1: TREATMENT TIMING
# =============================================================================

message("Creating Table 1: Treatment timing")

promise_programs <- read_csv("../data/promise_treatment_timing.csv", show_col_types = FALSE) %>%
  filter(ever_treated) %>%
  arrange(first_cohort_year)

# Create LaTeX table
table1_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{State College Promise Program Adoption Timing}\n",
  "\\label{tab:treatment_timing}\n",
  "\\begin{tabular}{lcc}\n",
  "\\toprule\n",
  "State & First Cohort Year & Notes \\\\\n",
  "\\midrule\n"
)

for (i in 1:nrow(promise_programs)) {
  table1_tex <- paste0(table1_tex,
    promise_programs$state_abbr[i], " & ",
    promise_programs$first_cohort_year[i], " & \\\\\n"
  )
}

table1_tex <- paste0(table1_tex,
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\floatfoot{\\textit{Notes:} Programs provide tuition subsidies (typically ``last-dollar'' after other aid) for community college attendance. ",
  "Source: NCSL State College Promise Landscape, state legislative records.}\n",
  "\\end{table}\n"
)

writeLines(table1_tex, "../tables/table1_treatment_timing.tex")

# =============================================================================
# 3. TABLE 2: SUMMARY STATISTICS
# =============================================================================

message("Creating Table 2: Summary statistics")

# Pre-treatment summary by group
summary_stats <- df %>%
  filter(year <= 2014) %>%
  group_by(ever_treated) %>%
  summarize(
    `N (state-years)` = n(),
    `Mean Enrollment` = mean(total_college_enrolled, na.rm = TRUE),
    `SD Enrollment` = sd(total_college_enrolled, na.rm = TRUE),
    `Mean Undergrad Share` = mean(undergrad_enrolled / total_college_enrolled, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    Group = ifelse(ever_treated, "Promise States", "Non-Promise States")
  ) %>%
  select(Group, everything(), -ever_treated)

# Format for LaTeX
table2_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Summary Statistics: Pre-Treatment Period (2010--2014)}\n",
  "\\label{tab:summary_stats}\n",
  "\\begin{tabular}{lcccc}\n",
  "\\toprule\n",
  " & N & Mean Enrollment & SD Enrollment & Undergrad Share \\\\\n",
  "\\midrule\n"
)

for (i in 1:nrow(summary_stats)) {
  table2_tex <- paste0(table2_tex,
    summary_stats$Group[i], " & ",
    summary_stats$`N (state-years)`[i], " & ",
    format(round(summary_stats$`Mean Enrollment`[i], 0), big.mark = ","), " & ",
    format(round(summary_stats$`SD Enrollment`[i], 0), big.mark = ","), " & ",
    round(summary_stats$`Mean Undergrad Share`[i], 3), " \\\\\n"
  )
}

table2_tex <- paste0(table2_tex,
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\floatfoot{\\textit{Notes:} Statistics calculated from ACS state-level college enrollment data. ",
  "Promise states are those that adopted a statewide program by 2021.}\n",
  "\\end{table}\n"
)

writeLines(table2_tex, "../tables/table2_summary_stats.tex")

# =============================================================================
# 4. TABLE 3: MAIN RESULTS
# =============================================================================

message("Creating Table 3: Main results")

main_results <- read_csv("../tables/main_results.csv", show_col_types = FALSE)

table3_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Effect of Promise Programs on College Enrollment}\n",
  "\\label{tab:main_results}\n",
  "\\begin{tabular}{lcccc}\n",
  "\\toprule\n",
  "Specification & Estimate & SE & 95\\% CI & p-value \\\\\n",
  "\\midrule\n"
)

for (i in 1:nrow(main_results)) {
  table3_tex <- paste0(table3_tex,
    main_results$Specification[i], " & ",
    main_results$Estimate[i], " & ",
    main_results$SE[i], " & ",
    "[", main_results$`95% CI Lower`[i], ", ", main_results$`95% CI Upper`[i], "]", " & ",
    ifelse(is.na(main_results$`P-value`[i]), "--", round(main_results$`P-value`[i], 3)), " \\\\\n"
  )
}

table3_tex <- paste0(table3_tex,
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\floatfoot{\\textit{Notes:} Dependent variable is log college enrollment. ",
  "CS DiD uses the Callaway-Sant'Anna (2021) estimator with never-treated states as controls. ",
  "Standard errors clustered at the state level. ",
  "Estimates represent effect in log points; multiply by 100 for approximate percentage effect.}\n",
  "\\end{table}\n"
)

writeLines(table3_tex, "../tables/table3_main_results.tex")

# =============================================================================
# 5. TABLE 4: ROBUSTNESS CHECKS
# =============================================================================

message("Creating Table 4: Robustness checks")

robustness <- read_csv("../tables/robustness_table.csv", show_col_types = FALSE)

table4_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Robustness Checks}\n",
  "\\label{tab:robustness}\n",
  "\\begin{tabular}{lcccl}\n",
  "\\toprule\n",
  "Specification & Estimate & SE & p-value & Notes \\\\\n",
  "\\midrule\n"
)

for (i in 1:nrow(robustness)) {
  table4_tex <- paste0(table4_tex,
    robustness$Specification[i], " & ",
    ifelse(is.na(robustness$Estimate[i]), "--", robustness$Estimate[i]), " & ",
    ifelse(is.na(robustness$SE[i]), "--", robustness$SE[i]), " & ",
    ifelse(is.na(robustness$Pvalue[i]), "--", robustness$Pvalue[i]), " & ",
    robustness$Notes[i], " \\\\\n"
  )
}

table4_tex <- paste0(table4_tex,
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\floatfoot{\\textit{Notes:} All specifications use log enrollment as dependent variable. ",
  "Randomization inference permutes treatment across states 1,000 times. ",
  "Placebo test assigns pseudo-treatment 3 years before actual adoption.}\n",
  "\\end{table}\n"
)

writeLines(table4_tex, "../tables/table4_robustness.tex")

# =============================================================================
# 6. TABLE 5: HETEROGENEITY BY COHORT
# =============================================================================

message("Creating Table 5: Heterogeneity")

att_group <- cs_aggregates$group

group_table <- tibble(
  Cohort = att_group$egt,
  Estimate = round(att_group$att.egt, 4),
  SE = round(att_group$se.egt, 4)
) %>%
  filter(!is.na(Estimate)) %>%
  mutate(
    `95% CI` = paste0("[", round(Estimate - 1.96*SE, 4), ", ", round(Estimate + 1.96*SE, 4), "]")
  )

table5_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Heterogeneous Effects by Adoption Cohort}\n",
  "\\label{tab:heterogeneity}\n",
  "\\begin{tabular}{lccc}\n",
  "\\toprule\n",
  "Adoption Year & ATT & SE & 95\\% CI \\\\\n",
  "\\midrule\n"
)

for (i in 1:nrow(group_table)) {
  table5_tex <- paste0(table5_tex,
    group_table$Cohort[i], " & ",
    group_table$Estimate[i], " & ",
    group_table$SE[i], " & ",
    group_table$`95% CI`[i], " \\\\\n"
  )
}

table5_tex <- paste0(table5_tex,
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\floatfoot{\\textit{Notes:} Group-specific average treatment effects on the treated (ATT) ",
  "from Callaway-Sant'Anna estimator. Each row shows the effect for states adopting in that year.}\n",
  "\\end{table}\n"
)

writeLines(table5_tex, "../tables/table5_heterogeneity.tex")

message("\n=== TABLES SAVED ===")
message("All tables saved to ../tables/")
