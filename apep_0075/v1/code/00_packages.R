# =============================================================================
# 00_packages.R
# Load packages, set themes, define APEP styling
# Paper 102: Minimum Wage and Elderly Worker Employment
# =============================================================================

# Core packages
library(tidyverse)
library(data.table)
library(fixest)
library(did)

# DiD diagnostics
library(bacondecomp)

# Visualization
library(ggplot2)
library(latex2exp)
library(scales)

# Spatial (optional - only for maps)
if (requireNamespace("sf", quietly = TRUE)) {
  library(sf)
  library(tigris)
  options(tigris_use_cache = TRUE)
}

# Suppress scientific notation
options(scipen = 999)

# -----------------------------------------------------------------------------
# APEP Standard Theme
# -----------------------------------------------------------------------------

theme_apep <- function() {
  theme_minimal(base_size = 12) +
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

# Colorblind-safe palette
apep_colors <- c(
  "#0072B2",  # Blue (treated)
  "#D55E00",  # Orange (control)
  "#009E73",  # Green (third group)
  "#CC79A7",  # Pink (fourth group)
  "#F0E442",  # Yellow (fifth group)
  "#56B4E9"   # Light blue (sixth group)
)

# Set default theme
theme_set(theme_apep())

# fixest dictionary for nice variable names
setFixest_dict(c(
  employed = "Employed",
  log_mw = "Log(Min Wage)",
  treat_post = "Treated $\\times$ Post",
  age = "Age",
  female = "Female",
  black = "Black",
  hispanic = "Hispanic",
  married = "Married",
  hs_or_less = "HS or Less",
  service_occ = "Service Occupation"
))

# -----------------------------------------------------------------------------
# Project paths
# -----------------------------------------------------------------------------

proj_dir <- here::here()
data_dir <- file.path(proj_dir, "output/paper_102/data")
fig_dir <- file.path(proj_dir, "output/paper_102/figures")
tab_dir <- file.path(proj_dir, "output/paper_102/tables")

# Create directories if they don't exist
dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(tab_dir, recursive = TRUE, showWarnings = FALSE)

message("Packages loaded successfully")
message("Data directory: ", data_dir)
message("Figures directory: ", fig_dir)
