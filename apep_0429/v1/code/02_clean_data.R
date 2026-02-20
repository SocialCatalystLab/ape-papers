## 02_clean_data.R — Build analysis sample for PMGSY dynamic RDD
## APEP-0429

source("00_packages.R")
load("../data/raw_shrug.RData")

## ── Step 1: Identify rural (2001) villages ─────────────────────────
rural_ids <- rural_01$shrid2
cat("Rural villages in 2001:", length(rural_ids), "\n")

## ── Step 2: Get state codes for each village ────────────────────────
geo_slim <- geo[, .(shrid2, pc11_state_id, pc11_district_id)]

## ── Step 3: Exclude NE + hill states (PMGSY threshold = 250) ────────
## NE: Arunachal (12), Assam (18), Manipur (14), Meghalaya (17),
## Mizoram (15), Nagaland (13), Sikkim (11), Tripura (16)
## Hill: HP (02), J&K (01), Uttarakhand (05)
excluded_states <- c("01", "02", "05", "11", "12", "13", "14",
                     "15", "16", "17", "18")

## ── Step 4: Build base sample from Census 2001 ─────────────────────
sample <- pca01[shrid2 %in% rural_ids]
sample <- merge(sample, geo_slim, by = "shrid2", all.x = TRUE)
sample <- sample[!(pc11_state_id %in% excluded_states)]
sample <- sample[!is.na(pc01_pca_tot_p) & pc01_pca_tot_p > 0]
cat("Base sample (rural, plain areas, pop > 0):", nrow(sample), "\n")

## Key variables
sample[, pop01 := pc01_pca_tot_p]
sample[, eligible := as.integer(pop01 >= 500)]
sample[, pop_centered := pop01 - 500]

## Workforce composition (2001)
sample[, ag_share_01 := (pc01_pca_main_cl_p + pc01_pca_main_al_p) /
         pmax(pc01_pca_mainwork_p, 1)]
sample[, lit_rate_01 := pc01_pca_p_lit / pmax(pc01_pca_tot_p, 1)]
sample[, sc_share_01 := pc01_pca_p_sc / pmax(pc01_pca_tot_p, 1)]
sample[, st_share_01 := pc01_pca_p_st / pmax(pc01_pca_tot_p, 1)]
sample[, female_share_01 := pc01_pca_tot_f / pmax(pc01_pca_tot_p, 1)]
sample[, worker_share_01 := pc01_pca_tot_work_p / pmax(pc01_pca_tot_p, 1)]

## ── Step 5: Merge Census 1991 data (pre-treatment covariates) ──────
pca91_vars <- pca91[, .(shrid2,
                        pop91 = pc91_pca_tot_p,
                        lit_rate_91 = pc91_pca_p_lit / pmax(pc91_pca_tot_p, 1))]
sample <- merge(sample, pca91_vars, by = "shrid2", all.x = TRUE)

## ── Step 6: Merge Census 2011 data (long-run outcomes) ──────────────
pca11_vars <- pca11[, .(shrid2,
                        pop11 = pc11_pca_tot_p,
                        lit_rate_11 = pc11_pca_p_lit / pmax(pc11_pca_tot_p, 1),
                        ag_share_11 = (pc11_pca_main_cl_p + pc11_pca_main_al_p) /
                          pmax(pc11_pca_mainwork_p, 1),
                        nonag_share_11 = (pc11_pca_main_ot_p + pc11_pca_main_hh_p) /
                          pmax(pc11_pca_mainwork_p, 1),
                        worker_share_11 = pc11_pca_tot_work_p / pmax(pc11_pca_tot_p, 1))]
sample <- merge(sample, pca11_vars, by = "shrid2", all.x = TRUE)

## ── Step 7: Merge DMSP nightlights (long panel) ────────────────────
## DMSP is shrid2 × year panel. Use total_light_cal as primary measure.
cat("Merging DMSP nightlights...\n")
dmsp_slim <- dmsp[, .(shrid2, year,
                       dmsp_light = dmsp_total_light_cal)]

## Create wide panel for selected years
dmsp_wide <- dcast(dmsp_slim, shrid2 ~ year,
                   value.var = "dmsp_light", fun.aggregate = mean)
## Rename columns to dmsp_YYYY
old_names <- setdiff(names(dmsp_wide), "shrid2")
new_names <- paste0("dmsp_", old_names)
setnames(dmsp_wide, old_names, new_names)
sample <- merge(sample, dmsp_wide, by = "shrid2", all.x = TRUE)
cat("DMSP years available:", paste(sort(old_names), collapse = ", "), "\n")

## ── Step 8: Merge VIIRS nightlights ────────────────────────────────
cat("Merging VIIRS nightlights...\n")
## Use median-masked category where available
viirs_slim <- viirs[, .(shrid2, year,
                        viirs_light = viirs_annual_sum)]
viirs_wide <- dcast(viirs_slim, shrid2 ~ year,
                    value.var = "viirs_light", fun.aggregate = mean)
old_names_v <- setdiff(names(viirs_wide), "shrid2")
new_names_v <- paste0("viirs_", old_names_v)
setnames(viirs_wide, old_names_v, new_names_v)
sample <- merge(sample, viirs_wide, by = "shrid2", all.x = TRUE)
cat("VIIRS years available:", paste(sort(old_names_v), collapse = ", "), "\n")

## ── Step 9: Restrict bandwidth for main analysis ────────────────────
## Keep villages within a wide window around threshold (will narrow later)
sample_bw <- sample[abs(pop_centered) <= 500]
cat("\nFinal analysis sample (±500 bandwidth):", nrow(sample_bw), "\n")
cat("  Eligible (pop >= 500):", sum(sample_bw$eligible), "\n")
cat("  Ineligible (pop < 500):", sum(1 - sample_bw$eligible), "\n")

## ── Save ────────────────────────────────────────────────────────────
save(sample, sample_bw, file = "../data/analysis_data.RData")
cat("\nAnalysis data saved successfully.\n")

## Summary stats
cat("\n=== Population Distribution ===\n")
cat("Mean pop (full sample):", round(mean(sample$pop01)), "\n")
cat("Median pop (full sample):", round(median(sample$pop01)), "\n")
cat("Villages in ±100 of threshold:", sum(abs(sample$pop_centered) <= 100), "\n")
cat("Villages in ±200 of threshold:", sum(abs(sample$pop_centered) <= 200), "\n")
