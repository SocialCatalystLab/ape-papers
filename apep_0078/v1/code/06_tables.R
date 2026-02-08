# ============================================================================
# 06_tables.R
# State Minimum Wage and Business Formation
# Generate summary statistics and formatted tables
# ============================================================================

source("00_packages.R")

data_dir <- "../data/"
tables_dir <- "../tables/"

# ============================================================================
# 1. Load data
# ============================================================================

cat("Loading data...\n")

analysis_panel <- read_csv(paste0(data_dir, "analysis_panel.csv"), show_col_types = FALSE)
treatment_timing <- read_csv(paste0(data_dir, "treatment_timing.csv"), show_col_types = FALSE)

# ============================================================================
# Table 1: Summary Statistics
# ============================================================================

cat("Creating Table 1: Summary Statistics...\n")

# Main outcomes
summary_outcomes <- analysis_panel %>%
  summarize(
    `Business Applications` = mean(BA, na.rm = TRUE),
    `High-Propensity Applications` = mean(HBA, na.rm = TRUE),
    `Applications w/ Planned Wages` = mean(WBA, na.rm = TRUE)
  ) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "Mean")

summary_outcomes_sd <- analysis_panel %>%
  summarize(
    `Business Applications` = sd(BA, na.rm = TRUE),
    `High-Propensity Applications` = sd(HBA, na.rm = TRUE),
    `Applications w/ Planned Wages` = sd(WBA, na.rm = TRUE)
  ) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "SD")

# Treatment variables
summary_treatment <- analysis_panel %>%
  summarize(
    `Effective MW (Nominal $)` = mean(effective_mw, na.rm = TRUE),
    `Real MW (2020 $)` = mean(real_mw, na.rm = TRUE),
    `Above Federal (%)` = mean(above_federal, na.rm = TRUE) * 100
  ) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "Mean")

summary_treatment_sd <- analysis_panel %>%
  summarize(
    `Effective MW (Nominal $)` = sd(effective_mw, na.rm = TRUE),
    `Real MW (2020 $)` = sd(real_mw, na.rm = TRUE),
    `Above Federal (%)` = sd(above_federal, na.rm = TRUE) * 100
  ) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "SD")

# Combine
summary_stats <- bind_rows(summary_outcomes, summary_treatment) %>%
  left_join(bind_rows(summary_outcomes_sd, summary_treatment_sd), by = "Variable") %>%
  mutate(
    Min = c(
      min(analysis_panel$BA, na.rm = TRUE),
      min(analysis_panel$HBA, na.rm = TRUE),
      min(analysis_panel$WBA, na.rm = TRUE),
      min(analysis_panel$effective_mw, na.rm = TRUE),
      min(analysis_panel$real_mw, na.rm = TRUE),
      0
    ),
    Max = c(
      max(analysis_panel$BA, na.rm = TRUE),
      max(analysis_panel$HBA, na.rm = TRUE),
      max(analysis_panel$WBA, na.rm = TRUE),
      max(analysis_panel$effective_mw, na.rm = TRUE),
      max(analysis_panel$real_mw, na.rm = TRUE),
      100
    )
  )

print(summary_stats)

# Save as CSV
write_csv(summary_stats, paste0(tables_dir, "summary_stats.csv"))

# Create LaTeX table
sink(paste0(tables_dir, "summary_stats.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics}\n")
cat("\\label{tab:summary_stats}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat("Variable & Mean & SD & Min & Max \\\\\n")
cat("\\midrule\n")
cat("\\multicolumn{5}{l}{\\textit{Panel A: Outcome Variables (Monthly, State-Level)}} \\\\\n")

for (i in 1:3) {
  cat(sprintf("%s & %.0f & %.0f & %.0f & %.0f \\\\\n",
      summary_stats$Variable[i],
      summary_stats$Mean[i],
      summary_stats$SD[i],
      summary_stats$Min[i],
      summary_stats$Max[i]))
}

cat("\\midrule\n")
cat("\\multicolumn{5}{l}{\\textit{Panel B: Treatment Variables}} \\\\\n")

for (i in 4:6) {
  cat(sprintf("%s & %.2f & %.2f & %.2f & %.2f \\\\\n",
      summary_stats$Variable[i],
      summary_stats$Mean[i],
      summary_stats$SD[i],
      summary_stats$Min[i],
      summary_stats$Max[i]))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}\n")
cat("\\small\n")
cat("\\item Notes: Sample includes 50 states plus DC, monthly observations from 2005-2023.\n")
cat(sprintf("\\item N = %s state-months.\n", format(nrow(analysis_panel), big.mark = ",")))
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

# ============================================================================
# Table 2: Minimum Wage Policy Details
# ============================================================================

cat("Creating Table 2: State Minimum Wage Policies...\n")

# Get current MW and treatment timing for each state
mw_policies <- analysis_panel %>%
  filter(year == 2023 & month == 12) %>%
  select(state_abbr, effective_mw, above_federal) %>%
  left_join(
    treatment_timing %>%
      mutate(first_year = year(first_treat_date)),
    by = "state_abbr"
  ) %>%
  arrange(desc(effective_mw)) %>%
  head(20)

print(mw_policies)
write_csv(mw_policies, paste0(tables_dir, "mw_policies.csv"))

# ============================================================================
# Table 3: Main Results (formatted)
# ============================================================================

cat("Creating Table 3: Main Results...\n")

# Load main results if they exist
if (file.exists(paste0(tables_dir, "main_results.csv"))) {
  main_results <- read_csv(paste0(tables_dir, "main_results.csv"), show_col_types = FALSE)

  sink(paste0(tables_dir, "main_results.tex"))
  cat("\\begin{table}[htbp]\n")
  cat("\\centering\n")
  cat("\\caption{Effect of Minimum Wage on Business Formation}\n")
  cat("\\label{tab:main_results}\n")
  cat("\\begin{tabular}{lcccc}\n")
  cat("\\toprule\n")
  cat(" & (1) & (2) & (3) & (4) \\\\\n")
  cat(" & Log(BA) & Log(BA) & Log(BA) & Log(BA) \\\\\n")
  cat("\\midrule\n")
  cat("\\multicolumn{5}{l}{\\textit{Panel A: Continuous Treatment}} \\\\\n")
  cat(sprintf("Log(Real MW) & %.4f%s & %.4f%s & & \\\\\n",
      main_results$coefficient[1], main_results$stars[1],
      main_results$coefficient[2], main_results$stars[2]))
  cat(sprintf(" & (%.4f) & (%.4f) & & \\\\\n",
      main_results$se[1], main_results$se[2]))
  cat("\\midrule\n")
  cat("\\multicolumn{5}{l}{\\textit{Panel B: Binary Treatment}} \\\\\n")
  cat(sprintf("Above Federal & & & %.4f%s & %.4f%s \\\\\n",
      main_results$coefficient[3], main_results$stars[3],
      main_results$coefficient[4], main_results$stars[4]))
  cat(sprintf(" & & & (%.4f) & (%.4f) \\\\\n",
      main_results$se[3], main_results$se[4]))
  cat("\\midrule\n")
  cat("State FE & Yes & Yes & Yes & Yes \\\\\n")
  cat("Year-Month FE & Yes & Yes & Yes & Yes \\\\\n")
  cat("State Trends & No & Yes & No & Yes \\\\\n")
  cat(sprintf("Observations & %s & %s & %s & %s \\\\\n",
      format(main_results$n_obs[1], big.mark = ","),
      format(main_results$n_obs[2], big.mark = ","),
      format(main_results$n_obs[3], big.mark = ","),
      format(main_results$n_obs[4], big.mark = ",")))
  cat("\\bottomrule\n")
  cat("\\end{tabular}\n")
  cat("\\begin{tablenotes}\n")
  cat("\\small\n")
  cat("\\item Notes: * p<0.1, ** p<0.05, *** p<0.01. Standard errors clustered at state level in parentheses.\n")
  cat("\\item Dependent variable is log(Business Applications + 1). Real minimum wage deflated using CPI-U (base = Jan 2020).\n")
  cat("\\end{tablenotes}\n")
  cat("\\end{table}\n")
  sink()
}

# ============================================================================
# Table 4: Heterogeneity by Outcome Type
# ============================================================================

cat("Creating Table 4: Heterogeneity...\n")

# Run regressions for each outcome (if not already done)
analysis_panel <- analysis_panel %>%
  mutate(
    state_fe = as.factor(state_abbr),
    ym_fe = as.factor(ym)
  )

m_ba <- feols(log_BA ~ log_real_mw | state_fe + ym_fe, data = analysis_panel, cluster = ~state_abbr)
m_hba <- feols(log_HBA ~ log_real_mw | state_fe + ym_fe, data = analysis_panel, cluster = ~state_abbr)
m_wba <- feols(log_WBA ~ log_real_mw | state_fe + ym_fe, data = analysis_panel, cluster = ~state_abbr)

hetero_table <- tibble(
  Outcome = c("All Applications (BA)", "High-Propensity (HBA)", "With Planned Wages (WBA)"),
  Coefficient = c(coef(m_ba)["log_real_mw"], coef(m_hba)["log_real_mw"], coef(m_wba)["log_real_mw"]),
  SE = c(se(m_ba)["log_real_mw"], se(m_hba)["log_real_mw"], se(m_wba)["log_real_mw"]),
  N = c(nobs(m_ba), nobs(m_hba), nobs(m_wba))
) %>%
  mutate(
    t_stat = Coefficient / SE,
    p_value = 2 * (1 - pnorm(abs(t_stat))),
    stars = case_when(
      p_value < 0.01 ~ "***",
      p_value < 0.05 ~ "**",
      p_value < 0.1 ~ "*",
      TRUE ~ ""
    )
  )

print(hetero_table)
write_csv(hetero_table, paste0(tables_dir, "heterogeneity.csv"))

sink(paste0(tables_dir, "heterogeneity.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Effect of Minimum Wage by Application Type}\n")
cat("\\label{tab:heterogeneity}\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\toprule\n")
cat("Outcome & Coefficient & SE & N \\\\\n")
cat("\\midrule\n")

for (i in 1:nrow(hetero_table)) {
  cat(sprintf("%s & %.4f%s & (%.4f) & %s \\\\\n",
      hetero_table$Outcome[i],
      hetero_table$Coefficient[i],
      hetero_table$stars[i],
      hetero_table$SE[i],
      format(hetero_table$N[i], big.mark = ",")))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}\n")
cat("\\small\n")
cat("\\item Notes: * p<0.1, ** p<0.05, *** p<0.01. All specifications include state and year-month FE.\n")
cat("\\item Standard errors clustered at state level. HBA = applications likely to become employers.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

cat("\nAll tables saved to: ", tables_dir, "\n")
