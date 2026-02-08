###############################################################################
# 06_tables.R
# Paper 112: EERS and Residential Electricity Consumption
# Generate all LaTeX tables
###############################################################################

source("00_packages.R")

data_dir <- "../data/"
tab_dir  <- "../tables/"
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

panel <- readRDS(paste0(data_dir, "panel_clean.rds"))

###############################################################################
# Table 1: Summary Statistics
###############################################################################

cat("Generating Table 1: Summary Statistics\n")

# Overall summary
sum_stats <- panel %>%
  filter(!is.na(res_elec_pc)) %>%
  summarise(
    `N (state-years)` = n(),
    `States` = n_distinct(state_abbr),
    `Years` = paste0(min(year), "--", max(year)),
    `Mean Res. Elec. PC` = round(mean(res_elec_pc, na.rm = TRUE), 4),
    `SD Res. Elec. PC` = round(sd(res_elec_pc, na.rm = TRUE), 4),
    `Mean Res. Price` = round(mean(res_price, na.rm = TRUE), 2),
    `SD Res. Price` = round(sd(res_price, na.rm = TRUE), 2)
  )

# By treatment group
sum_by_group <- panel %>%
  filter(!is.na(res_elec_pc)) %>%
  mutate(group = ifelse(treated == 1, "EERS States", "Non-EERS States")) %>%
  group_by(group) %>%
  summarise(
    N = n(),
    States = n_distinct(state_abbr),
    `Mean Res. Elec. PC` = round(mean(res_elec_pc, na.rm = TRUE), 4),
    `SD` = round(sd(res_elec_pc, na.rm = TRUE), 4),
    `Mean Price` = round(mean(res_price, na.rm = TRUE), 2),
    `Price SD` = round(sd(res_price, na.rm = TRUE), 2),
    `Mean Pop (M)` = round(mean(population / 1e6, na.rm = TRUE), 2),
    `Pop SD (M)` = round(sd(population / 1e6, na.rm = TRUE), 2),
    .groups = "drop"
  )

# Pre-treatment balance (for states with EERS, use pre-treatment years only)
pre_balance <- panel %>%
  filter(!is.na(res_elec_pc)) %>%
  mutate(
    group = ifelse(treated == 1, "EERS States", "Non-EERS States"),
    pre_treat = ifelse(treated == 1, year < eers_year, TRUE)
  ) %>%
  filter(pre_treat) %>%
  group_by(group) %>%
  summarise(
    N = n(),
    States = n_distinct(state_abbr),
    `Mean Res. Elec. PC` = round(mean(res_elec_pc, na.rm = TRUE), 4),
    `SD` = round(sd(res_elec_pc, na.rm = TRUE), 4),
    `Mean Price` = round(mean(res_price, na.rm = TRUE), 2),
    `Price SD` = round(sd(res_price, na.rm = TRUE), 2),
    `Mean Pop (M)` = round(mean(population / 1e6, na.rm = TRUE), 2),
    `Pop SD (M)` = round(sd(population / 1e6, na.rm = TRUE), 2),
    .groups = "drop"
  )

# Write LaTeX table
tab1_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Summary Statistics}\n",
  "\\label{tab:summary_stats}\n",
  "\\begin{tabular}{lccccc}\n",
  "\\toprule\n",
  " & \\multicolumn{2}{c}{Full Sample} & \\multicolumn{2}{c}{Pre-Treatment} \\\\\n",
  "\\cmidrule(lr){2-3} \\cmidrule(lr){4-5}\n",
  " & EERS States & Non-EERS & EERS States & Non-EERS \\\\\n",
  "\\midrule\n"
)

tab1_tex <- paste0(tab1_tex,
  "N (state-years) & ", sum_by_group$N[sum_by_group$group == "EERS States"],
  " & ", sum_by_group$N[sum_by_group$group == "Non-EERS States"],
  " & ", pre_balance$N[pre_balance$group == "EERS States"],
  " & ", pre_balance$N[pre_balance$group == "Non-EERS States"], " \\\\\n",
  "States & ", sum_by_group$States[sum_by_group$group == "EERS States"],
  " & ", sum_by_group$States[sum_by_group$group == "Non-EERS States"],
  " & ", pre_balance$States[pre_balance$group == "EERS States"],
  " & ", pre_balance$States[pre_balance$group == "Non-EERS States"], " \\\\\n",
  "\\addlinespace\n",
  "\\multicolumn{5}{l}{\\textit{Panel A: Electricity Consumption}} \\\\\n",
  "\\addlinespace\n",
  "Mean Per-Capita Res. Elec. & ",
  sum_by_group$`Mean Res. Elec. PC`[sum_by_group$group == "EERS States"], " & ",
  sum_by_group$`Mean Res. Elec. PC`[sum_by_group$group == "Non-EERS States"], " & ",
  pre_balance$`Mean Res. Elec. PC`[pre_balance$group == "EERS States"], " & ",
  pre_balance$`Mean Res. Elec. PC`[pre_balance$group == "Non-EERS States"], " \\\\\n",
  "(Billion Btu) & (",
  sum_by_group$SD[sum_by_group$group == "EERS States"], ") & (",
  sum_by_group$SD[sum_by_group$group == "Non-EERS States"], ") & (",
  pre_balance$SD[pre_balance$group == "EERS States"], ") & (",
  pre_balance$SD[pre_balance$group == "Non-EERS States"], ") \\\\\n",
  "\\addlinespace\n",
  "\\multicolumn{5}{l}{\\textit{Panel B: Electricity Prices}} \\\\\n",
  "\\addlinespace\n",
  "Mean Res. Price (\\textcent/kWh) & ",
  sum_by_group$`Mean Price`[sum_by_group$group == "EERS States"], " & ",
  sum_by_group$`Mean Price`[sum_by_group$group == "Non-EERS States"], " & ",
  pre_balance$`Mean Price`[pre_balance$group == "EERS States"], " & ",
  pre_balance$`Mean Price`[pre_balance$group == "Non-EERS States"], " \\\\\n",
  " & (",
  sum_by_group$`Price SD`[sum_by_group$group == "EERS States"], ") & (",
  sum_by_group$`Price SD`[sum_by_group$group == "Non-EERS States"], ") & (",
  pre_balance$`Price SD`[pre_balance$group == "EERS States"], ") & (",
  pre_balance$`Price SD`[pre_balance$group == "Non-EERS States"], ") \\\\\n",
  "\\addlinespace\n",
  "\\multicolumn{5}{l}{\\textit{Panel C: Demographics}} \\\\\n",
  "\\addlinespace\n",
  "Mean Population (millions) & ",
  sum_by_group$`Mean Pop (M)`[sum_by_group$group == "EERS States"], " & ",
  sum_by_group$`Mean Pop (M)`[sum_by_group$group == "Non-EERS States"], " & ",
  pre_balance$`Mean Pop (M)`[pre_balance$group == "EERS States"], " & ",
  pre_balance$`Mean Pop (M)`[pre_balance$group == "Non-EERS States"], " \\\\\n",
  " & (",
  sum_by_group$`Pop SD (M)`[sum_by_group$group == "EERS States"], ") & (",
  sum_by_group$`Pop SD (M)`[sum_by_group$group == "Non-EERS States"], ") & (",
  pre_balance$`Pop SD (M)`[pre_balance$group == "EERS States"], ") & (",
  pre_balance$`Pop SD (M)`[pre_balance$group == "Non-EERS States"], ") \\\\\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}\n",
  "\\small\n",
  "\\item \\textit{Notes:} Standard deviations in parentheses. Per-capita residential electricity consumption measured in Billion Btu per person. Prices in cents per kilowatt-hour. EERS States are the 28 jurisdictions (27 states plus DC) with mandatory Energy Efficiency Resource Standards; Non-EERS states are the 23 states that never adopted mandatory EERS. Pre-treatment sample restricts EERS states to years before adoption.\n",
  "\\end{tablenotes}\n",
  "\\end{table}\n"
)

writeLines(tab1_tex, paste0(tab_dir, "tab1_summary_stats.tex"))

###############################################################################
# Table 2: Main DiD Results
###############################################################################

cat("Generating Table 2: Main Results\n")

cs_att <- readRDS(paste0(data_dir, "cs_att_simple.rds"))
twfe_main <- readRDS(paste0(data_dir, "twfe_main.rds"))
cs_nyt_att <- tryCatch(readRDS(paste0(data_dir, "cs_nyt_att.rds")), error = function(e) NULL)
cs_total_att <- tryCatch(readRDS(paste0(data_dir, "cs_total_att.rds")), error = function(e) NULL)
cs_price_att <- tryCatch(readRDS(paste0(data_dir, "cs_price_att.rds")), error = function(e) NULL)

# Build results for etable-style output
results_data <- tibble(
  spec = c("(1)", "(2)", "(3)", "(4)", "(5)"),
  method = c("CS-DiD", "TWFE", "CS-DiD", "CS-DiD", "CS-DiD"),
  outcome = c("Res. Elec. PC", "Res. Elec. PC", "Res. Elec. PC",
              "Total Elec. PC", "Res. Price"),
  control = c("Never-treated", "---", "Not-yet-treated",
              "Never-treated", "Never-treated"),
  att = c(cs_att$overall.att,
          coef(twfe_main)["post"],
          ifelse(!is.null(cs_nyt_att), cs_nyt_att$overall.att, NA),
          ifelse(!is.null(cs_total_att), cs_total_att$overall.att, NA),
          ifelse(!is.null(cs_price_att), cs_price_att$overall.att, NA)),
  se = c(cs_att$overall.se,
         se(twfe_main)["post"],
         ifelse(!is.null(cs_nyt_att), cs_nyt_att$overall.se, NA),
         ifelse(!is.null(cs_total_att), cs_total_att$overall.se, NA),
         ifelse(!is.null(cs_price_att), cs_price_att$overall.se, NA))
) %>%
  mutate(
    stars = case_when(
      abs(att / se) > 2.576 ~ "***",
      abs(att / se) > 1.96 ~ "**",
      abs(att / se) > 1.645 ~ "*",
      TRUE ~ ""
    ),
    att_str = paste0(formatC(att, format = "f", digits = 4), stars),
    se_str = paste0("(", formatC(se, format = "f", digits = 4), ")"),
    ci_str = paste0("[", formatC(att - 1.96*se, format = "f", digits = 4),
                    ", ", formatC(att + 1.96*se, format = "f", digits = 4), "]")
  )

# LaTeX table - FIXED: coefficients in columns, not stacked rows
n_obs <- nrow(panel %>% filter(!is.na(log_res_elec_pc)))
n_treated <- panel %>% filter(eers_year > 0) %>% distinct(state_abbr) %>% nrow()
n_control <- panel %>% filter(eers_year == 0) %>% distinct(state_abbr) %>% nrow()

# Get values for each column
get_val <- function(i, field) {
  if (is.na(results_data[[field]][i])) return("---")
  results_data[[field]][i]
}

tab2_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Effect of EERS on Electricity Consumption and Prices}\n",
  "\\label{tab:main_results}\n",
  "\\begin{tabular}{lccccc}\n",
  "\\toprule\n",
  " & (1) & (2) & (3) & (4) & (5) \\\\\n",
  "\\midrule\n",
  "Outcome: & \\multicolumn{3}{c}{Log Res. Elec. PC} & Log Total PC & Log Price \\\\\n",
  "\\cmidrule(lr){2-4} \\cmidrule(lr){5-5} \\cmidrule(lr){6-6}\n",
  "\\addlinespace\n",
  # Coefficient row
  "EERS & ", get_val(1, "att_str"), " & ", get_val(2, "att_str"), " & ",
             get_val(3, "att_str"), " & ", get_val(4, "att_str"), " & ",
             get_val(5, "att_str"), " \\\\\n",
  # SE row
  " & ", get_val(1, "se_str"), " & ", get_val(2, "se_str"), " & ",
         get_val(3, "se_str"), " & ", get_val(4, "se_str"), " & ",
         get_val(5, "se_str"), " \\\\\n",
  # CI row
  " & ", get_val(1, "ci_str"), " & ", get_val(2, "ci_str"), " & ",
         get_val(3, "ci_str"), " & ", get_val(4, "ci_str"), " & ",
         get_val(5, "ci_str"), " \\\\\n",
  "\\addlinespace\n",
  "\\midrule\n",
  "Estimator & CS-DiD & TWFE & CS-DiD & CS-DiD & CS-DiD \\\\\n",
  "Control Group & Never & --- & Not-yet & Never & Never \\\\\n",
  "State FE & \\checkmark & \\checkmark & \\checkmark & \\checkmark & \\checkmark \\\\\n",
  "Year FE & \\checkmark & \\checkmark & \\checkmark & \\checkmark & \\checkmark \\\\\n",
  "Observations & ", n_obs, " & ", n_obs, " & ", n_obs, " & ", n_obs, " & ", n_obs, " \\\\\n",
  "Treated States & ", n_treated, " & ", n_treated, " & ", n_treated, " & ", n_treated, " & ", n_treated, " \\\\\n",
  "Control States & ", n_control, " & --- & varies & ", n_control, " & ", n_control, " \\\\\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}\n",
  "\\small\n",
  "\\item \\textit{Notes:} $^{*}p<0.10$, $^{**}p<0.05$, $^{***}p<0.01$. Standard errors clustered at the state level in parentheses; 95\\% confidence intervals in brackets. CS-DiD refers to the Callaway and Sant'Anna (2021) doubly-robust estimator. Column (1) is the preferred specification using never-treated states as the comparison group. Column (2) reports conventional TWFE for comparison. Columns (3)--(5) show robustness to alternative control groups and outcome variables. All outcomes are in logs, so coefficients approximate percentage changes.\n",
  "\\end{tablenotes}\n",
  "\\end{table}\n"
)

writeLines(tab2_tex, paste0(tab_dir, "tab2_main_results.tex"))

###############################################################################
# Table 3: Adoption Cohort Details
###############################################################################

cat("Generating Table 3: Adoption Cohorts\n")

cohort_tab <- panel %>%
  filter(eers_year > 0) %>%
  distinct(state_abbr, state_name, eers_year) %>%
  arrange(eers_year, state_abbr) %>%
  group_by(eers_year) %>%
  summarise(
    n_states = n(),
    states = paste(state_abbr, collapse = ", "),
    .groups = "drop"
  )

tab3_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{EERS Adoption Cohorts}\n",
  "\\label{tab:cohorts}\n",
  "\\begin{tabular}{ccp{10cm}}\n",
  "\\toprule\n",
  "Year & States & State Abbreviations \\\\\n",
  "\\midrule\n"
)

for (i in 1:nrow(cohort_tab)) {
  tab3_tex <- paste0(tab3_tex,
    cohort_tab$eers_year[i], " & ", cohort_tab$n_states[i],
    " & ", cohort_tab$states[i], " \\\\\n")
}

tab3_tex <- paste0(tab3_tex,
  "\\midrule\n",
  "Total & ", sum(cohort_tab$n_states), " & \\\\\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}\n",
  "\\small\n",
  "\\item \\textit{Notes:} Year indicates the first year with a binding mandatory EERS. States with voluntary goals only are classified as never-treated.\n",
  "\\end{tablenotes}\n",
  "\\end{table}\n"
)

writeLines(tab3_tex, paste0(tab_dir, "tab3_cohorts.tex"))

cat("\nAll tables saved to:", tab_dir, "\n")
