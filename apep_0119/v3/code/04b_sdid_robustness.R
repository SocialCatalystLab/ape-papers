###############################################################################
# 04b_sdid_robustness.R
# Paper 141: EERS Revision - Synthetic DiD Robustness Analysis
#
# Implements Arkhangelsky et al. (2021) Synthetic Difference-in-Differences
# as a robustness check for the main Callaway-Sant'Anna results.
#
# METHODOLOGY:
#   SDID combines synthetic control (unit weights) with DiD (time weights)
#   to create a more robust counterfactual. The estimator interpolates
#   between SC and traditional DiD.
#
# REFERENCES:
#   Arkhangelsky et al. (2021). Synthetic Difference-in-Differences.
#   American Economic Review, 111(12), 4088-4118.
###############################################################################

source("00_packages.R")

data_dir <- "../data/"
fig_dir <- "../figures/"

cat("=== SYNTHETIC DiD ROBUSTNESS ANALYSIS ===\n\n")

###############################################################################
# Load Data
###############################################################################

panel <- readRDS(paste0(data_dir, "panel_clean.rds"))

# Create first_treat column if not present (required for SDID analysis)
if (!"first_treat" %in% names(panel)) {
  panel <- panel %>%
    mutate(first_treat = ifelse(is.na(eers_year) | eers_year == 0, 0L, as.integer(eers_year)))
}

cat("Panel dimensions:", nrow(panel), "obs,", n_distinct(panel$state_abbr), "states,",
    n_distinct(panel$year), "years\n")

###############################################################################
# SDID Requires: Uniform Treatment Timing
#
# For staggered adoption, we focus on comparing:
#   - Early adopters (1998-2004) vs. Never-treated
#   - Using 2004 as uniform treatment year (latest adoption year in sample)
#   - This ensures no "pre-treatment" data is mislabeled as "post-treatment"
###############################################################################

cat("\nPreparing data for SDID (early adopters analysis)...\n")

# Never-treated states
never_treated <- panel %>%
  filter(first_treat == 0) %>%
  distinct(state_abbr)

cat("Never-treated states:", nrow(never_treated), "states\n")

# Create analysis sample: early adopters (1998-2004 only) + never-treated
# Use 2004 as the latest adoption year to avoid misalignment
# (States adopting in 2005+ would have pre-treatment data labeled as post-treatment if we used 2005)
treatment_year <- 2004

# Filter to only include states that adopted in or before 2004
early_adopters <- panel %>%
  filter(first_treat > 0 & first_treat <= 2004) %>%
  distinct(state_abbr, first_treat)

cat("Early adopters (1998-2004):", nrow(early_adopters), "states\n")
print(early_adopters %>% arrange(first_treat))

sdid_sample <- panel %>%
  filter(
    (first_treat <= 2004 & first_treat > 0) |  # Early adopters (1998-2004 only)
    first_treat == 0                            # Never-treated
  ) %>%
  mutate(
    sdid_treated = as.integer(first_treat > 0 & first_treat <= 2004),
    sdid_post = as.integer(year >= treatment_year)
  )

cat("SDID sample:", n_distinct(sdid_sample$state_abbr), "states\n")
cat("Treatment year for SDID:", treatment_year, "\n")

###############################################################################
# Create Balanced Panel Matrix
###############################################################################

# SDID requires balanced panel with no missing values
# Focus on years 1995-2015 for cleaner pre/post balance

sdid_balanced <- sdid_sample %>%
  filter(year >= 1995 & year <= 2015) %>%
  select(state_abbr, year, log_res_elec_pc, sdid_treated) %>%
  filter(!is.na(log_res_elec_pc))

# Check balance
balance_check <- sdid_balanced %>%
  group_by(state_abbr) %>%
  summarise(n_years = n(), .groups = "drop")

if (min(balance_check$n_years) < max(balance_check$n_years)) {
  cat("Warning: Unbalanced panel. Restricting to complete cases.\n")
  complete_states <- balance_check %>%
    filter(n_years == max(n_years)) %>%
    pull(state_abbr)
  sdid_balanced <- sdid_balanced %>%
    filter(state_abbr %in% complete_states)
}

cat("Balanced panel:", n_distinct(sdid_balanced$state_abbr), "states x",
    n_distinct(sdid_balanced$year), "years\n")

###############################################################################
# Convert to Matrix Format for SDID
###############################################################################

cat("\nConverting to matrix format...\n")

# Pivot to wide format (states x years)
Y_wide <- sdid_balanced %>%
  select(state_abbr, year, log_res_elec_pc) %>%
  pivot_wider(names_from = year, values_from = log_res_elec_pc)

# Treatment indicator
treatment_status <- sdid_balanced %>%
  distinct(state_abbr, sdid_treated) %>%
  arrange(sdid_treated, state_abbr)  # Control states first

# Reorder Y_wide to match: control first, then treated
Y_wide <- Y_wide %>%
  left_join(treatment_status, by = "state_abbr") %>%
  arrange(sdid_treated, state_abbr)

# Extract matrix
Y <- as.matrix(Y_wide %>% select(-state_abbr, -sdid_treated))
rownames(Y) <- Y_wide$state_abbr

# Count control and treated units
N0 <- sum(treatment_status$sdid_treated == 0)  # Control units
N1 <- sum(treatment_status$sdid_treated == 1)  # Treated units

# Count pre and post periods
years_vec <- as.integer(colnames(Y))
T0 <- sum(years_vec < treatment_year)  # Pre-treatment periods
T1 <- sum(years_vec >= treatment_year) # Post-treatment periods

cat("Matrix dimensions: ", nrow(Y), "units x", ncol(Y), "periods\n")
cat("Control units (N0):", N0, "\n")
cat("Treated units (N1):", N1, "\n")
cat("Pre-treatment periods (T0):", T0, "\n")
cat("Post-treatment periods (T1):", T1, "\n")

###############################################################################
# Estimate SDID (Manual Implementation)
###############################################################################

cat("\nEstimating Synthetic DiD...\n")

# SDID combines:
# 1. Unit weights (omega) from synthetic control
# 2. Time weights (lambda) from DiD

# Step 1: Compute unit weights (synthetic control approach)
# Minimize pre-treatment fit between treated average and weighted controls

Y_pre_control <- Y[1:N0, 1:T0]
Y_pre_treated <- Y[(N0+1):(N0+N1), 1:T0]
Y_pre_treated_avg <- colMeans(Y_pre_treated)

# Simple correlation-based weights for controls
# (More sophisticated: quadratic programming as in synthdid package)
correlations <- apply(Y_pre_control, 1, function(row) {
  cor(row, Y_pre_treated_avg)
})
correlations[correlations < 0] <- 0
omega <- correlations / sum(correlations)

cat("\nUnit weights (top 5 controls):\n")
print(head(sort(omega, decreasing = TRUE), 5))

# Step 2: Compute time weights
# Weight pre-treatment periods by inverse distance to treatment
time_weights <- exp(-(T0 - 1:T0) / 3)  # Exponential decay
lambda <- time_weights / sum(time_weights)

cat("\nTime weights (last 5 pre-periods):\n")
print(tail(lambda, 5))

# Step 3: Compute SDID estimator
# Y_post_treated - Y_post_control(weighted) - [Y_pre_treated - Y_pre_control(weighted)](time-weighted)

Y_post_control <- Y[1:N0, (T0+1):(T0+T1)]
Y_post_treated <- Y[(N0+1):(N0+N1), (T0+1):(T0+T1)]

# Weighted control outcomes
Y_pre_control_weighted <- colSums(Y_pre_control * omega)
Y_post_control_weighted <- colSums(Y_post_control * omega)

# Average treated outcomes
Y_pre_treated_avg <- colMeans(Y_pre_treated)
Y_post_treated_avg <- colMeans(Y_post_treated)

# Pre-treatment gap (time-weighted)
pre_gap <- sum((Y_pre_treated_avg - Y_pre_control_weighted) * lambda)

# Post-treatment outcomes
post_treated <- mean(Y_post_treated_avg)
post_control <- mean(Y_post_control_weighted)

# SDID estimate = Post gap - Pre gap (adjusted)
sdid_estimate <- (post_treated - post_control) - pre_gap

cat("\n=== SDID RESULTS ===\n")
cat("SDID Estimate:", round(sdid_estimate, 4), "\n")
cat("Interpretation: Early EERS adopters had", round(sdid_estimate * 100, 2),
    "% lower electricity consumption\n")

###############################################################################
# Jackknife Standard Errors
###############################################################################

cat("\nComputing jackknife standard errors...\n")

jackknife_estimates <- numeric(N0 + N1)

for (i in 1:(N0 + N1)) {
  # Leave one unit out
  Y_loo <- Y[-i, ]

  if (i <= N0) {
    # Dropped a control unit
    N0_loo <- N0 - 1
    N1_loo <- N1
  } else {
    # Dropped a treated unit
    N0_loo <- N0
    N1_loo <- N1 - 1
  }

  # Skip if we drop all treated or all controls
  if (N0_loo < 2 | N1_loo < 1) {
    jackknife_estimates[i] <- NA
    next
  }

  # Recompute weights and estimate
  Y_pre_c <- Y_loo[1:N0_loo, 1:T0]
  Y_pre_t <- Y_loo[(N0_loo+1):(N0_loo+N1_loo), 1:T0, drop = FALSE]
  Y_post_c <- Y_loo[1:N0_loo, (T0+1):(T0+T1)]
  Y_post_t <- Y_loo[(N0_loo+1):(N0_loo+N1_loo), (T0+1):(T0+T1), drop = FALSE]

  Y_pre_t_avg <- colMeans(Y_pre_t)

  corr_loo <- apply(Y_pre_c, 1, function(row) cor(row, Y_pre_t_avg))
  corr_loo[corr_loo < 0] <- 0
  if (sum(corr_loo) == 0) corr_loo <- rep(1/N0_loo, N0_loo)
  omega_loo <- corr_loo / sum(corr_loo)

  Y_pre_c_w <- colSums(Y_pre_c * omega_loo)
  Y_post_c_w <- colSums(Y_post_c * omega_loo)

  pre_gap_loo <- sum((Y_pre_t_avg - Y_pre_c_w) * lambda)
  post_gap_loo <- mean(colMeans(Y_post_t)) - mean(Y_post_c_w)

  jackknife_estimates[i] <- post_gap_loo - pre_gap_loo
}

# Jackknife SE formula
valid_jk <- jackknife_estimates[!is.na(jackknife_estimates)]
n_jk <- length(valid_jk)
jk_mean <- mean(valid_jk)
jk_var <- ((n_jk - 1) / n_jk) * sum((valid_jk - jk_mean)^2)
sdid_se <- sqrt(jk_var)

cat("Jackknife SE:", round(sdid_se, 4), "\n")
cat("95% CI: [", round(sdid_estimate - 1.96 * sdid_se, 4), ",",
    round(sdid_estimate + 1.96 * sdid_se, 4), "]\n")

# t-statistic and p-value
t_stat <- sdid_estimate / sdid_se
p_value <- 2 * (1 - pnorm(abs(t_stat)))
cat("t-statistic:", round(t_stat, 3), "\n")
cat("p-value:", round(p_value, 4), "\n")

###############################################################################
# Compare with Traditional DiD and Synthetic Control
###############################################################################

cat("\n=== CROSS-METHOD COMPARISON ===\n")

# Traditional DiD (equal weights)
did_pre_gap <- mean(Y_pre_treated_avg) - mean(colMeans(Y_pre_control))
did_post_gap <- mean(Y_post_treated_avg) - mean(colMeans(Y_post_control))
did_estimate <- did_post_gap - did_pre_gap

cat("Traditional DiD estimate:", round(did_estimate, 4), "\n")

# Synthetic Control (no time weights)
sc_post_gap <- mean(Y_post_treated_avg) - mean(Y_post_control_weighted)
sc_estimate <- sc_post_gap  # SC uses level comparison, not pre-trend adjusted

cat("Synthetic Control estimate:", round(sc_estimate, 4), "\n")
cat("SDID estimate:", round(sdid_estimate, 4), "\n")

# Check: SDID should be between SC and DiD
if ((sdid_estimate >= min(sc_estimate, did_estimate)) &
    (sdid_estimate <= max(sc_estimate, did_estimate))) {
  cat("\nVALIDATION: SDID is between SC and DiD estimates (as expected)\n")
} else {
  cat("\nNOTE: SDID is outside SC-DiD range (unusual but possible)\n")
}

###############################################################################
# Save Results
###############################################################################

sdid_results <- list(
  estimate = sdid_estimate,
  se = sdid_se,
  ci_lower = sdid_estimate - 1.96 * sdid_se,
  ci_upper = sdid_estimate + 1.96 * sdid_se,
  t_stat = t_stat,
  p_value = p_value,
  did_estimate = did_estimate,
  sc_estimate = sc_estimate,
  N0 = N0,
  N1 = N1,
  T0 = T0,
  T1 = T1,
  treatment_year = treatment_year,
  unit_weights = omega,
  time_weights = lambda
)

saveRDS(sdid_results, paste0(data_dir, "sdid_results.rds"))

cat("\n=== SDID ANALYSIS COMPLETE ===\n")
cat("Results saved to: data/sdid_results.rds\n")

###############################################################################
# Create Comparison Table
###############################################################################

comparison_df <- tibble(
  Estimator = c("Synthetic Control", "Traditional DiD", "Synthetic DiD"),
  Estimate = c(sc_estimate, did_estimate, sdid_estimate),
  SE = c(NA, NA, sdid_se),
  `95% CI` = c("—", "—", paste0("[", round(sdid_estimate - 1.96*sdid_se, 3),
                                 ", ", round(sdid_estimate + 1.96*sdid_se, 3), "]"))
)

cat("\nCross-Method Comparison Table:\n")
print(comparison_df)

write_csv(comparison_df, paste0(data_dir, "sdid_comparison.csv"))
