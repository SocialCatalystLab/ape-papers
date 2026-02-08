# =============================================================================
# Paper 108: Geocoded Atlas of US Traffic Fatalities 2001-2023
# 04_merge_policy.R - Add marijuana legalization policy data
# =============================================================================

source(here::here("output/paper_108/code/00_packages.R"))

# =============================================================================
# 1. Marijuana Legalization Timeline
# =============================================================================

# Comprehensive marijuana policy data for Western states
# Sources: Harvard Dataverse, NORML, news archives
# Verified against multiple sources

marijuana_policy <- tribble(
  ~state, ~state_abbr, ~state_fips, ~medical_date, ~rec_ballot_date, ~rec_effective_date, ~retail_open_date,
  # Legal recreational states (Western focus)
  "Colorado", "CO", "08", "2000-11-07", "2012-11-06", "2012-12-10", "2014-01-01",
  "Washington", "WA", "53", "1998-11-03", "2012-11-06", "2012-12-06", "2014-07-08",
  "Oregon", "OR", "41", "1998-11-03", "2014-11-04", "2015-07-01", "2015-10-01",
  "Alaska", "AK", "02", "1998-11-03", "2014-11-04", "2015-02-24", "2016-10-29",
  "California", "CA", "06", "1996-11-05", "2016-11-08", "2016-11-09", "2018-01-01",
  "Nevada", "NV", "32", "2000-11-07", "2016-11-08", "2017-01-01", "2017-07-01",
  # Comparison states (illegal recreational during most of study period)
  "Wyoming", "WY", "56", NA_character_, NA_character_, NA_character_, NA_character_,
  "Nebraska", "NE", "31", NA_character_, NA_character_, NA_character_, NA_character_,
  "Kansas", "KS", "20", NA_character_, NA_character_, NA_character_, NA_character_,
  "Idaho", "ID", "16", NA_character_, NA_character_, NA_character_, NA_character_,
  "Utah", "UT", "49", "2018-11-06", NA_character_, NA_character_, NA_character_,
  "Arizona", "AZ", "04", "2010-11-02", "2020-11-03", "2020-11-30", "2021-01-22",
  "New Mexico", "NM", "35", "2007-04-02", "2021-04-12", "2021-06-29", "2022-04-01",
  "Montana", "MT", "30", "2004-11-02", "2020-11-03", "2021-01-01", "2022-01-01"
) %>%
  mutate(
    medical_date = as.Date(medical_date),
    rec_ballot_date = as.Date(rec_ballot_date),
    rec_effective_date = as.Date(rec_effective_date),
    retail_open_date = as.Date(retail_open_date)
  )

# Add derived policy indicators
marijuana_policy <- marijuana_policy %>%
  mutate(
    # Ever legal recreational
    ever_rec_legal = !is.na(rec_effective_date),
    # Early adopter (2012-2014)
    early_adopter = rec_effective_date <= as.Date("2014-12-31"),
    # Policy status category
    policy_category = case_when(
      state_abbr %in% c("CO", "WA") ~ "Pioneer (2012)",
      state_abbr %in% c("OR", "AK") ~ "Wave 2 (2014-15)",
      state_abbr %in% c("CA", "NV") ~ "Wave 3 (2016-17)",
      state_abbr %in% c("AZ", "MT", "NM") ~ "Wave 4 (2020+)",
      TRUE ~ "Never Legal"
    )
  )

message("Marijuana policy data compiled for ", nrow(marijuana_policy), " states")
print(marijuana_policy %>% select(state_abbr, rec_effective_date, retail_open_date, policy_category))

# Save policy data
saveRDS(marijuana_policy, file.path(dir_data_policy, "marijuana_policy.rds"))

# =============================================================================
# 2. State Boundaries from Census TIGER
# =============================================================================

message("\nFetching state boundaries...")

# Get state boundaries
states_sf <- states(cb = TRUE, year = 2020) %>%
  clean_names() %>%
  select(statefp, stusps, name, geometry) %>%
  rename(state_fips = statefp, state_abbr = stusps, state_name = name) %>%
  filter(state_fips %in% WESTERN_FIPS)

# Project to Albers Equal Area (NAD83)
states_sf <- st_transform(states_sf, crs = 5070)

# Join marijuana policy data
states_sf <- states_sf %>%
  left_join(marijuana_policy, by = c("state_abbr", "state_fips"))

saveRDS(states_sf, file.path(dir_data, "states_sf.rds"))
message("State boundaries saved with policy data")

# =============================================================================
# 3. Identify Border Pairs
# =============================================================================

message("\nIdentifying state borders...")

# Focus on policy-relevant borders
border_pairs <- tribble(
  ~legal_state, ~illegal_state, ~corridor, ~description,
  "CO", "WY", "I-25/I-80", "Colorado-Wyoming (sharpest contrast)",
  "CO", "NE", "I-76", "Colorado-Nebraska",
  "CO", "KS", "I-70", "Colorado-Kansas",
  "WA", "ID", "I-90", "Washington-Idaho (major corridor)",
  "OR", "ID", "I-84", "Oregon-Idaho",
  "CA", "AZ", "I-10/I-8", "California-Arizona (pre-2020)",
  "NV", "UT", "I-15", "Nevada-Utah (Las Vegas corridor)",
  "NV", "ID", "US-93", "Nevada-Idaho",
  "OR", "NV", "US-95", "Oregon-Nevada"
)

saveRDS(border_pairs, file.path(dir_data_policy, "border_pairs.rds"))

# =============================================================================
# 4. Load FARS Data and Add Policy Variables
# =============================================================================

message("\nLoading FARS data and adding policy variables...")

fars_analysis <- readRDS(file.path(dir_data, "fars_analysis.rds"))

# Create crash date
fars_analysis <- fars_analysis %>%
  mutate(
    crash_date = as.Date(paste(year, month, day, sep = "-")),
    crash_month = as.Date(paste(year, month, "01", sep = "-"))
  )

# Join marijuana policy
fars_analysis <- fars_analysis %>%
  left_join(
    marijuana_policy %>% select(state_fips, state_abbr, medical_date, rec_effective_date,
                                 retail_open_date, ever_rec_legal, early_adopter, policy_category),
    by = "state_fips"
  )

# Create time-varying policy exposure
fars_analysis <- fars_analysis %>%
  mutate(
    # Medical marijuana legal at time of crash
    medical_legal = !is.na(medical_date) & crash_date >= medical_date,
    # Recreational marijuana legal at time of crash
    rec_legal = !is.na(rec_effective_date) & crash_date >= rec_effective_date,
    # Retail sales open at time of crash
    retail_open = !is.na(retail_open_date) & crash_date >= retail_open_date,
    # Time since legalization (in months)
    months_since_rec = ifelse(rec_legal,
                               as.numeric(difftime(crash_date, rec_effective_date, units = "days")) / 30.44,
                               NA_real_),
    # Time relative to legalization (for event study)
    rel_time_rec = as.numeric(difftime(crash_date, rec_effective_date, units = "days")) / 30.44
  )

message("Policy variables added")

# =============================================================================
# 5. Compute Distance to State Borders
# =============================================================================

message("\nComputing distance to state borders...")

# Convert FARS to spatial
fars_sf <- fars_analysis %>%
  filter(!is.na(latitude) & !is.na(longitude)) %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326) %>%
  st_transform(crs = 5070)

# Get border geometries
border_list <- list()

for (i in 1:nrow(border_pairs)) {
  pair <- border_pairs[i, ]

  state1 <- states_sf %>% filter(state_abbr == pair$legal_state)
  state2 <- states_sf %>% filter(state_abbr == pair$illegal_state)

  if (nrow(state1) > 0 & nrow(state2) > 0) {
    border <- st_intersection(st_boundary(state1), st_boundary(state2))
    if (nrow(border) > 0) {
      border_list[[paste(pair$legal_state, pair$illegal_state, sep = "-")]] <-
        border %>%
        mutate(
          border_id = paste(pair$legal_state, pair$illegal_state, sep = "-"),
          legal_state = pair$legal_state,
          illegal_state = pair$illegal_state
        )
    }
  }
}

# Combine borders
if (length(border_list) > 0) {
  borders_sf <- bind_rows(border_list)
  saveRDS(borders_sf, file.path(dir_data, "borders_sf.rds"))
  message("  ", length(border_list), " borders identified")

  # Compute distance to nearest policy border for each crash
  message("  Computing distances (this may take a while)...")

  # For crashes in legal states, compute distance to nearest illegal state border
  # For crashes in illegal states, compute distance to nearest legal state border

  fars_sf <- fars_sf %>%
    mutate(row_id = row_number())

  # Split by state type
  legal_state_crashes <- fars_sf %>%
    filter(state_abbr %in% c("CO", "WA", "OR", "AK", "CA", "NV"))

  illegal_state_crashes <- fars_sf %>%
    filter(state_abbr %in% c("WY", "NE", "KS", "ID", "UT", "AZ", "NM", "MT"))

  # Function to compute distance to border
  compute_border_dist <- function(crashes, borders_subset) {
    if (nrow(crashes) == 0 | nrow(borders_subset) == 0) {
      return(crashes %>% mutate(dist_to_border_km = NA_real_))
    }

    # Compute nearest distance
    nearest <- st_nearest_feature(crashes, borders_subset)
    dist <- st_distance(crashes, borders_subset[nearest, ], by_element = TRUE)
    dist_km <- as.numeric(units::set_units(dist, "km"))

    crashes %>% mutate(dist_to_border_km = dist_km)
  }

  # Get relevant borders for each group
  legal_borders <- borders_sf %>%
    filter(legal_state %in% legal_state_crashes$state_abbr |
           illegal_state %in% legal_state_crashes$state_abbr)

  illegal_borders <- borders_sf %>%
    filter(legal_state %in% illegal_state_crashes$state_abbr |
           illegal_state %in% illegal_state_crashes$state_abbr)

  # Compute distances
  legal_with_dist <- compute_border_dist(legal_state_crashes, legal_borders) %>%
    mutate(dist_sign = -dist_to_border_km)  # Negative = legal side

  illegal_with_dist <- compute_border_dist(illegal_state_crashes, illegal_borders) %>%
    mutate(dist_sign = dist_to_border_km)  # Positive = illegal side

  # Combine
  fars_sf <- bind_rows(legal_with_dist, illegal_with_dist) %>%
    arrange(row_id)

  message("  Distances computed")
} else {
  fars_sf <- fars_sf %>%
    mutate(dist_to_border_km = NA_real_, dist_sign = NA_real_)
  message("  Warning: No borders could be computed")
}

# =============================================================================
# 6. Save Final Dataset
# =============================================================================

# Drop geometry for analysis file
fars_final <- fars_sf %>%
  st_drop_geometry() %>%
  as_tibble()

# Re-add coordinates
coords <- st_coordinates(fars_sf)
fars_final <- fars_final %>%
  mutate(
    x_albers = coords[, 1],
    y_albers = coords[, 2]
  )

# Save
saveRDS(fars_final, file.path(dir_data, "fars_analysis_policy.rds"))
fwrite(fars_final, file.path(dir_data, "fars_analysis_policy.csv"))

# Also save spatial version
saveRDS(fars_sf, file.path(dir_data, "fars_sf_policy.rds"))

message("\nFinal dataset saved with ", format(nrow(fars_final), big.mark = ","), " crashes")

# =============================================================================
# 7. Summary Statistics by Policy Status
# =============================================================================

message("\n", strrep("=", 60))
message("POLICY EXPOSURE SUMMARY")
message(strrep("=", 60))

# Crashes by policy status
message("\nCrashes by Recreational Marijuana Status:")
fars_final %>%
  filter(year >= 2012) %>%
  count(year, rec_legal) %>%
  pivot_wider(names_from = rec_legal, values_from = n, names_prefix = "rec_") %>%
  print(n = 15)

# THC positive rates by policy status
message("\nTHC Positive Rates by Policy Status (where tested):")
fars_final %>%
  filter(year >= 2012, !is.na(thc_positive)) %>%
  group_by(policy_category, rec_legal) %>%
  summarise(
    crashes = n(),
    thc_pos = sum(thc_positive),
    pct_thc = round(100 * thc_pos / crashes, 1),
    .groups = "drop"
  ) %>%
  arrange(policy_category, rec_legal) %>%
  print()

# Distance to border summary
message("\nDistance to Border (km) Summary:")
fars_final %>%
  filter(!is.na(dist_to_border_km), dist_to_border_km < 200) %>%
  group_by(rec_legal) %>%
  summarise(
    n = n(),
    mean_dist = round(mean(dist_to_border_km), 1),
    median_dist = round(median(dist_to_border_km), 1),
    min_dist = round(min(dist_to_border_km), 1),
    max_dist = round(max(dist_to_border_km), 1)
  ) %>%
  print()

message("\n", strrep("=", 60))
message("Policy merge complete!")
message(strrep("=", 60))
