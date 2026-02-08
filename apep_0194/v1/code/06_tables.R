################################################################################
# 06_tables.R — All Table Generation
# Paper: Digital Exodus or Digital Magnet?
################################################################################

source(file.path(dirname(sys.frame(1)$ofile %||% "00_packages.R"), "00_packages.R"))

cat("=== Generating Tables ===\n")

###############################################################################
# Load results
###############################################################################

qcew_panel <- read_csv(file.path(DATA_DIR, "qcew_panel.csv"),
                       show_col_types = FALSE)
bfs_panel  <- read_csv(file.path(DATA_DIR, "bfs_panel.csv"),
                       show_col_types = FALSE)
privacy_laws <- read_csv(file.path(DATA_DIR, "privacy_law_dates.csv"),
                         show_col_types = FALSE)

twfe_results   <- tryCatch(readRDS(file.path(DATA_DIR, "twfe_results.rds")),
                           error = function(e) list())
bfs_results    <- tryCatch(readRDS(file.path(DATA_DIR, "bfs_results.rds")),
                           error = function(e) list())
wage_results   <- tryCatch(readRDS(file.path(DATA_DIR, "wage_results.rds")),
                           error = function(e) list())
estab_results  <- tryCatch(readRDS(file.path(DATA_DIR, "estab_results.rds")),
                           error = function(e) list())
placebo_results <- tryCatch(readRDS(file.path(DATA_DIR, "placebo_results.rds")),
                            error = function(e) list())
excl_ca_results <- tryCatch(readRDS(file.path(DATA_DIR, "excl_ca_results.rds")),
                            error = function(e) list())
sa_results     <- tryCatch(readRDS(file.path(DATA_DIR, "sa_results.rds")),
                           error = function(e) list())
ri_results     <- tryCatch(readRDS(file.path(DATA_DIR, "ri_results.rds")),
                           error = function(e) NULL)
cs_results     <- tryCatch(readRDS(file.path(DATA_DIR, "cs_results.rds")),
                           error = function(e) list())

###############################################################################
# Helper: Format coefficient with stars
###############################################################################

format_coef <- function(est, se, pval) {
  stars <- ifelse(pval < 0.01, "***",
           ifelse(pval < 0.05, "**",
           ifelse(pval < 0.1, "*", "")))
  sprintf("%.4f%s", est, stars)
}

format_se <- function(se) {
  sprintf("(%.4f)", se)
}

###############################################################################
# Table 1: Summary Statistics
###############################################################################

cat("  Table 1: Summary statistics\n")

info_panel <- qcew_panel %>% filter(industry == "Information")

sum_stats <- info_panel %>%
  group_by(Treatment = ifelse(treated_state == 1, "Treated", "Control")) %>%
  summarize(
    `N States` = n_distinct(state_abbr),
    `N Obs` = n(),
    `Mean Employment` = round(mean(avg_emp, na.rm = TRUE), 0),
    `SD Employment` = round(sd(avg_emp, na.rm = TRUE), 0),
    `Mean Establishments` = round(mean(estabs, na.rm = TRUE), 0),
    `Mean Weekly Wage` = round(mean(avg_weekly_wage, na.rm = TRUE), 0),
    `Mean Log Emp` = round(mean(log_emp, na.rm = TRUE), 3),
    .groups = "drop"
  )

# Write LaTeX table
sum_tex <- kable(sum_stats, format = "latex", booktabs = TRUE,
                 caption = "Summary Statistics: Information Sector (NAICS 51)",
                 label = "tab:summary") %>%
  kable_styling(latex_options = c("hold_position"))

writeLines(sum_tex, file.path(TABLE_DIR, "tab1_summary.tex"))

###############################################################################
# Table 2: Main TWFE Results
###############################################################################

cat("  Table 2: Main TWFE results\n")

if (length(twfe_results) > 0) {
  # Build table using etable from fixest
  tryCatch({
    etable_out <- etable(
      twfe_results,
      tex = TRUE,
      title = "Effect of State Data Privacy Laws on Employment",
      label = "tab:main",
      dict = c(treat = "Privacy Law"),
      se.below = TRUE,
      fitstat = c("n", "wr2", "f"),
      style.tex = style.tex("aer"),
      file = file.path(TABLE_DIR, "tab2_main_twfe.tex")
    )
    cat("  TWFE table saved.\n")
  }, error = function(e) {
    cat("  etable failed:", e$message, "\n")

    # Manual table as fallback
    rows <- list()
    for (ind in names(twfe_results)) {
      fit <- twfe_results[[ind]]
      rows[[length(rows) + 1]] <- tibble(
        Industry = ind,
        Estimate = format_coef(coef(fit)["treat"], se(fit)["treat"], fixest::pvalue(fit)["treat"]),
        SE = format_se(se(fit)["treat"]),
        N = nobs(fit),
        `R2 (within)` = sprintf("%.4f", fitstat(fit, type = "wr2")[[1]])
      )
    }
    main_tab <- bind_rows(rows)
    main_tex <- kable(main_tab, format = "latex", booktabs = TRUE,
                      caption = "Effect of State Data Privacy Laws on Log Employment",
                      label = "tab:main") %>%
      kable_styling(latex_options = c("hold_position")) %>%
      footnote(general = "State and time fixed effects. Standard errors clustered by state.")
    writeLines(main_tex, file.path(TABLE_DIR, "tab2_main_twfe.tex"))
  })
}

###############################################################################
# Table 3: CS-DiD Aggregate ATTs
###############################################################################

cat("  Table 3: CS-DiD ATTs\n")

if (length(cs_results) > 0) {
  cs_rows <- list()
  for (ind in names(cs_results)) {
    tryCatch({
      agg <- aggte(cs_results[[ind]], type = "simple")
      cs_rows[[length(cs_rows) + 1]] <- tibble(
        Industry = ind,
        ATT = sprintf("%.4f", agg$overall.att),
        SE = sprintf("(%.4f)", agg$overall.se),
        `95% CI` = sprintf("[%.4f, %.4f]",
                           agg$overall.att - 1.96 * agg$overall.se,
                           agg$overall.att + 1.96 * agg$overall.se)
      )
    }, error = function(e) {
      cat("  CS aggregation failed for", ind, "\n")
    })
  }

  if (length(cs_rows) > 0) {
    cs_tab <- bind_rows(cs_rows)
    cs_tex <- kable(cs_tab, format = "latex", booktabs = TRUE,
                    caption = "Callaway-Sant'Anna Aggregate ATT Estimates",
                    label = "tab:cs_att") %>%
      kable_styling(latex_options = c("hold_position")) %>%
      footnote(general = "Doubly robust estimator with never-treated as control group. Standard errors clustered by state.")
    writeLines(cs_tex, file.path(TABLE_DIR, "tab3_cs_att.tex"))
    cat("  CS-DiD table saved.\n")
  }
}

###############################################################################
# Table 4: BFS Business Applications
###############################################################################

cat("  Table 4: BFS results\n")

if (length(bfs_results) > 0) {
  bfs_rows <- list()
  for (sec in names(bfs_results)) {
    fit <- bfs_results[[sec]]
    bfs_rows[[length(bfs_rows) + 1]] <- tibble(
      Sector = sec,
      Estimate = format_coef(coef(fit)["treat"], se(fit)["treat"], fixest::pvalue(fit)["treat"]),
      SE = format_se(se(fit)["treat"]),
      N = nobs(fit)
    )
  }

  bfs_tab <- bind_rows(bfs_rows)
  bfs_tex <- kable(bfs_tab, format = "latex", booktabs = TRUE,
                   caption = "Effect of Privacy Laws on Business Applications (BFS)",
                   label = "tab:bfs") %>%
    kable_styling(latex_options = c("hold_position")) %>%
    footnote(general = "State and time FE. Clustered SEs. Outcome: log quarterly business applications.")
  writeLines(bfs_tex, file.path(TABLE_DIR, "tab4_bfs.tex"))
}

###############################################################################
# Table 5: Robustness — Multi-panel
###############################################################################

cat("  Table 5: Robustness\n")

rob_rows <- list()

# Panel A: Sun-Abraham
if (length(sa_results) > 0) {
  for (ind in names(sa_results)) {
    tryCatch({
      sa_agg <- summary(sa_results[[ind]], agg = "ATT")
      rob_rows[[length(rob_rows) + 1]] <- tibble(
        Panel = "A: Sun-Abraham",
        Industry = ind,
        Estimate = sprintf("%.4f", sa_agg$coeftable[1, 1]),
        SE = sprintf("(%.4f)", sa_agg$coeftable[1, 2])
      )
    }, error = function(e) NULL)
  }
}

# Panel B: Exclude California
if (length(excl_ca_results) > 0) {
  for (ind in names(excl_ca_results)) {
    fit <- excl_ca_results[[ind]]
    rob_rows[[length(rob_rows) + 1]] <- tibble(
      Panel = "B: Exclude CA",
      Industry = ind,
      Estimate = format_coef(coef(fit)["treat"], se(fit)["treat"], fixest::pvalue(fit)["treat"]),
      SE = format_se(se(fit)["treat"])
    )
  }
}

# Panel C: Placebo
if (length(placebo_results) > 0) {
  for (ind in names(placebo_results)) {
    fit <- placebo_results[[ind]]
    rob_rows[[length(rob_rows) + 1]] <- tibble(
      Panel = "C: Placebo",
      Industry = ind,
      Estimate = format_coef(coef(fit)["treat"], se(fit)["treat"], fixest::pvalue(fit)["treat"]),
      SE = format_se(se(fit)["treat"])
    )
  }
}

# Panel D: Randomization Inference
if (!is.null(ri_results)) {
  rob_rows[[length(rob_rows) + 1]] <- tibble(
    Panel = "D: RI",
    Industry = "Information",
    Estimate = sprintf("%.4f", ri_results$actual_beta),
    SE = sprintf("RI p = %.3f", ri_results$ri_pvalue)
  )
}

if (length(rob_rows) > 0) {
  rob_tab <- bind_rows(rob_rows)
  rob_tex <- kable(rob_tab, format = "latex", booktabs = TRUE,
                   caption = "Robustness Checks",
                   label = "tab:robustness") %>%
    kable_styling(latex_options = c("hold_position")) %>%
    pack_rows(index = table(rob_tab$Panel)) %>%
    footnote(general = "Panel A: Sun-Abraham (2021) IW estimator. Panel B: Excludes California. Panel C: Non-tech placebo sectors. Panel D: Fisher randomization inference with 500 permutations.")
  writeLines(rob_tex, file.path(TABLE_DIR, "tab5_robustness.tex"))
}

###############################################################################
# Table 6: Wage and Establishment Effects
###############################################################################

cat("  Table 6: Wage and establishment effects\n")

outcome_rows <- list()

# Wages
if (length(wage_results) > 0) {
  for (ind in names(wage_results)) {
    fit <- wage_results[[ind]]
    outcome_rows[[length(outcome_rows) + 1]] <- tibble(
      Outcome = "Log Wage",
      Industry = ind,
      Estimate = format_coef(coef(fit)["treat"], se(fit)["treat"], fixest::pvalue(fit)["treat"]),
      SE = format_se(se(fit)["treat"]),
      N = nobs(fit)
    )
  }
}

# Establishments
if (length(estab_results) > 0) {
  for (ind in names(estab_results)) {
    fit <- estab_results[[ind]]
    outcome_rows[[length(outcome_rows) + 1]] <- tibble(
      Outcome = "Log Estabs",
      Industry = ind,
      Estimate = format_coef(coef(fit)["treat"], se(fit)["treat"], fixest::pvalue(fit)["treat"]),
      SE = format_se(se(fit)["treat"]),
      N = nobs(fit)
    )
  }
}

if (length(outcome_rows) > 0) {
  outcome_tab <- bind_rows(outcome_rows)
  outcome_tex <- kable(outcome_tab, format = "latex", booktabs = TRUE,
                       caption = "Privacy Law Effects on Wages and Establishments",
                       label = "tab:outcomes") %>%
    kable_styling(latex_options = c("hold_position")) %>%
    footnote(general = "TWFE with state and time FE. Clustered SEs by state.")
  writeLines(outcome_tex, file.path(TABLE_DIR, "tab6_wages_estabs.tex"))
}

###############################################################################
# Table A1: Treatment Timing (Appendix)
###############################################################################

cat("  Table A1: Treatment timing\n")

treat_tab <- privacy_laws %>%
  mutate(
    `Effective Date` = format(effective_date, "%B %d, %Y"),
    `Enacted Date` = format(enacted_date, "%B %d, %Y")
  ) %>%
  select(State = state, Abbreviation = state_abbr,
         `Enacted Date`, `Effective Date`) %>%
  arrange(privacy_laws$effective_date)

treat_tex <- kable(treat_tab, format = "latex", booktabs = TRUE,
                   caption = "State Comprehensive Data Privacy Laws: Treatment Timing",
                   label = "tab:treatment_timing") %>%
  kable_styling(latex_options = c("hold_position", "scale_down"))

writeLines(treat_tex, file.path(TABLE_DIR, "tabA1_treatment_timing.tex"))

###############################################################################
# Done
###############################################################################

cat("\nTables saved to:", TABLE_DIR, "\n")
cat("Files:", paste(list.files(TABLE_DIR, pattern = "\\.tex$"), collapse = ", "), "\n")
cat("\n=== Table generation complete ===\n")
