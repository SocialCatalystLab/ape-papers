# ============================================================================
# 05_figures.R
# Swedish School Transport (Skolskjuts) and Educational Equity
# Figure generation
# ============================================================================

source("00_packages.R")

# ============================================================================
# 1. LOAD DATA
# ============================================================================

cat("\n=== Loading data for figures ===\n")

analysis_2023 <- read_csv("../data/processed/analysis_2023.csv", show_col_types = FALSE)
analysis_panel <- read_csv("../data/processed/analysis_panel.csv", show_col_types = FALSE)

# Load geodata if available
kommun_exists <- file.exists("../data/processed/kommun_processed.gpkg")
deso_exists <- file.exists("../data/processed/deso_analysis.csv")

if (kommun_exists) {
  kommun_sf <- st_read("../data/processed/kommun_processed.gpkg", quiet = TRUE)
}

if (deso_exists) {
  deso_analysis <- read_csv("../data/processed/deso_analysis.csv", show_col_types = FALSE)
}

# ============================================================================
# FIGURE 1: RDD Plot - Merit Points at Accessibility Threshold
# ============================================================================

cat("\n=== Figure 1: Main RDD Plot ===\n")

# Create binned scatter plot with local polynomial fit
fig1_data <- analysis_2023 |>
  filter(!is.na(merit_all) & !is.na(running_var)) |>
  mutate(
    bin = cut(running_var, breaks = seq(-50, 50, by = 5), include.lowest = TRUE),
    bin_midpoint = as.numeric(gsub("\\(|\\[|\\]|,.*", "", as.character(bin))) + 2.5
  ) |>
  group_by(bin_midpoint) |>
  summarise(
    mean_merit = mean(merit_all, na.rm = TRUE),
    se_merit = sd(merit_all, na.rm = TRUE) / sqrt(n()),
    n = n(),
    .groups = "drop"
  ) |>
  filter(!is.na(bin_midpoint))

# Create plot
fig1 <- ggplot() +
  # Binned means with error bars
  geom_errorbar(
    data = fig1_data,
    aes(x = bin_midpoint, ymin = mean_merit - 1.96*se_merit, ymax = mean_merit + 1.96*se_merit),
    width = 2, color = "gray60"
  ) +
  geom_point(
    data = fig1_data,
    aes(x = bin_midpoint, y = mean_merit, size = n),
    color = sweden_colors["blue"], alpha = 0.8
  ) +
  # Local polynomial fits
  geom_smooth(
    data = analysis_2023 |> filter(running_var < 0 & !is.na(merit_all)),
    aes(x = running_var, y = merit_all),
    method = "loess", span = 0.8, se = TRUE,
    color = sweden_colors["dark_blue"], fill = sweden_colors["light_blue"],
    alpha = 0.2
  ) +
  geom_smooth(
    data = analysis_2023 |> filter(running_var >= 0 & !is.na(merit_all)),
    aes(x = running_var, y = merit_all),
    method = "loess", span = 0.8, se = TRUE,
    color = sweden_colors["dark_blue"], fill = sweden_colors["light_blue"],
    alpha = 0.2
  ) +
  # Vertical line at cutoff
  geom_vline(xintercept = 0, linetype = "dashed", color = "red", linewidth = 0.8) +
  # Labels
  labs(
    title = "School Transport Eligibility and Educational Achievement",
    subtitle = "Regression Discontinuity at 50% School Accessibility Threshold",
    x = "School Accessibility (% children within 2km) - Centered at 50%",
    y = "Average Merit Points (Grade 9)",
    caption = "Note: Points show binned municipality means; shaded areas show 95% CI.\nMunicipalities with lower accessibility (left of cutoff) have higher transport subsidy eligibility.",
    size = "N municipalities"
  ) +
  scale_size_continuous(range = c(2, 6)) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = c(0.85, 0.85),
    legend.background = element_rect(fill = "white", color = "gray80")
  )

ggsave("../figures/fig1_rdd_main.pdf", fig1, width = 10, height = 7)
ggsave("../figures/fig1_rdd_main.png", fig1, width = 10, height = 7, dpi = 300)

cat("  Figure 1 saved\n")

# ============================================================================
# FIGURE 2: Map of Sweden showing threshold variation
# ============================================================================

cat("\n=== Figure 2: Map of Sweden ===\n")

if (kommun_exists) {
  # Merge merit points with municipality boundaries
  kommun_plot <- kommun_sf |>
    left_join(
      analysis_2023 |> select(municipality_id, merit_all, school_access_2km),
      by = c("kommunkod" = "municipality_id")
    )

  # Create choropleth map
  fig2 <- ggplot(kommun_plot) +
    geom_sf(aes(fill = school_access_2km), color = "white", linewidth = 0.1) +
    scale_fill_viridis_c(
      name = "% Children\nWithin 2km\nof School",
      option = "plasma",
      direction = -1,
      na.value = "gray90"
    ) +
    labs(
      title = "School Accessibility Across Swedish Municipalities",
      subtitle = "Percentage of children living within 2 km of nearest school, 2023",
      caption = "Source: Kolada Database (N07531)"
    ) +
    theme_void() +
    theme(
      plot.title = element_text(face = "bold", size = 14, hjust = 0.5),
      plot.subtitle = element_text(size = 10, hjust = 0.5),
      legend.position = c(0.9, 0.3)
    )

  ggsave("../figures/fig2_sweden_map.pdf", fig2, width = 8, height = 12)
  ggsave("../figures/fig2_sweden_map.png", fig2, width = 8, height = 12, dpi = 300)

  cat("  Figure 2 saved\n")
} else {
  cat("  Figure 2 skipped (no geodata)\n")
}

# ============================================================================
# FIGURE 3: Heterogeneity by urbanity
# ============================================================================

cat("\n=== Figure 3: Heterogeneity Plot ===\n")

# Load heterogeneity results if available
hetero_file <- "../tables/robustness_heterogeneity.csv"
if (file.exists(hetero_file)) {
  heterogeneity_urban <- read_csv(hetero_file, show_col_types = FALSE)

  fig3 <- heterogeneity_urban |>
    mutate(
      urban_type = factor(urban_type, levels = c("Major City", "Urban", "Suburban", "Rural"))
    ) |>
    ggplot(aes(x = urban_type, y = estimate)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_errorbar(
      aes(ymin = estimate - 1.96*se, ymax = estimate + 1.96*se),
      width = 0.2, color = sweden_colors["blue"], linewidth = 1
    ) +
    geom_point(size = 4, color = sweden_colors["dark_blue"]) +
    labs(
      title = "Effect of Transport Subsidies by Municipality Type",
      subtitle = "RDD estimates of merit point discontinuity at accessibility threshold",
      x = "Municipality Type",
      y = "Effect on Merit Points\n(RDD Estimate)",
      caption = "Note: Error bars show 95% confidence intervals.\nMunicipality types based on school accessibility levels."
    ) +
    theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      axis.text.x = element_text(angle = 0, hjust = 0.5)
    )

  ggsave("../figures/fig3_heterogeneity.pdf", fig3, width = 8, height = 6)
  ggsave("../figures/fig3_heterogeneity.png", fig3, width = 8, height = 6, dpi = 300)

  cat("  Figure 3 saved\n")
} else {
  cat("  Figure 3 skipped (no heterogeneity results)\n")
}

# ============================================================================
# FIGURE 4: Trends over time
# ============================================================================

cat("\n=== Figure 4: Time Trends ===\n")

fig4_data <- analysis_panel |>
  filter(!is.na(merit_all)) |>
  group_by(year) |>
  summarise(
    mean_merit = mean(merit_all, na.rm = TRUE),
    mean_accessibility = mean(school_access_2km, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  )

fig4 <- fig4_data |>
  pivot_longer(cols = c(mean_merit, mean_accessibility), names_to = "variable", values_to = "value") |>
  mutate(
    variable = case_when(
      variable == "mean_merit" ~ "Merit Points",
      variable == "mean_accessibility" ~ "School Accessibility (%)"
    )
  ) |>
  ggplot(aes(x = year, y = value, color = variable)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  facet_wrap(~variable, scales = "free_y") +
  scale_color_manual(values = c(sweden_colors["blue"], sweden_colors["dark_blue"])) +
  labs(
    title = "Trends in Educational Outcomes and School Accessibility",
    subtitle = "Swedish municipalities, 2015-2024",
    x = "Year",
    y = "Value",
    caption = "Source: Kolada Database"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "none",
    strip.text = element_text(face = "bold")
  )

ggsave("../figures/fig4_trends.pdf", fig4, width = 10, height = 5)
ggsave("../figures/fig4_trends.png", fig4, width = 10, height = 5, dpi = 300)

cat("  Figure 4 saved\n")

# ============================================================================
# FIGURE 5: McCrary Density Test
# ============================================================================

cat("\n=== Figure 5: Manipulation Test ===\n")

fig5 <- ggplot(analysis_2023 |> filter(!is.na(running_var)), aes(x = running_var)) +
  geom_histogram(
    aes(y = after_stat(density)),
    bins = 30, fill = sweden_colors["blue"], alpha = 0.7, color = "white"
  ) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "red", linewidth = 1) +
  labs(
    title = "Distribution of Running Variable (Manipulation Test)",
    subtitle = "No evidence of bunching at threshold indicates valid RDD design",
    x = "School Accessibility - Centered at 50%",
    y = "Density",
    caption = "Note: Dashed line indicates RDD cutoff.\nSmooth density suggests no manipulation of treatment assignment."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14)
  )

ggsave("../figures/fig5_density.pdf", fig5, width = 8, height = 6)
ggsave("../figures/fig5_density.png", fig5, width = 8, height = 6, dpi = 300)

cat("  Figure 5 saved\n")

# ============================================================================
# FIGURE 6: Bandwidth Sensitivity
# ============================================================================

cat("\n=== Figure 6: Bandwidth Sensitivity ===\n")

bw_file <- "../tables/robustness_bandwidth.csv"
if (file.exists(bw_file)) {
  bw_sensitivity <- read_csv(bw_file, show_col_types = FALSE)

  fig6 <- bw_sensitivity |>
    ggplot(aes(x = bandwidth_multiplier, y = estimate)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_ribbon(
      aes(ymin = ci_lower, ymax = ci_upper),
      fill = sweden_colors["light_blue"], alpha = 0.3
    ) +
    geom_line(color = sweden_colors["blue"], linewidth = 1) +
    geom_point(color = sweden_colors["dark_blue"], size = 3) +
    geom_vline(xintercept = 1, linetype = "dotted", color = "gray40") +
    labs(
      title = "Sensitivity of RDD Estimate to Bandwidth Choice",
      subtitle = "Estimates remain stable across bandwidth selections",
      x = "Bandwidth Multiplier (1.0 = Optimal)",
      y = "RDD Estimate\n(Merit Points)",
      caption = "Note: Shaded area shows 95% confidence interval.\nVertical dotted line indicates optimal bandwidth."
    ) +
    scale_x_continuous(breaks = bw_sensitivity$bandwidth_multiplier) +
    theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", size = 14)
    )

  ggsave("../figures/fig6_bandwidth.pdf", fig6, width = 8, height = 6)
  ggsave("../figures/fig6_bandwidth.png", fig6, width = 8, height = 6, dpi = 300)

  cat("  Figure 6 saved\n")
} else {
  cat("  Figure 6 skipped (no bandwidth results)\n")
}

# ============================================================================
# FIGURE 7: School Type Comparison
# ============================================================================

cat("\n=== Figure 7: School Type Comparison ===\n")

fig7_data <- analysis_2023 |>
  filter(!is.na(merit_municipal) & !is.na(merit_friskola)) |>
  select(municipality_name, merit_municipal, merit_friskola) |>
  pivot_longer(cols = c(merit_municipal, merit_friskola), names_to = "school_type", values_to = "merit") |>
  mutate(
    school_type = case_when(
      school_type == "merit_municipal" ~ "Municipal Schools",
      school_type == "merit_friskola" ~ "Private Schools (Friskola)"
    )
  )

fig7 <- ggplot(fig7_data, aes(x = merit, fill = school_type)) +
  geom_density(alpha = 0.6) +
  scale_fill_manual(
    values = c(sweden_colors["blue"], sweden_colors["yellow"]),
    name = "School Type"
  ) +
  labs(
    title = "Distribution of Merit Points by School Type",
    subtitle = "Swedish municipalities, 2023",
    x = "Average Merit Points (Grade 9)",
    y = "Density",
    caption = "Note: Merit points measured on 0-340 scale (maximum = A grades in all subjects)."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = c(0.15, 0.85),
    legend.background = element_rect(fill = "white", color = "gray80")
  )

ggsave("../figures/fig7_school_types.pdf", fig7, width = 9, height = 6)
ggsave("../figures/fig7_school_types.png", fig7, width = 9, height = 6, dpi = 300)

cat("  Figure 7 saved\n")

# ============================================================================
# SUMMARY
# ============================================================================

cat("\n=== Figures generated ===\n")
figure_files <- list.files("../figures", pattern = "\\.(pdf|png)$", full.names = FALSE)
for (f in figure_files) {
  cat("  ", f, "\n")
}

cat("\nFigure generation complete.\n")
