# =============================================================================
# 01b_fetch_driver_data.R
# Fetch FARS Vehicle file to get driver license state (L_STATE)
# Then merge with existing crash analysis data
# =============================================================================

source("00_packages.R")

cat("Fetching FARS Vehicle data for driver license state...\n")
cat("===========================================================\n\n")

# Define study state FIPS codes
legal_fips <- c(6, 8, 32, 41, 53)       # CA, CO, NV, OR, WA
prohibition_fips <- c(4, 16, 20, 30, 31, 35, 49, 56)  # AZ, ID, KS, MT, NE, NM, UT, WY
all_fips <- c(legal_fips, prohibition_fips)

# Years to fetch
years <- 2016:2019

# =============================================================================
# Fetch vehicle-level data from NHTSA (contains L_STATE = driver license state)
# =============================================================================

vehicle_data_all <- data.frame()

for (yr in years) {
  cat(sprintf("Fetching %d vehicle data...\n", yr))

  csv_url <- sprintf(
    "https://static.nhtsa.gov/nhtsa/downloads/FARS/%d/National/FARS%dNationalCSV.zip",
    yr, yr
  )

  temp_zip <- tempfile(fileext = ".zip")
  temp_extract <- tempfile()

  tryCatch({
    download.file(csv_url, temp_zip, mode = "wb", quiet = TRUE)
    dir.create(temp_extract)
    unzip(temp_zip, exdir = temp_extract)

    # Read vehicle file (contains L_STATE = driver license state)
    vehicle_file <- list.files(temp_extract, pattern = "vehicle", ignore.case = TRUE,
                               full.names = TRUE, recursive = TRUE)[1]

    if (!is.na(vehicle_file) && file.exists(vehicle_file)) {
      vehicle_data <- read.csv(vehicle_file, stringsAsFactors = FALSE)
      names(vehicle_data) <- tolower(names(vehicle_data))

      # Filter to study states
      vehicle_data <- vehicle_data %>%
        filter(state %in% all_fips)

      # Select key columns for driver analysis
      key_cols <- c("state", "st_case", "veh_no", "l_state", "reg_stat",
                    "dr_drink", "dr_pres")
      available_cols <- key_cols[key_cols %in% names(vehicle_data)]

      vehicle_data <- vehicle_data %>%
        select(all_of(available_cols))

      if (nrow(vehicle_data) > 0) {
        vehicle_data$year <- yr
        vehicle_data_all <- bind_rows(vehicle_data_all, vehicle_data)
        cat(sprintf("  Found %d vehicle records with L_STATE\n", nrow(vehicle_data)))
      }
    }

    # Clean up
    unlink(temp_zip)
    unlink(temp_extract, recursive = TRUE)

  }, error = function(e) {
    cat(sprintf("  Error for %d: %s\n", yr, e$message))
  })

  Sys.sleep(1)
}

cat(sprintf("\nTotal vehicle records fetched: %d\n", nrow(vehicle_data_all)))

# =============================================================================
# Process driver license state information
# =============================================================================

if (nrow(vehicle_data_all) > 0) {
  cat("\nProcessing driver license states...\n")

  # L_STATE coding:
  # 1-56 = state FIPS, 60 = American Samoa, 64 = Federated States,
  # 66 = Guam, 70 = Palau, 72 = Puerto Rico, 78 = Virgin Islands,
  # 94 = Canadian, 95 = Mexican, 96 = other foreign, 97 = Indian nation,
  # 98 = US government, 99 = unknown

  # Create crash-level driver summary (primary vehicle = veh_no = 1)
  driver_license_lookup <- vehicle_data_all %>%
    filter(!is.na(l_state)) %>%
    filter(l_state > 0 & l_state <= 56) %>%  # Valid US state FIPS only
    # Take the first vehicle's driver for primary assignment
    # But also track all unique license states
    group_by(state, st_case, year) %>%
    summarise(
      # First vehicle driver's license state (often striking vehicle)
      driver_license_state = first(l_state),
      # All unique driver license states
      n_driver_states = n_distinct(l_state),
      all_driver_states = paste(unique(l_state), collapse = ","),
      # Any driver from legal state?
      any_legal_state_driver = any(l_state %in% legal_fips),
      # Any driver from prohibition state?
      any_prohib_state_driver = any(l_state %in% prohibition_fips),
      # Number of vehicles/drivers
      n_vehicles = n(),
      # Drinking status (from vehicle file)
      any_drinking = any(dr_drink > 0, na.rm = TRUE),
      .groups = "drop"
    )

  cat(sprintf("Created driver license lookup with %d crash records.\n", nrow(driver_license_lookup)))

  # Summary statistics
  cat("\nDriver license state distribution:\n")
  driver_states <- driver_license_lookup %>%
    mutate(
      state_type = case_when(
        driver_license_state %in% legal_fips ~ "Legal",
        driver_license_state %in% prohibition_fips ~ "Prohibition",
        TRUE ~ "Other"
      )
    ) %>%
    count(state_type)
  print(driver_states)

  # Save
  saveRDS(driver_license_lookup, "../data/driver_license_lookup.rds")
  saveRDS(vehicle_data_all, "../data/vehicle_data_raw.rds")
  cat("\nSaved driver_license_lookup.rds and vehicle_data_raw.rds\n")

} else {
  cat("No vehicle data fetched. Cannot create driver license lookup.\n")
}

# =============================================================================
# Merge with existing crash analysis data
# =============================================================================

cat("\n=== Merging driver license data with crash analysis ===\n")

crashes_analysis <- readRDS("../data/crashes_analysis.rds")
cat(sprintf("Original crash analysis: %d rows\n", nrow(crashes_analysis)))

if (file.exists("../data/driver_license_lookup.rds")) {
  driver_license_lookup <- readRDS("../data/driver_license_lookup.rds")

  # Merge on state, st_case, year
  crashes_enhanced <- crashes_analysis %>%
    left_join(
      driver_license_lookup,
      by = c("state", "st_case", "year")
    ) %>%
    mutate(
      # Driver residency classification
      driver_from_legal_state = as.integer(driver_license_state %in% legal_fips),
      driver_from_prohib_state = as.integer(driver_license_state %in% prohibition_fips),

      # In-state driver flag (driver license matches crash state)
      is_instate_driver = as.integer(driver_license_state == state),

      # Cross-border driver flag
      is_crossborder_driver = as.integer(!is.na(driver_license_state) & driver_license_state != state),

      # Driver legal status (based on residence)
      driver_legal_status = case_when(
        driver_license_state %in% legal_fips ~ "Legal",
        driver_license_state %in% prohibition_fips ~ "Prohibition",
        TRUE ~ NA_character_
      ),

      # Treatment based on driver residence (not crash location)
      treated_by_residence = as.integer(driver_from_legal_state == 1)
    )

  # Statistics
  n_matched <- sum(!is.na(crashes_enhanced$driver_license_state))
  cat(sprintf("\nMatched driver license data for %d of %d crashes (%.1f%%)\n",
              n_matched, nrow(crashes_enhanced), 100 * n_matched / nrow(crashes_enhanced)))

  n_instate <- sum(crashes_enhanced$is_instate_driver == 1, na.rm = TRUE)
  n_crossborder <- sum(crashes_enhanced$is_crossborder_driver == 1, na.rm = TRUE)
  cat(sprintf("  In-state drivers: %d (%.1f%% of matched)\n",
              n_instate, 100 * n_instate / n_matched))
  cat(sprintf("  Cross-border drivers: %d (%.1f%% of matched)\n",
              n_crossborder, 100 * n_crossborder / n_matched))

  # Alcohol rates by driver residence
  cat("\nAlcohol involvement by driver residence:\n")
  alc_by_res <- crashes_enhanced %>%
    filter(!is.na(driver_legal_status)) %>%
    group_by(driver_legal_status) %>%
    summarise(
      n = n(),
      alcohol_rate = mean(alcohol_involved),
      .groups = "drop"
    )
  print(alc_by_res)

  # Treatment concordance
  cat("\nTreatment concordance (crash location vs driver residence):\n")
  concordance <- crashes_enhanced %>%
    filter(!is.na(treated_by_residence)) %>%
    mutate(
      concordance = case_when(
        treated == 1 & treated_by_residence == 1 ~ "Both legal",
        treated == 0 & treated_by_residence == 0 ~ "Both prohibition",
        treated == 1 & treated_by_residence == 0 ~ "Legal crash, prohib resident",
        treated == 0 & treated_by_residence == 1 ~ "Prohib crash, legal resident"
      )
    ) %>%
    count(concordance) %>%
    mutate(pct = 100 * n / sum(n))
  print(concordance)

  # Save enhanced data
  saveRDS(crashes_enhanced, "../data/crashes_analysis.rds")
  cat("\nSaved enhanced crashes_analysis.rds with driver residency variables.\n")

} else {
  cat("No driver license lookup found.\n")
}

cat("\n=== Driver data fetch complete ===\n")
