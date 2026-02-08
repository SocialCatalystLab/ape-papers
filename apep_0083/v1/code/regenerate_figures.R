# =============================================================================
# Paper 108: Regenerate key figures with fixed data
# =============================================================================

source(here::here("output/paper_108/code/00_packages.R"))

# Load FIXED data
fars <- readRDS(file.path(dir_data, "fars_analysis_policy_fixed.rds"))
states_sf <- readRDS(file.path(dir_data, "states_sf.rds"))

message("Loaded ", format(nrow(fars), big.mark = ","), " crashes with fixed substance data")

# =============================================================================
# Figure 2: Annual Crashes Time Series
# =============================================================================

message("Creating Figure 2: Annual crashes time series...")

annual_crashes <- fars %>%
  group_by(year) %>%
  summarise(
    total_crashes = n(),
    total_fatals = sum(n_fatals, na.rm = TRUE),
    .groups = "drop"
  )

fig2 <- ggplot(annual_crashes, aes(x = year)) +
  geom_line(aes(y = total_crashes), color = apep_colors["legal"], linewidth = 1) +
  geom_point(aes(y = total_crashes), color = apep_colors["legal"], size = 2) +
  geom_vline(xintercept = 2012, linetype = "dashed", color = "grey50", linewidth = 0.5) +
  annotate("text", x = 2012.2, y = max(annual_crashes$total_crashes) * 0.95,
           label = "CO/WA Legalize", hjust = 0, size = 3, color = "grey40") +
  geom_vline(xintercept = 2014, linetype = "dashed", color = "grey50", linewidth = 0.5) +
  annotate("text", x = 2014.2, y = max(annual_crashes$total_crashes) * 0.90,
           label = "OR/AK Legalize", hjust = 0, size = 3, color = "grey40") +
  scale_x_continuous(breaks = seq(2001, 2023, 2)) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Fatal Traffic Crashes by Year, Western States",
    subtitle = "2001-2023",
    x = "Year",
    y = "Number of Fatal Crashes",
    caption = "Source: FARS (NHTSA). Western states: CO, WA, OR, CA, NV, AK, WY, NE, KS, ID, UT, AZ, NM, MT."
  ) +
  theme_apep()

ggsave(file.path(dir_figs, "fig02_annual_crashes.pdf"), fig2, width = 10, height = 6, dpi = 300)
message("  Saved fig02_annual_crashes")

# =============================================================================
# Figure 3: THC-Positive Rate Over Time (FIXED)
# =============================================================================

message("Creating Figure 3: THC-positive rate over time (2018-2023 only)...")

# THC data only available 2018+
thc_by_year <- fars %>%
  filter(year >= 2018) %>%
  group_by(year, ever_rec_legal) %>%
  summarise(
    crashes = n(),
    thc_pos = sum(thc_positive_fixed, na.rm = TRUE),
    pct_thc = 100 * thc_pos / crashes,
    .groups = "drop"
  ) %>%
  mutate(
    state_type = ifelse(ever_rec_legal, "States that Legalized", "Never-Legal States")
  )

fig3 <- ggplot(thc_by_year, aes(x = year, y = pct_thc, color = state_type)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  scale_color_manual(values = c(
    "States that Legalized" = "#1a9641",
    "Never-Legal States" = "#d7191c"
  )) +
  scale_x_continuous(breaks = 2018:2023) +
  scale_y_continuous(limits = c(0, 30)) +
  labs(
    title = "THC-Positive Rate Among Fatal Crash Drivers",
    subtitle = "Western States, 2018-2023 (drug test data available from 2018)",
    x = "Year",
    y = "Percent THC-Positive",
    color = "State Type",
    caption = "Source: FARS drug test data. Note: Comprehensive drug name data only available from 2018."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(dir_figs, "fig03_thc_rate_over_time.pdf"), fig3, width = 10, height = 6, dpi = 300)
message("  Saved fig03_thc_rate_over_time")

# =============================================================================
# Figure 4: Alcohol-Positive Rate Over Time (FIXED)
# =============================================================================

message("Creating Figure 4: Alcohol-positive rate over time...")

alc_by_year <- fars %>%
  group_by(year, ever_rec_legal) %>%
  summarise(
    crashes = n(),
    alc_inv = sum(alc_involved, na.rm = TRUE),
    pct_alc = 100 * alc_inv / crashes,
    .groups = "drop"
  ) %>%
  mutate(
    state_type = ifelse(ever_rec_legal, "States that Legalized", "Never-Legal States")
  )

fig4 <- ggplot(alc_by_year, aes(x = year, y = pct_alc, color = state_type)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_vline(xintercept = 2012, linetype = "dashed", color = "grey50") +
  scale_color_manual(values = c(
    "States that Legalized" = "#1a9641",
    "Never-Legal States" = "#d7191c"
  )) +
  scale_x_continuous(breaks = seq(2001, 2023, 2)) +
  scale_y_continuous(limits = c(20, 50)) +
  labs(
    title = "Alcohol-Involved Fatal Crashes Over Time",
    subtitle = "Western States, 2001-2023",
    x = "Year",
    y = "Percent with Alcohol-Impaired Driver",
    color = "State Type",
    caption = "Source: FARS. Alcohol-involved = at least one driver with alcohol impairment (drunk_dr >= 1)."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(dir_figs, "fig04_alcohol_rate_over_time.pdf"), fig4, width = 10, height = 6, dpi = 300)
message("  Saved fig04_alcohol_rate_over_time")

# =============================================================================
# Figure 8: Drug Testing Rate by State (FIXED)
# =============================================================================

message("Creating Figure 8: Drug testing rate by state...")

# Calculate testing rate as: crashes with any THC test result / all crashes
# Only for years with drug data (2018+)
testing_by_state <- fars %>%
  filter(year >= 2018) %>%
  group_by(state_abbr) %>%
  summarise(
    total_crashes = n(),
    # Count crashes where we have drug test data (either positive or explicitly negative)
    has_drug_test = sum(any_drug_test, na.rm = TRUE),
    pct_tested = 100 * has_drug_test / total_crashes,
    .groups = "drop"
  ) %>%
  arrange(desc(pct_tested))

fig8 <- ggplot(testing_by_state, aes(x = reorder(state_abbr, pct_tested), y = pct_tested)) +
  geom_col(fill = apep_colors["legal"], alpha = 0.8) +
  geom_hline(yintercept = mean(testing_by_state$pct_tested), linetype = "dashed", color = "red") +
  annotate("text", x = 1, y = mean(testing_by_state$pct_tested) + 3,
           label = paste0("Mean: ", round(mean(testing_by_state$pct_tested), 1), "%"),
           hjust = 0, size = 3, color = "red") +
  coord_flip() +
  labs(
    title = "Drug Testing Rate by State",
    subtitle = "Percent of fatal crashes with drug test results available (2018-2023)",
    x = NULL,
    y = "Percent with Drug Test Results",
    caption = "Source: FARS drug test data, 2018-2023. Shows proportion of crashes with any drug test recorded."
  ) +
  theme_apep()

ggsave(file.path(dir_figs, "fig08_testing_rate_by_state.pdf"), fig8, width = 8, height = 8, dpi = 300)
message("  Saved fig08_testing_rate_by_state")

# =============================================================================
# Figure 9: BAC Distribution (from PERSON file, needs to be fixed)
# =============================================================================

message("Creating Figure 9: BAC distribution...")

# Load person data to get actual BAC values
person <- readRDS(file.path(dir_data_raw, "fars_person_west.rds"))

# Filter to drivers with valid BAC
bac_data <- person %>%
  filter(per_typ == 1) %>%  # Drivers only
  mutate(bac = as.numeric(alc_res)) %>%
  filter(!is.na(bac) & bac > 0 & bac < 95)  # Valid BAC (codes 96,97 = not tested/refused)

# Convert to decimal if stored as integer (FARS stores as hundredths)
# If max > 1, it's stored as hundredths
if (max(bac_data$bac, na.rm = TRUE) > 1) {
  bac_data <- bac_data %>% mutate(bac = bac / 100)
}

message("  BAC records: ", nrow(bac_data), " drivers with valid BAC > 0")

fig9 <- ggplot(bac_data, aes(x = bac)) +
  geom_histogram(binwidth = 0.02, fill = apep_colors["legal"], alpha = 0.8, color = "white") +
  geom_vline(xintercept = 0.08, linetype = "dashed", color = "red", linewidth = 1) +
  annotate("text", x = 0.085, y = Inf, label = "Legal limit (0.08)",
           hjust = 0, vjust = 2, size = 3, color = "red") +
  scale_x_continuous(limits = c(0, 0.40), breaks = seq(0, 0.40, 0.05)) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Blood Alcohol Concentration Distribution Among Tested Drivers",
    subtitle = "Drivers with BAC > 0 in fatal crashes, Western States",
    x = "Blood Alcohol Concentration (BAC)",
    y = "Number of Drivers",
    caption = "Source: FARS person file. Limited to drivers with positive BAC test results."
  ) +
  theme_apep()

ggsave(file.path(dir_figs, "fig18_bac_distribution.pdf"), fig9, width = 10, height = 6, dpi = 300)
message("  Saved fig18_bac_distribution")

# =============================================================================
# Summary
# =============================================================================

message("\n", strrep("=", 60))
message("Key figures regenerated with fixed substance data!")
message("Figures saved to: ", dir_figs)
message(strrep("=", 60))
