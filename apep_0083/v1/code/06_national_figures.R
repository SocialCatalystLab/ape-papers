# =============================================================================
# Paper 109: Geocoded Atlas of US Traffic Fatalities 2001-2019 (Revision)
# 06_national_figures.R - National overview figures (Section 3)
# =============================================================================

source(here::here("output/paper_109/code/00_packages.R"))

# Load data
fars <- readRDS(file.path(dir_data, "fars_analysis_policy.rds"))
states_sf <- readRDS(file.path(dir_data, "states_sf.rds"))
marijuana_policy <- readRDS(file.path(dir_data_policy, "marijuana_policy.rds"))

message("Loaded ", format(nrow(fars), big.mark = ","), " crashes")

# =============================================================================
# Figure 1: National Crash Density Heatmap (Western States)
# =============================================================================

message("Creating Figure 1: Crash density map...")

# Create hexbin counts
fars_sf <- fars %>%
  filter(!is.na(x_albers) & !is.na(y_albers)) %>%
  st_as_sf(coords = c("x_albers", "y_albers"), crs = 5070)

# Get bounding box for Western states (excluding Alaska for cleaner viz)
states_lower48 <- states_sf %>% filter(state_abbr != "AK")

fig1 <- ggplot() +
  # State boundaries
  geom_sf(data = states_lower48, fill = "grey95", color = "grey70", linewidth = 0.3) +
  # Crash points (sample for performance)
  geom_sf(data = fars_sf %>% filter(state_fips != "02") %>% sample_n(min(50000, n())),
          aes(color = rec_legal), alpha = 0.2, size = 0.3) +
  # State labels
  geom_sf_text(data = states_lower48, aes(label = state_abbr),
               size = 3, color = "grey40") +
  scale_color_manual(
    values = c("TRUE" = apep_colors["legal"], "FALSE" = apep_colors["illegal"]),
    labels = c("TRUE" = "Recreational Legal", "FALSE" = "Not Legal"),
    name = "Marijuana Status\n(at time of crash)"
  ) +
  labs(
    title = "Fatal Traffic Crashes in Western United States, 2001-2019",
    subtitle = paste0("N = ", format(nrow(fars %>% filter(state_fips != "02")), big.mark = ","),
                      " geocoded crashes (Alaska excluded for visualization)"),
    caption = "Source: FARS (NHTSA), 2001-2019. Each point is one fatal crash."
  ) +
  theme_apep() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank()
  )

ggsave(file.path(dir_figs, "fig01_crash_density_map.pdf"), fig1,
       width = 12, height = 10, dpi = 300)
ggsave(file.path(dir_figs, "fig01_crash_density_map.png"), fig1,
       width = 12, height = 10, dpi = 300)

message("  Saved fig01_crash_density_map")

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
  # Key policy dates
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
    subtitle = "2001-2019",
    x = "Year",
    y = "Number of Fatal Crashes",
    caption = "Source: FARS (NHTSA). Western states: CO, WA, OR, CA, NV, AK, WY, NE, KS, ID, UT, AZ, NM, MT."
  ) +
  theme_apep()

ggsave(file.path(dir_figs, "fig02_annual_crashes.pdf"), fig2,
       width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig02_annual_crashes.png"), fig2,
       width = 10, height = 6, dpi = 300)

message("  Saved fig02_annual_crashes")

# =============================================================================
# Figure 3: THC-Positive Rate (2018-2019 only, where text-based ID is reliable)
# =============================================================================

message("Creating Figure 3: THC-positive rate over time...")

# Calculate THC-positive rate by state (2018-2019 only, where text-based ID reliable)
thc_by_state <- fars %>%
  filter(!is.na(thc_positive), year >= 2018) %>%
  group_by(state_fips, state_abbr, ever_rec_legal) %>%
  summarise(
    tested = n(),
    thc_pos = sum(thc_positive),
    pct_thc = 100 * thc_pos / tested,
    .groups = "drop"
  ) %>%
  filter(tested >= 30) %>%
  mutate(
    state_type = ifelse(ever_rec_legal, "Legalized", "Never Legal")
  )

fig3 <- ggplot(thc_by_state,
               aes(x = reorder(state_abbr, pct_thc), y = pct_thc, fill = state_type)) +
  geom_col() +
  geom_text(aes(label = paste0(round(pct_thc, 0), "%")), hjust = -0.1, size = 3) +
  coord_flip() +
  scale_fill_manual(values = c(
    "Legalized" = apep_colors["legal"],
    "Never Legal" = apep_colors["illegal"]
  )) +
  scale_y_continuous(limits = c(0, 40), expand = c(0, 0)) +
  labs(
    title = "THC-Positive Rate Among Fatal Crashes with Drug Records",
    subtitle = "Western States, 2018-2019",
    x = NULL,
    y = "Percent THC-Positive",
    fill = "Recreational\nMarijuana",
    caption = "Source: FARS drugs file, 2018-2019. THC identification via DRUGRESNAME text matching.\nN = crashes with at least one drug record (includes positive, negative, and 'Test Not Given')."
  ) +
  theme_apep() +
  theme(legend.position = "right")

ggsave(file.path(dir_figs, "fig03_thc_rate_over_time.pdf"), fig3,
       width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig03_thc_rate_over_time.png"), fig3,
       width = 10, height = 6, dpi = 300)

message("  Saved fig03_thc_rate_over_time")

# =============================================================================
# Figure 4: Alcohol-Involved Rate Over Time
# =============================================================================

message("Creating Figure 4: Alcohol-involved rate over time...")

# Use drunk_dr from accident file (number of drunk drivers), which is reliable
# across all years, rather than any_alc_positive from person file
alc_by_year <- fars %>%
  filter(!is.na(drunk_dr)) %>%
  group_by(year, ever_rec_legal) %>%
  summarise(
    total = n(),
    alc_involved = sum(drunk_dr > 0, na.rm = TRUE),
    pct_alc = 100 * alc_involved / total,
    .groups = "drop"
  ) %>%
  mutate(
    state_type = ifelse(ever_rec_legal, "States that Legalized", "Never-Legal States")
  )

fig4 <- ggplot(alc_by_year %>% filter(total >= 50),
               aes(x = year, y = pct_alc, color = state_type)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_vline(xintercept = 2012, linetype = "dashed", color = "grey50") +
  scale_color_manual(values = c(
    "States that Legalized" = apep_colors["legal"],
    "Never-Legal States" = apep_colors["illegal"]
  )) +
  scale_x_continuous(breaks = seq(2001, 2023, 2)) +
  scale_y_continuous(limits = c(0, 50)) +
  labs(
    title = "Alcohol-Involved Fatal Crashes Over Time",
    subtitle = "Western States, 2001-2019",
    x = "Year",
    y = "Percent with At Least One Drunk Driver",
    color = "State Type",
    caption = "Source: FARS. Alcohol-involved = at least one driver with alcohol detected (drunk_dr > 0)."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(dir_figs, "fig04_alcohol_rate_over_time.pdf"), fig4,
       width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig04_alcohol_rate_over_time.png"), fig4,
       width = 10, height = 6, dpi = 300)

message("  Saved fig04_alcohol_rate_over_time")

# =============================================================================
# Figure 5: Crashes by Time of Day (2018-2019 for THC breakdown consistency)
# =============================================================================

message("Creating Figure 5: Crashes by time of day...")

# Restrict to 2018-2019 where THC identification is reliable
hour_dist <- fars %>%
  filter(year >= 2018, !is.na(hour) & hour < 24) %>%
  count(hour, substance_cat) %>%
  group_by(hour) %>%
  mutate(pct = 100 * n / sum(n))

fig5 <- ggplot(fars %>% filter(year >= 2018, !is.na(hour) & hour < 24),
               aes(x = hour, fill = substance_cat)) +
  geom_bar(position = "stack", alpha = 0.8) +
  scale_fill_manual(values = substance_colors) +
  scale_x_continuous(breaks = seq(0, 23, 3),
                     labels = c("12am", "3am", "6am", "9am", "12pm", "3pm", "6pm", "9pm")) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Fatal Crashes by Hour of Day and Substance Involvement",
    subtitle = "Western States, 2018-2019",
    x = "Hour of Day",
    y = "Number of Crashes",
    fill = "Substance\nInvolvement",
    caption = "Source: FARS (NHTSA), 2018-2019. THC identification via DRUGRESNAME text matching."
  ) +
  theme_apep()

ggsave(file.path(dir_figs, "fig05_crashes_by_hour.pdf"), fig5,
       width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig05_crashes_by_hour.png"), fig5,
       width = 10, height = 6, dpi = 300)

message("  Saved fig05_crashes_by_hour")

# =============================================================================
# Figure 6: Crashes by Day of Week (2018-2019 for THC breakdown consistency)
# =============================================================================

message("Creating Figure 6: Crashes by day of week...")

dow_labels <- c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat")

# Restrict to 2018-2019 where THC identification is reliable
fig6 <- ggplot(fars %>% filter(year >= 2018, !is.na(day_week) & day_week >= 1 & day_week <= 7),
               aes(x = factor(day_week, labels = dow_labels), fill = substance_cat)) +
  geom_bar(position = "stack", alpha = 0.8) +
  scale_fill_manual(values = substance_colors) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Fatal Crashes by Day of Week and Substance Involvement",
    subtitle = "Western States, 2018-2019",
    x = "Day of Week",
    y = "Number of Crashes",
    fill = "Substance\nInvolvement",
    caption = "Source: FARS (NHTSA), 2018-2019. THC identification via DRUGRESNAME text matching."
  ) +
  theme_apep()

ggsave(file.path(dir_figs, "fig06_crashes_by_dow.pdf"), fig6,
       width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig06_crashes_by_dow.png"), fig6,
       width = 10, height = 6, dpi = 300)

message("  Saved fig06_crashes_by_dow")

# =============================================================================
# Figure 7: Geocoding Quality by Year
# =============================================================================

message("Creating Figure 7: Geocoding quality by year...")

# Need to reload full data to see missing geocodes
fars_all <- readRDS(file.path(dir_data_raw, "fars_accident_west.rds"))

geocode_quality <- fars_all %>%
  mutate(
    has_coords = !is.na(latitude) & !is.na(longitude),
    year = as.numeric(year)
  ) %>%
  group_by(year) %>%
  summarise(
    total = n(),
    geocoded = sum(has_coords, na.rm = TRUE),
    pct_geocoded = 100 * geocoded / total,
    .groups = "drop"
  )

fig7 <- ggplot(geocode_quality, aes(x = year, y = pct_geocoded)) +
  geom_line(color = apep_colors["legal"], linewidth = 1) +
  geom_point(color = apep_colors["legal"], size = 2) +
  geom_hline(yintercept = 90, linetype = "dashed", color = "grey50") +
  annotate("text", x = 2002, y = 91, label = "90% threshold", hjust = 0, size = 3, color = "grey50") +
  scale_x_continuous(breaks = seq(2001, 2023, 2)) +
  scale_y_continuous(limits = c(70, 100)) +
  labs(
    title = "FARS Geocoding Quality Over Time",
    subtitle = "Percent of fatal crashes with valid lat/lon coordinates",
    x = "Year",
    y = "Percent Geocoded",
    caption = "Source: FARS (NHTSA). Valid coordinates = non-missing lat/lon. Alaska included (geocode validity checked separately)."
  ) +
  theme_apep()

ggsave(file.path(dir_figs, "fig07_geocoding_quality.pdf"), fig7,
       width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig07_geocoding_quality.png"), fig7,
       width = 10, height = 6, dpi = 300)

message("  Saved fig07_geocoding_quality")

# =============================================================================
# Figure 8: Drug Finding Rate by State (2018-2019)
# =============================================================================

message("Creating Figure 8: Drug finding rate by state...")

# Calculate share of crashes with any positive drug finding (not just "Test Not Given")
# This uses thc_positive OR any_drug_positive to identify crashes where drugs were actually found
finding_by_state <- fars %>%
  filter(year >= 2018) %>%
  group_by(state_abbr, ever_rec_legal) %>%
  summarise(
    total_crashes = n(),
    # Crashes with any drug finding (THC or other drugs)
    any_drug_finding = sum(thc_positive | (any_drug_positive == TRUE), na.rm = TRUE),
    pct_drug_finding = 100 * any_drug_finding / total_crashes,
    .groups = "drop"
  ) %>%
  arrange(desc(pct_drug_finding))

fig8 <- ggplot(finding_by_state, aes(x = reorder(state_abbr, pct_drug_finding), y = pct_drug_finding,
                                      fill = factor(ever_rec_legal))) +
  geom_col(alpha = 0.8) +
  geom_hline(yintercept = mean(finding_by_state$pct_drug_finding), linetype = "dashed", color = "grey30") +
  annotate("text", x = 1, y = mean(finding_by_state$pct_drug_finding) + 2,
           label = paste0("Mean: ", round(mean(finding_by_state$pct_drug_finding), 1), "%"),
           hjust = 0, size = 3, color = "grey30") +
  coord_flip(ylim = c(0, 80)) +  # Use ylim in coord_flip to avoid dropping high values
  scale_fill_manual(values = c("TRUE" = unname(apep_colors["legal"]), "FALSE" = unname(apep_colors["illegal"])),
                    labels = c("TRUE" = "Legalized", "FALSE" = "Never Legal"),
                    name = "Marijuana Status") +
  scale_y_continuous(expand = c(0, 0)) +
  labs(
    title = "Share of Fatal Crashes with Any Positive Drug Finding",
    subtitle = "Western States, 2018-2019",
    x = NULL,
    y = "Percent of Crashes with Drug Finding",
    caption = "Source: FARS drugs file, 2018-2019. Drug finding = any driver with positive drug result."
  ) +
  theme_apep()

ggsave(file.path(dir_figs, "fig08_testing_rate_by_state.pdf"), fig8,
       width = 8, height = 8, dpi = 300)
ggsave(file.path(dir_figs, "fig08_testing_rate_by_state.png"), fig8,
       width = 8, height = 8, dpi = 300)

message("  Saved fig08_testing_rate_by_state")

# =============================================================================
# Figure 9: Crashes by State (Bar Chart)
# =============================================================================

message("Creating Figure 9: Crashes by state...")

crashes_by_state <- fars %>%
  group_by(state_abbr, ever_rec_legal) %>%
  summarise(
    crashes = n(),
    .groups = "drop"
  ) %>%
  mutate(
    state_type = ifelse(ever_rec_legal, "Legalized", "Never Legal")
  )

fig9 <- ggplot(crashes_by_state, aes(x = reorder(state_abbr, crashes), y = crashes, fill = state_type)) +
  geom_col(alpha = 0.8) +
  scale_fill_manual(values = c(
    "Legalized" = apep_colors["legal"],
    "Never Legal" = apep_colors["illegal"]
  )) +
  scale_y_continuous(labels = scales::comma) +
  coord_flip() +
  labs(
    title = "Total Fatal Crashes by State, 2001-2019",
    subtitle = "Western marijuana states and comparison states",
    x = NULL,
    y = "Number of Fatal Crashes",
    fill = "Marijuana\nLegalization",
    caption = "Source: FARS (NHTSA). Legalized = enacted recreational marijuana during study period."
  ) +
  theme_apep()

ggsave(file.path(dir_figs, "fig09_crashes_by_state.pdf"), fig9,
       width = 8, height = 8, dpi = 300)
ggsave(file.path(dir_figs, "fig09_crashes_by_state.png"), fig9,
       width = 8, height = 8, dpi = 300)

message("  Saved fig09_crashes_by_state")

# =============================================================================
# Summary
# =============================================================================

message("\n", strrep("=", 60))
message("National figures complete!")
message("Figures saved to: ", dir_figs)
message(strrep("=", 60))

# List all figures
message("\nGenerated figures:")
list.files(dir_figs, pattern = "^fig0[0-9]_.*\\.(pdf|png)$") %>%
  unique() %>%
  sort() %>%
  walk(~ message("  ", .x))
