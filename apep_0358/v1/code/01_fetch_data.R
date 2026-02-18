## ============================================================================
## 01_fetch_data.R — Build postpartum-specific panel from T-MSIS + NPPES
## Paper: Medicaid Postpartum Coverage Extensions and Provider Supply
## ============================================================================

source("00_packages.R")

## ---- 0. Paths ----
SHARED_DATA <- file.path("..", "..", "..", "..", "data", "medicaid_provider_spending")
DATA <- "../data"
dir.create(DATA, showWarnings = FALSE, recursive = TRUE)

## ---- 1. Verify T-MSIS ----
tmsis_path <- file.path(SHARED_DATA, "tmsis.parquet")
if (!file.exists(tmsis_path)) {
  stop("T-MSIS Parquet file not found at: ", tmsis_path)
}
cat("Opening T-MSIS Parquet (lazy)...\n")
tmsis_ds <- open_dataset(tmsis_path)

## ---- 2. Load NPPES ----
nppes_path <- file.path(SHARED_DATA, "nppes_extract.parquet")
if (!file.exists(nppes_path)) stop("NPPES extract not found: ", nppes_path)
nppes <- as.data.table(read_parquet(nppes_path))
nppes[, npi := as.character(npi)]
cat(sprintf("NPPES loaded: %s providers\n", format(nrow(nppes), big.mark = ",")))

## ---- 3. Identify maternal health providers in NPPES ----
# OB/GYN taxonomy: 207V (Obstetrics & Gynecology and subspecialties)
# Nurse-Midwife taxonomy: 176B00000X
# Maternal-Fetal Medicine: 207VM0101X (subspecialty of 207V)
ob_npis <- nppes[grepl("^207V", taxonomy_1) | taxonomy_1 == "176B00000X",
                  .(npi, state, entity_type, taxonomy_1, credential, gender,
                    enumeration_date, deactivation_date)]
cat(sprintf("Maternal health providers in NPPES: %s\n", format(nrow(ob_npis), big.mark = ",")))

## ---- 4. Define postpartum-specific HCPCS codes ----
# Postpartum care codes
postpartum_codes <- c(
  "59430"  # Postpartum care only (separate procedure)
)

# Antepartum care codes (PLACEBO — should NOT respond to extension)
antepartum_codes <- c(
  "59425", # Antepartum care only, 4-6 visits
  "59426"  # Antepartum care only, 7+ visits
)

# Contraceptive service codes (provided in extended postpartum window)
contraceptive_codes <- c(
  "58300", # IUD insertion
  "11981", # Subdermal contraceptive implant insertion
  "11983"  # Subdermal contraceptive implant removal with reinsertion
)

# Delivery codes (for baseline volume)
delivery_codes <- c(
  "59409", # Vaginal delivery only
  "59410", # Vaginal delivery + postpartum care
  "59400", # Obstetric care (total, vaginal)
  "59510", # Cesarean delivery only
  "59610"  # Vaginal delivery after cesarean
)

# All maternal codes
all_maternal_codes <- c(postpartum_codes, antepartum_codes,
                        contraceptive_codes, delivery_codes)

## ---- 5. Build maternal care panel from T-MSIS ----
cat("Extracting maternal health claims from T-MSIS (lazy Arrow query)...\n")

# Step 5a: Filter T-MSIS to maternal HCPCS codes, aggregate by NPI × code × month
maternal_claims <- tmsis_ds |>
  filter(HCPCS_CODE %in% all_maternal_codes) |>
  group_by(BILLING_PROVIDER_NPI_NUM, HCPCS_CODE, CLAIM_FROM_MONTH) |>
  summarize(
    total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    total_paid   = sum(TOTAL_PAID, na.rm = TRUE),
    total_beneficiaries = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect() |>
  as.data.table()

setnames(maternal_claims, "BILLING_PROVIDER_NPI_NUM", "billing_npi")
cat(sprintf("Maternal claims collected: %s rows\n", format(nrow(maternal_claims), big.mark = ",")))

## ---- 5b: Also get total OB/GYN Medicaid billing (any code) ----
cat("Extracting all OB/GYN provider billing (for extensive margin)...\n")
obgyn_npi_list <- ob_npis$npi

# Use Arrow to filter by provider NPI and aggregate by month
# This is a large query — do it in chunks by year to manage memory
all_obgyn_billing <- list()
for (yr in 2018:2024) {
  cat(sprintf("  Processing year %d...\n", yr))
  yr_data <- tmsis_ds |>
    filter(
      substr(CLAIM_FROM_MONTH, 1, 4) == sprintf("%d", yr)
    ) |>
    mutate(billing_npi_char = cast(BILLING_PROVIDER_NPI_NUM, utf8())) |>
    filter(billing_npi_char %in% obgyn_npi_list) |>
    group_by(billing_npi_char, CLAIM_FROM_MONTH) |>
    summarize(
      total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
      total_paid   = sum(TOTAL_PAID, na.rm = TRUE),
      total_beneficiaries = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
      .groups = "drop"
    ) |>
    collect() |>
    as.data.table()

  setnames(yr_data, "billing_npi_char", "billing_npi")
  all_obgyn_billing[[as.character(yr)]] <- yr_data
}
obgyn_monthly <- rbindlist(all_obgyn_billing)
rm(all_obgyn_billing)
gc()

cat(sprintf("OB/GYN monthly billing collected: %s rows\n",
            format(nrow(obgyn_monthly), big.mark = ",")))

## ---- 6. Join NPPES state to maternal claims ----
npi_state <- ob_npis[!is.na(state) & state != "", .(npi, state)]

# Maternal claims: join state
maternal_claims <- merge(maternal_claims, npi_state,
                          by.x = "billing_npi", by.y = "npi",
                          all.x = TRUE)

# Also join state for non-OB/GYN providers who bill maternal codes
# (using full NPPES for this)
npi_state_all <- nppes[!is.na(state) & state != "", .(npi, state)]
maternal_claims[is.na(state), state := npi_state_all[match(
  maternal_claims[is.na(state), billing_npi], npi_state_all$npi
), state]]

# OB/GYN monthly: join state
obgyn_monthly <- merge(obgyn_monthly, npi_state,
                        by.x = "billing_npi", by.y = "npi",
                        all.x = TRUE)

# Drop records without state
maternal_claims <- maternal_claims[!is.na(state) & state != ""]
obgyn_monthly <- obgyn_monthly[!is.na(state) & state != ""]

## ---- 7. Parse dates ----
maternal_claims[, month_date := as.Date(paste0(CLAIM_FROM_MONTH, "-01"))]
maternal_claims[, year := year(month_date)]
maternal_claims[, month_num := month(month_date)]

obgyn_monthly[, month_date := as.Date(paste0(CLAIM_FROM_MONTH, "-01"))]
obgyn_monthly[, year := year(month_date)]
obgyn_monthly[, month_num := month(month_date)]

## ---- 8. Create code categories ----
maternal_claims[, code_category := fcase(
  HCPCS_CODE %in% postpartum_codes, "postpartum",
  HCPCS_CODE %in% antepartum_codes, "antepartum",
  HCPCS_CODE %in% contraceptive_codes, "contraceptive",
  HCPCS_CODE %in% delivery_codes, "delivery",
  default = "other"
)]

## ---- 9. Build state × month panels ----
cat("Building state × month panels...\n")

# Panel A: Maternal claims by category
panel_maternal <- maternal_claims[, .(
  claims     = sum(total_claims),
  paid       = sum(total_paid),
  beneficiaries = sum(total_beneficiaries),
  n_providers = uniqueN(billing_npi)
), by = .(state, month_date, year, month_num, code_category)]
setorder(panel_maternal, state, month_date, code_category)

# Panel B: OB/GYN extensive margin (any-code billing)
panel_obgyn <- obgyn_monthly[, .(
  total_claims = sum(total_claims),
  total_paid = sum(total_paid),
  total_beneficiaries = sum(total_beneficiaries),
  n_obgyn_billing = uniqueN(billing_npi)
), by = .(state, month_date, year, month_num)]
setorder(panel_obgyn, state, month_date)

cat(sprintf("Panel A (maternal by category): %d rows, %d states\n",
            nrow(panel_maternal), uniqueN(panel_maternal$state)))
cat(sprintf("Panel B (OB/GYN extensive): %d rows, %d states\n",
            nrow(panel_obgyn), uniqueN(panel_obgyn$state)))

## ---- 10. Fetch Census ACS state population ----
cat("Fetching Census ACS state population...\n")
census_key <- Sys.getenv("CENSUS_API_KEY")

pop_list <- list()
for (yr in 2018:2023) {
  url <- sprintf(
    "https://api.census.gov/data/%d/acs/acs5?get=B01003_001E,NAME&for=state:*",
    yr
  )
  if (nchar(census_key) > 0) url <- paste0(url, "&key=", census_key)

  resp <- tryCatch({
    jsonlite::fromJSON(url)
  }, error = function(e) {
    cat(sprintf("  Warning: ACS %d fetch failed: %s\n", yr, e$message))
    NULL
  })

  if (!is.null(resp)) {
    df <- as.data.frame(resp[-1, ], stringsAsFactors = FALSE)
    names(df) <- resp[1, ]
    pop_list[[as.character(yr)]] <- data.table(
      state_fips = df$state,
      state_name = df$NAME,
      population = as.numeric(df$B01003_001E),
      year = yr
    )
  }
}
state_pop <- rbindlist(pop_list)

# Map state FIPS to state abbreviation
fips_to_abbr <- c(
  "01"="AL","02"="AK","04"="AZ","05"="AR","06"="CA","08"="CO","09"="CT",
  "10"="DE","11"="DC","12"="FL","13"="GA","15"="HI","16"="ID","17"="IL",
  "18"="IN","19"="IA","20"="KS","21"="KY","22"="LA","23"="ME","24"="MD",
  "25"="MA","26"="MI","27"="MN","28"="MS","29"="MO","30"="MT","31"="NE",
  "32"="NV","33"="NH","34"="NJ","35"="NM","36"="NY","37"="NC","38"="ND",
  "39"="OH","40"="OK","41"="OR","42"="PA","44"="RI","45"="SC","46"="SD",
  "47"="TN","48"="TX","49"="UT","50"="VT","51"="VA","53"="WA","54"="WV",
  "55"="WI","56"="WY"
)
state_pop[, state := fips_to_abbr[state_fips]]
state_pop <- state_pop[!is.na(state)]

# Extend 2023 population to 2024
pop_2024 <- state_pop[year == 2023]
pop_2024[, year := 2024L]
state_pop <- rbind(state_pop, pop_2024)

cat(sprintf("State population data: %d rows\n", nrow(state_pop)))

## ---- 11. Save everything ----
saveRDS(maternal_claims, file.path(DATA, "maternal_claims.rds"))
saveRDS(panel_maternal, file.path(DATA, "panel_maternal.rds"))
saveRDS(panel_obgyn, file.path(DATA, "panel_obgyn.rds"))
saveRDS(ob_npis, file.path(DATA, "ob_npis.rds"))
saveRDS(state_pop, file.path(DATA, "state_pop.rds"))

cat("\n=== Data preparation complete ===\n")
cat(sprintf("Maternal claims: %s rows\n", format(nrow(maternal_claims), big.mark = ",")))
cat(sprintf("Panel (maternal by category): %s rows\n", format(nrow(panel_maternal), big.mark = ",")))
cat(sprintf("Panel (OB/GYN extensive): %s rows\n", format(nrow(panel_obgyn), big.mark = ",")))
