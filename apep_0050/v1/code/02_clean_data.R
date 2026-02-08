# ============================================================================
# Paper 66: Salary Transparency Laws and Wage Outcomes
# 02_clean_data.R - Clean and construct analysis variables
# ============================================================================

source("code/00_packages.R")

# ============================================================================
# Load Raw Data
# ============================================================================

message("Loading raw CPS MORG data...")
cps_raw <- readRDS("data/cps_morg_raw.rds")
message("Loaded ", format(nrow(cps_raw), big.mark = ","), " observations")

# ============================================================================
# Treatment Assignment: Salary Transparency Laws
# ============================================================================

# Define treatment timing (year and month of effective date)
treatment_dates <- tribble(
  ~statefip, ~state_abbr, ~state_name, ~treat_year, ~treat_month, ~threshold,
  8,  "CO", "Colorado",       2021, 1,  1,    # Jan 1, 2021 - all employers
  6,  "CA", "California",     2023, 1,  15,   # Jan 1, 2023 - 15+ employees
  53, "WA", "Washington",     2023, 1,  15,   # Jan 1, 2023 - 15+ employees
  36, "NY", "New York",       2023, 9,  4,    # Sept 17, 2023 - 4+ employees
  15, "HI", "Hawaii",         2024, 1,  50,   # Jan 1, 2024 - 50+ employees
  11, "DC", "District of Columbia", 2024, 6, 1, # June 30, 2024 - all
  24, "MD", "Maryland",       2024, 10, 1,    # Oct 1, 2024 - all employers
  17, "IL", "Illinois",       2025, 1,  15,   # Jan 1, 2025 - 15+ employees
  27, "MN", "Minnesota",      2025, 1,  30,   # Jan 1, 2025 - 30+ employees
  50, "VT", "Vermont",        2025, 7,  5,    # July 1, 2025 - 5+ employees
  25, "MA", "Massachusetts",  2025, 10, 25,   # Oct 29, 2025 - 25+ employees
  23, "ME", "Maine",          2026, 1,  10    # Jan 1, 2026 - 10+ employees
)

# Create treatment year variable (first year fully treated)
treatment_years <- treatment_dates %>%
  mutate(
    # Treatment year = effective year if effective in first half,
    # otherwise next year (for conservative approach)
    treatment_year = case_when(
      treat_month <= 6 ~ treat_year,
      TRUE ~ treat_year  # Keep actual year for precision
    )
  ) %>%
  select(statefip, state_abbr, state_name, treatment_year, threshold)

# ============================================================================
# Harmonize Variable Names Across MORG Vintages
# ============================================================================

# NBER MORG variable names vary slightly by year
# Harmonize to consistent names

harmonize_morg <- function(df) {
  # Common variable mappings
  df <- df %>%
    rename_with(tolower) %>%
    rename(
      # State
      statefip = any_of(c("stfips", "state", "statefip")),
      # Earnings
      earnweek = any_of(c("earnwke", "earnweek")),
      hourwage = any_of(c("hourwage", "earnhre")),
      # Demographics
      female = any_of(c("female")),
      # Education
      educ = any_of(c("grade92", "educ", "grdhi")),
      # Occupation
      occ = any_of(c("docc03p", "occ", "docc00")),
      # Industry
      ind = any_of(c("dind03p", "ind", "dind00")),
      # Hours
      uhrswork = any_of(c("uhourse", "uhrswork", "uhrsworkt")),
      # Weight
      earnwt = any_of(c("earnwt", "orgwgt", "minsamp"))
    )

  # Create female indicator if not present
  if (!"female" %in% names(df) && "sex" %in% names(df)) {
    df <- df %>% mutate(female = as.integer(sex == 2))
  }

  return(df)
}

cps <- harmonize_morg(cps_raw)

# ============================================================================
# Sample Selection
# ============================================================================

message("Applying sample restrictions...")

cps_analysis <- cps %>%
  filter(
    # Age 18-64 (prime working age)
    age >= 18 & age <= 64,

    # Wage/salary workers only (exclude self-employed)
    classwkr %in% c(21, 22, 25, 26, 27, 28) | classwly %in% c(21:28),

    # Has valid earnings
    !is.na(earnweek) & earnweek > 0,

    # Not allocated (for cleaner estimates)
    # allocated earnings can introduce noise

    # Positive hours
    !is.na(uhrswork) & uhrswork > 0,

    # Reasonable earnings (top-code handling)
    earnweek < 2885  # Top code varies; use conservative threshold
  )

message("After sample restrictions: ", format(nrow(cps_analysis), big.mark = ","))

# ============================================================================
# Merge Treatment Status
# ============================================================================

cps_analysis <- cps_analysis %>%
  left_join(treatment_years, by = "statefip") %>%
  mutate(
    # Treatment status
    ever_treated = !is.na(treatment_year),
    treated = ever_treated & year >= treatment_year,

    # For never-treated states, set treatment_year to 0 (required by did package)
    treatment_year = ifelse(is.na(treatment_year), 0, treatment_year),

    # Event time (years since treatment)
    event_time = ifelse(ever_treated, year - treatment_year, NA_integer_),

    # Treatment cohort label
    cohort = case_when(
      treatment_year == 0 ~ "Never treated",
      treatment_year == 2021 ~ "2021",
      treatment_year == 2023 ~ "2023",
      treatment_year == 2024 ~ "2024",
      treatment_year == 2025 ~ "2025",
      treatment_year >= 2026 ~ "2026+",
      TRUE ~ as.character(treatment_year)
    )
  )

# ============================================================================
# Construct Analysis Variables
# ============================================================================

cps_analysis <- cps_analysis %>%
  mutate(
    # Log weekly earnings (primary outcome)
    log_earnweek = log(earnweek),

    # Hourly wage (for hourly workers) or imputed
    implied_hourwage = earnweek / uhrswork,

    # Education categories
    educ_cat = case_when(
      educ < 39 ~ "Less than HS",
      educ == 39 ~ "High school",
      educ %in% 40:42 ~ "Some college",
      educ == 43 ~ "Bachelor's",
      educ >= 44 ~ "Graduate",
      TRUE ~ "Unknown"
    ),

    # Age groups
    age_group = cut(age, breaks = c(17, 24, 34, 44, 54, 64),
                    labels = c("18-24", "25-34", "35-44", "45-54", "55-64")),

    # Race/ethnicity
    race_eth = case_when(
      hispan > 0 ~ "Hispanic",
      race == 100 ~ "White",
      race == 200 ~ "Black",
      race %in% c(651, 652) ~ "Asian",
      TRUE ~ "Other"
    ),

    # Full-time indicator
    fulltime = uhrswork >= 35,

    # State name for plotting (if not already merged)
    state_name = ifelse(is.na(state_name), as.character(statefip), state_name)
  )

# ============================================================================
# Create State-Year Panel
# ============================================================================

# Collapse to state-year level for some analyses
state_year <- cps_analysis %>%
  group_by(statefip, state_name, year, treatment_year, ever_treated, treated, cohort) %>%
  summarise(
    # Weighted means
    mean_earnweek = weighted.mean(earnweek, earnwt, na.rm = TRUE),
    mean_log_earn = weighted.mean(log_earnweek, earnwt, na.rm = TRUE),

    # Gender wage gap (male - female log earnings)
    mean_earn_male = weighted.mean(log_earnweek[female == 0], earnwt[female == 0], na.rm = TRUE),
    mean_earn_female = weighted.mean(log_earnweek[female == 1], earnwt[female == 1], na.rm = TRUE),
    gender_gap = mean_earn_male - mean_earn_female,

    # Sample sizes
    n_obs = n(),
    n_male = sum(female == 0, na.rm = TRUE),
    n_female = sum(female == 1, na.rm = TRUE),

    # Wage dispersion
    p10_earn = weighted.quantile(earnweek, earnwt, probs = 0.10, na.rm = TRUE),
    p50_earn = weighted.quantile(earnweek, earnwt, probs = 0.50, na.rm = TRUE),
    p90_earn = weighted.quantile(earnweek, earnwt, probs = 0.90, na.rm = TRUE),
    wage_9010_ratio = p90_earn / p10_earn,

    .groups = "drop"
  ) %>%
  mutate(
    event_time = ifelse(ever_treated, year - treatment_year, NA_integer_)
  )

# Weighted quantile helper function
weighted.quantile <- function(x, w, probs, na.rm = TRUE) {
  if (na.rm) {
    valid <- !is.na(x) & !is.na(w)
    x <- x[valid]
    w <- w[valid]
  }
  if (length(x) == 0) return(NA_real_)
  ord <- order(x)
  x <- x[ord]
  w <- w[ord]
  cum_w <- cumsum(w) / sum(w)
  approx(cum_w, x, xout = probs, rule = 2)$y
}

# ============================================================================
# Summary Statistics
# ============================================================================

message("\n=== Sample Summary ===")
message("Individual-level observations: ", format(nrow(cps_analysis), big.mark = ","))
message("State-year cells: ", nrow(state_year))
message("Years: ", min(cps_analysis$year), " - ", max(cps_analysis$year))
message("States: ", n_distinct(cps_analysis$statefip))

# Treatment summary
treatment_summary <- cps_analysis %>%
  group_by(cohort) %>%
  summarise(
    n_states = n_distinct(statefip),
    n_obs = n(),
    .groups = "drop"
  )

print(treatment_summary)

# ============================================================================
# Save Cleaned Data
# ============================================================================

saveRDS(cps_analysis, "data/cps_analysis.rds")
saveRDS(state_year, "data/state_year_panel.rds")

message("\nSaved cleaned data:")
message("  - data/cps_analysis.rds (individual-level)")
message("  - data/state_year_panel.rds (state-year panel)")

# ============================================================================
# Export Treatment Timing for Reference
# ============================================================================

write_csv(treatment_years, "data/treatment_timing.csv")
message("  - data/treatment_timing.csv")

message("\n=== Data Cleaning Complete ===")
