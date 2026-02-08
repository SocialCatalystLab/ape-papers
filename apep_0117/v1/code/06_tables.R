# =============================================================================
# 06_tables.R
# Generate tables for the paper
# =============================================================================

library(dplyr, warn.conflicts = FALSE)
library(readr)
library(tidyr)

message("=== GENERATING TABLES ===")

df <- readRDS("output/paper_116/data/acs_clean.rds")
results <- readRDS("output/paper_116/data/main_results.rds")
robustness <- readRDS("output/paper_116/data/robustness_results.rds")

tab_dir <- "output/paper_116/tables"
dir.create(tab_dir, showWarnings = FALSE)

df_main <- df %>% filter(sample_main)

# =============================================================================
# TABLE 1: Summary Statistics
# =============================================================================

summary_stats <- df_main %>%
  group_by(self_employed) %>%
  summarize(
    N = n(),
    `Age (mean)` = round(mean(AGEP), 1),
    `Female (%)` = round(mean(female) * 100, 1),
    `Married (%)` = round(mean(married) * 100, 1),
    `College (%)` = round(mean(college) * 100, 1),
    `Has Disability (%)` = round(mean(has_disability) * 100, 1),
    `Hours/Week (mean)` = round(mean(hours_weekly), 1),
    `Part-Time (%)` = round(mean(part_time) * 100, 1),
    `Income (mean)` = round(mean(PINCP, na.rm = TRUE), 0),
    .groups = "drop"
  ) %>%
  mutate(Group = if_else(self_employed, "Self-Employed", "Wage Workers")) %>%
  select(Group, everything(), -self_employed)

write_csv(summary_stats, file.path(tab_dir, "table1_summary_stats.csv"))
message("Table 1 saved")

# =============================================================================
# TABLE 2: Main Results
# =============================================================================

main_results_table <- tibble(
  Specification = c(
    "Full Sample",
    "Pre-ACA (2012-2014)",
    "Post-ACA (2017-2022)",
    "Placebo (65-74) Pre-ACA",
    "Placebo (65-74) Post-ACA"
  ),
  N = c(
    results$main$n,
    results$pre_post$N[1],
    results$pre_post$N[2],
    results$placebo$N[1],
    results$placebo$N[2]
  ),
  Effect = c(
    results$main$ols_coef,
    results$pre_post$ATT_Hours[1],
    results$pre_post$ATT_Hours[2],
    results$placebo$ATT_Hours[1],
    results$placebo$ATT_Hours[2]
  ),
  SE = c(
    results$main$ols_se,
    results$pre_post$ATT_SE[1],
    results$pre_post$ATT_SE[2],
    results$placebo$ATT_SE[1],
    results$placebo$ATT_SE[2]
  )
) %>%
  mutate(
    `95% CI` = paste0("[", round(Effect - 1.96*SE, 2), ", ", round(Effect + 1.96*SE, 2), "]")
  )

write_csv(main_results_table, file.path(tab_dir, "table2_main_results.csv"))
message("Table 2 saved")

# =============================================================================
# TABLE 3: DiD Summary
# =============================================================================

dd_table <- tibble(
  Comparison = c(
    "Main (55-64): Post - Pre",
    "Placebo (65-74): Post - Pre",
    "Triple-Diff: Main - Placebo"
  ),
  Estimate = c(
    results$dd_main$estimate,
    results$dd_placebo$estimate,
    results$triple_diff
  ),
  SE = c(
    results$dd_main$se,
    results$dd_placebo$se,
    sqrt(results$dd_main$se^2 + results$dd_placebo$se^2)
  )
) %>%
  mutate(
    `95% CI` = paste0("[", round(Estimate - 1.96*SE, 2), ", ", round(Estimate + 1.96*SE, 2), "]")
  )

write_csv(dd_table, file.path(tab_dir, "table3_did_summary.csv"))
message("Table 3 saved")

# =============================================================================
# TABLE 4: Alternative Outcomes
# =============================================================================

table4 <- robustness$alternative_outcomes %>%
  mutate(
    Outcome = case_when(
      outcome == "hours" ~ "Weekly Hours",
      outcome == "part_time" ~ "Part-Time (<35 hrs)",
      outcome == "log_income" ~ "Log Total Income"
    ),
    `95% CI` = paste0("[", round(estimate - 1.96*se, 3), ", ", round(estimate + 1.96*se, 3), "]")
  ) %>%
  select(Outcome, Estimate = estimate, SE = se, `95% CI`)

write_csv(table4, file.path(tab_dir, "table4_alternative_outcomes.csv"))
message("Table 4 saved")

# =============================================================================
# TABLE 5: Expansion Heterogeneity
# =============================================================================

table5 <- robustness$expansion_heterogeneity %>%
  mutate(
    `95% CI` = paste0("[", round(Self_Emp_Effect - 1.96*SE, 2), ", ", 
                      round(Self_Emp_Effect + 1.96*SE, 2), "]")
  )

write_csv(table5, file.path(tab_dir, "table5_expansion_heterogeneity.csv"))
message("Table 5 saved")

# =============================================================================
# TABLE 6: Covariate Balance
# =============================================================================

write_csv(robustness$balance, file.path(tab_dir, "table6_covariate_balance.csv"))
message("Table 6 saved")

message("\n=== ALL TABLES GENERATED ===")
list.files(tab_dir)
