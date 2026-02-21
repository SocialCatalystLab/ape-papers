## ────────────────────────────────────────────────────────────────────────────
## 02_clean_data.R — Construct analysis dataset
## Running variable: Census 2001 village population
## Outcomes: Worker classification by gender (2001, 2011), nightlights (annual)
## ────────────────────────────────────────────────────────────────────────────

source("00_packages.R")
load("../data/shrug_raw.RData")

# ── Special category states (PMGSY threshold = 250) ─────────────────────────
# Using Census 2011 state codes (2-digit)
special_states <- c(
  "01",  # Jammu & Kashmir
  "02",  # Himachal Pradesh
  "05",  # Uttarakhand
  "10",  # Tripura
  "11",  # Meghalaya
  "12",  # Manipur
  "13",  # Mizoram
  "14",  # Nagaland
  "15",  # Arunachal Pradesh
  "16",  # Sikkim
  "18"   # Assam
)

# ── Identify rural villages ─────────────────────────────────────────────────
rural_ids <- rural_key$shrid2
cat("Rural villages (Census 2001):", length(rural_ids), "\n")

# ── Merge Census data ───────────────────────────────────────────────────────
panel <- merge(pc01, pc11, by = "shrid2", suffixes = c("_01", "_11"))
panel <- merge(panel, dist_key, by = "shrid2")

# Restrict to rural villages
panel <- panel[shrid2 %in% rural_ids]
cat("Rural panel villages:", nrow(panel), "\n")

# ── Construct running variable ──────────────────────────────────────────────
panel[, pop2001 := pc01_pca_tot_p]
panel[, pop_centered := pop2001 - 500]

# Classify state type
panel[, special_state := pc11_state_id %in% special_states]
panel[, threshold := ifelse(special_state, 250, 500)]
panel[, pop_centered_local := pop2001 - threshold]
panel[, above_threshold := as.integer(pop2001 >= threshold)]

# ── Construct worker outcome variables ──────────────────────────────────────

# Census 2001 baseline
panel[, `:=`(
  # Total workers
  workers_01_p = pc01_pca_tot_work_p,
  workers_01_m = pc01_pca_tot_work_m,
  workers_01_f = pc01_pca_tot_work_f,
  # Main workers by type
  ag_01_f = pc01_pca_main_cl_f + pc01_pca_main_al_f,
  ag_01_m = pc01_pca_main_cl_m + pc01_pca_main_al_m,
  nonag_01_f = pc01_pca_main_hh_f + pc01_pca_main_ot_f,
  nonag_01_m = pc01_pca_main_hh_m + pc01_pca_main_ot_m
)]

# Census 2011 outcomes
panel[, `:=`(
  workers_11_p = pc11_pca_tot_work_p,
  workers_11_m = pc11_pca_tot_work_m,
  workers_11_f = pc11_pca_tot_work_f,
  ag_11_f = pc11_pca_main_cl_f + pc11_pca_main_al_f,
  ag_11_m = pc11_pca_main_cl_m + pc11_pca_main_al_m,
  nonag_11_f = pc11_pca_main_hh_f + pc11_pca_main_ot_f,
  nonag_11_m = pc11_pca_main_hh_m + pc11_pca_main_ot_m
)]

# Shares (conditional on having workers)
panel[workers_01_f > 0, nonag_share_01_f := nonag_01_f / workers_01_f]
panel[workers_01_m > 0, nonag_share_01_m := nonag_01_m / workers_01_m]
panel[workers_11_f > 0, nonag_share_11_f := nonag_11_f / workers_11_f]
panel[workers_11_m > 0, nonag_share_11_m := nonag_11_m / workers_11_m]

# Changes (primary outcomes)
panel[, d_nonag_share_f := nonag_share_11_f - nonag_share_01_f]
panel[, d_nonag_share_m := nonag_share_11_m - nonag_share_01_m]
panel[, d_nonag_share_gap := d_nonag_share_f - d_nonag_share_m]

# Total worker participation rates
panel[pc01_pca_tot_f > 0, wfpr_01_f := workers_01_f / pc01_pca_tot_f]
panel[pc01_pca_tot_m > 0, wfpr_01_m := workers_01_m / pc01_pca_tot_m]
panel[pc11_pca_tot_f > 0, wfpr_11_f := workers_11_f / pc11_pca_tot_f]
panel[pc11_pca_tot_m > 0, wfpr_11_m := workers_11_m / pc11_pca_tot_m]
panel[, d_wfpr_f := wfpr_11_f - wfpr_01_f]
panel[, d_wfpr_m := wfpr_11_m - wfpr_01_m]

# ── Baseline covariates ─────────────────────────────────────────────────────
panel[pc01_pca_tot_p > 0, `:=`(
  lit_rate_01 = pc01_pca_p_lit / pc01_pca_tot_p,
  sc_share_01 = pc01_pca_p_sc / pc01_pca_tot_p,
  st_share_01 = pc01_pca_p_st / pc01_pca_tot_p,
  female_share_01 = pc01_pca_tot_f / pc01_pca_tot_p
)]

# ── Build nightlights panel ────────────────────────────────────────────────
# DMSP: calibrated total light (1994-2013)
dmsp_panel <- dmsp[shrid2 %in% rural_ids,
                   .(shrid2, year = as.integer(year),
                     nl_dmsp = dmsp_total_light_cal)]

# VIIRS: annual sum (2012-2023)
viirs_panel <- viirs[shrid2 %in% rural_ids,
                     .(shrid2, year = as.integer(year),
                       nl_viirs = viirs_annual_sum)]

# Harmonize DMSP and VIIRS using 2012-2013 overlap
# Method: Use DMSP for 1994-2011, VIIRS for 2014-2023
# For 2012-2013: use DMSP (consistent with pre-period sensor)
nl_combined <- rbind(
  dmsp_panel[year <= 2013, .(shrid2, year, nl = nl_dmsp, sensor = "DMSP")],
  viirs_panel[year >= 2014, .(shrid2, year, nl = nl_viirs, sensor = "VIIRS")]
)

# Add running variable to nightlights panel
nl_combined <- merge(
  nl_combined,
  panel[, .(shrid2, pop2001, pop_centered, above_threshold, threshold,
            special_state, pc11_state_id, pc11_district_id)],
  by = "shrid2"
)

# Log transform (adding 0.01 to handle zeros)
nl_combined[, log_nl := log(nl + 0.01)]

# ── Summary statistics ──────────────────────────────────────────────────────
cat("\n=== Analysis Sample Summary ===\n")
cat("Total rural villages:", nrow(panel), "\n")
cat("  Plain-area states:", sum(!panel$special_state), "\n")
cat("  Special-category states:", sum(panel$special_state), "\n")

# Near threshold (±200 of 500)
near500 <- panel[!special_state & abs(pop_centered) <= 200]
cat("\nPlain states, within ±200 of 500:\n")
cat("  Villages:", nrow(near500), "\n")
cat("  Above threshold:", sum(near500$above_threshold == 1), "\n")
cat("  Below threshold:", sum(near500$above_threshold == 0), "\n")
cat("  Mean pop:", round(mean(near500$pop2001)), "\n")

cat("\nOutcome availability (plain states, ±200):\n")
cat("  d_nonag_share_f (non-missing):", sum(!is.na(near500$d_nonag_share_f)), "\n")
cat("  d_nonag_share_m (non-missing):", sum(!is.na(near500$d_nonag_share_m)), "\n")

# ── Save analysis datasets ──────────────────────────────────────────────────
save(panel, nl_combined, file = "../data/analysis_data.RData")

cat("\nAnalysis data saved to data/analysis_data.RData\n")
