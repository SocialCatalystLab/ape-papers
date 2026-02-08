# =============================================================================
# 01_fetch_data.R - Gemeinde-Level Panel Data Acquisition
# Swiss Cantonal Energy Laws and Federal Referendum Voting
# Spatial RDD at Canton Borders
# =============================================================================

# Get script directory for portable sourcing
get_this_script_dir <- function() {
  for (i in seq_len(sys.nframe())) {
    if (!is.null(sys.frame(i)$ofile)) {
      return(dirname(sys.frame(i)$ofile))
    }
  }
  return(getwd())
}
script_dir <- get_this_script_dir()
source(file.path(script_dir, "00_packages.R"))

# data_dir is now set by 00_packages.R
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

# -----------------------------------------------------------------------------
# 1. Fetch Gemeinde-Level Voting Data
# -----------------------------------------------------------------------------

message("=== FETCHING GEMEINDE-LEVEL VOTING DATA ===")

# Energy Strategy 2050 referendum - May 21, 2017
message("\n1. Energy Strategy 2050 (May 2017)...")
energy_vote <- get_nationalvotes(
  from_date = "2017-05-01",
  to_date = "2017-05-31",
  geolevel = "municipality"
)

message(paste("   Got", nrow(energy_vote), "gemeinde observations"))

# Clean and standardize
energy_df <- energy_vote %>%
  select(
    mun_id,
    mun_name,
    canton_id,
    canton_name,
    yes_share = jaStimmenInProzent,
    yes_votes = jaStimmenAbsolut,
    no_votes = neinStimmenAbsolut,
    turnout = stimmbeteiligungInProzent,
    eligible_voters = anzahlStimmberechtigte,
    votedate
  ) %>%
  mutate(
    mun_id = as.integer(mun_id),
    canton_id = as.integer(canton_id),
    vote_type = "energy_2017"
  )

# Also fetch earlier energy-related votes for pre-trends
message("\n2. Fetching additional votes for panel/pre-trends...")

# Nuclear moratorium initiative - November 27, 2016
nuclear_2016 <- get_nationalvotes(
  from_date = "2016-11-01",
  to_date = "2016-11-30",
  geolevel = "municipality"
) %>%
  filter(str_detect(tolower(name), "atomausstieg|nuclear|atom"))

if (nrow(nuclear_2016) > 0) {
  message(paste("   Nuclear 2016:", nrow(nuclear_2016), "obs"))
}

# Green economy initiative - September 25, 2016
green_2016 <- get_nationalvotes(
  from_date = "2016-09-01",
  to_date = "2016-09-30",
  geolevel = "municipality"
) %>%
  filter(str_detect(tolower(name), "grüne|green|economy"))

if (nrow(green_2016) > 0) {
  message(paste("   Green economy 2016:", nrow(green_2016), "obs"))
}

# Clean additional votes
clean_vote <- function(df, vote_type) {
  if (nrow(df) == 0) return(NULL)
  df %>%
    select(
      mun_id,
      mun_name,
      canton_id,
      canton_name,
      yes_share = jaStimmenInProzent,
      yes_votes = jaStimmenAbsolut,
      no_votes = neinStimmenAbsolut,
      turnout = stimmbeteiligungInProzent,
      eligible_voters = anzahlStimmberechtigte,
      votedate
    ) %>%
    mutate(
      mun_id = as.integer(mun_id),
      canton_id = as.integer(canton_id),
      vote_type = vote_type
    )
}

nuclear_df <- clean_vote(nuclear_2016, "nuclear_2016")
green_df <- clean_vote(green_2016, "green_2016")

# Combine into panel
panel_df <- bind_rows(energy_df, nuclear_df, green_df) %>%
  arrange(mun_id, votedate)

message(paste("\n   Total panel observations:", nrow(panel_df)))

# -----------------------------------------------------------------------------
# 2. Define Treatment: Cantonal Energy Law Adoption
# -----------------------------------------------------------------------------

message("\n=== DEFINING TREATMENT ===")

# Cantonal comprehensive energy laws enacted BEFORE May 21, 2017
# Source: LexFind.ch + HuggingFace swiss_legislation
canton_treatment <- tribble(
  ~canton_id, ~canton_abbr, ~adoption_year, ~entry_force_date, ~treated,
  # Treated (energy law in force before May 2017)
  18, "GR", 2010, "2011-01-01", TRUE,   # Graubünden
  2,  "BE", 2011, "2012-01-01", TRUE,   # Bern
  19, "AG", 2012, "2013-01-01", TRUE,   # Aargau
  13, "BL", 2016, "2016-07-01", TRUE,   # Basel-Landschaft
  12, "BS", 2016, "2017-01-01", TRUE,   # Basel-Stadt
  # Control cantons (no comprehensive energy law before vote)
  1,  "ZH", NA, NA, FALSE,
  3,  "LU", 2017, "2018-01-01", FALSE,  # Adopted AFTER vote
  4,  "UR", NA, NA, FALSE,
  5,  "SZ", NA, NA, FALSE,
  6,  "OW", NA, NA, FALSE,
  7,  "NW", NA, NA, FALSE,
  8,  "GL", NA, NA, FALSE,
  9,  "ZG", NA, NA, FALSE,
  10, "FR", 2019, "2020-01-01", FALSE,  # Adopted after vote
  11, "SO", NA, NA, FALSE,
  14, "SH", NA, NA, FALSE,
  15, "AR", NA, NA, FALSE,
  16, "AI", 2020, "2021-01-01", FALSE,  # Adopted after vote
  17, "SG", NA, NA, FALSE,
  20, "TG", NA, NA, FALSE,
  21, "TI", NA, NA, FALSE,
  22, "VD", NA, NA, FALSE,
  23, "VS", NA, NA, FALSE,
  24, "NE", NA, NA, FALSE,
  25, "GE", NA, NA, FALSE,
  26, "JU", NA, NA, FALSE
)

# Add language region
canton_treatment <- canton_treatment %>%
  mutate(
    lang = case_when(
      canton_abbr %in% c("GE", "VD", "NE", "JU") ~ "French",
      canton_abbr %in% c("FR", "VS") ~ "French",  # Simplified - majority French
      canton_abbr == "TI" ~ "Italian",
      TRUE ~ "German"
    )
  )

message("Treated cantons:")
print(canton_treatment %>% filter(treated) %>% select(canton_abbr, adoption_year))

# -----------------------------------------------------------------------------
# 3. Fetch Gemeinde Boundaries (for Spatial RDD)
# -----------------------------------------------------------------------------

message("\n=== FETCHING SPATIAL DATA ===")

# Get municipal boundaries from BFS
message("1. Downloading gemeinde boundaries from BFS...")
gemeinde_sf <- tryCatch({
  bfs_get_base_maps(geom = "polg", category = "gf", date = "2017-01-01")
}, error = function(e) {
  message("   BFS failed, trying swisstopo...")
  NULL
})

# Fallback: Try multiple sources for boundaries
if (is.null(gemeinde_sf)) {
  message("   Attempting alternative boundary sources...")

  # Try opendata.swiss API
  tryCatch({
    # SwissBoundaries from opendata.swiss
    api_url <- "https://data.geo.admin.ch/ch.swisstopo.swissboundaries3d/swissboundaries3d_2025-01/swissboundaries3d_2025-01_2056_5728.gpkg.zip"
    temp_zip <- tempfile(fileext = ".zip")
    download.file(api_url, temp_zip, mode = "wb", quiet = TRUE, timeout = 120)
    temp_dir <- tempdir()
    unzip(temp_zip, exdir = temp_dir)
    gpkg_files <- list.files(temp_dir, pattern = "\\.gpkg$", full.names = TRUE, recursive = TRUE)
    if (length(gpkg_files) > 0) {
      layers <- st_layers(gpkg_files[1])
      # Find gemeinde layer
      gem_layer <- layers$name[grepl("gemeinde|municipality|hoheitsgebiet", layers$name, ignore.case = TRUE)]
      if (length(gem_layer) > 0) {
        gemeinde_sf <- st_read(gpkg_files[1], layer = gem_layer[1], quiet = TRUE)
        message(paste("   Loaded", nrow(gemeinde_sf), "gemeinde boundaries from geopackage"))
      }
    }
  }, error = function(e) {
    message(paste("   Alternative source failed:", e$message))
  })
}

# If still no spatial data, proceed without it
if (!exists("gemeinde_sf") || is.null(gemeinde_sf)) {
  message("   Spatial boundaries not available - will use non-spatial analysis")
  gemeinde_sf <- NULL
}

# Get canton boundaries for border identification
message("2. Downloading canton boundaries...")
canton_sf <- tryCatch({
  bfs_get_base_maps(geom = "polg", category = "kf", date = "2017-01-01")
}, error = function(e) NULL)

if (is.null(canton_sf)) {
  # Aggregate gemeinde to cantons if we have gemeinde boundaries
  if (!is.null(gemeinde_sf) && "KTNR" %in% names(gemeinde_sf)) {
    canton_sf <- gemeinde_sf %>%
      group_by(KTNR) %>%
      summarise() %>%  # Let sf handle geometry union automatically
      ungroup()
  }
}

# -----------------------------------------------------------------------------
# 4. Merge Voting Data with Spatial Data
# -----------------------------------------------------------------------------

message("\n=== MERGING DATA ===")

# Merge treatment status
voting_data <- energy_df %>%
  left_join(canton_treatment %>% select(canton_id, canton_abbr, treated, lang, adoption_year),
            by = "canton_id")

message(paste("   Treated gemeinden:", sum(voting_data$treated)))
message(paste("   Control gemeinden:", sum(!voting_data$treated)))

# Merge with spatial data if available
if (!is.null(gemeinde_sf)) {
  # Match on gemeinde ID - try various column names
  id_col <- names(gemeinde_sf)[str_detect(names(gemeinde_sf), "GMDNR|BFS_NR|mun_id|GDENR|bfs_nummer")]

  if (length(id_col) > 0) {
    voting_sf <- gemeinde_sf %>%
      rename(mun_id = all_of(id_col[1])) %>%
      mutate(mun_id = as.integer(mun_id)) %>%
      left_join(voting_data, by = "mun_id")

    message(paste("   Spatial merge successful:", nrow(voting_sf), "gemeinden"))
    message(paste("   Matched with voting data:", sum(!is.na(voting_sf$yes_share)), "gemeinden"))
  } else {
    message("   Warning: Could not find gemeinde ID column")
    message(paste("   Available columns:", paste(names(gemeinde_sf), collapse = ", ")))
    voting_sf <- NULL
  }
} else {
  voting_sf <- NULL
}

# -----------------------------------------------------------------------------
# 5. Identify Border Gemeinden
# -----------------------------------------------------------------------------

message("\n=== IDENTIFYING BORDER GEMEINDEN ===")

# Key border pairs for spatial RDD
# Treatment cantons: GR, BE, AG, BL, BS
# Adjacent control cantons for each:
border_pairs <- list(
  "AG-ZH" = c(19, 1),   # Aargau (T) - Zürich (C)
  "AG-LU" = c(19, 3),   # Aargau (T) - Luzern (C)
  "AG-SO" = c(19, 11),  # Aargau (T) - Solothurn (C)
  "BE-SO" = c(2, 11),   # Bern (T) - Solothurn (C)
  "BE-LU" = c(2, 3),    # Bern (T) - Luzern (C)
  "BE-FR" = c(2, 10),   # Bern (T) - Fribourg (C)
  "GR-SG" = c(18, 17),  # Graubünden (T) - St. Gallen (C)
  "GR-GL" = c(18, 8),   # Graubünden (T) - Glarus (C)
  "GR-UR" = c(18, 4),   # Graubünden (T) - Uri (C)
  "BL-SO" = c(13, 11),  # Basel-Land (T) - Solothurn (C)
  "BS-BL" = c(12, 13)   # Basel-Stadt (T) - Basel-Land (T) - not usable
)

# Remove BS-BL since both are treated
border_pairs <- border_pairs[names(border_pairs) != "BS-BL"]

if (!is.null(voting_sf) && !is.null(canton_sf)) {
  # Identify gemeinden that touch canton borders
  message("   Finding gemeinden near canton borders...")

  # Add canton number to gemeinden if not present
  if (!"KTNR" %in% names(voting_sf)) {
    ktnr_col <- names(voting_sf)[str_detect(names(voting_sf), "KTNR|canton")]
    if (length(ktnr_col) > 0) {
      voting_sf <- voting_sf %>% rename(KTNR = all_of(ktnr_col[1]))
    }
  }

  # Find neighbors
  neighbors <- st_touches(voting_sf)

  border_gemeinden <- voting_sf %>%
    mutate(
      neighbor_cantons = map(row_number(), function(i) {
        unique(voting_sf$canton_id[neighbors[[i]]])
      }),
      is_border = map_lgl(neighbor_cantons, function(nc) {
        any(nc != canton_id)
      }),
      border_with_treated = map_lgl(neighbor_cantons, function(nc) {
        # This gemeinde is control, neighbor is treated (or vice versa)
        any(nc %in% c(2, 12, 13, 18, 19)) != treated
      })
    )

  message(paste("   Border gemeinden (treatment discontinuity):",
                sum(border_gemeinden$border_with_treated, na.rm = TRUE)))

  saveRDS(border_gemeinden, file.path(data_dir, "border_gemeinden.rds"))
}

# -----------------------------------------------------------------------------
# 6. Save All Data
# -----------------------------------------------------------------------------

message("\n=== SAVING DATA ===")

saveRDS(voting_data, file.path(data_dir, "voting_data.rds"))
saveRDS(panel_df, file.path(data_dir, "panel_data.rds"))
saveRDS(canton_treatment, file.path(data_dir, "canton_treatment.rds"))

if (!is.null(voting_sf)) {
  saveRDS(voting_sf, file.path(data_dir, "voting_sf.rds"))
}
if (!is.null(gemeinde_sf)) {
  saveRDS(gemeinde_sf, file.path(data_dir, "gemeinde_boundaries.rds"))
}
if (!is.null(canton_sf)) {
  saveRDS(canton_sf, file.path(data_dir, "canton_boundaries.rds"))
}

message("\n=== DATA SUMMARY ===")
message(paste("Total gemeinden:", nrow(voting_data)))
message(paste("  Treated:", sum(voting_data$treated)))
message(paste("  Control:", sum(!voting_data$treated)))
message(paste("\nMean Yes share (treated):", round(mean(voting_data$yes_share[voting_data$treated]), 2), "%"))
message(paste("Mean Yes share (control):", round(mean(voting_data$yes_share[!voting_data$treated]), 2), "%"))
message(paste("Raw difference:", round(mean(voting_data$yes_share[voting_data$treated]) -
                                        mean(voting_data$yes_share[!voting_data$treated]), 2), "pp"))
