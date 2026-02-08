# =============================================================================
# 01c_fetch_minimal.R
# Minimal QWI Fetch - Colorado Only for Proof of Concept
# =============================================================================

source("00_packages.R")

# =============================================================================
# Treatment Timing
# =============================================================================

treatment_dates <- tribble(
  ~state_fips, ~state_abbr, ~retail_date,
  "08", "CO", "2014-01-01"
) %>%
  mutate(
    retail_date = as.Date(retail_date),
    treat_qtr_num = year(retail_date) * 4 + quarter(retail_date)
  )

# =============================================================================
# Geographic Data (from previous run)
# =============================================================================

border_counties <- readRDS(file.path(data_dir, "border_counties.rds"))
counties_sf <- readRDS(file.path(data_dir, "counties_sf.rds"))
states_sf <- readRDS(file.path(data_dir, "states_sf.rds"))

# Filter to Colorado borders only
co_borders <- border_counties %>%
  filter(grepl("^CO-", border_pair))

cat("Colorado border counties:", nrow(co_borders), "\n")

# =============================================================================
# QWI Fetch - Colorado and neighbors, All Industries, 2012-2018
# =============================================================================

fetch_qwi <- function(state_fips, year, industry_code) {
  base_url <- "https://api.census.gov/data/timeseries/qwi/se"
  results <- list()

  for (qtr in 1:4) {
    url <- paste0(
      base_url,
      "?get=EarnHirAS,Emp,HirA",
      "&for=county:*",
      "&in=state:", state_fips,
      "&year=", year,
      "&quarter=", qtr,
      "&ownercode=A05",
      "&industry=", industry_code,
      "&sex=0"
    )

    response <- tryCatch({
      httr::GET(url, httr::timeout(60))
    }, error = function(e) NULL)

    if (!is.null(response) && httr::status_code(response) == 200) {
      content <- httr::content(response, "text", encoding = "UTF-8")
      if (nchar(content) > 10) {
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
    Sys.sleep(0.5)
  }

  if (length(results) == 0) return(NULL)
  bind_rows(results)
}

# States: CO + 3 neighbors
states <- c("08", "20", "31", "56")  # CO, KS, NE, WY

# Years: 2012-2018 (covers pre/post for CO)
years <- 2012:2018

# Industries: All + key sectors
industries <- c("00", "11", "44-45", "72", "48-49")

cat("\n=== Fetching QWI Data ===\n")
cat("States:", length(states), "\n")
cat("Years:", min(years), "-", max(years), "\n")
cat("Industries:", length(industries), "\n")

all_qwi <- list()
total <- length(states) * length(years) * length(industries)
progress <- 0

for (state in states) {
  for (yr in years) {
    for (ind in industries) {
      progress <- progress + 1
      cat(sprintf("\r%d/%d (%s, %d, %s)   ", progress, total, state, yr, ind))

      df <- fetch_qwi(state, yr, ind)
      if (!is.null(df)) {
        all_qwi[[length(all_qwi) + 1]] <- df
      }
    }
  }
}

cat("\n")

# Combine
qwi_raw <- bind_rows(all_qwi)
cat("Total QWI rows:", nrow(qwi_raw), "\n")

# =============================================================================
# Clean and Merge
# =============================================================================

qwi_clean <- qwi_raw %>%
  mutate(
    EarnHirAS = as.numeric(EarnHirAS),
    Emp = as.numeric(Emp),
    HirA = as.numeric(HirA),
    year = as.numeric(year),
    quarter = as.numeric(quarter),
    county_fips = paste0(state, county),
    qtr_num = year * 4 + quarter,
    date = as.Date(paste0(year, "-", (quarter - 1) * 3 + 1, "-01"))
  ) %>%
  filter(!is.na(EarnHirAS), EarnHirAS > 0) %>%
  mutate(
    log_earn_hire = log(EarnHirAS),
    log_emp = log(Emp + 1)
  )

# Merge with border info
qwi_border <- qwi_clean %>%
  inner_join(co_borders, by = c("county_fips" = "GEOID")) %>%
  mutate(
    treat_qtr_num = treatment_dates$treat_qtr_num[1],
    event_time = qtr_num - treat_qtr_num,
    post = event_time >= 0,
    in_bandwidth = dist_to_border <= 100
  )

cat("Final sample size:", nrow(qwi_border), "\n")
cat("Counties:", n_distinct(qwi_border$county_fips), "\n")
cat("Border pairs:", n_distinct(qwi_border$border_pair), "\n")

# Save
saveRDS(qwi_border, file.path(data_dir, "qwi_border.rds"))

# Summary
cat("\n=== Summary ===\n")
qwi_border %>%
  filter(industry == "00", in_bandwidth) %>%
  group_by(border_pair, treated) %>%
  summarise(
    n = n(),
    mean_earn = mean(EarnHirAS, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  print()

cat("\nMinimal data fetch complete!\n")
