# ============================================================
# 00_packages.R - Load Required Packages
# ERPO Laws and Firearm Suicide Analysis
# ============================================================

# Package installation (run once if needed)
# install.packages(c("did", "fixest", "modelsummary", "ggplot2",
#                    "dplyr", "tidyr", "readr", "httr", "jsonlite"))

# Load packages
library(did)          # Callaway-Sant'Anna DiD
library(fixest)       # Fixed effects / TWFE
library(modelsummary) # Tables
library(ggplot2)      # Figures
library(dplyr)        # Data manipulation
library(tidyr)        # Data reshaping
library(readr)        # CSV I/O
library(httr)         # HTTP requests
library(jsonlite)     # JSON parsing

# Set APEP ggplot theme
theme_apep <- function() {
  theme_minimal(base_size = 12) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      axis.line = element_line(color = "black", linewidth = 0.3),
      axis.ticks = element_line(color = "black", linewidth = 0.3),
      legend.position = "bottom",
      plot.title = element_text(face = "bold", hjust = 0),
      plot.subtitle = element_text(color = "gray40"),
      plot.caption = element_text(color = "gray40", hjust = 0)
    )
}

theme_set(theme_apep())

# Color palette
apep_colors <- c(
  "treated" = "#E41A1C",
  "control" = "#377EB8",
  "point" = "#4DAF4A",
  "ci" = "gray70"
)

cat("Packages loaded successfully\n")
cat("Using did package version:", as.character(packageVersion("did")), "\n")
