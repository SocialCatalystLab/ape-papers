## ============================================================================
## 04_robustness.R — Sensitivity and robustness checks
## ============================================================================

source("00_packages.R")

## ---- Load panels ----
ny_provider_months <- readRDS(file.path(DATA, "ny_provider_months.rds"))
zip_total <- readRDS(file.path(DATA, "zip_total.rds"))
t1019_zip <- readRDS(file.path(DATA, "t1019_zip.rds"))

## ---- 1. Exclude fiscal intermediaries ----
# ZIP 12110 (Latham) is a probable fiscal intermediary hub
# Check if results change when excluding top billing ZIPs

cat("=== SENSITIVITY: EXCLUDING FISCAL INTERMEDIARY ZIPS ===\n\n")

# Identify ZIPs with extremely high spending-per-provider ratios
zip_total[, spend_per_provider := total_paid / n_providers]
outlier_zips <- zip_total[spend_per_provider > 1e9]  # >$1B per provider

cat(sprintf("ZIPs with >$1B per provider: %d\n", nrow(outlier_zips)))
if (nrow(outlier_zips) > 0) {
  print(outlier_zips[, .(zip5, n_providers, total_paid_B = total_paid/1e9,
                          spend_per_prov_M = spend_per_provider/1e6)])
}

# Recalculate concentration excluding these
zip_excl <- zip_total[!zip5 %in% outlier_zips$zip5]
zip_excl_sorted <- zip_excl[order(-total_paid)]
zip_excl_sorted[, cum_pct_spend := cumsum(total_paid) / sum(total_paid) * 100]

top20_excl <- zip_excl_sorted[20, cum_pct_spend]
cat(sprintf("\nTop 20 ZIPs share (excl intermediaries): %.1f%%\n", top20_excl))

## ---- 2. Individual vs Organization providers ----
cat("\n=== INDIVIDUAL vs ORGANIZATION PROVIDERS ===\n\n")

by_entity <- ny_provider_months[, .(
  n = .N,
  total_paid = sum(total_paid, na.rm = TRUE),
  mean_months = mean(months_active),
  pct_transient = mean(months_active < 12) * 100
), by = entity_label]

by_entity[, pct_providers := n / sum(n) * 100]
by_entity[, pct_paid := total_paid / sum(total_paid) * 100]
print(by_entity)

## ---- 3. Pre/post COVID stability ----
cat("\n=== PRE/POST COVID SPENDING STRUCTURE ===\n\n")

zip_monthly <- readRDS(file.path(DATA, "zip_monthly.rds"))

# Split into pre-COVID (2018-2019) and post-COVID (2022-2024)
zip_monthly[, period := fcase(
  month < "2020-03", "Pre-COVID (2018-2019)",
  month >= "2022-01", "Post-COVID (2022-2024)",
  default = "Transition"
)]

period_total <- zip_monthly[period != "Transition", .(
  total_paid = sum(total_paid, na.rm = TRUE),
  n_zips = uniqueN(zip5)
), by = period]

cat("Spending by period:\n")
print(period_total)

# Rank correlation: are the same ZIPs high-spending in both periods?
pre <- zip_monthly[period == "Pre-COVID (2018-2019)",
                    .(pre_paid = sum(total_paid)), by = zip5]
post <- zip_monthly[period == "Post-COVID (2022-2024)",
                     .(post_paid = sum(total_paid)), by = zip5]

both <- merge(pre, post, by = "zip5")
rank_corr <- cor(both$pre_paid, both$post_paid, method = "spearman")
cat(sprintf("Spearman rank correlation (pre vs post COVID): %.3f\n", rank_corr))

saveRDS(both, file.path(DATA, "pre_post_stability.rds"))

## ---- 4. Specialty composition by region ----
cat("\n=== SPECIALTY COMPOSITION BY REGION ===\n\n")

specialty_region <- ny_provider_months[, .(
  n = .N,
  total_paid = sum(total_paid, na.rm = TRUE)
), by = .(region, specialty_group)]

specialty_region[, pct_paid := total_paid / sum(total_paid) * 100, by = region]

# Wide format for comparison
spec_wide <- dcast(specialty_region, specialty_group ~ region,
                    value.var = "pct_paid", fill = 0)
print(spec_wide)

saveRDS(specialty_region, file.path(DATA, "specialty_region.rds"))

cat("\nRobustness checks complete.\n")
