# ==============================================================================
# 02_clean_data.R
# Clean and construct analysis variables from ACS PUMS
# Paper 154: The Insurance Value of Secondary Employment
# ==============================================================================

source("00_packages.R")

# Load raw data
acs_raw <- readRDS(file.path(data_dir, "acs_pums_raw.rds"))

cat("Loaded", nrow(acs_raw), "observations.\n")

# ==============================================================================
# Variable construction
# ==============================================================================

# Note: ACS PUMS doesn't have a direct "multiple job holder" variable
# We use CLASS OF WORKER (COW) to identify self-employed as a proxy for
# entrepreneurship/alternative work arrangements
# The theoretical framework shifts to: Does self-employment status enable
# different labor market behaviors?

acs_clean <- acs_raw %>%
  mutate(
    # Convert all to numeric
    across(c(PWGTP, AGEP, SEX, RAC1P, HISP, MAR, SCHL, ESR, COW, WKHP, WAGP, PINCP, TEN),
           ~ suppressWarnings(as.numeric(.x))),

    # -------------------------------------------------------------------------
    # Demographics
    # -------------------------------------------------------------------------
    age = AGEP,
    female = as.integer(SEX == 2),

    # Race/ethnicity (RAC1P: 1=White, 2=Black, 6=Asian; HISP: 1=Not Hispanic)
    race = case_when(
      HISP > 1 ~ "Hispanic",
      RAC1P == 1 ~ "White",
      RAC1P == 2 ~ "Black",
      RAC1P == 6 ~ "Asian",
      TRUE ~ "Other"
    ),

    # Marital status (MAR: 1=Married)
    married = as.integer(MAR == 1),

    # Education (SCHL: 21=Bachelor's, 22=Master's, 23=Professional, 24=Doctorate)
    educ_years = case_when(
      SCHL <= 15 ~ 10,        # Less than HS
      SCHL == 16 | SCHL == 17 ~ 12,  # HS diploma or GED
      SCHL %in% 18:20 ~ 14,   # Some college, Associate's
      SCHL == 21 ~ 16,        # Bachelor's
      SCHL >= 22 ~ 18,        # Graduate degree
      TRUE ~ NA_real_
    ),
    college = as.integer(SCHL >= 21),

    # -------------------------------------------------------------------------
    # Employment variables
    # -------------------------------------------------------------------------
    # ESR: Employment status recode
    # 1 = Civilian employed, at work
    # 2 = Civilian employed, with a job but not at work
    # 3 = Unemployed
    # 4 = Armed forces, at work
    # 5 = Armed forces, with a job but not at work
    # 6 = Not in labor force
    employed = as.integer(ESR %in% c(1, 2, 4, 5)),

    # COW: Class of worker
    # 1 = Employee of private for-profit company
    # 2 = Employee of private not-for-profit
    # 3 = Local government employee
    # 4 = State government employee
    # 5 = Federal government employee
    # 6 = Self-employed in own not incorporated business
    # 7 = Self-employed in own incorporated business
    # 8 = Working without pay in family business
    self_employed = as.integer(COW %in% c(6, 7)),
    incorporated = as.integer(COW == 7),  # Incorporated self-employed
    wage_worker = as.integer(COW %in% c(1, 2, 3, 4, 5)),

    # As a proxy for "secondary employment" or "gig work tendency":
    # Use self-employment in unincorporated business (often side work)
    # plus high hours variation as indicators
    gig_proxy = as.integer(COW == 6),  # Unincorporated self-employed

    # Hours worked
    hours_usual = WKHP,
    full_time = as.integer(hours_usual >= 35),

    # -------------------------------------------------------------------------
    # Income and economic status
    # -------------------------------------------------------------------------
    earnings = WAGP,
    total_income = PINCP,

    # Log earnings (for wage analysis)
    log_earnings = log(pmax(earnings, 1)),

    # Income quartiles within year
    # -------------------------------------------------------------------------
    # Housing and wealth proxies
    # -------------------------------------------------------------------------
    # TEN: 1 = Owned with mortgage, 2 = Owned free and clear, 3 = Rented, 4 = Occupied without rent
    homeowner = as.integer(TEN %in% c(1, 2)),

    # -------------------------------------------------------------------------
    # Weight
    # -------------------------------------------------------------------------
    weight = PWGTP,

    # -------------------------------------------------------------------------
    # Year indicators
    # -------------------------------------------------------------------------
    year = as.integer(year),
    covid_period = as.integer(year %in% c(2020, 2021))
  )

# ==============================================================================
# Create income quartiles within year
# ==============================================================================

acs_clean <- acs_clean %>%
  group_by(year) %>%
  mutate(
    income_quartile = ntile(earnings, 4)
  ) %>%
  ungroup() %>%
  mutate(
    low_income = as.integer(income_quartile == 1)
  )

# ==============================================================================
# Sample restrictions
# ==============================================================================

cat("\n=== Applying Sample Restrictions ===\n")

acs_analysis <- acs_clean %>%
  filter(
    # Age restriction: Prime working age
    age >= 25 & age <= 54,

    # Must be employed
    employed == 1,

    # Valid weight
    !is.na(weight) & weight > 0,

    # Non-missing key variables
    !is.na(self_employed),
    !is.na(earnings),
    !is.na(educ_years)
  )

cat("After sample restrictions:", nrow(acs_analysis), "observations.\n")

# ==============================================================================
# Create credit constraint proxy
# ==============================================================================

acs_analysis <- acs_analysis %>%
  mutate(
    credit_constrained = as.integer(low_income == 1 & homeowner == 0)
  )

# ==============================================================================
# Summary statistics
# ==============================================================================

cat("\n=== Sample Summary ===\n")

# Overall sample
cat("\nSample size by year:\n")
print(table(acs_analysis$year))

# Self-employment rates
selfemp_by_year <- acs_analysis %>%
  group_by(year) %>%
  summarise(
    n = n(),
    selfemp_rate = weighted.mean(self_employed, weight, na.rm = TRUE),
    gig_proxy_rate = weighted.mean(gig_proxy, weight, na.rm = TRUE),
    .groups = "drop"
  )

cat("\nSelf-employment rates by year:\n")
print(selfemp_by_year)

# Characteristics comparison
cat("\n=== Comparison: Self-Employed vs Wage Workers ===\n")

comparison <- acs_analysis %>%
  group_by(self_employed) %>%
  summarise(
    n = n(),
    mean_age = weighted.mean(age, weight, na.rm = TRUE),
    pct_female = weighted.mean(female, weight, na.rm = TRUE) * 100,
    pct_college = weighted.mean(college, weight, na.rm = TRUE) * 100,
    pct_married = weighted.mean(married, weight, na.rm = TRUE) * 100,
    mean_earnings = weighted.mean(earnings, weight, na.rm = TRUE),
    mean_hours = weighted.mean(hours_usual, weight, na.rm = TRUE),
    pct_homeowner = weighted.mean(homeowner, weight, na.rm = TRUE) * 100,
    .groups = "drop"
  ) %>%
  mutate(
    group = ifelse(self_employed == 1, "Self-Employed", "Wage Worker")
  )

print(comparison %>% select(group, everything(), -self_employed))

# ==============================================================================
# For the main analysis, we reframe around self-employment as the "treatment"
# The research question becomes:
# "Does self-employment status (entrepreneurship) reflect selection or
#  different labor market dynamics?"
# ==============================================================================

# Create analysis dataset
analysis_vars <- c(
  # Identifiers
  "year", "state",

  # Treatment: Self-employment (proxy for alternative work)
  "self_employed", "gig_proxy", "incorporated",

  # Outcomes
  "employed", "earnings", "log_earnings", "full_time", "hours_usual",

  # Demographics
  "age", "female", "race", "married", "college", "educ_years",

  # Economic status
  "income_quartile", "low_income", "homeowner",
  "credit_constrained",

  # Period indicators
  "covid_period",

  # Weight
  "weight"
)

acs_final <- acs_analysis %>%
  select(all_of(analysis_vars))

# Save analysis dataset
saveRDS(acs_final, file.path(data_dir, "acs_analysis.rds"))
cat("\n\nAnalysis dataset saved:", nrow(acs_final), "observations.\n")

# ==============================================================================
# Save to cps_analysis.rds for compatibility with downstream scripts
# ==============================================================================

# Rename variables for compatibility
cps_compatible <- acs_final %>%
  rename(
    multiple_jobs = self_employed  # Use self-employed as the "treatment"
  )

saveRDS(cps_compatible, file.path(data_dir, "cps_analysis.rds"))

# Save descriptive statistics
desc_stats <- acs_analysis %>%
  summarise(
    `N` = n(),
    `Age (mean)` = weighted.mean(age, weight),
    `Female (%)` = weighted.mean(female, weight) * 100,
    `College (%)` = weighted.mean(college, weight) * 100,
    `Married (%)` = weighted.mean(married, weight) * 100,
    `Earnings (mean)` = weighted.mean(earnings, weight),
    `Full-time (%)` = weighted.mean(full_time, weight) * 100,
    `Homeowner (%)` = weighted.mean(homeowner, weight) * 100,
    `Self-employed (%)` = weighted.mean(self_employed, weight) * 100
  )

saveRDS(desc_stats, file.path(data_dir, "descriptive_stats.rds"))
saveRDS(comparison, file.path(data_dir, "mjh_comparison.rds"))

cat("\n=== Data Cleaning Complete ===\n")
