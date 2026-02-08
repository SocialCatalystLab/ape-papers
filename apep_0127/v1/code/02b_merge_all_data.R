# ============================================================================
# 02b_merge_all_data.R
# Swedish School Transport (Skolskjuts) and Educational Equity
# Merge all data sources
# ============================================================================

source("00_packages.R")

# ============================================================================
# 1. LOAD ALL DATA SOURCES
# ============================================================================

cat("\n=== Loading all data sources ===\n")

# Educational outcomes (2015-2016)
edu_outcomes <- read_csv("../data/processed/educational_outcomes.csv", show_col_types = FALSE)
cat("  Educational outcomes:", nrow(edu_outcomes), "rows\n")

# Car ownership and housing (2013-2014)
transport_housing <- read_csv("../data/raw/kolada_transport_housing_wide.csv", show_col_types = FALSE)
cat("  Transport/housing:", nrow(transport_housing), "rows\n")

# Municipality metadata
municipalities <- read_csv("../data/processed/municipalities_clean.csv", show_col_types = FALSE)
cat("  Municipalities:", nrow(municipalities), "rows\n")

# Skolskjuts thresholds
thresholds <- read_csv("../data/processed/skolskjuts_thresholds.csv", show_col_types = FALSE)
cat("  Thresholds:", nrow(thresholds), "rows\n")

# ============================================================================
# 2. PREPARE TRANSPORT/HOUSING DATA (use 2013 as baseline)
# ============================================================================

cat("\n=== Preparing transport/housing data ===\n")

# Use 2013 data as pre-treatment characteristics
th_2013 <- transport_housing |>
  filter(year == 2013) |>
  select(-year) |>
  # Standardize municipality ID
  mutate(municipality_id = str_pad(municipality_id, 4, pad = "0")) |>
  # Filter for real municipalities
  filter(str_detect(municipality_id, "^(0[1-9]|1[0-9]|2[0-5])"))

cat("  Transport/housing 2013:", nrow(th_2013), "municipalities\n")

# ============================================================================
# 3. MERGE ALL DATA
# ============================================================================

cat("\n=== Merging datasets ===\n")

# Start with educational outcomes
analysis_data <- edu_outcomes |>
  # Filter for years with data and real municipalities
  filter(year %in% c(2015, 2016)) |>
  filter(str_detect(municipality_id, "^(0[1-9]|1[0-9]|2[0-5])"))

cat("  Educational outcomes (filtered):", nrow(analysis_data), "rows\n")

# Add transport/housing (2013 baseline - pre-treatment)
analysis_data <- analysis_data |>
  left_join(
    th_2013 |> select(municipality_id, cars_per_1000, gasoline_cars_per_1000,
                      diesel_cars_per_1000, electric_cars_per_1000,
                      rental_housing_pct, coop_housing_pct, owner_housing_pct),
    by = "municipality_id"
  )

cat("  After transport/housing merge:", nrow(analysis_data), "rows\n")

# Add municipality metadata
analysis_data <- analysis_data |>
  left_join(
    municipalities |> select(municipality_id, municipality_name, county_code, county_name),
    by = "municipality_id"
  )

cat("  After municipality merge:", nrow(analysis_data), "rows\n")

# Add skolskjuts thresholds
analysis_data <- analysis_data |>
  left_join(
    thresholds |> select(municipality_id, threshold_F3_km, threshold_46_km, threshold_79_km),
    by = "municipality_id"
  ) |>
  # Fill in default thresholds
  mutate(
    threshold_F3_km = coalesce(threshold_F3_km, 2.0),
    threshold_46_km = coalesce(threshold_46_km, 3.0),
    threshold_79_km = coalesce(threshold_79_km, 4.0)
  )

cat("  After threshold merge:", nrow(analysis_data), "rows\n")

# ============================================================================
# 4. CREATE DERIVED VARIABLES
# ============================================================================

cat("\n=== Creating derived variables ===\n")

analysis_data <- analysis_data |>
  mutate(
    # Car ownership terciles
    car_ownership_tercile = ntile(cars_per_1000, 3),
    car_ownership_group = case_when(
      car_ownership_tercile == 1 ~ "Low car ownership",
      car_ownership_tercile == 2 ~ "Medium car ownership",
      car_ownership_tercile == 3 ~ "High car ownership"
    ),

    # Housing tenure dominant type
    housing_dominant = case_when(
      rental_housing_pct > coop_housing_pct & rental_housing_pct > owner_housing_pct ~ "Rental dominant",
      owner_housing_pct > rental_housing_pct & owner_housing_pct > coop_housing_pct ~ "Owner dominant",
      coop_housing_pct > rental_housing_pct & coop_housing_pct > owner_housing_pct ~ "Coop dominant",
      TRUE ~ "Mixed"
    ),

    # Urbanity proxy (based on car ownership - lower in urban areas)
    urban_proxy = case_when(
      cars_per_1000 < 400 ~ "Urban (low car)",
      cars_per_1000 < 500 ~ "Suburban",
      cars_per_1000 < 600 ~ "Semi-rural",
      TRUE ~ "Rural (high car)"
    ),

    # Rental share terciles (potential treatment intensity)
    rental_tercile = ntile(rental_housing_pct, 3),

    # Owner share terciles
    owner_tercile = ntile(owner_housing_pct, 3)
  )

# ============================================================================
# 5. SUMMARY STATISTICS
# ============================================================================

cat("\n=== Summary Statistics ===\n")

# Year coverage
cat("\nObservations by year:\n")
analysis_data |>
  count(year) |>
  print()

# Key variables
cat("\nKey variable means (2015):\n")
analysis_data |>
  filter(year == 2015) |>
  summarise(
    n = n(),
    mean_merit = mean(merit_excl_new, na.rm = TRUE),
    mean_cars = mean(cars_per_1000, na.rm = TRUE),
    mean_rental = mean(rental_housing_pct, na.rm = TRUE),
    mean_owner = mean(owner_housing_pct, na.rm = TRUE),
    mean_teachers = mean(teachers_qualified, na.rm = TRUE)
  ) |>
  print()

# By car ownership group
cat("\nMerit points by car ownership group (2015):\n")
analysis_data |>
  filter(year == 2015) |>
  group_by(car_ownership_group) |>
  summarise(
    n = n(),
    mean_merit = mean(merit_excl_new, na.rm = TRUE),
    mean_cars = mean(cars_per_1000, na.rm = TRUE),
    .groups = "drop"
  ) |>
  arrange(car_ownership_group) |>
  print()

# By housing dominant type
cat("\nMerit points by housing type (2015):\n")
analysis_data |>
  filter(year == 2015) |>
  group_by(housing_dominant) |>
  summarise(
    n = n(),
    mean_merit = mean(merit_excl_new, na.rm = TRUE),
    mean_rental = mean(rental_housing_pct, na.rm = TRUE),
    .groups = "drop"
  ) |>
  print()

# ============================================================================
# 6. SAVE MERGED DATA
# ============================================================================

cat("\n=== Saving merged data ===\n")

write_csv(analysis_data, "../data/processed/analysis_merged.csv")

cat("  Saved:", nrow(analysis_data), "observations\n")
cat("  Columns:", ncol(analysis_data), "\n")
cat("  File: ../data/processed/analysis_merged.csv\n")

cat("\nData merge complete.\n")
