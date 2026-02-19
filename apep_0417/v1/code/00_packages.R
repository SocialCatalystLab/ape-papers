## ============================================================
## 00_packages.R — Load libraries and set global options
## Paper: Where Medicaid Goes Dark (apep_0371)
## ============================================================

# Core data manipulation
library(arrow)        # Parquet I/O, lazy evaluation
library(data.table)   # Fast data ops
library(dplyr)        # Tidyverse verbs
library(tidyr)        # Pivoting
library(stringr)      # String ops
library(lubridate)    # Date handling
library(readxl)       # Excel files (USDA RUCC)

# Econometrics
library(fixest)       # Fixed effects estimation, CS-DiD
library(did)          # Callaway & Sant'Anna (2021)
library(modelsummary) # Regression tables
library(sandwich)     # Robust SEs

# Graphics
library(ggplot2)      # Core plotting
library(sf)           # Spatial data
library(patchwork)    # Combine plots
library(scales)       # Formatting
library(viridis)      # Color scales
library(RColorBrewer) # Additional palettes

# Tables
library(kableExtra)   # LaTeX tables

# Set global theme
theme_set(theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold", size = 12),
    plot.subtitle = element_text(size = 10, color = "gray40"),
    legend.position = "bottom"
  ))

# Paths — detect root from working directory or script location
get_root <- function() {
  # Try commandArgs approach (Rscript)
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  if (length(file_arg) > 0) {
    script_dir <- dirname(normalizePath(sub("^--file=", "", file_arg[1])))
    return(normalizePath(file.path(script_dir, ".."), mustWork = TRUE))
  }
  # Fall back to working directory
  if (basename(getwd()) == "code") {
    return(normalizePath("..", mustWork = TRUE))
  }
  return(normalizePath(".", mustWork = TRUE))
}
ROOT <- get_root()
DATA_DIR <- file.path(ROOT, "data")
FIG_DIR  <- file.path(ROOT, "figures")
TAB_DIR  <- file.path(ROOT, "tables")
CODE_DIR <- file.path(ROOT, "code")

# Shared Medicaid data — resolve from repo root
# ROOT = v1/, so repo root is 3 levels up: v1 → apep_0371 → output → repo
REPO_ROOT <- normalizePath(file.path(ROOT, "../../.."), mustWork = TRUE)
TMSIS_PATH <- file.path(REPO_ROOT, "data/medicaid_provider_spending/tmsis.parquet")
NPPES_PATH <- file.path(REPO_ROOT, "data/medicaid_provider_spending/nppes_extract.parquet")

stopifnot("T-MSIS parquet not found" = file.exists(TMSIS_PATH))
stopifnot("NPPES parquet not found" = file.exists(NPPES_PATH))

dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(TAB_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(DATA_DIR, showWarnings = FALSE, recursive = TRUE)

cat("Packages loaded. Data paths verified.\n")
cat("  T-MSIS:", TMSIS_PATH, "\n")
cat("  NPPES:", NPPES_PATH, "\n")
