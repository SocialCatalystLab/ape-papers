## =============================================================================
## 02_clean_data.R — Merge QCEW data with IMLC treatment; construct panel
## APEP Working Paper apep_0232
## =============================================================================

source("00_packages.R")

data_dir <- "../data"

## ---------------------------------------------------------------------------
## 1. Load raw data
## ---------------------------------------------------------------------------

qcew_panel <- read_csv(file.path(data_dir, "qcew_panel.csv"),
                       show_col_types = FALSE)
imlc_treatment <- read_csv(file.path(data_dir, "imlc_treatment.csv"),
                           col_types = cols(state_fips = col_character()))
acs_panel <- read_csv(file.path(data_dir, "acs_wfh_panel.csv"),
                      show_col_types = FALSE) %>%
  mutate(state_fips = sprintf("%02s", state_fips))

# Ensure state_fips is zero-padded
imlc_treatment$state_fips <- sprintf("%02s", imlc_treatment$state_fips)
qcew_panel$state_fips <- sprintf("%02s", qcew_panel$state_fips)

## ---------------------------------------------------------------------------
## 2. Reshape QCEW to wide format (one row per state-year)
## ---------------------------------------------------------------------------

# Pivot healthcare (62), ambulatory (621), hospitals (622), retail (44-45)
qcew_wide <- qcew_panel %>%
  pivot_wider(
    id_cols = c(state_fips, year),
    names_from = industry_label,
    values_from = c(annual_avg_estabs_count, annual_avg_emplvl,
                    total_annual_wages, avg_annual_pay),
    names_sep = "_"
  )

cat(sprintf("QCEW wide panel: %d state-years\n", nrow(qcew_wide)))

## ---------------------------------------------------------------------------
## 3. Merge with IMLC treatment
## ---------------------------------------------------------------------------

panel <- qcew_wide %>%
  left_join(imlc_treatment %>% select(state_fips, state_abbr, state_name, imlc_year),
            by = "state_fips") %>%
  filter(!is.na(state_abbr))  # Drop any non-state rows

# Create treatment indicator
panel <- panel %>%
  mutate(
    treated = as.integer(imlc_year > 0 & year >= imlc_year),
    post = as.integer(year >= imlc_year & imlc_year > 0),
    # For did package: first_treat = 0 means never treated
    first_treat = imlc_year,
    # Numeric state ID for did package
    state_id = as.integer(state_fips)
  )

## ---------------------------------------------------------------------------
## 4. Construct outcome variables
## ---------------------------------------------------------------------------

panel <- panel %>%
  mutate(
    # Log outcomes for healthcare
    log_hc_emp       = log(annual_avg_emplvl_healthcare + 1),
    log_hc_estabs    = log(annual_avg_estabs_count_healthcare + 1),
    log_hc_avgpay    = log(avg_annual_pay_healthcare + 1),
    log_hc_wages     = log(total_annual_wages_healthcare + 1),

    # Log outcomes for ambulatory care
    log_amb_emp      = log(annual_avg_emplvl_ambulatory + 1),
    log_amb_estabs   = log(annual_avg_estabs_count_ambulatory + 1),
    log_amb_avgpay   = log(avg_annual_pay_ambulatory + 1),

    # Log outcomes for hospitals
    log_hosp_emp     = log(annual_avg_emplvl_hospitals + 1),
    log_hosp_estabs  = log(annual_avg_estabs_count_hospitals + 1),

    # Placebo: accommodation & food services
    log_plc_emp      = log(annual_avg_emplvl_placebo + 1),
    log_plc_estabs   = log(annual_avg_estabs_count_placebo + 1),

    # Cohort group label
    cohort_label = case_when(
      imlc_year == 0    ~ "Never Treated",
      imlc_year == 2017 ~ "2017 Cohort",
      imlc_year == 2018 ~ "2018 Cohort",
      imlc_year == 2019 ~ "2019 Cohort",
      imlc_year == 2020 ~ "2020 Cohort",
      imlc_year == 2021 ~ "2021 Cohort",
      imlc_year >= 2022 ~ "2022+ Cohort"
    )
  )

## ---------------------------------------------------------------------------
## 5. Merge ACS WFH data
## ---------------------------------------------------------------------------

panel <- panel %>%
  left_join(acs_panel %>% select(state_fips, year, wfh_share, wfh_workers, total_workers),
            by = c("state_fips", "year"))

## ---------------------------------------------------------------------------
## 6. Summary statistics
## ---------------------------------------------------------------------------

cat("\n=== Panel Summary ===\n")
cat(sprintf("States: %d\n", n_distinct(panel$state_fips)))
cat(sprintf("Years: %d-%d\n", min(panel$year), max(panel$year)))
cat(sprintf("Total observations: %d\n", nrow(panel)))

# Treatment summary
cat("\nCohort sizes:\n")
panel %>%
  filter(year == 2017) %>%
  count(cohort_label) %>%
  print()

# Summary statistics for main variables
cat("\nSummary statistics (healthcare employment):\n")
panel %>%
  group_by(treated = ifelse(imlc_year > 0, "IMLC Member", "Non-Member")) %>%
  summarise(
    n_state_years = n(),
    mean_hc_emp = mean(annual_avg_emplvl_healthcare, na.rm = TRUE),
    sd_hc_emp = sd(annual_avg_emplvl_healthcare, na.rm = TRUE),
    mean_amb_emp = mean(annual_avg_emplvl_ambulatory, na.rm = TRUE),
    mean_hc_estabs = mean(annual_avg_estabs_count_healthcare, na.rm = TRUE),
    mean_hc_avgpay = mean(avg_annual_pay_healthcare, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  print()

## ---------------------------------------------------------------------------
## 7. Generate summary stats table for paper
## ---------------------------------------------------------------------------

# Overall summary
sumstats <- panel %>%
  filter(!is.na(annual_avg_emplvl_healthcare)) %>%
  summarise(
    `Healthcare Employment`          = mean(annual_avg_emplvl_healthcare, na.rm = TRUE),
    `Healthcare Employment SD`       = sd(annual_avg_emplvl_healthcare, na.rm = TRUE),
    `Ambulatory Employment`          = mean(annual_avg_emplvl_ambulatory, na.rm = TRUE),
    `Ambulatory Employment SD`       = sd(annual_avg_emplvl_ambulatory, na.rm = TRUE),
    `Hospital Employment`            = mean(annual_avg_emplvl_hospitals, na.rm = TRUE),
    `Hospital Employment SD`         = sd(annual_avg_emplvl_hospitals, na.rm = TRUE),
    `Healthcare Establishments`      = mean(annual_avg_estabs_count_healthcare, na.rm = TRUE),
    `Healthcare Establishments SD`   = sd(annual_avg_estabs_count_healthcare, na.rm = TRUE),
    `Avg Annual Pay (Healthcare)`    = mean(avg_annual_pay_healthcare, na.rm = TRUE),
    `Avg Annual Pay (Healthcare) SD` = sd(avg_annual_pay_healthcare, na.rm = TRUE),
    `Placebo Employment`              = mean(annual_avg_emplvl_placebo, na.rm = TRUE),
    `Placebo Employment SD`           = sd(annual_avg_emplvl_placebo, na.rm = TRUE),
    N = n()
  )

# By treatment group (pre-treatment only, for balance)
balance <- panel %>%
  filter(year < 2017, !is.na(annual_avg_emplvl_healthcare)) %>%
  group_by(ever_treated = ifelse(imlc_year > 0, "Eventually Treated", "Never Treated")) %>%
  summarise(
    hc_emp_mean = mean(annual_avg_emplvl_healthcare, na.rm = TRUE),
    hc_emp_sd = sd(annual_avg_emplvl_healthcare, na.rm = TRUE),
    amb_emp_mean = mean(annual_avg_emplvl_ambulatory, na.rm = TRUE),
    hc_estabs_mean = mean(annual_avg_estabs_count_healthcare, na.rm = TRUE),
    hc_avgpay_mean = mean(avg_annual_pay_healthcare, na.rm = TRUE),
    plc_emp_mean = mean(annual_avg_emplvl_placebo, na.rm = TRUE),
    n_states = n_distinct(state_fips),
    .groups = "drop"
  )

cat("\nPre-treatment balance:\n")
print(balance)

## ---------------------------------------------------------------------------
## 8. Save clean panel
## ---------------------------------------------------------------------------

write_csv(panel, file.path(data_dir, "analysis_panel.csv"))
saveRDS(panel, file.path(data_dir, "analysis_panel.rds"))

# Save summary stats for LaTeX
write_csv(sumstats, file.path(data_dir, "summary_stats.csv"))
write_csv(balance, file.path(data_dir, "balance_table.csv"))

cat(sprintf("\nSaved analysis panel: %d rows\n", nrow(panel)))
cat("=== Clean data complete ===\n")
