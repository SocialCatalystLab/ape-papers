###############################################################################
# 01_fetch_data.R — Fetch PSEO earnings + minimum wage + state controls
# APEP-0372: Minimum Wage Spillovers to College Graduate Earnings
###############################################################################

source("00_packages.R")

data_dir <- "../data"
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

###############################################################################
# 1. PSEO Time Series — Earnings
###############################################################################

cat("=== Fetching PSEO Earnings Data ===\n")

base_url <- "https://api.census.gov/data/timeseries/pseo/earnings"

# Fetch institution-level data for all degree levels and cohorts
# Degree levels: 01=cert<1yr, 02=cert1-2yr, 03=associate, 05=bachelor's
degree_levels <- c("01", "02", "03", "05", "07")
degree_names <- c("cert_short", "cert_long", "associate", "bachelor", "master")

all_pseo <- list()

for (i in seq_along(degree_levels)) {
  dl <- degree_levels[i]
  cat(sprintf("  Fetching degree level %s (%s)...\n", dl, degree_names[i]))

  # All fields (CIP=00) at institution level
  url <- paste0(
    base_url,
    "?get=INSTITUTION,GRAD_COHORT,GRAD_COHORT_YEARS,",
    "Y1_P25_EARNINGS,Y1_P50_EARNINGS,Y1_P75_EARNINGS,",
    "Y5_P25_EARNINGS,Y5_P50_EARNINGS,Y5_P75_EARNINGS,",
    "Y10_P25_EARNINGS,Y10_P50_EARNINGS,Y10_P75_EARNINGS,",
    "Y1_GRADS_EARN,Y5_GRADS_EARN,Y10_GRADS_EARN,",
    "INST_STATE,INST_LEVEL",
    "&for=us:1&CIPCODE=00&DEGREE_LEVEL=", dl
  )

  resp <- GET(url)
  if (status_code(resp) == 200) {
    json_data <- content(resp, as = "text", encoding = "UTF-8")
    parsed <- fromJSON(json_data)
    if (is.matrix(parsed) && nrow(parsed) > 1) {
      df <- as.data.frame(parsed[-1, , drop = FALSE], stringsAsFactors = FALSE)
      colnames(df) <- parsed[1, ]
      df$degree_level <- dl
      df$degree_name <- degree_names[i]
      all_pseo[[length(all_pseo) + 1]] <- df
      cat(sprintf("    -> %d rows\n", nrow(df)))
    }
  } else {
    cat(sprintf("    -> ERROR: HTTP %d\n", status_code(resp)))
  }
  Sys.sleep(0.5)
}

pseo_inst <- bind_rows(all_pseo)
cat(sprintf("Total PSEO institution-level rows: %d\n", nrow(pseo_inst)))

# Also fetch CIP-level data for bachelor's (field heterogeneity)
cat("  Fetching CIP-level data for bachelor's...\n")
all_cip <- list()
cohorts <- c("2001", "2004", "2007", "2010", "2013", "2016", "2019")

for (cohort in cohorts) {
  cat(sprintf("    Cohort %s...\n", cohort))
  url <- paste0(
    base_url,
    "?get=INSTITUTION,CIPCODE,",
    "Y1_P25_EARNINGS,Y1_P50_EARNINGS,Y1_P75_EARNINGS,",
    "Y5_P25_EARNINGS,Y5_P50_EARNINGS,Y5_P75_EARNINGS,",
    "Y1_GRADS_EARN,INST_STATE",
    "&for=us:1&DEGREE_LEVEL=05&GRAD_COHORT=", cohort,
    "&INST_LEVEL=I"
  )

  resp <- GET(url)
  if (status_code(resp) == 200) {
    json_data <- content(resp, as = "text", encoding = "UTF-8")
    parsed <- fromJSON(json_data)
    if (is.matrix(parsed) && nrow(parsed) > 1) {
      df <- as.data.frame(parsed[-1, , drop = FALSE], stringsAsFactors = FALSE)
      colnames(df) <- parsed[1, ]
      df$GRAD_COHORT <- cohort
      all_cip[[length(all_cip) + 1]] <- df
      cat(sprintf("      -> %d rows\n", nrow(df)))
    }
  } else {
    cat(sprintf("      -> ERROR: HTTP %d\n", status_code(resp)))
  }
  Sys.sleep(0.5)
}

pseo_cip <- bind_rows(all_cip)
cat(sprintf("Total PSEO CIP-level rows: %d\n", nrow(pseo_cip)))

# Also fetch state-level aggregates (for descriptive statistics)
cat("  Fetching state-level aggregates...\n")
url_state <- paste0(
  base_url,
  "?get=DEGREE_LEVEL,GRAD_COHORT,GRAD_COHORT_YEARS,",
  "Y1_P25_EARNINGS,Y1_P50_EARNINGS,Y1_P75_EARNINGS,",
  "Y5_P25_EARNINGS,Y5_P50_EARNINGS,Y5_P75_EARNINGS,",
  "Y10_P25_EARNINGS,Y10_P50_EARNINGS,Y10_P75_EARNINGS,",
  "INST_STATE",
  "&for=us:1&CIPCODE=00&INST_LEVEL=S"
)

resp <- GET(url_state)
json_data <- content(resp, as = "text", encoding = "UTF-8")
parsed <- fromJSON(json_data)
pseo_state <- as.data.frame(parsed[-1, , drop = FALSE], stringsAsFactors = FALSE)
colnames(pseo_state) <- parsed[1, ]
cat(sprintf("State-level aggregate rows: %d\n", nrow(pseo_state)))


###############################################################################
# 2. State Minimum Wages (DOL via Lislejoem)
###############################################################################

cat("\n=== Fetching State Minimum Wage Data ===\n")

mw_url <- "https://raw.githubusercontent.com/Lislejoem/Minimum-Wage-by-State-1968-to-2020/master/Minimum%20Wage%20Data.csv"

# Download with latin1 encoding
mw_file <- file.path(data_dir, "minimum_wage_raw.csv")
download.file(mw_url, mw_file, quiet = TRUE)
mw_raw <- read.csv(mw_file, fileEncoding = "latin1", stringsAsFactors = FALSE)
cat(sprintf("Minimum wage raw: %d rows, %d cols\n", nrow(mw_raw), ncol(mw_raw)))
cat(sprintf("Years: %d-%d\n", min(mw_raw$Year), max(mw_raw$Year)))
cat(sprintf("States: %d\n", length(unique(mw_raw$State))))


###############################################################################
# 3. State Economic Controls from FRED
###############################################################################

cat("\n=== Fetching State Economic Controls ===\n")

fred_key <- Sys.getenv("FRED_API_KEY")
if (fred_key == "") {
  cat("WARNING: FRED_API_KEY not set. Using fallback data.\n")
}

# State FIPS codes for PSEO states
state_fips <- data.frame(
  fips = c("01","04","08","09","11","13","15","16","17","18","19",
           "22","23","25","26","27","29","30","36","37","39","40",
           "41","42","44","45","46","48","49","51","54","55","56"),
  abbr = c("AL","AZ","CO","CT","DC","GA","HI","ID","IL","IN","IA",
           "LA","ME","MA","MI","MN","MO","MT","NY","NC","OH","OK",
           "OR","PA","RI","SC","SD","TX","UT","VA","WV","WI","WY"),
  stringsAsFactors = FALSE
)

# Fetch state unemployment rates from FRED (LAUS series)
fetch_fred_series <- function(series_id, api_key) {
  url <- sprintf(
    "https://api.stlouisfed.org/fred/series/observations?series_id=%s&api_key=%s&file_type=json&observation_start=2000-01-01",
    series_id, api_key
  )
  resp <- GET(url)
  if (status_code(resp) == 200) {
    data <- content(resp, as = "parsed")
    obs <- data$observations
    if (length(obs) > 0) {
      df <- bind_rows(lapply(obs, function(o) {
        data.frame(date = o$date, value = as.numeric(o$value), stringsAsFactors = FALSE)
      }))
      return(df)
    }
  }
  return(NULL)
}

# Fetch unemployment rate for each state
all_unemp <- list()
for (i in seq_len(nrow(state_fips))) {
  abbr <- state_fips$abbr[i]
  fips <- state_fips$fips[i]
  series_id <- paste0(abbr, "UR")
  cat(sprintf("  Fetching unemployment: %s (%s)...\n", abbr, series_id))

  df <- fetch_fred_series(series_id, fred_key)
  if (!is.null(df)) {
    df$state_fips <- fips
    df$state_abbr <- abbr
    all_unemp[[length(all_unemp) + 1]] <- df
  }
  Sys.sleep(0.3)
}

unemp <- bind_rows(all_unemp)
cat(sprintf("Unemployment data: %d observations\n", nrow(unemp)))

# Fetch per capita personal income (BEA data via FRED)
all_income <- list()
for (i in seq_len(nrow(state_fips))) {
  abbr <- state_fips$abbr[i]
  fips <- state_fips$fips[i]
  series_id <- paste0(abbr, "PCPI")
  cat(sprintf("  Fetching per capita income: %s...\n", abbr))

  df <- fetch_fred_series(series_id, fred_key)
  if (!is.null(df)) {
    df$state_fips <- fips
    df$state_abbr <- abbr
    all_income[[length(all_income) + 1]] <- df
  }
  Sys.sleep(0.3)
}

income <- bind_rows(all_income)
cat(sprintf("Per capita income data: %d observations\n", nrow(income)))


###############################################################################
# 4. Save all raw data
###############################################################################

cat("\n=== Saving Raw Data ===\n")

saveRDS(pseo_inst, file.path(data_dir, "pseo_institution.rds"))
saveRDS(pseo_cip, file.path(data_dir, "pseo_cip.rds"))
saveRDS(pseo_state, file.path(data_dir, "pseo_state_agg.rds"))
saveRDS(mw_raw, file.path(data_dir, "minimum_wage_raw.rds"))
saveRDS(unemp, file.path(data_dir, "state_unemployment.rds"))
saveRDS(income, file.path(data_dir, "state_income.rds"))
saveRDS(state_fips, file.path(data_dir, "state_fips.rds"))

cat("All data saved successfully.\n")
cat(sprintf("  PSEO institutions: %d rows\n", nrow(pseo_inst)))
cat(sprintf("  PSEO CIP-level: %d rows\n", nrow(pseo_cip)))
cat(sprintf("  PSEO state agg: %d rows\n", nrow(pseo_state)))
cat(sprintf("  Minimum wage: %d rows\n", nrow(mw_raw)))
cat(sprintf("  Unemployment: %d rows\n", nrow(unemp)))
cat(sprintf("  Income: %d rows\n", nrow(income)))
