# =============================================================================
# 05_figures.R
# Publication-Quality Figures for Auto-IRA Paper
# =============================================================================

source("00_packages.R")

# -----------------------------------------------------------------------------
# Load Data and Results
# -----------------------------------------------------------------------------

cat("Loading data and results...\n")

df <- readRDS(file.path(data_dir, "cps_asec_clean.rds"))
cs_out <- readRDS(file.path(data_dir, "cs_results.rds"))
cs_dynamic <- readRDS(file.path(data_dir, "cs_dynamic.rds"))
es_coefs <- read_csv(file.path(data_dir, "event_study_coefs.csv"),
                     show_col_types = FALSE)
treatment_data <- read_csv(file.path(data_dir, "treatment_data.csv"),
                           show_col_types = FALSE)

# -----------------------------------------------------------------------------
# FIGURE 1: Policy Adoption Map
# -----------------------------------------------------------------------------

cat("\nCreating Figure 1: Policy adoption map...\n")

# Get US states shapefile
states_sf <- states(cb = TRUE) %>%
  filter(!STATEFP %in% c("02", "15", "72", "78", "60", "66", "69")) %>%  # Lower 48
  mutate(statefip = as.numeric(STATEFP))

# Join treatment data
states_policy <- states_sf %>%
  left_join(treatment_data %>% select(statefip, first_treat_year), by = "statefip")

# Create adoption categories
states_policy <- states_policy %>%
  mutate(
    adoption_status = case_when(
      first_treat_year <= 2018 ~ "Early Adopter (2017-2018)",
      first_treat_year %in% 2019:2021 ~ "Middle Adopter (2019-2021)",
      first_treat_year >= 2022 ~ "Recent Adopter (2022-2024)",
      TRUE ~ "No Mandate"
    ),
    adoption_status = factor(adoption_status, levels = c(
      "Early Adopter (2017-2018)",
      "Middle Adopter (2019-2021)",
      "Recent Adopter (2022-2024)",
      "No Mandate"
    ))
  )

fig1 <- ggplot(states_policy) +
  geom_sf(aes(fill = adoption_status), color = "white", linewidth = 0.3) +
  scale_fill_manual(
    name = "Auto-IRA Mandate Status",
    values = c(
      "Early Adopter (2017-2018)" = "#0072B2",
      "Middle Adopter (2019-2021)" = "#56B4E9",
      "Recent Adopter (2022-2024)" = "#D55E00",
      "No Mandate" = "grey85"
    )
  ) +
  labs(
    title = "State Automatic IRA Mandate Adoption, 2017-2024",
    subtitle = "Staggered rollout of mandatory retirement savings programs for employers without plans",
    caption = "Note: Early adopters include Oregon (2017), Illinois (2018). Middle adopters include California (2019), Connecticut (2021).\nRecent adopters include Maryland, Colorado, Virginia, Maine, Delaware, New Jersey, Vermont (2022-2024)."
  ) +
  theme_void() +
  theme(
    legend.position = "bottom",
    legend.key.size = unit(0.8, "cm"),
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "grey40"),
    plot.caption = element_text(size = 8, hjust = 0, color = "grey50"),
    plot.margin = margin(10, 10, 10, 10)
  )

ggsave(file.path(fig_dir, "fig1_adoption_map.pdf"), fig1, width = 10, height = 7)
ggsave(file.path(fig_dir, "fig1_adoption_map.png"), fig1, width = 10, height = 7, dpi = 300)
cat("Saved: fig1_adoption_map.pdf\n")

# -----------------------------------------------------------------------------
# FIGURE 2: Parallel Trends
# -----------------------------------------------------------------------------

cat("\nCreating Figure 2: Parallel trends...\n")

# Collapse to state-year for treated vs never-treated
df_trends <- df %>%
  mutate(
    treated_group = ifelse(first_treat > 0, "Will Be Treated", "Never Treated")
  ) %>%
  group_by(year, treated_group) %>%
  summarise(
    pension_rate = weighted.mean(has_pension, weight, na.rm = TRUE),
    se = sqrt(weighted.mean((has_pension - pension_rate)^2, weight, na.rm = TRUE) / n()),
    n = n(),
    .groups = "drop"
  )

# First treatment year for vertical line
first_treat_year <- min(treatment_data$first_treat_year)

fig2 <- ggplot(df_trends, aes(x = year, y = pension_rate, color = treated_group)) +
  geom_ribbon(aes(ymin = pension_rate - 1.96*se, ymax = pension_rate + 1.96*se,
                  fill = treated_group), alpha = 0.2, color = NA) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  geom_vline(xintercept = first_treat_year - 0.5, linetype = "dashed", color = "grey40") +
  annotate("text", x = first_treat_year - 0.3, y = max(df_trends$pension_rate) * 1.02,
           label = "First\nMandate", hjust = 0, size = 3, color = "grey40") +
  scale_color_manual(values = c("Will Be Treated" = apep_colors[1],
                                 "Never Treated" = apep_colors[2]),
                     name = "") +
  scale_fill_manual(values = c("Will Be Treated" = apep_colors[1],
                                "Never Treated" = apep_colors[2]),
                    guide = "none") +
  scale_x_continuous(breaks = seq(2010, 2024, 2)) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  labs(
    title = "Retirement Plan Coverage: Treated vs. Never-Treated States",
    subtitle = "Private-sector workers ages 18-64, weighted by ASEC weights",
    x = "Year",
    y = "Retirement Plan Coverage Rate",
    caption = "Note: Shaded areas show 95% confidence intervals. Dashed line indicates first state mandate (Oregon, 2017)."
  ) +
  theme_apep() +
  theme(legend.position = c(0.15, 0.9))

ggsave(file.path(fig_dir, "fig2_parallel_trends.pdf"), fig2, width = 9, height = 6)
ggsave(file.path(fig_dir, "fig2_parallel_trends.png"), fig2, width = 9, height = 6, dpi = 300)
cat("Saved: fig2_parallel_trends.pdf\n")

# -----------------------------------------------------------------------------
# FIGURE 3: Event Study (Main Result)
# -----------------------------------------------------------------------------

cat("\nCreating Figure 3: Event study...\n")

fig3 <- ggplot(es_coefs, aes(x = event_time, y = att)) +
  # Confidence interval ribbon
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper),
              alpha = 0.2, fill = apep_colors[1]) +
  # Point estimates and line
  geom_point(color = apep_colors[1], size = 3) +
  geom_line(color = apep_colors[1], linewidth = 0.8) +
  # Reference lines
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40", linewidth = 0.5) +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60", linewidth = 0.5) +
  # Annotations
  annotate("text", x = -3, y = max(es_coefs$ci_upper, na.rm = TRUE) * 0.9,
           label = "Pre-treatment\n(parallel trends test)", hjust = 0.5, size = 3, color = "grey40") +
  annotate("text", x = 2, y = max(es_coefs$ci_upper, na.rm = TRUE) * 0.9,
           label = "Post-treatment\n(causal effect)", hjust = 0.5, size = 3, color = "grey40") +
  # Scales
  scale_x_continuous(breaks = seq(-5, 5, 1)) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
  labs(
    title = "Effect of Auto-IRA Mandates on Retirement Plan Coverage",
    subtitle = "Callaway-Sant'Anna (2021) estimator, event study specification",
    x = "Years Relative to Mandate Implementation",
    y = "Effect on Coverage Rate (ATT)",
    caption = "Note: Points show estimated ATT by event time. Shaded region shows 95% confidence interval.\nClustered standard errors at state level. Reference period is t = -1."
  ) +
  theme_apep()

ggsave(file.path(fig_dir, "fig3_event_study.pdf"), fig3, width = 9, height = 6)
ggsave(file.path(fig_dir, "fig3_event_study.png"), fig3, width = 9, height = 6, dpi = 300)
cat("Saved: fig3_event_study.pdf\n")

# -----------------------------------------------------------------------------
# FIGURE 4: Heterogeneity by Firm Size
# -----------------------------------------------------------------------------

cat("\nCreating Figure 4: Heterogeneity...\n")

# Load heterogeneity results if they exist
if (file.exists(file.path(data_dir, "cs_small_firms.rds")) &&
    file.exists(file.path(data_dir, "cs_placebo_large.rds"))) {

  cs_small <- readRDS(file.path(data_dir, "cs_small_firms.rds"))
  cs_large <- readRDS(file.path(data_dir, "cs_placebo_large.rds"))

  agg_small <- aggte(cs_small, type = "dynamic", min_e = -4, max_e = 4)
  agg_large <- aggte(cs_large, type = "dynamic", min_e = -4, max_e = 4)

  het_data <- bind_rows(
    data.frame(
      event_time = agg_small$egt,
      att = agg_small$att.egt,
      se = agg_small$se.egt,
      group = "Small Firms (<100 employees)"
    ),
    data.frame(
      event_time = agg_large$egt,
      att = agg_large$att.egt,
      se = agg_large$se.egt,
      group = "Large Firms (100+ employees)"
    )
  ) %>%
    mutate(
      ci_lower = att - 1.96 * se,
      ci_upper = att + 1.96 * se
    )

  fig4 <- ggplot(het_data, aes(x = event_time, y = att, color = group, fill = group)) +
    geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.15, color = NA) +
    geom_line(linewidth = 0.8) +
    geom_point(size = 2.5) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
    geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
    scale_color_manual(values = c("Small Firms (<100 employees)" = apep_colors[1],
                                   "Large Firms (100+ employees)" = apep_colors[2]),
                       name = "") +
    scale_fill_manual(values = c("Small Firms (<100 employees)" = apep_colors[1],
                                  "Large Firms (100+ employees)" = apep_colors[2]),
                      guide = "none") +
    scale_x_continuous(breaks = seq(-4, 4, 1)) +
    scale_y_continuous(labels = scales::percent_format(accuracy = 0.1)) +
    labs(
      title = "Heterogeneous Effects by Employer Size",
      subtitle = "Auto-IRA mandates primarily target small employers without existing plans",
      x = "Years Relative to Mandate Implementation",
      y = "Effect on Coverage Rate (ATT)",
      caption = "Note: Large firms serve as placebo test. Effect should be concentrated among small firms."
    ) +
    theme_apep() +
    theme(legend.position = c(0.25, 0.85))

  ggsave(file.path(fig_dir, "fig4_heterogeneity.pdf"), fig4, width = 9, height = 6)
  ggsave(file.path(fig_dir, "fig4_heterogeneity.png"), fig4, width = 9, height = 6, dpi = 300)
  cat("Saved: fig4_heterogeneity.pdf\n")

} else {
  cat("Heterogeneity results not found. Run 04_robustness.R first.\n")
}

# -----------------------------------------------------------------------------
# FIGURE 5: Robustness Comparison
# -----------------------------------------------------------------------------

cat("\nCreating Figure 5: Robustness comparison...\n")

if (file.exists(file.path(data_dir, "robustness_summary.csv"))) {

  robust_df <- read_csv(file.path(data_dir, "robustness_summary.csv"),
                        show_col_types = FALSE) %>%
    filter(!is.na(ATT)) %>%
    mutate(
      Specification = factor(Specification, levels = rev(Specification))
    )

  fig5 <- ggplot(robust_df, aes(x = ATT, y = Specification)) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
    geom_errorbarh(aes(xmin = CI_Lower, xmax = CI_Upper),
                   height = 0.2, color = apep_colors[1], linewidth = 0.8) +
    geom_point(size = 3, color = apep_colors[1]) +
    scale_x_continuous(labels = scales::percent_format(accuracy = 0.1)) +
    labs(
      title = "Robustness of Main Results Across Specifications",
      subtitle = "All estimates use Callaway-Sant'Anna (2021) estimator",
      x = "ATT on Retirement Plan Coverage",
      y = "",
      caption = "Note: Horizontal bars show 95% confidence intervals. Placebo test uses workers at large firms."
    ) +
    theme_apep() +
    theme(
      axis.text.y = element_text(size = 10),
      panel.grid.major.y = element_blank()
    )

  ggsave(file.path(fig_dir, "fig5_robustness.pdf"), fig5, width = 9, height = 5)
  ggsave(file.path(fig_dir, "fig5_robustness.png"), fig5, width = 9, height = 5, dpi = 300)
  cat("Saved: fig5_robustness.pdf\n")

} else {
  cat("Robustness summary not found. Run 04_robustness.R first.\n")
}

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------

cat("\n", rep("=", 60), "\n")
cat("FIGURES COMPLETE\n")
cat(rep("=", 60), "\n")

cat("\nFigures saved to:", fig_dir, "\n")
cat("- fig1_adoption_map.pdf: Geographic variation in policy adoption\n")
cat("- fig2_parallel_trends.pdf: Pre-treatment outcome trends\n")
cat("- fig3_event_study.pdf: Main result - dynamic treatment effects\n")
cat("- fig4_heterogeneity.pdf: Effects by firm size\n")
cat("- fig5_robustness.pdf: Robustness across specifications\n")
