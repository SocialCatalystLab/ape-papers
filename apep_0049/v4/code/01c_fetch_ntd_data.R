# ============================================================================
# APEP-0049 v4 - Transit Funding Discontinuity
# 01c_fetch_ntd_data.R - Fetch NTD transit service data for heterogeneity
#
# Downloads NTD Annual Database from data.transportation.gov (Socrata API)
# to identify UZAs with existing transit service and measure service levels.
#
# Transit agency presence is highly persistent: agencies reporting to NTD
# in recent years almost always had operations as of 2010 as well.
#
# Key output: data/ntd_uza_service.csv with UZA-level transit metrics
# ============================================================================

# Source packages
if (file.exists("00_packages.R")) {
  source("00_packages.R")
} else if (file.exists("code/00_packages.R")) {
  source("code/00_packages.R")
} else {
  stop("Cannot find 00_packages.R - run from code/ directory or paper root")
}

# ============================================================================
# 1. FETCH NTD SERVICE DATA FROM SOCRATA
# ============================================================================

cat("=== Fetching NTD Transit Service Data ===\n")
cat("Source: NTD Annual Data via data.transportation.gov\n\n")

# The NTD Annual Data View (Service by Agency) is available on Socrata
# Dataset ID: 6y83-7vuw
# Contains: Agency-level service metrics with UZA identifiers

ntd_url <- "https://data.transportation.gov/resource/6y83-7vuw.csv"

# Fetch data for available years
all_ntd <- list()

for (yr in c(2022, 2023, 2024)) {
  cat(sprintf("Fetching NTD %d...\n", yr))

  resp <- tryCatch(
    GET(ntd_url, query = list(
      report_year = as.character(yr),
      `$limit` = 5000
    ), timeout(30)),
    error = function(e) NULL
  )

  if (!is.null(resp) && status_code(resp) == 200) {
    df <- read_csv(content(resp, "text"), show_col_types = FALSE)
    cat(sprintf("  Records: %d agencies\n", nrow(df)))
    all_ntd[[as.character(yr)]] <- df
  } else {
    cat(sprintf("  Failed (status %s)\n",
                ifelse(is.null(resp), "error", status_code(resp))))
  }
}

if (length(all_ntd) == 0) {
  stop("Failed to download any NTD data.")
}

# Use the earliest available year for stability
ntd_data <- all_ntd[[1]]  # Use first successful year
ntd_year <- names(all_ntd)[1]
cat(sprintf("\nUsing NTD %s data (%d agencies)\n", ntd_year, nrow(ntd_data)))

# ============================================================================
# 2. AGGREGATE TO UZA LEVEL
# ============================================================================

cat("\n=== Aggregating to UZA Level ===\n")

uza_service <- ntd_data %>%
  mutate(
    uza_code = max_primary_uza_code,
    uza_name = max_primary_uza_name,
    uza_pop = as.numeric(max_primary_uza_population),
    vrm = as.numeric(sum_actual_vehicles_passenger_car_revenue_miles),
    upt = as.numeric(sum_unlinked_passenger_trips_upt),
    voms = as.numeric(max_agency_voms),
    drm = as.numeric(sum_directional_route_miles)
  ) %>%
  filter(!is.na(uza_code), uza_code != "") %>%
  group_by(uza_code, uza_name) %>%
  summarise(
    uza_pop = first(uza_pop),
    n_agencies = n(),
    total_vrm = sum(vrm, na.rm = TRUE),
    total_upt = sum(upt, na.rm = TRUE),
    total_voms = sum(voms, na.rm = TRUE),
    total_drm = sum(drm, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    has_transit = total_voms > 0 | total_upt > 0,
    vrm_per_capita = ifelse(uza_pop > 0, total_vrm / uza_pop, NA_real_),
    upt_per_capita = ifelse(uza_pop > 0, total_upt / uza_pop, NA_real_),
    # Size classification
    near_threshold = abs(uza_pop - 50000) <= 25000
  )

cat("UZAs with NTD-reporting agencies:", nrow(uza_service), "\n")
cat("UZAs with active transit (VOMS > 0):", sum(uza_service$has_transit), "\n")
cat("Near threshold (25k-75k):", sum(uza_service$near_threshold, na.rm = TRUE), "\n")

# ============================================================================
# 3. CREATE MATCHING KEY FOR CENSUS DATA
# ============================================================================

cat("\n=== Preparing for Census Match ===\n")

uza_service <- uza_service %>%
  mutate(
    # Create match key from UZA name
    name_clean = str_remove(uza_name, ",.*$"),
    match_key = str_to_lower(name_clean),
    match_key = str_remove(match_key, "-.*$"),
    match_key = str_trim(match_key)
  )

# ============================================================================
# 4. MATCH TO CENSUS ANALYSIS DATA
# ============================================================================

ua_data <- read_csv(file.path(data_dir, "ua_analysis.csv"), show_col_types = FALSE)

ua_data <- ua_data %>%
  mutate(
    census_city = str_remove(name_clean, ",.*$"),
    match_key = str_to_lower(census_city),
    match_key = str_remove(match_key, "-.*$"),
    match_key = str_trim(match_key)
  )

# Match NTD service data to Census UZAs
ua_with_ntd <- ua_data %>%
  left_join(
    uza_service %>% select(match_key, n_agencies, total_vrm, total_upt,
                           total_voms, total_drm, has_transit,
                           vrm_per_capita, upt_per_capita),
    by = "match_key"
  ) %>%
  mutate(
    # For UZAs not in NTD data, they have no transit agencies
    has_transit = ifelse(is.na(has_transit), FALSE, has_transit),
    n_agencies = ifelse(is.na(n_agencies), 0, n_agencies),
    total_voms = ifelse(is.na(total_voms), 0, total_voms)
  )

# Summary
matched_transit <- sum(ua_with_ntd$has_transit & ua_with_ntd$eligible_5307 == 1)
total_eligible <- sum(ua_with_ntd$eligible_5307 == 1)

cat("Eligible UZAs with transit agencies:", matched_transit, "of", total_eligible, "\n")
cat("Eligible UZAs WITHOUT transit agencies:", total_eligible - matched_transit, "\n")

# Near threshold breakdown
near <- ua_with_ntd %>% filter(abs(running_var) <= 25000)
cat("\nNear threshold (25k-75k):\n")
cat("  With transit:", sum(near$has_transit), "\n")
cat("  Without transit:", sum(!near$has_transit), "\n")
cat("  Above threshold with transit:", sum(near$has_transit & near$eligible_5307 == 1), "\n")
cat("  Below threshold with transit:", sum(near$has_transit & near$eligible_5307 == 0), "\n")

# ============================================================================
# 5. SAVE
# ============================================================================

cat("\n=== Saving NTD Data ===\n")

# Save UZA-level NTD service data
write_csv(uza_service, file.path(data_dir, "ntd_uza_service.csv"))

# Save matched analysis data
write_csv(
  ua_with_ntd %>% select(-census_city, -match_key),
  file.path(data_dir, "ua_analysis_with_ntd.csv")
)

cat("Files saved:\n")
cat("  - ntd_uza_service.csv (UZA-level NTD service metrics)\n")
cat("  - ua_analysis_with_ntd.csv (analysis sample with NTD transit indicators)\n")

cat("\n=== NTD Data Fetch Complete ===\n")
