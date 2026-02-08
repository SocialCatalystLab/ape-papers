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
  qwi_raw_all <- readRDS("../data/raw_qwi.rds")
  # Standardize column names to lowercase
  if ("Emp" %in% names(qwi_raw_all)) {
    rename_map <- c(emp = "Emp", earn = "EarnS")
    # Also rename job flow variables if present
    if ("HirA" %in% names(qwi_raw_all)) rename_map <- c(rename_map, hira = "HirA")
    if ("Sep" %in% names(qwi_raw_all)) rename_map <- c(rename_map, sep = "Sep")
    if ("FrmJbC" %in% names(qwi_raw_all)) rename_map <- c(rename_map, frmjbc = "FrmJbC")
    if ("FrmJbD" %in% names(qwi_raw_all)) rename_map <- c(rename_map, frmjbd = "FrmJbD")
    qwi_raw_all <- qwi_raw_all %>% rename(!!!rename_map)
  }

  # Try to merge separately-fetched job flow data if available
  if (file.exists("../data/raw_job_flows.rds") &&
      !all(c("hira", "sep") %in% names(qwi_raw_all))) {
    cat("  Loading separately-fetched job flow data...\n")
    jf_data <- readRDS("../data/raw_job_flows.rds")
    cat("  Job flow rows:", format(nrow(jf_data), big.mark = ","), "\n")
    qwi_raw_all <- qwi_raw_all %>%
      left_join(jf_data, by = c("county_fips", "year", "quarter"))
    cat("  Merged job flow data into QWI\n")
  }

  # Report job flow variable availability
  jf_vars <- intersect(c("hira", "sep", "frmjbc", "frmjbd"), names(qwi_raw_all))
  cat("  Job flow variables present:", paste(jf_vars, collapse = ", "), "\n")

  # Separate aggregate (industry=00) from industry-specific data
  if ("industry" %in% names(qwi_raw_all)) {
    qwi_raw <- qwi_raw_all %>% filter(industry == "00" | is.na(industry))
    qwi_industry <- qwi_raw_all %>% filter(!is.na(industry) & industry != "00")

    # Create industry_type classification
    if (nrow(qwi_industry) > 0) {
      qwi_industry <- qwi_industry %>%
        mutate(industry_type = case_when(
          industry %in% c("44-45", "72") ~ "High Bite",   # Retail, Accommodation/Food
          industry %in% c("52", "54") ~ "Low Bite",       # Finance, Professional
          TRUE ~ NA_character_
        )) %>%
        filter(!is.na(industry_type))

      cat("  Industry-level QWI rows:", format(nrow(qwi_industry), big.mark = ","), "\n")
      cat("    High Bite (Retail+Accommodation):", sum(qwi_industry$industry_type == "High Bite"), "\n")
      cat("    Low Bite (Finance+Professional):", sum(qwi_industry$industry_type == "Low Bite"), "\n")
    } else {
      qwi_industry <- NULL
      cat("  No industry-specific QWI data found\n")
    }
  } else {
    qwi_raw <- qwi_raw_all
    qwi_industry <- NULL
    cat("  No industry column in QWI data\n")
  }
} else {
  cat("  WARNING: QWI data not found. Will create simpler panel.\n")
  qwi_raw <- NULL
  qwi_industry <- NULL
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
# REVISION (apep_0198): Re-normalize weights AFTER NA filtering to fix
# the normalization bug where weights didn't sum to 1 after join mismatches.
compute_all_exposures <- function(yr, qtr) {

  # Get minimum wages for this quarter
  mw_this_q <- state_mw_panel %>%
    filter(year == yr, quarter == qtr) %>%
    select(state_fips, log_min_wage, min_wage)

  # POPULATION-WEIGHTED FULL NETWORK (main endogenous variable)
  pop_full_exp <- sci_pop_full_coords %>%
    left_join(mw_this_q, by = c("state_fips_2" = "state_fips")) %>%
    filter(!is.na(log_min_wage), !is.na(sci_pop)) %>%
    group_by(county_fips_1) %>%
    mutate(
      w_pop_renorm = sci_pop / sum(sci_pop),
      w_geo_renorm = inv_dist / sum(inv_dist)
    ) %>%
    summarise(
      network_mw_pop = sum(w_pop_renorm * log_min_wage),
      network_mw_pop_dollar = sum(w_pop_renorm * min_wage),
      geo_exposure = sum(w_geo_renorm * log_min_wage),
      .groups = "drop"
    )

  # POPULATION-WEIGHTED OUT-OF-STATE (main IV)
  pop_cross_exp <- sci_pop_cross_coords %>%
    left_join(mw_this_q, by = c("state_fips_2" = "state_fips")) %>%
    filter(!is.na(log_min_wage), !is.na(sci_pop)) %>%
    group_by(county_fips_1) %>%
    mutate(w_pop_renorm = sci_pop / sum(sci_pop)) %>%
    summarise(
      network_mw_pop_out_state = sum(w_pop_renorm * log_min_wage),
      network_mw_pop_out_state_dollar = sum(w_pop_renorm * min_wage),
      .groups = "drop"
    )

  # PROBABILITY-WEIGHTED FULL NETWORK (for mechanism test)
  prob_full_exp <- sci_prob_full %>%
    left_join(mw_this_q, by = c("state_fips_2" = "state_fips")) %>%
    filter(!is.na(log_min_wage), !is.na(sci)) %>%
    group_by(county_fips_1) %>%
    mutate(w_prob_renorm = sci / sum(sci)) %>%
    summarise(
      network_mw_prob = sum(w_prob_renorm * log_min_wage),
      network_mw_prob_dollar = sum(w_prob_renorm * min_wage),
      .groups = "drop"
    )

  # PROBABILITY-WEIGHTED OUT-OF-STATE (for mechanism test IV)
  prob_cross_exp <- sci_prob_cross %>%
    left_join(mw_this_q, by = c("state_fips_2" = "state_fips")) %>%
    filter(!is.na(log_min_wage), !is.na(sci)) %>%
    group_by(county_fips_1) %>%
    mutate(w_prob_renorm = sci / sum(sci)) %>%
    summarise(
      network_mw_prob_out_state = sum(w_prob_renorm * log_min_wage),
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

# VALIDATION: Check that all exposure measures are >= log(7.25) = 1.981
log_floor <- log(7.25)
n_below_pop <- sum(exposure_panel$network_mw_pop < log_floor, na.rm = TRUE)
n_below_prob <- sum(exposure_panel$network_mw_prob < log_floor, na.rm = TRUE)
cat("\n  === WEIGHT NORMALIZATION VALIDATION ===\n")
cat("  Observations with network_mw_pop < log(7.25):", n_below_pop,
    "(", round(100 * n_below_pop / nrow(exposure_panel), 1), "%)\n")
cat("  Observations with network_mw_prob < log(7.25):", n_below_prob,
    "(", round(100 * n_below_prob / nrow(exposure_panel), 1), "%)\n")
cat("  Pop-weighted range: [", round(min(exposure_panel$network_mw_pop, na.rm = TRUE), 4), ",",
    round(max(exposure_panel$network_mw_pop, na.rm = TRUE), 4), "]\n")
cat("  Dollar range: [$", round(min(exposure_panel$network_mw_pop_dollar, na.rm = TRUE), 2), ", $",
    round(max(exposure_panel$network_mw_pop_dollar, na.rm = TRUE), 2), "]\n")
if (n_below_pop == 0) cat("  PASS: All exposure measures >= log(7.25)\n")
cat("  =====================================\n")

# ============================================================================
# 7. Construct Distance-Thresholded IVs (for robustness)
# ============================================================================

cat("\n7. Constructing distance-thresholded out-of-state IVs (pop-weighted)...\n")

distance_thresholds <- c(0, 100, 150, 200, 250, 300, 400, 500)

compute_distance_iv <- function(min_dist, yr, qtr) {

  mw_this_q <- state_mw_panel %>%
    filter(year == yr, quarter == qtr) %>%
    select(state_fips, log_min_wage)

  # Filter to connections beyond min_dist, join MW, then re-normalize
  filtered <- sci_pop_cross_coords %>%
    filter(dist_km >= min_dist) %>%
    left_join(mw_this_q, by = c("state_fips_2" = "state_fips")) %>%
    filter(!is.na(log_min_wage), !is.na(sci_pop))

  if (nrow(filtered) == 0) return(NULL)

  # Re-normalize population-weighted weights within the filtered set AFTER NA removal
  iv <- filtered %>%
    group_by(county_fips_1) %>%
    mutate(w = sci_pop / sum(sci_pop)) %>%
    summarise(
      iv_value = sum(w * log_min_wage),
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

  # Add job flow variables if present
  jf_cols <- intersect(c("hira", "sep", "frmjbc", "frmjbd"), names(panel))
  if (length(jf_cols) > 0) {
    cat("  Adding job flow transformations for:", paste(jf_cols, collapse = ", "), "\n")
    if ("hira" %in% jf_cols) panel <- panel %>% mutate(log_hira = log(pmax(hira, 1)))
    if ("sep" %in% jf_cols) panel <- panel %>% mutate(log_sep = log(pmax(sep, 1)))
    if ("frmjbc" %in% jf_cols) panel <- panel %>% mutate(log_frmjbc = log(pmax(frmjbc, 1)))
    if ("frmjbd" %in% jf_cols) panel <- panel %>% mutate(log_frmjbd = log(pmax(frmjbd, 1)))
    if (all(c("hira", "emp") %in% names(panel))) {
      panel <- panel %>% mutate(hire_rate = hira / pmax(emp, 1))
    }
    if (all(c("sep", "emp") %in% names(panel))) {
      panel <- panel %>% mutate(sep_rate = sep / pmax(emp, 1))
    }
    if (all(c("frmjbc", "frmjbd", "emp") %in% names(panel))) {
      panel <- panel %>% mutate(net_job_creation_rate = (frmjbc - frmjbd) / pmax(emp, 1))
    }
  }

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

cat("\nPopulation-Weighted Network MW (MAIN, log):\n")
cat("  Range: [", round(min(panel$network_mw_pop, na.rm = TRUE), 3), ", ",
    round(max(panel$network_mw_pop, na.rm = TRUE), 3), "]\n", sep = "")
cat("  Mean:", round(mean(panel$network_mw_pop, na.rm = TRUE), 3), "\n")
cat("  SD:", round(sd(panel$network_mw_pop, na.rm = TRUE), 3), "\n")

cat("\nPopulation-Weighted Network MW (USD):\n")
cat("  Range: [$", round(min(panel$network_mw_pop_dollar, na.rm = TRUE), 2), ", $",
    round(max(panel$network_mw_pop_dollar, na.rm = TRUE), 2), "]\n", sep = "")
cat("  Mean: $", round(mean(panel$network_mw_pop_dollar, na.rm = TRUE), 2), "\n", sep = "")
cat("  SD: $", round(sd(panel$network_mw_pop_dollar, na.rm = TRUE), 2), "\n", sep = "")

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

# Job flow summary
jf_cols_panel <- intersect(c("hira", "sep", "frmjbc", "frmjbd"), names(panel))
if (length(jf_cols_panel) > 0) {
  cat("\nJob Flow Variables:\n")
  for (v in jf_cols_panel) {
    non_na <- sum(!is.na(panel[[v]]) & panel[[v]] > 0)
    cat("  ", v, ": non-missing =", format(non_na, big.mark = ","),
        ", mean =", round(mean(panel[[v]], na.rm = TRUE), 1), "\n")
  }
  cat("  Coverage:", round(100 * mean(!is.na(panel$hira) & panel$hira > 0, na.rm = TRUE), 1),
      "% of county-quarters have non-suppressed hiring data\n")
}

# ============================================================================
# 13. Create Industry-Level Analysis Panel
# ============================================================================

cat("\n13. Creating industry-level analysis panel...\n")

if (!is.null(qwi_industry) && nrow(qwi_industry) > 0) {
  # Aggregate industry data by county-quarter-industry_type
  # (combine NAICS 44-45 + 72 for High Bite, 52 + 54 for Low Bite)
  # Include job flow variables if present
  agg_expr <- list(
    emp = ~sum(emp, na.rm = TRUE),
    earn = ~weighted.mean(earn, w = pmax(emp, 1), na.rm = TRUE)
  )
  if ("hira" %in% names(qwi_industry)) agg_expr$hira <- ~sum(hira, na.rm = TRUE)
  if ("sep" %in% names(qwi_industry)) agg_expr$sep <- ~sum(sep, na.rm = TRUE)
  if ("frmjbc" %in% names(qwi_industry)) agg_expr$frmjbc <- ~sum(frmjbc, na.rm = TRUE)
  if ("frmjbd" %in% names(qwi_industry)) agg_expr$frmjbd <- ~sum(frmjbd, na.rm = TRUE)

  qwi_industry_agg <- qwi_industry %>%
    group_by(county_fips, year, quarter, industry_type) %>%
    summarise(!!!agg_expr, .groups = "drop") %>%
    mutate(
      log_emp = log(pmax(emp, 1)),
      log_earn = log(pmax(earn, 1))
    )

  # Merge with exposure panel
  industry_panel <- qwi_industry_agg %>%
    left_join(exposure_panel, by = c("county_fips" = "county_fips_1", "year", "quarter")) %>%
    left_join(centroids, by = c("county_fips" = "fips")) %>%
    left_join(
      state_mw_panel %>% select(state_fips, year, quarter, own_min_wage = min_wage, own_log_mw = log_min_wage),
      by = c("state_fips", "year", "quarter")
    ) %>%
    mutate(yearq = year + (quarter - 1) / 4) %>%
    left_join(communities, by = "county_fips")

  # Add backward-compatible aliases
  industry_panel <- industry_panel %>%
    mutate(
      network_mw_full = network_mw_pop,
      network_mw_out_state = network_mw_pop_out_state
    )

  saveRDS(industry_panel, "../data/industry_panel.rds")
  cat("  Industry panel observations:", format(nrow(industry_panel), big.mark = ","), "\n")
  cat("  High Bite obs:", sum(industry_panel$industry_type == "High Bite", na.rm = TRUE), "\n")
  cat("  Low Bite obs:", sum(industry_panel$industry_type == "Low Bite", na.rm = TRUE), "\n")
} else {
  cat("  No industry data available; skipping industry panel\n")
}

cat("\nFiles saved:\n")
cat("  - analysis_panel.rds\n")
cat("  - state_mw_panel.rds\n")
cat("  - exposure_panel.rds\n")
cat("  - network_communities.rds\n")
if (!is.null(qwi_industry) && nrow(qwi_industry) > 0) cat("  - industry_panel.rds\n")
