# =============================================================================
# 06_figures.R
# Generate Publication-Quality Figures
# Paper 117: Sports Betting Employment Effects
# =============================================================================

source("00_packages.R")

# =============================================================================
# Load Results
# =============================================================================

message("Loading results...")
main_results <- readRDS("../data/main_results.rds")
robustness_results <- readRDS("../data/robustness_results.rds")
event_coefs <- read_csv("../data/event_study_coefficients.csv", show_col_types = FALSE)
analysis_df <- read_csv("../data/analysis_sample.csv", show_col_types = FALSE)
loo_results <- read_csv("../data/leave_one_out.csv", show_col_types = FALSE)

# =============================================================================
# Figure 1: Event Study
# =============================================================================

message("\nCreating Figure 1: Event Study...")

fig1 <- ggplot(event_coefs, aes(x = event_time, y = att)) +
  # Reference line at zero
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  # Vertical line at treatment
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "gray30") +
  # Confidence intervals
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, fill = "steelblue") +
  # Point estimates
  geom_point(size = 3, color = "steelblue") +
  geom_line(color = "steelblue", linewidth = 0.8) +
  # Labels
  labs(
    x = "Years Relative to Sports Betting Legalization",
    y = "ATT (Log Employment)",
    title = "Event Study: Effect of Sports Betting on Gambling Employment",
    subtitle = "Callaway-Sant'Anna (2021) estimator with not-yet-treated controls"
  ) +
  scale_x_continuous(breaks = seq(-6, 5, by = 1)) +
  theme(
    plot.title = element_text(size = 12, face = "bold"),
    plot.subtitle = element_text(size = 10, color = "gray40")
  )

ggsave("../figures/fig1_event_study.pdf", fig1, width = 8, height = 5.5)
ggsave("../figures/fig1_event_study.png", fig1, width = 8, height = 5.5, dpi = 300)
message("Saved: fig1_event_study.pdf/png")

# =============================================================================
# Figure 2: Parallel Trends (Raw Data)
# =============================================================================

message("\nCreating Figure 2: Parallel Trends...")

# Calculate mean log employment by treatment status and year
trends_data <- analysis_df %>%
  mutate(ever_treated = g > 0) %>%
  group_by(year, ever_treated) %>%
  summarise(
    mean_log_empl = mean(log_employment, na.rm = TRUE),
    se = sd(log_employment, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  ) %>%
  mutate(
    group = if_else(ever_treated, "Eventually Treated", "Never Treated"),
    ci_lower = mean_log_empl - 1.96 * se,
    ci_upper = mean_log_empl + 1.96 * se
  )

fig2 <- ggplot(trends_data, aes(x = year, y = mean_log_empl, color = group, fill = group)) +
  # Pre-treatment shading
  annotate("rect", xmin = -Inf, xmax = 2017.5, ymin = -Inf, ymax = Inf,
           fill = "gray90", alpha = 0.5) +
  # Murphy v. NCAA line
  geom_vline(xintercept = 2018, linetype = "dashed", color = "gray40") +
  annotate("text", x = 2018.2, y = max(trends_data$mean_log_empl),
           label = "Murphy v. NCAA", hjust = 0, size = 3, color = "gray40") +
  # Trends with CI
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, color = NA) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  # Styling
  scale_color_manual(values = c("Eventually Treated" = "steelblue", "Never Treated" = "coral")) +
  scale_fill_manual(values = c("Eventually Treated" = "steelblue", "Never Treated" = "coral")) +
  labs(
    x = "Year",
    y = "Mean Log Employment (NAICS 7132)",
    title = "Pre-Treatment Trends in Gambling Employment",
    subtitle = "Treated vs. control states before sports betting legalization",
    color = NULL, fill = NULL
  ) +
  theme(
    legend.position = c(0.15, 0.85),
    legend.background = element_rect(fill = "white", color = "gray80")
  )

ggsave("../figures/fig2_parallel_trends.pdf", fig2, width = 8, height = 5.5)
ggsave("../figures/fig2_parallel_trends.png", fig2, width = 8, height = 5.5, dpi = 300)
message("Saved: fig2_parallel_trends.pdf/png")

# =============================================================================
# Figure 3: Treatment Timing Map
# =============================================================================

message("\nCreating Figure 3: Treatment Timing Map...")

# Load US map data
if (!requireNamespace("maps", quietly = TRUE)) {
  message("  Installing 'maps' package...")
  install.packages("maps", quiet = TRUE)
}

us_map <- map_data("state")

# Prepare state data for mapping
policy_data <- analysis_df %>%
  select(state_abbr, g) %>%
  distinct() %>%
  mutate(
    state_name = tolower(state.name[match(state_abbr, state.abb)]),
    treatment_cohort = case_when(
      g == 0 ~ "Not Legalized",
      g <= 2018 ~ "2018",
      g == 2019 ~ "2019",
      g == 2020 ~ "2020",
      g == 2021 ~ "2021",
      g == 2022 ~ "2022",
      g >= 2023 ~ "2023+"
    )
  ) %>%
  filter(!is.na(state_name))

map_data_merged <- us_map %>%
  left_join(policy_data, by = c("region" = "state_name"))

fig3 <- ggplot(map_data_merged, aes(x = long, y = lat, group = group, fill = treatment_cohort)) +
  geom_polygon(color = "white", linewidth = 0.2) +
  scale_fill_manual(
    values = c(
      "Not Legalized" = "gray80",
      "2018" = "#08519c",
      "2019" = "#3182bd",
      "2020" = "#6baed6",
      "2021" = "#9ecae1",
      "2022" = "#c6dbef",
      "2023+" = "#eff3ff"
    ),
    na.value = "gray95",
    na.translate = FALSE
  ) +
  coord_fixed(1.3) +
  labs(
    title = "Sports Betting Legalization by Year",
    subtitle = "Staggered adoption following Murphy v. NCAA (May 2018)",
    fill = "Legalization Year"
  ) +
  theme_void() +
  theme(
    plot.title = element_text(size = 12, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 10, color = "gray40", hjust = 0.5),
    legend.position = "bottom"
  )

ggsave("../figures/fig3_treatment_map.pdf", fig3, width = 10, height = 6)
ggsave("../figures/fig3_treatment_map.png", fig3, width = 10, height = 6, dpi = 300)
message("Saved: fig3_treatment_map.pdf/png")

# =============================================================================
# Figure 4: Robustness Summary
# =============================================================================

message("\nCreating Figure 4: Robustness Summary...")

robust_data <- robustness_results$summary %>%
  filter(!is.na(att)) %>%  # Remove rows with NA (e.g., never-treated controls)
  mutate(
    specification = factor(specification, levels = rev(specification))
  )

fig4 <- ggplot(robust_data, aes(x = att, y = specification)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
  # Main estimate reference
  geom_vline(xintercept = robust_data$att[1], linetype = "dotted", color = "steelblue", alpha = 0.5) +
  # Confidence intervals
  geom_errorbarh(aes(xmin = ci_lower, xmax = ci_upper), height = 0.2, color = "gray40") +
  # Point estimates
  geom_point(size = 3, color = "steelblue") +
  labs(
    x = "ATT (Log Employment)",
    y = NULL,
    title = "Robustness of Main Results",
    subtitle = "Alternative specifications and sample restrictions"
  ) +
  theme(
    plot.title = element_text(size = 12, face = "bold"),
    axis.text.y = element_text(size = 10)
  )

ggsave("../figures/fig4_robustness.pdf", fig4, width = 8, height = 5)
ggsave("../figures/fig4_robustness.png", fig4, width = 8, height = 5, dpi = 300)
message("Saved: fig4_robustness.pdf/png")

# =============================================================================
# Figure 5: Leave-One-Out Analysis
# =============================================================================

message("\nCreating Figure 5: Leave-One-Out...")

# Main estimate for reference
main_att <- main_results$cs_overall$overall.att
main_se <- main_results$cs_overall$overall.se

fig5 <- ggplot(loo_results %>% filter(!is.na(att)), aes(x = reorder(excluded_state, att), y = att)) +
  # Main estimate reference band
  geom_hline(yintercept = main_att, color = "steelblue", linewidth = 1) +
  geom_hline(yintercept = main_att - 1.96*main_se, color = "steelblue", linetype = "dashed", alpha = 0.5) +
  geom_hline(yintercept = main_att + 1.96*main_se, color = "steelblue", linetype = "dashed", alpha = 0.5) +
  geom_hline(yintercept = 0, linetype = "dotted", color = "gray50") +
  # Leave-one-out estimates
  geom_errorbar(aes(ymin = att - 1.96*se, ymax = att + 1.96*se), width = 0.3, color = "gray40") +
  geom_point(size = 2, color = "coral") +
  labs(
    x = "Excluded State",
    y = "ATT (Log Employment)",
    title = "Leave-One-Out Analysis",
    subtitle = "Horizontal line = main estimate; no single state drives the result"
  ) +
  coord_flip() +
  theme(
    plot.title = element_text(size = 12, face = "bold"),
    axis.text.y = element_text(size = 8)
  )

ggsave("../figures/fig5_leave_one_out.pdf", fig5, width = 8, height = 8)
ggsave("../figures/fig5_leave_one_out.png", fig5, width = 8, height = 8, dpi = 300)
message("Saved: fig5_leave_one_out.pdf/png")

# =============================================================================
# Summary
# =============================================================================

message("\n", paste(rep("=", 70), collapse = ""))
message("FIGURES COMPLETE")
message(paste(rep("=", 70), collapse = ""))

message("\nFigures created:")
message("  fig1_event_study.pdf/png    - Event study coefficients")
message("  fig2_parallel_trends.pdf/png - Pre-treatment trends")
message("  fig3_treatment_map.pdf/png  - Geographic adoption timing")
message("  fig4_robustness.pdf/png     - Robustness summary")
message("  fig5_leave_one_out.pdf/png  - Leave-one-out analysis")
