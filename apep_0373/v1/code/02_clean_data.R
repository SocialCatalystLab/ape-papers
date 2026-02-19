###############################################################################
# 02_clean_data.R — Clean and merge PSEO + MW + controls
# APEP-0372: Minimum Wage Spillovers to College Graduate Earnings
###############################################################################

source("00_packages.R")

data_dir <- "../data"

###############################################################################
# 1. Load raw data
###############################################################################

pseo_inst <- readRDS(file.path(data_dir, "pseo_institution.rds"))
pseo_cip <- readRDS(file.path(data_dir, "pseo_cip.rds"))
mw_raw <- readRDS(file.path(data_dir, "minimum_wage_raw.rds"))
unemp <- readRDS(file.path(data_dir, "state_unemployment.rds"))
income <- readRDS(file.path(data_dir, "state_income.rds"))
state_fips <- readRDS(file.path(data_dir, "state_fips.rds"))

###############################################################################
# 2. Clean PSEO institution-level data
###############################################################################

cat("=== Cleaning PSEO Institution Data ===\n")

# Keep only institution-level (INST_LEVEL = "I") and real cohorts
pseo <- pseo_inst %>%
  filter(INST_LEVEL == "I", GRAD_COHORT != "0000") %>%
  mutate(
    across(starts_with("Y1_"), as.numeric),
    across(starts_with("Y5_"), as.numeric),
    across(starts_with("Y10_"), as.numeric),
    cohort = as.integer(GRAD_COHORT),
    cohort_years = as.integer(GRAD_COHORT_YEARS),
    state_fips = INST_STATE,
    inst_id = INSTITUTION
  ) %>%
  select(inst_id, state_fips, cohort, cohort_years, degree_level, degree_name,
         Y1_P25_EARNINGS, Y1_P50_EARNINGS, Y1_P75_EARNINGS,
         Y5_P25_EARNINGS, Y5_P50_EARNINGS, Y5_P75_EARNINGS,
         Y10_P25_EARNINGS, Y10_P50_EARNINGS, Y10_P75_EARNINGS,
         Y1_GRADS_EARN, Y5_GRADS_EARN, Y10_GRADS_EARN) %>%
  # Rename earnings columns for easier use
  rename(
    y1_p25 = Y1_P25_EARNINGS, y1_p50 = Y1_P50_EARNINGS, y1_p75 = Y1_P75_EARNINGS,
    y5_p25 = Y5_P25_EARNINGS, y5_p50 = Y5_P50_EARNINGS, y5_p75 = Y5_P75_EARNINGS,
    y10_p25 = Y10_P25_EARNINGS, y10_p50 = Y10_P50_EARNINGS, y10_p75 = Y10_P75_EARNINGS,
    y1_n = Y1_GRADS_EARN, y5_n = Y5_GRADS_EARN, y10_n = Y10_GRADS_EARN
  ) %>%
  mutate(across(c(y1_n, y5_n, y10_n), as.numeric))

cat(sprintf("PSEO institution-level: %d rows\n", nrow(pseo)))
cat(sprintf("  Institutions: %d\n", n_distinct(pseo$inst_id)))
cat(sprintf("  States: %d\n", n_distinct(pseo$state_fips)))
cat(sprintf("  Cohorts: %s\n", paste(sort(unique(pseo$cohort)), collapse = ", ")))
cat(sprintf("  Degree levels: %s\n", paste(unique(pseo$degree_name), collapse = ", ")))

###############################################################################
# 3. Clean minimum wage data
###############################################################################

cat("\n=== Cleaning Minimum Wage Data ===\n")

# State name to FIPS mapping
state_name_to_fips <- c(
  "Alabama" = "01", "Alaska" = "02", "Arizona" = "04", "Arkansas" = "05",
  "California" = "06", "Colorado" = "08", "Connecticut" = "09",
  "Delaware" = "10", "District of Columbia" = "11", "Florida" = "12",
  "Georgia" = "13", "Hawaii" = "15", "Idaho" = "16", "Illinois" = "17",
  "Indiana" = "18", "Iowa" = "19", "Kansas" = "20", "Kentucky" = "21",
  "Louisiana" = "22", "Maine" = "23", "Maryland" = "24", "Massachusetts" = "25",
  "Michigan" = "26", "Minnesota" = "27", "Mississippi" = "28", "Missouri" = "29",
  "Montana" = "30", "Nebraska" = "31", "Nevada" = "32", "New Hampshire" = "33",
  "New Jersey" = "34", "New Mexico" = "35", "New York" = "36",
  "North Carolina" = "37", "North Dakota" = "38", "Ohio" = "39",
  "Oklahoma" = "40", "Oregon" = "41", "Pennsylvania" = "42",
  "Rhode Island" = "44", "South Carolina" = "45", "South Dakota" = "46",
  "Tennessee" = "47", "Texas" = "48", "Utah" = "49", "Vermont" = "50",
  "Virginia" = "51", "Washington" = "52", "West Virginia" = "54",
  "Wisconsin" = "55", "Wyoming" = "56"
)

mw <- mw_raw %>%
  mutate(
    state_fips = state_name_to_fips[State],
    year = as.integer(Year),
    effective_mw = as.numeric(Effective.Minimum.Wage),
    state_mw = as.numeric(State.Minimum.Wage),
    federal_mw = as.numeric(Federal.Minimum.Wage),
    effective_mw_2020 = as.numeric(Effective.Minimum.Wage.2020.Dollars)
  ) %>%
  filter(!is.na(state_fips), year >= 2000, year <= 2021) %>%
  select(state_fips, year, effective_mw, state_mw, federal_mw, effective_mw_2020)

# For each PSEO cohort (3-year window), compute average effective MW
# Cohort 2001 = graduated 2001-2003, etc.
cohort_windows <- data.frame(
  cohort = c(2001, 2004, 2006, 2007, 2010, 2011, 2013, 2016, 2019),
  start = c(2001, 2004, 2006, 2007, 2010, 2011, 2013, 2016, 2019),
  end   = c(2003, 2006, 2008, 2009, 2012, 2013, 2015, 2018, 2020)
)

mw_cohort <- list()
for (i in seq_len(nrow(cohort_windows))) {
  c_year <- cohort_windows$cohort[i]
  c_start <- cohort_windows$start[i]
  c_end <- cohort_windows$end[i]

  mw_avg <- mw %>%
    filter(year >= c_start, year <= c_end) %>%
    group_by(state_fips) %>%
    summarise(
      mw_avg = mean(effective_mw, na.rm = TRUE),
      mw_avg_real = mean(effective_mw_2020, na.rm = TRUE),
      mw_max = max(effective_mw, na.rm = TRUE),
      mw_min = min(effective_mw, na.rm = TRUE),
      mw_change = max(effective_mw, na.rm = TRUE) - min(effective_mw, na.rm = TRUE),
      fed_mw = mean(federal_mw, na.rm = TRUE),
      above_federal = as.integer(mean(effective_mw > federal_mw, na.rm = TRUE) > 0.5),
      .groups = "drop"
    ) %>%
    mutate(
      cohort = c_year,
      ln_mw = log(mw_avg),
      ln_mw_real = log(mw_avg_real),
      mw_annual = mw_avg * 2080  # Annualized at 40hr/week
    )

  mw_cohort[[length(mw_cohort) + 1]] <- mw_avg
}

mw_panel <- bind_rows(mw_cohort)
cat(sprintf("MW panel: %d state-cohort obs\n", nrow(mw_panel)))

###############################################################################
# 4. Clean state economic controls
###############################################################################

cat("\n=== Cleaning State Controls ===\n")

# Aggregate unemployment to cohort windows
unemp_clean <- unemp %>%
  mutate(
    year = as.integer(substr(date, 1, 4)),
    unemp_rate = value
  ) %>%
  select(state_fips, year, unemp_rate)

unemp_cohort <- list()
for (i in seq_len(nrow(cohort_windows))) {
  c_year <- cohort_windows$cohort[i]
  c_start <- cohort_windows$start[i]
  c_end <- cohort_windows$end[i]

  unemp_avg <- unemp_clean %>%
    filter(year >= c_start, year <= c_end) %>%
    group_by(state_fips) %>%
    summarise(
      unemp_avg = mean(unemp_rate, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(cohort = c_year)

  unemp_cohort[[length(unemp_cohort) + 1]] <- unemp_avg
}

unemp_panel <- bind_rows(unemp_cohort)

# Aggregate income to cohort windows
income_clean <- income %>%
  mutate(
    year = as.integer(substr(date, 1, 4)),
    pc_income = value
  ) %>%
  select(state_fips, year, pc_income)

income_cohort <- list()
for (i in seq_len(nrow(cohort_windows))) {
  c_year <- cohort_windows$cohort[i]
  c_start <- cohort_windows$start[i]
  c_end <- cohort_windows$end[i]

  income_avg <- income_clean %>%
    filter(year >= c_start, year <= c_end) %>%
    group_by(state_fips) %>%
    summarise(
      pc_income_avg = mean(pc_income, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(
      cohort = c_year,
      ln_income = log(pc_income_avg)
    )

  income_cohort[[length(income_cohort) + 1]] <- income_avg
}

income_panel <- bind_rows(income_cohort)

# Merge controls
controls <- mw_panel %>%
  left_join(unemp_panel, by = c("state_fips", "cohort")) %>%
  left_join(income_panel, by = c("state_fips", "cohort"))

cat(sprintf("Controls panel: %d state-cohort obs\n", nrow(controls)))

###############################################################################
# 5. Merge PSEO with controls
###############################################################################

cat("\n=== Merging PSEO + Controls ===\n")

# Add state abbreviation
pseo <- pseo %>%
  left_join(state_fips, by = c("state_fips" = "fips"))

# Merge PSEO institution data with MW and controls
analysis_data <- pseo %>%
  left_join(controls, by = c("state_fips", "cohort")) %>%
  filter(!is.na(mw_avg)) %>%
  # Create log earnings variables
  mutate(
    ln_y1_p25 = log(y1_p25),
    ln_y1_p50 = log(y1_p50),
    ln_y1_p75 = log(y1_p75),
    ln_y5_p25 = log(y5_p25),
    ln_y5_p50 = log(y5_p50),
    ln_y5_p75 = log(y5_p75),
    ln_y10_p25 = log(y10_p25),
    ln_y10_p50 = log(y10_p50),
    ln_y10_p75 = log(y10_p75),
    # Degree group
    degree_group = case_when(
      degree_level %in% c("01", "02") ~ "Certificate",
      degree_level == "03" ~ "Associate",
      degree_level == "05" ~ "Bachelor's",
      degree_level %in% c("07", "08", "17", "18") ~ "Graduate",
      TRUE ~ "Other"
    ),
    # Census region for region x cohort FE
    region = case_when(
      state_fips %in% c("09","23","25","33","34","36","42","44","50") ~ "Northeast",
      state_fips %in% c("17","18","19","20","26","27","29","31","38","39","46","55") ~ "Midwest",
      state_fips %in% c("01","05","10","11","12","13","21","22","24","28","37",
                        "40","45","47","48","51","54") ~ "South",
      state_fips %in% c("02","04","06","08","15","16","30","32","35","41","49",
                        "53","56") ~ "West",
      TRUE ~ "Other"
    )
  )

cat(sprintf("Analysis dataset: %d rows\n", nrow(analysis_data)))
cat(sprintf("  With Y1 P25 earnings: %d\n", sum(!is.na(analysis_data$y1_p25))))
cat(sprintf("  With Y5 P50 earnings: %d\n", sum(!is.na(analysis_data$y5_p50))))

# Summary by degree group
analysis_data %>%
  group_by(degree_group) %>%
  summarise(
    n = n(),
    n_inst = n_distinct(inst_id),
    n_states = n_distinct(state_fips),
    n_cohorts = n_distinct(cohort),
    mean_y1_p25 = mean(y1_p25, na.rm = TRUE),
    mean_y1_p50 = mean(y1_p50, na.rm = TRUE),
    mean_mw_annual = mean(mw_annual, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  print()

###############################################################################
# 6. Clean CIP-level data for bachelor's
###############################################################################

cat("\n=== Cleaning CIP-level Data ===\n")

pseo_cip_clean <- pseo_cip %>%
  filter(CIPCODE != "00") %>%
  mutate(
    across(starts_with("Y1_"), as.numeric),
    across(starts_with("Y5_"), as.numeric),
    cohort = as.integer(GRAD_COHORT),
    state_fips = INST_STATE,
    inst_id = INSTITUTION,
    cip2 = substr(CIPCODE, 1, 2),
    y1_n = as.numeric(Y1_GRADS_EARN)
  ) %>%
  rename(
    y1_p25 = Y1_P25_EARNINGS, y1_p50 = Y1_P50_EARNINGS, y1_p75 = Y1_P75_EARNINGS,
    y5_p25 = Y5_P25_EARNINGS, y5_p50 = Y5_P50_EARNINGS, y5_p75 = Y5_P75_EARNINGS
  ) %>%
  # Classify CIP into wage groups
  mutate(
    cip_group = case_when(
      cip2 %in% c("11", "14", "15") ~ "STEM-High",   # CS, Engineering
      cip2 %in% c("26", "27", "40") ~ "STEM-Mid",    # Bio, Math, Physical Sci
      cip2 %in% c("52") ~ "Business",                 # Business
      cip2 %in% c("51") ~ "Health",                   # Health professions
      cip2 %in% c("13") ~ "Education",                # Education
      cip2 %in% c("42", "45") ~ "Social Science",     # Psychology, Social Sci
      cip2 %in% c("23", "24", "50", "38", "54") ~ "Humanities/Arts",  # English, Liberal Arts, Arts, Philosophy, History
      TRUE ~ "Other"
    ),
    wage_group = case_when(
      cip_group %in% c("STEM-High", "Business", "Health") ~ "High-wage",
      cip_group %in% c("Education", "Humanities/Arts") ~ "Low-wage",
      TRUE ~ "Mid-wage"
    )
  ) %>%
  left_join(controls, by = c("state_fips", "cohort")) %>%
  filter(!is.na(mw_avg)) %>%
  mutate(
    ln_y1_p25 = log(y1_p25),
    ln_y1_p50 = log(y1_p50),
    ln_y1_p75 = log(y1_p75)
  )

cat(sprintf("CIP-level data: %d rows\n", nrow(pseo_cip_clean)))
cat("CIP groups:\n")
print(table(pseo_cip_clean$cip_group))

###############################################################################
# 7. Save analysis datasets
###############################################################################

cat("\n=== Saving Analysis Datasets ===\n")

saveRDS(analysis_data, file.path(data_dir, "analysis_data.rds"))
saveRDS(pseo_cip_clean, file.path(data_dir, "analysis_cip.rds"))
saveRDS(controls, file.path(data_dir, "controls_panel.rds"))

cat("Analysis datasets saved.\n")
