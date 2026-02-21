###############################################################################
# 05_figures.R — All figures for the paper
# Paper: Secret Ballots and Women's Political Voice (apep_0438)
###############################################################################

# Source packages from same directory
script_args <- commandArgs(trailingOnly = FALSE)
script_path <- grep("--file=", script_args, value = TRUE)
if (length(script_path) > 0) {
  script_dir_local <- dirname(normalizePath(sub("--file=", "", script_path)))
} else {
  script_dir_local <- getwd()
}
source(file.path(script_dir_local, "00_packages.R"))

cat("\n=== PHASE 5: FIGURES ===\n\n")

# --- Load data ---------------------------------------------------------------
panel       <- readRDS(file.path(data_dir, "panel.rds"))
ar_ai_panel <- readRDS(file.path(data_dir, "ar_ai_panel.rds"))
border_gem  <- readRDS(file.path(data_dir, "border_gemeinden.rds"))
gemeinde_sf <- readRDS(file.path(data_dir, "gemeinde_centroids.rds"))
robustness  <- readRDS(file.path(data_dir, "robustness_results.rds"))

# ============================================================================
# Figure 1: Map of Study Region — Landsgemeinde Cantons
# ============================================================================
cat("Creating Figure 1: Map...\n")

# Create treatment map
map_data <- gemeinde_sf %>%
  mutate(
    lg_status = case_when(
      canton_abbr %in% c("AI", "GL") ~ "Active Landsgemeinde",
      canton_abbr %in% c("AR", "OW", "NW") ~ "Abolished (1996-98)",
      canton_abbr %in% c("SG", "LU") ~ "Never had (control)",
      TRUE ~ "Other cantons"
    ),
    lg_status = factor(lg_status, levels = c(
      "Active Landsgemeinde", "Abolished (1996-98)",
      "Never had (control)", "Other cantons"
    ))
  )

# Focus on central-eastern Switzerland
bbox <- st_bbox(map_data %>% filter(canton_abbr %in%
  c("AI", "AR", "GL", "SG", "OW", "NW", "LU", "SZ", "ZG", "UR", "GR")))

fig1 <- ggplot(map_data) +
  geom_sf(aes(fill = lg_status), color = "grey70", linewidth = 0.1) +
  geom_sf(data = map_data %>% filter(canton_abbr %in%
    c("AI", "AR", "GL", "SG", "OW", "NW", "LU")),
    fill = NA, color = "black", linewidth = 0.4) +
  scale_fill_manual(
    values = c(
      "Active Landsgemeinde" = "#c0392b",
      "Abolished (1996-98)" = "#e67e22",
      "Never had (control)" = "#2980b9",
      "Other cantons" = "grey90"
    ),
    name = NULL
  ) +
  coord_sf(xlim = c(bbox["xmin"] - 5000, bbox["xmax"] + 5000),
           ylim = c(bbox["ymin"] - 5000, bbox["ymax"] + 5000)) +
  labs(title = "Landsgemeinde Status by Canton",
       subtitle = "Central-Eastern Switzerland") +
  theme_void(base_size = 10) +
  theme(legend.position = "bottom",
        plot.title = element_text(face = "bold"))

ggsave(file.path(fig_dir, "fig1_map.pdf"), fig1, width = 7, height = 5)
ggsave(file.path(fig_dir, "fig1_map.png"), fig1, width = 7, height = 5, dpi = 300)
cat("  Saved fig1_map\n")

# ============================================================================
# Figure 2: RDD Plot — Yes-Share vs Distance to Border
# ============================================================================
cat("Creating Figure 2: RDD scatter...\n")

# Post-1997 data at AR-AI border
rdd_plot_data <- ar_ai_panel %>%
  filter(post_abolition) %>%
  group_by(gem_id, signed_dist, ar_side) %>%
  summarise(yes_share = mean(yes_share, na.rm = TRUE),
            n_votes = n(), .groups = "drop")

# Bin the data for visual clarity
rdd_plot_data <- rdd_plot_data %>%
  mutate(dist_bin = cut(signed_dist,
                        breaks = seq(-25, 25, by = 2),
                        include.lowest = TRUE))

binned <- rdd_plot_data %>%
  group_by(dist_bin, ar_side) %>%
  summarise(
    yes_share = mean(yes_share, na.rm = TRUE),
    dist_mid = mean(signed_dist, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  ) %>%
  filter(!is.na(dist_mid))

fig2 <- ggplot() +
  geom_point(data = rdd_plot_data,
             aes(x = signed_dist, y = yes_share, color = ar_side),
             alpha = 0.4, size = 1.5) +
  geom_smooth(data = rdd_plot_data %>% filter(signed_dist < 0),
              aes(x = signed_dist, y = yes_share),
              method = "loess", se = TRUE, color = "#c0392b",
              fill = "#c0392b", alpha = 0.15) +
  geom_smooth(data = rdd_plot_data %>% filter(signed_dist > 0),
              aes(x = signed_dist, y = yes_share),
              method = "loess", se = TRUE, color = "#2980b9",
              fill = "#2980b9", alpha = 0.15) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey30") +
  scale_color_manual(
    values = c("TRUE" = "#2980b9", "FALSE" = "#c0392b"),
    labels = c("TRUE" = "AR (abolished)", "FALSE" = "AI (Landsgemeinde)"),
    name = NULL
  ) +
  labs(
    x = "Distance to AR-AI Border (km, positive = AR side)",
    y = "Average Yes-Share on Federal Referendums",
    title = "Spatial Discontinuity at the AR-AI Border",
    subtitle = "Post-1997 federal referendums"
  )

ggsave(file.path(fig_dir, "fig2_rdd_scatter.pdf"), fig2, width = 7, height = 5)
ggsave(file.path(fig_dir, "fig2_rdd_scatter.png"), fig2, width = 7, height = 5, dpi = 300)
cat("  Saved fig2_rdd_scatter\n")

# ============================================================================
# Figure 3: Event Study — Border Discontinuity by Year
# ============================================================================
cat("Creating Figure 3: Event study...\n")

event_df <- robustness$event_study

if (!is.null(event_df) && nrow(event_df) > 0) {
  fig3 <- ggplot(event_df, aes(x = year, y = estimate)) +
    geom_hline(yintercept = 0, color = "grey50", linetype = "dashed") +
    geom_vline(xintercept = 1997, color = "#e67e22", linetype = "dashed",
               linewidth = 0.8) +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
                fill = "#3498db", alpha = 0.15) +
    geom_point(aes(color = post), size = 2) +
    geom_line(color = "grey40", alpha = 0.5) +
    scale_color_manual(
      values = c("TRUE" = "#2980b9", "FALSE" = "#95a5a6"),
      labels = c("TRUE" = "Post-abolition", "FALSE" = "Pre-abolition"),
      name = NULL
    ) +
    annotate("text", x = 1997.5, y = max(event_df$ci_upper, na.rm = TRUE),
             label = "AR abolishes\nLandsgemeinde", hjust = 0, size = 3,
             color = "#e67e22") +
    labs(
      x = "Year",
      y = "Estimated Border Discontinuity\n(AR - AI, pp)",
      title = "Event Study: AR-AI Border Discontinuity by Year",
      subtitle = "Should be zero pre-1997 if design is valid"
    )

  ggsave(file.path(fig_dir, "fig3_event_study.pdf"), fig3, width = 8, height = 5)
  ggsave(file.path(fig_dir, "fig3_event_study.png"), fig3, width = 8, height = 5, dpi = 300)
  cat("  Saved fig3_event_study\n")
}

# ============================================================================
# Figure 4: Gender vs Non-Gender Referendum Comparison
# ============================================================================
cat("Creating Figure 4: Gender vs non-gender...\n")

# Compare border discontinuity for gender vs non-gender topics
topic_comparison <- ar_ai_panel %>%
  filter(post_abolition) %>%
  mutate(topic = ifelse(gender_related, "Gender-Related", "Other")) %>%
  group_by(gem_id, signed_dist, ar_side, topic) %>%
  summarise(yes_share = mean(yes_share, na.rm = TRUE), .groups = "drop")

fig4 <- ggplot(topic_comparison, aes(x = signed_dist, y = yes_share)) +
  geom_point(aes(color = ar_side), alpha = 0.3, size = 1) +
  geom_smooth(data = topic_comparison %>% filter(signed_dist < 0),
              method = "loess", se = TRUE, color = "#c0392b",
              fill = "#c0392b", alpha = 0.1) +
  geom_smooth(data = topic_comparison %>% filter(signed_dist > 0),
              method = "loess", se = TRUE, color = "#2980b9",
              fill = "#2980b9", alpha = 0.1) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  facet_wrap(~topic) +
  scale_color_manual(
    values = c("TRUE" = "#2980b9", "FALSE" = "#c0392b"),
    labels = c("TRUE" = "AR (abolished)", "FALSE" = "AI (Landsgemeinde)"),
    name = NULL
  ) +
  labs(
    x = "Distance to AR-AI Border (km)",
    y = "Yes-Share",
    title = "Border Discontinuity: Gender vs Other Referendums",
    subtitle = "Larger discontinuity on gender topics supports the mechanism"
  )

ggsave(file.path(fig_dir, "fig4_gender_placebo.pdf"), fig4, width = 10, height = 5)
ggsave(file.path(fig_dir, "fig4_gender_placebo.png"), fig4, width = 10, height = 5, dpi = 300)
cat("  Saved fig4_gender_placebo\n")

# ============================================================================
# Figure 5: Bandwidth Sensitivity
# ============================================================================
cat("Creating Figure 5: Bandwidth sensitivity...\n")

bw_df <- robustness$bandwidth

if (!is.null(bw_df) && nrow(bw_df) > 0) {
  fig5 <- ggplot(bw_df, aes(x = bandwidth, y = estimate)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
                fill = "#3498db", alpha = 0.2) +
    geom_point(size = 3, color = "#2c3e50") +
    geom_line(color = "#2c3e50") +
    labs(
      x = "Bandwidth (km)",
      y = "RDD Estimate",
      title = "Bandwidth Sensitivity",
      subtitle = "Shaded area: 95% robust CI"
    )

  ggsave(file.path(fig_dir, "fig5_bandwidth.pdf"), fig5, width = 6, height = 4)
  ggsave(file.path(fig_dir, "fig5_bandwidth.png"), fig5, width = 6, height = 4, dpi = 300)
  cat("  Saved fig5_bandwidth\n")
}

# ============================================================================
# Figure 6: Permutation Distribution
# ============================================================================
cat("Creating Figure 6: Permutation inference...\n")

perm_data <- robustness$permutation

if (!is.null(perm_data)) {
  perm_df <- tibble(estimate = perm_data$perm_dist) %>%
    filter(!is.na(estimate))

  fig6 <- ggplot(perm_df, aes(x = estimate)) +
    geom_histogram(bins = 40, fill = "grey70", color = "white") +
    geom_vline(xintercept = perm_data$actual, color = "#c0392b",
               linewidth = 1.2, linetype = "solid") +
    annotate("text", x = perm_data$actual, y = Inf,
             label = paste0("Actual\n(p = ", round(perm_data$perm_pval, 3), ")"),
             vjust = 1.5, hjust = -0.1, color = "#c0392b", size = 3.5) +
    labs(
      x = "Permuted Estimates",
      y = "Count",
      title = "Permutation Inference",
      subtitle = paste0(length(perm_data$perm_dist), " random permutations of treatment")
    )

  ggsave(file.path(fig_dir, "fig6_permutation.pdf"), fig6, width = 6, height = 4)
  ggsave(file.path(fig_dir, "fig6_permutation.png"), fig6, width = 6, height = 4, dpi = 300)
  cat("  Saved fig6_permutation\n")
}

# ============================================================================
# Figure 7: Time Series — AR vs AI on Key Gender Referendums
# ============================================================================
cat("Creating Figure 7: AR vs AI on gender referendums over time...\n")

gender_ts <- ar_ai_panel %>%
  filter(gender_related) %>%
  group_by(votedate, ar_side) %>%
  summarise(
    yes_share = mean(yes_share, na.rm = TRUE),
    n_gemeinden = n_distinct(gem_id),
    .groups = "drop"
  ) %>%
  mutate(side = ifelse(ar_side, "AR (abolished 1997)", "AI (Landsgemeinde)"))

if (nrow(gender_ts) > 2) {
  fig7 <- ggplot(gender_ts, aes(x = votedate, y = yes_share, color = side)) +
    geom_vline(xintercept = as.Date("1997-04-27"), linetype = "dashed",
               color = "#e67e22") +
    geom_point(size = 3) +
    geom_line(linewidth = 0.8) +
    scale_color_manual(
      values = c("AR (abolished 1997)" = "#2980b9",
                 "AI (Landsgemeinde)" = "#c0392b"),
      name = NULL
    ) +
    scale_y_continuous(labels = scales::percent) +
    labs(
      x = NULL,
      y = "Mean Yes-Share",
      title = "Gender-Related Referendum Outcomes: AR vs AI",
      subtitle = "Mean yes-share across border Gemeinden"
    )

  ggsave(file.path(fig_dir, "fig7_gender_timeseries.pdf"), fig7, width = 8, height = 5)
  ggsave(file.path(fig_dir, "fig7_gender_timeseries.png"), fig7, width = 8, height = 5, dpi = 300)
  cat("  Saved fig7_gender_timeseries\n")
}

cat("\n✓ All figures generated\n")
