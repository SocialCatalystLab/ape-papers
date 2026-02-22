###############################################################################
# 06_tables.R - Main results tables, balance tests, robustness summaries
# Paper: Where Cultural Borders Cross (apep_0439)
###############################################################################

source("code/00_packages.R")

gender_panel <- readRDS(file.path(data_dir, "gender_panel_final.rds"))
gender_index <- readRDS(file.path(data_dir, "gender_index.rds"))
results <- readRDS(file.path(data_dir, "main_results.rds"))
robustness <- readRDS(file.path(data_dir, "robustness_results.rds"))

# Helper: format coefficient with significance stars
format_coef_star <- function(est, se, p = NULL) {
  if (is.null(p)) p <- 2 * pnorm(-abs(est / se))
  stars <- ifelse(p < 0.01, "***", ifelse(p < 0.05, "**", ifelse(p < 0.10, "*", "")))
  paste0(sprintf("%.3f", est), stars)
}

format_se_parens <- function(se) {
  paste0("(", sprintf("%.3f", se), ")")
}

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
                    "SD", "Turnout (\\%)", "Eligible Voters", "Mean Ref.")) %>%
  kable_styling(latex_options = "hold_position") %>%
  add_header_above(c(" " = 1, " " = 1, "Gender Progressivism" = 2,
                     "Participation" = 2, " " = 1)) %>%
  footnote(general = paste0(
    "Gender progressivism index is the average yes-share across six gender referenda: ",
    "equal rights (1981), maternity insurance (1999), women's representation (2000), ",
    "abortion (2002), paternity leave (2020), marriage for all (2021). ",
    "Culture groups defined by municipal language (BFS) and ",
    "historically predetermined confessional status (16th century Reformation). ",
    "Italian-speaking municipalities excluded."
  ), threeparttable = TRUE)

writeLines(tab1_tex, file.path(tab_dir, "tab1_summary.tex"))
cat("  Saved tab1_summary.tex\n")

# ============================================================================
# TABLE 2: Main Results - Language and Religion Effects (with Controlled column)
# ============================================================================
cat("=== Table 2: Main Results ===\n")

# Force decimal formatting globally (avoid scientific notation in all etables)
# "r4" = round to 4 decimal places (not 4 significant digits)
setFixest_etable(digits = "r4")

tab2_tex <- etable(
  results$m1_lang, results$m1_relig, results$m1_both,
  results$m1_interaction, results$m1_canton, results$m1_controlled,
  title = "Language and Religion Effects on Gender Referendum Voting",
  label = "tab:main",
  dict = c(
    is_frenchTRUE = "French-speaking",
    is_catholicTRUE = "Catholic (historical)",
    "is_frenchTRUE:is_catholicTRUE" = "French $\\times$ Catholic",
    log_eligible = "Log(eligible voters)",
    avg_turnout = "Avg. turnout"
  ),
  headers = c("(1)", "(2)", "(3)", "(4)", "(5)", "(6)"),
  se.below = TRUE,
  fitstat = c("n", "r2", "ar2"),
  notes = paste0(
    "Dependent variable: yes-share on gender referenda. ",
    "All specifications include referendum fixed effects. ",
    "Column (5) adds canton fixed effects, identifying the language effect ",
    "only from bilingual cantons (FR, BE, VS). ",
    "Column (6) includes municipality-level controls (log eligible voters and ",
    "average turnout as proxies for urbanization and civic engagement). ",
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
  headers = c("(1)", "(2)", "(3)", "(4)", "(5)", "(6)", "(7)"),
  se.below = TRUE,
  fitstat = c("n", "r2"),
  notes = paste0(
    "Dependent variable: yes-share on gender referenda. ",
    "Columns (1)--(3) vary clustering level (municipality, canton, two-way). ",
    "Column (4) adds canton fixed effects. ",
    "Column (5) excludes municipalities with $>$50,000 eligible voters. ",
    "Column (6) restricts to municipalities with $<$10,000 eligible voters. ",
    "Column (7) weights by eligible voters. ",
    "All specifications include referendum fixed effects. ",
    "* $p<0.10$, ** $p<0.05$, *** $p<0.01$."
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

# Format p-values correctly: "< 0.002" when 0 permutations exceed observed
perm_p_lang_str <- if (robustness$permutation$perm_p_lang == 0) {
  paste0("$< ", round(1/length(robustness$permutation$perm_lang_coefs), 4), "$")
} else {
  as.character(round(robustness$permutation$perm_p_lang, 3))
}

perm_p_int_str <- if (robustness$permutation$perm_p_interaction == 0) {
  paste0("$< ", round(1/length(robustness$permutation$perm_coefs), 4), "$")
} else {
  as.character(round(robustness$permutation$perm_p_interaction, 3))
}

tab5_tex <- paste0(
  "\\begin{table}[htbp]\n",
  "\\centering\n",
  "\\caption{Permutation Inference}\n",
  "\\label{tab:permutation}\n",
  "\\begin{tabular}{lcc}\n",
  "\\toprule\n",
  " & Language Effect & Interaction \\\\\n",
  "\\midrule\n",
  "Observed coefficient & ", sprintf("%.4f", robustness$permutation$obs_lang),
  " & ", sprintf("%.4f", robustness$permutation$obs_interaction), " \\\\\n",
  "Permutation $p$-value & ", perm_p_lang_str,
  " & ", perm_p_int_str, " \\\\\n",
  "N permutations & ", length(robustness$permutation$perm_lang_coefs),
  " & ", length(robustness$permutation$perm_coefs), " \\\\\n",
  "Permutations exceeding observed & ", robustness$permutation$n_exceed_lang,
  " & ", robustness$permutation$n_exceed_interaction, " \\\\\n",
  "Permutation mean & ",
  sprintf("%.4f", mean(robustness$permutation$perm_lang_coefs)),
  " & ", sprintf("%.4f", mean(robustness$permutation$perm_coefs)), " \\\\\n",
  "Permutation SD & ",
  sprintf("%.4f", sd(robustness$permutation$perm_lang_coefs)),
  " & ", sprintf("%.4f", sd(robustness$permutation$perm_coefs)), " \\\\\n",
  "\\bottomrule\n",
  "\\end{tabular}\n",
  "\\begin{minipage}{0.85\\textwidth}\n",
  "\\footnotesize\n",
  "\\textit{Notes:} Permutation inference based on 500 random reassignments ",
  "of municipality language and religion labels. Two-sided $p$-values report ",
  "the fraction of permuted coefficients with absolute value at least as large ",
  "as the observed coefficient. Reported as $< 1/N$ when no ",
  "permutation exceeds the observed value.\n",
  "\\end{minipage}\n",
  "\\end{table}\n"
)

writeLines(tab5_tex, file.path(tab_dir, "tab5_permutation.tex"))
cat("  Saved tab5_permutation.tex\n")

# ============================================================================
# TABLE 6: Time-Varying Gaps (with SEs and significance stars)
# ============================================================================
cat("=== Table 6: Time-varying gaps ===\n")

time_gaps <- readRDS(file.path(data_dir, "time_gaps.rds"))

tab6_data <- time_gaps %>%
  filter(!is.na(lang_gap)) %>%
  mutate(
    # Compute p-values for significance stars
    lang_p = 2 * pnorm(-abs(lang_gap / lang_se)),
    lang_stars = ifelse(lang_p < 0.01, "***", ifelse(lang_p < 0.05, "**", ifelse(lang_p < 0.10, "*", ""))),
    relig_p = ifelse(!is.na(relig_gap) & !is.na(relig_se),
                     2 * pnorm(-abs(relig_gap / relig_se)), NA),
    relig_stars = ifelse(is.na(relig_p), "",
                         ifelse(relig_p < 0.01, "***",
                                ifelse(relig_p < 0.05, "**",
                                       ifelse(relig_p < 0.10, "*", "")))),
    int_p = ifelse(!is.na(interaction) & !is.na(interaction_se),
                   2 * pnorm(-abs(interaction / interaction_se)), NA),
    int_stars = ifelse(is.na(int_p), "",
                       ifelse(int_p < 0.01, "***",
                              ifelse(int_p < 0.05, "**",
                                     ifelse(int_p < 0.10, "*", "")))),
    # Format: coefficient with stars on line 1, SE in parens on line 2
    Referendum = format(vote_date, "%b %d, %Y"),
    `Language Gap` = paste0(
      sprintf("%.1f", lang_gap * 100), lang_stars
    ),
    `Lang SE` = paste0("(", sprintf("%.1f", lang_se * 100), ")"),
    `Religion Gap` = ifelse(!is.na(relig_gap),
                            paste0(sprintf("%.1f", relig_gap * 100), relig_stars),
                            "---"),
    `Relig SE` = ifelse(!is.na(relig_se),
                        paste0("(", sprintf("%.1f", relig_se * 100), ")"),
                        ""),
    `Interaction` = ifelse(!is.na(interaction),
                           paste0(sprintf("%.1f", interaction * 100), int_stars),
                           "---"),
    `Int SE` = ifelse(!is.na(interaction_se),
                      paste0("(", sprintf("%.1f", interaction_se * 100), ")"),
                      ""),
    N = format(n, big.mark = ",")
  )

# Build LaTeX table manually for proper formatting with SEs below coefficients
tab6_tex_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Cultural Gaps by Gender Referendum}",
  "\\label{tab:time_gaps}",
  "\\begin{tabular}{lccccccc}",
  "\\toprule",
  " & \\multicolumn{2}{c}{Language Gap} & \\multicolumn{2}{c}{Religion Gap} & \\multicolumn{2}{c}{Interaction} & \\\\",
  "\\cmidrule(lr){2-3} \\cmidrule(lr){4-5} \\cmidrule(lr){6-7}",
  "Referendum & Coef & (SE) & Coef & (SE) & Coef & (SE) & N \\\\"
)
tab6_tex_lines <- c(tab6_tex_lines, "\\midrule")

for (i in seq_len(nrow(tab6_data))) {
  row <- tab6_data[i, ]
  line <- paste0(
    row$Referendum, " & ",
    row$`Language Gap`, " & ", row$`Lang SE`, " & ",
    row$`Religion Gap`, " & ", row$`Relig SE`, " & ",
    row$Interaction, " & ", row$`Int SE`, " & ",
    row$N, " \\\\"
  )
  tab6_tex_lines <- c(tab6_tex_lines, line)
}

tab6_tex_lines <- c(tab6_tex_lines,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{minipage}{0.95\\textwidth}",
  "\\footnotesize",
  paste0("\\textit{Notes:} Language gap: French minus German yes-share (pp). ",
         "Religion gap: Catholic minus Protestant yes-share (pp). ",
         "Interaction: French $\\times$ Catholic coefficient (pp). ",
         "Standard errors in parentheses from OLS with municipality-level data. ",
         "* $p<0.10$, ** $p<0.05$, *** $p<0.01$."),
  "\\end{minipage}",
  "\\end{table}"
)

writeLines(tab6_tex_lines, file.path(tab_dir, "tab6_time_gaps.tex"))
cat("  Saved tab6_time_gaps.tex\n")

cat("\n=== ALL TABLES GENERATED ===\n")
cat("Tables in", tab_dir, ":\n")
cat(paste("  ", list.files(tab_dir, pattern = "\\.tex$"), collapse = "\n"), "\n")
