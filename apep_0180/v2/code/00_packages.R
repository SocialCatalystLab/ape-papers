# ============================================================================
# 00_packages.R - Load required packages and set global options
# MVPF of Unconditional Cash Transfers in Kenya
# ============================================================================

# Required packages
required_packages <- c(
  "tidyverse",      # Data manipulation and visualization
  "haven",          # Read Stata files
  "fixest",         # Fixed effects estimation
  "sandwich",       # Robust standard errors
  "lmtest",         # Hypothesis testing
  "broom",          # Tidy model outputs
  "knitr",          # Tables
  "kableExtra",     # Enhanced tables
  "ggplot2",        # Visualization
  "scales",         # Scale functions for plots
  "gridExtra",      # Arrange multiple plots
  "stargazer",      # Regression tables
  "modelsummary",   # Model summary tables
  "DRDID"           # Doubly robust DiD estimators
)

# Install missing packages
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
}

invisible(lapply(required_packages, install_if_missing))

# Load packages
invisible(lapply(required_packages, library, character.only = TRUE))

# Set global options
options(
  scipen = 999,           # Avoid scientific notation
  digits = 4,             # Decimal places
  dplyr.summarise.inform = FALSE  # Suppress grouping messages
)

# ggplot2 theme
theme_mvpf <- theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    plot.title = element_text(face = "bold", hjust = 0.5),
    axis.title = element_text(face = "bold")
  )

theme_set(theme_mvpf)

# Color palette (colorblind-friendly)
mvpf_colors <- c(
  "recipient" = "#0072B2",
  "spillover" = "#D55E00",
  "control" = "#999999",
  "mvpf" = "#009E73"
)

# Output directories
dir.create("../figures", showWarnings = FALSE)
dir.create("../tables", showWarnings = FALSE)
dir.create("../data", showWarnings = FALSE)

cat("Packages loaded successfully.\n")
cat("Theme set to theme_mvpf.\n")
cat("Output directories created.\n")
