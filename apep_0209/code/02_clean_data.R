# ============================================================================
# 02_clean_data.R
# Salary Transparency Laws and the Gender Wage Gap
# Data Cleaning and Variable Construction
# ============================================================================
#
# --- Input/Output Provenance ---
# INPUTS:
#   data/cps_asec_raw.rds          <- 01_fetch_data.R (raw IPUMS microdata)
#   data/transparency_laws.rds     <- 00_policy_data.R (treatment timing)
# OUTPUTS:
#   data/cps_analysis.rds          (individual-level analysis data, trimmed)
#   data/state_year_panel.rds      (state-year aggregates)
#   data/wage_bounds_info.rds      (wage trimming metadata)
# ============================================================================

source("code/00_packages.R")

# ============================================================================
# Load Raw Data
# ============================================================================

cat("Loading raw CPS ASEC data...\n")
df_raw <- readRDS("data/cps_asec_raw.rds")
transparency_laws <- readRDS("data/transparency_laws.rds")

cat("Raw data:", format(nrow(df_raw), big.mark = ","), "observations\n")

# ============================================================================
# Sample Restrictions
# ============================================================================

cat("\nApplying sample restrictions...\n")

df <- df_raw %>%
  # 1. Working-age adults (25-64)
  filter(AGE >= 25, AGE <= 64) %>%

  # 2. Employed wage/salary workers
  # CLASSWKR: 21-28 = private sector, 25-28 = government
  filter(CLASSWKR >= 21, CLASSWKR <= 28) %>%

  # 3. Positive wage income
  filter(INCWAGE > 0, INCWAGE < 9999999) %>%

  # 4. Reasonable hours (at least part-time, 10+ hours)
  filter(UHRSWORKLY >= 10, UHRSWORKLY <= 80) %>%

  # 5. Worked at least 13 weeks last year (quarterly)
  filter(WKSWORK1 >= 13 | WKSWORK2 >= 2)

cat("After restrictions:", format(nrow(df), big.mark = ","), "observations\n")

# ============================================================================
# Variable Construction
# ============================================================================

cat("\nConstructing analysis variables...\n")

df <- df %>%
  mutate(
    # ---- Outcome Variables ----

    # Annual hours worked
    weeks_worked = case_when(
      !is.na(WKSWORK1) & WKSWORK1 > 0 ~ as.numeric(WKSWORK1),
      WKSWORK2 == 1 ~ 7,    # 1-13 weeks
      WKSWORK2 == 2 ~ 20,   # 14-26 weeks
      WKSWORK2 == 3 ~ 33,   # 27-39 weeks
      WKSWORK2 == 4 ~ 43,   # 40-47 weeks
      WKSWORK2 == 5 ~ 48,   # 48-49 weeks
      WKSWORK2 == 6 ~ 51,   # 50-52 weeks
      TRUE ~ 50
    ),
    annual_hours = UHRSWORKLY * weeks_worked,

    # Hourly wage
    hourly_wage = INCWAGE / annual_hours,

    # Log hourly wage (primary outcome)
    log_hourly_wage = log(hourly_wage),

    # ---- Treatment Variables ----

    # Female indicator
    female = as.integer(SEX == 2),

    # ---- Demographic Controls ----

    # Age groups
    age_group = cut(AGE, breaks = c(24, 34, 44, 54, 64),
                    labels = c("25-34", "35-44", "45-54", "55-64")),

    # Education categories
    educ_cat = case_when(
      EDUC <= 72 ~ "Less than HS",
      EDUC >= 73 & EDUC <= 81 ~ "High school",
      EDUC >= 91 & EDUC <= 109 ~ "Some college",
      EDUC >= 110 & EDUC <= 122 ~ "BA or higher",
      EDUC >= 123 ~ "Graduate degree",
      TRUE ~ "Other"
    ),

    # Race/ethnicity
    race_eth = case_when(
      HISPAN >= 100 & HISPAN <= 412 ~ "Hispanic",
      RACE == 100 ~ "White",
      RACE == 200 ~ "Black",
      RACE >= 650 ~ "Asian",
      TRUE ~ "Other"
    ),

    # Married indicator
    married = as.integer(MARST == 1 | MARST == 2),

    # Full-time indicator
    fulltime = as.integer(UHRSWORKLY >= 35),

    # ---- Geographic ----

    # State FIPS
    statefip = as.integer(STATEFIP),

    # Metropolitan status
    metro = as.integer(METRO >= 2)
  )

# ============================================================================
# Merge Treatment Status
# ============================================================================

cat("Merging treatment status...\n")

# Create treatment indicators by state-year
df <- df %>%
  left_join(
    transparency_laws %>%
      select(statefip, first_treat),
    by = "statefip"
  ) %>%
  mutate(
    # Treatment cohort (0 for never-treated)
    first_treat = replace_na(first_treat, 0),

    # Ever-treated indicator
    ever_treated = as.integer(first_treat > 0),

    # Post-treatment indicator
    post = as.integer(income_year >= first_treat & first_treat > 0),

    # DiD interaction
    treat_post = ever_treated * post,

    # Event time (relative to treatment)
    event_time = case_when(
      first_treat == 0 ~ NA_real_,
      TRUE ~ income_year - first_treat
    )
  )

# ============================================================================
# Wage Trimming (Using PRE-TREATMENT Period Only)
# ============================================================================
#
# IMPORTANT: To avoid selection bias from conditioning on the outcome,
# we calculate wage bounds using PRE-TREATMENT data only (income years 2014-2020)
# and apply those same bounds to ALL observations. This ensures the same
# population is compared across treatment status and time periods.
#
# See Rambachan & Roth (2023) and Lee & Lemieux (2010) on conditioning concerns.

cat("Trimming extreme wages using PRE-TREATMENT bounds...\n")

# Calculate bounds from pre-treatment period ONLY
# Earliest treatment is Colorado in income year 2021
# Use income years 2014-2020 (all pre-treatment for all states)
pre_treatment_wages <- df %>%
  filter(income_year <= 2020) %>%
  pull(hourly_wage)

wage_bounds <- quantile(pre_treatment_wages, c(0.01, 0.99), na.rm = TRUE)
cat("Pre-treatment wage bounds (2014-2020): $", round(wage_bounds[1], 2),
    " - $", round(wage_bounds[2], 2), "\n")
cat("(These bounds are applied to ALL years to avoid selection bias)\n")

# Apply same bounds to ALL observations
df <- df %>%
  filter(hourly_wage >= wage_bounds[1], hourly_wage <= wage_bounds[2]) %>%
  mutate(
    # Recalculate log wage after trimming
    log_hourly_wage = log(hourly_wage)
  )

cat("After wage trimming:", format(nrow(df), big.mark = ","), "observations\n")

# Save the bounds for documentation
wage_bounds_info <- list(
  lower = wage_bounds[1],
  upper = wage_bounds[2],
  percentiles = c(0.01, 0.99),
  source_years = 2014:2020,
  n_obs_for_bounds = length(pre_treatment_wages)
)
saveRDS(wage_bounds_info, "data/wage_bounds_info.rds")
cat("Saved wage bounds metadata to data/wage_bounds_info.rds\n")

# ============================================================================
# Occupation Classification for Heterogeneity
# ============================================================================

cat("Classifying occupations by bargaining intensity...\n")

# Major occupation categories (from OCC2010)
# High bargaining: Professional, technical, managerial
# Low bargaining: Service, sales, production with posted wages

df <- df %>%
  mutate(
    occ_major = case_when(
      OCC2010 >= 10 & OCC2010 <= 430 ~ "Management",
      OCC2010 >= 500 & OCC2010 <= 950 ~ "Business/Financial",
      OCC2010 >= 1000 & OCC2010 <= 1240 ~ "Computer/Math",
      OCC2010 >= 1300 & OCC2010 <= 1560 ~ "Architecture/Engineering",
      OCC2010 >= 1600 & OCC2010 <= 1980 ~ "Life/Physical/Social Science",
      OCC2010 >= 2000 & OCC2010 <= 2060 ~ "Community/Social Service",
      OCC2010 >= 2100 & OCC2010 <= 2160 ~ "Legal",
      OCC2010 >= 2200 & OCC2010 <= 2550 ~ "Education",
      OCC2010 >= 2600 & OCC2010 <= 2960 ~ "Arts/Entertainment/Media",
      OCC2010 >= 3000 & OCC2010 <= 3540 ~ "Healthcare Practitioners",
      OCC2010 >= 3600 & OCC2010 <= 3650 ~ "Healthcare Support",
      OCC2010 >= 3700 & OCC2010 <= 3950 ~ "Protective Service",
      OCC2010 >= 4000 & OCC2010 <= 4150 ~ "Food Preparation",
      OCC2010 >= 4200 & OCC2010 <= 4250 ~ "Building/Grounds",
      OCC2010 >= 4300 & OCC2010 <= 4650 ~ "Personal Care",
      OCC2010 >= 4700 & OCC2010 <= 4965 ~ "Sales",
      OCC2010 >= 5000 & OCC2010 <= 5940 ~ "Office/Admin",
      OCC2010 >= 6000 & OCC2010 <= 6130 ~ "Farming/Fishing",
      OCC2010 >= 6200 & OCC2010 <= 6765 ~ "Construction",
      OCC2010 >= 6800 & OCC2010 <= 6940 ~ "Extraction",
      OCC2010 >= 7000 & OCC2010 <= 7630 ~ "Installation/Repair",
      OCC2010 >= 7700 & OCC2010 <= 8965 ~ "Production",
      OCC2010 >= 9000 & OCC2010 <= 9750 ~ "Transportation",
      TRUE ~ "Other"
    ),

    # High bargaining occupations (professional, technical, where individual
    # negotiation is common)
    high_bargaining = as.integer(occ_major %in% c(
      "Management", "Business/Financial", "Computer/Math",
      "Architecture/Engineering", "Legal", "Healthcare Practitioners"
    ))
  )

# ============================================================================
# Industry Classification
# ============================================================================

df <- df %>%
  mutate(
    ind_major = case_when(
      IND1990 >= 10 & IND1990 <= 32 ~ "Agriculture",
      IND1990 >= 40 & IND1990 <= 50 ~ "Mining",
      IND1990 == 60 ~ "Construction",
      IND1990 >= 100 & IND1990 <= 392 ~ "Manufacturing",
      IND1990 >= 400 & IND1990 <= 472 ~ "Transportation",
      IND1990 >= 500 & IND1990 <= 571 ~ "Wholesale Trade",
      IND1990 >= 580 & IND1990 <= 691 ~ "Retail Trade",
      IND1990 >= 700 & IND1990 <= 712 ~ "Finance/Insurance/RE",
      IND1990 >= 721 & IND1990 <= 760 ~ "Business Services",
      IND1990 >= 761 & IND1990 <= 791 ~ "Personal Services",
      IND1990 >= 800 & IND1990 <= 810 ~ "Entertainment",
      IND1990 >= 812 & IND1990 <= 893 ~ "Professional Services",
      IND1990 >= 900 & IND1990 <= 932 ~ "Public Administration",
      TRUE ~ "Other"
    )
  )

# ============================================================================
# Create State-Level Panel for Aggregates
# ============================================================================

cat("Creating state-year aggregates...\n")

# Helper function for weighted variance (must be defined before use)
wtd.var <- function(x, w) {
  sum(w * (x - weighted.mean(x, w))^2) / sum(w)
}

# Helper function for weighted quantiles (must be defined before use)
wtd.quantile <- function(x, w, probs) {
  ord <- order(x)
  x <- x[ord]
  w <- w[ord]
  cum_w <- cumsum(w) / sum(w)
  approx(cum_w, x, probs, rule = 2)$y
}

# Create state-year panel with weighted statistics
state_year <- df %>%
  group_by(statefip, income_year, first_treat, ever_treated, post, treat_post) %>%
  summarize(
    n = n(),
    n_female = sum(female),
    n_male = sum(1 - female),
    mean_wage = weighted.mean(hourly_wage, ASECWT, na.rm = TRUE),
    mean_log_wage = weighted.mean(log_hourly_wage, ASECWT, na.rm = TRUE),
    mean_wage_female = weighted.mean(hourly_wage[female == 1],
                                     ASECWT[female == 1], na.rm = TRUE),
    mean_wage_male = weighted.mean(hourly_wage[female == 0],
                                   ASECWT[female == 0], na.rm = TRUE),
    pct_female = weighted.mean(female, ASECWT, na.rm = TRUE) * 100,
    pct_college = weighted.mean(educ_cat %in% c("BA or higher", "Graduate degree"),
                                ASECWT, na.rm = TRUE) * 100,
    mean_age = weighted.mean(AGE, ASECWT, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    wage_gap = mean_wage_male - mean_wage_female,
    wage_gap_pct = (mean_wage_male - mean_wage_female) / mean_wage_male * 100,
    log_wage_gap = log(mean_wage_male) - log(mean_wage_female),
    event_time = ifelse(first_treat > 0, income_year - first_treat, NA_real_)
  )

# ============================================================================
# Summary Statistics
# ============================================================================

cat("\n==== Summary Statistics ====\n")

cat("\nSample by treatment status:\n")
df %>%
  group_by(ever_treated) %>%
  summarize(
    n = n(),
    states = n_distinct(statefip),
    mean_wage = mean(hourly_wage, na.rm = TRUE),
    pct_female = mean(female) * 100
  ) %>%
  print()

cat("\nTreatment cohorts:\n")
df %>%
  filter(first_treat > 0) %>%
  group_by(first_treat) %>%
  summarize(
    states = n_distinct(statefip),
    n = n()
  ) %>%
  print()

cat("\nObservations by year:\n")
df %>%
  count(income_year) %>%
  print()

cat("\nState-year panel dimensions:\n")
cat("States:", n_distinct(state_year$statefip), "\n")
cat("Years:", n_distinct(state_year$income_year), "\n")
cat("Observations:", nrow(state_year), "\n")

# ============================================================================
# Save Cleaned Data
# ============================================================================

cat("\nSaving cleaned data...\n")

saveRDS(df, "data/cps_analysis.rds")
saveRDS(state_year, "data/state_year_panel.rds")

cat("Individual data saved to data/cps_analysis.rds\n")
cat("State-year panel saved to data/state_year_panel.rds\n")

cat("\n==== Data Cleaning Complete ====\n")
cat("Next step: Run 03_descriptives.R\n")
