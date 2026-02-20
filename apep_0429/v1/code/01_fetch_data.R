## 01_fetch_data.R — Load SHRUG data for PMGSY dynamic RDD
## APEP-0429

source("00_packages.R")

## Resolve project root (handles running from code/ or from v1/)
project_root <- Sys.getenv("APEP_ROOT",
                           unset = normalizePath(file.path(getwd(), "../../../..")))
shrug_dir <- file.path(project_root, "data", "india_shrug")

cat("Loading SHRUG data from:", shrug_dir, "\n")

## ── Census 2001 PCA (population, workforce, literacy) ──────────────
pca01 <- fread(file.path(shrug_dir, "pc01_pca_clean_shrid.csv"))
cat("Census 2001 PCA:", nrow(pca01), "settlements\n")

## ── Census 2011 PCA ────────────────────────────────────────────────
pca11 <- fread(file.path(shrug_dir, "pc11_pca_clean_shrid.csv"))
cat("Census 2011 PCA:", nrow(pca11), "settlements\n")

## ── Census 1991 PCA (for pre-treatment balance) ────────────────────
pca91 <- fread(file.path(shrug_dir, "pc91_pca_clean_shrid.csv"))
cat("Census 1991 PCA:", nrow(pca91), "settlements\n")

## ── Rural key files (identify rural villages + land area) ──────────
rural_01 <- fread(file.path(shrug_dir, "pc01r_shrid_key.csv"))
cat("Rural settlements in 2001:", nrow(rural_01), "\n")

rural_11 <- fread(file.path(shrug_dir, "pc11r_shrid_key.csv"))
cat("Rural settlements in 2011:", nrow(rural_11), "\n")

## ── Geographic crosswalk (state, district codes) ───────────────────
geo <- fread(file.path(shrug_dir, "shrid_pc11dist_key.csv"))
cat("Geographic crosswalk:", nrow(geo), "entries\n")

## ── Nightlights: DMSP (1992–2013) ─────────────────────────────────
cat("Loading DMSP nightlights (this may take a minute)...\n")
dmsp <- fread(file.path(shrug_dir, "dmsp_shrid.csv"))
cat("DMSP nightlights:", nrow(dmsp), "settlements\n")

## ── Nightlights: VIIRS (2012–2021) ─────────────────────────────────
cat("Loading VIIRS nightlights (this may take a minute)...\n")
viirs <- fread(file.path(shrug_dir, "viirs_annual_shrid.csv"))
cat("VIIRS nightlights:", nrow(viirs), "settlements\n")

## ── Save intermediate objects ──────────────────────────────────────
save(pca01, pca11, pca91, rural_01, rural_11, geo, dmsp, viirs,
     file = "../data/raw_shrug.RData")
cat("Raw data saved to ../data/raw_shrug.RData\n")
