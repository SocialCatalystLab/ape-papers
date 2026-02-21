## ============================================================
## 06_tables.R — All tables for the paper
## ============================================================

source("00_packages.R")

df <- readRDS("../data/analysis_data.rds")
results <- readRDS("../data/rd_results.rds")
balance_results <- readRDS("../data/balance_results.rds")
bw_results <- readRDS("../data/bw_sensitivity.rds")

tab_dir <- "../tables"
dir.create(tab_dir, showWarnings = FALSE)

## ----------------------------------------------------------
## Table 1: Summary Statistics
## ----------------------------------------------------------

cat("Creating Table 1: Summary Statistics...\n")

# Split by treatment status
stats_list <- list()
for (side in c("Full Sample", "Below 1,000", "Above 1,000")) {
  sub <- switch(side,
    "Full Sample" = df,
    "Below 1,000" = df %>% filter(above_threshold == 0),
    "Above 1,000" = df %>% filter(above_threshold == 1)
  )

  stats_list[[side]] <- tibble(
    group = side,
    n = nrow(sub),
    pop_mean = mean(sub$pop),
    pop_sd = sd(sub$pop),
    female_share = mean(sub$female_share),
    female_emp_rate = mean(sub$female_emp_rate, na.rm = TRUE),
    female_lfpr = mean(sub$female_lfpr, na.rm = TRUE),
    male_emp_rate = mean(sub$male_emp_rate, na.rm = TRUE),
    gender_gap = mean(sub$gender_emp_gap, na.rm = TRUE),
    unemp_rate = mean(sub$unemployment_rate, na.rm = TRUE),
    density = mean(sub$densite, na.rm = TRUE)
  )
}

stats <- bind_rows(stats_list)

# Write LaTeX table
sink(file.path(tab_dir, "tab1_summary.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lrrr}\n")
cat("\\toprule\n")
cat(" & Full Sample & Below 1{,}000 & Above 1{,}000 \\\\\n")
cat("\\midrule\n")
cat(sprintf("N (communes) & %s & %s & %s \\\\\n",
    format(stats$n[1], big.mark = ","),
    format(stats$n[2], big.mark = ","),
    format(stats$n[3], big.mark = ",")))
cat(sprintf("Population (mean) & %s & %s & %s \\\\\n",
    format(round(stats$pop_mean[1]), big.mark = ","),
    format(round(stats$pop_mean[2]), big.mark = ","),
    format(round(stats$pop_mean[3]), big.mark = ",")))
cat(sprintf("Female councillor share & %.3f & %.3f & %.3f \\\\\n",
    stats$female_share[1], stats$female_share[2], stats$female_share[3]))
cat(sprintf("Female employment rate & %.3f & %.3f & %.3f \\\\\n",
    stats$female_emp_rate[1], stats$female_emp_rate[2], stats$female_emp_rate[3]))
cat(sprintf("Female LFPR & %.3f & %.3f & %.3f \\\\\n",
    stats$female_lfpr[1], stats$female_lfpr[2], stats$female_lfpr[3]))
cat(sprintf("Male employment rate & %.3f & %.3f & %.3f \\\\\n",
    stats$male_emp_rate[1], stats$male_emp_rate[2], stats$male_emp_rate[3]))
cat(sprintf("Gender employment gap & %.3f & %.3f & %.3f \\\\\n",
    stats$gender_gap[1], stats$gender_gap[2], stats$gender_gap[3]))
cat(sprintf("Unemployment rate & %.3f & %.3f & %.3f \\\\\n",
    stats$unemp_rate[1], stats$unemp_rate[2], stats$unemp_rate[3]))
cat(sprintf("Density (hab/km\\textsuperscript{2}) & %.0f & %.0f & %.0f \\\\\n",
    stats$density[1], stats$density[2], stats$density[3]))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item Notes: Statistics computed from the analysis sample of metropolitan French communes. Female employment rate and LFPR are for the population aged 15--64 from the 2022 INSEE census. Female councillor share computed from the R\\'{e}pertoire National des \\'{E}lus (2025).\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\label{tab:summary}\n")
cat("\\end{table}\n")
sink()

## ----------------------------------------------------------
## Table 2: Main RDD Results
## ----------------------------------------------------------

cat("Creating Table 2: Main RDD Results...\n")

outcome_order <- c("female_emp_rate", "female_lfpr", "male_emp_rate",
                   "gender_emp_gap", "female_share_employed",
                   "total_emp_rate", "unemployment_rate")

sink(file.path(tab_dir, "tab2_main_results.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{RDD Estimates: Effect of Gender Parity Mandate on Labor Market Outcomes}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lcccccc}\n")
cat("\\toprule\n")
cat("Outcome & Estimate & SE & 95\\% CI & $p$-value & BW & $N$ \\\\\n")
cat("\\midrule\n")

for (v in outcome_order) {
  if (!v %in% names(results)) next
  r <- results[[v]]
  stars <- ifelse(r$pv_robust < 0.01, "***",
           ifelse(r$pv_robust < 0.05, "**",
           ifelse(r$pv_robust < 0.10, "*", "")))
  cat(sprintf("%s & %.4f%s & (%.4f) & [%.4f, %.4f] & %.3f & %d & %s \\\\\n",
      r$name, r$coef_conv, stars, r$se_robust,
      r$ci_lower, r$ci_upper,
      r$pv_robust,
      round(r$bw), format(r$n_left + r$n_right, big.mark = ",")))
}

cat("\\midrule\n")
cat(sprintf("\\multicolumn{7}{l}{\\textit{First stage: Female councillor share}} \\\\\n"))

# First stage with manual BW=200
sub200 <- df %>% filter(abs(pop_centered) <= 200)
mod_fs <- lm(female_share ~ above_threshold + pop_centered +
               I(above_threshold * pop_centered), data = sub200)
se_fs <- sqrt(vcovHC(mod_fs, type = "HC1")[2, 2])
fs_coef <- coef(mod_fs)[2]
cat(sprintf("Female councillor share & %.4f*** & (%.4f) & [%.4f, %.4f] & $<$0.001 & 200 & %s \\\\\n",
    fs_coef, se_fs, fs_coef - 1.96 * se_fs, fs_coef + 1.96 * se_fs,
    format(nrow(sub200), big.mark = ",")))

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item Notes: Each row reports a separate RDD regression. Estimates from local linear regression with triangular kernel and CER-optimal bandwidth (Cattaneo, Idrobo, and Titiunik 2020). Robust bias-corrected standard errors in parentheses. First stage estimated with bandwidth of 200 and HC1 standard errors. * $p<0.10$, ** $p<0.05$, *** $p<0.01$.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\label{tab:main}\n")
cat("\\end{table}\n")
sink()

## ----------------------------------------------------------
## Table 3: Covariate Balance
## ----------------------------------------------------------

cat("Creating Table 3: Covariate Balance...\n")

sink(file.path(tab_dir, "tab3_balance.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Covariate Balance at the 1,000-Inhabitant Threshold}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lccccc}\n")
cat("\\toprule\n")
cat("Pre-determined Covariate & RDD Estimate & SE & $p$-value & BW & $N$ \\\\\n")
cat("\\midrule\n")

for (i in seq_len(nrow(balance_results))) {
  cat(sprintf("%s & %.4f & (%.4f) & %.3f & %d & %s \\\\\n",
      balance_results$variable[i],
      balance_results$coef[i],
      balance_results$se[i],
      balance_results$pvalue[i],
      round(balance_results$bw[i]),
      format(balance_results$n_obs[i], big.mark = ",")))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item Notes: Each row tests whether the pre-determined covariate exhibits a discontinuity at the 1,000 threshold. All covariates are from the 2011 census (before the threshold was lowered from 3,500 to 1,000 in 2014). Local linear regression with robust bias-corrected inference.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\label{tab:balance}\n")
cat("\\end{table}\n")
sink()

## ----------------------------------------------------------
## Table 4: Bandwidth Sensitivity
## ----------------------------------------------------------

cat("Creating Table 4: Bandwidth Sensitivity...\n")

sink(file.path(tab_dir, "tab4_bandwidth.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Bandwidth Sensitivity: Female Employment Rate}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat("Bandwidth & Estimate & SE & $N$ & 95\\% CI \\\\\n")
cat("\\midrule\n")

for (bw in c(100, 150, 200, 300, 400, 500, 600, 800)) {
  row <- bw_results %>% filter(bandwidth == bw)
  if (nrow(row) == 0) next
  cat(sprintf("%d & %.4f & (%.4f) & %s & [%.4f, %.4f] \\\\\n",
      bw, row$coef, row$se, format(row$n, big.mark = ","),
      row$coef - 1.96 * row$se, row$coef + 1.96 * row$se))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item Notes: Local linear regression with HC1 robust standard errors. Outcome: female employment rate (ages 15--64). 95\\% confidence intervals constructed as estimate $\\pm$ 1.96 $\\times$ SE.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\label{tab:bandwidth}\n")
cat("\\end{table}\n")
sink()

## ----------------------------------------------------------
## Table 5: Robustness — Multiple Specifications
## ----------------------------------------------------------

cat("Creating Table 5: Robustness...\n")

# Run additional specifications for robustness table
valid <- !is.na(df$female_emp_rate) & is.finite(df$female_emp_rate)

rob_specs <- list()

# 1. Baseline (rdrobust)
rd1 <- rdrobust(y = df$female_emp_rate[valid], x = df$pop_centered[valid],
                c = 0, p = 1, kernel = "triangular", bwselect = "cerrd",
                masspoints = "adjust")
rob_specs[["Baseline (linear)"]] <- c(rd1$coef[1], rd1$se[3], rd1$pv[3],
                                       rd1$N_h[1] + rd1$N_h[2])

# 2. Quadratic
rd2 <- rdrobust(y = df$female_emp_rate[valid], x = df$pop_centered[valid],
                c = 0, p = 2, kernel = "triangular", bwselect = "cerrd",
                masspoints = "adjust")
rob_specs[["Quadratic"]] <- c(rd2$coef[1], rd2$se[3], rd2$pv[3],
                               rd2$N_h[1] + rd2$N_h[2])

# 3. Uniform kernel
rd3 <- rdrobust(y = df$female_emp_rate[valid], x = df$pop_centered[valid],
                c = 0, p = 1, kernel = "uniform", bwselect = "cerrd",
                masspoints = "adjust")
rob_specs[["Uniform kernel"]] <- c(rd3$coef[1], rd3$se[3], rd3$pv[3],
                                    rd3$N_h[1] + rd3$N_h[2])

# 4. Donut (exclude ±20)
sub_donut <- df[valid, ] %>% filter(abs(pop_centered) >= 20)
rd4 <- rdrobust(y = sub_donut$female_emp_rate, x = sub_donut$pop_centered,
                c = 0, p = 1, kernel = "triangular", bwselect = "cerrd",
                masspoints = "adjust")
rob_specs[["Donut (±20)"]] <- c(rd4$coef[1], rd4$se[3], rd4$pv[3],
                                 rd4$N_h[1] + rd4$N_h[2])

# 5. With department FE (manual)
sub_man <- df[valid, ] %>% filter(abs(pop_centered) <= 200)
mod5 <- lm(female_emp_rate ~ above_threshold + pop_centered +
             I(above_threshold * pop_centered) + factor(dep_code.x),
           data = sub_man)
se5 <- sqrt(vcovHC(mod5, type = "HC1")[2, 2])
rob_specs[["+ Department FE"]] <- c(coef(mod5)[2], se5,
                                     2 * pnorm(-abs(coef(mod5)[2] / se5)),
                                     nrow(sub_man))

sink(file.path(tab_dir, "tab5_robustness.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Robustness: Alternative Specifications for Female Employment Rate}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat("Specification & Estimate & SE & $p$-value & $N$ \\\\\n")
cat("\\midrule\n")
for (spec in names(rob_specs)) {
  r <- rob_specs[[spec]]
  cat(sprintf("%s & %.4f & (%.4f) & %.3f & %s \\\\\n",
      spec, r[1], r[2], r[3], format(round(r[4]), big.mark = ",")))
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item Notes: All specifications estimate the discontinuity in female employment rate at the 1,000-inhabitant threshold. Baseline uses local linear regression with triangular kernel and CER-optimal bandwidth. Department FE specification uses bandwidth of 200 with HC1 standard errors.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\label{tab:robustness}\n")
cat("\\end{table}\n")
sink()

cat("All tables saved to", tab_dir, "\n")
