# ============================================================================
# Paper 78: Dyslexia Screening Mandates and Fourth-Grade Reading Proficiency
# (Revision of apep_0069)
# 02_descriptives.R - Summary statistics and descriptive analysis
# ============================================================================

source("00_packages.R")

# Load data
df <- readRDS(file.path(data_dir, "analysis_data.rds"))
mandates <- readRDS(file.path(data_dir, "dyslexia_mandates.rds"))

# ============================================================================
# 1. Treatment Adoption Timeline (with Corrected Timing)
# ============================================================================

cat("\n=== Treatment Adoption Summary (Corrected Timing) ===\n")

# Count by first NAEP exposure year (corrected timing)
adoption_summary <- df %>%
  filter(first_treat > 0) %>%
  distinct(state_abbr, first_treat) %>%
  count(first_treat, name = "n_states") %>%
  mutate(cumulative = cumsum(n_states))

cat("\nFirst NAEP Exposure Distribution (corrected):\n")
print(adoption_summary)

# States by treatment status
treatment_status <- df %>%
  distinct(state_abbr, ever_treated, first_treat, bundled, dyslexia_only) %>%
  mutate(
    status = case_when(
      ever_treated == 0 ~ "Never Treated",
      first_treat <= 2013 ~ "Early Exposure (2003-2013)",
      first_treat >= 2015 & first_treat <= 2017 ~ "Middle Exposure (2015-2017)",
      first_treat >= 2019 ~ "Late Exposure (2019+)"
    ),
    reform_type = case_when(
      ever_treated == 0 ~ "Never Treated",
      bundled == 1 ~ "Bundled Reform",
      dyslexia_only == 1 ~ "Dyslexia-Only"
    )
  )

cat("\nTreatment status by exposure timing:\n")
print(table(treatment_status$status))

cat("\nTreatment status by reform type:\n")
print(table(treatment_status$reform_type))

# List states by category
never_treated <- treatment_status %>% filter(ever_treated == 0)
bundled <- treatment_status %>% filter(bundled == 1)
dyslexia_only <- treatment_status %>% filter(dyslexia_only == 1)

cat("\nNever-treated states (", nrow(never_treated), "):\n")
cat(paste(sort(never_treated$state_abbr), collapse = ", "), "\n")

cat("\nBundled reform states (", nrow(bundled), "):\n")
cat(paste(sort(bundled$state_abbr), collapse = ", "), "\n")

cat("\nDyslexia-only states (", nrow(dyslexia_only), "):\n")
cat(paste(sort(dyslexia_only$state_abbr), collapse = ", "), "\n")

# ============================================================================
# 2. Summary Statistics Table
# ============================================================================

cat("\n=== Summary Statistics ===\n")

# Overall summary
overall_stats <- df %>%
  summarise(
    N = n(),
    mean_score = mean(reading_score),
    sd_score = sd(reading_score),
    min_score = min(reading_score),
    max_score = max(reading_score)
  )

cat("Overall (N =", overall_stats$N, "):\n")
cat("  Mean reading score:", round(overall_stats$mean_score, 1), "\n")
cat("  SD:", round(overall_stats$sd_score, 1), "\n")
cat("  Range:", round(overall_stats$min_score, 1), "-", round(overall_stats$max_score, 1), "\n")

# By reform type
reform_stats <- df %>%
  mutate(
    reform_type = case_when(
      ever_treated == 0 ~ "Never Treated",
      bundled == 1 ~ "Bundled Reform",
      TRUE ~ "Dyslexia-Only"
    )
  ) %>%
  group_by(reform_type) %>%
  summarise(
    N = n(),
    mean_score = mean(reading_score),
    sd_score = sd(reading_score),
    .groups = "drop"
  )

cat("\nBy reform type:\n")
print(reform_stats)

# ============================================================================
# 3. Balance Table (Pre-Treatment Characteristics)
# ============================================================================

# Get baseline (2003) characteristics
baseline <- df %>%
  filter(year == 2003) %>%
  select(state_abbr, reading_score_2003 = reading_score, ever_treated, bundled)

# Calculate pre-treatment trends (2003-2011)
pre_trends <- df %>%
  filter(year <= 2011) %>%
  group_by(state_abbr, ever_treated) %>%
  summarise(
    trend = coef(lm(reading_score ~ year))[2],  # Slope
    .groups = "drop"
  )

# Merge and compare
balance_data <- baseline %>%
  left_join(pre_trends, by = c("state_abbr", "ever_treated"))

balance_table <- balance_data %>%
  group_by(ever_treated) %>%
  summarise(
    N = n(),
    mean_baseline = mean(reading_score_2003),
    sd_baseline = sd(reading_score_2003),
    mean_trend = mean(trend),
    sd_trend = sd(trend),
    .groups = "drop"
  )

cat("\n=== Balance Table (Baseline 2003) ===\n")
print(balance_table)

# T-test for baseline difference
t_baseline <- t.test(reading_score_2003 ~ ever_treated, data = balance_data)
cat("\nBaseline difference p-value:", round(t_baseline$p.value, 3), "\n")

# T-test for pre-trend difference
t_trend <- t.test(trend ~ ever_treated, data = balance_data)
cat("Pre-trend difference p-value:", round(t_trend$p.value, 3), "\n")

# ============================================================================
# 4. Raw Outcome Trends by Cohort
# ============================================================================

# Create cohort variable based on corrected timing
df <- df %>%
  mutate(
    cohort = case_when(
      ever_treated == 0 ~ "Never Treated",
      first_treat <= 2013 ~ "Early (2003-2013)",
      first_treat >= 2015 & first_treat <= 2017 ~ "Middle (2015-2017)",
      first_treat >= 2019 ~ "Late (2019+)"
    ),
    cohort = factor(cohort, levels = c("Never Treated", "Early (2003-2013)",
                                        "Middle (2015-2017)", "Late (2019+)"))
  )

# Cohort means by year
cohort_means <- df %>%
  group_by(year, cohort) %>%
  summarise(
    mean_score = mean(reading_score),
    se = sd(reading_score) / sqrt(n()),
    n = n(),
    .groups = "drop"
  )

cat("\n=== Cohort Means by Year ===\n")
print(cohort_means %>% filter(year %in% c(2003, 2011, 2019, 2022)))

# ============================================================================
# 5. Figures
# ============================================================================

# Figure 1: Policy Adoption Map (requires sf and tigris packages)
if (exists("sf_available") && sf_available && exists("tigris_available") && tigris_available) {
  cat("\nCreating Figure 1: Policy adoption map...\n")

  # Get US state shapefile
  us_states <- states(cb = TRUE) %>%
    filter(!STATEFP %in% c("02", "15", "72", "78", "60", "66", "69"))  # Lower 48 + DC

  # Merge with mandate data
  map_data <- us_states %>%
    mutate(state_abbr = STUSPS) %>%
    left_join(mandates %>% select(state_abbr, mandate_year, first_naep_exposure, bundled_reform),
              by = "state_abbr")

  # Create map
  fig1 <- ggplot(map_data) +
    geom_sf(aes(fill = mandate_year), color = "white", linewidth = 0.3) +
    scale_fill_viridis_c(
      name = "Year Adopted",
      option = "plasma",
      na.value = "grey85",
      direction = -1,
      limits = c(1995, 2023),
      breaks = seq(1995, 2020, 5)
    ) +
    labs(
      title = "State Adoption of Dyslexia Screening Mandates",
      subtitle = "1995-2023 (with corrected NAEP exposure timing)",
      caption = "Source: Dyslegia.com, State of Dyslexia. Grey states: no mandate as of 2023."
    ) +
    theme_void() +
    theme(
      legend.position = "bottom",
      legend.key.width = unit(2, "cm"),
      legend.key.height = unit(0.4, "cm"),
      plot.title = element_text(size = 14, face = "bold", hjust = 0.5),
      plot.subtitle = element_text(size = 10, hjust = 0.5, color = "grey40"),
      plot.caption = element_text(size = 8, color = "grey50", hjust = 0.5),
      plot.margin = margin(10, 10, 10, 10)
    )

  pdf(file.path(fig_dir, "fig1_adoption_map.pdf"), width = 10, height = 7)
  print(fig1)
  dev.off()
  png(file.path(fig_dir, "fig1_adoption_map.png"), width = 10, height = 7, units = "in", res = 300)
  print(fig1)
  dev.off()
} else {
  cat("\nSkipping Figure 1 (policy adoption map): sf/tigris packages not available\n")
}

# Figure 2: Raw Trends by Cohort
cat("Creating Figure 2: Raw outcome trends...\n")

years <- c(2003, 2005, 2007, 2009, 2011, 2013, 2015, 2017, 2019, 2022)

fig2 <- ggplot(cohort_means, aes(x = year, y = mean_score, color = cohort, group = cohort)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  geom_errorbar(aes(ymin = mean_score - 1.96*se, ymax = mean_score + 1.96*se),
                width = 0.3, alpha = 0.5) +
  scale_color_manual(
    values = c("Never Treated" = apep_colors[2],
               "Early (2003-2013)" = apep_colors[1],
               "Middle (2015-2017)" = apep_colors[3],
               "Late (2019+)" = apep_colors[4]),
    name = "First NAEP Exposure"
  ) +
  scale_x_continuous(breaks = years) +
  labs(
    title = "NAEP Grade 4 Reading Scores by Treatment Cohort",
    subtitle = "State averages with 95% CI (cohorts based on corrected NAEP exposure timing)",
    x = "Year",
    y = "Mean NAEP Reading Score",
    caption = "Source: NAEP Data Service API. Cohorts defined by first NAEP exposure to dyslexia mandate."
  ) +
  theme_apep() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "right"
  )

pdf(file.path(fig_dir, "fig2_raw_trends.pdf"), width = 10, height = 6)
print(fig2)
dev.off()
png(file.path(fig_dir, "fig2_raw_trends.png"), width = 10, height = 6, units = "in", res = 300)
print(fig2)
dev.off()

# Figure 3: Treatment Adoption Timeline
cat("Creating Figure 3: Adoption timeline...\n")

adoption_timeline <- mandates %>%
  filter(!is.na(first_naep_exposure)) %>%
  count(first_naep_exposure) %>%
  rename(year = first_naep_exposure) %>%
  mutate(cumulative = cumsum(n))

fig3 <- ggplot(adoption_timeline, aes(x = year)) +
  geom_col(aes(y = n), fill = apep_colors[1], alpha = 0.7, width = 0.8) +
  geom_line(aes(y = cumulative / 2), color = apep_colors[2], linewidth = 1.2) +
  geom_point(aes(y = cumulative / 2), color = apep_colors[2], size = 2.5) +
  scale_y_continuous(
    name = "States with First NAEP Exposure (bars)",
    sec.axis = sec_axis(~ . * 2, name = "Cumulative States (line)")
  ) +
  scale_x_continuous(breaks = years) +
  labs(
    title = "Timeline of First NAEP Exposure to Dyslexia Mandates",
    subtitle = "(Based on corrected timing: when NAEP could first show effects)",
    x = "NAEP Year",
    caption = "Note: Bar heights show states with first NAEP exposure in that year. Line shows cumulative total."
  ) +
  theme_apep() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

pdf(file.path(fig_dir, "fig3_adoption_timeline.pdf"), width = 9, height = 5)
print(fig3)
dev.off()
png(file.path(fig_dir, "fig3_adoption_timeline.png"), width = 9, height = 5, units = "in", res = 300)
print(fig3)
dev.off()

# ============================================================================
# 6. Treatment Classification Table (New for Revision)
# ============================================================================

cat("\nCreating Treatment Classification Table...\n")

treatment_table <- mandates %>%
  select(state_abbr, mandate_year, effective_month, first_naep_exposure,
         universal, intervention_req, teacher_training, funding,
         mandate_strength, mandate_strength_cat, bundled_reform) %>%
  arrange(mandate_year)

write_csv(treatment_table, file.path(tab_dir, "treatment_classification.csv"))

cat("Treatment classification table saved\n")

# ============================================================================
# 7. Save Summary Statistics
# ============================================================================

# Create summary statistics table for paper
summary_stats_table <- df %>%
  mutate(
    reform_type = case_when(
      ever_treated == 0 ~ "Never Treated",
      bundled == 1 ~ "Bundled Reform",
      TRUE ~ "Dyslexia-Only"
    )
  ) %>%
  group_by(reform_type) %>%
  summarise(
    `N (state-years)` = n(),
    `Mean Reading Score` = round(mean(reading_score), 1),
    `SD Reading Score` = round(sd(reading_score), 1),
    `Min` = round(min(reading_score), 1),
    `Max` = round(max(reading_score), 1),
    .groups = "drop"
  )

write_csv(summary_stats_table, file.path(tab_dir, "table1_summary_stats.csv"))

# Save updated data with cohort variable
saveRDS(df, file.path(data_dir, "analysis_data.rds"))

cat("\n=== Descriptive analysis complete ===\n")
cat("Figures saved to:", fig_dir, "\n")
cat("Tables saved to:", tab_dir, "\n")
