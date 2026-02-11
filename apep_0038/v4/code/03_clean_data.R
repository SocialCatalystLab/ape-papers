# =============================================================================
# 03_clean_data.R
# Merge QCEW with Policy Data and Construct Analysis Variables
# Sports Betting Employment Effects - Revision of apep_0038 (v3)
# =============================================================================

source("00_packages.R")

# -----------------------------------------------------------------------------
# Load Data with Provenance Check
# -----------------------------------------------------------------------------

message("Loading data...")

# Load policy panel
state_quarter_panel <- read_csv("../data/state_quarter_panel.csv", show_col_types = FALSE)
policy_panel <- read_csv("../data/policy_panel.csv", show_col_types = FALSE)

# Load QCEW data — ONLY accept qcew_annual.csv from BLS fetch
if (!file.exists("../data/qcew_annual.csv")) {
  stop("No QCEW data found. Run 01_fetch_qcew.R first.\n",
       "Do NOT use simulated or cached data.")
}

# Verify provenance
if (file.exists("../data/qcew_provenance.json")) {
  provenance <- jsonlite::fromJSON("../data/qcew_provenance.json")
  message(sprintf("QCEW data provenance verified:"))
  message(sprintf("  Source: %s", provenance$source))
  message(sprintf("  Fetch date: %s", provenance$fetch_date))
  message(sprintf("  SHA256: %s", provenance$sha256))
  message(sprintf("  Observations: %d", provenance$n_observations))
} else {
  warning("No provenance file found for QCEW data. Run 01_fetch_qcew.R to generate.")
}

qcew <- read_csv("../data/qcew_annual.csv", show_col_types = FALSE)
data_freq <- "annual"
message(sprintf("Loaded QCEW annual data: %d rows", nrow(qcew)))

# Ensure consistent types for joins
qcew <- qcew %>%
  mutate(
    industry_code = as.character(industry_code),
    state_fips = sprintf("%02d", as.integer(state_fips))
  )

# Verify this is real BLS data (check for expected columns)
expected_cols <- c("year", "industry_code", "state_fips", "total_empl", "avg_wkly_wage")
missing_cols <- setdiff(expected_cols, names(qcew))
if (length(missing_cols) > 0) {
  stop("QCEW data missing expected columns: ", paste(missing_cols, collapse = ", "),
       "\nThis may not be real BLS data. Re-run 01_fetch_qcew.R.")
}

# -----------------------------------------------------------------------------
# Clean QCEW Data
# -----------------------------------------------------------------------------

# Gambling industries (NAICS 7132) - main outcome
qcew_wide <- qcew %>%
  filter(industry_code == "7132") %>%
  rename(
    empl_7132 = total_empl,
    estabs_7132 = total_estabs,
    wages_7132 = total_wages,
    wkly_wage_7132 = avg_wkly_wage
  ) %>%
  select(year, state_fips, state_abbr, empl_7132, estabs_7132, wages_7132, wkly_wage_7132)

# Placebo industries
qcew_mfg <- qcew %>%
  filter(industry_code == "31-33") %>%
  rename(empl_mfg = total_empl) %>%
  select(year, state_fips, empl_mfg)

qcew_ag <- qcew %>%
  filter(industry_code == "11") %>%
  rename(empl_ag = total_empl) %>%
  select(year, state_fips, empl_ag)

# Merge all outcomes
qcew_clean <- qcew_wide %>%
  left_join(qcew_mfg, by = c("year", "state_fips")) %>%
  left_join(qcew_ag, by = c("year", "state_fips"))

# Create year-quarter variable (annual = Q4 of each year for matching)
qcew_clean <- qcew_clean %>%
  mutate(
    quarter = 4,
    year_quarter = year + 0.75
  )

# -----------------------------------------------------------------------------
# Merge with Policy Panel
# -----------------------------------------------------------------------------

message("Merging with policy panel...")

# Get state info
state_info <- policy_panel %>%
  select(state_abbr, state_fips, state_name, ever_treated_sb, sb_type,
         sb_year_quarter, has_mobile, has_igaming, igaming_year)

# Merge QCEW with state info
# Remove state_abbr from qcew_clean to avoid duplicate columns
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

    # Log weekly wage
    log_wkly_wage = log(pmax(wkly_wage_7132, 1)),

    # Employment growth
    empl_growth = (empl_7132 - lag(empl_7132)) / lag(empl_7132),

    # Standardized employment (for comparability)
    empl_std = (empl_7132 - mean(empl_7132, na.rm = TRUE)) /
               sd(empl_7132, na.rm = TRUE)
  ) %>%
  ungroup()

# -----------------------------------------------------------------------------
# Create Full State Adjacency Matrix (for spillover analysis)
# -----------------------------------------------------------------------------

message("Building state adjacency matrix...")

# Complete US state adjacency list (all 50 states + DC)
state_neighbors <- tribble(
  ~state, ~neighbors,
  "AL", "FL,GA,MS,TN",
  "AK", "",
  "AZ", "CA,CO,NM,NV,UT",
  "AR", "LA,MO,MS,OK,TN,TX",
  "CA", "AZ,NV,OR",
  "CO", "AZ,KS,NE,NM,OK,UT,WY",
  "CT", "MA,NY,RI",
  "DE", "MD,NJ,PA",
  "DC", "MD,VA",
  "FL", "AL,GA",
  "GA", "AL,FL,NC,SC,TN",
  "HI", "",
  "ID", "MT,NV,OR,UT,WA,WY",
  "IL", "IA,IN,KY,MO,WI",
  "IN", "IL,KY,MI,OH",
  "IA", "IL,MN,MO,NE,SD,WI",
  "KS", "CO,MO,NE,OK",
  "KY", "IL,IN,MO,OH,TN,VA,WV",
  "LA", "AR,MS,TX",
  "ME", "NH",
  "MD", "DC,DE,PA,VA,WV",
  "MA", "CT,NH,NY,RI,VT",
  "MI", "IN,OH,WI",
  "MN", "IA,ND,SD,WI",
  "MS", "AL,AR,LA,TN",
  "MO", "AR,IA,IL,KS,KY,NE,OK,TN",
  "MT", "ID,ND,SD,WY",
  "NE", "CO,IA,KS,MO,SD,WY",
  "NV", "AZ,CA,ID,OR,UT",
  "NH", "MA,ME,VT",
  "NJ", "DE,NY,PA",
  "NM", "AZ,CO,OK,TX,UT",
  "NY", "CT,MA,NJ,PA,VT",
  "NC", "GA,SC,TN,VA",
  "ND", "MN,MT,SD",
  "OH", "IN,KY,MI,PA,WV",
  "OK", "AR,CO,KS,MO,NM,TX",
  "OR", "CA,ID,NV,WA",
  "PA", "DE,MD,NJ,NY,OH,WV",
  "RI", "CT,MA",
  "SC", "GA,NC",
  "SD", "IA,MN,MT,ND,NE,WY",
  "TN", "AL,AR,GA,KY,MO,MS,NC,VA",
  "TX", "AR,LA,NM,OK",
  "UT", "AZ,CO,ID,NM,NV,WY",
  "VT", "MA,NH,NY",
  "VA", "DC,KY,MD,NC,TN,WV",
  "WA", "ID,OR",
  "WV", "KY,MD,OH,PA,VA",
  "WI", "IA,IL,MI,MN",
  "WY", "CO,ID,MT,NE,SD,UT"
)

# Calculate neighbor treatment exposure for each state-year
# (proportion of bordering states that have legalized sports betting)
sb_dates <- policy_panel %>%
  select(state_abbr, sb_year_quarter, ever_treated_sb) %>%
  filter(!is.na(state_abbr))

neighbor_exposure <- analysis_sample %>%
  select(state_abbr, year) %>%
  distinct() %>%
  left_join(state_neighbors, by = c("state_abbr" = "state")) %>%
  mutate(neighbor_list = str_split(neighbors, ",")) %>%
  rowwise() %>%
  mutate(
    n_neighbors = length(neighbor_list[neighbor_list != ""]),
    n_neighbors_treated = {
      treated_count <- 0
      for (nb in neighbor_list) {
        if (nb == "") next
        nb_sb <- sb_dates %>% filter(state_abbr == nb)
        if (nrow(nb_sb) > 0 && !is.na(nb_sb$sb_year_quarter[1])) {
          if (year >= floor(nb_sb$sb_year_quarter[1])) {
            treated_count <- treated_count + 1
          }
        }
      }
      treated_count
    },
    neighbor_exposure = if_else(n_neighbors > 0, n_neighbors_treated / n_neighbors, 0)
  ) %>%
  ungroup() %>%
  select(state_abbr, year, n_neighbors, n_neighbors_treated, neighbor_exposure)

# Merge neighbor exposure into analysis sample
analysis_sample <- analysis_sample %>%
  left_join(neighbor_exposure, by = c("state_abbr", "year"))

message(sprintf("Neighbor exposure: mean = %.3f, max = %.3f",
                mean(analysis_sample$neighbor_exposure, na.rm = TRUE),
                max(analysis_sample$neighbor_exposure, na.rm = TRUE)))

# -----------------------------------------------------------------------------
# Balance Table Data
# -----------------------------------------------------------------------------

balance_data <- analysis_sample %>%
  filter(year == 2017) %>%
  group_by(ever_treated_sb) %>%
  summarise(
    n_states = n(),
    mean_empl = mean(empl_7132, na.rm = TRUE),
    sd_empl = sd(empl_7132, na.rm = TRUE),
    mean_estabs = mean(estabs_7132, na.rm = TRUE),
    mean_wkly_wage = mean(wkly_wage_7132, na.rm = TRUE),
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
    wkly_wage_7132, log_wkly_wage,
    empl_mfg, empl_ag,
    treated, ever_treated_sb, pre_covid,
    has_mobile, igaming_treated,
    neighbor_exposure, n_neighbors, n_neighbors_treated
  )

write_csv(cs_data, "../data/cs_analysis_data.csv")
message("Saved: ../data/cs_analysis_data.csv")

message("\nData cleaning complete.")
