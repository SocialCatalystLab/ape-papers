# ============================================================================
# 00_packages.R
# Swedish School Transport (Skolskjuts) and Educational Equity
# Package installation and loading
# ============================================================================

# Required packages
packages <- c(
  # Data manipulation
  "tidyverse",
  "data.table",
  "janitor",
  "lubridate",

  # Spatial analysis
  "sf",
  "terra",
  "units",

  # API access
  "httr2",
  "jsonlite",
  "xml2",

  # Econometrics - RDD
  "rdrobust",      # Robust RDD estimation
  "rddensity",     # Manipulation testing

  # Visualization
  "ggplot2",
  "ggthemes",
  "scales",
  "patchwork",
  "viridis",

  # Tables
  "kableExtra",
  "gt",
  "modelsummary"
)

# Install missing packages
installed <- packages %in% rownames(installed.packages())
if (any(!installed)) {
  install.packages(packages[!installed], repos = "https://cloud.r-project.org")
}

# Load all packages
invisible(lapply(packages, library, character.only = TRUE))

# Set global options
options(
  scipen = 999,
  digits = 4,
  dplyr.summarise.inform = FALSE
)

# Set ggplot theme
theme_set(
  theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      plot.subtitle = element_text(color = "gray40"),
      panel.grid.minor = element_blank(),
      legend.position = "bottom"
    )
)

# Color palette for Sweden
sweden_colors <- c(
  blue = "#006AA7",   # Swedish flag blue
  yellow = "#FECC00", # Swedish flag yellow
  gray = "#6E6E6E",
  light_blue = "#4A90D9",
  dark_blue = "#003366"
)

# Create output directories
dir.create("../figures", showWarnings = FALSE)
dir.create("../tables", showWarnings = FALSE)
dir.create("../data/raw", showWarnings = FALSE, recursive = TRUE)
dir.create("../data/processed", showWarnings = FALSE, recursive = TRUE)

cat("Packages loaded and environment configured.\n")
cat("Working directory:", getwd(), "\n")
