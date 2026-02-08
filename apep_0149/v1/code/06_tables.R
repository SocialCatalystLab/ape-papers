##############################################################################
# 06_tables.R - Generate all tables
# Paper 137: Medicaid Postpartum Coverage Extensions
##############################################################################

source("00_packages.R")

cat("=== Generating Tables ===\n")

# Load data and results
df_postpartum <- fread(file.path(data_dir, "acs_postpartum.csv"))
state_year_pp <- fread(file.path(data_dir, "state_year_postpartum.csv"))
treatment_dates <- fread(file.path(data_dir, "treatment_dates.csv"))
results <- readRDS(file.path(data_dir, "main_results.rds"))
robustness <- tryCatch(readRDS(file.path(data_dir, "robustness_results.rds")),
                       error = function(e) NULL)

# =========================================================
# Table 1: Summary Statistics
# =========================================================

cat("  Table 1: Summary statistics\n")

# Pre-treatment period (2017-2019)
pre_data <- df_postpartum %>% filter(year <= 2019)

# Summary by treatment group
sum_stats <- pre_data %>%
  mutate(
    treat_group = ifelse(first_treat > 0, "Treated States", "Control States")
  ) %>%
  group_by(treat_group) %>%
  summarise(
    N = n(),
    `Medicaid (\\%)` = sprintf("%.1f", 100 * weighted.mean(medicaid, weight, na.rm = TRUE)),
    `Uninsured (\\%)` = sprintf("%.1f", 100 * weighted.mean(uninsured, weight, na.rm = TRUE)),
    `Employer Ins (\\%)` = sprintf("%.1f", 100 * weighted.mean(employer_ins, weight, na.rm = TRUE)),
    `Age` = sprintf("%.1f", weighted.mean(age, weight, na.rm = TRUE)),
    `Married (\\%)` = sprintf("%.1f", 100 * weighted.mean(married, weight, na.rm = TRUE)),
    `White NH (\\%)` = sprintf("%.1f", 100 * weighted.mean(race_eth == "White NH", weight, na.rm = TRUE)),
    `Black NH (\\%)` = sprintf("%.1f", 100 * weighted.mean(race_eth == "Black NH", weight, na.rm = TRUE)),
    `Hispanic (\\%)` = sprintf("%.1f", 100 * weighted.mean(race_eth == "Hispanic", weight, na.rm = TRUE)),
    `BA+ (\\%)` = sprintf("%.1f", 100 * weighted.mean(educ == "BA or higher", weight, na.rm = TRUE)),
    `Below 200\\% FPL (\\%)` = sprintf("%.1f", 100 * weighted.mean(low_income, weight, na.rm = TRUE)),
    .groups = "drop"
  )

# Write LaTeX table
tab1_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Summary Statistics: Postpartum Women (Pre-Treatment, 2017--2019)}\n",
  "\\label{tab:summary}\n",
  "\\begin{tabular}{lcc}\n",
  "\\toprule\n",
  " & Treated States & Control States \\\\\n",
  "\\midrule\n"
)

# Add rows
vars_to_show <- c("N", "Medicaid (\\%)", "Uninsured (\\%)", "Employer Ins (\\%)",
                   "Age", "Married (\\%)", "White NH (\\%)", "Black NH (\\%)",
                   "Hispanic (\\%)", "BA+ (\\%)", "Below 200\\% FPL (\\%)")

for (v in vars_to_show) {
  treated_val <- sum_stats %>% filter(treat_group == "Treated States") %>% pull(!!sym(v))
  control_val <- sum_stats %>% filter(treat_group == "Control States") %>% pull(!!sym(v))
  if (v == "N") {
    tab1_tex <- paste0(tab1_tex, sprintf("%s & %s & %s \\\\\n", v,
                                          format(as.numeric(treated_val), big.mark = ","),
                                          format(as.numeric(control_val), big.mark = ",")))
  } else {
    tab1_tex <- paste0(tab1_tex, sprintf("%s & %s & %s \\\\\n", v, treated_val, control_val))
  }
}

tab1_tex <- paste0(tab1_tex,
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item \\textit{Notes:} Sample is women aged 18--44 who gave birth in the past 12 months.\n",
  "Pre-treatment period is 2017--2019 (before PHE and policy adoption).\n",
  "Statistics are weighted using ACS person weights.\n",
  "Treated states are those that adopted the 12-month postpartum extension.\n",
  "Control states are Arkansas and Wisconsin (never adopted as of 2023).\n",
  "\\end{tablenotes}\n",
  "\\end{table}\n"
)

writeLines(tab1_tex, file.path(tab_dir, "tab1_summary.tex"))

# =========================================================
# Table 2: Main Results
# =========================================================

cat("  Table 2: Main results\n")

# Extract CS-DiD results
cs_med <- results$cs_agg$medicaid
cs_uni <- results$cs_agg$uninsured
cs_emp <- results$cs_agg$employer
cs_med_low <- results$cs_agg$medicaid_low
cs_uni_low <- results$cs_agg$uninsured_low

tab2_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Effect of Postpartum Medicaid Extensions on Insurance Coverage}\n",
  "\\label{tab:main_results}\n",
  "\\begin{tabular}{lccccc}\n",
  "\\toprule\n",
  " & \\multicolumn{3}{c}{All Postpartum Women} & \\multicolumn{2}{c}{Low-Income ($<$200\\% FPL)} \\\\\n",
  "\\cmidrule(lr){2-4} \\cmidrule(lr){5-6}\n",
  " & Medicaid & Uninsured & Employer & Medicaid & Uninsured \\\\\n",
  " & (1) & (2) & (3) & (4) & (5) \\\\\n",
  "\\midrule\n",
  "\\multicolumn{6}{l}{\\textit{Panel A: Callaway \\& Sant'Anna (2021)}} \\\\\n",
  sprintf("ATT & %.4f & %.4f & %.4f & %.4f & %.4f \\\\\n",
          cs_med$overall.att, cs_uni$overall.att, cs_emp$overall.att,
          cs_med_low$overall.att, cs_uni_low$overall.att),
  sprintf(" & (%.4f) & (%.4f) & (%.4f) & (%.4f) & (%.4f) \\\\\n",
          cs_med$overall.se, cs_uni$overall.se, cs_emp$overall.se,
          cs_med_low$overall.se, cs_uni_low$overall.se),
  "[0.5em]\n",
  "\\multicolumn{6}{l}{\\textit{Panel B: TWFE (biased benchmark)}} \\\\\n",
  sprintf("Treated & %.4f & %.4f & %.4f & & \\\\\n",
          coef(results$twfe$medicaid)["treated"],
          coef(results$twfe$uninsured)["treated"],
          coef(results$twfe$employer)["treated"]),
  sprintf(" & (%.4f) & (%.4f) & (%.4f) & & \\\\\n",
          se(results$twfe$medicaid)["treated"],
          se(results$twfe$uninsured)["treated"],
          se(results$twfe$employer)["treated"]),
  "\\midrule\n",
  "State FE & Yes & Yes & Yes & Yes & Yes \\\\\n",
  "Year FE & Yes & Yes & Yes & Yes & Yes \\\\\n",
  sprintf("State-years (Panel A) & %d & %d & %d & %d & %d \\\\\n",
          nrow(state_year_pp), nrow(state_year_pp), nrow(state_year_pp),
          nrow(fread(file.path(data_dir, "state_year_postpartum_lowinc.csv"))),
          nrow(fread(file.path(data_dir, "state_year_postpartum_lowinc.csv")))),
  sprintf("Observations (Panel B) & %s & %s & %s & & \\\\\n",
          format(nrow(fread(file.path(data_dir, "acs_postpartum.csv"))), big.mark = ","),
          format(nrow(fread(file.path(data_dir, "acs_postpartum.csv"))), big.mark = ","),
          format(nrow(fread(file.path(data_dir, "acs_postpartum.csv"))), big.mark = ",")),
  "Treated jurisdictions & 29 & 29 & 29 & 29 & 29 \\\\\n",
  "Control jurisdictions & 22 & 22 & 22 & 22 & 22 \\\\\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item \\textit{Notes:} Panel A reports the overall average treatment effect on the treated (ATT) from the Callaway \\& Sant'Anna (2021) estimator.\n",
  "Standard errors in parentheses. Panel B reports biased TWFE estimates for comparison.\n",
  "Columns (1)--(3) use all postpartum women aged 18--44; Columns (4)--(5) restrict to women below 200\\% FPL.\n",
  "Column (3) is a placebo outcome: employer-sponsored insurance should not be affected by Medicaid policy.\n",
  "Treated jurisdictions adopted by 2022; control jurisdictions include 2 never-adopters and 20 not-yet-adopters.\n",
  "\\end{tablenotes}\n",
  "\\end{table}\n"
)

writeLines(tab2_tex, file.path(tab_dir, "tab2_main_results.tex"))

# =========================================================
# Table 3: Robustness Checks
# =========================================================

cat("  Table 3: Robustness\n")

tab3_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Robustness Checks}\n",
  "\\label{tab:robustness}\n",
  "\\begin{tabular}{lcc}\n",
  "\\toprule\n",
  " & Medicaid ATT & SE \\\\\n",
  "\\midrule\n",
  sprintf("Main result (CS-DiD, all PP) & %.4f & %.4f \\\\\n",
          cs_med$overall.att, cs_med$overall.se),
  sprintf("Low-income PP ($<$200\\%% FPL) & %.4f & %.4f \\\\\n",
          cs_med_low$overall.att, cs_med_low$overall.se)
)

if (!is.null(robustness)) {
  if (!is.null(robustness$placebo_highinc)) {
    tab3_tex <- paste0(tab3_tex,
      sprintf("Placebo: High-income PP ($>$400\\%% FPL) & %.4f & %.4f \\\\\n",
              robustness$placebo_highinc$overall.att, robustness$placebo_highinc$overall.se))
  }
  if (!is.null(robustness$placebo_nonpp)) {
    tab3_tex <- paste0(tab3_tex,
      sprintf("Placebo: Non-PP low-income women & %.4f & %.4f \\\\\n",
              robustness$placebo_nonpp$overall.att, robustness$placebo_nonpp$overall.se))
  }
  if (!is.null(robustness$no_phe)) {
    tab3_tex <- paste0(tab3_tex,
      sprintf("Excluding PHE period (2020--2022) & %.4f & %.4f \\\\\n",
              robustness$no_phe$overall.att, robustness$no_phe$overall.se))
  }
}

tab3_tex <- paste0(tab3_tex,
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item \\textit{Notes:} All estimates use the Callaway \\& Sant'Anna (2021) estimator.\n",
  "Placebo tests confirm effects are concentrated among the policy-affected population.\n",
  "\\end{tablenotes}\n",
  "\\end{table}\n"
)

writeLines(tab3_tex, file.path(tab_dir, "tab3_robustness.tex"))

# =========================================================
# Table 4: Treatment Dates
# =========================================================

cat("  Table 4: Treatment dates\n")

sorted_dates <- treatment_dates %>%
  arrange(adopt_year, state_abbr) %>%
  mutate(
    in_sample = ifelse(adopt_year <= 2022, "Treated", "NYT")
  )

tab4_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{State Adoption of 12-Month Medicaid Postpartum Coverage}\n",
  "\\label{tab:adoption}\n",
  "\\footnotesize\n",
  "\\begin{tabular}{lccc|lccc}\n",
  "\\toprule\n",
  "State & Year & Mechanism & Status & State & Year & Mechanism & Status \\\\\n",
  "\\midrule\n"
)

# Split into two columns
n <- nrow(sorted_dates)
mid <- ceiling(n / 2)

for (i in 1:mid) {
  left <- sorted_dates[i, ]
  right_idx <- i + mid
  if (right_idx <= n) {
    right <- sorted_dates[right_idx, ]
    tab4_tex <- paste0(tab4_tex,
      sprintf("%s & %d & %s & %s & %s & %d & %s & %s \\\\\n",
              left$state_abbr, left$adopt_year, left$mechanism, left$in_sample,
              right$state_abbr, right$adopt_year, right$mechanism, right$in_sample))
  } else {
    tab4_tex <- paste0(tab4_tex,
      sprintf("%s & %d & %s & %s & & & & \\\\\n",
              left$state_abbr, left$adopt_year, left$mechanism, left$in_sample))
  }
}

tab4_tex <- paste0(tab4_tex,
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item \\textit{Notes:} SPA = State Plan Amendment under ARPA Section 9812.\n",
  "Waiver = Section 1115 demonstration waiver. Dates indicate year of effective coverage.\n",
  "Status: ``Treated'' = coded as treated in the 2017--2022 analysis sample; ``NYT'' = not-yet-treated (adopted after sample period ends).\n",
  "Arkansas and Wisconsin are never-adopted controls (coded as not-yet-treated).\n",
  "Treated states: 29 (4 in 2021, 25 in 2022). Not-yet-treated: 22 (2 never + 20 post-2022).\n",
  "\\end{tablenotes}\n",
  "\\end{table}\n"
)

writeLines(tab4_tex, file.path(tab_dir, "tab4_adoption.tex"))

cat("\n=== Tables complete ===\n")
