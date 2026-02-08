## ============================================================================
## 00_packages.R — Package Management & Theme Setup
## Paper 184: Revision of apep_0128 (Dutch Nitrogen Crisis & Housing)
## Sub-national DiD with Natura 2000 proximity
## ============================================================================

cat("=== 00_packages.R: Loading packages ===\n")

options(
  scipen = 999,
  digits = 4,
  dplyr.summarise.inform = FALSE,
  timeout = 300
)

required_cran <- c(
  "tidyverse", "data.table", "lubridate", "jsonlite", "httr",
  "cbsodataR",
  "sf",
  "fixest", "sandwich", "lmtest", "rdrobust",
  "ggplot2", "patchwork", "scales", "viridis",
  "modelsummary", "kableExtra",
  "boot", "nnls"
)

for (pkg in required_cran) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org", quiet = TRUE)
  }
  suppressPackageStartupMessages(library(pkg, character.only = TRUE))
}

## augsynth for Augmented SCM / SDID
if (!requireNamespace("augsynth", quietly = TRUE)) {
  if (!requireNamespace("remotes", quietly = TRUE))
    install.packages("remotes", repos = "https://cloud.r-project.org", quiet = TRUE)
  remotes::install_github("ebenmichael/augsynth", quiet = TRUE)
}
suppressPackageStartupMessages(library(augsynth))

## Publication theme
theme_pub <- function(base_size = 12) {
  theme_minimal(base_size = base_size) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "gray90", linewidth = 0.25),
      axis.line = element_line(color = "black", linewidth = 0.3),
      axis.ticks = element_line(color = "black", linewidth = 0.3),
      legend.position = "bottom",
      legend.key.width = unit(1.5, "cm"),
      plot.title = element_text(face = "bold", hjust = 0),
      plot.subtitle = element_text(size = 10, color = "gray40"),
      strip.text = element_text(face = "bold"),
      panel.border = element_rect(color = "black", fill = NA, linewidth = 0.5),
      plot.caption = element_text(size = 8, color = "gray50", hjust = 0)
    )
}
theme_set(theme_pub())

cols <- list(
  treated = "#D62728",
  control = "#1F77B4",
  medium  = "#FF7F0E",
  gray    = "gray60",
  light   = "gray85",
  ci      = "gray80",
  accent  = "#2CA02C"
)

dir.create("figures", showWarnings = FALSE)
dir.create("tables", showWarnings = FALSE)
dir.create("data", showWarnings = FALSE)

cat("=== Packages loaded successfully ===\n")
