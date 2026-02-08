# ==============================================================================
# Paper 86: Minimum Wage and Teen Time Allocation
# 00_packages.R - Package installation and loading
# ==============================================================================

# Install packages if needed
packages <- c(
  # Data manipulation
  "tidyverse",
  "data.table",
  "haven",
  "readxl",

  # IPUMS
  "ipumsr",

  # Econometrics
  "fixest",
  "did",
  "HonestDiD",
  "modelsummary",
  "broom",

  # Visualization
  "ggplot2",
  "patchwork",
  "scales",
  "viridis",

  # Tables
  "kableExtra",
  "gt",

  # Utilities
  "lubridate",
  "janitor"
)

# Install missing packages
new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) {
  install.packages(new_packages, repos = "https://cloud.r-project.org")
}

# Load packages
invisible(lapply(packages, library, character.only = TRUE))

# ==============================================================================
# APEP Theme for figures
# ==============================================================================

theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      # Text
      plot.title = element_text(face = "bold", size = rel(1.2), hjust = 0),
      plot.subtitle = element_text(size = rel(0.9), hjust = 0, color = "gray40"),
      plot.caption = element_text(size = rel(0.8), hjust = 1, color = "gray50"),

      # Axes
      axis.title = element_text(size = rel(0.9)),
      axis.text = element_text(size = rel(0.85)),
      axis.line = element_line(color = "gray40", linewidth = 0.3),

      # Panel
      panel.grid.major = element_line(color = "gray90", linewidth = 0.2),
      panel.grid.minor = element_blank(),
      panel.border = element_blank(),

      # Legend
      legend.position = "bottom",
      legend.title = element_text(size = rel(0.9)),
      legend.text = element_text(size = rel(0.85)),

      # Facets
      strip.text = element_text(face = "bold", size = rel(0.9)),
      strip.background = element_rect(fill = "gray95", color = NA),

      # Plot margins
      plot.margin = margin(10, 10, 10, 10)
    )
}

# Set as default theme
theme_set(theme_apep())

# Color palettes
apep_colors <- c(
  "blue" = "#2171b5",
  "red" = "#cb181d",
  "green" = "#238b45",
  "orange" = "#d94801",
  "purple" = "#6a51a3",
  "gray" = "#525252"
)

apep_palette <- function(n = 6) {
  unname(apep_colors[1:min(n, length(apep_colors))])
}

# ==============================================================================
# Utility functions
# ==============================================================================

# Standard errors clustered at state level
cluster_se <- function(model, cluster_var) {
  summary(model, cluster = cluster_var)
}

# Print session info
cat("\n=== Session Info ===\n")
cat("R version:", R.version.string, "\n")
cat("Date:", as.character(Sys.Date()), "\n")
cat("Packages loaded successfully\n")
