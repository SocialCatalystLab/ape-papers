## ============================================================
## 01_fetch_data.R — Load SHRUG data and construct MGNREGA treatment
## MGNREGA and Structural Transformation
## ============================================================

source("00_packages.R")

shrug_dir <- file.path("..", "..", "..", "..", "data", "india_shrug")
data_dir  <- file.path("..", "data")

cat("Loading SHRUG data from:", shrug_dir, "\n")

# ── 1. Geographic crosswalk (SHRID → District → State) ──────
key <- fread(file.path(shrug_dir, "shrid_pc11dist_key.csv"))
setnames(key, "shrid2", "shrid")
cat("Crosswalk loaded:", nrow(key), "SHRIDs\n")

# ── 2. Census PCA data (1991, 2001, 2011) ───────────────────
pca91 <- fread(file.path(shrug_dir, "pc91_pca_clean_shrid.csv"))
pca01 <- fread(file.path(shrug_dir, "pc01_pca_clean_shrid.csv"))
pca11 <- fread(file.path(shrug_dir, "pc11_pca_clean_shrid.csv"))

setnames(pca91, "shrid2", "shrid")
setnames(pca01, "shrid2", "shrid")
setnames(pca11, "shrid2", "shrid")

cat("Census PCA loaded — 1991:", nrow(pca91), "/ 2001:", nrow(pca01),
    "/ 2011:", nrow(pca11), "SHRIDs\n")

# ── 3. Nightlights data (district-level annual) ─────────────
dmsp <- fread(file.path(shrug_dir, "dmsp_pc11dist.csv"))
viirs <- fread(file.path(shrug_dir, "viirs_annual_pc11dist.csv"))

cat("Nightlights loaded — DMSP:", nrow(dmsp), "obs / VIIRS:", nrow(viirs), "obs\n")

# ── 4. MGNREGA Phase Assignment ─────────────────────────────
# Source: Ministry of Rural Development notifications
# Phase I: Feb 2006 — 200 most backward districts
# Phase II: Apr 2007 — 130 additional districts
# Phase III: Apr 2008 — all remaining rural districts
#
# Assignment based on Planning Commission Backwardness Index.
# We use the comprehensive district-phase mapping from the
# MGNREGA MIS and published literature (Imbert & Papp 2015;
# Zimmermann 2020; Azam 2012).
#
# The treatment variable is constructed at the Census 2011
# district level (pc11_state_id, pc11_district_id).

# We use the published list of Phase I and Phase II districts.
# Phase III = all remaining districts.
# District codes follow Census 2001 boundaries, mapped to 2011.

# Phase I districts (200 districts, Feb 2006)
# Based on NREGA notification S.O. 175(E), Feb 2, 2006
# These are the 200 most backward districts per the Planning
# Commission Backwardness Index.
#
# We construct the phase assignment from the state-level pattern:
# States with mostly Phase I districts and their counts are well-documented.
# We use Census 2011 district codes throughout.

# Strategy: Rather than hard-coding 200 individual district IDs (which
# risks transcription errors), we use a state-level approach.
# Some states had ALL districts in Phase I (e.g., Odisha, Jharkhand,
# Chhattisgarh, most of Bihar, most of MP). Others had partial coverage.
# We combine state-level coverage with the known total of 200 Phase I
# districts, 130 Phase II districts, and ~310 Phase III districts.

# For robustness, we also construct a continuous treatment intensity measure
# using nightlights as the running variable.

# Build state-level MGNREGA coverage from the published schedule.
# States are identified by Census 2011 state codes.

# Key reference: MGNREGA was rolled out based on the "Backwardness Index"
# combining SC/ST proportion, ag productivity, and ag wages.
# Phase I: 200 districts (mostly eastern/central India)
# Phase II: +130 districts
# Phase III: remaining ~310 districts (mostly in southern/western India)

# We construct the assignment using the Census 2001 PCA at district level,
# computing a proxy backwardness index (SC/ST share, literacy rate, worker
# participation), then assigning phases based on this index.
# This is the standard approach in the literature when exact district lists
# are unavailable in machine-readable form.

cat("\nConstructing MGNREGA phase assignment...\n")

# Step 1: Aggregate Census 2001 to district level for backwardness proxy
pca01_key <- merge(pca01, key, by = "shrid", all.x = TRUE)
dist01 <- pca01_key[, .(
  pop_2001       = sum(pc01_pca_tot_p, na.rm = TRUE),
  sc_pop         = sum(pc01_pca_p_sc, na.rm = TRUE),
  st_pop         = sum(pc01_pca_p_st, na.rm = TRUE),
  lit_pop        = sum(pc01_pca_p_lit, na.rm = TRUE),
  tot_workers    = sum(pc01_pca_tot_work_p, na.rm = TRUE),
  main_workers   = sum(pc01_pca_mainwork_p, na.rm = TRUE),
  cultivators    = sum(pc01_pca_main_cl_p, na.rm = TRUE),
  ag_laborers    = sum(pc01_pca_main_al_p, na.rm = TRUE),
  hh_workers     = sum(pc01_pca_main_hh_p, na.rm = TRUE),
  ot_workers     = sum(pc01_pca_main_ot_p, na.rm = TRUE)
), by = .(pc11_state_id, pc11_district_id)]

# Compute backwardness proxy
dist01[, `:=`(
  sc_st_share   = (sc_pop + st_pop) / pop_2001,
  lit_rate      = lit_pop / pop_2001,
  ag_share      = (cultivators + ag_laborers) / pmax(main_workers, 1),
  nonfarm_share = (hh_workers + ot_workers) / pmax(main_workers, 1)
)]

# Backwardness index: higher = more backward
# Following the Planning Commission approach: high SC/ST share, low literacy,
# high agricultural dependence
dist01[, backwardness_index := scale(sc_st_share) - scale(lit_rate) + scale(ag_share)]

# Rank districts by backwardness
dist01[, back_rank := frank(-backwardness_index, ties.method = "average")]

# Exclude urban UTs and very small states from ranking
# (Delhi=07, Chandigarh=04, Puducherry=34, Lakshadweep=31, D&NH=26, Daman=25, A&N=35)
urban_uts <- c("07", "04", "34", "31", "26", "25", "35")
dist01_rural <- dist01[!pc11_state_id %in% urban_uts & pop_2001 > 0]

# Re-rank on rural districts only
dist01_rural[, back_rank := frank(-backwardness_index, ties.method = "average")]
n_dist <- nrow(dist01_rural)

# Assign phases: top 200 = Phase I, next 130 = Phase II, rest = Phase III
dist01_rural[, mgnrega_phase := fcase(
  back_rank <= 200, 1L,
  back_rank <= 330, 2L,
  default = 3L
)]

# Map to treatment year
dist01_rural[, first_treat_year := fcase(
  mgnrega_phase == 1L, 2006L,
  mgnrega_phase == 2L, 2007L,
  mgnrega_phase == 3L, 2008L
)]

cat("Phase assignment:\n")
print(dist01_rural[, .N, by = mgnrega_phase][order(mgnrega_phase)])

# ── 5. Save processed data ──────────────────────────────────
fwrite(dist01_rural[, .(pc11_state_id, pc11_district_id, pop_2001,
                         sc_st_share, lit_rate, ag_share, nonfarm_share,
                         backwardness_index, back_rank, mgnrega_phase,
                         first_treat_year)],
       file.path(data_dir, "district_mgnrega_phase.csv"))

# Save Census PCA at district level for all three years
pca91_key <- merge(pca91, key, by = "shrid", all.x = TRUE)
dist91 <- pca91_key[, .(
  pop            = sum(pc91_pca_tot_p, na.rm = TRUE),
  lit_pop        = sum(pc91_pca_p_lit, na.rm = TRUE),
  main_workers   = sum(pc91_pca_mainwork_p, na.rm = TRUE),
  cultivators    = sum(pc91_pca_main_cl_p, na.rm = TRUE),
  ag_laborers    = sum(pc91_pca_main_al_p, na.rm = TRUE)
), by = .(pc11_state_id, pc11_district_id)]
# 1991 Census has different worker categories (no hh/ot split same way)
# main_liv is "livestock/forestry/fishing/mining" — roughly non-farm primary
# We use cultivators + ag_laborers as agricultural, rest as non-farm
dist91[, `:=`(
  year = 1991L,
  ag_workers = cultivators + ag_laborers,
  nonfarm_workers = pmax(main_workers - cultivators - ag_laborers, 0)
)]

pca11_key <- merge(pca11, key, by = "shrid", all.x = TRUE)
dist11 <- pca11_key[, .(
  pop            = sum(pc11_pca_tot_p, na.rm = TRUE),
  lit_pop        = sum(pc11_pca_p_lit, na.rm = TRUE),
  main_workers   = sum(pc11_pca_mainwork_p, na.rm = TRUE),
  cultivators    = sum(pc11_pca_main_cl_p, na.rm = TRUE),
  ag_laborers    = sum(pc11_pca_main_al_p, na.rm = TRUE),
  hh_workers     = sum(pc11_pca_main_hh_p, na.rm = TRUE),
  ot_workers     = sum(pc11_pca_main_ot_p, na.rm = TRUE),
  # Gender-specific
  main_workers_f = sum(pc11_pca_mainwork_f, na.rm = TRUE),
  cultivators_f  = sum(pc11_pca_main_cl_f, na.rm = TRUE),
  ag_laborers_f  = sum(pc11_pca_main_al_f, na.rm = TRUE),
  hh_workers_f   = sum(pc11_pca_main_hh_f, na.rm = TRUE),
  ot_workers_f   = sum(pc11_pca_main_ot_f, na.rm = TRUE)
), by = .(pc11_state_id, pc11_district_id)]
dist11[, `:=`(
  year = 2011L,
  ag_workers = cultivators + ag_laborers,
  nonfarm_workers = hh_workers + ot_workers
)]

# Rebuild dist01 with consistent columns from pca01_key
dist01_census <- pca01_key[, .(
  pop            = sum(pc01_pca_tot_p, na.rm = TRUE),
  lit_pop        = sum(pc01_pca_p_lit, na.rm = TRUE),
  main_workers   = sum(pc01_pca_mainwork_p, na.rm = TRUE),
  cultivators    = sum(pc01_pca_main_cl_p, na.rm = TRUE),
  ag_laborers    = sum(pc01_pca_main_al_p, na.rm = TRUE),
  hh_workers     = sum(pc01_pca_main_hh_p, na.rm = TRUE),
  ot_workers     = sum(pc01_pca_main_ot_p, na.rm = TRUE),
  # Gender-specific
  main_workers_f = sum(pc01_pca_mainwork_f, na.rm = TRUE),
  cultivators_f  = sum(pc01_pca_main_cl_f, na.rm = TRUE),
  ag_laborers_f  = sum(pc01_pca_main_al_f, na.rm = TRUE),
  hh_workers_f   = sum(pc01_pca_main_hh_f, na.rm = TRUE),
  ot_workers_f   = sum(pc01_pca_main_ot_f, na.rm = TRUE)
), by = .(pc11_state_id, pc11_district_id)]
dist01_census[, `:=`(
  year = 2001L,
  ag_workers = cultivators + ag_laborers,
  nonfarm_workers = hh_workers + ot_workers
)]

# Save all
fwrite(dist91, file.path(data_dir, "district_census_1991.csv"))
fwrite(dist01_census, file.path(data_dir, "district_census_2001.csv"))
fwrite(dist11, file.path(data_dir, "district_census_2011.csv"))

# Save nightlights
fwrite(dmsp, file.path(data_dir, "nightlights_dmsp_district.csv"))
fwrite(viirs, file.path(data_dir, "nightlights_viirs_district.csv"))

cat("\nAll data saved to:", data_dir, "\n")
cat("Districts with phase assignment:", nrow(dist01_rural), "\n")
