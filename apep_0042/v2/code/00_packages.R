# =============================================================================
# 00_packages.R
# Load packages and set standard themes for Paper 100
# State Auto-IRA Mandates and Retirement Savings Participation (Revision)
# =============================================================================

# Core data manipulation
library(tidyverse)
library(data.table)

# IPUMS data access
library(ipumsr)

# Causal inference - DiD
library(did)        # Callaway-Sant'Anna
library(fixest)     # TWFE and Sun-Abraham
library(did2s)      # Gardner two-stage

# Inference
library(sandwich)
library(lmtest)
# Try to load fwildclusterboot for small-cluster inference (optional)
if (requireNamespace("fwildclusterboot", quietly = TRUE)) {
  library(fwildclusterboot)
  cat("fwildclusterboot loaded for wild cluster bootstrap.\n")
} else {
  cat("fwildclusterboot not available - will skip wild bootstrap.\n")
}

# Tables and figures
library(ggplot2)
library(latex2exp)

# Mapping
library(sf)
library(tigris)
options(tigris_use_cache = TRUE)

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

# Color palette (colorblind-safe)
apep_colors <- c(
  "#0072B2",  # Blue (treated)
  "#D55E00",  # Orange (control)
  "#009E73",  # Green (third group)
  "#CC79A7",  # Pink (fourth group)
  "#F0E442",  # Yellow (fifth group)
  "#56B4E9"   # Light blue (sixth group)
)

# Set default ggplot theme
theme_set(theme_apep())

# -----------------------------------------------------------------------------
# Project paths
# -----------------------------------------------------------------------------

project_dir <- here::here()
data_dir <- file.path(project_dir, "data")
fig_dir <- file.path(project_dir, "figures")
code_dir <- file.path(project_dir, "code")

# Create directories if they don't exist
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)

cat("Packages loaded and theme set.\n")
cat("Project directory:", project_dir, "\n")
