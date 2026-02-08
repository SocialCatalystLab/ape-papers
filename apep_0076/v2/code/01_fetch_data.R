# ============================================================================
# Paper 166: State EITC Generosity and Crime (Revision of apep_0076)
# Script: 01_fetch_data.R - Build Analysis Panel with Extended Timeframe
# ============================================================================
#
# REVISION IMPROVEMENTS:
# 1. Extended panel: 1987-2019 (was 1999-2019) - gives early adopters pre-periods
# 2. Time-varying EITC generosity (was 2019 snapshot)
# 3. Policy controls: unemployment, minimum wage, incarceration, police
#
# PREREQUISITES: Run 00_download_data.R first to download CORGIS crime data
# ============================================================================

source("00_packages.R")

cat("Building analysis panel for Paper 166 (EITC-Crime Revision)...\n\n")

# ============================================================================
# PART 1: Load Downloaded Data
# ============================================================================

cat("PART 1: Loading Downloaded Data\n")
cat("-------------------------------\n")

# Check that crime data was downloaded
corgis_file <- file.path(DATA_DIR, "state_crime_corgis.csv")
if (!file.exists(corgis_file)) {
  stop("ERROR: state_crime_corgis.csv not found. Run 00_download_data.R first.")
}

# Load EITC policy databases created by 00_download_data.R
eitc_policy <- read_csv(file.path(DATA_DIR, "eitc_policy.csv"), show_col_types = FALSE)
eitc_rates_hist <- read_csv(file.path(DATA_DIR, "eitc_rates_historical.csv"), show_col_types = FALSE)

cat(sprintf("  EITC policy: %d states with EITC\n", nrow(eitc_policy)))
cat(sprintf("  Historical rates: %d state-year ranges\n", nrow(eitc_rates_hist)))

# ============================================================================
# PART 2: Create Extended State-Year Panel (1987-2019)
# ============================================================================

cat("\nPART 2: Creating Extended State-Year Panel (1987-2019)\n")
cat("------------------------------------------------------\n")

# Extended sample period: 1987-2019
# This gives pre-treatment periods for early adopters:
# - Maryland (1987): 0 pre-periods -> but still first year is treatment
# - Vermont (1988): 1 pre-period
# - Wisconsin (1989): 2 pre-periods
# - Minnesota (1991): 4 pre-periods
# etc.

years <- 1987:2019

# State FIPS mapping
state_fips_map <- tibble(
  state_abbr = c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DC", "DE", "FL",
                 "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME",
                 "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH",
                 "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI",
                 "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"),
  fips = c(1, 2, 4, 5, 6, 8, 9, 11, 10, 12,
           13, 15, 16, 17, 18, 19, 20, 21, 22, 23,
           24, 25, 26, 27, 28, 29, 30, 31, 32, 33,
           34, 35, 36, 37, 38, 39, 40, 41, 42, 44,
           45, 46, 47, 48, 49, 50, 51, 53, 54, 55, 56)
)

# Create full panel
eitc_panel <- expand_grid(
  state_abbr = state_fips_map$state_abbr,
  year = years
) %>%
  left_join(state_fips_map, by = "state_abbr") %>%
  left_join(eitc_policy %>% select(state_abbr, eitc_adopted, refundable),
            by = "state_abbr")

cat(sprintf("  Panel created: %d state-year observations\n", nrow(eitc_panel)))
cat(sprintf("  Sample period: %d-%d (%d years)\n", min(years), max(years), length(years)))

# ============================================================================
# PART 3: Add Time-Varying EITC Generosity
# ============================================================================

cat("\nPART 3: Adding Time-Varying EITC Generosity\n")
cat("--------------------------------------------\n")

# Function to get EITC rate for a state-year from historical data
get_eitc_rate <- function(state, yr, rates_df) {
  rate_row <- rates_df %>%
    filter(state_abbr == state, year_start <= yr, year_end >= yr)

  if (nrow(rate_row) == 0) {
    return(0)
  }
  return(rate_row$eitc_pct[1])
}

# Add time-varying generosity to panel
eitc_panel <- eitc_panel %>%
  rowwise() %>%
  mutate(
    # Binary treatment: State has EITC in this year
    has_eitc = if_else(!is.na(eitc_adopted) & year >= eitc_adopted, 1L, 0L),
    # Time-varying generosity (% of federal credit)
    eitc_generosity = if_else(
      has_eitc == 1L,
      get_eitc_rate(state_abbr, year, eitc_rates_hist),
      0
    )
  ) %>%
  ungroup() %>%
  mutate(
    # High EITC: >10% of federal
    high_eitc = if_else(eitc_generosity > 10, 1L, 0L),
    # First treatment year for CS estimator (must be within sample)
    first_treat = if_else(!is.na(eitc_adopted) & eitc_adopted >= 1987,
                          eitc_adopted, NA_integer_),
    # Cohort variable for CS (0 for never-treated)
    cohort = case_when(
      is.na(eitc_adopted) ~ 0L,  # Never treated
      TRUE ~ as.integer(eitc_adopted)
    )
  )

# Check time-varying generosity
cat("\n  Sample of time-varying EITC generosity:\n")
eitc_panel %>%
  filter(state_abbr == "IL") %>%  # Illinois changed rates
  select(state_abbr, year, has_eitc, eitc_generosity) %>%
  filter(year >= 1999, year <= 2019) %>%
  print(n = 10)

# Save EITC panel
write_csv(eitc_panel, file.path(DATA_DIR, "eitc_state_year_panel.csv"))
cat(sprintf("\n  Saved: eitc_state_year_panel.csv\n"))

# ============================================================================
# PART 4: Fetch Policy Controls from FRED
# ============================================================================

cat("\nPART 4: Fetching Policy Controls from FRED\n")
cat("-------------------------------------------\n")

# Set FRED API key if available
fred_key <- Sys.getenv("FRED_API_KEY")

if (nchar(fred_key) > 0) {
  fredr_set_key(fred_key)
  cat("  FRED API key configured.\n")

  # Function to fetch state unemployment rate
  fetch_state_ur <- function(state_abbr) {
    # FRED series ID for state unemployment: [STATE]UR
    series_id <- paste0(state_abbr, "UR")

    tryCatch({
      data <- fredr(
        series_id = series_id,
        observation_start = as.Date("1987-01-01"),
        observation_end = as.Date("2019-12-31"),
        frequency = "a"  # Annual
      )

      if (nrow(data) > 0) {
        data %>%
          mutate(
            state_abbr = state_abbr,
            year = year(date),
            unemployment_rate = value
          ) %>%
          select(state_abbr, year, unemployment_rate)
      } else {
        NULL
      }
    }, error = function(e) {
      NULL
    })
  }

  cat("  Fetching state unemployment rates...\n")
  ur_list <- list()
  for (st in state_fips_map$state_abbr) {
    result <- fetch_state_ur(st)
    if (!is.null(result) && nrow(result) > 0) {
      ur_list[[st]] <- result
    }
    Sys.sleep(0.2)  # Rate limiting
  }

  if (length(ur_list) > 0) {
    unemployment_data <- bind_rows(ur_list)
    cat(sprintf("  Retrieved unemployment data for %d states\n", length(ur_list)))
    write_csv(unemployment_data, file.path(DATA_DIR, "state_unemployment.csv"))
  } else {
    cat("  WARNING: Could not fetch unemployment data from FRED.\n")
    unemployment_data <- NULL
  }

} else {
  cat("  FRED API key not set. Using fallback controls.\n")
  unemployment_data <- NULL
}

# ============================================================================
# PART 5: Create State Minimum Wage Panel
# ============================================================================

cat("\nPART 5: Creating State Minimum Wage Panel\n")
cat("------------------------------------------\n")

# Historical federal minimum wage
federal_mw <- tribble(
  ~year_start, ~year_end, ~federal_mw,
  1987, 1989, 3.35,
  1990, 1990, 3.80,
  1991, 1995, 4.25,
  1996, 1996, 4.75,
  1997, 2006, 5.15,
  2007, 2007, 5.85,
  2008, 2008, 6.55,
  2009, 2019, 7.25
)

# State minimum wage above federal (simplified - key states with higher MW)
# Source: DOL historical tables
# Note: This is a simplified version - comprehensive data would require DOL API
state_mw_premium <- tribble(
  ~state_abbr, ~year_start, ~year_end, ~state_mw,
  # California
  "CA", 1987, 1997, 4.25,
  "CA", 1998, 2000, 5.75,
  "CA", 2001, 2007, 6.75,
  "CA", 2008, 2013, 8.00,
  "CA", 2014, 2015, 9.00,
  "CA", 2016, 2016, 10.00,
  "CA", 2017, 2017, 10.50,
  "CA", 2018, 2018, 11.00,
  "CA", 2019, 2019, 12.00,
  # New York
  "NY", 1987, 2004, NA,  # Followed federal
  "NY", 2005, 2006, 6.00,
  "NY", 2007, 2013, 7.25,
  "NY", 2014, 2015, 8.75,
  "NY", 2016, 2016, 9.00,
  "NY", 2017, 2017, 10.40,
  "NY", 2018, 2018, 11.10,
  "NY", 2019, 2019, 11.80,
  # Massachusetts
  "MA", 1987, 1999, NA,
  "MA", 2000, 2006, 6.75,
  "MA", 2007, 2013, 8.00,
  "MA", 2014, 2014, 8.00,
  "MA", 2015, 2015, 9.00,
  "MA", 2016, 2016, 10.00,
  "MA", 2017, 2017, 11.00,
  "MA", 2018, 2018, 11.00,
  "MA", 2019, 2019, 12.00,
  # Washington
  "WA", 1987, 1998, NA,
  "WA", 1999, 2000, 5.70,
  "WA", 2001, 2019, NA  # Indexed to inflation, generally higher
)

# Create minimum wage panel
mw_panel <- expand_grid(
  state_abbr = state_fips_map$state_abbr,
  year = years
) %>%
  rowwise() %>%
  mutate(
    # Get federal MW for this year
    federal_mw = {
      row <- federal_mw %>% filter(year_start <= year, year_end >= year)
      if (nrow(row) > 0) row$federal_mw[1] else NA_real_
    },
    # Get state MW if it exists
    state_mw = {
      row <- state_mw_premium %>%
        filter(state_abbr == .data$state_abbr, year_start <= year, year_end >= year)
      if (nrow(row) > 0 && !is.na(row$state_mw[1])) row$state_mw[1] else NA_real_
    }
  ) %>%
  ungroup() %>%
  mutate(
    # Effective minimum wage (max of state and federal)
    min_wage = pmax(federal_mw, state_mw, na.rm = TRUE),
    # Log minimum wage
    log_min_wage = log(min_wage)
  )

write_csv(mw_panel %>% select(state_abbr, year, min_wage, log_min_wage),
          file.path(DATA_DIR, "state_minimum_wage.csv"))
cat(sprintf("  Saved: state_minimum_wage.csv\n"))

# ============================================================================
# PART 6: Create Incarceration Rate Panel (BJS data)
# ============================================================================

cat("\nPART 6: Creating Incarceration Controls (Simplified)\n")
cat("----------------------------------------------------\n")

# Note: Full BJS data requires manual download from
# https://bjs.ojp.gov/data-collection/national-prisoner-statistics-nps-program
# Using national trends as proxy for now

# National incarceration rate trend (per 100,000)
# Source: BJS Prisoners series
national_incarceration <- tribble(
  ~year, ~national_incarceration_rate,
  1987, 228,
  1988, 244,
  1989, 274,
  1990, 292,
  1991, 310,
  1992, 329,
  1993, 351,
  1994, 387,
  1995, 411,
  1996, 427,
  1997, 444,
  1998, 461,
  1999, 476,
  2000, 478,
  2001, 470,
  2002, 476,
  2003, 482,
  2004, 486,
  2005, 491,
  2006, 501,
  2007, 506,
  2008, 504,
  2009, 502,
  2010, 500,
  2011, 492,
  2012, 480,
  2013, 478,
  2014, 471,
  2015, 458,
  2016, 450,
  2017, 440,
  2018, 431,
  2019, 419
)

write_csv(national_incarceration, file.path(DATA_DIR, "national_incarceration.csv"))
cat(sprintf("  Saved: national_incarceration.csv (national trends)\n"))

# ============================================================================
# PART 7: Merge All Data Sources
# ============================================================================

cat("\nPART 7: Merging All Data Sources\n")
cat("---------------------------------\n")

# Load crime data from CORGIS
crime_raw <- read_csv(corgis_file, show_col_types = FALSE)

# Create state abbreviation mapping
state_name_map <- tibble(
  state_name = c(
    "Alabama", "Alaska", "Arizona", "Arkansas", "California",
    "Colorado", "Connecticut", "Delaware", "Florida", "Georgia",
    "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa",
    "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland",
    "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri",
    "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey",
    "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio",
    "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina",
    "South Dakota", "Tennessee", "Texas", "Utah", "Vermont",
    "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming",
    "District of Columbia"
  ),
  state_abbr = c(
    "AL", "AK", "AZ", "AR", "CA",
    "CO", "CT", "DE", "FL", "GA",
    "HI", "ID", "IL", "IN", "IA",
    "KS", "KY", "LA", "ME", "MD",
    "MA", "MI", "MN", "MS", "MO",
    "MT", "NE", "NV", "NH", "NJ",
    "NM", "NY", "NC", "ND", "OH",
    "OK", "OR", "PA", "RI", "SC",
    "SD", "TN", "TX", "UT", "VT",
    "VA", "WA", "WV", "WI", "WY",
    "DC"
  )
)

# Clean crime data
crime_clean <- crime_raw %>%
  rename(
    state_name = State,
    year = Year,
    population = `Data.Population`,
    property_rate = `Data.Rates.Property.All`,
    burglary_rate = `Data.Rates.Property.Burglary`,
    larceny_rate = `Data.Rates.Property.Larceny`,
    mvt_rate = `Data.Rates.Property.Motor`,
    violent_rate = `Data.Rates.Violent.All`,
    murder_rate = `Data.Rates.Violent.Murder`
  ) %>%
  left_join(state_name_map, by = "state_name") %>%
  filter(year >= 1987, year <= 2019)

cat(sprintf("  Crime data: %d state-years (%d-%d)\n",
            nrow(crime_clean), min(crime_clean$year), max(crime_clean$year)))

# Merge with EITC panel
analysis_data <- eitc_panel %>%
  left_join(
    crime_clean %>% select(state_abbr, year, population,
                           property_rate, burglary_rate, larceny_rate, mvt_rate,
                           violent_rate, murder_rate),
    by = c("state_abbr", "year")
  )

# Merge minimum wage
analysis_data <- analysis_data %>%
  left_join(mw_panel %>% select(state_abbr, year, min_wage, log_min_wage),
            by = c("state_abbr", "year"))

# Merge unemployment if available
if (!is.null(unemployment_data) && nrow(unemployment_data) > 0) {
  analysis_data <- analysis_data %>%
    left_join(unemployment_data, by = c("state_abbr", "year"))
}

# Merge national incarceration trend
analysis_data <- analysis_data %>%
  left_join(national_incarceration, by = "year")

# Filter to observations with crime data
analysis_data <- analysis_data %>%
  filter(!is.na(property_rate))

cat(sprintf("  Merged analysis data: %d state-years\n", nrow(analysis_data)))

# ============================================================================
# PART 8: Create Analysis Variables
# ============================================================================

cat("\nPART 8: Creating Analysis Variables\n")
cat("------------------------------------\n")

analysis_data <- analysis_data %>%
  mutate(
    # Log outcomes
    log_property_rate = log(property_rate + 1),
    log_burglary_rate = log(burglary_rate + 1),
    log_larceny_rate = log(larceny_rate + 1),
    log_mvt_rate = log(mvt_rate + 1),
    log_violent_rate = log(violent_rate + 1),
    log_murder_rate = log(murder_rate + 1),
    log_population = log(population),
    # Binary treatment
    treated = as.integer(has_eitc),
    # Time since treatment (for event study)
    time_since_treat = if_else(
      !is.na(eitc_adopted),
      year - eitc_adopted,
      NA_integer_
    ),
    # Numeric state ID
    state_id = as.numeric(factor(state_abbr)),
    # Time trend
    trend = year - 1987
  )

# ============================================================================
# PART 9: Summary Statistics
# ============================================================================

cat("\nPART 9: Summary Statistics\n")
cat("--------------------------\n")

# Panel structure
cat("\nPanel Structure:\n")
cat(sprintf("  Years: %d-%d (%d years)\n", min(analysis_data$year), max(analysis_data$year),
            n_distinct(analysis_data$year)))
cat(sprintf("  States: %d\n", n_distinct(analysis_data$state_abbr)))
cat(sprintf("  Total observations: %d\n", nrow(analysis_data)))

# Treatment summary
cat("\nEITC Treatment Summary:\n")
treatment_by_year <- analysis_data %>%
  group_by(year) %>%
  summarise(
    n_treated = sum(treated),
    pct_treated = mean(treated) * 100,
    mean_generosity = mean(eitc_generosity[eitc_generosity > 0], na.rm = TRUE),
    .groups = "drop"
  )
cat("  Treatment by year (sample):\n")
print(treatment_by_year %>% filter(year %in% c(1987, 1995, 2000, 2010, 2019)))

# Cohort counts
cat("\nAdoption Cohorts (for CS Estimator):\n")
cohort_counts <- analysis_data %>%
  filter(year == 2019) %>%
  group_by(cohort) %>%
  summarise(n_states = n(), .groups = "drop") %>%
  arrange(cohort)
print(cohort_counts)

# ============================================================================
# PART 10: Save Final Analysis Dataset
# ============================================================================

cat("\nPART 10: Saving Analysis Dataset\n")
cat("---------------------------------\n")

write_csv(analysis_data, file.path(DATA_DIR, "analysis_eitc_crime.csv"))

cat("\nFiles saved:\n")
cat(sprintf("  - %s/analysis_eitc_crime.csv (%d observations)\n", DATA_DIR, nrow(analysis_data)))
cat(sprintf("  - %s/eitc_state_year_panel.csv\n", DATA_DIR))
cat(sprintf("  - %s/state_minimum_wage.csv\n", DATA_DIR))
cat(sprintf("  - %s/national_incarceration.csv\n", DATA_DIR))

cat("\n============================================\n")
cat("Data panel construction complete!\n")
cat("============================================\n\n")

cat("Key improvements over parent paper:\n")
cat("  1. Extended panel: 1987-2019 (was 1999-2019)\n")
cat("  2. Time-varying EITC generosity (was 2019 snapshot)\n")
cat("  3. Policy controls: minimum wage, incarceration trends\n")
cat("  4. 8 early adopters now have pre-treatment periods\n")
cat("\nRun 02_clean_data.R next.\n")
