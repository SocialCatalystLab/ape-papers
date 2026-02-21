## ────────────────────────────────────────────────────────────────────────────
## 01_fetch_data.R — Load SHRUG data from local installation
## All data sourced from SHRUG v2.1 (Asher, Novosad, Lunt — devdatalab.org)
## ────────────────────────────────────────────────────────────────────────────

source("00_packages.R")

shrug_dir <- "../../../../data/india_shrug"

cat("Loading SHRUG data from:", shrug_dir, "\n")

# ── Census 2001 PCA (running variable + baseline outcomes) ──────────────────
cat("  Census 2001 PCA (village level)...\n")
pc01 <- fread(file.path(shrug_dir, "pc01_pca_clean_shrid.csv"))
cat("    Rows:", nrow(pc01), "\n")

# ── Census 2011 PCA (outcome variables) ─────────────────────────────────────
cat("  Census 2011 PCA (village level)...\n")
pc11 <- fread(file.path(shrug_dir, "pc11_pca_clean_shrid.csv"))
cat("    Rows:", nrow(pc11), "\n")

# ── Geographic crosswalk (state/district codes) ─────────────────────────────
cat("  District-level crosswalk...\n")
dist_key <- fread(file.path(shrug_dir, "shrid_pc11dist_key.csv"))
cat("    Rows:", nrow(dist_key), "\n")

# ── Rural village identifier ────────────────────────────────────────────────
cat("  Rural village key (Census 2001)...\n")
rural_key <- fread(file.path(shrug_dir, "pc01r_shrid_key.csv"))
cat("    Rural villages:", nrow(rural_key), "\n")

# ── DMSP nightlights (1994-2013) ────────────────────────────────────────────
cat("  DMSP nightlights (annual, village level)...\n")
dmsp <- fread(file.path(shrug_dir, "dmsp_shrid.csv"))
cat("    Rows:", nrow(dmsp), "| Years:", paste(range(dmsp$year), collapse = "-"), "\n")

# ── VIIRS nightlights (2012-2023) ───────────────────────────────────────────
cat("  VIIRS nightlights (annual, village level)...\n")
viirs <- fread(file.path(shrug_dir, "viirs_annual_shrid.csv"))
cat("    Rows:", nrow(viirs), "| Years:", paste(range(viirs$year), collapse = "-"), "\n")

# ── Save raw data ───────────────────────────────────────────────────────────
save(pc01, pc11, dist_key, rural_key, dmsp, viirs,
     file = "../data/shrug_raw.RData")

cat("\nAll SHRUG data loaded and saved to data/shrug_raw.RData\n")
