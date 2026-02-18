## ============================================================================
## 06_tables.R — Generate all tables (LaTeX output)
## Paper: Medicaid Postpartum Coverage Extensions and Provider Supply
## ============================================================================

source("00_packages.R")
library(did)

DATA <- "../data"
TAB  <- "../tables"
dir.create(TAB, showWarnings = FALSE)

## ---- Load data ----
panel   <- readRDS(file.path(DATA, "panel_analysis.rds"))
results <- readRDS(file.path(DATA, "main_results.rds"))
robust  <- readRDS(file.path(DATA, "robustness_results.rds"))
treatment_dates <- readRDS(file.path(DATA, "treatment_dates.rds"))

## ===================================================================
## Table 1: Summary Statistics
## ===================================================================
cat("Creating Table 1: Summary statistics...\n")

# Pre-treatment summary (before any state adopted: Jan 2018 – Sept 2021)
pre <- panel[month_date < as.Date("2021-10-01")]
post <- panel[treated == 1]
full <- panel

make_sumstats <- function(dt, label) {
  data.table(
    Sample = label,
    `Postpartum claims (59430)` = sprintf("%.1f (%.1f)", mean(dt$claims_postpartum, na.rm = TRUE), sd(dt$claims_postpartum, na.rm = TRUE)),
    `Antepartum claims` = sprintf("%.1f (%.1f)", mean(dt$claims_antepartum, na.rm = TRUE), sd(dt$claims_antepartum, na.rm = TRUE)),
    `Contraceptive claims` = sprintf("%.1f (%.1f)", mean(dt$claims_contraceptive, na.rm = TRUE), sd(dt$claims_contraceptive, na.rm = TRUE)),
    `Delivery claims` = sprintf("%.1f (%.1f)", mean(dt$claims_delivery, na.rm = TRUE), sd(dt$claims_delivery, na.rm = TRUE)),
    `Postpartum providers` = sprintf("%.1f (%.1f)", mean(dt$n_providers_postpartum, na.rm = TRUE), sd(dt$n_providers_postpartum, na.rm = TRUE)),
    `OB/GYN providers (any code)` = sprintf("%.1f (%.1f)", mean(dt$n_obgyn_billing, na.rm = TRUE), sd(dt$n_obgyn_billing, na.rm = TRUE)),
    `N (state-months)` = as.character(nrow(dt)),
    `States` = as.character(uniqueN(dt$state))
  )
}

sumstats <- rbind(
  make_sumstats(pre, "Pre-treatment"),
  make_sumstats(post, "Post-treatment (treated)"),
  make_sumstats(full, "Full sample")
)

# Write LaTeX
sink(file.path(TAB, "tab1_summary_stats.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics: Maternal Health Claims in Medicaid}\n")
cat("\\label{tab:summary}\n")
cat("\\small\n")
cat("\\begin{tabular}{lccc}\n")
cat("\\hline\\hline\n")
cat(" & Pre-Treatment & Post-Treatment & Full Sample \\\\\n")
cat(" & (Jan 2018--Sept 2021) & (Treated states) & \\\\\n")
cat("\\hline\n")
cat("\\multicolumn{4}{l}{\\textit{Panel A: Claims per state-month}} \\\\\n")
cat(sprintf("Postpartum care (59430) & %s & %s & %s \\\\\n",
    sumstats[1, `Postpartum claims (59430)`],
    sumstats[2, `Postpartum claims (59430)`],
    sumstats[3, `Postpartum claims (59430)`]))
cat(sprintf("Antepartum care (59425/26) & %s & %s & %s \\\\\n",
    sumstats[1, `Antepartum claims`],
    sumstats[2, `Antepartum claims`],
    sumstats[3, `Antepartum claims`]))
cat(sprintf("Contraceptive services & %s & %s & %s \\\\\n",
    sumstats[1, `Contraceptive claims`],
    sumstats[2, `Contraceptive claims`],
    sumstats[3, `Contraceptive claims`]))
cat(sprintf("Delivery (594XX) & %s & %s & %s \\\\\n",
    sumstats[1, `Delivery claims`],
    sumstats[2, `Delivery claims`],
    sumstats[3, `Delivery claims`]))
cat("[6pt]\n")
cat("\\multicolumn{4}{l}{\\textit{Panel B: Providers per state-month}} \\\\\n")
cat(sprintf("Postpartum providers & %s & %s & %s \\\\\n",
    sumstats[1, `Postpartum providers`],
    sumstats[2, `Postpartum providers`],
    sumstats[3, `Postpartum providers`]))
cat(sprintf("OB/GYN providers (any code) & %s & %s & %s \\\\\n",
    sumstats[1, `OB/GYN providers (any code)`],
    sumstats[2, `OB/GYN providers (any code)`],
    sumstats[3, `OB/GYN providers (any code)`]))
cat("[6pt]\n")
cat(sprintf("State-months & %s & %s & %s \\\\\n",
    sumstats[1, `N (state-months)`],
    sumstats[2, `N (state-months)`],
    sumstats[3, `N (state-months)`]))
cat(sprintf("States & %s & %s & %s \\\\\n",
    sumstats[1, `States`],
    sumstats[2, `States`],
    sumstats[3, `States`]))
cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.95\\linewidth}\n")
cat("\\vspace{6pt}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} Mean (standard deviation) reported. Pre-treatment period defined as January 2018 through September 2021 (before any state adopted the 12-month postpartum extension). Post-treatment includes only state-months where the extension is in effect. Claims and provider counts are at the state-month level. Data from T-MSIS Medicaid Provider Spending (2018--2024) linked to NPPES for provider identification.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

## ===================================================================
## Table 2: Main DiD Results
## ===================================================================
cat("Creating Table 2: Main results...\n")

# Helper to format estimates
fmt_est <- function(att, se) {
  p <- 2 * pnorm(-abs(att / se))
  stars <- ifelse(p < 0.01, "***", ifelse(p < 0.05, "**", ifelse(p < 0.10, "*", "")))
  sprintf("%.4f%s", att, stars)
}
fmt_se <- function(se) sprintf("(%.4f)", se)

sink(file.path(TAB, "tab2_main_results.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Effect of Postpartum Coverage Extensions on Maternal Health Provider Supply}\n")
cat("\\label{tab:main_results}\n")
cat("\\small\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\hline\\hline\n")
cat(" & Log Post- & Log Post- & Log Contra- & Log OB/GYN \\\\\n")
cat(" & partum & partum & ceptive & Providers \\\\\n")
cat(" & Claims & Providers & Claims & (any code) \\\\\n")
cat(" & (1) & (2) & (3) & (4) \\\\\n")
cat("\\hline\n")
cat("\\multicolumn{5}{l}{\\textit{Panel A: Callaway \\& Sant'Anna (2021)}} \\\\\n")

# CS-DiD ATTs
cat(sprintf("ATT & %s & %s & %s & %s \\\\\n",
    fmt_est(results$agg_pp_claims$overall.att, results$agg_pp_claims$overall.se),
    fmt_est(results$agg_pp_providers$overall.att, results$agg_pp_providers$overall.se),
    fmt_est(results$agg_contra$overall.att, results$agg_contra$overall.se),
    fmt_est(results$agg_obgyn$overall.att, results$agg_obgyn$overall.se)))
cat(sprintf(" & %s & %s & %s & %s \\\\\n",
    fmt_se(results$agg_pp_claims$overall.se),
    fmt_se(results$agg_pp_providers$overall.se),
    fmt_se(results$agg_contra$overall.se),
    fmt_se(results$agg_obgyn$overall.se)))

cat("[6pt]\n")
cat("\\multicolumn{5}{l}{\\textit{Panel B: TWFE}} \\\\\n")

# TWFE
twfe_list <- list(results$twfe_pp, results$twfe_providers,
                  results$twfe_contra, results$twfe_obgyn)
twfe_coefs <- sapply(twfe_list, function(m) coef(m)["treated"])
twfe_ses <- sapply(twfe_list, function(m) se(m)["treated"])

cat(sprintf("Treated & %s & %s & %s & %s \\\\\n",
    fmt_est(twfe_coefs[1], twfe_ses[1]),
    fmt_est(twfe_coefs[2], twfe_ses[2]),
    fmt_est(twfe_coefs[3], twfe_ses[3]),
    fmt_est(twfe_coefs[4], twfe_ses[4])))
cat(sprintf(" & %s & %s & %s & %s \\\\\n",
    fmt_se(twfe_ses[1]), fmt_se(twfe_ses[2]),
    fmt_se(twfe_ses[3]), fmt_se(twfe_ses[4])))

cat("[6pt]\n")
cat("\\multicolumn{5}{l}{\\textit{Panel C: TWFE post-PHE only (April 2023+)}} \\\\\n")

# Post-PHE TWFE
pp_coef <- coef(results$twfe_pp_post)["treated"]
pp_se <- se(results$twfe_pp_post)["treated"]
cat(sprintf("Treated & %s & & & \\\\\n", fmt_est(pp_coef, pp_se)))
cat(sprintf(" & %s & & & \\\\\n", fmt_se(pp_se)))

cat("[6pt]\n")
cat("\\multicolumn{5}{l}{\\textit{Panel D: Triple-difference (postpartum vs. antepartum)}} \\\\\n")

# Triple-diff: DDD = (treated effect on postpartum) - (treated effect on antepartum)
triple_coefs <- coef(results$twfe_triple)
triple_vcov  <- vcov(results$twfe_triple)
triple_names <- names(triple_coefs)
td_post_idx <- grep("treated.*postpartum_ind.*1", triple_names)
td_ante_idx <- grep("treated.*postpartum_ind.*0", triple_names)
if (length(td_post_idx) > 0 && length(td_ante_idx) > 0) {
  ddd_coef <- triple_coefs[td_post_idx[1]] - triple_coefs[td_ante_idx[1]]
  ddd_var  <- triple_vcov[td_post_idx[1], td_post_idx[1]] +
              triple_vcov[td_ante_idx[1], td_ante_idx[1]] -
              2 * triple_vcov[td_post_idx[1], td_ante_idx[1]]
  ddd_se   <- sqrt(ddd_var)
  cat(sprintf("Treated $\\times$ Postpartum & %s & & & \\\\\n",
      fmt_est(ddd_coef, ddd_se)))
  cat(sprintf(" & %s & & & \\\\\n",
      fmt_se(ddd_se)))
}

cat("[6pt]\n")
cat("\\hline\n")
cat("State FE & Yes & Yes & Yes & Yes \\\\\n")
cat("Month FE & Yes & Yes & Yes & Yes \\\\\n")
cat(sprintf("State-months & %d & %d & %d & %d \\\\\n",
    nrow(panel), nrow(panel), nrow(panel), nrow(panel)))
cat(sprintf("States & %d & %d & %d & %d \\\\\n",
    uniqueN(panel$state), uniqueN(panel$state),
    uniqueN(panel$state), uniqueN(panel$state)))
cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.95\\linewidth}\n")
cat("\\vspace{6pt}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} Panel A reports the simple aggregate ATT from Callaway and Sant'Anna (2021) with doubly robust estimation and not-yet-treated states as the control group. Panel B reports TWFE estimates with state and month fixed effects, clustering at the state level. Panel C restricts to the post-PHE period (April 2023 onward) when extensions create new coverage. Panel D reports the triple-difference coefficient: the difference between the treated effect on postpartum claims and the treated effect on antepartum claims, estimated jointly with state$\\times$type and month$\\times$type fixed effects. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

## ===================================================================
## Table 3: Robustness Checks
## ===================================================================
cat("Creating Table 3: Robustness...\n")

sink(file.path(TAB, "tab3_robustness.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Robustness Checks}\n")
cat("\\label{tab:robustness}\n")
cat("\\small\n")
cat("\\begin{tabular}{lcc}\n")
cat("\\hline\\hline\n")
cat(" & Log Postpartum & Log Postpartum \\\\\n")
cat(" & Claims & Providers \\\\\n")
cat("\\hline\n")

# Row 1: Baseline CS-DiD
cat(sprintf("Baseline (CS-DiD) & %s & %s \\\\\n",
    fmt_est(results$agg_pp_claims$overall.att, results$agg_pp_claims$overall.se),
    fmt_est(results$agg_pp_providers$overall.att, results$agg_pp_providers$overall.se)))
cat(sprintf(" & %s & %s \\\\\n",
    fmt_se(results$agg_pp_claims$overall.se),
    fmt_se(results$agg_pp_providers$overall.se)))

# Row 2: TWFE with state trends
cat("[4pt]\n")
tw_tr_coef1 <- coef(robust$twfe_trend_pp)["treated"]
tw_tr_se1 <- se(robust$twfe_trend_pp)["treated"]
tw_tr_coef2 <- coef(robust$twfe_trend_providers)["treated"]
tw_tr_se2 <- se(robust$twfe_trend_providers)["treated"]
cat(sprintf("TWFE + state trends & %s & %s \\\\\n",
    fmt_est(tw_tr_coef1, tw_tr_se1), fmt_est(tw_tr_coef2, tw_tr_se2)))
cat(sprintf(" & %s & %s \\\\\n", fmt_se(tw_tr_se1), fmt_se(tw_tr_se2)))

# Row 3: Balanced panel
cat("[4pt]\n")
cat(sprintf("Balanced panel (\\geq 90\\%% nonzero) & %s & \\\\\n",
    fmt_est(robust$agg_balanced$overall.att, robust$agg_balanced$overall.se)))
cat(sprintf(" & %s & \\\\\n", fmt_se(robust$agg_balanced$overall.se)))

# Row 4: RI p-value
cat("[4pt]\n")
cat(sprintf("Randomization inference $p$-value & [%.3f] & \\\\\n", robust$ri_pvalue))

# Row 5: Placebos
cat("[6pt]\n")
cat("\\multicolumn{3}{l}{\\textit{Placebo outcomes (CS-DiD):}} \\\\\n")
cat(sprintf("\\quad Antepartum claims & %s & \\\\\n",
    fmt_est(robust$agg_ante$overall.att, robust$agg_ante$overall.se)))
cat(sprintf(" & %s & \\\\\n", fmt_se(robust$agg_ante$overall.se)))
cat(sprintf("\\quad Delivery claims & %s & \\\\\n",
    fmt_est(robust$agg_delivery$overall.att, robust$agg_delivery$overall.se)))
cat(sprintf(" & %s & \\\\\n", fmt_se(robust$agg_delivery$overall.se)))

cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.85\\linewidth}\n")
cat("\\vspace{6pt}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} All specifications use log-transformed outcomes. Baseline is the Callaway and Sant'Anna (2021) doubly robust estimator with not-yet-treated controls. TWFE + state trends adds state-specific linear time trends. Balanced panel restricts to states with non-zero postpartum claims in $\\geq$90\\% of months. RI $p$-value from 1,000 permutations of state treatment assignment. Placebo outcomes should show no effect: antepartum care and delivery are unaffected by the postpartum extension. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

## ===================================================================
## Table 4: Adoption Timeline
## ===================================================================
cat("Creating Table 4: Adoption timeline...\n")

treat_tab <- treatment_dates[treat_date <= as.Date("2024-12-31")]
treat_tab[, wave := fcase(
  treat_date < as.Date("2022-04-01"), "Pre-ARP waiver",
  treat_date == as.Date("2022-04-01"), "Wave 1 (April 2022)",
  treat_date <= as.Date("2022-12-31"), "Wave 2 (May--Dec 2022)",
  treat_date <= as.Date("2023-12-31"), "Wave 3 (2023)",
  default = "Wave 4 (2024)"
)]
setorder(treat_tab, treat_date, state)

sink(file.path(TAB, "tab4_adoption_timeline.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Staggered Adoption of 12-Month Medicaid Postpartum Coverage Extensions}\n")
cat("\\label{tab:adoption}\n")
cat("\\small\n")
cat("\\begin{tabular}{llcl}\n")
cat("\\hline\\hline\n")
cat("Wave & States & N & Effective Date \\\\\n")
cat("\\hline\n")

for (w in c("Pre-ARP waiver", "Wave 1 (April 2022)", "Wave 2 (May--Dec 2022)",
            "Wave 3 (2023)", "Wave 4 (2024)")) {
  sub <- treat_tab[wave == w]
  states_str <- paste(sub$state, collapse = ", ")
  n <- nrow(sub)
  dates <- unique(format(sub$treat_date, "%b %Y"))
  date_str <- paste(dates, collapse = "; ")
  cat(sprintf("%s & %s & %d & %s \\\\\n", w, states_str, n, date_str))
}
cat("[4pt]\n")
cat("Never adopted & AR, WI & 2 & --- \\\\\n")

cat("\\hline\\hline\n")
cat("\\end{tabular}\n")
cat("\\begin{minipage}{0.95\\linewidth}\n")
cat("\\vspace{6pt}\n")
cat("\\footnotesize\n")
cat("\\textit{Notes:} Adoption dates represent the effective date of the State Plan Amendment (SPA) or 1115 waiver extending Medicaid postpartum coverage from 60 days to 12 months. Source: KFF Medicaid Postpartum Coverage Extension Tracker, CMS SPA approvals. Idaho and Iowa adopted in 2025, outside the T-MSIS data window (through December 2024), and are coded as never-treated in the estimation.\n")
cat("\\end{minipage}\n")
cat("\\end{table}\n")
sink()

cat("\n=== All tables saved to", TAB, "===\n")
