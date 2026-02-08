# ==============================================================================
# Paper 68: Broadband Internet and Moral Foundations in Local Governance
# 00_packages.R - Load libraries and set global options
# ==============================================================================

# ------------------------------------------------------------------------------
# Core Data Manipulation
# ------------------------------------------------------------------------------
library(tidyverse)      # dplyr, ggplot2, tidyr, etc.
library(data.table)     # Fast data operations
library(arrow)          # Parquet files
library(lubridate)      # Date handling

# ------------------------------------------------------------------------------
# Econometrics - DiD
# ------------------------------------------------------------------------------
library(did)            # Callaway-Sant'Anna estimator
library(fixest)         # Fast fixed effects, Sun-Abraham via sunab()
library(did2s)          # Gardner two-stage imputation
library(bacondecomp)    # Goodman-Bacon decomposition

# HonestDiD for sensitivity analysis
tryCatch({
  library(HonestDiD)
}, error = function(e) {
  message("HonestDiD not available, will skip sensitivity analysis")
})

# ------------------------------------------------------------------------------
# Inference
# ------------------------------------------------------------------------------
library(sandwich)       # Robust SEs
library(lmtest)         # Hypothesis tests
library(clubSandwich)   # Small-sample clustered SEs (CR2)

# ------------------------------------------------------------------------------
# Tables and Figures
# ------------------------------------------------------------------------------
library(ggplot2)
library(patchwork)      # Combine plots
library(scales)         # Scale formatting
library(viridis)        # Color palettes

# ------------------------------------------------------------------------------
# API Access
# ------------------------------------------------------------------------------
library(httr)
library(jsonlite)

# ------------------------------------------------------------------------------
# Global Options
# ------------------------------------------------------------------------------
options(
  scipen = 999,                    # Avoid scientific notation
  dplyr.summarise.inform = FALSE,  # Suppress summarise warnings
  mc.cores = parallel::detectCores() - 1  # Parallel processing
)

# Set seed for reproducibility
set.seed(20260122)

# ------------------------------------------------------------------------------
# APEP Theme for Publication-Ready Figures
# ------------------------------------------------------------------------------
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
  "#0072B2",  # Blue (primary)
  "#D55E00",  # Orange (secondary)
  "#009E73",  # Green (third)
  "#CC79A7",  # Pink (fourth)
  "#E69F00",  # Gold (fifth)
  "#56B4E9"   # Light blue (sixth)
)

# Set as default theme
theme_set(theme_apep())

# ------------------------------------------------------------------------------
# Directory Setup
# ------------------------------------------------------------------------------
project_dir <- getwd()

# Ensure directories exist
dir.create(file.path(project_dir, "data"), showWarnings = FALSE)
dir.create(file.path(project_dir, "figures"), showWarnings = FALSE)
dir.create(file.path(project_dir, "tables"), showWarnings = FALSE)

cat("Packages loaded. Project directory:", project_dir, "\n")
