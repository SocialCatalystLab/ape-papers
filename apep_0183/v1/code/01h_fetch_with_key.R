# =============================================================================
# 01h_fetch_with_key.R
# Fetch QWI using Census API Key
# =============================================================================

source("00_packages.R")

# Get API key from environment
census_api_key <- Sys.getenv("CENSUS_API_KEY")
if (census_api_key == "") {
  stop("CENSUS_API_KEY not set! Run: source .env")
}
cat("Census API Key loaded\n")

# =============================================================================
# Treatment Timing
# =============================================================================

treatment_dates <- tribble(
  ~state_fips, ~state_abbr, ~state_name, ~retail_date,
  "08", "CO", "Colorado", "2014-01-01",
  "53", "WA", "Washington", "2014-07-08"
) %>%
  mutate(
    retail_date = as.Date(retail_date),
    treat_year = year(retail_date),
    treat_qtr = quarter(retail_date),
    treat_qtr_num = treat_year * 4 + treat_qtr
  )

# =============================================================================
# Load Border Counties
# =============================================================================

border_counties <- readRDS(file.path(data_dir, "border_counties.rds"))
cat("Border counties loaded:", nrow(border_counties), "\n")

# =============================================================================
# QWI Fetch Function with API Key
# =============================================================================

fetch_qwi_with_key <- function(state_fips, year, industry_code, api_key) {
  base_url <- "https://api.census.gov/data/timeseries/qwi/se"
  results <- list()

  for (qtr in 1:4) {
    url <- paste0(
      base_url,
      "?get=EarnHirAS,EarnS,Emp,HirA",
      "&for=county:*",
      "&in=state:", state_fips,
      "&year=", year,
      "&quarter=", qtr,
      "&ownercode=A05",
      "&industry=", industry_code,
      "&sex=0",
      "&key=", api_key
    )

    response <- tryCatch({
      Sys.sleep(0.3)  # Lighter rate limiting with API key
      httr::GET(url, httr::timeout(60))
    }, error = function(e) NULL)

    if (!is.null(response) && httr::status_code(response) == 200) {
      content <- httr::content(response, "text", encoding = "UTF-8")
      if (nchar(content) > 50 && !grepl("error", tolower(content))) {
        data <- tryCatch(jsonlite::fromJSON(content), error = function(e) NULL)
        if (!is.null(data) && nrow(data) >= 2) {
          df <- as.data.frame(data[-1, , drop = FALSE], stringsAsFactors = FALSE)
          colnames(df) <- data[1, ]
          df$year <- year
          df$quarter <- qtr
          df$industry <- industry_code
          results[[length(results) + 1]] <- df
        }
      }
    }
  }

  if (length(results) == 0) return(NULL)
  bind_rows(results)
}

# =============================================================================
# Fetch Data
# =============================================================================

# States to fetch
states_needed <- unique(border_counties$state_fips)
cat("\nStates to fetch:", paste(states_needed, collapse = ", "), "\n")

# Parameters
years <- 2010:2019  # Good coverage for CO (2014) and WA (2014)
industries <- c("00", "44-45", "72", "31-33", "62", "23", "48-49", "11", "21", "51")

cat("Years:", min(years), "-", max(years), "\n")
cat("Industries:", length(industries), "\n")

# Calculate total calls
total_calls <- length(states_needed) * length(years) * length(industries)
cat("Total API calls:", total_calls, "\n\n")

all_qwi <- list()
progress <- 0

for (state in states_needed) {
  cat("\nFetching state", state, "...\n")

  for (yr in years) {
    for (ind in industries) {
      progress <- progress + 1

      if (progress %% 20 == 0) {
        cat(sprintf("\r  Progress: %d/%d (%.1f%%)", progress, total_calls, 100*progress/total_calls))
      }

      df <- fetch_qwi_with_key(state, yr, ind, census_api_key)
      if (!is.null(df) && nrow(df) > 0) {
        all_qwi[[length(all_qwi) + 1]] <- df
      }
    }
  }
  cat("\n")
}

# Combine
cat("\n\nCombining data...\n")
qwi_raw <- bind_rows(all_qwi)
cat("Total QWI rows:", nrow(qwi_raw), "\n")

if (nrow(qwi_raw) == 0) {
  stop("No data fetched!")
}

# =============================================================================
# Clean Data
# =============================================================================

cat("\n=== Cleaning Data ===\n")

qwi_clean <- qwi_raw %>%
  mutate(
    EarnHirAS = as.numeric(EarnHirAS),
    EarnS = as.numeric(EarnS),
    Emp = as.numeric(Emp),
    HirA = as.numeric(HirA),
    year = as.numeric(year),
    quarter = as.numeric(quarter),
    county_fips = paste0(state, county),  # Keep as character
    state_fips_code = state,
    qtr_num = year * 4 + quarter,
    date = as.Date(paste0(year, "-", (quarter - 1) * 3 + 1, "-01"))
  ) %>%
  filter(!is.na(EarnHirAS), EarnHirAS > 0) %>%
  mutate(
    log_earn_hire = log(EarnHirAS),
    log_earn = log(EarnS),
    log_emp = log(Emp + 1),
    log_hires = log(HirA + 1)
  )

cat("Cleaned rows:", nrow(qwi_clean), "\n")

# =============================================================================
# Merge with Border Data
# =============================================================================

cat("\n=== Merging with Border Data ===\n")

border_counties <- border_counties %>%
  mutate(county_fips = as.character(county_fips))

qwi_border <- qwi_clean %>%
  inner_join(
    border_counties %>%
      select(county_fips, county_name, border_pair, treated,
             treated_state, dist_to_border, dist_km),
    by = "county_fips"
  )

cat("After merge:", nrow(qwi_border), "rows\n")

# Add treatment timing
co_treat_time <- treatment_dates$treat_qtr_num[treatment_dates$state_abbr == "CO"]
wa_treat_time <- treatment_dates$treat_qtr_num[treatment_dates$state_abbr == "WA"]

qwi_border <- qwi_border %>%
  mutate(
    treat_qtr_num = case_when(
      grepl("^CO-", border_pair) ~ co_treat_time,
      grepl("^WA-", border_pair) ~ wa_treat_time,
      TRUE ~ NA_real_
    ),
    event_time = qtr_num - treat_qtr_num,
    post = event_time >= 0,
    in_bandwidth = dist_to_border <= 100
  )

# =============================================================================
# Summary
# =============================================================================

cat("\n=== Final Dataset ===\n")
cat("Rows:", nrow(qwi_border), "\n")
cat("Counties:", n_distinct(qwi_border$county_fips), "\n")
cat("Border pairs:", n_distinct(qwi_border$border_pair), "\n")
cat("Industries:", n_distinct(qwi_border$industry), "\n")
cat("Quarters:", n_distinct(qwi_border$qtr_num), "\n")

cat("\n=== By Border Pair (All Industries, in bandwidth) ===\n")
qwi_border %>%
  filter(industry == "00", in_bandwidth) %>%
  group_by(border_pair, treated) %>%
  summarise(
    n_counties = n_distinct(county_fips),
    n_obs = n(),
    mean_earn = mean(EarnHirAS, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(border_pair, treated) %>%
  print(n = 20)

# =============================================================================
# Save
# =============================================================================

saveRDS(qwi_border, file.path(data_dir, "qwi_border.rds"))
saveRDS(treatment_dates, file.path(data_dir, "treatment_dates.rds"))

cat("\n=== Data fetch complete! ===\n")
