# ==============================================================================
# 06_tables.R - Generate All Tables
# Paper 60: State Auto-IRA Mandates and Retirement Savings
# ==============================================================================

source("code/00_packages.R")

# ==============================================================================
# Load Data
# ==============================================================================

cps_private <- readRDS("data/cps_private.rds")
auto_ira_dates <- readRDS("data/auto_ira_policy_dates.rds")
results <- readRDS("data/main_results.rds")

# ==============================================================================
# Table 1: Summary Statistics
# ==============================================================================

cat("Creating Table 1: Summary statistics...\n")

# Calculate summary stats by treatment status
summary_stats <- cps_private %>%
  mutate(
    treatment_group = ifelse(auto_ira_state == 1, "Treated States", "Control States")
  ) %>%
  group_by(treatment_group) %>%
  summarise(
    n = n(),
    `Age` = weighted.mean(age, weight),
    `Female (%)` = weighted.mean(female, weight) * 100,
    `Married (%)` = weighted.mean(married, weight) * 100,
    `Bachelor's+ (%)` = weighted.mean(educ_ba_plus, weight) * 100,
    `Has Pension at Job (%)` = weighted.mean(has_pension_at_job, weight, na.rm = TRUE) * 100,
    `Pension Participant (%)` = weighted.mean(pension_participant, weight, na.rm = TRUE) * 100,
    `Mean Wage Income ($)` = weighted.mean(income_wage, weight, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_longer(-treatment_group, names_to = "Variable", values_to = "value") %>%
  pivot_wider(names_from = treatment_group, values_from = value)

# Also add overall column
overall_stats <- cps_private %>%
  summarise(
    n = n(),
    `Age` = weighted.mean(age, weight),
    `Female (%)` = weighted.mean(female, weight) * 100,
    `Married (%)` = weighted.mean(married, weight) * 100,
    `Bachelor's+ (%)` = weighted.mean(educ_ba_plus, weight) * 100,
    `Has Pension at Job (%)` = weighted.mean(has_pension_at_job, weight, na.rm = TRUE) * 100,
    `Pension Participant (%)` = weighted.mean(pension_participant, weight, na.rm = TRUE) * 100,
    `Mean Wage Income ($)` = weighted.mean(income_wage, weight, na.rm = TRUE)
  ) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "Overall")

summary_stats <- summary_stats %>%
  left_join(overall_stats, by = "Variable")

# Round values
summary_stats <- summary_stats %>%
  mutate(across(where(is.numeric), ~round(., 2)))

# Export to LaTeX
cat("\n% Table 1: Summary Statistics\n")
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics: Private Sector Workers Ages 25-64}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\toprule\n")
cat("Variable & Treated States & Control States & Overall \\\\\n")
cat("\\midrule\n")
for (i in 1:nrow(summary_stats)) {
  row <- summary_stats[i, ]
  if (row$Variable == "n") {
    cat(sprintf("N & %s & %s & %s \\\\\n",
                format(row$`Treated States`, big.mark = ","),
                format(row$`Control States`, big.mark = ","),
                format(row$Overall, big.mark = ",")))
  } else if (grepl("\\$", row$Variable)) {
    cat(sprintf("%s & %s & %s & %s \\\\\n",
                row$Variable,
                format(round(row$`Treated States`), big.mark = ","),
                format(round(row$`Control States`), big.mark = ","),
                format(round(row$Overall), big.mark = ",")))
  } else {
    cat(sprintf("%s & %.2f & %.2f & %.2f \\\\\n",
                row$Variable, row$`Treated States`, row$`Control States`, row$Overall))
  }
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}\n")
cat("\\small\n")
cat("\\item Note: Data from CPS ASEC 2012-2024. Treated states are those that adopted auto-IRA mandates by 2024. Statistics weighted by ASEC weights.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")

# Save to file
sink("figures/tab1_summary.tex")
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics: Private Sector Workers Ages 25-64}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\toprule\n")
cat("Variable & Treated States & Control States & Overall \\\\\n")
cat("\\midrule\n")
for (i in 1:nrow(summary_stats)) {
  row <- summary_stats[i, ]
  if (row$Variable == "n") {
    cat(sprintf("N & %s & %s & %s \\\\\n",
                format(row$`Treated States`, big.mark = ","),
                format(row$`Control States`, big.mark = ","),
                format(row$Overall, big.mark = ",")))
  } else if (grepl("\\$", row$Variable)) {
    cat(sprintf("%s & %s & %s & %s \\\\\n",
                row$Variable,
                format(round(row$`Treated States`), big.mark = ","),
                format(round(row$`Control States`), big.mark = ","),
                format(round(row$Overall), big.mark = ",")))
  } else {
    cat(sprintf("%s & %.2f & %.2f & %.2f \\\\\n",
                row$Variable, row$`Treated States`, row$`Control States`, row$Overall))
  }
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}\n")
cat("\\small\n")
cat("\\item Note: Data from CPS ASEC 2012-2024. Treated states are those that adopted auto-IRA mandates by 2024. Statistics weighted by ASEC weights.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

cat("Saved figures/tab1_summary.tex\n")

# ==============================================================================
# Table 2: Main Results
# ==============================================================================

cat("\nCreating Table 2: Main results...\n")

# Export main regression results using fixest::etable
etable(
  results$twfe_simple,
  results$twfe_controls,
  tex = TRUE,
  style.tex = style.tex("aer"),
  fitstat = ~ r2 + n,
  title = "Effect of Auto-IRA Mandates on Retirement Plan Coverage",
  label = "tab:main_results",
  notes = c("Standard errors clustered at the state level.",
            "Sample: Private sector workers ages 25-64.",
            "Data: CPS ASEC 2012-2024."),
  file = "figures/tab2_main_results.tex"
)

cat("Saved figures/tab2_main_results.tex\n")

# ==============================================================================
# Table 3: Policy Adoption Details
# ==============================================================================

cat("\nCreating Table 3: Policy details...\n")

policy_table <- auto_ira_dates %>%
  select(state_name, program_name, launch_date, first_treat_year) %>%
  arrange(first_treat_year, state_name) %>%
  rename(
    State = state_name,
    Program = program_name,
    `Launch Date` = launch_date,
    `First Full Year` = first_treat_year
  )

sink("figures/tab3_policy_details.tex")
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{State Auto-IRA Program Details}\n")
cat("\\label{tab:policy}\n")
cat("\\begin{tabular}{llcc}\n")
cat("\\toprule\n")
cat("State & Program Name & Launch Date & First Full Year \\\\\n")
cat("\\midrule\n")
for (i in 1:nrow(policy_table)) {
  row <- policy_table[i, ]
  cat(sprintf("%s & %s & %s & %d \\\\\n",
              row$State, row$Program, row$`Launch Date`, row$`First Full Year`))
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}\n")
cat("\\small\n")
cat("\\item Note: Launch dates from Georgetown Center for Retirement Initiatives. First full year is the first calendar year with the program in effect for at least 6 months.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

cat("Saved figures/tab3_policy_details.tex\n")

# ==============================================================================
# Table 4: Robustness Checks
# ==============================================================================

cat("\nCreating Table 4: Robustness checks...\n")

# Load robustness results if available
if (file.exists("data/robustness_results.rds")) {
  robust <- readRDS("data/robustness_results.rds")

  robustness_summary <- tibble(
    Specification = c(
      "Main (Callaway-Sant'Anna)",
      "TWFE (simple)",
      "TWFE (with controls)",
      "Gardner Two-Stage",
      "Excluding Oregon",
      "Placebo: Workers WITH pension"
    ),
    ATT = c(
      results$att_overall$overall.att,
      coef(results$twfe_simple)["treated"],
      coef(results$twfe_controls)["treated"],
      coef(robust$gardner_out)[["treated"]],
      robust$att_no_or$overall.att,
      robust$att_placebo$overall.att
    ),
    SE = c(
      results$att_overall$overall.se,
      sqrt(vcov(results$twfe_simple)["treated", "treated"]),
      sqrt(vcov(results$twfe_controls)["treated", "treated"]),
      sqrt(vcov(robust$gardner_out)[["treated", "treated"]]),
      robust$att_no_or$overall.se,
      robust$att_placebo$overall.se
    )
  ) %>%
    mutate(
      `95% CI` = sprintf("[%.4f, %.4f]", ATT - 1.96*SE, ATT + 1.96*SE),
      ATT = round(ATT, 4),
      SE = round(SE, 4)
    )

  sink("figures/tab4_robustness.tex")
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{Robustness Checks}\n")
  cat("\\label{tab:robustness}\n")
  cat("\\begin{tabular}{lccc}\n")
  cat("\\toprule\n")
  cat("Specification & ATT & SE & 95\\% CI \\\\\n")
  cat("\\midrule\n")
  for (i in 1:nrow(robustness_summary)) {
    row <- robustness_summary[i, ]
    cat(sprintf("%s & %.4f & %.4f & %s \\\\\n",
                row$Specification, row$ATT, row$SE, row$`95% CI`))
  }
  cat("\\bottomrule\n")
  cat("\\end{tabular}\n")
  cat("\\begin{tablenotes}\n")
  cat("\\small\n")
  cat("\\item Note: All specifications use private sector workers ages 25-64. Standard errors clustered at state level.\n")
  cat("\\end{tablenotes}\n")
  cat("\\end{table}\n")
  sink()

  cat("Saved figures/tab4_robustness.tex\n")
}

cat("\nAll tables generated successfully.\n")
