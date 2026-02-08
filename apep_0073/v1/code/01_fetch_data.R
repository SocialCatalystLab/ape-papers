# ==============================================================================
# APEP Paper 93: SNAP Work Requirements and Employment
# 01_fetch_data.R - Fetch ACS PUMS data from Census API
# ==============================================================================

source("00_packages.R")

# ------------------------------------------------------------------------------
# ABAWD Waiver Status by State and Year
# Source: USDA FNS https://www.fns.usda.gov/snap/abawd/waivers
# ------------------------------------------------------------------------------

# Create waiver status dataset
# waiver = 1 means work requirements are WAIVED (no work requirement)
# waiver = 0 means work requirements are IN EFFECT

waiver_data <- tribble(
  ~state_fips, ~state_name, ~fy2010, ~fy2011, ~fy2012, ~fy2013, ~fy2014, ~fy2015, ~fy2016, ~fy2017, ~fy2018, ~fy2019,
  "01", "Alabama",       1, 1, 1, 1, 1, 0, 1, 0, 0, 0,
  "02", "Alaska",        1, 1, 1, 1, 1, 0, 1, 1, 0, 1,
  "04", "Arizona",       1, 1, 1, 1, 1, 0, 1, 1, 1, 1,
  "05", "Arkansas",      1, 1, 1, 1, 1, 0, 1, 0, 0, 0,
  "06", "California",    1, 1, 1, 1, 1, 0, 1, 1, 1, 1,
  "08", "Colorado",      1, 1, 1, 1, 1, 0, 1, 1, 1, 1,
  "09", "Connecticut",   1, 1, 1, 1, 1, 0, 1, 1, 1, 1,
  "10", "Delaware",      1, 1, 1, 1, 1, 0, 1, 1, 1, 1,
  "11", "DC",            1, 1, 1, 1, 1, 0, 1, 1, 0, 1,
  "12", "Florida",       1, 1, 1, 1, 1, 0, 1, 0, 0, 0,
  "13", "Georgia",       1, 1, 1, 1, 1, 0, 1, 1, 1, 1,
  "15", "Hawaii",        1, 1, 1, 1, 1, 1, 1, 0, 1, 1,
  "16", "Idaho",         1, 1, 1, 1, 1, 0, 1, 1, 1, 1,
  "17", "Illinois",      1, 1, 1, 1, 1, 0, 1, 1, 1, 1,
  "18", "Indiana",       1, 1, 1, 1, 1, 0, 0, 0, 0, 0,
  "19", "Iowa",          1, 1, 1, 1, 1, 0, 0, 0, 0, 0,
  "20", "Kansas",        1, 1, 1, 1, 1, 0, 0, 0, 0, 0,
  "21", "Kentucky",      1, 1, 1, 1, 1, 0, 1, 1, 1, 1,
  "22", "Louisiana",     1, 1, 1, 1, 1, 0, 1, 1, 1, 1,
  "23", "Maine",         1, 1, 1, 1, 1, 0, 0, 0, 0, 1,
  "24", "Maryland",      1, 1, 1, 1, 1, 0, 1, 1, 1, 1,
  "25", "Massachusetts", 1, 1, 1, 1, 1, 0, 1, 1, 1, 1,
  "26", "Michigan",      1, 1, 1, 1, 1, 0, 1, 1, 1, 1,
  "27", "Minnesota",     1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  "28", "Mississippi",   1, 1, 1, 1, 1, 0, 1, 0, 0, 0,
  "29", "Missouri",      1, 1, 1, 1, 1, 0, 1, 0, 0, 0,
  "30", "Montana",       1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  "31", "Nebraska",      1, 1, 1, 1, 1, 0, 0, 0, 0, 0,
  "32", "Nevada",        1, 1, 1, 1, 1, 0, 1, 0, 1, 0,
  "33", "New Hampshire", 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  "34", "New Jersey",    1, 1, 1, 1, 1, 0, 1, 1, 1, 1,
  "35", "New Mexico",    1, 1, 1, 1, 1, 0, 1, 1, 1, 1,
  "36", "New York",      1, 1, 1, 1, 1, 0, 1, 1, 1, 1,
  "37", "North Carolina",1, 1, 1, 1, 1, 0, 1, 0, 0, 0,
  "38", "North Dakota",  1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  "39", "Ohio",          1, 1, 1, 1, 1, 0, 1, 1, 1, 1,
  "40", "Oklahoma",      1, 1, 1, 1, 1, 0, 0, 0, 0, 0,
  "41", "Oregon",        1, 1, 1, 1, 1, 0, 1, 1, 1, 1,
  "42", "Pennsylvania",  1, 1, 1, 1, 1, 0, 1, 1, 1, 1,
  "44", "Rhode Island",  1, 1, 1, 1, 1, 0, 1, 1, 1, 1,
  "45", "South Carolina",1, 1, 1, 1, 1, 0, 1, 0, 0, 0,
  "46", "South Dakota",  1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  "47", "Tennessee",     1, 1, 1, 1, 1, 0, 1, 1, 1, 1,
  "48", "Texas",         1, 1, 1, 1, 1, 0, 0, 0, 0, 0,
  "49", "Utah",          1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  "50", "Vermont",       1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  "51", "Virginia",      1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
  "53", "Washington",    1, 1, 1, 1, 1, 0, 1, 1, 1, 1,
  "54", "West Virginia", 1, 1, 1, 1, 1, 0, 1, 1, 1, 1,
  "55", "Wisconsin",     1, 1, 1, 1, 1, 1, 0, 0, 0, 0,
  "56", "Wyoming",       1, 1, 1, 1, 1, 0, 0, 0, 0, 0
)

# Convert to long format
waiver_long <- waiver_data %>%
  pivot_longer(
    cols = starts_with("fy"),
    names_to = "fiscal_year",
    values_to = "waiver"
  ) %>%
  mutate(
    year = as.integer(str_extract(fiscal_year, "\\d+")) + 2000,
    # Treatment = work requirements in effect (waiver = 0)
    work_req = 1 - waiver
  )

# Find first year of work requirement reinstatement for each state
first_treat <- waiver_long %>%
  filter(work_req == 1) %>%
  group_by(state_fips) %>%
  summarize(first_treat = min(year), .groups = "drop")

# States with never treated (always waived)
never_treated <- waiver_data %>%
  filter(state_fips %in% c("27", "30", "33", "38", "46", "49", "50", "51")) %>%
  pull(state_fips)

cat("Waiver data processed.\n")
cat("States never reinstating work requirements:", paste(never_treated, collapse = ", "), "\n")

# Save waiver data
saveRDS(waiver_long, "../data/waiver_status.rds")
saveRDS(first_treat, "../data/first_treat.rds")

# ------------------------------------------------------------------------------
# Fetch ACS PUMS Data from Census API
# ------------------------------------------------------------------------------

fetch_pums_year <- function(year) {
  cat("Fetching ACS PUMS for year", year, "...\n")
  
  # Variables:
  # AGEP = Age
  # ESR = Employment status recode
  # FS = SNAP/food stamps (1=yes, 2=no)
  # PWGTP = Person weight
  # ST = State FIPS
  # SEX = Sex (1=male, 2=female)
  # RAC1P = Race
  # SCHL = Educational attainment
  # NCHILD = Number of own children (for 1-year, approximate with HHT)
  # DIS = Disability status (1=yes, 2=no)
  
  base_url <- sprintf(
    "https://api.census.gov/data/%d/acs/acs1/pums?get=AGEP,ESR,FS,PWGTP,ST,SEX,RAC1P,SCHL,DIS&for=state:*",
    year
  )
  
  tryCatch({
    resp <- httr::GET(base_url)
    if (httr::status_code(resp) != 200) {
      warning(sprintf("Failed to fetch year %d: HTTP %d", year, httr::status_code(resp)))
      return(NULL)
    }
    
    json_data <- httr::content(resp, "text", encoding = "UTF-8")
    data_list <- jsonlite::fromJSON(json_data)
    
    # Convert to data frame
    df <- as.data.frame(data_list[-1, ], stringsAsFactors = FALSE)
    names(df) <- data_list[1, ]
    
    # Convert types
    df <- df %>%
      mutate(
        year = year,
        AGEP = as.integer(AGEP),
        ESR = as.integer(ESR),
        FS = as.integer(FS),
        PWGTP = as.integer(PWGTP),
        ST = sprintf("%02d", as.integer(ST)),
        SEX = as.integer(SEX),
        RAC1P = as.integer(RAC1P),
        SCHL = as.integer(SCHL),
        DIS = as.integer(DIS)
      )
    
    cat("  Retrieved", nrow(df), "records for year", year, "\n")
    return(df)
    
  }, error = function(e) {
    warning(sprintf("Error fetching year %d: %s", year, e$message))
    return(NULL)
  })
}

# Fetch data for 2012-2019 (covers pre/post waiver reinstatement)
years <- 2012:2019
pums_list <- lapply(years, fetch_pums_year)
pums_all <- bind_rows(pums_list)

cat("\nTotal records:", nrow(pums_all), "\n")

# Save raw data
saveRDS(pums_all, "../data/pums_raw.rds")
cat("Data saved to ../data/pums_raw.rds\n")
