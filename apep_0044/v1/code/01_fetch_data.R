# ==============================================================================
# 01_fetch_data.R
# Fetch Census ACS data for Clean Slate analysis
# ==============================================================================

source("output/paper_59/code/00_packages.R")

library(httr)
library(jsonlite)

cat("========================================\n")
cat("FETCHING DATA: Census ACS\n")
cat("========================================\n\n")

# ==============================================================================
# Census ACS Data - Employment, Income, Demographics
# ==============================================================================

cat("Fetching Census ACS data (2010-2023)...\n")

# ACS 1-year estimates
# Variables:
# B23025_002E - In labor force (16+)
# B23025_003E - Civilian labor force
# B23025_004E - Employed
# B23025_005E - Unemployed
# B23025_007E - Not in labor force
# B01003_001E - Total population

fetch_acs_year <- function(year) {
  base_url <- sprintf("https://api.census.gov/data/%d/acs/acs1", year)

  vars <- c(
    "NAME",
    "B23025_002E",  # In labor force
    "B23025_003E",  # Civilian labor force
    "B23025_004E",  # Employed (civilian)
    "B23025_005E",  # Unemployed
    "B23025_007E",  # Not in labor force
    "B01003_001E"   # Total population
  )

  url <- paste0(
    base_url,
    "?get=", paste(vars, collapse = ","),
    "&for=state:*"
  )

  response <- tryCatch(
    GET(url, timeout(30)),
    error = function(e) NULL
  )

  if (is.null(response) || status_code(response) != 200) {
    warning(sprintf("Failed to fetch ACS data for %d", year))
    return(NULL)
  }

  data <- fromJSON(content(response, "text"))

  # First row is header
  df <- as_tibble(data[-1, ], .name_repair = "minimal")
  names(df) <- data[1, ]

  df <- df %>%
    mutate(
      year = year,
      across(c(B23025_002E:B01003_001E), as.numeric)
    ) %>%
    rename(state_fips = state)

  return(df)
}

# Fetch ACS data for all available years
acs_data <- list()
for (year in 2010:2023) {
  cat(sprintf("  Fetching ACS %d...", year))
  acs_year <- fetch_acs_year(year)
  if (!is.null(acs_year)) {
    acs_data[[as.character(year)]] <- acs_year
    cat(" done\n")
  } else {
    cat(" FAILED\n")
  }
  Sys.sleep(0.5)
}

acs_all <- bind_rows(acs_data)

# Rename and compute variables
acs_clean <- acs_all %>%
  rename(
    state_name = NAME,
    in_labor_force = B23025_002E,
    civilian_labor_force = B23025_003E,
    employed_civilian = B23025_004E,
    unemployed = B23025_005E,
    not_in_labor_force = B23025_007E,
    total_pop = B01003_001E
  ) %>%
  mutate(
    # Compute rates
    working_age_pop = in_labor_force + not_in_labor_force,
    lfp_rate = in_labor_force / working_age_pop * 100,
    emp_rate = employed_civilian / working_age_pop * 100,
    unemp_rate = unemployed / civilian_labor_force * 100
  )

cat(sprintf("\nFetched ACS data for %d state-years\n", nrow(acs_clean)))

# ==============================================================================
# State Abbreviations Reference
# ==============================================================================

state_abbr <- tibble(
  state_fips = c("01", "02", "04", "05", "06", "08", "09", "10", "11", "12", "13",
                 "15", "16", "17", "18", "19", "20", "21", "22", "23", "24",
                 "25", "26", "27", "28", "29", "30", "31", "32", "33", "34",
                 "35", "36", "37", "38", "39", "40", "41", "42", "44", "45",
                 "46", "47", "48", "49", "50", "51", "53", "54", "55", "56"),
  state_abbr = c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "FL", "GA",
                 "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
                 "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
                 "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
                 "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY")
)

# ==============================================================================
# Create Panel Data
# ==============================================================================

panel_data <- acs_clean %>%
  # Add state abbreviations
  left_join(state_abbr, by = "state_fips") %>%
  # Add treatment information
  left_join(
    clean_slate_dates %>% select(state_fips, treat_year = treat_year_analysis),
    by = "state_fips"
  ) %>%
  mutate(
    # States without Clean Slate are never-treated (treat_year = 0)
    treat_year = replace_na(treat_year, 0),
    # Cohort for Sun-Abraham (Inf = never-treated)
    cohort = ifelse(treat_year == 0, Inf, treat_year),
    # Post-treatment indicator
    post = as.integer(year >= treat_year & treat_year > 0),
    # Treatment indicator (ever treated within sample)
    treated = as.integer(treat_year > 0 & treat_year <= 2024),
    # Relative time to treatment
    rel_time = ifelse(treat_year > 0, year - treat_year, NA_integer_)
  ) %>%
  # Create state numeric ID
  mutate(state_id = as.integer(factor(state_fips)))

# State population for weighting (2019 pre-COVID baseline)
state_pop <- acs_clean %>%
  filter(year == 2019) %>%
  select(state_fips, pop_2019 = total_pop)

panel_data <- panel_data %>%
  left_join(state_pop, by = "state_fips")

# ==============================================================================
# Save Data
# ==============================================================================

write_csv(panel_data, file.path(data_dir, "panel_data.csv"))
saveRDS(panel_data, file.path(data_dir, "panel_data.rds"))
write_csv(clean_slate_dates, file.path(data_dir, "clean_slate_dates.csv"))

cat("\n========================================\n")
cat("DATA SUMMARY\n")
cat("========================================\n")
cat(sprintf("Panel data: %d state-years\n", nrow(panel_data)))
cat(sprintf("States: %d\n", n_distinct(panel_data$state_fips)))
cat(sprintf("Years: %d - %d\n", min(panel_data$year), max(panel_data$year)))
cat(sprintf("Treated states (Clean Slate by 2024): %d\n",
            sum(panel_data$treated[panel_data$year == 2023])))
cat("\nTreatment timing:\n")
panel_data %>%
  filter(treat_year > 0, year == 2023) %>%
  arrange(treat_year) %>%
  select(state_abbr, treat_year) %>%
  print(n = 15)

cat("\nOutcome means (2019):\n")
panel_data %>%
  filter(year == 2019) %>%
  summarize(
    emp_rate = mean(emp_rate, na.rm = TRUE),
    lfp_rate = mean(lfp_rate, na.rm = TRUE),
    unemp_rate = mean(unemp_rate, na.rm = TRUE)
  ) %>%
  print()

cat("\nData saved to:", data_dir, "\n")
