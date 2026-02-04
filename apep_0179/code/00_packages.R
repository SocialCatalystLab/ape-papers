# ============================================================================
# Paper 70: Age 26 RDD on Birth Insurance Coverage
# 00_packages.R - Load packages and set themes
# ============================================================================

# Core packages
library(tidyverse)
library(data.table)
library(haven)

# RDD packages
library(rdrobust)
library(rddensity)
library(rdlocrand)

# Inference
library(sandwich)
library(lmtest)
library(fixest)

# Tables and figures
library(ggplot2)
library(latex2exp)
library(scales)

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
  "#0072B2",  # Blue (below threshold)
  "#D55E00",  # Orange (above threshold)
  "#009E73",  # Green (third group)
  "#CC79A7",  # Pink (fourth group)
  "#F0E442",  # Yellow (fifth group)
  "#56B4E9"   # Light blue (sixth group)
)

# ============================================================================
# Paths (relative to this script's location for portability)
# ============================================================================

# Detect project root from script location
# Works when sourced from code/ directory or via Rscript
if (exists("code_dir") && !is.null(code_dir)) {
  proj_root <- dirname(code_dir)
} else {
  # Assume we're running from the code directory
  proj_root <- normalizePath(file.path(getwd(), ".."), mustWork = FALSE)
  # If that doesn't exist, try current directory as project root
  if (!dir.exists(proj_root)) {
    proj_root <- getwd()
  }
}

# Subdirectories (relative paths for AER replicability standards)
data_dir <- file.path(proj_root, "data")
code_dir <- file.path(proj_root, "code")
fig_dir <- file.path(proj_root, "figures")
tables_dir <- file.path(proj_root, "tables")

# Create if needed
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tables_dir, showWarnings = FALSE, recursive = TRUE)

cat("Packages loaded. Directories set.\n")
cat("Project root:", proj_root, "\n")
cat("Data directory:", data_dir, "\n")
cat("Figures directory:", fig_dir, "\n")
