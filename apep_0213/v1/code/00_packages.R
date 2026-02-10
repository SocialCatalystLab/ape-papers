## =============================================================================
## 00_packages.R — Load and install required packages
## Anti-Cyberbullying Laws and Youth Mental Health
## =============================================================================

required_packages <- c(
  # Data wrangling
  "tidyverse", "jsonlite", "httr",
  # Econometrics
  "fixest", "did", "bacondecomp",
  # Inference
  "sandwich", "lmtest", "clubSandwich",
  # Figures and tables
  "ggplot2", "latex2exp", "patchwork", "scales",
  # Maps
  "sf", "tigris"
)

for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org", quiet = TRUE)
  }
  library(pkg, character.only = TRUE)
}

# Suppress scientific notation
options(scipen = 999)

# Set random seed for reproducibility
set.seed(20260210)

cat("All packages loaded successfully.\n")
