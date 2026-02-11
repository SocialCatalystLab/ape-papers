## ============================================================================
## 06_tables.R — All tables for the paper
## APEP Working Paper apep_0225
## ============================================================================

source("00_packages.R")

data_dir <- "../data"
tab_dir <- "../tables"
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

df <- readRDS(file.path(data_dir, "analysis_panel.rds"))
results <- readRDS(file.path(data_dir, "main_results.rds"))
robust <- readRDS(file.path(data_dir, "robustness_results.rds"))

## ---------------------------------------------------------------------------
## Table 1: Summary Statistics
## ---------------------------------------------------------------------------

cat("Table 1: Summary statistics...\n")

# Pre-treatment (2013-2017) vs Post-treatment observations
pre_df <- df %>% filter(year <= 2017)
post_treat <- df %>% filter(treated == 1)
post_control <- df %>% filter(year >= 2018, treated == 0, first_treat == 0)

make_stats <- function(data, label) {
  data %>%
    summarise(
      Group = label,
      N = n(),
      `Synth. Opioid Rate` = sprintf("%.2f (%.2f)", mean(rate_synth_opioid, na.rm=T), sd(rate_synth_opioid, na.rm=T)),
      `All Drug Rate` = sprintf("%.2f (%.2f)", mean(rate_all_drug, na.rm=T), sd(rate_all_drug, na.rm=T)),
      `Cocaine Rate` = sprintf("%.2f (%.2f)", mean(rate_cocaine, na.rm=T), sd(rate_cocaine, na.rm=T)),
      `Stimulant Rate` = sprintf("%.2f (%.2f)", mean(rate_stimulant, na.rm=T), sd(rate_stimulant, na.rm=T)),
      `Poverty Rate` = sprintf("%.3f (%.3f)", mean(poverty_rate, na.rm=T), sd(poverty_rate, na.rm=T)),
      `Unemp. Rate` = sprintf("%.3f (%.3f)", mean(unemp_rate, na.rm=T), sd(unemp_rate, na.rm=T)),
      `Population (M)` = sprintf("%.2f (%.2f)", mean(population/1e6, na.rm=T), sd(population/1e6, na.rm=T))
    )
}

tab1 <- bind_rows(
  make_stats(pre_df, "Pre-treatment (2013-2017)"),
  make_stats(post_treat, "Post-treatment (treated)"),
  make_stats(post_control, "Post-treatment (never-treated)")
)

write_csv(tab1, file.path(tab_dir, "table1_summary.csv"))

# LaTeX version
tab1_tex <- tab1 %>%
  kbl(format = "latex", booktabs = TRUE,
      caption = "Summary Statistics by Treatment Status",
      label = "tab:summary") %>%
  kable_styling(latex_options = c("scale_down")) %>%
  footnote(general = "Death rates per 100,000 population. Standard deviations in parentheses. Pre-treatment period: 2013--2017. Post-treatment includes state-years after FTS legalization. Never-treated states: ID, IN, IA, ND, TX.")

writeLines(tab1_tex, file.path(tab_dir, "table1_summary.tex"))

## ---------------------------------------------------------------------------
## Table 2: Treatment Rollout
## ---------------------------------------------------------------------------

cat("Table 2: Treatment rollout...\n")

fts_laws <- readRDS(file.path(data_dir, "fts_laws.rds"))

tab2 <- fts_laws %>%
  filter(effective_year >= 2018 & effective_year <= 2023) %>%
  arrange(effective_year, state_abb) %>%
  group_by(effective_year) %>%
  summarise(
    `N States` = n(),
    States = paste(state_abb, collapse = ", "),
    .groups = "drop"
  ) %>%
  rename(Year = effective_year)

write_csv(tab2, file.path(tab_dir, "table2_rollout.csv"))

## ---------------------------------------------------------------------------
## Table 3: Main Results (TWFE + CS-DiD)
## ---------------------------------------------------------------------------

cat("Table 3: Main results...\n")

# Use etable from fixest for TWFE results
etable(
  results$twfe_basic, results$twfe_controls, results$twfe_log,
  file = file.path(tab_dir, "table3_twfe.tex"),
  title = "TWFE Estimates: Effect of FTS Legalization on Overdose Deaths",
  label = "tab:twfe",
  style.tex = style.tex("aer"),
  dict = c(
    treated = "FTS Legal",
    naloxone_law = "Naloxone Access Law",
    medicaid_expanded = "Medicaid Expanded",
    poverty_pct = "Poverty Rate (pp)",
    unemp_pct = "Unemployment Rate (pp)"
  ),
  notes = c(
    "Clustered standard errors at state level in parentheses.",
    "All specifications include state and year fixed effects.",
    "Column (3) uses log(rate + 0.1) as the dependent variable."
  ),
  depvar = TRUE,
  fitstat = ~ n + wr2
)

# CS-DiD summary table (manual construction)
cs_results_tab <- tribble(
  ~Specification, ~ATT, ~SE, ~`95\\% CI`, ~`RI p-value`,
  "CS-DiD (never-treated)",
    sprintf("%.3f", results$cs_agg_never$overall.att),
    sprintf("%.3f", results$cs_agg_never$overall.se),
    sprintf("[%.3f, %.3f]",
            results$cs_agg_never$overall.att - 1.96 * results$cs_agg_never$overall.se,
            results$cs_agg_never$overall.att + 1.96 * results$cs_agg_never$overall.se),
    ifelse(!is.null(robust$ri_pvalue), sprintf("%.4f", robust$ri_pvalue), "---"),

  "CS-DiD (not-yet-treated)",
    sprintf("%.3f", results$cs_agg_notyet$overall.att),
    sprintf("%.3f", results$cs_agg_notyet$overall.se),
    sprintf("[%.3f, %.3f]",
            results$cs_agg_notyet$overall.att - 1.96 * results$cs_agg_notyet$overall.se,
            results$cs_agg_notyet$overall.att + 1.96 * results$cs_agg_notyet$overall.se),
    "---",

  "CS-DiD (log, never-treated)",
    sprintf("%.4f", results$cs_log_agg$overall.att),
    sprintf("%.4f", results$cs_log_agg$overall.se),
    sprintf("[%.4f, %.4f]",
            results$cs_log_agg$overall.att - 1.96 * results$cs_log_agg$overall.se,
            results$cs_log_agg$overall.att + 1.96 * results$cs_log_agg$overall.se),
    "---"
)

write_csv(cs_results_tab, file.path(tab_dir, "table3_csdd.csv"))

## ---------------------------------------------------------------------------
## Table 4: Robustness Checks
## ---------------------------------------------------------------------------

cat("Table 4: Robustness checks...\n")

robust_tab <- list()

# Main result
robust_tab[["Main estimate"]] <- c(
  results$cs_agg_never$overall.att, results$cs_agg_never$overall.se
)

# Excluding 2018 cohort
if (!is.null(robust$excl_2018)) {
  robust_tab[["Excluding 2018 cohort (MA, MD, RI)"]] <- c(
    robust$excl_2018$overall.att, robust$excl_2018$overall.se
  )
}

# All drug deaths
if (!is.null(robust$all_drug)) {
  robust_tab[["Outcome: All drug overdose deaths"]] <- c(
    robust$all_drug$overall.att, robust$all_drug$overall.se
  )
}

# Stimulant deaths
if (!is.null(robust$stimulant)) {
  robust_tab[["Outcome: Stimulant deaths"]] <- c(
    robust$stimulant$overall.att, robust$stimulant$overall.se
  )
}

# Placebo: cocaine
if (!is.null(robust$placebo_cocaine)) {
  robust_tab[["Placebo: Cocaine deaths"]] <- c(
    robust$placebo_cocaine$overall.att, robust$placebo_cocaine$overall.se
  )
}

# Placebo: natural opioid
if (!is.null(robust$placebo_natural)) {
  robust_tab[["Placebo: Natural opioid deaths"]] <- c(
    robust$placebo_natural$overall.att, robust$placebo_natural$overall.se
  )
}

tab4 <- tibble(
  Specification = names(robust_tab),
  ATT = sapply(robust_tab, `[`, 1),
  SE = sapply(robust_tab, `[`, 2)
) %>%
  mutate(
    ATT = sprintf("%.3f", ATT),
    SE = sprintf("(%.3f)", SE)
  )

write_csv(tab4, file.path(tab_dir, "table4_robustness.csv"))

## ---------------------------------------------------------------------------
## Table 5: Cohort-Specific ATTs
## ---------------------------------------------------------------------------

cat("Table 5: Cohort-specific ATTs...\n")

cs_group <- results$cs_group

tab5 <- tibble(
  Cohort = cs_group$egt,
  ATT = sprintf("%.3f", cs_group$att.egt),
  SE = sprintf("(%.3f)", cs_group$se.egt),
  `N States` = sapply(cs_group$egt, function(g) {
    sum(df$first_treat == g & df$year == 2020, na.rm = TRUE)
  })
)

write_csv(tab5, file.path(tab_dir, "table5_cohort_atts.csv"))

cat("\n=== All tables saved to", tab_dir, "===\n")
