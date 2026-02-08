# ============================================================================
# 05_robustness.R
# Salary Transparency Laws and the Gender Wage Gap
# Robustness Checks and Sensitivity Analysis
# ============================================================================

source("code/00_packages.R")

# Load data and results
df <- readRDS("data/cps_analysis.rds")
state_year <- readRDS("data/state_year_panel.rds")
results <- readRDS("data/main_results.rds")

cat("Loaded data and main results.\n")

# ============================================================================
# 1. Sun-Abraham Estimator (Alternative to C-S)
# ============================================================================

cat("\n==== 1. Sun-Abraham Estimator ====\n")

# Prepare data with cohort indicators
state_year <- state_year %>%
  mutate(
    cohort = factor(ifelse(g == 0, Inf, g))  # sunab needs Inf for never-treated
  )

# Sun-Abraham via fixest::sunab()
sa_result <- feols(
  y ~ sunab(cohort, income_year) | statefip + income_year,
  data = state_year,
  cluster = ~statefip
)

cat("\nSun-Abraham Event Study:\n")
print(summary(sa_result))

# Extract event-study coefficients
sa_coefs <- data.frame(
  event_time = as.numeric(gsub(".*::", "", names(coef(sa_result)))),
  att = coef(sa_result),
  se = se(sa_result)
) %>%
  filter(!is.na(event_time)) %>%
  mutate(
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se
  )

# ============================================================================
# 2. Gardner's Two-Stage (did2s)
# ============================================================================

cat("\n==== 2. Gardner Two-Stage Estimator ====\n")

# did2s implementation
# Requires: first_treat variable (0 for never-treated)
d2s_result <- did2s(
  data = as.data.frame(state_year),
  yname = "y",
  first_stage = ~ 1 | statefip + income_year,  # Fixed effects
  second_stage = ~ i(event_time, ref = -1),    # Event study
  treatment = "treat_post",
  cluster_var = "statefip"
)

cat("\nGardner Two-Stage Results:\n")
print(summary(d2s_result))

# ============================================================================
# 3. Not-Yet-Treated as Controls (Alternative Control Group)
# ============================================================================

cat("\n==== 3. Not-Yet-Treated Controls ====\n")

# Prepare data with g variable
state_year_nyt <- state_year %>%
  mutate(g = first_treat)

cs_nyt <- att_gt(
  yname = "y",
  tname = "income_year",
  idname = "statefip",
  gname = "g",
  data = as.data.frame(state_year_nyt),
  control_group = "notyettreated",  # Use not-yet-treated
  anticipation = 0,
  est_method = "dr",
  print_details = FALSE
)

att_nyt <- aggte(cs_nyt, type = "simple")
cat("\nC-S with Not-Yet-Treated Controls:\n")
cat("  ATT:", round(att_nyt$overall.att, 4),
    "(SE:", round(att_nyt$overall.se, 4), ")\n")

# Compare to main result
cat("\nComparison to main result (never-treated):\n")
cat("  Main ATT:", round(results$att_simple$overall.att, 4), "\n")
cat("  Difference:", round(att_nyt$overall.att - results$att_simple$overall.att, 4), "\n")

# ============================================================================
# 4. Excluding Border States
# ============================================================================

cat("\n==== 4. Excluding Border States ====\n")

# States bordering treated states may have spillovers
# Define border states (states that border any treated state)
treated_states <- c(6, 8, 9, 15, 17, 24, 25, 27, 32, 34, 36, 44, 50, 53)

# Border states (simplified - states adjacent to treated states)
border_states <- c(
  # Border CA: AZ, NV, OR
  4, 32, 41,
  # Border CO: AZ, KS, NE, NM, OK, UT, WY
  4, 20, 31, 35, 40, 49, 56,
  # Border NY: CT, MA, NJ, PA, VT
  9, 25, 34, 42, 50,
  # etc. (simplified)
  42, 10, 33, 23  # PA, DE, NH, ME
)
border_states <- unique(border_states)

# Remove treated states from border list
border_states <- setdiff(border_states, treated_states)

# Exclude border states
state_year_noborder <- state_year %>%
  filter(!(statefip %in% border_states & g == 0))

cat("Removed", length(border_states), "border control states\n")
cat("Remaining control states:", sum(state_year_noborder$g == 0 & state_year_noborder$income_year == 2020), "\n")

cs_noborder <- att_gt(
  yname = "y",
  tname = "income_year",
  idname = "statefip",
  gname = "g",
  data = as.data.frame(state_year_noborder),
  control_group = "nevertreated",
  anticipation = 0,
  est_method = "dr",
  print_details = FALSE
)

att_noborder <- aggte(cs_noborder, type = "simple")
cat("\nExcluding Border States:\n")
cat("  ATT:", round(att_noborder$overall.att, 4),
    "(SE:", round(att_noborder$overall.se, 4), ")\n")

# ============================================================================
# 5. Full-Time Workers Only
# ============================================================================

cat("\n==== 5. Full-Time Workers Only ====\n")

# Aggregate full-time only state-year panel
state_year_ft <- df %>%
  filter(fulltime == 1) %>%
  group_by(statefip, income_year, first_treat, ever_treated, post, treat_post) %>%
  summarize(
    mean_wage = weighted.mean(hourly_wage, ASECWT, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  ) %>%
  mutate(
    g = first_treat,
    y = log(mean_wage)
  )

cs_ft <- att_gt(
  yname = "y",
  tname = "income_year",
  idname = "statefip",
  gname = "g",
  data = as.data.frame(state_year_ft),
  control_group = "nevertreated",
  anticipation = 0,
  est_method = "dr",
  print_details = FALSE
)

att_ft <- aggte(cs_ft, type = "simple")
cat("\nFull-Time Workers Only:\n")
cat("  ATT:", round(att_ft$overall.att, 4),
    "(SE:", round(att_ft$overall.se, 4), ")\n")

# ============================================================================
# 6. By Education Level
# ============================================================================

cat("\n==== 6. Heterogeneity by Education ====\n")

# College-educated workers
state_year_college <- df %>%
  filter(educ_cat %in% c("BA or higher", "Graduate degree")) %>%
  group_by(statefip, income_year, first_treat) %>%
  summarize(
    mean_wage = weighted.mean(hourly_wage, ASECWT, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  ) %>%
  mutate(g = first_treat, y = log(mean_wage))

cs_college <- att_gt(
  yname = "y", tname = "income_year", idname = "statefip", gname = "g",
  data = as.data.frame(state_year_college),
  control_group = "nevertreated", anticipation = 0, est_method = "dr",
  print_details = FALSE
)
att_college <- aggte(cs_college, type = "simple")

# Non-college workers
state_year_nocollege <- df %>%
  filter(!educ_cat %in% c("BA or higher", "Graduate degree")) %>%
  group_by(statefip, income_year, first_treat) %>%
  summarize(
    mean_wage = weighted.mean(hourly_wage, ASECWT, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  ) %>%
  mutate(g = first_treat, y = log(mean_wage))

cs_nocollege <- att_gt(
  yname = "y", tname = "income_year", idname = "statefip", gname = "g",
  data = as.data.frame(state_year_nocollege),
  control_group = "nevertreated", anticipation = 0, est_method = "dr",
  print_details = FALSE
)
att_nocollege <- aggte(cs_nocollege, type = "simple")

cat("\nBy Education:\n")
cat("  College+: ATT =", round(att_college$overall.att, 4),
    "(SE:", round(att_college$overall.se, 4), ")\n")
cat("  No College: ATT =", round(att_nocollege$overall.att, 4),
    "(SE:", round(att_nocollege$overall.se, 4), ")\n")

# ============================================================================
# 7. Placebo Test: 2 Years Before Actual Treatment
# ============================================================================

cat("\n==== 7. Placebo Test (Fake Treatment 2 Years Early) ====\n")

# Create placebo treatment (2 years before actual)
state_year_placebo <- state_year %>%
  mutate(
    g_placebo = ifelse(g > 0, g - 2, 0),
    # Exclude actual post-treatment periods
    income_year_restricted = income_year
  ) %>%
  filter(income_year < min(g[g > 0]))  # Only pre-treatment data

if (nrow(state_year_placebo) > 20) {
  cs_placebo <- att_gt(
    yname = "y",
    tname = "income_year_restricted",
    idname = "statefip",
    gname = "g_placebo",
    data = as.data.frame(state_year_placebo),
    control_group = "nevertreated",
    anticipation = 0,
    est_method = "dr",
    print_details = FALSE
  )

  att_placebo <- aggte(cs_placebo, type = "simple")
  cat("\nPlacebo Treatment (2 years early):\n")
  cat("  ATT:", round(att_placebo$overall.att, 4),
      "(SE:", round(att_placebo$overall.se, 4), ")\n")
  cat("  Should be ~0 if parallel trends hold\n")
} else {
  cat("Insufficient pre-treatment data for placebo test\n")
}

# ============================================================================
# 8. Individual-Level Regression with Additional Controls
# ============================================================================

cat("\n==== 8. Individual-Level with Rich Controls ====\n")

# More saturated specification
ind_rich <- feols(
  log_hourly_wage ~ treat_post |
    statefip^income_year + occ_major^income_year + ind_major +
    educ_cat + age_group + female + married + race_eth,
  data = df,
  weights = ~ASECWT,
  cluster = ~statefip
)

cat("\nIndividual-Level with Rich Controls:\n")
cat("  treat_post:", round(coef(ind_rich)["treat_post"], 4),
    "(SE:", round(se(ind_rich)["treat_post"], 4), ")\n")

# ============================================================================
# 9. Compile Robustness Summary Table
# ============================================================================

cat("\n==== Robustness Summary ====\n")

robustness_summary <- tibble(
  Specification = c(
    "Main (C-S, never-treated)",
    "Sun-Abraham",
    "C-S, not-yet-treated controls",
    "Excluding border states",
    "Full-time workers only",
    "College-educated only",
    "Non-college only",
    "Individual-level, rich controls"
  ),
  ATT = c(
    results$att_simple$overall.att,
    mean(sa_coefs$att[sa_coefs$event_time >= 0], na.rm = TRUE),
    att_nyt$overall.att,
    att_noborder$overall.att,
    att_ft$overall.att,
    att_college$overall.att,
    att_nocollege$overall.att,
    coef(ind_rich)["treat_post"]
  ),
  SE = c(
    results$att_simple$overall.se,
    mean(sa_coefs$se[sa_coefs$event_time >= 0], na.rm = TRUE),
    att_nyt$overall.se,
    att_noborder$overall.se,
    att_ft$overall.se,
    att_college$overall.se,
    att_nocollege$overall.se,
    se(ind_rich)["treat_post"]
  )
) %>%
  mutate(
    `95% CI` = paste0("[", round(ATT - 1.96*SE, 4), ", ", round(ATT + 1.96*SE, 4), "]"),
    ATT = round(ATT, 4),
    SE = round(SE, 4)
  )

print(robustness_summary)

# ============================================================================
# 10. Save Robustness Results
# ============================================================================

robustness_results <- list(
  sa_result = sa_result,
  sa_coefs = sa_coefs,
  cs_nyt = cs_nyt,
  att_nyt = att_nyt,
  cs_noborder = cs_noborder,
  att_noborder = att_noborder,
  cs_ft = cs_ft,
  att_ft = att_ft,
  att_college = att_college,
  att_nocollege = att_nocollege,
  ind_rich = ind_rich,
  summary_table = robustness_summary
)

saveRDS(robustness_results, "data/robustness_results.rds")

# ============================================================================
# 11. Create Robustness Figure
# ============================================================================

cat("\n==== Creating Robustness Figure ====\n")

# Forest plot of robustness specifications
robust_plot_data <- robustness_summary %>%
  mutate(
    Specification = factor(Specification, levels = rev(Specification)),
    ci_lower = ATT - 1.96 * SE,
    ci_upper = ATT + 1.96 * SE
  )

p_robust <- ggplot(robust_plot_data, aes(x = ATT, y = Specification)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_vline(xintercept = results$att_simple$overall.att,
             linetype = "dotted", color = color_treated, alpha = 0.5) +
  geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper),
                 height = 0.2, color = color_treated) +
  geom_point(size = 3, color = color_treated) +
  labs(
    title = "Robustness of Main Results",
    subtitle = "Point estimates and 95% confidence intervals across specifications",
    x = "ATT (Log Hourly Wage)",
    y = NULL,
    caption = "Note: Dotted line shows main specification estimate."
  ) +
  theme_apep() +
  theme(
    axis.text.y = element_text(size = 9),
    panel.grid.major.y = element_blank()
  )

ggsave("figures/fig6_robustness.pdf", p_robust, width = 9, height = 6)
ggsave("figures/fig6_robustness.png", p_robust, width = 9, height = 6, dpi = 300)

cat("Saved figures/fig6_robustness.pdf\n")

cat("\n==== Robustness Checks Complete ====\n")
cat("Results saved to data/robustness_results.rds\n")
cat("Next step: Run 06_figures.R\n")
