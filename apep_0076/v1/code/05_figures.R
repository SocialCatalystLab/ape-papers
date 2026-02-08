# ============================================================================
# Paper 105: State EITC Generosity and Property Crime
# Script: 05_figures.R - Figure Generation
# ============================================================================

source("00_packages.R")

cat("Generating figures for Paper 105...\n\n")

# Load data
analysis_data <- read_csv(file.path(DATA_DIR, "analysis_eitc_crime.csv"), show_col_types = FALSE)
cs_results <- readRDS(file.path(DATA_DIR, "cs_results.rds"))
bacon_data <- read_csv(file.path(DATA_DIR, "bacon_decomposition.csv"), show_col_types = FALSE)

# ============================================================================
# FIGURE 1: Treatment Rollout Map
# ============================================================================

cat("Creating Figure 1: Treatment Rollout...\n")

# Get adoption timing by state
# Note: Only count states adopting by 2019 (end of sample); states adopting after 2019 are "Never Adopted" in our sample
adoption_timing <- analysis_data %>%
  select(state_abbr, eitc_adopted) %>%
  distinct() %>%
  mutate(
    adoption_period = case_when(
      is.na(eitc_adopted) ~ "Never Adopted",
      eitc_adopted > 2019 ~ "Never Adopted",  # Outside sample period (e.g., WA 2023)
      eitc_adopted < 1999 ~ "Pre-1999",
      eitc_adopted <= 2005 ~ "1999-2005",
      eitc_adopted <= 2010 ~ "2006-2010",
      eitc_adopted <= 2015 ~ "2011-2015",
      TRUE ~ "2016-2019"
    ),
    adoption_period = factor(adoption_period,
                             levels = c("Pre-1999", "1999-2005", "2006-2010",
                                        "2011-2015", "2016-2019", "Never Adopted"))
  )

# Count by period
period_counts <- adoption_timing %>%
  count(adoption_period) %>%
  mutate(label = sprintf("%s (n=%d)", adoption_period, n))

fig1 <- ggplot(adoption_timing, aes(x = adoption_period)) +
  geom_bar(fill = "#2C3E50", alpha = 0.8) +
  geom_text(stat = "count", aes(label = after_stat(count)), vjust = -0.5, size = 3.5) +
  labs(
    title = "State EITC Adoption Timing",
    subtitle = "Number of states by adoption period",
    x = "Adoption Period",
    y = "Number of States"
  ) +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(file.path(FIG_DIR, "fig1_adoption_timing.pdf"), fig1, width = 8, height = 6)
ggsave(file.path(FIG_DIR, "fig1_adoption_timing.png"), fig1, width = 8, height = 6, dpi = 300)

# ============================================================================
# FIGURE 2: Pre-Trends (Property Crime by Treatment Status)
# ============================================================================

cat("Creating Figure 2: Pre-Trends...\n")

# Calculate mean crime rates by treatment status and year
trends_data <- analysis_data %>%
  mutate(
    treatment_group = case_when(
      is.na(eitc_adopted) ~ "Never Treated",
      eitc_adopted < 1999 ~ "Early Adopter (pre-1999)",
      TRUE ~ "Later Adopter (1999+)"
    )
  ) %>%
  group_by(year, treatment_group) %>%
  summarise(
    mean_property = mean(property_rate),
    se_property = sd(property_rate) / sqrt(n()),
    mean_violent = mean(violent_rate),
    n = n(),
    .groups = "drop"
  )

fig2 <- ggplot(trends_data, aes(x = year, y = mean_property, color = treatment_group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_ribbon(aes(ymin = mean_property - 1.96 * se_property,
                  ymax = mean_property + 1.96 * se_property,
                  fill = treatment_group), alpha = 0.2, color = NA) +
  scale_color_manual(values = c("#E74C3C", "#3498DB", "#2ECC71")) +
  scale_fill_manual(values = c("#E74C3C", "#3498DB", "#2ECC71")) +
  labs(
    title = "Property Crime Trends by EITC Adoption Status",
    subtitle = "Mean property crime rate per 100,000 with 95% confidence bands",
    x = "Year",
    y = "Property Crime Rate (per 100,000)",
    color = "Treatment Group",
    fill = "Treatment Group"
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(FIG_DIR, "fig2_pretrends.pdf"), fig2, width = 10, height = 7)
ggsave(file.path(FIG_DIR, "fig2_pretrends.png"), fig2, width = 10, height = 7, dpi = 300)

# ============================================================================
# FIGURE 3: Event Study (Callaway-Sant'Anna)
# ============================================================================

cat("Creating Figure 3: Event Study...\n")

# Extract dynamic ATT estimates
cs_dynamic <- cs_results$agg_dynamic

# Create event study data frame
es_df <- data.frame(
  time = cs_dynamic$egt,
  att = cs_dynamic$att.egt,
  se = cs_dynamic$se.egt
) %>%
  mutate(
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se,
    significant = ci_lower > 0 | ci_upper < 0
  ) %>%
  filter(time >= -5 & time <= 10)

fig3 <- ggplot(es_df, aes(x = time, y = att)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray50") +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), fill = "#3498DB", alpha = 0.3) +
  geom_line(color = "#2C3E50", linewidth = 1) +
  geom_point(aes(color = significant), size = 3) +
  scale_color_manual(values = c("FALSE" = "#2C3E50", "TRUE" = "#E74C3C"), guide = "none") +
  labs(
    title = "Event Study: Effect of State EITC on Property Crime",
    subtitle = "Callaway-Sant'Anna (2021) estimator with 95% confidence intervals",
    x = "Years Relative to EITC Adoption",
    y = "ATT (Log Property Crime Rate)"
  ) +
  theme_apep() +
  annotate("text", x = -3, y = max(es_df$ci_upper) * 0.9,
           label = "Pre-treatment", hjust = 0.5, size = 3.5, color = "gray40") +
  annotate("text", x = 5, y = max(es_df$ci_upper) * 0.9,
           label = "Post-treatment", hjust = 0.5, size = 3.5, color = "gray40")

ggsave(file.path(FIG_DIR, "fig3_event_study.pdf"), fig3, width = 10, height = 7)
ggsave(file.path(FIG_DIR, "fig3_event_study.png"), fig3, width = 10, height = 7, dpi = 300)

# ============================================================================
# FIGURE 4: Bacon Decomposition
# ============================================================================

cat("Creating Figure 4: Bacon Decomposition...\n")

# Summarize bacon decomposition
bacon_summary <- bacon_data %>%
  group_by(type) %>%
  summarise(
    n = n(),
    weight = sum(weight),
    weighted_est = sum(weight * estimate) / sum(weight),
    .groups = "drop"
  ) %>%
  mutate(
    type_label = case_when(
      type == "Earlier vs Later Treated" ~ "Earlier vs\nLater Treated",
      type == "Later vs Earlier Treated" ~ "Later vs\nEarlier Treated",
      type == "Treated vs Untreated" ~ "Treated vs\nNever Treated",
      TRUE ~ type
    )
  )

fig4a <- ggplot(bacon_summary, aes(x = reorder(type_label, -weight), y = weight)) +
  geom_col(fill = "#2C3E50", alpha = 0.8) +
  geom_text(aes(label = sprintf("%.1f%%", weight * 100)), vjust = -0.5, size = 3.5) +
  labs(
    title = "Bacon Decomposition: Weight by Comparison Type",
    subtitle = "Share of TWFE estimate from each 2x2 comparison",
    x = "Comparison Type",
    y = "Weight"
  ) +
  scale_y_continuous(labels = scales::percent_format(), limits = c(0, 0.7)) +
  theme_apep()

fig4b <- ggplot(bacon_data, aes(x = weight, y = estimate, color = type)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_point(size = 3, alpha = 0.7) +
  scale_color_manual(values = c("#E74C3C", "#3498DB", "#2ECC71", "#9B59B6")) +
  labs(
    title = "Bacon Decomposition: Estimate vs Weight",
    subtitle = "Each point is a 2x2 DiD comparison",
    x = "Weight",
    y = "Estimate",
    color = "Comparison Type"
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(FIG_DIR, "fig4a_bacon_weights.pdf"), fig4a, width = 8, height = 6)
ggsave(file.path(FIG_DIR, "fig4a_bacon_weights.png"), fig4a, width = 8, height = 6, dpi = 300)
ggsave(file.path(FIG_DIR, "fig4b_bacon_scatter.pdf"), fig4b, width = 8, height = 6)
ggsave(file.path(FIG_DIR, "fig4b_bacon_scatter.png"), fig4b, width = 8, height = 6, dpi = 300)

# ============================================================================
# FIGURE 5: EITC Generosity Distribution
# ============================================================================

cat("Creating Figure 5: EITC Generosity...\n")

# Get 2019 EITC generosity for states with EITC
generosity_2019 <- analysis_data %>%
  filter(year == 2019, treated == 1) %>%
  select(state_abbr, eitc_generosity) %>%
  arrange(desc(eitc_generosity))

fig5 <- ggplot(generosity_2019, aes(x = reorder(state_abbr, eitc_generosity), y = eitc_generosity)) +
  geom_col(fill = "#3498DB", alpha = 0.8) +
  geom_text(aes(label = sprintf("%.0f%%", eitc_generosity)), hjust = -0.1, size = 2.5) +
  coord_flip() +
  labs(
    title = "State EITC Generosity in 2019",
    subtitle = "Percentage of federal EITC credit",
    x = "State",
    y = "EITC Generosity (% of Federal)"
  ) +
  scale_y_continuous(limits = c(0, 120)) +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig5_eitc_generosity.pdf"), fig5, width = 8, height = 10)
ggsave(file.path(FIG_DIR, "fig5_eitc_generosity.png"), fig5, width = 8, height = 10, dpi = 300)

# ============================================================================
# FIGURE 6: Coefficient Plot (All Outcomes)
# ============================================================================

cat("Creating Figure 6: Coefficient Plot...\n")

# Run regressions for all outcomes
outcomes <- c("log_property_rate", "log_burglary_rate", "log_larceny_rate",
              "log_mvt_rate", "log_violent_rate")
outcome_labels <- c("Property Crime", "Burglary", "Larceny",
                    "Motor Vehicle Theft", "Violent Crime")

coef_data <- map2_dfr(outcomes, outcome_labels, function(outcome, label) {
  formula <- as.formula(paste0(outcome, " ~ treated | state_abbr + year"))
  model <- feols(formula, data = analysis_data, cluster = "state_abbr")

  tibble(
    outcome = label,
    estimate = coef(model)["treated"],
    se = se(model)["treated"],
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se
  )
}) %>%
  mutate(
    outcome = factor(outcome, levels = rev(outcome_labels)),
    significant = ci_lower > 0 | ci_upper < 0
  )

fig6 <- ggplot(coef_data, aes(x = estimate, y = outcome)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
  geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper), height = 0.2, color = "#2C3E50") +
  geom_point(aes(color = significant), size = 4) +
  scale_color_manual(values = c("FALSE" = "#2C3E50", "TRUE" = "#E74C3C"), guide = "none") +
  labs(
    title = "Effect of State EITC on Crime Rates",
    subtitle = "TWFE estimates with 95% confidence intervals (state-clustered SE)",
    x = "Coefficient (Log Crime Rate)",
    y = ""
  ) +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig6_coefficient_plot.pdf"), fig6, width = 9, height = 6)
ggsave(file.path(FIG_DIR, "fig6_coefficient_plot.png"), fig6, width = 9, height = 6, dpi = 300)

# ============================================================================
# Summary
# ============================================================================

cat("\n============================================\n")
cat("Figures saved to:", FIG_DIR, "\n")
cat("============================================\n")
cat("  - fig1_adoption_timing.pdf/png\n")
cat("  - fig2_pretrends.pdf/png\n")
cat("  - fig3_event_study.pdf/png\n")
cat("  - fig4a_bacon_weights.pdf/png\n")
cat("  - fig4b_bacon_scatter.pdf/png\n")
cat("  - fig5_eitc_generosity.pdf/png\n")
cat("  - fig6_coefficient_plot.pdf/png\n")
cat("============================================\n")
