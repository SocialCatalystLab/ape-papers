# ==============================================================================
# Paper 68: Broadband Internet and Moral Foundations in Local Governance
# 02_clean_data.R - Merge datasets and construct analysis variables
# ==============================================================================

source("code/00_packages.R")

# ==============================================================================
# 1. LOAD ALL DATA
# ==============================================================================
cat("=== Loading Data ===\n")

# LocalView (outcome)
localview <- arrow::read_parquet("data/localview_annual.parquet")
cat(sprintf("  LocalView: %d place-years\n", nrow(localview)))

# ACS Broadband (treatment)
broadband <- arrow::read_parquet("data/acs_broadband_place.parquet")
cat(sprintf("  ACS Broadband: %d observations\n", nrow(broadband)))

# ACS Demographics (controls)
demographics <- arrow::read_parquet("data/acs_demographics_2018.parquet")
cat(sprintf("  Demographics: %d places\n", nrow(demographics)))

# Place-county crosswalk
if (file.exists("data/place_county_crosswalk.csv")) {
  crosswalk <- read_csv("data/place_county_crosswalk.csv", show_col_types = FALSE)
  cat(sprintf("  Crosswalk: %d places\n", nrow(crosswalk)))
}

# ==============================================================================
# 2. MERGE LOCALVIEW WITH BROADBAND
# ==============================================================================
cat("\n=== Merging Datasets ===\n")

# First check st_fips format compatibility
cat("LocalView st_fips examples:\n")
print(head(localview$st_fips, 5))
cat("\nBroadband st_fips examples:\n")
print(head(broadband$st_fips, 5))

# Merge on st_fips and year
panel <- localview %>%
  inner_join(
    broadband %>% select(st_fips, year, total_hh, broadband_hh, broadband_rate),
    by = c("st_fips", "year")
  )

cat(sprintf("\n  After merge: %d place-years (%d places)\n",
            nrow(panel), n_distinct(panel$st_fips)))

# Add demographics
panel <- panel %>%
  left_join(
    demographics %>% select(st_fips, population, median_income,
                            pct_college, pct_white, median_age),
    by = "st_fips"
  )

# ==============================================================================
# 3. CONSTRUCT TREATMENT VARIABLES
# ==============================================================================
cat("\n=== Constructing Treatment Variables ===\n")

# Define treatment threshold
THRESHOLD <- 0.70

# Identify first year crossing threshold for each place
treatment_timing <- panel %>%
  filter(broadband_rate >= THRESHOLD) %>%
  group_by(st_fips) %>%
  summarise(
    treat_year = min(year),
    .groups = "drop"
  )

cat(sprintf("  Places crossing %.0f%% threshold: %d\n",
            THRESHOLD * 100, nrow(treatment_timing)))

# Distribution of treatment timing
cat("\n  Treatment timing distribution:\n")
print(table(treatment_timing$treat_year))

# Merge treatment timing
panel <- panel %>%
  left_join(treatment_timing, by = "st_fips") %>%
  mutate(
    # Treatment indicators
    treated = !is.na(treat_year),
    post = year >= treat_year,
    treat_post = treated & post,

    # Event time (relative to treatment)
    rel_year = ifelse(treated, year - treat_year, NA),

    # For C-S estimator: cohort indicator (0 for never-treated)
    cohort = ifelse(treated, treat_year, 0),

    # Alternative thresholds (for robustness)
    broadband_65 = broadband_rate >= 0.65,
    broadband_75 = broadband_rate >= 0.75
  )

# ==============================================================================
# 4. CREATE ANALYSIS SAMPLE
# ==============================================================================
cat("\n=== Creating Analysis Sample ===\n")

# Filter to analysis period (2013-2022 where broadband data exists)
analysis <- panel %>%
  filter(year >= 2013, year <= 2022) %>%
  # Require minimum meetings for reliability
  filter(n_meetings >= 2) %>%
  # Remove places with missing demographics
  filter(!is.na(population)) %>%
  # Create numeric ID for fixed effects
  mutate(
    place_id = as.numeric(factor(st_fips)),
    state_fips = substr(st_fips, 1, 2)
  )

# Sample statistics
cat(sprintf("  Analysis sample: %d place-years\n", nrow(analysis)))
cat(sprintf("  Unique places: %d\n", n_distinct(analysis$st_fips)))
cat(sprintf("  Treated places: %d (%.1f%%)\n",
            sum(analysis$treated & analysis$year == 2022),
            mean(analysis$treated[analysis$year == 2022]) * 100))
cat(sprintf("  Years: %d - %d\n", min(analysis$year), max(analysis$year)))

# ==============================================================================
# 5. COMPUTE UNIVERSALISM VS COMMUNAL INDEX
# ==============================================================================
cat("\n=== Computing Universalism vs Communal Index ===\n")

# Following Haidt's moral foundations theory:
# - Individualizing (Universalist): Care + Fairness
# - Binding (Communal): Loyalty + Authority + Sanctity

# Already computed in LocalView processing, but verify
analysis <- analysis %>%
  mutate(
    # Ensure consistent calculation
    individualizing = (care_p + fairness_p) / 2,
    binding = (loyalty_p + authority_p + sanctity_p) / 3,

    # Ratio (higher = more universalist/individualizing)
    univ_comm_ratio = individualizing / binding,

    # Log difference (more symmetric)
    log_univ_comm = log(individualizing + 0.001) - log(binding + 0.001),

    # Difference (simple)
    univ_comm_diff = individualizing - binding,

    # Standardized scores for easier interpretation
    individualizing_z = (individualizing - mean(individualizing, na.rm = TRUE)) /
                        sd(individualizing, na.rm = TRUE),
    binding_z = (binding - mean(binding, na.rm = TRUE)) /
                sd(binding, na.rm = TRUE)
  )

# Summary of moral foundations
cat("\n  Moral Foundation Summary:\n")
analysis %>%
  summarise(
    across(c(care_p, fairness_p, loyalty_p, authority_p, sanctity_p,
             individualizing, binding, univ_comm_ratio),
           list(mean = ~mean(., na.rm = TRUE),
                sd = ~sd(., na.rm = TRUE)),
           .names = "{.col}_{.fn}")
  ) %>%
  pivot_longer(everything()) %>%
  print(n = 30)

# ==============================================================================
# 6. ADD COUNTY-LEVEL DATA (for IV/heterogeneity)
# ==============================================================================
cat("\n=== Adding County-Level Data ===\n")

if (exists("crosswalk")) {
  analysis <- analysis %>%
    left_join(
      crosswalk %>% select(st_fips, county_fips, county_name),
      by = "st_fips"
    )

  cat(sprintf("  Places with county mapping: %d\n",
              sum(!is.na(analysis$county_fips))))
}

# ==============================================================================
# 7. BALANCED PANEL CHECK
# ==============================================================================
cat("\n=== Panel Structure ===\n")

# Check balance
panel_balance <- analysis %>%
  group_by(st_fips) %>%
  summarise(
    n_years = n(),
    min_year = min(year),
    max_year = max(year),
    years_with_data = paste(year, collapse = ","),
    .groups = "drop"
  )

cat(sprintf("  Mean years per place: %.1f\n", mean(panel_balance$n_years)))
cat(sprintf("  Min years: %d, Max years: %d\n",
            min(panel_balance$n_years), max(panel_balance$n_years)))

# Places with at least 5 years (for event study)
places_5plus <- panel_balance %>%
  filter(n_years >= 5) %>%
  pull(st_fips)

cat(sprintf("  Places with 5+ years: %d\n", length(places_5plus)))

# ==============================================================================
# 8. SAVE ANALYSIS DATA
# ==============================================================================
cat("\n=== Saving Analysis Data ===\n")

# Full analysis sample
write_csv(analysis, "data/analysis_panel.csv")
arrow::write_parquet(analysis, "data/analysis_panel.parquet")
cat(sprintf("  Saved: analysis_panel (%d rows)\n", nrow(analysis)))

# Treatment timing
write_csv(treatment_timing, "data/treatment_timing.csv")
cat(sprintf("  Saved: treatment_timing (%d places)\n", nrow(treatment_timing)))

# Panel balance info
write_csv(panel_balance, "data/panel_balance.csv")

# Create summary data for figures
summary_by_year <- analysis %>%
  group_by(year, treated) %>%
  summarise(
    n_places = n(),
    mean_broadband = mean(broadband_rate, na.rm = TRUE),
    mean_individualizing = mean(individualizing, na.rm = TRUE),
    mean_binding = mean(binding, na.rm = TRUE),
    mean_univ_comm = mean(univ_comm_ratio, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(summary_by_year, "data/summary_by_year.csv")

# Summary by cohort
summary_by_cohort <- analysis %>%
  filter(treated) %>%
  group_by(cohort, rel_year) %>%
  summarise(
    n_places = n(),
    mean_individualizing = mean(individualizing, na.rm = TRUE),
    mean_binding = mean(binding, na.rm = TRUE),
    mean_univ_comm = mean(univ_comm_ratio, na.rm = TRUE),
    .groups = "drop"
  )

write_csv(summary_by_cohort, "data/summary_by_cohort.csv")

# ==============================================================================
# 9. DESCRIPTIVE STATISTICS TABLE
# ==============================================================================
cat("\n=== Descriptive Statistics ===\n")

# Overall
cat("\n  Full Sample:\n")
analysis %>%
  summarise(
    `N (place-years)` = n(),
    `N (places)` = n_distinct(st_fips),
    `N (states)` = n_distinct(state_fips),
    `Broadband Rate` = sprintf("%.3f (%.3f)", mean(broadband_rate), sd(broadband_rate)),
    `Individualizing` = sprintf("%.3f (%.3f)", mean(individualizing), sd(individualizing)),
    `Binding` = sprintf("%.3f (%.3f)", mean(binding), sd(binding)),
    `Univ/Comm Ratio` = sprintf("%.3f (%.3f)", mean(univ_comm_ratio, na.rm = TRUE),
                                 sd(univ_comm_ratio, na.rm = TRUE))
  ) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "Value") %>%
  print()

# By treatment status
cat("\n  By Treatment Status:\n")
analysis %>%
  group_by(Treatment = ifelse(treated, "Treated", "Never Treated")) %>%
  summarise(
    `N places` = n_distinct(st_fips),
    `Broadband (mean)` = mean(broadband_rate),
    `Individualizing` = mean(individualizing),
    `Binding` = mean(binding),
    `Population (mean)` = mean(population, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  print()

cat("\n=== Data Cleaning Complete ===\n")
