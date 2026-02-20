## ── 01_fetch_data.R ───────────────────────────────────────────────────────
## Fetch all data for apep_0426: MGNREGA and Structural Transformation
##
## Data sources (all local SHRUG files):
##   1. SHRUG nightlights (DMSP 1994-2013 + VIIRS 2014-2023)
##   2. SHRUG Census PCA 2001 and 2011
##   3. SHRUG Census PCA 1991
##   4. SHRUG district crosswalk
##   5. MGNREGA phase assignment (constructed from Census 2001 backwardness)
## ──────────────────────────────────────────────────────────────────────────

source("00_packages.R")

data_dir <- "../data"
shrug_dir <- Sys.getenv("SHRUG_DIR", file.path(data_dir, "..", "..", "..", "..", "data", "india_shrug"))

## ══════════════════════════════════════════════════════════════════════════
## 1. SHRUG District Crosswalk
## ══════════════════════════════════════════════════════════════════════════
cat("Loading SHRUG district crosswalk...\n")
dist_key <- fread(file.path(shrug_dir, "shrid_pc11dist_key.csv"))
dist_key[, dist_code := paste0(pc11_state_id, pc11_district_id)]
districts <- unique(dist_key[, .(dist_code, pc11_state_id, pc11_district_id)])
cat(sprintf("  %d unique districts\n", nrow(districts)))

## ══════════════════════════════════════════════════════════════════════════
## 2. SHRUG Census 2001 PCA (for backwardness index + baseline controls)
## ══════════════════════════════════════════════════════════════════════════
cat("Loading Census 2001 PCA...\n")
pca01 <- fread(file.path(shrug_dir, "pc01_pca_clean_shrid.csv"))
pca01 <- merge(pca01, dist_key[, .(shrid2, dist_code)], by = "shrid2")

dist_01 <- pca01[, .(
  pop_2001       = sum(pc01_pca_tot_p, na.rm = TRUE),
  sc_pop_2001    = sum(pc01_pca_p_sc, na.rm = TRUE),
  st_pop_2001    = sum(pc01_pca_p_st, na.rm = TRUE),
  literate_2001  = sum(pc01_pca_p_lit, na.rm = TRUE),
  workers_2001   = sum(pc01_pca_tot_work_p, na.rm = TRUE),
  main_workers_2001 = sum(pc01_pca_mainwork_p, na.rm = TRUE),
  cultivators_2001  = sum(pc01_pca_main_cl_p, na.rm = TRUE),
  agri_labor_2001   = sum(pc01_pca_main_al_p, na.rm = TRUE),
  hh_industry_2001  = sum(pc01_pca_main_hh_p, na.rm = TRUE),
  other_workers_2001 = sum(pc01_pca_main_ot_p, na.rm = TRUE),
  n_villages_01   = .N
), by = dist_code]

## Construct rates
dist_01[pop_2001 > 0, `:=`(
  sc_st_share = (sc_pop_2001 + st_pop_2001) / pop_2001,
  lit_rate    = literate_2001 / pop_2001,
  agri_labor_share = agri_labor_2001 / pmax(main_workers_2001, 1),
  cultivator_share = cultivators_2001 / pmax(main_workers_2001, 1),
  hh_industry_share = hh_industry_2001 / pmax(main_workers_2001, 1),
  other_worker_share = other_workers_2001 / pmax(main_workers_2001, 1)
)]

## ══════════════════════════════════════════════════════════════════════════
## 3. SHRUG Census 2011 PCA (post-treatment outcomes)
## ══════════════════════════════════════════════════════════════════════════
cat("Loading Census 2011 PCA...\n")
pca11 <- fread(file.path(shrug_dir, "pc11_pca_clean_shrid.csv"))
pca11 <- merge(pca11, dist_key[, .(shrid2, dist_code)], by = "shrid2")

dist_11 <- pca11[, .(
  pop_2011        = sum(pc11_pca_tot_p, na.rm = TRUE),
  sc_pop_2011     = sum(pc11_pca_p_sc, na.rm = TRUE),
  st_pop_2011     = sum(pc11_pca_p_st, na.rm = TRUE),
  literate_2011   = sum(pc11_pca_p_lit, na.rm = TRUE),
  workers_2011    = sum(pc11_pca_tot_work_p, na.rm = TRUE),
  main_workers_2011  = sum(pc11_pca_mainwork_p, na.rm = TRUE),
  cultivators_2011   = sum(pc11_pca_main_cl_p, na.rm = TRUE),
  agri_labor_2011    = sum(pc11_pca_main_al_p, na.rm = TRUE),
  hh_industry_2011   = sum(pc11_pca_main_hh_p, na.rm = TRUE),
  other_workers_2011 = sum(pc11_pca_main_ot_p, na.rm = TRUE),
  n_villages_11   = .N
), by = dist_code]

dist_11[pop_2011 > 0, `:=`(
  lit_rate_11       = literate_2011 / pop_2011,
  agri_labor_share_11 = agri_labor_2011 / pmax(main_workers_2011, 1),
  cultivator_share_11 = cultivators_2011 / pmax(main_workers_2011, 1),
  nonfarm_share_11    = (hh_industry_2011 + other_workers_2011) / pmax(main_workers_2011, 1)
)]

## ══════════════════════════════════════════════════════════════════════════
## 4. Census 1991 PCA (deep pre-treatment baseline)
## ══════════════════════════════════════════════════════════════════════════
cat("Loading Census 1991 PCA...\n")
pca91 <- fread(file.path(shrug_dir, "pc91_pca_clean_shrid.csv"))
pca91 <- merge(pca91, dist_key[, .(shrid2, dist_code)], by = "shrid2")

dist_91 <- pca91[, .(
  pop_1991     = sum(pc91_pca_tot_p, na.rm = TRUE),
  literate_1991 = sum(pc91_pca_p_lit, na.rm = TRUE),
  workers_1991  = sum(pc91_pca_mainwork_p + pc91_pca_margwork_p, na.rm = TRUE),
  n_villages_91 = .N
), by = dist_code]

dist_91[pop_1991 > 0, lit_rate_91 := literate_1991 / pop_1991]

## ══════════════════════════════════════════════════════════════════════════
## 5. Nightlights Panel (District-Year)
## ══════════════════════════════════════════════════════════════════════════
cat("Building nightlights panel...\n")

## DMSP (1994-2013)
dmsp <- fread(file.path(shrug_dir, "dmsp_shrid.csv"))
dmsp <- merge(dmsp, dist_key[, .(shrid2, dist_code)], by = "shrid2")
dist_nl_dmsp <- dmsp[, .(
  total_light = sum(dmsp_total_light_cal, na.rm = TRUE),
  mean_light  = mean(dmsp_mean_light_cal, na.rm = TRUE),
  n_cells     = sum(dmsp_num_cells, na.rm = TRUE)
), by = .(dist_code, year)]

## VIIRS (2012-2023)
viirs <- fread(file.path(shrug_dir, "viirs_annual_shrid.csv"))
viirs <- merge(viirs, dist_key[, .(shrid2, dist_code)], by = "shrid2")
dist_nl_viirs <- viirs[, .(
  total_light = sum(viirs_annual_sum, na.rm = TRUE),
  mean_light  = mean(viirs_annual_mean, na.rm = TRUE),
  n_cells     = sum(viirs_annual_num_cells, na.rm = TRUE)
), by = .(dist_code, year)]

## Combine: DMSP through 2013, VIIRS from 2014
## Calibrate at 2013 overlap
dmsp_2013 <- dist_nl_dmsp[year == 2013, .(dist_code, dmsp_light = total_light)]
viirs_2013 <- dist_nl_viirs[year == 2013, .(dist_code, viirs_light = total_light)]
calib <- merge(dmsp_2013, viirs_2013, by = "dist_code")
scale_factor <- calib[viirs_light > 0, median(dmsp_light / viirs_light, na.rm = TRUE)]
cat(sprintf("  DMSP/VIIRS calibration factor (median at 2013): %.4f\n", scale_factor))

dist_nl <- rbind(
  dist_nl_dmsp[year <= 2013],
  dist_nl_viirs[year >= 2014]
)
dist_nl[year >= 2014, `:=`(
  total_light = total_light * scale_factor,
  mean_light  = mean_light * scale_factor
)]
dist_nl[, log_light := log(total_light + 1)]

cat(sprintf("  Nightlights panel: %d district-years, %d districts, years %d-%d\n",
            nrow(dist_nl), uniqueN(dist_nl$dist_code),
            min(dist_nl$year), max(dist_nl$year)))

## ══════════════════════════════════════════════════════════════════════════
## 6. MGNREGA Phase Assignment (from Census 2001 Backwardness Index)
## ══════════════════════════════════════════════════════════════════════════
##
## The Planning Commission's Inter-Ministerial Task Group ranked districts
## using a composite backwardness index based on:
##   (a) SC/ST population share
##   (b) Inverse of agricultural wages (proxied by agricultural labor share)
##   (c) Inverse of agricultural output per worker (proxied inversely)
##
## Phase I (Feb 2006): 200 most backward districts
## Phase II (Apr 2007): next 130 districts
## Phase III (Apr 2008): all remaining ~310 districts
##
## We construct the index from Census 2001 variables. Following Imbert &
## Papp (2015) and the existing literature, the key predictors of phase
## assignment are SC/ST share, agricultural labor share, and inverse
## literacy rate.
## ══════════════════════════════════════════════════════════════════════════

cat("Constructing MGNREGA phase assignment...\n")

## Standardize backwardness components (higher = more backward)
dist_01[, `:=`(
  z_scst    = scale(sc_st_share),
  z_aglab   = scale(agri_labor_share),
  z_invlit  = scale(1 - lit_rate)
)]

## Composite backwardness index (equal weights)
dist_01[, backwardness := (z_scst + z_aglab + z_invlit) / 3]

## Rank districts
dist_01[, backward_rank := frank(-backwardness, ties.method = "first")]

## Assign phases
dist_01[, nrega_phase := fifelse(
  backward_rank <= 200, 1L,
  fifelse(backward_rank <= 330, 2L, 3L)
)]

## Treatment year based on phase
dist_01[, treat_year := fifelse(
  nrega_phase == 1L, 2006L,
  fifelse(nrega_phase == 2L, 2007L, 2008L)
)]

cat("Phase assignment distribution:\n")
print(dist_01[, .N, by = nrega_phase][order(nrega_phase)])

## Validate: Check top states in Phase I
## Add state code from dist_code (first 2 characters)
dist_01[, state_code := substr(dist_code, 1, 2)]
phase1_states <- dist_01[nrega_phase == 1, .N, by = state_code][order(-N)]
cat("\nTop states in Phase I (should be Bihar, Jharkhand, MP, Chhattisgarh, Odisha):\n")
print(head(phase1_states, 10))

## State code mapping (Census 2011 codes)
## 10 = Bihar, 20 = Jharkhand, 22 = Chhattisgarh, 23 = Madhya Pradesh, 21 = Odisha
## 08 = Rajasthan, 09 = Uttar Pradesh, 28 = Andhra Pradesh, 19 = West Bengal

## ══════════════════════════════════════════════════════════════════════════
## 7. Build Analysis Panel
## ══════════════════════════════════════════════════════════════════════════

cat("Building analysis panel...\n")

## Merge nightlights with phase assignment and controls
panel <- merge(dist_nl, dist_01[, .(dist_code, nrega_phase, treat_year,
                                     backwardness, backward_rank,
                                     pop_2001, sc_st_share, lit_rate,
                                     agri_labor_share, cultivator_share)],
               by = "dist_code", all.x = TRUE)

## Drop districts without Census 2001 data
panel <- panel[!is.na(nrega_phase)]

## Treatment indicator
panel[, treated := as.integer(year >= treat_year)]

## Event time (years relative to treatment)
panel[, event_time := year - treat_year]

## For CS-DiD: cohort variable (treat_year for treated, 0 for never-treated)
## Since all districts are eventually treated (by 2008), we use not-yet-treated
## For the did package: gname = first treatment period
panel[, cohort := treat_year]

## State code (for clustering)
panel[, state_code := substr(dist_code, 1, 2)]

## Log population baseline
panel[, log_pop_2001 := log(pop_2001 + 1)]

## Merge 2011 Census for cross-sectional structural transformation analysis
panel_cross <- merge(dist_01, dist_11, by = "dist_code", all.x = TRUE)

cat(sprintf("  Analysis panel: %d observations, %d districts, %d years\n",
            nrow(panel), uniqueN(panel$dist_code), uniqueN(panel$year)))

## ══════════════════════════════════════════════════════════════════════════
## 8. Save
## ══════════════════════════════════════════════════════════════════════════

fwrite(panel, file.path(data_dir, "analysis_panel.csv"))
fwrite(dist_01, file.path(data_dir, "district_census_2001.csv"))
fwrite(dist_11, file.path(data_dir, "district_census_2011.csv"))
fwrite(dist_91, file.path(data_dir, "district_census_1991.csv"))
fwrite(dist_nl, file.path(data_dir, "district_nightlights.csv"))
fwrite(panel_cross, file.path(data_dir, "district_cross_section.csv"))

cat("\n✓ All data saved to:", normalizePath(data_dir), "\n")
