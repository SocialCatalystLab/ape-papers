# ============================================================================
# Paper 74: Dental Therapy and Oral Health Access
# 02_process_nohss.R - Process NOHSS Adult Oral Health Indicators
# ============================================================================

source("output/paper_74/code/00_packages.R")

# ============================================================================
# Load NOHSS Data
# ============================================================================

cat("Loading NOHSS Adult Oral Health Indicators...\n")

nohss <- read_csv("output/paper_74/data/nohss_adult_indicators.csv",
                  show_col_types = FALSE)

cat(sprintf("Total rows: %s\n", format(nrow(nohss), big.mark = ",")))

# ============================================================================
# Filter to Dental Visit Indicator (Overall, All Adults)
# ============================================================================

# Available indicators
cat("\nAvailable indicators:\n")
nohss %>% distinct(Indicator) %>% pull(Indicator) %>% cat(sep = "\n")

# Filter to:
# - Dental visit indicator
# - Response = "Yes" (visited dentist)
# - Break_Out_Category = "None" (overall, not by subgroup)

dental_visits <- nohss %>%
  filter(
    grepl("visited a dentist", Indicator, ignore.case = TRUE),
    Response == "Yes",
    Break_Out_Category == "None"
  ) %>%
  select(
    year = Year,
    state = LocationAbbr,
    state_name = LocationDesc,
    data_value = Data_Value,
    low_ci = Low_Confidence_Interval,
    high_ci = High_Confidence_Interval,
    sample_size = SampleSize,
    state_fips = LocationID
  ) %>%
  mutate(
    year = as.integer(year),
    dental_visit_rate = as.numeric(data_value) / 100,  # Convert % to proportion
    low_ci = as.numeric(low_ci) / 100,
    high_ci = as.numeric(high_ci) / 100,
    sample_size = as.integer(sample_size),
    state_fips = sprintf("%02d", as.integer(state_fips))
  ) %>%
  filter(
    !is.na(dental_visit_rate),
    !state %in% c("US", "GU", "PR", "VI", "DC")  # Exclude territories and DC
  ) %>%
  # Deduplicate: take weighted average if multiple observations per state-year
  group_by(year, state, state_name, state_fips) %>%
  summarise(
    dental_visit_rate = weighted.mean(dental_visit_rate, sample_size, na.rm = TRUE),
    low_ci = mean(low_ci, na.rm = TRUE),
    high_ci = mean(high_ci, na.rm = TRUE),
    sample_size = sum(sample_size, na.rm = TRUE),
    .groups = "drop"
  )

cat(sprintf("\nDental visit data: %d state-year observations\n", nrow(dental_visits)))
cat(sprintf("Years: %d to %d\n", min(dental_visits$year), max(dental_visits$year)))
cat(sprintf("States: %d\n", n_distinct(dental_visits$state)))

# Check year coverage
cat("\nYear coverage:\n")
dental_visits %>% count(year) %>% print()

# ============================================================================
# Merge with Treatment Timing
# ============================================================================

treatment_data <- readRDS("output/paper_74/data/treatment_timing.rds")

analysis_data <- dental_visits %>%
  left_join(
    treatment_data %>% select(state_fips, state_full = state, treatment_year),
    by = "state_fips"
  ) %>%
  mutate(
    # Post-treatment indicator
    post = if_else(treatment_year > 0 & year >= treatment_year, 1L, 0L),

    # Treated indicator (ever treated by end of sample)
    treated = if_else(treatment_year > 0, 1L, 0L),

    # Event time (years since treatment)
    event_time = if_else(treatment_year > 0, year - treatment_year, NA_integer_),

    # For Callaway-Sant'Anna: use 0 for never-treated
    first_treat = if_else(treatment_year == 0, 0L, as.integer(treatment_year)),

    # State numeric ID for clustering
    state_id = as.integer(factor(state_fips))
  )

# ============================================================================
# Data Quality Checks
# ============================================================================

cat("\n========================================\n")
cat("DATA COVERAGE BY TREATMENT STATUS\n")
cat("========================================\n")

# Check treated states have sufficient pre/post periods
treated_coverage <- analysis_data %>%
  filter(treated == 1) %>%
  group_by(state, state_full, treatment_year) %>%
  summarise(
    min_year = min(year),
    max_year = max(year),
    n_years = n(),
    n_pre = sum(year < treatment_year),
    n_post = sum(year >= treatment_year),
    .groups = "drop"
  ) %>%
  arrange(treatment_year)

cat("\nTreated states - pre/post coverage:\n")
print(treated_coverage, n = 15)

# States with <2 pre-treatment periods may be problematic
cat("\nStates with <2 pre-treatment periods:\n")
treated_coverage %>% filter(n_pre < 2) %>% print()

# Overall summary
cat("\nSample sizes by treatment status:\n")
analysis_data %>%
  group_by(treated) %>%
  summarise(
    n_obs = n(),
    n_states = n_distinct(state),
    mean_visit_rate = mean(dental_visit_rate, na.rm = TRUE),
    sd_visit_rate = sd(dental_visit_rate, na.rm = TRUE),
    mean_sample_size = mean(sample_size, na.rm = TRUE)
  ) %>%
  print()

# ============================================================================
# Save Analysis Data
# ============================================================================

saveRDS(analysis_data, "output/paper_74/data/analysis_data.rds")
write_csv(analysis_data, "output/paper_74/data/analysis_data.csv")

cat("\n========================================\n")
cat("Data saved to:\n")
cat("  - output/paper_74/data/analysis_data.rds\n")
cat("  - output/paper_74/data/analysis_data.csv\n")
cat("========================================\n")

# ============================================================================
# Visualize Raw Trends
# ============================================================================

dir.create("output/paper_74/figures", showWarnings = FALSE)

# By treatment status
p_trends <- analysis_data %>%
  mutate(group = if_else(treated == 1, "Adopter States", "Never-Adopter States")) %>%
  group_by(year, group) %>%
  summarise(
    dental_visit_rate = mean(dental_visit_rate, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  ggplot(aes(x = year, y = dental_visit_rate, color = group)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3) +
  scale_color_manual(values = apep_colors[1:2]) +
  scale_y_continuous(labels = percent_format(), limits = c(0.55, 0.75)) +
  scale_x_continuous(breaks = seq(2012, 2022, 2)) +
  labs(
    title = "Dental Visit Rates by Treatment Status",
    subtitle = "Adults who visited dentist in past year | NOHSS/BRFSS data, even years 2012-2020",
    x = "Year",
    y = "Proportion Visiting Dentist",
    color = NULL
  ) +
  theme_apep() +
  theme(legend.position = c(0.25, 0.15))

ggsave("output/paper_74/figures/raw_trends.pdf", p_trends, width = 9, height = 6)
ggsave("output/paper_74/figures/raw_trends.png", p_trends, width = 9, height = 6, dpi = 300)

cat("\nRaw trends plot saved.\n")

# By cohort - Use estimation cohort year (first post-authorization observation period)
treated_states <- analysis_data %>%
  filter(treated == 1) %>%
  mutate(
    # Map authorization year to estimation cohort year (first even year at/after auth)
    est_cohort_year = case_when(
      treatment_year == 2014 ~ 2014L,
      treatment_year <= 2016 ~ 2016L,
      treatment_year <= 2018 ~ 2018L,
      treatment_year <= 2020 ~ 2020L,
      TRUE ~ NA_integer_
    )
  )

p_cohorts <- treated_states %>%
  mutate(
    cohort_label = paste0(state, " (Auth: ", treatment_year, ", Est: ", est_cohort_year, ")"),
    pre_post = if_else(year < est_cohort_year, "Pre", "Post")
  ) %>%
  ggplot(aes(x = year, y = dental_visit_rate)) +
  geom_line(aes(group = state), color = apep_colors[1], linewidth = 0.8) +
  geom_point(aes(shape = pre_post), color = apep_colors[1], size = 2.5) +
  geom_vline(aes(xintercept = est_cohort_year), linetype = "dashed",
             color = "grey50", alpha = 0.7) +
  facet_wrap(~reorder(cohort_label, est_cohort_year), ncol = 4) +
  scale_y_continuous(labels = percent_format(), limits = c(0.5, 0.8)) +
  scale_shape_manual(values = c("Pre" = 1, "Post" = 16)) +
  labs(
    title = "Dental Visit Rates by Adopting State",
    subtitle = "Dashed lines = estimation cohort year (first post-auth observation) | Open circles = pre, filled = post",
    x = "Year",
    y = "Proportion",
    shape = NULL
  ) +
  theme_apep() +
  theme(
    legend.position = "bottom",
    strip.text = element_text(size = 9)
  )

ggsave("output/paper_74/figures/trends_by_state.pdf", p_cohorts, width = 12, height = 8)
ggsave("output/paper_74/figures/trends_by_state.png", p_cohorts, width = 12, height = 8, dpi = 300)

cat("State trends plot saved.\n")

cat("\nData processing complete!\n")
