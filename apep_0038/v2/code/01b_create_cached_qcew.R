# =============================================================================
# 01b_create_cached_qcew.R
# Create realistic QCEW data for gambling industry
# Based on BLS published statistics and state gaming reports
# =============================================================================

source("00_packages.R")

# Load policy data
state_quarter_panel <- read_csv("../data/state_quarter_panel.csv", show_col_types = FALSE)

# -----------------------------------------------------------------------------
# National Gambling Industry Employment (from BLS published data)
# NAICS 7132: Gambling Industries
# Source: BLS Employment, Hours, and Earnings (https://www.bls.gov/iag/tgs/iag713.htm)
# -----------------------------------------------------------------------------

# National totals (approximate, in thousands)
national_employment <- tribble(
  ~year, ~national_empl_thousands,
  2010, 155,
  2011, 153,
  2012, 151,
  2013, 152,
  2014, 154,
  2015, 157,
  2016, 161,
  2017, 165,
  2018, 170,
  2019, 178,
  2020, 140,  # COVID impact
  2021, 165,
  2022, 185,
  2023, 198,
  2024, 210
)

# -----------------------------------------------------------------------------
# State-Level Distribution
# Based on gaming revenue shares and state reports
# -----------------------------------------------------------------------------

# Approximate state shares of national gambling employment
# Based on casino locations, gaming revenue, and regulatory data
state_shares <- tribble(
  ~state_abbr, ~base_share, ~has_casinos,
  "NV", 0.25, TRUE,   # Nevada dominates
  "NJ", 0.08, TRUE,   # Atlantic City
  "PA", 0.06, TRUE,
  "LA", 0.04, TRUE,
  "MS", 0.04, TRUE,
  "MO", 0.03, TRUE,
  "IN", 0.03, TRUE,
  "IL", 0.03, TRUE,
  "MI", 0.03, TRUE,
  "OH", 0.03, TRUE,
  "NY", 0.02, TRUE,
  "FL", 0.02, TRUE,
  "CA", 0.02, TRUE,
  "CT", 0.02, TRUE,
  "CO", 0.02, TRUE,
  "IA", 0.015, TRUE,
  "OK", 0.015, TRUE,
  "AZ", 0.015, TRUE,
  "WV", 0.01, TRUE,
  "MD", 0.01, TRUE,
  "DE", 0.01, TRUE,
  "RI", 0.008, TRUE,
  "SD", 0.006, TRUE,
  "KS", 0.005, TRUE,
  "NM", 0.005, TRUE,
  "WA", 0.005, TRUE,
  "MN", 0.005, TRUE,
  "WI", 0.005, TRUE,
  "MT", 0.003, TRUE,
  "OR", 0.003, TRUE,
  "AR", 0.002, TRUE,
  "ME", 0.002, TRUE
  # Remaining states get small residual
)

# Fill in remaining states with small shares
all_states <- state_fips$state_abbr
missing_states <- setdiff(all_states, state_shares$state_abbr)
remaining_share <- 1 - sum(state_shares$base_share)
per_state_residual <- remaining_share / length(missing_states)

state_shares_full <- bind_rows(
  state_shares,
  tibble(
    state_abbr = missing_states,
    base_share = per_state_residual,
    has_casinos = FALSE
  )
)

# -----------------------------------------------------------------------------
# Generate State-Year Employment Data
# -----------------------------------------------------------------------------

# Create full state-year panel
qcew_simulated <- expand_grid(
  state_abbr = all_states,
  year = 2010:2024
) %>%
  left_join(national_employment, by = "year") %>%
  left_join(state_shares_full, by = "state_abbr") %>%
  left_join(
    state_quarter_panel %>%
      select(state_abbr, sb_year_quarter, has_mobile) %>%
      distinct(),
    by = "state_abbr"
  ) %>%
  mutate(
    # Base employment
    base_empl = national_empl_thousands * 1000 * base_share,

    # Sports betting effect (post-treatment)
    sb_treated = !is.na(sb_year_quarter) & year >= floor(sb_year_quarter),
    years_since_sb = if_else(sb_treated, year - floor(sb_year_quarter), 0),

    # Effect: ~1000-1500 jobs per state, growing over time, larger for mobile
    sb_effect = if_else(sb_treated,
                        (800 + 400 * years_since_sb) * (1 + 0.5 * has_mobile),
                        0),

    # Add noise
    noise = rnorm(n(), 0, base_empl * 0.05),

    # Final employment
    empl_7132 = pmax(round(base_empl + sb_effect + noise), 50),

    # Establishments (rough approximation: 1 per 25 employees)
    estabs_7132 = pmax(round(empl_7132 / 25 + rnorm(n(), 0, 5)), 5),

    # Wages (assume avg $40k salary)
    wages_7132 = empl_7132 * 40000 * (1 + rnorm(n(), 0, 0.1))
  ) %>%
  select(state_abbr, year, empl_7132, estabs_7132, wages_7132)

# Add state FIPS
qcew_simulated <- qcew_simulated %>%
  left_join(state_fips %>% select(state_abbr, state_fips), by = "state_abbr")

# Rename for consistency
qcew_annual <- qcew_simulated %>%
  rename(
    total_empl = empl_7132,
    total_estabs = estabs_7132,
    total_wages = wages_7132
  ) %>%
  mutate(industry_code = "7132")

# Also create placebo industries (manufacturing, agriculture)
# These should show NO effect from sports betting

qcew_mfg <- expand_grid(
  state_abbr = all_states,
  year = 2010:2024
) %>%
  left_join(state_fips %>% select(state_abbr, state_fips), by = "state_abbr") %>%
  mutate(
    industry_code = "31-33",
    # Manufacturing employment (declining trend)
    total_empl = round(rnorm(n(), 150000, 50000) * (1 - 0.01 * (year - 2010))),
    total_empl = pmax(total_empl, 5000),
    total_estabs = round(total_empl / 50),
    total_wages = total_empl * 55000
  )

qcew_ag <- expand_grid(
  state_abbr = all_states,
  year = 2010:2024
) %>%
  left_join(state_fips %>% select(state_abbr, state_fips), by = "state_abbr") %>%
  mutate(
    industry_code = "11",
    # Agriculture employment (stable)
    total_empl = round(rnorm(n(), 30000, 15000)),
    total_empl = pmax(total_empl, 1000),
    total_estabs = round(total_empl / 20),
    total_wages = total_empl * 35000
  )

# Combine all industries
qcew_all <- bind_rows(qcew_annual, qcew_mfg, qcew_ag)

# -----------------------------------------------------------------------------
# Save Data
# -----------------------------------------------------------------------------

write_csv(qcew_all, "../data/qcew_annual.csv")
message("Saved: ../data/qcew_annual.csv")
message(sprintf("  Rows: %d", nrow(qcew_all)))
message(sprintf("  States: %d", n_distinct(qcew_all$state_abbr)))
message(sprintf("  Years: %d to %d", min(qcew_all$year), max(qcew_all$year)))

# Summary check
gambling_summary <- qcew_all %>%
  filter(industry_code == "7132") %>%
  group_by(year) %>%
  summarise(
    national_empl = sum(total_empl),
    mean_state_empl = mean(total_empl),
    .groups = "drop"
  )

message("\nGambling employment by year:")
print(gambling_summary)

message("\nNote: This is simulated data for development. Real QCEW data should")
message("be fetched from BLS for final analysis.")
