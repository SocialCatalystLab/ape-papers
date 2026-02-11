## ============================================================================
## 02_clean_data.R — Clean and merge data into analysis panel
## APEP Working Paper apep_0225
## ============================================================================

source("00_packages.R")

data_dir <- "../data"

## ---------------------------------------------------------------------------
## 1. Load raw data
## ---------------------------------------------------------------------------

cdc_raw <- readRDS(file.path(data_dir, "cdc_vsrr_raw.rds"))
pop_df <- readRDS(file.path(data_dir, "state_population.rds"))
state_fips <- readRDS(file.path(data_dir, "state_fips.rds"))
fts_laws <- readRDS(file.path(data_dir, "fts_laws.rds"))
naloxone_laws <- readRDS(file.path(data_dir, "naloxone_laws.rds"))
medicaid_exp <- readRDS(file.path(data_dir, "medicaid_expansion.rds"))
econ_df <- readRDS(file.path(data_dir, "state_econ_controls.rds"))

## ---------------------------------------------------------------------------
## 2. Clean CDC VSRR data — collapse to state-year
## ---------------------------------------------------------------------------

cat("Cleaning CDC VSRR data...\n")

# VSRR data is 12-month-ending counts, reported monthly.
# Use December of each year = annual total for that calendar year.
# The "data_value" field is the death count.

cdc_annual <- cdc_raw %>%
  filter(
    month == "December",
    period == "12 month-ending",
    state != "US",           # Exclude national total
    state != "YC"            # Exclude NYC (separate from NY)
  ) %>%
  mutate(
    year = as.integer(year),
    deaths = as.numeric(data_value)
  ) %>%
  filter(!is.na(deaths), year >= 2013, year <= 2023) %>%
  select(state_abb = state, year, indicator, deaths)

# Pivot to wide format: one row per state-year
cdc_wide <- cdc_annual %>%
  mutate(
    var_name = case_when(
      grepl("T40.4", indicator) ~ "deaths_synth_opioid",
      grepl("T40.0-T40.4", indicator) ~ "deaths_all_opioid",
      grepl("T40.5", indicator) ~ "deaths_cocaine",
      grepl("T43.6", indicator) ~ "deaths_stimulant",
      grepl("Number of Drug Overdose", indicator) ~ "deaths_all_drug",
      grepl("T40.2", indicator) ~ "deaths_natural_opioid",
      grepl("T40.1", indicator) ~ "deaths_heroin",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(var_name)) %>%
  group_by(state_abb, year, var_name) %>%
  summarise(deaths = max(deaths, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = var_name, values_from = deaths, values_fill = 0)

cat("CDC wide data:", nrow(cdc_wide), "state-years\n")
cat("Columns available:", paste(names(cdc_wide), collapse = ", "), "\n")

# Ensure all expected columns exist (fill with 0 if missing)
expected_cols <- c("deaths_synth_opioid", "deaths_all_opioid", "deaths_cocaine",
                   "deaths_stimulant", "deaths_all_drug", "deaths_natural_opioid",
                   "deaths_heroin")
for (col in expected_cols) {
  if (!(col %in% names(cdc_wide))) {
    cat("  Adding missing column:", col, "\n")
    cdc_wide[[col]] <- 0
  }
}

## ---------------------------------------------------------------------------
## 3. Merge with population and compute rates
## ---------------------------------------------------------------------------

# Join FIPS to CDC data
panel <- cdc_wide %>%
  left_join(state_fips %>% select(state_abb, state_fips, state_name),
            by = "state_abb") %>%
  filter(!is.na(state_fips))

# Join population
panel <- panel %>%
  left_join(pop_df, by = c("state_fips", "year"))

# Compute death rates per 100,000
panel <- panel %>%
  mutate(
    rate_synth_opioid = deaths_synth_opioid / population * 100000,
    rate_all_opioid = deaths_all_opioid / population * 100000,
    rate_cocaine = deaths_cocaine / population * 100000,
    rate_stimulant = deaths_stimulant / population * 100000,
    rate_all_drug = deaths_all_drug / population * 100000,
    rate_natural_opioid = deaths_natural_opioid / population * 100000,
    rate_heroin = deaths_heroin / population * 100000
  )

## ---------------------------------------------------------------------------
## 4. Merge FTS treatment assignment
## ---------------------------------------------------------------------------

cat("Assigning FTS treatment status...\n")

# Map treatment year to each state
# Never-treated states get first_treat = 0 (for `did` package convention)
# Ambiguous states are flagged for sensitivity analysis

never_treated <- c("ID", "IN", "IA", "ND", "TX")
ambiguous_states <- c("AK", "NE", "OR", "WY")

fts_treat <- state_fips %>%
  left_join(
    fts_laws %>% select(state_abb, effective_year, exposure_fraction),
    by = "state_abb"
  ) %>%
  mutate(
    first_treat = case_when(
      state_abb %in% never_treated ~ 0L,        # Never treated
      state_abb %in% ambiguous_states ~ NA_integer_, # Exclude
      !is.na(effective_year) ~ as.integer(effective_year),
      TRUE ~ NA_integer_
    ),
    treat_group = case_when(
      first_treat == 0 ~ "Never treated",
      !is.na(first_treat) ~ paste0("Cohort ", first_treat),
      state_abb %in% ambiguous_states ~ "Ambiguous",
      TRUE ~ "Untreated (late/missing)"
    )
  ) %>%
  select(state_abb, state_fips, first_treat, treat_group, exposure_fraction)

panel <- panel %>%
  left_join(fts_treat, by = c("state_abb", "state_fips"))

# Create binary treatment indicator
panel <- panel %>%
  mutate(
    treated = as.integer(!is.na(first_treat) & first_treat > 0 & year >= first_treat),
    # Partial-year exposure for treatment year
    treat_intensity = case_when(
      is.na(first_treat) | first_treat == 0 ~ 0,
      year > first_treat ~ 1,
      year == first_treat ~ coalesce(exposure_fraction, 0.5),
      TRUE ~ 0
    )
  )

## ---------------------------------------------------------------------------
## 5. Merge concurrent policy controls
## ---------------------------------------------------------------------------

panel <- panel %>%
  left_join(naloxone_laws, by = "state_abb") %>%
  mutate(naloxone_law = as.integer(!is.na(naloxone_year) & year >= naloxone_year)) %>%
  left_join(medicaid_exp, by = "state_abb") %>%
  mutate(medicaid_expanded = as.integer(!is.na(medicaid_exp_year) & year >= medicaid_exp_year))

## ---------------------------------------------------------------------------
## 6. Merge economic controls
## ---------------------------------------------------------------------------

panel <- panel %>%
  left_join(econ_df, by = c("state_fips", "year"))

## ---------------------------------------------------------------------------
## 7. Create analysis variables
## ---------------------------------------------------------------------------

# Log transformation (adding 0.1 to handle zeros)
panel <- panel %>%
  mutate(
    log_rate_synth = log(rate_synth_opioid + 0.1),
    log_rate_all_drug = log(rate_all_drug + 0.1),
    log_rate_cocaine = log(rate_cocaine + 0.1),
    log_rate_stimulant = log(rate_stimulant + 0.1),
    # State numeric ID for did package
    state_id = as.integer(factor(state_fips)),
    # Baseline (2017) fentanyl death rate quintile
    # (for heterogeneity analysis)
    state_abb_factor = factor(state_abb)
  )

# Compute baseline overdose quintiles
baseline <- panel %>%
  filter(year == 2017) %>%
  mutate(
    baseline_synth_rate = rate_synth_opioid,
    baseline_quintile = ntile(baseline_synth_rate, 5)
  ) %>%
  select(state_abb, baseline_synth_rate, baseline_quintile)

panel <- panel %>%
  left_join(baseline, by = "state_abb")

## ---------------------------------------------------------------------------
## 8. Exclusion criteria
## ---------------------------------------------------------------------------

# Main analysis sample: exclude ambiguous states, keep 2013-2023
analysis_df <- panel %>%
  filter(
    !(state_abb %in% ambiguous_states),
    year >= 2013, year <= 2023,
    !is.na(rate_synth_opioid),
    !is.na(population)
  )

cat("\n=== Analysis panel summary ===\n")
cat("States:", n_distinct(analysis_df$state_abb), "\n")
cat("Years:", min(analysis_df$year), "-", max(analysis_df$year), "\n")
cat("Observations:", nrow(analysis_df), "\n")
cat("Never-treated:", sum(analysis_df$first_treat == 0 & analysis_df$year == 2020), "states\n")
cat("Treatment cohorts:\n")
print(table(analysis_df$treat_group[analysis_df$year == 2023]))

## ---------------------------------------------------------------------------
## 9. Save
## ---------------------------------------------------------------------------

saveRDS(analysis_df, file.path(data_dir, "analysis_panel.rds"))
write_csv(analysis_df, file.path(data_dir, "analysis_panel.csv"))

cat("\nAnalysis panel saved.\n")
