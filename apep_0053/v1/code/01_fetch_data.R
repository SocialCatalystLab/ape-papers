# ============================================================================
# Paper 66: Pay Transparency Laws and Gender Wage Gaps
# Script 01: Fetch ACS PUMS Data
# ============================================================================

library(tidyverse)
library(httr)
library(jsonlite)

# ============================================================================
# Census ACS PUMS API
# ============================================================================

# Variables needed:
# WAGP - Wage/salary income past 12 months
# PINCP - Total personal income
# SEX - Sex (1=Male, 2=Female)
# AGEP - Age
# SCHL - Educational attainment
# OCCP - Occupation (4-digit)
# INDP - Industry (4-digit NAICS)
# WKHP - Hours worked per week
# WKWN - Weeks worked per year
# ESR - Employment status
# PWGTP - Person weight
# ST - State FIPS code
# PUMA - Public Use Microdata Area

fetch_acs_pums <- function(year, variables, state = "*") {
  base_url <- sprintf("https://api.census.gov/data/%d/acs/acs1/pums", year)

  vars_string <- paste(variables, collapse = ",")

  url <- sprintf("%s?get=%s&for=state:%s", base_url, vars_string, state)

  cat(sprintf("Fetching ACS %d PUMS data...\n", year))

  response <- GET(url)

  if (status_code(response) != 200) {
    warning(sprintf("Failed to fetch year %d: HTTP %d", year, status_code(response)))
    return(NULL)
  }

  # Parse JSON
  content <- content(response, as = "text", encoding = "UTF-8")
  data_list <- fromJSON(content)

  # First row is header
  if (is.matrix(data_list) || is.data.frame(data_list)) {
    df <- as.data.frame(data_list[-1, ], stringsAsFactors = FALSE)
    colnames(df) <- data_list[1, ]
  } else {
    warning(sprintf("Unexpected data structure for year %d", year))
    return(NULL)
  }

  # Add year column
  df$year <- year

  cat(sprintf("  → Fetched %s rows\n", formatC(nrow(df), format = "d", big.mark = ",")))

  return(df)
}

# ============================================================================
# Fetch Data for 2010-2023
# ============================================================================

# NOTE: We'll fetch a SAMPLE for each year to avoid overwhelming the API
# For full analysis, need to request IPUMS extract or download CSV files

# Core variables
vars <- c("WAGP", "PINCP", "SEX", "AGEP", "SCHL", "OCCP", "INDP",
          "WKHP", "WKWN", "ESR", "PWGTP", "ST", "PUMA")

years <- 2010:2023

# Fetch data (this will be slow - API rate limits)
# For now, let's fetch just one year as a test

cat("============================================================\n")
cat("FETCHING ACS PUMS DATA\n")
cat("============================================================\n\n")

cat("NOTE: Full ACS PUMS dataset is ~3M rows/year.\n")
cat("Census API has rate limits and doesn't support LIMIT parameter.\n")
cat("For production, we need to use ipumspy or download CSV files.\n\n")

cat("ALTERNATIVE APPROACH: Use ipumspy to submit extract request\n\n")

# ============================================================================
# Alternative: Use ipumspy (requires IPUMS_API_KEY)
# ============================================================================

# Check if IPUMS API key is available
ipums_key <- Sys.getenv("IPUMS_API_KEY")

if (ipums_key == "") {
  cat("⚠️  IPUMS_API_KEY not set. Skipping IPUMS extract.\n")
  cat("   For full dataset, set IPUMS_API_KEY environment variable.\n\n")

  # Fallback: Fetch limited sample from Census API
  cat("Fetching sample data from Census API for 2022 (most recent)...\n\n")

  # Census API limitation: Can't sample, returns full dataset or nothing
  # This will attempt to fetch but may fail due to size

  # WORKAROUND: Fetch state-by-state to manage size
  states_sample <- c("06", "08", "36", "48", "12")  # CA, CO, NY, TX, FL

  df_list <- list()
  for (st in states_sample) {
    df_st <- fetch_acs_pums(2022, vars, state = st)
    if (!is.null(df_st)) {
      df_list[[st]] <- df_st
    }
    Sys.sleep(1)  # Rate limiting
  }

  if (length(df_list) > 0) {
    df_2022 <- bind_rows(df_list)
    saveRDS(df_2022, "output/paper_66/data/acs_2022_sample.rds")
    cat(sprintf("\n✓ Saved sample data: %s rows\n", formatC(nrow(df_2022), format = "d", big.mark = ",")))
  } else {
    cat("\n✗ Failed to fetch sample data\n")
  }

} else {
  cat("✓ IPUMS_API_KEY found. Using ipumspy to request full extract...\n\n")

  # Create IPUMS extract definition
  cat("Creating IPUMS USA extract definition...\n\n")

  # Write Python script to submit extract
  python_script <- '
import os
from ipumspy import IpumsApiClient, UsaExtract

# Initialize client
api_key = os.environ.get("IPUMS_API_KEY")
client = IpumsApiClient(api_key)

# Define extract
extract = UsaExtract(
    samples=["us2010a", "us2011a", "us2012a", "us2013a", "us2014a",
             "us2015a", "us2016a", "us2017a", "us2018a", "us2019a",
             "us2020a", "us2021a", "us2022a", "us2023a"],
    variables=["YEAR", "SAMPLE", "SERIAL", "HHWT", "STATEFIP", "PUMA",
               "PERWT", "SEX", "AGE", "EDUC", "EMPSTAT", "LABFORCE",
               "OCC", "IND", "UHRSWORK", "WKSWORK2", "INCWAGE", "INCTOT"],
    description="Pay Transparency Laws DiD Analysis (2010-2023)"
)

# Submit extract
submitted = client.submit_extract(extract)
print(f"Extract submitted: {submitted.number}")
print(f"Status: {submitted.status}")
print(f"Monitor at: https://usa.ipums.org/usa-action/downloads")
'

  writeLines(python_script, "output/paper_66/code/submit_ipums_extract.py")

  cat("Python script saved to: output/paper_66/code/submit_ipums_extract.py\n\n")
  cat("To submit IPUMS extract, run:\n")
  cat("  cd output/paper_66/code && python3 submit_ipums_extract.py\n\n")
  cat("This will submit an extract request. IPUMS will email when ready (1-4 hours).\n")
  cat("Then download the .dat.gz file and place in output/paper_66/data/\n\n")
}

# ============================================================================
# Create Policy Treatment Database
# ============================================================================

cat("Creating policy treatment database...\n\n")

# Pay transparency law effective dates
treatment_db <- tribble(
  ~state, ~state_fips, ~state_abbr, ~law_effective, ~cohort, ~bundled_enforcement,
  "Colorado", "08", "CO", "2021-01-01", 2021, FALSE,
  "California", "06", "CA", "2023-01-01", 2023, TRUE,   # SB 1162 includes pay data reporting
  "Washington", "53", "WA", "2023-01-01", 2023, FALSE,
  "Nevada", "32", "NV", "2023-10-01", 2023, FALSE,
  "Rhode Island", "44", "RI", "2024-01-01", 2024, FALSE,
  "New York", "36", "NY", "2024-09-17", 2024, FALSE,  # Went into effect Sept 17
  "Illinois", "17", "IL", "2025-01-01", 2025, TRUE,   # Includes pay equity reporting
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

# Add never-treated states (for control group)
all_states <- state.name[!state.name %in% c("Alaska", "Hawaii")]  # Exclude AK/HI for now
treated_states <- treatment_db$state

never_treated <- setdiff(all_states, treated_states)

# Get state FIPS codes
state_fips_lookup <- tibble(
  state = state.name,
  state_abbr = state.abb,
  state_fips = sprintf("%02d", 1:50)
)

never_treated_db <- state_fips_lookup %>%
  filter(state %in% never_treated) %>%
  mutate(
    law_effective = as.Date(NA),
    cohort = NA,
    bundled_enforcement = NA,
    ever_treated = FALSE
  )

# Combine
full_treatment_db <- bind_rows(treatment_db, never_treated_db)

# Save
write_csv(full_treatment_db, "output/paper_66/data/treatment_database.csv")

cat("✓ Policy treatment database saved\n")
cat(sprintf("   Treated states: %d\n", sum(full_treatment_db$ever_treated, na.rm = TRUE)))
cat(sprintf("   Never-treated states: %d\n", sum(!full_treatment_db$ever_treated)))

# Print treatment timing
cat("\nTreatment timing by cohort:\n")
treatment_db %>%
  count(cohort, name = "n_states") %>%
  arrange(cohort) %>%
  print()

cat("\n============================================================\n")
cat("DATA FETCHING COMPLETE\n")
cat("============================================================\n\n")

cat("Next steps:\n")
cat("1. If using IPUMS: Submit extract via submit_ipums_extract.py\n")
cat("2. Wait for IPUMS email (1-4 hours)\n")
cat("3. Download .dat.gz file to output/paper_66/data/\n")
cat("4. Run 02_clean_data.R to process microdata\n\n")
