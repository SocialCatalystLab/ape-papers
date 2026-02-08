# ============================================================================
# Paper 81: State Heat Protection Standards and Worker Safety
# 00_packages.R - Load packages and set themes
# ============================================================================

# Core packages
library(tidyverse)
library(fixest)
library(did)

# Synthetic control - will use augsynth or manual implementation if Synth unavailable
# library(Synth)  # Commented out - install issues

# Inference for few clusters
library(sandwich)
library(lmtest)
library(clubSandwich)  # Small-sample CR2

# Tables and figures
library(ggplot2)
library(ggthemes)
library(latex2exp)
library(scales)

# Data access
library(fredr)  # FRED API
library(httr)
library(jsonlite)

# Set FRED API key - read from .env file
env_file <- here::here(".env")
if (file.exists(env_file)) {
  env_lines <- readLines(env_file)
  for (line in env_lines) {
    if (grepl("^FRED_API_KEY=", line)) {
      api_key <- sub("^FRED_API_KEY=", "", line)
      fredr_set_key(api_key)
      cat("FRED API key loaded from .env\n")
      break
    }
  }
} else {
  cat("Warning: .env file not found, FRED API key not set\n")
}

# ============================================================================
# APEP Theme for Publication-Quality Figures
# ============================================================================

theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      # Panel
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "gray90", linewidth = 0.3),
      panel.background = element_rect(fill = "white", color = NA),

      # Axes
      axis.line = element_line(color = "gray30", linewidth = 0.4),
      axis.ticks = element_line(color = "gray30", linewidth = 0.3),
      axis.text = element_text(color = "gray20", size = rel(0.9)),
      axis.title = element_text(color = "gray10", face = "bold", size = rel(1)),

      # Legend
      legend.position = "bottom",
      legend.title = element_text(face = "bold", size = rel(0.9)),
      legend.text = element_text(size = rel(0.85)),
      legend.key.size = unit(0.8, "lines"),

      # Plot title/subtitle
      plot.title = element_text(face = "bold", size = rel(1.2), hjust = 0),
      plot.subtitle = element_text(color = "gray40", size = rel(0.95), hjust = 0),
      plot.caption = element_text(color = "gray50", size = rel(0.75), hjust = 1),

      # Facets
      strip.text = element_text(face = "bold", size = rel(0.9)),
      strip.background = element_rect(fill = "gray95", color = NA)
    )
}

# Set as default
theme_set(theme_apep())

# Color palette
apep_colors <- c(
  "treatment" = "#E64B35",  # Red
  "control" = "#4DBBD5",    # Blue
  "pre" = "#00A087",        # Teal
  "post" = "#F39B7F",       # Light coral
  "estimate" = "#3C5488",   # Navy
  "ci" = "#8491B4"          # Gray-blue
)

# ============================================================================
# File paths (relative to code directory)
# ============================================================================

# Get the directory containing this script, then navigate to data/figures/tables
CODE_DIR <- here::here("output", "paper_81", "code")
PAPER_DIR <- dirname(CODE_DIR)
DATA_DIR <- file.path(PAPER_DIR, "data")
FIG_DIR <- file.path(PAPER_DIR, "figures")
TAB_DIR <- file.path(PAPER_DIR, "tables")

# Create directories if they don't exist
dir.create(DATA_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(FIG_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(TAB_DIR, recursive = TRUE, showWarnings = FALSE)

cat("Packages loaded and theme set.\n")
cat("Data directory:", DATA_DIR, "\n")
cat("Figures directory:", FIG_DIR, "\n")
