###############################################################################
# 01_fetch_data.R - Download referendum data, shapefiles, population stats
# Paper: Where Cultural Borders Cross (apep_0439)
###############################################################################

source("code/00_packages.R")

# ============================================================================
# 1. REFERENDUM DATA (swissdd)
# ============================================================================
cat("=== Fetching referendum data from swissdd ===\n")

# Check if votes_raw already exists (avoid re-downloading)
if (file.exists(file.path(data_dir, "votes_raw.rds"))) {
  cat("  votes_raw.rds already exists, skipping download\n")
  votes_raw <- readRDS(file.path(data_dir, "votes_raw.rds"))
  cat("  Loaded", nrow(votes_raw), "rows from cached data\n")
} else {
  # Fetch ALL federal referendums 1981-2024 at municipality level
  # Do this in chunks to avoid API timeouts
  years <- seq(1981, 2024, by = 5)
  all_votes <- list()

  for (i in seq_along(years)) {
    from <- paste0(years[i], "-01-01")
    to <- paste0(min(years[i] + 4, 2024), "-12-31")
    cat("  Fetching", from, "to", to, "...\n")

    chunk <- tryCatch({
      get_nationalvotes(from_date = from, to_date = to, geolevel = "municipality")
    }, error = function(e) {
      cat("  Error:", e$message, "\n")
      NULL
    })

    if (!is.null(chunk) && nrow(chunk) > 0) {
      all_votes[[i]] <- chunk
      cat("    Got", nrow(chunk), "rows\n")
    }

    Sys.sleep(2)  # Rate limit
  }

  votes_raw <- bind_rows(all_votes)
  cat("Total referendum rows:", nrow(votes_raw), "\n")
  cat("Unique vote dates:", length(unique(votes_raw$votedate)), "\n")
  cat("Unique municipalities:", length(unique(votes_raw$mun_id)), "\n")

  # Save raw referendum data
  saveRDS(votes_raw, file.path(data_dir, "votes_raw.rds"))
}

# ============================================================================
# 2. MUNICIPAL SHAPEFILES (BFS)
# ============================================================================
cat("\n=== Fetching municipal boundaries ===\n")

# Download Swiss municipality boundaries from BFS (skip if cached)
if (file.exists(file.path(data_dir, "municipalities_sf.rds"))) {
  cat("  municipalities_sf.rds already exists, skipping download\n")
} else {
boundaries_url <- "https://dam-api.bfs.admin.ch/hub/api/dam/assets/32507974/master"

tryCatch({
  temp_zip <- tempfile(fileext = ".zip")
  download.file(boundaries_url, temp_zip, mode = "wb", quiet = TRUE)
  temp_dir <- tempdir()
  unzip(temp_zip, exdir = temp_dir)

  # Look for the municipality shapefile
  shp_files <- list.files(temp_dir, pattern = "\\.shp$", recursive = TRUE, full.names = TRUE)
  cat("  Found shapefiles:", paste(basename(shp_files), collapse = ", "), "\n")

  # Read the municipality shapefile (look for "Gemeinde" or "gde" pattern)
  gde_shp <- shp_files[grepl("gde|gemeinde|polg|muni", shp_files, ignore.case = TRUE)]
  if (length(gde_shp) > 0) {
    municipalities_sf <- st_read(gde_shp[1], quiet = TRUE)
    cat("  Loaded", nrow(municipalities_sf), "municipality polygons\n")
    saveRDS(municipalities_sf, file.path(data_dir, "municipalities_sf.rds"))
  } else {
    cat("  WARNING: No municipality shapefile found in download\n")
    cat("  Available files:", paste(basename(shp_files), collapse = "\n  "), "\n")
  }
}, error = function(e) {
  cat("  BFS shapefile download error:", e$message, "\n")
  cat("  Will try alternative source...\n")
})

# Alternative: download from opendata.swiss if BFS direct fails
if (!file.exists(file.path(data_dir, "municipalities_sf.rds"))) {
  cat("  Trying opendata.swiss GeoJSON...\n")
  geo_url <- "https://data.geo.admin.ch/ch.bfs.generalisierte-grenzen_2024_v1/generalisierte-grenzen_2024_v1/generalisierte-grenzen_2024_v1_2056.geojson"
  tryCatch({
    municipalities_sf <- st_read(geo_url, quiet = TRUE)
    cat("  Loaded", nrow(municipalities_sf), "features from GeoJSON\n")
    saveRDS(municipalities_sf, file.path(data_dir, "municipalities_sf.rds"))
  }, error = function(e) {
    cat("  GeoJSON error:", e$message, "\n")
    # Final fallback: use Swiss cantonal boundaries only
    cat("  Will construct boundaries from available data\n")
  })
}
}  # end of else block (shapefile not cached)

# ============================================================================
# 3. LANGUAGE BORDER GEOMETRY
# ============================================================================
cat("\n=== Defining language and religion classifications ===\n")

# Historical cantonal confessional status (Reformation era, 16th century)
# Source: Well-documented historical fact
canton_religion <- tibble(
  canton_id = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
                17, 18, 19, 20, 21, 22, 23, 24, 25, 26),
  canton_abbr = c("ZH", "BE", "LU", "UR", "SZ", "OW", "NW", "GL", "ZG",
                  "FR", "SO", "BS", "BL", "SH", "AR", "AI", "SG", "GR",
                  "AG", "TG", "TI", "VD", "VS", "NE", "GE", "JU"),
  canton_name = c("Zürich", "Bern", "Luzern", "Uri", "Schwyz", "Obwalden",
                  "Nidwalden", "Glarus", "Zug", "Fribourg", "Solothurn",
                  "Basel-Stadt", "Basel-Landschaft", "Schaffhausen",
                  "Appenzell Ausserrhoden", "Appenzell Innerrhoden",
                  "St. Gallen", "Graubünden", "Aargau", "Thurgau",
                  "Ticino", "Vaud", "Valais", "Neuchâtel", "Geneva", "Jura"),
  # Historical confessional status (predetermined 16th century)
  hist_religion = c(
    "Protestant",  # ZH - Zwingli's reformation 1523
    "Protestant",  # BE - Reformed 1528
    "Catholic",    # LU - Remained Catholic
    "Catholic",    # UR - Catholic
    "Catholic",    # SZ - Catholic
    "Catholic",    # OW - Catholic
    "Catholic",    # NW - Catholic
    "Protestant",  # GL - Mixed, majority Protestant
    "Catholic",    # ZG - Catholic
    "Catholic",    # FR - Catholic (despite French language)
    "Mixed",       # SO - Complex history, mixed (exclude from main, classify Protestant in robustness)
    "Protestant",  # BS - Reformed 1529
    "Protestant",  # BL - Reformed
    "Protestant",  # SH - Reformed 1529
    "Protestant",  # AR - Protestant
    "Catholic",    # AI - Catholic
    "Mixed",       # SG - Mixed (Catholic majority; classify Catholic in robustness)
    "Mixed",       # GR - Mixed (Three Leagues; classify Protestant in robustness)
    "Mixed",       # AG - Mixed (Baden Catholic, former Bern Protestant; classify Protestant in robustness)
    "Mixed",       # TG - Mixed (Protestant majority; classify Protestant in robustness)
    "Catholic",    # TI - Catholic
    "Protestant",  # VD - Reformed (Bernese rule)
    "Catholic",    # VS - Catholic
    "Protestant",  # NE - Reformed
    "Protestant",  # GE - Calvin's reformation 1536
    "Catholic"     # JU - Catholic
  ),
  # Dominant language (from BFS official classification)
  dominant_language = c(
    "German", "German", "German", "German", "German", "German", "German",
    "German", "German", "French", "German", "German", "German", "German",
    "German", "German", "German", "German", "German", "German",
    "Italian", "French", "French", "French", "French", "French"
  )
)

# Note: For bilingual cantons (FR, BE, VS, GR), language is assigned at
# municipality level below, not at canton level.

saveRDS(canton_religion, file.path(data_dir, "canton_religion.rds"))

# ============================================================================
# 4. POPULATION STATISTICS (BFS)
# ============================================================================
cat("\n=== Fetching population statistics ===\n")

# Municipality-level controls are constructed from swissdd data (eligible voters, turnout)
# in 02_clean_data.R. BFS population data is not required for the main analysis.
cat("  Using eligible voters from swissdd as municipality size proxy\n")
cat("  Skipping BFS population download\n")

# ============================================================================
# 5. MARRIAGE / DIVORCE STATISTICS (BFS) - informational only
# ============================================================================
cat("\n=== Vital statistics (informational) ===\n")
cat("  Skipping vital statistics fetch (not needed for main analysis)\n")

# ============================================================================
# 6. SWISSVOTES DATASET (backup referendum metadata)
# ============================================================================
cat("\n=== Fetching Swissvotes metadata ===\n")

if (file.exists(file.path(data_dir, "swissvotes_metadata.rds"))) {
  cat("  swissvotes_metadata.rds already cached, skipping\n")
} else {
  tryCatch({
    sv_url <- "https://swissvotes.ch/page/dataset/swissvotes_dataset.csv"
    sv_data <- read_csv(sv_url, show_col_types = FALSE, locale = locale(encoding = "UTF-8"))
    cat("  Downloaded", nrow(sv_data), "referendum records\n")
    saveRDS(sv_data, file.path(data_dir, "swissvotes_metadata.rds"))
  }, error = function(e) {
    cat("  Swissvotes download error:", e$message, "\n")
  })
}

cat("\n=== DATA FETCH COMPLETE ===\n")
cat("Files in data directory:\n")
cat(paste("  ", list.files(data_dir), collapse = "\n"), "\n")
