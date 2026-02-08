# ==============================================================================
# Paper 91: Credit, Social Networks, and Political Polarization
# 00_packages.R - Load libraries and set global options
# ==============================================================================

# Core packages
library(tidyverse)
library(data.table)
library(haven)

# Mapping and GIS
library(sf)
library(tigris)
library(viridis)

# Tables and visualization
library(ggplot2)
library(latex2exp)
library(patchwork)
library(scales)
library(fixest)
library(modelsummary)

# Set options
options(
  tigris_use_cache = TRUE,
  tigris_class = "sf",
  scipen = 999  # Avoid scientific notation
)

# APEP standard theme for publication-ready figures
theme_apep <- function(base_size = 12) {
  theme_minimal(base_size = base_size) +
    theme(
      # Clean background
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "grey90", linewidth = 0.3),

      # Clear axis lines
      axis.line = element_line(color = "grey30", linewidth = 0.4),
      axis.ticks = element_line(color = "grey30", linewidth = 0.3),

      # Readable text
      axis.title = element_text(size = 11, face = "bold"),
      axis.text = element_text(size = 10, color = "grey30"),

      # Legend
      legend.position = "bottom",
      legend.title = element_text(size = 10, face = "bold"),
      legend.text = element_text(size = 9),

      # Title
      plot.title = element_text(size = 13, face = "bold", hjust = 0),
      plot.subtitle = element_text(size = 10, color = "grey40", hjust = 0),
      plot.caption = element_text(size = 8, color = "grey50", hjust = 1),

      # Margins
      plot.margin = margin(10, 15, 10, 10)
    )
}

# Color palette (colorblind-safe)
apep_colors <- c(
  "#0072B2",  # Blue
  "#D55E00",  # Orange
  "#009E73",  # Green
  "#CC79A7",  # Pink
  "#F0E442",  # Yellow
  "#56B4E9"   # Light blue
)

# Diverging palette for maps (red-white-blue)
apep_diverging <- c("#B2182B", "#D6604D", "#F4A582", "#FDDBC7", "#F7F7F7",
                    "#D1E5F0", "#92C5DE", "#4393C3", "#2166AC")

# Set global ggplot theme
theme_set(theme_apep())

cat("Packages loaded and APEP theme set.\n")
