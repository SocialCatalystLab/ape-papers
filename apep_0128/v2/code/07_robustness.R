# ==============================================================================
# 07_robustness.R
# All Robustness Checks for Sub-National DiD
# ==============================================================================

source("00_packages.R")

cat("=== 07_robustness.R: Robustness Checks ===\n")

panel_prices <- readRDS("../data/processed/panel_prices.rds")
panel_permits <- readRDS("../data/processed/panel_permits.rds")
province_lookup <- readRDS("../data/processed/province_lookup.rds")

# Add derived columns
panel_prices <- panel_prices %>%
  left_join(province_lookup, by = "muni_code")

panel_permits <- panel_permits %>%
  left_join(province_lookup, by = "muni_code") %>%
  mutate(
    permits = dwellings_permitted,
    permits_rate = dwellings_permitted / pmax(woningvoorraad / 1000, 0.01)
  )

# Helper: extract coef, se, p from coeftable
get_est <- function(model) {
  ct <- coeftable(model)
  list(coef = ct[1,1], se = ct[1,2], pval = ct[1,4])
}

# ------------------------------------------------------------------------------
# 1. Alternative Treatment Definitions (Distance-Based)
# ------------------------------------------------------------------------------
cat("\n--- 1. Alternative Treatment: Distance-Based Cutoffs ---\n")

for (cutoff in c(5, 10, 15)) {
  panel_prices[[paste0("near_", cutoff, "km")]] <- panel_prices$dist_n2000_km < cutoff
}

rob_5km <- feols(log_price ~ near_5km:post | muni_code + year,
                 data = panel_prices, cluster = ~muni_code)
rob_10km <- feols(log_price ~ near_10km:post | muni_code + year,
                  data = panel_prices, cluster = ~muni_code)
rob_15km <- feols(log_price ~ near_15km:post | muni_code + year,
                  data = panel_prices, cluster = ~muni_code)

cat("5km binary:\n"); print(coeftable(rob_5km))
cat("10km binary:\n"); print(coeftable(rob_10km))
cat("15km binary:\n"); print(coeftable(rob_15km))

# Continuous distance (inverse distance)
rob_dist <- feols(log_price ~ I(1/pmax(dist_n2000_km, 0.1)):post | muni_code + year,
                  data = panel_prices, cluster = ~muni_code)
cat("Inverse distance:\n"); print(coeftable(rob_dist))

# ------------------------------------------------------------------------------
# 2. Pre-COVID vs Full Sample
# ------------------------------------------------------------------------------
cat("\n--- 2. Pre-COVID vs Full Sample ---\n")

rob_precovid <- feols(log_price ~ n2000_share:post | muni_code + year,
                      data = filter(panel_prices, year <= 2019),
                      cluster = ~muni_code)

rob_full <- feols(log_price ~ n2000_share:post | muni_code + year,
                  data = panel_prices, cluster = ~muni_code)

e_pre <- get_est(rob_precovid)
e_full <- get_est(rob_full)
cat(sprintf("Pre-COVID ATT: %.4f (SE: %.4f)\n", e_pre$coef, e_pre$se))
cat(sprintf("Full sample ATT: %.4f (SE: %.4f)\n", e_full$coef, e_full$se))

# ------------------------------------------------------------------------------
# 3. Excluding Randstad (Major Urban Area)
# ------------------------------------------------------------------------------
cat("\n--- 3. Randstad Heterogeneity ---\n")

# Randstad provinces: Noord-Holland, Zuid-Holland, Utrecht, Flevoland
randstad_provinces <- c("Noord-Holland", "Zuid-Holland", "Utrecht", "Flevoland")

rob_no_randstad <- feols(log_price ~ n2000_share:post | muni_code + year,
                         data = filter(panel_prices, !province %in% randstad_provinces),
                         cluster = ~muni_code)

rob_randstad_only <- feols(log_price ~ n2000_share:post | muni_code + year,
                           data = filter(panel_prices, province %in% randstad_provinces),
                           cluster = ~muni_code)

e_nr <- get_est(rob_no_randstad)
e_ro <- get_est(rob_randstad_only)
cat(sprintf("Excluding Randstad: %.4f (SE: %.4f, N=%d munis)\n",
            e_nr$coef, e_nr$se,
            n_distinct(filter(panel_prices, !province %in% randstad_provinces)$muni_code)))
cat(sprintf("Randstad only: %.4f (SE: %.4f, N=%d munis)\n",
            e_ro$coef, e_ro$se,
            n_distinct(filter(panel_prices, province %in% randstad_provinces)$muni_code)))

# ------------------------------------------------------------------------------
# 4. Different Pre-Treatment Windows
# ------------------------------------------------------------------------------
cat("\n--- 4. Different Pre-Treatment Windows ---\n")

window_results <- list()
for (start_yr in c(2012, 2014, 2016)) {
  rob_window <- feols(log_price ~ n2000_share:post | muni_code + year,
                      data = filter(panel_prices, year >= start_yr),
                      cluster = ~muni_code)
  window_results[[as.character(start_yr)]] <- coeftable(rob_window)
  e_w <- get_est(rob_window)
  cat(sprintf("Start year %d: ATT = %.4f (SE = %.4f, p = %.4f)\n",
              start_yr, e_w$coef, e_w$se, e_w$pval))
}

# ------------------------------------------------------------------------------
# 5. Placebo Treatment Dates
# ------------------------------------------------------------------------------
cat("\n--- 5. Placebo Treatment Dates ---\n")

placebo_results <- list()
for (placebo_year in c(2014, 2015, 2016, 2017)) {
  panel_placebo <- panel_prices %>%
    filter(year <= 2018) %>%
    mutate(post_placebo = as.integer(year >= placebo_year))

  rob_placebo <- feols(log_price ~ n2000_share:post_placebo | muni_code + year,
                       data = panel_placebo, cluster = ~muni_code)
  e_p <- get_est(rob_placebo)
  placebo_results[[as.character(placebo_year)]] <- list(
    coef = e_p$coef,
    se = e_p$se,
    pval = e_p$pval
  )
  cat(sprintf("Placebo %d: ATT = %.4f (SE = %.4f, p = %.3f)\n",
              placebo_year, e_p$coef, e_p$se, e_p$pval))
}

# Good outcome: placebo coefficients should be small and insignificant
cat("\nPre-trend check: placebos should be insignificant (p > 0.05).\n")
n_sig <- sum(sapply(placebo_results, function(x) x$pval < 0.05))
cat(sprintf("Significant placebos: %d of %d\n", n_sig, length(placebo_results)))

# ------------------------------------------------------------------------------
# 6. Province-Level Clustering
# ------------------------------------------------------------------------------
cat("\n--- 6. Province-Level Clustering ---\n")

rob_prov_cluster <- feols(log_price ~ n2000_share:post | muni_code + year,
                          data = panel_prices, cluster = ~province)
cat("Province-level clustering:\n")
print(coeftable(rob_prov_cluster))

# Also two-way clustering: municipality + year
rob_twoway <- feols(log_price ~ n2000_share:post | muni_code + year,
                    data = panel_prices, cluster = ~muni_code + year)
cat("Two-way clustering (municipality + year):\n")
print(coeftable(rob_twoway))

# ------------------------------------------------------------------------------
# 7. Permits Robustness (First Stage)
# ------------------------------------------------------------------------------
cat("\n--- 7. Permits Robustness ---\n")

# Pre-COVID permits (filter by year since yq is character)
rob_permits_precovid <- feols(permits ~ n2000_share:post | muni_code + yq,
                              data = filter(panel_permits, year <= 2019),
                              cluster = ~muni_code)

# Permits with province x quarter FE
rob_permits_prov <- feols(permits ~ n2000_share:post | muni_code + yq + province^yq,
                          data = panel_permits, cluster = ~muni_code)

# Permits rate
rob_permits_rate <- feols(permits_rate ~ n2000_share:post | muni_code + yq,
                          data = panel_permits, cluster = ~muni_code)

e_pp <- get_est(rob_permits_precovid)
e_pprov <- get_est(rob_permits_prov)
e_pr <- get_est(rob_permits_rate)
cat(sprintf("Permits (pre-COVID): %.4f (SE: %.4f)\n", e_pp$coef, e_pp$se))
cat(sprintf("Permits (province x quarter FE): %.4f (SE: %.4f)\n", e_pprov$coef, e_pprov$se))
cat(sprintf("Permits rate: %.4f (SE: %.4f)\n", e_pr$coef, e_pr$se))

# ------------------------------------------------------------------------------
# 8. Save All Robustness Results
# ------------------------------------------------------------------------------
cat("\n--- Saving robustness results ---\n")

saveRDS(list(
  # Distance-based treatment
  rob_5km = rob_5km, rob_10km = rob_10km, rob_15km = rob_15km,
  rob_dist = rob_dist,
  # COVID sensitivity
  rob_precovid = rob_precovid, rob_full = rob_full,
  # Randstad
  rob_no_randstad = rob_no_randstad, rob_randstad_only = rob_randstad_only,
  # Windows
  window_results = window_results,
  # Placebos
  placebo_results = placebo_results,
  # Clustering
  rob_prov_cluster = rob_prov_cluster, rob_twoway = rob_twoway,
  # Permits
  rob_permits_precovid = rob_permits_precovid,
  rob_permits_prov = rob_permits_prov,
  rob_permits_rate = rob_permits_rate
), "../data/processed/robustness_results.rds")

cat("\n=== Robustness checks complete ===\n")
