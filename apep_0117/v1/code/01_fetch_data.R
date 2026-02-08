# =============================================================================
# 01_fetch_data.R  
# Fetch ACS PUMS data from Census API
# =============================================================================

library(httr)
library(jsonlite)
library(dplyr, warn.conflicts = FALSE)
library(readr)

set.seed(20260130)
options(scipen = 999)

message("=== STARTING DATA FETCH ===")

# Variables to fetch
vars <- c("AGEP","COW","WKHP","PINCP","SCHL","DIS","HICOV","SEX","RAC1P","MAR","PWGTP","ESR","ST")

# Function to fetch one year-state
fetch_year <- function(year) {
  message(paste("Fetching year:", year))
  
  url <- paste0("https://api.census.gov/data/", year, "/acs/acs1/pums?get=", 
                paste(vars, collapse = ","), "&for=state:*&AGEP=55:74")
  
  tryCatch({
    response <- GET(url, timeout(180))
    
    if (status_code(response) != 200) {
      warning(paste("Failed for year", year, "- Status:", status_code(response)))
      return(NULL)
    }
    
    content_text <- content(response, "text", encoding = "UTF-8")
    data <- fromJSON(content_text)
    df <- as.data.frame(data[-1, ], stringsAsFactors = FALSE)
    colnames(df) <- data[1, ]
    df <- df[, !duplicated(colnames(df))]
    df$YEAR <- year
    
    message(paste("  Got", nrow(df), "rows"))
    return(df)
    
  }, error = function(e) {
    warning(paste("Error for year", year, ":", e$message))
    return(NULL)
  })
}

# Fetch just key years for speed: 2012, 2014, 2017, 2019, 2022
# This captures pre-ACA, ACA transition, post-ACA, and recent
years <- c(2012, 2014, 2017, 2019, 2022)

message("Fetching years:", paste(years, collapse = ", "))

all_data <- lapply(years, fetch_year)
df_raw <- bind_rows(all_data)

message(paste("\nTotal observations:", nrow(df_raw)))

# Convert types
df <- df_raw %>%
  mutate(
    across(c(AGEP, COW, WKHP, PINCP, SCHL, DIS, HICOV, SEX, RAC1P, MAR, PWGTP, ESR, ST, YEAR),
           as.numeric)
  )

# Save
dir.create("output/paper_116/data", showWarnings = FALSE, recursive = TRUE)
write_csv(df, "output/paper_116/data/acs_raw.csv")
saveRDS(df, "output/paper_116/data/acs_raw.rds")

message("\n=== DATA SUMMARY ===")
message(paste("Years:", paste(unique(df$YEAR), collapse = ", ")))
message(paste("Total observations:", format(nrow(df), big.mark = ",")))
message(paste("States:", n_distinct(df$ST)))

# Self-employment by year
message("\nSelf-Employment Rate by Year:")
df %>%
  filter(!is.na(COW), COW > 0) %>%
  mutate(self_emp = COW %in% c(6, 7)) %>%
  group_by(YEAR) %>%
  summarize(
    n = n(),
    self_emp_rate = round(mean(self_emp) * 100, 1),
    .groups = "drop"
  ) %>%
  print()

message("\n=== DATA FETCH COMPLETE ===")
