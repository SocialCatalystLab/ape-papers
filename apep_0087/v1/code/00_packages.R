# ==============================================================================
# 00_packages.R - Load required packages and set global options
# Paper 110: Automation Exposure and Older Worker Labor Force Exit
# ==============================================================================

# Package installation (run once if needed)
required_packages <- c(
  # Data manipulation
  "tidyverse", "data.table", "haven", "readr",
  # Census/API access
  "httr", "jsonlite",
  # Causal inference / DR (simplified - avoid mlr3 dependency issues)
  "AIPW", "SuperLearner", "ranger", "xgboost",
  # Diagnostics
  "cobalt", "WeightIt",
  # Sensitivity analysis
  "EValue", "sensemakr",
  # Tables and figures
  "modelsummary", "kableExtra", "ggplot2", "patchwork", "scales"
)

# Install missing packages
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) {
  message("Installing packages: ", paste(new_packages, collapse = ", "))
  install.packages(new_packages, repos = "https://cloud.r-project.org")
}

# Load packages
suppressPackageStartupMessages({
  library(tidyverse)
  library(data.table)
  library(httr)
  library(jsonlite)
  library(AIPW)
  library(SuperLearner)
  library(ranger)
  library(xgboost)
  library(cobalt)
  library(WeightIt)
  library(EValue)
  library(sensemakr)
  library(modelsummary)
  library(kableExtra)
  library(ggplot2)
  library(patchwork)
  library(scales)
})

# Set global options
options(
  scipen = 999,
  digits = 4,
  dplyr.summarise.inform = FALSE
)

# ggplot2 theme for figures
theme_paper <- theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 12),
    axis.title = element_text(size = 10),
    legend.title = element_text(size = 9),
    legend.text = element_text(size = 8)
  )
theme_set(theme_paper)

# Color palette (colorblind-friendly)
cb_palette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", 
                "#0072B2", "#D55E00", "#CC79A7", "#999999")

# Paths
data_dir <- file.path(getwd(), "data")
fig_dir <- file.path(getwd(), "figures")
tab_dir <- file.path(getwd(), "tables")

# Create directories if they don't exist
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

message("Packages loaded successfully. Data/figure/table directories ready.")
