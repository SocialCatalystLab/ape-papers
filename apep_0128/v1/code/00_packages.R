# ==============================================================================
# 00_packages.R
# Netherlands Nitrogen Shock and Housing Markets
# Package installation and loading
# ==============================================================================

# Required packages
packages <- c(
  # Data manipulation
  "tidyverse",
  "data.table",
  "lubridate",

  # CBS data access
  "cbsodataR",

  # Spatial analysis
  "sf",
  "terra",
  "nngeo",

  # Econometrics
  "fixest",
  "did",
  "rdrobust",
  "modelsummary",
  "sandwich",

  # Visualization
  "ggplot2",
  "patchwork",
  "scales",
  "viridis",
  "ggthemes",

  # Tables
  "kableExtra",
  "gt",

  # Misc
  "haven",
  "jsonlite",
  "httr"
)

# Install missing packages
installed <- packages %in% rownames(installed.packages())
if (any(!installed)) {
  install.packages(packages[!installed], repos = "https://cran.r-project.org")
}

# Load all packages
invisible(lapply(packages, library, character.only = TRUE))

# Set options
options(
  scipen = 999,
  digits = 4,
  dplyr.summarise.inform = FALSE
)

# Publication-quality theme
theme_pub <- function(base_size = 12) {
  theme_minimal(base_size = base_size) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "gray90", linewidth = 0.25),
      axis.line = element_line(color = "black", linewidth = 0.3),
      axis.ticks = element_line(color = "black", linewidth = 0.3),
      legend.position = "bottom",
      legend.key.width = unit(1.5, "cm"),
      plot.title = element_text(face = "bold", hjust = 0),
      strip.text = element_text(face = "bold"),
      panel.border = element_rect(color = "black", fill = NA, linewidth = 0.5)
    )
}

theme_set(theme_pub())

# Color palette for treatment groups
treatment_colors <- c(
  "High (< 5km)" = "#d73027",
  "Medium (5-15km)" = "#fc8d59",
  "Low (> 15km)" = "#91bfdb"
)

cat("Packages loaded successfully.\n")
cat("Treatment date: May 29, 2019\n")
