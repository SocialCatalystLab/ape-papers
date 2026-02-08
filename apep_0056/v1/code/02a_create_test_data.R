# =============================================================================
# Paper 72: Create Test Data for Pipeline Development
# =============================================================================
# Creates simulated data matching the structure of CDC natality data
# to test the analysis pipeline while real data downloads
#
# NOTE: This is FOR PIPELINE TESTING ONLY - final analysis uses real data
# =============================================================================

library(tidyverse)

set.seed(72)

# Output directory
data_dir <- "output/paper_72/data"
dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)

cat("Creating test data for pipeline development...\n")
cat("NOTE: This is simulated data - final analysis uses real CDC natality data.\n\n")

# =============================================================================
# Generate test data
# =============================================================================

n_obs <- 1000000  # 1 million observations

# Generate ages 20-32 with realistic distribution (bell curve around 27-28)
ages <- sample(20:32, n_obs, replace = TRUE,
               prob = c(0.02, 0.03, 0.05, 0.07, 0.09, 0.11, 0.12,  # 20-26
                        0.13, 0.12, 0.10, 0.08, 0.05, 0.03))       # 27-32

# Create treatment indicator
above_26 <- ifelse(ages >= 26, 1, 0)

# Baseline probabilities (roughly matching real data patterns)
# Medicaid share decreases with age (younger mothers more likely on Medicaid)
# But INCREASES at 26 due to losing private coverage

# Latent index for Medicaid (base probability around 40%)
base_medicaid_prob <- 0.45 - 0.015 * (ages - 26)  # Age gradient

# Add discontinuity at 26: ~5pp increase in Medicaid at 26
medicaid_prob <- base_medicaid_prob + 0.05 * above_26

# Add noise
medicaid_prob <- pmin(pmax(medicaid_prob + rnorm(n_obs, 0, 0.05), 0.1), 0.8)

# Generate Medicaid indicator
medicaid <- rbinom(n_obs, 1, medicaid_prob)

# Private insurance (complementary pattern - only for non-Medicaid)
# Among non-Medicaid, private decreases at 26 (some go to self-pay)
private_given_no_medicaid <- 0.85 - 0.06 * above_26
private <- ifelse(medicaid == 0, rbinom(n_obs, 1, private_given_no_medicaid), 0)

# Self-pay (residual)
self_pay <- ifelse(medicaid == 0 & private == 0, 1, 0)

# Covariates
# Education (higher with age)
education_prob <- pmin(0.3 + 0.02 * (ages - 20), 0.7)
ba_or_higher <- rbinom(n_obs, 1, education_prob)

# Married (increases with age, might increase at 26 as mechanism)
married_base <- 0.35 + 0.025 * (ages - 20)
married_effect_26 <- 0.02 * above_26  # Small mechanism effect
married_prob <- pmin(married_base + married_effect_26, 0.85)
married <- rbinom(n_obs, 1, married_prob)

# First birth (decreases with age)
first_birth_prob <- pmax(0.6 - 0.04 * (ages - 20), 0.2)
first_birth <- rbinom(n_obs, 1, first_birth_prob)

# Early prenatal care (no discontinuity - balance test)
early_prenatal_prob <- 0.75 + 0.01 * (ages - 26)  # No discontinuity at 26
early_prenatal <- rbinom(n_obs, 1, pmin(early_prenatal_prob, 0.95))

# Race/ethnicity
race_probs <- c(0.50, 0.15, 0.02, 0.08, 0.01, 0.02, 0.22)  # Rough US distribution
race_eth <- sample(
  c("White NH", "Black NH", "AIAN NH", "Asian NH", "NHOPI NH", "More than one NH", "Hispanic"),
  n_obs, replace = TRUE, prob = race_probs
)

# Years (2016-2022)
years <- sample(2016:2022, n_obs, replace = TRUE)

# =============================================================================
# Create analysis dataset
# =============================================================================

test_data <- tibble(
  year = years,
  mother_age = ages,
  medicaid = medicaid,
  private = private,
  self_pay = self_pay,
  other_pay = 0,  # Simplified
  married = married,
  first_birth = first_birth,
  early_prenatal = early_prenatal,
  race_eth = race_eth,
  education_cat = ifelse(ba_or_higher, "BA or higher", "Less than BA"),
  above_26 = above_26,
  age_centered = ages - 26
)

cat(sprintf("Created %s test observations\n", format(nrow(test_data), big.mark = ",")))

# =============================================================================
# Aggregate to age level
# =============================================================================

agg_by_age <- test_data %>%
  group_by(mother_age) %>%
  summarise(
    n_births = n(),
    medicaid_share = mean(medicaid),
    private_share = mean(private),
    self_pay_share = mean(self_pay),
    other_share = mean(other_pay),
    married_share = mean(married),
    first_birth_share = mean(first_birth),
    early_prenatal_share = mean(early_prenatal),
    .groups = "drop"
  )

agg_by_age_year <- test_data %>%
  group_by(year, mother_age) %>%
  summarise(
    n_births = n(),
    medicaid_share = mean(medicaid),
    private_share = mean(private),
    self_pay_share = mean(self_pay),
    other_share = mean(other_pay),
    married_share = mean(married),
    first_birth_share = mean(first_birth),
    early_prenatal_share = mean(early_prenatal),
    .groups = "drop"
  )

# =============================================================================
# Save test data
# =============================================================================

saveRDS(test_data, file.path(data_dir, "rdd_sample.rds"))
saveRDS(agg_by_age, file.path(data_dir, "agg_by_age.rds"))
saveRDS(agg_by_age_year, file.path(data_dir, "agg_by_age_year.rds"))

write_csv(agg_by_age, file.path(data_dir, "agg_by_age.csv"))
write_csv(agg_by_age_year, file.path(data_dir, "agg_by_age_year.csv"))

cat("\nTest data saved to:\n")
cat("  - rdd_sample.rds\n")
cat("  - agg_by_age.rds/csv\n")
cat("  - agg_by_age_year.rds/csv\n")

# =============================================================================
# Quick preview
# =============================================================================

cat("\n=============================================================================\n")
cat("Test Data Summary - Medicaid Share by Age\n")
cat("=============================================================================\n")
print(agg_by_age %>% select(mother_age, n_births, medicaid_share, private_share))

cat("\nNote: There is a built-in ~5pp discontinuity at age 26 in Medicaid.\n")
cat("This tests the pipeline's ability to detect the RD effect.\n")
