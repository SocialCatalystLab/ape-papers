## ============================================================================
## 02_clean_data.R — Merge treatment assignment, create analysis variables
## Paper: Medicaid Postpartum Coverage Extensions and Provider Supply
## ============================================================================

source("00_packages.R")

DATA <- "../data"

## ---- 1. Load data ----
panel_maternal <- readRDS(file.path(DATA, "panel_maternal.rds"))
panel_obgyn    <- readRDS(file.path(DATA, "panel_obgyn.rds"))
state_pop      <- readRDS(file.path(DATA, "state_pop.rds"))

## ---- 2. Treatment assignment: postpartum extension adoption dates ----
# Source: KFF Medicaid Postpartum Coverage Extension Tracker, CMS SPA approvals,
# state executive orders, and legislative records.
# Effective dates (not announcement dates)

treatment_dates <- data.table(
  state = c(
    # Pre-ARP waiver states (2021)
    "NJ", "VA",
    # Wave 1: April 1, 2022 (first available SPA date)
    "CA", "CT", "DC", "HI", "IN", "KS", "KY", "LA", "MD",
    "MA", "MI", "NM", "NC", "OH", "OR", "PA", "SC", "TN", "WA", "WV",
    # Wave 2: mid-to-late 2022
    "FL", "CO", "IL", "MN", "DE", "ME", "AL", "RI", "GA",
    # Wave 3: 2023
    "ND", "OK", "NY", "AZ", "MS", "VT", "MO", "WY", "NH", "MT", "SD",
    # Wave 4: 2024
    "NE", "NV", "UT", "AK", "TX",
    # Wave 5: 2025 (outside data window — treated as never-treated in estimation)
    "ID", "IA"
  ),
  treat_date = as.Date(c(
    # Pre-ARP waivers
    "2021-10-01", "2021-11-01",
    # Wave 1: April 2022
    rep("2022-04-01", 20),
    # Wave 2
    "2022-06-01", "2022-07-01", "2022-07-01", "2022-07-01", "2022-07-01",
    "2022-08-01", "2022-10-01", "2022-10-01", "2022-11-01",
    # Wave 3
    "2023-01-01", "2023-01-01", "2023-03-01", "2023-04-01", "2023-04-01",
    "2023-04-01", "2023-07-01", "2023-07-01", "2023-10-01", "2023-10-01", "2023-10-01",
    # Wave 4
    "2024-01-01", "2024-01-01", "2024-01-01", "2024-02-01", "2024-03-01",
    # Wave 5 (post-data window)
    "2025-01-01", "2025-04-01"
  ))
)

# States that NEVER adopted (as of data end Dec 2024)
never_treated <- c("AR", "WI")
# States adopting after data window also treated as never-treated for estimation
never_treated_in_data <- c(never_treated, "ID", "IA")

## ---- 3. Create treatment variables ----
# Merge treatment dates into panels
panel_maternal <- merge(panel_maternal, treatment_dates, by = "state", all.x = TRUE)
panel_obgyn    <- merge(panel_obgyn,    treatment_dates, by = "state", all.x = TRUE)

# Binary treatment indicator
panel_maternal[, treated := fifelse(!is.na(treat_date) & month_date >= treat_date, 1L, 0L)]
panel_obgyn[, treated := fifelse(!is.na(treat_date) & month_date >= treat_date, 1L, 0L)]

# Treatment cohort (year-month of adoption) for CS-DiD
# Convert to integer time period: months since Jan 2018
ref_date <- as.Date("2018-01-01")
panel_maternal[, time_period := as.integer(difftime(month_date, ref_date, units = "days")) %/% 30]
panel_maternal[, cohort := fifelse(
  !is.na(treat_date) & !(state %in% never_treated_in_data),
  as.integer(difftime(treat_date, ref_date, units = "days")) %/% 30,
  0L  # Never-treated coded as 0 for did package
)]

panel_obgyn[, time_period := as.integer(difftime(month_date, ref_date, units = "days")) %/% 30]
panel_obgyn[, cohort := fifelse(
  !is.na(treat_date) & !(state %in% never_treated_in_data),
  as.integer(difftime(treat_date, ref_date, units = "days")) %/% 30,
  0L
)]

## ---- 4. PHE indicator ----
# Public Health Emergency: January 2020 – March 2023
# During this period, continuous enrollment effectively extended postpartum coverage
phe_start <- as.Date("2020-01-01")
phe_end   <- as.Date("2023-03-31")

panel_maternal[, phe := fifelse(month_date >= phe_start & month_date <= phe_end, 1L, 0L)]
panel_obgyn[, phe := fifelse(month_date >= phe_start & month_date <= phe_end, 1L, 0L)]

# Post-PHE indicator (April 2023+)
panel_maternal[, post_phe := fifelse(month_date > phe_end, 1L, 0L)]
panel_obgyn[, post_phe := fifelse(month_date > phe_end, 1L, 0L)]

## ---- 5. Merge population denominators ----
panel_maternal <- merge(panel_maternal, state_pop[, .(state, year, population)],
                         by = c("state", "year"), all.x = TRUE)
panel_obgyn    <- merge(panel_obgyn, state_pop[, .(state, year, population)],
                         by = c("state", "year"), all.x = TRUE)

# Per-capita normalization (per 100,000 population)
panel_maternal[, claims_pc := claims / population * 100000]
panel_maternal[, paid_pc := paid / population * 100000]
panel_maternal[, providers_pc := n_providers / population * 100000]

panel_obgyn[, total_claims_pc := total_claims / population * 100000]
panel_obgyn[, n_obgyn_pc := n_obgyn_billing / population * 100000]

## ---- 6. State numeric ID for fixest ----
panel_maternal[, state_id := as.integer(as.factor(state))]
panel_obgyn[, state_id := as.integer(as.factor(state))]

## ---- 7. Create BALANCED wide outcome panels for main DiD ----
# CRITICAL: The `did` package requires a balanced panel.
# Create a complete state × month grid, then fill missing cells with 0.

# First, get all valid states and all months
valid_states_pre <- c(state.abb, "DC")
all_months <- sort(unique(c(panel_maternal$month_date, panel_obgyn$month_date)))
all_months <- all_months[!is.na(all_months)]

# Create complete grid
grid <- CJ(state = valid_states_pre, month_date = all_months)
grid[, year := year(month_date)]
grid[, month_num := month(month_date)]

# Pivot maternal panel to wide by category (fill = 0)
maternal_wide <- dcast(panel_maternal[state %in% valid_states_pre],
  state + month_date ~
    code_category,
  value.var = c("claims", "paid", "n_providers", "beneficiaries"),
  fill = 0)

# Merge grid with maternal wide data
panel_wide <- merge(grid, maternal_wide, by = c("state", "month_date"), all.x = TRUE)

# Merge OB/GYN extensive margin
panel_wide <- merge(panel_wide, panel_obgyn[state %in% valid_states_pre, .(state, month_date, n_obgyn_billing)],
                     by = c("state", "month_date"), all.x = TRUE)

# Fill all NAs with 0 for outcome columns
outcome_cols <- names(panel_wide)[grepl("^(claims_|paid_|n_providers_|beneficiaries_|n_obgyn)", names(panel_wide))]
for (col in outcome_cols) {
  panel_wide[is.na(get(col)), (col) := 0]
}

# Now add treatment variables
panel_wide <- merge(panel_wide, treatment_dates, by = "state", all.x = TRUE)
panel_wide[, treated := fifelse(!is.na(treat_date) & month_date >= treat_date, 1L, 0L)]

ref_date <- as.Date("2018-01-01")
panel_wide[, time_period := as.integer(difftime(month_date, ref_date, units = "days")) %/% 30]
panel_wide[, cohort := fifelse(
  !is.na(treat_date) & !(state %in% never_treated_in_data),
  as.integer(difftime(treat_date, ref_date, units = "days")) %/% 30,
  0L
)]

panel_wide[, phe := fifelse(month_date >= phe_start & month_date <= phe_end, 1L, 0L)]
panel_wide[, post_phe := fifelse(month_date > phe_end, 1L, 0L)]

# Population
panel_wide <- merge(panel_wide, state_pop[, .(state, year, population)],
                     by = c("state", "year"), all.x = TRUE)

# Per-capita (claims_pc, providers_pc)
if ("claims_postpartum" %in% names(panel_wide)) {
  panel_wide[!is.na(population) & population > 0, claims_pc_postpartum := claims_postpartum / population * 100000]
  panel_wide[!is.na(population) & population > 0, providers_pc_postpartum := n_providers_postpartum / population * 100000]
  panel_wide[!is.na(population) & population > 0, n_obgyn_pc := n_obgyn_billing / population * 100000]
}

# State numeric ID
panel_wide[, state_id := as.integer(as.factor(state))]

## ---- 8. (Balanced panel already restricted to 50 states + DC) ----

## ---- 9. Data quality check ----
cat("\n=== Data Quality Summary ===\n")
cat(sprintf("States in panel: %d\n", uniqueN(panel_wide$state)))
cat(sprintf("Months in panel: %d\n", uniqueN(panel_wide$month_date)))
cat(sprintf("Total rows (state × month): %d\n", nrow(panel_wide)))
cat(sprintf("Treated states (in data window): %d\n",
            uniqueN(panel_wide[cohort > 0, state])))
cat(sprintf("Never-treated states: %d\n",
            uniqueN(panel_wide[cohort == 0, state])))

# Check for state-months with zero claims
zero_months <- panel_wide[claims_postpartum + claims_antepartum + claims_delivery == 0]
cat(sprintf("State-months with zero maternal claims: %d (%.1f%%)\n",
            nrow(zero_months), 100 * nrow(zero_months) / nrow(panel_wide)))

## ---- 10. Log transform for percentage interpretation ----
# Check which columns exist and create log versions
if ("claims_postpartum" %in% names(panel_wide)) {
  panel_wide[, ln_claims_pp := log(claims_postpartum + 1)]
} else {
  panel_wide[, ln_claims_pp := 0]
}
if ("claims_antepartum" %in% names(panel_wide)) {
  panel_wide[, ln_claims_ante := log(claims_antepartum + 1)]
} else {
  panel_wide[, ln_claims_ante := 0]
}
if ("claims_contraceptive" %in% names(panel_wide)) {
  panel_wide[, ln_claims_contra := log(claims_contraceptive + 1)]
} else {
  panel_wide[, ln_claims_contra := 0]
}
if ("claims_delivery" %in% names(panel_wide)) {
  panel_wide[, ln_claims_delivery := log(claims_delivery + 1)]
} else {
  panel_wide[, ln_claims_delivery := 0]
}
if ("n_providers_postpartum" %in% names(panel_wide)) {
  panel_wide[, ln_n_providers_pp := log(n_providers_postpartum + 1)]
} else {
  panel_wide[, ln_n_providers_pp := 0]
}
panel_wide[, ln_n_obgyn := log(n_obgyn_billing + 1)]

## ---- 11. Save ----
saveRDS(panel_wide, file.path(DATA, "panel_analysis.rds"))
saveRDS(treatment_dates, file.path(DATA, "treatment_dates.rds"))

cat("\n=== Cleaning complete ===\n")
cat(sprintf("Analysis panel: %d rows (state × month)\n", nrow(panel_wide)))
cat(sprintf("  Treated obs (post-treatment): %d\n", sum(panel_wide$treated)))
cat(sprintf("  Control obs: %d\n", sum(1 - panel_wide$treated)))
