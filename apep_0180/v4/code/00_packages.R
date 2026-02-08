# ============================================================================
# 00_packages.R - Load required packages and set global options
# MVPF of Unconditional Cash Transfers in Kenya (v4)
# ============================================================================

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
  "MASS",           # Multivariate normal draws (mvrnorm)
  "DRDID"           # Doubly robust DiD estimators
)

install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
}

invisible(lapply(required_packages, install_if_missing))
invisible(lapply(required_packages, library, character.only = TRUE))

options(
  scipen = 999,
  digits = 4,
  dplyr.summarise.inform = FALSE
)

# Publication-quality theme
theme_mvpf <- theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    plot.title = element_text(face = "bold", hjust = 0),
    plot.subtitle = element_text(color = "gray40", size = 10),
    axis.title = element_text(face = "bold"),
    strip.text = element_text(face = "bold")
  )

theme_set(theme_mvpf)

# Colorblind-friendly palette (Okabe-Ito)
mvpf_colors <- c(
  "recipient"  = "#0072B2",
  "spillover"  = "#D55E00",
  "control"    = "#999999",
  "mvpf"       = "#009E73",
  "government" = "#CC79A7",
  "highlight"  = "#E69F00"
)

dir.create("../figures", showWarnings = FALSE)
dir.create("../tables", showWarnings = FALSE)
dir.create("../data", showWarnings = FALSE)

cat("Packages loaded. Theme set. Output directories ready.\n")
