## ============================================================================
## 06_tables.R — All tables for paper
## ============================================================================

source("00_packages.R")

## ---- Load data ----
zip_total <- readRDS(file.path(DATA, "zip_total.rds"))
t1019_zip <- readRDS(file.path(DATA, "t1019_zip.rds"))
ny_provider_months <- readRDS(file.path(DATA, "ny_provider_months.rds"))
hhi_county <- readRDS(file.path(DATA, "hhi_county.rds"))
borough_stats <- readRDS(file.path(DATA, "borough_stats.rds"))
national_service <- readRDS(file.path(DATA, "national_service.rds"))
county_service <- readRDS(file.path(DATA, "county_service.rds"))
county_total <- readRDS(file.path(DATA, "county_total.rds"))
county_shapes <- readRDS(file.path(DATA, "ny_county_shapes.rds"))
region_stats <- readRDS(file.path(DATA, "region_stats.rds"))

## ============================================================================
## TABLE 1: NY Overview Statistics
## ============================================================================

ny_total_paid <- sum(zip_total$total_paid, na.rm = TRUE)
ny_total_claims <- sum(zip_total$total_claims, na.rm = TRUE)
ny_n_providers <- nrow(ny_provider_months)
ny_n_zips <- nrow(zip_total[!is.na(zip5)])

# Read tmsis for national totals (using arrow summary)
tmsis <- open_dataset(file.path(DATA, "tmsis_full.parquet"))
national_totals <- tmsis |>
  summarize(
    total_paid = sum(TOTAL_PAID, na.rm = TRUE),
    total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    n_rows = n()
  ) |>
  collect()

nat_paid <- national_totals$total_paid
nat_claims <- national_totals$total_claims

overview_tab <- data.frame(
  Metric = c(
    "Total spending (\\$B)",
    "Total claims (B)",
    "Unique billing NPIs",
    "ZIP codes with providers",
    "Counties",
    "Share of national spending (\\%)",
    "Share of national providers (\\%)",
    "Spending per provider (\\$M)",
    "Median provider spending (\\$K)"
  ),
  `New York` = c(
    sprintf("%.1f", ny_total_paid / 1e9),
    sprintf("%.2f", ny_total_claims / 1e9),
    format(ny_n_providers, big.mark = ","),
    format(ny_n_zips, big.mark = ","),
    "62",
    sprintf("%.1f", ny_total_paid / nat_paid * 100),
    sprintf("%.1f", ny_n_providers / 617503 * 100),
    sprintf("%.2f", ny_total_paid / ny_n_providers / 1e6),
    sprintf("%.1f", median(ny_provider_months$total_paid, na.rm = TRUE) / 1e3)
  ),
  check.names = FALSE
)

# Write LaTeX
sink(file.path(TAB, "tab1_overview.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{New York Medicaid Provider Spending Overview}\n")
cat("\\label{tab:overview}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lr}\n")
cat("\\toprule\n")
cat("Metric & New York \\\\\n")
cat("\\midrule\n")
for (i in 1:nrow(overview_tab)) {
  cat(sprintf("%s & %s \\\\\n", overview_tab$Metric[i], overview_tab$`New York`[i]))
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Data from T-MSIS Medicaid Provider Spending dataset, January 2018 -- December 2024. ")
cat("Provider geography assigned via NPPES practice location ZIP code. ")
cat("National totals from full T-MSIS file (\\$1.09 trillion, 617,503 billing NPIs). ")
cat("Spending per provider = total payments / unique billing NPIs.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\end{table}\n")
sink()
cat("Table 1 saved.\n")

## ============================================================================
## TABLE 2: Top 10 HCPCS Codes in NY
## ============================================================================

# Load tmsis for NY HCPCS analysis
nppes <- readRDS(file.path(DATA, "ny_npis.rds"))
ny_npi_set <- unique(nppes$npi)

ny_hcpcs <- tmsis |>
  filter(BILLING_PROVIDER_NPI_NUM %in% ny_npi_set) |>
  group_by(HCPCS_CODE) |>
  summarize(
    total_paid = sum(TOTAL_PAID, na.rm = TRUE),
    total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    n_providers = n_distinct(BILLING_PROVIDER_NPI_NUM),
    .groups = "drop"
  ) |>
  collect() |>
  as.data.table()

setorder(ny_hcpcs, -total_paid)
top10 <- ny_hcpcs[1:10]
top10[, pct := total_paid / sum(ny_hcpcs$total_paid) * 100]
top10[, per_claim := total_paid / total_claims]

# National comparison for these codes
national_hcpcs <- tmsis |>
  filter(HCPCS_CODE %in% top10$HCPCS_CODE) |>
  group_by(HCPCS_CODE) |>
  summarize(
    nat_paid = sum(TOTAL_PAID, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect() |>
  as.data.table()

national_hcpcs[, nat_pct := nat_paid / nat_paid * 100]  # need total
nat_total <- nat_paid  # from overview
national_hcpcs[, nat_pct := nat_paid / nat_total * 100]

top10 <- merge(top10, national_hcpcs[, .(HCPCS_CODE, nat_pct)],
                by = "HCPCS_CODE", all.x = TRUE)

# HCPCS descriptions
hcpcs_desc <- c(
  "T1019" = "Personal care aide / HHA, 15 min",
  "99213" = "Office visit, estab., low complex.",
  "T1020" = "Personal care aide, live-in, per diem",
  "99214" = "Office visit, estab., moderate",
  "S5126" = "Attendant care services",
  "G9005" = "Telehealth / care management",
  "90834" = "Psychotherapy, 45 min",
  "90832" = "Psychotherapy, 30 min",
  "S5105" = "Day habilitation services",
  "99284" = "ED visit, moderate severity"
)

setorder(top10, -total_paid)

sink(file.path(TAB, "tab2_top_hcpcs.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Top 10 Procedure Codes in New York by Medicaid Spending}\n")
cat("\\label{tab:tophcpcs}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{clS[table-format=5.1]S[table-format=3.1]S[table-format=6.0]S[table-format=3.0]S[table-format=2.1]}\n")
cat("\\toprule\n")
cat("& HCPCS & {Spending (\\$M)} & {\\% NY} & {Providers} & {\\$/Claim} & {\\% Natl} \\\\\n")
cat("\\midrule\n")
for (i in 1:10) {
  r <- top10[i]
  desc <- hcpcs_desc[r$HCPCS_CODE]
  if (is.na(desc)) desc <- ""
  cat(sprintf("%d & \\texttt{%s} & %.1f & %.1f & %s & %.0f & %.1f \\\\\n",
              i, r$HCPCS_CODE,
              r$total_paid / 1e6,
              r$pct,
              format(r$n_providers, big.mark = ","),
              r$per_claim,
              ifelse(is.na(r$nat_pct), 0, r$nat_pct)))
  if (nchar(desc) > 0) {
    cat(sprintf("  & \\small{\\textit{%s}} & & & & & \\\\\n", desc))
  }
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Spending and provider counts cumulative over January 2018 -- December 2024. ")
cat("\\% NY = share of total New York Medicaid spending. \\% Natl = share of total national Medicaid spending. ")
cat("\\$/Claim = average payment per claim.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\end{table}\n")
sink()
cat("Table 2 saved.\n")

## ============================================================================
## TABLE 3: Regional Comparison
## ============================================================================

setorder(region_stats, -total_paid)

sink(file.path(TAB, "tab3_regions.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Medicaid Provider Spending by Region, New York State}\n")
cat("\\label{tab:regions}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lS[table-format=6.0]S[table-format=4.1]S[table-format=3.1]S[table-format=2.1]S[table-format=2.1]}\n")
cat("\\toprule\n")
cat("Region & {Providers} & {Spending (\\$B)} & {\\$/Provider (\\$M)} & {Med. Months} & {\\% Transient} \\\\\n")
cat("\\midrule\n")
for (i in 1:nrow(region_stats)) {
  r <- region_stats[i]
  if (r$region == "Unknown") next
  cat(sprintf("%s & %s & %.1f & %.2f & %.0f & %.1f \\\\\n",
              r$region,
              format(r$providers, big.mark = ","),
              r$total_paid / 1e9,
              r$spending_per_provider / 1e6,
              r$median_months,
              r$pct_transient))
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} NYC = five boroughs (Bronx, Brooklyn, Manhattan, Queens, Staten Island). ")
cat("Long Island = Nassau and Suffolk counties. Hudson Valley = Westchester and Rockland counties. ")
cat("Upstate = all remaining counties. Transient = active fewer than 12 of 84 months. ")
cat("Spending per provider = region total / unique billing NPIs.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\end{table}\n")
sink()
cat("Table 3 saved.\n")

## ============================================================================
## TABLE 4: NYC Borough Comparison
## ============================================================================

setorder(borough_stats, -total_paid)

sink(file.path(TAB, "tab4_boroughs.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Medicaid Spending by NYC Borough}\n")
cat("\\label{tab:boroughs}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lS[table-format=6.0]S[table-format=4.1]S[table-format=5.0]S[table-format=2.1]}\n")
cat("\\toprule\n")
cat("Borough & {Providers} & {Spending (\\$B)} & {Organizations} & {T1019 (\\%)} \\\\\n")
cat("\\midrule\n")
for (i in 1:nrow(borough_stats)) {
  r <- borough_stats[i]
  cat(sprintf("%s & %s & %.1f & %s & %.1f \\\\\n",
              r$borough,
              format(r$n_providers, big.mark = ","),
              r$total_paid / 1e9,
              format(r$n_orgs, big.mark = ","),
              r$pct_t1019))
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Borough assignment based on NPPES practice location ZIP code ")
cat("mapped to county via Census ZCTA-to-county crosswalk. ")
cat("T1019 (\\%) = share of borough's total spending from personal care aide code T1019.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\end{table}\n")
sink()
cat("Table 4 saved.\n")

## ============================================================================
## TABLE 5: Market Concentration (HHI Summary)
## ============================================================================

# Merge county names — ensure GEOID type matches hhi_county$county_fips
county_names <- as.data.table(county_shapes)[, .(county_fips = as.character(GEOID), county_name = NAME)]
hhi_county[, county_fips := as.character(county_fips)]
hhi_named <- merge(hhi_county, county_names, by = "county_fips", all.x = TRUE)
setorder(hhi_named, -hhi)

sink(file.path(TAB, "tab5_hhi.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Market Concentration in Personal Care (T1019) by County}\n")
cat("\\label{tab:hhi}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lS[table-format=5.0]S[table-format=3.0]S[table-format=3.1]S[table-format=2.1]}\n")
cat("\\toprule\n")
cat("County & {HHI} & {Providers} & {Spending (\\$M)} & {Top Firm (\\%)} \\\\\n")
cat("\\midrule\n")
cat("\\multicolumn{5}{l}{\\textit{Panel A: Most Concentrated (Top 10)}} \\\\\n")
for (i in 1:min(10, nrow(hhi_named))) {
  r <- hhi_named[i]
  cat(sprintf("%s & %.0f & %d & %.1f & %.1f \\\\\n",
              r$county_name,
              r$hhi,
              r$n_providers,
              r$total_paid / 1e6,
              r$top1_share * 100))
}
cat("\\midrule\n")
cat("\\multicolumn{5}{l}{\\textit{Panel B: Least Concentrated (Bottom 5)}} \\\\\n")
bottom5 <- hhi_named[order(hhi)][1:min(5, nrow(hhi_named))]
for (i in 1:nrow(bottom5)) {
  r <- bottom5[i]
  cat(sprintf("%s & %.0f & %d & %.1f & %.1f \\\\\n",
              r$county_name,
              r$hhi,
              r$n_providers,
              r$total_paid / 1e6,
              r$top1_share * 100))
}
cat("\\midrule\n")
cat(sprintf("\\textbf{All counties} & \\textbf{%.0f} & \\textbf{%.0f} & \\textbf{%.1f} & \\textbf{%.1f} \\\\\n",
            mean(hhi_named$hhi, na.rm = TRUE),
            mean(hhi_named$n_providers, na.rm = TRUE),
            sum(hhi_named$total_paid, na.rm = TRUE) / 1e6,
            mean(hhi_named$top1_share, na.rm = TRUE) * 100))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} HHI = Herfindahl-Hirschman Index (sum of squared market shares $\\times$ 10,000). ")
cat("Computed at county level using T1019 (personal care aide) spending shares by billing NPI. ")
cat("Top Firm = market share of the largest billing provider. ")
cat("HHI $>$ 2,500 indicates a highly concentrated market (DOJ/FTC threshold). ")
cat("Counties with no T1019 billing excluded. ")
cat("All counties row shows mean HHI and mean providers.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\end{table}\n")
sink()
cat("Table 5 saved.\n")

cat("\nAll tables saved.\n")
