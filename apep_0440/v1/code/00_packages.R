###############################################################################
# 00_packages.R — Load required packages and set global options
# Paper: Social Insurance Thresholds and Late-Career Underemployment
# APEP-0440
###############################################################################

# --- CRAN packages ---
required_pkgs <- c(
  "tidycensus",    # ACS PUMS microdata access
  "tidyverse",     # Data manipulation and visualization
  "data.table",    # Memory-efficient large data operations
  "fixest",        # Fast fixed effects estimation
  "rdrobust",      # RDD estimation (Cattaneo et al.)
  "rddensity",     # McCrary-type density tests
  "modelsummary",  # Regression tables
  "kableExtra",    # LaTeX table formatting
  "ggthemes",      # Clean plot themes
  "patchwork",     # Combine ggplots
  "haven",         # Read/write data formats
  "arrow",         # Parquet I/O for memory efficiency
  "readxl",        # Read O*NET Excel files
  "httr",          # HTTP requests for O*NET download
  "scales"         # Axis formatting
)

for (pkg in required_pkgs) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
  library(pkg, character.only = TRUE)
}

# --- Global options ---
options(
  scipen = 999,            # Avoid scientific notation
  tidycensus.show_progress = FALSE,
  timeout = 600            # 10-minute download timeout
)

# --- Census API key ---
env_file <- file.path(dirname(dirname(getwd())), "..", "..", ".env")
if (file.exists(env_file)) {
  env_lines <- readLines(env_file, warn = FALSE)
  for (line in env_lines) {
    if (grepl("^CENSUS_API_KEY=", line)) {
      key <- sub("^CENSUS_API_KEY=", "", line)
      census_api_key(key, install = FALSE)
    }
  }
}

# --- ggplot2 theme ---
theme_apep <- theme_minimal(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(size = 11, color = "gray30"),
    legend.position = "bottom",
    strip.text = element_text(face = "bold")
  )
theme_set(theme_apep)

cat("Packages loaded successfully.\n")
cat("Hardware constraints: 8GB RAM, 8 cores\n")
cat("Strategy: Process ACS PUMS in chunks, filter early, use data.table\n")
