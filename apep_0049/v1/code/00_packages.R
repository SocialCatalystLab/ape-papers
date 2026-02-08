# ============================================================================
# Paper 65: Transit Funding Discontinuity at 50,000 Population Threshold
# 00_packages.R - Load required packages and set up environment
# ============================================================================

# ---- Install packages if needed ----
required_packages <- c(
  # Data manipulation
  "tidyverse", "data.table", "haven", "readxl", "jsonlite", "httr",

  # RDD analysis
  "rdrobust", "rddensity", "rdlocrand",

  # Inference
  "sandwich", "lmtest",

  # Visualization
  "ggplot2", "ggthemes", "latex2exp", "patchwork", "scales",

  # Mapping
  "sf", "tigris", "ggspatial",

  # Tables
  "fixest", "modelsummary", "kableExtra"
)

# Install missing packages
new_packages <- required_packages[!required_packages %in% installed.packages()[,"Package"]]
if(length(new_packages)) install.packages(new_packages, repos = "https://cloud.r-project.org")

# ---- Load packages ----
library(tidyverse)
library(data.table)
library(jsonlite)
library(httr)
library(rdrobust)
library(rddensity)
library(sandwich)
library(lmtest)
library(ggplot2)
library(latex2exp)
library(patchwork)
library(scales)
library(sf)
library(tigris)
library(fixest)
library(modelsummary)

# ---- Set options ----
options(
  scipen = 999,               # Avoid scientific notation
  tigris_use_cache = TRUE,    # Cache Census shapefiles
  stringsAsFactors = FALSE
)

# ---- Define paths ----
root_dir <- "/Users/olafwillner/auto-policy-evals"

data_dir <- file.path(root_dir, "output/paper_65/data")
fig_dir <- file.path(root_dir, "output/paper_65/figures")
code_dir <- file.path(root_dir, "output/paper_65/code")

# Create directories if needed
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

# ---- APEP Theme ----
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

# Color palette (colorblind-safe)
apep_colors <- c(
  "#0072B2",  # Blue
  "#D55E00",  # Orange
  "#009E73",  # Green
  "#CC79A7",  # Pink
  "#F0E442",  # Yellow
  "#56B4E9"   # Light blue
)

# ---- Census API key ----
# Set Census API key if available (not strictly required for basic queries)
# census_api_key("YOUR_KEY_HERE", install = TRUE)

cat("Packages loaded. Ready for analysis.\n")
cat("Data directory:", data_dir, "\n")
cat("Figures directory:", fig_dir, "\n")
