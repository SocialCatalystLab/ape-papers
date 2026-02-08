# ==============================================================================
# APEP Paper 93: SNAP Work Requirements and Employment
# 02_clean_data.R - Clean data and construct variables
# ==============================================================================

source("00_packages.R")

# Load data
pums_raw <- readRDS("../data/pums_raw.rds")
waiver_long <- readRDS("../data/waiver_status.rds")
first_treat <- readRDS("../data/first_treat.rds")

cat("Loaded", nrow(pums_raw), "observations\n")

# ------------------------------------------------------------------------------
# Variable Construction
# ------------------------------------------------------------------------------

pums_clean <- pums_raw %>%
  # Restrict to working-age adults
  filter(AGEP >= 18 & AGEP <= 64) %>%
  mutate(
    # Employment status
    # ESR codes: 1=employed, 2=employed but absent, 3=unemployed, 
    #            4=armed forces, 5=armed forces absent, 6=not in labor force
    employed = case_when(
      ESR %in% c(1, 2) ~ 1,
      ESR %in% c(3, 6) ~ 0,
      TRUE ~ NA_real_
    ),
    in_labor_force = case_when(
      ESR %in% c(1, 2, 3) ~ 1,
      ESR == 6 ~ 0,
      TRUE ~ NA_real_
    ),
    unemployed = case_when(
      ESR == 3 ~ 1,
      ESR %in% c(1, 2, 6) ~ 0,
      TRUE ~ NA_real_
    ),
    
    # SNAP receipt
    snap = ifelse(FS == 1, 1, 0),
    
    # Demographics
    female = ifelse(SEX == 2, 1, 0),
    
    # Race (simplified)
    race_cat = case_when(
      RAC1P == 1 ~ "White",
      RAC1P == 2 ~ "Black",
      RAC1P %in% c(3, 4, 5) ~ "Native American",
      RAC1P == 6 ~ "Asian",
      TRUE ~ "Other"
    ),
    white = ifelse(RAC1P == 1, 1, 0),
    black = ifelse(RAC1P == 2, 1, 0),
    
    # Education (simplified)
    # SCHL: 0-15 = less than HS, 16-17 = HS diploma/GED, 18-20 = some college, 21+ = BA+
    educ_cat = case_when(
      SCHL <= 15 ~ "Less than HS",
      SCHL %in% c(16, 17) ~ "HS diploma",
      SCHL %in% c(18, 19, 20) ~ "Some college",
      SCHL >= 21 ~ "Bachelor's+",
      TRUE ~ "Unknown"
    ),
    less_than_hs = ifelse(SCHL <= 15, 1, 0),
    hs_only = ifelse(SCHL %in% c(16, 17), 1, 0),
    
    # Disability
    has_disability = ifelse(DIS == 1, 1, 0),
    
    # Age groups
    age_18_24 = ifelse(AGEP >= 18 & AGEP <= 24, 1, 0),
    age_25_34 = ifelse(AGEP >= 25 & AGEP <= 34, 1, 0),
    age_35_49 = ifelse(AGEP >= 35 & AGEP <= 49, 1, 0),
    age_50_64 = ifelse(AGEP >= 50 & AGEP <= 64, 1, 0),
    
    # ABAWD eligible (ages 18-49, no disability)
    # Note: We can't directly observe dependents in single-year ACS PUMS
    # So we define potential ABAWDs as 18-49 without disability
    abawd_eligible = ifelse(AGEP >= 18 & AGEP <= 49 & has_disability == 0, 1, 0),
    
    # Comparison group: ages 50-64 (exempt from ABAWD)
    exempt_age = ifelse(AGEP >= 50 & AGEP <= 64, 1, 0)
  )

cat("After cleaning:", nrow(pums_clean), "observations\n")

# ------------------------------------------------------------------------------
# Merge with Waiver Status
# ------------------------------------------------------------------------------

pums_merged <- pums_clean %>%
  left_join(
    waiver_long %>% select(state_fips, year, waiver, work_req),
    by = c("ST" = "state_fips", "year" = "year")
  ) %>%
  left_join(
    first_treat,
    by = c("ST" = "state_fips")
  ) %>%
  mutate(
    # Set first_treat to 0 for never-treated states
    first_treat = ifelse(is.na(first_treat), 0, first_treat),
    
    # Treatment indicator (post-reinstatement in treated state)
    treated = ifelse(first_treat > 0 & year >= first_treat, 1, 0),
    
    # Event time (years since treatment)
    event_time = ifelse(first_treat > 0, year - first_treat, NA_integer_)
  )

cat("After merge:", nrow(pums_merged), "observations\n")
cat("Treatment rate:", mean(pums_merged$treated, na.rm = TRUE), "\n")

# ------------------------------------------------------------------------------
# Create Analysis Sample
# ------------------------------------------------------------------------------

# Main sample: ABAWD-eligible individuals
analysis_sample <- pums_merged %>%
  filter(abawd_eligible == 1) %>%
  filter(!is.na(employed)) %>%
  filter(!is.na(waiver))

cat("Analysis sample (ABAWD-eligible):", nrow(analysis_sample), "observations\n")

# Create state-year aggregates for DiD
state_year <- analysis_sample %>%
  group_by(ST, year, first_treat, treated, work_req) %>%
  summarize(
    employed = weighted.mean(employed, w = PWGTP, na.rm = TRUE),
    in_lf = weighted.mean(in_labor_force, w = PWGTP, na.rm = TRUE),
    snap = weighted.mean(snap, w = PWGTP, na.rm = TRUE),
    n_obs = n(),
    pop = sum(PWGTP),
    .groups = "drop"
  ) %>%
  mutate(
    state_id = as.integer(factor(ST))
  )

cat("State-year observations:", nrow(state_year), "\n")

# Save cleaned data
saveRDS(pums_merged, "../data/pums_merged.rds")
saveRDS(analysis_sample, "../data/analysis_sample.rds")
saveRDS(state_year, "../data/state_year.rds")

cat("\nData saved:\n")
cat("  ../data/pums_merged.rds\n")
cat("  ../data/analysis_sample.rds\n")
cat("  ../data/state_year.rds\n")
