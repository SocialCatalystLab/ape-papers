# =============================================================================
# 00_packages.R — Load libraries and set themes
# apep_0427: France Apprenticeship Subsidy and Entry-Level Labor Markets
# =============================================================================

# Core packages
library(tidyverse)
library(fixest)
library(data.table)
library(readxl)

# Set CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Eurostat data access
if (!requireNamespace("eurostat", quietly = TRUE)) install.packages("eurostat")
library(eurostat)

# FRED data access
if (!requireNamespace("fredr", quietly = TRUE)) install.packages("fredr")
library(fredr)

# DiD packages
library(did)
library(sandwich)
library(lmtest)

# Synthetic control
if (!requireNamespace("tidysynth", quietly = TRUE)) install.packages("tidysynth")

# Tables
library(ggplot2)
library(latex2exp)

# Set FRED API key
fred_key <- Sys.getenv("FRED_API_KEY")
if (nchar(fred_key) > 0) {
  fredr_set_key(fred_key)
}

# --------------------------------------------------
# APEP Standard Theme
# --------------------------------------------------
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

apep_colors <- c(
  "#0072B2",  # Blue (treated/France)
  "#D55E00",  # Orange (control)
  "#009E73",  # Green (third group)
  "#CC79A7",  # Pink (fourth)
  "#F0E442",  # Yellow (fifth)
  "#56B4E9"   # Light blue (sixth)
)

cat("Packages loaded successfully.\n")
