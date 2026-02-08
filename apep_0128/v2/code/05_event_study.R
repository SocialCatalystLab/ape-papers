# ==============================================================================
# 05_event_study.R
# Event Studies: Building Permits (Quarterly) + Housing Prices (Annual)
# Tests parallel trends and visualizes treatment dynamics
# ==============================================================================

source("00_packages.R")

cat("=== 05_event_study.R: Event Studies (Permits + Prices) ===\n")

panel_prices <- readRDS("../data/processed/panel_prices.rds")
panel_permits <- readRDS("../data/processed/panel_permits.rds")
province_lookup <- readRDS("../data/processed/province_lookup.rds")

# Add derived columns
panel_prices <- panel_prices %>%
  left_join(province_lookup, by = "muni_code") %>%
  mutate(event_time = rel_year)

panel_permits <- panel_permits %>%
  left_join(province_lookup, by = "muni_code") %>%
  mutate(
    permits = dwellings_permitted,
    event_time_q = (year - 2019) * 4 + (qtr - 2)
  )

# ------------------------------------------------------------------------------
# 1. Annual Price Event Study (Continuous Treatment)
# ------------------------------------------------------------------------------
cat("\n--- 1. Annual Price Event Study ---\n")

# Reference: event_time == -1 (year before treatment, i.e. 2018)
es_price <- feols(log_price ~ i(event_time, n2000_share, ref = -1) | muni_code + year,
                  data = panel_prices, cluster = ~muni_code)

cat("Price event study (continuous treatment):\n")
print(summary(es_price))

# Pre-trend test: joint F-test of pre-treatment coefficients
pre_coefs <- grep("event_time::-", names(coef(es_price)), value = TRUE)
if (length(pre_coefs) > 1) {
  pre_test <- tryCatch({
    wald(es_price, keep = pre_coefs)
  }, error = function(e) {
    cat("Wald test error:", conditionMessage(e), "\n")
    NULL
  })
  if (!is.null(pre_test)) {
    cat("\nPre-trend joint F-test:\n")
    print(pre_test)
  }
}

# ------------------------------------------------------------------------------
# 2. Quarterly Permit Event Study (Continuous Treatment)
# ------------------------------------------------------------------------------
cat("\n--- 2. Quarterly Permit Event Study ---\n")

# Reference: event_time_q == -1 (last pre-treatment quarter, 2019Q1)
es_permits <- feols(permits ~ i(event_time_q, n2000_share, ref = -1) | muni_code + yq,
                    data = panel_permits, cluster = ~muni_code)

cat("Permit event study (continuous treatment):\n")
print(summary(es_permits))

# Pre-trend test for permits
pre_coefs_p <- grep("event_time_q::-", names(coef(es_permits)), value = TRUE)
if (length(pre_coefs_p) > 1) {
  pre_test_p <- tryCatch({
    wald(es_permits, keep = pre_coefs_p)
  }, error = function(e) {
    cat("Wald test error:", conditionMessage(e), "\n")
    NULL
  })
  if (!is.null(pre_test_p)) {
    cat("\nPre-trend joint F-test (permits):\n")
    print(pre_test_p)
  }
}

# ------------------------------------------------------------------------------
# 3. Binary Treatment Event Studies (for cleaner figures)
# ------------------------------------------------------------------------------
cat("\n--- 3. Binary Treatment Event Studies ---\n")

# High N2000 (tertile 3) vs Low (tertile 1)
panel_binary <- panel_prices %>% filter(n2000_tertile %in% c(1, 3))
es_binary <- feols(log_price ~ i(event_time, n2000_tertile == 3, ref = -1) | muni_code + year,
                   data = panel_binary, cluster = ~muni_code)

cat("\nBinary price event study (tertile 3 vs 1):\n")
print(summary(es_binary))

panel_binary_p <- panel_permits %>% filter(n2000_tertile %in% c(1, 3))
es_binary_p <- feols(permits ~ i(event_time_q, n2000_tertile == 3, ref = -1) | muni_code + yq,
                     data = panel_binary_p, cluster = ~muni_code)

cat("\nBinary permit event study (tertile 3 vs 1):\n")
print(summary(es_binary_p))

# ------------------------------------------------------------------------------
# 4. Province x Time FE Event Study (Most Demanding)
# ------------------------------------------------------------------------------
cat("\n--- 4. Province x Year FE Event Study ---\n")

es_price_prov <- feols(log_price ~ i(event_time, n2000_share, ref = -1) | muni_code + province^year,
                       data = panel_prices, cluster = ~muni_code)

cat("Price event study with province x year FE:\n")
print(summary(es_price_prov))

# ------------------------------------------------------------------------------
# 5. Save Results
# ------------------------------------------------------------------------------
cat("\n--- Saving event study results ---\n")

saveRDS(list(
  es_price = es_price,
  es_permits = es_permits,
  es_binary = es_binary,
  es_binary_p = es_binary_p,
  es_price_prov = es_price_prov
), "../data/processed/event_study_results.rds")

cat("\n=== Event study analysis complete ===\n")
