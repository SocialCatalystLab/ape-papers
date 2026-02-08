# ==============================================================================
# 03_main_analysis.R
# Synthetic Control Analysis: Netherlands Nitrogen Crisis
# Manual implementation (no external Synth package dependency)
# ==============================================================================

source("00_packages.R")

# Load data
cat("Loading analysis data...\n")
analysis_data <- readRDS("../data/processed/analysis_data.rds")
synth_wide <- readRDS("../data/processed/synth_wide.rds")
time_periods <- readRDS("../data/processed/time_periods.rds")
params <- readRDS("../data/processed/analysis_params.rds")

cat(sprintf("Treatment date: %s\n", params$treatment_date))
cat(sprintf("Pre-treatment periods: %d\n", params$n_pre_periods))
cat(sprintf("Post-treatment periods: %d\n", params$n_post_periods))

# ------------------------------------------------------------------------------
# 1. Prepare data matrices
# ------------------------------------------------------------------------------
cat("\n=== Preparing Data Matrices ===\n")

# Get Netherlands and donor country data
nl_data <- analysis_data %>%
  filter(country == "Netherlands") %>%
  arrange(time_id) %>%
  pull(hpi_norm)

donor_data <- analysis_data %>%
  filter(country != "Netherlands") %>%
  select(country, time_id, hpi_norm) %>%
  pivot_wider(names_from = country, values_from = hpi_norm) %>%
  arrange(time_id) %>%
  select(-time_id) %>%
  as.matrix()

# Pre-treatment period
pre_idx <- 1:params$n_pre_periods
post_idx <- (params$n_pre_periods + 1):length(nl_data)

cat(sprintf("Netherlands observations: %d\n", length(nl_data)))
cat(sprintf("Donor countries: %d\n", ncol(donor_data)))
cat(sprintf("Pre-treatment periods: %d\n", length(pre_idx)))
cat(sprintf("Post-treatment periods: %d\n", length(post_idx)))

# Pre-treatment data
Y1_pre <- nl_data[pre_idx]
Y0_pre <- donor_data[pre_idx, ]

# ------------------------------------------------------------------------------
# 2. Estimate Synthetic Control Weights
# Using constrained least squares: min ||Y1 - Y0*w||^2 s.t. w >= 0, sum(w) = 1
# ------------------------------------------------------------------------------
cat("\n=== Estimating Synthetic Control Weights ===\n")

# Objective function: sum of squared errors
objective <- function(w, Y1, Y0) {
  synth <- Y0 %*% w
  sum((Y1 - synth)^2)
}

# Gradient
gradient <- function(w, Y1, Y0) {
  synth <- Y0 %*% w
  -2 * t(Y0) %*% (Y1 - synth)
}

# Number of donors
n_donors <- ncol(Y0_pre)
donor_names <- colnames(donor_data)

# Initial weights (equal)
w_init <- rep(1/n_donors, n_donors)

# Use constrained optimization (L-BFGS-B with bounds)
# Note: This doesn't enforce sum(w) = 1 directly, so we'll use a different approach

# Method: Quadratic programming via reformulation
# Or: Simple constrained optimization using nlm/optim with projection

# Simpler approach: Use nnls (non-negative least squares) then normalize
if (!require("nnls", quietly = TRUE)) {
  install.packages("nnls", repos = "https://cran.r-project.org")
  library(nnls)
}

# Non-negative least squares
nnls_result <- nnls(Y0_pre, Y1_pre)
weights_raw <- nnls_result$x

# Normalize to sum to 1
weights <- weights_raw / sum(weights_raw)
names(weights) <- donor_names

# Display weights
cat("\nSynthetic Control Weights:\n")
weights_df <- data.frame(
  country = names(weights),
  weight = as.numeric(weights)
) %>%
  filter(weight > 0.001) %>%
  arrange(desc(weight))

print(weights_df)

cat(sprintf("\nTotal weight: %.4f\n", sum(weights)))
cat(sprintf("Countries with positive weight: %d\n", sum(weights > 0.001)))

# ------------------------------------------------------------------------------
# 3. Construct Synthetic Netherlands
# ------------------------------------------------------------------------------
cat("\n=== Constructing Synthetic Netherlands ===\n")

# Full time series
synth_nl <- donor_data %*% weights

cat(sprintf("Netherlands series length: %d\n", length(nl_data)))
cat(sprintf("Synthetic series length: %d\n", length(synth_nl)))

# Match lengths (use minimum)
n_periods <- min(length(nl_data), length(synth_nl))

# Create results dataframe
results <- data.frame(
  time_id = 1:n_periods,
  netherlands = nl_data[1:n_periods],
  synthetic = as.numeric(synth_nl[1:n_periods])
) %>%
  mutate(
    gap = netherlands - synthetic,
    post = time_id > params$n_pre_periods
  ) %>%
  left_join(time_periods, by = "time_id")

cat("First 10 periods:\n")
print(results[1:10, c("date", "netherlands", "synthetic", "gap", "post")])

# ------------------------------------------------------------------------------
# 4. Evaluate Pre-Treatment Fit
# ------------------------------------------------------------------------------
cat("\n=== Pre-Treatment Fit ===\n")

pre_fit <- results %>%
  filter(!post) %>%
  summarize(
    mean_nl = mean(netherlands),
    mean_synth = mean(synthetic),
    mean_gap = mean(gap),
    rmse = sqrt(mean(gap^2)),
    mape = mean(abs(gap / netherlands)) * 100,
    r_squared = 1 - sum(gap^2) / sum((netherlands - mean(netherlands))^2),
    .groups = "drop"
  )

cat(sprintf("Mean Netherlands HPI: %.2f\n", pre_fit$mean_nl))
cat(sprintf("Mean Synthetic HPI: %.2f\n", pre_fit$mean_synth))
cat(sprintf("Mean Gap: %.3f\n", pre_fit$mean_gap))
cat(sprintf("RMSE: %.3f\n", pre_fit$rmse))
cat(sprintf("MAPE: %.2f%%\n", pre_fit$mape))
cat(sprintf("R-squared: %.4f\n", pre_fit$r_squared))

# ------------------------------------------------------------------------------
# 5. Estimate Treatment Effect
# ------------------------------------------------------------------------------
cat("\n=== Treatment Effect Estimates ===\n")

# Average treatment effect on treated (ATT)
post_effect <- results %>%
  filter(post) %>%
  summarize(
    att = mean(gap),
    se = sd(gap) / sqrt(n()),
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se,
    min_gap = min(gap),
    max_gap = max(gap),
    n_periods = n(),
    .groups = "drop"
  )

cat(sprintf("\nAverage Treatment Effect (ATT): %.3f index points\n", post_effect$att))
cat(sprintf("Standard Error: %.3f\n", post_effect$se))
cat(sprintf("95%% CI: [%.3f, %.3f]\n", post_effect$ci_lower, post_effect$ci_upper))

# Interpretation: positive gap means Netherlands HPI higher than synthetic
# This is consistent with supply constraint raising prices
if (post_effect$att > 0) {
  cat("\nInterpretation: Netherlands house prices were HIGHER than synthetic control\n")
  cat("This is consistent with the nitrogen crisis causing a supply constraint\n")
} else {
  cat("\nInterpretation: Netherlands house prices were LOWER than synthetic control\n")
}

# Effect as percentage of pre-treatment level
pct_effect <- post_effect$att / pre_fit$mean_nl * 100
cat(sprintf("\nEffect as %% of pre-treatment level: %.2f%%\n", pct_effect))

# By year
cat("\n=== Effect by Year ===\n")
yearly_effects <- results %>%
  filter(post) %>%
  mutate(year = year(date)) %>%
  group_by(year) %>%
  summarize(
    mean_gap = mean(gap),
    n_quarters = n(),
    .groups = "drop"
  )

print(as.data.frame(yearly_effects))

# Cumulative effect over time
cat("\n=== Quarterly Effects (Post-Treatment) ===\n")
post_results <- results %>%
  filter(post) %>%
  select(date, netherlands, synthetic, gap) %>%
  mutate(across(c(netherlands, synthetic, gap), ~round(., 2)))
print(as.data.frame(post_results))

# ------------------------------------------------------------------------------
# 6. DiD Comparison (Simple Average)
# ------------------------------------------------------------------------------
cat("\n=== Simple DiD Comparison ===\n")

did_data <- analysis_data %>%
  mutate(group = if_else(country == "Netherlands", "Netherlands", "Donors"))

did_means <- did_data %>%
  group_by(group, post) %>%
  summarize(mean_hpi = mean(hpi_norm), .groups = "drop") %>%
  pivot_wider(names_from = c(group, post), values_from = mean_hpi)

did_estimate <- (did_means$Netherlands_TRUE - did_means$Netherlands_FALSE) -
  (did_means$Donors_TRUE - did_means$Donors_FALSE)

cat(sprintf("Netherlands change: %.2f\n",
            did_means$Netherlands_TRUE - did_means$Netherlands_FALSE))
cat(sprintf("Donors average change: %.2f\n",
            did_means$Donors_TRUE - did_means$Donors_FALSE))
cat(sprintf("DiD estimate: %.2f index points\n", did_estimate))

# ------------------------------------------------------------------------------
# 7. Save Results
# ------------------------------------------------------------------------------
cat("\n=== Saving Results ===\n")

# Main results
saveRDS(results, "../data/processed/synth_results.rds")
saveRDS(weights_df, "../data/processed/synth_weights.rds")

# Estimates summary
estimates <- list(
  pre_fit = pre_fit,
  post_effect = post_effect,
  yearly_effects = yearly_effects,
  weights = weights_df,
  did_estimate = did_estimate
)
saveRDS(estimates, "../data/processed/estimates.rds")

cat("Results saved to ../data/processed/\n")
cat("\nMain analysis complete.\n")
