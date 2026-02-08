# =============================================================================
# Paper 108: Geocoded Atlas of US Traffic Fatalities 2001-2023
# 08_substance_figures.R - Drug and alcohol pattern figures (Section 5)
# =============================================================================

source(here::here("output/paper_108/code/00_packages.R"))

# Load data
fars <- readRDS(file.path(dir_data, "fars_analysis_policy.rds"))
marijuana_policy <- readRDS(file.path(dir_data_policy, "marijuana_policy.rds"))

message("Loaded ", format(nrow(fars), big.mark = ","), " crashes")

# =============================================================================
# Figure 18: BAC Distribution Among Tested Drivers
# =============================================================================

message("Creating Figure 18: BAC distribution...")

# Filter to crashes with valid BAC
bac_data <- fars %>%
  filter(!is.na(max_bac), max_bac >= 0, max_bac <= 0.5) %>%
  mutate(
    bac_cat = case_when(
      max_bac == 0 ~ "0.00 (No alcohol)",
      max_bac < 0.08 ~ "0.01-0.07",
      max_bac < 0.15 ~ "0.08-0.14 (Impaired)",
      TRUE ~ "0.15+ (Highly impaired)"
    )
  )

fig18 <- ggplot(bac_data, aes(x = max_bac)) +
  geom_histogram(binwidth = 0.01, fill = apep_colors["alcohol_positive"], alpha = 0.7, color = "white") +
  geom_vline(xintercept = 0.08, linetype = "dashed", color = "red", linewidth = 1) +
  annotate("text", x = 0.085, y = Inf, label = "Legal limit (0.08)", hjust = 0, vjust = 2,
           size = 3, color = "red") +
  scale_x_continuous(breaks = seq(0, 0.5, 0.05), limits = c(0, 0.4)) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Blood Alcohol Concentration (BAC) Distribution",
    subtitle = "Drivers in fatal crashes with positive BAC test, Western States 2001-2023",
    x = "Blood Alcohol Concentration (BAC)",
    y = "Number of Drivers",
    caption = "Source: FARS (NHTSA). Legal limit for DUI is 0.08 in all states."
  ) +
  theme_apep()

ggsave(file.path(dir_figs, "fig18_bac_distribution.pdf"), fig18,
       width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig18_bac_distribution.png"), fig18,
       width = 10, height = 6, dpi = 300)

message("  Saved fig18_bac_distribution")

# =============================================================================
# Figure 19: THC vs Alcohol Over Time (Legal States)
# =============================================================================

message("Creating Figure 19: THC vs alcohol comparison...")

# Focus on states that legalized and have both years before and after
legal_states <- c("CO", "WA", "OR", "CA", "NV")

substance_trend <- fars %>%
  filter(state_abbr %in% legal_states) %>%
  filter(!is.na(thc_positive) | !is.na(any_alc_positive)) %>%
  group_by(year) %>%
  summarise(
    thc_tested = sum(!is.na(thc_positive)),
    thc_pos = sum(thc_positive, na.rm = TRUE),
    alc_tested = sum(!is.na(any_alc_positive)),
    alc_pos = sum(any_alc_positive, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    pct_thc = 100 * thc_pos / thc_tested,
    pct_alc = 100 * alc_pos / alc_tested
  ) %>%
  filter(thc_tested >= 100, alc_tested >= 100)  # Minimum sample size

# Reshape for plotting
substance_long <- substance_trend %>%
  select(year, pct_thc, pct_alc) %>%
  pivot_longer(cols = c(pct_thc, pct_alc),
               names_to = "substance",
               values_to = "percent") %>%
  mutate(
    substance = recode(substance,
                       "pct_thc" = "THC Positive",
                       "pct_alc" = "Alcohol Positive")
  )

fig19 <- ggplot(substance_long, aes(x = year, y = percent, color = substance)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 2.5) +
  geom_vline(xintercept = 2012, linetype = "dashed", color = "grey50") +
  annotate("text", x = 2012.3, y = max(substance_long$percent) * 0.95,
           label = "CO/WA\nLegalize", hjust = 0, size = 3) +
  scale_color_manual(values = c(
    "THC Positive" = apep_colors["thc_positive"],
    "Alcohol Positive" = apep_colors["alcohol_positive"]
  )) +
  scale_x_continuous(breaks = seq(2001, 2023, 2)) +
  labs(
    title = "THC vs Alcohol Involvement in Fatal Crashes",
    subtitle = "States that legalized recreational marijuana (CO, WA, OR, CA, NV)",
    x = "Year",
    y = "Percent Positive (Among Tested)",
    color = "Substance",
    caption = "Source: FARS drug/alcohol test data. Includes only crashes with valid test results."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(dir_figs, "fig19_thc_vs_alcohol_trend.pdf"), fig19,
       width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig19_thc_vs_alcohol_trend.png"), fig19,
       width = 10, height = 6, dpi = 300)

message("  Saved fig19_thc_vs_alcohol_trend")

# =============================================================================
# Figure 20: Poly-Substance Involvement
# =============================================================================

message("Creating Figure 20: Poly-substance involvement...")

poly_data <- fars %>%
  filter(!is.na(thc_positive) & !is.na(any_alc_positive)) %>%
  group_by(year) %>%
  summarise(
    total = n(),
    thc_only = sum(thc_positive & !any_alc_positive),
    alc_only = sum(!thc_positive & any_alc_positive),
    both = sum(thc_positive & any_alc_positive),
    neither = sum(!thc_positive & !any_alc_positive),
    .groups = "drop"
  ) %>%
  pivot_longer(cols = c(thc_only, alc_only, both, neither),
               names_to = "category",
               values_to = "count") %>%
  group_by(year) %>%
  mutate(pct = 100 * count / sum(count)) %>%
  ungroup() %>%
  mutate(
    category = recode(category,
                      "thc_only" = "THC Only",
                      "alc_only" = "Alcohol Only",
                      "both" = "Both THC + Alcohol",
                      "neither" = "Neither")
  )

fig20 <- ggplot(poly_data, aes(x = year, y = pct, fill = category)) +
  geom_area(alpha = 0.8) +
  geom_vline(xintercept = 2012, linetype = "dashed", color = "grey30") +
  scale_fill_manual(values = c(
    "THC Only" = apep_colors["thc_positive"],
    "Alcohol Only" = apep_colors["alcohol_positive"],
    "Both THC + Alcohol" = apep_colors["both"],
    "Neither" = apep_colors["neither"]
  )) +
  scale_x_continuous(breaks = seq(2001, 2023, 2)) +
  labs(
    title = "Substance Involvement Breakdown Over Time",
    subtitle = "Western States, crashes with both THC and alcohol tests available",
    x = "Year",
    y = "Percent of Tested Crashes",
    fill = "Substance\nCategory",
    caption = "Source: FARS. Limited to crashes where both drug and alcohol tests were conducted."
  ) +
  theme_apep()

ggsave(file.path(dir_figs, "fig20_polysubstance.pdf"), fig20,
       width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig20_polysubstance.png"), fig20,
       width = 10, height = 6, dpi = 300)

message("  Saved fig20_polysubstance")

# =============================================================================
# Figure 21: THC Positive Rate by State (Before vs After)
# =============================================================================

message("Creating Figure 21: THC rate by state, before vs after...")

# Calculate THC rate in pre vs post legalization
# rec_effective_date is already in fars from 04_merge_policy.R
thc_by_state <- fars %>%
  filter(!is.na(thc_positive), state_abbr %in% c("CO", "WA", "OR", "CA", "NV")) %>%
  mutate(
    period = case_when(
      rec_legal ~ "Post-Legalization",
      TRUE ~ "Pre-Legalization"
    )
  ) %>%
  filter(period != "No Legalization") %>%
  group_by(state_abbr, period) %>%
  summarise(
    tested = n(),
    thc_pos = sum(thc_positive),
    pct_thc = 100 * thc_pos / tested,
    .groups = "drop"
  ) %>%
  filter(tested >= 50)

fig21 <- ggplot(thc_by_state, aes(x = state_abbr, y = pct_thc, fill = period)) +
  geom_col(position = position_dodge(width = 0.8), alpha = 0.8, width = 0.7) +
  scale_fill_manual(values = c(
    "Pre-Legalization" = "grey60",
    "Post-Legalization" = apep_colors["legal"]
  )) +
  labs(
    title = "THC-Positive Rate Before and After Legalization",
    subtitle = "States that legalized recreational marijuana",
    x = NULL,
    y = "Percent THC-Positive (Among Tested)",
    fill = "Period",
    caption = "Source: FARS drug test data. Pre = before state's rec legalization date."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(dir_figs, "fig21_thc_before_after.pdf"), fig21,
       width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig21_thc_before_after.png"), fig21,
       width = 10, height = 6, dpi = 300)

message("  Saved fig21_thc_before_after")

# =============================================================================
# Figure 22: Alcohol Involvement by Time of Day
# =============================================================================

message("Creating Figure 22: Alcohol by time of day...")

alc_by_hour <- fars %>%
  filter(!is.na(any_alc_positive), !is.na(hour), hour < 24) %>%
  group_by(hour) %>%
  summarise(
    total = n(),
    alc_pos = sum(any_alc_positive),
    pct_alc = 100 * alc_pos / total,
    .groups = "drop"
  )

fig22 <- ggplot(alc_by_hour, aes(x = hour, y = pct_alc)) +
  geom_line(color = apep_colors["alcohol_positive"], linewidth = 1.2) +
  geom_point(color = apep_colors["alcohol_positive"], size = 2.5) +
  geom_hline(yintercept = mean(alc_by_hour$pct_alc), linetype = "dashed", color = "grey50") +
  annotate("text", x = 0, y = mean(alc_by_hour$pct_alc) + 2,
           label = paste0("Mean: ", round(mean(alc_by_hour$pct_alc), 1), "%"),
           hjust = 0, size = 3, color = "grey50") +
  scale_x_continuous(breaks = seq(0, 23, 3),
                     labels = c("12am", "3am", "6am", "9am", "12pm", "3pm", "6pm", "9pm")) +
  labs(
    title = "Alcohol Involvement by Hour of Day",
    subtitle = "Western States, 2001-2023",
    x = "Hour of Day",
    y = "Percent Alcohol-Positive",
    caption = "Source: FARS alcohol test data. Alcohol-positive = BAC > 0."
  ) +
  theme_apep()

ggsave(file.path(dir_figs, "fig22_alcohol_by_hour.pdf"), fig22,
       width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig22_alcohol_by_hour.png"), fig22,
       width = 10, height = 6, dpi = 300)

message("  Saved fig22_alcohol_by_hour")

# =============================================================================
# Figure 23: Weekend vs Weekday Substance Patterns
# =============================================================================

message("Creating Figure 23: Weekend vs weekday patterns...")

weekend_substance <- fars %>%
  filter(!is.na(thc_positive) | !is.na(any_alc_positive)) %>%
  mutate(
    day_type = ifelse(is_weekend, "Weekend", "Weekday")
  ) %>%
  group_by(day_type) %>%
  summarise(
    total = n(),
    thc_pos = sum(thc_positive, na.rm = TRUE),
    alc_pos = sum(any_alc_positive, na.rm = TRUE),
    both_pos = sum(thc_positive & any_alc_positive, na.rm = TRUE),
    pct_thc = 100 * thc_pos / total,
    pct_alc = 100 * alc_pos / total,
    pct_both = 100 * both_pos / total,
    .groups = "drop"
  )

weekend_long <- weekend_substance %>%
  select(day_type, pct_thc, pct_alc, pct_both) %>%
  pivot_longer(cols = c(pct_thc, pct_alc, pct_both),
               names_to = "substance",
               values_to = "percent") %>%
  mutate(
    substance = recode(substance,
                       "pct_thc" = "THC",
                       "pct_alc" = "Alcohol",
                       "pct_both" = "Both")
  )

fig23 <- ggplot(weekend_long, aes(x = day_type, y = percent, fill = substance)) +
  geom_col(position = position_dodge(width = 0.7), alpha = 0.8, width = 0.6) +
  scale_fill_manual(values = c(
    "THC" = apep_colors["thc_positive"],
    "Alcohol" = apep_colors["alcohol_positive"],
    "Both" = apep_colors["both"]
  )) +
  labs(
    title = "Substance Involvement: Weekend vs Weekday",
    subtitle = "Western States, 2001-2023",
    x = NULL,
    y = "Percent Positive",
    fill = "Substance",
    caption = "Source: FARS. Weekend = Saturday and Sunday."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(dir_figs, "fig23_weekend_weekday.pdf"), fig23,
       width = 8, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig23_weekend_weekday.png"), fig23,
       width = 8, height = 6, dpi = 300)

message("  Saved fig23_weekend_weekday")

# =============================================================================
# Summary
# =============================================================================

message("\n", strrep("=", 60))
message("Substance figures complete!")
message("Figures saved to: ", dir_figs)
message(strrep("=", 60))

# List substance figures
message("\nGenerated substance figures:")
list.files(dir_figs, pattern = "^fig1[8-9]_|^fig2[0-3]_") %>%
  unique() %>%
  sort() %>%
  walk(~ message("  ", .x))
