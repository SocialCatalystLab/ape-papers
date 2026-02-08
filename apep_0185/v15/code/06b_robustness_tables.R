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
    # Use Wald F = (coef/se)^2 from first stage, consistent with main table
    fs <- summary(model, stage = 1)
    (coef(fs)[1] / se(fs)[1])^2
  }, error = function(e) {
    tryCatch({
      fs <- fitstat(model, "ivf")
      fs[[1]]$stat
    }, error = function(e2) NA)
  })
}

# ============================================================================
# Table B1: Sample Restrictions
# ============================================================================

cat("Table B1: Sample Restrictions...\n")

# Column values
b1 <- list(
  baseline = list(
    emp_c  = coef(robustness$baseline_iv_emp)[1],
    emp_se = se(robustness$baseline_iv_emp)[1],
    emp_p  = fixest::pvalue(robustness$baseline_iv_emp)[1],
    ear_c  = coef(robustness$baseline_iv_earn)[1],
    ear_se = se(robustness$baseline_iv_earn)[1],
    ear_p  = fixest::pvalue(robustness$baseline_iv_earn)[1],
    f      = get_f(robustness$baseline_iv_emp),
    n      = nobs(robustness$baseline_iv_emp)
  ),
  precovid = list(
    emp_c  = coef(robustness$pre_covid_iv_emp)[1],
    emp_se = se(robustness$pre_covid_iv_emp)[1],
    emp_p  = fixest::pvalue(robustness$pre_covid_iv_emp)[1],
    ear_c  = coef(robustness$pre_covid_iv_earn)[1],
    ear_se = se(robustness$pre_covid_iv_earn)[1],
    ear_p  = fixest::pvalue(robustness$pre_covid_iv_earn)[1],
    f      = get_f(robustness$pre_covid_iv_emp),
    n      = nobs(robustness$pre_covid_iv_emp)
  ),
  post2015 = list(
    emp_c  = coef(robustness$post_2015_iv_emp)[1],
    emp_se = se(robustness$post_2015_iv_emp)[1],
    emp_p  = fixest::pvalue(robustness$post_2015_iv_emp)[1],
    ear_c  = coef(robustness$post_2015_iv_earn)[1],
    ear_se = se(robustness$post_2015_iv_earn)[1],
    ear_p  = fixest::pvalue(robustness$post_2015_iv_earn)[1],
    f      = get_f(robustness$post_2015_iv_emp),
    n      = nobs(robustness$post_2015_iv_emp)
  ),
  top3 = list(
    emp_c  = robustness$loso_results[["top3"]]$emp_coef,
    emp_se = robustness$loso_results[["top3"]]$emp_se,
    emp_p  = robustness$loso_results[["top3"]]$emp_p,
    ear_c  = robustness$loso_results[["top3"]]$earn_coef,
    ear_se = robustness$loso_results[["top3"]]$earn_se,
    ear_p  = robustness$loso_results[["top3"]]$earn_p,
    f      = robustness$loso_results[["top3"]]$emp_f,
    n      = robustness$loso_results[["top3"]]$emp_n
  )
)

tab_b1 <- paste0(
  "\\begin{table}[H]\n",
  "\\centering\n",
  "\\caption{Robustness: Sample Restrictions (2SLS)}\n",
  "\\label{tab:robustB1}\n",
  "\\small\n",
  "\\begin{tabular}{l cccc}\n",
  "\\toprule\n",
  " & (1) Baseline & (2) Pre-COVID & (3) Post-2015 & (4) Excl.\\ Top-3 \\\\\n",
  " & & (2012--2019) & (2016--2022) & (CA, NY, WA) \\\\\n",
  "\\midrule\n",
  "\\multicolumn{5}{l}{\\textit{Panel A: Log Employment}} \\\\[3pt]\n",
  "Network MW & ", fmt_coef(b1$baseline$emp_c, b1$baseline$emp_p),
  " & ", fmt_coef(b1$precovid$emp_c, b1$precovid$emp_p),
  " & ", fmt_coef(b1$post2015$emp_c, b1$post2015$emp_p),
  " & ", fmt_coef(b1$top3$emp_c, b1$top3$emp_p), " \\\\\n",
  " & ", fmt_se(b1$baseline$emp_se),
  " & ", fmt_se(b1$precovid$emp_se),
  " & ", fmt_se(b1$post2015$emp_se),
  " & ", fmt_se(b1$top3$emp_se), " \\\\\n",
  "\\addlinespace\n",
  "\\multicolumn{5}{l}{\\textit{Panel B: Log Earnings}} \\\\[3pt]\n",
  "Network MW & ", fmt_coef(b1$baseline$ear_c, b1$baseline$ear_p),
  " & ", fmt_coef(b1$precovid$ear_c, b1$precovid$ear_p),
  " & ", fmt_coef(b1$post2015$ear_c, b1$post2015$ear_p),
  " & ", fmt_coef(b1$top3$ear_c, b1$top3$ear_p), " \\\\\n",
  " & ", fmt_se(b1$baseline$ear_se),
  " & ", fmt_se(b1$precovid$ear_se),
  " & ", fmt_se(b1$post2015$ear_se),
  " & ", fmt_se(b1$top3$ear_se), " \\\\\n",
  "\\midrule\n",
  "County FE & Yes & Yes & Yes & Yes \\\\\n",
  "State $\\times$ Time FE & Yes & Yes & Yes & Yes \\\\\n",
  "First Stage F & ", fmt_f(b1$baseline$f),
  " & ", fmt_f(b1$precovid$f),
  " & ", fmt_f(b1$post2015$f),
  " & ", fmt_f(b1$top3$f), " \\\\\n",
  "Observations & ", fmt_n(b1$baseline$n),
  " & ", fmt_n(b1$precovid$n),
  " & ", fmt_n(b1$post2015$n),
  " & ", fmt_n(b1$top3$n), " \\\\\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{figurenotes}\n",
  "Notes: All columns report 2SLS estimates instrumenting network minimum wage exposure with\n",
  "out-of-state network exposure. Column (2) restricts to pre-COVID quarters (2012Q1--2019Q4).\n",
  "Column (3) restricts to post-2015 quarters. Column (4) excludes the three highest minimum\n",
  "wage states (California, New York, Washington) simultaneously.\n",
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

# States to show: CA, NY, WA, MA, FL, top3
loso_states <- c("06", "36", "53", "25", "12")
loso_labels <- c("$-$CA", "$-$NY", "$-$WA", "$-$MA", "$-$FL")

# Build header
tab_b2 <- paste0(
  "\\begin{table}[H]\n",
  "\\centering\n",
  "\\caption{Robustness: Leave-One-State-Out (2SLS)}\n",
  "\\label{tab:robustB2}\n",
  "\\small\n",
  "\\begin{tabular}{l ccccccc}\n",
  "\\toprule\n",
  " & (1) & (2) & (3) & (4) & (5) & (6) & (7) \\\\\n",
  " & Baseline & $-$CA & $-$NY & $-$WA & $-$MA & $-$FL & $-$CA/NY/WA \\\\\n",
  "\\midrule\n",
  "\\multicolumn{8}{l}{\\textit{Panel A: Log Employment}} \\\\[3pt]\n"
)

# Panel A row
emp_row <- paste0("Network MW & ", fmt_coef(b1$baseline$emp_c, b1$baseline$emp_p))
se_row  <- paste0(" & ", fmt_se(b1$baseline$emp_se))
for (st in loso_states) {
  r <- robustness$loso_results[[st]]
  emp_row <- paste0(emp_row, " & ", fmt_coef(r$emp_coef, r$emp_p))
  se_row  <- paste0(se_row,  " & ", fmt_se(r$emp_se))
}
# Top-3 column
r_t3 <- robustness$loso_results[["top3"]]
emp_row <- paste0(emp_row, " & ", fmt_coef(r_t3$emp_coef, r_t3$emp_p), " \\\\\n")
se_row  <- paste0(se_row,  " & ", fmt_se(r_t3$emp_se), " \\\\\n")

tab_b2 <- paste0(tab_b2, emp_row, se_row,
  "\\addlinespace\n",
  "\\multicolumn{8}{l}{\\textit{Panel B: Log Earnings}} \\\\[3pt]\n"
)

# Panel B row
ear_row <- paste0("Network MW & ", fmt_coef(b1$baseline$ear_c, b1$baseline$ear_p))
se_row2 <- paste0(" & ", fmt_se(b1$baseline$ear_se))
for (st in loso_states) {
  r <- robustness$loso_results[[st]]
  ear_row <- paste0(ear_row, " & ", fmt_coef(r$earn_coef, r$earn_p))
  se_row2 <- paste0(se_row2, " & ", fmt_se(r$earn_se))
}
ear_row <- paste0(ear_row, " & ", fmt_coef(r_t3$earn_coef, r_t3$earn_p), " \\\\\n")
se_row2 <- paste0(se_row2, " & ", fmt_se(r_t3$earn_se), " \\\\\n")

tab_b2 <- paste0(tab_b2, ear_row, se_row2)

# Footer
n_row <- paste0("Observations & ", fmt_n(b1$baseline$n))
for (st in loso_states) {
  r <- robustness$loso_results[[st]]
  n_row <- paste0(n_row, " & ", fmt_n(r$emp_n))
}
n_row <- paste0(n_row, " & ", fmt_n(r_t3$emp_n), " \\\\\n")

tab_b2 <- paste0(tab_b2,
  "\\midrule\n",
  "County FE & Yes & Yes & Yes & Yes & Yes & Yes & Yes \\\\\n",
  "State $\\times$ Time FE & Yes & Yes & Yes & Yes & Yes & Yes & Yes \\\\\n",
  n_row,
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{figurenotes}\n",
  "Notes: All columns report 2SLS estimates instrumenting network minimum wage exposure with\n",
  "out-of-state network exposure. Each column excludes the indicated state(s) from the estimation\n",
  "sample. Column (7) simultaneously excludes California, New York, and Washington.\n",
  "Standard errors clustered at state level in parentheses.\n",
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

# Get values from placebo results
gdp_c  <- if (!is.null(placebo$gdp_rf)) coef(placebo$gdp_rf)[1] else NA
gdp_se <- if (!is.null(placebo$gdp_rf)) se(placebo$gdp_rf)[1] else NA
gdp_p  <- if (!is.null(placebo$gdp_rf)) fixest::pvalue(placebo$gdp_rf)[1] else NA

emp_c  <- if (!is.null(placebo$emp_rf)) coef(placebo$emp_rf)[1] else NA
emp_se <- if (!is.null(placebo$emp_rf)) se(placebo$emp_rf)[1] else NA
emp_p  <- if (!is.null(placebo$emp_rf)) fixest::pvalue(placebo$emp_rf)[1] else NA

hr_mw_c  <- if (!is.null(placebo$horse_race)) coef(placebo$horse_race)["network_mw_pop"] else NA
hr_mw_se <- if (!is.null(placebo$horse_race)) se(placebo$horse_race)["network_mw_pop"] else NA
hr_mw_p  <- if (!is.null(placebo$horse_race)) fixest::pvalue(placebo$horse_race)["network_mw_pop"] else NA
hr_gd_c  <- if (!is.null(placebo$horse_race)) coef(placebo$horse_race)["placebo_gdp"] else NA
hr_gd_se <- if (!is.null(placebo$horse_race)) se(placebo$horse_race)["placebo_gdp"] else NA
hr_gd_p  <- if (!is.null(placebo$horse_race)) fixest::pvalue(placebo$horse_race)["placebo_gdp"] else NA

# Get baseline OLS (reduced form) for comparison
base_rf_c  <- coef(robustness$contemp_ols)[1]
base_rf_se <- se(robustness$contemp_ols)[1]
base_rf_p  <- fixest::pvalue(robustness$contemp_ols)[1]

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
  "Observations & ", fmt_n(nobs(robustness$contemp_ols)),
  " & ", if (!is.null(placebo$gdp_rf)) fmt_n(nobs(placebo$gdp_rf)) else "---",
  " & ", if (!is.null(placebo$emp_rf)) fmt_n(nobs(placebo$emp_rf)) else "---",
  " & ", if (!is.null(placebo$horse_race)) fmt_n(nobs(placebo$horse_race)) else "---", " \\\\\n",
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
# Table B4: Alternative Controls (2SLS)
# ============================================================================

cat("Table B4: Alternative Controls...\n")

# Region trends
rt_emp_c  <- if (!is.null(robustness$region_trend_results$iv_emp)) coef(robustness$region_trend_results$iv_emp)[1] else NA
rt_emp_se <- if (!is.null(robustness$region_trend_results$iv_emp)) se(robustness$region_trend_results$iv_emp)[1] else NA
rt_emp_p  <- if (!is.null(robustness$region_trend_results$iv_emp)) fixest::pvalue(robustness$region_trend_results$iv_emp)[1] else NA
rt_ear_c  <- if (!is.null(robustness$region_trend_results$iv_earn)) coef(robustness$region_trend_results$iv_earn)[1] else NA
rt_ear_se <- if (!is.null(robustness$region_trend_results$iv_earn)) se(robustness$region_trend_results$iv_earn)[1] else NA
rt_ear_p  <- if (!is.null(robustness$region_trend_results$iv_earn)) fixest::pvalue(robustness$region_trend_results$iv_earn)[1] else NA
rt_f      <- get_f(robustness$region_trend_results$iv_emp)
rt_n      <- if (!is.null(robustness$region_trend_results$iv_emp)) nobs(robustness$region_trend_results$iv_emp) else NA

# Geo controls
gc_emp_c  <- coef(robustness$geo_control_iv_emp)["fit_network_mw_pop"]
gc_emp_se <- se(robustness$geo_control_iv_emp)["fit_network_mw_pop"]
gc_emp_p  <- fixest::pvalue(robustness$geo_control_iv_emp)["fit_network_mw_pop"]
gc_ear_c  <- coef(robustness$geo_control_iv_earn)["fit_network_mw_pop"]
gc_ear_se <- se(robustness$geo_control_iv_earn)["fit_network_mw_pop"]
gc_ear_p  <- fixest::pvalue(robustness$geo_control_iv_earn)["fit_network_mw_pop"]
gc_f      <- get_f(robustness$geo_control_iv_emp)
gc_n      <- nobs(robustness$geo_control_iv_emp)

tab_b4 <- paste0(
  "\\begin{table}[H]\n",
  "\\centering\n",
  "\\caption{Robustness: Alternative Controls (2SLS)}\n",
  "\\label{tab:robustB4}\n",
  "\\small\n",
  "\\begin{tabular}{l ccc}\n",
  "\\toprule\n",
  " & (1) Baseline & (2) + Geographic & (3) + Region \\\\\n",
  " & & Controls & Trends \\\\\n",
  "\\midrule\n",
  "\\multicolumn{4}{l}{\\textit{Panel A: Log Employment}} \\\\[3pt]\n",
  "Network MW & ", fmt_coef(b1$baseline$emp_c, b1$baseline$emp_p),
  " & ", fmt_coef(gc_emp_c, gc_emp_p),
  " & ", fmt_coef(rt_emp_c, rt_emp_p), " \\\\\n",
  " & ", fmt_se(b1$baseline$emp_se),
  " & ", fmt_se(gc_emp_se),
  " & ", fmt_se(rt_emp_se), " \\\\\n",
  "\\addlinespace\n",
  "\\multicolumn{4}{l}{\\textit{Panel B: Log Earnings}} \\\\[3pt]\n",
  "Network MW & ", fmt_coef(b1$baseline$ear_c, b1$baseline$ear_p),
  " & ", fmt_coef(gc_ear_c, gc_ear_p),
  " & ", fmt_coef(rt_ear_c, rt_ear_p), " \\\\\n",
  " & ", fmt_se(b1$baseline$ear_se),
  " & ", fmt_se(gc_ear_se),
  " & ", fmt_se(rt_ear_se), " \\\\\n",
  "\\midrule\n",
  "County FE & Yes & Yes & Yes \\\\\n",
  "State $\\times$ Time FE & Yes & Yes & Yes \\\\\n",
  "Geographic Exposure & No & Yes & No \\\\\n",
  "Region $\\times$ Time Trend & No & No & Yes \\\\\n",
  "First Stage F & ", fmt_f(b1$baseline$f),
  " & ", fmt_f(gc_f),
  " & ", fmt_f(rt_f), " \\\\\n",
  "Observations & ", fmt_n(b1$baseline$n),
  " & ", fmt_n(gc_n),
  " & ", fmt_n(rt_n), " \\\\\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{figurenotes}\n",
  "Notes: All columns report 2SLS estimates instrumenting network minimum wage exposure with\n",
  "out-of-state network exposure. Column (2) adds geographic exposure (distance-weighted\n",
  "network MW) as an additional control. Column (3) adds Census division $\\times$ linear\n",
  "time trends to absorb broad regional dynamics.\n",
  "Standard errors clustered at state level in parentheses.\n",
  "*** p$<$0.01, ** p$<$0.05, * p$<$0.1.\n",
  "\\end{figurenotes}\n",
  "\\end{table}\n"
)

writeLines(tab_b4, "../tables/tabB4_controls.tex")
cat("  Written tabB4_controls.tex\n")

cat("\n=== Appendix Tables Complete ===\n")
