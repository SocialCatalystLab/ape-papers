# ==============================================================================
# 05_figures.R
# Generate publication-quality figures
# Paper 111: NP Full Practice Authority and Physician Employment
# ==============================================================================

source("00_packages.R")

# Load data and results
analysis_main <- read_csv(file.path(data_dir, "analysis_main.csv"))
analysis_did <- read_csv(file.path(data_dir, "analysis_did.csv"))
es_results <- read_csv(file.path(data_dir, "event_study_results.csv"))
results <- readRDS(file.path(data_dir, "main_results.rds"))
fpa_dates <- read_csv(file.path(data_dir, "fpa_dates.csv"))

# ==============================================================================
# FIGURE 1: Event Study Plot
# ==============================================================================

cat("Creating Figure 1: Event Study...\n")

fig1 <- es_results %>%
  mutate(
    significant = (ci_lower > 0) | (ci_upper < 0)
  ) %>%
  ggplot(aes(x = event_time, y = att)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray50") +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, fill = "#2E86AB") +
  geom_point(aes(color = significant), size = 3) +
  geom_line(color = "#2E86AB", linewidth = 0.8) +
  scale_color_manual(values = c("FALSE" = "#2E86AB", "TRUE" = "#E94F37"),
                     guide = "none") +
  scale_x_continuous(breaks = seq(-8, 8, 2)) +
  labs(
    title = "Effect of Full Practice Authority on Physician Office Employment",
    subtitle = "Callaway-Sant'Anna event study estimates (NAICS 6211)",
    x = "Years Relative to FPA Adoption",
    y = "ATT (Log Employment in Offices of Physicians)",
    caption = "Notes: Shaded area shows 95% confidence intervals. Vertical dashed line indicates treatment timing."
  ) +
  annotate("text", x = -4, y = max(es_results$ci_upper, na.rm = TRUE) * 0.9,
           label = "Pre-treatment", hjust = 0.5, size = 3.5, color = "gray40") +
  annotate("text", x = 4, y = max(es_results$ci_upper, na.rm = TRUE) * 0.9,
           label = "Post-treatment", hjust = 0.5, size = 3.5, color = "gray40") +
  theme(
    plot.caption = element_text(hjust = 0, size = 9, color = "gray40")
  )

ggsave(file.path(fig_dir, "fig1_event_study.pdf"),  fig1, width = 10, height = 6)
ggsave(file.path(fig_dir, "fig1_event_study.png"),  fig1, width = 10, height = 6, dpi = 300)

cat("  Saved: figures/fig1_event_study.pdf\n")

# ==============================================================================
# FIGURE 2: Map of FPA Adoption Timing
# ==============================================================================

cat("Creating Figure 2: FPA Adoption Map...\n")

# Prepare map data
map_data <- fpa_dates %>%
  filter(fpa_year > 0) %>%
  mutate(
    adoption_period = case_when(
      fpa_year < 2000 ~ "Before 2000",
      fpa_year >= 2000 & fpa_year < 2010 ~ "2000-2009",
      fpa_year >= 2010 & fpa_year < 2020 ~ "2010-2019",
      fpa_year >= 2020 ~ "2020+"
    ),
    adoption_period = factor(adoption_period,
                             levels = c("Before 2000", "2000-2009", "2010-2019", "2020+"))
  )

# Add non-FPA states
non_fpa <- fpa_dates %>%
  filter(fpa_year == 0) %>%
  mutate(adoption_period = "Never Adopted")

all_map_data <- bind_rows(map_data, non_fpa) %>%
  mutate(
    adoption_period = factor(adoption_period,
                             levels = c("Before 2000", "2000-2009", "2010-2019", "2020+", "Never Adopted")),
    state = state_abbr  # usmap requires 'state' column
  )

fig2 <- plot_usmap(
  data = all_map_data,
  values = "adoption_period",
  labels = FALSE
) +
  scale_fill_manual(
    values = c(
      "Before 2000" = "#1a9850",
      "2000-2009" = "#91cf60",
      "2010-2019" = "#fee08b",
      "2020+" = "#fc8d59",
      "Never Adopted" = "#d73027"
    ),
    name = "FPA Adoption"
  ) +
  labs(
    title = "Full Practice Authority Adoption Timing by State",
    subtitle = "States with darker colors adopted FPA earlier",
    caption = "Notes: FPA = Full Practice Authority for Nurse Practitioners.\nSource: AANP State Practice Environment data."
  ) +
  theme(
    legend.position = "right",
    plot.caption = element_text(hjust = 0, size = 9, color = "gray40")
  )

ggsave(file.path(fig_dir, "fig2_adoption_map.pdf"),  fig2, width = 12, height = 8)
ggsave(file.path(fig_dir, "fig2_adoption_map.png"),  fig2, width = 12, height = 8, dpi = 300)

cat("  Saved: figures/fig2_adoption_map.pdf\n")

# ==============================================================================
# FIGURE 3: Raw Trends by Treatment Status
# ==============================================================================

cat("Creating Figure 3: Raw Trends...\n")

# Calculate average employment by year and treatment status
trends_data <- analysis_main %>%
  mutate(
    group = ifelse(ever_treated, "FPA States", "Non-FPA States")
  ) %>%
  group_by(year, group) %>%
  summarise(
    mean_emp = mean(employment, na.rm = TRUE),
    se_emp = sd(employment, na.rm = TRUE) / sqrt(n()),
    n = n(),
    .groups = "drop"
  )

# Normalize to 2000 = 100
base_values <- trends_data %>%
  filter(year == 2000) %>%
  select(group, base_emp = mean_emp)

trends_data <- trends_data %>%
  left_join(base_values, by = "group") %>%
  mutate(
    normalized_emp = (mean_emp / base_emp) * 100
  )

fig3 <- trends_data %>%
  ggplot(aes(x = year, y = normalized_emp, color = group, fill = group)) +
  geom_ribbon(aes(ymin = normalized_emp - 1.96 * se_emp / base_emp * 100,
                  ymax = normalized_emp + 1.96 * se_emp / base_emp * 100),
              alpha = 0.2, color = NA) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2) +
  scale_color_manual(values = colors_main) +
  scale_fill_manual(values = colors_main) +
  scale_x_continuous(breaks = seq(2000, 2023, 4)) +
  labs(
    title = "Physician Employment Trends by FPA Status",
    subtitle = "Mean employment normalized to 2000 = 100",
    x = "Year",
    y = "Normalized Employment (2000 = 100)",
    color = NULL,
    fill = NULL,
    caption = "Notes: Shaded areas show 95% confidence intervals around means.\nSource: BLS Quarterly Census of Employment and Wages."
  ) +
  theme(
    legend.position = c(0.15, 0.85),
    plot.caption = element_text(hjust = 0, size = 9, color = "gray40")
  )

ggsave(file.path(fig_dir, "fig3_raw_trends.pdf"),  fig3, width = 10, height = 6)
ggsave(file.path(fig_dir, "fig3_raw_trends.png"),  fig3, width = 10, height = 6, dpi = 300)

cat("  Saved: figures/fig3_raw_trends.pdf\n")

# ==============================================================================
# FIGURE 4: Group-Specific Treatment Effects by Cohort
# ==============================================================================

cat("Creating Figure 4: Cohort Effects...\n")

# Extract group-specific ATTs
cohort_effects <- tibble(
  cohort = results$agg_group$egt,
  att = results$agg_group$att.egt,
  se = results$agg_group$se.egt
) %>%
  filter(cohort >= 2008) %>%  # Focus on post-2007 adopters
  mutate(
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se,
    significant = (ci_lower > 0) | (ci_upper < 0)
  )

fig4 <- cohort_effects %>%
  ggplot(aes(x = factor(cohort), y = att)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.2, color = "#2E86AB") +
  geom_point(aes(color = significant), size = 4) +
  scale_color_manual(values = c("FALSE" = "#2E86AB", "TRUE" = "#E94F37"),
                     guide = "none") +
  labs(
    title = "Treatment Effects by Adoption Cohort",
    subtitle = "Callaway-Sant'Anna group-specific ATT estimates",
    x = "FPA Adoption Year",
    y = "ATT (Log Employment)",
    caption = "Notes: Error bars show 95% confidence intervals.\nRed points indicate statistically significant effects at 5% level."
  ) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    plot.caption = element_text(hjust = 0, size = 9, color = "gray40")
  )

ggsave(file.path(fig_dir, "fig4_cohort_effects.pdf"),  fig4, width = 10, height = 6)
ggsave(file.path(fig_dir, "fig4_cohort_effects.png"),  fig4, width = 10, height = 6, dpi = 300)

cat("  Saved: figures/fig4_cohort_effects.pdf\n")

# ==============================================================================
# FIGURE 5: Skipped (placebo data not available due to API limitations)
# ==============================================================================

cat("Skipping Figure 5: Placebo tests not available\n")

# Load robustness results for Figure 6
robustness <- readRDS(file.path(data_dir, "robustness_results.rds"))

# ==============================================================================
# FIGURE 6: Robustness Specifications
# ==============================================================================

cat("Creating Figure 6: Robustness Specifications...\n")

# Compile all specifications
specs <- tibble(
  specification = c(
    "Main (CS-DiD)",
    "TWFE (Traditional)",
    "Excl. 2021+ Adopters",
    "Large States Only",
    "High Physician Baseline",
    "Low Physician Baseline"
  ),
  estimate = c(
    results$simple_att$estimate,
    coef(results$twfe)["postTRUE"],
    coef(robustness$sensitivity_recent)["postTRUE"],
    coef(robustness$sensitivity_large)["postTRUE"],
    coef(robustness$het_high)["postTRUE"],
    coef(robustness$het_low)["postTRUE"]
  ),
  se = c(
    results$simple_att$se,
    se(results$twfe)["postTRUE"],
    se(robustness$sensitivity_recent)["postTRUE"],
    se(robustness$sensitivity_large)["postTRUE"],
    se(robustness$het_high)["postTRUE"],
    se(robustness$het_low)["postTRUE"]
  )
) %>%
  mutate(
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se,
    specification = factor(specification, levels = rev(specification))
  )

fig6 <- specs %>%
  ggplot(aes(x = estimate, y = specification)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
  geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper), height = 0.2, color = "#2E86AB") +
  geom_point(size = 3, color = "#2E86AB") +
  labs(
    title = "Robustness of Main Results Across Specifications",
    x = "Treatment Effect (Log Employment)",
    y = NULL,
    caption = "Notes: Error bars show 95% confidence intervals.\nAll specifications cluster standard errors at the state level."
  ) +
  theme(
    plot.caption = element_text(hjust = 0, size = 9, color = "gray40")
  )

ggsave(file.path(fig_dir, "fig6_robustness.pdf"),  fig6, width = 10, height = 6)
ggsave(file.path(fig_dir, "fig6_robustness.png"),  fig6, width = 10, height = 6, dpi = 300)

cat("  Saved: figures/fig6_robustness.pdf\n")

# ==============================================================================
# Completion
# ==============================================================================

cat("\n=== All Figures Saved ===\n")
cat("Generated 6 publication-quality figures in figures/\n")
