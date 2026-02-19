## =============================================================================
## 02_clean_data.R — Variable Construction and Panel Assembly
## APEP-0369: Click to Prescribe
## =============================================================================

source("00_packages.R")

cat("=== Cleaning and assembling panel data ===\n")

## ---------------------------------------------------------------------------
## 1. Clean CDC overdose data
## ---------------------------------------------------------------------------

cdc_raw <- readRDS("../data/cdc_vsrr_raw.rds")

# State abbreviation to FIPS crosswalk
state_fips <- readRDS("../data/epcs_mandates.rds") %>%
  select(state_abbr, state_fips, state_name) %>%
  distinct()

# Clean CDC data: keep December 12-month-ending (annual totals)
cdc_clean <- cdc_raw %>%
  filter(month == "December", period == "12 month-ending") %>%
  mutate(
    year = as.integer(year),
    deaths = as.numeric(data_value)
  ) %>%
  filter(!is.na(deaths), !state %in% c("US", "YC")) %>%
  rename(state_abbr = state) %>%
  select(state_abbr, year, indicator, deaths)

# Pivot to wide format (one column per drug class)
cdc_wide <- cdc_clean %>%
  mutate(
    var_name = case_when(
      indicator == "Number of Drug Overdose Deaths" ~ "total_od_deaths",
      indicator == "Natural & semi-synthetic opioids (T40.2)" ~ "rx_opioid_deaths",
      indicator == "Synthetic opioids, excl. methadone (T40.4)" ~ "synth_opioid_deaths",
      indicator == "Opioids (T40.0-T40.4,T40.6)" ~ "all_opioid_deaths",
      indicator == "Heroin (T40.1)" ~ "heroin_deaths",
      indicator == "Cocaine (T40.5)" ~ "cocaine_deaths",
      indicator == "Psychostimulants with abuse potential (T43.6)" ~ "stimulant_deaths",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(var_name)) %>%
  select(state_abbr, year, var_name, deaths) %>%
  pivot_wider(names_from = var_name, values_from = deaths)

cat(sprintf("  CDC data: %d state-years, %d states, years %d-%d\n",
            nrow(cdc_wide), n_distinct(cdc_wide$state_abbr),
            min(cdc_wide$year), max(cdc_wide$year)))

## ---------------------------------------------------------------------------
## 2. Merge population data
## ---------------------------------------------------------------------------

pop_df <- readRDS("../data/state_population.rds")

# Merge state abbreviations onto population data
pop_with_abbr <- pop_df %>%
  left_join(state_fips, by = "state_fips") %>%
  select(state_abbr, year, population)

## ---------------------------------------------------------------------------
## 3. Merge treatment and control variables
## ---------------------------------------------------------------------------

epcs <- readRDS("../data/epcs_mandates.rds")
pdmp <- readRDS("../data/pdmp_mandates.rds")

# Load unemployment if available
unemp_file <- "../data/state_unemployment.rds"
if (file.exists(unemp_file)) {
  unemp <- readRDS(unemp_file)
} else {
  unemp <- NULL
}

## ---------------------------------------------------------------------------
## 4. Assemble balanced panel
## ---------------------------------------------------------------------------

# Create balanced state-year panel
states_in_data <- intersect(cdc_wide$state_abbr, epcs$state_abbr)
years <- 2015:2023

panel <- expand.grid(
  state_abbr = states_in_data,
  year = years,
  stringsAsFactors = FALSE
)

# Merge in outcomes
panel <- panel %>%
  left_join(cdc_wide, by = c("state_abbr", "year")) %>%
  left_join(pop_with_abbr, by = c("state_abbr", "year")) %>%
  left_join(epcs %>% select(state_abbr, state_fips, state_name, epcs_mandate_year),
            by = "state_abbr") %>%
  left_join(pdmp %>% select(state_abbr, pdmp_mandate_year),
            by = "state_abbr")

# Fill missing PDMP mandate years (states without mandate)
panel <- panel %>%
  mutate(pdmp_mandate_year = ifelse(is.na(pdmp_mandate_year), 0, pdmp_mandate_year))

# Merge unemployment
if (!is.null(unemp)) {
  panel <- panel %>%
    left_join(unemp, by = c("state_abbr", "year"))
}

## ---------------------------------------------------------------------------
## 5. Construct analysis variables
## ---------------------------------------------------------------------------

panel <- panel %>%
  mutate(
    # Death rates per 100,000 population
    rx_opioid_death_rate = ifelse(!is.na(population) & population > 0,
                                  rx_opioid_deaths / population * 100000, NA),
    synth_opioid_death_rate = ifelse(!is.na(population) & population > 0,
                                     synth_opioid_deaths / population * 100000, NA),
    all_opioid_death_rate = ifelse(!is.na(population) & population > 0,
                                   all_opioid_deaths / population * 100000, NA),
    total_od_death_rate = ifelse(!is.na(population) & population > 0,
                                 total_od_deaths / population * 100000, NA),
    heroin_death_rate = ifelse(!is.na(population) & population > 0,
                               heroin_deaths / population * 100000, NA),
    cocaine_death_rate = ifelse(!is.na(population) & population > 0,
                                cocaine_deaths / population * 100000, NA),
    stimulant_death_rate = ifelse(!is.na(population) & population > 0,
                                  stimulant_deaths / population * 100000, NA),

    # Treatment indicators
    epcs_treated = as.integer(epcs_mandate_year > 0 & year >= epcs_mandate_year),
    pdmp_treated = as.integer(pdmp_mandate_year > 0 & year >= pdmp_mandate_year),

    # Log outcomes (for percent interpretation)
    log_rx_opioid_deaths = log(pmax(rx_opioid_deaths, 1)),
    log_synth_opioid_deaths = log(pmax(synth_opioid_deaths, 1)),
    log_all_opioid_deaths = log(pmax(all_opioid_deaths, 1)),

    # Event time
    event_time = ifelse(epcs_mandate_year > 0, year - epcs_mandate_year, NA),

    # Numeric state ID for panel
    state_id = as.integer(factor(state_abbr))
  )

## ---------------------------------------------------------------------------
## 6. Summary statistics
## ---------------------------------------------------------------------------

cat("\n=== Panel Summary ===\n")
cat(sprintf("States: %d (%d treated, %d control)\n",
            n_distinct(panel$state_abbr),
            n_distinct(panel$state_abbr[panel$epcs_mandate_year > 0]),
            n_distinct(panel$state_abbr[panel$epcs_mandate_year == 0])))
cat(sprintf("Years: %d-%d\n", min(panel$year), max(panel$year)))
cat(sprintf("State-years: %d\n", nrow(panel)))

cat("\nOutcome summary (death rates per 100K):\n")
panel %>%
  filter(!is.na(rx_opioid_death_rate)) %>%
  summarise(
    n = n(),
    mean_rx = mean(rx_opioid_death_rate, na.rm = TRUE),
    sd_rx = sd(rx_opioid_death_rate, na.rm = TRUE),
    mean_synth = mean(synth_opioid_death_rate, na.rm = TRUE),
    sd_synth = sd(synth_opioid_death_rate, na.rm = TRUE),
    mean_total = mean(total_od_death_rate, na.rm = TRUE),
    sd_total = sd(total_od_death_rate, na.rm = TRUE)
  ) %>%
  print()

cat("\nTreatment rollout:\n")
panel %>%
  filter(epcs_mandate_year > 0) %>%
  group_by(epcs_mandate_year) %>%
  summarise(n_states = n_distinct(state_abbr)) %>%
  arrange(epcs_mandate_year) %>%
  print()

## ---------------------------------------------------------------------------
## 7. Save panel
## ---------------------------------------------------------------------------

saveRDS(panel, "../data/analysis_panel.rds")
write_csv(panel, "../data/analysis_panel.csv")

cat("\n=== Panel saved to ../data/analysis_panel.rds ===\n")
