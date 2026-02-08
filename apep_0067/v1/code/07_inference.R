# ==============================================================================
# Paper 86: Minimum Wage and Teen Employment
# 07_inference.R - Alternative inference procedures
# ==============================================================================

source("00_packages.R")

# Wild cluster bootstrap via sandwich/boot if available
# If fwildclusterboot isn't available, we'll use manual implementation

cat("\n=== Inference Robustness Analysis ===\n")

# Load data
data_dir <- "../data"
df <- readRDS(file.path(data_dir, "analysis_data.rds"))
df <- df[YEAR >= 2010 & YEAR < 2024]

cat("Sample size:", nrow(df), "\n")

# ==============================================================================
# 1. Baseline Clustered SEs
# ==============================================================================

cat("\n--- 1. Baseline: Clustered Standard Errors ---\n")

twfe <- feols(
  employed ~ mw_above_federal | STATEFIP + YEAR,
  data = df,
  weights = ~weight,
  cluster = ~STATEFIP
)

cat("\nBaseline TWFE:\n")
print(summary(twfe))

baseline_coef <- coef(twfe)["mw_above_federalTRUE"]
baseline_se <- se(twfe)["mw_above_federalTRUE"]
baseline_t <- baseline_coef / baseline_se
baseline_p <- 2 * pt(abs(baseline_t), df = 50, lower.tail = FALSE)

cat("\nBaseline: coef =", round(baseline_coef, 4),
    ", SE =", round(baseline_se, 4),
    ", t =", round(baseline_t, 2),
    ", p =", round(baseline_p, 2), "\n")

# ==============================================================================
# 2. Wild Cluster Bootstrap (manual implementation)
# ==============================================================================

cat("\n--- 2. Wild Cluster Bootstrap ---\n")

# Manual wild cluster bootstrap with Rademacher weights
set.seed(54321)
n_boot <- 999
boot_t_stats <- numeric(n_boot)

# Get original residuals by cluster
twfe_noweight <- feols(
  employed ~ mw_above_federal | STATEFIP + YEAR,
  data = df,
  cluster = ~STATEFIP
)

states <- unique(df$STATEFIP)
n_states <- length(states)

for (b in 1:n_boot) {
  # Generate Rademacher weights for each cluster
  weights_cluster <- sample(c(-1, 1), n_states, replace = TRUE)
  names(weights_cluster) <- states

  # Apply weights to residuals within each cluster
  df[, boot_resid := residuals(twfe_noweight) * weights_cluster[as.character(STATEFIP)]]

  # Create bootstrap outcome
  df[, boot_y := fitted(twfe_noweight) + boot_resid]

  # Run bootstrap regression
  boot_mod <- tryCatch({
    feols(boot_y ~ mw_above_federal | STATEFIP + YEAR, data = df, cluster = ~STATEFIP)
  }, error = function(e) NULL)

  if (!is.null(boot_mod)) {
    boot_coef <- coef(boot_mod)["mw_above_federalTRUE"]
    boot_se <- se(boot_mod)["mw_above_federalTRUE"]
    boot_t_stats[b] <- boot_coef / boot_se
  } else {
    boot_t_stats[b] <- NA
  }

  if (b %% 100 == 0) cat("  Bootstrap iteration", b, "of", n_boot, "\n")
}

# Remove NAs
boot_t_stats <- boot_t_stats[!is.na(boot_t_stats)]

# Calculate bootstrap p-value (two-sided)
original_t <- baseline_coef / baseline_se
boot_p <- mean(abs(boot_t_stats) >= abs(original_t))

# Calculate percentile CI
boot_ci <- quantile(boot_t_stats * baseline_se + baseline_coef, c(0.025, 0.975))

cat("\nWild Cluster Bootstrap (Rademacher weights):\n")
cat("  Bootstrap replications:", length(boot_t_stats), "\n")
cat("  Bootstrap 95% CI: [", round(boot_ci[1], 3), ",", round(boot_ci[2], 3), "]\n")
cat("  Bootstrap p-value:", round(boot_p, 2), "\n")

# ==============================================================================
# 3. Randomization Inference
# ==============================================================================

cat("\n--- 3. Randomization Inference ---\n")

# Get actual treatment effect
actual_effect <- baseline_coef

# Create state-level treatment indicator (ever treated in sample)
state_treat <- df[, .(ever_treated = any(mw_above_federal == TRUE)), by = STATEFIP]
n_treated <- sum(state_treat$ever_treated)
n_states <- nrow(state_treat)

cat("Number of treated states:", n_treated, "out of", n_states, "\n")

# Permutation test: randomly reassign treatment timing across states
# Rather than reassigning which states are treated, we shuffle treatment status
# within years to preserve year-level treatment rates
set.seed(12345)
n_perms <- 1000
perm_effects <- numeric(n_perms)
valid_perms <- 0

for (i in 1:n_perms) {
  # Shuffle treatment status within each year
  df[, perm_treat := sample(mw_above_federal), by = YEAR]

  # Check that permuted treatment has variation within FE
  if (df[, uniqueN(perm_treat), by = STATEFIP][, all(V1 > 1)] ||
      df[, uniqueN(perm_treat), by = YEAR][, all(V1 > 1)]) {

    # Run regression with permuted treatment
    perm_mod <- tryCatch({
      feols(
        employed ~ perm_treat | STATEFIP + YEAR,
        data = df,
        weights = ~weight,
        cluster = ~STATEFIP
      )
    }, error = function(e) NULL)

    if (!is.null(perm_mod) && "perm_treatTRUE" %in% names(coef(perm_mod))) {
      valid_perms <- valid_perms + 1
      perm_effects[valid_perms] <- coef(perm_mod)["perm_treatTRUE"]
    }
  }

  if (i %% 200 == 0) cat("  Permutation", i, "of", n_perms, "(valid:", valid_perms, ")\n")
}

# Trim to valid permutations
perm_effects <- perm_effects[1:valid_perms]

# Two-sided p-value
perm_p <- mean(abs(perm_effects) >= abs(actual_effect))

cat("\nRandomization inference:\n")
cat("  Actual effect:", round(actual_effect, 4), "\n")
cat("  Mean permuted effect:", round(mean(perm_effects), 4), "\n")
cat("  SD permuted effects:", round(sd(perm_effects), 4), "\n")
cat("  Permutation p-value (two-sided):", round(perm_p, 2), "\n")

# ==============================================================================
# 4. Aggregated State-Year Analysis
# ==============================================================================

cat("\n--- 4. Aggregated State-Year Analysis ---\n")

# Collapse to state-year means
state_year <- df[, .(
  employed = weighted.mean(employed, weight, na.rm = TRUE),
  mw_above_federal = first(mw_above_federal),
  n = .N
), by = .(STATEFIP, YEAR)]

cat("State-year panel:", nrow(state_year), "observations\n")

# Run regression on aggregated data
agg_mod <- feols(
  employed ~ mw_above_federal | STATEFIP + YEAR,
  data = state_year,
  cluster = ~STATEFIP
)

cat("\nAggregated analysis:\n")
print(summary(agg_mod))

agg_coef <- coef(agg_mod)["mw_above_federalTRUE"]
agg_se <- se(agg_mod)["mw_above_federalTRUE"]

cat("\nAggregated: coef =", round(agg_coef, 4),
    ", SE =", round(agg_se, 4), "\n")

# ==============================================================================
# 5. Effective Number of Clusters
# ==============================================================================

cat("\n--- 5. Effective Number of Clusters ---\n")

# Compute cluster sizes
cluster_sizes <- df[, .N, by = STATEFIP]$N
n_clusters <- length(cluster_sizes)
n_total <- sum(cluster_sizes)

# Effective number of clusters (following Carter et al. 2017)
G_eff <- n_clusters / (1 + var(cluster_sizes) / mean(cluster_sizes)^2)

cat("Number of clusters (states):", n_clusters, "\n")
cat("Total observations:", n_total, "\n")
cat("Cluster size range:", min(cluster_sizes), "-", max(cluster_sizes), "\n")
cat("Effective number of clusters:", round(G_eff, 1), "\n")

# ==============================================================================
# 6. Summary Table
# ==============================================================================

cat("\n--- Summary of Inference Methods ---\n")

inference_summary <- data.table(
  Method = c(
    "Clustered (baseline)",
    "Wild cluster bootstrap",
    "Randomization inference",
    "State-year aggregation"
  ),
  Coefficient = c(
    round(baseline_coef, 3),
    round(baseline_coef, 3),
    round(actual_effect, 3),
    round(agg_coef, 3)
  ),
  SE_or_CI = c(
    paste0("SE=", round(baseline_se, 3)),
    paste0("[", round(boot_ci[1], 3), ", ", round(boot_ci[2], 3), "]"),
    "---",
    paste0("SE=", round(agg_se, 3))
  ),
  p_value = c(
    round(baseline_p, 2),
    round(boot_p, 2),
    round(perm_p, 2),
    round(2 * pt(abs(agg_coef/agg_se), df = 50, lower.tail = FALSE), 2)
  )
)

print(inference_summary)

# Save
fwrite(inference_summary, file.path(data_dir, "inference_summary.csv"))

cat("\n=== Inference Analysis Complete ===\n")
