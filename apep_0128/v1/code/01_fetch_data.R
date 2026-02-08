# ==============================================================================
# 01_fetch_data.R
# Fetch housing price data from FRED and Eurostat for synthetic control analysis
# Netherlands Nitrogen Crisis (May 2019)
# ==============================================================================

source("00_packages.R")

# Create data directories
dir.create("../data/raw", recursive = TRUE, showWarnings = FALSE)
dir.create("../data/processed", recursive = TRUE, showWarnings = FALSE)

# ------------------------------------------------------------------------------
# 1. Fetch FRED Housing Price Indices (BIS data)
# Real residential property prices, seasonally adjusted
# ------------------------------------------------------------------------------
cat("Fetching FRED housing price data...\n")

fred_api_key <- Sys.getenv("FRED_API_KEY")

if (fred_api_key == "") {
  stop("FRED_API_KEY environment variable not set. Please set it in .env file.")
}

# Countries and their FRED series IDs (BIS Real House Price Index)
country_series <- tribble(
  ~country, ~series_id,
  "Netherlands", "QNLR628BIS",
  "Germany", "QDER628BIS",
  "Belgium", "QBER628BIS",
  "France", "QFRR628BIS",
  "Austria", "QATR628BIS",
  "United Kingdom", "QGBR628BIS",
  "Denmark", "QDKR628BIS",
  "Sweden", "QSER628BIS",
  "Finland", "QFIR628BIS",
  "Norway", "QNOR628BIS",
  "Switzerland", "QCHR628BIS",
  "Ireland", "QIER628BIS",
  "Italy", "QITR628BIS",
  "Spain", "QESR628BIS",
  "Portugal", "QPTR628BIS",
  "Luxembourg", "QLUR628BIS"
)

# Function to fetch from FRED API
fetch_fred_series <- function(series_id, api_key) {
  url <- paste0(
    "https://api.stlouisfed.org/fred/series/observations?",
    "series_id=", series_id,
    "&api_key=", api_key,
    "&file_type=json",
    "&observation_start=2005-01-01"
  )

  response <- httr::GET(url, httr::timeout(60))

  if (httr::status_code(response) != 200) {
    warning("Failed to fetch ", series_id, ": HTTP ", httr::status_code(response))
    return(NULL)
  }

  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content)

  if (is.null(data$observations)) {
    warning("No observations for ", series_id)
    return(NULL)
  }

  data$observations %>%
    mutate(
      date = ymd(date),
      value = as.numeric(value),
      series_id = series_id
    ) %>%
    filter(!is.na(value))
}

# Fetch all series
cat("Fetching data for", nrow(country_series), "countries...\n")

all_fred_data <- list()
for (i in 1:nrow(country_series)) {
  country <- country_series$country[i]
  series_id <- country_series$series_id[i]

  cat(sprintf("  %s (%s)...", country, series_id))

  data <- fetch_fred_series(series_id, fred_api_key)

  if (!is.null(data)) {
    data$country <- country
    all_fred_data[[country]] <- data
    cat(sprintf(" %d obs\n", nrow(data)))
  } else {
    cat(" FAILED\n")
  }

  Sys.sleep(0.5)  # Rate limiting
}

# Combine all data
fred_hpi <- bind_rows(all_fred_data) %>%
  select(country, date, value) %>%
  rename(hpi = value) %>%
  mutate(
    year = year(date),
    quarter = quarter(date)
  )

cat(sprintf("\nFRED data: %d observations, %d countries\n",
            nrow(fred_hpi), n_distinct(fred_hpi$country)))

saveRDS(fred_hpi, "../data/raw/fred_hpi_all_countries.rds")

# ------------------------------------------------------------------------------
# 2. Fetch Eurostat House Price Index (backup/validation)
# ------------------------------------------------------------------------------
cat("\nFetching Eurostat house price index...\n")

# Eurostat countries
eurostat_countries <- c("NL", "DE", "BE", "FR", "AT", "DK", "SE", "FI", "IE", "IT", "ES", "PT", "LU", "NO", "CH")

eurostat_url <- paste0(
  "https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/prc_hpi_q?",
  "format=JSON&lang=en&",
  "geo=", paste(eurostat_countries, collapse = "&geo=")
)

tryCatch({
  response <- httr::GET(eurostat_url, httr::timeout(120))

  if (httr::status_code(response) == 200) {
    content <- httr::content(response, as = "text", encoding = "UTF-8")
    eurostat_raw <- jsonlite::fromJSON(content)
    saveRDS(eurostat_raw, "../data/raw/eurostat_hpi_raw.rds")

    # Parse Eurostat JSON format
    # This is complex nested structure
    if (!is.null(eurostat_raw$value)) {
      cat("Eurostat data saved (raw JSON format)\n")

      # Extract dimensions
      time_dim <- eurostat_raw$dimension$time$category
      geo_dim <- eurostat_raw$dimension$geo$category

      # Create mapping
      time_labels <- names(time_dim$index)
      geo_labels <- names(geo_dim$index)

      cat(sprintf("  Time periods: %d\n", length(time_labels)))
      cat(sprintf("  Countries: %d\n", length(geo_labels)))
    }
  }
}, error = function(e) {
  cat("Eurostat fetch error:", conditionMessage(e), "\n")
})

# ------------------------------------------------------------------------------
# 3. Fetch additional covariates from FRED
# GDP, unemployment, interest rates for matching
# ------------------------------------------------------------------------------
cat("\nFetching additional covariates...\n")

# Netherlands GDP
gdp_series <- c("NLDNGDPRPCPPPT", "DEUNGDPRPCPPPT", "BELNGDPRPCPPPT")

for (series_id in gdp_series) {
  cat(sprintf("  Fetching %s...", series_id))
  data <- fetch_fred_series(series_id, fred_api_key)
  if (!is.null(data)) {
    saveRDS(data, paste0("../data/raw/fred_", tolower(series_id), ".rds"))
    cat(" done\n")
  } else {
    cat(" failed\n")
  }
  Sys.sleep(0.5)
}

# ------------------------------------------------------------------------------
# 4. Create analysis dataset
# ------------------------------------------------------------------------------
cat("\nCreating analysis dataset...\n")

# Reshape to wide format for synthetic control
hpi_wide <- fred_hpi %>%
  select(country, date, year, quarter, hpi) %>%
  pivot_wider(
    names_from = country,
    values_from = hpi
  ) %>%
  arrange(date)

# Treatment indicator
treatment_date <- ymd("2019-04-01")  # Q2 2019 (ruling was May 29)

hpi_wide <- hpi_wide %>%
  mutate(
    post = date >= treatment_date,
    time_id = row_number()
  )

cat("Analysis dataset:\n")
cat(sprintf("  Observations: %d\n", nrow(hpi_wide)))
cat(sprintf("  Pre-treatment: %d\n", sum(!hpi_wide$post)))
cat(sprintf("  Post-treatment: %d\n", sum(hpi_wide$post)))
cat(sprintf("  Countries with data: %s\n",
            paste(names(hpi_wide)[!names(hpi_wide) %in% c("date", "year", "quarter", "post", "time_id")],
                  collapse = ", ")))

saveRDS(hpi_wide, "../data/processed/hpi_wide.rds")

# Long format for plotting
hpi_long <- fred_hpi %>%
  mutate(
    post = date >= treatment_date,
    treated = country == "Netherlands"
  )

saveRDS(hpi_long, "../data/processed/hpi_long.rds")

# ------------------------------------------------------------------------------
# 5. Summary statistics
# ------------------------------------------------------------------------------
cat("\n=== Data Summary ===\n")

cat("\nNetherlands HPI around treatment:\n")
nl_around <- hpi_long %>%
  filter(country == "Netherlands", year >= 2018, year <= 2020) %>%
  select(date, hpi)
print(as.data.frame(nl_around))

cat("\nCountry coverage:\n")
coverage <- hpi_long %>%
  group_by(country) %>%
  summarize(
    first_date = min(date),
    last_date = max(date),
    n_obs = n(),
    mean_hpi = mean(hpi),
    .groups = "drop"
  ) %>%
  arrange(country)
print(as.data.frame(coverage))

# ------------------------------------------------------------------------------
# 6. File summary
# ------------------------------------------------------------------------------
cat("\n=== Downloaded Files ===\n")
for (dir in c("../data/raw", "../data/processed")) {
  cat(sprintf("\n%s:\n", dir))
  data_files <- list.files(dir, full.names = TRUE)
  for (f in data_files) {
    info <- file.info(f)
    cat(sprintf("  %s: %.1f KB\n", basename(f), info$size / 1024))
  }
}

cat("\nData fetch complete.\n")
