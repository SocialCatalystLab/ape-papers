# ============================================================
# 02_clean_data.R - Clean and merge analysis panels
# Paper 148: State Insulin Copay Caps and Working-Age
#             Diabetes Mortality (v5)
# Revision of apep_0161 (family apep_0150)
# ============================================================
# Inputs (from 01_fetch_data.R, 01b, and 01c):
#   - data/mortality_data.rds         <- All-ages mortality
#   - data/mortality_working_age.rds  <- Working-age (25-64) mortality
#   - data/policy_database.csv        <- Treatment timing
#   - data/insulin_utilization.rds    <- Medicaid insulin Rx (from 01c)
#   - data/placebo_cancer.rds         <- Cancer placebo (pre)
#   - data/placebo_heart.rds          <- Heart placebo (pre)
#   - data/placebo_cancer_post.rds    <- Cancer placebo (post)
#   - data/placebo_heart_post.rds     <- Heart placebo (post)
#   - data/state_lookup.rds           <- State FIPS lookup
#
# Outputs:
#   - data/analysis_panel.rds         <- PRIMARY: working-age panel
#   - data/analysis_panel.csv
#   - data/analysis_panel_allages.rds <- SECONDARY: all-ages panel
#   - data/panel_vermont_treated.rds  <- Vermont sensitivity: as treated
#   - data/panel_vermont_control.rds  <- Vermont sensitivity: as control
# ============================================================

source("code/00_packages.R")

# ============================================================
# PART 1: Load Raw Data
# ============================================================

cat("\n=== Loading Raw Data ===\n")

# Verify inputs exist (Flag 1-2 fix: provenance checks)
stopifnot(file.exists("data/policy_database.csv"))

# Load all-ages data
mort_allages <- tryCatch(readRDS("data/mortality_data.rds"), error = function(e) {
  cat("WARNING: All-ages mortality data not found.\n")
  NULL
})

# Load working-age data
mort_working_age <- tryCatch(readRDS("data/mortality_working_age.rds"), error = function(e) {
  cat("WARNING: Working-age mortality data not found.\n")
  NULL
})

policy_db  <- read_csv("data/policy_database.csv", show_col_types = FALSE)

# Load placebo outcomes (may not exist if API failed)
placebo_cancer      <- tryCatch(readRDS("data/placebo_cancer.rds"), error = function(e) NULL)
placebo_heart       <- tryCatch(readRDS("data/placebo_heart.rds"), error = function(e) NULL)
placebo_cancer_post <- tryCatch(readRDS("data/placebo_cancer_post.rds"), error = function(e) NULL)
placebo_heart_post  <- tryCatch(readRDS("data/placebo_heart_post.rds"), error = function(e) NULL)

if (!is.null(mort_allages)) cat("All-ages mortality:", nrow(mort_allages), "rows\n")
if (!is.null(mort_working_age)) cat("Working-age mortality:", nrow(mort_working_age), "rows\n")
cat("Policy database:", nrow(policy_db), "states with caps\n")

# ============================================================
# Helper: Add Derived Variables (defined early for use in panels)
# ============================================================

add_derived_vars <- function(panel) {
  panel %>%
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
}

# ============================================================
# Helper: Build Panel from Mortality Data
# ============================================================

build_panel <- function(mort_data, panel_label, exclude_vermont = TRUE) {
  cat("\n--- Building panel:", panel_label, "---\n")

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
  max_year <- max(panel$year)
  panel <- panel %>%
    mutate(first_treat = ifelse(first_treat > max_year, 0, first_treat))

  # FIX (Flag 6): Vermont handling
  if (exclude_vermont) {
    # PRIMARY specification: Exclude Vermont entirely
    n_vt_before <- sum(panel$state_name == "Vermont")
    panel <- panel %>% filter(state_name != "Vermont")
    cat("  Vermont EXCLUDED (", n_vt_before, "obs removed)\n")
  } else {
    # Reclassify Vermont as not-yet-treated (original behavior)
    panel <- panel %>%
      mutate(first_treat = ifelse(state_name == "Vermont", 0, first_treat))
    cat("  Vermont reclassified as not-yet-treated\n")
  }

  # Recalculate treated indicator after reclassification
  panel <- panel %>%
    mutate(treated = ifelse(first_treat > 0 & year >= first_treat, 1, 0))

  cat("  Treatment Assignment:\n")
  cat("    Never-treated states:", n_distinct(panel$state_fips[panel$first_treat == 0]), "\n")
  cat("    Ever-treated states: ", n_distinct(panel$state_fips[panel$first_treat > 0]), "\n")
  cat("    Post-treatment obs:  ", sum(panel$treated), "\n")

  return(panel)
}

# ============================================================
# PART 2: Build Working-Age Panel (PRIMARY)
# ============================================================

cat("\n=== Building Working-Age Panel (PRIMARY) ===\n")

if (!is.null(mort_working_age)) {
  # Standardize column names for working-age data
  wa_data <- mort_working_age %>%
    rename(mortality_rate = crude_rate) %>%
    mutate(
      mortality_deaths = deaths,
      mortality_rate = ifelse(is_suppressed, NA_real_, mortality_rate)
    ) %>%
    select(state_fips, state_abbr, state_name, year,
           mortality_deaths, mortality_rate, is_suppressed, data_source)

  # Drop rows where rate is NA (suppressed)
  n_before <- nrow(wa_data)
  wa_data_clean <- wa_data %>% filter(!is.na(mortality_rate))
  n_after <- nrow(wa_data_clean)
  cat("Working-age data: dropped", n_before - n_after, "suppressed obs\n")

  panel_wa <- build_panel(wa_data_clean, "Working-Age (25-64)")
} else if (!is.null(mort_allages)) {
  cat("WARNING: Working-age data unavailable. Using all-ages as primary.\n")
  panel_wa <- build_panel(mort_allages, "All-Ages (fallback)")
} else {
  stop("FATAL: No mortality data available.")
}

# ============================================================
# PART 3: Build All-Ages Panel (SECONDARY)
# ============================================================

cat("\n=== Building All-Ages Panel (SECONDARY) ===\n")

panel_allages <- NULL
if (!is.null(mort_allages)) {
  mort_allages_clean <- mort_allages %>%
    filter(!is.na(mortality_rate))
  panel_allages <- build_panel(mort_allages_clean, "All-Ages")
}

# ============================================================
# PART 4: Vermont Sensitivity Panels (Flag 6 fix)
# ============================================================

cat("\n=== Building Vermont Sensitivity Panels ===\n")

if (!is.null(mort_working_age)) {
  wa_for_vt <- mort_working_age %>%
    rename(mortality_rate = crude_rate) %>%
    mutate(
      mortality_deaths = deaths,
      mortality_rate = ifelse(is_suppressed, NA_real_, mortality_rate)
    ) %>%
    filter(!is.na(mortality_rate)) %>%
    select(state_fips, state_abbr, state_name, year,
           mortality_deaths, mortality_rate, is_suppressed, data_source)

  # Vermont-as-treated: Keep Vermont with original treatment assignment
  panel_vt_treated <- build_panel(wa_for_vt, "Vermont-as-Treated", exclude_vermont = FALSE)
  vt_treat_year <- policy_db %>% filter(state_abbr == "VT") %>% pull(first_treat)
  if (length(vt_treat_year) > 0) {
    panel_vt_treated <- panel_vt_treated %>%
      mutate(
        first_treat = ifelse(state_name == "Vermont", vt_treat_year, first_treat),
        treated = ifelse(first_treat > 0 & year >= first_treat, 1, 0)
      )
    cat("  Vermont-as-treated: VT first_treat =", vt_treat_year, "\n")
  }
  panel_vt_treated <- add_derived_vars(panel_vt_treated)
  saveRDS(panel_vt_treated, "data/panel_vermont_treated.rds")

  # Vermont-as-control: Vermont with first_treat = 0
  panel_vt_control <- build_panel(wa_for_vt, "Vermont-as-Control", exclude_vermont = FALSE)
  panel_vt_control <- add_derived_vars(panel_vt_control)
  saveRDS(panel_vt_control, "data/panel_vermont_control.rds")
  cat("  Saved Vermont sensitivity panels\n")
} else if (!is.null(mort_allages)) {
  # Use all-ages for Vermont sensitivity if working-age unavailable
  panel_vt_treated <- build_panel(mort_allages %>% filter(!is.na(mortality_rate)),
                                   "Vermont-as-Treated (all-ages)", exclude_vermont = FALSE)
  vt_treat_year <- policy_db %>% filter(state_abbr == "VT") %>% pull(first_treat)
  if (length(vt_treat_year) > 0) {
    panel_vt_treated <- panel_vt_treated %>%
      mutate(
        first_treat = ifelse(state_name == "Vermont", vt_treat_year, first_treat),
        treated = ifelse(first_treat > 0 & year >= first_treat, 1, 0)
      )
  }
  panel_vt_treated <- add_derived_vars(panel_vt_treated)
  saveRDS(panel_vt_treated, "data/panel_vermont_treated.rds")

  panel_vt_control <- build_panel(mort_allages %>% filter(!is.na(mortality_rate)),
                                   "Vermont-as-Control (all-ages)", exclude_vermont = FALSE)
  panel_vt_control <- add_derived_vars(panel_vt_control)
  saveRDS(panel_vt_control, "data/panel_vermont_control.rds")
  cat("  Saved Vermont sensitivity panels (all-ages)\n")
} else {
  cat("  Skipping Vermont sensitivity (no data)\n")
}

# ============================================================
# PART 5: Create Derived Variables (for primary panel)
# ============================================================

cat("\n=== Creating Derived Variables ===\n")

add_derived_vars <- function(panel) {
  panel %>%
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
}

panel_wa <- add_derived_vars(panel_wa)
if (!is.null(panel_allages)) panel_allages <- add_derived_vars(panel_allages)

# ============================================================
# PART 6: Merge Placebo Outcomes (for primary panel)
# ============================================================

cat("\n=== Merging Placebo Outcomes ===\n")

if (!is.null(placebo_cancer) && !is.null(placebo_cancer_post)) {
  placebo_cancer_combined <- bind_rows(placebo_cancer, placebo_cancer_post) %>%
    distinct(state_fips, year, .keep_all = TRUE)
  cat("  Combined cancer placebo:", nrow(placebo_cancer_combined), "rows\n")
} else if (!is.null(placebo_cancer)) {
  placebo_cancer_combined <- placebo_cancer
} else {
  placebo_cancer_combined <- placebo_cancer_post
}

if (!is.null(placebo_heart) && !is.null(placebo_heart_post)) {
  placebo_heart_combined <- bind_rows(placebo_heart, placebo_heart_post) %>%
    distinct(state_fips, year, .keep_all = TRUE)
  cat("  Combined heart placebo:", nrow(placebo_heart_combined), "rows\n")
} else if (!is.null(placebo_heart)) {
  placebo_heart_combined <- placebo_heart
} else {
  placebo_heart_combined <- placebo_heart_post
}

if (!is.null(placebo_cancer_combined)) {
  cancer_cols <- intersect(names(placebo_cancer_combined),
                            c("state_fips", "year", "mortality_deaths_cancer", "mortality_rate_cancer"))
  panel_wa <- panel_wa %>%
    left_join(placebo_cancer_combined %>% select(all_of(cancer_cols)), by = c("state_fips", "year"))
  cat("  Merged cancer mortality (", sum(!is.na(panel_wa$mortality_rate_cancer)), " non-missing)\n")
}

if (!is.null(placebo_heart_combined)) {
  heart_cols <- intersect(names(placebo_heart_combined),
                           c("state_fips", "year", "mortality_deaths_heart", "mortality_rate_heart"))
  panel_wa <- panel_wa %>%
    left_join(placebo_heart_combined %>% select(all_of(heart_cols)), by = c("state_fips", "year"))
  cat("  Merged heart disease mortality (", sum(!is.na(panel_wa$mortality_rate_heart)), " non-missing)\n")
}

if ("mortality_rate_cancer" %in% names(panel_wa)) {
  panel_wa <- panel_wa %>% mutate(log_mortality_cancer = log(mortality_rate_cancer + 0.1))
}
if ("mortality_rate_heart" %in% names(panel_wa)) {
  panel_wa <- panel_wa %>% mutate(log_mortality_heart = log(mortality_rate_heart + 0.1))
}

# ============================================================
# PART 7: Create COVID Control Variables
# ============================================================

cat("\n=== Creating COVID Control Variables ===\n")

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
    df <- df %>%
      mutate(jurisdiction_of_occurrence = case_when(
        jurisdiction_of_occurrence == "New York City" ~ "New York",
        TRUE ~ jurisdiction_of_occurrence
      )) %>%
      group_by(jurisdiction_of_occurrence, mmwryear) %>%
      summarise(covid_deaths = sum(covid_deaths, na.rm = TRUE), .groups = "drop") %>%
      rename(state_name = jurisdiction_of_occurrence, year = mmwryear) %>%
      mutate(year = as.integer(year))

    state_lookup <- readRDS("data/state_lookup.rds")
    df <- df %>%
      left_join(state_lookup, by = "state_name") %>%
      filter(!is.na(state_fips)) %>%
      select(state_fips, year, covid_deaths)
    cat("  COVID death data:", nrow(df), "state-year observations\n")
    df
  } else { NULL }
}, error = function(e) { cat("  COVID data error:", e$message, "\n"); NULL })

if (!is.null(covid_deaths)) {
  panel_wa <- panel_wa %>%
    left_join(covid_deaths, by = c("state_fips", "year")) %>%
    mutate(
      covid_deaths = ifelse(year < 2020, 0L, covid_deaths),
      covid_death_rate = covid_deaths / 100
    )
  if (!is.null(panel_allages)) {
    panel_allages <- panel_allages %>%
      left_join(covid_deaths, by = c("state_fips", "year")) %>%
      mutate(covid_deaths = ifelse(year < 2020, 0L, covid_deaths),
             covid_death_rate = covid_deaths / 100)
  }
} else {
  panel_wa <- panel_wa %>% mutate(covid_death_rate = NA_real_, covid_deaths = NA_integer_)
  if (!is.null(panel_allages)) {
    panel_allages <- panel_allages %>% mutate(covid_death_rate = NA_real_, covid_deaths = NA_integer_)
  }
}

# ============================================================
# PART 7B: Merge Medicaid Insulin Utilization Data
# ============================================================

cat("\n=== Merging Medicaid Insulin Utilization ===\n")

insulin_data <- tryCatch(readRDS("data/insulin_utilization.rds"), error = function(e) NULL)

if (!is.null(insulin_data) && nrow(insulin_data) > 0) {
  # Merge insulin prescriptions into primary panel
  panel_wa <- panel_wa %>%
    left_join(
      insulin_data %>% select(state_fips, year, total_prescriptions, total_units),
      by = c("state_fips", "year")
    ) %>%
    mutate(
      log_insulin_rx = ifelse(!is.na(total_prescriptions) & total_prescriptions > 0,
                              log(total_prescriptions), NA_real_)
    )
  cat("  Merged insulin Rx (", sum(!is.na(panel_wa$total_prescriptions)), " non-missing)\n")

  # Also merge into all-ages panel
  if (!is.null(panel_allages)) {
    panel_allages <- panel_allages %>%
      left_join(
        insulin_data %>% select(state_fips, year, total_prescriptions, total_units),
        by = c("state_fips", "year")
      ) %>%
      mutate(
        log_insulin_rx = ifelse(!is.na(total_prescriptions) & total_prescriptions > 0,
                                log(total_prescriptions), NA_real_)
      )
  }
} else {
  cat("  Insulin utilization data not available — skipping merge\n")
  panel_wa <- panel_wa %>%
    mutate(total_prescriptions = NA_real_, total_units = NA_real_, log_insulin_rx = NA_real_)
  if (!is.null(panel_allages)) {
    panel_allages <- panel_allages %>%
      mutate(total_prescriptions = NA_real_, total_units = NA_real_, log_insulin_rx = NA_real_)
  }
}

# ============================================================
# PART 7C: Add Medicaid Expansion Indicator
# ============================================================
# Binary indicator for whether state had expanded Medicaid under
# the ACA as of each year. Source: KFF Medicaid expansion tracker.
# States that expanded and their expansion years:

cat("\n=== Adding Medicaid Expansion Indicator ===\n")

# Medicaid expansion dates (year effective, Jan 1 implementation)
# Source: KFF Status of State Action on the Medicaid Expansion Decision
medicaid_expansion <- tribble(
  ~state_abbr, ~expansion_year,
  "AK", 2015, "AR", 2014, "AZ", 2014, "CA", 2014, "CO", 2014,
  "CT", 2014, "DE", 2014, "HI", 2014, "IA", 2014, "IL", 2014,
  "IN", 2015, "KY", 2014, "LA", 2016, "MA", 2014, "MD", 2014,
  "ME", 2019, "MI", 2014, "MN", 2014, "MO", 2021, "MT", 2016,
  "ND", 2014, "NE", 2020, "NH", 2014, "NJ", 2014, "NM", 2014,
  "NV", 2014, "NY", 2014, "OH", 2014, "OK", 2021, "OR", 2014,
  "PA", 2015, "RI", 2014, "VA", 2019, "VT", 2014, "WA", 2014,
  "WV", 2014, "DC", 2014, "ID", 2020, "UT", 2020, "NC", 2024,
  "SD", 2024
)

panel_wa <- panel_wa %>%
  left_join(medicaid_expansion, by = "state_abbr") %>%
  mutate(
    medicaid_expanded = as.integer(!is.na(expansion_year) & year >= expansion_year),
    expansion_year = NULL  # drop helper column
  )

if (!is.null(panel_allages)) {
  panel_allages <- panel_allages %>%
    left_join(medicaid_expansion, by = "state_abbr") %>%
    mutate(
      medicaid_expanded = as.integer(!is.na(expansion_year) & year >= expansion_year),
      expansion_year = NULL
    )
}

cat("  Medicaid expansion variable added\n")
cat("  Expanded obs:", sum(panel_wa$medicaid_expanded, na.rm = TRUE), "\n")
cat("  Not expanded obs:", sum(panel_wa$medicaid_expanded == 0, na.rm = TRUE), "\n")

# ============================================================
# PART 8: Panel Balance Checks
# ============================================================

cat("\n=== Panel Balance Check (Working-Age) ===\n")

n_states <- n_distinct(panel_wa$state_fips)
n_years  <- n_distinct(panel_wa$year)
n_obs    <- nrow(panel_wa)

cat("States:", n_states, "\n")
cat("Years: ", n_years, "(", min(panel_wa$year), "-", max(panel_wa$year), ")\n")
cat("Total obs:", n_obs, "\n")

has_2018 <- 2018 %in% panel_wa$year
has_2019 <- 2019 %in% panel_wa$year
if (has_2018 && has_2019) {
  cat("2018-2019 GAP FILLED: Working-age panel includes 2018-2019 data\n")
} else {
  cat("2018-2019 gap persists in working-age panel\n")
}

if (n_obs < n_states * n_years) {
  cat("Panel is UNBALANCED (", n_states * n_years - n_obs, " missing cells)\n")
} else {
  cat("Panel is BALANCED\n")
}

# ============================================================
# PART 9: Summary Statistics
# ============================================================

cat("\n=== Panel Summary Statistics (Working-Age) ===\n")

cat("\nOverall:\n")
panel_wa %>%
  summarise(
    mean_rate = mean(mortality_rate, na.rm = TRUE),
    sd_rate = sd(mortality_rate, na.rm = TRUE),
    min_rate = min(mortality_rate, na.rm = TRUE),
    max_rate = max(mortality_rate, na.rm = TRUE),
    n = n()
  ) %>% print()

cat("\nPre-Treatment Period by Group:\n")
panel_wa %>%
  filter(pre_period == 1) %>%
  mutate(group = ifelse(first_treat > 0, "Ever-Treated", "Never-Treated")) %>%
  group_by(group) %>%
  summarise(
    mean_rate = mean(mortality_rate, na.rm = TRUE),
    sd_rate = sd(mortality_rate, na.rm = TRUE),
    n_states = n_distinct(state_fips),
    n_obs = n()
  ) %>% print()

cat("\nBy Treatment Cohort:\n")
panel_wa %>%
  filter(first_treat > 0) %>%
  distinct(state_fips, first_treat, state_abbr) %>%
  arrange(first_treat) %>%
  group_by(first_treat) %>%
  summarise(n_states = n(), states = paste(state_abbr, collapse = ", ")) %>%
  print()

# ============================================================
# PART 10: Save Panels
# ============================================================

cat("\n=== Saving Analysis Panels ===\n")

saveRDS(panel_wa, "data/analysis_panel.rds")
write_csv(panel_wa, "data/analysis_panel.csv")
cat("Saved data/analysis_panel.rds (PRIMARY: working-age)\n")
cat("  Dimensions:", nrow(panel_wa), "rows x", ncol(panel_wa), "columns\n")

if (!is.null(panel_allages)) {
  saveRDS(panel_allages, "data/analysis_panel_allages.rds")
  cat("Saved data/analysis_panel_allages.rds (SECONDARY: all-ages)\n")
  cat("  Dimensions:", nrow(panel_allages), "rows x", ncol(panel_allages), "columns\n")
}

cat("\n=== Panel Construction Complete ===\n")
cat("PRIMARY panel: Working-age (25-64)\n")
cat("  States:", n_distinct(panel_wa$state_fips), "\n")
cat("  Years:", min(panel_wa$year), "-", max(panel_wa$year), "\n")
cat("  Ever-treated:", n_distinct(panel_wa$state_fips[panel_wa$first_treat > 0]), "states\n")
cat("  Never-treated:", n_distinct(panel_wa$state_fips[panel_wa$first_treat == 0]), "states\n")
cat("  Vermont: EXCLUDED from primary panel\n")
