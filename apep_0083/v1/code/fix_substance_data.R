# =============================================================================
# Paper 108: Fix substance involvement data
# This script corrects THC and alcohol indicators
# =============================================================================

source(here::here("output/paper_108/code/00_packages.R"))

# Load existing analysis data
fars <- readRDS(file.path(dir_data, "fars_analysis_policy.rds"))
message("Loaded ", nrow(fars), " crashes")

# =============================================================================
# 1. Fix Alcohol Indicator using drunk_dr from accident file
# =============================================================================

message("\nFixing alcohol indicator...")

# drunk_dr is number of drunk drivers in crash (from ACCIDENT file)
# This is more reliable than the buggy any_alc_positive from person file
fars$alc_involved <- fars$drunk_dr >= 1

# Summary
message("Alcohol involvement: ", sum(fars$alc_involved, na.rm=TRUE), " crashes (",
        round(100 * mean(fars$alc_involved, na.rm=TRUE), 1), "%)")

# =============================================================================
# 2. Fix THC Indicator from DRUGS file using text matching
# =============================================================================

message("\nFixing THC indicator from drugs file...")

# Load raw drugs data
drugs <- readRDS(file.path(dir_data_raw, "fars_drugs_all.rds"))
drugs <- drugs %>% filter(!is.na(state))

# Filter to Western states
drugs_west <- drugs %>%
  mutate(state_fips = sprintf("%02d", as.numeric(state))) %>%
  filter(state_fips %in% WESTERN_FIPS)

message("Drugs records in Western states: ", nrow(drugs_west))

# Detect THC/cannabinoid positive results using text pattern in drugresname
# Patterns: THC, Tetrahydrocannabinol, DELTA 9, Cannabinoid, Marijuana
thc_pattern <- "CANNAB|THC|DELTA.?9|MARIJUANA|TETRAHYDRO"

thc_crashes <- drugs_west %>%
  filter(grepl(thc_pattern, drugresname, ignore.case = TRUE)) %>%
  distinct(st_case, state, year) %>%
  mutate(thc_positive_fixed = TRUE)

message("THC-positive crashes found: ", nrow(thc_crashes))

# Check distribution by year
thc_by_year <- thc_crashes %>%
  count(year) %>%
  arrange(year)
message("\nTHC-positive crashes by year:")
print(as.data.frame(thc_by_year))

# =============================================================================
# 3. Merge fixed indicators back to main data
# =============================================================================

message("\nMerging fixed indicators...")

# Add THC fix
fars <- fars %>%
  left_join(
    thc_crashes %>% select(st_case, state, year, thc_positive_fixed),
    by = c("st_case", "state", "year")
  ) %>%
  mutate(
    thc_positive_fixed = ifelse(is.na(thc_positive_fixed), FALSE, thc_positive_fixed)
  )

# Update substance category
fars <- fars %>%
  mutate(
    substance_cat_fixed = case_when(
      thc_positive_fixed & alc_involved ~ "Both",
      thc_positive_fixed ~ "THC Positive",
      alc_involved ~ "Alcohol Only",
      TRUE ~ "Neither/Unknown"
    )
  )

# =============================================================================
# 4. Summary of fixed data
# =============================================================================

message("\n", strrep("=", 60))
message("FIXED SUBSTANCE DATA SUMMARY")
message(strrep("=", 60))

message("\nAlcohol involvement by year:")
alc_summary <- fars %>%
  group_by(year) %>%
  summarise(
    crashes = n(),
    alc_inv = sum(alc_involved, na.rm = TRUE),
    pct_alc = round(100 * alc_inv / crashes, 1)
  )
print(as.data.frame(alc_summary))

message("\nTHC-positive rate by year (all Western states):")
thc_summary <- fars %>%
  group_by(year) %>%
  summarise(
    crashes = n(),
    thc_pos = sum(thc_positive_fixed, na.rm = TRUE),
    pct_thc = round(100 * thc_pos / crashes, 1)
  )
print(as.data.frame(thc_summary))

message("\nTHC-positive rate by year (legal states only: CO, WA, OR, CA, NV, AK):")
legal_states <- c("08", "53", "41", "06", "32", "02")
thc_legal <- fars %>%
  filter(state_fips %in% legal_states) %>%
  group_by(year) %>%
  summarise(
    crashes = n(),
    thc_pos = sum(thc_positive_fixed, na.rm = TRUE),
    pct_thc = round(100 * thc_pos / crashes, 1)
  )
print(as.data.frame(thc_legal))

# =============================================================================
# 5. Save fixed data
# =============================================================================

saveRDS(fars, file.path(dir_data, "fars_analysis_policy_fixed.rds"))
message("\nFixed data saved to: fars_analysis_policy_fixed.rds")

message("\n", strrep("=", 60))
message("Data fix complete!")
message(strrep("=", 60))
