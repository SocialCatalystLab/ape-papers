# ==============================================================================
# 08_spatial_rdd.R
# Spatial RDD at Natura 2000 Boundary
# Running variable: distance to nearest N2000 site
# ==============================================================================

source("00_packages.R")

cat("=== 08_spatial_rdd.R: Spatial RDD at Natura 2000 Boundary ===\n")

panel_prices <- readRDS("../data/processed/panel_prices.rds")
province_lookup <- readRDS("../data/processed/province_lookup.rds")
panel_prices <- panel_prices %>%
  left_join(province_lookup, by = "muni_code")

# ------------------------------------------------------------------------------
# 1. Prepare RDD Data
# ------------------------------------------------------------------------------
cat("\n--- 1. Preparing RDD Data ---\n")

# Running variable: signed distance to N2000 boundary
# Negative = municipality overlaps with N2000 (n2000_share > 0)
# Positive = municipality is outside N2000
# Cutoff at 0: municipalities with any N2000 overlap
rdd_data <- panel_prices %>%
  mutate(
    signed_dist = ifelse(n2000_share > 0, -dist_n2000_km, dist_n2000_km),
    # Compute pre-treatment mean for each municipality
    pre_mean = ave(log_price * (!post), muni_code, FUN = function(x) {
      vals <- x[x != 0]
      if (length(vals) > 0) mean(vals) else NA
    })
  ) %>%
  filter(year >= 2019) %>%
  group_by(muni_code) %>%
  summarize(
    mean_log_price_post = mean(log_price, na.rm = TRUE),
    pre_mean = first(pre_mean),
    mean_price_change = mean_log_price_post - pre_mean,
    signed_dist = first(signed_dist),
    n2000_share = first(n2000_share),
    province = first(province),
    .groups = "drop"
  ) %>%
  filter(!is.na(mean_price_change), !is.na(signed_dist))

cat(sprintf("RDD observations: %d municipalities\n", nrow(rdd_data)))
cat(sprintf("Inside/overlapping N2000 (signed_dist <= 0): %d\n", sum(rdd_data$signed_dist <= 0)))
cat(sprintf("Outside N2000 (signed_dist > 0): %d\n", sum(rdd_data$signed_dist > 0)))
cat(sprintf("Signed distance range: [%.1f, %.1f] km\n",
            min(rdd_data$signed_dist), max(rdd_data$signed_dist)))

# ------------------------------------------------------------------------------
# 2. Run RDD (rdrobust)
# ------------------------------------------------------------------------------
cat("\n--- 2. RDD Estimation ---\n")

tryCatch({
  rdd_result <- rdrobust(
    y = rdd_data$mean_price_change,
    x = rdd_data$signed_dist,
    c = 0,
    kernel = "triangular",
    bwselect = "mserd"
  )

  cat("\nRDD Results (MSE-optimal bandwidth):\n")
  print(summary(rdd_result))

  # Bandwidth diagnostics
  bw <- rdd_result$bws[1, 1]
  n_in_bw <- sum(abs(rdd_data$signed_dist) <= bw)
  n_left <- sum(rdd_data$signed_dist >= -bw & rdd_data$signed_dist < 0)
  n_right <- sum(rdd_data$signed_dist > 0 & rdd_data$signed_dist <= bw)

  cat(sprintf("\nOptimal bandwidth: %.1f km\n", bw))
  cat(sprintf("Observations in bandwidth: %d (left=%d, right=%d)\n", n_in_bw, n_left, n_right))

  if (n_in_bw < 50) {
    cat("WARNING: Fewer than 50 observations in bandwidth. RDD may be underpowered.\n")
  }

  # Alternative bandwidths
  cat("\n--- Alternative Bandwidths ---\n")
  for (bw_mult in c(0.5, 0.75, 1.25, 1.5)) {
    alt_bw <- bw * bw_mult
    tryCatch({
      rdd_alt <- rdrobust(
        y = rdd_data$mean_price_change,
        x = rdd_data$signed_dist,
        c = 0,
        kernel = "triangular",
        h = alt_bw
      )
      cat(sprintf("  bw = %.1f km (%.0f%% of optimal): coef = %.4f, p = %.3f\n",
                  alt_bw, 100 * bw_mult, rdd_alt$coef[1], rdd_alt$pv[1]))
    }, error = function(e) {
      cat(sprintf("  bw = %.1f km: failed (%s)\n", alt_bw, conditionMessage(e)))
    })
  }

  # Density test (McCrary / Cattaneo et al.)
  cat("\n--- Density Test ---\n")
  tryCatch({
    density_test <- rddensity::rddensity(rdd_data$signed_dist, c = 0)
    cat(sprintf("Density test p-value: %.3f\n", density_test$test$p_jk))
    if (density_test$test$p_jk < 0.05) {
      cat("WARNING: Significant bunching at cutoff — potential manipulation.\n")
    } else {
      cat("No evidence of manipulation at the cutoff.\n")
    }
  }, error = function(e) {
    cat(sprintf("Density test failed: %s\n", conditionMessage(e)))
    cat("Installing rddensity...\n")
    tryCatch({
      install.packages("rddensity", repos = "https://cloud.r-project.org", quiet = TRUE)
      library(rddensity)
      density_test <- rddensity(rdd_data$signed_dist, c = 0)
      cat(sprintf("Density test p-value: %.3f\n", density_test$test$p_jk))
    }, error = function(e2) {
      cat(sprintf("Density test unavailable: %s\n", conditionMessage(e2)))
    })
  })

  saveRDS(list(
    rdd_result = rdd_result,
    rdd_data = rdd_data,
    bw = bw,
    n_in_bw = n_in_bw,
    n_left = n_left,
    n_right = n_right
  ), "../data/processed/rdd_results.rds")

}, error = function(e) {
  cat("RDD error:", conditionMessage(e), "\n")
  cat("Spatial RDD infeasible — insufficient density near N2000 boundaries.\n")
  saveRDS(list(error = conditionMessage(e), rdd_data = rdd_data),
          "../data/processed/rdd_results.rds")
})

# ------------------------------------------------------------------------------
# 3. RDD with Covariates
# ------------------------------------------------------------------------------
cat("\n--- 3. RDD with Province Covariates ---\n")

tryCatch({
  # Create province dummies for covariate-adjusted RDD
  prov_dummies <- model.matrix(~ province - 1, data = rdd_data)

  rdd_cov <- rdrobust(
    y = rdd_data$mean_price_change,
    x = rdd_data$signed_dist,
    c = 0,
    kernel = "triangular",
    bwselect = "mserd",
    covs = prov_dummies
  )

  cat("RDD with province covariates:\n")
  print(summary(rdd_cov))

}, error = function(e) {
  cat(sprintf("Covariate-adjusted RDD failed: %s\n", conditionMessage(e)))
})

cat("\n=== Spatial RDD analysis complete ===\n")
