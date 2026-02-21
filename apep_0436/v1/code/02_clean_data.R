## ============================================================
## 02_clean_data.R — Construct analysis panels
## MGNREGA and Structural Transformation
## ============================================================

source("00_packages.R")

data_dir  <- file.path("..", "data")

# ── 1. Load data ─────────────────────────────────────────────
phase <- fread(file.path(data_dir, "district_mgnrega_phase.csv"))
d91   <- fread(file.path(data_dir, "district_census_1991.csv"))
d01   <- fread(file.path(data_dir, "district_census_2001.csv"))
d11   <- fread(file.path(data_dir, "district_census_2011.csv"))
dmsp  <- fread(file.path(data_dir, "nightlights_dmsp_district.csv"))
viirs <- fread(file.path(data_dir, "nightlights_viirs_district.csv"))

# ── 2. Build Census District Panel ──────────────────────────
# Stack 1991, 2001, 2011 with common columns
common_cols <- c("pc11_state_id", "pc11_district_id", "year",
                 "pop", "main_workers", "cultivators", "ag_laborers",
                 "ag_workers", "nonfarm_workers")

d91_sub <- d91[, ..common_cols]
d01_sub <- d01[, ..common_cols]
d11_sub <- d11[, ..common_cols]

census_panel <- rbindlist(list(d91_sub, d01_sub, d11_sub))

# Create district ID
census_panel[, dist_id := paste0(pc11_state_id, "_", pc11_district_id)]

# Merge phase assignment
census_panel <- merge(census_panel, phase[, .(pc11_state_id, pc11_district_id,
                                               mgnrega_phase, first_treat_year,
                                               backwardness_index, sc_st_share)],
                      by = c("pc11_state_id", "pc11_district_id"),
                      all.x = FALSE)

# Compute outcome variables
census_panel[, `:=`(
  nonfarm_share = nonfarm_workers / pmax(main_workers, 1),
  ag_share      = ag_workers / pmax(main_workers, 1),
  cult_share    = cultivators / pmax(main_workers, 1),
  aglab_share   = ag_laborers / pmax(main_workers, 1),
  lit_rate      = NA_real_,  # Not in stacked panel (different var names per year)
  log_pop       = log(pmax(pop, 1))
)]

# Treatment indicator: treated if Census year >= first_treat_year
# 1991 and 2001: pre-treatment for all phases
# 2011: post-treatment for all phases (Phase I: 5 years, II: 4 years, III: 3 years)
census_panel[, treated := as.integer(year >= first_treat_year)]

# Create numeric time variable for CS-DiD
# Map census years to integers: 1991→1, 2001→2, 2011→3
census_panel[, time_id := fcase(
  year == 1991L, 1L,
  year == 2001L, 2L,
  year == 2011L, 3L
)]

# Create numeric district ID for CS-DiD
census_panel[, dist_num := as.integer(factor(dist_id))]

# CS-DiD requires first_treat in same time units
# Phase I (2006) → first treated in period 3 (2011 is first post-Census)
# Phase II (2007) → first treated in period 3
# Phase III (2008) → first treated in period 3
# Problem: all phases are treated by 2011, no variation in treatment timing
# at Census-year resolution!
#
# Solution: Use the phase assignment directly. Phase I was treated for
# 5 years by 2011, Phase III for only 3 years. The dose/duration varies.
# For CS-DiD, we need a "never-treated" or "not-yet-treated" group.
# Since all districts are treated by 2008, there is no never-treated group
# at Census level.
#
# Alternative approach:
# 1. TWFE DiD comparing Phase I (early) vs Phase III (late) districts
#    between 2001 and 2011. Phase III districts serve as comparison in 2001-2011
#    because they were treated ~2 years later. This is a standard "early vs late"
#    design, identical to Imbert & Papp (2015).
# 2. Triple-diff: Phase × Post × Census with 1991-2001 as pre-trend period.
# 3. Nightlights panel: Annual data 1994-2013 allows event study with
#    proper timing variation (Phase I=2006, II=2007, III=2008).

cat("\nCensus panel constructed:", nrow(census_panel), "district-year obs\n")
cat("  Districts:", uniqueN(census_panel$dist_id), "\n")
cat("  Phase distribution:\n")
print(census_panel[year == 2001, .N, by = mgnrega_phase][order(mgnrega_phase)])

# ── 3. Build Nightlights Panel ──────────────────────────────
# DMSP: 1994-2013, VIIRS: 2012-2023
# Use DMSP for the main analysis (covers pre/post MGNREGA)
# VIIRS for extended post-treatment period

# Standardize column names for DMSP
dmsp_panel <- dmsp[, .(pc11_state_id, pc11_district_id, year,
                        total_light = dmsp_total_light_cal,
                        mean_light = dmsp_mean_light_cal)]
dmsp_panel[, dist_id := paste0(pc11_state_id, "_", pc11_district_id)]

# Merge phase assignment
dmsp_panel <- merge(dmsp_panel, phase[, .(pc11_state_id, pc11_district_id,
                                           mgnrega_phase, first_treat_year,
                                           backwardness_index, sc_st_share)],
                    by = c("pc11_state_id", "pc11_district_id"),
                    all.x = FALSE)

# Log nightlights
dmsp_panel[, log_light := log(total_light + 1)]

# Treatment indicator
dmsp_panel[, treated := as.integer(year >= first_treat_year)]

# Event time relative to first treatment year
dmsp_panel[, event_time := year - first_treat_year]

# Numeric district ID
dmsp_panel[, dist_num := as.integer(factor(dist_id))]

cat("\nNightlights DMSP panel:", nrow(dmsp_panel), "district-year obs\n")
cat("  Districts:", uniqueN(dmsp_panel$dist_id), "\n")
cat("  Years:", min(dmsp_panel$year), "-", max(dmsp_panel$year), "\n")

# VIIRS panel
viirs_panel <- viirs[, .(pc11_state_id, pc11_district_id, year,
                          total_light = viirs_annual_sum,
                          mean_light = viirs_annual_mean)]
viirs_panel[, dist_id := paste0(pc11_state_id, "_", pc11_district_id)]
viirs_panel <- merge(viirs_panel, phase[, .(pc11_state_id, pc11_district_id,
                                             mgnrega_phase, first_treat_year)],
                     by = c("pc11_state_id", "pc11_district_id"),
                     all.x = FALSE)
viirs_panel[, `:=`(
  log_light = log(total_light + 1),
  treated = as.integer(year >= first_treat_year),
  event_time = year - first_treat_year,
  dist_num = as.integer(factor(dist_id))
)]

cat("Nightlights VIIRS panel:", nrow(viirs_panel), "district-year obs\n")

# ── 4. Gender-specific panel (2001 & 2011 only) ─────────────
d01_gender <- d01[, .(pc11_state_id, pc11_district_id,
                       main_workers_f, cultivators_f, ag_laborers_f,
                       hh_workers_f, ot_workers_f)]
d01_gender[, year := 2001L]

d11_gender <- d11[, .(pc11_state_id, pc11_district_id,
                       main_workers_f, cultivators_f, ag_laborers_f,
                       hh_workers_f, ot_workers_f)]
d11_gender[, year := 2011L]

gender_panel <- rbindlist(list(d01_gender, d11_gender))
gender_panel[, dist_id := paste0(pc11_state_id, "_", pc11_district_id)]
gender_panel <- merge(gender_panel, phase[, .(pc11_state_id, pc11_district_id,
                                               mgnrega_phase, first_treat_year)],
                      by = c("pc11_state_id", "pc11_district_id"),
                      all.x = FALSE)
gender_panel[, `:=`(
  nonfarm_share_f = (hh_workers_f + ot_workers_f) / pmax(main_workers_f, 1),
  ag_share_f = (cultivators_f + ag_laborers_f) / pmax(main_workers_f, 1),
  treated = as.integer(year >= first_treat_year)
)]

cat("Gender panel:", nrow(gender_panel), "district-year obs\n")

# ── 5. Save analysis-ready panels ───────────────────────────
fwrite(census_panel, file.path(data_dir, "analysis_census_panel.csv"))
fwrite(dmsp_panel, file.path(data_dir, "analysis_nightlights_panel.csv"))
fwrite(viirs_panel, file.path(data_dir, "analysis_viirs_panel.csv"))
fwrite(gender_panel, file.path(data_dir, "analysis_gender_panel.csv"))

cat("\nAll analysis panels saved.\n")
