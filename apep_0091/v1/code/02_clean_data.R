# =============================================================================
# 02_clean_data.R
# Clean and prepare data for Spatial RDD analysis
# =============================================================================

source("00_packages.R")

# Load data
crashes_sf <- readRDS("../data/crashes_sf.rds")
states_sf <- readRDS("../data/states_sf.rds")
borders_sf <- readRDS("../data/borders_sf.rds")
dispensaries_sf <- readRDS("../data/dispensaries_sf.rds")

cat("Data loaded.\n")
cat(sprintf("  Crashes: %d\n", nrow(crashes_sf)))
cat(sprintf("  States: %d\n", nrow(states_sf)))
cat(sprintf("  Border segments: %d\n", nrow(borders_sf)))
cat(sprintf("  Dispensaries: %d\n", nrow(dispensaries_sf)))

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

# Note: Driver age requires person-level FARS data (separate file)
# For now, we analyze without age heterogeneity
crashes_df$age_group <- NA
crashes_df$is_young_adult <- NA
crashes_df$is_elderly <- NA
crashes_df$is_weekend <- NA

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
cat(sprintf("  Legal state: %d (%.1f%%)\n",
            sum(crashes_analysis$treated),
            100 * mean(crashes_analysis$treated)))
cat(sprintf("  Prohibition state: %d (%.1f%%)\n",
            sum(1 - crashes_analysis$treated),
            100 * mean(1 - crashes_analysis$treated)))
cat(sprintf("\nAlcohol involvement rate:\n"))
cat(sprintf("  Overall: %.1f%%\n", 100 * mean(crashes_analysis$alcohol_involved)))
cat(sprintf("  Legal state: %.1f%%\n",
            100 * mean(crashes_analysis$alcohol_involved[crashes_analysis$treated == 1])))
cat(sprintf("  Prohibition state: %.1f%%\n",
            100 * mean(crashes_analysis$alcohol_involved[crashes_analysis$treated == 0])))

cat(sprintf("\nDistance to border (km):\n"))
cat(sprintf("  Mean: %.1f\n", mean(crashes_analysis$running_var)))
cat(sprintf("  Median: %.1f\n", median(crashes_analysis$running_var)))
cat(sprintf("  SD: %.1f\n", sd(crashes_analysis$running_var)))

# =============================================================================
# Save cleaned data
# =============================================================================

saveRDS(crashes_analysis, "../data/crashes_analysis.rds")
saveRDS(bin_means, "../data/bin_means.rds")

cat("\nData cleaning complete. Saved to ../data/\n")
