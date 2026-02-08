# Paper 67: Aging Out at 26 and Fertility
# 01_fetch_data.R - Fetch ACS PUMS data from Census API

source("output/paper_67/code/00_packages.R")

# Census API base URL for ACS PUMS
# Using 1-year ACS PUMS for largest sample sizes

fetch_acs_pums <- function(year, variables, age_range = c(22, 30)) {
  base_url <- sprintf(
    "https://api.census.gov/data/%d/acs/acs1/pums",
    year
  )

  # Variables to fetch
  vars <- paste(variables, collapse = ",")

  # Age filter
  age_filter <- sprintf("AGEP=%d:%d", age_range[1], age_range[2])

  # Women only (SEX=2)
  sex_filter <- "SEX=2"

  # Construct URL
  url <- sprintf(
    "%s?get=%s&%s&%s&ucgid=0100000US",
    base_url, vars, age_filter, sex_filter
  )

  cat(sprintf("Fetching year %d...\n", year))

  # Make request
  response <- httr::GET(url, httr::timeout(120))

  if (httr::status_code(response) != 200) {
    warning(sprintf("Failed to fetch year %d: HTTP %d", year, httr::status_code(response)))
    return(NULL)
  }

  # Parse JSON
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content)

  # Convert to dataframe
  df <- as.data.frame(data[-1, ], stringsAsFactors = FALSE)
  names(df) <- data[1, ]

  # Add year
  df$year <- year

  return(df)
}

# Variables to fetch
# PWGTP: Person weight
# AGEP: Age
# SEX: Sex (already filtered to 2=Female)
# FER: Gave birth in past 12 months (1=Yes, 2=No, NA for males and ages outside 15-50)
# HICOV: Health insurance coverage (1=Yes, 2=No)
# PRIVCOV: Private health insurance (1=Yes, 2=No)
# PUBCOV: Public health coverage (1=Yes, 2=No)
# MAR: Marital status
# RAC1P: Race
# HISP: Hispanic origin
# SCHL: Educational attainment
# CIT: Citizenship status
# NATIVITY: Nativity
# ST: State
# POVPIP: Income-to-poverty ratio

variables <- c(
  "PWGTP",    # Person weight
  "AGEP",     # Age
  "SEX",      # Sex
  "FER",      # Gave birth
  "HICOV",    # Health insurance coverage
  "PRIVCOV",  # Private insurance
  "PUBCOV",   # Public coverage
  "MAR",      # Marital status
  "RAC1P",    # Race
  "HISP",     # Hispanic origin
  "SCHL",     # Education
  "CIT",      # Citizenship
  "NATIVITY", # Nativity
  "ST",       # State
  "POVPIP"    # Poverty ratio
)

# Fetch data for years 2011-2022
years <- 2011:2022

all_data <- list()
for (yr in years) {
  tryCatch({
    df <- fetch_acs_pums(yr, variables)
    if (!is.null(df)) {
      all_data[[as.character(yr)]] <- df
    }
    Sys.sleep(1)  # Be nice to the API
  }, error = function(e) {
    warning(sprintf("Error fetching year %d: %s", yr, e$message))
  })
}

# Combine all years
cat("Combining data across years...\n")
combined_data <- bind_rows(all_data)

cat(sprintf("Total observations: %d\n", nrow(combined_data)))
cat(sprintf("Years covered: %s\n", paste(unique(combined_data$year), collapse = ", ")))

# Convert numeric columns
numeric_cols <- c("PWGTP", "AGEP", "FER", "HICOV", "PRIVCOV", "PUBCOV",
                  "MAR", "RAC1P", "HISP", "SCHL", "CIT", "NATIVITY", "ST", "POVPIP")
for (col in numeric_cols) {
  if (col %in% names(combined_data)) {
    combined_data[[col]] <- as.numeric(combined_data[[col]])
  }
}

# Save raw data
cat("Saving raw data...\n")
saveRDS(combined_data, "output/paper_67/data/acs_pums_raw.rds")
cat("Data saved to output/paper_67/data/acs_pums_raw.rds\n")

# Quick summary
cat("\n=== Data Summary ===\n")
cat(sprintf("Total observations: %s\n", format(nrow(combined_data), big.mark = ",")))
cat(sprintf("Age range: %d - %d\n", min(combined_data$AGEP, na.rm = TRUE),
            max(combined_data$AGEP, na.rm = TRUE)))
cat("\nObservations by age:\n")
print(table(combined_data$AGEP))

cat("\nFER (gave birth) distribution:\n")
print(table(combined_data$FER, useNA = "ifany"))

cat("\nHICOV (health insurance) distribution:\n")
print(table(combined_data$HICOV, useNA = "ifany"))

cat("\nData fetch complete.\n")
