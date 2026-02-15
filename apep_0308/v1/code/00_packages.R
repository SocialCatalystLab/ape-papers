## ============================================================================
## 00_packages.R — Load libraries and set paths
## apep_0296: Geography of Medicaid's Invisible Workforce (NY State)
## ============================================================================

# Core data manipulation
library(data.table)
library(arrow)
library(dplyr)
library(tidyr)
library(stringr)

# Spatial/mapping
library(sf)
library(ggplot2)
library(scales)
library(viridis)

# Tables
library(xtable)

# Set paths
CODE <- tryCatch(
  normalizePath(dirname(sys.frame(1)$ofile), mustWork = FALSE),
  error = function(e) getwd()
)
ROOT <- dirname(CODE)
DATA <- file.path(ROOT, "data")
FIG  <- file.path(ROOT, "figures")
TAB  <- file.path(ROOT, "tables")

dir.create(FIG, showWarnings = FALSE, recursive = TRUE)
dir.create(TAB, showWarnings = FALSE, recursive = TRUE)

# Global theme
theme_set(
  theme_minimal(base_size = 11) +
    theme(
      panel.grid.minor = element_blank(),
      plot.title = element_text(face = "bold", size = 12),
      plot.subtitle = element_text(size = 10, color = "gray40"),
      legend.position = "bottom"
    )
)

cat("Paths set:\n")
cat("  ROOT:", ROOT, "\n")
cat("  DATA:", DATA, "\n")
cat("  FIG: ", FIG, "\n")
cat("  TAB: ", TAB, "\n")
