## 01_fetch_data.R — Fetch labor market data and compile PDMP mandate dates
## Paper 109: Must-Access PDMP Mandates and Prime-Age Labor Force Participation

library(httr)
library(jsonlite)
library(tidyverse)

data_dir <- file.path(dirname(getwd()), "data")
dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)

###############################################################################
## PART 1: State-level labor force data from BLS LAUS API
###############################################################################

cat("=== PART 1: BLS LAUS State-Level Labor Force Data ===\n")

# BLS LAUS provides monthly state-level labor force, employment, unemployment
# Series ID structure: LASST{FIPS}0000000000003 = labor force level
#                      LASST{FIPS}0000000000005 = employment level
#                      LASST{FIPS}0000000000006 = unemployment rate

state_fips_map <- tribble(
  ~statefip, ~abbr,
  1,  "AL",  2,  "AK",  4,  "AZ",  5,  "AR",  6,  "CA",
  8,  "CO",  9,  "CT", 10,  "DE", 12,  "FL",
  13, "GA",  15, "HI",  16, "ID",  17, "IL",  18, "IN",
  19, "IA",  20, "KS",  21, "KY",  22, "LA",  23, "ME",
  24, "MD",  25, "MA",  26, "MI",  27, "MN",  28, "MS",
  29, "MO",  30, "MT",  31, "NE",  32, "NV",  33, "NH",
  34, "NJ",  35, "NM",  36, "NY",  37, "NC",  38, "ND",
  39, "OH",  40, "OK",  41, "OR",  42, "PA",  44, "RI",
  45, "SC",  46, "SD",  47, "TN",  48, "TX",  49, "UT",
  50, "VT",  51, "VA",  53, "WA",  54, "WV",  55, "WI",
  56, "WY"
)

bls_url <- "https://api.bls.gov/publicAPI/v2/timeseries/data/"

fetch_bls_chunk <- function(series_ids, start_year, end_year) {
  payload <- toJSON(
    list(
      seriesid = series_ids,
      startyear = as.character(start_year),
      endyear = as.character(end_year)
    ),
    auto_unbox = TRUE
  )

  resp <- POST(bls_url,
               body = payload,
               content_type_json(),
               timeout(60))

  if (status_code(resp) == 200) {
    result <- fromJSON(content(resp, "text", encoding = "UTF-8"),
                       simplifyVector = FALSE)
    if (result$status == "REQUEST_SUCCEEDED") {
      return(result$Results$series)
    }
  }
  return(NULL)
}

parse_bls_series <- function(series_list) {
  rows <- list()
  for (s in series_list) {
    sid <- s$seriesID
    for (d in s$data) {
      if (d$period != "M13") {  # Skip annual average
        rows[[length(rows) + 1]] <- list(
          series_id = sid,
          year = as.integer(d$year),
          period = d$period,
          value = as.numeric(gsub(",", "", d$value))
        )
      }
    }
  }
  bind_rows(rows)
}

# Build series IDs for all states
# LAUS series code endings:
# 003 = Unemployment rate (%)
# 005 = Employment (level)
# 006 = Labor force (level)
# Note: series 03 (unemp rate) and 05 (employment) are reliably available
lf_series <- sprintf("LASST%02d0000000000003", state_fips_map$statefip)  # Unemp rate
emp_series <- sprintf("LASST%02d0000000000005", state_fips_map$statefip)  # Employment level

all_bls <- list()

# BLS public API: max 50 series per request, 20-year span
# We need 51 states * 2 metrics = 102 series => need 3 requests per time chunk
# Time span 2007-2023 = 17 years, fits in one chunk per request

cat("Fetching BLS LAUS data (multiple API calls due to 10-year limit)...\n")

# BLS public API: max 50 series, max 10 years per request
# Split into: 2007-2016 and 2017-2023, and 2 halves of states
request_idx <- 1

for (yr_start in c(2007, 2017)) {
  yr_end <- min(yr_start + 9, 2023)

  for (series_set in list(
    list(ids = lf_series[1:25], label = "LF 1-25"),
    list(ids = lf_series[26:51], label = "LF 26-51"),
    list(ids = emp_series[1:25], label = "Emp 1-25"),
    list(ids = emp_series[26:51], label = "Emp 26-51")
  )) {
    chunk <- fetch_bls_chunk(series_set$ids, yr_start, yr_end)
    if (!is.null(chunk)) {
      all_bls[[request_idx]] <- parse_bls_series(chunk)
      cat(sprintf("  Request %d (%s, %d-%d): OK - %d obs\n",
                  request_idx, series_set$label, yr_start, yr_end,
                  nrow(all_bls[[request_idx]])))
    } else {
      cat(sprintf("  Request %d (%s, %d-%d): FAILED\n",
                  request_idx, series_set$label, yr_start, yr_end))
    }
    request_idx <- request_idx + 1
    Sys.sleep(2)  # Rate limit
  }
}

bls_raw <- bind_rows(all_bls)
cat(sprintf("Total BLS observations: %d\n", nrow(bls_raw)))

# Parse state FIPS from series ID and classify measure
bls_parsed <- bls_raw %>%
  mutate(
    statefip = as.integer(substr(series_id, 6, 7)),
    measure = ifelse(grepl("03$", series_id), "unemp_rate", "employment"),
    month = as.integer(sub("M", "", period))
  )

# Get annual March values (to match CPS ASEC timing) and annual averages
bls_march <- bls_parsed %>%
  filter(month == 3) %>%
  select(statefip, year, measure, value) %>%
  pivot_wider(names_from = measure, values_from = value) %>%
  mutate(
    lfp_thousands = labor_force,
    emp_thousands = employment,
    unemp_thousands = labor_force - employment
  )

bls_annual <- bls_parsed %>%
  group_by(statefip, year, measure) %>%
  summarise(value = mean(value, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = measure, values_from = value) %>%
  rename(labor_force_annual = labor_force, employment_annual = employment)

cat(sprintf("BLS March values: %d state-years\n", nrow(bls_march)))
cat(sprintf("BLS Annual averages: %d state-years\n", nrow(bls_annual)))

###############################################################################
## PART 1b: State-level population data from Census API (for LFP rates)
###############################################################################

cat("\n=== PART 1b: Census Population Estimates ===\n")

# We need working-age population to compute LFP rates
# Census Population Estimates API provides age/sex/race breakdowns by state

fetch_pop_estimates <- function(year) {
  # Census PEP API for state-level population by age
  if (year >= 2020) {
    # Post-2020 census vintage
    url <- sprintf(
      "https://api.census.gov/data/%d/pep/natmonthly?get=POP&for=state:*",
      year
    )
  } else if (year >= 2015) {
    url <- sprintf(
      "https://api.census.gov/data/%d/pep/charagegroups?get=POP&AGEGROUP=0&for=state:*",
      year
    )
  } else {
    # Older vintage - intercensal estimates
    url <- sprintf(
      "https://api.census.gov/data/%d/pep/charagegroups?get=POP&AGEGROUP=0&for=state:*",
      year
    )
  }

  tryCatch({
    resp <- GET(url, timeout(30))
    if (status_code(resp) == 200) {
      dat <- fromJSON(content(resp, "text", encoding = "UTF-8"))
      df <- as.data.frame(dat[-1, ], stringsAsFactors = FALSE)
      colnames(df) <- dat[1, ]
      return(df)
    }
    return(NULL)
  }, error = function(e) NULL)
}

# Since Census PEP API is complex for age-specific data, use a simpler approach:
# Compute LFP rate as (labor force / civilian noninstitutional population 16+)
# BLS LAUS already gives us LF and employment levels
# We can also get LFP rate directly from BLS

# Fetch unemployment rate series (series 06)
cat("Fetching unemployment rate series...\n")
ur_series_ids <- sprintf("LASST%02d0000000000003", state_fips_map$statefip)

ur_bls <- list()
ur_idx <- 1
for (yr_start in c(2007, 2017)) {
  yr_end <- min(yr_start + 9, 2023)
  for (half in list(1:25, 26:51)) {
    chunk <- fetch_bls_chunk(ur_series_ids[half], yr_start, yr_end)
    if (!is.null(chunk)) {
      ur_bls[[ur_idx]] <- parse_bls_series(chunk)
      cat(sprintf("  UR chunk %d (%d-%d): %d obs\n", ur_idx, yr_start, yr_end, nrow(ur_bls[[ur_idx]])))
    }
    ur_idx <- ur_idx + 1
    Sys.sleep(2)
  }
}

ur_raw <- bind_rows(ur_bls)
cat(sprintf("  Unemployment rate obs: %d\n", nrow(ur_raw)))

ur_march <- ur_raw %>%
  mutate(
    statefip = as.integer(substr(series_id, 6, 7)),
    month = as.integer(sub("M", "", period))
  ) %>%
  filter(month == 3) %>%
  select(statefip, year, unemp_rate = value)

# For LFP rate, we use the labor_force / employment ratio and unemp rate
# LAUS provides labor force (LF) and employment (E) in thousands
# LFP rate = LF / CivPop * 100
# We can derive CivPop from unemp_rate: unemp_rate = (LF - E) / LF * 100
# which is already in our data. For LFP *rate* we need population.
# Use employment-population ratio: emp_pop_ratio = E / CivPop * 100
# CivPop = LF / (1 - (1 - unemp_rate/100)) ... circular
# Instead, use log(labor_force) as our primary outcome (levels)
# This avoids needing population denominators

# Merge all BLS data
bls_state <- bls_march %>%
  left_join(ur_march, by = c("statefip", "year")) %>%
  left_join(bls_annual, by = c("statefip", "year")) %>%
  mutate(
    log_lf = log(labor_force),
    log_emp = log(employment),
    emp_lf_ratio = employment / labor_force * 100  # = 100 - unemp_rate
  )

cat(sprintf("\nFinal BLS state-year panel: %d observations\n", nrow(bls_state)))
cat(sprintf("Years: %d - %d\n", min(bls_state$year), max(bls_state$year)))
cat(sprintf("States: %d\n", n_distinct(bls_state$statefip)))

saveRDS(bls_state, file.path(data_dir, "bls_state_panel.rds"))
cat("Saved BLS state panel to data/bls_state_panel.rds\n")

###############################################################################
## PART 2: PDMP Must-Access Mandate Dates
###############################################################################

cat("\n=== PART 2: PDMP Must-Access Mandate Dates ===\n")

# Compile must-access PDMP mandate effective dates
# Sources: PDAPS, Horwitz et al. (2018), Buchmueller & Carey (2018), FSMB, Pew
# "Must-access" = prescriber must query PDMP before prescribing controlled substances
# Full-exposure year: first full calendar year under mandate

pdmp_mandates <- tribble(
  ~state_abbr, ~statefip, ~mandate_effective_date, ~mandate_year_full_exposure,
  "KY",  21, "2012-07-20", 2013,
  "WV",  54, "2012-06-08", 2013,
  "NM",  35, "2012-07-01", 2013,
  "TN",  47, "2013-04-01", 2014,
  "NY",  36, "2013-08-27", 2014,
  "VT",  50, "2013-07-01", 2014,
  "IN",  18, "2014-07-01", 2015,
  "MA",  25, "2014-07-01", 2015,
  "CO",  8,  "2014-07-15", 2015,
  "LA",  22, "2014-08-01", 2015,
  "OH",  39, "2015-04-01", 2016,
  "NV",  32, "2015-10-01", 2016,
  "VA",  51, "2015-07-01", 2016,
  "CT",  9,  "2015-10-01", 2016,
  "NJ",  34, "2015-11-01", 2016,
  "OK",  40, "2015-11-01", 2016,
  "RI",  44, "2016-03-01", 2017,
  "PA",  42, "2017-01-01", 2017,
  "AK",  2,  "2017-01-01", 2017,
  "AR",  5,  "2017-01-01", 2017,
  "SC",  45, "2017-05-19", 2018,
  "WI",  55, "2017-04-01", 2018,
  "AZ",  4,  "2017-10-16", 2018,
  "UT",  49, "2017-05-09", 2018,
  "WA",  53, "2017-10-06", 2018,
  "ME",  23, "2017-07-01", 2018,
  "IL",  17, "2018-01-01", 2018,
  "NC",  37, "2018-01-01", 2018,
  "OR",  41, "2018-01-01", 2018,
  "FL",  12, "2018-07-01", 2019,
  "GA",  13, "2018-07-01", 2019,
  "IA",  19, "2018-07-01", 2019,
  "MI",  26, "2018-06-01", 2019,
  "MS",  28, "2018-07-01", 2019,
  "ND",  38, "2018-08-01", 2019,
  "DE",  10, "2018-03-28", 2019,
  "HI",  15, "2018-07-01", 2019,
  "MD",  24, "2018-07-01", 2019,
  "MN",  27, "2019-01-01", 2019,
  "AL",  1,  "2019-01-01", 2019,
  "TX",  48, "2019-09-01", 2020,
  "CA",   6, "2018-10-02", 2019,  # CURES 2.0 mandatory consultation
  "NH",  33, "2017-01-01", 2017,  # RSA 318-B mandatory query
  "MT",  30, "2019-10-01", 2020,  # HB 86 mandatory PDMP use
  "ID",  16, "2020-10-01", 2021,  # Idaho Code 37-2722(f)
  "WY",  56, "2020-01-01", 2021   # WY SF0047 mandatory query
)

# Never-treated states (no comprehensive must-access mandate by end 2023)
# Missouri: last state to implement statewide PDMP (Dec 2023, not must-access)
# Kansas, Nebraska, South Dakota: Medicaid-only PDMP requirements, no universal mandate
never_treated <- tribble(
  ~state_abbr, ~statefip,
  "KS",  20,
  "MO",  29,
  "NE",  31,
  "SD",  46
)
never_treated$mandate_effective_date <- NA_character_
never_treated$mandate_year_full_exposure <- 0

all_states_pdmp <- bind_rows(pdmp_mandates, never_treated) %>%
  arrange(statefip)

cat(sprintf("Treated states: %d\n", nrow(pdmp_mandates)))
cat(sprintf("Never-treated states: %d\n", nrow(never_treated)))

# Adoption cohort distribution
cat("\nAdoption Cohort Sizes:\n")
pdmp_mandates %>%
  count(mandate_year_full_exposure, name = "n_states") %>%
  arrange(mandate_year_full_exposure) %>%
  print()

saveRDS(all_states_pdmp, file.path(data_dir, "pdmp_mandate_dates.rds"))
write_csv(all_states_pdmp, file.path(data_dir, "pdmp_mandate_dates.csv"))
cat("Saved PDMP mandate dates.\n")

###############################################################################
## PART 3: Concurrent Policy Dates
###############################################################################

cat("\n=== PART 3: Concurrent Policy Dates ===\n")

medicaid_expansion <- tribble(
  ~statefip, ~medicaid_expansion_year,
  4, 2014, 5, 2014, 6, 2014, 8, 2014, 9, 2014,
  10, 2014, 11, 2014, 15, 2014, 17, 2014, 18, 2015,
  19, 2014, 21, 2014, 22, 2016, 23, 2019, 24, 2014,
  25, 2014, 26, 2014, 27, 2014, 30, 2016, 32, 2014,
  34, 2014, 35, 2014, 36, 2014, 38, 2014, 39, 2014,
  41, 2014, 42, 2015, 44, 2014, 50, 2014, 51, 2019,
  53, 2014, 54, 2014, 16, 2020, 31, 2020, 40, 2021,
  49, 2020
)

rec_marijuana <- tribble(
  ~statefip, ~rec_marijuana_year,
  8, 2012, 53, 2012, 41, 2014, 2, 2014, 11, 2014,
  32, 2016, 6, 2016, 25, 2016, 23, 2016, 50, 2018,
  26, 2018, 17, 2019, 4, 2020, 30, 2020, 34, 2021,
  36, 2021, 9, 2021, 35, 2021, 51, 2021
)

saveRDS(medicaid_expansion, file.path(data_dir, "medicaid_expansion.rds"))
saveRDS(rec_marijuana, file.path(data_dir, "rec_marijuana.rds"))
cat("Saved concurrent policy dates.\n")

cat("\n=== All Data Fetch Complete ===\n")
