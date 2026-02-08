## 02_clean_data.R — Build analysis panel from BLS + PDMP data
## Paper 109: Must-Access PDMP Mandates and Prime-Age Labor Force Participation

source("00_packages.R")

data_dir <- "../data"

# Load raw BLS state panel
bls_raw <- readRDS(file.path(data_dir, "bls_state_panel.rds"))
pdmp <- readRDS(file.path(data_dir, "pdmp_mandate_dates.rds"))
medicaid <- readRDS(file.path(data_dir, "medicaid_expansion.rds"))
rec_mj <- readRDS(file.path(data_dir, "rec_marijuana.rds"))

cat("=== Fix column labels from BLS LAUS ===\n")
# From 01_fetch_data.R, series 03 was labeled "labor_force" but is actually
# unemployment rate (%). series 05 labeled "employment" is employment level.
# Fix column names:

bls <- bls_raw %>%
  rename(
    unemp_rate_march = labor_force,  # Series 03 = unemployment rate
    employment_march = employment     # Series 05 = employment level
  ) %>%
  select(
    statefip, year,
    unemp_rate_march, employment_march,
    employment_annual, labor_force_annual
  ) %>%
  mutate(
    log_emp = log(employment_march),
    # Employment rate = 100 - unemployment rate
    emp_rate = 100 - unemp_rate_march
  )

cat(sprintf("BLS panel: %d obs, %d states, years %d-%d\n",
            nrow(bls), n_distinct(bls$statefip),
            min(bls$year), max(bls$year)))
cat(sprintf("Employment range: %s - %s\n",
            format(min(bls$employment_march, na.rm=T), big.mark=","),
            format(max(bls$employment_march, na.rm=T), big.mark=",")))
cat(sprintf("Unemployment rate range: %.1f%% - %.1f%%\n",
            min(bls$unemp_rate_march, na.rm=T),
            max(bls$unemp_rate_march, na.rm=T)))

cat("\n=== Merge PDMP Treatment ===\n")

panel <- bls %>%
  left_join(
    pdmp %>% select(statefip, state_abbr, mandate_year_full_exposure),
    by = "statefip"
  ) %>%
  mutate(
    mandate_year_full_exposure = replace_na(mandate_year_full_exposure, 0),
    # first_treat for CS-DiD: 0 = never treated
    first_treat = mandate_year_full_exposure,
    treated = as.integer(first_treat > 0 & year >= first_treat),
    ever_treated = as.integer(first_treat > 0),
    rel_time = ifelse(first_treat > 0, year - first_treat, NA_real_),
    cohort_group = case_when(
      first_treat == 0 ~ "Never Treated",
      first_treat <= 2014 ~ "Early (2013-14)",
      first_treat <= 2016 ~ "Middle (2015-16)",
      first_treat <= 2018 ~ "Late (2017-18)",
      first_treat >= 2019 ~ "Very Late (2019+)",
      TRUE ~ "Other"
    )
  )

# Merge concurrent policies
panel <- panel %>%
  left_join(medicaid, by = "statefip") %>%
  left_join(rec_mj, by = "statefip") %>%
  mutate(
    medicaid_expanded = as.integer(
      !is.na(medicaid_expansion_year) & year >= medicaid_expansion_year
    ),
    rec_marijuana_legal = as.integer(
      !is.na(rec_marijuana_year) & year >= rec_marijuana_year
    )
  )

cat(sprintf("Panel: %d state-years\n", nrow(panel)))
cat(sprintf("States: %d (treated: %d, never-treated: %d)\n",
            n_distinct(panel$statefip),
            n_distinct(panel$statefip[panel$ever_treated == 1]),
            n_distinct(panel$statefip[panel$ever_treated == 0])))
cat(sprintf("Years: %d-%d\n", min(panel$year), max(panel$year)))
cat(sprintf("Treated obs: %d / %d (%.1f%%)\n",
            sum(panel$treated), nrow(panel),
            100 * mean(panel$treated)))

cat("\n=== Adoption Cohorts ===\n")
panel %>%
  filter(year == max(year)) %>%
  count(cohort_group, name = "n_states") %>%
  arrange(desc(n_states)) %>%
  print()

cat("\n=== Pre-Treatment Summary (2007-2012) ===\n")
panel %>%
  filter(year <= 2012) %>%
  group_by(Group = ifelse(ever_treated == 1, "Ever-Treated", "Never-Treated")) %>%
  summarise(
    n_states = n_distinct(statefip),
    mean_log_emp = mean(log_emp, na.rm = TRUE),
    sd_log_emp = sd(log_emp, na.rm = TRUE),
    mean_unemp_rate = mean(unemp_rate_march, na.rm = TRUE),
    sd_unemp_rate = sd(unemp_rate_march, na.rm = TRUE),
    mean_emp_rate = mean(emp_rate, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  print()

# Save
saveRDS(panel, file.path(data_dir, "analysis_panel.rds"))
cat("\nSaved analysis panel: data/analysis_panel.rds\n")
