## =============================================================================
## 01_fetch_data.R — Fetch QCEW healthcare employment data and construct
##                   IMLC treatment variable
## APEP Working Paper apep_0232
## =============================================================================

source("00_packages.R")

data_dir <- "../data"
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

## ---------------------------------------------------------------------------
## 1. IMLC treatment variable
##    Coded from FSMB press releases, state legislation records, and IMLCC
##    official website. Year = year state became operational in the compact.
##    States that enacted legislation before April 2017 all became operational
##    in 2017 when the compact first processed applications.
## ---------------------------------------------------------------------------

imlc_treatment <- tribble(
  ~state_fips, ~state_abbr, ~state_name,          ~imlc_year,
  "01",        "AL",        "Alabama",             2017,
  "02",        "AK",        "Alaska",              0,     # Never treated
  "04",        "AZ",        "Arizona",             2017,
  "05",        "AR",        "Arkansas",            0,     # Enacted 2025, too recent
  "06",        "CA",        "California",          0,     # Never treated
  "08",        "CO",        "Colorado",            2017,
  "09",        "CT",        "Connecticut",         2022,
  "10",        "DE",        "Delaware",            2021,
  "11",        "DC",        "District of Columbia", 2018,
  "12",        "FL",        "Florida",             0,     # 2024 too recent, treat as never
  "13",        "GA",        "Georgia",             2019,
  "15",        "HI",        "Hawaii",              2023,
  "16",        "ID",        "Idaho",               2017,
  "17",        "IL",        "Illinois",            2017,
  "18",        "IN",        "Indiana",             2022,
  "19",        "IA",        "Iowa",                2017,
  "20",        "KS",        "Kansas",              2017,
  "21",        "KY",        "Kentucky",            2019,
  "22",        "LA",        "Louisiana",           2020,
  "23",        "ME",        "Maine",               2017,
  "24",        "MD",        "Maryland",            2018,
  "25",        "MA",        "Massachusetts",       0,     # Never treated
  "26",        "MI",        "Michigan",            2018,
  "27",        "MN",        "Minnesota",           2017,
  "28",        "MS",        "Mississippi",         2017,
  "29",        "MO",        "Missouri",            2023,
  "30",        "MT",        "Montana",             2017,
  "31",        "NE",        "Nebraska",            2017,
  "32",        "NV",        "Nevada",              2017,
  "33",        "NH",        "New Hampshire",       2017,
  "34",        "NJ",        "New Jersey",          2022,
  "35",        "NM",        "New Mexico",          0,     # Never treated
  "36",        "NY",        "New York",            0,     # Never treated
  "37",        "NC",        "North Carolina",      0,     # Enacted 2025, too recent
  "38",        "ND",        "North Dakota",        2019,
  "39",        "OH",        "Ohio",                2021,
  "40",        "OK",        "Oklahoma",            2019,
  "41",        "OR",        "Oregon",              0,     # Never treated
  "42",        "PA",        "Pennsylvania",        2017,
  "44",        "RI",        "Rhode Island",        2022,
  "45",        "SC",        "South Carolina",      0,     # Never treated
  "46",        "SD",        "South Dakota",        2017,
  "47",        "TN",        "Tennessee",           2017,
  "48",        "TX",        "Texas",               2021,
  "49",        "UT",        "Utah",                2017,
  "50",        "VT",        "Vermont",             2018,
  "51",        "VA",        "Virginia",            0,     # Never treated
  "53",        "WA",        "Washington",          2017,
  "54",        "WV",        "West Virginia",       2017,
  "55",        "WI",        "Wisconsin",           2017,
  "56",        "WY",        "Wyoming",             2017
)

cat(sprintf("IMLC treatment data: %d jurisdictions\n", nrow(imlc_treatment)))
cat(sprintf("  Never treated: %d\n", sum(imlc_treatment$imlc_year == 0)))
cat(sprintf("  Treated: %d\n", sum(imlc_treatment$imlc_year > 0)))

write_csv(imlc_treatment, file.path(data_dir, "imlc_treatment.csv"))

## ---------------------------------------------------------------------------
## 2. Fetch QCEW data from BLS API
##    Data available from 2014 onward via industry endpoint.
##    Retail (44-45) not available; use Accommodation & Food (72) as placebo.
## ---------------------------------------------------------------------------

fetch_qcew_industry <- function(year, industry_code) {
  url <- sprintf(
    "https://data.bls.gov/cew/data/api/%d/a/industry/%s.csv",
    year, industry_code
  )
  cat(sprintf("  Fetching QCEW: year=%d, industry=%s ... ", year, industry_code))

  result <- tryCatch({
    resp <- httr::GET(url, httr::timeout(60))
    if (httr::status_code(resp) == 200) {
      txt <- httr::content(resp, as = "text", encoding = "UTF-8")
      df <- read.csv(textConnection(txt), stringsAsFactors = FALSE)
      cat(sprintf("OK (%d rows)\n", nrow(df)))
      return(df)
    } else {
      cat(sprintf("HTTP %d\n", httr::status_code(resp)))
      return(NULL)
    }
  }, error = function(e) {
    cat(sprintf("ERROR: %s\n", e$message))
    return(NULL)
  })

  return(result)
}

# Industries to fetch
industries <- list(
  healthcare  = "62",      # Health Care and Social Assistance
  ambulatory  = "621",     # Ambulatory Health Care Services
  hospitals   = "622",     # Hospitals
  placebo     = "72"       # Accommodation and Food Services (placebo)
)

years <- 2014:2023  # QCEW API data available from 2014

# Fetch all industry-year combinations
all_qcew <- list()
for (ind_name in names(industries)) {
  ind_code <- industries[[ind_name]]
  cat(sprintf("\nFetching %s (NAICS %s):\n", ind_name, ind_code))

  for (yr in years) {
    df <- fetch_qcew_industry(yr, ind_code)
    if (!is.null(df)) {
      df$industry_label <- ind_name
      all_qcew[[paste(ind_name, yr, sep = "_")]] <- df
    }
    Sys.sleep(0.5)
  }
}

# Combine all data
qcew_raw <- bind_rows(all_qcew)
cat(sprintf("\nTotal raw QCEW rows: %d\n", nrow(qcew_raw)))

## ---------------------------------------------------------------------------
## 3. Filter for state-level totals
##    area_fips is character like "01000" for Alabama. Filter for SS000 pattern.
##    own_code = 0 means total (all ownerships)
## ---------------------------------------------------------------------------

# Filter for state-level rows (area_fips = "SS000" pattern)
# own_code: 1=Federal, 2=State, 3=Local, 5=Private. No total (0).
# Aggregate across ownership types to get total.
qcew_states <- qcew_raw %>%
  filter(
    nchar(area_fips) == 5,
    substr(area_fips, 3, 5) == "000",
    !substr(area_fips, 1, 1) %in% c("C", "U")
  ) %>%
  mutate(state_fips = substr(area_fips, 1, 2))

cat(sprintf("State-level rows before aggregation: %d\n", nrow(qcew_states)))
cat(sprintf("Ownership codes present: %s\n", paste(sort(unique(qcew_states$own_code)), collapse=", ")))

# Aggregate across ownership types to get totals
qcew_panel <- qcew_states %>%
  group_by(state_fips, year, industry_label) %>%
  summarise(
    annual_avg_estabs_count = sum(as.numeric(annual_avg_estabs), na.rm = TRUE),
    annual_avg_emplvl = sum(as.numeric(annual_avg_emplvl), na.rm = TRUE),
    total_annual_wages = sum(as.numeric(total_annual_wages), na.rm = TRUE),
    # Weighted average pay = total wages / total employment
    avg_annual_pay = sum(as.numeric(total_annual_wages), na.rm = TRUE) /
                     sum(as.numeric(annual_avg_emplvl), na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(year = as.integer(year))

# Check coverage
cat("\nCoverage by industry and year:\n")
print(qcew_panel %>% count(industry_label, year) %>% pivot_wider(names_from = industry_label, values_from = n))

write_csv(qcew_panel, file.path(data_dir, "qcew_panel.csv"))
cat(sprintf("\nSaved QCEW panel: %d rows\n", nrow(qcew_panel)))

## ---------------------------------------------------------------------------
## 4. Fetch ACS work-from-home data (supplementary)
##    Table B08301: Means of Transportation to Work
##    B08301_001E = total workers, B08301_021E = worked from home
## ---------------------------------------------------------------------------

cat("\nFetching ACS work-from-home data...\n")

# Load Census API key if available
census_key <- Sys.getenv("CENSUS_API_KEY")
if (census_key == "") {
  env_file <- file.path(dirname(getwd()), "..", ".env")
  if (file.exists(env_file)) {
    env_lines <- readLines(env_file)
    key_line <- grep("^CENSUS_API_KEY=", env_lines, value = TRUE)
    if (length(key_line) > 0) {
      census_key <- sub("^CENSUS_API_KEY=", "", key_line[1])
      census_key <- gsub('"', '', census_key)
    }
  }
}

acs_years <- 2014:2023
acs_wfh <- list()

for (yr in acs_years) {
  if (yr == 2020) next  # ACS 1-year not available for 2020

  url <- sprintf(
    "https://api.census.gov/data/%d/acs/acs1?get=NAME,B08301_001E,B08301_021E&for=state:*",
    yr
  )
  if (census_key != "") url <- paste0(url, "&key=", census_key)

  result <- tryCatch({
    Sys.sleep(2)  # Rate limiting
    resp <- httr::GET(url, httr::timeout(30))
    if (httr::status_code(resp) == 200) {
      json <- httr::content(resp, as = "text", encoding = "UTF-8")
      mat <- fromJSON(json)
      df <- as.data.frame(mat[-1, ], stringsAsFactors = FALSE)
      names(df) <- mat[1, ]
      df$year <- yr
      cat(sprintf("  ACS %d: %d states\n", yr, nrow(df)))
      df
    } else {
      cat(sprintf("  ACS %d: HTTP %d\n", yr, httr::status_code(resp)))
      NULL
    }
  }, error = function(e) {
    cat(sprintf("  ACS %d: ERROR %s\n", yr, e$message))
    NULL
  })

  if (!is.null(result)) {
    acs_wfh[[as.character(yr)]] <- result
  }
}

if (length(acs_wfh) > 0) {
  acs_panel <- bind_rows(acs_wfh) %>%
    rename(state_name = NAME, state_fips = state) %>%
    mutate(
      total_workers = as.numeric(B08301_001E),
      wfh_workers = as.numeric(B08301_021E),
      wfh_share = wfh_workers / total_workers
    ) %>%
    select(state_fips, state_name, year, total_workers, wfh_workers, wfh_share)

  write_csv(acs_panel, file.path(data_dir, "acs_wfh_panel.csv"))
  cat(sprintf("Saved ACS WFH panel: %d rows\n", nrow(acs_panel)))
} else {
  cat("WARNING: No ACS data retrieved. Creating empty file.\n")
  acs_panel <- tibble(state_fips = character(), state_name = character(),
                      year = integer(), total_workers = numeric(),
                      wfh_workers = numeric(), wfh_share = numeric())
  write_csv(acs_panel, file.path(data_dir, "acs_wfh_panel.csv"))
}

cat("\n=== Data fetch complete ===\n")
