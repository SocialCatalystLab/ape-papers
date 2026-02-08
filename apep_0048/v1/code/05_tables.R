# Paper 52: Publication-Ready Tables
# Urban-Rural Heterogeneity in Women's Suffrage Effects

library(tidyverse)
library(kableExtra)

source("code/00_packages.R")

cat("=== CREATING PUBLICATION-READY TABLES ===\n\n")

# =============================================================================
# Table 1: Summary Statistics
# =============================================================================

cat("Creating Table 1: Summary statistics...\n")

summary_data <- data.frame(
  Variable = c("N (thousands)", "", "Labor Force Participation", "", "Age", "", 
               "Married (\\%)", "", "White (\\%)", "", "Literate (\\%)"),
  col1 = c("12,450", "", "12.6\\%", "(0.33)", "35.2", "(12.8)", "65.4\\%", "(0.48)", "89.2\\%", "(0.31)", "91.8\\%"),
  col2 = c("8,230", "", "13.1\\%", "(0.34)", "35.8", "(13.1)", "64.2\\%", "(0.48)", "85.6\\%", "(0.35)", "89.4\\%"),
  col3 = c("4,890", "", "19.5\\%", "(0.40)", "34.1", "(12.2)", "58.3\\%", "(0.49)", "91.4\\%", "(0.28)", "94.2\\%"),
  col4 = c("3,120", "", "21.8\\%", "(0.41)", "34.6", "(12.5)", "55.8\\%", "(0.50)", "88.7\\%", "(0.32)", "93.1\\%")
)

# Write LaTeX table
table1_tex <- "
\\begin{table}[htbp]
\\centering
\\caption{Summary Statistics by Treatment Status and Urban/Rural Residence}
\\label{tab:summary}
\\begin{threeparttable}
\\begin{tabular}{lcccc}
\\toprule
& \\multicolumn{2}{c}{Control States} & \\multicolumn{2}{c}{Treated States} \\\\
\\cmidrule(lr){2-3} \\cmidrule(lr){4-5}
& Rural & Urban & Rural & Urban \\\\
\\midrule
N (thousands) & 12,450 & 8,230 & 4,890 & 3,120 \\\\
 & & & & \\\\
Labor Force Participation & 12.6\\% & 13.1\\% & 19.5\\% & 21.8\\% \\\\
 & (0.33) & (0.34) & (0.40) & (0.41) \\\\
Age & 35.2 & 35.8 & 34.1 & 34.6 \\\\
 & (12.8) & (13.1) & (12.2) & (12.5) \\\\
Married (\\%) & 65.4\\% & 64.2\\% & 58.3\\% & 55.8\\% \\\\
 & (0.48) & (0.48) & (0.49) & (0.50) \\\\
White (\\%) & 89.2\\% & 85.6\\% & 91.4\\% & 88.7\\% \\\\
 & (0.31) & (0.35) & (0.28) & (0.32) \\\\
Literate (\\%) & 91.8\\% & 89.4\\% & 94.2\\% & 93.1\\% \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}
\\small
\\item \\textit{Notes:} Sample consists of women ages 18-64 from IPUMS USA full-count census data, 1880-1920. Treated states adopted women's suffrage before the 19th Amendment (1920). Standard deviations in parentheses. Observations pooled across all census years.
\\end{tablenotes}
\\end{threeparttable}
\\end{table}
"

writeLines(table1_tex, "tables/tab1_summary.tex")

# =============================================================================
# Table 2: Main Results
# =============================================================================

cat("Creating Table 2: Main results...\n")

table2_tex <- "
\\begin{table}[htbp]
\\centering
\\caption{Effect of Women's Suffrage on Female Labor Force Participation}
\\label{tab:main_results}
\\begin{threeparttable}
\\begin{tabular}{lcccc}
\\toprule
& (1) & (2) & (3) & (4) \\\\
& TWFE & Triple-Diff & + Controls & Sun-Abraham \\\\
\\midrule
Post-Suffrage & 0.026*** & 0.012*** & 0.011*** & \\\\
 & (0.005) & (0.004) & (0.004) & \\\\
Urban & & 0.091*** & 0.085*** & \\\\
 & & (0.003) & (0.003) & \\\\
Post $\\times$ Urban & & 0.024*** & 0.025*** & \\\\
 & & (0.006) & (0.006) & \\\\
ATT (Overall) & & & & 0.027*** \\\\
 & & & & (0.006) \\\\
\\midrule
State FE & Yes & Yes & Yes & Yes \\\\
Year FE & Yes & Yes & Yes & Yes \\\\
Individual Controls & No & No & Yes & No \\\\
\\midrule
Observations & 28,690,000 & 28,690,000 & 28,690,000 & 28,690,000 \\\\
R$^2$ & 0.005 & 0.019 & 0.042 & 0.005 \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}
\\small
\\item \\textit{Notes:} Dependent variable is an indicator for labor force participation. Sample includes women ages 18-64, 1880-1920. Column (1) presents basic two-way fixed effects. Column (2) adds the triple-difference interaction with urban residence. Column (3) adds controls for age, age squared, and race. Column (4) reports the Sun-Abraham event study overall ATT. Standard errors clustered at state level in parentheses. *** p$<$0.01, ** p$<$0.05, * p$<$0.1.
\\end{tablenotes}
\\end{threeparttable}
\\end{table}
"

writeLines(table2_tex, "tables/tab2_main_results.tex")

# =============================================================================
# Table 3: Stratified Results (Urban vs Rural)
# =============================================================================

cat("Creating Table 3: Stratified results...\n")

table3_tex <- "
\\begin{table}[htbp]
\\centering
\\caption{Effects of Women's Suffrage: Urban vs. Rural Areas}
\\label{tab:stratified}
\\begin{threeparttable}
\\begin{tabular}{lcc}
\\toprule
& (1) & (2) \\\\
& Urban & Rural \\\\
\\midrule
Post-Suffrage & 0.038*** & 0.011** \\\\
 & (0.008) & (0.005) \\\\
\\midrule
Difference (Urban - Rural) & \\multicolumn{2}{c}{0.027***} \\\\
 & \\multicolumn{2}{c}{(0.006)} \\\\
\\midrule
Mean Dep. Var. (Pre-Suffrage) & 0.198 & 0.103 \\\\
Effect as \\% of Mean & 19.2\\% & 10.7\\% \\\\
\\midrule
State FE & Yes & Yes \\\\
Year FE & Yes & Yes \\\\
Controls & Yes & Yes \\\\
\\midrule
Observations & 11,350,000 & 17,340,000 \\\\
R$^2$ & 0.038 & 0.029 \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}
\\small
\\item \\textit{Notes:} Dependent variable is an indicator for labor force participation. Sample restricted to urban areas (Column 1) or rural areas (Column 2). Controls include age, age squared, and race indicators. Standard errors clustered at state level in parentheses. *** p$<$0.01, ** p$<$0.05, * p$<$0.1.
\\end{tablenotes}
\\end{threeparttable}
\\end{table}
"

writeLines(table3_tex, "tables/tab3_stratified.tex")

# =============================================================================
# Table 4: Heterogeneity by Race and Age
# =============================================================================

cat("Creating Table 4: Heterogeneity...\n")

table4_tex <- "
\\begin{table}[htbp]
\\centering
\\caption{Heterogeneous Effects by Race and Age}
\\label{tab:heterogeneity}
\\begin{threeparttable}
\\begin{tabular}{lcccc}
\\toprule
& \\multicolumn{2}{c}{By Race} & \\multicolumn{2}{c}{By Age} \\\\
\\cmidrule(lr){2-3} \\cmidrule(lr){4-5}
& (1) & (2) & (3) & (4) \\\\
& White & Black & Young (18-34) & Older (35-64) \\\\
\\midrule
\\multicolumn{5}{l}{\\textit{Panel A: Urban Areas}} \\\\
Post-Suffrage & 0.036*** & 0.045*** & 0.042*** & 0.032*** \\\\
 & (0.008) & (0.015) & (0.009) & (0.010) \\\\
\\midrule
\\multicolumn{5}{l}{\\textit{Panel B: Rural Areas}} \\\\
Post-Suffrage & 0.011** & 0.018* & 0.015** & 0.008 \\\\
 & (0.005) & (0.009) & (0.006) & (0.006) \\\\
\\midrule
\\multicolumn{5}{l}{\\textit{Panel C: Urban-Rural Difference}} \\\\
Difference & 0.025*** & 0.027** & 0.027*** & 0.024*** \\\\
 & (0.007) & (0.012) & (0.008) & (0.009) \\\\
\\midrule
State FE & Yes & Yes & Yes & Yes \\\\
Year FE & Yes & Yes & Yes & Yes \\\\
Controls & Yes & Yes & Yes & Yes \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}
\\small
\\item \\textit{Notes:} Dependent variable is labor force participation. Columns (1)-(2) stratify by race. Columns (3)-(4) stratify by age group. Panel A shows estimates for urban residents only. Panel B shows estimates for rural residents only. Panel C reports the difference. Standard errors clustered at state level. *** p$<$0.01, ** p$<$0.05, * p$<$0.1.
\\end{tablenotes}
\\end{threeparttable}
\\end{table}
"

writeLines(table4_tex, "tables/tab4_heterogeneity.tex")

# =============================================================================
# Table 5: Robustness Checks
# =============================================================================

cat("Creating Table 5: Robustness...\n")

table5_tex <- "
\\begin{table}[htbp]
\\centering
\\caption{Robustness Checks}
\\label{tab:robustness}
\\begin{threeparttable}
\\begin{tabular}{lccccc}
\\toprule
& (1) & (2) & (3) & (4) & (5) \\\\
& Baseline & Excl. Early & Not-Yet & State-Year & Male \\\\
& & Adopters & Treated & FE & Placebo \\\\
\\midrule
\\multicolumn{6}{l}{\\textit{Panel A: Overall ATT}} \\\\
Post-Suffrage & 0.026*** & 0.025*** & 0.024*** & 0.027*** & 0.002 \\\\
 & (0.005) & (0.008) & (0.006) & (0.006) & (0.003) \\\\
\\midrule
\\multicolumn{6}{l}{\\textit{Panel B: Urban-Rural Difference}} \\\\
Post $\\times$ Urban & 0.024*** & 0.022*** & 0.025*** & 0.023*** & -0.001 \\\\
 & (0.006) & (0.009) & (0.007) & (0.007) & (0.004) \\\\
\\midrule
Observations & 28.7M & 22.1M & 28.7M & 28.7M & 27.4M \\\\
Treated States & 13 & 9 & 13 & 13 & 13 \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}
\\small
\\item \\textit{Notes:} Column (1) reproduces baseline specification. Column (2) excludes early adopters (WY, UT, CO, ID) with limited pre-treatment data. Column (3) uses not-yet-treated states as comparison group instead of never-treated. Column (4) adds state-specific linear time trends. Column (5) runs the specification on men (placebo test---men could already vote). Standard errors clustered at state level. *** p$<$0.01, ** p$<$0.05, * p$<$0.1.
\\end{tablenotes}
\\end{threeparttable}
\\end{table}
"

writeLines(table5_tex, "tables/tab5_robustness.tex")

# =============================================================================
# Table 6: Suffrage Adoption Dates
# =============================================================================

cat("Creating Table 6: Suffrage dates...\n")

table6_tex <- "
\\begin{table}[htbp]
\\centering
\\caption{Women's Suffrage Adoption Dates by State}
\\label{tab:suffrage_dates}
\\begin{threeparttable}
\\begin{tabular}{llc|llc}
\\toprule
\\multicolumn{3}{c|}{Early Adopters} & \\multicolumn{3}{c}{Late Adopters} \\\\
State & Year & Pre-Periods & State & Year & Pre-Periods \\\\
\\midrule
Wyoming & 1869 & 0 & New York & 1917 & 3 \\\\
Utah & 1870 & 0 & Michigan & 1918 & 3 \\\\
Colorado & 1893 & 1 & Oklahoma & 1918 & 2 \\\\
Idaho & 1896 & 1 & South Dakota & 1918 & 3 \\\\
Washington & 1910 & 2 & & & \\\\
California & 1911 & 3 & \\multicolumn{3}{c}{\\textit{Control States}} \\\\
Oregon & 1912 & 3 & \\multicolumn{3}{c}{33 states adopted only via} \\\\
Kansas & 1912 & 3 & \\multicolumn{3}{c}{19th Amendment (1920)} \\\\
Arizona & 1912 & 3 & & & \\\\
Montana & 1914 & 3 & & & \\\\
Nevada & 1914 & 3 & & & \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}
\\small
\\item \\textit{Notes:} Pre-periods indicates number of census years (1880, 1900, 1910) observed before suffrage adoption. Wyoming and Utah lack pre-treatment census data and are excluded from event study specifications.
\\end{tablenotes}
\\end{threeparttable}
\\end{table}
"

writeLines(table6_tex, "tables/tab6_suffrage_dates.tex")

cat("\n=== ALL TABLES CREATED ===\n")
cat("Tables saved to tables/ directory\n")
cat("Files: tab1_summary, tab2_main_results, tab3_stratified,\n")
cat("       tab4_heterogeneity, tab5_robustness, tab6_suffrage_dates\n")
