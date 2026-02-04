# ==============================================================================
# 09_atlas_figures.R
# Create Atlas Maps and Additional Figures
# Revision of apep_0173
# ==============================================================================

source("00_packages.R")

# Additional packages for maps
library(sf)
library(maps)

# Define figure directory
fig_dir <- file.path(dirname(data_dir), "figures")

# Create a simple US states map using base maps package
# We'll use a subset of 10 states
state_info <- tibble(
  state = c("06", "48", "12", "36", "17", "39", "42", "13", "37", "26"),
  state_name = c("California", "Texas", "Florida", "New York", "Illinois",
                 "Ohio", "Pennsylvania", "Georgia", "North Carolina", "Michigan"),
  state_abbr = c("CA", "TX", "FL", "NY", "IL", "OH", "PA", "GA", "NC", "MI"),
  region = c("West", "South", "South", "Northeast", "Midwest",
             "Midwest", "Northeast", "South", "South", "Midwest")
)

# Load results
state_results <- readRDS(file.path(data_dir, "state_results.rds"))
gender_results <- readRDS(file.path(data_dir, "gender_results.rds"))
gender_state_results <- readRDS(file.path(data_dir, "gender_state_results.rds"))

# ==============================================================================
# Get US states shapefile
# ==============================================================================

# Use maps package to get state boundaries
us_states <- map_data("state")

# Map state names to our data
state_name_lower <- tolower(state_info$state_name)
names(state_name_lower) <- state_info$state

# ==============================================================================
# Figure 8: State-Level Aggregate SE Penalty Map
# ==============================================================================

cat("Creating Figure 8: State Aggregate SE Penalty Map...\n")

agg_data <- state_results %>%
  filter(type == "Aggregate", converged) %>%
  mutate(state_name_lower = tolower(state_name))

# Join with map data
map_agg <- us_states %>%
  filter(region %in% agg_data$state_name_lower) %>%
  left_join(agg_data, by = c("region" = "state_name_lower"))

# Create base US map for context (grayed out)
us_base <- us_states %>%
  filter(!region %in% c("alaska", "hawaii", "puerto rico"))

# Plot
p8 <- ggplot() +
  # Base layer: all US states in light gray
  geom_polygon(data = us_base,
               aes(x = long, y = lat, group = group),
               fill = "gray90", color = "white", linewidth = 0.3) +
  # Overlay: our 10 states with values
  geom_polygon(data = map_agg,
               aes(x = long, y = lat, group = group, fill = estimate),
               color = "white", linewidth = 0.5) +
  scale_fill_gradient2(
    name = "Effect on\nLog Earnings",
    low = "#B2182B",      # Dark red for large penalty
    mid = "#F7F7F7",      # White for neutral
    high = "#2166AC",     # Blue for premium (not expected)
    midpoint = 0,
    limits = c(-0.6, 0.1),
    breaks = seq(-0.6, 0, by = 0.2),
    labels = c("-0.6", "-0.4", "-0.2", "0")
  ) +
  coord_map("albers", lat0 = 39, lat1 = 45) +
  labs(
    title = "The Self-Employment Penalty Across America",
    subtitle = "Aggregate effect of self-employment on log earnings (vs. wage workers)",
    caption = "Note: Darker red indicates larger earnings penalty. Gray states not in sample.\nSource: ACS PUMS 2019-2022. IPW estimates with robust standard errors."
  ) +
  theme_void() +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "gray40"),
    plot.caption = element_text(size = 8, hjust = 0, color = "gray50"),
    legend.position = "right",
    legend.title = element_text(size = 9),
    legend.text = element_text(size = 8),
    plot.margin = margin(10, 10, 10, 10)
  )

ggsave(file.path(fig_dir, "fig8_state_aggregate_map.pdf"), p8, width = 10, height = 6, dpi = 300)
ggsave(file.path(fig_dir, "fig8_state_aggregate_map.png"), p8, width = 10, height = 6, dpi = 300)

# ==============================================================================
# Figure 9: State-Level Incorporated Premium Map
# ==============================================================================

cat("Creating Figure 9: State Incorporated Premium Map...\n")

inc_data <- state_results %>%
  filter(type == "Incorporated", converged) %>%
  mutate(state_name_lower = tolower(state_name))

map_inc <- us_states %>%
  filter(region %in% inc_data$state_name_lower) %>%
  left_join(inc_data, by = c("region" = "state_name_lower"))

p9 <- ggplot() +
  geom_polygon(data = us_base,
               aes(x = long, y = lat, group = group),
               fill = "gray90", color = "white", linewidth = 0.3) +
  geom_polygon(data = map_inc,
               aes(x = long, y = lat, group = group, fill = estimate),
               color = "white", linewidth = 0.5) +
  scale_fill_gradient2(
    name = "Effect on\nLog Earnings",
    low = "#B2182B",
    mid = "#F7F7F7",
    high = "#2166AC",
    midpoint = 0,
    limits = c(-0.1, 0.2),
    breaks = seq(-0.1, 0.2, by = 0.1)
  ) +
  coord_map("albers", lat0 = 39, lat1 = 45) +
  labs(
    title = "The Incorporated Self-Employment Premium",
    subtitle = "Effect of incorporated self-employment on log earnings (vs. wage workers)",
    caption = "Note: Blue indicates earnings premium; red indicates penalty.\nSource: ACS PUMS 2019-2022. IPW estimates with robust standard errors."
  ) +
  theme_void() +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "gray40"),
    plot.caption = element_text(size = 8, hjust = 0, color = "gray50"),
    legend.position = "right",
    legend.title = element_text(size = 9),
    legend.text = element_text(size = 8),
    plot.margin = margin(10, 10, 10, 10)
  )

ggsave(file.path(fig_dir, "fig9_state_incorporated_map.pdf"), p9, width = 10, height = 6, dpi = 300)
ggsave(file.path(fig_dir, "fig9_state_incorporated_map.png"), p9, width = 10, height = 6, dpi = 300)

# ==============================================================================
# Figure 10: State-Level Unincorporated Penalty Map
# ==============================================================================

cat("Creating Figure 10: State Unincorporated Penalty Map...\n")

uninc_data <- state_results %>%
  filter(type == "Unincorporated", converged) %>%
  mutate(state_name_lower = tolower(state_name))

map_uninc <- us_states %>%
  filter(region %in% uninc_data$state_name_lower) %>%
  left_join(uninc_data, by = c("region" = "state_name_lower"))

p10 <- ggplot() +
  geom_polygon(data = us_base,
               aes(x = long, y = lat, group = group),
               fill = "gray90", color = "white", linewidth = 0.3) +
  geom_polygon(data = map_uninc,
               aes(x = long, y = lat, group = group, fill = estimate),
               color = "white", linewidth = 0.5) +
  scale_fill_gradient2(
    name = "Effect on\nLog Earnings",
    low = "#B2182B",
    mid = "#F7F7F7",
    high = "#2166AC",
    midpoint = 0,
    limits = c(-0.8, 0),
    breaks = seq(-0.8, 0, by = 0.2)
  ) +
  coord_map("albers", lat0 = 39, lat1 = 45) +
  labs(
    title = "The Unincorporated Self-Employment Penalty",
    subtitle = "Effect of unincorporated self-employment on log earnings (vs. wage workers)",
    caption = "Note: Darker red indicates larger earnings penalty.\nSource: ACS PUMS 2019-2022. IPW estimates with robust standard errors."
  ) +
  theme_void() +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "gray40"),
    plot.caption = element_text(size = 8, hjust = 0, color = "gray50"),
    legend.position = "right",
    legend.title = element_text(size = 9),
    legend.text = element_text(size = 8),
    plot.margin = margin(10, 10, 10, 10)
  )

ggsave(file.path(fig_dir, "fig10_state_unincorporated_map.pdf"), p10, width = 10, height = 6, dpi = 300)
ggsave(file.path(fig_dir, "fig10_state_unincorporated_map.png"), p10, width = 10, height = 6, dpi = 300)

# ==============================================================================
# Figure 11: Gender Heterogeneity Coefficient Plot
# ==============================================================================

cat("Creating Figure 11: Gender Heterogeneity...\n")

gender_plot_data <- gender_results %>%
  filter(converged) %>%
  mutate(
    type = factor(type, levels = c("Aggregate", "Incorporated", "Unincorporated")),
    gender = factor(gender, levels = c("Men", "Women"))
  )

p11 <- ggplot(gender_plot_data, aes(x = type, y = estimate, color = gender, shape = gender)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_pointrange(aes(ymin = ci_lower, ymax = ci_upper),
                  position = position_dodge(width = 0.4),
                  size = 0.8, linewidth = 0.8) +
  scale_color_manual(values = c("Men" = "#2171B5", "Women" = "#CB181D"),
                     name = "") +
  scale_shape_manual(values = c("Men" = 16, "Women" = 17), name = "") +
  scale_y_continuous(breaks = seq(-0.8, 0.2, by = 0.2)) +
  labs(
    title = "Self-Employment Effects by Gender",
    subtitle = "IPW estimates with 95% confidence intervals",
    x = "",
    y = "Effect on Log Earnings",
    caption = "Note: Estimates control for age, education, marital status, race, and homeownership.\nSource: ACS PUMS 2019-2022."
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 10, color = "gray40"),
    legend.position = "top",
    panel.grid.minor = element_blank(),
    axis.text = element_text(size = 10),
    axis.title = element_text(size = 11)
  )

ggsave(file.path(fig_dir, "fig11_gender_heterogeneity.pdf"), p11, width = 8, height = 6, dpi = 300)
ggsave(file.path(fig_dir, "fig11_gender_heterogeneity.png"), p11, width = 8, height = 6, dpi = 300)

# ==============================================================================
# Figure 12: State-Level Results Bar Chart
# ==============================================================================

cat("Creating Figure 12: State Results Bar Chart...\n")

state_bar_data <- state_results %>%
  filter(converged) %>%
  select(state_abbr, type, estimate, ci_lower, ci_upper) %>%
  mutate(
    type = factor(type, levels = c("Aggregate", "Incorporated", "Unincorporated")),
    state_abbr = factor(state_abbr, levels = c("CA", "TX", "FL", "NY", "IL", "OH", "PA", "GA", "NC", "MI"))
  )

p12 <- ggplot(state_bar_data, aes(x = state_abbr, y = estimate, fill = type)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_col(position = position_dodge(width = 0.8), width = 0.7, alpha = 0.85) +
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper),
                position = position_dodge(width = 0.8),
                width = 0.2, linewidth = 0.5) +
  scale_fill_manual(
    values = c("Aggregate" = "#525252", "Incorporated" = "#2171B5", "Unincorporated" = "#CB181D"),
    name = "Self-Employment Type"
  ) +
  scale_y_continuous(breaks = seq(-0.8, 0.2, by = 0.2)) +
  labs(
    title = "The Atlas of Self-Employment: State-by-State Results",
    subtitle = "Effect of self-employment on log earnings by state and incorporation status",
    x = "State",
    y = "Effect on Log Earnings",
    caption = "Note: Error bars show 95% confidence intervals. Positive values indicate premium; negative indicate penalty.\nSource: ACS PUMS 2019-2022. IPW estimates with robust standard errors."
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 10, color = "gray40"),
    legend.position = "top",
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(size = 10, face = "bold"),
    axis.text.y = element_text(size = 9)
  )

ggsave(file.path(fig_dir, "fig12_state_bar_chart.pdf"), p12, width = 12, height = 7, dpi = 300)
ggsave(file.path(fig_dir, "fig12_state_bar_chart.png"), p12, width = 12, height = 7, dpi = 300)

# ==============================================================================
# Figure 13: Gender Gap in SE Penalty by State
# ==============================================================================

cat("Creating Figure 13: Gender Gap by State...\n")

# Calculate gender gap by state
gender_state_wide <- gender_state_results %>%
  filter(converged) %>%
  select(gender, state, state_name, estimate, se) %>%
  pivot_wider(names_from = gender, values_from = c(estimate, se)) %>%
  mutate(
    gender_gap = estimate_Men - estimate_Women,
    se_gap = sqrt(se_Men^2 + se_Women^2),
    ci_lower = gender_gap - 1.96 * se_gap,
    ci_upper = gender_gap + 1.96 * se_gap,
    state_name_lower = tolower(state_name)
  )

map_gap <- us_states %>%
  filter(region %in% gender_state_wide$state_name_lower) %>%
  left_join(gender_state_wide, by = c("region" = "state_name_lower"))

p13 <- ggplot() +
  geom_polygon(data = us_base,
               aes(x = long, y = lat, group = group),
               fill = "gray90", color = "white", linewidth = 0.3) +
  geom_polygon(data = map_gap,
               aes(x = long, y = lat, group = group, fill = gender_gap),
               color = "white", linewidth = 0.5) +
  scale_fill_gradient2(
    name = "Gender Gap\n(Men - Women)",
    low = "#762A83",     # Purple if women do worse
    mid = "#F7F7F7",
    high = "#1B7837",    # Green if men do worse
    midpoint = 0,
    limits = c(-0.15, 0.15)
  ) +
  coord_map("albers", lat0 = 39, lat1 = 45) +
  labs(
    title = "Gender Gap in the Self-Employment Penalty",
    subtitle = "Difference between men's and women's self-employment earnings effects",
    caption = "Note: Positive values (green) indicate men face larger penalty than women.\nNegative values (purple) indicate women face larger penalty.\nSource: ACS PUMS 2019-2022."
  ) +
  theme_void() +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "gray40"),
    plot.caption = element_text(size = 8, hjust = 0, color = "gray50"),
    legend.position = "right",
    legend.title = element_text(size = 9),
    legend.text = element_text(size = 8)
  )

ggsave(file.path(fig_dir, "fig13_gender_gap_map.pdf"), p13, width = 10, height = 6, dpi = 300)
ggsave(file.path(fig_dir, "fig13_gender_gap_map.png"), p13, width = 10, height = 6, dpi = 300)

# ==============================================================================
# Figure 14: Combined 3-Panel Atlas (for main text)
# ==============================================================================

cat("Creating Figure 14: Combined Atlas Panel...\n")

library(patchwork)

# Simplified versions for panel
p_agg <- ggplot() +
  geom_polygon(data = us_base, aes(x = long, y = lat, group = group),
               fill = "gray90", color = "white", linewidth = 0.2) +
  geom_polygon(data = map_agg, aes(x = long, y = lat, group = group, fill = estimate),
               color = "white", linewidth = 0.3) +
  scale_fill_gradient2(name = "Effect", low = "#B2182B", mid = "#F7F7F7", high = "#2166AC",
                       midpoint = 0, limits = c(-0.6, 0.1), guide = "none") +
  coord_map("albers", lat0 = 39, lat1 = 45) +
  labs(title = "A. Aggregate") +
  theme_void() +
  theme(plot.title = element_text(size = 11, face = "bold", hjust = 0.5))

p_inc_small <- ggplot() +
  geom_polygon(data = us_base, aes(x = long, y = lat, group = group),
               fill = "gray90", color = "white", linewidth = 0.2) +
  geom_polygon(data = map_inc, aes(x = long, y = lat, group = group, fill = estimate),
               color = "white", linewidth = 0.3) +
  scale_fill_gradient2(name = "Effect", low = "#B2182B", mid = "#F7F7F7", high = "#2166AC",
                       midpoint = 0, limits = c(-0.1, 0.2), guide = "none") +
  coord_map("albers", lat0 = 39, lat1 = 45) +
  labs(title = "B. Incorporated") +
  theme_void() +
  theme(plot.title = element_text(size = 11, face = "bold", hjust = 0.5))

p_uninc_small <- ggplot() +
  geom_polygon(data = us_base, aes(x = long, y = lat, group = group),
               fill = "gray90", color = "white", linewidth = 0.2) +
  geom_polygon(data = map_uninc, aes(x = long, y = lat, group = group, fill = estimate),
               color = "white", linewidth = 0.3) +
  scale_fill_gradient2(name = "Effect", low = "#B2182B", mid = "#F7F7F7", high = "#2166AC",
                       midpoint = 0, limits = c(-0.8, 0), guide = "none") +
  coord_map("albers", lat0 = 39, lat1 = 45) +
  labs(title = "C. Unincorporated") +
  theme_void() +
  theme(plot.title = element_text(size = 11, face = "bold", hjust = 0.5))

# Combine panels
p14 <- (p_agg | p_inc_small | p_uninc_small) +
  plot_annotation(
    title = "The Atlas of Self-Employment in America",
    subtitle = "Effect of self-employment on log earnings by state and incorporation status",
    caption = "Note: Blue = premium, Red = penalty. Gray states not in sample. Source: ACS PUMS 2019-2022.",
    theme = theme(
      plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
      plot.subtitle = element_text(size = 10, hjust = 0.5, color = "gray40"),
      plot.caption = element_text(size = 8, hjust = 0.5, color = "gray50")
    )
  )

ggsave(file.path(fig_dir, "fig14_atlas_combined.pdf"), p14, width = 14, height = 5, dpi = 300)
ggsave(file.path(fig_dir, "fig14_atlas_combined.png"), p14, width = 14, height = 5, dpi = 300)

cat("\n", strrep("=", 70), "\n")
cat("ATLAS FIGURES COMPLETE\n")
cat(strrep("=", 70), "\n")
cat("\nGenerated figures:\n")
cat("  - fig8_state_aggregate_map.pdf\n")
cat("  - fig9_state_incorporated_map.pdf\n")
cat("  - fig10_state_unincorporated_map.pdf\n")
cat("  - fig11_gender_heterogeneity.pdf\n")
cat("  - fig12_state_bar_chart.pdf\n")
cat("  - fig13_gender_gap_map.pdf\n")
cat("  - fig14_atlas_combined.pdf\n")
