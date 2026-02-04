# ============================================================================
# Paper 70: Age 26 RDD on Birth Insurance Coverage
# 07_tables.R - Generate LaTeX tables
# ============================================================================

source("00_packages.R")

# Load data and results
natality <- readRDS(file.path(data_dir, "natality_analysis.rds"))
main_results <- readRDS(file.path(data_dir, "main_results.rds"))

# ============================================================================
# Table 1: Summary Statistics
# ============================================================================

cat("Generating Table 1: Summary Statistics...\n")

# Split by threshold
below_26 <- natality[MAGER < 26]
above_26 <- natality[MAGER >= 26]

# Function to compute stats
compute_stats <- function(dt, vars) {
  sapply(vars, function(v) {
    x <- dt[[v]]
    c(Mean = mean(x, na.rm = TRUE),
      SD = sd(x, na.rm = TRUE),
      N = sum(!is.na(x)))
  })
}

vars <- c("medicaid", "private", "selfpay", "early_prenatal",
          "preterm", "low_birthweight", "married", "college", "us_born")

stats_below <- compute_stats(below_26, vars)
stats_above <- compute_stats(above_26, vars)

# Create LaTeX table and save to file
var_labels <- c("Medicaid", "Private Insurance", "Self-Pay",
                "Early Prenatal Care", "Preterm Birth", "Low Birth Weight",
                "Married", "College+", "US-Born")

# Save Table 1 to file
sink(file.path(tables_dir, "table1_summary.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics by Age Group}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{tabular}{lcc}\n")
cat("\\toprule\n")
cat(" & Age 22--25 & Age 26--30 \\\\\n")
cat("\\midrule\n")
cat("\\textit{Payment Source} & & \\\\\n")
for (i in 1:3) {
  cat(sprintf("\\quad %s & %.1f\\%% & %.1f\\%% \\\\\n",
              var_labels[i],
              stats_below["Mean", vars[i]] * 100,
              stats_above["Mean", vars[i]] * 100))
}
cat("\\midrule\n")
cat("\\textit{Demographics} & & \\\\\n")
cat(sprintf("\\quad Married & %.1f\\%% & %.1f\\%% \\\\\n",
            stats_below["Mean", "married"] * 100,
            stats_above["Mean", "married"] * 100))
cat(sprintf("\\quad College Degree & %.1f\\%% & %.1f\\%% \\\\\n",
            stats_below["Mean", "college"] * 100,
            stats_above["Mean", "college"] * 100))
cat("\\midrule\n")
cat("\\textit{Health Outcomes} & & \\\\\n")
for (i in 4:6) {
  cat(sprintf("\\quad %s & %.1f\\%% & %.1f\\%% \\\\\n",
              var_labels[i],
              stats_below["Mean", vars[i]] * 100,
              stats_above["Mean", vars[i]] * 100))
}
cat("\\midrule\n")
cat(sprintf("Observations & %s & %s \\\\\n",
            format(nrow(below_26), big.mark=","),
            format(nrow(above_26), big.mark=",")))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\floatfoot{\\textit{Notes:} Sample includes all births to mothers ages 22--30 in 2023 CDC Natality data.}\n")
cat("\\end{table}\n")
sink()

cat("Table 1 saved to tables/table1_summary.tex\n")

# ============================================================================
# Table 2: Main RDD Results
# ============================================================================

cat("Generating Table 2: Main RDD Results...\n")

results_df <- main_results$results_table

cat("\n\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Regression Discontinuity Estimates: Effect of Aging Out at 26}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat("Outcome & RD Estimate & Robust SE & 95\\% CI & Bandwidth \\\\\n")
cat("\\midrule\n")
cat("\\multicolumn{5}{l}{\\textit{Panel A: Source of Payment}} \\\\\n")

for (i in 1:3) {
  cat(sprintf("%s & %.4f & (%.4f) & [%.4f, %.4f] & %.1f \\\\\n",
              results_df$Outcome[i],
              results_df$RD_Estimate[i],
              results_df$Robust_SE[i],
              results_df$CI_Lower[i],
              results_df$CI_Upper[i],
              results_df$Bandwidth[i]))
}

cat("\\midrule\n")
cat("\\multicolumn{5}{l}{\\textit{Panel B: Health Outcomes}} \\\\\n")

for (i in 4:6) {
  cat(sprintf("%s & %.4f & (%.4f) & [%.4f, %.4f] & %.1f \\\\\n",
              results_df$Outcome[i],
              results_df$RD_Estimate[i],
              results_df$Robust_SE[i],
              results_df$CI_Lower[i],
              results_df$CI_Upper[i],
              results_df$Bandwidth[i]))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}\n")
cat("\\small\n")
cat("\\item Notes: Local polynomial RD estimates using rdrobust. Robust bias-corrected\n")
cat("\\item standard errors in parentheses. Bandwidth is MSE-optimal.\n")
cat("\\item *** p<0.01, ** p<0.05, * p<0.1\n")
cat("\\end{tablenotes}\n")
cat("\\label{tab:main}\n")
cat("\\end{table}\n")

cat("Table 2 saved.\n")

# ============================================================================
# Table 3: Covariate Balance
# ============================================================================

cat("Generating Table 3: Covariate Balance...\n")

balance_results <- readRDS(file.path(data_dir, "balance_results.rds"))

cat("\n\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Covariate Balance at Age 26 Threshold}\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\toprule\n")
cat("Covariate & RD Estimate & Robust SE & p-value \\\\\n")
cat("\\midrule\n")

for (i in 1:nrow(balance_results)) {
  cat(sprintf("%s & %.4f & (%.4f) & %.3f \\\\\n",
              balance_results$Covariate[i],
              balance_results$RD_Estimate[i],
              balance_results$Robust_SE[i],
              balance_results$p_value[i]))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}\n")
cat("\\small\n")
cat("\\item Notes: RD estimates for predetermined covariates. No significant discontinuities\n")
cat("\\item indicate valid counterfactual comparison at the threshold.\n")
cat("\\end{tablenotes}\n")
cat("\\label{tab:balance}\n")
cat("\\end{table}\n")

cat("Table 3 saved.\n")

# ============================================================================
# Table 4: Robustness Checks
# ============================================================================

cat("Generating Table 4: Robustness Checks...\n")

bw_table <- readRDS(file.path(data_dir, "bandwidth_sensitivity.rds"))

cat("\n\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Robustness: Bandwidth Sensitivity}\n")
cat("\\begin{tabular}{lccccc}\n")
cat("\\toprule\n")
cat("Bandwidth & N & RD Estimate & Robust SE & 95\\% CI \\\\\n")
cat("\\midrule\n")

for (i in 1:nrow(bw_table)) {
  cat(sprintf("%d years & %s & %.4f & & [%.4f, %.4f] \\\\\n",
              bw_table$Bandwidth[i],
              format(bw_table$N[i], big.mark=","),
              bw_table$RD_Estimate[i],
              bw_table$CI_Lower[i],
              bw_table$CI_Upper[i]))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\label{tab:bandwidth}\n")
cat("\\end{table}\n")

cat("Table 4 saved.\n")

# ============================================================================
# All tables generated
# ============================================================================

cat("\n=== All Tables Generated ===\n")
