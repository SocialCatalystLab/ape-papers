# =============================================================================
# Paper 110: The Price of Distance
# 04_build_analysis_data.R - Construct analysis dataset
# Uses existing FARS data from paper 0103 + new dispensary data
# =============================================================================

source(here::here("output/paper_110/code/00_packages.R"))

# =============================================================================
# 1. Load Data
# =============================================================================

message("Loading data...")

# Load FARS data from paper 0103 (already cleaned)
fars_raw <- readRDS(here::here("papers/apep_0103/data/fars_analysis_policy_fixed_clean.rds"))
message("FARS loaded: ", nrow(fars_raw), " crashes")

# Load dispensaries
dispensaries <- fread(file.path(data_dir, "dispensaries_osm.csv"))
message("Dispensaries loaded: ", nrow(dispensaries))

# =============================================================================
# 2. Define Study States
# =============================================================================

# Legal states (source of dispensaries)
legal_states <- c("CO", "WA", "OR", "NV", "CA", "AK")

# Illegal states (our analysis sample)
illegal_states <- c("ID", "WY", "NE", "KS", "UT", "AZ", "MT", "NM")

# Filter to illegal states
fars_illegal <- fars_raw %>%
  filter(state_abbr %in% illegal_states) %>%
  # Keep only geocoded crashes
  filter(!is.na(x_albers) & !is.na(y_albers))

message("Crashes in illegal states: ", nrow(fars_illegal))

# =============================================================================
# 3. Compute Driving Time to Nearest Dispensary
# =============================================================================

# Convert FARS coordinates back to lat/lon (from Albers)
# Paper 0103 used EPSG:5070 (Albers Equal Area)
fars_sf <- st_as_sf(fars_illegal, coords = c("x_albers", "y_albers"), crs = 5070)
fars_sf <- st_transform(fars_sf, 4326)

# Extract coordinates
coords <- st_coordinates(fars_sf)
fars_illegal$longitude <- coords[, 1]
fars_illegal$latitude <- coords[, 2]

# Function to compute haversine distance
haversine <- function(lat1, lon1, lat2, lon2) {
  R <- 6371  # Earth's radius in km
  dlat <- (lat2 - lat1) * pi / 180
  dlon <- (lon2 - lon1) * pi / 180
  a <- sin(dlat/2)^2 + cos(lat1 * pi/180) * cos(lat2 * pi/180) * sin(dlon/2)^2
  c <- 2 * atan2(sqrt(a), sqrt(1-a))
  R * c
}

# Compute distance to each dispensary and find minimum
message("Computing distances to dispensaries...")

# Create dispensary matrix
disp_mat <- dispensaries %>%
  select(latitude, longitude, state) %>%
  filter(!is.na(latitude), !is.na(longitude))

# For efficiency, compute distances in chunks
n_crashes <- nrow(fars_illegal)
dist_to_disp <- numeric(n_crashes)
nearest_state <- character(n_crashes)

pb <- progress_bar$new(total = n_crashes, format = "  [:bar] :percent eta: :eta")

for (i in 1:n_crashes) {
  if (i %% 1000 == 0) pb$update(i / n_crashes)

  crash_lat <- fars_illegal$latitude[i]
  crash_lon <- fars_illegal$longitude[i]

  if (is.na(crash_lat) | is.na(crash_lon)) {
    dist_to_disp[i] <- NA
    nearest_state[i] <- NA
    next
  }

  # Compute distance to all dispensaries
  dists <- haversine(crash_lat, crash_lon, disp_mat$latitude, disp_mat$longitude)

  # Find minimum
  min_idx <- which.min(dists)
  dist_to_disp[i] <- dists[min_idx]
  nearest_state[i] <- disp_mat$state[min_idx]
}

pb$terminate()

# Add to data
fars_illegal$dist_to_disp_km <- dist_to_disp
fars_illegal$nearest_disp_state <- nearest_state

# Convert to driving time (assuming 65 km/h average speed, 1.3 routing factor)
fars_illegal$drive_time_min <- (fars_illegal$dist_to_disp_km * 1.3 / 65) * 60

message("Distance computation complete.")

# =============================================================================
# 4. Construct Final Analysis Dataset
# =============================================================================

analysis_data <- fars_illegal %>%
  select(
    # Identifiers
    st_case, state_abbr, year, month, day, hour,
    # Location
    latitude, longitude, x_albers, y_albers,
    # Outcomes
    alc_involved, thc_positive_fixed, substance_cat_fixed,
    # Treatment
    dist_to_disp_km, drive_time_min, nearest_disp_state,
    dist_to_border_km,
    # Controls
    func_sys, sp_limit, is_weekend, hour_cat,
    # Policy info
    crash_date, crash_month
  ) %>%
  rename(
    alcohol_involved = alc_involved,
    thc_involved = thc_positive_fixed
  ) %>%
  mutate(
    # Create year-month
    year_month = floor_date(crash_date, "month"),
    # Nighttime indicator (10pm - 3am)
    nighttime = hour >= 22 | hour <= 3,
    # Create drive time bins
    drive_time_bin = cut(
      drive_time_min,
      breaks = c(0, 60, 120, 180, 240, 300, Inf),
      labels = c("0-60", "60-120", "120-180", "180-240", "240-300", "300+"),
      right = FALSE
    ),
    # Distance band for heterogeneity
    dist_band = case_when(
      dist_to_disp_km <= 50 ~ "0-50km",
      dist_to_disp_km <= 100 ~ "50-100km",
      dist_to_disp_km <= 200 ~ "100-200km",
      TRUE ~ ">200km"
    ),
    dist_band = factor(dist_band, levels = c("0-50km", "50-100km", "100-200km", ">200km"))
  )

message("\nAnalysis dataset constructed: ", nrow(analysis_data), " crashes")

# =============================================================================
# 5. Summary Statistics
# =============================================================================

message("\n=== Summary Statistics ===")

# By state
state_summary <- analysis_data %>%
  group_by(state_abbr) %>%
  summarize(
    n_crashes = n(),
    pct_alcohol = mean(alcohol_involved, na.rm = TRUE) * 100,
    mean_drive_time = mean(drive_time_min, na.rm = TRUE),
    median_drive_time = median(drive_time_min, na.rm = TRUE),
    nearest_legal = names(sort(table(nearest_disp_state), decreasing = TRUE))[1],
    .groups = "drop"
  )

print(state_summary)

# By year
year_summary <- analysis_data %>%
  group_by(year) %>%
  summarize(
    n_crashes = n(),
    pct_alcohol = mean(alcohol_involved, na.rm = TRUE) * 100,
    .groups = "drop"
  )

message("\nBy year:")
print(year_summary)

# Overall
message("\nOverall:")
message("  Total crashes: ", nrow(analysis_data))
message("  Alcohol involvement: ", round(mean(analysis_data$alcohol_involved) * 100, 1), "%")
message("  Mean drive time: ", round(mean(analysis_data$drive_time_min, na.rm = TRUE), 0), " min")
message("  Median drive time: ", round(median(analysis_data$drive_time_min, na.rm = TRUE), 0), " min")

# =============================================================================
# 6. Save
# =============================================================================

saveRDS(analysis_data, file.path(data_dir, "analysis_data.rds"))
fwrite(state_summary, file.path(tab_dir, "summary_by_state.csv"))

message("\nSaved analysis data to: ", file.path(data_dir, "analysis_data.rds"))
