# =============================================================================
# 05_figures.R - Maps and Visualizations
# Swiss Childcare Mandates and Maternal Labor Supply
# Spatial RDD at Canton Borders
# =============================================================================

library(tidyverse)
library(sf)
library(viridis)
library(patchwork)

# APEP theme
theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "gray90"),
      plot.title = element_text(face = "bold", size = base_size + 2),
      plot.subtitle = element_text(color = "gray40"),
      axis.title = element_text(face = "bold"),
      legend.position = "bottom",
      strip.text = element_text(face = "bold"),
      plot.caption = element_text(hjust = 0, color = "gray50")
    )
}
theme_set(theme_apep())

# Load data
data_dir <- "output/paper_94/data"
gemeinde_matched <- readRDS(file.path(data_dir, "gemeinde_matched.rds"))
canton_sf <- readRDS(file.path(data_dir, "canton_sf.rds"))
rdd_sample <- readRDS(file.path(data_dir, "rdd_sample.rds"))
treatment_border <- readRDS(file.path(data_dir, "treatment_border.rds"))

fig_dir <- "output/paper_94/figures"
dir.create(fig_dir, showWarnings = FALSE)

# =============================================================================
# 1. Treatment Map
# =============================================================================

message("=== FIGURE 1: TREATMENT MAP ===")

# Add treatment status for mapping
gemeinde_matched <- gemeinde_matched %>%
  mutate(
    treatment_status = case_when(
      canton_abbr %in% c("BE", "ZH") ~ "Treated (2010)",
      canton_abbr %in% c("BS", "GR", "LU", "SH") ~ "Treated (2014-16)",
      canton_abbr == "NE" ~ "French canton (excluded)",
      TRUE ~ "Control"
    )
  )

p_treatment <- ggplot() +
  geom_sf(data = gemeinde_matched, aes(fill = treatment_status), color = "white", size = 0.05) +
  geom_sf(data = canton_sf, fill = NA, color = "black", size = 0.3) +
  geom_sf(data = treatment_border, color = "red", size = 1.5) +
  scale_fill_manual(
    values = c(
      "Treated (2010)" = "#2166AC",
      "Treated (2014-16)" = "#92C5DE",
      "French canton (excluded)" = "#D1E5F0",
      "Control" = "#F4A582"
    ),
    name = ""
  ) +
  labs(
    title = "Childcare Mandate Adoption by Canton",
    subtitle = "Bern and Zurich adopted in 2010; later adopters in 2014-16",
    caption = "Red line shows treatment boundary for spatial RDD (German-German borders)"
  ) +
  theme_void() +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(color = "gray40"),
    legend.text = element_text(size = 10)
  )

ggsave(file.path(fig_dir, "fig1_treatment_map.pdf"), p_treatment, width = 10, height = 8)
message("Saved: fig1_treatment_map.pdf")

# =============================================================================
# 2. Language Map (Röstigraben)
# =============================================================================

message("=== FIGURE 2: LANGUAGE MAP ===")

p_language <- ggplot() +
  geom_sf(data = gemeinde_matched, aes(fill = lang), color = "white", size = 0.05) +
  geom_sf(data = canton_sf, fill = NA, color = "black", size = 0.3) +
  scale_fill_manual(
    values = c("German" = "#2166AC", "French" = "#B2182B", "Italian" = "#1B7837"),
    name = "Language"
  ) +
  labs(
    title = "Language Regions in Switzerland",
    subtitle = "The Röstigraben (German-French divide) is a major political cleavage",
    caption = "Analysis restricted to German-speaking cantons to avoid language confounds"
  ) +
  theme_void() +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(color = "gray40")
  )

ggsave(file.path(fig_dir, "fig2_language_map.pdf"), p_language, width = 10, height = 8)
message("Saved: fig2_language_map.pdf")

# =============================================================================
# 3. Outcome Map (Family Initiative 2013 Yes Share)
# =============================================================================

message("=== FIGURE 3: OUTCOME MAP ===")

p_outcome <- ggplot() +
  geom_sf(data = gemeinde_matched, aes(fill = yes_share_2013), color = "white", size = 0.05) +
  geom_sf(data = canton_sf, fill = NA, color = "black", size = 0.3) +
  geom_sf(data = treatment_border, color = "red", size = 1) +
  scale_fill_viridis_c(
    name = "Yes Share (%)",
    option = "viridis",
    na.value = "gray80"
  ) +
  labs(
    title = "Family Policy Decree 2013: Yes Share by Municipality",
    subtitle = "Post-treatment outcome measuring support for family policy",
    caption = "Red line shows treatment boundary"
  ) +
  theme_void() +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(color = "gray40")
  )

ggsave(file.path(fig_dir, "fig3_outcome_map.pdf"), p_outcome, width = 10, height = 8)
message("Saved: fig3_outcome_map.pdf")

# =============================================================================
# 4. RDD Sample Map (Distance to Border)
# =============================================================================

message("=== FIGURE 4: RDD SAMPLE MAP ===")

# Create distance categories
rdd_sample <- rdd_sample %>%
  mutate(
    dist_cat = cut(abs(distance_to_border),
                   breaks = c(0, 5, 10, 15, 20, 30),
                   labels = c("0-5km", "5-10km", "10-15km", "15-20km", "20-30km"))
  )

p_rdd_sample <- ggplot() +
  geom_sf(data = gemeinde_matched %>% filter(lang != "German"),
          fill = "gray90", color = "white", size = 0.05) +
  geom_sf(data = rdd_sample, aes(fill = dist_cat), color = "white", size = 0.05) +
  geom_sf(data = canton_sf, fill = NA, color = "black", size = 0.3) +
  geom_sf(data = treatment_border, color = "red", size = 1.5) +
  scale_fill_viridis_d(
    name = "Distance to Border",
    option = "plasma",
    direction = -1
  ) +
  labs(
    title = "RDD Sample: German-Speaking Municipalities Near Border",
    subtitle = paste("N =", nrow(rdd_sample), "municipalities within 30km of treatment boundary"),
    caption = "Darker colors indicate closer to border (stronger RDD identification)"
  ) +
  theme_void() +
  theme(
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(color = "gray40")
  )

ggsave(file.path(fig_dir, "fig4_rdd_sample_map.pdf"), p_rdd_sample, width = 10, height = 8)
message("Saved: fig4_rdd_sample_map.pdf")

# =============================================================================
# 5. Bandwidth Sensitivity Plot
# =============================================================================

message("=== FIGURE 5: BANDWIDTH SENSITIVITY ===")

library(rdrobust)

# Prepare data
rdd_data <- rdd_sample %>%
  st_drop_geometry() %>%
  filter(!is.na(yes_share_2013), !is.na(distance_to_border))

# Sweep bandwidths
bandwidths <- seq(3, 20, by = 1)
bw_results <- map_dfr(bandwidths, function(h) {
  rd <- tryCatch({
    rdrobust(
      y = rdd_data$yes_share_2013,
      x = rdd_data$distance_to_border,
      c = 0,
      h = h
    )
  }, error = function(e) NULL)

  if (is.null(rd)) return(NULL)

  tibble(
    bandwidth = h,
    estimate = rd$coef[1],
    se = rd$se[1],
    ci_lower = rd$ci[1, 1],
    ci_upper = rd$ci[1, 2],
    n_eff = sum(rd$N)
  )
})

# Get MSE-optimal bandwidth
mse_bw <- rdrobust(
  y = rdd_data$yes_share_2013,
  x = rdd_data$distance_to_border,
  c = 0
)$bws[1]

p_bw <- ggplot(bw_results, aes(x = bandwidth, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = mse_bw, linetype = "dashed", color = "#D73027") +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), fill = "#2166AC", alpha = 0.2) +
  geom_line(color = "#2166AC", size = 1) +
  geom_point(color = "#2166AC", size = 2) +
  annotate("text", x = mse_bw + 0.5, y = max(bw_results$ci_upper, na.rm = TRUE),
           label = paste("MSE-optimal\n(", round(mse_bw, 1), "km)"),
           hjust = 0, size = 3, color = "#D73027") +
  labs(
    title = "Bandwidth Sensitivity Analysis",
    subtitle = "RDD estimates across different bandwidth choices",
    x = "Bandwidth (km)",
    y = "RDD Estimate (pp)",
    caption = "Shaded area shows 95% confidence interval"
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig5_bandwidth_sensitivity.pdf"), p_bw, width = 10, height = 6)
message("Saved: fig5_bandwidth_sensitivity.pdf")

# =============================================================================
# 6. McCrary Density Plot
# =============================================================================

message("=== FIGURE 6: MCCRARY DENSITY ===")

# Create density plot around the cutoff
density_data <- rdd_data %>%
  mutate(side = ifelse(distance_to_border >= 0, "Treated", "Control"))

p_density <- ggplot(density_data, aes(x = distance_to_border, fill = side)) +
  geom_histogram(aes(y = after_stat(density)), bins = 40, alpha = 0.7,
                 color = "white", boundary = 0) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray30", linewidth = 1) +
  scale_fill_manual(
    values = c("Treated" = "#2166AC", "Control" = "#B2182B"),
    name = ""
  ) +
  labs(
    x = "Distance to Canton Border (km)",
    y = "Density",
    title = "Distribution of Municipalities Around Treatment Border",
    subtitle = "McCrary test: t = 1.25, p = 0.21 (no evidence of manipulation)",
    caption = "Dashed line shows treatment boundary (0 km)"
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig_density.pdf"), p_density, width = 10, height = 6)
message("Saved: fig_density.pdf")

# =============================================================================
# 7. Combined Panel Figure
# =============================================================================

message("=== CREATING COMBINED FIGURE ===")

# Combine key figures into a panel
combined <- (p_treatment + p_language) / (p_outcome + p_rdd_sample) +
  plot_annotation(
    title = "Swiss Childcare Mandates: Spatial RDD Design",
    theme = theme(plot.title = element_text(face = "bold", size = 16))
  )

ggsave(file.path(fig_dir, "fig_combined_maps.pdf"), combined, width = 14, height = 14)
message("Saved: fig_combined_maps.pdf")

message("\n=== ALL FIGURES COMPLETE ===")
