## ============================================================================
## 06_tables.R — All table generation (LaTeX)
## apep_0341 v2: Medicaid Reimbursement Rates and HCBS Provider Supply
## ============================================================================

source("00_packages.R")

## ---- Load data ----
panel_pc <- readRDS(file.path(DATA, "did_panel_pc.rds"))
rc       <- readRDS(file.path(DATA, "rate_changes.rds"))
results  <- readRDS(file.path(DATA, "main_results.rds"))
robust   <- readRDS(file.path(DATA, "robust_results.rds"))

panel_pc[, post_treat := as.integer(treated == TRUE & month_date >= treat_date)]
panel_pc[, group := ifelse(treated, "Treated", "Never-Treated")]

n_states  <- uniqueN(panel_pc$state)
n_treated <- sum(rc$treated)
n_control <- sum(!rc$treated)

## ============================================================================
## Table 1: Summary Statistics
## ============================================================================

cat("Table 1: Summary statistics...\n")

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

vars <- c("prov", "benes", "claims", "paid", "rate")
labels <- c("Provider count", "Beneficiaries", "Total claims",
            "Total paid (\\$)", "Avg.\\ payment/claim (\\$)")

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
  "\\footnotesize \\textit{Notes:} Summary statistics for the pre-ARPA period (January 2018 to March 2021). The full regression panel covers the entire 2018--2024 period. Personal care codes include T1019, T1020, S5125, and S5130. ``Treated'' states are those with a detected sustained rate increase of $\\geq$15\\% in average payment per claim. Provider counts are unique billing NPIs per state-month.",
  "\\end{minipage}",
  "\\end{table}"
)

writeLines(tex1, file.path(TABLES, "tab1_summary.tex"))

## ============================================================================
## Table 2: Main Results (TWFE) — v2: with significance stars and WCB p-values
## ============================================================================

cat("Table 2: Main results...\n")

## Build manually for better control over stars and formatting
make_coef_row <- function(mod, var = "post_treat") {
  b <- coef(mod)[var]
  p <- pvalue(mod)[var]
  stars <- sig_stars(p)
  sprintf("%.4f%s", b, stars)
}

make_se_row <- function(mod, var = "post_treat") {
  sprintf("(%.4f)", se(mod)[var])
}

make_ci_row <- function(mod, var = "post_treat") {
  b <- coef(mod)[var]
  s <- se(mod)[var]
  sprintf("[%.3f, %.3f]", b - 1.96 * s, b + 1.96 * s)
}

## Extract WCB p-values
wcb_p <- c(
  if (!is.null(results$wcb_providers)) sprintf("%.3f", results$wcb_providers$p_val) else "---",
  if (!is.null(results$wcb_claims)) sprintf("%.3f", results$wcb_claims$p_val) else "---",
  if (!is.null(results$wcb_benes)) sprintf("%.3f", results$wcb_benes$p_val) else "---",
  if (!is.null(results$wcb_paid)) sprintf("%.3f", results$wcb_paid$p_val) else "---"
)

tex2 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Effect of HCBS Rate Increases on Provider Outcomes}",
  "\\label{tab:main}",
  "\\begin{tabular}{lcccc}",
  "\\toprule",
  " & Log Providers & Log Claims & Log Beneficiaries & Log Paid \\\\",
  " & (1) & (2) & (3) & (4) \\\\",
  "\\midrule",
  sprintf("Post Rate Increase & %s & %s & %s & %s \\\\",
          make_coef_row(results$twfe_providers),
          make_coef_row(results$twfe_claims),
          make_coef_row(results$twfe_benes),
          make_coef_row(results$twfe_paid)),
  sprintf(" & %s & %s & %s & %s \\\\",
          make_se_row(results$twfe_providers),
          make_se_row(results$twfe_claims),
          make_se_row(results$twfe_benes),
          make_se_row(results$twfe_paid)),
  sprintf("95\\%% CI & %s & %s & %s & %s \\\\",
          make_ci_row(results$twfe_providers),
          make_ci_row(results$twfe_claims),
          make_ci_row(results$twfe_benes),
          make_ci_row(results$twfe_paid)),
  sprintf("WCB $p$-value & %s & %s & %s & %s \\\\",
          wcb_p[1], wcb_p[2], wcb_p[3], wcb_p[4]),
  "\\midrule",
  sprintf("Observations & %s & %s & %s & %s \\\\",
          format(nobs(results$twfe_providers), big.mark = ","),
          format(nobs(results$twfe_claims), big.mark = ","),
          format(nobs(results$twfe_benes), big.mark = ","),
          format(nobs(results$twfe_paid), big.mark = ",")),
  sprintf("States & %d & %d & %d & %d \\\\",
          n_states, n_states, n_states, n_states),
  "State FE & $\\checkmark$ & $\\checkmark$ & $\\checkmark$ & $\\checkmark$ \\\\",
  "Month FE & $\\checkmark$ & $\\checkmark$ & $\\checkmark$ & $\\checkmark$ \\\\",
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{minipage}{0.95\\textwidth}",
  "\\vspace{4pt}",
  "\\footnotesize \\textit{Notes:} All regressions include state and month fixed effects with standard errors clustered at the state level (in parentheses). 95\\% confidence intervals in brackets. WCB $p$-values from wild cluster bootstrap with Webb weights (9,999 replications). $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.1$.",
  "\\end{minipage}",
  "\\end{table}"
)

writeLines(tex2, file.path(TABLES, "tab2_main_results.tex"))

## ============================================================================
## Table 3: CS-DiD ATT Summary — v2: with stars and CI
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
  cs_p_prov <- 2 * (1 - pnorm(abs(results$att_overall_prov$overall.att /
                                    results$att_overall_prov$overall.se)))
  cs_p_claims <- 2 * (1 - pnorm(abs(results$att_overall_claims$overall.att /
                                      results$att_overall_claims$overall.se)))
  cs_p_benes <- 2 * (1 - pnorm(abs(results$att_overall_benes$overall.att /
                                     results$att_overall_benes$overall.se)))

  cs_tex <- c(cs_tex,
    sprintf("Overall ATT & %.4f%s & %.4f%s & %.4f%s \\\\",
            results$att_overall_prov$overall.att, sig_stars(cs_p_prov),
            results$att_overall_claims$overall.att, sig_stars(cs_p_claims),
            results$att_overall_benes$overall.att, sig_stars(cs_p_benes)),
    sprintf(" & (%.4f) & (%.4f) & (%.4f) \\\\",
            results$att_overall_prov$overall.se,
            results$att_overall_claims$overall.se,
            results$att_overall_benes$overall.se),
    ## v2: RI p-value for CS-DiD
    sprintf("RI $p$-value & \\multicolumn{3}{c}{%.3f (500 permutations)} \\\\",
            if (!is.na(robust$ri_cs_pvalue)) robust$ri_cs_pvalue else NA)
  )
}

cs_tex <- c(cs_tex,
  "\\midrule",
  sprintf("TWFE Estimate & %.4f%s & %.4f%s & %.4f%s \\\\",
          coef(results$twfe_providers)["post_treat"],
          sig_stars(pvalue(results$twfe_providers)["post_treat"]),
          coef(results$twfe_claims)["post_treat"],
          sig_stars(pvalue(results$twfe_claims)["post_treat"]),
          coef(results$twfe_benes)["post_treat"],
          sig_stars(pvalue(results$twfe_benes)["post_treat"])),
  sprintf(" & (%.4f) & (%.4f) & (%.4f) \\\\",
          se(results$twfe_providers)["post_treat"],
          se(results$twfe_claims)["post_treat"],
          se(results$twfe_benes)["post_treat"]),
  "\\midrule",
  "Control Group & Never-Treated & Never-Treated & Never-Treated \\\\",
  sprintf("States & %d & %d & %d \\\\", n_states, n_states, n_states),
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{minipage}{0.85\\textwidth}",
  "\\vspace{4pt}",
  "\\footnotesize \\textit{Notes:} Top panel reports the aggregate ATT from \\citet{callaway2021difference} using never-treated states as the comparison group. RI $p$-value from 500 Fisher permutations of treatment assignment. Bottom panel reports standard TWFE for comparison. Standard errors (in parentheses) are clustered at the state level. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.1$.",
  "\\end{minipage}",
  "\\end{table}"
)

writeLines(cs_tex, file.path(TABLES, "tab3_cs_did.tex"))

## ============================================================================
## Table 4: Robustness Checks — v2: expanded with new tests, stars, state counts
## ============================================================================

cat("Table 4: Robustness...\n")

make_rob_row <- function(label, mod, var = "post_treat", notes = "") {
  b <- coef(mod)[var]
  s <- se(mod)[var]
  p <- pvalue(mod)[var]
  n_st <- length(unique(mod$fixef_id$state))
  sprintf("\\quad %s & %s%s & (%.4f) & %d & %s \\\\",
          label, sprintf("%.4f", b), sig_stars(p), s, n_st, notes)
}

rob_tex <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Robustness Checks}",
  "\\label{tab:robustness}",
  "\\begin{tabular}{lccrl}",
  "\\toprule",
  "Specification & Coefficient & SE & States & Notes \\\\",
  "\\midrule",
  "\\textit{Panel A: Baseline} & & & & \\\\",
  sprintf("\\quad TWFE (personal care providers) & %.4f%s & (%.4f) & %d & Main result \\\\",
          coef(results$twfe_providers)["post_treat"],
          sig_stars(pvalue(results$twfe_providers)["post_treat"]),
          se(results$twfe_providers)["post_treat"],
          n_states),
  "\\midrule",
  "\\textit{Panel B: Placebo Tests} & & & & \\\\",
  sprintf("\\quad E/M visit providers (99213/99214) & %.4f%s & (%.4f) & %d & Placebo \\\\",
          coef(robust$placebo_em)["post_treat"],
          sig_stars(pvalue(robust$placebo_em)["post_treat"]),
          se(robust$placebo_em)["post_treat"],
          n_states),
  sprintf("\\quad E/M visit claims & %.4f%s & (%.4f) & %d & Placebo \\\\",
          coef(robust$placebo_em_claims)["post_treat"],
          sig_stars(pvalue(robust$placebo_em_claims)["post_treat"]),
          se(robust$placebo_em_claims)["post_treat"],
          n_states),
  sprintf("\\quad Pre-treatment lead (12m early) & %.4f%s & (%.4f) & %d & Placebo \\\\",
          coef(robust$lead_prov)["lead_post"],
          sig_stars(pvalue(robust$lead_prov)["lead_post"]),
          se(robust$lead_prov)["lead_post"],
          n_states),
  "\\midrule",
  "\\textit{Panel C: Heterogeneity} & & & & \\\\",
  sprintf("\\quad Individual providers (Type 1) & %.4f%s & (%.4f) & %d & \\\\",
          coef(robust$het_indiv)["post_treat"],
          sig_stars(pvalue(robust$het_indiv)["post_treat"]),
          se(robust$het_indiv)["post_treat"],
          n_states),
  sprintf("\\quad Organizations (Type 2) & %.4f%s & (%.4f) & %d & \\\\",
          coef(robust$het_org)["post_treat"],
          sig_stars(pvalue(robust$het_org)["post_treat"]),
          se(robust$het_org)["post_treat"],
          n_states),
  sprintf("\\quad Sole proprietors & %.4f%s & (%.4f) & %d & \\\\",
          coef(robust$het_sole)["post_treat"],
          sig_stars(pvalue(robust$het_sole)["post_treat"]),
          se(robust$het_sole)["post_treat"],
          n_states),
  "\\midrule",
  "\\textit{Panel D: Sensitivity} & & & & \\\\",
  sprintf("\\quad Excluding COVID onset & %.4f%s & (%.4f) & %d & Mar--Jun 2020 \\\\",
          coef(robust$nocovid_prov)["post_treat"],
          sig_stars(pvalue(robust$nocovid_prov)["post_treat"]),
          se(robust$nocovid_prov)["post_treat"],
          n_states),
  sprintf("\\quad Excluding Wyoming & %.4f%s & (%.4f) & %d & Outlier dropped \\\\",
          coef(robust$nowy_prov)["post_treat"],
          sig_stars(pvalue(robust$nowy_prov)["post_treat"]),
          se(robust$nowy_prov)["post_treat"],
          n_states - 1)
)

## Add state-specific trends if available
if (!is.null(robust$sst_prov)) {
  rob_tex <- c(rob_tex,
    sprintf("\\quad State-specific linear trends & %.4f%s & (%.4f) & %d & \\\\",
            coef(robust$sst_prov)["post_treat"],
            sig_stars(pvalue(robust$sst_prov)["post_treat"]),
            se(robust$sst_prov)["post_treat"],
            n_states))
}

## Median detection
rob_tex <- c(rob_tex,
  sprintf("\\quad Median-based rate detection & %.4f%s & (%.4f) & %d & Alt.\\ detection \\\\",
          coef(robust$mod_med)["post_treat"],
          sig_stars(pvalue(robust$mod_med)["post_treat"]),
          se(robust$mod_med)["post_treat"],
          n_states),
  sprintf("\\quad Randomization inference & \\multicolumn{2}{c}{$p = %.3f$} & %d & 1,000 perms \\\\",
          robust$ri_pvalue, n_states),
  "\\midrule",
  "\\textit{Panel E: Dose-Response} & & & & \\\\",
  sprintf("\\quad Rate increase $\\times$ post & %.4f%s & (%.4f) & %d & Excl.\\ WY \\\\",
          coef(results$twfe_dose_prov)["post_dose"],
          sig_stars(pvalue(results$twfe_dose_prov)["post_dose"]),
          se(results$twfe_dose_prov)["post_dose"],
          n_states - 1),
  "\\midrule",
  "\\textit{Panel F: ARPA-Era Subsample} & & & & \\\\",
  sprintf("\\quad ARPA cohorts only (post Apr 2021) & %.4f%s & (%.4f) & %d & TWFE \\\\",
          coef(results$twfe_arpa_prov)["post_treat"],
          sig_stars(pvalue(results$twfe_arpa_prov)["post_treat"]),
          se(results$twfe_arpa_prov)["post_treat"],
          n_control + length(rc[treated == TRUE & treat_date >= "2021-04-01", state])),
  sprintf("\\quad Pre-ARPA cohorts only & %.4f%s & (%.4f) & %d & TWFE \\\\",
          coef(results$twfe_prearpa_prov)["post_treat"],
          sig_stars(pvalue(results$twfe_prearpa_prov)["post_treat"]),
          se(results$twfe_prearpa_prov)["post_treat"],
          n_control + length(rc[treated == TRUE & treat_date < "2021-04-01", state])),
  "\\midrule",
  "\\textit{Panel G: Mechanism Tests} & & & & \\\\",
  sprintf("\\quad Org share (Type 2 / total NPIs) & %.4f%s & (%.4f) & %d & \\\\",
          coef(results$mech_org_share)["post_treat"],
          sig_stars(pvalue(results$mech_org_share)["post_treat"]),
          se(results$mech_org_share)["post_treat"],
          n_states),
  sprintf("\\quad Log claims per provider & %.4f%s & (%.4f) & %d & Intensive margin \\\\",
          coef(results$mech_intensive)["post_treat"],
          sig_stars(pvalue(results$mech_intensive)["post_treat"]),
          se(results$mech_intensive)["post_treat"],
          n_states),
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{minipage}{0.95\\textwidth}",
  "\\vspace{4pt}",
  "\\footnotesize \\textit{Notes:} All regressions include state and month fixed effects with standard errors (in parentheses) clustered at the state level. Panel B tests whether personal care rate increases affect unrelated services (E/M visits) and whether a placebo treatment dated 12 months before actual treatment shows effects. Panel C splits by provider entity type. Panel D includes sensitivity to COVID-era exclusion, outlier removal, state-specific linear trends, and alternative rate detection. Panel E uses rate change magnitude as continuous treatment. Panel F separates ARPA-era (post April 2021) from pre-ARPA treatment cohorts. Panel G tests consolidation mechanisms. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.1$.",
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
## v2: Label ARPA era
treat_detail[, era := ifelse(treat_date >= "2021-04-01", "ARPA", "Pre-ARPA")]

tex5 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Detected HCBS Rate Increases by State}",
  "\\label{tab:treatment}",
  "\\footnotesize",
  "\\begin{tabular}{lcrrrl}",
  "\\toprule",
  "State & Treatment Quarter & Rate Before (\\$) & Rate After (\\$) & Change (\\%) & Era \\\\",
  "\\midrule"
)

for (i in seq_len(nrow(treat_detail))) {
  row <- treat_detail[i]
  tex5 <- c(tex5,
    sprintf("%s & %s & %.2f & %.2f & %.1f & %s \\\\",
            row$state, row$treat_quarter,
            row$rate_before, row$rate_after, row$pct_change * 100,
            row$era))
}

tex5 <- c(tex5,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{minipage}{0.90\\textwidth}",
  "\\vspace{4pt}",
  "\\footnotesize \\textit{Notes:} Rate changes detected from T-MSIS payment data using T1019-specific rates where available. ``Rate Before'' and ``Rate After'' are the 6-month average payment per claim before and after the detected jump. ``Era'' indicates whether the rate increase occurred before or after April 2021, the effective date of ARPA Section 9817.",
  "\\end{minipage}",
  "\\end{table}"
)

writeLines(tex5, file.path(TABLES, "tab5_treatment.tex"))

cat("\n=== All tables generated ===\n")
