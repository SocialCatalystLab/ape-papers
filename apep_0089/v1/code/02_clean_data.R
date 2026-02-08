# ==============================================================================
# 02_clean_data.R
# Clean and prepare data for analysis
# Paper 111: NP Full Practice Authority and Physician Employment
# ==============================================================================

source("00_packages.R")

# Load raw data
analysis_data <- read_csv(file.path(data_dir, "analysis_data.csv"))
fpa_dates <- read_csv(file.path(data_dir, "fpa_dates.csv"))

cat("Loaded", nrow(analysis_data), "observations\n")

# ==============================================================================
# PART 1: Data Quality Checks
# ==============================================================================

# Check for missing values
cat("\n=== Missing Values ===\n")
analysis_data %>%
  summarise(across(everything(), ~sum(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "n_missing") %>%
  filter(n_missing > 0) %>%
  print()

# Check panel balance
cat("\n=== Panel Balance ===\n")
panel_balance <- analysis_data %>%
  count(state_abbr) %>%
  summarise(
    min_years = min(n),
    max_years = max(n),
    mean_years = mean(n)
  )
print(panel_balance)

# States with incomplete panels
incomplete <- analysis_data %>%
  count(state_abbr) %>%
  filter(n < max(n))

if (nrow(incomplete) > 0) {
  cat("\nStates with incomplete panels:\n")
  print(incomplete)
}

# ==============================================================================
# PART 2: Create Analysis Variables
# ==============================================================================

analysis_clean <- analysis_data %>%
  # Remove DC if needed (small sample issues)
  # filter(state_abbr != "DC") %>%

  # Create cohort variable (year of first treatment)
  mutate(
    # Cohort = 0 for never-treated, else year of FPA adoption
    cohort = ifelse(fpa_year == 0, 0, fpa_year),

    # Event time (years relative to treatment)
    event_time = ifelse(fpa_year == 0, NA_integer_, year - fpa_year),

    # Pre/post indicator
    post = year >= fpa_year & fpa_year > 0,

    # Ever-treated indicator
    ever_treated = fpa_year > 0,

    # Log transformations
    log_emp = log(employment + 1),
    log_estab = log(establishments + 1),
    log_wage = log(avg_weekly_wage),

    # Growth rates
    emp_growth = (employment - lag(employment)) / lag(employment),
    .by = state_fips
  )

# ==============================================================================
# PART 3: Construct Control Variables
# ==============================================================================

# Baseline characteristics (pre-treatment period means)
baseline_chars <- analysis_clean %>%
  filter(year <= 2015) %>%  # Use 2014-2015 as baseline

  group_by(state_fips, state_abbr, state_name, fpa_year, ever_treated) %>%
  summarise(
    baseline_emp = mean(employment, na.rm = TRUE),
    baseline_estab = mean(establishments, na.rm = TRUE),
    baseline_wage = mean(avg_weekly_wage, na.rm = TRUE),
    baseline_healthcare_emp = mean(healthcare_emp, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    baseline_physician_intensity = baseline_emp / baseline_healthcare_emp
  )

# Merge baseline characteristics
analysis_clean <- analysis_clean %>%
  left_join(
    baseline_chars %>% select(state_fips, starts_with("baseline_")),
    by = "state_fips"
  )

# ==============================================================================
# PART 4: Identify Treatment Cohorts
# ==============================================================================

cat("\n=== Treatment Cohorts ===\n")
cohort_summary <- analysis_clean %>%
  filter(fpa_year > 0) %>%
  distinct(state_abbr, state_name, fpa_year) %>%
  arrange(fpa_year)

print(cohort_summary, n = 30)

# Cohort sizes
cat("\n=== Cohort Sizes ===\n")
analysis_clean %>%
  filter(fpa_year > 0) %>%
  distinct(state_abbr, fpa_year) %>%
  count(fpa_year, name = "n_states") %>%
  print(n = 20)

# ==============================================================================
# PART 5: Sample Restrictions
# ==============================================================================

# For main analysis: Use balanced panel 2000-2023
# Exclude 2024 (recent, may be incomplete)
# Exclude pre-2000 adopters from "clean" DiD sample

analysis_main <- analysis_clean %>%
  filter(year >= 2014, year <= 2024) %>%
  # Keep states with complete panels (2014-2024 = 11 years)
  group_by(state_fips) %>%
  filter(n() >= 10) %>%  # Need at least 10 years
  ungroup()

cat("\n=== Main Analysis Sample ===\n")
cat("States:", n_distinct(analysis_main$state_fips), "\n")
cat("Years:", min(analysis_main$year), "-", max(analysis_main$year), "\n")
cat("Observations:", nrow(analysis_main), "\n")

# For DiD: Create sample excluding states treated before 2014
# With data starting in 2014, we need post-2014 adopters for pre-treatment periods
# States treated before 2014 are "always-treated" in our data window
analysis_did <- analysis_main %>%
  filter(fpa_year == 0 | fpa_year >= 2015)  # Keep never-treated + post-2014 adopters

cat("\n=== DiD Sample (excluding pre-2015 adopters) ===\n")
cat("States:", n_distinct(analysis_did$state_fips), "\n")
cat("Treated states:", n_distinct(analysis_did$state_fips[analysis_did$fpa_year > 0]), "\n")
cat("Control states:", n_distinct(analysis_did$state_fips[analysis_did$fpa_year == 0]), "\n")

# ==============================================================================
# PART 6: Summary Statistics
# ==============================================================================

cat("\n=== Summary Statistics by Treatment Status ===\n")

summary_stats <- analysis_main %>%
  group_by(ever_treated) %>%
  summarise(
    n_states = n_distinct(state_fips),
    n_obs = n(),
    mean_emp = mean(employment, na.rm = TRUE),
    sd_emp = sd(employment, na.rm = TRUE),
    mean_estab = mean(establishments, na.rm = TRUE),
    mean_wage = mean(avg_weekly_wage, na.rm = TRUE),
    mean_healthcare = mean(healthcare_emp, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    group = ifelse(ever_treated, "FPA States", "Non-FPA States")
  )

print(summary_stats)

# ==============================================================================
# PART 7: Save Cleaned Data
# ==============================================================================

write_csv(analysis_main, file.path(data_dir, "analysis_main.csv"))
write_csv(analysis_did, file.path(data_dir, "analysis_did.csv"))
write_csv(baseline_chars, file.path(data_dir, "baseline_characteristics.csv"))

cat("\n=== Data Saved ===\n")
cat("Main analysis: data/analysis_main.csv (", nrow(analysis_main), " obs)\n")
cat("DiD sample: data/analysis_did.csv (", nrow(analysis_did), " obs)\n")
cat("Baseline chars: data/baseline_characteristics.csv\n")

# Final data structure
cat("\n=== Final Data Structure ===\n")
str(analysis_main %>% select(state_fips, state_abbr, year, fpa_year, cohort, ever_treated, post, employment, log_emp))
