###############################################################################
# 00_packages.R
# Paper 141: EERS and Residential Electricity Consumption (Revision of apep_0130)
# Load all required packages and set global options
###############################################################################

# ── Core packages ──
library(tidyverse)
library(fixest)
library(did)           # Callaway-Sant'Anna
library(bacondecomp)   # Goodman-Bacon decomposition
library(HonestDiD)     # Rambachan-Roth sensitivity analysis
library(zoo)           # For na.approx interpolation

# Wild cluster bootstrap
if (requireNamespace("fwildclusterboot", quietly = TRUE)) {
  library(fwildclusterboot)
  cat("fwildclusterboot loaded for wild cluster bootstrap.\n")
}

# Synthetic DiD (optional - may not be available on all systems)
if (requireNamespace("synthdid", quietly = TRUE)) {
  library(synthdid)
  cat("synthdid loaded for Synthetic DiD analysis.\n")
} else {
  cat("synthdid not available - will use manual SDID implementation.\n")
}

# ── Data packages ──
library(jsonlite)
library(httr)

# ── Tables & Figures ──
library(ggplot2)
library(latex2exp)
library(scales)

# ── Set global options ──
options(
  scipen = 999,
  digits = 4,
  dplyr.summarise.inform = FALSE
)

# ── APEP Theme for figures ──
theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", size = base_size + 2, hjust = 0),
      plot.subtitle = element_text(color = "gray40", size = base_size),
      plot.caption = element_text(color = "gray50", size = base_size - 2, hjust = 0),
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      axis.title = element_text(size = base_size),
      axis.text = element_text(size = base_size - 1),
      legend.position = "bottom",
      legend.title = element_text(size = base_size - 1),
      legend.text = element_text(size = base_size - 2),
      strip.text = element_text(face = "bold", size = base_size)
    )
}

theme_set(theme_apep())

# ── Color palette ──
apep_colors <- c(
  "treated"   = "#2C5F8A",
  "control"   = "#C44E52",
  "highlight" = "#4C9F38",
  "neutral"   = "#7F7F7F"
)

cat("Packages loaded successfully.\n")
