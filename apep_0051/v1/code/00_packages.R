# Paper 67: Aging Out at 26 and Fertility
# 00_packages.R - Load required packages and set options

# Install packages if needed
required_packages <- c(
  "tidyverse",
  "httr",
  "jsonlite",
  "rdrobust",
  "rddensity",
  "fixest",
  "modelsummary",
  "patchwork",
  "scales",
  "sandwich",
  "lmtest"
)

for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
    library(pkg, character.only = TRUE)
  }
}

# APEP theme for publication-quality figures
theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      # Text elements
      plot.title = element_text(face = "bold", size = rel(1.2), hjust = 0),
      plot.subtitle = element_text(size = rel(1.0), hjust = 0, color = "gray40"),
      plot.caption = element_text(size = rel(0.8), hjust = 1, color = "gray40"),

      # Axis
      axis.title = element_text(size = rel(1.0)),
      axis.text = element_text(size = rel(0.9)),
      axis.line = element_line(color = "gray40", size = 0.3),

      # Panel
      panel.grid.major = element_line(color = "gray90", size = 0.2),
      panel.grid.minor = element_blank(),
      panel.border = element_blank(),

      # Legend
      legend.position = "bottom",
      legend.title = element_text(size = rel(0.9)),
      legend.text = element_text(size = rel(0.85)),

      # Facets
      strip.text = element_text(face = "bold", size = rel(1.0)),
      strip.background = element_rect(fill = "gray95", color = NA)
    )
}

# Set default theme
theme_set(theme_apep())

# Color palette
apep_colors <- c(
  "primary" = "#2E86AB",
  "secondary" = "#A23B72",
  "accent" = "#F18F01",
  "success" = "#C73E1D",
  "neutral" = "#3B3B3B"
)

# Set options
options(
  scipen = 999,
  digits = 3,
  dplyr.summarise.inform = FALSE
)

# Output directories
data_dir <- "output/paper_67/data"
fig_dir <- "output/paper_67/figures"
code_dir <- "output/paper_67/code"

cat("Packages loaded and APEP theme set.\n")
