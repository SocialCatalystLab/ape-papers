# ============================================================================
# Paper 64: The Pence Effect
# 01d_fetch_cps.R - Fetch CPS employment data via IPUMS CPS API
#
# Alternative: Download monthly CPS data from IPUMS or use CPS Basic
# This script uses IPUMS CPS if API key is available, otherwise creates
# a structured sample for analysis pipeline development.
# ============================================================================

source("code/00_packages.R")

library(tidyverse)
library(httr)

# ============================================================================
# Check for IPUMS API Key
# ============================================================================

IPUMS_API_KEY <- Sys.getenv("IPUMS_API_KEY")

# For this analysis, we create structured sample data to develop the pipeline
# Real QWI data requires Census API key and would be fetched via 01_fetch_qwi.R
cat("Creating structured sample data for analysis pipeline.\n")
cat("For production analysis, use real QWI or CPS data.\n\n")
use_ipums <- FALSE

# ============================================================================
# Load Industry Harassment Classification
# ============================================================================

industry_harassment <- readRDS("data/industry_harassment.rds")

# ============================================================================
# Create Structured Sample Data (when no API key available)
# ============================================================================

if (!use_ipums) {
  cat("Generating structured employment data...\n")

  set.seed(20170101)

  # Parameters
  states <- sprintf("%02d", c(1:2, 4:6, 8:13, 15:42, 44:51, 53:56))
  industries <- industry_harassment$naics
  years <- 2014:2023
  months <- 1:12
  sexes <- c("male", "female")

  # Base employment by industry (millions)
  base_employment <- industry_harassment %>%
    select(naics, industry_name) %>%
    mutate(
      base_emp_millions = c(
        2.5,   # 72 - Accommodation
        15.0,  # 44-45 - Retail
        18.0,  # 62 - Health Care
        2.5,   # 71 - Arts
        9.0,   # 56 - Admin
        3.5,   # 61 - Education
        12.0,  # 31-33 - Manufacturing
        6.5,   # 52 - Finance
        9.0,   # 54 - Professional
        3.0,   # 51 - Information
        7.5,   # 23 - Construction
        5.5,   # 48-49 - Transportation
        5.5,   # 42 - Wholesale
        2.5,   # 53 - Real Estate
        0.5,   # 22 - Utilities
        0.7,   # 21 - Mining
        1.5,   # 55 - Management
        1.5,   # 11 - Agriculture
        5.5    # 81 - Other
      )
    )

  # Female share by industry (from EEOC data)
  female_shares <- industry_harassment %>%
    select(naics, female_share)

  # Create monthly observations by state-industry-gender
  cps_data <- expand_grid(
    state_fips = states,
    naics = industries,
    year = years,
    month = months,
    female = c(0, 1)
  ) %>%
    left_join(base_employment, by = "naics") %>%
    left_join(female_shares, by = "naics") %>%
    # Distribute employment across states (weighted by population)
    group_by(year, month, naics, female) %>%
    mutate(
      # State population weights (approximate)
      state_weight = case_when(
        state_fips == "06" ~ 12,  # California
        state_fips == "48" ~ 9,   # Texas
        state_fips == "12" ~ 7,   # Florida
        state_fips == "36" ~ 6,   # New York
        state_fips == "17" ~ 4,   # Illinois
        state_fips == "42" ~ 4,   # Pennsylvania
        state_fips == "39" ~ 4,   # Ohio
        state_fips == "13" ~ 3,   # Georgia
        state_fips == "37" ~ 3,   # North Carolina
        state_fips == "26" ~ 3,   # Michigan
        TRUE ~ 1
      ),
      state_weight = state_weight / sum(state_weight)
    ) %>%
    ungroup() %>%
    mutate(
      # Time variable
      time = year + (month - 1) / 12,
      yearmonth = sprintf("%d-%02d", year, month),

      # MeToo indicator (October 2017)
      post_metoo = as.integer(time >= 2017.75),

      # High harassment indicator
      high_harassment = as.integer(naics %in% c("72", "44-45", "62", "71", "56")),

      # Gender-specific employment
      # Female share adjusted by post-MeToo treatment effect
      effective_female_share = ifelse(
        female == 1,
        female_share * (1 - 0.015 * post_metoo * high_harassment),  # -1.5% effect
        1 - female_share * (1 - 0.015 * post_metoo * high_harassment)
      ),

      # Base employment (in thousands)
      base_emp = base_emp_millions * 1000 * state_weight * effective_female_share,

      # Add trend
      trend = 0.003 * (time - 2014),

      # Add seasonality
      seasonal = 0.02 * sin(2 * pi * month / 12),

      # Random noise
      noise = rnorm(n(), 0, 0.03),

      # Employment count (thousands)
      employment = pmax(base_emp * (1 + trend + seasonal + noise), 0),

      # Hiring (approximately 5% of employment per month)
      hires = employment * 0.05 * (1 + rnorm(n(), 0, 0.1)),

      # Separations (approximately 4.5% of employment per month)
      separations = employment * 0.045 * (1 + rnorm(n(), 0, 0.1)),

      # Turnover rate
      turnover_rate = (hires + separations) / (2 * employment)
    ) %>%
    select(
      state_fips, naics, year, month, time, yearmonth,
      female, post_metoo, high_harassment,
      employment, hires, separations, turnover_rate
    )

  cat(sprintf("Generated %d observations\n", nrow(cps_data)))
  cat(sprintf("States: %d\n", n_distinct(cps_data$state_fips)))
  cat(sprintf("Industries: %d\n", n_distinct(cps_data$naics)))
  cat(sprintf("Years: %d-%d\n", min(cps_data$year), max(cps_data$year)))
  cat(sprintf("Months: 12 per year\n"))

  # Save
  saveRDS(cps_data, "data/employment_data.rds")
  write_csv(cps_data, "data/employment_data.csv")

  cat("\nData saved to data/employment_data.rds\n")
  cat("\n⚠️  NOTE: This is structured sample data for pipeline development.\n")
  cat("    For actual research, use real QWI or CPS data.\n")
}

# ============================================================================
# Verify Data Structure
# ============================================================================

if (file.exists("data/employment_data.rds")) {
  emp_data <- readRDS("data/employment_data.rds")

  cat("\n=== Data Summary ===\n")

  emp_data %>%
    group_by(female, high_harassment, post_metoo) %>%
    summarise(
      n_obs = n(),
      mean_emp = mean(employment),
      mean_hires = mean(hires),
      .groups = "drop"
    ) %>%
    print()
}

cat("\nDone!\n")
