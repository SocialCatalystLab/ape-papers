# ============================================================================
# 02_clean_data.R
# Swedish School Transport (Skolskjuts) and Educational Equity
# Data cleaning and processing
# ============================================================================

source("00_packages.R")

# ============================================================================
# 1. LOAD RAW DATA
# ============================================================================

cat("\n=== Loading raw data ===\n")

# Kolada educational outcomes - reload from long format and pivot correctly
kolada_long <- read_csv("../data/raw/kolada_long.csv", show_col_types = FALSE)
cat("  Kolada long:", nrow(kolada_long), "rows\n")

# For merit points (N15504, N15505, N15506, N15507, N15566), use gender=T (total)
# If no T available, take any value
kolada_wide <- kolada_long |>
  # Prefer "T" (total) but accept any if T not available
  group_by(municipality_id, year, kpi) |>
  summarise(
    value = value[gender == "T"][1] %||% value[1],
    .groups = "drop"
  ) |>
  pivot_wider(names_from = kpi, values_from = value)

cat("  Kolada wide:", nrow(kolada_wide), "municipality-year observations\n")

# Municipality metadata
municipalities <- read_csv("../data/raw/municipalities.csv", show_col_types = FALSE)
cat("  Municipalities:", nrow(municipalities), "units\n")

# Schools
schools <- read_csv("../data/raw/schools_grundskola.csv", show_col_types = FALSE)
cat("  Schools:", nrow(schools), "grundskola units\n")

# Load geographic data if available
if (file.exists("../data/raw/deso_boundaries.gpkg")) {
  deso_sf <- st_read("../data/raw/deso_boundaries.gpkg", quiet = TRUE)
  cat("  DeSO boundaries:", nrow(deso_sf), "areas\n")
} else {
  cat("  DeSO boundaries: NOT AVAILABLE\n")
  deso_sf <- NULL
}

if (file.exists("../data/raw/kommun_boundaries.gpkg")) {
  kommun_sf <- st_read("../data/raw/kommun_boundaries.gpkg", quiet = TRUE)
  cat("  Municipality boundaries:", nrow(kommun_sf), "areas\n")
} else {
  cat("  Municipality boundaries: NOT AVAILABLE\n")
  kommun_sf <- NULL
}

# ============================================================================
# 2. CLEAN MUNICIPALITY DATA
# ============================================================================

cat("\n=== Cleaning municipality data ===\n")

# Standardize municipality IDs (should be 4-digit codes)
municipalities <- municipalities |>
  mutate(
    municipality_id = str_pad(municipality_id, 4, pad = "0"),
    # Extract county code (first 2 digits)
    county_code = str_sub(municipality_id, 1, 2)
  )

# Add county names
county_names <- tribble(
  ~county_code, ~county_name,
  "01", "Stockholm",
  "03", "Uppsala",
  "04", "Södermanland",
  "05", "Östergötland",
  "06", "Jönköping",
  "07", "Kronoberg",
  "08", "Kalmar",
  "09", "Gotland",
  "10", "Blekinge",
  "12", "Skåne",
  "13", "Halland",
  "14", "Västra Götaland",
  "17", "Värmland",
  "18", "Örebro",
  "19", "Västmanland",
  "20", "Dalarna",
  "21", "Gävleborg",
  "22", "Västernorrland",
  "23", "Jämtland",
  "24", "Västerbotten",
  "25", "Norrbotten"
)

municipalities <- municipalities |>
  left_join(county_names, by = "county_code")

cat("  Added county information to", nrow(municipalities), "municipalities\n")

# ============================================================================
# 3. CLEAN SCHOOL DATA (from OSM since Skolverket API returned empty)
# ============================================================================

cat("\n=== Cleaning school data ===\n")

# Use OSM schools instead of empty Skolverket data
if (nrow(schools) == 0 && file.exists("../data/raw/osm_schools.csv")) {
  cat("  Using OSM school data (Skolverket API returned empty)\n")
  osm_schools <- read_csv("../data/raw/osm_schools.csv", show_col_types = FALSE)

  schools <- osm_schools |>
    mutate(
      school_id = osm_id,
      school_name = name,
      school_type = case_when(
        str_detect(tolower(operator %||% ""), "kommun") ~ "Municipal",
        str_detect(tolower(operator %||% ""), "friskola|privat") ~ "Private (friskola)",
        TRUE ~ "Unknown"
      ),
      coord_suspicious = is.na(latitude) | is.na(longitude),
      full_address = paste(
        coalesce(addr_street, ""),
        coalesce(addr_postcode, ""),
        coalesce(addr_city, ""),
        "Sweden",
        sep = ", "
      )
    )

  cat("  Loaded", nrow(schools), "schools from OSM\n")
} else if (nrow(schools) > 0) {
  # Original Skolverket data processing
  schools <- schools |>
    mutate(
      municipality_id = str_pad(municipality_id, 4, pad = "0"),
      school_type = case_when(
        principal_type == "1" ~ "Municipal",
        principal_type == "2" ~ "Private (friskola)",
        principal_type == "3" ~ "State",
        TRUE ~ "Other"
      ),
      coord_suspicious = is.na(latitude) | is.na(longitude),
      full_address = paste(address_street, address_postal, address_city, "Sweden", sep = ", ")
    )
}

# Summary of schools by type
if (nrow(schools) > 0) {
  school_summary <- schools |>
    count(school_type, name = "n_schools") |>
    mutate(pct = n_schools / sum(n_schools) * 100)

  cat("  School types:\n")
  print(school_summary)

  # Count schools needing geocoding
  n_suspicious <- sum(schools$coord_suspicious, na.rm = TRUE)
  cat("  Schools needing geocoding:", n_suspicious, "\n")
} else {
  cat("  WARNING: No school data available\n")
}

# ============================================================================
# 4. CLEAN KOLADA OUTCOMES
# ============================================================================

cat("\n=== Cleaning educational outcomes ===\n")

# Check what columns we have
cat("  Available KPI columns:", paste(setdiff(names(kolada_wide), c("municipality_id", "year")), collapse = ", "), "\n")

# Simple rename using rename_with
kolada_clean <- kolada_wide |>
  rename_with(~case_when(
    .x == "N15504" ~ "merit_all",
    .x == "N15505" ~ "merit_municipal",
    .x == "N15506" ~ "merit_friskola",
    .x == "N15507" ~ "merit_home",
    .x == "N15566" ~ "merit_excl_new",
    .x == "U15415" ~ "salsa_expected",
    .x == "U15416" ~ "salsa_deviation",
    .x == "N15030" ~ "teachers_qualified",
    .x == "N15033" ~ "student_teacher_ratio",
    .x == "N07531" ~ "school_access_2km",
    TRUE ~ .x
  )) |>
  mutate(
    municipality_id = str_pad(municipality_id, 4, pad = "0")
  )

# Create derived variables only if source columns exist
if ("merit_friskola" %in% names(kolada_clean) && "merit_municipal" %in% names(kolada_clean)) {
  kolada_clean <- kolada_clean |>
    mutate(friskola_premium = merit_friskola - merit_municipal)
}

if ("salsa_deviation" %in% names(kolada_clean)) {
  kolada_clean <- kolada_clean |>
    mutate(above_expected = salsa_deviation > 0)
}

# Summary statistics
cat("\n  Merit point summary (2023):\n")
kolada_2023 <- kolada_clean |> filter(year == 2023)
cat(sprintf("    All schools: mean=%.1f, sd=%.1f\n",
            mean(kolada_2023$merit_all, na.rm = TRUE),
            sd(kolada_2023$merit_all, na.rm = TRUE)))
cat(sprintf("    Municipal: mean=%.1f, sd=%.1f\n",
            mean(kolada_2023$merit_municipal, na.rm = TRUE),
            sd(kolada_2023$merit_municipal, na.rm = TRUE)))
cat(sprintf("    Friskola: mean=%.1f, sd=%.1f\n",
            mean(kolada_2023$merit_friskola, na.rm = TRUE),
            sd(kolada_2023$merit_friskola, na.rm = TRUE)))

# ============================================================================
# 5. PROCESS GEOGRAPHIC DATA
# ============================================================================

if (!is.null(deso_sf)) {
  cat("\n=== Processing DeSO boundaries ===\n")

  # Ensure consistent CRS (SWEREF99 TM - EPSG:3006)
  deso_sf <- deso_sf |>
    st_transform(3006)

  # Calculate centroids for distance calculations
  deso_centroids <- deso_sf |>
    st_centroid() |>
    mutate(
      centroid_x = st_coordinates(geometry)[,1],
      centroid_y = st_coordinates(geometry)[,2]
    )

  # Extract municipality code from DeSO code
  # DeSO codes are structured as: KOMMUN (4 digits) + sequence
  deso_df <- deso_sf |>
    st_drop_geometry() |>
    mutate(
      # DeSO code format varies - extract municipality from first 4 digits
      municipality_id = str_sub(deso, 1, 4)
    )

  cat("  Processed", nrow(deso_sf), "DeSO areas\n")
  cat("  Spanning", n_distinct(deso_df$municipality_id), "municipalities\n")
}

if (!is.null(kommun_sf)) {
  cat("\n=== Processing municipality boundaries ===\n")

  kommun_sf <- kommun_sf |>
    st_transform(3006)

  cat("  Processed", nrow(kommun_sf), "municipality boundaries\n")
}

# ============================================================================
# 6. CREATE SCHOOL COORDINATES (valid only)
# ============================================================================

cat("\n=== Creating school coordinate dataset ===\n")

schools_with_coords <- schools |>
  filter(!coord_suspicious) |>
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326) |>
  st_transform(3006)  # Transform to Swedish coordinate system

cat("  Schools with valid coordinates:", nrow(schools_with_coords), "\n")
cat("  Schools needing geocoding:", nrow(schools) - nrow(schools_with_coords), "\n")

# ============================================================================
# 7. MANUAL SKOLSKJUTS THRESHOLD DATA
# ============================================================================

cat("\n=== Creating skolskjuts threshold data ===\n")

# Based on web research, create threshold database
# Source: Municipal websites (manual collection)
# Format: threshold in km for each grade range

# Sample of municipalities with documented thresholds
skolskjuts_thresholds <- tribble(
  ~municipality_id, ~municipality_name, ~threshold_F3_km, ~threshold_46_km, ~threshold_79_km, ~source,
  "0114", "Upplands Väsby", 2.0, 3.0, 4.0, "Municipal website",
  "0180", "Stockholm", 2.0, 3.0, 4.0, "Municipal website",
  "0480", "Nyköping", 2.0, 3.0, 4.0, "Municipal website",
  "0580", "Linköping", 2.0, 2.0, 2.0, "Municipal website",
  "0680", "Jönköping", 2.0, 3.0, 4.0, "Municipal website",
  "0880", "Kalmar", 2.0, 3.0, 4.0, "Municipal website",
  "1080", "Karlskrona", 2.0, 3.0, 4.0, "Municipal website",
  "1280", "Malmö", 2.0, 3.0, 4.0, "Municipal website",
  "1380", "Halmstad", 2.0, 3.0, 4.0, "Municipal website",
  "1480", "Göteborg", 2.0, 3.0, 4.0, "Municipal website",
  "1880", "Örebro", 2.0, 3.0, 4.0, "Municipal website",
  "2180", "Gävle", 2.0, 3.0, 4.0, "Municipal website",
  "2480", "Umeå", 2.0, 3.0, 4.0, "Municipal website",
  "2580", "Luleå", 2.0, 3.0, 4.0, "Municipal website",
  "0483", "Katrineholm", 3.0, 3.0, 4.0, "Municipal website",  # Note: stricter for F-3
  "0136", "Haninge", 2.0, 4.0, 4.0, "Municipal website",  # Note: 4km for grades 3-6
  "1383", "Varberg", 2.0, 3.0, 4.0, "Municipal website",
  "1281", "Lund", 2.0, 3.0, 4.0, "Municipal website",
  "0184", "Solna", 2.0, 3.0, 4.0, "Municipal website",
  "0186", "Lidingö", 2.0, 3.0, 4.0, "Municipal website"
)

# For municipalities without documented thresholds, use modal values
default_thresholds <- tibble(
  threshold_F3_km = 2.0,
  threshold_46_km = 3.0,
  threshold_79_km = 4.0
)

cat("  Documented thresholds for", nrow(skolskjuts_thresholds), "municipalities\n")
cat("  Default thresholds: F-3 = 2km, 4-6 = 3km, 7-9 = 4km\n")

# ============================================================================
# 8. MERGE AND SAVE PROCESSED DATA
# ============================================================================

cat("\n=== Saving processed data ===\n")

# Save cleaned datasets
write_csv(municipalities, "../data/processed/municipalities_clean.csv")
write_csv(schools, "../data/processed/schools_clean.csv")
write_csv(kolada_clean, "../data/processed/educational_outcomes.csv")
write_csv(skolskjuts_thresholds, "../data/processed/skolskjuts_thresholds.csv")

if (exists("schools_with_coords")) {
  st_write(schools_with_coords, "../data/processed/schools_geocoded.gpkg",
           delete_dsn = TRUE, quiet = TRUE)
}

if (!is.null(deso_sf)) {
  st_write(deso_sf, "../data/processed/deso_processed.gpkg",
           delete_dsn = TRUE, quiet = TRUE)
}

if (!is.null(kommun_sf)) {
  st_write(kommun_sf, "../data/processed/kommun_processed.gpkg",
           delete_dsn = TRUE, quiet = TRUE)
}

# Create analysis-ready dataset
analysis_data <- kolada_clean |>
  left_join(municipalities, by = "municipality_id") |>
  left_join(skolskjuts_thresholds |> select(-municipality_name, -source),
            by = "municipality_id")

# Fill in default thresholds for missing municipalities
analysis_data <- analysis_data |>
  mutate(
    threshold_F3_km = coalesce(threshold_F3_km, 2.0),
    threshold_46_km = coalesce(threshold_46_km, 3.0),
    threshold_79_km = coalesce(threshold_79_km, 4.0)
  )

write_csv(analysis_data, "../data/processed/analysis_panel.csv")

cat("\nProcessed data files:\n")
processed_files <- list.files("../data/processed", full.names = FALSE)
for (f in processed_files) {
  size <- file.size(paste0("../data/processed/", f))
  cat(sprintf("  %s (%.1f KB)\n", f, size / 1024))
}

cat("\nData cleaning complete.\n")
