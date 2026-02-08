# =============================================================================
# 03_analysis.R
# AIPW analysis of self-employment effects on health insurance
# =============================================================================

library(tidyverse)
library(AIPW)
library(SuperLearner)
library(sensemakr)
library(EValue)

set.seed(20260125)

# Load data
df <- read_csv("data/pums_clean.csv", show_col_types = FALSE)
cat("Loaded", nrow(df), "observations\n")

# Sample for faster estimation (10% random sample for initial run)
set.seed(42)
df_sample <- df %>% slice_sample(n = 300000)
cat("Using sample of", nrow(df_sample), "observations for analysis\n")

# =============================================================================
# Prepare covariates
# =============================================================================

# Create model matrix (numeric covariates for AIPW)
W <- model.matrix(
  ~ age + I(age^2) + female +
    race + educ + married +
    hours_worked + I(hours_worked^2) +
    household_size + income_quintile + medicaid_expanded - 1,
  data = df_sample
)

cat("Covariate matrix:", dim(W)[1], "x", dim(W)[2], "\n")

# =============================================================================
# Main AIPW Estimation
# =============================================================================

outcomes <- c("any_insurance", "employer_insurance", "direct_purchase", "medicaid")

sl_lib <- c("SL.glm", "SL.glmnet")  # Start with parametric methods

results <- list()

for (outcome in outcomes) {
  cat("\n=== Estimating effect on:", outcome, "===\n")

  Y <- df_sample[[outcome]]

  # Run AIPW
  aipw_fit <- AIPW$new(
    Y = Y,
    A = df_sample$self_employed,
    W = W,
    Q.SL.library = sl_lib,
    g.SL.library = sl_lib,
    k_split = 5,
    verbose = FALSE
  )

  aipw_fit$fit()

  # Get ATT
  att <- aipw_fit$result$ATT
  se <- aipw_fit$result$ATT.se

  cat("ATT:", round(att, 4), "\n")
  cat("SE:", round(se, 4), "\n")
  cat("95% CI: [", round(att - 1.96*se, 4), ",", round(att + 1.96*se, 4), "]\n")

  results[[outcome]] <- list(
    outcome = outcome,
    att = att,
    se = se,
    ci_lower = att - 1.96*se,
    ci_upper = att + 1.96*se,
    p_value = 2 * pnorm(-abs(att / se))
  )
}

# =============================================================================
# Results Summary
# =============================================================================

cat("\n\n========================================\n")
cat("MAIN RESULTS: Effect of Self-Employment\n")
cat("========================================\n\n")

results_df <- bind_rows(lapply(results, function(x) {
  tibble(
    Outcome = x$outcome,
    ATT = x$att,
    SE = x$se,
    CI_Lower = x$ci_lower,
    CI_Upper = x$ci_upper,
    P_Value = x$p_value
  )
}))

print(results_df)

# Baseline means
baseline <- df_sample %>%
  filter(self_employed == 0) %>%
  summarise(across(all_of(outcomes), mean))

cat("\nBaseline means (wage workers):\n")
print(baseline)

# Effect sizes as % of baseline
cat("\nEffect sizes (percentage points and % of baseline):\n")
for (i in 1:nrow(results_df)) {
  outcome <- results_df$Outcome[i]
  effect <- results_df$ATT[i]
  base <- baseline[[outcome]]
  cat(outcome, ": ", round(100*effect, 1), "pp (",
      round(100*effect/base, 1), "% of baseline)\n")
}

# =============================================================================
# Sensitivity Analysis
# =============================================================================

cat("\n\n========================================\n")
cat("SENSITIVITY ANALYSIS: E-Values\n")
cat("========================================\n\n")

for (i in 1:nrow(results_df)) {
  outcome <- results_df$Outcome[i]
  att <- results_df$ATT[i]
  ci <- results_df$CI_Lower[i]
  base <- as.numeric(baseline[[outcome]])

  # Risk ratio
  rr <- (base + att) / base

  if (rr > 0 && !is.na(rr)) {
    # E-value
    if (rr > 1) {
      ev_point <- rr + sqrt(rr * (rr - 1))
    } else {
      ev_point <- 1/rr + sqrt(1/rr * (1/rr - 1))
    }

    cat(outcome, ":\n")
    cat("  Risk Ratio:", round(rr, 3), "\n")
    cat("  E-value:", round(ev_point, 2), "\n\n")
  }
}

# =============================================================================
# OLS for comparison
# =============================================================================

cat("\n\n========================================\n")
cat("OLS COMPARISON (for sensemakr)\n")
cat("========================================\n\n")

ols_fit <- lm(
  any_insurance ~ self_employed + age + I(age^2) + female +
    race + educ + married + hours_worked + medicaid_expanded,
  data = df_sample
)

cat("OLS coefficient on self_employed:", round(coef(ols_fit)["self_employed"], 4), "\n")

# Sensemakr
sens <- sensemakr(
  model = ols_fit,
  treatment = "self_employed",
  benchmark_covariates = c("female", "married"),
  kd = 1:3
)

cat("\nSensitivity analysis (sensemakr):\n")
print(summary(sens))

# =============================================================================
# Save results
# =============================================================================

saveRDS(results_df, "data/aipw_results.rds")
cat("\nResults saved to data/aipw_results.rds\n")
