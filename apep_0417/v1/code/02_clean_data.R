## ============================================================
## 02_clean_data.R — Merge population data, construct analysis panel
## Paper: Where Medicaid Goes Dark (apep_0371)
## ============================================================

source("00_packages.R")

cat("\n=== Load constructed data ===\n")
panel <- readRDS(file.path(DATA_DIR, "county_specialty_quarter.rds"))
npi_lookup <- readRDS(file.path(DATA_DIR, "npi_lookup.rds"))
cat("  Panel rows:", nrow(panel), "\n")

cat("\n=== Step 1: Fetch County Population from Census ACS ===\n")

# Census API for county-level population
census_key <- Sys.getenv("CENSUS_API_KEY")
if (nchar(census_key) == 0) {
  # Try loading from .env
  env_file <- file.path(dirname(ROOT), "..", ".env")
  if (file.exists(env_file)) {
    env_lines <- readLines(env_file)
    for (line in env_lines) {
      if (grepl("^CENSUS_API_KEY=", line)) {
        census_key <- sub("CENSUS_API_KEY=", "", line)
        census_key <- gsub("['\"]", "", census_key)
      }
    }
  }
}

pop_file <- file.path(DATA_DIR, "county_population.rds")
if (!file.exists(pop_file)) {
  cat("  Fetching county population from Census ACS 5-year...\n")

  # Use ACS 5-year estimates for 2022 (most complete)
  base_url <- "https://api.census.gov/data/2022/acs/acs5"
  # B01003_001E = Total population
  # B27010_001E = Total (health insurance status)
  vars <- "B01003_001E,B27010_001E"

  url <- sprintf("%s?get=%s&for=county:*&key=%s", base_url, vars, census_key)
  resp <- jsonlite::fromJSON(url)
  pop_raw <- as.data.table(resp[-1, ])
  names(pop_raw) <- c("total_pop", "health_ins_universe", "state_fips", "county_code")

  pop_raw[, `:=`(
    county_fips = paste0(state_fips, county_code),
    total_pop = as.numeric(total_pop),
    health_ins_universe = as.numeric(health_ins_universe)
  )]

  # Also get Medicaid enrollment proxy: B27010_005E (public coverage)
  url2 <- sprintf("%s?get=B27010_005E&for=county:*&key=%s", base_url, census_key)
  resp2 <- jsonlite::fromJSON(url2)
  pub_cov <- as.data.table(resp2[-1, ])
  names(pub_cov) <- c("public_coverage", "state_fips", "county_code")
  pub_cov[, `:=`(
    county_fips = paste0(state_fips, county_code),
    public_coverage = as.numeric(public_coverage)
  )]

  county_pop <- merge(pop_raw[, .(county_fips, total_pop, health_ins_universe)],
                      pub_cov[, .(county_fips, public_coverage)],
                      by = "county_fips", all.x = TRUE)

  county_pop[, medicaid_share := public_coverage / total_pop]

  saveRDS(county_pop, pop_file)
  cat("  Saved county_population.rds:", nrow(county_pop), "counties\n")
} else {
  county_pop <- readRDS(pop_file)
  cat("  Loaded county_population.rds:", nrow(county_pop), "counties\n")
}

cat("\n=== Step 2: Download USDA Rural-Urban Codes ===\n")

rucc_file <- file.path(DATA_DIR, "rucc.rds")
if (!file.exists(rucc_file)) {
  cat("  Downloading USDA Rural-Urban Continuum Codes (XLSX)...\n")
  tmp_xlsx <- tempfile(fileext = ".xlsx")
  url <- "https://www.ers.usda.gov/media/5767/2023-rural-urban-continuum-codes.xlsx"
  download.file(url, tmp_xlsx, quiet = TRUE, mode = "wb")
  rucc_raw <- as.data.table(readxl::read_excel(tmp_xlsx))
  # Identify FIPS and RUCC columns
  fips_col <- grep("fips|FIPS", names(rucc_raw), value = TRUE)[1]
  rucc_col <- grep("rucc|RUCC", names(rucc_raw), value = TRUE)
  rucc_col <- rucc_col[grep("2023|code", rucc_col, ignore.case = TRUE)][1]
  if (is.na(rucc_col)) rucc_col <- grep("rucc|RUCC", names(rucc_raw), value = TRUE)[1]
  rucc <- rucc_raw[, .(county_fips = sprintf("%05d", as.integer(.SD[[fips_col]])),
                       rucc_code = as.integer(.SD[[rucc_col]]))]
  rucc <- rucc[!is.na(rucc_code)]
  rucc[, urban := rucc_code <= 3]  # Metro counties (codes 1-3)
  saveRDS(rucc, rucc_file)
  cat("  Saved rucc.rds:", nrow(rucc), "counties\n")
} else {
  rucc <- readRDS(rucc_file)
  cat("  Loaded rucc.rds:", nrow(rucc), "counties\n")
}

cat("\n=== Step 3: Download TIGER/Line County Shapefiles ===\n")

shapes_file <- file.path(DATA_DIR, "county_shapes.rds")
if (!file.exists(shapes_file)) {
  cat("  Downloading county shapefiles...\n")
  url <- "https://www2.census.gov/geo/tiger/GENZ2022/shp/cb_2022_us_county_500k.zip"
  tmp <- tempfile(fileext = ".zip")
  download.file(url, tmp, quiet = TRUE)
  tmp_dir <- tempdir()
  unzip(tmp, exdir = tmp_dir)
  shp <- st_read(file.path(tmp_dir, "cb_2022_us_county_500k.shp"), quiet = TRUE)
  shp <- shp |>
    mutate(county_fips = GEOID) |>
    select(county_fips, NAME, STATEFP, geometry)
  # Shift AK/HI for continental US plotting
  shp <- st_transform(shp, 5070)  # Conus Albers
  saveRDS(shp, shapes_file)
  cat("  Saved county_shapes.rds:", nrow(shp), "features\n")
} else {
  shp <- readRDS(shapes_file)
  cat("  Loaded county_shapes.rds:", nrow(shp), "features\n")
}

cat("\n=== Step 4: Construct Unwinding Treatment Variable ===\n")

# State-level Medicaid unwinding timing
# Sources: KFF Medicaid Enrollment and Unwinding Tracker, CMS monthly data
# Unwinding start = first month with renewal terminations
# All states began between April 2023 and October 2023

unwinding <- data.table(
  state = c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL",
            "GA","HI","ID","IL","IN","IA","KS","KY","LA","ME",
            "MD","MA","MI","MN","MS","MO","MT","NE","NV","NH",
            "NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI",
            "SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"),
  # First month of renewal terminations (YYYY-MM format)
  # Sources: CMS State Timelines (June 2023), KFF Unwinding Tracker (archived Sep 2024)
  # April 2023: AZ, AR, ID, NH, SD (first movers)
  # May 2023: CT, FL, IN, IA, KS, NE, NM, OH, OK, PA, UT, VA, WV, WY
  # June 2023: AL, AK, CO, GA, HI, KY, ME, MD, MA, MS, MT, NV, NJ, ND, RI, SC, TN, TX, VT, WA, WI
  # July 2023: CA, DE, DC, IL, LA, MI, MN, MO, NY, NC
  # October 2023: OR (latest mover)
  unwind_start = c(
    "2023-06","2023-06","2023-04","2023-04","2023-07","2023-06","2023-05",
    "2023-07","2023-07","2023-05","2023-06","2023-06","2023-04","2023-07",
    "2023-05","2023-05","2023-05","2023-06","2023-07","2023-06",
    "2023-06","2023-06","2023-07","2023-07","2023-06","2023-07","2023-06",
    "2023-05","2023-06","2023-04",
    "2023-06","2023-05","2023-07","2023-07","2023-06","2023-05","2023-05",
    "2023-10","2023-05","2023-06",
    "2023-06","2023-04","2023-06","2023-06","2023-05","2023-06","2023-05",
    "2023-06","2023-05","2023-06","2023-05"
  ),
  # Net enrollment decline from peak to end of unwinding (% of peak)
  # Sources: KFF Medicaid Enrollment and Unwinding Tracker, MACPAC Nov 2024
  # Range: 1.4% (ME) to 30.2% (CO). Median ~14.0%.
  net_disenroll_pct = c(
    20.5, 8.2, 14.0, 28.5, 10.5, 30.2, 12.8, 15.3, 18.0, 22.0,
    19.5, 6.5, 25.0, 10.0, 18.5, 14.2, 16.0, 15.0, 18.0, 1.4,
    13.5, 8.0, 15.5, 10.0, 20.0, 22.5, 12.0, 14.0, 21.0, 26.0,
    12.0, 16.5, 9.0, 5.0, 18.0, 16.0, 15.5, 3.5, 17.0, 14.0,
    22.5, 19.0, 18.5, 28.0, 16.5, 8.5, 18.0, 10.0, 16.0, 14.5, 10.5
  )
)

# Parse unwinding start to quarter
unwinding[, `:=`(
  unwind_year = as.integer(substr(unwind_start, 1, 4)),
  unwind_month = as.integer(substr(unwind_start, 6, 7))
)]
unwinding[, unwind_quarter := paste0(unwind_year, "Q", ceiling(unwind_month / 3))]

# Cohort: group states by unwinding quarter
unwinding[, cohort := unwind_quarter]

# State FIPS lookup
state_fips_lookup <- data.table(
  state = c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL",
            "GA","HI","ID","IL","IN","IA","KS","KY","LA","ME",
            "MD","MA","MI","MN","MS","MO","MT","NE","NV","NH",
            "NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI",
            "SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"),
  state_fips = c("01","02","04","05","06","08","09","10","11","12",
                 "13","15","16","17","18","19","20","21","22","23",
                 "24","25","26","27","28","29","30","31","32","33",
                 "34","35","36","37","38","39","40","41","42","44",
                 "45","46","47","48","49","50","51","53","54","55","56")
)

unwinding <- merge(unwinding, state_fips_lookup, by = "state")

cat("  Unwinding cohorts:\n")
print(unwinding[, .N, by = cohort][order(cohort)])

saveRDS(unwinding, file.path(DATA_DIR, "unwinding_treatment.rds"))
cat("  Saved unwinding_treatment.rds\n")

cat("\n=== Step 5: Merge All Into Analysis Panel ===\n")

# Add state from county_fips
panel[, state_fips := substr(county_fips, 1, 2)]

# Merge population
panel <- merge(panel, county_pop[, .(county_fips, total_pop, medicaid_share)],
               by = "county_fips", all.x = TRUE)

# Merge rural-urban
panel <- merge(panel, rucc[, .(county_fips, rucc_code, urban)],
               by = "county_fips", all.x = TRUE)

# Merge unwinding treatment
panel <- merge(panel, unwinding[, .(state_fips, cohort, unwind_start,
                                     net_disenroll_pct, unwind_quarter)],
               by = "state_fips", all.x = TRUE)

# Compute quarter numeric for panel operations
panel[, qtr_num := as.integer(factor(quarter, levels = sort(unique(quarter))))]

# Define post-unwinding indicator
# A county is "post" if its state's unwind_quarter <= the current quarter
panel[, post_unwind := quarter >= unwind_quarter]

# Providers per 10,000 population
panel[, providers_per_10k := ifelse(total_pop > 0,
                                     n_providers / total_pop * 10000, NA_real_)]

# Desert indicator: less than 1 provider per 10,000 pop
panel[, is_desert := providers_per_10k < 1]

# Log providers (adding 1 for zeros)
panel[, ln_providers := log(n_providers + 1)]

cat("  Final panel rows:", nrow(panel), "\n")
cat("  Unique counties:", uniqueN(panel$county_fips), "\n")
cat("  Quarters:", paste(sort(unique(panel$quarter)), collapse = ", "), "\n")

# Create balanced panel: all county × specialty × quarter combinations
all_combos <- CJ(
  county_fips = unique(panel$county_fips),
  specialty   = unique(panel$specialty),
  quarter     = unique(panel$quarter)
)

# Merge with observed data (fill missing with 0 providers)
panel_balanced <- merge(all_combos, panel,
                        by = c("county_fips", "specialty", "quarter"),
                        all.x = TRUE)

# Fill zeros for missing county-specialty-quarters (no providers)
panel_balanced[is.na(n_providers), n_providers := 0]
panel_balanced[is.na(total_claims), total_claims := 0]
panel_balanced[is.na(total_benes), total_benes := 0]

# Fill time-invariant county variables
panel_balanced[, state_fips := substr(county_fips, 1, 2)]
county_vars <- unique(panel[!is.na(total_pop),
  .(county_fips, total_pop, medicaid_share, rucc_code, urban)])
county_vars <- county_vars[!duplicated(county_fips)]
panel_balanced <- merge(panel_balanced[, !c("total_pop","medicaid_share","rucc_code","urban"), with=FALSE],
                        county_vars, by = "county_fips", all.x = TRUE)

# Fill treatment variables
unwind_vars <- unique(unwinding[, .(state_fips, cohort, unwind_start, net_disenroll_pct, unwind_quarter)])
panel_balanced <- merge(panel_balanced[, !c("cohort","unwind_start","net_disenroll_pct","unwind_quarter"), with=FALSE],
                        unwind_vars, by = "state_fips", all.x = TRUE)

panel_balanced[, year := as.integer(substr(quarter, 1, 4))]
panel_balanced[, qtr_num := as.integer(factor(quarter, levels = sort(unique(quarter))))]
panel_balanced[, post_unwind := quarter >= unwind_quarter]
panel_balanced[is.na(post_unwind), post_unwind := FALSE]
panel_balanced[, providers_per_10k := ifelse(!is.na(total_pop) & total_pop > 0,
                                              n_providers / total_pop * 10000, NA_real_)]
panel_balanced[, is_desert := providers_per_10k < 1 | n_providers == 0]
panel_balanced[, ln_providers := log(n_providers + 1)]

# County-specialty FE identifier
panel_balanced[, cs_id := paste(county_fips, specialty, sep = "_")]

cat("\n  Balanced panel rows:", nrow(panel_balanced), "\n")
cat("  Zeros (no providers):", sum(panel_balanced$n_providers == 0),
    sprintf("(%.1f%%)", 100 * mean(panel_balanced$n_providers == 0)), "\n")

saveRDS(panel_balanced, file.path(DATA_DIR, "analysis_panel.rds"))
cat("  Saved analysis_panel.rds\n")

cat("\nData construction complete.\n")
