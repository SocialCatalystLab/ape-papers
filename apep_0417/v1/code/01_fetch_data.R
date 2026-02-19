## ============================================================
## 01_fetch_data.R — Load T-MSIS + NPPES, build provider panel
## Paper: Where Medicaid Goes Dark (apep_0371)
## ============================================================

source("00_packages.R")

cat("\n=== Step 1: Load NPPES Extract ===\n")
nppes <- read_parquet(NPPES_PATH) |>
  as.data.table()

cat("  NPPES rows:", nrow(nppes), "\n")

# Specialty classification using NUCC taxonomy codes
# Focus on individual providers (entity_type == 1)
nppes_indiv <- nppes[entity_type == 1 & !is.na(taxonomy_1)]

# Map taxonomy codes to specialty groups
classify_specialty <- function(tax) {
  case_when(
    # Primary Care (MD/DO)
    str_starts(tax, "207Q") ~ "Primary Care",
    tax == "207R00000X"     ~ "Primary Care",  # General Internal Medicine only
    str_starts(tax, "208D") ~ "Primary Care",  # General Practice
    tax == "208000000X"     ~ "Primary Care",  # General Pediatrics only

    # NP/PA
    str_starts(tax, "363L") ~ "NP/PA",
    str_starts(tax, "363A") ~ "NP/PA",

    # Psychiatry (MD/DO)
    str_starts(tax, "2084") ~ "Psychiatry",

    # Behavioral Health (non-MD)
    str_starts(tax, "101Y") ~ "Behavioral Health",
    str_starts(tax, "1041") ~ "Behavioral Health",
    str_starts(tax, "104100") ~ "Behavioral Health",
    str_starts(tax, "103T") ~ "Behavioral Health",
    str_starts(tax, "103K") ~ "Behavioral Health",
    str_starts(tax, "106H") ~ "Behavioral Health",

    # Dental
    str_starts(tax, "1223") ~ "Dental",
    str_starts(tax, "122300") ~ "Dental",

    # OB-GYN
    str_starts(tax, "207V") ~ "OB-GYN",

    # Surgery
    str_starts(tax, "2086") ~ "Surgery",
    str_starts(tax, "207X") ~ "Surgery",
    str_starts(tax, "207T") ~ "Surgery",
    str_starts(tax, "208200") ~ "Surgery",
    str_starts(tax, "208C") ~ "Surgery",
    str_starts(tax, "208G") ~ "Surgery",
    str_starts(tax, "204E") ~ "Surgery",

    TRUE ~ NA_character_
  )
}

nppes_indiv[, specialty := classify_specialty(taxonomy_1)]
nppes_classified <- nppes_indiv[!is.na(specialty)]

cat("  Classified providers:", nrow(nppes_classified), "\n")
cat("  Specialty distribution:\n")
print(nppes_classified[, .N, by = specialty][order(-N)])

# Provider type from credential
nppes_classified[, provider_type := case_when(
  str_detect(credential, "(?i)\\bMD\\b|\\bM\\.D\\b") ~ "MD",
  str_detect(credential, "(?i)\\bDO\\b|\\bD\\.O\\b") ~ "DO",
  str_detect(credential, "(?i)\\bNP\\b|\\bFNP\\b|\\bARNP\\b|\\bCRNP\\b|\\bAPRN\\b|\\bDNP\\b") ~ "NP",
  str_detect(credential, "(?i)\\bPA\\b|\\bPA-C\\b|\\bPAC\\b") ~ "PA",
  str_detect(credential, "(?i)\\bDDS\\b|\\bDMD\\b|\\bD\\.D\\.S\\b|\\bD\\.M\\.D\\b") ~ "DDS/DMD",
  str_detect(credential, "(?i)\\bLCSW\\b|\\bMSW\\b|\\bLISW\\b") ~ "LCSW",
  str_detect(credential, "(?i)\\bLPC\\b|\\bLMHC\\b|\\bLMFT\\b") ~ "LPC/LMHC",
  str_detect(credential, "(?i)\\bPH\\.?D\\b|\\bPSY\\.?D\\b") ~ "PhD/PsyD",
  TRUE ~ "Other"
)]

cat("\n  Provider type distribution:\n")
print(nppes_classified[, .N, by = provider_type][order(-N)])

cat("\n=== Step 2: Build ZCTA-County Crosswalk ===\n")

# Download Census ZCTA-to-county relationship file
xwalk_file <- file.path(DATA_DIR, "zcta_county_xwalk.csv")
if (!file.exists(xwalk_file)) {
  url <- "https://www2.census.gov/geo/docs/maps-data/data/rel2020/zcta520/tab20_zcta520_county20_natl.txt"
  cat("  Downloading ZCTA-county crosswalk...\n")
  download.file(url, xwalk_file, quiet = TRUE)
}

xwalk <- fread(xwalk_file, sep = "|")
# Keep the county with largest area overlap per ZCTA
xwalk <- xwalk[, .(
  county_fips = sprintf("%05d", GEOID_COUNTY_20[which.max(AREALAND_PART)])
), by = .(zcta5 = sprintf("%05d", GEOID_ZCTA5_20))]

cat("  ZCTA-county mappings:", nrow(xwalk), "\n")

# Map providers to counties
nppes_classified[, zip5_clean := str_pad(zip5, 5, pad = "0")]
nppes_classified <- merge(nppes_classified, xwalk,
                          by.x = "zip5_clean", by.y = "zcta5",
                          all.x = TRUE)

cat("  Providers mapped to county:", sum(!is.na(nppes_classified$county_fips)), "/",
    nrow(nppes_classified),
    sprintf("(%.1f%%)", 100 * mean(!is.na(nppes_classified$county_fips))), "\n")

# Create NPI lookup: npi -> (specialty, county_fips, state, provider_type)
npi_lookup <- nppes_classified[!is.na(county_fips),
  .(npi = as.character(npi), specialty, county_fips, state, provider_type,
    enumeration_date, deactivation_date)]
setkey(npi_lookup, npi)

cat("  NPI lookup size:", nrow(npi_lookup), "\n")

cat("\n=== Step 3: Build County-Specialty-Quarter Panel from T-MSIS ===\n")

# Open T-MSIS lazily
tmsis <- open_dataset(TMSIS_PATH)
cat("  T-MSIS schema:", paste(names(tmsis), collapse = ", "), "\n")

# Process in Arrow: aggregate by billing NPI × month, then collect
# We only need billing NPI and month for provider counting
cat("  Scanning T-MSIS (this takes a few minutes)...\n")

provider_months <- tmsis |>
  filter(!is.na(BILLING_PROVIDER_NPI_NUM)) |>
  group_by(BILLING_PROVIDER_NPI_NUM, CLAIM_FROM_MONTH) |>
  summarize(
    total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    total_benes  = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
    total_paid   = sum(TOTAL_PAID, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect() |>
  as.data.table()

cat("  Provider-month rows:", nrow(provider_months), "\n")

# Parse month to quarter
provider_months[, `:=`(
  npi = BILLING_PROVIDER_NPI_NUM,
  year = as.integer(substr(CLAIM_FROM_MONTH, 1, 4)),
  month = as.integer(substr(CLAIM_FROM_MONTH, 6, 7))
)]
provider_months[, quarter := paste0(year, "Q", ceiling(month / 3))]

# Drop 2024Q4 (incomplete data — Nov/Dec claim lag)
provider_months <- provider_months[!(year == 2024 & month >= 10)]

cat("  After dropping 2024Q4:", nrow(provider_months), "\n")

# Aggregate to NPI × quarter
provider_quarters <- provider_months[, .(
  claims_quarter = sum(total_claims),
  benes_quarter  = sum(total_benes),
  paid_quarter   = sum(total_paid),
  months_active  = .N
), by = .(npi, quarter, year)]

cat("  Provider-quarter rows:", nrow(provider_quarters), "\n")

# Join to NPI lookup for specialty + county
provider_quarters <- merge(provider_quarters, npi_lookup,
                           by = "npi", all.x = FALSE)  # inner join

cat("  After specialty/county join:", nrow(provider_quarters), "\n")

# Define "active" thresholds
provider_quarters[, `:=`(
  active_loose  = claims_quarter >= 1,
  active_strict = claims_quarter >= 4,    # ~1/month minimum
  active_ft     = claims_quarter >= 12    # ~1/week, full-time equivalent
)]

cat("\n=== Step 4: Build County × Specialty × Quarter Panel ===\n")

# Aggregate to county × specialty × quarter
county_spec_qtr <- provider_quarters[active_strict == TRUE, .(
  n_providers    = uniqueN(npi),
  total_claims   = sum(claims_quarter),
  total_benes    = sum(benes_quarter),
  total_paid     = sum(paid_quarter),
  n_md           = uniqueN(npi[provider_type == "MD"]),
  n_do           = uniqueN(npi[provider_type == "DO"]),
  n_np           = uniqueN(npi[provider_type == "NP"]),
  n_pa           = uniqueN(npi[provider_type == "PA"])
), by = .(county_fips, specialty, quarter, year)]

# Also compute with loose threshold for robustness
county_spec_qtr_loose <- provider_quarters[active_loose == TRUE, .(
  n_providers_loose = uniqueN(npi)
), by = .(county_fips, specialty, quarter, year)]

county_spec_qtr <- merge(county_spec_qtr, county_spec_qtr_loose,
                         by = c("county_fips", "specialty", "quarter", "year"),
                         all.x = TRUE)

cat("  County × specialty × quarter cells:", nrow(county_spec_qtr), "\n")
cat("  Unique counties:", uniqueN(county_spec_qtr$county_fips), "\n")
cat("  Unique specialties:", uniqueN(county_spec_qtr$specialty), "\n")
cat("  Unique quarters:", uniqueN(county_spec_qtr$quarter), "\n")

# State from county FIPS
county_spec_qtr[, state_fips := substr(county_fips, 1, 2)]

cat("\n=== Step 5: Save ===\n")

saveRDS(county_spec_qtr, file.path(DATA_DIR, "county_specialty_quarter.rds"))
saveRDS(provider_quarters, file.path(DATA_DIR, "provider_quarters.rds"))
saveRDS(npi_lookup, file.path(DATA_DIR, "npi_lookup.rds"))

cat("  Saved county_specialty_quarter.rds\n")
cat("  Saved provider_quarters.rds\n")
cat("  Saved npi_lookup.rds\n")

cat("\n=== Summary Statistics ===\n")
cat("Providers by specialty (strict threshold, any quarter):\n")
print(county_spec_qtr[, .(
  counties = uniqueN(county_fips),
  avg_providers = round(mean(n_providers), 1),
  total_providers = sum(n_providers)
), by = specialty][order(-total_providers)])

cat("\nDone with data construction.\n")
