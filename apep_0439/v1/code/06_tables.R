###############################################################################
# 06_tables.R - Main results tables, balance tests, robustness summaries
# Paper: Where Cultural Borders Cross (apep_0439)
###############################################################################

source("code/00_packages.R")

gender_panel <- readRDS(file.path(data_dir, "gender_panel_final.rds"))
gender_index <- readRDS(file.path(data_dir, "gender_index.rds"))
results <- readRDS(file.path(data_dir, "main_results.rds"))
robustness <- readRDS(file.path(data_dir, "robustness_results.rds"))

# ============================================================================
# TABLE 1: Summary Statistics
# ============================================================================
cat("=== Table 1: Summary Statistics ===\n")

# Panel A: Municipality characteristics by culture group
tab1_data <- gender_index %>%
  filter(culture_group %in% c("French-Protestant", "French-Catholic",
                               "German-Protestant", "German-Catholic")) %>%
  group_by(culture_group) %>%
  summarize(
    N = n(),
    `Gender Index` = round(mean(gender_index), 3),
    `SD` = round(sd(gender_index), 3),
    `Avg Turnout` = round(mean(avg_turnout, na.rm = TRUE), 1),
    `Avg Eligible` = round(mean(avg_eligible, na.rm = TRUE), 0),
    `N Referenda` = round(mean(n_referenda), 1),
    .groups = "drop"
  )

# Write LaTeX table
tab1_tex <- tab1_data %>%
  kbl(format = "latex", booktabs = TRUE,
      caption = "Summary Statistics by Culture Group",
      label = "tab:summary",
      col.names = c("Culture Group", "Municipalities", "Gender Index",
                    "SD", "Turnout (\\%)", "Eligible Voters", "Referenda")) %>%
  kable_styling(latex_options = "hold_position") %>%
  add_header_above(c(" " = 1, " " = 1, "Gender Progressivism" = 2,
                     "Participation" = 2, " " = 1)) %>%
  footnote(general = paste0(
    "Gender progressivism index is the average yes-share across six gender referenda: ",
    "equal rights (1981), maternity insurance (1999), women's representation (2000), ",
    "abortion (2002), paternity leave (2020), marriage for all (2021). ",
    "Culture groups defined by municipal language (BFS) and ",
    "historically predetermined confessional status (16th century Reformation). ",
    "Italian-speaking and mixed-religion municipalities excluded."
  ), threeparttable = TRUE)

writeLines(tab1_tex, file.path(tab_dir, "tab1_summary.tex"))
cat("  Saved tab1_summary.tex\n")

# ============================================================================
# TABLE 2: Main Results - Language and Religion Effects
# ============================================================================
cat("=== Table 2: Main Results ===\n")

tab2_tex <- etable(
  results$m1_lang, results$m1_relig, results$m1_both,
  results$m1_interaction, results$m1_canton,
  title = "Language and Religion Effects on Gender Referendum Voting",
  label = "tab:main",
  dict = c(
    is_frenchTRUE = "French-speaking",
    is_catholicTRUE = "Catholic (historical)",
    "is_frenchTRUE:is_catholicTRUE" = "French $\\times$ Catholic"
  ),
  headers = c("(1)", "(2)", "(3)", "(4)", "(5)"),
  se.below = TRUE,
  fitstat = c("n", "r2", "ar2"),
  notes = paste0(
    "Dependent variable: yes-share on gender referenda. ",
    "All specifications include referendum fixed effects. ",
    "Column (5) adds canton fixed effects, identifying the language effect ",
    "only from bilingual cantons (FR, BE, VS). ",
    "Standard errors clustered at municipality level in parentheses. ",
    "* p<0.10, ** p<0.05, *** p<0.01."
  ),
  tex = TRUE,
  file = file.path(tab_dir, "tab2_main.tex"),
  replace = TRUE
)
cat("  Saved tab2_main.tex\n")

# ============================================================================
# TABLE 3: Culture Group Means (2x2 Factorial)
# ============================================================================
cat("=== Table 3: Culture Group Means ===\n")

group_means <- results$group_means
interaction_test <- results$interaction_test

tab3_data <- group_means %>%
  mutate(
    language = ifelse(grepl("French", culture_4), "French", "German"),
    religion = ifelse(grepl("Catholic", culture_4), "Catholic", "Protestant")
  ) %>%
  select(religion, language, n_mun, mean_yes, sd_yes) %>%
  mutate(
    mean_yes = round(mean_yes, 3),
    sd_yes = round(sd_yes, 3)
  )

# Reshape for 2x2 display
tab3_wide <- tab3_data %>%
  pivot_wider(names_from = language,
              values_from = c(n_mun, mean_yes, sd_yes))

tab3_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Gender Progressivism Index by Culture Group}\n",
  "\\label{tab:culture_groups}\n",
  "\\begin{tabular}{lcccc}\n",
  "\\toprule\n",
  " & \\multicolumn{2}{c}{German-speaking} & \\multicolumn{2}{c}{French-speaking} \\\\\n",
  "\\cmidrule(lr){2-3} \\cmidrule(lr){4-5}\n",
  " & Mean & (SD) & Mean & (SD) \\\\\n",
  "\\midrule\n",
  "Protestant & ", tab3_wide$mean_yes_German[tab3_wide$religion == "Protestant"],
  " & (", tab3_wide$sd_yes_German[tab3_wide$religion == "Protestant"], ")",
  " & ", tab3_wide$mean_yes_French[tab3_wide$religion == "Protestant"],
  " & (", tab3_wide$sd_yes_French[tab3_wide$religion == "Protestant"], ") \\\\\n",
  " & [N=", tab3_wide$n_mun_German[tab3_wide$religion == "Protestant"], "]",
  " & & [N=", tab3_wide$n_mun_French[tab3_wide$religion == "Protestant"], "] & \\\\\n",
  "[4pt]\n",
  "Catholic & ", tab3_wide$mean_yes_German[tab3_wide$religion == "Catholic"],
  " & (", tab3_wide$sd_yes_German[tab3_wide$religion == "Catholic"], ")",
  " & ", tab3_wide$mean_yes_French[tab3_wide$religion == "Catholic"],
  " & (", tab3_wide$sd_yes_French[tab3_wide$religion == "Catholic"], ") \\\\\n",
  " & [N=", tab3_wide$n_mun_German[tab3_wide$religion == "Catholic"], "]",
  " & & [N=", tab3_wide$n_mun_French[tab3_wide$religion == "Catholic"], "] & \\\\\n",
  "\\midrule\n",
  "\\multicolumn{5}{l}{\\textit{Additivity test:}} \\\\\n",
  "Predicted FC (additive) & \\multicolumn{4}{c}{",
  round(interaction_test$predicted_additive, 3), "} \\\\\n",
  "Actual FC & \\multicolumn{4}{c}{",
  round(interaction_test$actual_fc, 3), "} \\\\\n",
  "Interaction (deviation) & \\multicolumn{4}{c}{",
  round(interaction_test$interaction_term, 3), "} \\\\\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{minipage}{0.9\\textwidth}\n",
  "\\footnotesize\n",
  "\\textit{Notes:} Gender progressivism index is the average yes-share across six ",
  "gender referenda (equal rights 1981, maternity insurance 1999, women's representation 2000, ",
  "abortion 2002, paternity leave 2020, marriage for all 2021). ",
  "Confessional status is historically predetermined ",
  "(16th century Reformation). Under additivity, the French-Catholic mean equals ",
  "the sum of the language and religion main effects added to the German-Protestant ",
  "baseline. A positive deviation indicates super-additivity (amplification).\n",
  "\\end{minipage}\n",
  "\\end{table}\n"
)

writeLines(tab3_tex, file.path(tab_dir, "tab3_culture_groups.tex"))
cat("  Saved tab3_culture_groups.tex\n")

# ============================================================================
# TABLE 4: Robustness - Alternative Specifications
# ============================================================================
cat("=== Table 4: Robustness ===\n")

tab4_tex <- etable(
  robustness$alt_clustering$r1_mun,
  robustness$alt_clustering$r1_canton,
  robustness$alt_clustering$r1_twoway,
  robustness$within_canton$r2_canton_fe,
  robustness$no_cities,
  robustness$rural_only,
  robustness$voter_weighted,
  title = "Robustness: Alternative Specifications",
  label = "tab:robustness",
  dict = c(
    is_frenchTRUE = "French-speaking",
    is_catholicTRUE = "Catholic (historical)",
    "is_frenchTRUE:is_catholicTRUE" = "French $\\times$ Catholic"
  ),
  headers = c("Mun Cluster", "Canton Cluster", "Two-way",
              "Canton FE", "No Cities", "Rural Only", "Voter Wtd"),
  se.below = TRUE,
  fitstat = c("n", "r2"),
  notes = paste0(
    "Dependent variable: yes-share on gender referenda. ",
    "Columns (1)--(3) vary clustering level. Column (4) adds canton fixed effects. ",
    "Column (5) excludes municipalities with >50,000 eligible voters. ",
    "Column (6) restricts to municipalities with <10,000 eligible voters. ",
    "Column (7) weights by eligible voters. ",
    "All specifications include referendum fixed effects."
  ),
  tex = TRUE,
  file = file.path(tab_dir, "tab4_robustness.tex"),
  replace = TRUE
)
cat("  Saved tab4_robustness.tex\n")

# ============================================================================
# TABLE 5: Permutation Inference Summary
# ============================================================================
cat("=== Table 5: Permutation Inference ===\n")

tab5_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Permutation Inference}\n",
  "\\label{tab:permutation}\n",
  "\\begin{tabular}{lcc}\n",
  "\\toprule\n",
  " & Language Effect & Interaction \\\\\n",
  "\\midrule\n",
  "Observed coefficient & ", round(robustness$permutation$obs_lang, 4),
  " & ", round(robustness$permutation$obs_interaction, 4), " \\\\\n",
  "Permutation $p$-value & ",
  ifelse(robustness$permutation$perm_p_lang == 0,
         "$<0.002$",
         round(robustness$permutation$perm_p_lang, 3)),
  " & ",
  ifelse(robustness$permutation$perm_p_interaction == 0,
         "$<0.002$",
         round(robustness$permutation$perm_p_interaction, 3)),
  " \\\\\n",
  "N permutations & ", length(robustness$permutation$perm_lang_coefs),
  " & ", length(robustness$permutation$perm_coefs), " \\\\\n",
  "Permutation mean & ",
  round(mean(robustness$permutation$perm_lang_coefs), 4),
  " & ", round(mean(robustness$permutation$perm_coefs), 4), " \\\\\n",
  "Permutation SD & ",
  round(sd(robustness$permutation$perm_lang_coefs), 4),
  " & ", round(sd(robustness$permutation$perm_coefs), 4), " \\\\\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{minipage}{0.85\\textwidth}\n",
  "\\footnotesize\n",
  "\\textit{Notes:} Permutation inference based on 500 random reassignments ",
  "of municipality language and religion labels. Two-sided $p$-values report ",
  "the fraction of permuted coefficients with absolute value at least as large ",
  "as the observed coefficient. Reported as $< 1/500 = 0.002$ when no ",
  "permutation exceeds the observed value.\n",
  "\\end{minipage}\n",
  "\\end{table}\n"
)

writeLines(tab5_tex, file.path(tab_dir, "tab5_permutation.tex"))
cat("  Saved tab5_permutation.tex\n")

# ============================================================================
# TABLE 6: Time-Varying Gaps
# ============================================================================
cat("=== Table 6: Time-varying gaps ===\n")

time_gaps <- readRDS(file.path(data_dir, "time_gaps.rds"))

tab6_data <- time_gaps %>%
  filter(!is.na(lang_gap)) %>%
  mutate(
    Referendum = format(vote_date, "%b %d, %Y"),
    `Language Gap` = paste0(
      round(lang_gap * 100, 1), " pp\n(",
      round(lang_se * 100, 1), ")"),
    `Religion Gap` = ifelse(!is.na(relig_gap),
                            paste0(round(relig_gap * 100, 1), " pp"), "---"),
    Interaction = ifelse(!is.na(interaction),
                         paste0(round(interaction * 100, 1), " pp",
                                ifelse(!is.na(interaction_se),
                                       paste0("\n(", round(interaction_se * 100, 1), ")"),
                                       "")),
                         "---"),
    N = format(n, big.mark = ",")
  ) %>%
  select(Referendum, `Language Gap`, `Religion Gap`, Interaction, N)

tab6_tex <- tab6_data %>%
  kbl(format = "latex", booktabs = TRUE,
      caption = "Cultural Gaps by Gender Referendum",
      label = "tab:time_gaps") %>%
  kable_styling(latex_options = "hold_position") %>%
  footnote(general = paste0(
    "Language gap: French minus German yes-share. Religion gap: Catholic minus ",
    "Protestant yes-share. Interaction: French $\\times$ Catholic coefficient. ",
    "Standard errors in parentheses. ",
    "All from OLS with municipality-level data."
  ), threeparttable = TRUE, escape = FALSE)

writeLines(tab6_tex, file.path(tab_dir, "tab6_time_gaps.tex"))
cat("  Saved tab6_time_gaps.tex\n")

cat("\n=== ALL TABLES GENERATED ===\n")
cat("Tables in", tab_dir, ":\n")
cat(paste("  ", list.files(tab_dir, pattern = "\\.tex$"), collapse = "\n"), "\n")
