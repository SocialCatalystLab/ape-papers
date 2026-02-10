## =============================================================================
## 00_packages.R — Load libraries and set global options
## The Innovation Cost of Privacy
## =============================================================================

# Core packages
library(tidyverse)
library(fixest)
library(did)

# Data fetching
library(httr)
library(jsonlite)

# Tables and output
library(modelsummary)
library(kableExtra)

# Figures
library(ggplot2)
library(patchwork)
library(scales)
library(maps)

# Set global options
options(scipen = 999)
set.seed(42)

# APEP standard theme
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

# Colorblind-safe palette
apep_colors <- c(
  "#0072B2",  # Blue (treated)
  "#D55E00",  # Orange (control)
  "#009E73",  # Green
  "#CC79A7",  # Pink
  "#F0E442",  # Yellow
  "#56B4E9",  # Light blue
  "#E69F00"   # Amber
)

cat("Packages loaded successfully.\n")

# Base directory for all paths (avoids hard-coded output paths)
base_dir <- here::here("output", "apep_0214", "v1")
