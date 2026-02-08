# =============================================================================
# 00_packages.R - Load packages and set themes
# Paper 85: Paid Family Leave and Female Entrepreneurship
# =============================================================================

# Core packages
library(tidyverse)
library(data.table)
library(httr)
library(jsonlite)

# Econometrics
library(fixest)
library(did)  # Callaway-Sant'Anna

# Small-sample cluster corrections
# Note: fwildclusterboot may not be available for all R versions
# Use fixest's built-in small-sample adjustments instead
# library(fwildclusterboot)  # Commented out - version incompatible

# Tables and figures
library(ggplot2)
library(latex2exp)
library(scales)
library(patchwork)

# Maps
library(sf)
library(tigris)
options(tigris_use_cache = TRUE)

# Set random seed for reproducibility
set.seed(20260127)

# -----------------------------------------------------------------------------
# APEP Standard Theme
# -----------------------------------------------------------------------------

theme_apep <- function() {
  theme_minimal(base_size = 12) +
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

# Set default ggplot theme
theme_set(theme_apep())

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------

# Function to safely query Census API
census_api_query <- function(year, variables, geography = "state:*") {
  base_url <- sprintf("https://api.census.gov/data/%d/acs/acs1", year)

  url <- paste0(
    base_url,
    "?get=NAME,", paste(variables, collapse = ","),
    "&for=", geography
  )

  response <- tryCatch({
    GET(url, timeout(30))
  }, error = function(e) {
    message("Error fetching data for year ", year, ": ", e$message)
    return(NULL)
  })

  if (is.null(response) || status_code(response) != 200) {
    message("Failed to fetch data for year ", year)
    return(NULL)
  }

  data <- fromJSON(content(response, "text", encoding = "UTF-8"))

  # Convert to data frame
  df <- as.data.frame(data[-1, ], stringsAsFactors = FALSE)
  names(df) <- data[1, ]

  df$year <- year

  return(df)
}

# State FIPS codes lookup table
state_fips_lookup <- tibble(
  fips = c("01", "02", "04", "05", "06", "08", "09", "10", "11", "12",
           "13", "15", "16", "17", "18", "19", "20", "21", "22", "23",
           "24", "25", "26", "27", "28", "29", "30", "31", "32", "33",
           "34", "35", "36", "37", "38", "39", "40", "41", "42", "44",
           "45", "46", "47", "48", "49", "50", "51", "53", "54", "55", "56"),
  state_abbr = c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "FL",
                 "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME",
                 "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH",
                 "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI",
                 "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY")
)

# Valid state FIPS codes (50 states + DC)
valid_fips <- state_fips_lookup$fips

message("Packages loaded successfully.")
