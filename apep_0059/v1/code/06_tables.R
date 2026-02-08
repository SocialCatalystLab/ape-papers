# =============================================================================
# 06_tables.R
# Generate publication-ready tables
# =============================================================================

source("00_packages.R")

library(knitr)
library(kableExtra)

# Load data and results
df <- readRDS(file.path(data_dir, "pums_clean.rds"))
results_df <- readRDS(file.path(data_dir, "aipw_results_df.rds"))
robustness <- readRDS(file.path(data_dir, "robustness_results.rds"))

# =============================================================================
# Table 1: Summary Statistics
# =============================================================================

cat("Creating Table 1: Summary Statistics...\n")

# Calculate weighted statistics by group
summary_stats <- df %>%
  group_by(self_employed) %>%
  summarise(
    # Sample
    n = n(),
    n_weighted = sum(PWGTP),

    # Demographics
    age_mean = weighted.mean(age, PWGTP),
    female_pct = 100 * weighted.mean(female, PWGTP),
    white_pct = 100 * weighted.mean(race == "White", PWGTP),
    black_pct = 100 * weighted.mean(race == "Black", PWGTP),
    hispanic_pct = 100 * weighted.mean(race == "Hispanic", PWGTP),
    college_pct = 100 * weighted.mean(educ %in% c("Bachelor's", "Graduate"), PWGTP),
    married_pct = 100 * weighted.mean(married, PWGTP),

    # Labor
    hours_mean = weighted.mean(hours_worked, PWGTP),

    # Insurance outcomes
    any_insurance = 100 * weighted.mean(any_insurance, PWGTP),
    employer_ins = 100 * weighted.mean(employer_insurance, PWGTP),
    direct_purchase = 100 * weighted.mean(direct_purchase, PWGTP),
    medicaid = 100 * weighted.mean(medicaid, PWGTP),

    .groups = "drop"
  )

# Format for table
table1 <- tibble(
  Variable = c(
    "Observations (unweighted)", "Observations (weighted, millions)",
    "", "Demographics",
    "Age (mean)", "Female (%)", "White (%)", "Black (%)", "Hispanic (%)",
    "College graduate (%)", "Married (%)", "Hours worked (mean)",
    "", "Health Insurance Coverage (%)",
    "Any insurance", "Employer-sponsored", "Direct purchase/Marketplace", "Medicaid"
  ),
  `Wage Workers` = c(
    format(summary_stats$n[1], big.mark = ","),
    sprintf("%.1f", summary_stats$n_weighted[1] / 1e6),
    "", "",
    sprintf("%.1f", summary_stats$age_mean[1]),
    sprintf("%.1f", summary_stats$female_pct[1]),
    sprintf("%.1f", summary_stats$white_pct[1]),
    sprintf("%.1f", summary_stats$black_pct[1]),
    sprintf("%.1f", summary_stats$hispanic_pct[1]),
    sprintf("%.1f", summary_stats$college_pct[1]),
    sprintf("%.1f", summary_stats$married_pct[1]),
    sprintf("%.1f", summary_stats$hours_mean[1]),
    "", "",
    sprintf("%.1f", summary_stats$any_insurance[1]),
    sprintf("%.1f", summary_stats$employer_ins[1]),
    sprintf("%.1f", summary_stats$direct_purchase[1]),
    sprintf("%.1f", summary_stats$medicaid[1])
  ),
  `Self-Employed` = c(
    format(summary_stats$n[2], big.mark = ","),
    sprintf("%.1f", summary_stats$n_weighted[2] / 1e6),
    "", "",
    sprintf("%.1f", summary_stats$age_mean[2]),
    sprintf("%.1f", summary_stats$female_pct[2]),
    sprintf("%.1f", summary_stats$white_pct[2]),
    sprintf("%.1f", summary_stats$black_pct[2]),
    sprintf("%.1f", summary_stats$hispanic_pct[2]),
    sprintf("%.1f", summary_stats$college_pct[2]),
    sprintf("%.1f", summary_stats$married_pct[2]),
    sprintf("%.1f", summary_stats$hours_mean[2]),
    "", "",
    sprintf("%.1f", summary_stats$any_insurance[2]),
    sprintf("%.1f", summary_stats$employer_ins[2]),
    sprintf("%.1f", summary_stats$direct_purchase[2]),
    sprintf("%.1f", summary_stats$medicaid[2])
  )
)

# Save as CSV
write_csv(table1, file.path(fig_dir, "table1_summary_stats.csv"))

# Print for LaTeX
cat("\n=== Table 1: Summary Statistics ===\n")
print(table1, n = Inf)

# =============================================================================
# Table 2: Main AIPW Results
# =============================================================================

cat("\nCreating Table 2: Main Results...\n")

# Format results
table2 <- results_df %>%
  mutate(
    Outcome = case_when(
      Outcome == "any_insurance" ~ "Any Health Insurance",
      Outcome == "private_coverage" ~ "Private Coverage",
      Outcome == "public_coverage" ~ "Public Coverage",
      Outcome == "employer_insurance" ~ "Employer-Sponsored",
      Outcome == "direct_purchase" ~ "Direct Purchase/Marketplace",
      Outcome == "medicaid" ~ "Medicaid"
    ),
    Effect = sprintf("%.3f", ATT),
    `Std. Error` = sprintf("%.3f", SE),
    `95% CI` = sprintf("[%.3f, %.3f]", CI_Lower, CI_Upper),
    `p-value` = case_when(
      P_Value < 0.001 ~ "< 0.001",
      P_Value < 0.01 ~ sprintf("%.3f", P_Value),
      P_Value < 0.05 ~ sprintf("%.3f", P_Value),
      TRUE ~ sprintf("%.3f", P_Value)
    ),
    Significance = case_when(
      P_Value < 0.001 ~ "***",
      P_Value < 0.01 ~ "**",
      P_Value < 0.05 ~ "*",
      TRUE ~ ""
    )
  ) %>%
  select(Outcome, Effect, `Std. Error`, `95% CI`, `p-value`, Significance)

write_csv(table2, file.path(fig_dir, "table2_main_results.csv"))

cat("\n=== Table 2: Main AIPW Results ===\n")
print(table2, n = Inf)

# =============================================================================
# Table 3: Robustness Checks
# =============================================================================

cat("\nCreating Table 3: Robustness Checks...\n")

table3 <- robustness$alt_specs %>%
  mutate(
    Effect = sprintf("%.3f", att),
    `Std. Error` = sprintf("%.3f", se),
    `95% CI` = sprintf("[%.3f, %.3f]", att - 1.96*se, att + 1.96*se)
  ) %>%
  select(Specification = specification, Effect, `Std. Error`, `95% CI`)

write_csv(table3, file.path(fig_dir, "table3_robustness.csv"))

cat("\n=== Table 3: Robustness Checks (Any Insurance) ===\n")
print(table3)

# =============================================================================
# Table 4: Subgroup Analysis
# =============================================================================

cat("\nCreating Table 4: Subgroup Analysis...\n")

table4 <- robustness$subgroup %>%
  filter(outcome == "any_insurance") %>%
  mutate(
    Subgroup = subgroup,
    Effect = sprintf("%.3f", att),
    `Std. Error` = sprintf("%.3f", se),
    `95% CI` = sprintf("[%.3f, %.3f]", ci_lower, ci_upper)
  ) %>%
  select(Subgroup, Effect, `Std. Error`, `95% CI`)

write_csv(table4, file.path(fig_dir, "table4_subgroups.csv"))

cat("\n=== Table 4: Subgroup Analysis ===\n")
print(table4)

# =============================================================================
# Table 5: E-Values (Sensitivity)
# =============================================================================

cat("\nCreating Table 5: E-Values...\n")

table5 <- robustness$evalues %>%
  filter(!is.na(e_value_point)) %>%
  mutate(
    Outcome = case_when(
      outcome == "any_insurance" ~ "Any Health Insurance",
      outcome == "employer_insurance" ~ "Employer-Sponsored",
      outcome == "direct_purchase" ~ "Direct Purchase",
      outcome == "medicaid" ~ "Medicaid",
      TRUE ~ outcome
    ),
    `Risk Ratio` = sprintf("%.2f", risk_ratio),
    `E-value (Point)` = sprintf("%.2f", e_value_point),
    `E-value (CI)` = sprintf("%.2f", e_value_ci)
  ) %>%
  select(Outcome, `Risk Ratio`, `E-value (Point)`, `E-value (CI)`)

write_csv(table5, file.path(fig_dir, "table5_evalues.csv"))

cat("\n=== Table 5: E-Values for Sensitivity Analysis ===\n")
print(table5)

# =============================================================================
# LaTeX Table Export
# =============================================================================

cat("\nGenerating LaTeX tables...\n")

# Main results LaTeX
latex_main <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Effect of Self-Employment on Health Insurance Coverage}\n",
  "\\label{tab:main_results}\n",
  "\\begin{tabular}{lcccc}\n",
  "\\toprule\n",
  "Outcome & Effect & SE & 95\\% CI & Sig. \\\\\n",
  "\\midrule\n",
  paste(apply(table2[, c(1:4, 6)], 1, function(x) paste(x, collapse = " & ")), collapse = " \\\\\n"),
  " \\\\\n",
  "\\bottomrule\n",
  "\\multicolumn{5}{l}{\\footnotesize Note: AIPW estimates of ATT with influence-function SEs.} \\\\\n",
  "\\multicolumn{5}{l}{\\footnotesize Significance: *** p<0.001, ** p<0.01, * p<0.05} \\\\\n",
  "\\end{tabular}\n",
  "\\end{table}"
)

writeLines(latex_main, file.path(fig_dir, "table2_main_results.tex"))

cat("\n=== Tables Created ===\n")
cat("1. table1_summary_stats.csv\n")
cat("2. table2_main_results.csv / .tex\n")
cat("3. table3_robustness.csv\n")
cat("4. table4_subgroups.csv\n")
cat("5. table5_evalues.csv\n")

cat("\nAll tables saved to:", fig_dir, "\n")
