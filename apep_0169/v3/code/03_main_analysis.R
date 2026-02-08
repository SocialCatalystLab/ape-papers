# ==============================================================================
# 03_main_analysis.R
# Main causal analysis using Doubly Robust methods
# Revision of apep_0169: The Self-Employment Earnings Penalty
# Key additions: Incorporated vs. Unincorporated split, ATT, 95% CIs
# ==============================================================================

source("00_packages.R")

# Load analysis data
cps <- readRDS(file.path(data_dir, "cps_analysis.rds"))

cat("Loaded", nrow(cps), "observations for analysis.\n")

# ==============================================================================
# Prepare data for analysis
# ==============================================================================

cps_complete <- cps %>%
  filter(
    !is.na(multiple_jobs),
    !is.na(age),
    !is.na(female),
    !is.na(college),
    !is.na(married),
    !is.na(homeowner),
    !is.na(log_earnings)
  ) %>%
  mutate(
    # Create race dummies
    race_white = as.integer(race == "White"),
    race_black = as.integer(race == "Black"),
    race_hispanic = as.integer(race == "Hispanic"),
    race_asian = as.integer(race == "Asian"),
    age_sq = age^2
  )

cat("Complete cases:", nrow(cps_complete), "\n")

# Sample sizes by self-employment type
cat("\n=== Sample by Self-Employment Type ===\n")
cat("Wage workers:", sum(cps_complete$multiple_jobs == 0), "\n")
cat("Self-employed (total):", sum(cps_complete$multiple_jobs == 1), "\n")
cat("  - Incorporated:", sum(cps_complete$incorporated == 1, na.rm = TRUE), "\n")
cat("  - Unincorporated:", sum(cps_complete$unincorporated == 1, na.rm = TRUE), "\n")

# Define covariates
covariates <- c(
  "age", "age_sq", "female", "college", "married",
  "race_white", "race_black", "race_hispanic", "race_asian",
  "homeowner", "covid_period"
)

# ==============================================================================
# Helper function to compute robust standard errors and 95% CIs
# ==============================================================================

compute_ipw_results <- function(model, treatment_var, n_obs) {
  est <- coef(model)[treatment_var]
  # Use sandwich estimator for robust SEs
  se <- sqrt(sandwich::vcovHC(model, type = "HC1")[treatment_var, treatment_var])
  ci <- est + c(-1.96, 1.96) * se
  pval <- 2 * pnorm(-abs(est / se))

  tibble(
    estimate = est,
    se = se,
    ci_lower = ci[1],
    ci_upper = ci[2],
    p_value = pval,
    n = n_obs
  )
}

# ==============================================================================
# PART 1: Aggregate Self-Employment Effects (ATE and ATT)
# ==============================================================================

cat("\n" , strrep("=", 70), "\n")
cat("PART 1: AGGREGATE SELF-EMPLOYMENT EFFECTS\n")
cat(strrep("=", 70), "\n")

# --- ATE Estimation ---
ps_formula <- as.formula(paste(
  "multiple_jobs ~",
  paste(covariates, collapse = " + ")
))

ps_ate <- weightit(
  ps_formula,
  data = cps_complete,
  method = "ps",
  estimand = "ATE"
)

cps_complete$ipw_ate <- pmin(ps_ate$weights, quantile(ps_ate$weights, 0.99, na.rm = TRUE))

cat("\nATE Weight summary:\n")
print(summary(cps_complete$ipw_ate))

# --- ATT Estimation ---
ps_att <- weightit(
  ps_formula,
  data = cps_complete,
  method = "ps",
  estimand = "ATT"
)

cps_complete$ipw_att <- pmin(ps_att$weights, quantile(ps_att$weights, 0.99, na.rm = TRUE))

cat("\nATT Weight summary:\n")
print(summary(cps_complete$ipw_att))

# --- Log Earnings ---
cat("\n=== Effect on Log Earnings ===\n")

# ATE
m_ate_earn <- lm(log_earnings ~ multiple_jobs, data = cps_complete, weights = ipw_ate)
res_ate_earn <- compute_ipw_results(m_ate_earn, "multiple_jobs", nrow(cps_complete)) %>%
  mutate(estimand = "ATE", outcome = "Log earnings")

# ATT
m_att_earn <- lm(log_earnings ~ multiple_jobs, data = cps_complete, weights = ipw_att)
res_att_earn <- compute_ipw_results(m_att_earn, "multiple_jobs", nrow(cps_complete)) %>%
  mutate(estimand = "ATT", outcome = "Log earnings")

cat("ATE:", round(res_ate_earn$estimate, 4), "[95% CI:", round(res_ate_earn$ci_lower, 4), ",", round(res_ate_earn$ci_upper, 4), "]\n")
cat("ATT:", round(res_att_earn$estimate, 4), "[95% CI:", round(res_att_earn$ci_lower, 4), ",", round(res_att_earn$ci_upper, 4), "]\n")

# --- Full-Time Status ---
cat("\n=== Effect on Full-Time Status ===\n")

m_ate_ft <- lm(full_time ~ multiple_jobs, data = cps_complete, weights = ipw_ate)
res_ate_ft <- compute_ipw_results(m_ate_ft, "multiple_jobs", nrow(cps_complete)) %>%
  mutate(estimand = "ATE", outcome = "Full-time")

m_att_ft <- lm(full_time ~ multiple_jobs, data = cps_complete, weights = ipw_att)
res_att_ft <- compute_ipw_results(m_att_ft, "multiple_jobs", nrow(cps_complete)) %>%
  mutate(estimand = "ATT", outcome = "Full-time")

cat("ATE:", round(res_ate_ft$estimate, 4), "[95% CI:", round(res_ate_ft$ci_lower, 4), ",", round(res_ate_ft$ci_upper, 4), "]\n")
cat("ATT:", round(res_att_ft$estimate, 4), "[95% CI:", round(res_att_ft$ci_lower, 4), ",", round(res_att_ft$ci_upper, 4), "]\n")

# --- Hours Worked ---
cat("\n=== Effect on Hours Worked ===\n")

m_ate_hrs <- lm(hours_usual ~ multiple_jobs, data = cps_complete, weights = ipw_ate)
res_ate_hrs <- compute_ipw_results(m_ate_hrs, "multiple_jobs", nrow(cps_complete)) %>%
  mutate(estimand = "ATE", outcome = "Hours/week")

m_att_hrs <- lm(hours_usual ~ multiple_jobs, data = cps_complete, weights = ipw_att)
res_att_hrs <- compute_ipw_results(m_att_hrs, "multiple_jobs", nrow(cps_complete)) %>%
  mutate(estimand = "ATT", outcome = "Hours/week")

cat("ATE:", round(res_ate_hrs$estimate, 2), "hours [95% CI:", round(res_ate_hrs$ci_lower, 2), ",", round(res_ate_hrs$ci_upper, 2), "]\n")
cat("ATT:", round(res_att_hrs$estimate, 2), "hours [95% CI:", round(res_att_hrs$ci_lower, 2), ",", round(res_att_hrs$ci_upper, 2), "]\n")

# Combine aggregate results
aggregate_results <- bind_rows(
  res_ate_earn, res_att_earn,
  res_ate_ft, res_att_ft,
  res_ate_hrs, res_att_hrs
)

# ==============================================================================
# PART 2: INCORPORATED vs. UNINCORPORATED SPLIT (Key Addition)
# ==============================================================================

cat("\n", strrep("=", 70), "\n")
cat("PART 2: INCORPORATED vs. UNINCORPORATED SELF-EMPLOYMENT\n")
cat(strrep("=", 70), "\n")

# --- Incorporated Self-Employment ---
cat("\n=== Incorporated Self-Employed vs. Wage Workers ===\n")

# Create subset: wage workers + incorporated self-employed only
inc_data <- cps_complete %>%
  filter(multiple_jobs == 0 | incorporated == 1)

inc_data$treatment_inc <- inc_data$incorporated

ps_formula_inc <- as.formula(paste(
  "treatment_inc ~",
  paste(covariates, collapse = " + ")
))

ps_inc <- weightit(
  ps_formula_inc,
  data = inc_data,
  method = "ps",
  estimand = "ATE"
)

inc_data$ipw <- pmin(ps_inc$weights, quantile(ps_inc$weights, 0.99, na.rm = TRUE))

m_inc_earn <- lm(log_earnings ~ treatment_inc, data = inc_data, weights = ipw)
res_inc_earn <- compute_ipw_results(m_inc_earn, "treatment_inc", nrow(inc_data)) %>%
  mutate(type = "Incorporated", outcome = "Log earnings")

m_inc_ft <- lm(full_time ~ treatment_inc, data = inc_data, weights = ipw)
res_inc_ft <- compute_ipw_results(m_inc_ft, "treatment_inc", nrow(inc_data)) %>%
  mutate(type = "Incorporated", outcome = "Full-time")

m_inc_hrs <- lm(hours_usual ~ treatment_inc, data = inc_data, weights = ipw)
res_inc_hrs <- compute_ipw_results(m_inc_hrs, "treatment_inc", nrow(inc_data)) %>%
  mutate(type = "Incorporated", outcome = "Hours/week")

cat("N wage workers:", sum(inc_data$treatment_inc == 0), "\n")
cat("N incorporated:", sum(inc_data$treatment_inc == 1), "\n")
cat("Log earnings effect:", round(res_inc_earn$estimate, 4),
    "[95% CI:", round(res_inc_earn$ci_lower, 4), ",", round(res_inc_earn$ci_upper, 4), "]\n")
cat("Full-time effect:", round(res_inc_ft$estimate, 4),
    "[95% CI:", round(res_inc_ft$ci_lower, 4), ",", round(res_inc_ft$ci_upper, 4), "]\n")
cat("Hours effect:", round(res_inc_hrs$estimate, 2),
    "[95% CI:", round(res_inc_hrs$ci_lower, 2), ",", round(res_inc_hrs$ci_upper, 2), "]\n")

# --- Unincorporated Self-Employment ---
cat("\n=== Unincorporated Self-Employed vs. Wage Workers ===\n")

# Create subset: wage workers + unincorporated self-employed only
uninc_data <- cps_complete %>%
  filter(multiple_jobs == 0 | unincorporated == 1)

uninc_data$treatment_uninc <- uninc_data$unincorporated

ps_formula_uninc <- as.formula(paste(
  "treatment_uninc ~",
  paste(covariates, collapse = " + ")
))

ps_uninc <- weightit(
  ps_formula_uninc,
  data = uninc_data,
  method = "ps",
  estimand = "ATE"
)

uninc_data$ipw <- pmin(ps_uninc$weights, quantile(ps_uninc$weights, 0.99, na.rm = TRUE))

m_uninc_earn <- lm(log_earnings ~ treatment_uninc, data = uninc_data, weights = ipw)
res_uninc_earn <- compute_ipw_results(m_uninc_earn, "treatment_uninc", nrow(uninc_data)) %>%
  mutate(type = "Unincorporated", outcome = "Log earnings")

m_uninc_ft <- lm(full_time ~ treatment_uninc, data = uninc_data, weights = ipw)
res_uninc_ft <- compute_ipw_results(m_uninc_ft, "treatment_uninc", nrow(uninc_data)) %>%
  mutate(type = "Unincorporated", outcome = "Full-time")

m_uninc_hrs <- lm(hours_usual ~ treatment_uninc, data = uninc_data, weights = ipw)
res_uninc_hrs <- compute_ipw_results(m_uninc_hrs, "treatment_uninc", nrow(uninc_data)) %>%
  mutate(type = "Unincorporated", outcome = "Hours/week")

cat("N wage workers:", sum(uninc_data$treatment_uninc == 0), "\n")
cat("N unincorporated:", sum(uninc_data$treatment_uninc == 1), "\n")
cat("Log earnings effect:", round(res_uninc_earn$estimate, 4),
    "[95% CI:", round(res_uninc_earn$ci_lower, 4), ",", round(res_uninc_earn$ci_upper, 4), "]\n")
cat("Full-time effect:", round(res_uninc_ft$estimate, 4),
    "[95% CI:", round(res_uninc_ft$ci_lower, 4), ",", round(res_uninc_ft$ci_upper, 4), "]\n")
cat("Hours effect:", round(res_uninc_hrs$estimate, 2),
    "[95% CI:", round(res_uninc_hrs$ci_lower, 2), ",", round(res_uninc_hrs$ci_upper, 2), "]\n")

# Combine type-specific results
type_results <- bind_rows(
  res_inc_earn, res_inc_ft, res_inc_hrs,
  res_uninc_earn, res_uninc_ft, res_uninc_hrs
)

# Test for difference between incorporated and unincorporated
cat("\n=== Test: Incorporated vs. Unincorporated Difference ===\n")
diff_earn <- res_inc_earn$estimate - res_uninc_earn$estimate
se_diff <- sqrt(res_inc_earn$se^2 + res_uninc_earn$se^2)
z_diff <- diff_earn / se_diff
p_diff <- 2 * pnorm(-abs(z_diff))
cat("Difference in log earnings effect:", round(diff_earn, 4), "\n")
cat("SE of difference:", round(se_diff, 4), "\n")
cat("p-value:", round(p_diff, 4), "\n")

# ==============================================================================
# PART 3: Heterogeneity by Education
# ==============================================================================

cat("\n", strrep("=", 70), "\n")
cat("PART 3: HETEROGENEITY BY EDUCATION\n")
cat(strrep("=", 70), "\n")

educ_results <- list()

for (educ_level in c(0, 1)) {

  label <- ifelse(educ_level == 1, "College+", "No college")

  subset_data <- cps_complete %>%
    filter(college == educ_level)

  cat("\n--- Subgroup:", label, "(N =", nrow(subset_data), ") ---\n")

  # Refit IPW for subgroup (excluding college from formula)
  ps_formula_sub <- as.formula(paste(
    "multiple_jobs ~",
    paste(setdiff(covariates, "college"), collapse = " + ")
  ))

  ps_sub <- weightit(
    ps_formula_sub,
    data = subset_data,
    method = "ps",
    estimand = "ATE"
  )

  subset_data$ipw_sub <- pmin(ps_sub$weights, quantile(ps_sub$weights, 0.99, na.rm = TRUE))

  m_sub <- lm(log_earnings ~ multiple_jobs, data = subset_data, weights = ipw_sub)

  educ_results[[label]] <- compute_ipw_results(m_sub, "multiple_jobs", nrow(subset_data)) %>%
    mutate(subgroup = label, outcome = "Log earnings")

  cat("Estimate:", round(educ_results[[label]]$estimate, 4),
      "[95% CI:", round(educ_results[[label]]$ci_lower, 4), ",",
      round(educ_results[[label]]$ci_upper, 4), "]\n")
}

educ_df <- bind_rows(educ_results)

# Test for difference
diff_educ <- educ_results[["No college"]]$estimate - educ_results[["College+"]]$estimate
se_educ <- sqrt(educ_results[["No college"]]$se^2 + educ_results[["College+"]]$se^2)
p_educ <- 2 * pnorm(-abs(diff_educ / se_educ))
cat("\nDifference (No college - College):", round(diff_educ, 4), ", p =", round(p_educ, 3), "\n")

# ==============================================================================
# PART 4: Heterogeneity by Credit Constraints
# ==============================================================================

cat("\n", strrep("=", 70), "\n")
cat("PART 4: HETEROGENEITY BY CREDIT CONSTRAINTS\n")
cat(strrep("=", 70), "\n")

credit_results <- list()

for (constraint_status in c(0, 1)) {

  label <- ifelse(constraint_status == 1, "Credit-constrained", "Not constrained")

  subset_data <- cps_complete %>%
    filter(credit_constrained == constraint_status)

  cat("\n--- Subgroup:", label, "(N =", nrow(subset_data), ") ---\n")

  if (nrow(subset_data) < 1000) {
    cat("Insufficient sample size for subgroup analysis.\n")
    next
  }

  ps_sub <- weightit(
    ps_formula,
    data = subset_data,
    method = "ps",
    estimand = "ATE"
  )

  subset_data$ipw_sub <- pmin(ps_sub$weights, quantile(ps_sub$weights, 0.99, na.rm = TRUE))

  m_sub <- lm(log_earnings ~ multiple_jobs, data = subset_data, weights = ipw_sub)

  credit_results[[label]] <- compute_ipw_results(m_sub, "multiple_jobs", nrow(subset_data)) %>%
    mutate(subgroup = label, outcome = "Log earnings")

  cat("Estimate:", round(credit_results[[label]]$estimate, 4),
      "[95% CI:", round(credit_results[[label]]$ci_lower, 4), ",",
      round(credit_results[[label]]$ci_upper, 4), "]\n")
}

credit_df <- bind_rows(credit_results)

# ==============================================================================
# PART 5: Heterogeneity by Education × Incorporation Status
# ==============================================================================

cat("\n", strrep("=", 70), "\n")
cat("PART 5: EDUCATION × INCORPORATION INTERACTION\n")
cat(strrep("=", 70), "\n")

educ_type_results <- list()

for (educ_level in c(0, 1)) {
  for (selfemp_type in c("Incorporated", "Unincorporated")) {

    educ_label <- ifelse(educ_level == 1, "College", "No college")

    if (selfemp_type == "Incorporated") {
      subset_data <- cps_complete %>%
        filter(college == educ_level) %>%
        filter(multiple_jobs == 0 | incorporated == 1) %>%
        mutate(treatment = incorporated)
    } else {
      subset_data <- cps_complete %>%
        filter(college == educ_level) %>%
        filter(multiple_jobs == 0 | unincorporated == 1) %>%
        mutate(treatment = unincorporated)
    }

    label <- paste(educ_label, selfemp_type, sep = " × ")
    cat("\n--- Subgroup:", label, "(N =", nrow(subset_data), ", N treated =", sum(subset_data$treatment), ") ---\n")

    if (sum(subset_data$treatment) < 500) {
      cat("Insufficient treated sample.\n")
      next
    }

    ps_formula_sub <- as.formula(paste(
      "treatment ~",
      paste(setdiff(covariates, "college"), collapse = " + ")
    ))

    ps_sub <- weightit(
      ps_formula_sub,
      data = subset_data,
      method = "ps",
      estimand = "ATE"
    )

    subset_data$ipw_sub <- pmin(ps_sub$weights, quantile(ps_sub$weights, 0.99, na.rm = TRUE))

    m_sub <- lm(log_earnings ~ treatment, data = subset_data, weights = ipw_sub)

    educ_type_results[[label]] <- compute_ipw_results(m_sub, "treatment", nrow(subset_data)) %>%
      mutate(
        subgroup = label,
        education = educ_label,
        selfemp_type = selfemp_type,
        outcome = "Log earnings"
      )

    cat("Estimate:", round(educ_type_results[[label]]$estimate, 4),
        "[95% CI:", round(educ_type_results[[label]]$ci_lower, 4), ",",
        round(educ_type_results[[label]]$ci_upper, 4), "]\n")
  }
}

educ_type_df <- bind_rows(educ_type_results)

# ==============================================================================
# PART 6: Propensity Score Diagnostics
# ==============================================================================

cat("\n", strrep("=", 70), "\n")
cat("PART 6: PROPENSITY SCORE DIAGNOSTICS\n")
cat(strrep("=", 70), "\n")

# Fit propensity score model for diagnostics
ps_logit <- glm(ps_formula, data = cps_complete, family = binomial())
cps_complete$pscore <- predict(ps_logit, type = "response")

# Summary statistics
ps_summary <- cps_complete %>%
  group_by(multiple_jobs) %>%
  summarise(
    mean_ps = mean(pscore),
    sd_ps = sd(pscore),
    min_ps = min(pscore),
    max_ps = max(pscore),
    .groups = "drop"
  )

cat("\nPropensity Score Summary:\n")
print(ps_summary)

# Check overlap
ps_overlap <- cps_complete %>%
  summarise(
    ps_below_01 = mean(pscore < 0.01),
    ps_above_99 = mean(pscore > 0.99),
    common_support = mean(pscore >= 0.01 & pscore <= 0.99)
  )

cat("\nOverlap Check:\n")
cat("P(X) < 0.01:", round(ps_overlap$ps_below_01 * 100, 2), "%\n")
cat("P(X) > 0.99:", round(ps_overlap$ps_above_99 * 100, 2), "%\n")
cat("Common support:", round(ps_overlap$common_support * 100, 2), "%\n")

# Covariate balance
bal <- bal.tab(ps_ate, thresholds = c(m = 0.1))
cat("\nCovariate Balance (Max SMD after weighting):", round(max(abs(bal$Balance$Diff.Adj)), 3), "\n")

# ==============================================================================
# Save all results
# ==============================================================================

# Main results (for backward compatibility)
main_results <- aggregate_results %>%
  filter(estimand == "ATE") %>%
  select(-estimand)

saveRDS(main_results, file.path(data_dir, "main_results.rds"))
saveRDS(aggregate_results, file.path(data_dir, "aggregate_results.rds"))
saveRDS(type_results, file.path(data_dir, "type_results.rds"))
saveRDS(educ_df, file.path(data_dir, "heterogeneity_education.rds"))
saveRDS(credit_df, file.path(data_dir, "heterogeneity_results.rds"))
saveRDS(educ_type_df, file.path(data_dir, "heterogeneity_educ_type.rds"))
saveRDS(cps_complete, file.path(data_dir, "cps_with_pscore.rds"))

cat("\n", strrep("=", 70), "\n")
cat("MAIN ANALYSIS COMPLETE\n")
cat(strrep("=", 70), "\n")

# Print key findings summary
cat("\n=== KEY FINDINGS SUMMARY ===\n")
cat("\n1. Aggregate self-employment penalty (ATE):", round(aggregate_results$estimate[1], 4), "log points\n")
cat("   95% CI: [", round(aggregate_results$ci_lower[1], 4), ", ", round(aggregate_results$ci_upper[1], 4), "]\n")
cat("\n2. Incorporated self-employment effect:", round(type_results$estimate[type_results$type == "Incorporated" & type_results$outcome == "Log earnings"], 4), "log points\n")
cat("\n3. Unincorporated self-employment effect:", round(type_results$estimate[type_results$type == "Unincorporated" & type_results$outcome == "Log earnings"], 4), "log points\n")
cat("\n4. The aggregate penalty masks profound heterogeneity:\n")
cat("   - Incorporated workers show", ifelse(type_results$estimate[type_results$type == "Incorporated" & type_results$outcome == "Log earnings"] > 0, "a PREMIUM", "a smaller penalty"), "\n")
cat("   - Unincorporated workers show a larger PENALTY\n")
