################################################################################
# 01b_fetch_qcew.R
# Download QCEW employment data from BLS bulk files
#
# DATA LIMITATIONS - TEMPORAL INTERPOLATION:
# This script downloads ANNUAL QCEW averages from BLS and creates quarterly
# observations by replicating each annual value across 4 quarters. This is a
# PROXY approach that holds employment constant within each year.
#
# IMPORTANT: The resulting "quarterly" data does NOT capture within-year
# employment fluctuations. All four quarters of a given year have identical
# employment values derived from the annual average. This approach:
#   1. Preserves cross-sectional variation (across counties/industries)
#   2. Preserves year-to-year variation (annual changes)
#   3. Does NOT capture within-year dynamics or seasonal patterns
#
# IMPLICATIONS FOR INFERENCE:
# - Standard errors should be clustered at the county-year level (not quarter)
# - Point estimates are valid for annual-average effects
# - Effective sample size for temporal variation is YEARS, not QUARTERS
# - Reported quarterly sample sizes overstate independent observations by 4x
#
# ALTERNATIVE APPROACHES (not used here due to data access constraints):
# - QWI quarterly files provide true quarterly variation but require Census API
# - QCEW quarterly files are available but require separate downloads per quarter
#
# This limitation is documented in the paper's Data section under "Data
# Limitations" and in all tables reporting quarterly sample sizes.
################################################################################

source("00_packages.R")

cat("=== Fetching QCEW Employment Data from BLS ===\n\n")

# BLS QCEW data is available in bulk CSV format
# We'll download annual averages by county and industry

# Create data directory
dir.create("../data", showWarnings = FALSE)

# Sample years to download (keeping manageable)
years <- 2015:2022

qcew_list <- list()

for (yr in years) {
  cat("Downloading QCEW data for", yr, "...\n")

  # URL for annual averages by county (CSV format)
  # File format: {year}.annual.by_area.csv.zip
  url <- paste0("https://data.bls.gov/cew/data/files/", yr,
                "/csv/", yr, "_annual_by_area.zip")

  temp_zip <- tempfile(fileext = ".zip")
  temp_dir <- tempdir()

  tryCatch({
    download.file(url, temp_zip, mode = "wb", quiet = TRUE)
    unzip(temp_zip, exdir = temp_dir)

    # Find the CSV file
    csv_file <- list.files(temp_dir, pattern = "\\.csv$", full.names = TRUE)[1]

    if (!is.null(csv_file) && file.exists(csv_file)) {
      # Read and filter to counties + relevant industries
      dat <- fread(csv_file, nrows = -1)

      # Filter to:
      # - County level (area_fips 5 digits, not ending in 000)
      # - Private ownership (own_code = 5)
      # - Relevant industries: Total (10), Retail (44-45), Food Service (72), Finance (52), Professional (54)

      dat_filtered <- dat %>%
        filter(
          nchar(area_fips) == 5,
          !grepl("000$", area_fips),
          own_code == 5,
          industry_code %in% c("10", "44-45", "72", "52", "54")
        ) %>%
        select(
          area_fips, industry_code, year,
          annual_avg_emplvl, annual_avg_wkly_wage, total_annual_wages
        ) %>%
        rename(
          county_fips = area_fips,
          industry = industry_code,
          emp = annual_avg_emplvl,
          avg_wage = annual_avg_wkly_wage,
          total_wages = total_annual_wages
        )

      qcew_list[[as.character(yr)]] <- dat_filtered
      cat("  Downloaded", format(nrow(dat_filtered), big.mark = ","), "county-industry records\n")
    }

  }, error = function(e) {
    cat("  Error downloading", yr, ":", conditionMessage(e), "\n")
  })

  # Clean up
  unlink(temp_zip)
  Sys.sleep(1)  # Be nice to BLS servers
}

# Combine all years
if (length(qcew_list) > 0) {
  qcew_data <- bind_rows(qcew_list)

  # ============================================================================
  # TEMPORAL INTERPOLATION: Create quarterly observations from annual data
  # ============================================================================
  # LIMITATION: This replicates annual averages across 4 quarters.
  # The resulting quarterly observations are NOT independent - they represent
  # the SAME annual employment level repeated 4 times.
  #
  # This is a proxy approach used because:
  # 1. QCEW annual files are more reliably available than quarterly files
  # 2. The primary analysis focuses on cross-sectional (county) variation
  # 3. Minimum wage changes occur at discrete dates, not quarterly
  #
  # All downstream analysis must account for this by:
  # - Clustering at county-year level (not county-quarter)
  # - Interpreting sample sizes as county-years, not county-quarters
  # - Focusing on cross-sectional rather than high-frequency temporal variation
  # ============================================================================
  qcew_quarterly <- qcew_data %>%
    crossing(quarter = 1:4) %>%
    mutate(
      yearq = year + (quarter - 1) / 4,
      log_emp = log(pmax(emp, 1)),
      # Flag for downstream scripts that this is interpolated data
      is_annual_interpolation = TRUE
    )

  # Identify high-bite vs low-bite industries
  qcew_quarterly <- qcew_quarterly %>%
    mutate(
      industry_type = case_when(
        industry %in% c("44-45", "72") ~ "High Bite",
        industry %in% c("52", "54") ~ "Low Bite",
        industry == "10" ~ "All Industries",
        TRUE ~ "Other"
      )
    )

  cat("\n=== QCEW Data Summary ===\n")
  cat("Total observations:", format(nrow(qcew_quarterly), big.mark = ","), "\n")
  cat("Counties:", n_distinct(qcew_quarterly$county_fips), "\n")
  cat("Industries:", n_distinct(qcew_quarterly$industry), "\n")
  cat("Years:", min(qcew_quarterly$year), "-", max(qcew_quarterly$year), "\n")

  # Save
  saveRDS(qcew_quarterly, "../data/raw_qcew.rds")
  cat("\nSaved raw_qcew.rds\n")

} else {
  cat("\nERROR: Could not download any QCEW data\n")
}
