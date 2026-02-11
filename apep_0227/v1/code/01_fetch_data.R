## ============================================================================
## 01_fetch_data.R — Fetch overdose mortality and covariate data
## APEP Working Paper apep_0225
## ============================================================================

source("00_packages.R")

data_dir <- "../data"
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

## ---------------------------------------------------------------------------
## 1. CDC VSRR Provisional Drug Overdose Death Counts (Socrata API)
## ---------------------------------------------------------------------------
## Source: https://data.cdc.gov/NCHS/VSRR-Provisional-Drug-Overdose-Death-Counts/xkb8-kh2a
## This dataset provides monthly state-level provisional counts by drug type.

cat("Fetching CDC VSRR provisional overdose data...\n")

base_url <- "https://data.cdc.gov/resource/xkb8-kh2a.json"

# Indicators we need
indicators <- c(
  "Synthetic opioids, excl. methadone (T40.4)",
  "Opioids (T40.0-T40.4,T40.6)",
  "Cocaine (T40.5)",
  "Psychostimulants with abuse potential (T43.6)",
  "Number of Drug Overdose Deaths",
  "Natural & semi-synthetic opioids (T40.2)",
  "Heroin (T40.1)"
)

all_data <- list()

for (ind in indicators) {
  cat("  Fetching:", ind, "\n")

  offset <- 0
  batch_size <- 50000
  indicator_data <- list()

  repeat {
    url <- paste0(
      base_url,
      "?$where=indicator='", URLencode(ind, reserved = TRUE), "'",
      "&$limit=", batch_size,
      "&$offset=", offset,
      "&$order=state,year,month"
    )

    resp <- httr::GET(url, httr::timeout(60))

    if (httr::status_code(resp) != 200) {
      cat("    HTTP error:", httr::status_code(resp), "\n")
      break
    }

    batch <- jsonlite::fromJSON(httr::content(resp, as = "text", encoding = "UTF-8"))

    if (is.null(batch) || nrow(batch) == 0) break

    indicator_data[[length(indicator_data) + 1]] <- batch
    offset <- offset + batch_size

    if (nrow(batch) < batch_size) break

    Sys.sleep(0.5)
  }

  if (length(indicator_data) > 0) {
    all_data[[ind]] <- bind_rows(indicator_data)
    cat("    Records:", nrow(all_data[[ind]]), "\n")
  }
}

cdc_raw <- bind_rows(all_data)
cat("Total CDC records:", nrow(cdc_raw), "\n")

# Save raw data
saveRDS(cdc_raw, file.path(data_dir, "cdc_vsrr_raw.rds"))

## ---------------------------------------------------------------------------
## 2. State FIPS codes and population data
## ---------------------------------------------------------------------------
## Use Census Bureau population estimates

cat("Fetching state population data from Census Bureau...\n")

# State FIPS crosswalk
state_fips <- tibble(
  state_abb = c("AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA",
                "HI","ID","IL","IN","IA","KS","KY","LA","ME","MD",
                "MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ",
                "NM","NY","NC","ND","OH","OK","OR","PA","RI","SC",
                "SD","TN","TX","UT","VT","VA","WA","WV","WI","WY","DC"),
  state_fips = c("01","02","04","05","06","08","09","10","12","13",
                 "15","16","17","18","19","20","21","22","23","24",
                 "25","26","27","28","29","30","31","32","33","34",
                 "35","36","37","38","39","40","41","42","44","45",
                 "46","47","48","49","50","51","53","54","55","56","11"),
  state_name = c("Alabama","Alaska","Arizona","Arkansas","California",
                 "Colorado","Connecticut","Delaware","Florida","Georgia",
                 "Hawaii","Idaho","Illinois","Indiana","Iowa","Kansas",
                 "Kentucky","Louisiana","Maine","Maryland","Massachusetts",
                 "Michigan","Minnesota","Mississippi","Missouri","Montana",
                 "Nebraska","Nevada","New Hampshire","New Jersey",
                 "New Mexico","New York","North Carolina","North Dakota",
                 "Ohio","Oklahoma","Oregon","Pennsylvania","Rhode Island",
                 "South Carolina","South Dakota","Tennessee","Texas","Utah",
                 "Vermont","Virginia","Washington","West Virginia",
                 "Wisconsin","Wyoming","District of Columbia")
)

# Fetch population from Census PEP (Vintage 2023) via API
pop_data <- list()
years_for_pop <- 2013:2023

for (yr in years_for_pop) {
  cat("  Population for", yr, "...")

  # Use ACS 1-year total population table B01003
  url <- paste0(
    "https://api.census.gov/data/", yr, "/acs/acs1?get=NAME,B01003_001E&for=state:*"
  )

  tryCatch({
    resp <- httr::GET(url, httr::timeout(30))
    Sys.sleep(1.5)  # Rate limiting

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
      cat(" OK\n")
    } else {
      cat(" HTTP", httr::status_code(resp), "\n")
    }
  }, error = function(e) {
    cat(" Error:", conditionMessage(e), "\n")
  })
}

pop_df <- bind_rows(pop_data)
cat("Population records:", nrow(pop_df), "\n")

saveRDS(pop_df, file.path(data_dir, "state_population.rds"))
saveRDS(state_fips, file.path(data_dir, "state_fips.rds"))

## ---------------------------------------------------------------------------
## 3. FTS Legalization Dates (hand-coded from legislative records)
## ---------------------------------------------------------------------------
## Sources: LAPPA, NCSL, Network for Public Health Law, state statutes
## Coding rule: effective date of law removing FTS from paraphernalia def.
## For always-legal states (never included testing equipment): coded as
## always-treated with first_treat = 0 (excluded from main analysis).

cat("Creating FTS legalization treatment assignment...\n")

fts_laws <- tribble(
  ~state_abb, ~effective_date, ~effective_year, ~notes,
  # Always legal (testing equipment never in paraphernalia statute)
  # These are excluded from the main analysis or coded as always-treated
  # "AK", NA, 0, "No state paraphernalia law",
  # "OR", NA, 0, "Testing equipment excluded from statute",

  # 2017 cohort (DC)
  "DC", "2017-06-01", 2017, "Opioid Overdose Treatment/Prevention provisions",

  # 2018 cohort
  "RI", "2018-07-15", 2018, "HB 7939 removed drug checking equipment",
  "MA", "2018-08-09", 2018, "SB 2371 harm reduction provisions",
  "MD", "2018-06-01", 2018, "SB 1137 drug checking equipment",

  # 2019 cohort
  "NC", "2019-07-22", 2019, "HB 325 Good Samaritan + FTS",
  "VA", "2019-07-01", 2019, "HB 2317 drug checking equipment",

  # 2020 cohort
  "CO", "2020-07-01", 2020, "SB 20-007 fentanyl testing equipment",

  # 2021 cohort
  "AZ", "2021-08-25", 2021, "HB 2082 drug testing equipment",
  "DE", "2021-08-18", 2021, "SB 90 fentanyl testing strips",
  "MN", "2021-07-01", 2021, "SF 72 drug checking equipment",
  "NV", "2021-10-01", 2021, "AB 74 fentanyl test strips",
  "WI", "2021-12-03", 2021, "2021 Act 57",

  # 2022 cohort (major wave)
  "AL", "2022-04-07", 2022, "Act 2022-211",
  "CT", "2022-07-01", 2022, "SB 16 drug checking equipment",
  "GA", "2022-07-01", 2022, "HB 1401 drug checking equipment",
  "KY", "2022-07-14", 2022, "SB 173 harm reduction",
  "LA", "2022-08-01", 2022, "SB 301 drug checking equipment",
  "ME", "2022-04-18", 2022, "LD 1909 drug checking equipment",
  "NM", "2022-06-17", 2022, "HB 152 drug checking equipment",
  "OH", "2022-06-13", 2022, "SB 296 signed (effective 2022)",
  "TN", "2022-05-25", 2022, "SB 2677 fentanyl test strips",
  "WV", "2022-06-08", 2022, "SB 587 drug checking equipment",

  # 2023 cohort
  "AR", "2023-08-01", 2023, "HB 1099 drug testing equipment",
  "FL", "2023-07-01", 2023, "HB 365 drug checking equipment",
  "HI", "2023-06-22", 2023, "HB 1369 drug checking equipment",
  "IL", "2023-01-01", 2023, "HB 4556 fentanyl test strips",
  "KS", "2023-07-01", 2023, "HB 2089 drug checking equipment",
  "MI", "2023-07-19", 2023, "SB 78 drug checking equipment",
  "MS", "2023-07-01", 2023, "HB 722 drug testing equipment",
  "NH", "2023-08-04", 2023, "SB 139 fentanyl test strips",
  "NJ", "2023-03-20", 2023, "A5407 drug checking equipment",
  "SC", "2023-05-19", 2023, "SB 233 fentanyl test strips",
  "SD", "2023-07-01", 2023, "SB 13 drug testing equipment",
  "UT", "2023-05-03", 2023, "SB 38 drug testing equipment",
  "WA", "2023-07-23", 2023, "SB 5536 drug checking equipment",
  "CA", "2022-01-01", 2022, "AB 1598 drug checking equipment",
  "MO", "2023-07-07", 2023, "SB 480 drug checking equipment",
  "MT", "2023-07-01", 2023, "HB 437 drug checking equipment",
  "OK", "2023-11-01", 2023, "HB 1987 drug checking equipment",

  # 2024 cohort (for robustness / out-of-sample)
  "NY", "2024-04-01", 2024, "S6478 drug checking equipment",
  "PA", "2024-01-01", 2024, "HB 1393 drug testing equipment",
  "VT", "2024-07-01", 2024, "S.258 drug checking equipment"
)

# Never-treated states (as of end 2023)
never_treated <- c("ID", "IN", "IA", "ND", "TX")

# States that may be "always legal" or ambiguous
# AK, NE, OR - testing equipment may never have been illegal
# We code these as missing/ambiguous and exclude from main analysis
ambiguous_states <- c("AK", "NE", "OR", "WY")

# Partial-year exposure fraction
fts_laws <- fts_laws %>%
  mutate(
    effective_date = as.Date(effective_date),
    # Fraction of year exposed (from effective date to Dec 31)
    days_exposed = as.numeric(as.Date(paste0(effective_year, "-12-31")) - effective_date + 1),
    exposure_fraction = pmin(pmax(days_exposed / 365, 0), 1)
  )

saveRDS(fts_laws, file.path(data_dir, "fts_laws.rds"))

## ---------------------------------------------------------------------------
## 4. Concurrent harm reduction policy controls
## ---------------------------------------------------------------------------
## Source: PDAPS (pdaps.org), LAPPA, KFF
## We code: Naloxone access laws, SSP legality, PDMP mandated use,
##          Medicaid expansion

cat("Creating concurrent policy controls...\n")

# Naloxone access laws (NALs) - year of first standing order/third-party Rx
naloxone_laws <- tribble(
  ~state_abb, ~naloxone_year,
  "NM", 2001, "WA", 2010, "CT", 2011, "IL", 2010, "CA", 2013,
  "CO", 2013, "RI", 2012, "VT", 2013, "NY", 2014, "NC", 2013,
  "OH", 2014, "PA", 2014, "VA", 2013, "MA", 2012, "MD", 2013,
  "NJ", 2013, "WI", 2014, "TN", 2014, "GA", 2014, "MN", 2014,
  "OR", 2013, "KY", 2013, "IN", 2015, "TX", 2015, "FL", 2015,
  "ME", 2014, "NH", 2015, "MI", 2014, "MO", 2017, "DE", 2014,
  "AZ", 2015, "AL", 2015, "AR", 2015, "HI", 2016, "IA", 2016,
  "ID", 2015, "KS", 2017, "LA", 2014, "MS", 2016, "MT", 2015,
  "ND", 2015, "NE", 2015, "NV", 2015, "OK", 2015, "SC", 2015,
  "SD", 2016, "UT", 2014, "WV", 2015, "WY", 2017, "AK", 2016,
  "DC", 2015
)

# Medicaid expansion year
medicaid_exp <- tribble(
  ~state_abb, ~medicaid_exp_year,
  "AZ", 2014, "AR", 2014, "CA", 2014, "CO", 2014, "CT", 2014,
  "DE", 2014, "HI", 2014, "IL", 2014, "IA", 2014, "KY", 2014,
  "MD", 2014, "MA", 2014, "MI", 2014, "MN", 2014, "NV", 2014,
  "NH", 2014, "NJ", 2014, "NM", 2014, "NY", 2014, "ND", 2014,
  "OH", 2014, "OR", 2014, "RI", 2014, "VT", 2014, "WA", 2014,
  "WV", 2014, "DC", 2014,
  "MT", 2016, "AK", 2015, "IN", 2015, "PA", 2015, "LA", 2016,
  "VA", 2019, "ME", 2019, "ID", 2020, "NE", 2020, "UT", 2020,
  "OK", 2021, "MO", 2021, "SD", 2024, "NC", 2024
)

saveRDS(naloxone_laws, file.path(data_dir, "naloxone_laws.rds"))
saveRDS(medicaid_exp, file.path(data_dir, "medicaid_expansion.rds"))

## ---------------------------------------------------------------------------
## 5. State-level economic controls from ACS
## ---------------------------------------------------------------------------
## Poverty rate, unemployment rate, median income

cat("Fetching state economic controls from ACS...\n")

econ_data <- list()

for (yr in 2013:2023) {
  cat("  ACS economic controls for", yr, "...")

  # B17001_001 = Total for poverty, B17001_002 = Below poverty
  # B23025_003 = In labor force, B23025_005 = Unemployed
  # B19013_001 = Median household income
  url <- paste0(
    "https://api.census.gov/data/", yr, "/acs/acs1?get=NAME,",
    "B17001_001E,B17001_002E,B23025_003E,B23025_005E,B19013_001E",
    "&for=state:*"
  )

  tryCatch({
    resp <- httr::GET(url, httr::timeout(30))
    Sys.sleep(1.5)

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
      cat(" OK\n")
    } else {
      cat(" HTTP", httr::status_code(resp), "\n")
    }
  }, error = function(e) {
    cat(" Error:", conditionMessage(e), "\n")
  })
}

econ_df <- bind_rows(econ_data)
cat("Economic control records:", nrow(econ_df), "\n")

saveRDS(econ_df, file.path(data_dir, "state_econ_controls.rds"))

cat("\n=== Data fetch complete ===\n")
cat("Files saved to:", data_dir, "\n")
