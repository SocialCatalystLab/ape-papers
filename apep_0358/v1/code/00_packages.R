## ============================================================================
## 00_packages.R — Load packages and set global options
## Paper: Medicaid Postpartum Coverage Extensions and Provider Supply
## ============================================================================

## ---- Core ----
library(arrow)
library(data.table)
library(dplyr)
library(ggplot2)
library(fixest)

## ---- DiD ----
library(did)          # Callaway & Sant'Anna (2021)

## ---- Optional (loaded when needed) ----
# library(HonestDiD)  # Rambachan & Roth (2023)
# library(xtable)     # LaTeX tables

## ---- ggplot theme ----
theme_set(theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    legend.position  = "bottom",
    plot.title       = element_text(face = "bold", size = 12),
    strip.text       = element_text(face = "bold")
  ))

## ---- Global options ----
options(scipen = 999)
setFixest_nthreads(4)
