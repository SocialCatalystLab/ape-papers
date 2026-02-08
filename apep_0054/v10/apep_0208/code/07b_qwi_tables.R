################################################################################
# 07b_qwi_tables.R
# Salary Transparency Laws and the Gender Wage Gap
# QWI Table Generation (LaTeX)
################################################################################
#
# --- Input/Output Provenance ---
# INPUTS:
#   data/qwi_results.rds          <- 04b_qwi_analysis.R (all QWI DiD results)
#   data/qwi_agg.rds              <- 02b_clean_qwi.R (state x quarter aggregate)
#   data/qwi_gender_gap.rds       <- 02b_clean_qwi.R (gender gap panel)
#   data/main_results.rds         <- 04_main_analysis.R (CPS results, for cross-dataset)
# OUTPUTS:
#   tables/tab_qwi_summary.tex
#   tables/tab_qwi_main.tex
#   tables/tab_qwi_dynamism.tex
#   tables/tab_qwi_industry.tex
#   tables/tab_cross_dataset.tex
################################################################################

source("code/00_packages.R")

cat("=== QWI Table Generation ===\n\n")

# ============================================================================
# Load Data
# ============================================================================

required_files <- c(
  "data/qwi_results.rds",
  "data/qwi_agg.rds",
  "data/qwi_gender_gap.rds"
)
for (f in required_files) {
  if (!file.exists(f)) stop("Required input file not found: ", f,
                            "\nRun upstream scripts first.")
}

qwi_res   <- readRDS("data/qwi_results.rds")
qwi_agg   <- readRDS("data/qwi_agg.rds")
qwi_gap   <- readRDS("data/qwi_gender_gap.rds")

# CPS results for cross-dataset comparison (optional but expected)
has_cps <- file.exists("data/main_results.rds")
if (has_cps) {
  cps_res <- readRDS("data/main_results.rds")
  cat("Loaded CPS results for cross-dataset comparison.\n")
}

dir.create("tables", showWarnings = FALSE)

cat("Data loaded.\n\n")

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

# ============================================================================
# Table QWI-1: Summary Statistics
# ============================================================================

cat("Creating Table QWI-1: Summary Statistics...\n")

# Panel dimensions
n_states   <- n_distinct(qwi_agg$statefip)
n_quarters <- n_distinct(qwi_agg$quarter_num)
n_obs_agg  <- nrow(qwi_agg)

# Identify treated vs control
n_treated_states <- sum(qwi_agg$g[!duplicated(qwi_agg$statefip)] > 0)
n_control_states <- n_states - n_treated_states

# Pre-treatment means by treatment status
qwi_pre <- qwi_agg %>%
  mutate(treated = ifelse(g > 0, "Treated", "Control")) %>%
  filter(is.na(g) | g == 0 | quarter_num < g)

pre_means <- qwi_pre %>%
  group_by(treated) %>%
  summarize(
    mean_earns     = mean(earns, na.rm = TRUE),
    mean_emp       = mean(emp, na.rm = TRUE),
    mean_hire_rate = mean(hire_rate, na.rm = TRUE),
    mean_sep_rate  = mean(sep_rate, na.rm = TRUE),
    mean_njc_rate  = mean(net_job_creation_rate, na.rm = TRUE),
    n_obs          = n(),
    .groups = "drop"
  )

# Gender gap pre-treatment means
qwi_gap_agg <- qwi_gap %>% filter(is_aggregate)
qwi_gap_pre <- qwi_gap_agg %>%
  mutate(treated = ifelse(g > 0, "Treated", "Control")) %>%
  filter(is.na(g) | g == 0 | quarter_num < g)

gap_pre_means <- qwi_gap_pre %>%
  group_by(treated) %>%
  summarize(
    mean_gap = mean(earns_gap, na.rm = TRUE),
    .groups = "drop"
  )

# Extract treated/control rows
treated_row <- pre_means %>% filter(treated == "Treated")
control_row <- pre_means %>% filter(treated == "Control")
gap_treated <- gap_pre_means %>% filter(treated == "Treated")
gap_control <- gap_pre_means %>% filter(treated == "Control")

# Safe formatting: use 0 if no rows exist
fmt_t <- function(x) if (length(x) == 0 || is.na(x)) "---" else sprintf("%.0f", x)
fmt_t2 <- function(x) if (length(x) == 0 || is.na(x)) "---" else sprintf("%.3f", x)
fmt_t3 <- function(x) if (length(x) == 0 || is.na(x)) "---" else format(round(x), big.mark = ",")

tab_qwi_summary <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{QWI Summary Statistics}\n",
  "\\label{tab:qwi_summary}\n",
  "\\begin{tabular}{lcc}\n",
  "\\toprule\n",
  " & Treated States & Control States \\\\\n",
  "\\midrule\n",
  "\\multicolumn{3}{l}{\\textit{Panel A: Panel Dimensions}} \\\\[3pt]\n",
  "States & ", n_treated_states, " & ", n_control_states, " \\\\\n",
  "Quarters & ", n_quarters, " & ", n_quarters, " \\\\\n",
  "State-Quarter Observations & ",
    format(sum(pre_means$n_obs[pre_means$treated == "Treated"]), big.mark = ","), " & ",
    format(sum(pre_means$n_obs[pre_means$treated == "Control"]), big.mark = ","), " \\\\\n",
  "\\addlinespace\n",
  "\\multicolumn{3}{l}{\\textit{Panel B: Pre-Treatment Means}} \\\\[3pt]\n",
  "Average Quarterly Earnings (\\$) & ",
    fmt_t3(treated_row$mean_earns), " & ",
    fmt_t3(control_row$mean_earns), " \\\\\n",
  "Average Employment & ",
    fmt_t3(treated_row$mean_emp), " & ",
    fmt_t3(control_row$mean_emp), " \\\\\n",
  "Hiring Rate & ",
    fmt_t2(treated_row$mean_hire_rate), " & ",
    fmt_t2(control_row$mean_hire_rate), " \\\\\n",
  "Separation Rate & ",
    fmt_t2(treated_row$mean_sep_rate), " & ",
    fmt_t2(control_row$mean_sep_rate), " \\\\\n",
  "Net Job Creation Rate & ",
    fmt_t2(treated_row$mean_njc_rate), " & ",
    fmt_t2(control_row$mean_njc_rate), " \\\\\n",
  "Gender Earnings Gap (M$-$F) & ",
    fmt_t2(gap_treated$mean_gap), " & ",
    fmt_t2(gap_control$mean_gap), " \\\\\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{minipage}{0.92\\textwidth}\n",
  "\\footnotesize\n",
  "\\textit{Notes:} Data from the Census Bureau's Quarterly Workforce Indicators (QWI), ",
  "aggregated to the state-quarter level. Treated states enacted salary transparency laws; ",
  "control states are never-treated. Pre-treatment means computed over quarters prior to ",
  "each state's treatment date. Earnings are average quarterly earnings per worker. ",
  "Hiring rate = hires/employment; separation rate = separations/employment; ",
  "net job creation rate = (hires $-$ separations)/employment. ",
  "Gender earnings gap = male average earnings $-$ female average earnings.\n",
  "\\end{minipage}\n",
  "\\end{table}\n"
)

writeLines(tab_qwi_summary, "tables/tab_qwi_summary.tex")
cat("  Saved tables/tab_qwi_summary.tex\n")

# ============================================================================
# Table QWI-2: Main Results (Earnings + Gender Gap)
# ============================================================================

cat("\nCreating Table QWI-2: Main Results...\n")

# Extract C-S ATT for earnings
cs_earns_att  <- qwi_res$cs_earns_att$att
cs_earns_se   <- qwi_res$cs_earns_att$se
cs_earns_pval <- 2 * pnorm(-abs(cs_earns_att / cs_earns_se))

# TWFE earnings
twfe_earns_coef <- qwi_res$twfe_earns$coef
twfe_earns_se   <- qwi_res$twfe_earns$se
twfe_earns_pval <- 2 * pnorm(-abs(twfe_earns_coef / twfe_earns_se))

# C-S Gender Gap (may or may not exist)
has_cs_gap <- !is.null(qwi_res$cs_gap_att)
if (has_cs_gap) {
  cs_gap_att  <- qwi_res$cs_gap_att$att
  cs_gap_se   <- qwi_res$cs_gap_att$se
  cs_gap_pval <- 2 * pnorm(-abs(cs_gap_att / cs_gap_se))
}

# TWFE Gender Gap
twfe_gap_coef <- qwi_res$twfe_gap$coef
twfe_gap_se   <- qwi_res$twfe_gap$se
twfe_gap_pval <- 2 * pnorm(-abs(twfe_gap_coef / twfe_gap_se))

# DDD (treat_post x female)
has_ddd <- !is.null(qwi_res$ddd)
if (has_ddd) {
  ddd_coef <- qwi_res$ddd$coef
  ddd_se   <- qwi_res$ddd$se
  ddd_pval <- 2 * pnorm(-abs(ddd_coef / ddd_se))
}

# Get N from re-running a minimal query on the data
n_earns <- nrow(qwi_agg %>% filter(!is.na(log_earns)))
n_gap   <- nrow(qwi_gap_agg %>% filter(!is.na(earns_gap)))

# Format helper
fmt_coef <- function(val, pval) {
  paste0(sprintf("%.4f", val), stars(pval))
}
fmt_se_paren <- function(val) {
  sprintf("(%.4f)", val)
}

tab_qwi_main <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{QWI Main Results: Earnings and Gender Gap}\n",
  "\\label{tab:qwi_main}\n",
  "\\begin{tabular}{lcc}\n",
  "\\toprule\n",
  " & C-S ATT & TWFE \\\\\n",
  "\\midrule\n",
  "\\multicolumn{3}{l}{\\textit{Panel A: Log Quarterly Earnings}} \\\\[3pt]\n",
  "Treated $\\times$ Post & ",
    fmt_coef(cs_earns_att, cs_earns_pval), " & ",
    fmt_coef(twfe_earns_coef, twfe_earns_pval), " \\\\\n",
  " & ", fmt_se_paren(cs_earns_se), " & ", fmt_se_paren(twfe_earns_se), " \\\\\n",
  "N & ", format(n_earns, big.mark = ","), " & ", format(n_earns, big.mark = ","), " \\\\\n",
  "\\addlinespace\n",
  "\\multicolumn{3}{l}{\\textit{Panel B: Gender Earnings Gap (Male $-$ Female)}} \\\\[3pt]\n",
  "Treated $\\times$ Post & ",
    if (has_cs_gap) fmt_coef(cs_gap_att, cs_gap_pval) else "---", " & ",
    fmt_coef(twfe_gap_coef, twfe_gap_pval), " \\\\\n",
  " & ",
    if (has_cs_gap) fmt_se_paren(cs_gap_se) else "", " & ",
    fmt_se_paren(twfe_gap_se), " \\\\\n",
  "N & ", format(n_gap, big.mark = ","), " & ", format(n_gap, big.mark = ","), " \\\\\n",
  "\\addlinespace\n",
  "\\multicolumn{3}{l}{\\textit{Panel C: DDD (Treated $\\times$ Post $\\times$ Female)}} \\\\[3pt]\n",
  "Treated $\\times$ Post $\\times$ Female & ",
    if (has_ddd) fmt_coef(ddd_coef, ddd_pval) else "---", " & --- \\\\\n",
  " & ",
    if (has_ddd) fmt_se_paren(ddd_se) else "", " & \\\\\n",
  "\\midrule\n",
  "State FE & Yes & Yes \\\\\n",
  "Quarter FE & Yes & Yes \\\\\n",
  "Clustering & State & State \\\\\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{minipage}{0.92\\textwidth}\n",
  "\\footnotesize\n",
  "\\textit{Notes:} Standard errors clustered at the state level in parentheses. ",
  "Panel A reports the effect on log average quarterly earnings from the QWI state-quarter panel. ",
  "Panel B reports the effect on the raw gender earnings gap (male earnings $-$ female earnings); ",
  "a negative coefficient indicates the gap narrowed. ",
  "Panel C reports the triple-difference coefficient from a sex-specific panel (male and female earnings ",
  "stacked) with state$\\times$quarter fixed effects; a positive coefficient indicates women's earnings ",
  "rose relative to men's. ",
  "C-S ATT uses Callaway \\& Sant'Anna (2021) with doubly-robust estimation and never-treated controls. ",
  "$^{*}$ $p<0.10$, $^{**}$ $p<0.05$, $^{***}$ $p<0.01$.\n",
  "\\end{minipage}\n",
  "\\end{table}\n"
)

writeLines(tab_qwi_main, "tables/tab_qwi_main.tex")
cat("  Saved tables/tab_qwi_main.tex\n")

# ============================================================================
# Table QWI-3: Labor Market Dynamism
# ============================================================================

cat("\nCreating Table QWI-3: Labor Market Dynamism...\n")

# Dynamism results stored as a named list in qwi_res$dynamism
dyn <- qwi_res$dynamism

# Outcome labels mapping
outcome_labels <- c(
  hire_rate             = "Hiring Rate",
  sep_rate              = "Separation Rate",
  log_hira              = "Log Hires",
  log_sep               = "Log Separations",
  net_job_creation_rate = "Net Job Creation Rate"
)

# TWFE outcomes
twfe_outcomes <- c("hire_rate", "sep_rate", "log_hira", "log_sep", "net_job_creation_rate")
# C-S outcomes (only hire_rate and sep_rate have C-S)
cs_outcomes <- c("hire_rate_cs", "sep_rate_cs")

tab_qwi_dynamism <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{QWI Labor Market Dynamism Results}\n",
  "\\label{tab:qwi_dynamism}\n",
  "\\begin{tabular}{lccccc}\n",
  "\\toprule\n",
  " & \\multicolumn{2}{c}{TWFE} & & \\multicolumn{2}{c}{C-S ATT} \\\\\n",
  "\\cmidrule{2-3} \\cmidrule{5-6}\n",
  "Outcome & Coeff. & SE & & ATT & SE \\\\\n",
  "\\midrule\n"
)

for (outcome in twfe_outcomes) {
  label <- outcome_labels[outcome]
  twfe_entry <- dyn[[outcome]]
  cs_key <- paste0(outcome, "_cs")
  cs_entry <- dyn[[cs_key]]

  # TWFE values
  if (!is.null(twfe_entry)) {
    twfe_coef_val <- twfe_entry$coef
    twfe_se_val   <- twfe_entry$se
    twfe_pval     <- twfe_entry$pval
    twfe_n        <- twfe_entry$n
    twfe_str <- paste0(fmt_coef(twfe_coef_val, twfe_pval),
                       " & ", fmt_se_paren(twfe_se_val))
  } else {
    twfe_str <- "--- & ---"
    twfe_n <- NA
  }

  # C-S values
  if (!is.null(cs_entry)) {
    cs_coef_val <- cs_entry$coef
    cs_se_val   <- cs_entry$se
    # No pval stored for C-S dynamism, compute from normal approx
    cs_pval <- 2 * pnorm(-abs(cs_coef_val / cs_se_val))
    cs_str <- paste0(fmt_coef(cs_coef_val, cs_pval),
                     " & ", fmt_se_paren(cs_se_val))
  } else {
    cs_str <- "--- & ---"
  }

  tab_qwi_dynamism <- paste0(tab_qwi_dynamism,
    label, " & ", twfe_str, " & & ", cs_str, " \\\\\n"
  )
}

# Add N row (use the first available TWFE N)
first_n <- NA
for (outcome in twfe_outcomes) {
  if (!is.null(dyn[[outcome]])) {
    first_n <- dyn[[outcome]]$n
    break
  }
}

tab_qwi_dynamism <- paste0(tab_qwi_dynamism,
  "\\midrule\n",
  "N & \\multicolumn{2}{c}{",
    if (!is.na(first_n)) format(first_n, big.mark = ",") else "---",
  "} & & \\multicolumn{2}{c}{",
    if (!is.na(first_n)) format(first_n, big.mark = ",") else "---",
  "} \\\\\n",
  "State FE & \\multicolumn{2}{c}{Yes} & & \\multicolumn{2}{c}{Yes} \\\\\n",
  "Quarter FE & \\multicolumn{2}{c}{Yes} & & \\multicolumn{2}{c}{Yes} \\\\\n",
  "Clustering & \\multicolumn{2}{c}{State} & & \\multicolumn{2}{c}{State} \\\\\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{minipage}{0.92\\textwidth}\n",
  "\\footnotesize\n",
  "\\textit{Notes:} Standard errors clustered at the state level in parentheses. ",
  "All outcomes from the QWI state-quarter panel. Hiring rate = total hires / beginning-of-quarter ",
  "employment; separation rate = total separations / beginning-of-quarter employment; ",
  "net job creation rate = (hires $-$ separations) / employment. ",
  "TWFE includes state and quarter fixed effects. C-S uses Callaway \\& Sant'Anna (2021) ",
  "with never-treated controls (estimated for rate outcomes only). ",
  "$^{*}$ $p<0.10$, $^{**}$ $p<0.05$, $^{***}$ $p<0.01$.\n",
  "\\end{minipage}\n",
  "\\end{table}\n"
)

writeLines(tab_qwi_dynamism, "tables/tab_qwi_dynamism.tex")
cat("  Saved tables/tab_qwi_dynamism.tex\n")

# ============================================================================
# Table QWI-4: Industry Heterogeneity
# ============================================================================

cat("\nCreating Table QWI-4: Industry Heterogeneity...\n")

ind <- qwi_res$industry

# Separate earnings-level and gap results
# Earnings results have no $outcome field; gap results have outcome == "earnings_gap"
ind_earnings <- list()
ind_gap <- list()
for (nm in names(ind)) {
  entry <- ind[[nm]]
  if (!is.null(entry$outcome) && entry$outcome == "earnings_gap") {
    ind_gap[[entry$industry]] <- entry
  } else if (is.null(entry$outcome)) {
    ind_earnings[[entry$industry]] <- entry
  }
}

# Get unique industry names (union of both)
all_industries <- unique(c(names(ind_earnings), names(ind_gap)))

tab_qwi_industry <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{QWI Industry Heterogeneity: Earnings and Gender Gap Effects}\n",
  "\\label{tab:qwi_industry}\n",
  "\\begin{tabular}{lcccc}\n",
  "\\toprule\n",
  " & \\multicolumn{2}{c}{Log Earnings} & \\multicolumn{2}{c}{Gender Earnings Gap} \\\\\n",
  "\\cmidrule(lr){2-3} \\cmidrule(lr){4-5}\n",
  "Industry & Coeff. & SE & Coeff. & SE \\\\\n",
  "\\midrule\n"
)

for (ind_name in all_industries) {
  # Earnings
  e <- ind_earnings[[ind_name]]
  if (!is.null(e)) {
    e_str <- paste0(fmt_coef(e$coef, e$pval), " & ", fmt_se_paren(e$se))
  } else {
    e_str <- "--- & ---"
  }

  # Gap
  g <- ind_gap[[ind_name]]
  if (!is.null(g)) {
    g_str <- paste0(fmt_coef(g$coef, g$pval), " & ", fmt_se_paren(g$se))
  } else {
    g_str <- "--- & ---"
  }

  # Escape ampersands in industry name for LaTeX
  safe_name <- gsub("&", "\\\\&", ind_name)

  tab_qwi_industry <- paste0(tab_qwi_industry,
    safe_name, " & ", e_str, " & ", g_str, " \\\\\n"
  )
}

tab_qwi_industry <- paste0(tab_qwi_industry,
  "\\midrule\n",
  "State FE & \\multicolumn{2}{c}{Yes} & \\multicolumn{2}{c}{Yes} \\\\\n",
  "Quarter FE & \\multicolumn{2}{c}{Yes} & \\multicolumn{2}{c}{Yes} \\\\\n",
  "Clustering & \\multicolumn{2}{c}{State} & \\multicolumn{2}{c}{State} \\\\\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{minipage}{0.92\\textwidth}\n",
  "\\footnotesize\n",
  "\\textit{Notes:} Each cell reports a separate TWFE regression of the outcome on ",
  "Treated $\\times$ Post with state and quarter fixed effects, estimated within the ",
  "indicated NAICS sector. Standard errors clustered at the state level in parentheses. ",
  "Log Earnings columns use the sex-aggregate ($sex=0$) QWI panel by industry. ",
  "Gender Earnings Gap columns use the male$-$female earnings difference within each industry. ",
  "High-bargaining sectors (Finance, Professional Services) are expected to show larger ",
  "transparency effects per Cullen \\& Pakzad-Hurson (2023); low-bargaining sectors ",
  "(Retail, Accommodation) provide a comparison group. ",
  "$^{*}$ $p<0.10$, $^{**}$ $p<0.05$, $^{***}$ $p<0.01$.\n",
  "\\end{minipage}\n",
  "\\end{table}\n"
)

writeLines(tab_qwi_industry, "tables/tab_qwi_industry.tex")
cat("  Saved tables/tab_qwi_industry.tex\n")

# ============================================================================
# Table QWI-5: Cross-Dataset Comparison (CPS vs QWI)
# ============================================================================

cat("\nCreating Table QWI-5: Cross-Dataset Comparison...\n")

if (has_cps) {
  # CPS C-S ATT (aggregate)
  cps_cs_att  <- cps_res$att_simple$overall.att
  cps_cs_se   <- cps_res$att_simple$overall.se
  cps_cs_pval <- 2 * pnorm(-abs(cps_cs_att / cps_cs_se))

  # CPS DDD (treat_post:female from ddd_result)
  cps_ddd_coef <- coef(cps_res$ddd_result)["treat_post:female"]
  cps_ddd_se   <- se(cps_res$ddd_result)["treat_post:female"]
  cps_ddd_pval <- fixest::pvalue(cps_res$ddd_result)["treat_post:female"]

  # CPS TWFE (from main TWFE; the first model in main_results)
  # Use state-year aggregate TWFE if available
  cps_twfe_coef <- NA
  cps_twfe_se   <- NA
  cps_twfe_pval <- NA
  if (!is.null(cps_res$twfe_state)) {
    cps_twfe_coef <- coef(cps_res$twfe_state)["treat_post"]
    cps_twfe_se   <- se(cps_res$twfe_state)["treat_post"]
    cps_twfe_pval <- fixest::pvalue(cps_res$twfe_state)["treat_post"]
  }
} else {
  cps_cs_att <- NA; cps_cs_se <- NA; cps_cs_pval <- NA
  cps_ddd_coef <- NA; cps_ddd_se <- NA; cps_ddd_pval <- NA
  cps_twfe_coef <- NA; cps_twfe_se <- NA; cps_twfe_pval <- NA
}

# Format helper for cross-dataset
fmt_or_dash <- function(val, pval) {
  if (is.na(val)) return("---")
  fmt_coef(val, pval)
}
se_or_empty <- function(val) {
  if (is.na(val)) return("")
  fmt_se_paren(val)
}

tab_cross <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Cross-Dataset Comparison: CPS vs.\\ QWI Estimates}\n",
  "\\label{tab:cross_dataset}\n",
  "\\begin{tabular}{lcccc}\n",
  "\\toprule\n",
  " & \\multicolumn{2}{c}{CPS ASEC} & \\multicolumn{2}{c}{QWI} \\\\\n",
  "\\cmidrule(lr){2-3} \\cmidrule(lr){4-5}\n",
  " & C-S ATT & TWFE & C-S ATT & TWFE \\\\\n",
  "\\midrule\n",
  "\\multicolumn{5}{l}{\\textit{Panel A: Aggregate Wage/Earnings Effect}} \\\\[3pt]\n",
  "Treated $\\times$ Post & ",
    fmt_or_dash(cps_cs_att, cps_cs_pval), " & ",
    fmt_or_dash(cps_twfe_coef, cps_twfe_pval), " & ",
    fmt_coef(cs_earns_att, cs_earns_pval), " & ",
    fmt_coef(twfe_earns_coef, twfe_earns_pval), " \\\\\n",
  " & ", se_or_empty(cps_cs_se), " & ",
    se_or_empty(cps_twfe_se), " & ",
    fmt_se_paren(cs_earns_se), " & ",
    fmt_se_paren(twfe_earns_se), " \\\\\n",
  "\\addlinespace\n",
  "\\multicolumn{5}{l}{\\textit{Panel B: Gender Gap / DDD Effect}} \\\\[3pt]\n",
  "DDD ($\\beta_2$) or Gap & ",
    fmt_or_dash(cps_ddd_coef, cps_ddd_pval), " & --- & ",
    if (has_cs_gap) fmt_coef(cs_gap_att, cs_gap_pval) else "---", " & ",
    fmt_coef(twfe_gap_coef, twfe_gap_pval), " \\\\\n",
  " & ", se_or_empty(cps_ddd_se), " & & ",
    if (has_cs_gap) fmt_se_paren(cs_gap_se) else "", " & ",
    fmt_se_paren(twfe_gap_se), " \\\\\n",
  "\\midrule\n",
  "Unit of observation & \\multicolumn{2}{c}{Individual} & \\multicolumn{2}{c}{State-Quarter} \\\\\n",
  "Outcome variable & \\multicolumn{2}{c}{Log hourly wage} & \\multicolumn{2}{c}{Log quarterly earnings} \\\\\n",
  "Frequency & \\multicolumn{2}{c}{Annual} & \\multicolumn{2}{c}{Quarterly} \\\\\n",
  "Source & \\multicolumn{2}{c}{CPS ASEC} & \\multicolumn{2}{c}{LEHD/QWI} \\\\\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{minipage}{0.95\\textwidth}\n",
  "\\footnotesize\n",
  "\\textit{Notes:} Side-by-side comparison of estimates from the CPS ASEC individual-level analysis ",
  "and the QWI administrative state-quarter panel. CPS outcomes are log hourly wages; QWI outcomes are ",
  "log average quarterly earnings. The CPS gender effect is a triple-difference coefficient ",
  "(Treated $\\times$ Post $\\times$ Female); the QWI gender effect is the gap in average earnings ",
  "(male $-$ female). Standard errors clustered at the state level in parentheses. ",
  "C-S ATT uses Callaway \\& Sant'Anna (2021); TWFE includes state and time fixed effects. ",
  "$^{*}$ $p<0.10$, $^{**}$ $p<0.05$, $^{***}$ $p<0.01$.\n",
  "\\end{minipage}\n",
  "\\end{table}\n"
)

writeLines(tab_cross, "tables/tab_cross_dataset.tex")
cat("  Saved tables/tab_cross_dataset.tex\n")

# ============================================================================
# Summary
# ============================================================================

cat("\n==== QWI Table Generation Complete ====\n")
cat("Created tables:\n")
cat("  tables/tab_qwi_summary.tex    - QWI summary statistics\n")
cat("  tables/tab_qwi_main.tex       - QWI main earnings and gender gap results\n")
cat("  tables/tab_qwi_dynamism.tex   - Labor market dynamism results\n")
cat("  tables/tab_qwi_industry.tex   - Industry heterogeneity\n")
cat("  tables/tab_cross_dataset.tex  - Cross-dataset CPS vs QWI comparison\n")
