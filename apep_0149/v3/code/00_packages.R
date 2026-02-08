##############################################################################
# 00_packages.R - Load libraries and set global options
# Revision of apep_0153: Medicaid Postpartum Coverage Extensions (v3)
##############################################################################

# Core packages
library(tidyverse)
library(fixest)
library(did)
library(data.table)
library(httr)
library(jsonlite)

# Inference and robustness
library(sandwich)
library(lmtest)

# HonestDiD for Rambachan-Roth sensitivity
if (!requireNamespace("HonestDiD", quietly = TRUE)) {
  install.packages("HonestDiD", repos = "https://cloud.r-project.org")
}
library(HonestDiD)

# Figures
library(ggplot2)
library(scales)
library(patchwork)

# Set global options
options(scipen = 999)
theme_set(theme_minimal(base_size = 12))

# APEP figure theme
theme_apep <- function(base_size = 12) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", size = base_size + 2),
      plot.subtitle = element_text(color = "gray40", size = base_size),
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      axis.title = element_text(face = "bold"),
      legend.position = "bottom",
      plot.caption = element_text(color = "gray50", hjust = 0),
      strip.text = element_text(face = "bold")
    )
}

# Paths
data_dir <- file.path(dirname(getwd()), "data")
fig_dir <- file.path(dirname(getwd()), "figures")
tab_dir <- file.path(dirname(getwd()), "tables")

# Create dirs if needed
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(fig_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

cat("Packages loaded. Directories set.\n")
cat("Data:", data_dir, "\n")
cat("Figures:", fig_dir, "\n")
cat("Tables:", tab_dir, "\n")
