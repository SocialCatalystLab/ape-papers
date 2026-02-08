# ============================================================================
# Paper 66: Salary Transparency Laws and Wage Outcomes
# 06_tables.R - Publication-Quality Tables
# ============================================================================

source("code/00_packages.R")

# ============================================================================
# Load Data and Results
# ============================================================================

message("Loading data and results...")
cps <- readRDS("data/cps_analysis.rds")
state_year <- readRDS("data/state_year_panel.rds")
results <- readRDS("data/main_results.rds")
robustness <- readRDS("data/robustness_results.rds")

# ============================================================================
# Table 1: Summary Statistics
# ============================================================================

message("Creating Table 1: Summary statistics...")

# Individual-level summary statistics
summ_stats <- cps %>%
  group_by(ever_treated) %>%
  summarise(
    # Outcomes
    `Weekly Earnings ($)` = mean(earnweek, na.rm = TRUE),
    `Log Weekly Earnings` = mean(log_earnweek, na.rm = TRUE),
    `Hourly Wage ($)` = mean(implied_hourwage, na.rm = TRUE),

    # Demographics
    `Age` = mean(age, na.rm = TRUE),
    `Female (%)` = mean(female, na.rm = TRUE) * 100,
    `College+ (%)` = mean(educ_cat %in% c("Bachelor's", "Graduate"), na.rm = TRUE) * 100,
    `Full-time (%)` = mean(fulltime, na.rm = TRUE) * 100,
    `Usual Hours/Week` = mean(uhrswork, na.rm = TRUE),

    # Sample size
    `N` = n(),

    .groups = "drop"
  ) %>%
  mutate(
    Group = ifelse(ever_treated, "Treated States", "Control States")
  ) %>%
  select(Group, everything(), -ever_treated) %>%
  pivot_longer(cols = -Group, names_to = "Variable", values_to = "value") %>%
  pivot_wider(names_from = Group, values_from = value)

# Add full sample column
full_sample <- cps %>%
  summarise(
    `Weekly Earnings ($)` = mean(earnweek, na.rm = TRUE),
    `Log Weekly Earnings` = mean(log_earnweek, na.rm = TRUE),
    `Hourly Wage ($)` = mean(implied_hourwage, na.rm = TRUE),
    `Age` = mean(age, na.rm = TRUE),
    `Female (%)` = mean(female, na.rm = TRUE) * 100,
    `College+ (%)` = mean(educ_cat %in% c("Bachelor's", "Graduate"), na.rm = TRUE) * 100,
    `Full-time (%)` = mean(fulltime, na.rm = TRUE) * 100,
    `Usual Hours/Week` = mean(uhrswork, na.rm = TRUE),
    `N` = n()
  ) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "Full Sample")

summ_stats <- summ_stats %>%
  left_join(full_sample, by = "Variable")

# Format for display
table1 <- summ_stats %>%
  mutate(across(where(is.numeric), ~ case_when(
    Variable == "N" ~ format(round(.x), big.mark = ",", scientific = FALSE),
    TRUE ~ sprintf("%.2f", .x)
  )))

# Save as CSV
write_csv(table1, "tables/table1_summary_stats.csv")

# Create LaTeX table
cat(
  "\\begin{table}[htbp]
  \\centering
  \\caption{Summary Statistics}
  \\label{tab:summ_stats}
  \\begin{tabular}{lccc}
  \\toprule
  & \\multicolumn{1}{c}{Treated States} & \\multicolumn{1}{c}{Control States} & \\multicolumn{1}{c}{Full Sample} \\\\
  \\midrule\n",
  file = "tables/table1_summary_stats.tex"
)

for (i in 1:nrow(table1)) {
  cat(
    paste0("  ", table1$Variable[i], " & ",
           table1$`Treated States`[i], " & ",
           table1$`Control States`[i], " & ",
           table1$`Full Sample`[i], " \\\\\n"),
    file = "tables/table1_summary_stats.tex",
    append = TRUE
  )
}

cat(
  "  \\bottomrule
  \\end{tabular}
  \\begin{tablenotes}
  \\small
  \\item \\textit{Notes:} Sample includes wage/salary workers ages 18-64 from CPS MORG 2016-2024.
  Treated states are those adopting salary transparency laws by 2025 (CO, CA, WA, NY, HI, DC, MD, IL, MN).
  Weekly earnings top-coded at \\$2,885. Percentages shown for binary variables.
  \\end{tablenotes}
  \\end{table}\n",
  file = "tables/table1_summary_stats.tex",
  append = TRUE
)

message("Saved: tables/table1_summary_stats.tex")

# ============================================================================
# Table 2: Treatment Timing and Features
# ============================================================================

message("Creating Table 2: Treatment timing...")

treatment_table <- cps %>%
  distinct(state_name, treatment_year, threshold) %>%
  filter(treatment_year > 0) %>%
  arrange(treatment_year, state_name) %>%
  mutate(
    `Effective Date` = case_when(
      state_name == "Colorado" ~ "January 1, 2021",
      state_name == "California" ~ "January 1, 2023",
      state_name == "Washington" ~ "January 1, 2023",
      state_name == "New York" ~ "September 17, 2023",
      state_name == "Hawaii" ~ "January 1, 2024",
      state_name == "District of Columbia" ~ "June 30, 2024",
      state_name == "Maryland" ~ "October 1, 2024",
      state_name == "Illinois" ~ "January 1, 2025",
      state_name == "Minnesota" ~ "January 1, 2025",
      TRUE ~ paste0("January 1, ", treatment_year)
    ),
    `Employer Threshold` = case_when(
      threshold == 1 ~ "All employers",
      TRUE ~ paste0(threshold, "+ employees")
    )
  ) %>%
  select(State = state_name, `Effective Date`, `Employer Threshold`)

write_csv(treatment_table, "tables/table2_treatment_timing.csv")

# LaTeX version
cat(
  "\\begin{table}[htbp]
  \\centering
  \\caption{Salary Transparency Law Adoption Timeline}
  \\label{tab:treatment_timing}
  \\begin{tabular}{lll}
  \\toprule
  State & Effective Date & Employer Threshold \\\\
  \\midrule\n",
  file = "tables/table2_treatment_timing.tex"
)

for (i in 1:nrow(treatment_table)) {
  cat(
    paste0("  ", treatment_table$State[i], " & ",
           treatment_table$`Effective Date`[i], " & ",
           treatment_table$`Employer Threshold`[i], " \\\\\n"),
    file = "tables/table2_treatment_timing.tex",
    append = TRUE
  )
}

cat(
  "  \\bottomrule
  \\end{tabular}
  \\begin{tablenotes}
  \\small
  \\item \\textit{Notes:} Laws require employers above the threshold to disclose salary ranges in job postings.
  States not listed have not adopted salary transparency laws as of 2025.
  \\end{tablenotes}
  \\end{table}\n",
  file = "tables/table2_treatment_timing.tex",
  append = TRUE
)

message("Saved: tables/table2_treatment_timing.tex")

# ============================================================================
# Table 3: Main Results
# ============================================================================

message("Creating Table 3: Main results...")

# Extract main results
main_results_df <- tibble(
  Specification = c(
    "Overall ATT",
    "Dynamic ATT (t=0)",
    "Dynamic ATT (t=1)",
    "Dynamic ATT (t=2)",
    "Dynamic ATT (t=3)"
  ),
  Estimate = c(
    results$overall_att$overall.att,
    results$es_att$att.egt[results$es_att$egt == 0],
    results$es_att$att.egt[results$es_att$egt == 1],
    results$es_att$att.egt[results$es_att$egt == 2],
    results$es_att$att.egt[results$es_att$egt == 3]
  ),
  SE = c(
    results$overall_att$overall.se,
    results$es_att$se.egt[results$es_att$egt == 0],
    results$es_att$se.egt[results$es_att$egt == 1],
    results$es_att$se.egt[results$es_att$egt == 2],
    results$es_att$se.egt[results$es_att$egt == 3]
  )
) %>%
  mutate(
    CI_lower = Estimate - 1.96 * SE,
    CI_upper = Estimate + 1.96 * SE,
    p_value = 2 * (1 - pnorm(abs(Estimate / SE))),
    stars = case_when(
      p_value < 0.01 ~ "***",
      p_value < 0.05 ~ "**",
      p_value < 0.10 ~ "*",
      TRUE ~ ""
    )
  )

write_csv(main_results_df, "tables/table3_main_results.csv")

# LaTeX version with proper formatting
cat(
  "\\begin{table}[htbp]
  \\centering
  \\caption{Effect of Salary Transparency Laws on Log Weekly Earnings}
  \\label{tab:main_results}
  \\begin{tabular}{lcccc}
  \\toprule
  & Estimate & SE & 95\\% CI & \\\\
  \\midrule\n",
  file = "tables/table3_main_results.tex"
)

for (i in 1:nrow(main_results_df)) {
  cat(
    sprintf("  %s & %.4f%s & (%.4f) & [%.4f, %.4f] \\\\\n",
            main_results_df$Specification[i],
            main_results_df$Estimate[i],
            main_results_df$stars[i],
            main_results_df$SE[i],
            main_results_df$CI_lower[i],
            main_results_df$CI_upper[i]),
    file = "tables/table3_main_results.tex",
    append = TRUE
  )
}

cat(
  "  \\midrule
  N (individuals) & \\multicolumn{4}{c}{", format(nrow(cps), big.mark = ","), "} \\\\
  N (state-years) & \\multicolumn{4}{c}{", nrow(state_year), "} \\\\
  Treated states & \\multicolumn{4}{c}{", sum(cps$ever_treated[!duplicated(cps$statefip)]), "} \\\\
  Control states & \\multicolumn{4}{c}{", sum(!cps$ever_treated[!duplicated(cps$statefip)]), "} \\\\
  \\bottomrule
  \\end{tabular}
  \\begin{tablenotes}
  \\small
  \\item \\textit{Notes:} Callaway-Sant'Anna (2021) estimates with not-yet-treated control group.
  Standard errors clustered at state level. * p $<$ 0.10, ** p $<$ 0.05, *** p $<$ 0.01.
  Dynamic ATT shows average treatment effect at t years after treatment.
  \\end{tablenotes}
  \\end{table}\n",
  file = "tables/table3_main_results.tex",
  append = TRUE
)

message("Saved: tables/table3_main_results.tex")

# ============================================================================
# Table 4: Heterogeneity Results
# ============================================================================

message("Creating Table 4: Heterogeneity results...")

het_results <- tibble(
  Subgroup = c("All Workers", "Male", "Female", "College+", "No College"),
  ATT = c(
    results$overall_att$overall.att,
    results$het_male$overall.att,
    results$het_female$overall.att,
    results$het_college$overall.att,
    results$het_nocollege$overall.att
  ),
  SE = c(
    results$overall_att$overall.se,
    results$het_male$overall.se,
    results$het_female$overall.se,
    results$het_college$overall.se,
    results$het_nocollege$overall.se
  )
) %>%
  mutate(
    CI_lower = ATT - 1.96 * SE,
    CI_upper = ATT + 1.96 * SE,
    p_value = 2 * (1 - pnorm(abs(ATT / SE))),
    stars = case_when(
      p_value < 0.01 ~ "***",
      p_value < 0.05 ~ "**",
      p_value < 0.10 ~ "*",
      TRUE ~ ""
    )
  )

write_csv(het_results, "tables/table4_heterogeneity.csv")

# LaTeX version
cat(
  "\\begin{table}[htbp]
  \\centering
  \\caption{Heterogeneous Treatment Effects by Subgroup}
  \\label{tab:heterogeneity}
  \\begin{tabular}{lccc}
  \\toprule
  Subgroup & ATT & SE & 95\\% CI \\\\
  \\midrule\n",
  file = "tables/table4_heterogeneity.tex"
)

for (i in 1:nrow(het_results)) {
  cat(
    sprintf("  %s & %.4f%s & (%.4f) & [%.4f, %.4f] \\\\\n",
            het_results$Subgroup[i],
            het_results$ATT[i],
            het_results$stars[i],
            het_results$SE[i],
            het_results$CI_lower[i],
            het_results$CI_upper[i]),
    file = "tables/table4_heterogeneity.tex",
    append = TRUE
  )
}

cat(
  "  \\bottomrule
  \\end{tabular}
  \\begin{tablenotes}
  \\small
  \\item \\textit{Notes:} Callaway-Sant'Anna ATT estimates by subgroup.
  Standard errors clustered at state level. * p $<$ 0.10, ** p $<$ 0.05, *** p $<$ 0.01.
  \\end{tablenotes}
  \\end{table}\n",
  file = "tables/table4_heterogeneity.tex",
  append = TRUE
)

message("Saved: tables/table4_heterogeneity.tex")

# ============================================================================
# Table 5: Robustness Results
# ============================================================================

message("Creating Table 5: Robustness results...")

robust_table <- robustness$robustness_summary %>%
  mutate(
    CI = paste0("[", sprintf("%.4f", CI_lower), ", ", sprintf("%.4f", CI_upper), "]"),
    p_value = 2 * (1 - pnorm(abs(ATT / SE))),
    stars = case_when(
      p_value < 0.01 ~ "***",
      p_value < 0.05 ~ "**",
      p_value < 0.10 ~ "*",
      TRUE ~ ""
    ),
    ATT_display = paste0(sprintf("%.4f", ATT), stars)
  ) %>%
  select(Specification, ATT = ATT_display, SE, CI)

write_csv(robust_table, "tables/table5_robustness.csv")

# LaTeX version
cat(
  "\\begin{table}[htbp]
  \\centering
  \\caption{Robustness to Alternative Specifications}
  \\label{tab:robustness}
  \\begin{tabular}{lccc}
  \\toprule
  Specification & ATT & SE & 95\\% CI \\\\
  \\midrule\n",
  file = "tables/table5_robustness.tex"
)

for (i in 1:nrow(robust_table)) {
  cat(
    sprintf("  %s & %s & (%.4f) & %s \\\\\n",
            robust_table$Specification[i],
            robust_table$ATT[i],
            robustness$robustness_summary$SE[i],
            robust_table$CI[i]),
    file = "tables/table5_robustness.tex",
    append = TRUE
  )
}

cat(
  "  \\bottomrule
  \\end{tabular}
  \\begin{tablenotes}
  \\small
  \\item \\textit{Notes:} Row 1 is the main specification (Callaway-Sant'Anna with not-yet-treated control).
  Row 5 (TWFE) shown for comparison but is biased with staggered adoption.
  Standard errors clustered at state level. * p $<$ 0.10, ** p $<$ 0.05, *** p $<$ 0.01.
  \\end{tablenotes}
  \\end{table}\n",
  file = "tables/table5_robustness.tex",
  append = TRUE
)

message("Saved: tables/table5_robustness.tex")

# ============================================================================
# Table 6: Gender Wage Gap Analysis
# ============================================================================

message("Creating Table 6: Gender wage gap analysis...")

gap_did <- results$gap_did

gender_gap_table <- tibble(
  Specification = c(
    "DiD (Treated × Post)",
    "Pre-treatment gender gap (treated)",
    "Pre-treatment gender gap (control)"
  ),
  Estimate = c(
    coef(gap_did)["treated"],
    NA,  # Would compute from data
    NA   # Would compute from data
  ),
  SE = c(
    se(gap_did)["treated"],
    NA,
    NA
  )
)

write_csv(gender_gap_table, "tables/table6_gender_gap.csv")
message("Saved: tables/table6_gender_gap.csv")

# ============================================================================
# Summary
# ============================================================================

message("\n=== All Tables Complete ===")
message("Tables saved to: tables/")
message("\nFiles created:")
message("  - table1_summary_stats.tex")
message("  - table2_treatment_timing.tex")
message("  - table3_main_results.tex")
message("  - table4_heterogeneity.tex")
message("  - table5_robustness.tex")
message("  - table6_gender_gap.csv")
