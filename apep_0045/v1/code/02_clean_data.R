# ==============================================================================
# 02_clean_data.R - Clean and construct analysis variables
# Paper 60: State Auto-IRA Mandates and Retirement Savings
# ==============================================================================

source("code/00_packages.R")

# ==============================================================================
# Load Raw Data
# ==============================================================================

cps_raw <- readRDS("data/cps_asec_raw.rds")
auto_ira_dates <- readRDS("data/auto_ira_policy_dates.rds")

cat("Loaded", nrow(cps_raw), "observations\n")

# ==============================================================================
# Construct Analysis Variables
# ==============================================================================

cps <- cps_raw %>%
  mutate(
    # Demographics
    age = as.numeric(AGE),
    female = as.numeric(SEX == 2),
    married = as.numeric(MARST %in% c(1, 2)),  # Married, spouse present/absent

    # Race/ethnicity
    white = as.numeric(RACE == 100 & HISPAN == 0),
    black = as.numeric(RACE == 200 & HISPAN == 0),
    hispanic = as.numeric(HISPAN != 0),

    # Education
    educ_cat = case_when(
      EDUC < 73 ~ "Less than HS",
      EDUC == 73 ~ "HS diploma",
      EDUC %in% 80:110 ~ "Some college",
      EDUC >= 111 ~ "Bachelor's+"
    ),
    educ_hs = as.numeric(EDUC == 73),
    educ_some_college = as.numeric(EDUC %in% 80:110),
    educ_ba_plus = as.numeric(EDUC >= 111),

    # Labor force status
    employed = as.numeric(EMPSTAT %in% c(10, 12)),  # At work, has job not at work
    unemployed = as.numeric(EMPSTAT %in% c(20, 21, 22)),
    not_in_lf = as.numeric(EMPSTAT >= 30),

    # Class of worker (for identifying private sector)
    # CLASSWKR codes: 21=Private for profit, 25=Federal govt, 26=Armed forces,
    # 27=State govt, 28=Local govt, 13/14=Self-employed
    private_sector = as.numeric(CLASSWKR == 21),  # Private for-profit wage/salary
    government = as.numeric(CLASSWKR %in% c(25, 26, 27, 28)),  # Federal, state, local gov
    self_employed = as.numeric(CLASSWKR %in% c(13, 14)),

    # Full-time worker
    full_time = as.numeric(UHRSWORKLY >= 35 | FULLPART == 1),

    # Income
    income_wage = as.numeric(INCWAGE),
    income_wage = ifelse(income_wage == 9999999, NA, income_wage),
    income_total = as.numeric(INCTOT),
    income_total = ifelse(income_total == 99999999, NA, income_total),
    log_income = log(pmax(income_wage, 1)),

    # Firm size (key for treatment intensity)
    # FIRMSIZE: 0=NIU, 1=under 10, 2=10-24, 3=25-99, 4=100-499, 5=500-999, 6=1000+
    firm_small = as.numeric(FIRMSIZE %in% c(1, 2)),  # Under 25
    firm_medium = as.numeric(FIRMSIZE %in% c(3, 4)),  # 25-499
    firm_large = as.numeric(FIRMSIZE %in% c(5, 6)),   # 500+

    # ==== KEY OUTCOME VARIABLES ====

    # PENSION: Employer/union has pension plan and respondent included?
    # 0=NIU, 1=No pension plan, 2=Yes pension, NOT included
    # 3=Yes pension, included, 4=No, covered by union
    # Key: Code 3 = has access AND is included (participant)
    has_pension_at_job = case_when(
      PENSION %in% c(2, 3, 4) ~ 1,  # Employer has pension plan
      PENSION == 1 ~ 0,  # No pension plan
      TRUE ~ NA_real_
    ),

    # Pension participant (included in employer's plan)
    pension_participant = case_when(
      PENSION == 3 ~ 1,  # Yes pension, included
      PENSION %in% c(1, 2, 4) ~ 0,  # Not included
      TRUE ~ NA_real_
    ),

    # "At risk" population: workers who DON'T have employer pension
    # These are the workers auto-IRA programs target
    no_employer_pension = as.numeric(has_pension_at_job == 0),

    # Year
    year = as.numeric(YEAR),

    # State
    statefip = as.numeric(STATEFIP),

    # Weight
    weight = as.numeric(ASECWT)
  )

# ==============================================================================
# Merge Treatment Indicators
# ==============================================================================

# Create state-level treatment data
state_treat <- auto_ira_dates %>%
  select(statefip, first_treat_year) %>%
  rename(first_treat = first_treat_year)

# Merge
cps <- cps %>%
  left_join(state_treat, by = "statefip") %>%
  mutate(
    # Treatment indicators
    auto_ira_state = as.numeric(!is.na(first_treat)),
    treated = as.numeric(!is.na(first_treat) & year >= first_treat),

    # For never-treated, set first_treat to 0 (Callaway-Sant'Anna convention)
    first_treat = ifelse(is.na(first_treat), 0, first_treat)
  )

# ==============================================================================
# Create Analysis Sample
# ==============================================================================

# Main sample: Working-age adults (25-64) who are employed
# Focus on private sector workers (most affected by auto-IRA)
cps_analysis <- cps %>%
  filter(
    age >= 25 & age <= 64,        # Working age
    employed == 1,                 # Currently employed
    !is.na(weight),
    weight > 0
  )

cat("Analysis sample:", nrow(cps_analysis), "observations\n")
cat("Private sector workers:", sum(cps_analysis$private_sector), "\n")
cat("Workers without employer pension:", sum(cps_analysis$no_employer_pension, na.rm = TRUE), "\n")

# Create restricted samples
cps_private <- cps_analysis %>% filter(private_sector == 1)
cps_no_pension <- cps_analysis %>% filter(no_employer_pension == 1)

cat("Private sector sample:", nrow(cps_private), "observations\n")
cat("No employer pension sample:", nrow(cps_no_pension), "observations\n")

# ==============================================================================
# Summary Statistics
# ==============================================================================

cat("\n=== Sample Summary by Year ===\n")
summary_by_year <- cps_private %>%
  group_by(year) %>%
  summarise(
    n = n(),
    pct_has_pension = weighted.mean(has_pension_at_job, weight, na.rm = TRUE),
    pct_pension_participant = weighted.mean(pension_participant, weight, na.rm = TRUE),
    mean_age = weighted.mean(age, weight),
    pct_female = weighted.mean(female, weight),
    pct_ba_plus = weighted.mean(educ_ba_plus, weight),
    n_treated_states = n_distinct(statefip[auto_ira_state == 1]),
    .groups = "drop"
  )

print(summary_by_year)

cat("\n=== Treatment Status by State ===\n")
state_summary <- cps_private %>%
  group_by(statefip, auto_ira_state, first_treat) %>%
  summarise(
    n_obs = n(),
    mean_pension = weighted.mean(has_pension_at_job, weight, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(auto_ira_state == 1) %>%
  arrange(first_treat)

print(state_summary)

# ==============================================================================
# Save Clean Data
# ==============================================================================

saveRDS(cps_analysis, "data/cps_analysis.rds")
saveRDS(cps_private, "data/cps_private.rds")
saveRDS(cps_no_pension, "data/cps_no_pension.rds")

cat("\nClean data saved:\n")
cat("  - data/cps_analysis.rds (all employed workers)\n")
cat("  - data/cps_private.rds (private sector workers)\n")
cat("  - data/cps_no_pension.rds (workers without employer pension)\n")
