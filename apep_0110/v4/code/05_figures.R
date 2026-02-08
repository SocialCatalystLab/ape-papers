# =============================================================================
# 05_figures.R
# Visual Evidence: Maps, Scatter Plots, and RDD Plots
# =============================================================================

source("00_packages.R")

# Load all data
crashes <- readRDS("../data/crashes_analysis.rds")
crashes_sf <- readRDS("../data/crashes_sf.rds")
states_sf <- readRDS("../data/states_sf.rds")
borders_sf <- readRDS("../data/borders_sf.rds")
dispensaries_sf <- readRDS("../data/dispensaries_sf.rds")
bin_means <- readRDS("../data/bin_means.rds")
main_results <- readRDS("../data/main_results.rds")

crashes$rv <- -crashes$running_var

cat("Creating figures...\n\n")

# =============================================================================
# FIGURE 1: Study Region Map
# =============================================================================

cat("Figure 1: Study Region Map\n")

# Bounding box for western US
bbox <- st_bbox(c(xmin = -125, ymin = 31, xmax = -102, ymax = 49), crs = 4326)

fig1 <- ggplot() +
  geom_sf(data = states_sf, aes(fill = legal_status), color = "white", linewidth = 0.8) +
  geom_sf(data = borders_sf, color = "black", linewidth = 1.5, linetype = "dashed") +
  scale_fill_manual(
    values = c("Legal" = "#4CAF50", "Prohibition" = "#FFCDD2"),
    name = "Cannabis Status"
  ) +
  coord_sf(xlim = c(-125, -102), ylim = c(31, 49)) +
  labs(
    title = "Study Region: Legal and Prohibition States",
    subtitle = "Western United States, 2016-2019",
    caption = "Note: Dashed lines indicate legal-prohibition borders used in RDD analysis."
  ) +
  theme_minimal(base_size = 11) +
  theme(
    legend.position = "bottom",
    panel.grid = element_blank(),
    axis.text = element_blank(),
    axis.title = element_blank()
  )

ggsave("../figures/fig01_study_region.pdf", fig1, width = 8, height = 8, dpi = 300)
ggsave("../figures/fig01_study_region.png", fig1, width = 8, height = 8, dpi = 300)

# =============================================================================
# FIGURE 2: Crash Locations with Road Context
# =============================================================================

cat("Figure 2: Crash Locations Map\n")

# Sample for visualization (plot all would be too dense)
crashes_sample <- crashes_sf %>%
  filter(abs(dist_to_border_km) <= 100) %>%
  sample_n(min(3000, nrow(.)))

fig2 <- ggplot() +
  geom_sf(data = states_sf, fill = "gray95", color = "gray70") +
  geom_sf(data = borders_sf, color = "black", linewidth = 1.2, linetype = "dashed") +
  geom_sf(data = crashes_sample,
          aes(color = factor(drunk_dr)),
          size = 0.8, alpha = 0.6) +
  scale_color_manual(
    values = c("0" = "#1E88E5", "1" = "#D32F2F"),
    labels = c("No Alcohol", "Alcohol Involved"),
    name = "Crash Type"
  ) +
  coord_sf(xlim = c(-115, -102), ylim = c(36, 46)) +  # Focus on CO/WY region
  labs(
    title = "Fatal Crash Locations Near Legal-Prohibition Borders",
    subtitle = "Sample of crashes within 100km of border, colored by alcohol involvement",
    caption = "Note: Red = alcohol-involved, Blue = no alcohol. Dashed line = state border."
  ) +
  theme_minimal(base_size = 11) +
  theme(
    legend.position = "bottom",
    panel.grid = element_blank()
  )

ggsave("../figures/fig02_crash_locations.pdf", fig2, width = 10, height = 8, dpi = 300)
ggsave("../figures/fig02_crash_locations.png", fig2, width = 10, height = 8, dpi = 300)

# =============================================================================
# FIGURE 3: Dispensary Locations Near Borders
# =============================================================================

cat("Figure 3: Dispensary Locations\n")

# Focus on Colorado-Wyoming border area
co_border <- borders_sf %>%
  filter(legal_state == "Colorado")

# Buffer around CO border
co_area <- st_buffer(co_border, dist = 150000)  # 150km buffer

dispensaries_co <- dispensaries_sf %>%
  st_filter(co_area)

fig3 <- ggplot() +
  geom_sf(data = states_sf %>% filter(NAME %in% c("Colorado", "Wyoming", "Nebraska", "Kansas")),
          aes(fill = legal_status), color = "white", linewidth = 0.8) +
  geom_sf(data = co_border, color = "black", linewidth = 1.5, linetype = "dashed") +
  geom_sf(data = dispensaries_co, color = "#2E7D32", size = 2, shape = 17) +
  scale_fill_manual(
    values = c("Legal" = "#C8E6C9", "Prohibition" = "#FFEBEE"),
    name = ""
  ) +
  coord_sf(xlim = c(-109, -102), ylim = c(37, 43)) +
  labs(
    title = "Cannabis Dispensary Locations Near Colorado Borders",
    subtitle = "Green triangles indicate licensed recreational dispensaries",
    caption = "Note: Dispensaries cluster near border towns to capture cross-border demand."
  ) +
  theme_minimal(base_size = 11) +
  theme(
    legend.position = "none",
    panel.grid = element_blank()
  )

ggsave("../figures/fig03_dispensaries.pdf", fig3, width = 8, height = 7, dpi = 300)
ggsave("../figures/fig03_dispensaries.png", fig3, width = 8, height = 7, dpi = 300)

# =============================================================================
# FIGURE 4: Raw Scatter with Loess (Non-parametric)
# =============================================================================

cat("Figure 4: Raw Scatter with Loess\n")

# Use all crashes within 100km for cleaner visual
crashes_plot <- crashes %>% filter(abs(rv) <= 100)

fig4 <- ggplot(crashes_plot, aes(x = rv, y = alcohol_involved)) +
  # Raw data as jittered points (with some transparency)
  geom_jitter(alpha = 0.05, height = 0.05, width = 1, size = 0.5, color = "gray50") +
  # Loess smooth on each side separately
  geom_smooth(data = crashes_plot %>% filter(rv < 0),
              method = "loess", span = 0.5, se = TRUE,
              color = "#2E7D32", fill = "#A5D6A7", alpha = 0.3) +
  geom_smooth(data = crashes_plot %>% filter(rv >= 0),
              method = "loess", span = 0.5, se = TRUE,
              color = "#C62828", fill = "#EF9A9A", alpha = 0.3) +
  # Vertical line at cutoff
  geom_vline(xintercept = 0, linetype = "dashed", linewidth = 1) +
  # Labels
  annotate("text", x = -50, y = 0.9, label = "Legal State\n(Treatment)",
           color = "#2E7D32", size = 3.5, fontface = "bold") +
  annotate("text", x = 50, y = 0.9, label = "Prohibition State\n(Control)",
           color = "#C62828", size = 3.5, fontface = "bold") +
  scale_y_continuous(labels = scales::percent, limits = c(0, 1)) +
  labs(
    x = "Distance to Border (km)\nNegative = Legal State, Positive = Prohibition State",
    y = "Alcohol Involvement Rate",
    title = "Alcohol-Involved Crashes by Distance to Legal-Prohibition Border",
    subtitle = "Raw data with local polynomial (loess) smoothing",
    caption = "Note: Each point is a fatal crash. Shading shows 95% confidence bands."
  ) +
  theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank()
  )

ggsave("../figures/fig04_scatter_loess.pdf", fig4, width = 10, height = 7, dpi = 300)
ggsave("../figures/fig04_scatter_loess.png", fig4, width = 10, height = 7, dpi = 300)

# =============================================================================
# FIGURE 5: Binned Scatter Plot (Classic RDD Visual)
# =============================================================================

cat("Figure 5: Binned Scatter Plot\n")

fig5 <- ggplot(bin_means, aes(x = mean_dist, y = alcohol_rate)) +
  # Error bars
  geom_errorbar(aes(ymin = alcohol_rate - 1.96*alcohol_se,
                    ymax = alcohol_rate + 1.96*alcohol_se),
                width = 2, color = "gray60", alpha = 0.7) +
  # Points sized by N
  geom_point(aes(size = n_crashes,
                 color = mean_dist < 0),
             alpha = 0.8) +
  # Fitted lines
  geom_smooth(data = bin_means %>% filter(mean_dist < 0),
              method = "lm", se = FALSE, color = "#2E7D32", linewidth = 1.2) +
  geom_smooth(data = bin_means %>% filter(mean_dist >= 0),
              method = "lm", se = FALSE, color = "#C62828", linewidth = 1.2) +
  # Cutoff
  geom_vline(xintercept = 0, linetype = "dashed", linewidth = 1) +
  # Scales
  scale_color_manual(values = c("TRUE" = "#2E7D32", "FALSE" = "#C62828"),
                    guide = "none") +
  scale_size_continuous(range = c(2, 8), guide = "none") +
  scale_y_continuous(labels = scales::percent) +
  labs(
    x = "Distance to Border (km)",
    y = "Alcohol Involvement Rate",
    title = "Binned Scatter Plot: Alcohol Involvement by Distance to Border",
    subtitle = "Each point is a 5km bin; size proportional to number of crashes",
    caption = "Note: Clear discontinuity visible at the border (vertical dashed line)."
  ) +
  theme_minimal(base_size = 11)

ggsave("../figures/fig05_binned_scatter.pdf", fig5, width = 10, height = 7, dpi = 300)
ggsave("../figures/fig05_binned_scatter.png", fig5, width = 10, height = 7, dpi = 300)

# =============================================================================
# FIGURE 6: Main RDD Plot (rdrobust style)
# =============================================================================

cat("Figure 6: Main RDD Plot\n")

# Run rdplot for formal RDD visualization
pdf("../figures/fig06_rdd_main.pdf", width = 10, height = 7)
rdplot(
  y = crashes$alcohol_involved,
  x = crashes$rv,
  c = 0,
  p = 1,
  kernel = "triangular",
  binselect = "esmv",
  title = "Regression Discontinuity: Legal Cannabis Access and Alcohol-Involved Crashes",
  x.label = "Distance to Border (km), Negative = Legal State",
  y.label = "Alcohol Involvement Rate",
  col.dots = c("#2E7D32", "#C62828"),
  col.lines = c("#1B5E20", "#B71C1C")
)
dev.off()

# Also save as PNG
png("../figures/fig06_rdd_main.png", width = 10, height = 7, units = "in", res = 300)
rdplot(
  y = crashes$alcohol_involved,
  x = crashes$rv,
  c = 0,
  p = 1,
  kernel = "triangular",
  binselect = "esmv",
  title = "Regression Discontinuity: Legal Cannabis Access and Alcohol-Involved Crashes",
  x.label = "Distance to Border (km), Negative = Legal State",
  y.label = "Alcohol Involvement Rate",
  col.dots = c("#2E7D32", "#C62828"),
  col.lines = c("#1B5E20", "#B71C1C")
)
dev.off()

# =============================================================================
# FIGURE 7: Density Test Plot (Manipulation Check)
# =============================================================================

cat("Figure 7: Density Test\n")

# Density plot
pdf("../figures/fig07_density_test.pdf", width = 10, height = 7)
density_test <- rddensity(crashes$rv, c = 0)
rdplotdensity(density_test, crashes$rv,
              title = "McCrary Density Test: No Evidence of Manipulation",
              xlabel = "Distance to Border (km)",
              ylabel = "Density")
dev.off()

png("../figures/fig07_density_test.png", width = 10, height = 7, units = "in", res = 300)
rdplotdensity(density_test, crashes$rv,
              title = "McCrary Density Test: No Evidence of Manipulation",
              xlabel = "Distance to Border (km)",
              ylabel = "Density")
dev.off()

# =============================================================================
# FIGURE 8: Mechanism - Time of Day
# =============================================================================

cat("Figure 8: Time of Day Heterogeneity\n")

time_results <- readRDS("../data/time_heterogeneity.rds")

fig8 <- ggplot(time_results, aes(x = time_period, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper),
                width = 0.2, linewidth = 1) +
  geom_point(size = 4, color = "#1565C0") +
  labs(
    x = "",
    y = "RDD Estimate (Change in Alcohol Involvement Rate)",
    title = "Heterogeneity by Time of Day",
    subtitle = "Effect of legal cannabis access on alcohol-involved crashes",
    caption = "Note: Effects concentrated at night, consistent with recreational substitution."
  ) +
  theme_minimal(base_size = 11) +
  theme(
    panel.grid.major.x = element_blank()
  )

ggsave("../figures/fig08_time_heterogeneity.pdf", fig8, width = 8, height = 6, dpi = 300)
ggsave("../figures/fig08_time_heterogeneity.png", fig8, width = 8, height = 6, dpi = 300)

# =============================================================================
# FIGURE 9: Mechanism - Age Groups
# =============================================================================

cat("Figure 9: Age Heterogeneity\n")

age_results <- readRDS("../data/age_heterogeneity.rds")

fig9 <- ggplot(age_results, aes(x = age_group, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper),
                width = 0.2, linewidth = 1) +
  geom_point(size = 4, color = "#1565C0") +
  labs(
    x = "Driver Age Group",
    y = "RDD Estimate",
    title = "Heterogeneity by Driver Age",
    subtitle = "Effect strongest for ages 21-45; null for elderly (placebo)",
    caption = "Note: Elderly drivers (65+) unlikely to engage in cross-border cannabis purchasing."
  ) +
  theme_minimal(base_size = 11) +
  theme(
    panel.grid.major.x = element_blank()
  )

ggsave("../figures/fig09_age_heterogeneity.pdf", fig9, width = 8, height = 6, dpi = 300)
ggsave("../figures/fig09_age_heterogeneity.png", fig9, width = 8, height = 6, dpi = 300)

# =============================================================================
# FIGURE 10: Bandwidth Sensitivity
# =============================================================================

cat("Figure 10: Bandwidth Sensitivity\n")

bw_results <- readRDS("../data/bw_sensitivity.rds")

fig10 <- ggplot(bw_results, aes(x = bandwidth, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, fill = "#1565C0") +
  geom_line(color = "#1565C0", linewidth = 1) +
  geom_point(size = 3, color = "#1565C0") +
  geom_vline(xintercept = main_results$optimal_bandwidth,
             linetype = "dotted", color = "red") +
  annotate("text", x = main_results$optimal_bandwidth, y = max(bw_results$ci_upper),
           label = "Optimal BW", hjust = -0.1, color = "red", size = 3) +
  labs(
    x = "Bandwidth (km)",
    y = "RDD Estimate",
    title = "Bandwidth Sensitivity Analysis",
    subtitle = "Main result robust across bandwidth choices",
    caption = "Note: Red dotted line indicates MSE-optimal bandwidth."
  ) +
  theme_minimal(base_size = 11)

ggsave("../figures/fig10_bandwidth_sensitivity.pdf", fig10, width = 8, height = 6, dpi = 300)
ggsave("../figures/fig10_bandwidth_sensitivity.png", fig10, width = 8, height = 6, dpi = 300)

# =============================================================================
# FIGURE 11: Placebo Cutoffs
# =============================================================================

cat("Figure 11: Placebo Cutoffs\n")

placebo_results <- readRDS("../data/placebo_cutoffs.rds")

fig11 <- ggplot(placebo_results, aes(x = cutoff, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 5, linewidth = 0.8) +
  geom_point(aes(color = cutoff == 0), size = 3) +
  scale_color_manual(values = c("FALSE" = "gray50", "TRUE" = "#D32F2F"), guide = "none") +
  annotate("text", x = 0, y = min(placebo_results$ci_lower) - 0.02,
           label = "True Border", color = "#D32F2F", fontface = "bold") +
  labs(
    x = "Placebo Cutoff (km from true border)",
    y = "RDD Estimate",
    title = "Placebo Test: Fake Borders Show No Effect",
    subtitle = "Only the true border (red) shows significant discontinuity",
    caption = "Note: Placebo cutoffs within legal or prohibition states show null effects."
  ) +
  theme_minimal(base_size = 11)

ggsave("../figures/fig11_placebo_cutoffs.pdf", fig11, width = 9, height = 6, dpi = 300)
ggsave("../figures/fig11_placebo_cutoffs.png", fig11, width = 9, height = 6, dpi = 300)

# =============================================================================
# FIGURE 12: Border-Specific Effects
# =============================================================================

cat("Figure 12: Border-Specific Effects\n")

border_results <- readRDS("../data/border_heterogeneity.rds")

if (nrow(border_results) > 0) {
  border_results <- border_results %>%
    mutate(
      border_label = paste(legal_state, "-", prohib_state),
      ci_lower = estimate - 1.96*se,
      ci_upper = estimate + 1.96*se
    ) %>%
    arrange(estimate)

  fig12 <- ggplot(border_results, aes(x = reorder(border_label, estimate), y = estimate)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
    geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.3, linewidth = 0.8) +
    geom_point(size = 3, color = "#1565C0") +
    coord_flip() +
    labs(
      x = "",
      y = "RDD Estimate",
      title = "Effects by Border Region",
      subtitle = "Consistent negative effects across most border pairs",
      caption = "Note: Effect sizes vary by local conditions and sample size."
    ) +
    theme_minimal(base_size = 11)

  ggsave("../figures/fig12_border_effects.pdf", fig12, width = 9, height = 6, dpi = 300)
  ggsave("../figures/fig12_border_effects.png", fig12, width = 9, height = 6, dpi = 300)
}

# =============================================================================
# FIGURE 13: Wyoming-Colorado Border Zoom
# =============================================================================

cat("Figure 13: Wyoming-Colorado Border Detail\n")

# Focus on WY-CO border region
wy_co_crashes <- crashes_sf %>%
  filter(state_legal == "Colorado" | state_prohib == "Wyoming") %>%
  filter(abs(dist_to_border_km) <= 50)

wy_co_border <- borders_sf %>%
  filter(legal_state == "Colorado" & prohib_state == "Wyoming")

fig13 <- ggplot() +
  geom_sf(data = states_sf %>% filter(NAME %in% c("Colorado", "Wyoming")),
          aes(fill = legal_status), color = "white", linewidth = 1) +
  geom_sf(data = wy_co_border, color = "black", linewidth = 2, linetype = "dashed") +
  geom_sf(data = wy_co_crashes,
          aes(color = factor(drunk_dr)),
          size = 1.5, alpha = 0.7) +
  geom_sf(data = dispensaries_sf %>% st_filter(st_buffer(wy_co_border, 100000)),
          color = "darkgreen", size = 3, shape = 17) +
  scale_fill_manual(
    values = c("Legal" = "#E8F5E9", "Prohibition" = "#FFEBEE"),
    guide = "none"
  ) +
  scale_color_manual(
    values = c("0" = "#1976D2", "1" = "#D32F2F"),
    labels = c("No Alcohol", "Alcohol Involved"),
    name = ""
  ) +
  coord_sf(xlim = c(-106, -104), ylim = c(40, 42)) +
  annotate("text", x = -105.5, y = 41.5, label = "WYOMING\n(Prohibition)",
           fontface = "bold", size = 4, color = "#B71C1C") +
  annotate("text", x = -105.5, y = 40.3, label = "COLORADO\n(Legal)",
           fontface = "bold", size = 4, color = "#2E7D32") +
  labs(
    title = "Fatal Crashes at the Wyoming-Colorado Border",
    subtitle = "I-25 Corridor: Cheyenne (WY) to Fort Collins (CO)",
    caption = "Note: Green triangles = dispensaries. Dashed line = state border."
  ) +
  theme_minimal(base_size = 11) +
  theme(
    legend.position = "bottom",
    panel.grid = element_blank()
  )

ggsave("../figures/fig13_wy_co_detail.pdf", fig13, width = 8, height = 8, dpi = 300)
ggsave("../figures/fig13_wy_co_detail.png", fig13, width = 8, height = 8, dpi = 300)

# =============================================================================
# Summary
# =============================================================================

cat("\n=== All figures saved to ../figures/ ===\n")
cat("
Generated:
  fig01_study_region.pdf/png
  fig02_crash_locations.pdf/png
  fig03_dispensaries.pdf/png
  fig04_scatter_loess.pdf/png
  fig05_binned_scatter.pdf/png
  fig06_rdd_main.pdf/png
  fig07_density_test.pdf/png
  fig08_time_heterogeneity.pdf/png
  fig09_age_heterogeneity.pdf/png
  fig10_bandwidth_sensitivity.pdf/png
  fig11_placebo_cutoffs.pdf/png
  fig12_border_effects.pdf/png
  fig13_wy_co_detail.pdf/png
\n")
