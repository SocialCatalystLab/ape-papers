# ==============================================================================
# 05_figures.R
# Generate all figures for Clean Slate Laws paper
# ==============================================================================

source("output/paper_59/code/00_packages.R")

# Load data and results
panel_data <- readRDS("output/paper_59/data/panel_data.rds")
results <- readRDS("output/paper_59/data/main_results.rds")

fig_dir <- "output/paper_59/figures"
if (!dir.exists(fig_dir)) dir.create(fig_dir, recursive = TRUE)

cat("========================================\n")
cat("GENERATING FIGURES\n")
cat("========================================\n\n")

# ==============================================================================
# FIGURE 1: Treatment Timing Bar Chart
# ==============================================================================

cat("Creating Figure 1: Treatment timing...\n")

cohort_data <- clean_slate_dates %>%
  filter(treat_year <= 2024) %>%
  count(treat_year) %>%
  rename(cohort_size = n)

fig1 <- ggplot(cohort_data, aes(x = factor(treat_year), y = cohort_size)) +
  geom_col(fill = apep_colors[1], width = 0.7) +
  geom_text(aes(label = cohort_size), vjust = -0.5, size = 4, fontface = "bold") +
  labs(
    title = "Clean Slate Law Adoption by Year",
    subtitle = "Number of states implementing automatic expungement",
    x = "Year of Implementation",
    y = "Number of States",
    caption = "Source: Clean Slate Initiative, CCRC"
  ) +
  theme_apep() +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15)), breaks = 1:5)

ggsave(file.path(fig_dir, "fig1_adoption_timing.pdf"), fig1, width = 8, height = 5)
ggsave(file.path(fig_dir, "fig1_adoption_timing.png"), fig1, width = 8, height = 5, dpi = 300)

# ==============================================================================
# FIGURE 2: Parallel Trends - Employment Rate by Treatment Status
# ==============================================================================

cat("Creating Figure 2: Parallel trends...\n")

# Compute mean employment rate by treatment status and year
trends_data <- panel_data %>%
  mutate(
    group = ifelse(treated == 1, "Clean Slate States", "Control States")
  ) %>%
  group_by(group, year) %>%
  summarize(
    emp_rate_mean = mean(emp_rate, na.rm = TRUE),
    emp_rate_se = sd(emp_rate, na.rm = TRUE) / sqrt(n()),
    n = n(),
    .groups = "drop"
  )

fig2 <- ggplot(trends_data, aes(x = year, y = emp_rate_mean, color = group)) +
  geom_ribbon(
    aes(ymin = emp_rate_mean - 1.96 * emp_rate_se,
        ymax = emp_rate_mean + 1.96 * emp_rate_se,
        fill = group),
    alpha = 0.15, color = NA
  ) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  geom_vline(xintercept = 2018.5, linetype = "dashed", color = "grey40") +
  annotate("text", x = 2019.5, y = max(trends_data$emp_rate_mean) + 1,
           label = "First Clean Slate\nImplementation (2019)", hjust = 0, size = 3, color = "grey40") +
  scale_color_manual(values = c("Clean Slate States" = apep_colors[1],
                                "Control States" = apep_colors[2])) +
  scale_fill_manual(values = c("Clean Slate States" = apep_colors[1],
                               "Control States" = apep_colors[2])) +
  labs(
    title = "Employment-to-Population Ratio by Treatment Status",
    subtitle = "Mean across states, 95% confidence intervals",
    x = "Year",
    y = "Employment Rate (%)",
    color = "",
    fill = "",
    caption = "Note: Dashed line indicates first Clean Slate law implementation (PA, 2019)."
  ) +
  theme_apep() +
  theme(legend.position = c(0.2, 0.2))

ggsave(file.path(fig_dir, "fig2_parallel_trends.pdf"), fig2, width = 9, height = 6)
ggsave(file.path(fig_dir, "fig2_parallel_trends.png"), fig2, width = 9, height = 6, dpi = 300)

# ==============================================================================
# FIGURE 3: Event Study - Employment Rate
# ==============================================================================

cat("Creating Figure 3: Event study...\n")

# Extract event study coefficients from saved results
es_coefs <- results$es_coefs

# Filter to employment rate and reasonable event time window
es_emp <- es_coefs %>%
  filter(outcome == "Employment Rate", rel_time >= -8, rel_time <= 4) %>%
  mutate(
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se
  )

fig3 <- ggplot(es_emp, aes(x = rel_time, y = estimate)) +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
              alpha = 0.2, fill = apep_colors[1]) +
  geom_point(color = apep_colors[1], size = 3) +
  geom_line(color = apep_colors[1], linewidth = 0.8) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  labs(
    title = "Event Study: Effect of Clean Slate Laws on Employment",
    subtitle = "Sun-Abraham estimator, 95% confidence intervals",
    x = "Years Relative to Clean Slate Implementation",
    y = "ATT (Percentage Points)",
    caption = "Note: Reference period is t = -1. Control group: never-treated states."
  ) +
  theme_apep() +
  scale_x_continuous(breaks = seq(-8, 4, 1))

ggsave(file.path(fig_dir, "fig3_event_study_emp.pdf"), fig3, width = 9, height = 6)
ggsave(file.path(fig_dir, "fig3_event_study_emp.png"), fig3, width = 9, height = 6, dpi = 300)

# ==============================================================================
# FIGURE 4: Event Study - LFP Rate
# ==============================================================================

cat("Creating Figure 4: Event study - LFP...\n")

es_lfp <- es_coefs %>%
  filter(outcome == "LFP Rate", rel_time >= -8, rel_time <= 4) %>%
  mutate(
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se
  )

fig4 <- ggplot(es_lfp, aes(x = rel_time, y = estimate)) +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
              alpha = 0.2, fill = apep_colors[3]) +
  geom_point(color = apep_colors[3], size = 3) +
  geom_line(color = apep_colors[3], linewidth = 0.8) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  labs(
    title = "Event Study: Effect of Clean Slate Laws on Labor Force Participation",
    subtitle = "Sun-Abraham estimator, 95% confidence intervals",
    x = "Years Relative to Clean Slate Implementation",
    y = "ATT (Percentage Points)",
    caption = "Note: Reference period is t = -1. Control group: never-treated states."
  ) +
  theme_apep() +
  scale_x_continuous(breaks = seq(-8, 4, 1))

ggsave(file.path(fig_dir, "fig4_event_study_lfp.pdf"), fig4, width = 9, height = 6)
ggsave(file.path(fig_dir, "fig4_event_study_lfp.png"), fig4, width = 9, height = 6, dpi = 300)

# ==============================================================================
# FIGURE 5: All Three Outcomes Panel
# ==============================================================================

cat("Creating Figure 5: Multi-panel event study...\n")

es_all <- es_coefs %>%
  filter(rel_time >= -8, rel_time <= 4) %>%
  mutate(
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se,
    outcome = factor(outcome, levels = c("Employment Rate", "LFP Rate", "Unemployment Rate"))
  )

fig5 <- ggplot(es_all, aes(x = rel_time, y = estimate)) +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
              alpha = 0.2, fill = apep_colors[1]) +
  geom_point(color = apep_colors[1], size = 2) +
  geom_line(color = apep_colors[1], linewidth = 0.6) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  facet_wrap(~ outcome, scales = "free_y", ncol = 3) +
  labs(
    title = "Event Study: Clean Slate Laws and Labor Market Outcomes",
    subtitle = "Sun-Abraham estimator, 95% CI. Reference period: t = -1",
    x = "Years Relative to Implementation",
    y = "ATT (Percentage Points)"
  ) +
  theme_apep() +
  theme(
    strip.text = element_text(face = "bold", size = 10),
    panel.spacing = unit(1.5, "lines")
  ) +
  scale_x_continuous(breaks = seq(-6, 4, 2))

ggsave(file.path(fig_dir, "fig5_all_outcomes.pdf"), fig5, width = 12, height = 4.5)
ggsave(file.path(fig_dir, "fig5_all_outcomes.png"), fig5, width = 12, height = 4.5, dpi = 300)

# ==============================================================================
# Done
# ==============================================================================

cat("\n========================================\n")
cat("Figures saved to:", fig_dir, "\n")
cat("  - fig1_adoption_timing.pdf\n")
cat("  - fig2_parallel_trends.pdf\n")
cat("  - fig3_event_study_emp.pdf\n")
cat("  - fig4_event_study_lfp.pdf\n")
cat("  - fig5_all_outcomes.pdf\n")
cat("========================================\n")
