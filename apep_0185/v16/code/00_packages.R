################################################################################
# 00_packages.R
# Social Network Minimum Wage Exposure - Population-Weighted Revision
#
# Input:  None
# Output: Loads required packages, sets themes and options
################################################################################

# Core tidyverse
library(tidyverse)
library(lubridate)
library(data.table)   # Fast data manipulation for large SCI matrix

# Econometrics
library(fixest)       # Fast fixed effects estimation with multi-way clustering
library(did)          # Callaway-Sant'Anna DiD
# library(AER)          # Instrumental variables - not needed, using fixest instead
library(sandwich)     # Robust SEs
library(lmtest)       # Coefficient tests
library(broom)        # Tidy model outputs

# Network analysis
library(igraph)       # Graph algorithms, Louvain clustering
library(Matrix)       # Sparse matrices for SCI

# Spatial analysis
library(sf)           # Simple features for spatial data
library(tigris)       # Census TIGER/Line shapefiles
library(tidycensus)   # Census data and geography

# Tables and figures
library(kableExtra)   # Nice tables
library(patchwork)    # Combining plots
library(scales)       # Nice axis labels
library(viridis)      # Colorblind-friendly palettes

# API access
library(httr)         # HTTP requests
library(jsonlite)     # JSON parsing

# Set ggplot2 theme
theme_set(
  theme_minimal(base_size = 11) +
    theme(
      panel.grid.minor = element_blank(),
      legend.position = "bottom",
      plot.title = element_text(face = "bold"),
      strip.text = element_text(face = "bold")
    )
)

# Color palettes
palette_exposure <- c("Low" = "#4575b4", "Medium" = "#fee090", "High" = "#d73027")
palette_industry <- c("High Bite" = "#d73027", "Low Bite" = "#4575b4")

# Set seed for reproducibility
set.seed(42)

# Options
options(
  scipen = 999,
  digits = 4,
  dplyr.summarise.inform = FALSE,
  tigris_use_cache = TRUE,
  tigris_class = "sf"
)

# Census API key (set via environment variable)
if (Sys.getenv("CENSUS_API_KEY") != "") {
  census_api_key(Sys.getenv("CENSUS_API_KEY"), install = FALSE)
}

cat("Packages loaded successfully.\n")
cat("R version:", R.version.string, "\n")
