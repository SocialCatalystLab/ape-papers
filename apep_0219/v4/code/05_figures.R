################################################################################
# 05_figures.R — Publication-Quality Figures for ARC RDD
# ARC Distressed County Designation RDD (apep_0217)
#
# Figures:
#   1. Map of Appalachian counties by economic status
#   2. Main RDD plots (3-panel)
#   3. McCrary density test
#   4. Covariate balance plots
#   5. Bandwidth sensitivity
#   6. Year-by-year estimates
#   7. Placebo cutoff RDD plots
################################################################################

source("00_packages.R")

data_dir <- "../data"
fig_dir <- "../figures"
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

################################################################################
# Load data and results
################################################################################

arc <- readRDS(file.path(data_dir, "arc_analysis.rds"))
panel <- readRDS(file.path(data_dir, "arc_panel_full.rds"))
main_results <- readRDS(file.path(data_dir, "main_results.rds"))
rob_results <- readRDS(file.path(data_dir, "robustness_results.rds"))

outcomes <- c("unemp_rate_arc", "log_pcmi", "poverty_rate_arc")
outcome_labels <- c("Unemployment Rate (%)",
                     "Log Per Capita Market Income",
                     "Poverty Rate (%)")
names(outcome_labels) <- outcomes

################################################################################
# 1. Map of Appalachian Counties by Economic Status (FY2014)
################################################################################

cat("--- Figure 1: Map of Appalachian Counties ---\n")

# Get county shapefiles
counties_sf <- tryCatch({
  tigris::counties(cb = TRUE, year = 2014, class = "sf") %>%
    mutate(fips = paste0(STATEFP, COUNTYFP))
}, error = function(e) {
  cat("  Warning: Could not download county shapefiles:", e$message, "\n")
  NULL
})

if (!is.null(counties_sf)) {
  # FY2014 data
  fy2014 <- panel %>%
    filter(fiscal_year == 2014) %>%
    mutate(
      econ_status = case_when(
        distressed == 1 ~ "Distressed",
        at_risk == 1 ~ "At-Risk",
        transitional == 1 ~ "Transitional",
        competitive == 1 ~ "Competitive",
        attainment == 1 ~ "Attainment",
        TRUE ~ "Other"
      ),
      econ_status = factor(econ_status,
                           levels = c("Distressed", "At-Risk", "Transitional",
                                      "Competitive", "Attainment"))
    )

  # Merge with shapefile
  arc_counties <- counties_sf %>%
    inner_join(fy2014 %>% select(fips, econ_status), by = "fips")

  # Appalachian states for background
  arc_state_fips <- unique(fy2014$state_fips)
  states_sf <- tryCatch({
    tigris::states(cb = TRUE, year = 2014, class = "sf") %>%
      filter(STATEFP %in% arc_state_fips)
  }, error = function(e) NULL)

  # Color scheme
  status_colors <- c(
    "Distressed" = "#D55E00",
    "At-Risk" = "#F0E442",
    "Transitional" = "#56B4E9",
    "Competitive" = "#009E73",
    "Attainment" = "#0072B2"
  )

  p_map <- ggplot() +
    {if (!is.null(states_sf))
      geom_sf(data = states_sf, fill = "grey95", color = "grey70", linewidth = 0.3)} +
    geom_sf(data = arc_counties, aes(fill = econ_status),
            color = "grey40", linewidth = 0.1) +
    scale_fill_manual(values = status_colors, name = "Economic Status") +
    coord_sf(xlim = c(-86, -75), ylim = c(33, 43)) +
    labs(
      title = "ARC County Economic Status Designations, FY 2014",
      subtitle = "Appalachian Regional Commission Composite Index Value (CIV) Classification",
      caption = "Source: ARC annual economic status reports"
    ) +
    theme_apep() +
    theme(
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      axis.title = element_blank(),
      axis.line = element_blank(),
      panel.grid = element_blank()
    )

  ggsave(file.path(fig_dir, "fig_map_appalachia.pdf"), p_map,
         width = 8, height = 8, device = cairo_pdf)
  cat("  Saved fig_map_appalachia.pdf\n")
} else {
  cat("  Skipping map (shapefile download failed)\n")
}

################################################################################
# 2. Main RDD Plots (3-panel)
################################################################################

cat("--- Figure 2: Main RDD Plots ---\n")

# Helper function for binned RDD scatter + local polynomial
make_rd_plot <- function(data, yvar, ylabel, nbins = 30) {

  d <- data %>%
    filter(!is.na(.data[[yvar]]) & !is.na(civ_centered))

  # Create bins
  d_left <- d %>% filter(civ_centered < 0)
  d_right <- d %>% filter(civ_centered >= 0)

  bin_left <- d_left %>%
    mutate(bin = cut(civ_centered, breaks = nbins, include.lowest = TRUE)) %>%
    group_by(bin) %>%
    summarize(
      x = mean(civ_centered),
      y = mean(.data[[yvar]], na.rm = TRUE),
      n = n(),
      .groups = "drop"
    )

  bin_right <- d_right %>%
    mutate(bin = cut(civ_centered, breaks = max(5, round(nbins * nrow(d_right) / nrow(d_left))),
                     include.lowest = TRUE)) %>%
    group_by(bin) %>%
    summarize(
      x = mean(civ_centered),
      y = mean(.data[[yvar]], na.rm = TRUE),
      n = n(),
      .groups = "drop"
    )

  bins_all <- bind_rows(bin_left, bin_right) %>%
    mutate(side = ifelse(x < 0, "Below", "Above"))

  # Get main result for annotation
  res <- main_results$pooled[[yvar]]
  ann_text <- sprintf("RD est. = %.3f\n(SE = %.3f)\np = %.3f",
                       res$coef_robust, res$se_robust, res$pv_robust)

  p <- ggplot(bins_all, aes(x = x, y = y)) +
    geom_point(aes(size = n), color = "grey50", alpha = 0.7) +
    geom_smooth(data = d %>% filter(civ_centered < 0),
                aes(x = civ_centered, y = .data[[yvar]]),
                method = "loess", span = 0.75, se = TRUE,
                color = apep_colors[1], fill = apep_colors[1], alpha = 0.15,
                linewidth = 1) +
    geom_smooth(data = d %>% filter(civ_centered >= 0),
                aes(x = civ_centered, y = .data[[yvar]]),
                method = "loess", span = 0.75, se = TRUE,
                color = apep_colors[2], fill = apep_colors[2], alpha = 0.15,
                linewidth = 1) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "grey30", linewidth = 0.5) +
    annotate("text", x = max(bins_all$x) * 0.55, y = max(bins_all$y) * 0.98,
             label = ann_text, hjust = 0, vjust = 1, size = 3, color = "grey30") +
    scale_size_continuous(range = c(1, 4), guide = "none") +
    labs(
      x = "CIV (centered at threshold)",
      y = ylabel,
      title = ylabel
    ) +
    theme_apep()

  return(p)
}

p1 <- make_rd_plot(arc, "unemp_rate_arc", "Unemployment Rate (%)")
p2 <- make_rd_plot(arc, "log_pcmi", "Log Per Capita Market Income")
p3 <- make_rd_plot(arc, "poverty_rate_arc", "Poverty Rate (%)")

p_main <- p1 / p2 / p3 +
  plot_annotation(
    title = "Regression Discontinuity: Effect of ARC Distressed Designation",
    subtitle = "Binned scatter with local polynomial fits (triangular kernel, MSE-optimal bandwidth)",
    caption = "Notes: Bins represent averages within equi-spaced intervals. Shaded areas show 95% CI.",
    theme = theme_apep()
  )

ggsave(file.path(fig_dir, "fig_rd_plot_main.pdf"), p_main,
       width = 8, height = 12, device = cairo_pdf)
cat("  Saved fig_rd_plot_main.pdf\n")

################################################################################
# 3. McCrary Density Test
################################################################################

cat("--- Figure 3: McCrary Density Test ---\n")

density_fit <- rob_results$density$fit

# Use rddensity's built-in plot data
rdp <- rdplotdensity(density_fit, X = arc$civ_centered, plotGrid = "es")

# Extract the plot object and customize
p_density <- rdp$Estplot +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey30", linewidth = 0.5) +
  labs(
    title = "McCrary Density Test at ARC Distressed Threshold",
    subtitle = sprintf("T-statistic = %.3f, p-value = %.4f",
                       rob_results$density$t_stat, rob_results$density$p_value),
    x = "CIV (centered at threshold)",
    y = "Density",
    caption = "Notes: Density estimated separately on each side of the cutoff using rddensity."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig_density_test.pdf"), p_density,
       width = 8, height = 5, device = cairo_pdf)
cat("  Saved fig_density_test.pdf\n")

################################################################################
# 4. Covariate Balance Plots
################################################################################

cat("--- Figure 4: Covariate Balance ---\n")

# Build balance data with lags
balance_data <- panel %>%
  arrange(fips, fiscal_year) %>%
  group_by(fips) %>%
  mutate(
    lag_unemp = dplyr::lag(unemp_rate_arc, 1),
    lag_pcmi = dplyr::lag(pcmi, 1),
    lag_poverty = dplyr::lag(poverty_rate_arc, 1)
  ) %>%
  ungroup() %>%
  filter(abs(civ_centered) <= 50)

balance_vars <- c("lag_unemp", "lag_pcmi", "lag_poverty")
balance_labels_fig <- c("Balance: Lagged Unemployment Rate (%)",
                         "Balance: Lagged Per Capita Market Income ($)",
                         "Balance: Lagged Poverty Rate (%)")

p_balance_list <- list()

for (i in seq_along(balance_vars)) {
  bvar <- balance_vars[i]
  d <- balance_data %>% filter(!is.na(.data[[bvar]]) & !is.na(civ_centered))

  if (nrow(d) < 50) next

  # Get result
  bres <- rob_results$balance[[bvar]]
  ann_txt <- if (!is.null(bres)) {
    sprintf("RD est. = %.3f\np = %.3f", bres$coef_robust, bres$pv_robust)
  } else {
    ""
  }

  # Binned scatter
  d_bins <- d %>%
    mutate(
      bin = cut(civ_centered, breaks = 30, include.lowest = TRUE),
      side = ifelse(civ_centered < 0, "Below", "Above")
    ) %>%
    group_by(bin, side) %>%
    summarize(x = mean(civ_centered), y = mean(.data[[bvar]], na.rm = TRUE),
              n = n(), .groups = "drop")

  p <- ggplot(d_bins, aes(x = x, y = y)) +
    geom_point(aes(size = n), color = "grey50", alpha = 0.7) +
    geom_smooth(data = d %>% filter(civ_centered < 0),
                aes(x = civ_centered, y = .data[[bvar]]),
                method = "loess", span = 0.75, se = TRUE,
                color = apep_colors[1], fill = apep_colors[1], alpha = 0.15) +
    geom_smooth(data = d %>% filter(civ_centered >= 0),
                aes(x = civ_centered, y = .data[[bvar]]),
                method = "loess", span = 0.75, se = TRUE,
                color = apep_colors[2], fill = apep_colors[2], alpha = 0.15) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "grey30") +
    annotate("text", x = Inf, y = Inf, label = ann_txt,
             hjust = 1.1, vjust = 1.3, size = 3, color = "grey30") +
    scale_size_continuous(range = c(1, 3.5), guide = "none") +
    labs(x = "CIV (centered at threshold)", y = balance_labels_fig[i],
         title = balance_labels_fig[i]) +
    theme_apep()

  p_balance_list[[i]] <- p
}

if (length(p_balance_list) >= 3) {
  p_balance <- p_balance_list[[1]] / p_balance_list[[2]] / p_balance_list[[3]] +
    plot_annotation(
      title = "Covariate Balance: Lagged Outcomes at the ARC Distressed Threshold",
      subtitle = "Tests for discontinuity in predetermined characteristics",
      caption = "Notes: Lagged outcomes (t-1) tested for discontinuity at current-year threshold.",
      theme = theme_apep()
    )

  ggsave(file.path(fig_dir, "fig_covariate_balance.pdf"), p_balance,
         width = 8, height = 12, device = cairo_pdf)
  cat("  Saved fig_covariate_balance.pdf\n")
} else {
  cat("  Warning: fewer than 3 balance variables available\n")
}

################################################################################
# 5. Bandwidth Sensitivity
################################################################################

cat("--- Figure 5: Bandwidth Sensitivity ---\n")

bw_df <- bind_rows(lapply(rob_results$bandwidth, as.data.frame)) %>%
  mutate(label = outcome_labels[outcome])

p_bw <- ggplot(bw_df, aes(x = factor(multiplier), y = coef_robust)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
  geom_pointrange(aes(ymin = ci_lower, ymax = ci_upper, color = label),
                  position = position_dodge(width = 0.5), size = 0.5) +
  facet_wrap(~ label, scales = "free_y", ncol = 1) +
  scale_color_manual(values = apep_colors[1:3], guide = "none") +
  scale_x_discrete(labels = c("50%", "75%", "100%\n(optimal)", "125%", "150%")) +
  labs(
    x = "Bandwidth (% of MSE-optimal)",
    y = "RD Estimate (robust bias-corrected)",
    title = "Bandwidth Sensitivity of RD Estimates",
    subtitle = "MSE-optimal bandwidth with 0.5x to 1.5x multipliers",
    caption = "Notes: Points show robust bias-corrected estimates; whiskers show 95% robust CI."
  ) +
  theme_apep() +
  theme(strip.text = element_text(face = "bold", size = 10))

ggsave(file.path(fig_dir, "fig_bandwidth_sensitivity.pdf"), p_bw,
       width = 8, height = 10, device = cairo_pdf)
cat("  Saved fig_bandwidth_sensitivity.pdf\n")

################################################################################
# 6. Year-by-Year Estimates
################################################################################

cat("--- Figure 6: Year-by-Year Estimates ---\n")

yearly_df <- bind_rows(lapply(rob_results$yearly, as.data.frame)) %>%
  mutate(label = outcome_labels[outcome])

p_yearly <- ggplot(yearly_df, aes(x = year, y = coef_robust)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
  geom_pointrange(aes(ymin = ci_lower, ymax = ci_upper, color = label),
                  size = 0.4) +
  geom_line(aes(color = label), alpha = 0.3) +
  facet_wrap(~ label, scales = "free_y", ncol = 1) +
  scale_color_manual(values = apep_colors[1:3], guide = "none") +
  scale_x_continuous(breaks = seq(2007, 2017, by = 2)) +
  labs(
    x = "Fiscal Year",
    y = "RD Estimate (robust bias-corrected)",
    title = "Year-by-Year RD Estimates",
    subtitle = "Separate rdrobust estimation for each fiscal year",
    caption = "Notes: Triangular kernel, MSE-optimal bandwidth selected per year. Whiskers show 95% CI."
  ) +
  theme_apep() +
  theme(strip.text = element_text(face = "bold", size = 10))

ggsave(file.path(fig_dir, "fig_yearly_estimates.pdf"), p_yearly,
       width = 8, height = 10, device = cairo_pdf)
cat("  Saved fig_yearly_estimates.pdf\n")

################################################################################
# 7. Placebo Cutoff RDD Plots
################################################################################

cat("--- Figure 7: Placebo RDD Plots ---\n")

placebo_df <- bind_rows(lapply(rob_results$placebo, as.data.frame)) %>%
  mutate(label = outcome_labels[outcome])

# Create placebo coefficient plot
p_placebo <- ggplot(placebo_df, aes(x = cutoff_name, y = coef_robust, color = label)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey60") +
  geom_pointrange(aes(ymin = ci_lower, ymax = ci_upper),
                  position = position_dodge(width = 0.4), size = 0.5) +
  facet_wrap(~ label, scales = "free_y", ncol = 1) +
  scale_color_manual(values = apep_colors[1:3], guide = "none") +
  labs(
    x = "Placebo Cutoff Location",
    y = "RD Estimate (robust bias-corrected)",
    title = "Placebo Cutoff Tests",
    subtitle = "RD estimates at fake thresholds (25th percentile and median of CIV)",
    caption = "Notes: No significant effects expected at placebo cutoffs. Whiskers show 95% CI."
  ) +
  theme_apep() +
  theme(strip.text = element_text(face = "bold", size = 10))

ggsave(file.path(fig_dir, "fig_placebo.pdf"), p_placebo,
       width = 8, height = 10, device = cairo_pdf)
cat("  Saved fig_placebo.pdf\n")

cat("\n=== All Figures Complete ===\n")
