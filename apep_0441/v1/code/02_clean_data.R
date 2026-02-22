## ============================================================================
## 02_clean_data.R — Construct analysis panel with treatment assignment
## Project: apep_0441 — State Bifurcation and Development in India
## ============================================================================

source("00_packages.R")
load("../data/raw_shrug.RData")

## ============================================================================
## 1. Define treatment: state bifurcation assignment
## ============================================================================

# Census 2011 state codes for our study
# New states (created Nov 2000):
#   05 = Uttarakhand (from 09 = Uttar Pradesh)
#   20 = Jharkhand (from 10 = Bihar)
#   22 = Chhattisgarh (from 23 = Madhya Pradesh)
# New state (created June 2014):
#   36 = Telangana (from 28 = Andhra Pradesh)
# Note: Telangana has state code 36 in post-2014 data, but in Census 2011
# it was part of AP (28). We need to identify Telangana districts within AP.

# Telangana districts (Census 2011 district IDs within state 28):
# In SHRUG, AP district IDs run 532-554. Telangana = first 10 (532-541):
# Adilabad=532, Nizamabad=533, Karimnagar=534, Medak=535, Hyderabad=536,
# Rangareddi=537, Mahbubnagar=538, Nalgonda=539, Warangal=540, Khammam=541
telangana_districts <- 532:541

# State pairs: new_state_code -> parent_state_code
state_pairs <- list(
  list(new = "05", parent = "09", name_new = "Uttarakhand", name_parent = "Uttar Pradesh",
       year = 2001),  # First full year after Nov 2000
  list(new = "20", parent = "10", name_new = "Jharkhand", name_parent = "Bihar",
       year = 2001),
  list(new = "22", parent = "23", name_new = "Chhattisgarh", name_parent = "Madhya Pradesh",
       year = 2001),
  # Telangana: within Census 2011 state 28 (AP), specific districts
  list(new = "28_TG", parent = "28_AP", name_new = "Telangana", name_parent = "Andhra Pradesh",
       year = 2015)  # First full year after June 2014
)

## ============================================================================
## 2. Assign treatment status to districts
## ============================================================================

# Create district-level treatment assignment
districts <- td[, .(pc11_state_id, pc11_district_id, pc11_tot_p)]

# For the 2000 cohort: state code directly identifies treatment (integer comparison)
districts[, new_state_2000 := fifelse(
  pc11_state_id %in% c(5L, 20L, 22L), 1L, 0L
)]
districts[, parent_state_2000 := fifelse(
  pc11_state_id %in% c(9L, 10L, 23L), 1L, 0L
)]

# For Telangana: district code within AP identifies treatment
districts[, new_state_2014 := fifelse(
  pc11_state_id == 28L & pc11_district_id %in% telangana_districts, 1L, 0L
)]
districts[, parent_state_2014 := fifelse(
  pc11_state_id == 28L & !(pc11_district_id %in% telangana_districts), 1L, 0L
)]

# Combined treatment indicator
districts[, treated := fifelse(new_state_2000 == 1L | new_state_2014 == 1L, 1L, 0L)]
districts[, in_sample := fifelse(
  new_state_2000 == 1L | parent_state_2000 == 1L |
  new_state_2014 == 1L | parent_state_2014 == 1L, 1L, 0L
)]

# First treatment year (for CS-DiD gname)
districts[, first_treat := fifelse(new_state_2000 == 1L, 2001L,
                           fifelse(new_state_2014 == 1L, 2015L, 0L))]

# State pair identifier (for within-pair analysis)
districts[, state_pair := fifelse(
  pc11_state_id %in% c(5L, 9L), "UK-UP",
  fifelse(pc11_state_id %in% c(20L, 10L), "JH-BR",
  fifelse(pc11_state_id %in% c(22L, 23L), "CG-MP",
  fifelse(pc11_state_id == 28L, "TG-AP", "other"))))]

# State-level cluster ID for robust inference (character for flexibility)
districts[, cluster_state := as.character(pc11_state_id)]
# For Telangana, split AP into TG and AP clusters
districts[new_state_2014 == 1L, cluster_state := "36"]  # Telangana
districts[parent_state_2014 == 1L, cluster_state := "28"]  # Residual AP

# Summary
cat("Treatment assignment:\n")
cat("  2000 cohort — New state districts:", sum(districts$new_state_2000), "\n")
cat("  2000 cohort — Parent state districts:", sum(districts$parent_state_2000), "\n")
cat("  2014 cohort — Telangana districts:", sum(districts$new_state_2014), "\n")
cat("  2014 cohort — Residual AP districts:", sum(districts$parent_state_2014), "\n")
cat("  Total in sample:", sum(districts$in_sample), "\n")

## ============================================================================
## 3. Build nightlights panel
## ============================================================================

# Create unique district ID
dmsp[, dist_id := paste0(pc11_state_id, "_", pc11_district_id)]
viirs[, dist_id := paste0(pc11_state_id, "_", pc11_district_id)]
districts[, dist_id := paste0(pc11_state_id, "_", pc11_district_id)]

# DMSP panel: aggregate to district-year level (multiple satellite observations)
dmsp_panel <- dmsp[, .(nl_dmsp = mean(dmsp_total_light_cal, na.rm = TRUE),
                        nl_dmsp_mean = mean(dmsp_mean_light_cal, na.rm = TRUE)),
                    by = .(dist_id, year)]

# VIIRS panel: aggregate to district-year level
viirs_panel <- viirs[, .(nl_viirs = mean(viirs_annual_sum, na.rm = TRUE),
                          nl_viirs_mean = mean(viirs_annual_mean, na.rm = TRUE)),
                      by = .(dist_id, year)]

# Calibrate DMSP and VIIRS at overlap years (2012-2013)
# For each district, compute ratio of VIIRS/DMSP at overlap
overlap <- merge(
  dmsp_panel[year %in% 2012:2013, .(dmsp_avg = mean(nl_dmsp, na.rm = TRUE)), by = dist_id],
  viirs_panel[year %in% 2012:2013, .(viirs_avg = mean(nl_viirs, na.rm = TRUE)), by = dist_id],
  by = "dist_id"
)
overlap[, calib_ratio := fifelse(dmsp_avg > 0, viirs_avg / dmsp_avg, NA_real_)]

# Create unified nightlights panel
# DMSP for 1994-2013, VIIRS for 2014-2023
# Calibrate DMSP to VIIRS scale using overlap ratio
nl_panel <- rbind(
  merge(dmsp_panel[year <= 2013], overlap[, .(dist_id, calib_ratio)], by = "dist_id")[
    , .(dist_id, year, nightlights = nl_dmsp * calib_ratio)],
  viirs_panel[year >= 2014, .(dist_id, year, nightlights = nl_viirs)]
)

# Also keep DMSP-only panel (no calibration issues) for main analysis
dmsp_only <- dmsp_panel[, .(dist_id, year, nightlights = nl_dmsp)]

cat("Nightlights panel:\n")
cat("  Calibrated panel:", nrow(nl_panel), "obs |",
    length(unique(nl_panel$dist_id)), "districts |",
    paste(range(nl_panel$year), collapse = "-"), "\n")
cat("  DMSP-only panel:", nrow(dmsp_only), "obs |",
    paste(range(dmsp_only$year), collapse = "-"), "\n")

## ============================================================================
## 4. Merge treatment assignment with nightlights
## ============================================================================

# Main analysis panel (DMSP only, 1994-2013)
panel_dmsp <- merge(dmsp_only, districts[in_sample == 1L],
                     by = "dist_id", all.x = FALSE)

# Extended panel (calibrated, 1994-2023)
panel_full <- merge(nl_panel, districts[in_sample == 1L],
                     by = "dist_id", all.x = FALSE)

# Create analysis variables
for (p in list(panel_dmsp, panel_full)) {
  p[, log_nl := log(nightlights + 1)]
  p[, post_2000 := fifelse(year >= 2001, 1L, 0L)]
  p[, post_2014 := fifelse(year >= 2015, 1L, 0L)]
  p[, treat_post := treated * post_2000]
  # Numeric district ID for fixest
  p[, did := as.integer(factor(dist_id))]
}

cat("Analysis panels:\n")
cat("  DMSP panel:", nrow(panel_dmsp), "obs |",
    length(unique(panel_dmsp$dist_id)), "districts\n")
cat("  Full panel:", nrow(panel_full), "obs |",
    length(unique(panel_full$dist_id)), "districts\n")

## ============================================================================
## 5. Construct Census cross-sections for mechanism analysis
## ============================================================================

# Census 2011 variables at district level
census11 <- pca11[, .(
  pc11_state_id = as.character(pc11_state_id),
  pc11_district_id = pc11_district_id,
  pop_2011 = pc11_pca_tot_p,
  lit_rate_2011 = pc11_pca_p_lit / pc11_pca_tot_p,
  worker_rate_2011 = pc11_pca_tot_work_p / pc11_pca_tot_p,
  ag_worker_share_2011 = (pc11_pca_main_cl_p + pc11_pca_main_al_p) / pc11_pca_tot_work_p,
  nonag_worker_share_2011 = (pc11_pca_main_hh_p + pc11_pca_main_ot_p) / pc11_pca_tot_work_p,
  sc_share_2011 = pc11_pca_p_sc / pc11_pca_tot_p,
  st_share_2011 = pc11_pca_p_st / pc11_pca_tot_p
)]
census11[, dist_id := paste0(pc11_state_id, "_", pc11_district_id)]

# Census 2001 variables (use pc01 district codes — need mapping)
# Note: SHRUG harmonizes boundaries, but we access via state-level aggregation
# For now, use Census 2011 as the primary cross-section

# Merge census characteristics into panel
panel_dmsp <- merge(panel_dmsp, census11[, .(dist_id, pop_2011, lit_rate_2011,
  worker_rate_2011, ag_worker_share_2011, sc_share_2011, st_share_2011)],
  by = "dist_id", all.x = TRUE)

panel_full <- merge(panel_full, census11[, .(dist_id, pop_2011, lit_rate_2011,
  worker_rate_2011, ag_worker_share_2011, sc_share_2011, st_share_2011)],
  by = "dist_id", all.x = TRUE)

## ============================================================================
## 6. Capital city indicators
## ============================================================================

# New state capital districts (Census 2011 codes, integer format)
# Dehradun = largest district in UK (60), Ranchi = largest in JH (354),
# Raipur = largest in CG (410)
capital_districts <- data.table(
  dist_id = c(
    "5_60",    # Dehradun (Uttarakhand capital)
    "20_354",  # Ranchi (Jharkhand capital)
    "22_410"   # Raipur (Chhattisgarh capital)
  ),
  is_capital = 1L
)

panel_dmsp <- merge(panel_dmsp, capital_districts, by = "dist_id", all.x = TRUE)
panel_dmsp[is.na(is_capital), is_capital := 0L]

panel_full <- merge(panel_full, capital_districts, by = "dist_id", all.x = TRUE)
panel_full[is.na(is_capital), is_capital := 0L]

## ============================================================================
## 7. Save analysis-ready data
## ============================================================================

save(panel_dmsp, panel_full, districts, census11,
     file = "../data/analysis_panel.RData")

cat("\n=== Data construction complete ===\n")
cat("DMSP panel: ", nrow(panel_dmsp), " district-years\n")
cat("Full panel: ", nrow(panel_full), " district-years\n")
cat("Saved to data/analysis_panel.RData\n")
