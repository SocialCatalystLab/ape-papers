# ============================================================================
# Paper 105: State EITC Generosity and Property Crime
# Script: 01_fetch_data.R - Data Acquisition
# ============================================================================

source("00_packages.R")

cat("Fetching data for Paper 105 (EITC-Crime Analysis)...\n\n")

# ============================================================================
# PART 1: State EITC Policy Database
# ============================================================================

cat("Creating state EITC policy database...\n")

# State EITC adoption dates and generosity (% of federal credit)
# Source: Tax Policy Center, NCSL, state tax agencies
# Note: Generosity may change over time - using 2019 values for cross-section
eitc_policy <- tribble(
  ~state_abbr, ~state_name, ~eitc_adopted, ~eitc_pct_2019, ~refundable,
  "CA", "California", 2015, 85, TRUE,
  "CO", "Colorado", 1999, 10, TRUE,
  "CT", "Connecticut", 2011, 30.5, TRUE,
  "DC", "District of Columbia", 2000, 40, TRUE,
  "DE", "Delaware", 2006, 20, FALSE,
  "HI", "Hawaii", 2018, 20, FALSE,
  "IL", "Illinois", 2000, 18, TRUE,
  "IN", "Indiana", 1999, 9, TRUE,  # Non-refundable until 2023
  "IA", "Iowa", 2007, 15, TRUE,
  "KS", "Kansas", 1998, 17, TRUE,
  "LA", "Louisiana", 2008, 5, TRUE,
  "ME", "Maine", 2000, 5, FALSE,
  "MD", "Maryland", 1987, 28, TRUE,  # Both refundable and non-refundable portions
  "MA", "Massachusetts", 1997, 30, TRUE,
  "MI", "Michigan", 2008, 6, TRUE,
  "MN", "Minnesota", 1991, NA, TRUE,  # Uses own formula, not % of federal
  "MT", "Montana", 2019, 3, TRUE,
  "NE", "Nebraska", 2006, 10, TRUE,
  "NJ", "New Jersey", 2000, 40, TRUE,
  "NM", "New Mexico", 2007, 17, TRUE,  # Increased from 10% to 17%
  "NY", "New York", 1994, 30, TRUE,
  "OH", "Ohio", 2013, 30, FALSE,
  "OK", "Oklahoma", 2002, 5, TRUE,
  "OR", "Oregon", 1997, 12, TRUE,  # Basic rate, higher for kids <3
  "RI", "Rhode Island", 2001, 15, TRUE,
  "SC", "South Carolina", 2018, 104.17, FALSE,  # Non-refundable, up to 104.17% of federal
  "VT", "Vermont", 1988, 36, TRUE,
  "VA", "Virginia", 2004, 20, FALSE,
  "WA", "Washington", 2023, 50, TRUE,  # After our sample period
  "WI", "Wisconsin", 1989, NA, TRUE  # Uses formula based on # kids, not % of federal
) %>%
  mutate(
    eitc_adopted = as.integer(eitc_adopted),
    # For states with formula-based EITC, impute approximate equivalent %
    eitc_pct_2019 = case_when(
      state_abbr == "MN" ~ 25,  # Approximate
      state_abbr == "WI" ~ 11,  # Approximate average
      TRUE ~ eitc_pct_2019
    )
  )

# Create state-year panel with EITC treatment
years <- 1999:2019
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
  left_join(eitc_policy %>% select(state_abbr, eitc_adopted, eitc_pct_2019, refundable),
            by = "state_abbr") %>%
  mutate(
    # Binary treatment: State has EITC in this year
    has_eitc = if_else(!is.na(eitc_adopted) & year >= eitc_adopted, 1L, 0L),
    # Continuous treatment: Generosity (% of federal), 0 for non-EITC states
    eitc_generosity = if_else(has_eitc == 1, coalesce(eitc_pct_2019, 0), 0),
    # High EITC: >10% of federal
    high_eitc = if_else(eitc_generosity > 10, 1L, 0L),
    # First treatment year for CS estimator
    first_treat = if_else(!is.na(eitc_adopted) & eitc_adopted >= 1999,
                          eitc_adopted, NA_integer_)
  )

# Save EITC panel
write_csv(eitc_policy, file.path(DATA_DIR, "eitc_policy.csv"))
write_csv(eitc_panel, file.path(DATA_DIR, "eitc_state_year_panel.csv"))

cat(sprintf("  Saved EITC policy data: %d states with EITC by 2019\n", nrow(eitc_policy)))
cat(sprintf("  Panel: %d state-year observations\n", nrow(eitc_panel)))

# ============================================================================
# PART 2: FBI UCR Crime Data
# ============================================================================

cat("\nFetching FBI UCR crime data...\n")

# FBI Crime Data Explorer API
# Note: The API provides JSON data by state and year
# https://cde.ucr.cjis.gov/LATEST/webapp/#/pages/docApi

# Function to fetch state crime data
fetch_ucr_state <- function(state_abbr, year) {
  # UCR Crime Data Explorer API endpoint
  # For state-level estimated crime totals
  base_url <- "https://api.usa.gov/crime/fbi/cde/estimate/state"

  url <- sprintf("%s/%s?year=%d&API_KEY=iiHnOKfno2Mgkt5AynpvPpUQTEyxE77jo1RU8PIv",
                 base_url, state_abbr, year)

  tryCatch({
    response <- GET(url, timeout(30))
    if (status_code(response) == 200) {
      content <- fromJSON(content(response, "text", encoding = "UTF-8"))
      if (length(content$results) > 0) {
        df <- as.data.frame(content$results)
        df$state_abbr <- state_abbr
        return(df)
      }
    }
    return(NULL)
  }, error = function(e) {
    return(NULL)
  })
}

# Alternative: Use pre-compiled UCR data from Kaplan's repository
# Jacob Kaplan maintains clean UCR data at: https://jacobdkaplan.com/data/
cat("  Attempting FBI API...\n")

# Test API with one state-year
test_result <- fetch_ucr_state("CA", 2019)

if (!is.null(test_result) && nrow(test_result) > 0) {
  cat("  FBI API working. Fetching all states...\n")

  ucr_data <- list()
  total <- length(state_fips_map$state_abbr) * length(years)
  count <- 0

  for (yr in years) {
    for (st in state_fips_map$state_abbr) {
      count <- count + 1
      if (count %% 100 == 0) {
        cat(sprintf("    Progress: %d/%d...\n", count, total))
      }

      result <- fetch_ucr_state(st, yr)
      if (!is.null(result)) {
        result$year <- yr
        ucr_data[[length(ucr_data) + 1]] <- result
      }
      Sys.sleep(0.05)  # Rate limiting
    }
  }

  if (length(ucr_data) > 0) {
    crime_df <- rbindlist(ucr_data, fill = TRUE)
    cat(sprintf("  Retrieved %d state-year observations from FBI API\n", nrow(crime_df)))
  }
} else {
  cat("  FBI API not responding. Using backup data source...\n")

  # Backup: Use UCR property crime rates from historical compilation
  # These are estimates from FBI's Crime in the United States publications

  # Property crime rates per 100,000 by state and year (selected years for demonstration)
  # In real analysis, would use full Jacob Kaplan dataset or ICPSR download

  cat("  Creating state-level property crime panel from historical UCR summaries...\n")

  # Load from pre-compiled source or create from available data
  # Using National Archive of Criminal Justice Data (NACJD) format

  # For demonstration, fetch from openICPSR or direct UCR tables
  # Since no direct API, we'll construct from known FBI published totals

  # FBI publishes state crime rates in annual reports
  # These can be scraped or obtained from NACJD Study 4720

  # Placeholder: Create empty crime dataframe to be filled
  crime_df <- data.frame(
    state_abbr = character(),
    year = integer(),
    population = numeric(),
    property_crime_rate = numeric(),
    burglary_rate = numeric(),
    larceny_rate = numeric(),
    mvt_rate = numeric()
  )
}

# ============================================================================
# PART 3: Alternative - Use NACJD UCR Data (Pre-compiled)
# ============================================================================

cat("\nChecking for pre-compiled UCR data sources...\n")

# Try fetching from the USA.gov crime API with different endpoint
fetch_crime_estimates <- function() {
  # CDE Summary endpoint for national/state estimates
  url <- "https://api.usa.gov/crime/fbi/cde/estimate/state/CA?from=1999&to=2019&API_KEY=iiHnOKfno2Mgkt5AynpvPpUQTEyxE77jo1RU8PIv"

  tryCatch({
    response <- GET(url, timeout(60))
    if (status_code(response) == 200) {
      content <- fromJSON(content(response, "text", encoding = "UTF-8"))
      return(content)
    }
    return(NULL)
  }, error = function(e) {
    cat(sprintf("    API error: %s\n", e$message))
    return(NULL)
  })
}

# Test the time-series endpoint
ca_data <- fetch_crime_estimates()

if (!is.null(ca_data)) {
  cat("  Time-series API working.\n")

  # Fetch all states
  fetch_state_series <- function(state_abbr) {
    url <- sprintf(
      "https://api.usa.gov/crime/fbi/cde/estimate/state/%s?from=1999&to=2019&API_KEY=iiHnOKfno2Mgkt5AynpvPpUQTEyxE77jo1RU8PIv",
      state_abbr
    )

    tryCatch({
      response <- GET(url, timeout(30))
      if (status_code(response) == 200) {
        content <- fromJSON(content(response, "text", encoding = "UTF-8"))
        if (length(content$results) > 0) {
          df <- as.data.frame(content$results)
          df$state_abbr <- state_abbr
          return(df)
        }
      }
      return(NULL)
    }, error = function(e) {
      return(NULL)
    })
  }

  cat("  Fetching state crime time series...\n")
  crime_list <- list()
  for (st in state_fips_map$state_abbr) {
    result <- fetch_state_series(st)
    if (!is.null(result) && nrow(result) > 0) {
      crime_list[[st]] <- result
    }
    Sys.sleep(0.1)
  }

  if (length(crime_list) > 0) {
    crime_df <- rbindlist(crime_list, fill = TRUE)
    cat(sprintf("  Retrieved crime data for %d states\n", length(crime_list)))
  }
}

# ============================================================================
# PART 4: Construct Final Analysis Dataset
# ============================================================================

cat("\nConstructing analysis dataset...\n")

if (nrow(crime_df) > 0) {
  # Clean and standardize crime data
  crime_clean <- crime_df %>%
    mutate(
      year = as.integer(year),
      population = as.numeric(population)
    ) %>%
    select(
      state_abbr, year, population,
      matches("burglary|larceny|motor_vehicle|property")
    )

  # Merge with EITC treatment
  analysis_data <- eitc_panel %>%
    left_join(crime_clean, by = c("state_abbr", "year")) %>%
    filter(!is.na(population))

  # Calculate per capita rates if not already rates
  if ("property_crime" %in% names(analysis_data)) {
    analysis_data <- analysis_data %>%
      mutate(
        property_crime_rate = property_crime / population * 100000,
        burglary_rate = burglary / population * 100000,
        larceny_rate = larceny_theft / population * 100000,
        mvt_rate = motor_vehicle_theft / population * 100000,
        log_property_crime_rate = log(property_crime_rate + 1),
        log_burglary_rate = log(burglary_rate + 1),
        log_larceny_rate = log(larceny_rate + 1),
        log_mvt_rate = log(mvt_rate + 1)
      )
  }

  # Save analysis dataset
  write_csv(analysis_data, file.path(DATA_DIR, "analysis_eitc_crime.csv"))
  cat(sprintf("  Saved analysis dataset: %d observations\n", nrow(analysis_data)))
} else {
  cat("\n========================================\n")
  cat("WARNING: Crime data fetch unsuccessful.\n")
  cat("The analysis requires UCR crime data.\n")
  cat("========================================\n\n")

  cat("Options to obtain data:\n")
  cat("1. Download from NACJD/ICPSR: https://www.icpsr.umich.edu/web/NACJD/studies/37059\n")
  cat("2. Use Jacob Kaplan's cleaned data: https://jacobdkaplan.com/data/\n")
  cat("3. Download from FBI Crime Data Explorer: https://cde.ucr.cjis.gov/\n")

  # Save EITC-only panel for now
  write_csv(eitc_panel, file.path(DATA_DIR, "analysis_eitc_only.csv"))
  cat("  Saved EITC panel (without crime data)\n")
}

# ============================================================================
# PART 5: Summary
# ============================================================================

cat("\n============================================\n")
cat("Data acquisition complete!\n")
cat("============================================\n\n")

cat("Files created:\n")
cat(sprintf("  - %s/eitc_policy.csv\n", DATA_DIR))
cat(sprintf("  - %s/eitc_state_year_panel.csv\n", DATA_DIR))
if (file.exists(file.path(DATA_DIR, "analysis_eitc_crime.csv"))) {
  cat(sprintf("  - %s/analysis_eitc_crime.csv\n", DATA_DIR))
}

cat("\nData summary:\n")
cat(sprintf("  States with EITC by 2019: %d\n", sum(!is.na(eitc_policy$eitc_adopted))))
cat(sprintf("  Sample period: 1999-2019\n"))
cat(sprintf("  State-years: %d\n", nrow(eitc_panel)))
