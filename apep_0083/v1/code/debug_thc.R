# Debug THC data pipeline
library(tidyverse)
library(data.table)
library(janitor)

message("=== THC Data Pipeline Debug ===\n")

# Step 1: Download a single year and check what we get
message("Step 1: Downloading 2019 FARS data...")
url <- "https://static.nhtsa.gov/nhtsa/downloads/FARS/2019/National/FARS2019NationalCSV.zip"
temp_zip <- tempfile(fileext = ".zip")
temp_dir <- file.path(tempdir(), "fars_debug_2019")
if (dir.exists(temp_dir)) unlink(temp_dir, recursive = TRUE)
dir.create(temp_dir)

download.file(url, temp_zip, mode = "wb", quiet = TRUE)
unzip(temp_zip, exdir = temp_dir)

# Find drugs file
all_files <- list.files(temp_dir, full.names = TRUE, recursive = TRUE)
drugs_file <- all_files[grepl("drugs", all_files, ignore.case = TRUE)]
drugs_file <- drugs_file[grepl("[.]csv$", drugs_file, ignore.case = TRUE)]

message("Found drugs file: ", drugs_file)

# Read it raw
drugs_raw <- fread(drugs_file[1])
message("Raw drugs file columns: ", paste(names(drugs_raw), collapse = ", "))
message("Raw drugs file rows: ", nrow(drugs_raw))

# Check for THC in raw data
thc_pattern <- "THC|Tetrahydro|Cannabin"
thc_rows <- drugs_raw[grepl(thc_pattern, drugs_raw$DRUGRESNAME, ignore.case = TRUE), ]
message("THC rows in raw data: ", nrow(thc_rows))
message("Sample THC DRUGRESNAME values:")
print(head(unique(thc_rows$DRUGRESNAME), 10))

# Now apply clean_names() like the script does
drugs_clean <- drugs_raw %>% clean_names()
message("\nAfter clean_names(), columns: ", paste(names(drugs_clean), collapse = ", "))

# Check if drugresname exists and has THC
if ("drugresname" %in% names(drugs_clean)) {
  thc_clean <- drugs_clean[grepl(thc_pattern, drugs_clean$drugresname, ignore.case = TRUE), ]
  message("THC rows after clean_names: ", nrow(thc_clean))
  message("Sample values:")
  print(head(unique(thc_clean$drugresname), 10))
} else {
  message("ERROR: drugresname column not found after clean_names!")
}

# Step 2: Check what the standardize_drugs function does
message("\n\nStep 2: Simulating standardize_drugs function...")

standardize_drugs_original <- function(df, year) {
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

drugs_standardized <- standardize_drugs_original(drugs_clean, 2019)
message("After standardize_drugs, columns: ", paste(names(drugs_standardized), collapse = ", "))
message("drugresname in result: ", "drugresname" %in% names(drugs_standardized))

if ("drugresname" %in% names(drugs_standardized)) {
  thc_std <- drugs_standardized[grepl(thc_pattern, drugs_standardized$drugresname, ignore.case = TRUE), ]
  message("THC rows after standardize: ", nrow(thc_std))
} else {
  message("ERROR: drugresname lost in standardization!")
}

# Step 3: Filter to Western states
message("\n\nStep 3: Filtering to Western states...")
western_fips <- c("08", "53", "41", "06", "32", "02", "56", "31", "20", "16", "49", "04", "35", "30")
drugs_standardized$state_fips <- sprintf("%02d", drugs_standardized$state)
drugs_west <- drugs_standardized[drugs_standardized$state_fips %in% western_fips, ]
message("Western drugs rows: ", nrow(drugs_west))

thc_west <- drugs_west[grepl(thc_pattern, drugs_west$drugresname, ignore.case = TRUE), ]
message("THC rows in Western states: ", nrow(thc_west))

# Step 4: Create drug summary
message("\n\nStep 4: Creating drug summary with THC detection...")

# This is what the current script does
drugs_west_df <- as_tibble(drugs_west)

# Add is_thc_finding column
drugs_west_df <- drugs_west_df %>%
  mutate(
    is_thc_finding = grepl(thc_pattern, drugresname, ignore.case = TRUE)
  )

message("is_thc_finding TRUE count: ", sum(drugs_west_df$is_thc_finding, na.rm = TRUE))

# Create summary
drug_summary <- drugs_west_df %>%
  group_by(st_case, state, year) %>%
  summarise(
    any_drug_test = TRUE,
    thc_positive = any(is_thc_finding, na.rm = TRUE),
    any_drug_positive = any(drugres == 1, na.rm = TRUE),
    n_drugs_positive = sum(drugres == 1, na.rm = TRUE),
    .groups = "drop"
  )

message("Drug summary rows: ", nrow(drug_summary))
message("Crashes with THC positive: ", sum(drug_summary$thc_positive, na.rm = TRUE))

# Show sample
message("\nSample of crashes with THC positive:")
print(head(drug_summary[drug_summary$thc_positive == TRUE, ], 10))

# Clean up
unlink(temp_zip)
unlink(temp_dir, recursive = TRUE)

message("\n=== Debug Complete ===")
