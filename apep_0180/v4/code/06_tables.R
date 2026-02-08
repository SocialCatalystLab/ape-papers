# ============================================================================
# 06_tables.R - Generate all tables for the paper (v4)
# MVPF of Unconditional Cash Transfers in Kenya
# ============================================================================

source("00_packages.R")
load("../data/kenya_uct_data.RData")
load("../data/mvpf_clean.RData")
load("../data/main_results.RData")
load("../data/robustness_results.RData")

tab_dir <- "../tables"
dir.create(tab_dir, showWarnings = FALSE)

# ── Table 1: Treatment Effects from Original Studies ────────────────────────
# → paper.tex Table 1

table1_latex <- haushofer_shapiro_effects %>%
  filter(outcome %in% c("Total consumption", "Food consumption", "Non-food consumption",
                        "Total assets", "Livestock", "Non-agricultural revenue",
                        "Psychological wellbeing index")) %>%
  mutate(
    stars = case_when(
      pvalue < 0.001 ~ "***",
      pvalue < 0.01 ~ "**",
      pvalue < 0.05 ~ "*",
      TRUE ~ ""
    ),
    # Use 2 decimal places for index variables (small SEs), 1 for USD
    se_fmt = ifelse(se < 1, sprintf("%.2f", se), as.character(round(se, 0))),
    te_fmt = ifelse(abs(treatment_effect) < 1,
                    sprintf("%.2f", treatment_effect),
                    as.character(round(treatment_effect, 0))),
    cm_fmt = ifelse(abs(control_mean) < 1,
                    sprintf("%.1f", control_mean),
                    as.character(round(control_mean, 0)))
  )

sink(file.path(tab_dir, "table1_treatment_effects.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Treatment Effects on Household Outcomes}\n")
cat("\\label{tab:treatment_effects}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\hline\\hline\n")
cat("Outcome & Control Mean & Treatment Effect & SE & N \\\\\n")
cat("\\hline\n")
for (i in 1:nrow(table1_latex)) {
  cat(paste(
    table1_latex$outcome[i], "&",
    table1_latex$cm_fmt[i], "&",
    paste0(table1_latex$te_fmt[i], table1_latex$stars[i]), "&",
    paste0("(", table1_latex$se_fmt[i], ")"), "&",
    format(table1_latex$n_obs[i], big.mark = ","), "\\\\\n"
  ))
}
cat("\\hline\n")
cat("\\multicolumn{5}{l}{\\footnotesize Notes: ITT estimates from Haushofer \\& Shapiro (2016, QJE Tables 2--4).}\\\\\n")
cat("\\multicolumn{5}{l}{\\footnotesize All monetary values in USD PPP. N = 1,372 households. 9-month follow-up.}\\\\\n")
cat("\\multicolumn{5}{l}{\\footnotesize * p$<$0.05; ** p$<$0.01; *** p$<$0.001. SEs in parentheses.}\\\\\n")
cat("\\end{tabular}\n")
cat("\\end{table}\n")
sink()

cat("Table 1 generated.\n")

# ── Table 2: GE Effects (Egger et al.) ─────────────────────────────────────
# → paper.tex Table 2

sink(file.path(tab_dir, "table2_ge_effects.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{General Equilibrium Effects from Egger et al. (2022)}\n")
cat("\\label{tab:ge_effects}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\hline\\hline\n")
cat("Outcome & Recipients & (SE) & Non-Recipients & (SE) \\\\\n")
cat("\\hline\n")
for (i in 1:nrow(egger_ge_effects)) {
  cat(paste(
    egger_ge_effects$outcome[i], "&",
    round(egger_ge_effects$recipient_effect[i], 0), "&",
    paste0("(", round(egger_ge_effects$recipient_se[i], 0), ")"), "&",
    round(egger_ge_effects$nonrecipient_effect[i], 0), "&",
    paste0("(", round(egger_ge_effects$nonrecipient_se[i], 0), ")"),
    "\\\\\n"
  ))
}
cat("\\hline\n")
cat("\\multicolumn{5}{l}{\\footnotesize Notes: 18-month ITT estimates. All values in USD PPP annually. N = 10,546 households,}\\\\\n")
cat("\\multicolumn{5}{l}{\\footnotesize 653 villages. Standard errors clustered at the village level.}\\\\\n")
cat("\\end{tabular}\n")
cat("\\end{table}\n")
sink()

cat("Table 2 generated.\n")

# ── Table 3: Kenya Fiscal Parameters ───────────────────────────────────────
# → paper.tex Table 3

sink(file.path(tab_dir, "table3_fiscal_parameters.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Kenya Fiscal Parameters and Bootstrap Distributions}\n")
cat("\\label{tab:fiscal_params}\n")
cat("\\begin{tabular}{lcccl}\n")
cat("\\hline\\hline\n")
cat("Parameter & Value & Range & Distribution & Source \\\\\n")
cat("\\hline\n")
cat("\\textit{Tax rates} & & & & \\\\\n")
cat("\\quad VAT rate & 16\\% & --- & Fixed & Kenya Revenue Authority \\\\\n")
cat("\\quad Effective income tax & 18.5\\% & --- & Fixed & KNBS Economic Survey 2022 \\\\\n")
cat("& & & & \\\\\n")
cat("\\textit{Structural parameters} & & & & \\\\\n")
cat("\\quad Informal sector share & 80\\% & [60\\%, 95\\%] & $\\text{Beta}(8, 2)$ & ILO Kenya 2021; Bachas et al. \\\\\n")
cat("\\quad VAT coverage & 50\\% & [25\\%, 75\\%] & $\\text{Beta}(5, 5)$ & KIHBS 2015/16 \\\\\n")
cat("\\quad MCPF & 1.3 & [1.0, 2.0] & Fixed & Auriol \\& Warlters (2012) \\\\\n")
cat("& & & & \\\\\n")
cat("\\textit{Persistence} & & & & \\\\\n")
cat("\\quad Consumption retention & 48\\%/yr & --- & Fixed & $\\gamma = \\sqrt{0.23}$; Haushofer \\& Shapiro (2018) \\\\\n")
cat("\\quad Earnings retention & 75\\%/yr & --- & Fixed & Blattman et al. (2020) \\\\\n")
cat("\\quad Discount rate & 5\\% & [3\\%, 10\\%] & Fixed & Standard \\\\\n")
cat("& & & & \\\\\n")
cat("\\textit{Program parameters} & & & & \\\\\n")
cat("\\quad Transfer amount & \\$1,000 & --- & Fixed & GiveDirectly \\\\\n")
cat("\\quad Admin cost rate & 15\\% & --- & Fixed & GiveDirectly AR 2023 \\\\\n")
cat("\\quad PPP conversion & 2.515 & --- & Fixed & World Bank ICP \\\\\n")
cat("& & & & \\\\\n")
cat("\\textit{Treatment effects} & & & & \\\\\n")
cat("\\quad $\\Delta C$ (consumption) & \\$35 & --- & $N(35, 8^2)$ & Haushofer \\& Shapiro (2016) \\\\\n")
cat("\\quad $\\Delta E$ (earnings) & \\$17 & --- & $N(17, 7^2)$ & Haushofer \\& Shapiro (2016) \\\\\n")
cat("\\quad Correlation $\\rho$ & 0 & [$-$0.25, 0.75] & Varied & Sensitivity analysis \\\\\n")
cat("\\hline\n")
cat("\\multicolumn{5}{l}{\\footnotesize Notes: Distribution column shows parameterization used in 5,000-draw bootstrap.}\\\\\n")
cat("\\multicolumn{5}{l}{\\footnotesize $\\text{Beta}(\\alpha, \\beta)$ scaled to Range; $N(\\mu, \\sigma^2)$ from published SEs.}\\\\\n")
cat("\\multicolumn{5}{l}{\\footnotesize Treatment effects drawn jointly as bivariate normal with correlation $\\rho$.}\\\\\n")
cat("\\end{tabular}\n")
cat("\\end{table}\n")
sink()

cat("Table 3 generated.\n")

# ── Table 4: MVPF Calculation Components ───────────────────────────────────
# → paper.tex Table 4

sink(file.path(tab_dir, "table4_mvpf_components.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{MVPF Calculation Components}\n")
cat("\\label{tab:mvpf_components}\n")
cat("\\begin{tabular}{lrl}\n")
cat("\\hline\\hline\n")
cat("Component & Value (USD) & Notes \\\\\n")
cat("\\hline\n")
cat("\\textit{Panel A: Willingness to Pay} & & \\\\\n")
cat(paste0("\\quad Direct transfer (net of admin) & \\$", round(wtp_direct, 0),
    " & Transfer $\\times$ (1 $-$ 0.15) \\\\\n"))
cat(paste0("\\quad Spillover WTP (per recipient) & \\$", round(wtp_spillover_per_recipient, 0),
    " & Non-recipient consumption $\\times$ 0.5 \\\\\n"))
cat(paste0("\\quad Total WTP & \\$", round(wtp_total, 0), " & \\\\\n"))
cat("& & \\\\\n")
cat("\\textit{Panel B: Net Government Cost} & & \\\\\n")
cat("\\quad Gross transfer & \\$1,000 & \\\\\n")
cat(paste0("\\quad Less: VAT on recipient consumption & $-$\\$", round(pv_vat, 2),
    " & 16\\% $\\times$ 50\\% coverage $\\times$ PV(3yr) \\\\\n"))
cat(paste0("\\quad Less: Income tax on earnings & $-$\\$", round(pv_income_tax, 2),
    " & 18.5\\% $\\times$ 20\\% formal $\\times$ PV(5yr) \\\\\n"))
cat(paste0("\\quad Less: VAT on non-recip. consumption & $-$\\$", round(pv_nonrecipient_vat, 2),
    " & Extended specification only \\\\\n"))
cat(paste0("\\quad Net cost (baseline) & \\$", round(net_cost, 1), " & \\\\\n"))
cat(paste0("\\quad Net cost (extended) & \\$", round(net_cost_extended, 1), " & Including non-recipient FE \\\\\n"))
cat("& & \\\\\n")
cat("\\textit{Panel C: MVPF Estimates} & & 95\\% CI \\\\\n")
cat(paste0("\\quad Direct, no MCPF & ", sprintf("%.3f", as.numeric(mvpf_direct_no_mcpf)),
    " & [", sprintf("%.3f", ci_direct[1]), ", ", sprintf("%.3f", ci_direct[2]), "] \\\\\n"))
cat(paste0("\\quad Direct, MCPF = 1.3 & ", sprintf("%.3f", as.numeric(mvpf_direct_mcpf)),
    " & [", sprintf("%.3f", ci_mcpf[1]), ", ", sprintf("%.3f", ci_mcpf[2]), "] \\\\\n"))
cat(paste0("\\quad With spillovers & ", sprintf("%.3f", as.numeric(mvpf_total_no_mcpf)),
    " & [", sprintf("%.3f", ci_total[1]), ", ", sprintf("%.3f", ci_total[2]), "] \\\\\n"))
cat(paste0("\\quad With spillovers + MCPF & ", sprintf("%.3f", as.numeric(mvpf_total_mcpf)),
    " & [", sprintf("%.3f", ci_total_mcpf[1]), ", ", sprintf("%.3f", ci_total_mcpf[2]), "] \\\\\n"))
cat(paste0("\\quad Extended (+ NR FE) & ", sprintf("%.3f", as.numeric(mvpf_extended)),
    " & [", sprintf("%.3f", ci_extended[1]), ", ", sprintf("%.3f", ci_extended[2]), "] \\\\\n"))
cat("\\hline\n")
cat("\\multicolumn{3}{l}{\\footnotesize Notes: 95\\% CIs from correlated bootstrap (5,000 replications, $\\rho = 0$).}\\\\\n")
cat("\\multicolumn{3}{l}{\\footnotesize Panel B values rounded for presentation; MVPF computed from exact values.}\\\\\n")
cat("\\end{tabular}\n")
cat("\\end{table}\n")
sink()

cat("Table 4 generated.\n")

# ── Table 5: MVPF Comparison with US Programs ─────────────────────────────
# → paper.tex Table 5

sink(file.path(tab_dir, "table5_us_comparison.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{MVPF Comparison: Kenya UCT vs.\\ US Transfer Programs}\n")
cat("\\label{tab:mvpf_comparison}\n")
cat("\\begin{tabular}{llcc}\n")
cat("\\hline\\hline\n")
cat("Policy & Category & Country & MVPF \\\\\n")
cat("\\hline\n")

comp_print <- comparison_df %>%
  filter(!is.infinite(mvpf)) %>%
  arrange(desc(mvpf))
for (i in 1:nrow(comp_print)) {
  cat(paste(
    comp_print$policy[i], "&",
    comp_print$category[i], "&",
    ifelse(grepl("Kenya", comp_print$policy[i]), "Kenya", "US"), "&",
    round(comp_print$mvpf[i], 2), "\\\\\n"
  ))
}
cat("\\hline\n")
cat("\\multicolumn{4}{l}{\\footnotesize Notes: US MVPFs from Hendren \\& Sprung-Keyser (2020 QJE).}\\\\\n")
cat("\\multicolumn{4}{l}{\\footnotesize Kenya MVPF is baseline (direct WTP, no MCPF). Programs with MVPF = $\\infty$ omitted.}\\\\\n")
cat("\\end{tabular}\n")
cat("\\end{table}\n")
sink()

cat("Table 5 generated.\n")

# ── Table 6: Sensitivity Summary ──────────────────────────────────────────
# → paper.tex Table 6

sink(file.path(tab_dir, "table6_sensitivity.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Sensitivity of MVPF to Key Assumptions}\n")
cat("\\label{tab:sensitivity}\n")
cat("\\begin{tabular}{lcc}\n")
cat("\\hline\\hline\n")
cat("Assumption & MVPF & Change (\\%) \\\\\n")
cat("\\hline\n")
# Group labels for clarity
groups <- c(
  "Persistence: 1 year" = "persistence",
  "High informality (90%)" = "informality",
  "Discount: 3%" = "discount",
  "MCPF: 1.0" = "mcpf",
  "VAT coverage: 25%" = "vat",
  "Pecuniary spillovers: 50%" = "spillover",
  "WTP ratio: 0.90" = "wtp",
  "Lower bound" = "bounds"
)
# Build rows, then add spacing to last row of each group
rows <- character(0)
row_groups <- character(0)
for (i in 1:nrow(sensitivity_summary)) {
  param <- sensitivity_summary$parameter[i]
  bold <- param %in% c("Baseline", "Lower bound", "Upper bound")
  bold_start <- ifelse(bold, "\\textbf{", "")
  bold_end <- ifelse(bold, "}", "")

  this_group <- groups[param]
  if (is.na(this_group)) this_group <- if (length(row_groups) > 0) tail(row_groups, 1) else ""

  row_text <- paste0(
    bold_start, param, bold_end, " & ",
    bold_start, sprintf("%.3f", sensitivity_summary$mvpf[i]), bold_end, " & ",
    bold_start, sprintf("%+.1f", sensitivity_summary$change_pct[i]), bold_end
  )
  rows <- c(rows, row_text)
  row_groups <- c(row_groups, this_group)
}

# Output rows with extra spacing at group boundaries
for (i in seq_along(rows)) {
  suffix <- " \\\\\n"
  cat(paste0(rows[i], suffix))
  param <- sensitivity_summary$parameter[i]
  if (param == "Baseline") cat("\\hline\n")
}
cat("\\hline\n")
cat("\\multicolumn{3}{l}{\\footnotesize Notes: Each row varies one parameter from baseline, holding all others fixed.}\\\\\n")
cat("\\multicolumn{3}{l}{\\footnotesize MVPF = direct WTP / net cost (no MCPF). Change relative to baseline MVPF = 0.867.}\\\\\n")
cat("\\end{tabular}\n")
cat("\\end{table}\n")
sink()

cat("Table 6 generated.\n")

# ── Table 7: Government Implementation Scenarios ──────────────────────────
# → paper.tex Table 7

sink(file.path(tab_dir, "table7_government_scenarios.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{MVPF Under Alternative Implementation Scenarios}\n")
cat("\\label{tab:gov_scenarios}\n")
cat("\\begin{tabular}{lccccc}\n")
cat("\\hline\\hline\n")
cat("Scenario & Admin Cost & Leakage & Effective WTP & MVPF & MVPF (spillovers) \\\\\n")
cat("\\hline\n")
for (i in 1:nrow(gov_results)) {
  cat(paste(
    gov_results$scenario[i], "&",
    paste0(round(gov_results$admin_cost[i] * 100, 0), "\\%"), "&",
    paste0(round(gov_results$leakage[i] * 100, 0), "\\%"), "&",
    paste0("\\$", round(gov_results$effective_wtp[i], 0)), "&",
    sprintf("%.3f", gov_results$mvpf[i]), "&",
    sprintf("%.3f", gov_results$mvpf_with_spillover[i]), "\\\\\n"
  ))
}
cat("\\hline\n")
cat("\\multicolumn{6}{l}{\\footnotesize Notes: Admin cost reduces effective transfer. Leakage = share reaching non-poor}\\\\\n")
cat("\\multicolumn{6}{l}{\\footnotesize (WTP$_{\\text{non-poor}}$ = 0.5 $\\times$ WTP$_{\\text{poor}}$). Net cost held at baseline.}\\\\\n")
cat("\\end{tabular}\n")
cat("\\end{table}\n")
sink()

cat("Table 7 generated.\n")

# ── Table 8: Covariance Sensitivity ───────────────────────────────────────
# → paper.tex Table 8

sink(file.path(tab_dir, "table8_covariance.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{MVPF Sensitivity to Treatment Effect Correlation}\n")
cat("\\label{tab:covariance}\n")
cat("\\begin{tabular}{ccccc}\n")
cat("\\hline\\hline\n")
cat("$\\rho$ & MVPF (mean) & SD & 95\\% CI lower & 95\\% CI upper \\\\\n")
cat("\\hline\n")
for (i in 1:nrow(covariance_results)) {
  cat(paste(
    sprintf("%.2f", covariance_results$rho[i]), "&",
    round(covariance_results$mvpf_mean[i], 3), "&",
    round(covariance_results$mvpf_sd[i], 4), "&",
    round(covariance_results$ci_lo[i], 3), "&",
    round(covariance_results$ci_hi[i], 3), "\\\\\n"
  ))
}
cat("\\hline\n")
cat("\\multicolumn{5}{l}{\\footnotesize Notes: $\\rho$ = correlation between consumption and earnings treatment effects.}\\\\\n")
cat("\\multicolumn{5}{l}{\\footnotesize MVPF includes spillovers. 5,000 bootstrap replications per $\\rho$.}\\\\\n")
cat("\\end{tabular}\n")
cat("\\end{table}\n")
sink()

cat("Table 8 generated.\n")

# ── Summary ───────────────────────────────────────────────────────────────

cat("\n=== All 8 Tables Generated ===\n")
cat("1. table1_treatment_effects.tex\n")
cat("2. table2_ge_effects.tex\n")
cat("3. table3_fiscal_parameters.tex\n")
cat("4. table4_mvpf_components.tex\n")
cat("5. table5_us_comparison.tex\n")
cat("6. table6_sensitivity.tex\n")
cat("7. table7_government_scenarios.tex\n")
cat("8. table8_covariance.tex\n")
cat("Saved to:", tab_dir, "\n")
