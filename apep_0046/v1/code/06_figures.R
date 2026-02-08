# ==============================================================================
# Paper 63: State EITC and Single Mothers' Self-Employment
# 06_figures.R - Create publication-quality figures
# ==============================================================================

source("00_packages.R")

# ==============================================================================
# Load data
# ==============================================================================

event_coefs <- read_csv(file.path(data_path, "event_study_coefs.csv"), show_col_types = FALSE)
main_sample <- read_csv(file.path(data_path, "cps_main_sample.csv"), show_col_types = FALSE)
state_eitc <- read_csv(file.path(data_path, "state_eitc_panel.csv"), show_col_types = FALSE)

# ==============================================================================
# Figure 1: Event Study Plot
# ==============================================================================

fig1 <- ggplot(event_coefs, aes(x = event_time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray70") +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, fill = apep_colors[1]) +
  geom_point(color = apep_colors[1], size = 3) +
  geom_line(color = apep_colors[1], linewidth = 0.8) +
  scale_x_continuous(breaks = seq(-5, 5, 1)) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  labs(
    title = "Event Study: Effect of State EITC on Self-Employment",
    subtitle = "Single mothers ages 18-55, CPS ASEC 2014-2023",
    x = "Years Relative to State EITC Adoption",
    y = "Effect on Self-Employment Rate",
    caption = "Notes: 95% confidence intervals shown. Reference period is t=-1 (year before adoption).\nStandard errors clustered at state level."
  ) +
  theme_apep() +
  annotate("text", x = -3, y = 0.015, label = "Pre-treatment", color = "gray50", size = 3.5) +
  annotate("text", x = 2, y = 0.015, label = "Post-treatment", color = "gray50", size = 3.5)

ggsave(file.path(fig_path, "fig1_event_study.pdf"), fig1, width = 8, height = 5.5)
ggsave(file.path(fig_path, "fig1_event_study.png"), fig1, width = 8, height = 5.5, dpi = 300)

message("Figure 1 saved: Event Study")

# ==============================================================================
# Figure 2: State EITC Adoption Timeline
# ==============================================================================

# Get adoption year for each state (alternative to map)
adoption_timeline <- state_eitc %>%
  filter(!is.infinite(cohort)) %>%
  select(state, cohort) %>%
  distinct() %>%
  arrange(cohort) %>%
  mutate(state_abbr = state.abb[match(state, state.name)])

fig2 <- ggplot(adoption_timeline, aes(x = cohort, y = reorder(state, -cohort))) +
  geom_point(color = apep_colors[1], size = 3) +
  geom_segment(aes(xend = 2023, yend = state), color = apep_colors[1], alpha = 0.3) +
  scale_x_continuous(breaks = seq(1985, 2025, 5), limits = c(1985, 2025)) +
  labs(
    title = "State EITC Adoption Timeline",
    subtitle = "Year of state EITC enactment by state",
    x = "Year Enacted",
    y = "",
    caption = "Notes: 33 states have enacted state EITCs. Lines extend to 2023 (end of sample)."
  ) +
  theme_apep() +
  theme(axis.text.y = element_text(size = 7))

ggsave(file.path(fig_path, "fig2_adoption_timeline.pdf"), fig2, width = 8, height = 10)
ggsave(file.path(fig_path, "fig2_adoption_timeline.png"), fig2, width = 8, height = 10, dpi = 300)

message("Figure 2 saved: Adoption Timeline")

# ==============================================================================
# Figure 3: Self-Employment Trends by EITC Status
# ==============================================================================

trends_data <- main_sample %>%
  mutate(eitc_group = ifelse(has_state_eitc == 1, "State EITC States", "No State EITC")) %>%
  group_by(year, eitc_group) %>%
  summarise(
    self_emp_rate = weighted.mean(self_employed, weight, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  )

fig3 <- ggplot(trends_data, aes(x = year, y = self_emp_rate, color = eitc_group, shape = eitc_group)) +
  geom_point(size = 3) +
  geom_line(linewidth = 0.8) +
  scale_color_manual(values = c("State EITC States" = apep_colors[1], "No State EITC" = apep_colors[2]),
                     name = "") +
  scale_shape_manual(values = c("State EITC States" = 16, "No State EITC" = 17), name = "") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  scale_x_continuous(breaks = seq(2014, 2023, 2)) +
  labs(
    title = "Self-Employment Rates Among Single Mothers",
    subtitle = "By state EITC status, CPS ASEC 2014-2023",
    x = "Year",
    y = "Self-Employment Rate",
    caption = "Notes: Weighted by CPS ASEC survey weights. State EITC status based on each state-year."
  ) +
  theme_apep() +
  theme(legend.position = c(0.8, 0.9))

ggsave(file.path(fig_path, "fig3_trends.pdf"), fig3, width = 8, height = 5.5)
ggsave(file.path(fig_path, "fig3_trends.png"), fig3, width = 8, height = 5.5, dpi = 300)

message("Figure 3 saved: Trends")

# ==============================================================================
# Figure 4: Coefficient Comparison (Main vs Placebo)
# ==============================================================================

coef_comparison <- tibble(
  group = c("Single Mothers\n(Main Sample)", "Childless Women\n(Placebo)"),
  estimate = c(-0.0127, -0.0050),
  std_error = c(0.0062, 0.0047),
  ci_lower = estimate - 1.96 * std_error,
  ci_upper = estimate + 1.96 * std_error
)

fig4 <- ggplot(coef_comparison, aes(x = group, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.15, linewidth = 0.8, color = apep_colors[1]) +
  geom_point(size = 4, color = apep_colors[1]) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  labs(
    title = "Effect of State EITC on Self-Employment",
    subtitle = "Main sample vs. placebo comparison",
    x = "",
    y = "Effect on Self-Employment Rate",
    caption = "Notes: 95% confidence intervals shown. Standard errors clustered at state level.\nPlacebo group (childless women) should show no effect if EITC mechanism is correct."
  ) +
  theme_apep()

ggsave(file.path(fig_path, "fig4_coef_comparison.pdf"), fig4, width = 6, height = 5)
ggsave(file.path(fig_path, "fig4_coef_comparison.png"), fig4, width = 6, height = 5, dpi = 300)

message("Figure 4 saved: Coefficient Comparison")

message("\nAll figures saved to: ", fig_path)
