# =============================================================================
# 00_packages.R
# Load required packages and set global options
# =============================================================================

# Core tidyverse
library(tidyverse)

# RDD estimation (Cattaneo et al.)
library(rdrobust)
library(rddensity)

# Panel data / Fixed effects
library(fixest)

# Data access
library(httr)
library(jsonlite)

# Spatial data
library(sf)

# Tables
library(modelsummary)

# Parallel processing
library(future)
library(furrr)
plan(multisession, workers = 4)

# =============================================================================
# Global options
# =============================================================================

options(scipen = 999)  # Avoid scientific notation
theme_set(theme_minimal(base_size = 12))

# APEP figure theme
theme_apep <- function() {
  theme_minimal(base_size = 11) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "gray90"),
      plot.title = element_text(face = "bold", size = 12),
      plot.subtitle = element_text(color = "gray40", size = 10),
      axis.title = element_text(size = 10),
      legend.position = "bottom",
      strip.text = element_text(face = "bold")
    )
}

# Output directories
dir.create("../figures", showWarnings = FALSE)
dir.create("../tables", showWarnings = FALSE)
dir.create("../data", showWarnings = FALSE)

cat("Packages loaded successfully.\n")
cat("Working directory:", getwd(), "\n")
