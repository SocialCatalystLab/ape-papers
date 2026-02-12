## =============================================================================
## 06_tables.R — LaTeX tables for paper
## APEP Working Paper apep_0232
## =============================================================================

source("00_packages.R")

data_dir <- "../data"
tab_dir <- "../tables"
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

results <- readRDS(file.path(data_dir, "main_results.rds"))
robust <- readRDS(file.path(data_dir, "robust_results.rds"))
panel <- results$panel

## ---------------------------------------------------------------------------
## Table 1: Summary Statistics
## ---------------------------------------------------------------------------

cat("Table 1: Summary statistics...\n")

# Compute stats
stats_all <- panel %>%
  filter(!is.na(annual_avg_emplvl_healthcare)) %>%
  summarise(
    hc_emp_mean = mean(annual_avg_emplvl_healthcare / 1000, na.rm = TRUE),
    hc_emp_sd = sd(annual_avg_emplvl_healthcare / 1000, na.rm = TRUE),
    amb_emp_mean = mean(annual_avg_emplvl_ambulatory / 1000, na.rm = TRUE),
    amb_emp_sd = sd(annual_avg_emplvl_ambulatory / 1000, na.rm = TRUE),
    hosp_emp_mean = mean(annual_avg_emplvl_hospitals / 1000, na.rm = TRUE),
    hosp_emp_sd = sd(annual_avg_emplvl_hospitals / 1000, na.rm = TRUE),
    hc_estabs_mean = mean(annual_avg_estabs_count_healthcare / 1000, na.rm = TRUE),
    hc_estabs_sd = sd(annual_avg_estabs_count_healthcare / 1000, na.rm = TRUE),
    hc_pay_mean = mean(avg_annual_pay_healthcare / 1000, na.rm = TRUE),
    hc_pay_sd = sd(avg_annual_pay_healthcare / 1000, na.rm = TRUE),
    plc_emp_mean = mean(annual_avg_emplvl_placebo / 1000, na.rm = TRUE),
    plc_emp_sd = sd(annual_avg_emplvl_placebo / 1000, na.rm = TRUE),
    wfh_mean = mean(wfh_share * 100, na.rm = TRUE),
    wfh_sd = sd(wfh_share * 100, na.rm = TRUE),
    N = n()
  )

# Balance by treatment status (pre-2017)
balance <- panel %>%
  filter(year < 2017, !is.na(annual_avg_emplvl_healthcare)) %>%
  group_by(ever_treated = ifelse(imlc_year > 0, "Treated", "Control")) %>%
  summarise(
    hc_emp = mean(annual_avg_emplvl_healthcare / 1000, na.rm = TRUE),
    amb_emp = mean(annual_avg_emplvl_ambulatory / 1000, na.rm = TRUE),
    hosp_emp = mean(annual_avg_emplvl_hospitals / 1000, na.rm = TRUE),
    hc_estabs = mean(annual_avg_estabs_count_healthcare / 1000, na.rm = TRUE),
    hc_pay = mean(avg_annual_pay_healthcare / 1000, na.rm = TRUE),
    plc_emp = mean(annual_avg_emplvl_placebo / 1000, na.rm = TRUE),
    n_states = n_distinct(state_fips),
    .groups = "drop"
  )

# Write LaTeX
sink(file.path(tab_dir, "tab1_summary.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat("& \\multicolumn{2}{c}{Pre-2017 Means} & \\multicolumn{2}{c}{Full Sample} \\\\\n")
cat("\\cmidrule(lr){2-3} \\cmidrule(lr){4-5}\n")
cat("Variable & Eventually Treated & Never Treated & Mean & Std. Dev. \\\\\n")
cat("\\midrule\n")

treated <- balance %>% filter(ever_treated == "Treated")
control <- balance %>% filter(ever_treated == "Control")

cat(sprintf("Healthcare Employment (000s) & %.1f & %.1f & %.1f & %.1f \\\\\n",
            treated$hc_emp, control$hc_emp, stats_all$hc_emp_mean, stats_all$hc_emp_sd))
cat(sprintf("Ambulatory Employment (000s) & %.1f & %.1f & %.1f & %.1f \\\\\n",
            treated$amb_emp, control$amb_emp, stats_all$amb_emp_mean, stats_all$amb_emp_sd))
cat(sprintf("Hospital Employment (000s) & %.1f & %.1f & %.1f & %.1f \\\\\n",
            treated$hosp_emp, control$hosp_emp, stats_all$hosp_emp_mean, stats_all$hosp_emp_sd))
cat(sprintf("Healthcare Establishments (000s) & %.1f & %.1f & %.1f & %.1f \\\\\n",
            treated$hc_estabs, control$hc_estabs, stats_all$hc_estabs_mean, stats_all$hc_estabs_sd))
cat(sprintf("Avg. Annual Pay, Healthcare (\\$000s) & %.1f & %.1f & %.1f & %.1f \\\\\n",
            treated$hc_pay, control$hc_pay, stats_all$hc_pay_mean, stats_all$hc_pay_sd))
cat(sprintf("Placebo Employment (000s) & %.1f & %.1f & %.1f & %.1f \\\\\n",
            treated$plc_emp, control$plc_emp, stats_all$plc_emp_mean, stats_all$plc_emp_sd))
cat(sprintf("Work-from-Home Share (\\%%) & & & %.1f & %.1f \\\\\n",
            stats_all$wfh_mean, stats_all$wfh_sd))

cat("\\midrule\n")
cat(sprintf("States & %d & %d & %d & \\\\\n",
            treated$n_states, control$n_states, n_distinct(panel$state_fips)))
cat(sprintf("State-Years & & & %d & \\\\\n", stats_all$N))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Employment and establishment counts from BLS Quarterly Census of Employment and Wages (QCEW), 2012--2023. Work-from-home share from American Community Survey (ACS) 1-year estimates. Pre-2017 means compare states that eventually join the IMLC vs.\\ those that never join. All employment figures in thousands.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\end{table}\n")
sink()

## ---------------------------------------------------------------------------
## Table 2: Main Results — CS DiD
## ---------------------------------------------------------------------------

cat("Table 2: Main results...\n")

# Extract estimates
est <- read_csv(file.path(data_dir, "estimates_table.csv"), show_col_types = FALSE)

sink(file.path(tab_dir, "tab2_main_results.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Effect of IMLC Adoption on Healthcare Sector Outcomes}\n")
cat("\\label{tab:main}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lccccc}\n")
cat("\\toprule\n")
cat("& (1) & (2) & (3) & (4) & (5) \\\\\n")
cat("& HC Emp & Amb Emp & HC Estabs & Avg Pay & Amb Estabs \\\\\n")
cat("\\midrule\n")
cat("\\multicolumn{6}{l}{\\textit{Panel A: Callaway-Sant'Anna}} \\\\\n")
cat("[0.5em]\n")

for (i in 1:nrow(est)) {
  stars <- ifelse(est$CS_pval[i] < 0.01, "^{***}",
           ifelse(est$CS_pval[i] < 0.05, "^{**}",
           ifelse(est$CS_pval[i] < 0.10, "^{*}", "")))
  if (i == 1) {
    cat(sprintf("IMLC Adopted & $%.4f%s$ & $%.4f%s$ & $%.4f%s$ & $%.4f%s$ & $%.4f%s$ \\\\\n",
                est$CS_ATT[1], stars, est$CS_ATT[2],
                ifelse(est$CS_pval[2] < 0.01, "^{***}", ifelse(est$CS_pval[2] < 0.05, "^{**}", ifelse(est$CS_pval[2] < 0.10, "^{*}", ""))),
                est$CS_ATT[3],
                ifelse(est$CS_pval[3] < 0.01, "^{***}", ifelse(est$CS_pval[3] < 0.05, "^{**}", ifelse(est$CS_pval[3] < 0.10, "^{*}", ""))),
                est$CS_ATT[4],
                ifelse(est$CS_pval[4] < 0.01, "^{***}", ifelse(est$CS_pval[4] < 0.05, "^{**}", ifelse(est$CS_pval[4] < 0.10, "^{*}", ""))),
                est$CS_ATT[5],
                ifelse(est$CS_pval[5] < 0.01, "^{***}", ifelse(est$CS_pval[5] < 0.05, "^{**}", ifelse(est$CS_pval[5] < 0.10, "^{*}", "")))))
    cat(sprintf("& ($%.4f$) & ($%.4f$) & ($%.4f$) & ($%.4f$) & ($%.4f$) \\\\\n",
                est$CS_SE[1], est$CS_SE[2], est$CS_SE[3], est$CS_SE[4], est$CS_SE[5]))
    break
  }
}

cat("[0.5em]\n")
cat("\\multicolumn{6}{l}{\\textit{Panel B: TWFE (potentially biased)}} \\\\\n")
cat("[0.5em]\n")

twfe_coefs <- c(coef(results$twfe_hc)["treated"],
                coef(results$twfe_amb)["treated"],
                coef(results$twfe_estabs)["treated"],
                coef(results$twfe_pay)["treated"],
                coef(results$twfe_amb_estabs)["treated"])
twfe_ses <- c(se(results$twfe_hc)["treated"],
              se(results$twfe_amb)["treated"],
              se(results$twfe_estabs)["treated"],
              se(results$twfe_pay)["treated"],
              se(results$twfe_amb_estabs)["treated"])
twfe_pvals <- 2 * pnorm(-abs(twfe_coefs / twfe_ses))

twfe_str <- sapply(1:5, function(i) {
  if (is.na(twfe_coefs[i])) return("---")
  stars <- ifelse(twfe_pvals[i] < 0.01, "^{***}",
           ifelse(twfe_pvals[i] < 0.05, "^{**}",
           ifelse(twfe_pvals[i] < 0.10, "^{*}", "")))
  sprintf("$%.4f%s$", twfe_coefs[i], stars)
})
twfe_se_str <- sapply(1:5, function(i) {
  if (is.na(twfe_ses[i])) return("---")
  sprintf("($%.4f$)", twfe_ses[i])
})

cat(sprintf("IMLC Adopted & %s & %s & %s & %s & %s \\\\\n",
            twfe_str[1], twfe_str[2], twfe_str[3], twfe_str[4], twfe_str[5]))
cat(sprintf("& %s & %s & %s & %s & %s \\\\\n",
            twfe_se_str[1], twfe_se_str[2], twfe_se_str[3], twfe_se_str[4], twfe_se_str[5]))

cat("\\midrule\n")
n_obs <- nrow(panel %>% filter(!is.na(log_hc_emp)))
n_states <- n_distinct(panel$state_fips)
n_treated <- sum(panel %>% filter(year == 2017) %>% pull(imlc_year) > 0)
cat(sprintf("Observations & %d & %d & %d & %d & %d \\\\\n",
            n_obs, n_obs, n_obs, n_obs, n_obs))
cat(sprintf("States & %d & %d & %d & %d & %d \\\\\n",
            n_states, n_states, n_states, n_states, n_states))
cat(sprintf("Treated States & %d & %d & %d & %d & %d \\\\\n",
            n_treated, n_treated, n_treated, n_treated, n_treated))
cat("Control Group & \\multicolumn{5}{c}{Never-treated states} \\\\\n")
cat("Estimator & \\multicolumn{5}{c}{CS (Panel A) / TWFE (Panel B)} \\\\\n")
cat("Clustering & \\multicolumn{5}{c}{State} \\\\\n")
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Standard errors in parentheses, clustered at the state level. Panel A reports Callaway and Sant'Anna (2021) ATT estimates with never-treated states as the comparison group. Panel B reports standard two-way fixed effects (TWFE) estimates with state and year fixed effects, included for comparison. Outcomes are in logs. * $p<0.10$, ** $p<0.05$, *** $p<0.01$.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\end{table}\n")
sink()

## ---------------------------------------------------------------------------
## Table 3: Robustness checks
## ---------------------------------------------------------------------------

cat("Table 3: Robustness...\n")

robust_tab <- read_csv(file.path(data_dir, "robustness_table.csv"), show_col_types = FALSE)

sink(file.path(tab_dir, "tab3_robustness.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Robustness Checks}\n")
cat("\\label{tab:robust}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lccl}\n")
cat("\\toprule\n")
cat("Specification & ATT & SE & $p$-value \\\\\n")
cat("\\midrule\n")

for (i in 1:nrow(robust_tab)) {
  pv <- robust_tab$pval[i]
  stars_val <- as.character(robust_tab$stars[i])
  if (is.na(stars_val)) stars_val <- ""
  cat(sprintf("%s & $%.4f%s$ & ($%.4f$) & $%.3f$ \\\\\n",
              robust_tab$Specification[i], robust_tab$ATT[i], stars_val,
              robust_tab$SE[i], pv))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} All specifications estimate the effect of IMLC adoption on log outcomes using the Callaway-Sant'Anna estimator unless noted. ``Main'' uses never-treated states as the control group. ``Not-yet-treated'' uses states not yet in the IMLC as controls. Placebo tests use industries unrelated to healthcare licensing. * $p<0.10$, ** $p<0.05$, *** $p<0.01$.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\end{table}\n")
sink()

## ---------------------------------------------------------------------------
## Table 4: Event Study Coefficients
## ---------------------------------------------------------------------------

cat("Table 4: Event study coefficients...\n")

es <- results$es_hc_emp
es_df <- data.frame(
  time = es$egt,
  att = es$att.egt,
  se = es$se.egt
) %>%
  filter(time >= -5, time <= 6) %>%
  mutate(
    pval = 2 * pnorm(-abs(att / se)),
    stars = case_when(pval < 0.01 ~ "***", pval < 0.05 ~ "**",
                      pval < 0.10 ~ "*", TRUE ~ "")
  )

sink(file.path(tab_dir, "tab4_event_study.tex"))
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Event Study Coefficients: IMLC and Healthcare Employment}\n")
cat("\\label{tab:eventstudy}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\toprule\n")
cat("Event Time ($k$) & ATT & SE & $p$-value \\\\\n")
cat("\\midrule\n")

for (i in 1:nrow(es_df)) {
  if (i == 1 || (es_df$time[i] >= 0 && es_df$time[i-1] < 0)) {
    if (es_df$time[i] >= 0 && i > 1) {
      cat("\\midrule\n")
    }
  }
  # Handle reference period k=-1 specially
  if (es_df$time[i] == -1) {
    cat(sprintf("$k = %+d$ & $%.4f$ & --- & (ref.) \\\\\n",
                es_df$time[i], es_df$att[i]))
  } else {
    cat(sprintf("$k = %+d$ & $%.4f%s$ & ($%.4f$) & $%.3f$ \\\\\n",
                es_df$time[i], es_df$att[i], es_df$stars[i],
                es_df$se[i], es_df$pval[i]))
  }
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Callaway-Sant'Anna event study estimates for log healthcare employment. $k=0$ is the year of IMLC adoption. Pre-treatment coefficients ($k<0$) test parallel trends. Never-treated states as control group. * $p<0.10$, ** $p<0.05$, *** $p<0.01$.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\end{table}\n")
sink()

cat("\n=== All tables saved to", tab_dir, "===\n")
