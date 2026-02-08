# =============================================================================
# 08_heterogeneity.R
# Calculate heterogeneity estimates with proper sample sizes
# =============================================================================

library(tidyverse)
library(sandwich)

# Load 2022 sample data
df <- read_csv("/Users/dyanag/auto-policy-evals/output/paper_1/data/pums_sample.csv",
               show_col_types = FALSE)

cat("Sample size:", nrow(df), "\n")

# Expansion vs Non-expansion
cat("\n=== By Medicaid Expansion ===\n")
for (exp in c(0, 1)) {
  sub <- df %>% filter(medicaid_expanded == exp)
  fit <- lm(any_insurance ~ self_employed + age + I(age^2) + female +
              race + educ + married + hours_worked + factor(state), data = sub)
  robust_se <- sqrt(diag(vcovHC(fit, type = "HC2")))["self_employed"]
  coef_est <- coef(fit)["self_employed"]
  label <- ifelse(exp == 1, "Expansion", "Non-Expansion")
  cat(label, ": Effect =", round(coef_est, 4), "SE =", round(robust_se, 4),
      "N =", nrow(model.matrix(fit)), "\n")
}

# By Income Quintile
cat("\n=== By Income Quintile ===\n")
for (q in c("Q1", "Q2", "Q3", "Q4", "Q5")) {
  sub <- df %>% filter(income_quintile == q)
  if (nrow(sub) < 100) {
    cat(q, ": Insufficient data\n")
    next
  }
  fit <- lm(any_insurance ~ self_employed + age + I(age^2) + female +
              race + educ + married + hours_worked + medicaid_expanded + factor(state),
            data = sub)
  robust_se <- sqrt(diag(vcovHC(fit, type = "HC2")))["self_employed"]
  coef_est <- coef(fit)["self_employed"]
  cat(q, ": Effect =", round(coef_est, 4), "SE =", round(robust_se, 4),
      "N =", nrow(model.matrix(fit)), "\n")
}
