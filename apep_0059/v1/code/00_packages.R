# =============================================================================
# 00_packages.R
# Self-Employment and Health Insurance Coverage: A Doubly Robust Analysis
# Load libraries, set themes, define helper functions
# =============================================================================

# Core packages
library(tidyverse)
library(data.table)

# Doubly Robust estimation
library(AIPW)
library(SuperLearner)

# Sensitivity analysis
library(sensemakr)
library(EValue)

# Tables and figures
library(ggplot2)
library(latex2exp)
library(scales)

# Inference
library(sandwich)
library(lmtest)

# Set random seed for reproducibility
set.seed(20260125)

# =============================================================================
# APEP Standard Theme
# =============================================================================

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

# Colorblind-safe palette
apep_colors <- c(
  "#0072B2",  # Blue
  "#D55E00",  # Orange
  "#009E73",  # Green
  "#CC79A7",  # Pink
  "#F0E442",  # Yellow
  "#56B4E9"   # Light blue
)

# Set as default
theme_set(theme_apep())

# =============================================================================
# Helper Functions
# =============================================================================

# Weighted summary statistics
weighted_summary <- function(x, w) {
  list(
    mean = weighted.mean(x, w, na.rm = TRUE),
    sd = sqrt(Hmisc::wtd.var(x, w, na.rm = TRUE)),
    n = sum(!is.na(x))
  )
}

# Standardized mean difference
smd <- function(x, treat, weights = NULL) {
  if (is.null(weights)) weights <- rep(1, length(x))

  m1 <- weighted.mean(x[treat == 1], weights[treat == 1], na.rm = TRUE)
  m0 <- weighted.mean(x[treat == 0], weights[treat == 0], na.rm = TRUE)

  v1 <- Hmisc::wtd.var(x[treat == 1], weights[treat == 1], na.rm = TRUE)
  v0 <- Hmisc::wtd.var(x[treat == 0], weights[treat == 0], na.rm = TRUE)

  pooled_sd <- sqrt((v1 + v0) / 2)

  (m1 - m0) / pooled_sd
}

# =============================================================================
# Directory paths
# =============================================================================

data_dir <- "data/"
fig_dir <- "figures/"

# Create if not exist
dir.create(data_dir, showWarnings = FALSE)
dir.create(fig_dir, showWarnings = FALSE)

cat("Packages loaded successfully.\n")
cat("Theme set to APEP standard.\n")
cat("Data directory:", data_dir, "\n")
cat("Figures directory:", fig_dir, "\n")
