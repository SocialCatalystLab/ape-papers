# =============================================================================
# Paper 110: The Price of Distance
# Cannabis Dispensary Access and Alcohol-Related Traffic Fatalities
# 00_packages.R - Load all required packages
# =============================================================================

# Package management
if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  # Core data manipulation
  tidyverse,
  data.table,
  janitor,
  lubridate,
  here,

  # Econometrics
  fixest,       # Fast fixed effects (feols, feglm, fepois)
  did,          # Callaway-Sant'Anna DiD
  HonestDiD,    # Sensitivity analysis for DiD
  sandwich,     # Robust standard errors
  lmtest,       # Inference

  # Spatial analysis
  sf,           # Simple features for R
  tigris,       # Census geographic data

  # Tables and output
  modelsummary,
  kableExtra,
  stargazer,

  # Figures
  ggplot2,
  patchwork,
  scales,
  viridis,
  RColorBrewer,

  # Utilities
  glue,
  progress,
  tictoc
)

# Set options
options(
  scipen = 999,
  dplyr.summarise.inform = FALSE,
  tigris_use_cache = TRUE
)

# APEP figure theme
theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      text = element_text(family = ""),
      plot.title = element_text(size = rel(1.2), face = "bold", hjust = 0),
      plot.subtitle = element_text(size = rel(0.9), hjust = 0, color = "gray40"),
      plot.caption = element_text(size = rel(0.7), hjust = 1, color = "gray50"),
      axis.title = element_text(size = rel(0.9)),
      axis.text = element_text(size = rel(0.8)),
      legend.position = "bottom",
      legend.title = element_text(size = rel(0.8)),
      legend.text = element_text(size = rel(0.7)),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "gray90", linewidth = 0.3),
      strip.text = element_text(face = "bold", size = rel(0.9)),
      plot.margin = margin(10, 10, 10, 10)
    )
}

theme_set(theme_apep())

# Color palette
apep_colors <- c(
  "treatment" = "#E41A1C",
  "control" = "#377EB8",
  "highlight" = "#4DAF4A",
  "neutral" = "#984EA3",
  "legal" = "#4DAF4A",
  "illegal" = "#E41A1C"
)

# Project paths
proj_dir <- here::here("output/paper_110")
data_dir <- file.path(proj_dir, "data")
fig_dir <- file.path(proj_dir, "figures")
tab_dir <- file.path(proj_dir, "tables")
code_dir <- file.path(proj_dir, "code")

# Create directories if needed
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

message("Packages loaded and theme set.")
message("Project directory: ", proj_dir)
