# ============================================================================
# Paper 75: The Making of a City
# 00_packages.R - Load libraries and set themes
# ============================================================================

# Core packages
library(tidyverse)
library(data.table)
library(ipumsr)

# Visualization
library(ggplot2)
library(latex2exp)
library(scales)
library(patchwork)

# Spatial/mapping (load only if needed for figures)
# library(sf)
# library(tigris)
# options(tigris_use_cache = TRUE)

# Set random seed for reproducibility
set.seed(42)

# ============================================================================
# APEP Standard Theme
# ============================================================================

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
  "#0072B2",  # Blue (SF/treated)
  "#D55E00",  # Orange (LA/control)
  "#009E73",  # Green (Seattle)
  "#CC79A7",  # Pink
  "#F0E442",  # Yellow
  "#56B4E9"   # Light blue
)

# Era colors for historical periods
era_colors <- c(
  "Gold Rush (1850s)" = "#8B4513",      # Brown
  "Railroad Era (1870s)" = "#4169E1",   # Royal blue
  "Pre-Earthquake (1890s)" = "#228B22", # Forest green
  "Post-Earthquake (1910s)" = "#DC143C" # Crimson
)

# Set ggplot defaults
theme_set(theme_apep())

# ============================================================================
# Helper Functions
# ============================================================================

# Format large numbers with commas
fmt_num <- function(x) format(x, big.mark = ",", scientific = FALSE)

# Calculate percentage
pct <- function(x, digits = 1) round(x * 100, digits)

# Memory-efficient data loading message
msg <- function(...) message(paste0("[", Sys.time(), "] ", ...))

# ============================================================================
# Geographic Constants
# ============================================================================

# San Francisco County
SF_STATEFIP <- 6
SF_COUNTYFIP <- 75

# Los Angeles County (comparison city)
LA_STATEFIP <- 6
LA_COUNTYFIP <- 37

# Seattle (King County, WA) (comparison city)
SEA_STATEFIP <- 53
SEA_COUNTYFIP <- 33

# Census years available in MLP
CENSUS_YEARS <- c(1850, 1860, 1870, 1880, 1900, 1910, 1920, 1930, 1940, 1950)

# ============================================================================
# IPUMS Variable Codebook (key variables)
# ============================================================================

# HISTID: Unique person identifier for linking across censuses
# SERIAL: Household serial number
# PERNUM: Person number within household
# YEAR: Census year
# STATEFIP: State FIPS code
# COUNTY: County FIPS code
# AGE: Age in years
# SEX: 1=Male, 2=Female
# RACE: 1=White, 2=Black, 3=American Indian, etc.
# MARST: Marital status
# BPL: Birthplace (state/country code)
# NATIVITY: 0=Native-born, 1-5=Foreign-born
# LIT: Literacy (4=Can read and write)
# SCHOOL: School attendance
# OCC1950: Occupation (1950 basis)
# IND1950: Industry (1950 basis)
# LABFORCE: Labor force participation
# MOMLOC: Line number of mother in household
# POPLOC: Line number of father in household
# SPLOC: Line number of spouse

msg("Packages loaded and theme set")
