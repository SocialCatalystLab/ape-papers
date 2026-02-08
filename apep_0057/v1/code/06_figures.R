# =============================================================================
# Paper 73: Publication-Quality Figures
# =============================================================================

library(tidyverse)
library(data.table)
library(sf)
library(scales)

setwd("/Users/dyanag/auto-policy-evals")

# APEP ggplot theme
theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", size = base_size * 1.2, hjust = 0),
      plot.subtitle = element_text(size = base_size, color = "gray40", hjust = 0),
      plot.caption = element_text(size = base_size * 0.8, color = "gray50", hjust = 1),
      axis.title = element_text(face = "bold"),
      axis.text = element_text(color = "gray30"),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "gray90"),
      legend.position = "bottom",
      legend.title = element_text(face = "bold"),
      plot.margin = margin(10, 10, 10, 10)
    )
}

# Load data
analysis <- fread("output/paper_73/data/analysis_final.csv")
quintile_results <- fread("output/paper_73/data/quintile_results.csv")

cat("Loaded analysis data:", nrow(analysis), "counties\n")

# -----------------------------------------------------------------------------
# Figure 1: Map of SCI Diversity
# -----------------------------------------------------------------------------

cat("\nCreating Figure 1: SCI Diversity Map...\n")

# Download county shapefile
county_shp_url <- "https://www2.census.gov/geo/tiger/GENZ2021/shp/cb_2021_us_county_500k.zip"
temp_shp <- tempfile(fileext = ".zip")
download.file(county_shp_url, temp_shp, mode = "wb", quiet = TRUE)
unzip(temp_shp, exdir = tempdir())

counties_sf <- st_read(file.path(tempdir(), "cb_2021_us_county_500k.shp"), quiet = TRUE)

# Merge with SCI data
counties_sf <- counties_sf %>%
  mutate(fips = paste0(STATEFP, COUNTYFP)) %>%
  left_join(analysis[, c("fips", "diversity", "unemp_shock", "network_exposure")],
            by = "fips")

# Filter to continental US
continental <- counties_sf %>%
  filter(!STATEFP %in% c("02", "15", "60", "66", "69", "72", "78"))

# Create diversity map
fig1 <- ggplot(continental) +
  geom_sf(aes(fill = diversity), color = NA, size = 0.05) +
  scale_fill_viridis_c(
    name = "SCI Diversity\n(1 - HHI)",
    option = "plasma",
    limits = c(0, 1),
    breaks = seq(0, 1, 0.25),
    labels = c("0.0\n(Concentrated)", "0.25", "0.5", "0.75", "1.0\n(Diverse)")
  ) +
  coord_sf(crs = 5070) +  # Albers Equal Area
  labs(
    title = "Geographic Diversity of Social Networks Across U.S. Counties",
    subtitle = "SCI Diversity measures whether a county's Facebook connections are concentrated in few states (low) or spread across many (high)",
    caption = "Source: Facebook Social Connectedness Index (October 2021). Diversity = 1 - HHI of state-level SCI shares."
  ) +
  theme_apep() +
  theme(
    axis.text = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank()
  )

ggsave("output/paper_73/figures/fig1_diversity_map.png", fig1,
       width = 12, height = 8, dpi = 300, bg = "white")
ggsave("output/paper_73/figures/fig1_diversity_map.pdf", fig1,
       width = 12, height = 8, bg = "white")

cat("  Saved fig1_diversity_map\n")

# -----------------------------------------------------------------------------
# Figure 2: Binned Scatter - Network Exposure vs Own Shock
# -----------------------------------------------------------------------------

cat("Creating Figure 2: Network Exposure vs Own Shock...\n")

# Create 20 bins for smoother visualization
analysis_binned <- analysis %>%
  mutate(exposure_bin = ntile(network_exposure, 20)) %>%
  group_by(exposure_bin) %>%
  summarize(
    mean_exposure = mean(network_exposure),
    mean_shock = mean(unemp_shock),
    se_shock = sd(unemp_shock) / sqrt(n()),
    n = n()
  )

fig2 <- ggplot(analysis_binned, aes(x = mean_exposure, y = mean_shock)) +
  geom_point(aes(size = n), color = "#2E86AB", alpha = 0.8) +
  geom_errorbar(aes(ymin = mean_shock - 1.96*se_shock,
                    ymax = mean_shock + 1.96*se_shock),
                width = 0.02, color = "gray50", alpha = 0.6) +
  geom_smooth(method = "lm", color = "#E94F37", linewidth = 1, se = TRUE, alpha = 0.2) +
  scale_size_continuous(range = c(2, 6), guide = "none") +
  labs(
    x = "Network Shock Exposure (SCI-weighted mean of connected counties' shocks)",
    y = "Own Unemployment Shock (pp, 2019-2021)",
    title = "Counties More Connected to Shocked Areas Experience Larger Own Shocks",
    subtitle = "Each point represents the mean of ~160 counties; error bars show 95% CI",
    caption = "Note: Network exposure = Σ (SCI_ij × shock_j) for all connected counties j. Shocks measured as change in unemployment rate."
  ) +
  theme_apep() +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50")

ggsave("output/paper_73/figures/fig2_exposure_shock.png", fig2,
       width = 10, height = 7, dpi = 300, bg = "white")
ggsave("output/paper_73/figures/fig2_exposure_shock.pdf", fig2,
       width = 10, height = 7, bg = "white")

cat("  Saved fig2_exposure_shock\n")

# -----------------------------------------------------------------------------
# Figure 3: Quintile Comparison
# -----------------------------------------------------------------------------

cat("Creating Figure 3: Quintile Analysis...\n")

quintile_plot_data <- quintile_results %>%
  mutate(
    quintile_label = factor(exposure_quintile,
                            labels = c("Q1\n(Lowest)", "Q2", "Q3", "Q4", "Q5\n(Highest)"))
  )

fig3 <- ggplot(quintile_plot_data, aes(x = quintile_label, y = mean_own_shock)) +
  geom_col(fill = "#2E86AB", alpha = 0.8, width = 0.7) +
  geom_errorbar(aes(ymin = mean_own_shock - 1.96*se_shock,
                    ymax = mean_own_shock + 1.96*se_shock),
                width = 0.2, color = "gray30") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  labs(
    x = "Network Exposure Quintile",
    y = "Mean Unemployment Shock (pp)",
    title = "Unemployment Shocks by Network Exposure Quintile",
    subtitle = "Counties with higher network exposure to shocked areas experience worse own outcomes",
    caption = "Note: Error bars show 95% confidence intervals. Network exposure quintiles based on SCI-weighted shock exposure."
  ) +
  theme_apep() +
  theme(panel.grid.major.x = element_blank()) +
  annotate("text", x = 1, y = quintile_plot_data$mean_own_shock[1] - 0.15,
           label = sprintf("%.2f pp", quintile_plot_data$mean_own_shock[1]),
           size = 3.5, fontface = "bold") +
  annotate("text", x = 5, y = quintile_plot_data$mean_own_shock[5] + 0.15,
           label = sprintf("%.2f pp", quintile_plot_data$mean_own_shock[5]),
           size = 3.5, fontface = "bold")

ggsave("output/paper_73/figures/fig3_quintiles.png", fig3,
       width = 9, height = 7, dpi = 300, bg = "white")
ggsave("output/paper_73/figures/fig3_quintiles.pdf", fig3,
       width = 9, height = 7, bg = "white")

cat("  Saved fig3_quintiles\n")

# -----------------------------------------------------------------------------
# Figure 4: SCI Diversity vs Economic Outcomes
# -----------------------------------------------------------------------------

cat("Creating Figure 4: Diversity vs College Share...\n")

fig4 <- ggplot(analysis, aes(x = diversity, y = college_share)) +
  geom_point(alpha = 0.3, color = "#2E86AB", size = 0.8) +
  geom_smooth(method = "lm", color = "#E94F37", linewidth = 1.2, se = TRUE) +
  labs(
    x = "SCI Geographic Diversity (1 - HHI)",
    y = "College-Educated Share (%)",
    title = "Social Network Diversity Correlates with Human Capital",
    subtitle = sprintf("r = %.2f; counties with more geographically diverse networks have more educated populations",
                       cor(analysis$diversity, analysis$college_share, use = "complete.obs")),
    caption = "Note: Each point is a U.S. county. College share from ACS 2019 5-year estimates."
  ) +
  theme_apep()

ggsave("output/paper_73/figures/fig4_diversity_college.png", fig4,
       width = 9, height = 7, dpi = 300, bg = "white")
ggsave("output/paper_73/figures/fig4_diversity_college.pdf", fig4,
       width = 9, height = 7, bg = "white")

cat("  Saved fig4_diversity_college\n")

# -----------------------------------------------------------------------------
# Figure 5: Map of Unemployment Shock
# -----------------------------------------------------------------------------

cat("Creating Figure 5: Unemployment Shock Map...\n")

fig5 <- ggplot(continental) +
  geom_sf(aes(fill = unemp_shock), color = NA, size = 0.05) +
  scale_fill_gradient2(
    name = "Unemployment\nShock (pp)",
    low = "#2E86AB",
    mid = "white",
    high = "#E94F37",
    midpoint = 0,
    limits = c(-5, 5),
    oob = squish,
    breaks = seq(-4, 4, 2)
  ) +
  coord_sf(crs = 5070) +
  labs(
    title = "COVID-Era Labor Market Shocks Across U.S. Counties",
    subtitle = "Change in unemployment rate from 2019 to 2021 (percentage points)",
    caption = "Source: American Community Survey 5-year estimates. Red = unemployment increased; Blue = unemployment decreased."
  ) +
  theme_apep() +
  theme(
    axis.text = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank()
  )

ggsave("output/paper_73/figures/fig5_shock_map.png", fig5,
       width = 12, height = 8, dpi = 300, bg = "white")
ggsave("output/paper_73/figures/fig5_shock_map.pdf", fig5,
       width = 12, height = 8, bg = "white")

cat("  Saved fig5_shock_map\n")

# -----------------------------------------------------------------------------
# Figure 6: Within-State Variation
# -----------------------------------------------------------------------------

cat("Creating Figure 6: State Fixed Effects...\n")

# Add state-level means for visualization
state_means <- analysis %>%
  group_by(state_fips) %>%
  summarize(
    state_mean_exposure = mean(network_exposure),
    state_mean_shock = mean(unemp_shock)
  )

analysis_demean <- analysis %>%
  left_join(state_means, by = "state_fips") %>%
  mutate(
    exposure_demean = network_exposure - state_mean_exposure,
    shock_demean = unemp_shock - state_mean_shock
  )

# Binned scatter of demeaned values
analysis_demean_binned <- analysis_demean %>%
  mutate(exposure_bin = ntile(exposure_demean, 20)) %>%
  group_by(exposure_bin) %>%
  summarize(
    mean_exposure = mean(exposure_demean),
    mean_shock = mean(shock_demean),
    se_shock = sd(shock_demean) / sqrt(n()),
    n = n()
  )

fig6 <- ggplot(analysis_demean_binned, aes(x = mean_exposure, y = mean_shock)) +
  geom_point(aes(size = n), color = "#2E86AB", alpha = 0.8) +
  geom_errorbar(aes(ymin = mean_shock - 1.96*se_shock,
                    ymax = mean_shock + 1.96*se_shock),
                width = 0.01, color = "gray50", alpha = 0.6) +
  geom_smooth(method = "lm", color = "#E94F37", linewidth = 1, se = TRUE, alpha = 0.2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
  scale_size_continuous(range = c(2, 6), guide = "none") +
  labs(
    x = "Network Exposure (demeaned within state)",
    y = "Unemployment Shock (demeaned within state)",
    title = "Network Exposure Effect Persists Within States",
    subtitle = "Relationship holds after removing state-level variation",
    caption = "Note: Both variables demeaned by state mean. Bins represent ~160 counties each."
  ) +
  theme_apep()

ggsave("output/paper_73/figures/fig6_within_state.png", fig6,
       width = 10, height = 7, dpi = 300, bg = "white")
ggsave("output/paper_73/figures/fig6_within_state.pdf", fig6,
       width = 10, height = 7, bg = "white")

cat("  Saved fig6_within_state\n")

cat("\nAll figures created successfully!\n")

# List all figures
cat("\nFigures saved to output/paper_73/figures/:\n")
list.files("output/paper_73/figures/", pattern = "\\.(png|pdf)$")
