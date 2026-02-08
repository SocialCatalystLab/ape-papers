# =============================================================================
# 01_fetch_data.R
# Fetch ACS PUMS data from Census Bureau API
# =============================================================================

source("00_packages.R")

library(httr)
library(jsonlite)

# =============================================================================
# Census API Configuration
# =============================================================================

base_url <- "https://api.census.gov/data"

# Variables to fetch
vars <- c(
  # Demographics
  "AGEP",   # Age
  "SEX",    # Sex
  "RAC1P",  # Race
  "HISP",   # Hispanic origin
  "SCHL",   # Educational attainment
  "MAR",    # Marital status
  "MSP",    # Married spouse present

  # Labor market
  "COW",    # Class of worker
  "ESR",    # Employment status
  "OCCP",   # Occupation
  "INDP",   # Industry
  "WKHP",   # Usual hours worked
  "WKWN",   # Weeks worked

  # Household
  "HINCP",  # Household income
  "NP",     # Number of persons in household
  "PAOC",   # Presence and age of own children

  # Geography
  "ST",     # State
  "PUMA",   # Public Use Microdata Area

  # Health insurance
  "HICOV",  # Health insurance coverage
  "PRIVCOV", # Private coverage
  "PUBCOV", # Public coverage
  "HINS1",  # Employer/union insurance
  "HINS2",  # Direct purchase
  "HINS3",  # Medicare
  "HINS4",  # Medicaid
  "HINS5",  # TRICARE
  "HINS6",  # VA

  # Weight
  "PWGTP"   # Person weight
)

# =============================================================================
# Fetch Function
# =============================================================================

fetch_pums_year <- function(year, vars, states = "*") {
  cat("Fetching", year, "ACS PUMS data...\n")

  # Build URL
  var_string <- paste(vars, collapse = ",")
  url <- sprintf(
    "%s/%d/acs/acs1/pums?get=%s&for=state:%s",
    base_url, year, var_string, states
  )

  # Make request
  response <- GET(url, timeout(300))

  if (status_code(response) != 200) {
    warning(sprintf("Failed to fetch %d: HTTP %d", year, status_code(response)))
    return(NULL)
  }

  # Parse JSON
  content <- content(response, "text", encoding = "UTF-8")
  data <- fromJSON(content)

  # Convert to data frame
  df <- as.data.frame(data[-1, ], stringsAsFactors = FALSE)
  colnames(df) <- data[1, ]

  # Add year
  df$YEAR <- year

  # Convert numeric columns
  numeric_cols <- c("AGEP", "PWGTP", "HINCP", "WKHP", "NP")
  for (col in numeric_cols) {
    if (col %in% names(df)) {
      df[[col]] <- as.numeric(df[[col]])
    }
  }

  cat("  Fetched", nrow(df), "records\n")
  return(df)
}

# =============================================================================
# Fetch 2018-2022 Data
# =============================================================================

years <- 2018:2022
all_data <- list()

for (year in years) {
  df <- fetch_pums_year(year, vars)
  if (!is.null(df)) {
    all_data[[as.character(year)]] <- df
  }
  Sys.sleep(1)  # Be nice to API
}

# Combine all years
pums_raw <- bind_rows(all_data)

cat("\n=== Data Summary ===\n")
cat("Total observations:", nrow(pums_raw), "\n")
cat("Years:", unique(pums_raw$YEAR), "\n")

# =============================================================================
# Add Medicaid Expansion Status
# =============================================================================

# States that expanded Medicaid by January 2018
# Source: KFF State Health Facts
medicaid_expansion <- tribble(
  ~ST, ~expanded, ~expansion_year,
  "01", FALSE, NA,      # Alabama
  "02", TRUE, 2015,     # Alaska
  "04", TRUE, 2014,     # Arizona
  "05", TRUE, 2014,     # Arkansas
  "06", TRUE, 2014,     # California
  "08", TRUE, 2014,     # Colorado
  "09", TRUE, 2014,     # Connecticut
  "10", TRUE, 2014,     # Delaware
  "11", TRUE, 2014,     # DC
  "12", FALSE, NA,      # Florida
  "13", FALSE, NA,      # Georgia
  "15", TRUE, 2014,     # Hawaii
  "16", TRUE, 2020,     # Idaho
  "17", TRUE, 2014,     # Illinois
  "18", TRUE, 2015,     # Indiana
  "19", TRUE, 2014,     # Iowa
  "20", FALSE, NA,      # Kansas
  "21", TRUE, 2014,     # Kentucky
  "22", TRUE, 2016,     # Louisiana
  "23", TRUE, 2019,     # Maine
  "24", TRUE, 2014,     # Maryland
  "25", TRUE, 2014,     # Massachusetts
  "26", TRUE, 2014,     # Michigan
  "27", TRUE, 2014,     # Minnesota
  "28", FALSE, NA,      # Mississippi
  "29", TRUE, 2021,     # Missouri
  "30", TRUE, 2016,     # Montana
  "31", TRUE, 2020,     # Nebraska
  "32", TRUE, 2014,     # Nevada
  "33", TRUE, 2014,     # New Hampshire
  "34", TRUE, 2014,     # New Jersey
  "35", TRUE, 2014,     # New Mexico
  "36", TRUE, 2014,     # New York
  "37", FALSE, NA,      # North Carolina
  "38", TRUE, 2014,     # North Dakota
  "39", TRUE, 2014,     # Ohio
  "40", TRUE, 2024,     # Oklahoma (expanded after our period)
  "41", TRUE, 2014,     # Oregon
  "42", TRUE, 2015,     # Pennsylvania
  "44", TRUE, 2014,     # Rhode Island
  "45", FALSE, NA,      # South Carolina
  "46", TRUE, 2023,     # South Dakota (expanded after our period)
  "47", FALSE, NA,      # Tennessee
  "48", FALSE, NA,      # Texas
  "49", TRUE, 2014,     # Utah
  "50", TRUE, 2014,     # Vermont
  "51", TRUE, 2019,     # Virginia
  "53", TRUE, 2014,     # Washington
  "54", TRUE, 2014,     # West Virginia
  "55", FALSE, NA,      # Wisconsin (partial expansion)
  "56", FALSE, NA       # Wyoming
)

# Merge expansion status
pums_raw <- pums_raw %>%
  left_join(medicaid_expansion, by = "ST")

# =============================================================================
# Save Raw Data
# =============================================================================

saveRDS(pums_raw, file.path(data_dir, "pums_raw_2018_2022.rds"))

cat("\nRaw data saved to:", file.path(data_dir, "pums_raw_2018_2022.rds"), "\n")
cat("Observations by year:\n")
print(table(pums_raw$YEAR))
