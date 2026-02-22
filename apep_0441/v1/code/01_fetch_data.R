## ============================================================================
## 01_fetch_data.R — Load SHRUG data from local files
## Project: apep_0441 — State Bifurcation and Development in India
## ============================================================================

source("00_packages.R")

shrug_dir <- "../../../../data/india_shrug"

cat("Loading SHRUG district crosswalk...\n")
td <- fread(file.path(shrug_dir, "pc11_td_clean_pc11dist.csv"))
cat("  Districts:", nrow(td), "\n")

## ---- Nightlights: DMSP (1994-2013) ----------------------------------------
cat("Loading DMSP nightlights (district level)...\n")
dmsp <- fread(file.path(shrug_dir, "dmsp_pc11dist.csv"))
cat("  DMSP rows:", nrow(dmsp), "| Years:", paste(range(dmsp$year), collapse = "-"), "\n")

## ---- Nightlights: VIIRS (2012-2023) ---------------------------------------
cat("Loading VIIRS nightlights (district level)...\n")
viirs <- fread(file.path(shrug_dir, "viirs_annual_pc11dist.csv"))
# Keep only median-masked category (standard)
viirs <- viirs[category == "median-masked"]
cat("  VIIRS rows:", nrow(viirs), "| Years:", paste(range(viirs$year), collapse = "-"), "\n")

## ---- Census PCA (1991, 2001, 2011) ----------------------------------------
cat("Loading Census PCA at district level...\n")

# Census 2011
pca11 <- fread(file.path(shrug_dir, "pc11_pca_clean_pc11dist.csv"))
cat("  Census 2011 districts:", nrow(pca11), "\n")

# Census 2001
pca01 <- fread(file.path(shrug_dir, "pc01_pca_clean_pc01dist.csv"))
cat("  Census 2001 districts:", nrow(pca01), "\n")

# Census 1991
pca91 <- fread(file.path(shrug_dir, "pc91_pca_clean_pc91dist.csv"))
cat("  Census 1991 districts:", nrow(pca91), "\n")

## ---- Save raw data ---------------------------------------------------------
save(td, dmsp, viirs, pca11, pca01, pca91,
     file = "../data/raw_shrug.RData")
cat("Raw data saved to data/raw_shrug.RData\n")
