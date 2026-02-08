# =============================================================================
# 03_main_analysis.R
# Primary AIPW estimation of self-employment effects on health insurance
# =============================================================================

source("00_packages.R")

# Load clean data
df <- readRDS(file.path(data_dir, "pums_clean.rds"))

cat("Analysis sample:", nrow(df), "observations\n")
cat("Self-employed:", sum(df$self_employed), "(", round(100*mean(df$self_employed), 1), "%)\n")

# =============================================================================
# Prepare Data for AIPW
# =============================================================================

# Create design matrix for covariates
# Note: AIPW requires numeric matrix

# Dummy encode categorical variables
df_model <- df %>%
  mutate(
    # Factor to dummy
    female = as.numeric(female),
    married = as.numeric(married),
    married_spouse_present = as.numeric(married_spouse_present),
    has_children = as.numeric(has_children),
    medicaid_expanded = as.numeric(medicaid_expanded)
  )

# Create dummies for categorical variables
race_dummies <- model.matrix(~ race - 1, data = df_model)[, -1]  # drop reference
educ_dummies <- model.matrix(~ educ - 1, data = df_model)[, -1]
income_dummies <- model.matrix(~ income_quintile - 1, data = df_model)[, -1]
occ_dummies <- model.matrix(~ occ_category - 1, data = df_model)[, -1]
ind_dummies <- model.matrix(~ ind_category - 1, data = df_model)[, -1]
state_dummies <- model.matrix(~ state - 1, data = df_model)[, -1]

# Combine covariates
W <- cbind(
  # Continuous
  df_model$age, df_model$age_sq,
  df_model$hours_worked, df_model$hours_worked_sq,
  df_model$household_size,

  # Binary
  df_model$female, df_model$married, df_model$married_spouse_present,
  df_model$has_children, df_model$medicaid_expanded,

  # Categorical dummies
  race_dummies,
  educ_dummies,
  income_dummies,
  occ_dummies,
  ind_dummies,
  state_dummies
)

# Clean column names
colnames(W) <- make.names(colnames(W), unique = TRUE)

cat("Covariate matrix dimensions:", dim(W), "\n")

# =============================================================================
# SuperLearner Library
# =============================================================================

# Define ML methods for nuisance estimation
# Use a mix of parametric and nonparametric methods
sl_lib <- c(
  "SL.glm",           # Logistic/linear regression
  "SL.glmnet",        # LASSO/elastic net
  "SL.ranger",        # Random forest
  "SL.xgboost"        # Gradient boosting
)

cat("SuperLearner library:", paste(sl_lib, collapse = ", "), "\n")

# =============================================================================
# Main AIPW Estimation
# =============================================================================

# Outcomes to analyze
outcomes <- c(
  "any_insurance",
  "private_coverage",
  "public_coverage",
  "employer_insurance",
  "direct_purchase",
  "medicaid"
)

# Storage for results
results <- list()

for (outcome in outcomes) {
  cat("\n=== Estimating effect on:", outcome, "===\n")

  Y <- df_model[[outcome]]

  # Run AIPW
  aipw_fit <- AIPW$new(
    Y = Y,
    A = df_model$self_employed,
    W = W,
    Q.SL.library = sl_lib,
    g.SL.library = sl_lib,
    k_split = 5,  # 5-fold cross-fitting
    verbose = FALSE
  )

  # Fit and summarize
  aipw_fit$fit()

  # Extract results
  res <- aipw_fit$summary()

  # ATT estimate (effect on the treated)
  att <- aipw_fit$result$ATT
  se_att <- aipw_fit$result$ATT.se

  cat("ATT estimate:", round(att, 4), "\n")
  cat("SE:", round(se_att, 4), "\n")
  cat("95% CI: [", round(att - 1.96*se_att, 4), ",",
      round(att + 1.96*se_att, 4), "]\n")

  # Store results
  results[[outcome]] <- list(
    outcome = outcome,
    att = att,
    se = se_att,
    ci_lower = att - 1.96*se_att,
    ci_upper = att + 1.96*se_att,
    p_value = 2 * pnorm(-abs(att / se_att)),
    aipw_obj = aipw_fit
  )
}

# =============================================================================
# Results Summary Table
# =============================================================================

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

cat("\n\n=== MAIN RESULTS: Effect of Self-Employment on Health Insurance ===\n\n")
print(results_df, n = Inf)

# =============================================================================
# Baseline Means for Comparison
# =============================================================================

baseline_means <- df_model %>%
  filter(self_employed == 0) %>%
  summarise(across(all_of(outcomes), ~ weighted.mean(., PWGTP, na.rm = TRUE)))

cat("\n=== Baseline Means (Wage Workers) ===\n")
print(t(baseline_means))

# Calculate effect sizes as % of baseline
cat("\n=== Effect Sizes (% of baseline) ===\n")
for (i in 1:nrow(results_df)) {
  outcome <- results_df$Outcome[i]
  baseline <- baseline_means[[outcome]]
  effect <- results_df$ATT[i]
  pct_effect <- 100 * effect / baseline
  cat(outcome, ":", round(pct_effect, 1), "%\n")
}

# =============================================================================
# Save Results
# =============================================================================

saveRDS(results, file.path(data_dir, "aipw_results.rds"))
saveRDS(results_df, file.path(data_dir, "aipw_results_df.rds"))

cat("\nResults saved to data directory.\n")

# =============================================================================
# Quick Propensity Score Diagnostics
# =============================================================================

cat("\n=== Propensity Score Diagnostics ===\n")

# Extract propensity scores from first model
ps <- results$any_insurance$aipw_obj$obs_est$ps_hat

cat("Propensity score summary:\n")
print(summary(ps))

# Check overlap
ps_by_treat <- split(ps, df_model$self_employed)
cat("\nPS by treatment status:\n")
cat("Wage workers - Mean:", round(mean(ps_by_treat[["0"]]), 4),
    "SD:", round(sd(ps_by_treat[["0"]]), 4), "\n")
cat("Self-employed - Mean:", round(mean(ps_by_treat[["1"]]), 4),
    "SD:", round(sd(ps_by_treat[["1"]]), 4), "\n")

# Extreme weights
extreme_low <- sum(ps < 0.01)
extreme_high <- sum(ps > 0.99)
cat("\nExtreme propensity scores:\n")
cat("PS < 0.01:", extreme_low, "(", round(100*extreme_low/length(ps), 2), "%)\n")
cat("PS > 0.99:", extreme_high, "(", round(100*extreme_high/length(ps), 2), "%)\n")
