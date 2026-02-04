# ==============================================================================
# 06_tables.R
# Generate publication-quality tables
# Paper 154: The Insurance Value of Secondary Employment
# ==============================================================================

source("00_packages.R")

# Load data and results
cps <- readRDS(file.path(data_dir, "cps_with_pscore.rds"))
main_results <- readRDS(file.path(data_dir, "main_results.rds"))
mjh_comparison <- tryCatch(readRDS(file.path(data_dir, "mjh_comparison.rds")),
                           error = function(e) NULL)
stability_results <- tryCatch(readRDS(file.path(data_dir, "coefficient_stability.rds")),
                              error = function(e) NULL)
robustness_summary <- tryCatch(readRDS(file.path(data_dir, "robustness_summary.rds")),
                               error = function(e) NULL)

# ==============================================================================
# Table 1: Descriptive Statistics
# ==============================================================================

cat("Creating Table 1: Descriptive Statistics...\n")

# Overall statistics
overall_stats <- cps %>%
  summarise(
    N = n(),
    `Age (mean)` = sprintf("%.1f", weighted.mean(age, weight)),
    `Female (\\%)` = sprintf("%.1f", weighted.mean(female, weight) * 100),
    `College graduate (\\%)` = sprintf("%.1f", weighted.mean(college, weight) * 100),
    `Married (\\%)` = sprintf("%.1f", weighted.mean(married, weight) * 100),
    `Earnings (mean, \\$)` = sprintf("%s", scales::comma(weighted.mean(earnings, weight))),
    `Full-time (\\%)` = sprintf("%.1f", weighted.mean(full_time, weight) * 100),
    `Homeowner (\\%)` = sprintf("%.1f", weighted.mean(homeowner, weight) * 100),
    `Self-employed (\\%)` = sprintf("%.1f", weighted.mean(multiple_jobs, weight) * 100)
  ) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "Overall")

# By MJH status
mjh_stats <- cps %>%
  group_by(multiple_jobs) %>%
  summarise(
    N = n(),
    `Age (mean)` = sprintf("%.1f", weighted.mean(age, weight)),
    `Female (\\%)` = sprintf("%.1f", weighted.mean(female, weight) * 100),
    `College graduate (\\%)` = sprintf("%.1f", weighted.mean(college, weight) * 100),
    `Married (\\%)` = sprintf("%.1f", weighted.mean(married, weight) * 100),
    `Earnings (mean, \\$)` = sprintf("%s", scales::comma(weighted.mean(earnings, weight))),
    `Full-time (\\%)` = sprintf("%.1f", weighted.mean(full_time, weight) * 100),
    `Homeowner (\\%)` = sprintf("%.1f", weighted.mean(homeowner, weight) * 100),
    .groups = "drop"
  ) %>%
  pivot_longer(-multiple_jobs, names_to = "Variable", values_to = "value") %>%
  pivot_wider(names_from = multiple_jobs, values_from = value,
              names_prefix = "MJH_")

# Combine
table1 <- overall_stats %>%
  left_join(mjh_stats, by = "Variable") %>%
  rename(`Single Job` = MJH_0, `Multiple Jobs` = MJH_1)

# LaTeX output
table1_latex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Summary Statistics}\n",
  "\\label{tab:summary_stats}\n",
  "\\begin{tabular}{lccc}\n",
  "\\hline\\hline\n",
  " & Overall & Single Job & Multiple Jobs \\\\\n",
  "\\hline\n"
)

for (i in 1:nrow(table1)) {
  table1_latex <- paste0(table1_latex,
                         table1$Variable[i], " & ",
                         table1$Overall[i], " & ",
                         table1$`Single Job`[i], " & ",
                         table1$`Multiple Jobs`[i], " \\\\\n")
}

table1_latex <- paste0(
  table1_latex,
  "\\hline\\hline\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item \\textit{Notes:} Sample includes employed workers aged 25-54 from the CPS ASEC, 2015-2024. ",
  "Earnings and percentages are weighted using CPS survey weights.\n",
  "\\end{tablenotes}\n",
  "\\end{table}\n"
)

writeLines(table1_latex, file.path(table_dir, "table1_summary.tex"))

# ==============================================================================
# Table 2: Main Results
# ==============================================================================

cat("Creating Table 2: Main Results...\n")

table2_latex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Effect of Multiple Job Holding on Labor Market Outcomes}\n",
  "\\label{tab:main_results}\n",
  "\\begin{tabular}{lcccc}\n",
  "\\hline\\hline\n",
  "Outcome & Estimate & SE & 95\\% CI & p-value \\\\\n",
  "\\hline\n"
)

for (i in 1:nrow(main_results)) {
  ci_str <- sprintf("[%.4f, %.4f]", main_results$ci_lower[i], main_results$ci_upper[i])
  p_str <- ifelse(main_results$p_value[i] < 0.001, "$<$0.001",
                  sprintf("%.3f", main_results$p_value[i]))

  table2_latex <- paste0(
    table2_latex,
    main_results$outcome[i], " & ",
    sprintf("%.4f", main_results$estimate[i]), " & ",
    sprintf("%.4f", main_results$se[i]), " & ",
    ci_str, " & ",
    p_str, " \\\\\n"
  )
}

table2_latex <- paste0(
  table2_latex,
  "\\hline\n",
  "N & \\multicolumn{4}{c}{", scales::comma(nrow(cps)), "} \\\\\n",
  "\\hline\\hline\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item \\textit{Notes:} Estimates from augmented inverse probability weighting (AIPW) with 5-fold cross-fitting. ",
  "Covariates include age, sex, education, marital status, race, homeownership, metropolitan status, ",
  "occupation category, and COVID period indicator. Standard errors are influence-function based.\n",
  "\\end{tablenotes}\n",
  "\\end{table}\n"
)

writeLines(table2_latex, file.path(table_dir, "table2_main_results.tex"))

# ==============================================================================
# Table 3: Robustness Checks
# ==============================================================================

cat("Creating Table 3: Robustness Checks...\n")

if (!is.null(robustness_summary)) {
  table3_latex <- paste0(
    "\\begin{table}[htbp]\n",
    "\\centering\n",
    "\\caption{Robustness Checks for Self-Employment Outcome}\n",
    "\\label{tab:robustness}\n",
    "\\begin{tabular}{lcc}\n",
    "\\hline\\hline\n",
    "Specification & Estimate & Interpretation \\\\\n",
    "\\hline\n"
  )

  for (i in 1:nrow(robustness_summary)) {
    table3_latex <- paste0(
      table3_latex,
      robustness_summary$check[i], " & ",
      sprintf("%.4f", robustness_summary$estimate[i]), " & ",
      robustness_summary$interpretation[i], " \\\\\n"
    )
  }

  table3_latex <- paste0(
    table3_latex,
    "\\hline\\hline\n",
    "\\end{tabular}\n",
    "\\begin{tablenotes}[flushleft]\n",
    "\\small\n",
    "\\item \\textit{Notes:} All specifications estimate the effect of multiple job holding on self-employment. ",
    "Pre-COVID excludes 2020-2021. Trimming drops observations with extreme propensity scores. ",
    "The negative control (homeownership) should show a near-zero coefficient if conditional independence holds.\n",
    "\\end{tablenotes}\n",
    "\\end{table}\n"
  )

  writeLines(table3_latex, file.path(table_dir, "table3_robustness.tex"))
}

# ==============================================================================
# Table 4: Coefficient Stability (Oster Test)
# ==============================================================================

cat("Creating Table 4: Coefficient Stability...\n")

if (!is.null(stability_results)) {
  table4_latex <- paste0(
    "\\begin{table}[htbp]\n",
    "\\centering\n",
    "\\caption{Coefficient Stability Across Specifications}\n",
    "\\label{tab:stability}\n",
    "\\begin{tabular}{lcccc}\n",
    "\\hline\\hline\n",
    "Specification & \\# Covariates & Estimate & SE & $R^2$ \\\\\n",
    "\\hline\n"
  )

  for (i in 1:nrow(stability_results)) {
    table4_latex <- paste0(
      table4_latex,
      stability_results$specification[i], " & ",
      stability_results$n_covariates[i], " & ",
      sprintf("%.4f", stability_results$estimate[i]), " & ",
      sprintf("%.4f", stability_results$se[i]), " & ",
      sprintf("%.4f", stability_results$r_squared[i]), " \\\\\n"
    )
  }

  # Add Oster delta if available
  oster_delta <- stability_results$oster_delta[nrow(stability_results)]
  if (!is.na(oster_delta)) {
    oster_note <- sprintf("Oster (2019) $\\\\delta$: %.2f", oster_delta)
  } else {
    oster_note <- ""
  }

  table4_latex <- paste0(
    table4_latex,
    "\\hline\\hline\n",
    "\\end{tabular}\n",
    "\\begin{tablenotes}[flushleft]\n",
    "\\small\n",
    "\\item \\textit{Notes:} OLS estimates of the effect of multiple job holding on self-employment ",
    "with progressively richer covariate sets. ", oster_note,
    "\n\\end{tablenotes}\n",
    "\\end{table}\n"
  )

  writeLines(table4_latex, file.path(table_dir, "table4_stability.tex"))
}

# ==============================================================================
# Table 5: Propensity Score Summary
# ==============================================================================

cat("Creating Table 5: Propensity Score Diagnostics...\n")

ps_summary <- cps %>%
  group_by(Group = ifelse(multiple_jobs == 1, "Multiple Jobs", "Single Job")) %>%
  summarise(
    N = n(),
    `Mean P(X)` = sprintf("%.3f", mean(pscore, na.rm = TRUE)),
    `SD P(X)` = sprintf("%.3f", sd(pscore, na.rm = TRUE)),
    `Min P(X)` = sprintf("%.3f", min(pscore, na.rm = TRUE)),
    `Max P(X)` = sprintf("%.3f", max(pscore, na.rm = TRUE)),
    .groups = "drop"
  )

table5_latex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Propensity Score Distribution by Treatment Status}\n",
  "\\label{tab:pscore}\n",
  "\\begin{tabular}{lccccc}\n",
  "\\hline\\hline\n",
  "Group & N & Mean & SD & Min & Max \\\\\n",
  "\\hline\n"
)

for (i in 1:nrow(ps_summary)) {
  table5_latex <- paste0(
    table5_latex,
    ps_summary$Group[i], " & ",
    scales::comma(ps_summary$N[i]), " & ",
    ps_summary$`Mean P(X)`[i], " & ",
    ps_summary$`SD P(X)`[i], " & ",
    ps_summary$`Min P(X)`[i], " & ",
    ps_summary$`Max P(X)`[i], " \\\\\n"
  )
}

# Overlap statistics
overlap_pct <- mean(cps$pscore >= 0.01 & cps$pscore <= 0.99, na.rm = TRUE) * 100

table5_latex <- paste0(
  table5_latex,
  "\\hline\n",
  "\\multicolumn{6}{l}{Common support (0.01 $\\leq$ P(X) $\\leq$ 0.99): ",
  sprintf("%.1f", overlap_pct), "\\%} \\\\\n",
  "\\hline\\hline\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item \\textit{Notes:} Propensity scores estimated using logistic regression with demographic, ",
  "education, occupation, and geographic covariates.\n",
  "\\end{tablenotes}\n",
  "\\end{table}\n"
)

writeLines(table5_latex, file.path(table_dir, "table5_pscore.tex"))

# ==============================================================================
# Create combined tables file
# ==============================================================================

cat("\nCombining all tables...\n")

# Read all table files
table_files <- list.files(table_dir, pattern = "^table.*\\.tex$", full.names = TRUE)
all_tables <- paste(sapply(table_files, readLines), collapse = "\n\n")

writeLines(all_tables, file.path(table_dir, "all_tables.tex"))

cat("\n=== All Tables Created ===\n")
cat("Tables saved to:", table_dir, "\n")
