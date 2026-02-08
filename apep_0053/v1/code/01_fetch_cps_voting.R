# ============================================================================
# Paper 66: Automatic Voter Registration
# Script 01: Fetch CPS Voting and Registration Supplement Data
# ============================================================================

library(httr)
library(jsonlite)

cat("============================================================\n")
cat("FETCHING CPS VOTING DATA\n")
cat("============================================================\n\n")

# ============================================================================
# Function to fetch CPS Voting data for a given year
# ============================================================================

fetch_cps_voting <- function(year) {
  # CPS Voting Supplement only available in even years (November after elections)
  if (year %% 2 != 0) {
    cat(sprintf("Skipping %d (CPS Voting only in even years)\n", year))
    return(NULL)
  }

  # Variables:
  # PES1 - Registered to vote
  # PES2 - Voted in election
  # GESTFIPS - State FIPS
  # PESEX - Sex
  # PRTAGE - Age
  # PTDTRACE - Race
  # PEEDUCA - Education
  # PEMLR - Employment
  # HEFAMINC - Family income
  # PWSSWGT - Person weight

  vars <- c("PES1", "PES2", "GESTFIPS", "PESEX", "PRTAGE", "PTDTRACE",
            "PEEDUCA", "PEMLR", "HEFAMINC", "PWSSWGT")

  base_url <- sprintf("https://api.census.gov/data/%d/cps/voting/nov", year)

  # Build URL
  url <- sprintf("%s?get=%s&for=state:*", base_url, paste(vars, collapse = ","))

  cat(sprintf("Fetching CPS Voting %d...\n", year))
  cat(sprintf("  URL: %s\n", url))

  # Fetch data
  response <- tryCatch({
    GET(url, timeout(60))
  }, error = function(e) {
    warning(sprintf("HTTP request failed for %d: %s", year, e$message))
    return(NULL)
  })

  if (is.null(response)) return(NULL)

  if (status_code(response) != 200) {
    warning(sprintf("Failed to fetch %d: HTTP %d", year, status_code(response)))
    return(NULL)
  }

  # Parse JSON
  content_raw <- content(response, as = "text", encoding = "UTF-8")

  if (nchar(content_raw) == 0) {
    warning(sprintf("Empty response for %d", year))
    return(NULL)
  }

  data_list <- tryCatch({
    fromJSON(content_raw)
  }, error = function(e) {
    warning(sprintf("JSON parsing failed for %d: %s", year, e$message))
    return(NULL)
  })

  if (is.null(data_list)) return(NULL)

  # Convert to data frame
  if (is.matrix(data_list) || is.data.frame(data_list)) {
    if (nrow(data_list) <= 1) {
      warning(sprintf("No data rows for %d", year))
      return(NULL)
    }

    df <- as.data.frame(data_list[-1, ], stringsAsFactors = FALSE)
    colnames(df) <- data_list[1, ]
    df$year <- year

    cat(sprintf("  ✓ Fetched %s rows\n", formatC(nrow(df), format = "d", big.mark = ",")))
    return(df)
  } else {
    warning(sprintf("Unexpected data structure for %d", year))
    return(NULL)
  }
}

# ============================================================================
# Fetch all years (2010-2024, even years only)
# ============================================================================

years <- seq(2010, 2024, by = 2)  # 2010, 2012, 2014, 2016, 2018, 2020, 2022, 2024

cat("\nFetching CPS Voting data for years:", paste(years, collapse = ", "), "\n\n")

df_list <- list()

for (yr in years) {
  df_yr <- fetch_cps_voting(yr)

  if (!is.null(df_yr)) {
    df_list[[as.character(yr)]] <- df_yr
  }

  # Rate limiting - be polite to Census API
  Sys.sleep(2)
}

# ============================================================================
# Combine all years
# ============================================================================

if (length(df_list) > 0) {
  cat("\n============================================================\n")
  cat("COMBINING DATA\n")
  cat("============================================================\n\n")

  # Check if any data was fetched
  if (!require("data.table", quietly = TRUE)) {
    install.packages("data.table", repos = "https://cloud.r-project.org")
    library(data.table)
  }

  cps_voting <- rbindlist(df_list, fill = TRUE)

  cat(sprintf("Total observations: %s\n", formatC(nrow(cps_voting), format = "d", big.mark = ",")))
  cat(sprintf("Years available: %s\n", paste(unique(cps_voting$year), collapse = ", ")))
  cat(sprintf("States: %d\n", length(unique(cps_voting$state))))

  # Save raw data
  saveRDS(cps_voting, "output/paper_66/data/cps_voting_raw.rds")

  cat("\n✓ Data saved to: output/paper_66/data/cps_voting_raw.rds\n")

} else {
  cat("\n✗ ERROR: No data was successfully fetched\n")
  cat("This could be because:\n")
  cat("  1. Census API is down or rate-limiting\n")
  cat("  2. Network connectivity issues\n")
  cat("  3. API endpoint structure has changed\n\n")
  cat("FALLBACK STRATEGY: Use alternative data source\n")
  cat("  - IPUMS CPS (requires API key)\n")
  cat("  - Direct CSV download from Census FTP\n")
}

# ============================================================================
# Create AVR Treatment Database
# ============================================================================

cat("\n============================================================\n")
cat("CREATING AVR TREATMENT DATABASE\n")
cat("============================================================\n\n")

if (!require("tidyverse", quietly = TRUE)) {
  cat("Installing tidyverse (needed for data manipulation)...\n")
  install.packages("tidyverse", repos = "https://cloud.r-project.org", quiet = TRUE)
  library(tidyverse)
} else {
  library(tidyverse)
}

# AVR adoption dates
avr_states <- tribble(
  ~state, ~state_fips, ~state_abbr, ~avr_effective, ~cohort,
  "Oregon", "41", "OR", "2015-01-01", 2015,
  "California", "06", "CA", "2015-10-10", 2015,
  "Vermont", "50", "VT", "2016-01-01", 2016,
  "West Virginia", "54", "WV", "2016-04-01", 2016,
  "Connecticut", "09", "CT", "2016-01-01", 2016,
  "Colorado", "08", "CO", "2017-01-01", 2017,
  "Illinois", "17", "IL", "2017-07-01", 2017,
  "Rhode Island", "44", "RI", "2017-07-01", 2017,
  "Washington", "53", "WA", "2018-01-08", 2018,
  "Maryland", "24", "MD", "2018-07-01", 2018,
  "New Jersey", "34", "NJ", "2018-01-01", 2018,
  "Massachusetts", "25", "MA", "2018-01-01", 2018,
  "Nevada", "32", "NV", "2019-01-01", 2019,
  "New Mexico", "35", "NM", "2019-01-01", 2019,
  "Maine", "23", "ME", "2020-01-01", 2020,
  "Michigan", "26", "MI", "2020-01-01", 2020,
  "Pennsylvania", "42", "PA", "2020-01-01", 2020,
  "Virginia", "51", "VA", "2021-07-01", 2021,
  "Delaware", "10", "DE", "2021-01-01", 2021,
  "Minnesota", "27", "MN", "2023-01-01", 2023
)

avr_states <- avr_states %>%
  mutate(
    avr_effective = as.Date(avr_effective),
    year_effective = year(avr_effective),
    ever_treated = TRUE
  )

# All states
all_states_lookup <- data.frame(
  state = state.name,
  state_abbr = state.abb,
  state_fips = sprintf("%02d", 1:50),
  stringsAsFactors = FALSE
)

# Merge
full_avr_db <- all_states_lookup %>%
  left_join(avr_states %>% select(-state, -state_fips), by = "state_abbr") %>%
  mutate(
    ever_treated = !is.na(cohort),
    avr_effective = if_else(is.na(avr_effective), as.Date(NA), avr_effective)
  )

# Save
write_csv(full_avr_db, "output/paper_66/data/avr_treatment_database.csv")

cat("✓ AVR treatment database saved\n")
cat(sprintf("   Treated states: %d\n", sum(full_avr_db$ever_treated)))
cat(sprintf("   Never-treated states: %d\n", sum(!full_avr_db$ever_treated)))

cat("\nTreatment cohorts:\n")
avr_states %>%
  count(cohort) %>%
  arrange(cohort) %>%
  print()

cat("\n============================================================\n")
cat("DATA FETCHING COMPLETE\n")
cat("============================================================\n\n")

if (exists("cps_voting")) {
  cat("Next step: Run 02_clean_data.R to process CPS voting data\n")
} else {
  cat("⚠️  WARNING: CPS data fetch failed\n")
  cat("Need to use alternative data source (IPUMS CPS or direct download)\n")
}
