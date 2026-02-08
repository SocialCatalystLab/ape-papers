# =============================================================================
# 02_fetch_policy.R
# Sports Betting and iGaming Legalization Dates
# Paper 117: Sports Betting Employment Effects
# =============================================================================
#
# Policy dates are hardcoded from public sources:
# - Legal Sports Report (https://www.legalsportsreport.com/)
# - American Gaming Association
# - State gaming commission announcements
#
# Treatment date = date of first legal sports bet (not law passage date)
# =============================================================================

source("00_packages.R")

# =============================================================================
# Sports Betting Legalization Dates
# =============================================================================

# Source: Legal Sports Report, American Gaming Association, state gaming commissions
# Treatment date = date of first legal sports bet (not law passage)

sports_betting_dates <- tribble(
  ~state_abbr, ~sb_first_bet_date, ~sb_mobile_date, ~sb_type,

  # Pre-Murphy PASPA states (excluded from main analysis or treated as always-treated)
  "NV", "1949-01-01", "2010-01-01", "always_treated",  # Always legal
  "DE", "2018-06-05", NA, "expansion",        # Had parlay, expanded to single-game
  "MT", "2020-03-09", "2020-03-09", "expansion",  # Had limited pools
  "OR", "2019-08-27", "2019-08-27", "expansion",  # Had limited pools

  # Post-Murphy adopters (main treatment group)
  "NJ", "2018-06-14", "2018-08-01", "new",
  "MS", "2018-08-01", NA, "new",              # Retail only (tribal)
  "WV", "2018-09-01", "2019-01-15", "new",
  "PA", "2018-11-17", "2019-05-31", "new",
  "RI", "2018-11-26", "2019-09-04", "new",
  "NM", "2018-10-16", NA, "new",              # Tribal only
  "AR", "2019-07-01", "2022-03-04", "new",
  "NY", "2019-07-16", "2022-01-08", "new",    # Mobile much later
  "IA", "2019-08-15", "2019-08-15", "new",
  "IN", "2019-09-01", "2019-10-03", "new",
  "NH", "2019-12-30", "2019-12-30", "new",    # Mobile only
  "IL", "2020-03-09", "2020-06-18", "new",
  "MI", "2020-03-11", "2021-01-22", "new",
  "CO", "2020-05-01", "2020-05-01", "new",
  "DC", "2020-05-28", "2020-05-28", "new",
  "TN", "2020-11-01", "2020-11-01", "new",    # Mobile only
  "VA", "2021-01-21", "2021-01-21", "new",
  "WA", "2021-09-09", NA, "new",              # Tribal only
  "AZ", "2021-09-09", "2021-09-09", "new",
  "WY", "2021-09-01", "2021-09-01", "new",
  "CT", "2021-10-07", "2021-10-19", "new",
  "MD", "2021-12-09", "2022-11-23", "new",
  "LA", "2021-10-31", "2022-01-28", "new",    # Parish-by-parish

  "SD", "2021-09-09", NA, "new",              # Deadwood only
  "KS", "2022-09-01", "2022-09-01", "new",
  "OH", "2023-01-01", "2023-01-01", "new",
  "MA", "2023-01-31", "2023-03-10", "new",
  "KY", "2023-09-28", "2023-09-28", "new",
  "ME", "2023-11-03", "2023-11-03", "new",
  "NC", "2024-03-11", "2024-03-11", "new",
  "VT", "2024-01-11", "2024-01-11", "new"
)

# Convert dates and calculate treatment year
sports_betting <- sports_betting_dates %>%
  mutate(
    sb_first_bet_date = ymd(sb_first_bet_date),
    sb_mobile_date = ymd(sb_mobile_date),
    sb_year = year(sb_first_bet_date),
    has_mobile = !is.na(sb_mobile_date),
    mobile_year = year(sb_mobile_date)
  )

# =============================================================================
# iGaming (Online Casino) Legalization Dates
# =============================================================================

# iGaming is a key confounder - some states legalized online casinos
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
    igaming_year = year(igaming_launch_date)
  )

# =============================================================================
# Never-Treated States (as of end 2024)
# =============================================================================

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

# =============================================================================
# Create Analysis Panel
# =============================================================================

# Create policy panel with all states
policy_panel <- state_fips %>%
  left_join(sports_betting, by = "state_abbr") %>%
  left_join(igaming, by = "state_abbr") %>%
  mutate(
    # Treatment classification
    ever_treated_sb = !is.na(sb_first_bet_date) & sb_type == "new",
    always_treated = sb_type == "always_treated",
    never_treated = state_abbr %in% never_treated_states,
    has_igaming = !is.na(igaming_launch_date),

    # Treatment year for DiD (0 = never treated for did package)
    treatment_year = case_when(
      sb_type == "always_treated" ~ NA_integer_,  # Exclude NV from main analysis
      sb_type == "new" ~ sb_year,
      sb_type == "expansion" ~ sb_year,           # Include DE, MT, OR as treated
      TRUE ~ 0L                                    # Never treated
    )
  )

# Create state-year panel (2010-2024)
state_year_panel <- expand_grid(
  state_abbr = state_fips$state_abbr,
  year = 2010:2024
) %>%
  left_join(policy_panel, by = "state_abbr") %>%
  mutate(
    # Treatment indicator
    treated_sb = case_when(
      is.na(treatment_year) ~ NA_real_,           # NV excluded
      treatment_year == 0 ~ 0,                     # Never treated
      year >= treatment_year ~ 1,                  # Post-treatment
      TRUE ~ 0                                     # Pre-treatment
    ),
    # Mobile betting indicator
    treated_mobile = case_when(
      is.na(mobile_year) ~ 0,
      year >= mobile_year ~ 1,
      TRUE ~ 0
    ),
    # iGaming indicator
    treated_igaming = case_when(
      is.na(igaming_year) ~ 0,
      year >= igaming_year ~ 1,
      TRUE ~ 0
    ),
    # Event time (for event study)
    event_time = if_else(treatment_year > 0, year - treatment_year, NA_integer_)
  )

# =============================================================================
# Save Policy Data
# =============================================================================

write_csv(sports_betting, "../data/sports_betting_dates.csv")
write_csv(igaming, "../data/igaming_dates.csv")
write_csv(policy_panel, "../data/policy_panel.csv")
write_csv(state_year_panel, "../data/state_year_panel.csv")

message("\nPolicy data saved:")
message(sprintf("  - %d states with new sports betting (main treatment)", sum(policy_panel$sb_type == "new", na.rm = TRUE)))
message(sprintf("  - %d states with expanded sports betting", sum(policy_panel$sb_type == "expansion", na.rm = TRUE)))
message(sprintf("  - %d states with iGaming", nrow(igaming)))
message(sprintf("  - %d never-treated states", length(never_treated_states)))
message(sprintf("  - %d state-year observations", nrow(state_year_panel)))

# Treatment timing summary
timing_summary <- sports_betting %>%
  filter(sb_type == "new") %>%
  group_by(sb_year) %>%
  summarise(
    n_states = n(),
    states = paste(state_abbr, collapse = ", "),
    .groups = "drop"
  )

message("\nSports betting adoption timing:")
print(timing_summary)
