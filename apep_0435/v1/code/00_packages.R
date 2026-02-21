## ============================================================
## 00_packages.R — Install and load required packages
## apep_0435: Convergence of Gender Attitudes in Swiss Municipalities
## ============================================================

# CRAN packages
pkgs <- c(
  "tidyverse",      # data wrangling + ggplot2
  "fixest",         # fast fixed effects
  "sandwich",       # robust standard errors
  "lmtest",         # coefficient testing
  "modelsummary",   # publication-quality tables
  "kableExtra",     # LaTeX tables
  "xtable",         # LaTeX tables
  "jsonlite",       # JSON parsing for BFS API
  "httr",           # HTTP requests
  "scales",         # axis formatting
  "broom",          # tidy model output
  "did",            # Callaway-Sant'Anna DiD
  "DRDID",          # Doubly Robust DiD
  "WeightIt",       # propensity score weighting
  "cobalt",         # balance checking
  "ggridges",       # ridge plots
  "patchwork",      # combine plots
  "sf"              # spatial data
)

for (p in pkgs) {
  if (!requireNamespace(p, quietly = TRUE)) {
    install.packages(p, repos = "https://cloud.r-project.org", quiet = TRUE)
  }
}

# swissdd: Swiss referendum data (CRAN or GitHub)
if (!requireNamespace("swissdd", quietly = TRUE)) {
  if (!requireNamespace("remotes", quietly = TRUE)) {
    install.packages("remotes", repos = "https://cloud.r-project.org", quiet = TRUE)
  }
  tryCatch(
    install.packages("swissdd", repos = "https://cloud.r-project.org", quiet = TRUE),
    error = function(e) {
      message("CRAN install failed, trying GitHub...")
      remotes::install_github("politanch/swissdd", quiet = TRUE)
    }
  )
}

# BFS: Swiss Federal Statistics
if (!requireNamespace("BFS", quietly = TRUE)) {
  install.packages("BFS", repos = "https://cloud.r-project.org", quiet = TRUE)
}

# Load all
suppressPackageStartupMessages({
  library(tidyverse)
  library(fixest)
  library(sandwich)
  library(lmtest)
  library(modelsummary)
  library(kableExtra)
  library(jsonlite)
  library(httr)
  library(scales)
  library(broom)
  library(WeightIt)
  library(cobalt)
  library(patchwork)
})

# ggplot theme
theme_set(
  theme_minimal(base_size = 11) +
    theme(
      panel.grid.minor = element_blank(),
      plot.title = element_text(face = "bold", size = 12),
      strip.text = element_text(face = "bold"),
      legend.position = "bottom"
    )
)

cat("All packages loaded successfully.\n")
