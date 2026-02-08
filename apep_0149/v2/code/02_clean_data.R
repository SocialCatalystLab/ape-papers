##############################################################################
# 02_clean_data.R - Clean and construct analysis variables
# Revision of apep_0149: Medicaid Postpartum Coverage Extensions
# CHANGES: max_sample_year auto-updates to 2024; ID/IA state_abbr fill-in;
#          2023/2024 adopters become treated; control shrinks to AR, WI, ID, IA
##############################################################################

source("00_packages.R")

cat("=== Cleaning ACS PUMS data ===\n")

# Load raw data
df_raw <- fread(file.path(data_dir, "acs_pums_raw.csv"))
treatment_dates <- fread(file.path(data_dir, "treatment_dates.csv"))

cat(sprintf("Raw data: %d rows\n", nrow(df_raw)))

# Fix duplicate column names from Census API
# AGEP and SEX appear twice (as GET vars and predicate duplicates)
names(df_raw) <- gsub("\\.\\.\\.[0-9]+$", "", names(df_raw))
# Remove duplicate columns
df_raw <- df_raw[, !duplicated(names(df_raw)), with = FALSE]

cat(sprintf("Columns after dedup: %s\n", paste(names(df_raw), collapse = ", ")))

# =========================================================
# Construct outcome variables
# =========================================================

df <- df_raw %>%
  mutate(
    # Insurance outcomes (ACS codes: 1=Yes, 2=No)
    medicaid = as.integer(HINS4 == 1),
    uninsured = as.integer(HICOV == 2),
    employer_ins = as.integer(HINS1 == 1),
    private_ins = as.integer(HINS2 == 1),
    any_private = as.integer(HINS1 == 1 | HINS2 == 1),
    any_public = as.integer(HINS4 == 1 | HINS3 == 1 | HINS5 == 1),

    # Postpartum indicator
    postpartum = as.integer(FER == 1),

    # Demographics
    age = AGEP,
    state_fips = ST,

    # Income categories
    low_income = as.integer(POVPIP <= 200),   # Below 200% FPL
    very_low_income = as.integer(POVPIP <= 138), # Below 138% FPL (Medicaid expansion threshold)
    high_income = as.integer(POVPIP > 400),   # Above 400% FPL (placebo group)

    # Race/ethnicity
    race_eth = case_when(
      HISP > 1 ~ "Hispanic",
      RAC1P == 1 ~ "White NH",
      RAC1P == 2 ~ "Black NH",
      RAC1P == 6 ~ "Asian NH",
      TRUE ~ "Other NH"
    ),

    # Education
    educ = case_when(
      SCHL <= 15 ~ "Less than HS",
      SCHL >= 16 & SCHL <= 17 ~ "HS diploma",
      SCHL >= 18 & SCHL <= 20 ~ "Some college",
      SCHL >= 21 ~ "BA or higher"
    ),

    # Marital status
    married = as.integer(MAR == 1),

    # Weight
    weight = PWGTP
  )

# =========================================================
# Merge treatment status
# =========================================================

# Create state-level treatment indicator
df <- df %>%
  left_join(
    treatment_dates %>% select(state_fips, adopt_year, state_abbr),
    by = "state_fips"
  ) %>%
  mutate(
    # Maximum year in sample (auto-updates to 2024 with new data)
    max_sample_year = max(year),

    # Treatment: state has adopted by this year AND adoption is within sample
    treated = as.integer(!is.na(adopt_year) & adopt_year <= max_sample_year & year >= adopt_year),

    # For CS-DiD: first_treat = adoption year, 0 = never/not-yet treated
    # States adopting AFTER the last sample year are coded as not-yet-treated (0)
    first_treat = ifelse(is.na(adopt_year) | adopt_year > max_sample_year, 0, adopt_year),

    # PHE period indicator (March 2020 - May 2023, using calendar years)
    phe_period = as.integer(year >= 2020 & year <= 2022),

    # Post-PHE indicator
    post_phe = as.integer(year >= 2023),

    # Clean treatment: adopted AND post-PHE (when extension has bite)
    treated_post_phe = as.integer(treated == 1 & post_phe == 1),

    # CHANGE: Fill in state abbreviation for never-treated AND 2025 adopters
    state_abbr = ifelse(is.na(state_abbr),
                        case_when(
                          state_fips == 5 ~ "AR",
                          state_fips == 55 ~ "WI",
                          state_fips == 16 ~ "ID",
                          state_fips == 19 ~ "IA",
                          TRUE ~ paste0("ST", state_fips)
                        ),
                        state_abbr)
  )

cat(sprintf("After cleaning: %d rows\n", nrow(df)))
cat(sprintf("Max sample year: %d\n", max(df$year)))
cat(sprintf("Years in sample: %s\n", paste(sort(unique(df$year)), collapse = ", ")))

# Report treatment group sizes
cat("\n--- Treatment Group Sizes ---\n")
cat(sprintf("Treated states (adopted <= %d): %d\n",
            max(df$year),
            n_distinct(df$state_fips[df$first_treat > 0])))
cat(sprintf("Control states (never/not-yet-treated): %d\n",
            n_distinct(df$state_fips[df$first_treat == 0])))
cat(sprintf("  Never-treated (AR, WI): 2\n"))
cat(sprintf("  Not-yet-treated (2025 adopters: ID, IA): %d\n",
            n_distinct(df$state_fips[is.na(df$adopt_year) | df$adopt_year > max(df$year)])))

# =========================================================
# Create analysis samples
# =========================================================

# Sample 1: Postpartum women (FER=1, primary sample)
df_postpartum <- df %>% filter(postpartum == 1)
cat(sprintf("\nPostpartum sample: %d rows\n", nrow(df_postpartum)))

# Sample 2: Low-income postpartum women (most affected)
df_pp_lowinc <- df_postpartum %>% filter(low_income == 1)
cat(sprintf("Low-income postpartum: %d rows\n", nrow(df_pp_lowinc)))

# Sample 3: High-income postpartum women (placebo)
df_pp_highinc <- df_postpartum %>% filter(high_income == 1)
cat(sprintf("High-income postpartum (placebo): %d rows\n", nrow(df_pp_highinc)))

# Sample 4: Non-postpartum women (for DDD placebo population)
df_nonpostpartum <- df %>% filter(postpartum == 0) %>%
  filter(low_income == 1)  # Match on income
cat(sprintf("Non-postpartum low-income (DDD comparator): %d rows\n", nrow(df_nonpostpartum)))

# =========================================================
# Create state-year panel (for aggregate analysis)
# =========================================================

state_year_pp <- df_postpartum %>%
  group_by(state_fips, state_abbr, year, first_treat, treated) %>%
  summarise(
    medicaid_rate = weighted.mean(medicaid, weight, na.rm = TRUE),
    uninsured_rate = weighted.mean(uninsured, weight, na.rm = TRUE),
    employer_rate = weighted.mean(employer_ins, weight, na.rm = TRUE),
    private_rate = weighted.mean(any_private, weight, na.rm = TRUE),
    n_obs = n(),
    total_weight = sum(weight, na.rm = TRUE),
    mean_age = weighted.mean(age, weight, na.rm = TRUE),
    pct_married = weighted.mean(married, weight, na.rm = TRUE),
    pct_white = weighted.mean(race_eth == "White NH", weight, na.rm = TRUE),
    pct_black = weighted.mean(race_eth == "Black NH", weight, na.rm = TRUE),
    pct_hispanic = weighted.mean(race_eth == "Hispanic", weight, na.rm = TRUE),
    pct_ba = weighted.mean(educ == "BA or higher", weight, na.rm = TRUE),
    pct_low_income = weighted.mean(low_income, weight, na.rm = TRUE),
    .groups = "drop"
  )

# Low-income postpartum state-year panel
state_year_pp_low <- df_pp_lowinc %>%
  group_by(state_fips, state_abbr, year, first_treat, treated) %>%
  summarise(
    medicaid_rate = weighted.mean(medicaid, weight, na.rm = TRUE),
    uninsured_rate = weighted.mean(uninsured, weight, na.rm = TRUE),
    employer_rate = weighted.mean(employer_ins, weight, na.rm = TRUE),
    n_obs = n(),
    total_weight = sum(weight, na.rm = TRUE),
    .groups = "drop"
  )

# Non-postpartum low-income state-year panel (for DDD)
state_year_nonpp_low <- df_nonpostpartum %>%
  group_by(state_fips, state_abbr, year, first_treat, treated) %>%
  summarise(
    medicaid_rate = weighted.mean(medicaid, weight, na.rm = TRUE),
    uninsured_rate = weighted.mean(uninsured, weight, na.rm = TRUE),
    employer_rate = weighted.mean(employer_ins, weight, na.rm = TRUE),
    n_obs = n(),
    total_weight = sum(weight, na.rm = TRUE),
    .groups = "drop"
  )

cat(sprintf("\nState-year panel (all postpartum): %d rows, %d states\n",
            nrow(state_year_pp), n_distinct(state_year_pp$state_fips)))
cat(sprintf("State-year panel (low-income pp): %d rows, %d states\n",
            nrow(state_year_pp_low), n_distinct(state_year_pp_low$state_fips)))
cat(sprintf("State-year panel (non-pp low-income): %d rows, %d states\n",
            nrow(state_year_nonpp_low), n_distinct(state_year_nonpp_low$state_fips)))

# =========================================================
# Save cleaned data
# =========================================================

fwrite(df, file.path(data_dir, "acs_clean.csv"))
fwrite(df_postpartum, file.path(data_dir, "acs_postpartum.csv"))
fwrite(df_pp_lowinc, file.path(data_dir, "acs_postpartum_lowinc.csv"))
fwrite(df_pp_highinc, file.path(data_dir, "acs_postpartum_highinc.csv"))
fwrite(df_nonpostpartum, file.path(data_dir, "acs_nonpostpartum_lowinc.csv"))
fwrite(state_year_pp, file.path(data_dir, "state_year_postpartum.csv"))
fwrite(state_year_pp_low, file.path(data_dir, "state_year_postpartum_lowinc.csv"))
fwrite(state_year_nonpp_low, file.path(data_dir, "state_year_nonpp_lowinc.csv"))

cat("\n=== Data cleaning complete ===\n")

# Summary statistics
cat("\n--- Summary: Postpartum women ---\n")
cat(sprintf("Years: %d - %d\n", min(df_postpartum$year), max(df_postpartum$year)))
cat(sprintf("States: %d\n", n_distinct(df_postpartum$state_fips)))
cat(sprintf("Total N: %d\n", nrow(df_postpartum)))
cat(sprintf("Mean Medicaid rate: %.1f%%\n", 100 * weighted.mean(df_postpartum$medicaid, df_postpartum$weight, na.rm = TRUE)))
cat(sprintf("Mean uninsured rate: %.1f%%\n", 100 * weighted.mean(df_postpartum$uninsured, df_postpartum$weight, na.rm = TRUE)))
cat(sprintf("Mean employer ins rate: %.1f%%\n", 100 * weighted.mean(df_postpartum$employer_ins, df_postpartum$weight, na.rm = TRUE)))
