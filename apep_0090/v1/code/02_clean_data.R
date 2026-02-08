# ==============================================================================
# Paper 112: State Data Privacy Laws and Technology Sector Business Formation
# 02_clean_data.R - Clean and prepare analysis dataset
# ==============================================================================

source("00_packages.R")

# ==============================================================================
# 1. Load raw data
# ==============================================================================

privacy_laws <- read_csv(file.path(dir_data, "privacy_laws.csv"),
                         show_col_types = FALSE)
business_apps <- read_csv(file.path(dir_data, "business_applications.csv"),
                          show_col_types = FALSE)
unemployment <- read_csv(file.path(dir_data, "unemployment.csv"),
                         show_col_types = FALSE)
all_states <- read_csv(file.path(dir_data, "all_states.csv"),
                       show_col_types = FALSE)

message("Loaded ", nrow(business_apps), " business application observations")
message("Loaded ", nrow(privacy_laws), " privacy law entries")

# ==============================================================================
# 2. Create panel structure
# ==============================================================================

# Define analysis period
start_date <- as.Date("2018-01-01")
end_date <- as.Date("2025-06-01")

# Create state-month panel
panel <- expand_grid(
  state_abbr = all_states$state_abbr,
  date = seq(start_date, end_date, by = "month")
) %>%
  mutate(
    year = year(date),
    month = month(date),
    year_month = floor_date(date, "month")
  )

message("Created panel: ", nrow(panel), " state-months")

# ==============================================================================
# 3. Merge treatment status
# ==============================================================================

# For primary analysis: focus on 2023+ wave (exclude CA)
# CA will be analyzed separately via SCM

privacy_laws_2023 <- privacy_laws %>%
  filter(effective_date >= "2023-01-01",
         effective_date <= "2025-06-01") %>%  # Only include laws that are effective by our end date
  select(state_abbr, effective_date, threshold_consumers)

# Create treatment indicators
panel <- panel %>%
  left_join(privacy_laws_2023, by = "state_abbr") %>%
  mutate(
    # Treatment group: 1 if state ever gets privacy law in 2023+
    treated_ever = !is.na(effective_date),

    # Treatment status at time t
    treated = if_else(
      !is.na(effective_date) & date >= effective_date,
      1L, 0L
    ),

    # For Callaway-Sant'Anna: cohort is year-month of treatment
    # Convert to numeric for did package (months since Jan 2018)
    cohort = if_else(
      treated_ever,
      as.numeric(interval(start_date, effective_date) %/% months(1)) + 1,
      0  # Never treated
    ),

    # Time period (months since Jan 2018)
    time_period = as.numeric(interval(start_date, date) %/% months(1)) + 1
  )

# Check treatment assignment
treatment_summary <- panel %>%
  filter(date == "2025-01-01") %>%
  group_by(treated_ever) %>%
  summarise(n_states = n_distinct(state_abbr))

message("\nTreatment summary (as of Jan 2025):")
print(treatment_summary)

# ==============================================================================
# 4. Merge outcomes
# ==============================================================================

# Use high-propensity business applications as primary outcome
outcome_data <- business_apps %>%
  filter(type == "high_propensity") %>%
  mutate(date = floor_date(date, "month")) %>%
  group_by(state_abbr, date) %>%
  summarise(business_apps = mean(business_apps, na.rm = TRUE),
            .groups = "drop")

panel <- panel %>%
  left_join(outcome_data, by = c("state_abbr", "date"))

# Also add total applications
outcome_total <- business_apps %>%
  filter(type == "total") %>%
  mutate(date = floor_date(date, "month")) %>%
  group_by(state_abbr, date) %>%
  summarise(business_apps_total = mean(business_apps, na.rm = TRUE),
            .groups = "drop")

panel <- panel %>%
  left_join(outcome_total, by = c("state_abbr", "date"))

# ==============================================================================
# 5. Merge controls
# ==============================================================================

# Handle case where unemployment data is empty
if (nrow(unemployment) > 0 && "date" %in% names(unemployment)) {
  unemployment <- unemployment %>%
    mutate(date = floor_date(date, "month"))

  panel <- panel %>%
    left_join(unemployment, by = c("state_abbr", "date"))
} else {
  message("Warning: No unemployment data available, adding placeholder column")
  panel <- panel %>%
    mutate(unemployment_rate = NA_real_)
}

# ==============================================================================
# 6. Create log outcomes and additional variables
# ==============================================================================

panel <- panel %>%
  mutate(
    # Log outcome (add 1 to handle zeros)
    log_business_apps = log(business_apps + 1),
    log_business_apps_total = log(business_apps_total + 1),

    # Relative time to treatment (for event study)
    rel_time = if_else(
      treated_ever,
      as.numeric(interval(effective_date, date) %/% months(1)),
      NA_real_
    ),

    # COVID period indicator
    covid_period = date >= "2020-03-01" & date <= "2021-06-01"
  )

# ==============================================================================
# 7. Sample restrictions for main analysis
# ==============================================================================

# Main sample: 2023+ wave analysis
# Exclude California (will be analyzed separately)
# Exclude observations with missing outcomes

analysis_sample <- panel %>%
  filter(
    state_abbr != "CA",                    # Exclude CA (COVID confounded)
    !is.na(business_apps),                 # Non-missing outcome
    date >= "2018-01-01",                  # Start of pre-period
    date <= "2025-06-01"                   # End of sample
  )

message("\nMain analysis sample:")
message("  Observations: ", nrow(analysis_sample))
message("  States: ", n_distinct(analysis_sample$state_abbr))
message("  Treated states: ", n_distinct(analysis_sample$state_abbr[analysis_sample$treated_ever]))
message("  Time periods: ", n_distinct(analysis_sample$time_period))

# ==============================================================================
# 8. California sample for SCM
# ==============================================================================

ca_sample <- panel %>%
  filter(
    date >= "2015-01-01",
    date <= "2024-12-01",
    !is.na(business_apps)
  ) %>%
  mutate(
    # For CA SCM: treatment is CCPA effective Jan 2020
    treated_ca = state_abbr == "CA" & date >= "2020-01-01"
  )

message("\nCalifornia SCM sample:")
message("  Observations: ", nrow(ca_sample))

# ==============================================================================
# 9. Save analysis datasets
# ==============================================================================

write_csv(analysis_sample, file.path(dir_data, "analysis_sample.csv"))
write_csv(ca_sample, file.path(dir_data, "ca_sample.csv"))
write_csv(panel, file.path(dir_data, "full_panel.csv"))

message("\n", strrep("=", 60))
message("DATA CLEANING COMPLETE")
message(strrep("=", 60))

# Summary statistics
summary_stats <- analysis_sample %>%
  group_by(treated_ever) %>%
  summarise(
    n_obs = n(),
    n_states = n_distinct(state_abbr),
    mean_apps = mean(business_apps, na.rm = TRUE),
    sd_apps = sd(business_apps, na.rm = TRUE),
    mean_unemployment = mean(unemployment_rate, na.rm = TRUE)
  )

message("\nSummary by treatment status:")
print(summary_stats)
