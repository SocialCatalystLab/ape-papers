# =============================================================================
# Paper 108: Geocoded Atlas of US Traffic Fatalities 2001-2023
# 00_packages.R - Load libraries and set theme
# =============================================================================

# Core packages
library(tidyverse)
library(sf)
library(data.table)

# GIS packages
library(tigris)
library(units)

# Additional analysis
library(haven)
library(janitor)
library(lubridate)
library(scales)
library(latex2exp)
library(patchwork)
library(ggspatial)
library(viridis)

# For nice tables
library(modelsummary)
library(gt)

# Set options
options(tigris_use_cache = TRUE)
options(scipen = 999)
sf_use_s2(FALSE)  # Use planar geometry for buffer operations

# Directories
dir_data <- here::here("output/paper_108/data")
dir_data_raw <- here::here("output/paper_108/data/fars_raw")
dir_data_osm <- here::here("output/paper_108/data/osm_roads")
dir_data_policy <- here::here("output/paper_108/data/policy")
dir_figs <- here::here("output/paper_108/figures")
dir_tabs <- here::here("output/paper_108/tables")

# Create directories if they don't exist
for (d in c(dir_data, dir_data_raw, dir_data_osm, dir_data_policy, dir_figs, dir_tabs)) {
  if (!dir.exists(d)) dir.create(d, recursive = TRUE)
}

# Western states focus (legal marijuana + comparison states)
WESTERN_STATES <- c(
  # Legal recreational marijuana (during key period)
  "CO", "WA", "OR", "CA", "NV", "AK",
  # Comparison states (illegal during key period)
  "WY", "NE", "KS", "ID", "UT", "AZ", "NM", "MT"
)

# State FIPS codes for filtering
WESTERN_FIPS <- c(
  "08",  # Colorado
  "53",  # Washington
  "41",  # Oregon
  "06",  # California
  "32",  # Nevada
  "02",  # Alaska
  "56",  # Wyoming
  "31",  # Nebraska
  "20",  # Kansas
  "16",  # Idaho
  "49",  # Utah
  "04",  # Arizona
  "35",  # New Mexico
  "30"   # Montana
)

# APEP standard theme for publication-ready figures
theme_apep <- function() {
  theme_minimal(base_size = 12) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "grey90", linewidth = 0.3),
      axis.line = element_line(color = "grey30", linewidth = 0.4),
      axis.ticks = element_line(color = "grey30", linewidth = 0.3),
      axis.title = element_text(size = 11, face = "bold"),
      axis.text = element_text(size = 10, color = "grey30"),
      legend.position = "bottom",
      legend.title = element_text(size = 10, face = "bold"),
      legend.text = element_text(size = 9),
      plot.title = element_text(size = 13, face = "bold", hjust = 0),
      plot.subtitle = element_text(size = 10, color = "grey40", hjust = 0),
      plot.caption = element_text(size = 8, color = "grey50", hjust = 1),
      plot.margin = margin(10, 15, 10, 10)
    )
}

# Colorblind-safe color palette
apep_colors <- c(
  "thc_positive" = "#E41A1C",     # Red for THC
  "alcohol_positive" = "#377EB8", # Blue for alcohol
  "both" = "#984EA3",             # Purple for both
  "neither" = "#999999",          # Gray for neither
  "legal" = "#4DAF4A",            # Green for legal state
  "illegal" = "#FF7F00"           # Orange for illegal state
)

# Color palette for substance involvement
substance_colors <- c(
  "THC Positive" = "#E41A1C",
  "Alcohol Only" = "#377EB8",
  "Both" = "#984EA3",
  "Neither/Unknown" = "#999999"
)

# Set ggplot defaults
theme_set(theme_apep())

message("Packages loaded and theme set")
message("Working directories:")
message("  Data: ", dir_data)
message("  Figures: ", dir_figs)
message("  Tables: ", dir_tabs)
message("Western states focus: ", paste(WESTERN_STATES, collapse = ", "))
