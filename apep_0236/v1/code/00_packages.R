## =============================================================================
## 00_packages.R — Load required packages and set APEP theme
## APEP Working Paper apep_0232
## =============================================================================

cat("Loading packages...\n")

packages <- c(
  "tidyverse", "fixest", "did", "bacondecomp",
  "ggplot2", "latex2exp", "scales", "httr", "jsonlite",
  "knitr", "broom"
)

for (pkg in packages) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org", quiet = TRUE)
    library(pkg, character.only = TRUE)
  }
}

# APEP standard theme for publication-ready figures
theme_apep <- function() {
  theme_minimal(base_size = 12) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "grey90", linewidth = 0.3),
      axis.line = element_line(color = "grey30", linewidth = 0.4),
      axis.ticks = element_line(color = "grey30", linewidth = 0.3),
      axis.title = element_text(size = 11, face = "bold"),
      axis.text = element_text(size = 10, color = "grey30"),
      legend.position = "bottom",
      legend.title = element_text(size = 10, face = "bold"),
      legend.text = element_text(size = 9),
      plot.title = element_text(size = 13, face = "bold", hjust = 0),
      plot.subtitle = element_text(size = 10, color = "grey40", hjust = 0),
      plot.caption = element_text(size = 8, color = "grey50", hjust = 1),
      plot.margin = margin(10, 15, 10, 10)
    )
}

# Colorblind-safe palette
apep_colors <- c(
  "#0072B2",
  "#D55E00",
  "#009E73",
  "#CC79A7",
  "#F0E442",
  "#56B4E9"
)

cat("Packages loaded successfully.\n")
