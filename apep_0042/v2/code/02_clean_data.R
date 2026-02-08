# =============================================================================
# 02_clean_data.R
# Clean CPS ASEC data and construct analysis variables
# =============================================================================

source("00_packages.R")

# -----------------------------------------------------------------------------
# Load IPUMS Data
# -----------------------------------------------------------------------------

cat("Loading IPUMS data...\n")

# Find the DDI file
ddi_file <- list.files(data_dir, pattern = "\\.xml$", full.names = TRUE)[1]

if (is.na(ddi_file)) {
  stop("No DDI file found. Run 01_fetch_data.R first.")
}

cat("Reading DDI:", ddi_file, "\n")
ddi <- read_ipums_ddi(ddi_file)

# Read the microdata
cat("Reading microdata (this may take a few minutes)...\n")
df_raw <- read_ipums_micro(ddi)

cat("Raw data:", nrow(df_raw), "observations\n")

# -----------------------------------------------------------------------------
# Load Treatment Data
# -----------------------------------------------------------------------------

treatment_data <- read_csv(file.path(data_dir, "treatment_data.csv"),
                           show_col_types = FALSE)

# Create lookup for first treatment year (0 = never treated)
treat_lookup <- treatment_data %>%
  select(statefip, first_treat_year)

# -----------------------------------------------------------------------------
# Sample Restrictions
# -----------------------------------------------------------------------------

cat("\nApplying sample restrictions...\n")

df <- df_raw %>%
  # Convert labelled columns to values
  mutate(across(where(is.labelled), as.numeric)) %>%

  # Age restriction: 18-64
  filter(AGE >= 18, AGE <= 64) %>%

  # Private sector wage/salary workers only
  # CLASSWKR: 21 = Private for-profit, 25-28 = various private employee types
  # Exclude: government, self-employed (13,14), unpaid family
  filter(CLASSWKR %in% c(21, 25, 26, 27, 28)) %>%

  # In labor force and employed
  # EMPSTAT: 10 = at work, 12 = has job but not at work
  filter(EMPSTAT %in% c(10, 12))

cat("After restrictions:", nrow(df), "observations\n")

# -----------------------------------------------------------------------------
# Variable Construction
# -----------------------------------------------------------------------------

cat("\nConstructing analysis variables...\n")

df <- df %>%
  mutate(
    # Year
    year = YEAR,

    # State
    statefip = STATEFIP,

    # Treatment assignment
    first_treat = case_when(
      statefip %in% treat_lookup$statefip ~
        treat_lookup$first_treat_year[match(statefip, treat_lookup$statefip)],
      TRUE ~ 0  # Never treated
    ),

    # Post-treatment indicator
    post = ifelse(first_treat > 0 & year >= first_treat, 1, 0),

    # Treatment status (for descriptives)
    treated_state = ifelse(first_treat > 0, 1, 0),

    # OUTCOME: Has retirement plan coverage
    # PENSION: 0 = NIU, 1 = No pension plan, 2 = Yes pension plan
    has_pension = case_when(
      PENSION == 2 ~ 1,
      PENSION == 1 ~ 0,
      TRUE ~ NA_real_
    ),

    # Demographics
    female = ifelse(SEX == 2, 1, 0),
    age = AGE,
    age_sq = AGE^2,

    # Age groups
    age_group = case_when(
      AGE >= 18 & AGE <= 29 ~ "18-29",
      AGE >= 30 & AGE <= 44 ~ "30-44",
      AGE >= 45 & AGE <= 54 ~ "45-54",
      AGE >= 55 & AGE <= 64 ~ "55-64"
    ),

    # Education (harmonized)
    # EDUC codes vary; simplified here
    college = ifelse(EDUC >= 111, 1, 0),  # Bachelor's or higher

    # Race/ethnicity
    white_nh = ifelse(RACE == 100 & HISPAN == 0, 1, 0),
    black_nh = ifelse(RACE == 200 & HISPAN == 0, 1, 0),
    hispanic = ifelse(HISPAN > 0, 1, 0),

    # Married
    married = ifelse(MARST %in% c(1, 2), 1, 0),

    # Firm size (key for heterogeneity)
    # FIRMSIZE: 0=NIU, 1=Under 10, 2=10-24, 5=25-99, 7=100-499, 8=500-999, 9=1000+
    small_firm = case_when(
      FIRMSIZE %in% c(1, 2, 5) ~ 1,   # <100 employees
      FIRMSIZE %in% c(7, 8, 9) ~ 0,   # 100+ employees
      TRUE ~ NA_real_
    ),

    # More granular firm size for DDD analysis
    firm_size_cat = case_when(
      FIRMSIZE == 1 ~ "Under 10",
      FIRMSIZE == 2 ~ "10-24",
      FIRMSIZE == 5 ~ "25-99",
      FIRMSIZE == 7 ~ "100-499",
      FIRMSIZE == 8 ~ "500-999",
      FIRMSIZE == 9 ~ "1000+",
      TRUE ~ NA_character_
    ),

    # Wages (log)
    log_wage = ifelse(INCWAGE > 0, log(INCWAGE), NA_real_),

    # Health insurance from employer (for balance)
    has_emp_health = ifelse(HINSEMP == 2, 1, 0),

    # Sample weight
    weight = ASECWT
  )

cat("Variables constructed.\n")

# -----------------------------------------------------------------------------
# Final Sample
# -----------------------------------------------------------------------------

# Drop observations with missing outcome
df_analysis <- df %>%
  filter(!is.na(has_pension))

cat("\nFinal analysis sample:", nrow(df_analysis), "observations\n")

# Summary by treatment status
cat("\nSample by treatment status:\n")
df_analysis %>%
  group_by(treated_state) %>%
  summarise(
    n = n(),
    n_states = n_distinct(statefip),
    years = paste(min(year), max(year), sep = "-"),
    pct_pension = weighted.mean(has_pension, weight, na.rm = TRUE)
  ) %>%
  print()

# Summary by year
cat("\nSample by year:\n")
df_analysis %>%
  group_by(year) %>%
  summarise(
    n = n(),
    pct_pension = weighted.mean(has_pension, weight, na.rm = TRUE)
  ) %>%
  print(n = 20)

# -----------------------------------------------------------------------------
# Save Cleaned Data
# -----------------------------------------------------------------------------

cat("\nSaving cleaned data...\n")

# Save as RDS for R
saveRDS(df_analysis, file.path(data_dir, "cps_asec_clean.rds"))

# Save treatment data with all states
all_states <- df_analysis %>%
  distinct(statefip) %>%
  left_join(treat_lookup, by = "statefip") %>%
  mutate(first_treat_year = replace_na(first_treat_year, 0))

write_csv(all_states, file.path(data_dir, "states_treatment.csv"))

cat("Cleaned data saved to:", file.path(data_dir, "cps_asec_clean.rds"), "\n")
cat("\nNext: Run 03_main_analysis.R\n")
