##############################################################################
# 06_tables.R - Generate all tables
# Revision of apep_0160: Medicaid Postpartum Coverage Extensions (v5)
# CHANGES: 95% CIs in Tables 2-3, fixed Table 3 Panel C labeling,
#          completed Table 4 inference columns, new tables (pre-trend,
#          cohort ATTs, balance), per-regression N and cluster counts,
#          Panel D obs fix, LOO table, ATT(g,t) reconciliation, power curve
##############################################################################

source("00_packages.R")

cat("=== Generating Tables ===\n")

# Load data and results
df_postpartum <- fread(file.path(data_dir, "acs_postpartum.csv"))
df_pp_lowinc <- fread(file.path(data_dir, "acs_postpartum_lowinc.csv"))
state_year_pp <- fread(file.path(data_dir, "state_year_postpartum.csv"))
state_year_pp_low <- fread(file.path(data_dir, "state_year_postpartum_lowinc.csv"))
treatment_dates <- fread(file.path(data_dir, "treatment_dates.csv"))
results <- readRDS(file.path(data_dir, "main_results.rds"))
robustness <- tryCatch(readRDS(file.path(data_dir, "robustness_results.rds")),
                       error = function(e) NULL)

n_clusters_all <- n_distinct(state_year_pp$state_fips)
n_clusters_low <- n_distinct(state_year_pp_low$state_fips)

# Helper: format 95% CI from SE
fmt_ci <- function(att, se_val) {
  sprintf("[%.4f, %.4f]", att - 1.96 * se_val, att + 1.96 * se_val)
}

# =========================================================
# Table 1: Summary Statistics (unchanged)
# =========================================================

cat("  Table 1: Summary statistics\n")

pre_data <- df_postpartum %>% filter(year <= 2019)

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

n_treated_states <- n_distinct(pre_data$state_fips[pre_data$first_treat > 0])
n_control_states <- n_distinct(pre_data$state_fips[pre_data$first_treat == 0])

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
  "\\midrule\n",
  sprintf("States (clusters) & %d & %d \\\\\n", n_treated_states, n_control_states),
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item \\textit{Notes:} Sample is women aged 18--44 who gave birth in the past 12 months.\n",
  "Pre-treatment period is 2017--2019 (before PHE and policy adoption).\n",
  "Statistics are weighted using ACS person weights.\n",
  "Treated states adopted the 12-month postpartum extension by 2024.\n",
  sprintf("Control states: AR, WI (never adopted), ID, IA (adopt 2025). Total clusters: %d.\n", n_clusters_all),
  "\\end{tablenotes}\n",
  "\\end{table}\n"
)

writeLines(tab1_tex, file.path(tab_dir, "tab1_summary.tex"))

# =========================================================
# Table 2: Main Results (with 95% CIs and cluster counts)
# =========================================================

cat("  Table 2: Main results (with 95% CIs)\n")

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
  "\\small\n",
  "\\begin{tabular}{lccccc}\n",
  "\\toprule\n",
  " & \\multicolumn{3}{c}{All Postpartum Women} & \\multicolumn{2}{c}{Low-Income ($<$200\\% FPL)} \\\\\n",
  "\\cmidrule(lr){2-4} \\cmidrule(lr){5-6}\n",
  " & Medicaid & Uninsured & Employer & Medicaid & Uninsured \\\\\n",
  " & (1) & (2) & (3) & (4) & (5) \\\\\n",
  "\\midrule\n",
  "\\multicolumn{6}{l}{\\textit{Panel A: CS-DiD (Full Sample, 2017--2024)}} \\\\\n",
  sprintf("ATT & %.4f & %.4f & %.4f & %.4f & %.4f \\\\\n",
          cs_med$overall.att, cs_uni$overall.att, cs_emp$overall.att,
          cs_med_low$overall.att, cs_uni_low$overall.att),
  sprintf(" & (%.4f) & (%.4f) & (%.4f) & (%.4f) & (%.4f) \\\\\n",
          cs_med$overall.se, cs_uni$overall.se, cs_emp$overall.se,
          cs_med_low$overall.se, cs_uni_low$overall.se),
  sprintf("95\\%% CI & %s & %s & %s & %s & %s \\\\\n",
          fmt_ci(cs_med$overall.att, cs_med$overall.se),
          fmt_ci(cs_uni$overall.att, cs_uni$overall.se),
          fmt_ci(cs_emp$overall.att, cs_emp$overall.se),
          fmt_ci(cs_med_low$overall.att, cs_med_low$overall.se),
          fmt_ci(cs_uni_low$overall.att, cs_uni_low$overall.se)),
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
  sprintf("95\\%% CI & %s & %s & %s & & \\\\\n",
          fmt_ci(coef(results$twfe$medicaid)["treated"], se(results$twfe$medicaid)["treated"]),
          fmt_ci(coef(results$twfe$uninsured)["treated"], se(results$twfe$uninsured)["treated"]),
          fmt_ci(coef(results$twfe$employer)["treated"], se(results$twfe$employer)["treated"])),
  "[0.5em]\n"
)

# Panel C: DDD (fixed labeling per Advisor Fatal #3)
tab2_tex <- paste0(tab2_tex,
  "\\multicolumn{6}{l}{\\textit{Panel C: Triple-Difference (DDD, Low-Income)}} \\\\\n",
  sprintf("TWFE DDD (Treated $\\times$ PP) & %.4f & %.4f & %.4f & & \\\\\n",
          coef(results$ddd$twfe_medicaid)[1],
          coef(results$ddd$twfe_uninsured)[1],
          coef(results$ddd$twfe_employer)[1]),
  sprintf(" & (%.4f) & (%.4f) & (%.4f) & & \\\\\n",
          se(results$ddd$twfe_medicaid)[1],
          se(results$ddd$twfe_uninsured)[1],
          se(results$ddd$twfe_employer)[1]),
  sprintf("95\\%% CI & %s & %s & %s & & \\\\\n",
          fmt_ci(coef(results$ddd$twfe_medicaid)[1], se(results$ddd$twfe_medicaid)[1]),
          fmt_ci(coef(results$ddd$twfe_uninsured)[1], se(results$ddd$twfe_uninsured)[1]),
          fmt_ci(coef(results$ddd$twfe_employer)[1], se(results$ddd$twfe_employer)[1]))
)

# DDD CS-DiD line (clearly labeled)
if (!is.null(results$ddd$cs_agg_medicaid)) {
  tab2_tex <- paste0(tab2_tex,
    sprintf("CS-DiD on Diff.~Outcome & %.4f & & & & \\\\\n",
            results$ddd$cs_agg_medicaid$overall.att),
    sprintf(" & (%.4f) & & & & \\\\\n",
            results$ddd$cs_agg_medicaid$overall.se),
    sprintf("95\\%% CI & %s & & & & \\\\\n",
            fmt_ci(results$ddd$cs_agg_medicaid$overall.att,
                   results$ddd$cs_agg_medicaid$overall.se))
  )
}

tab2_tex <- paste0(tab2_tex, "[0.5em]\n")

# Panel D: Post-PHE Only
if (!is.null(robustness) && !is.null(robustness$post_phe)) {
  tab2_tex <- paste0(tab2_tex,
    "\\multicolumn{6}{l}{\\textit{Panel D: Post-PHE Only (2017--2019 + 2023--2024)}} \\\\\n",
    sprintf("ATT & %.4f & ", robustness$post_phe$overall.att)
  )
  if (!is.null(robustness$post_phe_unins)) {
    tab2_tex <- paste0(tab2_tex, sprintf("%.4f & ", robustness$post_phe_unins$overall.att))
  } else {
    tab2_tex <- paste0(tab2_tex, "--- & ")
  }
  if (!is.null(robustness$post_phe_emp)) {
    tab2_tex <- paste0(tab2_tex, sprintf("%.4f & & \\\\\n", robustness$post_phe_emp$overall.att))
  } else {
    tab2_tex <- paste0(tab2_tex, "--- & & \\\\\n")
  }
  tab2_tex <- paste0(tab2_tex,
    sprintf(" & (%.4f) & ", robustness$post_phe$overall.se))
  if (!is.null(robustness$post_phe_unins)) {
    tab2_tex <- paste0(tab2_tex, sprintf("(%.4f) & ", robustness$post_phe_unins$overall.se))
  } else {
    tab2_tex <- paste0(tab2_tex, "--- & ")
  }
  if (!is.null(robustness$post_phe_emp)) {
    tab2_tex <- paste0(tab2_tex, sprintf("(%.4f) & & \\\\\n", robustness$post_phe_emp$overall.se))
  } else {
    tab2_tex <- paste0(tab2_tex, "--- & & \\\\\n")
  }
  # 95% CI for post-PHE
  tab2_tex <- paste0(tab2_tex,
    sprintf("95\\%% CI & %s & ", fmt_ci(robustness$post_phe$overall.att, robustness$post_phe$overall.se)))
  if (!is.null(robustness$post_phe_unins)) {
    tab2_tex <- paste0(tab2_tex, sprintf("%s & ", fmt_ci(robustness$post_phe_unins$overall.att, robustness$post_phe_unins$overall.se)))
  } else {
    tab2_tex <- paste0(tab2_tex, "--- & ")
  }
  if (!is.null(robustness$post_phe_emp)) {
    tab2_tex <- paste0(tab2_tex, sprintf("%s & & \\\\\n", fmt_ci(robustness$post_phe_emp$overall.att, robustness$post_phe_emp$overall.se)))
  } else {
    tab2_tex <- paste0(tab2_tex, "--- & & \\\\\n")
  }
}

# Compute per-panel observation counts
n_obs_panel_a <- nrow(state_year_pp)
n_obs_panel_d <- nrow(state_year_pp %>% filter(year <= 2019 | year >= 2023))
n_obs_panel_low <- nrow(state_year_pp_low)

# Bottom section with cluster counts and N
n_treated <- n_distinct(state_year_pp$state_fips[state_year_pp$first_treat > 0])
n_control <- n_distinct(state_year_pp$state_fips[state_year_pp$first_treat == 0])

tab2_tex <- paste0(tab2_tex,
  "\\midrule\n",
  "State FE & Yes & Yes & Yes & Yes & Yes \\\\\n",
  "Year FE & Yes & Yes & Yes & Yes & Yes \\\\\n",
  "Weights & ACS & ACS & ACS & ACS & ACS \\\\\n",
  sprintf("Obs.~(Panel A, state-years) & %d & %d & %d & %d & %d \\\\\n",
          n_obs_panel_a, n_obs_panel_a, n_obs_panel_a,
          n_obs_panel_low, n_obs_panel_low),
  sprintf("Obs.~(Panel D, state-years) & %d & %d & %d & & \\\\\n",
          n_obs_panel_d, n_obs_panel_d, n_obs_panel_d),
  sprintf("Clusters (states) & %d & %d & %d & %d & %d \\\\\n",
          n_clusters_all, n_clusters_all, n_clusters_all, n_clusters_low, n_clusters_low),
  sprintf("Treated states & %d & %d & %d & %d & %d \\\\\n",
          n_treated, n_treated, n_treated, n_treated, n_treated),
  sprintf("Control states & %d & %d & %d & %d & %d \\\\\n",
          n_control, n_control, n_control, n_control, n_control),
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item \\textit{Notes:} Panel A reports CS-DiD ATT (Callaway \\& Sant'Anna 2021) using the full 2017--2024 sample.\n",
  "Panel B reports biased TWFE for comparison.\n",
  "Panel C: ``TWFE DDD'' uses state$\\times$postpartum and year$\\times$postpartum FE on individual-level data; ``CS-DiD on Diff.~Outcome'' applies the CS estimator to the state-year difference (postpartum minus non-postpartum Medicaid rate). Signs can differ because TWFE DDD is subject to negative weighting bias from heterogeneous treatment effects, while CS-DiD on the differenced outcome avoids this.\n",
  "Panel D restricts to 2017--2019 + 2023--2024, excluding PHE years.\n",
  "Standard errors in parentheses, clustered at the state level. 95\\% CIs based on normal approximation.\n",
  "\\end{tablenotes}\n",
  "\\end{table}\n"
)

writeLines(tab2_tex, file.path(tab_dir, "tab2_main_results.tex"))

# =========================================================
# Table 3: Robustness Checks (with 95% CIs, fixed labeling, filled p-values)
# =========================================================

cat("  Table 3: Robustness (expanded with 95% CIs)\n")

tab3_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Robustness Checks}\n",
  "\\label{tab:robustness}\n",
  "\\small\n",
  "\\begin{tabular}{lccccc}\n",
  "\\toprule\n",
  " & ATT & SE & 95\\% CI & WCB $p$ & Perm.~$p$ \\\\\n",
  "\\midrule\n"
)

# Row helper
add_row <- function(label, att, se_val, wcb_p = NA, perm_p = NA) {
  ci_str <- fmt_ci(att, se_val)
  wcb_str <- ifelse(is.na(wcb_p), "N/A$^a$", sprintf("%.3f", wcb_p))
  perm_str <- ifelse(is.na(perm_p), "N/A$^a$", sprintf("%.3f", perm_p))
  sprintf("%s & %.4f & %.4f & %s & %s & %s \\\\\n",
          label, att, se_val, ci_str, wcb_str, perm_str)
}

# Main result
wcb_twfe_p <- if (!is.null(robustness) && !is.null(robustness$wcb$twfe)) robustness$wcb$twfe$p_val else NA
wcb_csid_p <- if (!is.null(robustness) && !is.null(robustness$wcb$csid_main)) robustness$wcb$csid_main$p_val else NA
perm_csid_p <- if (!is.null(robustness) && !is.null(robustness$permutation)) robustness$permutation$pval else NA

tab3_tex <- paste0(tab3_tex,
  add_row("Main CS-DiD (all PP)", cs_med$overall.att, cs_med$overall.se,
          wcb_csid_p, perm_csid_p))

# Low-income
tab3_tex <- paste0(tab3_tex,
  add_row("Low-income PP ($<$200\\% FPL)", cs_med_low$overall.att, cs_med_low$overall.se))

# DDD TWFE (clearly labeled)
wcb_ddd_p <- if (!is.null(robustness) && !is.null(robustness$wcb$ddd)) robustness$wcb$ddd$p_val else NA
tab3_tex <- paste0(tab3_tex,
  add_row("TWFE DDD (Treated $\\times$ PP)", coef(results$ddd$twfe_medicaid)[1],
          se(results$ddd$twfe_medicaid)[1], wcb_ddd_p))

# DDD CS-DiD (clearly labeled)
if (!is.null(results$ddd$cs_agg_medicaid)) {
  ddd_perm_p <- if (!is.null(robustness) && !is.null(robustness$permutation$ddd_pval)) {
    robustness$permutation$ddd_pval
  } else { NA }
  tab3_tex <- paste0(tab3_tex,
    add_row("CS-DiD on Diff.~Outcome", results$ddd$cs_agg_medicaid$overall.att,
            results$ddd$cs_agg_medicaid$overall.se, NA, ddd_perm_p))
}

# Post-PHE
if (!is.null(robustness) && !is.null(robustness$post_phe)) {
  wcb_phe_p <- if (!is.null(robustness$wcb$post_phe)) robustness$wcb$post_phe$p_val else NA
  wcb_csid_phe_p <- if (!is.null(robustness$wcb$csid_post_phe)) robustness$wcb$csid_post_phe$p_val else NA
  tab3_tex <- paste0(tab3_tex,
    add_row("Post-PHE (2017--19 + 2023--24)", robustness$post_phe$overall.att,
            robustness$post_phe$overall.se, wcb_csid_phe_p))
}

# 2024-only
if (!is.null(robustness) && !is.null(robustness$post_2024only)) {
  tab3_tex <- paste0(tab3_tex,
    add_row("2024-only post-period", robustness$post_2024only$overall.att,
            robustness$post_2024only$overall.se))
} else if (!is.null(robustness) && !is.null(robustness$post_2024only_twfe)) {
  tab3_tex <- paste0(tab3_tex,
    add_row("2024-only (TWFE)", coef(robustness$post_2024only_twfe)["treated"],
            se(robustness$post_2024only_twfe)["treated"]))
}

# Late adopters
if (!is.null(robustness) && !is.null(robustness$late_adopter)) {
  tab3_tex <- paste0(tab3_tex,
    add_row("Late adopters (2024)", robustness$late_adopter$overall.att,
            robustness$late_adopter$overall.se))
} else if (!is.null(robustness) && !is.null(robustness$late_adopter_twfe)) {
  tab3_tex <- paste0(tab3_tex,
    add_row("Late adopters (2024, TWFE)", coef(robustness$late_adopter_twfe)["treated"],
            se(robustness$late_adopter_twfe)["treated"]))
}

# Placebos
tab3_tex <- paste0(tab3_tex, "\\midrule\n",
  "\\multicolumn{6}{l}{\\textit{Placebo Tests}} \\\\\n")

if (!is.null(robustness) && !is.null(robustness$placebo_highinc)) {
  tab3_tex <- paste0(tab3_tex,
    add_row("High-income PP ($>$400\\% FPL)", robustness$placebo_highinc$overall.att,
            robustness$placebo_highinc$overall.se))
}
if (!is.null(robustness) && !is.null(robustness$placebo_nonpp)) {
  tab3_tex <- paste0(tab3_tex,
    add_row("Non-PP low-income women", robustness$placebo_nonpp$overall.att,
            robustness$placebo_nonpp$overall.se))
}
if (!is.null(robustness) && !is.null(robustness$no_phe)) {
  tab3_tex <- paste0(tab3_tex,
    add_row("Excluding PHE (2020--2022)", robustness$no_phe$overall.att,
            robustness$no_phe$overall.se))
}

# HonestDiD
tab3_tex <- paste0(tab3_tex, "\\midrule\n",
  "\\multicolumn{6}{l}{\\textit{HonestDiD Sensitivity (Rambachan-Roth)}} \\\\\n")

if (!is.null(robustness) && !is.null(robustness$honest_did)) {
  for (mbar_name in names(robustness$honest_did)) {
    hd <- robustness$honest_did[[mbar_name]]
    if (!is.null(hd) && nrow(hd) > 0) {
      tab3_tex <- paste0(tab3_tex,
        sprintf("\\quad $\\bar{M} = %s$ & & & [%.4f, %.4f] & & \\\\\n",
                mbar_name, hd$lb[1], hd$ub[1]))
    }
  }
} else {
  tab3_tex <- paste0(tab3_tex, "\\quad Not computed & & & & & \\\\\n")
}

# Footer
tab3_tex <- paste0(tab3_tex,
  "\\midrule\n",
  sprintf("Observations (state-years) & \\multicolumn{5}{c}{%d} \\\\\n", nrow(state_year_pp)),
  sprintf("Clusters (states) & \\multicolumn{5}{c}{%d} \\\\\n", n_clusters_all),
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item \\textit{Notes:} All CS-DiD estimates use the Callaway \\& Sant'Anna (2021) estimator.\n",
  "``TWFE DDD'' uses state$\\times$postpartum and year$\\times$postpartum FE.\n",
  "``CS-DiD on Diff.~Outcome'' applies CS-DiD to the differenced Medicaid rate (PP $-$ non-PP).\n",
  "WCB $p$: wild cluster bootstrap or state-cluster bootstrap $p$-value.\n",
  sprintf("Perm.~$p$: CS-DiD permutation $p$-value from %d random reassignments (two-sided).\n",
          ifelse(!is.null(robustness) && !is.null(robustness$permutation),
                 robustness$permutation$n_perm, 200)),
  "$^a$N/A indicates inference method not applicable to this specification.\n",
  "HonestDiD: Rambachan \\& Roth (2023) robust CIs under relative magnitudes assumption.\n",
  "\\end{tablenotes}\n",
  "\\end{table}\n"
)

writeLines(tab3_tex, file.path(tab_dir, "tab3_robustness.tex"))

# =========================================================
# Table 4: Treatment Dates (with horizontal rules between adoption years)
# =========================================================

cat("  Table 4: Treatment dates\n")

max_year <- max(df_postpartum$year)

sorted_dates <- treatment_dates %>%
  arrange(adopt_year, state_abbr) %>%
  mutate(
    in_sample = case_when(
      adopt_year <= max_year ~ "Treated",
      adopt_year > max_year ~ "NYT",
      TRUE ~ "Control"
    )
  )

never_rows <- data.frame(
  state_fips = c(5, 55),
  state_abbr = c("AR", "WI"),
  adopt_year = c(NA, NA),
  mechanism = c("---", "---"),
  in_sample = c("Control", "Control")
)

sorted_dates <- bind_rows(sorted_dates, never_rows) %>%
  arrange(
    is.na(adopt_year),
    adopt_year,
    state_abbr
  ) %>%
  mutate(adopt_year_str = ifelse(is.na(adopt_year), "Never", as.character(adopt_year)))

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

n <- nrow(sorted_dates)
mid <- ceiling(n / 2)

prev_year <- NULL
for (i in 1:mid) {
  left <- sorted_dates[i, ]
  right_idx <- i + mid

  # Determine current adoption year for the left column
  cur_year <- left$adopt_year_str

  # Insert a cmidrule when the adoption year changes

  if (!is.null(prev_year) && cur_year != prev_year) {
    tab4_tex <- paste0(tab4_tex, "\\cmidrule{1-8}\n")
  }
  prev_year <- cur_year

  if (right_idx <= n) {
    right <- sorted_dates[right_idx, ]
    tab4_tex <- paste0(tab4_tex,
      sprintf("%s & %s & %s & %s & %s & %s & %s & %s \\\\\n",
              left$state_abbr, left$adopt_year_str, left$mechanism, left$in_sample,
              right$state_abbr, right$adopt_year_str, right$mechanism, right$in_sample))
  } else {
    tab4_tex <- paste0(tab4_tex,
      sprintf("%s & %s & %s & %s & & & & \\\\\n",
              left$state_abbr, left$adopt_year_str, left$mechanism, left$in_sample))
  }
}

n_treated_total <- sum(sorted_dates$in_sample == "Treated")
n_nyt <- sum(sorted_dates$in_sample == "NYT")
n_control_tab <- sum(sorted_dates$in_sample == "Control")

tab4_tex <- paste0(tab4_tex,
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item \\textit{Notes:} SPA = State Plan Amendment under ARPA Section 9812.\n",
  "Waiver = Section 1115 demonstration waiver.\n",
  sprintf("Status: ``Treated'' = adopted by %d (N=%d); ``NYT'' = not-yet-treated in sample (N=%d, coded as \\texttt{first\\_treat = 0} in CS-DiD, i.e., treated as never-treated control units); ``Control'' = never adopted (N=%d).\n",
          max_year, n_treated_total, n_nyt, n_control_tab),
  sprintf("Total clusters (states): %d.\n", n_clusters_all),
  "Control group for CS-DiD: NYT + Control states (all coded \\texttt{first\\_treat = 0}).\n",
  "\\end{tablenotes}\n",
  "\\end{table}\n"
)

writeLines(tab4_tex, file.path(tab_dir, "tab4_adoption.tex"))

# =========================================================
# Table 5: Post-PHE Heterogeneity (unchanged)
# =========================================================

cat("  Table 5: Post-PHE heterogeneity\n")

tab5_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Post-PHE Treatment Effect Heterogeneity}\n",
  "\\label{tab:heterogeneity}\n",
  "\\begin{tabular}{lcc}\n",
  "\\toprule\n",
  " & Medicaid ATT & SE \\\\\n",
  "\\midrule\n"
)

tab5_tex <- paste0(tab5_tex,
  "\\multicolumn{3}{l}{\\textit{Panel A: By Adoption Cohort}} \\\\\n")

if (!is.null(robustness) && !is.null(robustness$cohort_het)) {
  ch <- robustness$cohort_het
  for (i in seq_along(ch$egt)) {
    tab5_tex <- paste0(tab5_tex,
      sprintf("Cohort %d & %.4f & %.4f \\\\\n",
              ch$egt[i], ch$att.egt[i], ch$se.egt[i]))
  }
} else {
  tab5_tex <- paste0(tab5_tex, "Not computed & & \\\\\n")
}

tab5_tex <- paste0(tab5_tex,
  "[0.5em]\n",
  "\\multicolumn{3}{l}{\\textit{Panel B: By Medicaid Expansion Status (Post-PHE)}} \\\\\n")

if (!is.null(robustness) && !is.null(robustness$twfe_expansion_post_phe)) {
  exp_coefs <- coef(robustness$twfe_expansion_post_phe)
  exp_ses <- se(robustness$twfe_expansion_post_phe)
  for (i in seq_along(exp_coefs)) {
    tab5_tex <- paste0(tab5_tex,
      sprintf("%s & %.4f & %.4f \\\\\n",
              names(exp_coefs)[i], exp_coefs[i], exp_ses[i]))
  }
} else {
  tab5_tex <- paste0(tab5_tex, "Not computed & & \\\\\n")
}

tab5_tex <- paste0(tab5_tex,
  "[0.5em]\n",
  "\\multicolumn{3}{l}{\\textit{Panel C: By Race/Ethnicity (Post-PHE, Low-Income)}} \\\\\n")

if (!is.null(robustness) && length(robustness$race_het) > 0) {
  for (race in names(robustness$race_het)) {
    r <- robustness$race_het[[race]]
    tab5_tex <- paste0(tab5_tex,
      sprintf("%s & %.4f & %.4f \\\\\n",
              race, coef(r)["treated"], se(r)["treated"]))
  }
} else {
  tab5_tex <- paste0(tab5_tex, "Not computed & & \\\\\n")
}

tab5_tex <- paste0(tab5_tex,
  "\\midrule\n",
  sprintf("Clusters (states) & \\multicolumn{2}{c}{%d} \\\\\n", n_clusters_all),
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item \\textit{Notes:} Panel A reports group-specific ATTs from Callaway \\& Sant'Anna (2021).\n",
  "Panels B--C use TWFE on the post-PHE sample (2017--2019 + 2023--2024) for low-income postpartum women.\n",
  sprintf("All standard errors clustered at the state level (%d clusters).\n", n_clusters_all),
  "\\end{tablenotes}\n",
  "\\end{table}\n"
)

writeLines(tab5_tex, file.path(tab_dir, "tab5_heterogeneity.tex"))

# =========================================================
# NEW Table 6: DDD Pre-Trend Coefficients
# =========================================================

cat("  Table 6: DDD pre-trend coefficients\n")

tab6_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{DDD Pre-Treatment Event-Study Coefficients}\n",
  "\\label{tab:ddd_pretrend}\n",
  "\\begin{tabular}{lccc}\n",
  "\\toprule\n",
  "Event Time & Coefficient & SE & $p$-value \\\\\n",
  "\\midrule\n"
)

if (!is.null(robustness) && !is.null(robustness$ddd_pretrend)) {
  pre_c <- robustness$ddd_pretrend$pre_coefs
  for (i in seq_len(nrow(pre_c))) {
    pval_i <- 2 * pnorm(-abs(pre_c$att[i] / pre_c$se[i]))
    tab6_tex <- paste0(tab6_tex,
      sprintf("$e = %d$ & %.4f & %.4f & %.3f \\\\\n",
              pre_c$e[i], pre_c$att[i], pre_c$se[i], pval_i))
  }
  tab6_tex <- paste0(tab6_tex, "\\midrule\n",
    sprintf("Joint $F$-test ($p$-value) & \\multicolumn{3}{c}{%.3f} \\\\\n",
            robustness$ddd_pretrend$f_pval))
} else if (!is.null(results$ddd$cs_dyn_medicaid)) {
  ddd_dyn <- results$ddd$cs_dyn_medicaid
  es <- data.frame(e = ddd_dyn$egt, att = ddd_dyn$att.egt, se = ddd_dyn$se.egt)
  pre_c <- es[es$e < 0, ]
  for (i in seq_len(nrow(pre_c))) {
    pval_i <- 2 * pnorm(-abs(pre_c$att[i] / pre_c$se[i]))
    tab6_tex <- paste0(tab6_tex,
      sprintf("$e = %d$ & %.4f & %.4f & %.3f \\\\\n",
              pre_c$e[i], pre_c$att[i], pre_c$se[i], pval_i))
  }
} else {
  tab6_tex <- paste0(tab6_tex, "Not available & & & \\\\\n")
}

tab6_tex <- paste0(tab6_tex,
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item \\textit{Notes:} Pre-treatment event-study coefficients from the DDD CS-DiD on the differenced outcome\n",
  "(postpartum minus non-postpartum low-income Medicaid rate).\n",
  "Coefficients near zero support the DDD parallel trends assumption.\n",
  "Joint $F$-test: null hypothesis that all pre-treatment coefficients are jointly zero.\n",
  "\\end{tablenotes}\n",
  "\\end{table}\n"
)

writeLines(tab6_tex, file.path(tab_dir, "tab6_ddd_pretrend.tex"))

# =========================================================
# NEW Table 7: Cohort-Specific ATTs
# =========================================================

cat("  Table 7: Cohort-specific ATTs\n")

tab7_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Cohort-Specific Average Treatment Effects}\n",
  "\\label{tab:cohort_atts}\n",
  "\\begin{tabular}{lccc}\n",
  "\\toprule\n",
  "Adoption Year & ATT & SE & N (states) \\\\\n",
  "\\midrule\n"
)

# Cohort sizes from treatment assignment
cohort_sizes <- state_year_pp %>%
  filter(first_treat > 0) %>%
  distinct(state_fips, first_treat) %>%
  count(first_treat, name = "n_states") %>%
  arrange(first_treat)

# Use cs_group from main results if available
if (!is.null(results$cs_group$medicaid)) {
  cg <- results$cs_group$medicaid
  for (i in seq_along(cg$egt)) {
    n_st <- cohort_sizes$n_states[cohort_sizes$first_treat == cg$egt[i]]
    if (length(n_st) == 0) n_st <- NA
    tab7_tex <- paste0(tab7_tex,
      sprintf("%d & %.4f & %.4f & %d \\\\\n",
              cg$egt[i], cg$att.egt[i], cg$se.egt[i], n_st))
  }
} else if (!is.null(robustness) && !is.null(robustness$cohort_het)) {
  ch <- robustness$cohort_het
  for (i in seq_along(ch$egt)) {
    n_st <- cohort_sizes$n_states[cohort_sizes$first_treat == ch$egt[i]]
    if (length(n_st) == 0) n_st <- NA
    tab7_tex <- paste0(tab7_tex,
      sprintf("%d & %.4f & %.4f & %d \\\\\n",
              ch$egt[i], ch$att.egt[i], ch$se.egt[i], n_st))
  }
} else {
  tab7_tex <- paste0(tab7_tex, "Not available & & & \\\\\n")
}

# Overall
tab7_tex <- paste0(tab7_tex,
  "\\midrule\n",
  sprintf("Overall (simple) & %.4f & %.4f & %d \\\\\n",
          cs_med$overall.att, cs_med$overall.se, n_clusters_all))

tab7_tex <- paste0(tab7_tex,
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item \\textit{Notes:} Group-specific ATTs from Callaway \\& Sant'Anna (2021) \\texttt{aggte(type = ``group'')}.\n",
  "Each row shows the average treatment effect for states adopting in that year.\n",
  "Standard errors clustered at the state level.\n",
  "\\end{tablenotes}\n",
  "\\end{table}\n"
)

writeLines(tab7_tex, file.path(tab_dir, "tab7_cohort_atts.tex"))

# =========================================================
# NEW Table 8: Leave-One-Out Control State Analysis
# =========================================================

cat("  Table 8: Leave-one-out results\n")

tab8_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Leave-One-Out Control State Analysis}\n",
  "\\label{tab:loo}\n",
  "\\begin{tabular}{lccc}\n",
  "\\toprule\n",
  "Dropped State & ATT & SE & 95\\% CI \\\\\n",
  "\\midrule\n"
)

if (!is.null(robustness) && !is.null(robustness$loo) && length(robustness$loo) > 0) {
  for (state_name in names(robustness$loo)) {
    loo_r <- robustness$loo[[state_name]]
    tab8_tex <- paste0(tab8_tex,
      sprintf("%s & %.4f & %.4f & %s \\\\\n",
              state_name, loo_r$att, loo_r$se,
              fmt_ci(loo_r$att, loo_r$se)))
  }
}

# Full sample for comparison
tab8_tex <- paste0(tab8_tex,
  "\\midrule\n",
  sprintf("Full sample & %.4f & %.4f & %s \\\\\n",
          cs_med$overall.att, cs_med$overall.se,
          fmt_ci(cs_med$overall.att, cs_med$overall.se)),
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item \\textit{Notes:} Each row drops one control state and re-estimates the CS-DiD ATT.\n",
  "Control states: AR (Arkansas), WI (Wisconsin), ID (Idaho), IA (Iowa).\n",
  "Stability across rows indicates no single control state drives the results.\n",
  "\\end{tablenotes}\n",
  "\\end{table}\n"
)

writeLines(tab8_tex, file.path(tab_dir, "tab8_loo.tex"))

# =========================================================
# NEW Table 9: ATT(g,t) Reconciliation
# =========================================================

cat("  Table 9: ATT(g,t) reconciliation\n")

tab9_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{ATT(g,t) Matrix: Decomposing the Aggregate CS-DiD Estimate}\n",
  "\\label{tab:att_gt}\n",
  "\\footnotesize\n",
  "\\begin{tabular}{l",
  paste(rep("c", 7), collapse = ""),
  "}\n",
  "\\toprule\n",
  " & \\multicolumn{7}{c}{Year $t$} \\\\\n",
  "\\cmidrule(lr){2-8}\n",
  "Cohort $g$ & 2017 & 2018 & 2019 & 2021 & 2022 & 2023 & 2024 \\\\\n",
  "\\midrule\n"
)

# Extract ATT(g,t) from the CS object
if (!is.null(results$cs$medicaid)) {
  cs_obj <- results$cs$medicaid
  gt_df <- data.frame(
    group = cs_obj$group,
    t = cs_obj$t,
    att = cs_obj$att,
    se = cs_obj$se
  )

  all_years <- c(2017, 2018, 2019, 2021, 2022, 2023, 2024)
  cohorts <- sort(unique(gt_df$group[gt_df$group > 0]))

  for (g in cohorts) {
    row_str <- sprintf("%d", g)
    for (yr in all_years) {
      cell <- gt_df %>% filter(group == g, t == yr)
      if (nrow(cell) > 0) {
        stars <- ifelse(abs(cell$att[1]/cell$se[1]) > 1.96, "*", "")
        row_str <- paste0(row_str, sprintf(" & %.3f%s", cell$att[1], stars))
      } else {
        row_str <- paste0(row_str, " & ---")
      }
    }
    tab9_tex <- paste0(tab9_tex, row_str, " \\\\\n")
  }
} else {
  tab9_tex <- paste0(tab9_tex, "Not available & & & & & & & \\\\\n")
}

tab9_tex <- paste0(tab9_tex,
  "\\midrule\n",
  sprintf("Overall ATT (simple) & \\multicolumn{7}{c}{%.4f (SE = %.4f)} \\\\\n",
          cs_med$overall.att, cs_med$overall.se),
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item \\textit{Notes:} Each cell reports $ATT(g,t)$ from Callaway \\& Sant'Anna (2021).\n",
  "Pre-treatment cells ($t < g$) should be near zero under parallel trends.\n",
  "Post-treatment cells ($t \\geq g$) contribute to the aggregate ATT weighted by group size.\n",
  "* indicates $|ATT/SE| > 1.96$. --- indicates cell not estimated.\n",
  "The overall ATT is the group-size-weighted average of post-treatment cells.\n",
  "\\end{tablenotes}\n",
  "\\end{table}\n"
)

writeLines(tab9_tex, file.path(tab_dir, "tab9_att_gt.tex"))

# =========================================================
# NEW Table 10: Power Curve
# =========================================================

cat("  Table 10: Power curve\n")

# Use CS-DiD DDD SE (primary spec) for power analysis, not TWFE DDD SE
ddd_se_val <- if (!is.null(results$ddd$cs_agg_medicaid)) {
  results$ddd$cs_agg_medicaid$overall.se
} else if (!is.null(robustness) && !is.null(robustness$ddd_power)) {
  robustness$ddd_power$ddd_se
} else {
  se(results$ddd$twfe_medicaid)[1]
}

main_se_val <- cs_med$overall.se

tab10_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Statistical Power at Varying True Effect Sizes}\n",
  "\\label{tab:power}\n",
  "\\begin{tabular}{lcc}\n",
  "\\toprule\n",
  "True Effect (pp) & Power (Main CS-DiD) & Power (DDD) \\\\\n",
  "\\midrule\n"
)

for (eff in c(0.025, 0.034, 0.050, 0.075, 0.100)) {
  ncp_main <- eff / main_se_val
  power_main <- 1 - pnorm(1.96 - ncp_main) + pnorm(-1.96 - ncp_main)
  ncp_ddd <- eff / ddd_se_val
  power_ddd <- 1 - pnorm(1.96 - ncp_ddd) + pnorm(-1.96 - ncp_ddd)
  tab10_tex <- paste0(tab10_tex,
    sprintf("%.1f & %.0f\\%% & %.0f\\%% \\\\\n",
            eff * 100, power_main * 100, power_ddd * 100))
}

tab10_tex <- paste0(tab10_tex,
  "\\midrule\n",
  sprintf("MDE at 80\\%% power & %.1f pp & %.1f pp \\\\\n",
          2.8 * main_se_val * 100, 2.8 * ddd_se_val * 100),
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item \\textit{Notes:} Power calculated assuming two-sided test at 5\\% significance.\n",
  sprintf("Main CS-DiD SE = %.4f; DDD SE = %.4f.\n", main_se_val, ddd_se_val),
  "MDE = minimum detectable effect at 80\\% power ($2.8 \\times$ SE).\n",
  "\\end{tablenotes}\n",
  "\\end{table}\n"
)

writeLines(tab10_tex, file.path(tab_dir, "tab10_power.tex"))

cat("\n=== Tables complete ===\n")
