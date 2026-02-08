# =============================================================================
# 01_fetch_data.R - Data Acquisition
# Swiss Childcare Mandates and Maternal Labor Supply
# Spatial RDD at Canton Borders
# =============================================================================

library(tidyverse)
library(sf)
library(BFS)
library(swissdd)

# Output paths
data_dir <- "output/paper_94/data"
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

# =============================================================================
# 1. Define Treatment Status by Canton
# =============================================================================

message("=== DEFINING TREATMENT STATUS ===")

# Cantons with childcare mandates and adoption timing
# Source: Cantonal Volksschulgesetz via LexFind
canton_treatment <- tribble(
  ~canton_id, ~canton_abbr, ~canton_name, ~adoption_year, ~entry_force_date, ~treated,
  # Treated cantons (childcare mandate before 2017)
  2,  "BE", "Bern",         2010, "2010-08-01", TRUE,
  1,  "ZH", "Zurich",       2010, "2010-08-01", TRUE,
  12, "BS", "Basel-Stadt",  2014, "2014-08-01", TRUE,
  18, "GR", "Graubünden",   2014, "2014-08-01", TRUE,
  3,  "LU", "Lucerne",      2016, "2016-08-01", TRUE,
  24, "NE", "Neuchâtel",    2015, "2015-08-01", TRUE,  # French
  14, "SH", "Schaffhausen", 2016, "2016-08-01", TRUE,

  # Control cantons (no comprehensive mandate before 2017)
  19, "AG", "Aargau",       NA, NA, FALSE,
  11, "SO", "Solothurn",    NA, NA, FALSE,
  17, "SG", "St. Gallen",   NA, NA, FALSE,
  20, "TG", "Thurgau",      NA, NA, FALSE,
  4,  "UR", "Uri",          NA, NA, FALSE,
  5,  "SZ", "Schwyz",       NA, NA, FALSE,
  9,  "ZG", "Zug",          NA, NA, FALSE,
  6,  "OW", "Obwalden",     NA, NA, FALSE,
  7,  "NW", "Nidwalden",    NA, NA, FALSE,
  8,  "GL", "Glarus",       NA, NA, FALSE,
  15, "AR", "Appenzell AR", NA, NA, FALSE,
  16, "AI", "Appenzell IR", NA, NA, FALSE,
  13, "BL", "Basel-Land",   NA, NA, FALSE,
  10, "FR", "Fribourg",     NA, NA, FALSE,
  21, "TI", "Ticino",       NA, NA, FALSE,
  22, "VD", "Vaud",         NA, NA, FALSE,
  23, "VS", "Valais",       NA, NA, FALSE,
  25, "GE", "Geneva",       NA, NA, FALSE,
  26, "JU", "Jura",         NA, NA, FALSE
)

# Add language region
canton_treatment <- canton_treatment %>%
  mutate(
    lang = case_when(
      canton_abbr %in% c("GE", "VD", "NE", "JU") ~ "French",
      canton_abbr %in% c("FR", "VS") ~ "French",
      canton_abbr == "TI" ~ "Italian",
      TRUE ~ "German"
    ),
    treatment_cohort = case_when(
      adoption_year == 2010 ~ "Early (2010)",
      adoption_year %in% 2014:2016 ~ "Late (2014-16)",
      TRUE ~ "Never"
    )
  )

saveRDS(canton_treatment, file.path(data_dir, "canton_treatment.rds"))
message("Saved: canton_treatment.rds")

# =============================================================================
# 2. Fetch Gemeinde Boundaries
# =============================================================================

message("\n=== FETCHING SPATIAL DATA ===")

# Get municipal boundaries from BFS
message("1. Downloading Gemeinde boundaries...")
gemeinde_sf <- tryCatch({
  bfs_get_base_maps(geom = "polg", category = "gf")
}, error = function(e) {
  message(paste("   BFS download failed:", e$message))
  NULL
})

if (!is.null(gemeinde_sf)) {
  message(paste("   Downloaded", nrow(gemeinde_sf), "Gemeinden"))

  # The gemeinde_sf has 'id' and 'name' columns
  # We need to map to canton - extract from the ID (first 2 digits often = canton)
  # OR use spatial join with canton boundaries

  # Try alternative: download with canton info
  gemeinde_sf2 <- tryCatch({
    bfs_get_base_maps(geom = "polg", category = "gk")  # gk = Gemeinde with Kanton
  }, error = function(e) NULL)

  if (!is.null(gemeinde_sf2) && "KTNR" %in% names(gemeinde_sf2)) {
    gemeinde_sf <- gemeinde_sf2
    message("   Using dataset with canton info")
  }

  saveRDS(gemeinde_sf, file.path(data_dir, "gemeinde_sf.rds"))
  message("   Saved: gemeinde_sf.rds")
}

# Get canton boundaries by aggregating from Gemeinde
message("\n2. Creating canton boundaries...")
if (!is.null(gemeinde_sf)) {
  # If we have canton IDs, aggregate
  if ("KTNR" %in% names(gemeinde_sf)) {
    canton_sf <- gemeinde_sf %>%
      group_by(KTNR) %>%
      summarise(geometry = st_union(geometry), .groups = "drop") %>%
      rename(canton_id = KTNR) %>%
      left_join(canton_treatment %>% select(canton_id, canton_abbr, treated, lang),
                by = "canton_id")
    saveRDS(canton_sf, file.path(data_dir, "canton_sf.rds"))
    message("   Saved: canton_sf.rds")
  } else {
    message("   Warning: No canton ID in Gemeinde data, skipping canton boundaries")
  }
}

# =============================================================================
# 3. Fetch Voting Data for Outcomes/Pre-Trends
# =============================================================================

message("\n=== FETCHING VOTING DATA ===")

# Get family-related referendum votes using swissdd
# These can serve as attitude outcomes or pre-trend checks

# 2013 Family initiative vote
message("1. Fetching 2013 family initiative vote...")
family_2013 <- tryCatch({
  get_nationalvotes(
    from_date = "2013-03-01",
    to_date = "2013-03-31",
    geolevel = "municipality"
  )
}, error = function(e) {
  message(paste("   Failed:", e$message))
  NULL
})

if (!is.null(family_2013) && nrow(family_2013) > 0) {
  message(paste("   Downloaded", nrow(family_2013), "observations"))
  saveRDS(family_2013, file.path(data_dir, "family_2013.rds"))
}

# 2004 Maternity insurance vote (pre-period)
message("2. Fetching 2004 maternity insurance vote...")
maternity_2004 <- tryCatch({
  get_nationalvotes(
    from_date = "2004-09-01",
    to_date = "2004-09-30",
    geolevel = "municipality"
  )
}, error = function(e) {
  message(paste("   Failed:", e$message))
  NULL
})

if (!is.null(maternity_2004) && nrow(maternity_2004) > 0) {
  message(paste("   Downloaded", nrow(maternity_2004), "observations"))
  saveRDS(maternity_2004, file.path(data_dir, "maternity_2004.rds"))
}

# 2016 childcare initiative vote (post-period outcome)
message("3. Fetching 2016 childcare vote...")
childcare_2016 <- tryCatch({
  get_nationalvotes(
    from_date = "2016-02-01",
    to_date = "2016-02-29",
    geolevel = "municipality"
  )
}, error = function(e) {
  message(paste("   Failed:", e$message))
  NULL
})

if (!is.null(childcare_2016) && nrow(childcare_2016) > 0) {
  message(paste("   Downloaded", nrow(childcare_2016), "observations"))
  saveRDS(childcare_2016, file.path(data_dir, "childcare_2016.rds"))
}

# =============================================================================
# 4. Summary
# =============================================================================

message("\n=== DATA SUMMARY ===")
message(paste("Treated cantons:", paste(canton_treatment %>% filter(treated) %>% pull(canton_abbr), collapse = ", ")))
message(paste("Control cantons:", paste(canton_treatment %>% filter(!treated) %>% pull(canton_abbr), collapse = ", ")))
message(paste("Files saved to:", data_dir))

# List saved files
message("\nSaved files:")
for (f in list.files(data_dir, pattern = "\\.rds$")) {
  size <- file.info(file.path(data_dir, f))$size / 1024
  message(sprintf("  - %s (%.1f KB)", f, size))
}

message("\n=== DATA ACQUISITION COMPLETE ===")
