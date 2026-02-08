# =============================================================================
# Paper 107: Spatial RDD of Primary Seatbelt Enforcement Laws
# 06_tables.R - Generate All Tables
# =============================================================================

source(here::here("output/paper_107/code/00_packages.R"))

# Load data
analysis_df <- readRDS(file.path(dir_data, "analysis_df.rds"))
seatbelt_laws <- readRDS(file.path(dir_data, "seatbelt_laws.rds"))
rd_results <- readRDS(file.path(dir_data, "rd_results.rds"))
robustness <- readRDS(file.path(dir_data, "robustness_results.rds"))

# =============================================================================
# Table 1: Summary Statistics
# =============================================================================

message("Creating Table 1: Summary statistics...")

# Overall summary
summary_overall <- analysis_df %>%
  summarise(
    `Total Crashes` = n(),
    `Mean Fatalities per Crash` = mean(fatals_per_crash, na.rm = TRUE),
    `Mean Persons per Crash` = mean(n_persons, na.rm = TRUE),
    `Fatality Probability` = mean(fatality_prob, na.rm = TRUE),
    `Ejection Rate` = mean(any_ejection, na.rm = TRUE),
    `Single-Vehicle Crashes` = mean(single_vehicle, na.rm = TRUE),
    `Night Crashes` = mean(night_crash, na.rm = TRUE)
  ) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "Overall")

# By treatment status
summary_by_treat <- analysis_df %>%
  group_by(treated) %>%
  summarise(
    `Total Crashes` = n(),
    `Mean Fatalities per Crash` = mean(fatals_per_crash, na.rm = TRUE),
    `Mean Persons per Crash` = mean(n_persons, na.rm = TRUE),
    `Fatality Probability` = mean(fatality_prob, na.rm = TRUE),
    `Ejection Rate` = mean(any_ejection, na.rm = TRUE),
    `Single-Vehicle Crashes` = mean(single_vehicle, na.rm = TRUE),
    `Night Crashes` = mean(night_crash, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_longer(-treated, names_to = "Variable", values_to = "Value") %>%
  pivot_wider(names_from = treated, values_from = Value,
              names_prefix = "treat_") %>%
  rename(`Secondary (Control)` = treat_0, `Primary (Treated)` = treat_1)

# Combine
table1 <- summary_overall %>%
  left_join(summary_by_treat, by = "Variable") %>%
  mutate(Difference = `Primary (Treated)` - `Secondary (Control)`)

# Format for display
table1_formatted <- table1 %>%
  mutate(across(where(is.numeric), ~ case_when(
    Variable == "Total Crashes" ~ format(round(.), big.mark = ","),
    TRUE ~ sprintf("%.3f", .)
  )))

print(table1_formatted)

# Export to LaTeX
sink(file.path(dir_tabs, "table1_summary_stats.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics: Fatal Crashes Near State Borders, 2000-2020}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat("Variable & Overall & Secondary & Primary & Difference \\\\\n")
cat("\\midrule\n")
for (i in 1:nrow(table1_formatted)) {
  cat(sprintf("%s & %s & %s & %s & %s \\\\\n",
              table1_formatted$Variable[i],
              table1_formatted$Overall[i],
              table1_formatted$`Secondary (Control)`[i],
              table1_formatted$`Primary (Treated)`[i],
              table1_formatted$Difference[i]))
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Note:} Sample includes fatal crashes within 100 km of a primary/secondary ")
cat("enforcement state border. Secondary enforcement states serve as the control group.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

message("  ✓ Table 1 saved")

# =============================================================================
# Table 2: Primary Seatbelt Enforcement Adoption Dates
# =============================================================================

message("Creating Table 2: Policy adoption dates...")

table2 <- seatbelt_laws %>%
  filter(enforcement_type == "primary", !is.na(primary_date)) %>%
  select(state, state_abbr, primary_date) %>%
  mutate(primary_date = format(primary_date, "%B %d, %Y")) %>%
  arrange(state)

# Export
sink(file.path(dir_tabs, "table2_adoption_dates.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Primary Seatbelt Enforcement Law Adoption Dates}\n")
cat("\\label{tab:adoption}\n")
cat("\\begin{tabular}{llc}\n")
cat("\\toprule\n")
cat("State & Abbreviation & Effective Date \\\\\n")
cat("\\midrule\n")
for (i in 1:nrow(table2)) {
  cat(sprintf("%s & %s & %s \\\\\n",
              table2$state[i], table2$state_abbr[i], table2$primary_date[i]))
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Source:} Insurance Institute for Highway Safety (IIHS).\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

message("  ✓ Table 2 saved")

# =============================================================================
# Table 3: Main RDD Results
# =============================================================================

message("Creating Table 3: Main RDD results...")

table3 <- rd_results$main_results %>%
  mutate(
    stars = case_when(
      p_value < 0.01 ~ "***",
      p_value < 0.05 ~ "**",
      p_value < 0.10 ~ "*",
      TRUE ~ ""
    ),
    estimate_formatted = sprintf("%.4f%s", estimate, stars),
    se_formatted = sprintf("(%.4f)", se),
    ci_formatted = sprintf("[%.4f, %.4f]", ci_lower, ci_upper)
  )

# Export
sink(file.path(dir_tabs, "table3_main_results.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Spatial RDD Estimates: Effect of Primary Seatbelt Enforcement on Fatality Outcomes}\n")
cat("\\label{tab:main_results}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat("Outcome & Estimate & 95\\% CI & Bandwidth (km) & Eff. N \\\\\n")
cat("\\midrule\n")
for (i in 1:nrow(table3)) {
  cat(sprintf("%s & %s & %s & %.1f & %s \\\\\n",
              table3$outcome[i],
              table3$estimate_formatted[i],
              table3$ci_formatted[i],
              table3$bandwidth[i],
              format(table3$n_eff[i], big.mark = ",")))
  cat(sprintf(" & %s & & & \\\\\n", table3$se_formatted[i]))
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Note:} Local linear RDD estimates with triangular kernel and MSE-optimal bandwidth. ")
cat("Robust bias-corrected standard errors in parentheses. ")
cat("*** p$<$0.01, ** p$<$0.05, * p$<$0.10.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

message("  ✓ Table 3 saved")

# =============================================================================
# Table 4: Robustness to Bandwidth Choice
# =============================================================================

message("Creating Table 4: Bandwidth robustness...")

table4 <- robustness$bandwidth %>%
  mutate(
    stars = case_when(
      2 * pnorm(-abs(estimate/se)) < 0.01 ~ "***",
      2 * pnorm(-abs(estimate/se)) < 0.05 ~ "**",
      2 * pnorm(-abs(estimate/se)) < 0.10 ~ "*",
      TRUE ~ ""
    ),
    estimate_formatted = sprintf("%.4f%s", estimate, stars),
    se_formatted = sprintf("(%.4f)", se),
    bw_label = sprintf("%.0f km (%.0f\\%%)", bandwidth, bandwidth_ratio * 100)
  )

sink(file.path(dir_tabs, "table4_bandwidth_robustness.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Robustness to Bandwidth Choice}\n")
cat("\\label{tab:bandwidth}\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\toprule\n")
cat("Bandwidth & Estimate & SE & Eff. N \\\\\n")
cat("\\midrule\n")
for (i in 1:nrow(table4)) {
  cat(sprintf("%s & %s & %s & %s \\\\\n",
              table4$bw_label[i],
              table4$estimate_formatted[i],
              table4$se_formatted[i],
              format(table4$n_eff[i], big.mark = ",")))
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Note:} Percentage in bandwidth column refers to fraction of MSE-optimal bandwidth. ")
cat("Outcome is fatality probability. *** p$<$0.01, ** p$<$0.05, * p$<$0.10.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

message("  ✓ Table 4 saved")

# =============================================================================
# Table 5: Heterogeneity Analysis
# =============================================================================

message("Creating Table 5: Heterogeneity...")

table5 <- rd_results$heterogeneity %>%
  mutate(
    p_value = 2 * pnorm(-abs(estimate/se)),
    stars = case_when(
      p_value < 0.01 ~ "***",
      p_value < 0.05 ~ "**",
      p_value < 0.10 ~ "*",
      TRUE ~ ""
    ),
    estimate_formatted = sprintf("%.4f%s", estimate, stars),
    se_formatted = sprintf("(%.4f)", se)
  )

sink(file.path(dir_tabs, "table5_heterogeneity.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Heterogeneous Treatment Effects by Crash Characteristics}\n")
cat("\\label{tab:heterogeneity}\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\toprule\n")
cat("Subgroup & Estimate & SE & Eff. N \\\\\n")
cat("\\midrule\n")
for (i in 1:nrow(table5)) {
  cat(sprintf("%s & %s & %s & %s \\\\\n",
              table5$subgroup[i],
              table5$estimate_formatted[i],
              table5$se_formatted[i],
              format(table5$n_eff[i], big.mark = ",")))
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Note:} Each row shows the RDD estimate for the indicated subsample. ")
cat("MSE-optimal bandwidth estimated separately for each subgroup. *** p$<$0.01, ** p$<$0.05, * p$<$0.10.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

message("  ✓ Table 5 saved")

# =============================================================================
# Table 6: Placebo Tests
# =============================================================================

message("Creating Table 6: Placebo tests...")

table6 <- robustness$placebo_cutoffs %>%
  mutate(
    stars = case_when(
      p_value < 0.01 ~ "***",
      p_value < 0.05 ~ "**",
      p_value < 0.10 ~ "*",
      TRUE ~ ""
    ),
    estimate_formatted = sprintf("%.4f%s", estimate, stars),
    se_formatted = sprintf("(%.4f)", se),
    cutoff_label = sprintf("%+d km", placebo_cutoff)
  )

# Get main result for comparison
main_result <- rd_results$main_results %>% filter(outcome == "Fatality Probability")

sink(file.path(dir_tabs, "table6_placebo_cutoffs.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Placebo Tests: RDD at False Cutoffs}\n")
cat("\\label{tab:placebo}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat("Cutoff Location & Estimate & SE & p-value & Eff. N \\\\\n")
cat("\\midrule\n")
# Add actual main result
main_stars <- ifelse(main_result$p_value < 0.01, "***",
              ifelse(main_result$p_value < 0.05, "**",
              ifelse(main_result$p_value < 0.10, "*", "")))
cat(sprintf("Actual border (0 km) & %.4f%s & (%.4f) & %.3f & %s \\\\\n",
            main_result$estimate, main_stars, main_result$se, main_result$p_value,
            format(main_result$n_eff, big.mark = ",")))
cat("\\midrule\n")
for (i in 1:nrow(table6)) {
  cat(sprintf("%s & %s & %s & %.3f & %s \\\\\n",
              table6$cutoff_label[i],
              table6$estimate_formatted[i],
              table6$se_formatted[i],
              table6$p_value[i],
              format(table6$n_eff[i], big.mark = ",")))
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Note:} RDD estimates at placebo cutoffs away from the true state border. ")
cat("All placebo cutoffs should show null effects if the design is valid. *** p$<$0.01, ** p$<$0.05, * p$<$0.10.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

message("  ✓ Table 6 saved")

# =============================================================================
# Summary
# =============================================================================

message("\n=== All tables saved to: ", dir_tabs, " ===")
message("  1. table1_summary_stats.tex")
message("  2. table2_adoption_dates.tex")
message("  3. table3_main_results.tex")
message("  4. table4_bandwidth_robustness.tex")
message("  5. table5_heterogeneity.tex")
message("  6. table6_placebo_cutoffs.tex")
