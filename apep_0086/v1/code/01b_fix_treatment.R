## 01b_fix_treatment.R — Fix misclassified never-treated states
## Moves CA, NH, MT, ID, WY from never-treated to treated
## Removes DC from the sample

library(tidyverse)

data_dir <- "../data"

# Corrected PDMP mandate dates
pdmp_mandates <- tribble(
  ~state_abbr, ~statefip, ~mandate_effective_date, ~mandate_year_full_exposure,
  "KY",  21, "2012-07-20", 2013,
  "WV",  54, "2012-06-08", 2013,
  "NM",  35, "2012-07-01", 2013,
  "TN",  47, "2013-04-01", 2014,
  "NY",  36, "2013-08-27", 2014,
  "VT",  50, "2013-07-01", 2014,
  "IN",  18, "2014-07-01", 2015,
  "MA",  25, "2014-07-01", 2015,
  "CO",  8,  "2014-07-15", 2015,
  "LA",  22, "2014-08-01", 2015,
  "OH",  39, "2015-04-01", 2016,
  "NV",  32, "2015-10-01", 2016,
  "VA",  51, "2015-07-01", 2016,
  "CT",  9,  "2015-10-01", 2016,
  "NJ",  34, "2015-11-01", 2016,
  "OK",  40, "2015-11-01", 2016,
  "RI",  44, "2016-03-01", 2017,
  "PA",  42, "2017-01-01", 2017,
  "AK",  2,  "2017-01-01", 2017,
  "AR",  5,  "2017-01-01", 2017,
  "NH",  33, "2017-01-01", 2017,
  "SC",  45, "2017-05-19", 2018,
  "WI",  55, "2017-04-01", 2018,
  "AZ",  4,  "2017-10-16", 2018,
  "UT",  49, "2017-05-09", 2018,
  "WA",  53, "2017-10-06", 2018,
  "ME",  23, "2017-07-01", 2018,
  "IL",  17, "2018-01-01", 2018,
  "NC",  37, "2018-01-01", 2018,
  "OR",  41, "2018-01-01", 2018,
  "FL",  12, "2018-07-01", 2019,
  "GA",  13, "2018-07-01", 2019,
  "IA",  19, "2018-07-01", 2019,
  "MI",  26, "2018-06-01", 2019,
  "MS",  28, "2018-07-01", 2019,
  "ND",  38, "2018-08-01", 2019,
  "DE",  10, "2018-03-28", 2019,
  "HI",  15, "2018-07-01", 2019,
  "MD",  24, "2018-07-01", 2019,
  "CA",   6, "2018-10-02", 2019,
  "MN",  27, "2019-01-01", 2019,
  "AL",  1,  "2019-01-01", 2019,
  "TX",  48, "2019-09-01", 2020,
  "MT",  30, "2019-10-01", 2020,
  "ID",  16, "2020-10-01", 2021
)
# Note: Wyoming (FIPS 56) has a must-access mandate (effective 2020, full-exposure 2021)
# but is excluded because BLS LAUS data for WY was not successfully fetched.

# Never-treated: only states with no universal must-access mandate
never_treated <- tribble(
  ~state_abbr, ~statefip,
  "KS",  20,
  "MO",  29,
  "NE",  31,
  "SD",  46
)
never_treated$mandate_effective_date <- NA_character_
never_treated$mandate_year_full_exposure <- 0

all_states_pdmp <- bind_rows(pdmp_mandates, never_treated) %>%
  arrange(statefip)

cat(sprintf("Treated states: %d\n", nrow(pdmp_mandates)))
cat(sprintf("Never-treated states: %d\n", nrow(never_treated)))

cat("\nAdoption Cohort Sizes:\n")
pdmp_mandates %>%
  count(mandate_year_full_exposure, name = "n_states") %>%
  arrange(mandate_year_full_exposure) %>%
  print()

saveRDS(all_states_pdmp, file.path(data_dir, "pdmp_mandate_dates.rds"))
write_csv(all_states_pdmp, file.path(data_dir, "pdmp_mandate_dates.csv"))
cat("Saved corrected PDMP mandate dates.\n")

# Also remove DC from BLS panel if present
bls_raw <- readRDS(file.path(data_dir, "bls_state_panel.rds"))
if (11 %in% bls_raw$statefip) {
  cat("Removing DC (FIPS 11) from BLS panel...\n")
  bls_raw <- bls_raw %>% filter(statefip != 11)
  saveRDS(bls_raw, file.path(data_dir, "bls_state_panel.rds"))
  cat(sprintf("Updated BLS panel: %d obs, %d states\n",
              nrow(bls_raw), n_distinct(bls_raw$statefip)))
} else {
  cat("DC not in BLS panel (already excluded).\n")
}
