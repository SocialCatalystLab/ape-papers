# 00_packages.R
# Install and load required packages for Promise program analysis

# Required packages
required_packages <- c(
  # Data manipulation
  "tidyverse",
  "data.table",
  "haven",

  # Econometrics
  "fixest",
  "did",
  "HonestDiD",

  # Data access
  "httr",
  "jsonlite",

  # Tables and figures
  "ggplot2",
  "kableExtra",
  "modelsummary",
  "patchwork"
)

# Install missing packages
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org/")
  }
}
invisible(lapply(required_packages, install_if_missing))

# Load packages
library(tidyverse)
library(data.table)
library(fixest)
library(did)
library(httr)
library(jsonlite)
library(ggplot2)
library(kableExtra)
library(modelsummary)
library(patchwork)

# Try to load HonestDiD
if (requireNamespace("HonestDiD", quietly = TRUE)) {
  library(HonestDiD)
} else {
  message("HonestDiD not available - install with: remotes::install_github('asheshrambachan/HonestDiD')")
}

# Set ggplot theme for APEP papers
theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      axis.line = element_line(color = "black", linewidth = 0.3),
      axis.ticks = element_line(color = "black", linewidth = 0.3),
      legend.position = "bottom",
      legend.title = element_blank(),
      plot.title = element_text(face = "bold", size = rel(1.1)),
      plot.subtitle = element_text(color = "gray40"),
      strip.text = element_text(face = "bold")
    )
}
theme_set(theme_apep())

# Output directory
if (!dir.exists("../figures")) dir.create("../figures")
if (!dir.exists("../tables")) dir.create("../tables")
if (!dir.exists("../data")) dir.create("../data")

message("Packages loaded successfully")
