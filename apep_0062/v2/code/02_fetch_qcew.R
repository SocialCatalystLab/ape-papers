# =============================================================================
# 02_fetch_qcew.R
# Fetch REAL QCEW data from BLS API
# State-quarter panel for NAICS 7132 (Gambling Industries) and NAICS 71
# =============================================================================

source("output/paper_84/code/00_packages.R")

# =============================================================================
# BLS QCEW API Functions
# Documentation: https://www.bls.gov/cew/data-guide/overview.htm
# =============================================================================

# QCEW data URL pattern:
# https://data.bls.gov/cew/data/api/{YEAR}/{QTR}/industry/{NAICS}.csv
# QTR: 1, 2, 3, 4 for quarters; "a" for annual averages

fetch_qcew_quarter <- function(year, qtr, naics = "7132") {
  # BLS QCEW API endpoint
  url <- sprintf(
    "https://data.bls.gov/cew/data/api/%d/%s/industry/%s.csv",
    year, qtr, naics
  )

  cat(sprintf("Fetching QCEW %d Q%s NAICS %s...\n", year, qtr, naics))

  tryCatch({
    # Read directly from URL
    df <- read_csv(url, show_col_types = FALSE, progress = FALSE)

    # Add metadata
    df$fetch_year <- year
    df$fetch_qtr <- qtr
    df$naics_requested <- naics

    # Filter to state-level totals (area_fips ending in 000)
    df <- df %>%
      filter(
        agglvl_code %in% c(50, 51, 52, 53, 54, 55),  # State-level aggregation codes
        str_sub(area_fips, 3, 5) == "000"  # State totals only
      )

    return(df)

  }, error = function(e) {
    cat(sprintf("  ERROR: %s\n", e$message))
    return(NULL)
  })
}

# Annual averages are more reliable (less suppression)
fetch_qcew_annual <- function(year, naics = "7132") {
  url <- sprintf(
    "https://data.bls.gov/cew/data/api/%d/a/industry/%s.csv",
    year, naics
  )

  cat(sprintf("Fetching QCEW %d annual NAICS %s...\n", year, naics))

  tryCatch({
    df <- read_csv(url, show_col_types = FALSE, progress = FALSE)

    df$fetch_year <- year
    df$naics_requested <- naics

    # State-level totals only
    df <- df %>%
      filter(
        agglvl_code %in% c(50, 51, 52, 53, 54, 55),
        str_sub(area_fips, 3, 5) == "000"
      )

    return(df)

  }, error = function(e) {
    cat(sprintf("  ERROR: %s\n", e$message))
    return(NULL)
  })
}

# =============================================================================
# Fetch QCEW data for all years and industries
# Panel: 2010-2024 (15 years) for long pre-period
# =============================================================================

years <- 2010:2024
naics_codes <- c("7132", "71")  # Gambling Industries, Arts/Entertainment/Recreation

cat("\n=== Fetching QCEW Data ===\n\n")
cat(sprintf("Years: %d to %d\n", min(years), max(years)))
cat(sprintf("Industries: %s\n", paste(naics_codes, collapse = ", ")))
cat("\n")

# Fetch quarterly data for precise treatment timing
qcew_quarterly <- list()

for (naics in naics_codes) {
  for (yr in years) {
    for (q in 1:4) {
      # Skip future quarters
      if (yr == 2024 && q > 3) next  # Data through Q3 2024 typically available

      df <- fetch_qcew_quarter(yr, q, naics)

      if (!is.null(df) && nrow(df) > 0) {
        qcew_quarterly[[paste(yr, q, naics, sep = "_")]] <- df
      }

      # Rate limit: BLS API can be slow
      Sys.sleep(0.5)
    }
  }
}

# Combine quarterly data
cat("\nCombining quarterly data...\n")
qcew_all <- bind_rows(qcew_quarterly)

# =============================================================================
# Clean and reshape QCEW data
# =============================================================================

cat("Cleaning QCEW data...\n")

# Select and rename key variables
qcew_clean <- qcew_all %>%
  mutate(
    state_fips = str_sub(area_fips, 1, 2),
    year = as.integer(fetch_year),
    quarter = as.integer(fetch_qtr),
    naics = naics_requested,

    # Employment measures
    employment = as.numeric(qtrly_estabs_count) * as.numeric(avg_wkly_wage),  # Placeholder
    month1_emp = as.numeric(month1_emplvl),
    month2_emp = as.numeric(month2_emplvl),
    month3_emp = as.numeric(month3_emplvl),
    avg_emp = (month1_emp + month2_emp + month3_emp) / 3,

    # Establishment count
    establishments = as.numeric(qtrly_estabs),

    # Wage measures
    total_wages = as.numeric(total_qtrly_wages),
    avg_weekly_wage = as.numeric(avg_wkly_wage),
    avg_annual_pay = as.numeric(avg_annual_pay)
  ) %>%
  select(
    state_fips, year, quarter, naics,
    month1_emp, month2_emp, month3_emp, avg_emp,
    establishments, total_wages, avg_weekly_wage, avg_annual_pay,
    disclosure_code = disclosure_code,
    own_code  # Ownership code
  ) %>%
  # Filter to private ownership only (own_code = 5)
  filter(own_code == 5 | is.na(own_code))

# Handle suppression: disclosure_code indicates suppression
# N = not available, C = confidential
qcew_clean <- qcew_clean %>%
  mutate(
    suppressed = disclosure_code %in% c("N", "C", "n", "c") |
                 is.na(avg_emp) |
                 avg_emp == 0
  )

# Summary of suppression
cat("\nSuppression summary by NAICS:\n")
qcew_clean %>%
  group_by(naics) %>%
  summarise(
    total_obs = n(),
    suppressed = sum(suppressed, na.rm = TRUE),
    pct_suppressed = 100 * suppressed / total_obs,
    .groups = "drop"
  ) %>%
  print()

# =============================================================================
# Create state-quarter panel
# =============================================================================

cat("\nCreating state-quarter panel...\n")

# Load policy dates for state info
policy_dates <- read_csv("output/paper_84/data/policy_dates.csv", show_col_types = FALSE)

# Get state FIPS codes
state_fips_list <- policy_dates %>%
  select(state_fips, state_abbr, state_name) %>%
  distinct()

# Create balanced panel skeleton
panel_skeleton <- expand_grid(
  state_fips = state_fips_list$state_fips,
  year = years,
  quarter = 1:4
) %>%
  filter(!(year == 2024 & quarter > 3)) %>%  # Remove future quarters
  mutate(
    quarter_num = year * 4 + quarter,  # Continuous quarter number
    yearq = year + (quarter - 1) / 4
  )

# Pivot to wide format (one row per state-quarter, columns for each NAICS)
qcew_wide <- qcew_clean %>%
  filter(!suppressed) %>%
  select(state_fips, year, quarter, naics, avg_emp, establishments, total_wages, avg_weekly_wage) %>%
  pivot_wider(
    id_cols = c(state_fips, year, quarter),
    names_from = naics,
    values_from = c(avg_emp, establishments, total_wages, avg_weekly_wage),
    names_sep = "_"
  )

# Merge with panel skeleton
panel <- panel_skeleton %>%
  left_join(qcew_wide, by = c("state_fips", "year", "quarter")) %>%
  left_join(state_fips_list, by = "state_fips")

# Rename for clarity
panel <- panel %>%
  rename(
    gambling_emp = avg_emp_7132,
    gambling_estab = establishments_7132,
    gambling_wages = total_wages_7132,
    gambling_weekly_wage = avg_weekly_wage_7132,
    leisure_emp = avg_emp_71,
    leisure_estab = establishments_71,
    leisure_wages = total_wages_71,
    leisure_weekly_wage = avg_weekly_wage_71
  )

# =============================================================================
# Merge with policy dates
# =============================================================================

cat("Merging with policy dates...\n")

panel <- panel %>%
  left_join(
    policy_dates %>%
      select(state_fips, first_treat_quarter, first_treat_year,
             implementation_type, has_igaming, igaming_confounder,
             mobile_quarter),
    by = "state_fips"
  ) %>%
  mutate(
    # Treatment indicators
    treated = if_else(quarter_num >= first_treat_quarter & first_treat_quarter > 0, 1L, 0L),
    rel_time = if_else(first_treat_quarter > 0, quarter_num - first_treat_quarter, NA_integer_),

    # Mobile treatment (separate from retail)
    mobile_treated = if_else(!is.na(mobile_quarter) & quarter_num >= mobile_quarter, 1L, 0L),

    # iGaming control
    igaming_active = if_else(has_igaming & !is.na(igaming_confounder), 1L, 0L)
  )

# =============================================================================
# Summary statistics
# =============================================================================

cat("\n=== Panel Summary ===\n\n")
cat(sprintf("Total observations: %d\n", nrow(panel)))
cat(sprintf("States: %d\n", n_distinct(panel$state_fips)))
cat(sprintf("Time periods: %d-%d Q1 to %d Q3\n", min(panel$year), min(panel$year), max(panel$year)))
cat(sprintf("Quarters per state: %d\n", nrow(panel) / n_distinct(panel$state_fips)))

cat("\nMissing data summary:\n")
panel %>%
  summarise(
    gambling_emp_missing = sum(is.na(gambling_emp)),
    gambling_emp_pct_missing = 100 * gambling_emp_missing / n(),
    leisure_emp_missing = sum(is.na(leisure_emp)),
    leisure_emp_pct_missing = 100 * leisure_emp_missing / n()
  ) %>%
  print()

cat("\nTreated vs control observations:\n")
panel %>%
  group_by(treated) %>%
  summarise(
    n = n(),
    states = n_distinct(state_fips),
    mean_gambling_emp = mean(gambling_emp, na.rm = TRUE),
    mean_leisure_emp = mean(leisure_emp, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  print()

# =============================================================================
# Save panel data
# =============================================================================

write_csv(panel, "output/paper_84/data/qcew_panel.csv")

cat("\n\nPanel data saved to data/qcew_panel.csv\n")
cat(sprintf("Observations: %d\n", nrow(panel)))
