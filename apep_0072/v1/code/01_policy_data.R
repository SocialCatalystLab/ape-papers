# ==============================================================================
# 01_policy_data.R
# Paper 96: Telehealth Parity Laws and Mental Health Treatment Utilization
# Description: Compile telehealth parity law adoption dates by state
# Sources: CCHPCA, NCSL, Health Affairs, state legislation databases
# ==============================================================================

source("00_packages.R")

# ==============================================================================
# Treatment Coding: Telehealth Private Payer Parity Laws
# ==============================================================================

# Notes on treatment definition:
# - Treatment = state has law requiring private insurers to provide coverage
#   for telehealth services (coverage parity) OR payment at same rate (payment parity)
# - First treated year = first FULL calendar year after law effective date
# - Some states have very early laws (pre-2010) - these are "always treated"
# - Some states never adopted through 2019 - these are "never treated"
#
# Sources:
# - CCHPCA State Telehealth Laws Report (2019)
# - Health Affairs Policy Brief (2016)
# - NCSL Telehealth Private Insurance Laws database
# - Individual state legislative records
#
# Limitations:
# - Exact effective dates vary across sources
# - Some states have partial parity (coverage but not payment) - coded as treated
# - ERISA preemption means self-insured plans are exempt - measurement error

telehealth_parity <- tribble(
  ~state, ~state_fips, ~first_parity_law_year, ~parity_type, ~notes,

  # Pre-2010 adopters (always treated in our sample)
  "California",    "06", 2012, "coverage", "AB 415 effective 2012; earlier Medicaid rules",
  "Colorado",      "08", 2008, "coverage", "HB 1061 effective 2008",
  "Georgia",       "13", 2005, "coverage", "SB 99 effective 2005",
  "Hawaii",        "15", 2006, "coverage", "HB 2515 effective 2006",
  "Kentucky",      "21", 2000, "coverage", "HB 737 effective 2000",
  "Louisiana",     "22", 2010, "coverage", "HB 977 effective 2010",
  "Maine",         "23", 2009, "coverage", "HP 1063 effective 2009",
  "Oklahoma",      "40", 1997, "coverage", "HB 1122 effective 1997",
  "Oregon",        "41", 2009, "coverage", "HB 2009 effective 2009",
  "Texas",         "48", 1997, "coverage", "HB 2085 effective 1997",
  "Virginia",      "51", 2010, "coverage", "HB 1280 effective 2010",

  # 2011-2013 adopters
  "Maryland",      "24", 2012, "coverage", "SB 776 effective 2012",
  "Mississippi",   "28", 2013, "coverage", "HB 786 effective 2013",
  "Missouri",      "29", 2013, "coverage", "HB 315 effective 2013",
  "Montana",       "30", 2013, "coverage", "HB 45 effective 2013",
  "New Hampshire", "33", 2012, "coverage", "HB 1360 effective 2012",
  "New Mexico",    "35", 2013, "coverage", "HB 91 effective 2013",
  "Tennessee",     "47", 2013, "coverage", "SB 442 effective 2013",
  "Vermont",       "50", 2012, "coverage", "Act 107 effective 2012",

  # 2014-2015 adopters
  "Arizona",       "04", 2014, "payment", "HB 2411 effective 2014",
  "Delaware",      "10", 2015, "coverage", "SB 138 effective 2015",
  "Indiana",       "18", 2015, "coverage", "SB 187 effective 2015",
  "Michigan",      "26", 2014, "coverage", "SB 774 effective 2014",
  "Minnesota",     "27", 2015, "coverage", "HF 1166 effective 2015",
  "Nebraska",      "31", 2014, "coverage", "LB 914 effective 2014",
  "New York",      "36", 2016, "coverage", "A 8528 signed 2014, effective 2016",
  "Arkansas",      "05", 2015, "coverage", "HB 1495 effective 2015",

  # 2016-2017 adopters
  "Connecticut",   "09", 2016, "coverage", "HB 5053 effective 2016",
  "Illinois",      "17", 2016, "coverage", "HB 5547 effective 2016",
  "Massachusetts", "25", 2016, "coverage", "Chapter 224 telehealth 2016",
  "Nevada",        "32", 2017, "coverage", "AB 292 effective 2017",
  "Rhode Island",  "44", 2016, "coverage", "H 7946 effective 2016",
  "West Virginia", "54", 2016, "coverage", "SB 461 effective 2016",

  # 2018-2019 adopters
  "Alaska",        "02", 2018, "coverage", "HB 135 effective 2018",
  "Iowa",          "19", 2018, "coverage", "HF 2305 effective 2018",
  "Kansas",        "20", 2019, "coverage", "HB 2028 effective 2019",
  "New Jersey",    "34", 2018, "coverage", "A 1771 effective 2018",

  # Never-treated through 2019
  "Alabama",       "01", NA, "none", "No parity law through 2019",
  "District of Columbia", "11", NA, "none", "No parity law through 2019",
  "Florida",       "12", NA, "none", "No parity law through 2019",
  "Idaho",         "16", NA, "none", "No parity law through 2019",
  "North Carolina","37", NA, "none", "No parity law through 2019",
  "North Dakota",  "38", NA, "none", "No parity law through 2019",
  "Ohio",          "39", NA, "none", "No parity law through 2019",
  "Pennsylvania",  "42", NA, "none", "No parity law through 2019",
  "South Carolina","45", NA, "none", "No parity law through 2019",
  "South Dakota",  "46", NA, "none", "No parity law through 2019",
  "Utah",          "49", NA, "none", "No parity law through 2019",
  "Washington",    "53", NA, "none", "No parity law through 2019",
  "Wisconsin",     "55", NA, "none", "No parity law through 2019",
  "Wyoming",       "56", NA, "none", "No parity law through 2019"
)

# ==============================================================================
# Create Analysis Panel
# ==============================================================================

# Sample period
years <- 2008:2019

# Create state-year panel
panel <- expand_grid(
  state = telehealth_parity$state,
  year = years
) %>%
  left_join(telehealth_parity, by = "state") %>%
  mutate(
    # Treatment indicator: treated if law in effect for full year
    treated = case_when(
      is.na(first_parity_law_year) ~ 0L,
      year >= first_parity_law_year ~ 1L,
      TRUE ~ 0L
    ),

    # Cohort variable for Callaway-Sant'Anna (0 = never treated)
    cohort = case_when(
      is.na(first_parity_law_year) ~ 0L,
      TRUE ~ as.integer(first_parity_law_year)
    ),

    # Time to treatment (event time)
    time_to_treat = case_when(
      is.na(first_parity_law_year) ~ NA_integer_,
      TRUE ~ as.integer(year - first_parity_law_year)
    ),

    # Parity type indicators
    has_payment_parity = parity_type == "payment",
    has_coverage_parity = parity_type == "coverage"
  )

# ==============================================================================
# Summary Statistics
# ==============================================================================

message("\n=== Treatment Summary ===")

# States by treatment status
treatment_summary <- telehealth_parity %>%
  mutate(
    treatment_status = case_when(
      is.na(first_parity_law_year) ~ "Never treated",
      first_parity_law_year <= 2010 ~ "Always treated (pre-2010)",
      first_parity_law_year <= 2015 ~ "Early adopter (2011-2015)",
      TRUE ~ "Late adopter (2016-2019)"
    )
  ) %>%
  count(treatment_status) %>%
  arrange(match(treatment_status, c("Always treated (pre-2010)",
                                     "Early adopter (2011-2015)",
                                     "Late adopter (2016-2019)",
                                     "Never treated")))

print(treatment_summary)

# Adoption timeline
adoption_timeline <- telehealth_parity %>%
  filter(!is.na(first_parity_law_year)) %>%
  count(first_parity_law_year, name = "states_adopting") %>%
  mutate(cumulative = cumsum(states_adopting))

message("\n=== Adoption Timeline ===")
print(adoption_timeline)

# ==============================================================================
# Save Data
# ==============================================================================

write_csv(telehealth_parity, "../data/telehealth_parity_laws.csv")
write_csv(panel, "../data/state_year_panel.csv")

message("\n=== Data Saved ===")
message("- telehealth_parity_laws.csv")
message("- state_year_panel.csv")

# ==============================================================================
# Diagnostic Checks
# ==============================================================================

message("\n=== Diagnostic Checks ===")

# States with treatment variation in our sample
states_with_variation <- panel %>%
  group_by(state) %>%
  summarize(
    ever_treated = any(treated == 1),
    always_treated = all(treated == 1),
    .groups = "drop"
  ) %>%
  filter(ever_treated, !always_treated)

message(paste("States with treatment variation in 2008-2019:",
              nrow(states_with_variation)))

# Pre-treatment periods for each cohort
pre_periods <- panel %>%
  filter(!is.na(time_to_treat), time_to_treat < 0) %>%
  group_by(cohort) %>%
  summarize(
    n_pre_periods = n_distinct(year),
    .groups = "drop"
  )

message("\nPre-treatment periods by cohort:")
print(pre_periods)
