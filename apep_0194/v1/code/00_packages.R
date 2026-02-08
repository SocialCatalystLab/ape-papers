################################################################################
# 00_packages.R — Load libraries and set themes
# Paper: Digital Exodus or Digital Magnet?
################################################################################

# Core
library(tidyverse)
library(data.table)
library(lubridate)

# Econometrics
library(fixest)
library(did)
library(HonestDiD)
library(bacondecomp)

# Tables & Figures
library(ggplot2)
library(latex2exp)
library(scales)
library(patchwork)
library(kableExtra)

# Data access
library(httr)
library(jsonlite)

# Set paths — resolve relative to this script's location
BASE_DIR <- tryCatch({
  script_dir <- dirname(sys.frame(1)$ofile)
  normalizePath(file.path(script_dir, ".."), mustWork = TRUE)
}, error = function(e) {
  # Fallback: find code/ dir relative to working directory
  candidates <- c(".", "..", file.path("..", ".."))
  for (d in candidates) {
    p <- file.path(d, "code", "00_packages.R")
    if (file.exists(p)) return(normalizePath(d))
  }
  stop("Cannot determine BASE_DIR. Run from the paper directory or its code/ subdirectory.")
})
DATA_DIR   <- file.path(BASE_DIR, "data")
FIG_DIR    <- file.path(BASE_DIR, "figures")
TABLE_DIR  <- file.path(BASE_DIR, "tables")
CODE_DIR   <- file.path(BASE_DIR, "code")

dir.create(DATA_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(TABLE_DIR, showWarnings = FALSE, recursive = TRUE)

# APEP standard theme
theme_apep <- function() {
  theme_minimal(base_size = 12) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "grey90", linewidth = 0.3),
      axis.line = element_line(color = "grey30", linewidth = 0.4),
      axis.ticks = element_line(color = "grey30", linewidth = 0.3),
      axis.title = element_text(size = 11, face = "bold"),
      axis.text = element_text(size = 10, color = "grey30"),
      legend.position = "bottom",
      legend.title = element_text(size = 10, face = "bold"),
      legend.text = element_text(size = 9),
      plot.title = element_text(size = 13, face = "bold", hjust = 0),
      plot.subtitle = element_text(size = 10, color = "grey40", hjust = 0),
      plot.caption = element_text(size = 8, color = "grey50", hjust = 1),
      plot.margin = margin(10, 15, 10, 10)
    )
}

# Color palette (colorblind-safe)
apep_colors <- c(
  "#0072B2",  # Blue (treated)
  "#D55E00",  # Orange (control)
  "#009E73",  # Green
  "#CC79A7",  # Pink
  "#F0E442",  # Yellow
  "#56B4E9",  # Light blue
  "#E69F00",  # Amber
  "#000000"   # Black
)

set.seed(42)
options(scipen = 999)

cat("Packages loaded. BASE_DIR:", BASE_DIR, "\n")
