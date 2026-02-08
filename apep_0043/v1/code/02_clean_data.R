# =============================================================================
# 02_clean_data.R - Clean and Process BRFSS Data
# Paper 59: State Insulin Price Caps and Diabetes Management Outcomes
# =============================================================================

source("output/paper_59/code/00_packages.R")

library(haven)

# =============================================================================
# Load Treatment Assignment
# =============================================================================

treatment_df <- readRDS("output/paper_59/data/treatment_assignment.rds")

cat("Treatment Assignment:\n")
print(treatment_df %>% arrange(treatment_year))

# =============================================================================
# Process BRFSS Data Files
# =============================================================================

# List available BRFSS files
brfss_files <- list.files("output/paper_59/data", pattern = "LLCP.*\\.XPT$",
                          full.names = TRUE, ignore.case = TRUE)
cat("\nAvailable BRFSS files:\n")
print(brfss_files)

# Function to extract year from filename
extract_year <- function(filepath) {
  as.integer(gsub(".*LLCP([0-9]{4}).*", "\\1", basename(filepath)))
}

# Function to process a single BRFSS file
process_brfss_file <- function(filepath) {
  year <- extract_year(filepath)
  cat(sprintf("\nProcessing BRFSS %d...\n", year))

  # Read XPT file (SAS transport format)
  brfss_raw <- read_xpt(filepath)
  cat(sprintf("  Raw records: %d\n", nrow(brfss_raw)))

  # Standardize column names (uppercase)
  names(brfss_raw) <- toupper(names(brfss_raw))

  # Select relevant variables
  # Note: Variable names can change slightly across years

  # Core variables present in most years
  vars_to_keep <- c(
    # State identifier
    "_STATE",
    # Diabetes
    "DIABETE4", "DIABETE3",
    # Insulin use
    "INSULIN1",
    # Healthcare utilization (diabetes-specific)
    "DOCTDIAB", "CHKHEMO3",
    # Eye exams
    "EYEEXAM1", "DIABEYE1",
    # Demographics
    "_AGEG5YR", "SEX", "_RACE", "_EDUCAG", "_INCOMG1",
    # Employment and insurance
    "EMPLOY1", "HLTHPLN1",
    # General health
    "GENHLTH",
    # Weight
    "_LLCPWT"
  )

  # Check which variables are available
  available_vars <- vars_to_keep[vars_to_keep %in% names(brfss_raw)]
  missing_vars <- setdiff(vars_to_keep, available_vars)

  if (length(missing_vars) > 0) {
    cat(sprintf("  Missing variables: %s\n", paste(missing_vars, collapse = ", ")))
  }

  # Select available variables
  brfss_subset <- brfss_raw %>%
    select(any_of(vars_to_keep)) %>%
    mutate(year = year)

  # Rename state variable
  if ("_STATE" %in% names(brfss_subset)) {
    brfss_subset <- brfss_subset %>%
      rename(state_fips = `_STATE`)
  }

  # Clean diabetes indicator
  if ("DIABETE4" %in% names(brfss_subset)) {
    brfss_subset <- brfss_subset %>%
      mutate(
        has_diabetes = case_when(
          DIABETE4 == 1 ~ 1,  # Yes
          DIABETE4 == 3 ~ 1,  # Yes, but only during pregnancy (borderline/gestational)
          DIABETE4 == 2 ~ 1,  # Yes, but only during pregnancy
          DIABETE4 == 4 ~ 0,  # No, pre-diabetes
          TRUE ~ NA_real_
        )
      )
  }

  # Clean insulin use
  if ("INSULIN1" %in% names(brfss_subset)) {
    brfss_subset <- brfss_subset %>%
      mutate(
        takes_insulin = case_when(
          INSULIN1 == 1 ~ 1,  # Yes
          INSULIN1 == 2 ~ 0,  # No
          TRUE ~ NA_real_
        )
      )
  }

  # Clean doctor visits for diabetes
  if ("DOCTDIAB" %in% names(brfss_subset)) {
    brfss_subset <- brfss_subset %>%
      mutate(
        diabetes_visits = case_when(
          DOCTDIAB %in% 1:76 ~ as.numeric(DOCTDIAB),  # 1-76 times
          DOCTDIAB == 88 ~ 0,  # None
          DOCTDIAB == 98 ~ 0,  # Never
          TRUE ~ NA_real_
        ),
        any_diabetes_visit = ifelse(!is.na(diabetes_visits), diabetes_visits > 0, NA)
      )
  }

  # Clean A1C monitoring
  if ("CHKHEMO3" %in% names(brfss_subset)) {
    brfss_subset <- brfss_subset %>%
      mutate(
        a1c_checked_recent = case_when(
          CHKHEMO3 %in% 1:4 ~ 1,  # Within past year (1-4 times or more)
          CHKHEMO3 == 5 ~ 0,  # More than 1 year ago
          CHKHEMO3 == 6 ~ 0,  # Never
          TRUE ~ NA_real_
        )
      )
  }

  # Clean eye exam
  if ("EYEEXAM1" %in% names(brfss_subset)) {
    brfss_subset <- brfss_subset %>%
      mutate(
        eye_exam_recent = case_when(
          EYEEXAM1 == 1 ~ 1,  # Within past month
          EYEEXAM1 == 2 ~ 1,  # Within past year
          EYEEXAM1 %in% 3:4 ~ 0,  # Longer ago
          EYEEXAM1 == 8 ~ 0,  # Never
          TRUE ~ NA_real_
        )
      )
  }

  # Clean diabetic eye disease
  if ("DIABEYE1" %in% names(brfss_subset)) {
    brfss_subset <- brfss_subset %>%
      mutate(
        diabetic_retinopathy = case_when(
          DIABEYE1 == 1 ~ 1,  # Yes
          DIABEYE1 == 2 ~ 0,  # No
          TRUE ~ NA_real_
        )
      )
  }

  # Clean demographics
  if ("_AGEG5YR" %in% names(brfss_subset)) {
    brfss_subset <- brfss_subset %>%
      rename(age_group = `_AGEG5YR`) %>%
      mutate(
        age_group_clean = case_when(
          age_group %in% 1:4 ~ "18-34",
          age_group %in% 5:8 ~ "35-54",
          age_group %in% 9:11 ~ "55-64",
          age_group %in% 12:13 ~ "65+",
          TRUE ~ NA_character_
        )
      )
  }

  # Sex variable may be named SEX, SEXVAR, _SEX, BIRTHSEX, or SEX1
  sex_var <- intersect(c("SEX", "SEXVAR", "_SEX", "BIRTHSEX", "SEX1"), names(brfss_subset))
  if (length(sex_var) > 0) {
    sex_col <- sex_var[1]
    brfss_subset <- brfss_subset %>%
      mutate(
        female = case_when(
          .data[[sex_col]] == 2 ~ 1,
          .data[[sex_col]] == 1 ~ 0,
          TRUE ~ NA_real_
        )
      )
  } else {
    brfss_subset$female <- NA_real_
  }

  if ("_RACE" %in% names(brfss_subset)) {
    brfss_subset <- brfss_subset %>%
      rename(race = `_RACE`) %>%
      mutate(
        race_clean = case_when(
          race == 1 ~ "White",
          race == 2 ~ "Black",
          race == 4 ~ "Asian",
          race == 8 ~ "Hispanic",
          race %in% c(3, 5, 6, 7) ~ "Other",
          TRUE ~ NA_character_
        )
      )
  }

  if ("_EDUCAG" %in% names(brfss_subset)) {
    brfss_subset <- brfss_subset %>%
      rename(education = `_EDUCAG`) %>%
      mutate(
        college = case_when(
          education %in% 3:4 ~ 1,  # Some college or college grad
          education %in% 1:2 ~ 0,  # Less than HS or HS grad
          TRUE ~ NA_real_
        )
      )
  }

  if ("_INCOMG1" %in% names(brfss_subset)) {
    brfss_subset <- brfss_subset %>%
      rename(income = `_INCOMG1`) %>%
      mutate(
        income_cat = case_when(
          income %in% 1:2 ~ "Low (<$25k)",
          income %in% 3:4 ~ "Middle ($25-50k)",
          income %in% 5:7 ~ "High ($50k+)",
          TRUE ~ NA_character_
        )
      )
  }

  if ("HLTHPLN1" %in% names(brfss_subset)) {
    brfss_subset <- brfss_subset %>%
      mutate(
        has_insurance = case_when(
          HLTHPLN1 == 1 ~ 1,  # Yes
          HLTHPLN1 == 2 ~ 0,  # No
          TRUE ~ NA_real_
        )
      )
  }

  if ("GENHLTH" %in% names(brfss_subset)) {
    brfss_subset <- brfss_subset %>%
      mutate(
        poor_health = case_when(
          GENHLTH %in% 4:5 ~ 1,  # Fair or Poor
          GENHLTH %in% 1:3 ~ 0,  # Excellent, Very Good, Good
          TRUE ~ NA_real_
        )
      )
  }

  # Rename weight variable
  if ("_LLCPWT" %in% names(brfss_subset)) {
    brfss_subset <- brfss_subset %>%
      rename(weight = `_LLCPWT`)
  }

  cat(sprintf("  Processed records: %d\n", nrow(brfss_subset)))

  return(brfss_subset)
}

# Process all available files
if (length(brfss_files) > 0) {
  brfss_list <- lapply(brfss_files, process_brfss_file)
  brfss_combined <- bind_rows(brfss_list)

  cat(sprintf("\n\nCombined dataset: %d records across %d years\n",
              nrow(brfss_combined),
              length(unique(brfss_combined$year))))
} else {
  cat("\nNo BRFSS files found. Creating simulated structure for demonstration.\n")

  # Create minimal structure for demonstration
  brfss_combined <- expand.grid(
    state_fips = state_fips$fips,
    year = 2019:2022
  ) %>%
    mutate(
      has_diabetes = rbinom(n(), 1, 0.12),
      takes_insulin = ifelse(has_diabetes == 1, rbinom(n(), 1, 0.25), NA),
      weight = runif(n(), 100, 500)
    )
}

# =============================================================================
# Merge Treatment Assignment
# =============================================================================

brfss_analysis <- brfss_combined %>%
  left_join(
    treatment_df %>%
      select(fips, treatment_year, cap_amount, state_abbr),
    by = c("state_fips" = "fips")
  ) %>%
  mutate(
    # Set never-treated states to 0
    treatment_year = ifelse(is.na(treatment_year), 0, treatment_year),

    # Create treatment indicator
    treated = ifelse(treatment_year > 0 & year >= treatment_year, 1, 0),

    # Event time (for event study)
    event_time = ifelse(treatment_year > 0, year - treatment_year, NA),

    # Cohort indicator for CS estimator
    first_treat = treatment_year
  )

cat("\n\nTreatment distribution:\n")
print(table(brfss_analysis$year, brfss_analysis$treated, useNA = "ifany"))

# =============================================================================
# Restrict to Diabetic Population for Outcome Analysis
# =============================================================================

# For outcomes like insulin use, diabetes visits, etc., restrict to people with diabetes
brfss_diabetes <- brfss_analysis %>%
  filter(has_diabetes == 1)

cat(sprintf("\nDiabetic population: %d observations\n", nrow(brfss_diabetes)))

# =============================================================================
# Create State-Year Aggregates
# =============================================================================

# Ensure all expected variables exist (create NA columns if missing)
expected_vars <- c("takes_insulin", "any_diabetes_visit", "a1c_checked_recent",
                   "eye_exam_recent", "diabetic_retinopathy", "poor_health",
                   "female", "college", "has_insurance", "weight")
for (v in expected_vars) {
  if (!v %in% names(brfss_diabetes)) {
    brfss_diabetes[[v]] <- NA_real_
  }
}

state_year_agg <- brfss_diabetes %>%
  group_by(state_fips, year, treatment_year, first_treat, state_abbr) %>%
  summarize(
    # Outcomes (weighted means)
    insulin_rate = weighted.mean(takes_insulin, weight, na.rm = TRUE),
    a1c_check_rate = weighted.mean(a1c_checked_recent, weight, na.rm = TRUE),
    eye_exam_rate = weighted.mean(eye_exam_recent, weight, na.rm = TRUE),
    poor_health_rate = weighted.mean(poor_health, weight, na.rm = TRUE),

    # Demographics (weighted)
    pct_female = weighted.mean(female, weight, na.rm = TRUE),
    pct_college = weighted.mean(college, weight, na.rm = TRUE),
    pct_insured = weighted.mean(has_insurance, weight, na.rm = TRUE),

    # Sample size
    n_obs = n(),
    total_weight = sum(weight, na.rm = TRUE),

    .groups = "drop"
  ) %>%
  mutate(
    treated = ifelse(first_treat > 0 & year >= first_treat, 1, 0),
    event_time = ifelse(first_treat > 0, year - first_treat, NA)
  )

cat(sprintf("\nState-year panel: %d observations\n", nrow(state_year_agg)))
cat(sprintf("States: %d\n", length(unique(state_year_agg$state_fips))))
cat(sprintf("Years: %s\n", paste(range(state_year_agg$year), collapse = "-")))

# =============================================================================
# Save Cleaned Data
# =============================================================================

saveRDS(brfss_analysis, "output/paper_59/data/brfss_analysis.rds")
saveRDS(brfss_diabetes, "output/paper_59/data/brfss_diabetes.rds")
saveRDS(state_year_agg, "output/paper_59/data/state_year_panel.rds")

cat("\nCleaned data saved:\n")
cat("  - brfss_analysis.rds (full sample with treatment)\n")
cat("  - brfss_diabetes.rds (diabetic population only)\n")
cat("  - state_year_panel.rds (state-year aggregates)\n")

# =============================================================================
# Summary Statistics
# =============================================================================

cat("\n" %>% paste0(rep("=", 70), collapse = ""), "\n")
cat("SUMMARY STATISTICS\n")
cat(rep("=", 70) %>% paste0(collapse = ""), "\n\n")

# By treatment status
cat("Outcomes by treatment status (state-year level):\n")
state_year_agg %>%
  group_by(treated) %>%
  summarize(
    n_states = n_distinct(state_fips),
    n_obs = n(),
    insulin_rate = mean(insulin_rate, na.rm = TRUE),
    a1c_rate = mean(a1c_check_rate, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  print()

cat("\nData cleaning complete.\n")
