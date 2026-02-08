# =============================================================================
# 01b_fetch_data_fast.R
# Fast QWI Fetch - Focus on Colorado Border Only (Proof of Concept)
# Then expand to other borders
# =============================================================================

source("00_packages.R")

# =============================================================================
# Treatment Timing (Marijuana Retail Opening)
# =============================================================================

treatment_dates <- tribble(
  ~state_fips, ~state_abbr, ~state_name, ~retail_date,
  "08", "CO", "Colorado",     "2014-01-01",
  "53", "WA", "Washington",   "2014-07-08",
  "41", "OR", "Oregon",       "2015-10-01",
  "32", "NV", "Nevada",       "2017-07-01",
  "06", "CA", "California",   "2018-01-01"
) %>%
  mutate(
    retail_date = as.Date(retail_date),
    treat_year = year(retail_date),
    treat_qtr = quarter(retail_date),
    treat_qtr_num = treat_year * 4 + treat_qtr
  )

cat("Treatment states:\n")
print(treatment_dates)

# =============================================================================
# Border Configuration - Focus on Key Borders
# =============================================================================

# Colorado borders: KS, NE, WY, UT, AZ, NM, OK
# Nevada borders: AZ, UT, ID, CA, OR
# California borders: AZ, NV, OR
# Washington borders: ID, OR
# Oregon borders: WA, ID, NV, CA

border_pairs <- tribble(
  ~treated_fips, ~control_fips, ~treated_abbr, ~control_abbr,
  # Colorado borders (first adopter - most data)
  "08", "20", "CO", "KS",
  "08", "31", "CO", "NE",
  "08", "56", "CO", "WY",
  "08", "49", "CO", "UT",
  "08", "35", "CO", "NM",
  "08", "40", "CO", "OK",
  # Nevada borders
  "32", "04", "NV", "AZ",
  "32", "49", "NV", "UT",
  "32", "16", "NV", "ID",
  # California borders
  "06", "04", "CA", "AZ",
  # Washington borders
  "53", "16", "WA", "ID"
)

all_states <- unique(c(border_pairs$treated_fips, border_pairs$control_fips))
cat("\nStates to fetch:", length(all_states), "\n")
print(all_states)

# =============================================================================
# Download Shapefiles
# =============================================================================

cat("\n=== Downloading Shapefiles ===\n")

# Counties
counties_sf <- counties(cb = TRUE, year = 2020) %>%
  filter(STATEFP %in% all_states) %>%
  st_transform(crs = 5070)

# States
states_sf <- states(cb = TRUE, year = 2020) %>%
  filter(STATEFP %in% all_states) %>%
  st_transform(crs = 5070)

cat("Counties:", nrow(counties_sf), "\n")

# =============================================================================
# Calculate Border Distances
# =============================================================================

cat("\n=== Calculating Border Distances ===\n")

calc_border_distance <- function(county_sf, border_sf) {
  centroid <- st_centroid(county_sf)
  border_line <- st_boundary(border_sf)
  dist_m <- st_distance(centroid, border_line)
  return(as.numeric(dist_m) / 1000)
}

border_distances <- list()

for (i in 1:nrow(border_pairs)) {
  pair <- border_pairs[i, ]

  treated_boundary <- states_sf %>% filter(STATEFP == pair$treated_fips)
  control_boundary <- states_sf %>% filter(STATEFP == pair$control_fips)

  treated_counties <- counties_sf %>%
    filter(STATEFP == pair$treated_fips) %>%
    mutate(
      treated = TRUE,
      border_pair = paste0(pair$treated_abbr, "-", pair$control_abbr)
    )

  control_counties <- counties_sf %>%
    filter(STATEFP == pair$control_fips) %>%
    mutate(
      treated = FALSE,
      border_pair = paste0(pair$treated_abbr, "-", pair$control_abbr)
    )

  if (nrow(treated_counties) == 0 || nrow(control_counties) == 0) next

  treated_counties$dist_to_border <- sapply(
    1:nrow(treated_counties),
    function(j) calc_border_distance(treated_counties[j, ], control_boundary)
  )

  control_counties$dist_to_border <- sapply(
    1:nrow(control_counties),
    function(j) calc_border_distance(control_counties[j, ], treated_boundary)
  )

  pair_counties <- bind_rows(treated_counties, control_counties) %>%
    mutate(
      signed_dist = ifelse(treated, dist_to_border, -dist_to_border),
      treated_state = pair$treated_fips,
      control_state = pair$control_fips
    )

  border_distances[[i]] <- pair_counties
  cat(sprintf("  %s-%s: %d counties\n", pair$treated_abbr, pair$control_abbr, nrow(pair_counties)))
}

all_border_counties <- bind_rows(border_distances) %>%
  st_drop_geometry() %>%
  select(GEOID, NAME, STATEFP, border_pair, treated, dist_to_border, signed_dist,
         treated_state, control_state)

cat("\nTotal border county observations:", nrow(all_border_counties), "\n")

# Save geographic data
saveRDS(all_border_counties, file.path(data_dir, "border_counties.rds"))
saveRDS(counties_sf, file.path(data_dir, "counties_sf.rds"))
saveRDS(states_sf, file.path(data_dir, "states_sf.rds"))
saveRDS(treatment_dates, file.path(data_dir, "treatment_dates.rds"))

# =============================================================================
# QWI Fetch Function
# =============================================================================

fetch_qwi <- function(state_fips, year, industry_code, max_retries = 3) {
  base_url <- "https://api.census.gov/data/timeseries/qwi/se"
  results <- list()

  for (qtr in 1:4) {
    url <- paste0(
      base_url,
      "?get=EarnHirAS,EarnS,HirA,Emp",
      "&for=county:*",
      "&in=state:", state_fips,
      "&year=", year,
      "&quarter=", qtr,
      "&ownercode=A05",
      "&industry=", industry_code,
      "&sex=0"
    )

    for (retry in 1:max_retries) {
      response <- tryCatch({
        httr::GET(url, httr::timeout(120))
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
            break
          }
        }
      }
      Sys.sleep(1)
    }
  }

  if (length(results) == 0) return(NULL)
  bind_rows(results)
}

# =============================================================================
# Fetch QWI Data
# =============================================================================

# Key industries for marijuana analysis
industries <- c(
  "00",      # All industries
  "11",      # Agriculture
  "44-45",   # Retail Trade
  "72",      # Accommodation/Food
  "48-49",   # Transportation
  "31-33",   # Manufacturing
  "23",      # Construction
  "54",      # Professional Services
  "52",      # Finance
  "51"       # Information
)

# Years: 2010-2023 for long pre-period
years <- 2010:2023

cat("\n=== Fetching QWI Data ===\n")
cat("States:", length(all_states), "\n")
cat("Years:", min(years), "-", max(years), "\n")
cat("Industries:", length(industries), "\n")

all_qwi <- list()
progress <- 0
total <- length(all_states) * length(years) * length(industries)

for (state in all_states) {
  state_data <- list()

  for (yr in years) {
    for (ind in industries) {
      progress <- progress + 1
      if (progress %% 50 == 0) {
        cat(sprintf("\rProgress: %d/%d (%.0f%%)", progress, total, 100*progress/total))
      }

      df <- fetch_qwi(state, yr, ind)
      if (!is.null(df)) {
        state_data[[length(state_data) + 1]] <- df
      }
      Sys.sleep(0.4)  # Rate limit
    }
  }

  if (length(state_data) > 0) {
    all_qwi[[state]] <- bind_rows(state_data)
  }
}

cat("\n")

# Combine
qwi_raw <- bind_rows(all_qwi)
cat("Total QWI rows:", nrow(qwi_raw), "\n")

# =============================================================================
# Clean and Merge
# =============================================================================

cat("\n=== Cleaning Data ===\n")

qwi_clean <- qwi_raw %>%
  mutate(
    EarnHirAS = as.numeric(EarnHirAS),
    EarnS = as.numeric(EarnS),
    HirA = as.numeric(HirA),
    Emp = as.numeric(Emp),
    year = as.numeric(year),
    quarter = as.numeric(quarter),
    county_fips = paste0(state, county),
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

# Merge with border info
qwi_border <- qwi_clean %>%
  inner_join(all_border_counties, by = c("county_fips" = "GEOID")) %>%
  left_join(
    treatment_dates %>% select(state_fips, treat_qtr_num, retail_date),
    by = c("treated_state" = "state_fips")
  ) %>%
  mutate(
    event_time = qtr_num - treat_qtr_num,
    post = event_time >= 0,
    in_bandwidth = dist_to_border <= 100
  )

cat("Final sample size:", nrow(qwi_border), "\n")
cat("Counties:", n_distinct(qwi_border$county_fips), "\n")
cat("Border pairs:", n_distinct(qwi_border$border_pair), "\n")

# Save
saveRDS(qwi_border, file.path(data_dir, "qwi_border.rds"))

cat("\n=== Summary ===\n")
qwi_border %>%
  filter(industry == "00", in_bandwidth) %>%
  group_by(border_pair, treated) %>%
  summarise(
    n = n(),
    mean_earn = mean(EarnHirAS, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  print(n = 30)

cat("\nData fetch complete!\n")
