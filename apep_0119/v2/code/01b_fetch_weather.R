###############################################################################
# 01b_fetch_weather.R
# Paper 130: EERS Revision - Fetch HDD/CDD Weather Data
# Source: NOAA NCEI State Climate Divisions
###############################################################################

source("00_packages.R")

data_dir <- "../data/"

###############################################################################
# Fetch Heating and Cooling Degree Days from NOAA NCEI
# Using state-level population-weighted degree days
###############################################################################

cat("=== FETCHING WEATHER DATA (HDD/CDD) ===\n")

# NOAA NCEI Climate at a Glance API
# https://www.ncei.noaa.gov/cag/statewide/time-series

fetch_degree_days <- function(state_code, variable, start_year = 1990, end_year = 2023) {
  # variable: "hdd" or "cdd"
  # state_code: 2-digit state FIPS code (01-50)

  base_url <- "https://www.ncei.noaa.gov/cag/statewide/time-series"
  url <- paste0(base_url, "/", state_code, "-", variable, "-all-12-1895-2024.json")

  tryCatch({
    response <- httr::GET(url, httr::timeout(30))

    if (httr::status_code(response) == 200) {
      content <- httr::content(response, as = "text", encoding = "UTF-8")
      data <- jsonlite::fromJSON(content)

      # Extract data from the nested structure
      if (!is.null(data$data)) {
        df <- data.frame(
          year_month = names(data$data),
          value = as.numeric(unlist(data$data)),
          stringsAsFactors = FALSE
        )

        # Filter to annual values (12 = December = annual total)
        df <- df %>%
          mutate(
            year = as.integer(substr(year_month, 1, 4)),
            month = as.integer(substr(year_month, 5, 6))
          ) %>%
          filter(month == 12, year >= start_year, year <= end_year) %>%
          select(year, value)

        return(df)
      }
    }
    return(NULL)
  }, error = function(e) {
    cat("  Error fetching", variable, "for state", state_code, ":", e$message, "\n")
    return(NULL)
  })
}

# State FIPS codes (need to load from existing data)
state_fips <- readRDS(paste0(data_dir, "state_fips.rds"))

# Fetch HDD and CDD for all states
all_weather <- tibble()

cat("Fetching HDD/CDD for", nrow(state_fips), "states...\n")

for (i in 1:nrow(state_fips)) {
  state_code <- sprintf("%02d", state_fips$state_fips[i])
  state_abbr <- state_fips$state_abbr[i]

  cat("  ", state_abbr, "...")

  # Fetch HDD
  hdd <- fetch_degree_days(state_code, "hdd")
  if (!is.null(hdd)) {
    hdd <- hdd %>% mutate(state_abbr = state_abbr, variable = "hdd")
    all_weather <- bind_rows(all_weather, hdd)
  }

  # Fetch CDD
  cdd <- fetch_degree_days(state_code, "cdd")
  if (!is.null(cdd)) {
    cdd <- cdd %>% mutate(state_abbr = state_abbr, variable = "cdd")
    all_weather <- bind_rows(all_weather, cdd)
  }

  cat(" done\n")
  Sys.sleep(0.2)  # Be nice to NOAA servers
}

# Pivot to wide format
weather_wide <- all_weather %>%
  pivot_wider(names_from = variable, values_from = value) %>%
  rename(hdd = hdd, cdd = cdd)

cat("\nWeather data fetched:", nrow(weather_wide), "state-year observations\n")
cat("  Years:", range(weather_wide$year), "\n")
cat("  States:", n_distinct(weather_wide$state_abbr), "\n")

# Check for missing
cat("\nMissing values:\n")
cat("  HDD:", sum(is.na(weather_wide$hdd)), "\n")
cat("  CDD:", sum(is.na(weather_wide$cdd)), "\n")

# Save
saveRDS(weather_wide, paste0(data_dir, "weather_hdd_cdd.rds"))

cat("\n=== WEATHER DATA COMPLETE ===\n")
