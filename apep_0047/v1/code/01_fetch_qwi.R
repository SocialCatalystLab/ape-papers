# ============================================================================
# Paper 64: The Pence Effect
# 01_fetch_qwi.R - Fetch Quarterly Workforce Indicators data
# ============================================================================

source("code/00_packages.R")

library(httr)
library(jsonlite)
library(tidyverse)

# ============================================================================
# QWI API Function
# ============================================================================

fetch_qwi <- function(year, quarter, state = "*", industry = "*", sex = "*") {
  # QWI API endpoint
  base_url <- "https://api.census.gov/data/timeseries/qwi/sa"

  # Variables to fetch
  vars <- c("Emp", "HirA", "Sep", "EarnS", "EarnHirAS", "TurnOvrS")

  # Build query
  params <- list(
    get = paste(vars, collapse = ","),
    `for` = paste0("state:", state),
    time = paste0(year, "-Q", quarter),
    industry = industry,
    sex = sex,
    key = CENSUS_API_KEY
  )

  # Make request
  response <- GET(base_url, query = params)

  if (status_code(response) != 200) {
    warning(paste("Failed to fetch QWI data for", year, "Q", quarter))
    return(NULL)
  }

  # Parse response
  content_text <- content(response, "text", encoding = "UTF-8")
  data <- fromJSON(content_text)

  # Convert to data frame
  if (is.matrix(data) && nrow(data) > 1) {
    df <- as.data.frame(data[-1, , drop = FALSE], stringsAsFactors = FALSE)
    colnames(df) <- data[1, ]
    return(df)
  } else {
    return(NULL)
  }
}

# ============================================================================
# Fetch All QWI Data (2010-2023)
# ============================================================================

cat("Fetching QWI data...\n")
cat("This may take several minutes.\n\n")

# Parameters
years <- 2010:2023
quarters <- 1:4
states <- sprintf("%02d", c(1:2, 4:6, 8:13, 15:42, 44:51, 53:56))  # All states
industries <- c("11", "21", "22", "23", "31-33", "42", "44-45", "48-49",
                "51", "52", "53", "54", "55", "56", "61", "62", "71", "72", "81")
sexes <- c("1", "2")  # 1 = Male, 2 = Female

# Fetch data in chunks to avoid API limits
all_data <- list()
counter <- 0

for (yr in years) {
  for (qtr in quarters) {
    cat(sprintf("Fetching %d Q%d...\n", yr, qtr))

    # Fetch all states at once for this quarter
    df <- tryCatch({
      fetch_qwi(year = yr, quarter = qtr,
                industry = paste(industries, collapse = ","),
                sex = "1,2")
    }, error = function(e) {
      warning(paste("Error fetching", yr, "Q", qtr, ":", e$message))
      NULL
    })

    if (!is.null(df)) {
      df$year <- yr
      df$quarter <- qtr
      all_data[[length(all_data) + 1]] <- df
    }

    # Rate limiting
    Sys.sleep(0.5)
  }
}

# Combine all data
cat("\nCombining data...\n")
qwi_raw <- bind_rows(all_data)

# ============================================================================
# Clean and Process Data
# ============================================================================

cat("Processing data...\n")

qwi_clean <- qwi_raw %>%
  # Rename columns
  rename(
    state_fips = state,
    naics = industry,
    sex_code = sex,
    employment = Emp,
    hires = HirA,
    separations = Sep,
    earnings = EarnS,
    hire_earnings = EarnHirAS,
    turnover = TurnOvrS
  ) %>%
  # Convert to numeric
  mutate(
    across(c(employment, hires, separations, earnings, hire_earnings, turnover),
           as.numeric),
    year = as.integer(year),
    quarter = as.integer(quarter),
    # Create time variable
    time = year + (quarter - 1) / 4,
    yearqtr = paste0(year, "Q", quarter),
    # Gender indicator
    female = as.integer(sex_code == "2"),
    # Post-MeToo indicator (October 2017 = Q4 2017)
    post_metoo = as.integer(time >= 2017.75),
    # High harassment industry indicator
    high_harassment = as.integer(naics %in% high_harassment_industries)
  ) %>%
  # Remove missing
  filter(!is.na(employment), employment > 0)

cat(sprintf("Final dataset: %d observations\n", nrow(qwi_clean)))
cat(sprintf("States: %d\n", n_distinct(qwi_clean$state_fips)))
cat(sprintf("Industries: %d\n", n_distinct(qwi_clean$naics)))
cat(sprintf("Time periods: %d quarters\n", n_distinct(qwi_clean$yearqtr)))

# ============================================================================
# Save Data
# ============================================================================

saveRDS(qwi_clean, "data/qwi_clean.rds")
write_csv(qwi_clean, "data/qwi_clean.csv")

cat("\nData saved to data/qwi_clean.rds\n")

# ============================================================================
# Quick Summary Statistics
# ============================================================================

cat("\n=== Summary Statistics ===\n")

qwi_clean %>%
  group_by(female, high_harassment, post_metoo) %>%
  summarise(
    n_obs = n(),
    mean_emp = mean(employment, na.rm = TRUE),
    mean_hires = mean(hires, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  print()

cat("\nDone!\n")
