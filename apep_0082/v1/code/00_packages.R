## 00_packages.R — Load libraries and set global options
## Paper 110: Recreational Marijuana and Business Formation

# Core
library(tidyverse)
library(fixest)
library(did)
library(modelsummary)
library(kableExtra)
library(latex2exp)

# (fwildclusterboot not available for R 4.5; using RI + cluster-robust SEs)

# Paths
BASE_DIR   <- Sys.getenv("PAPER_DIR", unset = ".")
if (BASE_DIR == "." || !dir.exists(BASE_DIR)) {
  # Try to detect from script location
  BASE_DIR <- tryCatch(
    file.path(dirname(dirname(sys.frame(1)$ofile))),
    error = function(e) "."
  )
  if (!dir.exists(BASE_DIR)) BASE_DIR <- "."
}
DATA_DIR   <- file.path(BASE_DIR, "data")
FIG_DIR    <- file.path(BASE_DIR, "figures")
TAB_DIR    <- file.path(BASE_DIR, "tables")

dir.create(DATA_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(FIG_DIR,  showWarnings = FALSE, recursive = TRUE)
dir.create(TAB_DIR,  showWarnings = FALSE, recursive = TRUE)

# APEP standard theme
theme_apep <- function() {
  theme_minimal(base_size = 12) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "grey90", linewidth = 0.3),
      axis.line  = element_line(color = "grey30", linewidth = 0.4),
      axis.ticks = element_line(color = "grey30", linewidth = 0.3),
      axis.title = element_text(size = 11, face = "bold"),
      axis.text  = element_text(size = 10, color = "grey30"),
      legend.position = "bottom",
      legend.title = element_text(size = 10, face = "bold"),
      legend.text  = element_text(size = 9),
      plot.title    = element_text(size = 13, face = "bold", hjust = 0),
      plot.subtitle = element_text(size = 10, color = "grey40", hjust = 0),
      plot.caption  = element_text(size = 8, color = "grey50", hjust = 1),
      plot.margin   = margin(10, 15, 10, 10)
    )
}

apep_colors <- c(
  "#0072B2", "#D55E00", "#009E73", "#CC79A7", "#F0E442", "#56B4E9"
)

cat("Packages loaded. Directories set.\n")
