# =============================================================================
# 03_analysis_fast.R
# Quick OLS analysis for preliminary results
# =============================================================================

library(tidyverse)
library(sandwich)
library(lmtest)
library(sensemakr)

set.seed(20260125)

# Load data
df <- read_csv("data/pums_clean.csv", show_col_types = FALSE)
cat("Loaded", nrow(df), "observations\n")

# Use a sample for faster estimation
set.seed(42)
df_sample <- df %>% slice_sample(n = 500000)
cat("Using sample of", nrow(df_sample), "observations\n")

# =============================================================================
# Descriptive Statistics
# =============================================================================

cat("\n========================================\n")
cat("DESCRIPTIVE STATISTICS\n")
cat("========================================\n\n")

# By self-employment status
stats_by_group <- df_sample %>%
  group_by(self_employed) %>%
  summarise(
    n = n(),
    age_mean = mean(age),
    female_pct = 100 * mean(female),
    college_pct = 100 * mean(educ %in% c("Bachelors", "Graduate")),
    married_pct = 100 * mean(married),
    hours_mean = mean(hours_worked),
    any_insurance = 100 * mean(any_insurance),
    employer_ins = 100 * mean(employer_insurance),
    direct_purchase = 100 * mean(direct_purchase),
    medicaid = 100 * mean(medicaid),
    .groups = "drop"
  )

cat("Summary by Self-Employment Status:\n")
print(stats_by_group)

# =============================================================================
# OLS with Robust SEs
# =============================================================================

cat("\n========================================\n")
cat("OLS REGRESSION RESULTS\n")
cat("========================================\n\n")

outcomes <- c("any_insurance", "employer_insurance", "direct_purchase", "medicaid")

results <- list()

for (outcome in outcomes) {
  cat("\n--- Outcome:", outcome, "---\n")

  formula <- as.formula(paste(
    outcome,
    "~ self_employed + age + I(age^2) + female + race + educ +",
    "married + hours_worked + I(hours_worked^2) + household_size +",
    "income_quintile + medicaid_expanded + factor(state)"
  ))

  fit <- lm(formula, data = df_sample)

  # Robust SEs (HC2)
  robust_se <- sqrt(diag(vcovHC(fit, type = "HC2")))

  coef_se <- robust_se["self_employed"]
  coef_est <- coef(fit)["self_employed"]

  ci_lower <- coef_est - 1.96 * coef_se
  ci_upper <- coef_est + 1.96 * coef_se
  p_value <- 2 * pnorm(-abs(coef_est / coef_se))

  cat("Coefficient:", round(coef_est, 4), "\n")
  cat("Robust SE:", round(coef_se, 4), "\n")
  cat("95% CI: [", round(ci_lower, 4), ",", round(ci_upper, 4), "]\n")
  cat("p-value:", format(p_value, digits = 3), "\n")

  results[[outcome]] <- list(
    outcome = outcome,
    coef = coef_est,
    se = coef_se,
    ci_lower = ci_lower,
    ci_upper = ci_upper,
    p_value = p_value,
    r_squared = summary(fit)$r.squared,
    n = nrow(model.matrix(fit))
  )
}

# =============================================================================
# Results Summary Table
# =============================================================================

results_df <- bind_rows(lapply(results, function(x) {
  tibble(
    Outcome = x$outcome,
    Coefficient = x$coef,
    SE = x$se,
    CI_Lower = x$ci_lower,
    CI_Upper = x$ci_upper,
    P_Value = x$p_value,
    R_Squared = x$r_squared,
    N = x$n
  )
}))

cat("\n========================================\n")
cat("SUMMARY: Effect of Self-Employment\n")
cat("========================================\n\n")

print(results_df)

# Baseline means
baseline <- df_sample %>%
  filter(self_employed == 0) %>%
  summarise(across(all_of(outcomes), mean))

cat("\nBaseline means (wage workers):\n")
print(baseline)

# Effect sizes
cat("\nEffect sizes (percentage points):\n")
for (i in 1:nrow(results_df)) {
  outcome <- results_df$Outcome[i]
  effect <- results_df$Coefficient[i]
  base <- baseline[[outcome]]
  cat(outcome, ": ", round(100*effect, 1), "pp (",
      round(100*effect/base, 1), "% change from baseline of ",
      round(100*base, 1), "%)\n")
}

# =============================================================================
# Sensitivity Analysis
# =============================================================================

cat("\n========================================\n")
cat("SENSITIVITY ANALYSIS (sensemakr)\n")
cat("========================================\n\n")

# Run on any_insurance
formula_sens <- any_insurance ~ self_employed + age + I(age^2) + female +
  race + educ + married + hours_worked + medicaid_expanded

fit_sens <- lm(formula_sens, data = df_sample)

sens <- sensemakr(
  model = fit_sens,
  treatment = "self_employed",
  benchmark_covariates = c("female", "married"),
  kd = 1:3
)

cat("Sensitivity of 'any_insurance' effect:\n\n")
print(summary(sens))

# =============================================================================
# Subgroup Analysis
# =============================================================================

cat("\n========================================\n")
cat("SUBGROUP ANALYSIS\n")
cat("========================================\n\n")

# By Medicaid expansion status
for (expanded in c(0, 1)) {
  subset <- df_sample %>% filter(medicaid_expanded == expanded)
  label <- ifelse(expanded == 1, "Expansion States", "Non-Expansion States")

  fit <- lm(any_insurance ~ self_employed + age + I(age^2) + female +
              race + educ + married + hours_worked,
            data = subset)

  robust_se <- sqrt(diag(vcovHC(fit, type = "HC2")))["self_employed"]
  coef_est <- coef(fit)["self_employed"]

  cat(label, ":\n")
  cat("  Effect:", round(coef_est, 4), "SE:", round(robust_se, 4), "\n")
}

# By income
for (income_group in c("Q1", "Q2", "Q4", "Q5")) {
  subset <- df_sample %>% filter(income_quintile == income_group)

  fit <- lm(any_insurance ~ self_employed + age + I(age^2) + female +
              race + educ + married + hours_worked + medicaid_expanded,
            data = subset)

  robust_se <- sqrt(diag(vcovHC(fit, type = "HC2")))["self_employed"]
  coef_est <- coef(fit)["self_employed"]

  cat("Income", income_group, ":\n")
  cat("  Effect:", round(coef_est, 4), "SE:", round(robust_se, 4), "\n")
}

# =============================================================================
# Save results
# =============================================================================

saveRDS(results_df, "data/ols_results.rds")
saveRDS(stats_by_group, "data/descriptive_stats.rds")

cat("\n\nResults saved to data/ols_results.rds\n")
