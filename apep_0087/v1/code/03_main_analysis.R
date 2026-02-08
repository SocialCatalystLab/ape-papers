# ==============================================================================
# 03_main_analysis.R - Main DR/AIPW Analysis
# Paper 110: Automation Exposure and Older Worker Labor Force Exit
# ==============================================================================

source("00_packages.R")

message("\n=== Loading Analysis Data ===")

df <- readRDS(file.path(data_dir, "analysis_data.rds"))
message("Loaded ", nrow(df), " observations")

# ==============================================================================
# 1. Define Covariates and Treatment
# ==============================================================================

# Outcome
outcome_var <- "not_in_labor_force"

# Treatment (binary for main specification)
treatment_var <- "high_automation"

# Covariates for propensity score and outcome model
covariates <- c(
  "AGEP", "age_squared",
  "SEX",
  "education",
  "race_ethnicity",
  "foreign_born",
  "married",
  "has_children",
  "has_disability",
  "homeowner",
  "log_income",
  "has_employer_ins",
  "has_medicare",
  "industry_broad",
  "year"
)

# ==============================================================================
# 2. Prepare Data for Analysis
# ==============================================================================

message("\n=== Preparing Analysis Data ===")

# Select and complete cases
df_model <- df %>%
  select(all_of(c(outcome_var, treatment_var, covariates, "PWGTP", "ST", "college",
                  "automation_exposure"))) %>%
  drop_na()

message("Complete cases: ", nrow(df_model), " observations")

# Extract vectors
Y <- df_model[[outcome_var]]
A <- df_model[[treatment_var]]
W <- df_model$PWGTP

message("Treatment prevalence: ", round(mean(A) * 100, 1), "%")
message("Outcome prevalence: ", round(weighted.mean(Y, W) * 100, 1), "%")

# ==============================================================================
# 3. OLS Baseline (for comparison)
# ==============================================================================

message("\n=== OLS Baseline Estimation ===")

ols_formula <- as.formula(paste(outcome_var, "~", treatment_var, "+",
                                 paste(covariates, collapse = " + ")))

ols_fit <- lm(ols_formula, data = df_model, weights = PWGTP)

ols_coef <- coef(ols_fit)[treatment_var]
ols_se <- sqrt(vcov(ols_fit)[treatment_var, treatment_var])

message("OLS estimate: ", round(ols_coef, 4), " (SE: ", round(ols_se, 4), ")")
message("Interpretation: High automation associated with ",
        round(ols_coef * 100, 2), " pp change in NILF probability")

# ==============================================================================
# 4. IPW Estimation (Doubly Robust Approach - Component 1)
# ==============================================================================

message("\n=== IPW Estimation ===")

# Fit propensity score model with all covariates
ps_formula <- as.formula(paste("high_automation ~", paste(covariates, collapse = " + ")))
ps_model <- glm(ps_formula, data = df_model, family = binomial, weights = PWGTP)

# Calculate propensity scores
df_model$ps <- predict(ps_model, type = "response")

# Trim extreme propensity scores for stability
df_model$ps_trimmed <- pmax(pmin(df_model$ps, 0.99), 0.01)

# Calculate IPW weights
df_model$ipw <- ifelse(
  df_model$high_automation == 1,
  1 / df_model$ps_trimmed,
  1 / (1 - df_model$ps_trimmed)
)

# Further trim extreme weights
df_model$ipw_trimmed <- pmin(df_model$ipw, quantile(df_model$ipw, 0.99))

# IPW-weighted outcome regression
ipw_fit <- lm(not_in_labor_force ~ high_automation,
              data = df_model,
              weights = PWGTP * ipw_trimmed)

ipw_coef <- coef(ipw_fit)["high_automation"]
ipw_se <- sqrt(vcov(ipw_fit)["high_automation", "high_automation"])

message("IPW estimate: ", round(ipw_coef, 4), " (SE: ", round(ipw_se, 4), ")")

# ==============================================================================
# 5. AIPW Estimation (Manual Implementation)
# ==============================================================================

message("\n=== AIPW Estimation (Manual) ===")

# Outcome model for treated
outcome_formula <- as.formula(paste("not_in_labor_force ~", paste(covariates, collapse = " + ")))

outcome_model_1 <- lm(outcome_formula,
                      data = filter(df_model, high_automation == 1),
                      weights = PWGTP)

outcome_model_0 <- lm(outcome_formula,
                      data = filter(df_model, high_automation == 0),
                      weights = PWGTP)

# Predict outcomes under both treatment conditions
df_model$mu_1 <- predict(outcome_model_1, newdata = df_model)
df_model$mu_0 <- predict(outcome_model_0, newdata = df_model)

# AIPW components
df_model <- df_model %>%
  mutate(
    # Augmented IPW terms
    aipw_1 = (high_automation * not_in_labor_force / ps_trimmed) -
             ((high_automation - ps_trimmed) / ps_trimmed) * mu_1,
    aipw_0 = ((1 - high_automation) * not_in_labor_force / (1 - ps_trimmed)) +
             ((high_automation - ps_trimmed) / (1 - ps_trimmed)) * mu_0
  )

# AIPW estimate (weighted)
aipw_ate <- weighted.mean(df_model$aipw_1, df_model$PWGTP) -
            weighted.mean(df_model$aipw_0, df_model$PWGTP)

# Bootstrap for SE
set.seed(123)
n_boot <- 500
boot_ates <- numeric(n_boot)

message("Running bootstrap for AIPW standard errors...")

for (b in 1:n_boot) {
  idx <- sample(1:nrow(df_model), replace = TRUE)
  boot_data <- df_model[idx, ]

  tryCatch({
    # Re-estimate propensity score
    ps_boot <- glm(ps_formula, data = boot_data, family = binomial, weights = PWGTP)
    boot_data$ps_b <- predict(ps_boot, type = "response")
    boot_data$ps_b <- pmax(pmin(boot_data$ps_b, 0.99), 0.01)

    # Re-estimate outcome models
    om1_boot <- lm(outcome_formula, data = filter(boot_data, high_automation == 1), weights = PWGTP)
    om0_boot <- lm(outcome_formula, data = filter(boot_data, high_automation == 0), weights = PWGTP)

    boot_data$mu_1_b <- predict(om1_boot, newdata = boot_data)
    boot_data$mu_0_b <- predict(om0_boot, newdata = boot_data)

    # AIPW
    boot_data <- boot_data %>%
      mutate(
        aipw_1_b = (high_automation * not_in_labor_force / ps_b) -
                   ((high_automation - ps_b) / ps_b) * mu_1_b,
        aipw_0_b = ((1 - high_automation) * not_in_labor_force / (1 - ps_b)) +
                   ((high_automation - ps_b) / (1 - ps_b)) * mu_0_b
      )

    boot_ates[b] <- weighted.mean(boot_data$aipw_1_b, boot_data$PWGTP) -
                    weighted.mean(boot_data$aipw_0_b, boot_data$PWGTP)
  }, error = function(e) {
    boot_ates[b] <- NA
  })
}

aipw_se <- sd(boot_ates, na.rm = TRUE)
aipw_ci <- c(aipw_ate - 1.96 * aipw_se, aipw_ate + 1.96 * aipw_se)

message("\n--- AIPW Results ---")
message("ATE: ", round(aipw_ate, 4), " (SE: ", round(aipw_se, 4), ")")
message("95% CI: [", round(aipw_ci[1], 4), ", ", round(aipw_ci[2], 4), "]")
message("Interpretation: High automation CAUSES ",
        round(aipw_ate * 100, 2), " pp change in NILF probability")

# ==============================================================================
# 6. Heterogeneity Analysis
# ==============================================================================

message("\n=== Heterogeneity Analysis ===")

# Function to estimate effect for subgroup
estimate_subgroup <- function(data, subgroup_name) {
  Y_sub <- data$not_in_labor_force
  A_sub <- data$high_automation

  tryCatch({
    # Simple propensity score model
    ps_mod <- glm(high_automation ~ AGEP + log_income + married + has_disability,
                  data = data, family = binomial)
    ps <- predict(ps_mod, type = "response")
    ps <- pmax(pmin(ps, 0.99), 0.01)

    # IPW weights
    ipw <- ifelse(data$high_automation == 1, 1/ps, 1/(1-ps))
    ipw <- pmin(ipw, quantile(ipw, 0.99))

    # IPW estimate
    fit <- lm(not_in_labor_force ~ high_automation, data = data, weights = ipw)
    coef_est <- coef(fit)["high_automation"]
    se_est <- sqrt(vcov(fit)["high_automation", "high_automation"])

    data.frame(
      subgroup = subgroup_name,
      n = nrow(data),
      ate = coef_est,
      se = se_est,
      ci_lower = coef_est - 1.96 * se_est,
      ci_upper = coef_est + 1.96 * se_est
    )
  }, error = function(e) {
    # Fallback to simple OLS
    fit <- lm(not_in_labor_force ~ high_automation + AGEP + log_income, data = data)
    coef_est <- coef(fit)["high_automation"]
    se_est <- sqrt(vcov(fit)["high_automation", "high_automation"])

    data.frame(
      subgroup = subgroup_name,
      n = nrow(data),
      ate = coef_est,
      se = se_est,
      ci_lower = coef_est - 1.96 * se_est,
      ci_upper = coef_est + 1.96 * se_est
    )
  })
}

# Heterogeneity by education
message("\n--- By Education ---")
het_education <- df_model %>%
  group_by(college) %>%
  group_split() %>%
  map_dfr(~estimate_subgroup(.x, ifelse(.x$college[1] == 1, "College+", "No College")))
print(het_education)

# Heterogeneity by age group
message("\n--- By Age Group ---")
df_model <- df_model %>%
  mutate(age_group = cut(AGEP, breaks = c(54, 60, 65, 70),
                         labels = c("55-60", "61-65", "66-70")))

het_age <- df_model %>%
  group_by(age_group) %>%
  group_split() %>%
  map_dfr(~estimate_subgroup(.x, as.character(.x$age_group[1])))
print(het_age)

# Heterogeneity by sex
message("\n--- By Sex ---")
het_sex <- df_model %>%
  group_by(SEX) %>%
  group_split() %>%
  map_dfr(~estimate_subgroup(.x, as.character(.x$SEX[1])))
print(het_sex)

# ==============================================================================
# 7. Save Results
# ==============================================================================

message("\n=== Saving Results ===")

main_results <- list(
  ols = list(
    estimate = ols_coef,
    se = ols_se,
    ci = c(ols_coef - 1.96 * ols_se, ols_coef + 1.96 * ols_se)
  ),
  ipw = list(
    estimate = ipw_coef,
    se = ipw_se,
    ci = c(ipw_coef - 1.96 * ipw_se, ipw_coef + 1.96 * ipw_se)
  ),
  aipw = list(
    estimate = aipw_ate,
    se = aipw_se,
    ci = aipw_ci
  ),
  heterogeneity = list(
    by_education = het_education,
    by_age = het_age,
    by_sex = het_sex
  ),
  sample_size = nrow(df_model),
  propensity_score_summary = summary(df_model$ps_trimmed)
)

saveRDS(main_results, file.path(data_dir, "main_results.rds"))
message("Saved: ", file.path(data_dir, "main_results.rds"))

message("\n=== Main Analysis Complete ===")
