## ============================================================
## 06_tables.R — Generate all tables
## MGNREGA and Structural Transformation
## ============================================================

source("00_packages.R")

data_dir  <- file.path("..", "data")
tab_dir   <- file.path("..", "tables")

census <- fread(file.path(data_dir, "analysis_census_panel.csv"))
nl     <- fread(file.path(data_dir, "analysis_nightlights_panel.csv"))
results <- readRDS(file.path(data_dir, "main_results.rds"))
rob     <- readRDS(file.path(data_dir, "robustness_results.rds"))

# ── Table 1: Summary Statistics ──────────────────────────────
cat("Creating Table 1: Summary statistics...\n")

sum_pre <- census[year == 2001L, .(
  `Population` = pop,
  `Main Workers` = main_workers,
  `Non-Farm Share` = nonfarm_share,
  `Cultivator Share` = cult_share,
  `Ag. Laborer Share` = aglab_share,
  Phase = mgnrega_phase
)]

# Summary by phase
make_summ <- function(dt, phase_val) {
  d <- dt[Phase == phase_val]
  data.frame(
    Variable = c("Population", "Main Workers", "Non-Farm Share",
                 "Cultivator Share", "Ag. Laborer Share"),
    Mean = c(mean(d$Population, na.rm = TRUE),
             mean(d$`Main Workers`, na.rm = TRUE),
             mean(d$`Non-Farm Share`, na.rm = TRUE),
             mean(d$`Cultivator Share`, na.rm = TRUE),
             mean(d$`Ag. Laborer Share`, na.rm = TRUE)),
    SD = c(sd(d$Population, na.rm = TRUE),
           sd(d$`Main Workers`, na.rm = TRUE),
           sd(d$`Non-Farm Share`, na.rm = TRUE),
           sd(d$`Cultivator Share`, na.rm = TRUE),
           sd(d$`Ag. Laborer Share`, na.rm = TRUE)),
    N = nrow(d)
  )
}

t1_p1 <- make_summ(sum_pre, 1L)
t1_p2 <- make_summ(sum_pre, 2L)
t1_p3 <- make_summ(sum_pre, 3L)

# Write LaTeX table
sink(file.path(tab_dir, "tab1_summary.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics: Baseline District Characteristics (Census 2001)}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{tabular}{l ccc ccc ccc}\n")
cat("\\toprule\n")
cat("& \\multicolumn{3}{c}{Phase I} & \\multicolumn{3}{c}{Phase II} & \\multicolumn{3}{c}{Phase III} \\\\\n")
cat("\\cmidrule(lr){2-4} \\cmidrule(lr){5-7} \\cmidrule(lr){8-10}\n")
cat("& Mean & SD & N & Mean & SD & N & Mean & SD & N \\\\\n")
cat("\\midrule\n")
for (i in 1:5) {
  cat(sprintf("%s & %.3f & %.3f & %d & %.3f & %.3f & %d & %.3f & %.3f & %d \\\\\n",
              t1_p1$Variable[i],
              t1_p1$Mean[i], t1_p1$SD[i], t1_p1$N[i],
              t1_p2$Mean[i], t1_p2$SD[i], t1_p2$N[i],
              t1_p3$Mean[i], t1_p3$SD[i], t1_p3$N[i]))
}
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\vspace{0.2cm}\n")
cat("\\footnotesize \\textit{Notes:} Summary statistics computed from Census 2001 Primary Census Abstract,\n")
cat("aggregated to Census 2011 district boundaries using SHRUG crosswalks.\n")
cat("Phase I includes the 200 most backward districts (treated Feb 2006),\n")
cat("Phase II the next 130 (treated Apr 2007), and Phase III the remaining\n")
cat("districts (treated Apr 2008). Non-farm share = (household industry +\n")
cat("other workers) / main workers.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

# Also save with better formatting for population
sink(file.path(tab_dir, "tab1_summary_formatted.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics: Baseline District Characteristics (Census 2001)}\n")
cat("\\label{tab:summary}\n")
cat("\\small\n")
cat("\\begin{tabular}{l cc cc cc}\n")
cat("\\toprule\n")
cat("& \\multicolumn{2}{c}{Phase I (N=", t1_p1$N[1], ")} & \\multicolumn{2}{c}{Phase II (N=", t1_p2$N[1], ")} & \\multicolumn{2}{c}{Phase III (N=", t1_p3$N[1], ")} \\\\\n")
cat("\\cmidrule(lr){2-3} \\cmidrule(lr){4-5} \\cmidrule(lr){6-7}\n")
cat("& Mean & SD & Mean & SD & Mean & SD \\\\\n")
cat("\\midrule\n")
cat(sprintf("Population (000s) & %.1f & %.1f & %.1f & %.1f & %.1f & %.1f \\\\\n",
            t1_p1$Mean[1]/1000, t1_p1$SD[1]/1000,
            t1_p2$Mean[1]/1000, t1_p2$SD[1]/1000,
            t1_p3$Mean[1]/1000, t1_p3$SD[1]/1000))
cat(sprintf("Main Workers (000s) & %.1f & %.1f & %.1f & %.1f & %.1f & %.1f \\\\\n",
            t1_p1$Mean[2]/1000, t1_p1$SD[2]/1000,
            t1_p2$Mean[2]/1000, t1_p2$SD[2]/1000,
            t1_p3$Mean[2]/1000, t1_p3$SD[2]/1000))
cat(sprintf("Non-Farm Share & %.3f & %.3f & %.3f & %.3f & %.3f & %.3f \\\\\n",
            t1_p1$Mean[3], t1_p1$SD[3], t1_p2$Mean[3], t1_p2$SD[3], t1_p3$Mean[3], t1_p3$SD[3]))
cat(sprintf("Cultivator Share & %.3f & %.3f & %.3f & %.3f & %.3f & %.3f \\\\\n",
            t1_p1$Mean[4], t1_p1$SD[4], t1_p2$Mean[4], t1_p2$SD[4], t1_p3$Mean[4], t1_p3$SD[4]))
cat(sprintf("Ag. Laborer Share & %.3f & %.3f & %.3f & %.3f & %.3f & %.3f \\\\\n",
            t1_p1$Mean[5], t1_p1$SD[5], t1_p2$Mean[5], t1_p2$SD[5], t1_p3$Mean[5], t1_p3$SD[5]))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\vspace{0.2cm}\n")
cat("\\footnotesize \\textit{Notes:} Summary statistics from Census 2001 PCA aggregated to 2011 district boundaries via SHRUG. Phase assignment based on Planning Commission Backwardness Index ranking. Non-farm share $=$ (household industry $+$ other workers) $/$ main workers.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

# ── Table 2: Main DiD Results ────────────────────────────────
cat("Creating Table 2: Main results...\n")

sink(file.path(tab_dir, "tab2_main_results.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Effect of MGNREGA on Worker Composition: Phase I vs Phase III Districts}\n")
cat("\\label{tab:main}\n")
cat("\\begin{tabular}{l cccc}\n")
cat("\\toprule\n")
cat("& (1) & (2) & (3) & (4) \\\\\n")
cat("& Non-Farm & Cultivator & Ag. Laborer & Log \\\\\n")
cat("& Share & Share & Share & Population \\\\\n")
cat("\\midrule\n")

# Extract coefficients
models <- list(results$twfe_nonfarm, results$twfe_cult,
               results$twfe_aglab, results$twfe_pop)
for_stars <- function(p) {
  if (p < 0.01) return("***")
  if (p < 0.05) return("**")
  if (p < 0.1) return("*")
  return("")
}

coefs <- sapply(models, function(m) coef(m)["early_post"])
ses   <- sapply(models, function(m) se(m)["early_post"])
pvals <- sapply(models, function(m) fixest::pvalue(m)["early_post"])
stars <- sapply(pvals, for_stars)

cat(sprintf("Phase I $\\times$ Post & %.4f%s & %.4f%s & %.4f%s & %.4f%s \\\\\n",
            coefs[1], stars[1], coefs[2], stars[2],
            coefs[3], stars[3], coefs[4], stars[4]))
cat(sprintf("& (%.4f) & (%.4f) & (%.4f) & (%.4f) \\\\\n",
            ses[1], ses[2], ses[3], ses[4]))

# Add 95% CIs
ci_lo <- coefs - 1.96 * ses
ci_hi <- coefs + 1.96 * ses
cat(sprintf("95\\%% CI & [%.4f, %.4f] & [%.4f, %.4f] & [%.4f, %.4f] & [%.4f, %.4f] \\\\\n",
            ci_lo[1], ci_hi[1], ci_lo[2], ci_hi[2],
            ci_lo[3], ci_hi[3], ci_lo[4], ci_hi[4]))

# Pre-trend test
pt_coefs <- c(coef(results$pt_nonfarm)["early_post"],
              coef(results$pt_cult)["early_post"],
              coef(results$pt_aglab)["early_post"], NA)
pt_pvals <- c(fixest::pvalue(results$pt_nonfarm)["early_post"],
              fixest::pvalue(results$pt_cult)["early_post"],
              fixest::pvalue(results$pt_aglab)["early_post"], NA)

cat("\\midrule\n")
cat(sprintf("Pre-trend (1991--2001) & %.4f & %.4f & %.4f & --- \\\\\n",
            pt_coefs[1], pt_coefs[2], pt_coefs[3]))
cat(sprintf("Pre-trend $p$-value & %.3f & %.3f & %.3f & --- \\\\\n",
            pt_pvals[1], pt_pvals[2], pt_pvals[3]))

cat("\\midrule\n")
n_obs <- nrow(census[mgnrega_phase %in% c(1L, 3L) & year %in% c(2001L, 2011L)])
n_dist <- uniqueN(census[mgnrega_phase %in% c(1L, 3L), dist_id])
n_clust <- uniqueN(census[mgnrega_phase %in% c(1L, 3L), pc11_state_id])
n_treat <- uniqueN(census[mgnrega_phase == 1L, dist_id])

cat(sprintf("Observations & %d & %d & %d & %d \\\\\n", n_obs, n_obs, n_obs, n_obs))
cat(sprintf("Districts & %d & %d & %d & %d \\\\\n", n_dist, n_dist, n_dist, n_dist))
cat(sprintf("Treated districts & %d & %d & %d & %d \\\\\n", n_treat, n_treat, n_treat, n_treat))
cat(sprintf("Clusters (states) & %d & %d & %d & %d \\\\\n", n_clust, n_clust, n_clust, n_clust))
cat("Estimator & TWFE & TWFE & TWFE & TWFE \\\\\n")
cat("Control group & Phase III & Phase III & Phase III & Phase III \\\\\n")
cat("District FE & \\checkmark & \\checkmark & \\checkmark & \\checkmark \\\\\n")
cat("Year FE & \\checkmark & \\checkmark & \\checkmark & \\checkmark \\\\\n")
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\vspace{0.2cm}\n")
cat("\\footnotesize \\textit{Notes:} Difference-in-differences estimates comparing Phase I districts (treated Feb 2006) with Phase III districts (treated Apr 2008), using Census 2001 (pre) and 2011 (post). Standard errors clustered at state level in parentheses. Pre-trend test: same specification on 1991--2001 change. * $p<0.10$, ** $p<0.05$, *** $p<0.01$.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

# ── Table 3: Nightlights Results ─────────────────────────────
cat("Creating Table 3: Nightlights results...\n")

sink(file.path(tab_dir, "tab3_nightlights.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Effect of MGNREGA on Nightlights: Callaway-Sant'Anna and Sun-Abraham Estimates}\n")
cat("\\label{tab:nightlights}\n")
cat("\\begin{tabular}{l ccc}\n")
cat("\\toprule\n")
cat("& (1) & (2) & (3) \\\\\n")
cat("& TWFE & CS ATT & Sun-Abraham \\\\\n")
cat("\\midrule\n")

# TWFE
cat(sprintf("ATT & %.4f%s & %.4f%s & --- \\\\\n",
            coef(rob$twfe_nl)["treated"], for_stars(fixest::pvalue(rob$twfe_nl)["treated"]),
            results$overall_nl$overall.att,
            for_stars(ifelse(abs(results$overall_nl$overall.att / results$overall_nl$overall.se) > 2.58, 0.001,
                      ifelse(abs(results$overall_nl$overall.att / results$overall_nl$overall.se) > 1.96, 0.01, 0.1)))))
cat(sprintf("& (%.4f) & (%.4f) & --- \\\\\n",
            se(rob$twfe_nl)["treated"],
            results$overall_nl$overall.se))

cat("\\midrule\n")
n_nl <- nrow(nl)
n_nl_dist <- uniqueN(nl$dist_num)
n_nl_clust <- uniqueN(nl$pc11_state_id)
cat(sprintf("Observations & %d & %d & %d \\\\\n", n_nl, n_nl, n_nl))
cat(sprintf("Districts & %d & %d & %d \\\\\n", n_nl_dist, n_nl_dist, n_nl_dist))
cat(sprintf("Clusters & %d & --- & %d \\\\\n", n_nl_clust, n_nl_clust))
cat("Years & 1994--2013 & 1994--2013 & 1994--2013 \\\\\n")
cat("Outcome & Log(light+1) & Log(light+1) & Log(light+1) \\\\\n")
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\vspace{0.2cm}\n")
cat("\\footnotesize \\textit{Notes:} Dependent variable is log(calibrated DMSP nightlights + 1) at district-year level. Column 1: standard TWFE with district and year FE. Column 2: Callaway \\& Sant'Anna (2021) overall ATT using not-yet-treated as control group. Column 3: Sun \\& Abraham (2021) interaction-weighted estimator. Standard errors clustered at state level. * $p<0.10$, ** $p<0.05$, *** $p<0.01$.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

# ── Table 4: Robustness ─────────────────────────────────────
cat("Creating Table 4: Robustness...\n")

sink(file.path(tab_dir, "tab4_robustness.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Robustness Checks: Alternative Comparisons and Heterogeneity}\n")
cat("\\label{tab:robust}\n")
cat("\\begin{tabular}{l cccc}\n")
cat("\\toprule\n")
cat("& (1) & (2) & (3) & (4) \\\\\n")
cat("& Phase I & Dose- & High & Low \\\\\n")
cat("& vs II & Response & Baseline & Baseline \\\\\n")
cat("\\midrule\n")
cat("\\multicolumn{5}{l}{\\textit{Panel A: Non-Farm Worker Share}} \\\\\n")

c1 <- coef(rob$rob_nonfarm_12)["early_post"]
s1 <- se(rob$rob_nonfarm_12)["early_post"]
p1 <- fixest::pvalue(rob$rob_nonfarm_12)["early_post"]

c2 <- coef(rob$dose_resp)["treatment_years"]
s2 <- se(rob$dose_resp)["treatment_years"]
p2 <- fixest::pvalue(rob$dose_resp)["treatment_years"]

c3 <- coef(rob$het_high)["early_post"]
s3 <- se(rob$het_high)["early_post"]
p3 <- fixest::pvalue(rob$het_high)["early_post"]

c4 <- coef(rob$het_low)["early_post"]
s4 <- se(rob$het_low)["early_post"]
p4 <- fixest::pvalue(rob$het_low)["early_post"]

cat(sprintf("Estimate & %.4f%s & %.4f%s & %.4f%s & %.4f%s \\\\\n",
            c1, for_stars(p1), c2, for_stars(p2), c3, for_stars(p3), c4, for_stars(p4)))
cat(sprintf("& (%.4f) & (%.4f) & (%.4f) & (%.4f) \\\\\n", s1, s2, s3, s4))
cat("\\midrule\n")
cat(sprintf("RI $p$-value & --- & --- & --- & --- \\\\\n"))
cat(sprintf("Main estimate RI $p$ & \\multicolumn{4}{c}{%.3f (500 permutations)} \\\\\n",
            rob$ri_pvalue))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.95\\textwidth}\n")
cat("\\vspace{0.2cm}\n")
cat("\\footnotesize \\textit{Notes:} Column 1: Phase I vs Phase II districts (both early treated). Column 2: dose-response regression of $\\Delta$ non-farm share (2001--2011) on years of MGNREGA exposure by 2011, with state FE. Columns 3--4: Phase I vs Phase III, split by median baseline non-farm share in 2001. RI $p$-value from 500 random permutations of phase assignment. * $p<0.10$, ** $p<0.05$, *** $p<0.01$.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

cat("\nAll tables saved to:", tab_dir, "\n")
