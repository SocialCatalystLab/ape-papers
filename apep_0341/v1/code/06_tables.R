## ============================================================================
## 06_tables.R — All table generation (LaTeX)
## apep_0328: Medicaid Reimbursement Rates and HCBS Provider Supply
## ============================================================================

source("00_packages.R")

## ---- Load data ----
panel_pc <- readRDS(file.path(DATA, "did_panel_pc.rds"))
rc       <- readRDS(file.path(DATA, "rate_changes.rds"))
results  <- readRDS(file.path(DATA, "main_results.rds"))
robust   <- readRDS(file.path(DATA, "robust_results.rds"))

panel_pc[, post_treat := as.integer(treated == TRUE & month_date >= treat_date)]
panel_pc[, group := ifelse(treated, "Treated", "Never-Treated")]

## ============================================================================
## Table 1: Summary Statistics
## ============================================================================

cat("Table 1: Summary statistics...\n")

## Pre-treatment period (before any treatment date)
pre_period <- panel_pc[month_date < "2021-04-01"]

summ_all <- pre_period[, .(
  mean_prov   = mean(n_providers),
  sd_prov     = sd(n_providers),
  mean_benes  = mean(total_benes),
  sd_benes    = sd(total_benes),
  mean_claims = mean(total_claims),
  sd_claims   = sd(total_claims),
  mean_paid   = mean(total_paid),
  sd_paid     = sd(total_paid),
  mean_rate   = mean(avg_paid_per_claim),
  sd_rate     = sd(avg_paid_per_claim),
  N           = .N,
  n_states    = uniqueN(state)
)]

summ_by_group <- pre_period[, .(
  mean_prov   = mean(n_providers),
  sd_prov     = sd(n_providers),
  mean_benes  = mean(total_benes),
  sd_benes    = sd(total_benes),
  mean_claims = mean(total_claims),
  sd_claims   = sd(total_claims),
  mean_paid   = mean(total_paid),
  sd_paid     = sd(total_paid),
  mean_rate   = mean(avg_paid_per_claim),
  sd_rate     = sd(avg_paid_per_claim),
  N           = .N,
  n_states    = uniqueN(state)
), by = group]

## Write LaTeX
fmt <- function(x, d = 1) formatC(x, format = "f", digits = d, big.mark = ",")

tex1 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Summary Statistics: Pre-ARPA Baseline Period (January 2018--March 2021)}",
  "\\label{tab:summary}",
  "\\begin{tabular}{lcccccc}",
  "\\toprule",
  " & \\multicolumn{2}{c}{All States} & \\multicolumn{2}{c}{Treated} & \\multicolumn{2}{c}{Never-Treated} \\\\",
  "\\cmidrule(lr){2-3} \\cmidrule(lr){4-5} \\cmidrule(lr){6-7}",
  " & Mean & SD & Mean & SD & Mean & SD \\\\",
  "\\midrule"
)

## Add rows
vars <- c("prov", "benes", "claims", "paid", "rate")
labels <- c("Provider count", "Beneficiaries", "Total claims",
            "Total paid ($)", "Avg. payment/claim ($)")

for (i in seq_along(vars)) {
  row <- sprintf("%s & %s & %s & %s & %s & %s & %s \\\\",
                 labels[i],
                 fmt(summ_all[[paste0("mean_", vars[i])]]),
                 fmt(summ_all[[paste0("sd_", vars[i])]]),
                 fmt(summ_by_group[group == "Treated"][[paste0("mean_", vars[i])]]),
                 fmt(summ_by_group[group == "Treated"][[paste0("sd_", vars[i])]]),
                 fmt(summ_by_group[group == "Never-Treated"][[paste0("mean_", vars[i])]]),
                 fmt(summ_by_group[group == "Never-Treated"][[paste0("sd_", vars[i])]]))
  tex1 <- c(tex1, row)
}

tex1 <- c(tex1,
  "\\midrule",
  sprintf("State-months & \\multicolumn{2}{c}{%s} & \\multicolumn{2}{c}{%s} & \\multicolumn{2}{c}{%s} \\\\",
          fmt(summ_all$N, 0), fmt(summ_by_group[group == "Treated", N], 0),
          fmt(summ_by_group[group == "Never-Treated", N], 0)),
  sprintf("States & \\multicolumn{2}{c}{%d} & \\multicolumn{2}{c}{%d} & \\multicolumn{2}{c}{%d} \\\\",
          summ_all$n_states, summ_by_group[group == "Treated", n_states],
          summ_by_group[group == "Never-Treated", n_states]),
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{minipage}{0.95\\textwidth}",
  "\\vspace{4pt}",
  "\\footnotesize \\textit{Notes:} Summary statistics for the pre-ARPA period (January 2018 to March 2021), covering 1,899 state-months. The full regression panel (Table~\\ref{tab:main}) covers 4,161 state-months across the entire 2018--2024 period. Some early-treated cohorts (2018) have post-treatment observations in this pre-ARPA window. Personal care codes include T1019, T1020, S5125, and S5130. ``Treated'' states are those with a detected sustained rate increase of \\(\\geq\\)15\\% in average payment per claim. Provider counts are unique billing NPIs per state-month. Two treated states (U.S. Virgin Islands and Vermont) lack pre-ARPA data and are excluded from this table but included in all regressions. They are excluded because they entered the T-MSIS reporting system only after April 2021, providing insufficient pre-treatment baseline for this table; the Callaway-Sant'Anna estimator accommodates their short pre-treatment windows in the regression analysis.",
  "\\end{minipage}",
  "\\end{table}"
)

writeLines(tex1, file.path(TABLES, "tab1_summary.tex"))

## ============================================================================
## Table 2: Main Results (TWFE + CS-DiD)
## ============================================================================

cat("Table 2: Main results...\n")

etable(results$twfe_providers, results$twfe_claims,
       results$twfe_benes, results$twfe_paid,
       se.below = TRUE,
       dict = c(post_treat = "Post Rate Increase"),
       headers = c("Log Providers", "Log Claims", "Log Benes",
                    "Log Paid"),
       title = "Effect of HCBS Rate Increases on Provider Outcomes",
       label = "tab:main",
       notes = "All regressions include state and month fixed effects with standard errors clustered at the state level.",
       fitstat = ~ n + r2,
       depvar = FALSE,
       file = file.path(TABLES, "tab2_main_results.tex"),
       replace = TRUE,
       style.tex = style.tex("aer"))

## Add 95% CI row manually to Table 2
ci_prov  <- confint(results$twfe_providers)["post_treat",]
ci_claim <- confint(results$twfe_claims)["post_treat",]
ci_bene  <- confint(results$twfe_benes)["post_treat",]
ci_paid  <- confint(results$twfe_paid)["post_treat",]
cat(sprintf("95%% CIs: Providers [%.3f, %.3f], Claims [%.3f, %.3f], Benes [%.3f, %.3f], Paid [%.3f, %.3f]\n",
            ci_prov[1], ci_prov[2], ci_claim[1], ci_claim[2], ci_bene[1], ci_bene[2], ci_paid[1], ci_paid[2]))

## ============================================================================
## Table 3: CS-DiD ATT Summary
## ============================================================================

cat("Table 3: CS-DiD ATT summary...\n")

cs_tex <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Callaway-Sant'Anna Staggered DiD Estimates}",
  "\\label{tab:cs_did}",
  "\\begin{tabular}{lccc}",
  "\\toprule",
  " & Log Providers & Log Claims & Log Beneficiaries \\\\",
  "\\midrule"
)

if (!is.null(results$att_overall_prov)) {
  cs_tex <- c(cs_tex,
    sprintf("Overall ATT & %.4f & %.4f & %.4f \\\\",
            results$att_overall_prov$overall.att,
            results$att_overall_claims$overall.att,
            results$att_overall_benes$overall.att),
    sprintf(" & (%.4f) & (%.4f) & (%.4f) \\\\",
            results$att_overall_prov$overall.se,
            results$att_overall_claims$overall.se,
            results$att_overall_benes$overall.se)
  )
}

cs_tex <- c(cs_tex,
  "\\midrule",
  sprintf("TWFE Estimate & %.4f & %.4f & %.4f \\\\",
          coef(results$twfe_providers)["post_treat"],
          coef(results$twfe_claims)["post_treat"],
          coef(results$twfe_benes)["post_treat"]),
  sprintf(" & (%.4f) & (%.4f) & (%.4f) \\\\",
          se(results$twfe_providers)["post_treat"],
          se(results$twfe_claims)["post_treat"],
          se(results$twfe_benes)["post_treat"]),
  "\\midrule",
  "Estimator & CS-DiD & CS-DiD & CS-DiD \\\\",
  "Control Group & Never-Treated & Never-Treated & Never-Treated \\\\",
  "State FE & Yes & Yes & Yes \\\\",
  "Time FE & Yes & Yes & Yes \\\\",
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{minipage}{0.85\\textwidth}",
  "\\vspace{4pt}",
  "\\footnotesize \\textit{Notes:} Top panel reports the aggregate ATT from \\citet{callaway2021difference} using never-treated states as the comparison group. Bottom panel reports standard TWFE for comparison. Standard errors (in parentheses) are clustered at the state level.",
  "\\end{minipage}",
  "\\end{table}"
)

writeLines(cs_tex, file.path(TABLES, "tab3_cs_did.tex"))

## ============================================================================
## Table 4: Robustness Checks
## ============================================================================

cat("Table 4: Robustness...\n")

rob_tex <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Robustness Checks}",
  "\\label{tab:robustness}",
  "\\begin{tabular}{lccl}",
  "\\toprule",
  "Specification & Coefficient & SE & Notes \\\\",
  "\\midrule",
  "\\textit{Panel A: Baseline} & & & \\\\",
  sprintf("\\quad TWFE (personal care providers) & %.4f & %.4f & Main result \\\\",
          coef(results$twfe_providers)["post_treat"],
          se(results$twfe_providers)["post_treat"]),
  "\\midrule",
  "\\textit{Panel B: Placebo Tests} & & & \\\\",
  sprintf("\\quad E/M visit providers (99213/99214) & %.4f & %.4f & Placebo \\\\",
          coef(robust$placebo_em)["post_treat"],
          se(robust$placebo_em)["post_treat"]),
  sprintf("\\quad E/M visit claims & %.4f & %.4f & Placebo \\\\",
          coef(robust$placebo_em_claims)["post_treat"],
          se(robust$placebo_em_claims)["post_treat"]),
  "\\midrule",
  "\\textit{Panel C: Heterogeneity} & & & \\\\",
  sprintf("\\quad Individual providers (Type 1) & %.4f & %.4f & \\\\",
          coef(robust$het_indiv)["post_treat"],
          se(robust$het_indiv)["post_treat"]),
  sprintf("\\quad Organizations (Type 2) & %.4f & %.4f & \\\\",
          coef(robust$het_org)["post_treat"],
          se(robust$het_org)["post_treat"]),
  sprintf("\\quad Sole proprietors & %.4f & %.4f & \\\\",
          coef(robust$het_sole)["post_treat"],
          se(robust$het_sole)["post_treat"]),
  "\\midrule",
  "\\textit{Panel D: Sensitivity} & & & \\\\",
  sprintf("\\quad Excluding COVID onset & %.4f & %.4f & Mar--Jun 2020 dropped \\\\",
          coef(robust$nocovid_prov)["post_treat"],
          se(robust$nocovid_prov)["post_treat"]),
  sprintf("\\quad Excluding Wyoming & %.4f & %.4f & 1,422\\%% outlier dropped \\\\",
          coef(robust$nowy_prov)["post_treat"],
          se(robust$nowy_prov)["post_treat"]),
  sprintf("\\quad Randomization inference & \\multicolumn{2}{c}{$p = %.3f$} & 1,000 permutations \\\\",
          robust$ri_pvalue),
  "\\midrule",
  "\\textit{Panel E: Dose-Response} & & & \\\\",
  sprintf("\\quad Rate increase $\\times$ post & %.4f & %.4f & Continuous treatment \\\\",
          coef(results$twfe_dose_prov)["post_dose"],
          se(results$twfe_dose_prov)["post_dose"]),
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{minipage}{0.95\\textwidth}",
  "\\vspace{4pt}",
  "\\footnotesize \\textit{Notes:} All regressions include state and month fixed effects with standard errors clustered at the state level. Panel B tests whether the personal care rate increase affects outcomes for unrelated services (E/M office visits). Panel C splits provider counts by entity type from NPPES. Panel D drops the initial COVID-19 months, excludes the extreme Wyoming outlier (1,422\\% rate increase), and reports a randomization inference p-value. Panel E uses rate change magnitude as a continuous treatment intensity variable.",
  "\\end{minipage}",
  "\\end{table}"
)

writeLines(rob_tex, file.path(TABLES, "tab4_robustness.tex"))

## ============================================================================
## Table 5: Treatment Details by State
## ============================================================================

cat("Table 5: Treatment details...\n")

treat_detail <- rc[treated == TRUE][order(treat_date)]
treat_detail[, treat_quarter := paste0(year(treat_date), " Q", ceiling(month(treat_date) / 3))]

tex5 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Detected HCBS Rate Increases by State}",
  "\\label{tab:treatment}",
  "\\footnotesize",
  "\\begin{tabular}{lcrrr}",
  "\\toprule",
  "State & Treatment Quarter & Rate Before (\\$) & Rate After (\\$) & Change (\\%) \\\\",
  "\\midrule"
)

for (i in seq_len(nrow(treat_detail))) {
  row <- treat_detail[i]
  tex5 <- c(tex5,
    sprintf("%s & %s & %.2f & %.2f & %.1f \\\\",
            row$state, row$treat_quarter,
            row$rate_before, row$rate_after, row$pct_change * 100))
}

tex5 <- c(tex5,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{minipage}{0.90\\textwidth}",
  "\\vspace{4pt}",
  "\\footnotesize \\textit{Notes:} Rate changes detected from T-MSIS payment data. ``Rate Before'' and ``Rate After'' are the 6-month average payment per claim for personal care HCPCS codes (T1019, T1020, S5125, S5130) before and after the detected jump. Treatment quarter is the first quarter with a sustained ($\\geq$3 month) rate increase of $\\geq$15\\%.",
  "\\end{minipage}",
  "\\end{table}"
)

writeLines(tex5, file.path(TABLES, "tab5_treatment.tex"))

cat("\n=== All tables generated ===\n")
