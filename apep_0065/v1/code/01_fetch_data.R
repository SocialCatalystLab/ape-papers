# =============================================================================
# Paper 82: Social Security at 62 and Civic Engagement
# 01_fetch_data.R - Download and process ATUS data from BLS
# =============================================================================

source("00_packages.R")

# -----------------------------------------------------------------------------
# ATUS Multi-Year Microdata from BLS
# Source: https://www.bls.gov/tus/data.htm
# BLS provides multi-year data files that combine all years
# -----------------------------------------------------------------------------

cat("=" %>% strrep(70), "\n")
cat("ATUS Data Acquisition - BLS Multi-Year Files\n")
cat("=" %>% strrep(70), "\n\n")

# URLs for 2003-2023 data files (multi-year format)
# Note: BLS URL structure may change - verify at https://www.bls.gov/tus/data.htm
ATUS_SUMMARY_URL <- "https://www.bls.gov/tus/datafiles/atussum-0323.zip"
ATUS_RESP_URL <- "https://www.bls.gov/tus/datafiles/atusresp-0323.zip"
ATUS_CPS_URL <- "https://www.bls.gov/tus/datafiles/atuscps-0323.zip"

# Download function
download_atus_file <- function(url, dest_dir = data_dir) {
  filename <- basename(url)
  zip_path <- file.path(dest_dir, filename)
  # BLS files have underscores in extracted .dat files, not hyphens
  dat_path <- gsub("\\.zip$", ".dat", zip_path)
  dat_path_underscore <- gsub("-", "_", dat_path)

  # Check for existing .dat file (with underscore format)
  if (file.exists(dat_path_underscore)) {
    cat("Already downloaded:", dat_path_underscore, "\n")
    return(dat_path_underscore)
  }

  # Also check hyphen format
  if (file.exists(dat_path)) {
    cat("Already downloaded:", dat_path, "\n")
    return(dat_path)
  }

  cat("Downloading:", url, "\n")
  tryCatch({
    download.file(url, zip_path, mode = "wb", quiet = FALSE)
    unzip(zip_path, exdir = dest_dir)
    file.remove(zip_path)
    cat("Extracted to:", dest_dir, "\n")
    # Return the underscore version which is what BLS uses
    if (file.exists(dat_path_underscore)) {
      return(dat_path_underscore)
    }
    return(dat_path)
  }, error = function(e) {
    cat("ERROR downloading:", e$message, "\n")
    return(NULL)
  })
}

# -----------------------------------------------------------------------------
# Download ATUS data files
# -----------------------------------------------------------------------------

cat("\n--- Downloading ATUS Summary File ---\n")
sum_file <- download_atus_file(ATUS_SUMMARY_URL)

cat("\n--- Downloading ATUS Respondent File ---\n")
resp_file <- download_atus_file(ATUS_RESP_URL)

cat("\n--- Downloading ATUS CPS File ---\n")
cps_file <- download_atus_file(ATUS_CPS_URL)

# -----------------------------------------------------------------------------
# Read and process ATUS data
# The BLS .dat files are pipe-delimited with headers
# -----------------------------------------------------------------------------

read_atus_dat <- function(filepath) {
  if (is.null(filepath) || !file.exists(filepath)) {
    return(NULL)
  }
  cat("Reading:", filepath, "\n")
  # BLS ATUS files are pipe-delimited
  df <- fread(filepath, sep = ",", header = TRUE, stringsAsFactors = FALSE)
  return(df)
}

# Check if we successfully downloaded files
if (is.null(sum_file) || is.null(resp_file)) {
  cat("\n")
  cat("=" %>% strrep(70), "\n")
  cat("CRITICAL: Could not download ATUS data from BLS\n")
  cat("=" %>% strrep(70), "\n")
  cat("\n")
  cat("Please manually download ATUS data:\n")
  cat("1. Go to: https://www.bls.gov/tus/data.htm\n")
  cat("2. Download 'Multi-year ATUS Microdata Files (2003-2023)':\n")
  cat("   - ATUS Summary File (atussum)\n")
  cat("   - ATUS Respondent File (atusresp)\n")
  cat("   - ATUS CPS File (atuscps)\n")
  cat("3. Extract .dat files to: ", data_dir, "\n")
  cat("\n")
  cat("Alternative: Use IPUMS ATUS (https://www.atusdata.org/atus/)\n")
  cat("   Variables needed: CASEID, YEAR, AGE, SEX, MARST, EDUC, RACE,\n")
  cat("                     BLS_VOLUN, BLS_PCARE*, BLS_CIVIC\n")
  stop("ATUS data not available. Cannot proceed without real data.")
}

# Read the data files
cat("\n--- Reading Downloaded Files ---\n")
atus_sum <- read_atus_dat(sum_file)
atus_resp <- read_atus_dat(resp_file)
atus_cps <- read_atus_dat(cps_file)

# Check data loaded
if (is.null(atus_sum) || nrow(atus_sum) == 0) {
  stop("Failed to read ATUS summary file")
}

cat("\nATUS Summary file rows:", nrow(atus_sum), "\n")
cat("ATUS Respondent file rows:", nrow(atus_resp), "\n")
if (!is.null(atus_cps)) cat("ATUS CPS file rows:", nrow(atus_cps), "\n")

# -----------------------------------------------------------------------------
# Merge files and create analysis dataset
# Key: TUCASEID (case identifier)
# -----------------------------------------------------------------------------

cat("\n--- Merging ATUS Files ---\n")

# The summary file contains time totals by activity category
# Columns prefixed with "t" are time totals (in minutes) for activity codes
# Example: t150101 = minutes in "Computer use for leisure" (code 150101)

# Key time use variables in summary file:
# t15XXXX = Volunteering activities (major category 15)
# t0301XX = Caring for household children
# t0401XX = Caring for non-household children (grandchildren)
# t0402XX = Caring for household adults
# t0403XX = Caring for non-household adults

# Identify volunteering columns (activity codes starting with 15)
vol_cols <- names(atus_sum)[grepl("^t15", names(atus_sum))]
cat("Volunteering activity columns found:", length(vol_cols), "\n")

# Identify caregiving columns
care_hh_child_cols <- names(atus_sum)[grepl("^t0301", names(atus_sum))]
care_nonhh_child_cols <- names(atus_sum)[grepl("^t0401", names(atus_sum))]
care_hh_adult_cols <- names(atus_sum)[grepl("^t0402", names(atus_sum))]
care_nonhh_adult_cols <- names(atus_sum)[grepl("^t0403", names(atus_sum))]

cat("Care for HH children columns:", length(care_hh_child_cols), "\n")
cat("Care for non-HH children columns:", length(care_nonhh_child_cols), "\n")
cat("Care for adults columns:", length(care_hh_adult_cols) + length(care_nonhh_adult_cols), "\n")

# Calculate totals
atus_sum <- atus_sum %>%
  mutate(
    volunteer_mins = rowSums(across(all_of(vol_cols)), na.rm = TRUE),
    care_hh_child_mins = rowSums(across(all_of(care_hh_child_cols)), na.rm = TRUE),
    care_nonhh_child_mins = rowSums(across(all_of(care_nonhh_child_cols)), na.rm = TRUE),
    care_adult_mins = rowSums(across(all_of(c(care_hh_adult_cols, care_nonhh_adult_cols))), na.rm = TRUE),
    total_prosocial_mins = volunteer_mins + care_nonhh_child_mins + care_adult_mins
  )

# Merge with respondent file for diary variables
atus <- merge(
  atus_sum %>% select(TUCASEID, TUYEAR, volunteer_mins, care_hh_child_mins,
                      care_nonhh_child_mins, care_adult_mins, total_prosocial_mins),
  atus_resp %>% select(TUCASEID, TRDPFTPT, TUYEAR, TUMONTH, TUDIARYDAY),
  by = c("TUCASEID", "TUYEAR")
)

cat("\nMerged with respondent file rows:", nrow(atus), "\n")

# Merge with CPS file for demographics (PRTAGE, PESEX, PEEDUCA, PTDTRACE)
# CPS file has multiple records per household - keep only respondent (TULINENO == 1)
if (!is.null(atus_cps) && nrow(atus_cps) > 0) {
  cat("Merging with CPS file for demographics...\n")

  # Get respondent demographics (TULINENO == 1 is the ATUS respondent)
  cps_demo <- atus_cps %>%
    filter(TULINENO == 1) %>%
    select(TUCASEID, PRTAGE, PESEX, PEEDUCA, PTDTRACE, PEMARITL) %>%
    distinct(TUCASEID, .keep_all = TRUE)

  cat("CPS demographics rows:", nrow(cps_demo), "\n")

  atus <- merge(atus, cps_demo, by = "TUCASEID", all.x = TRUE)
  cat("After CPS merge rows:", nrow(atus), "\n")
}

# -----------------------------------------------------------------------------
# Clean and construct variables
# -----------------------------------------------------------------------------

cat("\n--- Constructing Analysis Variables ---\n")

atus <- atus %>%
  rename(
    caseid = TUCASEID,
    year = TUYEAR,
    age = PRTAGE,
    sex = PESEX,
    education = PEEDUCA,
    race = PTDTRACE,
    fulltime = TRDPFTPT,
    month = TUMONTH,
    diary_day = TUDIARYDAY,
    marital = PEMARITL
  ) %>%
  mutate(
    # Demographics
    female = as.integer(sex == 2),
    college = as.integer(education >= 43),  # Bachelor's or higher
    white = as.integer(race == 1),
    married = as.integer(marital %in% c(1, 2)),  # 1=married spouse present, 2=married spouse absent

    # Day of week
    weekday = as.integer(diary_day %in% 2:6),  # Monday=2 to Friday=6

    # Binary outcomes
    any_volunteer = as.integer(volunteer_mins > 0),
    any_care_grandchild = as.integer(care_nonhh_child_mins > 0),
    any_care_adult = as.integer(care_adult_mins > 0),
    any_prosocial = as.integer(total_prosocial_mins > 0),

    # Treatment indicator (for summary stats)
    post62 = as.integer(age >= 62)
  ) %>%
  # Filter to analysis sample
  filter(
    age >= 55,
    age <= 70,
    !is.na(age),
    !is.na(volunteer_mins)
  )

# -----------------------------------------------------------------------------
# Summary statistics
# -----------------------------------------------------------------------------

cat("\n--- Sample Summary ---\n")
cat("Total observations:", nrow(atus), "\n")
cat("Years covered:", min(atus$year), "-", max(atus$year), "\n")
cat("Age range:", min(atus$age), "-", max(atus$age), "\n")

cat("\nObservations by age:\n")
print(table(atus$age))

cat("\nVolunteering rates by age:\n")
atus %>%
  group_by(age) %>%
  summarise(
    n = n(),
    pct_volunteer = mean(any_volunteer) * 100,
    mean_mins = mean(volunteer_mins),
    .groups = "drop"
  ) %>%
  print()

# -----------------------------------------------------------------------------
# Save analysis dataset
# -----------------------------------------------------------------------------

cat("\n--- Saving Data ---\n")
saveRDS(atus, paste0(data_dir, "atus_analysis.rds"))
write_csv(atus, paste0(data_dir, "atus_analysis.csv"))
cat("Data saved to:", paste0(data_dir, "atus_analysis.rds"), "\n")
cat("Data saved to:", paste0(data_dir, "atus_analysis.csv"), "\n")

cat("\n", "=" %>% strrep(70), "\n")
cat("Data acquisition complete!\n")
cat("=" %>% strrep(70), "\n")
