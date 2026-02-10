## =============================================================================
## 06_tables.R — Publication-quality LaTeX tables
## The Innovation Cost of Privacy
## =============================================================================

source(here::here("output", "apep_0214", "v1", "code", "00_packages.R"))

data_dir <- file.path(base_dir, "data")
tab_dir  <- file.path(base_dir, "tables")
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

# ==== Load results ====
main_results <- readRDS(file.path(data_dir, "main_results.rds"))
robustness   <- readRDS(file.path(data_dir, "robustness_results.rds"))
panel_info   <- read_csv(file.path(data_dir, "panel_information.csv"), show_col_types = FALSE)
panel_bfs    <- read_csv(file.path(data_dir, "panel_bfs.csv"), show_col_types = FALSE)


# ==== Table 1: Summary Statistics ====
cat("Creating Table 1: Summary statistics...\n")

pre_info <- panel_info %>% filter(year <= 2019)
pre_bfs <- panel_bfs %>% filter(year <= 2019)

treated_info <- pre_info %>% filter(first_treat > 0)
control_info <- pre_info %>% filter(first_treat == 0)

make_summ <- function(df, vars, labels) {
  sapply(seq_along(vars), function(i) {
    x <- df[[vars[i]]]
    x <- x[!is.na(x)]
    sprintf("%.1f & %.1f & %.1f & %.1f", mean(x), sd(x), min(x), max(x))
  })
}

# LaTeX table
tab1_lines <- c(
  "\\begin{table}[H]",
  "\\centering",
  "\\caption{Summary Statistics: Information Sector (NAICS 51), Pre-Treatment Period (2015--2019)}",
  "\\label{tab:summary}",
  "\\begin{threeparttable}",
  "\\begin{tabular}{lrrrr}",
  "\\toprule",
  " & Mean & Std.\\ Dev. & Min & Max \\\\",
  "\\midrule",
  "\\multicolumn{5}{l}{\\textit{Panel A: Treated States (N = %d state-quarters)}} \\\\",
  sprintf("Avg.\\ Quarterly Employment & %s \\\\",
          sprintf("%.0f & %.0f & %.0f & %.0f",
                  mean(treated_info$avg_emp, na.rm=T), sd(treated_info$avg_emp, na.rm=T),
                  min(treated_info$avg_emp, na.rm=T), max(treated_info$avg_emp, na.rm=T))),
  sprintf("Quarterly Establishments & %s \\\\",
          sprintf("%.0f & %.0f & %.0f & %.0f",
                  mean(treated_info$qtrly_estabs, na.rm=T), sd(treated_info$qtrly_estabs, na.rm=T),
                  min(treated_info$qtrly_estabs, na.rm=T), max(treated_info$qtrly_estabs, na.rm=T))),
  sprintf("Avg.\\ Weekly Wage (\\$) & %s \\\\",
          sprintf("%.0f & %.0f & %.0f & %.0f",
                  mean(treated_info$avg_wkly_wage, na.rm=T), sd(treated_info$avg_wkly_wage, na.rm=T),
                  min(treated_info$avg_wkly_wage, na.rm=T), max(treated_info$avg_wkly_wage, na.rm=T))),
  "\\addlinespace",
  sprintf("\\multicolumn{5}{l}{\\textit{Panel B: Control States (N = %d state-quarters)}} \\\\",
          nrow(control_info)),
  sprintf("Avg.\\ Quarterly Employment & %s \\\\",
          sprintf("%.0f & %.0f & %.0f & %.0f",
                  mean(control_info$avg_emp, na.rm=T), sd(control_info$avg_emp, na.rm=T),
                  min(control_info$avg_emp, na.rm=T), max(control_info$avg_emp, na.rm=T))),
  sprintf("Quarterly Establishments & %s \\\\",
          sprintf("%.0f & %.0f & %.0f & %.0f",
                  mean(control_info$qtrly_estabs, na.rm=T), sd(control_info$qtrly_estabs, na.rm=T),
                  min(control_info$qtrly_estabs, na.rm=T), max(control_info$qtrly_estabs, na.rm=T))),
  sprintf("Avg.\\ Weekly Wage (\\$) & %s \\\\",
          sprintf("%.0f & %.0f & %.0f & %.0f",
                  mean(control_info$avg_wkly_wage, na.rm=T), sd(control_info$avg_wkly_wage, na.rm=T),
                  min(control_info$avg_wkly_wage, na.rm=T), max(control_info$avg_wkly_wage, na.rm=T))),
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  sprintf("\\item Notes: Pre-treatment period covers 2015Q1--2019Q4. Treated states (N=%d) are those with comprehensive data privacy laws effective by 2025Q1 and at least one post-treatment quarter in the QCEW data (through 2025Q2). Control states (N=%d) include never-treated states and states with laws effective after 2025Q2. Employment and establishments from BLS Quarterly Census of Employment and Wages (QCEW), private ownership, NAICS 51 (Information).",
          n_distinct(treated_info$state_abbr), n_distinct(control_info$state_abbr)),
  "\\end{tablenotes}",
  "\\end{threeparttable}",
  "\\end{table}"
)

# Fix Panel A count
tab1_lines[10] <- sprintf("\\multicolumn{5}{l}{\\textit{Panel A: Treated States (N = %d state-quarters)}} \\\\",
                           nrow(treated_info))

writeLines(tab1_lines, file.path(tab_dir, "tab1_summary.tex"))
cat("  Saved tab1_summary.tex\n")


# ==== Table 2: Main Results ====
cat("Creating Table 2: Main results...\n")

panel_soft <- read_csv(file.path(data_dir, "panel_software.csv"), show_col_types = FALSE)

stars <- function(p) {
  if (is.na(p)) return("")
  if (p < 0.01) return("$^{***}$")
  if (p < 0.05) return("$^{**}$")
  if (p < 0.10) return("$^{*}$")
  return("")
}

get_pval <- function(att, se) {
  if (is.na(att) || is.na(se) || se == 0) return(NA)
  2 * pnorm(-abs(att / se))
}

# Column order: (1) Soft Emp, (2) Info Estab, (3) Bus Apps
cs_results <- list(
  list(name = "Log Emp. (5112)", att = main_results$att_soft),
  list(name = "Log Estab. (51)", att = main_results$att_estabs),
  list(name = "Log Bus. Apps", att = main_results$att_bfs)
)

twfe_models <- list(
  main_results$twfe_soft,
  main_results$twfe_estabs,
  main_results$twfe_bfs
)

tab2_lines <- c(
  "\\begin{table}[H]",
  "\\centering",
  "\\caption{Main Results: Effect of State Data Privacy Laws on the Technology Sector}",
  "\\label{tab:main}",
  "\\begin{threeparttable}",
  "\\begin{tabular}{lccc}",
  "\\toprule",
  " & (1) & (2) & (3) \\\\",
  " & Log Emp. & Log Estab. & Log Bus.\\ Apps. \\\\",
  " & \\small(NAICS 5112) & \\small(NAICS 51) & \\small(BFS, CA only) \\\\",
  "\\midrule",
  "\\multicolumn{4}{l}{\\textit{Panel A: Callaway-Sant'Anna DiD}} \\\\"
)

# CS-DiD row
cs_atts <- sapply(cs_results, function(r) r$att$overall.att)
cs_ses <- sapply(cs_results, function(r) r$att$overall.se)
cs_pvals <- mapply(get_pval, cs_atts, cs_ses)
cs_stars_vec <- sapply(cs_pvals, stars)

tab2_lines <- c(tab2_lines,
  sprintf("ATT & %.4f%s & %.4f%s & %.4f%s \\\\",
          cs_atts[1], cs_stars_vec[1], cs_atts[2], cs_stars_vec[2],
          cs_atts[3], cs_stars_vec[3]),
  sprintf(" & (%.4f) & (%.4f) & (%.4f) \\\\",
          cs_ses[1], cs_ses[2], cs_ses[3]),
  "\\addlinespace",
  "\\multicolumn{4}{l}{\\textit{Panel B: Two-Way Fixed Effects}} \\\\"
)

# TWFE row
twfe_coefs <- sapply(twfe_models, function(m) coef(m)["treated"])
twfe_ses_v <- sapply(twfe_models, function(m) fixest::se(m)["treated"])
twfe_pvals <- sapply(twfe_models, function(m) fixest::pvalue(m)["treated"])
twfe_stars_vec <- sapply(twfe_pvals, stars)

tab2_lines <- c(tab2_lines,
  sprintf("Treated & %.4f%s & %.4f%s & %.4f%s \\\\",
          twfe_coefs[1], twfe_stars_vec[1], twfe_coefs[2], twfe_stars_vec[2],
          twfe_coefs[3], twfe_stars_vec[3]),
  sprintf(" & (%.4f) & (%.4f) & (%.4f) \\\\",
          twfe_ses_v[1], twfe_ses_v[2], twfe_ses_v[3]),
  "\\addlinespace",
  "\\midrule",
  sprintf("States & %d & %d & %d \\\\",
          n_distinct(panel_soft$state_id), n_distinct(panel_info$state_id),
          n_distinct(panel_bfs$state_id)),
  sprintf("State-Quarters & %s & %s & %s \\\\",
          format(sum(!is.na(panel_soft$log_emp)), big.mark=","),
          format(sum(!is.na(panel_info$log_estabs)), big.mark=","),
          format(sum(!is.na(panel_bfs$log_apps)), big.mark=",")),
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item Notes: Panel A reports Callaway and Sant'Anna (2021) aggregate ATT with doubly robust estimation and 1,000 bootstrap iterations. Panel B reports TWFE coefficients with state and period fixed effects. Standard errors clustered at the state level in parentheses. Column (1) uses NAICS 5112 (Software Publishers); column (2) uses NAICS 51 (Information sector). QCEW data: 2015Q1--2025Q2, 13 treated states with post-treatment data. BFS column (3): 2015Q1--2020Q4 with California as the only treated state during this window. Wage effects are not tabulated; estimates are near zero with wide confidence intervals. * p$<$0.10, ** p$<$0.05, *** p$<$0.01.",
  "\\end{tablenotes}",
  "\\end{threeparttable}",
  "\\end{table}"
)

writeLines(tab2_lines, file.path(tab_dir, "tab2_main_results.tex"))
cat("  Saved tab2_main_results.tex\n")


# ==== Table 3: Robustness ====
cat("Creating Table 3: Robustness...\n")

rob_specs <- list()

# Software Publishers (primary)
if (!is.null(robustness$cs_soft)) {
  rob_specs[["Software Publishers (5112)"]] <- list(
    att = robustness$cs_soft$att$overall.att,
    se = robustness$cs_soft$att$overall.se,
    note = "Primary specification"
  )
}

# Broad Info (NAICS 51)
rob_specs[["Broad Info (NAICS 51)"]] <- list(
  att = main_results$att_emp$overall.att,
  se = main_results$att_emp$overall.se,
  note = "Broad sector; underpowered$^\\dag$"
)

# Placebos
if (!is.null(robustness$placebo_health)) {
  rob_specs[["Placebo: Healthcare"]] <- list(
    att = robustness$placebo_health$att$overall.att,
    se = robustness$placebo_health$att$overall.se,
    note = "NAICS 62"
  )
}
if (!is.null(robustness$placebo_constr)) {
  rob_specs[["Placebo: Construction"]] <- list(
    att = robustness$placebo_constr$att$overall.att,
    se = robustness$placebo_constr$att$overall.se,
    note = "NAICS 23"
  )
}

# Not-yet-treated controls from reviewer robustness
rev_rob_file <- file.path(data_dir, "reviewer_robustness.rds")
if (file.exists(rev_rob_file)) {
  rev_rob <- readRDS(rev_rob_file)
  if (!is.null(rev_rob$att_nyt)) {
    rob_specs[["Not-Yet-Treated Controls"]] <- list(
      att = rev_rob$att_nyt$overall.att,
      se = rev_rob$att_nyt$overall.se,
      note = "Alternative control group"
    )
  }
}

tab3_lines <- c(
  "\\begin{table}[H]",
  "\\centering",
  "\\caption{Robustness and Placebo Tests: Log Employment ATT}",
  "\\label{tab:robustness}",
  "\\begin{threeparttable}",
  "\\begin{tabular}{lccc}",
  "\\toprule",
  "Specification & ATT & SE & Note \\\\",
  "\\midrule"
)

for (nm in names(rob_specs)) {
  r <- rob_specs[[nm]]
  p <- get_pval(r$att, r$se)
  s <- stars(p)
  tab3_lines <- c(tab3_lines,
    sprintf("%s & %.4f%s & (%.4f) & %s \\\\", nm, r$att, s, r$se, r$note)
  )
}

# RI p-value row
tab3_lines <- c(tab3_lines,
  "\\addlinespace",
  sprintf("Randomization Inference & \\multicolumn{3}{c}{p-value = %.3f (%d permutations)} \\\\",
          robustness$ri_pvalue, length(robustness$ri_distribution)),
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item Notes: All specifications use Callaway-Sant'Anna (2021) with doubly robust estimation. Unless noted, the control group is never-treated states. QCEW data: 2015Q1--2025Q2, 52 units, 13 treated states with post-treatment data. All rows report log employment ATT for Software Publishers (NAICS 5112) unless otherwise noted. Placebo industries should show null effects if privacy laws specifically affect the technology sector. Not-yet-treated controls expand the comparison group to include states that adopted laws later. Randomization inference permutes treatment assignment 500 times across the Software Publishers specification. $^\\dag$The broad NAICS 51 specification has SE $\\gg$ $|$ATT$|$ because enormous cross-state heterogeneity in Information sector employment produces wide confidence intervals; this is a power limitation, not a specification error. * p$<$0.10, ** p$<$0.05, *** p$<$0.01.",
  "\\end{tablenotes}",
  "\\end{threeparttable}",
  "\\end{table}"
)

writeLines(tab3_lines, file.path(tab_dir, "tab3_robustness.tex"))
cat("  Saved tab3_robustness.tex\n")


# ==== Table 4: Treatment Assignment ====
cat("Creating Table 4: Treatment assignment...\n")

privacy_laws_full <- tribble(
  ~state_abbr, ~law_name, ~effective_date,
  "CA", "CCPA", "January 1, 2020",
  "VA", "VCDPA", "January 1, 2023",
  "CO", "CPA", "July 1, 2023",
  "CT", "CTDPA", "July 1, 2023",
  "UT", "UCPA", "December 31, 2023",
  "TX", "TDPSA", "July 1, 2024",
  "OR", "OCPA", "July 1, 2024",
  "MT", "MTCDPA", "October 1, 2024",
  "DE", "DPDPA", "January 1, 2025",
  "IA", "ICDPA", "January 1, 2025",
  "NE", "NDPA", "January 1, 2025",
  "NH", "NHPA", "January 1, 2025",
  "NJ", "NJDPA", "January 15, 2025",
  "TN", "TIPA", "July 1, 2025",
  "MN", "MCDPA", "July 31, 2025",
  "MD", "MODPA", "October 1, 2025",
  "IN", "INCDPA", "January 1, 2026",
  "KY", "KCDPA", "January 1, 2026",
  "RI", "RIDTPPA", "January 1, 2026"
)

tab4_lines <- c(
  "\\begin{table}[H]",
  "\\centering",
  "\\caption{State Comprehensive Data Privacy Laws: Treatment Assignment}",
  "\\label{tab:treatment}",
  "\\begin{threeparttable}",
  "\\begin{tabular}{llll}",
  "\\toprule",
  "State & Law & Effective Date & Treatment Cohort \\\\",
  "\\midrule"
)

cohort_map <- c(
  "CA" = "2020Q1", "VA" = "2023Q1", "CO" = "2023Q3", "CT" = "2023Q3",
  "UT" = "2024Q1", "TX" = "2024Q3", "OR" = "2024Q3", "MT" = "2024Q4",
  "DE" = "2025Q1", "IA" = "2025Q1", "NE" = "2025Q1", "NH" = "2025Q1",
  "NJ" = "2025Q1", "TN" = "2025Q3", "MN" = "2025Q3", "MD" = "2025Q4",
  "IN" = "2026Q1", "KY" = "2026Q1", "RI" = "2026Q1"
)

# Treated states (first 13 rows)
for (i in 1:13) {
  r <- privacy_laws_full[i, ]
  tab4_lines <- c(tab4_lines,
    sprintf("%s & %s & %s & %s \\\\",
            r$state_abbr, r$law_name, r$effective_date, cohort_map[r$state_abbr])
  )
}

# Not-yet-treated section
tab4_lines <- c(tab4_lines,
  "\\midrule",
  "\\multicolumn{4}{l}{\\textit{Not-yet-treated (zero post-treatment quarters in QCEW data ending 2025Q2)}} \\\\"
)

for (i in 14:nrow(privacy_laws_full)) {
  r <- privacy_laws_full[i, ]
  tab4_lines <- c(tab4_lines,
    sprintf("%s & %s & %s & %s \\\\",
            r$state_abbr, r$law_name, r$effective_date, cohort_map[r$state_abbr])
  )
}

tab4_lines <- c(tab4_lines,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item Notes: Treatment quarter is the first full calendar quarter in which the law is in effect; when a law takes effect on the first day of a quarter, that quarter is the treatment quarter. The top panel lists 13 states included as treated in the primary specification (with at least one post-treatment quarter in the QCEW data ending 2025Q2). The bottom panel lists 6 states classified as not-yet-treated because their treatment quarters fall at or after the end of the QCEW sample. Florida is excluded from the primary specification due to its unique \\$1 billion revenue threshold. Sources: IAPP State Privacy Legislation Tracker, individual state statutes.",
  "\\end{tablenotes}",
  "\\end{threeparttable}",
  "\\end{table}"
)

writeLines(tab4_lines, file.path(tab_dir, "tab4_treatment.tex"))
cat("  Saved tab4_treatment.tex\n")


cat("\n=== All tables complete ===\n")
