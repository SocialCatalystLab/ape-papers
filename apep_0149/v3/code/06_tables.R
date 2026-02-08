##############################################################################
# 06_tables.R - Generate all tables
# Revision of apep_0153: Medicaid Postpartum Coverage Extensions (v3)
# CHANGES: Cluster counts in all tables, 2024-only row in robustness,
#          permutation p-values, attenuation calculation row
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

# =========================================================
# Table 1: Summary Statistics
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
# Table 2: Main Results (with cluster counts)
# =========================================================

cat("  Table 2: Main results\n")

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
  "\\multicolumn{6}{l}{\\textit{Panel A: CS-DiD (Full Sample, 2017--2024)}} \\\\\n",
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
  "[0.5em]\n"
)

# Panel C: DDD
tab2_tex <- paste0(tab2_tex,
  "\\multicolumn{6}{l}{\\textit{Panel C: Triple-Difference (DDD, Low-Income)}} \\\\\n",
  sprintf("Treated $\\times$ Postpartum & %.4f & %.4f & %.4f & & \\\\\n",
          coef(results$ddd$twfe_medicaid)[1],
          coef(results$ddd$twfe_uninsured)[1],
          coef(results$ddd$twfe_employer)[1]),
  sprintf(" & (%.4f) & (%.4f) & (%.4f) & & \\\\\n",
          se(results$ddd$twfe_medicaid)[1],
          se(results$ddd$twfe_uninsured)[1],
          se(results$ddd$twfe_employer)[1])
)

# DDD CS-DiD line
if (!is.null(results$ddd$cs_agg_medicaid)) {
  tab2_tex <- paste0(tab2_tex,
    sprintf("DDD CS-DiD ATT & %.4f & & & & \\\\\n",
            results$ddd$cs_agg_medicaid$overall.att),
    sprintf(" & (%.4f) & & & & \\\\\n",
            results$ddd$cs_agg_medicaid$overall.se)
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
    sprintf(" & (%.4f) & ", robustness$post_phe$overall.se)
  )
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
}

# Bottom section with cluster counts
n_treated <- n_distinct(state_year_pp$state_fips[state_year_pp$first_treat > 0])
n_control <- n_distinct(state_year_pp$state_fips[state_year_pp$first_treat == 0])

tab2_tex <- paste0(tab2_tex,
  "\\midrule\n",
  "State FE & Yes & Yes & Yes & Yes & Yes \\\\\n",
  "Year FE & Yes & Yes & Yes & Yes & Yes \\\\\n",
  sprintf("Observations (state-years) & %d & %d & %d & %d & %d \\\\\n",
          nrow(state_year_pp), nrow(state_year_pp), nrow(state_year_pp),
          nrow(state_year_pp_low), nrow(state_year_pp_low)),
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
  "Panel C reports DDD estimates (treated $\\times$ postpartum indicator) with state$\\times$postpartum and year$\\times$postpartum FE, using low-income women; DDD CS-DiD applies the Callaway-Sant'Anna estimator to the differenced outcome (postpartum minus non-postpartum Medicaid rate).\n",
  "Panel D restricts to the clean post-PHE specification (2017--2019 pre-period + 2023--2024 post-period, excluding PHE years).\n",
  "Standard errors in parentheses, clustered at the state level.\n",
  "\\end{tablenotes}\n",
  "\\end{table}\n"
)

writeLines(tab2_tex, file.path(tab_dir, "tab2_main_results.tex"))

# =========================================================
# Table 3: Robustness Checks (with permutation p-values, 2024-only, cluster counts)
# =========================================================

cat("  Table 3: Robustness (expanded)\n")

tab3_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Robustness Checks}\n",
  "\\label{tab:robustness}\n",
  "\\begin{tabular}{lcccc}\n",
  "\\toprule\n",
  " & Medicaid ATT & SE & WCB $p$ & Perm.~$p$ \\\\\n",
  "\\midrule\n",
  sprintf("Main result (CS-DiD, all PP) & %.4f & %.4f & ",
          cs_med$overall.att, cs_med$overall.se)
)

# WCB p-value for TWFE
if (!is.null(robustness) && !is.null(robustness$wcb$twfe)) {
  tab3_tex <- paste0(tab3_tex, sprintf("%.3f", robustness$wcb$twfe$p_val))
} else {
  tab3_tex <- paste0(tab3_tex, "---")
}
# Permutation p-value
if (!is.null(robustness) && !is.null(robustness$permutation)) {
  tab3_tex <- paste0(tab3_tex, sprintf(" & %.3f", robustness$permutation$pval))
} else {
  tab3_tex <- paste0(tab3_tex, " & ---")
}
tab3_tex <- paste0(tab3_tex, " \\\\\n")

# Low-income
tab3_tex <- paste0(tab3_tex,
  sprintf("Low-income PP ($<$200\\%% FPL) & %.4f & %.4f & --- & --- \\\\\n",
          cs_med_low$overall.att, cs_med_low$overall.se)
)

# DDD
tab3_tex <- paste0(tab3_tex,
  sprintf("Triple-difference (DDD TWFE) & %.4f & %.4f & ",
          coef(results$ddd$twfe_medicaid)[1], se(results$ddd$twfe_medicaid)[1])
)
if (!is.null(robustness) && !is.null(robustness$wcb$ddd)) {
  tab3_tex <- paste0(tab3_tex, sprintf("%.3f", robustness$wcb$ddd$p_val))
} else {
  tab3_tex <- paste0(tab3_tex, "---")
}
tab3_tex <- paste0(tab3_tex, " & --- \\\\\n")

# DDD CS-DiD
if (!is.null(results$ddd$cs_agg_medicaid)) {
  tab3_tex <- paste0(tab3_tex,
    sprintf("DDD CS-DiD (differenced outcome) & %.4f & %.4f & --- & --- \\\\\n",
            results$ddd$cs_agg_medicaid$overall.att, results$ddd$cs_agg_medicaid$overall.se))
}

# Post-PHE
if (!is.null(robustness) && !is.null(robustness$post_phe)) {
  tab3_tex <- paste0(tab3_tex,
    sprintf("Post-PHE only (2017--19 + 2023--24) & %.4f & %.4f & ",
            robustness$post_phe$overall.att, robustness$post_phe$overall.se))
  if (!is.null(robustness$wcb$post_phe)) {
    tab3_tex <- paste0(tab3_tex, sprintf("%.3f", robustness$wcb$post_phe$p_val))
  } else {
    tab3_tex <- paste0(tab3_tex, "---")
  }
  tab3_tex <- paste0(tab3_tex, " & --- \\\\\n")
}

# NEW: 2024-only
if (!is.null(robustness) && !is.null(robustness$post_2024only)) {
  tab3_tex <- paste0(tab3_tex,
    sprintf("2024-only post-period (excl.~2023) & %.4f & %.4f & --- & --- \\\\\n",
            robustness$post_2024only$overall.att, robustness$post_2024only$overall.se))
} else if (!is.null(robustness) && !is.null(robustness$post_2024only_twfe)) {
  tab3_tex <- paste0(tab3_tex,
    sprintf("2024-only post-period (TWFE, excl.~2023) & %.4f & %.4f & --- & --- \\\\\n",
            coef(robustness$post_2024only_twfe)["treated"],
            se(robustness$post_2024only_twfe)["treated"]))
}

# Late adopters
if (!is.null(robustness) && !is.null(robustness$late_adopter)) {
  tab3_tex <- paste0(tab3_tex,
    sprintf("Late adopters (2024) vs controls & %.4f & %.4f & --- & --- \\\\\n",
            robustness$late_adopter$overall.att, robustness$late_adopter$overall.se))
} else if (!is.null(robustness) && !is.null(robustness$late_adopter_twfe)) {
  tab3_tex <- paste0(tab3_tex,
    sprintf("Late adopters (2024, TWFE) & %.4f & %.4f & --- & --- \\\\\n",
            coef(robustness$late_adopter_twfe)["treated"],
            se(robustness$late_adopter_twfe)["treated"]))
}

# Placebos
tab3_tex <- paste0(tab3_tex, "\\midrule\n")
tab3_tex <- paste0(tab3_tex,
  "\\multicolumn{5}{l}{\\textit{Placebo Tests}} \\\\\n")

if (!is.null(robustness) && !is.null(robustness$placebo_highinc)) {
  tab3_tex <- paste0(tab3_tex,
    sprintf("High-income PP ($>$400\\%% FPL) & %.4f & %.4f & --- & --- \\\\\n",
            robustness$placebo_highinc$overall.att, robustness$placebo_highinc$overall.se))
}
if (!is.null(robustness) && !is.null(robustness$placebo_nonpp)) {
  tab3_tex <- paste0(tab3_tex,
    sprintf("Non-PP low-income women & %.4f & %.4f & --- & --- \\\\\n",
            robustness$placebo_nonpp$overall.att, robustness$placebo_nonpp$overall.se))
}

# Excluding PHE
if (!is.null(robustness) && !is.null(robustness$no_phe)) {
  tab3_tex <- paste0(tab3_tex,
    sprintf("Excluding PHE period (2020--2022) & %.4f & %.4f & --- & --- \\\\\n",
            robustness$no_phe$overall.att, robustness$no_phe$overall.se))
}

# HonestDiD
tab3_tex <- paste0(tab3_tex, "\\midrule\n")
tab3_tex <- paste0(tab3_tex,
  "\\multicolumn{5}{l}{\\textit{HonestDiD Sensitivity (Rambachan-Roth)}} \\\\\n")

if (!is.null(robustness) && !is.null(robustness$honest_did)) {
  for (mbar_name in names(robustness$honest_did)) {
    hd <- robustness$honest_did[[mbar_name]]
    if (!is.null(hd) && nrow(hd) > 0) {
      tab3_tex <- paste0(tab3_tex,
        sprintf("$\\bar{M} = %s$: [%.4f, %.4f] & & & & \\\\\n",
                mbar_name, hd$lb[1], hd$ub[1]))
    }
  }
} else {
  tab3_tex <- paste0(tab3_tex, "Not computed & & & & \\\\\n")
}

# Footer with cluster counts
tab3_tex <- paste0(tab3_tex,
  "\\midrule\n",
  sprintf("Clusters (states) & \\multicolumn{4}{c}{%d} \\\\\n", n_clusters_all),
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{tablenotes}[flushleft]\n",
  "\\small\n",
  "\\item \\textit{Notes:} All CS-DiD estimates use the Callaway \\& Sant'Anna (2021) estimator with never/not-yet-treated control group.\n",
  "DDD uses TWFE with state$\\times$postpartum and year$\\times$postpartum FE.\n",
  "WCB $p$: wild cluster bootstrap $p$-value (Rademacher weights, 9,999 replications).\n",
  sprintf("Perm.~$p$: permutation $p$-value from %d random reassignments of adoption years (two-sided).\n",
          ifelse(!is.null(robustness) && !is.null(robustness$permutation),
                 robustness$permutation$n_perm, 500)),
  "HonestDiD: Rambachan \\& Roth (2023) robust confidence intervals under relative magnitudes assumption.\n",
  "$\\bar{M}$ bounds the ratio of post-treatment trend deviations to the maximum pre-treatment deviation.\n",
  "\\end{tablenotes}\n",
  "\\end{table}\n"
)

writeLines(tab3_tex, file.path(tab_dir, "tab3_robustness.tex"))

# =========================================================
# Table 4: Treatment Dates
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

for (i in 1:mid) {
  left <- sorted_dates[i, ]
  right_idx <- i + mid
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
  sprintf("Status: ``Treated'' = adopted by %d (N=%d); ``NYT'' = not-yet-treated in sample (N=%d); ``Control'' = never adopted (N=%d).\n",
          max_year, n_treated_total, n_nyt, n_control_tab),
  sprintf("Total clusters (states): %d.\n", n_clusters_all),
  "Control group for CS-DiD: NYT + Control states.\n",
  "\\end{tablenotes}\n",
  "\\end{table}\n"
)

writeLines(tab4_tex, file.path(tab_dir, "tab4_adoption.tex"))

# =========================================================
# Table 5: Post-PHE Heterogeneity
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

# By cohort
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

# By expansion status
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

# By race
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

cat("\n=== Tables complete ===\n")
