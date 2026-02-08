# ==============================================================================
# Paper 63: State EITC and Single Mothers' Self-Employment
# 00_packages.R - Load libraries and set themes
# ==============================================================================

# Core packages
library(tidyverse)
library(data.table)

# Econometric analysis - load what's available
suppressPackageStartupMessages({
  if (require(fixest, quietly = TRUE)) {
    message("fixest loaded")
  } else {
    message("fixest not available - using base R")
  }

  if (require(did, quietly = TRUE)) {
    message("did package loaded")
  } else {
    message("did not available - will use fixest for DiD")
  }
})

# Inference
suppressPackageStartupMessages({
  library(sandwich)
  library(lmtest)
})

# Tables and figures
library(ggplot2)

# ==============================================================================
# APEP Standard Theme for Publication-Ready Figures
# ==============================================================================

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

# Set default theme
theme_set(theme_apep())

# ==============================================================================
# Paths
# ==============================================================================

base_path <- "/Users/celine/Dropbox (Personal)/SC_Diverse/auto-policy-evals/output/paper_63"
data_path <- file.path(base_path, "data")
code_path <- file.path(base_path, "code")
fig_path <- file.path(base_path, "figures")

# Create directories if they don't exist
dir.create(data_path, showWarnings = FALSE, recursive = TRUE)
dir.create(fig_path, showWarnings = FALSE, recursive = TRUE)

message("Packages loaded successfully. Using APEP theme.")
