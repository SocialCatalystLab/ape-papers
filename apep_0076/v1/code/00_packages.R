# ============================================================================
# Paper 105: Salary History Bans and the Wage Penalty for Job Stayers
# Script: 00_packages.R - Package Installation and Setup
# ============================================================================

# Clear environment
rm(list = ls())
gc()

# Set CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Install packages if not present
packages <- c(
  # Core
  "tidyverse", "data.table", "haven", "lubridate",
  # DiD packages
  "did", "fixest", "bacondecomp", "staggered",
  # Inference
  "sandwich", "lmtest", "clubSandwich",
  # Figures and tables
  "ggplot2", "ggthemes", "latex2exp", "patchwork", "scales",
  # Data access
  "httr", "jsonlite"
)

for (pkg in packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg)
    library(pkg, character.only = TRUE)
  }
}

# Install HonestDiD if not present (requires GLPK system dependency)
# Skip if GLPK not available - HonestDiD is optional for sensitivity analysis
if (!require("HonestDiD", quietly = TRUE)) {
  tryCatch({
    if (require("Rglpk", quietly = TRUE)) {
      remotes::install_github("asheshrambachan/HonestDiD")
      library(HonestDiD)
    } else {
      cat("Note: HonestDiD not available (requires GLPK). Sensitivity analysis will be skipped.\n")
    }
  }, error = function(e) {
    cat("Note: HonestDiD not available. Sensitivity analysis will be skipped.\n")
  })
}

# Set paths using here::here() for portability
if (!require("here", quietly = TRUE)) {
  install.packages("here")
  library(here)
}

# Detect if we're in code/ subdirectory and set root accordingly
BASE_DIR <- here::here()
if (basename(BASE_DIR) == "code") {
  BASE_DIR <- dirname(BASE_DIR)
}
DATA_DIR <- file.path(BASE_DIR, "data")
CODE_DIR <- file.path(BASE_DIR, "code")
FIG_DIR  <- file.path(BASE_DIR, "figures")
TAB_DIR  <- file.path(BASE_DIR, "tables")

# Create directories if they don't exist
for (d in c(DATA_DIR, FIG_DIR, TAB_DIR)) {
  if (!dir.exists(d)) dir.create(d, recursive = TRUE)
}

# ============================================================================
# APEP Theme for Figures
# ============================================================================
theme_apep <- function(base_size = 12) {
  theme_minimal(base_size = base_size) +
    theme(
      # Title and axis
      plot.title = element_text(size = base_size + 2, face = "bold", hjust = 0),
      plot.subtitle = element_text(size = base_size, hjust = 0, color = "gray40"),
      plot.caption = element_text(size = base_size - 2, hjust = 1, color = "gray50"),
      axis.title = element_text(size = base_size),
      axis.text = element_text(size = base_size - 1),
      # Legend
      legend.position = "bottom",
      legend.title = element_text(size = base_size - 1, face = "bold"),
      legend.text = element_text(size = base_size - 2),
      # Panel
      panel.grid.major = element_line(color = "gray90", linewidth = 0.3),
      panel.grid.minor = element_blank(),
      panel.border = element_blank(),
      # Strip for facets
      strip.text = element_text(size = base_size, face = "bold"),
      strip.background = element_rect(fill = "gray95", color = NA)
    )
}

# Set default theme
theme_set(theme_apep())

# Color palette
apep_colors <- c(
  "primary" = "#2C3E50",    # Dark blue-gray
  "secondary" = "#E74C3C",  # Red
  "accent" = "#3498DB",     # Blue
  "light" = "#BDC3C7",      # Light gray
  "success" = "#27AE60",    # Green
  "warning" = "#F39C12"     # Orange
)

cat("\n============================================\n")
cat("Paper 105: Packages and environment loaded\n")
cat("Base directory:", BASE_DIR, "\n")
cat("============================================\n\n")
