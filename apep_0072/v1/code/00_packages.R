# ==============================================================================
# 00_packages.R
# Paper 96: Telehealth Parity Laws and Mental Health Treatment Utilization
# Description: Load required packages and set analysis themes
# ==============================================================================

# --- Package Installation Check -----------------------------------------------

required_packages <- c(
  # Data manipulation
  "tidyverse",
  "data.table",
  "haven",
  "readxl",

  # Econometrics - DiD
  "did",           # Callaway-Sant'Anna
  "fixest",        # TWFE and event studies
  "did2s",         # Gardner (2021) estimator
  "HonestDiD",     # Sensitivity analysis

  # Tables and output
  "modelsummary",
  "kableExtra",
  "gt",

  # Visualization
  "ggplot2",
  "patchwork",
  "scales",
  "ggthemes",

  # API access
  "httr",
  "jsonlite"
)

# Install missing packages
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    message(paste("Installing:", pkg))
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
}

invisible(sapply(required_packages, install_if_missing))

# --- Load Packages ------------------------------------------------------------

suppressPackageStartupMessages({
  library(tidyverse)
  library(data.table)
  library(haven)
  library(readxl)
  library(did)
  library(fixest)
  library(modelsummary)
  library(kableExtra)
  library(ggplot2)
  library(patchwork)
  library(scales)
  library(httr)
  library(jsonlite)
})

# --- APEP Theme ---------------------------------------------------------------

theme_apep <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      # Text elements
      plot.title = element_text(face = "bold", size = rel(1.2), hjust = 0),
      plot.subtitle = element_text(size = rel(0.9), hjust = 0, color = "grey40"),
      plot.caption = element_text(size = rel(0.7), hjust = 1, color = "grey50"),

      # Axis elements
      axis.title = element_text(size = rel(0.9)),
      axis.text = element_text(size = rel(0.8)),
      axis.line = element_line(color = "grey70", linewidth = 0.3),

      # Panel elements
      panel.grid.major = element_line(color = "grey90", linewidth = 0.2),
      panel.grid.minor = element_blank(),
      panel.background = element_rect(fill = "white", color = NA),
      plot.background = element_rect(fill = "white", color = NA),

      # Legend
      legend.position = "bottom",
      legend.title = element_text(size = rel(0.9)),
      legend.text = element_text(size = rel(0.8)),

      # Strip (facets)
      strip.text = element_text(face = "bold", size = rel(0.9)),
      strip.background = element_rect(fill = "grey95", color = NA)
    )
}

# Set as default
theme_set(theme_apep())

# --- Color Palettes -----------------------------------------------------------

apep_colors <- c(
  "treatment" = "#2E86AB",
  "control" = "#A23B72",
  "neutral" = "#6B7280",
  "highlight" = "#F18F01",
  "success" = "#28A745",
  "warning" = "#DC3545"
)

apep_palette <- c("#2E86AB", "#A23B72", "#F18F01", "#4CAF50", "#9C27B0")

# --- Output Directories -------------------------------------------------------

# Create directories if they don't exist
dirs <- c("../data", "../figures", "../tables")
invisible(sapply(dirs, function(d) if (!dir.exists(d)) dir.create(d, recursive = TRUE)))

# --- Helper Functions ---------------------------------------------------------

# Save figure in multiple formats
save_figure <- function(plot, filename, width = 8, height = 6, dpi = 300) {
  ggsave(
    filename = paste0("../figures/", filename, ".pdf"),
    plot = plot,
    width = width,
    height = height,
    device = cairo_pdf
  )
  ggsave(
    filename = paste0("../figures/", filename, ".png"),
    plot = plot,
    width = width,
    height = height,
    dpi = dpi
  )
  message(paste("Saved:", filename))
}

# Format numbers for tables
fmt_num <- function(x, digits = 2) {
  formatC(x, format = "f", digits = digits, big.mark = ",")
}

fmt_pct <- function(x, digits = 1) {
  paste0(formatC(x * 100, format = "f", digits = digits), "%")
}

# --- Session Info -------------------------------------------------------------

message("Packages loaded successfully.")
message(paste("R version:", R.version.string))
message(paste("Working directory:", getwd()))
