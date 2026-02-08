## 06_tables.R — Generate LaTeX tables
## Paper 109: Must-Access PDMP Mandates and Employment

library(tidyverse)
library(fixest)
library(data.table)

data_dir <- "../data"
tab_dir <- "../tables"
dir.create(tab_dir, showWarnings = FALSE)

panel <- readRDS(file.path(data_dir, "analysis_panel.rds"))
pdmp <- readRDS(file.path(data_dir, "pdmp_mandate_dates.rds"))

###############################################################################
## Table 1: Summary Statistics
###############################################################################

cat("=== Table 1: Summary Statistics ===\n")

summ <- panel %>%
  mutate(Group = ifelse(ever_treated == 1, "Ever-Treated", "Never-Treated")) %>%
  group_by(Group) %>%
  summarise(
    `N (state-years)` = n(),
    `States` = n_distinct(statefip),
    `Mean Employment (thousands)` = sprintf("%.0f", mean(employment_march / 1000, na.rm = TRUE)),
    `SD Employment (thousands)` = sprintf("%.0f", sd(employment_march / 1000, na.rm = TRUE)),
    `Mean Log Employment` = sprintf("%.3f", mean(log_emp, na.rm = TRUE)),
    `SD Log Employment` = sprintf("%.3f", sd(log_emp, na.rm = TRUE)),
    `Mean Unemployment Rate` = sprintf("%.2f", mean(unemp_rate_march, na.rm = TRUE)),
    `SD Unemployment Rate` = sprintf("%.2f", sd(unemp_rate_march, na.rm = TRUE)),
    `Mean Employment Rate` = sprintf("%.2f", mean(emp_rate, na.rm = TRUE)),
    .groups = "drop"
  )

# Write LaTeX
sink(file.path(tab_dir, "summary_stats.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Summary Statistics by Treatment Status}\n")
cat("\\label{tab:summary}\n")
cat("\\begin{tabular}{lcc}\n")
cat("\\toprule\n")
cat(" & Ever-Treated & Never-Treated \\\\\n")
cat("\\midrule\n")

vars <- c("N (state-years)", "States", "Mean Employment (thousands)",
          "SD Employment (thousands)", "Mean Log Employment",
          "SD Log Employment", "Mean Unemployment Rate",
          "SD Unemployment Rate", "Mean Employment Rate")

for (v in vars) {
  et <- summ %>% filter(Group == "Ever-Treated") %>% pull(!!sym(v))
  nt <- summ %>% filter(Group == "Never-Treated") %>% pull(!!sym(v))
  cat(sprintf("%s & %s & %s \\\\\n", v, et, nt))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Data from BLS Local Area Unemployment Statistics, 2007--2023.\n")
cat("Ever-treated states adopted must-access PDMP mandates between 2012 and 2021.\n")
cat("Employment and unemployment figures are from the March monthly release.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()
cat("Saved tables/summary_stats.tex\n")

###############################################################################
## Table 2: PDMP Mandate Adoption Dates
###############################################################################

cat("\n=== Table 2: Adoption Dates ===\n")

## Build adoption table from panel (includes Wyoming)
adopt_from_panel <- panel %>%
  filter(ever_treated == 1) %>%
  distinct(statefip, state_abbr, first_treat) %>%
  arrange(first_treat, state_abbr)

## Merge with pdmp dates where available
adopt_table <- adopt_from_panel %>%
  left_join(pdmp %>% select(state_abbr, mandate_effective_date, mandate_year_full_exposure),
            by = "state_abbr") %>%
  mutate(
    # For WY: use known date if not in pdmp file
    mandate_effective_date = ifelse(is.na(mandate_effective_date) & state_abbr == "WY",
                                   "2020-07-01", mandate_effective_date),
    mandate_year_full_exposure = ifelse(is.na(mandate_year_full_exposure),
                                       first_treat, mandate_year_full_exposure)
  ) %>%
  arrange(mandate_effective_date) %>%
  mutate(
    `State` = state_abbr,
    `Effective Date` = mandate_effective_date,
    `Full-Exposure Year` = mandate_year_full_exposure
  ) %>%
  select(`State`, `Effective Date`, `Full-Exposure Year`)

sink(file.path(tab_dir, "adoption_dates.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Must-Access PDMP Mandate Adoption Dates}\n")
cat("\\label{tab:adoption}\n")
cat("\\small\n")
cat("\\begin{tabular}{llc}\n")
cat("\\toprule\n")
cat("State & Effective Date & Full-Exposure Year \\\\\n")
cat("\\midrule\n")

for (i in seq_len(nrow(adopt_table))) {
  row <- adopt_table[i, ]
  cat(sprintf("%s & %s & %d \\\\\n", row$State, row$`Effective Date`, row$`Full-Exposure Year`))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Dates compiled from PDAPS, Horwitz et al. (2018),\n")
cat("Buchmueller and Carey (2018), and NCSL. Full-exposure year is the first\n")
cat("calendar year in which the mandate was in effect for the entire year.\n")
nt_states <- panel %>%
  filter(ever_treated == 0) %>%
  distinct(state_abbr) %>%
  arrange(state_abbr) %>%
  pull(state_abbr) %>%
  paste(collapse = ", ")
cat(sprintf("Never-treated states (as of 2023): %s.\n", nt_states))
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()
cat("Saved tables/adoption_dates.tex\n")

###############################################################################
## Table 3: Main Results
###############################################################################

cat("\n=== Table 3: Main Results ===\n")

att_overall <- readRDS(file.path(data_dir, "att_overall_log_emp.rds"))
att_overall_ur <- readRDS(file.path(data_dir, "att_overall_unemp.rds"))
att_overall_er <- readRDS(file.path(data_dir, "att_overall_emp_rate.rds"))
twfe_log <- readRDS(file.path(data_dir, "twfe_log_emp.rds"))
twfe_ur <- readRDS(file.path(data_dir, "twfe_unemp.rds"))
twfe_er <- readRDS(file.path(data_dir, "twfe_emp_rate.rds"))
twfe_ctrl <- readRDS(file.path(data_dir, "twfe_controls.rds"))

stars_fn <- function(p) {
  if (p < 0.01) return("***")
  if (p < 0.05) return("**")
  if (p < 0.1) return("*")
  return("")
}

p_fn <- function(est, se) 2 * pnorm(-abs(est / se))

sink(file.path(tab_dir, "main_results.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Effect of Must-Access PDMP Mandates on State Employment Outcomes}\n")
cat("\\label{tab:main}\n")
cat("\\begin{tabular}{lcccc}\n")
cat("\\toprule\n")
cat(" & \\multicolumn{2}{c}{Callaway-Sant'Anna} & \\multicolumn{2}{c}{TWFE} \\\\\n")
cat("\\cmidrule(lr){2-3} \\cmidrule(lr){4-5}\n")
cat("Outcome & ATT & SE & Coef & SE \\\\\n")
cat("\\midrule\n")

# Row 1: Log Employment
cs_est <- att_overall$overall.att
cs_se <- att_overall$overall.se
cs_p <- p_fn(cs_est, cs_se)
tw_est <- coef(twfe_log)["treated"]
tw_se <- se(twfe_log)["treated"]
tw_p <- pvalue(twfe_log)["treated"]

cat(sprintf("Log(Employment) & %.4f%s & (%.4f) & %.4f%s & (%.4f) \\\\\n",
            cs_est, stars_fn(cs_p), cs_se,
            tw_est, stars_fn(tw_p), tw_se))

# Row 2: Unemployment Rate
cs_est2 <- att_overall_ur$overall.att
cs_se2 <- att_overall_ur$overall.se
cs_p2 <- p_fn(cs_est2, cs_se2)
tw_est2 <- coef(twfe_ur)["treated"]
tw_se2 <- se(twfe_ur)["treated"]
tw_p2 <- pvalue(twfe_ur)["treated"]

cat(sprintf("Unemployment Rate & %.4f%s & (%.4f) & %.4f%s & (%.4f) \\\\\n",
            cs_est2, stars_fn(cs_p2), cs_se2,
            tw_est2, stars_fn(tw_p2), tw_se2))

# Row 3: Employment Rate
cs_est3 <- att_overall_er$overall.att
cs_se3 <- att_overall_er$overall.se
cs_p3 <- p_fn(cs_est3, cs_se3)
tw_est3 <- coef(twfe_er)["treated"]
tw_se3 <- se(twfe_er)["treated"]
tw_p3 <- pvalue(twfe_er)["treated"]

cat(sprintf("Employment Rate & %.4f%s & (%.4f) & %.4f%s & (%.4f) \\\\\n",
            cs_est3, stars_fn(cs_p3), cs_se3,
            tw_est3, stars_fn(tw_p3), tw_se3))

cat("\\midrule\n")
cat(sprintf("State FE & \\checkmark & & \\checkmark & \\\\\n"))
cat(sprintf("Year FE & \\checkmark & & \\checkmark & \\\\\n"))
cat(sprintf("N (state-years) & %d & & %d & \\\\\n", nrow(panel), nrow(panel)))
cat(sprintf("States & %d & & %d & \\\\\n",
            n_distinct(panel$statefip), n_distinct(panel$statefip)))
cat(sprintf("Treated states & %d & & %d & \\\\\n",
            n_distinct(panel$statefip[panel$ever_treated == 1]),
            n_distinct(panel$statefip[panel$ever_treated == 1])))
cat("Control group & Never-treated & & All & \\\\\n")
cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Columns (1)--(2) report Callaway and Sant'Anna (2021) doubly-robust ATT estimates\n")
cat("using never-treated states as the comparison group. Columns (3)--(4) report standard TWFE estimates with\n")
cat("state and year fixed effects. Standard errors clustered at the state level in parentheses.\n")
cat("* $p < 0.1$, ** $p < 0.05$, *** $p < 0.01$.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()
cat("Saved tables/main_results.tex\n")

###############################################################################
## Table 4: Group-level ATT
###############################################################################

cat("\n=== Table 4: Group ATT ===\n")

att_group <- readRDS(file.path(data_dir, "att_group_log_emp.rds"))

sink(file.path(tab_dir, "group_att.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Group-Level ATT Estimates by Adoption Cohort}\n")
cat("\\label{tab:group_att}\n")
cat("\\begin{tabular}{lccccc}\n")
cat("\\toprule\n")
cat("Cohort & ATT & SE & 95\\% CI & States \\\\\n")
cat("\\midrule\n")

groups <- att_group$egt
ests <- att_group$att.egt
ses <- att_group$se.egt

cohort_sizes <- panel %>%
  filter(first_treat > 0) %>%
  distinct(statefip, first_treat) %>%
  count(first_treat) %>%
  deframe()

for (i in seq_along(groups)) {
  g <- groups[i]
  e <- ests[i]
  s <- ses[i]
  p <- 2 * pnorm(-abs(e / s))
  ci_lo <- e - 1.96 * s
  ci_hi <- e + 1.96 * s
  n_st <- ifelse(as.character(g) %in% names(cohort_sizes),
                 cohort_sizes[as.character(g)], NA)
  cat(sprintf("%d & %.4f%s & (%.4f) & [%.4f, %.4f] & %s \\\\\n",
              g, e, stars_fn(p), s, ci_lo, ci_hi,
              ifelse(is.na(n_st), "---", as.character(n_st))))
}

cat("\\midrule\n")
cat(sprintf("Overall & %.4f%s & (%.4f) & [%.4f, %.4f] & %d \\\\\n",
            att_group$overall.att,
            stars_fn(p_fn(att_group$overall.att, att_group$overall.se)),
            att_group$overall.se,
            att_group$overall.att - 1.96 * att_group$overall.se,
            att_group$overall.att + 1.96 * att_group$overall.se,
            n_distinct(panel$statefip[panel$ever_treated == 1])))

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}[flushleft]\n")
cat("\\small\n")
cat("\\item \\textit{Notes:} Callaway and Sant'Anna (2021) group-level ATT estimates.\n")
cat("Cohort defined by the first full-exposure year of the must-access PDMP mandate.\n")
cat("Doubly-robust estimation with never-treated states as control.\n")
cat("Standard errors from multiplier bootstrap (1,000 iterations).\n")
cat("* $p < 0.1$, ** $p < 0.05$, *** $p < 0.01$.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()
cat("Saved tables/group_att.tex\n")

cat("\n=== All tables generated ===\n")
