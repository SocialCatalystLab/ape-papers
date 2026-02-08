# =============================================================================
# 02_clean_data.R - Clean and prepare analysis dataset
# Paper 85: Paid Family Leave and Female Entrepreneurship
# =============================================================================

source("00_packages.R")

# -----------------------------------------------------------------------------
# Load Data
# -----------------------------------------------------------------------------

df_raw <- read_csv("../data/acs_selfemployment.csv", show_col_types = FALSE)

message("Loaded ", nrow(df_raw), " observations")

# -----------------------------------------------------------------------------
# Clean Data
# -----------------------------------------------------------------------------

df <- df_raw %>%
  # Filter to 50 states + DC (exclude Puerto Rico and other territories)
  filter(state_fips %in% valid_fips) %>%
  # Exclude year 2020 (COVID disruption, already missing from ACS 1-year)
  filter(!is.na(year)) %>%
  # Drop partial-year treatment observations to ensure clean pre/post periods:
  # - NJ 2009: benefits began July 2009 (6 months exposure)
  # - DC 2020: benefits began July 2020 (6 months exposure)
  # - OR 2023: benefits began Sept 2023 (4 months exposure)
  filter(!(state_abbr == "NJ" & year == 2009)) %>%
  filter(!(state_abbr == "DC" & year == 2020)) %>%
  filter(!(state_abbr == "OR" & year == 2023)) %>%
  # Create numeric state ID for panel
  mutate(state_id = as.numeric(factor(state_abbr))) %>%
  # For Callaway-Sant'Anna, cohort must be 0 for never-treated
  mutate(
    cohort_cs = ifelse(treated, first_full_year, 0)
  ) %>%
  arrange(state_abbr, year)

# Summary
message("\n=== CLEANED DATA SUMMARY ===")
message("Years: ", min(df$year), " - ", max(df$year))
message("Unique years: ", n_distinct(df$year))
message("States: ", n_distinct(df$state_abbr))
message("Total observations: ", nrow(df))

# Treatment summary
treatment_summary <- df %>%
  group_by(state_abbr, treated, cohort_cs) %>%
  summarise(n_years = n(), .groups = "drop")

message("\n--- Treatment Summary ---")
message("Treated states: ", sum(treatment_summary$treated))
message("Never-treated states: ", sum(!treatment_summary$treated))

# Print treated states with cohorts
message("\nTreated states by cohort:")
treatment_summary %>%
  filter(treated) %>%
  arrange(cohort_cs) %>%
  print()

# -----------------------------------------------------------------------------
# Descriptive Statistics
# -----------------------------------------------------------------------------

desc_stats <- df %>%
  summarise(
    across(
      c(female_selfempl_rate, male_selfempl_rate, total_selfempl_rate,
        female_selfempl_inc_rate, female_selfempl_uninc_rate),
      list(
        mean = ~mean(.x, na.rm = TRUE),
        sd = ~sd(.x, na.rm = TRUE),
        min = ~min(.x, na.rm = TRUE),
        max = ~max(.x, na.rm = TRUE)
      )
    )
  )

message("\n--- Descriptive Statistics: Self-Employment Rates ---")
message("Female SE Rate: Mean = ", round(desc_stats$female_selfempl_rate_mean, 2),
        "%, SD = ", round(desc_stats$female_selfempl_rate_sd, 2), "%")
message("Male SE Rate: Mean = ", round(desc_stats$male_selfempl_rate_mean, 2),
        "%, SD = ", round(desc_stats$male_selfempl_rate_sd, 2), "%")

# By treatment status
desc_by_treat <- df %>%
  group_by(treated) %>%
  summarise(
    mean_female_se = mean(female_selfempl_rate, na.rm = TRUE),
    sd_female_se = sd(female_selfempl_rate, na.rm = TRUE),
    n_obs = n()
  )

message("\n--- By Treatment Status ---")
print(desc_by_treat)

# Pre vs Post for treated states
desc_pre_post <- df %>%
  filter(treated) %>%
  group_by(post) %>%
  summarise(
    mean_female_se = mean(female_selfempl_rate, na.rm = TRUE),
    sd_female_se = sd(female_selfempl_rate, na.rm = TRUE),
    n_obs = n()
  )

message("\n--- Treated States: Pre vs Post ---")
print(desc_pre_post)

# -----------------------------------------------------------------------------
# Save Analysis Dataset
# -----------------------------------------------------------------------------

write_csv(df, "../data/analysis_data.csv")
saveRDS(df, "../data/analysis_data.rds")

message("\nAnalysis dataset saved to data/analysis_data.csv and data/analysis_data.rds")
message("Ready for analysis.")
