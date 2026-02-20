## ============================================================================
## 01_fetch_data.R — Download NFHS-4/5 district data
## Paper: Can Clean Cooking Save Lives? (apep_0422)
## ============================================================================

source(file.path(dirname(sys.frame(1)$ofile), "00_packages.R"))

# ── 1. NFHS District Factsheet Data (NFHS-4 & NFHS-5) ───────────────────────
# Source: GitHub repo by SaiSiddhardhaKalla (parsed from rchiips.org)
# 707 districts, both NFHS-4 (2015-16) and NFHS-5 (2019-21) values

nfhs_url <- "https://raw.githubusercontent.com/SaiSiddhardhaKalla/NFHS/main/India.csv"
nfhs_file <- file.path(data_dir, "nfhs_district_raw.csv")

if (!file.exists(nfhs_file)) {
  cat("Downloading NFHS district factsheet data...\n")
  download.file(nfhs_url, nfhs_file, quiet = TRUE)
  cat("  Downloaded:", nfhs_file, "\n")
} else {
  cat("NFHS data already present:", nfhs_file, "\n")
}

nfhs_raw <- fread(nfhs_file)
cat("NFHS raw data:", nrow(nfhs_raw), "rows,", length(unique(nfhs_raw$District)), "districts\n")

# ── 2. Summary ───────────────────────────────────────────────────────────────
cat("\n=== Data Fetch Summary ===\n")
cat("NFHS district data: ", ifelse(file.exists(nfhs_file), "OK", "MISSING"), "\n")
