# ==============================================================================
# 00_packages.R
# Load required packages and set global options
# Paper 111: NP Full Practice Authority and Physician Employment
# ==============================================================================

# Package installation (if needed)
required_packages <- c(
  "tidyverse",     # Data manipulation and visualization
  "did",           # Callaway-Sant'Anna DiD estimator
  "fixest",        # Fast fixed effects estimation
  "modelsummary",  # Regression tables
  "kableExtra",    # Table formatting
  "scales",        # Axis formatting
  "httr",          # HTTP requests for API
  "jsonlite",      # JSON parsing
  "lubridate",     # Date handling
  "haven",         # Data import
  "broom",         # Tidy model output
  "patchwork",     # Combining plots
  "sf",            # Spatial data (for maps)
  "usmap"          # US map data
)

# Install missing packages
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages, repos = "https://cloud.r-project.org/")

# Load packages
suppressPackageStartupMessages({
  library(tidyverse)
  library(did)
  library(fixest)
  library(modelsummary)
  library(kableExtra)
  library(scales)
  library(httr)
  library(jsonlite)
  library(lubridate)
  library(broom)
  library(patchwork)
  library(usmap)
})

# Global options
options(
  scipen = 999,           # Disable scientific notation
  digits = 4,             # Decimal places
  dplyr.summarise.inform = FALSE,
  readr.show_col_types = FALSE
)

# ggplot2 theme
theme_set(
  theme_minimal(base_size = 12) +
    theme(
      panel.grid.minor = element_blank(),
      plot.title = element_text(face = "bold"),
      legend.position = "bottom"
    )
)

# Color palette for figures
colors_main <- c(
  "FPA States" = "#2E86AB",
  "Non-FPA States" = "#E94F37"
)

# Paths - use parent directory (paper_111/)
base_dir <- dirname(getwd())
data_dir <- file.path(base_dir, "data/")
fig_dir <- file.path(base_dir, "figures/")
tab_dir <- file.path(base_dir, "tables/")

# Create directories if needed
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

cat("Packages loaded successfully.\n")
cat("Working directory:", getwd(), "\n")
