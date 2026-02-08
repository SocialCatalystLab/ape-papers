# ==============================================================================
# Paper 63: State EITC and Single Mothers' Self-Employment
# 03_policy_data.R - Construct state EITC policy panel
# ==============================================================================

source("00_packages.R")

# ==============================================================================
# State EITC Adoption Years (Primary Source: ITEP, NCSL, NBER TAXSIM)
# ==============================================================================

# Year each state first enacted a state EITC
eitc_adoption <- tribble(
  ~statefip, ~state, ~year_enacted,
  44, "Rhode Island", 1986,
  24, "Maryland", 1987,
  50, "Vermont", 1988,
  55, "Wisconsin", 1989,
  19, "Iowa", 1989,
  27, "Minnesota", 1991,
  36, "New York", 1994,
  25, "Massachusetts", 1997,
  41, "Oregon", 1997,
  20, "Kansas", 1998,
  8, "Colorado", 1999,
  18, "Indiana", 1999,
  17, "Illinois", 2000,
  34, "New Jersey", 2000,
  23, "Maine", 2000,
  11, "District of Columbia", 2000,
  40, "Oklahoma", 2002,
  51, "Virginia", 2004,
  10, "Delaware", 2005,
  26, "Michigan", 2006,
  31, "Nebraska", 2006,
  22, "Louisiana", 2007,
  35, "New Mexico", 2007,
  37, "North Carolina", 2008,  # Repealed 2014
  9, "Connecticut", 2011,
  39, "Ohio", 2013,
  6, "California", 2015,
  15, "Hawaii", 2017,
  45, "South Carolina", 2018,
  30, "Montana", 2019,
  53, "Washington", 2021,
  49, "Utah", 2022,
  29, "Missouri", 2023
)

# Note: North Carolina repealed its EITC in 2014
# We will treat NC as treated 2008-2013, then reverted

# ==============================================================================
# Create state-year panel of EITC status (1990-2023)
# ==============================================================================

years <- 1990:2023

# All state FIPS codes
all_states <- tibble(
  statefip = c(1:2, 4:6, 8:13, 15:42, 44:51, 53:56),
  state = c("Alabama", "Alaska", "Arizona", "Arkansas", "California",
            "Colorado", "Connecticut", "Delaware", "District of Columbia", "Florida",
            "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana",
            "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine",
            "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi",
            "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire",
            "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota",
            "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island",
            "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah",
            "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin",
            "Wyoming")
)

# Create full panel
state_year_panel <- expand_grid(statefip = all_states$statefip, year = years) %>%
  left_join(all_states, by = "statefip") %>%
  left_join(eitc_adoption %>% select(statefip, year_enacted), by = "statefip")

# Create treatment indicator
state_year_panel <- state_year_panel %>%
  mutate(
    # Basic treatment indicator (1 if state has EITC in that year)
    has_state_eitc = case_when(
      is.na(year_enacted) ~ 0,
      # Special case: North Carolina repealed in 2014
      statefip == 37 & year >= 2014 ~ 0,
      year >= year_enacted ~ 1,
      TRUE ~ 0
    ),
    # Cohort (year of adoption for CS estimator)
    cohort = case_when(
      is.na(year_enacted) ~ Inf,  # Never treated
      statefip == 37 ~ Inf,  # NC treated then repealed - exclude from cohort
      TRUE ~ as.numeric(year_enacted)
    ),
    # Time since treatment
    time_since_treat = case_when(
      cohort == Inf ~ NA_real_,
      TRUE ~ year - cohort
    )
  )

# ==============================================================================
# State EITC Generosity (% of federal, by year)
# ==============================================================================

# This is a simplified version - can be expanded with full year-by-year rates
# For now, use 2024 rates as proxy for relative generosity

eitc_generosity <- tribble(
  ~statefip, ~rate_2024, ~refundable,
  6, 47, 1,   # California
  8, 50, 1,   # Colorado
  9, 30.5, 1, # Connecticut
  10, 20, 1,  # Delaware
  11, 70, 1,  # DC
  15, 40, 1,  # Hawaii
  17, 20, 1,  # Illinois
  18, 10, 1,  # Indiana
  19, 15, 1,  # Iowa
  20, 17, 1,  # Kansas
  22, 5, 1,   # Louisiana
  23, 12, 1,  # Maine
  24, 45, 1,  # Maryland
  25, 40, 1,  # Massachusetts
  26, 30, 1,  # Michigan
  27, 37, 1,  # Minnesota (own calculation)
  29, 10, 0,  # Missouri (non-refundable)
  30, 10, 1,  # Montana
  31, 10, 1,  # Nebraska
  34, 40, 1,  # New Jersey
  35, 25, 1,  # New Mexico
  36, 30, 1,  # New York
  39, 30, 0,  # Ohio (non-refundable)
  40, 5, 0,   # Oklahoma (non-refundable since 2016)
  41, 12, 1,  # Oregon
  44, 16, 1,  # Rhode Island
  45, 125, 0, # South Carolina (non-refundable)
  49, 20, 0,  # Utah (non-refundable)
  50, 38, 1,  # Vermont
  51, 20, 1,  # Virginia
  53, 15, 1,  # Washington
  55, 15, 1   # Wisconsin (using avg of 4-34)
)

state_year_panel <- state_year_panel %>%
  left_join(eitc_generosity, by = "statefip") %>%
  mutate(
    rate_2024 = replace_na(rate_2024, 0),
    refundable = replace_na(refundable, NA)
  )

# ==============================================================================
# Save policy data
# ==============================================================================

write_csv(state_year_panel, file.path(data_path, "state_eitc_panel.csv"))

message("State EITC policy panel created: ", nrow(state_year_panel), " state-years")
message("States with EITC: ", n_distinct(eitc_adoption$statefip))
message("Never-treated states: ", n_distinct(state_year_panel$statefip) - n_distinct(eitc_adoption$statefip))

# Summary
state_year_panel %>%
  group_by(has_state_eitc) %>%
  summarise(
    n_state_years = n(),
    n_states = n_distinct(statefip)
  ) %>%
  print()

# Adoption timeline
eitc_adoption %>%
  arrange(year_enacted) %>%
  print(n = 40)
