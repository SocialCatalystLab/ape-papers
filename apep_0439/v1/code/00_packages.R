###############################################################################
# 00_packages.R - Load libraries and set themes
# Paper: Where Cultural Borders Cross (apep_0439)
###############################################################################

# --- Core packages ---
library(tidyverse)
library(fixest)
library(sf)

# --- Swiss data access ---
library(swissdd)
library(BFS)

# --- RDD packages ---
library(rdrobust)

# --- Additional ---
library(modelsummary)
library(kableExtra)
library(scales)
library(patchwork)

# --- Install if needed ---
for (pkg in c("tidyverse", "fixest", "sf", "swissdd", "BFS",
              "rdrobust", "modelsummary", "kableExtra", "scales", "patchwork")) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
}

# --- APEP theme ---
theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title = element_text(face = "bold", size = base_size + 2),
      plot.subtitle = element_text(color = "grey40", size = base_size),
      plot.caption = element_text(color = "grey50", size = base_size - 2, hjust = 0),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "grey90"),
      axis.title = element_text(size = base_size),
      legend.position = "bottom",
      strip.text = element_text(face = "bold")
    )
}

theme_set(theme_apep())

# --- Color palettes ---
# Language: French = blue, German = red
lang_colors <- c("French" = "#2166AC", "German" = "#B2182B")

# Religion: Protestant = orange, Catholic = purple
relig_colors <- c("Protestant" = "#E66101", "Catholic" = "#5E3C99")

# 2x2 interaction palette
interaction_colors <- c(
  "French-Protestant" = "#2166AC",
  "French-Catholic"   = "#762A83",
  "German-Protestant" = "#E66101",
  "German-Catholic"   = "#B2182B"
)

# --- Paths ---
data_dir <- "data"
fig_dir <- "figures"
tab_dir <- "tables"

dir.create(data_dir, showWarnings = FALSE)
dir.create(fig_dir, showWarnings = FALSE)
dir.create(tab_dir, showWarnings = FALSE)

cat("Packages loaded. Theme set. Ready.\n")
