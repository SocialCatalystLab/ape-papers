# ============================================================================
# 07_tables.R
# Salary Transparency Laws and the Gender Wage Gap
# All Table Generation (LaTeX)
# ============================================================================

source("code/00_packages.R")

# Load data and results
df <- readRDS("data/cps_analysis.rds")
state_year <- readRDS("data/state_year_panel.rds")
transparency_laws <- readRDS("data/transparency_laws.rds")
results <- readRDS("data/main_results.rds")
robustness <- readRDS("data/robustness_results.rds")
desc_stats <- readRDS("data/descriptive_stats.rds")
es_data <- readRDS("data/event_study_data.rds")

cat("Loaded all data and results.\n")

# ============================================================================
# Set Variable Labels for fixest
# ============================================================================

setFixest_dict(c(
  treat_post = "Treated $\\times$ Post",
  `treat_post:female` = "Treated $\\times$ Post $\\times$ Female",
  `treat_post:high_bargaining` = "Treated $\\times$ Post $\\times$ High Bargaining",
  female = "Female",
  high_bargaining = "High-Bargaining Occupation",
  log_hourly_wage = "Log Hourly Wage",
  y = "Log Mean Wage"
))

# ============================================================================
# Table 1: Summary Statistics
# ============================================================================

cat("\nCreating Table 1: Summary Statistics...\n")

# Prepare summary statistics by treatment status (pre-treatment only)
sum_stats <- df %>%
  filter(income_year < 2021) %>%
  group_by(ever_treated) %>%
  summarize(
    `Hourly Wage` = sprintf("%.2f", mean(hourly_wage)),
    `SD Wage` = sprintf("%.2f", sd(hourly_wage)),
    `Female (\\%%)` = sprintf("%.1f", mean(female) * 100),
    `Age` = sprintf("%.1f", mean(AGE)),
    `College+ (\\%%)` = sprintf("%.1f", mean(educ_cat %in% c("BA or higher", "Graduate degree")) * 100),
    `Full-time (\\%%)` = sprintf("%.1f", mean(fulltime) * 100),
    `High-bargaining (\\%%)` = sprintf("%.1f", mean(high_bargaining) * 100),
    `N` = format(n(), big.mark = ","),
    .groups = "drop"
  )

# Create LaTeX table
table1_latex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Summary Statistics: Pre-Treatment Period (2014-2020)}\n",
  "\\label{tab:summary_stats}\n",
  "\\begin{tabular}{lcc}\n",
  "\\toprule\n",
  " & Treated States & Control States \\\\\n",
  "\\midrule\n",
  "Hourly Wage (\\$) & ", sum_stats$`Hourly Wage`[2], " & ", sum_stats$`Hourly Wage`[1], " \\\\\n",
  "\\quad (SD) & (", sum_stats$`SD Wage`[2], ") & (", sum_stats$`SD Wage`[1], ") \\\\\n",
  "Female (\\%) & ", sum_stats$`Female (\\%%)`[2], " & ", sum_stats$`Female (\\%%)`[1], " \\\\\n",
  "Age (years) & ", sum_stats$Age[2], " & ", sum_stats$Age[1], " \\\\\n",
  "College+ (\\%) & ", sum_stats$`College+ (\\%%)`[2], " & ", sum_stats$`College+ (\\%%)`[1], " \\\\\n",
  "Full-time (\\%) & ", sum_stats$`Full-time (\\%%)`[2], " & ", sum_stats$`Full-time (\\%%)`[1], " \\\\\n",
  "High-bargaining Occ. (\\%) & ", sum_stats$`High-bargaining (\\%%)`[2], " & ", sum_stats$`High-bargaining (\\%%)`[1], " \\\\\n",
  "\\midrule\n",
  "N & ", sum_stats$N[2], " & ", sum_stats$N[1], " \\\\\n",
  "States & ", sum(transparency_laws$statefip > 0), " & ", 51 - sum(transparency_laws$statefip > 0), " \\\\\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{minipage}{0.9\\textwidth}\n",
  "\\footnotesize\n",
  "\\textit{Notes:} Sample restricted to wage/salary workers ages 25-64 in the CPS ASEC, pre-treatment period (income years 2014-2020). Treated states are those that enacted salary transparency laws by 2024. High-bargaining occupations include management, business/financial, computer/math, architecture/engineering, legal, and healthcare practitioner occupations.\n",
  "\\end{minipage}\n",
  "\\end{table}\n"
)

writeLines(table1_latex, "tables/table1_summary_stats.tex")
cat("Saved tables/table1_summary_stats.tex\n")

# ============================================================================
# Table 2: Main DiD Results
# ============================================================================

cat("\nCreating Table 2: Main Results...\n")

# Run specifications for table
# (1) Simple TWFE
m1 <- feols(y ~ treat_post | statefip + income_year, data = state_year, cluster = ~statefip)

# (2) C-S Simple ATT
# Extract from results
cs_att <- results$att_simple$overall.att
cs_se <- results$att_simple$overall.se

# (3) Individual-level with basic FE
m3 <- feols(log_hourly_wage ~ treat_post | statefip + income_year,
            data = df, weights = ~ASECWT, cluster = ~statefip)

# (4) Individual-level with rich FE
m4 <- feols(log_hourly_wage ~ treat_post | statefip + income_year + occ_major + ind_major,
            data = df, weights = ~ASECWT, cluster = ~statefip)

# (5) Individual-level with demographics
m5 <- feols(log_hourly_wage ~ treat_post | statefip + income_year + occ_major + ind_major + educ_cat + age_group,
            data = df, weights = ~ASECWT, cluster = ~statefip)

# Export table
etable(m1, m3, m4, m5,
       tex = TRUE,
       style.tex = style.tex("aer"),
       fitstat = ~ r2 + n,
       title = "Effect of Salary Transparency Laws on Log Wages",
       label = "tab:main_results",
       dict = c(treat_post = "Treated $\\times$ Post"),
       notes = paste0(
         "Notes: Standard errors clustered at the state level in parentheses. ",
         "Column (1) uses state-year aggregates; Columns (2)-(4) use individual-level CPS ASEC data with survey weights. ",
         "The outcome is log hourly wage. ",
         "Sample: wage/salary workers ages 25-64, income years 2014-2023. ",
         "* p $<$ 0.10, ** p $<$ 0.05, *** p $<$ 0.01."
       ),
       file = "tables/table2_main_results.tex")

cat("Saved tables/table2_main_results.tex\n")

# ============================================================================
# Table 3: Gender Gap Results (DDD)
# ============================================================================

cat("\nCreating Table 3: Gender Gap Results...\n")

# Run DDD specifications
# (1) Basic DDD
d1 <- feols(log_hourly_wage ~ treat_post * female | statefip + income_year,
            data = df, weights = ~ASECWT, cluster = ~statefip)

# (2) With occupation FE
d2 <- feols(log_hourly_wage ~ treat_post * female | statefip + income_year + occ_major,
            data = df, weights = ~ASECWT, cluster = ~statefip)

# (3) With full controls
d3 <- feols(log_hourly_wage ~ treat_post * female | statefip + income_year + occ_major + ind_major + educ_cat + age_group,
            data = df, weights = ~ASECWT, cluster = ~statefip)

# (4) State-by-year FE
d4 <- feols(log_hourly_wage ~ treat_post * female | statefip^income_year + occ_major + educ_cat,
            data = df, weights = ~ASECWT, cluster = ~statefip)

etable(d1, d2, d3, d4,
       tex = TRUE,
       style.tex = style.tex("aer"),
       fitstat = ~ r2 + n,
       title = "Triple-Difference: Effect on Gender Wage Gap",
       label = "tab:gender_gap",
       keep = c("treat_post", "treat_post:female"),
       dict = c(
         treat_post = "Treated $\\times$ Post",
         `treat_post:female` = "Treated $\\times$ Post $\\times$ Female"
       ),
       notes = paste0(
         "Notes: Standard errors clustered at the state level in parentheses. ",
         "Sample: wage/salary workers ages 25-64, income years 2014-2023. ",
         "The coefficient on Treated $\\times$ Post represents the effect on male wages. ",
         "The coefficient on Treated $\\times$ Post $\\times$ Female represents the additional effect for women; ",
         "a positive coefficient indicates the gender gap narrows. ",
         "* p $<$ 0.10, ** p $<$ 0.05, *** p $<$ 0.01."
       ),
       file = "tables/table3_gender_gap.tex")

cat("Saved tables/table3_gender_gap.tex\n")

# ============================================================================
# Table 4: Heterogeneity by Bargaining Intensity
# ============================================================================

cat("\nCreating Table 4: Bargaining Heterogeneity...\n")

# (1) Basic interaction
b1 <- feols(log_hourly_wage ~ treat_post * high_bargaining | statefip + income_year,
            data = df, weights = ~ASECWT, cluster = ~statefip)

# (2) With controls
b2 <- feols(log_hourly_wage ~ treat_post * high_bargaining | statefip + income_year + female + educ_cat + age_group,
            data = df, weights = ~ASECWT, cluster = ~statefip)

# (3) High-bargaining subsample
h3 <- feols(log_hourly_wage ~ treat_post | statefip + income_year + female + educ_cat,
            data = filter(df, high_bargaining == 1), weights = ~ASECWT, cluster = ~statefip)

# (4) Low-bargaining subsample
l4 <- feols(log_hourly_wage ~ treat_post | statefip + income_year + female + educ_cat,
            data = filter(df, high_bargaining == 0), weights = ~ASECWT, cluster = ~statefip)

etable(b1, b2, h3, l4,
       tex = TRUE,
       style.tex = style.tex("aer"),
       fitstat = ~ r2 + n,
       title = "Heterogeneity by Occupation Bargaining Intensity",
       label = "tab:bargaining",
       headers = c("All", "All", "High-Bargain", "Low-Bargain"),
       keep = c("treat_post", "treat_post:high_bargaining"),
       dict = c(
         treat_post = "Treated $\\times$ Post",
         `treat_post:high_bargaining` = "Treated $\\times$ Post $\\times$ High-Bargain"
       ),
       notes = paste0(
         "Notes: Standard errors clustered at the state level in parentheses. ",
         "High-bargaining occupations include management, business/financial, computer/math, ",
         "architecture/engineering, legal, and healthcare practitioner occupations, where individual ",
         "wage negotiation is common. Cullen \\& Pakzad-Hurson (2023) predict that transparency ",
         "reduces wages more in high-bargaining occupations by eliminating workers' information rents. ",
         "* p $<$ 0.10, ** p $<$ 0.05, *** p $<$ 0.01."
       ),
       file = "tables/table4_bargaining.tex")

cat("Saved tables/table4_bargaining.tex\n")

# ============================================================================
# Table 5: Event Study Coefficients
# ============================================================================

cat("\nCreating Table 5: Event Study Coefficients...\n")

# Format event study data for table
es_table <- es_data %>%
  mutate(
    Coefficient = sprintf("%.4f", att),
    SE = sprintf("(%.4f)", se),
    `95\\%% CI` = sprintf("[%.4f, %.4f]", ci_lower, ci_upper),
    Significant = ifelse(significant, "*", "")
  ) %>%
  select(`Event Time` = event_time, Coefficient, SE, `95\\%% CI`)

# Create LaTeX
es_latex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Event Study Coefficients: Callaway-Sant'Anna Estimator}\n",
  "\\label{tab:event_study}\n",
  "\\begin{tabular}{cccc}\n",
  "\\toprule\n",
  "Event Time & Coefficient & SE & 95\\% CI \\\\\n",
  "\\midrule\n"
)

for (i in 1:nrow(es_table)) {
  es_latex <- paste0(es_latex,
    es_table$`Event Time`[i], " & ",
    es_table$Coefficient[i], " & ",
    es_table$SE[i], " & ",
    es_table$`95\\%% CI`[i], " \\\\\n"
  )
}

es_latex <- paste0(es_latex,
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{minipage}{0.8\\textwidth}\n",
  "\\footnotesize\n",
  "\\textit{Notes:} Event time is years relative to treatment. Reference period is $t = -1$ (coefficient normalized to zero). Estimates from Callaway \\& Sant'Anna (2021) with never-treated states as controls and doubly-robust estimation.\n",
  "\\end{minipage}\n",
  "\\end{table}\n"
)

writeLines(es_latex, "tables/table5_event_study.tex")
cat("Saved tables/table5_event_study.tex\n")

# ============================================================================
# Table 6: Robustness Checks
# ============================================================================

cat("\nCreating Table 6: Robustness Checks...\n")

# Use the robustness summary from 05_robustness.R
robust_table <- robustness$summary_table

robust_latex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Robustness of Main Results}\n",
  "\\label{tab:robustness}\n",
  "\\begin{tabular}{lccc}\n",
  "\\toprule\n",
  "Specification & ATT & SE & 95\\% CI \\\\\n",
  "\\midrule\n"
)

for (i in 1:nrow(robust_table)) {
  robust_latex <- paste0(robust_latex,
    robust_table$Specification[i], " & ",
    robust_table$ATT[i], " & ",
    robust_table$SE[i], " & ",
    robust_table$`95% CI`[i], " \\\\\n"
  )
}

robust_latex <- paste0(robust_latex,
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{minipage}{0.9\\textwidth}\n",
  "\\footnotesize\n",
  "\\textit{Notes:} All specifications estimate the effect of salary transparency laws on log hourly wages. The main specification uses the Callaway \\& Sant'Anna (2021) estimator with never-treated states as controls. Alternative specifications vary the estimator, control group, sample restrictions, and fixed effects. Standard errors clustered at the state level.\n",
  "\\end{minipage}\n",
  "\\end{table}\n"
)

writeLines(robust_latex, "tables/table6_robustness.tex")
cat("Saved tables/table6_robustness.tex\n")

# ============================================================================
# Table A1: Treatment Timing (Appendix)
# ============================================================================

cat("\nCreating Table A1: Treatment Timing...\n")

timing_table <- transparency_laws %>%
  arrange(effective_date) %>%
  mutate(
    `Effective Date` = format(effective_date, "%B %d, %Y"),
    `First Income Year` = first_treat,
    `Employer Threshold` = paste0(employer_threshold, "+")
  ) %>%
  select(State = state_name, `Effective Date`, `First Income Year`, `Employer Threshold`)

timing_latex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Salary Transparency Law Adoption Timing}\n",
  "\\label{tab:timing}\n",
  "\\begin{tabular}{lccc}\n",
  "\\toprule\n",
  "State & Effective Date & First Income Year & Employer Threshold \\\\\n",
  "\\midrule\n"
)

for (i in 1:nrow(timing_table)) {
  timing_latex <- paste0(timing_latex,
    timing_table$State[i], " & ",
    timing_table$`Effective Date`[i], " & ",
    timing_table$`First Income Year`[i], " & ",
    timing_table$`Employer Threshold`[i], " employees \\\\\n"
  )
}

timing_latex <- paste0(timing_latex,
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{minipage}{0.9\\textwidth}\n",
  "\\footnotesize\n",
  "\\textit{Notes:} The ``First Income Year'' column indicates when the law first affects income measured in the CPS ASEC, which asks about income in the prior calendar year. For laws effective January 1, the income year equals the effective year. For laws effective later in the year, the first full income year is the following year.\n",
  "\\end{minipage}\n",
  "\\end{table}\n"
)

writeLines(timing_latex, "tables/tableA1_timing.tex")
cat("Saved tables/tableA1_timing.tex\n")

# ============================================================================
# Summary
# ============================================================================

cat("\n==== Table Generation Complete ====\n")
cat("Created tables:\n")
cat("  table1_summary_stats.tex - Summary statistics\n")
cat("  table2_main_results.tex - Main DiD results\n")
cat("  table3_gender_gap.tex - Triple-difference gender results\n")
cat("  table4_bargaining.tex - Bargaining heterogeneity\n")
cat("  table5_event_study.tex - Event study coefficients\n")
cat("  table6_robustness.tex - Robustness checks\n")
cat("  tableA1_timing.tex - Treatment timing (appendix)\n")
cat("\nAnalysis complete. Ready to write paper.\n")
