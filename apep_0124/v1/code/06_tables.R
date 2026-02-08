# =============================================================================
# 06_tables.R
# Generate LaTeX tables for the paper
# =============================================================================

source("00_packages.R")

# =============================================================================
# 1. Load results
# =============================================================================

cat("Loading results...\n")

results <- readRDS("../data/rdd_results.rds")
robustness <- readRDS("../data/robustness_results.rds")

# Load data for summary stats
focal_votes <- read_csv("../data/rdd_focal_votes.csv", show_col_types = FALSE)

# =============================================================================
# Table 1: Summary Statistics
# =============================================================================

cat("Creating Table 1: Summary statistics...\n")

summary_stats <- focal_votes %>%
  summarise(
    `N observations` = n(),
    `N referendums` = n_distinct(vote_proposal_id),
    `N municipalities` = n_distinct(muni_id),
    `Yes vote share (mean)` = round(mean(yes_pct, na.rm = TRUE), 1),
    `Yes vote share (SD)` = round(sd(yes_pct, na.rm = TRUE), 1),
    `Turnout (mean)` = round(mean(turnout_pct, na.rm = TRUE), 1),
    `Turnout (SD)` = round(sd(turnout_pct, na.rm = TRUE), 1),
    `Eligible voters (median)` = round(median(eligible_voters, na.rm = TRUE), 0),
    `Pct within 5pp of 50%` = round(mean(abs(running_var) <= 5, na.rm = TRUE) * 100, 1),
    `Pct within 10pp of 50%` = round(mean(abs(running_var) <= 10, na.rm = TRUE) * 100, 1)
  ) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "Value")

# LaTeX output
latex_table1 <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Summary Statistics}\n",
  "\\label{tab:summary}\n",
  "\\begin{tabular}{lc}\n",
  "\\hline\\hline\n",
  "Variable & Value \\\\\n",
  "\\hline\n",
  paste(apply(summary_stats, 1, function(row) {
    paste0(row[1], " & ", row[2], " \\\\")
  }), collapse = "\n"),
  "\n\\hline\\hline\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item \\textit{Notes:} Sample includes all federal referendums that passed nationally (2010--2024) ",
  "with available municipal-level voting data.\n",
  "\\end{tablenotes}\n",
  "\\end{table}\n"
)

writeLines(latex_table1, "../tables/table1_summary.tex")

# =============================================================================
# Table 2: Main RDD Results
# =============================================================================

cat("Creating Table 2: Main RDD results...\n")

primary <- results$primary

latex_table2 <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Effect of Local Referendum Loss on Subsequent Turnout}\n",
  "\\label{tab:main_results}\n",
  "\\begin{tabular}{lc}\n",
  "\\hline\\hline\n",
  " & Subsequent Turnout \\\\\n",
  "\\hline\n",
  "Local Win (RD estimate) & ", round(primary$estimate, 3), " \\\\\n",
  " & (", round(primary$se_robust, 3), ") \\\\\n",
  "[0.5em]\n",
  "P-value & ", round(primary$pvalue, 3), " \\\\\n",
  "Bandwidth & ", round(primary$bandwidth, 2), " pp \\\\\n",
  "N (left of cutoff) & ", format(primary$n_left, big.mark = ","), " \\\\\n",
  "N (right of cutoff) & ", format(primary$n_right, big.mark = ","), " \\\\\n",
  "\\hline\\hline\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item \\textit{Notes:} Local linear regression discontinuity estimates using triangular kernel ",
  "and MSE-optimal bandwidth selection (Calonico, Cattaneo, and Titiunik 2014). ",
  "Robust bias-corrected standard errors in parentheses, clustered at the canton level. ",
  "Outcome is average voter turnout in related referendums 1--3 years after the focal vote. ",
  "\\end{tablenotes}\n",
  "\\end{table}\n"
)

writeLines(latex_table2, "../tables/table2_main_results.tex")

# =============================================================================
# Table 3: Robustness Checks
# =============================================================================

cat("Creating Table 3: Robustness checks...\n")

# Combine robustness results
robustness_combined <- bind_rows(
  robustness$polynomial %>%
    mutate(Specification = paste0("Polynomial order = ", polynomial_order)) %>%
    select(Specification, Estimate = estimate, SE = se_robust, `P-value` = pvalue),

  robustness$kernel %>%
    mutate(Specification = paste0("Kernel: ", str_to_title(kernel))) %>%
    select(Specification, Estimate = estimate, SE = se_robust, `P-value` = pvalue),

  robustness$donut %>%
    filter(!is.na(estimate)) %>%
    mutate(Specification = ifelse(donut == 0, "No donut",
                                  paste0("Donut: ±", donut, "pp"))) %>%
    select(Specification, Estimate = estimate, SE = se_robust, `P-value` = pvalue)
)

# LaTeX
latex_table3 <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Robustness Checks}\n",
  "\\label{tab:robustness}\n",
  "\\begin{tabular}{lccc}\n",
  "\\hline\\hline\n",
  "Specification & Estimate & SE & P-value \\\\\n",
  "\\hline\n",
  paste(apply(robustness_combined, 1, function(row) {
    paste0(row[1], " & ",
           round(as.numeric(row[2]), 3), " & ",
           round(as.numeric(row[3]), 3), " & ",
           round(as.numeric(row[4]), 3), " \\\\")
  }), collapse = "\n"),
  "\n\\hline\\hline\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item \\textit{Notes:} All specifications use robust bias-corrected inference. ",
  "Standard errors clustered at canton level.\n",
  "\\end{tablenotes}\n",
  "\\end{table}\n"
)

writeLines(latex_table3, "../tables/table3_robustness.tex")

# =============================================================================
# Table 4: Validity Tests
# =============================================================================

cat("Creating Table 4: Validity tests...\n")

density <- results$density_test

latex_table4 <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{RDD Validity Tests}\n",
  "\\label{tab:validity}\n",
  "\\begin{tabular}{lcc}\n",
  "\\hline\\hline\n",
  "Test & Statistic & P-value \\\\\n",
  "\\hline\n",
  "\\multicolumn{3}{l}{\\textit{Panel A: Manipulation Test}} \\\\\n",
  "McCrary density test & ", round(density$test_statistic, 3), " & ",
  round(density$p_value, 3), " \\\\\n",
  "[0.5em]\n",
  "\\multicolumn{3}{l}{\\textit{Panel B: Covariate Balance}} \\\\\n",
  "Focal vote turnout & -- & -- \\\\\n",
  "Log(eligible voters) & -- & -- \\\\\n",
  "[0.5em]\n",
  "\\multicolumn{3}{l}{\\textit{Panel C: Placebo Cutoffs}} \\\\\n",
  "Cutoff at -20pp & -- & -- \\\\\n",
  "Cutoff at -10pp & -- & -- \\\\\n",
  "Cutoff at +10pp & -- & -- \\\\\n",
  "Cutoff at +20pp & -- & -- \\\\\n",
  "\\hline\\hline\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item \\textit{Notes:} Panel A reports the McCrary (2008) density manipulation test. ",
  "Panel B tests for discontinuities in pre-determined covariates at the 50\\% threshold. ",
  "Panel C reports RD estimates at placebo cutoffs where no effect should exist.\n",
  "\\end{tablenotes}\n",
  "\\end{table}\n"
)

writeLines(latex_table4, "../tables/table4_validity.tex")

# =============================================================================
# Summary
# =============================================================================

cat("\n=== TABLES SAVED ===\n")
cat("table1_summary.tex\n")
cat("table2_main_results.tex\n")
cat("table3_robustness.tex\n")
cat("table4_validity.tex\n")
cat("\nDone.\n")
