# =============================================================================
# Paper 107: Spatial RDD of Primary Seatbelt Enforcement Laws
# 05_figures.R - Generate All Figures
# =============================================================================

source(here::here("output/paper_107/code/00_packages.R"))

# Load data
analysis_df <- readRDS(file.path(dir_data, "analysis_df.rds"))
analysis_sf <- readRDS(file.path(dir_data, "analysis_sf.rds"))
states_sf <- readRDS(file.path(dir_data, "states_sf.rds"))
seatbelt_laws <- readRDS(file.path(dir_data, "seatbelt_laws.rds"))
rd_results <- readRDS(file.path(dir_data, "rd_results.rds"))
robustness <- readRDS(file.path(dir_data, "robustness_results.rds"))

# =============================================================================
# Figure 1: Map of Primary vs Secondary Enforcement States (2020)
# =============================================================================

message("Creating Figure 1: Enforcement status map...")

# Prepare state data for 2020
states_2020 <- states_sf %>%
  st_transform(crs = 4326) %>%  # WGS84 for plotting
  mutate(
    enforcement_label = case_when(
      enforcement_type == "primary" ~ "Primary Enforcement",
      enforcement_type == "secondary" ~ "Secondary Enforcement",
      enforcement_type == "none" ~ "No Adult Law",
      TRUE ~ "Unknown"
    )
  )

# Shift Alaska and Hawaii (simplified version)
# For publication, use proper inset maps

fig1 <- ggplot(states_2020) +
  geom_sf(aes(fill = enforcement_label), color = "white", linewidth = 0.3) +
  scale_fill_manual(
    name = "Seatbelt Law Enforcement Type (2020)",
    values = c(
      "Primary Enforcement" = apep_colors[1],  # Blue
      "Secondary Enforcement" = apep_colors[2],  # Orange
      "No Adult Law" = "grey70"
    ),
    na.value = "grey90"
  ) +
  labs(
    title = "Primary vs. Secondary Seatbelt Enforcement Laws (2019)",
    subtitle = "34 states + DC have primary; 15 states have secondary; NH has no adult law",
    caption = "Source: Insurance Institute for Highway Safety (IIHS)"
  ) +
  theme_void() +
  theme(
    legend.position = "bottom",
    legend.key.width = unit(1.5, "cm"),
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "grey40"),
    plot.margin = margin(10, 10, 10, 10)
  )

ggsave(file.path(dir_figs, "fig1_enforcement_map.pdf"), fig1, width = 10, height = 7)
message("  ✓ Figure 1 saved")

# =============================================================================
# Figure 2: Timeline of Primary Enforcement Adoption
# =============================================================================

message("Creating Figure 2: Adoption timeline...")

adoption_timeline <- seatbelt_laws %>%
  filter(enforcement_type == "primary", !is.na(primary_date)) %>%
  mutate(year = year(primary_date)) %>%
  count(year) %>%
  mutate(cumulative = cumsum(n))

fig2 <- ggplot(adoption_timeline, aes(x = year, y = cumulative)) +
  geom_step(color = apep_colors[1], linewidth = 1.2) +
  geom_point(color = apep_colors[1], size = 3) +
  geom_text(aes(label = n), vjust = -1, size = 3, color = "grey40") +
  scale_x_continuous(breaks = seq(1985, 2025, 5)) +
  scale_y_continuous(breaks = seq(0, 40, 5), limits = c(0, 40)) +
  labs(
    title = "Cumulative Adoption of Primary Seatbelt Enforcement Laws",
    subtitle = "Number of states with primary enforcement, 1984-2023",
    x = "Year",
    y = "Number of States with Primary Enforcement",
    caption = "Note: Numbers above points indicate new adoptions each year."
  ) +
  theme_apep()

ggsave(file.path(dir_figs, "fig2_adoption_timeline.pdf"), fig2, width = 9, height = 5)
message("  ✓ Figure 2 saved")

# =============================================================================
# Figure 3: Main RDD Plot
# =============================================================================

message("Creating Figure 3: Main RDD plot...")

# Create binned scatter for visualization
bin_width <- 5  # km
binned_data <- analysis_df %>%
  mutate(bin = floor(running_var / bin_width) * bin_width + bin_width/2) %>%
  group_by(bin) %>%
  summarise(
    mean_fatality = mean(fatality_prob, na.rm = TRUE),
    se_fatality = sd(fatality_prob, na.rm = TRUE) / sqrt(n()),
    n = n(),
    .groups = "drop"
  ) %>%
  filter(abs(bin) <= 75, n >= 10)  # Restrict to reasonable range

# Get RDD estimates for plotting fitted line
main_rd <- rd_results$main_rd_object

# Create fitted values from local polynomial
fit_left <- analysis_df %>%
  filter(running_var < 0, running_var >= -main_rd$bws[1, 1]) %>%
  arrange(running_var)

fit_right <- analysis_df %>%
  filter(running_var >= 0, running_var <= main_rd$bws[1, 1]) %>%
  arrange(running_var)

fig3 <- ggplot() +
  # Binned scatter points
  geom_point(data = binned_data,
             aes(x = bin, y = mean_fatality, size = n),
             color = "grey50", alpha = 0.7) +

  # Vertical line at border
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey30", linewidth = 0.8) +

  # Local polynomial fits (using loess for simplicity)
  geom_smooth(data = filter(binned_data, bin < 0),
              aes(x = bin, y = mean_fatality),
              method = "loess", se = TRUE,
              color = apep_colors[2], fill = apep_colors[2], alpha = 0.2, linewidth = 1) +
  geom_smooth(data = filter(binned_data, bin >= 0),
              aes(x = bin, y = mean_fatality),
              method = "loess", se = TRUE,
              color = apep_colors[1], fill = apep_colors[1], alpha = 0.2, linewidth = 1) +

  # Annotation with RD estimate (use robust p-value from rdrobust)
  annotate("text", x = 50, y = max(binned_data$mean_fatality, na.rm = TRUE) * 0.95,
           label = sprintf("RD Estimate: %.4f\n(SE: %.4f)\np = %.2f",
                          main_rd$coef[1], main_rd$se[1], main_rd$pv[1]),
           hjust = 0, size = 3.5, fontface = "italic") +

  # Labels
  labs(
    title = "Spatial Regression Discontinuity: Effect of Primary Seatbelt Enforcement",
    subtitle = "Fatality probability by distance to primary/secondary enforcement border",
    x = "Distance to Border (km)\n← Secondary Enforcement | Primary Enforcement →",
    y = "Fatality Probability (Deaths per Person in Crash)",
    caption = "Note: Points show binned means. Lines show local polynomial fits.",
    size = "Crashes\nper Bin"
  ) +
  theme_apep() +
  theme(legend.position = c(0.85, 0.85))

ggsave(file.path(dir_figs, "fig3_main_rdd.pdf"), fig3, width = 10, height = 6)
message("  ✓ Figure 3 saved")

# =============================================================================
# Figure 4: Crash Locations Near Borders
# =============================================================================

message("Creating Figure 4: Crash location map...")

# Focus on a specific border for illustration (e.g., NC-VA border)
border_region <- analysis_sf %>%
  filter(state_abbr %in% c("NC", "VA")) %>%
  st_transform(crs = 4326)

# State boundaries for context
nc_va_states <- states_sf %>%
  filter(state_abbr %in% c("NC", "VA", "SC", "TN", "KY", "WV", "MD")) %>%
  st_transform(crs = 4326)

fig4 <- ggplot() +
  # State boundaries
  geom_sf(data = nc_va_states, fill = "grey95", color = "grey50", linewidth = 0.5) +

  # Highlight NC (primary) and VA (secondary)
  geom_sf(data = filter(nc_va_states, state_abbr == "NC"),
          fill = alpha(apep_colors[1], 0.3), color = apep_colors[1], linewidth = 0.8) +
  geom_sf(data = filter(nc_va_states, state_abbr == "VA"),
          fill = alpha(apep_colors[2], 0.3), color = apep_colors[2], linewidth = 0.8) +

  # Crash points colored by fatality outcome
  geom_sf(data = border_region,
          aes(color = fatality_prob),
          size = 0.5, alpha = 0.6) +
  scale_color_viridis_c(option = "plasma", name = "Fatality\nProbability") +

  # Labels
  annotate("text", x = -80, y = 35, label = "NC\n(Primary)", color = apep_colors[1],
           size = 5, fontface = "bold") +
  annotate("text", x = -79, y = 38.5, label = "VA\n(Secondary)", color = apep_colors[2],
           size = 5, fontface = "bold") +

  labs(
    title = "Fatal Crash Locations: North Carolina vs. Virginia Border",
    subtitle = "NC has primary seatbelt enforcement; VA has secondary enforcement",
    caption = "Source: FARS 2000-2020. Point color indicates fatality probability per crash."
  ) +
  coord_sf(xlim = c(-84, -75), ylim = c(33, 40)) +
  theme_void() +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "grey40"),
    legend.position = c(0.1, 0.3)
  )

ggsave(file.path(dir_figs, "fig4_nc_va_crashes.pdf"), fig4, width = 10, height = 8)
message("  ✓ Figure 4 saved")

# =============================================================================
# Figure 5: Bandwidth Sensitivity
# =============================================================================

message("Creating Figure 5: Bandwidth sensitivity...")

bw_plot_data <- robustness$bandwidth %>%
  mutate(
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se
  )

fig5 <- ggplot(bw_plot_data, aes(x = bandwidth, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
              alpha = 0.2, fill = apep_colors[1]) +
  geom_line(color = apep_colors[1], linewidth = 1) +
  geom_point(color = apep_colors[1], size = 3) +
  # Mark optimal bandwidth
  geom_vline(xintercept = bw_plot_data$bandwidth[bw_plot_data$bandwidth_ratio == 1],
             linetype = "dotted", color = apep_colors[2], linewidth = 0.8) +
  labs(
    title = "Bandwidth Sensitivity Analysis",
    subtitle = "RD estimate across bandwidth choices; vertical line shows MSE-optimal bandwidth",
    x = "Bandwidth (km)",
    y = "RD Estimate (Effect on Fatality Probability)",
    caption = "Note: Shaded region shows 95% confidence interval."
  ) +
  theme_apep()

ggsave(file.path(dir_figs, "fig5_bandwidth_sensitivity.pdf"), fig5, width = 8, height = 5)
message("  ✓ Figure 5 saved")

# =============================================================================
# Figure 6: Heterogeneity Forest Plot
# =============================================================================

message("Creating Figure 6: Heterogeneity forest plot...")

hetero_data <- rd_results$heterogeneity %>%
  mutate(
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se,
    subgroup = factor(subgroup, levels = rev(subgroup))
  )

fig6 <- ggplot(hetero_data, aes(x = estimate, y = subgroup)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
  geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper),
                 height = 0.2, color = apep_colors[1], linewidth = 0.8) +
  geom_point(size = 3, color = apep_colors[1]) +
  labs(
    title = "Heterogeneous Treatment Effects",
    subtitle = "Effect of primary seatbelt enforcement by crash characteristics",
    x = "RD Estimate (Effect on Fatality Probability)",
    y = "",
    caption = "Note: Error bars show 95% confidence intervals."
  ) +
  theme_apep() +
  theme(panel.grid.major.y = element_blank())

ggsave(file.path(dir_figs, "fig6_heterogeneity.pdf"), fig6, width = 8, height = 5)
message("  ✓ Figure 6 saved")

# =============================================================================
# Figure 7: McCrary Density Test
# =============================================================================

message("Creating Figure 7: McCrary density plot...")

# Create density plot
density_data <- analysis_df %>%
  filter(abs(running_var) <= 100)

fig7 <- ggplot(density_data, aes(x = running_var)) +
  geom_histogram(aes(y = after_stat(density)),
                 bins = 50, fill = "grey70", color = "white") +
  geom_density(color = apep_colors[1], linewidth = 1) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey30", linewidth = 0.8) +
  # Add annotation with p-value
  annotate("text", x = 60, y = max(density(density_data$running_var)$y) * 0.9,
           label = sprintf("McCrary Test\np = %.3f", robustness$density_test),
           hjust = 0, size = 4) +
  labs(
    title = "Density of Crashes at the Border (McCrary Test)",
    subtitle = "Testing for manipulation/bunching at the enforcement boundary",
    x = "Distance to Border (km)\n← Secondary | Primary →",
    y = "Density",
    caption = sprintf("Note: McCrary test p < 0.001 indicates significant density discontinuity at the border.")
  ) +
  theme_apep()

ggsave(file.path(dir_figs, "fig7_mccrary_density.pdf"), fig7, width = 8, height = 5)
message("  ✓ Figure 7 saved")

# =============================================================================
# Figure 8: Placebo Outcomes (Pedestrian Deaths)
# =============================================================================

message("Creating Figure 8: Placebo outcome plot...")

# Binned data for pedestrian deaths
binned_placebo <- analysis_df %>%
  mutate(bin = floor(running_var / bin_width) * bin_width + bin_width/2) %>%
  group_by(bin) %>%
  summarise(
    mean_nonoccupant = mean(nonoccupant_deaths, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  ) %>%
  filter(abs(bin) <= 75, n >= 10)

placebo_result <- rd_results$main_results %>% filter(outcome == "Pedestrian/Cyclist Deaths (Placebo)")

fig8 <- ggplot() +
  geom_point(data = binned_placebo,
             aes(x = bin, y = mean_nonoccupant, size = n),
             color = "grey50", alpha = 0.7) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey30", linewidth = 0.8) +
  geom_smooth(data = filter(binned_placebo, bin < 0),
              aes(x = bin, y = mean_nonoccupant),
              method = "loess", se = TRUE,
              color = apep_colors[2], fill = apep_colors[2], alpha = 0.2, linewidth = 1) +
  geom_smooth(data = filter(binned_placebo, bin >= 0),
              aes(x = bin, y = mean_nonoccupant),
              method = "loess", se = TRUE,
              color = apep_colors[1], fill = apep_colors[1], alpha = 0.2, linewidth = 1) +
  annotate("text", x = 50, y = max(binned_placebo$mean_nonoccupant, na.rm = TRUE) * 0.95,
           label = sprintf("RD Estimate: %.4f\n(SE: %.4f)\np = %.3f",
                          placebo_result$estimate, placebo_result$se, placebo_result$p_value),
           hjust = 0, size = 3.5, fontface = "italic") +
  labs(
    title = "Placebo Test: Pedestrian and Cyclist Deaths",
    subtitle = "Seatbelt laws should NOT affect non-occupant fatalities",
    x = "Distance to Border (km)\n← Secondary Enforcement | Primary Enforcement →",
    y = "Mean Pedestrian/Cyclist Deaths per Crash",
    caption = "Note: Null effect expected; seatbelts protect vehicle occupants, not pedestrians."
  ) +
  theme_apep() +
  guides(size = "none")

ggsave(file.path(dir_figs, "fig8_placebo_pedestrians.pdf"), fig8, width = 10, height = 6)
message("  ✓ Figure 8 saved")

# =============================================================================
# Summary
# =============================================================================

message("\n=== All figures saved to: ", dir_figs, " ===")
message("  1. fig1_enforcement_map.pdf - Primary vs secondary states")
message("  2. fig2_adoption_timeline.pdf - Adoption over time")
message("  3. fig3_main_rdd.pdf - Main RDD result")
message("  4. fig4_nc_va_crashes.pdf - Border crash locations")
message("  5. fig5_bandwidth_sensitivity.pdf - Robustness to bandwidth")
message("  6. fig6_heterogeneity.pdf - Effect by subgroup")
message("  7. fig7_mccrary_density.pdf - Manipulation test")
message("  8. fig8_placebo_pedestrians.pdf - Placebo outcome")
