# ==============================================================================
# 02_clean_data.R - Clean and Prepare Analysis Sample
# Paper: Salary History Bans and Wage Compression
# ==============================================================================

library(tidyverse)
library(data.table)
library(ipumsr)
library(here)

# Set paths relative to paper directory
data_dir <- file.path(here::here(), "data")

# ------------------------------------------------------------------------------
# Load IPUMS ACS Data
# ------------------------------------------------------------------------------

# Check if IPUMS data exists
ipums_files <- list.files(data_dir, pattern = "\\.xml$", full.names = TRUE)

if (length(ipums_files) == 0) {
  stop(paste0(
    "IPUMS ACS data not found in ", data_dir, "\n",
    "This analysis requires real microdata from IPUMS.\n",
    "Please:\n",
    "  1. Submit an IPUMS ACS extract at https://usa.ipums.org/usa/\n",
    "  2. Download the .xml DDI file and .dat.gz data file\n",
    "  3. Place them in the data/ subdirectory\n",
    "  4. Re-run this script\n\n",
    "Required variables: YEAR, STATEFIP, PERWT, AGE, SEX, EDUC, EMPSTAT, INCWAGE, MIGRATE1, MONTH"
  ))
} else {
  cat("Loading IPUMS ACS data...\n")
  ddi <- read_ipums_ddi(ipums_files[1])
  acs <- read_ipums_micro(ddi)
  cat("  Loaded", nrow(acs), "observations\n")
}

# ------------------------------------------------------------------------------
# Sample Restrictions
# ------------------------------------------------------------------------------

acs_clean <- acs %>%
  filter(
    # Working age
    age >= 18 & age <= 64,
    
    # Employed (for wage analysis)
    empstat == 1,
    
    # Positive wage income
    incwage > 0 & incwage < 999998  # Exclude top-coded/missing
  ) %>%
  mutate(
    # Log wages
    log_wage = log(incwage),
    
    # Job changer indicator (key for addressing dilution concern)
    # MIGRATE1: 1=same house, 2=moved within state, 3=moved different state, 4=abroad
    job_changer = migrate1 >= 2,  # Proxy: movers likely changed jobs
    
    # Education categories
    educ_cat = case_when(
      educ <= 6 ~ "Less than HS",
      educ <= 7 ~ "High School",
      educ <= 10 ~ "Some College",
      educ >= 11 ~ "College+"
    ),
    
    # Demographics
    female = sex == 2,
    
    # Year-month for precise timing
    ym = year * 100 + month
  )

cat("\nSample after restrictions:\n")
cat("  Total observations:", nrow(acs_clean), "\n")
cat("  Job changers:", sum(acs_clean$job_changer), 
    sprintf("(%.1f%%)", 100 * mean(acs_clean$job_changer)), "\n")

# ------------------------------------------------------------------------------
# Merge Treatment Status
# ------------------------------------------------------------------------------

# Load treatment dates
shb_dates <- read_csv(file.path(data_dir, "shb_treatment_dates.csv"),
                      show_col_types = FALSE)

# Create treatment indicator with precise timing
acs_clean <- acs_clean %>%
  left_join(
    shb_dates %>% select(statefip, effective_date, effective_year),
    by = "statefip"
  ) %>%
  mutate(
    # State ever treated
    treated_state = !is.na(effective_year),
    
    # Post-treatment (using effective year for annual analysis)
    post = year >= effective_year,
    post = ifelse(is.na(post), FALSE, post),
    
    # Treatment indicator
    shb = treated_state & post,
    
    # First treatment year for CS estimator (0 = never treated)
    first_treat = ifelse(treated_state, effective_year, 0)
  )

cat("\nTreatment status:\n")
cat("  Treated state-years:", sum(acs_clean$shb), "\n")
cat("  Control state-years:", sum(!acs_clean$shb), "\n")

# ------------------------------------------------------------------------------
# Compute State-Year Wage Dispersion Measures
# ------------------------------------------------------------------------------

state_year_stats <- acs_clean %>%
  group_by(statefip, year, first_treat, shb) %>%
  summarise(
    # Sample size
    n_obs = n(),
    n_weighted = sum(perwt),
    
    # Mean wage
    mean_log_wage = weighted.mean(log_wage, perwt, na.rm = TRUE),
    mean_wage = weighted.mean(incwage, perwt, na.rm = TRUE),
    
    # Wage dispersion measures (PRIMARY OUTCOMES)
    sd_log_wage = sqrt(Hmisc::wtd.var(log_wage, perwt, na.rm = TRUE)),
    
    # Percentiles (unweighted for simplicity; weight in final)
    p10 = quantile(log_wage, 0.10, na.rm = TRUE),
    p50 = quantile(log_wage, 0.50, na.rm = TRUE),
    p90 = quantile(log_wage, 0.90, na.rm = TRUE),
    
    # Ratios
    p90_p10 = p90 - p10,  # Log difference = ratio
    p90_p50 = p90 - p50,
    p50_p10 = p50 - p10,
    
    # Share of job changers (for heterogeneity)
    pct_job_changer = mean(job_changer, na.rm = TRUE),
    
    .groups = "drop"
  )

cat("\nState-year panel:\n")
cat("  Observations:", nrow(state_year_stats), "\n")
cat("  Years:", paste(range(state_year_stats$year), collapse = "-"), "\n")
cat("  States:", n_distinct(state_year_stats$statefip), "\n")

# ------------------------------------------------------------------------------
# Job Changers Subsample (Higher Exposure to Treatment)
# ------------------------------------------------------------------------------

job_changer_stats <- acs_clean %>%
  filter(job_changer) %>%
  group_by(statefip, year, first_treat, shb) %>%
  summarise(
    n_obs = n(),
    n_weighted = sum(perwt),
    mean_log_wage = weighted.mean(log_wage, perwt, na.rm = TRUE),
    sd_log_wage = sqrt(Hmisc::wtd.var(log_wage, perwt, na.rm = TRUE)),
    p10 = quantile(log_wage, 0.10, na.rm = TRUE),
    p50 = quantile(log_wage, 0.50, na.rm = TRUE),
    p90 = quantile(log_wage, 0.90, na.rm = TRUE),
    p90_p10 = p90 - p10,
    .groups = "drop"
  )

cat("\nJob changers subsample:\n")
cat("  Observations:", nrow(job_changer_stats), "\n")

# ------------------------------------------------------------------------------
# Save Cleaned Data
# ------------------------------------------------------------------------------

write_csv(acs_clean, file.path(data_dir, "acs_clean.csv.gz"))
write_csv(state_year_stats, file.path(data_dir, "state_year_wages.csv"))
write_csv(job_changer_stats, file.path(data_dir, "job_changer_wages.csv"))

cat("\n")
cat(strrep("=", 60), "\n")
cat("DATA CLEANING COMPLETE\n")
cat(strrep("=", 60), "\n")
cat("\nFiles saved:\n")
cat("  - acs_clean.csv.gz (individual-level data)\n")
cat("  - state_year_wages.csv (state-year aggregates)\n")
cat("  - job_changer_wages.csv (job changers only)\n")
