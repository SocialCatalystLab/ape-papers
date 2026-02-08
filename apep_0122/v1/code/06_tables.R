# 06_tables.R — Generate all LaTeX tables
# Paper 113: RPS and Electricity Sector Employment

source("00_packages.R")

panel <- readRDS("../data/panel.rds")

cat("=== Generating Tables ===\n\n")

# ==============================================================================
# Table 1: Summary Statistics
# ==============================================================================

cat("Table 1: Summary statistics...\n")

# Panel A: Full sample
full_stats <- panel %>%
  summarise(
    n = n(),
    n_states = n_distinct(state_fips),
    years = paste(min(year), max(year), sep = "-"),
    mean_elec_rate = mean(elec_emp_rate, na.rm = TRUE),
    sd_elec_rate = sd(elec_emp_rate, na.rm = TRUE),
    mean_util_rate = mean(util_emp_rate, na.rm = TRUE),
    sd_util_rate = sd(util_emp_rate, na.rm = TRUE),
    mean_total_rate = mean(total_emp_rate, na.rm = TRUE),
    sd_total_rate = sd(total_emp_rate, na.rm = TRUE),
    mean_elec_wages = mean(elec_avg_wages, na.rm = TRUE),
    sd_elec_wages = sd(elec_avg_wages, na.rm = TRUE)
  )

# By RPS status
by_rps <- panel %>%
  group_by(ever_treated) %>%
  summarise(
    n = n(),
    n_states = n_distinct(state_fips),
    mean_elec_rate = mean(elec_emp_rate, na.rm = TRUE),
    sd_elec_rate = sd(elec_emp_rate, na.rm = TRUE),
    mean_util_rate = mean(util_emp_rate, na.rm = TRUE),
    sd_util_rate = sd(util_emp_rate, na.rm = TRUE),
    mean_total_rate = mean(total_emp_rate, na.rm = TRUE),
    sd_total_rate = sd(total_emp_rate, na.rm = TRUE),
    mean_elec_wages = mean(elec_avg_wages, na.rm = TRUE),
    sd_elec_wages = sd(elec_avg_wages, na.rm = TRUE),
    .groups = "drop"
  )

# LaTeX table
latex_summary <- sprintf("
\\begin{table}[htbp]
\\centering
\\caption{Summary Statistics}
\\label{tab:summary}
\\begin{tabular}{lccc}
\\toprule
& \\multicolumn{1}{c}{Full Sample} & \\multicolumn{1}{c}{RPS States} & \\multicolumn{1}{c}{Non-RPS States} \\\\
\\midrule
\\multicolumn{4}{l}{\\textit{Panel A: Employment Rates (per 1,000 working-age population)}} \\\\[3pt]
Electricity sector & %.3f & %.3f & %.3f \\\\
& (%.3f) & (%.3f) & (%.3f) \\\\[3pt]
All utilities & %.3f & %.3f & %.3f \\\\
& (%.3f) & (%.3f) & (%.3f) \\\\[3pt]
Total employment & %.1f & %.1f & %.1f \\\\
& (%.1f) & (%.1f) & (%.1f) \\\\[3pt]
\\multicolumn{4}{l}{\\textit{Panel B: Wages}} \\\\[3pt]
Avg. electricity wages (\\$) & %s & %s & %s \\\\
& (%s) & (%s) & (%s) \\\\[6pt]
\\midrule
State-year observations & %d & %d & %d \\\\
Number of states & %d & %d & %d \\\\
Years & \\multicolumn{3}{c}{%s} \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\footnotesize
\\item \\textit{Notes:} Standard deviations in parentheses. Employment rates are employees per 1,000 working-age population (ages 16--64). Electricity sector corresponds to NAICS code 0570 (electric power generation, transmission, and distribution). Data from ACS 1-Year PUMS, 2005--2023. RPS states defined as those with a binding Renewable Portfolio Standard compliance obligation during the sample period.
\\end{tablenotes}
\\end{table}
",
  full_stats$mean_elec_rate, by_rps$mean_elec_rate[2], by_rps$mean_elec_rate[1],
  full_stats$sd_elec_rate, by_rps$sd_elec_rate[2], by_rps$sd_elec_rate[1],
  full_stats$mean_util_rate, by_rps$mean_util_rate[2], by_rps$mean_util_rate[1],
  full_stats$sd_util_rate, by_rps$sd_util_rate[2], by_rps$sd_util_rate[1],
  full_stats$mean_total_rate, by_rps$mean_total_rate[2], by_rps$mean_total_rate[1],
  full_stats$sd_total_rate, by_rps$sd_total_rate[2], by_rps$sd_total_rate[1],
  format(round(full_stats$mean_elec_wages), big.mark = ","),
  format(round(by_rps$mean_elec_wages[2]), big.mark = ","),
  format(round(by_rps$mean_elec_wages[1]), big.mark = ","),
  format(round(full_stats$sd_elec_wages), big.mark = ","),
  format(round(by_rps$sd_elec_wages[2]), big.mark = ","),
  format(round(by_rps$sd_elec_wages[1]), big.mark = ","),
  nrow(panel), sum(panel$ever_treated), sum(!panel$ever_treated),
  full_stats$n_states, by_rps$n_states[2], by_rps$n_states[1],
  full_stats$years
)

writeLines(latex_summary, "../tables/tab1_summary.tex")
cat("  Saved: tab1_summary.tex\n")

# ==============================================================================
# Table 2: Main Results
# ==============================================================================

cat("Table 2: Main results...\n")

main_results <- readRDS("../data/main_results.rds")

twfe_result <- readRDS("../data/twfe_result.rds")
sa_result <- readRDS("../data/sa_result.rds")

# Create main results table using fixest etable
tryCatch({
  # Region FE model
  region_fe <- readRDS("../data/region_fe_result.rds")

  etable(twfe_result, sa_result, region_fe,
         file = "../tables/tab2_main_results.tex",
         title = "Effect of RPS on Electricity Sector Employment",
         headers = c("TWFE", "Sun-Abraham", "Region$\\times$Year FE"),
         label = "tab:main",
         notes = "Standard errors clustered at the state level in parentheses. The dependent variable is electricity sector employment per 1,000 working-age population. Treatment is defined as the first year of binding RPS compliance. Column (1) reports standard two-way fixed effects estimates; columns (2)--(3) use heterogeneity-robust estimators. All specifications include state and year fixed effects.",
         fitstat = ~ n + r2 + r2.within,
         se.below = TRUE,
         drop = "Intercept",
         signif.code = c("***" = 0.01, "**" = 0.05, "*" = 0.10))

  cat("  Saved: tab2_main_results.tex\n")
}, error = function(e) {
  cat(sprintf("  Table 2 error: %s\n", e$message))
  # Fallback: manual table
  cat("  Creating manual LaTeX table...\n")

  latex_main <- sprintf("
\\begin{table}[htbp]
\\centering
\\caption{Effect of RPS on Electricity Sector Employment}
\\label{tab:main}
\\begin{tabular}{lccc}
\\toprule
& (1) & (2) & (3) \\\\
& TWFE & CS-DiD & CS-DiD \\\\
& & (Not-yet-treated) & (Never-treated) \\\\
\\midrule
RPS Treatment & %.4f%s & %.4f%s & %.4f%s \\\\
& (%.4f) & (%.4f) & (%.4f) \\\\
& [%.4f] & [%.4f] & [%.4f] \\\\[6pt]
\\midrule
State FE & Yes & --- & --- \\\\
Year FE & Yes & --- & --- \\\\
Estimator & TWFE & CS-DiD (DR) & CS-DiD (DR) \\\\
Control group & --- & Not-yet-treated & Never-treated \\\\
Observations & %d & %d & %d \\\\
\\# Treated states & %d & %d & %d \\\\
\\# Clusters & %d & %d & %d \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\footnotesize
\\item \\textit{Notes:} Standard errors in parentheses. 95\\%% confidence intervals in brackets. *** p$<$0.01, ** p$<$0.05, * p$<$0.10. The dependent variable is electricity sector employment per 1,000 working-age population. Treatment is defined as the first year of binding RPS compliance. Column (1) reports standard two-way fixed effects; columns (2)--(3) use the Callaway-Sant'Anna (2021) doubly-robust estimator with different control groups.
\\end{tablenotes}
\\end{table}
",
    main_results$att[4], main_results$sig[4],
    main_results$att[1], main_results$sig[1],
    main_results$att[2], main_results$sig[2],
    main_results$se[4], main_results$se[1], main_results$se[2],
    main_results$ci_lower[4], main_results$ci_lower[1], main_results$ci_lower[2],
    nrow(panel), nrow(panel), nrow(panel),
    sum(panel$ever_treated[!duplicated(panel$state_fips)]),
    sum(panel$ever_treated[!duplicated(panel$state_fips)]),
    sum(panel$ever_treated[!duplicated(panel$state_fips)]),
    n_distinct(panel$state_fips), n_distinct(panel$state_fips), n_distinct(panel$state_fips)
  )
  writeLines(latex_main, "../tables/tab2_main_results.tex")
  cat("  Saved: tab2_main_results.tex\n")
})

# ==============================================================================
# Table 3: Robustness Checks
# ==============================================================================

cat("Table 3: Robustness...\n")

robustness <- readRDS("../data/robustness_summary.rds")

latex_robust <- "
\\begin{table}[htbp]
\\centering
\\caption{Robustness Checks}
\\label{tab:robustness}
\\begin{tabular}{lcccc}
\\toprule
Specification & ATT & SE & p-value & Sig. \\\\
\\midrule
"

for (i in 1:nrow(robustness)) {
  latex_robust <- paste0(latex_robust,
    sprintf("%s & %.4f & (%.4f) & %.3f & %s \\\\\n",
            robustness$check[i], robustness$att[i],
            robustness$se[i], robustness$pvalue[i], robustness$sig[i]))
}

latex_robust <- paste0(latex_robust, "
\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\footnotesize
\\item \\textit{Notes:} All specifications use the Callaway-Sant'Anna (2021) estimator with doubly-robust estimation unless otherwise noted. Standard errors in parentheses. *** p$<$0.01, ** p$<$0.05, * p$<$0.10. The placebo outcomes (manufacturing and total employment) should show null effects if RPS specifically affects the electricity sector.
\\end{tablenotes}
\\end{table}
")

writeLines(latex_robust, "../tables/tab3_robustness.tex")
cat("  Saved: tab3_robustness.tex\n")

# ==============================================================================
# Table 4: Event Study Coefficients
# ==============================================================================

cat("Table 4: Event study coefficients...\n")

es_df <- readRDS("../data/event_study_cs.rds")

latex_es <- "
\\begin{table}[htbp]
\\centering
\\caption{Event Study Coefficients: Callaway-Sant'Anna Estimates}
\\label{tab:event_study}
\\begin{tabular}{lccc}
\\toprule
Event Time & ATT & SE & 95\\% CI \\\\
\\midrule
"

for (i in 1:nrow(es_df)) {
  latex_es <- paste0(latex_es,
    sprintf("$\\tau = %+d$ & %.4f & (%.4f) & [%.4f, %.4f] \\\\\n",
            es_df$event_time[i], es_df$estimate[i],
            es_df$se[i], es_df$ci_lower[i], es_df$ci_upper[i]))
}

latex_es <- paste0(latex_es, "
\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\footnotesize
\\item \\textit{Notes:} Callaway-Sant'Anna (2021) group-time ATT estimates aggregated to event time. Doubly-robust estimation with not-yet-treated comparison group. Standard errors computed via multiplier bootstrap (1,000 iterations). $\\tau = 0$ is the first year of binding RPS compliance.
\\end{tablenotes}
\\end{table}
")

writeLines(latex_es, "../tables/tab4_event_study.tex")
cat("  Saved: tab4_event_study.tex\n")

cat("\n=== All tables generated ===\n")
