# ============================================================================
# 03_main_analysis.R
# Swedish School Transport (Skolskjuts) and Educational Equity
# Main RDD analysis
# ============================================================================

source("00_packages.R")

# ============================================================================
# 1. LOAD PROCESSED DATA
# ============================================================================

cat("\n=== Loading processed data ===\n")

# Load analysis panel
analysis_panel <- read_csv("../data/processed/analysis_panel.csv", show_col_types = FALSE)
cat("  Analysis panel:", nrow(analysis_panel), "municipality-year observations\n")

# Load school data
schools <- read_csv("../data/processed/schools_clean.csv", show_col_types = FALSE)
cat("  Schools:", nrow(schools), "units\n")

# Load geographic data if available
deso_exists <- file.exists("../data/processed/deso_processed.gpkg")
kommun_exists <- file.exists("../data/processed/kommun_processed.gpkg")
schools_geo_exists <- file.exists("../data/processed/schools_geocoded.gpkg")

if (deso_exists) {
  deso_sf <- st_read("../data/processed/deso_processed.gpkg", quiet = TRUE)
  cat("  DeSO boundaries: loaded\n")
}

if (kommun_exists) {
  kommun_sf <- st_read("../data/processed/kommun_processed.gpkg", quiet = TRUE)
  cat("  Municipality boundaries: loaded\n")
}

if (schools_geo_exists) {
  schools_sf <- st_read("../data/processed/schools_geocoded.gpkg", quiet = TRUE)
  cat("  Geocoded schools: loaded\n")
}

# ============================================================================
# 2. CONSTRUCT DISTANCE-BASED TREATMENT ASSIGNMENT
# ============================================================================

cat("\n=== Constructing distance-based treatment ===\n")

# Since we don't have individual student addresses, we'll use two approaches:
# Approach A: Municipality-level analysis using school accessibility KPI
# Approach B: DeSO-level analysis (if geodata available)

# Approach A: Use N07531 (% children within 2km of school) as proxy for treatment
analysis_panel <- analysis_panel |>
  mutate(
    # Create treatment intensity based on school accessibility
    high_accessibility = school_access_2km > median(school_access_2km, na.rm = TRUE),
    # Inverse: low accessibility means students are more likely to be eligible for skolskjuts
    skolskjuts_likely = 100 - school_access_2km,
    # Centered running variable (distance proxy)
    dist_from_median = school_access_2km - median(school_access_2km, na.rm = TRUE)
  )

cat("  Treatment constructed based on school accessibility\n")
cat("  Median accessibility:", median(analysis_panel$school_access_2km, na.rm = TRUE), "%\n")

# ============================================================================
# 3. APPROACH A: MUNICIPALITY-LEVEL SHARP RDD
# ============================================================================

cat("\n=== Municipality-Level RDD Analysis ===\n")

# Focus on most recent year with complete data
analysis_2023 <- analysis_panel |>
  filter(year == 2023) |>
  filter(!is.na(merit_all) & !is.na(school_access_2km))

cat("  Observations for 2023:", nrow(analysis_2023), "municipalities\n")

# RDD with school accessibility as running variable
# Higher accessibility = less likely to need transport = "control"
# Lower accessibility = more likely to need transport = "treatment"

# Define cutoff at median accessibility
cutoff_accessibility <- 50  # 50% of children within 2km

# Create centered running variable
analysis_2023 <- analysis_2023 |>
  mutate(
    running_var = school_access_2km - cutoff_accessibility,
    treated = school_access_2km < cutoff_accessibility  # Below 50% = likely needs transport
  )

# Basic RDD estimation using rdrobust
if (nrow(analysis_2023 |> filter(!is.na(merit_all))) > 50) {

  cat("\n  Estimating RDD for merit points...\n")

  rdd_merit <- rdrobust(
    y = analysis_2023$merit_all,
    x = analysis_2023$running_var,
    c = 0,
    kernel = "triangular",
    bwselect = "mserd"
  )

  cat("\n  === RDD Results: Merit Points ===\n")
  print(summary(rdd_merit))

  # Store results
  rdd_results_merit <- tibble(
    outcome = "Merit Points (All Schools)",
    estimate = rdd_merit$Estimate[1],
    se = rdd_merit$se[1],
    ci_lower = rdd_merit$ci[1],
    ci_upper = rdd_merit$ci[3],
    bandwidth = rdd_merit$bws[1],
    n_left = rdd_merit$N_h[1],
    n_right = rdd_merit$N_h[2],
    p_value = rdd_merit$pv[1]
  )

  # RDD for SALSA deviation
  rdd_salsa <- rdrobust(
    y = analysis_2023$salsa_deviation,
    x = analysis_2023$running_var,
    c = 0,
    kernel = "triangular",
    bwselect = "mserd"
  )

  cat("\n  === RDD Results: SALSA Deviation ===\n")
  print(summary(rdd_salsa))

  rdd_results_salsa <- tibble(
    outcome = "SALSA Deviation (Value Added)",
    estimate = rdd_salsa$Estimate[1],
    se = rdd_salsa$se[1],
    ci_lower = rdd_salsa$ci[1],
    ci_upper = rdd_salsa$ci[3],
    bandwidth = rdd_salsa$bws[1],
    n_left = rdd_salsa$N_h[1],
    n_right = rdd_salsa$N_h[2],
    p_value = rdd_salsa$pv[1]
  )

  # Combine results
  rdd_results <- bind_rows(rdd_results_merit, rdd_results_salsa)

} else {
  cat("  Insufficient observations for RDD\n")
  rdd_results <- tibble()
}

# ============================================================================
# 4. APPROACH B: DeSO-LEVEL ANALYSIS (if geodata available)
# ============================================================================

if (deso_exists && schools_geo_exists) {

  cat("\n=== DeSO-Level Analysis ===\n")

  # Calculate distance from each DeSO centroid to nearest municipal school
  deso_centroids <- deso_sf |>
    st_centroid()

  # Filter to municipal schools only
  municipal_schools <- schools_sf |>
    filter(school_type == "Municipal")

  cat("  Municipal schools:", nrow(municipal_schools), "\n")

  # Calculate distance to nearest school for each DeSO
  nearest_school <- st_nearest_feature(deso_centroids, municipal_schools)
  distances <- st_distance(deso_centroids, municipal_schools[nearest_school,], by_element = TRUE)

  deso_analysis <- deso_sf |>
    st_drop_geometry() |>
    mutate(
      dist_to_nearest_school_m = as.numeric(distances),
      dist_to_nearest_school_km = dist_to_nearest_school_m / 1000,
      # Treatment based on 2km threshold (F-3 grades)
      eligible_F3 = dist_to_nearest_school_km > 2.0,
      # Treatment based on 3km threshold (grades 4-6)
      eligible_46 = dist_to_nearest_school_km > 3.0,
      # Centered running variable for F-3 threshold
      running_var_F3 = dist_to_nearest_school_km - 2.0,
      running_var_46 = dist_to_nearest_school_km - 3.0
    )

  cat("  DeSOs with distance calculated:", nrow(deso_analysis), "\n")
  cat("  DeSOs eligible for skolskjuts (F-3, >2km):", sum(deso_analysis$eligible_F3), "\n")
  cat("  DeSOs eligible for skolskjuts (4-6, >3km):", sum(deso_analysis$eligible_46), "\n")

  # Summary statistics
  cat("\n  Distance distribution:\n")
  cat(sprintf("    Mean: %.2f km\n", mean(deso_analysis$dist_to_nearest_school_km)))
  cat(sprintf("    Median: %.2f km\n", median(deso_analysis$dist_to_nearest_school_km)))
  cat(sprintf("    SD: %.2f km\n", sd(deso_analysis$dist_to_nearest_school_km)))
  cat(sprintf("    Range: %.2f - %.2f km\n",
              min(deso_analysis$dist_to_nearest_school_km),
              max(deso_analysis$dist_to_nearest_school_km)))

  # Save DeSO-level analysis data
  write_csv(deso_analysis, "../data/processed/deso_analysis.csv")

} else {
  cat("\n  DeSO-level analysis skipped (geodata not available)\n")
}

# ============================================================================
# 5. HETEROGENEITY BY MUNICIPALITY TYPE
# ============================================================================

cat("\n=== Heterogeneity Analysis ===\n")

# Classify municipalities by urbanity
analysis_2023 <- analysis_2023 |>
  mutate(
    urban_type = case_when(
      municipality_name %in% c("Stockholm", "Göteborg", "Malmö") ~ "Major City",
      school_access_2km > 75 ~ "Urban",
      school_access_2km > 50 ~ "Suburban",
      TRUE ~ "Rural"
    )
  )

# Summary by urban type
urban_summary <- analysis_2023 |>
  group_by(urban_type) |>
  summarise(
    n = n(),
    mean_merit = mean(merit_all, na.rm = TRUE),
    mean_accessibility = mean(school_access_2km, na.rm = TRUE),
    .groups = "drop"
  )

cat("\n  Summary by municipality type:\n")
print(urban_summary)

# ============================================================================
# 6. MANIPULATION TEST
# ============================================================================

cat("\n=== Manipulation Test ===\n")

if (nrow(analysis_2023) > 30) {
  manip_test <- rddensity(
    X = analysis_2023$running_var,
    c = 0
  )

  cat("\n  McCrary Density Test:\n")
  cat(sprintf("    Test statistic: %.3f\n", manip_test$test$t_jk))
  cat(sprintf("    P-value: %.4f\n", manip_test$test$p_jk))

  if (manip_test$test$p_jk > 0.05) {
    cat("    Result: No evidence of manipulation (p > 0.05)\n")
  } else {
    cat("    Result: Potential manipulation detected (p < 0.05)\n")
  }
}

# ============================================================================
# 7. SAVE RESULTS
# ============================================================================

cat("\n=== Saving results ===\n")

# Save RDD results
if (nrow(rdd_results) > 0) {
  write_csv(rdd_results, "../tables/rdd_main_results.csv")
  cat("  Main RDD results saved\n")
}

# Save analysis data
write_csv(analysis_2023, "../data/processed/analysis_2023.csv")

# Save urban summary
write_csv(urban_summary, "../tables/urban_summary.csv")

cat("\nMain analysis complete.\n")
