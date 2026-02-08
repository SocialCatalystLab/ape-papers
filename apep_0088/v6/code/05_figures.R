# =============================================================================
# 05_figures.R - Publication-Quality Figures
# Swiss Cantonal Energy Laws and Federal Referendum Voting
# Spatial RDD at Canton Borders
# =============================================================================

# Get script directory for portable sourcing
get_this_script_dir <- function() {
  for (i in seq_len(sys.nframe())) {
    if (!is.null(sys.frame(i)$ofile)) {
      return(dirname(sys.frame(i)$ofile))
    }
  }
  return(getwd())
}
script_dir <- get_this_script_dir()
source(file.path(script_dir, "00_packages.R"))

# APEP theme (override with function version for figures)
theme_apep <- function() {
  theme_minimal(base_size = 11) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "grey90"),
      plot.title = element_text(face = "bold", size = 12),
      axis.title = element_text(size = 10),
      legend.position = "bottom",
      plot.caption = element_text(size = 8, color = "grey50")
    )
}

# Load data (using paths from 00_packages.R)
figures_dir <- fig_dir
dir.create(figures_dir, showWarnings = FALSE, recursive = TRUE)

voting_data <- readRDS(file.path(data_dir, "voting_data.rds"))
voting_sf <- readRDS(file.path(data_dir, "voting_sf.rds"))

# =============================================================================
# Figure 1: Map of Treatment Status and Vote Shares
# =============================================================================

message("Creating Figure 1: Treatment map...")

# Prepare map data
map_data <- voting_sf %>%
  filter(!is.na(yes_share)) %>%
  mutate(
    treated_label = ifelse(treated, "Treated (energy law before 2017)", "Control")
  )

# Panel A: Treatment status
fig1a <- ggplot(map_data) +
  geom_sf(aes(fill = treated_label), color = "white", linewidth = 0.05) +
  scale_fill_manual(
    values = c("Treated (energy law before 2017)" = "#2166AC",
               "Control" = "#B2182B"),
    name = ""
  ) +
  labs(
    title = "A. Cantonal Energy Law Status",
    subtitle = "Treatment: comprehensive energy law in force before May 2017"
  ) +
  theme_apep() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank()
  )

ggsave(file.path(figures_dir, "fig1a_treatment_map.pdf"), fig1a,
       width = 7, height = 5, device = cairo_pdf)

# Panel B: Vote shares
fig1b <- ggplot(map_data) +
  geom_sf(aes(fill = yes_share), color = "white", linewidth = 0.05) +
  scale_fill_gradient2(
    low = "#B2182B", mid = "#F7F7F7", high = "#2166AC",
    midpoint = 58.2,  # National average
    name = "Yes share (%)",
    limits = c(15, 90)
  ) +
  labs(
    title = "B. Energy Strategy 2050 Vote Shares",
    subtitle = "May 21, 2017 federal referendum (national avg: 58.2%)"
  ) +
  theme_apep() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank()
  )

ggsave(file.path(figures_dir, "fig1b_voteshare_map.pdf"), fig1b,
       width = 7, height = 5, device = cairo_pdf)

message("   Saved fig1a_treatment_map.pdf and fig1b_voteshare_map.pdf")

# =============================================================================
# Figure 1c: Language Zones Map
# =============================================================================

message("Creating Figure 1c: Language zones map...")

# Add language to map data
language_colors <- c(
  "German" = "#4DAF4A",
  "French" = "#984EA3",
  "Italian" = "#FF7F00"
)

fig1c <- ggplot(map_data) +
  geom_sf(aes(fill = lang), color = "white", linewidth = 0.05) +
  scale_fill_manual(
    values = language_colors,
    name = "Language Region"
  ) +
  labs(
    title = "C. Language Regions (Röstigraben)",
    subtitle = "Primary confounder: French cantons support federal energy policy more"
  ) +
  theme_apep() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank()
  )

ggsave(file.path(figures_dir, "fig1c_language_map.pdf"), fig1c,
       width = 7, height = 5, device = cairo_pdf)

message("   Saved fig1c_language_map.pdf")

# =============================================================================
# Figure 1d: Treatment Timing Map
# =============================================================================

message("Creating Figure 1d: Treatment timing map...")

# Create treatment timing variable using IN-FORCE years (not adoption years)
# GR: in-force January 2011; BE: January 2012; AG: January 2013; BL: July 2016; BS: January 2017
treatment_timing <- map_data %>%
  mutate(
    in_force_year = case_when(
      canton_abbr == "GR" ~ "2011",
      canton_abbr == "BE" ~ "2012",
      canton_abbr == "AG" ~ "2013",
      canton_abbr == "BL" ~ "2016",
      canton_abbr == "BS" ~ "2017",
      TRUE ~ "Control"
    ),
    in_force_year = factor(in_force_year, levels = c("2011", "2012", "2013", "2016", "2017", "Control"))
  )

timing_colors <- c(
  "2011" = "#08519C",
  "2012" = "#3182BD",
  "2013" = "#6BAED6",
  "2016" = "#9ECAE1",
  "2017" = "#BDD7E7",
  "Control" = "#FCBBA1"
)

fig1d <- ggplot(treatment_timing) +
  geom_sf(aes(fill = in_force_year), color = "white", linewidth = 0.05) +
  scale_fill_manual(
    values = timing_colors,
    name = "In-Force Year"
  ) +
  labs(
    title = "D. Staggered Treatment Timing",
    subtitle = "Year cantonal energy law came into force"
  ) +
  theme_apep() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank()
  )

ggsave(file.path(figures_dir, "fig1d_timing_map.pdf"), fig1d,
       width = 7, height = 5, device = cairo_pdf)

message("   Saved fig1d_timing_map.pdf")

# =============================================================================
# Figure 1e: Border Municipalities (RDD Sample)
# =============================================================================

message("Creating Figure 1e: Border municipalities map...")

# Calculate distance to border for highlighting
voting_sf_clean <- map_data %>%
  filter(!is.na(yes_share)) %>%
  mutate(centroid = st_centroid(st_geometry(.)))

# Get treated and control areas
treated_canton_ids <- c(2, 12, 13, 18, 19)  # BE, BS, BL, GR, AG

canton_borders <- voting_sf_clean %>%
  group_by(canton_id) %>%
  summarise(.groups = "drop")  # Let sf handle geometry union automatically

# CRITICAL FIX: Use get_policy_border() to compute ONLY internal canton borders
# The original code used st_boundary() intersection which includes national
# borders with France, Italy, Germany - invalidating the RDD sample selection.
message("Computing CORRECT policy border for Figure 1e...")
border_line <- tryCatch({
  get_policy_border(canton_borders, treated_canton_ids, canton_id_col = "canton_id")
}, error = function(e) {
  message(paste("Border computation error:", e$message))
  NULL
})

if (!is.null(border_line)) {
  # Calculate distance to border
  voting_sf_clean <- voting_sf_clean %>%
    mutate(
      dist_to_border = as.numeric(st_distance(centroid, border_line)),
      dist_km = dist_to_border / 1000,
      near_border = dist_km <= 5,  # Within 5km of border
      border_label = case_when(
        near_border & treated ~ "Treated (near border)",
        near_border & !treated ~ "Control (near border)",
        !near_border & treated ~ "Treated (interior)",
        TRUE ~ "Control (interior)"
      )
    )

  border_colors <- c(
    "Treated (near border)" = "#08519C",
    "Control (near border)" = "#A50F15",
    "Treated (interior)" = "#9ECAE1",
    "Control (interior)" = "#FCBBA1"
  )

  fig1e <- ggplot(voting_sf_clean) +
    geom_sf(aes(fill = border_label), color = "white", linewidth = 0.05) +
    scale_fill_manual(
      values = border_colors,
      name = ""
    ) +
    labs(
      title = "E. RDD Sample: Border Municipalities",
      subtitle = "Gemeinden within 5km of treated-control border (dark colors)"
    ) +
    theme_apep() +
    theme(
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      panel.grid = element_blank()
    )

  ggsave(file.path(figures_dir, "fig1e_border_map.pdf"), fig1e,
         width = 7, height = 5, device = cairo_pdf)

  message("   Saved fig1e_border_map.pdf")
} else {
  message("   Warning: Could not compute border - skipping fig1e")
}

# =============================================================================
# Figure 2: Distribution of Vote Shares by Treatment Status
# =============================================================================

message("Creating Figure 2: Distribution comparison...")

fig2 <- ggplot(voting_data, aes(x = yes_share, fill = treated)) +
  geom_histogram(alpha = 0.6, position = "identity", bins = 40, color = "white") +
  geom_vline(aes(xintercept = 58.2), linetype = "dashed", color = "grey30") +
  annotate("text", x = 59, y = Inf, label = "National avg\n(58.2%)",
           hjust = 0, vjust = 1.5, size = 3, color = "grey30") +
  scale_fill_manual(
    values = c("TRUE" = "#2166AC", "FALSE" = "#B2182B"),
    labels = c("TRUE" = "Treated", "FALSE" = "Control"),
    name = ""
  ) +
  labs(
    x = "Yes Share (%)",
    y = "Number of Gemeinden",
    title = "Distribution of Vote Shares by Treatment Status",
    subtitle = "Energy Strategy 2050 referendum, May 2017"
  ) +
  theme_apep()

ggsave(file.path(figures_dir, "fig2_distribution.pdf"), fig2,
       width = 7, height = 4.5, device = cairo_pdf)

message("   Saved fig2_distribution.pdf")

# =============================================================================
# Figure 3: Spatial RDD Plot
# =============================================================================

message("Creating Figure 3: Spatial RDD plot...")

# Compute distance to border
voting_sf_clean <- voting_sf %>%
  filter(!is.na(yes_share) & !is.na(treated)) %>%
  mutate(centroid = st_centroid(geom))

# Get canton borders
treated_cantons <- c(2, 12, 13, 18, 19)

canton_borders <- voting_sf_clean %>%
  group_by(kantonsnummer) %>%
  summarise(.groups = "drop")  # Let sf handle geometry union automatically

# CRITICAL FIX: Use get_policy_border() for correct internal borders only
message("Computing CORRECT policy border for Figure 3...")
border <- get_policy_border(canton_borders, treated_cantons, canton_id_col = "kantonsnummer")

# Compute running variable
if (!st_is_empty(border)) {
  voting_sf_clean <- voting_sf_clean %>%
    mutate(
      dist_to_border = as.numeric(st_distance(centroid, border)) / 1000,  # km
      running_var = ifelse(treated, dist_to_border, -dist_to_border)
    )

  # Create FULL RDD sample for estimation (NOT restricted to 20km)
  # This ensures the MSE-optimal bandwidth matches Table 5 Spec 1
  rd_full_data <- voting_sf_clean %>%
    st_drop_geometry() %>%
    filter(!is.na(running_var)) %>%
    select(yes_share, running_var, treated)

  # Run RDD on FULL sample to get MSE-optimal bandwidth (matches Table 5)
  rd_result <- rdrobust(
    y = rd_full_data$yes_share,
    x = rd_full_data$running_var,
    c = 0,
    kernel = "triangular"
  )
  message(paste("MSE-optimal bandwidth:", round(rd_result$bws[1], 2), "km"))
  message(paste("RDD estimate:", round(rd_result$coef[1], 2), "pp (SE =", round(rd_result$se[1], 2), ")"))

  # Create plot data restricted to 20km for visualization only
  rd_plot_data <- rd_full_data %>%
    filter(abs(running_var) <= 20)

  # Bin means for scatter
  bin_width <- 2  # 2km bins
  binned_data <- rd_plot_data %>%
    mutate(bin = cut(running_var, breaks = seq(-20, 20, by = bin_width))) %>%
    group_by(bin, treated) %>%
    summarise(
      mean_yes = mean(yes_share, na.rm = TRUE),
      se_yes = sd(yes_share, na.rm = TRUE) / sqrt(n()),
      n = n(),
      mid = mean(running_var, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    filter(n >= 3)  # Only bins with at least 3 observations

  # Create RDD figure
  fig3 <- ggplot(binned_data, aes(x = mid, y = mean_yes, color = treated)) +
    geom_point(size = 2.5, alpha = 0.8) +
    geom_errorbar(aes(ymin = mean_yes - 1.96*se_yes, ymax = mean_yes + 1.96*se_yes),
                  width = 0.3, alpha = 0.5) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "grey30") +
    geom_smooth(data = rd_plot_data %>% filter(running_var < 0),
                aes(x = running_var, y = yes_share),
                method = "loess", se = TRUE, color = "#B2182B", fill = "#B2182B",
                alpha = 0.2, linewidth = 1) +
    geom_smooth(data = rd_plot_data %>% filter(running_var > 0),
                aes(x = running_var, y = yes_share),
                method = "loess", se = TRUE, color = "#2166AC", fill = "#2166AC",
                alpha = 0.2, linewidth = 1) +
    scale_color_manual(
      values = c("TRUE" = "#2166AC", "FALSE" = "#B2182B"),
      labels = c("TRUE" = "Treated", "FALSE" = "Control"),
      name = ""
    ) +
    labs(
      x = "Distance to Canton Border (km)",
      y = "Yes Share (%)",
      title = "Spatial RDD: Vote Shares at Canton Border",
      subtitle = paste0("RD estimate: ", round(rd_result$coef[1], 2),
                        " pp (SE = ", round(rd_result$se[1], 2),
                        ", p = ", round(rd_result$pv[1], 3), ")"),
      caption = "Dots show bin means (2km width); lines show local polynomial fits"
    ) +
    annotate("text", x = -10, y = max(binned_data$mean_yes) - 2,
             label = "← Control side", color = "#B2182B", size = 3) +
    annotate("text", x = 10, y = max(binned_data$mean_yes) - 2,
             label = "Treated side →", color = "#2166AC", size = 3) +
    theme_apep()

  ggsave(file.path(figures_dir, "fig3_spatial_rdd.pdf"), fig3,
         width = 8, height = 5, device = cairo_pdf)

  message("   Saved fig3_spatial_rdd.pdf")

  # Save RDD results
  rd_results <- tibble(
    Method = "Spatial RDD (border gemeinden)",
    Estimate = rd_result$coef[1],
    SE = rd_result$se[1],
    CI_low = rd_result$ci[1],
    CI_high = rd_result$ci[2],
    Bandwidth_km = rd_result$bws[1],
    N_control = rd_result$N_h[1],
    N_treated = rd_result$N_h[2],
    p_value = rd_result$pv[1]
  )
  write_csv(rd_results, file.path(tab_dir, "table4_spatial_rdd.csv"))
}

# =============================================================================
# Figure 4: Robustness - Bandwidth Sensitivity
# =============================================================================

message("Creating Figure 4: Bandwidth sensitivity...")

if (!st_is_empty(border)) {
  # Test at different bandwidths
  bandwidths <- seq(2, 15, by = 1)

  bw_results <- map_dfr(bandwidths, function(bw) {
    sample <- rd_plot_data %>% filter(abs(running_var) <= bw)
    if (sum(sample$running_var > 0) >= 10 & sum(sample$running_var < 0) >= 10) {
      rd <- rdrobust(y = sample$yes_share, x = sample$running_var, c = 0, h = bw)
      tibble(
        bandwidth = bw,
        estimate = rd$coef[1],
        se = rd$se[1],
        ci_low = rd$ci[1],
        ci_high = rd$ci[2],
        n_total = nrow(sample)
      )
    } else {
      NULL
    }
  })

  fig4 <- ggplot(bw_results, aes(x = bandwidth, y = estimate)) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
    geom_ribbon(aes(ymin = estimate - 1.96*se, ymax = estimate + 1.96*se),
                fill = "#2166AC", alpha = 0.2) +
    geom_line(color = "#2166AC", linewidth = 1) +
    geom_point(color = "#2166AC", size = 2) +
    labs(
      x = "Bandwidth (km)",
      y = "RD Estimate (pp)",
      title = "Bandwidth Sensitivity Analysis",
      subtitle = "Spatial RDD estimates at different distance bandwidths"
    ) +
    theme_apep()

  ggsave(file.path(figures_dir, "fig4_bandwidth_sensitivity.pdf"), fig4,
         width = 7, height = 4.5, device = cairo_pdf)

  message("   Saved fig4_bandwidth_sensitivity.pdf")
}

# =============================================================================
# Figure 5: Language Region Effects
# =============================================================================

message("Creating Figure 5: Language region comparison...")

lang_summary <- voting_data %>%
  group_by(lang, treated) %>%
  summarise(
    mean_yes = mean(yes_share, na.rm = TRUE),
    se_yes = sd(yes_share, na.rm = TRUE) / sqrt(n()),
    n = n(),
    .groups = "drop"
  ) %>%
  mutate(
    treated_label = ifelse(treated, "Treated", "Control")
  )

fig5 <- ggplot(lang_summary, aes(x = lang, y = mean_yes, fill = treated_label)) +
  geom_bar(stat = "identity", position = position_dodge(0.8), width = 0.7) +
  geom_errorbar(aes(ymin = mean_yes - 1.96*se_yes, ymax = mean_yes + 1.96*se_yes),
                position = position_dodge(0.8), width = 0.2) +
  geom_hline(yintercept = 58.2, linetype = "dashed", color = "grey30") +
  annotate("text", x = 0.5, y = 59, label = "National avg", hjust = 0, size = 3, color = "grey30") +
  scale_fill_manual(
    values = c("Treated" = "#2166AC", "Control" = "#B2182B"),
    name = ""
  ) +
  labs(
    x = "Language Region",
    y = "Mean Yes Share (%)",
    title = "Vote Shares by Language Region and Treatment Status",
    subtitle = "Error bars show 95% confidence intervals"
  ) +
  theme_apep()

ggsave(file.path(figures_dir, "fig5_language_comparison.pdf"), fig5,
       width = 7, height = 4.5, device = cairo_pdf)

message("   Saved fig5_language_comparison.pdf")

# =============================================================================
# Figure 6: Border-Pair Specific RDD Plots
# =============================================================================

message("Creating Figure 6: Border-pair specific RDD plots...")

# Load border pair data if it exists
border_file <- file.path(data_dir, "border_pair_data.rds")
if (file.exists(border_file)) {
  border_data <- readRDS(border_file)

  # Get unique border pairs
  if ("border_pair" %in% names(border_data)) {
    border_pairs <- unique(border_data$border_pair)
    border_pairs <- border_pairs[!is.na(border_pairs)]

    # Create individual RDD plots for each border pair
    border_plots <- list()

    for (bp in border_pairs) {
      bp_data <- border_data %>%
        filter(border_pair == bp, !is.na(running_var), !is.na(yes_share))

      if (nrow(bp_data) >= 20) {  # Only if sufficient observations
        # Create bins
        bp_data <- bp_data %>%
          mutate(bin = cut(running_var, breaks = seq(-10, 10, by = 2), include.lowest = TRUE)) %>%
          group_by(bin) %>%
          summarise(
            running_mid = mean(running_var, na.rm = TRUE),
            yes_mean = mean(yes_share, na.rm = TRUE),
            n = n(),
            .groups = "drop"
          )

        p <- ggplot(bp_data, aes(x = running_mid, y = yes_mean)) +
          geom_point(aes(size = n), alpha = 0.7, color = "#2166AC") +
          geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
          geom_smooth(data = bp_data %>% filter(running_mid < 0),
                      method = "lm", se = TRUE, color = "#B2182B", fill = "#B2182B", alpha = 0.2) +
          geom_smooth(data = bp_data %>% filter(running_mid >= 0),
                      method = "lm", se = TRUE, color = "#2166AC", fill = "#2166AC", alpha = 0.2) +
          scale_size_continuous(range = c(2, 6), guide = "none") +
          labs(
            title = paste("Border:", bp),
            x = "Distance to Border (km)",
            y = "Yes Share (%)"
          ) +
          theme_apep() +
          theme(plot.title = element_text(size = 10))

        border_plots[[bp]] <- p
      }
    }

    # Combine into multi-panel figure if we have plots
    if (length(border_plots) >= 2) {
      library(patchwork)

      combined_plot <- wrap_plots(border_plots, ncol = 2) +
        plot_annotation(
          title = "Border-Pair Specific RDD Estimates",
          subtitle = "Each panel shows Gemeinden near a specific treated-control canton border",
          theme = theme(
            plot.title = element_text(face = "bold", size = 14),
            plot.subtitle = element_text(size = 11)
          )
        )

      ggsave(file.path(figures_dir, "fig6_border_pair_rdds.pdf"), combined_plot,
             width = 10, height = 8, device = cairo_pdf)

      message("   Saved fig6_border_pair_rdds.pdf")
    }
  }
} else {
  message("   Border pair data not found, skipping border-pair RDD plots")
}

# =============================================================================
# Summary
# =============================================================================

message("\n=== FIGURES COMPLETE ===")
message(paste("Figures saved to:", figures_dir))
message("Generated:")
message("  - fig1a_treatment_map.pdf")
message("  - fig1b_voteshare_map.pdf")
message("  - fig2_distribution.pdf")
message("  - fig3_spatial_rdd.pdf")
message("  - fig4_bandwidth_sensitivity.pdf")
message("  - fig5_language_comparison.pdf")
