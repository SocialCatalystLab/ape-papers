# ==============================================================================
# 04_robustness.R
# Universal School Meals and Household Food Security
# Robustness checks and additional inference methods
# ==============================================================================

source("output/paper_106/code/00_packages.R")

# Load bootstrap package for wild cluster bootstrap
library(boot)

# ------------------------------------------------------------------------------
# Load analysis data and main results
# ------------------------------------------------------------------------------

df <- read_csv(file.path(DATA_DIR, "cps_fss_analysis_school.csv"), show_col_types = FALSE)

# Load main TWFE results
twfe_fi <- readRDS(file.path(DATA_DIR, "twfe_fi.rds"))
twfe_vlfs <- readRDS(file.path(DATA_DIR, "twfe_vlfs.rds"))

# Create restricted sample (2023 adopters + never-treated)
df_restricted <- df %>%
  filter(treatment_group != 2022)

cat("Restricted sample:", nrow(df_restricted), "obs\n")

# ------------------------------------------------------------------------------
# 1. Wild Cluster Bootstrap for Few-Cluster Inference
# With only 4 treated states in 2023 cohort, standard CRSEs may be unreliable
# Following Cameron, Gelbach & Miller (2008)
# ------------------------------------------------------------------------------

cat("\n=== Wild Cluster Bootstrap Inference ===\n")

# Function to compute wild cluster bootstrap p-values
wild_cluster_bootstrap <- function(data, formula, cluster_var, n_boot = 999) {

  # Fit original model
  original_fit <- feols(formula, data = data, cluster = as.formula(paste0("~", cluster_var)))
  original_coef <- coef(original_fit)["treated"]

  # Get cluster IDs
  clusters <- unique(data[[cluster_var]])
  n_clusters <- length(clusters)

  cat("Number of clusters:", n_clusters, "\n")
  cat("Original coefficient:", round(original_coef, 4), "\n")

  # Storage for bootstrap coefficients
  boot_coefs <- numeric(n_boot)

  # Wild bootstrap with Rademacher weights
  set.seed(20260128)

  for (b in 1:n_boot) {
    # Generate cluster-level Rademacher weights (+1 or -1)
    weights_b <- sample(c(-1, 1), n_clusters, replace = TRUE)
    names(weights_b) <- clusters

    # Create bootstrap residuals
    residuals_orig <- residuals(original_fit)
    fitted_orig <- fitted(original_fit)

    # Perturb residuals by cluster weight
    cluster_weights <- weights_b[as.character(data[[cluster_var]])]
    y_boot <- fitted_orig + residuals_orig * cluster_weights

    # Refit with bootstrap y
    data_boot <- data
    data_boot$y_boot <- y_boot

    formula_boot <- update(formula, y_boot ~ .)

    fit_b <- tryCatch({
      feols(formula_boot, data = data_boot, cluster = as.formula(paste0("~", cluster_var)))
    }, error = function(e) NULL)

    if (!is.null(fit_b)) {
      boot_coefs[b] <- coef(fit_b)["treated"]
    } else {
      boot_coefs[b] <- NA
    }
  }

  # Compute p-value (two-sided)
  # Under H0: beta = 0, use t-stat for original and bootstrap
  original_se <- se(original_fit)["treated"]
  t_orig <- original_coef / original_se

  boot_coefs_valid <- boot_coefs[!is.na(boot_coefs)]
  t_boot <- (boot_coefs_valid - original_coef) / original_se  # Centered bootstrap t-stats

  # P-value: proportion of |t_boot| >= |t_orig|
  p_value_wcb <- mean(abs(t_boot) >= abs(t_orig))

  # 95% CI using bootstrap percentiles
  ci_95 <- quantile(boot_coefs_valid, c(0.025, 0.975))

  return(list(
    original_coef = original_coef,
    original_se = original_se,
    original_t = t_orig,
    wcb_p_value = p_value_wcb,
    ci_95_lower = ci_95[1],
    ci_95_upper = ci_95[2],
    n_boot_valid = length(boot_coefs_valid)
  ))
}

# Run wild cluster bootstrap for main specification
cat("\nWild Cluster Bootstrap for Food Insecurity TWFE:\n")
wcb_fi <- wild_cluster_bootstrap(
  data = df_restricted,
  formula = food_insecure ~ treated | state_fips + year,
  cluster_var = "state_fips",
  n_boot = 999
)

cat("\nResults:\n")
cat("  Coefficient:", round(wcb_fi$original_coef, 4), "\n")
cat("  Cluster-robust SE:", round(wcb_fi$original_se, 4), "\n")
cat("  t-statistic:", round(wcb_fi$original_t, 3), "\n")
cat("  Wild cluster bootstrap p-value:", round(wcb_fi$wcb_p_value, 4), "\n")
cat("  95% CI: [", round(wcb_fi$ci_95_lower, 4), ", ", round(wcb_fi$ci_95_upper, 4), "]\n")

# Run for VLFS
cat("\nWild Cluster Bootstrap for Very Low Food Security TWFE:\n")
wcb_vlfs <- wild_cluster_bootstrap(
  data = df_restricted,
  formula = very_low_fs ~ treated | state_fips + year,
  cluster_var = "state_fips",
  n_boot = 999
)

cat("\nResults:\n")
cat("  Coefficient:", round(wcb_vlfs$original_coef, 4), "\n")
cat("  Cluster-robust SE:", round(wcb_vlfs$original_se, 4), "\n")
cat("  Wild cluster bootstrap p-value:", round(wcb_vlfs$wcb_p_value, 4), "\n")
cat("  95% CI: [", round(wcb_vlfs$ci_95_lower, 4), ", ", round(wcb_vlfs$ci_95_upper, 4), "]\n")

# ------------------------------------------------------------------------------
# 2. Randomization Inference / Permutation Test
# Reassign treatment to placebo states and compute distribution under H0
# Following Ferman & Pinto (2019)
# ------------------------------------------------------------------------------

cat("\n=== Randomization Inference ===\n")

# Get list of states
states_2023_treated <- c(8, 26, 27, 35)  # CO, MI, MN, NM
states_never_treated <- unique(df_restricted$state_fips[df_restricted$treatment_group == 0])

# Function to compute treatment effect under permuted treatment
compute_permuted_effect <- function(data, treated_states, all_control_states) {

  # Randomly select 4 states from control group to be "treated"
  n_treat <- length(treated_states)
  placebo_treated <- sample(all_control_states, n_treat, replace = FALSE)

  # Create placebo treatment indicator
  data_perm <- data %>%
    mutate(
      treated_perm = as.integer(state_fips %in% placebo_treated & year >= 2023)
    )

  # Fit model with placebo treatment
  fit_perm <- tryCatch({
    feols(food_insecure ~ treated_perm | state_fips + year,
          data = data_perm,
          cluster = ~state_fips)
  }, error = function(e) NULL)

  if (!is.null(fit_perm)) {
    return(coef(fit_perm)["treated_perm"])
  } else {
    return(NA)
  }
}

# Run permutation test
n_perms <- 999
set.seed(20260128)

perm_effects <- numeric(n_perms)

for (i in 1:n_perms) {
  perm_effects[i] <- compute_permuted_effect(
    df_restricted,
    states_2023_treated,
    states_never_treated
  )
}

# Compute RI p-value
observed_effect <- coef(twfe_fi)["treated"]
perm_effects_valid <- perm_effects[!is.na(perm_effects)]
ri_p_value <- mean(abs(perm_effects_valid) >= abs(observed_effect))

cat("\nRandomization Inference Results:\n")
cat("  Observed effect:", round(observed_effect, 4), "\n")
cat("  Number of permutations:", length(perm_effects_valid), "\n")
cat("  RI p-value (two-sided):", round(ri_p_value, 4), "\n")

# Plot permutation distribution
perm_df <- tibble(effect = perm_effects_valid)
p_ri <- ggplot(perm_df, aes(x = effect)) +
  geom_histogram(bins = 50, fill = "gray70", color = "white") +
  geom_vline(xintercept = observed_effect, color = "red", linewidth = 1.2) +
  geom_vline(xintercept = -observed_effect, color = "red", linetype = "dashed", linewidth = 1.2) +
  labs(
    title = "Randomization Inference: Permutation Distribution",
    subtitle = paste0("Observed effect = ", round(observed_effect, 3),
                      ", RI p-value = ", round(ri_p_value, 3)),
    x = "Placebo Treatment Effect",
    y = "Frequency"
  ) +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig_ri_distribution.png"), p_ri, width = 8, height = 6, dpi = 300)

# ------------------------------------------------------------------------------
# 3. Triple-Difference: HH with children vs HH without children
# This controls for state-year shocks affecting all households
# ------------------------------------------------------------------------------

cat("\n=== Triple-Difference Analysis ===\n")

# Load full sample (including households without children)
df_full <- read_csv(file.path(DATA_DIR, "cps_fss_analysis_full.csv"), show_col_types = FALSE)

# Restrict to 2023 adopters + never-treated
df_full_restricted <- df_full %>%
  filter(treatment_group != 2022) %>%
  mutate(
    child_indicator = has_children_5_17
  )

cat("Full sample (including no children):", nrow(df_full_restricted), "\n")

# Triple-diff with State x Year FE (proper DDD)
# This absorbs all state-year variation, identification comes from within-state-year
# comparisons of HH with vs without children
ddd_model <- feols(
  food_insecure ~ child_indicator + child_indicator:treated | state_fips^year,
  data = df_full_restricted,
  weights = ~weight,
  cluster = ~state_fips
)

cat("\nTriple-Difference Results:\n")
summary(ddd_model)

# The coefficient on treated:child_indicator is the DDD estimate
# It compares:
# (Treatment HH w/ children - Control HH w/ children) - (Treatment HH no children - Control HH no children)

# ------------------------------------------------------------------------------
# 4. Placebo Outcome Test
# Use alternative outcomes that shouldn't be affected by school meals
# Limited by available variables in CPS-FSS
# ------------------------------------------------------------------------------

cat("\n=== Placebo Outcome Analysis ===\n")
cat("Note: Limited placebo outcomes available in CPS-FSS\n")
cat("The main food security module has no obvious placebo outcomes\n")
cat("Future work could examine non-food hardship measures from other surveys\n")

# ------------------------------------------------------------------------------
# 5. Save Robustness Results
# ------------------------------------------------------------------------------

robustness_results <- tibble(
  test = c("TWFE (Cluster-robust)", "Wild Cluster Bootstrap", "Randomization Inference",
           "Triple-Diff (DDD)"),
  estimate = c(
    round(coef(twfe_fi)["treated"], 4),
    round(wcb_fi$original_coef, 4),
    round(observed_effect, 4),
    round(coef(ddd_model)["treated:child_indicator"], 4)
  ),
  se = c(
    round(se(twfe_fi)["treated"], 4),
    round(wcb_fi$original_se, 4),
    NA,
    round(se(ddd_model)["treated:child_indicator"], 4)
  ),
  p_value = c(
    round(2 * pnorm(-abs(coef(twfe_fi)["treated"] / se(twfe_fi)["treated"])), 4),
    round(wcb_fi$wcb_p_value, 4),
    round(ri_p_value, 4),
    round(2 * pnorm(-abs(coef(ddd_model)["treated:child_indicator"] /
                          se(ddd_model)["treated:child_indicator"])), 4)
  ),
  ci_95 = c(
    paste0("[", round(coef(twfe_fi)["treated"] - 1.96*se(twfe_fi)["treated"], 3), ", ",
           round(coef(twfe_fi)["treated"] + 1.96*se(twfe_fi)["treated"], 3), "]"),
    paste0("[", round(wcb_fi$ci_95_lower, 3), ", ", round(wcb_fi$ci_95_upper, 3), "]"),
    NA,
    paste0("[", round(coef(ddd_model)["treated:child_indicator"] -
                        1.96*se(ddd_model)["treated:child_indicator"], 3), ", ",
           round(coef(ddd_model)["treated:child_indicator"] +
                   1.96*se(ddd_model)["treated:child_indicator"], 3), "]")
  )
)

print(robustness_results)
write_csv(robustness_results, file.path(TAB_DIR, "robustness_results.csv"))

# Save model objects
saveRDS(ddd_model, file.path(DATA_DIR, "ddd_model.rds"))
saveRDS(list(wcb_fi = wcb_fi, wcb_vlfs = wcb_vlfs), file.path(DATA_DIR, "wcb_results.rds"))
saveRDS(list(perm_effects = perm_effects_valid, ri_p = ri_p_value), file.path(DATA_DIR, "ri_results.rds"))

cat("\n=== 04_robustness.R complete ===\n")
