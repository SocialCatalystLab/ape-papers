## ============================================================================
## 03_main_analysis.R — Core descriptive analysis
## ============================================================================

source("00_packages.R")

## ---- Load panels ----
ny_npis <- readRDS(file.path(DATA, "ny_npis.rds"))
zip_total <- readRDS(file.path(DATA, "zip_total.rds"))
county_total <- readRDS(file.path(DATA, "county_total.rds"))
county_service <- readRDS(file.path(DATA, "county_service.rds"))
t1019_zip <- readRDS(file.path(DATA, "t1019_zip.rds"))
t1019_monthly <- readRDS(file.path(DATA, "t1019_monthly.rds"))
ny_provider_months <- readRDS(file.path(DATA, "ny_provider_months.rds"))
hhi_county <- readRDS(file.path(DATA, "hhi_county.rds"))
borough_stats <- readRDS(file.path(DATA, "borough_stats.rds"))
national_service <- readRDS(file.path(DATA, "national_service.rds"))

## ---- 1. Key summary statistics ----
cat("=== KEY SUMMARY STATISTICS ===\n\n")

# Total NY
ny_total_paid <- sum(zip_total$total_paid, na.rm = TRUE)
ny_total_providers <- sum(zip_total$n_providers, na.rm = TRUE)
ny_total_claims <- sum(zip_total$total_claims, na.rm = TRUE)
ny_zips <- nrow(zip_total[!is.na(zip5)])

cat(sprintf("NY total spending: $%.1fB\n", ny_total_paid / 1e9))
cat(sprintf("NY unique billing NPIs: %s\n", format(ny_total_providers, big.mark = ",")))
cat(sprintf("NY total claims: %.1fB\n", ny_total_claims / 1e9))
cat(sprintf("NY unique ZIPs: %d\n", ny_zips))

## ---- 2. Spatial concentration ----
cat("\n=== SPATIAL CONCENTRATION ===\n\n")

# Lorenz curve data
zip_sorted <- zip_total[order(-total_paid)]
zip_sorted[, cum_pct_spend := cumsum(total_paid) / sum(total_paid) * 100]
zip_sorted[, cum_pct_zips := (1:.N) / .N * 100]

# Key concentration stats
top10_pct <- zip_sorted[10, cum_pct_spend]
top20_pct <- zip_sorted[20, cum_pct_spend]
top50_pct <- zip_sorted[50, cum_pct_spend]

cat(sprintf("Top 10 ZIPs: %.1f%% of spending\n", top10_pct))
cat(sprintf("Top 20 ZIPs: %.1f%% of spending\n", top20_pct))
cat(sprintf("Top 50 ZIPs: %.1f%% of spending\n", top50_pct))

# Gini coefficient
n <- nrow(zip_sorted)
gini <- 1 - 2 * sum((n + 1 - 1:n) * sort(zip_sorted$total_paid)) /
  (n * sum(zip_sorted$total_paid))
cat(sprintf("Gini coefficient: %.3f\n", gini))

# Save Lorenz data
saveRDS(zip_sorted, file.path(DATA, "lorenz_data.rds"))

## ---- 3. NYC vs Rest comparison ----
cat("\n=== NYC vs REST ===\n\n")

region_stats <- ny_provider_months[, .(
  providers = .N,
  total_paid = sum(total_paid, na.rm = TRUE),
  median_months = as.double(median(months_active)),
  mean_months = mean(months_active),
  pct_transient = mean(months_active < 12) * 100,
  spending_per_provider = sum(total_paid, na.rm = TRUE) / .N
), by = region]

print(region_stats[order(-total_paid)])

## ---- 4. Provider tenure analysis ----
cat("\n=== PROVIDER TENURE ===\n\n")

tenure_dist <- ny_provider_months[, .(
  n_providers = .N,
  total_paid = sum(total_paid, na.rm = TRUE)
), by = tenure_group]

tenure_dist[, pct_providers := n_providers / sum(n_providers) * 100]
tenure_dist[, pct_paid := total_paid / sum(total_paid) * 100]

# Order
tenure_order <- c("1 month", "2-3 months", "4-6 months", "7-11 months",
                   "12-18 months", "19-24 months", "25-48 months",
                   "49-72 months", "73-84 months")
tenure_dist[, tenure_group := factor(tenure_group, levels = tenure_order)]
setorder(tenure_dist, tenure_group)
print(tenure_dist)

saveRDS(tenure_dist, file.path(DATA, "tenure_dist.rds"))

## ---- 5. T1019 concentration ----
cat("\n=== T1019 CONCENTRATION ===\n\n")

t1019_total <- sum(t1019_zip$t1019_paid, na.rm = TRUE)
cat(sprintf("T1019 total spending: $%.1fB\n", t1019_total / 1e9))
cat(sprintf("T1019 share of NY spending: %.1f%%\n",
            t1019_total / ny_total_paid * 100))

# Top T1019 ZIPs
t1019_sorted <- t1019_zip[order(-t1019_paid)][1:10]
cat("\nTop 10 T1019 ZIPs:\n")
print(t1019_sorted)

## ---- 6. HHI analysis ----
cat("\n=== MARKET CONCENTRATION (HHI) ===\n\n")

cat(sprintf("Mean HHI (T1019 by county): %.0f\n", mean(hhi_county$hhi, na.rm = TRUE)))
cat(sprintf("Median HHI: %.0f\n", median(hhi_county$hhi, na.rm = TRUE)))
cat(sprintf("Counties with HHI > 2500 (highly concentrated): %d / %d\n",
            sum(hhi_county$hhi > 2500, na.rm = TRUE), nrow(hhi_county)))
cat(sprintf("Mean top-1 provider share: %.1f%%\n",
            mean(hhi_county$top1_share, na.rm = TRUE) * 100))

saveRDS(region_stats, file.path(DATA, "region_stats.rds"))

## ---- 7. Borough comparison ----
cat("\n=== NYC BOROUGH COMPARISON ===\n\n")
print(borough_stats[order(-total_paid)])

cat("\nAnalysis complete.\n")
