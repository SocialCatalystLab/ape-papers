# =============================================================================
# Paper 110: The Price of Distance
# 01_fetch_fars.R - Download and process FARS data (2012-2023)
# =============================================================================

source(here::here("output/paper_110/code/00_packages.R"))

# =============================================================================
# 1. Define Study Region
# =============================================================================

# States of interest
legal_states <- c("CO", "WA", "OR", "NV", "CA", "AK")
illegal_states <- c("ID", "WY", "NE", "KS", "UT", "AZ", "MT", "NM")
all_states <- c(legal_states, illegal_states)

# FIPS codes for filtering
state_fips <- tigris::fips_codes %>%
  filter(state %in% all_states) %>%
  distinct(state, state_code) %>%
  mutate(state_code = as.numeric(state_code))

# =============================================================================
# 2. Download FARS Data (2012-2023)
# =============================================================================

fetch_fars_year <- function(year) {
  message("  Downloading FARS ", year, "...")

  base_url <- "https://static.nhtsa.gov/nhtsa/downloads/FARS"
  acc_url <- paste0(base_url, "/", year, "/National/FARS", year, "NationalCSV.zip")

  temp_zip <- tempfile(fileext = ".zip")
  temp_dir <- tempdir()

  tryCatch({
    download.file(acc_url, temp_zip, mode = "wb", quiet = TRUE)
    unzip(temp_zip, exdir = temp_dir, overwrite = TRUE)

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

    # Read PERSON file
    per_file <- all_files[grepl("person", all_files, ignore.case = TRUE)]
    per_file <- per_file[grepl("\\.csv$", per_file, ignore.case = TRUE)]
    per_file <- per_file[!grepl("pbtype|nmprior|nmimpair|nmcrash|nmdistract|drimpair|driverrf|distract",
                                per_file, ignore.case = TRUE)]

    per <- NULL
    if (length(per_file) > 0) {
      per <- fread(per_file[1], stringsAsFactors = FALSE) %>%
        clean_names() %>%
        mutate(year = year)
    }

    # Read DRUGS file (if available)
    drugs_file <- all_files[grepl("drugs", all_files, ignore.case = TRUE)]
    drugs_file <- drugs_file[grepl("\\.csv$", drugs_file, ignore.case = TRUE)]

    drugs <- NULL
    if (length(drugs_file) > 0) {
      drugs <- fread(drugs_file[1], stringsAsFactors = FALSE) %>%
        clean_names() %>%
        mutate(year = year)
    }

    # Clean up
    unlink(temp_zip)
    unlink(list.files(temp_dir, full.names = TRUE, pattern = "\\.csv$"))

    return(list(accident = acc, person = per, drugs = drugs))

  }, error = function(e) {
    message("    Error: ", e$message)
    return(NULL)
  })
}

# Download all years
message("Starting FARS download (2012-2023)...")
message("This will take several minutes...")

fars_years <- 2012:2023
fars_list <- list()

for (yr in fars_years) {
  result <- fetch_fars_year(yr)
  if (!is.null(result)) {
    fars_list[[as.character(yr)]] <- result
  }
  Sys.sleep(1)
}

message("Download complete. Processing data...")

# =============================================================================
# 3. Standardize and Combine Accident Data
# =============================================================================

standardize_accident <- function(df, year) {
  df <- df %>% mutate(across(everything(), as.character))

  # Standardize coordinate columns
  if ("longitud" %in% names(df) && !"longitude" %in% names(df)) {
    df <- rename(df, longitude = longitud)
  }

  df <- df %>%
    mutate(
      st_case = as.numeric(st_case),
      state = as.numeric(state),
      fatals = as.numeric(ifelse("fatals" %in% names(df), fatals, NA)),
      latitude = as.numeric(latitude),
      longitude = as.numeric(longitude),
      month = as.numeric(month),
      day = as.numeric(ifelse("day" %in% names(df), day, NA)),
      hour = as.numeric(hour),
      minute = as.numeric(ifelse("minute" %in% names(df), minute, NA)),
      day_week = as.numeric(day_week),
      drunk_dr = as.numeric(ifelse("drunk_dr" %in% names(df), drunk_dr, NA)),
      year = as.numeric(year)
    )

  # Keep relevant columns
  cols_keep <- c("st_case", "state", "year", "month", "day", "hour", "minute",
                 "day_week", "latitude", "longitude", "fatals",
                 "drunk_dr", "lgt_cond", "weather", "route", "func_sys")

  cols_exist <- intersect(cols_keep, names(df))
  df <- df %>% select(all_of(cols_exist))

  return(df)
}

# Combine accident data
fars_acc <- map_dfr(names(fars_list), function(yr) {
  if (!is.null(fars_list[[yr]]$accident)) {
    standardize_accident(fars_list[[yr]]$accident, yr)
  }
})

message("Total crashes downloaded: ", nrow(fars_acc))

# =============================================================================
# 4. Filter to Study Region
# =============================================================================

fars_regional <- fars_acc %>%
  filter(state %in% state_fips$state_code) %>%
  left_join(state_fips, by = c("state" = "state_code")) %>%
  rename(state_abbr = state.y, state_fips = state) %>%
  # Clean coordinates
  mutate(
    latitude = ifelse(latitude > 90 | latitude < 20, NA, latitude),
    longitude = ifelse(longitude > -60 | longitude < -180, NA, longitude),
    # Fix positive longitudes (should be negative in Western US)
    longitude = ifelse(longitude > 0, -longitude, longitude)
  ) %>%
  # Create key variables
  mutate(
    alcohol_involved = drunk_dr > 0 & !is.na(drunk_dr),
    crash_date = ymd(paste(year, month, day, sep = "-")),
    year_month = floor_date(crash_date, "month"),
    nighttime = hour >= 22 | hour <= 3,
    legal_state = state_abbr %in% legal_states,
    has_coords = !is.na(latitude) & !is.na(longitude)
  )

message("Crashes in study region: ", nrow(fars_regional))
message("Crashes with coordinates: ", sum(fars_regional$has_coords))

# =============================================================================
# 5. Process Drug Data (2018+ for THC)
# =============================================================================

process_drugs <- function(df, year) {
  if (is.null(df)) return(NULL)

  df %>%
    clean_names() %>%
    mutate(
      st_case = as.numeric(st_case),
      veh_no = as.numeric(ifelse("veh_no" %in% names(df), veh_no, NA)),
      per_no = as.numeric(ifelse("per_no" %in% names(df), per_no, NA)),
      year = year
    ) %>%
    # Identify THC via drug name matching (reliable from 2018+)
    mutate(
      drug_name = tolower(as.character(ifelse("drugres1" %in% names(df), drugres1, ""))),
      thc_positive = grepl("thc|tetrahydrocannabinol|delta.?9|cannabis|marijuana",
                           drug_name, ignore.case = TRUE)
    )
}

# Process drug files
fars_drugs <- map_dfr(names(fars_list), function(yr) {
  if (!is.null(fars_list[[yr]]$drugs)) {
    process_drugs(fars_list[[yr]]$drugs, as.numeric(yr))
  }
})

# Aggregate to crash level
if (nrow(fars_drugs) > 0) {
  drug_crash_level <- fars_drugs %>%
    filter(year >= 2018) %>%
    group_by(st_case, year) %>%
    summarize(
      any_drug_record = TRUE,
      thc_involved = any(thc_positive, na.rm = TRUE),
      .groups = "drop"
    )

  # Merge back to accidents
  fars_regional <- fars_regional %>%
    left_join(drug_crash_level, by = c("st_case", "year")) %>%
    mutate(
      any_drug_record = replace_na(any_drug_record, FALSE),
      thc_involved = replace_na(thc_involved, FALSE)
    )
}

# =============================================================================
# 6. Summary Statistics
# =============================================================================

message("\n=== FARS Summary Statistics ===")

fars_regional %>%
  group_by(legal_state) %>%
  summarize(
    n_crashes = n(),
    n_geocoded = sum(has_coords),
    pct_geocoded = mean(has_coords) * 100,
    pct_alcohol = mean(alcohol_involved, na.rm = TRUE) * 100,
    .groups = "drop"
  ) %>%
  mutate(state_type = ifelse(legal_state, "Legal States", "Illegal States")) %>%
  print()

message("\nBy year:")
fars_regional %>%
  group_by(year) %>%
  summarize(
    n_crashes = n(),
    pct_alcohol = mean(alcohol_involved, na.rm = TRUE) * 100,
    .groups = "drop"
  ) %>%
  print()

# =============================================================================
# 7. Save Data
# =============================================================================

saveRDS(fars_regional, file.path(data_dir, "fars_crashes.rds"))
message("\nSaved to: ", file.path(data_dir, "fars_crashes.rds"))
message("Total observations: ", nrow(fars_regional))
