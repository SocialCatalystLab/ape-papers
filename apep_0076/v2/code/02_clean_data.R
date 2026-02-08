# ============================================================================
# Paper 166: State EITC Generosity and Crime (Revision of apep_0076)
# Script: 02_clean_data.R - Data Verification and Summary Statistics
# ============================================================================
#
# NOTE: Most data cleaning now happens in 01_fetch_data.R
# This script verifies the analysis dataset and produces summary statistics
# ============================================================================

source("00_packages.R")

cat("Verifying and summarizing data for Paper 166...\n\n")

# ============================================================================
# PART 1: Load Analysis Dataset
# ============================================================================

cat("PART 1: Loading Analysis Dataset\n")
cat("---------------------------------\n")

analysis_file <- file.path(DATA_DIR, "analysis_eitc_crime.csv")
if (!file.exists(analysis_file)) {
  stop("ERROR: analysis_eitc_crime.csv not found. Run 01_fetch_data.R first.")
}

analysis_data <- read_csv(analysis_file, show_col_types = FALSE)

cat(sprintf("  Loaded: %d state-year observations\n", nrow(analysis_data)))
cat(sprintf("  Years: %d-%d\n", min(analysis_data$year), max(analysis_data$year)))
cat(sprintf("  States: %d\n", n_distinct(analysis_data$state_abbr)))

# ============================================================================
# PART 2: Verify Data Quality
# ============================================================================

cat("\nPART 2: Data Quality Verification\n")
cat("----------------------------------\n")

# Check for missing values
missing_check <- analysis_data %>%
  summarise(
    across(c(property_rate, burglary_rate, larceny_rate, mvt_rate,
             violent_rate, murder_rate, population, has_eitc, eitc_generosity),
           ~sum(is.na(.)))
  )

cat("\nMissing values by variable:\n")
print(t(missing_check))

# Check for reasonable values
cat("\nValue range checks:\n")
cat(sprintf("  Property rate range: %.1f to %.1f\n",
            min(analysis_data$property_rate), max(analysis_data$property_rate)))
cat(sprintf("  Violent rate range: %.1f to %.1f\n",
            min(analysis_data$violent_rate), max(analysis_data$violent_rate)))
cat(sprintf("  Population range: %s to %s\n",
            format(min(analysis_data$population), big.mark = ","),
            format(max(analysis_data$population), big.mark = ",")))
cat(sprintf("  EITC generosity range: %.1f%% to %.1f%%\n",
            min(analysis_data$eitc_generosity), max(analysis_data$eitc_generosity)))

# ============================================================================
# PART 3: Treatment Structure Analysis
# ============================================================================

cat("\nPART 3: Treatment Structure Analysis\n")
cat("-------------------------------------\n")

# Treatment summary by year
cat("\nTreatment status by year (selected years):\n")
treatment_summary <- analysis_data %>%
  group_by(year) %>%
  summarise(
    n_states = n(),
    n_treated = sum(treated),
    pct_treated = round(mean(treated) * 100, 1),
    mean_generosity = round(mean(eitc_generosity[eitc_generosity > 0], na.rm = TRUE), 1),
    .groups = "drop"
  )
print(treatment_summary %>% filter(year %in% c(1987, 1990, 1995, 2000, 2005, 2010, 2015, 2019)))

# Cohort structure for CS estimator
cat("\nAdoption Cohorts:\n")
cohort_info <- analysis_data %>%
  filter(year == 2019) %>%
  group_by(cohort) %>%
  summarise(
    n_states = n(),
    states = paste(sort(state_abbr), collapse = ", "),
    .groups = "drop"
  ) %>%
  arrange(cohort)

for (i in 1:nrow(cohort_info)) {
  if (cohort_info$cohort[i] == 0) {
    cat(sprintf("  Never-treated: %d states\n", cohort_info$n_states[i]))
  } else {
    cat(sprintf("  Cohort %d: %d states (%s)\n",
                cohort_info$cohort[i], cohort_info$n_states[i],
                substr(cohort_info$states[i], 1, 50)))
  }
}

# Pre-treatment periods for early adopters
cat("\nPre-treatment periods for early adopters (1987-1999):\n")
early_adopters <- analysis_data %>%
  filter(!is.na(eitc_adopted), eitc_adopted <= 1999) %>%
  select(state_abbr, eitc_adopted) %>%
  distinct() %>%
  mutate(pre_periods = eitc_adopted - 1987) %>%
  arrange(eitc_adopted)

print(early_adopters)

# ============================================================================
# PART 4: Descriptive Statistics
# ============================================================================

cat("\nPART 4: Descriptive Statistics\n")
cat("-------------------------------\n")

# Overall summary statistics
cat("\nOutcome Variables (Full Sample):\n")
outcome_stats <- analysis_data %>%
  summarise(
    across(c(property_rate, burglary_rate, larceny_rate, mvt_rate,
             violent_rate, murder_rate),
           list(mean = ~mean(., na.rm = TRUE),
                sd = ~sd(., na.rm = TRUE),
                min = ~min(., na.rm = TRUE),
                max = ~max(., na.rm = TRUE)),
           .names = "{.col}_{.fn}")
  )

# Format for display
stats_df <- tibble(
  Variable = c("Property Crime Rate", "Burglary Rate", "Larceny Rate",
               "Motor Vehicle Theft Rate", "Violent Crime Rate", "Murder Rate"),
  Mean = c(outcome_stats$property_rate_mean, outcome_stats$burglary_rate_mean,
           outcome_stats$larceny_rate_mean, outcome_stats$mvt_rate_mean,
           outcome_stats$violent_rate_mean, outcome_stats$murder_rate_mean),
  SD = c(outcome_stats$property_rate_sd, outcome_stats$burglary_rate_sd,
         outcome_stats$larceny_rate_sd, outcome_stats$mvt_rate_sd,
         outcome_stats$violent_rate_sd, outcome_stats$murder_rate_sd),
  Min = c(outcome_stats$property_rate_min, outcome_stats$burglary_rate_min,
          outcome_stats$larceny_rate_min, outcome_stats$mvt_rate_min,
          outcome_stats$violent_rate_min, outcome_stats$murder_rate_min),
  Max = c(outcome_stats$property_rate_max, outcome_stats$burglary_rate_max,
          outcome_stats$larceny_rate_max, outcome_stats$mvt_rate_max,
          outcome_stats$violent_rate_max, outcome_stats$murder_rate_max)
) %>%
  mutate(across(c(Mean, SD, Min, Max), ~round(., 1)))

print(stats_df)

# By treatment status
cat("\nMean Crime Rates by Treatment Status:\n")
by_treatment <- analysis_data %>%
  group_by(treated) %>%
  summarise(
    n_obs = n(),
    property = round(mean(property_rate), 1),
    burglary = round(mean(burglary_rate), 1),
    larceny = round(mean(larceny_rate), 1),
    mvt = round(mean(mvt_rate), 1),
    violent = round(mean(violent_rate), 1),
    murder = round(mean(murder_rate), 2),
    .groups = "drop"
  ) %>%
  mutate(Treatment = if_else(treated == 1, "Treated", "Control")) %>%
  select(Treatment, n_obs, property, burglary, larceny, mvt, violent, murder)

print(by_treatment)

# ============================================================================
# PART 5: Time Trends
# ============================================================================

cat("\nPART 5: Time Trends\n")
cat("--------------------\n")

# Crime trends over time
crime_trends <- analysis_data %>%
  group_by(year) %>%
  summarise(
    property = mean(property_rate),
    violent = mean(violent_rate),
    .groups = "drop"
  )

cat("\nMean crime rates by year (sample):\n")
print(crime_trends %>%
        filter(year %in% c(1987, 1990, 1995, 2000, 2005, 2010, 2015, 2019)) %>%
        mutate(across(c(property, violent), ~round(., 1))))

# ============================================================================
# PART 6: Save Summary Statistics
# ============================================================================

cat("\nPART 6: Saving Summary Statistics\n")
cat("----------------------------------\n")

# Save detailed summary for paper
summary_stats <- analysis_data %>%
  select(state_abbr, year, treated, eitc_generosity, eitc_adopted, cohort,
         property_rate, burglary_rate, larceny_rate, mvt_rate,
         violent_rate, murder_rate, population) %>%
  mutate(across(where(is.numeric) & !c(year, eitc_adopted, cohort), ~round(., 2)))

write_csv(summary_stats, file.path(DATA_DIR, "summary_stats.csv"))

# Save treatment summary
write_csv(treatment_summary, file.path(DATA_DIR, "treatment_summary.csv"))

cat("\nFiles saved:\n")
cat(sprintf("  - %s/summary_stats.csv\n", DATA_DIR))
cat(sprintf("  - %s/treatment_summary.csv\n", DATA_DIR))

# ============================================================================
# PART 7: Final Summary
# ============================================================================

cat("\n============================================\n")
cat("Data Verification Complete\n")
cat("============================================\n\n")

cat("Panel Structure:\n")
cat(sprintf("  Sample period: %d-%d (%d years)\n",
            min(analysis_data$year), max(analysis_data$year),
            n_distinct(analysis_data$year)))
cat(sprintf("  States: %d (including DC)\n", n_distinct(analysis_data$state_abbr)))
cat(sprintf("  Total observations: %d\n", nrow(analysis_data)))

cat("\nTreatment Structure:\n")
cat(sprintf("  Adoption cohorts: %d (including never-treated)\n", n_distinct(analysis_data$cohort)))
cat(sprintf("  States with EITC by 2019: %d\n",
            sum(analysis_data$treated[analysis_data$year == 2019])))
cat(sprintf("  Never-treated states: %d\n",
            sum(analysis_data$treated[analysis_data$year == 2019] == 0)))

cat("\nKey Improvements (vs. Parent Paper):\n")
cat("  - Extended panel gives early adopters pre-treatment observations\n")
cat("  - Time-varying EITC generosity captures rate changes\n")
cat("  - Ready for CS estimator with proper cohort structure\n")

cat("\nRun 03_main_analysis.R next.\n")
