## ============================================================================
## 00_packages.R — Load libraries and set global options
## Project: apep_0441 — State Bifurcation and Development in India
## ============================================================================

# Core data manipulation
library(data.table)
library(tidyverse)

# Econometrics
library(fixest)          # Fast fixed-effects estimation, Sun-Abraham
library(did)             # Callaway-Sant'Anna staggered DiD
# fwildclusterboot not available for R 4.3; manual wild bootstrap implemented
# library(fwildclusterboot)
library(HonestDiD)       # Rambachan-Roth sensitivity bounds

# Figures
library(ggplot2)
library(patchwork)       # Multi-panel figure composition
library(latex2exp)       # LaTeX expressions in plots
library(scales)          # Axis formatting

# Tables
library(modelsummary)    # Regression tables
library(kableExtra)      # Table formatting

# Spatial (for border analysis)
library(sf)              # Simple features

# Set global options
setFixest_nthreads(2)
options(scipen = 999)
set.seed(20260222)

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

apep_colors <- c(
  "#0072B2",  # Blue (new state)
  "#D55E00",  # Orange (parent state)
  "#009E73",  # Green (third)
  "#CC79A7",  # Pink (fourth)
  "#F0E442",  # Yellow
  "#56B4E9"   # Light blue
)

cat("Packages loaded successfully.\n")
