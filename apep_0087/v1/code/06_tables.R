# ==============================================================================
# 06_tables.R - Generate All Tables
# Paper 110: Automation Exposure and Older Worker Labor Force Exit
# ==============================================================================

source("00_packages.R")

message("\n=== Loading Data and Results ===")

df <- readRDS(file.path(data_dir, "analysis_data.rds"))
main_results <- readRDS(file.path(data_dir, "main_results.rds"))
robustness_results <- readRDS(file.path(data_dir, "robustness_results.rds"))

# ==============================================================================
# Table 1: Summary Statistics
# ==============================================================================

message("\n=== Creating Table 1: Summary Statistics ===")

# Summary statistics by treatment group
summary_stats <- df %>%
  group_by(high_automation) %>%
  summarise(
    # Sample size
    N = n(),
    
    # Outcome
    `Not in Labor Force (%)` = weighted.mean(not_in_labor_force, w = PWGTP) * 100,
    
    # Demographics
    `Age (years)` = weighted.mean(AGEP, w = PWGTP),
    `Female (%)` = weighted.mean(SEX == "Female", w = PWGTP) * 100,
    `College+ (%)` = weighted.mean(college == 1, w = PWGTP) * 100,
    `Foreign-born (%)` = weighted.mean(foreign_born, w = PWGTP) * 100,
    
    # Economic
    `Personal Income ($)` = weighted.mean(PINCP, w = PWGTP, na.rm = TRUE),
    `Has Disability (%)` = weighted.mean(has_disability, w = PWGTP) * 100,
    `Married (%)` = weighted.mean(married, w = PWGTP) * 100,
    `Homeowner (%)` = weighted.mean(homeowner, w = PWGTP) * 100,
    
    # Insurance
    `Has Medicare (%)` = weighted.mean(has_medicare, w = PWGTP) * 100,
    `Has Employer Ins (%)` = weighted.mean(has_employer_ins, w = PWGTP) * 100,
    
    .groups = "drop"
  ) %>%
  mutate(
    Group = ifelse(high_automation == 1, "High Automation", "Low/Medium Automation")
  ) %>%
  select(Group, everything(), -high_automation)

# Transpose for display
table1 <- summary_stats %>%
  pivot_longer(-Group, names_to = "Variable", values_to = "Value") %>%
  pivot_wider(names_from = Group, values_from = Value)

# Add overall column
overall_stats <- df %>%
  summarise(
    N = n(),
    `Not in Labor Force (%)` = weighted.mean(not_in_labor_force, w = PWGTP) * 100,
    `Age (years)` = weighted.mean(AGEP, w = PWGTP),
    `Female (%)` = weighted.mean(SEX == "Female", w = PWGTP) * 100,
    `College+ (%)` = weighted.mean(college == 1, w = PWGTP) * 100,
    `Foreign-born (%)` = weighted.mean(foreign_born, w = PWGTP) * 100,
    `Personal Income ($)` = weighted.mean(PINCP, w = PWGTP, na.rm = TRUE),
    `Has Disability (%)` = weighted.mean(has_disability, w = PWGTP) * 100,
    `Married (%)` = weighted.mean(married, w = PWGTP) * 100,
    `Homeowner (%)` = weighted.mean(homeowner, w = PWGTP) * 100,
    `Has Medicare (%)` = weighted.mean(has_medicare, w = PWGTP) * 100,
    `Has Employer Ins (%)` = weighted.mean(has_employer_ins, w = PWGTP) * 100
  ) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "Overall")

table1 <- table1 %>%
  left_join(overall_stats, by = "Variable")

# Format and save
table1_latex <- kable(table1, format = "latex", booktabs = TRUE, digits = 1,
                      caption = "Summary Statistics by Automation Exposure",
                      col.names = c("Variable", "Low/Medium Auto.", "High Auto.", "Overall")) %>%
  kable_styling(latex_options = c("striped", "hold_position"))

writeLines(table1_latex, file.path(tab_dir, "table1_summary_stats.tex"))
write_csv(table1, file.path(tab_dir, "table1_summary_stats.csv"))
message("Saved: table1_summary_stats.tex/csv")

# ==============================================================================
# Table 2: Main Results
# ==============================================================================

message("\n=== Creating Table 2: Main Results ===")

# Prepare regression results for modelsummary
df_reg <- df %>%
  select(not_in_labor_force, high_automation, automation_exposure,
         AGEP, age_squared, SEX, education, race_ethnicity, 
         married, has_disability, log_income, has_medicare,
         industry_broad, ST, PWGTP) %>%
  drop_na() %>%
  mutate(across(where(is.factor), as.numeric))

# Model 1: Basic OLS
m1 <- lm(not_in_labor_force ~ high_automation + AGEP + age_squared + SEX,
         data = df_reg, weights = PWGTP)

# Model 2: Add demographics
m2 <- lm(not_in_labor_force ~ high_automation + AGEP + age_squared + SEX + 
           education + race_ethnicity + married,
         data = df_reg, weights = PWGTP)

# Model 3: Add economic controls
m3 <- lm(not_in_labor_force ~ high_automation + AGEP + age_squared + SEX + 
           education + race_ethnicity + married + has_disability + log_income,
         data = df_reg, weights = PWGTP)

# Model 4: Full specification
m4 <- lm(not_in_labor_force ~ high_automation + AGEP + age_squared + SEX + 
           education + race_ethnicity + married + has_disability + log_income +
           has_medicare + industry_broad,
         data = df_reg, weights = PWGTP)

# Model 5: AIPW (add manually)
models <- list(
  "(1) Basic" = m1,
  "(2) Demographics" = m2,
  "(3) Economic" = m3,
  "(4) Full" = m4
)

# Create table - save directly to file
modelsummary(
  models,
  stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
  coef_map = c(
    "high_automation" = "High Automation",
    "AGEP" = "Age",
    "age_squared" = "Age²",
    "SEX" = "Female",
    "has_disability" = "Has Disability",
    "log_income" = "Log Income",
    "has_medicare" = "Has Medicare"
  ),
  gof_map = c("nobs", "r.squared"),
  output = file.path(tab_dir, "table2_main_results.tex"),
  title = "Effect of Automation Exposure on Labor Force Exit"
)
message("Saved: table2_main_results.tex")

# ==============================================================================
# Table 3: Heterogeneous Effects
# ==============================================================================

message("\n=== Creating Table 3: Heterogeneous Effects ===")

het_table <- bind_rows(
  main_results$heterogeneity$by_education %>%
    mutate(dimension = "Education"),
  main_results$heterogeneity$by_age %>%
    mutate(dimension = "Age Group"),
  main_results$heterogeneity$by_sex %>%
    mutate(dimension = "Sex")
) %>%
  filter(!is.na(ate)) %>%
  mutate(
    estimate_fmt = sprintf("%.4f", ate),
    se_fmt = sprintf("(%.4f)", se),
    ci_fmt = sprintf("[%.4f, %.4f]", ci_lower, ci_upper),
    n_fmt = format(n, big.mark = ",")
  ) %>%
  select(dimension, subgroup, estimate_fmt, se_fmt, ci_fmt, n_fmt)

table3_latex <- kable(het_table, format = "latex", booktabs = TRUE,
                      caption = "Heterogeneous Effects by Subgroup",
                      col.names = c("Dimension", "Subgroup", "Estimate", "SE", "95\\% CI", "N"),
                      escape = FALSE) %>%
  kable_styling(latex_options = c("striped", "hold_position")) %>%
  collapse_rows(columns = 1, latex_hline = "major")

writeLines(table3_latex, file.path(tab_dir, "table3_heterogeneity.tex"))
write_csv(het_table, file.path(tab_dir, "table3_heterogeneity.csv"))
message("Saved: table3_heterogeneity.tex/csv")

# ==============================================================================
# Table 4: Robustness Checks
# ==============================================================================

message("\n=== Creating Table 4: Robustness Checks ===")

robustness_table <- tribble(
  ~Specification, ~Estimate, ~SE, ~Notes,
  "Main (OLS)", 
    sprintf("%.4f", main_results$ols$estimate), 
    sprintf("%.4f", main_results$ols$se), 
    "Baseline",
  "AIPW with Cross-Fitting", 
    sprintf("%.4f", main_results$aipw$estimate), 
    sprintf("%.4f", main_results$aipw$se), 
    "Preferred",
  "Continuous Treatment", 
    sprintf("%.4f", robustness_results$alternative_treatments$continuous$estimate), 
    sprintf("%.4f", robustness_results$alternative_treatments$continuous$se), 
    "Per unit increase",
  "Top vs Bottom Tercile", 
    sprintf("%.4f", robustness_results$alternative_treatments$tercile$estimate), 
    sprintf("%.4f", robustness_results$alternative_treatments$tercile$se), 
    "Extreme comparison",
  "With Industry FE", 
    sprintf("%.4f", robustness_results$fixed_effects$industry$estimate), 
    sprintf("%.4f", robustness_results$fixed_effects$industry$se), 
    "Within-industry variation",
  "With State FE", 
    sprintf("%.4f", robustness_results$fixed_effects$state$estimate), 
    sprintf("%.4f", robustness_results$fixed_effects$state$se), 
    "Within-state variation",
  "Excluding Disability", 
    sprintf("%.4f", robustness_results$subsamples$no_disability), 
    "—", 
    "Sample restriction",
  "Men Only", 
    sprintf("%.4f", robustness_results$subsamples$men), 
    "—", 
    "Sample restriction",
  "Women Only", 
    sprintf("%.4f", robustness_results$subsamples$women), 
    "—", 
    "Sample restriction"
)

table4_latex <- kable(robustness_table, format = "latex", booktabs = TRUE,
                      caption = "Robustness of Main Effect",
                      col.names = c("Specification", "Estimate", "SE", "Notes")) %>%
  kable_styling(latex_options = c("striped", "hold_position"))

writeLines(table4_latex, file.path(tab_dir, "table4_robustness.tex"))
write_csv(robustness_table, file.path(tab_dir, "table4_robustness.csv"))
message("Saved: table4_robustness.tex/csv")

# ==============================================================================
# Table 5: Negative Control Outcomes
# ==============================================================================

message("\n=== Creating Table 5: Negative Control Outcomes ===")

nc_table <- robustness_results$negative_controls %>%
  mutate(
    outcome = case_when(
      outcome == "homeowner" ~ "Homeownership",
      outcome == "married" ~ "Currently Married",
      outcome == "has_children" ~ "Has Children Present"
    ),
    estimate_fmt = sprintf("%.4f", estimate),
    se_fmt = sprintf("(%.4f)", se),
    p_fmt = sprintf("%.3f", p_value),
    significant = ifelse(p_value < 0.05, "*", "")
  ) %>%
  select(outcome, estimate_fmt, se_fmt, p_fmt, significant)

table5_latex <- kable(nc_table, format = "latex", booktabs = TRUE,
                      caption = "Negative Control Outcomes Test",
                      col.names = c("Outcome", "Estimate", "SE", "p-value", "")) %>%
  kable_styling(latex_options = c("striped", "hold_position")) %>%
  footnote(general = "Effects should be near zero if unconfoundedness holds.")

writeLines(table5_latex, file.path(tab_dir, "table5_negative_controls.tex"))
message("Saved: table5_negative_controls.tex")

# ==============================================================================
# Table 6: Sensitivity Analysis Summary
# ==============================================================================

message("\n=== Creating Table 6: Sensitivity Analysis ===")

sensitivity_table <- tribble(
  ~Measure, ~Value, ~Interpretation,
  "E-value (point estimate)", 
    sprintf("%.2f", robustness_results$sensitivity$e_value),
    "Required confounder strength to nullify",
  "Risk Ratio", 
    sprintf("%.3f", robustness_results$sensitivity$risk_ratio),
    "High vs Low automation groups",
  "Baseline Risk (Low Auto)", 
    sprintf("%.3f", robustness_results$sensitivity$baseline_risk),
    "Exit probability in control group"
)

table6_latex <- kable(sensitivity_table, format = "latex", booktabs = TRUE,
                      caption = "Sensitivity Analysis for Unmeasured Confounding") %>%
  kable_styling(latex_options = c("striped", "hold_position"))

writeLines(table6_latex, file.path(tab_dir, "table6_sensitivity.tex"))
message("Saved: table6_sensitivity.tex")

# ==============================================================================
# Summary
# ==============================================================================

message("\n=== Tables Complete ===")
message("Generated tables in ", tab_dir)

# List all tables
list.files(tab_dir, pattern = "\\.(tex|csv)$")
