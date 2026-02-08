# =============================================================================
# Paper 72: Process Natality Data
# =============================================================================
# Reads and processes CDC/NCHS natality data for RDD analysis
# Key variables: mother's age, payment source
# =============================================================================

library(tidyverse)
library(data.table)

# Directories
data_dir <- "output/paper_72/data"
output_dir <- "output/paper_72/data"

# =============================================================================
# Read natality data
# =============================================================================

# List available data files
data_files <- list.files(data_dir, pattern = "natality.*us\\.csv$", full.names = TRUE)
cat("Found data files:\n")
print(data_files)

if (length(data_files) == 0) {
  stop("No data files found. Run 01_download_natality.R first.")
}

# Read and combine all years
# Use data.table for speed with large files
cat("\nReading data files (this may take several minutes for large files)...\n")

read_natality_year <- function(filepath) {
  cat(sprintf("  Reading: %s\n", basename(filepath)))

  # Use fread for speed
  dt <- fread(
    filepath,
    select = c(
      "dob_yy",      # Year of birth
      "mager",       # Mother's age (single years, 12-50)
      "pay",         # Source of payment (1=Medicaid, 2=Private, etc.)
      "pay_rec",     # Payment source recode
      "meduc",       # Mother's education
      "mrace6",      # Mother's race (6 categories)
      "mracehisp",   # Mother's race/Hispanic origin
      "dmar",        # Marital status
      "lbo_rec",     # Live birth order
      "precare",     # Month prenatal care began
      "previs",      # Number of prenatal visits
      "priorlive",   # Prior live births
      "priordead",   # Prior deaths
      "bmi",         # Mother's BMI
      "illb_r"       # Interval since last live birth
    ),
    showProgress = TRUE
  )

  # Extract year from filename if dob_yy is missing
  year <- as.integer(str_extract(basename(filepath), "\\d{4}"))
  if (!"dob_yy" %in% names(dt) || all(is.na(dt$dob_yy))) {
    dt$dob_yy <- year
  }

  return(dt)
}

# Read all files
all_data <- rbindlist(lapply(data_files, read_natality_year))

cat(sprintf("\nTotal observations: %s\n", format(nrow(all_data), big.mark = ",")))

# =============================================================================
# Clean and recode variables
# =============================================================================

cat("\nCleaning data...\n")

# Create analysis dataset
analysis_data <- all_data %>%
  as_tibble() %>%
  rename(
    year = dob_yy,
    mother_age = mager,
    payment = pay,
    payment_recode = pay_rec,
    education = meduc,
    race = mrace6,
    race_hisp = mracehisp,
    marital = dmar,
    birth_order = lbo_rec,
    prenatal_month = precare,
    prenatal_visits = previs,
    prior_live = priorlive,
    prior_dead = priordead,
    mother_bmi = bmi,
    birth_interval = illb_r
  ) %>%
  mutate(
    # Payment source categories
    # Standard coding: 1=Medicaid, 2=Private Insurance, 3=Self-pay, 4=Other, 9=Unknown
    medicaid = case_when(
      payment_recode == 1 ~ 1,
      payment_recode %in% c(2, 3, 4) ~ 0,
      TRUE ~ NA_real_
    ),
    private = case_when(
      payment_recode == 2 ~ 1,
      payment_recode %in% c(1, 3, 4) ~ 0,
      TRUE ~ NA_real_
    ),
    self_pay = case_when(
      payment_recode == 3 ~ 1,
      payment_recode %in% c(1, 2, 4) ~ 0,
      TRUE ~ NA_real_
    ),
    other_pay = case_when(
      payment_recode == 4 ~ 1,
      payment_recode %in% c(1, 2, 3) ~ 0,
      TRUE ~ NA_real_
    ),

    # Payment category labels
    payment_cat = factor(
      payment_recode,
      levels = c(1, 2, 3, 4, 9),
      labels = c("Medicaid", "Private", "Self-pay", "Other", "Unknown")
    ),

    # Education categories
    education_cat = case_when(
      education %in% 1:2 ~ "Less than HS",
      education == 3 ~ "High school",
      education %in% 4:5 ~ "Some college",
      education %in% 6:8 ~ "BA or higher",
      TRUE ~ "Unknown"
    ),
    education_cat = factor(education_cat,
      levels = c("Less than HS", "High school", "Some college", "BA or higher", "Unknown")),

    # Marital status
    married = case_when(
      marital == 1 ~ 1,
      marital == 2 ~ 0,
      TRUE ~ NA_real_
    ),

    # Race/ethnicity
    race_eth = case_when(
      race_hisp == 1 ~ "White NH",
      race_hisp == 2 ~ "Black NH",
      race_hisp == 3 ~ "AIAN NH",
      race_hisp == 4 ~ "Asian NH",
      race_hisp == 5 ~ "NHOPI NH",
      race_hisp == 6 ~ "More than one NH",
      race_hisp == 7 ~ "Hispanic",
      TRUE ~ "Unknown"
    ),
    race_eth = factor(race_eth),

    # First birth indicator
    first_birth = ifelse(birth_order == 1, 1, 0),

    # Adequate prenatal care (started in first trimester)
    early_prenatal = case_when(
      prenatal_month %in% 1:3 ~ 1,
      prenatal_month %in% 4:10 ~ 0,
      TRUE ~ NA_real_
    )
  )

# =============================================================================
# Restrict sample for RDD analysis
# =============================================================================

cat("\nApplying sample restrictions...\n")

# Restriction 1: Mother's age 20-32 (wide RD window)
# Restriction 2: Known payment source
# Restriction 3: Post-ACA (2011+)

rdd_sample <- analysis_data %>%
  filter(
    mother_age >= 20 & mother_age <= 32,  # RD window
    !is.na(medicaid),                       # Known payment source
    year >= 2011                            # Post-ACA
  )

cat(sprintf("Analysis sample: %s observations\n", format(nrow(rdd_sample), big.mark = ",")))

# =============================================================================
# Aggregate to age-year level for RD analysis
# =============================================================================

cat("\nAggregating to age-year level...\n")

agg_by_age_year <- rdd_sample %>%
  group_by(year, mother_age) %>%
  summarise(
    n_births = n(),
    medicaid_share = mean(medicaid, na.rm = TRUE),
    private_share = mean(private, na.rm = TRUE),
    self_pay_share = mean(self_pay, na.rm = TRUE),
    other_share = mean(other_pay, na.rm = TRUE),
    married_share = mean(married, na.rm = TRUE),
    first_birth_share = mean(first_birth, na.rm = TRUE),
    early_prenatal_share = mean(early_prenatal, na.rm = TRUE),
    .groups = "drop"
  )

# Also aggregate just by age (pooled across years)
agg_by_age <- rdd_sample %>%
  group_by(mother_age) %>%
  summarise(
    n_births = n(),
    medicaid_share = mean(medicaid, na.rm = TRUE),
    private_share = mean(private, na.rm = TRUE),
    self_pay_share = mean(self_pay, na.rm = TRUE),
    other_share = mean(other_pay, na.rm = TRUE),
    married_share = mean(married, na.rm = TRUE),
    first_birth_share = mean(first_birth, na.rm = TRUE),
    early_prenatal_share = mean(early_prenatal, na.rm = TRUE),
    .groups = "drop"
  )

# =============================================================================
# Save processed data
# =============================================================================

cat("\nSaving processed data...\n")

# Save individual-level data (for robustness checks)
saveRDS(rdd_sample, file.path(output_dir, "rdd_sample.rds"))

# Save aggregated data
saveRDS(agg_by_age_year, file.path(output_dir, "agg_by_age_year.rds"))
saveRDS(agg_by_age, file.path(output_dir, "agg_by_age.rds"))

# Also save as CSV for inspection
write_csv(agg_by_age_year, file.path(output_dir, "agg_by_age_year.csv"))
write_csv(agg_by_age, file.path(output_dir, "agg_by_age.csv"))

cat("=============================================================================\n")
cat("Data processing complete!\n")
cat("Files saved:\n")
cat("  - rdd_sample.rds (individual-level)\n")
cat("  - agg_by_age_year.rds/csv (age x year aggregates)\n")
cat("  - agg_by_age.rds/csv (age aggregates, pooled)\n")
cat("=============================================================================\n")

# Print summary statistics
cat("\nSummary: Births by Mother's Age (Pooled)\n")
print(agg_by_age, n = 20)

cat("\nMedicaid share by age:\n")
agg_by_age %>%
  select(mother_age, n_births, medicaid_share) %>%
  print(n = 20)
