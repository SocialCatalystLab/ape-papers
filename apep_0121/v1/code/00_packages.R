# ==============================================================================
# 00_packages.R
# State Minimum Wage Increases and Young Adult Household Formation
# Purpose: Load required packages, set global options, define paths and theme
# ==============================================================================

# --- Install packages if missing ---
required_packages <- c(
  "tidyverse",
  "fixest",
  "did",
  "DRDID",
  "HonestDiD",
  "ggplot2",
  "latex2exp",
  "jsonlite",
  "readxl",
  "sandwich",
  "lmtest",
  "clubSandwich",
  "bacondecomp",
  "data.table",
  "scales",
  "patchwork",
  "httr"
)

for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
}

# --- Load libraries ---
library(tidyverse)
library(fixest)
library(did)
library(DRDID)
library(HonestDiD)
library(ggplot2)
library(latex2exp)
library(jsonlite)
library(readxl)
library(sandwich)
library(lmtest)
library(clubSandwich)
library(bacondecomp)
library(data.table)
library(scales)
library(patchwork)
library(httr)

# --- Global options ---
options(scipen = 999)                          # Disable scientific notation
options(dplyr.summarise.inform = FALSE)        # Suppress grouping messages
set.seed(20240101)                             # Reproducibility

# ==============================================================================
# Directory paths
# ==============================================================================

# Detect project root: scripts run from the paper dir via Rscript code/XX.R
# or from the code/ subdirectory via source("00_packages.R")
if (file.exists(file.path(getwd(), "code", "00_packages.R"))) {
  # Running from the paper directory
  PAPER_DIR <- getwd()
} else if (file.exists(file.path(dirname(getwd()), "code", "00_packages.R"))) {
  # Running from the code subdirectory
  PAPER_DIR <- dirname(getwd())
} else {
  # Absolute fallback — use here::here() for portability
  PAPER_DIR <- here::here()
}

DATA_DIR <- file.path(PAPER_DIR, "data")
FIG_DIR  <- file.path(PAPER_DIR, "figures")
TAB_DIR  <- file.path(PAPER_DIR, "tables")

# Create directories if they don't exist
dir.create(DATA_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(FIG_DIR,  recursive = TRUE, showWarnings = FALSE)
dir.create(TAB_DIR,  recursive = TRUE, showWarnings = FALSE)

cat("DATA_DIR:", DATA_DIR, "\n")
cat("FIG_DIR: ", FIG_DIR,  "\n")
cat("TAB_DIR: ", TAB_DIR,  "\n")

# ==============================================================================
# APEP standard ggplot theme
# ==============================================================================

theme_apep <- function() {
  theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "grey90", linewidth = 0.3),
    axis.line        = element_line(color = "grey30", linewidth = 0.4),
    axis.ticks       = element_line(color = "grey30", linewidth = 0.3),
    axis.title       = element_text(size = 11, face = "bold"),
    axis.text        = element_text(size = 10, color = "grey30"),
    legend.position  = "bottom",
    legend.title     = element_text(size = 10, face = "bold"),
    legend.text      = element_text(size = 9),
    plot.title       = element_text(size = 13, face = "bold", hjust = 0),
    plot.subtitle    = element_text(size = 10, color = "grey40", hjust = 0),
    plot.caption     = element_text(size = 8, color = "grey50", hjust = 1),
    plot.margin      = margin(10, 15, 10, 10)
  )
}

apep_colors <- c("#0072B2", "#D55E00", "#009E73", "#CC79A7", "#F0E442", "#56B4E9")

# Set APEP theme as default
theme_set(theme_apep())

cat("All packages loaded. Paths and theme configured.\n")
