# ============================================================================
# 04_main_analysis.R
# Salary Transparency Laws and the Gender Wage Gap
# Main DiD Analysis with Callaway-Sant'Anna Estimator
# ============================================================================

source("code/00_packages.R")

# Load cleaned data
df <- readRDS("data/cps_analysis.rds")
state_year <- readRDS("data/state_year_panel.rds")

cat("Loaded", format(nrow(df), big.mark = ","), "individual observations\n")
cat("Loaded", nrow(state_year), "state-year observations\n")

# ============================================================================
# Prepare Data for Callaway-Sant'Anna Estimator
# ============================================================================

cat("\nPreparing data for Callaway-Sant'Anna estimator...\n")

# The `did` package requires:
# - Panel ID (we'll use state as unit)
# - Time variable
# - First treatment period (0 for never-treated)
# - Outcome

# We'll work at the state-year level for computational tractability
# and because treatment varies at the state level

# Ensure proper coding
state_year <- state_year %>%
  mutate(
    # Recode first_treat = 0 for never-treated (required by did package)
    g = first_treat,

    # Log wage as primary outcome
    y = log(mean_wage)
  ) %>%
  filter(!is.na(y), !is.infinite(y))

cat("State-year panel ready:", nrow(state_year), "observations\n")
cat("Treated states:", sum(state_year$g > 0 & state_year$income_year == 2020), "\n")
cat("Control states:", sum(state_year$g == 0 & state_year$income_year == 2020), "\n")

# ============================================================================
# A) Callaway-Sant'Anna ATT(g,t)
# ============================================================================

cat("\n==== Callaway-Sant'Anna Estimation ====\n")

# Main specification: unconditional parallel trends
# Using never-treated states as control group
cs_result <- att_gt(
  yname = "y",                        # Outcome: log wage
  tname = "income_year",              # Time variable
  idname = "statefip",                # Panel unit ID
  gname = "g",                        # First treatment period (0 = never treated)
  data = as.data.frame(state_year),
  control_group = "nevertreated",     # Use never-treated as controls
  anticipation = 0,                   # No anticipation
  est_method = "dr",                  # Doubly-robust (default)
  print_details = FALSE
)

# Print group-time ATTs
cat("\nGroup-Time ATT Estimates:\n")
print(summary(cs_result))

# Save results
saveRDS(cs_result, "data/cs_main_result.rds")

# ============================================================================
# B) Aggregate to Event Study
# ============================================================================

cat("\n==== Event Study Aggregation ====\n")

# Aggregate to event-time (dynamic) effects
es_result <- aggte(cs_result, type = "dynamic", min_e = -5, max_e = 3)

cat("\nEvent Study Estimates:\n")
print(summary(es_result))

# Extract for plotting
es_data <- data.frame(
  event_time = es_result$egt,
  att = es_result$att.egt,
  se = es_result$se.egt
) %>%
  mutate(
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se,
    significant = (ci_lower > 0) | (ci_upper < 0)
  )

saveRDS(es_data, "data/event_study_data.rds")

# ============================================================================
# C) Simple ATT (Overall Average Effect)
# ============================================================================

cat("\n==== Overall ATT ====\n")

# Aggregate to simple overall ATT
att_simple <- aggte(cs_result, type = "simple")
cat("\nSimple ATT (Average Treatment Effect on Treated):\n")
print(summary(att_simple))

# ============================================================================
# D) Group-Specific Effects
# ============================================================================

cat("\n==== Group-Specific Effects ====\n")

# Aggregate by treatment cohort (group)
att_group <- aggte(cs_result, type = "group")
cat("\nEffects by Treatment Cohort:\n")
print(summary(att_group))

# ============================================================================
# E) TWFE Comparison (for Reference)
# ============================================================================

cat("\n==== TWFE Comparison ====\n")

# Standard TWFE regression
twfe_result <- feols(
  y ~ treat_post | statefip + income_year,
  data = state_year,
  cluster = ~statefip
)

cat("\nTWFE Result (potentially biased with staggered adoption):\n")
print(summary(twfe_result))

# Compare
cat("\nComparison:\n")
cat("  C-S Simple ATT:", round(att_simple$overall.att, 4),
    "(SE:", round(att_simple$overall.se, 4), ")\n")
cat("  TWFE Estimate: ", round(coef(twfe_result)["treat_post"], 4),
    "(SE:", round(se(twfe_result)["treat_post"], 4), ")\n")

# ============================================================================
# F) Gender Gap Analysis (DDD)
# ============================================================================

cat("\n==== Gender Gap Analysis (DDD) ====\n")

# For individual-level DDD, we need the microdata
# Y = α + β1(Treat×Post) + β2(Treat×Post×Female) + γ(Female) + FE + ε
# β2 is the differential effect for women

ddd_result <- feols(
  log_hourly_wage ~ treat_post * female |
    statefip^income_year + occ_major + ind_major + educ_cat + age_group,
  data = df,
  weights = ~ASECWT,
  cluster = ~statefip
)

cat("\nTriple-Difference Results:\n")
print(summary(ddd_result))

# Interpretation:
# - treat_post: Effect on men's wages
# - treat_post:female: Additional effect for women (positive = gap narrows)
# - Total female effect: treat_post + treat_post:female

# ============================================================================
# G) Heterogeneity by Occupation (Bargaining Intensity)
# ============================================================================

cat("\n==== Heterogeneity by Bargaining Intensity ====\n")

# DDD: State × Time × High-Bargaining Occupation
ddd_bargain <- feols(
  log_hourly_wage ~ treat_post * high_bargaining |
    statefip^income_year + female + educ_cat + age_group,
  data = df,
  weights = ~ASECWT,
  cluster = ~statefip
)

cat("\nTriple-Difference by Bargaining Intensity:\n")
print(summary(ddd_bargain))

# Cullen prediction: high-bargaining occupations should see larger wage decline
# (negative treat_post:high_bargaining)

# ============================================================================
# H) Save All Results
# ============================================================================

results <- list(
  cs_result = cs_result,
  es_result = es_result,
  es_data = es_data,
  att_simple = att_simple,
  att_group = att_group,
  twfe_result = twfe_result,
  ddd_result = ddd_result,
  ddd_bargain = ddd_bargain
)

saveRDS(results, "data/main_results.rds")

# ============================================================================
# I) Create Event Study Figure
# ============================================================================

cat("\n==== Creating Event Study Figure ====\n")

p_event_study <- ggplot(es_data, aes(x = event_time, y = att)) +
  # Zero reference line
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +

  # Treatment timing line
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey40", linewidth = 0.7) +

  # Confidence interval ribbon
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
              alpha = 0.2, fill = color_treated) +

  # Point estimates
  geom_line(color = color_treated, linewidth = 0.8) +
  geom_point(aes(shape = significant), color = color_treated, size = 3) +

  # Scale for significance markers
  scale_shape_manual(values = c("FALSE" = 1, "TRUE" = 16),
                     guide = "none") +

  # Labels
  labs(
    title = "Event Study: Effect of Salary Transparency Laws on Log Wages",
    subtitle = "Callaway-Sant'Anna estimator with never-treated controls",
    x = "Years Relative to Treatment",
    y = "ATT (Log Hourly Wage)",
    caption = paste0(
      "Note: Reference period is t = -1. Shaded area shows 95% CI.\n",
      "Filled points indicate statistical significance at 5% level.\n",
      "Pre-treatment coefficients test parallel trends assumption."
    )
  ) +
  scale_x_continuous(breaks = seq(-5, 3, 1)) +
  theme_apep()

ggsave("figures/fig5_event_study.pdf", p_event_study, width = 9, height = 6)
ggsave("figures/fig5_event_study.png", p_event_study, width = 9, height = 6, dpi = 300)

cat("Saved figures/fig5_event_study.pdf\n")

# ============================================================================
# J) Summary Statistics for Results
# ============================================================================

cat("\n==== Summary of Main Results ====\n")

cat("\n1. Overall Effect (Callaway-Sant'Anna):\n")
cat("   ATT:", round(att_simple$overall.att, 4), "\n")
cat("   SE: ", round(att_simple$overall.se, 4), "\n")
cat("   95% CI: [", round(att_simple$overall.att - 1.96*att_simple$overall.se, 4),
    ", ", round(att_simple$overall.att + 1.96*att_simple$overall.se, 4), "]\n")
cat("   Interpretation: ", round(att_simple$overall.att * 100, 2),
    "% change in wages from transparency laws\n")

cat("\n2. Pre-trends (Event Study):\n")
pre_period <- es_data %>% filter(event_time < 0)
cat("   Max pre-trend coefficient:", round(max(abs(pre_period$att)), 4), "\n")
cat("   Any significant pre-trends:", any(pre_period$significant), "\n")

cat("\n3. Gender Gap Effect (DDD):\n")
cat("   Effect on men (β1):", round(coef(ddd_result)["treat_post"], 4), "\n")
cat("   Additional effect for women (β2):", round(coef(ddd_result)["treat_post:female"], 4), "\n")
female_total <- coef(ddd_result)["treat_post"] + coef(ddd_result)["treat_post:female"]
cat("   Total effect on women:", round(female_total, 4), "\n")
if (coef(ddd_result)["treat_post:female"] > 0) {
  cat("   → Gender gap NARROWS (women benefit more)\n")
} else {
  cat("   → Gender gap WIDENS (men benefit more)\n")
}

cat("\n4. Bargaining Heterogeneity:\n")
cat("   Effect in low-bargaining:", round(coef(ddd_bargain)["treat_post"], 4), "\n")
cat("   Additional effect in high-bargaining:",
    round(coef(ddd_bargain)["treat_post:high_bargaining"], 4), "\n")

cat("\n==== Main Analysis Complete ====\n")
cat("Results saved to data/main_results.rds\n")
cat("Event study figure saved to figures/fig5_event_study.pdf\n")
cat("\nNext step: Run 05_robustness.R\n")
