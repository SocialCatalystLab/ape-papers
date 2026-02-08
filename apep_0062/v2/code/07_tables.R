# =============================================================================
# 07_tables.R
# Generate publication-quality tables
# =============================================================================

source("output/paper_84/code/00_packages.R")

# =============================================================================
# Load results
# =============================================================================

df <- read_csv("output/paper_84/data/analysis_main.csv", show_col_types = FALSE)
cs_results <- readRDS("output/paper_84/data/cs_results.rds")
robustness <- readRDS("output/paper_84/data/robustness_results.rds")
policy <- read_csv("output/paper_84/data/policy_dates.csv", show_col_types = FALSE)

# =============================================================================
# Table 1: Summary Statistics
# =============================================================================

cat("Creating Table 1: Summary Statistics...\n")

# Pre-treatment period
pre_period <- df %>% filter(year < 2018)

summary_stats <- bind_rows(
  # Panel A: Employment
  pre_period %>%
    summarise(
      Variable = "Gambling employment (NAICS 7132)",
      Mean = mean(gambling_emp_clean, na.rm = TRUE),
      SD = sd(gambling_emp_clean, na.rm = TRUE),
      Min = min(gambling_emp_clean, na.rm = TRUE),
      Max = max(gambling_emp_clean, na.rm = TRUE)
    ),
  pre_period %>%
    summarise(
      Variable = "Leisure/entertainment employment (NAICS 71)",
      Mean = mean(leisure_emp_clean, na.rm = TRUE),
      SD = sd(leisure_emp_clean, na.rm = TRUE),
      Min = min(leisure_emp_clean, na.rm = TRUE),
      Max = max(leisure_emp_clean, na.rm = TRUE)
    ),
  pre_period %>%
    summarise(
      Variable = "Gambling establishments",
      Mean = mean(gambling_estab, na.rm = TRUE),
      SD = sd(gambling_estab, na.rm = TRUE),
      Min = min(gambling_estab, na.rm = TRUE),
      Max = max(gambling_estab, na.rm = TRUE)
    ),
  pre_period %>%
    summarise(
      Variable = "Avg weekly wage (gambling)",
      Mean = mean(gambling_weekly_wage, na.rm = TRUE),
      SD = sd(gambling_weekly_wage, na.rm = TRUE),
      Min = min(gambling_weekly_wage, na.rm = TRUE),
      Max = max(gambling_weekly_wage, na.rm = TRUE)
    )
)

# Panel B: Treatment
treatment_stats <- df %>%
  filter(year == max(year)) %>%
  summarise(
    `Ever treated (by 2024)` = mean(first_treat_year > 0),
    `Currently treated` = mean(treated),
    `Mobile permitted` = mean(implementation_type %in% c("both", "mobile"), na.rm = TRUE)
  ) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "Mean") %>%
  mutate(SD = NA, Min = 0, Max = 1)

# Combine
table1 <- bind_rows(
  tibble(Variable = "Panel A: Employment", Mean = NA, SD = NA, Min = NA, Max = NA),
  summary_stats,
  tibble(Variable = "", Mean = NA, SD = NA, Min = NA, Max = NA),
  tibble(Variable = "Panel B: Treatment", Mean = NA, SD = NA, Min = NA, Max = NA),
  treatment_stats
)

# Save
write_csv(table1, "output/paper_84/tables/table1_summary.csv")

# LaTeX version
table1_latex <- table1 %>%
  filter(!is.na(Mean) | str_detect(Variable, "Panel")) %>%
  mutate(
    Mean = ifelse(is.na(Mean), "", sprintf("%.1f", Mean)),
    SD = ifelse(is.na(SD), "", sprintf("%.1f", SD)),
    Min = ifelse(is.na(Min), "", sprintf("%.0f", Min)),
    Max = ifelse(is.na(Max), "", sprintf("%.0f", Max))
  )

write_csv(table1_latex, "output/paper_84/tables/table1_latex.csv")

# =============================================================================
# Table 2: Main Results
# =============================================================================

cat("Creating Table 2: Main Results...\n")

# Compile main results
main_results_table <- data.frame(
  Specification = c("Callaway-Sant'Anna", "Sun-Abraham", "TWFE"),
  ATT = c(
    cs_results$overall_att,
    robustness$sa_model %>% summary(agg = "att") %>% .$coeftable %>% .[1, 1],
    coef(robustness$twfe_model)["treated"]
  ),
  SE = c(
    cs_results$overall_se,
    robustness$sa_model %>% summary(agg = "att") %>% .$coeftable %>% .[1, 2],
    se(robustness$twfe_model)["treated"]
  )
) %>%
  mutate(
    CI_lower = ATT - 1.96 * SE,
    CI_upper = ATT + 1.96 * SE,
    `95% CI` = sprintf("[%.0f, %.0f]", CI_lower, CI_upper),
    t_stat = ATT / SE,
    sig = case_when(
      abs(t_stat) > 2.576 ~ "***",
      abs(t_stat) > 1.96 ~ "**",
      abs(t_stat) > 1.645 ~ "*",
      TRUE ~ ""
    )
  )

# Add pre-trend test
main_results_table$`Pre-trend p` <- c(
  sprintf("%.2f", cs_results$pre_trend_pval),
  NA,
  NA
)

# Add sample info
main_results_table$Observations <- nrow(df)
main_results_table$States <- n_distinct(df$state_fips)

write_csv(main_results_table, "output/paper_84/tables/table2_main_results.csv")

# =============================================================================
# Table 3: Heterogeneity by Implementation Type
# =============================================================================

cat("Creating Table 3: Heterogeneity...\n")

het_table <- data.frame(
  `Implementation Type` = c("Retail + Mobile", "Retail Only", "Mobile Only"),
  ATT = c(
    cs_results$agg_both$overall.att,
    cs_results$agg_retail$overall.att,
    NA
  ),
  SE = c(
    cs_results$agg_both$overall.se,
    cs_results$agg_retail$overall.se,
    NA
  ),
  N_States = c(
    n_distinct(df$state_fips[df$implementation_type == "both"]),
    n_distinct(df$state_fips[df$implementation_type == "retail"]),
    n_distinct(df$state_fips[df$implementation_type == "mobile"])
  )
) %>%
  filter(!is.na(ATT)) %>%
  mutate(
    CI_lower = ATT - 1.96 * SE,
    CI_upper = ATT + 1.96 * SE,
    `95% CI` = sprintf("[%.0f, %.0f]", CI_lower, CI_upper)
  )

write_csv(het_table, "output/paper_84/tables/table3_heterogeneity.csv")

# =============================================================================
# Table 4: Robustness
# =============================================================================

cat("Creating Table 4: Robustness...\n")

robustness_table <- read_csv("output/paper_84/data/robustness_summary.csv", show_col_types = FALSE) %>%
  mutate(
    `95% CI` = sprintf("[%.0f, %.0f]", CI_lower, CI_upper),
    sig = case_when(
      abs(t_stat) > 2.576 ~ "***",
      abs(t_stat) > 1.96 ~ "**",
      abs(t_stat) > 1.645 ~ "*",
      TRUE ~ ""
    ),
    ATT_display = sprintf("%.0f%s", ATT, sig)
  ) %>%
  select(Specification, ATT_display, SE, `95% CI`)

write_csv(robustness_table, "output/paper_84/tables/table4_robustness.csv")

# =============================================================================
# Table 5: Event Study Coefficients
# =============================================================================

cat("Creating Table 5: Event study coefficients...\n")

es_table <- cs_results$es_coefs %>%
  filter(event_time >= -4, event_time <= 5) %>%
  mutate(
    ATT = sprintf("%.0f", att),
    SE = sprintf("(%.0f)", se),
    `95% CI` = sprintf("[%.0f, %.0f]", ci_lower, ci_upper)
  ) %>%
  select(`Event Time` = event_time, ATT, SE, `95% CI`)

write_csv(es_table, "output/paper_84/tables/table5_event_study.csv")

# =============================================================================
# Table 6: Treatment Cohorts
# =============================================================================

cat("Creating Table 6: Treatment cohorts...\n")

cohort_table <- policy %>%
  filter(first_treat_year > 0) %>%
  group_by(first_treat_year) %>%
  summarise(
    N = n(),
    States = paste(state_abbr, collapse = ", "),
    .groups = "drop"
  ) %>%
  rename(Cohort = first_treat_year)

# Add never treated
cohort_table <- bind_rows(
  cohort_table,
  tibble(
    Cohort = NA,
    N = sum(policy$first_treat_year == 0),
    States = policy %>% filter(first_treat_year == 0) %>% pull(state_abbr) %>% paste(collapse = ", ")
  )
)

write_csv(cohort_table, "output/paper_84/tables/table6_cohorts.csv")

# =============================================================================
# Print summaries
# =============================================================================

cat("\n=== Tables created ===\n\n")

cat("Table 1: Summary Statistics\n")
print(summary_stats)

cat("\n\nTable 2: Main Results\n")
print(main_results_table %>% select(Specification, ATT, SE, `95% CI`))

cat("\n\nTable 3: Heterogeneity\n")
print(het_table)

cat("\n\nTables saved to output/paper_84/tables/\n")
