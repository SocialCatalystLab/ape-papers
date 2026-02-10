## =============================================================================
## 02_clean_data.R — Construct treatment indicators and analysis variables
## The Innovation Cost of Privacy
## =============================================================================

source(here::here("output", "apep_0214", "v1", "code", "00_packages.R"))

data_dir <- file.path(base_dir, "data")

# ==== 1. Treatment Assignment ====
# State comprehensive data privacy laws — effective dates
# Source: Osano, IAPP, state legislation trackers (verified Feb 2026)

privacy_laws <- tribble(
  ~state_abbr, ~law_name, ~effective_date, ~treatment_quarter,
  "CA", "CCPA", "2020-01-01", "2020.1",
  "VA", "VCDPA", "2023-01-01", "2023.1",
  "CO", "CPA", "2023-07-01", "2023.3",
  "CT", "CTDPA", "2023-07-01", "2023.3",
  "UT", "UCPA", "2023-12-31", "2024.1",
  "TX", "TDPSA", "2024-07-01", "2024.3",
  "OR", "OCPA", "2024-07-01", "2024.3",
  "MT", "MTCDPA", "2024-10-01", "2024.4",
  "DE", "DPDPA", "2025-01-01", "2025.1",
  "IA", "ICDPA", "2025-01-01", "2025.1",
  "NE", "NDPA", "2025-01-01", "2025.1",
  "NH", "NHPA", "2025-01-01", "2025.1",
  "NJ", "NJDPA", "2025-01-15", "2025.1"
)
# Note: The following states are excluded because the QCEW data panel ends at
# 2025Q2, leaving them with zero post-treatment observations:
#   Tennessee (2025-07-01), Minnesota (2025-07-31), Maryland (2025-10-01),
#   Indiana (2026-01-01), Kentucky (2026-01-01), Rhode Island (2026-01-01)

# Note: Florida excluded from primary spec (unique $1B threshold)
# Parse treatment quarter into numeric
privacy_laws <- privacy_laws %>%
  mutate(
    treat_year = as.integer(str_extract(treatment_quarter, "^\\d{4}")),
    treat_qtr = as.integer(str_extract(treatment_quarter, "\\d$")),
    first_treat_period = (treat_year - 2015) * 4 + treat_qtr  # Period index starting at 2015Q1=1
  )


# ==== 2. Load and merge QCEW ====
cat("Loading QCEW data...\n")
qcew <- read_csv(file.path(data_dir, "qcew_raw.csv"), show_col_types = FALSE)

# Merge with state info
state_fips <- tibble(
  fips = sprintf("%02d", c(1,2,4,5,6,8,9,10,11,12,13,15,16,17,18,19,20,
                            21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,
                            36,37,38,39,40,41,42,44,45,46,47,48,49,50,51,
                            53,54,55,56)),
  state_abbr = c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL","GA",
                  "HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA",
                  "MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY",
                  "NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX",
                  "UT","VT","VA","WA","WV","WI","WY")
)

qcew <- qcew %>%
  left_join(state_fips, by = c("state_fips" = "fips")) %>%
  left_join(privacy_laws %>% select(state_abbr, first_treat_period, law_name),
            by = "state_abbr")

# Create period variable (2015Q1 = 1, 2015Q2 = 2, etc.)
qcew <- qcew %>%
  mutate(
    period = (year - 2015) * 4 + qtr,
    # For CS-DiD: never-treated states get first_treat = 0
    first_treat = ifelse(is.na(first_treat_period), 0, first_treat_period),
    treated = ifelse(first_treat > 0 & period >= first_treat, 1, 0),
    # Log outcomes (add 1 for zeros)
    log_emp = log(avg_emp + 1),
    log_estabs = log(qtrly_estabs + 1),
    log_wages = log(avg_wkly_wage + 1),
    log_total_wages = log(total_qtrly_wages + 1)
  )

# Create state numeric ID
qcew <- qcew %>%
  mutate(state_id = as.integer(factor(state_abbr)))

cat(sprintf("QCEW panel: %d obs, %d states, periods %d-%d\n",
            nrow(qcew), n_distinct(qcew$state_abbr),
            min(qcew$period, na.rm=TRUE), max(qcew$period, na.rm=TRUE)))


# ==== 3. Load and merge BFS ====
cat("Loading BFS data...\n")
bfs <- read_csv(file.path(data_dir, "bfs_raw.csv"), show_col_types = FALSE)

bfs <- bfs %>%
  left_join(privacy_laws %>% select(state_abbr, first_treat_period, law_name),
            by = c("geo" = "state_abbr")) %>%
  mutate(
    period = (year - 2015) * 4 + quarter,
    first_treat = ifelse(is.na(first_treat_period), 0, first_treat_period),
    treated = ifelse(first_treat > 0 & period >= first_treat, 1, 0),
    log_apps = log(applications + 1),
    state_id = as.integer(factor(geo))
  )

cat(sprintf("BFS panel: %d obs, %d states\n",
            nrow(bfs), n_distinct(bfs$geo)))


# ==== 4. Summary statistics ====
cat("\n=== Treatment Summary ===\n")
cat(sprintf("Treated states: %d\n", n_distinct(privacy_laws$state_abbr)))
cat(sprintf("Control states: %d\n",
            n_distinct(qcew$state_abbr[qcew$first_treat == 0])))

cat("\nTreatment cohorts:\n")
privacy_laws %>%
  group_by(treatment_quarter) %>%
  summarise(states = paste(state_abbr, collapse = ", "), n = n(), .groups = "drop") %>%
  arrange(treatment_quarter) %>%
  print(n = 20)


# ==== 5. Save analysis datasets ====
# Primary: Information sector (NAICS 51) panel
qcew_info <- qcew %>% filter(industry_code == "51")
write_csv(qcew_info, file.path(data_dir, "panel_information.csv"))
cat(sprintf("\nSaved panel_information.csv: %d obs\n", nrow(qcew_info)))

# Software publishers (NAICS 5112)
qcew_soft <- qcew %>% filter(industry_code == "5112")
write_csv(qcew_soft, file.path(data_dir, "panel_software.csv"))
cat(sprintf("Saved panel_software.csv: %d obs\n", nrow(qcew_soft)))

# Placebo industries
qcew_manuf <- qcew %>% filter(industry_code == "31-33")
write_csv(qcew_manuf, file.path(data_dir, "panel_manufacturing.csv"))

qcew_health <- qcew %>% filter(industry_code == "62")
write_csv(qcew_health, file.path(data_dir, "panel_healthcare.csv"))

qcew_constr <- qcew %>% filter(industry_code == "23")
write_csv(qcew_constr, file.path(data_dir, "panel_construction.csv"))

# Total all industries
qcew_total <- qcew %>% filter(industry_code == "10")
write_csv(qcew_total, file.path(data_dir, "panel_total.csv"))

# BFS (business applications)
bfs_ba <- bfs %>% filter(series == "BA_BA", sa == "U")
write_csv(bfs_ba, file.path(data_dir, "panel_bfs.csv"))
cat(sprintf("Saved panel_bfs.csv: %d obs\n", nrow(bfs_ba)))

# Save full analysis dataset (all industries)
write_csv(qcew, file.path(data_dir, "qcew_analysis.csv"))

cat("\n=== Data cleaning complete ===\n")
