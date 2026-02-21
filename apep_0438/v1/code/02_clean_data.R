###############################################################################
# 02_clean_data.R — Clean, merge, compute distances, construct analysis sample
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

cat("\n=== PHASE 2: DATA CLEANING ===\n\n")

# --- Load raw data -----------------------------------------------------------
votes_raw   <- readRDS(file.path(data_dir, "votes_raw.rds"))
gemeinde_sf <- readRDS(file.path(data_dir, "gemeinde_sf.rds"))
kanton_sf   <- readRDS(file.path(data_dir, "kanton_sf.rds"))

# ============================================================================
# 1. Standardize voting data
# ============================================================================
cat("Standardizing voting data...\n")

# swissdd returns: id, name, canton_id, canton_name, mun_id, mun_name,
#   jaStimmenInProzent, stimmbeteiligungInProzent, votedate, etc.

votes <- votes_raw %>%
  mutate(
    gem_id    = as.integer(mun_id),
    yes_share = jaStimmenInProzent / 100,
    turnout   = stimmbeteiligungInProzent / 100,
    vote_id   = id,
    vote_title = name,
    vote_year  = as.integer(format(votedate, "%Y")),
    KTNR = as.integer(canton_id)
  ) %>%
  filter(!is.na(yes_share), !is.na(gem_id))

cat("  Votes after standardization:", nrow(votes), "\n")
cat("  Unique votes:", n_distinct(votes$vote_id), "\n")
cat("  Date range:", as.character(range(votes$votedate, na.rm = TRUE)), "\n")
cat("  Cantons:", n_distinct(votes$KTNR), "\n")

# ============================================================================
# 2. Classify referendums as gender-related vs placebo
# ============================================================================
cat("\nClassifying referendums by gender relevance...\n")

votes <- votes %>%
  mutate(
    vote_title_lower = tolower(vote_title),
    gender_related = str_detect(
      vote_title_lower,
      paste0("(",
        paste(c(
          "mutterschaft", "vaterschaft", "elternurlaub", "elternzeit",
          "gleichstellung", "ehe für alle", "ehe fuer alle",
          "fristen", "schwangerschaftsabbruch", "abtreibung",
          "familie", "familieninitiative", "familienvorlage",
          "kinderbetreuung", "kinderkrippen",
          "adoption", "fortpflanzung", "fortpflanzungsmedizin"
        ), collapse = "|"),
        ")")
    ),
    topic_type = case_when(
      gender_related ~ "gender",
      str_detect(vote_title_lower,
                 "armee|militär|milit.r|waffen|verteidigung|wehrpflicht|kampfjet|gripen") ~ "military",
      str_detect(vote_title_lower,
                 "steuer|mwst|mehrwertsteuer|verrechnungssteuer|stempel") ~ "tax",
      str_detect(vote_title_lower,
                 "strasse|autobahn|eisenbahn|verkehr|gotthard|neat") ~ "transport",
      TRUE ~ "other"
    )
  )

n_gender <- n_distinct(votes$vote_id[votes$gender_related])
cat("  Gender-related votes:", n_gender, "unique referendums\n")
cat("  Military votes:", n_distinct(votes$vote_id[votes$topic_type == "military"]), "\n")
cat("  Tax votes:", n_distinct(votes$vote_id[votes$topic_type == "tax"]), "\n")

# Show gender referendum titles
gender_votes <- votes %>%
  filter(gender_related) %>%
  distinct(vote_id, vote_title, votedate) %>%
  arrange(votedate)
cat("\n  Gender referendums found:\n")
for (i in seq_len(min(nrow(gender_votes), 15))) {
  cat("    ", as.character(gender_votes$votedate[i]), ": ",
      substr(gender_votes$vote_title[i], 1, 60), "\n")
}

# ============================================================================
# 3. Prepare spatial data
# ============================================================================
cat("\nPreparing spatial data...\n")

# Compute Gemeinde centroids
gemeinde_centroids <- gemeinde_sf %>%
  mutate(
    centroid = st_centroid(geometry),
    area_km2 = as.numeric(st_area(geometry)) / 1e6
  )

# Add canton abbreviation and Landsgemeinde status
gemeinde_centroids <- gemeinde_centroids %>%
  mutate(KTNR = as.integer(KTNR)) %>%
  left_join(
    landsgemeinde_cantons %>% select(KTNR, canton_abbr, landsgemeinde, abolished_year),
    by = "KTNR"
  )

cat("  Gemeinden with Landsgemeinde info:",
    sum(!is.na(gemeinde_centroids$landsgemeinde)), "of",
    nrow(gemeinde_centroids), "\n")

# Show key cantons
for (ct in c("AI", "AR", "GL", "SG", "OW", "NW", "LU")) {
  n <- sum(gemeinde_centroids$canton_abbr == ct, na.rm = TRUE)
  cat("    ", ct, ":", n, "Gemeinden\n")
}

# ============================================================================
# 4. Define border pairs and compute distances
# ============================================================================
cat("\nDefining border pairs and computing distances...\n")

# Key border pairs: "control" has/had Landsgemeinde, "treated" never had / abolished
# Convention: signed_dist > 0 = NON-Landsgemeinde side
border_pairs <- list(
  "AR-AI" = list(no_lg = 15L, has_lg = 16L, name = "AR-AI"),
  "SG-AI" = list(no_lg = 17L, has_lg = 16L, name = "SG-AI"),
  "SG-GL" = list(no_lg = 17L, has_lg = 8L,  name = "SG-GL"),
  "LU-OW" = list(no_lg = 3L,  has_lg = 6L,  name = "LU-OW"),
  "LU-NW" = list(no_lg = 3L,  has_lg = 7L,  name = "LU-NW")
)

border_data <- list()

for (pair_name in names(border_pairs)) {
  pair <- border_pairs[[pair_name]]
  cat("  Processing border pair:", pair_name, "\n")

  pair_cantons <- c(pair$no_lg, pair$has_lg)
  pair_kanton_sf <- kanton_sf %>% filter(KTNR %in% pair_cantons)

  if (nrow(pair_kanton_sf) < 2) {
    cat("    WARNING: Missing canton polygon. Skipping.\n")
    next
  }

  # Extract shared border between the two cantons
  border_line <- tryCatch({
    k1 <- pair_kanton_sf %>% filter(KTNR == pair$no_lg)
    k2 <- pair_kanton_sf %>% filter(KTNR == pair$has_lg)

    # Check if they actually touch
    if (!st_touches(k1, k2, sparse = FALSE)[1, 1]) {
      cat("    Cantons don't touch! Trying intersects...\n")
      if (!st_intersects(k1, k2, sparse = FALSE)[1, 1]) {
        cat("    No intersection either. Skipping.\n")
        return(NULL)
      }
    }

    shared <- st_intersection(st_geometry(k1), st_geometry(k2))
    geom_type <- as.character(st_geometry_type(shared))

    if (geom_type %in% c("POLYGON", "MULTIPOLYGON")) {
      shared <- st_cast(st_boundary(shared), "MULTILINESTRING")
    } else if (geom_type == "GEOMETRYCOLLECTION") {
      # Extract lines from collection
      parts <- st_collection_extract(shared, type = "LINESTRING")
      if (length(parts) > 0) {
        shared <- st_union(parts)
      } else {
        # Try polygon extraction
        parts <- st_collection_extract(shared, type = "POLYGON")
        if (length(parts) > 0) {
          shared <- st_cast(st_boundary(st_union(parts)), "MULTILINESTRING")
        }
      }
    }

    st_set_crs(shared, st_crs(pair_kanton_sf))
  }, error = function(e) {
    cat("    Border extraction failed:", e$message, "\n")
    NULL
  })

  if (is.null(border_line) || st_is_empty(border_line)) {
    cat("    Empty border. Skipping.\n")
    next
  }

  # Get Gemeinden in this pair's cantons
  pair_gem <- gemeinde_centroids %>%
    filter(KTNR %in% pair_cantons) %>%
    mutate(
      dist_to_border = as.numeric(st_distance(centroid, border_line)) / 1000,
      # Positive = non-Landsgemeinde side
      signed_dist = ifelse(KTNR == pair$no_lg, dist_to_border, -dist_to_border),
      border_pair = pair_name,
      no_landsgemeinde = (KTNR == pair$no_lg)
    )

  border_data[[pair_name]] <- pair_gem %>% st_drop_geometry() %>%
    select(gem_id, name, KTNR, canton_abbr, landsgemeinde, abolished_year,
           dist_to_border, signed_dist, border_pair, no_landsgemeinde, area_km2)

  cat("    Gemeinden:", nrow(pair_gem),
      "(", sum(pair_gem$no_landsgemeinde), "no-LG,",
      sum(!pair_gem$no_landsgemeinde), "LG)\n")
  cat("    Distance range:", round(range(pair_gem$signed_dist), 1), "km\n")
}

# Combine all border pair Gemeinden
border_gemeinden <- bind_rows(border_data)
cat("\nTotal border Gemeinden:", nrow(border_gemeinden), "\n")
cat("  Unique Gemeinden:", n_distinct(border_gemeinden$gem_id), "\n")

# ============================================================================
# 5. Create analysis panel: Gemeinde × Referendum
# ============================================================================
cat("\nCreating Gemeinde × Referendum analysis panel...\n")

panel <- votes %>%
  inner_join(border_gemeinden, by = c("gem_id", "KTNR")) %>%
  filter(!is.na(yes_share), !is.na(signed_dist))

cat("  Panel observations:", nrow(panel), "\n")
cat("  Unique Gemeinden in panel:", n_distinct(panel$gem_id), "\n")
cat("  Unique referendums in panel:", n_distinct(panel$vote_id), "\n")

# ============================================================================
# 6. Create AR-AI specific DiDisc sample
# ============================================================================
cat("\nCreating AR-AI DiDisc sample...\n")

# AR abolished on April 27, 1997 (Landsgemeinde vote to abolish)
ar_ai_panel <- panel %>%
  filter(border_pair == "AR-AI") %>%
  mutate(
    post_abolition = (votedate >= as.Date("1997-04-27")),
    ar_side = (KTNR == 15L)
  )

cat("  AR-AI panel:", nrow(ar_ai_panel), "obs\n")
cat("  Pre-abolition:", sum(!ar_ai_panel$post_abolition), "\n")
cat("  Post-abolition:", sum(ar_ai_panel$post_abolition), "\n")
cat("  AR Gemeinden:", n_distinct(ar_ai_panel$gem_id[ar_ai_panel$ar_side]), "\n")
cat("  AI Gemeinden:", n_distinct(ar_ai_panel$gem_id[!ar_ai_panel$ar_side]), "\n")

# ============================================================================
# 7. Save cleaned data
# ============================================================================
saveRDS(border_gemeinden, file.path(data_dir, "border_gemeinden.rds"))
saveRDS(panel, file.path(data_dir, "panel.rds"))
saveRDS(ar_ai_panel, file.path(data_dir, "ar_ai_panel.rds"))
saveRDS(gemeinde_centroids, file.path(data_dir, "gemeinde_centroids.rds"))

cat("\n✓ Data cleaning complete\n")
