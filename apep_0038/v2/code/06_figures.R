# =============================================================================
# 06_figures.R
# Generate Publication-Quality Figures
# Sports Betting Employment Effects - Revision of apep_0038
# =============================================================================

source("00_packages.R")

# -----------------------------------------------------------------------------
# Load Data
# -----------------------------------------------------------------------------

cs_data <- read_csv("../data/cs_analysis_data.csv", show_col_types = FALSE)
analysis_sample <- read_csv("../data/analysis_sample.csv", show_col_types = FALSE)
event_study <- read_csv("../data/event_study_coefficients.csv", show_col_types = FALSE)
main_results <- readRDS("../data/main_results.rds")

# Figure directory
fig_dir <- "../figures"
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

# -----------------------------------------------------------------------------
# Figure 1: Event Study Plot (Main Result)
# -----------------------------------------------------------------------------

message("Creating Figure 1: Event Study...")

fig1 <- event_study %>%
  ggplot(aes(x = event_time, y = att)) +
  # Zero line
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  # Treatment line
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray30") +
  # Confidence intervals
  geom_ribbon(aes(ymin = ci_low, ymax = ci_high),
              fill = "steelblue", alpha = 0.2) +
  # Point estimates
  geom_point(size = 3, color = "steelblue") +
  geom_line(color = "steelblue", linewidth = 0.8) +
  # Labels
  labs(
    x = "Years Since Sports Betting Legalization",
    y = "Effect on Gambling Industry Employment",
    title = "Event Study: Employment Effects of Sports Betting Legalization",
    subtitle = "Callaway-Sant'Anna estimator with not-yet-treated control group"
  ) +
  # Scales
  scale_x_continuous(breaks = seq(-6, 6, 2)) +
  scale_y_continuous(labels = scales::comma) +
  # Theme
theme_paper() +
  theme(
    plot.title = element_text(size = 12, face = "bold"),
    plot.subtitle = element_text(size = 10, color = "gray40")
  )

ggsave(file.path(fig_dir, "fig1_event_study.pdf"), fig1,
       width = 8, height = 5, device = cairo_pdf)
ggsave(file.path(fig_dir, "fig1_event_study.png"), fig1,
       width = 8, height = 5, dpi = 300)

message("  Saved: fig1_event_study.pdf")

# -----------------------------------------------------------------------------
# Figure 2: Parallel Trends by Cohort
# -----------------------------------------------------------------------------

message("Creating Figure 2: Parallel Trends...")

# Create cohort groups
cohort_data <- analysis_sample %>%
  mutate(
    cohort_group = case_when(
      is.na(sb_year_quarter) | !ever_treated_sb ~ "Never Treated",
      floor(sb_year_quarter) == 2018 ~ "2018 Cohort",
      floor(sb_year_quarter) == 2019 ~ "2019 Cohort",
      floor(sb_year_quarter) == 2020 ~ "2020 Cohort",
      floor(sb_year_quarter) >= 2021 ~ "2021+ Cohort"
    )
  ) %>%
  group_by(year, cohort_group) %>%
  summarise(
    mean_empl = mean(empl_7132, na.rm = TRUE),
    se_empl = sd(empl_7132, na.rm = TRUE) / sqrt(n()),
    n = n(),
    .groups = "drop"
  )

fig2 <- cohort_data %>%
  filter(cohort_group != "Never Treated" | year <= 2022) %>%
  ggplot(aes(x = year, y = mean_empl, color = cohort_group)) +
  geom_vline(xintercept = 2018, linetype = "dashed", color = "gray50", alpha = 0.5) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  labs(
    x = "Year",
    y = "Mean Gambling Industry Employment",
    title = "Pre-Treatment Trends by Cohort",
    subtitle = "Average state employment in NAICS 7132",
    color = "Treatment Cohort"
  ) +
  scale_color_viridis_d(option = "D", end = 0.85) +
  scale_y_continuous(labels = scales::comma) +
  theme_paper() +
  theme(legend.position = "right")

ggsave(file.path(fig_dir, "fig2_parallel_trends.pdf"), fig2,
       width = 9, height = 5, device = cairo_pdf)
ggsave(file.path(fig_dir, "fig2_parallel_trends.png"), fig2,
       width = 9, height = 5, dpi = 300)

message("  Saved: fig2_parallel_trends.pdf")

# -----------------------------------------------------------------------------
# Figure 3: Treatment Timing Map
# -----------------------------------------------------------------------------

message("Creating Figure 3: Treatment Map...")

# Prepare state data for map
# First get all states including Nevada
all_states <- tibble(state_abbr = c(state.abb, "DC"))

map_data <- analysis_sample %>%
  select(state_abbr, sb_year_quarter, ever_treated_sb) %>%
  distinct() %>%
  right_join(all_states, by = "state_abbr") %>%
  mutate(
    treatment_year = floor(sb_year_quarter),
    fill_category = case_when(
      state_abbr == "NV" ~ "Excluded (Always-Treated)",
      is.na(ever_treated_sb) | !ever_treated_sb ~ "Not Legalized (2024)",
      treatment_year == 2018 ~ "2018",
      treatment_year == 2019 ~ "2019",
      treatment_year == 2020 ~ "2020",
      treatment_year == 2021 ~ "2021",
      treatment_year == 2022 ~ "2022",
      treatment_year >= 2023 ~ "2023+"
    )
  )

# Get US state map data
if (requireNamespace("maps", quietly = TRUE)) {
  us_states <- map_data("state") %>%
    mutate(region = str_to_title(region))

  # State name to abbreviation lookup
  state_lookup <- tibble(
    region = state.name,
    state_abbr = state.abb
  ) %>%
    add_row(region = "District Of Columbia", state_abbr = "DC")

  map_plot_data <- us_states %>%
    left_join(state_lookup, by = "region") %>%
    left_join(map_data, by = "state_abbr")

  fig3 <- map_plot_data %>%
    ggplot(aes(x = long, y = lat, group = group, fill = fill_category)) +
    geom_polygon(color = "white", linewidth = 0.2) +
    coord_fixed(1.3) +
    scale_fill_viridis_d(option = "C", na.value = "gray80") +
    labs(
      title = "Sports Betting Legalization Timeline",
      subtitle = "Year of first legal sports bet by state",
      fill = "Treatment Year"
    ) +
    theme_void() +
    theme(
      legend.position = "bottom",
      plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
      plot.subtitle = element_text(size = 10, hjust = 0.5, color = "gray40")
    )

  ggsave(file.path(fig_dir, "fig3_treatment_map.pdf"), fig3,
         width = 10, height = 6, device = cairo_pdf)
  ggsave(file.path(fig_dir, "fig3_treatment_map.png"), fig3,
         width = 10, height = 6, dpi = 300)

  message("  Saved: fig3_treatment_map.pdf")
} else {
  message("  Skipping map (maps package not installed)")
}

# -----------------------------------------------------------------------------
# Figure 4: Heterogeneity by Mobile Betting
# -----------------------------------------------------------------------------

message("Creating Figure 4: Mobile vs Retail Heterogeneity...")

# Calculate means by mobile status and time
mobile_het <- analysis_sample %>%
  filter(ever_treated_sb) %>%
  mutate(
    mobile_status = if_else(has_mobile, "Mobile Betting", "Retail Only"),
    relative_year = year - floor(sb_year_quarter)
  ) %>%
  filter(relative_year >= -4, relative_year <= 4) %>%
  group_by(relative_year, mobile_status) %>%
  summarise(
    mean_empl = mean(empl_7132, na.rm = TRUE),
    se = sd(empl_7132, na.rm = TRUE) / sqrt(n()),
    n = n(),
    .groups = "drop"
  )

fig4 <- mobile_het %>%
  ggplot(aes(x = relative_year, y = mean_empl, color = mobile_status)) +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray50") +
  geom_ribbon(aes(ymin = mean_empl - 1.96 * se,
                  ymax = mean_empl + 1.96 * se,
                  fill = mobile_status),
              alpha = 0.2, color = NA) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  labs(
    x = "Years Since Legalization",
    y = "Mean Gambling Industry Employment",
    title = "Employment Effects by Betting Type",
    subtitle = "States with mobile betting vs retail-only",
    color = NULL, fill = NULL
  ) +
  scale_color_manual(values = c("Mobile Betting" = "#2166ac", "Retail Only" = "#b2182b")) +
  scale_fill_manual(values = c("Mobile Betting" = "#2166ac", "Retail Only" = "#b2182b")) +
  scale_y_continuous(labels = scales::comma) +
  theme_paper() +
  theme(legend.position = c(0.15, 0.85))

ggsave(file.path(fig_dir, "fig4_mobile_heterogeneity.pdf"), fig4,
       width = 8, height = 5, device = cairo_pdf)
ggsave(file.path(fig_dir, "fig4_mobile_heterogeneity.png"), fig4,
       width = 8, height = 5, dpi = 300)

message("  Saved: fig4_mobile_heterogeneity.pdf")

# -----------------------------------------------------------------------------
# Figure 5: Robustness Summary
# -----------------------------------------------------------------------------

message("Creating Figure 5: Robustness Summary...")

robustness_results <- readRDS("../data/robustness_results.rds")

robustness_plot_data <- tibble(
  specification = c(
    "Main Result",
    "Exclude 2020-2021",
    "Exclude PASPA States",
    "Exclude iGaming States",
    "TWFE Comparison"
  ),
  att = c(
    main_results$overall$att,
    robustness_results$covid_sensitivity$exclude_2020_2021$att,
    robustness_results$paspa_sensitivity$exclude_de_mt_or$att,
    robustness_results$igaming_sensitivity$exclude_igaming$att,
    main_results$twfe_comparison$att
  ),
  se = c(
    main_results$overall$se,
    robustness_results$covid_sensitivity$exclude_2020_2021$se,
    robustness_results$paspa_sensitivity$exclude_de_mt_or$se,
    robustness_results$igaming_sensitivity$exclude_igaming$se,
    main_results$twfe_comparison$se
  )
) %>%
  mutate(
    ci_low = att - 1.96 * se,
    ci_high = att + 1.96 * se,
    specification = factor(specification, levels = rev(specification))
  )

fig5 <- robustness_plot_data %>%
  ggplot(aes(x = att, y = specification)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = main_results$overall$att,
             linetype = "dotted", color = "steelblue", alpha = 0.5) +
  geom_errorbarh(aes(xmin = ci_low, xmax = ci_high),
                 height = 0.2, color = "gray40") +
  geom_point(size = 3, color = "steelblue") +
  labs(
    x = "Effect on Gambling Industry Employment",
    y = NULL,
    title = "Robustness of Main Result",
    subtitle = "95% confidence intervals across specifications"
  ) +
  scale_x_continuous(labels = scales::comma) +
  theme_paper() +
  theme(
    axis.text.y = element_text(size = 10),
    panel.grid.major.y = element_blank()
  )

ggsave(file.path(fig_dir, "fig5_robustness.pdf"), fig5,
       width = 8, height = 4, device = cairo_pdf)
ggsave(file.path(fig_dir, "fig5_robustness.png"), fig5,
       width = 8, height = 4, dpi = 300)

message("  Saved: fig5_robustness.pdf")

# -----------------------------------------------------------------------------
# Figure 6: Leave-One-Out Sensitivity
# -----------------------------------------------------------------------------

message("Creating Figure 6: Leave-One-Out...")

loo_results <- read_csv("../data/leave_one_out.csv", show_col_types = FALSE)

fig6 <- loo_results %>%
  filter(!is.na(att)) %>%
  mutate(dropped_state = fct_reorder(dropped_state, att)) %>%
  ggplot(aes(x = att, y = dropped_state)) +
  geom_vline(xintercept = main_results$overall$att,
             linetype = "solid", color = "steelblue", linewidth = 1) +
  geom_vline(xintercept = main_results$overall$att - 1.96 * main_results$overall$se,
             linetype = "dashed", color = "steelblue", alpha = 0.5) +
  geom_vline(xintercept = main_results$overall$att + 1.96 * main_results$overall$se,
             linetype = "dashed", color = "steelblue", alpha = 0.5) +
  geom_point(size = 2, color = "gray30") +
  labs(
    x = "ATT Estimate (Excluding State)",
    y = "Dropped State",
    title = "Leave-One-Out Sensitivity",
    subtitle = "Vertical line shows main estimate; dashed lines show 95% CI"
  ) +
  scale_x_continuous(labels = scales::comma) +
  theme_paper() +
  theme(panel.grid.major.y = element_blank())

ggsave(file.path(fig_dir, "fig6_leave_one_out.pdf"), fig6,
       width = 7, height = 6, device = cairo_pdf)
ggsave(file.path(fig_dir, "fig6_leave_one_out.png"), fig6,
       width = 7, height = 6, dpi = 300)

message("  Saved: fig6_leave_one_out.pdf")

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------

message("\n", paste(rep("=", 60), collapse = ""))
message("All figures saved to: ", fig_dir)
message(paste(rep("=", 60), collapse = ""))

list.files(fig_dir, pattern = "\\.(pdf|png)$")
