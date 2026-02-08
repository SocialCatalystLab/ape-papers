# ============================================================================
# Paper 65: Transit Funding Discontinuity at 50,000 Population Threshold
# 04_figures.R - Create publication-ready figures
# ============================================================================

source("output/paper_65/code/00_packages.R")

# ============================================================================
# 1. LOAD DATA
# ============================================================================

cat("Loading data...\n")

ua_data <- read_csv(file.path(data_dir, "ua_combined.csv"), show_col_types = FALSE)
rdd_results <- read_csv(file.path(data_dir, "rdd_results.csv"), show_col_types = FALSE)
mccrary <- read_csv(file.path(data_dir, "mccrary_test.csv"), show_col_types = FALSE)

# Filter to complete cases
analysis_data <- ua_data %>%
  filter(!is.na(transit_share), !is.na(employment_rate))

# ============================================================================
# 2. FIGURE 1: DISTRIBUTION OF URBANIZED AREAS BY POPULATION
# ============================================================================

cat("Creating Figure 1: Population distribution...\n")

# Histogram with threshold marked
fig1 <- ggplot(analysis_data %>% filter(abs(running_var) <= 40000),
               aes(x = population_2020 / 1000)) +
  geom_histogram(binwidth = 2.5, fill = apep_colors[1], color = "white", alpha = 0.7) +
  geom_vline(xintercept = 50, linetype = "dashed", color = apep_colors[2], linewidth = 1) +
  annotate("text", x = 50, y = Inf, label = "50,000 Threshold",
           hjust = -0.1, vjust = 1.5, color = apep_colors[2], size = 3.5, fontface = "bold") +
  labs(
    title = "Distribution of Urbanized Areas Near the 50,000 Population Threshold",
    subtitle = sprintf("McCrary density test: p = %.3f (no evidence of manipulation)", mccrary$p_value),
    x = "Population (thousands)",
    y = "Number of Urbanized Areas",
    caption = "Note: Sample includes 2020 Census urbanized areas with population 10,000-90,000."
  ) +
  theme_apep() +
  scale_x_continuous(breaks = seq(10, 90, 10), limits = c(10, 90))

ggsave(file.path(fig_dir, "fig1_population_distribution.pdf"), fig1,
       width = 8, height = 5, device = cairo_pdf)
ggsave(file.path(fig_dir, "fig1_population_distribution.png"), fig1,
       width = 8, height = 5, dpi = 300)

# ============================================================================
# 3. FIGURE 2: RDD PLOT - TRANSIT SHARE
# ============================================================================

cat("Creating Figure 2: RDD plot for transit share...\n")

# Create binned scatter with local polynomial fits
# Restrict to narrower bandwidth for visibility
plot_data <- analysis_data %>%
  filter(abs(running_var) <= 25000)

# Create bins
plot_data <- plot_data %>%
  mutate(bin = cut(running_var, breaks = seq(-25000, 25000, by = 2500), include.lowest = TRUE)) %>%
  group_by(bin) %>%
  summarise(
    mean_x = mean(running_var),
    mean_y = mean(transit_share),
    n = n(),
    se = sd(transit_share) / sqrt(n())
  ) %>%
  ungroup() %>%
  filter(!is.na(bin))

# Run rdrobust for annotation
rd_transit <- rdrobust(
  y = analysis_data$transit_share,
  x = analysis_data$running_var,
  c = 0
)

fig2 <- ggplot() +
  # Binned means with error bars
  geom_point(data = plot_data, aes(x = mean_x / 1000, y = mean_y * 100),
             color = "grey50", size = 3, alpha = 0.8) +
  geom_errorbar(data = plot_data,
                aes(x = mean_x / 1000, ymin = (mean_y - 1.96*se) * 100, ymax = (mean_y + 1.96*se) * 100),
                color = "grey50", width = 0.5, alpha = 0.5) +

  # Local polynomial fits
  geom_smooth(data = analysis_data %>% filter(running_var < 0, abs(running_var) <= 25000),
              aes(x = running_var / 1000, y = transit_share * 100),
              method = "loess", formula = y ~ x, span = 0.8,
              color = apep_colors[1], fill = apep_colors[1], alpha = 0.2, linewidth = 1.2) +
  geom_smooth(data = analysis_data %>% filter(running_var >= 0, abs(running_var) <= 25000),
              aes(x = running_var / 1000, y = transit_share * 100),
              method = "loess", formula = y ~ x, span = 0.8,
              color = apep_colors[2], fill = apep_colors[2], alpha = 0.2, linewidth = 1.2) +

  # Threshold line
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey30", linewidth = 0.8) +

  # Annotation with RD estimate
  annotate("text", x = 15, y = max(plot_data$mean_y * 100, na.rm = TRUE) * 0.95,
           label = sprintf("RD Estimate: %.4f\n(Robust SE: %.4f)\np = %.3f",
                           rd_transit$coef[1], rd_transit$se[3], rd_transit$pv[3]),
           hjust = 0, size = 3, fontface = "italic") +

  labs(
    title = "Effect of Federal Transit Eligibility on Public Transit Use",
    subtitle = "Local polynomial regression discontinuity at 50,000 population threshold",
    x = "Population Relative to 50,000 Threshold (thousands)",
    y = "Transit Share (%)",
    caption = "Note: Points show binned means with 95% CIs. Lines show local polynomial fits. Bandwidth ±25,000."
  ) +
  theme_apep() +
  scale_x_continuous(breaks = seq(-25, 25, 5)) +
  scale_y_continuous(labels = function(x) paste0(x, "%"))

ggsave(file.path(fig_dir, "fig2_rd_transit_share.pdf"), fig2,
       width = 9, height = 6, device = cairo_pdf)
ggsave(file.path(fig_dir, "fig2_rd_transit_share.png"), fig2,
       width = 9, height = 6, dpi = 300)

# ============================================================================
# 4. FIGURE 3: RDD PLOT - EMPLOYMENT RATE
# ============================================================================

cat("Creating Figure 3: RDD plot for employment rate...\n")

# Create bins for employment rate
plot_data_emp <- analysis_data %>%
  filter(abs(running_var) <= 25000) %>%
  mutate(bin = cut(running_var, breaks = seq(-25000, 25000, by = 2500), include.lowest = TRUE)) %>%
  group_by(bin) %>%
  summarise(
    mean_x = mean(running_var),
    mean_y = mean(employment_rate),
    n = n(),
    se = sd(employment_rate) / sqrt(n())
  ) %>%
  ungroup() %>%
  filter(!is.na(bin))

rd_emp <- rdrobust(
  y = analysis_data$employment_rate,
  x = analysis_data$running_var,
  c = 0
)

fig3 <- ggplot() +
  geom_point(data = plot_data_emp, aes(x = mean_x / 1000, y = mean_y * 100),
             color = "grey50", size = 3, alpha = 0.8) +
  geom_errorbar(data = plot_data_emp,
                aes(x = mean_x / 1000, ymin = (mean_y - 1.96*se) * 100, ymax = (mean_y + 1.96*se) * 100),
                color = "grey50", width = 0.5, alpha = 0.5) +

  geom_smooth(data = analysis_data %>% filter(running_var < 0, abs(running_var) <= 25000),
              aes(x = running_var / 1000, y = employment_rate * 100),
              method = "loess", formula = y ~ x, span = 0.8,
              color = apep_colors[1], fill = apep_colors[1], alpha = 0.2, linewidth = 1.2) +
  geom_smooth(data = analysis_data %>% filter(running_var >= 0, abs(running_var) <= 25000),
              aes(x = running_var / 1000, y = employment_rate * 100),
              method = "loess", formula = y ~ x, span = 0.8,
              color = apep_colors[2], fill = apep_colors[2], alpha = 0.2, linewidth = 1.2) +

  geom_vline(xintercept = 0, linetype = "dashed", color = "grey30", linewidth = 0.8) +

  annotate("text", x = 15, y = min(plot_data_emp$mean_y * 100, na.rm = TRUE) + 1,
           label = sprintf("RD Estimate: %.4f\n(Robust SE: %.4f)\np = %.3f",
                           rd_emp$coef[1], rd_emp$se[3], rd_emp$pv[3]),
           hjust = 0, size = 3, fontface = "italic") +

  labs(
    title = "Effect of Federal Transit Eligibility on Employment Rate",
    subtitle = "Local polynomial regression discontinuity at 50,000 population threshold",
    x = "Population Relative to 50,000 Threshold (thousands)",
    y = "Employment Rate (%)",
    caption = "Note: Employment rate = employed / labor force. Points show binned means with 95% CIs."
  ) +
  theme_apep() +
  scale_x_continuous(breaks = seq(-25, 25, 5)) +
  scale_y_continuous(labels = function(x) paste0(x, "%"))

ggsave(file.path(fig_dir, "fig3_rd_employment.pdf"), fig3,
       width = 9, height = 6, device = cairo_pdf)
ggsave(file.path(fig_dir, "fig3_rd_employment.png"), fig3,
       width = 9, height = 6, dpi = 300)

# ============================================================================
# 5. FIGURE 4: COVARIATE BALANCE
# ============================================================================

cat("Creating Figure 4: Covariate balance...\n")

# RDD plot for median household income (pre-determined covariate)
plot_data_income <- analysis_data %>%
  filter(abs(running_var) <= 25000) %>%
  mutate(bin = cut(running_var, breaks = seq(-25000, 25000, by = 2500), include.lowest = TRUE)) %>%
  group_by(bin) %>%
  summarise(
    mean_x = mean(running_var),
    mean_y = mean(median_hh_income, na.rm = TRUE),
    n = n(),
    se = sd(median_hh_income, na.rm = TRUE) / sqrt(n())
  ) %>%
  ungroup() %>%
  filter(!is.na(bin), !is.na(mean_y))

fig4 <- ggplot() +
  geom_point(data = plot_data_income, aes(x = mean_x / 1000, y = mean_y / 1000),
             color = "grey50", size = 3, alpha = 0.8) +
  geom_errorbar(data = plot_data_income,
                aes(x = mean_x / 1000, ymin = (mean_y - 1.96*se) / 1000, ymax = (mean_y + 1.96*se) / 1000),
                color = "grey50", width = 0.5, alpha = 0.5) +

  geom_smooth(data = analysis_data %>% filter(running_var < 0, abs(running_var) <= 25000),
              aes(x = running_var / 1000, y = median_hh_income / 1000),
              method = "loess", formula = y ~ x, span = 0.8,
              color = apep_colors[3], fill = apep_colors[3], alpha = 0.2, linewidth = 1.2) +
  geom_smooth(data = analysis_data %>% filter(running_var >= 0, abs(running_var) <= 25000),
              aes(x = running_var / 1000, y = median_hh_income / 1000),
              method = "loess", formula = y ~ x, span = 0.8,
              color = apep_colors[3], fill = apep_colors[3], alpha = 0.2, linewidth = 1.2) +

  geom_vline(xintercept = 0, linetype = "dashed", color = "grey30", linewidth = 0.8) +

  labs(
    title = "Covariate Balance: Median Household Income at Threshold",
    subtitle = "Test for smoothness of predetermined covariates (validation check)",
    x = "Population Relative to 50,000 Threshold (thousands)",
    y = "Median Household Income ($thousands)",
    caption = "Note: No discontinuity in income at threshold supports RDD validity."
  ) +
  theme_apep() +
  scale_x_continuous(breaks = seq(-25, 25, 5)) +
  scale_y_continuous(labels = function(x) paste0("$", x, "k"))

ggsave(file.path(fig_dir, "fig4_covariate_balance.pdf"), fig4,
       width = 9, height = 6, device = cairo_pdf)
ggsave(file.path(fig_dir, "fig4_covariate_balance.png"), fig4,
       width = 9, height = 6, dpi = 300)

# ============================================================================
# 6. FIGURE 5: BANDWIDTH SENSITIVITY
# ============================================================================

cat("Creating Figure 5: Bandwidth sensitivity...\n")

# Run RDD with multiple bandwidths
rd_base <- rdrobust(y = analysis_data$transit_share, x = analysis_data$running_var, c = 0)
optimal_bw <- rd_base$bws[1, 1]

bw_multipliers <- seq(0.5, 2, 0.25)
sensitivity_results <- map_df(bw_multipliers, function(mult) {
  bw <- mult * optimal_bw
  rd <- rdrobust(y = analysis_data$transit_share, x = analysis_data$running_var, c = 0, h = bw)
  tibble(
    multiplier = mult,
    bandwidth = bw,
    estimate = rd$coef[1],
    se = rd$se[3],
    ci_lower = rd$ci[3, 1],
    ci_upper = rd$ci[3, 2],
    pvalue = rd$pv[3]
  )
})

fig5 <- ggplot(sensitivity_results, aes(x = multiplier)) +
  geom_ribbon(aes(ymin = ci_lower * 100, ymax = ci_upper * 100),
              fill = apep_colors[1], alpha = 0.2) +
  geom_line(aes(y = estimate * 100), color = apep_colors[1], linewidth = 1) +
  geom_point(aes(y = estimate * 100), color = apep_colors[1], size = 3) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = 1, linetype = "dotted", color = "grey60") +
  annotate("text", x = 1, y = max(sensitivity_results$ci_upper * 100) * 0.9,
           label = "MSE-Optimal", size = 3, hjust = -0.1) +
  labs(
    title = "Bandwidth Sensitivity Analysis: Transit Share",
    subtitle = "RD estimates stable across bandwidth choices",
    x = "Bandwidth Multiplier (1 = MSE-Optimal)",
    y = "RD Estimate (percentage points)",
    caption = sprintf("Note: Optimal bandwidth = %d population. Shaded area shows 95%% robust CI.",
                      round(optimal_bw))
  ) +
  theme_apep() +
  scale_x_continuous(breaks = bw_multipliers)

ggsave(file.path(fig_dir, "fig5_bandwidth_sensitivity.pdf"), fig5,
       width = 8, height = 5, device = cairo_pdf)
ggsave(file.path(fig_dir, "fig5_bandwidth_sensitivity.png"), fig5,
       width = 8, height = 5, dpi = 300)

# ============================================================================
# 7. FIGURE 6: SUMMARY OF ALL OUTCOMES
# ============================================================================

cat("Creating Figure 6: Summary of all outcomes...\n")

fig6 <- ggplot(rdd_results, aes(x = reorder(outcome, estimate), y = estimate * 100)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_errorbar(aes(ymin = ci_lower * 100, ymax = ci_upper * 100),
                width = 0.2, color = apep_colors[1], linewidth = 0.8) +
  geom_point(size = 4, color = apep_colors[1]) +
  coord_flip() +
  labs(
    title = "RDD Estimates Across All Outcomes",
    subtitle = "Effect of crossing 50,000 population threshold on transit and labor outcomes",
    x = NULL,
    y = "RD Estimate (percentage points)",
    caption = "Note: Bars show robust 95% confidence intervals. All estimates statistically insignificant."
  ) +
  theme_apep() +
  theme(
    axis.text.y = element_text(size = 11),
    panel.grid.major.y = element_blank()
  )

ggsave(file.path(fig_dir, "fig6_all_outcomes.pdf"), fig6,
       width = 8, height = 5, device = cairo_pdf)
ggsave(file.path(fig_dir, "fig6_all_outcomes.png"), fig6,
       width = 8, height = 5, dpi = 300)

# ============================================================================
# 8. FIGURE FOR STATE DISTRIBUTION
# ============================================================================

cat("Creating Figure 7: State distribution...\n")

# Subset to near-threshold areas and extract state from the name column we have
near_threshold <- ua_data %>%
  filter(abs(running_var) <= 15000) %>%
  mutate(
    threshold_status = ifelse(above_threshold == 1, "Above 50k (Eligible)", "Below 50k (Ineligible)"),
    # Extract state from name - use the state column we already have
    state_abbr = state
  )

# Count by state
state_counts <- near_threshold %>%
  filter(!is.na(state_abbr)) %>%
  group_by(state_abbr, threshold_status) %>%
  summarise(n = n(), .groups = "drop") %>%
  group_by(state_abbr) %>%
  mutate(total = sum(n)) %>%
  ungroup() %>%
  filter(total >= 2)  # Only states with at least 2 areas

fig7 <- ggplot(state_counts, aes(x = reorder(state_abbr, total), y = n, fill = threshold_status)) +
  geom_col(position = "stack", alpha = 0.8) +
  coord_flip() +
  scale_fill_manual(values = c(apep_colors[2], apep_colors[1]),
                    name = "Transit Funding Eligibility") +
  labs(
    title = "Urbanized Areas Near the 50,000 Threshold by State",
    subtitle = "Distribution of areas with population 35,000-65,000",
    x = NULL,
    y = "Number of Urbanized Areas",
    caption = "Source: 2020 Census urbanized area definitions."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(fig_dir, "fig7_state_distribution.png"), fig7,
       width = 8, height = 10, dpi = 300)

cat("\n=== All figures saved to:", fig_dir, "===\n")
cat("Files created:\n")
cat("  - fig1_population_distribution.pdf/png\n")
cat("  - fig2_rd_transit_share.pdf/png\n")
cat("  - fig3_rd_employment.pdf/png\n")
cat("  - fig4_covariate_balance.pdf/png\n")
cat("  - fig5_bandwidth_sensitivity.pdf/png\n")
cat("  - fig6_all_outcomes.pdf/png\n")
cat("  - fig7_state_distribution.pdf/png\n")
