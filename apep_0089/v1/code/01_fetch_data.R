# ==============================================================================
# 01_fetch_data.R
# Fetch physician employment data from BLS QCEW API
# Paper 111: NP Full Practice Authority and Physician Employment
# ==============================================================================

source("00_packages.R")

# ==============================================================================
# PART 1: Define FPA Adoption Dates
# ==============================================================================

# Full Practice Authority adoption years by state
# Sources: AANP State Practice Environment, DePriest et al. (2020),
# legislative records, Campaign for Action reports
fpa_dates <- tribble(
  ~state_abbr, ~state_name, ~fpa_year, ~source,
  # Early pioneers (pre-1994, treated before our data begins)
  "AK", "Alaska", 1988, "AANP - early pioneer",
  "OR", "Oregon", 1990, "AANP - early pioneer",
  "WA", "Washington", 1990, "AANP - early pioneer",
  "NH", "New Hampshire", 1990, "AANP - early pioneer",

  # 1994 cohort
  "IA", "Iowa", 1994, "AANP",
  "MT", "Montana", 1994, "AANP",
  "NM", "New Mexico", 1994, "AANP",

  # Late 1990s / 2000 cohort
  "ME", "Maine", 1995, "AANP - pre-2000",
  "VT", "Vermont", 1996, "AANP - pre-2000",
  "WY", "Wyoming", 1997, "AANP - pre-2000",
  "CO", "Colorado", 1998, "AANP - pre-2000",
  "AZ", "Arizona", 2000, "AANP",
  "HI", "Hawaii", 2000, "AANP",
  "ID", "Idaho", 2000, "AANP",
  "DC", "District of Columbia", 2000, "AANP",

  # 2000s adoptions
  "RI", "Rhode Island", 2008, "DePriest et al. 2020",
  "ND", "North Dakota", 2011, "DePriest et al. 2020",

  # 2010s adoptions
  "NV", "Nevada", 2013, "Campaign for Action",
  "CT", "Connecticut", 2014, "DePriest et al. 2020",
  "MN", "Minnesota", 2014, "DePriest et al. 2020",
  "MD", "Maryland", 2015, "DePriest et al. 2020",
  "NE", "Nebraska", 2015, "DePriest et al. 2020",
  "SD", "South Dakota", 2017, "AANP News",

  # 2020s adoptions
  "MA", "Massachusetts", 2021, "Campaign for Action",
  "DE", "Delaware", 2021, "Campaign for Action",
  "NY", "New York", 2022, "AANP News",
  "KS", "Kansas", 2022, "AANP News",
  "UT", "Utah", 2023, "AANP News"
)

# Non-FPA states (restricted/reduced practice as of 2024)
# These serve as the "never-treated" control group
non_fpa_states <- tribble(
  ~state_abbr, ~state_name, ~practice_type,
  "CA", "California", "Reduced",
  "FL", "Florida", "Reduced",
  "GA", "Georgia", "Reduced",
  "IN", "Indiana", "Reduced",
  "KY", "Kentucky", "Reduced",
  "LA", "Louisiana", "Reduced",
  "MI", "Michigan", "Restricted",
  "MO", "Missouri", "Restricted",
  "NC", "North Carolina", "Restricted",
  "NJ", "New Jersey", "Reduced",
  "OH", "Ohio", "Reduced",
  "OK", "Oklahoma", "Restricted",
  "PA", "Pennsylvania", "Reduced",
  "SC", "South Carolina", "Restricted",
  "TN", "Tennessee", "Restricted",
  "TX", "Texas", "Restricted",
  "VA", "Virginia", "Restricted",
  "WI", "Wisconsin", "Reduced",
  "WV", "West Virginia", "Reduced",
  "AL", "Alabama", "Reduced",
  "AR", "Arkansas", "Reduced",
  "MS", "Mississippi", "Reduced",
  "IL", "Illinois", "Reduced"
)

# Add fpa_year = 0 for never-treated (required by did package)
non_fpa_states <- non_fpa_states %>%
  mutate(fpa_year = 0, source = "Never adopted FPA")

# Combine all states
all_states <- bind_rows(
  fpa_dates %>% select(state_abbr, state_name, fpa_year, source),
  non_fpa_states %>% select(state_abbr, state_name, fpa_year, source)
)

cat("FPA adoption dates compiled for", nrow(all_states), "states/jurisdictions\n")
cat("Treated states:", sum(all_states$fpa_year > 0), "\n")
cat("Control states:", sum(all_states$fpa_year == 0), "\n")

# ==============================================================================
# PART 2: Fetch QCEW Data from BLS API
# ==============================================================================

# State FIPS codes mapping
state_fips <- tibble(
  state_abbr = state.abb,
  state_name = state.name
) %>%
  bind_rows(tibble(state_abbr = "DC", state_name = "District of Columbia")) %>%
  mutate(
    state_fips = case_when(
      state_abbr == "AL" ~ "01", state_abbr == "AK" ~ "02", state_abbr == "AZ" ~ "04",
      state_abbr == "AR" ~ "05", state_abbr == "CA" ~ "06", state_abbr == "CO" ~ "08",
      state_abbr == "CT" ~ "09", state_abbr == "DE" ~ "10", state_abbr == "DC" ~ "11",
      state_abbr == "FL" ~ "12", state_abbr == "GA" ~ "13", state_abbr == "HI" ~ "15",
      state_abbr == "ID" ~ "16", state_abbr == "IL" ~ "17", state_abbr == "IN" ~ "18",
      state_abbr == "IA" ~ "19", state_abbr == "KS" ~ "20", state_abbr == "KY" ~ "21",
      state_abbr == "LA" ~ "22", state_abbr == "ME" ~ "23", state_abbr == "MD" ~ "24",
      state_abbr == "MA" ~ "25", state_abbr == "MI" ~ "26", state_abbr == "MN" ~ "27",
      state_abbr == "MS" ~ "28", state_abbr == "MO" ~ "29", state_abbr == "MT" ~ "30",
      state_abbr == "NE" ~ "31", state_abbr == "NV" ~ "32", state_abbr == "NH" ~ "33",
      state_abbr == "NJ" ~ "34", state_abbr == "NM" ~ "35", state_abbr == "NY" ~ "36",
      state_abbr == "NC" ~ "37", state_abbr == "ND" ~ "38", state_abbr == "OH" ~ "39",
      state_abbr == "OK" ~ "40", state_abbr == "OR" ~ "41", state_abbr == "PA" ~ "42",
      state_abbr == "RI" ~ "44", state_abbr == "SC" ~ "45", state_abbr == "SD" ~ "46",
      state_abbr == "TN" ~ "47", state_abbr == "TX" ~ "48", state_abbr == "UT" ~ "49",
      state_abbr == "VT" ~ "50", state_abbr == "VA" ~ "51", state_abbr == "WA" ~ "53",
      state_abbr == "WV" ~ "54", state_abbr == "WI" ~ "55", state_abbr == "WY" ~ "56",
      TRUE ~ NA_character_
    )
  )

# Function to fetch QCEW data for a single year
fetch_qcew_year <- function(year, industry = "6211") {
  url <- paste0("https://data.bls.gov/cew/data/api/", year, "/a/industry/", industry, ".csv")

  cat("Fetching QCEW data for year", year, "...\n")

  tryCatch({
    # Read CSV directly from API
    df <- read_csv(url, show_col_types = FALSE)

    # Filter to state-level totals (private ownership, all sizes)
    # agglvl_code 54 = State, by NAICS Sector (3-digit)
    # own_code 5 = Private
    df_state <- df %>%
      filter(
        own_code == 5,  # Private sector
        agglvl_code == 56,  # State level, 4-digit NAICS
        size_code == 0  # All establishment sizes
      ) %>%
      mutate(
        year = as.integer(year),
        state_fips = substr(area_fips, 1, 2)
      ) %>%
      select(
        state_fips,
        year,
        establishments = annual_avg_estabs,
        employment = annual_avg_emplvl,
        total_wages = total_annual_wages,
        avg_weekly_wage = annual_avg_wkly_wage
      )

    return(df_state)
  }, error = function(e) {
    cat("Error fetching year", year, ":", conditionMessage(e), "\n")
    return(NULL)
  })
}

# Fetch data for years 2000-2024
years <- 2000:2024
qcew_list <- lapply(years, fetch_qcew_year)

# Combine all years
qcew_raw <- bind_rows(qcew_list)

cat("\nFetched", nrow(qcew_raw), "state-year observations\n")

# ==============================================================================
# PART 3: Fetch Healthcare Sector Totals (for normalization)
# ==============================================================================

fetch_qcew_healthcare <- function(year) {
  # NAICS 62 = Health Care and Social Assistance
  url <- paste0("https://data.bls.gov/cew/data/api/", year, "/a/industry/62.csv")

  cat("Fetching healthcare sector data for year", year, "...\n")

  tryCatch({
    df <- read_csv(url, show_col_types = FALSE)

    df_state <- df %>%
      filter(
        own_code == 5,
        agglvl_code == 54,  # State, NAICS sector (2-digit)
        size_code == 0
      ) %>%
      mutate(
        year = as.integer(year),
        state_fips = substr(area_fips, 1, 2)
      ) %>%
      select(
        state_fips,
        year,
        healthcare_emp = annual_avg_emplvl
      )

    return(df_state)
  }, error = function(e) {
    cat("Error:", conditionMessage(e), "\n")
    return(NULL)
  })
}

healthcare_list <- lapply(years, fetch_qcew_healthcare)
healthcare_raw <- bind_rows(healthcare_list)

# ==============================================================================
# PART 4: Merge and Clean Data
# ==============================================================================

# Merge physician employment with healthcare sector
analysis_data <- qcew_raw %>%
  left_join(healthcare_raw, by = c("state_fips", "year")) %>%
  left_join(state_fips, by = "state_fips") %>%
  left_join(all_states %>% select(state_abbr, fpa_year), by = "state_abbr") %>%
  filter(!is.na(state_abbr)) %>%
  mutate(
    # Treatment indicator
    treated = fpa_year > 0 & year >= fpa_year,

    # Log employment
    log_emp = log(employment),

    # Physician share of healthcare
    physician_share = employment / healthcare_emp,

    # Numeric state ID for fixed effects
    state_id = as.integer(factor(state_fips))
  ) %>%
  arrange(state_fips, year)

cat("\nFinal analysis dataset:\n")
cat("  Observations:", nrow(analysis_data), "\n")
cat("  States:", n_distinct(analysis_data$state_fips), "\n")
cat("  Years:", min(analysis_data$year), "-", max(analysis_data$year), "\n")
cat("  Treated state-years:", sum(analysis_data$treated, na.rm = TRUE), "\n")

# ==============================================================================
# PART 5: Save Data
# ==============================================================================

# Save main analysis dataset
write_csv(analysis_data, file.path(data_dir, "analysis_data.csv"))
cat("\nAnalysis data saved to data/analysis_data.csv\n")

# Save FPA adoption dates for reference
write_csv(all_states, file.path(data_dir, "fpa_dates.csv"))
cat("FPA dates saved to data/fpa_dates.csv\n")

# Summary statistics
cat("\n=== Summary Statistics ===\n")
analysis_data %>%
  group_by(fpa_year > 0) %>%
  summarise(
    n_states = n_distinct(state_fips),
    mean_emp = mean(employment, na.rm = TRUE),
    sd_emp = sd(employment, na.rm = TRUE),
    mean_establishments = mean(establishments, na.rm = TRUE)
  ) %>%
  print()
