## ── 06_tables.R ───────────────────────────────────────────────────────────
## Generate all tables for apep_0426
## ──────────────────────────────────────────────────────────────────────────

source("00_packages.R")

data_dir  <- "../data"
table_dir <- "../tables"

panel <- fread(file.path(data_dir, "analysis_panel_clean.csv"))
cross <- fread(file.path(data_dir, "district_cross_section.csv"))
results <- readRDS(file.path(data_dir, "main_results.rds"))

## ══════════════════════════════════════════════════════════════════════════
## Table 1: Summary Statistics by MGNREGA Phase
## ══════════════════════════════════════════════════════════════════════════

## Pre-treatment (year 2000) characteristics
pre <- panel[year == 2000, .(dist_code, nrega_phase, log_light, baseline_light,
                              pop_2001, sc_st_share, lit_rate, agri_labor_share)]

sumstats <- pre[, .(
  `Log Nightlights (2000)` = sprintf("%.3f (%.3f)", mean(log_light, na.rm = TRUE), sd(log_light, na.rm = TRUE)),
  `Population (2001, thousands)` = sprintf("%.0f (%.0f)", mean(pop_2001/1000, na.rm = TRUE), sd(pop_2001/1000, na.rm = TRUE)),
  `SC/ST Share` = sprintf("%.3f (%.3f)", mean(sc_st_share, na.rm = TRUE), sd(sc_st_share, na.rm = TRUE)),
  `Literacy Rate` = sprintf("%.3f (%.3f)", mean(lit_rate, na.rm = TRUE), sd(lit_rate, na.rm = TRUE)),
  `Agricultural Labor Share` = sprintf("%.3f (%.3f)", mean(agri_labor_share, na.rm = TRUE), sd(agri_labor_share, na.rm = TRUE)),
  `N Districts` = as.character(.N)
), by = nrega_phase]

setorder(sumstats, nrega_phase)
sumstats[, nrega_phase := paste0("Phase ", nrega_phase)]
sumstats_t <- t(sumstats[, -1])
colnames(sumstats_t) <- sumstats$nrega_phase

## Write LaTeX table
sink(file.path(table_dir, "tab1_summary.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics by MGNREGA Phase}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\toprule\n")
cat(" & Phase I & Phase II & Phase III \\\\\n")
cat("\\midrule\n")
for (i in 1:nrow(sumstats_t)) {
  cat(sprintf("%s & %s & %s & %s \\\\\n",
              rownames(sumstats_t)[i],
              sumstats_t[i, 1], sumstats_t[i, 2], sumstats_t[i, 3]))
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\\small\n")
cat("\\item \\textit{Notes:} Mean values with standard deviations in parentheses.")
cat(" Phase I districts (200) received MGNREGA in February 2006,")
cat(" Phase II (130) in April 2007, and Phase III (310) in April 2008.")
cat(" Phase assignment based on Planning Commission's composite backwardness index")
cat(" constructed from Census 2001 SC/ST share, agricultural labor share, and inverse literacy rate.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()
cat("✓ Table 1 saved\n")

## ══════════════════════════════════════════════════════════════════════════
## Table 2: Main Results (TWFE + CS-DiD + Sun-Abraham)
## ══════════════════════════════════════════════════════════════════════════

## Use modelsummary for regression table
models <- list(
  "TWFE" = results$twfe,
  "State\\times Year FE" = results$twfe_sxy,
  "TWFE + Controls" = results$twfe_ctrl,
  "Sun-Abraham" = results$sa
)

## Overall CS-DiD ATT
cs_att <- results$cs_agg$overall.att
cs_se <- results$cs_agg$overall.se

sink(file.path(table_dir, "tab2_main_results.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Effect of MGNREGA on District Nightlights}\n")
cat("\\label{tab:main}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat(" & (1) & (2) & (3) & (4) \\\\\n")
cat(" & TWFE & State$\\times$Year FE & TWFE + Controls & Sun-Abraham \\\\\n")
cat("\\midrule\n")
## Sun-Abraham: aggregate ATT from summary
sa_summ <- summary(results$sa, agg = "ATT")
sa_coef <- sa_summ$coeftable[1, 1]
sa_se   <- sa_summ$coeftable[1, 2]

## Helper: add significance stars
add_stars <- function(coef, se) {
  tstat <- abs(coef / se)
  pval <- 2 * pt(tstat, df = Inf, lower.tail = FALSE)
  stars <- ifelse(pval < 0.01, "$^{***}$",
           ifelse(pval < 0.05, "$^{**}$",
           ifelse(pval < 0.10, "$^{*}$", "")))
  sprintf("%.4f%s", coef, stars)
}

cat(sprintf("Treated & %s & %s & %s & %s \\\\\n",
            add_stars(coef(results$twfe)["treated"], se(results$twfe)["treated"]),
            add_stars(coef(results$twfe_sxy)["treated"], se(results$twfe_sxy)["treated"]),
            add_stars(coef(results$twfe_ctrl)["treated"], se(results$twfe_ctrl)["treated"]),
            add_stars(sa_coef, sa_se)))
cat(sprintf(" & (%.4f) & (%.4f) & (%.4f) & (%.4f) \\\\\n",
            se(results$twfe)["treated"],
            se(results$twfe_sxy)["treated"],
            se(results$twfe_ctrl)["treated"],
            sa_se))
cat("\\midrule\n")
cat(sprintf("Callaway-Sant'Anna ATT & \\multicolumn{4}{c}{%.4f (%.4f)} \\\\\n",
            cs_att, cs_se))
cat("\\midrule\n")
cat("District FE & Yes & Yes & Yes & Yes \\\\\n")
cat("Year FE & Yes & -- & Yes & Yes \\\\\n")
cat("State$\\times$Year FE & -- & Yes & -- & -- \\\\\n")
cat("Baseline Controls$\\times$Year & -- & -- & Yes & -- \\\\\n")
cat(sprintf("Observations & %s & %s & %s & %s \\\\\n",
            format(nobs(results$twfe), big.mark = ","),
            format(nobs(results$twfe_sxy), big.mark = ","),
            format(nobs(results$twfe_ctrl), big.mark = ","),
            format(nobs(results$sa), big.mark = ",")))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\\small\n")
cat("\\item \\textit{Notes:} Dependent variable is log(nightlights + 1).")
cat(" Standard errors clustered at the state level in parentheses.")
cat(" The Callaway-Sant'Anna estimate uses regression-based estimation")
cat(" with not-yet-treated districts as controls.")
cat(" The 2006 treatment cohort returns missing group-time ATTs due to limited not-yet-treated")
cat(" controls after conditioning; the overall CS-DiD ATT is primarily identified from the 2007 and 2008 cohorts.")
cat(" $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.1$.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()
cat("✓ Table 2 saved\n")

## ══════════════════════════════════════════════════════════════════════════
## Table 3: Structural Transformation (Cross-Section)
## ══════════════════════════════════════════════════════════════════════════

sink(file.path(table_dir, "tab3_structural.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{MGNREGA and Structural Transformation (Census 2001--2011)}\n")
cat("\\label{tab:structural}\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\toprule\n")
cat(" & (1) & (2) & (3) \\\\\n")
cat(" & $\\Delta$ Non-Farm Share & $\\Delta$ Agricultural Share & Pop. Growth \\\\\n")
cat("\\midrule\n")

## Extract coefficients
struct_coefs <- coef(results$struct)
struct_se <- se(results$struct)
agri_coefs <- coef(results$agri)
agri_se <- se(results$agri)
pop_coefs <- coef(results$pop)
pop_se <- se(results$pop)

for (i in seq_along(struct_coefs)) {
  nm <- names(struct_coefs)[i]
  label <- gsub("nrega_phase::", "Phase ", nm)
  cat(sprintf("%s & %.4f & %.4f & %.4f \\\\\n",
              label, struct_coefs[i], agri_coefs[i], pop_coefs[i]))
  cat(sprintf(" & (%.4f) & (%.4f) & (%.4f) \\\\\n",
              struct_se[i], agri_se[i], pop_se[i]))
}

cat("\\midrule\n")
cat("State FE & Yes & Yes & Yes \\\\\n")
cat(sprintf("Observations & %d & %d & %d \\\\\n",
            nobs(results$struct), nobs(results$agri), nobs(results$pop)))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\\small\n")
cat("\\item \\textit{Notes:} Cross-sectional OLS regressions.")
cat(" Reference category: Phase III districts.")
cat(" $\\Delta$ Non-Farm Share is the change in the proportion of main workers")
cat(" in household industry and other non-agricultural occupations (2001--2011).")
cat(" Standard errors clustered at the state level in parentheses.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()
cat("✓ Table 3 saved\n")

## ══════════════════════════════════════════════════════════════════════════
## Table 4: Heterogeneity Results
## ══════════════════════════════════════════════════════════════════════════

het_results <- list()
for (q in c("Q1 (darkest)", "Q2", "Q3", "Q4 (brightest)")) {
  sub <- panel[dev_quartile == q]
  m <- feols(log_light ~ treated | dist_code + year,
             data = sub, cluster = ~state_code)
  het_results[[q]] <- data.table(
    quartile = q,
    coef = coef(m)["treated"],
    se = se(m)["treated"],
    n = nobs(m)
  )
}
het_dt <- rbindlist(het_results)

sink(file.path(table_dir, "tab4_heterogeneity.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Heterogeneous Effects by Baseline Development}\n")
cat("\\label{tab:heterogeneity}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat(" & Q1 (Darkest) & Q2 & Q3 & Q4 (Brightest) \\\\\n")
cat("\\midrule\n")
cat(sprintf("MGNREGA & %.4f & %.4f & %.4f & %.4f \\\\\n",
            het_dt$coef[1], het_dt$coef[2], het_dt$coef[3], het_dt$coef[4]))
cat(sprintf(" & (%.4f) & (%.4f) & (%.4f) & (%.4f) \\\\\n",
            het_dt$se[1], het_dt$se[2], het_dt$se[3], het_dt$se[4]))
cat("\\midrule\n")
cat(sprintf("Observations & %s & %s & %s & %s \\\\\n",
            format(het_dt$n[1], big.mark = ","),
            format(het_dt$n[2], big.mark = ","),
            format(het_dt$n[3], big.mark = ","),
            format(het_dt$n[4], big.mark = ",")))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\\small\n")
cat("\\item \\textit{Notes:} TWFE regressions by quartile of baseline nightlight intensity (year 2000).")
cat(" Dependent variable is log(nightlights + 1). District and year fixed effects included.")
cat(" Standard errors clustered at the state level.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()
cat("✓ Table 4 saved\n")

cat("\n✓ All tables generated.\n")
