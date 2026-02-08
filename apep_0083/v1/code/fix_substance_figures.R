# =============================================================================
# Fix Substance Category Figures - Restrict to 2018-2019 only
# =============================================================================

source(here::here("output/paper_108/code/00_packages.R"))

# Load clean data
fars <- readRDS(file.path(dir_data, "fars_analysis_policy_fixed_clean.rds"))
states_sf <- readRDS(file.path(dir_data, "states_sf.rds"))

THC_YEARS <- c(2018, 2019)
THC_YEAR_LABEL <- "2018-2019"

message("Loaded data. Restricting substance figures to 2018-2019.")

# =============================================================================
# Figure 5: Crashes by Hour - Restrict to 2018-2019
# =============================================================================

message("Fixing Figure 5: Crashes by hour (2018-2019 only)...")

# Filter to years with THC data
fig5_data <- fars %>%
  filter(year %in% THC_YEARS, !is.na(hour), hour < 24)

fig5 <- ggplot(fig5_data, aes(x = hour, fill = substance_cat)) +
  geom_bar(position = "stack", alpha = 0.8) +
  scale_fill_manual(values = substance_colors) +
  scale_x_continuous(breaks = seq(0, 23, 3),
                     labels = c("12am", "3am", "6am", "9am", "12pm", "3pm", "6pm", "9pm")) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Fatal Crashes by Hour of Day and Substance Involvement",
    subtitle = paste0("Western States, ", THC_YEAR_LABEL, " (THC data available)"),
    x = "Hour of Day",
    y = "Number of Crashes",
    fill = "Substance\nInvolvement",
    caption = "Source: FARS. Substance categories use THC data available only from 2018."
  ) +
  theme_apep()

ggsave(file.path(dir_figs, "fig05_crashes_by_hour.pdf"), fig5, width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig05_crashes_by_hour.png"), fig5, width = 10, height = 6, dpi = 300)
message("  Saved fig05")

# =============================================================================
# Figure 11: I-25 Corridor - Restrict to 2018-2019
# =============================================================================

message("Fixing Figure 11: I-25 corridor (2018-2019 only)...")

# Convert to spatial
fars_sf <- fars %>%
  filter(!is.na(x_albers) & !is.na(y_albers)) %>%
  st_as_sf(coords = c("x_albers", "y_albers"), crs = 5070)

i25_bbox <- list(north = 41.2, south = 39.5, east = -104.5, west = -105.5)

bbox_sf <- st_as_sfc(st_bbox(c(
  xmin = i25_bbox$west, ymin = i25_bbox$south,
  xmax = i25_bbox$east, ymax = i25_bbox$north
), crs = 4326)) %>%
  st_transform(crs = 5070)

bbox_albers <- st_bbox(bbox_sf)

# Filter to 2018-2019 only
fars_i25 <- fars_sf %>%
  filter(year %in% THC_YEARS, state_abbr %in% c("CO", "WY"))

crashes_zoom <- fars_i25 %>% st_crop(bbox_albers)
states_zoom <- states_sf %>% st_crop(bbox_albers)

fig11 <- ggplot() +
  geom_sf(data = states_zoom, fill = "grey98", color = "grey50", linewidth = 0.5) +
  geom_sf(data = crashes_zoom, aes(color = substance_cat), alpha = 0.6, size = 1) +
  scale_color_manual(values = substance_colors, name = "Substance\nInvolvement") +
  geom_sf_text(data = st_centroid(states_zoom), aes(label = state_abbr),
               size = 4, fontface = "bold", color = "grey30") +
  labs(
    title = "Fatal Crashes Along the I-25 Corridor",
    subtitle = paste0("Denver to Wyoming border, ", THC_YEAR_LABEL, "\nN = ", format(nrow(crashes_zoom), big.mark = ","), " crashes"),
    caption = "Source: FARS. Substance categories based on 2018+ drug name data."
  ) +
  annotation_scale(location = "br", width_hint = 0.3) +
  theme_apep() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank()
  )

ggsave(file.path(dir_figs, "fig11_i25_corridor.pdf"), fig11, width = 8, height = 12, dpi = 300)
ggsave(file.path(dir_figs, "fig11_i25_corridor.png"), fig11, width = 8, height = 12, dpi = 300)
message("  Saved fig11")

# =============================================================================
# Figure 12: Denver Metro - Restrict to 2018-2019
# =============================================================================

message("Fixing Figure 12: Denver metro (2018-2019 only)...")

denver_bbox <- list(north = 40.1, south = 39.5, east = -104.5, west = -105.3)

bbox_sf <- st_as_sfc(st_bbox(c(
  xmin = denver_bbox$west, ymin = denver_bbox$south,
  xmax = denver_bbox$east, ymax = denver_bbox$north
), crs = 4326)) %>%
  st_transform(crs = 5070)

bbox_albers <- st_bbox(bbox_sf)

# Filter to 2018-2019 only
fars_denver <- fars_sf %>%
  filter(year %in% THC_YEARS, state_abbr == "CO")

crashes_zoom <- fars_denver %>% st_crop(bbox_albers)
states_zoom <- states_sf %>% st_crop(bbox_albers)

fig12 <- ggplot() +
  geom_sf(data = states_zoom, fill = "grey98", color = "grey50", linewidth = 0.5) +
  geom_sf(data = crashes_zoom, aes(color = substance_cat), alpha = 0.6, size = 1) +
  scale_color_manual(values = substance_colors, name = "Substance\nInvolvement") +
  labs(
    title = "Fatal Crashes in the Denver Metropolitan Area",
    subtitle = paste0(THC_YEAR_LABEL, " (N = ", format(nrow(crashes_zoom), big.mark = ","), " crashes)"),
    caption = "Source: FARS. Substance categories based on 2018+ drug name data."
  ) +
  annotation_scale(location = "br", width_hint = 0.3) +
  theme_apep() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank()
  )

ggsave(file.path(dir_figs, "fig12_denver_metro.pdf"), fig12, width = 10, height = 10, dpi = 300)
ggsave(file.path(dir_figs, "fig12_denver_metro.png"), fig12, width = 10, height = 10, dpi = 300)
message("  Saved fig12")

message("\nAll substance figures fixed to use 2018-2019 only!")
