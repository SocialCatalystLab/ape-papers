# ============================================================================
# Technology Obsolescence and Populist Voting
# 00_packages.R - Load required packages and set options
# ============================================================================

# Required packages
packages <- c(
  "haven",        # Read Stata files
  "tidyverse",    # Data manipulation and visualization
  "fixest",       # Fast fixed effects estimation
  "modelsummary", # Regression tables
  "kableExtra",   # Table formatting
  "scales",       # Axis formatting
  "broom",        # Tidy regression output
  "sandwich",     # Robust standard errors
  "lmtest",       # Hypothesis testing
  "ggthemes",     # Publication-quality themes
  "patchwork",    # Combine plots
  "sf",           # Spatial data
  "tigris",       # Census shapefiles
  "viridis"       # Color palettes for maps
)

# Install missing packages
for (pkg in packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
    library(pkg, character.only = TRUE)
  }
}

# Set options
options(
  scipen = 999,           # Avoid scientific notation
  digits = 4,             # Display precision
  dplyr.summarise.inform = FALSE,  # Suppress grouping messages
  knitr.kable.NA = ""     # Don't show NA in tables
)

# Set ggplot theme
theme_set(
  theme_minimal(base_size = 12) +
    theme(
      panel.grid.minor = element_blank(),
      legend.position = "bottom",
      plot.title = element_text(face = "bold"),
      strip.text = element_text(face = "bold")
    )
)

# Color palette for figures
cbsa_colors <- c(
  "High Tech Age" = "#E41A1C",
  "Low Tech Age" = "#377EB8",
  "Trump" = "#E41A1C",
  "Clinton/Biden/Harris" = "#377EB8"
)

cat("Packages loaded successfully.\n")
