# =============================================================================
# 06_tables.R
# Publication-Quality Tables for Marijuana Legalization DiDisc Paper
# =============================================================================

source("00_packages.R")

# Load results
qwi_border <- readRDS(file.path(data_dir, "qwi_border.rds"))
treatment_dates <- readRDS(file.path(data_dir, "treatment_dates.rds"))
main_results <- readRDS(file.path(data_dir, "main_results.rds"))
industry_df <- readRDS(file.path(data_dir, "industry_results.rds"))

cat("=== Generating Tables ===\n")

# =============================================================================
# Table 1: Treatment Timing
# =============================================================================

cat("Table 1: Treatment Timing\n")

tab1 <- treatment_dates %>%
  select(state_name, election_date, retail_date) %>%
  mutate(
    election_date = format(election_date, "%B %d, %Y"),
    retail_date = format(retail_date, "%B %d, %Y")
  ) %>%
  rename(
    State = state_name,
    `Election Date` = election_date,
    `Retail Opening` = retail_date
  )

# Export to LaTeX
tab1_latex <- kbl(tab1, format = "latex", booktabs = TRUE,
                  caption = "Recreational Marijuana Legalization Timeline",
                  label = "tab:timing") %>%
  kable_styling(latex_options = c("hold_position"))

writeLines(tab1_latex, file.path(tab_dir, "tab1_timing.tex"))

# =============================================================================
# Table 2: Summary Statistics
# =============================================================================

cat("Table 2: Summary Statistics\n")

# Summary by treatment status
summary_stats <- qwi_border %>%
  filter(industry == "00", in_bandwidth) %>%
  group_by(treated) %>%
  summarise(
    `N (county-quarters)` = n(),
    `N (counties)` = n_distinct(county_fips),
    `Mean Earnings` = mean(EarnHirAS, na.rm = TRUE),
    `SD Earnings` = sd(EarnHirAS, na.rm = TRUE),
    `Mean Employment` = mean(Emp, na.rm = TRUE),
    `Mean Hires` = mean(HirA, na.rm = TRUE),
    `Mean Distance (km)` = mean(dist_to_border, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    Group = ifelse(treated, "Treated Border Counties", "Control Border Counties"),
    across(where(is.numeric), ~round(., 2))
  ) %>%
  select(Group, everything(), -treated) %>%
  pivot_longer(-Group, names_to = "Variable", values_to = "value") %>%
  pivot_wider(names_from = Group, values_from = value)

tab2_latex <- kbl(summary_stats, format = "latex", booktabs = TRUE,
                  caption = "Summary Statistics by Treatment Status (100km Bandwidth)",
                  label = "tab:summary") %>%
  kable_styling(latex_options = c("hold_position"))

writeLines(tab2_latex, file.path(tab_dir, "tab2_summary.tex"))

# =============================================================================
# Table 3: Main DiDisc Results
# =============================================================================

cat("Table 3: Main Results\n")

# Create different specifications for comparison
analysis_sample <- qwi_border %>%
  filter(in_bandwidth, industry == "00") %>%
  mutate(
    dist_km = signed_dist,
    treat_post = treated * post
  )

# Specification 1: Simple DiD
spec1 <- feols(
  log_earn_hire ~ treat_post | border_pair + quarter,
  data = analysis_sample,
  cluster = ~border_pair
)

# Specification 2: DiD with controls
spec2 <- feols(
  log_earn_hire ~ treat_post + dist_km + treated:dist_km | border_pair + quarter,
  data = analysis_sample,
  cluster = ~border_pair
)

# Specification 3: DiDisc with border-pair×quarter FE
spec3 <- feols(
  log_earn_hire ~ treat_post + dist_km + treated:dist_km | border_pair^quarter,
  data = analysis_sample,
  cluster = ~border_pair
)

# Specification 4: Full DiDisc
spec4 <- feols(
  log_earn_hire ~ treat_post + dist_km + I(dist_km^2) +
    dist_km:post + I(dist_km^2):post +
    treated:dist_km + treated:I(dist_km^2) +
    treated:dist_km:post + treated:I(dist_km^2):post | border_pair^quarter,
  data = analysis_sample,
  cluster = ~border_pair
)

# Export using modelsummary
models <- list(
  "DiD" = spec1,
  "DiD + Distance" = spec2,
  "DiDisc (Linear)" = spec3,
  "DiDisc (Quadratic)" = spec4
)

tab3_latex <- modelsummary(
  models,
  output = "latex",
  stars = c('*' = 0.1, '**' = 0.05, '***' = 0.01),
  coef_map = c(
    "treat_post" = "Treated × Post",
    "dist_km" = "Distance (km)",
    "treated:dist_km" = "Treated × Distance",
    "dist_km:post" = "Distance × Post"
  ),
  gof_map = c("nobs", "r.squared", "FE: border_pair", "FE: quarter", "FE: border_pair^quarter"),
  title = "Difference-in-Discontinuities Estimates: Effect of Marijuana Legalization on New Hire Earnings",
  notes = "Standard errors clustered by border pair in parentheses. Sample restricted to counties within 100km of state border. Outcome: log average monthly earnings of stable new hires.",
  label = "tab:main"
)

writeLines(tab3_latex, file.path(tab_dir, "tab3_main_results.tex"))

# =============================================================================
# Table 4: Industry Heterogeneity
# =============================================================================

cat("Table 4: Industry Heterogeneity\n")

tab4_data <- industry_df %>%
  select(industry_name, category, tau, se, p_value, p_fdr_all, n_obs) %>%
  mutate(
    tau = sprintf("%.4f", tau),
    se = sprintf("(%.4f)", se),
    p_raw = sprintf("%.3f", p_value),
    p_fdr = sprintf("%.3f", p_fdr_all),
    n_obs = format(n_obs, big.mark = ",")
  ) %>%
  select(Industry = industry_name, Category = category,
         Effect = tau, SE = se, `p-value` = p_raw, `FDR q` = p_fdr, N = n_obs) %>%
  arrange(Category, `FDR q`)

tab4_latex <- kbl(tab4_data, format = "latex", booktabs = TRUE,
                  caption = "Industry-Specific Effects with FDR Correction",
                  label = "tab:industry") %>%
  kable_styling(latex_options = c("hold_position", "scale_down")) %>%
  pack_rows(index = table(tab4_data$Category))

writeLines(tab4_latex, file.path(tab_dir, "tab4_industry.tex"))

# =============================================================================
# Table 5: Bandwidth Sensitivity
# =============================================================================

cat("Table 5: Bandwidth Sensitivity\n")

if (!is.null(main_results$bandwidth_sensitivity)) {
  bw_df <- main_results$bandwidth_sensitivity %>%
    mutate(
      ci_low = tau - 1.96 * se,
      ci_high = tau + 1.96 * se,
      effect = sprintf("%.4f", tau),
      se_fmt = sprintf("(%.4f)", se),
      ci = sprintf("[%.4f, %.4f]", ci_low, ci_high),
      n_obs = format(n_obs, big.mark = ","),
      n_counties = as.character(n_counties)
    ) %>%
    select(`Bandwidth (km)` = bandwidth, Effect = effect, SE = se_fmt,
           `95% CI` = ci, Counties = n_counties, Observations = n_obs)

  tab5_latex <- kbl(bw_df, format = "latex", booktabs = TRUE,
                    caption = "Bandwidth Sensitivity Analysis",
                    label = "tab:bandwidth") %>%
    kable_styling(latex_options = c("hold_position"))

  writeLines(tab5_latex, file.path(tab_dir, "tab5_bandwidth.tex"))
}

# =============================================================================
# Table 6: Border-by-Border Results
# =============================================================================

cat("Table 6: Border Heterogeneity\n")

if (!is.null(main_results$border_heterogeneity)) {
  border_df <- main_results$border_heterogeneity %>%
    mutate(
      effect = sprintf("%.4f", tau),
      se_fmt = sprintf("(%.4f)", se),
      ci = sprintf("[%.4f, %.4f]", ci_low, ci_high),
      n_obs = format(n_obs, big.mark = ",")
    ) %>%
    arrange(tau) %>%
    select(`Border Pair` = border_pair, Effect = effect, SE = se_fmt,
           `95% CI` = ci, Observations = n_obs)

  tab6_latex <- kbl(border_df, format = "latex", booktabs = TRUE,
                    caption = "Treatment Effects by Border Pair",
                    label = "tab:borders") %>%
    kable_styling(latex_options = c("hold_position"))

  writeLines(tab6_latex, file.path(tab_dir, "tab6_borders.tex"))
}

# =============================================================================
# Table 7: Placebo Test Results
# =============================================================================

cat("Table 7: Placebo Tests\n")

if (!is.null(main_results$placebo)) {
  placebo_df <- main_results$placebo %>%
    mutate(
      effect = sprintf("%.4f", tau),
      se_fmt = sprintf("(%.4f)", se),
      t = sprintf("%.2f", t_stat),
      p = sprintf("%.3f", p_value)
    ) %>%
    select(`Event Time` = event_time, Effect = effect, SE = se_fmt,
           `t-stat` = t, `p-value` = p)

  # Add summary row
  placebo_summary <- tibble(
    `Event Time` = "Joint F-test",
    Effect = "",
    SE = "",
    `t-stat` = sprintf("%.2f", mean(main_results$placebo$t_stat^2)),
    `p-value` = sprintf("%.3f", pchisq(sum(main_results$placebo$t_stat^2),
                                        df = nrow(main_results$placebo), lower.tail = FALSE))
  )

  tab7_latex <- kbl(bind_rows(placebo_df, placebo_summary), format = "latex", booktabs = TRUE,
                    caption = "Placebo Tests: Pre-Treatment Discontinuity Changes",
                    label = "tab:placebo",
                    notes = "Each row estimates the change in border discontinuity in a 2-quarter window ending at the indicated event time. Joint F-test evaluates whether all placebo effects are jointly zero.") %>%
    kable_styling(latex_options = c("hold_position"))

  writeLines(tab7_latex, file.path(tab_dir, "tab7_placebo.tex"))
}

cat("\n=== All Tables Generated ===\n")
cat("Saved to:", tab_dir, "\n")
