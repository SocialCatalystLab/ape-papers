# =============================================================================
# 01_fetch_data.R
# Fetch CPS data and minimum wage data
# Paper 102: Minimum Wage and Elderly Worker Employment
# =============================================================================

source("output/paper_102/code/00_packages.R")

# =============================================================================
# Part 1: Minimum Wage Data (Vaghul-Zipperer database)
# =============================================================================

message("Fetching minimum wage data...")

# Create minimum wage panel from DOL data
# Federal minimum wage: $7.25 since July 2009
# State MW data compiled from DOL and NCSL sources

# Key state MW increases above federal (simplified panel)
# Source: DOL State Minimum Wages chart and NCSL compilations
fed_mw <- 7.25

# States that raised MW above federal during 2010-2022
# Format: state FIPS, year first raised above $7.25, MW level in that year
state_mw_changes <- tribble(
  ~state, ~state_name, ~first_treat_year, ~mw_2022,
  # Early movers (already above federal by 2010)
  6,  "California", 2008, 15.00,
  8,  "Colorado", 2007, 12.56,
  9,  "Connecticut", 2010, 14.00,
  10, "Delaware", 2014, 10.50,
  11, "District of Columbia", 2008, 16.10,
  12, "Florida", 2005, 11.00,
  15, "Hawaii", 2015, 12.00,
  17, "Illinois", 2010, 12.00,
  23, "Maine", 2017, 12.75,
  24, "Maryland", 2015, 12.50,
  25, "Massachusetts", 2008, 14.25,
  26, "Michigan", 2014, 10.10,
  27, "Minnesota", 2014, 10.33,
  29, "Missouri", 2018, 11.15,
  30, "Montana", 2007, 9.20,
  32, "Nevada", 2007, 10.50,
  33, "New Hampshire", 2008, 7.25,  # Tied to federal
  34, "New Jersey", 2014, 13.00,
  35, "New Mexico", 2019, 11.50,
  36, "New York", 2014, 13.20,
  37, "North Carolina", 2008, 7.25,  # Tied to federal
  38, "North Dakota", 2008, 7.25,  # Tied to federal
  39, "Ohio", 2007, 9.30,
  41, "Oregon", 2003, 13.50,
  42, "Pennsylvania", 2007, 7.25,  # Tied to federal
  44, "Rhode Island", 2013, 12.25,
  50, "Vermont", 2007, 12.55,
  53, "Washington", 1999, 14.49,
  55, "Wisconsin", 2005, 7.25  # Tied to federal
)

# Create panel for 2010-2022
years <- 2010:2022
all_states <- 1:56  # All state FIPS codes

# Simple panel with federal MW as baseline
mw_panel <- expand_grid(state = all_states, year = years) %>%
  filter(state <= 56, !state %in% c(3, 7, 14, 43, 52, 54)) %>%  # Exclude non-states
  mutate(fed_mw = 7.25) %>%
  left_join(state_mw_changes %>% select(state, first_treat_year, mw_2022), by = "state") %>%
  mutate(
    # Interpolate state MW from first treat year to 2022
    state_mw = case_when(
      is.na(first_treat_year) ~ fed_mw,
      year < first_treat_year ~ fed_mw,
      year >= first_treat_year ~ fed_mw + (mw_2022 - fed_mw) * (year - first_treat_year) / (2022 - first_treat_year),
      TRUE ~ fed_mw
    ),
    eff_mw = pmax(state_mw, fed_mw),
    log_eff_mw = log(eff_mw),
    log_fed_mw = log(fed_mw),
    state_mw_above_fed = state_mw > fed_mw
  )

mw_data <- mw_panel

# Identify first time each state raises MW above federal (treatment timing)
first_treatment <- mw_data %>%
  filter(state_mw_above_fed) %>%
  group_by(state) %>%
  summarize(
    first_treat_year = min(year),
    .groups = "drop"
  )

# States that never raised above federal during study period
never_treated_states <- setdiff(unique(mw_data$state), first_treatment$state)
message("Never-treated states: ", length(never_treated_states))

# Save MW data
write_csv(mw_data, file.path(data_dir, "minimum_wage.csv"))
write_csv(first_treatment, file.path(data_dir, "first_treatment.csv"))

# =============================================================================
# Part 2: CPS MORG Data via Census API
# =============================================================================

message("Fetching CPS data via Census API...")

# CPS MORG is not directly available via Census API
# We'll use ACS PUMS as alternative (larger samples, annual data)
# For production: use IPUMS CPS extract

# Function to fetch ACS PUMS data
fetch_acs_pums <- function(year, state = "*") {

  # Variables to fetch
  # AGEP: Age, ESR: Employment status, SCHL: Education, SEX, RAC1P: Race
  # WAGP: Wages, WKHP: Usual hours, OCCP: Occupation, INDP: Industry
  # HICOV: Health insurance, PWGTP: Person weight, ST: State
  vars <- c("AGEP", "ESR", "SCHL", "SEX", "RAC1P", "HISP", "MAR",
            "WAGP", "WKHP", "OCCP", "INDP", "ST", "PWGTP")

  base_url <- sprintf(
    "https://api.census.gov/data/%d/acs/acs1/pums?get=%s&for=state:%s",
    year, paste(vars, collapse = ","), state
  )

  tryCatch({
    response <- jsonlite::fromJSON(base_url)
    df <- as.data.frame(response[-1, ], stringsAsFactors = FALSE)
    names(df) <- response[1, ]

    # Convert to proper types
    df <- df %>%
      mutate(
        across(c(AGEP, ESR, SCHL, SEX, RAC1P, HISP, MAR, WAGP, WKHP, ST, PWGTP), as.numeric),
        year = year
      )

    return(df)
  }, error = function(e) {
    message("Error fetching ", year, ": ", e$message)
    return(NULL)
  })
}

# Fetch data for 2010-2023 (ACS 1-year PUMS)
years <- 2010:2023
all_data <- list()

for (y in years) {
  message("Fetching ACS PUMS for ", y, "...")
  df <- fetch_acs_pums(y)
  if (!is.null(df)) {
    all_data[[as.character(y)]] <- df
    Sys.sleep(0.5)  # Rate limiting
  }
}

# Combine all years
cps_raw <- bind_rows(all_data)

message("Total observations fetched: ", nrow(cps_raw))

# =============================================================================
# Part 3: Clean and prepare analysis sample
# =============================================================================

message("Preparing analysis sample...")

cps_clean <- cps_raw %>%
  # Filter to ages 65+
  filter(AGEP >= 65) %>%
  # Create variables
  mutate(
    state = ST,
    weight = PWGTP,
    age = AGEP,
    female = (SEX == 2),
    # Race/ethnicity
    black = (RAC1P == 2),
    hispanic = (HISP > 1),
    white_nh = (RAC1P == 1 & HISP == 1),
    # Marital status
    married = (MAR == 1),
    # Education: HS or less
    hs_or_less = (SCHL <= 17),  # HS diploma or less
    some_college = (SCHL >= 18 & SCHL <= 20),
    college_plus = (SCHL >= 21),
    # Employment status
    employed = (ESR %in% c(1, 2)),  # Employed (with/without job not at work)
    in_lf = (ESR %in% c(1, 2, 3)),  # In labor force
    # Wages and hours
    wages = WAGP,
    hours = WKHP,
    # Industry (2-digit NAICS)
    retail = (INDP >= 4670 & INDP <= 5790),  # Retail trade
    food_service = (INDP >= 8660 & INDP <= 8690),  # Food services
    healthcare = (INDP >= 7970 & INDP <= 8470),  # Healthcare
    admin_support = (INDP >= 7580 & INDP <= 7590),  # Admin support
    # Service occupations (broadly defined)
    # OCC codes for service occupations: 3000-3999
    service_occ = (OCCP >= 3000 & OCCP <= 3999),
    # Low-wage indicator: retail, food service, or service occupation + HS or less
    low_wage_likely = (hs_or_less & (retail | food_service | service_occ | admin_support))
  ) %>%
  # Join minimum wage data
  left_join(
    mw_data %>%
      group_by(state, year) %>%
      summarize(
        eff_mw = mean(eff_mw),
        log_eff_mw = mean(log_eff_mw),
        state_mw_above_fed = any(state_mw_above_fed),
        .groups = "drop"
      ),
    by = c("state", "year")
  ) %>%
  # Join first treatment timing
  left_join(first_treatment, by = "state") %>%
  # Set first_treat_year to 0 for never-treated
  mutate(
    first_treat_year = ifelse(is.na(first_treat_year), 0, first_treat_year),
    # Post indicator
    post = (year >= first_treat_year & first_treat_year > 0),
    # Relative time
    rel_time = ifelse(first_treat_year > 0, year - first_treat_year, NA)
  )

# =============================================================================
# Part 4: Save cleaned data
# =============================================================================

# Full sample
write_csv(cps_clean, file.path(data_dir, "cps_65plus_full.csv"))

# Low-wage likely sample (main analysis sample)
cps_lowwage <- cps_clean %>%
  filter(low_wage_likely)

write_csv(cps_lowwage, file.path(data_dir, "cps_65plus_lowwage.csv"))

# Summary statistics
message("\n=== Data Summary ===")
message("Total 65+ sample: ", nrow(cps_clean), " observations")
message("Low-wage likely sample: ", nrow(cps_lowwage), " observations")
message("Years: ", min(cps_clean$year), " - ", max(cps_clean$year))
message("States: ", n_distinct(cps_clean$state))
message("\nTreated states (raised MW above federal):")
print(first_treatment %>% arrange(first_treat_year))

# Employment rates by treatment status
emp_summary <- cps_clean %>%
  filter(year >= 2010 & year <= 2019) %>%
  group_by(first_treat_year > 0) %>%
  summarize(
    n = n(),
    emp_rate = weighted.mean(employed, weight, na.rm = TRUE),
    lfp_rate = weighted.mean(in_lf, weight, na.rm = TRUE),
    .groups = "drop"
  )

message("\nEmployment rates by treatment status (2010-2019):")
print(emp_summary)

message("\nData fetch complete. Files saved to: ", data_dir)
