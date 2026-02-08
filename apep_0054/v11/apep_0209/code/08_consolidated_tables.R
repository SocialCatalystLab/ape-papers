################################################################################
# 08_consolidated_tables.R
# Salary Transparency Laws and the Gender Wage Gap
# Consolidated Panel A (QWI) / Panel B (CPS) Tables
################################################################################
#
# --- Input/Output Provenance ---
# INPUTS:
#   data/main_results.rds    <- 04_main_analysis.R (CPS DiD results)
#   data/qwi_results.rds     <- 04b_qwi_analysis.R (QWI DiD results)
#   data/cps_analysis.rds    <- 02_clean_data.R (individual-level CPS microdata)
# OUTPUTS:
#   tables/tab_consolidated_agg.tex    - Consolidated aggregate effects
#   tables/tab_consolidated_gender.tex - Consolidated gender gap DDD
################################################################################

source("code/00_packages.R")

cat("=== Consolidated Table Generation ===\n\n")

# ============================================================================
# Load Data
# ============================================================================

required_files <- c(
  "data/main_results.rds",
  "data/qwi_results.rds",
  "data/cps_analysis.rds"
)
for (f in required_files) {
  if (!file.exists(f)) stop("Required input file not found: ", f,
                            "\nRun upstream scripts first.")
}

cps_res <- readRDS("data/main_results.rds")
qwi_res <- readRDS("data/qwi_results.rds")
df      <- readRDS("data/cps_analysis.rds")

dir.create("tables", showWarnings = FALSE)

cat("Data loaded.\n")
cat("  CPS microdata: ", format(nrow(df), big.mark = ","), " observations\n")
cat("  QWI results: ", paste(names(qwi_res), collapse = ", "), "\n\n")

# ============================================================================
# Helper: significance stars
# ============================================================================

stars <- function(pval) {
  if (is.na(pval)) return("")
  if (pval < 0.01) return("$^{***}$")
  if (pval < 0.05) return("$^{**}$")
  if (pval < 0.10) return("$^{*}$")
  return("")
}

fmt_coef <- function(val, pval) {
  paste0(sprintf("%.4f", val), stars(pval))
}

fmt_se <- function(val) {
  sprintf("(%.4f)", val)
}

# ============================================================================
# Table 1: Consolidated Aggregate Effects
# ============================================================================

cat("Creating Table 1: Consolidated Aggregate Effects...\n")

# --- Panel A: QWI ---
# Col 1: C-S ATT
qwi_cs_att  <- qwi_res$cs_earns_att$att
qwi_cs_se   <- qwi_res$cs_earns_att$se
qwi_cs_pval <- 2 * pnorm(-abs(qwi_cs_att / qwi_cs_se))

# Col 2: TWFE
qwi_twfe_coef <- qwi_res$twfe_earns$coef
qwi_twfe_se   <- qwi_res$twfe_earns$se
qwi_twfe_pval <- 2 * pnorm(-abs(qwi_twfe_coef / qwi_twfe_se))

# Col 3: No individual controls in QWI
cat("  Panel A (QWI): C-S ATT = ", sprintf("%.4f", qwi_cs_att),
    ", TWFE = ", sprintf("%.4f", qwi_twfe_coef), "\n")

# --- Panel B: CPS ---
# Col 1: C-S ATT from stored results
cps_cs_att  <- cps_res$att_simple$overall.att
cps_cs_se   <- cps_res$att_simple$overall.se
cps_cs_pval <- 2 * pnorm(-abs(cps_cs_att / cps_cs_se))

# Col 2: TWFE with state + year FE (run fresh)
cat("  Running CPS TWFE (state + year FE)...\n")
m_cps_twfe <- feols(log_hourly_wage ~ treat_post | statefip + income_year,
                     data = df, weights = ~ASECWT, cluster = ~statefip)
cps_twfe_coef <- coef(m_cps_twfe)["treat_post"]
cps_twfe_se   <- se(m_cps_twfe)["treat_post"]
cps_twfe_pval <- fixest::pvalue(m_cps_twfe)["treat_post"]

# Col 3: TWFE + occupation and industry FE (run fresh)
cat("  Running CPS TWFE + controls...\n")
m_cps_ctrl <- feols(log_hourly_wage ~ treat_post | statefip + income_year + occ_major + ind_major,
                     data = df, weights = ~ASECWT, cluster = ~statefip)
cps_ctrl_coef <- coef(m_cps_ctrl)["treat_post"]
cps_ctrl_se   <- se(m_cps_ctrl)["treat_post"]
cps_ctrl_pval <- fixest::pvalue(m_cps_ctrl)["treat_post"]

cat("  Panel B (CPS): C-S ATT = ", sprintf("%.4f", cps_cs_att),
    ", TWFE = ", sprintf("%.4f", cps_twfe_coef),
    ", TWFE+Ctrl = ", sprintf("%.4f", cps_ctrl_coef), "\n")

# --- N values ---
n_cps <- format(nrow(df), big.mark = ",")

# --- Build LaTeX ---
tab_agg <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Effect of Salary Transparency Laws on Wages and Earnings}\n",
  "\\label{tab:agg}\n",
  "\\begin{tabular}{lccc}\n",
  "\\toprule\n",
  " & (1) & (2) & (3) \\\\\n",
  " & C-S ATT & TWFE & TWFE + Controls \\\\\n",
  "\\midrule\n",
  "\\multicolumn{4}{l}{\\textit{Panel A: QWI Administrative Data (N = 2,603 state-quarters)}} \\\\[3pt]\n",
  "Treated $\\times$ Post & ",
    fmt_coef(qwi_cs_att, qwi_cs_pval), " & ",
    fmt_coef(qwi_twfe_coef, qwi_twfe_pval), " & --- \\\\\n",
  " & ", fmt_se(qwi_cs_se), " & ", fmt_se(qwi_twfe_se), " & \\\\\n",
  "\\addlinespace\n",
  "\\multicolumn{4}{l}{\\textit{Panel B: CPS Microdata (N = ", n_cps, " workers)}} \\\\[3pt]\n",
  "Treated $\\times$ Post & ",
    fmt_coef(cps_cs_att, cps_cs_pval), " & ",
    fmt_coef(cps_twfe_coef, cps_twfe_pval), " & ",
    fmt_coef(cps_ctrl_coef, cps_ctrl_pval), " \\\\\n",
  " & ", fmt_se(cps_cs_se), " & ", fmt_se(cps_twfe_se), " & ", fmt_se(cps_ctrl_se), " \\\\\n",
  "\\midrule\n",
  "State FE & Yes & Yes & Yes \\\\\n",
  "Time FE & Yes & Yes & Yes \\\\\n",
  "Occupation FE & & & Yes \\\\\n",
  "Industry FE & & & Yes \\\\\n",
  "Clustering & State & State & State \\\\\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{minipage}{0.95\\textwidth}\n",
  "\\footnotesize\n",
  "\\textit{Notes:} Standard errors clustered at the state level (51 clusters) in parentheses. ",
  "Panel~A uses administrative earnings data from the Census Bureau's Quarterly Workforce Indicators (QWI), ",
  "aggregated to the state-quarter level; the outcome is log average quarterly earnings. ",
  "Column~(3) is not applicable because QWI provides aggregate data without individual-level controls. ",
  "Panel~B uses individual-level data from the CPS ASEC (wage/salary workers ages 25--64, income years 2014--2024); ",
  "the outcome is log hourly wage and regressions are weighted by ASECWT. ",
  "Column~(1): Callaway \\& Sant'Anna (2021) with doubly-robust estimation and never-treated controls. ",
  "Column~(2): two-way fixed effects (state + time). ",
  "Column~(3): adds 2-digit occupation and industry fixed effects. ",
  "$^{*}$ $p<0.10$, $^{**}$ $p<0.05$, $^{***}$ $p<0.01$.\n",
  "\\end{minipage}\n",
  "\\end{table}\n"
)

writeLines(tab_agg, "tables/tab_consolidated_agg.tex")
cat("  Saved tables/tab_consolidated_agg.tex\n\n")

# ============================================================================
# Table 2: Consolidated Gender Gap DDD
# ============================================================================

cat("Creating Table 2: Consolidated Gender Gap DDD...\n")

# --- Panel A: QWI ---
# DDD from stored results (state x quarter FE already included)
qwi_ddd_coef <- qwi_res$ddd$coef
qwi_ddd_se   <- qwi_res$ddd$se
qwi_ddd_pval <- 2 * pnorm(-abs(qwi_ddd_coef / qwi_ddd_se))

cat("  Panel A (QWI): DDD = ", sprintf("%.4f", qwi_ddd_coef),
    " (", sprintf("%.4f", qwi_ddd_se), ")\n")

# --- Panel B: CPS (run 4 fresh DDD specifications) ---

# (1) Basic DDD: state + year FE
cat("  Running CPS DDD (1) basic...\n")
d1 <- feols(log_hourly_wage ~ treat_post + treat_post:female + female |
              statefip + income_year,
            data = df, weights = ~ASECWT, cluster = ~statefip)
cps_d1_coef <- coef(d1)["treat_post:female"]
cps_d1_se   <- se(d1)["treat_post:female"]
cps_d1_pval <- fixest::pvalue(d1)["treat_post:female"]

# (2) + Occupation FE
cat("  Running CPS DDD (2) + occupation FE...\n")
d2 <- feols(log_hourly_wage ~ treat_post + treat_post:female + female |
              statefip + income_year + occ_major,
            data = df, weights = ~ASECWT, cluster = ~statefip)
cps_d2_coef <- coef(d2)["treat_post:female"]
cps_d2_se   <- se(d2)["treat_post:female"]
cps_d2_pval <- fixest::pvalue(d2)["treat_post:female"]

# (3) + Full controls (occupation FE + industry FE + demographic controls)
cat("  Running CPS DDD (3) + full controls...\n")
d3 <- feols(log_hourly_wage ~ treat_post + treat_post:female + female +
              age_group + educ_cat + race_eth + married |
              statefip + income_year + occ_major + ind_major,
            data = df, weights = ~ASECWT, cluster = ~statefip)
cps_d3_coef <- coef(d3)["treat_post:female"]
cps_d3_se   <- se(d3)["treat_post:female"]
cps_d3_pval <- fixest::pvalue(d3)["treat_post:female"]

# (4) State x Year FE (absorbs treat_post main effect)
cat("  Running CPS DDD (4) state x year FE...\n")
d4 <- feols(log_hourly_wage ~ treat_post:female + female |
              statefip^income_year + occ_major + ind_major,
            data = df, weights = ~ASECWT, cluster = ~statefip)
cps_d4_coef <- coef(d4)["treat_post:female"]
cps_d4_se   <- se(d4)["treat_post:female"]
cps_d4_pval <- fixest::pvalue(d4)["treat_post:female"]

cat("  Panel B (CPS): DDD = ",
    sprintf("%.4f", cps_d1_coef), " / ",
    sprintf("%.4f", cps_d2_coef), " / ",
    sprintf("%.4f", cps_d3_coef), " / ",
    sprintf("%.4f", cps_d4_coef), "\n")

# --- Build LaTeX ---
n_cps <- format(nrow(df), big.mark = ",")

tab_gender <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Effect of Salary Transparency Laws on the Gender Wage Gap}\n",
  "\\label{tab:gender}\n",
  "\\begin{tabular}{lcccc}\n",
  "\\toprule\n",
  " & (1) & (2) & (3) & (4) \\\\\n",
  " & Basic DDD & + Occupation FE & + Full Controls & State$\\times$Time FE \\\\\n",
  "\\midrule\n",
  "\\multicolumn{5}{l}{\\textit{Panel A: QWI Administrative Data (N = 2,603 state-quarters, 51 clusters)}} \\\\[3pt]\n",
  "Treated $\\times$ Post $\\times$ Female & ",
    fmt_coef(qwi_ddd_coef, qwi_ddd_pval), " & --- & --- & ",
    fmt_coef(qwi_ddd_coef, qwi_ddd_pval), " \\\\\n",
  " & ", fmt_se(qwi_ddd_se), " & & & ", fmt_se(qwi_ddd_se), " \\\\\n",
  "\\addlinespace\n",
  "\\multicolumn{5}{l}{\\textit{Panel B: CPS Microdata (N = ", n_cps, " workers, 51 state clusters)}} \\\\[3pt]\n",
  "Treated $\\times$ Post $\\times$ Female & ",
    fmt_coef(cps_d1_coef, cps_d1_pval), " & ",
    fmt_coef(cps_d2_coef, cps_d2_pval), " & ",
    fmt_coef(cps_d3_coef, cps_d3_pval), " & ",
    fmt_coef(cps_d4_coef, cps_d4_pval), " \\\\\n",
  " & ", fmt_se(cps_d1_se), " & ", fmt_se(cps_d2_se), " & ",
    fmt_se(cps_d3_se), " & ", fmt_se(cps_d4_se), " \\\\\n",
  "\\midrule\n",
  "State FE & Yes & Yes & Yes & \\\\\n",
  "Time FE & Yes & Yes & Yes & \\\\\n",
  "State$\\times$Time FE & & & & Yes \\\\\n",
  "Occupation FE & & Yes & Yes & Yes \\\\\n",
  "Industry FE & & & Yes & Yes \\\\\n",
  "Demographic controls & & & Yes & \\\\\n",
  "Clustering & State & State & State & State \\\\\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{minipage}{0.95\\textwidth}\n",
  "\\footnotesize\n",
  "\\textit{Notes:} Standard errors clustered at the state level (51 clusters) in parentheses. ",
  "The coefficient of interest is Treated $\\times$ Post $\\times$ Female; a positive value indicates ",
  "that transparency laws narrowed the gender gap (women's relative wages/earnings improved). ",
  "Panel~A uses sex-disaggregated QWI data with state$\\times$quarter fixed effects; individual-level controls ",
  "are not available in administrative aggregates, so columns (2)--(3) are not applicable. ",
  "The column (4) estimate repeats column (1) because the QWI specification already includes state$\\times$quarter FE. ",
  "Panel~B uses individual-level CPS ASEC data (wage/salary workers ages 25--64, income years 2014--2024). ",
  "Column~(1): basic triple-difference with state and year FE. ",
  "Column~(2): adds 2-digit occupation FE. ",
  "Column~(3): adds industry FE and demographic controls (age group, education, race/ethnicity, marital status). ",
  "Column~(4): replaces state and year FE with state$\\times$year FE, absorbing the Treated $\\times$ Post main effect. ",
  "$^{*}$ $p<0.10$, $^{**}$ $p<0.05$, $^{***}$ $p<0.01$.\n",
  "\\end{minipage}\n",
  "\\end{table}\n"
)

writeLines(tab_gender, "tables/tab_consolidated_gender.tex")
cat("  Saved tables/tab_consolidated_gender.tex\n\n")

# ============================================================================
# Summary
# ============================================================================

cat("==== Consolidated Table Generation Complete ====\n")
cat("Created tables:\n")
cat("  tables/tab_consolidated_agg.tex    - Panel A (QWI) / Panel B (CPS) aggregate effects\n")
cat("  tables/tab_consolidated_gender.tex - Panel A (QWI) / Panel B (CPS) gender gap DDD\n")
cat("\nKey results:\n")
cat(sprintf("  QWI C-S ATT (earnings):  %.4f (%.4f)\n", qwi_cs_att, qwi_cs_se))
cat(sprintf("  CPS C-S ATT (wages):     %.4f (%.4f)\n", cps_cs_att, cps_cs_se))
cat(sprintf("  QWI DDD (gender gap):    %.4f (%.4f)\n", qwi_ddd_coef, qwi_ddd_se))
cat(sprintf("  CPS DDD (gender gap):    %.4f (%.4f)\n", cps_d1_coef, cps_d1_se))
cat("\nDone.\n")
