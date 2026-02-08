# ==============================================================================
# 04_main_analysis.R
# Housing Price DiD — Primary Results
# Dutch Nitrogen Crisis: Effect on Municipality-Level House Prices
# ==============================================================================

source("00_packages.R")

cat("=== 04_main_analysis.R: Housing Price DiD (Primary Results) ===\n")

panel_prices <- readRDS("../data/processed/panel_prices.rds")
province_lookup <- readRDS("../data/processed/province_lookup.rds")

# Add province and population columns
panel_prices <- panel_prices %>%
  left_join(province_lookup, by = "muni_code") %>%
  mutate(population = aantalInwoners)

cat(sprintf("Panel prices: %d obs, %d municipalities, %d years\n",
            nrow(panel_prices),
            n_distinct(panel_prices$muni_code),
            n_distinct(panel_prices$year)))
cat(sprintf("Year range: %d-%d\n", min(panel_prices$year), max(panel_prices$year)))
cat(sprintf("N2000 share range: [%.3f, %.3f]\n",
            min(panel_prices$n2000_share), max(panel_prices$n2000_share)))

# ------------------------------------------------------------------------------
# 1. Main DiD Specifications
# ------------------------------------------------------------------------------
cat("\n--- 1. Main DiD Specifications ---\n")

# (1) Basic: log_price ~ n2000_share x post | muni + year FE
p1 <- feols(log_price ~ n2000_share:post | muni_code + year,
            data = panel_prices, cluster = ~muni_code)

# (2) With population control
p2 <- feols(log_price ~ n2000_share:post + log(population) | muni_code + year,
            data = panel_prices, cluster = ~muni_code)

# (3) With province x year FE (most demanding -- absorbs province-level shocks)
p3 <- feols(log_price ~ n2000_share:post | muni_code + province^year,
            data = panel_prices, cluster = ~muni_code)

# (4) Pre-COVID only (2012-2019)
p4 <- feols(log_price ~ n2000_share:post | muni_code + year,
            data = filter(panel_prices, year <= 2019),
            cluster = ~muni_code)

# (5) Full sample (all years available)
p5 <- feols(log_price ~ n2000_share:post | muni_code + year,
            data = panel_prices, cluster = ~muni_code)

# (6) Province-level clustering (more conservative -- 12 provinces)
p6 <- feols(log_price ~ n2000_share:post | muni_code + year,
            data = panel_prices, cluster = ~province)

cat("\np1 (basic DiD):\n")
print(summary(p1))
cat("\np2 (population control):\n")
print(summary(p2))
cat("\np3 (province x year FE):\n")
print(summary(p3))
cat("\np4 (pre-COVID only):\n")
print(summary(p4))
cat("\np5 (full sample):\n")
print(summary(p5))
cat("\np6 (province-level clustering):\n")
print(summary(p6))

# ------------------------------------------------------------------------------
# 2. Effect Magnitudes
# ------------------------------------------------------------------------------
cat("\n--- 2. Effect Magnitudes ---\n")

# For continuous treatment, the coefficient represents the effect of a
# one-unit increase in N2000 share. Since N2000 share is in [0,1],
# the coefficient gives the full-dose effect.
# For a more interpretable IQR effect:
iqr_n2000 <- IQR(panel_prices$n2000_share)
mean_n2000_high <- mean(panel_prices$n2000_share[panel_prices$n2000_tertile == 3])
mean_n2000_low <- mean(panel_prices$n2000_share[panel_prices$n2000_tertile == 1])

cat(sprintf("N2000 share IQR: %.3f\n", iqr_n2000))
cat(sprintf("Mean N2000 (tertile 3): %.3f\n", mean_n2000_high))
cat(sprintf("Mean N2000 (tertile 1): %.3f\n", mean_n2000_low))
cat(sprintf("IQR effect (p1): %.4f log points = %.2f%%\n",
            coef(p1)[1] * iqr_n2000, 100 * (exp(coef(p1)[1] * iqr_n2000) - 1)))
cat(sprintf("High vs Low tertile effect (p1): %.4f log points = %.2f%%\n",
            coef(p1)[1] * (mean_n2000_high - mean_n2000_low),
            100 * (exp(coef(p1)[1] * (mean_n2000_high - mean_n2000_low)) - 1)))

# ------------------------------------------------------------------------------
# 3. Dose-Response
# ------------------------------------------------------------------------------
cat("\n--- 3. Dose-Response (Quartile Dummies) ---\n")

# Create quartile dummies for treatment intensity
panel_prices <- panel_prices %>%
  mutate(n2000_q = ntile(n2000_share, 4))

p_dose <- feols(log_price ~ i(n2000_q, post, ref = 1) | muni_code + year,
                data = panel_prices, cluster = ~muni_code)

cat("\nDose-response (quartile dummies, ref = Q1):\n")
print(summary(p_dose))

# ------------------------------------------------------------------------------
# 4. Binary Treatment (Tertile-based)
# ------------------------------------------------------------------------------
cat("\n--- 4. Binary Treatment ---\n")

panel_prices <- panel_prices %>%
  mutate(high_n2000 = as.integer(n2000_tertile == 3))

p_binary <- feols(log_price ~ high_n2000:post | muni_code + year,
                  data = panel_prices, cluster = ~muni_code)

cat("\nBinary treatment (high N2000 tertile):\n")
print(summary(p_binary))

# ------------------------------------------------------------------------------
# 5. Save Results
# ------------------------------------------------------------------------------
cat("\n--- Saving main results ---\n")

saveRDS(list(
  p1 = p1, p2 = p2, p3 = p3, p4 = p4, p5 = p5, p6 = p6,
  p_dose = p_dose, p_binary = p_binary,
  iqr_n2000 = iqr_n2000,
  mean_n2000_high = mean_n2000_high,
  mean_n2000_low = mean_n2000_low
), "../data/processed/main_results.rds")

cat("\n=== Main analysis complete ===\n")
p1_ct <- coeftable(p1)
p3_ct <- coeftable(p3)
cat(sprintf("Key result (p1): coef = %.4f, se = %.4f, p = %.4f\n",
            p1_ct[1, 1], p1_ct[1, 2], p1_ct[1, 4]))
cat(sprintf("Key result (p3, province x year): coef = %.4f, se = %.4f, p = %.4f\n",
            p3_ct[1, 1], p3_ct[1, 2], p3_ct[1, 4]))
