# ============================================================================
# Paper 74: Dental Therapy and Oral Health Access
# 02_fetch_brfss_api.R - Fetch BRFSS data via CDC API
# ============================================================================

source("output/paper_74/code/00_packages.R")
library(httr)
library(jsonlite)

# Create data directory
dir.create("output/paper_74/data", recursive = TRUE, showWarnings = FALSE)
dir.create("output/paper_74/figures", recursive = TRUE, showWarnings = FALSE)

# ============================================================================
# Approach: Use CDC's Chronic Disease Indicators API
# ============================================================================
#
# The CDC's Chronic Disease Indicators (CDI) API provides pre-aggregated
# state-level health indicators including dental health measures.
#
# API: https://data.cdc.gov/resource/g4ie-h725.json
#
# Dental indicators available:
# - Dental visit (Adults aged 18+ who visited dentist in past year)
# - Untreated tooth decay
# - No teeth lost (adults 65+)
# ============================================================================

cat("Fetching dental health data from CDC Chronic Disease Indicators API...\n\n")

# CDI API endpoint
cdi_url <- "https://data.cdc.gov/resource/g4ie-h725.json"

# Query for oral health topic
# Topic: Oral Health
# Limit: 50000 to get all records

query <- paste0(
  cdi_url,
  "?topic=Oral%20Health",
  "&$limit=50000"
)

response <- GET(query)

if (status_code(response) != 200) {
  stop("API request failed with status: ", status_code(response))
}

cdi_data <- fromJSON(content(response, "text"))

cat(sprintf("Retrieved %d records\n", nrow(cdi_data)))

# ============================================================================
# Filter to Dental Visit Indicator
# ============================================================================

# Available questions:
unique(cdi_data$question) %>% head(20)

# Find dental visit in past year question
dental_visits <- cdi_data %>%
  filter(grepl("dental", question, ignore.case = TRUE)) %>%
  filter(grepl("visit|visited", question, ignore.case = TRUE))

cat("\nAvailable dental visit indicators:\n")
dental_visits %>%
  distinct(question) %>%
  pull(question) %>%
  cat(sep = "\n")

# Use: "Visits to dentist or dental clinic among adults aged >= 18 years"
# This is the closest to our desired measure

dental_data <- cdi_data %>%
  filter(grepl("Visits to dentist", question, ignore.case = TRUE)) %>%
  filter(datavaluetypeid == "CrdPrv") %>%  # Crude prevalence
  filter(datavalueunit == "%") %>%
  select(
    year = yearstart,
    state = locationabbr,
    state_name = locationdesc,
    question,
    data_value = datavalue,
    sample_size = sample_size,
    low_ci = lowconfidencelimit,
    high_ci = highconfidencelimit
  ) %>%
  mutate(
    year = as.integer(year),
    data_value = as.numeric(data_value),
    sample_size = as.integer(sample_size),
    low_ci = as.numeric(low_ci),
    high_ci = as.numeric(high_ci),
    dental_visit_rate = data_value / 100  # Convert percentage to proportion
  ) %>%
  filter(
    !is.na(data_value),
    !state %in% c("US", "GU", "PR", "VI")  # Remove national and territories
  )

cat(sprintf("\nDental visit data: %d state-year observations\n", nrow(dental_data)))
cat(sprintf("Years: %d to %d\n", min(dental_data$year), max(dental_data$year)))
cat(sprintf("States: %d\n", n_distinct(dental_data$state)))

# ============================================================================
# Also Get Teeth Removed Data (if available)
# ============================================================================

teeth_data <- cdi_data %>%
  filter(grepl("teeth", question, ignore.case = TRUE)) %>%
  filter(datavaluetypeid == "CrdPrv") %>%
  select(
    year = yearstart,
    state = locationabbr,
    state_name = locationdesc,
    question,
    teeth_value = datavalue
  ) %>%
  mutate(
    year = as.integer(year),
    teeth_value = as.numeric(teeth_value)
  ) %>%
  filter(!is.na(teeth_value))

cat("\nTeeth-related indicators:\n")
teeth_data %>% distinct(question) %>% pull(question) %>% head(10) %>% cat(sep = "\n")

# ============================================================================
# Create State FIPS Lookup
# ============================================================================

state_fips_lookup <- tibble(
  state = c(
    "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "FL",
    "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME",
    "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH",
    "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI",
    "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"
  ),
  state_fips = c(
    "01", "02", "04", "05", "06", "08", "09", "10", "11", "12",
    "13", "15", "16", "17", "18", "19", "20", "21", "22", "23",
    "24", "25", "26", "27", "28", "29", "30", "31", "32", "33",
    "34", "35", "36", "37", "38", "39", "40", "41", "42", "44",
    "45", "46", "47", "48", "49", "50", "51", "53", "54", "55", "56"
  )
)

# ============================================================================
# Merge with Treatment Timing
# ============================================================================

# Load treatment data
treatment_data <- readRDS("output/paper_74/data/treatment_timing.rds")

# Merge
analysis_data <- dental_data %>%
  left_join(state_fips_lookup, by = "state") %>%
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
    first_treat = if_else(treatment_year == 0, 0L, as.integer(treatment_year))
  )

# Check coverage
cat("\n========================================\n")
cat("DATA COVERAGE\n")
cat("========================================\n")

cat("\nYears by state:\n")
analysis_data %>%
  group_by(state) %>%
  summarise(
    min_year = min(year),
    max_year = max(year),
    n_years = n()
  ) %>%
  arrange(state) %>%
  print(n = 60)

cat("\nTreatment timing:\n")
analysis_data %>%
  filter(treated == 1) %>%
  distinct(state, state_full, treatment_year) %>%
  arrange(treatment_year) %>%
  print(n = 20)

cat("\nSample sizes by treatment status:\n")
analysis_data %>%
  group_by(treated) %>%
  summarise(
    n_obs = n(),
    n_states = n_distinct(state),
    mean_visit_rate = mean(dental_visit_rate, na.rm = TRUE),
    sd_visit_rate = sd(dental_visit_rate, na.rm = TRUE)
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

# By treatment status
p_trends <- analysis_data %>%
  mutate(group = if_else(treated == 1, "Adopter States", "Never-Adopter States")) %>%
  group_by(year, group) %>%
  summarise(
    dental_visit_rate = mean(dental_visit_rate, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  ggplot(aes(x = year, y = dental_visit_rate, color = group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2.5) +
  scale_color_manual(values = apep_colors[1:2]) +
  scale_y_continuous(labels = percent_format(), limits = c(0.5, 0.75)) +
  scale_x_continuous(breaks = seq(2010, 2024, 2)) +
  labs(
    title = "Dental Visit Rates by Treatment Status",
    subtitle = "Adults who visited dentist in past year, BRFSS/CDI data",
    x = "Year",
    y = "Proportion Visiting Dentist",
    color = NULL
  ) +
  theme_apep() +
  theme(legend.position = c(0.2, 0.9))

ggsave("output/paper_74/figures/raw_trends.pdf", p_trends, width = 8, height = 5)
ggsave("output/paper_74/figures/raw_trends.png", p_trends, width = 8, height = 5, dpi = 300)

cat("\nRaw trends plot saved to figures/\n")

# By cohort
p_cohorts <- analysis_data %>%
  filter(treated == 1) %>%
  mutate(cohort = factor(treatment_year)) %>%
  ggplot(aes(x = year, y = dental_visit_rate, color = cohort, group = state)) +
  geom_line(alpha = 0.6) +
  geom_point(size = 1.5, alpha = 0.6) +
  geom_vline(aes(xintercept = treatment_year), linetype = "dashed", alpha = 0.3) +
  facet_wrap(~cohort, nrow = 2) +
  scale_y_continuous(labels = percent_format()) +
  scale_color_viridis_d() +
  labs(
    title = "Dental Visit Rates by Adoption Cohort",
    subtitle = "Dashed lines indicate treatment year for each cohort",
    x = "Year",
    y = "Proportion Visiting Dentist",
    color = "Cohort"
  ) +
  theme_apep() +
  theme(legend.position = "none")

ggsave("output/paper_74/figures/trends_by_cohort.pdf", p_cohorts, width = 10, height = 6)
ggsave("output/paper_74/figures/trends_by_cohort.png", p_cohorts, width = 10, height = 6, dpi = 300)

cat("Cohort trends plot saved to figures/\n")
