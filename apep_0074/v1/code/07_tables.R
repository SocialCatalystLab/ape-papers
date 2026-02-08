# ============================================================
# 07_tables.R - Generate LaTeX Tables
# ============================================================

source("00_packages.R")

cat("=== Generating Tables ===\n")

# Ensure tables directory exists
dir.create("../tables", showWarnings = FALSE)

# Load data and results
df <- readRDS("../data/analysis_data.rds")
results <- readRDS("../data/main_results.rds")
robustness <- readRDS("../data/robustness_results.rds")

# ============================================================
# Table 1: ERPO Adoption Timeline
# ============================================================

cat("Creating Table 1: ERPO Adoption...\n")

erpo_table <- tribble(
  ~State, ~`Effective Date`, ~`Treatment Year`, ~`Pre-Treatment Years`, ~`Post-Treatment Years`,
  "Connecticut", "Oct 1999", "2000", "0 (pre-sample)", "13 (2005-2017)",
  "Indiana", "Jul 2005", "2006", "1", "12",
  "California", "Jan 2016", "2016", "11", "2",
  "Washington", "Dec 2016", "2017", "12", "1",
  "Oregon", "Jan 2018", "2018", "13", "0 (post-sample)",
  "Florida", "Mar 2018", "2019", "13", "0 (post-sample)",
  "Vermont", "Apr 2018", "2019", "13", "0 (post-sample)",
  "Maryland", "Oct 2018", "2019", "13", "0 (post-sample)",
  "Rhode Island", "Jun 2018", "2019", "13", "0 (post-sample)",
  "New Jersey", "Sep 2018", "2019", "13", "0 (post-sample)",
  "Delaware", "Dec 2018", "2019", "13", "0 (post-sample)",
  "Massachusetts", "Jul 2018", "2019", "13", "0 (post-sample)",
  "Illinois", "Jan 2019", "2019", "13", "0 (post-sample)"
)

# Write LaTeX table
cat("\\begin{table}[htbp]
\\centering
\\caption{ERPO Law Adoption Timeline}
\\label{tab:adoption}
\\begin{tabular}{lcccc}
\\toprule
State & Effective Date & Treatment Year & Pre-Years & Post-Years \\\\
\\midrule
",
file = "../tables/tab1_adoption.tex")

for (i in 1:nrow(erpo_table)) {
  cat(paste(erpo_table[i,], collapse = " & "), " \\\\\n",
      file = "../tables/tab1_adoption.tex", append = TRUE)
}

cat("\\bottomrule
\\end{tabular}
\\begin{tablenotes}
\\small
\\item Notes: Treatment year defined as first full calendar year with ERPO in effect.
Pre- and post-treatment years calculated for 2005-2017 sample period.
States adopting after 2017 have no post-treatment observations in our data.
\\end{tablenotes}
\\end{table}
",
file = "../tables/tab1_adoption.tex", append = TRUE)

# ============================================================
# Table 2: Summary Statistics
# ============================================================

cat("Creating Table 2: Summary Statistics...\n")

# By treatment status
summ_stats <- df %>%
  mutate(
    Group = case_when(
      first_treat == 0 ~ "Never Treated",
      first_treat <= 2006 ~ "Early Adopters",
      TRUE ~ "Later Adopters"
    )
  ) %>%
  group_by(Group) %>%
  summarise(
    States = n_distinct(state_abbr),
    Observations = n(),
    `Mean Rate` = round(mean(suicide_rate, na.rm = TRUE), 2),
    `SD` = round(sd(suicide_rate, na.rm = TRUE), 2),
    `Min` = round(min(suicide_rate, na.rm = TRUE), 2),
    `Max` = round(max(suicide_rate, na.rm = TRUE), 2),
    .groups = "drop"
  )

# Write LaTeX
cat("\\begin{table}[htbp]
\\centering
\\caption{Summary Statistics by ERPO Adoption Status}
\\label{tab:summ}
\\begin{tabular}{lcccccc}
\\toprule
Group & States & Obs. & Mean & SD & Min & Max \\\\
\\midrule
",
file = "../tables/tab2_summary.tex")

for (i in 1:nrow(summ_stats)) {
  cat(paste(summ_stats[i,], collapse = " & "), " \\\\\n",
      file = "../tables/tab2_summary.tex", append = TRUE)
}

# Overall
overall <- df %>%
  summarise(
    States = n_distinct(state_abbr),
    Observations = n(),
    `Mean Rate` = round(mean(suicide_rate, na.rm = TRUE), 2),
    `SD` = round(sd(suicide_rate, na.rm = TRUE), 2),
    `Min` = round(min(suicide_rate, na.rm = TRUE), 2),
    `Max` = round(max(suicide_rate, na.rm = TRUE), 2)
  )

cat("\\midrule\n", file = "../tables/tab2_summary.tex", append = TRUE)
cat(paste("Overall &", paste(overall, collapse = " & ")), " \\\\\n",
    file = "../tables/tab2_summary.tex", append = TRUE)

cat("\\bottomrule
\\end{tabular}
\\begin{tablenotes}
\\small
\\item Notes: Suicide rate is deaths per 100,000 population.
Early adopters: Connecticut (2000) and Indiana (2006).
Later adopters: California (2016) and Washington (2017).
Sample: 2005-2017.
\\end{tablenotes}
\\end{table}
",
file = "../tables/tab2_summary.tex", append = TRUE)

# ============================================================
# Table 3: Main Results
# ============================================================

cat("Creating Table 3: Main Results...\n")

# Extract key results
main_att <- results$agg_simple$overall.att
main_se <- results$agg_simple$overall.se
dyn_att <- results$agg_dynamic$overall.att
dyn_se <- results$agg_dynamic$overall.se
twfe_att <- coef(results$twfe)["treated"]
twfe_se <- se(results$twfe)["treated"]

# Format with stars
format_est <- function(est, se, alpha = 0.05) {
  t_stat <- abs(est / se)
  if (t_stat > qnorm(1 - alpha/2)) {
    return(sprintf("%.3f*", est))
  } else {
    return(sprintf("%.3f", est))
  }
}

cat("\\begin{table}[htbp]
\\centering
\\caption{Effect of ERPO Laws on Suicide Rate}
\\label{tab:main}
\\begin{tabular}{lcccc}
\\toprule
& (1) & (2) & (3) & (4) \\\\
& C-S Simple & C-S Dynamic & C-S Group & TWFE \\\\
\\midrule
",
file = "../tables/tab3_main.tex")

# ATT row
cat(sprintf("ATT & %s & %s & %s & %s \\\\\n",
            format_est(main_att, main_se),
            format_est(dyn_att, dyn_se),
            format_est(results$agg_group$overall.att, results$agg_group$overall.se),
            format_est(twfe_att, twfe_se)),
    file = "../tables/tab3_main.tex", append = TRUE)

# SE row
cat(sprintf("& (%.3f) & (%.3f) & (%.3f) & (%.3f) \\\\\n",
            main_se, dyn_se, results$agg_group$overall.se, twfe_se),
    file = "../tables/tab3_main.tex", append = TRUE)

# 95% CI row
cat(sprintf("95\\%% CI & [%.2f, %.2f] & [%.2f, %.2f] & [%.2f, %.2f] & [%.2f, %.2f] \\\\\n",
            main_att - 1.96*main_se, main_att + 1.96*main_se,
            dyn_att - 1.96*dyn_se, dyn_att + 1.96*dyn_se,
            results$agg_group$overall.att - 1.96*results$agg_group$overall.se,
            results$agg_group$overall.att + 1.96*results$agg_group$overall.se,
            twfe_att - 1.96*twfe_se, twfe_att + 1.96*twfe_se),
    file = "../tables/tab3_main.tex", append = TRUE)

cat("\\midrule
States & 51 & 51 & 51 & 51 \\\\
Years & 2005-2017 & 2005-2017 & 2005-2017 & 2005-2017 \\\\
Observations & 663 & 663 & 663 & 663 \\\\
Treated States & 4 & 4 & 4 & 4 \\\\
\\bottomrule
\\end{tabular}
\\begin{tablenotes}
\\small
\\item Notes: C-S = Callaway-Sant'Anna (2021) heterogeneity-robust estimator.
TWFE = Two-way fixed effects. Standard errors clustered at state level.
* p < 0.05.
\\end{tablenotes}
\\end{table}
",
file = "../tables/tab3_main.tex", append = TRUE)

# ============================================================
# Table 4: Robustness Checks
# ============================================================

cat("Creating Table 4: Robustness...\n")

cat("\\begin{table}[htbp]
\\centering
\\caption{Robustness Checks}
\\label{tab:robust}
\\begin{tabular}{lcc}
\\toprule
Specification & ATT & SE \\\\
\\midrule
",
file = "../tables/tab4_robustness.tex")

# Main result
cat(sprintf("Main (Never-treated, DR) & %.3f & (%.3f) \\\\\n",
            main_att, main_se),
    file = "../tables/tab4_robustness.tex", append = TRUE)

# Robustness specs
cat(sprintf("Not-yet-treated controls & %.3f & (%.3f) \\\\\n",
            robustness$notyet$overall.att, robustness$notyet$overall.se),
    file = "../tables/tab4_robustness.tex", append = TRUE)

cat(sprintf("Exclude Washington & %.3f & (%.3f) \\\\\n",
            robustness$no_wa$overall.att, robustness$no_wa$overall.se),
    file = "../tables/tab4_robustness.tex", append = TRUE)

cat(sprintf("IPW estimation & %.3f & (%.3f) \\\\\n",
            robustness$ipw$overall.att, robustness$ipw$overall.se),
    file = "../tables/tab4_robustness.tex", append = TRUE)

cat(sprintf("Outcome regression & %.3f & (%.3f) \\\\\n",
            robustness$or$overall.att, robustness$or$overall.se),
    file = "../tables/tab4_robustness.tex", append = TRUE)

cat(sprintf("Log outcome & %.3f & (%.3f) \\\\\n",
            robustness$log$overall.att, robustness$log$overall.se),
    file = "../tables/tab4_robustness.tex", append = TRUE)

cat("\\bottomrule
\\end{tabular}
\\begin{tablenotes}
\\small
\\item Notes: All specifications use Callaway-Sant'Anna estimator except where noted.
DR = doubly robust, IPW = inverse probability weighting.
Standard errors clustered at state level.
\\end{tablenotes}
\\end{table}
",
file = "../tables/tab4_robustness.tex", append = TRUE)

# ============================================================
# Table 5: Group-Specific Effects
# ============================================================

cat("Creating Table 5: Group Effects...\n")

grp <- results$agg_group

cat("\\begin{table}[htbp]
\\centering
\\caption{Cohort-Specific Treatment Effects}
\\label{tab:group}
\\begin{tabular}{lccccc}
\\toprule
Cohort & State & ATT & SE & 95\\% CI & Post-Periods \\\\
\\midrule
",
file = "../tables/tab5_groups.tex")

cohorts <- data.frame(
  group = grp$egt,
  att = grp$att.egt,
  se = grp$se.egt
) %>%
  mutate(
    state = case_when(
      group == 2006 ~ "Indiana",
      group == 2016 ~ "California",
      group == 2017 ~ "Washington"
    ),
    post = case_when(
      group == 2006 ~ "12",
      group == 2016 ~ "2",
      group == 2017 ~ "1"
    )
  )

for (i in 1:nrow(cohorts)) {
  ci_low <- cohorts$att[i] - 1.96 * cohorts$se[i]
  ci_high <- cohorts$att[i] + 1.96 * cohorts$se[i]
  sig <- ifelse(ci_low > 0 | ci_high < 0, "*", "")
  cat(sprintf("%d & %s & %.3f%s & (%.3f) & [%.2f, %.2f] & %s \\\\\n",
              cohorts$group[i], cohorts$state[i],
              cohorts$att[i], sig, cohorts$se[i],
              ci_low, ci_high, cohorts$post[i]),
      file = "../tables/tab5_groups.tex", append = TRUE)
}

cat("\\bottomrule
\\end{tabular}
\\begin{tablenotes}
\\small
\\item Notes: ATT = average treatment effect on the treated for each cohort.
Callaway-Sant'Anna (2021) estimator with doubly robust estimation.
* p < 0.05.
\\end{tablenotes}
\\end{table}
",
file = "../tables/tab5_groups.tex", append = TRUE)

cat("\n=== All Tables Saved ===\n")
cat("Files in tables/:\n")
list.files("../tables")
