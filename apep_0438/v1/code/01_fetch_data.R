###############################################################################
# 01_fetch_data.R — Fetch voting, spatial, and covariate data
# Paper: Secret Ballots and Women's Political Voice (apep_0438)
###############################################################################

# Source packages from same directory
script_args <- commandArgs(trailingOnly = FALSE)
script_path <- grep("--file=", script_args, value = TRUE)
if (length(script_path) > 0) {
  script_dir_local <- dirname(normalizePath(sub("--file=", "", script_path)))
} else {
  script_dir_local <- getwd()
}
source(file.path(script_dir_local, "00_packages.R"))

cat("\n=== PHASE 1: DATA ACQUISITION ===\n\n")

# ============================================================================
# 1. Federal referendum results at Gemeinde level (1981–2024)
# ============================================================================
cat("Fetching federal referendum results from swissdd...\n")

# swissdd::get_nationalvotes fetches from BFS official API
# geolevel = "municipality" gives Gemeinde-level results
votes_raw <- tryCatch({
  get_nationalvotes(
    from_date = "1981-01-01",
    to_date   = "2025-01-01",
    geolevel  = "municipality"
  )
}, error = function(e) {
  cat("  swissdd API error:", e$message, "\n")
  cat("  Trying direct JSON fetch as fallback...\n")
  NULL
})

if (is.null(votes_raw) || nrow(votes_raw) == 0) {
  stop("FATAL: Could not fetch referendum data. Cannot proceed.")
}

cat("  Fetched", nrow(votes_raw), "Gemeinde-referendum observations\n")
cat("  Unique referendums:", length(unique(votes_raw$id)), "\n")
cat("  Date range:", as.character(range(votes_raw$votedate)), "\n")

# Save raw voting data
saveRDS(votes_raw, file.path(data_dir, "votes_raw.rds"))
cat("  Saved: votes_raw.rds\n")

# ============================================================================
# 2. Gemeinde spatial boundaries (polygons)
# ============================================================================
cat("\nFetching Gemeinde boundaries from BFS...\n")

# Try multiple approaches for spatial data
gemeinde_sf <- tryCatch({
  bfs_get_base_maps(geom = "polg")
}, error = function(e) {
  cat("  bfs_get_base_maps failed:", e$message, "\n")
  cat("  Trying ThemaKart approach...\n")
  tryCatch({
    # Alternative: download from geo.admin.ch
    url <- "https://data.geo.admin.ch/ch.bfs.generalisierte-grenzen/generalisierte-grenzen_2024_2056/generalisierte-grenzen_2024_2056.gpkg"
    tmp <- tempfile(fileext = ".gpkg")
    download.file(url, tmp, mode = "wb", quiet = TRUE)
    layers <- st_layers(tmp)$name
    polg_layer <- layers[grepl("polg|gem|municipality", layers, ignore.case = TRUE)][1]
    if (is.na(polg_layer)) polg_layer <- layers[1]
    st_read(tmp, layer = polg_layer, quiet = TRUE)
  }, error = function(e2) {
    cat("  geo.admin.ch fallback also failed:", e2$message, "\n")
    NULL
  })
})

if (is.null(gemeinde_sf) || nrow(gemeinde_sf) == 0) {
  stop("FATAL: Could not fetch Gemeinde boundaries. Cannot proceed.")
}

cat("  Loaded", nrow(gemeinde_sf), "Gemeinde polygons\n")
cat("  CRS:", st_crs(gemeinde_sf)$epsg, "\n")

# Ensure CRS is LV95 (EPSG:2056) for proper distance calculations
if (!is.na(st_crs(gemeinde_sf)$epsg) && st_crs(gemeinde_sf)$epsg != 2056) {
  gemeinde_sf <- st_transform(gemeinde_sf, 2056)
  cat("  Transformed to EPSG:2056 (LV95)\n")
}

saveRDS(gemeinde_sf, file.path(data_dir, "gemeinde_sf.rds"))
cat("  Saved: gemeinde_sf.rds\n")

# ============================================================================
# 3. Get canton boundaries and derive Gemeinde→Canton mapping
# ============================================================================
cat("\nGetting canton boundaries and Gemeinde-Canton mapping...\n")

# bfs_get_base_maps only returns id+name. Derive canton from voting data.
# The swissdd voting data has canton_id per Gemeinde — use that as our mapping.
gem_canton_map <- votes_raw %>%
  select(any_of(c("mun_id", "gdenr", "bfs_nr", "id",
                   "canton_id", "kt_nr", "canton"))) %>%
  distinct()

# Identify the gem_id and canton columns
gem_col_v <- intersect(names(gem_canton_map), c("mun_id", "gdenr", "bfs_nr"))
kt_col_v  <- intersect(names(gem_canton_map), c("canton_id", "kt_nr", "canton"))

if (length(gem_col_v) > 0 && length(kt_col_v) > 0) {
  gem_canton_map <- gem_canton_map %>%
    rename(gem_id = !!sym(gem_col_v[1]), KTNR = !!sym(kt_col_v[1])) %>%
    mutate(gem_id = as.integer(gem_id), KTNR = as.integer(KTNR)) %>%
    select(gem_id, KTNR) %>%
    distinct() %>%
    # Keep most common canton per Gemeinde (in case of canton changes)
    group_by(gem_id) %>%
    slice_max(n = 1, order_by = KTNR, with_ties = FALSE) %>%
    ungroup()

  cat("  Mapped", nrow(gem_canton_map), "Gemeinden to cantons from voting data\n")
} else {
  cat("  Voting data columns:", paste(names(gem_canton_map), collapse = ", "), "\n")
  # Fallback: derive canton from BFS municipality number
  # BFS numbering: canton is encoded in the municipality number
  bfs_canton_ranges <- tibble::tribble(
    ~KTNR, ~min_id, ~max_id,
    1L,    1,    299,     # ZH
    2L,  301,    999,     # BE
    3L, 1001,   1199,     # LU
    4L, 1201,   1299,     # UR
    5L, 1301,   1399,     # SZ
    6L, 1401,   1409,     # OW
    7L, 1501,   1599,     # NW
    8L, 1601,   1699,     # GL
    9L, 1701,   1799,     # ZG
   10L, 2001,   2399,     # FR
   11L, 2401,   2699,     # SO
   12L, 2701,   2799,     # BS
   13L, 2801,   2899,     # BL
   14L, 2901,   2999,     # SH
   15L, 3001,   3099,     # AR (Ausserrhoden)
   16L, 3101,   3199,     # AI (Innerrhoden)
   17L, 3201,   3499,     # SG
   18L, 3501,   3999,     # GR
   19L, 4001,   4299,     # AG
   20L, 4401,   4699,     # TG
   21L, 5001,   5399,     # TI
   22L, 5401,   5999,     # VD
   23L, 6001,   6299,     # VS
   24L, 6401,   6599,     # NE
   25L, 6601,   6699,     # GE
   26L, 6701,   6799      # JU
  )

  gem_canton_map <- gemeinde_sf %>%
    st_drop_geometry() %>%
    rename(gem_id = id) %>%
    rowwise() %>%
    mutate(KTNR = {
      match <- bfs_canton_ranges %>% filter(gem_id >= min_id, gem_id <= max_id)
      if (nrow(match) > 0) match$KTNR[1] else NA_integer_
    }) %>%
    ungroup() %>%
    select(gem_id, KTNR) %>%
    filter(!is.na(KTNR))

  cat("  Mapped", nrow(gem_canton_map), "Gemeinden to cantons from BFS ranges\n")
}

# Join canton to Gemeinde sf — ensure type compatibility
gemeinde_sf <- gemeinde_sf %>%
  rename(gem_id = id) %>%
  mutate(gem_id = as.integer(gem_id))
gem_canton_map <- gem_canton_map %>% mutate(gem_id = as.integer(gem_id))

gemeinde_sf <- gemeinde_sf %>%
  left_join(gem_canton_map, by = "gem_id")

cat("  Gemeinden with canton (from voting data):", sum(!is.na(gemeinde_sf$KTNR)), "of", nrow(gemeinde_sf), "\n")

# Fill missing KTNR using BFS municipality number ranges
# This catches municipalities whose IDs changed (e.g., GL mergers in 2011)
bfs_canton_ranges <- tibble::tribble(
  ~KTNR, ~min_id, ~max_id,
  1L,    1,    299,     # ZH
  2L,  301,    999,     # BE
  3L, 1001,   1199,     # LU
  4L, 1201,   1299,     # UR
  5L, 1301,   1399,     # SZ
  6L, 1401,   1409,     # OW
  7L, 1501,   1599,     # NW
  8L, 1601,   1699,     # GL
  9L, 1701,   1799,     # ZG
 10L, 2001,   2399,     # FR
 11L, 2401,   2699,     # SO
 12L, 2701,   2799,     # BS
 13L, 2801,   2899,     # BL
 14L, 2901,   2999,     # SH
 15L, 3001,   3099,     # AR (Ausserrhoden)
 16L, 3101,   3199,     # AI (Innerrhoden)
 17L, 3201,   3499,     # SG
 18L, 3501,   3999,     # GR
 19L, 4001,   4299,     # AG
 20L, 4401,   4699,     # TG
 21L, 5001,   5399,     # TI
 22L, 5401,   5999,     # VD
 23L, 6001,   6299,     # VS
 24L, 6401,   6599,     # NE
 25L, 6601,   6699,     # GE
 26L, 6701,   6799      # JU
)

missing_mask <- is.na(gemeinde_sf$KTNR)
if (sum(missing_mask) > 0) {
  for (i in which(missing_mask)) {
    gid <- gemeinde_sf$gem_id[i]
    match <- bfs_canton_ranges %>% filter(gid >= min_id, gid <= max_id)
    if (nrow(match) > 0) gemeinde_sf$KTNR[i] <- match$KTNR[1]
  }
  cat("  After BFS range fallback:", sum(!is.na(gemeinde_sf$KTNR)), "of", nrow(gemeinde_sf), "\n")
}

# Create canton boundaries by dissolving Gemeinde polygons
kanton_sf <- gemeinde_sf %>%
  filter(!is.na(KTNR)) %>%
  group_by(KTNR) %>%
  summarise(geometry = st_union(geometry), .groups = "drop")

cat("  Created", nrow(kanton_sf), "canton polygons\n")

# Re-save with KTNR included
saveRDS(gemeinde_sf, file.path(data_dir, "gemeinde_sf.rds"))
saveRDS(kanton_sf, file.path(data_dir, "kanton_sf.rds"))
cat("  Saved: gemeinde_sf.rds, kanton_sf.rds\n")

# ============================================================================
# 4. Municipality inventory mapping (SMMT) for merger harmonization
# ============================================================================
cat("\nFetching municipality merger mapping from SMMT...\n")

# Map pre-merger Gemeinde IDs to current IDs
# This is critical: GL went from 25 to 3 Gemeinden in 2011
merger_map <- tryCatch({
  mapping <- map_old_to_new_state(
    old_state_date = "1981-01-01",
    new_state_date = "2024-01-01"
  )
  cat("  Mapped", nrow(mapping), "old → new municipality pairs\n")
  mapping
}, error = function(e) {
  cat("  SMMT mapping failed:", e$message, "\n")
  cat("  Will handle mergers manually if needed\n")
  NULL
})

if (!is.null(merger_map)) {
  saveRDS(merger_map, file.path(data_dir, "merger_map.rds"))
  cat("  Saved: merger_map.rds\n")
}

# ============================================================================
# 5. Population data (covariates) from BFS
# ============================================================================
cat("\nFetching Gemeinde-level population data from BFS...\n")

pop_data <- tryCatch({
  # BFS catalog search for population by Gemeinde
  catalog <- bfs_get_catalog_data(language = "en")
  pop_entries <- catalog %>%
    filter(str_detect(tolower(title), "population|bevölkerung|einwohner")) %>%
    filter(str_detect(tolower(title), "gemeinde|municipal|commune"))

  if (nrow(pop_entries) > 0) {
    cat("  Found", nrow(pop_entries), "population datasets\n")
    # Try to download the most relevant one
    pop <- tryCatch({
      bfs_get_data(
        number_bfs = pop_entries$number_bfs[1],
        language = "en"
      )
    }, error = function(e) {
      cat("  Could not download population data:", e$message, "\n")
      NULL
    })
    pop
  } else {
    cat("  No population datasets found in catalog\n")
    NULL
  }
}, error = function(e) {
  cat("  BFS catalog search failed:", e$message, "\n")
  NULL
})

if (!is.null(pop_data)) {
  saveRDS(pop_data, file.path(data_dir, "pop_data.rds"))
  cat("  Saved: pop_data.rds\n")
} else {
  cat("  Will use Gemeinde polygon area as fallback covariate\n")
}

# ============================================================================
# Summary
# ============================================================================
cat("\n=== DATA ACQUISITION SUMMARY ===\n")
cat("  Referendum data:   ", ifelse(exists("votes_raw"), paste(nrow(votes_raw), "obs"), "MISSING"), "\n")
cat("  Gemeinde polygons: ", ifelse(exists("gemeinde_sf"), paste(nrow(gemeinde_sf), "polygons"), "MISSING"), "\n")
cat("  Canton polygons:   ", ifelse(exists("kanton_sf"), paste(nrow(kanton_sf), "cantons"), "MISSING"), "\n")
cat("  Merger mapping:    ", ifelse(!is.null(merger_map), paste(nrow(merger_map), "pairs"), "MISSING"), "\n")
cat("  Population data:   ", ifelse(!is.null(pop_data), "OK", "MISSING (will use fallback)"), "\n")
cat("\n✓ Data acquisition complete\n")
