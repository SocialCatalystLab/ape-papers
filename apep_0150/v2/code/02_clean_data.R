# ============================================================
# 02_clean_data.R - Clean and merge analysis panel
# Paper 135: State Insulin Copay Caps and Diabetes Mortality
# ============================================================

source("code/00_packages.R")

# ============================================================
# PART 1: Load Raw Data
# ============================================================

cat("\n=== Loading Raw Data ===\n")

mort_data  <- readRDS("data/mortality_data.rds")
policy_db  <- read_csv("data/policy_database.csv", show_col_types = FALSE)

# Load placebo outcomes (may not exist if API failed)
placebo_cancer <- tryCatch(readRDS("data/placebo_cancer.rds"), error = function(e) NULL)
placebo_heart  <- tryCatch(readRDS("data/placebo_heart.rds"), error = function(e) NULL)

cat("Mortality data:", nrow(mort_data), "rows\n")
cat("Policy database:", nrow(policy_db), "states with caps\n")
cat("Placebo cancer:", ifelse(!is.null(placebo_cancer), nrow(placebo_cancer), "not available"), "\n")
cat("Placebo heart:", ifelse(!is.null(placebo_heart), nrow(placebo_heart), "not available"), "\n")

# ============================================================
# PART 2: Merge Policy Data onto Full State Panel
# ============================================================

cat("\n=== Creating Analysis Panel ===\n")

panel <- mort_data %>%
  left_join(
    policy_db %>%
      select(state_fips, first_treat, cap_amount, effective_date),
    by = "state_fips"
  ) %>%
  mutate(
    first_treat = ifelse(is.na(first_treat), 0L, as.integer(first_treat)),
    cap_amount  = ifelse(is.na(cap_amount), NA_real_, cap_amount),
    treated = as.integer(first_treat > 0 & year >= first_treat),
    state_id = as.integer(factor(state_fips))
  )

# Reclassify cohorts with first_treat > max(year) as never-treated
# States with first_treat in 2024-2025 have no post-treatment mortality data (data ends 2023)
max_year <- max(panel$year)
panel <- panel %>%
  mutate(first_treat = ifelse(first_treat > max_year, 0, first_treat))

# Also reclassify Vermont (no post-2020 data, cannot estimate post-treatment effects)
# NOTE: Vermont enacted a copay cap (effective 2022) but post-treatment mortality data
# are suppressed by CDC due to small cell sizes. Vermont is reclassified as never-treated
# in the estimation sample. Sensitivity analysis with Vermont included is in 04_robustness.R.
panel <- panel %>%
  mutate(first_treat = ifelse(state_name == "Vermont", 0, first_treat))

# Recalculate treated indicator after reclassification
panel <- panel %>%
  mutate(treated = ifelse(first_treat > 0 & year >= first_treat, 1, 0))

cat("\nTreatment Assignment Summary:\n")
cat("  Never-treated states:", n_distinct(panel$state_fips[panel$first_treat == 0]), "\n")
cat("  Ever-treated states: ", n_distinct(panel$state_fips[panel$first_treat > 0]), "\n")
cat("  Post-treatment obs:  ", sum(panel$treated), "\n")
cat("  Pre-treatment obs:   ", sum(panel$treated == 0), "\n")

cat("\nTreatment Cohort Sizes:\n")
panel %>%
  filter(first_treat > 0) %>%
  distinct(state_fips, first_treat) %>%
  count(first_treat) %>%
  print()

# ============================================================
# PART 3: Handle Missing / Suppressed Data
# ============================================================

cat("\n=== Handling Missing Data ===\n")

n_missing <- sum(is.na(panel$mortality_rate))
cat("Missing mortality rates:", n_missing, "of", nrow(panel), "\n")

if (n_missing > 0) {
  missing_obs <- panel %>%
    filter(is.na(mortality_rate)) %>%
    select(state_fips, state_abbr, year)
  cat("Missing observations:\n")
  print(missing_obs, n = 20)
  panel <- panel %>% filter(!is.na(mortality_rate))
  cat("Dropped", n_missing, "observations with missing mortality rates\n")
}

# ============================================================
# PART 4: Create Derived Variables
# ============================================================

cat("\n=== Creating Derived Variables ===\n")

panel <- panel %>%
  mutate(
    log_mortality_rate = log(mortality_rate + 0.1),
    covid_year = as.integer(year %in% c(2020, 2021)),
    covid_2020 = as.integer(year == 2020),
    covid_2021 = as.integer(year == 2021),
    post_covid = as.integer(year >= 2020),
    pre_period = as.integer(year < first_treat | first_treat == 0),
    rel_time = ifelse(first_treat > 0, year - first_treat, NA_integer_),
    cap_category = case_when(
      is.na(cap_amount) ~ "No Cap",
      cap_amount <= 30   ~ "Low ($25-30)",
      cap_amount <= 50   ~ "Medium ($35-50)",
      cap_amount >= 100  ~ "High ($100)",
      TRUE               ~ "Other"
    ),
    time_trend = year - 1999
  )

# ============================================================
# PART 5: Merge Placebo Outcomes
# ============================================================

cat("\n=== Merging Placebo Outcomes ===\n")

if (!is.null(placebo_cancer)) {
  panel <- panel %>%
    left_join(placebo_cancer, by = c("state_fips", "year"))
  cat("  Merged cancer mortality (", sum(!is.na(panel$mortality_rate_cancer)), " non-missing)\n")
}

if (!is.null(placebo_heart)) {
  panel <- panel %>%
    left_join(placebo_heart, by = c("state_fips", "year"))
  cat("  Merged heart disease mortality (", sum(!is.na(panel$mortality_rate_heart)), " non-missing)\n")
}

# Create log versions of placebo outcomes
if ("mortality_rate_cancer" %in% names(panel)) {
  panel <- panel %>%
    mutate(log_mortality_cancer = log(mortality_rate_cancer + 0.1))
}
if ("mortality_rate_heart" %in% names(panel)) {
  panel <- panel %>%
    mutate(log_mortality_heart = log(mortality_rate_heart + 0.1))
}

# ============================================================
# PART 6: Create COVID Control Variables
# ============================================================

cat("\n=== Creating COVID Control Variables ===\n")

# Fetch state-level COVID death counts from the weekly data
# Use total COVID deaths per state per year as control
covid_deaths <- tryCatch({
  resp <- GET(
    "https://data.cdc.gov/resource/muzy-jte6.csv",
    query = list(
      `$select` = paste0("jurisdiction_of_occurrence,mmwryear,",
                          "sum(covid_19_u071_underlying_cause_of_death) as covid_deaths"),
      `$where` = paste0("jurisdiction_of_occurrence<>'United States'",
                        " AND jurisdiction_of_occurrence<>'Puerto Rico'"),
      `$group` = "jurisdiction_of_occurrence,mmwryear",
      `$order` = "mmwryear,jurisdiction_of_occurrence",
      `$limit` = 500
    ),
    timeout(120)
  )

  if (status_code(resp) == 200) {
    df <- read_csv(content(resp, "text", encoding = "UTF-8"), show_col_types = FALSE)
    # Combine NY + NYC
    df <- df %>%
      mutate(
        jurisdiction_of_occurrence = case_when(
          jurisdiction_of_occurrence == "New York City" ~ "New York",
          TRUE ~ jurisdiction_of_occurrence
        )
      ) %>%
      group_by(jurisdiction_of_occurrence, mmwryear) %>%
      summarise(covid_deaths = sum(covid_deaths, na.rm = TRUE), .groups = "drop") %>%
      rename(state_name = jurisdiction_of_occurrence, year = mmwryear) %>%
      mutate(year = as.integer(year))

    # Load state lookup for FIPS
    state_lookup <- readRDS("data/state_lookup.rds")
    df <- df %>%
      left_join(state_lookup, by = "state_name") %>%
      filter(!is.na(state_fips)) %>%
      select(state_fips, year, covid_deaths)
    cat("  COVID death data:", nrow(df), "state-year observations\n")
    df
  } else {
    cat("  COVID data HTTP error:", status_code(resp), "\n")
    NULL
  }
}, error = function(e) {
  cat("  COVID data error:", e$message, "\n")
  NULL
})

if (!is.null(covid_deaths)) {
  # Merge and compute COVID death rate per 100,000
  panel <- panel %>%
    left_join(covid_deaths, by = c("state_fips", "year")) %>%
    mutate(
      # Pre-COVID years (before 2020) have zero COVID deaths by definition
      covid_deaths = ifelse(year < 2020, 0L, covid_deaths),
      # For 2020+ observations: keep NA if API returned NA (do NOT hard-code to 0)
      # Rescale to per 100,000 for interpretable coefficients
      covid_death_rate = covid_deaths / 100  # per 100K (raw counts are ~tens of thousands)
    )
  n_covid_na <- sum(is.na(panel$covid_deaths) & panel$year >= 2020)
  if (n_covid_na > 0) {
    cat("  WARNING:", n_covid_na, "post-2020 state-years have NA COVID deaths (API missing)\n")
  }
} else {
  # If COVID data API entirely unavailable, set to NA (NOT 0)
  cat("  WARNING: COVID death data API failed. Setting covid_death_rate to NA.\n")
  cat("  COVID controls will be unavailable in analysis.\n")
  panel <- panel %>%
    mutate(covid_death_rate = NA_real_, covid_deaths = NA_integer_)
}

# ============================================================
# PART 7: Panel Balance Check
# ============================================================

cat("\n=== Panel Balance Check ===\n")

n_states <- n_distinct(panel$state_fips)
n_years  <- n_distinct(panel$year)
n_obs    <- nrow(panel)

cat("States:", n_states, "\n")
cat("Years: ", n_years, "(", min(panel$year), "-", max(panel$year), ")\n")
cat("Total obs:", n_obs, "\n")

# Note: Panel will be unbalanced due to 2018-2019 gap and some
# states suppressed in 2020-2023 weekly data
if (n_obs < n_states * n_years) {
  cat("Panel is UNBALANCED (", n_states * n_years - n_obs, " missing cells)\n")
  cat("This is expected due to:\n")
  cat("  - 2018-2019 gap between historical and weekly CDC datasets\n")
  cat("  - Small states with suppressed weekly counts (2020-2023)\n")
} else {
  cat("Panel is BALANCED\n")
}

# ============================================================
# PART 8: Summary Statistics
# ============================================================

cat("\n=== Panel Summary Statistics ===\n")

cat("\nOverall:\n")
panel %>%
  summarise(
    mean_rate = mean(mortality_rate, na.rm = TRUE),
    sd_rate = sd(mortality_rate, na.rm = TRUE),
    min_rate = min(mortality_rate, na.rm = TRUE),
    max_rate = max(mortality_rate, na.rm = TRUE),
    n = n()
  ) %>%
  print()

cat("\nPre-Treatment Period by Group:\n")
panel %>%
  filter(pre_period == 1) %>%
  mutate(group = ifelse(first_treat > 0, "Ever-Treated", "Never-Treated")) %>%
  group_by(group) %>%
  summarise(
    mean_rate = mean(mortality_rate, na.rm = TRUE),
    sd_rate = sd(mortality_rate, na.rm = TRUE),
    n_states = n_distinct(state_fips),
    n_obs = n()
  ) %>%
  print()

cat("\nBy Treatment Cohort:\n")
panel %>%
  filter(first_treat > 0) %>%
  distinct(state_fips, first_treat, state_abbr) %>%
  arrange(first_treat) %>%
  group_by(first_treat) %>%
  summarise(
    n_states = n(),
    states = paste(state_abbr, collapse = ", ")
  ) %>%
  print()

# ============================================================
# PART 9: Save Analysis Panel
# ============================================================

cat("\n=== Validating Panel Structure ===\n")

required_cols <- c(
  "state_fips", "state_abbr", "state_name", "year", "state_id",
  "mortality_rate", "log_mortality_rate",
  "first_treat", "treated",
  "covid_year", "covid_death_rate",
  "cap_amount", "cap_category"
)

missing_cols <- setdiff(required_cols, names(panel))
if (length(missing_cols) > 0) {
  cat("WARNING: Missing columns:", paste(missing_cols, collapse = ", "), "\n")
} else {
  cat("All required columns present\n")
}

cat("\nPanel columns:\n")
cat(paste(names(panel), collapse = ", "), "\n")

saveRDS(panel, "data/analysis_panel.rds")
write_csv(panel, "data/analysis_panel.csv")

cat("\n=== Panel Construction Complete ===\n")
cat("Saved data/analysis_panel.rds\n")
cat("Dimensions:", nrow(panel), "rows x", ncol(panel), "columns\n")
cat("States:", n_distinct(panel$state_fips), "\n")
cat("Years:", min(panel$year), "-", max(panel$year), "\n")
cat("Ever-treated:", n_distinct(panel$state_fips[panel$first_treat > 0]), "states\n")
cat("Never-treated:", n_distinct(panel$state_fips[panel$first_treat == 0]), "states\n")
