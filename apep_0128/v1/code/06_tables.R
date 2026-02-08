# ==============================================================================
# 06_tables.R
# Generate LaTeX tables for the paper
# ==============================================================================

source("00_packages.R")

# Load results
cat("Loading results for table generation...\n")
analysis_data <- readRDS("../data/processed/analysis_data.rds")
weights_df <- readRDS("../data/processed/synth_weights.rds")
estimates <- readRDS("../data/processed/estimates.rds")
results <- readRDS("../data/processed/synth_results.rds")
robustness <- readRDS("../data/processed/robustness.rds")
params <- readRDS("../data/processed/analysis_params.rds")

# Create tables directory
dir.create("../tables", recursive = TRUE, showWarnings = FALSE)

# ------------------------------------------------------------------------------
# Table 1: Summary Statistics
# ------------------------------------------------------------------------------
cat("Creating Table 1: Summary Statistics...\n")

# Pre-treatment statistics by country
pre_stats <- analysis_data %>%
  filter(!post) %>%
  group_by(country) %>%
  summarize(
    mean_hpi = mean(hpi_norm, na.rm = TRUE),
    sd_hpi = sd(hpi_norm, na.rm = TRUE),
    min_hpi = min(hpi_norm, na.rm = TRUE),
    max_hpi = max(hpi_norm, na.rm = TRUE),
    n_obs = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(mean_hpi))

# Full sample statistics
full_stats <- analysis_data %>%
  group_by(country) %>%
  summarize(
    mean_hpi = mean(hpi_norm, na.rm = TRUE),
    sd_hpi = sd(hpi_norm, na.rm = TRUE),
    n_obs = n(),
    .groups = "drop"
  )

# Create LaTeX table
table1_latex <- paste0(
"\\begin{table}[H]
\\centering
\\caption{Summary Statistics: Real House Price Index by Country}
\\label{tab:summary}
\\begin{threeparttable}
\\begin{tabular}{lrrrr}
\\toprule
Country & Mean & Std. Dev. & Min & Max \\\\
\\midrule
\\multicolumn{5}{l}{\\textit{Panel A: Pre-Treatment Period (2010Q1--2019Q1)}} \\\\[0.5ex]
",
paste(sprintf("%s & %.1f & %.1f & %.1f & %.1f \\\\",
              pre_stats$country, pre_stats$mean_hpi, pre_stats$sd_hpi,
              pre_stats$min_hpi, pre_stats$max_hpi), collapse = "\n"),
"
\\\\[1ex]
\\multicolumn{5}{l}{\\textit{Panel B: Summary}} \\\\[0.5ex]
Number of countries & \\multicolumn{4}{c}{", n_distinct(analysis_data$country), "} \\\\
Quarterly observations & \\multicolumn{4}{c}{", nrow(analysis_data), "} \\\\
Pre-treatment quarters & \\multicolumn{4}{c}{", params$n_pre_periods, "} \\\\
Post-treatment quarters & \\multicolumn{4}{c}{", params$n_post_periods, "} \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\small
\\item Notes: Real House Price Index from BIS via FRED, normalized to 2010Q1 = 100. Pre-treatment period is 2010Q1--2019Q1 (37 quarters). Post-treatment period is 2019Q2--2023Q4 (19 quarters). Treatment is the Dutch Council of State nitrogen ruling on May 29, 2019.
\\end{tablenotes}
\\end{threeparttable}
\\end{table}
")

writeLines(table1_latex, "../tables/tab1_summary.tex")

# ------------------------------------------------------------------------------
# Table 2: Synthetic Control Weights
# ------------------------------------------------------------------------------
cat("Creating Table 2: Synthetic Control Weights...\n")

table2_latex <- paste0(
"\\begin{table}[H]
\\centering
\\caption{Synthetic Control Weights}
\\label{tab:weights}
\\begin{threeparttable}
\\begin{tabular}{lr}
\\toprule
Country & Weight \\\\
\\midrule
",
paste(sprintf("%s & %.3f \\\\", weights_df$country, weights_df$weight), collapse = "\n"),
"
\\midrule
Total & ", sprintf("%.3f", sum(weights_df$weight)), " \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\small
\\item Notes: Weights estimated using non-negative least squares on pre-treatment outcomes (2010Q1--2019Q1), normalized to sum to 1. Only countries with weights $>$ 0.001 shown.
\\end{tablenotes}
\\end{threeparttable}
\\end{table}
")

writeLines(table2_latex, "../tables/tab2_weights.tex")

# ------------------------------------------------------------------------------
# Table 3: Main Results
# ------------------------------------------------------------------------------
cat("Creating Table 3: Main Results...\n")

table3_latex <- paste0(
"\\begin{table}[H]
\\centering
\\caption{Main Results: Effect of Nitrogen Ruling on Dutch House Prices}
\\label{tab:main}
\\begin{threeparttable}
\\begin{tabular}{lrr}
\\toprule
& Estimate & Std. Error \\\\
\\midrule
\\multicolumn{3}{l}{\\textit{Panel A: Pre-Treatment Fit (2010Q1--2019Q1)}} \\\\[0.5ex]
Mean Netherlands HPI & ", sprintf("%.2f", estimates$pre_fit$mean_nl), " & --- \\\\
Mean Synthetic HPI & ", sprintf("%.2f", estimates$pre_fit$mean_synth), " & --- \\\\
RMSE & ", sprintf("%.3f", estimates$pre_fit$rmse), " & --- \\\\
R-squared & ", sprintf("%.4f", estimates$pre_fit$r_squared), " & --- \\\\
\\\\[1ex]
\\multicolumn{3}{l}{\\textit{Panel B: Treatment Effect (2019Q2--2023Q4)}} \\\\[0.5ex]
Average Treatment Effect (ATT) & ", sprintf("%.3f", estimates$post_effect$att), " & ", sprintf("%.3f", estimates$post_effect$se), " \\\\
95\\% CI Lower & ", sprintf("%.3f", estimates$post_effect$ci_lower), " & --- \\\\
95\\% CI Upper & ", sprintf("%.3f", estimates$post_effect$ci_upper), " & --- \\\\
Effect as \\% of pre-treatment & ", sprintf("%.2f\\%%", estimates$post_effect$att / estimates$pre_fit$mean_nl * 100), " & --- \\\\
\\\\[1ex]
\\multicolumn{3}{l}{\\textit{Panel C: DiD Comparison}} \\\\[0.5ex]
Simple DiD Estimate & ", sprintf("%.2f", estimates$did_estimate), " & --- \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\small
\\item Notes: ATT is the average gap between Netherlands and synthetic control in the post-treatment period. Standard error computed as the standard deviation of quarterly gaps divided by $\\sqrt{n}$. DiD estimate uses simple average of donor countries as comparison group.
\\end{tablenotes}
\\end{threeparttable}
\\end{table}
")

writeLines(table3_latex, "../tables/tab3_main.tex")

# ------------------------------------------------------------------------------
# Table 4: Yearly Effects
# ------------------------------------------------------------------------------
cat("Creating Table 4: Yearly Effects...\n")

yearly <- estimates$yearly_effects

table4_latex <- paste0(
"\\begin{table}[H]
\\centering
\\caption{Treatment Effects by Year}
\\label{tab:yearly}
\\begin{threeparttable}
\\begin{tabular}{lrr}
\\toprule
Year & Mean Gap & Quarters \\\\
\\midrule
",
paste(sprintf("%d & %.2f & %d \\\\", yearly$year, yearly$mean_gap, yearly$n_quarters), collapse = "\n"),
"
\\midrule
Overall ATT & ", sprintf("%.2f", estimates$post_effect$att), " & ", sum(yearly$n_quarters), " \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\small
\\item Notes: Mean gap is the average difference between Netherlands and synthetic control (index points). Positive values indicate Netherlands HPI exceeded synthetic control.
\\end{tablenotes}
\\end{threeparttable}
\\end{table}
")

writeLines(table4_latex, "../tables/tab4_yearly.tex")

# ------------------------------------------------------------------------------
# Table 5: Robustness - Placebo Tests
# ------------------------------------------------------------------------------
cat("Creating Table 5: Placebo Tests...\n")

placebo <- robustness$placebo_summary %>%
  arrange(desc(abs(post_gap))) %>%
  head(10)

# Add Netherlands row
nl_row <- data.frame(
  country = "Netherlands (Treated)",
  pre_rmse = estimates$pre_fit$rmse,
  post_gap = estimates$post_effect$att,
  ratio = abs(estimates$post_effect$att) / estimates$pre_fit$rmse
)

table5_latex <- paste0(
"\\begin{table}[H]
\\centering
\\caption{Placebo Tests: In-Space Placebos}
\\label{tab:placebo}
\\begin{threeparttable}
\\begin{tabular}{lrrr}
\\toprule
Country & Pre-RMSE & Post-Gap & Ratio \\\\
\\midrule
\\textbf{Netherlands (Treated)} & \\textbf{", sprintf("%.2f", nl_row$pre_rmse), "} & \\textbf{", sprintf("%.2f", nl_row$post_gap), "} & \\textbf{", sprintf("%.2f", nl_row$ratio), "} \\\\[0.5ex]
",
paste(sprintf("%s & %.2f & %.2f & %.2f \\\\", placebo$country, placebo$pre_rmse, placebo$post_gap, placebo$ratio), collapse = "\n"),
"
\\midrule
\\multicolumn{4}{l}{Netherlands rank: ", robustness$nl_rank, " of ", nrow(robustness$placebo_summary) + 1, " (p-value = ", sprintf("%.3f", robustness$nl_pvalue), ")} \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\small
\\item Notes: Each donor country is treated as if it received the treatment, with all other countries (including Netherlands) as donors. Pre-RMSE is root mean squared prediction error in pre-treatment period. Post-Gap is average gap in post-treatment period. Ratio = $|$Post-Gap$|$ / Pre-RMSE. Only top 10 countries by $|$Post-Gap$|$ shown.
\\end{tablenotes}
\\end{threeparttable}
\\end{table}
")

writeLines(table5_latex, "../tables/tab5_placebo.tex")

# ------------------------------------------------------------------------------
# Table 6: Robustness - Leave-One-Out
# ------------------------------------------------------------------------------
cat("Creating Table 6: Leave-One-Out...\n")

loo <- robustness$loo_results

table6_latex <- paste0(
"\\begin{table}[H]
\\centering
\\caption{Leave-One-Out Robustness}
\\label{tab:loo}
\\begin{threeparttable}
\\begin{tabular}{lr}
\\toprule
Country Left Out & ATT Estimate \\\\
\\midrule
",
paste(sprintf("%s & %.2f \\\\", loo$left_out, loo$att), collapse = "\n"),
"
\\midrule
Baseline (all donors) & ", sprintf("%.2f", estimates$post_effect$att), " \\\\
Range & [", sprintf("%.2f", min(loo$att)), ", ", sprintf("%.2f", max(loo$att)), "] \\\\
Mean & ", sprintf("%.2f", mean(loo$att)), " \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\small
\\item Notes: Each row shows the ATT estimate when the indicated country is excluded from the donor pool. Baseline uses all donor countries.
\\end{tablenotes}
\\end{threeparttable}
\\end{table}
")

writeLines(table6_latex, "../tables/tab6_loo.tex")

# ------------------------------------------------------------------------------
# Table 7: Robustness - COVID Sensitivity
# ------------------------------------------------------------------------------
cat("Creating Table 7: COVID Sensitivity...\n")

table7_latex <- paste0(
"\\begin{table}[H]
\\centering
\\caption{COVID-19 Sensitivity Analysis}
\\label{tab:covid}
\\begin{threeparttable}
\\begin{tabular}{lrr}
\\toprule
Sample & ATT Estimate & Post Periods \\\\
\\midrule
Full sample (2019Q2--2023Q4) & ", sprintf("%.2f", estimates$post_effect$att), " & ", estimates$post_effect$n_periods, " \\\\
Pre-COVID only (2019Q2--2019Q4) & ", sprintf("%.2f", robustness$att_pre_covid), " & 3 \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}[flushleft]
\\small
\\item Notes: Pre-COVID sample ends at 2019Q4 to exclude any COVID-19 effects. The difference suggests substantial confounding from pandemic-era housing market dynamics.
\\end{tablenotes}
\\end{threeparttable}
\\end{table}
")

writeLines(table7_latex, "../tables/tab7_covid.tex")

# ------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------
cat("\n=== Tables Created ===\n")
list.files("../tables", pattern = "\\.tex$") %>%
  sort() %>%
  cat(sep = "\n")

cat("\nTable generation complete.\n")
