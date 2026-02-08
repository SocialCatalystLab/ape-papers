# 01_fetch_data.R — Load pre-fetched data and create RPS policy data
# Paper 113: RPS and Electricity Sector Employment
# Data was fetched via 01_fetch_data.py (Census API)

source("00_packages.R")

cat("=== Loading pre-fetched data ===\n\n")

# ==============================================================================
# PART 1: Load electricity sector PUMS data
# ==============================================================================

pums_elec <- read.csv("../data/pums_electricity.csv", stringsAsFactors = FALSE)
cat(sprintf("Electricity sector PUMS: %s records\n", format(nrow(pums_elec), big.mark = ",")))

# ==============================================================================
# PART 2: Load all utilities PUMS data
# ==============================================================================

pums_util <- read.csv("../data/pums_utilities.csv", stringsAsFactors = FALSE)
cat(sprintf("Utility sector PUMS: %s records\n", format(nrow(pums_util), big.mark = ",")))

# ==============================================================================
# PART 3: Load state-year aggregate employment data
# ==============================================================================

state_agg <- read.csv("../data/state_year_aggregates.csv", stringsAsFactors = FALSE)
cat(sprintf("State-year aggregates: %s records\n", format(nrow(state_agg), big.mark = ",")))

# ==============================================================================
# PART 4: Load industry data
# ==============================================================================

state_industry <- read.csv("../data/state_year_industry.csv", stringsAsFactors = FALSE)
cat(sprintf("State-year industry: %s records\n", format(nrow(state_industry), big.mark = ",")))

# ==============================================================================
# PART 5: Create RPS policy treatment data
# ==============================================================================

cat("\nCreating RPS policy treatment data...\n")

rps_data <- tribble(
  ~state_fips, ~state_abbr, ~state_name,           ~rps_first_binding,  ~rps_target_2025,
  "04",        "AZ",        "Arizona",              2006,                15,
  "06",        "CA",        "California",           2003,                60,
  "08",        "CO",        "Colorado",             2007,                30,
  "09",        "CT",        "Connecticut",          2000,                48,
  "10",        "DE",        "Delaware",             2007,                25,
  "15",        "HI",        "Hawaii",               2005,                40,
  "17",        "IL",        "Illinois",             2008,                25,
  "19",        "IA",        "Iowa",                 1999,                NA,
  "20",        "KS",        "Kansas",               2011,                20,
  "23",        "ME",        "Maine",                2000,                80,
  "24",        "MD",        "Maryland",             2006,                50,
  "25",        "MA",        "Massachusetts",        2003,                40,
  "26",        "MI",        "Michigan",             2012,                15,
  "27",        "MN",        "Minnesota",            2010,                25,
  "29",        "MO",        "Missouri",             2011,                15,
  "30",        "MT",        "Montana",              2008,                15,
  "32",        "NV",        "Nevada",               2003,                50,
  "33",        "NH",        "New Hampshire",        2008,                25,
  "34",        "NJ",        "New Jersey",           2001,                50,
  "36",        "NY",        "New York",             2006,                70,
  "37",        "NC",        "North Carolina",       2010,                12.5,
  "38",        "ND",        "North Dakota",         2010,                10,
  "39",        "OH",        "Ohio",                 2009,                12.5,
  "41",        "OR",        "Oregon",               2011,                50,
  "44",        "RI",        "Rhode Island",         2007,                38.5,
  "48",        "TX",        "Texas",                2003,                NA,
  "49",        "UT",        "Utah",                 2010,                20,
  "50",        "VT",        "Vermont",              2008,                75,
  "53",        "WA",        "Washington",           2012,                15,
  "55",        "WI",        "Wisconsin",            2001,                10,
  "11",        "DC",        "Washington DC",        2007,                100,
  "35",        "NM",        "New Mexico",           2006,                40,
  "42",        "PA",        "Pennsylvania",         2007,                18,
  "45",        "SC",        "South Carolina",       2015,                2,
  "22",        "LA",        "Louisiana",            2012,                NA
)

# States without RPS (never-treated)
no_rps <- tribble(
  ~state_fips, ~state_abbr, ~state_name,
  "01",        "AL",        "Alabama",
  "05",        "AR",        "Arkansas",
  "12",        "FL",        "Florida",
  "13",        "GA",        "Georgia",
  "16",        "ID",        "Idaho",
  "18",        "IN",        "Indiana",
  "21",        "KY",        "Kentucky",
  "28",        "MS",        "Mississippi",
  "31",        "NE",        "Nebraska",
  "40",        "OK",        "Oklahoma",
  "46",        "SD",        "South Dakota",
  "47",        "TN",        "Tennessee",
  "51",        "VA",        "Virginia",
  "54",        "WV",        "West Virginia",
  "56",        "WY",        "Wyoming",
  "02",        "AK",        "Alaska"
)
no_rps$rps_first_binding <- NA
no_rps$rps_target_2025 <- NA

rps_policy <- bind_rows(rps_data, no_rps) %>%
  mutate(
    treatment_year = ifelse(is.na(rps_first_binding), 0, rps_first_binding),
    ever_treated = !is.na(rps_first_binding)
  )

cat(sprintf("RPS states: %d treated, %d never-treated\n",
            sum(rps_policy$ever_treated), sum(!rps_policy$ever_treated)))

saveRDS(rps_policy, "../data/rps_policy.rds")

# ==============================================================================
# Save all loaded data as RDS for R
# ==============================================================================

saveRDS(pums_elec, "../data/pums_electricity.rds")
saveRDS(pums_util, "../data/pums_utilities.rds")
saveRDS(state_agg, "../data/state_aggregates.rds")
saveRDS(state_industry, "../data/state_industry.rds")

cat("\n=== Data loading complete ===\n")
