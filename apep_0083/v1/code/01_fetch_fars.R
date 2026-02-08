# =============================================================================
# Paper 109: Geocoded Atlas of US Traffic Fatalities 2001-2019 (Revision)
# 01_fetch_fars.R - Download FARS data for Western marijuana states
# =============================================================================

source(here::here("output/paper_109/code/00_packages.R"))

# =============================================================================
# 1. Download FARS Data (2001-2019) with Retry Logic
# =============================================================================

# Function to download FARS data for a given year with retry logic
fetch_fars_year <- function(year, max_retries = 3) {
  message("  Downloading FARS ", year, "...")

  # NHTSA static server URL
  base_url <- "https://static.nhtsa.gov/nhtsa/downloads/FARS"
  acc_url <- paste0(base_url, "/", year, "/National/FARS", year, "NationalCSV.zip")

  temp_zip <- tempfile(fileext = ".zip")
  # Use a unique temp directory for each year to avoid stale file issues
  temp_dir <- file.path(tempdir(), paste0("fars_", year))
  if (dir.exists(temp_dir)) unlink(temp_dir, recursive = TRUE)
  dir.create(temp_dir, showWarnings = FALSE)

  for (attempt in 1:max_retries) {
    tryCatch({
      # Download with timeout
      download.file(acc_url, temp_zip, mode = "wb", quiet = TRUE,
                    timeout = 300)  # 5 minute timeout

      # Verify download completed
      if (!file.exists(temp_zip) || file.size(temp_zip) < 1000) {
        stop("Download incomplete or file too small")
      }

      unzip(temp_zip, exdir = temp_dir, overwrite = TRUE)

      # Find files - handle case sensitivity and naming variations
      all_files <- list.files(temp_dir, full.names = TRUE, recursive = TRUE)

      # Read ACCIDENT file
      acc_file <- all_files[grepl("accident", all_files, ignore.case = TRUE)]
      acc_file <- acc_file[grepl("\\.csv$", acc_file, ignore.case = TRUE)]

      if (length(acc_file) == 0) {
        message("    Warning: No accident file found for ", year)
        return(NULL)
      }

      acc <- fread(acc_file[1], stringsAsFactors = FALSE) %>%
        clean_names() %>%
        mutate(year = year)

      # Read PERSON file (contains drug/alcohol test results)
      per_file <- all_files[grepl("person", all_files, ignore.case = TRUE)]
      per_file <- per_file[grepl("\\.csv$", per_file, ignore.case = TRUE)]
      per_file <- per_file[!grepl("pbtype|nmprior|nmimpair|nmcrash|nmdistract|drimpair|driverrf|distract",
                                   per_file, ignore.case = TRUE)]  # Exclude related files

      per <- NULL
      if (length(per_file) > 0) {
        per <- fread(per_file[1], stringsAsFactors = FALSE) %>%
          clean_names() %>%
          mutate(year = year)
      }

      # Read DRUGS file (detailed drug test results)
      drugs_file <- all_files[grepl("drugs", all_files, ignore.case = TRUE)]
      drugs_file <- drugs_file[grepl("\\.csv$", drugs_file, ignore.case = TRUE)]

      drugs <- NULL
      if (length(drugs_file) > 0) {
        drugs <- fread(drugs_file[1], stringsAsFactors = FALSE) %>%
          clean_names() %>%
          mutate(year = year)
      }

      # Clean up temp files completely
      unlink(temp_zip)
      unlink(temp_dir, recursive = TRUE)

      message("    SUCCESS: ", year, " - ", nrow(acc), " accidents")
      return(list(accident = acc, person = per, drugs = drugs))

    }, error = function(e) {
      message("    Attempt ", attempt, "/", max_retries, " failed: ", e$message)
      if (attempt < max_retries) {
        Sys.sleep(5 * attempt)  # Exponential backoff
      }
    })
  }

  message("    FAILED after ", max_retries, " attempts: ", year)
  return(NULL)
}

# Download years 2001-2019 (continuous coverage for event study)
message("Starting FARS data download (2001-2019)...")
message("This will take several minutes...")

fars_years <- 2001:2019
fars_list <- list()
failed_years <- c()

for (yr in fars_years) {
  result <- fetch_fars_year(yr)
  if (!is.null(result)) {
    fars_list[[as.character(yr)]] <- result
  } else {
    failed_years <- c(failed_years, yr)
  }
  Sys.sleep(2)  # Be nice to the server
}

message("\nDownload complete.")
message("Successful years: ", length(fars_list))
if (length(failed_years) > 0) {
  message("Failed years: ", paste(failed_years, collapse = ", "))
} else {
  message("All years downloaded successfully!")
}

# =============================================================================
# 2. Combine and Clean Accident Data
# =============================================================================

# Function to standardize column names across years
standardize_accident <- function(df, year) {
  df <- df %>% mutate(across(everything(), as.character))

  # Standardize coordinate column names (these vary by year)
  if ("longitud" %in% names(df) && !"longitude" %in% names(df)) {
    df <- rename(df, longitude = longitud)
  }

  # Standardize key variables
  df <- df %>%
    mutate(
      st_case = as.numeric(st_case),
      state = as.numeric(state),
      fatals = as.numeric(ifelse("fatals" %in% names(df), fatals, NA)),
      persons = as.numeric(ifelse("persons" %in% names(df), persons, NA)),
      latitude = as.numeric(latitude),
      longitude = as.numeric(longitude),
      month = as.numeric(month),
      day = as.numeric(ifelse("day" %in% names(df), day, NA)),
      hour = as.numeric(hour),
      minute = as.numeric(minute),
      day_week = as.numeric(day_week),
      year = as.numeric(year)
    )

  # Keep relevant columns
  cols_keep <- c("st_case", "state", "year", "month", "day", "hour", "minute",
                 "day_week", "latitude", "longitude", "fatals", "persons",
                 "ve_total", "drunk_dr", "lgt_cond", "weather", "route",
                 "func_sys", "rd_owner", "sp_limit")

  # Only keep columns that exist
  cols_exist <- intersect(cols_keep, names(df))
  df <- df %>% select(all_of(cols_exist))

  return(df)
}

# Combine all accident files
fars_acc <- map_dfr(names(fars_list), function(yr) {
  if (!is.null(fars_list[[yr]]$accident)) {
    standardize_accident(fars_list[[yr]]$accident, yr)
  }
})

message("Combined accident data: ", format(nrow(fars_acc), big.mark = ","), " crashes")

# =============================================================================
# 3. Combine Person Data (for drug/alcohol test results)
# =============================================================================

# Function to standardize person file
standardize_person <- function(df, year) {
  df <- df %>% mutate(across(everything(), as.character))

  df <- df %>%
    mutate(
      st_case = as.numeric(st_case),
      state = as.numeric(state),
      veh_no = as.numeric(veh_no),
      per_no = as.numeric(per_no),
      inj_sev = as.numeric(inj_sev),
      per_typ = as.numeric(per_typ),
      age = as.numeric(age),
      sex = as.numeric(sex),
      ejection = as.numeric(ifelse("ejection" %in% names(df), ejection, NA)),
      drinking = as.numeric(ifelse("drinking" %in% names(df), drinking, NA)),
      drugs = as.numeric(ifelse("drugs" %in% names(df), drugs, NA)),
      drug_det = as.numeric(ifelse("drug_det" %in% names(df), drug_det, NA)),
      alc_res = as.numeric(ifelse("alc_res" %in% names(df), alc_res, NA)),
      alc_det = as.numeric(ifelse("alc_det" %in% names(df), alc_det, NA)),
      year = as.numeric(year)
    )

  return(df)
}

# Combine all person files
fars_per <- map_dfr(names(fars_list), function(yr) {
  if (!is.null(fars_list[[yr]]$person)) {
    standardize_person(fars_list[[yr]]$person, yr)
  }
})

message("Combined person data: ", format(nrow(fars_per), big.mark = ","), " persons")

# =============================================================================
# 4. Combine Drugs Data (detailed drug test results)
# =============================================================================

standardize_drugs <- function(df, year) {
  df <- df %>% mutate(across(everything(), as.character))

  # Preserve drugresname BEFORE mutate (avoid ifelse scalar bug)
  has_drugresname <- "drugresname" %in% names(df)
  drugresname_col <- if (has_drugresname) df$drugresname else rep(NA_character_, nrow(df))

  has_drugspec <- "drugspec" %in% names(df)
  drugspec_col <- if (has_drugspec) as.numeric(df$drugspec) else rep(NA_real_, nrow(df))

  has_drugres <- "drugres" %in% names(df)
  drugres_col <- if (has_drugres) as.numeric(df$drugres) else rep(NA_real_, nrow(df))

  df <- df %>%
    mutate(
      st_case = as.numeric(st_case),
      state = as.numeric(state),
      veh_no = as.numeric(veh_no),
      per_no = as.numeric(per_no),
      year = as.numeric(year)
    )

  # Add the preserved columns back
  df$drugspec <- drugspec_col
  df$drugres <- drugres_col
  df$drugresname <- drugresname_col

  return(df)
}

# Combine all drugs files
fars_drugs <- map_dfr(names(fars_list), function(yr) {
  if (!is.null(fars_list[[yr]]$drugs)) {
    standardize_drugs(fars_list[[yr]]$drugs, yr)
  }
})

if (nrow(fars_drugs) > 0) {
  message("Combined drugs data: ", format(nrow(fars_drugs), big.mark = ","), " drug test records")
} else {
  message("No detailed drugs data available")
}

# =============================================================================
# 5. Filter to Western States
# =============================================================================

message("\nFiltering to Western marijuana states...")

# Add state FIPS as character
fars_acc <- fars_acc %>%
  mutate(state_fips = sprintf("%02d", state))

# Filter to Western states
fars_acc_west <- fars_acc %>%
  filter(state_fips %in% WESTERN_FIPS)

message("Western states crashes: ", format(nrow(fars_acc_west), big.mark = ","))

# Also filter person data
fars_per_west <- fars_per %>%
  mutate(state_fips = sprintf("%02d", state)) %>%
  filter(state_fips %in% WESTERN_FIPS)

message("Western states persons: ", format(nrow(fars_per_west), big.mark = ","))

# Filter drugs data
if (nrow(fars_drugs) > 0) {
  fars_drugs_west <- fars_drugs %>%
    mutate(state_fips = sprintf("%02d", state)) %>%
    filter(state_fips %in% WESTERN_FIPS)
  message("Western states drug tests: ", format(nrow(fars_drugs_west), big.mark = ","))
}

# =============================================================================
# 6. Filter to Valid Geocoded Crashes
# =============================================================================

message("\nFiltering to valid geocoded crashes...")

fars_geo <- fars_acc_west %>%
  filter(
    !is.na(latitude) & !is.na(longitude),
    latitude > 20 & latitude < 72,    # Include Alaska
    longitude < -60 & longitude > -180
  )

message("Geocoded crashes: ", format(nrow(fars_geo), big.mark = ","),
        " (", round(100 * nrow(fars_geo) / nrow(fars_acc_west), 1), "% of Western crashes)")

# Check geocoding by year - SHOW ALL YEARS
geocode_by_year <- fars_acc_west %>%
  mutate(has_coords = !is.na(latitude) & !is.na(longitude)) %>%
  group_by(year) %>%
  summarise(
    total = n(),
    geocoded = sum(has_coords),
    pct_geocoded = round(100 * geocoded / total, 1)
  )

message("\nGeocoding rate by year (ALL YEARS):")
print(geocode_by_year, n = 25)

# =============================================================================
# 7. Create Drug/Alcohol Summary by Crash
# =============================================================================

message("\nCreating substance involvement summary...")

# THC detection via text matching in drugresname (not numeric codes)
# THC patterns include: THC, Tetrahydrocannabinol, Carboxy, Cannabinoid, Cannabis, Marijuana, Delta-9

# Summarize drug involvement from drugs file
if (nrow(fars_drugs) > 0) {
  # First, identify THC-positive records via text matching
  thc_patterns <- "THC|Tetrahydro|Carboxy|Cannabin|Marijuana|Cannabis|Delta"

  fars_drugs_west <- fars_drugs_west %>%
    mutate(
      is_thc_finding = grepl(thc_patterns, drugresname, ignore.case = TRUE)
    )

  drug_summary <- fars_drugs_west %>%
    group_by(st_case, state, year) %>%
    summarise(
      any_drug_test = TRUE,
      thc_positive = any(is_thc_finding, na.rm = TRUE),
      any_drug_positive = any(drugres == 1, na.rm = TRUE),
      n_drugs_positive = sum(drugres == 1, na.rm = TRUE),
      .groups = "drop"
    )
} else {
  # Use person file drugs variable if drugs file not available
  drug_summary <- fars_per_west %>%
    group_by(st_case, state, year) %>%
    summarise(
      any_drug_test = any(drug_det %in% c(0, 1), na.rm = TRUE),
      thc_positive = NA,  # Can't determine specific drug from person file
      any_drug_positive = any(drugs == 1, na.rm = TRUE),
      n_drugs_positive = NA_integer_,
      .groups = "drop"
    )
}

# Summarize alcohol involvement from person file
alc_summary <- fars_per_west %>%
  filter(per_typ == 1) %>%  # Drivers only
  group_by(st_case, state, year) %>%
  summarise(
    any_alc_test = any(alc_det %in% c(0, 1), na.rm = TRUE),
    any_alc_positive = any(drinking == 1, na.rm = TRUE),
    max_bac = max(alc_res / 100, na.rm = TRUE),  # Convert to decimal
    driver_bac_over_08 = any((alc_res / 100) >= 0.08, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(max_bac = ifelse(is.infinite(max_bac), NA_real_, max_bac))

# Summarize person characteristics by crash
crash_persons <- fars_per_west %>%
  group_by(st_case, state, year) %>%
  summarise(
    n_persons = n(),
    n_fatals = sum(inj_sev == 4, na.rm = TRUE),
    n_drivers = sum(per_typ == 1, na.rm = TRUE),
    n_passengers = sum(per_typ == 2, na.rm = TRUE),
    n_pedestrians = sum(per_typ == 5, na.rm = TRUE),
    n_cyclists = sum(per_typ == 6, na.rm = TRUE),
    n_ejected = sum(ejection %in% c(2, 3), na.rm = TRUE),
    mean_age = mean(age[age < 998], na.rm = TRUE),
    any_young_driver = any(per_typ == 1 & age >= 16 & age <= 24, na.rm = TRUE),
    .groups = "drop"
  )

# =============================================================================
# 8. Merge Everything Together
# =============================================================================

message("Merging accident, person, and drug data...")

fars_analysis <- fars_geo %>%
  left_join(crash_persons, by = c("st_case", "state", "year")) %>%
  left_join(alc_summary, by = c("st_case", "state", "year")) %>%
  left_join(drug_summary, by = c("st_case", "state", "year"))

# Create summary substance variable
fars_analysis <- fars_analysis %>%
  mutate(
    substance_cat = case_when(
      thc_positive & any_alc_positive ~ "Both",
      thc_positive ~ "THC Positive",
      any_alc_positive ~ "Alcohol Only",
      TRUE ~ "Neither/Unknown"
    ),
    # Time of day categories
    hour_cat = case_when(
      hour >= 6 & hour < 12 ~ "Morning",
      hour >= 12 & hour < 18 ~ "Afternoon",
      hour >= 18 & hour < 22 ~ "Evening",
      TRUE ~ "Night"
    ),
    # Weekend indicator
    is_weekend = day_week %in% c(1, 7)  # Sunday=1, Saturday=7
  )

message("Final analysis dataset: ", format(nrow(fars_analysis), big.mark = ","), " crashes")

# =============================================================================
# 9. Save Data Files
# =============================================================================

message("\nSaving data files...")

# Save raw downloads
saveRDS(fars_acc, file.path(dir_data_raw, "fars_accident_all.rds"))
saveRDS(fars_per, file.path(dir_data_raw, "fars_person_all.rds"))
if (nrow(fars_drugs) > 0) {
  saveRDS(fars_drugs, file.path(dir_data_raw, "fars_drugs_all.rds"))
}

# Save Western states subsets
saveRDS(fars_acc_west, file.path(dir_data_raw, "fars_accident_west.rds"))
saveRDS(fars_per_west, file.path(dir_data_raw, "fars_person_west.rds"))

# Save final analysis dataset
saveRDS(fars_analysis, file.path(dir_data, "fars_analysis.rds"))

# Also save as CSV for Python access
fwrite(fars_analysis, file.path(dir_data, "fars_analysis.csv"))

message("Data files saved to: ", dir_data)

# =============================================================================
# 10. Summary Statistics
# =============================================================================

message("\n", strrep("=", 60))
message("FARS DATA SUMMARY")
message(strrep("=", 60))

message("\nCrashes by Year (should show continuous 2001-2019):")
crashes_by_year <- fars_analysis %>%
  group_by(year) %>%
  summarise(
    crashes = n(),
    fatals = sum(n_fatals, na.rm = TRUE)
  )
print(crashes_by_year, n = 25)

message("\nYear coverage check:")
expected_years <- 2001:2019
actual_years <- sort(unique(fars_analysis$year))
missing <- setdiff(expected_years, actual_years)
if (length(missing) == 0) {
  message("  ALL YEARS PRESENT (2001-2019)")
} else {
  message("  WARNING - Missing years: ", paste(missing, collapse = ", "))
}

message("\nCrashes by State:")
fars_analysis %>%
  group_by(state_fips) %>%
  summarise(
    crashes = n(),
    fatals = sum(n_fatals, na.rm = TRUE)
  ) %>%
  arrange(desc(crashes)) %>%
  print(n = 15)

message("\nSubstance Involvement (where tested):")
fars_analysis %>%
  filter(!is.na(thc_positive) | !is.na(any_alc_positive)) %>%
  count(substance_cat) %>%
  mutate(pct = round(100 * n / sum(n), 1)) %>%
  print()

message("\nTHC Positive Rate by Year (legal states: CO, WA, OR, CA, NV, AK):")
fars_analysis %>%
  filter(state_fips %in% c("08", "53", "41", "06", "32", "02")) %>%
  filter(!is.na(thc_positive)) %>%
  group_by(year) %>%
  summarise(
    tested = n(),
    thc_pos = sum(thc_positive),
    pct_thc = round(100 * thc_pos / tested, 1)
  ) %>%
  print(n = 25)

message("\n", strrep("=", 60))
message("Data fetching complete!")
message(strrep("=", 60))
