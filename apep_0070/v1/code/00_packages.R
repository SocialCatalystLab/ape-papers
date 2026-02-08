# =============================================================================
# 00_packages.R - Package Installation and Loading
# Swiss Childcare Mandates and Maternal Labor Supply
# Spatial RDD at Canton Borders
# =============================================================================

# Install packages if needed
packages <- c(
  # Data manipulation
  "tidyverse",
  "data.table",

  # Spatial analysis
  "sf",
  "SpatialRDD",

  # RDD estimation
  "rdrobust",
  "rddensity",

  # Econometrics
  "fixest",
  "modelsummary",

  # Swiss data
  "swissdd",
  "BFS",
  "SMMT",

  # Visualization
  "ggplot2",
  "scales",
  "viridis",
  "patchwork"
)

# Install missing packages
for (pkg in packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org", quiet = TRUE)
    library(pkg, character.only = TRUE)
  }
}

# APEP theme for figures
theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "gray90"),
      plot.title = element_text(face = "bold", size = base_size + 2),
      plot.subtitle = element_text(color = "gray40"),
      axis.title = element_text(face = "bold"),
      legend.position = "bottom",
      strip.text = element_text(face = "bold"),
      plot.caption = element_text(hjust = 0, color = "gray50")
    )
}

# Set theme globally
theme_set(theme_apep())

# Color palette
apep_colors <- c(
  treated = "#2166AC",    # Blue for treated
  control = "#B2182B",    # Red for control
  neutral = "#4D4D4D",    # Gray
  highlight = "#D73027"   # Bright red for emphasis
)

message("All packages loaded successfully")
message(paste("R version:", R.version.string))
