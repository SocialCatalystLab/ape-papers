## =============================================================================
## 01_fetch_data.R — Fetch YRBS data from CDC Socrata API
## Anti-Cyberbullying Laws and Youth Mental Health
## =============================================================================

source("00_packages.R")

data_dir <- "../data"
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

## -----------------------------------------------------------------------------
## 1. Fetch YRBS data from CDC Socrata API
## Dataset: svam-8dhg (YRBSS High School, excluding sexual identity)
## -----------------------------------------------------------------------------

base_url <- "https://data.cdc.gov/resource/svam-8dhg.json"

# Questions of interest
questions <- c(
  "H24",  # Electronic bullying (cyberbullying)
  "H23",  # Bullying at school (traditional)
  "H26",  # Considered suicide
  "H27",  # Suicide plan
  "H28",  # Attempted suicide
  "H29",  # Injurious suicide attempt
  "H25"   # Sad or hopeless (depression proxy)
)

fetch_yrbs_question <- function(qcode, stratification = "Total") {
  cat(sprintf("  Fetching %s...\n", qcode))

  all_rows <- list()
  offset <- 0
  batch_size <- 5000

  repeat {
    url <- sprintf(
      "%s?$limit=%d&$offset=%d&$where=questioncode='%s'&$order=year,locationabbr",
      base_url, batch_size, offset, qcode
    )
    resp <- httr::GET(url)
    if (httr::status_code(resp) != 200) {
      warning(sprintf("HTTP %d for %s at offset %d", httr::status_code(resp), qcode, offset))
      break
    }
    rows <- jsonlite::fromJSON(httr::content(resp, "text", encoding = "UTF-8"))
    if (is.null(rows) || nrow(rows) == 0) break
    all_rows[[length(all_rows) + 1]] <- rows
    offset <- offset + batch_size
    if (nrow(rows) < batch_size) break
  }

  if (length(all_rows) == 0) {
    warning(sprintf("No data returned for %s", qcode))
    return(NULL)
  }

  bind_rows(all_rows)
}

cat("Fetching YRBS data from CDC API...\n")
yrbs_raw <- list()
for (q in questions) {
  yrbs_raw[[q]] <- fetch_yrbs_question(q)
  Sys.sleep(0.5)  # Rate limiting
}

# Combine all questions
yrbs_all <- bind_rows(yrbs_raw, .id = "question_id")
cat(sprintf("  Total rows fetched: %d\n", nrow(yrbs_all)))

saveRDS(yrbs_all, file.path(data_dir, "yrbs_raw.rds"))

# Drop nested columns (geolocation) before CSV export
yrbs_flat <- yrbs_all %>%
  select(-any_of("geolocation")) %>%
  mutate(across(where(is.list), as.character))
write_csv(yrbs_flat, file.path(data_dir, "yrbs_raw.csv"))

## -----------------------------------------------------------------------------
## 2. Construct anti-cyberbullying law treatment matrix
## Sources: Hinduja & Patchin (2016), NCSL, Cyberbullying Research Center
##
## Year = year law including electronic harassment/cyberbullying took effect
## Coded relative to YRBS spring survey window:
##   If law effective before March of YRBS year Y, state is treated in wave Y
## -----------------------------------------------------------------------------

cat("Constructing treatment matrix...\n")

# State cyberbullying law effective years
# Based on Hinduja & Patchin (2016), NCSL State Bullying Laws database,
# and Cyberbullying Research Center (updated 2021)
#
# Year = year law first explicitly addressed electronic/cyber bullying
# Type: "criminal" = criminal sanctions for cyberbullying
#       "school"   = school policy mandate only
#       "both"     = criminal sanctions AND school policy mandate

cyberbullying_laws <- tribble(
  ~state, ~state_abbr, ~law_year, ~law_type,
  "Alabama",        "AL", 2012, "school",
  "Alaska",         "AK",   NA, "none",      # No specific cyberbullying provision
  "Arizona",        "AZ", 2012, "school",
  "Arkansas",       "AR", 2011, "both",
  "California",     "CA", 2009, "school",
  "Colorado",       "CO", 2012, "school",
  "Connecticut",    "CT", 2011, "both",
  "Delaware",       "DE", 2009, "school",
  "Florida",        "FL", 2008, "both",
  "Georgia",        "GA", 2011, "school",
  "Hawaii",         "HI", 2011, "school",
  "Idaho",          "ID", 2006, "school",
  "Illinois",       "IL", 2009, "school",
  "Indiana",        "IN", 2013, "school",
  "Iowa",           "IA", 2007, "school",
  "Kansas",         "KS", 2008, "school",
  "Kentucky",       "KY", 2008, "school",
  "Louisiana",      "LA", 2010, "both",
  "Maine",          "ME", 2012, "school",
  "Maryland",       "MD", 2008, "both",
  "Massachusetts",  "MA", 2010, "school",
  "Michigan",       "MI", 2011, "school",
  "Minnesota",      "MN", 2007, "school",
  "Mississippi",    "MS", 2010, "school",
  "Missouri",       "MO", 2007, "both",
  "Montana",        "MT", 2015, "school",
  "Nebraska",       "NE", 2009, "school",
  "Nevada",         "NV", 2009, "both",
  "New Hampshire",  "NH", 2010, "both",
  "New Jersey",     "NJ", 2011, "school",
  "New Mexico",     "NM", 2012, "school",
  "New York",       "NY", 2012, "both",
  "North Carolina", "NC", 2009, "both",
  "North Dakota",   "ND", 2011, "school",
  "Ohio",           "OH", 2007, "school",
  "Oklahoma",       "OK", 2008, "school",
  "Oregon",         "OR", 2007, "school",
  "Pennsylvania",   "PA", 2008, "school",
  "Rhode Island",   "RI", 2012, "school",
  "South Carolina", "SC", 2006, "school",
  "South Dakota",   "SD", 2012, "school",
  "Tennessee",      "TN", 2012, "both",
  "Texas",          "TX", 2011, "school",
  "Utah",           "UT", 2013, "school",
  "Vermont",        "VT", 2012, "school",
  "Virginia",       "VA", 2009, "school",
  "Washington",     "WA", 2007, "school",
  "West Virginia",  "WV", 2011, "school",
  "Wisconsin",      "WI",   NA, "none",      # No specific cyberbullying provision
  "Wyoming",        "WY", 2009, "school"
)

saveRDS(cyberbullying_laws, file.path(data_dir, "cyberbullying_laws.rds"))
write_csv(cyberbullying_laws, file.path(data_dir, "cyberbullying_laws.csv"))

## -----------------------------------------------------------------------------
## 3. Fetch state-level controls from Census ACS via tidycensus (if available)
##    Fallback: BLS unemployment rate
## -----------------------------------------------------------------------------

cat("Fetching state controls...\n")

# BLS unemployment data (LAUS) via public API
# Annual average unemployment rate by state
bls_data <- tryCatch({
  years <- 2003:2017
  all_unemp <- list()

  for (yr in years) {
    url <- sprintf(
      "https://api.bls.gov/publicAPI/v2/timeseries/data/LASST%s0000000000003?startyear=%d&endyear=%d",
      "01", yr, yr  # Will iterate through states
    )
    # Use LAUS series for each state
    # Format: LASST{FIPS}0000000000003 (unemployment rate)
    # Skip individual API calls — use pre-constructed state FIPS
  }

  # Simpler approach: fetch from BLS flat files
  bls_url <- "https://download.bls.gov/pub/time.series/la/la.data.3.AllStatesS"
  bls_resp <- httr::GET(bls_url)
  if (httr::status_code(bls_resp) == 200) {
    bls_text <- httr::content(bls_resp, "text", encoding = "UTF-8")
    bls_df <- read.delim(textConnection(bls_text), sep = "\t", strip.white = TRUE)
    cat("  BLS data fetched from flat files.\n")
    bls_df
  } else {
    cat("  BLS flat file unavailable, skipping.\n")
    NULL
  }
}, error = function(e) {
  cat(sprintf("  BLS fetch failed: %s\n", e$message))
  NULL
})

if (!is.null(bls_data)) {
  saveRDS(bls_data, file.path(data_dir, "bls_unemployment_raw.rds"))
}

## -----------------------------------------------------------------------------
## 4. State population data from Census for rate calculations
## -----------------------------------------------------------------------------

cat("Fetching state population data...\n")

# Census population estimates via API
pop_data <- tryCatch({
  pop_list <- list()
  for (yr in 2003:2017) {
    # Use Census vintage estimates
    vintage <- ifelse(yr >= 2010, "2019", "2009")
    pop_url <- sprintf(
      "https://api.census.gov/data/%s/pep/charagegroups?get=POP,NAME&for=state:*&DATE_CODE=%d&AGEGROUP=1",
      vintage,
      ifelse(vintage == "2019", yr - 2010 + 3, yr - 2000 + 1)
    )
    resp <- httr::GET(pop_url)
    if (httr::status_code(resp) == 200) {
      txt <- httr::content(resp, "text", encoding = "UTF-8")
      df <- jsonlite::fromJSON(txt)
      if (!is.null(df) && nrow(df) > 1) {
        colnames(df) <- df[1, ]
        df <- as.data.frame(df[-1, ])
        df$year <- yr
        pop_list[[as.character(yr)]] <- df
      }
    }
    Sys.sleep(0.3)
  }

  if (length(pop_list) > 0) {
    cat("  Population data fetched.\n")
    bind_rows(pop_list)
  } else {
    cat("  Population fetch returned no data.\n")
    NULL
  }
}, error = function(e) {
  cat(sprintf("  Population fetch failed: %s\n", e$message))
  NULL
})

if (!is.null(pop_data)) {
  saveRDS(pop_data, file.path(data_dir, "state_population_raw.rds"))
}

cat("\n=== Data fetch complete ===\n")
cat(sprintf("Files saved to: %s\n", normalizePath(data_dir)))
cat("  - yrbs_raw.rds / .csv\n")
cat("  - cyberbullying_laws.rds / .csv\n")
if (!is.null(bls_data)) cat("  - bls_unemployment_raw.rds\n")
if (!is.null(pop_data)) cat("  - state_population_raw.rds\n")
