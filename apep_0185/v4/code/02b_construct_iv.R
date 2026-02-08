################################################################################
# 02b_construct_iv.R
# Social Network Spillovers of Minimum Wage - IV Construction
#
# Input:  data/raw_*.rds files (from 01_fetch_data.R)
# Output: data/iv_panel.rds with distance-based instruments
#
# This script constructs instrumental variables for the network exposure measure
# using GEOGRAPHICALLY DISTANT social connections. The key insight is that
# connections to distant counties are less likely to be confounded by local
# economic shocks, improving the exclusion restriction.
#
# Instruments:
#   - iv_mw_distant_200_400: SCI-weighted MW using only 200-400km connections
#   - iv_mw_distant_400_600: SCI-weighted MW using only 400-600km connections
#   - iv_mw_distant_600_800: SCI-weighted MW using only 600-800km connections
################################################################################

source("00_packages.R")

cat("=== Constructing Distance-Based Instrumental Variables ===\n\n")

# ============================================================================
# 1. Load Data
# ============================================================================

cat("1. Loading raw data...\n")

sci_raw <- readRDS("../data/raw_sci.rds")
centroids <- readRDS("../data/raw_county_centroids.rds")
state_mw_panel <- readRDS("../data/state_mw_panel.rds")

cat("  SCI pairs:", format(nrow(sci_raw), big.mark = ","), "\n")
cat("  Counties:", nrow(centroids), "\n")

# ============================================================================
# 2. Compute Pairwise County Distances
# ============================================================================

cat("\n2. Computing pairwise county distances...\n")

# Haversine distance function (already defined in 02_clean_data.R but repeated here)
haversine <- function(lon1, lat1, lon2, lat2) {
  # Returns distance in km
  R <- 6371
  dLat <- (lat2 - lat1) * pi / 180
  dLon <- (lon2 - lon1) * pi / 180
  lat1_rad <- lat1 * pi / 180
  lat2_rad <- lat2 * pi / 180
  a <- sin(dLat/2)^2 + cos(lat1_rad) * cos(lat2_rad) * sin(dLon/2)^2
  c <- 2 * atan2(sqrt(a), sqrt(1-a))
  R * c
}

# Convert SCI to tibble and add state FIPS
sci <- as_tibble(sci_raw) %>%
  mutate(
    state_fips_1 = substr(county_fips_1, 1, 2),
    state_fips_2 = substr(county_fips_2, 1, 2)
  )

# Leave-own-state-out: Only keep cross-state connections
sci_cross_state <- sci %>%
  filter(state_fips_1 != state_fips_2)

cat("  Cross-state SCI pairs:", format(nrow(sci_cross_state), big.mark = ","), "\n")

# Merge with centroids to get coordinates
sci_with_coords <- sci_cross_state %>%
  left_join(centroids %>% select(fips, lon1 = lon, lat1 = lat),
            by = c("county_fips_1" = "fips")) %>%
  left_join(centroids %>% select(fips, lon2 = lon, lat2 = lat),
            by = c("county_fips_2" = "fips")) %>%
  filter(!is.na(lon1) & !is.na(lon2))

# Compute distances
cat("  Computing Haversine distances for", format(nrow(sci_with_coords), big.mark = ","), "pairs...\n")
sci_with_coords <- sci_with_coords %>%
  mutate(dist_km = haversine(lon1, lat1, lon2, lat2))

cat("  Distance range: [", round(min(sci_with_coords$dist_km), 0), ",",
    round(max(sci_with_coords$dist_km), 0), "] km\n")

# ============================================================================
# 3. Define Distance Windows for Instruments
# ============================================================================

cat("\n3. Defining distance windows for instruments...\n")

# Distance windows (in km)
windows <- list(
  "200_400" = c(200, 400),
  "400_600" = c(400, 600),
  "600_800" = c(600, 800)
)

# For each window, compute the proportion of SCI pairs included
for (name in names(windows)) {
  d_min <- windows[[name]][1]
  d_max <- windows[[name]][2]
  n_pairs <- sum(sci_with_coords$dist_km >= d_min & sci_with_coords$dist_km < d_max)
  pct <- round(100 * n_pairs / nrow(sci_with_coords), 1)
  cat("  Window", name, "km:", format(n_pairs, big.mark = ","), "pairs (", pct, "%)\n")
}

# ============================================================================
# 4. Construct Distance-Filtered SCI Weights
# ============================================================================

cat("\n4. Constructing distance-filtered SCI weights...\n")

# Function to compute normalized weights for a distance window
compute_distance_weights <- function(data, d_min, d_max) {
  # Filter to distance window
  filtered <- data %>%
    filter(dist_km >= d_min & dist_km < d_max)

  # Compute total SCI within window for each origin county
  totals <- filtered %>%
    group_by(county_fips_1) %>%
    summarise(total_sci_window = sum(sci, na.rm = TRUE), .groups = "drop")

  # Normalize weights to sum to 1 within window
  filtered %>%
    left_join(totals, by = "county_fips_1") %>%
    mutate(w_sci_dist = sci / total_sci_window) %>%
    select(county_fips_1, county_fips_2, state_fips_2, sci, w_sci_dist, dist_km)
}

# Compute weights for each window
weights_list <- list()
for (name in names(windows)) {
  d_min <- windows[[name]][1]
  d_max <- windows[[name]][2]
  weights_list[[name]] <- compute_distance_weights(sci_with_coords, d_min, d_max)
  cat("  Window", name, ": computed weights for",
      n_distinct(weights_list[[name]]$county_fips_1), "origin counties\n")
}

# ============================================================================
# 5. Compute Instrument Values for Each County-Quarter
# ============================================================================

cat("\n5. Computing instrument values...\n")

# Get unique quarters
time_periods <- state_mw_panel %>%
  select(year, quarter, yearq) %>%
  distinct()

# Function to compute IV exposure for a given window and time period
compute_iv_exposure <- function(weights_data, mw_panel, yr, qtr) {
  # Get minimum wages for this quarter
  mw_this_q <- mw_panel %>%
    filter(year == yr, quarter == qtr) %>%
    select(state_fips, log_min_wage)

  # Join with weights and compute weighted average
  exposure <- weights_data %>%
    left_join(mw_this_q, by = c("state_fips_2" = "state_fips")) %>%
    group_by(county_fips_1) %>%
    summarise(
      iv_exposure = sum(w_sci_dist * log_min_wage, na.rm = TRUE),
      n_connections = n(),
      mean_dist = mean(dist_km, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(year = yr, quarter = qtr)

  return(exposure)
}

# Compute IVs for all windows and quarters
iv_panels <- list()

for (window_name in names(windows)) {
  cat("  Processing window", window_name, "...\n")

  exposure_list <- list()
  for (i in 1:nrow(time_periods)) {
    yr <- time_periods$year[i]
    qtr <- time_periods$quarter[i]
    exposure_list[[i]] <- compute_iv_exposure(
      weights_list[[window_name]],
      state_mw_panel,
      yr,
      qtr
    )
  }

  iv_panels[[window_name]] <- bind_rows(exposure_list) %>%
    rename(!!paste0("iv_mw_", window_name) := iv_exposure,
           !!paste0("n_conn_", window_name) := n_connections,
           !!paste0("mean_dist_", window_name) := mean_dist)
}

# ============================================================================
# 6. Merge All IVs into Single Panel
# ============================================================================

cat("\n6. Merging IV panels...\n")

# Start with the first window
iv_panel <- iv_panels[[1]] %>%
  rename(county_fips = county_fips_1)

# Merge in other windows by selecting only the IV columns (not year/quarter duplicates)
for (window_name in names(windows)[-1]) {
  # Get the column names specific to this window
  iv_col <- paste0("iv_mw_", window_name)
  conn_col <- paste0("n_conn_", window_name)
  dist_col <- paste0("mean_dist_", window_name)

  iv_panel <- iv_panel %>%
    left_join(
      iv_panels[[window_name]] %>%
        rename(county_fips = county_fips_1) %>%
        select(county_fips, year, quarter, all_of(c(iv_col, conn_col, dist_col))),
      by = c("county_fips", "year", "quarter")
    )
}

# Add yearq
iv_panel <- iv_panel %>%
  mutate(yearq = year + (quarter - 1) / 4)

cat("  Final IV panel:", format(nrow(iv_panel), big.mark = ","), "county-quarter obs\n")
cat("  Columns:", paste(names(iv_panel), collapse = ", "), "\n")

# ============================================================================
# 7. Summary Statistics
# ============================================================================

cat("\n7. IV summary statistics...\n")

for (window_name in names(windows)) {
  iv_col <- paste0("iv_mw_", window_name)
  iv_vals <- iv_panel[[iv_col]]

  cat("\n  ", window_name, " km window:\n", sep = "")
  cat("    Mean:", round(mean(iv_vals, na.rm = TRUE), 4), "\n")
  cat("    SD:", round(sd(iv_vals, na.rm = TRUE), 4), "\n")
  cat("    Min:", round(min(iv_vals, na.rm = TRUE), 4), "\n")
  cat("    Max:", round(max(iv_vals, na.rm = TRUE), 4), "\n")
  cat("    Non-missing:", sum(!is.na(iv_vals)), "/", length(iv_vals), "\n")
}

# ============================================================================
# 8. Save IV Panel
# ============================================================================

cat("\n8. Saving IV panel...\n")

saveRDS(iv_panel, "../data/iv_panel.rds")

# Also save the distance-filtered weights for diagnostics
saveRDS(weights_list, "../data/iv_weights_by_window.rds")

cat("  Saved iv_panel.rds\n")
cat("  Saved iv_weights_by_window.rds\n")

# ============================================================================
# 9. Correlations Between IVs
# ============================================================================

cat("\n9. Correlations between instrument windows...\n")

iv_cors <- iv_panel %>%
  select(starts_with("iv_mw_")) %>%
  cor(use = "pairwise.complete.obs")

print(round(iv_cors, 3))

cat("\n=== IV Construction Complete ===\n")
