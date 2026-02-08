# ==============================================================================
# 04_robustness.R
# Robustness checks for synthetic control analysis
# ==============================================================================

source("00_packages.R")

# Load data
cat("Loading data...\n")
analysis_data <- readRDS("../data/processed/analysis_data.rds")
results <- readRDS("../data/processed/synth_results.rds")
params <- readRDS("../data/processed/analysis_params.rds")
estimates <- readRDS("../data/processed/estimates.rds")

# Load nnls
library(nnls)

# ------------------------------------------------------------------------------
# 1. Placebo Tests: Apply synthetic control to each donor country
# ------------------------------------------------------------------------------
cat("\n=== Placebo Tests (In-Space) ===\n")

donor_countries <- params$donor_countries
placebo_results <- list()

for (placebo_country in donor_countries) {
  cat(sprintf("  Running placebo for %s...", placebo_country))

  # Get placebo treated country data
  placebo_data <- analysis_data %>%
    filter(country == placebo_country) %>%
    arrange(time_id) %>%
    pull(hpi_norm)

  # Get donor data (all countries except placebo)
  other_donors <- setdiff(c("Netherlands", donor_countries), placebo_country)

  donor_matrix <- analysis_data %>%
    filter(country %in% other_donors) %>%
    select(country, time_id, hpi_norm) %>%
    pivot_wider(names_from = country, values_from = hpi_norm) %>%
    arrange(time_id) %>%
    select(-time_id) %>%
    as.matrix()

  # Pre-treatment data
  pre_idx <- 1:params$n_pre_periods
  Y1_pre <- placebo_data[pre_idx]
  Y0_pre <- donor_matrix[pre_idx, ]

  # Estimate weights
  tryCatch({
    nnls_result <- nnls(Y0_pre, Y1_pre)
    weights <- nnls_result$x / sum(nnls_result$x)

    # Construct synthetic
    n_periods <- min(length(placebo_data), nrow(donor_matrix))
    synth_placebo <- donor_matrix[1:n_periods, ] %*% weights

    # Calculate gap
    gap <- placebo_data[1:n_periods] - as.numeric(synth_placebo)

    # Pre and post RMSE
    pre_rmse <- sqrt(mean(gap[1:params$n_pre_periods]^2))
    post_gap <- mean(gap[(params$n_pre_periods + 1):length(gap)])

    placebo_results[[placebo_country]] <- list(
      country = placebo_country,
      pre_rmse = pre_rmse,
      post_gap = post_gap,
      gap = gap
    )

    cat(sprintf(" pre-RMSE: %.2f, post-gap: %.2f\n", pre_rmse, post_gap))

  }, error = function(e) {
    cat(" FAILED\n")
  })
}

# Compare Netherlands to placebos
nl_pre_rmse <- estimates$pre_fit$rmse
nl_post_gap <- estimates$post_effect$att

placebo_summary <- map_df(placebo_results, function(x) {
  data.frame(
    country = x$country,
    pre_rmse = x$pre_rmse,
    post_gap = x$post_gap
  )
})

cat("\n=== Placebo Summary ===\n")
placebo_summary <- placebo_summary %>%
  arrange(desc(abs(post_gap)))

print(placebo_summary)

# Netherlands rank
nl_rank <- sum(abs(placebo_summary$post_gap) > abs(nl_post_gap)) + 1
cat(sprintf("\nNetherlands post-treatment gap: %.2f\n", nl_post_gap))
cat(sprintf("Netherlands rank among %d countries: %d\n", nrow(placebo_summary) + 1, nl_rank))
cat(sprintf("p-value (exact): %.3f\n", nl_rank / (nrow(placebo_summary) + 1)))

# Calculate RMSPE ratio (post/pre)
placebo_summary <- placebo_summary %>%
  mutate(ratio = abs(post_gap) / pre_rmse)

nl_ratio <- abs(nl_post_gap) / nl_pre_rmse

cat(sprintf("\nNetherlands RMSPE ratio (|post-gap|/pre-RMSE): %.2f\n", nl_ratio))
cat(sprintf("Rank by ratio: %d of %d\n",
            sum(placebo_summary$ratio > nl_ratio) + 1,
            nrow(placebo_summary) + 1))

# ------------------------------------------------------------------------------
# 2. Leave-One-Out Robustness
# ------------------------------------------------------------------------------
cat("\n=== Leave-One-Out Robustness ===\n")

# Get Netherlands data
nl_data <- analysis_data %>%
  filter(country == "Netherlands") %>%
  arrange(time_id) %>%
  pull(hpi_norm)

loo_results <- list()

for (leave_out in donor_countries) {
  cat(sprintf("  Leaving out %s...", leave_out))

  # Donors without leave_out
  loo_donors <- setdiff(donor_countries, leave_out)

  donor_matrix <- analysis_data %>%
    filter(country %in% loo_donors) %>%
    select(country, time_id, hpi_norm) %>%
    pivot_wider(names_from = country, values_from = hpi_norm) %>%
    arrange(time_id) %>%
    select(-time_id) %>%
    as.matrix()

  # Pre-treatment data
  pre_idx <- 1:params$n_pre_periods
  Y1_pre <- nl_data[pre_idx]
  Y0_pre <- donor_matrix[pre_idx, ]

  # Estimate weights
  tryCatch({
    nnls_result <- nnls(Y0_pre, Y1_pre)
    weights <- nnls_result$x / sum(nnls_result$x)

    # Construct synthetic
    n_periods <- min(length(nl_data), nrow(donor_matrix))
    synth_loo <- donor_matrix[1:n_periods, ] %*% weights

    # Calculate gap
    gap <- nl_data[1:n_periods] - as.numeric(synth_loo)

    # Post-treatment effect
    post_gap <- mean(gap[(params$n_pre_periods + 1):length(gap)])

    loo_results[[leave_out]] <- post_gap
    cat(sprintf(" ATT: %.2f\n", post_gap))

  }, error = function(e) {
    cat(" FAILED\n")
  })
}

cat("\n=== Leave-One-Out Summary ===\n")
loo_df <- data.frame(
  left_out = names(loo_results),
  att = unlist(loo_results)
) %>%
  arrange(att)

print(loo_df)

cat(sprintf("\nBaseline ATT: %.2f\n", nl_post_gap))
cat(sprintf("LOO range: [%.2f, %.2f]\n", min(loo_df$att), max(loo_df$att)))
cat(sprintf("LOO mean: %.2f\n", mean(loo_df$att)))

# ------------------------------------------------------------------------------
# 3. Different Pre-Treatment Windows
# ------------------------------------------------------------------------------
cat("\n=== Different Pre-Treatment Windows ===\n")

# Test different starting years: 2010, 2012, 2014, 2016
start_years <- c(2010, 2012, 2014, 2016)
window_results <- list()

for (start_year in start_years) {
  cat(sprintf("  Starting from %d...", start_year))

  # Filter data
  window_data <- analysis_data %>%
    filter(year(date) >= start_year)

  # Get Netherlands
  nl_window <- window_data %>%
    filter(country == "Netherlands") %>%
    arrange(time_id) %>%
    pull(hpi_norm)

  # Get donors
  donor_window <- window_data %>%
    filter(country != "Netherlands") %>%
    select(country, time_id, hpi_norm) %>%
    pivot_wider(names_from = country, values_from = hpi_norm) %>%
    arrange(time_id) %>%
    select(-time_id) %>%
    as.matrix()

  # Determine pre-treatment periods
  window_dates <- window_data %>%
    filter(country == "Netherlands") %>%
    pull(date)

  n_pre_window <- sum(window_dates < params$treatment_date)

  # Estimate
  tryCatch({
    Y1_pre <- nl_window[1:n_pre_window]
    Y0_pre <- donor_window[1:n_pre_window, ]

    nnls_result <- nnls(Y0_pre, Y1_pre)
    weights <- nnls_result$x / sum(nnls_result$x)

    n_periods <- min(length(nl_window), nrow(donor_window))
    synth_window <- donor_window[1:n_periods, ] %*% weights

    gap <- nl_window[1:n_periods] - as.numeric(synth_window)
    post_gap <- mean(gap[(n_pre_window + 1):length(gap)])

    window_results[[as.character(start_year)]] <- list(
      start_year = start_year,
      n_pre = n_pre_window,
      att = post_gap
    )

    cat(sprintf(" n_pre=%d, ATT=%.2f\n", n_pre_window, post_gap))

  }, error = function(e) {
    cat(" FAILED\n")
  })
}

# ------------------------------------------------------------------------------
# 4. COVID-19 Truncation
# ------------------------------------------------------------------------------
cat("\n=== COVID-19 Sensitivity ===\n")

# Truncate at 2020Q1 (before COVID)
covid_date <- ymd("2020-01-01")

covid_data <- analysis_data %>%
  filter(date < covid_date)

nl_covid <- covid_data %>%
  filter(country == "Netherlands") %>%
  arrange(time_id) %>%
  pull(hpi_norm)

donor_covid <- covid_data %>%
  filter(country != "Netherlands") %>%
  select(country, time_id, hpi_norm) %>%
  pivot_wider(names_from = country, values_from = hpi_norm) %>%
  arrange(time_id) %>%
  select(-time_id) %>%
  as.matrix()

# Pre-treatment ends at 2019Q1 (37 periods from 2010Q1)
n_pre_covid <- sum(covid_data$date[covid_data$country == "Netherlands"] < params$treatment_date)
n_post_covid <- length(nl_covid) - n_pre_covid

cat(sprintf("Pre-COVID sample: %d pre-treatment, %d post-treatment periods\n",
            n_pre_covid, n_post_covid))

# Estimate
Y1_pre <- nl_covid[1:n_pre_covid]
Y0_pre <- donor_covid[1:n_pre_covid, ]

nnls_result <- nnls(Y0_pre, Y1_pre)
weights_covid <- nnls_result$x / sum(nnls_result$x)

synth_covid <- donor_covid %*% weights_covid
gap_covid <- nl_covid - as.numeric(synth_covid)

att_covid <- mean(gap_covid[(n_pre_covid + 1):length(gap_covid)])

cat(sprintf("ATT (pre-COVID only): %.2f\n", att_covid))
cat(sprintf("ATT (full sample): %.2f\n", nl_post_gap))

# ------------------------------------------------------------------------------
# 5. Save Robustness Results
# ------------------------------------------------------------------------------
cat("\n=== Saving Robustness Results ===\n")

robustness <- list(
  placebo_summary = placebo_summary,
  placebo_results = placebo_results,
  nl_rank = nl_rank,
  nl_pvalue = nl_rank / (nrow(placebo_summary) + 1),
  loo_results = loo_df,
  window_results = window_results,
  att_pre_covid = att_covid
)

saveRDS(robustness, "../data/processed/robustness.rds")

cat("Robustness results saved.\n")
cat("\nRobustness checks complete.\n")
