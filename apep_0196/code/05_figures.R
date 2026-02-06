# 05_figures.R
# Generate figures for Promise Program paper

source("00_packages.R")

# =============================================================================
# 1. LOAD DATA AND RESULTS
# =============================================================================

df <- readRDS("../data/clean_panel.rds")
cs_result <- readRDS("../data/cs_result.rds")
cs_aggregates <- readRDS("../data/cs_aggregates.rds")

message("Data and results loaded")

# =============================================================================
# 2. FIGURE 1: TREATMENT TIMING MAP
# =============================================================================

message("Creating Figure 1: Treatment timing map")

# Get US state map data
if (requireNamespace("maps", quietly = TRUE) && requireNamespace("mapproj", quietly = TRUE)) {
  library(maps)
  library(mapproj)

  # State data
  treatment_timing <- read_csv("../data/promise_treatment_timing.csv", show_col_types = FALSE)

  state_map <- map_data("state") %>%
    mutate(state_abbr = state.abb[match(str_to_title(region), state.name)]) %>%
    left_join(
      treatment_timing %>%
        mutate(state_abbr = c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "FL",
                              "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME",
                              "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH",
                              "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI",
                              "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY")[
                                match(state_fips, c(1:2, 4:6, 8:13, 15:42, 44:51, 53:56))
                              ]),
      by = "state_abbr"
    )

  fig1 <- ggplot(state_map, aes(x = long, y = lat, group = group)) +
    geom_polygon(aes(fill = factor(first_cohort_year)), color = "white", size = 0.2) +
    scale_fill_viridis_d(
      name = "First Cohort Year",
      na.value = "gray80",
      option = "plasma"
    ) +
    coord_map("albers", lat0 = 30, lat1 = 40) +
    labs(
      title = "State College Promise Program Adoption",
      subtitle = "Year of first eligible cohort",
      caption = "Gray states: no statewide Promise program as of 2021"
    ) +
    theme_void() +
    theme(
      legend.position = "bottom",
      plot.title = element_text(face = "bold", hjust = 0.5),
      plot.subtitle = element_text(hjust = 0.5, color = "gray40")
    )

  ggsave("../figures/fig1_treatment_map.pdf", fig1, width = 10, height = 6)
  ggsave("../figures/fig1_treatment_map.png", fig1, width = 10, height = 6, dpi = 300)
} else {
  message("Skipping map figure - mapproj package not available")
}

# =============================================================================
# 3. FIGURE 2: RAW TRENDS BY TREATMENT STATUS
# =============================================================================

message("Creating Figure 2: Raw trends")

# Aggregate to treated vs control
trends_data <- df %>%
  group_by(year, ever_treated) %>%
  summarize(
    mean_enroll = mean(total_college_enrolled, na.rm = TRUE),
    se_enroll = sd(total_college_enrolled, na.rm = TRUE) / sqrt(n()),
    n = n(),
    .groups = "drop"
  ) %>%
  mutate(group = ifelse(ever_treated, "Promise States", "Non-Promise States"))

# Mark approximate average treatment year
avg_treat_year <- df %>%
  filter(ever_treated, first_treat > 0) %>%
  summarize(avg = mean(first_treat)) %>%
  pull(avg)

fig2 <- ggplot(trends_data, aes(x = year, y = mean_enroll / 1e6, color = group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_ribbon(aes(ymin = (mean_enroll - 1.96*se_enroll) / 1e6,
                  ymax = (mean_enroll + 1.96*se_enroll) / 1e6,
                  fill = group), alpha = 0.2, color = NA) +
  geom_vline(xintercept = avg_treat_year, linetype = "dashed", color = "gray50") +
  annotate("text", x = avg_treat_year + 0.3, y = max(trends_data$mean_enroll) / 1e6 * 0.95,
           label = "Avg. treatment\nstart", hjust = 0, size = 3, color = "gray40") +
  scale_color_manual(values = c("Promise States" = "#E64B35", "Non-Promise States" = "#4DBBD5")) +
  scale_fill_manual(values = c("Promise States" = "#E64B35", "Non-Promise States" = "#4DBBD5")) +
  labs(
    x = "Year",
    y = "Average College Enrollment (millions)",
    title = "College Enrollment Trends by Promise Program Status",
    subtitle = "State-level averages with 95% confidence intervals"
  ) +
  theme_apep() +
  theme(legend.position = c(0.15, 0.85))

ggsave("../figures/fig2_raw_trends.pdf", fig2, width = 8, height = 5)
ggsave("../figures/fig2_raw_trends.png", fig2, width = 8, height = 5, dpi = 300)

# =============================================================================
# 4. FIGURE 3: EVENT STUDY (CALLAWAY-SANT'ANNA)
# =============================================================================

message("Creating Figure 3: Event study")

# Extract dynamic effects
att_dynamic <- cs_aggregates$dynamic

# Create event study data frame
es_data <- tibble(
  time = att_dynamic$egt,
  estimate = att_dynamic$att.egt,
  se = att_dynamic$se.egt
) %>%
  mutate(
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se
  )

fig3 <- ggplot(es_data, aes(x = time, y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_vline(xintercept = -0.5, linetype = "dashed", color = "gray50") +
  geom_ribbon(aes(ymin = ci_lower, ymax = ci_upper), fill = "#4DBBD5", alpha = 0.3) +
  geom_line(color = "#4DBBD5", linewidth = 1) +
  geom_point(color = "#4DBBD5", size = 2.5) +
  annotate("text", x = -4, y = max(es_data$ci_upper) * 0.9,
           label = "Pre-treatment", fontface = "italic", color = "gray40") +
  annotate("text", x = 4, y = max(es_data$ci_upper) * 0.9,
           label = "Post-treatment", fontface = "italic", color = "gray40") +
  labs(
    x = "Years Relative to Promise Program Adoption",
    y = "Effect on Log Enrollment",
    title = "Dynamic Treatment Effects of Promise Programs",
    subtitle = "Callaway-Sant'Anna estimator with never-treated control group",
    caption = "Shaded area: 95% confidence interval. Dashed line: treatment onset."
  ) +
  theme_apep()

ggsave("../figures/fig3_event_study.pdf", fig3, width = 8, height = 5)
ggsave("../figures/fig3_event_study.png", fig3, width = 8, height = 5, dpi = 300)

# =============================================================================
# 5. FIGURE 4: HETEROGENEITY BY COHORT
# =============================================================================

message("Creating Figure 4: Heterogeneity by cohort")

# Group-specific effects
att_group <- cs_aggregates$group

group_data <- tibble(
  cohort = att_group$egt,
  estimate = att_group$att.egt,
  se = att_group$se.egt
) %>%
  filter(!is.na(estimate)) %>%
  mutate(
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se,
    cohort_label = as.character(cohort)
  )

fig4 <- ggplot(group_data, aes(x = reorder(cohort_label, cohort), y = estimate)) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray50") +
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.2, color = "#E64B35") +
  geom_point(size = 3, color = "#E64B35") +
  labs(
    x = "Adoption Cohort (First Cohort Year)",
    y = "Group-Specific ATT",
    title = "Treatment Effects by Adoption Cohort",
    subtitle = "Later adopters show different effects than early adopters"
  ) +
  theme_apep() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave("../figures/fig4_heterogeneity_cohort.pdf", fig4, width = 8, height = 5)
ggsave("../figures/fig4_heterogeneity_cohort.png", fig4, width = 8, height = 5, dpi = 300)

# =============================================================================
# 6. FIGURE 5: RANDOMIZATION INFERENCE
# =============================================================================

message("Creating Figure 5: Randomization inference")

ri_results <- readRDS("../data/randomization_inference.rds")

ri_data <- tibble(
  effect = ri_results$ri_distribution
) %>%
  filter(!is.na(effect))

fig5 <- ggplot(ri_data, aes(x = effect)) +
  geom_histogram(bins = 50, fill = "gray70", color = "white") +
  geom_vline(xintercept = ri_results$actual_effect, color = "#E64B35", linewidth = 1.2) +
  geom_vline(xintercept = -ri_results$actual_effect, color = "#E64B35",
             linewidth = 1.2, linetype = "dashed") +
  annotate("text", x = ri_results$actual_effect, y = Inf,
           label = paste("Actual effect\np =", round(ri_results$ri_pvalue, 3)),
           hjust = -0.1, vjust = 1.5, color = "#E64B35", fontface = "bold") +
  labs(
    x = "Permutation Effect Estimates",
    y = "Frequency",
    title = "Randomization Inference Distribution",
    subtitle = paste("1,000 permutations of treatment assignment across states"),
    caption = "Solid line: actual estimate. Dashed line: mirror for two-sided test."
  ) +
  theme_apep()

ggsave("../figures/fig5_randomization_inference.pdf", fig5, width = 8, height = 5)
ggsave("../figures/fig5_randomization_inference.png", fig5, width = 8, height = 5, dpi = 300)

message("\n=== FIGURES SAVED ===")
message("All figures saved to ../figures/")
