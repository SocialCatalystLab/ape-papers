# ============================================================================
# 06_figures.R
# Salary Transparency Laws and the Gender Wage Gap
# All Figure Generation
# ============================================================================

source("code/00_packages.R")

# Load all results
df <- readRDS("data/cps_analysis.rds")
state_year <- readRDS("data/state_year_panel.rds")
transparency_laws <- readRDS("data/transparency_laws.rds")
results <- readRDS("data/main_results.rds")
robustness <- readRDS("data/robustness_results.rds")
es_data <- readRDS("data/event_study_data.rds")

cat("Loaded all data and results.\n")

# ============================================================================
# Figure 1: Policy Adoption Map (already created in 03_descriptives.R)
# ============================================================================

# See 03_descriptives.R

# ============================================================================
# Figure 2: Wage Trends (already created in 03_descriptives.R)
# ============================================================================

# See 03_descriptives.R

# ============================================================================
# Figure 3: Gender Wage Gap Trends (already created in 03_descriptives.R)
# ============================================================================

# See 03_descriptives.R

# ============================================================================
# Figure 4: Event Study - Main Result
# ============================================================================

cat("\nCreating main event study figure...\n")

p_es_main <- ggplot(es_data, aes(x = event_time, y = att)) +
  # Reference lines
  geom_hline(yintercept = 0, linetype = "solid", color = "grey70", linewidth = 0.5) +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "grey50", linewidth = 0.6) +

  # Confidence interval
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
              alpha = 0.2, fill = color_treated) +

  # Point estimates and line
  geom_line(color = color_treated, linewidth = 0.9) +
  geom_point(color = color_treated, size = 3.5, shape = 16) +

  # Annotation for treatment timing
 annotate("text", x = 0.3, y = max(es_data$ci_upper) * 0.9,
           label = "Post-Treatment",
           hjust = 0, size = 3.5, fontface = "italic", color = "grey40") +
  annotate("text", x = -0.7, y = max(es_data$ci_upper) * 0.9,
           label = "Pre-Treatment",
           hjust = 1, size = 3.5, fontface = "italic", color = "grey40") +

  # Scales
  scale_x_continuous(breaks = seq(-5, 3, 1)) +
  scale_y_continuous(labels = scales::number_format(accuracy = 0.001)) +

  # Labels
  labs(
    title = "Event Study: Effect of Salary Transparency Laws on Wages",
    subtitle = "Callaway-Sant'Anna estimator, never-treated states as controls",
    x = "Years Relative to Treatment",
    y = "ATT (Log Hourly Wage)",
    caption = paste0(
      "Notes: Reference period is t = -1 (normalized to zero). ",
      "Shaded area shows 95% confidence interval.\n",
      "Pre-treatment coefficients test the parallel trends assumption."
    )
  ) +
  theme_apep() +
  theme(
    plot.caption = element_text(hjust = 0, size = 8, lineheight = 1.2)
  )

ggsave("figures/fig4_event_study_main.pdf", p_es_main, width = 9, height = 6)
ggsave("figures/fig4_event_study_main.png", p_es_main, width = 9, height = 6, dpi = 300)

cat("Saved figures/fig4_event_study_main.pdf\n")

# ============================================================================
# Figure 5: Gender-Specific Event Studies
# ============================================================================

cat("\nCreating gender-specific event studies...\n")

# Run separate event studies by gender
state_year_gender <- df %>%
  group_by(statefip, income_year, first_treat, female) %>%
  summarize(
    mean_wage = weighted.mean(hourly_wage, ASECWT, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  ) %>%
  mutate(
    g = first_treat,
    y = log(mean_wage)
  )

# Male event study
cs_male <- att_gt(
  yname = "y",
  tname = "income_year",
  idname = "statefip",
  gname = "g",
  data = as.data.frame(filter(state_year_gender, female == 0)),
  control_group = "nevertreated",
  anticipation = 0,
  est_method = "dr",
  print_details = FALSE
)
es_male <- aggte(cs_male, type = "dynamic", min_e = -5, max_e = 3)

# Female event study
cs_female <- att_gt(
  yname = "y",
  tname = "income_year",
  idname = "statefip",
  gname = "g",
  data = as.data.frame(filter(state_year_gender, female == 1)),
  control_group = "nevertreated",
  anticipation = 0,
  est_method = "dr",
  print_details = FALSE
)
es_female <- aggte(cs_female, type = "dynamic", min_e = -5, max_e = 3)

# Combine
es_gender <- bind_rows(
  data.frame(
    event_time = es_male$egt,
    att = es_male$att.egt,
    se = es_male$se.egt,
    gender = "Male"
  ),
  data.frame(
    event_time = es_female$egt,
    att = es_female$att.egt,
    se = es_female$se.egt,
    gender = "Female"
  )
) %>%
  mutate(
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se
  )

p_es_gender <- ggplot(es_gender, aes(x = event_time, y = att, color = gender, fill = gender)) +
  geom_hline(yintercept = 0, linetype = "solid", color = "grey70") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "grey50") +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.15, color = NA) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 3) +
  scale_color_manual(values = c("Female" = color_female, "Male" = color_male)) +
  scale_fill_manual(values = c("Female" = color_female, "Male" = color_male)) +
  scale_x_continuous(breaks = seq(-5, 3, 1)) +
  labs(
    title = "Event Study by Gender",
    subtitle = "Separate Callaway-Sant'Anna estimates for men and women",
    x = "Years Relative to Treatment",
    y = "ATT (Log Hourly Wage)",
    color = NULL, fill = NULL,
    caption = "Note: Convergence of male and female effects post-treatment indicates gender gap narrowing."
  ) +
  theme_apep() +
  theme(legend.position = c(0.15, 0.85))

ggsave("figures/fig5_event_study_gender.pdf", p_es_gender, width = 9, height = 6)
ggsave("figures/fig5_event_study_gender.png", p_es_gender, width = 9, height = 6, dpi = 300)

cat("Saved figures/fig5_event_study_gender.pdf\n")

# ============================================================================
# Figure 6: DDD Coefficients - Gender Gap Effect
# ============================================================================

cat("\nCreating DDD coefficient figure...\n")

# Extract DDD results
ddd_coefs <- data.frame(
  term = c("Treated × Post", "Treated × Post × Female", "Total Female Effect"),
  estimate = c(
    coef(results$ddd_result)["treat_post"],
    coef(results$ddd_result)["treat_post:female"],
    coef(results$ddd_result)["treat_post"] + coef(results$ddd_result)["treat_post:female"]
  ),
  se = c(
    se(results$ddd_result)["treat_post"],
    se(results$ddd_result)["treat_post:female"],
    sqrt(se(results$ddd_result)["treat_post"]^2 +
         se(results$ddd_result)["treat_post:female"]^2)  # Approximate
  )
) %>%
  mutate(
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se,
    term = factor(term, levels = rev(term))
  )

p_ddd <- ggplot(ddd_coefs, aes(x = estimate, y = term)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper), height = 0.2) +
  geom_point(size = 4, color = color_treated) +
  labs(
    title = "Triple-Difference Results: Gender Gap Effects",
    subtitle = "Effect of transparency laws on wages by gender",
    x = "Coefficient (Log Hourly Wage)",
    y = NULL,
    caption = paste0(
      "Notes: 'Treated × Post' = effect on male wages. ",
      "'Treated × Post × Female' = additional effect for women.\n",
      "Positive 'Treated × Post × Female' indicates gender gap narrowing."
    )
  ) +
  theme_apep() +
  theme(
    axis.text.y = element_text(size = 11),
    plot.caption = element_text(hjust = 0)
  )

ggsave("figures/fig6_ddd_gender.pdf", p_ddd, width = 8, height = 4.5)
ggsave("figures/fig6_ddd_gender.png", p_ddd, width = 8, height = 4.5, dpi = 300)

cat("Saved figures/fig6_ddd_gender.pdf\n")

# ============================================================================
# Figure 7: Heterogeneity by Bargaining Intensity
# ============================================================================

cat("\nCreating bargaining heterogeneity figure...\n")

# Event studies by bargaining intensity
state_year_bargain <- df %>%
  group_by(statefip, income_year, first_treat, high_bargaining) %>%
  summarize(
    mean_wage = weighted.mean(hourly_wage, ASECWT, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  ) %>%
  mutate(g = first_treat, y = log(mean_wage))

# High bargaining
cs_high <- att_gt(
  yname = "y", tname = "income_year", idname = "statefip", gname = "g",
  data = as.data.frame(filter(state_year_bargain, high_bargaining == 1)),
  control_group = "nevertreated", anticipation = 0, est_method = "dr",
  print_details = FALSE
)
es_high <- aggte(cs_high, type = "dynamic", min_e = -5, max_e = 3)

# Low bargaining
cs_low <- att_gt(
  yname = "y", tname = "income_year", idname = "statefip", gname = "g",
  data = as.data.frame(filter(state_year_bargain, high_bargaining == 0)),
  control_group = "nevertreated", anticipation = 0, est_method = "dr",
  print_details = FALSE
)
es_low <- aggte(cs_low, type = "dynamic", min_e = -5, max_e = 3)

# Combine
es_bargain <- bind_rows(
  data.frame(
    event_time = es_high$egt,
    att = es_high$att.egt,
    se = es_high$se.egt,
    bargaining = "High Bargaining"
  ),
  data.frame(
    event_time = es_low$egt,
    att = es_low$att.egt,
    se = es_low$se.egt,
    bargaining = "Low Bargaining"
  )
) %>%
  mutate(
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se
  )

p_bargain <- ggplot(es_bargain, aes(x = event_time, y = att, color = bargaining, fill = bargaining)) +
  geom_hline(yintercept = 0, linetype = "solid", color = "grey70") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "grey50") +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.15, color = NA) +
  geom_line(linewidth = 0.9) +
  geom_point(size = 3) +
  scale_color_manual(values = c("High Bargaining" = color_treated,
                                "Low Bargaining" = color_control)) +
  scale_fill_manual(values = c("High Bargaining" = color_treated,
                               "Low Bargaining" = color_control)) +
  scale_x_continuous(breaks = seq(-5, 3, 1)) +
  labs(
    title = "Event Study by Occupation Bargaining Intensity",
    subtitle = "Cullen prediction: Larger effects in high-bargaining occupations",
    x = "Years Relative to Treatment",
    y = "ATT (Log Hourly Wage)",
    color = NULL, fill = NULL,
    caption = paste0(
      "Notes: High-bargaining = professional, managerial, technical occupations.\n",
      "Cullen & Pakzad-Hurson (2023) predict transparency reduces wages more where individual bargaining is common."
    )
  ) +
  theme_apep() +
  theme(
    legend.position = c(0.2, 0.2),
    plot.caption = element_text(hjust = 0)
  )

ggsave("figures/fig7_heterogeneity_bargaining.pdf", p_bargain, width = 9, height = 6)
ggsave("figures/fig7_heterogeneity_bargaining.png", p_bargain, width = 9, height = 6, dpi = 300)

cat("Saved figures/fig7_heterogeneity_bargaining.pdf\n")

# ============================================================================
# Figure 8: Robustness Summary (already created in 05_robustness.R)
# ============================================================================

# See 05_robustness.R

# ============================================================================
# Figure 9: Conceptual Framework Diagram
# ============================================================================

cat("\nCreating conceptual framework diagram...\n")

# Simple pathway diagram showing mechanisms
# This is a stylized figure - in practice you might want to use tikz

framework_data <- data.frame(
  stage = c("Policy", "Mechanism 1", "Mechanism 2", "Mechanism 3", "Outcome"),
  label = c(
    "Salary Transparency\nLaw",
    "Information\nDisclosure",
    "Employer\nCommitment",
    "Reduced\nBargaining",
    "Wage\nEffects"
  ),
  x = c(1, 2, 2, 2, 3),
  y = c(2, 3, 2, 1, 2)
)

p_framework <- ggplot(framework_data, aes(x = x, y = y, label = label)) +
  # Boxes
  geom_tile(width = 0.7, height = 0.6, fill = "white", color = color_treated, linewidth = 1.2) +
  geom_text(size = 3.5, lineheight = 0.9) +
  # Arrows from policy to mechanisms
  annotate("segment", x = 1.35, xend = 1.65, y = 2.15, yend = 2.85,
           arrow = arrow(length = unit(0.2, "cm")), color = "grey40") +
  annotate("segment", x = 1.35, xend = 1.65, y = 2, yend = 2,
           arrow = arrow(length = unit(0.2, "cm")), color = "grey40") +
  annotate("segment", x = 1.35, xend = 1.65, y = 1.85, yend = 1.15,
           arrow = arrow(length = unit(0.2, "cm")), color = "grey40") +
  # Arrows from mechanisms to outcome
  annotate("segment", x = 2.35, xend = 2.65, y = 2.85, yend = 2.15,
           arrow = arrow(length = unit(0.2, "cm")), color = "grey40") +
  annotate("segment", x = 2.35, xend = 2.65, y = 2, yend = 2,
           arrow = arrow(length = unit(0.2, "cm")), color = "grey40") +
  annotate("segment", x = 2.35, xend = 2.65, y = 1.15, yend = 1.85,
           arrow = arrow(length = unit(0.2, "cm")), color = "grey40") +
  # Effect signs
  annotate("text", x = 3, y = 2.55, label = "+ Women gain info", size = 2.5, color = "#009E73") +
  annotate("text", x = 3, y = 1.45, label = "− Workers lose leverage", size = 2.5, color = "#D55E00") +
  # Limits and theme
  xlim(0.5, 3.5) + ylim(0.5, 3.5) +
  labs(
    title = "Conceptual Framework: Pay Transparency and Wages",
    subtitle = "Multiple mechanisms with potentially opposing effects"
  ) +
  theme_void() +
  theme(
    plot.title = element_text(size = 13, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "grey40")
  )

ggsave("figures/fig9_conceptual_framework.pdf", p_framework, width = 8, height = 5)
ggsave("figures/fig9_conceptual_framework.png", p_framework, width = 8, height = 5, dpi = 300)

cat("Saved figures/fig9_conceptual_framework.pdf\n")

# ============================================================================
# Save All Event Study Data
# ============================================================================

all_es_data <- list(
  main = es_data,
  by_gender = es_gender,
  by_bargaining = es_bargain
)

saveRDS(all_es_data, "data/all_event_studies.rds")

# ============================================================================
# Summary
# ============================================================================

cat("\n==== Figure Generation Complete ====\n")
cat("Created figures:\n")
cat("  fig1_policy_map.pdf - Geographic distribution of policy adoption\n")
cat("  fig2_wage_trends.pdf - Wage trends by treatment status\n")
cat("  fig3_gap_trends.pdf - Gender wage gap trends\n")
cat("  fig4_event_study_main.pdf - Main event study results\n")
cat("  fig5_event_study_gender.pdf - Event study by gender\n")
cat("  fig6_ddd_gender.pdf - Triple-difference gender gap results\n")
cat("  fig7_heterogeneity_bargaining.pdf - Heterogeneity by bargaining intensity\n")
cat("  fig6_robustness.pdf - Robustness check summary\n")
cat("  fig9_conceptual_framework.pdf - Conceptual mechanisms diagram\n")
cat("\nNext step: Run 07_tables.R\n")
