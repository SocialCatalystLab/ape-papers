## =============================================================================
## 01_fetch_data.R — Data Acquisition
## APEP-0369: Click to Prescribe
## =============================================================================

source("00_packages.R")

cat("=== Fetching data for APEP-0369 ===\n")

## ---------------------------------------------------------------------------
## 1. CDC VSRR Drug Overdose Deaths (2015-2024)
## ---------------------------------------------------------------------------

cat("Fetching CDC VSRR drug overdose data...\n")

# Indicators we need
indicators <- c(
  "Number of Drug Overdose Deaths",
  "Natural & semi-synthetic opioids (T40.2)",
  "Synthetic opioids, excl. methadone (T40.4)",
  "Opioids (T40.0-T40.4,T40.6)",
  "Heroin (T40.1)",
  "Cocaine (T40.5)",
  "Psychostimulants with abuse potential (T43.6)"
)

# Fetch from CDC Socrata API
base_url <- "https://data.cdc.gov/resource/xkb8-kh2a.json"

all_data <- list()
for (ind in indicators) {
  cat(sprintf("  Fetching: %s\n", ind))

  offset <- 0
  ind_data <- list()
  repeat {
    params <- list(
      `$where` = sprintf("indicator='%s' AND period='12 month-ending' AND month='December'", ind),
      `$limit` = 5000,
      `$offset` = offset
    )

    resp <- GET(base_url, query = params)

    if (status_code(resp) != 200) {
      warning(sprintf("API error for %s: %d", ind, status_code(resp)))
      break
    }

    batch <- fromJSON(content(resp, "text", encoding = "UTF-8"))
    if (length(batch) == 0 || nrow(batch) == 0) break

    ind_data[[length(ind_data) + 1]] <- batch
    offset <- offset + 5000
    if (nrow(batch) < 5000) break
  }

  if (length(ind_data) > 0) {
    all_data[[ind]] <- bind_rows(ind_data)
  }
}

# Combine
cdc_raw <- bind_rows(all_data)
cat(sprintf("  Total CDC records: %d\n", nrow(cdc_raw)))

# Save raw data
saveRDS(cdc_raw, "../data/cdc_vsrr_raw.rds")

## ---------------------------------------------------------------------------
## 2. EPCS Mandate Dates (compiled from RXNT/legislative records)
## ---------------------------------------------------------------------------

cat("Creating EPCS mandate dataset...\n")

# State FIPS codes
state_fips <- data.frame(
  state_abbr = c("AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA",
                  "HI","ID","IL","IN","IA","KS","KY","LA","ME","MD",
                  "MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ",
                  "NM","NY","NC","ND","OH","OK","OR","PA","RI","SC",
                  "SD","TN","TX","UT","VT","VA","WA","WV","WI","WY","DC"),
  state_fips = c(1,2,4,5,6,8,9,10,12,13,
                 15,16,17,18,19,20,21,22,23,24,
                 25,26,27,28,29,30,31,32,33,34,
                 35,36,37,38,39,40,41,42,44,45,
                 46,47,48,49,50,51,53,54,55,56,11),
  state_name = c("Alabama","Alaska","Arizona","Arkansas","California",
                 "Colorado","Connecticut","Delaware","Florida","Georgia",
                 "Hawaii","Idaho","Illinois","Indiana","Iowa","Kansas",
                 "Kentucky","Louisiana","Maine","Maryland",
                 "Massachusetts","Michigan","Minnesota","Mississippi",
                 "Missouri","Montana","Nebraska","Nevada","New Hampshire",
                 "New Jersey","New Mexico","New York","North Carolina",
                 "North Dakota","Ohio","Oklahoma","Oregon","Pennsylvania",
                 "Rhode Island","South Carolina","South Dakota","Tennessee",
                 "Texas","Utah","Vermont","Virginia","Washington",
                 "West Virginia","Wisconsin","Wyoming","District of Columbia"),
  stringsAsFactors = FALSE
)

# EPCS mandate effective dates (compiled from RXNT.com and state legislation)
# Year the mandate took effect (0 = never-treated as of 2024)
epcs_mandates <- data.frame(
  state_abbr = c(
    # Treated states (34)
    "MN", "NY", "ME", "CT", "PA",
    "AZ", "IA", "NC", "OK", "RI", "VA",
    "AR", "DE", "KY", "MA", "MI", "MO", "NV", "NM", "SC", "TN", "TX", "FL", "KS", "WY",
    "CA", "IN", "NE", "NH", "UT", "WA",
    "MD", "CO", "IL",
    # Never-treated states (17)
    "AL", "AK", "GA", "HI", "ID", "LA", "MS", "MT", "NJ", "ND", "OH", "OR", "SD", "VT", "WV", "WI", "DC"
  ),
  epcs_mandate_year = c(
    # Treated
    2011, 2016, 2017, 2018, 2019,
    2020, 2020, 2020, 2020, 2020, 2020,
    2021, 2021, 2021, 2021, 2021, 2021, 2021, 2021, 2021, 2021, 2021, 2021, 2021, 2021,
    2022, 2022, 2022, 2022, 2022, 2022,
    2023, 2023, 2024,
    # Never-treated (coded as 0 for did package)
    rep(0, 17)
  ),
  stringsAsFactors = FALSE
)

# Merge with FIPS
epcs_mandates <- merge(epcs_mandates, state_fips, by = "state_abbr")
cat(sprintf("  EPCS mandate data: %d states (%d treated, %d never-treated)\n",
            nrow(epcs_mandates),
            sum(epcs_mandates$epcs_mandate_year > 0),
            sum(epcs_mandates$epcs_mandate_year == 0)))

saveRDS(epcs_mandates, "../data/epcs_mandates.rds")

## ---------------------------------------------------------------------------
## 3. State Population Data from Census (for rate calculation)
## ---------------------------------------------------------------------------

cat("Fetching state population data from Census...\n")

pop_data <- list()
for (yr in 2015:2023) {
  cat(sprintf("  Year: %d\n", yr))

  # Use Census Population Estimates API
  if (yr >= 2020) {
    url <- sprintf("https://api.census.gov/data/%d/pep/population?get=POP_2020_BASE,NAME&for=state:*", yr)
    # Try vintage API
    url <- sprintf("https://api.census.gov/data/%d/pep/natmonthly?get=POP,NAME&for=state:*&MONTHLY=7", yr)
  }

  # Simpler approach: use ACS 1-year total population
  url <- sprintf("https://api.census.gov/data/%d/acs/acs1?get=B01001_001E,NAME&for=state:*", yr)

  tryCatch({
    resp <- GET(url)
    if (status_code(resp) == 200) {
      raw <- fromJSON(content(resp, "text", encoding = "UTF-8"))
      df <- as.data.frame(raw[-1, ], stringsAsFactors = FALSE)
      names(df) <- raw[1, ]
      df$year <- yr
      df$population <- as.numeric(df$B01001_001E)
      df$state_fips <- as.integer(df$state)
      pop_data[[as.character(yr)]] <- df[, c("NAME", "state_fips", "year", "population")]
    } else {
      warning(sprintf("Census API error for %d: %d", yr, status_code(resp)))
    }
  }, error = function(e) {
    warning(sprintf("Failed for year %d: %s", yr, e$message))
  })

  Sys.sleep(0.5)  # Rate limit
}

pop_df <- bind_rows(pop_data)
cat(sprintf("  Population data: %d state-years\n", nrow(pop_df)))

saveRDS(pop_df, "../data/state_population.rds")

## ---------------------------------------------------------------------------
## 4. FRED State Unemployment Rate (control variable)
## ---------------------------------------------------------------------------

cat("Fetching state unemployment data from FRED...\n")

fred_key <- Sys.getenv("FRED_API_KEY")
if (nchar(fred_key) == 0) {
  warning("FRED_API_KEY not set. Skipping unemployment data.")
} else {
  # State unemployment rate series IDs follow pattern: [ST]UR
  state_ur_series <- paste0(state_fips$state_abbr, "UR")
  # DC is DCUR

  unemp_data <- list()
  for (i in seq_along(state_ur_series)) {
    series_id <- state_ur_series[i]
    st <- state_fips$state_abbr[i]

    url <- sprintf(
      "https://api.stlouisfed.org/fred/series/observations?series_id=%s&api_key=%s&file_type=json&observation_start=2010-01-01&observation_end=2024-12-31&frequency=a",
      series_id, fred_key
    )

    tryCatch({
      resp <- GET(url)
      if (status_code(resp) == 200) {
        raw <- fromJSON(content(resp, "text", encoding = "UTF-8"))
        if (!is.null(raw$observations) && nrow(raw$observations) > 0) {
          obs <- raw$observations
          obs$state_abbr <- st
          obs$year <- as.integer(substr(obs$date, 1, 4))
          obs$unemployment_rate <- as.numeric(obs$value)
          unemp_data[[st]] <- obs[, c("state_abbr", "year", "unemployment_rate")]
        }
      }
    }, error = function(e) {
      # Skip silently
    })

    Sys.sleep(0.2)
  }

  unemp_df <- bind_rows(unemp_data)
  cat(sprintf("  Unemployment data: %d state-years\n", nrow(unemp_df)))
  saveRDS(unemp_df, "../data/state_unemployment.rds")
}

## ---------------------------------------------------------------------------
## 5. PDMP Must-Access Mandate Dates (concurrent policy control)
## ---------------------------------------------------------------------------

cat("Creating PDMP mandate control variable...\n")

# Must-access PDMP mandate dates (from Buchmueller & Carey 2018; PDAPS; updated)
pdmp_mandates <- data.frame(
  state_abbr = c(
    "KY", "NM", "OH", "TN", "WV",   # 2012
    "NV",                              # 2013
    "NY", "VT",                        # 2013
    "MA",                              # 2014
    "VA",                              # 2015
    "CT", "IN", "NJ", "PA", "RI",     # 2016
    "AR", "AZ", "CO", "DE", "IL", "ME", "MD", "MN", "MS", "OK", "SC", "WI", # 2017-2018
    "CA", "FL", "GA", "IA", "KS", "LA", "MI", "MO", "MT", "NC", "NE", "NH", "OR", "SD", "TX", "UT", "WA", "WY" # 2018-2021
  ),
  pdmp_mandate_year = c(
    rep(2012, 5), 2013, 2013, 2013, 2014, 2015,
    rep(2016, 5),
    2017, 2017, 2018, 2018, 2018, 2018, 2018, 2018, 2018, 2018, 2018, 2018,
    2018, 2018, 2018, 2019, 2019, 2019, 2019, 2019, 2019, 2020, 2020, 2020, 2020, 2020, 2021, 2021, 2021, 2021
  ),
  stringsAsFactors = FALSE
)

saveRDS(pdmp_mandates, "../data/pdmp_mandates.rds")

cat("\n=== Data fetching complete ===\n")
cat("Files saved to ../data/\n")
