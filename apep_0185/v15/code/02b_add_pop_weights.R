################################################################################
# 02b_add_pop_weights.R
# Social Network Minimum Wage Exposure - ADD POPULATION-WEIGHTED MEASURES
#
# This script takes the existing analysis_panel.rds (which has the probability-
# weighted exposure measures) and adds population-weighted measures.
#
# This is much faster than recomputing everything from scratch.
################################################################################

source("00_packages.R")

cat("=== Adding Population-Weighted Exposure to Existing Panel ===\n\n")

# ============================================================================
# 1. Load Existing Data
# ============================================================================

cat("1. Loading existing analysis panel...\n")

panel <- readRDS("../data/analysis_panel.rds")
sci_raw <- readRDS("../data/raw_sci.rds")
centroids <- readRDS("../data/raw_county_centroids.rds")
state_mw_panel <- readRDS("../data/state_mw_panel.rds")

cat("  Panel observations:", format(nrow(panel), big.mark = ","), "\n")
cat("  SCI pairs:", format(nrow(sci_raw), big.mark = ","), "\n")

# ============================================================================
# 2. Compute County Population Proxy (from employment)
# ============================================================================

cat("\n2. Computing county population proxies (pre-treatment 2012-2013 employment)...\n")

# Use ONLY pre-treatment employment (2012-2013) to ensure predetermined shares
# per Borusyak et al. (2022) shocks-based identification requirement
county_pop <- panel %>%
  filter(year %in% c(2012, 2013)) %>%
  group_by(county_fips) %>%
  summarise(pop_proxy = mean(emp, na.rm = TRUE), .groups = "drop")

cat("  Computed pre-treatment population proxy for", nrow(county_pop), "counties\n")
cat("  Using pre-treatment years: 2012-2013\n")
cat("  Population range: [", round(min(county_pop$pop_proxy, na.rm = TRUE), 0),
    ", ", round(max(county_pop$pop_proxy, na.rm = TRUE), 0), "]\n", sep = "")

# ============================================================================
# 3. Construct Population-Weighted SCI Weights
# ============================================================================

cat("\n3. Constructing population-weighted SCI weights...\n")

# Add state FIPS to SCI data
sci <- as_tibble(sci_raw) %>%
  mutate(
    state_fips_1 = substr(county_fips_1, 1, 2),
    state_fips_2 = substr(county_fips_2, 1, 2)
  )

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

cat("  Full network (pop-weighted) pairs:", format(nrow(sci_pop_full), big.mark = ","), "\n")

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

cat("  Cross-state (pop-weighted) pairs:", format(nrow(sci_pop_cross), big.mark = ","), "\n")

# ============================================================================
# 4. Compute Population-Weighted Exposure for Each County-Quarter
# ============================================================================

cat("\n4. Computing population-weighted exposure for each county-quarter...\n")

# Get unique time periods
time_periods <- panel %>%
  select(year, quarter) %>%
  distinct() %>%
  arrange(year, quarter)

# Function to compute pop-weighted exposure for a time period
compute_pop_exposure <- function(yr, qtr) {

  # Get minimum wages for this quarter
  mw_this_q <- state_mw_panel %>%
    filter(year == yr, quarter == qtr) %>%
    select(state_fips, log_min_wage, min_wage)

  # POPULATION-WEIGHTED FULL NETWORK (main endogenous variable)
  pop_full_exp <- sci_pop_full %>%
    left_join(mw_this_q, by = c("state_fips_2" = "state_fips")) %>%
    group_by(county_fips_1) %>%
    summarise(
      network_mw_pop = sum(w_pop * log_min_wage, na.rm = TRUE),
      network_mw_pop_dollar = sum(w_pop * min_wage, na.rm = TRUE),
      .groups = "drop"
    )

  # POPULATION-WEIGHTED OUT-OF-STATE (main IV)
  pop_cross_exp <- sci_pop_cross %>%
    left_join(mw_this_q, by = c("state_fips_2" = "state_fips")) %>%
    group_by(county_fips_1) %>%
    summarise(
      network_mw_pop_out_state = sum(w_pop * log_min_wage, na.rm = TRUE),
      network_mw_pop_out_state_dollar = sum(w_pop * min_wage, na.rm = TRUE),
      .groups = "drop"
    )

  # Merge
  exposure <- pop_full_exp %>%
    left_join(pop_cross_exp, by = "county_fips_1") %>%
    mutate(year = yr, quarter = qtr)

  return(exposure)
}

cat("  Computing exposures for", nrow(time_periods), "quarters...\n")
exposure_list <- list()

for (i in 1:nrow(time_periods)) {
  if (i %% 10 == 0) cat("  Quarter", i, "/", nrow(time_periods), "\n")
  exposure_list[[i]] <- compute_pop_exposure(time_periods$year[i], time_periods$quarter[i])
}

pop_exposure_panel <- bind_rows(exposure_list)
cat("  Created pop-weighted exposure panel with",
    format(nrow(pop_exposure_panel), big.mark = ","), "county-quarter obs\n")

# ============================================================================
# 5. Merge Pop-Weighted Exposure into Main Panel
# ============================================================================

cat("\n5. Merging pop-weighted exposure into main panel...\n")

# Drop old pop-weighted columns if they exist (from previous run with wrong weights)
old_pop_cols <- c("network_mw_pop", "network_mw_pop_dollar",
                  "network_mw_pop_out_state", "network_mw_pop_out_state_dollar",
                  "network_mw_full", "network_mw_out_state",
                  "social_exposure", "network_mw_full_prob",
                  "network_mw_out_state_prob")
existing_old <- intersect(old_pop_cols, names(panel))
if (length(existing_old) > 0) {
  cat("  Dropping", length(existing_old), "old pop-weighted columns to replace with corrected weights\n")
  panel <- panel %>% select(-all_of(existing_old))
}

# If prob-weighted columns don't exist but network_mw_prob does, skip rename
if (!"network_mw_prob" %in% names(panel)) {
  # Rename existing probability-weighted variables for clarity
  panel <- panel %>%
    rename(
      network_mw_prob = network_mw_full,
      network_mw_prob_out_state = network_mw_out_state
    )
}

# Merge new pop-weighted exposure (with corrected pre-treatment weights)
panel <- panel %>%
  left_join(
    pop_exposure_panel,
    by = c("county_fips" = "county_fips_1", "year", "quarter")
  )

# Create backward-compatible aliases
panel <- panel %>%
  mutate(
    # Main variables (population-weighted)
    network_mw_full = network_mw_pop,
    network_mw_out_state = network_mw_pop_out_state,
    social_exposure = network_mw_pop,

    # For backward compatibility with robustness code
    network_mw_full_prob = network_mw_prob,
    network_mw_out_state_prob = network_mw_prob_out_state
  )

cat("  Panel now has", ncol(panel), "columns\n")

# ============================================================================
# 6. Check Exposure Statistics
# ============================================================================

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

# ============================================================================
# 7. Save Updated Panel
# ============================================================================

cat("\n7. Saving updated analysis panel...\n")

saveRDS(panel, "../data/analysis_panel.rds")

cat("\nDone! Saved updated analysis_panel.rds with population-weighted exposure measures.\n")
