# ============================================================================
# Paper 70: Age 26 RDD on Birth Insurance Coverage
# 08_tables.R - Generate LaTeX tables
# ============================================================================

source("00_packages.R")

# Create tables directory
table_dir <- file.path(dirname(data_dir), "tables")
dir.create(table_dir, showWarnings = FALSE)

# ============================================================================
# Table 1: Summary Statistics
# ============================================================================

natality <- readRDS(file.path(data_dir, "natality_analysis.rds"))
natality[, above26 := MAGER >= 26]

# Calculate means by group
summary_stats <- natality[, .(
  N = .N,
  Medicaid = mean(medicaid, na.rm = TRUE),
  Private = mean(private, na.rm = TRUE),
  SelfPay = mean(selfpay, na.rm = TRUE),
  Married = mean(married, na.rm = TRUE),
  College = mean(college, na.rm = TRUE),
  EarlyPrenatal = mean(early_prenatal, na.rm = TRUE),
  Preterm = mean(preterm, na.rm = TRUE),
  LowBirthWeight = mean(low_birthweight, na.rm = TRUE)
), by = above26]

# Format as LaTeX table
sink(file.path(table_dir, "table1_summary.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics by Age Group}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{tabular}{lcc}\n")
cat("\\toprule\n")
cat(" & Age 22--25 & Age 26--30 \\\\\n")
cat("\\midrule\n")
cat("\\textit{Payment Source} & & \\\\\n")
cat(sprintf("\\quad Medicaid & %.1f\\%% & %.1f\\%% \\\\\n",
            summary_stats[above26 == FALSE, Medicaid * 100],
            summary_stats[above26 == TRUE, Medicaid * 100]))
cat(sprintf("\\quad Private Insurance & %.1f\\%% & %.1f\\%% \\\\\n",
            summary_stats[above26 == FALSE, Private * 100],
            summary_stats[above26 == TRUE, Private * 100]))
cat(sprintf("\\quad Self-Pay & %.1f\\%% & %.1f\\%% \\\\\n",
            summary_stats[above26 == FALSE, SelfPay * 100],
            summary_stats[above26 == TRUE, SelfPay * 100]))
cat("\\midrule\n")
cat("\\textit{Demographics} & & \\\\\n")
cat(sprintf("\\quad Married & %.1f\\%% & %.1f\\%% \\\\\n",
            summary_stats[above26 == FALSE, Married * 100],
            summary_stats[above26 == TRUE, Married * 100]))
cat(sprintf("\\quad College Degree & %.1f\\%% & %.1f\\%% \\\\\n",
            summary_stats[above26 == FALSE, College * 100],
            summary_stats[above26 == TRUE, College * 100]))
cat("\\midrule\n")
cat("\\textit{Health Outcomes} & & \\\\\n")
cat(sprintf("\\quad Early Prenatal Care & %.1f\\%% & %.1f\\%% \\\\\n",
            summary_stats[above26 == FALSE, EarlyPrenatal * 100],
            summary_stats[above26 == TRUE, EarlyPrenatal * 100]))
cat(sprintf("\\quad Preterm Birth & %.1f\\%% & %.1f\\%% \\\\\n",
            summary_stats[above26 == FALSE, Preterm * 100],
            summary_stats[above26 == TRUE, Preterm * 100]))
cat(sprintf("\\quad Low Birth Weight & %.1f\\%% & %.1f\\%% \\\\\n",
            summary_stats[above26 == FALSE, LowBirthWeight * 100],
            summary_stats[above26 == TRUE, LowBirthWeight * 100]))
cat("\\midrule\n")
cat(sprintf("Observations & %s & %s \\\\\n",
            format(summary_stats[above26 == FALSE, N], big.mark = ","),
            format(summary_stats[above26 == TRUE, N], big.mark = ",")))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\floatfoot{\\textit{Notes:} Sample includes all births to mothers ages 22--30 in 2023 CDC Natality data.}\n")
cat("\\end{table}\n")
sink()

cat("Table 1 saved.\n")

# ============================================================================
# Table 2: Main RDD Results
# ============================================================================

results <- readRDS(file.path(data_dir, "rd_results.rds"))

sink(file.path(table_dir, "table2_main.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Main RDD Results: Effect of Age 26 Threshold on Payment Source and Health}\n")
cat("\\label{tab:main}\n")
cat("\\begin{tabular}{lccccc}\n")
cat("\\toprule\n")
cat("Outcome & RD Estimate & SE & 95\\% CI & p-value & N \\\\\n")
cat("\\midrule\n")
cat("\\textit{Payment Source} & & & & & \\\\\n")

for (i in 1:3) {
  outcome <- results$Outcome[i]
  est <- sprintf("%.3f", results$RD_Estimate[i])
  se <- sprintf("(%.3f)", results$SE[i])
  ci <- sprintf("[%.3f, %.3f]", results$CI_Lower[i], results$CI_Upper[i])
  pval <- ifelse(results$p_value[i] < 0.001, "$<$0.001", sprintf("%.3f", results$p_value[i]))
  n <- format(results$N[i], big.mark = ",")

  cat(sprintf("\\quad %s & %s & %s & %s & %s & %s \\\\\n",
              outcome, est, se, ci, pval, n))
}

cat("\\midrule\n")
cat("\\textit{Health Outcomes} & & & & & \\\\\n")

for (i in 4:6) {
  outcome <- results$Outcome[i]
  est <- sprintf("%.3f", results$RD_Estimate[i])
  se <- sprintf("(%.3f)", results$SE[i])
  ci <- sprintf("[%.3f, %.3f]", results$CI_Lower[i], results$CI_Upper[i])
  pval <- ifelse(results$p_value[i] < 0.001, "$<$0.001", sprintf("%.3f", results$p_value[i]))
  n <- format(results$N[i], big.mark = ",")

  cat(sprintf("\\quad %s & %s & %s & %s & %s & %s \\\\\n",
              outcome, est, se, ci, pval, n))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\floatfoot{\\textit{Notes:} RD estimates from local linear regression with bandwidth of 4 years and heteroskedasticity-robust standard errors. * p$<$0.05, ** p$<$0.01, *** p$<$0.001.}\n")
cat("\\end{table}\n")
sink()

cat("Table 2 saved.\n")

# ============================================================================
# Table 3: Balance Tests
# ============================================================================

balance <- readRDS(file.path(data_dir, "balance_results.rds"))

sink(file.path(table_dir, "table3_balance.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Covariate Balance Tests}\n")
cat("\\label{tab:balance}\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\toprule\n")
cat("Covariate & RD Estimate & Robust SE & p-value \\\\\n")
cat("\\midrule\n")

for (i in 1:nrow(balance)) {
  if (is.na(balance$RD_Estimate[i])) {
    cat(sprintf("%s & -- & -- & -- \\\\\n", balance$Covariate[i]))
  } else {
    est <- sprintf("%.4f", balance$RD_Estimate[i])
    se <- sprintf("(%.4f)", balance$Robust_SE[i])
    pval <- ifelse(balance$p_value[i] < 0.001, "$<$0.001", sprintf("%.3f", balance$p_value[i]))
    sig <- balance$Significant[i]
    cat(sprintf("%s & %s%s & %s & %s \\\\\n", balance$Covariate[i], est, sig, se, pval))
  }
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\floatfoot{\\textit{Notes:} RD estimates for predetermined covariates using local linear regression with bandwidth of 4 years. * indicates p$<$0.05.}\n")
cat("\\end{table}\n")
sink()

cat("Table 3 saved.\n")

# ============================================================================
# Table 4: Placebo Tests
# ============================================================================

placebo <- readRDS(file.path(data_dir, "placebo_results.rds"))

sink(file.path(table_dir, "table4_placebo.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Placebo Cutoff Tests}\n")
cat("\\label{tab:placebo}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat("Cutoff Age & RD Estimate & Robust SE & p-value & Significant \\\\\n")
cat("\\midrule\n")

for (i in 1:nrow(placebo)) {
  cutoff <- placebo$Cutoff[i]
  est <- sprintf("%.4f", placebo$RD_Estimate[i])
  se <- sprintf("(%.4f)", placebo$Robust_SE[i])
  pval <- ifelse(placebo$p_value[i] < 0.001, "$<$0.001", sprintf("%.3f", placebo$p_value[i]))
  sig <- ifelse(cutoff == 26, "\\textbf{Policy}", placebo$Significant[i])

  if (cutoff == 26) {
    cat(sprintf("\\textbf{%d} & \\textbf{%s} & \\textbf{%s} & \\textbf{%s} & %s \\\\\n",
                cutoff, est, se, pval, sig))
  } else {
    cat(sprintf("%d & %s & %s & %s & %s \\\\\n", cutoff, est, se, pval, sig))
  }
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\floatfoot{\\textit{Notes:} RD estimates for Medicaid outcome at each cutoff using local linear regression with bandwidth of 2 years. Age 26 (bold) is the policy-relevant cutoff; others are placebo tests.}\n")
cat("\\end{table}\n")
sink()

cat("Table 4 saved.\n")

# ============================================================================
# Table 5: Heterogeneity by Marital Status
# ============================================================================

het <- readRDS(file.path(data_dir, "heterogeneity_marital.rds"))

sink(file.path(table_dir, "table5_heterogeneity.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Heterogeneity in RDD Effect by Marital Status}\n")
cat("\\label{tab:heterogeneity}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat("Group & N & RD Estimate & SE & 95\\% CI \\\\\n")
cat("\\midrule\n")

for (i in 1:nrow(het)) {
  group <- het$Group[i]
  n <- format(het$N[i], big.mark = ",")
  est <- sprintf("%.3f", het$RD_Estimate[i])
  se <- sprintf("(%.3f)", het$SE[i])
  ci <- sprintf("[%.3f, %.3f]", het$CI_Lower[i], het$CI_Upper[i])

  cat(sprintf("%s & %s & %s & %s & %s \\\\\n", group, n, est, se, ci))
}

cat("\\midrule\n")
cat(sprintf("Difference & & %.3f & & \\\\\n",
            het$RD_Estimate[het$Group == "Unmarried"] - het$RD_Estimate[het$Group == "Married"]))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\floatfoot{\\textit{Notes:} RD estimates for Medicaid outcome by marital status using local linear regression with bandwidth of 4 years.}\n")
cat("\\end{table}\n")
sink()

cat("Table 5 saved.\n")

cat("\nAll tables saved to:", table_dir, "\n")
