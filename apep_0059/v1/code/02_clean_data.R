# =============================================================================
# 02_clean_data.R
# Clean data and construct analysis variables
# =============================================================================

source("00_packages.R")

# Load raw data
pums_raw <- readRDS(file.path(data_dir, "pums_raw_2018_2022.rds"))

cat("Raw data loaded:", nrow(pums_raw), "observations\n")

# =============================================================================
# Sample Restrictions
# =============================================================================

pums <- pums_raw %>%
  mutate(
    # Convert to numeric
    AGEP = as.numeric(AGEP),
    COW = as.character(COW),
    ESR = as.character(ESR),
    PWGTP = as.numeric(PWGTP)
  ) %>%
  filter(
    # Working age (25-64, pre-Medicare)
    AGEP >= 25 & AGEP <= 64,

    # Employed (at work or with job but not at work)
    ESR %in% c("1", "2"),

    # Valid class of worker (exclude unemployed/never worked)
    COW %in% c("1", "2", "3", "4", "5", "6", "7"),

    # Positive weight
    PWGTP > 0
  )

cat("After sample restrictions:", nrow(pums), "observations\n")

# =============================================================================
# Treatment Definition
# =============================================================================

pums <- pums %>%
  mutate(
    # Self-employed = COW 6 (unincorporated) or 7 (incorporated)
    self_employed = as.integer(COW %in% c("6", "7")),

    # Self-employment type
    se_type = case_when(
      COW == "7" ~ "Incorporated",
      COW == "6" ~ "Unincorporated",
      TRUE ~ "Wage Worker"
    )
  )

cat("\nTreatment distribution:\n")
print(table(pums$self_employed))
cat("Self-employment rate:", round(100 * mean(pums$self_employed), 2), "%\n")

# =============================================================================
# Outcome Variables
# =============================================================================

pums <- pums %>%
  mutate(
    # Health insurance outcomes
    any_insurance = as.integer(HICOV == "1"),
    private_coverage = as.integer(PRIVCOV == "1"),
    public_coverage = as.integer(PUBCOV == "1"),
    employer_insurance = as.integer(HINS1 == "1"),
    direct_purchase = as.integer(HINS2 == "1"),
    medicare = as.integer(HINS3 == "1"),
    medicaid = as.integer(HINS4 == "1"),
    tricare = as.integer(HINS5 == "1"),
    va_coverage = as.integer(HINS6 == "1")
  )

cat("\nOutcome distributions:\n")
cat("Any insurance:", round(100 * mean(pums$any_insurance, na.rm = TRUE), 2), "%\n")
cat("Employer insurance:", round(100 * mean(pums$employer_insurance, na.rm = TRUE), 2), "%\n")
cat("Direct purchase:", round(100 * mean(pums$direct_purchase, na.rm = TRUE), 2), "%\n")
cat("Medicaid:", round(100 * mean(pums$medicaid, na.rm = TRUE), 2), "%\n")

# =============================================================================
# Covariate Construction
# =============================================================================

pums <- pums %>%
  mutate(
    # Demographics
    age = AGEP,
    age_sq = AGEP^2,
    female = as.integer(SEX == "2"),

    # Race/ethnicity
    race = case_when(
      HISP != "01" ~ "Hispanic",
      RAC1P == "1" ~ "White",
      RAC1P == "2" ~ "Black",
      RAC1P %in% c("6", "7") ~ "Asian",
      TRUE ~ "Other"
    ),

    # Education
    educ = case_when(
      as.numeric(SCHL) < 16 ~ "Less than HS",
      as.numeric(SCHL) %in% 16:17 ~ "High School",
      as.numeric(SCHL) %in% 18:20 ~ "Some College",
      as.numeric(SCHL) == 21 ~ "Bachelor's",
      as.numeric(SCHL) >= 22 ~ "Graduate",
      TRUE ~ "Unknown"
    ),

    # Marital status
    married = as.integer(MAR == "1"),
    married_spouse_present = as.integer(MSP == "1"),

    # Household
    household_size = pmin(as.numeric(NP), 10),  # Top-code at 10
    has_children = as.integer(PAOC != "4"),

    # Labor market
    hours_worked = pmin(as.numeric(WKHP), 80),  # Top-code at 80
    weeks_worked = as.numeric(WKWN),
    hours_worked_sq = hours_worked^2,

    # Household income (quintiles)
    hinc = as.numeric(HINCP)
  )

# Create income quintiles
pums <- pums %>%
  mutate(
    income_quintile = ntile(hinc, 5),
    income_quintile = factor(income_quintile, levels = 1:5,
                              labels = c("Q1 (Lowest)", "Q2", "Q3", "Q4", "Q5 (Highest)"))
  )

# Occupation categories (2-digit SOC)
pums <- pums %>%
  mutate(
    occ_2digit = substr(OCCP, 1, 2),
    occ_category = case_when(
      occ_2digit %in% c("11", "13") ~ "Management/Business",
      occ_2digit %in% c("15", "17", "19") ~ "STEM",
      occ_2digit %in% c("21", "23", "25", "27") ~ "Education/Legal/Arts",
      occ_2digit %in% c("29", "31") ~ "Healthcare",
      occ_2digit %in% c("33", "35", "37") ~ "Service",
      occ_2digit %in% c("41", "43") ~ "Sales/Office",
      occ_2digit %in% c("45", "47", "49") ~ "Blue Collar",
      occ_2digit %in% c("51", "53") ~ "Production/Transport",
      TRUE ~ "Other"
    )
  )

# Industry categories (2-digit NAICS)
pums <- pums %>%
  mutate(
    ind_2digit = substr(INDP, 1, 2),
    ind_category = case_when(
      INDP %in% c("0170", "0180", "0190", "0270", "0280", "0290") ~ "Agriculture/Mining",
      ind_2digit == "23" ~ "Construction",
      ind_2digit %in% c("31", "32", "33") ~ "Manufacturing",
      ind_2digit %in% c("42", "44", "45") ~ "Wholesale/Retail",
      ind_2digit %in% c("48", "49") ~ "Transportation",
      ind_2digit == "51" ~ "Information",
      ind_2digit %in% c("52", "53") ~ "Finance/Real Estate",
      ind_2digit %in% c("54", "55", "56") ~ "Professional Services",
      ind_2digit %in% c("61", "62") ~ "Education/Healthcare",
      ind_2digit %in% c("71", "72") ~ "Leisure/Hospitality",
      ind_2digit %in% c("81", "92") ~ "Other Services/Government",
      TRUE ~ "Other"
    )
  )

# State factor
pums <- pums %>%
  mutate(
    state = factor(ST),
    medicaid_expanded = as.integer(expanded == TRUE)
  )

# =============================================================================
# Final Variable Selection
# =============================================================================

# Define covariate sets
demographic_vars <- c("age", "age_sq", "female", "race", "educ",
                       "married", "married_spouse_present")
household_vars <- c("household_size", "has_children", "income_quintile")
labor_vars <- c("hours_worked", "hours_worked_sq", "occ_category", "ind_category")
geo_vars <- c("state", "medicaid_expanded")

all_covariates <- c(demographic_vars, household_vars, labor_vars, geo_vars)

# Select final analysis sample (complete cases for key variables)
pums_clean <- pums %>%
  select(
    # ID variables
    YEAR, ST, PUMA, PWGTP,

    # Treatment
    self_employed, se_type, COW,

    # Outcomes
    any_insurance, private_coverage, public_coverage,
    employer_insurance, direct_purchase, medicare, medicaid,
    tricare, va_coverage,

    # Covariates
    all_of(c(demographic_vars, household_vars, labor_vars)),
    state, medicaid_expanded, expanded
  ) %>%
  filter(complete.cases(.))

cat("\n=== Final Analysis Sample ===\n")
cat("Observations:", nrow(pums_clean), "\n")
cat("Self-employed:", sum(pums_clean$self_employed), "\n")
cat("Wage workers:", sum(1 - pums_clean$self_employed), "\n")

# =============================================================================
# Save Clean Data
# =============================================================================

saveRDS(pums_clean, file.path(data_dir, "pums_clean.rds"))

cat("\nClean data saved to:", file.path(data_dir, "pums_clean.rds"), "\n")

# =============================================================================
# Summary Statistics
# =============================================================================

cat("\n=== Variable Distributions ===\n")

cat("\nSelf-employment by type:\n")
print(table(pums_clean$se_type))

cat("\nEducation:\n")
print(prop.table(table(pums_clean$educ)))

cat("\nRace/ethnicity:\n")
print(prop.table(table(pums_clean$race)))

cat("\nMedicaid expansion status:\n")
print(table(pums_clean$medicaid_expanded))

cat("\n=== Insurance by Self-Employment ===\n")
pums_clean %>%
  group_by(self_employed) %>%
  summarise(
    n = n(),
    any_insurance = mean(any_insurance),
    employer_insurance = mean(employer_insurance),
    direct_purchase = mean(direct_purchase),
    medicaid = mean(medicaid),
    .groups = "drop"
  ) %>%
  print()
