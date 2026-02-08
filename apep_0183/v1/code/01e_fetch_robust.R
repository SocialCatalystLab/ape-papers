# =============================================================================
# 01e_fetch_robust.R
# Robust QWI Fetch - Census API with Better Rate Limiting
# =============================================================================

source("00_packages.R")

# =============================================================================
# Treatment Timing (Expanded)
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

cat("Treatment states:\n")
print(treatment_dates)

# =============================================================================
# Geographic Data - Build from Scratch
# =============================================================================

cat("\n=== Building Geographic Data ===\n")

# States of interest
treated_states <- c("CO", "WA")
neighbor_states <- list(
  "CO" = c("KS", "NE", "WY", "UT", "NM", "OK"),
  "WA" = c("ID", "OR")
)

all_states <- c(treated_states, unlist(neighbor_states)) %>% unique()

# State FIPS codes
state_fips_lookup <- tribble(
  ~state_abbr, ~state_fips, ~state_name,
  "CO", "08", "Colorado",
  "KS", "20", "Kansas",
  "NE", "31", "Nebraska",
  "WY", "56", "Wyoming",
  "UT", "49", "Utah",
  "NM", "35", "New Mexico",
  "OK", "40", "Oklahoma",
  "WA", "53", "Washington",
  "ID", "16", "Idaho",
  "OR", "41", "Oregon"
)

# Download county shapefiles
cat("Downloading county shapefiles...\n")
counties_sf <- counties(state = all_states, cb = TRUE, year = 2020) %>%
  st_transform(crs = 4326) %>%
  mutate(
    state_fips = STATEFP,
    county_fips = GEOID,
    county_name = NAME
  ) %>%
  left_join(state_fips_lookup, by = "state_fips")

cat("Counties downloaded:", nrow(counties_sf), "\n")

# Download state boundaries
states_sf <- states(cb = TRUE, year = 2020) %>%
  st_transform(crs = 4326) %>%
  filter(STUSPS %in% all_states)

# =============================================================================
# Calculate Border Distances
# =============================================================================

cat("\n=== Calculating Border Distances ===\n")

# Get state borders as lines
get_shared_border <- function(state1, state2) {
  s1 <- states_sf %>% filter(STUSPS == state1)
  s2 <- states_sf %>% filter(STUSPS == state2)

  if (nrow(s1) == 0 || nrow(s2) == 0) return(NULL)

  border <- st_intersection(st_boundary(s1), st_boundary(s2))
  if (length(border) == 0 || st_is_empty(border)) return(NULL)

  return(border)
}

# Build border county dataset
border_counties_list <- list()

for (treated_st in treated_states) {
  treated_fips <- state_fips_lookup$state_fips[state_fips_lookup$state_abbr == treated_st]
  neighbors <- neighbor_states[[treated_st]]

  for (neighbor_st in neighbors) {
    neighbor_fips <- state_fips_lookup$state_fips[state_fips_lookup$state_abbr == neighbor_st]

    # Get shared border
    border <- tryCatch(
      get_shared_border(treated_st, neighbor_st),
      error = function(e) NULL
    )

    if (is.null(border) || st_is_empty(border)) {
      cat("  No border found:", treated_st, "-", neighbor_st, "\n")
      next
    }

    # Get counties from both states
    treated_counties <- counties_sf %>% filter(state_abbr == treated_st)
    neighbor_counties <- counties_sf %>% filter(state_abbr == neighbor_st)

    if (nrow(treated_counties) == 0 || nrow(neighbor_counties) == 0) next

    # Calculate distances to border
    treated_centroids <- st_centroid(treated_counties)
    neighbor_centroids <- st_centroid(neighbor_counties)

    # Distance in km
    treated_dists <- as.numeric(st_distance(treated_centroids, border)) / 1000
    neighbor_dists <- as.numeric(st_distance(neighbor_centroids, border)) / 1000

    # Create border pair data
    border_pair_name <- paste0(treated_st, "-", neighbor_st)

    # Treated side
    treated_df <- treated_counties %>%
      st_drop_geometry() %>%
      mutate(
        border_pair = border_pair_name,
        treated = 1,
        treated_state = treated_fips,
        dist_to_border = treated_dists,
        dist_km = -dist_to_border  # Negative = treated side
      ) %>%
      select(county_fips, county_name, state_abbr, state_fips,
             border_pair, treated, treated_state, dist_to_border, dist_km)

    # Control side
    control_df <- neighbor_counties %>%
      st_drop_geometry() %>%
      mutate(
        border_pair = border_pair_name,
        treated = 0,
        treated_state = treated_fips,
        dist_to_border = neighbor_dists,
        dist_km = dist_to_border  # Positive = control side
      ) %>%
      select(county_fips, county_name, state_abbr, state_fips,
             border_pair, treated, treated_state, dist_to_border, dist_km)

    border_counties_list[[border_pair_name]] <- bind_rows(treated_df, control_df)

    cat("  ", border_pair_name, ":", nrow(treated_df), "+", nrow(control_df), "counties\n")
  }
}

border_counties <- bind_rows(border_counties_list)
cat("\nTotal border county observations:", nrow(border_counties), "\n")

# Filter to counties within 200km of border
border_counties <- border_counties %>%
  filter(dist_to_border <= 200)

cat("Counties within 200km:", nrow(border_counties), "\n")

# Save geographic data
saveRDS(border_counties, file.path(data_dir, "border_counties.rds"))
saveRDS(counties_sf, file.path(data_dir, "counties_sf.rds"))
saveRDS(states_sf, file.path(data_dir, "states_sf.rds"))

# =============================================================================
# Fetch QWI Data via Census API
# =============================================================================

cat("\n=== Fetching QWI Data ===\n")

# Get unique state FIPS codes we need
states_needed <- unique(border_counties$state_fips)
cat("States needed:", paste(states_needed, collapse = ", "), "\n")

# Years to fetch (2010-2020 for CO/WA legalization)
years <- 2010:2020

# Industries: All + key sectors
industries <- c("00", "11", "21", "22", "23", "31-33", "42", "44-45",
                "48-49", "51", "52", "53", "54", "55", "56", "61", "62",
                "71", "72", "81", "92")

cat("Years:", min(years), "-", max(years), "\n")
cat("Industries:", length(industries), "\n")

# Robust fetch function with retries
fetch_qwi_robust <- function(state_fips, year, industry_code, max_retries = 3) {
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
      "&sex=0"
    )

    for (attempt in 1:max_retries) {
      response <- tryCatch({
        Sys.sleep(0.8 + runif(1, 0, 0.4))  # Rate limiting with jitter
        httr::GET(url, httr::timeout(90))
      }, error = function(e) NULL)

      if (!is.null(response) && httr::status_code(response) == 200) {
        content <- httr::content(response, "text", encoding = "UTF-8")
        if (nchar(content) > 10 && !grepl("error", tolower(content))) {
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
      } else if (!is.null(response) && httr::status_code(response) == 429) {
        # Rate limited - wait longer
        Sys.sleep(5 * attempt)
      }

      if (attempt == max_retries) {
        # Silent fail for this quarter
      }
    }
  }

  if (length(results) == 0) return(NULL)
  bind_rows(results)
}

# Fetch data
all_qwi <- list()
total_calls <- length(states_needed) * length(years) * length(industries)
progress <- 0

for (state in states_needed) {
  state_abbr <- state_fips_lookup$state_abbr[state_fips_lookup$state_fips == state]
  cat("\nFetching", state_abbr, "(", state, ")...\n")

  for (yr in years) {
    for (ind in industries) {
      progress <- progress + 1

      if (progress %% 50 == 0) {
        cat(sprintf("\rProgress: %d/%d (%.1f%%)", progress, total_calls, 100*progress/total_calls))
      }

      df <- fetch_qwi_robust(state, yr, ind)
      if (!is.null(df) && nrow(df) > 0) {
        all_qwi[[length(all_qwi) + 1]] <- df
      }
    }
  }
}

cat("\n\nCombining data...\n")

# Combine all QWI data
qwi_raw <- bind_rows(all_qwi)
cat("Total QWI rows:", nrow(qwi_raw), "\n")

if (nrow(qwi_raw) == 0) {
  stop("No QWI data fetched! Check API access.")
}

# =============================================================================
# Clean and Merge
# =============================================================================

cat("\n=== Cleaning and Merging ===\n")

qwi_clean <- qwi_raw %>%
  mutate(
    EarnHirAS = as.numeric(EarnHirAS),
    EarnS = as.numeric(EarnS),
    Emp = as.numeric(Emp),
    HirA = as.numeric(HirA),
    year = as.numeric(year),
    quarter = as.numeric(quarter),
    # CRITICAL: Keep county_fips as CHARACTER
    county_fips = paste0(state, county),
    state_fips = state,
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
cat("Unique counties in QWI:", n_distinct(qwi_clean$county_fips), "\n")
cat("Unique counties in borders:", n_distinct(border_counties$county_fips), "\n")

# Check type alignment
cat("\nType check:\n")
cat("  QWI county_fips type:", class(qwi_clean$county_fips), "\n")
cat("  Border county_fips type:", class(border_counties$county_fips), "\n")

# Ensure both are character for join
border_counties <- border_counties %>%
  mutate(county_fips = as.character(county_fips))

qwi_clean <- qwi_clean %>%
  mutate(county_fips = as.character(county_fips))

# Sample values for debugging
cat("\nSample county_fips values:\n")
cat("  QWI:", head(unique(qwi_clean$county_fips), 5), "\n")
cat("  Border:", head(unique(border_counties$county_fips), 5), "\n")

# Merge with border info
qwi_border <- qwi_clean %>%
  inner_join(
    border_counties %>% select(county_fips, county_name, border_pair, treated,
                               treated_state, dist_to_border, dist_km),
    by = "county_fips"
  )

cat("\nAfter border merge:", nrow(qwi_border), "rows\n")

if (nrow(qwi_border) == 0) {
  cat("\nWARNING: No matches found. Checking overlap...\n")
  overlap <- intersect(qwi_clean$county_fips, border_counties$county_fips)
  cat("Overlapping counties:", length(overlap), "\n")
  if (length(overlap) > 0) {
    cat("Sample overlap:", head(overlap, 10), "\n")
  }
}

# Add treatment timing
qwi_border <- qwi_border %>%
  left_join(
    treatment_dates %>% select(state_fips, treat_qtr_num),
    by = c("treated_state" = "state_fips")
  ) %>%
  mutate(
    event_time = qtr_num - treat_qtr_num,
    post = event_time >= 0,
    in_bandwidth = dist_to_border <= 100
  )

cat("\nFinal sample:\n")
cat("  Rows:", nrow(qwi_border), "\n")
cat("  Counties:", n_distinct(qwi_border$county_fips), "\n")
cat("  Border pairs:", n_distinct(qwi_border$border_pair), "\n")
cat("  Industries:", n_distinct(qwi_border$industry), "\n")
cat("  Quarters:", n_distinct(qwi_border$qtr_num), "\n")

# =============================================================================
# Save
# =============================================================================

saveRDS(qwi_border, file.path(data_dir, "qwi_border.rds"))
saveRDS(treatment_dates, file.path(data_dir, "treatment_dates.rds"))

# Summary by border pair
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
  print(n = 20)

cat("\n=== Data fetch complete! ===\n")
