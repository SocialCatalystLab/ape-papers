## ============================================================================
## 00_packages.R — Load libraries, set constants, define theme
## apep_0341 v2: Medicaid Reimbursement Rates and HCBS Provider Supply
## ============================================================================

## ---- Core packages ----
library(arrow)         # Parquet I/O (lazy evaluation)
library(data.table)    # Fast data wrangling
library(tidyverse)     # dplyr, ggplot2, tidyr, etc.
library(fixest)        # Fast fixed effects (TWFE, Sun-Abraham)
library(did)           # Callaway-Sant'Anna staggered DiD
library(ggplot2)       # Figures
library(latex2exp)     # LaTeX in plots
library(fwildclusterboot) # Wild cluster bootstrap

## ---- Suppress summarise messages ----
options(dplyr.summarise.inform = FALSE)

## ---- Paths (project-root-relative) ----
## Detect project root from code/ directory
PROJECT_ROOT <- normalizePath(file.path(getwd(), ".."), mustWork = TRUE)
FIGURES <- file.path(PROJECT_ROOT, "figures")
TABLES  <- file.path(PROJECT_ROOT, "tables")
DATA    <- file.path(PROJECT_ROOT, "data")
dir.create(FIGURES, showWarnings = FALSE, recursive = TRUE)
dir.create(TABLES,  showWarnings = FALSE, recursive = TRUE)
dir.create(DATA,    showWarnings = FALSE, recursive = TRUE)

## ---- APEP Standard Theme ----
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
  "#0072B2",  # Blue (treated)
  "#D55E00",  # Orange (control)
  "#009E73",  # Green
  "#CC79A7",  # Pink
  "#F0E442",  # Yellow
  "#56B4E9"   # Light blue
)

## ---- Personal care HCPCS codes (treatment-relevant) ----
PC_CODES <- c("T1019", "T1020", "S5125", "S5130")

## ---- Placebo HCPCS codes (physician E/M visits) ----
PLACEBO_CODES <- c("99213", "99214")

## ---- Significance star helper ----
sig_stars <- function(p) {
  ifelse(p < 0.01, "***", ifelse(p < 0.05, "**", ifelse(p < 0.1, "*", "")))
}

cat("Packages loaded. Paths set.\n")
