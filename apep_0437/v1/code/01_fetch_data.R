# ============================================================================
# 01_fetch_data.R — Load election data and SHRUG nightlights
# Multi-Level Political Alignment and Local Development in India
# ============================================================================

source("00_packages.R")

# ── Paths ─────────────────────────────────────────────────────────────────
shrug_dir <- "../../../../data/india_shrug"
data_dir  <- "../data"

# ============================================================================
# 1. State Assembly Election Data (Harvard Dataverse, Bhavnani v3.0)
# ============================================================================
cat("Loading state assembly election data...\n")
elections <- fread(file.path(data_dir, "india_state_elections.tab"),
                   sep = "\t", quote = "\"", na.strings = c("", "NA"))

# Clean column names
setnames(elections, tolower(names(elections)))

cat(sprintf("  Elections: %s rows, %d columns\n",
            format(nrow(elections), big.mark = ","), ncol(elections)))
cat(sprintf("  States: %d | Years: %d-%d\n",
            uniqueN(elections$st_name),
            min(elections$year, na.rm = TRUE),
            max(elections$year, na.rm = TRUE)))

# ============================================================================
# 2. SHRUG VIIRS Nightlights at Assembly Constituency Level
# ============================================================================
cat("\nLoading VIIRS nightlights (AC level)...\n")
viirs <- fread(file.path(shrug_dir, "viirs_annual_con07.csv"))

# Keep the average-masked category (primary measure)
viirs <- viirs[category == "average-masked"]
viirs[, category := NULL]

cat(sprintf("  VIIRS: %s rows | ACs: %d | Years: %d-%d\n",
            format(nrow(viirs), big.mark = ","),
            uniqueN(viirs$ac07_id),
            min(viirs$year), max(viirs$year)))

# ============================================================================
# 3. SHRUG DMSP Nightlights at AC Level (for pre-2012 extension)
# ============================================================================
cat("\nLoading DMSP nightlights (AC level)...\n")
dmsp <- fread(file.path(shrug_dir, "dmsp_con07.csv"))

cat(sprintf("  DMSP: %s rows | ACs: %d | Years: %d-%d\n",
            format(nrow(dmsp), big.mark = ","),
            uniqueN(dmsp$ac07_id),
            min(dmsp$year), max(dmsp$year)))

# ============================================================================
# 4. Census 2011 Demographics at AC Level (covariates)
# ============================================================================
cat("\nLoading Census 2011 PCA (AC level)...\n")
census <- fread(file.path(shrug_dir, "pc11_pca_clean_con07.csv"))

cat(sprintf("  Census PCA: %d ACs\n", nrow(census)))

# ============================================================================
# 5. Census 2011 Town Directory at AC Level (amenities)
# ============================================================================
cat("\nLoading Census 2011 TD (AC level)...\n")
td <- fread(file.path(shrug_dir, "pc11_td_clean_con07.csv"))

cat(sprintf("  Census TD: %d ACs, %d columns\n", nrow(td), ncol(td)))

# ============================================================================
# 6. Save cleaned data
# ============================================================================
save(elections, viirs, dmsp, census, td,
     file = file.path(data_dir, "raw_data.RData"))
cat("\nAll data saved to raw_data.RData\n")
