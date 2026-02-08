# =============================================================================
# 03_clean_data.R
# Clean and prepare analysis dataset
# Merge QCEW with policy dates, handle missing data
# =============================================================================

source("output/paper_84/code/00_packages.R")

# =============================================================================
# Load data
# =============================================================================

qcew <- read_csv("output/paper_84/data/qcew_gambling.csv", show_col_types = FALSE)
policy <- read_csv("output/paper_84/data/policy_dates.csv", show_col_types = FALSE)

cat("Loaded QCEW with", nrow(qcew), "observations\n")
cat("Loaded policy dates for", nrow(policy), "states\n")

# =============================================================================
# Prepare QCEW data for merge
# =============================================================================

# The QCEW data has state_fips as area_fips (with "000" suffix stripped)
qcew_clean <- qcew %>%
  mutate(
    # Extract 2-digit state FIPS from area_fips
    state_fips = str_sub(as.character(area_fips), 1, 2),
    # Mark suppressed observations
    suppressed = disclosure_code == "N" | employment == 0,
    # Clean employment (treat suppressed as NA for analysis)
    employment_clean = if_else(suppressed, NA_real_, as.numeric(employment))
  ) %>%
  filter(industry_code == "7132") %>%  # NAICS 7132 only
  select(state_fips, year, employment, employment_clean, suppressed,
         establishments, total_wages, weekly_wage)

cat("\nQCEW by year:\n")
qcew_clean %>% count(year) %>% print()

# =============================================================================
# Merge with policy dates
# =============================================================================

panel <- qcew_clean %>%
  left_join(policy, by = "state_fips") %>%
  filter(!is.na(state_abbr)) %>%  # Drop any unmatched
  mutate(
    # Treatment indicator
    treated = if_else(first_treat_year > 0 & year >= first_treat_year, 1L, 0L),
    # Relative time (event time)
    rel_time = if_else(first_treat_year > 0, year - first_treat_year, NA_integer_),
    # Create state numeric ID for did package
    state_id = as.integer(factor(state_fips)),
    # Group variable for did package (0 = never treated, year otherwise)
    G = first_treat_year
  )

cat("\nPanel dimensions:\n")
cat("  States:", n_distinct(panel$state_fips), "\n")
cat("  Years:", n_distinct(panel$year), "\n")
cat("  Observations:", nrow(panel), "\n")

# =============================================================================
# Check balance and suppression
# =============================================================================

cat("\n=== Suppression by treatment status ===\n")
panel %>%
  mutate(treat_status = if_else(G > 0, "Treated", "Never-treated")) %>%
  group_by(treat_status) %>%
  summarise(
    n_obs = n(),
    n_suppressed = sum(suppressed),
    pct_suppressed = round(100 * n_suppressed / n_obs, 1),
    .groups = "drop"
  ) %>%
  print()

cat("\n=== Observations by treatment cohort ===\n")
panel %>%
  group_by(G) %>%
  summarise(
    n_states = n_distinct(state_fips),
    n_obs = n(),
    states = paste(unique(state_abbr), collapse = ", "),
    .groups = "drop"
  ) %>%
  arrange(G) %>%
  print(n = 10)

# =============================================================================
# Summary statistics for paper
# =============================================================================

cat("\n=== Summary Statistics ===\n")

# Pre-treatment means by treatment status
pre_treatment <- panel %>%
  filter(year < 2018 | (G == 0)) %>%  # Pre-Murphy for all
  filter(!suppressed)

cat("\nPre-treatment employment (non-suppressed):\n")
pre_treatment %>%
  mutate(treat_status = if_else(G > 0, "Eventually Treated", "Never Treated")) %>%
  group_by(treat_status) %>%
  summarise(
    n_states = n_distinct(state_fips),
    mean_emp = mean(employment, na.rm = TRUE),
    sd_emp = sd(employment, na.rm = TRUE),
    median_emp = median(employment, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  print()

# =============================================================================
# Save analysis panel
# =============================================================================

write_csv(panel, "output/paper_84/data/analysis_panel.csv")

cat("\n\nAnalysis panel saved to data/analysis_panel.csv\n")
cat("Total observations:", nrow(panel), "\n")
cat("Treated states:", sum(panel$G > 0) / n_distinct(panel$year), "\n")
cat("Never-treated states:", sum(panel$G == 0) / n_distinct(panel$year), "\n")
