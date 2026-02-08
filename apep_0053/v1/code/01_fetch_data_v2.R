# ============================================================================
# Paper 66: Pay Transparency Laws and Gender Wage Gaps
# Script 01: Fetch Data (State-Level Aggregates)
# ============================================================================
#
# STRATEGIC PIVOT: Instead of 42M person-records from ACS PUMS,
# use state-level aggregate wage data from BLS Quarterly Census of
# Employment and Wages (QCEW) and Census ACS summary tables.
#
# This is:
# 1. Faster to fetch (50 states × 14 years = 700 obs vs 42M)
# 2. Still valid for DiD (state×year panel)
# 3. Publicly accessible without API limits
# ============================================================================

library(tidyverse)
library(httr)
library(jsonlite)

cat("============================================================\n")
cat("FETCHING STATE-LEVEL WAGE DATA\n")
cat("============================================================\n\n")

# ============================================================================
# Create Policy Treatment Database
# ============================================================================

cat("Creating policy treatment database...\n\n")

treatment_db <- tribble(
  ~state, ~state_fips, ~state_abbr, ~law_effective, ~cohort, ~bundled_enforcement,
  "Colorado", "08", "CO", "2021-01-01", 2021, FALSE,
  "California", "06", "CA", "2023-01-01", 2023, TRUE,
  "Washington", "53", "WA", "2023-01-01", 2023, FALSE,
  "Nevada", "32", "NV", "2023-10-01", 2023, FALSE,
  "Rhode Island", "44", "RI", "2024-01-01", 2024, FALSE,
  "New York", "36", "NY", "2024-09-17", 2024, FALSE,
  "Illinois", "17", "IL", "2025-01-01", 2025, TRUE,
  "Minnesota", "27", "MN", "2025-01-01", 2025, FALSE,
  "Vermont", "50", "VT", "2025-07-01", 2025, FALSE,
  "Massachusetts", "25", "MA", "2025-10-29", 2025, FALSE,
  "Maryland", "24", "MD", "2025-01-01", 2025, FALSE,
  "Hawaii", "15", "HI", "2025-01-01", 2025, FALSE,
  "District of Columbia", "11", "DC", "2026-01-01", 2026, FALSE,
  "Delaware", "10", "DE", "2027-01-01", 2027, FALSE
)

treatment_db <- treatment_db %>%
  mutate(
    law_effective = as.Date(law_effective),
    year_effective = year(law_effective),
    ever_treated = TRUE
  )

# All US states + DC
all_states <- data.frame(
  state_abbr = c(state.abb, "DC"),
  state = c(state.name, "District of Columbia"),
  state_fips = c(sprintf("%02d", 1:50), "11"),
  stringsAsFactors = FALSE
)

# Merge to get full treatment indicator
full_db <- all_states %>%
  left_join(treatment_db %>% select(-state, -state_fips), by = "state_abbr") %>%
  mutate(
    ever_treated = !is.na(cohort),
    law_effective = if_else(is.na(law_effective), as.Date(NA), law_effective),
    bundled_enforcement = if_else(is.na(bundled_enforcement), FALSE, bundled_enforcement)
  )

# Save
write_csv(full_db, "output/paper_66/data/treatment_database.csv")

cat("✓ Policy treatment database saved\n")
cat(sprintf("   Treated states: %d\n", sum(full_db$ever_treated)))
cat(sprintf("   Never-treated states: %d\n", sum(!full_db$ever_treated)))

# ============================================================================
# Fetch BLS QCEW Data (State-Level Employment & Wages)
# ============================================================================

cat("\nFetching BLS QCEW data...\n\n")

# BLS QCEW API: https://data.bls.gov/cew/data/api/YEAR/Q/industry/10.csv
# Ownership code: 5 = Private sector
# Industry: 10 = Total, all industries

# Function to fetch QCEW for a given year
fetch_qcew_year <- function(year) {
  url <- sprintf("https://data.bls.gov/cew/data/api/%d/a/industry/10.csv", year)

  cat(sprintf("  Fetching %d...\n", year))

  tryCatch({
    df <- read_csv(url, show_col_types = FALSE, progress = FALSE)
    df %>%
      filter(own_code == 5,  # Private sector
             agglvl_code == 50) %>%  # State level
      select(area_fips, year, qtr, annual_avg_emplvl, total_annual_wages,
             annual_avg_wkly_wage, avg_annual_pay) %>%
      mutate(year = as.integer(year))
  }, error = function(e) {
    warning(sprintf("Failed to fetch QCEW for %d: %s", year, e$message))
    return(NULL)
  })
}

# Fetch 2010-2023 (2024-2025 not available yet)
qcew_list <- map(2010:2022, fetch_qcew_year)  # 2023 may not be available
qcew_list <- compact(qcew_list)  # Remove NULLs

if (length(qcew_list) > 0) {
  qcew_df <- bind_rows(qcew_list)

  # Rename area_fips to state_fips for merging
  qcew_df <- qcew_df %>%
    rename(state_fips = area_fips) %>%
    mutate(state_fips = substr(state_fips, 1, 2))  # Strip county codes

  saveRDS(qcew_df, "output/paper_66/data/qcew_state_wages.rds")
  cat(sprintf("\n✓ QCEW data saved: %d state-year observations\n", nrow(qcew_df)))
} else {
  cat("\n✗ Failed to fetch QCEW data\n")
}

# ============================================================================
# Create Simulated Gender Wage Gap Data (PLACEHOLDER)
# ============================================================================

cat("\n⚠️  NOTE: Gender-specific wage data requires ACS microdata.\n")
cat("   Creating placeholder structure for now.\n")
cat("   TODO: Replace with real ACS PUMS or CPS data.\n\n")

# We'll need to either:
# 1. Fetch ACS PUMS microdata and compute gaps ourselves, OR
# 2. Use BLS CPS data (March Annual Social and Economic Supplement)

# For now, create placeholder structure
years <- 2010:2023
states <- full_db$state_fips

# Create empty data frame
wage_gap_df <- expand_grid(
  state_fips = states,
  year = years
) %>%
  left_join(full_db %>% select(state_fips, state_abbr, ever_treated, cohort, law_effective),
            by = "state_fips") %>%
  mutate(
    # Treatment indicator
    post_treatment = if_else(
      ever_treated & year >= year(law_effective),
      1, 0
    ),

    # Placeholder for real data
    log_wage_male = NA_real_,
    log_wage_female = NA_real_,
    wage_gap = NA_real_,

    # Sample size placeholder
    n_male = NA_integer_,
    n_female = NA_integer_
  )

# Save placeholder
saveRDS(wage_gap_df, "output/paper_66/data/wage_gap_panel_PLACEHOLDER.rds")

cat("✓ Placeholder wage gap panel created\n")
cat("   Structure: 51 states × 14 years = 714 observations\n\n")

# ============================================================================
# Real Data Strategy: Use ipumspy to fetch ACS microdata
# ============================================================================

cat("============================================================\n")
cat("REAL DATA FETCHING STRATEGY\n")
cat("============================================================\n\n")

cat("Option 1: IPUMS USA (Preferred)\n")
cat("  - Requires IPUMS_API_KEY from https://uma.pop.umn.edu/\n")
cat("  - Submit extract with ipumspy Python package\n")
cat("  - Variables: SEX, AGE, EDUC, INCWAGE, UHRSWORK, WKSWORK2, OCC, IND\n")
cat("  - Samples: ACS 2010-2023 (14 years)\n")
cat("  - Processing time: 1-4 hours for extract to process\n\n")

cat("Option 2: Census API (Direct)\n")
cat("  - Free, no API key for ACS summary tables\n")
cat("  - Limitation: Gender wage gap not in summary tables\n")
cat("  - Would need to fetch PUMS (large files)\n\n")

cat("Option 3: CPS March Supplement\n")
cat("  - Annual earnings data with demographics\n")
cat("  - Smaller sample size (~60k/year vs 3M in ACS)\n")
cat("  - Available via IPUMS CPS or Census FTP\n\n")

cat("RECOMMENDATION: Proceed with IPUMS USA extract.\n")
cat("While waiting for extract, continue with analysis code development.\n\n")

# Create IPUMS extract definition
ipums_extract_yaml <- '
description: "Pay Transparency DiD Analysis - ACS 2010-2023"
collection: usa
samples:
  - us2010a
  - us2011a
  - us2012a
  - us2013a
  - us2014a
  - us2015a
  - us2016a
  - us2017a
  - us2018a
  - us2019a
  - us2020a
  - us2021a
  - us2022a
  - us2023a
variables:
  - YEAR
  - STATEFIP
  - PUMA
  - PERWT
  - SEX
  - AGE
  - EDUC
  - EMPSTAT
  - LABFORCE
  - OCC
  - IND
  - UHRSWORK
  - WKSWORK2
  - INCWAGE
'

writeLines(ipums_extract_yaml, "output/paper_66/data/ipums_extract.yaml")

cat("✓ IPUMS extract definition saved to data/ipums_extract.yaml\n\n")

cat("To submit:\n")
cat("  pip install ipumspy\n")
cat("  export IPUMS_API_KEY=your_key_here\n")
cat("  ipums extract submit output/paper_66/data/ipums_extract.yaml\n\n")

cat("============================================================\n")
cat("DATA SETUP COMPLETE\n")
cat("============================================================\n\n")

cat("Files created:\n")
cat("  ✓ data/treatment_database.csv\n")
if (exists("qcew_df")) cat("  ✓ data/qcew_state_wages.rds\n")
cat("  ✓ data/wage_gap_panel_PLACEHOLDER.rds\n")
cat("  ✓ data/ipums_extract.yaml\n\n")

cat("Next steps:\n")
cat("  1. Submit IPUMS extract (see above)\n")
cat("  2. Wait for extract processing (1-4 hours)\n")
cat("  3. Download .dat.gz file\n")
cat("  4. Run 02_clean_data.R to process microdata\n\n")
