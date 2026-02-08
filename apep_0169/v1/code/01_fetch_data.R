# ==============================================================================
# 01_fetch_data.R
# Fetch ACS PUMS data via Census API
# Paper 154: The Insurance Value of Secondary Employment
# ==============================================================================

source("00_packages.R")

library(httr)
library(jsonlite)

# ==============================================================================
# Fetch data from Census ACS PUMS API
# ==============================================================================

# Function to query Census ACS PUMS API for a single state
query_acs_pums <- function(year, variables, state) {
  base_url <- sprintf(
    "https://api.census.gov/data/%d/acs/acs1/pums",
    year
  )

  # Build query
  query_url <- paste0(
    base_url,
    "?get=", paste(variables, collapse = ","),
    "&for=state:", state
  )

  response <- tryCatch(
    GET(query_url, timeout(180)),
    error = function(e) {
      warning("Failed to fetch state ", state, " year ", year, ": ", e$message)
      return(NULL)
    }
  )

  if (is.null(response)) return(NULL)

  if (status_code(response) != 200) {
    warning("API returned status ", status_code(response), " for state ", state, " year ", year)
    return(NULL)
  }

  data <- content(response, "text", encoding = "UTF-8")
  parsed <- fromJSON(data)

  # First row is column names
  colnames <- parsed[1, ]
  df <- as.data.frame(parsed[-1, ], stringsAsFactors = FALSE)
  names(df) <- colnames

  df$year <- year
  return(df)
}

# ACS PUMS variables
acs_variables <- c(
  "PWGTP",   # Person weight
  "AGEP",    # Age
  "SEX",     # Sex
  "RAC1P",   # Race
  "HISP",    # Hispanic origin
  "MAR",     # Marital status
  "SCHL",    # Educational attainment
  "ESR",     # Employment status
  "COW",     # Class of worker (self-employed indicator)
  "WKHP",    # Usual hours worked per week
  "WAGP",    # Wages
  "PINCP",   # Total income
  "TEN"      # Housing tenure (own/rent)
)

# Select a sample of large states for faster development
# These states together have ~40% of US population
sample_states <- c("06", "48", "12", "36", "17", "39", "42", "13", "37", "26")  # CA, TX, FL, NY, IL, OH, PA, GA, NC, MI

# Fetch data for years 2019-2022 (recent, pre-COVID to post-COVID)
years <- c(2019, 2021, 2022)  # Skip 2020 (ACS issues)
all_data <- list()

cat("Fetching ACS PUMS data for", length(sample_states), "states,", length(years), "years...\n")

for (yr in years) {
  cat("\nYear", yr, ":\n")
  for (st in sample_states) {
    cat("  State", st, "... ")
    df <- query_acs_pums(yr, acs_variables, st)
    if (!is.null(df)) {
      all_data[[paste(yr, st, sep = "_")]] <- df
      cat(nrow(df), "obs\n")
    } else {
      cat("FAILED\n")
    }
    Sys.sleep(0.5)  # Rate limiting
  }
}

# Check if we got data
if (length(all_data) == 0) {
  stop("No data fetched from Census API")
}

acs_raw <- bind_rows(all_data)
cat("\n=== Data Summary ===\n")
cat("Total observations:", nrow(acs_raw), "\n")
cat("Years covered:", paste(unique(acs_raw$year), collapse = ", "), "\n")
cat("States:", length(unique(acs_raw$state)), "\n")
cat("Variables:", ncol(acs_raw), "\n")

# Save raw data
output_file <- file.path(data_dir, "acs_pums_raw.rds")
saveRDS(acs_raw, output_file)
cat("\nRaw data saved to:", output_file, "\n")

# Also save as CSV for verification
write_csv(acs_raw, file.path(data_dir, "acs_pums_raw.csv"))

cat("\n=== Data Fetch Complete ===\n")
