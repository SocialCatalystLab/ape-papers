# ==============================================================================
# 02_fetch_outcome_data.R
# Paper 96: Telehealth Parity Laws and Mental Health Treatment Utilization
# Description: Fetch BRFSS mental health data from CDC API
# ==============================================================================

source("00_packages.R")

# ==============================================================================
# Data Sources
# ==============================================================================

# Primary: CDC BRFSS (Behavioral Risk Factor Surveillance System)
# - State-level prevalence estimates
# - Available via CDC Chronic Data API
# - Key indicator: "Ever told you have a form of depression" (prevalence)
#
# Note: This measures depression prevalence, not mental health treatment.
# Depression prevalence captures a related but distinct outcome:
# - Higher prevalence in states with better access/detection suggests
#   diagnosis effects rather than true prevalence differences
# - Treatment effects via telehealth may show up as changes in diagnosed
#   depression rates (improved access → more diagnoses)
#
# Limitation: BRFSS does not directly measure mental health treatment utilization.
# We use depression diagnosis as a proxy, noting this captures:
# 1. True prevalence differences
# 2. Access/detection effects (telehealth may improve diagnosis)
# 3. Reporting differences

# ==============================================================================
# Fetch BRFSS Data from CDC API
# ==============================================================================

message("=== Fetching BRFSS Mental Health Data ===")

# CDC Chronic Data API endpoint
api_base <- "https://chronicdata.cdc.gov/resource/dttw-5yxu.json"

# Query parameters
query_params <- list(
  `$select` = paste(
    "year",
    "locationabbr",
    "locationdesc",
    "data_value",
    "sample_size",
    "confidence_limit_low",
    "confidence_limit_high",
    sep = ","
  ),
  `$where` = "topic='Depression' AND response='Yes' AND break_out='Overall'",
  `$limit` = 5000
)

# Fetch data
response <- GET(api_base, query = query_params, timeout(120))

if (status_code(response) != 200) {
  stop(paste("API request failed with status:", status_code(response)))
}

# Parse response
content_text <- content(response, as = "text", encoding = "UTF-8")
brfss_raw <- fromJSON(content_text)

message(paste("Retrieved", nrow(brfss_raw), "records from CDC API"))

# ==============================================================================
# Clean and Process Data
# ==============================================================================

brfss_depression <- brfss_raw %>%
  as_tibble() %>%
  mutate(
    year = as.integer(year),
    depression_pct = as.numeric(data_value),
    sample_size = as.integer(sample_size),
    ci_low = as.numeric(confidence_limit_low),
    ci_high = as.numeric(confidence_limit_high),

    # Rename location
    state_abbr = locationabbr,
    state = locationdesc
  ) %>%
  select(year, state_abbr, state, depression_pct, sample_size, ci_low, ci_high) %>%
  # Filter to analysis period (2011-2019, pre-COVID)
  filter(year >= 2011, year <= 2019) %>%
  # Exclude territories
  filter(!state_abbr %in% c("PR", "VI", "GU", "AS", "MP")) %>%
  arrange(state_abbr, year)

# Check coverage
message("\n=== Data Coverage ===")
message(paste("Years:", min(brfss_depression$year), "-", max(brfss_depression$year)))
message(paste("States:", n_distinct(brfss_depression$state_abbr)))
message(paste("Total observations:", nrow(brfss_depression)))

# Check balance
state_year_counts <- brfss_depression %>%
  count(state_abbr, name = "n_years") %>%
  count(n_years, name = "n_states")

message("\nPanel balance:")
print(state_year_counts)

# ==============================================================================
# Summary Statistics
# ==============================================================================

message("\n=== Summary Statistics ===")

annual_summary <- brfss_depression %>%
  group_by(year) %>%
  summarize(
    mean_depression = mean(depression_pct, na.rm = TRUE),
    sd_depression = sd(depression_pct, na.rm = TRUE),
    min_depression = min(depression_pct, na.rm = TRUE),
    max_depression = max(depression_pct, na.rm = TRUE),
    n_states = n(),
    .groups = "drop"
  )

print(annual_summary)

# State-level variation
state_summary <- brfss_depression %>%
  group_by(state_abbr, state) %>%
  summarize(
    mean_depression = mean(depression_pct, na.rm = TRUE),
    n_years = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(mean_depression))

message("\nHighest depression prevalence states (2011-2019 average):")
print(head(state_summary, 10))

message("\nLowest depression prevalence states (2011-2019 average):")
print(tail(state_summary, 10))

# ==============================================================================
# Create State Name Mapping
# ==============================================================================

# For merging with policy data
state_mapping <- brfss_depression %>%
  distinct(state_abbr, state) %>%
  arrange(state_abbr)

# ==============================================================================
# Merge with Policy Data
# ==============================================================================

message("\n=== Merging with Policy Data ===")

# Read policy data
policy_data <- read_csv("../data/telehealth_parity_laws.csv", show_col_types = FALSE)
panel_data <- read_csv("../data/state_year_panel.csv", show_col_types = FALSE)

# Check state name matching
policy_states <- unique(policy_data$state)
outcome_states <- unique(brfss_depression$state)

# States in policy but not in outcome
missing_in_outcome <- setdiff(policy_states, outcome_states)
if (length(missing_in_outcome) > 0) {
  message("States in policy data but not in outcome data:")
  print(missing_in_outcome)
}

# States in outcome but not in policy
extra_in_outcome <- setdiff(outcome_states, policy_states)
if (length(extra_in_outcome) > 0) {
  message("States in outcome data but not in policy data:")
  print(extra_in_outcome)
}

# Merge
analysis_data <- panel_data %>%
  filter(year >= 2011, year <= 2019) %>%
  left_join(
    brfss_depression %>% select(state, year, depression_pct, sample_size, ci_low, ci_high),
    by = c("state", "year")
  )

# Check merge success
merge_success <- analysis_data %>%
  summarize(
    n_total = n(),
    n_with_outcome = sum(!is.na(depression_pct)),
    pct_matched = n_with_outcome / n_total * 100
  )

message(paste("\nMerge success:", round(merge_success$pct_matched, 1), "% matched"))

# ==============================================================================
# Save Processed Data
# ==============================================================================

write_csv(brfss_depression, "../data/brfss_depression_2011_2019.csv")
write_csv(analysis_data, "../data/analysis_panel.csv")
write_csv(state_mapping, "../data/state_mapping.csv")

message("\n=== Data Saved ===")
message("- brfss_depression_2011_2019.csv")
message("- analysis_panel.csv")
message("- state_mapping.csv")

# ==============================================================================
# Descriptive Plot
# ==============================================================================

# National trend
national_trend <- brfss_depression %>%
  group_by(year) %>%
  summarize(
    depression_pct = weighted.mean(depression_pct, sample_size, na.rm = TRUE),
    .groups = "drop"
  )

p_trend <- ggplot(national_trend, aes(x = year, y = depression_pct)) +
  geom_line(linewidth = 1, color = apep_colors["treatment"]) +
  geom_point(size = 2, color = apep_colors["treatment"]) +
  scale_x_continuous(breaks = 2011:2019) +
  scale_y_continuous(limits = c(0, NA)) +
  labs(
    title = "National Depression Prevalence Trend (2011-2019)",
    subtitle = "BRFSS: % Adults ever told they have depression",
    x = "Year",
    y = "Prevalence (%)",
    caption = "Source: CDC BRFSS via Chronic Data API"
  )

save_figure(p_trend, "fig1_depression_trend", width = 8, height = 5)

# ==============================================================================
# Outcome Variable Description
# ==============================================================================

message("\n=== Outcome Variable ===")
message("Variable: depression_pct")
message("Definition: % of adults ever told they have a form of depression")
message("Source: CDC BRFSS (Behavioral Risk Factor Surveillance System)")
message("Note: This is a diagnosis-based measure, not treatment utilization")
message("")
message("Interpretation for telehealth study:")
message("- If telehealth improves access, more people may be diagnosed")
message("- Increases in diagnosis could reflect improved detection, not true prevalence")
message("- This is a conservative test of telehealth effects on mental health care access")
