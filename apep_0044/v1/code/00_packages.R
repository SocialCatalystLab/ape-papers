# ==============================================================================
# 00_packages.R
# Clean Slate Laws and Employment Outcomes
# Paper 59
# ==============================================================================

# Core packages
library(tidyverse)
library(data.table)

# DiD estimation - using fixest (installed)
library(fixest)     # Sun-Abraham via sunab(), fast TWFE

# Inference
library(sandwich)
library(lmtest)

# Visualization
library(ggplot2)
library(scales)
library(patchwork)

# Set random seed for reproducibility
set.seed(20260121)

# ==============================================================================
# APEP Standard Theme
# ==============================================================================

theme_apep <- function() {
  theme_minimal(base_size = 12) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "grey90", linewidth = 0.3),
      axis.line = element_line(color = "grey30", linewidth = 0.4),
      axis.ticks = element_line(color = "grey30", linewidth = 0.3),
      axis.title = element_text(size = 11, face = "bold"),
      axis.text = element_text(size = 10, color = "grey30"),
      legend.position = "bottom",
      legend.title = element_text(size = 10, face = "bold"),
      legend.text = element_text(size = 9),
      plot.title = element_text(size = 13, face = "bold", hjust = 0),
      plot.subtitle = element_text(size = 10, color = "grey40", hjust = 0),
      plot.caption = element_text(size = 8, color = "grey50", hjust = 1),
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

# Set ggplot defaults
theme_set(theme_apep())

# ==============================================================================
# Clean Slate Law Adoption Dates
# ==============================================================================

# Compiled from Clean Slate Initiative, CCRC, news sources
# Using IMPLEMENTATION dates (when automatic expungement began), not passage dates
clean_slate_dates <- tibble(
  state = c("Pennsylvania", "Utah", "New Jersey", "Michigan", "Connecticut",
            "Delaware", "Virginia", "Oklahoma", "Colorado", "California",
            "Minnesota", "New York"),
  state_abbr = c("PA", "UT", "NJ", "MI", "CT", "DE", "VA", "OK", "CO", "CA", "MN", "NY"),
  state_fips = c("42", "49", "34", "26", "09", "10", "51", "40", "08", "06", "27", "36"),
  # Year law took effect (implementation began)
  treat_year = c(2019, 2022, 2020, 2023, 2023, 2024, 2026, 2025, 2025, 2023, 2025, 2027)
)

# For analysis, we'll use data through 2024
# States with treat_year > 2024 are effectively "not-yet-treated" in our sample
clean_slate_dates <- clean_slate_dates %>%
  mutate(
    # For analysis, treat as never-treated if implementation after sample period
    treat_year_analysis = ifelse(treat_year > 2024, 0, treat_year)
  )

# Print adoption timeline
cat("Clean Slate Law Adoption Dates (Implementation):\n")
print(clean_slate_dates %>% arrange(treat_year) %>% select(state, treat_year))

# ==============================================================================
# Directory setup
# ==============================================================================

data_dir <- "output/paper_59/data"
fig_dir <- "output/paper_59/figures"

if (!dir.exists(data_dir)) dir.create(data_dir, recursive = TRUE)
if (!dir.exists(fig_dir)) dir.create(fig_dir, recursive = TRUE)

cat("\nPackages loaded and theme set.\n")
cat("Data directory:", data_dir, "\n")
cat("Figures directory:", fig_dir, "\n")
