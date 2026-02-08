################################################################################
# 01b_fetch_qcew.R
# Download QCEW employment data from BLS bulk files
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

  # Create quarterly proxy by duplicating annual data
  # (QCEW annual averages are actually based on quarterly data)
  qcew_quarterly <- qcew_data %>%
    crossing(quarter = 1:4) %>%
    mutate(
      yearq = year + (quarter - 1) / 4,
      log_emp = log(pmax(emp, 1))
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
