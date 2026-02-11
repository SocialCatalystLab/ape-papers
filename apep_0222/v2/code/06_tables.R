##############################################################################
# 06_tables.R — Publication-quality LaTeX tables
# APEP-0222 v2: Educational Content Restriction Laws and Teacher Labor Markets
# Revision: NAICS 6111 (K-12 Schools), Panel D female share, MDE, broad comparison
##############################################################################

source("00_packages.R")

cat("=== Generating tables ===\n")

# Load data and results
edu_panel <- readRDS("../data/edu_panel.rds")
panel <- readRDS("../data/panel.rds")
results <- readRDS("../data/main_results.rds")
treatment_laws <- readRDS("../data/treatment_laws.rds")
robust_results <- readRDS("../data/robust_results.rds")

# ============================================================================
# TABLE 1: Summary Statistics
# ============================================================================

cat("Table 1: Summary statistics...\n")

sum_data <- edu_panel %>%
  filter(!is.na(Emp), Emp > 0) %>%
  mutate(
    group = ifelse(treated_state, "Treated", "Never-Treated"),
    period = ifelse(year <= 2020, "Pre-Treatment (2015-2020)", "Post-Treatment (2021-2024)"),
    sep_rate = Sep / Emp,
    hire_rate = HirA / Emp
  )

# Compute stats
sum_stats <- sum_data %>%
  group_by(group, period) %>%
  summarise(
    N = n(),
    n_states = n_distinct(state_fips),
    mean_emp = mean(Emp, na.rm = TRUE),
    sd_emp = sd(Emp, na.rm = TRUE),
    mean_earn = mean(EarnS, na.rm = TRUE),
    sd_earn = sd(EarnS, na.rm = TRUE),
    mean_sep = mean(sep_rate, na.rm = TRUE),
    sd_sep = sd(sep_rate, na.rm = TRUE),
    mean_hire = mean(hire_rate, na.rm = TRUE),
    sd_hire = sd(hire_rate, na.rm = TRUE),
    mean_turn = mean(TurnOvrS, na.rm = TRUE),
    sd_turn = sd(TurnOvrS, na.rm = TRUE),
    .groups = "drop"
  )

# Format for LaTeX
n_treated <- n_distinct(edu_panel$state_fips[edu_panel$treated_state == TRUE])
n_control <- n_distinct(edu_panel$state_fips[edu_panel$treated_state == FALSE])

tab1_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Summary Statistics: K--12 Schools (NAICS 6111) by Treatment Status}",
  "\\label{tab:summary}",
  "\\begin{threeparttable}",
  "\\begin{tabular}{lcccc}",
  "\\toprule",
  sprintf(" & \\multicolumn{2}{c}{Treated States (N=%d)} & \\multicolumn{2}{c}{Never-Treated States (N=%d)} \\\\",
          n_treated, n_control),
  "\\cmidrule(lr){2-3} \\cmidrule(lr){4-5}",
  " & Pre & Post & Pre & Post \\\\",
  "\\midrule"
)

for (var_name in c("Employment", "Avg. Monthly Earnings (\\$)", "Separation Rate",
                   "Hire Rate", "Turnover Rate")) {
  var_map <- list(
    "Employment" = c("mean_emp", "sd_emp"),
    "Avg. Monthly Earnings (\\$)" = c("mean_earn", "sd_earn"),
    "Separation Rate" = c("mean_sep", "sd_sep"),
    "Hire Rate" = c("mean_hire", "sd_hire"),
    "Turnover Rate" = c("mean_turn", "sd_turn")
  )

  m_col <- var_map[[var_name]][1]
  s_col <- var_map[[var_name]][2]

  # Get values for each group-period
  vals <- list()
  for (g in c("Treated", "Never-Treated")) {
    for (p in c("Pre-Treatment (2015-2020)", "Post-Treatment (2021-2024)")) {
      row <- sum_stats %>% filter(group == g, period == p)
      if (nrow(row) > 0) {
        vals[[paste0(g, "_", p)]] <- c(row[[m_col]], row[[s_col]])
      } else {
        vals[[paste0(g, "_", p)]] <- c(NA, NA)
      }
    }
  }

  # Format numbers
  fmt <- function(x, d = 2) {
    if (is.na(x)) return("---")
    if (abs(x) >= 1000) return(format(round(x, 0), big.mark = ","))
    return(sprintf(paste0("%.", d, "f"), x))
  }

  tp <- vals[["Treated_Pre-Treatment (2015-2020)"]]
  tpo <- vals[["Treated_Post-Treatment (2021-2024)"]]
  np <- vals[["Never-Treated_Pre-Treatment (2015-2020)"]]
  npo <- vals[["Never-Treated_Post-Treatment (2021-2024)"]]

  tab1_lines <- c(tab1_lines,
    sprintf("%s & %s & %s & %s & %s \\\\", var_name, fmt(tp[1]), fmt(tpo[1]), fmt(np[1]), fmt(npo[1])),
    sprintf(" & (%s) & (%s) & (%s) & (%s) \\\\", fmt(tp[2]), fmt(tpo[2]), fmt(np[2]), fmt(npo[2]))
  )
}

# Add observation counts
pre_t <- sum_stats %>% filter(group == "Treated", period == "Pre-Treatment (2015-2020)")
post_t <- sum_stats %>% filter(group == "Treated", period == "Post-Treatment (2021-2024)")
pre_n <- sum_stats %>% filter(group == "Never-Treated", period == "Pre-Treatment (2015-2020)")
post_n <- sum_stats %>% filter(group == "Never-Treated", period == "Post-Treatment (2021-2024)")

tab1_lines <- c(tab1_lines,
  "\\midrule",
  sprintf("State-Quarters & %s & %s & %s & %s \\\\",
          format(pre_t$N, big.mark = ","),
          format(post_t$N, big.mark = ","),
          format(pre_n$N, big.mark = ","),
          format(post_n$N, big.mark = ",")),
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} Standard deviations in parentheses. Data from Census Quarterly Workforce Indicators (QWI), NAICS 6111 (Elementary and Secondary Schools), 2015Q1--2024Q4. Treated states enacted educational content restriction laws between 2021--2023. Employment is total quarterly employment; earnings are average monthly; separation and hire rates are quarterly flows divided by employment. All owners (public and private). Some state-quarters are suppressed at the 4-digit NAICS level due to disclosure avoidance.",
  "\\end{tablenotes}",
  "\\end{threeparttable}",
  "\\end{table}"
)

writeLines(tab1_lines, "../tables/tab1_summary.tex")
cat("  Saved: tab1_summary.tex\n")

# ============================================================================
# TABLE 2: Main Results — DiD Estimates
# ============================================================================

cat("Table 2: Main DiD results...\n")

# Extract CS aggregated results
extract_att <- function(agg_obj) {
  list(
    att = agg_obj$overall.att,
    se = agg_obj$overall.se,
    p = 2 * pnorm(-abs(agg_obj$overall.att / agg_obj$overall.se))
  )
}

cs_res <- list(
  emp = extract_att(results$agg_emp),
  sep = extract_att(results$agg_sep),
  earn = extract_att(results$agg_earn),
  hire = extract_att(results$agg_hire),
  turn = extract_att(results$agg_turn)
)

# Stars function
stars <- function(p) {
  if (is.na(p)) return("")
  if (p < 0.01) return("***")
  if (p < 0.05) return("**")
  if (p < 0.10) return("*")
  return("")
}

# TWFE results
twfe_res <- list(
  emp = list(att = coef(results$twfe_emp)["treat"],
             se = se(results$twfe_emp)["treat"],
             p = fixest::pvalue(results$twfe_emp)["treat"]),
  sep = list(att = coef(results$twfe_sep)["treat"],
             se = se(results$twfe_sep)["treat"],
             p = fixest::pvalue(results$twfe_sep)["treat"]),
  earn = list(att = coef(results$twfe_earn)["treat"],
              se = se(results$twfe_earn)["treat"],
              p = fixest::pvalue(results$twfe_earn)["treat"]),
  hire = list(att = coef(results$twfe_hire)["treat"],
              se = se(results$twfe_hire)["treat"],
              p = fixest::pvalue(results$twfe_hire)["treat"])
)

# DDD results
ddd_res <- list(
  emp = list(att = coef(results$ddd_emp)["DDD"],
             se = se(results$ddd_emp)["DDD"],
             p = fixest::pvalue(results$ddd_emp)["DDD"]),
  sep = list(att = coef(results$ddd_sep)["DDD"],
             se = se(results$ddd_sep)["DDD"],
             p = fixest::pvalue(results$ddd_sep)["DDD"]),
  earn = list(att = coef(results$ddd_earn)["DDD"],
              se = se(results$ddd_earn)["DDD"],
              p = fixest::pvalue(results$ddd_earn)["DDD"]),
  hire = list(att = coef(results$ddd_hire)["DDD"],
              se = se(results$ddd_hire)["DDD"],
              p = fixest::pvalue(results$ddd_hire)["DDD"])
)

# Female share results
fs_cs <- NULL
fs_twfe <- NULL
if (!is.null(results$agg_female)) {
  fs_cs <- extract_att(results$agg_female)
}
if (!is.null(results$twfe_female)) {
  fs_twfe <- list(
    att = coef(results$twfe_female)["treat"],
    se = se(results$twfe_female)["treat"],
    p = fixest::pvalue(results$twfe_female)["treat"]
  )
}

fmt_coef <- function(x, d = 4) sprintf(paste0("%.", d, "f"), x)

tab2_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Effect of Educational Content Restriction Laws on K--12 School Labor Markets}",
  "\\label{tab:main_results}",
  "\\begin{threeparttable}",
  "\\begin{tabular}{lcccc}",
  "\\toprule",
  " & Log Emp. & Sep. Rate & Log Earn. & Hire Rate \\\\",
  " & (1) & (2) & (3) & (4) \\\\",
  "\\midrule",
  "\\multicolumn{5}{l}{\\textit{Panel A: Callaway-Sant'Anna (2021)}} \\\\[3pt]",
  sprintf("ATT & %s%s & %s%s & %s%s & %s%s \\\\",
          fmt_coef(cs_res$emp$att), stars(cs_res$emp$p),
          fmt_coef(cs_res$sep$att), stars(cs_res$sep$p),
          fmt_coef(cs_res$earn$att), stars(cs_res$earn$p),
          fmt_coef(cs_res$hire$att), stars(cs_res$hire$p)),
  sprintf(" & (%s) & (%s) & (%s) & (%s) \\\\",
          fmt_coef(cs_res$emp$se), fmt_coef(cs_res$sep$se),
          fmt_coef(cs_res$earn$se), fmt_coef(cs_res$hire$se)),
  "[6pt]",
  "\\multicolumn{5}{l}{\\textit{Panel B: TWFE (state + quarter FE)}} \\\\[3pt]",
  sprintf("Treat & %s%s & %s%s & %s%s & %s%s \\\\",
          fmt_coef(twfe_res$emp$att), stars(twfe_res$emp$p),
          fmt_coef(twfe_res$sep$att), stars(twfe_res$sep$p),
          fmt_coef(twfe_res$earn$att), stars(twfe_res$earn$p),
          fmt_coef(twfe_res$hire$att), stars(twfe_res$hire$p)),
  sprintf(" & (%s) & (%s) & (%s) & (%s) \\\\",
          fmt_coef(twfe_res$emp$se), fmt_coef(twfe_res$sep$se),
          fmt_coef(twfe_res$earn$se), fmt_coef(twfe_res$hire$se)),
  "[6pt]",
  "\\multicolumn{5}{l}{\\textit{Panel C: Triple-Difference (K--12 vs. Healthcare)}} \\\\[3pt]",
  sprintf("DDD & %s%s & %s%s & %s%s & %s%s \\\\",
          fmt_coef(ddd_res$emp$att), stars(ddd_res$emp$p),
          fmt_coef(ddd_res$sep$att), stars(ddd_res$sep$p),
          fmt_coef(ddd_res$earn$att), stars(ddd_res$earn$p),
          fmt_coef(ddd_res$hire$att), stars(ddd_res$hire$p)),
  sprintf(" & (%s) & (%s) & (%s) & (%s) \\\\",
          fmt_coef(ddd_res$emp$se), fmt_coef(ddd_res$sep$se),
          fmt_coef(ddd_res$earn$se), fmt_coef(ddd_res$hire$se))
)

# Panel D: Female Share (CS + TWFE)
if (!is.null(fs_cs) || !is.null(fs_twfe)) {
  tab2_lines <- c(tab2_lines,
    "[6pt]",
    "\\multicolumn{5}{l}{\\textit{Panel D: Female Share (K--12 Schools)}} \\\\[3pt]"
  )
  if (!is.null(fs_cs)) {
    tab2_lines <- c(tab2_lines,
      sprintf("CS ATT & \\multicolumn{4}{c}{%s%s} \\\\",
              fmt_coef(fs_cs$att), stars(fs_cs$p)),
      sprintf(" & \\multicolumn{4}{c}{(%s)} \\\\",
              fmt_coef(fs_cs$se))
    )
  }
  if (!is.null(fs_twfe)) {
    tab2_lines <- c(tab2_lines,
      sprintf("TWFE & \\multicolumn{4}{c}{%s%s} \\\\",
              fmt_coef(fs_twfe$att), stars(fs_twfe$p)),
      sprintf(" & \\multicolumn{4}{c}{(%s)} \\\\",
              fmt_coef(fs_twfe$se))
    )
  }
}

tab2_lines <- c(tab2_lines,
  "\\midrule",
  sprintf("N (Panel A/B) & \\multicolumn{4}{c}{%s state-quarters} \\\\",
          format(nrow(edu_panel %>% filter(!is.na(Emp), Emp > 0) %>%
                       distinct(state_fips, time_int)), big.mark = ",")),
  sprintf("N (Panel C) & \\multicolumn{4}{c}{%s state-quarter-industries} \\\\",
          format(nrow(panel %>% filter(industry %in% c("6111", "62"), !is.na(Emp), Emp > 0) %>%
                       distinct(state_fips, time_int, industry)), big.mark = ",")),
  "Clustering & \\multicolumn{4}{c}{State} \\\\",
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} Standard errors clustered at the state level in parentheses. Panel A reports the overall ATT from \\citet{callaway2021difference} using never-treated states as the comparison group. Panel B reports TWFE estimates with state and quarter fixed effects. Panel C reports triple-difference estimates comparing K--12 schools (NAICS 6111) to healthcare (NAICS 62) within the same state-quarter, with state$\\times$industry, industry$\\times$quarter, and state$\\times$quarter fixed effects. Panel D reports the effect on female employment share in K--12 schools using both CS and TWFE estimators. $^{*}$ $p<0.10$, $^{**}$ $p<0.05$, $^{***}$ $p<0.01$.",
  "\\end{tablenotes}",
  "\\end{threeparttable}",
  "\\end{table}"
)

writeLines(tab2_lines, "../tables/tab2_main_results.tex")
cat("  Saved: tab2_main_results.tex\n")

# ============================================================================
# TABLE 3: Robustness — Alternative Estimators and Specifications
# ============================================================================

cat("Table 3: Robustness...\n")

tab3_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Robustness: Alternative Specifications for Log Employment}",
  "\\label{tab:robustness}",
  "\\begin{threeparttable}",
  "\\begin{tabular}{lcccc}",
  "\\toprule",
  "Specification & Estimate & SE & 95\\% CI & p-value \\\\",
  "\\midrule"
)

# Main CS
ci_lo <- cs_res$emp$att - 1.96 * cs_res$emp$se
ci_hi <- cs_res$emp$att + 1.96 * cs_res$emp$se
tab3_lines <- c(tab3_lines,
  sprintf("CS (never-treated) & %s%s & (%s) & [%s, %s] & %s \\\\",
          fmt_coef(cs_res$emp$att), stars(cs_res$emp$p),
          fmt_coef(cs_res$emp$se),
          fmt_coef(ci_lo), fmt_coef(ci_hi),
          fmt_coef(cs_res$emp$p, 3)))

# Not-yet-treated
if (!is.null(robust_results$agg_nyt)) {
  nyt <- extract_att(robust_results$agg_nyt)
  ci_lo_n <- nyt$att - 1.96 * nyt$se
  ci_hi_n <- nyt$att + 1.96 * nyt$se
  tab3_lines <- c(tab3_lines,
    sprintf("CS (not-yet-treated) & %s%s & (%s) & [%s, %s] & %s \\\\",
            fmt_coef(nyt$att), stars(nyt$p),
            fmt_coef(nyt$se),
            fmt_coef(ci_lo_n), fmt_coef(ci_hi_n),
            fmt_coef(nyt$p, 3)))
}

# TWFE
ci_lo_t <- twfe_res$emp$att - 1.96 * twfe_res$emp$se
ci_hi_t <- twfe_res$emp$att + 1.96 * twfe_res$emp$se
tab3_lines <- c(tab3_lines,
  sprintf("TWFE & %s%s & (%s) & [%s, %s] & %s \\\\",
          fmt_coef(twfe_res$emp$att), stars(twfe_res$emp$p),
          fmt_coef(twfe_res$emp$se),
          fmt_coef(ci_lo_t), fmt_coef(ci_hi_t),
          fmt_coef(twfe_res$emp$p, 3)))

# Sun-Abraham — re-estimate since saved object loses data reference
edu_panel_local <- readRDS("../data/edu_panel.rds")
cs_data_sa <- edu_panel_local %>%
  filter(!is.na(Emp), Emp > 0) %>%
  mutate(
    log_emp = log(Emp + 1),
    state_id = as.integer(factor(state_fips)),
    time_int = (year - 2015) * 4 + quarter,
    cohort = ifelse(first_treat_int == 0, 10000, first_treat_int)
  ) %>%
  distinct(state_id, time_int, .keep_all = TRUE)

sa_emp_local <- feols(log_emp ~ sunab(cohort, time_int) | state_id + time_int,
                      data = cs_data_sa, cluster = ~state_id)
sa_att <- summary(sa_emp_local, agg = "ATT")
sa_coef <- sa_att$coeftable[1, 1]
sa_se <- sa_att$coeftable[1, 2]
sa_p <- sa_att$coeftable[1, 4]
ci_lo_s <- sa_coef - 1.96 * sa_se
ci_hi_s <- sa_coef + 1.96 * sa_se
tab3_lines <- c(tab3_lines,
  sprintf("Sun-Abraham & %s%s & (%s) & [%s, %s] & %s \\\\",
          fmt_coef(sa_coef), stars(sa_p),
          fmt_coef(sa_se),
          fmt_coef(ci_lo_s), fmt_coef(ci_hi_s),
          fmt_coef(sa_p, 3)))

# DDD
ci_lo_d <- ddd_res$emp$att - 1.96 * ddd_res$emp$se
ci_hi_d <- ddd_res$emp$att + 1.96 * ddd_res$emp$se
tab3_lines <- c(tab3_lines,
  sprintf("Triple-Diff (K--12 vs HC) & %s%s & (%s) & [%s, %s] & %s \\\\",
          fmt_coef(ddd_res$emp$att), stars(ddd_res$emp$p),
          fmt_coef(ddd_res$emp$se),
          fmt_coef(ci_lo_d), fmt_coef(ci_hi_d),
          fmt_coef(ddd_res$emp$p, 3)))

# Broad Education (NAICS 61) comparison
if (!is.null(robust_results$agg_broad)) {
  broad_r <- extract_att(robust_results$agg_broad)
  ci_lo_b <- broad_r$att - 1.96 * broad_r$se
  ci_hi_b <- broad_r$att + 1.96 * broad_r$se
  tab3_lines <- c(tab3_lines,
    sprintf("CS: Broad Educ. (NAICS 61) & %s%s & (%s) & [%s, %s] & %s \\\\",
            fmt_coef(broad_r$att), stars(broad_r$p),
            fmt_coef(broad_r$se),
            fmt_coef(ci_lo_b), fmt_coef(ci_hi_b),
            fmt_coef(broad_r$p, 3)))
}

# Stringency heterogeneity
if (!is.null(robust_results$agg_strong)) {
  str_r <- extract_att(robust_results$agg_strong)
  tab3_lines <- c(tab3_lines,
    sprintf("CS: Strong laws only & %s%s & (%s) & & %s \\\\",
            fmt_coef(str_r$att), stars(str_r$p),
            fmt_coef(str_r$se), fmt_coef(str_r$p, 3)))
}
if (!is.null(robust_results$agg_mw)) {
  mw_r <- extract_att(robust_results$agg_mw)
  tab3_lines <- c(tab3_lines,
    sprintf("CS: Moderate/weak only & %s%s & (%s) & & %s \\\\",
            fmt_coef(mw_r$att), stars(mw_r$p),
            fmt_coef(mw_r$se), fmt_coef(mw_r$p, 3)))
}

# Fisher p-value and MDE
tab3_lines <- c(tab3_lines,
  "\\midrule",
  sprintf("Fisher exact p-value & \\multicolumn{4}{c}{%s (1,000 permutations)} \\\\",
          fmt_coef(robust_results$fisher_p, 3))
)

# MDE row
if (!is.null(robust_results$mde_results)) {
  mde_emp <- robust_results$mde_results %>% filter(outcome == "Log Employment")
  if (nrow(mde_emp) > 0) {
    tab3_lines <- c(tab3_lines,
      sprintf("MDE (80\\%% power) & \\multicolumn{4}{c}{%s log points} \\\\",
              fmt_coef(mde_emp$mde_80[1])))
  }
}

tab3_lines <- c(tab3_lines,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} All specifications use log employment in K--12 schools (NAICS 6111) as the outcome. Standard errors clustered at the state level. CS = \\citet{callaway2021difference}. TWFE = two-way fixed effects with state and quarter FE. Sun-Abraham = \\citet{sun2021estimating} interaction-weighted estimator. Triple-diff compares K--12 schools vs.~healthcare within the same state-quarter. ``Broad Educ.'' uses NAICS 61 (all educational services) for comparison with the narrower 6111 estimate. MDE = minimum detectable effect at 80\\% power and 5\\% significance ($\\text{MDE} = 2.8 \\times \\text{SE}$). Fisher p-value from 1,000 permutations of treatment assignment. $^{*}$ $p<0.10$, $^{**}$ $p<0.05$, $^{***}$ $p<0.01$.",
  "\\end{tablenotes}",
  "\\end{threeparttable}",
  "\\end{table}"
)

writeLines(tab3_lines, "../tables/tab3_robustness.tex")
cat("  Saved: tab3_robustness.tex\n")

# ============================================================================
# TABLE 4: Treatment Laws
# ============================================================================

cat("Table 4: Treatment law details...\n")

state_info <- tibble(
  state_fips = c("01","04","05","12","13","16","18","19","21","22","28","30","33",
                 "37","38","40","45","46","47","48","49","51","54"),
  state_abb = c("AL","AZ","AR","FL","GA","ID","IN","IA","KY","LA","MS","MT","NH",
                "NC","ND","OK","SC","SD","TN","TX","UT","VA","WV")
)

tab4_data <- treatment_laws %>%
  left_join(state_info, by = "state_fips") %>%
  arrange(effective_date) %>%
  select(state_name, state_abb, bill, effective_date, stringency)

tab4_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Educational Content Restriction Laws: Treatment Coding}",
  "\\label{tab:treatment_laws}",
  "\\begin{threeparttable}",
  "\\small",
  "\\begin{tabular}{llllc}",
  "\\toprule",
  "State & Bill & Effective Date & Stringency & Cohort \\\\",
  "\\midrule"
)

for (i in seq_len(nrow(tab4_data))) {
  row <- tab4_data[i, ]
  qtr <- quarter(row$effective_date)
  yr <- year(row$effective_date)
  tab4_lines <- c(tab4_lines,
    sprintf("%s & %s & %s & %s & %dQ%d \\\\",
            row$state_name, row$bill,
            format(row$effective_date, "%b %d, %Y"),
            tools::toTitleCase(row$stringency),
            yr, qtr))
}

tab4_lines <- c(tab4_lines,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} Stringency classification: Strong = includes penalties, sanctions, or private right of action; Moderate = statutory prohibition without explicit penalties; Weak = executive order, budget proviso, or advisory. Sources: PEN America Index of Educational Gag Orders, Heritage Foundation, state legislative records.",
  "\\end{tablenotes}",
  "\\end{threeparttable}",
  "\\end{table}"
)

writeLines(tab4_lines, "../tables/tab4_treatment_laws.tex")
cat("  Saved: tab4_treatment_laws.tex\n")

# ============================================================================
# TABLE 5: Placebo Test Results
# ============================================================================

cat("Table 5: Placebo tests...\n")

if (!is.null(robust_results$placebo_results)) {
  tab5_lines <- c(
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Placebo Tests: Effect of Education Content Laws on Non-Education Sectors}",
    "\\label{tab:placebo}",
    "\\begin{threeparttable}",
    "\\begin{tabular}{lccc}",
    "\\toprule",
    "Sector (NAICS) & ATT & SE & p-value \\\\",
    "\\midrule",
    sprintf("K--12 Schools (6111) --- \\textit{Treated} & %s%s & (%s) & %s \\\\",
            fmt_coef(cs_res$emp$att), stars(cs_res$emp$p),
            fmt_coef(cs_res$emp$se), fmt_coef(cs_res$emp$p, 3))
  )

  # Add broad education row if available
  if (!is.null(robust_results$agg_broad)) {
    broad_r <- extract_att(robust_results$agg_broad)
    tab5_lines <- c(tab5_lines,
      sprintf("Broad Education (61) & %s%s & (%s) & %s \\\\",
              fmt_coef(broad_r$att), stars(broad_r$p),
              fmt_coef(broad_r$se), fmt_coef(broad_r$p, 3)))
  }

  tab5_lines <- c(tab5_lines, "\\midrule")

  for (ind in names(robust_results$placebo_results)) {
    pr <- robust_results$placebo_results[[ind]]
    pr_att <- extract_att(pr$agg)
    tab5_lines <- c(tab5_lines,
      sprintf("%s (%s) & %s%s & (%s) & %s \\\\",
              pr$industry, ind,
              fmt_coef(pr_att$att), stars(pr_att$p),
              fmt_coef(pr_att$se), fmt_coef(pr_att$p, 3)))
  }

  tab5_lines <- c(tab5_lines,
    "\\bottomrule",
    "\\end{tabular}",
    "\\begin{tablenotes}[flushleft]",
    "\\small",
    "\\item \\textit{Notes:} All specifications use Callaway-Sant'Anna (2021) with never-treated control and log employment as the outcome. Treatment coding assigns education content restriction law dates to all sectors within the state. Non-education sectors should show null effects under valid identification. ``Broad Education'' uses NAICS 61 (all educational services) vs.~the primary NAICS 6111 (K--12 schools only). $^{*}$ $p<0.10$, $^{**}$ $p<0.05$, $^{***}$ $p<0.01$.",
    "\\end{tablenotes}",
    "\\end{threeparttable}",
    "\\end{table}"
  )

  writeLines(tab5_lines, "../tables/tab5_placebo.tex")
  cat("  Saved: tab5_placebo.tex\n")
}

# ============================================================================
# TABLE 6: Minimum Detectable Effects
# ============================================================================

cat("Table 6: MDE...\n")

if (!is.null(robust_results$mde_results)) {
  mde <- robust_results$mde_results

  tab6_lines <- c(
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Minimum Detectable Effects at 80\\% Power}",
    "\\label{tab:mde}",
    "\\begin{threeparttable}",
    "\\begin{tabular}{lcccc}",
    "\\toprule",
    "Outcome & ATT & SE & MDE (80\\%) & $|\\text{ATT}| / \\text{MDE}$ \\\\",
    "\\midrule"
  )

  for (i in seq_len(nrow(mde))) {
    ratio <- abs(mde$att[i]) / mde$mde_80[i]
    tab6_lines <- c(tab6_lines,
      sprintf("%s & %s & %s & %s & %s \\\\",
              mde$outcome[i],
              fmt_coef(mde$att[i]),
              fmt_coef(mde$se[i]),
              fmt_coef(mde$mde_80[i]),
              fmt_coef(ratio, 2)))
  }

  tab6_lines <- c(tab6_lines,
    "\\bottomrule",
    "\\end{tabular}",
    "\\begin{tablenotes}[flushleft]",
    "\\small",
    "\\item \\textit{Notes:} MDE at 80\\% power and 5\\% significance (two-sided) calculated as $2.8 \\times \\text{SE}$, where SE is from the Callaway-Sant'Anna estimator. $|\\text{ATT}| / \\text{MDE}$ below 1 indicates the estimated effect is smaller than what the design can reliably detect. Data: NAICS 6111 (K--12 Schools), Census QWI 2015--2024.",
    "\\end{tablenotes}",
    "\\end{threeparttable}",
    "\\end{table}"
  )

  writeLines(tab6_lines, "../tables/tab6_mde.tex")
  cat("  Saved: tab6_mde.tex\n")
}

cat("\n=== All tables generated ===\n")
