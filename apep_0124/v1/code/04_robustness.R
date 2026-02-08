# =============================================================================
# 04_robustness.R
# Robustness checks for RDD analysis
# =============================================================================

source("00_packages.R")

# =============================================================================
# 1. Load data and results
# =============================================================================

cat("Loading data...\n")

focal_with_outcome <- read_csv("../data/rdd_focal_votes.csv", show_col_types = FALSE) %>%
  # Re-create outcome variable (simplified)
  mutate(subsequent_turnout = turnout_pct)  # Placeholder - will be fixed

# Load actual outcome data
muni_turnout <- read_csv("../data/muni_year_turnout.csv", show_col_types = FALSE)

# Reconstruct focal_with_outcome with subsequent turnout
focal_votes <- read_csv("../data/rdd_focal_votes.csv", show_col_types = FALSE)

focal_with_outcome <- focal_votes %>%
  left_join(
    muni_turnout %>%
      rename(future_year = vote_year, subsequent_turnout = avg_turnout),
    by = "muni_id",
    relationship = "many-to-many"
  ) %>%
  filter(future_year > vote_year, future_year <= vote_year + 3) %>%
  group_by(vote_proposal_id, muni_id, gemeinde_name, kanton_name, vote_date, vote_year,
           yes_pct, running_var, local_win, turnout_pct, eligible_voters,
           language_region, policy_domain) %>%
  summarise(
    subsequent_turnout = mean(subsequent_turnout, na.rm = TRUE),
    n_future_years = n(),
    .groups = "drop"
  ) %>%
  filter(!is.na(subsequent_turnout))

results <- readRDS("../data/rdd_results.rds")

# =============================================================================
# 2. Alternative Polynomial Orders
# =============================================================================

cat("\n=== POLYNOMIAL ORDER ROBUSTNESS ===\n")

poly_results <- map_dfr(1:2, function(p) {
  result <- rdrobust(
    y = focal_with_outcome$subsequent_turnout,
    x = focal_with_outcome$running_var,
    c = 0,
    p = p,
    kernel = "triangular",
    cluster = focal_with_outcome$kanton_name
  )

  tibble(
    polynomial_order = p,
    estimate = result$coef["Conventional"],
    se_robust = result$se["Robust"],
    pvalue = result$pv["Robust"],
    bandwidth = result$bws["h", "left"]
  )
})

print(poly_results)

# =============================================================================
# 3. Alternative Kernels
# =============================================================================

cat("\n=== KERNEL ROBUSTNESS ===\n")

kernels <- c("triangular", "uniform", "epanechnikov")

kernel_results <- map_dfr(kernels, function(k) {
  result <- rdrobust(
    y = focal_with_outcome$subsequent_turnout,
    x = focal_with_outcome$running_var,
    c = 0,
    kernel = k,
    cluster = focal_with_outcome$kanton_name
  )

  tibble(
    kernel = k,
    estimate = result$coef["Conventional"],
    se_robust = result$se["Robust"],
    pvalue = result$pv["Robust"]
  )
})

print(kernel_results)

# =============================================================================
# 4. Excluding Municipalities at Exact 50%
# =============================================================================

cat("\n=== EXCLUDING EXACT 50% VOTES ===\n")

# Check for heaping at 50%
exact_50 <- focal_with_outcome %>%
  filter(abs(running_var) < 0.5) %>%
  nrow()

cat("Observations with yes_pct between 49.5% and 50.5%:", exact_50, "\n")

# Exclude donut around cutoff
donut_sizes <- c(0, 0.5, 1, 2)

donut_results <- map_dfr(donut_sizes, function(donut) {
  subset <- focal_with_outcome %>%
    filter(abs(running_var) > donut)

  if (nrow(subset) < 100) {
    return(tibble(donut = donut, estimate = NA, n = nrow(subset)))
  }

  result <- tryCatch({
    rdrobust(
      y = subset$subsequent_turnout,
      x = subset$running_var,
      c = 0,
      kernel = "triangular"
    )
  }, error = function(e) NULL)

  if (is.null(result)) {
    return(tibble(donut = donut, estimate = NA, n = nrow(subset)))
  }

  tibble(
    donut = donut,
    estimate = result$coef["Conventional"],
    se_robust = result$se["Robust"],
    pvalue = result$pv["Robust"],
    n = nrow(subset)
  )
})

print(donut_results)

# =============================================================================
# 5. Heterogeneity by Language Region
# =============================================================================

cat("\n=== HETEROGENEITY BY LANGUAGE REGION ===\n")

regions <- focal_with_outcome %>%
  count(language_region) %>%
  filter(n > 100) %>%
  pull(language_region)

region_results <- map_dfr(regions, function(reg) {
  subset <- focal_with_outcome %>% filter(language_region == reg)

  if (nrow(subset) < 50) {
    return(tibble(region = reg, estimate = NA))
  }

  result <- tryCatch({
    rdrobust(
      y = subset$subsequent_turnout,
      x = subset$running_var,
      c = 0,
      kernel = "triangular"
    )
  }, error = function(e) NULL)

  if (is.null(result)) {
    return(tibble(region = reg, estimate = NA))
  }

  tibble(
    region = reg,
    estimate = result$coef["Conventional"],
    se_robust = result$se["Robust"],
    pvalue = result$pv["Robust"],
    n = nrow(subset)
  )
})

print(region_results)

# =============================================================================
# 6. Heterogeneity by Vote Year (Pre/Post 2015)
# =============================================================================

cat("\n=== HETEROGENEITY BY TIME PERIOD ===\n")

time_periods <- list(
  early = c(2010, 2014),
  late = c(2015, 2024)
)

time_results <- map_dfr(names(time_periods), function(period) {
  years <- time_periods[[period]]
  subset <- focal_with_outcome %>%
    filter(vote_year >= years[1], vote_year <= years[2])

  if (nrow(subset) < 100) {
    return(tibble(period = period, estimate = NA))
  }

  result <- tryCatch({
    rdrobust(
      y = subset$subsequent_turnout,
      x = subset$running_var,
      c = 0,
      kernel = "triangular"
    )
  }, error = function(e) NULL)

  if (is.null(result)) {
    return(tibble(period = period, estimate = NA))
  }

  tibble(
    period = period,
    estimate = result$coef["Conventional"],
    se_robust = result$se["Robust"],
    pvalue = result$pv["Robust"],
    n = nrow(subset)
  )
})

print(time_results)

# =============================================================================
# 7. Alternative Outcome: Turnout Change
# =============================================================================

cat("\n=== ALTERNATIVE OUTCOME: TURNOUT CHANGE ===\n")

# Instead of level, use change in turnout
focal_with_change <- focal_with_outcome %>%
  mutate(turnout_change = subsequent_turnout - turnout_pct)

result_change <- rdrobust(
  y = focal_with_change$turnout_change,
  x = focal_with_change$running_var,
  c = 0,
  kernel = "triangular",
  cluster = focal_with_change$kanton_name
)

cat("Outcome: Turnout change (subsequent - focal)\n")
cat("Estimate:", round(result_change$coef["Conventional"], 4), "\n")
cat("Robust SE:", round(result_change$se["Robust"], 4), "\n")
cat("P-value:", round(result_change$pv["Robust"], 4), "\n")

# =============================================================================
# 8. Save All Robustness Results
# =============================================================================

cat("\nSaving robustness results...\n")

robustness <- list(
  polynomial = poly_results,
  kernel = kernel_results,
  donut = donut_results,
  heterogeneity_region = region_results,
  heterogeneity_time = time_results
)

saveRDS(robustness, "../data/robustness_results.rds")

# Combine into single table
robustness_table <- bind_rows(
  poly_results %>% mutate(test = paste0("Polynomial p=", polynomial_order)) %>%
    select(test, estimate, se_robust, pvalue),
  kernel_results %>% mutate(test = paste0("Kernel: ", kernel)) %>%
    select(test, estimate, se_robust, pvalue),
  donut_results %>% filter(!is.na(estimate)) %>%
    mutate(test = paste0("Donut: ", donut, "pp")) %>%
    select(test, estimate, se_robust, pvalue)
)

write_csv(robustness_table, "../tables/robustness_summary.csv")

cat("\nDone.\n")
