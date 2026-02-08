# =============================================================================
# Paper 107: Spatial RDD of Primary Seatbelt Enforcement Laws
# 00_packages.R - Load libraries and set theme
# =============================================================================

# Core packages
library(tidyverse)
library(sf)
library(fixest)
library(rdrobust)
library(rddensity)
library(modelsummary)

# GIS packages
library(tigris)
library(osmdata)
library(sfnetworks)
library(tidygraph)
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

# For spatial RDD
library(SpatialRDD)

# Set options
options(tigris_use_cache = TRUE)
options(scipen = 999)
sf_use_s2(FALSE)  # Use planar geometry for buffer operations

# Directories
dir_data <- here::here("output/paper_107/data")
dir_figs <- here::here("output/paper_107/figures")
dir_tabs <- here::here("output/paper_107/tables")

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
  "#0072B2",  # Blue (primary enforcement)
  "#D55E00",  # Orange (secondary enforcement)
  "#009E73",  # Green (third group)
  "#CC79A7",  # Pink (fourth group)
  "#F0E442",  # Yellow
  "#56B4E9"   # Light blue
)

# Set ggplot defaults
theme_set(theme_apep())

message("✓ Packages loaded and theme set")
