# =============================================================================
# Paper 107: Spatial RDD of Primary Seatbelt Enforcement Laws
# 02_clean_data.R - Compute distance to borders, create analysis dataset
# =============================================================================

source(here::here("output/paper_107/code/00_packages.R"))

# Load data
fars_sf <- readRDS(file.path(dir_data, "fars_sf.rds"))
states_sf <- readRDS(file.path(dir_data, "states_sf.rds"))
seatbelt_laws <- readRDS(file.path(dir_data, "seatbelt_laws.rds"))

message("Crashes loaded: ", nrow(fars_sf))
message("States loaded: ", nrow(states_sf))

# =============================================================================
# 1. Determine Primary/Secondary Status by State-Year
# =============================================================================

message("\nDetermining enforcement status by state-year...")

# Create state enforcement lookup with exact dates
# Note: We use crash date vs effective date, not year-level classification
state_enforcement <- seatbelt_laws %>%
  select(state_abbr, enforcement_type, primary_date)

# Join to crashes
fars_sf <- fars_sf %>%
  st_join(states_sf %>% select(state_abbr), left = TRUE)

# Add enforcement status based on EXACT crash date vs effective date
# This avoids misclassifying crashes in adoption years
fars_sf <- fars_sf %>%
  left_join(state_enforcement, by = "state_abbr") %>%
  mutate(
    # Create crash date from month/day/year if available, else use year only
    crash_date = as.Date(sprintf("%04d-%02d-%02d", year,
                                  pmax(1, pmin(12, as.numeric(month))),
                                  pmax(1, pmin(28, as.numeric(day)))),
                         format = "%Y-%m-%d"),
    is_primary = case_when(
      # Secondary or no-law states: never primary
      enforcement_type != "primary" ~ FALSE,
      # Primary state with known date: check crash date >= effective date
      enforcement_type == "primary" & !is.na(primary_date) ~ crash_date >= primary_date,
      # Primary state with missing date (always primary in our data): TRUE
      enforcement_type == "primary" & is.na(primary_date) ~ TRUE,
      TRUE ~ NA
    )
  )

message("Crashes with primary enforcement: ", sum(fars_sf$is_primary, na.rm = TRUE))
message("Crashes with secondary enforcement: ", sum(!fars_sf$is_primary, na.rm = TRUE))

# =============================================================================
# 2. Compute Distance to Nearest Opposite-Enforcement State
# =============================================================================

message("\nComputing distance to enforcement borders...")

# For each year, identify which states have primary vs secondary
# Then compute distance from each crash to nearest border with opposite enforcement

compute_border_distance_simple <- function(crashes_sf, states_sf, year_val) {
  message("  Year ", year_val, ": ", sum(crashes_sf$year == year_val), " crashes")

  # Filter crashes for this year
  crashes_year <- crashes_sf %>%
    filter(year == year_val) %>%
    mutate(crash_idx = row_number())

  if (nrow(crashes_year) == 0) return(NULL)

  # For each crash, we already have is_primary based on exact date
  # Now compute distance to nearest state with OPPOSITE enforcement as of crash date

  # Get all states and their enforcement type (simplified - use 2019 status for borders)
  # This defines which borders exist, not treatment assignment
  state_status <- state_enforcement %>%
    mutate(border_is_primary = enforcement_type == "primary") %>%
    select(state_abbr, border_is_primary)

  states_year <- states_sf %>%
    left_join(state_status, by = "state_abbr")

  primary_states <- states_year %>% filter(border_is_primary) %>% st_union()
  secondary_states <- states_year %>% filter(!border_is_primary) %>% st_union()

  # Compute distance from each crash to each enforcement type
  crashes_year <- crashes_year %>%
    mutate(
      dist_to_primary = as.numeric(st_distance(., primary_states)),
      dist_to_secondary = as.numeric(st_distance(., secondary_states)),
      # Distance to relevant border (signed: positive = primary side)
      # Note: is_primary already determined by exact crash date
      dist_to_border_m = if_else(is_primary, dist_to_secondary, dist_to_primary),
      dist_to_border_km = dist_to_border_m / 1000,
      signed_dist_km = if_else(is_primary, dist_to_border_km, -dist_to_border_km)
    )

  return(crashes_year %>% st_drop_geometry() %>% select(crash_idx, signed_dist_km, dist_to_border_km))
}

# Process year by year
distance_results <- map_dfr(2001:2019, function(yr) {
  compute_border_distance_simple(fars_sf, states_sf, yr)
})

# Add back to main data
fars_sf <- fars_sf %>%
  mutate(crash_idx = row_number()) %>%
  left_join(distance_results, by = "crash_idx")

message("\n✓ Distance computed for ", sum(!is.na(fars_sf$signed_dist_km)), " crashes")

# =============================================================================
# 3. Restrict to Border Region
# =============================================================================

max_bandwidth <- 100  # km

analysis_near_border <- fars_sf %>%
  filter(!is.na(signed_dist_km)) %>%
  filter(abs(signed_dist_km) <= max_bandwidth)

message("Crashes within ", max_bandwidth, " km of border: ", nrow(analysis_near_border))

# =============================================================================
# 4. Create Outcome Variables
# =============================================================================

message("\nCreating outcome variables...")

analysis_near_border <- analysis_near_border %>%
  mutate(
    # Treatment indicator
    treated = as.numeric(is_primary),

    # Running variable
    running_var = signed_dist_km,

    # Outcomes - compute fatality probability
    fatality_prob = n_fatals / pmax(n_persons, 1),
    fatals_per_crash = n_fatals,

    # Mechanism variables
    any_ejection = as.numeric(n_ejected > 0),

    # Placebo
    nonoccupant_deaths = n_pedestrians + n_cyclists,

    # Crash characteristics
    single_vehicle = as.numeric(ve_total == 1),
    multi_vehicle = as.numeric(ve_total > 1),

    # Time
    night_crash = as.numeric(hour >= 20 | hour <= 5),

    # Cluster
    border_cluster = paste(state_abbr, year, sep = "_")
  )

# =============================================================================
# 5. Summary Statistics
# =============================================================================

message("\n=== Analysis Data Summary ===")

summary_stats <- analysis_near_border %>%
  st_drop_geometry() %>%
  group_by(treated) %>%
  summarise(
    n_crashes = n(),
    mean_fatality_prob = mean(fatality_prob, na.rm = TRUE),
    mean_fatals = mean(fatals_per_crash, na.rm = TRUE),
    mean_persons = mean(n_persons, na.rm = TRUE),
    mean_ejection = mean(any_ejection, na.rm = TRUE),
    .groups = "drop"
  )

print(summary_stats)

message("\nDistance to border distribution:")
message("  Min: ", round(min(analysis_near_border$signed_dist_km, na.rm = TRUE), 1), " km")
message("  Max: ", round(max(analysis_near_border$signed_dist_km, na.rm = TRUE), 1), " km")
message("  Median: ", round(median(analysis_near_border$signed_dist_km, na.rm = TRUE), 1), " km")

# =============================================================================
# 6. Save Analysis Dataset
# =============================================================================

# Get coordinates before dropping geometry
coords <- st_coordinates(analysis_near_border)
analysis_df <- analysis_near_border %>%
  st_drop_geometry() %>%
  mutate(
    crash_lat = coords[, 2],
    crash_lon = coords[, 1]
  )

saveRDS(analysis_df, file.path(dir_data, "analysis_df.rds"))
saveRDS(analysis_near_border, file.path(dir_data, "analysis_sf.rds"))

message("\n✓ Analysis dataset saved: ", nrow(analysis_df), " observations")
