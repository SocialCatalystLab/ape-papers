# =============================================================================
# 12_corrected_rdd_figures.R - RDD Figures Using CORRECTED Sample
#
# This script generates RDD figures using the corrected sample construction:
#   - Distance measured to each Gemeinde's OWN canton's treated-control border
#   - Basel-Stadt excluded (no treated-control border)
#   - Only cantons with actual treated-control borders included
#
# These figures replace the "illustrative" pre-correction figures.
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

# APEP theme
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

dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

cat("\n", rep("=", 70), "\n")
cat("GENERATING CORRECTED RDD FIGURES\n")
cat(rep("=", 70), "\n\n")

# =============================================================================
# LOAD CORRECTED DATA
# =============================================================================

cat("Loading corrected RDD sample...\n")

# Check for corrected data files
rdd_file <- file.path(data_dir, "rdd_sample_corrected.rds")
if (!file.exists(rdd_file)) {
  cat("Corrected RDD sample not found. Running 09_fix_rdd_sample.R first...\n")
  source(file.path(script_dir, "09_fix_rdd_sample.R"))
}

rdd_corrected <- readRDS(rdd_file)
results_corrected <- readRDS(file.path(data_dir, "rdd_results_corrected.rds"))

cat(paste("Loaded corrected sample:", nrow(rdd_corrected), "Gemeinden\n"))
cat(paste("Pooled estimate:", round(results_corrected$pooled$estimate, 2), "pp\n"))
cat(paste("Same-language estimate:", round(results_corrected$same_language$estimate, 2), "pp\n"))

# =============================================================================
# FIGURE: MAIN CORRECTED RDD PLOT (Pooled)
# =============================================================================

cat("\nCreating main corrected RDD figure (pooled)...\n")

# Restrict to visualization bandwidth (20km)
viz_bandwidth <- 20
plot_data <- rdd_corrected %>%
  filter(abs(signed_distance_km) <= viz_bandwidth)

cat(paste("Visualization sample:", nrow(plot_data), "Gemeinden within", viz_bandwidth, "km\n"))

# Create bins for scatter
bin_width <- 2  # km
binned_data <- plot_data %>%
  mutate(bin = cut(signed_distance_km,
                   breaks = seq(-viz_bandwidth, viz_bandwidth, by = bin_width),
                   include.lowest = TRUE)) %>%
  group_by(bin, treated) %>%
  summarise(
    mean_yes = mean(yes_share, na.rm = TRUE),
    se_yes = sd(yes_share, na.rm = TRUE) / sqrt(n()),
    n = n(),
    mid = mean(signed_distance_km, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(n >= 3)  # Only bins with at least 3 observations

# Get results for annotation
pooled_est <- round(results_corrected$pooled$estimate, 2)
pooled_se <- round(results_corrected$pooled$se, 2)
pooled_p <- round(results_corrected$pooled$pvalue, 3)
pooled_bw <- round(results_corrected$pooled$bandwidth, 1)
pooled_n <- results_corrected$pooled$n

# Create the main RDD figure
fig_rdd_corrected <- ggplot(binned_data, aes(x = mid, y = mean_yes, color = treated)) +
  geom_point(size = 2.5, alpha = 0.8) +
  geom_errorbar(aes(ymin = mean_yes - 1.96*se_yes, ymax = mean_yes + 1.96*se_yes),
                width = 0.3, alpha = 0.5) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey30", linewidth = 0.8) +
  # Local polynomial fits
  geom_smooth(data = plot_data %>% filter(signed_distance_km < 0),
              aes(x = signed_distance_km, y = yes_share),
              method = "loess", se = TRUE, color = "#B2182B", fill = "#B2182B",
              alpha = 0.2, linewidth = 1) +
  geom_smooth(data = plot_data %>% filter(signed_distance_km > 0),
              aes(x = signed_distance_km, y = yes_share),
              method = "loess", se = TRUE, color = "#2166AC", fill = "#2166AC",
              alpha = 0.2, linewidth = 1) +
  scale_color_manual(
    values = c("TRUE" = "#2166AC", "FALSE" = "#B2182B"),
    labels = c("TRUE" = "Treated (energy law)", "FALSE" = "Control"),
    name = ""
  ) +
  labs(
    x = "Distance to Own Canton Border (km)",
    y = "Yes Share (%)",
    title = "Spatial RDD: Energy Strategy 2050 Vote Shares at Canton Border",
    subtitle = paste0("RD estimate: ", pooled_est, " pp (SE = ", pooled_se, ", p = ", pooled_p,
                      ") | Bandwidth: ", pooled_bw, " km | N = ", pooled_n),
    caption = paste0("Dots show bin means (", bin_width, " km bins); lines show local polynomial fits.\n",
                     "Negative distances = control side; positive = treated side. ",
                     "Corrected sample: distance to own canton border.")
  ) +
  annotate("text", x = -12, y = max(binned_data$mean_yes, na.rm = TRUE) - 2,
           label = "Control side", color = "#B2182B", size = 3.5, fontface = "bold") +
  annotate("text", x = 12, y = max(binned_data$mean_yes, na.rm = TRUE) - 2,
           label = "Treated side", color = "#2166AC", size = 3.5, fontface = "bold") +
  theme_apep() +
  theme(
    plot.subtitle = element_text(size = 9),
    plot.caption = element_text(size = 7, hjust = 0)
  )

ggsave(file.path(fig_dir, "fig_rdd_corrected_pooled.pdf"), fig_rdd_corrected,
       width = 9, height = 6, device = cairo_pdf)

cat("   Saved fig_rdd_corrected_pooled.pdf\n")

# =============================================================================
# FIGURE: SAME-LANGUAGE RDD PLOT (Primary Specification)
# =============================================================================

cat("\nCreating same-language corrected RDD figure (primary specification)...\n")

# Load border pairs to identify same-language
border_pairs <- readRDS(file.path(data_dir, "border_pairs_verified.rds"))

# German cantons
german_cantons <- c("ZH", "BE", "LU", "UR", "SZ", "OW", "NW", "GL", "ZG",
                    "SO", "BS", "BL", "SH", "AR", "AI", "SG", "GR", "AG", "TG")

same_lang_pairs <- border_pairs %>%
  filter(
    canton_treated %in% german_cantons,
    canton_control %in% german_cantons
  ) %>%
  pull(border_pair)

# Filter to same-language sample
same_lang_data <- rdd_corrected %>%
  filter(nearest_border_pair %in% same_lang_pairs) %>%
  filter(abs(signed_distance_km) <= viz_bandwidth)

cat(paste("Same-language sample:", nrow(same_lang_data), "Gemeinden\n"))

# Create bins
binned_same_lang <- same_lang_data %>%
  mutate(bin = cut(signed_distance_km,
                   breaks = seq(-viz_bandwidth, viz_bandwidth, by = bin_width),
                   include.lowest = TRUE)) %>%
  group_by(bin, treated) %>%
  summarise(
    mean_yes = mean(yes_share, na.rm = TRUE),
    se_yes = sd(yes_share, na.rm = TRUE) / sqrt(n()),
    n = n(),
    mid = mean(signed_distance_km, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(n >= 3)

# Get same-language results
same_lang_est <- round(results_corrected$same_language$estimate, 2)
same_lang_se <- round(results_corrected$same_language$se, 2)
same_lang_p <- round(results_corrected$same_language$pvalue, 3)
same_lang_bw <- round(results_corrected$same_language$bandwidth, 1)
same_lang_n <- results_corrected$same_language$n

fig_rdd_same_lang <- ggplot(binned_same_lang, aes(x = mid, y = mean_yes, color = treated)) +
  geom_point(size = 2.5, alpha = 0.8) +
  geom_errorbar(aes(ymin = mean_yes - 1.96*se_yes, ymax = mean_yes + 1.96*se_yes),
                width = 0.3, alpha = 0.5) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey30", linewidth = 0.8) +
  geom_smooth(data = same_lang_data %>% filter(signed_distance_km < 0),
              aes(x = signed_distance_km, y = yes_share),
              method = "loess", se = TRUE, color = "#B2182B", fill = "#B2182B",
              alpha = 0.2, linewidth = 1) +
  geom_smooth(data = same_lang_data %>% filter(signed_distance_km > 0),
              aes(x = signed_distance_km, y = yes_share),
              method = "loess", se = TRUE, color = "#2166AC", fill = "#2166AC",
              alpha = 0.2, linewidth = 1) +
  scale_color_manual(
    values = c("TRUE" = "#2166AC", "FALSE" = "#B2182B"),
    labels = c("TRUE" = "Treated (energy law)", "FALSE" = "Control"),
    name = ""
  ) +
  labs(
    x = "Distance to Own Canton Border (km)",
    y = "Yes Share (%)",
    title = "Spatial RDD: Same-Language Borders Only (German-German)",
    subtitle = paste0("PRIMARY SPECIFICATION | RD estimate: ", same_lang_est, " pp (SE = ", same_lang_se,
                      ", p = ", same_lang_p, ") | Bandwidth: ", same_lang_bw, " km | N = ", same_lang_n),
    caption = "Same-language borders eliminate Röstigraben confounding. Distance to own canton border."
  ) +
  annotate("text", x = -10, y = max(binned_same_lang$mean_yes, na.rm = TRUE) - 1.5,
           label = "Control side", color = "#B2182B", size = 3.5, fontface = "bold") +
  annotate("text", x = 10, y = max(binned_same_lang$mean_yes, na.rm = TRUE) - 1.5,
           label = "Treated side", color = "#2166AC", size = 3.5, fontface = "bold") +
  theme_apep() +
  theme(
    plot.subtitle = element_text(size = 9, face = "bold"),
    plot.caption = element_text(size = 7, hjust = 0)
  )

ggsave(file.path(fig_dir, "fig_rdd_corrected_same_lang.pdf"), fig_rdd_same_lang,
       width = 9, height = 6, device = cairo_pdf)

cat("   Saved fig_rdd_corrected_same_lang.pdf\n")

# =============================================================================
# FIGURE: BANDWIDTH SENSITIVITY (Corrected Sample)
# =============================================================================

cat("\nCreating bandwidth sensitivity figure (corrected sample)...\n")

# Test across bandwidths
bandwidths <- seq(2, 15, by = 0.5)

bw_results <- map_dfr(bandwidths, function(bw) {
  sample_bw <- rdd_corrected %>%
    filter(abs(signed_distance_km) <= bw)

  n_left <- sum(sample_bw$signed_distance_km < 0)
  n_right <- sum(sample_bw$signed_distance_km > 0)

  if (n_left >= 20 & n_right >= 20) {
    rd <- tryCatch({
      rdrobust(y = sample_bw$yes_share, x = sample_bw$signed_distance_km, c = 0, h = bw)
    }, error = function(e) NULL)

    if (!is.null(rd)) {
      return(tibble(
        bandwidth = bw,
        estimate = rd$coef[1],
        se = rd$se[1],
        ci_low = rd$ci[1, 1],
        ci_high = rd$ci[1, 2],
        n = n_left + n_right
      ))
    }
  }
  return(NULL)
})

# Mark optimal bandwidth
opt_bw <- results_corrected$pooled$bandwidth

fig_bw_sensitivity <- ggplot(bw_results, aes(x = bandwidth, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_ribbon(aes(ymin = ci_low, ymax = ci_high), fill = "#2166AC", alpha = 0.2) +
  geom_line(color = "#2166AC", linewidth = 1) +
  geom_point(color = "#2166AC", size = 2) +
  geom_vline(xintercept = opt_bw, linetype = "dotted", color = "#D7191C", linewidth = 0.8) +
  annotate("text", x = opt_bw + 0.3, y = max(bw_results$estimate, na.rm = TRUE),
           label = paste0("MSE-optimal\n(", round(opt_bw, 1), " km)"),
           hjust = 0, size = 3, color = "#D7191C") +
  labs(
    x = "Bandwidth (km)",
    y = "RD Estimate (pp)",
    title = "Bandwidth Sensitivity Analysis (Corrected Sample)",
    subtitle = "Estimates remain negative across bandwidth range",
    caption = "Shaded area shows 95% confidence intervals. Corrected sample construction."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig_bandwidth_corrected.pdf"), fig_bw_sensitivity,
       width = 8, height = 5, device = cairo_pdf)

cat("   Saved fig_bandwidth_corrected.pdf\n")

cat("\n=== CORRECTED RDD FIGURES COMPLETE ===\n")
