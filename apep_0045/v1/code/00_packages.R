# ==============================================================================
# 00_packages.R - Load libraries and set themes for auto-IRA analysis
# Paper 60: State Auto-IRA Mandates and Retirement Savings
# ==============================================================================

# Core data manipulation
library(tidyverse)
library(data.table)
library(haven)

# IPUMS data access
library(ipumsr)

# DiD estimation
library(did)          # Callaway-Sant'Anna
library(fixest)       # Sun-Abraham via sunab(), fast TWFE
library(did2s)        # Gardner two-stage
library(HonestDiD)    # Sensitivity analysis

# Inference
library(sandwich)
library(lmtest)

# Visualization
library(ggplot2)
library(latex2exp)
library(scales)

# Mapping
library(sf)
library(tigris)
options(tigris_use_cache = TRUE)

# Tables
library(modelsummary)

# Set seed for reproducibility
set.seed(42)

# ==============================================================================
# APEP Theme for Publication-Ready Figures
# ==============================================================================

theme_apep <- function() {
  theme_minimal(base_size = 12) +
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
  "#0072B2",  # Blue (treated)
  "#D55E00",  # Orange (control)
  "#009E73",  # Green (third group)
  "#CC79A7",  # Pink (fourth group)
  "#F0E442",  # Yellow (fifth group)
  "#56B4E9"   # Light blue (sixth group)
)

# Set default theme
theme_set(theme_apep())

# ==============================================================================
# Variable Labels for fixest
# ==============================================================================

setFixest_dict(c(
  auto_ira = "Auto-IRA State",
  post = "Post-Adoption",
  treat_post = "Auto-IRA $\\times$ Post",
  has_pension = "Has Retirement Plan",
  age = "Age",
  female = "Female",
  married = "Married",
  educ_hs = "High School",
  educ_some_college = "Some College",
  educ_ba_plus = "Bachelor's+",
  log_income = "Log Income",
  employed = "Employed",
  private_sector = "Private Sector"
))

cat("Packages loaded and theme set.\n")
