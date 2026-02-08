# ==============================================================================
# 00_packages.R
# Load required packages and set global options
# Paper 154: The Insurance Value of Secondary Employment
# ==============================================================================

# Package installation check
required_packages <- c(
  # Data manipulation
  "tidyverse",
  "data.table",
  "haven",
  "janitor",

  # Causal inference
  "AIPW",
  "SuperLearner",
  "WeightIt",
  "cobalt",

  # Machine learning backends
  "ranger",
  "xgboost",
  "glmnet",

  # Sensitivity analysis
  "EValue",
  "sensemakr",

  # Quantile regression and robust SEs
  "quantreg",
  "sandwich",

  # Panel data and fixed effects
  "fixest",
  "plm",

  # Tables and visualization
  "modelsummary",
  "kableExtra",
  "ggplot2",
  "patchwork",
  "scales",
  "viridis"
)

# Optional packages (may have installation issues)
optional_packages <- c("DoubleML", "mlr3", "mlr3learners", "ipumsr")

# Install missing packages
install_if_missing <- function(pkg) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
    library(pkg, character.only = TRUE)
  }
}

invisible(sapply(required_packages, install_if_missing))

# Try to install optional packages but don't fail if they're unavailable
for (pkg in optional_packages) {
  tryCatch({
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      install.packages(pkg, repos = "https://cloud.r-project.org", quiet = TRUE)
      library(pkg, character.only = TRUE)
    }
  }, error = function(e) {
    message("Optional package ", pkg, " not available: ", e$message)
  })
}

# Global options
options(
  scipen = 999,
  digits = 4,
  dplyr.summarise.inform = FALSE,
  readr.show_col_types = FALSE
)

# ggplot2 theme
theme_paper <- theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    panel.border = element_rect(color = "gray80", fill = NA),
    strip.background = element_rect(fill = "gray95", color = "gray80"),
    legend.position = "bottom",
    plot.title = element_text(face = "bold", size = 12),
    plot.subtitle = element_text(color = "gray40"),
    axis.title = element_text(size = 10)
  )

theme_set(theme_paper)

# Color palette
colors_paper <- c(
  "primary" = "#2C3E50",
  "secondary" = "#E74C3C",
  "tertiary" = "#3498DB",
  "quaternary" = "#27AE60",
  "light" = "#BDC3C7"
)

# Output directory - use relative path from code/ subdirectory
output_dir <- ".."
figure_dir <- file.path(output_dir, "figures")
table_dir <- file.path(output_dir, "tables")
data_dir <- file.path(output_dir, "data")

# Create directories if they don't exist
dir.create(figure_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(table_dir, showWarnings = FALSE, recursive = TRUE)
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

cat("Packages loaded successfully.\n")
cat("Output directory:", output_dir, "\n")
