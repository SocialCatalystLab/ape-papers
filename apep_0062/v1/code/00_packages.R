# =============================================================================
# 00_packages.R
# Load and install required packages for sports betting employment analysis
# =============================================================================

# Package list - core packages only (sf/tigris/synthdid removed due to dependencies)
packages <- c(
  # Core data manipulation
  "tidyverse",
  "lubridate",
  "janitor",
  "zoo",           # For na.approx interpolation

  # Difference-in-differences
  "did",           # Callaway-Sant'Anna estimator
  "fixest",        # Sun-Abraham via sunab(), fast FE estimation
  "bacondecomp",   # Goodman-Bacon decomposition

  # Data access
  "httr",          # HTTP requests for BLS API
  "jsonlite",      # JSON parsing

  # Tables and output
  "modelsummary",  # Regression tables
  "kableExtra",    # Table formatting

  # Visualization
  "ggplot2",
  "patchwork",     # Combine plots
  "scales",        # Axis formatting
  "viridis",       # Color palettes

  # Utilities
  "here",          # Project paths
  "glue"           # String interpolation
)

# Install missing packages
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    message(sprintf("Installing %s...", pkg))
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
}

invisible(sapply(packages, install_if_missing))

# Load all packages
invisible(sapply(packages, library, character.only = TRUE))

# Set options
options(
  dplyr.summarise.inform = FALSE,
  scipen = 999,
  digits = 4
)

# Theme for plots
theme_set(theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "bottom"
  ))

cat("Packages loaded successfully.\n")
cat(sprintf("R version: %s\n", R.version.string))
cat(sprintf("did package version: %s\n", packageVersion("did")))
cat(sprintf("fixest package version: %s\n", packageVersion("fixest")))
