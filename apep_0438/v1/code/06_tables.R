###############################################################################
# 06_tables.R — All tables for the paper
# Paper: Secret Ballots and Women's Political Voice (apep_0438)
###############################################################################

# Source packages from same directory
script_args <- commandArgs(trailingOnly = FALSE)
script_path <- grep("--file=", script_args, value = TRUE)
if (length(script_path) > 0) {
  script_dir_local <- dirname(normalizePath(sub("--file=", "", script_path)))
} else {
  script_dir_local <- getwd()
}
source(file.path(script_dir_local, "00_packages.R"))

cat("\n=== PHASE 6: TABLES ===\n\n")

# --- Load data ---------------------------------------------------------------
panel       <- readRDS(file.path(data_dir, "panel.rds"))
ar_ai_panel <- readRDS(file.path(data_dir, "ar_ai_panel.rds"))
border_gem  <- readRDS(file.path(data_dir, "border_gemeinden.rds"))
results     <- readRDS(file.path(data_dir, "main_results.rds"))
robustness  <- readRDS(file.path(data_dir, "robustness_results.rds"))

# ============================================================================
# Table 1: Summary Statistics
# ============================================================================
cat("Creating Table 1: Summary statistics...\n")

# Summary by canton group
summary_data <- ar_ai_panel %>%
  mutate(side = ifelse(ar_side, "AR (Abolished)", "AI (Active LG)")) %>%
  group_by(side) %>%
  summarise(
    `N Gemeinden` = n_distinct(gem_id),
    `N Referendum-Obs` = n(),
    `Mean Yes-Share` = sprintf("%.3f", mean(yes_share, na.rm = TRUE)),
    `SD Yes-Share` = sprintf("%.3f", sd(yes_share, na.rm = TRUE)),
    `Mean Turnout` = sprintf("%.3f", mean(turnout, na.rm = TRUE)),
    `Gender Ref Obs` = sum(gender_related, na.rm = TRUE),
    .groups = "drop"
  )

# Add pre/post breakdown
pre_post <- ar_ai_panel %>%
  mutate(
    side = ifelse(ar_side, "AR (Abolished)", "AI (Active LG)"),
    period = ifelse(post_abolition, "Post-1997", "Pre-1997")
  ) %>%
  group_by(side, period) %>%
  summarise(
    `Mean Yes-Share` = sprintf("%.3f", mean(yes_share, na.rm = TRUE)),
    `N Obs` = n(),
    .groups = "drop"
  ) %>%
  pivot_wider(names_from = period, values_from = c(`Mean Yes-Share`, `N Obs`))

# Write LaTeX table
tab1_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Summary Statistics: AR-AI Border Sample}",
  "\\label{tab:summary}",
  "\\begin{tabular}{lcc}",
  "\\toprule",
  " & AR (Abolished 1997) & AI (Active Landsgemeinde) \\\\",
  "\\midrule",
  "\\multicolumn{3}{l}{\\textit{Panel A: Full Sample}} \\\\[3pt]"
)

for (i in 1:nrow(summary_data)) {
  row <- summary_data[i, ]
  if (i == 1) {
    vals <- as.character(row[-1])
  } else {
    vals <- as.character(row[-1])
  }
}

# Build table content from summary data
ar_row <- summary_data %>% filter(side == "AR (Abolished)")
ai_row <- summary_data %>% filter(side == "AI (Active LG)")

tab1_lines <- c(tab1_lines,
  paste0("Gemeinden & ", ar_row$`N Gemeinden`, " & ", ai_row$`N Gemeinden`, " \\\\"),
  paste0("Referendum-Observations & ", ar_row$`N Referendum-Obs`, " & ", ai_row$`N Referendum-Obs`, " \\\\"),
  paste0("Mean Yes-Share & ", ar_row$`Mean Yes-Share`, " & ", ai_row$`Mean Yes-Share`, " \\\\"),
  paste0("SD Yes-Share & ", ar_row$`SD Yes-Share`, " & ", ai_row$`SD Yes-Share`, " \\\\"),
  paste0("Mean Turnout & ", ar_row$`Mean Turnout`, " & ", ai_row$`Mean Turnout`, " \\\\"),
  paste0("Gender Referendum Obs & ", ar_row$`Gender Ref Obs`, " & ", ai_row$`Gender Ref Obs`, " \\\\"),
  "\\midrule",
  "\\multicolumn{3}{l}{\\textit{Panel B: Pre/Post Abolition}} \\\\[3pt]"
)

# Pre-1997 means
pre_ar <- ar_ai_panel %>% filter(ar_side, !post_abolition)
pre_ai <- ar_ai_panel %>% filter(!ar_side, !post_abolition)
post_ar <- ar_ai_panel %>% filter(ar_side, post_abolition)
post_ai <- ar_ai_panel %>% filter(!ar_side, post_abolition)

tab1_lines <- c(tab1_lines,
  paste0("Pre-1997 Mean Yes-Share & ",
         sprintf("%.3f", mean(pre_ar$yes_share, na.rm = TRUE)), " & ",
         sprintf("%.3f", mean(pre_ai$yes_share, na.rm = TRUE)), " \\\\"),
  paste0("Post-1997 Mean Yes-Share & ",
         sprintf("%.3f", mean(post_ar$yes_share, na.rm = TRUE)), " & ",
         sprintf("%.3f", mean(post_ai$yes_share, na.rm = TRUE)), " \\\\"),
  paste0("Pre-1997 N & ", nrow(pre_ar), " & ", nrow(pre_ai), " \\\\"),
  paste0("Post-1997 N & ", nrow(post_ar), " & ", nrow(post_ai), " \\\\"),
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} Summary statistics for Gemeinden near the AR-AI canton border. AR (Appenzell Ausserrhoden) abolished its Landsgemeinde in April 1997. AI (Appenzell Innerrhoden) retains the Landsgemeinde. Yes-share is the proportion voting yes on federal referendums. Turnout is the share of eligible voters casting ballots.",
  "\\end{tablenotes}",
  "\\end{table}"
)

writeLines(tab1_lines, file.path(tab_dir, "tab1_summary.tex"))
cat("  Saved tab1_summary.tex\n")

# ============================================================================
# Table 2: Main RDD and DiDisc Results
# ============================================================================
cat("Creating Table 2: Main results...\n")

tab2_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Main Results: Effect of Landsgemeinde Abolition on Referendum Voting}",
  "\\label{tab:main_results}",
  "\\begin{tabular}{lcccc}",
  "\\toprule",
  " & (1) & (2) & (3) & (4) \\\\",
  " & All Votes & All Votes & Gender Votes & Placebo \\\\",
  " & RDD Post & DiDisc & DiDisc & Pre-1997 \\\\",
  "\\midrule"
)

# Extract coefficients from results
specs <- list(
  rdd_post = results$rdd_post,
  didisc_ols = results$didisc_ols,
  didisc_gender = results$didisc_gender,
  placebo_pre = results$placebo_pre
)

for (i in seq_along(specs)) {
  spec <- specs[[i]]
  if (is.null(spec)) {
    tab2_lines <- c(tab2_lines, paste0("Estimate & --- \\\\"))
    next
  }

  if (inherits(spec, "rdrobust")) {
    est <- sprintf("%.4f", spec$coef[1])
    se  <- sprintf("(%.4f)", spec$se[3])
    pval <- spec$pv[3]
    n_obs <- paste0(spec$N_h[1], "/", spec$N_h[2])
  } else if (inherits(spec, "fixest")) {
    ct <- coeftable(spec)
    # Get the interaction term for DiDisc
    int_row <- grep("ar_side.*post_abolition|post_abolition.*ar_side", rownames(ct))
    if (length(int_row) > 0) {
      est <- sprintf("%.4f", ct[int_row[1], 1])
      se  <- sprintf("(%.4f)", ct[int_row[1], 2])
      pval <- ct[int_row[1], 4]
    } else {
      est <- sprintf("%.4f", ct[2, 1])
      se  <- sprintf("(%.4f)", ct[2, 2])
      pval <- ct[2, 4]
    }
    n_obs <- as.character(nobs(spec))
  } else next

  stars <- ifelse(pval < 0.01, "***",
           ifelse(pval < 0.05, "**",
           ifelse(pval < 0.10, "*", "")))

  if (i == 1) {
    tab2_lines <- c(tab2_lines, paste0("Treatment Effect & ", est, stars, " & & & \\\\"))
    tab2_lines <- c(tab2_lines, paste0(" & ", se, " & & & \\\\"))
  }
}

tab2_lines <- c(tab2_lines,
  "\\midrule",
  "Border pair & AR-AI & AR-AI & AR-AI & AR-AI \\\\",
  "Referendum FE & No & Yes & Yes & No \\\\",
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} Column (1) reports the spatial RDD estimate using post-1997 referendums at the AR-AI border. Column (2) reports the difference-in-discontinuities (DiDisc) estimate with referendum fixed effects. Column (3) restricts to gender-related referendums. Column (4) is a placebo test using pre-1997 data (should be zero). Robust bias-corrected standard errors in parentheses. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.",
  "\\end{tablenotes}",
  "\\end{table}"
)

writeLines(tab2_lines, file.path(tab_dir, "tab2_main_results.tex"))
cat("  Saved tab2_main_results.tex\n")

# ============================================================================
# Table 3: Robustness — Bandwidth Sensitivity
# ============================================================================
cat("Creating Table 3: Bandwidth sensitivity...\n")

bw_df <- robustness$bandwidth

if (!is.null(bw_df) && nrow(bw_df) > 0) {
  tab3_lines <- c(
    "\\begin{table}[htbp]",
    "\\centering",
    "\\caption{Robustness: Bandwidth Sensitivity}",
    "\\label{tab:bandwidth}",
    "\\begin{tabular}{cccccc}",
    "\\toprule",
    "BW Multiplier & Bandwidth (km) & Estimate & SE & p-value & N (L/R) \\\\",
    "\\midrule"
  )

  for (i in 1:nrow(bw_df)) {
    row <- bw_df[i, ]
    stars <- ifelse(row$pval < 0.01, "***",
             ifelse(row$pval < 0.05, "**",
             ifelse(row$pval < 0.10, "*", "")))
    tab3_lines <- c(tab3_lines,
      paste0(
        sprintf("%.2f", row$bw_mult), " & ",
        sprintf("%.1f", row$bandwidth), " & ",
        sprintf("%.4f", row$estimate), stars, " & ",
        sprintf("%.4f", row$se), " & ",
        sprintf("%.3f", row$pval), " & ",
        row$n_left, "/", row$n_right, " \\\\"
      )
    )
  }

  tab3_lines <- c(tab3_lines,
    "\\bottomrule",
    "\\end{tabular}",
    "\\begin{tablenotes}[flushleft]",
    "\\small",
    "\\item \\textit{Notes:} BW multiplier of 1.0 corresponds to the MSE-optimal bandwidth from \\citet{calonico2014}. Robust bias-corrected standard errors. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.",
    "\\end{tablenotes}",
    "\\end{table}"
  )

  writeLines(tab3_lines, file.path(tab_dir, "tab3_bandwidth.tex"))
  cat("  Saved tab3_bandwidth.tex\n")
}

# ============================================================================
# Table 4: Individual Border Pair Estimates
# ============================================================================
cat("Creating Table 4: Border pair estimates...\n")

tab4_lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Robustness: Individual Border Pair Estimates}",
  "\\label{tab:border_pairs}",
  "\\begin{tabular}{lccc}",
  "\\toprule",
  "Border Pair & Estimate & p-value & Status \\\\",
  "\\midrule"
)

pair_descriptions <- c(
  "AR-AI" = "AR (abolished 1997) vs AI (active)",
  "AI-SG" = "AI (active) vs SG (never had)",
  "GL-SG" = "GL (active) vs SG (never had)",
  "OW-LU" = "OW (abolished 1998) vs LU (never had)",
  "NW-LU" = "NW (abolished 1996) vs LU (never had)"
)

for (bp in names(robustness$pair_results)) {
  pr <- robustness$pair_results[[bp]]
  desc <- pair_descriptions[bp]
  if (is.null(desc)) desc <- bp

  est <- round(pr$coef[1], 4)
  pval <- round(pr$pv[min(3, nrow(pr$pv))], 3)
  stars <- ifelse(pval < 0.01, "***",
           ifelse(pval < 0.05, "**",
           ifelse(pval < 0.10, "*", "")))

  tab4_lines <- c(tab4_lines,
    paste0(desc, " & ", sprintf("%.4f", est), stars,
           " & ", sprintf("%.3f", pval), " & ",
           ifelse(bp %in% c("AI-SG", "GL-SG"), "Cross-sectional", "DiDisc"), " \\\\")
  )
}

tab4_lines <- c(tab4_lines,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}[flushleft]",
  "\\small",
  "\\item \\textit{Notes:} Spatial RDD estimates for individual border pairs. Post-1997 referendums. Positive estimates indicate higher yes-share on the non-Landsgemeinde side. $^{***}p<0.01$, $^{**}p<0.05$, $^{*}p<0.10$.",
  "\\end{tablenotes}",
  "\\end{table}"
)

writeLines(tab4_lines, file.path(tab_dir, "tab4_border_pairs.tex"))
cat("  Saved tab4_border_pairs.tex\n")

cat("\n✓ All tables generated\n")
