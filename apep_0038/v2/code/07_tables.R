# =============================================================================
# 07_tables.R
# Generate Publication-Quality Tables
# Sports Betting Employment Effects - Revision of apep_0038
# =============================================================================

source("00_packages.R")

# -----------------------------------------------------------------------------
# Load Data
# -----------------------------------------------------------------------------

cs_data <- read_csv("../data/cs_analysis_data.csv", show_col_types = FALSE)
analysis_sample <- read_csv("../data/analysis_sample.csv", show_col_types = FALSE)
event_study <- read_csv("../data/event_study_coefficients.csv", show_col_types = FALSE)
main_results <- readRDS("../data/main_results.rds")
robustness_results <- readRDS("../data/robustness_results.rds")

# Table directory
tab_dir <- "../tables"
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

# -----------------------------------------------------------------------------
# Table 1: Summary Statistics
# -----------------------------------------------------------------------------

message("Creating Table 1: Summary Statistics...")

summary_stats <- analysis_sample %>%
  group_by(ever_treated_sb) %>%
  summarise(
    n_states = n_distinct(state_abbr),
    n_obs = n(),
    mean_empl = mean(empl_7132, na.rm = TRUE),
    sd_empl = sd(empl_7132, na.rm = TRUE),
    min_empl = min(empl_7132, na.rm = TRUE),
    max_empl = max(empl_7132, na.rm = TRUE),
    mean_estabs = mean(estabs_7132, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    group = if_else(ever_treated_sb, "Treated States", "Control States")
  )

# Pre-treatment balance (2017)
balance_2017 <- analysis_sample %>%
  filter(year == 2017) %>%
  group_by(ever_treated_sb) %>%
  summarise(
    mean_empl = mean(empl_7132, na.rm = TRUE),
    sd_empl = sd(empl_7132, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  )

# T-test for balance
balance_test <- t.test(
  empl_7132 ~ ever_treated_sb,
  data = analysis_sample %>% filter(year == 2017)
)

# Create LaTeX table
table1_latex <- sprintf("
\\begin{table}[htbp]
\\centering
\\caption{Summary Statistics: Gambling Industry Employment (NAICS 7132)}
\\label{tab:summary}
\\begin{tabular}{lcc}
\\toprule
& Treated States & Control States \\\\
\\midrule
\\multicolumn{3}{l}{\\textit{Panel A: Sample Composition}} \\\\
Number of states & %d & %d \\\\
State-year observations & %d & %d \\\\
\\midrule
\\multicolumn{3}{l}{\\textit{Panel B: Employment Statistics (2010--2024)}} \\\\
Mean employment & %.0f & %.0f \\\\
& (%.0f) & (%.0f) \\\\
Min employment & %.0f & %.0f \\\\
Max employment & %.0f & %.0f \\\\
\\midrule
\\multicolumn{3}{l}{\\textit{Panel C: Pre-Treatment Balance (2017)}} \\\\
Mean employment & %.0f & %.0f \\\\
& (%.0f) & (%.0f) \\\\
Difference & \\multicolumn{2}{c}{%.0f} \\\\
t-statistic & \\multicolumn{2}{c}{[%.2f]} \\\\
p-value & \\multicolumn{2}{c}{%.3f} \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}
\\footnotesize
\\item \\textit{Notes:} Standard deviations in parentheses. Treated states are those that legalized sports betting after \\textit{Murphy v. NCAA} (May 2018). Nevada is excluded as always-treated. Employment is annual average from QCEW.
\\end{tablenotes}
\\end{table}
",
  summary_stats$n_states[2], summary_stats$n_states[1],
  summary_stats$n_obs[2], summary_stats$n_obs[1],
  summary_stats$mean_empl[2], summary_stats$mean_empl[1],
  summary_stats$sd_empl[2], summary_stats$sd_empl[1],
  summary_stats$min_empl[2], summary_stats$min_empl[1],
  summary_stats$max_empl[2], summary_stats$max_empl[1],
  balance_2017$mean_empl[2], balance_2017$mean_empl[1],
  balance_2017$sd_empl[2], balance_2017$sd_empl[1],
  balance_2017$mean_empl[2] - balance_2017$mean_empl[1],
  balance_test$statistic,
  balance_test$p.value
)

writeLines(table1_latex, file.path(tab_dir, "table1_summary.tex"))
message("  Saved: table1_summary.tex")

# -----------------------------------------------------------------------------
# Table 2: Treatment Timing
# -----------------------------------------------------------------------------

message("Creating Table 2: Treatment Timing...")

treatment_timing <- analysis_sample %>%
  filter(ever_treated_sb) %>%
  select(state_abbr, sb_year_quarter, has_mobile) %>%
  distinct() %>%
  arrange(sb_year_quarter) %>%
  mutate(
    year = floor(sb_year_quarter),
    quarter = ceiling((sb_year_quarter - year) * 4) + 1,
    timing = sprintf("%d Q%d", year, quarter),
    mobile = if_else(has_mobile, "Yes", "No")
  )

# Group by year
timing_by_year <- treatment_timing %>%
  group_by(year) %>%
  summarise(
    n_states = n(),
    states = paste(state_abbr, collapse = ", "),
    n_mobile = sum(has_mobile),
    .groups = "drop"
  )

table2_latex <- "
\\begin{table}[htbp]
\\centering
\\caption{Sports Betting Legalization Timeline}
\\label{tab:timing}
\\begin{tabular}{clcc}
\\toprule
Year & States & N & Mobile Betting \\\\
\\midrule
"

for (i in 1:nrow(timing_by_year)) {
  table2_latex <- paste0(table2_latex, sprintf(
    "%d & %s & %d & %d \\\\\\n",
    timing_by_year$year[i],
    timing_by_year$states[i],
    timing_by_year$n_states[i],
    timing_by_year$n_mobile[i]
  ))
}

table2_latex <- paste0(table2_latex, "
\\bottomrule
\\end{tabular}
\\begin{tablenotes}
\\footnotesize
\\item \\textit{Notes:} Treatment year is the calendar year of first legal sports bet. Mobile betting indicates whether state permitted mobile/online wagering at any point. Nevada excluded (always-treated).
\\end{tablenotes}
\\end{table}
")

writeLines(table2_latex, file.path(tab_dir, "table2_timing.tex"))
message("  Saved: table2_timing.tex")

# -----------------------------------------------------------------------------
# Table 3: Main Results
# -----------------------------------------------------------------------------

message("Creating Table 3: Main Results...")

table3_latex <- sprintf("
\\begin{table}[htbp]
\\centering
\\caption{Effect of Sports Betting Legalization on Gambling Industry Employment}
\\label{tab:main_results}
\\begin{tabular}{lccc}
\\toprule
& (1) & (2) & (3) \\\\
& CS (Not-Yet-Treated) & CS (Never-Treated) & TWFE \\\\
\\midrule
Sports Betting Legal & %.1f & %.1f & %.1f \\\\
& (%.1f) & (%.1f) & (%.1f) \\\\
& [%.1f, %.1f] & & \\\\
\\midrule
Pre-trend F-test & \\multicolumn{2}{c}{%.2f} & --- \\\\
Pre-trend p-value & \\multicolumn{2}{c}{%.3f} & --- \\\\
\\midrule
Treated states & %d & %d & %d \\\\
Control states & %d & %d & %d \\\\
Observations & %d & %d & %d \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}
\\footnotesize
\\item \\textit{Notes:} Column (1) reports the Callaway-Sant'Anna (2021) average treatment effect on the treated using not-yet-treated states as controls. Column (2) uses never-treated states only. Column (3) reports the traditional two-way fixed effects estimate for comparison. Standard errors clustered at state level in parentheses; 95\\%% confidence interval in brackets. Pre-trend test is joint F-test of pre-treatment event study coefficients. * p<0.10, ** p<0.05, *** p<0.01.
\\end{tablenotes}
\\end{table}
",
  main_results$overall$att, robustness_results$main_att, main_results$twfe_comparison$att,
  main_results$overall$se, robustness_results$main_se, main_results$twfe_comparison$se,
  main_results$overall$ci_low, main_results$overall$ci_high,
  main_results$pre_trend_test$f_stat,
  main_results$pre_trend_test$p_value,
  main_results$overall$n_treated, main_results$overall$n_treated, main_results$overall$n_treated,
  main_results$overall$n_control, main_results$overall$n_control, main_results$overall$n_control + main_results$overall$n_treated,
  nrow(cs_data), nrow(cs_data), nrow(analysis_sample)
)

writeLines(table3_latex, file.path(tab_dir, "table3_main_results.tex"))
message("  Saved: table3_main_results.tex")

# -----------------------------------------------------------------------------
# Table 4: Event Study Coefficients
# -----------------------------------------------------------------------------

message("Creating Table 4: Event Study...")

table4_latex <- "
\\begin{table}[htbp]
\\centering
\\caption{Event Study Estimates: Dynamic Treatment Effects}
\\label{tab:event_study}
\\begin{tabular}{ccccc}
\\toprule
Event Time & Estimate & Std. Error & 95\\% CI Lower & 95\\% CI Upper \\\\
\\midrule
"

for (i in 1:nrow(event_study)) {
  stars <- if_else(event_study$significant[i], "*", "")
  table4_latex <- paste0(table4_latex, sprintf(
    "%d & %.1f%s & (%.1f) & %.1f & %.1f \\\\\\n",
    event_study$event_time[i],
    event_study$att[i], stars,
    event_study$se[i],
    event_study$ci_low[i],
    event_study$ci_high[i]
  ))
}

table4_latex <- paste0(table4_latex, "
\\bottomrule
\\end{tabular}
\\begin{tablenotes}
\\footnotesize
\\item \\textit{Notes:} Event time 0 is the year of first legal sports bet. Estimates from Callaway-Sant'Anna (2021) with not-yet-treated control group. Standard errors in parentheses. * indicates significance at 5\\% level.
\\end{tablenotes}
\\end{table}
")

writeLines(table4_latex, file.path(tab_dir, "table4_event_study.tex"))
message("  Saved: table4_event_study.tex")

# -----------------------------------------------------------------------------
# Table 5: Robustness Checks
# -----------------------------------------------------------------------------

message("Creating Table 5: Robustness...")

table5_latex <- sprintf("
\\begin{table}[htbp]
\\centering
\\caption{Robustness Checks}
\\label{tab:robustness}
\\begin{tabular}{lcc}
\\toprule
Specification & ATT & Std. Error \\\\
\\midrule
Main result (CS, not-yet-treated) & %.1f & (%.1f) \\\\
\\midrule
\\multicolumn{3}{l}{\\textit{COVID-19 Sensitivity}} \\\\
\\quad Excluding 2020--2021 & %.1f & (%.1f) \\\\
\\midrule
\\multicolumn{3}{l}{\\textit{Sample Restrictions}} \\\\
\\quad Excluding PASPA states (DE, MT, OR) & %.1f & (%.1f) \\\\
\\quad Excluding iGaming states & %.1f & (%.1f) \\\\
\\midrule
\\multicolumn{3}{l}{\\textit{Alternative Estimators}} \\\\
\\quad Two-way fixed effects & %.1f & (%.1f) \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}
\\footnotesize
\\item \\textit{Notes:} Main result uses Callaway-Sant'Anna (2021) with not-yet-treated control group. PASPA states had limited sports betting authorization pre-\\textit{Murphy}. iGaming states legalized online casino gaming concurrently with sports betting. Standard errors clustered at state level.
\\end{tablenotes}
\\end{table}
",
  main_results$overall$att, main_results$overall$se,
  robustness_results$covid_sensitivity$exclude_2020_2021$att,
  robustness_results$covid_sensitivity$exclude_2020_2021$se,
  robustness_results$paspa_sensitivity$exclude_de_mt_or$att,
  robustness_results$paspa_sensitivity$exclude_de_mt_or$se,
  robustness_results$igaming_sensitivity$exclude_igaming$att,
  robustness_results$igaming_sensitivity$exclude_igaming$se,
  main_results$twfe_comparison$att, main_results$twfe_comparison$se
)

writeLines(table5_latex, file.path(tab_dir, "table5_robustness.tex"))
message("  Saved: table5_robustness.tex")

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------

message("\n", paste(rep("=", 60), collapse = ""))
message("All tables saved to: ", tab_dir)
message(paste(rep("=", 60), collapse = ""))

list.files(tab_dir, pattern = "\\.tex$")
