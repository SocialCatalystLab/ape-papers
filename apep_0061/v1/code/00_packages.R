# ============================================================================
# Paper 78: Dyslexia Screening Mandates and Fourth-Grade Reading Proficiency
# (Revision of apep_0069)
# 00_packages.R - Load libraries and set themes
# ============================================================================

# Core DiD packages
library(did)          # Callaway-Sant'Anna estimator
library(fixest)       # Fast TWFE, Sun-Abraham via sunab()
library(did2s)        # Gardner's two-stage imputation

# Data manipulation
library(tidyverse)
library(httr)
library(jsonlite)

# Mapping (optional - only needed for map figures)
sf_available <- requireNamespace("sf", quietly = TRUE)
tigris_available <- requireNamespace("tigris", quietly = TRUE)
if (sf_available && tigris_available) {
  library(sf)
  library(tigris)
  options(tigris_use_cache = TRUE)
  cat("Spatial packages loaded (sf, tigris)\n")
} else {
  cat("Note: Spatial packages (sf, tigris) not available. Map figures will be skipped.\n")
}

# Tables and figures
library(ggplot2)
library(latex2exp)
library(scales)

# Sensitivity analysis
# library(HonestDiD)  # Sensitivity analysis (requires glpk)
# library(fwildclusterboot)  # Wild cluster bootstrap

# ============================================================================
# APEP Standard Theme
# ============================================================================

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
  "#0072B2",  # Blue (primary/treated)
  "#D55E00",  # Orange (secondary/control)
  "#009E73",  # Green (third group)
  "#CC79A7",  # Pink (fourth group)
  "#F0E442",  # Yellow (fifth group)
  "#56B4E9"   # Light blue (sixth group)
)

# Set default theme
theme_set(theme_apep())

# ============================================================================
# Project paths
# ============================================================================

# Base paths - Paper 78 (revision of apep_0069)
base_dir <- "/Users/dyanag/auto-policy-evals/output/paper_78"
data_dir <- file.path(base_dir, "data")
fig_dir <- file.path(base_dir, "figures")
tab_dir <- file.path(base_dir, "tables")
code_dir <- file.path(base_dir, "code")

# Create directories if they don't exist
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

cat("Packages loaded. Theme set. Directories configured.\n")
cat("Working directory:", getwd(), "\n")
cat("Paper 78: Revision of apep_0069 (Dyslexia Laws)\n")
