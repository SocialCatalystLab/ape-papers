# Paper 67: Aging Out at 26 and Fertility
# 03_main_analysis.R - Main RDD analysis (discrete running variable approach)

source("output/paper_67/code/00_packages.R")

# Load cleaned data
cat("Loading analysis data...\n")
data <- readRDS("output/paper_67/data/analysis_data.rds")

cat(sprintf("Sample size: %s\n", format(nrow(data), big.mark = ",")))

# ============================================================
# APPROACH: Local linear regression for discrete running variable
# Following Lee & Card (2008) for discrete RDD
# ============================================================

# Function to run RDD with discrete running variable
run_discrete_rdd <- function(data, outcome_var, bandwidth = 4) {
  # Filter to bandwidth around cutoff
  rdd_data <- data %>%
    filter(abs(age_centered) <= bandwidth)

  # Local linear regression with interaction at cutoff
  formula_str <- paste0(outcome_var, " ~ age_centered + I(age_centered >= 0) + age_centered:I(age_centered >= 0)")
  model <- lm(as.formula(formula_str), data = rdd_data, weights = weight)

  # Extract discontinuity estimate (coefficient on treatment indicator)
  coef_idx <- which(names(coef(model)) == "I(age_centered >= 0)TRUE")
  est <- coef(model)[coef_idx]
  se <- sqrt(vcov(model)[coef_idx, coef_idx])

  # Cluster-robust standard errors at age level
  cluster_se <- sqrt(diag(vcovCL(model, cluster = rdd_data$AGEP)))[coef_idx]

  list(
    estimate = est,
    se = se,
    cluster_se = cluster_se,
    pvalue = 2 * pnorm(-abs(est / cluster_se)),
    n = nrow(rdd_data),
    model = model
  )
}

# Simple mean comparison function (most transparent)
mean_comparison <- function(data, outcome_var) {
  # Weighted means at ages 25 and 26
  age_25 <- data %>% filter(AGEP == 25)
  age_26 <- data %>% filter(AGEP == 26)

  mean_25 <- weighted.mean(age_25[[outcome_var]], age_25$weight, na.rm = TRUE)
  mean_26 <- weighted.mean(age_26[[outcome_var]], age_26$weight, na.rm = TRUE)

  # T-test for difference
  t_result <- t.test(
    age_26[[outcome_var]],
    age_25[[outcome_var]]
  )

  list(
    mean_25 = mean_25,
    mean_26 = mean_26,
    difference = mean_26 - mean_25,
    pvalue = t_result$p.value,
    n_25 = nrow(age_25),
    n_26 = nrow(age_26)
  )
}

# ============================================================
# FIRST STAGE: Insurance Coverage Discontinuity at Age 26
# ============================================================

cat("\n========================================\n")
cat("FIRST STAGE: Insurance Coverage at Age 26\n")
cat("========================================\n")

# Simple mean comparisons
cat("\n--- Simple Mean Comparison (Age 25 vs 26) ---\n")

insurance_vars <- c("has_insurance", "has_private", "has_public")
fs_results <- list()

for (var in insurance_vars) {
  result <- mean_comparison(data, var)
  fs_results[[var]] <- result
  cat(sprintf("\n%s:\n", var))
  cat(sprintf("  Age 25 mean: %.3f\n", result$mean_25))
  cat(sprintf("  Age 26 mean: %.3f\n", result$mean_26))
  cat(sprintf("  Difference: %.4f (p = %.4f)\n", result$difference, result$pvalue))
}

# Local linear RDD
cat("\n--- Local Linear RDD (bandwidth = 4) ---\n")

fs_rdd <- list()
for (var in insurance_vars) {
  result <- run_discrete_rdd(data, var, bandwidth = 4)
  fs_rdd[[var]] <- result
  cat(sprintf("\n%s:\n", var))
  cat(sprintf("  Estimate: %.4f\n", result$estimate))
  cat(sprintf("  Cluster SE: %.4f\n", result$cluster_se))
  cat(sprintf("  P-value: %.4f\n", result$pvalue))
}

# ============================================================
# REDUCED FORM: Fertility Discontinuity at Age 26
# ============================================================

cat("\n========================================\n")
cat("REDUCED FORM: Fertility at Age 26\n")
cat("========================================\n")

# Simple mean comparison
cat("\n--- Simple Mean Comparison ---\n")
birth_simple <- mean_comparison(data, "gave_birth")
cat(sprintf("Age 25 birth rate: %.4f\n", birth_simple$mean_25))
cat(sprintf("Age 26 birth rate: %.4f\n", birth_simple$mean_26))
cat(sprintf("Difference: %.4f (p = %.4f)\n", birth_simple$difference, birth_simple$pvalue))

# Local linear RDD
cat("\n--- Local Linear RDD (bandwidth = 4) ---\n")
birth_rdd <- run_discrete_rdd(data, "gave_birth", bandwidth = 4)
cat(sprintf("Estimate: %.4f\n", birth_rdd$estimate))
cat(sprintf("Cluster SE: %.4f\n", birth_rdd$cluster_se))
cat(sprintf("P-value: %.4f\n", birth_rdd$pvalue))

# ============================================================
# ROBUSTNESS: Alternative Bandwidths
# ============================================================

cat("\n========================================\n")
cat("ROBUSTNESS: Bandwidth Sensitivity\n")
cat("========================================\n")

bandwidths <- c(2, 3, 4, 5)
bw_results <- data.frame(
  bandwidth = numeric(),
  estimate = numeric(),
  se = numeric(),
  pvalue = numeric(),
  n = numeric()
)

for (bw in bandwidths) {
  result <- run_discrete_rdd(data, "gave_birth", bandwidth = bw)
  bw_results <- rbind(bw_results, data.frame(
    bandwidth = bw,
    estimate = result$estimate,
    se = result$cluster_se,
    pvalue = result$pvalue,
    n = result$n
  ))
}

cat("\nBandwidth Sensitivity for Fertility Outcome:\n")
print(bw_results)

# ============================================================
# PLACEBO CUTOFFS
# ============================================================

cat("\n========================================\n")
cat("PLACEBO: Testing at Non-Policy Ages\n")
cat("========================================\n")

placebo_ages <- c(23, 24, 25, 27, 28, 29)
placebo_results <- data.frame(
  cutoff_age = numeric(),
  estimate = numeric(),
  se = numeric(),
  pvalue = numeric()
)

for (age in placebo_ages) {
  # Create placebo dataset centered at this age
  placebo_data <- data %>%
    mutate(placebo_centered = AGEP - age)

  # Filter to bandwidth around placebo cutoff
  placebo_subset <- placebo_data %>%
    filter(abs(placebo_centered) <= 4)

  tryCatch({
    model <- lm(gave_birth ~ placebo_centered + I(placebo_centered >= 0) +
                  placebo_centered:I(placebo_centered >= 0),
                data = placebo_subset, weights = weight)

    coef_idx <- which(names(coef(model)) == "I(placebo_centered >= 0)TRUE")
    est <- coef(model)[coef_idx]
    cluster_se <- sqrt(diag(vcovCL(model, cluster = placebo_subset$AGEP)))[coef_idx]

    placebo_results <- rbind(placebo_results, data.frame(
      cutoff_age = age,
      estimate = est,
      se = cluster_se,
      pvalue = 2 * pnorm(-abs(est / cluster_se))
    ))
  }, error = function(e) {
    cat(sprintf("Error at placebo age %d: %s\n", age, e$message))
  })
}

cat("\nPlacebo Cutoff Results (Fertility):\n")
print(placebo_results)

# ============================================================
# BALANCE TESTS
# ============================================================

cat("\n========================================\n")
cat("BALANCE TESTS: Predetermined Characteristics\n")
cat("========================================\n")

balance_vars <- c("married", "college", "native_born", "citizen")
balance_results <- data.frame(
  variable = character(),
  mean_25 = numeric(),
  mean_26 = numeric(),
  difference = numeric(),
  pvalue = numeric()
)

for (var in balance_vars) {
  result <- mean_comparison(data, var)
  balance_results <- rbind(balance_results, data.frame(
    variable = var,
    mean_25 = result$mean_25,
    mean_26 = result$mean_26,
    difference = result$difference,
    pvalue = result$pvalue
  ))
}

cat("\nBalance Test Results:\n")
print(balance_results)

# ============================================================
# HETEROGENEITY BY MEDICAID EXPANSION
# ============================================================

cat("\n========================================\n")
cat("HETEROGENEITY: Medicaid Expansion States\n")
cat("========================================\n")

# Expansion states
data_expansion <- data %>% filter(medicaid_expansion == 1)
het_exp_birth <- mean_comparison(data_expansion, "gave_birth")
het_exp_ins <- mean_comparison(data_expansion, "has_private")

cat("\n--- Medicaid Expansion States ---\n")
cat(sprintf("Birth rate difference: %.4f (p = %.4f)\n",
            het_exp_birth$difference, het_exp_birth$pvalue))
cat(sprintf("Private insurance difference: %.4f (p = %.4f)\n",
            het_exp_ins$difference, het_exp_ins$pvalue))

# Non-expansion states
data_nonexp <- data %>% filter(medicaid_expansion == 0)
het_nonexp_birth <- mean_comparison(data_nonexp, "gave_birth")
het_nonexp_ins <- mean_comparison(data_nonexp, "has_private")

cat("\n--- Non-Expansion States ---\n")
cat(sprintf("Birth rate difference: %.4f (p = %.4f)\n",
            het_nonexp_birth$difference, het_nonexp_birth$pvalue))
cat(sprintf("Private insurance difference: %.4f (p = %.4f)\n",
            het_nonexp_ins$difference, het_nonexp_ins$pvalue))

# ============================================================
# HETEROGENEITY BY MARITAL STATUS
# ============================================================

cat("\n========================================\n")
cat("HETEROGENEITY: Marital Status\n")
cat("========================================\n")

# Unmarried women
data_unmarried <- data %>% filter(married == 0)
het_unmar_birth <- mean_comparison(data_unmarried, "gave_birth")
het_unmar_ins <- mean_comparison(data_unmarried, "has_private")

cat("\n--- Unmarried Women ---\n")
cat(sprintf("Birth rate difference: %.4f (p = %.4f)\n",
            het_unmar_birth$difference, het_unmar_birth$pvalue))
cat(sprintf("Private insurance difference: %.4f (p = %.4f)\n",
            het_unmar_ins$difference, het_unmar_ins$pvalue))

# Married women
data_married <- data %>% filter(married == 1)
het_mar_birth <- mean_comparison(data_married, "gave_birth")
het_mar_ins <- mean_comparison(data_married, "has_private")

cat("\n--- Married Women ---\n")
cat(sprintf("Birth rate difference: %.4f (p = %.4f)\n",
            het_mar_birth$difference, het_mar_birth$pvalue))
cat(sprintf("Private insurance difference: %.4f (p = %.4f)\n",
            het_mar_ins$difference, het_mar_ins$pvalue))

# ============================================================
# SAVE RESULTS
# ============================================================

cat("\n========================================\n")
cat("Saving Results\n")
cat("========================================\n")

results <- list(
  first_stage_simple = fs_results,
  first_stage_rdd = fs_rdd,
  birth_simple = birth_simple,
  birth_rdd = birth_rdd,
  bandwidth_sensitivity = bw_results,
  placebo_tests = placebo_results,
  balance_tests = balance_results,
  het_expansion = list(birth = het_exp_birth, insurance = het_exp_ins),
  het_nonexp = list(birth = het_nonexp_birth, insurance = het_nonexp_ins),
  het_unmarried = list(birth = het_unmar_birth, insurance = het_unmar_ins),
  het_married = list(birth = het_mar_birth, insurance = het_mar_ins)
)

saveRDS(results, "output/paper_67/data/rdd_results.rds")

# Summary table
cat("\n========================================\n")
cat("SUMMARY OF MAIN RESULTS\n")
cat("========================================\n")

summary_table <- data.frame(
  Outcome = c("Private Insurance (simple)", "Public Insurance (simple)",
              "Any Insurance (simple)", "Gave Birth (simple)",
              "Private Insurance (RDD)", "Gave Birth (RDD)"),
  Estimate = c(
    fs_results$has_private$difference,
    fs_results$has_public$difference,
    fs_results$has_insurance$difference,
    birth_simple$difference,
    fs_rdd$has_private$estimate,
    birth_rdd$estimate
  ),
  P_value = c(
    fs_results$has_private$pvalue,
    fs_results$has_public$pvalue,
    fs_results$has_insurance$pvalue,
    birth_simple$pvalue,
    fs_rdd$has_private$pvalue,
    birth_rdd$pvalue
  )
)

print(summary_table)

cat("\nAnalysis complete.\n")
