# ============================================================================
# Paper 66: Automatic Voter Registration
# Script 02: Data Cleaning
# ============================================================================

library(tidyverse)

cat("============================================================\n")
cat("DATA CLEANING\n")
cat("============================================================\n\n")

# Load raw CPS Voting data
cps_raw <- readRDS("data/cps_voting_raw.rds")
cat(sprintf("Raw data: %s observations\n", formatC(nrow(cps_raw), big.mark=",")))

# Load AVR treatment database
avr_db <- read_csv("data/avr_treatment_database.csv", show_col_types = FALSE)

# ============================================================================
# Clean and recode variables
# ============================================================================

cps_clean <- cps_raw %>%
  mutate(
    # Convert to numeric
    across(c(PES1, PES2, GESTFIPS, PESEX, PRTAGE, PTDTRACE, PEEDUCA, PEMLR, HEFAMINC, PWSSWGT), as.numeric),

    # Registration (PES1: 1=Yes, 2=No, -1=Not in universe/-2=Don't know/-3=Refused)
    registered = case_when(
      PES1 == 1 ~ 1,
      PES1 == 2 ~ 0,
      TRUE ~ NA_real_
    ),

    # Voted (PES2: 1=Yes, 2=No, 3=Don't know, -1=Not in universe)
    voted = case_when(
      PES2 == 1 ~ 1,
      PES2 == 2 ~ 0,
      TRUE ~ NA_real_
    ),

    # State FIPS as character
    state_fips = sprintf("%02d", GESTFIPS),

    # Demographics
    female = if_else(PESEX == 2, 1, 0),
    age = PRTAGE,
    age_group = case_when(
      age >= 18 & age <= 29 ~ "18-29",
      age >= 30 & age <= 44 ~ "30-44",
      age >= 45 & age <= 64 ~ "45-64",
      age >= 65 ~ "65+",
      TRUE ~ NA_character_
    ),

    # Race (PTDTRACE: 1=White, 2=Black, 3=AI/AN, 4=Asian, etc.)
    race = case_when(
      PTDTRACE == 1 ~ "White",
      PTDTRACE == 2 ~ "Black",
      PTDTRACE == 4 ~ "Asian",
      PTDTRACE %in% c(3, 5:26) ~ "Other",
      TRUE ~ NA_character_
    ),

    # Education (PEEDUCA codes vary by year, simplified)
    college = if_else(PEEDUCA >= 40, 1, 0, missing = 0),

    # Income quartile
    income_quartile = ntile(HEFAMINC, 4),

    # Weight
    weight = PWSSWGT
  ) %>%

  # Keep only valid observations (18+, answered registration question)
  filter(
    age >= 18,
    !is.na(registered)
  )

cat(sprintf("After cleaning: %s observations\n", formatC(nrow(cps_clean), big.mark=",")))

# ============================================================================
# Merge with AVR treatment
# ============================================================================

cps_analysis <- cps_clean %>%
  left_join(
    avr_db %>% select(state_fips, state_abbr, ever_treated, cohort, avr_effective),
    by = "state_fips"
  ) %>%
  mutate(
    # Treatment indicator: AVR in effect by election
    # Election happens in November, AVR effective date matters
    treated = case_when(
      !ever_treated ~ 0,
      is.na(cohort) ~ 0,
      year >= cohort ~ 1,  # Treated if year >= cohort year
      TRUE ~ 0
    ),

    # Event time (relative to AVR adoption)
    event_time = if_else(ever_treated, year - cohort, NA_integer_)
  )

# Check treatment assignment
cat("\nTreatment summary:\n")
cps_analysis %>%
  group_by(year, treated) %>%
  summarize(n = n(), .groups = "drop") %>%
  pivot_wider(names_from = treated, values_from = n, names_prefix = "treated_") %>%
  print()

# ============================================================================
# Create state-year aggregates
# ============================================================================

state_year <- cps_analysis %>%
  group_by(state_fips, state_abbr, year, ever_treated, cohort, treated) %>%
  summarize(
    # Outcomes (weighted)
    reg_rate = weighted.mean(registered, weight, na.rm = TRUE),
    vote_rate = weighted.mean(voted, weight, na.rm = TRUE),

    # Unweighted for comparison
    reg_rate_unw = mean(registered, na.rm = TRUE),
    vote_rate_unw = mean(voted, na.rm = TRUE),

    # Sample size
    n_obs = n(),
    n_reg = sum(registered == 1, na.rm = TRUE),
    n_vote = sum(voted == 1, na.rm = TRUE),

    .groups = "drop"
  )

cat("\nState-year panel created:", nrow(state_year), "state-year observations\n")

# ============================================================================
# Save cleaned data
# ============================================================================

saveRDS(cps_analysis, "data/cps_analysis_individual.rds")
saveRDS(state_year, "data/state_year_panel.rds")

cat("\n✓ Cleaned data saved:\n")
cat("  - data/cps_analysis_individual.rds\n")
cat("  - data/state_year_panel.rds\n")

cat("\n============================================================\n")
cat("DATA CLEANING COMPLETE\n")
cat("============================================================\n")
