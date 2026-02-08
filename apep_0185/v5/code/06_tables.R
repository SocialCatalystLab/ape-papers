################################################################################
# 06_tables.R
# Social Network Minimum Wage Exposure - REVISED IDENTIFICATION STRATEGY
#
# Input:  data/analysis_panel.rds, data/main_results.rds
# Output: tables/tab*.tex
################################################################################

source("00_packages.R")

cat("=== Generating Tables ===\n\n")

# ============================================================================
# 1. Load Data
# ============================================================================

panel <- readRDS("../data/analysis_panel.rds")
results <- readRDS("../data/main_results.rds")
state_mw <- readRDS("../data/state_mw_panel.rds")

cat("Data loaded.\n")

# Create tables directory
dir.create("../tables", showWarnings = FALSE)

# Stars function
stars <- function(pval) {
  if (is.na(pval)) return("")
  if (pval < 0.01) return("***")
  if (pval < 0.05) return("**")
  if (pval < 0.1) return("*")
  return("")
}

# ============================================================================
# Table 1: Summary Statistics
# ============================================================================

cat("\nTable 1: Summary statistics...\n")

# Panel summary
panel_summary <- panel %>%
  summarise(
    `Counties` = n_distinct(county_fips),
    `States` = n_distinct(state_fips),
    `Quarters` = n_distinct(yearq),
    `Observations` = format(n(), big.mark = ",")
  )

# Exposure summary (using new variable names)
exposure_summary <- panel %>%
  summarise(
    `Full Network MW Mean` = sprintf("%.3f", mean(network_mw_full, na.rm = TRUE)),
    `Full Network MW SD` = sprintf("%.3f", sd(network_mw_full, na.rm = TRUE)),
    `Out-of-State MW Mean` = sprintf("%.3f", mean(network_mw_out_state, na.rm = TRUE)),
    `Out-of-State MW SD` = sprintf("%.3f", sd(network_mw_out_state, na.rm = TRUE)),
    `Corr (Full, Out-of-State)` = sprintf("%.3f",
      cor(network_mw_full, network_mw_out_state, use = "complete.obs")),
    `Corr (Full, Own-State)` = sprintf("%.3f",
      cor(network_mw_full, own_log_mw, use = "complete.obs"))
  )

# Minimum wage summary
mw_summary <- state_mw %>%
  filter(min_wage > 7.25) %>%
  summarise(
    `States with MW > Federal` = n_distinct(state_fips),
    `Min State MW` = sprintf("$%.2f", min(min_wage)),
    `Max State MW` = sprintf("$%.2f", max(min_wage))
  )

# Combine into table
tab1_data <- tibble(
  Statistic = c(
    "\\textbf{Panel Structure}", "",
    "Counties", "States", "Quarters", "Observations",
    "", "\\textbf{Network Exposure Variables}", "",
    "Full Network MW (Mean)", "Full Network MW (SD)",
    "Out-of-State Network MW (Mean)", "Out-of-State Network MW (SD)",
    "Corr(Full, Out-of-State)", "Corr(Full, Own-State MW)",
    "", "\\textbf{Minimum Wage Variation}", "",
    "States with MW > Federal", "Min State MW", "Max State MW"
  ),
  Value = c(
    "", "",
    as.character(panel_summary$Counties),
    as.character(panel_summary$States),
    as.character(panel_summary$Quarters),
    panel_summary$Observations,
    "", "", "",
    exposure_summary$`Full Network MW Mean`,
    exposure_summary$`Full Network MW SD`,
    exposure_summary$`Out-of-State MW Mean`,
    exposure_summary$`Out-of-State MW SD`,
    exposure_summary$`Corr (Full, Out-of-State)`,
    exposure_summary$`Corr (Full, Own-State)`,
    "", "", "",
    as.character(mw_summary$`States with MW > Federal`),
    mw_summary$`Min State MW`,
    mw_summary$`Max State MW`
  )
)

tab1_latex <- tab1_data %>%
  kable(
    format = "latex",
    booktabs = TRUE,
    col.names = c("", ""),
    escape = FALSE,
    caption = "Summary Statistics",
    label = "sumstats"
  ) %>%
  kable_styling(latex_options = "hold_position") %>%
  add_footnote(
    paste0("Notes: Full network MW is the SCI-weighted average of log minimum wages ",
           "excluding only own-county. Out-of-state network MW excludes all same-state connections ",
           "and serves as the instrumental variable. Sample period: 2012-2022."),
    notation = "none"
  )

writeLines(tab1_latex, "../tables/tab1_sumstats.tex")
cat("  Saved tab1_sumstats.tex\n")

# ============================================================================
# Table 2: Main Results - OLS vs IV
# ============================================================================

cat("\nTable 2: Main results (OLS vs 2SLS)...\n")

# Extract coefficients from results (using population-weighted specification names)
ols1_coef <- coef(results$ols_pop_simple)[1]
ols1_se <- se(results$ols_pop_simple)[1]
ols1_p <- fixest::pvalue(results$ols_pop_simple)[1]

ols2_coef <- coef(results$ols_pop_statetime)[1]
ols2_se <- se(results$ols_pop_statetime)[1]
ols2_p <- fixest::pvalue(results$ols_pop_statetime)[1]

iv_coef <- coef(results$iv_2sls_pop)[1]
iv_se <- se(results$iv_2sls_pop)[1]
iv_p <- fixest::pvalue(results$iv_2sls_pop)[1]

fs_coef <- coef(results$first_stage_pop)[1]
fs_se <- se(results$first_stage_pop)[1]
first_stage_f <- results$first_stage_f_pop

tab2_data <- tibble(
  ` ` = c(
    "Full Network MW", "",
    "", "County FE", "Time FE", "State $\\times$ Time FE",
    "First Stage F", "Observations"
  ),
  `(1) OLS` = c(
    paste0(sprintf("%.4f", ols1_coef), stars(ols1_p)),
    sprintf("(%.4f)", ols1_se),
    "", "Yes", "Yes", "No",
    "--",
    format(nobs(results$ols_pop_simple), big.mark = ",")
  ),
  `(2) OLS` = c(
    paste0(sprintf("%.4f", ols2_coef), stars(ols2_p)),
    sprintf("(%.4f)", ols2_se),
    "", "Yes", "No", "Yes",
    "--",
    format(nobs(results$ols_pop_statetime), big.mark = ",")
  ),
  `(3) 2SLS` = c(
    paste0(sprintf("%.4f", iv_coef), stars(iv_p)),
    sprintf("(%.4f)", iv_se),
    "", "Yes", "No", "Yes",
    sprintf("%.1f", first_stage_f),
    format(nobs(results$iv_2sls_pop), big.mark = ",")
  )
)

tab2_latex <- tab2_data %>%
  kable(
    format = "latex",
    booktabs = TRUE,
    escape = FALSE,
    caption = "Main Results: Effect of Network Minimum Wage on Employment",
    label = "mainresults",
    align = c("l", "c", "c", "c")
  ) %>%
  kable_styling(latex_options = "hold_position") %>%
  add_footnote(
    paste0("Notes: Dependent variable is log employment. Full Network MW is ",
           "SCI-weighted average of log minimum wages excluding only own-county. ",
           "Column (3) instruments Full Network MW with Out-of-State Network MW ",
           "(excludes all same-state connections). ",
           "Standard errors clustered at state level in parentheses. ",
           "*** p<0.01, ** p<0.05, * p<0.1."),
    notation = "none"
  )

writeLines(tab2_latex, "../tables/tab2_main.tex")
cat("  Saved tab2_main.tex\n")

# ============================================================================
# Table 3: First Stage and Balancedness
# ============================================================================

cat("\nTable 3: First stage and balancedness...\n")

# First stage
tab3a_data <- tibble(
  ` ` = c(
    "Out-of-State Network MW", "",
    "", "County FE", "State $\\times$ Time FE",
    "F-statistic", "Observations"
  ),
  `First Stage` = c(
    paste0(sprintf("%.4f", fs_coef), "***"),
    sprintf("(%.4f)", fs_se),
    "", "Yes", "Yes",
    sprintf("%.1f", first_stage_f),
    format(nobs(results$first_stage_pop), big.mark = ",")
  )
)

tab3a_latex <- tab3a_data %>%
  kable(
    format = "latex",
    booktabs = TRUE,
    escape = FALSE,
    caption = "First Stage: Out-of-State Network MW $\\rightarrow$ Full Network MW",
    label = "firststage",
    align = c("l", "c")
  ) %>%
  kable_styling(latex_options = "hold_position") %>%
  add_footnote(
    paste0("Notes: Dependent variable is Full Network MW (log). ",
           "Out-of-State Network MW excludes all same-state SCI connections. ",
           "*** p<0.01."),
    notation = "none"
  )

writeLines(tab3a_latex, "../tables/tab3_firststage.tex")
cat("  Saved tab3_firststage.tex\n")

# ============================================================================
# Table 4: Distance Robustness
# ============================================================================

cat("\nTable 4: Distance robustness...\n")

dist_results <- results$distance_results

if (!is.null(dist_results) && length(dist_results) > 0) {
  # Convert list to data frame
  dist_df <- do.call(rbind, lapply(names(dist_results), function(d) {
    r <- dist_results[[d]]
    data.frame(
      dist = r$threshold,
      fs_f = as.numeric(r$first_stage_f),
      tsls_coef = as.numeric(r$tsls_coef),
      tsls_se = as.numeric(r$tsls_se),
      balance_p = as.numeric(r$balance_p),
      stringsAsFactors = FALSE
    )
  }))

  # Filter to strong instruments only
  tab4_data <- dist_df %>%
    filter(fs_f >= 10) %>%
    mutate(
      `Distance Threshold` = paste0("$\\geq$ ", dist, " km"),
      `First Stage F` = sprintf("%.1f", fs_f),
      `2SLS Coef.` = sprintf("%.4f", tsls_coef),
      `2SLS SE` = sprintf("%.4f", tsls_se),
      `Balance p` = sprintf("%.3f", balance_p)
    ) %>%
    select(`Distance Threshold`, `First Stage F`, `2SLS Coef.`, `2SLS SE`, `Balance p`)

  tab4_latex <- tab4_data %>%
    kable(
      format = "latex",
      booktabs = TRUE,
      escape = FALSE,
      caption = "Distance Robustness: 2SLS Estimates by IV Distance Threshold",
      label = "distance",
      align = c("l", "c", "c", "c", "c")
    ) %>%
    kable_styling(latex_options = "hold_position") %>%
    add_footnote(
      paste0("Notes: Each row uses out-of-state SCI connections beyond the distance threshold ",
             "as the instrument. Balance p-value tests equality of pre-treatment employment across IV quartiles. ",
             "Estimates shown only for specifications with F $>$ 10."),
      notation = "none"
    )

  writeLines(tab4_latex, "../tables/tab4_distance.tex")
  cat("  Saved tab4_distance.tex\n")
}

# ============================================================================
# Table 5: Earnings Outcome
# ============================================================================

cat("\nTable 5: Earnings outcome...\n")

if (!is.null(results$ols_earn_pop) && !is.null(results$iv_earn_pop)) {
  ols_earn_coef <- coef(results$ols_earn_pop)[1]
  ols_earn_se <- se(results$ols_earn_pop)[1]
  ols_earn_p <- fixest::pvalue(results$ols_earn_pop)[1]

  iv_earn_coef <- coef(results$iv_earn_pop)[1]
  iv_earn_se <- se(results$iv_earn_pop)[1]
  iv_earn_p <- fixest::pvalue(results$iv_earn_pop)[1]

  tab5_data <- tibble(
    ` ` = c(
      "Full Network MW", "",
      "", "First Stage F", "Observations"
    ),
    `(1) OLS` = c(
      paste0(sprintf("%.4f", ols_earn_coef), stars(ols_earn_p)),
      sprintf("(%.4f)", ols_earn_se),
      "", "--",
      format(nobs(results$ols_earn_pop), big.mark = ",")
    ),
    `(2) 2SLS` = c(
      paste0(sprintf("%.4f", iv_earn_coef), stars(iv_earn_p)),
      sprintf("(%.4f)", iv_earn_se),
      "", sprintf("%.1f", first_stage_f),
      format(nobs(results$iv_earn_pop), big.mark = ",")
    )
  )

  tab5_latex <- tab5_data %>%
    kable(
      format = "latex",
      booktabs = TRUE,
      escape = FALSE,
      caption = "Effect on Log Earnings",
      label = "earnings",
      align = c("l", "c", "c")
    ) %>%
    kable_styling(latex_options = "hold_position") %>%
    add_footnote(
      paste0("Notes: Dependent variable is log average quarterly earnings. ",
             "Specifications include county and state $\\times$ time fixed effects. ",
             "*** p<0.01, ** p<0.05, * p<0.1."),
      notation = "none"
    )

  writeLines(tab5_latex, "../tables/tab5_earnings.tex")
  cat("  Saved tab5_earnings.tex\n")
}

# ============================================================================
# Table 6: Reduced Form
# ============================================================================

cat("\nTable 6: Reduced form...\n")

if (!is.null(results$reduced_form_pop)) {
  rf_coef <- coef(results$reduced_form_pop)[1]
  rf_se <- se(results$reduced_form_pop)[1]
  rf_p <- fixest::pvalue(results$reduced_form_pop)[1]

  tab6_data <- tibble(
    ` ` = c(
      "Out-of-State Network MW", "",
      "", "County FE", "State $\\times$ Time FE",
      "Observations"
    ),
    `Reduced Form` = c(
      paste0(sprintf("%.4f", rf_coef), stars(rf_p)),
      sprintf("(%.4f)", rf_se),
      "", "Yes", "Yes",
      format(nobs(results$reduced_form_pop), big.mark = ",")
    )
  )

  tab6_latex <- tab6_data %>%
    kable(
      format = "latex",
      booktabs = TRUE,
      escape = FALSE,
      caption = "Reduced Form: Out-of-State Network MW $\\rightarrow$ Employment",
      label = "reducedform",
      align = c("l", "c")
    ) %>%
    kable_styling(latex_options = "hold_position") %>%
    add_footnote(
      paste0("Notes: Dependent variable is log employment. ",
             "This is the direct effect of the instrument on the outcome. ",
             "Reduced form coefficient divided by first stage equals 2SLS: ",
             sprintf("%.4f / %.4f = %.4f", rf_coef, fs_coef, rf_coef/fs_coef), "."),
      notation = "none"
    )

  writeLines(tab6_latex, "../tables/tab6_reducedform.tex")
  cat("  Saved tab6_reducedform.tex\n")
}

# ============================================================================
# Summary
# ============================================================================

cat("\n=== Tables Complete ===\n")
cat("Generated tables in ../tables/\n")
