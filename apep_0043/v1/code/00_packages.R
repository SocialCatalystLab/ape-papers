# =============================================================================
# 00_packages.R - Package Installation and Loading
# Paper 59: State Insulin Price Caps and Diabetes Management Outcomes
# =============================================================================

# Install packages if needed
packages <- c(
  # DiD packages
  "did", "fixest", "did2s", "bacondecomp",
  # Data manipulation
  "tidyverse", "data.table", "haven", "httr", "jsonlite",
  # Visualization
  "ggplot2", "ggthemes", "latex2exp", "scales", "patchwork",
  # Mapping

  "sf", "tigris",
  # Inference
  "sandwich", "lmtest", "clubSandwich",
  # Tables
  "modelsummary", "kableExtra"
)

install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
}

invisible(lapply(packages, install_if_missing))

# Load packages
library(did)
library(fixest)
library(did2s)
library(tidyverse)
library(data.table)
library(haven)
library(httr)
library(jsonlite)
library(ggplot2)
library(scales)
library(patchwork)
library(sf)
library(tigris)
library(sandwich)
library(lmtest)
library(modelsummary)

# =============================================================================
# APEP Standard Theme
# =============================================================================

theme_apep <- function(base_size = 12) {
  theme_minimal(base_size = base_size) +
    theme(
      # Clean background
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "grey90", linewidth = 0.3),

      # Clear axis lines
      axis.line = element_line(color = "grey30", linewidth = 0.4),
      axis.ticks = element_line(color = "grey30", linewidth = 0.3),

      # Readable text
      axis.title = element_text(size = 11, face = "bold"),
      axis.text = element_text(size = 10, color = "grey30"),

      # Legend
      legend.position = "bottom",
      legend.title = element_text(size = 10, face = "bold"),
      legend.text = element_text(size = 9),

      # Title
      plot.title = element_text(size = 13, face = "bold", hjust = 0),
      plot.subtitle = element_text(size = 10, color = "grey40", hjust = 0),
      plot.caption = element_text(size = 8, color = "grey50", hjust = 1),

      # Margins
      plot.margin = margin(10, 15, 10, 10)
    )
}

# Color palette (colorblind-safe)
apep_colors <- c(
  "#0072B2",  # Blue (treated)
  "#D55E00",  # Orange (control)
  "#009E73",  # Green (third group)
  "#CC79A7",  # Pink (fourth group)
  "#F0E442",  # Yellow (fifth group)
  "#56B4E9"   # Light blue (sixth group)
)

# =============================================================================
# Utility Functions
# =============================================================================

# State FIPS codes lookup
state_fips <- data.frame(
  state_name = c("Alabama", "Alaska", "Arizona", "Arkansas", "California",
                 "Colorado", "Connecticut", "Delaware", "Florida", "Georgia",
                 "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa",
                 "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland",
                 "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri",
                 "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey",
                 "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio",
                 "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina",
                 "South Dakota", "Tennessee", "Texas", "Utah", "Vermont",
                 "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming",
                 "District of Columbia"),
  state_abbr = c("AL", "AK", "AZ", "AR", "CA",
                 "CO", "CT", "DE", "FL", "GA",
                 "HI", "ID", "IL", "IN", "IA",
                 "KS", "KY", "LA", "ME", "MD",
                 "MA", "MI", "MN", "MS", "MO",
                 "MT", "NE", "NV", "NH", "NJ",
                 "NM", "NY", "NC", "ND", "OH",
                 "OK", "OR", "PA", "RI", "SC",
                 "SD", "TN", "TX", "UT", "VT",
                 "VA", "WA", "WV", "WI", "WY",
                 "DC"),
  fips = c(1, 2, 4, 5, 6,
           8, 9, 10, 12, 13,
           15, 16, 17, 18, 19,
           20, 21, 22, 23, 24,
           25, 26, 27, 28, 29,
           30, 31, 32, 33, 34,
           35, 36, 37, 38, 39,
           40, 41, 42, 44, 45,
           46, 47, 48, 49, 50,
           51, 53, 54, 55, 56,
           11)
)

# =============================================================================
# Treatment Assignment: State Insulin Price Cap Laws
# =============================================================================

# Treatment cohorts based on effective dates of state insulin price cap laws
# Sources: ADA, NCSL, state legislation
insulin_cap_laws <- data.frame(
  state_abbr = c("CO", "IL", "NM", "NY", "ME", "UT", "WA", "TX",
                 "CT", "DE", "NH", "WV", "CA", "KY", "LA", "NV",
                 "OK", "VT"),
  treatment_year = c(2020, 2020, 2020, 2020, 2020, 2020, 2021, 2021,
                     2022, 2022, 2022, 2022, 2023, 2023, 2023, 2023,
                     2023, 2023),
  cap_amount = c(100, 100, 25, 100, 35, 30, 100, 25,
                 25, 100, 30, 35, 35, 35, 35, 35,
                 35, 35)
) %>%
  left_join(state_fips, by = "state_abbr")

cat("State insulin price cap laws loaded:\n")
print(insulin_cap_laws %>% arrange(treatment_year))

cat("\n\nPackages loaded and APEP theme defined.\n")
