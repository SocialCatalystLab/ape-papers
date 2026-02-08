# ==============================================================================
# 04_robustness.R
# Robustness checks and sensitivity analyses
# Paper 111: NP Full Practice Authority and Physician Employment
# ==============================================================================

source("00_packages.R")

# Load data
analysis_main <- read_csv(file.path(data_dir, "analysis_main.csv"))
analysis_did <- read_csv(file.path(data_dir, "analysis_did.csv"))
results <- readRDS(file.path(data_dir, "main_results.rds"))

# ==============================================================================
# PART 1: Placebo Tests - Skip (API limitations for other industry codes)
# ==============================================================================

cat("\n=== PART 1: Placebo Tests ===\n")
cat("Skipping placebo tests due to API limitations for other industry codes.\n")
cat("Placebo validation can be done manually with downloaded QCEW data.\n")

# Create placeholder for consistency
placebo_results <- list()
placebo_results[["Manufacturing"]] <- NULL
placebo_results[["Retail"]] <- NULL

# ==============================================================================
# PART 2: Sun-Abraham Estimator
# ==============================================================================

cat("\n=== PART 2: Sun-Abraham Estimator ===\n")

# Prepare data for Sun-Abraham
sa_data <- analysis_did %>%
  mutate(
    cohort = ifelse(fpa_year == 0, Inf, fpa_year),  # Inf for never-treated
    rel_time = year - fpa_year,
    rel_time = ifelse(fpa_year == 0, NA, rel_time)
  )

# Create relative time dummies
sa_data <- sa_data %>%
  mutate(
    rel_time_binned = case_when(
      is.na(rel_time) ~ "never_treated",
      rel_time <= -8 ~ "m8_",
      rel_time == -7 ~ "m7",
      rel_time == -6 ~ "m6",
      rel_time == -5 ~ "m5",
      rel_time == -4 ~ "m4",
      rel_time == -3 ~ "m3",
      rel_time == -2 ~ "m2",
      rel_time == -1 ~ "m1",
      rel_time == 0 ~ "p0",
      rel_time == 1 ~ "p1",
      rel_time == 2 ~ "p2",
      rel_time == 3 ~ "p3",
      rel_time == 4 ~ "p4",
      rel_time == 5 ~ "p5",
      rel_time == 6 ~ "p6",
      rel_time == 7 ~ "p7",
      rel_time >= 8 ~ "p8_",
      TRUE ~ "other"
    )
  )

# Sun-Abraham via fixest's sunab() function
sa_model <- feols(
  log_emp ~ sunab(cohort, year) | state_fips + year,
  data = sa_data %>% filter(cohort != Inf | fpa_year == 0),
  cluster = ~ state_fips
)

cat("\nSun-Abraham event study coefficients:\n")
summary(sa_model)

# ==============================================================================
# PART 3: Heterogeneity by State Characteristics
# ==============================================================================

cat("\n=== PART 3: Heterogeneity Analysis ===\n")

# Load baseline characteristics
baseline <- read_csv(file.path(data_dir, "baseline_characteristics.csv"))

# Classify states by baseline physician intensity
median_intensity <- median(baseline$baseline_physician_intensity, na.rm = TRUE)
baseline <- baseline %>%
  mutate(
    high_physician = baseline_physician_intensity > median_intensity
  )

# Merge with analysis data
het_data <- analysis_did %>%
  left_join(baseline %>% select(state_fips, high_physician), by = "state_fips")

# Heterogeneity by baseline physician intensity
het_high <- feols(
  log_emp ~ post | state_fips + year,
  data = het_data %>% filter(high_physician == TRUE),
  cluster = ~ state_fips
)

het_low <- feols(
  log_emp ~ post | state_fips + year,
  data = het_data %>% filter(high_physician == FALSE),
  cluster = ~ state_fips
)

cat("\nHeterogeneity by baseline physician intensity:\n")
cat("High physician states:", round(coef(het_high)["postTRUE"], 4),
    " (SE:", round(se(het_high)["postTRUE"], 4), ")\n")
cat("Low physician states:", round(coef(het_low)["postTRUE"], 4),
    " (SE:", round(se(het_low)["postTRUE"], 4), ")\n")

# ==============================================================================
# PART 4: Sensitivity to Sample Restrictions
# ==============================================================================

cat("\n=== PART 4: Sensitivity to Sample ===\n")

# Excluding recent adopters (2021+)
recent_excluded <- analysis_did %>%
  filter(fpa_year == 0 | (fpa_year >= 2008 & fpa_year < 2021))

sensitivity_recent <- feols(
  log_emp ~ post | state_fips + year,
  data = recent_excluded,
  cluster = ~ state_fips
)

cat("\nExcluding recent adopters (2021+):\n")
cat("  Estimate:", round(coef(sensitivity_recent)["postTRUE"], 4),
    " (SE:", round(se(sensitivity_recent)["postTRUE"], 4), ")\n")

# Excluding small states (< 500k healthcare workers baseline)
large_states <- baseline %>%
  filter(baseline_healthcare_emp > 500000) %>%
  pull(state_fips)

sensitivity_large <- feols(
  log_emp ~ post | state_fips + year,
  data = analysis_did %>% filter(state_fips %in% large_states),
  cluster = ~ state_fips
)

cat("\nLarge states only (>500k healthcare workers):\n")
cat("  Estimate:", round(coef(sensitivity_large)["postTRUE"], 4),
    " (SE:", round(se(sensitivity_large)["postTRUE"], 4), ")\n")

# ==============================================================================
# PART 5: Physician Establishments (Entry/Exit)
# ==============================================================================

cat("\n=== PART 5: Establishment Analysis ===\n")

# Effect on number of physician practices
estab_model <- feols(
  log_estab ~ post | state_fips + year,
  data = analysis_did,
  cluster = ~ state_fips
)

cat("\nEffect on log(establishments):\n")
summary(estab_model)

# Effect on average practice size
analysis_did <- analysis_did %>%
  mutate(
    avg_practice_size = employment / establishments,
    log_practice_size = log(avg_practice_size)
  )

size_model <- feols(
  log_practice_size ~ post | state_fips + year,
  data = analysis_did,
  cluster = ~ state_fips
)

cat("\nEffect on log(average practice size):\n")
summary(size_model)

# ==============================================================================
# PART 6: Save Robustness Results
# ==============================================================================

robustness_results <- list(
  placebo = placebo_results,
  sun_abraham = sa_model,
  het_high = het_high,
  het_low = het_low,
  sensitivity_recent = sensitivity_recent,
  sensitivity_large = sensitivity_large,
  establishments = estab_model,
  practice_size = size_model
)

saveRDS(robustness_results, file.path(data_dir, "robustness_results.rds"))
cat("\nRobustness results saved to data/robustness_results.rds\n")

# ==============================================================================
# PART 7: Summary Table
# ==============================================================================

cat("\n")
cat("=" %>% rep(60) %>% paste(collapse = ""), "\n")
cat("ROBUSTNESS SUMMARY\n")
cat("=" %>% rep(60) %>% paste(collapse = ""), "\n")

cat("\nSpecification                      | Estimate | SE     | Sig?\n")
cat(paste(rep("-", 60), collapse = ""), "\n")
cat(sprintf("Main (CS-DiD)                      | %7.4f | %6.4f | %s\n",
            results$simple_att$estimate, results$simple_att$se,
            ifelse(results$simple_att$p_value < 0.05, "Yes", "No")))
cat(sprintf("Excluding 2021+ adopters           | %7.4f | %6.4f | %s\n",
            coef(sensitivity_recent)["postTRUE"],
            se(sensitivity_recent)["postTRUE"],
            ifelse(abs(coef(sensitivity_recent)["postTRUE"] /
                         se(sensitivity_recent)["postTRUE"]) > 1.96, "Yes", "No")))
cat(sprintf("Large states only                  | %7.4f | %6.4f | %s\n",
            coef(sensitivity_large)["postTRUE"],
            se(sensitivity_large)["postTRUE"],
            ifelse(abs(coef(sensitivity_large)["postTRUE"] /
                         se(sensitivity_large)["postTRUE"]) > 1.96, "Yes", "No")))
