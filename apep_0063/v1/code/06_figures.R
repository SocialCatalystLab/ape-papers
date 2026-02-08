# ============================================================================
# Paper 81: State Heat Protection Standards and Worker Safety
# 06_figures.R - Generate publication-quality figures
# ============================================================================

# Source packages script (relative path)
source(file.path(dirname(sys.frame(1)$ofile %||% "."), "00_packages.R"))

# Load data and results
panel <- read_csv(file.path(DATA_DIR, "heat_panel.csv"), show_col_types = FALSE)
results <- readRDS(file.path(DATA_DIR, "analysis_results.rds"))

# ============================================================================
# FIGURE 1: National Heat Death Trends
# ============================================================================

national <- panel %>%
  group_by(year) %>%
  summarize(
    total_deaths = sum(heat_deaths_imputed, na.rm = TRUE),
    .groups = "drop"
  )

fig1 <- ggplot(national, aes(x = year, y = total_deaths)) +
  geom_line(color = apep_colors["estimate"], linewidth = 1) +
  geom_point(color = apep_colors["estimate"], size = 2) +
  # Add policy markers
  geom_vline(xintercept = 2006, linetype = "dashed", color = "gray50", alpha = 0.7) +
  annotate("text", x = 2006, y = 55, label = "CA", hjust = -0.2, size = 3, color = "gray40") +
  geom_vline(xintercept = 2022, linetype = "dashed", color = "gray50", alpha = 0.7) +
  annotate("text", x = 2022, y = 55, label = "CO/OR", hjust = -0.2, size = 3, color = "gray40") +
  labs(
    title = "Heat-Related Occupational Fatalities in the United States",
    subtitle = "Dashed lines indicate state heat standard adoptions",
    x = "Year",
    y = "Number of Deaths",
    caption = "Source: BLS Census of Fatal Occupational Injuries (CFOI)"
  ) +
  scale_x_continuous(breaks = seq(1995, 2020, 5)) +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig1_national_trends.pdf"), fig1, width = 8, height = 5)
ggsave(file.path(FIG_DIR, "fig1_national_trends.png"), fig1, width = 8, height = 5, dpi = 300)

# ============================================================================
# FIGURE 2: California vs Synthetic California
# ============================================================================

synth_results <- results$synth_results

# Pre-treatment data for the plot
ca_all <- panel %>%
  filter(state_abbr == "CA") %>%
  select(year, ca_heat_rate = heat_rate)

# Get synthetic for all years
never_treated_states <- panel %>%
  filter(is.infinite(treat_year)) %>%
  pull(state_abbr) %>%
  unique()

# Top donors (from analysis)
top_donors <- c("VA", "DE", "ME", "TX", "NH", "VT", "NJ", "NE", "SD", "OK")

synth_all <- panel %>%
  filter(state_abbr %in% top_donors) %>%
  group_by(year) %>%
  summarize(synth_heat_rate = mean(heat_rate, na.rm = TRUE), .groups = "drop")

plot_data <- ca_all %>%
  left_join(synth_all, by = "year") %>%
  pivot_longer(
    cols = c(ca_heat_rate, synth_heat_rate),
    names_to = "series",
    values_to = "heat_rate"
  ) %>%
  mutate(
    series = if_else(series == "ca_heat_rate", "California", "Synthetic California")
  )

fig2 <- ggplot(plot_data, aes(x = year, y = heat_rate, color = series, linetype = series)) +
  geom_line(linewidth = 1) +
  geom_point(size = 1.5) +
  geom_vline(xintercept = 2006, linetype = "dashed", color = "gray50") +
  annotate("text", x = 2006, y = max(plot_data$heat_rate) * 0.95,
           label = "CA Heat Standard\n(Aug 2005)", hjust = -0.1, size = 3, color = "gray40") +
  scale_color_manual(
    values = c("California" = "#E64B35", "Synthetic California" = "#4DBBD5"),
    name = ""
  ) +
  scale_linetype_manual(
    values = c("California" = "solid", "Synthetic California" = "dashed"),
    name = ""
  ) +
  labs(
    title = "California vs. Synthetic Control",
    subtitle = "Heat-related fatality rate per 100,000 workers",
    x = "Year",
    y = "Heat Fatality Rate (per 100,000)",
    caption = "Note: Synthetic California constructed from 10 highest-correlation donor states"
  ) +
  scale_x_continuous(breaks = seq(1995, 2020, 5)) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(FIG_DIR, "fig2_synthetic_control.pdf"), fig2, width = 8, height = 5)
ggsave(file.path(FIG_DIR, "fig2_synthetic_control.png"), fig2, width = 8, height = 5, dpi = 300)

# ============================================================================
# FIGURE 3: Event Study (Callaway-Sant'Anna)
# ============================================================================

cs_es <- results$cs_eventstudy

# Extract event study estimates
es_data <- tibble(
  time = cs_es$egt,
  estimate = cs_es$att.egt,
  se = cs_es$se.egt
) %>%
  mutate(
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se
  ) %>%
  filter(time >= -15, time <= 17)  # Restrict to reasonable window

fig3 <- ggplot(es_data, aes(x = time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "solid", color = "gray70") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray50") +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), fill = apep_colors["ci"], alpha = 0.3) +
  geom_line(color = apep_colors["estimate"], linewidth = 0.8) +
  geom_point(color = apep_colors["estimate"], size = 2) +
  labs(
    title = "Event Study: Effect of Heat Standards on Fatality Rates",
    subtitle = "Callaway-Sant'Anna estimates with 95% confidence bands",
    x = "Years Relative to Treatment",
    y = "ATT (Change in Fatality Rate)",
    caption = "Note: Vertical dashed line indicates treatment onset (year 0)"
  ) +
  scale_x_continuous(breaks = seq(-15, 15, 5)) +
  theme_apep()

ggsave(file.path(FIG_DIR, "fig3_event_study.pdf"), fig3, width = 8, height = 5)
ggsave(file.path(FIG_DIR, "fig3_event_study.png"), fig3, width = 8, height = 5, dpi = 300)

# ============================================================================
# FIGURE 4: State Adoption Map (skipped - sf package not available)
# ============================================================================

cat("\nNote: Map figure skipped (sf/tigris packages not installed)\n")

# ============================================================================
# FIGURE 5: Pre-Treatment Balance
# ============================================================================

# Compare treated vs never-treated states in pre-treatment period
pre_balance <- panel %>%
  filter(year < 2006, year >= 1992) %>%  # Pre-California treatment
  mutate(group = if_else(is.finite(treat_year) & treat_year == 2006, "California", "Control States")) %>%
  filter(group %in% c("California", "Control States")) %>%
  group_by(group, year) %>%
  summarize(
    mean_rate = mean(heat_rate, na.rm = TRUE),
    .groups = "drop"
  )

fig5 <- ggplot(pre_balance, aes(x = year, y = mean_rate, color = group, linetype = group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_vline(xintercept = 2005.5, linetype = "dashed", color = "gray50") +
  scale_color_manual(
    values = c("California" = "#E64B35", "Control States" = "#4DBBD5"),
    name = ""
  ) +
  scale_linetype_manual(
    values = c("California" = "solid", "Control States" = "dashed"),
    name = ""
  ) +
  labs(
    title = "Pre-Treatment Trends: California vs. Control States",
    subtitle = "Heat fatality rate per 100,000 workers, 1992-2005",
    x = "Year",
    y = "Heat Fatality Rate",
    caption = "Note: Control states are never-treated states"
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(FIG_DIR, "fig5_pretrends.pdf"), fig5, width = 8, height = 5)
ggsave(file.path(FIG_DIR, "fig5_pretrends.png"), fig5, width = 8, height = 5, dpi = 300)

cat("\n============================================================\n")
cat("FIGURES GENERATED\n")
cat("============================================================\n")
cat("Saved to:", FIG_DIR, "\n")
list.files(FIG_DIR)
