# =============================================================================
# 03_main_analysis.R
# Spatial RDD Analysis: Cannabis Access and Alcohol-Involved Crashes
# =============================================================================

source("00_packages.R")

# Load cleaned data
crashes <- readRDS("../data/crashes_analysis.rds")

cat("Loaded analysis sample with", nrow(crashes), "crashes.\n\n")

# =============================================================================
# PART 1: Main RDD Estimation
# =============================================================================

cat(paste0(rep("=", 60), collapse = ""), "\n")
cat("PART 1: MAIN RDD RESULTS\n")
cat(paste0(rep("=", 60), collapse = ""), "\n\n")

# Running variable: distance to border (positive = prohibition, negative = legal)
# Cutoff: 0 (at the border)
# Outcome: alcohol involvement (binary)
# Expected effect: NEGATIVE (lower alcohol involvement when treated/legal)

# Note: In rdrobust, by default treatment is assigned when running variable
# is ABOVE the cutoff. Our setup: legal state = negative distance.
# So we flip the sign for rdrobust conventions.

crashes$rv <- -crashes$running_var  # Now positive = legal (treatment)

# ----- Model 1: MSE-Optimal Bandwidth -----
cat("Model 1: MSE-Optimal Bandwidth (Main Specification)\n")
cat(paste0(rep("-", 50), collapse = ""), "\n")

rdd_main <- rdrobust(
  y = crashes$alcohol_involved,
  x = crashes$rv,
  c = 0,
  kernel = "triangular",
  p = 1,  # Local linear
  bwselect = "mserd"
)

summary(rdd_main)

# Extract key results
tau_main <- rdd_main$coef[1]  # Conventional estimate
se_main <- rdd_main$se[1]
bw_main <- rdd_main$bws[1, 1]
n_left <- rdd_main$N_h[1]
n_right <- rdd_main$N_h[2]

cat(sprintf("\nMain Result: tau = %.4f (SE = %.4f)\n", tau_main, se_main))
cat(sprintf("Bandwidth: %.2f km\n", bw_main))
cat(sprintf("Effective N: %d (legal) + %d (prohibition) = %d\n",
            n_right, n_left, n_left + n_right))

# ----- Model 2: Bias-Corrected with Robust SE -----
cat("\n\nModel 2: Bias-Corrected Robust Inference\n")
cat(paste0(rep("-", 50), collapse = ""), "\n")

tau_bc <- rdd_main$coef[2]  # Bias-corrected
se_bc <- rdd_main$se[3]     # Robust SE
ci_bc <- c(tau_bc - 1.96 * se_bc, tau_bc + 1.96 * se_bc)

cat(sprintf("Bias-corrected: tau = %.4f (Robust SE = %.4f)\n", tau_bc, se_bc))
cat(sprintf("95%% CI: [%.4f, %.4f]\n", ci_bc[1], ci_bc[2]))

# ----- Model 3: Local Quadratic -----
cat("\n\nModel 3: Local Quadratic Specification\n")
cat(paste0(rep("-", 50), collapse = ""), "\n")

rdd_quad <- rdrobust(
  y = crashes$alcohol_involved,
  x = crashes$rv,
  c = 0,
  kernel = "triangular",
  p = 2,  # Local quadratic
  bwselect = "mserd"
)

summary(rdd_quad)

# =============================================================================
# PART 2: Bandwidth Sensitivity
# =============================================================================

cat("\n\n")
cat(paste0(rep("=", 60), collapse = ""), "\n")
cat("PART 2: BANDWIDTH SENSITIVITY\n")
cat(paste0(rep("=", 60), collapse = ""), "\n\n")

bandwidths <- c(0.5, 0.75, 1.0, 1.25, 1.5, 2.0) * bw_main

bw_results <- data.frame()

for (bw in bandwidths) {
  rdd_bw <- rdrobust(
    y = crashes$alcohol_involved,
    x = crashes$rv,
    c = 0,
    h = bw,
    kernel = "triangular",
    p = 1
  )

  bw_results <- rbind(bw_results, data.frame(
    bandwidth = bw,
    bandwidth_multiple = bw / bw_main,
    estimate = rdd_bw$coef[1],
    se = rdd_bw$se[1],
    ci_lower = rdd_bw$coef[1] - 1.96 * rdd_bw$se[1],
    ci_upper = rdd_bw$coef[1] + 1.96 * rdd_bw$se[1],
    n_eff = rdd_bw$N_h[1] + rdd_bw$N_h[2]
  ))
}

print(bw_results)
saveRDS(bw_results, "../data/bw_sensitivity.rds")

# =============================================================================
# PART 3: Kernel Sensitivity
# =============================================================================

cat("\n\n")
cat(paste0(rep("=", 60), collapse = ""), "\n")
cat("PART 3: KERNEL SENSITIVITY\n")
cat(paste0(rep("=", 60), collapse = ""), "\n\n")

kernels <- c("triangular", "uniform", "epanechnikov")

kernel_results <- data.frame()

for (k in kernels) {
  rdd_k <- rdrobust(
    y = crashes$alcohol_involved,
    x = crashes$rv,
    c = 0,
    kernel = k,
    p = 1,
    bwselect = "mserd"
  )

  kernel_results <- rbind(kernel_results, data.frame(
    kernel = k,
    estimate = rdd_k$coef[1],
    se = rdd_k$se[1],
    bandwidth = rdd_k$bws[1, 1],
    ci_lower = rdd_k$coef[1] - 1.96 * rdd_k$se[1],
    ci_upper = rdd_k$coef[1] + 1.96 * rdd_k$se[1]
  ))
}

print(kernel_results)
saveRDS(kernel_results, "../data/kernel_sensitivity.rds")

# =============================================================================
# PART 4: Placebo Cutoffs
# =============================================================================

cat("\n\n")
cat(paste0(rep("=", 60), collapse = ""), "\n")
cat("PART 4: PLACEBO CUTOFFS\n")
cat(paste0(rep("=", 60), collapse = ""), "\n\n")

# Test at fake cutoffs within each side of the real border
placebo_cutoffs <- c(-80, -50, -30, 30, 50, 80)

placebo_results <- data.frame()

for (pc in placebo_cutoffs) {
  # Restrict to appropriate side of real border
  if (pc < 0) {
    data_subset <- crashes %>% filter(rv < 0)  # Legal state only
  } else {
    data_subset <- crashes %>% filter(rv > 0)  # Prohibition state only
  }

  rdd_pc <- tryCatch({
    rdrobust(
      y = data_subset$alcohol_involved,
      x = data_subset$rv,
      c = pc,
      kernel = "triangular",
      p = 1,
      bwselect = "mserd"
    )
  }, error = function(e) NULL)

  if (!is.null(rdd_pc)) {
    placebo_results <- rbind(placebo_results, data.frame(
      cutoff = pc,
      estimate = rdd_pc$coef[1],
      se = rdd_pc$se[1],
      ci_lower = rdd_pc$coef[1] - 1.96 * rdd_pc$se[1],
      ci_upper = rdd_pc$coef[1] + 1.96 * rdd_pc$se[1]
    ))
  }
}

# Add real cutoff result
placebo_results <- rbind(placebo_results, data.frame(
  cutoff = 0,
  estimate = tau_main,
  se = se_main,
  ci_lower = tau_main - 1.96 * se_main,
  ci_upper = tau_main + 1.96 * se_main
))

placebo_results <- placebo_results %>% arrange(cutoff)
print(placebo_results)
saveRDS(placebo_results, "../data/placebo_cutoffs.rds")

# =============================================================================
# PART 5: Density Test (Manipulation Check)
# =============================================================================

cat("\n\n")
cat(paste0(rep("=", 60), collapse = ""), "\n")
cat("PART 5: MANIPULATION TEST\n")
cat(paste0(rep("=", 60), collapse = ""), "\n\n")

density_test <- rddensity(crashes$rv, c = 0)
summary(density_test)

cat(sprintf("\nMcCrary density test p-value: %.4f\n", density_test$test$p_jk))

if (density_test$test$p_jk > 0.05) {
  cat("Result: No evidence of manipulation at the border.\n")
} else {
  cat("Warning: Potential manipulation detected. Investigate further.\n")
}

# =============================================================================
# PART 6: Covariate Balance at Cutoff
# =============================================================================

cat("\n\n")
cat(paste0(rep("=", 60), collapse = ""), "\n")
cat("PART 6: COVARIATE BALANCE\n")
cat(paste0(rep("=", 60), collapse = ""), "\n\n")

covariates <- c("is_nighttime")

balance_results <- data.frame()

for (cov in covariates) {
  if (cov %in% names(crashes) && !all(is.na(crashes[[cov]]))) {
    rdd_cov <- tryCatch({
      rdrobust(
        y = crashes[[cov]],
        x = crashes$rv,
        c = 0,
        kernel = "triangular",
        p = 1,
        bwselect = "mserd"
      )
    }, error = function(e) NULL)

    if (!is.null(rdd_cov)) {
      balance_results <- rbind(balance_results, data.frame(
        covariate = cov,
        estimate = rdd_cov$coef[1],
        se = rdd_cov$se[1],
        p_value = 2 * pnorm(-abs(rdd_cov$coef[1] / rdd_cov$se[1]))
      ))
    }
  }
}

print(balance_results)
saveRDS(balance_results, "../data/covariate_balance.rds")

# =============================================================================
# PART 7: Save Main Results
# =============================================================================

main_results <- list(
  main_estimate = tau_main,
  main_se = se_main,
  bc_estimate = tau_bc,
  bc_se = se_bc,
  optimal_bandwidth = bw_main,
  n_effective = n_left + n_right,
  n_legal = n_right,
  n_prohibition = n_left,
  density_p_value = density_test$test$p_jk
)

saveRDS(main_results, "../data/main_results.rds")

cat("\n\n")
cat(paste0(rep("=", 60), collapse = ""), "\n")
cat("ANALYSIS COMPLETE\n")
cat(paste0(rep("=", 60), collapse = ""), "\n")
cat(sprintf("\nMain finding: Effect of legal cannabis access on alcohol involvement\n"))
cat(sprintf("Estimate: %.4f (SE = %.4f)\n", tau_main, se_main))
cat(sprintf("Interpretation: Crossing into legal state changes alcohol involvement by %.1f pp\n",
            100 * tau_main))
