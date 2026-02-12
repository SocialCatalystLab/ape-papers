## 01_fetch_data.R — Fetch all data from APIs
## Paper: "The Quiet Life Goes Macro" (apep_0243)

source("00_packages.R")

cat("=== FETCHING DATA ===\n")

# ============================================================
# 1. TREATMENT DATA: BC Statute Adoption Dates
# From Karpoff & Wittry (2018, Journal of Finance) corrected dates
# ============================================================

bc_dates <- tribble(
  ~state_abbr, ~state_name, ~state_fips, ~bc_year,
  "AZ", "Arizona",       "04", 1987,
  "CT", "Connecticut",   "09", 1988,
  "DE", "Delaware",      "10", 1988,
  "GA", "Georgia",       "13", 1988,
  "ID", "Idaho",         "16", 1988,
  "IL", "Illinois",      "17", 1989,
  "IN", "Indiana",       "18", 1986,
  "IA", "Iowa",          "19", 1997,
  "KS", "Kansas",        "20", 1989,
  "KY", "Kentucky",      "21", 1987,
  "ME", "Maine",         "23", 1988,
  "MD", "Maryland",      "24", 1989,
  "MA", "Massachusetts", "25", 1989,
  "MI", "Michigan",      "26", 1989,
  "MN", "Minnesota",     "27", 1987,
  "MS", "Mississippi",   "28", 1990,
  "NE", "Nebraska",      "31", 1988,
  "NV", "Nevada",        "32", 1991,
  "NJ", "New Jersey",    "34", 1986,
  "NY", "New York",      "36", 1985,
  "OH", "Ohio",          "39", 1990,
  "OK", "Oklahoma",      "40", 1991,
  "OR", "Oregon",        "41", 1991,
  "PA", "Pennsylvania",  "42", 1989,
  "RI", "Rhode Island",  "44", 1990,
  "SC", "South Carolina","45", 1988,
  "SD", "South Dakota",  "46", 1990,
  "TN", "Tennessee",     "47", 1988,
  "VA", "Virginia",      "51", 1988,
  "WA", "Washington",    "53", 1987,
  "WI", "Wisconsin",     "55", 1987,
  "WY", "Wyoming",       "56", 1989
)

# Never-treated states
never_treated <- tribble(
  ~state_abbr, ~state_name, ~state_fips,
  "AL", "Alabama",       "01",
  "AK", "Alaska",        "02",
  "AR", "Arkansas",      "05",
  "CA", "California",    "06",
  "CO", "Colorado",      "08",
  "FL", "Florida",       "12",
  "HI", "Hawaii",        "15",
  "LA", "Louisiana",     "22",
  "MO", "Missouri",      "29",
  "MT", "Montana",       "30",
  "NH", "New Hampshire", "33",
  "NM", "New Mexico",    "35",
  "NC", "North Carolina","37",
  "ND", "North Dakota",  "38",
  "TX", "Texas",         "48",
  "UT", "Utah",          "49",
  "VT", "Vermont",       "50",
  "WV", "West Virginia", "54"
)
never_treated$bc_year <- 0  # CS-DiD convention for never-treated

all_states <- bind_rows(bc_dates, never_treated) %>% arrange(state_fips)

cat(sprintf("Treatment: %d states adopted BC statutes (1985-1997)\n", nrow(bc_dates)))
cat(sprintf("Control: %d states never adopted\n", nrow(never_treated)))

saveRDS(all_states, "../data/treatment_dates.rds")

# ============================================================
# 2. BEA REGIONAL DATA: State GDP and Compensation
# Using FRED API for state-level annual series
# ============================================================

cat("\n--- Fetching BEA data via FRED ---\n")

# State GDP (NOMINAL, millions of dollars) — needed for labor share
# FRED series: {ST}NGSP for each state
state_gdp_list <- list()
state_comp_list <- list()

# FRED series IDs for NOMINAL state GDP
gdp_series <- c(
  "01"="ALNGSP", "02"="AKNGSP", "04"="AZNGSP", "05"="ARNGSP",
  "06"="CANGSP", "08"="CONGSP", "09"="CTNGSP", "10"="DENGSP",
  "12"="FLNGSP", "13"="GANGSP", "15"="HINGSP", "16"="IDNGSP",
  "17"="ILNGSP", "18"="INNGSP", "19"="IANGSP", "20"="KSNGSP",
  "21"="KYNGSP", "22"="LANGSP", "23"="MENGSP", "24"="MDNGSP",
  "25"="MANGSP", "26"="MINGSP", "27"="MNNGSP", "28"="MSNGSP",
  "29"="MONGSP", "30"="MTNGSP", "31"="NENGSP", "32"="NVNGSP",
  "33"="NHNGSP", "34"="NJNGSP", "35"="NMNGSP", "36"="NYNGSP",
  "37"="NCNGSP", "38"="NDNGSP", "39"="OHNGSP", "40"="OKNGSP",
  "41"="ORNGSP", "42"="PANGSP", "44"="RINGSP", "45"="SCNGSP",
  "46"="SDNGSP", "47"="TNNGSP", "48"="TXNGSP", "49"="UTNGSP",
  "50"="VTNGSP", "51"="VANGSP", "53"="WANGSP", "54"="WVNGSP",
  "55"="WINGSP", "56"="WYNGSP"
)

for (fips in names(gdp_series)) {
  cat(sprintf("  GDP: %s (%s)\n", fips, gdp_series[fips]))
  tryCatch({
    obs <- fredr(series_id = gdp_series[fips],
                 observation_start = as.Date("1977-01-01"),
                 observation_end = as.Date("2023-12-31"))
    if (nrow(obs) > 0) {
      state_gdp_list[[fips]] <- obs %>%
        transmute(
          state_fips = fips,
          year = as.integer(format(date, "%Y")),
          nominal_gdp = as.numeric(value)
        )
    }
    Sys.sleep(0.15)  # Rate limit
  }, error = function(e) cat(sprintf("    ERROR: %s\n", e$message)))
}

state_gdp <- bind_rows(state_gdp_list)
cat(sprintf("GDP: %d state-year observations\n", nrow(state_gdp)))

# NOTE: Compensation will be proxied by CBP total annual payroll (PAYANN)
# This is already fetched as part of CBP data below
# Labor share = CBP payroll / nominal state GDP (both in nominal $)
cat("Compensation: Using CBP payroll as proxy (fetched with CBP data).\n")
state_comp <- data.frame()  # Placeholder — actual comp comes from CBP

saveRDS(state_gdp, "../data/state_gdp.rds")
saveRDS(state_comp, "../data/state_comp.rds")

# ============================================================
# 3. COUNTY BUSINESS PATTERNS: State-level establishment data
# Census API for 1986-2021
# ============================================================

cat("\n--- Fetching CBP data via Census API ---\n")

fetch_cbp_year <- function(yr) {
  base_url <- sprintf("https://api.census.gov/data/%d/cbp", yr)

  if (yr <= 1997) {
    # SIC-based years: no filter returns all-industry total
    params <- list(get = "ESTAB,EMP,PAYANN", `for` = "state:*")
  } else if (yr <= 2002) {
    params <- list(get = "ESTAB,EMP,PAYANN", `for` = "state:*", NAICS1997 = "00")
  } else if (yr <= 2007) {
    params <- list(get = "ESTAB,EMP,PAYANN", `for` = "state:*", NAICS2002 = "00")
  } else if (yr <= 2011) {
    params <- list(get = "ESTAB,EMP,PAYANN", `for` = "state:*", NAICS2007 = "00")
  } else if (yr <= 2016) {
    params <- list(get = "ESTAB,EMP,PAYANN", `for` = "state:*", NAICS2012 = "00")
  } else {
    params <- list(get = "ESTAB,EMP,PAYANN", `for` = "state:*", NAICS2017 = "00")
  }

  tryCatch({
    resp <- GET(base_url, query = params)
    if (status_code(resp) == 200) {
      raw <- content(resp, "text", encoding = "UTF-8")
      if (nchar(raw) > 10) {
        dat <- fromJSON(raw)
        df <- as.data.frame(dat[-1, ], stringsAsFactors = FALSE)
        names(df) <- dat[1, ]
        df$year <- yr
        df$ESTAB <- as.integer(df$ESTAB)
        df$EMP <- as.integer(df$EMP)
        df$PAYANN <- as.numeric(df$PAYANN)
        return(df)
      }
    }
    return(NULL)
  }, error = function(e) {
    cat(sprintf("  CBP %d error: %s\n", yr, e$message))
    return(NULL)
  })
}

cbp_list <- list()
for (yr in 1988:2021) {
  cat(sprintf("  CBP year %d...\n", yr))
  result <- fetch_cbp_year(yr)
  if (!is.null(result)) {
    cbp_list[[as.character(yr)]] <- result
  }
  Sys.sleep(0.3)
}

cbp_raw <- bind_rows(cbp_list)
cat(sprintf("CBP: %d state-year observations across %d years\n",
            nrow(cbp_raw), length(unique(cbp_raw$year))))

saveRDS(cbp_raw, "../data/cbp_raw.rds")

# ============================================================
# 4. BDS (Business Dynamics Statistics) — Try Census API
# ============================================================

cat("\n--- Fetching BDS data ---\n")

bds_list <- list()
for (yr in 1978:2021) {
  tryCatch({
    url <- sprintf(
      "https://api.census.gov/data/timeseries/bds?get=FIRM,ESTAB,ESTABS_ENTRY,ESTABS_EXIT,JOB_CREATION,JOB_DESTRUCTION,NET_JOB_CREATION,EMP&for=state:*&time=%d&NAICS=00",
      yr
    )
    resp <- GET(url)
    if (status_code(resp) %in% c(200, 204)) {
      raw <- content(resp, "text", encoding = "UTF-8")
      if (nchar(raw) > 50) {
        dat <- fromJSON(raw)
        df <- as.data.frame(dat[-1, ], stringsAsFactors = FALSE)
        names(df) <- dat[1, ]
        df$year <- yr
        bds_list[[as.character(yr)]] <- df
        cat(sprintf("  BDS %d: %d states\n", yr, nrow(df)))
      }
    }
    Sys.sleep(0.2)
  }, error = function(e) NULL)
}

if (length(bds_list) > 0) {
  bds_raw <- bind_rows(bds_list)
  cat(sprintf("BDS: %d state-year observations\n", nrow(bds_raw)))
  saveRDS(bds_raw, "../data/bds_raw.rds")
} else {
  cat("BDS API returned no data — will construct dynamism from CBP.\n")
}

# ============================================================
# 5. STATE POPULATION (for per-capita scaling)
# ============================================================

cat("\n--- Fetching state population ---\n")

pop_list <- list()
for (fips in names(gdp_series)) {
  series_id <- paste0(
    c("01"="AL","02"="AK","04"="AZ","05"="AR","06"="CA","08"="CO",
      "09"="CT","10"="DE","12"="FL","13"="GA","15"="HI","16"="ID",
      "17"="IL","18"="IN","19"="IA","20"="KS","21"="KY","22"="LA",
      "23"="ME","24"="MD","25"="MA","26"="MI","27"="MN","28"="MS",
      "29"="MO","30"="MT","31"="NE","32"="NV","33"="NH","34"="NJ",
      "35"="NM","36"="NY","37"="NC","38"="ND","39"="OH","40"="OK",
      "41"="OR","42"="PA","44"="RI","45"="SC","46"="SD","47"="TN",
      "48"="TX","49"="UT","50"="VT","51"="VA","53"="WA","54"="WV",
      "55"="WI","56"="WY")[fips],
    "POP"
  )
  tryCatch({
    obs <- fredr(series_id = series_id,
                 observation_start = as.Date("1977-01-01"),
                 observation_end = as.Date("2023-12-31"))
    if (nrow(obs) > 0) {
      pop_list[[fips]] <- obs %>%
        transmute(
          state_fips = fips,
          year = as.integer(format(date, "%Y")),
          population = as.numeric(value) * 1000  # FRED reports in thousands
        )
    }
    Sys.sleep(0.15)
  }, error = function(e) NULL)
}

state_pop <- bind_rows(pop_list)
cat(sprintf("Population: %d state-year observations\n", nrow(state_pop)))
saveRDS(state_pop, "../data/state_pop.rds")

cat("\n=== DATA FETCH COMPLETE ===\n")
cat(sprintf("Files saved in ../data/:\n"))
cat("  treatment_dates.rds\n")
cat("  state_gdp.rds\n")
cat("  state_comp.rds\n")
cat("  cbp_raw.rds\n")
cat("  state_pop.rds\n")
if (length(bds_list) > 0) cat("  bds_raw.rds\n")
