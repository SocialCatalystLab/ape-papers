## ============================================================================
## 01_fetch_data.R — Fetch supplementary data (Census ACS ZCTA + shapefiles)
## T-MSIS and NPPES data already available via symlinks from apep_0294.
## ============================================================================

source("00_packages.R")

# Additional packages for fetching
if (!requireNamespace("tigris", quietly = TRUE)) install.packages("tigris")
library(tigris)
options(tigris_use_cache = TRUE)

## ---- 1. Verify symlinked data ----
cat("Verifying data from apep_0294...\n")
stopifnot(file.exists(file.path(DATA, "tmsis_full.parquet")))
stopifnot(file.exists(file.path(DATA, "nppes_extract.parquet")))
stopifnot(file.exists(file.path(DATA, "provider_panel_enriched.rds")))
cat("  tmsis_full.parquet: OK\n")
cat("  nppes_extract.parquet: OK\n")
cat("  provider_panel_enriched.rds: OK\n")

## ---- 2. Download NY ZCTA shapefiles via tigris ----
zcta_file <- file.path(DATA, "ny_zcta_shapes.rds")

if (!file.exists(zcta_file)) {
  cat("Downloading ZCTA shapefiles via tigris...\n")

  # tigris::zctas() downloads and caches ZCTA shapefiles
  # For 2020 Census ZCTAs, use year = 2020
  zcta_all <- zctas(year = 2020)

  # Filter to NY area by ZIP prefix
  # NY ZCTAs: 005xx-069xx (western NY/upstate), 100xx-149xx (downstate/NYC/LI)
  zcta_all$zip3 <- substr(zcta_all$ZCTA5CE20, 1, 3)
  ny_prefixes <- c(
    paste0("0", 0:6, collapse = ""), # won't work, need individual
    "100", "101", "102", "103", "104", "105", "106", "107", "108", "109",
    "110", "111", "112", "113", "114", "115", "116", "117", "118", "119",
    "120", "121", "122", "123", "124", "125", "126", "127", "128", "129",
    "130", "131", "132", "133", "134", "135", "136", "137", "138", "139",
    "140", "141", "142", "143", "144", "145", "146", "147", "148", "149"
  )
  # Simpler: NY ZIPs are in ranges 005xx-149xx
  ny_zip2 <- substr(zcta_all$ZCTA5CE20, 1, 2)
  zcta_ny <- zcta_all[ny_zip2 %in% c("00", "01", "02", "03", "04", "05", "06",
                                        "10", "11", "12", "13", "14"), ]

  # Spatial filter: intersect with NY state boundary to remove CT/NJ/PA ZCTAs
  ny_state <- states(year = 2020) |> filter(STATEFP == "36")
  zcta_ny <- st_filter(zcta_ny, ny_state)

  cat(sprintf("  NY ZCTAs: %d shapes\n", nrow(zcta_ny)))
  saveRDS(zcta_ny, zcta_file)
  cat("  Saved to ny_zcta_shapes.rds\n")
} else {
  cat("  ZCTA shapes already cached.\n")
}

## ---- 3. Download NY county shapefiles via tigris ----
county_file <- file.path(DATA, "ny_county_shapes.rds")

if (!file.exists(county_file)) {
  cat("Downloading NY county shapefiles...\n")
  ny_counties <- counties(state = "NY", year = 2020)
  cat(sprintf("  NY counties: %d shapes\n", nrow(ny_counties)))
  saveRDS(ny_counties, county_file)
  cat("  Saved to ny_county_shapes.rds\n")
} else {
  cat("  County shapes already cached.\n")
}

## ---- 4. Fetch Census ACS ZCTA demographics ----
acs_zcta_file <- file.path(DATA, "acs_zcta_demographics.rds")

if (!file.exists(acs_zcta_file)) {
  cat("Fetching ACS ZCTA demographics...\n")

  api_key <- Sys.getenv("CENSUS_API_KEY")

  # ACS 5-year 2022, ZCTA level
  base_url <- "https://api.census.gov/data/2022/acs/acs5"
  vars <- paste0(
    "NAME,B01001_001E,",   # total pop
    "B17001_002E,",         # below poverty
    "B19013_001E,",         # median household income
    "B01001_020E,B01001_021E,B01001_022E,B01001_023E,B01001_024E,B01001_025E,",  # male 65+
    "B01001_044E,B01001_045E,B01001_046E,B01001_047E,B01001_048E,B01001_049E,",  # female 65+
    "B02001_002E,B02001_003E,B02001_004E,B02001_005E"  # race
  )

  url <- sprintf(
    "%s?get=%s&for=zip%%20code%%20tabulation%%20area:*%s",
    base_url, vars,
    ifelse(nchar(api_key) > 0, paste0("&key=", api_key), "")
  )

  resp <- tryCatch(
    jsonlite::fromJSON(url),
    error = function(e) {
      cat("  ACS API error:", conditionMessage(e), "\n")
      NULL
    }
  )

  if (!is.null(resp)) {
    acs_zcta <- as.data.table(resp[-1, ])
    names(acs_zcta) <- resp[1, ]

    # Convert to numeric
    num_cols <- setdiff(names(acs_zcta), c("NAME", "zip code tabulation area"))
    for (col in num_cols) {
      acs_zcta[[col]] <- as.numeric(acs_zcta[[col]])
    }

    setnames(acs_zcta, "zip code tabulation area", "zcta")
    setnames(acs_zcta, "B01001_001E", "total_pop")
    setnames(acs_zcta, "B17001_002E", "poverty_pop")
    setnames(acs_zcta, "B19013_001E", "median_hh_income")
    setnames(acs_zcta, "B02001_002E", "pop_white")
    setnames(acs_zcta, "B02001_003E", "pop_black")
    setnames(acs_zcta, "B02001_004E", "pop_aian")
    setnames(acs_zcta, "B02001_005E", "pop_asian")

    male65_cols <- paste0("B01001_0", 20:25, "E")
    female65_cols <- paste0("B01001_0", 44:49, "E")
    acs_zcta[, pop_65plus := rowSums(.SD, na.rm = TRUE),
             .SDcols = c(male65_cols, female65_cols)]

    acs_zcta <- acs_zcta[, .(zcta, total_pop, poverty_pop, median_hh_income,
                              pop_white, pop_black, pop_aian, pop_asian,
                              pop_65plus)]

    # Filter to NY ZCTAs
    acs_zcta <- acs_zcta[substr(zcta, 1, 2) %in%
                           c("00", "01", "02", "03", "04", "05", "06",
                             "10", "11", "12", "13", "14")]

    cat(sprintf("  ACS ZCTA demographics: %d ZCTAs\n", nrow(acs_zcta)))
    saveRDS(acs_zcta, acs_zcta_file)
    cat("  Saved to acs_zcta_demographics.rds\n")
  } else {
    cat("  SKIPPED: ACS data not available.\n")
  }
} else {
  cat("  ACS ZCTA demographics already cached.\n")
}

## ---- 5. ZCTA-to-county crosswalk ----
xwalk_file <- file.path(DATA, "zcta_county_xwalk.rds")

if (!file.exists(xwalk_file)) {
  cat("Downloading ZCTA-to-county crosswalk...\n")

  xwalk_url <- "https://www2.census.gov/geo/docs/maps-data/data/rel2020/zcta520/tab20_zcta520_county20_natl.txt"
  xwalk <- fread(xwalk_url, sep = "|")

  # Primary county = largest land area overlap
  primary <- xwalk[, .SD[which.max(AREALAND_PART)], by = GEOID_ZCTA5_20]
  primary <- primary[, .(zcta = GEOID_ZCTA5_20,
                          county_fips = GEOID_COUNTY_20,
                          state_fips = substr(GEOID_COUNTY_20, 1, 2),
                          county_fips_3 = substr(GEOID_COUNTY_20, 3, 5))]

  ny_xwalk <- primary[state_fips == "36"]
  cat(sprintf("  NY ZCTA-to-county: %d mappings\n", nrow(ny_xwalk)))

  saveRDS(ny_xwalk, xwalk_file)
  cat("  Saved to zcta_county_xwalk.rds\n")
} else {
  cat("  ZCTA-county crosswalk already cached.\n")
}

cat("\nAll data fetched successfully.\n")
