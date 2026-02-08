# =============================================================================
# Paper 82: Social Security at 62 and Civic Engagement
# 02_clean_data.R - Clean and prepare ATUS data for analysis
# =============================================================================

source("00_packages.R")

cat("=" %>% strrep(70), "\n")
cat("ATUS Data Cleaning and Preparation\n")
cat("=" %>% strrep(70), "\n\n")

# -----------------------------------------------------------------------------
# Load ATUS Summary File
# The summary file contains both demographics AND time use totals
# -----------------------------------------------------------------------------

atus_file <- paste0(data_dir, "atussum_0323.dat")

if (!file.exists(atus_file)) {
  stop("ATUS summary file not found. Run 01_fetch_data.R first or download from BLS.")
}

cat("Reading ATUS summary file...\n")
atus_raw <- fread(atus_file, header = TRUE)
cat("Raw observations:", nrow(atus_raw), "\n")

# -----------------------------------------------------------------------------
# Variable documentation (from BLS ATUS data dictionary)
# -----------------------------------------------------------------------------
# Demographics:
#   TUCASEID = unique identifier
#   TUYEAR = survey year
#   TEAGE = age
#   TESEX = sex (1=male, 2=female)
#   PEEDUCA = education (31-46 scale; 43+ = bachelor's or higher)
#   PTDTRACE = race (1=white only, 2=black only, etc.)
#   PEHSPNON = Hispanic (1=Hispanic, 2=non-Hispanic)
#   TRDPFTPT = full/part time (1=full, 2=part)
#   TRSPPRES = spouse present (1=yes, 2=yes unmarried partner, 3=no)
#   TUDIARYDAY = diary day (1=Sun, 2=Mon, ..., 7=Sat)
#   TRHOLIDAY = holiday (0=no, 1=yes)
#   TUFNWGTP = final weight
#
# Time Use (in minutes):
#   t15XXXX = Volunteering activities (major category 15)
#   t0401XX = Caring for non-household children (grandchildren)
#   t0403XX = Caring for non-household adults
#   t100103 = Civic participation

# -----------------------------------------------------------------------------
# Identify time use variables
# -----------------------------------------------------------------------------

# Volunteering (category 15)
vol_cols <- names(atus_raw)[grepl("^t15", names(atus_raw))]
cat("Volunteering columns:", length(vol_cols), "\n")

# Caring for non-household children (category 0401 - includes grandchildren)
care_nonhh_child_cols <- names(atus_raw)[grepl("^t0401", names(atus_raw))]
cat("Care for non-HH children columns:", length(care_nonhh_child_cols), "\n")

# Caring for non-household adults (category 0403)
care_nonhh_adult_cols <- names(atus_raw)[grepl("^t0403", names(atus_raw))]
cat("Care for non-HH adults columns:", length(care_nonhh_adult_cols), "\n")

# Civic/political activities (category 10)
civic_cols <- names(atus_raw)[grepl("^t10", names(atus_raw))]
cat("Civic/political columns:", length(civic_cols), "\n")

# Religious activities (category 14)
religious_cols <- names(atus_raw)[grepl("^t14", names(atus_raw))]
cat("Religious columns:", length(religious_cols), "\n")

# -----------------------------------------------------------------------------
# Construct analysis dataset
# -----------------------------------------------------------------------------

cat("\nConstructing analysis variables...\n")

atus <- atus_raw %>%
  # Calculate time use totals
  mutate(
    # Primary outcome: volunteering
    volunteer_mins = rowSums(across(all_of(vol_cols)), na.rm = TRUE),

    # Secondary outcomes
    care_grandchild_mins = rowSums(across(all_of(care_nonhh_child_cols)), na.rm = TRUE),
    care_adult_mins = rowSums(across(all_of(care_nonhh_adult_cols)), na.rm = TRUE),
    civic_mins = rowSums(across(all_of(civic_cols)), na.rm = TRUE),
    religious_mins = rowSums(across(all_of(religious_cols)), na.rm = TRUE),

    # Total pro-social time
    total_prosocial_mins = volunteer_mins + care_grandchild_mins + care_adult_mins + civic_mins
  ) %>%
  # Select and rename key variables
  select(
    caseid = TUCASEID,
    year = TUYEAR,
    age = TEAGE,
    sex = TESEX,
    education = PEEDUCA,
    race = PTDTRACE,
    hispanic = PEHSPNON,
    spouse_present = TRSPPRES,
    fulltime = TRDPFTPT,
    diary_day = TUDIARYDAY,
    holiday = TRHOLIDAY,
    weight = TUFNWGTP,
    volunteer_mins,
    care_grandchild_mins,
    care_adult_mins,
    civic_mins,
    religious_mins,
    total_prosocial_mins
  ) %>%
  # Create derived variables
  mutate(
    # Demographics
    female = as.integer(sex == 2),
    college = as.integer(education >= 43),  # Bachelor's or higher
    white = as.integer(race == 1),
    married = as.integer(spouse_present == 1),  # Spouse present in household

    # Day of week
    weekend = as.integer(diary_day %in% c(1, 7)),  # Sunday=1, Saturday=7
    weekday = 1 - weekend,

    # Binary outcomes
    any_volunteer = as.integer(volunteer_mins > 0),
    any_care_grandchild = as.integer(care_grandchild_mins > 0),
    any_care_adult = as.integer(care_adult_mins > 0),
    any_civic = as.integer(civic_mins > 0),
    any_prosocial = as.integer(total_prosocial_mins > 0),

    # Treatment indicator
    post62 = as.integer(age >= 62),

    # Centered age (for RDD)
    age_centered = age - 62
  ) %>%
  # Filter to analysis sample
  filter(
    age >= 55 & age <= 70,  # Primary bandwidth
    !is.na(age),
    !is.na(volunteer_mins),
    !is.na(weight),
    weight > 0
  )

cat("Analysis sample size:", nrow(atus), "\n")

# -----------------------------------------------------------------------------
# Summary Statistics
# -----------------------------------------------------------------------------

cat("\n--- Sample Summary ---\n")
cat("Years covered:", min(atus$year), "-", max(atus$year), "\n")
cat("Age range:", min(atus$age), "-", max(atus$age), "\n")

cat("\nObservations by age:\n")
print(table(atus$age))

cat("\nMean volunteering rate by age:\n")
vol_by_age <- atus %>%
  group_by(age) %>%
  summarise(
    n = n(),
    pct_volunteer = round(100 * mean(any_volunteer), 2),
    mean_mins = round(mean(volunteer_mins), 1),
    .groups = "drop"
  )
print(vol_by_age)

cat("\nMean care for grandchildren by age:\n")
care_by_age <- atus %>%
  group_by(age) %>%
  summarise(
    n = n(),
    pct_care = round(100 * mean(any_care_grandchild), 2),
    mean_mins = round(mean(care_grandchild_mins), 1),
    .groups = "drop"
  )
print(care_by_age)

# Overall demographics
cat("\nDemographic Summary:\n")
cat("Female:", round(100 * mean(atus$female), 1), "%\n")
cat("College:", round(100 * mean(atus$college), 1), "%\n")
cat("White:", round(100 * mean(atus$white), 1), "%\n")
cat("Married:", round(100 * mean(atus$married, na.rm = TRUE), 1), "%\n")
cat("Weekend diary:", round(100 * mean(atus$weekend), 1), "%\n")

# -----------------------------------------------------------------------------
# Save analysis dataset
# -----------------------------------------------------------------------------

cat("\n--- Saving Data ---\n")
saveRDS(atus, paste0(data_dir, "atus_analysis.rds"))
write_csv(atus, paste0(data_dir, "atus_analysis.csv"))

# Also save summary by age for quick reference
saveRDS(vol_by_age, paste0(data_dir, "vol_by_age.rds"))

cat("Analysis data saved to:", paste0(data_dir, "atus_analysis.rds"), "\n")

cat("\n" , "=" %>% strrep(70), "\n")
cat("Data cleaning complete!\n")
cat("=" %>% strrep(70), "\n")
