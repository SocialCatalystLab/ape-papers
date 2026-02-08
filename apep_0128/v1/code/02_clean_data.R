# ==============================================================================
# 02_clean_data.R
# Prepare data for synthetic control analysis
# ==============================================================================

source("00_packages.R")

# Load data
cat("Loading FRED housing price data...\n")
hpi_long <- readRDS("../data/processed/hpi_long.rds")
hpi_wide <- readRDS("../data/processed/hpi_wide.rds")

# Treatment date
TREATMENT_DATE <- ymd("2019-04-01")  # Q2 2019 (ruling was May 29, 2019)
TREATMENT_QUARTER <- 58  # Q2 2019 is approximately the 58th quarter from Q1 2005

cat(sprintf("Treatment date: %s (Q2 2019)\n", TREATMENT_DATE))

# ------------------------------------------------------------------------------
# 1. Check data quality
# ------------------------------------------------------------------------------
cat("\n=== Data Quality Checks ===\n")

# Missing values by country
missing_check <- hpi_long %>%
  group_by(country) %>%
  summarize(
    n_obs = n(),
    n_missing = sum(is.na(hpi)),
    pct_missing = mean(is.na(hpi)) * 100,
    .groups = "drop"
  )

cat("Missing values by country:\n")
print(as.data.frame(missing_check))

# Pre-treatment observations
pre_treatment <- hpi_long %>%
  filter(date < TREATMENT_DATE)

cat(sprintf("\nPre-treatment observations: %d\n", nrow(pre_treatment)))
cat(sprintf("Pre-treatment quarters: %d\n", n_distinct(pre_treatment$date)))

# ------------------------------------------------------------------------------
# 2. Create analysis sample
# ------------------------------------------------------------------------------
cat("\n=== Creating Analysis Sample ===\n")

# Keep only countries with complete data in pre-treatment period
complete_countries <- hpi_long %>%
  filter(date >= ymd("2010-01-01"), date < TREATMENT_DATE) %>%
  group_by(country) %>%
  summarize(
    n_pre = n(),
    n_missing = sum(is.na(hpi)),
    .groups = "drop"
  ) %>%
  filter(n_missing == 0) %>%
  pull(country)

cat("Countries with complete pre-treatment data (2010-2019Q1):\n")
cat(paste(complete_countries, collapse = ", "), "\n")

# Filter to analysis sample - truncate at 2023Q4 as stated in paper
analysis_data <- hpi_long %>%
  filter(country %in% complete_countries) %>%
  filter(date >= ymd("2010-01-01"), date <= ymd("2023-10-01")) %>%
  arrange(country, date)

cat(sprintf("\nAnalysis sample: %d observations\n", nrow(analysis_data)))
cat(sprintf("Countries: %d\n", n_distinct(analysis_data$country)))
cat(sprintf("Time periods: %d quarters\n", n_distinct(analysis_data$date)))

# Create time index (for synthetic control)
time_periods <- analysis_data %>%
  select(date) %>%
  distinct() %>%
  arrange(date) %>%
  mutate(time_id = row_number())

analysis_data <- analysis_data %>%
  left_join(time_periods, by = "date")

# Treatment indicator
treatment_time_id <- time_periods %>%
  filter(date == TREATMENT_DATE) %>%
  pull(time_id)

analysis_data <- analysis_data %>%
  mutate(
    post = time_id >= treatment_time_id,
    rel_time = time_id - treatment_time_id,
    treated = country == "Netherlands"
  )

cat(sprintf("Treatment period index: %d\n", treatment_time_id))
cat(sprintf("Pre-treatment periods: %d\n", treatment_time_id - 1))
cat(sprintf("Post-treatment periods: %d\n", max(analysis_data$time_id) - treatment_time_id + 1))

# ------------------------------------------------------------------------------
# 3. Normalize HPI (2010 = 100)
# ------------------------------------------------------------------------------
cat("\n=== Normalizing HPI ===\n")

# Get base values for 2010Q1
base_values <- analysis_data %>%
  filter(date == ymd("2010-01-01")) %>%
  select(country, base_hpi = hpi)

analysis_data <- analysis_data %>%
  left_join(base_values, by = "country") %>%
  mutate(
    hpi_norm = (hpi / base_hpi) * 100
  )

# Check normalization
norm_check <- analysis_data %>%
  filter(date == ymd("2010-01-01")) %>%
  select(country, hpi, base_hpi, hpi_norm)

cat("2010Q1 values after normalization (should all be 100):\n")
print(as.data.frame(norm_check))

# ------------------------------------------------------------------------------
# 4. Create wide format for synthetic control
# ------------------------------------------------------------------------------
cat("\n=== Creating Wide Format ===\n")

# Wide format with normalized HPI
synth_wide <- analysis_data %>%
  select(country, time_id, hpi_norm) %>%
  pivot_wider(
    names_from = country,
    values_from = hpi_norm
  ) %>%
  arrange(time_id)

# Add date back
synth_wide <- synth_wide %>%
  left_join(time_periods, by = "time_id")

cat(sprintf("Synthetic control data: %d periods x %d countries\n",
            nrow(synth_wide), ncol(synth_wide) - 2))

# ------------------------------------------------------------------------------
# 5. Define donor pool (exclude Netherlands)
# ------------------------------------------------------------------------------
donor_countries <- setdiff(complete_countries, "Netherlands")
cat(sprintf("\nDonor pool: %d countries\n", length(donor_countries)))
cat(paste(donor_countries, collapse = ", "), "\n")

# ------------------------------------------------------------------------------
# 6. Save processed data
# ------------------------------------------------------------------------------
cat("\n=== Saving Processed Data ===\n")

# Save analysis data
saveRDS(analysis_data, "../data/processed/analysis_data.rds")
saveRDS(synth_wide, "../data/processed/synth_wide.rds")
saveRDS(time_periods, "../data/processed/time_periods.rds")

# Save parameters
params <- list(
  treatment_date = TREATMENT_DATE,
  treatment_time_id = treatment_time_id,
  treated_country = "Netherlands",
  donor_countries = donor_countries,
  n_pre_periods = treatment_time_id - 1,
  n_post_periods = max(analysis_data$time_id) - treatment_time_id + 1
)
saveRDS(params, "../data/processed/analysis_params.rds")

cat("Files saved:\n")
cat("  analysis_data.rds - Long format with all variables\n")
cat("  synth_wide.rds - Wide format for synthetic control\n")
cat("  time_periods.rds - Time period mapping\n")
cat("  analysis_params.rds - Analysis parameters\n")

# ------------------------------------------------------------------------------
# 7. Summary statistics
# ------------------------------------------------------------------------------
cat("\n=== Summary Statistics ===\n")

# Pre-treatment means by country
pre_means <- analysis_data %>%
  filter(!post) %>%
  group_by(country) %>%
  summarize(
    mean_hpi_norm = mean(hpi_norm),
    sd_hpi_norm = sd(hpi_norm),
    min_hpi_norm = min(hpi_norm),
    max_hpi_norm = max(hpi_norm),
    .groups = "drop"
  ) %>%
  arrange(desc(mean_hpi_norm))

cat("Pre-treatment HPI summary (normalized, 2010=100):\n")
print(as.data.frame(pre_means))

# Netherlands vs average of donors
nl_vs_donors <- analysis_data %>%
  mutate(group = if_else(country == "Netherlands", "Netherlands", "Donor Average")) %>%
  group_by(group, date) %>%
  summarize(mean_hpi = mean(hpi_norm), .groups = "drop") %>%
  pivot_wider(names_from = group, values_from = mean_hpi)

cat("\nNetherlands vs Donor Average (selected periods):\n")
nl_vs_donors %>%
  filter(year(date) %in% c(2010, 2015, 2019, 2020, 2023)) %>%
  print()

cat("\nData preparation complete.\n")
