# =============================================================================
# 02_clean_data.R - Data Cleaning and Preparation
# Swiss Cantonal Energy Laws and Federal Referendum Voting
# =============================================================================

# Get script directory for portable sourcing
get_this_script_dir <- function() {
  for (i in seq_len(sys.nframe())) {
    if (!is.null(sys.frame(i)$ofile)) {
      return(dirname(sys.frame(i)$ofile))
    }
  }
  return(getwd())
}
script_dir <- get_this_script_dir()
source(file.path(script_dir, "00_packages.R"))

# -----------------------------------------------------------------------------
# 1. Load Raw Data
# -----------------------------------------------------------------------------

# voting_data.rds contains the merged voting + treatment data from 01_fetch_data.R
# voting_sf.rds contains the spatial version with geometry
votes_2017 <- readRDS(file.path(data_dir, "voting_data.rds"))
gemeinde_sf <- readRDS(file.path(data_dir, "gemeinde_boundaries.rds"))
canton_treatment <- readRDS(file.path(data_dir, "canton_treatment.rds"))

# Standardize gemeinde_sf column names
if ("kantonsnummer" %in% names(gemeinde_sf)) {
  gemeinde_sf <- gemeinde_sf %>% rename(KTNR = kantonsnummer)
}
if ("bfs_nummer" %in% names(gemeinde_sf)) {
  gemeinde_sf <- gemeinde_sf %>% rename(mun_id = bfs_nummer)
}

# Try to load canton boundaries - may need to aggregate from gemeinde
kanton_sf <- tryCatch({
  readRDS(file.path(data_dir, "canton_boundaries.rds"))
}, error = function(e) {
  message("Canton boundaries not found, aggregating from gemeinde...")
  if ("KTNR" %in% names(gemeinde_sf)) {
    # sf::summarise automatically handles geometry column
    gemeinde_sf %>%
      group_by(KTNR) %>%
      summarise(.groups = "drop")
  } else {
    stop("Cannot create canton boundaries - no KTNR column in gemeinde_sf")
  }
})

# -----------------------------------------------------------------------------
# 2. Clean Voting Data
# -----------------------------------------------------------------------------

message("Cleaning voting data...")

# voting_data.rds from 01_fetch_data.R already has:
# mun_id, mun_name, canton_id, canton_name, yes_share, yes_votes, no_votes,
# turnout, eligible_voters, votedate, vote_type, canton_abbr, treated, lang, adoption_year
# Filter to energy_2017 vote type
energy_vote_clean <- votes_2017 %>%
  filter(vote_type == "energy_2017")

message(paste("Energy vote observations:", nrow(energy_vote_clean)))
message(paste("Treated municipalities:", sum(energy_vote_clean$treated, na.rm = TRUE)))
message(paste("Control municipalities:", sum(!energy_vote_clean$treated, na.rm = TRUE)))

# Summary stats
message("\nYes share by treatment status:")
tryCatch({
  energy_vote_clean %>%
    group_by(treated) %>%
    summarise(
      n = n(),
      mean_yes = mean(yes_share, na.rm = TRUE),
      sd_yes = sd(yes_share, na.rm = TRUE),
      mean_turnout = mean(turnout, na.rm = TRUE)
    ) %>%
    print()
}, error = function(e) {
  message(paste("Summary error:", e$message))
})

# -----------------------------------------------------------------------------
# 3. Prepare Spatial Data
# -----------------------------------------------------------------------------

message("\nPreparing spatial data...")

# Ensure gemeinde has canton info
# The BFS data should have KTNR (canton number)

# Create canton lookup
canton_lookup <- tibble(
  KTNR = 1:26,
  canton_abbr = c("ZH", "BE", "LU", "UR", "SZ", "OW", "NW", "GL", "ZG", "FR",
                  "SO", "BS", "BL", "SH", "AR", "AI", "SG", "GR", "AG", "TG",
                  "TI", "VD", "VS", "NE", "GE", "JU")
)

# Add canton abbreviation to gemeinde sf if not present
if (!"canton_abbr" %in% names(gemeinde_sf)) {
  if ("KTNR" %in% names(gemeinde_sf)) {
    gemeinde_sf <- gemeinde_sf %>%
      left_join(canton_lookup, by = "KTNR")
  } else if ("KANTONSNUM" %in% names(gemeinde_sf)) {
    gemeinde_sf <- gemeinde_sf %>%
      rename(KTNR = KANTONSNUM) %>%
      left_join(canton_lookup, by = "KTNR")
  }
}

# Compute municipality centroids
gemeinde_centroids <- gemeinde_sf %>%
  st_centroid() %>%
  st_coordinates() %>%
  as_tibble() %>%
  rename(centroid_x = X, centroid_y = Y)

gemeinde_sf <- gemeinde_sf %>%
  bind_cols(gemeinde_centroids)

# -----------------------------------------------------------------------------
# 4. Identify Canton Borders
# -----------------------------------------------------------------------------

message("Identifying canton borders...")

# Get canton boundary lines (internal borders only)
# This is done by finding shared edges between canton polygons

kanton_borders <- kanton_sf %>%
  st_cast("MULTILINESTRING") %>%
  st_cast("LINESTRING")

# Alternative: compute canton boundary as union of external edges
# For spatial RDD, we need the actual shared border lines

# For each treated canton, identify borders with control cantons
treated_abbrs <- canton_treatment %>%
  filter(treated == TRUE) %>%
  pull(canton_abbr)

control_abbrs <- canton_treatment %>%
  filter(treated == FALSE) %>%
  pull(canton_abbr)

# -----------------------------------------------------------------------------
# 5. Compute Distance to Nearest Treated Border
# -----------------------------------------------------------------------------

message("Computing distance to treated canton borders...")

# For each municipality, compute:
# 1. Which canton it's in
# 2. If in control: distance to nearest treated canton border (negative)
# 3. If in treated: distance to nearest control canton border (positive)

# CRITICAL FIX: Use get_policy_border() to compute ONLY internal canton borders
# The original code used st_boundary() which includes national borders with
# France, Italy, and Germany - invalidating the spatial RDD.

# Prepare canton data with treatment status
kanton_with_treatment <- kanton_sf %>%
  left_join(canton_lookup, by = "KTNR") %>%
  left_join(canton_treatment, by = "canton_abbr") %>%
  mutate(
    canton_id = KTNR,
    treated = coalesce(treated, FALSE)
  )

# Get treated canton IDs
treated_ids <- kanton_with_treatment %>%
  filter(treated == TRUE) %>%
  pull(canton_id)

message(paste("Treated canton IDs:", paste(treated_ids, collapse = ", ")))

# Compute the CORRECT policy border (only internal canton-to-canton boundaries)
treatment_boundary <- get_policy_border(
  kanton_with_treatment,
  treated_ids,
  canton_id_col = "canton_id"
)

message(paste("Policy border geometry type:", st_geometry_type(treatment_boundary)))

# Compute distance from each gemeinde centroid to treatment boundary
gemeinde_sf <- gemeinde_sf %>%
  mutate(
    centroid_geom = st_sfc(
      map2(centroid_x, centroid_y, ~st_point(c(.x, .y))),
      crs = st_crs(gemeinde_sf)
    )
  )

distances <- st_distance(
  st_as_sf(gemeinde_sf, coords = c("centroid_x", "centroid_y"), crs = st_crs(gemeinde_sf)),
  treatment_boundary
)

gemeinde_sf$dist_to_border <- as.numeric(distances)

# Sign the distance: positive for treated, negative for control
gemeinde_sf <- gemeinde_sf %>%
  left_join(canton_treatment, by = "canton_abbr") %>%
  mutate(
    signed_distance = if_else(treated, dist_to_border, -dist_to_border)
  )

# Convert to km
gemeinde_sf$signed_distance_km <- gemeinde_sf$signed_distance / 1000

message(paste("Distance range:",
              round(min(gemeinde_sf$signed_distance_km, na.rm = TRUE), 1), "to",
              round(max(gemeinde_sf$signed_distance_km, na.rm = TRUE), 1), "km"))

# -----------------------------------------------------------------------------
# 6. Merge Voting and Spatial Data
# -----------------------------------------------------------------------------

message("Merging voting and spatial data...")

# Need to match on municipality ID
# swissdd uses BFS municipality numbers

# mun_id already standardized at the top of this script

# Merge
analysis_data <- energy_vote_clean %>%
  left_join(
    gemeinde_sf %>%
      st_drop_geometry() %>%
      select(mun_id, centroid_x, centroid_y, dist_to_border, signed_distance_km),
    by = "mun_id"
  )

# Check merge success
message(paste("Merged observations:", nrow(analysis_data)))
message(paste("With distance data:", sum(!is.na(analysis_data$signed_distance_km))))

# -----------------------------------------------------------------------------
# 7. Identify Border Pairs
# -----------------------------------------------------------------------------

message("Identifying border pairs for heterogeneity analysis...")

# For each border-adjacent municipality, identify which border pair it belongs to
# This requires checking which canton borders are within a certain distance

# Simplified: assign based on nearest border canton
# More precise would trace actual border segments

# For now, we'll use canton pair as the border segment identifier
# Municipalities near AG-ZH border vs BE-JU border, etc.

# This will be refined in the analysis script

# -----------------------------------------------------------------------------
# 8. Create Final Analysis Dataset
# -----------------------------------------------------------------------------

analysis_df <- analysis_data %>%
  filter(!is.na(signed_distance_km)) %>%
  filter(!is.na(yes_share)) %>%
  mutate(
    # Indicator for "near border" (within 30km)
    near_border = abs(signed_distance_km) < 30,
    # Treatment indicator at cutoff
    treat = signed_distance_km >= 0
  )

message(paste("\nFinal analysis sample:", nrow(analysis_df)))
message(paste("Near border (30km):", sum(analysis_df$near_border)))

# Summary by treatment
analysis_df %>%
  filter(near_border) %>%
  group_by(treat) %>%
  summarise(
    n = n(),
    mean_yes = mean(yes_share),
    mean_dist = mean(abs(signed_distance_km))
  ) %>%
  print()

# Save
saveRDS(analysis_df, file.path(data_dir, "analysis_data.rds"))
saveRDS(gemeinde_sf, file.path(data_dir, "gemeinde_spatial.rds"))

message("\n=== DATA CLEANING COMPLETE ===")
message(paste("Analysis dataset saved:", file.path(data_dir, "analysis_data.rds")))
