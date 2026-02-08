# ==============================================================================
# 04_robustness.R - Robustness Checks and Sensitivity Analysis
# Paper 110: Automation Exposure and Older Worker Labor Force Exit
# ==============================================================================

source("00_packages.R")

message("\n=== Loading Analysis Data ===")

df <- readRDS(file.path(data_dir, "analysis_data.rds"))
main_results <- readRDS(file.path(data_dir, "main_results.rds"))

message("Loaded ", nrow(df), " observations")

# ==============================================================================
# 1. Sensitivity Analysis: E-Values
# ==============================================================================

message("\n=== Sensitivity Analysis: E-Values ===")

# Convert ATE to risk ratio for E-value calculation
# ATE is a risk difference; need to convert using baseline risk

baseline_risk <- weighted.mean(
  df$not_in_labor_force[df$high_automation == 0], 
  df$PWGTP[df$high_automation == 0]
)
treated_risk <- weighted.mean(
  df$not_in_labor_force[df$high_automation == 1], 
  df$PWGTP[df$high_automation == 1]
)

risk_ratio <- treated_risk / baseline_risk
message("Baseline risk (low automation): ", round(baseline_risk, 3))
message("Treated risk (high automation): ", round(treated_risk, 3))
message("Risk ratio: ", round(risk_ratio, 3))

# E-value
# E-value = RR + sqrt(RR * (RR - 1))
e_value <- risk_ratio + sqrt(risk_ratio * (risk_ratio - 1))
message("\nE-value for point estimate: ", round(e_value, 2))
message("Interpretation: An unmeasured confounder would need risk ratios of at least ", 
        round(e_value, 2), " with both treatment and outcome to explain away the effect")

# Using EValue package for formal calculation
evalue_results <- tryCatch({
  EValue::evalue(est = risk_ratio, lo = 1.01)  # assuming RR > 1
}, error = function(e) {
  message("EValue package calculation failed: ", e$message)
  NULL
})

if (!is.null(evalue_results)) {
  message("\n--- E-Value Results ---")
  print(evalue_results)
}

# ==============================================================================
# 2. Calibrated Sensitivity Analysis (Cinelli-Hazlett)
# ==============================================================================

message("\n=== Calibrated Sensitivity Analysis ===")

# Prepare data for sensemakr
df_sensemakr <- df %>%
  select(not_in_labor_force, high_automation, AGEP, age_squared,
         SEX, education, race_ethnicity, married, has_disability,
         log_income, has_medicare, industry_broad, PWGTP, ST) %>%
  drop_na() %>%
  mutate(
    # Convert factors to numeric for sensemakr
    SEX_num = as.numeric(SEX),
    married_num = as.numeric(married),
    has_disability_num = as.numeric(has_disability),
    has_medicare_num = as.numeric(has_medicare)
  )

# Fit OLS for sensemakr
ols_sensemakr <- lm(
  not_in_labor_force ~ high_automation + AGEP + age_squared + 
    SEX_num + married_num + has_disability_num + log_income + has_medicare_num,
  data = df_sensemakr,
  weights = PWGTP
)

# Calibrated sensitivity analysis
sens_analysis <- tryCatch({
  sensemakr(
    model = ols_sensemakr,
    treatment = "high_automation",
    benchmark_covariates = c("has_disability_num", "has_medicare_num"),
    kd = 1:3
  )
}, error = function(e) {
  message("sensemakr failed: ", e$message)
  NULL
})

if (!is.null(sens_analysis)) {
  message("\n--- Sensitivity Analysis Results ---")
  print(summary(sens_analysis))
  
  # Save contour plot
  pdf(file.path(fig_dir, "sensitivity_contour.pdf"), width = 8, height = 6)
  plot(sens_analysis)
  dev.off()
  message("Saved: ", file.path(fig_dir, "sensitivity_contour.pdf"))
}

# ==============================================================================
# 3. Negative Control Outcomes
# ==============================================================================

message("\n=== Negative Control Outcomes ===")

# Outcomes that SHOULD NOT be affected by automation exposure:
# - Homeownership (determined earlier in life)
# - Marital status (unlikely affected by occupation)
# - Number of children (past fertility)

negative_controls <- c("homeowner", "married", "has_children")

nc_results <- map_dfr(negative_controls, function(outcome) {
  formula_nc <- as.formula(paste(outcome, "~ high_automation + AGEP + age_squared + 
                                  SEX + education + race_ethnicity + log_income"))
  
  fit_nc <- lm(formula_nc, data = df, weights = PWGTP)
  
  coef_nc <- coef(fit_nc)["high_automation"]
  se_nc <- sqrt(vcov(fit_nc)["high_automation", "high_automation"])
  
  data.frame(
    outcome = outcome,
    estimate = coef_nc,
    se = se_nc,
    t_stat = coef_nc / se_nc,
    p_value = 2 * (1 - pnorm(abs(coef_nc / se_nc)))
  )
})

message("\n--- Negative Control Results ---")
message("(Effects should be near zero if no residual confounding)")
print(nc_results)

# Flag concern if any negative control is significant
if (any(nc_results$p_value < 0.05)) {
  message("\nWARNING: Some negative control outcomes show significant effects!")
  message("This suggests potential residual confounding.")
} else {
  message("\nNegative control test PASSED: No significant effects on placebo outcomes")
}

# ==============================================================================
# 4. Alternative Treatment Definitions
# ==============================================================================

message("\n=== Alternative Treatment Definitions ===")

# Continuous treatment
message("\n--- Continuous Treatment ---")
ols_continuous <- lm(
  not_in_labor_force ~ automation_exposure + AGEP + age_squared + 
    SEX + education + race_ethnicity + married + has_disability + log_income,
  data = df,
  weights = PWGTP
)
continuous_effect <- coef(ols_continuous)["automation_exposure"]
continuous_se <- sqrt(vcov(ols_continuous)["automation_exposure", "automation_exposure"])
message("Effect of 1-unit increase in automation: ", round(continuous_effect, 4), 
        " (SE: ", round(continuous_se, 4), ")")

# Top vs bottom tercile
message("\n--- Top vs Bottom Tercile ---")
df_terciles <- df %>%
  filter(automation_tercile %in% c(1, 3)) %>%
  mutate(top_tercile = as.integer(automation_tercile == 3))

ols_tercile <- lm(
  not_in_labor_force ~ top_tercile + AGEP + age_squared + 
    SEX + education + race_ethnicity + married + has_disability + log_income,
  data = df_terciles,
  weights = PWGTP
)
tercile_effect <- coef(ols_tercile)["top_tercile"]
tercile_se <- sqrt(vcov(ols_tercile)["top_tercile", "top_tercile"])
message("Top vs Bottom tercile effect: ", round(tercile_effect, 4), 
        " (SE: ", round(tercile_se, 4), ")")

# ==============================================================================
# 5. Industry Fixed Effects
# ==============================================================================

message("\n=== Industry Fixed Effects Robustness ===")

ols_industry_fe <- lm(
  not_in_labor_force ~ high_automation + AGEP + age_squared + 
    SEX + education + race_ethnicity + married + has_disability + 
    log_income + industry_broad,
  data = df,
  weights = PWGTP
)
industry_fe_effect <- coef(ols_industry_fe)["high_automation"]
industry_fe_se <- sqrt(vcov(ols_industry_fe)["high_automation", "high_automation"])

message("Effect with industry FE: ", round(industry_fe_effect, 4), 
        " (SE: ", round(industry_fe_se, 4), ")")
message("Compare to main: ", round(main_results$ols$estimate, 4))

change_pct <- (industry_fe_effect - main_results$ols$estimate) / main_results$ols$estimate * 100
message("Change: ", round(change_pct, 1), "%")

# ==============================================================================
# 6. State Fixed Effects
# ==============================================================================

message("\n=== State Fixed Effects Robustness ===")

ols_state_fe <- lm(
  not_in_labor_force ~ high_automation + AGEP + age_squared + 
    SEX + education + race_ethnicity + married + has_disability + 
    log_income + factor(ST),
  data = df,
  weights = PWGTP
)
state_fe_effect <- coef(ols_state_fe)["high_automation"]
state_fe_se <- sqrt(vcov(ols_state_fe)["high_automation", "high_automation"])

message("Effect with state FE: ", round(state_fe_effect, 4), 
        " (SE: ", round(state_fe_se, 4), ")")

# ==============================================================================
# 7. Sample Restrictions
# ==============================================================================

message("\n=== Sample Restrictions Robustness ===")

# Excluding disability
df_no_disability <- df %>% filter(has_disability == 0)
ols_no_dis <- lm(
  not_in_labor_force ~ high_automation + AGEP + age_squared + 
    SEX + education + race_ethnicity + married + log_income,
  data = df_no_disability,
  weights = PWGTP
)
message("Excluding disability: ", round(coef(ols_no_dis)["high_automation"], 4))

# Men only
df_men <- df %>% filter(SEX == "Male")
ols_men <- lm(
  not_in_labor_force ~ high_automation + AGEP + age_squared + 
    education + race_ethnicity + married + has_disability + log_income,
  data = df_men,
  weights = PWGTP
)
message("Men only: ", round(coef(ols_men)["high_automation"], 4))

# Women only
df_women <- df %>% filter(SEX == "Female")
ols_women <- lm(
  not_in_labor_force ~ high_automation + AGEP + age_squared + 
    education + race_ethnicity + married + has_disability + log_income,
  data = df_women,
  weights = PWGTP
)
message("Women only: ", round(coef(ols_women)["high_automation"], 4))

# ==============================================================================
# 8. Save Robustness Results
# ==============================================================================

message("\n=== Saving Robustness Results ===")

robustness_results <- list(
  sensitivity = list(
    e_value = e_value,
    risk_ratio = risk_ratio,
    baseline_risk = baseline_risk,
    sensemakr = if(exists("sens_analysis")) sens_analysis else NULL
  ),
  negative_controls = nc_results,
  alternative_treatments = list(
    continuous = list(estimate = continuous_effect, se = continuous_se),
    tercile = list(estimate = tercile_effect, se = tercile_se)
  ),
  fixed_effects = list(
    industry = list(estimate = industry_fe_effect, se = industry_fe_se),
    state = list(estimate = state_fe_effect, se = state_fe_se)
  ),
  subsamples = list(
    no_disability = coef(ols_no_dis)["high_automation"],
    men = coef(ols_men)["high_automation"],
    women = coef(ols_women)["high_automation"]
  )
)

saveRDS(robustness_results, file.path(data_dir, "robustness_results.rds"))
message("Saved: ", file.path(data_dir, "robustness_results.rds"))

message("\n=== Robustness Checks Complete ===")
