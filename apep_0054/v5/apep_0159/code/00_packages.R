# ============================================================================
# 00_packages.R
# Salary Transparency Laws and the Gender Wage Gap
# Package Loading and Theme Setup
# ============================================================================

# ---- Core packages ----
library(tidyverse)
library(data.table)
library(haven)

# ---- IPUMS data access ----
library(ipumsr)

# ---- Difference-in-Differences ----
library(did)          # Callaway-Sant'Anna
library(fixest)       # Sun-Abraham via sunab(), fast TWFE, tables
library(did2s)        # Gardner's two-stage

# ---- Sensitivity Analysis ----
# HonestDiD for Rambachan-Roth bounds on parallel trends violations
# Install with: remotes::install_github("asheshrambachan/HonestDiD")
# Will be loaded conditionally in 05_robustness.R

# ---- Inference ----
library(sandwich)
library(lmtest)
# Wild cluster bootstrap - loaded conditionally
if (requireNamespace("fwildclusterboot", quietly = TRUE)) {
  library(fwildclusterboot)
  cat("fwildclusterboot loaded for wild cluster bootstrap inference.\n")
} else {
  cat("WARNING: fwildclusterboot not available. Bootstrap inference will be skipped.\n")
}

# ---- Visualization ----
library(ggplot2)
library(latex2exp)
library(scales)
library(patchwork)

# ---- Mapping ----
library(sf)
library(tigris)
options(tigris_use_cache = TRUE)

# ---- API access ----
library(httr)
library(jsonlite)

# ============================================================================
# APEP Standard Theme
# ============================================================================

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
  "#0072B2",  # Blue (treated/primary)
  "#D55E00",  # Orange (control)
  "#009E73",  # Green (third group)
  "#CC79A7",  # Pink (fourth group/female)
  "#F0E442",  # Yellow (fifth group)
  "#56B4E9"   # Light blue (sixth group/male)
)

# Named colors for specific uses
color_treated <- "#0072B2"
color_control <- "#D55E00"
color_female <- "#CC79A7"
color_male <- "#56B4E9"
color_ci <- "#0072B2"

# ============================================================================
# Directory Setup
# ============================================================================

# Create output directories if they don't exist
dir.create("data", showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)
dir.create("tables", showWarnings = FALSE)

# ============================================================================
# Helper Functions
# ============================================================================

# Function to calculate hourly wage from annual income and hours
calc_hourly_wage <- function(annual_wage, hours_per_week, weeks_worked = 52) {
  # Assume 52 weeks if not specified
  annual_hours <- hours_per_week * weeks_worked
  hourly_wage <- annual_wage / annual_hours
  return(hourly_wage)
}

# Function to winsorize at percentiles
winsorize <- function(x, probs = c(0.01, 0.99)) {
  q <- quantile(x, probs, na.rm = TRUE)
  x[x < q[1]] <- q[1]
  x[x > q[2]] <- q[2]
  return(x)
}

# ============================================================================
# Salary Transparency Law Data
# ============================================================================
#
# IMPORTANT: Treatment timing with official citations is now in 00_policy_data.R
# Run that script first to create data/transparency_laws.rds with proper provenance.
#
# This section checks if the data file exists and loads it.

if (file.exists("data/transparency_laws.rds")) {
  transparency_laws <- readRDS("data/transparency_laws.rds")
  cat("Loaded transparency law data from data/transparency_laws.rds\n")
  cat("  Treated states:", sum(transparency_laws$first_treat > 0), "\n")
} else {
  cat("WARNING: data/transparency_laws.rds not found.\n")
  cat("Run 00_policy_data.R first to create treatment timing data.\n")
}

cat("Packages loaded and theme configured.\n")
