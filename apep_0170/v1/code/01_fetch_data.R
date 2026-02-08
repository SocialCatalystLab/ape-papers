# ==============================================================================
# 01_fetch_data.R - Fetch Wage Data from Public APIs
# Paper: Salary History Bans and Wage Compression
# ==============================================================================

# Note: This script uses publicly available aggregate data from BLS and Census
# while IPUMS microdata extract is processing. Full analysis uses IPUMS.

library(tidyverse)
library(httr)
library(jsonlite)
library(here)

# Set paths relative to paper directory
data_dir <- file.path(here::here(), "data")

# ------------------------------------------------------------------------------
# Salary History Ban Treatment Dates
# ------------------------------------------------------------------------------

# Treatment dates (effective dates when employers must comply)
# Note: Virginia excluded because its ban applies only to public sector employers,
# and this analysis restricts to private sector workers.
# Assignment rule: January-September effective dates assigned to same calendar year;
# October-December assigned to following year (to avoid contaminating treated period
# with pre-ban wage observations).
shb_dates <- tribble(
  ~state, ~statefip, ~effective_date, ~effective_year,
  "Massachusetts",    25, "2018-07-01", 2018,   # Jul = Q3, same year
  "California",       6,  "2018-01-01", 2018,   # Jan = Q1, same year
  "Delaware",        10,  "2017-12-14", 2018,   # Dec = Q4, next year
  "Oregon",          41,  "2017-10-06", 2018,   # Oct = Q4, next year
  "Connecticut",      9,  "2019-01-01", 2019,   # Jan = Q1, same year
  "Hawaii",          15,  "2019-01-01", 2019,   # Jan = Q1, same year
  "Vermont",         50,  "2018-07-01", 2018,   # Jul = Q3, same year
  "New Jersey",      34,  "2020-01-01", 2020,   # Jan = Q1, same year
  "Illinois",        17,  "2019-09-29", 2019,   # Sep = Q3, same year
  "Maine",           23,  "2019-09-17", 2019,   # Sep = Q3, same year
  "Colorado",         8,  "2021-01-01", 2021,   # Jan = Q1, same year
  "Maryland",        24,  "2020-10-01", 2021,   # Oct = Q4, next year
  "Nevada",          32,  "2021-10-01", 2022,   # Oct = Q4, next year
  "Rhode Island",    44,  "2023-01-01", 2023,   # Jan = Q1, same year
  "Washington",      53,  "2019-07-28", 2019,   # Jul = Q3, same year
  "New York",        36,  "2020-01-01", 2020,   # Jan = Q1, same year
  # Alabama excluded: law (HB 225) enacted 2019 but may not apply to private sector hiring
  # Virginia excluded: public sector only (statefip 51)
)

# Save treatment dates
write_csv(shb_dates, file.path(data_dir, "shb_treatment_dates.csv"))
cat("Treatment dates saved.\n")

# ------------------------------------------------------------------------------
# Fetch BLS QCEW Data (Quarterly Census of Employment and Wages)
# ------------------------------------------------------------------------------
# QCEW provides state-level wage data by industry

fetch_bls_qcew <- function(year, quarter = "a") {
  # Annual averages (quarter = "a")
  url <- sprintf(
    "https://data.bls.gov/cew/data/api/%d/%s/area/US000.csv",
    year, quarter
  )
  
  tryCatch({
    read_csv(url, show_col_types = FALSE) %>%
      filter(own_code == 5) %>%  # Private sector
      select(
        year = year,
        area_fips,
        industry_code,
        annual_avg_estabs,
        annual_avg_emplvl,
        total_annual_wages,
        annual_avg_wkly_wage
      )
  }, error = function(e) {
    message(sprintf("Could not fetch QCEW data for %d: %s", year, e$message))
    return(NULL)
  })
}

# Note: BLS QCEW API has rate limits; for full analysis use bulk downloads
cat("Note: QCEW data should be downloaded from BLS bulk files for full analysis.\n")

# ------------------------------------------------------------------------------
# Create State-Level Panel Structure
# ------------------------------------------------------------------------------
# This creates the panel structure (state x year) with treatment indicators.
# Actual wage outcome data comes from IPUMS ACS in 02_clean_data.R

years <- 2012:2023
states <- unique(c(shb_dates$statefip, 
                   2, 4, 5, 12, 13, 16, 18, 19, 20, 21, 22, 26, 27, 28, 29,
                   30, 31, 33, 35, 37, 38, 39, 40, 42, 45, 46, 47, 48, 49, 54, 55, 56))

# Create panel structure
panel <- expand_grid(
  statefip = states,
  year = years
) %>%
  left_join(
    shb_dates %>% select(statefip, effective_year),
    by = "statefip"
  ) %>%
  mutate(
    # Treatment indicator
    treated = !is.na(effective_year),
    post = year >= effective_year,
    post = ifelse(is.na(post), FALSE, post),
    shb = treated & post,
    
    # First treatment year (for CS estimator)
    first_treat = ifelse(treated, effective_year, 0)
  )

# Save panel structure
write_csv(panel, file.path(data_dir, "state_panel_structure.csv"))
cat("Panel structure saved with", nrow(panel), "state-year observations.\n")
cat("  Treated states:", sum(panel$treated & panel$year == 2023), "\n")
cat("  Control states:", sum(!panel$treated & panel$year == 2023), "\n")

# ------------------------------------------------------------------------------
# Summary
# ------------------------------------------------------------------------------

cat("\n")
cat(strrep("=", 60), "\n")
cat("DATA PREPARATION COMPLETE\n")
cat(strrep("=", 60), "\n")
cat("\n")
cat("Files created:\n")
cat("  - shb_treatment_dates.csv (treatment timing)\n")
cat("  - state_panel_structure.csv (panel with treatment indicators)\n")
cat("\n")
cat("Next steps:\n")
cat("  - Wait for IPUMS ACS extract to complete\n")
cat("  - Load microdata and compute wage dispersion measures\n")
cat("  - Run Callaway-Sant'Anna estimation\n")
