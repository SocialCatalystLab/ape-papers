################################################################################
# 02_clean_data.R
# Social Network Spillovers of Minimum Wage
#
# Input:  data/raw_*.rds files
# Output: data/analysis_panel.rds with network and geographic exposure measures
################################################################################

source("00_packages.R")

cat("=== Constructing Analysis Panel with Network Exposure ===\n\n")

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
  # Get all MW changes for this state before the date
  applicable <- state_mw %>%
    filter(state_fips == st_fips, date <= dt) %>%
    arrange(desc(date))

  if (nrow(applicable) > 0) {
    return(applicable$min_wage[1])
  } else {
    # Use federal minimum as default
    return(federal_mw)
  }
}

# Apply (this is slow but clear)
cat("  Computing state minimum wages for each quarter...\n")
state_mw_panel <- state_mw_panel %>%
  rowwise() %>%
  mutate(min_wage = get_min_wage(state_fips, date_end)) %>%
  ungroup()

# Log minimum wage
state_mw_panel <- state_mw_panel %>%
  mutate(log_min_wage = log(min_wage))

cat("  Created panel with", nrow(state_mw_panel), "state-quarter obs\n")

# Summary of variation
mw_summary <- state_mw_panel %>%
  group_by(state_fips) %>%
  summarise(
    min_mw = min(min_wage),
    max_mw = max(min_wage),
    ever_raised = max_mw > federal_mw
  )

cat("  States that raised MW above federal:", sum(mw_summary$ever_raised), "\n")

# ============================================================================
# 3. Construct SCI Weights (Normalized, Leave-Own-State-Out)
# ============================================================================

cat("\n3. Constructing normalized SCI weights...\n")

# Add state FIPS to SCI data
sci <- as_tibble(sci_raw) %>%
  mutate(
    state_fips_1 = substr(county_fips_1, 1, 2),
    state_fips_2 = substr(county_fips_2, 1, 2)
  )

# Leave-own-state-out: Only keep cross-state connections
sci_cross_state <- sci %>%
  filter(state_fips_1 != state_fips_2)

cat("  Cross-state SCI pairs:", format(nrow(sci_cross_state), big.mark = ","), "\n")

# For each county, compute total SCI to all other-state counties
# This is the denominator for normalization
sci_totals <- sci_cross_state %>%
  group_by(county_fips_1) %>%
  summarise(total_sci = sum(sci, na.rm = TRUE), .groups = "drop")

# Normalize weights
sci_normalized <- sci_cross_state %>%
  left_join(sci_totals, by = "county_fips_1") %>%
  mutate(w_sci = sci / total_sci) %>%
  select(county_fips_1, county_fips_2, state_fips_2, sci, w_sci)

cat("  Normalized SCI weights computed\n")

# ============================================================================
# 4. Compute Inter-County Distances
# ============================================================================

cat("\n4. Computing inter-county distances...\n")

# For geographic exposure, compute distances between all county pairs
# This is O(n^2) but necessary for the distance-weighted exposure

# Haversine distance function
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

# For efficiency, merge SCI data with centroids to get coordinates
sci_with_coords <- sci_normalized %>%
  left_join(centroids %>% select(fips, lon1 = lon, lat1 = lat),
            by = c("county_fips_1" = "fips")) %>%
  left_join(centroids %>% select(fips, lon2 = lon, lat2 = lat),
            by = c("county_fips_2" = "fips"))

# Compute distances
cat("  Computing Haversine distances for", format(nrow(sci_with_coords), big.mark = ","), "pairs...\n")
sci_with_coords <- sci_with_coords %>%
  filter(!is.na(lon1) & !is.na(lon2)) %>%
  mutate(
    dist_km = haversine(lon1, lat1, lon2, lat2),
    inv_dist = 1 / pmax(dist_km, 1)  # Avoid division by zero
  )

# Normalize geographic weights
geo_totals <- sci_with_coords %>%
  group_by(county_fips_1) %>%
  summarise(total_inv_dist = sum(inv_dist, na.rm = TRUE), .groups = "drop")

sci_with_coords <- sci_with_coords %>%
  left_join(geo_totals, by = "county_fips_1") %>%
  mutate(w_geo = inv_dist / total_inv_dist)

cat("  Distance weights computed\n")

# ============================================================================
# 5. Compute Network and Geographic Exposure for Each County-Quarter
# ============================================================================

cat("\n5. Computing exposure measures...\n")

# Get unique quarters
time_periods <- state_mw_panel %>%
  select(year, quarter, yearq) %>%
  distinct()

# For each county, compute:
# SocialExposure_{ct} = Σⱼ w_{cj} × log(MinWage_{jt})
# GeographicExposure_{ct} = Σⱼ g_{cj} × log(MinWage_{jt})

# Prepare weights with state info for county_2
weights_data <- sci_with_coords %>%
  select(county_fips_1, county_fips_2, state_fips_2, w_sci, w_geo)

# Function to compute exposures for a given time period
compute_exposure <- function(yr, qtr) {
  # Get minimum wages for this quarter
  mw_this_q <- state_mw_panel %>%
    filter(year == yr, quarter == qtr) %>%
    select(state_fips, log_min_wage)

  # Join with weights
  exposure <- weights_data %>%
    left_join(mw_this_q, by = c("state_fips_2" = "state_fips")) %>%
    group_by(county_fips_1) %>%
    summarise(
      social_exposure = sum(w_sci * log_min_wage, na.rm = TRUE),
      geo_exposure = sum(w_geo * log_min_wage, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(year = yr, quarter = qtr)

  return(exposure)
}

# Compute for all quarters
cat("  Computing exposures for", nrow(time_periods), "quarters...\n")
exposure_list <- list()

for (i in 1:nrow(time_periods)) {
  if (i %% 10 == 0) cat("  Quarter", i, "/", nrow(time_periods), "\n")
  exposure_list[[i]] <- compute_exposure(time_periods$year[i], time_periods$quarter[i])
}

exposure_panel <- bind_rows(exposure_list)
cat("  Created exposure panel with", format(nrow(exposure_panel), big.mark = ","), "county-quarter obs\n")

# ============================================================================
# 6. Merge with QWI Outcomes
# ============================================================================

cat("\n6. Creating final analysis panel...\n")

if (!is.null(qwi_raw) && nrow(qwi_raw) > 0) {
  cat("  QWI data found with", nrow(qwi_raw), "rows\n")
  cat("  QWI columns:", paste(names(qwi_raw), collapse = ", "), "\n")

  # Merge exposure with QWI
  panel <- qwi_raw %>%
    left_join(exposure_panel, by = c("county_fips" = "county_fips_1", "year", "quarter")) %>%
    left_join(centroids, by = c("county_fips" = "fips"))

  # Add state minimum wage for own-state
  panel <- panel %>%
    left_join(
      state_mw_panel %>% select(state_fips, year, quarter, own_min_wage = min_wage, own_log_mw = log_min_wage),
      by = c("state_fips", "year", "quarter")
    )

  # Create/ensure log outcomes exist
  # QWI data already has emp, earn, log_emp, log_earn
  panel <- panel %>%
    mutate(
      log_emp = if ("log_emp" %in% names(.)) log_emp else log(pmax(emp, 1)),
      log_earn = if ("log_earn" %in% names(.)) log_earn else log(pmax(earn, 1)),
      yearq = year + (quarter - 1) / 4
    )

  # All industries aggregated (we fetched aggregate QWI data)
  panel <- panel %>%
    mutate(industry_type = "All Industries")

} else {
  # Create basic panel without QWI (for code testing)
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
cat("  Final panel cols:", ncol(panel), "\n")

# ============================================================================
# 7. Network Community Detection (for Clustering)
# ============================================================================

cat("\n7. Running Louvain community detection for network clustering...\n")

# Create graph from SCI data (sampled for speed)
# Use only top connections per county
top_sci <- sci_normalized %>%
  group_by(county_fips_1) %>%
  slice_max(order_by = sci, n = 50) %>%  # Top 50 connections per county
  ungroup()

# Create igraph object
g <- graph_from_data_frame(
  top_sci %>% select(from = county_fips_1, to = county_fips_2, weight = sci),
  directed = FALSE
)

# Run Louvain clustering
louvain <- cluster_louvain(g, weights = E(g)$weight)

# Extract community assignments
communities <- data.frame(
  county_fips = V(g)$name,
  network_cluster = membership(louvain)
)

cat("  Detected", max(communities$network_cluster), "network communities\n")

# Add to panel
panel <- panel %>%
  left_join(communities, by = "county_fips")

# ============================================================================
# 8. Create Exposure Quantiles for Visualization
# ============================================================================

cat("\n8. Creating exposure categories...\n")

# Compute time-averaged exposure for categorization
avg_exposure <- panel %>%
  group_by(county_fips) %>%
  summarise(
    mean_social_exposure = mean(social_exposure, na.rm = TRUE),
    mean_geo_exposure = mean(geo_exposure, na.rm = TRUE),
    .groups = "drop"
  )

# Terciles
avg_exposure <- avg_exposure %>%
  mutate(
    social_exposure_cat = cut(mean_social_exposure,
                               breaks = quantile(mean_social_exposure, c(0, 1/3, 2/3, 1), na.rm = TRUE),
                               labels = c("Low", "Medium", "High"),
                               include.lowest = TRUE),
    geo_exposure_cat = cut(mean_geo_exposure,
                           breaks = quantile(mean_geo_exposure, c(0, 1/3, 2/3, 1), na.rm = TRUE),
                           labels = c("Low", "Medium", "High"),
                           include.lowest = TRUE)
  )

panel <- panel %>%
  left_join(avg_exposure, by = "county_fips")

# ============================================================================
# 9. Compute Exposure Orthogonal Component
# ============================================================================

cat("\n9. Computing orthogonalized exposure (residual from geography)...\n")

# Regress social exposure on geographic exposure to get residual
# This is the "pure network" effect controlling for geography

# Handle missing values properly
panel <- panel %>%
  mutate(social_exposure_resid = NA_real_)

# Only compute for observations with both exposures
has_exposure <- !is.na(panel$social_exposure) & !is.na(panel$geo_exposure)
if (sum(has_exposure) > 100) {
  ortho_model <- lm(social_exposure ~ geo_exposure, data = panel[has_exposure, ])
  panel$social_exposure_resid[has_exposure] <- resid(ortho_model)
} else {
  cat("  WARNING: Too few observations with exposure data for orthogonalization\n")
  ortho_model <- list(r.squared = NA)
}

cat("  R-squared of social ~ geo:", round(summary(ortho_model)$r.squared, 3), "\n")
cat("  This measures how much network exposure overlaps with geography\n")

# ============================================================================
# 10. Save Analysis Panel
# ============================================================================

cat("\n10. Saving analysis panel...\n")

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

if ("industry" %in% names(panel)) {
  cat("  Industries:", n_distinct(panel$industry), "\n")
}

cat("\nExposure variation:\n")
cat("  Social exposure range: [",
    round(min(panel$social_exposure, na.rm = TRUE), 3), ", ",
    round(max(panel$social_exposure, na.rm = TRUE), 3), "]\n", sep = "")
cat("  Geographic exposure range: [",
    round(min(panel$geo_exposure, na.rm = TRUE), 3), ", ",
    round(max(panel$geo_exposure, na.rm = TRUE), 3), "]\n", sep = "")
cat("  Correlation (social, geo):",
    round(cor(panel$social_exposure, panel$geo_exposure, use = "complete.obs"), 3), "\n")

cat("\nFiles saved:\n")
cat("  - analysis_panel.rds\n")
cat("  - state_mw_panel.rds\n")
cat("  - exposure_panel.rds\n")
cat("  - network_communities.rds\n")
