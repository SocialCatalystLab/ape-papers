# ==============================================================================
# Paper 63: State EITC and Single Mothers' Self-Employment
# 02_clean_data.R - Clean and construct analysis sample
# ==============================================================================

source("00_packages.R")

# ==============================================================================
# Load raw data
# ==============================================================================

cps_raw <- read_csv(file.path(data_path, "cps_asec_raw.csv"), show_col_types = FALSE)

message(sprintf("Loaded %s observations from raw CPS data", format(nrow(cps_raw), big.mark = ",")))

# ==============================================================================
# Variable Coding Reference (from Census API documentation)
# ==============================================================================

# A_SEX: 1=Male, 2=Female
# A_MARITL: 1=Married-civilian spouse present, 2=Married-AF spouse present,
#           3=Married-spouse absent, 4=Widowed, 5=Divorced, 6=Separated, 7=Never married
# A_CLSWKR: 1=Private, 2=Federal govt, 3=State govt, 4=Local govt, 5=Without pay,
#           6=Self-employed (incorporated), 7=Self-employed (unincorporated), 8=Never worked
# A_LFSR: Labor force status recode
# A_HGA: Educational attainment (1-46 scale)

# ==============================================================================
# Create analysis variables
# ==============================================================================

cps_clean <- cps_raw %>%
  rename(
    statefip = GESTFIPS,
    year = YEAR,
    age = A_AGE,
    sex = A_SEX,
    marital = A_MARITL,
    class_worker = A_CLSWKR,
    n_children_u18 = FOWNU18,
    n_children_u6 = FOWNU6,
    educ = A_HGA,
    work_status = A_WKSTAT,
    weight = MARSUPWT
  ) %>%
  mutate(
    # Demographics
    female = (sex == 2),

    # Marital status
    married = (marital %in% c(1, 2, 3)),
    single = !married,

    # Parent status
    has_children = (n_children_u18 > 0),
    has_young_children = (n_children_u6 > 0),

    # Single mother indicator (key treatment population)
    single_mother = (female & single & has_children),

    # Education categories
    less_than_hs = (educ < 39),  # Less than HS diploma
    hs_diploma = (educ == 39),    # HS diploma
    some_college = (educ %in% c(40, 41, 42)),  # Some college
    college_plus = (educ >= 43),  # Bachelor's or higher
    low_education = (educ <= 40),  # HS or less (EITC-eligible proxy)

    # Employment status
    employed = (class_worker %in% c(1, 2, 3, 4, 5, 6, 7)),

    # Self-employment (main outcome)
    self_employed = (class_worker %in% c(6, 7)),
    self_emp_incorporated = (class_worker == 6),
    self_emp_unincorporated = (class_worker == 7),

    # Wage employment
    wage_employed = (class_worker %in% c(1, 2, 3, 4)),

    # Combined employment types
    only_self_employed = (self_employed & !wage_employed),

    # Ensure weight is numeric
    weight = as.numeric(weight)
  )

# ==============================================================================
# Merge with state EITC policy data
# ==============================================================================

# Load policy data
state_eitc <- read_csv(file.path(data_path, "state_eitc_panel.csv"), show_col_types = FALSE)

# Merge
cps_analysis <- cps_clean %>%
  left_join(
    state_eitc %>% select(statefip, year, has_state_eitc, cohort, rate_2024, refundable),
    by = c("statefip", "year")
  )

# Check merge
message(sprintf("Observations with EITC data: %s / %s",
                format(sum(!is.na(cps_analysis$has_state_eitc)), big.mark = ","),
                format(nrow(cps_analysis), big.mark = ",")))

# ==============================================================================
# Define analysis samples
# ==============================================================================

# Main sample: Single mothers, ages 18-55
main_sample <- cps_analysis %>%
  filter(
    single_mother,
    age >= 18 & age <= 55
  )

message(sprintf("Main sample (single mothers 18-55): %s observations",
                format(nrow(main_sample), big.mark = ",")))

# Restricted sample: Low education (HS or less) - more likely EITC-eligible
restricted_sample <- main_sample %>%
  filter(low_education)

message(sprintf("Restricted sample (low education): %s observations",
                format(nrow(restricted_sample), big.mark = ",")))

# Placebo sample: Childless women (for comparison)
placebo_childless <- cps_analysis %>%
  filter(
    female,
    single,
    !has_children,
    age >= 18 & age <= 55
  )

message(sprintf("Placebo sample (childless single women): %s observations",
                format(nrow(placebo_childless), big.mark = ",")))

# ==============================================================================
# Summary statistics
# ==============================================================================

message("\n=== Main Sample Summary ===")

main_sample %>%
  summarise(
    n = n(),
    mean_age = weighted.mean(age, weight, na.rm = TRUE),
    pct_employed = weighted.mean(employed, weight, na.rm = TRUE) * 100,
    pct_self_employed = weighted.mean(self_employed, weight, na.rm = TRUE) * 100,
    pct_self_emp_inc = weighted.mean(self_emp_incorporated, weight, na.rm = TRUE) * 100,
    pct_self_emp_uninc = weighted.mean(self_emp_unincorporated, weight, na.rm = TRUE) * 100,
    pct_state_eitc = weighted.mean(has_state_eitc, weight, na.rm = TRUE) * 100,
    pct_low_educ = weighted.mean(low_education, weight, na.rm = TRUE) * 100,
    mean_n_children = weighted.mean(n_children_u18, weight, na.rm = TRUE)
  ) %>%
  pivot_longer(everything(), names_to = "Statistic", values_to = "Value") %>%
  print()

# ==============================================================================
# Save cleaned data
# ==============================================================================

write_csv(cps_analysis, file.path(data_path, "cps_analysis_full.csv"))
write_csv(main_sample, file.path(data_path, "cps_main_sample.csv"))
write_csv(restricted_sample, file.path(data_path, "cps_restricted_sample.csv"))
write_csv(placebo_childless, file.path(data_path, "cps_placebo_childless.csv"))

message("\nData files saved to: ", data_path)
message("  - cps_analysis_full.csv")
message("  - cps_main_sample.csv")
message("  - cps_restricted_sample.csv")
message("  - cps_placebo_childless.csv")
