# ==============================================================================
# Paper 72: PDMP Mandatory Query Effects on Opioid Overdose Deaths
# 02_process_pdmp_data.R - Process and merge CDC mortality + PDMP dates
# ==============================================================================

library(tidyverse)

cat("=== Processing PDMP Data ===\n\n")

# ------------------------------------------------------------------------------
# Load CDC VSRR Overdose Data
# ------------------------------------------------------------------------------

cdc <- read_csv("../data_pdmp/cdc_vsrr_overdose.csv", show_col_types = FALSE)
cat(sprintf("Loaded CDC VSRR data: %d rows\n", nrow(cdc)))

# Focus on opioid deaths (T40.0-T40.4, T40.6)
opioid_deaths <- cdc %>%
  filter(Indicator == "Opioids (T40.0-T40.4,T40.6)") %>%
  # Use December of each year for annual snapshot
  filter(Month == "December") %>%
  select(
    state_abbr = State,
    state_name = `State Name`,
    year = Year,
    opioid_deaths = `Data Value`,
    predicted_deaths = `Predicted Value`
  ) %>%
  # Use predicted when actual suppressed
  mutate(
    opioid_deaths_clean = coalesce(opioid_deaths, predicted_deaths)
  )

cat(sprintf("Opioid deaths by state-year: %d rows\n", nrow(opioid_deaths)))
cat(sprintf("Years covered: %d to %d\n", min(opioid_deaths$year), max(opioid_deaths$year)))

# Also get total drug overdose deaths for rate calculation
total_deaths <- cdc %>%
  filter(Indicator == "Number of Drug Overdose Deaths") %>%
  filter(Month == "December") %>%
  select(
    state_abbr = State,
    year = Year,
    total_overdose_deaths = `Data Value`,
    total_predicted = `Predicted Value`
  ) %>%
  mutate(
    total_overdose_clean = coalesce(total_overdose_deaths, total_predicted)
  )

# Merge
mortality <- opioid_deaths %>%
  left_join(total_deaths, by = c("state_abbr", "year"))

cat(sprintf("Merged mortality data: %d rows\n", nrow(mortality)))

# ------------------------------------------------------------------------------
# Load PDMP Mandate Dates
# ------------------------------------------------------------------------------

pdmp <- read_csv("../data_pdmp/pdmp_mandate_dates.csv", show_col_types = FALSE) %>%
  mutate(
    mandate_year = as.integer(mandate_year),
    has_mandate = !is.na(mandate_year)
  )

cat(sprintf("\nPDMP mandate dates loaded: %d states\n", nrow(pdmp)))
cat(sprintf("States with mandates: %d\n", sum(pdmp$has_mandate)))
cat(sprintf("States without mandates (never-treated): %d\n", sum(!pdmp$has_mandate)))

# Distribution of mandate adoption years
cat("\nMandate adoption by year:\n")
print(table(pdmp$mandate_year, useNA = "ifany"))

# ------------------------------------------------------------------------------
# Merge PDMP mandates with mortality data
# ------------------------------------------------------------------------------

panel <- mortality %>%
  left_join(pdmp %>% select(state_abbr, mandate_year, has_mandate), by = "state_abbr") %>%
  filter(!is.na(state_name)) %>%  # Remove non-state entries (like US total)
  filter(state_abbr != "US")

# Create treatment indicators
panel <- panel %>%
  mutate(
    # Treatment: year >= mandate effective year
    treated = if_else(has_mandate & year >= mandate_year, 1L, 0L),
    # Post indicator for treated states
    post = if_else(has_mandate, year >= mandate_year, NA),
    # Years since mandate (for event study)
    rel_year = if_else(has_mandate, year - mandate_year, NA_integer_),
    # Group for Callaway-Sant'Anna: cohort year (mandate_year) or 0 for never-treated
    cohort = if_else(has_mandate, mandate_year, 0L)
  )

cat(sprintf("\nFinal panel: %d state-years\n", nrow(panel)))
cat(sprintf("Unique states: %d\n", n_distinct(panel$state_abbr)))
cat(sprintf("Years: %d to %d\n", min(panel$year), max(panel$year)))

# Check treatment timing distribution
cat("\nTreatment distribution:\n")
print(table(panel$treated, useNA = "ifany"))

cat("\nRelative year distribution (treated states only):\n")
print(table(panel$rel_year, useNA = "ifany"))

# ------------------------------------------------------------------------------
# Summary statistics
# ------------------------------------------------------------------------------

cat("\n=== Summary Statistics ===\n")

# By treatment status
panel %>%
  group_by(treated) %>%
  summarise(
    n = n(),
    mean_opioid_deaths = mean(opioid_deaths_clean, na.rm = TRUE),
    sd_opioid_deaths = sd(opioid_deaths_clean, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  print()

# By cohort
cat("\nBy treatment cohort:\n")
panel %>%
  filter(has_mandate) %>%
  group_by(cohort) %>%
  summarise(
    n_states = n_distinct(state_abbr),
    n_obs = n(),
    .groups = "drop"
  ) %>%
  print()

# ------------------------------------------------------------------------------
# Save processed data
# ------------------------------------------------------------------------------

saveRDS(panel, "../data_pdmp/panel_state_year.rds")
write_csv(panel, "../data_pdmp/panel_state_year.csv")

cat("\n=== Saved: data_pdmp/panel_state_year.rds ===\n")
