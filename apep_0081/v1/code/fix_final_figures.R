# =============================================================================
# Paper 108: Final Figure Fixes
# =============================================================================

source(here::here("output/paper_108/code/00_packages.R"))

# Load clean data
fars <- readRDS(file.path(dir_data, "fars_analysis_policy_fixed_clean.rds"))
states_sf <- readRDS(file.path(dir_data, "states_sf.rds"))

THC_YEARS <- c(2018, 2019)
THC_YEAR_LABEL <- "2018-2019"

message("Loaded data")

# =============================================================================
# FIX Figure 10: CO-WY Border - MUST show BOTH THC Positive and THC Negative
# =============================================================================

message("Fixing Figure 10: CO-WY border (both THC categories)...")

# Convert to spatial
fars_sf <- fars %>%
  filter(!is.na(x_albers) & !is.na(y_albers)) %>%
  st_as_sf(coords = c("x_albers", "y_albers"), crs = 5070)

co_wy_bbox <- list(north = 41.5, south = 40.0, east = -103.0, west = -106.5)

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

# Create THC status with both categories
crashes_tested <- crashes_zoom %>%
  filter(!is.na(thc_positive)) %>%
  mutate(
    thc_status = factor(
      ifelse(thc_positive, "THC Positive", "THC Negative"),
      levels = c("THC Positive", "THC Negative")
    )
  )

# Check we have both categories
message("  THC Positive: ", sum(crashes_tested$thc_status == "THC Positive"))
message("  THC Negative: ", sum(crashes_tested$thc_status == "THC Negative"))

n_crashes <- nrow(crashes_tested)

fig10 <- ggplot() +
  geom_sf(data = states_zoom, fill = "grey98", color = "grey50", linewidth = 0.5) +
  # Plot THC Negative first (so positive shows on top)
  geom_sf(data = filter(crashes_tested, thc_status == "THC Negative"),
          aes(color = thc_status), alpha = 0.6, size = 1) +
  geom_sf(data = filter(crashes_tested, thc_status == "THC Positive"),
          aes(color = thc_status), alpha = 0.8, size = 1.5) +
  scale_color_manual(
    values = c("THC Positive" = "#E41A1C", "THC Negative" = "#999999"),
    name = "THC Test Result",
    drop = FALSE  # Keep both levels even if one is empty
  ) +
  geom_sf_text(data = st_centroid(states_zoom), aes(label = state_abbr),
               size = 4, fontface = "bold", color = "grey30") +
  labs(
    title = "Fatal Crashes at the Colorado-Wyoming Border",
    subtitle = paste0(THC_YEAR_LABEL, " (N = ", format(n_crashes, big.mark = ","), " tested crashes)"),
    caption = "Source: FARS. THC-positive (red) vs THC-negative (gray) among tested drivers."
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
message("  Saved fig10")

# =============================================================================
# FIX Figure 28: Border Pairs - Update to 2018-2019
# =============================================================================

message("Fixing Figure 28: Border pairs (2018-2019)...")

border_pairs <- tribble(
  ~legal, ~illegal, ~pair_name,
  "CO", "WY", "CO-WY",
  "WA", "ID", "WA-ID",
  "OR", "ID", "OR-ID",
  "NV", "UT", "NV-UT"
)

pair_data <- list()
for (i in 1:nrow(border_pairs)) {
  bp <- border_pairs[i, ]

  legal_data <- fars %>%
    filter(state_abbr == bp$legal, year %in% THC_YEARS, !is.na(thc_positive)) %>%
    summarise(
      state = bp$legal,
      side = "Legal",
      tested = n(),
      thc_pos = sum(thc_positive),
      pct_thc = 100 * thc_pos / tested
    )

  illegal_data <- fars %>%
    filter(state_abbr == bp$illegal, year %in% THC_YEARS, !is.na(thc_positive)) %>%
    summarise(
      state = bp$illegal,
      side = "Illegal",
      tested = n(),
      thc_pos = sum(thc_positive),
      pct_thc = 100 * thc_pos / tested
    )

  pair_data[[i]] <- bind_rows(legal_data, illegal_data) %>%
    mutate(pair = bp$pair_name)
}

pair_df <- bind_rows(pair_data)

fig28 <- ggplot(pair_df, aes(x = pair, y = pct_thc, fill = side)) +
  geom_col(position = position_dodge(width = 0.7), alpha = 0.8, width = 0.6) +
  scale_fill_manual(values = c("Legal" = "#4DAF4A", "Illegal" = "#FF7F00")) +
  labs(
    title = "THC-Positive Rates by Border Pair",
    subtitle = paste0(THC_YEAR_LABEL, ", comparing adjacent legal vs illegal states"),
    x = "Border Pair",
    y = "Percent THC-Positive",
    fill = "State Type",
    caption = "Source: FARS drug test data."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(dir_figs, "fig28_border_pairs.pdf"), fig28, width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig28_border_pairs.png"), fig28, width = 10, height = 6, dpi = 300)
message("  Saved fig28")

# =============================================================================
# FIX Figure 29: RDD CO-WY - Update to 2018-2019
# =============================================================================

message("Fixing Figure 29: RDD CO-WY (2018-2019)...")

co_wy_data <- fars %>%
  filter(state_abbr %in% c("CO", "WY"),
         year %in% THC_YEARS,
         !is.na(thc_positive),
         !is.na(dist_to_border_km),
         dist_to_border_km < 150) %>%
  mutate(
    dist_signed = ifelse(state_abbr == "CO", -dist_to_border_km, dist_to_border_km)
  )

# Bin data
co_wy_binned <- co_wy_data %>%
  mutate(dist_bin = round(dist_signed / 10) * 10) %>%
  group_by(dist_bin, state_abbr) %>%
  summarise(
    n = n(),
    thc_pos = sum(thc_positive),
    pct_thc = 100 * thc_pos / n,
    se = sqrt(pct_thc * (100 - pct_thc) / n),
    .groups = "drop"
  ) %>%
  filter(n >= 10)

fig29 <- ggplot(co_wy_binned, aes(x = dist_bin, y = pct_thc, color = state_abbr)) +
  geom_vline(xintercept = 0, linetype = "solid", color = "grey30", linewidth = 1) +
  geom_point(aes(size = n), alpha = 0.7) +
  geom_smooth(method = "loess", se = TRUE, alpha = 0.2) +
  scale_color_manual(
    values = c("CO" = "#4DAF4A", "WY" = "#FF7F00"),
    labels = c("CO" = "Colorado (Legal)", "WY" = "Wyoming (Illegal)")
  ) +
  scale_size_continuous(range = c(2, 8), guide = "none") +
  annotate("text", x = -75, y = max(co_wy_binned$pct_thc, na.rm = TRUE) * 0.9,
           label = "Colorado\n(Legal)", hjust = 0.5, size = 4, fontface = "bold") +
  annotate("text", x = 75, y = max(co_wy_binned$pct_thc, na.rm = TRUE) * 0.9,
           label = "Wyoming\n(Illegal)", hjust = 0.5, size = 4, fontface = "bold") +
  labs(
    title = "THC-Positive Rate at the Colorado-Wyoming Border",
    subtitle = paste0("RDD-style plot, ", THC_YEAR_LABEL, " (10km bins)"),
    x = "Distance from Border (km, negative = Colorado side)",
    y = "Percent THC-Positive",
    color = NULL,
    caption = "Source: FARS. Point size proportional to sample size. LOESS fit with 95% CI."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(dir_figs, "fig29_rdd_co_wy.pdf"), fig29, width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig29_rdd_co_wy.png"), fig29, width = 10, height = 6, dpi = 300)
message("  Saved fig29")

# =============================================================================
# FIX Figure 7: Geocoding Quality - Only show available years
# =============================================================================

message("Fixing Figure 7: Geocoding quality (only available years)...")

# Load raw data
fars_all <- readRDS(file.path(dir_data_raw, "fars_accident_all.rds"))

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
  ) %>%
  filter(year %in% c(2001:2005, 2016:2019))  # Only years we have

fig7 <- ggplot(geocode_quality, aes(x = year, y = pct_geocoded)) +
  geom_line(color = "#4DAF4A", linewidth = 1) +
  geom_point(color = "#4DAF4A", size = 2) +
  geom_hline(yintercept = 90, linetype = "dashed", color = "grey50") +
  annotate("text", x = 2002, y = 91, label = "90% threshold", hjust = 0, size = 3, color = "grey50") +
  scale_x_continuous(breaks = sort(unique(geocode_quality$year))) +
  scale_y_continuous(limits = c(70, 100)) +
  labs(
    title = "FARS Geocoding Quality Over Time",
    subtitle = "Percent of fatal crashes with valid coordinates (2001-2005, 2016-2019)",
    x = "Year",
    y = "Percent Geocoded",
    caption = "Source: FARS. Gap 2006-2015 reflects data not included in sample."
  ) +
  theme_apep()

ggsave(file.path(dir_figs, "fig07_geocoding_quality.pdf"), fig7, width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig07_geocoding_quality.png"), fig7, width = 10, height = 6, dpi = 300)
message("  Saved fig07")

# =============================================================================
# FIX Figure 8: Drug Testing Rate - Debug and fix
# =============================================================================

message("Fixing Figure 8: Drug testing rate (debugging)...")

# Load drugs data to count unique tested crashes
drugs_raw <- readRDS(file.path(dir_data_raw, "fars_drugs_all.rds"))

# Count crashes with drug tests by state (2018-2019)
crashes_with_tests <- drugs_raw %>%
  filter(year %in% THC_YEARS) %>%
  mutate(state_fips = sprintf("%02d", as.integer(state))) %>%
  distinct(st_case, state_fips, year) %>%
  group_by(state_fips) %>%
  summarise(crashes_tested = n(), .groups = "drop")

# Total crashes by state
total_crashes <- fars %>%
  filter(year %in% THC_YEARS) %>%
  group_by(state_fips) %>%
  summarise(total = n(), .groups = "drop")

# State abbreviation lookup
state_codes <- fars %>%
  select(state_fips, state_abbr) %>%
  distinct()

# Merge
testing_rate <- total_crashes %>%
  left_join(crashes_with_tests, by = "state_fips") %>%
  left_join(state_codes, by = "state_fips") %>%
  mutate(
    crashes_tested = ifelse(is.na(crashes_tested), 0, crashes_tested),
    pct_tested = 100 * crashes_tested / total
  ) %>%
  arrange(desc(pct_tested))

# Debug output
message("  Testing rate summary:")
message("    Range: ", round(min(testing_rate$pct_tested), 1), "% to ",
        round(max(testing_rate$pct_tested), 1), "%")
message("    Mean: ", round(mean(testing_rate$pct_tested), 1), "%")

# Print states with extreme values
message("  States with lowest testing:")
for (i in 1:3) {
  row <- testing_rate %>% arrange(pct_tested) %>% slice(i)
  message("    ", row$state_abbr, ": ", round(row$pct_tested, 1), "% (", row$crashes_tested, "/", row$total, ")")
}

fig8 <- ggplot(testing_rate, aes(x = reorder(state_abbr, pct_tested), y = pct_tested)) +
  geom_col(fill = "#4DAF4A", alpha = 0.8) +
  geom_hline(yintercept = mean(testing_rate$pct_tested), linetype = "dashed", color = "red") +
  annotate("text", x = 1, y = mean(testing_rate$pct_tested) + 3,
           label = paste0("Mean: ", round(mean(testing_rate$pct_tested), 1), "%"),
           hjust = 0, size = 3, color = "red") +
  coord_flip() +
  scale_y_continuous(limits = c(0, 100)) +
  labs(
    title = "Drug Testing Rate by State",
    subtitle = paste0("Percent of fatal crashes with any drug test result, ", THC_YEAR_LABEL),
    x = NULL,
    y = "Percent of Crashes with Drug Test",
    caption = "Source: FARS drugs file. Rate = crashes with any drug record / total crashes."
  ) +
  theme_apep()

ggsave(file.path(dir_figs, "fig08_testing_rate_by_state.pdf"), fig8, width = 8, height = 8, dpi = 300)
ggsave(file.path(dir_figs, "fig08_testing_rate_by_state.png"), fig8, width = 8, height = 8, dpi = 300)
message("  Saved fig08")

message("\nAll final figures fixed!")
