# 01_fetch_data.R
# Fetch enrollment data and compile Promise program treatment timing

source("00_packages.R")

# =============================================================================
# 1. PROMISE PROGRAM TREATMENT TIMING
# =============================================================================

# State FIPS codes
state_fips_lookup <- tibble(
  state_abbr = c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "FL",
                 "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME",
                 "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH",
                 "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI",
                 "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"),
  state_fips = c(1, 2, 4, 5, 6, 8, 9, 10, 11, 12,
                 13, 15, 16, 17, 18, 19, 20, 21, 22, 23,
                 24, 25, 26, 27, 28, 29, 30, 31, 32, 33,
                 34, 35, 36, 37, 38, 39, 40, 41, 42, 44,
                 45, 46, 47, 48, 49, 50, 51, 53, 54, 55, 56)
)

# Compile verified Promise program adoption dates
# Source: NCSL State College Promise Landscape, TCF reports, state legislation
promise_programs <- tribble(
  ~state_abbr, ~program_name, ~first_cohort_year, ~notes,
  "TN", "Tennessee Promise", 2015, "First statewide program; last-dollar",
  "OR", "Oregon Promise", 2016, "Last-dollar; 2.5 GPA minimum",
  "AR", "ArFuture Grant", 2017, "Last-dollar for CC",
  "HI", "Hawaii Promise", 2017, "Covers tuition and fees",
  "IN", "21st Century Scholars", 2017, "Expansion to all CC",
  "KY", "Work Ready Kentucky", 2017, "Last-dollar; high-demand fields",
  "NV", "Nevada Promise", 2017, "Last-dollar; mentor required",
  "NY", "Excelsior Scholarship", 2017, "Includes 4-year; income cap",
  "RI", "RI Promise", 2017, "2 free years CC",
  "MD", "CC Promise", 2018, "Phased in by county",
  "WA", "College Bound", 2019, "Expansion; income-eligible",
  "CA", "CA College Promise", 2019, "First year free; major expansion",
  "CT", "PACT", 2020, "Tuition-free CC",
  "DE", "SEED", 2020, "Last-dollar scholarship",
  "MI", "Reconnect", 2021, "Adults 25+; expanded later",
  "MO", "A+ Program", 2010, "Early adopter; separate",
  "MT", "Montana Promise", 2020, "2-year tuition waiver",
  "NM", "Opportunity Scholarship", 2020, "Covers tuition at public schools",
  "OK", "Oklahoma Promise", 2017, "Expansion of prior program",
  "WV", "Promise Scholarship", 2019, "For graduating seniors"
)

# Merge with FIPS codes
treatment_timing <- state_fips_lookup %>%
  left_join(promise_programs, by = "state_abbr") %>%
  mutate(
    first_treat = ifelse(is.na(first_cohort_year), 0, first_cohort_year),
    ever_treated = !is.na(first_cohort_year)
  )

write_csv(treatment_timing, "../data/promise_treatment_timing.csv")
message("Treatment timing saved: ", sum(treatment_timing$ever_treated), " treated states")

# =============================================================================
# 2. FETCH CENSUS ACS DATA (COLLEGE ENROLLMENT)
# =============================================================================

message("Fetching Census ACS enrollment data...")

fetch_acs_enrollment <- function(year) {
  # B14001: School Enrollment by Level of School for Population 3+ Years
  # B14001_008E = Enrolled in college, undergraduate
  # B14001_009E = Enrolled in graduate/professional
  # B14001_001E = Total population 3+
  url <- paste0(
    "https://api.census.gov/data/", year, "/acs/acs1?",
    "get=NAME,B14001_001E,B14001_008E,B14001_009E&",
    "for=state:*"
  )

  tryCatch({
    response <- GET(url)
    if (status_code(response) != 200) return(NULL)

    data <- fromJSON(content(response, "text", encoding = "UTF-8"))
    df <- as_tibble(data[-1, ], .name_repair = "minimal")
    names(df) <- c("state_name", "pop_3plus", "undergrad_enrolled", "grad_enrolled", "state_fips")

    df <- df %>%
      mutate(
        year = year,
        state_fips = as.integer(state_fips),
        pop_3plus = as.integer(pop_3plus),
        undergrad_enrolled = as.integer(undergrad_enrolled),
        grad_enrolled = as.integer(grad_enrolled),
        total_college_enrolled = undergrad_enrolled + grad_enrolled
      )

    return(df)
  }, error = function(e) {
    warning("Error fetching ACS for year ", year, ": ", e$message)
    return(NULL)
  })
}

# Fetch 2010-2023
acs_years <- 2010:2023
acs_data <- map(acs_years, ~{
  message("  Fetching ACS ", .x)
  Sys.sleep(0.3)
  fetch_acs_enrollment(.x)
}) %>%
  compact() %>%
  bind_rows()

message("ACS data fetched: ", nrow(acs_data), " state-years")

# Calculate enrollment rate
acs_data <- acs_data %>%
  mutate(
    enrollment_rate = total_college_enrolled / pop_3plus
  )

write_csv(acs_data, "../data/acs_college_enrollment.csv")

# =============================================================================
# 3. MERGE TREATMENT WITH OUTCOMES
# =============================================================================

# Create analysis dataset
analysis_data <- acs_data %>%
  left_join(treatment_timing %>% select(state_fips, state_abbr, first_treat, ever_treated),
            by = "state_fips") %>%
  mutate(
    treated = ever_treated & year >= first_treat,
    years_since_treat = ifelse(first_treat > 0, year - first_treat, NA),
    rel_time = case_when(
      first_treat == 0 ~ NA_real_,
      TRUE ~ year - first_treat
    ),
    # Create state ID for clustering
    state_id = as.integer(factor(state_fips))
  )

write_csv(analysis_data, "../data/analysis_panel.csv")

message("\n=== DATA SUMMARY ===")
message("Panel years: ", min(analysis_data$year), "-", max(analysis_data$year))
message("States: ", n_distinct(analysis_data$state_fips))
message("Treated states: ", n_distinct(filter(analysis_data, ever_treated)$state_fips))
message("Never-treated states: ", n_distinct(filter(analysis_data, !ever_treated)$state_fips))
message("Total observations: ", nrow(analysis_data))
message("Analysis dataset saved to: ../data/analysis_panel.csv")
