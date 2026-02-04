# =============================================================================
# 06_tables.R
# Generate Publication-Quality Tables
# =============================================================================

source("00_packages.R")
library(modelsummary)
library(kableExtra)

# =============================================================================
# Load Results
# =============================================================================

qwi <- readRDS("data/qwi_analysis.rds")
att_overall <- readRDS("data/att_overall.rds")
att_dynamic <- readRDS("data/att_dynamic.rds")
results_by_sex <- readRDS("data/results_by_sex.rds")
robustness_table <- readRDS("data/robustness_table.rds")
twfe_result <- readRDS("data/twfe_result.rds")
border_did <- readRDS("data/border_did.rds")

# =============================================================================
# Table 1: Summary Statistics
# =============================================================================

cat("Creating Table 1: Summary Statistics...\n")

summary_stats <- qwi %>%
  group_by(treated_state) %>%
  summarise(
    `New Hire Earnings` = mean(EarnHirAS, na.rm = TRUE),
    `SD` = sd(EarnHirAS, na.rm = TRUE),
    `All Earnings` = mean(EarnS, na.rm = TRUE),
    `Employment` = mean(Emp, na.rm = TRUE),
    `Hires` = mean(HirA, na.rm = TRUE),
    `Counties` = n_distinct(county_fips),
    `Observations` = n(),
    .groups = "drop"
  ) %>%
  mutate(Group = if_else(treated_state, "Treated States", "Control States")) %>%
  select(Group, everything(), -treated_state)

# LaTeX output
summary_latex <- summary_stats %>%
  kbl(format = "latex",
      booktabs = TRUE,
      digits = c(0, 0, 0, 0, 0, 0, 0, 0),
      caption = "Summary Statistics by Treatment Status",
      label = "tab:summary") %>%
  kable_styling(latex_options = c("hold_position")) %>%
  add_footnote("Note: Sample includes all county-quarter-sex observations from 1995-2023.
New hire earnings and all earnings in dollars. Employment and hires are quarterly counts.
Treated states: CA, CO, CT, NV, RI, WA.",
               notation = "none")

writeLines(summary_latex, "tables/tab1_summary.tex")

# =============================================================================
# Table 2: Main Results - ATT Estimates
# =============================================================================

cat("Creating Table 2: Main ATT Results...\n")

# Create table with main specifications
main_results <- tibble(
  Specification = c(
    "Callaway-Sant'Anna",
    "TWFE (fixest)",
    "Border County-Pairs"
  ),
  ATT = c(
    att_overall$overall.att,
    coef(twfe_result)["postTRUE"],
    coef(border_did)["postTRUE"]
  ),
  SE = c(
    att_overall$overall.se,
    se(twfe_result)["postTRUE"],
    se(border_did)["postTRUE"]
  ),
  `Bootstrap p` = c(
    NA,
    NA,
    NA
  ),
  N = c(
    nrow(qwi),
    nrow(qwi),
    nrow(readRDS("data/qwi_border.rds"))
  ),
  Clusters = c(
    n_distinct(qwi$state_fips),
    n_distinct(qwi$state_fips),
    nrow(readRDS("data/border_pairs.rds"))
  )
) %>%
  mutate(
    t_stat = ATT / SE,
    stars = case_when(
      abs(t_stat) > 2.576 ~ "***",
      abs(t_stat) > 1.96 ~ "**",
      abs(t_stat) > 1.645 ~ "*",
      TRUE ~ ""
    ),
    ATT_display = paste0(sprintf("%.4f", ATT), stars),
    SE_display = paste0("(", sprintf("%.4f", SE), ")")
  )

main_latex <- main_results %>%
  select(Specification, ATT_display, SE_display, `Bootstrap p`, N, Clusters) %>%
  kbl(format = "latex",
      booktabs = TRUE,
      col.names = c("Specification", "ATT", "SE", "Bootstrap p", "N", "Clusters"),
      caption = "Effect of Salary Transparency Laws on New Hire Earnings",
      label = "tab:main") %>%
  kable_styling(latex_options = c("hold_position")) %>%
  add_footnote("Note: Dependent variable is log average monthly earnings of new hires (EarnHirAS).
Callaway-Sant'Anna uses doubly-robust estimation with never-treated controls.
TWFE includes county and quarter fixed effects.
Border county-pairs specification includes pair×quarter fixed effects.
Standard errors clustered at state level (C-S, TWFE) or pair level (border).
*** p<0.01, ** p<0.05, * p<0.10.",
               notation = "none")

writeLines(main_latex, "tables/tab2_main_results.tex")

# =============================================================================
# Table 3: Results by Sex
# =============================================================================

cat("Creating Table 3: Results by Sex...\n")

sex_results <- tibble(
  Sex = c("Male", "Female", "Difference (F-M)"),
  ATT = c(
    results_by_sex$Male$overall.att,
    results_by_sex$Female$overall.att,
    results_by_sex$Female$overall.att - results_by_sex$Male$overall.att
  ),
  SE = c(
    results_by_sex$Male$overall.se,
    results_by_sex$Female$overall.se,
    sqrt(results_by_sex$Male$overall.se^2 + results_by_sex$Female$overall.se^2)
  )
) %>%
  mutate(
    t_stat = ATT / SE,
    stars = case_when(
      abs(t_stat) > 2.576 ~ "***",
      abs(t_stat) > 1.96 ~ "**",
      abs(t_stat) > 1.645 ~ "*",
      TRUE ~ ""
    ),
    ATT_display = paste0(sprintf("%.4f", ATT), stars),
    SE_display = paste0("(", sprintf("%.4f", SE), ")")
  )

sex_latex <- sex_results %>%
  select(Sex, ATT_display, SE_display) %>%
  kbl(format = "latex",
      booktabs = TRUE,
      col.names = c("Group", "ATT", "SE"),
      caption = "Treatment Effect by Sex",
      label = "tab:sex") %>%
  kable_styling(latex_options = c("hold_position")) %>%
  add_footnote("Note: Callaway-Sant'Anna estimates run separately by sex.
Difference calculated as Female ATT minus Male ATT.
Negative difference indicates gender gap narrows (women's wages fell less).
Standard error for difference computed assuming independence.
*** p<0.01, ** p<0.05, * p<0.10.",
               notation = "none")

writeLines(sex_latex, "tables/tab3_sex_results.tex")

# =============================================================================
# Table 4: Event Study Coefficients
# =============================================================================

cat("Creating Table 4: Event Study...\n")

event_study_table <- tibble(
  `Quarters Relative to Treatment` = att_dynamic$egt,
  ATT = att_dynamic$att.egt,
  SE = att_dynamic$se.egt
) %>%
  mutate(
    CI_lower = ATT - 1.96 * SE,
    CI_upper = ATT + 1.96 * SE,
    t_stat = ATT / SE,
    stars = case_when(
      abs(t_stat) > 2.576 ~ "***",
      abs(t_stat) > 1.96 ~ "**",
      abs(t_stat) > 1.645 ~ "*",
      TRUE ~ ""
    ),
    ATT_display = paste0(sprintf("%.4f", ATT), stars),
    CI_display = paste0("[", sprintf("%.4f", CI_lower), ", ",
                        sprintf("%.4f", CI_upper), "]")
  )

es_latex <- event_study_table %>%
  select(`Quarters Relative to Treatment`, ATT_display, SE, CI_display) %>%
  kbl(format = "latex",
      booktabs = TRUE,
      col.names = c("Rel. Quarter", "ATT", "SE", "95% CI"),
      digits = c(0, NA, 4, NA),
      caption = "Event Study Estimates",
      label = "tab:eventstudy") %>%
  kable_styling(latex_options = c("hold_position")) %>%
  add_footnote("Note: Callaway-Sant'Anna dynamic aggregation.
Pre-treatment periods (negative) test parallel trends assumption.
Post-treatment periods show evolution of treatment effect.
*** p<0.01, ** p<0.05, * p<0.10.",
               notation = "none")

writeLines(es_latex, "tables/tab4_event_study.tex")

# =============================================================================
# Table 5: Robustness Checks
# =============================================================================

cat("Creating Table 5: Robustness...\n")

robust_latex <- robustness_table %>%
  mutate(
    stars = case_when(
      abs(t_stat) > 2.576 ~ "***",
      abs(t_stat) > 1.96 ~ "**",
      abs(t_stat) > 1.645 ~ "*",
      TRUE ~ ""
    ),
    ATT_display = paste0(sprintf("%.4f", ATT), stars),
    SE_display = sprintf("%.4f", SE)
  ) %>%
  select(Specification, ATT_display, SE_display) %>%
  kbl(format = "latex",
      booktabs = TRUE,
      col.names = c("Specification", "ATT", "SE"),
      caption = "Robustness Checks",
      label = "tab:robustness") %>%
  kable_styling(latex_options = c("hold_position")) %>%
  add_footnote("Note: All specifications use log new hire earnings as outcome.
Main uses Callaway-Sant'Anna with never-treated controls.
Border pairs uses contiguous county design with pair×quarter FE.
Placebo tests effect 2 years before actual treatment.
*** p<0.01, ** p<0.05, * p<0.10.",
               notation = "none")

writeLines(robust_latex, "tables/tab5_robustness.tex")

# =============================================================================
# Table 6: Treatment Timing
# =============================================================================

cat("Creating Table 6: Treatment Timing...\n")

timing_table <- tibble(
  State = c("Colorado", "Connecticut", "Nevada", "Rhode Island",
            "California", "Washington"),
  Abbreviation = c("CO", "CT", "NV", "RI", "CA", "WA"),
  `Effective Date` = c("January 1, 2021", "October 1, 2021", "October 1, 2021",
                       "January 1, 2023", "January 1, 2023", "January 1, 2023"),
  Cohort = c("2021Q1", "2021Q4", "2021Q4", "2023Q1", "2023Q1", "2023Q1"),
  `Post-Treatment Quarters` = c(12, 9, 9, 4, 4, 4),
  Counties = c(64, 8, 17, 5, 58, 39)
)

timing_latex <- timing_table %>%
  kbl(format = "latex",
      booktabs = TRUE,
      caption = "Salary Transparency Law Adoption Timing",
      label = "tab:timing") %>%
  kable_styling(latex_options = c("hold_position")) %>%
  add_footnote("Note: Effective date indicates when posting requirements took effect.
Post-treatment quarters calculated through 2023Q4 (end of sample).
NY and HI adopted laws effective 2024, outside our sample window.",
               notation = "none")

writeLines(timing_latex, "tables/tab6_timing.tex")

cat("\n=== All Tables Complete ===\n")
cat("Saved to tables/ directory\n")
