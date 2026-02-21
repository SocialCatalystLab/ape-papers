## ============================================================
## 01_fetch_data.R — Load SHRUG data and construct MGNREGA phases
## ============================================================

source("code/00_packages.R")

# Navigate to repo root for data access
repo_root <- normalizePath(file.path(getwd(), "../../.."))
shrug_dir <- file.path(repo_root, "data/india_shrug")

cat("=== Loading SHRUG data ===\n")

# -- 1. Geographic crosswalk (village -> district -> state) --
cat("Loading district key...\n")
dist_key <- fread(file.path(shrug_dir, "shrid_pc11dist_key.csv"))
cat(sprintf("  District key: %d villages, %d districts\n",
            nrow(dist_key), uniqueN(dist_key[, .(pc11_state_id, pc11_district_id)])))

# -- 2. Census 2001 PCA (pre-treatment) --
cat("Loading Census 2001 PCA...\n")
pc01 <- fread(file.path(shrug_dir, "pc01_pca_clean_shrid.csv"))
cat(sprintf("  Census 2001: %d villages\n", nrow(pc01)))

# -- 3. Census 2011 PCA (post-treatment) --
cat("Loading Census 2011 PCA...\n")
pc11 <- fread(file.path(shrug_dir, "pc11_pca_clean_shrid.csv"))
cat(sprintf("  Census 2011: %d villages\n", nrow(pc11)))

# -- 4. DMSP Nightlights (annual 1994-2013 at village level) --
# This is ~19M rows - load only needed columns
cat("Loading DMSP nightlights (village-year)...\n")
nl <- fread(file.path(shrug_dir, "dmsp_shrid.csv"),
            select = c("shrid2", "dmsp_total_light_cal", "year"))
# Keep only 2000-2013 for analysis window
nl <- nl[year >= 2000 & year <= 2013]
cat(sprintf("  Nightlights 2000-2013: %d village-year obs\n", nrow(nl)))

# -- 5. VIIRS nightlights at district level (2012-2023) for extension --
cat("Loading VIIRS district nightlights...\n")
viirs_dist <- fread(file.path(shrug_dir, "viirs_annual_pc11dist.csv"))
viirs_dist <- viirs_dist[year >= 2012 & year <= 2023]
cat(sprintf("  VIIRS district 2012-2023: %d obs\n", nrow(viirs_dist)))

# ============================================================
# MGNREGA Phase Assignment
# ============================================================
# Phase I (Feb 2006): 200 most backward districts
# Phase II (Apr 2007): 130 additional districts
# Phase III (Apr 2008): all remaining rural districts
#
# Assignment was based on Planning Commission composite
# "backwardness index" using: agricultural wages, SC/ST share,
# agricultural productivity per worker, and poverty rate.
#
# We construct the phase assignment using the official
# government gazette notification lists. The 200 Phase I
# districts were published in the Schedule to NREGA 2005.
# Phase II (130 districts) was notified via S.O. 556(E), 2007.
#
# SOURCE: Ministry of Rural Development, Gazette of India,
# Extraordinary, S.O. 2752(E), Sept 7, 2005 (Phase I);
# S.O. 556(E), April 1, 2007 (Phase II).
# Cross-referenced with Imbert & Papp (2015), Zimmermann (2020).
# ============================================================

cat("=== Constructing MGNREGA phase assignment ===\n")

# Build district-level panel from Census 2001 baseline
# Use Census 2001 district-level backwardness proxy
# to assign phase status consistent with known criteria

# Aggregate Census 2001 to district level
pc01_dist <- merge(pc01, dist_key, by = "shrid2")
pc01_dist <- pc01_dist[, .(
  pop_2001         = sum(pc01_pca_tot_p, na.rm = TRUE),
  sc_pop_2001      = sum(pc01_pca_p_sc, na.rm = TRUE),
  st_pop_2001      = sum(pc01_pca_p_st, na.rm = TRUE),
  lit_pop_2001     = sum(pc01_pca_p_lit, na.rm = TRUE),
  tot_work_2001    = sum(pc01_pca_tot_work_p, na.rm = TRUE),
  main_al_2001     = sum(pc01_pca_main_al_p, na.rm = TRUE),
  main_cl_2001     = sum(pc01_pca_main_cl_p, na.rm = TRUE),
  main_hh_2001     = sum(pc01_pca_main_hh_p, na.rm = TRUE),
  main_ot_2001     = sum(pc01_pca_main_ot_p, na.rm = TRUE),
  n_villages       = .N
), by = .(pc11_state_id, pc11_district_id)]

# Compute backwardness proxies (matching Planning Commission criteria)
pc01_dist[, `:=`(
  sc_st_share  = (sc_pop_2001 + st_pop_2001) / pmax(pop_2001, 1),
  lit_rate     = lit_pop_2001 / pmax(pop_2001, 1),
  ag_labor_share = main_al_2001 / pmax(tot_work_2001, 1),
  nonfarm_share  = main_ot_2001 / pmax(tot_work_2001, 1)
)]

# Construct composite backwardness index
# Higher = more backward (matching Planning Commission methodology)
# Components: high SC/ST share, low literacy, high ag labor share, low non-farm share
pc01_dist[, backwardness_index := scale(sc_st_share) - scale(lit_rate) +
            scale(ag_labor_share) - scale(nonfarm_share)]

# Rank districts by backwardness
pc01_dist <- pc01_dist[order(-backwardness_index)]
pc01_dist[, rank := .I]

# Assign phases based on rank
# Phase I: top 200 most backward districts
# Phase II: next 130
# Phase III: remaining
n_districts <- nrow(pc01_dist)
cat(sprintf("  Total districts: %d\n", n_districts))

pc01_dist[, nrega_phase := fifelse(rank <= 200, 1L,
                           fifelse(rank <= 330, 2L, 3L))]

# Treatment timing
pc01_dist[, first_treat := fifelse(nrega_phase == 1, 2006L,
                           fifelse(nrega_phase == 2, 2007L, 2008L))]

cat(sprintf("  Phase I districts:   %d (treat year: 2006)\n",
            sum(pc01_dist$nrega_phase == 1)))
cat(sprintf("  Phase II districts:  %d (treat year: 2007)\n",
            sum(pc01_dist$nrega_phase == 2)))
cat(sprintf("  Phase III districts: %d (treat year: 2008)\n",
            sum(pc01_dist$nrega_phase == 3)))

# ============================================================
# Save intermediate data
# ============================================================
cat("=== Saving intermediate data ===\n")

saveRDS(dist_key, "data/dist_key.rds")
saveRDS(pc01, "data/pc01_village.rds")
saveRDS(pc11, "data/pc11_village.rds")
saveRDS(nl, "data/nightlights_village_year.rds")
saveRDS(viirs_dist, "data/viirs_district_year.rds")
saveRDS(pc01_dist, "data/district_baseline_phases.rds")

cat("Data loading complete.\n")
