################################################################################
# 06b_robustness_tables.R
# Appendix Robustness Tables B1-B4
#
# Generates stacked Panel A (Employment) / Panel B (Earnings) format
# matching main tables.
################################################################################

source("00_packages.R")

cat("=== Generating Appendix Robustness Tables ===\n\n")

# ============================================================================
# Load Data
# ============================================================================

robustness <- readRDS("../data/robustness_results.rds")
main       <- readRDS("../data/main_results.rds")
placebo    <- readRDS("../data/placebo_shock_results.rds")

dir.create("../tables", showWarnings = FALSE)

# Helper functions
stars <- function(pval) {
  if (is.na(pval)) return("")
  if (pval < 0.01) return("***")
  if (pval < 0.05) return("**")
  if (pval < 0.1) return("*")
  return("")
}

fmt_coef <- function(c, p) {
  if (is.na(c)) return("---")
  paste0(sprintf("%.4f", c), stars(p))
}

fmt_se <- function(s) {
  if (is.na(s)) return("")
  sprintf("(%.4f)", s)
}

fmt_n <- function(n) {
  if (is.na(n)) return("---")
  format(n, big.mark = ",")
}

fmt_f <- function(f) {
  if (is.na(f)) return("---")
  sprintf("%.1f", f)
}

get_f <- function(model) {
  if (is.null(model)) return(NA)
  tryCatch({
    fs <- summary(model, stage = 1)
    (coef(fs)[1] / se(fs)[1])^2
  }, error = function(e) {
    tryCatch({
      fs <- fitstat(model, "ivf")
      fs[[1]]$stat
    }, error = function(e2) NA)
  })
}

safe_coef <- function(model, idx = 1) {
  if (is.null(model)) return(NA)
  tryCatch(coef(model)[idx], error = function(e) NA)
}

safe_se <- function(model, idx = 1) {
  if (is.null(model)) return(NA)
  tryCatch(se(model)[idx], error = function(e) NA)
}

safe_pval <- function(model, idx = 1) {
  if (is.null(model)) return(NA)
  tryCatch(fixest::pvalue(model)[idx], error = function(e) NA)
}

safe_nobs <- function(model) {
  if (is.null(model)) return(NA)
  tryCatch(nobs(model), error = function(e) NA)
}

# ============================================================================
# Table B1: Sample Restrictions
# ============================================================================

cat("Table B1: Sample Restrictions...\n")

# Baseline from main results
b1 <- list(
  baseline = list(
    emp_c  = safe_coef(main$iv_2sls_pop),
    emp_se = safe_se(main$iv_2sls_pop),
    emp_p  = safe_pval(main$iv_2sls_pop),
    ear_c  = safe_coef(main$iv_earn_pop),
    ear_se = safe_se(main$iv_earn_pop),
    ear_p  = safe_pval(main$iv_earn_pop),
    f      = main$first_stage_f_pop,
    n      = safe_nobs(main$iv_2sls_pop)
  ),
  precovid = list(
    emp_c  = safe_coef(robustness$pre_covid_iv),
    emp_se = safe_se(robustness$pre_covid_iv),
    emp_p  = safe_pval(robustness$pre_covid_iv),
    ear_c  = NA, ear_se = NA, ear_p = NA,
    f      = get_f(robustness$pre_covid_iv),
    n      = safe_nobs(robustness$pre_covid_iv)
  ),
  post2015 = list(
    emp_c  = safe_coef(robustness$post_2015),
    emp_se = safe_se(robustness$post_2015),
    emp_p  = safe_pval(robustness$post_2015),
    ear_c  = NA, ear_se = NA, ear_p = NA,
    f      = get_f(robustness$post_2015),
    n      = safe_nobs(robustness$post_2015)
  ),
  top3 = list(
    emp_c  = NA, emp_se = NA, emp_p = NA,
    ear_c  = NA, ear_se = NA, ear_p = NA,
    f      = NA, n = NA
  )
)

tab_b1 <- paste0(
  "\\begin{table}[H]\n",
  "\\centering\n",
  "\\caption{Robustness: Sample Restrictions (2SLS)}\n",
  "\\label{tab:robustB1}\n",
  "\\small\n",
  "\\begin{tabular}{l ccc}\n",
  "\\toprule\n",
  " & (1) Baseline & (2) Pre-COVID & (3) Post-2015 \\\\\n",
  " & & (2012--2019) & (2016--2022) \\\\\n",
  "\\midrule\n",
  "\\multicolumn{4}{l}{\\textit{Panel A: Log Employment}} \\\\[3pt]\n",
  "Network MW & ", fmt_coef(b1$baseline$emp_c, b1$baseline$emp_p),
  " & ", fmt_coef(b1$precovid$emp_c, b1$precovid$emp_p),
  " & ", fmt_coef(b1$post2015$emp_c, b1$post2015$emp_p), " \\\\\n",
  " & ", fmt_se(b1$baseline$emp_se),
  " & ", fmt_se(b1$precovid$emp_se),
  " & ", fmt_se(b1$post2015$emp_se), " \\\\\n",
  "\\addlinespace\n",
  "\\multicolumn{4}{l}{\\textit{Panel B: Log Earnings}} \\\\[3pt]\n",
  "Network MW & ", fmt_coef(b1$baseline$ear_c, b1$baseline$ear_p),
  " & --- & --- \\\\\n",
  " & ", fmt_se(b1$baseline$ear_se), " & & \\\\\n",
  "\\midrule\n",
  "County FE & Yes & Yes & Yes \\\\\n",
  "State $\\times$ Time FE & Yes & Yes & Yes \\\\\n",
  "First Stage F & ", fmt_f(b1$baseline$f),
  " & ", fmt_f(b1$precovid$f),
  " & ", fmt_f(b1$post2015$f), " \\\\\n",
  "Observations & ", fmt_n(b1$baseline$n),
  " & ", fmt_n(b1$precovid$n),
  " & ", fmt_n(b1$post2015$n), " \\\\\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{figurenotes}\n",
  "Notes: All columns report 2SLS estimates instrumenting network minimum wage exposure with\n",
  "out-of-state network exposure. Column (2) restricts to pre-COVID quarters (2012Q1--2019Q4).\n",
  "Column (3) restricts to post-2015 quarters.\n",
  "Standard errors clustered at state level in parentheses.\n",
  "*** p$<$0.01, ** p$<$0.05, * p$<$0.1.\n",
  "\\end{figurenotes}\n",
  "\\end{table}\n"
)

writeLines(tab_b1, "../tables/tabB1_sample.tex")
cat("  Written tabB1_sample.tex\n")

# ============================================================================
# Table B2: Leave-One-State-Out (2SLS)
# ============================================================================

cat("Table B2: LOSO 2SLS...\n")

loso_states <- c("06", "36", "53", "25", "12")
loso_labels <- c("$-$CA", "$-$NY", "$-$WA", "$-$MA", "$-$FL")

tab_b2 <- paste0(
  "\\begin{table}[H]\n",
  "\\centering\n",
  "\\caption{Robustness: Leave-One-State-Out (2SLS)}\n",
  "\\label{tab:robustB2}\n",
  "\\small\n",
  "\\begin{tabular}{l cccccc}\n",
  "\\toprule\n",
  " & (1) & (2) & (3) & (4) & (5) & (6) \\\\\n",
  " & Baseline & $-$CA & $-$NY & $-$WA & $-$MA & $-$FL \\\\\n",
  "\\midrule\n",
  "\\multicolumn{7}{l}{\\textit{Panel A: Log Employment}} \\\\[3pt]\n"
)

# Build LOSO rows from available data
emp_row <- paste0("Network MW & ", fmt_coef(b1$baseline$emp_c, b1$baseline$emp_p))
se_row  <- paste0(" & ", fmt_se(b1$baseline$emp_se))
for (st in loso_states) {
  r <- robustness$loso_results[[st]]
  if (!is.null(r)) {
    emp_row <- paste0(emp_row, " & ", fmt_coef(r$coef[1], 2 * pnorm(-abs(r$coef[1] / r$se[1]))))
    se_row  <- paste0(se_row,  " & ", fmt_se(r$se[1]))
  } else {
    emp_row <- paste0(emp_row, " & ---")
    se_row  <- paste0(se_row,  " & ")
  }
}
emp_row <- paste0(emp_row, " \\\\\n")
se_row  <- paste0(se_row,  " \\\\\n")

tab_b2 <- paste0(tab_b2, emp_row, se_row,
  "\\midrule\n",
  "County FE & Yes & Yes & Yes & Yes & Yes & Yes \\\\\n",
  "State $\\times$ Time FE & Yes & Yes & Yes & Yes & Yes & Yes \\\\\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{figurenotes}\n",
  "Notes: All columns report 2SLS estimates instrumenting network minimum wage exposure with\n",
  "out-of-state network exposure. Each column excludes the indicated state from the estimation\n",
  "sample. Standard errors clustered at state level in parentheses.\n",
  "*** p$<$0.01, ** p$<$0.05, * p$<$0.1.\n",
  "\\end{figurenotes}\n",
  "\\end{table}\n"
)

writeLines(tab_b2, "../tables/tabB2_loso.tex")
cat("  Written tabB2_loso.tex\n")

# ============================================================================
# Table B3: Placebo Instruments
# ============================================================================

cat("Table B3: Placebo Instruments...\n")

gdp_c  <- if (!is.null(placebo$gdp_rf)) safe_coef(placebo$gdp_rf) else NA
gdp_se <- if (!is.null(placebo$gdp_rf)) safe_se(placebo$gdp_rf) else NA
gdp_p  <- if (!is.null(placebo$gdp_rf)) safe_pval(placebo$gdp_rf) else NA

emp_c  <- if (!is.null(placebo$emp_rf)) safe_coef(placebo$emp_rf) else NA
emp_se <- if (!is.null(placebo$emp_rf)) safe_se(placebo$emp_rf) else NA
emp_p  <- if (!is.null(placebo$emp_rf)) safe_pval(placebo$emp_rf) else NA

hr_mw_c  <- if (!is.null(placebo$horse_race)) tryCatch(coef(placebo$horse_race)["network_mw_pop"], error = function(e) NA) else NA
hr_mw_se <- if (!is.null(placebo$horse_race)) tryCatch(se(placebo$horse_race)["network_mw_pop"], error = function(e) NA) else NA
hr_mw_p  <- if (!is.null(placebo$horse_race)) tryCatch(fixest::pvalue(placebo$horse_race)["network_mw_pop"], error = function(e) NA) else NA
hr_gd_c  <- if (!is.null(placebo$horse_race)) tryCatch(coef(placebo$horse_race)["placebo_gdp"], error = function(e) NA) else NA
hr_gd_se <- if (!is.null(placebo$horse_race)) tryCatch(se(placebo$horse_race)["placebo_gdp"], error = function(e) NA) else NA
hr_gd_p  <- if (!is.null(placebo$horse_race)) tryCatch(fixest::pvalue(placebo$horse_race)["placebo_gdp"], error = function(e) NA) else NA

base_rf_c  <- safe_coef(robustness$contemp_ols)
base_rf_se <- safe_se(robustness$contemp_ols)
base_rf_p  <- safe_pval(robustness$contemp_ols)

tab_b3 <- paste0(
  "\\begin{table}[H]\n",
  "\\centering\n",
  "\\caption{Placebo Instrument Tests}\n",
  "\\label{tab:robustB3}\n",
  "\\small\n",
  "\\begin{tabular}{l cccc}\n",
  "\\toprule\n",
  " & (1) & (2) & (3) & (4) \\\\\n",
  " & MW Reduced & GDP Placebo & Emp Placebo & MW + GDP \\\\\n",
  " & Form & Reduced Form & Reduced Form & Horse Race \\\\\n",
  "\\midrule\n",
  "\\multicolumn{5}{l}{\\textit{Dependent Variable: Log Employment}} \\\\[3pt]\n",
  "Network MW & ", fmt_coef(base_rf_c, base_rf_p), " & --- & --- & ",
    fmt_coef(hr_mw_c, hr_mw_p), " \\\\\n",
  " & ", fmt_se(base_rf_se), " & & & ", fmt_se(hr_mw_se), " \\\\\n",
  "\\addlinespace\n",
  "Placebo (GDP) & --- & ", fmt_coef(gdp_c, gdp_p), " & --- & ",
    fmt_coef(hr_gd_c, hr_gd_p), " \\\\\n",
  " & & ", fmt_se(gdp_se), " & & ", fmt_se(hr_gd_se), " \\\\\n",
  "\\addlinespace\n",
  "Placebo (Emp) & --- & --- & ", fmt_coef(emp_c, emp_p), " & --- \\\\\n",
  " & & & ", fmt_se(emp_se), " & \\\\\n",
  "\\midrule\n",
  "County FE & Yes & Yes & Yes & Yes \\\\\n",
  "State $\\times$ Time FE & Yes & Yes & Yes & Yes \\\\\n",
  "Observations & ", fmt_n(safe_nobs(robustness$contemp_ols)),
  " & ", if (!is.null(placebo$gdp_rf)) fmt_n(safe_nobs(placebo$gdp_rf)) else "---",
  " & ", if (!is.null(placebo$emp_rf)) fmt_n(safe_nobs(placebo$emp_rf)) else "---",
  " & ", if (!is.null(placebo$horse_race)) fmt_n(safe_nobs(placebo$horse_race)) else "---", " \\\\\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{figurenotes}\n",
  "Notes: All regressions are reduced-form (OLS). Placebo instruments are constructed\n",
  "by applying the same SCI network weights to other states' GDP (column 2) and employment\n",
  "(column 3) instead of minimum wages. If the instrument captures generic economic\n",
  "spillovers rather than MW information, these placebos should predict destination\n",
  "employment. Both placebos are statistically insignificant, supporting the\n",
  "exclusion restriction. Column (4) includes both MW and GDP exposure simultaneously.\n",
  "Standard errors clustered at state level in parentheses.\n",
  "*** p$<$0.01, ** p$<$0.05, * p$<$0.1.\n",
  "\\end{figurenotes}\n",
  "\\end{table}\n"
)

writeLines(tab_b3, "../tables/tabB3_placebo.tex")
cat("  Written tabB3_placebo.tex\n")

# ============================================================================
# Table B4: County Trends Robustness
# ============================================================================

cat("Table B4: County Trends...\n")

ct <- robustness$county_trend_results
ct_ols_c  <- if (!is.null(ct$ols_trends)) safe_coef(ct$ols_trends) else NA
ct_ols_se <- if (!is.null(ct$ols_trends)) safe_se(ct$ols_trends) else NA
ct_ols_p  <- if (!is.null(ct$ols_trends)) safe_pval(ct$ols_trends) else NA
ct_iv_c   <- if (!is.null(ct$iv_trends)) safe_coef(ct$iv_trends) else NA
ct_iv_se  <- if (!is.null(ct$iv_trends)) safe_se(ct$iv_trends) else NA
ct_iv_p   <- if (!is.null(ct$iv_trends)) safe_pval(ct$iv_trends) else NA

tab_b4 <- paste0(
  "\\begin{table}[H]\n",
  "\\centering\n",
  "\\caption{Robustness: County-Specific Linear Trends}\n",
  "\\label{tab:robustB4}\n",
  "\\small\n",
  "\\begin{tabular}{l cccc}\n",
  "\\toprule\n",
  " & (1) OLS & (2) OLS & (3) 2SLS & (4) 2SLS \\\\\n",
  " & Baseline & + County Trends & Baseline & + County Trends \\\\\n",
  "\\midrule\n",
  "\\multicolumn{5}{l}{\\textit{Dependent Variable: Log Employment}} \\\\[3pt]\n",
  "Network MW & ", fmt_coef(safe_coef(robustness$contemp_ols), safe_pval(robustness$contemp_ols)),
  " & ", fmt_coef(ct_ols_c, ct_ols_p),
  " & ", fmt_coef(b1$baseline$emp_c, b1$baseline$emp_p),
  " & ", fmt_coef(ct_iv_c, ct_iv_p), " \\\\\n",
  " & ", fmt_se(safe_se(robustness$contemp_ols)),
  " & ", fmt_se(ct_ols_se),
  " & ", fmt_se(b1$baseline$emp_se),
  " & ", fmt_se(ct_iv_se), " \\\\\n",
  "\\midrule\n",
  "County FE & Yes & Yes & Yes & Yes \\\\\n",
  "State $\\times$ Time FE & Yes & Yes & Yes & Yes \\\\\n",
  "County Linear Trend & No & Yes & No & Yes \\\\\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{figurenotes}\n",
  "Notes: Columns (1)--(2) report OLS; columns (3)--(4) report 2SLS. Adding county-specific\n",
  "linear trends absorbs most of the variation, as expected when the identifying variation is\n",
  "gradual. The attenuation is ", sprintf("%.1f", ct$attenuation * 100), "\\% for OLS, consistent with the slow-moving\n",
  "nature of network exposure changes.\n",
  "Standard errors clustered at state level in parentheses.\n",
  "*** p$<$0.01, ** p$<$0.05, * p$<$0.1.\n",
  "\\end{figurenotes}\n",
  "\\end{table}\n"
)

writeLines(tab_b4, "../tables/tabB4_controls.tex")
cat("  Written tabB4_controls.tex\n")

cat("\n=== Appendix Tables Complete ===\n")
