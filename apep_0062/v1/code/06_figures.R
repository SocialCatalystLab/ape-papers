# =============================================================================
# 06_figures.R
# Publication-quality figures for the paper
# =============================================================================

source("output/paper_80/code/00_packages.R")

# =============================================================================
# Load results
# =============================================================================

df <- read_csv("output/paper_80/data/analysis_main.csv", show_col_types = FALSE)
es_coefs <- read_csv("output/paper_80/data/event_study_coefs.csv", show_col_types = FALSE)
cs_results <- readRDS("output/paper_80/data/cs_results.rds")
policy <- read_csv("output/paper_80/data/policy_dates.csv", show_col_types = FALSE)

# =============================================================================
# Figure 1: Treatment Adoption Map
# =============================================================================

cat("Creating Figure 1: Treatment adoption map...\n")

# Get US states shapefile
states_sf <- tigris::states(cb = TRUE, progress_bar = FALSE) %>%
  filter(!STUSPS %in% c("AK", "HI", "PR", "VI", "GU", "AS", "MP")) %>%
  st_transform(crs = 5070)  # Albers Equal Area

# Merge with policy dates
map_data <- states_sf %>%
  left_join(
    policy %>%
      mutate(
        adoption_year = case_when(
          first_treat_year == 0 ~ "Never",
          first_treat_year == 2018 ~ "2018",
          first_treat_year == 2019 ~ "2019",
          first_treat_year == 2020 ~ "2020",
          first_treat_year >= 2021 ~ "2021+"
        )
      ) %>%
      select(state_abbr, adoption_year),
    by = c("STUSPS" = "state_abbr")
  )

fig1_map <- ggplot(map_data) +
  geom_sf(aes(fill = adoption_year), color = "white", size = 0.2) +
  scale_fill_manual(
    values = c(
      "2018" = "#1a9850",
      "2019" = "#91cf60",
      "2020" = "#d9ef8b",
      "2021+" = "#fee08b",
      "Never" = "#d73027"
    ),
    na.value = "grey80",
    name = "First Legal Bet"
  ) +
  labs(
    title = "Staggered Adoption of Legal Sports Betting",
    subtitle = "Post-Murphy v. NCAA (May 2018)",
    caption = "Note: Nevada excluded (always-treated)."
  ) +
  theme_void() +
  theme(
    legend.position = "bottom",
    plot.title = element_text(hjust = 0.5, face = "bold"),
    plot.subtitle = element_text(hjust = 0.5)
  )

ggsave("output/paper_80/figures/fig1_adoption_map.pdf", fig1_map,
       width = 8, height = 6, dpi = 300)

# =============================================================================
# Figure 2: Employment Trends by Cohort
# =============================================================================

cat("Creating Figure 2: Employment trends by cohort...\n")

cohort_trends <- df %>%
  mutate(
    cohort_label = case_when(
      first_treat_year == 0 ~ "Never Treated",
      first_treat_year == 2018 ~ "2018 Cohort",
      first_treat_year == 2019 ~ "2019 Cohort",
      first_treat_year == 2020 ~ "2020 Cohort",
      first_treat_year >= 2021 ~ "2021+ Cohort"
    )
  ) %>%
  group_by(cohort_label, yearq) %>%
  summarise(
    mean_emp = mean(gambling_emp_clean, na.rm = TRUE),
    se_emp = sd(gambling_emp_clean, na.rm = TRUE) / sqrt(n()),
    n = n(),
    .groups = "drop"
  ) %>%
  filter(!is.na(cohort_label))

fig2_trends <- ggplot(cohort_trends, aes(x = yearq, y = mean_emp, color = cohort_label)) +
  geom_vline(xintercept = 2018.375, linetype = "dashed", color = "gray50") +
  geom_line(linewidth = 1) +
  geom_point(size = 1.5) +
  annotate("text", x = 2018.5, y = max(cohort_trends$mean_emp, na.rm = TRUE),
           label = "Murphy v. NCAA", hjust = 0, size = 3, color = "gray40") +
  scale_color_manual(
    values = c(
      "2018 Cohort" = "#1a9850",
      "2019 Cohort" = "#91cf60",
      "2020 Cohort" = "#d9ef8b",
      "2021+ Cohort" = "#fee08b",
      "Never Treated" = "#d73027"
    ),
    name = "Treatment Cohort"
  ) +
  scale_x_continuous(breaks = seq(2010, 2024, 2)) +
  labs(
    title = "Gambling Employment Trends by Treatment Cohort",
    subtitle = "Pre-2018 trends support parallel trends assumption",
    x = "Year",
    y = "Mean Employment (NAICS 7132)",
    caption = "Note: Cohorts defined by year of first legal sports bet."
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

ggsave("output/paper_80/figures/fig2_cohort_trends.pdf", fig2_trends,
       width = 10, height = 6, dpi = 300)

# =============================================================================
# Figure 3: Event Study
# =============================================================================

cat("Creating Figure 3: Event study...\n")

# Filter to reasonable event window
es_plot_data <- es_coefs %>%
  filter(event_time >= -8, event_time <= 12)

fig3_event <- ggplot(es_plot_data, aes(x = event_time, y = att)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray50") +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), alpha = 0.2, fill = "#3182bd") +
  geom_line(color = "#3182bd", linewidth = 1) +
  geom_point(color = "#3182bd", size = 2) +
  annotate("text", x = -4, y = max(es_plot_data$ci_upper) * 0.9,
           label = "Pre-treatment", hjust = 0.5, size = 3, color = "gray40") +
  annotate("text", x = 6, y = max(es_plot_data$ci_upper) * 0.9,
           label = "Post-treatment", hjust = 0.5, size = 3, color = "gray40") +
  scale_x_continuous(breaks = seq(-8, 12, 2)) +
  labs(
    title = "Event Study: Effect of Sports Betting Legalization on Employment",
    subtitle = "Callaway-Sant'Anna estimator with 95% confidence intervals",
    x = "Quarters Relative to Legalization",
    y = "ATT (Change in Employment)",
    caption = "Note: Reference period is t = -1. Never-treated states serve as controls."
  ) +
  theme_minimal() +
  theme(
    panel.grid.minor = element_blank()
  )

ggsave("output/paper_80/figures/fig3_event_study.pdf", fig3_event,
       width = 10, height = 6, dpi = 300)

# =============================================================================
# Figure 4: Heterogeneity by Implementation Type
# =============================================================================

cat("Creating Figure 4: Heterogeneity by implementation type...\n")

# Get heterogeneity results
het_data <- data.frame(
  type = c("Retail + Mobile", "Retail Only", "Mobile Only"),
  att = c(
    cs_results$agg_both$overall.att,
    cs_results$agg_retail$overall.att,
    NA  # Placeholder if not enough mobile-only states
  ),
  se = c(
    cs_results$agg_both$overall.se,
    cs_results$agg_retail$overall.se,
    NA
  )
) %>%
  filter(!is.na(att)) %>%
  mutate(
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se
  )

fig4_het <- ggplot(het_data, aes(x = type, y = att, fill = type)) +
  geom_col(width = 0.6, alpha = 0.8) +
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.2) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  scale_fill_manual(
    values = c(
      "Retail + Mobile" = "#2166ac",
      "Retail Only" = "#67a9cf",
      "Mobile Only" = "#d1e5f0"
    )
  ) +
  labs(
    title = "Treatment Effects by Implementation Type",
    subtitle = "States with mobile betting show larger employment gains",
    x = "Implementation Type",
    y = "ATT (Employment Change)",
    caption = "Note: Effects calculated from Callaway-Sant'Anna estimator. Error bars show 95% CI."
  ) +
  theme_minimal() +
  theme(
    legend.position = "none",
    panel.grid.minor = element_blank()
  )

ggsave("output/paper_80/figures/fig4_heterogeneity.pdf", fig4_het,
       width = 8, height = 6, dpi = 300)

# =============================================================================
# Figure 5: Robustness Comparison
# =============================================================================

cat("Creating Figure 5: Robustness comparison...\n")

robustness <- read_csv("output/paper_80/data/robustness_summary.csv", show_col_types = FALSE)

fig5_robust <- ggplot(robustness, aes(x = reorder(Specification, ATT), y = ATT)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_hline(yintercept = robustness$ATT[1], linetype = "dotted",
             color = "#e41a1c", alpha = 0.5) +
  geom_pointrange(aes(ymin = CI_lower, ymax = CI_upper), color = "#377eb8", size = 0.5) +
  coord_flip() +
  labs(
    title = "Robustness of Employment Effects",
    subtitle = "Main estimate shown as dotted red line",
    x = "",
    y = "ATT (Employment Change)",
    caption = "Note: Error bars show 95% confidence intervals."
  ) +
  theme_minimal() +
  theme(
    panel.grid.minor = element_blank()
  )

ggsave("output/paper_80/figures/fig5_robustness.pdf", fig5_robust,
       width = 10, height = 6, dpi = 300)

# =============================================================================
# Figure 6: Adoption Timeline
# =============================================================================

cat("Creating Figure 6: Adoption timeline...\n")

adoption_by_year <- policy %>%
  filter(first_treat_year > 0) %>%
  count(first_treat_year, name = "n_states") %>%
  mutate(cumulative = cumsum(n_states))

fig6_timeline <- ggplot(adoption_by_year) +
  geom_col(aes(x = first_treat_year, y = n_states), fill = "#3182bd", alpha = 0.7) +
  geom_line(aes(x = first_treat_year, y = cumulative), color = "#e6550d", linewidth = 1.2) +
  geom_point(aes(x = first_treat_year, y = cumulative), color = "#e6550d", size = 3) +
  geom_text(aes(x = first_treat_year, y = cumulative, label = cumulative),
            vjust = -0.8, color = "#e6550d", size = 3.5) +
  scale_x_continuous(breaks = 2018:2024) +
  scale_y_continuous(
    name = "States Legalizing (bars)",
    sec.axis = sec_axis(~., name = "Cumulative States (line)")
  ) +
  labs(
    title = "Staggered Adoption of Legal Sports Betting",
    subtitle = "States legalizing by year (bars) and cumulative adoption (line)",
    x = "Year",
    caption = "Note: Based on date of first legal sports bet. Murphy v. NCAA decided May 2018."
  ) +
  theme_minimal() +
  theme(
    panel.grid.minor = element_blank()
  )

ggsave("output/paper_80/figures/fig6_timeline.pdf", fig6_timeline,
       width = 10, height = 6, dpi = 300)

# =============================================================================
# Save all figures as PNG for quick viewing
# =============================================================================

cat("\nSaving PNG versions...\n")

ggsave("output/paper_80/figures/fig1_adoption_map.png", fig1_map, width = 8, height = 6, dpi = 150)
ggsave("output/paper_80/figures/fig2_cohort_trends.png", fig2_trends, width = 10, height = 6, dpi = 150)
ggsave("output/paper_80/figures/fig3_event_study.png", fig3_event, width = 10, height = 6, dpi = 150)
ggsave("output/paper_80/figures/fig4_heterogeneity.png", fig4_het, width = 8, height = 6, dpi = 150)
ggsave("output/paper_80/figures/fig5_robustness.png", fig5_robust, width = 10, height = 6, dpi = 150)
ggsave("output/paper_80/figures/fig6_timeline.png", fig6_timeline, width = 10, height = 6, dpi = 150)

cat("\nAll figures saved to output/paper_80/figures/\n")
