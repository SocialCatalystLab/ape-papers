# =============================================================================
# 04_robustness.R
# Robustness Checks and Sensitivity Analysis
# =============================================================================

library(dplyr, warn.conflicts = FALSE)
library(readr)
library(tidyr)

message("=== STARTING ROBUSTNESS ANALYSIS ===")

df <- readRDS("output/paper_116/data/acs_clean.rds")
df_main <- df %>% filter(sample_main)

# =============================================================================
# 1. COVARIATE BALANCE
# =============================================================================

message("\n=== COVARIATE BALANCE ===")

balance <- df_main %>%
  group_by(self_employed) %>%
  summarize(
    age_mean = mean(AGEP),
    age_sd = sd(AGEP),
    female_mean = mean(female),
    married_mean = mean(married),
    college_mean = mean(college),
    disability_mean = mean(has_disability),
    .groups = "drop"
  )

wage <- balance %>% filter(!self_employed)
self <- balance %>% filter(self_employed)

# SMD calculations
smd_age <- (self$age_mean - wage$age_mean) / sqrt((self$age_sd^2 + wage$age_sd^2)/2)
smd_female <- (self$female_mean - wage$female_mean) / 
  sqrt((self$female_mean*(1-self$female_mean) + wage$female_mean*(1-wage$female_mean))/2)
smd_married <- (self$married_mean - wage$married_mean) / 
  sqrt((self$married_mean*(1-self$married_mean) + wage$married_mean*(1-wage$married_mean))/2)
smd_college <- (self$college_mean - wage$college_mean) / 
  sqrt((self$college_mean*(1-self$college_mean) + wage$college_mean*(1-wage$college_mean))/2)
smd_disability <- (self$disability_mean - wage$disability_mean) / 
  sqrt((self$disability_mean*(1-self$disability_mean) + wage$disability_mean*(1-wage$disability_mean))/2)

balance_smd <- tibble(
  Variable = c("Age", "Female", "Married", "College", "Disability"),
  Mean_Wage = c(wage$age_mean, wage$female_mean, wage$married_mean, 
                wage$college_mean, wage$disability_mean),
  Mean_SelfEmp = c(self$age_mean, self$female_mean, self$married_mean,
                   self$college_mean, self$disability_mean),
  SMD = c(smd_age, smd_female, smd_married, smd_college, smd_disability)
)

print(balance_smd)

# =============================================================================
# 2. YEAR-BY-YEAR EFFECTS
# =============================================================================

message("\n=== YEAR-BY-YEAR EFFECTS ===")

yearly_effects <- df_main %>%
  group_by(YEAR) %>%
  nest() %>%
  mutate(
    fit = purrr::map(data, ~lm(hours_weekly ~ self_employed + AGEP + female + 
                                 married + college + has_disability, data = .x)),
    coef = purrr::map(fit, ~{
      s <- summary(.x)$coefficients["self_employedTRUE", ]
      tibble(effect = s["Estimate"], se = s["Std. Error"])
    })
  ) %>%
  select(YEAR, coef) %>%
  tidyr::unnest(coef)

print(yearly_effects)

# =============================================================================
# 3. ALTERNATIVE OUTCOMES
# =============================================================================

message("\n=== ALTERNATIVE OUTCOMES ===")

outcomes <- list(
  hours = df_main$hours_weekly,
  part_time = as.numeric(df_main$part_time),
  log_income = df_main$log_income
)

outcome_results <- purrr::map_dfr(names(outcomes), function(out_name) {
  fit <- lm(outcomes[[out_name]] ~ df_main$self_employed + df_main$AGEP + 
              df_main$female + df_main$married + df_main$college + 
              df_main$has_disability)
  
  coef_info <- summary(fit)$coefficients["df_main$self_employedTRUE", ]
  
  tibble(
    outcome = out_name,
    estimate = coef_info["Estimate"],
    se = coef_info["Std. Error"],
    t_stat = coef_info["t value"]
  )
})

print(outcome_results)

# =============================================================================
# 4. MEDICAID EXPANSION HETEROGENEITY
# =============================================================================

message("\n=== MEDICAID EXPANSION HETEROGENEITY ===")

df_exp <- df_main %>% filter(medicaid_expansion)
df_noexp <- df_main %>% filter(!medicaid_expansion)

ols_exp <- lm(hours_weekly ~ self_employed + AGEP + female + married + 
                college + has_disability, data = df_exp)
ols_noexp <- lm(hours_weekly ~ self_employed + AGEP + female + married + 
                  college + has_disability, data = df_noexp)

expansion_results <- tibble(
  Group = c("Expansion States", "Non-Expansion States"),
  N = c(nrow(df_exp), nrow(df_noexp)),
  Self_Emp_Effect = c(
    coef(ols_exp)["self_employedTRUE"],
    coef(ols_noexp)["self_employedTRUE"]
  ),
  SE = c(
    summary(ols_exp)$coefficients["self_employedTRUE", "Std. Error"],
    summary(ols_noexp)$coefficients["self_employedTRUE", "Std. Error"]
  )
)

print(expansion_results)

# =============================================================================
# SAVE RESULTS
# =============================================================================

robustness <- list(
  balance = balance_smd,
  yearly_effects = yearly_effects,
  alternative_outcomes = outcome_results,
  expansion_heterogeneity = expansion_results
)

saveRDS(robustness, "output/paper_116/data/robustness_results.rds")
message("\nRobustness results saved")

message("\n=== ROBUSTNESS ANALYSIS COMPLETE ===")
