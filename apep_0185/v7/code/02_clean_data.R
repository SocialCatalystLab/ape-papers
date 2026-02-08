################################################################################
# 02_clean_data.R
# Social Network Minimum Wage Exposure - POPULATION-WEIGHTED REVISION
#
# KEY CHANGE FROM PARENT PAPER (apep_0188):
# This revision implements POPULATION-WEIGHTED exposure measures.
#
# The key insight: Information VOLUME matters, not just information SHARE.
# Having more friends in high-MW states (absolute connections) drives effects,
# not just the fraction of your network in high-MW states.
#
# TWO WEIGHTING SCHEMES:
# 1. POPULATION-WEIGHTED (MAIN): w_j = (SCI_j × Pop_j) / Σ_k (SCI_k × Pop_k)
#    Interpretation: Weights by how many potential information sources
#
# 2. PROBABILITY-WEIGHTED (MECHANISM TEST): w_j = SCI_j / Σ_k SCI_k
#    Interpretation: Weights by probability of having a friend there
#    Problem: Treats Manhattan = rural Montana if same SCI
#
# Input:  data/raw_*.rds files
# Output: data/analysis_panel.rds with both exposure types
################################################################################

source("00_packages.R")

cat("=== Constructing Analysis Panel with Population-Weighted Exposure ===\n\n")

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
  # Standardize column names to lowercase
  if ("Emp" %in% names(qwi_raw)) {
    qwi_raw <- qwi_raw %>%
      rename(emp = Emp, earn = EarnS)
  }
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
# 3. Compute County Population Proxy (from employment)
# ============================================================================

cat("\n3. Computing county population proxies...\n")

# Use mean employment as population proxy
if (!is.null(qwi_raw) && nrow(qwi_raw) > 0) {
  county_pop <- qwi_raw %>%
    group_by(county_fips) %>%
    summarise(pop_proxy = mean(emp, na.rm = TRUE), .groups = "drop")

  cat("  Computed population proxy for", nrow(county_pop), "counties\n")
  cat("  Population range: [", round(min(county_pop$pop_proxy, na.rm = TRUE), 0),
      ", ", round(max(county_pop$pop_proxy, na.rm = TRUE), 0), "]\n", sep = "")
} else {
  # Use uniform weights if no QWI data
  county_pop <- centroids %>%
    select(county_fips = fips) %>%
    mutate(pop_proxy = 1)
  cat("  Using uniform population weights (no QWI data)\n")
}

# ============================================================================
# 4. Construct TWO Sets of SCI Weights
# ============================================================================

cat("\n4. Constructing SCI weights for both weighting schemes...\n")

# Add state FIPS to SCI data
sci <- as_tibble(sci_raw) %>%
  mutate(
    state_fips_1 = substr(county_fips_1, 1, 2),
    state_fips_2 = substr(county_fips_2, 1, 2)
  )

# ----------------------------------------------------------------------------
# 4A. PROBABILITY-WEIGHTED (original approach)
# w_j = SCI_j / Σ_k SCI_k
# ----------------------------------------------------------------------------

cat("  4A. Probability-weighted (original approach)...\n")

# Full network (leave-own-county-out)
sci_prob_full <- sci %>%
  filter(county_fips_1 != county_fips_2)

sci_prob_full_totals <- sci_prob_full %>%
  group_by(county_fips_1) %>%
  summarise(total_sci = sum(sci, na.rm = TRUE), .groups = "drop")

sci_prob_full <- sci_prob_full %>%
  left_join(sci_prob_full_totals, by = "county_fips_1") %>%
  mutate(w_prob = sci / total_sci)

# Out-of-state (leave-own-state-out) for IV
sci_prob_cross <- sci %>%
  filter(state_fips_1 != state_fips_2)

sci_prob_cross_totals <- sci_prob_cross %>%
  group_by(county_fips_1) %>%
  summarise(total_sci = sum(sci, na.rm = TRUE), .groups = "drop")

sci_prob_cross <- sci_prob_cross %>%
  left_join(sci_prob_cross_totals, by = "county_fips_1") %>%
  mutate(w_prob = sci / total_sci)

# ----------------------------------------------------------------------------
# 4B. POPULATION-WEIGHTED (new approach - main specification)
# w_j = (SCI_j × Pop_j) / Σ_k (SCI_k × Pop_k)
# ----------------------------------------------------------------------------

cat("  4B. Population-weighted (new main specification)...\n")

# Full network (leave-own-county-out)
sci_pop_full <- sci %>%
  filter(county_fips_1 != county_fips_2) %>%
  left_join(county_pop, by = c("county_fips_2" = "county_fips")) %>%
  mutate(sci_pop = sci * pop_proxy)

sci_pop_full_totals <- sci_pop_full %>%
  group_by(county_fips_1) %>%
  summarise(total_sci_pop = sum(sci_pop, na.rm = TRUE), .groups = "drop")

sci_pop_full <- sci_pop_full %>%
  left_join(sci_pop_full_totals, by = "county_fips_1") %>%
  mutate(w_pop = sci_pop / total_sci_pop)

cat("      Full network (pop-weighted) pairs:", format(nrow(sci_pop_full), big.mark = ","), "\n")

# Out-of-state (leave-own-state-out) for IV
sci_pop_cross <- sci %>%
  filter(state_fips_1 != state_fips_2) %>%
  left_join(county_pop, by = c("county_fips_2" = "county_fips")) %>%
  mutate(sci_pop = sci * pop_proxy)

sci_pop_cross_totals <- sci_pop_cross %>%
  group_by(county_fips_1) %>%
  summarise(total_sci_pop = sum(sci_pop, na.rm = TRUE), .groups = "drop")

sci_pop_cross <- sci_pop_cross %>%
  left_join(sci_pop_cross_totals, by = "county_fips_1") %>%
  mutate(w_pop = sci_pop / total_sci_pop)

cat("      Cross-state (pop-weighted) pairs:", format(nrow(sci_pop_cross), big.mark = ","), "\n")

# ============================================================================
# 5. Compute Inter-County Distances (for distance-thresholded IVs)
# ============================================================================

cat("\n5. Computing inter-county distances...\n")

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
sci_pop_cross_coords <- sci_pop_cross %>%
  left_join(centroids %>% select(fips, lon1 = lon, lat1 = lat),
            by = c("county_fips_1" = "fips")) %>%
  left_join(centroids %>% select(fips, lon2 = lon, lat2 = lat),
            by = c("county_fips_2" = "fips")) %>%
  filter(!is.na(lon1) & !is.na(lon2)) %>%
  mutate(dist_km = haversine(lon1, lat1, lon2, lat2))

# Also for prob-weighted version
sci_prob_cross_coords <- sci_prob_cross %>%
  left_join(centroids %>% select(fips, lon1 = lon, lat1 = lat),
            by = c("county_fips_1" = "fips")) %>%
  left_join(centroids %>% select(fips, lon2 = lon, lat2 = lat),
            by = c("county_fips_2" = "fips")) %>%
  filter(!is.na(lon1) & !is.na(lon2)) %>%
  mutate(dist_km = haversine(lon1, lat1, lon2, lat2))

cat("  Distance range: [", round(min(sci_pop_cross_coords$dist_km), 0), ",",
    round(max(sci_pop_cross_coords$dist_km), 0), "] km\n")

# Add coordinates and geographic weights to full network
sci_pop_full_coords <- sci_pop_full %>%
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
geo_totals <- sci_pop_full_coords %>%
  group_by(county_fips_1) %>%
  summarise(total_inv_dist = sum(inv_dist, na.rm = TRUE), .groups = "drop")

sci_pop_full_coords <- sci_pop_full_coords %>%
  left_join(geo_totals, by = "county_fips_1") %>%
  mutate(w_geo = inv_dist / total_inv_dist)

# ============================================================================
# 6. Compute Exposure Measures for Each County-Quarter
# ============================================================================

cat("\n6. Computing BOTH exposure measures for each county-quarter...\n")

time_periods <- state_mw_panel %>%
  filter(year >= 2012, year <= 2022) %>%
  select(year, quarter, yearq) %>%
  distinct()

# Function to compute all exposure types for a time period
compute_all_exposures <- function(yr, qtr) {

  # Get minimum wages for this quarter
  mw_this_q <- state_mw_panel %>%
    filter(year == yr, quarter == qtr) %>%
    select(state_fips, log_min_wage, min_wage)

  # POPULATION-WEIGHTED FULL NETWORK (main endogenous variable)
  pop_full_exp <- sci_pop_full_coords %>%
    left_join(mw_this_q, by = c("state_fips_2" = "state_fips")) %>%
    group_by(county_fips_1) %>%
    summarise(
      network_mw_pop = sum(w_pop * log_min_wage, na.rm = TRUE),
      network_mw_pop_dollar = sum(w_pop * min_wage, na.rm = TRUE),
      geo_exposure = sum(w_geo * log_min_wage, na.rm = TRUE),
      .groups = "drop"
    )

  # POPULATION-WEIGHTED OUT-OF-STATE (main IV)
  pop_cross_exp <- sci_pop_cross_coords %>%
    left_join(mw_this_q, by = c("state_fips_2" = "state_fips")) %>%
    group_by(county_fips_1) %>%
    summarise(
      network_mw_pop_out_state = sum(w_pop * log_min_wage, na.rm = TRUE),
      network_mw_pop_out_state_dollar = sum(w_pop * min_wage, na.rm = TRUE),
      .groups = "drop"
    )

  # PROBABILITY-WEIGHTED FULL NETWORK (for mechanism test)
  prob_full_exp <- sci_prob_full %>%
    left_join(mw_this_q, by = c("state_fips_2" = "state_fips")) %>%
    group_by(county_fips_1) %>%
    summarise(
      network_mw_prob = sum(w_prob * log_min_wage, na.rm = TRUE),
      network_mw_prob_dollar = sum(w_prob * min_wage, na.rm = TRUE),
      .groups = "drop"
    )

  # PROBABILITY-WEIGHTED OUT-OF-STATE (for mechanism test IV)
  prob_cross_exp <- sci_prob_cross %>%
    left_join(mw_this_q, by = c("state_fips_2" = "state_fips")) %>%
    group_by(county_fips_1) %>%
    summarise(
      network_mw_prob_out_state = sum(w_prob * log_min_wage, na.rm = TRUE),
      .groups = "drop"
    )

  # Merge all
  exposure <- pop_full_exp %>%
    left_join(pop_cross_exp, by = "county_fips_1") %>%
    left_join(prob_full_exp, by = "county_fips_1") %>%
    left_join(prob_cross_exp, by = "county_fips_1") %>%
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
# 7. Construct Distance-Thresholded IVs (for robustness)
# ============================================================================

cat("\n7. Constructing distance-thresholded out-of-state IVs (pop-weighted)...\n")

distance_thresholds <- c(0, 100, 150, 200, 250, 300, 400, 500)

compute_distance_iv <- function(min_dist, yr, qtr) {

  mw_this_q <- state_mw_panel %>%
    filter(year == yr, quarter == qtr) %>%
    select(state_fips, log_min_wage)

  # Filter to connections beyond min_dist
  filtered <- sci_pop_cross_coords %>%
    filter(dist_km >= min_dist)

  if (nrow(filtered) == 0) return(NULL)

  # Re-normalize population-weighted weights within the filtered set
  filtered_totals <- filtered %>%
    group_by(county_fips_1) %>%
    summarise(total = sum(sci_pop, na.rm = TRUE), .groups = "drop")

  filtered <- filtered %>%
    left_join(filtered_totals, by = "county_fips_1") %>%
    mutate(w = sci_pop / total)

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
    rename(!!paste0("iv_pop_dist_", d) := iv_value,
           !!paste0("n_conn_", d) := n_connections)

  iv_list[[as.character(d)]] <- iv_panel_d
}

# Merge all distance IVs
iv_panel <- exposure_panel %>%
  select(county_fips_1, year, quarter)

for (d in distance_thresholds) {
  d_str <- as.character(d)
  iv_cols <- c(paste0("iv_pop_dist_", d), paste0("n_conn_", d))

  iv_panel <- iv_panel %>%
    left_join(
      iv_list[[d_str]] %>% select(county_fips_1, year, quarter, all_of(iv_cols)),
      by = c("county_fips_1", "year", "quarter")
    )
}

# Merge distance IVs into exposure panel
iv_cols_to_add <- setdiff(names(iv_panel), c("county_fips_1", "year", "quarter"))

exposure_panel <- exposure_panel %>%
  left_join(
    iv_panel %>% select(county_fips_1, year, quarter, all_of(iv_cols_to_add)),
    by = c("county_fips_1", "year", "quarter")
  )

# ============================================================================
# 8. Merge with QWI Outcomes
# ============================================================================

cat("\n8. Creating final analysis panel...\n")

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
# 9. Network Community Detection (for clustering)
# ============================================================================

cat("\n9. Running Louvain community detection...\n")

top_sci <- sci_prob_full %>%
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
# 10. Create Exposure Quantiles
# ============================================================================

cat("\n10. Creating exposure categories...\n")

avg_exposure <- panel %>%
  group_by(county_fips) %>%
  summarise(
    mean_network_mw_pop = mean(network_mw_pop, na.rm = TRUE),
    mean_network_mw_prob = mean(network_mw_prob, na.rm = TRUE),
    mean_geo_exposure = mean(geo_exposure, na.rm = TRUE),
    .groups = "drop"
  )

avg_exposure <- avg_exposure %>%
  mutate(
    network_pop_cat = cut(mean_network_mw_pop,
                          breaks = quantile(mean_network_mw_pop, c(0, 1/3, 2/3, 1), na.rm = TRUE),
                          labels = c("Low", "Medium", "High"),
                          include.lowest = TRUE),
    network_prob_cat = cut(mean_network_mw_prob,
                           breaks = quantile(mean_network_mw_prob, c(0, 1/3, 2/3, 1), na.rm = TRUE),
                           labels = c("Low", "Medium", "High"),
                           include.lowest = TRUE)
  )

panel <- panel %>%
  left_join(avg_exposure, by = "county_fips")

# ============================================================================
# 11. Create Backward-Compatible Aliases
# ============================================================================

cat("\n11. Creating backward-compatible variable names...\n")

# For legacy code compatibility, create aliases
# Main specification: population-weighted
# Mechanism test: probability-weighted
panel <- panel %>%
  mutate(
    # Main variables (population-weighted)
    network_mw_full = network_mw_pop,
    network_mw_out_state = network_mw_pop_out_state,
    social_exposure = network_mw_pop,
    social_exposure_cat = network_pop_cat,

    # Residualize social exposure on geographic exposure
    social_exposure_resid = resid(lm(network_mw_pop ~ geo_exposure, data = ., na.action = na.exclude)),

    # Mechanism test variables (probability-weighted)
    network_mw_full_prob = network_mw_prob,
    network_mw_out_state_prob = network_mw_prob_out_state
  )

# ============================================================================
# 12. Save Analysis Panel
# ============================================================================

cat("\n12. Saving analysis panel...\n")

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

cat("\n=== EXPOSURE MEASURE COMPARISON ===\n")

cat("\nPopulation-Weighted Network MW (MAIN):\n")
cat("  Range: [", round(min(panel$network_mw_pop, na.rm = TRUE), 3), ", ",
    round(max(panel$network_mw_pop, na.rm = TRUE), 3), "]\n", sep = "")
cat("  Mean:", round(mean(panel$network_mw_pop, na.rm = TRUE), 3), "\n")
cat("  SD:", round(sd(panel$network_mw_pop, na.rm = TRUE), 3), "\n")

cat("\nProbability-Weighted Network MW (MECHANISM TEST):\n")
cat("  Range: [", round(min(panel$network_mw_prob, na.rm = TRUE), 3), ", ",
    round(max(panel$network_mw_prob, na.rm = TRUE), 3), "]\n", sep = "")
cat("  Mean:", round(mean(panel$network_mw_prob, na.rm = TRUE), 3), "\n")
cat("  SD:", round(sd(panel$network_mw_prob, na.rm = TRUE), 3), "\n")

cat("\nCorrelation between Pop-Weighted and Prob-Weighted:",
    round(cor(panel$network_mw_pop, panel$network_mw_prob, use = "complete.obs"), 3), "\n")

cat("\nIV Correlations (with endogenous variable):\n")
cat("  Pop-weighted IV with Pop-weighted endog:",
    round(cor(panel$network_mw_pop, panel$network_mw_pop_out_state, use = "complete.obs"), 3), "\n")
cat("  Prob-weighted IV with Prob-weighted endog:",
    round(cor(panel$network_mw_prob, panel$network_mw_prob_out_state, use = "complete.obs"), 3), "\n")

cat("\nFiles saved:\n")
cat("  - analysis_panel.rds\n")
cat("  - state_mw_panel.rds\n")
cat("  - exposure_panel.rds\n")
cat("  - network_communities.rds\n")
