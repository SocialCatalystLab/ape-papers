# =============================================================================
# 01_fetch_data.R
# Fetch QWI Data and Calculate Border Distances for DiDisc Analysis
# =============================================================================

source("00_packages.R")

# =============================================================================
# Treatment Timing
# =============================================================================

# Retail opening dates (treatment onset)
treatment_dates <- tribble(
  ~state_fips, ~state_abbr, ~state_name, ~election_date, ~retail_date,
  "08", "CO", "Colorado",     "2012-11-06", "2014-01-01",
  "53", "WA", "Washington",   "2012-11-06", "2014-07-08",
  "41", "OR", "Oregon",       "2014-11-04", "2015-10-01",
  "32", "NV", "Nevada",       "2016-11-08", "2017-07-01",
  "06", "CA", "California",   "2016-11-08", "2018-01-01",
  "25", "MA", "Massachusetts","2016-11-08", "2018-11-20",
  "26", "MI", "Michigan",     "2018-11-06", "2019-12-01",
  "17", "IL", "Illinois",     "2019-06-25", "2020-01-01"
) %>%
  mutate(
    election_date = as.Date(election_date),
    retail_date = as.Date(retail_date),
    # Quarter of retail opening (treatment quarter)
    treat_year = year(retail_date),
    treat_qtr = quarter(retail_date),
    treat_qtr_num = treat_year * 4 + treat_qtr
  )

cat("Treatment states:\n")
print(treatment_dates %>% select(state_abbr, retail_date, treat_qtr_num))

# =============================================================================
# State Adjacency for Border Pairs
# =============================================================================

# Define border control states (neighbors of treated states without RML)
# Excluding states that legalized during sample or have no land border

border_pairs <- tribble(
  ~treated_fips, ~control_fips, ~treated_abbr, ~control_abbr,
  # Colorado borders
  "08", "04", "CO", "AZ",
  "08", "35", "CO", "NM",
  "08", "49", "CO", "UT",
  "08", "56", "CO", "WY",
  "08", "31", "CO", "NE",
  "08", "20", "CO", "KS",
  "08", "40", "CO", "OK",
  # Washington borders
  "53", "16", "WA", "ID",
  # Oregon borders
  "41", "16", "OR", "ID",
  "41", "32", "OR", "NV",  # NV treated later - use pre-NV period only
  "41", "06", "OR", "CA",  # CA treated later - use pre-CA period only
  # Nevada borders
  "32", "04", "NV", "AZ",
  "32", "49", "NV", "UT",
  "32", "16", "NV", "ID",
  # California borders
  "06", "04", "CA", "AZ",
  # Massachusetts borders
  "25", "09", "MA", "CT",
  "25", "44", "MA", "RI",
  "25", "33", "MA", "NH",
  "25", "50", "MA", "VT",  # VT legalized later
  "25", "36", "MA", "NY",  # NY legalized later
  # Michigan borders
  "26", "18", "MI", "IN",
  "26", "39", "MI", "OH",
  "26", "55", "MI", "WI",
  # Illinois borders
  "17", "18", "IL", "IN",
  "17", "19", "IL", "IA",
  "17", "21", "IL", "KY",
  "17", "29", "IL", "MO",
  "17", "55", "IL", "WI"
)

# Get unique states needed
all_states <- unique(c(border_pairs$treated_fips, border_pairs$control_fips))
cat("\nFetching data for", length(all_states), "states\n")

# =============================================================================
# Download County and State Shapefiles
# =============================================================================

cat("\n=== Downloading Shapefiles ===\n")

# Get all county boundaries
counties_sf <- counties(cb = TRUE, year = 2020) %>%
  filter(STATEFP %in% all_states) %>%
  st_transform(crs = 5070)  # Albers Equal Area for accurate distance

# Get state boundaries
states_sf <- states(cb = TRUE, year = 2020) %>%
  filter(STATEFP %in% all_states) %>%
  st_transform(crs = 5070)

cat("Downloaded", nrow(counties_sf), "counties in", length(unique(counties_sf$STATEFP)), "states\n")

# =============================================================================
# Calculate Distance to State Borders
# =============================================================================

cat("\n=== Calculating Border Distances ===\n")

# Function to calculate distance from county centroid to specific state border
calc_border_distance <- function(county_sf, border_sf) {
  # Get county centroid
  centroid <- st_centroid(county_sf)

  # Get border line (boundary of target state)
  border_line <- st_boundary(border_sf)

  # Calculate distance in meters
  dist_m <- st_distance(centroid, border_line)

  return(as.numeric(dist_m) / 1000)  # Convert to km
}

# Calculate distances for each border pair
border_distances <- list()

for (i in 1:nrow(border_pairs)) {
  pair <- border_pairs[i, ]

  # Get treated state boundary
  treated_boundary <- states_sf %>%
    filter(STATEFP == pair$treated_fips)

  # Get control state boundary
  control_boundary <- states_sf %>%
    filter(STATEFP == pair$control_fips)

  # Get counties in both states
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

  # Calculate distance to the shared border (approximate as distance to other state)
  # For treated counties: distance to control state
  treated_counties$dist_to_border <- sapply(
    1:nrow(treated_counties),
    function(j) calc_border_distance(treated_counties[j, ], control_boundary)
  )

  # For control counties: distance to treated state
  control_counties$dist_to_border <- sapply(
    1:nrow(control_counties),
    function(j) calc_border_distance(control_counties[j, ], treated_boundary)
  )

  # Combine
  pair_counties <- bind_rows(treated_counties, control_counties) %>%
    mutate(
      # Signed distance: positive for treated, negative for control
      signed_dist = ifelse(treated, dist_to_border, -dist_to_border),
      treated_state = pair$treated_fips,
      control_state = pair$control_fips
    )

  border_distances[[i]] <- pair_counties

  cat(sprintf("  %s-%s: %d treated counties, %d control counties\n",
              pair$treated_abbr, pair$control_abbr,
              sum(pair_counties$treated), sum(!pair_counties$treated)))
}

# Combine all border pairs
all_border_counties <- bind_rows(border_distances) %>%
  st_drop_geometry() %>%
  select(GEOID, NAME, STATEFP, border_pair, treated, dist_to_border, signed_dist,
         treated_state, control_state)

cat("\nTotal border county-pair observations:", nrow(all_border_counties), "\n")

# =============================================================================
# QWI Data Fetch Function
# =============================================================================

fetch_qwi_county_industry <- function(state_fips, year, industry_code) {
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
      "&sex=0"  # Both sexes
    )

    response <- tryCatch({
      httr::GET(url, httr::timeout(120))
    }, error = function(e) {
      cat("  API error for", state_fips, year, "Q", qtr, ":", e$message, "\n")
      return(NULL)
    })

    if (is.null(response) || httr::status_code(response) != 200) {
      Sys.sleep(0.5)
      next
    }

    content <- httr::content(response, "text", encoding = "UTF-8")
    if (content == "" || nchar(content) < 10) next

    data <- tryCatch({
      jsonlite::fromJSON(content)
    }, error = function(e) NULL)

    if (is.null(data) || nrow(data) < 2) next

    df <- as.data.frame(data[-1, , drop = FALSE], stringsAsFactors = FALSE)
    colnames(df) <- data[1, ]

    df$year <- year
    df$quarter <- qtr
    df$industry <- industry_code

    results[[length(results) + 1]] <- df
  }

  if (length(results) == 0) return(NULL)
  bind_rows(results)
}

# =============================================================================
# Fetch QWI Data for All Border States
# =============================================================================

# Industries to fetch (NAICS 2-digit sectors)
industries <- c(
  "11",      # Agriculture
  "21",      # Mining
  "23",      # Construction
  "31-33",   # Manufacturing
  "42",      # Wholesale Trade
  "44-45",   # Retail Trade
  "48-49",   # Transportation
  "51",      # Information
  "52",      # Finance
  "53",      # Real Estate
  "54",      # Professional Services
  "55",      # Management
  "56",      # Admin Services
  "61",      # Education
  "62",      # Health Care
  "71",      # Arts/Entertainment
  "72",      # Accommodation/Food
  "81",      # Other Services
  "00"       # All industries (aggregate)
)

# Years to fetch (need long pre-period)
years <- 2010:2023

cat("\n=== Fetching QWI Data ===\n")
cat("States:", length(all_states), "\n")
cat("Years:", min(years), "-", max(years), "\n")
cat("Industries:", length(industries), "\n")

all_qwi <- list()
total_calls <- length(all_states) * length(years) * length(industries)
call_count <- 0

for (state in all_states) {
  cat("\nFetching state:", state, "...")
  state_data <- list()

  for (yr in years) {
    for (ind in industries) {
      df <- fetch_qwi_county_industry(state, yr, ind)
      if (!is.null(df)) {
        state_data[[length(state_data) + 1]] <- df
      }
      call_count <- call_count + 1

      # Rate limiting
      Sys.sleep(0.3)

      if (call_count %% 100 == 0) {
        cat(sprintf("\r  Progress: %d/%d (%.1f%%)", call_count, total_calls,
                    100 * call_count / total_calls))
      }
    }
  }

  if (length(state_data) > 0) {
    all_qwi[[state]] <- bind_rows(state_data)
    cat(" OK (", nrow(all_qwi[[state]]), " rows)\n")
  } else {
    cat(" NO DATA\n")
  }
}

# Combine all QWI data
qwi_raw <- bind_rows(all_qwi)
cat("\n\nTotal QWI rows:", nrow(qwi_raw), "\n")

# =============================================================================
# Clean and Merge Data
# =============================================================================

cat("\n=== Cleaning and Merging ===\n")

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

# Merge with border distances
qwi_border <- qwi_clean %>%
  inner_join(all_border_counties, by = c("county_fips" = "GEOID")) %>%
  left_join(treatment_dates %>% select(state_fips, treat_qtr_num, retail_date, election_date),
            by = c("treated_state" = "state_fips")) %>%
  mutate(
    # Event time relative to retail opening
    event_time = qtr_num - treat_qtr_num,
    post = event_time >= 0,
    # Restrict to bandwidth (100km default)
    in_bandwidth = dist_to_border <= 100
  )

cat("Border sample size:", nrow(qwi_border), "\n")
cat("Counties:", length(unique(qwi_border$county_fips)), "\n")
cat("Border pairs:", length(unique(qwi_border$border_pair)), "\n")
cat("Industries:", length(unique(qwi_border$industry)), "\n")

# =============================================================================
# Save Data
# =============================================================================

saveRDS(qwi_border, file.path(data_dir, "qwi_border.rds"))
saveRDS(treatment_dates, file.path(data_dir, "treatment_dates.rds"))
saveRDS(all_border_counties, file.path(data_dir, "border_counties.rds"))
saveRDS(counties_sf, file.path(data_dir, "counties_sf.rds"))
saveRDS(states_sf, file.path(data_dir, "states_sf.rds"))

cat("\n=== Data Saved ===\n")
cat("Main file: data/qwi_border.rds\n")

# Summary statistics
cat("\n=== Summary by Border Pair ===\n")
qwi_border %>%
  filter(industry == "00", in_bandwidth) %>%
  group_by(border_pair, treated) %>%
  summarise(
    n_counties = n_distinct(county_fips),
    n_obs = n(),
    mean_earn = mean(EarnHirAS, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(border_pair, desc(treated)) %>%
  print(n = 50)

cat("\nData fetch complete.\n")
