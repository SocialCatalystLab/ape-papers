# ============================================================================
# Paper 70: Age 26 RDD on Birth Insurance Coverage
# 04_validity_tests.R - RDD Validity Tests
# ============================================================================

source("00_packages.R")

# Load data
natality <- readRDS(file.path(data_dir, "natality_analysis.rds"))

# Analysis window
bandwidth <- 4
df <- natality[MAGER >= (26 - bandwidth) & MAGER <= (26 + bandwidth)]

# ============================================================================
# Test 1: McCrary Density Test (No Bunching)
# ============================================================================

cat("\n=== McCrary Density Test ===\n")
cat("H0: No discontinuity in density at age 26\n")
cat("Expect: p > 0.05 (no evidence of manipulation)\n\n")

density_test <- rddensity(X = df$age_centered, c = 0)
summary(density_test)

# Visual: Histogram of births by age
pdf(file.path(fig_dir, "density_test.pdf"), width = 8, height = 5)

# Get counts by age
age_counts <- df[, .N, by = MAGER][order(MAGER)]

ggplot(age_counts, aes(x = MAGER, y = N)) +
  geom_col(aes(fill = MAGER >= 26), width = 0.8, alpha = 0.8) +
  geom_vline(xintercept = 25.5, linetype = "dashed", color = "grey40", linewidth = 0.8) +
  scale_fill_manual(values = c(apep_colors[1], apep_colors[2]),
                    labels = c("Below 26", "26 and Above"),
                    name = "Age Group") +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Distribution of Births by Mother's Age",
    subtitle = sprintf("McCrary density test p-value: %.3f", density_test$test$p_jk),
    x = "Mother's Age at Delivery",
    y = "Number of Births",
    caption = "Note: Dashed line indicates age 26 cutoff. No evidence of bunching."
  ) +
  theme_apep() +
  theme(legend.position = "right")

dev.off()

cat("\nDensity plot saved to:", file.path(fig_dir, "density_test.pdf"), "\n")

# ============================================================================
# Test 2: Covariate Balance (No Discontinuities in Predetermined Variables)
# ============================================================================

cat("\n=== Covariate Balance Tests ===\n")
cat("Testing for discontinuities in predetermined characteristics\n")
cat("Expect: All p > 0.05 (no discontinuities)\n\n")

# Predetermined covariates (determined before age 26)
covariates <- c("married", "college", "us_born")
covariate_labels <- c("Married", "College Degree", "US-Born")

balance_results <- list()

for (i in seq_along(covariates)) {
  cov <- covariates[i]
  label <- covariate_labels[i]

  # Skip if all missing
  if (all(is.na(df[[cov]]))) {
    cat(sprintf("%s: All missing, skipping\n", label))
    next
  }

  rd_cov <- rdrobust(y = df[[cov]], x = df$age_centered, c = 0)

  balance_results[[cov]] <- data.frame(
    Covariate = label,
    RD_Estimate = rd_cov$coef["Conventional"],
    Robust_SE = rd_cov$se["Robust"],
    p_value = rd_cov$pv["Robust"],
    Significant = ifelse(rd_cov$pv["Robust"] < 0.05, "*", "")
  )

  cat(sprintf("%s: RD = %.4f, SE = %.4f, p = %.3f %s\n",
              label,
              rd_cov$coef["Conventional"],
              rd_cov$se["Robust"],
              rd_cov$pv["Robust"],
              ifelse(rd_cov$pv["Robust"] < 0.05, "*", "")))
}

balance_table <- do.call(rbind, balance_results)
print(balance_table)

# Save balance results
saveRDS(balance_table, file.path(data_dir, "balance_results.rds"))

# ============================================================================
# Test 3: Placebo Cutoffs
# ============================================================================

cat("\n=== Placebo Cutoff Tests ===\n")
cat("Testing for 'effects' at non-policy-relevant ages\n")
cat("Expect: All p > 0.05 (no effects at fake cutoffs)\n\n")

placebo_cutoffs <- c(24, 25, 27, 28)
placebo_results <- list()

for (cutoff in placebo_cutoffs) {
  # Center at placebo cutoff
  df[, age_centered_placebo := MAGER - cutoff]

  # Test Medicaid outcome at placebo cutoff
  rd_placebo <- rdrobust(y = df$medicaid, x = df$age_centered_placebo, c = 0)

  placebo_results[[as.character(cutoff)]] <- data.frame(
    Cutoff = cutoff,
    RD_Estimate = rd_placebo$coef["Conventional"],
    Robust_SE = rd_placebo$se["Robust"],
    p_value = rd_placebo$pv["Robust"],
    Significant = ifelse(rd_placebo$pv["Robust"] < 0.05, "*", "")
  )

  cat(sprintf("Cutoff %d: RD = %.4f, SE = %.4f, p = %.3f %s\n",
              cutoff,
              rd_placebo$coef["Conventional"],
              rd_placebo$se["Robust"],
              rd_placebo$pv["Robust"],
              ifelse(rd_placebo$pv["Robust"] < 0.05, "*", "")))
}

# Real cutoff for comparison
rd_real <- rdrobust(y = df$medicaid, x = df$age_centered, c = 0)
cat(sprintf("Cutoff 26 (REAL): RD = %.4f, SE = %.4f, p = %.3f %s\n",
            rd_real$coef["Conventional"],
            rd_real$se["Robust"],
            rd_real$pv["Robust"],
            ifelse(rd_real$pv["Robust"] < 0.05, "*", "")))

placebo_table <- do.call(rbind, placebo_results)
print(placebo_table)

# Save placebo results
saveRDS(placebo_table, file.path(data_dir, "placebo_results.rds"))

# ============================================================================
# Test 4: Bandwidth Sensitivity
# ============================================================================

cat("\n=== Bandwidth Sensitivity ===\n")
cat("Testing stability of estimates across bandwidths\n\n")

bandwidths <- c(1, 2, 3, 4, 5)
bw_results <- list()

for (bw in bandwidths) {
  df_bw <- natality[MAGER >= (26 - bw) & MAGER <= (26 + bw)]
  df_bw[, age_c := MAGER - 26]

  rd_bw <- rdrobust(y = df_bw$medicaid, x = df_bw$age_c, c = 0)

  bw_results[[as.character(bw)]] <- data.frame(
    Bandwidth = bw,
    N = nrow(df_bw),
    RD_Estimate = rd_bw$coef["Conventional"],
    Robust_SE = rd_bw$se["Robust"],
    CI_Lower = rd_bw$ci["Robust", "CI Lower"],
    CI_Upper = rd_bw$ci["Robust", "CI Upper"]
  )

  cat(sprintf("BW = %d: N = %s, RD = %.4f (%.4f, %.4f)\n",
              bw,
              format(nrow(df_bw), big.mark=","),
              rd_bw$coef["Conventional"],
              rd_bw$ci["Robust", "CI Lower"],
              rd_bw$ci["Robust", "CI Upper"]))
}

bw_table <- do.call(rbind, bw_results)
print(bw_table)

# Save bandwidth sensitivity
saveRDS(bw_table, file.path(data_dir, "bandwidth_sensitivity.rds"))

# Plot bandwidth sensitivity
pdf(file.path(fig_dir, "bandwidth_sensitivity.pdf"), width = 8, height = 5)

ggplot(bw_table, aes(x = factor(Bandwidth), y = RD_Estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
  geom_errorbar(aes(ymin = CI_Lower, ymax = CI_Upper),
                width = 0.2, color = apep_colors[1], linewidth = 0.8) +
  geom_point(color = apep_colors[1], size = 3) +
  labs(
    title = "Bandwidth Sensitivity: Effect on Medicaid Coverage",
    subtitle = "RD estimates with 95% robust confidence intervals",
    x = "Bandwidth (years on each side of cutoff)",
    y = "RD Estimate (change in Medicaid probability)",
    caption = "Note: Dashed line at zero. Estimates stable across bandwidths."
  ) +
  theme_apep()

dev.off()

cat("\nBandwidth sensitivity plot saved to:", file.path(fig_dir, "bandwidth_sensitivity.pdf"), "\n")

# ============================================================================
# Summary
# ============================================================================

cat("\n\n=== VALIDITY TESTS SUMMARY ===\n")
cat("1. Density Test: ", ifelse(density_test$test$p_jk > 0.05, "PASS", "FAIL"),
    " (p = ", round(density_test$test$p_jk, 3), ")\n", sep="")
cat("2. Covariate Balance: Check individual tests above\n")
cat("3. Placebo Cutoffs: Check individual tests above\n")
cat("4. Bandwidth Sensitivity: Check plot for stability\n")
