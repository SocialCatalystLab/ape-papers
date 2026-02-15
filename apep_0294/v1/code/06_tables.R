## ============================================================================
## 06_tables.R — All tables for the T-MSIS overview paper
## Uses pre-computed panels from 02_clean_data.R (no full dataset in memory)
## ============================================================================

source("00_packages.R")

DATA <- "../data"
TABS <- "../tables"
dir.create(TABS, showWarnings = FALSE)

# Load pre-computed panels
panel_hcpcs <- readRDS(file.path(DATA, "panel_hcpcs.rds"))
panel_billing <- readRDS(file.path(DATA, "panel_billing.rds"))
provider_panel <- readRDS(file.path(DATA, "provider_panel.rds"))
panel_national <- readRDS(file.path(DATA, "panel_national.rds"))
cat_summary <- readRDS(file.path(DATA, "cat_summary.rds"))

has_state <- file.exists(file.path(DATA, "panel_state.rds"))
if (has_state) panel_state <- readRDS(file.path(DATA, "panel_state.rds"))

## =========================================================================
## TABLE 1: Dataset Overview (using pre-computed aggregates)
## =========================================================================
cat("Creating Table 1: Dataset overview...\n")

# Compute from panels rather than full dataset
total_paid <- sum(panel_national$total_paid)
total_claims <- sum(panel_national$total_claims)
total_benef <- sum(panel_national$total_beneficiaries)
n_providers <- nrow(provider_panel)
n_hcpcs <- nrow(panel_hcpcs)
n_months <- nrow(panel_national)
date_range <- paste0(
  format(min(panel_national$month_date), "%B %Y"), " to ",
  format(max(panel_national$month_date), "%B %Y")
)

# Per-row stats from provider panel
median_monthly_per_provider <- median(provider_panel$total_paid / provider_panel$active_months)
mean_monthly_per_provider <- mean(provider_panel$total_paid / provider_panel$active_months)

# Helper to format large dollar amounts without scientific notation
fmt_dollar <- function(x) {
  paste0("\\$", formatC(round(x), format = "f", big.mark = ",", digits = 0))
}

overview_tab <- data.frame(
  Characteristic = c(
    "Total rows (billing $\\times$ servicing $\\times$ HCPCS $\\times$ month)",
    "Date range",
    "Months covered",
    "Unique billing NPIs",
    "Unique HCPCS codes",
    "Total claims",
    "Total Medicaid paid",
    "Median monthly payment per provider",
    "Mean monthly payment per provider"
  ),
  Value = c(
    formatC(sum(panel_billing$n_rows), format = "f", big.mark = ",", digits = 0),
    date_range,
    as.character(n_months),
    format(n_providers, big.mark = ","),
    format(n_hcpcs, big.mark = ","),
    formatC(round(total_claims), format = "f", big.mark = ",", digits = 0),
    fmt_dollar(total_paid),
    fmt_dollar(median_monthly_per_provider),
    fmt_dollar(mean_monthly_per_provider)
  ),
  stringsAsFactors = FALSE
)

sink(file.path(TABS, "tab1_overview.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{T-MSIS Medicaid Provider Spending Dataset Overview}\n")
cat("\\label{tab:overview}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lp{5cm}}\n")
cat("\\toprule\n")
cat("Characteristic & Value \\\\\n")
cat("\\midrule\n")
for (i in seq_len(nrow(overview_tab))) {
  cat(sprintf("%s & %s \\\\\n", overview_tab$Characteristic[i], overview_tab$Value[i]))
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} T-MSIS = Transformed Medicaid Statistical Information System. Released by HHS February 9, 2026. Covers fee-for-service, managed care, and CHIP claims. Cell suppression applies when beneficiary count $<$ 12. Monthly payment per provider = provider's total payments divided by active months.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\end{table}\n")
sink()

## =========================================================================
## TABLE 2: Top 15 HCPCS Codes
## =========================================================================
cat("Creating Table 2: Top HCPCS codes...\n")

top15 <- head(panel_hcpcs, 15)
top15[, rank := 1:.N]
top15[, pct_total := total_paid / total_paid * 100]
top15[, pct_total := total_paid / sum(panel_hcpcs$total_paid) * 100]
top15[, cum_pct := cumsum(pct_total)]

sink(file.path(TABS, "tab2_top_hcpcs.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Top 15 HCPCS Codes by Total Medicaid Spending, 2018\\textendash 2024}\n")
cat("\\label{tab:top_hcpcs}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{clp{3.5cm}rrrr}\n")
cat("\\toprule\n")
cat("Rank & Code & Description & Total (\\$B) & Claims (M) & Providers & \\% \\\\\n")
cat("\\midrule\n")
for (i in seq_len(nrow(top15))) {
  r <- top15[i]
  cat(sprintf("%d & %s & %s & %.1f & %.1f & %s & %.1f \\\\\n",
              r$rank, r$hcpcs_code,
              gsub("&", "\\\\&", r$hcpcs_detail),
              r$total_paid / 1e9,
              r$total_claims / 1e6,
              format(r$n_providers, big.mark = ","),
              r$pct_total))
}
cat("\\midrule\n")
cat(sprintf("& & Top 15 total & %.1f & %.1f & & %.1f \\\\\n",
            sum(top15$total_paid) / 1e9,
            sum(top15$total_claims) / 1e6,
            sum(top15$pct_total)))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat(sprintf("\\item \\textit{Notes:} HCPCS = Healthcare Common Procedure Coding System. T-codes are state/HCBS specific, H-codes are behavioral health, S-codes are temporary/state codes. Most T, H, and S codes have no Medicare equivalent. Cumulative totals 2018\\textendash 2024. \\%% = share of total cumulative Medicaid spending (\\$%.2f trillion).\n", sum(panel_hcpcs$total_paid) / 1e12))
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\end{table}\n")
sink()

## =========================================================================
## TABLE 3: Service Category Summary
## =========================================================================
cat("Creating Table 3: Service categories...\n")

# Use cat_summary from clean script, add code counts from panel_hcpcs
cat_codes <- panel_hcpcs[, .(n_codes = .N), by = hcpcs_category]
cat_tab <- merge(cat_summary, cat_codes, by = "hcpcs_category", all.x = TRUE)
setorder(cat_tab, -total_paid)
cat_tab[, cum_pct := cumsum(pct_paid)]

sink(file.path(TABS, "tab3_categories.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Medicaid Spending by Service Category}\n")
cat("\\label{tab:categories}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lrrrr}\n")
cat("\\toprule\n")
cat("Category & Spending (\\$B) & \\% Total & Claims (B) & Codes \\\\\n")
cat("\\midrule\n")
for (i in seq_len(nrow(cat_tab))) {
  r <- cat_tab[i]
  cat(sprintf("%s & %.1f & %.1f & %.1f & %s \\\\\n",
              r$hcpcs_category,
              r$total_paid / 1e9,
              r$pct_paid,
              r$total_claims / 1e9,
              format(r$n_codes, big.mark = ",")))
}
cat("\\midrule\n")
cat(sprintf("Total & %.1f & 100.0 & %.1f & %s \\\\\n",
            sum(cat_tab$total_paid) / 1e9,
            sum(cat_tab$total_claims) / 1e9,
            format(nrow(panel_hcpcs), big.mark = ",")))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Categories defined by HCPCS code prefix. T-codes = HCBS/state-specific services; H-codes = behavioral health; S-codes = temporary/state codes; numeric = CPT professional services. Most T, H, and S codes have no Medicare equivalent.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\end{table}\n")
sink()

## =========================================================================
## TABLE 4: Annual Growth Summary
## =========================================================================
cat("Creating Table 4: Annual growth...\n")

# Exclude December 2024 (incomplete due to claims processing lag)
annual <- panel_national[!(year == 2024 & month_num == 12), .(
  total_paid = sum(total_paid),
  total_claims = sum(total_claims),
  n_providers = max(n_providers),
  n_hcpcs = max(n_hcpcs)
), by = year]
setorder(annual, year)

annual[, paid_growth := (total_paid / shift(total_paid) - 1) * 100]
annual[, claims_growth := (total_claims / shift(total_claims) - 1) * 100]
# Suppress misleading growth rates for 2024 (11 months vs 12 months comparison)
annual[year == 2024, paid_growth := NA_real_]
annual[year == 2024, claims_growth := NA_real_]

sink(file.path(TABS, "tab4_annual_growth.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Annual Growth in Medicaid Provider Spending}\n")
cat("\\label{tab:growth}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lrrrrrr}\n")
cat("\\toprule\n")
cat("Year & Spending (\\$B) & \\% $\\Delta$ & Claims (M) & \\% $\\Delta$ & Providers & Codes \\\\\n")
cat("\\midrule\n")
for (i in seq_len(nrow(annual))) {
  r <- annual[i]
  growth_p <- ifelse(is.na(r$paid_growth), "---", sprintf("%.1f", r$paid_growth))
  growth_c <- ifelse(is.na(r$claims_growth), "---", sprintf("%.1f", r$claims_growth))
  cat(sprintf("%d & %.1f & %s & %.1f & %s & %s & %s \\\\\n",
              r$year,
              r$total_paid / 1e9, growth_p,
              r$total_claims / 1e6, growth_c,
              format(r$n_providers, big.mark = ","),
              format(r$n_hcpcs, big.mark = ",")))
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Annual totals from T-MSIS. Providers = peak monthly unique billing NPIs. 2024 covers January--November only (December excluded due to claims processing lag); growth rates suppressed for 2024 because the 11- vs.\\ 12-month comparison is not meaningful. \\% $\\Delta$ = year-over-year growth rate.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\end{table}\n")
sink()

## =========================================================================
## TABLE 5: Provider Panel Properties
## =========================================================================
cat("Creating Table 5: Panel properties...\n")

tenure_breaks <- c(1, 6, 12, 24, 36, 48, 60, 72, 84)
provider_panel[, tenure_group := cut(active_months,
  breaks = c(0, tenure_breaks, Inf),
  labels = c(paste0(c("1", "2--6", "7--12", "13--24", "25--36", "37--48", "49--60", "61--72", "73--84"), " months"),
             "84+ months"),
  right = TRUE)]

tenure_dist <- provider_panel[, .(
  n = .N,
  total_paid = sum(total_paid),
  median_paid = median(total_paid)
), by = tenure_group]
tenure_dist[, pct_providers := n / sum(n) * 100]
tenure_dist[, pct_paid := total_paid / sum(total_paid) * 100]

# Sort by factor level order (ascending tenure)
tenure_dist <- tenure_dist[order(tenure_group)]

sink(file.path(TABS, "tab5_panel_properties.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Provider Panel Properties: Tenure and Spending Concentration}\n")
cat("\\label{tab:panel}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lrrrr}\n")
cat("\\toprule\n")
cat("Tenure & Providers & \\% of Providers & \\% of Spending & Median Total (\\$) \\\\\n")
cat("\\midrule\n")
for (i in seq_len(nrow(tenure_dist))) {
  r <- tenure_dist[i]
  cat(sprintf("%s & %s & %.1f & %.1f & %s \\\\\n",
              as.character(r$tenure_group),
              format(r$n, big.mark = ","),
              r$pct_providers, r$pct_paid,
              format(round(r$median_paid), big.mark = ",")))
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Panel covers January 2018\\textendash December 2024 (84 months). Tenure = months with at least one billing claim. Median total = median of cumulative payments across all months active.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\end{table}\n")
sink()

## =========================================================================
## TABLE 6: Billing Structure
## =========================================================================
cat("Creating Table 6: Billing structure...\n")

bill_tab <- panel_billing[, .(
  billing_structure,
  n_rows = format(n_rows, big.mark = ","),
  pct_rows = sprintf("%.1f", pct_rows),
  paid_billions = sprintf("%.1f", total_paid / 1e9),
  pct_paid = sprintf("%.1f", total_paid / sum(total_paid) * 100)
)]

sink(file.path(TABS, "tab6_billing_structure.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Billing Structure: Organizational Relationships in T-MSIS}\n")
cat("\\label{tab:billing}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lrrrr}\n")
cat("\\toprule\n")
cat("Structure & Rows & \\% Rows & Spending (\\$B) & \\% Spending \\\\\n")
cat("\\midrule\n")
for (i in seq_len(nrow(bill_tab))) {
  r <- bill_tab[i]
  cat(sprintf("%s & %s & %s & %s & %s \\\\\n",
              r$billing_structure, r$n_rows, r$pct_rows, r$paid_billions, r$pct_paid))
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Self-billing = billing NPI equals servicing NPI (provider bills for own services). Solo = no servicing NPI recorded (typically Type 2 organizations). Organization billing = billing NPI differs from servicing NPI (org bills for individual practitioners).\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\end{table}\n")
sink()

cat("\n=== All tables saved to", TABS, "===\n")
cat("Files:\n")
for (f in sort(list.files(TABS))) cat("  ", f, "\n")
