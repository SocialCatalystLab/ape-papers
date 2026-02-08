# =============================================================================
# Fix Figure Labels for Consistency
# =============================================================================

source(here::here("output/paper_108/code/00_packages.R"))

# Load clean data
fars <- readRDS(file.path(dir_data, "fars_analysis_policy_fixed_clean.rds"))

THC_YEARS <- c(2018, 2019)
THC_YEAR_LABEL <- "2018-2019"

message("Fixing figure labels for consistency...")

# =============================================================================
# Figure 3: THC rate - Fix legend labels
# =============================================================================

message("Fixing Figure 3: THC rate labels...")

thc_by_year <- fars %>%
  filter(year %in% THC_YEARS, !is.na(thc_positive)) %>%
  group_by(year, ever_rec_legal) %>%
  summarise(
    tested = n(),
    thc_pos = sum(thc_positive),
    pct_thc = 100 * thc_pos / tested,
    .groups = "drop"
  ) %>%
  mutate(
    state_type = ifelse(ever_rec_legal, "Legalized States", "Comparison States")
  )

fig3 <- ggplot(thc_by_year, aes(x = factor(year), y = pct_thc, fill = state_type)) +
  geom_col(position = position_dodge(width = 0.7), alpha = 0.8, width = 0.6) +
  geom_text(aes(label = paste0(round(pct_thc, 1), "%")),
            position = position_dodge(width = 0.7), vjust = -0.5, size = 3) +
  scale_fill_manual(values = c(
    "Legalized States" = "#4DAF4A",
    "Comparison States" = "#FF7F00"
  )) +
  labs(
    title = "THC-Positive Rate Among Tested Fatal Crash Drivers",
    subtitle = paste0("Western States, ", THC_YEAR_LABEL),
    x = "Year",
    y = "Percent THC-Positive",
    fill = "State Type",
    caption = "Source: FARS drug test data. Comparison = illegal during study period (WY, NE, KS, ID, UT, AZ, MT, NM)."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(dir_figs, "fig03_thc_rate_over_time.pdf"), fig3, width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig03_thc_rate_over_time.png"), fig3, width = 10, height = 6, dpi = 300)
message("  Saved fig03")

# =============================================================================
# Figure 4: Alcohol rate - Fix legend labels
# =============================================================================

message("Fixing Figure 4: Alcohol rate labels...")

alc_by_year <- fars %>%
  group_by(year, ever_rec_legal) %>%
  summarise(
    total = n(),
    alc_involved = sum(alc_involved, na.rm = TRUE),
    pct_alc = 100 * alc_involved / total,
    .groups = "drop"
  ) %>%
  mutate(
    state_type = ifelse(ever_rec_legal, "Legalized States", "Comparison States")
  )

fig4 <- ggplot(alc_by_year, aes(x = year, y = pct_alc, color = state_type)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  scale_color_manual(values = c(
    "Legalized States" = "#4DAF4A",
    "Comparison States" = "#FF7F00"
  )) +
  scale_x_continuous(breaks = sort(unique(alc_by_year$year))) +
  labs(
    title = "Alcohol-Involved Fatal Crashes Over Time",
    subtitle = "Western States, 2001-2005 and 2016-2019",
    x = "Year",
    y = "Percent Alcohol-Involved",
    color = "State Type",
    caption = "Source: FARS. Comparison = illegal during study period."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(dir_figs, "fig04_alcohol_rate_over_time.pdf"), fig4, width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig04_alcohol_rate_over_time.png"), fig4, width = 10, height = 6, dpi = 300)
message("  Saved fig04")

message("\nFigure labels fixed!")
