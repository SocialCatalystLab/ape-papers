# =============================================================================
# Paper 108: Geocoded Atlas of US Traffic Fatalities 2001-2023
# 05_build_analysis.R - Build final analysis dataset
# =============================================================================

source(here::here("output/paper_108/code/00_packages.R"))

# =============================================================================
# 1. Load All Data Components
# =============================================================================

message("Loading data components...")

# Load FARS with policy (if available)
fars_file <- file.path(dir_data, "fars_analysis_policy.rds")
if (file.exists(fars_file)) {
  fars <- readRDS(fars_file)
  message("  Loaded FARS with policy data: ", format(nrow(fars), big.mark = ","), " crashes")
} else {
  # Fall back to basic FARS
  fars_file <- file.path(dir_data, "fars_analysis.rds")
  if (file.exists(fars_file)) {
    fars <- readRDS(fars_file)
    message("  Loaded basic FARS data: ", format(nrow(fars), big.mark = ","), " crashes")
    message("  Note: Run 04_merge_policy.R to add policy variables")
  } else {
    stop("FARS data not found. Run 01_fetch_fars.R first.")
  }
}

# Load states (if available)
states_file <- file.path(dir_data, "states_sf.rds")
if (file.exists(states_file)) {
  states_sf <- readRDS(states_file)
  message("  Loaded state boundaries: ", nrow(states_sf), " states")
}

# Load snapped crashes (if available)
snapped_file <- file.path(dir_data, "fars_snapped.csv")
if (file.exists(snapped_file)) {
  fars_snapped <- fread(snapped_file)
  message("  Loaded snapped crashes: ", format(nrow(fars_snapped), big.mark = ","))

  # Merge road attributes into main dataset
  if ("highway" %in% names(fars_snapped)) {
    fars <- fars %>%
      left_join(
        fars_snapped %>% select(st_case, state, year, highway, road_name, maxspeed, lanes, snap_dist_m),
        by = c("st_case", "state", "year")
      )
    message("  Merged road network attributes")
  }
}

# =============================================================================
# 2. Create Additional Derived Variables
# =============================================================================

message("\nCreating derived variables...")

fars <- fars %>%
  mutate(
    # Crash characteristics
    crash_id = paste(state, st_case, year, sep = "_"),

    # Road classification (from OSM highway tag if available)
    road_class = case_when(
      highway %in% c("motorway", "motorway_link") ~ "Interstate",
      highway %in% c("trunk", "trunk_link") ~ "US Highway",
      highway %in% c("primary", "primary_link") ~ "State Highway",
      highway %in% c("secondary", "secondary_link") ~ "Major Local",
      highway %in% c("tertiary", "tertiary_link", "residential") ~ "Minor Local",
      TRUE ~ "Unknown"
    ),

    # Speed limit category
    speed_cat = case_when(
      !is.na(maxspeed) & as.numeric(gsub("[^0-9]", "", maxspeed)) >= 65 ~ "65+ mph",
      !is.na(maxspeed) & as.numeric(gsub("[^0-9]", "", maxspeed)) >= 55 ~ "55-64 mph",
      !is.na(maxspeed) & as.numeric(gsub("[^0-9]", "", maxspeed)) >= 45 ~ "45-54 mph",
      !is.na(maxspeed) & as.numeric(gsub("[^0-9]", "", maxspeed)) >= 35 ~ "35-44 mph",
      !is.na(maxspeed) ~ "< 35 mph",
      TRUE ~ "Unknown"
    ),

    # Impairment categories
    any_impaired = thc_positive | any_alc_positive | driver_bac_over_08,
    impairment_type = case_when(
      thc_positive & driver_bac_over_08 ~ "Both THC + High BAC",
      thc_positive & any_alc_positive ~ "THC + Some Alcohol",
      driver_bac_over_08 ~ "High BAC (>=0.08)",
      any_alc_positive ~ "Low BAC (>0, <0.08)",
      thc_positive ~ "THC Only",
      TRUE ~ "None/Unknown"
    ),

    # Crash type indicators
    single_vehicle = ve_total == 1,
    multi_vehicle = ve_total > 1,

    # Pedestrian/cyclist involved
    ped_cyc_involved = n_pedestrians > 0 | n_cyclists > 0,

    # Young driver involved
    young_driver = any_young_driver,

    # Night crash
    night_crash = hour >= 20 | hour < 6,

    # Weekend crash
    weekend = is_weekend
  )

message("  Created ", sum(startsWith(names(fars), c("road_", "speed_", "impairment_"))), " derived variables")

# =============================================================================
# 3. Data Quality Checks
# =============================================================================

message("\nData quality checks...")

# Check for duplicates
n_dups <- fars %>%
  group_by(crash_id) %>%
  filter(n() > 1) %>%
  nrow()

if (n_dups > 0) {
  message("  Warning: ", n_dups, " potential duplicate crash IDs")
  fars <- fars %>% distinct(crash_id, .keep_all = TRUE)
  message("  Removed duplicates, ", nrow(fars), " crashes remaining")
}

# Check variable ranges
message("  Checking variable ranges...")
stopifnot(all(fars$year >= 2001 & fars$year <= 2023, na.rm = TRUE))
stopifnot(all(fars$month >= 1 & fars$month <= 12, na.rm = TRUE))
stopifnot(all(fars$hour >= 0 & fars$hour <= 24 | is.na(fars$hour)))

# Report missing data rates
missing_rates <- fars %>%
  summarise(
    latitude = 100 * sum(is.na(latitude)) / n(),
    thc_positive = 100 * sum(is.na(thc_positive)) / n(),
    any_alc_positive = 100 * sum(is.na(any_alc_positive)) / n(),
    hour = 100 * sum(is.na(hour) | hour == 99) / n(),
    dist_to_border_km = 100 * sum(is.na(dist_to_border_km)) / n()
  )

message("  Missing data rates:")
message("    Coordinates: ", round(missing_rates$latitude, 1), "%")
message("    THC test: ", round(missing_rates$thc_positive, 1), "%")
message("    Alcohol test: ", round(missing_rates$any_alc_positive, 1), "%")
message("    Hour: ", round(missing_rates$hour, 1), "%")
message("    Border distance: ", round(missing_rates$dist_to_border_km, 1), "%")

# =============================================================================
# 4. Save Final Analysis Dataset
# =============================================================================

message("\nSaving final analysis dataset...")

# Save full dataset
saveRDS(fars, file.path(dir_data, "fars_final.rds"))
message("  Saved fars_final.rds")

# Save as CSV for portability
fwrite(fars, file.path(dir_data, "fars_final.csv"))
message("  Saved fars_final.csv")

# Save as feather for Python
write_feather <- function(df, path) {
  tryCatch({
    arrow::write_feather(df, path)
    message("  Saved ", basename(path))
  }, error = function(e) {
    message("  Note: Could not save feather file (arrow package may not be installed)")
  })
}
write_feather(fars, file.path(dir_data, "fars_final.feather"))

# =============================================================================
# 5. Create Analysis Subsets
# =============================================================================

message("\nCreating analysis subsets...")

# Legal states subset
fars_legal <- fars %>%
  filter(state_abbr %in% c("CO", "WA", "OR", "CA", "NV", "AK"))
saveRDS(fars_legal, file.path(dir_data, "fars_legal_states.rds"))
message("  Legal states: ", format(nrow(fars_legal), big.mark = ","), " crashes")

# Border region subset (within 100km of a marijuana border)
if ("dist_to_border_km" %in% names(fars) && sum(!is.na(fars$dist_to_border_km)) > 0) {
  fars_border <- fars %>%
    filter(!is.na(dist_to_border_km), dist_to_border_km < 100)
  saveRDS(fars_border, file.path(dir_data, "fars_border_region.rds"))
  message("  Border region: ", format(nrow(fars_border), big.mark = ","), " crashes")
}

# Post-legalization subset (2014+)
fars_post2014 <- fars %>%
  filter(year >= 2014)
saveRDS(fars_post2014, file.path(dir_data, "fars_post2014.rds"))
message("  Post-2014: ", format(nrow(fars_post2014), big.mark = ","), " crashes")

# Tested for both drugs and alcohol
fars_tested <- fars %>%
  filter(!is.na(thc_positive), !is.na(any_alc_positive))
saveRDS(fars_tested, file.path(dir_data, "fars_tested.rds"))
message("  Dual tested: ", format(nrow(fars_tested), big.mark = ","), " crashes")

# =============================================================================
# 6. Summary
# =============================================================================

message("\n", strrep("=", 60))
message("FINAL DATASET SUMMARY")
message(strrep("=", 60))

message("\nTotal crashes: ", format(nrow(fars), big.mark = ","))
message("Time period: ", min(fars$year), " - ", max(fars$year))
message("States: ", n_distinct(fars$state_abbr))

message("\nCrashes by policy status:")
fars %>%
  count(policy_category) %>%
  arrange(desc(n)) %>%
  mutate(pct = round(100 * n / sum(n), 1)) %>%
  print()

message("\nSubstance involvement (among tested):")
fars %>%
  filter(!is.na(thc_positive) & !is.na(any_alc_positive)) %>%
  count(substance_cat) %>%
  mutate(pct = round(100 * n / sum(n), 1)) %>%
  print()

message("\nData files saved to: ", dir_data)
message(strrep("=", 60))
