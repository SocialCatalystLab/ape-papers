# 00_packages.R — Load libraries and set themes
# Paper 113: RPS and Electricity Sector Employment

# Core packages
library(tidyverse)
library(fixest)
library(did)
library(bacondecomp)
library(HonestDiD)
# fwildclusterboot not available for this R version; skip wild bootstrap
# library(fwildclusterboot)
library(ggplot2)

# Set ggplot theme for journal-quality figures
theme_paper <- theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    strip.text = element_text(face = "bold"),
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 10, color = "gray40"),
    legend.position = "bottom",
    axis.title = element_text(size = 11),
    plot.caption = element_text(size = 8, color = "gray50", hjust = 0)
  )

theme_set(theme_paper)

# Color palette
pal <- c("#1b9e77", "#d95f02", "#7570b3", "#e7298a")

cat("Packages loaded successfully.\n")
