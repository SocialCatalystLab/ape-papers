## 06_tables.R — Publication-quality tables for PMGSY dynamic RDD
## APEP-0429

source("00_packages.R")
load("../data/analysis_data.RData")
load("../data/main_results.RData")
load("../data/robustness_results.RData")

tab_dir <- "../tables"

## ── Table 1: Summary Statistics ─────────────────────────────────────
cat("Generating Table 1: Summary statistics...\n")

sample_near <- sample[abs(pop_centered) <= 200]
stats <- data.table(
  Variable = c("Population (2001)", "Population (1991)",
               "Literacy Rate (2001)", "Agricultural Worker Share (2001)",
               "SC Share (2001)", "ST Share (2001)",
               "Female Share (2001)", "Worker Share (2001)",
               "DMSP Nightlights, raw (2000)", "VIIRS Nightlights, raw (2012)",
               "$N$"),
  `Below 500` = c(
    round(mean(sample_near[eligible == 0]$pop01), 0),
    round(mean(sample_near[eligible == 0]$pop91, na.rm = TRUE), 0),
    round(mean(sample_near[eligible == 0]$lit_rate_01, na.rm = TRUE), 3),
    round(mean(sample_near[eligible == 0]$ag_share_01, na.rm = TRUE), 3),
    round(mean(sample_near[eligible == 0]$sc_share_01, na.rm = TRUE), 3),
    round(mean(sample_near[eligible == 0]$st_share_01, na.rm = TRUE), 3),
    round(mean(sample_near[eligible == 0]$female_share_01, na.rm = TRUE), 3),
    round(mean(sample_near[eligible == 0]$worker_share_01, na.rm = TRUE), 3),
    round(mean(sample_near[eligible == 0]$dmsp_2000, na.rm = TRUE), 2),
    round(mean(sample_near[eligible == 0]$viirs_2012, na.rm = TRUE), 2),
    nrow(sample_near[eligible == 0])
  ),
  `Above 500` = c(
    round(mean(sample_near[eligible == 1]$pop01), 0),
    round(mean(sample_near[eligible == 1]$pop91, na.rm = TRUE), 0),
    round(mean(sample_near[eligible == 1]$lit_rate_01, na.rm = TRUE), 3),
    round(mean(sample_near[eligible == 1]$ag_share_01, na.rm = TRUE), 3),
    round(mean(sample_near[eligible == 1]$sc_share_01, na.rm = TRUE), 3),
    round(mean(sample_near[eligible == 1]$st_share_01, na.rm = TRUE), 3),
    round(mean(sample_near[eligible == 1]$female_share_01, na.rm = TRUE), 3),
    round(mean(sample_near[eligible == 1]$worker_share_01, na.rm = TRUE), 3),
    round(mean(sample_near[eligible == 1]$dmsp_2000, na.rm = TRUE), 2),
    round(mean(sample_near[eligible == 1]$viirs_2012, na.rm = TRUE), 2),
    nrow(sample_near[eligible == 1])
  )
)

## Write to LaTeX
sink(file.path(tab_dir, "tab1_summary.tex"))
cat("\\begin{table}[htbp]\n\\centering\n")
cat("\\caption{Summary Statistics: Villages Near PMGSY Threshold}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{tabular}{lcc}\n\\hline\\hline\n")
cat("& Below 500 & Above 500 \\\\\n\\hline\n")
for (i in 1:nrow(stats)) {
  cat(stats$Variable[i], "&", stats$`Below 500`[i], "&",
      stats$`Above 500`[i], "\\\\\n")
}
cat("\\hline\\hline\n\\end{tabular}\n")
cat("\\begin{tablenotes}\\small\n")
cat("\\item \\textit{Notes:} Sample includes rural villages in plain areas within $\\pm$200 of the PMGSY population threshold of 500 (Census 2001). NE states, Himachal Pradesh, J\\&K, and Uttarakhand excluded (threshold is 250 in these areas). DMSP Nightlights are calibrated total luminosity (integer 0--63). VIIRS Nightlights are annual sum radiance (nW/cm$^2$/sr). Regressions use $\\text{asinh}(\\cdot)$-transformed nightlights.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()
cat("  Saved tab1_summary.tex\n")

## ── Table 2: Main RDD Results ───────────────────────────────────────
cat("Generating Table 2: Main RDD results...\n")

## Select key years
key_years <- c(2000, 2005, 2010, 2013, 2015, 2020, 2023)
main_tab <- dynamic_all[year %in% key_years]
main_tab[, stars := ifelse(p_value < 0.01, "***",
                           ifelse(p_value < 0.05, "**",
                                  ifelse(p_value < 0.1, "*", "")))]

sink(file.path(tab_dir, "tab2_main_rdd.tex"))
cat("\\begin{table}[htbp]\n\\centering\n")
cat("\\caption{Main RDD Estimates: Effect of PMGSY Eligibility on Nightlights}\n")
cat("\\label{tab:main_rdd}\n")
cat("\\begin{tabular}{lccccc}\n\\hline\\hline\n")
cat("Year & Sensor & Estimate & SE & $p$-value & $N_{\\text{eff}}$ \\\\\n\\hline\n")
for (i in 1:nrow(main_tab)) {
  r <- main_tab[i]
  cat(r$year, "&", r$sensor, "&",
      sprintf("%.4f%s", r$estimate, r$stars), "&",
      sprintf("(%.4f)", r$se), "&",
      sprintf("%.3f", r$p_value), "&",
      format(r$n_eff, big.mark = ","), "\\\\\n")
}
cat("\\hline\\hline\n\\end{tabular}\n")
cat("\\begin{tablenotes}\\small\n")
cat("\\item \\textit{Notes:} Each row reports a separate local polynomial RDD estimate using \\texttt{rdrobust} with MSE-optimal bandwidth and triangular kernel. Dependent variable is $\\text{asinh}(\\text{nightlights})$. Running variable is Census 2001 village population centered at 500. Robust bias-corrected confidence intervals. * $p<0.1$, ** $p<0.05$, *** $p<0.01$.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()
cat("  Saved tab2_main_rdd.tex\n")

## ── Table 3: Covariate Balance ──────────────────────────────────────
cat("Generating Table 3: Covariate balance...\n")

sink(file.path(tab_dir, "tab3_balance.tex"))
cat("\\begin{table}[htbp]\n\\centering\n")
cat("\\caption{Covariate Balance at PMGSY Population Threshold}\n")
cat("\\label{tab:balance}\n")
cat("\\begin{tabular}{lcccc}\n\\hline\\hline\n")
cat("Covariate & Estimate & SE & $p$-value & $N_{\\text{eff}}$ \\\\\n\\hline\n")
## Map variable names to formal labels
balance_labels <- c(
  "balance_pop91" = "Population (1991)",
  "balance_lit_rate_01" = "Literacy Rate (2001)",
  "balance_ag_share_01" = "Agricultural Worker Share (2001)",
  "balance_sc_share_01" = "SC Share (2001)",
  "balance_st_share_01" = "ST Share (2001)",
  "balance_female_share_01" = "Female Share (2001)",
  "balance_worker_share_01" = "Worker Share (2001)"
)
for (i in 1:nrow(balance_results)) {
  r <- balance_results[i]
  label <- ifelse(r$outcome %in% names(balance_labels),
                  balance_labels[r$outcome],
                  gsub("_", " ", gsub("balance_", "", r$outcome)))
  cat(label, "&", sprintf("%.4f", r$estimate), "&",
      sprintf("(%.4f)", r$se), "&",
      sprintf("%.3f", r$p_value), "&",
      format(r$n_eff, big.mark = ","), "\\\\\n")
}
cat("\\hline\\hline\n\\end{tabular}\n")
cat("\\begin{tablenotes}\\small\n")
cat("\\item \\textit{Notes:} Each row reports an RDD estimate of the discontinuity in the pre-determined covariate at the 500 population threshold. MSE-optimal bandwidth, local linear polynomial, triangular kernel. Robust bias-corrected standard errors. No covariate shows a statistically significant discontinuity at conventional levels.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()
cat("  Saved tab3_balance.tex\n")

## ── Table 4: Census Outcome RDD ─────────────────────────────────────
cat("Generating Table 4: Census outcomes...\n")

sink(file.path(tab_dir, "tab4_census.tex"))
cat("\\begin{table}[htbp]\n\\centering\n")
cat("\\caption{RDD Estimates: Effect of PMGSY Eligibility on Census Outcomes (2001--2011)}\n")
cat("\\label{tab:census}\n")
cat("\\begin{tabular}{lcccc}\n\\hline\\hline\n")
cat("Outcome & Estimate & SE & $p$-value & $N_{\\text{eff}}$ \\\\\n\\hline\n")
for (i in 1:nrow(census_results)) {
  r <- census_results[i]
  label <- gsub("_", " ", r$outcome)
  label <- tools::toTitleCase(label)
  cat(label, "&", sprintf("%.4f", r$estimate), "&",
      sprintf("(%.4f)", r$se), "&",
      sprintf("%.3f", r$p_value), "&",
      format(r$n_eff, big.mark = ","), "\\\\\n")
}
cat("\\hline\\hline\n\\end{tabular}\n")
cat("\\begin{tablenotes}\\small\n")
cat("\\item \\textit{Notes:} Each row reports a separate RDD estimate. Lit Change = literacy rate change (2001--2011). Ag Change = agricultural worker share change. Pop Growth = $\\log(\\text{pop}_{2011}/\\text{pop}_{2001})$. Worker Change = worker participation rate change. MSE-optimal bandwidth, local linear polynomial, triangular kernel.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()
cat("  Saved tab4_census.tex\n")

## ── Table 5: Robustness ─────────────────────────────────────────────
cat("Generating Table 5: Robustness...\n")

sink(file.path(tab_dir, "tab5_robustness.tex"))
cat("\\begin{table}[htbp]\n\\centering\n")
cat("\\caption{Robustness: VIIRS 2020 RDD Estimates}\n")
cat("\\label{tab:robustness}\n")
cat("\\begin{tabular}{llcccc}\n\\hline\\hline\n")
cat("Specification & & Estimate & SE & $p$-value & $N_{\\text{eff}}$ \\\\\n\\hline\n")
cat("\\multicolumn{6}{l}{\\textit{Panel A: Bandwidth Sensitivity}} \\\\\n")
for (i in 1:nrow(bw_results)) {
  r <- bw_results[i]
  cat("& $h =", r$h, "$ &", sprintf("%.4f", r$estimate), "&",
      sprintf("(%.4f)", r$se), "&",
      sprintf("%.3f", r$p_value), "&",
      format(r$n_eff, big.mark = ","), "\\\\\n")
}
cat("\\multicolumn{6}{l}{\\textit{Panel B: Polynomial Order}} \\\\\n")
for (i in 1:nrow(poly_results)) {
  r <- poly_results[i]
  cat("& $p =", r$poly, "$ &", sprintf("%.4f", r$estimate), "&",
      sprintf("(%.4f)", r$se), "&",
      sprintf("%.3f", r$p_value), "&",
      format(r$n_eff, big.mark = ","), "\\\\\n")
}
cat("\\multicolumn{6}{l}{\\textit{Panel C: Donut RDD ($\\pm 25$ excluded)}} \\\\\n")
donut_viirs <- donut_results[grepl("viirs", outcome)]
for (i in 1:nrow(donut_viirs)) {
  r <- donut_viirs[i]
  label <- gsub("donut_viirs_", "VIIRS ", r$outcome)
  cat("&", label, "&", sprintf("%.4f", r$estimate), "&",
      sprintf("(%.4f)", r$se), "&",
      sprintf("%.3f", r$p_value), "&",
      format(r$n_eff, big.mark = ","), "\\\\\n")
}
cat("\\hline\\hline\n\\end{tabular}\n")
cat("\\begin{tablenotes}\\small\n")
cat("\\item \\textit{Notes:} All specifications use $\\text{asinh}(\\text{VIIRS nightlights})$ as the dependent variable and Census 2001 population as the running variable. Panel A varies the bandwidth around the MSE-optimal choice ($h^* = 107.8$); bandwidths are forced via \\texttt{rdrobust(h=...)}, which may yield different bias bandwidths and thus different SE/p-values than Table~\\ref{tab:main_rdd} (which uses automatic bandwidth selection). Panel B varies the polynomial order with MSE-optimal bandwidth. Panel C excludes villages within $\\pm 25$ persons of the 500 threshold to address heaping.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()
cat("  Saved tab5_robustness.tex\n")

cat("\n=== All tables generated ===\n")
