################################################################################
# 00_packages.R
# Paper 188: Moral Foundations Under Digital Pressure
# Revision of apep_0052. Ground-up rebuild with Enke framing.
#
# Input:  None
# Output: Loads required packages, sets themes, defines colors and helpers
################################################################################

# Core tidyverse
library(tidyverse)
library(data.table)

# Econometrics
library(fixest)       # Fast fixed effects estimation with multi-way clustering
library(did)          # Callaway-Sant'Anna DiD
library(bacondecomp)  # Goodman-Bacon decomposition
library(sandwich)     # Robust SEs
library(lmtest)       # Coefficient tests
library(broom)        # Tidy model outputs

# Spatial analysis
library(sf)           # Simple features for spatial data
library(tigris)       # Census TIGER/Line shapefiles

# Tables and figures
library(kableExtra)   # Nice tables
library(patchwork)    # Combining plots
library(scales)       # Nice axis labels
library(viridis)      # Colorblind-friendly palettes

# API access
library(httr)         # HTTP requests
library(jsonlite)     # JSON parsing

# Figure dimensions (consistent across all scripts)
fig_width  <- 8
fig_height <- 5.5
fig_dpi    <- 300

# Color palette
apep_colors <- c(
  "treated"   = "#D73027",
  "control"   = "#4575B4",
  "pre"       = "#91BFDB",
  "post"      = "#FC8D59",
  "ci"        = "#FDAE61",
  "care"      = "#1B9E77",
  "fairness"  = "#D95F02",
  "loyalty"   = "#7570B3",
  "authority" = "#E7298A",
  "sanctity"  = "#66A61E",
  "individualizing" = "#1B9E77",
  "binding"   = "#D95F02",
  "universalism" = "#E6AB02"
)

# Event study colors (used by 07_figures.R plot_event_study helper)
es_colors <- c(
  "pre"  = "#91BFDB",
  "post" = "#FC8D59"
)

# Moral foundation colors (title case, used by 07_figures.R)
mf_colors <- c(
  "Care"            = "#1B9E77",
  "Fairness"        = "#D95F02",
  "Loyalty"         = "#7570B3",
  "Authority"       = "#E7298A",
  "Sanctity"        = "#66A61E",
  "Individualizing" = "#1B9E77",
  "Binding"         = "#D95F02",
  "Universalism"    = "#E6AB02"
)

# Custom ggplot theme for publication
theme_apep <- function(base_size = 11, base_family = "") {
  theme_minimal(base_size = base_size, base_family = base_family) %+replace%
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "gray92", linewidth = 0.3),
      legend.position = "bottom",
      legend.background = element_rect(fill = "white", color = NA),
      plot.title = element_text(face = "bold", size = base_size + 2, hjust = 0),
      plot.subtitle = element_text(color = "gray40", size = base_size, hjust = 0),
      plot.caption = element_text(color = "gray50", size = base_size - 2, hjust = 1),
      strip.text = element_text(face = "bold", size = base_size),
      axis.title = element_text(size = base_size),
      axis.text = element_text(size = base_size - 1),
      plot.margin = margin(10, 10, 10, 10)
    )
}

# Set default theme
theme_set(theme_apep())

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
  tidycensus::census_api_key(Sys.getenv("CENSUS_API_KEY"), install = FALSE)
}

# Patch did package for data.table >= 1.16 compatibility
# (get() inside data.table [i] expression no longer works)
source("code/did_patch.R")

cat("Packages loaded successfully.\n")
cat("R version:", R.version.string, "\n")
