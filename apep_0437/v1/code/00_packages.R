# ============================================================================
# 00_packages.R — Load required packages and set global options
# Multi-Level Political Alignment and Local Development in India
# ============================================================================

# ── Install missing packages ──────────────────────────────────────────────
pkgs <- c("data.table", "fixest", "rdrobust", "rddensity", "ggplot2",
          "dplyr", "tidyr", "stringr", "broom", "modelsummary",
          "kableExtra", "scales", "patchwork", "sandwich", "lmtest")

for (p in pkgs) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p, repos = "https://cloud.r-project.org")
  }
}

# ── Load libraries ────────────────────────────────────────────────────────
library(data.table)
library(fixest)
library(rdrobust)
library(rddensity)
library(ggplot2)
library(dplyr)
library(tidyr)
library(stringr)
library(scales)
library(patchwork)

# ── Global options ────────────────────────────────────────────────────────
options(scipen = 999)
theme_set(
  theme_minimal(base_size = 11) +
    theme(
      panel.grid.minor = element_blank(),
      strip.text = element_text(face = "bold"),
      plot.title = element_text(face = "bold", size = 12),
      plot.subtitle = element_text(color = "grey40"),
      legend.position = "bottom"
    )
)

cat("All packages loaded successfully.\n")
