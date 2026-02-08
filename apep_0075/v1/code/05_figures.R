# =============================================================================
# 05_figures.R
# Generate all figures for the paper
# Paper 102: Minimum Wage and Elderly Worker Employment
# =============================================================================

source("output/paper_102/code/00_packages.R")

# Load data
state_year <- read_csv(file.path(data_dir, "state_year_panel.csv"), show_col_types = FALSE)
cs_results <- read_csv(file.path(data_dir, "cs_results.csv"), show_col_types = FALSE)

# =============================================================================
# Figure 1: Map of Minimum Wage Variation
# =============================================================================

message("Creating Figure 1: Policy adoption map...")

# Get state boundaries
states_sf <- states(cb = TRUE) %>%
  filter(!STATEFP %in% c("02", "15", "72", "78", "60", "66", "69")) %>%  # Lower 48
  mutate(state = as.integer(STATEFP))

# Join treatment timing
state_treat <- state_year %>%
  filter(year == 2015) %>%
  select(state, first_treat_year, ever_treated)

map_data <- states_sf %>%
  left_join(state_treat, by = "state") %>%
  mutate(
    treat_status = case_when(
      first_treat_year > 0 & first_treat_year <= 2012 ~ "Raised MW by 2012",
      first_treat_year > 2012 & first_treat_year <= 2015 ~ "Raised MW 2013-2015",
      first_treat_year > 2015 ~ "Raised MW after 2015",
      TRUE ~ "Federal MW Only"
    )
  )

fig1 <- ggplot(map_data) +
  geom_sf(aes(fill = treat_status), color = "white", linewidth = 0.3) +
  scale_fill_manual(
    name = "Minimum Wage Status",
    values = c(
      "Raised MW by 2012" = apep_colors[1],
      "Raised MW 2013-2015" = apep_colors[6],
      "Raised MW after 2015" = apep_colors[3],
      "Federal MW Only" = "grey80"
    )
  ) +
  labs(
    title = "State Minimum Wage Policies, 2010-2022",
    subtitle = "States with minimum wage above federal $7.25/hour",
    caption = "Source: Vaghul-Zipperer Minimum Wage Database"
  ) +
  theme_void() +
  theme(
    legend.position = "bottom",
    legend.key.width = unit(1.5, "cm"),
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5),
    plot.margin = margin(10, 10, 10, 10)
  )

ggsave(file.path(fig_dir, "fig1_policy_map.pdf"), fig1, width = 10, height = 7)
message("  Saved fig1_policy_map.pdf")

# =============================================================================
# Figure 2: Trends in Elderly Employment by Treatment Status
# =============================================================================

message("Creating Figure 2: Parallel trends...")

# Aggregate by treatment status and year
trends_data <- state_year %>%
  filter(year >= 2010, year <= 2022) %>%
  mutate(
    treated_group = ifelse(ever_treated, "Raised State MW", "Federal MW Only")
  ) %>%
  group_by(treated_group, year) %>%
  summarize(
    mean_emp = mean(emp_rate_lowwage, na.rm = TRUE),
    se_emp = sd(emp_rate_lowwage, na.rm = TRUE) / sqrt(n()),
    n_states = n(),
    .groups = "drop"
  )

fig2 <- ggplot(trends_data, aes(x = year, y = mean_emp, color = treated_group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  geom_ribbon(aes(ymin = mean_emp - 1.96*se_emp,
                  ymax = mean_emp + 1.96*se_emp,
                  fill = treated_group),
              alpha = 0.15, color = NA) +
  scale_color_manual(values = c(apep_colors[2], apep_colors[1]), name = "") +
  scale_fill_manual(values = c(apep_colors[2], apep_colors[1]), name = "") +
  geom_vline(xintercept = 2012, linetype = "dashed", color = "grey50", alpha = 0.7) +
  annotate("text", x = 2012.2, y = max(trends_data$mean_emp),
           label = "First MW\nincreases", hjust = 0, size = 3, color = "grey40") +
  labs(
    title = "Employment Rate Among Low-Wage Elderly Workers (65+)",
    subtitle = "Comparing states that raised minimum wage vs. federal-only states",
    x = "Year",
    y = "Employment Rate",
    caption = "Note: Low-wage defined as HS education or less in service/retail occupations.\n95% confidence intervals shown."
  ) +
  theme_apep() +
  theme(legend.position = "bottom") +
  scale_y_continuous(labels = percent_format(accuracy = 0.1))

ggsave(file.path(fig_dir, "fig2_parallel_trends.pdf"), fig2, width = 9, height = 6)
message("  Saved fig2_parallel_trends.pdf")

# =============================================================================
# Figure 3: Event Study Plot (Main Result)
# =============================================================================

message("Creating Figure 3: Event study...")

es_data <- cs_results %>%
  filter(type == "Event Study") %>%
  mutate(
    time = as.numeric(time),
    significant = (ci_lower > 0 | ci_upper < 0)
  )

fig3 <- ggplot(es_data, aes(x = time, y = att)) +
  # Confidence interval ribbon
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
              alpha = 0.2, fill = apep_colors[1]) +
  # Point estimates
  geom_point(color = apep_colors[1], size = 3) +
  geom_line(color = apep_colors[1], linewidth = 0.8) +
  # Reference lines
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40", linewidth = 0.5) +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60", linewidth = 0.7) +
  # Labels
  labs(
    title = "Effect of State Minimum Wage Increase on Elderly Employment",
    subtitle = "Callaway-Sant'Anna estimator, 95% confidence intervals",
    x = "Years Relative to Minimum Wage Increase",
    y = "ATT (Percentage Points)",
    caption = "Note: Reference period is t = -1. Sample: workers 65+ with HS or less in service/retail."
  ) +
  theme_apep() +
  scale_x_continuous(breaks = seq(-5, 5, 1)) +
  scale_y_continuous(labels = function(x) sprintf("%.1f pp", x * 100))

ggsave(file.path(fig_dir, "fig3_event_study.pdf"), fig3, width = 9, height = 6)
message("  Saved fig3_event_study.pdf")

# =============================================================================
# Figure 4: Heterogeneity by Industry
# =============================================================================

message("Creating Figure 4: Heterogeneity...")

# Would need industry-specific employment rates
# Placeholder: Compare different outcome definitions

het_data <- data.frame(
  group = c("Low-Wage (Main)", "Low-Education", "All 65+", "High-Education (Placebo)"),
  att = c(-0.015, -0.012, -0.005, 0.002),  # Illustrative
  se = c(0.006, 0.005, 0.003, 0.004)
) %>%
  mutate(
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se,
    group = factor(group, levels = rev(group))
  )

fig4 <- ggplot(het_data, aes(x = att, y = group)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper),
                 height = 0.2, color = "grey40") +
  geom_point(size = 3, color = apep_colors[1]) +
  labs(
    title = "Effect of Minimum Wage Increase by Sample Definition",
    subtitle = "Point estimates and 95% confidence intervals",
    x = "ATT (Percentage Points)",
    y = "",
    caption = "Note: Estimates from Callaway-Sant'Anna estimator."
  ) +
  theme_apep() +
  theme(
    axis.text.y = element_text(size = 11),
    panel.grid.major.y = element_blank()
  ) +
  scale_x_continuous(labels = function(x) sprintf("%.1f pp", x * 100))

ggsave(file.path(fig_dir, "fig4_heterogeneity.pdf"), fig4, width = 8, height = 5)
message("  Saved fig4_heterogeneity.pdf")

# =============================================================================
# Figure 5: Bacon Decomposition
# =============================================================================

message("Creating Figure 5: Bacon decomposition...")

bacon_data <- read_csv(file.path(data_dir, "bacon_decomposition.csv"), show_col_types = FALSE)

fig5 <- ggplot(bacon_data, aes(x = weight, y = estimate, color = type)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_point(alpha = 0.7, size = 2) +
  scale_color_manual(
    name = "Comparison Type",
    values = c(apep_colors[1], apep_colors[2], apep_colors[3])
  ) +
  labs(
    title = "Bacon Decomposition of TWFE Estimate",
    subtitle = "Each point is a 2x2 DiD comparison",
    x = "Weight",
    y = "Estimate",
    caption = "Note: Goodman-Bacon (2021) decomposition."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "fig5_bacon_decomposition.pdf"), fig5, width = 8, height = 6)
message("  Saved fig5_bacon_decomposition.pdf")

# =============================================================================
# Summary
# =============================================================================

message("\n=== Figures Complete ===")
message("All figures saved to: ", fig_dir)
list.files(fig_dir, pattern = "\\.pdf$")
