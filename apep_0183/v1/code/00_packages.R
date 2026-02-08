# =============================================================================
# 00_packages.R
# Package Loading and Theme Setup for Marijuana Legalization DiDisc Analysis
# =============================================================================

# Core tidyverse
library(tidyverse)
library(lubridate)

# Spatial analysis
library(sf)
library(tigris)
options(tigris_use_cache = TRUE)

# API access
library(httr)
library(jsonlite)

# Econometrics
library(fixest)
library(rdrobust)
library(rddensity)
library(did)

# Multiple testing
library(stats)  # for p.adjust

# Tables and output
library(modelsummary)
library(kableExtra)

# Visualization
library(ggplot2)
library(patchwork)
library(scales)
library(viridis)

# Set working directory to code folder
if (!grepl("code$", getwd())) {
  setwd(dirname(rstudioapi::getSourceEditorContext()$path))
}

# Data directory
data_dir <- "data"
if (!dir.exists(data_dir)) dir.create(data_dir)

# Figures directory
fig_dir <- "figures"
if (!dir.exists(fig_dir)) dir.create(fig_dir)

# Tables directory
tab_dir <- "tables"
if (!dir.exists(tab_dir)) dir.create(tab_dir)

# =============================================================================
# Publication-Quality Theme
# =============================================================================

theme_pub <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      # Text
      text = element_text(family = ""),
      plot.title = element_text(size = base_size + 2, face = "bold", hjust = 0),
      plot.subtitle = element_text(size = base_size, hjust = 0, color = "gray40"),
      axis.title = element_text(size = base_size),
      axis.text = element_text(size = base_size - 1),
      legend.title = element_text(size = base_size, face = "bold"),
      legend.text = element_text(size = base_size - 1),

      # Panel
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "gray90", linewidth = 0.3),
      panel.border = element_rect(color = "gray70", fill = NA, linewidth = 0.5),

      # Legend
      legend.position = "bottom",
      legend.background = element_rect(fill = "white", color = NA),

      # Margins
      plot.margin = margin(10, 10, 10, 10)
    )
}

theme_set(theme_pub())

# Color palette for treated/control
colors_treat <- c("Treated" = "#E41A1C", "Control" = "#377EB8")

# Color palette for industries
colors_industry <- viridis(10, option = "D")

cat("Packages loaded successfully.\n")
cat("Working directory:", getwd(), "\n")
