# ==============================================================================
# 06_maps.R
# NYC Neighborhood Maps with OPC Locations
# Paper 136 (Revision of apep_0134): Do Supervised Drug Injection Sites Save Lives?
# ==============================================================================
#
# Creates maps showing:
# 1. UHF neighborhood boundaries
# 2. OPC locations
# 3. Pre-treatment overdose rates by neighborhood
# 4. Treatment status (treated, control, spillover)
#
# ==============================================================================

# Source packages
if (file.exists("00_packages.R")) {
  source("00_packages.R")
} else if (file.exists("code/00_packages.R")) {
  source("code/00_packages.R")
} else {
  stop("Cannot find 00_packages.R - run from code/ directory or project root")
}

# Install mapping packages if needed
if (!require(sf, quietly = TRUE)) install.packages("sf")
if (!require(tigris, quietly = TRUE)) install.packages("tigris")
if (!require(viridis, quietly = TRUE)) install.packages("viridis")

library(sf)
library(tigris)
library(viridis)

# Set tigris options
options(tigris_use_cache = TRUE)

cat("\n==========================================================\n")
cat("GENERATING NYC MAPS\n")
cat("==========================================================\n\n")

# Load panel data
panel_data <- read_csv(file.path(PAPER_DIR, "data", "panel_data.csv"))
uhf_info <- read_csv(file.path(PAPER_DIR, "data", "uhf_neighborhoods.csv"))

# Calculate pre-treatment (2015-2020) average overdose rates
pre_treatment_rates <- panel_data %>%
  filter(year >= 2015, year <= 2020) %>%
  group_by(uhf_id, uhf_name, borough, treatment_status) %>%
  summarise(
    mean_od_rate = mean(od_rate, na.rm = TRUE),
    .groups = "drop"
  )

# ==============================================================================
# OPC LOCATION COORDINATES
# ==============================================================================

opc_locations <- tibble(
  name = c("East Harlem OPC", "Washington Heights OPC"),
  address = c("104-106 E 126th St", "500 W 180th St"),
  lat = c(40.8044, 40.8498),
  lon = c(-73.9370, -73.9321),
  uhf_id = c(203, 201)
)

# ==============================================================================
# DOWNLOAD NYC BOROUGH BOUNDARIES
# ==============================================================================

cat("Downloading NYC geographic boundaries...\n")

# Get NYC county boundaries (5 boroughs)
nyc_counties <- counties(state = "NY", cb = TRUE, year = 2020) %>%
  filter(NAME %in% c("New York", "Bronx", "Kings", "Queens", "Richmond"))

# Map county names to borough names
nyc_boroughs <- nyc_counties %>%
  mutate(borough = case_when(
    NAME == "New York" ~ "Manhattan",
    NAME == "Kings" ~ "Brooklyn",
    NAME == "Richmond" ~ "Staten Island",
    TRUE ~ NAME
  ))

# ==============================================================================
# CREATE SIMPLIFIED UHF APPROXIMATION
# ==============================================================================
# Note: Official UHF shapefiles require NYC Open Data download.
# We approximate using borough-level data with manual labels.

cat("Creating UHF neighborhood approximations...\n")

# For now, create a borough-level map with OPC points
# A full implementation would use UHF shapefiles from:
# https://data.cityofnewyork.us/Health/United-Hospital-Fund-UHF-Neighborhood-Index/d93w-z7h3

# ==============================================================================
# FIGURE 5A: BOROUGH-LEVEL MAP WITH OPC LOCATIONS
# ==============================================================================

# Convert OPC locations to sf object
opc_sf <- st_as_sf(opc_locations, coords = c("lon", "lat"), crs = 4326)

# Create base map
fig5a <- ggplot() +
  geom_sf(data = nyc_boroughs, aes(fill = borough), alpha = 0.3, color = "gray40") +
  geom_sf(data = opc_sf, color = "#E41A1C", size = 5, shape = 18) +
  geom_sf_text(data = opc_sf, aes(label = name), nudge_y = 0.015,
               size = 3, fontface = "bold", color = "black") +
  scale_fill_manual(values = c(
    "Manhattan" = "#E41A1C",
    "Bronx" = "#377EB8",
    "Brooklyn" = "#4DAF4A",
    "Queens" = "#984EA3",
    "Staten Island" = "#FF7F00"
  )) +
  labs(
    title = "Overdose Prevention Center Locations in New York City",
    subtitle = "Both OPCs located in Manhattan (opened November 2021)",
    fill = "Borough",
    caption = "Source: OnPoint NYC. Map shows NYC boroughs with OPC sites marked."
  ) +
  theme_void() +
  theme(
    legend.position = "right",
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 11),
    plot.caption = element_text(size = 8, hjust = 0)
  )

ggsave(file.path(PAPER_DIR, "figures", "fig5a_opc_locations.pdf"),
       fig5a, width = 10, height = 8)
ggsave(file.path(PAPER_DIR, "figures", "fig5a_opc_locations.png"),
       fig5a, width = 10, height = 8, dpi = 300)

cat("Figure 5A saved: fig5a_opc_locations\n")

# ==============================================================================
# FIGURE 5B: SCHEMATIC UHF MAP
# ==============================================================================

# Create a schematic representation of UHF neighborhoods
# with treatment status indicated

# Borough centroids for label placement
borough_centroids <- nyc_boroughs %>%
  st_centroid() %>%
  mutate(
    x = st_coordinates(.)[,1],
    y = st_coordinates(.)[,2]
  )

# Create UHF summary by borough
uhf_summary <- uhf_info %>%
  group_by(borough, treatment_status) %>%
  summarise(n = n(), .groups = "drop") %>%
  pivot_wider(names_from = treatment_status, values_from = n, values_fill = 0)

fig5b <- ggplot() +
  geom_sf(data = nyc_boroughs, fill = "gray95", color = "gray40") +
  # Add OPC locations
  geom_sf(data = opc_sf, color = "#E41A1C", size = 6, shape = 18) +
  # Add manual labels for key neighborhoods
  annotate("text", x = -73.94, y = 40.81, label = "East Harlem\n(TREATED)",
           size = 2.8, fontface = "bold", color = "#E41A1C") +
  annotate("text", x = -73.93, y = 40.86, label = "Washington Heights\n(TREATED)",
           size = 2.8, fontface = "bold", color = "#E41A1C") +
  annotate("text", x = -73.94, y = 40.835, label = "Central Harlem\n(spillover)",
           size = 2.5, color = "#FF7F00") +
  # Borough labels
  annotate("text", x = -73.87, y = 40.89, label = "BRONX",
           size = 4, fontface = "bold", color = "gray50") +
  annotate("text", x = -73.97, y = 40.755, label = "MANHATTAN",
           size = 4, fontface = "bold", color = "gray50", angle = 75) +
  annotate("text", x = -73.95, y = 40.65, label = "BROOKLYN",
           size = 4, fontface = "bold", color = "gray50") +
  annotate("text", x = -73.82, y = 40.72, label = "QUEENS",
           size = 4, fontface = "bold", color = "gray50") +
  labs(
    title = "Study Geography: Treated, Control, and Spillover Neighborhoods",
    subtitle = "OPC neighborhoods in Manhattan; adjacent neighborhoods excluded from donor pool",
    caption = "Red diamonds = OPC locations. Spillover neighborhoods (adjacent to treated) excluded from control group."
  ) +
  theme_void() +
  theme(
    plot.title = element_text(face = "bold", size = 12),
    plot.subtitle = element_text(size = 10),
    plot.caption = element_text(size = 8, hjust = 0)
  ) +
  coord_sf(xlim = c(-74.05, -73.7), ylim = c(40.55, 40.92))

ggsave(file.path(PAPER_DIR, "figures", "fig5b_study_geography.pdf"),
       fig5b, width = 10, height = 10)
ggsave(file.path(PAPER_DIR, "figures", "fig5b_study_geography.png"),
       fig5b, width = 10, height = 10, dpi = 300)

cat("Figure 5B saved: fig5b_study_geography\n")

# ==============================================================================
# FIGURE 5C: BAR CHART OF PRE-TREATMENT OVERDOSE RATES BY NEIGHBORHOOD
# ==============================================================================

# Create horizontal bar chart showing pre-treatment rates
# Color-coded by treatment status

rate_plot_data <- pre_treatment_rates %>%
  arrange(desc(mean_od_rate)) %>%
  mutate(
    uhf_label = paste0(uhf_name, " (", substr(borough, 1, 3), ")"),
    uhf_label = fct_reorder(uhf_label, mean_od_rate)
  )

fig5c <- ggplot(rate_plot_data, aes(x = mean_od_rate, y = uhf_label, fill = treatment_status)) +
  geom_col(width = 0.7) +
  geom_text(aes(label = round(mean_od_rate, 1)), hjust = -0.2, size = 2.5) +
  scale_fill_manual(
    values = c(
      "treated" = "#E41A1C",
      "control" = "#377EB8",
      "spillover" = "#FF7F00"
    ),
    labels = c(
      "treated" = "Treated (OPC sites)",
      "control" = "Control (donor pool)",
      "spillover" = "Spillover (excluded)"
    )
  ) +
  labs(
    title = "Pre-Treatment Overdose Death Rates (2015-2020 Average)",
    subtitle = "By UHF neighborhood and treatment status",
    x = "Overdose Deaths per 100,000",
    y = NULL,
    fill = "Sample Status",
    caption = "Note: Spillover neighborhoods excluded from control group due to potential treatment diffusion."
  ) +
  theme(
    legend.position = "bottom",
    axis.text.y = element_text(size = 8),
    plot.title = element_text(face = "bold")
  ) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.15)))

ggsave(file.path(PAPER_DIR, "figures", "fig5c_pretreatment_rates.pdf"),
       fig5c, width = 10, height = 8)
ggsave(file.path(PAPER_DIR, "figures", "fig5c_pretreatment_rates.png"),
       fig5c, width = 10, height = 8, dpi = 300)

cat("Figure 5C saved: fig5c_pretreatment_rates\n")

# ==============================================================================
# SAVE MAP METADATA
# ==============================================================================

map_metadata <- list(
  opc_locations = opc_locations,
  pre_treatment_rates = pre_treatment_rates,
  n_treated = sum(uhf_info$treatment_status == "treated"),
  n_control = sum(uhf_info$treatment_status == "control"),
  n_spillover = sum(uhf_info$treatment_status == "spillover"),
  nyc_total_uhfs = nrow(uhf_info)
)

saveRDS(map_metadata, file.path(PAPER_DIR, "data", "map_metadata.rds"))

cat("\n=== Map Generation Complete ===\n")
cat("Figures saved to:", file.path(PAPER_DIR, "figures"), "\n")
cat("  - fig5a_opc_locations.pdf/png\n")
cat("  - fig5b_study_geography.pdf/png\n")
cat("  - fig5c_pretreatment_rates.pdf/png\n")
