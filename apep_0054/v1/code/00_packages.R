# ============================================================================
# 00_packages.R
# Salary Transparency Laws and the Gender Wage Gap
# Package Loading and Theme Setup
# ============================================================================

# ---- Core packages ----
library(tidyverse)
library(data.table)
library(haven)

# ---- IPUMS data access ----
library(ipumsr)

# ---- Difference-in-Differences ----
library(did)          # Callaway-Sant'Anna
library(fixest)       # Sun-Abraham via sunab(), fast TWFE, tables
library(did2s)        # Gardner's two-stage

# ---- Inference ----
library(sandwich)
library(lmtest)

# ---- Visualization ----
library(ggplot2)
library(latex2exp)
library(scales)
library(patchwork)

# ---- Mapping ----
library(sf)
library(tigris)
options(tigris_use_cache = TRUE)

# ---- API access ----
library(httr)
library(jsonlite)

# ============================================================================
# APEP Standard Theme
# ============================================================================

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
  "#0072B2",  # Blue (treated/primary)
  "#D55E00",  # Orange (control)
  "#009E73",  # Green (third group)
  "#CC79A7",  # Pink (fourth group/female)
  "#F0E442",  # Yellow (fifth group)
  "#56B4E9"   # Light blue (sixth group/male)
)

# Named colors for specific uses
color_treated <- "#0072B2"
color_control <- "#D55E00"
color_female <- "#CC79A7"
color_male <- "#56B4E9"
color_ci <- "#0072B2"

# ============================================================================
# Directory Setup
# ============================================================================

# Create output directories if they don't exist
dir.create("data", showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)
dir.create("tables", showWarnings = FALSE)

# ============================================================================
# Helper Functions
# ============================================================================

# Function to calculate hourly wage from annual income and hours
calc_hourly_wage <- function(annual_wage, hours_per_week, weeks_worked = 52) {
  # Assume 52 weeks if not specified
  annual_hours <- hours_per_week * weeks_worked
  hourly_wage <- annual_wage / annual_hours
  return(hourly_wage)
}

# Function to winsorize at percentiles
winsorize <- function(x, probs = c(0.01, 0.99)) {
  q <- quantile(x, probs, na.rm = TRUE)
  x[x < q[1]] <- q[1]
  x[x > q[2]] <- q[2]
  return(x)
}

# ============================================================================
# Salary Transparency Law Data
# ============================================================================

# Treatment timing: State salary transparency laws
# Note: Dates are law effective dates; treatment year is income year affected
# CPS ASEC asks about income in PREVIOUS year
# So ASEC 2022 survey = income year 2021

transparency_laws <- tibble(
  state_name = c("Colorado", "Connecticut", "Nevada", "Rhode Island",
                 "California", "Washington", "New York", "Hawaii",
                 "Maryland", "Illinois", "Minnesota", "New Jersey",
                 "Vermont", "Massachusetts"),
  state_abbr = c("CO", "CT", "NV", "RI", "CA", "WA", "NY", "HI",
                 "MD", "IL", "MN", "NJ", "VT", "MA"),
  statefip = c(8, 9, 32, 44, 6, 53, 36, 15, 24, 17, 27, 34, 50, 25),
  effective_date = as.Date(c("2021-01-01", "2021-10-01", "2021-10-01",
                             "2023-01-01", "2023-01-01", "2023-01-01",
                             "2023-09-17", "2024-01-01", "2024-10-01",
                             "2025-01-01", "2025-01-01", "2025-06-01",
                             "2025-07-01", "2025-07-31")),
  employer_threshold = c(1, 1, 1, 1, 15, 15, 4, 50, 1, 15, 30, 10, 5, 25)
) %>%
  mutate(
    # First income year affected
    # For Jan 1 laws, income year = effective year
    # For mid-year laws, first FULL income year = following year
    income_year_first = case_when(
      month(effective_date) <= 3 ~ year(effective_date),  # Q1 = that year
      TRUE ~ year(effective_date) + 1  # Q2-Q4 = following year
    ),
    # Treatment cohort (for C-S estimator)
    first_treat = income_year_first
  )

# Save for use in other scripts
saveRDS(transparency_laws, "data/transparency_laws.rds")

cat("Packages loaded and theme configured.\n")
cat("Transparency law data saved to data/transparency_laws.rds\n")
