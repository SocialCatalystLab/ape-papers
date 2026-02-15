## ============================================================================
## 01_fetch_data.R — Prepare T-MSIS + NPPES data for analysis
## Downloads handled externally (curl); this script processes raw files
## ============================================================================

source("00_packages.R")

DATA <- "../data"
dir.create(DATA, showWarnings = FALSE, recursive = TRUE)

## ---- 1. T-MSIS: Unzip CSV and convert to Parquet ----
tmsis_parquet <- file.path(DATA, "tmsis_full.parquet")
tmsis_zip <- file.path(DATA, "medicaid_provider_spending.csv.zip")

if (!file.exists(tmsis_parquet)) {
  if (file.exists(tmsis_zip)) {
    cat("Unzipping T-MSIS CSV...\n")
    unzip(tmsis_zip, exdir = DATA)
    csv_file <- list.files(DATA, pattern = "medicaid.*\\.csv$", full.names = TRUE)
    csv_file <- csv_file[!grepl("sample", csv_file)]
    if (length(csv_file) > 0) {
      cat(sprintf("Reading %s...\n", basename(csv_file[1])))
      # Read in chunks to manage memory for 11 GB file
      tmsis <- fread(csv_file[1], showProgress = TRUE, nThread = 4)
      cat(sprintf("Loaded %s rows, %d columns\n", format(nrow(tmsis), big.mark=","), ncol(tmsis)))

      # Save as Parquet for fast future reads
      write_parquet(tmsis, tmsis_parquet)
      cat("Saved as Parquet.\n")

      # Remove the large CSV to save disk space
      file.remove(csv_file[1])
      cat("Removed raw CSV.\n")
    }
  } else {
    stop("T-MSIS zip not found. Download it first:\n",
         "curl -L -o ../data/medicaid_provider_spending.csv.zip ",
         "'https://stopendataprod.blob.core.windows.net/datasets/medicaid-provider-spending/2026-02-09/medicaid-provider-spending.csv.zip'")
  }
}

# Verify
if (file.exists(tmsis_parquet)) {
  pq <- read_parquet(tmsis_parquet, as_data_frame = FALSE)
  cat(sprintf("T-MSIS Parquet: %s rows, %d columns\n",
              format(nrow(pq), big.mark=","), ncol(pq)))
  cat("Columns:", paste(names(pq), collapse=", "), "\n")
}

## ---- 2. NPPES: Extract key columns from bulk CSV ----
nppes_parquet <- file.path(DATA, "nppes_extract.parquet")
nppes_csv <- list.files(DATA, pattern = "npidata_pfile.*\\.csv$", full.names = TRUE)
nppes_csv <- nppes_csv[!grepl("header", nppes_csv)]

if (!file.exists(nppes_parquet) && length(nppes_csv) > 0) {
  cat(sprintf("Reading NPPES from %s...\n", basename(nppes_csv[1])))
  # Only read the columns we need (329 → ~20)
  nppes_cols <- c(
    "NPI",
    "Entity Type Code",
    "Provider Organization Name (Legal Business Name)",
    "Provider Last Name (Legal Name)",
    "Provider First Name",
    "Provider Credential Text",
    "Provider Sex Code",
    "Provider Business Practice Location Address State Name",
    "Provider Business Practice Location Address Postal Code",
    "Provider Business Practice Location Address City Name",
    "Healthcare Provider Taxonomy Code_1",
    "Healthcare Provider Taxonomy Code_2",
    "Is Sole Proprietor",
    "Is Organization Subpart",
    "Parent Organization LBN",
    "Parent Organization TIN",
    "Provider Enumeration Date",
    "NPI Deactivation Date",
    "NPI Deactivation Reason Code",
    "NPI Reactivation Date",
    "Last Update Date"
  )

  nppes <- fread(nppes_csv[1], select = nppes_cols,
                 showProgress = TRUE, nThread = 4)

  setnames(nppes, c(
    "npi", "entity_type", "org_name", "last_name", "first_name",
    "credential", "gender", "state", "zip", "city",
    "taxonomy_1", "taxonomy_2", "sole_prop", "is_subpart",
    "parent_org_name", "parent_org_tin",
    "enumeration_date", "deactivation_date", "deactivation_reason",
    "reactivation_date", "last_update"
  ))

  # Parse dates
  date_cols <- c("enumeration_date", "deactivation_date", "reactivation_date", "last_update")
  for (col in date_cols) {
    nppes[, (col) := as.Date(get(col), format = "%m/%d/%Y")]
  }

  # Clean ZIP to 5-digit
  nppes[, zip5 := substr(gsub("[^0-9]", "", zip), 1, 5)]

  # Save
  write_parquet(nppes, nppes_parquet)
  cat(sprintf("NPPES extract saved: %s providers\n", format(nrow(nppes), big.mark=",")))

  # Remove the large CSV
  file.remove(nppes_csv[1])
  cat("Removed raw NPPES CSV.\n")
} else if (file.exists(nppes_parquet)) {
  nppes <- as.data.table(read_parquet(nppes_parquet))
  cat(sprintf("NPPES Parquet loaded: %s providers\n", format(nrow(nppes), big.mark=",")))
}

## ---- 3. State shapefiles ----
shapes_path <- file.path(DATA, "state_shapes.rds")
if (!file.exists(shapes_path)) {
  cat("Downloading state shapefiles...\n")
  states_sf <- tigris::states(cb = TRUE, year = 2022, progress_bar = FALSE)
  # Keep 50 states + DC
  states_sf <- states_sf[states_sf$STATEFP %in% sprintf("%02d", c(1:56)[-c(3,7,14,43,52)]),]
  saveRDS(states_sf, shapes_path)
  cat("State shapefiles saved.\n")
}

## ---- 4. Census ACS population for per-capita ----
acs_path <- file.path(DATA, "acs_state_pop.csv")
if (!file.exists(acs_path)) {
  api_key <- Sys.getenv("CENSUS_API_KEY")
  if (nchar(api_key) > 0) {
    cat("Fetching ACS state population...\n")
    url <- sprintf(
      "https://api.census.gov/data/2022/acs/acs5?get=B01003_001E,B17001_002E,NAME&for=state:*&key=%s",
      api_key
    )
    resp <- jsonlite::fromJSON(url)
    acs <- as.data.table(resp[-1,])
    setnames(acs, c("total_pop", "poverty_pop", "state_name", "state_fips"))
    acs[, total_pop := as.numeric(total_pop)]
    acs[, poverty_pop := as.numeric(poverty_pop)]
    fwrite(acs, acs_path)
    cat("ACS saved.\n")
  }
}

cat("\n=== Data preparation complete ===\n")
cat("Files:\n")
for (f in list.files(DATA, full.names = FALSE)) {
  sz <- file.size(file.path(DATA, f))
  cat(sprintf("  %-45s %s\n", f, format(sz, big.mark=",")))
}
