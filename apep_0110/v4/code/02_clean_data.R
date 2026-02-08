# =============================================================================
# 02_clean_data.R
# Clean and prepare data for Spatial RDD analysis
# Enhanced: Includes driver license state for residency analysis
# =============================================================================

source("00_packages.R")

# Load data
crashes_sf <- readRDS("../data/crashes_sf.rds")
states_sf <- readRDS("../data/states_sf.rds")
borders_sf <- readRDS("../data/borders_sf.rds")
dispensaries_sf <- readRDS("../data/dispensaries_sf.rds")

# Load driver license lookup (new)
driver_license_lookup <- tryCatch(
  readRDS("../data/driver_license_lookup.rds"),
  error = function(e) {
    cat("Warning: No driver license lookup found. Driver residency analysis will be limited.\n")
    data.frame()
  }
)

cat("Data loaded.\n")
cat(sprintf("  Crashes: %d\n", nrow(crashes_sf)))
cat(sprintf("  States: %d\n", nrow(states_sf)))
cat(sprintf("  Border segments: %d\n", nrow(borders_sf)))
cat(sprintf("  Dispensaries: %d\n", nrow(dispensaries_sf)))
if (nrow(driver_license_lookup) > 0) {
  cat(sprintf("  Driver license records: %d\n", nrow(driver_license_lookup)))
}

# =============================================================================
# PART 1: Compute Distance to Nearest Legal-Prohibition Border
# =============================================================================

cat("\nComputing distance to nearest border...\n")

# Combine all borders into single multilinestring
all_borders <- borders_sf %>%
  st_union() %>%
  st_sf()

# Function to compute signed distance to border
# Positive = prohibition state, Negative = legal state
compute_signed_distance <- function(point_sf, borders_sf, states_sf) {

  # Get unsigned distance to nearest border point
  dist_m <- st_distance(point_sf, all_borders) %>% as.numeric()
  dist_km <- dist_m / 1000

  # Determine sign based on legal status
  legal_status <- point_sf$legal_status

  # If in legal state, distance is negative (on treatment side)
  # If in prohibition state, distance is positive (on control side)
  signed_dist <- ifelse(legal_status == "Legal", -dist_km, dist_km)

  return(signed_dist)
}

# Compute for all crashes
crashes_sf$dist_to_border_km <- sapply(1:nrow(crashes_sf), function(i) {
  if (i %% 1000 == 0) cat(sprintf("  Processing crash %d/%d...\n", i, nrow(crashes_sf)))
  compute_signed_distance(crashes_sf[i, ], all_borders, states_sf)
})

cat("Distance computation complete.\n")

# =============================================================================
# PART 2: Compute Distance to Nearest Dispensary
# =============================================================================

cat("\nComputing distance to nearest dispensary...\n")

# For each crash, find distance to nearest dispensary
crashes_sf$dist_to_dispensary_km <- st_distance(
  crashes_sf,
  dispensaries_sf %>% st_union()
) %>%
  as.numeric() / 1000

# =============================================================================
# PART 3: Create Analysis Variables
# =============================================================================

cat("\nCreating analysis variables...\n")

crashes_df <- crashes_sf %>%
  st_drop_geometry() %>%
  mutate(
    # Running variable for RDD (distance to border)
    running_var = dist_to_border_km,

    # Treatment indicator (in legal state = on treatment side of cutoff)
    treated = as.integer(legal_status == "Legal"),

    # Outcome: alcohol involved
    alcohol_involved = as.integer(drunk_dr >= 1),

    # Time of day categories (hour may be in different column names)
    hour_val = ifelse("hour" %in% names(.), hour, NA),
    time_of_day = case_when(
      hour_val >= 21 | hour_val <= 5 ~ "Night (9pm-5am)",
      hour_val >= 6 & hour_val <= 11 ~ "Morning (6am-12pm)",
      hour_val >= 12 & hour_val <= 17 ~ "Afternoon (12pm-6pm)",
      hour_val >= 18 & hour_val <= 20 ~ "Evening (6pm-9pm)",
      TRUE ~ "Unknown"
    ),
    is_nighttime = as.integer(hour_val >= 21 | hour_val <= 5),

    # Year factors
    year_factor = factor(year)
  )

# =============================================================================
# PART 3b: Merge Driver License State Information
# =============================================================================

cat("\nMerging driver license state information...\n")

# Define legal/prohibition FIPS codes
legal_fips <- c(6, 8, 32, 41, 53)  # CA, CO, NV, OR, WA
prohibition_fips <- c(4, 16, 20, 30, 31, 35, 49, 56)  # AZ, ID, KS, MT, NE, NM, UT, WY

if (nrow(driver_license_lookup) > 0) {
  # Ensure matching columns exist (state and st_case)
  if ("st_case" %in% names(crashes_df) && "state" %in% names(crashes_df)) {
    crashes_df <- crashes_df %>%
      left_join(
        driver_license_lookup %>%
          select(state, st_case, year, driver_license_state,
                 any_legal_state_driver, any_prohib_state_driver,
                 mean_driver_age),
        by = c("state", "st_case", "year")
      ) %>%
      mutate(
        # Driver residency classification
        driver_from_legal_state = as.integer(driver_license_state %in% legal_fips),
        driver_from_prohib_state = as.integer(driver_license_state %in% prohibition_fips),

        # In-state driver flag (driver license matches crash state)
        is_instate_driver = as.integer(driver_license_state == state),

        # Cross-border driver flags
        is_crossborder_driver = as.integer(driver_license_state != state),

        # Key analysis variable: Driver lives in legal state (regardless of crash location)
        driver_legal_status = case_when(
          driver_license_state %in% legal_fips ~ "Legal",
          driver_license_state %in% prohibition_fips ~ "Prohibition",
          TRUE ~ NA_character_
        ),

        # Treated based on driver residence (not crash location)
        treated_by_residence = as.integer(driver_from_legal_state == 1)
      )

    cat(sprintf("  Matched driver license data for %d crashes.\n",
                sum(!is.na(crashes_df$driver_license_state))))
    cat(sprintf("  In-state drivers: %d (%.1f%%)\n",
                sum(crashes_df$is_instate_driver == 1, na.rm = TRUE),
                100 * mean(crashes_df$is_instate_driver == 1, na.rm = TRUE)))
    cat(sprintf("  Cross-border drivers: %d (%.1f%%)\n",
                sum(crashes_df$is_crossborder_driver == 1, na.rm = TRUE),
                100 * mean(crashes_df$is_crossborder_driver == 1, na.rm = TRUE)))
  } else {
    cat("  Warning: Cannot match - missing st_case or state columns.\n")
    crashes_df$driver_license_state <- NA
    crashes_df$driver_from_legal_state <- NA
    crashes_df$driver_from_prohib_state <- NA
    crashes_df$is_instate_driver <- NA
    crashes_df$is_crossborder_driver <- NA
    crashes_df$driver_legal_status <- NA
    crashes_df$treated_by_residence <- NA
  }
} else {
  cat("  No driver license data available.\n")
  crashes_df$driver_license_state <- NA
  crashes_df$driver_from_legal_state <- NA
  crashes_df$driver_from_prohib_state <- NA
  crashes_df$is_instate_driver <- NA
  crashes_df$is_crossborder_driver <- NA
  crashes_df$driver_legal_status <- NA
  crashes_df$treated_by_residence <- NA
  crashes_df$mean_driver_age <- NA
}

# Age groups (from merged driver data)
if ("mean_driver_age" %in% names(crashes_df) && any(!is.na(crashes_df$mean_driver_age))) {
  crashes_df <- crashes_df %>%
    mutate(
      age_group = case_when(
        mean_driver_age >= 16 & mean_driver_age < 25 ~ "Young (16-24)",
        mean_driver_age >= 25 & mean_driver_age < 45 ~ "Adult (25-44)",
        mean_driver_age >= 45 & mean_driver_age < 65 ~ "Middle (45-64)",
        mean_driver_age >= 65 ~ "Senior (65+)",
        TRUE ~ NA_character_
      ),
      is_young_adult = as.integer(mean_driver_age >= 16 & mean_driver_age < 25),
      is_elderly = as.integer(mean_driver_age >= 65)
    )
} else {
  crashes_df$age_group <- NA_character_
  crashes_df$is_young_adult <- NA_integer_
  crashes_df$is_elderly <- NA_integer_
}

# Weekend indicator (if day_week available)
if ("day_week" %in% names(crashes_df)) {
  # FARS codes: 1=Sunday, 2=Monday, ..., 7=Saturday
  crashes_df$is_weekend <- as.integer(crashes_df$day_week %in% c(1, 7))
} else if ("dayweek" %in% names(crashes_df)) {
  crashes_df$is_weekend <- as.integer(crashes_df$dayweek %in% c(1, 7))
} else {
  crashes_df$is_weekend <- NA
}

# =============================================================================
# PART 4: Sample Restrictions
# =============================================================================

cat("\nApplying sample restrictions...\n")

# Restrict to crashes within 150km of border (relevant for RDD)
crashes_analysis <- crashes_df %>%
  filter(abs(running_var) <= 150) %>%
  filter(!is.na(alcohol_involved)) %>%
  filter(!is.na(running_var))

cat(sprintf("Analysis sample: %d crashes within 150km of border.\n", nrow(crashes_analysis)))

# =============================================================================
# PART 5: Create Binned Data for Visualization
# =============================================================================

cat("\nCreating binned data for visualization...\n")

# Create bins of ~5km width
crashes_analysis <- crashes_analysis %>%
  mutate(
    dist_bin = cut(running_var, breaks = seq(-150, 150, by = 5), include.lowest = TRUE)
  )

# Compute bin means
bin_means <- crashes_analysis %>%
  group_by(dist_bin) %>%
  summarise(
    n_crashes = n(),
    alcohol_rate = mean(alcohol_involved),
    alcohol_se = sd(alcohol_involved) / sqrt(n()),
    mean_dist = mean(running_var),
    .groups = "drop"
  ) %>%
  filter(n_crashes >= 10)  # Only bins with sufficient observations

# =============================================================================
# PART 6: Summary Statistics
# =============================================================================

cat("\n=== Analysis Sample Summary ===\n")
cat(sprintf("Total crashes: %d\n", nrow(crashes_analysis)))
cat(sprintf("  Legal state (crash location): %d (%.1f%%)\n",
            sum(crashes_analysis$treated),
            100 * mean(crashes_analysis$treated)))
cat(sprintf("  Prohibition state (crash location): %d (%.1f%%)\n",
            sum(1 - crashes_analysis$treated),
            100 * mean(1 - crashes_analysis$treated)))

cat(sprintf("\nAlcohol involvement rate:\n"))
cat(sprintf("  Overall: %.1f%%\n", 100 * mean(crashes_analysis$alcohol_involved)))
cat(sprintf("  Legal state crash: %.1f%%\n",
            100 * mean(crashes_analysis$alcohol_involved[crashes_analysis$treated == 1])))
cat(sprintf("  Prohibition state crash: %.1f%%\n",
            100 * mean(crashes_analysis$alcohol_involved[crashes_analysis$treated == 0])))

cat(sprintf("\nDistance to border (km):\n"))
cat(sprintf("  Mean: %.1f\n", mean(crashes_analysis$running_var)))
cat(sprintf("  Median: %.1f\n", median(crashes_analysis$running_var)))
cat(sprintf("  SD: %.1f\n", sd(crashes_analysis$running_var)))

# NEW: Driver residency statistics
if (any(!is.na(crashes_analysis$driver_license_state))) {
  cat("\n=== Driver Residency Analysis ===\n")

  n_with_license <- sum(!is.na(crashes_analysis$driver_license_state))
  cat(sprintf("Crashes with driver license data: %d (%.1f%%)\n",
              n_with_license, 100 * n_with_license / nrow(crashes_analysis)))

  # In-state vs cross-border
  n_instate <- sum(crashes_analysis$is_instate_driver == 1, na.rm = TRUE)
  n_crossborder <- sum(crashes_analysis$is_crossborder_driver == 1, na.rm = TRUE)
  cat(sprintf("  In-state drivers: %d (%.1f%%)\n", n_instate, 100 * n_instate / n_with_license))
  cat(sprintf("  Cross-border drivers: %d (%.1f%%)\n", n_crossborder, 100 * n_crossborder / n_with_license))

  # Treatment by driver residence vs crash location
  if (any(!is.na(crashes_analysis$treated_by_residence))) {
    cat("\nTreatment comparison:\n")
    cat(sprintf("  Treated by crash location: %d (%.1f%%)\n",
                sum(crashes_analysis$treated == 1, na.rm = TRUE),
                100 * mean(crashes_analysis$treated == 1, na.rm = TRUE)))
    cat(sprintf("  Treated by driver residence: %d (%.1f%%)\n",
                sum(crashes_analysis$treated_by_residence == 1, na.rm = TRUE),
                100 * mean(crashes_analysis$treated_by_residence == 1, na.rm = TRUE)))

    # Discordant cases (crash location != driver residence)
    discordant <- crashes_analysis %>%
      filter(!is.na(treated_by_residence)) %>%
      filter(treated != treated_by_residence)
    cat(sprintf("  Discordant cases (location != residence): %d (%.1f%%)\n",
                nrow(discordant),
                100 * nrow(discordant) / sum(!is.na(crashes_analysis$treated_by_residence))))
  }

  # Alcohol involvement by driver residence
  cat("\nAlcohol involvement by driver residence:\n")
  alc_by_res <- crashes_analysis %>%
    filter(!is.na(driver_legal_status)) %>%
    group_by(driver_legal_status) %>%
    summarise(
      n = n(),
      alcohol_rate = mean(alcohol_involved),
      .groups = "drop"
    )
  for (i in 1:nrow(alc_by_res)) {
    cat(sprintf("  %s state driver: %.1f%% (n=%d)\n",
                alc_by_res$driver_legal_status[i],
                100 * alc_by_res$alcohol_rate[i],
                alc_by_res$n[i]))
  }
}

# =============================================================================
# Save cleaned data
# =============================================================================

saveRDS(crashes_analysis, "../data/crashes_analysis.rds")
saveRDS(bin_means, "../data/bin_means.rds")

cat("\nData cleaning complete. Saved to ../data/\n")
