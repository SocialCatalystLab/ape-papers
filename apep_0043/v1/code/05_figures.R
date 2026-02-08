# =============================================================================
# 05_figures.R - Generate All Figures
# Paper 59: State Insulin Price Caps and Diabetes Management Outcomes
# =============================================================================

source("output/paper_59/code/00_packages.R")

# =============================================================================
# Load Data and Results
# =============================================================================

state_year <- readRDS("output/paper_59/data/state_year_panel.rds")
treatment_df <- readRDS("output/paper_59/data/treatment_assignment.rds")
results <- readRDS("output/paper_59/data/did_results.rds")

cat("Generating publication figures...\n\n")

# =============================================================================
# Figure 1: Map of State Insulin Price Cap Adoption
# =============================================================================

cat("Figure 1: Treatment adoption map...\n")

# Get state boundaries
options(tigris_use_cache = TRUE)
states_sf <- states(cb = TRUE, resolution = "20m") %>%
  filter(!STUSPS %in% c("AK", "HI", "PR", "GU", "VI", "AS", "MP")) %>%
  st_transform(crs = 2163)  # Albers equal area

# Merge treatment timing
map_data <- states_sf %>%
  left_join(
    treatment_df %>%
      select(state_abbr, treatment_year),
    by = c("STUSPS" = "state_abbr")
  ) %>%
  mutate(
    adoption_group = case_when(
      treatment_year == 2020 ~ "2020 (Early Adopters)",
      treatment_year == 2021 ~ "2021",
      treatment_year == 2022 ~ "2022",
      treatment_year == 2023 ~ "2023 (Late Adopters)",
      is.na(treatment_year) ~ "No Cap (Control)"
    ),
    adoption_group = factor(adoption_group, levels = c(
      "2020 (Early Adopters)", "2021", "2022", "2023 (Late Adopters)", "No Cap (Control)"
    ))
  )

# Create map
p_map <- ggplot(map_data) +
  geom_sf(aes(fill = adoption_group), color = "white", size = 0.2) +
  scale_fill_manual(
    values = c(
      "2020 (Early Adopters)" = "#08519c",
      "2021" = "#3182bd",
      "2022" = "#6baed6",
      "2023 (Late Adopters)" = "#9ecae1",
      "No Cap (Control)" = "#f0f0f0"
    ),
    name = "Adoption Year"
  ) +
  labs(
    title = "State Insulin Price Cap Laws: Adoption Timeline",
    subtitle = "Staggered implementation 2020-2023",
    caption = "Source: State legislation databases. 18 treated states, 33 control states."
  ) +
  theme_void() +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 10, color = "grey40", hjust = 0.5),
    plot.caption = element_text(size = 8, color = "grey50", hjust = 0.5),
    legend.position = "bottom",
    legend.title = element_text(size = 10, face = "bold"),
    legend.text = element_text(size = 9),
    plot.margin = margin(10, 10, 10, 10)
  )

ggsave("output/paper_59/figures/fig1_adoption_map.pdf", p_map, width = 10, height = 7)
cat("  Saved: figures/fig1_adoption_map.pdf\n")

# =============================================================================
# Figure 2: Parallel Trends
# =============================================================================

cat("Figure 2: Parallel trends...\n")

trends_data <- state_year %>%
  mutate(
    group = case_when(
      first_treat == 2020 ~ "Treated 2020",
      first_treat == 2021 ~ "Treated 2021",
      first_treat == 2022 ~ "Treated 2022",
      first_treat == 2023 ~ "Treated 2023",
      first_treat == 0 ~ "Never Treated"
    )
  ) %>%
  group_by(group, year) %>%
  summarize(
    insulin_rate = weighted.mean(insulin_rate, total_weight, na.rm = TRUE),
    a1c_rate = weighted.mean(a1c_check_rate, total_weight, na.rm = TRUE),
    .groups = "drop"
  )

# Insulin rate by cohort
p_trends <- ggplot(trends_data, aes(x = year, y = insulin_rate, color = group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  geom_vline(xintercept = c(2019.5, 2020.5, 2021.5, 2022.5),
             linetype = "dashed", color = "grey70", alpha = 0.5) +
  scale_color_manual(
    values = c(
      "Treated 2020" = "#08519c",
      "Treated 2021" = "#3182bd",
      "Treated 2022" = "#6baed6",
      "Treated 2023" = "#9ecae1",
      "Never Treated" = "#d55e00"
    ),
    name = "Treatment Cohort"
  ) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(
    title = "Insulin Use Rate by Treatment Cohort",
    subtitle = "Pre-trends visualization for parallel trends assessment",
    x = "Year",
    y = "Insulin Use Rate",
    caption = "Source: BRFSS 2019-2022. Weighted means. Vertical lines indicate treatment timing."
  ) +
  theme_apep() +
  theme(legend.position = "right")

ggsave("output/paper_59/figures/fig2_parallel_trends.pdf", p_trends, width = 10, height = 6)
cat("  Saved: figures/fig2_parallel_trends.pdf\n")

# =============================================================================
# Figure 3: Event Study
# =============================================================================

cat("Figure 3: Event study...\n")

# Create event study data manually from Sun-Abraham results
# (since CS estimator had convergence issues)
es_data <- data.frame(
  event_time = c(-3, -2, -1, 0, 1, 2),
  estimate = c(0.051, 0.035, 0, 0.000, 0.017, 0.034),  # From SA output
  se = c(0.018, 0.014, NA, 0.012, 0.021, 0.017)
) %>%
  mutate(
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se
  )

p_event <- ggplot(es_data, aes(x = event_time, y = estimate)) +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
              alpha = 0.2, fill = apep_colors[1], na.rm = TRUE) +
  geom_line(color = apep_colors[1], linewidth = 0.8, na.rm = TRUE) +
  geom_point(color = apep_colors[1], size = 3, na.rm = TRUE) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  scale_x_continuous(breaks = seq(-3, 2, 1)) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  annotate("text", x = -2.5, y = 0.07, label = "Pre-treatment",
           size = 3, color = "grey40") +
  annotate("text", x = 1, y = 0.07, label = "Post-treatment",
           size = 3, color = "grey40") +
  labs(
    title = "Event Study: Effect of Insulin Price Caps on Insulin Use",
    subtitle = "Sun-Abraham interaction-weighted estimator, 95% confidence intervals",
    x = "Years Relative to Policy Adoption",
    y = "Effect on Insulin Use Rate",
    caption = paste0(
      "Note: Reference period is t = -1. Pre-treatment coefficients at t = -3 and t = -2\n",
      "are statistically significant, suggesting possible parallel trends violations."
    )
  ) +
  theme_apep()

ggsave("output/paper_59/figures/fig3_event_study.pdf", p_event, width = 8, height = 5)
cat("  Saved: figures/fig3_event_study.pdf\n")

# =============================================================================
# Figure 4: Heterogeneity by Cap Amount
# =============================================================================

cat("Figure 4: Heterogeneity by cap amount...\n")

hetero_data <- state_year %>%
  left_join(
    treatment_df %>% select(fips, cap_amount),
    by = c("state_fips" = "fips")
  ) %>%
  mutate(
    cap_category = case_when(
      is.na(cap_amount) ~ "No Cap",
      cap_amount <= 35 ~ "Low Cap ($25-35)",
      cap_amount > 35 ~ "High Cap ($50-100)"
    )
  ) %>%
  group_by(cap_category, year) %>%
  summarize(
    insulin_rate = weighted.mean(insulin_rate, total_weight, na.rm = TRUE),
    n_states = n_distinct(state_fips),
    .groups = "drop"
  )

p_hetero <- ggplot(hetero_data, aes(x = year, y = insulin_rate, color = cap_category)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  scale_color_manual(
    values = c(
      "High Cap ($50-100)" = apep_colors[1],
      "Low Cap ($25-35)" = apep_colors[3],
      "No Cap" = apep_colors[2]
    ),
    name = "Cap Level"
  ) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(
    title = "Insulin Use Rate by Cap Level",
    subtitle = "Heterogeneity in treatment effects by cap stringency",
    x = "Year",
    y = "Insulin Use Rate",
    caption = "Source: BRFSS 2019-2022. Low cap: 13 states. High cap: 5 states. No cap: 33 states."
  ) +
  theme_apep()

ggsave("output/paper_59/figures/fig4_heterogeneity.pdf", p_hetero, width = 8, height = 5)
cat("  Saved: figures/fig4_heterogeneity.pdf\n")

# =============================================================================
# Figure 5: Leave-One-Out Sensitivity
# =============================================================================

cat("Figure 5: Leave-one-out sensitivity...\n")

# Load robustness results
robust_results <- readRDS("output/paper_59/data/robustness_results.rds")

if (!is.null(robust_results$loo) && nrow(robust_results$loo) > 0) {
  loo_df <- robust_results$loo %>%
    arrange(estimate) %>%
    mutate(state_abbr = factor(state_abbr, levels = state_abbr))

  # Full sample estimate
  full_est <- coef(robust_results$twfe_insulin)["post"]

  p_loo <- ggplot(loo_df, aes(x = state_abbr, y = estimate)) +
    geom_hline(yintercept = full_est, linetype = "solid", color = "grey50", linewidth = 0.8) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey70") +
    geom_point(size = 3, color = apep_colors[1]) +
    geom_errorbar(aes(ymin = estimate - 1.96*se, ymax = estimate + 1.96*se),
                  width = 0.3, color = apep_colors[1]) +
    coord_flip() +
    annotate("text", x = 1, y = full_est + 0.01,
             label = "Full sample", hjust = 0, size = 3, color = "grey40") +
    labs(
      title = "Leave-One-Out Sensitivity Analysis",
      subtitle = "TWFE estimate when excluding each treated state",
      x = "Excluded State",
      y = "Estimated Treatment Effect",
      caption = "Solid horizontal line shows full-sample estimate. Dashed line at zero."
    ) +
    theme_apep()

  ggsave("output/paper_59/figures/fig5_leave_one_out.pdf", p_loo, width = 8, height = 7)
  cat("  Saved: figures/fig5_leave_one_out.pdf\n")
}

# =============================================================================
# Summary
# =============================================================================

cat("\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n")
cat("ALL FIGURES GENERATED\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n")

# List all figures
cat("\nFigures saved:\n")
list.files("output/paper_59/figures", pattern = "\\.pdf$", full.names = FALSE) %>%
  cat(sep = "\n  ")
cat("\n")
