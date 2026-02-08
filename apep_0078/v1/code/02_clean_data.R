# ============================================================================
# 02_clean_data.R
# State Minimum Wage and Business Formation
# Clean and merge datasets for analysis - ANNUAL FREQUENCY
# ============================================================================

source("00_packages.R")

data_dir <- "../data/"

# ============================================================================
# 1. Load all data files
# ============================================================================

cat("Loading data files...\n")

bfs_data <- read_csv(paste0(data_dir, "bfs_data.csv"), show_col_types = FALSE)
mw_panel <- read_csv(paste0(data_dir, "mw_panel.csv"), show_col_types = FALSE)
state_info <- read_csv(paste0(data_dir, "state_info.csv"), show_col_types = FALSE)
cpi_data <- read_csv(paste0(data_dir, "cpi_data.csv"), show_col_types = FALSE)

# ============================================================================
# 2. Collapse BFS data to ANNUAL level (CBP is annual data)
# ============================================================================

cat("Collapsing to annual state-level data...\n")

# Ensure state_fips is character with leading zeros
bfs_data <- bfs_data %>%
  mutate(state_fips = sprintf("%02d", as.integer(state_fips)))

# If state_abbr not already present, join from state_info
if (!"state_abbr" %in% names(bfs_data)) {
  bfs_data <- bfs_data %>%
    left_join(state_info, by = "state_fips")
}

# Collapse to state-year (taking annual sum or max since monthly values are identical)
bfs_annual <- bfs_data %>%
  group_by(state_abbr, state_fips, year) %>%
  summarize(
    establishments = max(BA, na.rm = TRUE),  # Annual establishment count
    .groups = "drop"
  ) %>%
  filter(!is.na(establishments) & establishments > 0)

cat("  Annual BFS observations: ", nrow(bfs_annual), "\n")
cat("  States: ", n_distinct(bfs_annual$state_abbr), "\n")
cat("  Years: ", min(bfs_annual$year), " to ", max(bfs_annual$year), "\n")

# ============================================================================
# 3. Create ANNUAL minimum wage data
# ============================================================================

cat("Creating annual minimum wage measures...\n")

# Annual average minimum wage and end-of-year MW
mw_annual <- mw_panel %>%
  group_by(state_abbr, year) %>%
  summarize(
    annual_avg_mw = mean(effective_mw, na.rm = TRUE),
    jan_mw = effective_mw[month == 1],  # January MW
    federal_mw = mean(federal_mw, na.rm = TRUE),
    above_federal_months = sum(above_federal, na.rm = TRUE),
    above_federal = above_federal_months > 0,  # Above federal at any point in year
    .groups = "drop"
  )

cat("  Annual MW observations: ", nrow(mw_annual), "\n")

# ============================================================================
# 4. Create ANNUAL CPI data
# ============================================================================

cat("Creating annual CPI...\n")

# Annual average CPI
cpi_annual <- cpi_data %>%
  group_by(year) %>%
  summarize(
    cpi = mean(cpi, na.rm = TRUE),
    .groups = "drop"
  )

# Base period: 2020 = 100
base_cpi <- cpi_annual %>%
  filter(year == 2020) %>%
  pull(cpi)

cpi_annual <- cpi_annual %>%
  mutate(cpi_index = cpi / base_cpi * 100)

# ============================================================================
# 5. Merge all data
# ============================================================================

cat("Merging datasets...\n")

analysis_data <- bfs_annual %>%
  left_join(mw_annual, by = c("state_abbr", "year")) %>%
  left_join(cpi_annual, by = "year") %>%
  mutate(
    real_mw = annual_avg_mw * 100 / cpi_index,
    log_real_mw = log(real_mw),
    log_establishments = log(establishments + 1)
  )

cat("  Merged observations: ", nrow(analysis_data), "\n")

# ============================================================================
# 6. Identify treatment timing (first time above federal WITHIN sample)
# ============================================================================

cat("Creating treatment variables...\n")

# Find first year each state is above federal
first_above_federal <- analysis_data %>%
  filter(above_federal) %>%
  group_by(state_abbr) %>%
  summarize(
    first_treat_year = min(year),
    .groups = "drop"
  )

# States that never went above federal in sample
never_treated <- state_info %>%
  filter(!(state_abbr %in% first_above_federal$state_abbr)) %>%
  pull(state_abbr)

# States already treated at sample start (2012)
already_treated_2012 <- first_above_federal %>%
  filter(first_treat_year == min(analysis_data$year)) %>%
  pull(state_abbr)

cat("  Never-treated states: ", length(never_treated), "\n")
cat("  States treated at sample start (excluded from event study): ", length(already_treated_2012), "\n")
cat("  States with within-sample adoption: ", nrow(first_above_federal) - length(already_treated_2012), "\n")

# Add treatment timing
analysis_data <- analysis_data %>%
  left_join(first_above_federal, by = "state_abbr") %>%
  mutate(
    # For never-treated, set first_treat_year to Inf
    first_treat_year = if_else(is.na(first_treat_year), Inf, as.numeric(first_treat_year)),

    # Post-treatment indicator
    post = year >= first_treat_year,

    # Event time (relative to treatment)
    event_time = if_else(
      is.finite(first_treat_year),
      year - first_treat_year,
      NA_real_
    ),

    # Cohort year for Callaway-Sant'Anna
    cohort_year = if_else(
      is.finite(first_treat_year),
      as.integer(first_treat_year),
      NA_integer_
    ),

    # Flag for states already treated at sample start
    already_treated_at_start = state_abbr %in% already_treated_2012
  )

# ============================================================================
# 7. Create analysis-ready panel
# ============================================================================

cat("Creating final analysis panel...\n")

analysis_panel <- analysis_data %>%
  filter(
    !is.na(establishments),
    !is.na(annual_avg_mw)
  ) %>%
  # Create factor variables for FE
  mutate(
    state_fe = as.factor(state_abbr),
    year_fe = as.factor(year)
  ) %>%
  arrange(state_abbr, year)

cat("  Final panel: ", nrow(analysis_panel), " state-year observations\n")
cat("  States: ", n_distinct(analysis_panel$state_abbr), "\n")
cat("  Years: ", n_distinct(analysis_panel$year), "\n")

# ============================================================================
# 8. Compute summary statistics
# ============================================================================

cat("Computing summary statistics...\n")

summary_stats <- analysis_panel %>%
  summarize(
    across(
      c(establishments, annual_avg_mw, real_mw, above_federal),
      list(
        mean = ~mean(., na.rm = TRUE),
        sd = ~sd(., na.rm = TRUE),
        min = ~min(., na.rm = TRUE),
        max = ~max(., na.rm = TRUE),
        n = ~sum(!is.na(.))
      ),
      .names = "{.col}_{.fn}"
    )
  ) %>%
  pivot_longer(everything()) %>%
  separate(name, into = c("variable", "stat"), sep = "_(?=[^_]+$)") %>%
  pivot_wider(names_from = stat, values_from = value)

print(summary_stats)

# ============================================================================
# 9. Save analysis data
# ============================================================================

cat("Saving analysis data...\n")

write_csv(analysis_panel, paste0(data_dir, "analysis_panel.csv"))
write_csv(first_above_federal, paste0(data_dir, "treatment_timing.csv"))
write_csv(summary_stats, paste0(data_dir, "summary_stats.csv"))

cat("\nData cleaning complete!\n")
cat("Analysis panel saved to: ", paste0(data_dir, "analysis_panel.csv"), "\n")
cat("NOTE: Data is at STATE-YEAR level (", nrow(analysis_panel), " observations)\n")
