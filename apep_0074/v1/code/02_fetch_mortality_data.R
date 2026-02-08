# ============================================================
# 02_fetch_mortality_data.R - Fetch Suicide Mortality Data
# Source: CDC NCHS Leading Causes of Death (data.cdc.gov)
# ============================================================

source("00_packages.R")

cat("=== Fetching CDC Mortality Data ===\n")

# Fetch suicide mortality data from CDC API
# Dataset: NCHS - Leading Causes of Death: United States
# API endpoint: https://data.cdc.gov/resource/bi63-dtpu

url <- "https://data.cdc.gov/resource/bi63-dtpu.csv"
params <- list(
  `$select` = "year,state,deaths,aadr",
  `$where` = "cause_name='Suicide'",
  `$limit` = 2000
)

cat("Querying CDC API...\n")
response <- GET(url, query = params)

if (status_code(response) == 200) {
  # Parse response
  mortality_raw <- content(response, type = "text", encoding = "UTF-8") %>%
    read_csv(show_col_types = FALSE)

  cat("Successfully fetched", nrow(mortality_raw), "records\n\n")
} else {
  stop("Failed to fetch CDC data. Status code: ", status_code(response))
}

# Clean and process data
mortality_data <- mortality_raw %>%
  filter(state != "United States") %>%  # Remove national aggregate
  mutate(
    year = as.integer(year),
    deaths = as.integer(deaths),
    suicide_rate = as.numeric(aadr)
  ) %>%
  select(state, year, deaths, suicide_rate)

# Add state abbreviations
state_lookup <- tibble(
  state = c("Alabama", "Alaska", "Arizona", "Arkansas", "California",
            "Colorado", "Connecticut", "Delaware", "District of Columbia",
            "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana",
            "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland",
            "Massachusetts", "Michigan", "Minnesota", "Mississippi",
            "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire",
            "New Jersey", "New Mexico", "New York", "North Carolina",
            "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania",
            "Rhode Island", "South Carolina", "South Dakota", "Tennessee",
            "Texas", "Utah", "Vermont", "Virginia", "Washington",
            "West Virginia", "Wisconsin", "Wyoming"),
  state_abbr = c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC",
                 "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY",
                 "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT",
                 "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH",
                 "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT",
                 "VT", "VA", "WA", "WV", "WI", "WY")
)

mortality_data <- mortality_data %>%
  left_join(state_lookup, by = "state") %>%
  select(state_abbr, state, year, deaths, suicide_rate)

# Check data coverage
cat("=== Data Coverage ===\n")
cat("Years:", min(mortality_data$year), "-", max(mortality_data$year), "\n")
cat("States:", n_distinct(mortality_data$state_abbr), "\n")
cat("Total observations:", nrow(mortality_data), "\n\n")

cat("Records per year:\n")
mortality_data %>%
  count(year) %>%
  print()

# Summary statistics
cat("\n=== Suicide Rate Summary (per 100,000) ===\n")
mortality_data %>%
  summarise(
    Mean = round(mean(suicide_rate, na.rm = TRUE), 1),
    SD = round(sd(suicide_rate, na.rm = TRUE), 1),
    Min = round(min(suicide_rate, na.rm = TRUE), 1),
    Max = round(max(suicide_rate, na.rm = TRUE), 1)
  ) %>%
  print()

# Trend over time
cat("\n=== National Trend ===\n")
mortality_data %>%
  group_by(year) %>%
  summarise(mean_rate = mean(suicide_rate, na.rm = TRUE)) %>%
  print(n = 20)

# Save processed data
write_csv(mortality_data, "../data/suicide_mortality.csv")
saveRDS(mortality_data, "../data/suicide_mortality.rds")

cat("\n=== Data Saved ===\n")
cat("File: data/suicide_mortality.csv\n")
cat("File: data/suicide_mortality.rds\n")

# Important note about data limitations
cat("\n=== DATA LIMITATIONS ===\n")
cat("1. Data covers 1999-2017 only (CDC API limitation)\n")
cat("2. This is TOTAL suicide, not firearm-specific\n")
cat("3. The 2018-2019 ERPO adoption wave is not captured\n")
cat("4. Only early adopters (CT 1999, IN 2005, CA 2016, WA 2016) contribute to identification\n")
cat("\nFor analysis with 2018-2019 data, CDC WONDER web queries would be needed.\n")
