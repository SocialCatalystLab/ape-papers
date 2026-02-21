## ============================================================
## 00_packages.R — MGNREGA and Structural Transformation
## Install and load required R packages
## ============================================================

# -- Install missing packages --
required <- c(
  "data.table", "fixest", "did", "ggplot2", "latex2exp",
  "dplyr", "tidyr", "purrr", "readr", "stringr",
  "sandwich", "lmtest", "modelsummary", "kableExtra"
)

for (pkg in required) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
}

# -- Load libraries --
library(data.table)
library(fixest)
library(did)
library(ggplot2)
library(latex2exp)
library(dplyr)
library(tidyr)
library(readr)
library(stringr)
library(sandwich)
library(lmtest)
library(modelsummary)
library(kableExtra)

# -- APEP Standard Theme --
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
  "#0072B2",  # Blue
  "#D55E00",  # Orange
  "#009E73",  # Green
  "#CC79A7",  # Pink
  "#F0E442",  # Yellow
  "#56B4E9"   # Light blue
)

cat("Packages loaded successfully.\n")
