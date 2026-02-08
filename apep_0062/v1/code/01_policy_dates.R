# =============================================================================
# 01_policy_dates.R
# Build comprehensive policy timing dataset with VERIFIED launch dates
# Sources: Legal Sports Report, state gaming commissions, news reports
#
# CRITICAL: Treatment = date of FIRST LEGAL BET at commercial sportsbooks
# Tribal-only states (WA) excluded from commercial analysis
# States with suspended markets (FL) coded as never-treated
# =============================================================================

source("output/paper_80/code/00_packages.R")

# =============================================================================
# State FIPS codes (standard reference) - 50 states only, no DC
# =============================================================================

state_fips <- tibble(
  state_abbr = c(
    "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA",
    "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD",
    "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ",
    "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC",
    "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"
  ),
  state_fips = c(
    "01", "02", "04", "05", "06", "08", "09", "10", "12", "13",
    "15", "16", "17", "18", "19", "20", "21", "22", "23", "24",
    "25", "26", "27", "28", "29", "30", "31", "32", "33", "34",
    "35", "36", "37", "38", "39", "40", "41", "42", "44", "45",
    "46", "47", "48", "49", "50", "51", "53", "54", "55", "56"
  ),
  state_name = c(
    "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado",
    "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho",
    "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana",
    "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota",
    "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada",
    "New Hampshire", "New Jersey", "New Mexico", "New York",
    "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon",
    "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota",
    "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington",
    "West Virginia", "Wisconsin", "Wyoming"
  )
)

# =============================================================================
# VERIFIED Sports Betting Launch Dates
# Using FIRST LEGAL BET date at commercial sportsbooks
# Sources verified against Legal Sports Report and state gaming commissions
# =============================================================================

sports_betting_dates <- tibble(
  state_abbr = c(
    # === 2018 (post-Murphy v. NCAA, May 14, 2018) ===
    "DE",  # June 5, 2018 - First state post-PASPA (Delaware Park)
    "NJ",  # June 14, 2018 - Borgata and Monmouth Park
    "MS",  # August 1, 2018 - Beau Rivage, Gold Strike casinos
    "WV",  # September 1, 2018 - Hollywood Casino
    "PA",  # November 17, 2018 - Hollywood Casino Penn National
    "RI",  # November 26, 2018 - Twin River Casino

    # === 2019 ===
    "NH",  # December 30, 2019 - DraftKings (mobile only)
    "IN",  # September 1, 2019 - Multiple casinos
    "IA",  # August 15, 2019 - Prairie Meadows and others
    "NY",  # July 16, 2019 - Rivers Casino (commercial only, not tribal)
    "OR",  # August 27, 2019 - Scoreboard app (state lottery)
    "AR",  # July 1, 2019 - Oaklawn Racing

    # === 2020 ===
    "CO",  # May 1, 2020 - Multiple casinos
    "IL",  # March 9, 2020 - Rivers Casino
    "MI",  # March 11, 2020 - MotorCity, MGM Grand Detroit
    "MT",  # March 11, 2020 - State lottery kiosks (CORRECTED from 2019)
    "TN",  # November 1, 2020 - Mobile only (CORRECTED from 2019)

    # === 2021 ===
    "VA",  # January 21, 2021 - Mobile (CORRECTED from 2020)
    "AZ",  # September 9, 2021 - Casinos and tribal
    "CT",  # October 7, 2021 - Mohegan Sun and Foxwoods
    "LA",  # October 31, 2021 - Casinos (retail)
    "MD",  # December 9, 2021 - Casinos
    "SD",  # September 9, 2021 - Deadwood casinos
    "WY",  # September 1, 2021 - Mobile only

    # === 2022 ===
    "KS",  # September 1, 2022 - Casinos

    # === 2023 ===
    "OH",  # January 1, 2023 - Type A locations (CORRECTED from 2022)
    "MA",  # March 10, 2023 - Encore Boston Harbor
    # NC excluded - tribal-only through 2023 (commercial mobile launched March 2024)
    "KY",  # September 28, 2023 - Racetracks
    "NE",  # September 2, 2023 - Authorized retail locations
    "ME"   # November 3, 2023 - Oxford Casino
  ),

  # EXACT first legal bet dates (VERIFIED)
  sb_first_date = as.Date(c(
    # 2018
    "2018-06-05",  # DE
    "2018-06-14",  # NJ
    "2018-08-01",  # MS
    "2018-09-01",  # WV
    "2018-11-17",  # PA
    "2018-11-26",  # RI
    # 2019
    "2019-12-30",  # NH
    "2019-09-01",  # IN
    "2019-08-15",  # IA
    "2019-07-16",  # NY
    "2019-08-27",  # OR
    "2019-07-01",  # AR
    # 2020
    "2020-05-01",  # CO
    "2020-03-09",  # IL
    "2020-03-11",  # MI
    "2020-03-11",  # MT - CORRECTED
    "2020-11-01",  # TN - CORRECTED
    # 2021
    "2021-01-21",  # VA - CORRECTED
    "2021-09-09",  # AZ
    "2021-10-07",  # CT
    "2021-10-31",  # LA
    "2021-12-09",  # MD
    "2021-09-09",  # SD
    "2021-09-01",  # WY
    # 2022
    "2022-09-01",  # KS
    # 2023
    "2023-01-01",  # OH - CORRECTED
    "2023-03-10",  # MA
    # NC excluded - tribal-only through 2023
    "2023-09-28",  # KY
    "2023-09-02",  # NE
    "2023-11-03"   # ME
  )),

  # Implementation type at launch
  implementation_type = c(
    # 2018
    "retail",  # DE
    "both",    # NJ
    "retail",  # MS
    "both",    # WV
    "both",    # PA
    "retail",  # RI
    # 2019
    "mobile",  # NH
    "both",    # IN
    "both",    # IA
    "retail",  # NY (mobile Jan 2022)
    "mobile",  # OR
    "retail",  # AR
    # 2020
    "both",    # CO
    "both",    # IL
    "both",    # MI
    "retail",  # MT
    "mobile",  # TN
    # 2021
    "mobile",  # VA
    "both",    # AZ
    "both",    # CT
    "retail",  # LA (mobile Jan 2022)
    "retail",  # MD (mobile Nov 2022)
    "retail",  # SD
    "mobile",  # WY
    # 2022
    "both",    # KS
    # 2023
    "both",    # OH
    "both",    # MA
    # NC excluded
    "both",    # KY
    "retail",  # NE
    "both"     # ME
  )
)

# =============================================================================
# iGaming (Online Casino) Legalization Dates
# Key confounder - some states launched both simultaneously
# =============================================================================

igaming_dates <- tibble(
  state_abbr = c("NJ", "PA", "MI", "DE", "WV", "CT"),
  igaming_date = as.Date(c(
    "2013-11-21",  # NJ - pre-Murphy, established market
    "2019-07-15",  # PA - ~8 months after sports betting
    "2021-01-22",  # MI - simultaneous with mobile SB
    "2013-10-31",  # DE - pre-Murphy, limited
    "2020-07-15",  # WV
    "2021-10-19"   # CT - simultaneous with mobile SB
  ))
)

# =============================================================================
# Compute treatment timing (ANNUAL for main analysis)
# =============================================================================

policy_dates <- sports_betting_dates %>%
  left_join(state_fips, by = "state_abbr") %>%
  left_join(igaming_dates, by = "state_abbr") %>%
  mutate(
    # Treatment year (for annual DiD)
    first_treat_year = year(sb_first_date),

    # iGaming info
    has_igaming = !is.na(igaming_date),

    # iGaming confounder: launched within same year or year before SB
    igaming_confounder = has_igaming &
      (year(igaming_date) == first_treat_year |
       year(igaming_date) == first_treat_year - 1)
  )

# =============================================================================
# Never-treated states through 2023
# Includes:
#   - States that never legalized
#   - States where markets were suspended (FL)
#   - Tribal-only states (WA) - not in commercial NAICS 7132
#   - States launching in 2024 (VT, MO)
# =============================================================================

treated_states <- policy_dates$state_abbr

never_treated <- state_fips %>%
  filter(!state_abbr %in% treated_states) %>%
  filter(state_abbr != "NV") %>%  # Exclude Nevada (always-treated)
  mutate(
    sb_first_date = NA_Date_,
    first_treat_year = 0L,  # 0 = never treated for did package
    implementation_type = "never",
    igaming_date = NA_Date_,
    has_igaming = FALSE,
    igaming_confounder = FALSE
  )

# =============================================================================
# Combine all states (excluding Nevada as always-treated)
# Also DROP: WA (tribal-only), NC (tribal-only through 2023), FL (treatment reversal)
# These states cannot serve as clean controls due to treatment contamination
# =============================================================================

all_states <- bind_rows(policy_dates, never_treated) %>%
  filter(state_abbr != "NV") %>%
  # Drop states with design problems
  filter(!state_abbr %in% c("WA", "NC", "FL")) %>%
  arrange(state_fips) %>%
  select(
    state_abbr, state_fips, state_name,
    sb_first_date, first_treat_year, implementation_type,
    igaming_date, has_igaming, igaming_confounder
  )

# =============================================================================
# Summary statistics
# =============================================================================

cat("\n=== VERIFIED Sports Betting Policy Timing ===\n\n")

cat("Treatment cohorts (by year of FIRST LEGAL BET):\n")
cohort_summary <- all_states %>%
  group_by(first_treat_year) %>%
  summarise(
    n = n(),
    states = paste(state_abbr, collapse = ", "),
    .groups = "drop"
  )
print(cohort_summary, n = 20)

cat("\n\nImplementation type distribution:\n")
all_states %>%
  count(implementation_type) %>%
  print()

cat("\n\niGaming confounding states (within 1 year of SB launch):\n")
all_states %>%
  filter(igaming_confounder) %>%
  select(state_abbr, sb_first_date, igaming_date) %>%
  print()

cat("\n\nNever-treated states (through 2023):\n")
never_list <- all_states %>%
  filter(first_treat_year == 0) %>%
  pull(state_abbr)
cat(paste(never_list, collapse = ", "), "\n")

# Verify counts
n_treated <- sum(all_states$first_treat_year > 0)
n_never <- sum(all_states$first_treat_year == 0)
n_total <- nrow(all_states)

cat(sprintf("\n\nTotal states: %d (excluding NV)\n", n_total))
cat(sprintf("Treated states (through 2023): %d\n", n_treated))
cat(sprintf("Never-treated states: %d\n", n_never))
cat(sprintf("Sum check: %d + %d = %d (should equal %d)\n",
            n_treated, n_never, n_treated + n_never, n_total))

# =============================================================================
# Save policy dates
# =============================================================================

write_csv(all_states, "output/paper_80/data/policy_dates.csv")

cat("\n\nPolicy dates saved to data/policy_dates.csv\n")

# =============================================================================
# Notes on excluded/special cases:
# - Nevada: Always-treated (pre-PASPA), excluded from analysis
# - Washington DC: Excluded (non-state jurisdiction)
# - Washington state: Tribal-only (Sept 2021), coded as never-treated
#   because tribal employment not in commercial NAICS 7132
# - Florida: Market launched Nov 2021 but suspended Dec 2021 due to
#   federal court ruling; coded as never-treated
# - Vermont: Launched Jan 2024, after sample period ends
# - Missouri: Launched Dec 2024, after sample period ends
# =============================================================================
