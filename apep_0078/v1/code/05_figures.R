# ============================================================================
# 05_figures.R
# State Minimum Wage and Business Establishments
# Generate all figures - ANNUAL FREQUENCY
# ============================================================================

source("00_packages.R")

data_dir <- "../data/"
tables_dir <- "../tables/"
figures_dir <- "../figures/"
dir.create(figures_dir, showWarnings = FALSE, recursive = TRUE)

# ============================================================================
# 1. Load data
# ============================================================================

cat("Loading data...\n")

analysis_panel <- read_csv(paste0(data_dir, "analysis_panel.csv"), show_col_types = FALSE)

# Load event study coefficients if they exist
if (file.exists(paste0(tables_dir, "event_study_coefs.csv"))) {
  event_coefs <- read_csv(paste0(tables_dir, "event_study_coefs.csv"), show_col_types = FALSE)
}

# ============================================================================
# Figure 1: Minimum Wage Variation Across States (ANNUAL)
# ============================================================================

cat("Creating Figure 1: Minimum Wage Variation...\n")

# State MW over time (selected states)
highlight_states <- c("CA", "NY", "WA", "FL", "TX", "PA")

mw_trends <- analysis_panel %>%
  select(state_abbr, year, annual_avg_mw) %>%
  distinct()

fig1 <- ggplot() +
  # All states in gray
  geom_line(
    data = mw_trends %>% filter(!(state_abbr %in% highlight_states)),
    aes(x = year, y = annual_avg_mw, group = state_abbr),
    color = "gray80", alpha = 0.5, linewidth = 0.3
  ) +
  # Highlight states
  geom_line(
    data = mw_trends %>% filter(state_abbr %in% highlight_states),
    aes(x = year, y = annual_avg_mw, color = state_abbr),
    linewidth = 1
  ) +
  # Federal minimum wage
  geom_hline(yintercept = 7.25, linetype = "dashed", color = "gray40") +
  annotate("text", x = 2013, y = 7.5, label = "Federal MW ($7.25)", hjust = 0, size = 3) +
  scale_color_brewer(palette = "Set1", name = "State") +
  scale_y_continuous(labels = dollar_format(), breaks = seq(5, 18, 2)) +
  labs(
    title = "State Minimum Wage Variation, 2012-2021",
    subtitle = "Gray lines show all states; colored lines highlight selected states",
    x = "Year",
    y = "Annual Average Minimum Wage (Nominal)",
    caption = "Source: Authors' compilation from DOL and state labor department records"
  ) +
  theme_apep()

ggsave(paste0(figures_dir, "fig1_mw_variation.pdf"), fig1, width = 10, height = 6)
ggsave(paste0(figures_dir, "fig1_mw_variation.png"), fig1, width = 10, height = 6, dpi = 300)

# ============================================================================
# Figure 2: Establishment Counts Over Time
# ============================================================================

cat("Creating Figure 2: Establishment Trends...\n")

est_trends <- analysis_panel %>%
  group_by(year) %>%
  summarize(
    total_establishments = sum(establishments, na.rm = TRUE),
    .groups = "drop"
  )

fig2 <- ggplot(est_trends, aes(x = year, y = total_establishments / 1e6)) +
  geom_line(color = apep_colors["primary"], linewidth = 1) +
  geom_point(color = apep_colors["primary"], size = 2) +
  scale_y_continuous(labels = comma_format(suffix = "M")) +
  labs(
    title = "Total Business Establishments in the United States",
    subtitle = "Annual establishment counts from Census County Business Patterns",
    x = "Year",
    y = "Total Establishments (Millions)",
    caption = "Source: Census Bureau County Business Patterns"
  ) +
  theme_apep()

ggsave(paste0(figures_dir, "fig2_est_trends.pdf"), fig2, width = 10, height = 5)
ggsave(paste0(figures_dir, "fig2_est_trends.png"), fig2, width = 10, height = 5, dpi = 300)

# ============================================================================
# Figure 3: Event Study (KEY FIGURE)
# ============================================================================

cat("Creating Figure 3: Event Study...\n")

if (exists("event_coefs") && nrow(event_coefs) > 0) {
  # Add reference period (rel_year = -1, coefficient = 0)
  event_plot_data <- event_coefs %>%
    bind_rows(tibble(rel_year = -1, estimate = 0, se = 0, ci_lower = 0, ci_upper = 0)) %>%
    arrange(rel_year)

  fig3 <- ggplot(event_plot_data, aes(x = rel_year, y = estimate)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "gray50") +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, fill = apep_colors["tertiary"]) +
    geom_point(color = apep_colors["primary"], size = 3) +
    geom_line(color = apep_colors["primary"], linewidth = 0.8) +
    scale_x_continuous(breaks = seq(-5, 5, 1)) +
    labs(
      title = "Event Study: Effect of Above-Federal Minimum Wage on Establishments",
      subtitle = "Coefficients relative to year before state MW exceeds federal floor",
      x = "Years Relative to Treatment",
      y = "Effect on Log(Establishments)",
      caption = "Notes: Vertical dashed line indicates treatment. 95% confidence intervals shown.\nOmitted category: t = -1 (year before treatment)."
    ) +
    theme_apep()

  ggsave(paste0(figures_dir, "fig3_event_study.pdf"), fig3, width = 9, height = 6)
  ggsave(paste0(figures_dir, "fig3_event_study.png"), fig3, width = 9, height = 6, dpi = 300)
} else {
  cat("  No event study coefficients found, skipping Figure 3\n")
}

# ============================================================================
# Figure 4: Treatment Timing Distribution
# ============================================================================

cat("Creating Figure 4: Treatment Timing...\n")

# Get first year above federal for each state
treatment_timing <- analysis_panel %>%
  filter(above_federal) %>%
  group_by(state_abbr) %>%
  summarize(first_year = min(year), .groups = "drop")

# States that never went above
never_treat <- analysis_panel %>%
  distinct(state_abbr) %>%
  filter(!(state_abbr %in% treatment_timing$state_abbr)) %>%
  mutate(first_year = 2025)  # Code as "never"

treatment_map_data <- bind_rows(treatment_timing, never_treat) %>%
  mutate(
    period = case_when(
      first_year == 2025 ~ "Never (Federal Only)",
      first_year <= 2012 ~ "At Sample Start (2012)",
      first_year < 2017 ~ "2013-2016",
      first_year < 2020 ~ "2017-2019",
      TRUE ~ "2020+"
    )
  ) %>%
  mutate(period = factor(period, levels = c("At Sample Start (2012)", "2013-2016",
                                             "2017-2019", "2020+",
                                             "Never (Federal Only)")))

fig4 <- ggplot(treatment_map_data, aes(x = period, fill = period)) +
  geom_bar() +
  geom_text(stat = "count", aes(label = after_stat(count)), vjust = -0.5) +
  scale_fill_viridis_d(option = "plasma", begin = 0.2, end = 0.8) +
  labs(
    title = "Timing of State Minimum Wage Adoption Above Federal Floor",
    subtitle = "Number of jurisdictions by period of first above-federal minimum wage",
    x = "Period of First Above-Federal MW",
    y = "Number of Jurisdictions",
    caption = "Note: 'Never' indicates jurisdictions that have not exceeded the federal minimum wage of $7.25."
  ) +
  theme_apep() +
  theme(legend.position = "none")

ggsave(paste0(figures_dir, "fig4_adoption_timing.pdf"), fig4, width = 8, height = 5)
ggsave(paste0(figures_dir, "fig4_adoption_timing.png"), fig4, width = 8, height = 5, dpi = 300)

cat("\nAll figures saved to: ", figures_dir, "\n")
