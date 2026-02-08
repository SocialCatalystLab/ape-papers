# =============================================================================
# 00_packages.R
# Sports Betting Employment Effects - Revision of apep_0038
# Load required packages and set global options
# =============================================================================

# Required packages
required_packages <- c(
  # Data manipulation
  "tidyverse",
  "data.table",
  "lubridate",

  # API access
  "httr",
  "jsonlite",

  # Econometrics
  "did",           # Callaway-Sant'Anna
  "fixest",        # Fast fixed effects
  "HonestDiD",     # Rambachan-Roth sensitivity
  "sandwich",      # Robust SEs
  "lmtest",        # Coefficient tests

  # Visualization
  "ggplot2",
  "patchwork",
  "scales",
  "viridis",

  # Tables
  "modelsummary",
  "kableExtra",

  # Misc
  "here"
)

# Install missing packages
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    message(paste("Installing", pkg, "..."))
    install.packages(pkg, repos = "https://cloud.r-project.org/")
  }
}

invisible(lapply(required_packages, install_if_missing))

# Load packages
invisible(lapply(required_packages, library, character.only = TRUE))

# Set options
options(
  scipen = 999,
  digits = 4,
  dplyr.summarise.inform = FALSE
)

# ggplot2 theme for publication
theme_paper <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "gray90", linewidth = 0.3),
      axis.line = element_line(color = "gray40", linewidth = 0.4),
      axis.ticks = element_line(color = "gray40", linewidth = 0.3),
      plot.title = element_text(face = "bold", size = rel(1.1)),
      plot.subtitle = element_text(color = "gray40"),
      legend.position = "bottom",
      strip.text = element_text(face = "bold")
    )
}

theme_set(theme_paper())

# State FIPS codes
state_fips <- tibble::tribble(
  ~state_abbr, ~state_fips, ~state_name,
  "AL", "01", "Alabama",
  "AK", "02", "Alaska",
  "AZ", "04", "Arizona",
  "AR", "05", "Arkansas",
  "CA", "06", "California",
  "CO", "08", "Colorado",
  "CT", "09", "Connecticut",
  "DE", "10", "Delaware",
  "DC", "11", "District of Columbia",
  "FL", "12", "Florida",
  "GA", "13", "Georgia",
  "HI", "15", "Hawaii",
  "ID", "16", "Idaho",
  "IL", "17", "Illinois",
  "IN", "18", "Indiana",
  "IA", "19", "Iowa",
  "KS", "20", "Kansas",
  "KY", "21", "Kentucky",
  "LA", "22", "Louisiana",
  "ME", "23", "Maine",
  "MD", "24", "Maryland",
  "MA", "25", "Massachusetts",
  "MI", "26", "Michigan",
  "MN", "27", "Minnesota",
  "MS", "28", "Mississippi",
  "MO", "29", "Missouri",
  "MT", "30", "Montana",
  "NE", "31", "Nebraska",
  "NV", "32", "Nevada",
  "NH", "33", "New Hampshire",
  "NJ", "34", "New Jersey",
  "NM", "35", "New Mexico",
  "NY", "36", "New York",
  "NC", "37", "North Carolina",
  "ND", "38", "North Dakota",
  "OH", "39", "Ohio",
  "OK", "40", "Oklahoma",
  "OR", "41", "Oregon",
  "PA", "42", "Pennsylvania",
  "RI", "44", "Rhode Island",
  "SC", "45", "South Carolina",
  "SD", "46", "South Dakota",
  "TN", "47", "Tennessee",
  "TX", "48", "Texas",
  "UT", "49", "Utah",
  "VT", "50", "Vermont",
  "VA", "51", "Virginia",
  "WA", "53", "Washington",
  "WV", "54", "West Virginia",
  "WI", "55", "Wisconsin",
  "WY", "56", "Wyoming"
)

message("Packages loaded successfully.")
message(paste("R version:", R.version.string))
message(paste("did package version:", packageVersion("did")))
message(paste("HonestDiD package version:", packageVersion("HonestDiD")))
