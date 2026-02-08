# ==============================================================================
# 00_packages.R
# Universal School Meals and Household Food Security
# Load required packages and set global options
# ==============================================================================

# Core packages
library(tidyverse)
library(data.table)
library(haven)
library(fixest)
library(did)
# library(fwildclusterboot)  # Not available, will use boot package for wild bootstrap
library(HonestDiD)
library(ggthemes)
library(latex2exp)
library(knitr)
library(kableExtra)

# Set seed for reproducibility
set.seed(20260128)

# ggplot theme for APEP papers
theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", size = base_size * 1.2, hjust = 0),
      plot.subtitle = element_text(size = base_size, color = "gray40"),
      plot.caption = element_text(size = base_size * 0.8, color = "gray50", hjust = 0),
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      axis.title = element_text(size = base_size),
      axis.text = element_text(size = base_size * 0.9),
      legend.position = "bottom",
      legend.title = element_text(size = base_size * 0.9),
      legend.text = element_text(size = base_size * 0.85),
      strip.text = element_text(face = "bold", size = base_size)
    )
}

theme_set(theme_apep())

# Color palette
apep_colors <- c(
  "primary" = "#2C3E50",
  "secondary" = "#E74C3C",
  "tertiary" = "#3498DB",
  "quaternary" = "#27AE60",
  "gray" = "#95A5A6"
)

# Global options
options(
  dplyr.summarise.inform = FALSE,
  scipen = 999,
  digits = 3
)

# Output directories
OUTPUT_DIR <- here::here("output/paper_106")
DATA_DIR <- file.path(OUTPUT_DIR, "data")
FIG_DIR <- file.path(OUTPUT_DIR, "figures")
TAB_DIR <- file.path(OUTPUT_DIR, "tables")

# Create if not exist
dir.create(DATA_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(FIG_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(TAB_DIR, showWarnings = FALSE, recursive = TRUE)

cat("Packages loaded. Output directories ready.\n")
cat("DATA_DIR:", DATA_DIR, "\n")
cat("FIG_DIR:", FIG_DIR, "\n")
cat("TAB_DIR:", TAB_DIR, "\n")
