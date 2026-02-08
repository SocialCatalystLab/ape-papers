# ============================================================================
# Paper 64: The Pence Effect
# 00_packages.R - Package loading and global settings
# ============================================================================

# Install missing packages
required_packages <- c(
  # Data manipulation
  "tidyverse", "data.table", "lubridate", "janitor",
  # Census API
  "censusapi", "httr", "jsonlite",
  # Econometrics
  "fixest", "did", "sandwich", "lmtest",
  # Tables and figures
  "ggplot2", "latex2exp", "scales", "patchwork"
  # Note: sf and tigris require system dependencies (udunits2, etc.)
  # Install separately if needed for mapping
)

for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
    library(pkg, character.only = TRUE)
  }
}

# ============================================================================
# Global Settings
# ============================================================================

# Set working directory relative to script location
# When running interactively, set manually; for replication use here::here()
if (!require("here", quietly = TRUE)) {
  install.packages("here", repos = "https://cloud.r-project.org")
}
# setwd(here::here())  # Uncomment for replication

# Census API key (if available)
CENSUS_API_KEY <- Sys.getenv("CENSUS_API_KEY")

# Create directories
dir.create("data", showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)

# ============================================================================
# APEP Theme for Publication-Ready Figures
# ============================================================================

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

# ============================================================================
# Industry Classification
# ============================================================================

# NAICS 2-digit sectors
naics_labels <- c(
  "11" = "Agriculture",
  "21" = "Mining",
  "22" = "Utilities",
  "23" = "Construction",
  "31-33" = "Manufacturing",
  "42" = "Wholesale Trade",
  "44-45" = "Retail Trade",
  "48-49" = "Transportation",
  "51" = "Information",
  "52" = "Finance & Insurance",
  "53" = "Real Estate",
  "54" = "Professional Services",
  "55" = "Management",
  "56" = "Administrative Services",
  "61" = "Education",
  "62" = "Health Care",
  "71" = "Arts & Entertainment",
  "72" = "Accommodation & Food",
  "81" = "Other Services"
)

# High-harassment industries (based on EEOC charge rates)
high_harassment_industries <- c("72", "44-45", "62", "71", "56")
low_harassment_industries <- c("52", "54", "51", "22", "21", "55")

cat("Packages loaded. Working directory:", getwd(), "\n")
