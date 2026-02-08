# =============================================================================
# 04_robustness.R
# Robustness checks and sensitivity analysis
# =============================================================================

source("00_packages.R")

# Load data and results
df <- readRDS(file.path(data_dir, "pums_clean.rds"))
results <- readRDS(file.path(data_dir, "aipw_results.rds"))
results_df <- readRDS(file.path(data_dir, "aipw_results_df.rds"))

cat("Loaded analysis results.\n")

# =============================================================================
# 1. SUBGROUP ANALYSIS
# =============================================================================

cat("\n=== SUBGROUP ANALYSIS ===\n")

# Function to run AIPW on subgroup
run_subgroup_aipw <- function(data, outcome_var, group_name) {
  cat("Running AIPW for subgroup:", group_name, "\n")

  # Prepare covariates (simplified for subgroups)
  W <- model.matrix(
    ~ age + I(age^2) + female + race + educ +
      married + hours_worked + income_quintile - 1,
    data = data
  )

  sl_lib <- c("SL.glm", "SL.ranger")

  aipw_fit <- AIPW$new(
    Y = data[[outcome_var]],
    A = data$self_employed,
    W = W,
    Q.SL.library = sl_lib,
    g.SL.library = sl_lib,
    k_split = 5,
    verbose = FALSE
  )

  aipw_fit$fit()

  att <- aipw_fit$result$ATT
  se <- aipw_fit$result$ATT.se

  tibble(
    subgroup = group_name,
    outcome = outcome_var,
    att = att,
    se = se,
    ci_lower = att - 1.96*se,
    ci_upper = att + 1.96*se
  )
}

# Subgroup: Medicaid expansion states vs non-expansion
subgroup_results <- list()

# By Medicaid expansion
for (expanded in c(TRUE, FALSE)) {
  subset_data <- df %>% filter(expanded == !!expanded)
  label <- ifelse(expanded, "Medicaid Expansion States", "Non-Expansion States")

  res <- run_subgroup_aipw(subset_data, "any_insurance", label)
  subgroup_results[[paste0("medicaid_exp_", expanded)]] <- res
}

# By income quintile (low vs high)
low_income <- df %>% filter(income_quintile %in% c("Q1 (Lowest)", "Q2"))
high_income <- df %>% filter(income_quintile %in% c("Q4", "Q5 (Highest)"))

subgroup_results[["low_income"]] <- run_subgroup_aipw(low_income, "any_insurance", "Low Income (Q1-Q2)")
subgroup_results[["high_income"]] <- run_subgroup_aipw(high_income, "any_insurance", "High Income (Q4-Q5)")

# By marital status
married <- df %>% filter(married_spouse_present == 1)
unmarried <- df %>% filter(married_spouse_present == 0)

subgroup_results[["married"]] <- run_subgroup_aipw(married, "any_insurance", "Married (Spouse Present)")
subgroup_results[["unmarried"]] <- run_subgroup_aipw(unmarried, "any_insurance", "Not Married")

# By self-employment type (for employer insurance)
incorporated <- df %>% filter(se_type == "Incorporated" | self_employed == 0)
incorporated$self_employed <- as.integer(df$se_type[df$se_type == "Incorporated" | df$self_employed == 0] == "Incorporated")

unincorporated <- df %>% filter(se_type == "Unincorporated" | self_employed == 0)
unincorporated$self_employed <- as.integer(df$se_type[df$se_type == "Unincorporated" | df$self_employed == 0] == "Unincorporated")

# Combine subgroup results
subgroup_df <- bind_rows(subgroup_results)
cat("\nSubgroup Analysis Results:\n")
print(subgroup_df)

# =============================================================================
# 2. NEGATIVE CONTROL OUTCOMES
# =============================================================================

cat("\n=== NEGATIVE CONTROL OUTCOMES ===\n")

# Medicare coverage for under-65 sample (should be near zero effect)
# Note: Some under-65 have Medicare due to disability, but self-employment
# shouldn't directly affect disability-based Medicare eligibility

under_65 <- df %>% filter(age < 65)

cat("Under-65 sample size:", nrow(under_65), "\n")
cat("Medicare coverage rate:", round(100*mean(under_65$medicare), 2), "%\n")

# Run AIPW for Medicare as negative control
W_nc <- model.matrix(
  ~ age + I(age^2) + female + race + educ +
    married + hours_worked + income_quintile - 1,
  data = under_65
)

sl_lib <- c("SL.glm", "SL.ranger")

nc_aipw <- AIPW$new(
  Y = under_65$medicare,
  A = under_65$self_employed,
  W = W_nc,
  Q.SL.library = sl_lib,
  g.SL.library = sl_lib,
  k_split = 5,
  verbose = FALSE
)
nc_aipw$fit()

nc_att <- nc_aipw$result$ATT
nc_se <- nc_aipw$result$ATT.se

cat("\nNegative Control: Effect on Medicare (under-65)\n")
cat("ATT:", round(nc_att, 4), "\n")
cat("SE:", round(nc_se, 4), "\n")
cat("95% CI: [", round(nc_att - 1.96*nc_se, 4), ",",
    round(nc_att + 1.96*nc_se, 4), "]\n")

if (abs(nc_att / nc_se) > 1.96) {
  cat("WARNING: Negative control shows significant effect - potential confounding\n")
} else {
  cat("PASS: Negative control shows no significant effect\n")
}

# =============================================================================
# 3. SENSITIVITY ANALYSIS: E-VALUES
# =============================================================================

cat("\n=== SENSITIVITY ANALYSIS: E-VALUES ===\n")

# For each main outcome, calculate E-value
evalue_results <- list()

for (i in 1:nrow(results_df)) {
  outcome <- results_df$Outcome[i]
  att <- results_df$ATT[i]
  ci_lower <- results_df$CI_Lower[i]

  # Get baseline risk
  baseline_risk <- mean(df[[outcome]][df$self_employed == 0])

  # Convert to risk ratio
  # ATT = P(Y=1|T=1) - P(Y=1|T=0)
  # RR = P(Y=1|T=1) / P(Y=1|T=0) = (baseline + ATT) / baseline
  if (baseline_risk > 0) {
    rr_point <- (baseline_risk + att) / baseline_risk
    rr_lower <- (baseline_risk + ci_lower) / baseline_risk
  } else {
    rr_point <- NA
    rr_lower <- NA
  }

  # Calculate E-value
  if (!is.na(rr_point) && rr_point > 0) {
    ev <- evalues.RR(rr_point, lo = rr_lower)

    evalue_results[[outcome]] <- tibble(
      outcome = outcome,
      att = att,
      risk_ratio = rr_point,
      e_value_point = ev$point[2],
      e_value_ci = ev$lower[2]
    )

    cat("\n", outcome, ":\n")
    cat("  Risk Ratio:", round(rr_point, 3), "\n")
    cat("  E-value (point):", round(ev$point[2], 2), "\n")
    cat("  E-value (CI):", round(ev$lower[2], 2), "\n")
  }
}

evalue_df <- bind_rows(evalue_results)

# =============================================================================
# 4. CALIBRATED SENSITIVITY (OLS BENCHMARK)
# =============================================================================

cat("\n=== CALIBRATED SENSITIVITY ANALYSIS ===\n")

# Run OLS for sensitivity benchmarking
ols_fit <- lm(
  any_insurance ~ self_employed + age + I(age^2) + female +
    race + educ + married + hours_worked + income_quintile +
    medicaid_expanded,
  data = df
)

# Run sensemakr
sens <- sensemakr(
  model = ols_fit,
  treatment = "self_employed",
  benchmark_covariates = c("female", "married"),  # Benchmark confounders
  kd = 1:3  # Multiples of benchmark strength
)

cat("\nOLS estimate:", round(coef(ols_fit)["self_employed"], 4), "\n")
cat("\nSensitivity to unobserved confounding:\n")
print(summary(sens))

# =============================================================================
# 5. ALTERNATIVE SPECIFICATIONS
# =============================================================================

cat("\n=== ALTERNATIVE SPECIFICATIONS ===\n")

# 5a. No state fixed effects
cat("\n5a. Without state fixed effects:\n")
W_no_state <- model.matrix(
  ~ age + I(age^2) + female + race + educ +
    married + hours_worked + income_quintile + occ_category - 1,
  data = df
)

aipw_no_state <- AIPW$new(
  Y = df$any_insurance,
  A = df$self_employed,
  W = W_no_state,
  Q.SL.library = c("SL.glm", "SL.ranger"),
  g.SL.library = c("SL.glm", "SL.ranger"),
  k_split = 5,
  verbose = FALSE
)
aipw_no_state$fit()

cat("ATT (no state FE):", round(aipw_no_state$result$ATT, 4), "\n")
cat("SE:", round(aipw_no_state$result$ATT.se, 4), "\n")

# 5b. Different ML methods (just GLM)
cat("\n5b. Parametric only (GLM):\n")

W_full <- model.matrix(
  ~ age + I(age^2) + female + race + educ +
    married + hours_worked + income_quintile + state - 1,
  data = df
)

aipw_glm <- AIPW$new(
  Y = df$any_insurance,
  A = df$self_employed,
  W = W_full,
  Q.SL.library = "SL.glm",
  g.SL.library = "SL.glm",
  k_split = 5,
  verbose = FALSE
)
aipw_glm$fit()

cat("ATT (GLM only):", round(aipw_glm$result$ATT, 4), "\n")
cat("SE:", round(aipw_glm$result$ATT.se, 4), "\n")

# =============================================================================
# 6. TRIMMED SAMPLE (POSITIVITY)
# =============================================================================

cat("\n=== TRIMMED SAMPLE (PROPENSITY SCORE OVERLAP) ===\n")

# Get propensity scores from main analysis
ps <- results$any_insurance$aipw_obj$obs_est$ps_hat

# Trim extreme propensity scores
trim_low <- 0.02
trim_high <- 0.98

in_overlap <- ps >= trim_low & ps <= trim_high
cat("Observations in overlap region:", sum(in_overlap),
    "(", round(100*mean(in_overlap), 1), "%)\n")

df_trimmed <- df[in_overlap, ]

# Re-run AIPW on trimmed sample
W_trimmed <- model.matrix(
  ~ age + I(age^2) + female + race + educ +
    married + hours_worked + income_quintile - 1,
  data = df_trimmed
)

aipw_trimmed <- AIPW$new(
  Y = df_trimmed$any_insurance,
  A = df_trimmed$self_employed,
  W = W_trimmed,
  Q.SL.library = c("SL.glm", "SL.ranger"),
  g.SL.library = c("SL.glm", "SL.ranger"),
  k_split = 5,
  verbose = FALSE
)
aipw_trimmed$fit()

cat("ATT (trimmed):", round(aipw_trimmed$result$ATT, 4), "\n")
cat("SE:", round(aipw_trimmed$result$ATT.se, 4), "\n")

# =============================================================================
# Save Robustness Results
# =============================================================================

robustness_results <- list(
  subgroup = subgroup_df,
  negative_control = tibble(
    outcome = "medicare_under65",
    att = nc_att,
    se = nc_se
  ),
  evalues = evalue_df,
  sensemakr = sens,
  alt_specs = tibble(
    specification = c("Main", "No State FE", "GLM Only", "Trimmed (2-98%)"),
    att = c(results_df$ATT[results_df$Outcome == "any_insurance"],
            aipw_no_state$result$ATT,
            aipw_glm$result$ATT,
            aipw_trimmed$result$ATT),
    se = c(results_df$SE[results_df$Outcome == "any_insurance"],
           aipw_no_state$result$ATT.se,
           aipw_glm$result$ATT.se,
           aipw_trimmed$result$ATT.se)
  )
)

saveRDS(robustness_results, file.path(data_dir, "robustness_results.rds"))

cat("\n\nRobustness results saved.\n")

# =============================================================================
# Summary
# =============================================================================

cat("\n=== ROBUSTNESS SUMMARY ===\n\n")

cat("Alternative Specifications:\n")
print(robustness_results$alt_specs)

cat("\nSubgroup Analysis (Any Insurance):\n")
print(subgroup_df %>% filter(outcome == "any_insurance"))

cat("\nNegative Control (Medicare, under-65):\n")
cat("ATT:", round(nc_att, 4), "SE:", round(nc_se, 4), "\n")
cat("Interpretation:", ifelse(abs(nc_att/nc_se) < 1.96, "PASS", "WARNING"), "\n")
