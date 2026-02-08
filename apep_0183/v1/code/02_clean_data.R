# =============================================================================
# 02_clean_data.R
# Data Cleaning and Validation for DiDisc Analysis
# =============================================================================

source("00_packages.R")

cat("=== Loading Raw Data ===\n")

# Check if data exists
if (!file.exists(file.path(data_dir, "qwi_border.rds"))) {
  stop("Run 01_fetch_data.R first to download data")
}

qwi_border <- readRDS(file.path(data_dir, "qwi_border.rds"))
treatment_dates <- readRDS(file.path(data_dir, "treatment_dates.rds"))
border_counties <- readRDS(file.path(data_dir, "border_counties.rds"))

cat("Raw observations:", nrow(qwi_border), "\n")

# =============================================================================
# Data Quality Checks
# =============================================================================

cat("\n=== Data Quality Checks ===\n")

# Check for missing values
missing_summary <- qwi_border %>%
  summarise(
    missing_earn = sum(is.na(log_earn_hire)),
    missing_emp = sum(is.na(log_emp)),
    missing_dist = sum(is.na(signed_dist)),
    missing_treat = sum(is.na(treated)),
    pct_missing_earn = mean(is.na(log_earn_hire)) * 100
  )

cat("Missing values:\n")
print(missing_summary)

# Check treatment timing
cat("\nTreatment timing check:\n")
qwi_border %>%
  filter(treated) %>%
  group_by(treated_state) %>%
  summarise(
    min_event_time = min(event_time, na.rm = TRUE),
    max_event_time = max(event_time, na.rm = TRUE),
    n_pre = sum(event_time < 0),
    n_post = sum(event_time >= 0)
  ) %>%
  left_join(treatment_dates %>% select(state_fips, state_abbr),
            by = c("treated_state" = "state_fips")) %>%
  print()

# =============================================================================
# Sample Restrictions
# =============================================================================

cat("\n=== Applying Sample Restrictions ===\n")

# 1. Require valid earnings data
qwi_clean <- qwi_border %>%
  filter(!is.na(log_earn_hire), EarnHirAS > 0)

cat("After earnings filter:", nrow(qwi_clean), "\n")

# 2. Require valid distance
qwi_clean <- qwi_clean %>%
  filter(!is.na(signed_dist))

cat("After distance filter:", nrow(qwi_clean), "\n")

# 3. Restrict to analysis period (2010-2023)
qwi_clean <- qwi_clean %>%
  filter(year >= 2010, year <= 2023)

cat("After year filter:", nrow(qwi_clean), "\n")

# 4. Drop observations from states that legalized but aren't in our treatment list
# (e.g., if control state later legalized, drop post-legalization periods)
# For simplicity, we define "control" as never-treated in sample or pre-their-treatment

# Example: Oregon-Nevada border before Nevada legalized
# Nevada legalized July 2017; before that, it's a valid control for Oregon (Oct 2015)

# =============================================================================
# Create Analysis Variables
# =============================================================================

cat("\n=== Creating Analysis Variables ===\n")

qwi_clean <- qwi_clean %>%
  mutate(
    # Standardize distance (for numerical stability)
    dist_km_std = signed_dist / 100,

    # Create event time categories
    event_cat = case_when(
      event_time < -8 ~ "Pre (-8+)",
      event_time >= -8 & event_time < 0 ~ "Pre (-8 to -1)",
      event_time >= 0 & event_time < 4 ~ "Post (0-3)",
      event_time >= 4 & event_time < 8 ~ "Post (4-7)",
      event_time >= 8 ~ "Post (8+)",
      TRUE ~ "Never Treated"
    ),

    # Industry categories (pre-specified)
    industry_cat = case_when(
      industry %in% c("11", "44-45") ~ "Direct Cannabis",
      industry == "48-49" ~ "DOT Regulated",
      industry %in% c("31-33", "23") ~ "Safety Sensitive",
      industry %in% c("54", "52", "51") ~ "Low Testing",
      industry == "72" ~ "Tourism Exposed",
      industry == "00" ~ "All Industries",
      TRUE ~ "Other"
    ),

    # Bandwidth indicators
    bw_25 = dist_to_border <= 25,
    bw_50 = dist_to_border <= 50,
    bw_75 = dist_to_border <= 75,
    bw_100 = dist_to_border <= 100,
    bw_150 = dist_to_border <= 150
  )

# =============================================================================
# Balance Checks
# =============================================================================

cat("\n=== Pre-Treatment Balance ===\n")

# Balance check: compare treated vs control counties in pre-period
balance_check <- qwi_clean %>%
  filter(event_time < 0 | is.na(event_time), industry == "00", bw_100) %>%
  group_by(treated) %>%
  summarise(
    mean_earn = mean(EarnHirAS, na.rm = TRUE),
    sd_earn = sd(EarnHirAS, na.rm = TRUE),
    mean_emp = mean(Emp, na.rm = TRUE),
    mean_hires = mean(HirA, na.rm = TRUE),
    mean_dist = mean(dist_to_border, na.rm = TRUE),
    n_counties = n_distinct(county_fips),
    n_obs = n()
  )

cat("Pre-treatment balance (100km bandwidth):\n")
print(balance_check)

# Standardized differences
std_diff <- balance_check %>%
  summarise(
    smd_earn = diff(mean_earn) / sqrt(mean(sd_earn^2)),
    smd_emp = diff(mean_emp) / sqrt(mean(var(qwi_clean$Emp[qwi_clean$bw_100], na.rm = TRUE))),
    smd_dist = diff(mean_dist) / sqrt(var(qwi_clean$dist_to_border[qwi_clean$bw_100], na.rm = TRUE))
  )

cat("\nStandardized mean differences:\n")
print(std_diff)

# =============================================================================
# Pre-Trend Visualization Data
# =============================================================================

cat("\n=== Preparing Pre-Trend Data ===\n")

# Aggregate by treated/control and quarter for visualization
trend_data <- qwi_clean %>%
  filter(industry == "00", bw_100) %>%
  group_by(year, quarter, treated) %>%
  summarise(
    mean_earn = mean(EarnHirAS, na.rm = TRUE),
    se_earn = sd(EarnHirAS, na.rm = TRUE) / sqrt(n()),
    mean_log_earn = mean(log_earn_hire, na.rm = TRUE),
    se_log_earn = sd(log_earn_hire, na.rm = TRUE) / sqrt(n()),
    n = n(),
    .groups = "drop"
  ) %>%
  mutate(
    date = as.Date(paste0(year, "-", (quarter - 1) * 3 + 1, "-01")),
    group = ifelse(treated, "Treated", "Control")
  )

saveRDS(trend_data, file.path(data_dir, "trend_data.rds"))

# =============================================================================
# Save Cleaned Data
# =============================================================================

cat("\n=== Saving Cleaned Data ===\n")

saveRDS(qwi_clean, file.path(data_dir, "qwi_clean.rds"))

# Update main file to use cleaned version
saveRDS(qwi_clean, file.path(data_dir, "qwi_border.rds"))

cat("Final sample size:", nrow(qwi_clean), "\n")
cat("Counties:", n_distinct(qwi_clean$county_fips), "\n")
cat("Border pairs:", n_distinct(qwi_clean$border_pair), "\n")
cat("Industries:", n_distinct(qwi_clean$industry), "\n")
cat("Date range:", min(qwi_clean$date), "to", max(qwi_clean$date), "\n")

# Summary by border pair
cat("\n=== Sample by Border Pair ===\n")
qwi_clean %>%
  filter(industry == "00", bw_100) %>%
  group_by(border_pair) %>%
  summarise(
    n_treat = sum(treated),
    n_ctrl = sum(!treated),
    mean_earn_treat = mean(EarnHirAS[treated], na.rm = TRUE),
    mean_earn_ctrl = mean(EarnHirAS[!treated], na.rm = TRUE),
    .groups = "drop"
  ) %>%
  print(n = 30)

cat("\nData cleaning complete.\n")
