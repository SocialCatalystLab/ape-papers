################################################################################
# 02_clean_data.R
# Social Network Minimum Wage Exposure - REVISED IDENTIFICATION
#
# Input:  data/raw_*.rds files
# Output: data/analysis_panel.rds with:
#         - network_mw_full: SCI-weighted MW excluding only own-county (ENDOGENOUS)
#         - network_mw_out_state: SCI-weighted MW excluding own-state (IV)
#         - Various distance-thresholded out-of-state IVs
#
# KEY CHANGE FROM PARENT PAPER:
# The parent paper used leave-own-state-out as the endogenous variable and
# distance-filtered versions as IVs. This created a weak instrument problem
# when combined with state×time FE.
#
# NEW APPROACH:
# - Endogenous: "Full network MW" = leave-own-county-out (includes same-state)
# - IV: "Out-of-state network MW" = leave-own-state-out
# - The idea: out-of-state policies don't directly affect local employment
################################################################################

source("00_packages.R")

cat("=== Constructing Analysis Panel with Revised Network Exposure ===\n\n")

# ============================================================================
# 1. Load Raw Data
# ============================================================================

cat("1. Loading raw data...\n")

sci_raw <- readRDS("../data/raw_sci.rds")
centroids <- readRDS("../data/raw_county_centroids.rds")
state_mw <- readRDS("../data/raw_state_min_wages.rds")
all_states <- readRDS("../data/raw_all_states.rds")

if (file.exists("../data/raw_qwi.rds")) {
  qwi_raw <- readRDS("../data/raw_qwi.rds")
} else {
  cat("  WARNING: QWI data not found. Will create simpler panel.\n")
  qwi_raw <- NULL
}

cat("  SCI pairs:", format(nrow(sci_raw), big.mark = ","), "\n")
cat("  Counties:", nrow(centroids), "\n")
cat("  MW changes:", nrow(state_mw), "\n")

# ============================================================================
# 2. Create State-Quarter Minimum Wage Panel
# ============================================================================

cat("\n2. Creating state-quarter minimum wage panel...\n")

# Federal minimum wage as floor
federal_mw <- 7.25

# Create quarterly time series 2010Q1 - 2023Q4
quarters <- expand_grid(
  year = 2010:2023,
  quarter = 1:4
) %>%
  mutate(
    yearq = year + (quarter - 1) / 4,
    date_start = ymd(paste(year, (quarter - 1) * 3 + 1, "01", sep = "-")),
    date_end = date_start + months(3) - days(1)
  )

# For each state, get the applicable minimum wage at each quarter
state_mw_panel <- expand_grid(
  state_fips = unique(centroids$state_fips),
  quarters
)

# Function to get minimum wage for a state at a given date
get_min_wage <- function(st_fips, dt) {
  applicable <- state_mw %>%
    filter(state_fips == st_fips, date <= dt) %>%
    arrange(desc(date))

  if (nrow(applicable) > 0) {
    return(applicable$min_wage[1])
  } else {
    return(federal_mw)
  }
}

cat("  Computing state minimum wages for each quarter...\n")
state_mw_panel <- state_mw_panel %>%
  rowwise() %>%
  mutate(min_wage = get_min_wage(state_fips, date_end)) %>%
  ungroup()

state_mw_panel <- state_mw_panel %>%
  mutate(log_min_wage = log(min_wage))

cat("  Created panel with", nrow(state_mw_panel), "state-quarter obs\n")

# ============================================================================
# 3. Construct TWO Sets of SCI Weights
# ============================================================================

cat("\n3. Constructing normalized SCI weights for TWO exposure types...\n")

# Add state FIPS to SCI data
sci <- as_tibble(sci_raw) %>%
  mutate(
    state_fips_1 = substr(county_fips_1, 1, 2),
    state_fips_2 = substr(county_fips_2, 1, 2)
  )

# ----------------------------------------------------------------------------
# 3A. FULL NETWORK WEIGHTS (leave-own-county-out, include same-state)
# This is the ENDOGENOUS VARIABLE
# ----------------------------------------------------------------------------

cat("  3A. Full network weights (leave-own-county-out)...\n")

# Exclude only self-connections (same county)
sci_full_network <- sci %>%
  filter(county_fips_1 != county_fips_2)

cat("      Full network pairs:", format(nrow(sci_full_network), big.mark = ","), "\n")

# Normalize: sum of weights for each origin county = 1
sci_full_totals <- sci_full_network %>%
  group_by(county_fips_1) %>%
  summarise(total_sci_full = sum(sci, na.rm = TRUE), .groups = "drop")

sci_full_normalized <- sci_full_network %>%
  left_join(sci_full_totals, by = "county_fips_1") %>%
  mutate(w_sci_full = sci / total_sci_full) %>%
  select(county_fips_1, county_fips_2, state_fips_2, sci, w_sci_full)

# ----------------------------------------------------------------------------
# 3B. OUT-OF-STATE WEIGHTS (leave-own-state-out)
# This is the INSTRUMENTAL VARIABLE
# ----------------------------------------------------------------------------

cat("  3B. Out-of-state weights (leave-own-state-out)...\n")

# Exclude same-state connections
sci_cross_state <- sci %>%
  filter(state_fips_1 != state_fips_2)

cat("      Cross-state pairs:", format(nrow(sci_cross_state), big.mark = ","), "\n")

# Normalize
sci_cross_totals <- sci_cross_state %>%
  group_by(county_fips_1) %>%
  summarise(total_sci_cross = sum(sci, na.rm = TRUE), .groups = "drop")

sci_cross_normalized <- sci_cross_state %>%
  left_join(sci_cross_totals, by = "county_fips_1") %>%
  mutate(w_sci_cross = sci / total_sci_cross) %>%
  select(county_fips_1, county_fips_2, state_fips_2, sci, w_sci_cross)

# ============================================================================
# 4. Compute Inter-County Distances (for distance-thresholded IVs)
# ============================================================================

cat("\n4. Computing inter-county distances...\n")

haversine <- function(lon1, lat1, lon2, lat2) {
  R <- 6371
  dLat <- (lat2 - lat1) * pi / 180
  dLon <- (lon2 - lon1) * pi / 180
  lat1_rad <- lat1 * pi / 180
  lat2_rad <- lat2 * pi / 180
  a <- sin(dLat/2)^2 + cos(lat1_rad) * cos(lat2_rad) * sin(dLon/2)^2
  c <- 2 * atan2(sqrt(a), sqrt(1-a))
  R * c
}

# Add coordinates to cross-state weights (for distance filtering)
sci_cross_with_coords <- sci_cross_normalized %>%
  left_join(centroids %>% select(fips, lon1 = lon, lat1 = lat),
            by = c("county_fips_1" = "fips")) %>%
  left_join(centroids %>% select(fips, lon2 = lon, lat2 = lat),
            by = c("county_fips_2" = "fips")) %>%
  filter(!is.na(lon1) & !is.na(lon2)) %>%
  mutate(dist_km = haversine(lon1, lat1, lon2, lat2))

cat("  Distance range: [", round(min(sci_cross_with_coords$dist_km), 0), ",",
    round(max(sci_cross_with_coords$dist_km), 0), "] km\n")

# Also add coordinates to full network for geographic exposure benchmark
sci_full_with_coords <- sci_full_normalized %>%
  left_join(centroids %>% select(fips, lon1 = lon, lat1 = lat),
            by = c("county_fips_1" = "fips")) %>%
  left_join(centroids %>% select(fips, lon2 = lon, lat2 = lat),
            by = c("county_fips_2" = "fips")) %>%
  filter(!is.na(lon1) & !is.na(lon2)) %>%
  mutate(
    dist_km = haversine(lon1, lat1, lon2, lat2),
    inv_dist = 1 / pmax(dist_km, 1)
  )

# Normalize geographic weights for benchmark
geo_totals <- sci_full_with_coords %>%
  group_by(county_fips_1) %>%
  summarise(total_inv_dist = sum(inv_dist, na.rm = TRUE), .groups = "drop")

sci_full_with_coords <- sci_full_with_coords %>%
  left_join(geo_totals, by = "county_fips_1") %>%
  mutate(w_geo = inv_dist / total_inv_dist)

# ============================================================================
# 5. Compute Exposure Measures for Each County-Quarter
# ============================================================================

cat("\n5. Computing exposure measures...\n")

time_periods <- state_mw_panel %>%
  filter(year >= 2012, year <= 2022) %>%  # Match QWI availability
  select(year, quarter, yearq) %>%
  distinct()

# Get county-level state minimum wages (for same-state contribution to full network)
county_state_map <- centroids %>%
  select(county_fips = fips, state_fips)

# Function to compute both exposure types for a time period
compute_all_exposures <- function(yr, qtr) {

  # Get minimum wages for this quarter
  mw_this_q <- state_mw_panel %>%
    filter(year == yr, quarter == qtr) %>%
    select(state_fips, log_min_wage, min_wage)

  # FULL NETWORK EXPOSURE (endogenous variable)
  # For each county c, weighted average of MW in all other counties (including same-state)
  full_exp <- sci_full_with_coords %>%
    left_join(mw_this_q, by = c("state_fips_2" = "state_fips")) %>%
    group_by(county_fips_1) %>%
    summarise(
      network_mw_full = sum(w_sci_full * log_min_wage, na.rm = TRUE),
      network_mw_full_dollar = sum(w_sci_full * min_wage, na.rm = TRUE),
      geo_exposure = sum(w_geo * log_min_wage, na.rm = TRUE),
      .groups = "drop"
    )

  # OUT-OF-STATE EXPOSURE (IV)
  # For each county c, weighted average of MW in other states
  cross_exp <- sci_cross_with_coords %>%
    left_join(mw_this_q, by = c("state_fips_2" = "state_fips")) %>%
    group_by(county_fips_1) %>%
    summarise(
      network_mw_out_state = sum(w_sci_cross * log_min_wage, na.rm = TRUE),
      network_mw_out_state_dollar = sum(w_sci_cross * min_wage, na.rm = TRUE),
      .groups = "drop"
    )

  # Merge
  exposure <- full_exp %>%
    left_join(cross_exp, by = "county_fips_1") %>%
    mutate(year = yr, quarter = qtr)

  return(exposure)
}

cat("  Computing exposures for", nrow(time_periods), "quarters...\n")
exposure_list <- list()

for (i in 1:nrow(time_periods)) {
  if (i %% 10 == 0) cat("  Quarter", i, "/", nrow(time_periods), "\n")
  exposure_list[[i]] <- compute_all_exposures(time_periods$year[i], time_periods$quarter[i])
}

exposure_panel <- bind_rows(exposure_list)
cat("  Created exposure panel with", format(nrow(exposure_panel), big.mark = ","), "county-quarter obs\n")

# ============================================================================
# 6. Construct Distance-Thresholded IVs (for robustness)
# ============================================================================

cat("\n6. Constructing distance-thresholded out-of-state IVs...\n")

# Distance thresholds to try
distance_thresholds <- c(0, 100, 150, 200, 250, 300, 400, 500)

compute_distance_iv <- function(min_dist, yr, qtr) {

  mw_this_q <- state_mw_panel %>%
    filter(year == yr, quarter == qtr) %>%
    select(state_fips, log_min_wage)

  # Filter to connections beyond min_dist
  filtered <- sci_cross_with_coords %>%
    filter(dist_km >= min_dist)

  if (nrow(filtered) == 0) return(NULL)

  # Re-normalize weights within the filtered set
  filtered_totals <- filtered %>%
    group_by(county_fips_1) %>%
    summarise(total = sum(sci, na.rm = TRUE), .groups = "drop")

  filtered <- filtered %>%
    left_join(filtered_totals, by = "county_fips_1") %>%
    mutate(w = sci / total)

  # Compute IV
  iv <- filtered %>%
    left_join(mw_this_q, by = c("state_fips_2" = "state_fips")) %>%
    group_by(county_fips_1) %>%
    summarise(
      iv_value = sum(w * log_min_wage, na.rm = TRUE),
      n_connections = n(),
      .groups = "drop"
    )

  return(iv)
}

# Compute distance IVs for all quarters
cat("  Computing distance-thresholded IVs...\n")

iv_list <- list()
for (d in distance_thresholds) {
  cat("    Distance >=", d, "km...\n")

  iv_time_list <- list()
  for (i in 1:nrow(time_periods)) {
    iv_result <- compute_distance_iv(d, time_periods$year[i], time_periods$quarter[i])
    if (!is.null(iv_result)) {
      iv_result$year <- time_periods$year[i]
      iv_result$quarter <- time_periods$quarter[i]
      iv_time_list[[i]] <- iv_result
    }
  }

  iv_panel_d <- bind_rows(iv_time_list) %>%
    rename(!!paste0("iv_dist_", d) := iv_value,
           !!paste0("n_conn_", d) := n_connections)

  iv_list[[as.character(d)]] <- iv_panel_d
}

# Merge all distance IVs
iv_panel <- exposure_panel %>%
  select(county_fips_1, year, quarter)

for (d in distance_thresholds) {
  d_str <- as.character(d)
  iv_cols <- c(paste0("iv_dist_", d), paste0("n_conn_", d))

  iv_panel <- iv_panel %>%
    left_join(
      iv_list[[d_str]] %>% select(county_fips_1, year, quarter, all_of(iv_cols)),
      by = c("county_fips_1", "year", "quarter")
    )
}

# Merge distance IVs into exposure panel
# iv_panel has all distance IV columns plus county_fips_1, year, quarter
iv_cols_to_add <- setdiff(names(iv_panel), c("county_fips_1", "year", "quarter"))

exposure_panel <- exposure_panel %>%
  left_join(
    iv_panel %>% select(county_fips_1, year, quarter, all_of(iv_cols_to_add)),
    by = c("county_fips_1", "year", "quarter")
  )

# ============================================================================
# 7. Merge with QWI Outcomes
# ============================================================================

cat("\n7. Creating final analysis panel...\n")

if (!is.null(qwi_raw) && nrow(qwi_raw) > 0) {
  cat("  QWI data found with", nrow(qwi_raw), "rows\n")

  panel <- qwi_raw %>%
    left_join(exposure_panel, by = c("county_fips" = "county_fips_1", "year", "quarter")) %>%
    left_join(centroids, by = c("county_fips" = "fips"))

  # Add own-state minimum wage
  panel <- panel %>%
    left_join(
      state_mw_panel %>% select(state_fips, year, quarter, own_min_wage = min_wage, own_log_mw = log_min_wage),
      by = c("state_fips", "year", "quarter")
    )

  # Ensure log outcomes exist
  panel <- panel %>%
    mutate(
      log_emp = if ("log_emp" %in% names(.)) log_emp else log(pmax(emp, 1)),
      log_earn = if ("log_earn" %in% names(.)) log_earn else log(pmax(earn, 1)),
      yearq = year + (quarter - 1) / 4
    )

} else {
  panel <- exposure_panel %>%
    rename(county_fips = county_fips_1) %>%
    left_join(centroids, by = c("county_fips" = "fips")) %>%
    left_join(
      state_mw_panel %>% select(state_fips, year, quarter, own_min_wage = min_wage, own_log_mw = log_min_wage),
      by = c("state_fips", "year", "quarter")
    ) %>%
    mutate(yearq = year + (quarter - 1) / 4)
}

cat("  Final panel rows:", format(nrow(panel), big.mark = ","), "\n")

# ============================================================================
# 8. Network Community Detection (for clustering)
# ============================================================================

cat("\n8. Running Louvain community detection...\n")

top_sci <- sci_full_normalized %>%
  group_by(county_fips_1) %>%
  slice_max(order_by = sci, n = 50) %>%
  ungroup()

g <- graph_from_data_frame(
  top_sci %>% select(from = county_fips_1, to = county_fips_2, weight = sci),
  directed = FALSE
)

louvain <- cluster_louvain(g, weights = E(g)$weight)

communities <- data.frame(
  county_fips = V(g)$name,
  network_cluster = membership(louvain)
)

cat("  Detected", max(communities$network_cluster), "network communities\n")

panel <- panel %>%
  left_join(communities, by = "county_fips")

# ============================================================================
# 9. Create Exposure Quantiles
# ============================================================================

cat("\n9. Creating exposure categories...\n")

avg_exposure <- panel %>%
  group_by(county_fips) %>%
  summarise(
    mean_network_mw_full = mean(network_mw_full, na.rm = TRUE),
    mean_network_mw_out_state = mean(network_mw_out_state, na.rm = TRUE),
    mean_geo_exposure = mean(geo_exposure, na.rm = TRUE),
    .groups = "drop"
  )

avg_exposure <- avg_exposure %>%
  mutate(
    network_full_cat = cut(mean_network_mw_full,
                           breaks = quantile(mean_network_mw_full, c(0, 1/3, 2/3, 1), na.rm = TRUE),
                           labels = c("Low", "Medium", "High"),
                           include.lowest = TRUE),
    network_out_state_cat = cut(mean_network_mw_out_state,
                                breaks = quantile(mean_network_mw_out_state, c(0, 1/3, 2/3, 1), na.rm = TRUE),
                                labels = c("Low", "Medium", "High"),
                                include.lowest = TRUE)
  )

panel <- panel %>%
  left_join(avg_exposure, by = "county_fips")

# ============================================================================
# 10. Save Analysis Panel
# ============================================================================

cat("\n10. Saving analysis panel...\n")

# Add backward-compatible aliases for legacy code
# social_exposure = network_mw_full (the full network including same-state, log scale)
# social_exposure_cat = network_full_cat (tercile categories)
# Note: social_exposure_resid would need to be computed here for orthogonalization
panel <- panel %>%
  mutate(
    social_exposure = network_mw_full,
    social_exposure_cat = network_full_cat,
    # Residualize social exposure on geographic exposure for orthogonal component
    social_exposure_resid = resid(lm(network_mw_full ~ geo_exposure, data = ., na.action = na.exclude))
  )

saveRDS(panel, "../data/analysis_panel.rds")
saveRDS(state_mw_panel, "../data/state_mw_panel.rds")
saveRDS(exposure_panel, "../data/exposure_panel.rds")
saveRDS(communities, "../data/network_communities.rds")

# ============================================================================
# Summary Statistics
# ============================================================================

cat("\n=== Panel Construction Complete ===\n")
cat("\nPanel summary:\n")
cat("  Observations:", format(nrow(panel), big.mark = ","), "\n")
cat("  Counties:", n_distinct(panel$county_fips), "\n")
cat("  States:", n_distinct(panel$state_fips), "\n")
cat("  Time periods:", n_distinct(panel$yearq), "\n")

cat("\nExposure variation:\n")
cat("  Full network MW (endogenous):\n")
cat("    Range: [", round(min(panel$network_mw_full, na.rm = TRUE), 3), ", ",
    round(max(panel$network_mw_full, na.rm = TRUE), 3), "]\n", sep = "")
cat("    Mean:", round(mean(panel$network_mw_full, na.rm = TRUE), 3), "\n")

cat("  Out-of-state network MW (IV):\n")
cat("    Range: [", round(min(panel$network_mw_out_state, na.rm = TRUE), 3), ", ",
    round(max(panel$network_mw_out_state, na.rm = TRUE), 3), "]\n", sep = "")
cat("    Mean:", round(mean(panel$network_mw_out_state, na.rm = TRUE), 3), "\n")

cat("\nCorrelations:\n")
cat("  Full vs Out-of-State:",
    round(cor(panel$network_mw_full, panel$network_mw_out_state, use = "complete.obs"), 3), "\n")
cat("  Full vs Own-State MW:",
    round(cor(panel$network_mw_full, panel$own_log_mw, use = "complete.obs"), 3), "\n")
cat("  Out-of-State vs Own-State MW:",
    round(cor(panel$network_mw_out_state, panel$own_log_mw, use = "complete.obs"), 3), "\n")

cat("\nFiles saved:\n")
cat("  - analysis_panel.rds\n")
cat("  - state_mw_panel.rds\n")
cat("  - exposure_panel.rds\n")
cat("  - network_communities.rds\n")
