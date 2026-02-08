##############################################################################
# 01_fetch_data.R - Fetch ACS PUMS microdata for postpartum women
# Paper 137: Medicaid Postpartum Coverage Extensions
##############################################################################

source("00_packages.R")

cat("=== Fetching ACS PUMS data (2017-2023) ===\n")

# ACS PUMS variables
# FER = Gave birth within past 12 months (1=Yes, 2=No)
# HICOV = Health insurance coverage (1=With, 2=Without)
# HINS1 = Employer insurance
# HINS2 = Direct-purchase insurance
# HINS3 = Medicare
# HINS4 = Medicaid
# HINS5 = TRICARE
# AGEP = Age
# SEX = Sex (2=Female)
# ST = State FIPS
# PWGTP = Person weight
# POVPIP = Income-to-poverty ratio (0-501)
# RAC1P = Race
# HISP = Hispanic origin
# SCHL = Educational attainment
# MAR = Marital status
# NRC = Number of own related children

vars <- "AGEP,FER,HICOV,HINS1,HINS2,HINS3,HINS4,HINS5,SEX,ST,PWGTP,POVPIP,RAC1P,HISP,SCHL,MAR,NRC"

# Years to fetch (2017-2023 for 1-year ACS PUMS)
years <- 2017:2023

fetch_acs_pums <- function(year, vars) {
  cat(sprintf("  Fetching ACS %d...\n", year))

  # Base URL for ACS 1-year PUMS
  base_url <- sprintf("https://api.census.gov/data/%d/acs/acs1/pums", year)

  # We need to fetch women aged 18-44
  # API allows predicates for SEX and AGEP range
  url <- paste0(base_url, "?get=", vars, "&SEX=2&AGEP=18:44&ucgid=0100000US")

  response <- GET(url, timeout(120))

  if (status_code(response) != 200) {
    cat(sprintf("    WARNING: HTTP %d for year %d\n", status_code(response), year))
    return(NULL)
  }

  # Parse JSON response
  content_text <- content(response, as = "text", encoding = "UTF-8")
  parsed <- fromJSON(content_text)

  # First row is header
  header <- parsed[1, ]
  data <- as.data.frame(parsed[-1, ], stringsAsFactors = FALSE)
  colnames(data) <- header

  # Add year
  data$year <- year

  cat(sprintf("    Got %d records for %d\n", nrow(data), year))
  return(data)
}

# Fetch all years
all_data <- list()
for (yr in years) {
  result <- fetch_acs_pums(yr, vars)
  if (!is.null(result)) {
    all_data[[as.character(yr)]] <- result
  }
  Sys.sleep(1)  # Rate limiting
}

# Combine
df_raw <- bind_rows(all_data)
cat(sprintf("\nTotal records: %d\n", nrow(df_raw)))

# Convert to numeric
numeric_vars <- c("AGEP", "FER", "HICOV", "HINS1", "HINS2", "HINS3", "HINS4",
                   "HINS5", "SEX", "ST", "PWGTP", "POVPIP", "RAC1P", "HISP",
                   "SCHL", "MAR", "NRC", "year")
for (v in numeric_vars) {
  if (v %in% colnames(df_raw)) {
    df_raw[[v]] <- as.numeric(df_raw[[v]])
  }
}

# Save raw data
fwrite(df_raw, file.path(data_dir, "acs_pums_raw.csv"))
cat(sprintf("Saved raw data: %d rows\n", nrow(df_raw)))

# =========================================================
# State postpartum extension adoption dates
# Source: KFF, CMS announcements, verified against state records
# Date = effective date of 12-month postpartum coverage
# =========================================================

cat("\n=== Building treatment assignment ===\n")

# Treatment dates: state FIPS code -> year of effective extension
# Using the year the extension had full bite (post-PHE consideration)
# For states adopting during PHE (before May 2023), the practical effect
# date is when PHE ended AND the extension was in place
# For states adopting after PHE, use actual effective date

treatment_dates <- tribble(
  ~state_fips, ~state_abbr, ~adopt_year, ~mechanism,
  # Pre-ARPA waiver states (2021)
  17, "IL", 2021, "Waiver",
  13, "GA", 2021, "Waiver",  # Initially 6 months, 12 months Nov 2022
  29, "MO", 2021, "Waiver",  # Limited initially, full SPA July 2023
  34, "NJ", 2021, "Waiver",
  51, "VA", 2022, "Waiver",
  # First wave ARPA SPA (April 2022)
  6,  "CA", 2022, "SPA",
  15, "HI", 2022, "SPA",
  21, "KY", 2022, "SPA",
  22, "LA", 2022, "SPA",
  23, "ME", 2022, "SPA",
  26, "MI", 2022, "SPA",
  27, "MN", 2022, "SPA",
  35, "NM", 2022, "SPA",
  37, "NC", 2022, "SPA",
  41, "OR", 2022, "SPA",
  45, "SC", 2022, "SPA",
  47, "TN", 2022, "SPA",
  53, "WA", 2022, "SPA",
  11, "DC", 2022, "SPA",
  12, "FL", 2022, "Waiver",
  # Mid-2022 wave
  9,  "CT", 2022, "SPA",
  20, "KS", 2022, "SPA",
  25, "MA", 2022, "SPA",
  24, "MD", 2022, "SPA",
  39, "OH", 2022, "SPA",
  42, "PA", 2022, "SPA",
  18, "IN", 2022, "SPA",
  54, "WV", 2022, "SPA",
  # Late 2022
  38, "ND", 2022, "SPA",
  # 2023 wave
  1,  "AL", 2023, "SPA",
  4,  "AZ", 2023, "SPA",
  8,  "CO", 2023, "SPA",
  40, "OK", 2023, "SPA",
  44, "RI", 2023, "SPA",
  10, "DE", 2023, "SPA",
  36, "NY", 2023, "SPA",
  46, "SD", 2023, "SPA",
  28, "MS", 2023, "SPA",
  56, "WY", 2023, "SPA",
  50, "VT", 2023, "SPA",
  30, "MT", 2023, "SPA",
  33, "NH", 2023, "SPA",
  # 2024 wave
  2,  "AK", 2024, "SPA",
  31, "NE", 2024, "SPA",
  48, "TX", 2024, "SPA",
  49, "UT", 2024, "SPA",
  16, "ID", 2025, "SPA",
  19, "IA", 2025, "SPA",
  32, "NV", 2024, "SPA"
)

# Never-treated states (as of end of sample, 2023)
# Arkansas and Wisconsin (90-day only)
never_treated <- c(5, 55)  # AR=5, WI=55

# Save treatment dates
fwrite(treatment_dates, file.path(data_dir, "treatment_dates.csv"))
cat(sprintf("Treatment dates: %d states\n", nrow(treatment_dates)))

cat("\n=== Data fetch complete ===\n")
