## ============================================================
## 02_clean_data.R — Merge Census data, construct analysis panels
## ============================================================

source("code/00_packages.R")

cat("=== Loading intermediate data ===\n")
dist_key  <- readRDS("data/dist_key.rds")
pc01      <- readRDS("data/pc01_village.rds")
pc11      <- readRDS("data/pc11_village.rds")
nl        <- readRDS("data/nightlights_village_year.rds")
phases    <- readRDS("data/district_baseline_phases.rds")

# ============================================================
# Panel A: Village-level Census panel (long difference)
# ============================================================
cat("=== Constructing Census village panel ===\n")

# Worker composition shares for Census 2001
pc01_vars <- pc01[, .(
  shrid2,
  pop_01          = pc01_pca_tot_p,
  tot_work_01     = pc01_pca_tot_work_p,
  main_cl_01      = pc01_pca_main_cl_p,     # cultivators
  main_al_01      = pc01_pca_main_al_p,     # agricultural labor
  main_hh_01      = pc01_pca_main_hh_p,     # household industry
  main_ot_01      = pc01_pca_main_ot_p,     # other (non-farm)
  lit_01          = pc01_pca_p_lit,
  sc_01           = pc01_pca_p_sc,
  st_01           = pc01_pca_p_st,
  # Female workers
  tot_work_f_01   = pc01_pca_tot_work_f,
  main_cl_f_01    = pc01_pca_main_cl_f,
  main_al_f_01    = pc01_pca_main_al_f,
  main_hh_f_01    = pc01_pca_main_hh_f,
  main_ot_f_01    = pc01_pca_main_ot_f,
  lit_f_01        = pc01_pca_f_lit
)]

# Worker composition shares for Census 2011
pc11_vars <- pc11[, .(
  shrid2,
  pop_11          = pc11_pca_tot_p,
  tot_work_11     = pc11_pca_tot_work_p,
  main_cl_11      = pc11_pca_main_cl_p,
  main_al_11      = pc11_pca_main_al_p,
  main_hh_11      = pc11_pca_main_hh_p,
  main_ot_11      = pc11_pca_main_ot_p,
  lit_11          = pc11_pca_p_lit,
  sc_11           = pc11_pca_p_sc,
  st_11           = pc11_pca_p_st,
  # Female workers
  tot_work_f_11   = pc11_pca_tot_work_f,
  main_cl_f_11    = pc11_pca_main_cl_f,
  main_al_f_11    = pc11_pca_main_al_f,
  main_hh_f_11    = pc11_pca_main_hh_f,
  main_ot_f_11    = pc11_pca_main_ot_f,
  lit_f_11        = pc11_pca_f_lit
)]

# Merge 2001 and 2011 Census
census_panel <- merge(pc01_vars, pc11_vars, by = "shrid2")

# Add district identifiers
census_panel <- merge(census_panel, dist_key, by = "shrid2")

# Add MGNREGA phase
phase_key <- phases[, .(pc11_state_id, pc11_district_id, nrega_phase, first_treat,
                        backwardness_index)]
census_panel <- merge(census_panel, phase_key,
                      by = c("pc11_state_id", "pc11_district_id"))

cat(sprintf("  Census panel: %d villages matched\n", nrow(census_panel)))

# -- Compute worker share changes (long difference) --
census_panel[, `:=`(
  # Shares in 2001
  nonfarm_share_01  = main_ot_01 / pmax(tot_work_01, 1),
  aglabor_share_01  = main_al_01 / pmax(tot_work_01, 1),
  cultivator_share_01 = main_cl_01 / pmax(tot_work_01, 1),
  hh_ind_share_01   = main_hh_01 / pmax(tot_work_01, 1),
  lit_rate_01       = lit_01 / pmax(pop_01, 1),
  sc_st_share_01    = (sc_01 + st_01) / pmax(pop_01, 1),
  wfpr_01           = tot_work_01 / pmax(pop_01, 1),

  # Shares in 2011
  nonfarm_share_11  = main_ot_11 / pmax(tot_work_11, 1),
  aglabor_share_11  = main_al_11 / pmax(tot_work_11, 1),
  cultivator_share_11 = main_cl_11 / pmax(tot_work_11, 1),
  hh_ind_share_11   = main_hh_11 / pmax(tot_work_11, 1),
  lit_rate_11       = lit_11 / pmax(pop_11, 1),
  wfpr_11           = tot_work_11 / pmax(pop_11, 1),

  # Female-specific shares
  f_nonfarm_share_01 = main_ot_f_01 / pmax(tot_work_f_01, 1),
  f_aglabor_share_01 = main_al_f_01 / pmax(tot_work_f_01, 1),
  f_nonfarm_share_11 = main_ot_f_11 / pmax(tot_work_f_11, 1),
  f_aglabor_share_11 = main_al_f_11 / pmax(tot_work_f_11, 1),
  f_lit_rate_01      = lit_f_01 / pmax(pop_01, 1),
  f_lit_rate_11      = lit_f_11 / pmax(pop_11, 1),
  f_wfpr_01          = tot_work_f_01 / pmax(pop_01, 1),
  f_wfpr_11          = tot_work_f_11 / pmax(pop_11, 1)
)]

# Long differences (2011 - 2001)
census_panel[, `:=`(
  d_nonfarm_share    = nonfarm_share_11 - nonfarm_share_01,
  d_aglabor_share    = aglabor_share_11 - aglabor_share_01,
  d_cultivator_share = cultivator_share_11 - cultivator_share_01,
  d_hh_ind_share     = hh_ind_share_11 - hh_ind_share_01,
  d_lit_rate         = lit_rate_11 - lit_rate_01,
  d_wfpr             = wfpr_11 - wfpr_01,
  d_log_pop          = log(pmax(pop_11, 1)) - log(pmax(pop_01, 1)),
  d_f_nonfarm_share  = f_nonfarm_share_11 - f_nonfarm_share_01,
  d_f_aglabor_share  = f_aglabor_share_11 - f_aglabor_share_01,
  d_f_lit_rate       = f_lit_rate_11 - f_lit_rate_01,
  d_f_wfpr           = f_wfpr_11 - f_wfpr_01
)]

# Treatment indicators
census_panel[, `:=`(
  early_treat = as.integer(nrega_phase <= 2),  # Phase I + II vs Phase III
  phase1      = as.integer(nrega_phase == 1),
  phase2      = as.integer(nrega_phase == 2),
  high_sc_st  = as.integer(sc_st_share_01 > median(sc_st_share_01, na.rm = TRUE))
)]

# Create unique district ID for clustering
census_panel[, dist_id := paste0(pc11_state_id, "_", pc11_district_id)]

# Drop villages with zero population in either census
census_panel <- census_panel[pop_01 > 0 & pop_11 > 0]

cat(sprintf("  After cleaning: %d villages\n", nrow(census_panel)))

# ============================================================
# Panel B: District × Year nightlight panel
# ============================================================
cat("=== Constructing nightlight district-year panel ===\n")

# Aggregate village nightlights to district level
nl_dist <- merge(nl, dist_key, by = "shrid2")
nl_dist <- nl_dist[, .(
  total_light = sum(dmsp_total_light_cal, na.rm = TRUE),
  n_villages  = .N
), by = .(pc11_state_id, pc11_district_id, year)]

# Add MGNREGA phase
nl_dist <- merge(nl_dist, phase_key,
                 by = c("pc11_state_id", "pc11_district_id"))

# Create panel variables
nl_dist[, `:=`(
  log_light   = log(total_light + 1),
  dist_id     = paste0(pc11_state_id, "_", pc11_district_id),
  post        = as.integer(year >= first_treat),
  rel_time    = year - first_treat
)]

# Create numeric district ID for `did` package
nl_dist[, dist_num := as.integer(as.factor(dist_id))]

cat(sprintf("  NL district panel: %d district-years, %d districts\n",
            nrow(nl_dist), uniqueN(nl_dist$dist_id)))

# ============================================================
# Panel C: VIIRS district panel (2012-2023, for extension)
# ============================================================
cat("=== Constructing VIIRS district-year panel ===\n")
viirs_dist <- readRDS("data/viirs_district_year.rds")
viirs_dist <- merge(viirs_dist, phase_key,
                    by = c("pc11_state_id", "pc11_district_id"))
viirs_dist[, `:=`(
  log_light = log(viirs_annual_sum + 1),
  dist_id   = paste0(pc11_state_id, "_", pc11_district_id),
  rel_time  = year - first_treat
)]

cat(sprintf("  VIIRS district panel: %d district-years\n", nrow(viirs_dist)))

# ============================================================
# Summary statistics
# ============================================================
cat("\n=== Summary Statistics ===\n")
cat(sprintf("Villages in Census panel: %s\n",
            format(nrow(census_panel), big.mark = ",")))
cat(sprintf("Districts: %d (Phase I: %d, Phase II: %d, Phase III: %d)\n",
            uniqueN(census_panel$dist_id),
            uniqueN(census_panel[nrega_phase == 1]$dist_id),
            uniqueN(census_panel[nrega_phase == 2]$dist_id),
            uniqueN(census_panel[nrega_phase == 3]$dist_id)))
cat(sprintf("\nMean non-farm share 2001: %.3f\n",
            mean(census_panel$nonfarm_share_01, na.rm = TRUE)))
cat(sprintf("Mean non-farm share 2011: %.3f\n",
            mean(census_panel$nonfarm_share_11, na.rm = TRUE)))
cat(sprintf("Mean change in non-farm share: %.3f\n",
            mean(census_panel$d_nonfarm_share, na.rm = TRUE)))

# ============================================================
# Save analysis-ready data
# ============================================================
cat("\n=== Saving analysis data ===\n")
saveRDS(census_panel, "data/census_panel.rds")
saveRDS(nl_dist, "data/nl_district_panel.rds")
saveRDS(viirs_dist, "data/viirs_district_panel.rds")

cat("Data cleaning complete.\n")
