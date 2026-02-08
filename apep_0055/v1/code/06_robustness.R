# ============================================================================
# Paper 70: Age 26 RDD on Birth Insurance Coverage
# 06_robustness.R - Robustness checks
# ============================================================================

source("00_packages.R")

# Load data
natality <- readRDS(file.path(data_dir, "natality_analysis.rds"))

# ============================================================================
# Robustness 1: Different Polynomial Orders
# ============================================================================

cat("\n=== Robustness: Polynomial Order ===\n")

df <- natality[MAGER >= 22 & MAGER <= 30]
df[, age_c := MAGER - 26]

poly_results <- list()

for (p in 1:3) {
  rd <- rdrobust(y = df$medicaid, x = df$age_c, c = 0, p = p)

  poly_results[[as.character(p)]] <- data.frame(
    Polynomial = p,
    RD_Estimate = rd$coef["Conventional"],
    Robust_SE = rd$se["Robust"],
    CI_Lower = rd$ci["Robust", "CI Lower"],
    CI_Upper = rd$ci["Robust", "CI Upper"]
  )

  cat(sprintf("p = %d: RD = %.4f (%.4f, %.4f)\n",
              p, rd$coef["Conventional"],
              rd$ci["Robust", "CI Lower"],
              rd$ci["Robust", "CI Upper"]))
}

poly_table <- do.call(rbind, poly_results)
saveRDS(poly_table, file.path(data_dir, "robustness_polynomial.rds"))

# ============================================================================
# Robustness 2: Different Kernels
# ============================================================================

cat("\n=== Robustness: Kernel Choice ===\n")

kernels <- c("triangular", "uniform", "epanechnikov")
kernel_results <- list()

for (k in kernels) {
  rd <- rdrobust(y = df$medicaid, x = df$age_c, c = 0, kernel = k)

  kernel_results[[k]] <- data.frame(
    Kernel = k,
    RD_Estimate = rd$coef["Conventional"],
    Robust_SE = rd$se["Robust"],
    CI_Lower = rd$ci["Robust", "CI Lower"],
    CI_Upper = rd$ci["Robust", "CI Upper"]
  )

  cat(sprintf("%s: RD = %.4f (%.4f, %.4f)\n",
              k, rd$coef["Conventional"],
              rd$ci["Robust", "CI Lower"],
              rd$ci["Robust", "CI Upper"]))
}

kernel_table <- do.call(rbind, kernel_results)
saveRDS(kernel_table, file.path(data_dir, "robustness_kernel.rds"))

# ============================================================================
# Robustness 3: Donut-Hole RDD
# ============================================================================

cat("\n=== Robustness: Donut-Hole RDD ===\n")
cat("Excluding observations at age 26 to address birthday timing uncertainty\n\n")

# Donut: exclude age 26
df_donut <- natality[MAGER >= 22 & MAGER <= 30 & MAGER != 26]
df_donut[, age_c := MAGER - 26]

# Run RD on donut sample
rd_donut <- rdrobust(y = df_donut$medicaid, x = df_donut$age_c, c = 0)
summary(rd_donut)

cat(sprintf("Donut RD: %.4f (%.4f, %.4f)\n",
            rd_donut$coef["Conventional"],
            rd_donut$ci["Robust", "CI Lower"],
            rd_donut$ci["Robust", "CI Upper"]))

# ============================================================================
# Robustness 4: With Covariates
# ============================================================================

cat("\n=== Robustness: Covariate-Adjusted RDD ===\n")

# Prepare covariates matrix (complete cases only)
df_cov <- df[complete.cases(df[, .(married, college, us_born)])]
Z <- as.matrix(df_cov[, .(married, college, us_born)])

rd_cov <- rdrobust(y = df_cov$medicaid, x = df_cov$age_c, c = 0, covs = Z)
summary(rd_cov)

cat(sprintf("Covariate-adjusted RD: %.4f (%.4f, %.4f)\n",
            rd_cov$coef["Conventional"],
            rd_cov$ci["Robust", "CI Lower"],
            rd_cov$ci["Robust", "CI Upper"]))

# ============================================================================
# Robustness 5: By Year
# ============================================================================

cat("\n=== Robustness: By Year ===\n")

year_results <- list()

for (yr in unique(natality$data_year)) {
  df_yr <- natality[data_year == yr & MAGER >= 22 & MAGER <= 30]
  df_yr[, age_c := MAGER - 26]

  if (nrow(df_yr) < 1000) next

  rd_yr <- rdrobust(y = df_yr$medicaid, x = df_yr$age_c, c = 0)

  year_results[[as.character(yr)]] <- data.frame(
    Year = yr,
    N = nrow(df_yr),
    RD_Estimate = rd_yr$coef["Conventional"],
    Robust_SE = rd_yr$se["Robust"],
    p_value = rd_yr$pv["Robust"]
  )

  cat(sprintf("Year %d (N=%s): RD = %.4f (p = %.3f)\n",
              yr, format(nrow(df_yr), big.mark=","),
              rd_yr$coef["Conventional"],
              rd_yr$pv["Robust"]))
}

year_table <- do.call(rbind, year_results)
saveRDS(year_table, file.path(data_dir, "robustness_by_year.rds"))

# ============================================================================
# Robustness 6: Alternative Outcomes
# ============================================================================

cat("\n=== Robustness: All Payment Outcomes ===\n")

outcomes <- c("medicaid", "private", "selfpay")
outcome_labels <- c("Medicaid", "Private Insurance", "Self-Pay")

outcome_results <- list()

for (i in seq_along(outcomes)) {
  outcome <- outcomes[i]
  label <- outcome_labels[i]

  rd <- rdrobust(y = df[[outcome]], x = df$age_c, c = 0)

  outcome_results[[outcome]] <- data.frame(
    Outcome = label,
    RD_Estimate = rd$coef["Conventional"],
    Robust_SE = rd$se["Robust"],
    CI_Lower = rd$ci["Robust", "CI Lower"],
    CI_Upper = rd$ci["Robust", "CI Upper"],
    p_value = rd$pv["Robust"]
  )

  cat(sprintf("%s: RD = %.4f (SE = %.4f, p = %.3f)\n",
              label, rd$coef["Conventional"],
              rd$se["Robust"],
              rd$pv["Robust"]))
}

outcome_table <- do.call(rbind, outcome_results)
saveRDS(outcome_table, file.path(data_dir, "robustness_outcomes.rds"))

# ============================================================================
# Summary Table
# ============================================================================

cat("\n=== ROBUSTNESS SUMMARY ===\n")

# Load main result for comparison
main_results <- readRDS(file.path(data_dir, "main_results.rds"))
main_est <- main_results$rd_medicaid$coef["Conventional"]

cat(sprintf("Main estimate (Medicaid): %.4f\n\n", main_est))

cat("Specification checks:\n")
cat(sprintf("  Linear polynomial:      %.4f\n", poly_table$RD_Estimate[1]))
cat(sprintf("  Quadratic polynomial:   %.4f\n", poly_table$RD_Estimate[2]))
cat(sprintf("  Cubic polynomial:       %.4f\n", poly_table$RD_Estimate[3]))
cat(sprintf("  Triangular kernel:      %.4f\n", kernel_table$RD_Estimate[1]))
cat(sprintf("  Uniform kernel:         %.4f\n", kernel_table$RD_Estimate[2]))
cat(sprintf("  Epanechnikov kernel:    %.4f\n", kernel_table$RD_Estimate[3]))
cat(sprintf("  Donut-hole:             %.4f\n", rd_donut$coef["Conventional"]))
cat(sprintf("  With covariates:        %.4f\n", rd_cov$coef["Conventional"]))

cat("\n\nAll robustness results saved.\n")
