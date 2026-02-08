# ============================================================================
# Paper 74: Dental Therapy and Oral Health Access
# 01_treatment_timing.R - Define treatment timing for all states
# ============================================================================

source("output/paper_74/code/00_packages.R")

# ============================================================================
# Dental Therapy Authorization Dates
# Sources:
# - Oral Health Workforce Research Center (oralhealthworkforce.org)
# - ADHA Dental Therapy Authorization by State Law
# - Individual state legislative records
# ============================================================================

# Treatment year is the year legislation was signed/enacted
# Effects likely lag by 1-2 years (time for training programs, hiring)

dental_therapy_treatment <- tibble(
  state = c(
    # Adopters (in chronological order)
    "Minnesota",    # 2009 - First state, SF 2083
    "Maine",        # 2014 - LD 1230
    "Vermont",      # 2016 - S.20
    "Arizona",      # 2018 - SB 1377
    "Michigan",     # 2018 - PA 463
    "New Mexico",   # 2018 - HB 283
    "Nevada",       # 2019 - SB 366
    "Idaho",        # 2019 - HB 289
    "Washington",   # 2020 - HB 2551
    "Oregon",       # 2020 - HB 2528
    "Connecticut",  # 2021 - HB 6669
    "Colorado",     # 2022 - SB 22-083
    "Wisconsin",    # 2024 - AB 715 (may be outside data window)

    # Never-treated states (as of 2023)
    "Alabama", "Alaska", "Arkansas", "California", "Delaware",
    "Florida", "Georgia", "Hawaii", "Illinois", "Indiana",
    "Iowa", "Kansas", "Kentucky", "Louisiana", "Maryland",
    "Massachusetts", "Mississippi", "Missouri", "Montana",
    "Nebraska", "New Hampshire", "New Jersey", "New York",
    "North Carolina", "North Dakota", "Ohio", "Oklahoma",
    "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota",
    "Tennessee", "Texas", "Utah", "Virginia", "West Virginia",
    "Wyoming"
  ),

  treatment_year = c(
    # Adopters
    2009, 2014, 2016, 2018, 2018, 2018, 2019, 2019, 2020, 2020, 2021, 2022, 2024,

    # Never-treated (coded as 0 for Callaway-Sant'Anna)
    rep(0, 37)
  )
)

# Add state FIPS codes
state_fips <- tibble(
  state = c(
    "Alabama", "Alaska", "Arizona", "Arkansas", "California",
    "Colorado", "Connecticut", "Delaware", "Florida", "Georgia",
    "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa",
    "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland",
    "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri",
    "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey",
    "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio",
    "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina",
    "South Dakota", "Tennessee", "Texas", "Utah", "Vermont",
    "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming"
  ),
  state_fips = sprintf("%02d", c(
    1, 2, 4, 5, 6, 8, 9, 10, 12, 13, 15, 16, 17, 18, 19,
    20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34,
    35, 36, 37, 38, 39, 40, 41, 42, 44, 45, 46, 47, 48, 49, 50,
    51, 53, 54, 55, 56
  ))
)

# Join and verify
treatment_data <- dental_therapy_treatment %>%
  left_join(state_fips, by = "state") %>%
  arrange(treatment_year, state)

# Check for missing FIPS
missing_fips <- treatment_data %>% filter(is.na(state_fips))
if (nrow(missing_fips) > 0) {
  warning("Missing FIPS codes for: ", paste(missing_fips$state, collapse = ", "))
}

# Summary
cat("\n========================================\n")
cat("TREATMENT TIMING SUMMARY\n")
cat("========================================\n")

treatment_data %>%
  group_by(treatment_year) %>%
  summarise(
    n_states = n(),
    states = paste(state, collapse = ", ")
  ) %>%
  print(n = 20)

# Save
saveRDS(treatment_data, "output/paper_74/data/treatment_timing.rds")
write_csv(treatment_data, "output/paper_74/data/treatment_timing.csv")

cat("\nTreatment timing saved to data/treatment_timing.rds\n")
