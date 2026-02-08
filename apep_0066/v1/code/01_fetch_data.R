# =============================================================================
# 01_fetch_data.R - Fetch ACS data on self-employment by sex and state
# Paper 85: Paid Family Leave and Female Entrepreneurship
# =============================================================================

source("00_packages.R")

# -----------------------------------------------------------------------------
# Define PFL Policy Dates
# -----------------------------------------------------------------------------

# Paid Family Leave policy adoption dates
# first_full_year = first calendar year with full-year benefit availability
pfl_policy <- tibble(
  state_abbr = c("CA", "NJ", "RI", "NY", "WA", "DC", "MA", "CT", "OR", "CO"),
  benefits_began = c("2004-07-01", "2009-07-01", "2014-01-01", "2018-01-01",
                     "2020-01-01", "2020-07-01", "2021-01-01", "2022-01-01",
                     "2023-09-01", "2024-01-01"),
  first_full_year = c(2005, 2010, 2014, 2018, 2020, 2021, 2021, 2022, 2024, 2024)
)

# Save policy dates
write_csv(pfl_policy, "../data/pfl_policy_dates.csv")
message("Policy dates saved to data/pfl_policy_dates.csv")

# -----------------------------------------------------------------------------
# Fetch ACS Data: Self-Employment by Sex
# -----------------------------------------------------------------------------

# Table B24080: Sex by Class of Worker for the Civilian Employed Population
# Key variables (verified from Census API):
# B24080_001E - Total civilian employed population
# B24080_002E - Male: Total
# B24080_005E - Male: Self-employed in own incorporated business
# B24080_010E - Male: Self-employed in own not incorporated business
# B24080_012E - Female: Total
# B24080_015E - Female: Self-employed in own incorporated business
# B24080_020E - Female: Self-employed in own not incorporated business

variables <- c(
  "B24080_001E",  # Total
  "B24080_002E",  # Male total
  "B24080_005E",  # Male: Self-employed incorporated
  "B24080_010E",  # Male: Self-employed not incorporated
  "B24080_012E",  # Female total
  "B24080_015E",  # Female: Self-employed incorporated
  "B24080_020E"   # Female: Self-employed not incorporated
)

# Fetch data for years 2005-2023
years <- 2005:2023

message("Fetching ACS data for years ", min(years), " to ", max(years), "...")

all_data <- list()

for (yr in years) {
  message("  Fetching year ", yr, "...")
  df <- census_api_query(yr, variables)

  if (!is.null(df)) {
    all_data[[as.character(yr)]] <- df
  }

  # Rate limiting
  Sys.sleep(0.5)
}

# Combine all years
acs_raw <- bind_rows(all_data)

message("Fetched ", nrow(acs_raw), " observations across ", length(unique(acs_raw$year)), " years")

# -----------------------------------------------------------------------------
# Clean and Process Data
# -----------------------------------------------------------------------------

# Convert to numeric
numeric_vars <- c("B24080_001E", "B24080_002E", "B24080_005E", "B24080_010E",
                  "B24080_012E", "B24080_015E", "B24080_020E")

acs_clean <- acs_raw %>%
  mutate(
    across(all_of(numeric_vars), as.numeric),
    state_fips = state,
    year = as.integer(year)
  ) %>%
  # Rename variables
  rename(
    total_employed = B24080_001E,
    male_total = B24080_002E,
    male_selfempl_inc = B24080_005E,
    male_selfempl_uninc = B24080_010E,
    female_total = B24080_012E,
    female_selfempl_inc = B24080_015E,
    female_selfempl_uninc = B24080_020E
  ) %>%
  # Calculate self-employment totals and rates
  mutate(
    male_selfempl_total = male_selfempl_inc + male_selfempl_uninc,
    female_selfempl_total = female_selfempl_inc + female_selfempl_uninc,
    total_selfempl = male_selfempl_total + female_selfempl_total,

    # Self-employment rates (as percentage of employed population by sex)
    male_selfempl_rate = 100 * male_selfempl_total / male_total,
    female_selfempl_rate = 100 * female_selfempl_total / female_total,
    total_selfempl_rate = 100 * total_selfempl / total_employed,

    # Separate incorporated/unincorporated rates
    female_selfempl_inc_rate = 100 * female_selfempl_inc / female_total,
    female_selfempl_uninc_rate = 100 * female_selfempl_uninc / female_total,
    male_selfempl_inc_rate = 100 * male_selfempl_inc / male_total,
    male_selfempl_uninc_rate = 100 * male_selfempl_uninc / male_total
  ) %>%
  # Join state abbreviations
  left_join(state_fips_lookup, by = c("state_fips" = "fips")) %>%
  # Join PFL policy dates
  left_join(pfl_policy %>% select(state_abbr, first_full_year), by = "state_abbr") %>%
  mutate(
    # Treatment indicator
    treated = !is.na(first_full_year),
    # Post-treatment indicator
    post = ifelse(treated, year >= first_full_year, FALSE),
    # Cohort (for never-treated, set to 0)
    cohort = ifelse(treated, first_full_year, 0)
  ) %>%
  # Select and arrange
  select(
    NAME, state_abbr, state_fips, year,
    # Employment totals
    total_employed, male_total, female_total,
    # Self-employment counts
    male_selfempl_total, male_selfempl_inc, male_selfempl_uninc,
    female_selfempl_total, female_selfempl_inc, female_selfempl_uninc,
    total_selfempl,
    # Self-employment rates
    male_selfempl_rate, male_selfempl_inc_rate, male_selfempl_uninc_rate,
    female_selfempl_rate, female_selfempl_inc_rate, female_selfempl_uninc_rate,
    total_selfempl_rate,
    # Treatment variables
    treated, post, cohort, first_full_year
  ) %>%
  arrange(state_abbr, year)

# Check for missing values
message("\nMissing values check:")
print(colSums(is.na(acs_clean)))

# -----------------------------------------------------------------------------
# Save Data
# -----------------------------------------------------------------------------

write_csv(acs_clean, "../data/acs_selfemployment.csv")
message("\nData saved to data/acs_selfemployment.csv")

# Summary statistics
message("\n=== DATA SUMMARY ===")
message("Years: ", min(acs_clean$year), " - ", max(acs_clean$year))
message("States: ", n_distinct(acs_clean$state_abbr))
message("Total observations: ", nrow(acs_clean))
message("\nTreated states: ", paste(unique(acs_clean$state_abbr[acs_clean$treated]), collapse = ", "))
message("Control states: ", sum(!acs_clean$treated) / n_distinct(acs_clean$year), " states")

message("\nMean female self-employment rate:")
message("  Overall: ", round(mean(acs_clean$female_selfempl_rate, na.rm = TRUE), 2), "%")
message("  Treated states: ", round(mean(acs_clean$female_selfempl_rate[acs_clean$treated], na.rm = TRUE), 2), "%")
message("  Control states: ", round(mean(acs_clean$female_selfempl_rate[!acs_clean$treated], na.rm = TRUE), 2), "%")
