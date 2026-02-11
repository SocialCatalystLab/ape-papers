################################################################################
# 06_tables.R — LaTeX Tables for ARC RDD
# ARC Distressed County Designation RDD (apep_0217)
#
# Tables:
#   1. Summary statistics
#   2. Main RDD results
#   3. Robustness checks
#   4. Covariate balance
#   5. Year-by-year estimates
################################################################################

source("00_packages.R")

data_dir <- "../data"
tab_dir <- "../tables"
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

################################################################################
# Load data and results
################################################################################

arc <- readRDS(file.path(data_dir, "arc_analysis.rds"))
panel <- readRDS(file.path(data_dir, "arc_panel_full.rds"))
main_results <- readRDS(file.path(data_dir, "main_results.rds"))
rob_results <- readRDS(file.path(data_dir, "robustness_results.rds"))

outcomes <- c("unemp_rate_arc", "log_pcmi", "poverty_rate_arc")
outcome_labels <- c("Unemployment Rate (\\%)",
                     "Log Per Capita Market Income",
                     "Poverty Rate (\\%)")
names(outcome_labels) <- outcomes

# Helper: format p-value stars
stars <- function(p) {
  ifelse(p < 0.01, "^{***}",
         ifelse(p < 0.05, "^{**}",
                ifelse(p < 0.10, "^{*}", "")))
}

# Helper: format coefficient
fmt_coef <- function(coef, se, pv) {
  sprintf("%.3f%s", coef, stars(pv))
}

# Helper: format SE in parentheses
fmt_se <- function(se) {
  sprintf("(%.3f)", se)
}

################################################################################
# 1. Summary Statistics Table
################################################################################

cat("--- Table 1: Summary Statistics ---\n")

# Full sample
full_stats <- arc %>%
  summarize(
    N = n(),
    mean_unemp = mean(unemp_rate_arc, na.rm = TRUE),
    sd_unemp = sd(unemp_rate_arc, na.rm = TRUE),
    mean_pcmi = mean(pcmi, na.rm = TRUE),
    sd_pcmi = sd(pcmi, na.rm = TRUE),
    mean_poverty = mean(poverty_rate_arc, na.rm = TRUE),
    sd_poverty = sd(poverty_rate_arc, na.rm = TRUE),
    mean_civ = mean(civ, na.rm = TRUE),
    sd_civ = sd(civ, na.rm = TRUE)
  )

# Near threshold by treatment status
near_stats <- arc %>%
  filter(abs(civ_centered) <= 15) %>%
  group_by(distressed) %>%
  summarize(
    N = n(),
    mean_unemp = mean(unemp_rate_arc, na.rm = TRUE),
    sd_unemp = sd(unemp_rate_arc, na.rm = TRUE),
    mean_pcmi = mean(pcmi, na.rm = TRUE),
    sd_pcmi = sd(pcmi, na.rm = TRUE),
    mean_poverty = mean(poverty_rate_arc, na.rm = TRUE),
    sd_poverty = sd(poverty_rate_arc, na.rm = TRUE),
    mean_civ = mean(civ, na.rm = TRUE),
    sd_civ = sd(civ, na.rm = TRUE),
    .groups = "drop"
  )

at_risk <- near_stats %>% filter(distressed == 0)
distressed <- near_stats %>% filter(distressed == 1)

# Build LaTeX
tab1 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Summary Statistics}",
  "\\label{tab:summary}",
  "\\begin{tabular}{lccc}",
  "\\toprule",
  " & Full Sample & \\multicolumn{2}{c}{Near Threshold ($|\\text{CIV} - c| \\leq 15$)} \\\\",
  "\\cmidrule(lr){3-4}",
  " & & At-Risk & Distressed \\\\",
  "\\midrule",
  sprintf("\\textit{N (county-years)} & %s & %s & %s \\\\",
          format(full_stats$N, big.mark = ","),
          format(at_risk$N, big.mark = ","),
          format(distressed$N, big.mark = ",")),
  " & & & \\\\",
  "\\textit{Panel A: Outcomes} & & & \\\\[3pt]",
  sprintf("Unemployment rate (\\%%) & %.2f & %.2f & %.2f \\\\",
          full_stats$mean_unemp, at_risk$mean_unemp, distressed$mean_unemp),
  sprintf(" & (%.2f) & (%.2f) & (%.2f) \\\\",
          full_stats$sd_unemp, at_risk$sd_unemp, distressed$sd_unemp),
  sprintf("Per capita market income (\\$) & %s & %s & %s \\\\",
          format(round(full_stats$mean_pcmi), big.mark = ","),
          format(round(at_risk$mean_pcmi), big.mark = ","),
          format(round(distressed$mean_pcmi), big.mark = ",")),
  sprintf(" & (%s) & (%s) & (%s) \\\\",
          format(round(full_stats$sd_pcmi), big.mark = ","),
          format(round(at_risk$sd_pcmi), big.mark = ","),
          format(round(distressed$sd_pcmi), big.mark = ",")),
  sprintf("Poverty rate (\\%%) & %.2f & %.2f & %.2f \\\\",
          full_stats$mean_poverty, at_risk$mean_poverty, distressed$mean_poverty),
  sprintf(" & (%.2f) & (%.2f) & (%.2f) \\\\",
          full_stats$sd_poverty, at_risk$sd_poverty, distressed$sd_poverty),
  " & & & \\\\",
  "\\textit{Panel B: Running Variable} & & & \\\\[3pt]",
  sprintf("Composite Index Value (CIV) & %.1f & %.1f & %.1f \\\\",
          full_stats$mean_civ, at_risk$mean_civ, distressed$mean_civ),
  sprintf(" & (%.1f) & (%.1f) & (%.1f) \\\\",
          full_stats$sd_civ, at_risk$sd_civ, distressed$sd_civ),
  "\\midrule",
  sprintf("Counties & %d & \\multicolumn{2}{c}{%d} \\\\",
          n_distinct(arc$fips),
          n_distinct(arc %>% filter(abs(civ_centered) <= 15) %>% pull(fips))),
  sprintf("Fiscal years & %d---%d & \\multicolumn{2}{c}{%d---%d} \\\\",
          min(arc$fiscal_year), max(arc$fiscal_year),
          min(arc$fiscal_year), max(arc$fiscal_year)),
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} Standard deviations in parentheses. Full sample includes all ARC county-years within $\\pm 50$ CIV points of the Distressed threshold. Near-threshold sample restricted to $\\pm 15$ CIV points. Unemployment rate and poverty rate are ARC three-year averages used in the CIV calculation. Per capita market income is in nominal dollars.",
  "\\end{tablenotes}",
  "\\end{table}"
)

writeLines(tab1, file.path(tab_dir, "tab_summary.tex"))
cat("  Saved tab_summary.tex\n")

################################################################################
# 2. Main RDD Results Table
################################################################################

cat("--- Table 2: Main RDD Results ---\n")

tab2 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Main RDD Results: Effect of ARC Distressed Designation}",
  "\\label{tab:main_results}",
  "\\begin{tabular}{lcccccc}",
  "\\toprule",
  " & \\multicolumn{3}{c}{Pooled Cross-Sectional} & \\multicolumn{3}{c}{Panel (Year FE)} \\\\",
  "\\cmidrule(lr){2-4} \\cmidrule(lr){5-7}",
  " & Unemp. & Log PCMI & Poverty & Unemp. & Log PCMI & Poverty \\\\",
  " & Rate & & Rate & Rate & & Rate \\\\",
  "\\midrule"
)

# Row: RD estimate (robust)
coefs_pooled <- sapply(outcomes, function(y) {
  r <- main_results$pooled[[y]]
  fmt_coef(r$coef_robust, r$se_robust, r$pv_robust)
})
coefs_panel <- sapply(outcomes, function(y) {
  r <- main_results$panel[[y]]
  fmt_coef(r$coef_robust, r$se_robust, r$pv_robust)
})
tab2 <- c(tab2,
  sprintf("RD estimate & $%s$ & $%s$ & $%s$ & $%s$ & $%s$ & $%s$ \\\\",
          coefs_pooled[1], coefs_pooled[2], coefs_pooled[3],
          coefs_panel[1], coefs_panel[2], coefs_panel[3]))

# Row: SE
ses_pooled <- sapply(outcomes, function(y) fmt_se(main_results$pooled[[y]]$se_robust))
ses_panel <- sapply(outcomes, function(y) fmt_se(main_results$panel[[y]]$se_robust))
tab2 <- c(tab2,
  sprintf(" & $%s$ & $%s$ & $%s$ & $%s$ & $%s$ & $%s$ \\\\",
          ses_pooled[1], ses_pooled[2], ses_pooled[3],
          ses_panel[1], ses_panel[2], ses_panel[3]))

# Blank row
tab2 <- c(tab2, " & & & & & & \\\\")

# Row: Bandwidth
bws_pooled <- sapply(outcomes, function(y) sprintf("%.1f", main_results$pooled[[y]]$bw_h))
bws_panel <- sapply(outcomes, function(y) sprintf("%.1f", main_results$panel[[y]]$bw_h))
tab2 <- c(tab2,
  sprintf("Bandwidth ($h$) & %s & %s & %s & %s & %s & %s \\\\",
          bws_pooled[1], bws_pooled[2], bws_pooled[3],
          bws_panel[1], bws_panel[2], bws_panel[3]))

# Row: N effective
ns_pooled <- sapply(outcomes, function(y) {
  r <- main_results$pooled[[y]]
  format(r$N_total, big.mark = ",")
})
ns_panel <- sapply(outcomes, function(y) {
  r <- main_results$panel[[y]]
  format(r$N_total, big.mark = ",")
})
tab2 <- c(tab2,
  sprintf("Eff. observations & %s & %s & %s & %s & %s & %s \\\\",
          ns_pooled[1], ns_pooled[2], ns_pooled[3],
          ns_panel[1], ns_panel[2], ns_panel[3]))

# Row: control mean
ctrl_means <- sapply(outcomes, function(y) {
  m <- mean(arc[[y]][arc$distressed == 0 & abs(arc$civ_centered) <= 15], na.rm = TRUE)
  if (y == "pcmi") sprintf("%s", format(round(m), big.mark = ","))
  else sprintf("%.2f", m)
})
tab2 <- c(tab2,
  sprintf("Control mean & %s & %s & %s & %s & %s & %s \\\\",
          ctrl_means[1], ctrl_means[2], ctrl_means[3],
          ctrl_means[1], ctrl_means[2], ctrl_means[3]))

# Details rows
tab2 <- c(tab2,
  "\\midrule",
  "Year FE & No & No & No & Yes & Yes & Yes \\\\",
  "Kernel & \\multicolumn{6}{c}{Triangular} \\\\",
  "BW selection & \\multicolumn{6}{c}{MSE-optimal (Calonico, Cattaneo, Titiunik 2014)} \\\\",
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  sprintf("\\item \\textit{Notes:} Robust bias-corrected estimates from \\texttt{rdrobust}. Standard errors in parentheses. $^{***}$, $^{**}$, $^{*}$ denote significance at 1\\%%, 5\\%%, 10\\%% levels. Panel specification residualizes both outcomes and the running variable on fiscal year fixed effects before estimation. Sample: ARC counties FY %d---%d within $\\pm 50$ CIV of the Distressed threshold.",
          min(arc$fiscal_year), max(arc$fiscal_year)),
  "\\end{tablenotes}",
  "\\end{table}"
)

writeLines(tab2, file.path(tab_dir, "tab_main_results.tex"))
cat("  Saved tab_main_results.tex\n")

################################################################################
# 3. Robustness Table
################################################################################

cat("--- Table 3: Robustness Checks ---\n")

tab3 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Robustness Checks}",
  "\\label{tab:robustness}",
  "\\small",
  "\\begin{tabular}{lccc}",
  "\\toprule",
  " & Unemployment & Log PCMI & Poverty \\\\",
  " & Rate & & Rate \\\\",
  "\\midrule",
  "\\textit{Panel A: Bandwidth Sensitivity} & & & \\\\"
)

# Bandwidth rows
for (mult in c(0.50, 0.75, 1.00, 1.25, 1.50)) {
  coefs <- sapply(outcomes, function(y) {
    key <- paste0(y, "_bw_", mult)
    r <- rob_results$bandwidth[[key]]
    if (is.null(r)) return("---")
    fmt_coef(r$coef_robust, r$se_robust, r$pv_robust)
  })
  ses <- sapply(outcomes, function(y) {
    key <- paste0(y, "_bw_", mult)
    r <- rob_results$bandwidth[[key]]
    if (is.null(r)) return("")
    fmt_se(r$se_robust)
  })
  label <- if (mult == 1.00) "Optimal bandwidth (1.0$\\times h$)"
           else sprintf("%.1f$\\times h$", mult)
  tab3 <- c(tab3,
    sprintf("\\quad %s & $%s$ & $%s$ & $%s$ \\\\", label, coefs[1], coefs[2], coefs[3]),
    sprintf("\\quad & $%s$ & $%s$ & $%s$ \\\\", ses[1], ses[2], ses[3])
  )
}

tab3 <- c(tab3, " & & & \\\\",
  "\\textit{Panel B: Donut Hole ($|\\text{CIV}| > 2$)} & & & \\\\")

# Donut results
coefs_donut <- sapply(outcomes, function(y) {
  r <- rob_results$donut[[y]]
  if (is.null(r)) return("---")
  fmt_coef(r$coef_robust, r$se_robust, r$pv_robust)
})
ses_donut <- sapply(outcomes, function(y) {
  r <- rob_results$donut[[y]]
  if (is.null(r)) return("")
  fmt_se(r$se_robust)
})
tab3 <- c(tab3,
  sprintf("\\quad Drop $\\pm 2$ CIV & $%s$ & $%s$ & $%s$ \\\\",
          coefs_donut[1], coefs_donut[2], coefs_donut[3]),
  sprintf("\\quad & $%s$ & $%s$ & $%s$ \\\\",
          ses_donut[1], ses_donut[2], ses_donut[3]))

tab3 <- c(tab3, " & & & \\\\",
  "\\textit{Panel C: Polynomial Order} & & & \\\\")

# Polynomial rows
for (p in c(1, 2)) {
  coefs_p <- sapply(outcomes, function(y) {
    key <- paste0(y, "_p", p)
    r <- rob_results$polynomial[[key]]
    if (is.null(r)) return("---")
    fmt_coef(r$coef_robust, r$se_robust, r$pv_robust)
  })
  ses_p <- sapply(outcomes, function(y) {
    key <- paste0(y, "_p", p)
    r <- rob_results$polynomial[[key]]
    if (is.null(r)) return("")
    fmt_se(r$se_robust)
  })
  poly_label <- if (p == 1) "Local linear ($p = 1$)" else "Local quadratic ($p = 2$)"
  tab3 <- c(tab3,
    sprintf("\\quad %s & $%s$ & $%s$ & $%s$ \\\\", poly_label, coefs_p[1], coefs_p[2], coefs_p[3]),
    sprintf("\\quad & $%s$ & $%s$ & $%s$ \\\\", ses_p[1], ses_p[2], ses_p[3])
  )
}

tab3 <- c(tab3,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} Robust bias-corrected RD estimates. Standard errors in parentheses. $^{***}$, $^{**}$, $^{*}$ denote significance at 1\\%, 5\\%, 10\\% levels. Triangular kernel throughout. Panel A varies the bandwidth relative to the MSE-optimal ($h$). Panel B excludes observations within $\\pm 2$ CIV of the threshold. Panel C compares local linear and local quadratic polynomial specifications.",
  "\\end{tablenotes}",
  "\\end{table}"
)

writeLines(tab3, file.path(tab_dir, "tab_robustness.tex"))
cat("  Saved tab_robustness.tex\n")

################################################################################
# 4. Covariate Balance Table
################################################################################

cat("--- Table 4: Covariate Balance ---\n")

tab4 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Covariate Balance at the Distressed Threshold}",
  "\\label{tab:balance}",
  "\\begin{tabular}{lccccc}",
  "\\toprule",
  "Predetermined Variable & RD Estimate & Robust SE & $p$-value & Bandwidth & Eff. $N$ \\\\",
  "\\midrule"
)

for (bvar in names(rob_results$balance)) {
  r <- rob_results$balance[[bvar]]
  if (is.null(r)) next

  tab4 <- c(tab4,
    sprintf("%s & $%s$ & $%s$ & %.3f & %.1f & %d \\\\",
            r$label,
            fmt_coef(r$coef_robust, r$se_robust, r$pv_robust),
            fmt_se(r$se_robust),
            r$pv_robust,
            r$bw_h,
            r$N_left + r$N_right))
}

# Add McCrary test
tab4 <- c(tab4,
  "\\midrule",
  sprintf("McCrary density test & $T = %.3f$ & & %.3f & & \\\\",
          rob_results$density$t_stat, rob_results$density$p_value))

tab4 <- c(tab4,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} Tests for discontinuities in predetermined (lagged) county characteristics at the ARC Distressed threshold. Robust bias-corrected estimates from \\texttt{rdrobust} with triangular kernel and MSE-optimal bandwidth. Lagged variables are the previous fiscal year's values. The McCrary test uses \\texttt{rddensity} to test for manipulation of the running variable. $^{***}$, $^{**}$, $^{*}$ denote significance at 1\\%, 5\\%, 10\\% levels. A null result (insignificant) supports the validity of the RD design.",
  "\\end{tablenotes}",
  "\\end{table}"
)

writeLines(tab4, file.path(tab_dir, "tab_balance.tex"))
cat("  Saved tab_balance.tex\n")

################################################################################
# 5. Year-by-Year Estimates Table
################################################################################

cat("--- Table 5: Year-by-Year Estimates ---\n")

years <- sort(unique(arc$fiscal_year))

tab5 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Year-by-Year RD Estimates}",
  "\\label{tab:yearly}",
  "\\begin{tabular}{lcccccc}",
  "\\toprule",
  " & \\multicolumn{2}{c}{Unemployment Rate} & \\multicolumn{2}{c}{Log PCMI} & \\multicolumn{2}{c}{Poverty Rate} \\\\",
  "\\cmidrule(lr){2-3} \\cmidrule(lr){4-5} \\cmidrule(lr){6-7}",
  "Fiscal Year & Estimate & $N$ & Estimate & $N$ & Estimate & $N$ \\\\",
  "\\midrule"
)

for (yr in years) {
  cells <- sapply(outcomes, function(y) {
    key <- paste0(y, "_", yr)
    r <- rob_results$yearly[[key]]
    if (is.null(r)) return(c("---", "---"))
    c(sprintf("$%s$", fmt_coef(r$coef_robust, r$se_robust, r$pv_robust)),
      format(r$N_left + r$N_right, big.mark = ","))
  })

  se_cells <- sapply(outcomes, function(y) {
    key <- paste0(y, "_", yr)
    r <- rob_results$yearly[[key]]
    if (is.null(r)) return("")
    sprintf("$%s$", fmt_se(r$se_robust))
  })

  tab5 <- c(tab5,
    sprintf("FY %d & %s & %s & %s & %s & %s & %s \\\\",
            yr, cells[1,1], cells[2,1], cells[1,2], cells[2,2], cells[1,3], cells[2,3]),
    sprintf(" & %s & & %s & & %s & \\\\",
            se_cells[1], se_cells[2], se_cells[3]))
}

tab5 <- c(tab5,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} Robust bias-corrected RD estimates from \\texttt{rdrobust}, estimated separately for each fiscal year. Triangular kernel with MSE-optimal bandwidth selected per year. Standard errors in parentheses. $N$ is the effective number of observations within the bandwidth. $^{***}$, $^{**}$, $^{*}$ denote significance at 1\\%, 5\\%, 10\\% levels.",
  "\\end{tablenotes}",
  "\\end{table}"
)

writeLines(tab5, file.path(tab_dir, "tab_yearly.tex"))
cat("  Saved tab_yearly.tex\n")

cat("\n=== All Tables Complete ===\n")
