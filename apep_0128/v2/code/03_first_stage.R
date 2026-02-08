# ==============================================================================
# 03_first_stage.R
# Building Permits DiD — Mechanism Test
# Dutch Nitrogen Crisis: Court Ruling -> Fewer Permits near N2000 -> Less Construction -> Higher Prices
# ==============================================================================

source("00_packages.R")

cat("=== 03_first_stage.R: Building Permits DiD (Mechanism Test) ===\n")

panel_permits <- readRDS("../data/processed/panel_permits.rds")
province_lookup <- readRDS("../data/processed/province_lookup.rds")

# Create missing columns expected by analysis scripts
panel_permits <- panel_permits %>%
  left_join(province_lookup, by = "muni_code") %>%
  mutate(
    permits = dwellings_permitted,
    permits_rate = dwellings_permitted / pmax(woningvoorraad / 1000, 0.01),
    # Create event_time_q: quarters relative to 2019Q2 (treatment)
    event_time_q = (year - 2019) * 4 + (qtr - 2)
  )

cat(sprintf("Panel permits: %d obs, %d municipalities, %d quarters\n",
            nrow(panel_permits),
            n_distinct(panel_permits$muni_code),
            n_distinct(panel_permits$yq)))
cat(sprintf("N2000 share range: [%.3f, %.3f]\n",
            min(panel_permits$n2000_share), max(panel_permits$n2000_share)))
cat(sprintf("Post-treatment obs: %d (%.1f%%)\n",
            sum(panel_permits$post), 100 * mean(panel_permits$post)))

# ------------------------------------------------------------------------------
# 1. Basic DiD: Permits ~ N2000_share x Post
# ------------------------------------------------------------------------------
cat("\n--- 1. Continuous Treatment DiD ---\n")

# (1) Basic: municipality + quarter FE
m1 <- feols(permits ~ n2000_share:post | muni_code + yq,
            data = panel_permits, cluster = ~muni_code)

# (2) With province x quarter FE (absorbs regional trends)
m2 <- feols(permits ~ n2000_share:post | muni_code + yq + province^yq,
            data = panel_permits, cluster = ~muni_code)

# (3) Permits rate (per 1000 dwellings) to normalize by municipality size
m3 <- feols(permits_rate ~ n2000_share:post | muni_code + yq,
            data = panel_permits, cluster = ~muni_code)

# (4) Pre-COVID only (through 2019Q4)
# yq is character like "2019Q4", so filter by year
m4 <- feols(permits ~ n2000_share:post | muni_code + yq,
            data = filter(panel_permits, year <= 2019),
            cluster = ~muni_code)

cat("\nm1 (basic DiD):\n")
print(summary(m1))
cat("\nm2 (province x quarter FE):\n")
print(summary(m2))
cat("\nm3 (permits rate):\n")
print(summary(m3))
cat("\nm4 (pre-COVID only):\n")
print(summary(m4))

# ------------------------------------------------------------------------------
# 2. Event Study: Quarterly Dynamics
# ------------------------------------------------------------------------------
cat("\n--- 2. Quarterly Event Study ---\n")

# Reference period: last pre-treatment quarter (event_time_q == -1)
m_es <- feols(permits ~ i(event_time_q, n2000_share, ref = -1) | muni_code + yq,
              data = panel_permits, cluster = ~muni_code)

cat("\nQuarterly event study:\n")
print(summary(m_es))

# ------------------------------------------------------------------------------
# 3. Binary Treatment Version (High vs Low N2000 exposure)
# ------------------------------------------------------------------------------
cat("\n--- 3. Binary Treatment (Tertile 3 vs Rest) ---\n")

# Create binary indicator for high-N2000 municipalities
panel_permits <- panel_permits %>%
  mutate(high_n2000 = as.integer(n2000_tertile == 3))

m_binary <- feols(permits ~ high_n2000:post | muni_code + yq,
                  data = panel_permits, cluster = ~muni_code)

cat("\nBinary treatment (high N2000 tertile):\n")
print(summary(m_binary))

# Binary event study
m_binary_es <- feols(permits ~ i(event_time_q, high_n2000, ref = -1) | muni_code + yq,
                     data = panel_permits, cluster = ~muni_code)

# ------------------------------------------------------------------------------
# 4. Save Results
# ------------------------------------------------------------------------------
cat("\n--- Saving first stage results ---\n")

saveRDS(list(
  m1 = m1, m2 = m2, m3 = m3, m4 = m4,
  m_es = m_es,
  m_binary = m_binary,
  m_binary_es = m_binary_es
), "../data/processed/first_stage_results.rds")

cat("\n=== First stage analysis complete ===\n")
m1_ct <- coeftable(m1)
cat(sprintf("Key result (m1): coef = %.4f, se = %.4f, p = %.4f\n",
            m1_ct[1, 1], m1_ct[1, 2], m1_ct[1, 4]))
