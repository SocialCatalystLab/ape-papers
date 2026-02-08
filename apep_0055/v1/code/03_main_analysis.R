# ============================================================================
# Paper 70: Age 26 RDD on Birth Insurance Coverage
# 03_main_analysis.R - Main RDD estimation
# ============================================================================

source("00_packages.R")

# ============================================================================
# Load Data
# ============================================================================

cat("Loading analysis data...\n")
natality <- readRDS(file.path(data_dir, "natality_analysis.rds"))
age_summary <- readRDS(file.path(data_dir, "age_summary.rds"))

cat(sprintf("Sample size: %s births\n", format(nrow(natality), big.mark=",")))

# ============================================================================
# Descriptive Statistics
# ============================================================================

cat("\n=== Sample by Age ===\n")
print(natality[, .N, by = MAGER][order(MAGER)])

cat("\n=== Payment by Age (full sample) ===\n")
print(age_summary[, .(MAGER, N, pct_medicaid = round(pct_medicaid*100,1),
                      pct_private = round(pct_private*100,1),
                      pct_selfpay = round(pct_selfpay*100,1))])

# ============================================================================
# RDD Estimation: Main Outcomes
# ============================================================================

# Create analysis subset (bandwidth around 26)
bandwidth <- 4  # Ages 22-30
df <- natality[MAGER >= (26 - bandwidth) & MAGER <= (26 + bandwidth)]

cat(sprintf("\nAnalysis sample (bandwidth %d): %s births\n",
            bandwidth, format(nrow(df), big.mark=",")))

# ============================================================================
# RDD with rdrobust
# ============================================================================

cat("\n=== RDD Results: Source of Payment ===\n")

# Outcome 1: Medicaid
cat("\n--- Medicaid ---\n")
rd_medicaid <- rdrobust(y = df$medicaid, x = df$age_centered, c = 0)
summary(rd_medicaid)

# Outcome 2: Private Insurance
cat("\n--- Private Insurance ---\n")
rd_private <- rdrobust(y = df$private, x = df$age_centered, c = 0)
summary(rd_private)

# Outcome 3: Self-pay (Uninsured)
cat("\n--- Self-Pay (Uninsured) ---\n")
rd_selfpay <- rdrobust(y = df$selfpay, x = df$age_centered, c = 0)
summary(rd_selfpay)

# ============================================================================
# RDD Results: Health Outcomes
# ============================================================================

cat("\n=== RDD Results: Health Outcomes ===\n")

# Outcome 4: Early Prenatal Care
cat("\n--- Early Prenatal Care (1st Trimester) ---\n")
rd_prenatal <- rdrobust(y = df$early_prenatal, x = df$age_centered, c = 0)
summary(rd_prenatal)

# Outcome 5: Preterm Birth
cat("\n--- Preterm Birth (<37 weeks) ---\n")
rd_preterm <- rdrobust(y = df$preterm, x = df$age_centered, c = 0)
summary(rd_preterm)

# Outcome 6: Low Birth Weight
cat("\n--- Low Birth Weight (<2500g) ---\n")
rd_lbw <- rdrobust(y = df$low_birthweight, x = df$age_centered, c = 0)
summary(rd_lbw)

# ============================================================================
# Compile Results Table
# ============================================================================

extract_rd_results <- function(rd_obj, outcome_name) {
  data.frame(
    Outcome = outcome_name,
    RD_Estimate = rd_obj$coef["Conventional"],
    Robust_SE = rd_obj$se["Robust"],
    CI_Lower = rd_obj$ci["Robust", "CI Lower"],
    CI_Upper = rd_obj$ci["Robust", "CI Upper"],
    p_value = rd_obj$pv["Robust"],
    Bandwidth = rd_obj$bws["h", "left"],
    N_Left = rd_obj$N_h[1],
    N_Right = rd_obj$N_h[2]
  )
}

results_table <- rbind(
  extract_rd_results(rd_medicaid, "Medicaid"),
  extract_rd_results(rd_private, "Private Insurance"),
  extract_rd_results(rd_selfpay, "Self-Pay (Uninsured)"),
  extract_rd_results(rd_prenatal, "Early Prenatal Care"),
  extract_rd_results(rd_preterm, "Preterm Birth"),
  extract_rd_results(rd_lbw, "Low Birth Weight")
)

cat("\n=== Summary Results Table ===\n")
print(results_table)

# Save results
saveRDS(results_table, file.path(data_dir, "rd_results.rds"))

# ============================================================================
# Alternative: Local Randomization Inference
# ============================================================================
# For discrete running variable, local randomization may be more appropriate

cat("\n=== Local Randomization Inference ===\n")

# Use narrow window around cutoff (ages 25 vs 26)
df_narrow <- natality[MAGER %in% c(25, 26)]

cat(sprintf("Narrow window sample: %s births\n", format(nrow(df_narrow), big.mark=",")))

# Simple difference in means (local randomization)
cat("\n--- Difference in Means (Age 25 vs 26) ---\n")

outcomes <- c("medicaid", "private", "selfpay", "early_prenatal", "preterm", "low_birthweight")

for (outcome in outcomes) {
  mean_25 <- mean(df_narrow[[outcome]][df_narrow$MAGER == 25], na.rm = TRUE)
  mean_26 <- mean(df_narrow[[outcome]][df_narrow$MAGER == 26], na.rm = TRUE)
  diff <- mean_26 - mean_25

  # T-test
  tt <- t.test(df_narrow[[outcome]] ~ df_narrow$above_26)

  cat(sprintf("%s: Age 25 = %.3f, Age 26 = %.3f, Diff = %.4f (p = %.4f)\n",
              outcome, mean_25, mean_26, diff, tt$p.value))
}

# ============================================================================
# Save Main Results
# ============================================================================

main_results <- list(
  rd_medicaid = rd_medicaid,
  rd_private = rd_private,
  rd_selfpay = rd_selfpay,
  rd_prenatal = rd_prenatal,
  rd_preterm = rd_preterm,
  rd_lbw = rd_lbw,
  results_table = results_table
)

saveRDS(main_results, file.path(data_dir, "main_results.rds"))
cat("\nMain results saved.\n")
