###############################################################################
# 02_clean_data.R
# Paper 112: EERS and Residential Electricity Consumption
# Clean, merge, and construct analysis variables
###############################################################################

source("00_packages.R")

data_dir <- "../data/"

###############################################################################
# PART 1: Load raw data
###############################################################################

treatment_df      <- readRDS(paste0(data_dir, "eers_treatment.rds"))
res_consumption   <- readRDS(paste0(data_dir, "res_consumption_raw.rds"))
total_consumption <- readRDS(paste0(data_dir, "total_consumption_raw.rds"))
com_consumption   <- readRDS(paste0(data_dir, "com_consumption_raw.rds"))
ind_consumption   <- readRDS(paste0(data_dir, "ind_consumption_raw.rds"))
res_prices        <- readRDS(paste0(data_dir, "res_prices_raw.rds"))
com_prices        <- readRDS(paste0(data_dir, "com_prices_raw.rds"))
population        <- readRDS(paste0(data_dir, "population_raw.rds"))
state_fips        <- readRDS(paste0(data_dir, "state_fips.rds"))

###############################################################################
# PART 2: Clean consumption data
###############################################################################

# Filter to 50 states + DC, exclude US total and territories
valid_states <- state_fips$state_abbr

clean_consumption <- function(df, var_name) {
  df %>%
    filter(state_abbr %in% valid_states,
           year >= 1990, year <= 2023,
           !is.na(value), value > 0) %>%
    select(year, state_abbr, value) %>%
    rename(!!var_name := value) %>%
    distinct(year, state_abbr, .keep_all = TRUE)
}

res_clean   <- clean_consumption(res_consumption, "res_elec_btu")
total_clean <- clean_consumption(total_consumption, "total_elec_btu")
com_clean   <- clean_consumption(com_consumption, "com_elec_btu")
ind_clean   <- clean_consumption(ind_consumption, "ind_elec_btu")

# Clean price data
res_price_clean <- res_prices %>%
  filter(state_abbr %in% valid_states,
         year >= 1990, year <= 2023,
         !is.na(price_cents_kwh)) %>%
  select(year, state_abbr, price_cents_kwh, sales_mwh) %>%
  rename(res_price = price_cents_kwh, res_sales_mwh = sales_mwh) %>%
  distinct(year, state_abbr, .keep_all = TRUE)

com_price_clean <- com_prices %>%
  filter(state_abbr %in% valid_states,
         year >= 1990, year <= 2023,
         !is.na(price_cents_kwh)) %>%
  select(year, state_abbr, price_cents_kwh) %>%
  rename(com_price = price_cents_kwh) %>%
  distinct(year, state_abbr, .keep_all = TRUE)

###############################################################################
# PART 3: Clean population data
###############################################################################

# Merge state_fips to population
pop_clean <- population %>%
  left_join(state_fips %>% select(state_fips, state_abbr),
            by = "state_fips") %>%
  filter(!is.na(state_abbr), !is.na(population), population > 0) %>%
  select(year, state_abbr, population) %>%
  distinct(year, state_abbr, .keep_all = TRUE)

# Check what years we have
pop_years <- pop_clean %>% distinct(year) %>% pull(year) %>% sort()
cat("Population data available for years:", range(pop_years), "\n")
cat("  Total population year-state records:", nrow(pop_clean), "\n")

###############################################################################
# PART 4: Merge all datasets
###############################################################################

# Create master state-year panel
panel <- expand_grid(
  year = 1990:2023,
  state_abbr = valid_states
)

# Merge everything
panel <- panel %>%
  left_join(res_clean, by = c("year", "state_abbr")) %>%
  left_join(total_clean, by = c("year", "state_abbr")) %>%
  left_join(com_clean, by = c("year", "state_abbr")) %>%
  left_join(ind_clean, by = c("year", "state_abbr")) %>%
  left_join(res_price_clean, by = c("year", "state_abbr")) %>%
  left_join(com_price_clean, by = c("year", "state_abbr")) %>%
  left_join(pop_clean, by = c("year", "state_abbr")) %>%
  left_join(treatment_df %>% select(state_abbr, eers_year, eers_type),
            by = "state_abbr") %>%
  left_join(state_fips %>% select(state_abbr, state_fips, state_name),
            by = "state_abbr")

###############################################################################
# PART 5: Construct analysis variables
###############################################################################

panel <- panel %>%
  mutate(
    # Per-capita consumption (Billion Btu / population)
    res_elec_pc = res_elec_btu / population,
    total_elec_pc = total_elec_btu / population,
    com_elec_pc = com_elec_btu / population,
    ind_elec_pc = ind_elec_btu / population,

    # FIXED: Log transformations with zero-value guards
    # Use ifelse to return NA for non-positive values instead of -Inf
    log_res_elec_pc = ifelse(res_elec_pc > 0, log(res_elec_pc), NA_real_),
    log_total_elec_pc = ifelse(total_elec_pc > 0, log(total_elec_pc), NA_real_),
    log_res_elec = ifelse(res_elec_btu > 0, log(res_elec_btu), NA_real_),
    log_total_elec = ifelse(total_elec_btu > 0, log(total_elec_btu), NA_real_),
    log_res_price = ifelse(res_price > 0, log(res_price), NA_real_),

    # Per-capita sales (MWh / population) — alternative measure
    res_sales_pc = res_sales_mwh / population,
    log_res_sales_pc = ifelse(res_sales_pc > 0, log(res_sales_pc), NA_real_),

    # Treatment indicators
    eers_year = ifelse(is.na(eers_year), 0L, as.integer(eers_year)),
    treated = as.integer(eers_year > 0),
    post = as.integer(year >= eers_year & eers_year > 0),

    # State numeric ID for DiD
    state_id = as.integer(as.factor(state_abbr)),

    # Event time (years since treatment; NA for never-treated)
    event_time = ifelse(eers_year > 0, year - eers_year, NA_integer_)
  )

###############################################################################
# PART 6: Data quality checks
###############################################################################

cat("\n=== DATA QUALITY CHECKS ===\n")

# Check panel balance
n_states <- n_distinct(panel$state_abbr)
n_years <- n_distinct(panel$year)
cat("Panel: ", n_states, " states x ", n_years, " years = ",
    n_states * n_years, " potential obs\n")
cat("Actual observations:", nrow(panel), "\n")

# Check missingness
cat("\nMissing values:\n")
panel %>%
  summarise(across(c(res_elec_btu, total_elec_btu, population, res_price),
                   ~sum(is.na(.)))) %>%
  print()

# Check treatment coding
cat("\nTreatment summary:\n")
treatment_summary <- panel %>%
  filter(year == 2020) %>%
  group_by(treated) %>%
  summarise(n_states = n_distinct(state_abbr), .groups = "drop")
print(treatment_summary)

# Adoption cohort sizes
cat("\nAdoption cohort sizes:\n")
panel %>%
  filter(eers_year > 0) %>%
  distinct(state_abbr, eers_year) %>%
  count(eers_year, name = "n_states") %>%
  arrange(eers_year) %>%
  print(n = 30)

# Drop rows with missing key variables for main analysis
panel_clean <- panel %>%
  filter(!is.na(res_elec_btu), !is.na(population), population > 0)

cat("\nClean panel:", nrow(panel_clean), "obs after dropping missing\n")

###############################################################################
# PART 7: Merge Weather and Policy Controls (if available)
###############################################################################

cat("\n=== MERGING ADDITIONAL CONTROLS ===\n")

# Merge weather data (HDD/CDD) if available
weather_file <- paste0(data_dir, "weather_hdd_cdd.rds")
if (file.exists(weather_file)) {
  weather <- readRDS(weather_file)
  panel_clean <- panel_clean %>%
    left_join(weather %>% select(year, state_abbr, hdd, cdd),
              by = c("year", "state_abbr"))
  cat("Weather data merged. HDD/CDD available for",
      sum(!is.na(panel_clean$hdd)), "/", nrow(panel_clean), "obs\n")
} else {
  cat("Weather data not yet fetched. Run 01b_fetch_weather.R first.\n")
  panel_clean <- panel_clean %>%
    mutate(hdd = NA_real_, cdd = NA_real_)
}

# Merge policy controls if available
policy_file <- paste0(data_dir, "policy_controls.rds")
if (file.exists(policy_file)) {
  policy <- readRDS(policy_file)
  panel_clean <- panel_clean %>%
    left_join(policy %>% select(year, state_abbr, has_rps, has_decoupling,
                                has_building_code, census_division, census_region),
              by = c("year", "state_abbr"))
  cat("Policy controls merged.\n")
  cat("  States with RPS (2020):", sum(panel_clean$has_rps[panel_clean$year == 2020], na.rm = TRUE), "\n")
  cat("  States with decoupling (2020):", sum(panel_clean$has_decoupling[panel_clean$year == 2020], na.rm = TRUE), "\n")
} else {
  cat("Policy controls not yet constructed. Run 01c_fetch_policy.R first.\n")
  panel_clean <- panel_clean %>%
    mutate(has_rps = NA_integer_, has_decoupling = NA_integer_,
           has_building_code = NA_integer_, census_division = NA_integer_,
           census_region = NA_character_)
}

###############################################################################
# PART 8: Save
###############################################################################

saveRDS(panel, paste0(data_dir, "panel_full.rds"))
saveRDS(panel_clean, paste0(data_dir, "panel_clean.rds"))

cat("\n=== CLEANING COMPLETE ===\n")
cat("Full panel saved:", nrow(panel), "rows\n")
cat("Clean panel saved:", nrow(panel_clean), "rows\n")
