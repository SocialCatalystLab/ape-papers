# ============================================================
# 01_policy_data.R - ERPO Law Adoption Dates
# Sources: PDAPS, Everytown, Giffords Law Center
# ============================================================

source("00_packages.R")

# ERPO (Red Flag / Extreme Risk Protection Order) Law Adoption
# Conservative coding: first full calendar year law in effect

erpo_adoption <- tribble(
  ~state_abbr, ~state_name, ~effective_date, ~treatment_year,
  "CT", "Connecticut",   "1999-10-01", 2000,  # First state
  "IN", "Indiana",       "2005-07-01", 2006,  # Second state
  "CA", "California",    "2016-01-01", 2016,  # Gun Violence Restraining Order
  "WA", "Washington",    "2016-12-08", 2017,  # I-1491 initiative
  "OR", "Oregon",        "2018-01-01", 2018,  # SB 719
  "FL", "Florida",       "2018-03-09", 2019,  # Post-Parkland, Marjory Stoneman Douglas Act
  "VT", "Vermont",       "2018-04-11", 2019,  # S.55
  "MD", "Maryland",      "2018-10-01", 2019,  # HB 1302
  "RI", "Rhode Island",  "2018-06-01", 2019,  # 2018-H 7688A
  "NJ", "New Jersey",    "2018-09-01", 2019,  # A1181
  "DE", "Delaware",      "2018-12-07", 2019,  # HB 222
  "MA", "Massachusetts", "2018-07-26", 2019,  # H.4670
  "IL", "Illinois",      "2019-01-01", 2019   # Firearm Restraining Order Act
)

# States adopting after 2019 (outside study period but documented for reference)
erpo_post_2019 <- tribble(
  ~state_abbr, ~state_name, ~effective_date, ~treatment_year,
  "NY", "New York",      "2019-08-24", 2020,
  "CO", "Colorado",      "2020-01-01", 2020,
  "NV", "Nevada",        "2020-01-01", 2020,
  "HI", "Hawaii",        "2020-01-01", 2020,
  "NM", "New Mexico",    "2020-05-19", 2021,
  "VA", "Virginia",      "2020-07-01", 2021,
  "DC", "District of Columbia", "2019-02-22", 2020
)

# All US states for reference
all_states <- tibble(
  state_abbr = c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "FL",
                 "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME",
                 "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH",
                 "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI",
                 "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"),
  state_name = c("Alabama", "Alaska", "Arizona", "Arkansas", "California",
                 "Colorado", "Connecticut", "Delaware", "District of Columbia",
                 "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana",
                 "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland",
                 "Massachusetts", "Michigan", "Minnesota", "Mississippi",
                 "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire",
                 "New Jersey", "New Mexico", "New York", "North Carolina",
                 "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania",
                 "Rhode Island", "South Carolina", "South Dakota", "Tennessee",
                 "Texas", "Utah", "Vermont", "Virginia", "Washington",
                 "West Virginia", "Wisconsin", "Wyoming")
)

# Create panel data structure
# Using 1999-2017 to include pre-treatment period for Connecticut (treated 2000)
years <- 1999:2017

panel <- expand_grid(
  state_abbr = all_states$state_abbr,
  year = years
) %>%
  left_join(all_states, by = "state_abbr") %>%
  left_join(
    erpo_adoption %>% select(state_abbr, treatment_year),
    by = "state_abbr"
  ) %>%
  mutate(
    # Group variable for C-S: first treatment year (0 if never treated by end of sample 2017)
    # States adopting 2018-2019 are "not yet treated" in our sample window
    first_treat = case_when(
      is.na(treatment_year) ~ 0L,  # Never treated
      treatment_year > 2017 ~ 0L,   # Treated after sample ends (not yet treated in window)
      TRUE ~ as.integer(treatment_year)
    ),
    # Treatment indicator
    treated = if_else(is.na(treatment_year) | treatment_year > year, 0L, 1L),
    # Cohort identifier for descriptive purposes
    cohort = case_when(
      is.na(treatment_year) ~ "Never treated",
      treatment_year <= 2006 ~ "Early (CT/IN)",
      treatment_year >= 2016 & treatment_year <= 2017 ~ "2016-2017",
      treatment_year >= 2018 ~ "Post-sample adopters"
    )
  )

# Summarize treatment status
cat("\n=== ERPO Adoption Summary ===\n")
cat("States adopting by 2019:", sum(!is.na(erpo_adoption$treatment_year)), "\n")
cat("States never adopting (by 2019):", 51 - sum(!is.na(erpo_adoption$treatment_year)), "\n\n")

cat("Treatment cohorts:\n")
panel %>%
  filter(year == 2017) %>%  # Last year in sample
  count(cohort) %>%
  print()

# Save policy panel
write_csv(panel, "../data/erpo_policy_panel.csv")
saveRDS(panel, "../data/erpo_policy_panel.rds")

cat("\nPolicy panel saved to data/erpo_policy_panel.csv\n")
cat("Observations:", nrow(panel), "\n")
cat("States:", n_distinct(panel$state_abbr), "\n")
cat("Years:", min(panel$year), "-", max(panel$year), "\n")
