# ============================================================================
# Paper 66: Salary Transparency Laws and Wage Outcomes
# 00_packages.R - Load required packages and set themes
# ============================================================================

# Core packages
library(tidyverse)
library(data.table)
library(haven)

# DiD packages
library(did)          # Callaway-Sant'Anna
library(fixest)       # Sun-Abraham via sunab(), fast TWFE
library(did2s)        # Gardner two-stage
library(HonestDiD)    # Rambachan-Roth sensitivity

# Inference
library(sandwich)
library(lmtest)
library(clubSandwich) # Small-sample clustered SEs

# IPUMS data access
library(ipumsr)

# Visualization
library(ggplot2)
library(latex2exp)
library(scales)
library(patchwork)    # Combine ggplots

# Mapping
library(sf)
library(tigris)
options(tigris_use_cache = TRUE)

# Tables
library(modelsummary)
library(kableExtra)

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
      legend.key.width = unit(1.5, "cm"),

      # Title
      plot.title = element_text(size = 13, face = "bold", hjust = 0),
      plot.subtitle = element_text(size = 10, color = "grey40", hjust = 0),
      plot.caption = element_text(size = 8, color = "grey50", hjust = 1),

      # Margins
      plot.margin = margin(10, 15, 10, 10)
    )
}

# Set as default theme
theme_set(theme_apep())

# Color palette (colorblind-safe)
apep_colors <- c(
  "treated"   = "#0072B2",  # Blue
  "control"   = "#D55E00",  # Orange
  "male"      = "#56B4E9",  # Light blue
  "female"    = "#CC79A7",  # Pink
  "highlight" = "#009E73",  # Green
  "neutral"   = "#999999"   # Grey
)

# Treatment cohort colors
cohort_colors <- c(
  "2021" = "#1a9850",  # Green (early)
  "2023" = "#91cf60",  # Light green
  "2024" = "#d9ef8b",  # Yellow-green
  "2025" = "#fee08b",  # Yellow
  "Never treated" = "#d73027"  # Red
)

# ============================================================================
# Helper Functions
# ============================================================================

# Standard errors formatter
format_se <- function(se, digits = 3) {
  paste0("(", format(round(se, digits), nsmall = digits), ")")
}

# Stars for significance
add_stars <- function(p) {
  case_when(
    p < 0.01 ~ "***",
    p < 0.05 ~ "**",
    p < 0.10 ~ "*",
    TRUE ~ ""
  )
}

# Save figure with standard dimensions
save_figure <- function(plot, filename, width = 8, height = 6, dpi = 300) {
  ggsave(
    filename = file.path("figures", filename),
    plot = plot,
    width = width,
    height = height,
    dpi = dpi,
    bg = "white"
  )
  message("Saved: ", filename)
}

# ============================================================================
# Output directory setup
# ============================================================================

dir.create("figures", showWarnings = FALSE)
dir.create("tables", showWarnings = FALSE)
dir.create("data", showWarnings = FALSE)

message("Packages loaded successfully.")
message("Working directory: ", getwd())
