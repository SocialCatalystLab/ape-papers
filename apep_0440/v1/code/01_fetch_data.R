###############################################################################
# 01_fetch_data.R — Fetch ACS PUMS and O*NET data
# Paper: Social Insurance Thresholds and Late-Career Underemployment
# APEP-0440
###############################################################################

source("00_packages.R")

cat("=== Phase 1: Fetching ACS PUMS Data ===\n")

pums_vars <- c("AGEP", "SCHL", "OCCP", "WKHP", "ESR",
               "HINS1", "HINS2", "HINS3", "HINS4",
               "PINCP", "SEX", "RAC1P", "HISP", "ST",
               "PWGTP", "NATIVITY", "COW")

# Use 15 largest states (~65% of US pop) for speed
# Geographic variation is irrelevant for age-based RDD
large_states <- c("CA", "TX", "FL", "NY", "PA", "IL", "OH", "GA",
                  "NC", "MI", "NJ", "VA", "WA", "AZ", "MA")

years <- 2018:2023
age_min <- 52
age_max <- 75

all_data <- list()

for (yr in years) {
  cache_file <- sprintf("../data/pums_%d.parquet", yr)

  if (file.exists(cache_file)) {
    cat(sprintf("  Loading cached %d...\n", yr))
    all_data[[as.character(yr)]] <- as.data.table(read_parquet(cache_file))
    next
  }

  cat(sprintf("  Fetching ACS PUMS %d (15 largest states)...\n", yr))

  tryCatch({
    pums_yr <- get_pums(
      variables = pums_vars,
      state = large_states,
      year = yr,
      survey = "acs1",
      recode = FALSE
    )

    setDT(pums_yr)
    pums_yr <- pums_yr[AGEP >= age_min & AGEP <= age_max]
    pums_yr[, employed := ESR %in% c("1", "2")]
    pums_yr[, year := yr]

    cat(sprintf("    -> %s observations (aged %d-%d)\n",
                format(nrow(pums_yr), big.mark = ","), age_min, age_max))

    write_parquet(pums_yr, cache_file)
    all_data[[as.character(yr)]] <- pums_yr

    gc()

  }, error = function(e) {
    cat(sprintf("    ERROR fetching %d: %s\n", yr, e$message))
  })
}

cat("  Combining all years...\n")
dt <- rbindlist(all_data, fill = TRUE)
rm(all_data); gc()

cat(sprintf("\nTotal observations: %s\n", format(nrow(dt), big.mark = ",")))
cat(sprintf("Age range: %d to %d\n", min(dt$AGEP), max(dt$AGEP)))
cat(sprintf("Years: %d to %d\n", min(dt$year), max(dt$year)))
cat(sprintf("Employed workers: %s\n",
            format(sum(dt$employed, na.rm = TRUE), big.mark = ",")))

write_parquet(dt, "../data/acs_pums_raw.parquet")
cat("  Saved: data/acs_pums_raw.parquet\n")

# === Phase 2: Fetch O*NET Job Zone data ===
cat("\n=== Phase 2: Fetching O*NET Job Zone Data ===\n")

onet_url <- "https://www.onetcenter.org/dl_files/database/db_29_1_excel/Job%20Zones.xlsx"
onet_dest <- "../data/onet_job_zones.xlsx"

if (!file.exists(onet_dest)) {
  cat("  Downloading O*NET Job Zones...\n")
  tryCatch({
    download.file(onet_url, onet_dest, mode = "wb", quiet = TRUE)
    cat("  Downloaded O*NET Job Zones successfully.\n")
  }, error = function(e) {
    cat(sprintf("  ERROR downloading O*NET: %s\n", e$message))
    alt_url <- "https://www.onetcenter.org/dl_files/database/db_29_1_text/Job%20Zones.txt"
    alt_dest <- "../data/onet_job_zones.txt"
    tryCatch({
      download.file(alt_url, alt_dest, mode = "wb", quiet = TRUE)
      cat("  Downloaded O*NET Job Zones (text format).\n")
    }, error = function(e2) {
      cat(sprintf("  ERROR: %s\n", e2$message))
      cat("  Will construct Job Zone mapping from education requirements.\n")
    })
  })
}

onet_edu_url <- "https://www.onetcenter.org/dl_files/database/db_29_1_excel/Education%2C%20Training%2C%20and%20Experience.xlsx"
onet_edu_dest <- "../data/onet_education.xlsx"

if (!file.exists(onet_edu_dest)) {
  cat("  Downloading O*NET Education requirements...\n")
  tryCatch({
    download.file(onet_edu_url, onet_edu_dest, mode = "wb", quiet = TRUE)
    cat("  Downloaded O*NET Education requirements.\n")
  }, error = function(e) {
    cat(sprintf("  NOTE: %s (will use Job Zones only)\n", e$message))
  })
}

# === Phase 3: Create SOC-to-OCCP crosswalk ===
cat("\n=== Phase 3: SOC-to-OCCP Crosswalk ===\n")

crosswalk_url <- "https://www2.census.gov/programs-surveys/acs/tech_docs/code_lists/2022_ACS_Code_Lists.xlsx"
crosswalk_dest <- "../data/acs_soc_crosswalk.xlsx"

if (!file.exists(crosswalk_dest)) {
  cat("  Downloading ACS-SOC crosswalk...\n")
  tryCatch({
    download.file(crosswalk_url, crosswalk_dest, mode = "wb", quiet = TRUE)
    cat("  Downloaded ACS-SOC crosswalk.\n")
  }, error = function(e) {
    cat(sprintf("  NOTE: %s\n", e$message))
    cat("  Will construct approximate mapping from OCCP ranges.\n")
  })
}

cat("\n=== Data Fetch Complete ===\n")
cat(sprintf("Files in data/:\n"))
print(list.files("../data/", pattern = "\\.(parquet|xlsx|txt)$"))
