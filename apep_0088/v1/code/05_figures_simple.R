# =============================================================================
# 05_figures_simple.R - Generate key figures for the paper
# =============================================================================

source("00_packages.R")

# Load data
crashes <- readRDS("../data/crashes_analysis.rds")
crashes_sf <- readRDS("../data/crashes_sf.rds")
states_sf <- readRDS("../data/states_sf.rds")
borders_sf <- readRDS("../data/borders_sf.rds")
dispensaries_sf <- readRDS("../data/dispensaries_sf.rds")
bin_means <- readRDS("../data/bin_means.rds")
main_results <- readRDS("../data/main_results.rds")
bw_results <- readRDS("../data/bw_sensitivity.rds")

crashes$rv <- -crashes$running_var

cat("Creating figures...\n\n")

# =============================================================================
# FIGURE 1: Study Region Map
# =============================================================================

cat("Figure 1: Study Region Map\n")

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
cat("  Saved fig01_study_region.pdf\n")

# =============================================================================
# FIGURE 2: Dispensary Locations
# =============================================================================

cat("Figure 2: Dispensary Locations\n")

fig2 <- ggplot() +
  geom_sf(data = states_sf, aes(fill = legal_status), color = "white", linewidth = 0.8) +
  geom_sf(data = borders_sf, color = "black", linewidth = 1.5, linetype = "dashed") +
  geom_sf(data = dispensaries_sf, color = "#2E7D32", size = 0.5, alpha = 0.6) +
  scale_fill_manual(
    values = c("Legal" = "#C8E6C9", "Prohibition" = "#FFEBEE"),
    guide = "none"
  ) +
  coord_sf(xlim = c(-125, -102), ylim = c(31, 49)) +
  labs(
    title = "Cannabis Dispensary Locations (N = 1,399)",
    subtitle = "Legal states: Colorado, Oregon, Washington, Nevada, California",
    caption = "Source: OpenStreetMap. Green points indicate licensed recreational dispensaries."
  ) +
  theme_minimal(base_size = 11) +
  theme(
    panel.grid = element_blank(),
    axis.text = element_blank(),
    axis.title = element_blank()
  )

ggsave("../figures/fig02_dispensaries.pdf", fig2, width = 8, height = 8, dpi = 300)
cat("  Saved fig02_dispensaries.pdf\n")

# =============================================================================
# FIGURE 3: Binned Scatter Plot (RDD Visual)
# =============================================================================

cat("Figure 3: Binned Scatter Plot\n")

fig3 <- ggplot(bin_means, aes(x = mean_dist, y = alcohol_rate)) +
  geom_errorbar(aes(ymin = alcohol_rate - 1.96*alcohol_se,
                    ymax = alcohol_rate + 1.96*alcohol_se),
                width = 2, color = "gray60", alpha = 0.7) +
  geom_point(aes(size = n_crashes,
                 color = mean_dist < 0),
             alpha = 0.8) +
  geom_smooth(data = bin_means %>% filter(mean_dist < 0),
              method = "lm", se = FALSE, color = "#2E7D32", linewidth = 1.2) +
  geom_smooth(data = bin_means %>% filter(mean_dist >= 0),
              method = "lm", se = FALSE, color = "#C62828", linewidth = 1.2) +
  geom_vline(xintercept = 0, linetype = "dashed", linewidth = 1) +
  scale_color_manual(values = c("TRUE" = "#2E7D32", "FALSE" = "#C62828"),
                    guide = "none") +
  scale_size_continuous(range = c(2, 8), guide = "none") +
  scale_y_continuous(labels = scales::percent) +
  annotate("text", x = -70, y = 0.38, label = "Legal State", color = "#2E7D32", fontface = "bold") +
  annotate("text", x = 70, y = 0.38, label = "Prohibition State", color = "#C62828", fontface = "bold") +
  labs(
    x = "Distance to Border (km)\nNegative = Legal State, Positive = Prohibition State",
    y = "Alcohol Involvement Rate",
    title = "Alcohol-Involved Crashes by Distance to State Border",
    subtitle = "Binned scatter plot with linear fits; each point = 5km bin",
    caption = "Note: Size proportional to number of crashes. Vertical dashed line = border."
  ) +
  theme_minimal(base_size = 11)

ggsave("../figures/fig03_binned_scatter.pdf", fig3, width = 10, height = 7, dpi = 300)
cat("  Saved fig03_binned_scatter.pdf\n")

# =============================================================================
# FIGURE 4: Main RDD Plot
# =============================================================================

cat("Figure 4: Main RDD Plot\n")

pdf("../figures/fig04_rdd_main.pdf", width = 10, height = 7)
rdplot(
  y = crashes$alcohol_involved,
  x = crashes$rv,
  c = 0,
  p = 1,
  kernel = "triangular",
  binselect = "esmv",
  title = "Regression Discontinuity: Legal Cannabis Access and Alcohol-Involved Crashes",
  x.label = "Distance to Border (km), Positive = Legal State",
  y.label = "Alcohol Involvement Rate",
  col.dots = c("#C62828", "#2E7D32"),
  col.lines = c("#B71C1C", "#1B5E20")
)
dev.off()
cat("  Saved fig04_rdd_main.pdf\n")

# =============================================================================
# FIGURE 5: Bandwidth Sensitivity
# =============================================================================

cat("Figure 5: Bandwidth Sensitivity\n")

fig5 <- ggplot(bw_results, aes(x = bandwidth, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, fill = "#1565C0") +
  geom_line(color = "#1565C0", linewidth = 1) +
  geom_point(size = 3, color = "#1565C0") +
  geom_vline(xintercept = main_results$optimal_bandwidth,
             linetype = "dotted", color = "red") +
  annotate("text", x = main_results$optimal_bandwidth + 5, y = max(bw_results$ci_upper),
           label = "Optimal", hjust = 0, color = "red", size = 3) +
  labs(
    x = "Bandwidth (km)",
    y = "RDD Estimate",
    title = "Bandwidth Sensitivity Analysis",
    subtitle = "Effect robust across bandwidth choices (all CIs include zero)",
    caption = "Note: Red dotted line = MSE-optimal bandwidth."
  ) +
  theme_minimal(base_size = 11)

ggsave("../figures/fig05_bandwidth_sensitivity.pdf", fig5, width = 8, height = 6, dpi = 300)
cat("  Saved fig05_bandwidth_sensitivity.pdf\n")

# =============================================================================
# FIGURE 6: Density Test
# =============================================================================

cat("Figure 6: Density Test\n")

pdf("../figures/fig06_density_test.pdf", width = 10, height = 7)
density_test <- rddensity(crashes$rv, c = 0)
rdplotdensity(density_test, crashes$rv,
              title = "Density Test: Distribution of Crashes at Border",
              xlabel = "Distance to Border (km)",
              ylabel = "Density")
dev.off()
cat("  Saved fig06_density_test.pdf\n")

cat("\n=== All figures saved to ../figures/ ===\n")
