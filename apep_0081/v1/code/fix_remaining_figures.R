# =============================================================================
# Paper 108: Fix Remaining Figures
# =============================================================================

source(here::here("output/paper_108/code/00_packages.R"))

# Load clean data
fars <- readRDS(file.path(dir_data, "fars_analysis_policy_fixed_clean.rds"))
states_sf <- readRDS(file.path(dir_data, "states_sf.rds"))

YEAR_LABEL <- "2001-2005 and 2016-2019"
THC_YEAR_LABEL <- "2018-2019"

# Convert to spatial
fars_sf <- fars %>%
  filter(!is.na(x_albers) & !is.na(y_albers)) %>%
  st_as_sf(coords = c("x_albers", "y_albers"), crs = 5070)

message("Loaded data")

# =============================================================================
# Figure 11: I-25 Corridor (substance categories, 2016-2019)
# =============================================================================

message("Creating Figure 11: I-25 corridor...")

i25_bbox <- list(north = 41.2, south = 39.5, east = -104.5, west = -105.5)

bbox_sf <- st_as_sfc(st_bbox(c(
  xmin = i25_bbox$west, ymin = i25_bbox$south,
  xmax = i25_bbox$east, ymax = i25_bbox$north
), crs = 4326)) %>%
  st_transform(crs = 5070)

bbox_albers <- st_bbox(bbox_sf)

fars_i25 <- fars_sf %>%
  filter(year >= 2016, state_abbr %in% c("CO", "WY"))

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
    subtitle = paste0("Denver to Wyoming border, 2016-2019\nN = ", format(nrow(crashes_zoom), big.mark = ","), " crashes"),
    caption = "Source: FARS. Each point is one fatal crash."
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
# Figure 12: Denver Metro (substance categories, 2016-2019)
# =============================================================================

message("Creating Figure 12: Denver metro...")

denver_bbox <- list(north = 40.1, south = 39.5, east = -104.5, west = -105.3)

bbox_sf <- st_as_sfc(st_bbox(c(
  xmin = denver_bbox$west, ymin = denver_bbox$south,
  xmax = denver_bbox$east, ymax = denver_bbox$north
), crs = 4326)) %>%
  st_transform(crs = 5070)

bbox_albers <- st_bbox(bbox_sf)

fars_denver <- fars_sf %>%
  filter(year >= 2016, state_abbr == "CO")

crashes_zoom <- fars_denver %>% st_crop(bbox_albers)
states_zoom <- states_sf %>% st_crop(bbox_albers)

fig12 <- ggplot() +
  geom_sf(data = states_zoom, fill = "grey98", color = "grey50", linewidth = 0.5) +
  geom_sf(data = crashes_zoom, aes(color = substance_cat), alpha = 0.6, size = 1) +
  scale_color_manual(values = substance_colors, name = "Substance\nInvolvement") +
  labs(
    title = "Fatal Crashes in the Denver Metropolitan Area",
    subtitle = paste0("2016-2019\nN = ", format(nrow(crashes_zoom), big.mark = ","), " crashes"),
    caption = "Source: FARS. Each point is one fatal crash."
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

# =============================================================================
# Figure 14: OR-ID Border (marijuana status, 2016-2019)
# =============================================================================

message("Creating Figure 14: OR-ID border...")

or_id_bbox <- list(north = 45.5, south = 43.0, east = -116.0, west = -118.5)

bbox_sf <- st_as_sfc(st_bbox(c(
  xmin = or_id_bbox$west, ymin = or_id_bbox$south,
  xmax = or_id_bbox$east, ymax = or_id_bbox$north
), crs = 4326)) %>%
  st_transform(crs = 5070)

bbox_albers <- st_bbox(bbox_sf)

fars_or_id <- fars_sf %>%
  filter(year >= 2016, state_abbr %in% c("OR", "ID"))

crashes_zoom <- fars_or_id %>% st_crop(bbox_albers)
states_zoom <- states_sf %>% st_crop(bbox_albers)

# Create marijuana status variable
crashes_zoom <- crashes_zoom %>%
  mutate(
    mj_status = ifelse(rec_legal, "Legal (Oregon)", "Illegal (Idaho)")
  )

fig14 <- ggplot() +
  geom_sf(data = states_zoom, fill = "grey98", color = "grey50", linewidth = 0.5) +
  geom_sf(data = crashes_zoom, aes(color = mj_status), alpha = 0.6, size = 1) +
  scale_color_manual(
    values = c("Legal (Oregon)" = "#4DAF4A", "Illegal (Idaho)" = "#FF7F00"),
    name = "Marijuana\nStatus"
  ) +
  geom_sf_text(data = st_centroid(states_zoom), aes(label = state_abbr),
               size = 4, fontface = "bold", color = "grey30") +
  labs(
    title = "Fatal Crashes at the Oregon-Idaho Border",
    subtitle = paste0("2016-2019 (I-84 corridor)\nN = ", format(nrow(crashes_zoom), big.mark = ","), " crashes"),
    caption = "Source: FARS. Oregon legalized recreational marijuana in 2015; Idaho maintains prohibition."
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

ggsave(file.path(dir_figs, "fig14_or_id_border.pdf"), fig14, width = 12, height = 10, dpi = 300)
ggsave(file.path(dir_figs, "fig14_or_id_border.png"), fig14, width = 12, height = 10, dpi = 300)
message("  Saved fig14")

# =============================================================================
# Fix border figures color scales
# =============================================================================

message("Fixing border figure colors...")

border_data <- fars %>%
  filter(year %in% c(2018, 2019), !is.na(dist_to_border_km), dist_to_border_km < 200) %>%
  mutate(
    dist_bin = cut(dist_sign,
                   breaks = c(-200, -150, -100, -75, -50, -25, -10, 0,
                              10, 25, 50, 75, 100, 150, 200),
                   labels = c("-175", "-125", "-87", "-62", "-37", "-17", "-5",
                              "5", "17", "37", "62", "87", "125", "175")),
    side = ifelse(dist_sign < 0, "Legal State", "Illegal State")
  )

# Figure 24: Crash density
border_counts <- border_data %>%
  group_by(dist_bin, side) %>%
  summarise(crashes = n(), .groups = "drop") %>%
  filter(!is.na(dist_bin)) %>%
  mutate(dist_num = as.numeric(as.character(dist_bin)))

fig24 <- ggplot(border_counts, aes(x = dist_num, y = crashes, fill = side)) +
  geom_col(alpha = 0.8, width = 20) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey30", linewidth = 1) +
  scale_fill_manual(values = c("Legal State" = "#4DAF4A", "Illegal State" = "#FF7F00")) +
  scale_x_continuous(breaks = seq(-150, 150, 50)) +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Fatal Crashes by Distance to Legal/Illegal State Border",
    subtitle = "Western marijuana borders, 2018-2019",
    x = "Distance to Border (km, negative = legal side)",
    y = "Number of Crashes",
    fill = NULL,
    caption = "Source: FARS. Distance computed to nearest marijuana legalization border."
  ) +
  theme_apep() +
  theme(legend.position = "none")

ggsave(file.path(dir_figs, "fig24_crash_density_border.pdf"), fig24, width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig24_crash_density_border.png"), fig24, width = 10, height = 6, dpi = 300)
message("  Saved fig24")

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
  geom_ribbon(aes(ymin = pmax(0, pct_thc - 1.96*se), ymax = pct_thc + 1.96*se, fill = side),
              alpha = 0.2, color = NA) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey30", linewidth = 1) +
  scale_color_manual(values = c("Legal State" = "#4DAF4A", "Illegal State" = "#FF7F00")) +
  scale_fill_manual(values = c("Legal State" = "#4DAF4A", "Illegal State" = "#FF7F00")) +
  scale_x_continuous(breaks = seq(-150, 150, 50)) +
  labs(
    title = "THC-Positive Rate by Distance to Legal/Illegal Border",
    subtitle = "Western marijuana borders, 2018-2019",
    x = "Distance to Border (km, negative = legal side)",
    y = "Percent THC-Positive",
    color = NULL, fill = NULL,
    caption = "Source: FARS drug test data. Shaded area = 95% CI. Minimum 20 tested crashes per bin."
  ) +
  theme_apep() +
  theme(legend.position = "bottom")

ggsave(file.path(dir_figs, "fig25_thc_rate_border.pdf"), fig25, width = 10, height = 6, dpi = 300)
ggsave(file.path(dir_figs, "fig25_thc_rate_border.png"), fig25, width = 10, height = 6, dpi = 300)
message("  Saved fig25")

message("\nAll remaining figures fixed!")
