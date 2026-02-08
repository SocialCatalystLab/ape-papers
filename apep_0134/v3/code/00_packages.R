# ==============================================================================
# 00_packages.R
# NYC Overdose Prevention Centers and Overdose Deaths
# Paper 136 (Revision of apep_0134): Do Supervised Drug Injection Sites Save Lives?
# ==============================================================================

# Package management
if (!require("pacman")) install.packages("pacman")

pacman::p_load(
  # Data manipulation
  tidyverse,
  lubridate,
  janitor,

  # Synthetic control - using gsynth (works with R 4.5.2)
  # augsynth not available for R 4.5.2, so we implement de-meaned SCM manually
  gsynth,        # Generalized Synthetic Control (Xu 2017)
  Synth,         # Traditional SCM for comparison

  # Panel data / DiD
  fixest,
  did,

  # Inference
  fwildclusterboot,

  # Visualization
  ggplot2,
  ggthemes,
  patchwork,
  scales,
  viridis,       # Color scales for maps

  # Tables
  modelsummary,
  kableExtra,
  gt,
  broom,         # For tidy model output

  # Spatial (for mapping)
  sf,
  tigris,

  # Utilities
  here,
  glue
)

# Set theme for all plots
theme_set(
  theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", size = 14),
      plot.subtitle = element_text(size = 11, color = "gray40"),
      axis.title = element_text(size = 11),
      legend.position = "bottom",
      panel.grid.minor = element_blank()
    )
)

# Color palette
opc_colors <- c(
  "treated" = "#E41A1C",    # Red for treated units
  "synthetic" = "#377EB8",   # Blue for synthetic control
  "donor" = "#999999"        # Gray for donor pool
)

# Set random seed for reproducibility
set.seed(20211130)  # OPC opening date

# Base directory for paper outputs
# Uses here() to find project root, then locates paper directory
# This works for both development (output/paper_N) and published (papers/apep_XXXX)
BASE_DIR <- here::here()
# Find the paper directory by looking for paper.tex relative to code/
CODE_DIR <- getwd()
if (grepl("/code$", CODE_DIR)) {
  PAPER_DIR <- dirname(CODE_DIR)
} else {
  # Running from project root - use here() detection
  PAPER_DIR <- BASE_DIR
}

cat("Packages loaded successfully.\n")
cat("R version:", R.version.string, "\n")
cat("Paper directory:", PAPER_DIR, "\n")
