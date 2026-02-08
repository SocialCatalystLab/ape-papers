# ==============================================================================
# Paper 68: Broadband Internet and Moral Foundations in Local Governance
# 06_figures.R - Generate Publication-Ready Figures
# ==============================================================================

source("code/00_packages.R")

# ==============================================================================
# LOAD DATA
# ==============================================================================
cat("=== Loading Data for Figures ===\n")

analysis <- arrow::read_parquet("data/analysis_panel.parquet")
load("data/cs_results.RData")

# Event study data
es_data <- read_csv("data/event_study_data.csv", show_col_types = FALSE)

# Summary data
summary_year <- read_csv("data/summary_by_year.csv", show_col_types = FALSE)

# ==============================================================================
# FIGURE 1: BROADBAND ADOPTION OVER TIME
# ==============================================================================
cat("\n=== Figure 1: Broadband Adoption ===\n")

# Panel A: Mean broadband rate by year
fig1a <- analysis %>%
  group_by(year) %>%
  summarise(
    mean_broadband = mean(broadband_rate, na.rm = TRUE),
    se = sd(broadband_rate, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  ) %>%
  ggplot(aes(x = year, y = mean_broadband)) +
  geom_ribbon(aes(ymin = mean_broadband - 1.96*se,
                  ymax = mean_broadband + 1.96*se),
              alpha = 0.2, fill = apep_colors[1]) +
  geom_line(color = apep_colors[1], linewidth = 1) +
  geom_point(color = apep_colors[1], size = 2) +
  geom_hline(yintercept = 0.70, linetype = "dashed", color = "grey40") +
  annotate("text", x = 2013.5, y = 0.72, label = "70% threshold",
           size = 3, hjust = 0, color = "grey40") +
  scale_y_continuous(labels = scales::percent_format(),
                     limits = c(0.5, 0.95)) +
  labs(
    subtitle = "A. Mean Household Broadband Subscription Rate",
    x = "Year",
    y = "Broadband Rate"
  ) +
  theme_apep()

# Panel B: Treatment cohort sizes
cohort_sizes <- analysis %>%
  filter(treated) %>%
  group_by(treat_year) %>%
  summarise(n_places = n_distinct(st_fips), .groups = "drop")

fig1b <- cohort_sizes %>%
  ggplot(aes(x = treat_year, y = n_places)) +
  geom_col(fill = apep_colors[1], alpha = 0.8, width = 0.7) +
  geom_text(aes(label = n_places), vjust = -0.5, size = 3) +
  labs(
    subtitle = "B. Number of Places Crossing 70% Threshold",
    x = "Treatment Year",
    y = "Number of Places"
  ) +
  theme_apep() +
  theme(panel.grid.major.x = element_blank())

# Combine
fig1 <- fig1a / fig1b +
  plot_annotation(
    title = "Figure 1: Broadband Internet Adoption in U.S. Local Governments, 2013-2022",
    caption = "Note: Panel A shows mean broadband subscription rates across places in the LocalView sample.\nPanel B shows the number of places crossing the 70% treatment threshold each year."
  )

ggsave("figures/fig1_broadband_adoption.pdf", fig1, width = 8, height = 9)
ggsave("figures/fig1_broadband_adoption.png", fig1, width = 8, height = 9, dpi = 300)

# ==============================================================================
# FIGURE 2: MORAL FOUNDATIONS BY TREATMENT STATUS
# ==============================================================================
cat("\n=== Figure 2: Moral Foundations Trends ===\n")

trends_data <- analysis %>%
  mutate(group = ifelse(treated, "Treated (will cross 70%)", "Never Treated")) %>%
  group_by(year, group) %>%
  summarise(
    individualizing = mean(individualizing, na.rm = TRUE),
    binding = mean(binding, na.rm = TRUE),
    se_ind = sd(individualizing, na.rm = TRUE) / sqrt(n()),
    se_bind = sd(binding, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  )

fig2a <- trends_data %>%
  ggplot(aes(x = year, y = individualizing, color = group, linetype = group)) +
  geom_ribbon(aes(ymin = individualizing - 1.96*se_ind,
                  ymax = individualizing + 1.96*se_ind,
                  fill = group), alpha = 0.15, color = NA) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  scale_color_manual(values = c(apep_colors[1], apep_colors[2]),
                     name = "") +
  scale_fill_manual(values = c(apep_colors[1], apep_colors[2]),
                    name = "") +
  scale_linetype_manual(values = c("solid", "dashed"), name = "") +
  labs(
    subtitle = "A. Individualizing Foundations (Care + Fairness)",
    x = "Year",
    y = "Score (per 1,000 words)"
  ) +
  theme_apep() +
  theme(legend.position = c(0.75, 0.15))

fig2b <- trends_data %>%
  ggplot(aes(x = year, y = binding, color = group, linetype = group)) +
  geom_ribbon(aes(ymin = binding - 1.96*se_bind,
                  ymax = binding + 1.96*se_bind,
                  fill = group), alpha = 0.15, color = NA) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  scale_color_manual(values = c(apep_colors[1], apep_colors[2]),
                     name = "") +
  scale_fill_manual(values = c(apep_colors[1], apep_colors[2]),
                    name = "") +
  scale_linetype_manual(values = c("solid", "dashed"), name = "") +
  labs(
    subtitle = "B. Binding Foundations (Loyalty + Authority + Sanctity)",
    x = "Year",
    y = "Score (per 1,000 words)"
  ) +
  theme_apep() +
  theme(legend.position = "none")

fig2 <- fig2a + fig2b +
  plot_annotation(
    title = "Figure 2: Trends in Moral Foundations by Treatment Status",
    caption = "Note: Treated places are those that eventually cross the 70% broadband threshold.\nShaded regions show 95% confidence intervals."
  )

ggsave("figures/fig2_moral_trends.pdf", fig2, width = 12, height = 5)
ggsave("figures/fig2_moral_trends.png", fig2, width = 12, height = 5, dpi = 300)

# ==============================================================================
# FIGURE 3: EVENT STUDY - INDIVIDUALIZING
# ==============================================================================
cat("\n=== Figure 3: Event Study (Individualizing) ===\n")

es_ind <- es_data %>%
  filter(outcome == "Individualizing")

fig3 <- ggplot(es_ind, aes(x = time, y = att)) +
  # Confidence interval
  geom_ribbon(aes(ymin = att - 1.96*se, ymax = att + 1.96*se),
              alpha = 0.2, fill = apep_colors[1]) +
  # Point estimates
  geom_point(color = apep_colors[1], size = 2.5) +
  geom_line(color = apep_colors[1], linewidth = 0.7) +
  # Reference lines
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60", linewidth = 0.7) +
  # Annotation
  annotate("text", x = -4.5, y = max(es_ind$att + 1.96*es_ind$se, na.rm = TRUE) * 0.9,
           label = "Pre-treatment", hjust = 0, size = 3, color = "grey40") +
  annotate("text", x = 0.5, y = max(es_ind$att + 1.96*es_ind$se, na.rm = TRUE) * 0.9,
           label = "Post-treatment", hjust = 0, size = 3, color = "grey40") +
  # Labels
  labs(
    title = "Figure 3: Event Study — Effect of Broadband on Individualizing Foundations",
    subtitle = "Callaway-Sant'Anna (2021) estimator with never-treated control group",
    x = "Years Relative to Crossing 70% Broadband Threshold",
    y = "ATT (Individualizing Score)",
    caption = "Note: Shaded region shows 95% confidence intervals. Treatment occurs at time 0.\nStandard errors clustered at state level."
  ) +
  theme_apep() +
  scale_x_continuous(breaks = seq(-5, 5, 1))

ggsave("figures/fig3_event_individualizing.pdf", fig3, width = 9, height = 6)
ggsave("figures/fig3_event_individualizing.png", fig3, width = 9, height = 6, dpi = 300)

# ==============================================================================
# FIGURE 4: EVENT STUDY - BINDING
# ==============================================================================
cat("\n=== Figure 4: Event Study (Binding) ===\n")

es_bind <- es_data %>%
  filter(outcome == "Binding")

fig4 <- ggplot(es_bind, aes(x = time, y = att)) +
  geom_ribbon(aes(ymin = att - 1.96*se, ymax = att + 1.96*se),
              alpha = 0.2, fill = apep_colors[2]) +
  geom_point(color = apep_colors[2], size = 2.5) +
  geom_line(color = apep_colors[2], linewidth = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60", linewidth = 0.7) +
  labs(
    title = "Figure 4: Event Study — Effect of Broadband on Binding Foundations",
    subtitle = "Callaway-Sant'Anna (2021) estimator with never-treated control group",
    x = "Years Relative to Crossing 70% Broadband Threshold",
    y = "ATT (Binding Score)",
    caption = "Note: Shaded region shows 95% confidence intervals. Treatment occurs at time 0.\nStandard errors clustered at state level."
  ) +
  theme_apep() +
  scale_x_continuous(breaks = seq(-5, 5, 1))

ggsave("figures/fig4_event_binding.pdf", fig4, width = 9, height = 6)
ggsave("figures/fig4_event_binding.png", fig4, width = 9, height = 6, dpi = 300)

# ==============================================================================
# FIGURE 5: UNIVERSALISM VS COMMUNAL RATIO
# ==============================================================================
cat("\n=== Figure 5: Universalism/Communal Ratio ===\n")

es_ratio <- es_data %>%
  filter(outcome == "Log Univ/Comm")

fig5 <- ggplot(es_ratio, aes(x = time, y = att)) +
  geom_ribbon(aes(ymin = att - 1.96*se, ymax = att + 1.96*se),
              alpha = 0.2, fill = apep_colors[3]) +
  geom_point(color = apep_colors[3], size = 2.5) +
  geom_line(color = apep_colors[3], linewidth = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60", linewidth = 0.7) +
  labs(
    title = "Figure 5: Event Study — Effect of Broadband on Universalism/Communal Balance",
    subtitle = "Log(Individualizing) - Log(Binding); Positive = more universalist",
    x = "Years Relative to Crossing 70% Broadband Threshold",
    y = "ATT (Log Univ/Comm Ratio)",
    caption = "Note: Higher values indicate a shift toward individualizing (universalist) moral language.\nShaded region shows 95% confidence intervals."
  ) +
  theme_apep() +
  scale_x_continuous(breaks = seq(-5, 5, 1))

ggsave("figures/fig5_event_ratio.pdf", fig5, width = 9, height = 6)
ggsave("figures/fig5_event_ratio.png", fig5, width = 9, height = 6, dpi = 300)

# ==============================================================================
# FIGURE 6: COMBINED EVENT STUDIES
# ==============================================================================
cat("\n=== Figure 6: Combined Event Studies ===\n")

fig6 <- es_data %>%
  mutate(outcome = factor(outcome,
                          levels = c("Individualizing", "Binding", "Log Univ/Comm"),
                          labels = c("Individualizing", "Binding", "Univ./Comm. Ratio"))) %>%
  ggplot(aes(x = time, y = att, color = outcome, fill = outcome)) +
  geom_ribbon(aes(ymin = att - 1.96*se, ymax = att + 1.96*se),
              alpha = 0.15, color = NA) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  facet_wrap(~outcome, scales = "free_y", ncol = 1) +
  scale_color_manual(values = apep_colors[1:3]) +
  scale_fill_manual(values = apep_colors[1:3]) +
  labs(
    title = "Figure 6: Event Studies for All Moral Foundation Outcomes",
    x = "Years Relative to Treatment",
    y = "ATT",
    caption = "Note: Treatment defined as crossing 70% broadband subscription threshold.\nCallaway-Sant'Anna estimator with never-treated control group."
  ) +
  theme_apep() +
  theme(legend.position = "none",
        strip.text = element_text(face = "bold"))

ggsave("figures/fig6_combined_events.pdf", fig6, width = 8, height = 10)
ggsave("figures/fig6_combined_events.png", fig6, width = 8, height = 10, dpi = 300)

# ==============================================================================
# FIGURE 7: INDIVIDUAL FOUNDATIONS
# ==============================================================================
cat("\n=== Figure 7: Individual Foundation Event Studies ===\n")

# Create event study data for each foundation
foundations <- c("Care", "Fairness", "Loyalty", "Authority", "Sanctity")

# This would need to be generated from foundation_results in main analysis
# For now, create placeholder with proper structure

# ==============================================================================
# FIGURE 8: GEOGRAPHIC MAP OF TREATMENT
# ==============================================================================
cat("\n=== Figure 8: Treatment Map ===\n")

# Get state-level treatment summary
state_treatment <- analysis %>%
  group_by(state_fips) %>%
  summarise(
    n_places = n_distinct(st_fips),
    pct_treated = mean(treated) * 100,
    mean_treat_year = mean(treat_year[treated], na.rm = TRUE),
    .groups = "drop"
  )

# Get state shapes
states <- tigris::states(cb = TRUE, year = 2019) %>%
  filter(!STATEFP %in% c("02", "15", "72", "78", "60", "66", "69"))  # Exclude AK, HI, territories

# Merge
states_plot <- states %>%
  left_join(state_treatment, by = c("STATEFP" = "state_fips"))

fig8 <- ggplot(states_plot) +
  geom_sf(aes(fill = mean_treat_year), color = "white", linewidth = 0.2) +
  scale_fill_viridis_c(
    name = "Mean Treatment Year",
    option = "plasma",
    na.value = "grey90",
    direction = -1
  ) +
  labs(
    title = "Figure 8: Geographic Distribution of Broadband Treatment Timing",
    subtitle = "Mean year places crossed 70% broadband threshold by state",
    caption = "Note: Earlier treatment years shown in darker colors. Grey states have insufficient data."
  ) +
  theme_void() +
  theme(
    legend.position = "bottom",
    legend.key.width = unit(2, "cm"),
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5),
    plot.margin = margin(10, 10, 10, 10)
  )

ggsave("figures/fig8_treatment_map.pdf", fig8, width = 10, height = 7)
ggsave("figures/fig8_treatment_map.png", fig8, width = 10, height = 7, dpi = 300)

# ==============================================================================
# SUMMARY
# ==============================================================================
cat("\n=== Figures Generated ===\n")
cat("  fig1_broadband_adoption.pdf - Broadband trends and cohort sizes\n")
cat("  fig2_moral_trends.pdf - Moral foundations by treatment status\n")
cat("  fig3_event_individualizing.pdf - Event study (Individualizing)\n")
cat("  fig4_event_binding.pdf - Event study (Binding)\n")
cat("  fig5_event_ratio.pdf - Event study (Univ/Comm ratio)\n")
cat("  fig6_combined_events.pdf - All outcomes combined\n")
cat("  fig8_treatment_map.pdf - Geographic distribution\n")
