# ============================================================================
# Paper 105: State EITC Generosity and Property Crime
# Script: 02_clean_data.R - Data Cleaning and Merging
# ============================================================================

source("00_packages.R")

cat("Cleaning and merging data for Paper 105...\n\n")

# ============================================================================
# PART 1: Load EITC Policy Data
# ============================================================================

cat("Loading EITC policy data...\n")

eitc_panel <- read_csv(file.path(DATA_DIR, "eitc_state_year_panel.csv"), show_col_types = FALSE)
eitc_policy <- read_csv(file.path(DATA_DIR, "eitc_policy.csv"), show_col_types = FALSE)

cat(sprintf("  EITC panel: %d state-years\n", nrow(eitc_panel)))

# ============================================================================
# PART 2: Load and Clean Crime Data
# ============================================================================

cat("\nLoading CORGIS state crime data...\n")

crime_raw <- read_csv(file.path(DATA_DIR, "state_crime_corgis.csv"), show_col_types = FALSE)

# Clean column names
crime_clean <- crime_raw %>%
  rename(
    state_name = State,
    year = Year,
    population = `Data.Population`,
    property_rate = `Data.Rates.Property.All`,
    burglary_rate = `Data.Rates.Property.Burglary`,
    larceny_rate = `Data.Rates.Property.Larceny`,
    mvt_rate = `Data.Rates.Property.Motor`,
    violent_rate = `Data.Rates.Violent.All`,
    assault_rate = `Data.Rates.Violent.Assault`,
    murder_rate = `Data.Rates.Violent.Murder`,
    rape_rate = `Data.Rates.Violent.Rape`,
    robbery_rate = `Data.Rates.Violent.Robbery`,
    property_total = `Data.Totals.Property.All`,
    burglary_total = `Data.Totals.Property.Burglary`,
    larceny_total = `Data.Totals.Property.Larceny`,
    mvt_total = `Data.Totals.Property.Motor`,
    violent_total = `Data.Totals.Violent.All`,
    assault_total = `Data.Totals.Violent.Assault`,
    murder_total = `Data.Totals.Violent.Murder`,
    rape_total = `Data.Totals.Violent.Rape`,
    robbery_total = `Data.Totals.Violent.Robbery`
  )

# Create state abbreviation mapping
state_abbr_map <- tibble(
  state_name = c(
    "Alabama", "Alaska", "Arizona", "Arkansas", "California",
    "Colorado", "Connecticut", "Delaware", "Florida", "Georgia",
    "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa",
    "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland",
    "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri",
    "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey",
    "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio",
    "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina",
    "South Dakota", "Tennessee", "Texas", "Utah", "Vermont",
    "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming",
    "District of Columbia"
  ),
  state_abbr = c(
    "AL", "AK", "AZ", "AR", "CA",
    "CO", "CT", "DE", "FL", "GA",
    "HI", "ID", "IL", "IN", "IA",
    "KS", "KY", "LA", "ME", "MD",
    "MA", "MI", "MN", "MS", "MO",
    "MT", "NE", "NV", "NH", "NJ",
    "NM", "NY", "NC", "ND", "OH",
    "OK", "OR", "PA", "RI", "SC",
    "SD", "TN", "TX", "UT", "VT",
    "VA", "WA", "WV", "WI", "WY",
    "DC"
  )
)

# Add state abbreviation
crime_clean <- crime_clean %>%
  left_join(state_abbr_map, by = "state_name")

cat(sprintf("  Crime data: %d state-years (1960-2019)\n", nrow(crime_clean)))

# ============================================================================
# PART 3: Merge EITC and Crime Data
# ============================================================================

cat("\nMerging EITC and crime data...\n")

# Filter to analysis period (1999-2019)
analysis_data <- eitc_panel %>%
  left_join(
    crime_clean %>% select(state_abbr, year, population,
                           property_rate, burglary_rate, larceny_rate, mvt_rate,
                           violent_rate, murder_rate),
    by = c("state_abbr", "year")
  ) %>%
  filter(!is.na(property_rate))

# Calculate log outcomes
analysis_data <- analysis_data %>%
  mutate(
    log_property_rate = log(property_rate + 1),
    log_burglary_rate = log(burglary_rate + 1),
    log_larceny_rate = log(larceny_rate + 1),
    log_mvt_rate = log(mvt_rate + 1),
    log_violent_rate = log(violent_rate + 1),
    log_population = log(population)
  )

cat(sprintf("  Merged analysis data: %d state-years\n", nrow(analysis_data)))

# ============================================================================
# PART 4: Create Treatment Variables
# ============================================================================

cat("\nCreating treatment variables...\n")

# For states with early adoption (before 1999), they are "always treated"
# For CS estimator, we need first_treat to be within the sample period
analysis_data <- analysis_data %>%
  mutate(
    # Create cohort variable for CS estimator
    # Early adopters (before 1999) get first_treat = 0 (always treated)
    # Never treated states get first_treat = Inf
    cohort = case_when(
      is.na(eitc_adopted) ~ 0,  # Never treated - will be comparison group
      eitc_adopted < 1999 ~ 1999,  # Early adopters - treat as 1999 cohort
      TRUE ~ eitc_adopted
    ),
    # Binary treatment - currently treated
    treated = if_else(has_eitc == 1, 1L, 0L),
    # Time since treatment (for event study)
    time_since_treat = if_else(
      !is.na(eitc_adopted),
      year - eitc_adopted,
      NA_integer_
    )
  )

# Summary of treatment status
cat("\nTreatment summary by year:\n")
treatment_summary <- analysis_data %>%
  group_by(year) %>%
  summarise(
    n_states = n(),
    n_treated = sum(treated),
    pct_treated = mean(treated) * 100,
    mean_eitc_generosity = mean(eitc_generosity),
    .groups = "drop"
  )
print(treatment_summary)

# ============================================================================
# PART 5: Descriptive Statistics
# ============================================================================

cat("\n\nDescriptive statistics:\n")

# Overall summary
overall_stats <- analysis_data %>%
  summarise(
    across(c(property_rate, burglary_rate, larceny_rate, mvt_rate, violent_rate),
           list(mean = mean, sd = sd, min = min, max = max),
           .names = "{.col}_{.fn}")
  )

cat("\nOutcome variable summary:\n")
print(as.data.frame(t(overall_stats)))

# By treatment status
by_treatment <- analysis_data %>%
  group_by(treated) %>%
  summarise(
    n_obs = n(),
    mean_property = mean(property_rate),
    mean_burglary = mean(burglary_rate),
    mean_larceny = mean(larceny_rate),
    mean_mvt = mean(mvt_rate),
    mean_violent = mean(violent_rate),
    .groups = "drop"
  )

cat("\nMean crime rates by treatment status:\n")
print(by_treatment)

# ============================================================================
# PART 6: Save Analysis Dataset
# ============================================================================

cat("\nSaving analysis dataset...\n")

write_csv(analysis_data, file.path(DATA_DIR, "analysis_eitc_crime.csv"))

# Also save a summary for the paper
summary_stats <- analysis_data %>%
  select(state_abbr, year, treated, eitc_generosity,
         property_rate, burglary_rate, larceny_rate, mvt_rate,
         violent_rate, population) %>%
  mutate(across(where(is.numeric), ~ round(., 2)))

write_csv(summary_stats, file.path(DATA_DIR, "summary_stats.csv"))

cat(sprintf("\nFinal analysis dataset: %d state-year observations\n", nrow(analysis_data)))
cat(sprintf("  Treatment years: 1999-2019\n"))
cat(sprintf("  States with EITC: %d (by 2019)\n",
            n_distinct(analysis_data$state_abbr[analysis_data$treated == 1 & analysis_data$year == 2019])))
cat(sprintf("  Never-treated states: %d\n",
            n_distinct(analysis_data$state_abbr[analysis_data$treated == 0 & analysis_data$year == 2019])))

cat("\n============================================\n")
cat("Data cleaning complete!\n")
cat("============================================\n")
