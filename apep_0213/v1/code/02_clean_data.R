## =============================================================================
## 02_clean_data.R — Clean and merge YRBS data with treatment matrix
## Anti-Cyberbullying Laws and Youth Mental Health
## =============================================================================

source("00_packages.R")

data_dir <- "../data"

## -----------------------------------------------------------------------------
## 1. Load raw data
## -----------------------------------------------------------------------------

yrbs_raw <- readRDS(file.path(data_dir, "yrbs_raw.rds"))
laws <- readRDS(file.path(data_dir, "cyberbullying_laws.rds"))

cat(sprintf("YRBS raw data: %d rows\n", nrow(yrbs_raw)))
cat(sprintf("States with laws: %d (including %d with no cyberbullying provision)\n",
            nrow(laws), sum(is.na(laws$law_year))))

## -----------------------------------------------------------------------------
## 2. Clean YRBS data — aggregate to state × year × question level
## -----------------------------------------------------------------------------

# Filter to state-level aggregates (Total sex, Total race, Total grade)
# and National-level (for comparison)
yrbs_clean <- yrbs_raw %>%
  filter(
    stratificationtype == "State" | locationdesc == "National"
  ) %>%
  mutate(
    year = as.integer(year),
    greater_risk_value = as.numeric(greater_risk_data_value),
    lesser_risk_value  = as.numeric(lesser_risk_data_value),
    sample_size        = as.integer(sample_size),
    ci_low  = as.numeric(greater_risk_low_confidence_limit),
    ci_high = as.numeric(greater_risk_high_confidence_limit)
  ) %>%
  select(
    year, state_abbr = locationabbr, state_name = locationdesc,
    question_code = questioncode, question_text = shortquestiontext,
    sex, race, grade,
    pct_risk = greater_risk_value,
    ci_low, ci_high, sample_size
  )

cat(sprintf("After initial filter: %d rows\n", nrow(yrbs_clean)))

## -----------------------------------------------------------------------------
## 3. Create analysis-ready state × year panels for each outcome
## -----------------------------------------------------------------------------

# Primary analysis: state × year totals (sex=Total, race=Total, grade=Total)
# Deduplicate: take the first (or mean) value per state-year-question
yrbs_state_total <- yrbs_clean %>%
  filter(
    sex == "Total",
    race == "Total",
    grade == "Total",
    state_abbr != "US"  # Exclude national average
  ) %>%
  group_by(year, state_abbr, state_name, question_code, question_text) %>%
  summarise(
    pct_risk = mean(pct_risk, na.rm = TRUE),
    ci_low = mean(ci_low, na.rm = TRUE),
    ci_high = mean(ci_high, na.rm = TRUE),
    sample_size = sum(sample_size, na.rm = TRUE),
    .groups = "drop"
  )

cat(sprintf("State-total panel: %d rows\n", nrow(yrbs_state_total)))

# Pivot to wide format: one row per state × year
yrbs_wide <- yrbs_state_total %>%
  select(year, state_abbr, state_name, question_code, pct_risk, sample_size) %>%
  pivot_wider(
    names_from = question_code,
    values_from = c(pct_risk, sample_size),
    names_sep = "_",
    values_fn = mean
  ) %>%
  rename(
    cyberbullying      = pct_risk_H24,
    bullying_school    = pct_risk_H23,
    suicide_ideation   = pct_risk_H26,
    suicide_plan       = pct_risk_H27,
    suicide_attempt    = pct_risk_H28,
    suicide_injurious  = pct_risk_H29,
    depression         = pct_risk_H25,
    n_cyberbullying    = sample_size_H24,
    n_bullying_school  = sample_size_H23,
    n_suicide_ideation = sample_size_H26,
    n_suicide_plan     = sample_size_H27,
    n_suicide_attempt  = sample_size_H28,
    n_suicide_injurious = sample_size_H29,
    n_depression       = sample_size_H25
  )

cat(sprintf("Wide panel: %d state-year observations\n", nrow(yrbs_wide)))

## -----------------------------------------------------------------------------
## 4. Merge with treatment matrix
## -----------------------------------------------------------------------------

yrbs_panel <- yrbs_wide %>%
  left_join(laws, by = c("state_abbr")) %>%
  mutate(
    # Treatment indicator: law effective before March of YRBS survey year
    # YRBS fielded Feb-May; if law effective by Jan of survey year, treated
    treated = case_when(
      is.na(law_year) ~ 0L,  # Never treated (AK, WI)
      year >= law_year ~ 1L,  # Law was in effect
      TRUE ~ 0L               # Not yet treated
    ),
    # First treatment period (for CS-DiD)
    # Map law_year to first YRBS wave where treated
    first_treat_wave = case_when(
      is.na(law_year) ~ 0L,    # Never treated coded as 0
      law_year <= 2003 ~ 2003L,
      law_year <= 2005 ~ 2005L,
      law_year <= 2007 ~ 2007L,
      law_year <= 2009 ~ 2009L,
      law_year <= 2011 ~ 2011L,
      law_year <= 2013 ~ 2013L,
      law_year <= 2015 ~ 2015L,
      law_year <= 2017 ~ 2017L,
      TRUE ~ 9999L  # Treated after sample period
    ),
    # State numeric ID for panel
    state_id = as.integer(factor(state_abbr)),
    # Has criminal sanctions
    has_criminal = as.integer(law_type %in% c("criminal", "both"))
  )

## -----------------------------------------------------------------------------
## 5. Create sex-stratified panels for heterogeneity analysis
## -----------------------------------------------------------------------------

yrbs_by_sex <- yrbs_clean %>%
  filter(
    sex %in% c("Male", "Female"),
    race == "Total",
    grade == "Total",
    state_abbr != "US"
  ) %>%
  group_by(year, state_abbr, sex, question_code) %>%
  summarise(
    pct_risk = mean(pct_risk, na.rm = TRUE),
    sample_size = sum(sample_size, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_wider(
    names_from = question_code,
    values_from = c(pct_risk, sample_size),
    names_sep = "_",
    values_fn = mean
  ) %>%
  rename(
    cyberbullying    = pct_risk_H24,
    bullying_school  = pct_risk_H23,
    suicide_ideation = pct_risk_H26,
    suicide_attempt  = pct_risk_H28,
    depression       = pct_risk_H25
  ) %>%
  left_join(laws, by = c("state_abbr")) %>%
  mutate(
    treated = case_when(
      is.na(law_year) ~ 0L,
      year >= law_year ~ 1L,
      TRUE ~ 0L
    ),
    first_treat_wave = case_when(
      is.na(law_year) ~ 0L,
      law_year <= 2003 ~ 2003L,
      law_year <= 2005 ~ 2005L,
      law_year <= 2007 ~ 2007L,
      law_year <= 2009 ~ 2009L,
      law_year <= 2011 ~ 2011L,
      law_year <= 2013 ~ 2013L,
      law_year <= 2015 ~ 2015L,
      law_year <= 2017 ~ 2017L,
      TRUE ~ 9999L
    ),
    state_id = as.integer(factor(state_abbr))
  )

## -----------------------------------------------------------------------------
## 6. Summary statistics
## -----------------------------------------------------------------------------

cat("\n=== Summary Statistics ===\n")

# Treatment rollout
cat("\nTreatment cohort sizes:\n")
laws %>%
  filter(!is.na(law_year)) %>%
  count(law_year, name = "n_states") %>%
  print()

cat(sprintf("\nNever-treated states: %d (%s)\n",
            sum(is.na(laws$law_year)),
            paste(laws$state_abbr[is.na(laws$law_year)], collapse = ", ")))

cat(sprintf("States with criminal penalties: %d\n",
            sum(laws$law_type %in% c("criminal", "both"))))

# Outcome means
cat("\nOutcome means (pooled across state-years):\n")
outcome_vars <- c("cyberbullying", "bullying_school", "suicide_ideation",
                   "suicide_plan", "suicide_attempt", "depression")
for (v in outcome_vars) {
  vals <- yrbs_panel[[v]]
  if (!is.null(vals) && is.numeric(vals)) {
    cat(sprintf("  %s: mean=%.1f, sd=%.1f, n=%d\n",
                v, mean(vals, na.rm = TRUE), sd(vals, na.rm = TRUE),
                sum(!is.na(vals))))
  } else {
    cat(sprintf("  %s: not available or non-numeric\n", v))
  }
}

# Panel balance
cat("\nPanel balance by year:\n")
yrbs_panel %>%
  group_by(year) %>%
  summarise(
    n_states = n(),
    n_treated = sum(treated),
    has_cyberbullying = sum(!is.na(cyberbullying)),
    has_suicide_ideation = sum(!is.na(suicide_ideation)),
    .groups = "drop"
  ) %>%
  print()

## -----------------------------------------------------------------------------
## 7. Save cleaned panels
## -----------------------------------------------------------------------------

saveRDS(yrbs_panel, file.path(data_dir, "yrbs_panel.rds"))
saveRDS(yrbs_by_sex, file.path(data_dir, "yrbs_by_sex.rds"))
write_csv(yrbs_panel, file.path(data_dir, "yrbs_panel.csv"))

cat("\n=== Cleaning complete ===\n")
cat(sprintf("Main panel: %d state-year observations\n", nrow(yrbs_panel)))
cat(sprintf("Sex-stratified panel: %d observations\n", nrow(yrbs_by_sex)))
