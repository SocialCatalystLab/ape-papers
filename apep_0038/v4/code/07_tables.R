# =============================================================================
# 07_tables.R
# Generate Publication-Quality Tables
# Sports Betting Employment Effects - Revision of apep_0038 (v3)
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
    mean_wage = mean(wkly_wage_7132, na.rm = TRUE),
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
    mean_wage = mean(wkly_wage_7132, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  )

# T-test for balance
balance_test <- t.test(
  empl_7132 ~ ever_treated_sb,
  data = analysis_sample %>% filter(year == 2017)
)

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
Mean avg. weekly wage & \\$%.0f & \\$%.0f \\\\
\\midrule
\\multicolumn{3}{l}{\\textit{Panel C: Pre-Treatment Balance (2017)}} \\\\
Mean employment & %.0f & %.0f \\\\
& (%.0f) & (%.0f) \\\\
Mean avg. weekly wage & \\$%.0f & \\$%.0f \\\\
Difference (empl.) & \\multicolumn{2}{c}{%.0f} \\\\
t-statistic & \\multicolumn{2}{c}{[%.2f]} \\\\
p-value & \\multicolumn{2}{c}{%.3f} \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}
\\footnotesize
\\item \\textit{Notes:} Standard deviations in parentheses. Treated states are those that legalized sports betting after \\textit{Murphy v. NCAA} (May 2018). Nevada is excluded as always-treated. Employment is annual average from QCEW. Average weekly wage from BLS QCEW administrative records.
\\end{tablenotes}
\\end{table}
",
  summary_stats$n_states[2], summary_stats$n_states[1],
  summary_stats$n_obs[2], summary_stats$n_obs[1],
  summary_stats$mean_empl[2], summary_stats$mean_empl[1],
  summary_stats$sd_empl[2], summary_stats$sd_empl[1],
  summary_stats$min_empl[2], summary_stats$min_empl[1],
  summary_stats$max_empl[2], summary_stats$max_empl[1],
  summary_stats$mean_wage[2], summary_stats$mean_wage[1],
  balance_2017$mean_empl[2], balance_2017$mean_empl[1],
  balance_2017$sd_empl[2], balance_2017$sd_empl[1],
  balance_2017$mean_wage[2], balance_2017$mean_wage[1],
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
    "%d & %s & %d & %d \\\\\n",
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
& [%.1f, %.1f] & [%.1f, %.1f] & \\\\
\\midrule
Pre-trend F-test & %.2f & --- & --- \\\\
Pre-trend p-value & %.3f & --- & --- \\\\
\\midrule
Treated states & %d & %d & %d \\\\
Control states & %d & %d & %d \\\\
Observations & %d & %d & %d \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}
\\footnotesize
\\item \\textit{Notes:} Column (1) reports the Callaway-Sant'Anna (2021) average treatment effect on the treated using not-yet-treated states as controls. Column (2) uses never-treated states only. Column (3) reports the traditional two-way fixed effects estimate for comparison. Standard errors clustered at state level in parentheses; 95\\%% confidence interval in brackets. Pre-trend test is joint Wald test of pre-treatment event study coefficients using full variance-covariance matrix. * p<0.10, ** p<0.05, *** p<0.01.
\\end{tablenotes}
\\end{table}
",
  main_results$overall$att, main_results$never_treated$att, main_results$twfe_comparison$att,
  main_results$overall$se, main_results$never_treated$se, main_results$twfe_comparison$se,
  main_results$overall$ci_low, main_results$overall$ci_high,
  main_results$never_treated$att - 1.96 * main_results$never_treated$se,
  main_results$never_treated$att + 1.96 * main_results$never_treated$se,
  main_results$pre_trend_test$f_stat,
  main_results$pre_trend_test$p_value,
  main_results$overall$n_treated, main_results$overall$n_treated, main_results$overall$n_treated,
  main_results$overall$n_control, main_results$overall$n_control,
  main_results$overall$n_control + main_results$overall$n_treated,
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
    "%d & %.1f%s & (%.1f) & %.1f & %.1f \\\\\n",
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
# Table: Heterogeneity
# -----------------------------------------------------------------------------

message("Creating Table: Heterogeneity...")

het_rows <- list()

if (!is.null(main_results$heterogeneity$mobile)) {
  het_rows[["Mobile betting states"]] <- main_results$heterogeneity$mobile
}
if (!is.null(main_results$heterogeneity$retail)) {
  het_rows[["Retail-only states"]] <- main_results$heterogeneity$retail
}
if (!is.null(main_results$heterogeneity$precovid)) {
  het_rows[["Pre-COVID cohorts (2018--2019)"]] <- main_results$heterogeneity$precovid
}

table_het_latex <- "
\\begin{table}[htbp]
\\centering
\\caption{Heterogeneity in Treatment Effects}
\\label{tab:heterogeneity}
\\begin{tabular}{lcc}
\\toprule
Subgroup & ATT & Std. Error \\\\
\\midrule
"

for (nm in names(het_rows)) {
  table_het_latex <- paste0(table_het_latex, sprintf(
    "%s & %.1f & (%.1f) \\\\\n",
    nm, het_rows[[nm]]$att, het_rows[[nm]]$se
  ))
}

table_het_latex <- paste0(table_het_latex, "
\\bottomrule
\\end{tabular}
\\begin{tablenotes}
\\footnotesize
\\item \\textit{Notes:} Each row reports the Callaway-Sant'Anna ATT for the indicated subgroup. Mobile betting states are those that permitted online/mobile wagering. Standard errors clustered at state level.
\\end{tablenotes}
\\end{table}
")

writeLines(table_het_latex, file.path(tab_dir, "table_heterogeneity.tex"))
message("  Saved: table_heterogeneity.tex")

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
%s\\midrule
\\multicolumn{3}{l}{\\textit{Sample Restrictions}} \\\\
\\quad Excluding PASPA states (DE, MT, OR) & %.1f & (%.1f) \\\\
\\quad Excluding iGaming states & %.1f & (%.1f) \\\\
\\midrule
\\multicolumn{3}{l}{\\textit{Alternative Specifications}} \\\\
\\quad Never-treated control group & %.1f & (%.1f) \\\\
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
  if (!is.null(robustness_results$covid_sensitivity$pre_covid_cohorts))
    sprintf("\\quad Pre-COVID cohorts (2018--2019 only) & %.1f & (%.1f) \\\\\n",
            robustness_results$covid_sensitivity$pre_covid_cohorts$att,
            robustness_results$covid_sensitivity$pre_covid_cohorts$se)
  else "",
  robustness_results$paspa_sensitivity$exclude_de_mt_or$att,
  robustness_results$paspa_sensitivity$exclude_de_mt_or$se,
  robustness_results$igaming_sensitivity$exclude_igaming$att,
  robustness_results$igaming_sensitivity$exclude_igaming$se,
  main_results$never_treated$att, main_results$never_treated$se,
  main_results$twfe_comparison$att, main_results$twfe_comparison$se
)

writeLines(table5_latex, file.path(tab_dir, "table5_robustness.tex"))
message("  Saved: table5_robustness.tex")

# -----------------------------------------------------------------------------
# Table 6: HonestDiD Sensitivity
# -----------------------------------------------------------------------------

message("Creating Table 6: HonestDiD...")

if (!is.null(robustness_results$honest_did) && nrow(robustness_results$honest_did) > 0) {
  honest_data <- robustness_results$honest_did

  # Try to get the average_post results, or fall back to whatever we have
  if ("target" %in% names(honest_data)) {
    honest_avg <- honest_data %>% filter(target == "average_post")
    if (nrow(honest_avg) == 0) honest_avg <- honest_data
  } else {
    honest_avg <- honest_data
  }

  # Detect column names (HonestDiD package vs manual fallback)
  if ("Mbar" %in% names(honest_avg)) {
    mbar_col <- "Mbar"
  } else if ("M" %in% names(honest_avg)) {
    mbar_col <- "M"
  } else {
    mbar_col <- names(honest_avg)[1]
  }

  if ("ci_low" %in% names(honest_avg)) {
    lb_col <- "ci_low"
    ub_col <- "ci_high"
  } else if ("lb" %in% names(honest_avg)) {
    lb_col <- "lb"
    ub_col <- "ub"
  } else {
    lb_col <- names(honest_avg)[2]
    ub_col <- names(honest_avg)[3]
  }

  table6_latex <- "
\\begin{table}[htbp]
\\centering
\\caption{HonestDiD Sensitivity Analysis (Rambachan-Roth)}
\\label{tab:honestdid}
\\begin{tabular}{ccc}
\\toprule
$\\bar{M}$ & 95\\% CI Lower & 95\\% CI Upper \\\\
\\midrule
"

  for (i in 1:nrow(honest_avg)) {
    table6_latex <- paste0(table6_latex, sprintf(
      "%.1f & %.1f & %.1f \\\\\n",
      honest_avg[[mbar_col]][i],
      honest_avg[[lb_col]][i],
      honest_avg[[ub_col]][i]
    ))
  }

  table6_latex <- paste0(table6_latex, "
\\bottomrule
\\end{tabular}
\\begin{tablenotes}
\\footnotesize
\\item \\textit{Notes:} $\\bar{M}$ bounds the ratio of the maximum post-treatment trend deviation to the maximum pre-treatment trend deviation. $\\bar{M} = 0$ corresponds to exact parallel trends. $\\bar{M} = 1$ allows post-treatment deviations equal to the largest observed pre-treatment deviation. Confidence intervals computed using \\cite{RambachanRoth2023} relative magnitudes approach.
\\end{tablenotes}
\\end{table}
")

  writeLines(table6_latex, file.path(tab_dir, "table6_honestdid.tex"))
  message("  Saved: table6_honestdid.tex")

} else {
  message("  No HonestDiD results available, skipping table")
}

# -----------------------------------------------------------------------------
# Table 7: Placebo Tests
# -----------------------------------------------------------------------------

message("Creating Table 7: Placebo...")

table7_latex <- "
\\begin{table}[htbp]
\\centering
\\caption{Placebo Tests: Unrelated Industries}
\\label{tab:placebo}
\\begin{tabular}{lcc}
\\toprule
Industry & ATT & Std. Error \\\\
\\midrule
"

if (!is.null(robustness_results$placebo$manufacturing)) {
  mfg_t <- robustness_results$placebo$manufacturing$att / robustness_results$placebo$manufacturing$se
  mfg_stars <- if_else(abs(mfg_t) > 1.96, "*", "")
  table7_latex <- paste0(table7_latex, sprintf(
    "Manufacturing (NAICS 31-33) & %.1f%s & (%.1f) \\\\\n",
    robustness_results$placebo$manufacturing$att,
    mfg_stars,
    robustness_results$placebo$manufacturing$se
  ))
}

if (!is.null(robustness_results$placebo$agriculture)) {
  table7_latex <- paste0(table7_latex, sprintf(
    "Agriculture (NAICS 11) & %.1f & (%.1f) \\\\\n",
    robustness_results$placebo$agriculture$att,
    robustness_results$placebo$agriculture$se
  ))
}

gambling_t <- main_results$overall$att / main_results$overall$se
gambling_stars <- if_else(abs(gambling_t) > 2.576, "***", if_else(abs(gambling_t) > 1.96, "**", if_else(abs(gambling_t) > 1.645, "*", "")))
table7_latex <- paste0(table7_latex, sprintf(
  "\\midrule\nGambling (NAICS 7132, main) & %.1f%s & (%.1f) \\\\\n",
  main_results$overall$att, gambling_stars, main_results$overall$se
))

table7_latex <- paste0(table7_latex, "
\\bottomrule
\\end{tabular}
\\begin{tablenotes}
\\footnotesize
\\item \\textit{Notes:} Each row reports the Callaway-Sant'Anna ATT for the indicated industry. Manufacturing and agriculture serve as placebo outcomes that should not be affected by sports betting legalization. Standard errors clustered at state level. * p<0.10, ** p<0.05, *** p<0.01.
\\end{tablenotes}
\\end{table}
")

writeLines(table7_latex, file.path(tab_dir, "table7_placebo.tex"))
message("  Saved: table7_placebo.tex")

# -----------------------------------------------------------------------------
# Table 8: Wage Effects (NEW in v3)
# -----------------------------------------------------------------------------

message("Creating Table 8: Wage Effects...")

if (!is.na(main_results$wage$att)) {
  table8_latex <- sprintf("
\\begin{table}[htbp]
\\centering
\\caption{Effect of Sports Betting Legalization on Gambling Industry Wages}
\\label{tab:wages}
\\begin{tabular}{lcc}
\\toprule
& (1) & (2) \\\\
& CS (Not-Yet-Treated) & TWFE \\\\
\\midrule
\\multicolumn{3}{l}{\\textit{Panel A: Log(Average Weekly Wage)}} \\\\
Sports Betting Legal & %.4f & %.4f \\\\
& (%.4f) & (%.4f) \\\\
Implied \\%% change & %.1f\\%% & %.1f\\%% \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}
\\footnotesize
\\item \\textit{Notes:} Outcome is log of average weekly wage in NAICS 7132 (Gambling Industries) from BLS QCEW. Column (1) reports Callaway-Sant'Anna estimator; Column (2) reports TWFE for comparison. Standard errors clustered at state level. Implied percent change computed as $100 \\times \\hat{\\beta}$.
\\end{tablenotes}
\\end{table}
",
    main_results$wage$att, main_results$wage$twfe_att,
    main_results$wage$se, main_results$wage$twfe_se,
    100 * main_results$wage$att, 100 * main_results$wage$twfe_att
  )

  writeLines(table8_latex, file.path(tab_dir, "table8_wages.tex"))
  message("  Saved: table8_wages.tex")
} else {
  message("  No wage results available, skipping table")
}

# -----------------------------------------------------------------------------
# Table 9: Spillover Analysis (NEW in v3)
# -----------------------------------------------------------------------------

message("Creating Table 9: Spillover Analysis...")

if (!is.null(robustness_results$spillover$model)) {
  table9_latex <- sprintf("
\\begin{table}[htbp]
\\centering
\\caption{Spillover Effects: Neighbor Legalization and Employment}
\\label{tab:spillover}
\\begin{tabular}{lc}
\\toprule
& Gambling Employment \\\\
\\midrule
Own state legalization & %.1f \\\\
& (%.1f) \\\\
Neighbor exposure & %.1f \\\\
& (%.1f) \\\\
\\midrule
State FE & Yes \\\\
Year FE & Yes \\\\
Clustering & State \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}
\\footnotesize
\\item \\textit{Notes:} TWFE regression of gambling industry employment on own-state treatment indicator and neighbor exposure (share of bordering states with legal sports betting). Standard errors clustered at state level in parentheses.
\\end{tablenotes}
\\end{table}
",
    robustness_results$spillover$model$own_effect,
    robustness_results$spillover$model$own_se,
    robustness_results$spillover$model$neighbor_effect,
    robustness_results$spillover$model$neighbor_se
  )

  writeLines(table9_latex, file.path(tab_dir, "table9_spillover.tex"))
  message("  Saved: table9_spillover.tex")
} else {
  message("  No spillover results available, skipping table")
}

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------

message("\n", paste(rep("=", 60), collapse = ""))
message("All tables saved to: ", tab_dir)
message(paste(rep("=", 60), collapse = ""))

list.files(tab_dir, pattern = "\\.tex$")
