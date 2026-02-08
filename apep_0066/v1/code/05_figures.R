# =============================================================================
# 05_figures.R - Generate Figures
# Paper 85: Paid Family Leave and Female Entrepreneurship
# =============================================================================

source("00_packages.R")

# -----------------------------------------------------------------------------
# Load Data and Results
# -----------------------------------------------------------------------------

df <- readRDS("../data/analysis_data.rds")
cs_results <- readRDS("../data/cs_results.rds")

message("Generating figures...")

# -----------------------------------------------------------------------------
# Figure 1: Map of PFL Adoption
# -----------------------------------------------------------------------------

message("Creating Figure 1: Policy adoption map...")

# Get state boundaries
states_sf <- states(cb = TRUE, year = 2020) %>%
  filter(!STATEFP %in% c("02", "15", "60", "66", "69", "72", "78")) %>%
  st_transform(crs = "EPSG:5070")  # Albers Equal Area for US

# Create policy data
policy_map_data <- tibble(
  STUSPS = c("CA", "NJ", "RI", "NY", "WA", "DC", "MA", "CT", "OR", "CO"),
  first_full_year = c(2005, 2010, 2014, 2018, 2020, 2021, 2021, 2022, 2024, 2024)
)

# Join to spatial data
states_policy <- states_sf %>%
  left_join(policy_map_data, by = "STUSPS") %>%
  mutate(
    treatment_status = case_when(
      first_full_year <= 2010 ~ "Early (2005-2010)",
      first_full_year <= 2018 ~ "Middle (2014-2018)",
      first_full_year <= 2022 ~ "Recent (2020-2022)",
      first_full_year >= 2023 ~ "Very Recent (2023+)",
      TRUE ~ "Never Adopted"
    ),
    treatment_status = factor(treatment_status, levels = c(
      "Early (2005-2010)", "Middle (2014-2018)",
      "Recent (2020-2022)", "Very Recent (2023+)", "Never Adopted"
    ))
  )

# Create map
p1 <- ggplot(states_policy) +
  geom_sf(aes(fill = treatment_status), color = "white", linewidth = 0.3) +
  scale_fill_manual(
    name = "PFL Adoption",
    values = c(
      "Early (2005-2010)" = "#0072B2",
      "Middle (2014-2018)" = "#56B4E9",
      "Recent (2020-2022)" = "#009E73",
      "Very Recent (2023+)" = "#F0E442",
      "Never Adopted" = "grey85"
    ),
    na.value = "grey85"
  ) +
  labs(
    title = "Staggered Adoption of State Paid Family Leave",
    subtitle = "First full year of benefit availability",
    caption = "Source: Department of Labor (2024)"
  ) +
  theme_void() +
  theme(
    legend.position = "bottom",
    legend.key.width = unit(0.8, "cm"),
    plot.title = element_text(size = 13, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 10, color = "grey40", hjust = 0.5),
    plot.caption = element_text(size = 8, color = "grey50", hjust = 1),
    plot.margin = margin(10, 10, 10, 10)
  )

ggsave("../figures/fig1_policy_map.pdf", p1, width = 10, height = 7)
ggsave("../figures/fig1_policy_map.png", p1, width = 10, height = 7, dpi = 300)

# -----------------------------------------------------------------------------
# Figure 2: Parallel Trends
# -----------------------------------------------------------------------------

message("Creating Figure 2: Parallel trends...")

# Calculate mean self-employment by treatment status and year
trends_data <- df %>%
  mutate(group = ifelse(treated, "PFL States", "Non-PFL States")) %>%
  group_by(year, group) %>%
  summarise(
    mean_se = mean(female_selfempl_rate, na.rm = TRUE),
    se_se = sd(female_selfempl_rate, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  )

# Shade region for treatment rollout
treatment_region <- data.frame(
  xmin = 2005, xmax = 2024,
  ymin = -Inf, ymax = Inf
)

p2 <- ggplot(trends_data, aes(x = year, y = mean_se, color = group)) +
  # Confidence ribbons
  geom_ribbon(aes(ymin = mean_se - 1.96*se_se, ymax = mean_se + 1.96*se_se, fill = group),
              alpha = 0.15, color = NA) +
  # Lines
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  # First treatment year
  geom_vline(xintercept = 2005, linetype = "dashed", color = "grey50", linewidth = 0.5) +
  annotate("text", x = 2005.5, y = 8.5, label = "CA PFL\n(2005)",
           hjust = 0, size = 2.5, color = "grey40") +
  # Colors
  scale_color_manual(name = "", values = c("PFL States" = apep_colors[1],
                                            "Non-PFL States" = apep_colors[2])) +
  scale_fill_manual(name = "", values = c("PFL States" = apep_colors[1],
                                           "Non-PFL States" = apep_colors[2])) +
  # Labels
  labs(
    title = "Female Self-Employment Rates: PFL vs Non-PFL States",
    subtitle = "Mean rates with 95% confidence intervals",
    x = "Year",
    y = "Female Self-Employment Rate (%)",
    caption = "Note: Dashed line indicates first state adoption (California, 2005). Year 2020 omitted (COVID)."
  ) +
  theme_apep() +
  scale_x_continuous(breaks = seq(2005, 2023, 2)) +
  theme(legend.position = c(0.85, 0.9))

ggsave("../figures/fig2_parallel_trends.pdf", p2, width = 9, height = 5)
ggsave("../figures/fig2_parallel_trends.png", p2, width = 9, height = 5, dpi = 300)

# -----------------------------------------------------------------------------
# Figure 3: Event Study
# -----------------------------------------------------------------------------

message("Creating Figure 3: Event study...")

# Extract event study data from CS results
es_data <- data.frame(
  time = cs_results$att_dynamic$egt,
  att = cs_results$att_dynamic$att.egt,
  se = cs_results$att_dynamic$se.egt
) %>%
  filter(!is.na(se))  # Remove base period

p3 <- ggplot(es_data, aes(x = time, y = att)) +
  # Confidence interval
  geom_ribbon(aes(ymin = att - 1.96*se, ymax = att + 1.96*se),
              alpha = 0.2, fill = apep_colors[1]) +
  # Point estimates
  geom_point(color = apep_colors[1], size = 2.5) +
  geom_line(color = apep_colors[1], linewidth = 0.7) +
  # Reference lines
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40", linewidth = 0.5) +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60", linewidth = 0.5) +
  # Labels
  labs(
    title = "Event Study: Effect of Paid Family Leave on Female Self-Employment",
    subtitle = "Callaway-Sant'Anna estimator, 95% confidence intervals",
    x = "Years Relative to PFL Implementation",
    y = "ATT (Percentage Points)",
    caption = "Note: Reference period is t = -1. Control group: never-treated states."
  ) +
  theme_apep() +
  scale_x_continuous(breaks = seq(-5, 5, 1))

ggsave("../figures/fig3_event_study.pdf", p3, width = 9, height = 5)
ggsave("../figures/fig3_event_study.png", p3, width = 9, height = 5, dpi = 300)

# -----------------------------------------------------------------------------
# Figure 4: Heterogeneity by Cohort
# -----------------------------------------------------------------------------

message("Creating Figure 4: Heterogeneity by cohort...")

# Extract cohort-specific ATTs
cohort_data <- data.frame(
  cohort = cs_results$att_group$egt,
  att = cs_results$att_group$att.egt,
  se = cs_results$att_group$se.egt
) %>%
  mutate(
    cohort_label = as.character(cohort),
    sig = ifelse(abs(att/se) > 1.96, "Significant", "Not Significant")
  )

p4 <- ggplot(cohort_data, aes(x = reorder(cohort_label, cohort), y = att)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_errorbar(aes(ymin = att - 1.96*se, ymax = att + 1.96*se),
                width = 0.2, color = "grey50") +
  geom_point(aes(color = sig), size = 3) +
  scale_color_manual(name = "", values = c("Significant" = apep_colors[1],
                                            "Not Significant" = "grey60")) +
  labs(
    title = "Treatment Effects by Adoption Cohort",
    subtitle = "Callaway-Sant'Anna group-specific ATTs",
    x = "Treatment Cohort (First Full Year)",
    y = "ATT (Percentage Points)",
    caption = "Note: Error bars show 95% confidence intervals."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave("../figures/fig4_cohort_heterogeneity.pdf", p4, width = 8, height = 5)
ggsave("../figures/fig4_cohort_heterogeneity.png", p4, width = 8, height = 5, dpi = 300)

# -----------------------------------------------------------------------------
# Save All Figures as Combined PDF
# -----------------------------------------------------------------------------

message("Combining figures...")

# Combine into multi-panel figure
p_combined <- (p1 | p2) / (p3 | p4) +
  plot_annotation(
    title = "Paid Family Leave and Female Self-Employment",
    theme = theme(plot.title = element_text(size = 16, face = "bold"))
  )

ggsave("../figures/all_figures_combined.pdf", p_combined, width = 16, height = 12)

message("\nAll figures saved to figures/")
message("  - fig1_policy_map.pdf")
message("  - fig2_parallel_trends.pdf")
message("  - fig3_event_study.pdf")
message("  - fig4_cohort_heterogeneity.pdf")
message("  - all_figures_combined.pdf")
