# ==============================================================================
# 04_figures.R
# Paper 96: Telehealth Parity Laws and Mental Health Treatment Utilization
# Description: Generate publication-quality figures
# ==============================================================================

source("00_packages.R")

# ==============================================================================
# Load Results
# ==============================================================================

cs_results <- readRDS("../data/cs_results.rds")
analysis_data <- read_csv("../data/analysis_panel.csv", show_col_types = FALSE)
event_study <- read_csv("../data/event_study_estimates.csv", show_col_types = FALSE)

# ==============================================================================
# Figure 1: Adoption Timeline
# ==============================================================================

message("Creating Figure 1: Adoption Timeline")

policy_data <- read_csv("../data/telehealth_parity_laws.csv", show_col_types = FALSE)

adoption_counts <- policy_data %>%
  filter(!is.na(first_parity_law_year)) %>%
  count(first_parity_law_year, name = "new_adopters") %>%
  complete(first_parity_law_year = 1997:2019, fill = list(new_adopters = 0)) %>%
  mutate(cumulative = cumsum(new_adopters))

fig1 <- ggplot(adoption_counts, aes(x = first_parity_law_year)) +
  geom_col(aes(y = new_adopters), fill = apep_colors["treatment"], alpha = 0.7) +
  geom_line(aes(y = cumulative / 2), linewidth = 1.2, color = apep_colors["highlight"]) +
  geom_point(aes(y = cumulative / 2), size = 2, color = apep_colors["highlight"]) +
  scale_y_continuous(
    name = "New Adopting States",
    sec.axis = sec_axis(~ . * 2, name = "Cumulative States with Parity Laws")
  ) +
  scale_x_continuous(breaks = seq(1998, 2018, by = 4)) +
  labs(
    title = "Telehealth Parity Law Adoption, 1997-2019",
    subtitle = "Bars: new adoptions; Line: cumulative total",
    x = "Year",
    caption = "Source: CCHPCA, NCSL, state legislation"
  ) +
  theme(
    axis.title.y.right = element_text(color = apep_colors["highlight"]),
    axis.text.y.right = element_text(color = apep_colors["highlight"])
  )

save_figure(fig1, "fig1_adoption_timeline", width = 8, height = 5)

# ==============================================================================
# Figure 2: Depression Trends by Treatment Status
# ==============================================================================

message("Creating Figure 2: Depression Trends")

# Classify states by early vs late adoption
trends_data <- analysis_data %>%
  filter(!is.na(depression_pct)) %>%
  mutate(
    treatment_group = case_when(
      is.na(cohort) | cohort == 0 ~ "Never treated",
      cohort <= 2011 ~ "Early adopter (≤2011)",
      cohort <= 2015 ~ "Mid adopter (2012-2015)",
      TRUE ~ "Late adopter (2016-2019)"
    )
  ) %>%
  group_by(year, treatment_group) %>%
  summarize(
    mean_depression = mean(depression_pct, na.rm = TRUE),
    se = sd(depression_pct, na.rm = TRUE) / sqrt(n()),
    n = n(),
    .groups = "drop"
  )

fig2 <- ggplot(trends_data, aes(x = year, y = mean_depression, color = treatment_group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_ribbon(aes(ymin = mean_depression - 1.96 * se,
                  ymax = mean_depression + 1.96 * se,
                  fill = treatment_group),
              alpha = 0.15, color = NA) +
  scale_x_continuous(breaks = 2011:2019) +
  scale_color_manual(values = c(
    "Never treated" = "#A23B72",
    "Early adopter (≤2011)" = "#2E86AB",
    "Mid adopter (2012-2015)" = "#F18F01",
    "Late adopter (2016-2019)" = "#4CAF50"
  )) +
  scale_fill_manual(values = c(
    "Never treated" = "#A23B72",
    "Early adopter (≤2011)" = "#2E86AB",
    "Mid adopter (2012-2015)" = "#F18F01",
    "Late adopter (2016-2019)" = "#4CAF50"
  )) +
  labs(
    title = "Depression Diagnosis Rates by Treatment Cohort",
    subtitle = "% adults ever told they have depression (BRFSS)",
    x = "Year",
    y = "Depression Prevalence (%)",
    color = "Treatment Group",
    fill = "Treatment Group",
    caption = "Source: CDC BRFSS. Shaded areas: 95% CI."
  ) +
  theme(legend.position = "bottom")

save_figure(fig2, "fig2_trends_by_treatment", width = 9, height = 6)

# ==============================================================================
# Figure 3: Event Study
# ==============================================================================

message("Creating Figure 3: Event Study")

# Add reference period (e = -1)
event_plot_data <- event_study %>%
  mutate(
    att = ifelse(event_time == -1, 0, att),
    se = ifelse(event_time == -1, 0, se),
    ci_low = ifelse(event_time == -1, 0, att - 1.96 * se),
    ci_high = ifelse(event_time == -1, 0, att + 1.96 * se)
  )

fig3 <- ggplot(event_plot_data, aes(x = event_time, y = att)) +
  # Reference line at zero
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  # Reference line at treatment
  geom_vline(xintercept = -0.5, linetype = "dotted", color = "grey50") +
  # Confidence intervals
  geom_ribbon(aes(ymin = ci_low, ymax = ci_high),
              fill = apep_colors["treatment"], alpha = 0.2) +
  # Point estimates
  geom_line(linewidth = 1, color = apep_colors["treatment"]) +
  geom_point(size = 3, color = apep_colors["treatment"]) +
  # Reference period marker
  geom_point(data = filter(event_plot_data, event_time == -1),
             size = 4, shape = 1, color = apep_colors["treatment"]) +
  # Labels
  annotate("text", x = -3, y = 1.2, label = "Pre-treatment",
           size = 3, color = "grey40") +
  annotate("text", x = 2, y = 1.2, label = "Post-treatment",
           size = 3, color = "grey40") +
  scale_x_continuous(breaks = -5:5, limits = c(-5.5, 5.5)) +
  scale_y_continuous(limits = c(-2.5, 1.5)) +
  labs(
    title = "Event Study: Effect of Telehealth Parity on Depression Diagnosis",
    subtitle = "Callaway-Sant'Anna with not-yet-treated controls",
    x = "Years Relative to Treatment",
    y = "ATT (Percentage Points)",
    caption = "Note: Reference period is e = -1. Shaded area: 95% CI. Pre-treatment coefficients test parallel trends."
  )

save_figure(fig3, "fig3_event_study", width = 9, height = 6)

# ==============================================================================
# Figure 4: Cohort-Specific Effects
# ==============================================================================

message("Creating Figure 4: Cohort Effects")

# Extract cohort effects from results
cohort_effects <- tibble(
  cohort = c(2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019),
  att = c(-0.6944, -0.1066, -0.4149, -0.0765, -0.4484, -3.6072, -2.0938, -1.3357),
  se = c(0.6956, 0.5473, 0.3668, 0.6966, 0.9269, 0.4000, 1.6760, 0.3540)
) %>%
  mutate(
    ci_low = att - 1.96 * se,
    ci_high = att + 1.96 * se,
    significant = ci_high < 0 | ci_low > 0
  )

fig4 <- ggplot(cohort_effects, aes(x = factor(cohort), y = att)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  geom_errorbar(aes(ymin = ci_low, ymax = ci_high),
                width = 0.2, color = apep_colors["treatment"]) +
  geom_point(aes(shape = significant), size = 3, color = apep_colors["treatment"]) +
  scale_shape_manual(values = c("FALSE" = 16, "TRUE" = 17),
                     labels = c("Not significant", "Significant"),
                     name = "") +
  labs(
    title = "Cohort-Specific Treatment Effects",
    subtitle = "ATT by year of telehealth parity law adoption",
    x = "Adoption Cohort",
    y = "ATT (Percentage Points)",
    caption = "Note: Vertical bars: 95% CI. Triangles indicate CIs excluding zero."
  ) +
  theme(legend.position = "bottom")

save_figure(fig4, "fig4_cohort_effects", width = 8, height = 5)

# ==============================================================================
# Figure 5: Geographic Map
# ==============================================================================

message("Creating Figure 5: Geographic Distribution")

# Prepare state-level data for map
state_map_data <- policy_data %>%
  mutate(
    adoption_period = case_when(
      is.na(first_parity_law_year) ~ "Never adopted (through 2019)",
      first_parity_law_year <= 2011 ~ "Early (≤2011)",
      first_parity_law_year <= 2015 ~ "Middle (2012-2015)",
      TRUE ~ "Late (2016-2019)"
    ),
    state_lower = tolower(state)
  )

# Get US map data
us_states <- map_data("state")

# Merge
map_data_merged <- us_states %>%
  left_join(state_map_data, by = c("region" = "state_lower"))

fig5 <- ggplot(map_data_merged, aes(x = long, y = lat, group = group)) +
  geom_polygon(aes(fill = adoption_period), color = "white", linewidth = 0.2) +
  scale_fill_manual(
    values = c(
      "Early (≤2011)" = "#2E86AB",
      "Middle (2012-2015)" = "#F18F01",
      "Late (2016-2019)" = "#4CAF50",
      "Never adopted (through 2019)" = "#E0E0E0"
    ),
    na.value = "#E0E0E0"
  ) +
  coord_map("albers", lat0 = 39, lat1 = 45) +
  labs(
    title = "Telehealth Parity Law Adoption by State",
    fill = "Adoption Period",
    caption = "Note: Hawaii and Alaska not shown. DC coded as state."
  ) +
  theme_void() +
  theme(
    plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
    legend.position = "bottom",
    plot.caption = element_text(size = 8, hjust = 1, color = "grey50")
  )

save_figure(fig5, "fig5_map_adoption", width = 10, height = 6)

# ==============================================================================
# Summary
# ==============================================================================

message("\n=== Figures Created ===")
message("1. fig1_adoption_timeline.pdf - Treatment rollout over time")
message("2. fig2_trends_by_treatment.pdf - Outcome trends by cohort")
message("3. fig3_event_study.pdf - Dynamic treatment effects")
message("4. fig4_cohort_effects.pdf - Heterogeneity by adoption cohort")
message("5. fig5_map_adoption.pdf - Geographic distribution")
