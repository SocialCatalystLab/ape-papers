# =============================================================================
# Paper 108: Fix All Figure Issues Identified by Advisor Review
# =============================================================================

source(here::here("output/paper_108/code/00_packages.R"))

# Load the CLEAN data (after deduplication and fixes)
fars <- readRDS(file.path(dir_data, "fars_analysis_policy_fixed_clean.rds"))
states_sf <- readRDS(file.path(dir_data, "states_sf.rds"))

message("Loaded ", format(nrow(fars), big.mark = ","), " crashes")
message("Years available: ", paste(sort(unique(fars$year)), collapse = ", "))

# Document actual data coverage
YEAR_LABEL <- "2001-2005 and 2016-2019"
THC_YEARS <- c(2018, 2019)  # THC only reliable from 2018+
THC_YEAR_LABEL <- "2018-2019"

# =============================================================================
# FIX 1: Figure 2 - Annual crashes (correct year label)
# =============================================================================

message("Fixing Figure 2: Annual crashes...")

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
  scale_x_continuous(breaks = sort(unique(annual_crashes$year))) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Fatal Traffic Crashes by Year, Western States",
    subtitle = YEAR_LABEL,
    x = "Year",
    y = "Number of Fatal Crashes",
    caption = "Source: FARS (NHTSA). Gap reflects data availability (2006-2015 not in sample)."
  ) +
  theme_apep()

ggsave(file.path(dir_figs, "fig02_annual_crashes.pdf"), fig2, width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig02_annual_crashes.png"), fig2, width = 10, height = 6, dpi = 300)
message("  Saved fig02_annual_crashes")

# =============================================================================
# FIX 2: Figure 3 - THC rate (restrict to 2018-2019 only)
# =============================================================================

message("Fixing Figure 3: THC rate (2018-2019 only)...")

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
    state_type = ifelse(ever_rec_legal, "Legalized States", "Never-Legal States")
  )

fig3 <- ggplot(thc_by_year, aes(x = factor(year), y = pct_thc, fill = state_type)) +
  geom_col(position = position_dodge(width = 0.7), alpha = 0.8, width = 0.6) +
  geom_text(aes(label = paste0(round(pct_thc, 1), "%")),
            position = position_dodge(width = 0.7), vjust = -0.5, size = 3) +
  scale_fill_manual(values = c(
    "Legalized States" = "#4DAF4A",
    "Never-Legal States" = "#FF7F00"
  )) +
  labs(
    title = "THC-Positive Rate Among Tested Fatal Crash Drivers",
    subtitle = paste0("Western States, ", THC_YEAR_LABEL, " (drug name data available)"),
    x = "Year",
    y = "Percent THC-Positive",
    fill = "State Type",
    caption = "Source: FARS drug test data. THC identified via drugresname text matching."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(dir_figs, "fig03_thc_rate_over_time.pdf"), fig3, width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig03_thc_rate_over_time.png"), fig3, width = 10, height = 6, dpi = 300)
message("  Saved fig03_thc_rate_over_time")

# =============================================================================
# FIX 3: Figure 4 - Alcohol rate (correct year label, use drunk_dr)
# =============================================================================

message("Fixing Figure 4: Alcohol rate...")

alc_by_year <- fars %>%
  group_by(year, ever_rec_legal) %>%
  summarise(
    total = n(),
    alc_involved = sum(alc_involved, na.rm = TRUE),
    pct_alc = 100 * alc_involved / total,
    .groups = "drop"
  ) %>%
  mutate(
    state_type = ifelse(ever_rec_legal, "Legalized States", "Never-Legal States")
  )

fig4 <- ggplot(alc_by_year, aes(x = year, y = pct_alc, color = state_type)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  scale_color_manual(values = c(
    "Legalized States" = "#4DAF4A",
    "Never-Legal States" = "#FF7F00"
  )) +
  scale_x_continuous(breaks = sort(unique(alc_by_year$year))) +
  labs(
    title = "Alcohol-Involved Fatal Crashes Over Time",
    subtitle = paste0("Western States, ", YEAR_LABEL),
    x = "Year",
    y = "Percent Alcohol-Involved",
    color = "State Type",
    caption = "Source: FARS. Alcohol-involved = drunk_dr >= 1 (any driver with alcohol impairment)."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(dir_figs, "fig04_alcohol_rate_over_time.pdf"), fig4, width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig04_alcohol_rate_over_time.png"), fig4, width = 10, height = 6, dpi = 300)
message("  Saved fig04_alcohol_rate_over_time")

# =============================================================================
# FIX 4: Figure 5 - Crashes by hour (correct year label)
# =============================================================================

message("Fixing Figure 5: Crashes by hour...")

fig5 <- ggplot(fars %>% filter(!is.na(hour) & hour < 24),
               aes(x = hour, fill = substance_cat)) +
  geom_bar(position = "stack", alpha = 0.8) +
  scale_fill_manual(values = substance_colors) +
  scale_x_continuous(breaks = seq(0, 23, 3),
                     labels = c("12am", "3am", "6am", "9am", "12pm", "3pm", "6pm", "9pm")) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Fatal Crashes by Hour of Day and Substance Involvement",
    subtitle = paste0("Western States, ", YEAR_LABEL),
    x = "Hour of Day",
    y = "Number of Crashes",
    fill = "Substance\nInvolvement",
    caption = "Source: FARS (NHTSA). Substance involvement based on driver drug/alcohol tests."
  ) +
  theme_apep()

ggsave(file.path(dir_figs, "fig05_crashes_by_hour.pdf"), fig5, width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig05_crashes_by_hour.png"), fig5, width = 10, height = 6, dpi = 300)
message("  Saved fig05_crashes_by_hour")

# =============================================================================
# FIX 5: Figure 8 - Drug testing rate (CORRECT COMPUTATION)
# =============================================================================

message("Fixing Figure 8: Drug testing rate (correct computation)...")

# The correct way: for 2018-2019 only (when drug data is available),
# compute what % of crashes have ANY drug test result in the drugs file
# This requires going back to the raw drugs data

# Load raw drugs data to compute testing rate properly
drugs_raw <- readRDS(file.path(dir_data_raw, "fars_drugs_all.rds"))

# Count unique crashes in drugs file by state (2018-2019)
crashes_with_tests <- drugs_raw %>%
  filter(year %in% THC_YEARS) %>%
  mutate(state = as.character(state)) %>%
  distinct(st_case, state, year) %>%
  group_by(state) %>%
  summarise(crashes_tested = n(), .groups = "drop")

# Total crashes by state (2018-2019)
total_crashes <- fars %>%
  filter(year %in% THC_YEARS) %>%
  group_by(state_fips) %>%
  summarise(total = n(), .groups = "drop")

# Merge and compute rate
state_codes <- fars %>%
  select(state_fips, state_abbr) %>%
  distinct()

testing_rate <- total_crashes %>%
  left_join(crashes_with_tests, by = c("state_fips" = "state")) %>%
  left_join(state_codes, by = "state_fips") %>%
  mutate(
    crashes_tested = ifelse(is.na(crashes_tested), 0, crashes_tested),
    pct_tested = 100 * crashes_tested / total
  ) %>%
  arrange(desc(pct_tested))

message("  Testing rates range: ", round(min(testing_rate$pct_tested), 1),
        "% to ", round(max(testing_rate$pct_tested), 1), "%")
message("  Mean testing rate: ", round(mean(testing_rate$pct_tested), 1), "%")

fig8 <- ggplot(testing_rate, aes(x = reorder(state_abbr, pct_tested), y = pct_tested)) +
  geom_col(fill = apep_colors["legal"], alpha = 0.8) +
  geom_hline(yintercept = mean(testing_rate$pct_tested), linetype = "dashed", color = "red") +
  annotate("text", x = 1, y = mean(testing_rate$pct_tested) + 3,
           label = paste0("Mean: ", round(mean(testing_rate$pct_tested), 1), "%"),
           hjust = 0, size = 3, color = "red") +
  coord_flip() +
  labs(
    title = "Drug Testing Rate by State",
    subtitle = paste0("Percent of fatal crashes with any drug test result, ", THC_YEAR_LABEL),
    x = NULL,
    y = "Percent of Crashes with Drug Test",
    caption = "Source: FARS drugs file. Denominator = all fatal crashes; numerator = crashes with any drug test record."
  ) +
  theme_apep()

ggsave(file.path(dir_figs, "fig08_testing_rate_by_state.pdf"), fig8, width = 8, height = 8, dpi = 300)
ggsave(file.path(dir_figs, "fig08_testing_rate_by_state.png"), fig8, width = 8, height = 8, dpi = 300)
message("  Saved fig08_testing_rate_by_state")

# =============================================================================
# FIX 6: Figure 10 - CO-WY border (restrict to 2018-2019, fix legend)
# =============================================================================

message("Fixing Figure 10: CO-WY border zoom (2018-2019, with proper THC legend)...")

# Convert to spatial
fars_sf <- fars %>%
  filter(!is.na(x_albers) & !is.na(y_albers)) %>%
  st_as_sf(coords = c("x_albers", "y_albers"), crs = 5070)

co_wy_bbox <- list(north = 41.5, south = 40.0, east = -103.0, west = -106.5)

# Convert bbox to Albers
bbox_sf <- st_as_sfc(st_bbox(c(
  xmin = co_wy_bbox$west, ymin = co_wy_bbox$south,
  xmax = co_wy_bbox$east, ymax = co_wy_bbox$north
), crs = 4326)) %>%
  st_transform(crs = 5070)

bbox_albers <- st_bbox(bbox_sf)

# Filter to 2018-2019 for THC analysis
fars_co_wy <- fars_sf %>%
  filter(year %in% THC_YEARS, state_abbr %in% c("CO", "WY"))

crashes_zoom <- fars_co_wy %>% st_crop(bbox_albers)
states_zoom <- states_sf %>% st_crop(bbox_albers)

# Create THC status variable with proper labels
crashes_zoom <- crashes_zoom %>%
  mutate(
    thc_status = case_when(
      is.na(thc_positive) ~ "Not Tested",
      thc_positive == TRUE ~ "THC Positive",
      thc_positive == FALSE ~ "THC Negative"
    ),
    thc_status = factor(thc_status, levels = c("THC Positive", "THC Negative", "Not Tested"))
  )

# Filter to only tested crashes for cleaner visualization
crashes_tested <- crashes_zoom %>%
  filter(thc_status != "Not Tested")

n_crashes <- nrow(crashes_tested)

fig10 <- ggplot() +
  geom_sf(data = states_zoom, fill = "grey98", color = "grey50", linewidth = 0.5) +
  geom_sf(data = crashes_tested, aes(color = thc_status), alpha = 0.7, size = 1.2) +
  scale_color_manual(
    values = c(
      "THC Positive" = apep_colors["thc_positive"],
      "THC Negative" = "grey60"
    ),
    name = "THC Test Result"
  ) +
  geom_sf_text(data = st_centroid(states_zoom), aes(label = state_abbr),
               size = 4, fontface = "bold", color = "grey30") +
  labs(
    title = "Fatal Crashes at the Colorado-Wyoming Border",
    subtitle = paste0(THC_YEAR_LABEL, " (N = ", format(n_crashes, big.mark = ","), " tested crashes)"),
    caption = "Source: FARS. Only crashes with drug test results shown. THC identified via drugresname."
  ) +
  annotation_scale(location = "br", width_hint = 0.3) +
  theme_apep() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank(),
    legend.position = "bottom"
  )

ggsave(file.path(dir_figs, "fig10_co_wy_border.pdf"), fig10, width = 12, height = 10, dpi = 300)
ggsave(file.path(dir_figs, "fig10_co_wy_border.png"), fig10, width = 12, height = 10, dpi = 300)
message("  Saved fig10_co_wy_border")

# =============================================================================
# FIX 7: Figure 18 - BAC distribution (better histogram)
# =============================================================================

message("Fixing Figure 18: BAC distribution...")

# Filter to drivers with positive BAC (> 0)
bac_data <- fars %>%
  filter(!is.na(max_bac), max_bac > 0, max_bac <= 0.5)

message("  BAC > 0 cases: ", nrow(bac_data))
message("  BAC range: ", round(min(bac_data$max_bac), 3), " to ", round(max(bac_data$max_bac), 3))

fig18 <- ggplot(bac_data, aes(x = max_bac)) +
  geom_histogram(binwidth = 0.01, fill = apep_colors["alcohol_positive"],
                 alpha = 0.7, color = "white", boundary = 0) +
  geom_vline(xintercept = 0.08, linetype = "dashed", color = "red", linewidth = 1) +
  annotate("text", x = 0.09, y = Inf, label = "Legal limit\n(0.08)", hjust = 0, vjust = 1.5,
           size = 3, color = "red") +
  scale_x_continuous(breaks = seq(0, 0.5, 0.05), limits = c(0, 0.45)) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Blood Alcohol Concentration (BAC) Distribution",
    subtitle = paste0("Drivers with BAC > 0 in fatal crashes, Western States, ", YEAR_LABEL),
    x = "Blood Alcohol Concentration (BAC)",
    y = "Number of Drivers",
    caption = "Source: FARS. Includes only drivers with positive alcohol test results."
  ) +
  theme_apep()

ggsave(file.path(dir_figs, "fig18_bac_distribution.pdf"), fig18, width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig18_bac_distribution.png"), fig18, width = 10, height = 6, dpi = 300)
message("  Saved fig18_bac_distribution")

# =============================================================================
# FIX 8: Figure 20 - Polysubstance (restrict to 2018-2019)
# =============================================================================

message("Fixing Figure 20: Polysubstance (2018-2019 only)...")

poly_data <- fars %>%
  filter(year %in% THC_YEARS, !is.na(thc_positive)) %>%
  mutate(
    category = case_when(
      thc_positive & alc_involved ~ "Both THC + Alcohol",
      thc_positive & !alc_involved ~ "THC Only",
      !thc_positive & alc_involved ~ "Alcohol Only",
      TRUE ~ "Neither"
    )
  ) %>%
  count(year, category) %>%
  group_by(year) %>%
  mutate(pct = 100 * n / sum(n)) %>%
  ungroup()

fig20 <- ggplot(poly_data, aes(x = factor(year), y = pct, fill = category)) +
  geom_col(alpha = 0.8, position = "stack") +
  scale_fill_manual(values = c(
    "THC Only" = apep_colors["thc_positive"],
    "Alcohol Only" = apep_colors["alcohol_positive"],
    "Both THC + Alcohol" = apep_colors["both"],
    "Neither" = apep_colors["neither"]
  )) +
  labs(
    title = "Substance Involvement Breakdown",
    subtitle = paste0("Western States, ", THC_YEAR_LABEL, " (crashes with THC test data)"),
    x = "Year",
    y = "Percent of Tested Crashes",
    fill = "Substance\nCategory",
    caption = "Source: FARS. Limited to crashes where THC test data is available (2018+)."
  ) +
  theme_apep()

ggsave(file.path(dir_figs, "fig20_polysubstance.pdf"), fig20, width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig20_polysubstance.png"), fig20, width = 10, height = 6, dpi = 300)
message("  Saved fig20_polysubstance")

# =============================================================================
# FIX 9: Border figures - restrict THC to 2018-2019
# =============================================================================

message("Fixing border figures (2018-2019 only)...")

border_data <- fars %>%
  filter(year %in% THC_YEARS, !is.na(dist_to_border_km), dist_to_border_km < 200) %>%
  mutate(
    dist_bin = cut(dist_sign,
                   breaks = c(-200, -150, -100, -75, -50, -25, -10, 0,
                              10, 25, 50, 75, 100, 150, 200),
                   labels = c("-175", "-125", "-87", "-62", "-37", "-17", "-5",
                              "5", "17", "37", "62", "87", "125", "175")),
    side = ifelse(dist_sign < 0, "Legal State", "Illegal State")
  )

# Figure 24: Crash density by distance
border_counts <- border_data %>%
  group_by(dist_bin, side) %>%
  summarise(crashes = n(), .groups = "drop") %>%
  filter(!is.na(dist_bin)) %>%
  mutate(dist_num = as.numeric(as.character(dist_bin)))

fig24 <- ggplot(border_counts, aes(x = dist_num, y = crashes, fill = side)) +
  geom_col(alpha = 0.8, width = 20) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey30", linewidth = 1) +
  scale_fill_manual(values = c(
    "Legal State" = apep_colors["legal"],
    "Illegal State" = apep_colors["illegal"]
  )) +
  scale_x_continuous(breaks = seq(-150, 150, 50)) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Fatal Crashes by Distance to Legal/Illegal State Border",
    subtitle = paste0("Western marijuana borders, ", THC_YEAR_LABEL),
    x = "Distance to Border (km, negative = legal side)",
    y = "Number of Crashes",
    fill = NULL,
    caption = "Source: FARS. Distance computed to nearest marijuana legalization border."
  ) +
  theme_apep() +
  theme(legend.position = "none")

ggsave(file.path(dir_figs, "fig24_crash_density_border.pdf"), fig24, width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig24_crash_density_border.png"), fig24, width = 10, height = 6, dpi = 300)
message("  Saved fig24_crash_density_border")

# Figure 25: THC rate by distance
thc_by_dist <- border_data %>%
  filter(!is.na(thc_positive), !is.na(dist_bin)) %>%
  group_by(dist_bin, side) %>%
  summarise(
    tested = n(),
    thc_pos = sum(thc_positive),
    pct_thc = 100 * thc_pos / tested,
    se = sqrt(pct_thc * (100 - pct_thc) / tested),
    .groups = "drop"
  ) %>%
  filter(tested >= 20) %>%
  mutate(dist_num = as.numeric(as.character(dist_bin)))

fig25 <- ggplot(thc_by_dist, aes(x = dist_num, y = pct_thc, color = side)) +
  geom_point(size = 3) +
  geom_line(linewidth = 1) +
  geom_ribbon(aes(ymin = pct_thc - 1.96*se, ymax = pct_thc + 1.96*se, fill = side),
              alpha = 0.2, color = NA) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey30", linewidth = 1) +
  scale_color_manual(values = c(
    "Legal State" = apep_colors["legal"],
    "Illegal State" = apep_colors["illegal"]
  )) +
  scale_fill_manual(values = c(
    "Legal State" = apep_colors["legal"],
    "Illegal State" = apep_colors["illegal"]
  )) +
  scale_x_continuous(breaks = seq(-150, 150, 50)) +
  labs(
    title = "THC-Positive Rate by Distance to Legal/Illegal Border",
    subtitle = paste0("Western marijuana borders, ", THC_YEAR_LABEL),
    x = "Distance to Border (km, negative = legal side)",
    y = "Percent THC-Positive",
    color = NULL, fill = NULL,
    caption = "Source: FARS drug test data. Shaded area = 95% CI. Minimum 20 tested crashes per bin."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(dir_figs, "fig25_thc_rate_border.pdf"), fig25, width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig25_thc_rate_border.png"), fig25, width = 10, height = 6, dpi = 300)
message("  Saved fig25_thc_rate_border")

# =============================================================================
# Summary
# =============================================================================

message("\n", strrep("=", 60))
message("All figures fixed!")
message("Key changes:")
message("  - All year labels updated to: ", YEAR_LABEL)
message("  - All THC analyses restricted to: ", THC_YEAR_LABEL)
message("  - Drug testing rate computed correctly")
message("  - THC positive/negative legend fixed")
message(strrep("=", 60))
