## ============================================================================
## 02_clean_data.R — Clean T-MSIS, join NPPES, build analysis panels
## Uses Arrow lazy evaluation to handle 227M rows without exceeding memory
## ============================================================================

source("00_packages.R")
library(dplyr)  # for Arrow dplyr interface

DATA <- "../data"

## ---- 1. Open T-MSIS as Arrow Dataset (lazy, no memory load) ----
cat("Opening T-MSIS Parquet (lazy)...\n")
tmsis_ds <- open_dataset(file.path(DATA, "tmsis_full.parquet"))
cat(sprintf("Schema: %s\n", paste(names(tmsis_ds), collapse=", ")))

## ---- 2. Compute basic stats via Arrow (no full memory load) ----
cat("Computing basic stats...\n")

# Total rows
n_total <- tmsis_ds |> summarize(n = n()) |> collect()
cat(sprintf("Total rows: %s\n", format(n_total$n, big.mark=",")))

# Total spending, claims, beneficiaries
totals <- tmsis_ds |>
  summarize(
    total_paid = sum(TOTAL_PAID, na.rm = TRUE),
    total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    total_benef = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE)
  ) |> collect()
cat(sprintf("Total paid: $%s\n", format(totals$total_paid, big.mark=",")))
cat(sprintf("Total claims: %s\n", format(totals$total_claims, big.mark=",")))

# Unique providers and codes
unique_billing <- tmsis_ds |>
  distinct(BILLING_PROVIDER_NPI_NUM) |>
  summarize(n = n()) |> collect()
unique_servicing <- tmsis_ds |>
  filter(!is.na(SERVICING_PROVIDER_NPI_NUM), SERVICING_PROVIDER_NPI_NUM != "") |>
  distinct(SERVICING_PROVIDER_NPI_NUM) |>
  summarize(n = n()) |> collect()
unique_hcpcs <- tmsis_ds |>
  distinct(HCPCS_CODE) |>
  summarize(n = n()) |> collect()

cat(sprintf("Unique billing NPIs: %s\n", format(unique_billing$n, big.mark=",")))
cat(sprintf("Unique servicing NPIs: %s\n", format(unique_servicing$n, big.mark=",")))
cat(sprintf("Unique HCPCS codes: %s\n", format(unique_hcpcs$n, big.mark=",")))

# Date range
months <- tmsis_ds |>
  summarize(min_m = min(CLAIM_FROM_MONTH), max_m = max(CLAIM_FROM_MONTH)) |>
  collect()
cat(sprintf("Date range: %s to %s\n", months$min_m, months$max_m))

## ---- 3. Build HCPCS-classified aggregates via Arrow ----
cat("Building monthly aggregates by service category...\n")

# We need to add hcpcs_category. Arrow supports mutate with case_when.
panel_monthly <- tmsis_ds |>
  mutate(
    year = as.integer(substr(CLAIM_FROM_MONTH, 1, 4)),
    month_num = as.integer(substr(CLAIM_FROM_MONTH, 6, 7)),
    hcpcs_prefix = substr(HCPCS_CODE, 1, 1),
    hcpcs_category = case_when(
      hcpcs_prefix == "T" ~ "HCBS/State (T-codes)",
      hcpcs_prefix == "H" ~ "Behavioral Health (H-codes)",
      hcpcs_prefix == "S" ~ "Temporary/State (S-codes)",
      hcpcs_prefix == "J" ~ "Drugs (J-codes)",
      hcpcs_prefix == "A" ~ "Ambulance/DME (A-codes)",
      hcpcs_prefix == "G" ~ "CMS Procedures (G-codes)",
      hcpcs_prefix == "E" ~ "DME (E-codes)",
      hcpcs_prefix == "L" ~ "Orthotics/Prosthetics (L-codes)",
      hcpcs_prefix %in% c("0","1","2","3","4","5","6","7","8","9") ~ "CPT Professional Services",
      TRUE ~ "Other"
    )
  ) |>
  group_by(year, month_num, CLAIM_FROM_MONTH, hcpcs_category) |>
  summarize(
    total_paid = sum(TOTAL_PAID, na.rm = TRUE),
    total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    total_beneficiaries = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect() |>
  as.data.table()

panel_monthly[, month_date := as.Date(paste0(CLAIM_FROM_MONTH, "-01"))]
setorder(panel_monthly, month_date, hcpcs_category)
cat(sprintf("Monthly panel: %d rows\n", nrow(panel_monthly)))

# National monthly totals
panel_national <- panel_monthly[, .(
  total_paid = sum(total_paid),
  total_claims = sum(total_claims),
  total_beneficiaries = sum(total_beneficiaries)
), by = .(year, month_num, month_date)]
setorder(panel_national, month_date)

# Count unique providers and codes per month (separate query)
cat("Counting providers and codes per month...\n")
provider_month_counts <- tmsis_ds |>
  mutate(
    year = as.integer(substr(CLAIM_FROM_MONTH, 1, 4)),
    month_num = as.integer(substr(CLAIM_FROM_MONTH, 6, 7))
  ) |>
  group_by(year, month_num, CLAIM_FROM_MONTH) |>
  summarize(
    n_providers = n_distinct(BILLING_PROVIDER_NPI_NUM),
    n_hcpcs = n_distinct(HCPCS_CODE),
    .groups = "drop"
  ) |>
  collect() |>
  as.data.table()

provider_month_counts[, month_date := as.Date(paste0(CLAIM_FROM_MONTH, "-01"))]
panel_national <- merge(panel_national, provider_month_counts[, .(month_date, n_providers, n_hcpcs)],
                        by = "month_date", all.x = TRUE)

## ---- 4. Top HCPCS codes ----
cat("Computing top HCPCS codes...\n")
panel_hcpcs <- tmsis_ds |>
  mutate(
    hcpcs_prefix = substr(HCPCS_CODE, 1, 1),
    hcpcs_category = case_when(
      hcpcs_prefix == "T" ~ "HCBS/State (T-codes)",
      hcpcs_prefix == "H" ~ "Behavioral Health (H-codes)",
      hcpcs_prefix == "S" ~ "Temporary/State (S-codes)",
      hcpcs_prefix == "J" ~ "Drugs (J-codes)",
      hcpcs_prefix == "A" ~ "Ambulance/DME (A-codes)",
      hcpcs_prefix == "G" ~ "CMS Procedures (G-codes)",
      hcpcs_prefix == "E" ~ "DME (E-codes)",
      hcpcs_prefix == "L" ~ "Orthotics/Prosthetics (L-codes)",
      hcpcs_prefix %in% c("0","1","2","3","4","5","6","7","8","9") ~ "CPT Professional Services",
      TRUE ~ "Other"
    )
  ) |>
  group_by(HCPCS_CODE, hcpcs_category) |>
  summarize(
    total_paid = sum(TOTAL_PAID, na.rm = TRUE),
    total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    total_beneficiaries = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
    n_providers = n_distinct(BILLING_PROVIDER_NPI_NUM),
    .groups = "drop"
  ) |>
  collect() |>
  as.data.table()

setnames(panel_hcpcs, "HCPCS_CODE", "hcpcs_code")
setorder(panel_hcpcs, -total_paid)

# Add detail labels for top codes
panel_hcpcs[, hcpcs_detail := fcase(
  hcpcs_code == "T1019", "Personal Care (T1019)",
  hcpcs_code == "T2016", "Habilitation Residential (T2016)",
  hcpcs_code == "S5125", "Attendant Care (S5125)",
  hcpcs_code == "H2016", "Community Support/Diem (H2016)",
  hcpcs_code == "T1015", "FQHC Clinic Visit (T1015)",
  hcpcs_code == "H2015", "Community Support/15min (H2015)",
  hcpcs_code == "T2025", "Waiver Services (T2025)",
  hcpcs_code == "99213", "Office Visit Estab. (99213)",
  hcpcs_code == "99214", "Office Visit Estab. (99214)",
  hcpcs_code == "T1016", "Case Management (T1016)",
  default = hcpcs_category
)]
cat(sprintf("HCPCS codes: %d unique\n", nrow(panel_hcpcs)))

## ---- 5. Billing structure ----
cat("Computing billing structure...\n")
panel_billing <- tmsis_ds |>
  mutate(
    billing_structure = case_when(
      is.na(SERVICING_PROVIDER_NPI_NUM) | SERVICING_PROVIDER_NPI_NUM == "" ~ "Solo (no servicing NPI)",
      BILLING_PROVIDER_NPI_NUM == SERVICING_PROVIDER_NPI_NUM ~ "Self-billing (billing = servicing)",
      TRUE ~ "Organization billing (billing != servicing)"
    )
  ) |>
  group_by(billing_structure) |>
  summarize(
    total_paid = sum(TOTAL_PAID, na.rm = TRUE),
    total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    n_rows = n(),
    .groups = "drop"
  ) |>
  collect() |>
  as.data.table()

panel_billing[, pct_rows := n_rows / sum(n_rows) * 100]

## ---- 6. Provider-level panel (chunked to save memory) ----
cat("Building provider-level panel (first/last month, volume)...\n")
provider_panel <- tmsis_ds |>
  group_by(BILLING_PROVIDER_NPI_NUM) |>
  summarize(
    first_month = min(CLAIM_FROM_MONTH),
    last_month = max(CLAIM_FROM_MONTH),
    active_months = n_distinct(CLAIM_FROM_MONTH),
    total_paid = sum(TOTAL_PAID, na.rm = TRUE),
    total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    n_hcpcs = n_distinct(HCPCS_CODE),
    .groups = "drop"
  ) |>
  collect() |>
  as.data.table()

setnames(provider_panel, "BILLING_PROVIDER_NPI_NUM", "billing_npi")
provider_panel[, first_date := as.Date(paste0(first_month, "-01"))]
provider_panel[, last_date := as.Date(paste0(last_month, "-01"))]
provider_panel[, tenure_months := as.numeric(difftime(last_date, first_date, units = "days")) / 30.44 + 1]
provider_panel[, activity_rate := active_months / tenure_months]
cat(sprintf("Provider panel: %s unique providers\n", format(nrow(provider_panel), big.mark=",")))

## ---- 7. Provider first appearance (entry) and last appearance (exit) ----
cat("Computing entry/exit flows...\n")
new_entrants <- provider_panel[, .N, by = first_month]
setnames(new_entrants, c("month", "new_providers"))
new_entrants[, month_date := as.Date(paste0(month, "-01"))]

max_month <- max(provider_panel$last_month)
exiting <- provider_panel[last_month < max_month, .N, by = last_month]
setnames(exiting, c("month", "exiting_providers"))
exiting[, month_date := as.Date(paste0(month, "-01"))]

## ---- 8. Join NPPES for state-level analysis ----
cat("Loading NPPES...\n")
nppes <- as.data.table(read_parquet(file.path(DATA, "nppes_extract.parquet")))
cat(sprintf("NPPES: %s providers\n", format(nrow(nppes), big.mark=",")))

# Ensure NPI types match (Arrow reads as character, fread as integer)
nppes[, npi := as.character(npi)]

# Join provider_panel to NPPES for state
provider_panel_enriched <- merge(provider_panel,
                                  nppes[, .(npi, entity_type, state, zip5, taxonomy_1,
                                            credential, gender, sole_prop,
                                            parent_org_name, parent_org_tin,
                                            enumeration_date, deactivation_date)],
                                  by.x = "billing_npi", by.y = "npi",
                                  all.x = TRUE, sort = FALSE)

match_rate <- sum(!is.na(provider_panel_enriched$state)) / nrow(provider_panel_enriched) * 100
cat(sprintf("NPPES match rate: %.1f%%\n", match_rate))

# Provider type
provider_panel_enriched[, provider_type := fifelse(entity_type == "1", "Individual", "Organization")]

## ---- 9. State-level panels (using provider_panel + NPPES) ----
cat("Building state-level panels...\n")

# Annual state totals from provider panel
# We need state-level monthly data - compute from Arrow with NPI-based join

# First, get NPI → state mapping (npi already converted to character above)
npi_state <- nppes[!is.na(state) & state != "", .(npi, state)]

# Compute state totals via Arrow
# This requires a semi-join which Arrow can't do directly
# Instead, compute provider-level annual totals then join state
provider_annual <- tmsis_ds |>
  mutate(year = as.integer(substr(CLAIM_FROM_MONTH, 1, 4))) |>
  group_by(BILLING_PROVIDER_NPI_NUM, year) |>
  summarize(
    total_paid = sum(TOTAL_PAID, na.rm = TRUE),
    total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    total_beneficiaries = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect() |>
  as.data.table()

setnames(provider_annual, "BILLING_PROVIDER_NPI_NUM", "billing_npi")

# Join state
provider_annual_state <- merge(provider_annual, npi_state,
                                by.x = "billing_npi", by.y = "npi",
                                all.x = TRUE)

# State × year panel
panel_state <- provider_annual_state[!is.na(state), .(
  total_paid = sum(total_paid),
  total_claims = sum(total_claims),
  total_beneficiaries = sum(total_beneficiaries),
  n_providers = uniqueN(billing_npi)
), by = .(state, year)]

# Clean up large temp object
rm(provider_annual, provider_annual_state)
gc()

## ---- 10. Category composition by service category ----
cat("Computing service category totals...\n")
cat_summary <- panel_monthly[, .(
  total_paid = sum(total_paid),
  total_claims = sum(total_claims)
), by = hcpcs_category]
cat_summary[, pct_paid := total_paid / sum(total_paid) * 100]
setorder(cat_summary, -total_paid)

## ---- 11. Save all panels ----
cat("Saving panels...\n")
saveRDS(panel_monthly, file.path(DATA, "panel_monthly.rds"))
saveRDS(panel_national, file.path(DATA, "panel_national.rds"))
saveRDS(panel_hcpcs, file.path(DATA, "panel_hcpcs.rds"))
saveRDS(panel_billing, file.path(DATA, "panel_billing.rds"))
saveRDS(provider_panel, file.path(DATA, "provider_panel.rds"))
saveRDS(provider_panel_enriched, file.path(DATA, "provider_panel_enriched.rds"))
saveRDS(panel_state, file.path(DATA, "panel_state.rds"))
saveRDS(new_entrants, file.path(DATA, "new_entrants.rds"))
saveRDS(exiting, file.path(DATA, "exiting.rds"))
saveRDS(cat_summary, file.path(DATA, "cat_summary.rds"))

## ---- 12. Print summary ----
cat("\n=== FULL DATASET SUMMARY ===\n")
cat(sprintf("Total rows: %s\n", format(n_total$n, big.mark=",")))
cat(sprintf("Total paid: $%s\n", format(totals$total_paid, big.mark=",")))
cat(sprintf("Total claims: %s\n", format(totals$total_claims, big.mark=",")))
cat(sprintf("Unique billing NPIs: %s\n", format(unique_billing$n, big.mark=",")))
cat(sprintf("Unique servicing NPIs: %s\n", format(unique_servicing$n, big.mark=",")))
cat(sprintf("Unique HCPCS codes: %d\n", unique_hcpcs$n))
cat(sprintf("Date range: %s to %s\n", months$min_m, months$max_m))
cat(sprintf("NPPES match rate: %.1f%%\n", match_rate))
cat(sprintf("States: %d\n", uniqueN(panel_state$state)))

cat("\nTop 10 HCPCS codes:\n")
top10 <- head(panel_hcpcs, 10)
top10[, paid_B := round(total_paid / 1e9, 1)]
print(top10[, .(hcpcs_code, hcpcs_detail, paid_B, n_providers = format(n_providers, big.mark=","))])

cat("\nService categories:\n")
print(cat_summary[, .(hcpcs_category, paid_B = round(total_paid/1e9, 1), pct = round(pct_paid, 1))])

cat("\nBilling structure:\n")
print(panel_billing[, .(billing_structure, pct_rows = round(pct_rows, 1),
                         paid_B = round(total_paid/1e9, 1))])

cat("\nProvider tenure distribution:\n")
cat(sprintf("  Full panel (84 months): %s (%.1f%%)\n",
    format(sum(provider_panel$active_months == 84), big.mark=","),
    sum(provider_panel$active_months == 84) / nrow(provider_panel) * 100))
cat(sprintf("  < 12 months: %s (%.1f%%)\n",
    format(sum(provider_panel$active_months < 12), big.mark=","),
    sum(provider_panel$active_months < 12) / nrow(provider_panel) * 100))
cat(sprintf("  Median tenure: %d months\n", median(provider_panel$active_months)))

cat("\n=== Clean complete ===\n")
