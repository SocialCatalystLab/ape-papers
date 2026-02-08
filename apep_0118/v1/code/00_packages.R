# =============================================================================
# 00_packages.R
# Load required packages for Sports Betting Employment Analysis
# Paper 117: Revision of apep_0116 with REAL data
# =============================================================================

# Core data manipulation
library(tidyverse)
library(lubridate)
library(data.table)

# Econometrics
library(fixest)      # Fast fixed effects
library(did)         # Callaway-Sant'Anna
library(HonestDiD)   # Rambachan-Roth sensitivity

# Tables and output
library(modelsummary)
library(kableExtra)

# Figures
library(ggplot2)
library(patchwork)
library(scales)

# Set ggplot theme
theme_set(theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold"),
    legend.position = "bottom"
  ))

# State FIPS codes mapping (used across scripts)
state_fips <- tibble(
  state_abbr = c(state.abb, "DC"),
  state_name = c(state.name, "District of Columbia")
) %>%
  mutate(
    state_fips = case_when(
      state_abbr == "AL" ~ "01", state_abbr == "AK" ~ "02", state_abbr == "AZ" ~ "04",
      state_abbr == "AR" ~ "05", state_abbr == "CA" ~ "06", state_abbr == "CO" ~ "08",
      state_abbr == "CT" ~ "09", state_abbr == "DE" ~ "10", state_abbr == "DC" ~ "11",
      state_abbr == "FL" ~ "12", state_abbr == "GA" ~ "13", state_abbr == "HI" ~ "15",
      state_abbr == "ID" ~ "16", state_abbr == "IL" ~ "17", state_abbr == "IN" ~ "18",
      state_abbr == "IA" ~ "19", state_abbr == "KS" ~ "20", state_abbr == "KY" ~ "21",
      state_abbr == "LA" ~ "22", state_abbr == "ME" ~ "23", state_abbr == "MD" ~ "24",
      state_abbr == "MA" ~ "25", state_abbr == "MI" ~ "26", state_abbr == "MN" ~ "27",
      state_abbr == "MS" ~ "28", state_abbr == "MO" ~ "29", state_abbr == "MT" ~ "30",
      state_abbr == "NE" ~ "31", state_abbr == "NV" ~ "32", state_abbr == "NH" ~ "33",
      state_abbr == "NJ" ~ "34", state_abbr == "NM" ~ "35", state_abbr == "NY" ~ "36",
      state_abbr == "NC" ~ "37", state_abbr == "ND" ~ "38", state_abbr == "OH" ~ "39",
      state_abbr == "OK" ~ "40", state_abbr == "OR" ~ "41", state_abbr == "PA" ~ "42",
      state_abbr == "RI" ~ "44", state_abbr == "SC" ~ "45", state_abbr == "SD" ~ "46",
      state_abbr == "TN" ~ "47", state_abbr == "TX" ~ "48", state_abbr == "UT" ~ "49",
      state_abbr == "VT" ~ "50", state_abbr == "VA" ~ "51", state_abbr == "WA" ~ "53",
      state_abbr == "WV" ~ "54", state_abbr == "WI" ~ "55", state_abbr == "WY" ~ "56",
      TRUE ~ NA_character_
    )
  )

message("Packages loaded successfully")
message("State FIPS mapping: ", nrow(state_fips), " states/jurisdictions")
