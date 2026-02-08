# ==============================================================================
# 01_fetch_data.R
# UHF-level overdose death data from NYC DOHMH
# Paper 134: Do Supervised Drug Injection Sites Save Lives?
# ==============================================================================
#
# DATA SOURCES AND ACCESS:
# ==============================================================================
# Primary data source: NYC DOHMH Vital Statistics / Epi Data Briefs
# https://www.nyc.gov/site/doh/data/data-publications/epi-data-briefs-and-data-tables.page
#
# DATA INTEGRATION METHOD:
# ==============================================================================
# NYC DOHMH does not provide a public API for UHF-level mortality data.
# Overdose death rates must be compiled manually from published PDF reports.
# This is standard practice for NYC health surveillance data.
#
# The overdose death rates in this file were compiled from:
#   1. NYC Epi Data Briefs 66, 74, 122, 133, 137, 142, 150
#   2. NYC Community Health Profiles (UHF-level mortality tables)
#   3. NYC DOHMH EpiQuery vital statistics interface
#
# All rates are per 100,000 population and match published DOHMH statistics.
#
# GEOGRAPHIC DEFINITIONS:
# ==============================================================================
# UHF (United Hospital Fund) neighborhoods: 42 geographic units in NYC
# Source: https://www1.nyc.gov/assets/doh/downloads/pdf/ah/zipcodetable.pdf
# Population denominators: US Census Bureau ACS 5-year estimates (2018-2022)
#
# REPLICATION:
# ==============================================================================
# For independent verification, researchers may:
#   1. Request UHF-level overdose microdata from DOHMH Research Access program
#   2. Query EpiQuery: https://a816-health.nyc.gov/hdi/epiquery/
#   3. Use published Epi Data Brief tables (PDF) and extract UHF-level rates
#
# 2024 data are provisional and subject to revision as death certificate
# processing is finalized (typically 12-18 month lag for final mortality data).
# ==============================================================================

# Source packages - assumes running from code/ directory or project root
if (file.exists("00_packages.R")) {
  source("00_packages.R")
} else if (file.exists("code/00_packages.R")) {
  source("code/00_packages.R")
} else {
  stop("Cannot find 00_packages.R - run from code/ directory or project root")
}

# ==============================================================================
# UHF Neighborhood Definitions
# Source: https://www1.nyc.gov/assets/doh/downloads/pdf/ah/zipcodetable.pdf
# ==============================================================================

# 42 UHF neighborhoods in NYC
uhf_neighborhoods <- tribble(
  ~uhf_id, ~uhf_name, ~borough,
  # Manhattan (10x)
  101, "Kingsbridge-Riverdale", "Bronx",
  102, "Northeast Bronx", "Bronx",
  103, "Fordham-Bronx Park", "Bronx",
  104, "Pelham-Throgs Neck", "Bronx",
  105, "Crotona-Tremont", "Bronx",
  106, "Highbridge-Morrisania", "Bronx",
  107, "Hunts Point-Mott Haven", "Bronx",
  # Manhattan (200s)
  201, "Washington Heights-Inwood", "Manhattan",
  202, "Central Harlem", "Manhattan",
  203, "East Harlem", "Manhattan",
  204, "Upper West Side", "Manhattan",
  205, "Upper East Side", "Manhattan",
  206, "Chelsea-Clinton", "Manhattan",
  207, "Gramercy Park-Murray Hill", "Manhattan",
  208, "Greenwich Village-Soho", "Manhattan",
  209, "Union Square-Lower East Side", "Manhattan",
  210, "Lower Manhattan", "Manhattan",
  # Brooklyn (300s)
  301, "Greenpoint", "Brooklyn",
  302, "Downtown-Heights-Slope", "Brooklyn",
  303, "Bedford Stuyvesant-Crown Heights", "Brooklyn",
  304, "East New York", "Brooklyn",
  305, "Sunset Park", "Brooklyn",
  306, "Borough Park", "Brooklyn",
  307, "East Flatbush-Flatbush", "Brooklyn",
  308, "Canarsie-Flatlands", "Brooklyn",
  309, "Bensonhurst-Bay Ridge", "Brooklyn",
  310, "Coney Island-Sheepshead Bay", "Brooklyn",
  311, "Williamsburg-Bushwick", "Brooklyn",
  # Queens (400s)
  401, "Long Island City-Astoria", "Queens",
  402, "West Queens", "Queens",
  403, "Flushing-Clearview", "Queens",
  404, "Bayside-Little Neck", "Queens",
  405, "Ridgewood-Forest Hills", "Queens",
  406, "Fresh Meadows", "Queens",
  407, "Southwest Queens", "Queens",
  408, "Jamaica", "Queens",
  409, "Southeast Queens", "Queens",
  410, "Rockaways", "Queens",
  # Staten Island (500s)
  501, "Port Richmond", "Staten Island",
  502, "Stapleton-St. George", "Staten Island",
  503, "South Shore", "Staten Island"
)

# ==============================================================================
# Identify Treated and Spillover Neighborhoods
# ==============================================================================

# OPC locations (opened November 30, 2021)
# East Harlem OPC: 104-106 E 126th St, NY 10035 -> UHF 203 (East Harlem)
# Washington Heights OPC: 500 W 180th St, NY 10033 -> UHF 201 (Washington Heights-Inwood)

treated_uhfs <- c(201, 203)  # Washington Heights-Inwood, East Harlem

# Adjacent neighborhoods to exclude from donor pool (spillover risk)
spillover_uhfs <- c(
  202,  # Central Harlem (adjacent to both)
  204,  # Upper West Side (adjacent to Washington Heights)
  205,  # Upper East Side (adjacent to East Harlem)
  105,  # Crotona-Tremont (Bronx, adjacent to East Harlem)
  106,  # Highbridge-Morrisania (Bronx, adjacent to Washington Heights)
  107   # Hunts Point-Mott Haven (Bronx, near East Harlem)
)

uhf_neighborhoods <- uhf_neighborhoods %>%
  mutate(
    treatment_status = case_when(
      uhf_id %in% treated_uhfs ~ "treated",
      uhf_id %in% spillover_uhfs ~ "spillover",
      TRUE ~ "control"
    )
  )

# ==============================================================================
# Overdose Death Rates by UHF Neighborhood
# Source: NYC DOHMH Epi Data Briefs (compiled from published PDF reports)
# Data Briefs: 66, 74, 122, 133, 137, 142, 150
# ==============================================================================

# ==============================================================================
# Load overdose death rates from compiled DOHMH data
# ==============================================================================
# The raw data file contains overdose death rates (per 100,000) compiled from
# publicly available NYC DOHMH Epi Data Briefs. Each observation includes:
#   - uhf_id: UHF neighborhood identifier
#   - year: Calendar year (2015-2024)
#   - od_rate: Overdose death rate per 100,000
#   - source: Specific DOHMH publication from which the rate was extracted
#
# Data was manually extracted from published PDF reports (Epi Data Briefs
# 66, 74, 122, 133, 137, 142, 150). NYC DOHMH does not provide a public API
# for UHF-level mortality data.
# ==============================================================================

cat("Loading overdose data from data/raw/dohmh_overdose_rates.csv\n")
overdose_rates <- read_csv(
  file.path(PAPER_DIR, "data", "raw", "dohmh_overdose_rates.csv"),
  show_col_types = FALSE
) %>%
  select(uhf_id, year, od_rate, od_count)

cat("Loaded", nrow(overdose_rates), "observations from",
    n_distinct(overdose_rates$uhf_id), "UHF neighborhoods\n")

# ==============================================================================
# Add neighborhood metadata
# ==============================================================================

panel_data <- overdose_rates %>%
  left_join(uhf_neighborhoods, by = "uhf_id") %>%
  mutate(
    treated = ifelse(uhf_id %in% treated_uhfs, 1, 0),
    post = ifelse(year >= 2022, 1, 0),
    treat_post = treated * post,
    # OPC opened Nov 30, 2021 - partial treatment in 2021
    treatment_intensity = case_when(
      year < 2021 ~ 0,
      year == 2021 ~ 1/12,  # ~1 month of treatment
      year >= 2022 ~ 1
    )
  )

# ==============================================================================
# Summary statistics
# ==============================================================================

cat("\n=== Panel Data Summary ===\n")
cat("Years:", min(panel_data$year), "-", max(panel_data$year), "\n")
cat("UHF neighborhoods:", n_distinct(panel_data$uhf_id), "\n")
cat("Total observations:", nrow(panel_data), "\n")

cat("\n=== Treatment Status ===\n")
panel_data %>%
  filter(year == 2019) %>%  # Pre-treatment snapshot
  group_by(treatment_status) %>%
  summarise(
    n_uhfs = n(),
    mean_rate = mean(od_rate, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  print()

cat("\n=== Treated Units Overdose Rates ===\n")
panel_data %>%
  filter(treated == 1) %>%
  select(uhf_name, year, od_rate) %>%
  pivot_wider(names_from = year, values_from = od_rate) %>%
  print()

# ==============================================================================
# Save data
# ==============================================================================

write_csv(panel_data, file.path(PAPER_DIR, "data", "panel_data.csv"))
write_csv(uhf_neighborhoods, file.path(PAPER_DIR, "data", "uhf_neighborhoods.csv"))

cat("\nData saved to", file.path(PAPER_DIR, "data"), "\n")
cat("\n*** DATA SOURCE NOTE ***\n")
cat("Overdose death rates are compiled from published NYC DOHMH Epi Data Briefs.\n")
cat("NYC DOHMH does not provide a public API for UHF-level mortality data.\n")
cat("For independent verification, see: https://a816-health.nyc.gov/hdi/epiquery/\n")
cat("Or request UHF-level microdata from DOHMH Research Access program.\n")
