# ==============================================================================
# Paper 112: State Data Privacy Laws and Technology Sector Business Formation
# 00_packages.R - Load required packages and set options
# ==============================================================================

# Package installation (run once if needed)
# install.packages(c("tidyverse", "did", "fixest", "modelsummary", "fredr",
#                    "lubridate", "scales", "patchwork", "Synth", "kableExtra"))

# Core packages
library(tidyverse)
library(lubridate)

# Econometrics
library(did)          # Callaway-Sant'Anna DiD
library(fixest)       # Fast fixed effects
library(Synth)        # Synthetic control method

# Output
library(modelsummary) # Tables
library(kableExtra)   # Table formatting
library(scales)       # Formatting

# Graphics settings
theme_set(theme_minimal(base_size = 12) +
            theme(
              panel.grid.minor = element_blank(),
              legend.position = "bottom",
              plot.title = element_text(face = "bold"),
              axis.title = element_text(size = 11)
            ))

# Color palette for treatment status
colors_treatment <- c("Never Treated" = "#377eb8",
                      "Treated" = "#e41a1c",
                      "Pre-Treatment" = "#4daf4a",
                      "Post-Treatment" = "#984ea3")

# Options
options(scipen = 999)  # Avoid scientific notation
options(digits = 3)

# FRED API key (should be set in environment)
fred_api_key <- Sys.getenv("FRED_API_KEY")
if (nchar(fred_api_key) > 0) {
  fredr::fredr_set_key(fred_api_key)
  message("FRED API key loaded successfully")
} else {
  warning("FRED API key not found in environment")
}

# Output directories
dir_data <- "../data"
dir_figures <- "../figures"
dir_tables <- "../tables"

# Create if they don't exist
dir.create(dir_data, showWarnings = FALSE)
dir.create(dir_figures, showWarnings = FALSE)
dir.create(dir_tables, showWarnings = FALSE)

message("Packages loaded. Ready for analysis.")
