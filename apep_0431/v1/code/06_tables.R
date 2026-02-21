## ────────────────────────────────────────────────────────────────────────────
## 06_tables.R — Generate LaTeX tables for paper
## ────────────────────────────────────────────────────────────────────────────

source("00_packages.R")
load("../data/analysis_data.RData")
load("../data/main_results.RData")
load("../data/robustness_results.RData")

df <- panel[special_state == FALSE & !is.na(pop2001) & pop2001 > 0]
tab_dir <- "../tables"

# ════════════════════════════════════════════════════════════════════════════
# TABLE 1: Summary Statistics
# ════════════════════════════════════════════════════════════════════════════

# Near-threshold sample (±200)
near <- df[abs(pop_centered) <= 200]
below <- near[above_threshold == 0]
above <- near[above_threshold == 1]

vars_sum <- c("pop2001", "pc01_pca_no_hh", "lit_rate_01", "sc_share_01",
              "st_share_01", "female_share_01", "wfpr_01_f", "wfpr_01_m",
              "nonag_share_01_f", "nonag_share_01_m")
labels_sum <- c("Population (2001)", "Households", "Literacy rate",
                "SC share", "ST share", "Female share",
                "Female WF participation", "Male WF participation",
                "Female non-ag share (2001)", "Male non-ag share (2001)")

sumstats <- data.table(
  Variable = labels_sum,
  Mean_Below = sapply(vars_sum, function(v) mean(below[[v]], na.rm = TRUE)),
  SD_Below = sapply(vars_sum, function(v) sd(below[[v]], na.rm = TRUE)),
  Mean_Above = sapply(vars_sum, function(v) mean(above[[v]], na.rm = TRUE)),
  SD_Above = sapply(vars_sum, function(v) sd(above[[v]], na.rm = TRUE)),
  N_Below = sapply(vars_sum, function(v) sum(!is.na(below[[v]]))),
  N_Above = sapply(vars_sum, function(v) sum(!is.na(above[[v]])))
)

# Write LaTeX
tex_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Summary Statistics: Villages Near PMGSY Threshold}",
  "\\label{tab:sumstats}",
  "\\begin{tabular}{lcccc}",
  "\\toprule",
  " & \\multicolumn{2}{c}{Below 500} & \\multicolumn{2}{c}{Above 500} \\\\",
  "\\cmidrule(lr){2-3} \\cmidrule(lr){4-5}",
  "Variable & Mean & SD & Mean & SD \\\\",
  "\\midrule"
)

for (i in 1:nrow(sumstats)) {
  tex_lines <- c(tex_lines, sprintf(
    "%s & %.3f & %.3f & %.3f & %.3f \\\\",
    sumstats$Variable[i],
    sumstats$Mean_Below[i], sumstats$SD_Below[i],
    sumstats$Mean_Above[i], sumstats$SD_Above[i]
  ))
}

tex_lines <- c(tex_lines,
  "\\midrule",
  sprintf("Villages & \\multicolumn{2}{c}{%s} & \\multicolumn{2}{c}{%s} \\\\",
          format(sumstats$N_Below[1], big.mark = ","),
          format(sumstats$N_Above[1], big.mark = ",")),
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} Sample restricted to plain-area states (non-special-category) with village population within $\\pm$200 of the PMGSY threshold of 500. Data from SHRUG v2.1 (Asher, Novosad, Lunt). Literacy rate, SC/ST share, and worker participation rates computed from Census 2001. Non-agricultural share is the fraction of main workers in household industry and other non-agricultural occupations.",
  "\\end{tablenotes}",
  "\\end{table}"
)

writeLines(tex_lines, file.path(tab_dir, "tab1_sumstats.tex"))
cat("Saved: tab1_sumstats.tex\n")

# ════════════════════════════════════════════════════════════════════════════
# TABLE 2: Main RDD Results
# ════════════════════════════════════════════════════════════════════════════

mr <- main_results[!is.na(Estimate)]

tex2 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Main RDD Estimates: Effect of PMGSY Eligibility on Structural Transformation}",
  "\\label{tab:main_rdd}",
  "\\begin{tabular}{lcccc}",
  "\\toprule",
  "Outcome & Estimate & Robust SE & $p$-value & Eff. $N$ \\\\",
  "\\midrule"
)

for (i in 1:nrow(mr)) {
  stars <- ifelse(mr$P_value[i] < 0.01, "^{***}",
           ifelse(mr$P_value[i] < 0.05, "^{**}",
           ifelse(mr$P_value[i] < 0.10, "^{*}", "")))
  tex2 <- c(tex2, sprintf(
    "%s & $%.4f%s$ & (%.4f) & %.3f & %s \\\\",
    mr$Outcome[i], mr$Estimate[i], stars, mr$SE_robust[i],
    mr$P_value[i], format(mr$N_eff[i], big.mark = ",")
  ))
}

tex2 <- c(tex2,
  "\\midrule",
  sprintf("Bandwidth & \\multicolumn{4}{c}{CCT Optimal (%.0f--%.0f)} \\\\",
          min(mr$BW, na.rm = TRUE), max(mr$BW, na.rm = TRUE)),
  "Polynomial & \\multicolumn{4}{c}{Local linear} \\\\",
  "Kernel & \\multicolumn{4}{c}{Triangular} \\\\",
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} Local polynomial RDD estimates using \\texttt{rdrobust} (Calonico, Cattaneo, Titiunik). Running variable: Census 2001 village population. Cutoff: 500 (plain-area states). Robust bias-corrected standard errors and $p$-values reported. Because $p$-values use bias-corrected test statistics, they do not equal $2\\Phi(-|\\hat{\\tau}/\\text{SE}|)$; see Calonico, Cattaneo, and Titiunik (2014). $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.",
  "\\end{tablenotes}",
  "\\end{table}"
)

writeLines(tex2, file.path(tab_dir, "tab2_main_rdd.tex"))
cat("Saved: tab2_main_rdd.tex\n")

# ════════════════════════════════════════════════════════════════════════════
# TABLE 3: Robustness — Bandwidth and Polynomial Sensitivity
# ════════════════════════════════════════════════════════════════════════════

tex3 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Robustness: Bandwidth and Polynomial Sensitivity}",
  "\\label{tab:robustness}",
  "\\begin{tabular}{lcccc}",
  "\\toprule",
  " & \\multicolumn{4}{c}{Change in Female Non-Agricultural Share} \\\\",
  "\\cmidrule(lr){2-5}",
  "Specification & Estimate & Robust SE & $p$-value & Eff. $N$ \\\\",
  "\\midrule",
  "\\textit{Panel A: Bandwidth} \\\\[3pt]"
)

bw_clean <- bw_results[!is.na(estimate)]
for (i in 1:nrow(bw_clean)) {
  lab <- sprintf("  %.1f$\\times$ optimal ($h$ = %.0f)", bw_clean$multiplier[i], bw_clean$bandwidth[i])
  tex3 <- c(tex3, sprintf(
    "%s & %.4f & (%.4f) & %.3f & %s \\\\",
    lab, bw_clean$estimate[i], bw_clean$se_robust[i],
    bw_clean$p_value[i], format(bw_clean$n_eff[i], big.mark = ",")))
}

tex3 <- c(tex3, "\\midrule", "\\textit{Panel B: Polynomial order} \\\\[3pt]")
poly_clean <- poly_results[!is.na(estimate)]
for (i in 1:nrow(poly_clean)) {
  tex3 <- c(tex3, sprintf(
    "  Order %d & %.4f & (%.4f) & %.3f & %s \\\\",
    poly_clean$order[i], poly_clean$estimate[i],
    poly_clean$se_robust[i], poly_clean$p_value[i],
    format(poly_clean$n_eff[i], big.mark = ",")))
}

tex3 <- c(tex3, "\\midrule", "\\textit{Panel C: Donut hole} \\\\[3pt]")
don_clean <- donut_results[!is.na(estimate)]
for (i in 1:nrow(don_clean)) {
  tex3 <- c(tex3, sprintf(
    "  Exclude $\\pm$%d & %.4f & (%.4f) & %.3f & %s \\\\",
    don_clean$donut[i], don_clean$estimate[i],
    don_clean$se_robust[i], don_clean$p_value[i],
    format(don_clean$n_eff[i], big.mark = ",")))
}

tex3 <- c(tex3,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} All specifications use local polynomial RDD at the 500 threshold for plain-area states. Panel A varies bandwidth around the CCT optimal (fixing $h$ changes the bias-correction bandwidth, so SEs and $p$-values differ from the main table even at $1.0\\times$ optimal). Panel B varies polynomial order (all use CCT bandwidth). Panel C excludes observations within the donut radius of the cutoff. Robust bias-corrected $p$-values reported throughout.",
  "\\end{tablenotes}",
  "\\end{table}"
)

writeLines(tex3, file.path(tab_dir, "tab3_robustness.tex"))
cat("Saved: tab3_robustness.tex\n")

# ════════════════════════════════════════════════════════════════════════════
# TABLE 4: Regional Heterogeneity
# ════════════════════════════════════════════════════════════════════════════

reg <- region_results[!is.na(n)]

tex4 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Regional Heterogeneity in Road Effects on Structural Transformation}",
  "\\label{tab:regional}",
  "\\begin{tabular}{lccccccc}",
  "\\toprule",
  " & \\multicolumn{3}{c}{Female} & \\multicolumn{3}{c}{Male} & \\\\",
  "\\cmidrule(lr){2-4} \\cmidrule(lr){5-7}",
  "Region & Estimate & SE & $p$ & Estimate & SE & $p$ & $N$ \\\\",
  "\\midrule"
)

for (i in 1:nrow(reg)) {
  tex4 <- c(tex4, sprintf(
    "%s & %.4f & (%.4f) & %.3f & %.4f & (%.4f) & %.3f & %s \\\\",
    reg$region[i],
    ifelse(is.na(reg$estimate_f[i]), NA, reg$estimate_f[i]),
    ifelse(is.na(reg$se_f[i]), NA, reg$se_f[i]),
    ifelse(is.na(reg$p_f[i]), NA, reg$p_f[i]),
    ifelse(is.na(reg$estimate_m[i]), NA, reg$estimate_m[i]),
    ifelse(is.na(reg$se_m[i]), NA, reg$se_m[i]),
    ifelse(is.na(reg$p_m[i]), NA, reg$p_m[i]),
    format(reg$n[i], big.mark = ",")))
}

tex4 <- c(tex4,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} RDD estimates at the 500 threshold by Indian region. North includes Hindi-belt states (UP, Bihar, MP, Rajasthan, Jharkhand, Chhattisgarh, Haryana). South includes AP, Karnataka, Kerala, Tamil Nadu, Telangana. East: West Bengal, Odisha. West: Gujarat, Maharashtra, Goa. Robust standard errors reported.",
  "\\end{tablenotes}",
  "\\end{table}"
)

writeLines(tex4, file.path(tab_dir, "tab4_regional.tex"))
cat("Saved: tab4_regional.tex\n")

# ════════════════════════════════════════════════════════════════════════════
# TABLE 5: Covariate Balance
# ════════════════════════════════════════════════════════════════════════════

cov <- cov_balance[!is.na(Estimate)]

tex5 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Covariate Balance at PMGSY Threshold}",
  "\\label{tab:covbalance}",
  "\\begin{tabular}{lccc}",
  "\\toprule",
  "Baseline Covariate (2001) & RDD Estimate & Robust SE & $p$-value \\\\",
  "\\midrule"
)

for (i in 1:nrow(cov)) {
  tex5 <- c(tex5, sprintf(
    "%s & %.4f & (%.4f) & %.3f \\\\",
    cov$Covariate[i], cov$Estimate[i], cov$SE[i], cov$P_value[i]))
}

tex5 <- c(tex5,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} Each row reports the RDD estimate at the 500 threshold for a baseline (Census 2001) covariate. Null effects support the identifying assumption that villages just above and below the threshold are comparable. CCT optimal bandwidth and triangular kernel.",
  "\\end{tablenotes}",
  "\\end{table}"
)

writeLines(tex5, file.path(tab_dir, "tab5_covbalance.tex"))
cat("Saved: tab5_covbalance.tex\n")

cat("\nAll tables saved to tables/\n")
