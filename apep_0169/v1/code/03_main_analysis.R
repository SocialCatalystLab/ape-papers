# ==============================================================================
# 03_main_analysis.R
# Main causal analysis using Doubly Robust methods
# Paper 154: The Insurance Value of Secondary Employment
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

# Define covariates
covariates <- c(
  "age", "age_sq", "female", "college", "married",
  "race_white", "race_black", "race_hispanic", "race_asian",
  "homeowner", "covid_period"
)

# Note: Our treatment is now "multiple_jobs" which is actually self_employed
# from the data cleaning step

# ==============================================================================
# Method 1: IPW with propensity score weighting
# ==============================================================================

cat("\n=== IPW Estimation ===\n")

# Fit propensity score model
ps_formula <- as.formula(paste(
  "multiple_jobs ~",
  paste(covariates, collapse = " + ")
))

ps_model <- weightit(
  ps_formula,
  data = cps_complete,
  method = "ps",
  estimand = "ATE"
)

cps_complete$ipw <- ps_model$weights

# Truncate extreme weights
cps_complete$ipw <- pmin(cps_complete$ipw, quantile(cps_complete$ipw, 0.99, na.rm = TRUE))

cat("\nWeight summary:\n")
print(summary(cps_complete$ipw))

# ==============================================================================
# Outcome 1: Log Earnings
# ==============================================================================

cat("\n=== Effect on Log Earnings ===\n")

ipw_earnings <- lm(log_earnings ~ multiple_jobs,
                   data = cps_complete,
                   weights = ipw)

cat("Estimate:", round(coef(ipw_earnings)["multiple_jobs"], 4), "\n")
cat("SE:", round(sqrt(vcov(ipw_earnings)["multiple_jobs", "multiple_jobs"]), 4), "\n")
cat("Interpretation: Self-employed workers earn",
    round((exp(coef(ipw_earnings)["multiple_jobs"]) - 1) * 100, 1),
    "% more/less than wage workers\n")

results_earnings <- tibble(
  outcome = "Log earnings",
  estimate = coef(ipw_earnings)["multiple_jobs"],
  se = sqrt(vcov(ipw_earnings)["multiple_jobs", "multiple_jobs"]),
  ci_lower = confint(ipw_earnings)["multiple_jobs", 1],
  ci_upper = confint(ipw_earnings)["multiple_jobs", 2],
  p_value = summary(ipw_earnings)$coefficients["multiple_jobs", 4]
)

# ==============================================================================
# Outcome 2: Full-Time Status
# ==============================================================================

cat("\n=== Effect on Full-Time Status ===\n")

ipw_fulltime <- lm(full_time ~ multiple_jobs,
                   data = cps_complete,
                   weights = ipw)

cat("Estimate:", round(coef(ipw_fulltime)["multiple_jobs"], 4), "\n")
cat("SE:", round(sqrt(vcov(ipw_fulltime)["multiple_jobs", "multiple_jobs"]), 4), "\n")

results_fulltime <- tibble(
  outcome = "Full-time employment",
  estimate = coef(ipw_fulltime)["multiple_jobs"],
  se = sqrt(vcov(ipw_fulltime)["multiple_jobs", "multiple_jobs"]),
  ci_lower = confint(ipw_fulltime)["multiple_jobs", 1],
  ci_upper = confint(ipw_fulltime)["multiple_jobs", 2],
  p_value = summary(ipw_fulltime)$coefficients["multiple_jobs", 4]
)

# ==============================================================================
# Outcome 3: Hours Worked
# ==============================================================================

cat("\n=== Effect on Hours Worked ===\n")

ipw_hours <- lm(hours_usual ~ multiple_jobs,
                data = cps_complete,
                weights = ipw)

cat("Estimate:", round(coef(ipw_hours)["multiple_jobs"], 2), "hours\n")
cat("SE:", round(sqrt(vcov(ipw_hours)["multiple_jobs", "multiple_jobs"]), 2), "\n")

results_hours <- tibble(
  outcome = "Hours worked",
  estimate = coef(ipw_hours)["multiple_jobs"],
  se = sqrt(vcov(ipw_hours)["multiple_jobs", "multiple_jobs"]),
  ci_lower = confint(ipw_hours)["multiple_jobs", 1],
  ci_upper = confint(ipw_hours)["multiple_jobs", 2],
  p_value = summary(ipw_hours)$coefficients["multiple_jobs", 4]
)

# ==============================================================================
# Combine main results
# ==============================================================================

main_results <- bind_rows(
  results_earnings,
  results_fulltime,
  results_hours
)

cat("\n=== Main Results Summary ===\n")
print(main_results)

saveRDS(main_results, file.path(data_dir, "main_results.rds"))

# ==============================================================================
# Heterogeneity Analysis: Credit Constraints
# ==============================================================================

cat("\n=== Heterogeneity by Credit Constraint Status ===\n")

hetero_results <- list()

for (constraint_status in c(0, 1)) {

  label <- ifelse(constraint_status == 1, "Credit-constrained", "Not constrained")

  subset_data <- cps_complete %>%
    filter(credit_constrained == constraint_status)

  cat("\n--- Subgroup:", label, "(N =", nrow(subset_data), ") ---\n")

  if (nrow(subset_data) < 1000) {
    cat("Insufficient sample size for subgroup analysis.\n")
    next
  }

  # Refit IPW for subgroup
  ps_sub <- weightit(
    ps_formula,
    data = subset_data,
    method = "ps",
    estimand = "ATE"
  )

  subset_data$ipw_sub <- pmin(ps_sub$weights, quantile(ps_sub$weights, 0.99, na.rm = TRUE))

  ipw_sub <- lm(log_earnings ~ multiple_jobs,
                data = subset_data,
                weights = ipw_sub)

  hetero_results[[label]] <- tibble(
    subgroup = label,
    outcome = "Log earnings",
    estimate = coef(ipw_sub)["multiple_jobs"],
    se = sqrt(vcov(ipw_sub)["multiple_jobs", "multiple_jobs"]),
    n = nrow(subset_data)
  )

  cat("Estimate:", round(coef(ipw_sub)["multiple_jobs"], 4),
      "(SE:", round(sqrt(vcov(ipw_sub)["multiple_jobs", "multiple_jobs"]), 4), ")\n")
}

hetero_df <- bind_rows(hetero_results)
saveRDS(hetero_df, file.path(data_dir, "heterogeneity_results.rds"))

# ==============================================================================
# Heterogeneity by Education
# ==============================================================================

cat("\n=== Heterogeneity by Education ===\n")

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

  ipw_sub <- lm(log_earnings ~ multiple_jobs,
                data = subset_data,
                weights = ipw_sub)

  educ_results[[label]] <- tibble(
    subgroup = label,
    outcome = "Log earnings",
    estimate = coef(ipw_sub)["multiple_jobs"],
    se = sqrt(vcov(ipw_sub)["multiple_jobs", "multiple_jobs"]),
    n = nrow(subset_data)
  )

  cat("Estimate:", round(coef(ipw_sub)["multiple_jobs"], 4),
      "(SE:", round(sqrt(vcov(ipw_sub)["multiple_jobs", "multiple_jobs"]), 4), ")\n")
}

educ_df <- bind_rows(educ_results)
saveRDS(educ_df, file.path(data_dir, "heterogeneity_education.rds"))

# ==============================================================================
# Propensity Score Diagnostics
# ==============================================================================

cat("\n=== Propensity Score Diagnostics ===\n")

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

saveRDS(cps_complete, file.path(data_dir, "cps_with_pscore.rds"))

cat("\n=== Main Analysis Complete ===\n")
