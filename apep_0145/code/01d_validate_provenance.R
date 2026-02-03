###############################################################################
# 01d_validate_provenance.R
# Paper 141: EERS Revision - Validate Hardcoded Data Against Raw Sources
#
# This script verifies that hardcoded datasets in the analysis scripts
# match the documented raw source files in data/raw/
###############################################################################

source("00_packages.R")

data_dir <- "../data/"
raw_dir <- "../data/raw/"

cat("=== DATA PROVENANCE VALIDATION ===\n")
cat("Comparing hardcoded values against raw source files...\n\n")

validation_results <- list()
all_passed <- TRUE

###############################################################################
# 1. Validate EERS Treatment Coding
###############################################################################

cat("1. EERS TREATMENT CODING\n")
cat("   Source: data/raw/eers_adoption_sources.csv\n")

# Load raw source
eers_raw <- read_csv(paste0(raw_dir, "eers_adoption_sources.csv"),
                     show_col_types = FALSE)

# Load hardcoded data from fetch script
eers_hardcoded <- readRDS(paste0(data_dir, "eers_treatment.rds")) %>%
  filter(eers_type == "mandatory")

# Compare
eers_check <- eers_raw %>%
  select(state_abbr, raw_year = eers_year) %>%
  full_join(
    eers_hardcoded %>% select(state_abbr, code_year = eers_year),
    by = "state_abbr"
  ) %>%
  mutate(match = raw_year == code_year)

eers_mismatches <- eers_check %>% filter(!match | is.na(match))

if (nrow(eers_mismatches) == 0) {
  cat("   STATUS: PASS - All", nrow(eers_check), "EERS adoption years match\n")
  validation_results$eers <- "PASS"
} else {
  cat("   STATUS: FAIL - Mismatches found:\n")
  print(eers_mismatches)
  validation_results$eers <- "FAIL"
  all_passed <- FALSE
}
cat("\n")

###############################################################################
# 2. Validate 1990 Census Population
###############################################################################

cat("2. 1990 CENSUS POPULATION\n")
cat("   Source: data/raw/census_1990_population.csv\n")

# Load raw source
census_raw <- read_csv(paste0(raw_dir, "census_1990_population.csv"),
                       show_col_types = FALSE) %>%
  mutate(state_fips = sprintf("%02d", as.integer(state_fips)))

# Reconstruct hardcoded data (from 01_fetch_data.R lines 336-389)
census_hardcoded <- tribble(
  ~state_fips, ~pop_1990,
  "01", 4040587,
  "02",  550043,
  "04", 3665228,
  "05", 2350725,
  "06", 29760021,
  "08", 3294394,
  "09", 3287116,
  "10",  666168,
  "11",  606900,
  "12", 12937926,
  "13", 6478216,
  "15", 1108229,
  "16", 1006749,
  "17", 11430602,
  "18", 5544159,
  "19", 2776755,
  "20", 2477574,
  "21", 3685296,
  "22", 4219973,
  "23", 1227928,
  "24", 4781468,
  "25", 6016425,
  "26", 9295297,
  "27", 4375099,
  "28", 2573216,
  "29", 5117073,
  "30",  799065,
  "31", 1578385,
  "32", 1201833,
  "33", 1109252,
  "34", 7730188,
  "35", 1515069,
  "36", 17990455,
  "37", 6628637,
  "38",  638800,
  "39", 10847115,
  "40", 3145585,
  "41", 2842321,
  "42", 11881643,
  "44", 1003464,
  "45", 3486703,
  "46",  696004,
  "47", 4877185,
  "48", 16986510,
  "49", 1722850,
  "50",  562758,
  "51", 6187358,
  "53", 4866692,
  "54", 1793477,
  "55", 4891769,
  "56",  453588
)

# Compare
census_check <- census_raw %>%
  select(state_fips, raw_pop = pop_1990) %>%
  full_join(
    census_hardcoded %>% select(state_fips, code_pop = pop_1990),
    by = "state_fips"
  ) %>%
  mutate(match = raw_pop == code_pop)

census_mismatches <- census_check %>% filter(!match | is.na(match))

if (nrow(census_mismatches) == 0) {
  cat("   STATUS: PASS - All", nrow(census_check), "1990 populations match\n")

  # Additional checksum: total US population
  total_pop <- sum(census_hardcoded$pop_1990)
  expected_total <- 248709873  # Official 1990 Census total
  if (abs(total_pop - expected_total) < 100000) {  # Allow small rounding
    cat("   CHECKSUM: Total US population =", format(total_pop, big.mark=","),
        "(official:", format(expected_total, big.mark=","), ")\n")
  }

  validation_results$census_1990 <- "PASS"
} else {
  cat("   STATUS: FAIL - Mismatches found:\n")
  print(census_mismatches)
  validation_results$census_1990 <- "FAIL"
  all_passed <- FALSE
}
cat("\n")

###############################################################################
# 3. Validate RPS Adoption
###############################################################################

cat("3. RPS ADOPTION\n")
cat("   Source: data/raw/dsire_rps_export.csv\n")

rps_raw <- read_csv(paste0(raw_dir, "dsire_rps_export.csv"),
                    show_col_types = FALSE)

# Load from policy controls
policy <- readRDS(paste0(data_dir, "policy_controls.rds"))
rps_hardcoded <- policy %>%
  filter(rps_year > 0) %>%
  distinct(state_abbr, rps_year)

rps_check <- rps_raw %>%
  select(state_abbr, raw_year = rps_year) %>%
  full_join(rps_hardcoded, by = "state_abbr") %>%
  mutate(match = raw_year == rps_year)

rps_mismatches <- rps_check %>% filter(!match | is.na(match))

if (nrow(rps_mismatches) == 0) {
  cat("   STATUS: PASS - All", nrow(rps_check), "RPS adoption years match\n")
  validation_results$rps <- "PASS"
} else {
  cat("   STATUS: FAIL - Mismatches found:\n")
  print(rps_mismatches)
  validation_results$rps <- "FAIL"
  all_passed <- FALSE
}
cat("\n")

###############################################################################
# 4. Validate Decoupling
###############################################################################

cat("4. UTILITY DECOUPLING\n")
cat("   Source: data/raw/aceee_decoupling.csv\n")

decoupling_raw <- read_csv(paste0(raw_dir, "aceee_decoupling.csv"),
                           show_col_types = FALSE)

decoupling_hardcoded <- policy %>%
  filter(decoupling_year > 0) %>%
  distinct(state_abbr, decoupling_year)

decoupling_check <- decoupling_raw %>%
  select(state_abbr, raw_year = decoupling_year) %>%
  full_join(decoupling_hardcoded, by = "state_abbr") %>%
  mutate(match = raw_year == decoupling_year)

decoupling_mismatches <- decoupling_check %>% filter(!match | is.na(match))

if (nrow(decoupling_mismatches) == 0) {
  cat("   STATUS: PASS - All", nrow(decoupling_check), "decoupling years match\n")
  validation_results$decoupling <- "PASS"
} else {
  cat("   STATUS: FAIL - Mismatches found:\n")
  print(decoupling_mismatches)
  validation_results$decoupling <- "FAIL"
  all_passed <- FALSE
}
cat("\n")

###############################################################################
# 5. Validate Building Codes
###############################################################################

cat("5. BUILDING ENERGY CODES\n")
cat("   Source: data/raw/doe_building_codes.csv\n")

building_raw <- read_csv(paste0(raw_dir, "doe_building_codes.csv"),
                         show_col_types = FALSE)

building_hardcoded <- policy %>%
  filter(building_code_year > 0) %>%
  distinct(state_abbr, building_code_year)

building_check <- building_raw %>%
  select(state_abbr, raw_year = building_code_year) %>%
  full_join(building_hardcoded, by = "state_abbr") %>%
  mutate(match = raw_year == building_code_year)

building_mismatches <- building_check %>% filter(!match | is.na(match))

if (nrow(building_mismatches) == 0) {
  cat("   STATUS: PASS - All", nrow(building_check), "building code years match\n")
  validation_results$building_codes <- "PASS"
} else {
  cat("   STATUS: FAIL - Mismatches found:\n")
  print(building_mismatches)
  validation_results$building_codes <- "FAIL"
  all_passed <- FALSE
}
cat("\n")

###############################################################################
# Summary
###############################################################################

cat("=== VALIDATION SUMMARY ===\n")
for (name in names(validation_results)) {
  cat(sprintf("  %-20s: %s\n", name, validation_results[[name]]))
}
cat("\n")

if (all_passed) {
  cat("OVERALL: ALL CHECKS PASSED\n")
  cat("All hardcoded data matches documented raw sources.\n")
} else {
  cat("OVERALL: VALIDATION FAILED\n")
  cat("Some hardcoded values do not match raw sources.\n")
  cat("Please review and correct discrepancies.\n")
}

# Save validation results
saveRDS(validation_results, paste0(data_dir, "validation_results.rds"))
cat("\nValidation results saved to data/validation_results.rds\n")
