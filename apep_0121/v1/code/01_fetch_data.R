# ==============================================================================
# 01_fetch_data.R
# State Minimum Wage Increases and Young Adult Household Formation
# Purpose: Fetch and assemble three datasets:
#   A) Census ACS living arrangements (Table B09021) + housing costs + population
#   B) State minimum wage history (hard-coded from DOL records)
#   C) State-level controls (unemployment from BLS LAUS)
# Output: Four CSV files in ../data/
# ==============================================================================

source("code/00_packages.R")

cat("\n====================================================================\n")
cat("  01_fetch_data.R: Fetching data for Paper 111\n")
cat("====================================================================\n\n")

# ==============================================================================
# HELPER: Robust API fetcher with retries
# ==============================================================================

fetch_json <- function(url, max_retries = 3, sleep_sec = 2) {
  for (attempt in seq_len(max_retries)) {
    result <- tryCatch({
      cat("  Fetching:", substr(url, 1, 120), "...\n")
      response <- httr::GET(
        url,
        httr::timeout(60),
        httr::user_agent("APEP-Research/1.0 (academic research)")
      )
      if (httr::status_code(response) == 200) {
        content_text <- httr::content(response, as = "text", encoding = "UTF-8")
        parsed <- jsonlite::fromJSON(content_text)
        Sys.sleep(0.5)
        return(parsed)
      } else {
        cat("    HTTP", httr::status_code(response),
            "(attempt", attempt, "/", max_retries, ")\n")
        if (attempt < max_retries) Sys.sleep(sleep_sec * attempt)
        NULL
      }
    }, error = function(e) {
      cat("    [Attempt", attempt, "/", max_retries, "] Error:",
          conditionMessage(e), "\n")
      if (attempt < max_retries) Sys.sleep(sleep_sec * attempt)
      NULL
    })
    if (!is.null(result)) return(result)
  }
  warning("Failed after ", max_retries, " attempts: ", url)
  return(NULL)
}

# Convert Census API JSON matrix (first row = header) to data frame
census_to_df <- function(raw) {
  if (is.null(raw)) return(NULL)
  df <- as.data.frame(raw[-1, , drop = FALSE], stringsAsFactors = FALSE)
  colnames(df) <- raw[1, ]
  return(df)
}

# State FIPS lookup tables (50 states + DC)
fips_to_abbr <- c(
  "01" = "AL", "02" = "AK", "04" = "AZ", "05" = "AR", "06" = "CA",
  "08" = "CO", "09" = "CT", "10" = "DE", "11" = "DC", "12" = "FL",
  "13" = "GA", "15" = "HI", "16" = "ID", "17" = "IL", "18" = "IN",
  "19" = "IA", "20" = "KS", "21" = "KY", "22" = "LA", "23" = "ME",
  "24" = "MD", "25" = "MA", "26" = "MI", "27" = "MN", "28" = "MS",
  "29" = "MO", "30" = "MT", "31" = "NE", "32" = "NV", "33" = "NH",
  "34" = "NJ", "35" = "NM", "36" = "NY", "37" = "NC", "38" = "ND",
  "39" = "OH", "40" = "OK", "41" = "OR", "42" = "PA", "44" = "RI",
  "45" = "SC", "46" = "SD", "47" = "TN", "48" = "TX", "49" = "UT",
  "50" = "VT", "51" = "VA", "53" = "WA", "54" = "WV", "55" = "WI",
  "56" = "WY"
)


# ########################################################################### #
#                                                                             #
#  PART A: CENSUS ACS LIVING ARRANGEMENTS (Table B09021)                      #
#                                                                             #
# ########################################################################### #
#
# Table B09021: "Living Arrangements of Adults"
# Full table structure:
#   B09021_001E  Total (all ages)
#   B09021_002E  Lives alone (all ages)
#   ...
#   B09021_008E  18 to 34 years: Total
#   B09021_009E  18 to 34 years: Lives alone
#   B09021_010E  18 to 34 years: Householder living with spouse or spouse of householder
#   B09021_011E  18 to 34 years: Householder living with unmarried partner or unmarried partner
#   B09021_012E  18 to 34 years: Child of householder
#   B09021_013E  18 to 34 years: Other relatives
#   B09021_014E  18 to 34 years: Other nonrelatives
#
# Additional variables for controls:
#   B25064_001E  Median gross rent ($)
#   B19013_001E  Median household income ($)
#   B01003_001E  Total population
# ==============================================================================

cat("--- Part A: Fetching Census ACS Table B09021 (Living Arrangements) ---\n")

acs_years <- 2010:2022

# Variables to request — 18-34 age group cells (B09021_008E through B09021_014E)
living_vars <- c("B09021_008E", "B09021_009E", "B09021_010E", "B09021_011E",
                 "B09021_012E", "B09021_013E", "B09021_014E")
extra_vars  <- c("B25064_001E", "B19013_001E", "B01003_001E")
all_vars    <- c("NAME", living_vars, extra_vars)
var_string  <- paste(all_vars, collapse = ",")

acs_list <- list()

for (yr in acs_years) {
  cat("\n  Year:", yr, "\n")

  url <- sprintf(
    "https://api.census.gov/data/%d/acs/acs1?get=%s&for=state:*",
    yr, var_string
  )

  raw <- fetch_json(url)
  df  <- census_to_df(raw)

  if (!is.null(df)) {
    df$year <- yr
    acs_list[[as.character(yr)]] <- df
    cat("    -> Got", nrow(df), "state-level records\n")
  } else {
    cat("    -> FAILED for year", yr, "\n")
  }
}

# Combine all years
acs_raw <- bind_rows(acs_list)

cat("\n  Raw ACS records:", nrow(acs_raw), "\n")

# Clean and convert
acs_panel <- acs_raw %>%
  rename(
    state_name = NAME,
    state_fips = state
  ) %>%
  mutate(
    across(all_of(c(living_vars, extra_vars)), as.numeric),
    state_fips = sprintf("%02d", as.integer(state_fips)),
    state_abbr = fips_to_abbr[state_fips]
  ) %>%
  rename(
    ya_total         = B09021_008E,
    ya_alone         = B09021_009E,
    ya_with_spouse   = B09021_010E,
    ya_with_partner  = B09021_011E,
    ya_with_parents  = B09021_012E,
    ya_other_rel     = B09021_013E,
    ya_other_nonrel  = B09021_014E,
    median_rent      = B25064_001E,
    median_hh_income = B19013_001E,
    total_pop        = B01003_001E
  ) %>%
  mutate(
    # Combine "other relatives" and "other nonrelatives" into single "other"
    ya_other = ya_other_rel + ya_other_nonrel,
    # Primary outcome: share living independently
    #   (alone + with spouse + with partner) / total
    ya_independent    = ya_alone + ya_with_spouse + ya_with_partner,
    share_independent = ya_independent / ya_total,
    # Secondary outcome: share living with parents
    share_with_parents = ya_with_parents / ya_total,
    # Tertiary: share living alone (subset of independent)
    share_alone = ya_alone / ya_total
  ) %>%
  select(
    state_fips, state_abbr, state_name, year,
    ya_total, ya_alone, ya_with_spouse, ya_with_partner,
    ya_with_parents, ya_other_rel, ya_other_nonrel, ya_other,
    ya_independent,
    share_independent, share_with_parents, share_alone,
    median_rent, median_hh_income, total_pop
  ) %>%
  arrange(state_fips, year)

cat("  ACS panel dimensions:", nrow(acs_panel), "x", ncol(acs_panel), "\n")
cat("  States:", length(unique(acs_panel$state_fips)), "\n")
cat("  Years: ", paste(range(acs_panel$year), collapse = " - "), "\n")


# ########################################################################### #
#                                                                             #
#  PART B: STATE MINIMUM WAGE PANEL (Hard-coded from DOL)                     #
#                                                                             #
# ########################################################################### #
#
# Sources:
#   - U.S. Department of Labor, Wage and Hour Division historical tables
#   - Economic Policy Institute Minimum Wage Tracker
#   - National Conference of State Legislatures (NCSL) state MW tables
#   - Individual state labor department records
#
# Federal minimum wage: $7.25/hour since July 24, 2009 (unchanged through 2023)
#
# Treatment definition for Callaway-Sant'Anna DiD:
#   first_treat = first calendar year where effective state MW >= $8.25
#                 (i.e., state MW exceeds federal floor by >= $1.00)
#   Never-treated states: first_treat = 0 (did package convention)
# ==============================================================================

cat("\n--- Part B: Building state minimum wage panel ---\n")

# All 51 state FIPS codes
all_fips <- names(fips_to_abbr)
federal_mw <- 7.25

# Create base panel: 51 entities x 13 years
mw_base <- expand.grid(
  state_fips = all_fips,
  year       = 2010:2022,
  stringsAsFactors = FALSE
) %>%
  mutate(state_mw = federal_mw)  # default: all states start at federal

# Helper: overwrite MW for one state across specified years
set_mw <- function(panel, fips, wages_by_year) {
  for (yr_str in names(wages_by_year)) {
    yr <- as.integer(yr_str)
    idx <- panel$state_fips == fips & panel$year == yr
    panel$state_mw[idx] <- wages_by_year[[yr_str]]
  }
  panel
}

# --- States with MW above federal (alphabetical by FIPS) ---

# Alaska (02): CPI-indexed since 2003; $8.75 ballot measure 2015
mw_base <- set_mw(mw_base, "02", list(
  "2010" = 7.75, "2011" = 7.75, "2012" = 7.75, "2013" = 7.75, "2014" = 7.75,
  "2015" = 8.75, "2016" = 9.75, "2017" = 9.80, "2018" = 9.84, "2019" = 9.89,
  "2020" = 10.19, "2021" = 10.34, "2022" = 10.34
))

# Arizona (04): CPI-indexed; Prop 206 jump to $10.00 in 2017
mw_base <- set_mw(mw_base, "04", list(
  "2010" = 7.25, "2011" = 7.35, "2012" = 7.65, "2013" = 7.80, "2014" = 7.90,
  "2015" = 8.05, "2016" = 8.05, "2017" = 10.00, "2018" = 10.50, "2019" = 11.00,
  "2020" = 12.00, "2021" = 12.15, "2022" = 12.80
))

# Arkansas (05): Issue 5 in 2018 raised to $11 by 2021
mw_base <- set_mw(mw_base, "05", list(
  "2010" = 7.25, "2011" = 7.25, "2012" = 7.25, "2013" = 7.25, "2014" = 7.25,
  "2015" = 7.50, "2016" = 8.00, "2017" = 8.50, "2018" = 8.50, "2019" = 9.25,
  "2020" = 10.00, "2021" = 11.00, "2022" = 11.00
))

# California (06): phased to $15 by 2022 (large employers)
mw_base <- set_mw(mw_base, "06", list(
  "2010" = 8.00, "2011" = 8.00, "2012" = 8.00, "2013" = 8.00, "2014" = 9.00,
  "2015" = 9.00, "2016" = 10.00, "2017" = 10.50, "2018" = 11.00, "2019" = 12.00,
  "2020" = 13.00, "2021" = 14.00, "2022" = 15.00
))

# Colorado (08): CPI-indexed; Amendment 70 jump to $9.30 in 2017
mw_base <- set_mw(mw_base, "08", list(
  "2010" = 7.24, "2011" = 7.36, "2012" = 7.64, "2013" = 7.78, "2014" = 8.00,
  "2015" = 8.23, "2016" = 8.31, "2017" = 9.30, "2018" = 10.20, "2019" = 11.10,
  "2020" = 12.00, "2021" = 12.32, "2022" = 12.56
))

# Connecticut (09): legislative increases
mw_base <- set_mw(mw_base, "09", list(
  "2010" = 8.25, "2011" = 8.25, "2012" = 8.25, "2013" = 8.25, "2014" = 8.70,
  "2015" = 9.15, "2016" = 9.60, "2017" = 10.10, "2018" = 10.10, "2019" = 10.10,
  "2020" = 12.00, "2021" = 13.00, "2022" = 14.00
))

# Delaware (10): legislative increases
mw_base <- set_mw(mw_base, "10", list(
  "2010" = 7.25, "2011" = 7.25, "2012" = 7.25, "2013" = 7.25, "2014" = 7.75,
  "2015" = 8.25, "2016" = 8.25, "2017" = 8.25, "2018" = 8.25, "2019" = 8.75,
  "2020" = 9.25, "2021" = 9.25, "2022" = 10.50
))

# District of Columbia (11): highest MW in the nation
mw_base <- set_mw(mw_base, "11", list(
  "2010" = 8.25, "2011" = 8.25, "2012" = 8.25, "2013" = 8.25, "2014" = 9.50,
  "2015" = 10.50, "2016" = 11.50, "2017" = 12.50, "2018" = 13.25, "2019" = 14.00,
  "2020" = 15.00, "2021" = 15.20, "2022" = 16.10
))

# Florida (12): CPI-indexed; Amendment 2 (2020) phased to $15
mw_base <- set_mw(mw_base, "12", list(
  "2010" = 7.25, "2011" = 7.31, "2012" = 7.67, "2013" = 7.79, "2014" = 7.93,
  "2015" = 8.05, "2016" = 8.05, "2017" = 8.10, "2018" = 8.25, "2019" = 8.46,
  "2020" = 8.56, "2021" = 10.00, "2022" = 10.00
))

# Hawaii (15): legislative increases
mw_base <- set_mw(mw_base, "15", list(
  "2010" = 7.25, "2011" = 7.25, "2012" = 7.25, "2013" = 7.25, "2014" = 7.25,
  "2015" = 7.75, "2016" = 8.50, "2017" = 9.25, "2018" = 10.10, "2019" = 10.10,
  "2020" = 10.10, "2021" = 10.10, "2022" = 10.10
))

# Illinois (17): SB 1 phased to $15 starting 2020
mw_base <- set_mw(mw_base, "17", list(
  "2010" = 8.25, "2011" = 8.25, "2012" = 8.25, "2013" = 8.25, "2014" = 8.25,
  "2015" = 8.25, "2016" = 8.25, "2017" = 8.25, "2018" = 8.25, "2019" = 8.25,
  "2020" = 10.00, "2021" = 11.00, "2022" = 12.00
))

# Maine (23): referendum 2016, effective 2017
mw_base <- set_mw(mw_base, "23", list(
  "2010" = 7.50, "2011" = 7.50, "2012" = 7.50, "2013" = 7.50, "2014" = 7.50,
  "2015" = 7.50, "2016" = 7.50, "2017" = 9.00, "2018" = 10.00, "2019" = 11.00,
  "2020" = 12.00, "2021" = 12.15, "2022" = 12.75
))

# Maryland (24): legislative increases
mw_base <- set_mw(mw_base, "24", list(
  "2010" = 7.25, "2011" = 7.25, "2012" = 7.25, "2013" = 7.25, "2014" = 7.25,
  "2015" = 8.00, "2016" = 8.75, "2017" = 9.25, "2018" = 10.10, "2019" = 10.10,
  "2020" = 11.00, "2021" = 11.75, "2022" = 12.50
))

# Massachusetts (25): Grand Bargain bill 2018
mw_base <- set_mw(mw_base, "25", list(
  "2010" = 8.00, "2011" = 8.00, "2012" = 8.00, "2013" = 8.00, "2014" = 8.00,
  "2015" = 9.00, "2016" = 10.00, "2017" = 11.00, "2018" = 11.00, "2019" = 12.00,
  "2020" = 12.75, "2021" = 13.50, "2022" = 14.25
))

# Michigan (26): Improved Workforce Opportunity Wage Act
mw_base <- set_mw(mw_base, "26", list(
  "2010" = 7.40, "2011" = 7.40, "2012" = 7.40, "2013" = 7.40, "2014" = 7.40,
  "2015" = 8.15, "2016" = 8.50, "2017" = 8.90, "2018" = 9.25, "2019" = 9.45,
  "2020" = 9.65, "2021" = 9.65, "2022" = 9.87
))

# Minnesota (27): SF 1236 (2014)
mw_base <- set_mw(mw_base, "27", list(
  "2010" = 7.25, "2011" = 7.25, "2012" = 7.25, "2013" = 7.25, "2014" = 8.00,
  "2015" = 9.00, "2016" = 9.50, "2017" = 9.50, "2018" = 9.65, "2019" = 9.86,
  "2020" = 10.00, "2021" = 10.08, "2022" = 10.33
))

# Missouri (29): CPI-indexed; Prop B (2018) phased to $12
mw_base <- set_mw(mw_base, "29", list(
  "2010" = 7.25, "2011" = 7.25, "2012" = 7.25, "2013" = 7.35, "2014" = 7.50,
  "2015" = 7.65, "2016" = 7.65, "2017" = 7.70, "2018" = 7.85, "2019" = 8.60,
  "2020" = 9.45, "2021" = 10.30, "2022" = 11.15
))

# Montana (30): CPI-indexed
mw_base <- set_mw(mw_base, "30", list(
  "2010" = 7.25, "2011" = 7.35, "2012" = 7.65, "2013" = 7.80, "2014" = 7.90,
  "2015" = 8.05, "2016" = 8.05, "2017" = 8.15, "2018" = 8.30, "2019" = 8.50,
  "2020" = 8.65, "2021" = 8.75, "2022" = 9.20
))

# Nebraska (31): Initiative 425 (2014)
mw_base <- set_mw(mw_base, "31", list(
  "2010" = 7.25, "2011" = 7.25, "2012" = 7.25, "2013" = 7.25, "2014" = 7.25,
  "2015" = 8.00, "2016" = 9.00, "2017" = 9.00, "2018" = 9.00, "2019" = 9.00,
  "2020" = 9.00, "2021" = 9.00, "2022" = 9.00
))

# Nevada (32): using lower tier (w/ health benefits); higher tier is +$1
mw_base <- set_mw(mw_base, "32", list(
  "2010" = 7.55, "2011" = 7.55, "2012" = 7.55, "2013" = 7.55, "2014" = 7.55,
  "2015" = 7.55, "2016" = 7.55, "2017" = 7.55, "2018" = 7.55, "2019" = 7.55,
  "2020" = 8.00, "2021" = 8.75, "2022" = 9.50
))

# New Jersey (34): 2014 CPI-indexing amendment; 2019 jump to $10
mw_base <- set_mw(mw_base, "34", list(
  "2010" = 7.25, "2011" = 7.25, "2012" = 7.25, "2013" = 7.25, "2014" = 8.25,
  "2015" = 8.38, "2016" = 8.38, "2017" = 8.44, "2018" = 8.60, "2019" = 10.00,
  "2020" = 11.00, "2021" = 12.00, "2022" = 13.00
))

# New Mexico (35): flat at $7.50 until 2020 jump
mw_base <- set_mw(mw_base, "35", list(
  "2010" = 7.50, "2011" = 7.50, "2012" = 7.50, "2013" = 7.50, "2014" = 7.50,
  "2015" = 7.50, "2016" = 7.50, "2017" = 7.50, "2018" = 7.50, "2019" = 7.50,
  "2020" = 9.00, "2021" = 10.50, "2022" = 11.50
))

# New York (36): using general upstate rate (NYC was higher)
mw_base <- set_mw(mw_base, "36", list(
  "2010" = 7.25, "2011" = 7.25, "2012" = 7.25, "2013" = 7.25, "2014" = 8.00,
  "2015" = 8.75, "2016" = 9.00, "2017" = 9.70, "2018" = 10.40, "2019" = 11.10,
  "2020" = 11.80, "2021" = 12.50, "2022" = 13.20
))

# Ohio (39): CPI-indexed (constitutional amendment 2006)
mw_base <- set_mw(mw_base, "39", list(
  "2010" = 7.30, "2011" = 7.40, "2012" = 7.70, "2013" = 7.85, "2014" = 7.95,
  "2015" = 8.10, "2016" = 8.10, "2017" = 8.15, "2018" = 8.30, "2019" = 8.55,
  "2020" = 8.70, "2021" = 8.80, "2022" = 9.30
))

# Oregon (41): CPI-indexed; SB 1532 (2016) tiered increases
mw_base <- set_mw(mw_base, "41", list(
  "2010" = 8.40, "2011" = 8.50, "2012" = 8.80, "2013" = 8.95, "2014" = 9.10,
  "2015" = 9.25, "2016" = 9.75, "2017" = 10.25, "2018" = 10.75, "2019" = 11.25,
  "2020" = 12.00, "2021" = 12.75, "2022" = 13.50
))

# Rhode Island (44): legislative increases
mw_base <- set_mw(mw_base, "44", list(
  "2010" = 7.40, "2011" = 7.40, "2012" = 7.40, "2013" = 7.75, "2014" = 8.00,
  "2015" = 9.00, "2016" = 9.60, "2017" = 9.60, "2018" = 10.10, "2019" = 10.50,
  "2020" = 10.50, "2021" = 11.50, "2022" = 12.25
))

# South Dakota (46): Initiated Measure 18 (2014), CPI-indexed
mw_base <- set_mw(mw_base, "46", list(
  "2010" = 7.25, "2011" = 7.25, "2012" = 7.25, "2013" = 7.25, "2014" = 7.25,
  "2015" = 8.50, "2016" = 8.55, "2017" = 8.65, "2018" = 8.85, "2019" = 9.10,
  "2020" = 9.30, "2021" = 9.45, "2022" = 9.95
))

# Vermont (50): annual legislative increases + CPI indexing
mw_base <- set_mw(mw_base, "50", list(
  "2010" = 8.06, "2011" = 8.15, "2012" = 8.46, "2013" = 8.60, "2014" = 8.73,
  "2015" = 9.15, "2016" = 9.60, "2017" = 10.00, "2018" = 10.50, "2019" = 10.78,
  "2020" = 10.96, "2021" = 11.75, "2022" = 12.55
))

# Virginia (51): first increase in 2021 after decades at federal
mw_base <- set_mw(mw_base, "51", list(
  "2010" = 7.25, "2011" = 7.25, "2012" = 7.25, "2013" = 7.25, "2014" = 7.25,
  "2015" = 7.25, "2016" = 7.25, "2017" = 7.25, "2018" = 7.25, "2019" = 7.25,
  "2020" = 7.25, "2021" = 9.50, "2022" = 11.00
))

# Washington (53): CPI-indexed; I-1433 jump to $11 in 2017
mw_base <- set_mw(mw_base, "53", list(
  "2010" = 8.55, "2011" = 8.67, "2012" = 9.04, "2013" = 9.19, "2014" = 9.32,
  "2015" = 9.47, "2016" = 9.47, "2017" = 11.00, "2018" = 11.50, "2019" = 12.00,
  "2020" = 13.50, "2021" = 13.69, "2022" = 14.49
))

# West Virginia (54): SB 367 (2014), effective 2015
mw_base <- set_mw(mw_base, "54", list(
  "2010" = 7.25, "2011" = 7.25, "2012" = 7.25, "2013" = 7.25, "2014" = 7.25,
  "2015" = 8.00, "2016" = 8.75, "2017" = 8.75, "2018" = 8.75, "2019" = 8.75,
  "2020" = 8.75, "2021" = 8.75, "2022" = 8.75
))

# --- Finalize MW panel ---
mw_panel <- mw_base %>%
  mutate(
    state_abbr   = fips_to_abbr[state_fips],
    federal_mw   = federal_mw,
    effective_mw = pmax(state_mw, federal_mw),
    mw_gap       = effective_mw - federal_mw,
    # Treatment: effective MW exceeds federal by >= $1.00
    treated_yr   = as.integer(mw_gap >= 1.00)
  )

# Compute first_treat: first year each state crosses the $1 threshold
first_treat_df <- mw_panel %>%
  filter(treated_yr == 1) %>%
  group_by(state_fips) %>%
  summarize(first_treat = min(year), .groups = "drop")

# Merge. Never-treated states get first_treat = 0 (did package convention)
mw_panel <- mw_panel %>%
  left_join(first_treat_df, by = "state_fips") %>%
  mutate(first_treat = ifelse(is.na(first_treat), 0L, as.integer(first_treat))) %>%
  arrange(state_fips, year)

# Report treatment distribution
n_ever    <- length(unique(mw_panel$state_fips[mw_panel$first_treat > 0]))
n_never   <- length(unique(mw_panel$state_fips[mw_panel$first_treat == 0]))

cat("\n  MW panel: ", nrow(mw_panel), "observations\n")
cat("  Treated states (ever):", n_ever, "\n")
cat("  Never-treated states: ", n_never, "\n")

cat("\n  Treatment cohort distribution:\n")
mw_panel %>%
  filter(first_treat > 0) %>%
  distinct(state_fips, first_treat, state_abbr) %>%
  arrange(first_treat) %>%
  group_by(first_treat) %>%
  summarize(
    n      = n(),
    states = paste(state_abbr, collapse = ", "),
    .groups = "drop"
  ) %>%
  print(n = Inf)


# ########################################################################### #
#                                                                             #
#  PART C: STATE CONTROLS -- BLS LAUS UNEMPLOYMENT DATA                       #
#                                                                             #
# ########################################################################### #
#
# BLS Local Area Unemployment Statistics (LAUS)
# Series ID format: LASST{2-digit FIPS}0000000000003  (unemployment rate)
# Period M13 = annual average
# Public API v2: https://api.bls.gov/publicAPI/v2/timeseries/data/
# ==============================================================================

cat("\n--- Part C: Fetching BLS LAUS unemployment data ---\n")

# Build series IDs
state_fips_padded <- sprintf("%02d", as.integer(all_fips))
laus_series <- paste0("LASST", state_fips_padded, "0000000000003")

bls_base_url <- "https://api.bls.gov/publicAPI/v2/timeseries/data/"

fetch_bls_data <- function(series_ids, start_year, end_year) {
  payload <- list(
    seriesid  = series_ids,
    startyear = as.character(start_year),
    endyear   = as.character(end_year)
  )

  tryCatch({
    response <- httr::POST(
      bls_base_url,
      body = jsonlite::toJSON(payload, auto_unbox = TRUE),
      httr::content_type_json(),
      httr::timeout(60)
    )
    content_text <- httr::content(response, as = "text", encoding = "UTF-8")
    parsed <- jsonlite::fromJSON(content_text)

    if (parsed$status == "REQUEST_SUCCEEDED") {
      return(parsed$Results$series)
    } else {
      warning("BLS API status: ", parsed$status,
              " | Message: ", paste(parsed$message, collapse = "; "))
      return(NULL)
    }
  }, error = function(e) {
    warning("BLS API error: ", conditionMessage(e))
    return(NULL)
  })
}

# BLS public API limits: 25 series per request, 10-year span
# We need 51 series over 13 years (2010-2022), so split into batches
batch_size <- 25
n_series   <- length(laus_series)
bls_results <- list()

# Split years into two spans: 2010-2019 and 2020-2022
year_spans <- list(c(2010, 2019), c(2020, 2022))

for (span in year_spans) {
  for (i in seq(1, n_series, by = batch_size)) {
    batch_end <- min(i + batch_size - 1, n_series)
    batch_ids <- laus_series[i:batch_end]

    cat("  BLS batch: series", i, "-", batch_end,
        ", years", span[1], "-", span[2], "\n")

    batch_result <- fetch_bls_data(batch_ids, span[1], span[2])

    if (!is.null(batch_result)) {
      bls_results <- c(bls_results, list(batch_result))
    }

    Sys.sleep(1.5)  # rate limiting
  }
}

# Parse BLS results
unemp_list <- list()

for (batch in bls_results) {
  if (is.null(batch)) next
  for (j in seq_len(nrow(batch))) {
    series_id <- batch$seriesID[j]
    data_rows <- batch$data[[j]]

    if (is.null(data_rows) || nrow(data_rows) == 0) next

    # Extract FIPS from LASST{XX}...
    fips_str <- substr(series_id, 6, 7)

    # Keep annual averages only (period M13)
    annual <- data_rows %>%
      filter(period == "M13") %>%
      transmute(
        state_fips = fips_str,
        year       = as.integer(year),
        unemp_rate = as.numeric(value)
      )

    unemp_list[[length(unemp_list) + 1]] <- annual
  }
}

if (length(unemp_list) > 0) {
  unemp_df <- bind_rows(unemp_list) %>%
    arrange(state_fips, year)
  cat("  BLS unemployment records:", nrow(unemp_df), "\n")
} else {
  cat("  WARNING: BLS API returned no data. Creating placeholder.\n")
  unemp_df <- tibble(
    state_fips = character(),
    year       = integer(),
    unemp_rate = numeric()
  )
}


# ########################################################################### #
#                                                                             #
#  MERGE AND SAVE                                                             #
#                                                                             #
# ########################################################################### #

cat("\n--- Merging and saving datasets ---\n")

# (1) Living arrangements panel
living_file <- file.path(DATA_DIR, "living_arrangements.csv")
write_csv(acs_panel, living_file)
cat("  Saved:", living_file, "\n")

# (2) State minimum wage panel
mw_file <- file.path(DATA_DIR, "state_mw.csv")
write_csv(mw_panel, mw_file)
cat("  Saved:", mw_file, "\n")

# (3) State controls (unemployment + housing + income from ACS)
state_controls <- acs_panel %>%
  select(state_fips, state_abbr, state_name, year,
         total_pop, median_rent, median_hh_income) %>%
  left_join(unemp_df, by = c("state_fips", "year"))

controls_file <- file.path(DATA_DIR, "state_controls.csv")
write_csv(state_controls, controls_file)
cat("  Saved:", controls_file, "\n")

# (4) Analysis-ready merged panel (all three datasets joined)
analysis_panel <- acs_panel %>%
  left_join(
    mw_panel %>% select(state_fips, year, state_mw, federal_mw,
                         effective_mw, mw_gap, treated_yr, first_treat),
    by = c("state_fips", "year")
  ) %>%
  left_join(unemp_df, by = c("state_fips", "year")) %>%
  arrange(state_fips, year)

analysis_file <- file.path(DATA_DIR, "analysis_panel.csv")
write_csv(analysis_panel, analysis_file)
cat("  Saved:", analysis_file, "\n")


# ########################################################################### #
#                                                                             #
#  SUMMARY STATISTICS                                                         #
#                                                                             #
# ########################################################################### #

cat("\n====================================================================\n")
cat("  DATA SUMMARY\n")
cat("====================================================================\n\n")

cat("Panel dimensions:\n")
cat("  Observations:", nrow(analysis_panel), "\n")
cat("  States:      ", length(unique(analysis_panel$state_fips)), "\n")
cat("  Years:       ", paste(range(analysis_panel$year), collapse = " - "), "\n")

cat("\nTreatment status:\n")
treat_summary <- analysis_panel %>%
  filter(year == min(year)) %>%
  summarize(
    n_ever_treated  = sum(first_treat > 0),
    n_never_treated = sum(first_treat == 0)
  )
cat("  Ever treated:  ", treat_summary$n_ever_treated, "\n")
cat("  Never treated: ", treat_summary$n_never_treated, "\n")

cat("\nTreatment cohorts:\n")
analysis_panel %>%
  filter(first_treat > 0) %>%
  distinct(state_fips, first_treat, state_abbr) %>%
  arrange(first_treat) %>%
  group_by(first_treat) %>%
  summarize(
    n      = n(),
    states = paste(state_abbr, collapse = ", "),
    .groups = "drop"
  ) %>%
  print(n = Inf)

cat("\nOutcome summary -- share_independent (alone + spouse + partner):\n")
analysis_panel %>%
  summarize(
    mean  = round(mean(share_independent, na.rm = TRUE), 4),
    sd    = round(sd(share_independent, na.rm = TRUE), 4),
    min   = round(min(share_independent, na.rm = TRUE), 4),
    max   = round(max(share_independent, na.rm = TRUE), 4),
    n_obs = sum(!is.na(share_independent))
  ) %>%
  print()

cat("\nOutcome summary -- share_with_parents:\n")
analysis_panel %>%
  summarize(
    mean  = round(mean(share_with_parents, na.rm = TRUE), 4),
    sd    = round(sd(share_with_parents, na.rm = TRUE), 4),
    min   = round(min(share_with_parents, na.rm = TRUE), 4),
    max   = round(max(share_with_parents, na.rm = TRUE), 4),
    n_obs = sum(!is.na(share_with_parents))
  ) %>%
  print()

cat("\nMinimum wage summary -- effective_mw:\n")
analysis_panel %>%
  summarize(
    mean = round(mean(effective_mw, na.rm = TRUE), 2),
    sd   = round(sd(effective_mw, na.rm = TRUE), 2),
    min  = round(min(effective_mw, na.rm = TRUE), 2),
    max  = round(max(effective_mw, na.rm = TRUE), 2)
  ) %>%
  print()

cat("\nControls summary:\n")
analysis_panel %>%
  summarize(
    median_rent_mean  = round(mean(median_rent, na.rm = TRUE), 0),
    median_rent_sd    = round(sd(median_rent, na.rm = TRUE), 0),
    unemp_rate_mean   = round(mean(unemp_rate, na.rm = TRUE), 1),
    unemp_rate_sd     = round(sd(unemp_rate, na.rm = TRUE), 1),
    unemp_n_nonmiss   = sum(!is.na(unemp_rate))
  ) %>%
  print()

cat("\n====================================================================\n")
cat("  01_fetch_data.R: COMPLETE\n")
cat("  Files saved to:", DATA_DIR, "\n")
cat("====================================================================\n")
