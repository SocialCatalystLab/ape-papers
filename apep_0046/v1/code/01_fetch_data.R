# ==============================================================================
# Paper 63: State EITC and Single Mothers' Self-Employment
# 01_fetch_data.R - Fetch CPS ASEC data from Census Microdata API
# ==============================================================================

source("00_packages.R")
library(httr)
library(jsonlite)

# ==============================================================================
# Census Microdata API Setup
# ==============================================================================

# Note: Census Microdata API works without a key for basic queries
# For heavy usage, get a key at: https://api.census.gov/data/key_signup.html

BASE_URL <- "https://api.census.gov/data"

# Variables to fetch
# A_AGE: Age
# A_SEX: Sex (1=Male, 2=Female)
# A_MARITL: Marital status (1-7)
# A_CLSWKR: Class of worker (self-employed = 6,7)
# FOWNU18: Number of own children under 18
# FOWNU6: Number of own children under 6
# A_HGA: Educational attainment
# A_WKSTAT: Work status
# MARSUPWT: March supplement weight
# GESTFIPS: State FIPS code

VARIABLES <- c(
  "A_AGE", "A_SEX", "A_MARITL", "A_CLSWKR",
  "FOWNU18", "FOWNU6", "A_HGA", "A_WKSTAT",
  "MARSUPWT", "GESTFIPS"
)

# Years available in Census Microdata API (2014+)
# For earlier years, would need IPUMS
YEARS <- 2014:2023

# ==============================================================================
# Function to fetch one year of data
# ==============================================================================

fetch_cps_year <- function(year, variables = VARIABLES) {

  message(sprintf("Fetching CPS ASEC %d...", year))

  # Build API URL
  vars_string <- paste(variables, collapse = ",")
  url <- sprintf(
    "%s/%d/cps/asec/mar?get=%s&for=state:*",
    BASE_URL, year, vars_string
  )

  # Make request
  response <- tryCatch({
    GET(url, timeout(120))
  }, error = function(e) {
    warning(sprintf("Error fetching %d: %s", year, e$message))
    return(NULL)
  })

  if (is.null(response)) return(NULL)

  if (status_code(response) != 200) {
    warning(sprintf("API returned status %d for year %d", status_code(response), year))
    return(NULL)
  }

  # Parse JSON response
  content_text <- content(response, "text", encoding = "UTF-8")
  data_matrix <- fromJSON(content_text)

  # Convert to dataframe (first row is headers)
  df <- as.data.frame(data_matrix[-1, ], stringsAsFactors = FALSE)
  names(df) <- data_matrix[1, ]

  # Add year
  df$YEAR <- year

  # Remove duplicate columns (API sometimes returns duplicates)
  df <- df[, !duplicated(names(df))]

  message(sprintf("  Retrieved %d observations", nrow(df)))

  return(df)
}

# ==============================================================================
# Fetch all years
# ==============================================================================

message("Starting CPS ASEC data collection from Census Microdata API")
message("Years: ", paste(YEARS, collapse = ", "))
message("")

all_data <- list()

for (year in YEARS) {
  df <- fetch_cps_year(year)
  if (!is.null(df)) {
    all_data[[as.character(year)]] <- df
  }
  Sys.sleep(1)  # Be nice to the API
}

# Combine all years
cps_raw <- bind_rows(all_data)

message("")
message(sprintf("Total observations: %s", format(nrow(cps_raw), big.mark = ",")))

# ==============================================================================
# Convert to numeric
# ==============================================================================

cps_raw <- cps_raw %>%
  mutate(across(c(A_AGE, A_SEX, A_MARITL, A_CLSWKR, FOWNU18, FOWNU6,
                  A_HGA, A_WKSTAT, MARSUPWT, GESTFIPS, YEAR), as.numeric))

# ==============================================================================
# Save raw data
# ==============================================================================

write_csv(cps_raw, file.path(data_path, "cps_asec_raw.csv"))
message(sprintf("Saved raw data to: %s", file.path(data_path, "cps_asec_raw.csv")))

# Summary
message("")
message("=== Data Summary ===")
message(sprintf("Years: %d - %d", min(cps_raw$YEAR), max(cps_raw$YEAR)))
message(sprintf("Total observations: %s", format(nrow(cps_raw), big.mark = ",")))
message(sprintf("States: %d", n_distinct(cps_raw$GESTFIPS)))
