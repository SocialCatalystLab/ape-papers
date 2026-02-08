# =============================================================================
# Paper 107: Spatial RDD of Primary Seatbelt Enforcement Laws
# 03_main_analysis.R - Main RDD Estimation
# =============================================================================

source(here::here("output/paper_107/code/00_packages.R"))

# Load analysis data
analysis_df <- readRDS(file.path(dir_data, "analysis_df.rds"))

message("Analysis data loaded: ", nrow(analysis_df), " crashes")

# =============================================================================
# 1. Main RDD Specification
# =============================================================================

message("\n=== Main RDD Estimation ===")

# Primary outcome: Fatality probability per crash
# Running variable: signed distance to border (positive = primary state)
# Treatment: crash in primary enforcement state

# Use rdrobust for robust RDD estimation
main_rd <- rdrobust(
  y = analysis_df$fatality_prob,
  x = analysis_df$running_var,
  c = 0,  # Cutoff at border
  kernel = "triangular",
  p = 1,  # Local linear
  bwselect = "mserd"  # MSE-optimal bandwidth
)

print(summary(main_rd))

# Store key results
main_results <- tibble(
  outcome = "Fatality Probability",
  estimate = main_rd$coef[1],
  se = main_rd$se[1],
  ci_lower = main_rd$ci[1, 1],
  ci_upper = main_rd$ci[1, 2],
  bandwidth = main_rd$bws[1, 1],
  n_left = main_rd$N[1],
  n_right = main_rd$N[2],
  n_eff = main_rd$N_h[1] + main_rd$N_h[2],
  p_value = 2 * pnorm(-abs(main_rd$coef[1] / main_rd$se[1]))
)

message("\n--- Main Result ---")
message("RD Estimate (Primary - Secondary): ", round(main_results$estimate, 4))
message("Standard Error: ", round(main_results$se, 4))
message("95% CI: [", round(main_results$ci_lower, 4), ", ", round(main_results$ci_upper, 4), "]")
message("Bandwidth: ", round(main_results$bandwidth, 1), " km")
message("Effective N: ", main_results$n_eff)

# =============================================================================
# 2. Alternative Outcomes
# =============================================================================

message("\n=== Alternative Outcomes ===")

# Outcome 2: Number of fatalities per crash
rd_fatals <- rdrobust(
  y = analysis_df$fatals_per_crash,
  x = analysis_df$running_var,
  c = 0,
  kernel = "triangular",
  p = 1,
  bwselect = "mserd"
)

# Outcome 3: Ejection indicator
rd_ejection <- rdrobust(
  y = analysis_df$any_ejection,
  x = analysis_df$running_var,
  c = 0,
  kernel = "triangular",
  p = 1,
  bwselect = "mserd"
)

# Outcome 4: Pedestrian/cyclist deaths (PLACEBO - should be null)
rd_nonoccupant <- rdrobust(
  y = analysis_df$nonoccupant_deaths,
  x = analysis_df$running_var,
  c = 0,
  kernel = "triangular",
  p = 1,
  bwselect = "mserd"
)

# Combine results
all_rd_results <- bind_rows(
  main_results,
  tibble(
    outcome = "Fatalities per Crash",
    estimate = rd_fatals$coef[1],
    se = rd_fatals$se[1],
    ci_lower = rd_fatals$ci[1, 1],
    ci_upper = rd_fatals$ci[1, 2],
    bandwidth = rd_fatals$bws[1, 1],
    n_left = rd_fatals$N[1],
    n_right = rd_fatals$N[2],
    n_eff = rd_fatals$N_h[1] + rd_fatals$N_h[2],
    p_value = 2 * pnorm(-abs(rd_fatals$coef[1] / rd_fatals$se[1]))
  ),
  tibble(
    outcome = "Ejection (Any)",
    estimate = rd_ejection$coef[1],
    se = rd_ejection$se[1],
    ci_lower = rd_ejection$ci[1, 1],
    ci_upper = rd_ejection$ci[1, 2],
    bandwidth = rd_ejection$bws[1, 1],
    n_left = rd_ejection$N[1],
    n_right = rd_ejection$N[2],
    n_eff = rd_ejection$N_h[1] + rd_ejection$N_h[2],
    p_value = 2 * pnorm(-abs(rd_ejection$coef[1] / rd_ejection$se[1]))
  ),
  tibble(
    outcome = "Pedestrian/Cyclist Deaths (Placebo)",
    estimate = rd_nonoccupant$coef[1],
    se = rd_nonoccupant$se[1],
    ci_lower = rd_nonoccupant$ci[1, 1],
    ci_upper = rd_nonoccupant$ci[1, 2],
    bandwidth = rd_nonoccupant$bws[1, 1],
    n_left = rd_nonoccupant$N[1],
    n_right = rd_nonoccupant$N[2],
    n_eff = rd_nonoccupant$N_h[1] + rd_nonoccupant$N_h[2],
    p_value = 2 * pnorm(-abs(rd_nonoccupant$coef[1] / rd_nonoccupant$se[1]))
  )
)

print(all_rd_results %>% select(outcome, estimate, se, p_value, bandwidth, n_eff))

# =============================================================================
# 3. Heterogeneity Analysis
# =============================================================================

message("\n=== Heterogeneity Analysis ===")

# Helper function to safely run RDD on subgroups
safe_rdrobust <- function(data_subset, min_n = 1000) {
  n <- sum(!is.na(data_subset$fatality_prob) & !is.na(data_subset$running_var))
  if (n < min_n) {
    message("  Skipping: only ", n, " observations (need ", min_n, ")")
    return(list(coef = c(NA), se = c(NA), N_h = c(0, 0), valid = FALSE))
  }
  tryCatch({
    rd <- rdrobust(
      y = data_subset$fatality_prob,
      x = data_subset$running_var,
      c = 0, kernel = "triangular", p = 1, bwselect = "mserd"
    )
    rd$valid <- TRUE
    rd
  }, error = function(e) {
    message("  RDD failed: ", e$message)
    list(coef = c(NA), se = c(NA), N_h = c(0, 0), valid = FALSE)
  })
}

# By time: Night vs Day (these have good sample sizes)
message("Night crashes...")
rd_night <- safe_rdrobust(analysis_df %>% filter(night_crash == 1))

message("Day crashes...")
rd_day <- safe_rdrobust(analysis_df %>% filter(night_crash == 0))

if (rd_night$valid) {
  message("Night crashes: estimate = ", round(rd_night$coef[1], 4),
          " (SE = ", round(rd_night$se[1], 4), ")")
}
if (rd_day$valid) {
  message("Day crashes:   estimate = ", round(rd_day$coef[1], 4),
          " (SE = ", round(rd_day$se[1], 4), ")")
}

# By crash type: Single vs Multi-vehicle (many NAs, but still try)
message("Single-vehicle crashes...")
rd_single <- safe_rdrobust(analysis_df %>% filter(single_vehicle == 1), min_n = 5000)

message("Multi-vehicle crashes...")
rd_multi <- safe_rdrobust(analysis_df %>% filter(multi_vehicle == 1), min_n = 5000)

if (rd_single$valid) {
  message("Single-vehicle crashes: estimate = ", round(rd_single$coef[1], 4),
          " (SE = ", round(rd_single$se[1], 4), ")")
}
if (rd_multi$valid) {
  message("Multi-vehicle crashes:  estimate = ", round(rd_multi$coef[1], 4),
          " (SE = ", round(rd_multi$se[1], 4), ")")
}

# Compile heterogeneity results - only include valid estimates with reasonable SEs
heterogeneity_results <- tribble(
  ~subgroup, ~estimate, ~se, ~n_eff,
  "Night (8pm-5am)", rd_night$coef[1], rd_night$se[1], rd_night$N_h[1] + rd_night$N_h[2],
  "Day (5am-8pm)", rd_day$coef[1], rd_day$se[1], rd_day$N_h[1] + rd_day$N_h[2]
) %>%
  filter(!is.na(estimate), se > 1e-10)  # Only keep results with valid SEs

# Note: Single/multi-vehicle results excluded due to 59% missing data leading to
# unreliable estimates (effective N in bandwidth < 500, SE essentially zero)

# =============================================================================
# 4. Year-by-Year Analysis (Dynamic Effects)
# =============================================================================

message("\n=== Year-by-Year RDD ===")

year_results <- map_dfr(unique(analysis_df$year), function(yr) {
  df_year <- analysis_df %>% filter(year == yr)

  if (nrow(df_year) > 100) {
    tryCatch({
      rd_yr <- rdrobust(
        y = df_year$fatality_prob,
        x = df_year$running_var,
        c = 0, kernel = "triangular", p = 1, bwselect = "mserd"
      )
      tibble(
        year = yr,
        estimate = rd_yr$coef[1],
        se = rd_yr$se[1],
        n_eff = rd_yr$N_h[1] + rd_yr$N_h[2]
      )
    }, error = function(e) {
      tibble(year = yr, estimate = NA, se = NA, n_eff = NA)
    })
  } else {
    tibble(year = yr, estimate = NA, se = NA, n_eff = NA)
  }
})

print(year_results)

# =============================================================================
# 5. Validity Tests
# =============================================================================

message("\n=== Validity Tests ===")

# McCrary density test
message("Running McCrary density test...")
density_test <- rddensity(analysis_df$running_var, c = 0)
density_pval <- density_test$test$p_jk
message("McCrary test p-value: ", round(density_pval, 4))

# Covariate balance (if covariates available)
# Test whether pre-determined characteristics are smooth at the border

# =============================================================================
# 6. Save Results
# =============================================================================

results_list <- list(
  main_results = all_rd_results,
  heterogeneity = heterogeneity_results,
  year_by_year = year_results,
  density_test_pval = density_pval,
  main_rd_object = main_rd
)

saveRDS(results_list, file.path(dir_data, "rd_results.rds"))

message("\n✓ Main analysis complete. Results saved.")
