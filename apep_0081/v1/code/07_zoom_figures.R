# =============================================================================
# Paper 108: Geocoded Atlas of US Traffic Fatalities 2001-2023
# 07_zoom_figures.R - Granularity showcase zoom maps (Section 4)
# =============================================================================

source(here::here("output/paper_108/code/00_packages.R"))

# Load data
fars <- readRDS(file.path(dir_data, "fars_analysis_policy_fixed_clean.rds"))
states_sf <- readRDS(file.path(dir_data, "states_sf.rds"))

# Convert FARS to spatial
fars_sf <- fars %>%
  filter(!is.na(x_albers) & !is.na(y_albers)) %>%
  st_as_sf(coords = c("x_albers", "y_albers"), crs = 5070)

message("Loaded ", format(nrow(fars), big.mark = ","), " crashes")

# =============================================================================
# Helper Function: Create Zoom Map
# =============================================================================

create_zoom_map <- function(fars_data, states_data, bbox, title, subtitle,
                            color_by = "substance_cat", show_roads = FALSE) {
  # Filter to bounding box (in lat/lon)
  # First convert bbox to Albers
  bbox_sf <- st_as_sfc(st_bbox(c(
    xmin = bbox$west, ymin = bbox$south,
    xmax = bbox$east, ymax = bbox$north
  ), crs = 4326)) %>%
    st_transform(crs = 5070)

  bbox_albers <- st_bbox(bbox_sf)

  # Filter crashes
  crashes_zoom <- fars_data %>%
    st_crop(bbox_albers)

  # Filter states
  states_zoom <- states_data %>%
    st_crop(bbox_albers)

  # Create plot
  p <- ggplot() +
    # State boundaries
    geom_sf(data = states_zoom, fill = "grey98", color = "grey50", linewidth = 0.5)

  # Add crash points
  if (color_by == "substance_cat") {
    p <- p +
      geom_sf(data = crashes_zoom, aes(color = substance_cat), alpha = 0.6, size = 1) +
      scale_color_manual(values = substance_colors, name = "Substance\nInvolvement")
  } else if (color_by == "rec_legal") {
    p <- p +
      geom_sf(data = crashes_zoom, aes(color = factor(rec_legal)), alpha = 0.6, size = 1) +
      scale_color_manual(
        values = c("TRUE" = apep_colors["legal"], "FALSE" = apep_colors["illegal"]),
        labels = c("TRUE" = "Legal State", "FALSE" = "Illegal State"),
        name = "Marijuana\nStatus"
      )
  } else if (color_by == "thc_positive") {
    p <- p +
      geom_sf(data = crashes_zoom %>% filter(!is.na(thc_positive)),
              aes(color = factor(thc_positive)), alpha = 0.7, size = 1.2) +
      scale_color_manual(
        values = c("TRUE" = apep_colors["thc_positive"], "FALSE" = "grey70"),
        labels = c("TRUE" = "THC Positive", "FALSE" = "THC Negative"),
        name = "THC Test\nResult"
      )
  }

  # Add state labels
  state_centers <- st_centroid(states_zoom)
  p <- p +
    geom_sf_text(data = state_centers, aes(label = state_abbr),
                 size = 4, fontface = "bold", color = "grey30")

  # Styling
  p <- p +
    labs(
      title = title,
      subtitle = subtitle,
      caption = "Source: FARS (NHTSA). Each point is one fatal crash."
    ) +
    annotation_scale(location = "br", width_hint = 0.3) +
    theme_apep() +
    theme(
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      axis.title = element_blank(),
      panel.grid = element_blank()
    )

  # Add crash count
  n_crashes <- nrow(crashes_zoom)
  p <- p +
    labs(subtitle = paste0(subtitle, "\nN = ", format(n_crashes, big.mark = ","), " fatal crashes"))

  return(p)
}

# =============================================================================
# Figure 10: Colorado-Wyoming Border Zoom
# =============================================================================

message("Creating Figure 10: CO-WY border zoom...")

co_wy_bbox <- list(
  north = 41.5, south = 40.0,
  east = -103.0, west = -106.5
)

# Filter to post-legalization period for most interesting patterns
fars_co_wy <- fars_sf %>%
  filter(year >= 2016,
         state_abbr %in% c("CO", "WY"))

fig10 <- create_zoom_map(
  fars_data = fars_co_wy,
  states_data = states_sf,
  bbox = co_wy_bbox,
  title = "Fatal Crashes at the Colorado-Wyoming Border",
  subtitle = "2016-2019 (post-legalization period)",
  color_by = "thc_positive"
)

# Add border emphasis
co_state <- states_sf %>% filter(state_abbr == "CO")
wy_state <- states_sf %>% filter(state_abbr == "WY")
border <- st_intersection(st_boundary(co_state), st_boundary(wy_state))

if (nrow(border) > 0) {
  fig10 <- fig10 +
    geom_sf(data = border, color = "red", linewidth = 1.5, linetype = "solid")
}

ggsave(file.path(dir_figs, "fig10_co_wy_border.pdf"), fig10,
       width = 12, height = 10, dpi = 300)
ggsave(file.path(dir_figs, "fig10_co_wy_border.png"), fig10,
       width = 12, height = 10, dpi = 300)

message("  Saved fig10_co_wy_border")

# =============================================================================
# Figure 11: I-25 Corridor Zoom (Denver to Wyoming)
# =============================================================================

message("Creating Figure 11: I-25 corridor zoom...")

i25_bbox <- list(
  north = 41.2, south = 39.5,
  east = -104.5, west = -105.5
)

fars_i25 <- fars_sf %>%
  filter(year >= 2016, state_abbr %in% c("CO", "WY"))

fig11 <- create_zoom_map(
  fars_data = fars_i25,
  states_data = states_sf,
  bbox = i25_bbox,
  title = "Fatal Crashes Along the I-25 Corridor",
  subtitle = "Denver to Wyoming border, 2016-2019",
  color_by = "substance_cat"
)

ggsave(file.path(dir_figs, "fig11_i25_corridor.pdf"), fig11,
       width = 8, height = 12, dpi = 300)
ggsave(file.path(dir_figs, "fig11_i25_corridor.png"), fig11,
       width = 8, height = 12, dpi = 300)

message("  Saved fig11_i25_corridor")

# =============================================================================
# Figure 12: Denver Metro Zoom
# =============================================================================

message("Creating Figure 12: Denver metro zoom...")

denver_bbox <- list(
  north = 40.1, south = 39.5,
  east = -104.5, west = -105.3
)

fars_denver <- fars_sf %>%
  filter(year >= 2016, state_abbr == "CO")

fig12 <- create_zoom_map(
  fars_data = fars_denver,
  states_data = states_sf,
  bbox = denver_bbox,
  title = "Fatal Crashes in the Denver Metropolitan Area",
  subtitle = "2016-2019",
  color_by = "substance_cat"
)

ggsave(file.path(dir_figs, "fig12_denver_metro.pdf"), fig12,
       width = 10, height = 10, dpi = 300)
ggsave(file.path(dir_figs, "fig12_denver_metro.png"), fig12,
       width = 10, height = 10, dpi = 300)

message("  Saved fig12_denver_metro")

# =============================================================================
# Figure 13: Washington-Idaho Border Zoom
# =============================================================================

message("Creating Figure 13: WA-ID border zoom...")

wa_id_bbox <- list(
  north = 47.8, south = 46.0,
  east = -116.0, west = -118.5
)

fars_wa_id <- fars_sf %>%
  filter(year >= 2016, state_abbr %in% c("WA", "ID"))

fig13 <- create_zoom_map(
  fars_data = fars_wa_id,
  states_data = states_sf,
  bbox = wa_id_bbox,
  title = "Fatal Crashes at the Washington-Idaho Border",
  subtitle = "2016-2019 (I-90 corridor)",
  color_by = "thc_positive"
)

ggsave(file.path(dir_figs, "fig13_wa_id_border.pdf"), fig13,
       width = 12, height = 10, dpi = 300)
ggsave(file.path(dir_figs, "fig13_wa_id_border.png"), fig13,
       width = 12, height = 10, dpi = 300)

message("  Saved fig13_wa_id_border")

# =============================================================================
# Figure 14: Oregon-Idaho Rural Border
# =============================================================================

message("Creating Figure 14: OR-ID rural border zoom...")

or_id_bbox <- list(
  north = 45.5, south = 43.0,
  east = -116.0, west = -118.5
)

fars_or_id <- fars_sf %>%
  filter(year >= 2016, state_abbr %in% c("OR", "ID"))

fig14 <- create_zoom_map(
  fars_data = fars_or_id,
  states_data = states_sf,
  bbox = or_id_bbox,
  title = "Fatal Crashes at the Oregon-Idaho Border",
  subtitle = "2016-2019 (I-84 corridor, rural)",
  color_by = "rec_legal"
)

ggsave(file.path(dir_figs, "fig14_or_id_border.pdf"), fig14,
       width = 12, height = 10, dpi = 300)
ggsave(file.path(dir_figs, "fig14_or_id_border.png"), fig14,
       width = 12, height = 10, dpi = 300)

message("  Saved fig14_or_id_border")

# =============================================================================
# Figure 15: California-Arizona Border
# =============================================================================

message("Creating Figure 15: CA-AZ border zoom...")

ca_az_bbox <- list(
  north = 35.0, south = 32.5,
  east = -113.5, west = -117.0
)

fars_ca_az <- fars_sf %>%
  filter(year >= 2018, state_abbr %in% c("CA", "AZ"))

fig15 <- create_zoom_map(
  fars_data = fars_ca_az,
  states_data = states_sf,
  bbox = ca_az_bbox,
  title = "Fatal Crashes at the California-Arizona Border",
  subtitle = "2018-2019 (I-10/I-8 corridors)",
  color_by = "substance_cat"
)

ggsave(file.path(dir_figs, "fig15_ca_az_border.pdf"), fig15,
       width = 12, height = 10, dpi = 300)
ggsave(file.path(dir_figs, "fig15_ca_az_border.png"), fig15,
       width = 12, height = 10, dpi = 300)

message("  Saved fig15_ca_az_border")

# =============================================================================
# Figure 16: Nevada-Utah Border (I-15)
# =============================================================================

message("Creating Figure 16: NV-UT border zoom...")

nv_ut_bbox <- list(
  north = 41.0, south = 36.0,
  east = -113.5, west = -115.5
)

fars_nv_ut <- fars_sf %>%
  filter(year >= 2017, state_abbr %in% c("NV", "UT"))

fig16 <- create_zoom_map(
  fars_data = fars_nv_ut,
  states_data = states_sf,
  bbox = nv_ut_bbox,
  title = "Fatal Crashes at the Nevada-Utah Border",
  subtitle = "2017-2019 (I-15 corridor, Las Vegas traffic)",
  color_by = "thc_positive"
)

ggsave(file.path(dir_figs, "fig16_nv_ut_border.pdf"), fig16,
       width = 10, height = 12, dpi = 300)
ggsave(file.path(dir_figs, "fig16_nv_ut_border.png"), fig16,
       width = 10, height = 12, dpi = 300)

message("  Saved fig16_nv_ut_border")

# =============================================================================
# Figure 17: Day vs Night Crashes (Denver Example)
# =============================================================================

message("Creating Figure 17: Day vs night comparison...")

# Create side-by-side day vs night for Denver
fars_denver_time <- fars_sf %>%
  filter(year >= 2016, state_abbr == "CO",
         !is.na(hour)) %>%
  mutate(
    time_period = case_when(
      hour >= 6 & hour < 18 ~ "Day (6am-6pm)",
      TRUE ~ "Night (6pm-6am)"
    )
  )

# Convert bbox to Albers
denver_bbox_sf <- st_as_sfc(st_bbox(c(
  xmin = denver_bbox$west, ymin = denver_bbox$south,
  xmax = denver_bbox$east, ymax = denver_bbox$north
), crs = 4326)) %>%
  st_transform(crs = 5070)

denver_bbox_albers <- st_bbox(denver_bbox_sf)

fars_denver_cropped <- fars_denver_time %>%
  st_crop(denver_bbox_albers)

states_denver <- states_sf %>%
  st_crop(denver_bbox_albers)

fig17 <- ggplot() +
  geom_sf(data = states_denver, fill = "grey98", color = "grey50", linewidth = 0.5) +
  geom_sf(data = fars_denver_cropped, aes(color = substance_cat), alpha = 0.6, size = 0.8) +
  facet_wrap(~ time_period, ncol = 2) +
  scale_color_manual(values = substance_colors, name = "Substance\nInvolvement") +
  labs(
    title = "Fatal Crashes in Denver: Day vs Night",
    subtitle = "2016-2019",
    caption = "Source: FARS (NHTSA). Day = 6am-6pm, Night = 6pm-6am."
  ) +
  theme_apep() +
  theme(
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_blank(),
    panel.grid = element_blank(),
    strip.text = element_text(size = 12, face = "bold")
  )

ggsave(file.path(dir_figs, "fig17_denver_day_night.pdf"), fig17,
       width = 14, height = 8, dpi = 300)
ggsave(file.path(dir_figs, "fig17_denver_day_night.png"), fig17,
       width = 14, height = 8, dpi = 300)

message("  Saved fig17_denver_day_night")

# =============================================================================
# Summary
# =============================================================================

message("\n", strrep("=", 60))
message("Zoom figures complete!")
message("Figures saved to: ", dir_figs)
message(strrep("=", 60))

# List zoom figures
message("\nGenerated zoom figures:")
list.files(dir_figs, pattern = "^fig1[0-7]_.*\\.(pdf|png)$") %>%
  unique() %>%
  sort() %>%
  walk(~ message("  ", .x))
