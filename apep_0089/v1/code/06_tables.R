# ==============================================================================
# 06_tables.R
# Generate publication-quality tables
# Paper 111: NP Full Practice Authority and Physician Employment
# ==============================================================================

source("00_packages.R")

# Load data and results
analysis_main <- read_csv(file.path(data_dir, "analysis_main.csv"))
analysis_did <- read_csv(file.path(data_dir, "analysis_did.csv"))
baseline <- read_csv(file.path(data_dir, "baseline_characteristics.csv"))
fpa_dates <- read_csv(file.path(data_dir, "fpa_dates.csv"))
results <- readRDS(file.path(data_dir, "main_results.rds"))
robustness <- readRDS(file.path(data_dir, "robustness_results.rds"))

# ==============================================================================
# TABLE 1: Summary Statistics
# ==============================================================================

cat("Creating Table 1: Summary Statistics...\n")

# Calculate summary stats by treatment status
summary_stats <- analysis_main %>%
  mutate(group = ifelse(ever_treated, "FPA States", "Non-FPA States")) %>%
  group_by(group) %>%
  summarise(
    `N (State-Years)` = n(),
    `N (States)` = n_distinct(state_fips),
    `Physician Employment (Mean)` = mean(employment, na.rm = TRUE),
    `Physician Employment (SD)` = sd(employment, na.rm = TRUE),
    `Establishments (Mean)` = mean(establishments, na.rm = TRUE),
    `Weekly Wage (Mean)` = mean(avg_weekly_wage, na.rm = TRUE),
    `Healthcare Sector Emp (Mean)` = mean(healthcare_emp, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_longer(-group, names_to = "Variable", values_to = "value") %>%
  pivot_wider(names_from = group, values_from = value)

# Add difference column
summary_stats <- summary_stats %>%
  mutate(
    Difference = `FPA States` - `Non-FPA States`
  )

# Format numbers
summary_stats_formatted <- summary_stats %>%
  mutate(across(where(is.numeric), ~case_when(
    Variable %in% c("N (State-Years)", "N (States)") ~ format(round(.), big.mark = ","),
    TRUE ~ format(round(., 0), big.mark = ",")
  )))

# Create LaTeX table
table1_tex <- summary_stats_formatted %>%
  kbl(format = "latex",
      booktabs = TRUE,
      caption = "Summary Statistics by FPA Status",
      label = "sumstats",
      align = c("l", "r", "r", "r")) %>%
  kable_styling(latex_options = c("hold_position")) %>%
  add_header_above(c(" " = 1, "Treatment" = 1, "Control" = 1, " " = 1)) %>%
  footnote(general = "Notes: Sample includes 50 states plus DC, 2000-2023. FPA States are those that adopted Full Practice Authority for nurse practitioners. Non-FPA States have reduced or restricted practice laws.",
           threeparttable = TRUE)

writeLines(table1_tex, file.path(tab_dir, "table1_summary.tex"))
cat("  Saved: tables/table1_summary.tex\n")

# ==============================================================================
# TABLE 2: FPA Adoption Timeline
# ==============================================================================

cat("Creating Table 2: FPA Adoption Timeline...\n")

adoption_table <- fpa_dates %>%
  filter(fpa_year > 0) %>%
  arrange(fpa_year, state_name) %>%
  select(State = state_name, `Adoption Year` = fpa_year, Source = source) %>%
  mutate(Source = str_trunc(Source, 30))

table2_tex <- adoption_table %>%
  kbl(format = "latex",
      booktabs = TRUE,
      caption = "Full Practice Authority Adoption Dates by State",
      label = "adoption",
      longtable = TRUE) %>%
  kable_styling(latex_options = c("hold_position", "repeat_header")) %>%
  footnote(general = "Notes: FPA = Full Practice Authority. Years indicate when FPA legislation became effective. Sources include AANP State Practice Environment, Campaign for Action, and DePriest et al. (2020).",
           threeparttable = TRUE)

writeLines(table2_tex, file.path(tab_dir, "table2_adoption.tex"))
cat("  Saved: tables/table2_adoption.tex\n")

# ==============================================================================
# TABLE 3: Main Results
# ==============================================================================

cat("Creating Table 3: Main Results...\n")

# Extract coefficients
main_results <- tribble(
  ~Specification, ~Estimate, ~SE, ~`95% CI`, ~N,
  "Callaway-Sant'Anna ATT",
    results$simple_att$estimate,
    results$simple_att$se,
    paste0("[", round(results$simple_att$ci_lower, 3), ", ", round(results$simple_att$ci_upper, 3), "]"),
    nrow(analysis_did),
  "Traditional TWFE",
    coef(results$twfe)["postTRUE"],
    se(results$twfe)["postTRUE"],
    paste0("[", round(coef(results$twfe)["postTRUE"] - 1.96*se(results$twfe)["postTRUE"], 3), ", ",
           round(coef(results$twfe)["postTRUE"] + 1.96*se(results$twfe)["postTRUE"], 3), "]"),
    nrow(analysis_did)
)

# Format
main_results_formatted <- main_results %>%
  mutate(
    Estimate = sprintf("%.4f", Estimate),
    SE = sprintf("(%.4f)", SE),
    N = format(N, big.mark = ",")
  )

table3_tex <- main_results_formatted %>%
  kbl(format = "latex",
      booktabs = TRUE,
      caption = "Effect of FPA Adoption on Physician Employment",
      label = "main",
      align = c("l", "r", "r", "c", "r")) %>%
  kable_styling(latex_options = c("hold_position")) %>%
  footnote(general = "Notes: Dependent variable is log(physician employment). Callaway-Sant'Anna estimates use never-treated states as control group with state-level clustering. TWFE includes state and year fixed effects. Standard errors clustered at state level in parentheses. * p < 0.10, ** p < 0.05, *** p < 0.01.",
           threeparttable = TRUE)

writeLines(table3_tex, file.path(tab_dir, "table3_main.tex"))
cat("  Saved: tables/table3_main.tex\n")

# ==============================================================================
# TABLE 4: Event Study Pre-Trends
# ==============================================================================

cat("Creating Table 4: Event Study Coefficients...\n")

es_table <- results$es_results %>%
  rename(`Event Time` = event_time, ATT = att, SE = se) %>%
  mutate(
    `95% CI` = paste0("[", round(ci_lower, 3), ", ", round(ci_upper, 3), "]"),
    ATT = sprintf("%.4f", ATT),
    SE = sprintf("(%.4f)", SE)
  ) %>%
  select(`Event Time`, ATT, SE, `95% CI`)

table4_tex <- es_table %>%
  kbl(format = "latex",
      booktabs = TRUE,
      caption = "Event Study Coefficients",
      label = "eventstudy",
      align = c("c", "r", "r", "c")) %>%
  kable_styling(latex_options = c("hold_position")) %>%
  pack_rows("Pre-Treatment", 1, sum(results$es_results$event_time < 0)) %>%
  pack_rows("Post-Treatment", sum(results$es_results$event_time < 0) + 1, nrow(results$es_results)) %>%
  footnote(general = "Notes: Callaway-Sant'Anna dynamic aggregate ATT estimates. Event time 0 is the year of FPA adoption. Standard errors clustered at state level.",
           threeparttable = TRUE)

writeLines(table4_tex, file.path(tab_dir, "table4_eventstudy.tex"))
cat("  Saved: tables/table4_eventstudy.tex\n")

# ==============================================================================
# TABLE 5: Robustness Checks
# ==============================================================================

cat("Creating Table 5: Robustness Checks...\n")

robustness_table <- tribble(
  ~Specification, ~Estimate, ~SE, ~N, ~Description,
  "(1) Main (CS-DiD)", results$simple_att$estimate, results$simple_att$se,
      nrow(analysis_did), "Baseline specification",
  "(2) Excluding 2021+ Adopters", coef(robustness$sensitivity_recent)["postTRUE"],
      se(robustness$sensitivity_recent)["postTRUE"],
      nrow(analysis_did %>% filter(fpa_year == 0 | fpa_year < 2021)),
      "Remove recent treatment cohorts",
  "(3) Large States Only", coef(robustness$sensitivity_large)["postTRUE"],
      se(robustness$sensitivity_large)["postTRUE"],
      NA, "States with >500k healthcare workers"
) %>%
  mutate(
    Estimate = sprintf("%.4f", Estimate),
    SE = sprintf("(%.4f)", SE),
    N = ifelse(is.na(N), "---", format(N, big.mark = ","))
  )

table5_tex <- robustness_table %>%
  select(-Description) %>%
  kbl(format = "latex",
      booktabs = TRUE,
      caption = "Robustness Checks",
      label = "robust",
      align = c("l", "r", "r", "r")) %>%
  kable_styling(latex_options = c("hold_position")) %>%
  footnote(general = "Notes: All specifications use TWFE with state and year fixed effects except (1) which uses Callaway-Sant'Anna. Standard errors clustered at state level. Placebo tests examine industries that should not be affected by NP scope of practice laws.",
           threeparttable = TRUE)

writeLines(table5_tex, file.path(tab_dir, "table5_robustness.tex"))
cat("  Saved: tables/table5_robustness.tex\n")

# ==============================================================================
# TABLE 6: Heterogeneity Analysis
# ==============================================================================

cat("Creating Table 6: Heterogeneity Analysis...\n")

het_table <- tribble(
  ~Subgroup, ~Estimate, ~SE, ~N,
  "All States", results$simple_att$estimate, results$simple_att$se, nrow(analysis_did),
  "High Physician Intensity", coef(robustness$het_high)["postTRUE"],
      se(robustness$het_high)["postTRUE"], NA,
  "Low Physician Intensity", coef(robustness$het_low)["postTRUE"],
      se(robustness$het_low)["postTRUE"], NA
) %>%
  mutate(
    `P-value` = 2 * pnorm(-abs(as.numeric(Estimate) / as.numeric(SE))),
    Estimate = sprintf("%.4f", Estimate),
    SE = sprintf("(%.4f)", SE),
    `P-value` = sprintf("%.3f", `P-value`),
    N = ifelse(is.na(N), "---", format(N, big.mark = ","))
  )

table6_tex <- het_table %>%
  kbl(format = "latex",
      booktabs = TRUE,
      caption = "Heterogeneity by Baseline Physician Intensity",
      label = "heterogeneity",
      align = c("l", "r", "r", "r", "r")) %>%
  kable_styling(latex_options = c("hold_position")) %>%
  footnote(general = "Notes: Physician intensity is measured as the ratio of physician employment to total healthcare employment in the baseline period (pre-2008). States are split at the median. Standard errors clustered at state level.",
           threeparttable = TRUE)

writeLines(table6_tex, file.path(tab_dir, "table6_heterogeneity.tex"))
cat("  Saved: tables/table6_heterogeneity.tex\n")

# ==============================================================================
# Completion
# ==============================================================================

cat("\n=== All Tables Saved ===\n")
cat("Generated 6 publication-quality tables in tables/\n")
