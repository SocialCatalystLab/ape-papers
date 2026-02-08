# Paper 52: Updated Analysis with Correct Labor Force Construction
# Uses OCC1950 to construct LFP for all years (including 1900)

library(tidyverse)
library(data.table)
library(fixest)

source("code/00_packages.R")

cat("=== UPDATED ANALYSIS: Correcting Labor Force Measurement ===\n\n")

# =============================================================================
# 1. Load data and construct consistent LFP measure
# =============================================================================

d <- readRDS("data/analysis_sample_10pct.rds")
cat("Loaded", nrow(d), "records\n")

# Construct LFP from OCC1950:
# OCC1950 1-979 = has occupation = in labor force
# OCC1950 0 or 980+ = no occupation = not in labor force
d$lfp_occ <- as.integer(d$OCC1950 >= 1 & d$OCC1950 <= 979)

cat("\n=== LFP by Year (using OCC1950-based measure) ===\n")
print(d %>% group_by(YEAR) %>% summarise(
  N = n(),
  LFP_rate = mean(lfp_occ, na.rm = TRUE),
  .groups = "drop"
))

# Compare with LABFORCE where available
cat("\n=== Comparing OCC1950-based vs LABFORCE-based LFP ===\n")
cat("Years with LABFORCE data (1880, 1910, 1920):\n")
comparison <- d %>%
  filter(YEAR != 1900) %>%
  mutate(lfp_labforce = ifelse(LABFORCE == 2, 1, 0)) %>%
  summarise(
    corr = cor(lfp_occ, lfp_labforce, use = "complete.obs"),
    agree_pct = mean(lfp_occ == lfp_labforce, na.rm = TRUE)
  )
print(comparison)

# =============================================================================
# 2. Summary Statistics
# =============================================================================

cat("\n=== SUMMARY STATISTICS ===\n")
summary_stats <- d %>%
  group_by(treated, URBAN) %>%
  summarise(
    N = n(),
    LFP = mean(lfp_occ, na.rm = TRUE),
    Age = mean(AGE, na.rm = TRUE),
    White = mean(RACE == 1, na.rm = TRUE),
    .groups = "drop"
  )
print(summary_stats)

# More detailed stats for paper
stats_by_year <- d %>%
  group_by(YEAR, treated, URBAN) %>%
  summarise(
    N = n(),
    LFP = mean(lfp_occ, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(treated, URBAN, YEAR)
print(stats_by_year)

write_csv(summary_stats, "data/summary_stats_updated.csv")
write_csv(stats_by_year, "data/stats_by_year.csv")

# =============================================================================
# 3. Main Regressions
# =============================================================================

cat("\n=== MODEL 1: Basic TWFE ===\n")
m1 <- feols(lfp_occ ~ post | STATEFIP + YEAR,
            data = d,
            weights = ~PERWT,
            cluster = ~STATEFIP)
print(coeftable(m1))

cat("\n=== MODEL 2: Triple-Difference (Post × Urban) ===\n")
m2 <- feols(lfp_occ ~ post * URBAN | STATEFIP + YEAR,
            data = d,
            weights = ~PERWT,
            cluster = ~STATEFIP)
print(coeftable(m2))

cat("\n=== MODEL 3: With Individual Controls ===\n")
m3 <- feols(lfp_occ ~ post * URBAN + AGE + I(AGE^2) + factor(RACE) | STATEFIP + YEAR,
            data = d,
            weights = ~PERWT,
            cluster = ~STATEFIP)
print(coeftable(m3))

# =============================================================================
# 4. Stratified Analysis (Urban vs Rural)
# =============================================================================

cat("\n=== STRATIFIED: Urban Only ===\n")
m_urban <- feols(lfp_occ ~ post | STATEFIP + YEAR,
                 data = d %>% filter(URBAN == 1),
                 weights = ~PERWT,
                 cluster = ~STATEFIP)
print(coeftable(m_urban))

cat("\n=== STRATIFIED: Rural Only ===\n")
m_rural <- feols(lfp_occ ~ post | STATEFIP + YEAR,
                 data = d %>% filter(URBAN == 0),
                 weights = ~PERWT,
                 cluster = ~STATEFIP)
print(coeftable(m_rural))

urban_effect <- coef(m_urban)["post"]
rural_effect <- coef(m_rural)["post"]
cat("\n=== Urban vs Rural Comparison ===\n")
cat("Urban effect:", round(urban_effect, 4), "(SE:", round(se(m_urban)["post"], 4), ")\n")
cat("Rural effect:", round(rural_effect, 4), "(SE:", round(se(m_rural)["post"], 4), ")\n")
cat("Difference (Urban - Rural):", round(urban_effect - rural_effect, 4), "\n")

# =============================================================================
# 5. Event Study with Sun-Abraham
# =============================================================================

cat("\n=== SUN-ABRAHAM EVENT STUDY ===\n")

# Create proper cohort variable for Sun-Abraham
d$cohort_sa <- ifelse(d$treated, d$year_suffrage, Inf)

# Sun-Abraham estimator
m_sunab <- feols(lfp_occ ~ sunab(cohort_sa, YEAR) | STATEFIP + YEAR,
                 data = d,
                 weights = ~PERWT,
                 cluster = ~STATEFIP)
print(summary(m_sunab, agg = "att"))

# Get event study coefficients
es_coefs <- coeftable(m_sunab)
print(es_coefs)

# =============================================================================
# 6. Event Study - Stratified by Urban/Rural
# =============================================================================

cat("\n=== EVENT STUDY: Urban ===\n")
d_urban <- d %>% filter(URBAN == 1)
m_sunab_urban <- feols(lfp_occ ~ sunab(cohort_sa, YEAR) | STATEFIP + YEAR,
                       data = d_urban,
                       weights = ~PERWT,
                       cluster = ~STATEFIP)
print(summary(m_sunab_urban, agg = "att"))

cat("\n=== EVENT STUDY: Rural ===\n")
d_rural <- d %>% filter(URBAN == 0)
m_sunab_rural <- feols(lfp_occ ~ sunab(cohort_sa, YEAR) | STATEFIP + YEAR,
                       data = d_rural,
                       weights = ~PERWT,
                       cluster = ~STATEFIP)
print(summary(m_sunab_rural, agg = "att"))

# =============================================================================
# 7. Heterogeneity by Race
# =============================================================================

cat("\n=== HETEROGENEITY: By Race ===\n")

# White women
m_white <- feols(lfp_occ ~ post * URBAN | STATEFIP + YEAR,
                 data = d %>% filter(RACE == 1),
                 weights = ~PERWT,
                 cluster = ~STATEFIP)

# Non-white women (primarily Black)
m_nonwhite <- feols(lfp_occ ~ post * URBAN | STATEFIP + YEAR,
                    data = d %>% filter(RACE != 1),
                    weights = ~PERWT,
                    cluster = ~STATEFIP)

cat("White women:\n")
print(coeftable(m_white))
cat("\nNon-white women:\n")
print(coeftable(m_nonwhite))

# =============================================================================
# 8. Heterogeneity by Age
# =============================================================================

cat("\n=== HETEROGENEITY: By Age ===\n")

# Young women (18-34)
m_young <- feols(lfp_occ ~ post * URBAN | STATEFIP + YEAR,
                 data = d %>% filter(AGE >= 18 & AGE <= 34),
                 weights = ~PERWT,
                 cluster = ~STATEFIP)

# Older women (35-64)
m_older <- feols(lfp_occ ~ post * URBAN | STATEFIP + YEAR,
                 data = d %>% filter(AGE >= 35 & AGE <= 64),
                 weights = ~PERWT,
                 cluster = ~STATEFIP)

cat("Young women (18-34):\n")
print(coeftable(m_young))
cat("\nOlder women (35-64):\n")
print(coeftable(m_older))

# =============================================================================
# 9. Robustness: Exclude early adopters
# =============================================================================

cat("\n=== ROBUSTNESS: Excluding Early Adopters (WY, UT, CO, ID) ===\n")
early_adopters <- c(56, 49, 8, 16)  # FIPS codes for WY, UT, CO, ID
d_late <- d %>% filter(!(STATEFIP %in% early_adopters))

m_late <- feols(lfp_occ ~ post * URBAN | STATEFIP + YEAR,
                data = d_late,
                weights = ~PERWT,
                cluster = ~STATEFIP)
print(coeftable(m_late))

# =============================================================================
# 10. Save Results
# =============================================================================

results <- list(
  summary_stats = summary_stats,
  stats_by_year = stats_by_year,
  m1_twfe = m1,
  m2_triple = m2,
  m3_controls = m3,
  m_urban = m_urban,
  m_rural = m_rural,
  m_sunab = m_sunab,
  m_sunab_urban = m_sunab_urban,
  m_sunab_rural = m_sunab_rural,
  m_white = m_white,
  m_nonwhite = m_nonwhite,
  m_young = m_young,
  m_older = m_older,
  m_late = m_late
)

saveRDS(results, "data/real_results_updated.rds")

cat("\n=== ANALYSIS COMPLETE ===\n")
cat("Results saved to data/real_results_updated.rds\n")

# =============================================================================
# 11. Create formatted output for paper
# =============================================================================

cat("\n=== FORMATTED RESULTS FOR PAPER ===\n")

# Main results table
cat("\nMain Results (Table 2 values):\n")
cat("Model 1 (TWFE): post =", round(coef(m1)["post"], 4),
    " SE =", round(se(m1)["post"], 4), "\n")
cat("Model 2 (Triple-Diff): post =", round(coef(m2)["post"], 4),
    " post×urban =", round(coef(m2)["post:URBAN"], 4), "\n")
cat("Model 3 (Controls): post =", round(coef(m3)["post"], 4),
    " post×urban =", round(coef(m3)["post:URBAN"], 4), "\n")

cat("\nStratified Results (Table 3 values):\n")
cat("Urban: post =", round(coef(m_urban)["post"], 4),
    " SE =", round(se(m_urban)["post"], 4), "\n")
cat("Rural: post =", round(coef(m_rural)["post"], 4),
    " SE =", round(se(m_rural)["post"], 4), "\n")
