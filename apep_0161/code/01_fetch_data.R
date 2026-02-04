# ============================================================
# 01_fetch_data.R - Fetch mortality and population data
# Paper 145: State Insulin Copay Caps and Working-Age
#             Diabetes Mortality (v4)
# Revision of apep_0157 (family apep_0150)
# ============================================================
# Data Sources:
#   1. CDC NCHS Leading Causes of Death (bi63-dtpu): 1999-2017
#      Age-adjusted diabetes death rates by state, ICD-10 E10-E14
#      URL: https://data.cdc.gov/NCHS/NCHS-Leading-Causes-of-Death-United-States/bi63-dtpu
#   2. CDC MMWR Weekly Counts (muzy-jte6): 2020-2023
#      Weekly diabetes death counts by jurisdiction, aggregated to annual
#      URL: https://data.cdc.gov/NCHS/Weekly-Provisional-Counts-of-Deaths-by-State-and-S/muzy-jte6
#   3. CDC Provisional Mortality Statistics (489q-934x): 2023-2025
#      Quarterly rolling age-adjusted rates by state (validation)
#      URL: https://data.cdc.gov/NCHS/AH-Provisional-Mortality-Statistics/489q-934x
#   4. Policy database compiled from state legislation
#      Sources: NCSL (https://www.ncsl.org/health/insulin-cost-and-coverage-legislation),
#               ADA state advocacy, Beyond Type 1, state session laws
#
# Outputs (saved to data/):
#   - mortality_data.rds, mortality_data.csv  <- from PART 3-4
#   - placebo_cancer.rds                      <- from PART 5
#   - placebo_heart.rds                       <- from PART 5
#   - placebo_cancer_post.rds                 <- from PART 5B
#   - placebo_heart_post.rds                  <- from PART 5B
#   - policy_database.csv                     <- from PART 1
#   - state_lookup.rds                        <- from PART 2
# ============================================================

source("code/00_packages.R")

# Create data directory
dir.create("data", showWarnings = FALSE)

# ============================================================
# PART 1: Policy Database — Insulin Copay Cap Laws
# ============================================================

cat("\n=== Building Policy Database ===\n")

# Policy sources:
#   NCSL: https://www.ncsl.org/health/insulin-cost-and-coverage-legislation
#   ADA:  https://diabetes.org/advocacy/state-legislation
#   Beyond Type 1: https://beyondtype1.org/insulin-copay-cap-state-by-state/
#   State session laws (Legiscan, individual legislature websites)
policy_db <- tribble(
  ~state_abbr, ~state_name,          ~state_fips, ~effective_date, ~cap_amount,
  "CO",        "Colorado",           "08",        "2020-01-01",    100,
  "VA",        "Virginia",           "51",        "2020-07-01",    50,
  "WV",        "West Virginia",      "54",        "2020-07-01",    100,
  "MN",        "Minnesota",          "27",        "2020-07-01",    50,
  "IL",        "Illinois",           "17",        "2021-01-01",    100,
  "ME",        "Maine",              "23",        "2021-01-01",    35,
  "NM",        "New Mexico",         "35",        "2021-01-01",    25,
  "NY",        "New York",           "36",        "2021-01-01",    100,
  "UT",        "Utah",               "49",        "2021-01-01",    30,
  "WA",        "Washington",         "53",        "2021-01-01",    100,
  "DE",        "Delaware",           "10",        "2021-01-01",    100,
  "NH",        "New Hampshire",      "33",        "2021-01-01",    30,
  "TX",        "Texas",              "48",        "2021-09-01",    25,
  "CT",        "Connecticut",        "09",        "2022-01-01",    25,
  "VT",        "Vermont",            "50",        "2022-01-01",    100,
  "OK",        "Oklahoma",           "40",        "2022-11-01",    30,
  "WI",        "Wisconsin",          "55",        "2023-01-01",    35,
  "KY",        "Kentucky",           "21",        "2023-01-01",    30,
  "WY",        "Wyoming",            "56",        "2023-07-01",    100,
  "GA",        "Georgia",            "13",        "2023-07-01",    35,
  "MT",        "Montana",            "30",        "2023-10-01",    35,
  "OH",        "Ohio",               "39",        "2024-01-01",    35,
  "NE",        "Nebraska",           "31",        "2024-01-01",    100,
  "IN",        "Indiana",            "18",        "2024-07-01",    35,
  "NC",        "North Carolina",     "37",        "2024-01-01",    50,
  "LA",        "Louisiana",          "22",        "2024-01-01",    100
)

policy_db <- policy_db %>%
  mutate(
    effective_date = as.Date(effective_date),
    effective_year = year(effective_date),
    effective_month = month(effective_date),
    first_treat = case_when(
      effective_month == 1 & day(effective_date) == 1 ~ effective_year,
      TRUE ~ effective_year + 1
    )
  )

cat("Policy database: ", nrow(policy_db), " states with copay cap laws\n")
cat("Treatment year range: ", min(policy_db$first_treat), "-", max(policy_db$first_treat), "\n")
cat("Treatment cohorts:\n")
print(table(policy_db$first_treat))

write_csv(policy_db, "data/policy_database.csv")
cat("Saved data/policy_database.csv\n")

# ============================================================
# PART 2: All 50 states + DC — FIPS lookup
# ============================================================

all_states <- tribble(
  ~state_fips, ~state_abbr, ~state_name,
  "01", "AL", "Alabama",
  "02", "AK", "Alaska",
  "04", "AZ", "Arizona",
  "05", "AR", "Arkansas",
  "06", "CA", "California",
  "08", "CO", "Colorado",
  "09", "CT", "Connecticut",
  "10", "DE", "Delaware",
  "11", "DC", "District of Columbia",
  "12", "FL", "Florida",
  "13", "GA", "Georgia",
  "15", "HI", "Hawaii",
  "16", "ID", "Idaho",
  "17", "IL", "Illinois",
  "18", "IN", "Indiana",
  "19", "IA", "Iowa",
  "20", "KS", "Kansas",
  "21", "KY", "Kentucky",
  "22", "LA", "Louisiana",
  "23", "ME", "Maine",
  "24", "MD", "Maryland",
  "25", "MA", "Massachusetts",
  "26", "MI", "Michigan",
  "27", "MN", "Minnesota",
  "28", "MS", "Mississippi",
  "29", "MO", "Missouri",
  "30", "MT", "Montana",
  "31", "NE", "Nebraska",
  "32", "NV", "Nevada",
  "33", "NH", "New Hampshire",
  "34", "NJ", "New Jersey",
  "35", "NM", "New Mexico",
  "36", "NY", "New York",
  "37", "NC", "North Carolina",
  "38", "ND", "North Dakota",
  "39", "OH", "Ohio",
  "40", "OK", "Oklahoma",
  "41", "OR", "Oregon",
  "42", "PA", "Pennsylvania",
  "44", "RI", "Rhode Island",
  "45", "SC", "South Carolina",
  "46", "SD", "South Dakota",
  "47", "TN", "Tennessee",
  "48", "TX", "Texas",
  "49", "UT", "Utah",
  "50", "VT", "Vermont",
  "51", "VA", "Virginia",
  "53", "WA", "Washington",
  "54", "WV", "West Virginia",
  "55", "WI", "Wisconsin",
  "56", "WY", "Wyoming"
)

# ============================================================
# PART 3A: Fetch Historical Mortality (1999-2017)
# ============================================================
# Source: CDC NCHS Leading Causes of Death (bi63-dtpu)
# Provides all-ages age-adjusted death rates by state

cat("\n=== Fetching Historical Mortality Data (1999-2017) ===\n")

historical_data <- tryCatch({
  resp <- GET(
    "https://data.cdc.gov/resource/bi63-dtpu.csv",
    query = list(
      `$where` = "cause_name='Diabetes' AND state<>'United States'",
      `$select` = "year,state,deaths,aadr",
      `$limit` = 5000,
      `$order` = "year,state"
    ),
    timeout(120)
  )

  if (status_code(resp) == 200) {
    df <- read_csv(content(resp, "text", encoding = "UTF-8"), show_col_types = FALSE)
    cat("  Historical data:", nrow(df), "rows,", length(unique(df$year)), "years\n")
    cat("  Year range:", min(df$year), "-", max(df$year), "\n")
    df
  } else {
    cat("  HTTP error:", status_code(resp), "\n")
    NULL
  }
}, error = function(e) {
  cat("  API error:", e$message, "\n")
  NULL
})

if (is.null(historical_data)) {
  stop("FATAL: Cannot fetch historical CDC mortality data. Cannot proceed.")
}

# Standardize to match our state list
historical_clean <- historical_data %>%
  rename(
    state_name = state,
    mortality_deaths = deaths,
    mortality_rate = aadr
  ) %>%
  mutate(
    year = as.integer(year),
    mortality_deaths = as.integer(mortality_deaths),
    mortality_rate = as.numeric(mortality_rate)
  ) %>%
  left_join(all_states, by = "state_name") %>%
  filter(!is.na(state_fips)) %>%
  select(state_fips, state_abbr, state_name, year, mortality_deaths, mortality_rate) %>%
  mutate(data_source = "CDC_NCHS_bi63dtpu")

cat("  Cleaned historical data:", nrow(historical_clean), "rows\n")
cat("  States:", length(unique(historical_clean$state_fips)), "\n")

# ============================================================
# PART 3B: Fetch Recent Mortality (2020-2023)
# ============================================================
# Source: CDC MMWR Weekly Provisional Counts (muzy-jte6)
# Weekly diabetes death counts by jurisdiction, aggregate to annual

cat("\n=== Fetching Recent Mortality Data (2020-2023) ===\n")

recent_weekly <- tryCatch({
  resp <- GET(
    "https://data.cdc.gov/resource/muzy-jte6.csv",
    query = list(
      `$select` = "jurisdiction_of_occurrence,mmwryear,sum(diabetes_mellitus_e10_e14) as annual_deaths",
      `$where` = "jurisdiction_of_occurrence<>'United States' AND jurisdiction_of_occurrence<>'Puerto Rico'",
      `$group` = "jurisdiction_of_occurrence,mmwryear",
      `$order` = "mmwryear,jurisdiction_of_occurrence",
      `$limit` = 500
    ),
    timeout(120)
  )

  if (status_code(resp) == 200) {
    df <- read_csv(content(resp, "text", encoding = "UTF-8"), show_col_types = FALSE)
    cat("  Weekly aggregated data:", nrow(df), "rows\n")
    df
  } else {
    cat("  HTTP error:", status_code(resp), "\n")
    NULL
  }
}, error = function(e) {
  cat("  API error:", e$message, "\n")
  NULL
})

# Also fetch Q4 rolling annual rates from provisional statistics for validation
recent_provisional <- tryCatch({
  resp <- GET(
    "https://data.cdc.gov/resource/489q-934x.csv",
    query = list(
      `$where` = paste0("cause_of_death='Diabetes'",
                        " AND time_period='12 months ending with quarter'",
                        " AND rate_type='Age-adjusted'"),
      `$limit` = 50,
      `$order` = "year_and_quarter"
    ),
    timeout(120)
  )

  if (status_code(resp) == 200) {
    df <- read_csv(content(resp, "text", encoding = "UTF-8"), show_col_types = FALSE)
    cat("  Provisional statistics:", nrow(df), "rows\n")
    df
  } else {
    cat("  Provisional HTTP error:", status_code(resp), "\n")
    NULL
  }
}, error = function(e) {
  cat("  Provisional API error:", e$message, "\n")
  NULL
})

# ============================================================
# PART 3C: Process Recent Data (2020-2023)
# ============================================================

cat("\n=== Processing Recent Data ===\n")

if (!is.null(recent_weekly)) {
  # Combine NY + NYC into single New York entry
  recent_clean <- recent_weekly %>%
    mutate(
      jurisdiction_of_occurrence = case_when(
        jurisdiction_of_occurrence == "New York City" ~ "New York",
        TRUE ~ jurisdiction_of_occurrence
      )
    ) %>%
    group_by(jurisdiction_of_occurrence, mmwryear) %>%
    summarise(mortality_deaths = sum(annual_deaths, na.rm = TRUE), .groups = "drop") %>%
    rename(state_name = jurisdiction_of_occurrence, year = mmwryear) %>%
    mutate(year = as.integer(year)) %>%
    left_join(all_states, by = "state_name") %>%
    filter(!is.na(state_fips))

  # Flag suppressed states (deaths = 0 due to weekly suppression)
  # FIX (Flag 3): Use is_suppressed column instead of dropping rows
  recent_clean <- recent_clean %>%
    mutate(is_suppressed = (mortality_deaths == 0))

  suppressed <- recent_clean %>%
    filter(is_suppressed) %>%
    distinct(state_name) %>%
    pull(state_name)

  if (length(suppressed) > 0) {
    cat("  Suppressed states (flagged, not dropped):", paste(suppressed, collapse = ", "), "\n")
    # Set deaths and rates to NA for suppressed observations (not dropped)
    recent_clean <- recent_clean %>%
      mutate(
        mortality_deaths = ifelse(is_suppressed, NA_integer_, mortality_deaths)
      )
  }

  cat("  Recent data: ", nrow(recent_clean), " state-year observations\n")
  cat("  States with data:", length(unique(recent_clean$state_fips)), "\n")
} else {
  stop("FATAL: Cannot fetch recent CDC weekly mortality data.")
}

# ============================================================
# PART 3D: Compute Rates for Recent Period
# ============================================================
# Use Census population estimates to compute crude death rates
# Then use provisional age-adjusted rates where available

cat("\n=== Fetching Population Data for Rate Computation ===\n")

# Fetch Census ACS 1-year population estimates for 2020-2023
pop_data <- list()

for (yr in 2020:2023) {
  cat("  Population", yr, "... ")

  pop_resp <- tryCatch({
    url <- paste0("https://api.census.gov/data/", yr,
                   "/acs/acs1?get=B01003_001E,NAME&for=state:*")
    resp <- GET(url, timeout(60))
    if (status_code(resp) == 200) {
      raw <- fromJSON(content(resp, "text", encoding = "UTF-8"))
      df <- as.data.frame(raw[-1, ], stringsAsFactors = FALSE)
      names(df) <- raw[1, ]
      df <- df %>%
        mutate(
          year = yr,
          population = as.integer(B01003_001E),
          state_fips = state
        ) %>%
        select(state_fips, year, population)
      cat("OK (", nrow(df), "states)\n")
      df
    } else {
      cat("HTTP", status_code(resp), "\n")
      NULL
    }
  }, error = function(e) {
    cat("error:", e$message, "\n")
    NULL
  })

  if (!is.null(pop_resp)) {
    pop_data[[as.character(yr)]] <- pop_resp
  }

  Sys.sleep(0.5)
}

# Try PEP endpoint for missing years
for (yr in 2020:2023) {
  if (is.null(pop_data[[as.character(yr)]])) {
    cat("  Retrying PEP for", yr, "... ")
    pop_resp <- tryCatch({
      url <- paste0("https://api.census.gov/data/", yr,
                     "/pep/population?get=POP,NAME&for=state:*")
      resp <- GET(url, timeout(60))
      if (status_code(resp) == 200) {
        raw <- fromJSON(content(resp, "text", encoding = "UTF-8"))
        df <- as.data.frame(raw[-1, ], stringsAsFactors = FALSE)
        names(df) <- raw[1, ]
        pop_col <- intersect(c("POP", "POP_2020", "POPESTIMATE"), names(df))
        if (length(pop_col) > 0) {
          df <- df %>%
            mutate(
              year = yr,
              population = as.integer(.data[[pop_col[1]]]),
              state_fips = state
            ) %>%
            select(state_fips, year, population)
          cat("OK\n")
          df
        } else {
          cat("no pop column\n")
          NULL
        }
      } else {
        cat("HTTP", status_code(resp), "\n")
        NULL
      }
    }, error = function(e) {
      cat("error\n")
      NULL
    })
    if (!is.null(pop_resp)) pop_data[[as.character(yr)]] <- pop_resp
  }
}

# For 2020, try Decennial Census if ACS/PEP failed
if (is.null(pop_data[["2020"]])) {
  cat("  Retrying Decennial for 2020 ... ")
  pop_resp <- tryCatch({
    url <- "https://api.census.gov/data/2020/dec/pl?get=P1_001N,NAME&for=state:*"
    resp <- GET(url, timeout(60))
    if (status_code(resp) == 200) {
      raw <- fromJSON(content(resp, "text", encoding = "UTF-8"))
      df <- as.data.frame(raw[-1, ], stringsAsFactors = FALSE)
      names(df) <- raw[1, ]
      df <- df %>%
        mutate(year = 2020L, population = as.integer(P1_001N), state_fips = state) %>%
        select(state_fips, year, population)
      cat("OK\n")
      df
    } else {
      cat("HTTP", status_code(resp), "\n")
      NULL
    }
  }, error = function(e) { cat("error\n"); NULL })
  if (!is.null(pop_resp)) pop_data[["2020"]] <- pop_resp
}

# If 2020 still missing, use 2021 as proxy
if (is.null(pop_data[["2020"]]) && !is.null(pop_data[["2021"]])) {
  cat("  Using 2021 population as proxy for 2020\n")
  pop_data[["2020"]] <- pop_data[["2021"]] %>% mutate(year = 2020L)
}

pop_all <- bind_rows(pop_data)
cat("  Population data:", nrow(pop_all), "state-year observations\n")

# Compute crude death rates for 2020-2023
recent_rates <- recent_clean %>%
  mutate(state_fips = sprintf("%02d", as.integer(state_fips))) %>%
  left_join(pop_all, by = c("state_fips", "year"))

# For states with population data, compute crude rate
recent_rates <- recent_rates %>%
  mutate(
    crude_rate = ifelse(!is.na(population) & population > 0,
                        (mortality_deaths / population) * 100000,
                        NA_real_)
  )

# Now incorporate age-adjusted rates from provisional dataset
if (!is.null(recent_provisional)) {
  # Extract Q4 annual values and pivot from wide to long
  prov_q4 <- recent_provisional %>%
    filter(grepl("Q4", year_and_quarter)) %>%
    mutate(year = as.integer(sub(" Q4", "", year_and_quarter)))

  # Pivot state columns to long format
  state_cols <- names(prov_q4)[grepl("^rate_", names(prov_q4)) &
                                !grepl("(overall|sex|age|type|unit)", names(prov_q4))]
  # Ensure only numeric columns
  state_cols <- state_cols[sapply(state_cols, function(x) is.numeric(prov_q4[[x]]))]

  prov_long <- prov_q4 %>%
    select(year, all_of(state_cols)) %>%
    pivot_longer(cols = all_of(state_cols),
                 names_to = "state_key",
                 values_to = "aadr_provisional") %>%
    mutate(
      state_name = gsub("^rate_", "", state_key),
      state_name = gsub("_", " ", state_name),
      state_name = str_to_title(state_name),
      # Fix specific names
      state_name = case_when(
        state_name == "District Of Columbia" ~ "District of Columbia",
        state_name == "New York" ~ "New York",
        state_name == "New Hampshire" ~ "New Hampshire",
        state_name == "New Jersey" ~ "New Jersey",
        state_name == "New Mexico" ~ "New Mexico",
        state_name == "North Carolina" ~ "North Carolina",
        state_name == "North Dakota" ~ "North Dakota",
        state_name == "South Carolina" ~ "South Carolina",
        state_name == "South Dakota" ~ "South Dakota",
        state_name == "West Virginia" ~ "West Virginia",
        state_name == "Rhode Island" ~ "Rhode Island",
        TRUE ~ state_name
      ),
      aadr_provisional = as.numeric(aadr_provisional)
    ) %>%
    left_join(all_states, by = "state_name") %>%
    filter(!is.na(state_fips)) %>%
    select(state_fips, year, aadr_provisional)

  cat("  Provisional AADR data:", nrow(prov_long), "state-year observations\n")

  # Merge provisional AADR into recent data
  recent_rates <- recent_rates %>%
    left_join(prov_long, by = c("state_fips", "year"))

  # Use provisional AADR as the primary rate where available
  # Fall back to crude rate
  recent_rates <- recent_rates %>%
    mutate(
      mortality_rate = coalesce(aadr_provisional, crude_rate),
      data_source = ifelse(!is.na(aadr_provisional),
                           "CDC_provisional_489q934x",
                           "CDC_MMWR_muzy_jte6_crude")
    )
} else {
  recent_rates <- recent_rates %>%
    mutate(
      mortality_rate = crude_rate,
      data_source = "CDC_MMWR_muzy_jte6_crude"
    )
}

recent_final <- recent_rates %>%
  select(state_fips, state_abbr, state_name, year,
         mortality_deaths, mortality_rate, data_source) %>%
  filter(!is.na(mortality_rate))

cat("  Final recent data:", nrow(recent_final), "state-year observations\n")

# ============================================================
# PART 4: Combine Historical + Recent
# ============================================================

cat("\n=== Combining Historical + Recent Data ===\n")

# Combine
mortality_combined <- bind_rows(historical_clean, recent_final) %>%
  arrange(state_fips, year)

cat("Combined panel:", nrow(mortality_combined), "state-year observations\n")
cat("Year range:", min(mortality_combined$year), "-", max(mortality_combined$year), "\n")
cat("States:", length(unique(mortality_combined$state_fips)), "\n")

# Check for gaps
year_coverage <- mortality_combined %>%
  group_by(state_fips) %>%
  summarise(
    min_year = min(year),
    max_year = max(year),
    n_years = n(),
    years_missing = paste(setdiff(1999:2023, year), collapse = ","),
    .groups = "drop"
  )

states_with_gaps <- year_coverage %>% filter(nchar(years_missing) > 0)
if (nrow(states_with_gaps) > 0) {
  cat("\nStates with year gaps:\n")
  print(states_with_gaps, n = 55)
  cat("\nNote: 2018-2019 gap is expected (between historical and weekly datasets)\n")
}

# ============================================================
# PART 5: Construct Placebo Outcomes
# ============================================================

cat("\n=== Constructing Placebo Outcome Data ===\n")

# Placebo 1: All-cause mortality from bi63-dtpu (for cancer, heart disease)
placebo_cancer <- tryCatch({
  resp <- GET(
    "https://data.cdc.gov/resource/bi63-dtpu.csv",
    query = list(
      `$where` = "cause_name='Cancer' AND state<>'United States'",
      `$select` = "year,state,deaths,aadr",
      `$limit` = 5000,
      `$order` = "year,state"
    ),
    timeout(120)
  )

  if (status_code(resp) == 200) {
    df <- read_csv(content(resp, "text", encoding = "UTF-8"), show_col_types = FALSE)
    cat("  Cancer mortality: ", nrow(df), " rows\n")
    df %>%
      rename(state_name = state,
             mortality_deaths_cancer = deaths,
             mortality_rate_cancer = aadr) %>%
      mutate(year = as.integer(year),
             mortality_deaths_cancer = as.integer(mortality_deaths_cancer),
             mortality_rate_cancer = as.numeric(mortality_rate_cancer)) %>%
      left_join(all_states, by = "state_name") %>%
      filter(!is.na(state_fips)) %>%
      select(state_fips, year, mortality_deaths_cancer, mortality_rate_cancer)
  } else {
    cat("  Cancer HTTP error:", status_code(resp), "\n")
    NULL
  }
}, error = function(e) {
  cat("  Cancer API error:", e$message, "\n")
  NULL
})

# Placebo 2: Heart disease from bi63-dtpu
placebo_heart <- tryCatch({
  resp <- GET(
    "https://data.cdc.gov/resource/bi63-dtpu.csv",
    query = list(
      `$where` = "cause_name='Heart disease' AND state<>'United States'",
      `$select` = "year,state,deaths,aadr",
      `$limit` = 5000,
      `$order` = "year,state"
    ),
    timeout(120)
  )

  if (status_code(resp) == 200) {
    df <- read_csv(content(resp, "text", encoding = "UTF-8"), show_col_types = FALSE)
    cat("  Heart disease mortality: ", nrow(df), " rows\n")
    df %>%
      rename(state_name = state,
             mortality_deaths_heart = deaths,
             mortality_rate_heart = aadr) %>%
      mutate(year = as.integer(year),
             mortality_deaths_heart = as.integer(mortality_deaths_heart),
             mortality_rate_heart = as.numeric(mortality_rate_heart)) %>%
      left_join(all_states, by = "state_name") %>%
      filter(!is.na(state_fips)) %>%
      select(state_fips, year, mortality_deaths_heart, mortality_rate_heart)
  } else {
    cat("  Heart HTTP error:", status_code(resp), "\n")
    NULL
  }
}, error = function(e) {
  cat("  Heart API error:", e$message, "\n")
  NULL
})

# ============================================================
# PART 5B: Fetch Post-Treatment Placebo Outcomes (2020-2023)
# ============================================================
# Source: CDC MMWR Weekly Provisional Counts (muzy-jte6)
# Cancer (malignant_neoplasms_c00_c97) and heart disease
# (diseases_of_heart_i00_i09) death counts by jurisdiction

cat("\n=== Fetching Post-Treatment Placebo Data (2020-2023) ===\n")

# Post-treatment cancer mortality from MMWR
placebo_cancer_post <- tryCatch({
  resp <- GET(
    "https://data.cdc.gov/resource/muzy-jte6.csv",
    query = list(
      `$select` = "jurisdiction_of_occurrence,mmwryear,sum(malignant_neoplasms_c00_c97) as annual_deaths",
      `$where` = "jurisdiction_of_occurrence<>'United States' AND jurisdiction_of_occurrence<>'Puerto Rico'",
      `$group` = "jurisdiction_of_occurrence,mmwryear",
      `$order` = "mmwryear,jurisdiction_of_occurrence",
      `$limit` = 500
    ),
    timeout(120)
  )

  if (status_code(resp) == 200) {
    df <- read_csv(content(resp, "text", encoding = "UTF-8"), show_col_types = FALSE)
    cat("  Post-treatment cancer data:", nrow(df), "rows\n")
    # Combine NY + NYC
    df <- df %>%
      mutate(jurisdiction_of_occurrence = case_when(
        jurisdiction_of_occurrence == "New York City" ~ "New York",
        TRUE ~ jurisdiction_of_occurrence
      )) %>%
      group_by(jurisdiction_of_occurrence, mmwryear) %>%
      summarise(mortality_deaths_cancer = sum(annual_deaths, na.rm = TRUE), .groups = "drop") %>%
      rename(state_name = jurisdiction_of_occurrence, year = mmwryear) %>%
      mutate(year = as.integer(year)) %>%
      left_join(all_states, by = "state_name") %>%
      filter(!is.na(state_fips)) %>%
      # FIX (Flag 4): Flag suppressed observations instead of dropping
      mutate(is_suppressed_cancer = (mortality_deaths_cancer == 0),
             mortality_deaths_cancer = ifelse(is_suppressed_cancer, NA_integer_, mortality_deaths_cancer))

    # Compute crude cancer rate using pop_all
    df <- df %>%
      mutate(state_fips = sprintf("%02d", as.integer(state_fips))) %>%
      left_join(pop_all, by = c("state_fips", "year")) %>%
      mutate(
        mortality_rate_cancer = ifelse(!is.na(population) & population > 0 & !is.na(mortality_deaths_cancer),
                                       (mortality_deaths_cancer / population) * 100000,
                                       NA_real_)
      ) %>%
      select(state_fips, year, mortality_deaths_cancer, mortality_rate_cancer, is_suppressed_cancer)

    cat("  Post-treatment cancer (with rates):", nrow(df), "rows\n")
    df
  } else {
    cat("  Cancer post-treatment HTTP error:", status_code(resp), "\n")
    NULL
  }
}, error = function(e) {
  cat("  Cancer post-treatment API error:", e$message, "\n")
  NULL
})

# Post-treatment heart disease mortality from MMWR
placebo_heart_post <- tryCatch({
  resp <- GET(
    "https://data.cdc.gov/resource/muzy-jte6.csv",
    query = list(
      `$select` = "jurisdiction_of_occurrence,mmwryear,sum(diseases_of_heart_i00_i09) as annual_deaths",
      `$where` = "jurisdiction_of_occurrence<>'United States' AND jurisdiction_of_occurrence<>'Puerto Rico'",
      `$group` = "jurisdiction_of_occurrence,mmwryear",
      `$order` = "mmwryear,jurisdiction_of_occurrence",
      `$limit` = 500
    ),
    timeout(120)
  )

  if (status_code(resp) == 200) {
    df <- read_csv(content(resp, "text", encoding = "UTF-8"), show_col_types = FALSE)
    cat("  Post-treatment heart data:", nrow(df), "rows\n")
    # Combine NY + NYC
    df <- df %>%
      mutate(jurisdiction_of_occurrence = case_when(
        jurisdiction_of_occurrence == "New York City" ~ "New York",
        TRUE ~ jurisdiction_of_occurrence
      )) %>%
      group_by(jurisdiction_of_occurrence, mmwryear) %>%
      summarise(mortality_deaths_heart = sum(annual_deaths, na.rm = TRUE), .groups = "drop") %>%
      rename(state_name = jurisdiction_of_occurrence, year = mmwryear) %>%
      mutate(year = as.integer(year)) %>%
      left_join(all_states, by = "state_name") %>%
      filter(!is.na(state_fips)) %>%
      # FIX (Flag 5): Flag suppressed observations instead of dropping
      mutate(is_suppressed_heart = (mortality_deaths_heart == 0),
             mortality_deaths_heart = ifelse(is_suppressed_heart, NA_integer_, mortality_deaths_heart))

    # Compute crude heart rate using pop_all
    df <- df %>%
      mutate(state_fips = sprintf("%02d", as.integer(state_fips))) %>%
      left_join(pop_all, by = c("state_fips", "year")) %>%
      mutate(
        mortality_rate_heart = ifelse(!is.na(population) & population > 0 & !is.na(mortality_deaths_heart),
                                      (mortality_deaths_heart / population) * 100000,
                                      NA_real_)
      ) %>%
      select(state_fips, year, mortality_deaths_heart, mortality_rate_heart, is_suppressed_heart)

    cat("  Post-treatment heart (with rates):", nrow(df), "rows\n")
    df
  } else {
    cat("  Heart post-treatment HTTP error:", status_code(resp), "\n")
    NULL
  }
}, error = function(e) {
  cat("  Heart post-treatment API error:", e$message, "\n")
  NULL
})

# ============================================================
# PART 6: Save All Data
# ============================================================

cat("\n=== Saving Fetched Data ===\n")

saveRDS(mortality_combined, "data/mortality_data.rds")
write_csv(mortality_combined, "data/mortality_data.csv")
cat("  Saved data/mortality_data.rds (", nrow(mortality_combined), " rows)\n")

if (!is.null(placebo_cancer)) {
  saveRDS(placebo_cancer, "data/placebo_cancer.rds")
  cat("  Saved data/placebo_cancer.rds\n")
}

if (!is.null(placebo_heart)) {
  saveRDS(placebo_heart, "data/placebo_heart.rds")
  cat("  Saved data/placebo_heart.rds\n")
}

if (!is.null(placebo_cancer_post)) {
  saveRDS(placebo_cancer_post, "data/placebo_cancer_post.rds")
  cat("  Saved data/placebo_cancer_post.rds\n")
}

if (!is.null(placebo_heart_post)) {
  saveRDS(placebo_heart_post, "data/placebo_heart_post.rds")
  cat("  Saved data/placebo_heart_post.rds\n")
}

saveRDS(all_states, "data/state_lookup.rds")

cat("\n=== Data Fetch Complete ===\n")
cat("Total state-year cells:", nrow(mortality_combined), "\n")
cat("Policy states:", nrow(policy_db), "\n")
cat("Year range:", min(mortality_combined$year), "-", max(mortality_combined$year), "\n")
cat("Data sources used:\n")
print(table(mortality_combined$data_source))
