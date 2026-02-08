# =============================================================================
# 00_packages.R
# Cannabis Dispensary Access and Traffic Safety: A Spatial RDD Approach
# =============================================================================

# Core packages
library(tidyverse)
library(sf)
library(data.table)

# Spatial analysis
library(sp)
# library(raster)  # Not needed
# library(geodist) # Not needed

# RDD packages
library(rdrobust)
library(rddensity)

# Visualization
library(ggplot2)
library(ggthemes)
library(patchwork)
library(viridis)
library(scales)
library(ggspatial)

# Tables
library(modelsummary)
library(kableExtra)
library(fixest)

# Set consistent theme
theme_set(
  theme_minimal(base_size = 11, base_family = "serif") +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "gray90", linewidth = 0.3),
      plot.title = element_text(face = "bold", size = 12),
      plot.subtitle = element_text(size = 10, color = "gray40"),
      axis.title = element_text(size = 10),
      legend.position = "bottom",
      plot.caption = element_text(size = 8, color = "gray50", hjust = 0)
    )
)

# Color palette for legal/illegal states
legal_colors <- c(
  "Legal" = "#2E7D32",      # Green
  "Prohibition" = "#C62828" # Red
)

# Set seed for reproducibility
set.seed(20260130)

cat("Packages loaded successfully.\n")
