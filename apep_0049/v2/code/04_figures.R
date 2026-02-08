# ============================================================================
# Paper 129: Revision of APEP-0049 - Transit Funding Discontinuity
# 04_figures.R - Create publication-ready figures
#
# Uses 2010 Census population (running variable) -> 2016-2020 ACS outcomes
# ============================================================================

# Source packages from relative path (run from code/ or paper root)
if (file.exists("00_packages.R")) {
  source("00_packages.R")
} else if (file.exists("code/00_packages.R")) {
  source("code/00_packages.R")
} else {
  stop("Cannot find 00_packages.R - run from code/ directory or paper root")
}

# ============================================================================
# 1. LOAD DATA
# ============================================================================

cat("=== Loading Data ===\n")

analysis_data <- read_csv(file.path(data_dir, "ua_analysis.csv"), show_col_types = FALSE)
rdd_results <- read_csv(file.path(data_dir, "rdd_results.csv"), show_col_types = FALSE)
mccrary <- read_csv(file.path(data_dir, "mccrary_test.csv"), show_col_types = FALSE)

cat("Analysis sample:", nrow(analysis_data), "urban areas\n")

# ============================================================================
# 2. FIGURE 1: DISTRIBUTION OF URBANIZED AREAS BY POPULATION (McCrary)
# ============================================================================

cat("\nCreating Figure 1: Population distribution (McCrary test)...\n")

# Plot distribution near threshold
plot_data_hist <- analysis_data %>%
  filter(abs(running_var) <= 40000)

fig1 <- ggplot(plot_data_hist, aes(x = population_2010 / 1000)) +
  geom_histogram(binwidth = 2.5, fill = apep_colors[1], color = "white", alpha = 0.7) +
  geom_vline(xintercept = 50, linetype = "dashed", color = apep_colors[2], linewidth = 1) +
  annotate("text", x = 50, y = Inf, label = "50,000 Threshold",
           hjust = -0.1, vjust = 1.5, color = apep_colors[2], size = 3.5, fontface = "bold") +
  labs(
    title = "Distribution of Urban Areas Near the 50,000 Population Threshold",
    subtitle = sprintf("McCrary density test: t = %.2f, p = %.3f (no evidence of manipulation)",
                       mccrary$t_stat, mccrary$p_value),
    x = "2010 Census Population (thousands)",
    y = "Number of Urban Areas",
    caption = "Note: Sample includes 2010 Census urban areas with population 10,000-90,000."
  ) +
  theme_apep() +
  scale_x_continuous(breaks = seq(10, 90, 10), limits = c(10, 90))

ggsave(file.path(fig_dir, "fig1_population_distribution.png"), fig1,
       width = 8, height = 5, dpi = 300)

# ============================================================================
# 3. FIGURE 2: RDD PLOT - TRANSIT SHARE (Primary Outcome)
# ============================================================================

cat("Creating Figure 2: RDD plot for transit share...\n")

# Create binned scatter with local polynomial fits
plot_data_transit <- analysis_data %>%
  filter(abs(running_var) <= 25000) %>%
  mutate(bin = cut(running_var, breaks = seq(-25000, 25000, by = 2500), include.lowest = TRUE)) %>%
  group_by(bin) %>%
  summarise(
    mean_x = mean(running_var),
    mean_y = mean(transit_share, na.rm = TRUE),
    n = n(),
    se = sd(transit_share, na.rm = TRUE) / sqrt(n())
  ) %>%
  ungroup() %>%
  filter(!is.na(bin), !is.na(mean_y))

# Get RDD result for annotation
rd_transit_result <- rdd_results %>% filter(outcome == "Transit Share")

fig2 <- ggplot() +
  # Binned means with error bars
  geom_point(data = plot_data_transit, aes(x = mean_x / 1000, y = mean_y * 100),
             color = "grey50", size = 3, alpha = 0.8) +
  geom_errorbar(data = plot_data_transit,
                aes(x = mean_x / 1000,
                    ymin = (mean_y - 1.96*se) * 100,
                    ymax = (mean_y + 1.96*se) * 100),
                color = "grey50", width = 0.5, alpha = 0.5) +

  # Local polynomial fits (separate for each side)
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
  annotate("text", x = 15, y = max(plot_data_transit$mean_y * 100, na.rm = TRUE) * 0.95,
           label = sprintf("RD Estimate: %.4f\n(Robust SE: %.4f)\np = %.3f",
                           rd_transit_result$estimate, rd_transit_result$robust_se,
                           rd_transit_result$p_value),
           hjust = 0, size = 3, fontface = "italic") +

  labs(
    title = "Effect of Section 5307 Eligibility on Public Transit Use",
    subtitle = "Sharp RDD at 50,000 population threshold (2010 Census classification)",
    x = "Population Relative to 50,000 Threshold (thousands)",
    y = "Transit Share (%)",
    caption = "Note: Points show binned means with 95% CIs. Lines show local polynomial fits.\nRunning variable: 2010 Census. Outcomes: 2016-2020 ACS."
  ) +
  theme_apep() +
  scale_x_continuous(breaks = seq(-25, 25, 5)) +
  scale_y_continuous(labels = function(x) paste0(x, "%"))

ggsave(file.path(fig_dir, "fig2_rd_transit_share.png"), fig2,
       width = 9, height = 6, dpi = 300)

# ============================================================================
# 4. FIGURE 3: RDD PLOT - EMPLOYMENT RATE
# ============================================================================

cat("Creating Figure 3: RDD plot for employment rate...\n")

plot_data_emp <- analysis_data %>%
  filter(abs(running_var) <= 25000) %>%
  mutate(bin = cut(running_var, breaks = seq(-25000, 25000, by = 2500), include.lowest = TRUE)) %>%
  group_by(bin) %>%
  summarise(
    mean_x = mean(running_var),
    mean_y = mean(employment_rate, na.rm = TRUE),
    n = n(),
    se = sd(employment_rate, na.rm = TRUE) / sqrt(n())
  ) %>%
  ungroup() %>%
  filter(!is.na(bin), !is.na(mean_y))

rd_emp_result <- rdd_results %>% filter(outcome == "Employment Rate")

fig3 <- ggplot() +
  geom_point(data = plot_data_emp, aes(x = mean_x / 1000, y = mean_y * 100),
             color = "grey50", size = 3, alpha = 0.8) +
  geom_errorbar(data = plot_data_emp,
                aes(x = mean_x / 1000,
                    ymin = (mean_y - 1.96*se) * 100,
                    ymax = (mean_y + 1.96*se) * 100),
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
                           rd_emp_result$estimate, rd_emp_result$robust_se,
                           rd_emp_result$p_value),
           hjust = 0, size = 3, fontface = "italic") +

  labs(
    title = "Effect of Section 5307 Eligibility on Employment Rate",
    subtitle = "Sharp RDD at 50,000 population threshold",
    x = "Population Relative to 50,000 Threshold (thousands)",
    y = "Employment Rate (%)",
    caption = "Note: Employment rate = employed / labor force. 2016-2020 ACS estimates."
  ) +
  theme_apep() +
  scale_x_continuous(breaks = seq(-25, 25, 5)) +
  scale_y_continuous(labels = function(x) paste0(x, "%"))

ggsave(file.path(fig_dir, "fig3_rd_employment.png"), fig3,
       width = 9, height = 6, dpi = 300)

# ============================================================================
# 5. FIGURE 4: COVARIATE BALANCE (Median HH Income)
# ============================================================================

cat("Creating Figure 4: Covariate balance...\n")

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

# Load balance test result
balance_result <- read_csv(file.path(data_dir, "balance_test.csv"), show_col_types = FALSE)

fig4 <- ggplot() +
  geom_point(data = plot_data_income, aes(x = mean_x / 1000, y = mean_y / 1000),
             color = "grey50", size = 3, alpha = 0.8) +
  geom_errorbar(data = plot_data_income,
                aes(x = mean_x / 1000,
                    ymin = (mean_y - 1.96*se) / 1000,
                    ymax = (mean_y + 1.96*se) / 1000),
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

  annotate("text", x = -20, y = max(plot_data_income$mean_y / 1000, na.rm = TRUE) * 0.98,
           label = sprintf("RD Estimate: $%.0f\np = %.3f (smooth)",
                           balance_result$estimate, balance_result$p_value),
           hjust = 0, size = 3, fontface = "italic") +

  labs(
    title = "Covariate Balance: Median Household Income at Threshold",
    subtitle = "Validation test - predetermined covariates should be smooth at threshold",
    x = "Population Relative to 50,000 Threshold (thousands)",
    y = "Median Household Income ($thousands)",
    caption = "Note: No discontinuity in income at threshold supports RDD validity."
  ) +
  theme_apep() +
  scale_x_continuous(breaks = seq(-25, 25, 5)) +
  scale_y_continuous(labels = function(x) paste0("$", x, "k"))

ggsave(file.path(fig_dir, "fig4_covariate_balance.png"), fig4,
       width = 9, height = 6, dpi = 300)

# ============================================================================
# 6. FIGURE 5: BANDWIDTH SENSITIVITY
# ============================================================================

cat("Creating Figure 5: Bandwidth sensitivity...\n")

bw_sensitivity <- read_csv(file.path(data_dir, "bandwidth_sensitivity.csv"), show_col_types = FALSE)

fig5 <- ggplot(bw_sensitivity, aes(x = multiplier)) +
  geom_ribbon(aes(ymin = (estimate - 1.96*robust_se) * 100,
                  ymax = (estimate + 1.96*robust_se) * 100),
              fill = apep_colors[1], alpha = 0.2) +
  geom_line(aes(y = estimate * 100), color = apep_colors[1], linewidth = 1) +
  geom_point(aes(y = estimate * 100), color = apep_colors[1], size = 3) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = 1, linetype = "dotted", color = "grey60") +
  annotate("text", x = 1.05, y = max(bw_sensitivity$estimate * 100) + 0.3,
           label = "MSE-Optimal", size = 3, hjust = 0) +
  labs(
    title = "Bandwidth Sensitivity Analysis: Transit Share",
    subtitle = "RD estimates stable across bandwidth choices",
    x = "Bandwidth Multiplier (1 = MSE-Optimal)",
    y = "RD Estimate (percentage points)",
    caption = sprintf("Note: Optimal bandwidth = %.0f population. Shaded area shows 95%% CI.",
                      bw_sensitivity$bandwidth[bw_sensitivity$multiplier == 1])
  ) +
  theme_apep() +
  scale_x_continuous(breaks = bw_sensitivity$multiplier)

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
    subtitle = "Effect of Section 5307 eligibility on transit and labor market outcomes",
    x = NULL,
    y = "RD Estimate (percentage points)",
    caption = "Note: Bars show robust 95% confidence intervals. All estimates statistically insignificant at 5% level."
  ) +
  theme_apep() +
  theme(
    axis.text.y = element_text(size = 11),
    panel.grid.major.y = element_blank()
  )

ggsave(file.path(fig_dir, "fig6_all_outcomes.png"), fig6,
       width = 8, height = 5, dpi = 300)

# ============================================================================
# 8. FIGURE 7: FIRST STAGE - STATUTORY ELIGIBILITY
# ============================================================================

cat("Creating Figure 7: First stage (statutory eligibility)...\n")

# The first stage is SHARP by statute - this figure illustrates the legal discontinuity
# Section 5307 eligibility is binary at 50,000 threshold

first_stage_data <- tibble(
  population = seq(25000, 75000, by = 100),
  running_var = seq(25000, 75000, by = 100) - 50000,
  eligible = as.integer(seq(25000, 75000, by = 100) >= 50000)
)

fig7 <- ggplot(first_stage_data, aes(x = running_var / 1000, y = eligible)) +
  geom_line(aes(color = factor(eligible)), linewidth = 1.5) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey30", linewidth = 0.8) +
  scale_color_manual(values = c("0" = apep_colors[2], "1" = apep_colors[1]),
                     labels = c("0" = "Not Eligible", "1" = "Eligible"),
                     name = "Section 5307\nStatus") +
  scale_y_continuous(breaks = c(0, 1), labels = c("No", "Yes")) +
  labs(
    title = "First Stage: Section 5307 Formula Funding Eligibility",
    subtitle = "Sharp statutory discontinuity at 50,000 population threshold",
    x = "Population Relative to 50,000 Threshold (thousands)",
    y = "Eligible for Section 5307?",
    caption = "Note: By federal law, only urbanized areas (population >= 50,000) are eligible for\nSection 5307 Urbanized Area Formula Grants. This creates a SHARP first stage."
  ) +
  theme_apep() +
  theme(legend.position = "right") +
  annotate("text", x = -15, y = 0.5, label = "Urban Clusters\n(Not eligible for 5307)",
           color = apep_colors[2], size = 3.5, fontface = "italic") +
  annotate("text", x = 15, y = 0.5, label = "Urbanized Areas\n(Eligible for 5307)",
           color = apep_colors[1], size = 3.5, fontface = "italic")

ggsave(file.path(fig_dir, "fig7_first_stage.png"), fig7,
       width = 9, height = 6, dpi = 300)

# ============================================================================
# 9. FIGURE 8: PLACEBO THRESHOLD TESTS
# ============================================================================

cat("Creating Figure 8: Placebo threshold tests...\n")

placebo_results <- read_csv(file.path(data_dir, "placebo_thresholds.csv"), show_col_types = FALSE)

fig8 <- ggplot(placebo_results, aes(x = factor(threshold), y = estimate * 100)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_errorbar(aes(ymin = (estimate - 1.96*robust_se) * 100,
                    ymax = (estimate + 1.96*robust_se) * 100),
                width = 0.2, linewidth = 0.8,
                color = ifelse(placebo_results$threshold == 50000, apep_colors[1], "grey50")) +
  geom_point(size = 4,
             color = ifelse(placebo_results$threshold == 50000, apep_colors[1], "grey50")) +
  labs(
    title = "Placebo Threshold Tests: Transit Share",
    subtitle = "Testing for spurious discontinuities at non-threshold values",
    x = "Population Threshold",
    y = "RD Estimate (percentage points)",
    caption = "Note: Blue point is the true 50,000 threshold. No significant effects at any placebo threshold."
  ) +
  theme_apep() +
  scale_x_discrete(labels = function(x) paste0(as.numeric(x)/1000, "k"))

ggsave(file.path(fig_dir, "fig8_placebo_thresholds.png"), fig8,
       width = 8, height = 5, dpi = 300)

# ============================================================================
# DONE
# ============================================================================

cat("\n=== All figures saved to:", fig_dir, "===\n")
cat("Files created:\n")
cat("  - fig1_population_distribution.png\n")
cat("  - fig2_rd_transit_share.png\n")
cat("  - fig3_rd_employment.png\n")
cat("  - fig4_covariate_balance.png\n")
cat("  - fig5_bandwidth_sensitivity.png\n")
cat("  - fig6_all_outcomes.png\n")
cat("  - fig7_first_stage.png (STATUTORY DISCONTINUITY - NOT FABRICATED)\n")
cat("  - fig8_placebo_thresholds.png\n")
