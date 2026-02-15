## ============================================================================
## 02_clean_data.R — Build NY-specific panels from T-MSIS + NPPES
## ============================================================================

source("00_packages.R")

## ---- 1. Load NPPES and identify NY providers ----
cat("Loading NPPES extract...\n")
nppes <- read_parquet(file.path(DATA, "nppes_extract.parquet"))
nppes <- as.data.table(nppes)

cat(sprintf("  Total NPIs: %s\n", format(nrow(nppes), big.mark = ",")))

# NY providers
ny_npis <- nppes[state == "NY"]
cat(sprintf("  NY NPIs in NPPES: %s\n", format(nrow(ny_npis), big.mark = ",")))

# Clean ZIP to 5-digit
ny_npis[, zip5 := substr(gsub("[^0-9]", "", zip), 1, 5)]
ny_npis <- ny_npis[nchar(zip5) == 5]

# Classify entity type
ny_npis[, entity_label := fifelse(entity_type == "1", "Individual", "Organization")]

# Extract primary taxonomy for specialty classification
# Taxonomy codes follow NUCC classification
ny_npis[, taxonomy_primary := taxonomy_1]

# Broad specialty grouping based on taxonomy prefix
ny_npis[, specialty_group := fcase(
  grepl("^251E", taxonomy_primary), "Home Health Agency",
  grepl("^251B", taxonomy_primary), "Assisted Living",
  grepl("^376G|^376K", taxonomy_primary), "Nursing Facility",
  grepl("^261QF", taxonomy_primary), "FQHC",
  grepl("^261Q", taxonomy_primary), "Clinic/Center",
  grepl("^207|^208|^174|^204|^2084", taxonomy_primary), "Physician",
  grepl("^363L", taxonomy_primary), "Nurse Practitioner",
  grepl("^363A", taxonomy_primary), "Physician Assistant",
  grepl("^103T|^1041C", taxonomy_primary), "Behavioral Health",
  grepl("^152W|^156F|^225", taxonomy_primary), "Therapist (PT/OT/SLP)",
  grepl("^372", taxonomy_primary), "Personal Care Agency",
  grepl("^374", taxonomy_primary), "Home Health Aide",
  default = "Other"
)]

cat("Specialty distribution (NY):\n")
print(ny_npis[, .N, by = specialty_group][order(-N)])

## ---- 2. Define geographic regions ----
# NYC boroughs by county FIPS
nyc_counties <- c("36005", "36047", "36061", "36081", "36085")
# Bronx=005, Kings/Brooklyn=047, New York/Manhattan=061, Queens=081, Richmond/SI=085

# NYC ZIP ranges (approximate - will refine with county xwalk)
# But also use county-level for precision
xwalk <- readRDS(file.path(DATA, "zcta_county_xwalk.rds"))

# Ensure zcta is character for merge
xwalk[, zcta := as.character(zcta)]
xwalk[nchar(zcta) == 4, zcta := paste0("0", zcta)]  # Pad leading zero

# Merge county to NY NPIs via ZIP
ny_npis <- merge(ny_npis, xwalk[, .(zcta, county_fips)],
                  by.x = "zip5", by.y = "zcta", all.x = TRUE)

# Region classification
ny_npis[, region := fcase(
  county_fips %in% nyc_counties, "NYC",
  county_fips %in% c("36059", "36103"), "Long Island",  # Nassau=059, Suffolk=103
  county_fips %in% c("36119", "36087"), "Hudson Valley (Westchester/Rockland)",
  !is.na(county_fips), "Upstate",
  default = "Unknown"
)]

# Borough names for NYC
ny_npis[, borough := fcase(
  county_fips == "36005", "Bronx",
  county_fips == "36047", "Brooklyn",
  county_fips == "36061", "Manhattan",
  county_fips == "36081", "Queens",
  county_fips == "36085", "Staten Island",
  default = NA_character_
)]

cat("\nRegion distribution:\n")
print(ny_npis[, .N, by = region][order(-N)])

## ---- 3. Load T-MSIS and filter to NY billing NPIs ----
cat("\nLoading T-MSIS (filtering to NY billing NPIs)...\n")

ny_npi_set <- as.character(unique(ny_npis$npi))

# Use arrow to filter efficiently
tmsis <- open_dataset(file.path(DATA, "tmsis_full.parquet"))

ny_tmsis <- tmsis |>
  filter(BILLING_PROVIDER_NPI_NUM %in% ny_npi_set) |>
  collect()

ny_tmsis <- as.data.table(ny_tmsis)
cat(sprintf("  NY T-MSIS rows: %s\n", format(nrow(ny_tmsis), big.mark = ",")))
cat(sprintf("  NY total spending: $%s\n",
            format(sum(ny_tmsis$TOTAL_PAID, na.rm = TRUE), big.mark = ",")))

## ---- 4. HCPCS classification ----
ny_tmsis[, hcpcs_prefix := substr(HCPCS_CODE, 1, 1)]

ny_tmsis[, service_category := fcase(
  hcpcs_prefix == "T", "T-codes (Home/Community)",
  hcpcs_prefix == "H", "H-codes (Behavioral Health)",
  hcpcs_prefix == "S", "S-codes (State-specific)",
  hcpcs_prefix == "D", "D-codes (Dental)",
  hcpcs_prefix == "A", "A-codes (Transport/Supply)",
  grepl("^99[2-9]", HCPCS_CODE), "E&M (Office/Hospital)",
  grepl("^9[0-8]", HCPCS_CODE), "Medicine/Therapy",
  grepl("^[0-6]", HCPCS_CODE), "Surgery/Procedures",
  grepl("^7", HCPCS_CODE), "Radiology/Imaging",
  grepl("^8", HCPCS_CODE), "Lab/Pathology",
  grepl("^J", HCPCS_CODE), "J-codes (Drugs)",
  grepl("^G", HCPCS_CODE), "G-codes (CMS procedures)",
  default = "Other"
)]

## ---- 5. Merge NPI geography into T-MSIS ----
cat("Merging geography into T-MSIS...\n")

npi_zip <- ny_npis[, .(npi, zip5, county_fips, region, borough, entity_type,
                        entity_label, specialty_group)]

# Ensure NPI types match for merge
npi_zip[, npi := as.character(npi)]
ny_tmsis[, BILLING_PROVIDER_NPI_NUM := as.character(BILLING_PROVIDER_NPI_NUM)]

ny_tmsis_geo <- merge(ny_tmsis, npi_zip,
                       by.x = "BILLING_PROVIDER_NPI_NUM", by.y = "npi",
                       all.x = TRUE)

cat(sprintf("  Rows with ZIP match: %s / %s\n",
            format(sum(!is.na(ny_tmsis_geo$zip5)), big.mark = ","),
            format(nrow(ny_tmsis_geo), big.mark = ",")))

## ---- 5b. Build ZIP-level panel ----
cat("Building ZIP-level panel...\n")

# Aggregate spending by ZIP × month
zip_monthly <- ny_tmsis_geo[!is.na(zip5), .(
  total_paid = sum(TOTAL_PAID, na.rm = TRUE),
  total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
  total_beneficiaries = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
  n_providers = uniqueN(BILLING_PROVIDER_NPI_NUM)
), by = .(zip5, month = CLAIM_FROM_MONTH)]

# Aggregate spending by ZIP (cumulative)
zip_total <- ny_tmsis_geo[!is.na(zip5), .(
  total_paid = sum(TOTAL_PAID, na.rm = TRUE),
  total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
  total_beneficiaries = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
  n_providers = uniqueN(BILLING_PROVIDER_NPI_NUM)
), by = zip5]

## ---- 6. Build ZIP-level service mix ----
cat("Building ZIP-level service mix...\n")

zip_service <- ny_tmsis_geo[, .(
  total_paid = sum(TOTAL_PAID, na.rm = TRUE)
), by = .(zip5, service_category)]

# Pivot wider for each ZIP's service composition
zip_service_wide <- dcast(zip_service, zip5 ~ service_category,
                           value.var = "total_paid", fill = 0)

## ---- 7. Build county-level panel ----
cat("Building county-level panel...\n")

county_total <- ny_tmsis_geo[!is.na(county_fips), .(
  total_paid = sum(TOTAL_PAID, na.rm = TRUE),
  total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
  total_beneficiaries = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
  n_providers = uniqueN(BILLING_PROVIDER_NPI_NUM),
  n_orgs = uniqueN(BILLING_PROVIDER_NPI_NUM[entity_type == "2"]),
  n_individuals = uniqueN(BILLING_PROVIDER_NPI_NUM[entity_type == "1"])
), by = county_fips]

# County service mix
county_service <- ny_tmsis_geo[!is.na(county_fips), .(
  total_paid = sum(TOTAL_PAID, na.rm = TRUE)
), by = .(county_fips, service_category)]

## ---- 8. T1019 analysis ----
cat("Building T1019 analysis...\n")

# T1019 spending by ZIP
t1019_zip <- ny_tmsis_geo[HCPCS_CODE == "T1019", .(
  t1019_paid = sum(TOTAL_PAID, na.rm = TRUE),
  t1019_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
  t1019_beneficiaries = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
  t1019_providers = uniqueN(BILLING_PROVIDER_NPI_NUM)
), by = zip5]

# T1019 monthly time series
t1019_monthly <- ny_tmsis[HCPCS_CODE == "T1019", .(
  total_paid = sum(TOTAL_PAID, na.rm = TRUE),
  total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
  n_providers = uniqueN(BILLING_PROVIDER_NPI_NUM)
), by = CLAIM_FROM_MONTH]
t1019_monthly[, month_date := as.Date(paste0(CLAIM_FROM_MONTH, "-01"))]
setorder(t1019_monthly, month_date)

## ---- 9. Provider tenure in NY ----
cat("Building provider tenure panel...\n")

ny_provider_months <- ny_tmsis[, .(
  months_active = uniqueN(CLAIM_FROM_MONTH),
  total_paid = sum(TOTAL_PAID, na.rm = TRUE),
  total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
  first_month = min(CLAIM_FROM_MONTH),
  last_month = max(CLAIM_FROM_MONTH)
), by = BILLING_PROVIDER_NPI_NUM]

# Merge geography
ny_provider_months <- merge(ny_provider_months, npi_zip,
                             by.x = "BILLING_PROVIDER_NPI_NUM", by.y = "npi",
                             all.x = TRUE)

# Tenure buckets
ny_provider_months[, tenure_group := fcase(
  months_active == 1, "1 month",
  months_active <= 3, "2-3 months",
  months_active <= 6, "4-6 months",
  months_active <= 11, "7-11 months",
  months_active <= 18, "12-18 months",
  months_active <= 24, "19-24 months",
  months_active <= 48, "25-48 months",
  months_active <= 72, "49-72 months",
  default = "73-84 months"
)]

## ---- 10. Market concentration (HHI by county for T1019) ----
cat("Computing market concentration...\n")

# T1019 spending by provider × county
t1019_provider_county <- ny_tmsis_geo[
  HCPCS_CODE == "T1019" & !is.na(county_fips),
  .(provider_paid = sum(TOTAL_PAID, na.rm = TRUE)),
  by = .(county_fips, BILLING_PROVIDER_NPI_NUM)
]

# Exclude providers with zero spending (they don't participate in the market)
t1019_provider_county <- t1019_provider_county[provider_paid > 0]

# Compute market shares and HHI
t1019_provider_county[, county_total := sum(provider_paid), by = county_fips]
t1019_provider_county[, market_share := provider_paid / county_total]
t1019_provider_county[, share_sq := market_share^2]

hhi_county <- t1019_provider_county[, .(
  hhi = sum(share_sq) * 10000,
  n_providers = .N,
  total_paid = sum(provider_paid),
  top1_share = max(market_share),
  top3_share = sum(sort(market_share, decreasing = TRUE)[1:min(3, .N)])
), by = county_fips]

## ---- 11. NYC borough comparison ----
cat("Building NYC borough panel...\n")

borough_stats <- ny_tmsis_geo[!is.na(borough), .(
  total_paid = sum(TOTAL_PAID, na.rm = TRUE),
  total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
  n_providers = uniqueN(BILLING_PROVIDER_NPI_NUM),
  n_orgs = uniqueN(BILLING_PROVIDER_NPI_NUM[entity_type == "2"]),
  pct_t1019 = sum(TOTAL_PAID[HCPCS_CODE == "T1019"], na.rm = TRUE) /
    sum(TOTAL_PAID, na.rm = TRUE) * 100
), by = borough]

## ---- 12. National comparison data ----
cat("Computing national comparison statistics...\n")

# Load full T-MSIS for national totals by service category
national_service <- tmsis |>
  mutate(service_category = case_when(
    substr(HCPCS_CODE, 1, 1) == "T" ~ "T-codes (Home/Community)",
    substr(HCPCS_CODE, 1, 1) == "H" ~ "H-codes (Behavioral Health)",
    substr(HCPCS_CODE, 1, 1) == "S" ~ "S-codes (State-specific)",
    substr(HCPCS_CODE, 1, 1) == "D" ~ "D-codes (Dental)",
    substr(HCPCS_CODE, 1, 1) == "A" ~ "A-codes (Transport/Supply)",
    grepl("^99[2-9]", HCPCS_CODE) ~ "E&M (Office/Hospital)",
    grepl("^9[0-8]", HCPCS_CODE) ~ "Medicine/Therapy",
    grepl("^J", HCPCS_CODE) ~ "J-codes (Drugs)",
    grepl("^G", HCPCS_CODE) ~ "G-codes (CMS procedures)",
    TRUE ~ "Other"
  )) |>
  group_by(service_category) |>
  summarize(
    national_paid = sum(TOTAL_PAID, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect()

national_service <- as.data.table(national_service)
national_service[, national_pct := national_paid / sum(national_paid) * 100]

## ---- 13. Save all panels ----
cat("Saving panels...\n")

saveRDS(ny_npis, file.path(DATA, "ny_npis.rds"))
saveRDS(zip_total, file.path(DATA, "zip_total.rds"))
saveRDS(zip_service_wide, file.path(DATA, "zip_service_wide.rds"))
saveRDS(county_total, file.path(DATA, "county_total.rds"))
saveRDS(county_service, file.path(DATA, "county_service.rds"))
saveRDS(t1019_zip, file.path(DATA, "t1019_zip.rds"))
saveRDS(t1019_monthly, file.path(DATA, "t1019_monthly.rds"))
saveRDS(ny_provider_months, file.path(DATA, "ny_provider_months.rds"))
saveRDS(hhi_county, file.path(DATA, "hhi_county.rds"))
saveRDS(borough_stats, file.path(DATA, "borough_stats.rds"))
saveRDS(national_service, file.path(DATA, "national_service.rds"))
saveRDS(zip_monthly, file.path(DATA, "zip_monthly.rds"))

cat(sprintf("\nAll panels saved. NY providers: %s, ZIP-level: %s ZIPs\n",
            format(nrow(ny_npis), big.mark = ","),
            format(nrow(zip_total), big.mark = ",")))
