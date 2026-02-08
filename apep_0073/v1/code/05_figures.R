# ==============================================================================
# APEP Paper 93: SNAP Work Requirements and Employment
# 05_figures.R - Generate all figures
# ==============================================================================

source("00_packages.R")

# Load results
cs_out <- readRDS("../data/cs_results.rds")
att_es <- readRDS("../data/att_es.rds")
state_year <- readRDS("../data/state_year.rds")
waiver_long <- readRDS("../data/waiver_status.rds")
first_treat <- readRDS("../data/first_treat.rds")

# ------------------------------------------------------------------------------
# Figure 1: Map of Work Requirement Reinstatement Timing
# ------------------------------------------------------------------------------

cat("Creating Figure 1: Policy Map\n")

# Get state boundaries
states <- tigris::states(cb = TRUE) %>%
  filter(!STATEFP %in% c("02", "15", "72", "78", "60", "66", "69"))

# Merge with treatment timing
states_policy <- states %>%
  left_join(
    first_treat %>% mutate(STATEFP = state_fips),
    by = "STATEFP"
  ) %>%
  mutate(
    treatment_group = case_when(
      first_treat == 0 ~ "Never Reinstated",
      first_treat <= 2015 ~ "Early (2015)",
      first_treat == 2016 ~ "2016",
      first_treat >= 2017 ~ "Late (2017+)",
      TRUE ~ "Never Reinstated"
    )
  )

fig1 <- ggplot(states_policy) +
  geom_sf(aes(fill = treatment_group), color = "white", linewidth = 0.2) +
  scale_fill_manual(
    name = "Work Requirement\nReinstatement",
    values = c(
      "Early (2015)" = "#D55E00",
      "2016" = "#F0E442",
      "Late (2017+)" = "#56B4E9",
      "Never Reinstated" = "grey80"
    )
  ) +
  labs(
    title = "SNAP ABAWD Work Requirement Reinstatement by State",
    subtitle = "Timing of waiver expiration, FY2015-2019",
    caption = "Source: USDA Food and Nutrition Service ABAWD waiver records."
  ) +
  theme_void() +
  theme(
    legend.position = "bottom",
    legend.key.width = unit(1, "cm"),
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    plot.subtitle = element_text(size = 10, hjust = 0.5, color = "grey40"),
    plot.caption = element_text(size = 8, hjust = 1, color = "grey50")
  )

ggsave("../figures/fig1_policy_map.pdf", fig1, width = 10, height = 7)
cat("  Saved fig1_policy_map.pdf\n")

# ------------------------------------------------------------------------------
# Figure 2: Pre-Trends - Employment by Treatment Cohort
# ------------------------------------------------------------------------------

cat("Creating Figure 2: Pre-Trends\n")

# Calculate means by cohort and year
cohort_means <- state_year %>%
  filter(first_treat > 0) %>%
  mutate(
    cohort = case_when(
      first_treat <= 2015 ~ "Early (2015)",
      first_treat == 2016 ~ "2016",
      first_treat >= 2017 ~ "Late (2017+)"
    )
  ) %>%
  group_by(cohort, year) %>%
  summarize(
    employed = weighted.mean(employed, w = pop),
    .groups = "drop"
  )

# Add never-treated
never_treated_means <- state_year %>%
  filter(first_treat == 0) %>%
  group_by(year) %>%
  summarize(
    employed = weighted.mean(employed, w = pop),
    .groups = "drop"
  ) %>%
  mutate(cohort = "Never Reinstated")

plot_data <- bind_rows(cohort_means, never_treated_means)

fig2 <- ggplot(plot_data, aes(x = year, y = employed, color = cohort, linetype = cohort)) +
  geom_line(linewidth = 0.8) +
  geom_point(size = 2) +
  scale_color_manual(
    name = "Treatment Cohort",
    values = c(
      "Early (2015)" = "#D55E00",
      "2016" = "#F0E442",
      "Late (2017+)" = "#56B4E9",
      "Never Reinstated" = "grey50"
    )
  ) +
  scale_linetype_manual(
    name = "Treatment Cohort",
    values = c(
      "Early (2015)" = "solid",
      "2016" = "solid",
      "Late (2017+)" = "solid",
      "Never Reinstated" = "dashed"
    )
  ) +
  labs(
    title = "Employment Rate Trends by Treatment Cohort",
    subtitle = "ABAWD-eligible adults (ages 18-49, no disability)",
    x = "Year",
    y = "Employment Rate",
    caption = "Source: ACS PUMS 2012-2019. Weighted means."
  ) +
  theme_apep() +
  theme(legend.position = "right") +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1))

ggsave("../figures/fig2_pretrends.pdf", fig2, width = 9, height = 6)
cat("  Saved fig2_pretrends.pdf\n")

# ------------------------------------------------------------------------------
# Figure 3: Event Study
# ------------------------------------------------------------------------------

cat("Creating Figure 3: Event Study\n")

# Extract event study data
es_data <- data.frame(
  time = att_es$egt,
  att = att_es$att.egt,
  se = att_es$se.egt
) %>%
  filter(!is.na(att))

fig3 <- ggplot(es_data, aes(x = time, y = att)) +
  # Confidence interval
  geom_ribbon(aes(ymin = att - 1.96*se, ymax = att + 1.96*se),
              alpha = 0.2, fill = apep_colors[1]) +
  # Point estimates
  geom_point(color = apep_colors[1], size = 2.5) +
  geom_line(color = apep_colors[1], linewidth = 0.7) +
  # Reference lines
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  # Labels
  labs(
    title = "Event Study: Effect of Work Requirements on Employment",
    subtitle = "Callaway-Sant'Anna estimator, 95% confidence intervals",
    x = "Years Relative to Work Requirement Reinstatement",
    y = "Average Treatment Effect on Employment Rate",
    caption = "Note: Reference period is t = -1. Shaded region shows 95% CI. Never-treated states as control."
  ) +
  theme_apep() +
  scale_x_continuous(breaks = seq(-4, 4, 1)) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1))

ggsave("../figures/fig3_event_study.pdf", fig3, width = 8, height = 5)
cat("  Saved fig3_event_study.pdf\n")

# ------------------------------------------------------------------------------
# Figure 4: SNAP Receipt Event Study
# ------------------------------------------------------------------------------

cat("Creating Figure 4: SNAP Receipt\n")

cs_snap <- readRDS("../data/cs_snap.rds")
att_snap_es <- aggte(cs_snap, type = "dynamic", min_e = -4, max_e = 4)

snap_es_data <- data.frame(
  time = att_snap_es$egt,
  att = att_snap_es$att.egt,
  se = att_snap_es$se.egt
) %>%
  filter(!is.na(att))

fig4 <- ggplot(snap_es_data, aes(x = time, y = att)) +
  geom_ribbon(aes(ymin = att - 1.96*se, ymax = att + 1.96*se),
              alpha = 0.2, fill = apep_colors[2]) +
  geom_point(color = apep_colors[2], size = 2.5) +
  geom_line(color = apep_colors[2], linewidth = 0.7) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey60") +
  labs(
    title = "Event Study: Effect of Work Requirements on SNAP Receipt",
    subtitle = "Callaway-Sant'Anna estimator, 95% confidence intervals",
    x = "Years Relative to Work Requirement Reinstatement",
    y = "Average Treatment Effect on SNAP Receipt Rate",
    caption = "Note: Negative values indicate reduced SNAP enrollment."
  ) +
  theme_apep() +
  scale_x_continuous(breaks = seq(-4, 4, 1)) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 0.1))

ggsave("../figures/fig4_snap_event_study.pdf", fig4, width = 8, height = 5)
cat("  Saved fig4_snap_event_study.pdf\n")

cat("\n=== All Figures Created ===\n")
