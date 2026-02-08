# =============================================================================
# 02_clean_data.R
# Clean QWI Data and Identify Border Counties
# =============================================================================

source("00_packages.R")

# =============================================================================
# Load Data
# =============================================================================

qwi <- readRDS("data/qwi_county_sex.rds")
cat("Loaded QWI data:", nrow(qwi), "observations\n")

# =============================================================================
# Identify Border Counties
# =============================================================================
# For the border discontinuity design, we need:
# 1. Counties that share a border with a county in a different state
# 2. One county in a treated state, one in a never-treated state

cat("\n=== Identifying Border Counties ===\n")

# Get county boundaries from tigris
counties_sf <- tigris::counties(cb = TRUE, year = 2020, progress_bar = FALSE) %>%
  st_transform(4326) %>%
  select(GEOID, STATEFP, NAME, geometry) %>%
  rename(county_fips = GEOID, state_fips = STATEFP, county_name = NAME)

# Find adjacent counties (share a border)
adj_matrix <- st_touches(counties_sf, sparse = TRUE)

# Convert to pairs
border_pairs <- list()
for (i in seq_len(nrow(counties_sf))) {
  neighbors <- adj_matrix[[i]]
  for (j in neighbors) {
    if (i < j) {
      pair <- c(counties_sf$county_fips[i], counties_sf$county_fips[j])
      state_i <- counties_sf$state_fips[i]
      state_j <- counties_sf$state_fips[j]
      if (state_i != state_j) {
        border_pairs[[length(border_pairs) + 1]] <- data.frame(
          county_a = pair[1],
          county_b = pair[2],
          state_a = state_i,
          state_b = state_j
        )
      }
    }
  }
}

border_pairs_df <- bind_rows(border_pairs)
cat("Found", nrow(border_pairs_df), "cross-state border county pairs\n")

# Add treatment status
treated_states <- c("08", "09", "32", "44", "06", "53")

border_pairs_df <- border_pairs_df %>%
  mutate(
    treat_a = state_a %in% treated_states,
    treat_b = state_b %in% treated_states,
    valid_pair = (treat_a & !treat_b) | (!treat_a & treat_b)
  ) %>%
  filter(valid_pair) %>%
  mutate(
    treated_county = if_else(treat_a, county_a, county_b),
    control_county = if_else(treat_a, county_b, county_a),
    treated_state = if_else(treat_a, state_a, state_b),
    control_state = if_else(treat_a, state_b, state_a)
  ) %>%
  select(treated_county, control_county, treated_state, control_state)

cat("Valid treated-control pairs:", nrow(border_pairs_df), "\n")

border_pairs_df$pair_id <- seq_len(nrow(border_pairs_df))

border_counties_long <- bind_rows(
  border_pairs_df %>%
    select(pair_id, county_fips = treated_county, treated_state, control_state) %>%
    mutate(side = "treated"),
  border_pairs_df %>%
    select(pair_id, county_fips = control_county, treated_state, control_state) %>%
    mutate(side = "control")
)

all_border_counties <- unique(c(border_pairs_df$treated_county,
                                 border_pairs_df$control_county))
cat("Total unique border counties:", length(all_border_counties), "\n")

# =============================================================================
# Merge Border Status into QWI Data
# =============================================================================

qwi_analysis <- qwi %>%
  mutate(is_border_county = county_fips %in% all_border_counties)

qwi_border <- qwi_analysis %>%
  inner_join(border_counties_long, by = "county_fips", relationship = "many-to-many")

cat("\n=== Border Sample Summary ===\n")
cat("Full sample observations:", nrow(qwi_analysis), "\n")
cat("Border sample observations:", nrow(qwi_border), "\n")
cat("Border county-pairs:", max(qwi_border$pair_id), "\n")

# =============================================================================
# Add Log Earnings
# =============================================================================

qwi_analysis <- qwi_analysis %>%
  mutate(
    log_earn_hire = log(EarnHirAS),
    log_earn = log(EarnS)
  )

qwi_border <- qwi_border %>%
  mutate(
    log_earn_hire = log(EarnHirAS),
    log_earn = log(EarnS)
  )

# =============================================================================
# Summary Statistics
# =============================================================================

cat("\n=== Summary Statistics ===\n")

qwi_analysis %>%
  group_by(treated_state, sex_label) %>%
  summarise(
    mean_earn_hire = mean(EarnHirAS, na.rm = TRUE),
    sd_earn_hire = sd(EarnHirAS, na.rm = TRUE),
    n_counties = n_distinct(county_fips),
    n_obs = n(),
    .groups = "drop"
  ) %>%
  print()

# =============================================================================
# Save Cleaned Data
# =============================================================================

saveRDS(qwi_analysis, "data/qwi_analysis.rds")
saveRDS(qwi_border, "data/qwi_border.rds")
saveRDS(border_pairs_df, "data/border_pairs.rds")

cat("\n=== Saved Files ===\n")
cat("data/qwi_analysis.rds - Full analysis sample\n")
cat("data/qwi_border.rds - Border county sample\n")
cat("data/border_pairs.rds - Border pair definitions\n")
