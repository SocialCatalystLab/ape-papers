###############################################################################
# 01_fetch_data.R
# Paper 141: EERS and Residential Electricity Consumption (Revision of apep_0130)
# Fetch all data from EIA API and compile treatment coding
###############################################################################

source("00_packages.R")

# ── Output directory ──
data_dir <- "../data/"
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

###############################################################################
# PART 1: EERS Treatment Coding
#
# DATA PROVENANCE:
#   Primary sources:
#     - ACEEE State EE Scorecard: https://www.aceee.org/state-policy/scorecard
#     - DSIRE: https://www.dsireusa.org/
#     - NCSL Energy Policy Database: https://www.ncsl.org/energy
#   Access date: 2026-01-27
#   Raw source file: data/raw/eers_adoption_sources.csv
#   Validation: Run 01d_validate_provenance.R to verify against source file
#
# METHODOLOGY:
#   Treatment definition: First year of a BINDING MANDATORY EERS with
#   quantitative savings targets. Voluntary goals and RPS energy efficiency
#   carve-outs are excluded unless they impose separate binding requirements.
###############################################################################

# EERS adoption year = first year with BINDING mandatory savings targets
# Voluntary goals and RPS energy efficiency carve-outs excluded unless binding
# DATA SOURCE: Read from documented raw CSV file
eers_raw_file <- paste0(data_dir, "raw/eers_adoption_sources.csv")
if (file.exists(eers_raw_file)) {
  eers_treatment <- read_csv(eers_raw_file, show_col_types = FALSE) %>%
    select(state_abbr, state_name, eers_year, eers_type)
  cat("Loaded EERS treatment data from:", eers_raw_file, "\n")
} else {
  # Fallback for backward compatibility (documented in DATA_SOURCES.md)
  cat("WARNING: Raw CSV not found, using embedded data\n")
  eers_treatment <- tribble(
    ~state_abbr, ~state_name,           ~eers_year, ~eers_type,
    "AZ",        "Arizona",              2010,       "mandatory",
    "AR",        "Arkansas",             2010,       "mandatory",
    "CA",        "California",           2004,       "mandatory",
    "CO",        "Colorado",             2007,       "mandatory",
    "CT",        "Connecticut",          1998,       "mandatory",
    "DC",        "District of Columbia", 2008,       "mandatory",
    "HI",        "Hawaii",              2009,       "mandatory",
    "IL",        "Illinois",            2007,       "mandatory",
    "IA",        "Iowa",                2019,       "mandatory",
    "ME",        "Maine",               2020,       "mandatory",
    "MD",        "Maryland",            2008,       "mandatory",
    "MA",        "Massachusetts",       2008,       "mandatory",
    "MI",        "Michigan",            2008,       "mandatory",
    "MN",        "Minnesota",           2007,       "mandatory",
    "NV",        "Nevada",              2005,       "mandatory",
    "NH",        "New Hampshire",       2018,       "mandatory",
    "NJ",        "New Jersey",          2018,       "mandatory",
    "NM",        "New Mexico",          2008,       "mandatory",
    "NY",        "New York",            2008,       "mandatory",
    "NC",        "North Carolina",      2008,       "mandatory",
    "OR",        "Oregon",              2016,       "mandatory",
    "PA",        "Pennsylvania",        2008,       "mandatory",
    "RI",        "Rhode Island",        2006,       "mandatory",
    "TX",        "Texas",               1999,       "mandatory",
    "VT",        "Vermont",             2000,       "mandatory",
    "VA",        "Virginia",            2020,       "mandatory",
    "WA",        "Washington",          2006,       "mandatory",
    "WI",        "Wisconsin",           2005,       "mandatory"
  )
}

# Never-treated states
never_treated <- tribble(
  ~state_abbr, ~state_name,
  "AL",        "Alabama",
  "AK",        "Alaska",
  "DE",        "Delaware",
  "FL",        "Florida",
  "GA",        "Georgia",
  "ID",        "Idaho",
  "IN",        "Indiana",
  "KS",        "Kansas",
  "KY",        "Kentucky",
  "LA",        "Louisiana",
  "MS",        "Mississippi",
  "MO",        "Missouri",
  "MT",        "Montana",
  "NE",        "Nebraska",
  "ND",        "North Dakota",
  "OH",        "Ohio",
  "OK",        "Oklahoma",
  "SC",        "South Carolina",
  "SD",        "South Dakota",
  "TN",        "Tennessee",
  "UT",        "Utah",
  "WV",        "West Virginia",
  "WY",        "Wyoming"
)
never_treated$eers_year <- 0L
never_treated$eers_type <- "never_treated"

treatment_df <- bind_rows(eers_treatment, never_treated)

cat("Treatment coding compiled:", nrow(eers_treatment), "treated states,",
    nrow(never_treated), "never-treated states\n")

###############################################################################
# PART 2: EIA API — Residential Electricity Consumption (SEDS)
###############################################################################

fetch_eia_seds <- function(series_id, start_year = 1990, end_year = 2023) {
  all_data <- list()
  offset <- 0
  page_size <- 5000

  repeat {
    url <- paste0(
      "https://api.eia.gov/v2/seds/data/",
      "?api_key=DEMO_KEY",
      "&frequency=annual",
      "&data[0]=value",
      "&facets[seriesId][]=", series_id,
      "&start=", start_year,
      "&end=", end_year,
      "&length=", page_size,
      "&offset=", offset
    )

    response <- GET(url)
    if (status_code(response) != 200) {
      warning("EIA API returned status ", status_code(response))
      break
    }

    json_data <- content(response, "parsed")
    records <- json_data$response$data

    if (length(records) == 0) break

    page_df <- bind_rows(lapply(records, function(r) {
      tibble(
        year = as.integer(r$period),
        state_abbr = r$stateId,
        state_name = r$stateDescription,
        series_id = r$seriesId,
        value = as.numeric(r$value),
        unit = r$unit
      )
    }))

    all_data[[length(all_data) + 1]] <- page_df
    offset <- offset + page_size

    total <- as.integer(json_data$response$total)
    if (offset >= total) break

    Sys.sleep(0.5)  # Rate limiting
  }

  bind_rows(all_data)
}

cat("Fetching residential electricity consumption (SEDS)...\n")
# ESRCB = Electricity consumed by residential sector (Billion Btu)
res_consumption <- fetch_eia_seds("ESRCB")
cat("  Residential electricity: ", nrow(res_consumption), " records\n")

cat("Fetching total electricity consumption (SEDS)...\n")
# ESTCB = Electricity total consumption (Billion Btu)
total_consumption <- fetch_eia_seds("ESTCB")
cat("  Total electricity: ", nrow(total_consumption), " records\n")

cat("Fetching commercial electricity consumption (SEDS)...\n")
# ESCCB = Electricity consumed by commercial sector
com_consumption <- fetch_eia_seds("ESCCB")
cat("  Commercial electricity: ", nrow(com_consumption), " records\n")

cat("Fetching industrial electricity consumption (SEDS)...\n")
# ESICB = Electricity consumed by industrial sector
ind_consumption <- fetch_eia_seds("ESICB")
cat("  Industrial electricity: ", nrow(ind_consumption), " records\n")

###############################################################################
# PART 3: EIA API — Electricity Prices (Retail Sales)
###############################################################################

fetch_eia_prices <- function(sector_id, start_year = 1990, end_year = 2023) {
  all_data <- list()
  offset <- 0
  page_size <- 5000

  repeat {
    url <- paste0(
      "https://api.eia.gov/v2/electricity/retail-sales/data/",
      "?api_key=DEMO_KEY",
      "&frequency=annual",
      "&data[0]=price",
      "&data[1]=revenue",
      "&data[2]=sales",
      "&facets[sectorid][]=", sector_id,
      "&start=", start_year,
      "&end=", end_year,
      "&length=", page_size,
      "&offset=", offset
    )

    response <- GET(url)
    if (status_code(response) != 200) {
      warning("EIA price API returned status ", status_code(response))
      break
    }

    json_data <- content(response, "parsed")
    records <- json_data$response$data

    if (length(records) == 0) break

    page_df <- bind_rows(lapply(records, function(r) {
      tibble(
        year = as.integer(r$period),
        state_abbr = r$stateid,
        state_name = r$stateDescription,
        sector = r$sectorName,
        price_cents_kwh = as.numeric(r$price),
        revenue_thousand_dollars = as.numeric(r$revenue),
        sales_mwh = as.numeric(r$sales)
      )
    }))

    all_data[[length(all_data) + 1]] <- page_df
    offset <- offset + page_size

    total <- as.integer(json_data$response$total)
    if (offset >= total) break

    Sys.sleep(0.5)
  }

  bind_rows(all_data)
}

cat("Fetching residential electricity prices...\n")
res_prices <- fetch_eia_prices("RES")
cat("  Residential prices: ", nrow(res_prices), " records\n")

cat("Fetching commercial electricity prices...\n")
com_prices <- fetch_eia_prices("COM")
cat("  Commercial prices: ", nrow(com_prices), " records\n")

###############################################################################
# PART 4: Census Population Data
###############################################################################

cat("Fetching state population data from Census API...\n")

# Census Population Estimates API
# 2000-2009 intercensal estimates
fetch_census_pop_2000s <- function() {
  url <- "https://api.census.gov/data/2000/pep/int_population?get=POP,DATE_DESC,GEONAME&for=state:*"
  response <- GET(url)
  if (status_code(response) != 200) {
    warning("Census 2000s API failed")
    return(tibble())
  }
  json <- content(response, "text", encoding = "UTF-8")
  mat <- fromJSON(json)
  df <- as_tibble(mat[-1, ], .name_repair = "minimal")
  colnames(df) <- mat[1, ]
  df %>%
    mutate(
      population = as.numeric(POP),
      state_fips = state,
      state_name = GEONAME
    ) %>%
    filter(grepl("^7/1/", DATE_DESC)) %>%
    mutate(year = as.integer(gsub(".*7/1/(\\d{4}).*", "\\1", DATE_DESC))) %>%
    select(year, state_fips, state_name, population)
}

# 2010-2019 estimates
fetch_census_pop_2010s <- function() {
  url <- "https://api.census.gov/data/2019/pep/population?get=POP,DATE_CODE,NAME&for=state:*"
  response <- GET(url)
  if (status_code(response) != 200) {
    warning("Census 2010s API failed")
    return(tibble())
  }
  json <- content(response, "text", encoding = "UTF-8")
  mat <- fromJSON(json)
  df <- as_tibble(mat[-1, ], .name_repair = "minimal")
  colnames(df) <- mat[1, ]
  df %>%
    mutate(
      population = as.numeric(POP),
      date_code = as.integer(DATE_CODE),
      state_fips = state,
      state_name = NAME
    ) %>%
    # DATE_CODE: 3=2010, 4=2011, ..., 12=2019
    filter(date_code >= 3 & date_code <= 12) %>%
    mutate(year = 2007 + date_code) %>%
    select(year, state_fips, state_name, population)
}

# 2020-2023 estimates
fetch_census_pop_2020s <- function() {
  url <- "https://api.census.gov/data/2023/pep/population?get=POP_2020,POP_2021,POP_2022,POP_2023,NAME&for=state:*"
  response <- GET(url)
  if (status_code(response) != 200) {
    warning("Census 2020s API failed, trying alternative...")
    # Try vintage 2022
    url2 <- "https://api.census.gov/data/2022/pep/population?get=POP_2020,POP_2021,POP_2022,NAME&for=state:*"
    response <- GET(url2)
    if (status_code(response) != 200) {
      warning("Census 2020s alternative also failed")
      return(tibble())
    }
  }
  json <- content(response, "text", encoding = "UTF-8")
  mat <- fromJSON(json)
  df <- as_tibble(mat[-1, ], .name_repair = "minimal")
  colnames(df) <- mat[1, ]

  pop_cols <- grep("^POP_", colnames(df), value = TRUE)
  df %>%
    mutate(state_fips = state, state_name = NAME) %>%
    pivot_longer(
      cols = all_of(pop_cols),
      names_to = "pop_year",
      values_to = "population"
    ) %>%
    mutate(
      year = as.integer(gsub("POP_", "", pop_year)),
      population = as.numeric(population)
    ) %>%
    select(year, state_fips, state_name, population)
}

# Fetch all periods
pop_2000s <- tryCatch(fetch_census_pop_2000s(), error = function(e) { cat("2000s pop failed:", e$message, "\n"); tibble() })
pop_2010s <- tryCatch(fetch_census_pop_2010s(), error = function(e) { cat("2010s pop failed:", e$message, "\n"); tibble() })
pop_2020s <- tryCatch(fetch_census_pop_2020s(), error = function(e) { cat("2020s pop failed:", e$message, "\n"); tibble() })

population <- bind_rows(pop_2000s, pop_2010s, pop_2020s)
cat("  Population records (2000-2023):", nrow(population), "\n")

###############################################################################
# PART 4b: 1990 Census State Population (for interpolation to 1990s)
#
# DATA PROVENANCE:
#   Source: U.S. Census Bureau, 1990 Decennial Census (Summary File 1)
#   URL: https://www.census.gov/data/tables/time-series/dec/popchange-data-text.html
#   Alternative: https://data.census.gov/table?q=1990+decennial+census+population+by+state
#   Access date: 2026-01-27
#   Raw source file: data/raw/census_1990_population.csv
#   Validation: Run 01d_validate_provenance.R to verify against source file
#
# NOTES:
#   - The Census API does not reliably serve 1990 Decennial Census data
#   - These are official SF1 counts, not estimates
#   - Total US 1990 population checksum: 248,709,873
###############################################################################

cat("Adding 1990 Census state populations for interpolation...\n")

census_1990 <- tribble(
  ~state_fips, ~pop_1990,
  "01", 4040587,   # Alabama
  "02",  550043,   # Alaska
  "04", 3665228,   # Arizona
  "05", 2350725,   # Arkansas
  "06", 29760021,  # California
  "08", 3294394,   # Colorado
  "09", 3287116,   # Connecticut
  "10",  666168,   # Delaware
  "11",  606900,   # District of Columbia
  "12", 12937926,  # Florida
  "13", 6478216,   # Georgia
  "15", 1108229,   # Hawaii
  "16", 1006749,   # Idaho
  "17", 11430602,  # Illinois
  "18", 5544159,   # Indiana
  "19", 2776755,   # Iowa
  "20", 2477574,   # Kansas
  "21", 3685296,   # Kentucky
  "22", 4219973,   # Louisiana
  "23", 1227928,   # Maine
  "24", 4781468,   # Maryland
  "25", 6016425,   # Massachusetts
  "26", 9295297,   # Michigan
  "27", 4375099,   # Minnesota
  "28", 2573216,   # Mississippi
  "29", 5117073,   # Missouri
  "30",  799065,   # Montana
  "31", 1578385,   # Nebraska
  "32", 1201833,   # Nevada
  "33", 1109252,   # New Hampshire
  "34", 7730188,   # New Jersey
  "35", 1515069,   # New Mexico
  "36", 17990455,  # New York
  "37", 6628637,   # North Carolina
  "38",  638800,   # North Dakota
  "39", 10847115,  # Ohio
  "40", 3145585,   # Oklahoma
  "41", 2842321,   # Oregon
  "42", 11881643,  # Pennsylvania
  "44", 1003464,   # Rhode Island
  "45", 3486703,   # South Carolina
  "46",  696004,   # South Dakota
  "47", 4877185,   # Tennessee
  "48", 16986510,  # Texas
  "49", 1722850,   # Utah
  "50",  562758,   # Vermont
  "51", 6187358,   # Virginia
  "53", 4866692,   # Washington
  "54", 1793477,   # West Virginia
  "55", 4891769,   # Wisconsin
  "56",  453588    # Wyoming
)

# Get 2000 Census base population from the intercensal data
pop_2000_base <- pop_2000s %>%
  filter(year == 2000) %>%
  select(state_fips, pop_2000 = population)

# Interpolate 1990-1999 using linear interpolation between 1990 and 2000 Census
pop_1990s_interp <- census_1990 %>%
  left_join(pop_2000_base, by = "state_fips") %>%
  filter(!is.na(pop_2000)) %>%
  crossing(year = 1990:1999) %>%
  mutate(
    # Linear interpolation: pop = pop_1990 + (pop_2000 - pop_1990) * (year - 1990) / 10
    population = as.numeric(round(pop_1990 + (pop_2000 - pop_1990) * (year - 1990) / 10))
  ) %>%
  select(year, state_fips, pop_1990, pop_2000, population)

cat("  1990s interpolated population records:", nrow(pop_1990s_interp), "\n")

# Combine all population data
population <- bind_rows(
  pop_1990s_interp %>% select(year, state_fips, population),
  population
)
cat("  Total population records:", nrow(population), "\n")

###############################################################################
# PART 5: State FIPS crosswalk
###############################################################################

state_fips <- tibble(
  state_abbr = c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL",
                  "GA","HI","ID","IL","IN","IA","KS","KY","LA","ME",
                  "MD","MA","MI","MN","MS","MO","MT","NE","NV","NH",
                  "NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI",
                  "SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"),
  state_fips = c("01","02","04","05","06","08","09","10","11","12",
                  "13","15","16","17","18","19","20","21","22","23",
                  "24","25","26","27","28","29","30","31","32","33",
                  "34","35","36","37","38","39","40","41","42","44",
                  "45","46","47","48","49","50","51","53","54","55","56"),
  state_name = c("Alabama","Alaska","Arizona","Arkansas","California",
                 "Colorado","Connecticut","Delaware","District of Columbia","Florida",
                 "Georgia","Hawaii","Idaho","Illinois","Indiana","Iowa","Kansas",
                 "Kentucky","Louisiana","Maine","Maryland","Massachusetts","Michigan",
                 "Minnesota","Mississippi","Missouri","Montana","Nebraska","Nevada",
                 "New Hampshire","New Jersey","New Mexico","New York","North Carolina",
                 "North Dakota","Ohio","Oklahoma","Oregon","Pennsylvania","Rhode Island",
                 "South Carolina","South Dakota","Tennessee","Texas","Utah","Vermont",
                 "Virginia","Washington","West Virginia","Wisconsin","Wyoming")
)

###############################################################################
# PART 6: Save all raw data
###############################################################################

saveRDS(treatment_df, paste0(data_dir, "eers_treatment.rds"))
saveRDS(res_consumption, paste0(data_dir, "res_consumption_raw.rds"))
saveRDS(total_consumption, paste0(data_dir, "total_consumption_raw.rds"))
saveRDS(com_consumption, paste0(data_dir, "com_consumption_raw.rds"))
saveRDS(ind_consumption, paste0(data_dir, "ind_consumption_raw.rds"))
saveRDS(res_prices, paste0(data_dir, "res_prices_raw.rds"))
saveRDS(com_prices, paste0(data_dir, "com_prices_raw.rds"))
saveRDS(population, paste0(data_dir, "population_raw.rds"))
saveRDS(state_fips, paste0(data_dir, "state_fips.rds"))

cat("\n=== DATA FETCH COMPLETE ===\n")
cat("Residential consumption:", nrow(res_consumption), "records\n")
cat("Total consumption:", nrow(total_consumption), "records\n")
cat("Commercial consumption:", nrow(com_consumption), "records\n")
cat("Industrial consumption:", nrow(ind_consumption), "records\n")
cat("Residential prices:", nrow(res_prices), "records\n")
cat("Population:", nrow(population), "records\n")
cat("Treatment:", nrow(eers_treatment), "treated +", nrow(never_treated), "control states\n")
