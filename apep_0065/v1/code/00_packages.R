# =============================================================================
# Paper 83: Social Security at 62 and Civic Engagement (Revision of apep_0081)
# 00_packages.R - Load required packages and set global options
# =============================================================================

# Core packages
library(tidyverse)
library(data.table)
library(haven)

# Econometrics - Standard RD
library(fixest)
library(rdrobust)
library(rddensity)
library(sandwich)
library(lmtest)

# Set CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org/"))

# Discrete RD Inference (Kolesar-Rothe)
# RDHonest provides honest CIs for discrete running variables
# Install: devtools::install_github("kolesarm/RDHonest")
RDHonest_available <- FALSE
tryCatch({
  if (!requireNamespace("RDHonest", quietly = TRUE)) {
    cat("Installing RDHonest package from GitHub...\n")
    if (!requireNamespace("devtools", quietly = TRUE)) install.packages("devtools")
    devtools::install_github("kolesarm/RDHonest")
  }
  library(RDHonest)
  RDHonest_available <- TRUE
}, error = function(e) {
  cat("Note: RDHonest not available. Will use alternative methods.\n")
})

# Local randomization inference for RD
# rdlocrand implements permutation-based inference
rdlocrand_available <- FALSE
tryCatch({
  if (!requireNamespace("rdlocrand", quietly = TRUE)) {
    cat("Installing rdlocrand package...\n")
    install.packages("rdlocrand")
  }
  library(rdlocrand)
  rdlocrand_available <- TRUE
}, error = function(e) {
  cat("Note: rdlocrand not available. Will use alternative methods.\n")
})

# Tables and figures
library(modelsummary)
library(kableExtra)
library(patchwork)
library(scales)

# Set options
options(
  scipen = 999,
  digits = 4,
  dplyr.summarise.inform = FALSE
)

# APEP theme for figures
theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.background = element_rect(fill = "white", color = NA),
      plot.background = element_rect(fill = "white", color = NA),
      axis.line = element_line(color = "gray30", linewidth = 0.3),
      axis.ticks = element_line(color = "gray30", linewidth = 0.3),
      plot.title = element_text(face = "bold", size = rel(1.1), hjust = 0),
      plot.subtitle = element_text(color = "gray40", size = rel(0.9), hjust = 0),
      plot.caption = element_text(color = "gray40", size = rel(0.8), hjust = 1),
      legend.position = "bottom",
      legend.title = element_text(size = rel(0.9)),
      strip.text = element_text(face = "bold", size = rel(0.9))
    )
}

theme_set(theme_apep())

# Color palette
apep_colors <- c(
  primary = "#2C3E50",
  secondary = "#E74C3C",
  tertiary = "#3498DB",
  quaternary = "#27AE60",
  light = "#BDC3C7"
)

# Paths (relative to code/ directory)
data_dir <- "../data/"
fig_dir <- "../figures/"
tab_dir <- "../tables/"

# Create directories if they don't exist
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

cat("Packages loaded successfully\n")
cat("Working directory:", getwd(), "\n")
