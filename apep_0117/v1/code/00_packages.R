# =============================================================================
# 00_packages.R
# Load required packages and set global options
# Project: Self-Employment as Bridge Employment
# =============================================================================

# Package installation check
required_packages <- c(
  # Data manipulation
  "tidyverse",
  "data.table",
  "janitor",
  
  # API access
  "httr",
  "jsonlite",
  
  # Causal inference - Doubly Robust
  "AIPW",
  "DoubleML",
  "mlr3",
  "mlr3learners",
  "SuperLearner",
  
  # ML backends
  "ranger",
  "xgboost",
  "glmnet",
  
  # Diagnostics
  "cobalt",
  "WeightIt",
  
  # Sensitivity analysis
  "sensemakr",
  
  # Visualization
  "ggplot2",
  "patchwork",
  "scales",
  "viridis",
  
  # Tables
  "modelsummary",
  "kableExtra",
  "gt",
  
  # Parallel processing
  "future",
  "furrr"
)

# Install missing packages
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    message(paste("Installing:", pkg))
    install.packages(pkg, repos = "https://cloud.r-project.org", quiet = TRUE)
  }
}

invisible(sapply(required_packages, install_if_missing))

# Load packages
suppressPackageStartupMessages({
  library(tidyverse)
  library(data.table)
  library(janitor)
  library(httr)
  library(jsonlite)
  library(AIPW)
  library(DoubleML)
  library(mlr3)
  library(mlr3learners)
  library(SuperLearner)
  library(ranger)
  library(xgboost)
  library(glmnet)
  library(cobalt)
  library(WeightIt)
  library(sensemakr)
  library(ggplot2)
  library(patchwork)
  library(scales)
  library(viridis)
  library(modelsummary)
  library(kableExtra)
  library(gt)
  library(future)
  library(furrr)
})

# Set global options
options(
  scipen = 999,
  digits = 4,
  dplyr.summarise.inform = FALSE
)

# Set ggplot theme
theme_set(
  theme_minimal(base_size = 11) +
    theme(
      panel.grid.minor = element_blank(),
      plot.title = element_text(face = "bold"),
      plot.subtitle = element_text(color = "gray40"),
      legend.position = "bottom"
    )
)

# Color palette
pal_main <- c("#2171B5", "#CB181D", "#238B45", "#6A51A3", "#D94801")

# Set seed for reproducibility
set.seed(20260130)

# Enable parallel processing
plan(multisession, workers = parallel::detectCores() - 1)

message("Packages loaded successfully")
message(paste("R version:", R.version.string))
message(paste("Working directory:", getwd()))
