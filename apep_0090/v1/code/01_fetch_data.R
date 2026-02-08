# ==============================================================================
# Paper 112: State Data Privacy Laws and Technology Sector Business Formation
# 01_fetch_data.R - Fetch data from FRED and other sources
# ==============================================================================

source("00_packages.R")
library(fredr)
library(httr)
library(jsonlite)

# ==============================================================================
# 1. Define state privacy law treatment dates
# ==============================================================================

privacy_laws <- tribble(
  ~state, ~state_abbr, ~effective_date, ~threshold_consumers, ~notes,
  "California", "CA", "2020-01-01", 50000, "CCPA - first comprehensive state law",
  "Virginia", "VA", "2023-01-01", 100000, "VCDPA - first of 2023 wave",
  "Colorado", "CO", "2023-07-01", 100000, "CPA",
  "Connecticut", "CT", "2023-07-01", 100000, "CTDPA",
  "Utah", "UT", "2023-12-31", 100000, "UCPA",
  "Texas", "TX", "2024-07-01", 0, "TDPSA - no consumer threshold",
  "Oregon", "OR", "2024-07-01", 100000, "OCPA",
  "Montana", "MT", "2024-10-01", 50000, "MCDPA",
  "Iowa", "IA", "2025-01-01", 100000, "ICDPA",
  "Indiana", "IN", "2026-01-01", 100000, "Future",
  "Tennessee", "TN", "2025-07-01", 100000, "TIPA",
  "Delaware", "DE", "2025-01-01", 35000, "DPDPA",
  "New Hampshire", "NH", "2025-01-01", 35000, "NHPA",
  "New Jersey", "NJ", "2025-01-15", 100000, "NJDPA",
  "Nebraska", "NE", "2025-01-01", 100000, "NDPA",
  "Maryland", "MD", "2025-10-01", 35000, "MODPA",
  "Minnesota", "MN", "2025-07-31", 100000, "MCDPA"
) %>%
  mutate(effective_date = as.Date(effective_date))

# All US states with FIPS codes
all_states <- tibble(
  state_abbr = c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
                 "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
                 "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
                 "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
                 "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"),
  state_fips = sprintf("%02d", c(1, 2, 4, 5, 6, 8, 9, 10, 12, 13,
                                  15, 16, 17, 18, 19, 20, 21, 22, 23, 24,
                                  25, 26, 27, 28, 29, 30, 31, 32, 33, 34,
                                  35, 36, 37, 38, 39, 40, 41, 42, 44, 45,
                                  46, 47, 48, 49, 50, 51, 53, 54, 55, 56))
)

# Save treatment data
write_csv(privacy_laws, file.path(dir_data, "privacy_laws.csv"))
write_csv(all_states, file.path(dir_data, "all_states.csv"))

message("Saved treatment definitions: ", nrow(privacy_laws), " privacy laws")

# ==============================================================================
# 2. Fetch Business Formation Statistics from FRED
# ==============================================================================

message("\nFetching Business Formation Statistics from FRED...")

# Function to get FRED series for all states
fetch_fred_series <- function(series_prefix, series_suffix = "") {
  results <- list()

  for (i in seq_len(nrow(all_states))) {
    state <- all_states$state_abbr[i]
    series_id <- paste0(series_prefix, state, series_suffix)

    tryCatch({
      data <- fredr(
        series_id = series_id,
        observation_start = as.Date("2015-01-01"),
        observation_end = as.Date("2025-12-01")
      )

      if (nrow(data) > 0) {
        data <- data %>%
          select(date, value) %>%
          mutate(state_abbr = state,
                 series = series_prefix)
        results[[state]] <- data
      }

    }, error = function(e) {
      message("  Could not fetch ", series_id, ": ", e$message)
    })

    Sys.sleep(0.2)  # Rate limiting
  }

  bind_rows(results)
}

# Fetch high-propensity business applications in Information sector
message("Fetching NAICS 51 (Information) business applications...")
# Note: FRED may not have sector-specific state series
# Try total high-propensity first
ba_total <- fetch_fred_series("BAHBATOTALSA")

if (nrow(ba_total) > 0) {
  message("  Fetched total high-propensity applications for ",
          n_distinct(ba_total$state_abbr), " states")
}

# Also fetch total business applications (not just high-propensity)
message("Fetching total business applications...")
ba_all <- fetch_fred_series("BABATOTALSA")

if (nrow(ba_all) > 0) {
  message("  Fetched total applications for ",
          n_distinct(ba_all$state_abbr), " states")
}

# Combine
business_apps <- bind_rows(
  ba_total %>% mutate(type = "high_propensity"),
  ba_all %>% mutate(type = "total")
) %>%
  rename(business_apps = value)

write_csv(business_apps, file.path(dir_data, "business_applications.csv"))
message("Saved: ", nrow(business_apps), " observations of business applications")

# ==============================================================================
# 3. Fetch state unemployment rates for controls
# ==============================================================================

message("\nFetching unemployment rates...")

unemployment <- fetch_fred_series("", "UR")  # State unemployment rates

# Alternative approach using BLS series naming
unemp_list <- list()
for (i in seq_len(nrow(all_states))) {
  state <- all_states$state_abbr[i]
  fips <- all_states$state_fips[i]

  # LAUS series: LASST{FIPS}0000000000003
  series_id <- paste0("LASST", fips, "0000000000003")

  tryCatch({
    data <- fredr(
      series_id = series_id,
      observation_start = as.Date("2015-01-01"),
      observation_end = as.Date("2025-12-01")
    )

    if (nrow(data) > 0) {
      unemp_list[[state]] <- data %>%
        select(date, value) %>%
        mutate(state_abbr = state) %>%
        rename(unemployment_rate = value)
    }

  }, error = function(e) {
    # Try alternative series naming
  })

  Sys.sleep(0.1)
}

unemployment <- bind_rows(unemp_list)
write_csv(unemployment, file.path(dir_data, "unemployment.csv"))
message("Saved: ", nrow(unemployment), " unemployment observations")

# ==============================================================================
# 4. Summary
# ==============================================================================

message("\n", strrep("=", 60))
message("DATA FETCH COMPLETE")
message(strrep("=", 60))

data_summary <- tibble(
  dataset = c("Privacy laws", "Business applications", "Unemployment"),
  observations = c(nrow(privacy_laws), nrow(business_apps), nrow(unemployment)),
  states = c(n_distinct(privacy_laws$state_abbr),
             n_distinct(business_apps$state_abbr),
             n_distinct(unemployment$state_abbr))
)

print(data_summary)

message("\nData saved to: ", dir_data)
