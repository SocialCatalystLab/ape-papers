# ============================================================================
# 00_packages.R
# State Minimum Wage and Business Formation
# Load required packages and set options
# ============================================================================

# Install packages if needed
required_packages <- c(
  # Data manipulation
  "tidyverse",
  "data.table",
  "lubridate",
  "janitor",

  # API and data access
  "httr",
  "jsonlite",
  "censusapi",

  # Econometrics
  "fixest",       # Fast fixed effects
  "did",          # Callaway-Sant'Anna
  "bacondecomp",  # Goodman-Bacon decomposition
  "modelsummary", # Regression tables
  "sandwich",     # Robust SEs

  # Visualization
  "ggplot2",
  "patchwork",
  "scales",
  "viridis",
  "ggthemes",

  # Tables
  "kableExtra",
  "gt"
)

# Install missing packages
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) {
  install.packages(new_packages, repos = "https://cloud.r-project.org")
}

# Load packages
invisible(lapply(required_packages, library, character.only = TRUE))

# Set options
options(
  scipen = 999,
  digits = 4,
  dplyr.summarise.inform = FALSE
)

# APEP theme for figures
theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", size = base_size * 1.2),
      plot.subtitle = element_text(color = "gray40", size = base_size * 0.9),
      plot.caption = element_text(color = "gray50", size = base_size * 0.7, hjust = 0),
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      legend.position = "bottom",
      legend.title = element_text(size = base_size * 0.9),
      axis.title = element_text(size = base_size * 0.9),
      strip.text = element_text(face = "bold")
    )
}

# Set as default
theme_set(theme_apep())

# Color palette
apep_colors <- c(
  "primary" = "#2C3E50",
  "secondary" = "#E74C3C",
  "tertiary" = "#3498DB",
  "quaternary" = "#27AE60",
  "gray" = "#95A5A6"
)

cat("Packages loaded successfully.\n")
cat("R version:", R.version$version.string, "\n")
