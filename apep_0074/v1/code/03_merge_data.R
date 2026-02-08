# ============================================================
# 03_merge_data.R - Merge Policy and Outcome Data
# ============================================================

source("00_packages.R")

cat("=== Merging Policy and Mortality Data ===\n")

# Load datasets
policy <- readRDS("../data/erpo_policy_panel.rds")
mortality <- readRDS("../data/suicide_mortality.rds")

# Check overlap
cat("\nPolicy panel years:", min(policy$year), "-", max(policy$year), "\n")
cat("Mortality data years:", min(mortality$year), "-", max(mortality$year), "\n")

# Restrict to overlapping years (1999-2017)
# Using 1999-2017 to include pre-treatment period for Connecticut (treated 2000)
analysis_years <- 1999:2017

# Merge datasets
analysis_data <- policy %>%
  filter(year %in% analysis_years) %>%
  left_join(
    mortality %>% select(state_abbr, year, deaths, suicide_rate),
    by = c("state_abbr", "year")
  )

# Check merge
cat("\n=== Merge Summary ===\n")
cat("Total observations:", nrow(analysis_data), "\n")
cat("States:", n_distinct(analysis_data$state_abbr), "\n")
cat("Years:", min(analysis_data$year), "-", max(analysis_data$year), "\n")
cat("Missing suicide rates:", sum(is.na(analysis_data$suicide_rate)), "\n")

# Treatment summary by year
cat("\n=== Treatment Status Over Time ===\n")
analysis_data %>%
  group_by(year) %>%
  summarise(
    n_treated = sum(treated),
    n_control = sum(1 - treated),
    mean_rate_treated = mean(suicide_rate[treated == 1], na.rm = TRUE),
    mean_rate_control = mean(suicide_rate[treated == 0], na.rm = TRUE)
  ) %>%
  print(n = 15)

# Cohort summary
cat("\n=== Treatment Cohorts ===\n")
analysis_data %>%
  filter(year == 2017) %>%
  count(first_treat, cohort) %>%
  arrange(first_treat) %>%
  print()

# Create variables for C-S estimator
analysis_data <- analysis_data %>%
  mutate(
    # State numeric ID
    state_id = as.numeric(factor(state_abbr)),
    # Log suicide rate for semi-elasticity interpretation
    log_suicide_rate = log(suicide_rate)
  )

# Save analysis dataset
write_csv(analysis_data, "../data/analysis_data.csv")
saveRDS(analysis_data, "../data/analysis_data.rds")

cat("\n=== Analysis Dataset Saved ===\n")
cat("File: data/analysis_data.csv\n")
cat("Observations:", nrow(analysis_data), "\n")

# Summary statistics table
cat("\n=== Summary Statistics ===\n")
analysis_data %>%
  group_by(cohort) %>%
  summarise(
    States = n_distinct(state_abbr),
    `Mean Rate` = round(mean(suicide_rate, na.rm = TRUE), 1),
    `SD Rate` = round(sd(suicide_rate, na.rm = TRUE), 1),
    Observations = n()
  ) %>%
  print()
