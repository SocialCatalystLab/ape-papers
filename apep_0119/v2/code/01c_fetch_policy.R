###############################################################################
# 01c_fetch_policy.R
# Paper 130: EERS Revision - Construct Policy Control Variables
# RPS adoption, utility decoupling, building codes
###############################################################################

source("00_packages.R")

data_dir <- "../data/"

###############################################################################
# RPS (Renewable Portfolio Standard) Adoption Data
# Source: DSIRE/NCSL compilations - hardcoded from authoritative sources
###############################################################################

cat("=== CONSTRUCTING POLICY CONTROL VARIABLES ===\n")

# RPS adoption years (mandatory RPS only, from DSIRE/NCSL)
# These are the first year of a binding mandatory RPS target
rps_data <- tribble(
  ~state_abbr, ~rps_year,
  "AZ", 2001,  # Arizona: AEPS 2001
  "CA", 2002,  # California: RPS 2002
  "CO", 2004,  # Colorado: Amendment 37
  "CT", 1998,  # Connecticut: RPS 1998
  "DC", 2005,  # DC: RPS 2005
  "DE", 2005,  # Delaware: RPS 2005
  "HI", 2001,  # Hawaii: RPS 2001
  "IL", 2007,  # Illinois: RPS 2007
  "IA", 1983,  # Iowa: AEP 1983 (earliest)
  "ME", 1999,  # Maine: RPS 1999
  "MD", 2004,  # Maryland: RPS 2004
  "MA", 2002,  # Massachusetts: RPS 2002
  "MI", 2008,  # Michigan: RPS 2008
  "MN", 2007,  # Minnesota: RES 2007
  "MO", 2008,  # Missouri: RES 2008
  "MT", 2005,  # Montana: RPS 2005
  "NV", 2001,  # Nevada: RPS 2001
  "NH", 2007,  # New Hampshire: RPS 2007
  "NJ", 2001,  # New Jersey: RPS 2001
  "NM", 2002,  # New Mexico: RPS 2002
  "NY", 2004,  # New York: RPS 2004
  "NC", 2007,  # North Carolina: REPS 2007
  "OH", 2008,  # Ohio: AEPS 2008
  "OR", 2007,  # Oregon: RPS 2007
  "PA", 2004,  # Pennsylvania: AEPS 2004
  "RI", 2004,  # Rhode Island: RES 2004
  "TX", 1999,  # Texas: RPS 1999
  "VT", 2005,  # Vermont: SPEED 2005 (voluntary, mandatory 2017)
  "VA", 2007,  # Virginia: RPS 2007 (voluntary target)
  "WA", 2006,  # Washington: I-937
  "WI", 1999,  # Wisconsin: RPS 1999
)

cat("RPS adoption data:", nrow(rps_data), "states with mandatory RPS\n")

###############################################################################
# Utility Decoupling/Revenue Adjustment Mechanism Data
# Source: ACEEE/RAP compilations
###############################################################################

# Electric decoupling adoption years (from ACEEE State Policy Tracker)
decoupling_data <- tribble(
  ~state_abbr, ~decoupling_year,
  "CA", 1982,  # California: earliest (updated 2004)
  "CT", 2007,  # Connecticut
  "DC", 2009,  # DC
  "HI", 2010,  # Hawaii
  "ID", 2007,  # Idaho
  "IL", 2017,  # Illinois
  "MA", 2008,  # Massachusetts
  "MD", 2007,  # Maryland
  "MI", 2009,  # Michigan
  "MN", 2010,  # Minnesota
  "NC", 2013,  # North Carolina
  "NY", 2007,  # New York
  "OH", 2008,  # Ohio
  "OR", 2009,  # Oregon
  "RI", 2011,  # Rhode Island
  "VT", 2000,  # Vermont
  "WA", 1991,  # Washington
  "WI", 2008,  # Wisconsin
)

cat("Decoupling adoption data:", nrow(decoupling_data), "states with decoupling\n")

###############################################################################
# Building Energy Codes - Residential (IECC adoption)
# Source: DOE Building Energy Codes Program
###############################################################################

# First adoption of IECC 2009 or later (significant efficiency standards)
building_code_data <- tribble(
  ~state_abbr, ~building_code_year,
  "CA", 2010,  # California Title 24 (state-specific, stricter)
  "CT", 2011,  # IECC 2009
  "DC", 2013,  # IECC 2012
  "DE", 2012,  # IECC 2009
  "FL", 2012,  # Florida Energy Code
  "GA", 2011,  # IECC 2009 (baseline)
  "IA", 2010,  # IECC 2009
  "ID", 2011,  # IECC 2009
  "IL", 2013,  # IECC 2012
  "KY", 2011,  # IECC 2009
  "MA", 2010,  # IECC 2009 (Stretch Code optional)
  "MD", 2010,  # IECC 2009
  "MI", 2011,  # IECC 2009
  "MN", 2015,  # Minnesota Energy Code
  "MT", 2012,  # IECC 2009
  "NC", 2012,  # NC Energy Code
  "NE", 2011,  # IECC 2009
  "NH", 2010,  # IECC 2009
  "NJ", 2011,  # IECC 2009
  "NM", 2011,  # IECC 2009
  "NV", 2012,  # IECC 2009
  "NY", 2011,  # ECCCNYS
  "OH", 2013,  # IECC 2009
  "OR", 2011,  # Oregon Energy Code
  "PA", 2010,  # IECC 2009
  "RI", 2013,  # IECC 2012
  "TX", 2012,  # IECC 2009
  "UT", 2011,  # IECC 2009
  "VA", 2011,  # IECC 2009
  "VT", 2011,  # IECC 2009
  "WA", 2011,  # WA Energy Code
  "WI", 2011,  # IECC 2009
  "WV", 2013,  # IECC 2009
  "WY", 2011,  # IECC 2009
)

cat("Building code adoption data:", nrow(building_code_data), "states\n")

###############################################################################
# Census Divisions for Region x Year FE
###############################################################################

census_divisions <- tribble(
  ~state_abbr, ~census_division, ~census_region,
  "CT", 1, "Northeast",
  "ME", 1, "Northeast",
  "MA", 1, "Northeast",
  "NH", 1, "Northeast",
  "RI", 1, "Northeast",
  "VT", 1, "Northeast",
  "NJ", 2, "Northeast",
  "NY", 2, "Northeast",
  "PA", 2, "Northeast",
  "IL", 3, "Midwest",
  "IN", 3, "Midwest",
  "MI", 3, "Midwest",
  "OH", 3, "Midwest",
  "WI", 3, "Midwest",
  "IA", 4, "Midwest",
  "KS", 4, "Midwest",
  "MN", 4, "Midwest",
  "MO", 4, "Midwest",
  "NE", 4, "Midwest",
  "ND", 4, "Midwest",
  "SD", 4, "Midwest",
  "DE", 5, "South",
  "FL", 5, "South",
  "GA", 5, "South",
  "MD", 5, "South",
  "NC", 5, "South",
  "SC", 5, "South",
  "VA", 5, "South",
  "DC", 5, "South",
  "WV", 5, "South",
  "AL", 6, "South",
  "KY", 6, "South",
  "MS", 6, "South",
  "TN", 6, "South",
  "AR", 7, "South",
  "LA", 7, "South",
  "OK", 7, "South",
  "TX", 7, "South",
  "AZ", 8, "West",
  "CO", 8, "West",
  "ID", 8, "West",
  "MT", 8, "West",
  "NV", 8, "West",
  "NM", 8, "West",
  "UT", 8, "West",
  "WY", 8, "West",
  "AK", 9, "West",
  "CA", 9, "West",
  "HI", 9, "West",
  "OR", 9, "West",
  "WA", 9, "West"
)

cat("Census divisions:", n_distinct(census_divisions$census_division), "divisions,",
    n_distinct(census_divisions$census_region), "regions\n")

###############################################################################
# Combine into panel format
###############################################################################

# Get state list from existing data
state_fips <- readRDS(paste0(data_dir, "state_fips.rds"))
years <- 1990:2023

# Create full panel
policy_panel <- expand_grid(
  year = years,
  state_abbr = state_fips$state_abbr
) %>%
  # Add RPS
  left_join(rps_data, by = "state_abbr") %>%
  mutate(
    rps_year = ifelse(is.na(rps_year), 0L, as.integer(rps_year)),
    has_rps = as.integer(year >= rps_year & rps_year > 0)
  ) %>%
  # Add decoupling
  left_join(decoupling_data, by = "state_abbr") %>%
  mutate(
    decoupling_year = ifelse(is.na(decoupling_year), 0L, as.integer(decoupling_year)),
    has_decoupling = as.integer(year >= decoupling_year & decoupling_year > 0)
  ) %>%
  # Add building codes
  left_join(building_code_data, by = "state_abbr") %>%
  mutate(
    building_code_year = ifelse(is.na(building_code_year), 0L, as.integer(building_code_year)),
    has_building_code = as.integer(year >= building_code_year & building_code_year > 0)
  ) %>%
  # Add census divisions
  left_join(census_divisions, by = "state_abbr")

cat("\nPolicy panel created:", nrow(policy_panel), "state-year observations\n")

# Summary of policy adoption
cat("\nPolicy adoption summary (as of 2020):\n")
policy_panel %>%
  filter(year == 2020) %>%
  summarise(
    states_with_rps = sum(has_rps),
    states_with_decoupling = sum(has_decoupling),
    states_with_modern_code = sum(has_building_code)
  ) %>%
  print()

# Save
saveRDS(policy_panel, paste0(data_dir, "policy_controls.rds"))
saveRDS(census_divisions, paste0(data_dir, "census_divisions.rds"))

cat("\n=== POLICY CONTROLS COMPLETE ===\n")
