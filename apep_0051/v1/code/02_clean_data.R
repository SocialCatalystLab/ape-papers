# Paper 67: Aging Out at 26 and Fertility
# 02_clean_data.R - Clean and prepare ACS PUMS data for analysis

source("output/paper_67/code/00_packages.R")

# Load raw data
cat("Loading raw data...\n")
raw_data <- readRDS("output/paper_67/data/acs_pums_raw.rds")

cat(sprintf("Raw data: %s observations\n", format(nrow(raw_data), big.mark = ",")))
cat(sprintf("Columns: %s\n", paste(names(raw_data), collapse = ", ")))

# Fix duplicate column names from Census API
# Keep only the first occurrence of AGEP and SEX
names_to_keep <- c("PWGTP", "AGEP...2", "SEX...3", "FER", "HICOV", "PRIVCOV",
                   "PUBCOV", "MAR", "RAC1P", "HISP", "SCHL", "CIT", "NATIVITY",
                   "ST", "POVPIP", "year")

# Select and rename columns
clean_data <- raw_data %>%
  select(any_of(names_to_keep)) %>%
  rename_with(~ gsub("\\.\\.\\.[0-9]+", "", .), everything())

# Convert to numeric
numeric_cols <- c("PWGTP", "AGEP", "SEX", "FER", "HICOV", "PRIVCOV", "PUBCOV",
                  "MAR", "RAC1P", "HISP", "SCHL", "CIT", "NATIVITY", "ST", "POVPIP")
for (col in numeric_cols) {
  if (col %in% names(clean_data)) {
    clean_data[[col]] <- as.numeric(clean_data[[col]])
  }
}

cat(sprintf("After column fix: %s observations\n", format(nrow(clean_data), big.mark = ",")))

# Create analysis variables
cat("Creating analysis variables...\n")

analysis_data <- clean_data %>%
  filter(
    !is.na(AGEP),           # Valid age
    AGEP >= 22 & AGEP <= 30  # Age range for analysis
  ) %>%
  mutate(
    # Outcome: Gave birth in past 12 months (1=Yes)
    gave_birth = ifelse(FER == 1, 1, 0),

    # Treatment/mechanism: Insurance coverage
    has_insurance = ifelse(HICOV == 1, 1, 0),
    has_private = ifelse(PRIVCOV == 1, 1, 0),
    has_public = ifelse(PUBCOV == 1, 1, 0),

    # Running variable: Age centered at 26
    age_centered = AGEP - 26,

    # Marital status
    married = ifelse(MAR == 1, 1, 0),

    # Race/ethnicity
    race_eth = case_when(
      HISP != 1 ~ "Hispanic",
      RAC1P == 1 ~ "White",
      RAC1P == 2 ~ "Black",
      RAC1P %in% c(6, 7) ~ "Asian",
      TRUE ~ "Other"
    ),

    # Education (simplified)
    college = ifelse(SCHL >= 21, 1, 0),  # Bachelor's degree or higher
    high_school = ifelse(SCHL >= 16, 1, 0),  # High school or higher

    # Citizenship
    citizen = ifelse(CIT %in% c(1, 2, 3, 4), 1, 0),

    # Nativity
    native_born = ifelse(NATIVITY == 1, 1, 0),

    # Poverty status
    poverty_ratio = POVPIP,
    below_poverty = ifelse(POVPIP < 100, 1, 0),

    # Survey weight
    weight = PWGTP,

    # State FIPS
    state_fips = ST
  )

cat(sprintf("After filtering and variable creation: %s observations\n",
            format(nrow(analysis_data), big.mark = ",")))

# Summary statistics by age
cat("\n=== Summary by Age ===\n")
age_summary <- analysis_data %>%
  group_by(AGEP) %>%
  summarise(
    n = n(),
    n_weighted = sum(weight, na.rm = TRUE),
    pct_gave_birth = weighted.mean(gave_birth, weight, na.rm = TRUE) * 100,
    pct_insured = weighted.mean(has_insurance, weight, na.rm = TRUE) * 100,
    pct_private = weighted.mean(has_private, weight, na.rm = TRUE) * 100,
    pct_married = weighted.mean(married, weight, na.rm = TRUE) * 100,
    .groups = "drop"
  )

print(age_summary)

# Key discontinuity check at age 26
cat("\n=== Discontinuity Check at Age 26 ===\n")
age_25_26 <- analysis_data %>%
  filter(AGEP %in% c(25, 26)) %>%
  group_by(AGEP) %>%
  summarise(
    pct_gave_birth = weighted.mean(gave_birth, weight, na.rm = TRUE) * 100,
    pct_insured = weighted.mean(has_insurance, weight, na.rm = TRUE) * 100,
    pct_private = weighted.mean(has_private, weight, na.rm = TRUE) * 100,
    .groups = "drop"
  )

print(age_25_26)

# Calculate raw discontinuities
cat("\n=== Raw Discontinuities (Age 26 - Age 25) ===\n")
disc_birth <- age_25_26$pct_gave_birth[age_25_26$AGEP == 26] -
              age_25_26$pct_gave_birth[age_25_26$AGEP == 25]
disc_insured <- age_25_26$pct_insured[age_25_26$AGEP == 26] -
                age_25_26$pct_insured[age_25_26$AGEP == 25]
disc_private <- age_25_26$pct_private[age_25_26$AGEP == 26] -
                age_25_26$pct_private[age_25_26$AGEP == 25]

cat(sprintf("Birth rate change: %.2f pp\n", disc_birth))
cat(sprintf("Insurance coverage change: %.2f pp\n", disc_insured))
cat(sprintf("Private insurance change: %.2f pp\n", disc_private))

# Add Medicaid expansion status (for heterogeneity)
# States that expanded by 2014: AZ, AR, CA, CO, CT, DE, HI, IL, IA, KY,
# MD, MA, MI, MN, NV, NH, NJ, NM, NY, ND, OH, OR, RI, VT, WA, WV, DC
expansion_states <- c(4, 5, 6, 8, 9, 10, 15, 17, 19, 21,
                      24, 25, 26, 27, 32, 33, 34, 35, 36, 38,
                      39, 41, 44, 50, 53, 54, 11)

analysis_data <- analysis_data %>%
  mutate(
    medicaid_expansion = ifelse(state_fips %in% expansion_states, 1, 0)
  )

# Save cleaned data
cat("\nSaving cleaned data...\n")
saveRDS(analysis_data, "output/paper_67/data/analysis_data.rds")
cat("Data saved to output/paper_67/data/analysis_data.rds\n")

# Save summary for reference
write.csv(age_summary, "output/paper_67/data/age_summary.csv", row.names = FALSE)

cat("\nData cleaning complete.\n")
cat(sprintf("Final sample: %s observations\n", format(nrow(analysis_data), big.mark = ",")))
cat(sprintf("Years: %s\n", paste(sort(unique(analysis_data$year)), collapse = ", ")))
