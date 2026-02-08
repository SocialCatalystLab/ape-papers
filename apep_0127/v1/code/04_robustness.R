# ============================================================================
# 04_robustness.R
# Swedish School Transport (Skolskjuts) and Educational Equity
# Robustness checks and sensitivity analysis
# ============================================================================

source("00_packages.R")

# ============================================================================
# 1. LOAD DATA
# ============================================================================

cat("\n=== Loading analysis data ===\n")

analysis_2023 <- read_csv("../data/processed/analysis_2023.csv", show_col_types = FALSE)
cat("  Analysis data:", nrow(analysis_2023), "municipalities\n")

# ============================================================================
# 2. BANDWIDTH SENSITIVITY
# ============================================================================

cat("\n=== Bandwidth Sensitivity Analysis ===\n")

# Define bandwidth multipliers
bw_multipliers <- c(0.5, 0.75, 1.0, 1.25, 1.5, 2.0)

# Get optimal bandwidth first
rdd_base <- rdrobust(
  y = analysis_2023$merit_all,
  x = analysis_2023$running_var,
  c = 0,
  bwselect = "mserd"
)

optimal_bw <- rdd_base$bws[1]
cat("  Optimal bandwidth:", round(optimal_bw, 2), "\n")

# Estimate for each bandwidth
bw_sensitivity <- map_dfr(bw_multipliers, function(mult) {
  bw <- optimal_bw * mult

  rdd <- tryCatch({
    rdrobust(
      y = analysis_2023$merit_all,
      x = analysis_2023$running_var,
      c = 0,
      h = bw
    )
  }, error = function(e) NULL)

  if (is.null(rdd)) return(NULL)

  tibble(
    bandwidth_multiplier = mult,
    bandwidth = bw,
    estimate = rdd$Estimate[1],
    se = rdd$se[1],
    ci_lower = rdd$ci[1],
    ci_upper = rdd$ci[3],
    n_left = rdd$N_h[1],
    n_right = rdd$N_h[2],
    p_value = rdd$pv[1]
  )
})

cat("\n  Bandwidth sensitivity results:\n")
print(bw_sensitivity |> select(bandwidth_multiplier, estimate, se, p_value))

# ============================================================================
# 3. POLYNOMIAL ORDER SENSITIVITY
# ============================================================================

cat("\n=== Polynomial Order Sensitivity ===\n")

poly_orders <- c(1, 2, 3)

poly_sensitivity <- map_dfr(poly_orders, function(p) {
  rdd <- tryCatch({
    rdrobust(
      y = analysis_2023$merit_all,
      x = analysis_2023$running_var,
      c = 0,
      p = p,
      bwselect = "mserd"
    )
  }, error = function(e) NULL)

  if (is.null(rdd)) return(NULL)

  tibble(
    polynomial_order = p,
    estimate = rdd$Estimate[1],
    se = rdd$se[1],
    ci_lower = rdd$ci[1],
    ci_upper = rdd$ci[3],
    p_value = rdd$pv[1]
  )
})

cat("\n  Polynomial sensitivity results:\n")
print(poly_sensitivity)

# ============================================================================
# 4. DONUT RDD (exclude observations near cutoff)
# ============================================================================

cat("\n=== Donut RDD ===\n")

donut_widths <- c(2, 5, 10)  # Percentage points

donut_sensitivity <- map_dfr(donut_widths, function(d) {
  # Exclude observations within d percentage points of cutoff
  analysis_donut <- analysis_2023 |>
    filter(abs(running_var) > d)

  if (nrow(analysis_donut) < 30) return(NULL)

  rdd <- tryCatch({
    rdrobust(
      y = analysis_donut$merit_all,
      x = analysis_donut$running_var,
      c = 0,
      bwselect = "mserd"
    )
  }, error = function(e) NULL)

  if (is.null(rdd)) return(NULL)

  tibble(
    donut_width = d,
    n_excluded = nrow(analysis_2023) - nrow(analysis_donut),
    estimate = rdd$Estimate[1],
    se = rdd$se[1],
    p_value = rdd$pv[1]
  )
})

if (nrow(donut_sensitivity) > 0) {
  cat("\n  Donut RDD results:\n")
  print(donut_sensitivity)
}

# ============================================================================
# 5. PLACEBO THRESHOLD TESTS
# ============================================================================

cat("\n=== Placebo Threshold Tests ===\n")

# Test for discontinuities at non-threshold values
placebo_cutoffs <- c(-30, -20, -10, 10, 20, 30)

placebo_tests <- map_dfr(placebo_cutoffs, function(cutoff) {
  rdd <- tryCatch({
    rdrobust(
      y = analysis_2023$merit_all,
      x = analysis_2023$running_var,
      c = cutoff,
      bwselect = "mserd"
    )
  }, error = function(e) NULL)

  if (is.null(rdd)) return(NULL)

  tibble(
    placebo_cutoff = cutoff,
    estimate = rdd$Estimate[1],
    se = rdd$se[1],
    p_value = rdd$pv[1],
    significant = rdd$pv[1] < 0.05
  )
})

if (nrow(placebo_tests) > 0) {
  cat("\n  Placebo test results:\n")
  print(placebo_tests)
  cat("\n  Number of significant placebos:", sum(placebo_tests$significant), "of", nrow(placebo_tests), "\n")
}

# ============================================================================
# 6. COVARIATE BALANCE AT THRESHOLD
# ============================================================================

cat("\n=== Covariate Balance ===\n")

# Test for discontinuities in pre-determined covariates
covariates <- c("teachers_qualified", "student_teacher_ratio")

balance_tests <- map_dfr(covariates, function(var) {
  y <- analysis_2023[[var]]

  if (sum(!is.na(y)) < 30) return(NULL)

  rdd <- tryCatch({
    rdrobust(
      y = y,
      x = analysis_2023$running_var,
      c = 0,
      bwselect = "mserd"
    )
  }, error = function(e) NULL)

  if (is.null(rdd)) return(NULL)

  tibble(
    covariate = var,
    estimate = rdd$Estimate[1],
    se = rdd$se[1],
    p_value = rdd$pv[1],
    balanced = rdd$pv[1] > 0.10
  )
})

if (nrow(balance_tests) > 0) {
  cat("\n  Balance test results:\n")
  print(balance_tests)
}

# ============================================================================
# 7. PANEL RDD (using multiple years)
# ============================================================================

cat("\n=== Panel Analysis ===\n")

# Load full panel
analysis_panel <- read_csv("../data/processed/analysis_panel.csv", show_col_types = FALSE) |>
  mutate(
    running_var = school_access_2km - 50
  ) |>
  filter(!is.na(merit_all) & !is.na(running_var))

# Estimate by year
yearly_estimates <- analysis_panel |>
  group_by(year) |>
  filter(n() > 50) |>
  group_modify(~{
    rdd <- tryCatch({
      rdrobust(
        y = .x$merit_all,
        x = .x$running_var,
        c = 0,
        bwselect = "mserd"
      )
    }, error = function(e) NULL)

    if (is.null(rdd)) {
      return(tibble(estimate = NA_real_, se = NA_real_, p_value = NA_real_))
    }

    tibble(
      estimate = rdd$Estimate[1],
      se = rdd$se[1],
      p_value = rdd$pv[1]
    )
  }) |>
  ungroup()

cat("\n  Year-by-year estimates:\n")
print(yearly_estimates |> filter(!is.na(estimate)))

# ============================================================================
# 8. HETEROGENEITY BY URBANITY
# ============================================================================

cat("\n=== Heterogeneity by Urbanity ===\n")

urban_types <- unique(analysis_2023$urban_type)

heterogeneity_urban <- map_dfr(urban_types, function(type) {
  subset <- analysis_2023 |> filter(urban_type == type)

  if (nrow(subset) < 20) return(NULL)

  rdd <- tryCatch({
    rdrobust(
      y = subset$merit_all,
      x = subset$running_var,
      c = 0,
      bwselect = "mserd"
    )
  }, error = function(e) NULL)

  if (is.null(rdd)) return(NULL)

  tibble(
    urban_type = type,
    n = nrow(subset),
    estimate = rdd$Estimate[1],
    se = rdd$se[1],
    p_value = rdd$pv[1]
  )
})

if (nrow(heterogeneity_urban) > 0) {
  cat("\n  Heterogeneity by urbanity:\n")
  print(heterogeneity_urban)
}

# ============================================================================
# 9. SAVE ROBUSTNESS RESULTS
# ============================================================================

cat("\n=== Saving robustness results ===\n")

# Combine all sensitivity results
robustness_summary <- list(
  bandwidth_sensitivity = bw_sensitivity,
  polynomial_sensitivity = poly_sensitivity,
  donut_sensitivity = donut_sensitivity,
  placebo_tests = placebo_tests,
  balance_tests = balance_tests,
  yearly_estimates = yearly_estimates,
  heterogeneity_urban = heterogeneity_urban
)

# Save individual tables
if (nrow(bw_sensitivity) > 0) {
  write_csv(bw_sensitivity, "../tables/robustness_bandwidth.csv")
}
if (nrow(poly_sensitivity) > 0) {
  write_csv(poly_sensitivity, "../tables/robustness_polynomial.csv")
}
if (nrow(placebo_tests) > 0) {
  write_csv(placebo_tests, "../tables/robustness_placebo.csv")
}
if (nrow(balance_tests) > 0) {
  write_csv(balance_tests, "../tables/robustness_balance.csv")
}
if (nrow(yearly_estimates) > 0) {
  write_csv(yearly_estimates, "../tables/robustness_yearly.csv")
}
if (nrow(heterogeneity_urban) > 0) {
  write_csv(heterogeneity_urban, "../tables/robustness_heterogeneity.csv")
}

cat("\nRobustness checks complete.\n")
