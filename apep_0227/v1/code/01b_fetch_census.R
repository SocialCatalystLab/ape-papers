## ============================================================================
## 01b_fetch_census.R — Fetch population and economic data with rate limiting
## APEP Working Paper apep_0225
## ============================================================================

source("00_packages.R")

data_dir <- "../data"

state_fips <- readRDS(file.path(data_dir, "state_fips.rds"))

## ---------------------------------------------------------------------------
## 1. Fetch Population Data from Census ACS with longer delays
## ---------------------------------------------------------------------------

cat("Fetching population data with extended rate-limit handling...\n")

pop_data <- list()
years_for_pop <- 2013:2023

for (yr in years_for_pop) {
  cat("  Population for", yr, "...")

  # Skip 2020 (1-year ACS not released due to COVID)
  if (yr == 2020) {
    cat(" skipped (no 2020 ACS 1-year)\n")
    next
  }

  url <- paste0(
    "https://api.census.gov/data/", yr, "/acs/acs1?get=NAME,B01003_001E&for=state:*"
  )

  success <- FALSE
  for (attempt in 1:5) {
    Sys.sleep(5 * attempt)  # Exponential backoff

    tryCatch({
      resp <- httr::GET(url, httr::timeout(30))

      if (httr::status_code(resp) == 200) {
        dat <- jsonlite::fromJSON(httr::content(resp, as = "text", encoding = "UTF-8"))
        header <- dat[1, ]
        body <- as_tibble(dat[-1, , drop = FALSE])
        names(body) <- header
        body <- body %>%
          mutate(
            year = yr,
            population = as.numeric(B01003_001E),
            state_fips = state
          ) %>%
          select(state_fips, year, population)
        pop_data[[as.character(yr)]] <- body
        cat(" OK (attempt", attempt, ")\n")
        success <- TRUE
        break
      } else {
        cat(" HTTP", httr::status_code(resp), "")
      }
    }, error = function(e) {
      cat(" error ")
    })
  }

  if (!success) {
    cat(" FAILED after 5 attempts\n")
  }
}

pop_df <- bind_rows(pop_data)

# If we're missing years, interpolate using available data
all_years <- 2013:2023
fetched_years <- unique(pop_df$year)
missing_years <- setdiff(all_years, fetched_years)

if (length(missing_years) > 0) {
  cat("Interpolating population for missing years:", paste(missing_years, collapse=", "), "\n")

  # For each state, use linear interpolation
  pop_complete <- pop_df %>%
    group_by(state_fips) %>%
    complete(year = all_years) %>%
    arrange(state_fips, year) %>%
    mutate(population = zoo::na.approx(population, year, na.rm = FALSE)) %>%
    # For extrapolation at edges, use nearest value
    fill(population, .direction = "downup") %>%
    ungroup()

  pop_df <- pop_complete
}

cat("Population records:", nrow(pop_df), "\n")
saveRDS(pop_df, file.path(data_dir, "state_population.rds"))

## ---------------------------------------------------------------------------
## 2. Fetch Economic Controls with same rate limiting
## ---------------------------------------------------------------------------

cat("\nFetching economic controls...\n")

econ_data <- list()

for (yr in years_for_pop) {
  if (yr == 2020) {
    cat("  ACS economic controls for", yr, "... skipped (no 2020 ACS 1-year)\n")
    next
  }

  cat("  ACS economic controls for", yr, "...")

  url <- paste0(
    "https://api.census.gov/data/", yr, "/acs/acs1?get=NAME,",
    "B17001_001E,B17001_002E,B23025_003E,B23025_005E,B19013_001E",
    "&for=state:*"
  )

  success <- FALSE
  for (attempt in 1:5) {
    Sys.sleep(5 * attempt)

    tryCatch({
      resp <- httr::GET(url, httr::timeout(30))

      if (httr::status_code(resp) == 200) {
        dat <- jsonlite::fromJSON(httr::content(resp, as = "text", encoding = "UTF-8"))
        header <- dat[1, ]
        body <- as_tibble(dat[-1, , drop = FALSE])
        names(body) <- header
        body <- body %>%
          mutate(
            year = yr,
            state_fips = state,
            poverty_total = as.numeric(B17001_001E),
            poverty_below = as.numeric(B17001_002E),
            labor_force = as.numeric(B23025_003E),
            unemployed = as.numeric(B23025_005E),
            median_income = as.numeric(B19013_001E),
            poverty_rate = poverty_below / poverty_total,
            unemp_rate = unemployed / labor_force
          ) %>%
          select(state_fips, year, poverty_rate, unemp_rate, median_income)
        econ_data[[as.character(yr)]] <- body
        cat(" OK (attempt", attempt, ")\n")
        success <- TRUE
        break
      } else {
        cat(" HTTP", httr::status_code(resp), "")
      }
    }, error = function(e) {
      cat(" error ")
    })
  }

  if (!success) {
    cat(" FAILED\n")
  }
}

econ_df <- bind_rows(econ_data)

# Interpolate missing years for economic controls too
if (nrow(econ_df) > 0) {
  econ_complete <- econ_df %>%
    group_by(state_fips) %>%
    complete(year = all_years) %>%
    arrange(state_fips, year) %>%
    mutate(
      poverty_rate = zoo::na.approx(poverty_rate, year, na.rm = FALSE),
      unemp_rate = zoo::na.approx(unemp_rate, year, na.rm = FALSE),
      median_income = zoo::na.approx(median_income, year, na.rm = FALSE)
    ) %>%
    fill(poverty_rate, unemp_rate, median_income, .direction = "downup") %>%
    ungroup()

  econ_df <- econ_complete
}

cat("Economic control records:", nrow(econ_df), "\n")
saveRDS(econ_df, file.path(data_dir, "state_econ_controls.rds"))

cat("\n=== Census data fetch complete ===\n")
