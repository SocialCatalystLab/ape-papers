# =============================================================================
# 03_clean_data.R
# Merge QCEW with Policy Data and Construct Analysis Variables
# Sports Betting Employment Effects - Revision of apep_0038
# =============================================================================

source("00_packages.R")

# -----------------------------------------------------------------------------
# Load Data
# -----------------------------------------------------------------------------

message("Loading data...")

# Load policy panel
state_quarter_panel <- read_csv("../data/state_quarter_panel.csv", show_col_types = FALSE)
policy_panel <- read_csv("../data/policy_panel.csv", show_col_types = FALSE)

# Load QCEW data (try quarterly first, fall back to annual)
if (file.exists("../data/qcew_quarterly.csv")) {
  qcew <- read_csv("../data/qcew_quarterly.csv", show_col_types = FALSE)
  data_freq <- "quarterly"
  message("Using quarterly QCEW data")
} else if (file.exists("../data/qcew_annual.csv")) {
  qcew <- read_csv("../data/qcew_annual.csv", show_col_types = FALSE)
  data_freq <- "annual"
  message("Using annual QCEW data")
} else {
  stop("No QCEW data found. Run 01_fetch_qcew.R first.")
}

# -----------------------------------------------------------------------------
# Clean QCEW Data
# -----------------------------------------------------------------------------

if (data_freq == "annual") {
  # Reshape annual data to wide format for different industries
  qcew_wide <- qcew %>%
    filter(industry_code == "7132") %>%  # Gambling industries
    rename(
      empl_7132 = total_empl,
      estabs_7132 = total_estabs,
      wages_7132 = total_wages
    ) %>%
    select(year, state_fips, state_abbr, empl_7132, estabs_7132, wages_7132)

  # Add placebo industries
  qcew_mfg <- qcew %>%
    filter(industry_code == "31-33") %>%
    rename(empl_mfg = total_empl) %>%
    select(year, state_fips, empl_mfg)

  qcew_ag <- qcew %>%
    filter(industry_code == "11") %>%
    rename(empl_ag = total_empl) %>%
    select(year, state_fips, empl_ag)

  # Add subsectors if available
  qcew_713210 <- qcew %>%
    filter(industry_code == "713210") %>%
    rename(empl_casinos = total_empl) %>%
    select(year, state_fips, empl_casinos)

  qcew_713290 <- qcew %>%
    filter(industry_code == "713290") %>%
    rename(empl_other_gambling = total_empl) %>%
    select(year, state_fips, empl_other_gambling)

  # Merge all outcomes
  qcew_clean <- qcew_wide %>%
    left_join(qcew_mfg, by = c("year", "state_fips")) %>%
    left_join(qcew_ag, by = c("year", "state_fips")) %>%
    left_join(qcew_713210, by = c("year", "state_fips")) %>%
    left_join(qcew_713290, by = c("year", "state_fips"))

  # Create year-quarter variable (annual = Q4 of each year for matching)
  qcew_clean <- qcew_clean %>%
    mutate(
      quarter = 4,
      year_quarter = year + 0.75
    )

} else {
  # Process quarterly data
  qcew_clean <- qcew %>%
    filter(own_code == 5, industry_code == "7132") %>%
    mutate(
      state_fips = sprintf("%02d", as.integer(area_fips)),
      empl_7132 = (month1_emplvl + month2_emplvl + month3_emplvl) / 3,
      year_quarter = year + (quarter - 1) / 4
    ) %>%
    select(year, quarter, year_quarter, state_fips, empl_7132,
           qtrly_estabs, total_qtrly_wages, avg_wkly_wage)
}

# -----------------------------------------------------------------------------
# Merge with Policy Panel
# -----------------------------------------------------------------------------

message("Merging with policy panel...")

# Get state info
state_info <- policy_panel %>%
  select(state_abbr, state_fips, state_name, ever_treated_sb, sb_type,
         sb_year_quarter, has_mobile, has_igaming, igaming_year)

# Merge QCEW with state info
# Remove state_abbr from qcew_clean if it exists to avoid duplicate columns
if ("state_abbr" %in% names(qcew_clean)) {
  qcew_clean <- qcew_clean %>% select(-state_abbr)
}

analysis_data <- qcew_clean %>%
  left_join(state_info, by = "state_fips") %>%
  filter(!is.na(state_abbr))

# Create treatment variables
analysis_data <- analysis_data %>%
  mutate(
    # Exclude Nevada (always treated)
    exclude_nv = state_abbr == "NV",

    # Sports betting treatment
    treated = case_when(
      exclude_nv ~ NA_real_,
      is.na(sb_year_quarter) ~ 0,
      year_quarter >= sb_year_quarter ~ 1,
      TRUE ~ 0
    ),

    # Treatment cohort (for Callaway-Sant'Anna)
    # Use 0 for never-treated
    cohort = case_when(
      exclude_nv ~ NA_real_,
      is.na(sb_year_quarter) ~ 0,
      TRUE ~ sb_year_quarter
    ),

    # Event time
    event_time = if_else(!is.na(sb_year_quarter),
                         year_quarter - sb_year_quarter,
                         NA_real_),

    # iGaming treatment (confounder)
    igaming_treated = case_when(
      is.na(igaming_year) ~ 0,
      year >= igaming_year ~ 1,
      TRUE ~ 0
    ),

    # Pre-COVID period
    pre_covid = year < 2020,

    # Cohort groups for heterogeneity
    cohort_group = case_when(
      is.na(sb_year_quarter) ~ "Never treated",
      sb_year_quarter < 2019 ~ "Early (2018)",
      sb_year_quarter < 2020 ~ "2019",
      sb_year_quarter < 2021 ~ "2020 (COVID)",
      sb_year_quarter < 2022 ~ "2021",
      sb_year_quarter < 2023 ~ "2022",
      TRUE ~ "2023+"
    )
  )

# -----------------------------------------------------------------------------
# Create Analysis Sample
# -----------------------------------------------------------------------------

message("Creating analysis sample...")

# Main sample: Exclude Nevada, keep 2010-2024
analysis_sample <- analysis_data %>%
  filter(
    !exclude_nv,
    year >= 2010,
    year <= 2024
  )

# Summary statistics
message("\nSample Summary:")
message(sprintf("  Total state-year observations: %d", nrow(analysis_sample)))
message(sprintf("  States: %d", n_distinct(analysis_sample$state_abbr)))
message(sprintf("  Years: %d to %d", min(analysis_sample$year), max(analysis_sample$year)))
message(sprintf("  Ever-treated states: %d",
                n_distinct(analysis_sample$state_abbr[analysis_sample$ever_treated_sb])))
message(sprintf("  Never-treated states: %d",
                n_distinct(analysis_sample$state_abbr[!analysis_sample$ever_treated_sb])))

# Treatment timing summary
treatment_timing <- analysis_sample %>%
  filter(ever_treated_sb) %>%
  group_by(state_abbr, sb_year_quarter) %>%
  slice(1) %>%
  ungroup() %>%
  group_by(year = floor(sb_year_quarter)) %>%
  summarise(
    n_states = n(),
    states = paste(state_abbr, collapse = ", "),
    .groups = "drop"
  )

message("\nTreatment Timing:")
print(treatment_timing)

# -----------------------------------------------------------------------------
# Variable Transformations
# -----------------------------------------------------------------------------

analysis_sample <- analysis_sample %>%
  group_by(state_abbr) %>%
  mutate(
    # Log employment (handling zeros)
    log_empl_7132 = log(pmax(empl_7132, 1)),

    # Employment growth
    empl_growth = (empl_7132 - lag(empl_7132)) / lag(empl_7132),

    # Standardized employment (for comparability)
    empl_std = (empl_7132 - mean(empl_7132, na.rm = TRUE)) /
               sd(empl_7132, na.rm = TRUE)
  ) %>%
  ungroup()

# -----------------------------------------------------------------------------
# Create Neighbor Exposure Variable (for spillovers)
# -----------------------------------------------------------------------------

# State adjacency matrix (simplified - major neighbors only)
state_neighbors <- tribble(
  ~state, ~neighbors,
  "NJ", "NY,PA,DE",
  "PA", "NJ,NY,DE,MD,WV,OH",
  "NY", "NJ,PA,CT,MA,VT",
  "CT", "NY,MA,RI",
  "MA", "NY,CT,RI,NH,VT",
  "MI", "OH,IN,WI",
  "IL", "WI,IN,KY,MO,IA",
  "OH", "PA,WV,KY,IN,MI",
  "IN", "IL,MI,OH,KY",
  "IA", "MN,WI,IL,MO,NE,SD",
  "CO", "WY,NE,KS,OK,NM,UT,AZ"
  # Add more as needed
)

# Calculate neighbor treatment exposure
# (proportion of neighbors that have legalized)
# This would require the full adjacency matrix - simplified for now

# -----------------------------------------------------------------------------
# Balance Table Data
# -----------------------------------------------------------------------------

balance_data <- analysis_sample %>%
  filter(year == 2017) %>%  # Pre-treatment year
  group_by(ever_treated_sb) %>%
  summarise(
    n_states = n(),
    mean_empl = mean(empl_7132, na.rm = TRUE),
    sd_empl = sd(empl_7132, na.rm = TRUE),
    mean_estabs = mean(estabs_7132, na.rm = TRUE),
    .groups = "drop"
  )

message("\nBalance (2017 pre-treatment):")
print(balance_data)

# -----------------------------------------------------------------------------
# Save Analysis Data
# -----------------------------------------------------------------------------

write_csv(analysis_sample, "../data/analysis_sample.csv")
message("\nSaved: ../data/analysis_sample.csv")

# Also save a version for Callaway-Sant'Anna
# The `did` package expects specific variable names
cs_data <- analysis_sample %>%
  mutate(
    # Cohort must be integer year for did package
    G = if_else(is.na(sb_year_quarter), 0, floor(sb_year_quarter)),
    # Time period must be integer
    t = year
  ) %>%
  select(
    state_abbr, state_fips, year, t, G,
    empl_7132, log_empl_7132, empl_std,
    treated, ever_treated_sb, pre_covid,
    has_mobile, igaming_treated
  )

write_csv(cs_data, "../data/cs_analysis_data.csv")
message("Saved: ../data/cs_analysis_data.csv")

message("\nData cleaning complete.")
