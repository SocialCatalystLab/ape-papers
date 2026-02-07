# ============================================================================
# 07_tables.R
# Salary Transparency Laws and the Gender Wage Gap
# All Table Generation (LaTeX)
# ============================================================================
#
# --- Input/Output Provenance ---
# INPUTS (all created by upstream scripts):
#   data/cps_analysis.rds          <- 02_clean_data.R (individual-level analysis data)
#   data/state_year_panel.rds      <- 02_clean_data.R (state-year aggregates)
#   data/transparency_laws.rds     <- 00_policy_data.R (treatment timing + citations)
#   data/main_results.rds          <- 04_main_analysis.R (CS-DiD, TWFE, DDD results)
#   data/robustness_results.rds    <- 05_robustness.R (robustness specifications)
#   data/event_study_data.rds      <- 04_main_analysis.R (event study coefficients)
#   data/collapsed_bootstrap.rds   <- 05_robustness.R (collapsed-cell bootstrap, optional)
#   data/permutation_results.rds   <- 05_robustness.R (Fisher randomization, optional)
#   data/loto_results.rds          <- 05_robustness.R (leave-one-out, optional)
#   data/honestdid_gender_results.rds <- 05_robustness.R (HonestDiD bounds, optional)
#   data/composition_results.rds   <- 05_robustness.R (composition balance, optional)
#   data/upper75_results.rds       <- 05_robustness.R (upper-distribution, optional)
#   data/threshold_results.rds     <- 05_robustness.R (firm-size threshold, optional)
# OUTPUTS:
#   tables/table1_summary_stats.tex
#   tables/table2_main_results.tex
#   tables/table3_gender_gap.tex
#   tables/table4_bargaining.tex
#   tables/table5_event_study.tex
#   tables/table6_robustness.tex
#   tables/tableA1_timing.tex
#   tables/tableA2_alt_inference.tex
#   tables/tableA3_honestdid_gender.tex
#   tables/tableA4_composition.tex
# ============================================================================

source("code/00_packages.R")

# --- File existence checks for required inputs ---
required_files <- c(
  "data/cps_analysis.rds",
  "data/state_year_panel.rds",
  "data/transparency_laws.rds",
  "data/main_results.rds",
  "data/robustness_results.rds",
  "data/event_study_data.rds"
)
for (f in required_files) {
  if (!file.exists(f)) stop("Required input file not found: ", f,
                            "\nRun upstream scripts first.")
}

# Load data and results
df <- readRDS("data/cps_analysis.rds")
state_year <- readRDS("data/state_year_panel.rds")
transparency_laws <- readRDS("data/transparency_laws.rds")
results <- readRDS("data/main_results.rds")
robustness <- readRDS("data/robustness_results.rds")
es_data <- readRDS("data/event_study_data.rds")

cat("Loaded all data and results.\n")

# Construct derived variables needed for table specifications
state_year <- state_year %>%
  mutate(
    g = first_treat,
    y = log(mean_wage),
    treat_post = as.integer(first_treat > 0 & income_year >= first_treat)
  )

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
  "States & ", sum(transparency_laws$first_treat > 0), " & ", 51 - sum(transparency_laws$first_treat > 0), " \\\\\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{minipage}{0.9\\textwidth}\n",
  "\\footnotesize\n",
  "\\textit{Notes:} Sample restricted to wage/salary workers ages 25-64 in the CPS ASEC, pre-treatment period (income years 2014-2020). N reports unweighted person-year observations. Treated states are the 8 states that enacted salary transparency laws by 2024; of these, 6 have post-treatment data in the analysis window (income years through 2023). High-bargaining occupations include management, business/financial, computer/math, architecture/engineering, legal, and healthcare practitioner occupations.\n",
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
         "Notes: Standard errors clustered at the state level (51 clusters: 6 treated with post-treatment data, 45 control/not-yet-treated) in parentheses. ",
         "Column (1) uses state-year aggregates (51 states $\\times$ 10 years = 510 obs); the high $R^2$ (0.965) reflects 51 state + 10 year fixed effects absorbing most variation in this small panel. ",
         "Columns (2)-(4) use individual-level CPS ASEC data with survey weights (ASECWT); observation counts are survey-weighted (unweighted N $\\approx$ 650,000 person-years). ",
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
       keep = c("%treat_post", "%female", "%treat_post:female"),
       dict = c(
         treat_post = "Treated $\\times$ Post",
         female = "Female",
         `treat_post:female` = "Treated $\\times$ Post $\\times$ Female"
       ),
       notes = paste0(
         "Notes: Standard errors clustered at the state level (51 clusters) in parentheses. ",
         "Sample: wage/salary workers ages 25-64, income years 2014-2023 (unweighted N $\\approx$ 650,000 person-years). ",
         "The coefficient on Treated $\\times$ Post represents the effect on male wages. ",
         "The coefficient on Treated $\\times$ Post $\\times$ Female represents the additional effect for women; ",
         "a positive coefficient indicates the gender gap narrows. ",
         "Column (4) absorbs Treated $\\times$ Post with state$\\times$year FE; the gender gap effect ($\\beta_2$) is identified from within-state-year variation. ",
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
       keep = c("%treat_post", "%high_bargaining", "%treat_post:high_bargaining"),
       dict = c(
         treat_post = "Treated $\\times$ Post",
         `treat_post:high_bargaining` = "Treated $\\times$ Post $\\times$ High-Bargain"
       ),
       notes = paste0(
         "Notes: Standard errors clustered at the state level (51 clusters) in parentheses. ",
         "Sample: wage/salary workers ages 25-64, income years 2014-2023 (unweighted N $\\approx$ 650,000 person-years). ",
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
  "\\textit{Notes:} All specifications estimate the effect of salary transparency laws on log hourly wages. The main specification uses the Callaway \\& Sant'Anna (2021) estimator with never-treated states as controls. Alternative specifications vary the estimator, control group, sample restrictions, and fixed effects. Standard errors clustered at the state level (51 clusters; 6 treated states with post-treatment data, 43 never-treated + DC, 2 treated without post-treatment observations). Unweighted individual-level sample $\\approx$ 650,000 person-years.\n",
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
  filter(first_treat > 0) %>%  # Only treated states
  arrange(effective_date) %>%
  mutate(
    `Effective Date` = format(effective_date, "%B %d, %Y"),
    `First Income Year` = first_treat,
    `Employer Threshold` = employer_threshold
  ) %>%
  select(State = state, `Effective Date`, `First Income Year`, `Employer Threshold`)

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

# ============================================================================
# Table A2: Alternative Inference Methods
# ============================================================================

cat("\nCreating Table A2: Alternative Inference Methods...\n")

# Build rows from saved results
a2_rows <- list()

# Row 1: Aggregate ATT
a2_rows[[1]] <- c(
  "Aggregate ATT (C-S)",
  sprintf("%.4f", results$att_simple$overall.att),
  sprintf("%.4f", results$att_simple$overall.se),
  sprintf("%.3f", 2 * pnorm(-abs(results$att_simple$overall.att / results$att_simple$overall.se)))
)

# Row 2: Gender DDD (treat_post:female)
ddd_est <- coef(results$ddd_result)["treat_post:female"]
ddd_se <- se(results$ddd_result)["treat_post:female"]
a2_rows[[2]] <- c(
  "Gender DDD ($\\beta_2$)",
  sprintf("%.4f", ddd_est),
  sprintf("%.4f", ddd_se),
  sprintf("%.3f", 2 * pnorm(-abs(ddd_est / ddd_se)))
)

# Add bootstrap and permutation columns
boot_p_att <- "---"
boot_p_ddd <- "---"
perm_p_att <- "---"
perm_p_ddd <- "---"
loto_range_att <- "---"
loto_range_ddd <- "---"

if (file.exists("data/collapsed_bootstrap.rds")) {
  cb <- readRDS("data/collapsed_bootstrap.rds")
  if (!is.null(cb$boot_collapsed_att)) {
    boot_p_att <- sprintf("%.3f", cb$boot_collapsed_att$p_val)
  }
  if (!is.null(cb$boot_collapsed_ddd)) {
    boot_p_ddd <- sprintf("%.3f", cb$boot_collapsed_ddd$p_val)
  }
}

if (file.exists("data/permutation_results.rds")) {
  pr <- readRDS("data/permutation_results.rds")
  perm_p_att <- sprintf("%.3f", pr$perm_p_att)
  perm_p_ddd <- sprintf("%.3f", pr$perm_p_ddd)
}

if (file.exists("data/loto_results.rds")) {
  lr <- readRDS("data/loto_results.rds")
  loto_range_att <- sprintf("[%.4f, %.4f]",
                            min(lr$loto_summary$ATT, na.rm = TRUE),
                            max(lr$loto_summary$ATT, na.rm = TRUE))
  loto_range_ddd <- sprintf("[%.4f, %.4f]",
                            min(lr$loto_summary$DDD_Coef, na.rm = TRUE),
                            max(lr$loto_summary$DDD_Coef, na.rm = TRUE))
}

a2_latex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Alternative Inference Methods}\n",
  "\\label{tab:alt_inference}\n",
  "\\begin{tabular}{lcccccc}\n",
  "\\toprule\n",
  " & Estimate & Asymptotic & Asymptotic & Bootstrap & Permutation & LOTO \\\\\n",
  " &  & SE & $p$ & $p$ & $p$ & Range \\\\\n",
  "\\midrule\n",
  "Aggregate ATT & ", a2_rows[[1]][2], " & ", a2_rows[[1]][3], " & ", a2_rows[[1]][4],
  " & ", boot_p_att, " & ", perm_p_att, " & ", loto_range_att, " \\\\\n",
  "Gender DDD ($\\beta_2$) & ", a2_rows[[2]][2], " & ", a2_rows[[2]][3], " & ", a2_rows[[2]][4],
  " & ", boot_p_ddd, " & ", perm_p_ddd, " & ", loto_range_ddd, " \\\\\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{minipage}{0.95\\textwidth}\n",
  "\\footnotesize\n",
  "\\textit{Notes:} Asymptotic inference uses cluster-robust standard errors at the state level (51 clusters). ",
  "Bootstrap $p$-values from collapsed-cell wild cluster bootstrap with Webb 6-point distribution and 99,999 iterations ",
  "\\citep{mackinnon2017wild}. Permutation $p$-values from Fisher randomization inference with 5,000 random ",
  "treatment assignments preserving the actual timing structure \\citep{ferman2019inference}. ",
  "LOTO range shows the range of estimates across leave-one-treated-state-out samples (6 leave-out estimates).\n",
  "\\end{minipage}\n",
  "\\end{table}\n"
)

writeLines(a2_latex, "tables/tableA2_alt_inference.tex")
cat("Saved tables/tableA2_alt_inference.tex\n")

# ============================================================================
# Table A3: HonestDiD Sensitivity for Gender Gap
# ============================================================================

cat("\nCreating Table A3: HonestDiD Gender Gap Sensitivity...\n")

a3_latex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{HonestDiD Sensitivity: Gender Gap Effect}\n",
  "\\label{tab:honestdid_gender}\n",
  "\\begin{tabular}{cccc}\n",
  "\\toprule\n",
  "$M$ & Estimate & 95\\% CI & Zero Excluded? \\\\\n",
  "\\midrule\n"
)

if (file.exists("data/honestdid_gender_results.rds")) {
  hd_g <- readRDS("data/honestdid_gender_results.rds")
  hd_df <- hd_g$hd_df
  if (!is.null(hd_df)) {
    for (i in 1:nrow(hd_df)) {
      excluded <- ifelse(hd_df$lb[i] > 0 | hd_df$ub[i] < 0, "Yes", "No")
      a3_latex <- paste0(a3_latex,
        sprintf("%.1f", hd_df$M[i]), " & ",
        sprintf("%.4f", hd_df$estimate[i]), " & [",
        sprintf("%.4f", hd_df$lb[i]), ", ",
        sprintf("%.4f", hd_df$ub[i]), "] & ",
        excluded, " \\\\\n"
      )
    }
  }
}

a3_latex <- paste0(a3_latex,
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{minipage}{0.85\\textwidth}\n",
  "\\footnotesize\n",
  "\\textit{Notes:} $M$ indicates the maximum magnitude of parallel trends violations relative to the largest ",
  "pre-treatment coefficient magnitude for the gender gap event study. Bounds computed using the ",
  "\\citet{rambachan2023more} relative magnitudes approach on the gender gap event study ",
  "(female ATT minus male ATT at each event time).\n",
  "\\end{minipage}\n",
  "\\end{table}\n"
)

writeLines(a3_latex, "tables/tableA3_honestdid_gender.tex")
cat("Saved tables/tableA3_honestdid_gender.tex\n")

# ============================================================================
# Table A4: Composition Balance Tests
# ============================================================================

cat("\nCreating Table A4: Composition Balance Tests...\n")

a4_latex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Composition Balance Tests: DiD on Workforce Characteristics}\n",
  "\\label{tab:composition}\n",
  "\\begin{tabular}{lccc}\n",
  "\\toprule\n",
  "Outcome & Coefficient & SE & $p$-value \\\\\n",
  "\\midrule\n"
)

if (file.exists("data/composition_results.rds")) {
  comp_res <- readRDS("data/composition_results.rds")
  for (cr in comp_res) {
    a4_latex <- paste0(a4_latex,
      cr$label, " & ",
      sprintf("%.4f", cr$estimate), " & ",
      sprintf("%.4f", cr$se), " & ",
      sprintf("%.3f", cr$p_value), " \\\\\n"
    )
  }
}

a4_latex <- paste0(a4_latex,
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{minipage}{0.85\\textwidth}\n",
  "\\footnotesize\n",
  "\\textit{Notes:} Each row reports results from a separate TWFE regression of the listed ",
  "composition variable on Treated $\\times$ Post with state and year fixed effects, using the state-year panel. ",
  "A significant coefficient would indicate differential compositional changes in treated states, ",
  "raising concerns about selection. Standard errors clustered at the state level.\n",
  "\\end{minipage}\n",
  "\\end{table}\n"
)

writeLines(a4_latex, "tables/tableA4_composition.tex")
cat("Saved tables/tableA4_composition.tex\n")

# ============================================================================
# Update Table 6: Add upper-75% and firm-size rows
# ============================================================================

cat("\nUpdating Table 6: Robustness Checks (with new rows)...\n")

# Rebuild Table 6 with additional rows
robust_table_v5 <- robustness$summary_table

# Add upper-75% row
if (file.exists("data/upper75_results.rds")) {
  u75 <- readRDS("data/upper75_results.rds")
  if (!is.null(u75$att_upper75)) {
    robust_table_v5 <- bind_rows(robust_table_v5, tibble(
      Specification = "Upper 75\\% wage dist.",
      ATT = round(u75$att_upper75$overall.att, 4),
      SE = round(u75$att_upper75$overall.se, 4),
      `95% CI` = paste0("[", round(u75$att_upper75$overall.att - 1.96 * u75$att_upper75$overall.se, 4),
                        ", ", round(u75$att_upper75$overall.att + 1.96 * u75$att_upper75$overall.se, 4), "]")
    ))
  }
}

# Add firm-size threshold row
if (file.exists("data/threshold_results.rds")) {
  thr <- readRDS("data/threshold_results.rds")
  if (!is.null(thr$m_threshold)) {
    tp_est <- coef(thr$m_threshold)["treat_post"]
    tp_se <- se(thr$m_threshold)["treat_post"]
    robust_table_v5 <- bind_rows(robust_table_v5, tibble(
      Specification = "Firm-size threshold interact.",
      ATT = round(tp_est, 4),
      SE = round(tp_se, 4),
      `95% CI` = paste0("[", round(tp_est - 1.96 * tp_se, 4),
                        ", ", round(tp_est + 1.96 * tp_se, 4), "]")
    ))
  }
}

# Rebuild latex
robust_latex_v5 <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Robustness of Main Results}\n",
  "\\label{tab:robustness}\n",
  "\\begin{tabular}{lccc}\n",
  "\\toprule\n",
  "Specification & ATT & SE & 95\\% CI \\\\\n",
  "\\midrule\n"
)

for (i in 1:nrow(robust_table_v5)) {
  robust_latex_v5 <- paste0(robust_latex_v5,
    robust_table_v5$Specification[i], " & ",
    robust_table_v5$ATT[i], " & ",
    robust_table_v5$SE[i], " & ",
    robust_table_v5$`95% CI`[i], " \\\\\n"
  )
}

robust_latex_v5 <- paste0(robust_latex_v5,
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{minipage}{0.9\\textwidth}\n",
  "\\footnotesize\n",
  "\\textit{Notes:} All specifications estimate the effect of salary transparency laws on log hourly wages. ",
  "The main specification uses the Callaway \\& Sant'Anna (2021) estimator with never-treated states as controls. ",
  "Alternative specifications vary the estimator, control group, sample restrictions, and fixed effects. ",
  "``Upper 75\\%'' restricts to workers above the 25th percentile of the pre-treatment wage distribution. ",
  "``Firm-size threshold'' interacts treatment with an indicator for states with all-employer coverage. ",
  "Standard errors clustered at the state level.\n",
  "\\end{minipage}\n",
  "\\end{table}\n"
)

writeLines(robust_latex_v5, "tables/table6_robustness.tex")
cat("Saved updated tables/table6_robustness.tex\n")

# ============================================================================
# Summary
# ============================================================================

cat("\n==== Table Generation Complete (v5) ====\n")
cat("Created tables:\n")
cat("  table1_summary_stats.tex - Summary statistics\n")
cat("  table2_main_results.tex - Main DiD results\n")
cat("  table3_gender_gap.tex - Triple-difference gender results\n")
cat("  table4_bargaining.tex - Bargaining heterogeneity\n")
cat("  table5_event_study.tex - Event study coefficients\n")
cat("  table6_robustness.tex - Robustness checks (updated with upper-75% and threshold)\n")
cat("  tableA1_timing.tex - Treatment timing (appendix)\n")
cat("  tableA2_alt_inference.tex - Alternative inference methods\n")
cat("  tableA3_honestdid_gender.tex - HonestDiD gender gap sensitivity\n")
cat("  tableA4_composition.tex - Composition balance tests\n")
cat("\nAnalysis complete. Ready to write paper.\n")
