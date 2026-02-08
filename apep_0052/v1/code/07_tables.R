# ==============================================================================
# Paper 68: Broadband Internet and Moral Foundations in Local Governance
# 07_tables.R - Generate Publication-Ready Tables
# ==============================================================================

source("code/00_packages.R")

# ==============================================================================
# LOAD DATA
# ==============================================================================
cat("=== Loading Data for Tables ===\n")

analysis <- arrow::read_parquet("data/analysis_panel.parquet")
load("data/cs_results.RData")

# Main results
main_results <- read_csv("tables/main_results.csv", show_col_types = FALSE)

# ==============================================================================
# TABLE 1: SUMMARY STATISTICS
# ==============================================================================
cat("\n=== Table 1: Summary Statistics ===\n")

# Overall statistics
tab1_overall <- analysis %>%
  summarise(
    Variable = c("Broadband Rate", "Individualizing", "Binding",
                 "Care", "Fairness", "Loyalty", "Authority", "Sanctity",
                 "Meetings per Year", "Total Words (000s)",
                 "Population (000s)", "Median Income ($000s)",
                 "% College Educated", "% White", "Median Age"),
    Mean = c(mean(broadband_rate), mean(individualizing), mean(binding),
             mean(care_p), mean(fairness_p), mean(loyalty_p),
             mean(authority_p), mean(sanctity_p),
             mean(n_meetings), mean(n_total_words)/1000,
             mean(population, na.rm=T)/1000, mean(median_income, na.rm=T)/1000,
             mean(pct_college, na.rm=T), mean(pct_white, na.rm=T),
             mean(median_age, na.rm=T)),
    SD = c(sd(broadband_rate), sd(individualizing), sd(binding),
           sd(care_p), sd(fairness_p), sd(loyalty_p),
           sd(authority_p), sd(sanctity_p),
           sd(n_meetings), sd(n_total_words)/1000,
           sd(population, na.rm=T)/1000, sd(median_income, na.rm=T)/1000,
           sd(pct_college, na.rm=T), sd(pct_white, na.rm=T),
           sd(median_age, na.rm=T)),
    Min = c(min(broadband_rate), min(individualizing), min(binding),
            min(care_p), min(fairness_p), min(loyalty_p),
            min(authority_p), min(sanctity_p),
            min(n_meetings), min(n_total_words)/1000,
            min(population, na.rm=T)/1000, min(median_income, na.rm=T)/1000,
            min(pct_college, na.rm=T), min(pct_white, na.rm=T),
            min(median_age, na.rm=T)),
    Max = c(max(broadband_rate), max(individualizing), max(binding),
            max(care_p), max(fairness_p), max(loyalty_p),
            max(authority_p), max(sanctity_p),
            max(n_meetings), max(n_total_words)/1000,
            max(population, na.rm=T)/1000, max(median_income, na.rm=T)/1000,
            max(pct_college, na.rm=T), max(pct_white, na.rm=T),
            max(median_age, na.rm=T))
  )

# Format and add N
tab1_overall <- tab1_overall %>%
  mutate(
    Mean = round(Mean, 3),
    SD = round(SD, 3),
    Min = round(Min, 3),
    Max = round(Max, 3)
  )

write_csv(tab1_overall, "tables/tab1_summary_stats.csv")

# LaTeX table
tab1_latex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Summary Statistics}\n",
  "\\label{tab:summary}\n",
  "\\begin{tabular}{lcccc}\n",
  "\\toprule\n",
  "Variable & Mean & SD & Min & Max \\\\\n",
  "\\midrule\n",
  "\\multicolumn{5}{l}{\\textit{Panel A: Treatment and Outcomes}} \\\\\n"
)

for (i in 1:9) {
  tab1_latex <- paste0(tab1_latex,
                       sprintf("%s & %.3f & %.3f & %.3f & %.3f \\\\\n",
                               tab1_overall$Variable[i],
                               tab1_overall$Mean[i], tab1_overall$SD[i],
                               tab1_overall$Min[i], tab1_overall$Max[i]))
}

tab1_latex <- paste0(tab1_latex,
                     "\\midrule\n",
                     "\\multicolumn{5}{l}{\\textit{Panel B: Place Characteristics}} \\\\\n")

for (i in 10:15) {
  tab1_latex <- paste0(tab1_latex,
                       sprintf("%s & %.3f & %.3f & %.3f & %.3f \\\\\n",
                               tab1_overall$Variable[i],
                               tab1_overall$Mean[i], tab1_overall$SD[i],
                               tab1_overall$Min[i], tab1_overall$Max[i]))
}

tab1_latex <- paste0(tab1_latex,
                     "\\bottomrule\n",
                     "\\multicolumn{5}{l}{\\footnotesize Place-years: ",
                     format(nrow(analysis), big.mark = ","), "; Places: ",
                     format(n_distinct(analysis$st_fips), big.mark = ","),
                     "; Years: 2013--2022} \\\\\n",
                     "\\end{tabular}\n",
                     "\\end{table}\n")

writeLines(tab1_latex, "tables/tab1_summary_stats.tex")

# ==============================================================================
# TABLE 2: TREATMENT TIMING DISTRIBUTION
# ==============================================================================
cat("\n=== Table 2: Treatment Timing ===\n")

tab2 <- analysis %>%
  filter(treated) %>%
  group_by(`Treatment Year` = treat_year) %>%
  summarise(
    `Number of Places` = n_distinct(st_fips),
    `Cumulative Places` = NA,
    `Mean Broadband (Pre)` = mean(broadband_rate[year < treat_year], na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    `Cumulative Places` = cumsum(`Number of Places`),
    `% of Treated` = round(`Number of Places` / sum(`Number of Places`) * 100, 1),
    `Mean Broadband (Pre)` = round(`Mean Broadband (Pre)`, 3)
  )

# Add never-treated row
never_treated <- analysis %>%
  filter(!treated) %>%
  summarise(
    `Treatment Year` = NA,
    `Number of Places` = n_distinct(st_fips),
    `Cumulative Places` = NA,
    `Mean Broadband (Pre)` = mean(broadband_rate, na.rm = TRUE),
    `% of Treated` = NA
  )

tab2 <- bind_rows(tab2, never_treated)

write_csv(tab2, "tables/tab2_treatment_timing.csv")

# LaTeX
tab2_latex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Treatment Timing Distribution}\n",
  "\\label{tab:timing}\n",
  "\\begin{tabular}{lccc}\n",
  "\\toprule\n",
  "Treatment Year & Places & Cumulative & \\% of Treated \\\\\n",
  "\\midrule\n"
)

for (i in 1:(nrow(tab2)-1)) {
  tab2_latex <- paste0(tab2_latex,
                       sprintf("%d & %d & %d & %.1f\\%% \\\\\n",
                               tab2$`Treatment Year`[i],
                               tab2$`Number of Places`[i],
                               tab2$`Cumulative Places`[i],
                               tab2$`% of Treated`[i]))
}

tab2_latex <- paste0(tab2_latex,
                     "\\midrule\n",
                     sprintf("Never treated & %d & --- & --- \\\\\n",
                             tab2$`Number of Places`[nrow(tab2)]),
                     "\\bottomrule\n",
                     "\\multicolumn{4}{l}{\\footnotesize Treatment = crossing 70\\% broadband threshold} \\\\\n",
                     "\\end{tabular}\n",
                     "\\end{table}\n")

writeLines(tab2_latex, "tables/tab2_treatment_timing.tex")

# ==============================================================================
# TABLE 3: MAIN DID RESULTS
# ==============================================================================
cat("\n=== Table 3: Main DiD Results ===\n")

tab3 <- main_results %>%
  select(Outcome, ATT, SE) %>%
  mutate(
    `t-stat` = ATT / SE,
    `p-value` = 2 * (1 - pnorm(abs(`t-stat`))),
    Sig = case_when(
      `p-value` < 0.01 ~ "***",
      `p-value` < 0.05 ~ "**",
      `p-value` < 0.10 ~ "*",
      TRUE ~ ""
    ),
    `Estimate (SE)` = sprintf("%.4f%s\n(%.4f)", ATT, Sig, SE)
  )

write_csv(tab3, "tables/tab3_main_results.csv")

# LaTeX with fixest etable format
# Load models for etable
load("data/cs_results.RData")

# Create formatted table manually since CS objects don't work with etable
tab3_latex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Effect of Broadband on Moral Foundations: Main Results}\n",
  "\\label{tab:main}\n",
  "\\begin{tabular}{lcccc}\n",
  "\\toprule\n",
  " & (1) & (2) & (3) \\\\\n",
  " & Individualizing & Binding & Log Univ/Comm \\\\\n",
  "\\midrule\n",
  sprintf("ATT & %.4f%s & %.4f%s & %.4f%s \\\\\n",
          att_individual$overall.att,
          ifelse(2*(1-pnorm(abs(att_individual$overall.att/att_individual$overall.se))) < 0.1, "*", ""),
          att_binding$overall.att,
          ifelse(2*(1-pnorm(abs(att_binding$overall.att/att_binding$overall.se))) < 0.1, "*", ""),
          att_ratio$overall.att,
          ifelse(2*(1-pnorm(abs(att_ratio$overall.att/att_ratio$overall.se))) < 0.1, "*", "")),
  sprintf(" & (%.4f) & (%.4f) & (%.4f) \\\\\n",
          att_individual$overall.se, att_binding$overall.se, att_ratio$overall.se),
  "\\midrule\n",
  "Estimator & \\multicolumn{3}{c}{Callaway-Sant'Anna (2021)} \\\\\n",
  "Control group & \\multicolumn{3}{c}{Never treated} \\\\\n",
  "Place FE & \\multicolumn{3}{c}{Yes} \\\\\n",
  "Year FE & \\multicolumn{3}{c}{Yes} \\\\\n",
  sprintf("Places & \\multicolumn{3}{c}{%s} \\\\\n",
          format(n_distinct(analysis$st_fips), big.mark = ",")),
  sprintf("Place-years & \\multicolumn{3}{c}{%s} \\\\\n",
          format(nrow(analysis), big.mark = ",")),
  "\\bottomrule\n",
  "\\multicolumn{4}{l}{\\footnotesize Standard errors clustered at state level. * p<0.10, ** p<0.05, *** p<0.01} \\\\\n",
  "\\end{tabular}\n",
  "\\end{table}\n"
)

writeLines(tab3_latex, "tables/tab3_main_results.tex")

# ==============================================================================
# TABLE 4: INDIVIDUAL FOUNDATION RESULTS
# ==============================================================================
cat("\n=== Table 4: Individual Foundation Results ===\n")

foundations_tab <- main_results %>%
  filter(Outcome %in% c("Care", "Fairness", "Loyalty", "Authority", "Sanctity")) %>%
  mutate(
    Foundation = Outcome,
    Type = ifelse(Foundation %in% c("Care", "Fairness"),
                  "Individualizing", "Binding"),
    `Estimate (SE)` = sprintf("%.4f (%.4f)", ATT, SE)
  )

write_csv(foundations_tab, "tables/tab4_individual_foundations.csv")

# LaTeX
tab4_latex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Effects on Individual Moral Foundations}\n",
  "\\label{tab:foundations}\n",
  "\\begin{tabular}{llcc}\n",
  "\\toprule\n",
  "Foundation & Type & ATT & SE \\\\\n",
  "\\midrule\n"
)

for (i in 1:nrow(foundations_tab)) {
  tab4_latex <- paste0(tab4_latex,
                       sprintf("%s & %s & %.4f & (%.4f) \\\\\n",
                               foundations_tab$Foundation[i],
                               foundations_tab$Type[i],
                               foundations_tab$ATT[i],
                               foundations_tab$SE[i]))
}

tab4_latex <- paste0(tab4_latex,
                     "\\bottomrule\n",
                     "\\multicolumn{4}{l}{\\footnotesize Callaway-Sant'Anna estimator. SEs clustered at state.} \\\\\n",
                     "\\end{tabular}\n",
                     "\\end{table}\n")

writeLines(tab4_latex, "tables/tab4_individual_foundations.tex")

# ==============================================================================
# TABLE 5: BALANCE TABLE (Treated vs Never-Treated)
# ==============================================================================
cat("\n=== Table 5: Balance Table ===\n")

# Baseline year (2013)
baseline <- analysis %>%
  filter(year == 2013)

tab5 <- baseline %>%
  group_by(Treatment = ifelse(treated, "Treated", "Never Treated")) %>%
  summarise(
    `N Places` = n(),
    `Population (mean)` = mean(population, na.rm = TRUE),
    `Population (sd)` = sd(population, na.rm = TRUE),
    `Median Income (mean)` = mean(median_income, na.rm = TRUE),
    `% College (mean)` = mean(pct_college, na.rm = TRUE),
    `% White (mean)` = mean(pct_white, na.rm = TRUE),
    `Broadband Rate (mean)` = mean(broadband_rate, na.rm = TRUE),
    `Individualizing (mean)` = mean(individualizing, na.rm = TRUE),
    `Binding (mean)` = mean(binding, na.rm = TRUE),
    .groups = "drop"
  )

# Add difference test
balance_test <- function(var) {
  t.test(baseline[[var]][baseline$treated],
         baseline[[var]][!baseline$treated])$p.value
}

write_csv(tab5, "tables/tab5_balance.csv")

# ==============================================================================
# TABLE 6: ROBUSTNESS CHECKS
# ==============================================================================
cat("\n=== Table 6: Robustness Summary ===\n")

robustness <- read_csv("tables/robustness_summary.csv", show_col_types = FALSE)

tab6_latex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Robustness Checks: Effect on Individualizing Foundations}\n",
  "\\label{tab:robust}\n",
  "\\begin{tabular}{lcc}\n",
  "\\toprule\n",
  "Specification & ATT & SE \\\\\n",
  "\\midrule\n",
  "\\multicolumn{3}{l}{\\textit{Main specification}} \\\\\n",
  sprintf("Threshold: 70\\%% & %.4f & (%.4f) \\\\\n",
          att_individual$overall.att, att_individual$overall.se),
  "\\midrule\n",
  "\\multicolumn{3}{l}{\\textit{Alternative thresholds}} \\\\\n"
)

for (i in 1:nrow(robustness)) {
  tab6_latex <- paste0(tab6_latex,
                       sprintf("%s & %.4f & (%.4f) \\\\\n",
                               robustness$check[i],
                               robustness$att[i],
                               robustness$se[i]))
}

tab6_latex <- paste0(tab6_latex,
                     "\\bottomrule\n",
                     "\\end{tabular}\n",
                     "\\end{table}\n")

writeLines(tab6_latex, "tables/tab6_robustness.tex")

# ==============================================================================
# SUMMARY
# ==============================================================================
cat("\n=== Tables Generated ===\n")
cat("  tab1_summary_stats.tex - Summary statistics\n")
cat("  tab2_treatment_timing.tex - Treatment timing\n")
cat("  tab3_main_results.tex - Main DiD results\n")
cat("  tab4_individual_foundations.tex - Individual foundations\n")
cat("  tab5_balance.csv - Balance table\n")
cat("  tab6_robustness.tex - Robustness checks\n")
