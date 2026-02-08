# ==============================================================================
# 00_packages.R - Load Required Packages
# Paper: Salary History Bans and Wage Compression
# ==============================================================================

# Core packages
library(tidyverse)
library(data.table)
library(fixest)
library(did)
library(here)

# Set project root for reproducible paths
# When running from code/ directory, set root to paper output directory
if (!exists("PAPER_ROOT")) {
  PAPER_ROOT <- here::here()
  if (grepl("/code$", PAPER_ROOT)) {
    PAPER_ROOT <- dirname(PAPER_ROOT)
  }
}
data_dir <- file.path(PAPER_ROOT, "data")
figures_dir <- file.path(PAPER_ROOT, "figures")
tables_dir <- file.path(PAPER_ROOT, "tables")

# Data
library(ipumsr)

# Visualization
library(ggplot2)
library(patchwork)
library(scales)

# Tables
library(modelsummary)
library(kableExtra)

# APEP theme
theme_apep <- function() {
  theme_minimal(base_size = 11) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      axis.line = element_line(color = "black", linewidth = 0.3),
      axis.ticks = element_line(color = "black", linewidth = 0.3),
      legend.position = "bottom",
      plot.title = element_text(face = "bold", size = 12),
      plot.subtitle = element_text(size = 10, color = "gray40"),
      strip.text = element_text(face = "bold")
    )
}

theme_set(theme_apep())

cat("Packages loaded successfully.\n")
