# ==============================================================================
# Paper 86: Minimum Wage and Teen Time Allocation
# 02_clean_data.R - Load IPUMS ATUS data and prepare analysis file
# ==============================================================================

source("00_packages.R")

cat("\n=== Loading and Cleaning Data ===\n")

data_dir <- "../data"

# ==============================================================================
# 1. Load IPUMS ATUS Data
# ==============================================================================

cat("\nLoading IPUMS ATUS data...\n")

# Find the DDI file
ddi_file <- list.files(data_dir, pattern = "\\.xml$", full.names = TRUE)[1]
dat_file <- list.files(data_dir, pattern = "\\.dat\\.gz$", full.names = TRUE)[1]

cat("DDI file:", ddi_file, "\n")
cat("Data file:", dat_file, "\n")

# Read using ipumsr
ddi <- read_ipums_ddi(ddi_file)
atus_raw <- read_ipums_micro(ddi, verbose = TRUE)

cat("\nATUS data loaded:", nrow(atus_raw), "rows,", ncol(atus_raw), "columns\n")
cat("Variables:", paste(names(atus_raw), collapse = ", "), "\n")

# Convert to data.table for efficiency
atus <- as.data.table(atus_raw)

# ==============================================================================
# 2. Filter to Teens (16-19)
# ==============================================================================

cat("\nFiltering to teens (ages 16-19)...\n")

# Check age distribution
cat("Age distribution before filter:\n")
print(table(atus$AGE))

# Filter to teens
atus <- atus[AGE >= 16 & AGE <= 19]

cat("\nTeen sample size:", nrow(atus), "\n")
cat("Years:", range(atus$YEAR), "\n")

# ==============================================================================
# 3. Create State Minimum Wage Panel
# ==============================================================================

cat("\nCreating minimum wage panel...\n")

# State FIPS codes
state_info <- data.table(
  STATEFIP = c(1, 2, 4, 5, 6, 8, 9, 10, 11, 12, 13, 15, 16, 17, 18, 19, 20,
               21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35,
               36, 37, 38, 39, 40, 41, 42, 44, 45, 46, 47, 48, 49, 50, 51,
               53, 54, 55, 56),
  state_abbr = c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "FL",
                 "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME",
                 "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH",
                 "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI",
                 "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI",
                 "WY")
)

# Load or create MW panel
mw_file <- file.path(data_dir, "state_mw_panel.csv")
if (file.exists(mw_file)) {
  mw_panel <- fread(mw_file)
  cat("Loaded MW panel from file\n")
} else {
  # Create MW panel if not exists (run 01_fetch_data.R first)
  source("01_fetch_data.R")
  mw_panel <- fread(mw_file)
}

# ==============================================================================
# 4. Merge ATUS with MW Data
# ==============================================================================

cat("\nMerging ATUS with MW data...\n")

# Create merge keys
atus[, year_month := YEAR * 12 + MONTH]

# Subset MW panel to needed columns
mw_merge <- mw_panel[, .(
  STATEFIP = statefip,
  year = year,
  month = month,
  year_month,
  effective_mw,
  federal_mw,
  mw_above_federal,
  first_treat_ym
)]

# Merge
atus <- merge(atus, mw_merge,
              by.x = c("STATEFIP", "YEAR", "MONTH", "year_month"),
              by.y = c("STATEFIP", "year", "month", "year_month"),
              all.x = TRUE)

cat("After merge:", nrow(atus), "rows\n")
cat("MW data coverage:", sum(!is.na(atus$effective_mw)), "/", nrow(atus), "\n")

# ==============================================================================
# 5. Create Analysis Variables
# ==============================================================================

cat("\nCreating analysis variables...\n")

# Employment status (recode IPUMS codes)
# EMPSTAT: 1=Employed at work, 2=Employed absent, 3=Unemployed layoff,
#          4=Unemployed looking, 5=Not in labor force
atus[, employed := EMPSTAT %in% c(1, 2)]
atus[, unemployed := EMPSTAT %in% c(3, 4)]
atus[, nilf := EMPSTAT == 5]

# MW-sensitive industries
# IND2: ATUS industry codes (based on NAICS but 3-digit)
# 160 = Retail trade
# 270-271 = Accommodation and food services
# 290-292 = Arts, entertainment, recreation
atus[, mw_industry := IND2 %in% c(160, 270, 271, 290, 291, 292)]
atus[is.na(mw_industry), mw_industry := FALSE]

# School enrollment
# IPUMS ATUS SCHLCOLL codes:
#   1 = Not enrolled
#   2 = High school part-time
#   3 = High school full-time
#   4 = College/university part-time
#   5 = College/university full-time
#   96 = Refused
#   99 = NIU (Not in universe)
atus[, enrolled := SCHLCOLL %in% c(2, 3, 4, 5)]
atus[, enrolled_hs := SCHLCOLL %in% c(2, 3)]
atus[, enrolled_college := SCHLCOLL %in% c(4, 5)]

# Demographics
atus[, female := SEX == 2]
atus[, white := RACE == 100]
atus[, black := RACE == 200]
atus[, hispanic := HISPAN > 0]

# Treatment: MW above federal
atus[is.na(mw_above_federal), mw_above_federal := FALSE]

# Log MW (for continuous treatment)
atus[, log_mw := log(effective_mw)]
atus[, log_federal := log(federal_mw)]
atus[, mw_gap := effective_mw - federal_mw]

# Relative time to first treatment (for event study)
atus[first_treat_ym > 0, rel_time := year_month - first_treat_ym]
atus[first_treat_ym == 0, rel_time := NA_integer_]  # Never treated

# ==============================================================================
# 6. Time Use Variables
# ==============================================================================

cat("\nProcessing time use variables...\n")

# IPUMS ATUS provides activity-level data or pre-computed totals
# Check what we have
time_vars <- grep("^BLS_|^ACT_|^t_|TIME", names(atus), value = TRUE, ignore.case = TRUE)
cat("Time use variables found:", paste(time_vars, collapse = ", "), "\n")

# If we have the standard BLS summary variables:
# - BLS_WORK: Work and work-related activities
# - BLS_CARENHH: Caring for non-household members
# - BLS_EDUC: Educational activities
# - BLS_SOCL: Socializing, relaxing, leisure
# - BLS_SPORTS: Sports, exercise, recreation
# - BLS_TRAVEL: Traveling
# - BLS_PCARE: Personal care
# - BLS_SLEEP: Sleeping

# If we don't have time use variables directly, we need to compute from activity records
# For now, create placeholder totals based on what IPUMS provides

# Check if common time use variables exist
if ("BLS_WORK" %in% names(atus)) {
  atus[, work_time := BLS_WORK]
} else if ("ACT_WORK" %in% names(atus)) {
  atus[, work_time := ACT_WORK]
} else {
  # Placeholder - would need activity-level data
  cat("WARNING: Work time variable not found in extract\n")
  cat("Time use variables need to be added via IPUMS extract system\n")
  atus[, work_time := NA_real_]
}

# Similar for other time use categories
# Education time
if ("BLS_EDUC" %in% names(atus)) {
  atus[, educ_time := BLS_EDUC]
} else if ("ACT_EDUC" %in% names(atus)) {
  atus[, educ_time := ACT_EDUC]
} else {
  atus[, educ_time := NA_real_]
}

# Leisure time
if ("BLS_SOCL" %in% names(atus)) {
  atus[, leisure_time := BLS_SOCL]
} else if ("ACT_SOCIAL" %in% names(atus)) {
  atus[, leisure_time := ACT_SOCIAL]
} else {
  atus[, leisure_time := NA_real_]
}

# Sleep
if ("BLS_SLEEP" %in% names(atus)) {
  atus[, sleep_time := BLS_SLEEP]
} else if ("ACT_SLEEP" %in% names(atus)) {
  atus[, sleep_time := ACT_SLEEP]
} else {
  atus[, sleep_time := NA_real_]
}

# Job search (typically small category)
if ("BLS_JOBSRCH" %in% names(atus)) {
  atus[, jobsearch_time := BLS_JOBSRCH]
} else {
  atus[, jobsearch_time := NA_real_]
}

# Household activities
if ("BLS_HHACT" %in% names(atus)) {
  atus[, hhact_time := BLS_HHACT]
} else {
  atus[, hhact_time := NA_real_]
}

# Personal care
if ("BLS_PCARE" %in% names(atus)) {
  atus[, pcare_time := BLS_PCARE]
} else {
  atus[, pcare_time := NA_real_]
}

# ==============================================================================
# 7. Sample Definitions
# ==============================================================================

cat("\nDefining analysis samples...\n")

# Full teen sample
atus[, sample_all := TRUE]

# Working teens
atus[, sample_employed := employed == TRUE]

# Working teens in MW-sensitive industries
atus[, sample_mw_workers := employed == TRUE & mw_industry == TRUE]

# Non-working teens
atus[, sample_nonworking := employed == FALSE]

# Enrolled teens
atus[, sample_enrolled := enrolled == TRUE]

# Sample sizes
cat("\nSample sizes:\n")
cat("  All teens:", sum(atus$sample_all), "\n")
cat("  Employed:", sum(atus$sample_employed), "\n")
cat("  MW workers:", sum(atus$sample_mw_workers), "\n")
cat("  Non-working:", sum(atus$sample_nonworking), "\n")
cat("  Enrolled:", sum(atus$sample_enrolled), "\n")

# ==============================================================================
# 8. Create Weights
# ==============================================================================

# ATUS provides sampling weights
# Look for WT06 (final weight) or similar
wt_vars <- grep("^WT|WEIGHT", names(atus), value = TRUE, ignore.case = TRUE)
cat("\nWeight variables found:", paste(wt_vars, collapse = ", "), "\n")

if ("WT06" %in% names(atus)) {
  atus[, weight := WT06]
} else if (length(wt_vars) > 0) {
  atus[, weight := get(wt_vars[1])]
} else {
  cat("WARNING: No weight variable found, using equal weights\n")
  atus[, weight := 1]
}

# ==============================================================================
# 9. Save Analysis File
# ==============================================================================

cat("\nSaving analysis dataset...\n")

# Select final variables
analysis_vars <- c(
  # Identifiers
  "YEAR", "MONTH", "STATEFIP", "year_month",

  # Demographics
  "AGE", "female", "white", "black", "hispanic",

  # Employment
  "employed", "unemployed", "nilf", "mw_industry",
  "EMPSTAT", "IND2",

  # Education
  "enrolled", "enrolled_hs", "enrolled_college", "SCHLCOLL",

  # Income
  "FAMINCOME", "EARNWEEK",

  # MW treatment
  "effective_mw", "federal_mw", "mw_above_federal", "mw_gap", "log_mw",
  "first_treat_ym", "rel_time",

  # Time use (may be NA)
  "work_time", "educ_time", "leisure_time", "sleep_time",
  "jobsearch_time", "hhact_time", "pcare_time",

  # Samples
  "sample_all", "sample_employed", "sample_mw_workers",
  "sample_nonworking", "sample_enrolled",

  # Weight
  "weight"
)

# Keep only variables that exist
analysis_vars <- intersect(analysis_vars, names(atus))

analysis_data <- atus[, ..analysis_vars]

# Save
fwrite(analysis_data, file.path(data_dir, "analysis_data.csv"))
saveRDS(analysis_data, file.path(data_dir, "analysis_data.rds"))

cat("\nAnalysis dataset saved:\n")
cat("  Rows:", nrow(analysis_data), "\n")
cat("  Columns:", ncol(analysis_data), "\n")
cat("  File:", file.path(data_dir, "analysis_data.rds"), "\n")

# ==============================================================================
# 10. Summary Statistics
# ==============================================================================

cat("\n=== Summary Statistics ===\n")

# By treatment status
cat("\nBy MW treatment status:\n")
print(analysis_data[, .(
  n = .N,
  pct_employed = mean(employed) * 100,
  pct_enrolled = mean(enrolled) * 100,
  mean_age = mean(AGE)
), by = mw_above_federal])

# By year
cat("\nSample by year:\n")
print(analysis_data[, .N, by = YEAR][order(YEAR)])

# Treatment adoption over time
cat("\nTreatment (MW > federal) over time:\n")
print(analysis_data[, .(
  n = .N,
  pct_treated = mean(mw_above_federal) * 100
), by = YEAR][order(YEAR)])

cat("\n=== Data Preparation Complete ===\n")
