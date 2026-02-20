# =============================================================================
# 06_tables.R — All Table Generation
# apep_0427: France Apprenticeship Subsidy and Entry-Level Labor Markets
# =============================================================================

source("00_packages.R")

cat("=== Generating tables for apep_0427 ===\n")

# Load data and models
cross_country  <- readRDS("../data/cross_country_panel.rds")
sector_panel   <- readRDS("../data/sector_panel.rds")
models         <- readRDS("../data/main_models.rds")

# =============================================================
# Table 1: Summary Statistics
# =============================================================
cat("Table 1: Summary statistics...\n")

# Cross-country youth employment — use same sample as regressions (2015+)
cc_youth <- cross_country %>%
  filter(age_group == "Y15-24")

cc_fr <- cc_youth %>% filter(country == "FR")
cc_ctrl <- cc_youth %>% filter(country != "FR")

summ_stats <- tribble(
  ~Variable, ~Mean_FR, ~SD_FR, ~Mean_Ctrl, ~SD_Ctrl,
  "Youth employment rate (\\%)", mean(cc_fr$emp_rate, na.rm = T), sd(cc_fr$emp_rate, na.rm = T),
    mean(cc_ctrl$emp_rate, na.rm = T), sd(cc_ctrl$emp_rate, na.rm = T)
)

# Add sector-level stats
sp <- sector_panel %>% filter(!is.na(youth_share))
summ_sector <- tribble(
  ~Variable, ~Mean, ~SD, ~Min, ~Max, ~N,
  "Youth employment share (\\%)", mean(sp$youth_share, na.rm = T),
    sd(sp$youth_share, na.rm = T), min(sp$youth_share, na.rm = T),
    max(sp$youth_share, na.rm = T), sum(!is.na(sp$youth_share)),
  "Apprenticeship exposure", mean(sp$exposure, na.rm = T),
    sd(sp$exposure, na.rm = T), min(sp$exposure, na.rm = T),
    max(sp$exposure, na.rm = T), sum(!is.na(sp$exposure)),
  "Youth employment (thousands)", mean(sp$emp_youth, na.rm = T),
    sd(sp$emp_youth, na.rm = T), min(sp$emp_youth, na.rm = T),
    max(sp$emp_youth, na.rm = T), sum(!is.na(sp$emp_youth)),
  "Total employment (thousands)", mean(sp$emp_total, na.rm = T),
    sd(sp$emp_total, na.rm = T), min(sp$emp_total, na.rm = T),
    max(sp$emp_total, na.rm = T), sum(!is.na(sp$emp_total))
)

# Write LaTeX
sink("../tables/tab1_summary.tex")
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{l S[table-format=4.1] S[table-format=4.1] S[table-format=4.1] S[table-format=4.1] S[table-format=5.0]}\n")
cat("\\toprule\n")
cat("Variable & {Mean} & {Std. Dev.} & {Min} & {Max} & {N} \\\\\n")
cat("\\midrule\n")
n_sectors <- length(unique(sp$sector))
cat(sprintf("\\multicolumn{6}{l}{\\textit{Panel A: France Sector-Quarter Panel (2015Q1--2025Q3, %d sectors)}} \\\\\n", n_sectors))
# Use more precision for exposure row to show meaningful variation
for (i in 1:nrow(summ_sector)) {
  if (grepl("exposure", summ_sector$Variable[i], ignore.case = TRUE)) {
    # Exposure is already in percentage points (1-18) after rescaling in 02_clean_data.R
    cat(sprintf("Apprenticeship exposure (\\%%) & %.1f & %.1f & %.1f & %.1f & %d \\\\\n",
                summ_sector$Mean[i], summ_sector$SD[i],
                summ_sector$Min[i], summ_sector$Max[i], summ_sector$N[i]))
  } else {
    cat(sprintf("%s & %.1f & %.1f & %.1f & %.1f & %d \\\\\n",
                summ_sector$Variable[i], summ_sector$Mean[i], summ_sector$SD[i],
                summ_sector$Min[i], summ_sector$Max[i], summ_sector$N[i]))
  }
}
cat("\\midrule\n")
cat("\\multicolumn{6}{l}{\\textit{Panel B: Cross-Country Quarterly Panel (2015Q1--2025Q3)}} \\\\\n")
cat(sprintf("Youth employment rate, France (\\%%) & %.1f & %.1f & %.1f & %.1f & %d \\\\\n",
            summ_stats$Mean_FR, summ_stats$SD_FR,
            min(cc_fr$emp_rate, na.rm = T), max(cc_fr$emp_rate, na.rm = T), nrow(cc_fr)))
cat(sprintf("Youth employment rate, Controls (\\%%) & %.1f & %.1f & %.1f & %.1f & %d \\\\\n",
            summ_stats$Mean_Ctrl, summ_stats$SD_Ctrl,
            min(cc_ctrl$emp_rate, na.rm = T), max(cc_ctrl$emp_rate, na.rm = T), nrow(cc_ctrl)))
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item Notes: Panel A reports statistics for the France sector-quarter panel used in the exposure DiD analysis. Apprenticeship exposure measures the 2019 share of apprenticeship contracts in sector employment (DARES/CEDEFOP), in percentage points. Regression coefficients are per percentage point of exposure. Panel B reports youth (15--24) employment rates from Eurostat LFS. Controls: Belgium, Netherlands, Spain, Italy, Portugal, Germany, Austria.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\label{tab:summary}\n")
cat("\\end{table}\n")
sink()

# =============================================================
# Table 2: Main Results — Bartik DiD
# =============================================================
cat("Table 2: Main Bartik DiD results...\n")

setFixest_dict(c(
  bartik_reduction = "Exposure $\\times$ Post-Reduction",
  `high_exposure:post_reduction` = "High Exposure $\\times$ Post-Reduction",
  bartik_subsidy = "Exposure $\\times$ Post-Introduction",
  youth_share = "Youth Share (\\%)",
  emp_youth = "Youth Emp. (000s)",
  emp_total = "Total Emp. (000s)",
  prime_share = "Prime-Age Share (\\%)",
  sector = "Sector",
  yq = "Year-Quarter"
))

# Load prime-age placebo
m_placebo_prime <- readRDS("../data/placebo_prime_age.rds")

# Delete existing file to prevent append
unlink("../tables/tab2_main_bartik.tex")
etable(
  models$bartik_youth_share,
  models$bartik_youth_level,
  models$binary_exposure,
  models$bartik_total_placebo,
  m_placebo_prime,
  tex = TRUE,
  style.tex = style.tex("aer"),
  fitstat = ~ r2 + n,
  headers = c("Youth Share (\\%)", "Youth (000s)", "Binary", "Total (000s)", "Prime-Age (\\%)"),
  title = "Effect of Apprenticeship Subsidy Reduction on Employment",
  label = "tab:main_bartik",
  adjustbox = TRUE,
  notes = c("Standard errors clustered at sector level in parentheses.",
            "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.",
            "All specifications include sector and year-quarter fixed effects.",
            "Exposure measures 2019 sector apprenticeship intensity (DARES), in percentage points.",
            "Coefficients are per percentage point of exposure.",
            "Post-Reduction = 1 after January 2023 subsidy cut.",
            "Col 5: Prime-age (25+) employment share as placebo outcome."),
  file = "../tables/tab2_main_bartik.tex"
)

# =============================================================
# Table 3: Cross-Country DiD and Triple-Diff
# =============================================================
cat("Table 3: Cross-country results...\n")

setFixest_dict(c(
  `france:post_reduction` = "France $\\times$ Post-Reduction",
  fr_youth_reduction = "France $\\times$ Youth $\\times$ Post-Reduction",
  `france:post_subsidy` = "France $\\times$ Post-Introduction",
  emp_rate = "Emp. Rate (\\%)",
  neet_rate = "NEET Rate (\\%)",
  temp_share = "Temp. Share (\\%)",
  country = "Country",
  yq = "Year-Quarter",
  age_group = "Age Group"
))

unlink("../tables/tab3_cross_country.tex")
etable(
  models$did_youth,
  models$did_intro,
  models$ddd,
  models$neet,
  models$temp_emp,
  tex = TRUE,
  style.tex = style.tex("aer"),
  fitstat = ~ r2 + n,
  headers = c("Youth Emp (Redn)", "Youth Emp (Intro)", "DDD", "NEET", "Temp Emp"),
  title = "Cross-Country Difference-in-Differences: Subsidy Effects on Youth Outcomes",
  label = "tab:cross_country",
  adjustbox = TRUE,
  notes = c("Standard errors clustered at country level in parentheses.",
            "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.",
            "Controls: Belgium, Netherlands, Spain, Italy, Portugal, Germany, Austria.",
            "Col 1--2: Youth (15--24) employment rate.",
            "Col 3: Triple-diff (France $\\times$ Youth $\\times$ Post).",
            "Col 4: NEET rate (15--24). Col 5: Temporary employment share."),
  file = "../tables/tab3_cross_country.tex"
)

# =============================================================
# Table 4: Alternative Control Groups
# =============================================================
cat("Table 4: Alternative control groups...\n")

rob_cc <- readRDS("../data/robustness_control_groups.rds")

unlink("../tables/tab4_alt_controls.tex")
etable(
  models$did_youth,
  rob_cc$no_germany,
  rob_cc$southern_only,
  rob_cc$neighbors_only,
  tex = TRUE,
  style.tex = style.tex("aer"),
  fitstat = ~ r2 + n,
  headers = c("Baseline", "Excl. Germany", "Southern EU", "Neighbors"),
  title = "Robustness: Alternative Control Groups",
  label = "tab:alt_controls",
  adjustbox = TRUE,
  notes = c("Standard errors clustered at country level in parentheses.",
            "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.",
            "Baseline: BE, NL, ES, IT, PT, DE, AT.",
            "Southern EU: ES, IT, PT. Neighbors: BE, DE, NL."),
  file = "../tables/tab4_alt_controls.tex"
)

# =============================================================
# Table 5: Inference Comparison (Clustered SE, RI, WCB)
# =============================================================
cat("Table 5: Inference comparison...\n")

ri_results <- readRDS("../data/permutation_inference.rds")
wcb_results <- readRDS("../data/wcb_results.rds")

# Extract p-values safely
get_wcb_p <- function(x) {
  if (is.null(x) || is.na(x$p_val)) return("---")
  sprintf("%.3f", x$p_val)
}
wcb_p_main <- get_wcb_p(wcb_results$main)
wcb_p_level <- get_wcb_p(wcb_results$level)
wcb_p_total <- get_wcb_p(wcb_results$total)
wcb_p_cc <- get_wcb_p(wcb_results$cross_country)

# Get clustered p-values from main models
get_p <- function(m, coef_name) {
  ct <- coeftable(m)
  idx <- grep(coef_name, rownames(ct), fixed = TRUE)
  if (length(idx) > 0) sprintf("%.3f", ct[idx[1], "Pr(>|t|)"]) else "---"
}

sink("../tables/tab5_inference.tex")
cat("\\begin{table}[H]\n")
cat("\\centering\n")
cat("\\caption{Inference Comparison: Clustered SEs, Randomization Inference, and Wild Cluster Bootstrap}\n")
cat("\\begin{threeparttable}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat(" & Youth Share & Youth Level & Total Emp. & Cross-Country \\\\\n")
cat(" & (1) & (2) & (3) & (4) \\\\\n")
cat("\\midrule\n")

# Coefficients
b1 <- sprintf("%.3f", coef(models$bartik_youth_share)["bartik_reduction"])
b2 <- sprintf("%.2f", coef(models$bartik_youth_level)["bartik_reduction"])
b3 <- sprintf("%.2f", coef(models$bartik_total_placebo)["bartik_reduction"])
b4_ct <- coeftable(models$did_youth)
b4_idx <- grep("france.*post_reduction|post_reduction", rownames(b4_ct))
b4 <- if (length(b4_idx) > 0) sprintf("%.2f", b4_ct[b4_idx[1], "Estimate"]) else "---"

cat(sprintf("Coefficient & %s & %s & %s & %s \\\\\n", b1, b2, b3, b4))

# Clustered SE p-values
p1 <- get_p(models$bartik_youth_share, "bartik_reduction")
p2 <- get_p(models$bartik_youth_level, "bartik_reduction")
p3 <- get_p(models$bartik_total_placebo, "bartik_reduction")
p4_all <- coeftable(models$did_youth)
p4_idx <- grep("france.*post_reduction|post_reduction", rownames(p4_all))
p4 <- if (length(p4_idx) > 0) sprintf("%.3f", p4_all[p4_idx[1], "Pr(>|t|)"]) else "---"
cat(sprintf("Clustered SE $p$-value & %s & %s & %s & %s \\\\\n", p1, p2, p3, p4))

# RI p-value (sector-level only)
ri_p <- sprintf("%.3f", ri_results$p)
cat(sprintf("RI $p$-value & %s & --- & --- & --- \\\\\n", ri_p))

# WCB p-values
cat(sprintf("WCB $p$-value & %s & %s & %s & %s \\\\\n",
            wcb_p_main, wcb_p_level, wcb_p_total, wcb_p_cc))

cat("\\midrule\n")
cat("Clusters & 19 sectors & 19 sectors & 19 sectors & 8 countries \\\\\n")
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item Notes: Cols 1--3: Exposure DiD (sector-level design). Col 4: Cross-country DiD (France vs.\\ 7 EU comparators, youth 15--24). Clustered SEs at sector level (cols 1--3) or country level (col 4). RI permutes exposure assignments across 19 sectors (1,000 permutations). WCB uses Rademacher weights with 999 bootstrap iterations, imposing the null hypothesis \\citep{cameron2008bootstrap}.\n")
cat("\\end{tablenotes}\n")
cat("\\end{threeparttable}\n")
cat("\\label{tab:inference}\n")
cat("\\end{table}\n")
sink()

# =============================================================
# Table 6: Pre-2025 Sample Robustness
# =============================================================
cat("Table 6: Pre-2025 sample robustness...\n")

pre2025 <- readRDS("../data/pre2025_results.rds")

unlink("../tables/tab6_pre2025.tex")
etable(
  models$bartik_youth_share,
  pre2025$share,
  models$bartik_youth_level,
  pre2025$level,
  models$bartik_total_placebo,
  pre2025$total,
  tex = TRUE,
  style.tex = style.tex("aer"),
  fitstat = ~ r2 + n,
  headers = c("Youth Share", "Youth Share", "Youth Level", "Youth Level", "Total Emp.", "Total Emp."),
  title = "Robustness: Excluding the February 2025 Reform",
  label = "tab:pre2025",
  adjustbox = TRUE,
  notes = c("Standard errors clustered at sector level in parentheses.",
            "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.",
            "Odd columns: full sample (2015Q1--2025Q3).",
            "Even columns: pre-2025 sample (2015Q1--2024Q4), excluding February 2025 redesign."),
  file = "../tables/tab6_pre2025.tex"
)

# =============================================================
# Table 7: Sector-Specific Linear Trends
# =============================================================
cat("Table 7: Sector-specific linear trends...\n")

trends <- readRDS("../data/sector_trends_results.rds")

unlink("../tables/tab7_trends.tex")
etable(
  models$bartik_youth_share,
  trends$share,
  models$bartik_youth_level,
  trends$level,
  models$bartik_total_placebo,
  trends$total,
  tex = TRUE,
  style.tex = style.tex("aer"),
  fitstat = ~ r2 + n,
  headers = c("Youth Share", "Youth Share", "Youth Level", "Youth Level", "Total Emp.", "Total Emp."),
  title = "Robustness: Controlling for Sector-Specific Linear Trends",
  label = "tab:trends",
  adjustbox = TRUE,
  notes = c("Standard errors clustered at sector level in parentheses.",
            "* p$<$0.10, ** p$<$0.05, *** p$<$0.01.",
            "Odd columns: baseline specification with sector and year-quarter FE.",
            "Even columns: add sector-specific linear time trends to absorb differential sector growth."),
  file = "../tables/tab7_trends.tex"
)

cat("\n=== All tables generated ===\n")
cat("Tables saved to ../tables/\n")
