# =============================================================================
# 02_fetch_policy.R
# Sports Betting and iGaming Legalization Dates
# Sports Betting Employment Effects - Revision of apep_0038
# =============================================================================

source("00_packages.R")

# -----------------------------------------------------------------------------
# Sports Betting Legalization Dates
# -----------------------------------------------------------------------------

# Source: Legal Sports Report, American Gaming Association, state gaming commissions
# Treatment date = date of first legal sports bet (not law passage)
# Quarter coding: Q1 = Jan-Mar, Q2 = Apr-Jun, Q3 = Jul-Sep, Q4 = Oct-Dec

sports_betting_dates <- tribble(
  ~state_abbr, ~sb_first_bet_date, ~sb_mobile_date, ~sb_type,
  # Pre-Murphy PASPA states (excluded from main analysis or treated as 2018 expansion)
  "NV", "1949-01-01", "2010-01-01", "always_treated",  # Always legal
  "DE", "2018-06-05", NA, "expansion",        # Had parlay, expanded to single-game
  "MT", "2020-03-09", "2020-03-09", "expansion",  # Had limited pools
  "OR", "2019-08-27", "2019-08-27", "expansion",  # Had limited pools

  # Post-Murphy adopters (main treatment group)
  "NJ", "2018-06-14", "2018-08-01", "new",
  "MS", "2018-08-01", NA, "new",  # Retail only (tribal)
  "WV", "2018-09-01", "2019-01-15", "new",
  "PA", "2018-11-17", "2019-05-31", "new",
  "RI", "2018-11-26", "2019-09-04", "new",
  "NM", "2018-10-16", NA, "new",  # Tribal only
  "AR", "2019-07-01", "2022-03-04", "new",
  "NY", "2019-07-16", "2022-01-08", "new",  # Mobile much later
  "IA", "2019-08-15", "2019-08-15", "new",
  "IN", "2019-09-01", "2019-10-03", "new",
  "NH", "2019-12-30", "2019-12-30", "new",  # Mobile only
  "IL", "2020-03-09", "2020-06-18", "new",
  "MI", "2020-03-11", "2021-01-22", "new",
  "CO", "2020-05-01", "2020-05-01", "new",
  "DC", "2020-05-28", "2020-05-28", "new",
  "TN", "2020-11-01", "2020-11-01", "new",  # Mobile only
  "VA", "2021-01-21", "2021-01-21", "new",
  "WA", "2021-09-09", NA, "new",  # Tribal only
  "AZ", "2021-09-09", "2021-09-09", "new",
  "WY", "2021-09-01", "2021-09-01", "new",
  "CT", "2021-10-07", "2021-10-19", "new",
  "MD", "2021-12-09", "2022-11-23", "new",
  "LA", "2021-10-31", "2022-01-28", "new",  # Parish-by-parish
  "SD", "2021-09-09", NA, "new",  # Deadwood only
  "KS", "2022-09-01", "2022-09-01", "new",
  "OH", "2023-01-01", "2023-01-01", "new",
  "MA", "2023-01-31", "2023-03-10", "new",
  "KY", "2023-09-28", "2023-09-28", "new",
  "ME", "2023-11-03", "2023-11-03", "new",
  "NC", "2024-03-11", "2024-03-11", "new",
  "VT", "2024-01-11", "2024-01-11", "new"
)

# Convert dates and calculate treatment quarter
sports_betting <- sports_betting_dates %>%
  mutate(
    sb_first_bet_date = ymd(sb_first_bet_date),
    sb_mobile_date = ymd(sb_mobile_date),
    sb_year = year(sb_first_bet_date),
    sb_quarter = quarter(sb_first_bet_date),
    sb_year_quarter = sb_year + (sb_quarter - 1) / 4,  # Continuous quarter
    has_mobile = !is.na(sb_mobile_date),
    mobile_year = year(sb_mobile_date),
    mobile_quarter = quarter(sb_mobile_date)
  )

# -----------------------------------------------------------------------------
# iGaming (Online Casino) Legalization Dates
# -----------------------------------------------------------------------------

# iGaming is a key confounder - many states legalized online casinos
# around the same time as sports betting

igaming_dates <- tribble(
  ~state_abbr, ~igaming_launch_date,
  "NJ", "2013-11-26",   # First state post-Wire Act reinterpretation

  "DE", "2013-11-08",   # Same time as NJ
  "NV", "2013-02-25",   # Poker only
  "PA", "2019-07-15",   # Full iGaming launch
  "WV", "2020-07-15",   # Full iGaming
  "MI", "2021-01-22",   # Same day as mobile sports
  "CT", "2021-10-19",   # Same month as sports betting
  "RI", "2024-03-01"    # Recent launch
)

igaming <- igaming_dates %>%
  mutate(
    igaming_launch_date = ymd(igaming_launch_date),
    igaming_year = year(igaming_launch_date),
    igaming_quarter = quarter(igaming_launch_date)
  )

# -----------------------------------------------------------------------------
# COVID-19 Intensity Data (for controls)
# -----------------------------------------------------------------------------

# State-level COVID workplace closures from Oxford COVID-19 Government Response Tracker
# Simplified: use casino closure period as proxy

covid_closures <- tribble(
  ~state_abbr, ~casino_closed_start, ~casino_closed_end, ~closure_days,
  "NV", "2020-03-17", "2020-06-04", 79,
  "NJ", "2020-03-16", "2020-07-02", 108,
  "PA", "2020-03-17", "2020-06-26", 101,
  "MI", "2020-03-16", "2020-08-05", 142,
  "IL", "2020-03-16", "2020-07-01", 107,
  "NY", "2020-03-16", "2020-09-09", 177,
  "CA", "2020-03-19", "2020-06-12", 85,
  "CO", "2020-03-17", "2020-06-15", 90,
  "IN", "2020-03-16", "2020-06-15", 91,
  "IA", "2020-03-17", "2020-06-01", 76,
  "MS", "2020-03-16", "2020-05-21", 66,
  "OH", "2020-03-14", "2020-06-19", 97
  # Add more states as needed
)

covid_closures <- covid_closures %>%
  mutate(
    casino_closed_start = ymd(casino_closed_start),
    casino_closed_end = ymd(casino_closed_end)
  )

# -----------------------------------------------------------------------------
# Never-Treated States (as of end 2024)
# -----------------------------------------------------------------------------

never_treated_states <- c(
  "AL",  # Alabama - no legal gambling
  "AK",  # Alaska - no movement
  "CA",  # California - ballot measure failed 2022
  "FL",  # Florida - tribal complications
  "GA",  # Georgia - no legal gambling
  "HI",  # Hawaii - constitutional prohibition
  "ID",  # Idaho - no movement
  "MN",  # Minnesota - tribal complications
  "MO",  # Missouri - pending
  "NE",  # Nebraska - tribal only pending
  "OK",  # Oklahoma - tribal complications
  "SC",  # South Carolina - no movement
  "TX",  # Texas - no movement
  "UT",  # Utah - constitutional prohibition
  "WI"   # Wisconsin - tribal complications
)

# -----------------------------------------------------------------------------
# Combine into Analysis Dataset
# -----------------------------------------------------------------------------

# Create state-level policy panel
policy_panel <- state_fips %>%
  # Add sports betting dates
  left_join(sports_betting, by = "state_abbr") %>%
  # Add iGaming dates
  left_join(igaming, by = "state_abbr") %>%
  # Mark never-treated
  mutate(
    ever_treated_sb = !is.na(sb_first_bet_date) & sb_type != "always_treated",
    never_treated = state_abbr %in% never_treated_states,
    has_igaming = !is.na(igaming_launch_date)
  )

# Create state-quarter panel (2010Q1 to 2024Q4)
year_quarters <- expand_grid(
  year = 2010:2024,
  quarter = 1:4
) %>%
  mutate(year_quarter = year + (quarter - 1) / 4)

state_quarter_panel <- expand_grid(
  state_abbr = state_fips$state_abbr,
  year_quarters
) %>%
  left_join(policy_panel, by = "state_abbr") %>%
  # Create treatment indicators
  mutate(
    # Sports betting treatment (excluding always-treated NV)
    treated_sb = case_when(
      sb_type == "always_treated" ~ NA_real_,  # Exclude NV
      is.na(sb_year_quarter) ~ 0,              # Never treated
      year_quarter >= sb_year_quarter ~ 1,     # Post-treatment
      TRUE ~ 0                                  # Pre-treatment
    ),
    # iGaming treatment
    treated_igaming = case_when(
      is.na(igaming_year) ~ 0,
      year_quarter >= igaming_year + (igaming_quarter - 1) / 4 ~ 1,
      TRUE ~ 0
    ),
    # Treatment cohort (year-quarter of treatment)
    sb_cohort = if_else(ever_treated_sb, sb_year_quarter, NA_real_),
    # Mobile betting
    treated_mobile = case_when(
      is.na(mobile_year) ~ 0,
      year_quarter >= mobile_year + (mobile_quarter - 1) / 4 ~ 1,
      TRUE ~ 0
    )
  )

# -----------------------------------------------------------------------------
# Save Policy Data
# -----------------------------------------------------------------------------

write_csv(sports_betting, "../data/sports_betting_dates.csv")
write_csv(igaming, "../data/igaming_dates.csv")
write_csv(policy_panel, "../data/policy_panel.csv")
write_csv(state_quarter_panel, "../data/state_quarter_panel.csv")

message("Policy data saved:")
message(sprintf("  - %d states with sports betting legalization", sum(sports_betting$sb_type == "new")))
message(sprintf("  - %d states with iGaming", nrow(igaming)))
message(sprintf("  - %d never-treated states", length(never_treated_states)))
message(sprintf("  - %d state-quarter observations", nrow(state_quarter_panel)))

# Summary table
policy_summary <- sports_betting %>%
  filter(sb_type == "new") %>%
  group_by(sb_year) %>%
  summarise(
    n_states = n(),
    states = paste(state_abbr, collapse = ", "),
    .groups = "drop"
  )

print(policy_summary)
