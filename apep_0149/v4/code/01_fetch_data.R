##############################################################################
# 01_fetch_data.R - Fetch ACS PUMS microdata for postpartum women
# Revision of apep_0153: Medicaid Postpartum Coverage Extensions (v3)
# Unchanged from parent - data already fetched and cached
##############################################################################

source("00_packages.R")

cat("=== Fetching ACS PUMS data (2017-2024) ===\n")

# ACS PUMS variables
vars_pre2023 <- "AGEP,FER,HICOV,HINS1,HINS2,HINS3,HINS4,HINS5,SEX,ST,PWGTP,POVPIP,RAC1P,HISP,SCHL,MAR,NRC"
vars_2023plus <- "AGEP,FER,HICOV,HINS1,HINS2,HINS3,HINS4,HINS5,SEX,STATE,PWGTP,POVPIP,RAC1P,HISP,SCHL,MAR,NRC"

years <- 2017:2024

fetch_acs_pums <- function(year, vars) {
  cat(sprintf("  Fetching ACS %d...\n", year))

  base_url <- sprintf("https://api.census.gov/data/%d/acs/acs1/pums", year)
  url <- paste0(base_url, "?get=", vars, "&SEX=2&AGEP=18:44&ucgid=0100000US")

  response <- GET(url, timeout(120))

  if (status_code(response) != 200) {
    cat(sprintf("    WARNING: HTTP %d for year %d\n", status_code(response), year))
    return(NULL)
  }

  content_text <- content(response, as = "text", encoding = "UTF-8")
  parsed <- fromJSON(content_text)

  header <- parsed[1, ]
  data <- as.data.frame(parsed[-1, ], stringsAsFactors = FALSE)
  colnames(data) <- header

  if ("STATE" %in% colnames(data) && !"ST" %in% colnames(data)) {
    colnames(data)[colnames(data) == "STATE"] <- "ST"
  }

  data$year <- year

  cat(sprintf("    Got %d records for %d\n", nrow(data), year))
  return(data)
}

# Check if data already exists (skip fetch if so)
if (file.exists(file.path(data_dir, "acs_pums_raw.csv"))) {
  cat("Raw data already exists, skipping fetch.\n")
} else {
  all_data <- list()
  for (yr in years) {
    vars <- if (yr >= 2023) vars_2023plus else vars_pre2023
    result <- fetch_acs_pums(yr, vars)
    if (!is.null(result)) {
      all_data[[as.character(yr)]] <- result
    }
    Sys.sleep(1)
  }

  df_raw <- bind_rows(all_data)
  cat(sprintf("\nTotal records: %d\n", nrow(df_raw)))

  numeric_vars <- c("AGEP", "FER", "HICOV", "HINS1", "HINS2", "HINS3", "HINS4",
                     "HINS5", "SEX", "ST", "PWGTP", "POVPIP", "RAC1P", "HISP",
                     "SCHL", "MAR", "NRC", "year")
  for (v in numeric_vars) {
    if (v %in% colnames(df_raw)) {
      df_raw[[v]] <- as.numeric(df_raw[[v]])
    }
  }

  fwrite(df_raw, file.path(data_dir, "acs_pums_raw.csv"))
  cat(sprintf("Saved raw data: %d rows\n", nrow(df_raw)))
}

# Treatment dates
cat("\n=== Building treatment assignment ===\n")

treatment_dates <- tribble(
  ~state_fips, ~state_abbr, ~adopt_year, ~mechanism,
  17, "IL", 2021, "Waiver",
  13, "GA", 2021, "Waiver",
  29, "MO", 2021, "Waiver",
  34, "NJ", 2021, "Waiver",
  51, "VA", 2022, "Waiver",
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
  9,  "CT", 2022, "SPA",
  20, "KS", 2022, "SPA",
  25, "MA", 2022, "SPA",
  24, "MD", 2022, "SPA",
  39, "OH", 2022, "SPA",
  42, "PA", 2022, "SPA",
  18, "IN", 2022, "SPA",
  54, "WV", 2022, "SPA",
  38, "ND", 2022, "SPA",
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
  2,  "AK", 2024, "SPA",
  31, "NE", 2024, "SPA",
  48, "TX", 2024, "SPA",
  49, "UT", 2024, "SPA",
  32, "NV", 2024, "SPA",
  16, "ID", 2025, "SPA",
  19, "IA", 2025, "SPA"
)

never_treated <- c(5, 55)

fwrite(treatment_dates, file.path(data_dir, "treatment_dates.csv"))
cat(sprintf("Treatment dates: %d states\n", nrow(treatment_dates)))

cat("\n=== Data fetch complete ===\n")
