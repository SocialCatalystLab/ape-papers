# ============================================================================
# 04_robustness.R
# State Minimum Wage and Business Formation
# Robustness checks and sensitivity analyses
# ============================================================================

source("00_packages.R")

data_dir <- "../data/"
tables_dir <- "../tables/"

# ============================================================================
# 1. Load data
# ============================================================================

cat("Loading analysis data...\n")

analysis_panel <- read_csv(paste0(data_dir, "analysis_panel.csv"), show_col_types = FALSE) %>%
  mutate(
    state_fe = as.factor(state_abbr),
    ym_fe = as.factor(ym),
    year_fe = as.factor(year),
    month_fe = as.factor(month)
  )

# ============================================================================
# 2. Placebo Test: Lead of Treatment
# ============================================================================

cat("\n=== Placebo Test: 1-Year Lead ===\n")

# Create lead of MW variable (what the MW will be in 12 months)
placebo_data <- analysis_panel %>%
  arrange(state_abbr, year, month) %>%
  group_by(state_abbr) %>%
  mutate(
    log_real_mw_lead12 = lead(log_real_mw, 12),
    above_federal_lead12 = lead(above_federal, 12)
  ) %>%
  ungroup() %>%
  filter(!is.na(log_real_mw_lead12))

# Placebo regression - lead should not predict current outcomes
placebo_continuous <- feols(
  log_BA ~ log_real_mw_lead12 | state_fe + ym_fe,
  data = placebo_data,
  cluster = ~state_abbr
)

placebo_binary <- feols(
  log_BA ~ above_federal_lead12 | state_fe + ym_fe,
  data = placebo_data,
  cluster = ~state_abbr
)

cat("\nPlacebo Results (Lead of Treatment):\n")
etable(placebo_continuous, placebo_binary,
       headers = c("Continuous Lead", "Binary Lead"))

# ============================================================================
# 3. Exclude Large States (CA, NY, TX)
# ============================================================================

cat("\n=== Robustness: Exclude Large States ===\n")

robust_exclude_large <- analysis_panel %>%
  filter(!(state_abbr %in% c("CA", "NY", "TX")))

m_exclude_large <- feols(
  log_BA ~ log_real_mw | state_fe + ym_fe,
  data = robust_exclude_large,
  cluster = ~state_abbr
)

cat("Excluding CA, NY, TX:\n")
etable(m_exclude_large)

# ============================================================================
# 4. Exclude Recession Years
# ============================================================================

cat("\n=== Robustness: Exclude Recession Years ===\n")

robust_no_recession <- analysis_panel %>%
  filter(!(year %in% c(2008, 2009, 2020)))

m_no_recession <- feols(
  log_BA ~ log_real_mw | state_fe + ym_fe,
  data = robust_no_recession,
  cluster = ~state_abbr
)

cat("Excluding 2008-2009 and 2020:\n")
etable(m_no_recession)

# ============================================================================
# 5. Alternative Time Fixed Effects
# ============================================================================

cat("\n=== Robustness: Alternative Time FE ===\n")

# Year + Month FE (instead of year-month)
m_year_month <- feols(
  log_BA ~ log_real_mw | state_fe + year_fe + month_fe,
  data = analysis_panel,
  cluster = ~state_abbr
)

# Year FE only (annual variation)
m_year_only <- feols(
  log_BA ~ log_real_mw | state_fe + year_fe,
  data = analysis_panel,
  cluster = ~state_abbr
)

cat("Alternative Time FE:\n")
etable(m_year_month, m_year_only,
       headers = c("Year + Month FE", "Year FE Only"))

# ============================================================================
# 6. Per Capita Outcomes
# ============================================================================

cat("\n=== Robustness: Per Capita ===\n")

# Approximate population from trend (ideally would use actual data)
# For now, use log(BA) which is already controlling for scale

# Alternative: control for state-specific trends
m_state_trends <- feols(
  log_BA ~ log_real_mw | state_fe + ym_fe + state_fe[year],
  data = analysis_panel,
  cluster = ~state_abbr
)

cat("With State-Specific Linear Trends:\n")
etable(m_state_trends)

# ============================================================================
# 7. Different Treatment Definitions
# ============================================================================

cat("\n=== Robustness: Alternative Treatment Definitions ===\n")

# Percent change in MW
analysis_panel <- analysis_panel %>%
  arrange(state_abbr, year, month) %>%
  group_by(state_abbr) %>%
  mutate(
    mw_pct_change = (effective_mw - lag(effective_mw, 12)) / lag(effective_mw, 12) * 100
  ) %>%
  ungroup()

m_pct_change <- feols(
  log_BA ~ mw_pct_change | state_fe + ym_fe,
  data = analysis_panel %>% filter(!is.na(mw_pct_change)),
  cluster = ~state_abbr
)

# MW gap above federal
analysis_panel <- analysis_panel %>%
  mutate(
    federal_mw_gap = effective_mw - 7.25,  # Gap above federal floor
    federal_mw_gap = pmax(federal_mw_gap, 0)
  )

m_gap <- feols(
  log_BA ~ federal_mw_gap | state_fe + ym_fe,
  data = analysis_panel,
  cluster = ~state_abbr
)

cat("Alternative Treatment Definitions:\n")
etable(m_pct_change, m_gap,
       headers = c("% Change YoY", "Gap Above Federal"))

# ============================================================================
# 8. Heterogeneity by Time Period
# ============================================================================

cat("\n=== Heterogeneity: By Time Period ===\n")

# Pre-2015 vs Post-2015 (before and during the $15 MW movement)
m_pre2015 <- feols(
  log_BA ~ log_real_mw | state_fe + ym_fe,
  data = analysis_panel %>% filter(year < 2015),
  cluster = ~state_abbr
)

m_post2015 <- feols(
  log_BA ~ log_real_mw | state_fe + ym_fe,
  data = analysis_panel %>% filter(year >= 2015),
  cluster = ~state_abbr
)

cat("By Time Period:\n")
etable(m_pre2015, m_post2015,
       headers = c("Pre-2015", "Post-2015"))

# ============================================================================
# 9. Compile Robustness Summary
# ============================================================================

cat("\n=== Compiling Robustness Summary ===\n")

# Main specification for comparison
m_main <- feols(
  log_BA ~ log_real_mw | state_fe + ym_fe,
  data = analysis_panel,
  cluster = ~state_abbr
)

robustness_summary <- tibble(
  specification = c(
    "Main (TWFE)",
    "Placebo (Lead 12m)",
    "Exclude CA, NY, TX",
    "Exclude Recession Years",
    "Year + Month FE",
    "State-Specific Trends",
    "% Change Treatment",
    "Gap Above Federal",
    "Pre-2015 Only",
    "Post-2015 Only"
  ),
  coefficient = c(
    coef(m_main)["log_real_mw"],
    coef(placebo_continuous)["log_real_mw_lead12"],
    coef(m_exclude_large)["log_real_mw"],
    coef(m_no_recession)["log_real_mw"],
    coef(m_year_month)["log_real_mw"],
    coef(m_state_trends)["log_real_mw"],
    coef(m_pct_change)["mw_pct_change"],
    coef(m_gap)["federal_mw_gap"],
    coef(m_pre2015)["log_real_mw"],
    coef(m_post2015)["log_real_mw"]
  ),
  se = c(
    se(m_main)["log_real_mw"],
    se(placebo_continuous)["log_real_mw_lead12"],
    se(m_exclude_large)["log_real_mw"],
    se(m_no_recession)["log_real_mw"],
    se(m_year_month)["log_real_mw"],
    se(m_state_trends)["log_real_mw"],
    se(m_pct_change)["mw_pct_change"],
    se(m_gap)["federal_mw_gap"],
    se(m_pre2015)["log_real_mw"],
    se(m_post2015)["log_real_mw"]
  )
) %>%
  mutate(
    t_stat = coefficient / se,
    p_value = 2 * (1 - pnorm(abs(t_stat))),
    significant = p_value < 0.05
  )

print(robustness_summary)
write_csv(robustness_summary, paste0(tables_dir, "robustness_summary.csv"))

# ============================================================================
# 10. Save robustness table for LaTeX
# ============================================================================

sink(paste0(tables_dir, "robustness.tex"))
cat("\\begin{table}[htbp]\n")
cat("\\centering\n")
cat("\\caption{Robustness Checks}\n")
cat("\\label{tab:robustness}\n")
cat("\\begin{tabular}{lcc}\n")
cat("\\toprule\n")
cat("Specification & Coefficient & SE \\\\\n")
cat("\\midrule\n")

for (i in 1:nrow(robustness_summary)) {
  stars <- ifelse(robustness_summary$p_value[i] < 0.01, "***",
           ifelse(robustness_summary$p_value[i] < 0.05, "**",
           ifelse(robustness_summary$p_value[i] < 0.1, "*", "")))

  cat(sprintf("%s & %.4f%s & (%.4f) \\\\\n",
      robustness_summary$specification[i],
      robustness_summary$coefficient[i],
      stars,
      robustness_summary$se[i]))
}

cat("\\bottomrule\n")
cat("\\end{tabular}\n")
cat("\\begin{tablenotes}\n")
cat("\\small\n")
cat("\\item Notes: * p<0.1, ** p<0.05, *** p<0.01. Standard errors clustered at state level.\n")
cat("\\end{tablenotes}\n")
cat("\\end{table}\n")
sink()

cat("\nRobustness analysis complete!\n")
