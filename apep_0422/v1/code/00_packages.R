## ============================================================================
## 00_packages.R — Load libraries and set themes
## Paper: Can Clean Cooking Save Lives? (apep_0422)
## ============================================================================

# ── Core packages ─────────────────────────────────────────────────────────────
library(tidyverse)
library(data.table)
library(fixest)
library(sandwich)
library(lmtest)

# ── Tables and figures ────────────────────────────────────────────────────────
library(ggplot2)
library(latex2exp)
library(scales)
library(cowplot)

# ── APEP standard theme ──────────────────────────────────────────────────────
theme_apep <- function() {
  theme_minimal(base_size = 12) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "grey90", linewidth = 0.3),
      axis.line = element_line(color = "grey30", linewidth = 0.4),
      axis.ticks = element_line(color = "grey30", linewidth = 0.3),
      axis.title = element_text(size = 11, face = "bold"),
      axis.text = element_text(size = 10, color = "grey30"),
      legend.position = "bottom",
      legend.title = element_text(size = 10, face = "bold"),
      legend.text = element_text(size = 9),
      plot.title = element_text(size = 13, face = "bold", hjust = 0),
      plot.subtitle = element_text(size = 10, color = "grey40", hjust = 0),
      plot.caption = element_text(size = 8, color = "grey50", hjust = 1),
      plot.margin = margin(10, 15, 10, 10)
    )
}

apep_colors <- c(
  "#0072B2",  # Blue (treated/high exposure)
  "#D55E00",  # Orange (control/low exposure)
  "#009E73",  # Green
  "#CC79A7",  # Pink
  "#F0E442",  # Yellow
  "#56B4E9"   # Light blue
)

# ── Paths ─────────────────────────────────────────────────────────────────────
# Derive base_dir relative to this script (code/ is one level below base)
.this_script <- tryCatch(
  normalizePath(sys.frame(1)$ofile),
  error = function(e) {
    args <- commandArgs(trailingOnly = FALSE)
    file_arg <- grep("--file=", args, value = TRUE)
    if (length(file_arg) > 0) normalizePath(sub("--file=", "", file_arg[1]))
    else normalizePath("code/00_packages.R")
  }
)
base_dir <- dirname(dirname(.this_script))
data_dir  <- file.path(base_dir, "data")
fig_dir   <- file.path(base_dir, "figures")
tab_dir   <- file.path(base_dir, "tables")
code_dir  <- file.path(base_dir, "code")

dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(fig_dir,  showWarnings = FALSE, recursive = TRUE)
dir.create(tab_dir,  showWarnings = FALSE, recursive = TRUE)

cat("Packages loaded. Directories verified.\n")
