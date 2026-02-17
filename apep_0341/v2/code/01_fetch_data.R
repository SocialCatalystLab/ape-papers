## ============================================================================
## 01_fetch_data.R — Load T-MSIS + NPPES, build state-month panels
## apep_0341 v2: Medicaid Reimbursement Rates and HCBS Provider Supply
## ============================================================================

source("00_packages.R")

## ---- 0. Paths to shared data (project-root-relative) ----
SHARED_DATA <- normalizePath(file.path(PROJECT_ROOT, "..", "..", "..", "data",
                                        "medicaid_provider_spending"),
                              mustWork = TRUE)
tmsis_path  <- file.path(SHARED_DATA, "tmsis.parquet")
nppes_path  <- file.path(SHARED_DATA, "nppes_extract.parquet")

stopifnot("T-MSIS Parquet not found" = file.exists(tmsis_path))
stopifnot("NPPES extract not found"  = file.exists(nppes_path))

## ---- 1. Open T-MSIS (lazy) ----
cat("Opening T-MSIS Parquet (lazy)...\n")
tmsis_ds <- open_dataset(tmsis_path)

## ---- 2. Load NPPES ----
cat("Loading NPPES extract...\n")
nppes <- as.data.table(read_parquet(nppes_path))
nppes[, npi := as.character(npi)]
npi_state <- nppes[!is.na(state) & state != "",
                   .(npi, state, entity_type, sole_prop, zip5)]
cat(sprintf("NPPES: %s providers with state\n", format(nrow(npi_state), big.mark = ",")))

## ---- 3. Build HCBS personal care panel (treatment-relevant codes) ----
## v2: Aggregate separately by HCPCS code so we can compute T1019 vs T1020 rates
cat("Aggregating T-MSIS for personal care codes (T1019, T1020, S5125, S5130)...\n")

pc_agg <- tmsis_ds |>
  filter(HCPCS_CODE %in% PC_CODES) |>
  group_by(BILLING_PROVIDER_NPI_NUM, CLAIM_FROM_MONTH, HCPCS_CODE) |>
  summarize(
    total_paid   = sum(TOTAL_PAID, na.rm = TRUE),
    total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    total_benes  = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect() |>
  as.data.table()

setnames(pc_agg, "BILLING_PROVIDER_NPI_NUM", "billing_npi")
setnames(pc_agg, "HCPCS_CODE", "hcpcs_code")

cat(sprintf("Personal care records: %s rows\n", format(nrow(pc_agg), big.mark = ",")))

## Join state from NPPES
pc_agg <- merge(pc_agg, npi_state[, .(npi, state, entity_type, sole_prop)],
                by.x = "billing_npi", by.y = "npi", all.x = TRUE)
pc_agg <- pc_agg[!is.na(state)]

## Parse dates
pc_agg[, month_date := as.Date(paste0(CLAIM_FROM_MONTH, "-01"))]
pc_agg[, year := year(month_date)]
pc_agg[, month_num := month(month_date)]

## ---- 4. Build state x month panel for personal care ----
cat("Building state x month panel...\n")

panel_pc <- pc_agg[, .(
  n_providers = uniqueN(billing_npi),
  total_paid  = sum(total_paid),
  total_claims = sum(total_claims),
  total_benes  = sum(total_benes),
  avg_paid_per_claim = sum(total_paid) / sum(total_claims),
  n_individual = uniqueN(billing_npi[entity_type == "1"]),
  n_org        = uniqueN(billing_npi[entity_type == "2"]),
  n_sole_prop  = uniqueN(billing_npi[sole_prop == "Y"]),
  ## v2: Code-specific rates for treatment detection refinement
  t1019_paid   = sum(total_paid[hcpcs_code == "T1019"]),
  t1019_claims = sum(total_claims[hcpcs_code == "T1019"]),
  t1020_paid   = sum(total_paid[hcpcs_code == "T1020"]),
  t1020_claims = sum(total_claims[hcpcs_code == "T1020"]),
  ## v2: Median payment per claim (alternative detection metric)
  median_paid_per_claim = median(total_paid / total_claims, na.rm = TRUE),
  ## v2: Intensive margin metrics
  claims_per_provider_raw = sum(total_claims) / uniqueN(billing_npi),
  ## v2: Type 2 billing share
  org_share = uniqueN(billing_npi[entity_type == "2"]) /
              max(uniqueN(billing_npi), 1)
), by = .(state, month_date, year, month_num)]

## v2: Compute T1019-specific rate (per 15 min) and T1020-specific rate (per diem)
panel_pc[, t1019_rate := ifelse(t1019_claims > 0, t1019_paid / t1019_claims, NA_real_)]
panel_pc[, t1020_rate := ifelse(t1020_claims > 0, t1020_paid / t1020_claims, NA_real_)]

setorder(panel_pc, state, month_date)
cat(sprintf("Personal care panel: %d rows, %d states, %d months\n",
            nrow(panel_pc), uniqueN(panel_pc$state), uniqueN(panel_pc$month_date)))

## ---- 5. Build placebo panel (E/M office visits) ----
cat("Aggregating T-MSIS for placebo codes (99213, 99214)...\n")

em_agg <- tmsis_ds |>
  filter(HCPCS_CODE %in% PLACEBO_CODES) |>
  group_by(BILLING_PROVIDER_NPI_NUM, CLAIM_FROM_MONTH) |>
  summarize(
    total_paid   = sum(TOTAL_PAID, na.rm = TRUE),
    total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    total_benes  = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect() |>
  as.data.table()

setnames(em_agg, "BILLING_PROVIDER_NPI_NUM", "billing_npi")

em_agg <- merge(em_agg, npi_state[, .(npi, state)],
                by.x = "billing_npi", by.y = "npi", all.x = TRUE)
em_agg <- em_agg[!is.na(state)]
em_agg[, month_date := as.Date(paste0(CLAIM_FROM_MONTH, "-01"))]

panel_em <- em_agg[, .(
  n_providers = uniqueN(billing_npi),
  total_paid  = sum(total_paid),
  total_claims = sum(total_claims),
  total_benes  = sum(total_benes),
  avg_paid_per_claim = sum(total_paid) / sum(total_claims)
), by = .(state, month_date)]

setorder(panel_em, state, month_date)
cat(sprintf("E/M placebo panel: %d rows, %d states\n",
            nrow(panel_em), uniqueN(panel_em$state)))

## ---- 6. Build all-HCBS panel (T + S + H codes) ----
cat("Aggregating T-MSIS for all HCBS codes (T/S/H prefixes)...\n")

hcbs_agg <- tmsis_ds |>
  mutate(prefix = substr(HCPCS_CODE, 1, 1)) |>
  filter(prefix %in% c("T", "S", "H")) |>
  group_by(BILLING_PROVIDER_NPI_NUM, CLAIM_FROM_MONTH) |>
  summarize(
    total_paid   = sum(TOTAL_PAID, na.rm = TRUE),
    total_claims = sum(TOTAL_CLAIMS, na.rm = TRUE),
    total_benes  = sum(TOTAL_UNIQUE_BENEFICIARIES, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect() |>
  as.data.table()

setnames(hcbs_agg, "BILLING_PROVIDER_NPI_NUM", "billing_npi")

hcbs_agg <- merge(hcbs_agg, npi_state[, .(npi, state, entity_type)],
                  by.x = "billing_npi", by.y = "npi", all.x = TRUE)
hcbs_agg <- hcbs_agg[!is.na(state)]
hcbs_agg[, month_date := as.Date(paste0(CLAIM_FROM_MONTH, "-01"))]

panel_hcbs <- hcbs_agg[, .(
  n_providers = uniqueN(billing_npi),
  total_paid  = sum(total_paid),
  total_claims = sum(total_claims),
  total_benes  = sum(total_benes),
  avg_paid_per_claim = sum(total_paid) / sum(total_claims)
), by = .(state, month_date)]

setorder(panel_hcbs, state, month_date)
cat(sprintf("All-HCBS panel: %d rows, %d states\n",
            nrow(panel_hcbs), uniqueN(panel_hcbs$state)))

## ---- 7. Save panels ----
saveRDS(panel_pc,   file.path(DATA, "panel_personal_care.rds"))
saveRDS(panel_em,   file.path(DATA, "panel_em_placebo.rds"))
saveRDS(panel_hcbs, file.path(DATA, "panel_hcbs_all.rds"))
saveRDS(pc_agg,     file.path(DATA, "pc_provider_level.rds"))

## Clean up
rm(pc_agg, em_agg, hcbs_agg)
gc()

cat("\n=== Data fetching complete ===\n")
cat(sprintf("Saved: panel_personal_care.rds (%d rows)\n", nrow(panel_pc)))
cat(sprintf("Saved: panel_em_placebo.rds (%d rows)\n", nrow(panel_em)))
cat(sprintf("Saved: panel_hcbs_all.rds (%d rows)\n", nrow(panel_hcbs)))
