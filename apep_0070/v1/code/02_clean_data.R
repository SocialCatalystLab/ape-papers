# =============================================================================
# 02_clean_data.R - Data Cleaning and Spatial Setup
# Swiss Childcare Mandates and Maternal Labor Supply
# Spatial RDD at Canton Borders
# =============================================================================

library(tidyverse)
library(sf)

# Load data
data_dir <- "output/paper_94/data"
canton_treatment <- readRDS(file.path(data_dir, "canton_treatment.rds"))
gemeinde_sf <- readRDS(file.path(data_dir, "gemeinde_sf.rds"))

# Load voting data
family_2013 <- readRDS(file.path(data_dir, "family_2013.rds"))
maternity_2004 <- readRDS(file.path(data_dir, "maternity_2004.rds"))
childcare_2016 <- readRDS(file.path(data_dir, "childcare_2016.rds"))

message("=== INSPECTING DATA ===")
message(paste("Gemeinde sf columns:", paste(names(gemeinde_sf), collapse = ", ")))
message(paste("Family 2013 columns:", paste(names(family_2013)[1:10], collapse = ", ")))

# =============================================================================
# 1. Extract Canton from Voting Data (has canton_id)
# =============================================================================

message("\n=== EXTRACTING CANTON INFO FROM VOTING DATA ===")

# The voting data has canton_id - use this to map Gemeinden
voting_cantons <- family_2013 %>%
  select(mun_id, canton_id, canton_name) %>%
  distinct() %>%
  mutate(
    mun_id = as.integer(mun_id),
    canton_id = as.integer(canton_id)
  )

message(paste("Unique Gemeinden in voting data:", nrow(voting_cantons)))
message(paste("Canton IDs found:", paste(sort(unique(voting_cantons$canton_id)), collapse = ", ")))

# =============================================================================
# 2. Map Gemeinde Boundaries to Cantons
# =============================================================================

message("\n=== MAPPING GEMEINDE TO CANTONS ===")

# The gemeinde_sf 'id' column should be the BFS Gemeinde number
gemeinde_sf <- gemeinde_sf %>%
  mutate(
    mun_id = as.integer(id)
  )

# Join with voting data to get canton
gemeinde_sf <- gemeinde_sf %>%
  left_join(voting_cantons, by = "mun_id")

# How many matched?
matched <- sum(!is.na(gemeinde_sf$canton_id))
message(paste("Gemeinden matched to cantons:", matched, "of", nrow(gemeinde_sf)))

# For unmatched, try extracting canton from BFS number
# BFS numbers: KGGG where K = canton (1-26), GGG = Gemeinde within canton
# But this doesn't work for all - numbers changed with mergers

# Alternative: use centroid spatial join with known canton boundaries
# Since we don't have canton boundaries, let's use the matched subset

gemeinde_matched <- gemeinde_sf %>%
  filter(!is.na(canton_id))

message(paste("Using", nrow(gemeinde_matched), "matched Gemeinden"))

# =============================================================================
# 3. Add Treatment Status
# =============================================================================

message("\n=== ADDING TREATMENT STATUS ===")

gemeinde_matched <- gemeinde_matched %>%
  left_join(
    canton_treatment %>% select(canton_id, canton_abbr, treated, lang, adoption_year, treatment_cohort),
    by = "canton_id"
  )

message(paste("Treated Gemeinden:", sum(gemeinde_matched$treated, na.rm = TRUE)))
message(paste("Control Gemeinden:", sum(!gemeinde_matched$treated, na.rm = TRUE)))

# =============================================================================
# 4. Create Canton Boundaries by Aggregation
# =============================================================================

message("\n=== CREATING CANTON BOUNDARIES ===")

canton_sf <- gemeinde_matched %>%
  group_by(canton_id, canton_abbr, treated, lang) %>%
  summarise(geometry = st_union(geometry), .groups = "drop")

message(paste("Created boundaries for", nrow(canton_sf), "cantons"))

saveRDS(canton_sf, file.path(data_dir, "canton_sf.rds"))
message("Saved: canton_sf.rds")

# =============================================================================
# 5. Identify Border Pairs (Same-Language Only)
# =============================================================================

message("\n=== IDENTIFYING BORDER PAIRS ===")

# Key border pairs for spatial RDD (German-German borders)
# Treatment (2010): BE, ZH
# Control: AG, SO, SG, TG

border_pairs <- tribble(
  ~pair_name, ~treated_canton, ~control_canton, ~lang,
  "BE-SO",    "BE",            "SO",            "German",
  "ZH-AG",    "ZH",            "AG",            "German",
  "ZH-SG",    "ZH",            "SG",            "German",
  "ZH-TG",    "ZH",            "TG",            "German",
  "ZH-SZ",    "ZH",            "SZ",            "German",
  "ZH-ZG",    "ZH",            "ZG",            "German",
  "BE-LU",    "BE",            "LU",            "German",  # Note: LU later treated (2016)
  "GR-SG",    "GR",            "SG",            "German",
  "GR-GL",    "GR",            "GL",            "German"
)

# Identify which Gemeinden touch the border
message("Identifying border Gemeinden...")

# Compute neighbors
neighbors <- st_touches(gemeinde_matched)

# For each Gemeinde, find if it borders a different canton
gemeinde_matched <- gemeinde_matched %>%
  mutate(row_id = row_number())

border_gemeinden <- gemeinde_matched %>%
  mutate(
    neighbor_cantons = map(row_id, function(i) {
      neighbor_ids <- neighbors[[i]]
      if (length(neighbor_ids) == 0) return(character(0))
      unique(gemeinde_matched$canton_abbr[neighbor_ids])
    }),
    is_border = map2_lgl(neighbor_cantons, canton_abbr, function(nc, ca) {
      any(nc != ca)
    }),
    borders_treated = map2_lgl(neighbor_cantons, treated, function(nc, t) {
      # This Gemeinde is control and neighbors a 2010 treated canton
      if (t) return(FALSE)
      any(nc %in% c("BE", "ZH"))
    }),
    borders_control = pmap_lgl(list(neighbor_cantons, treated, canton_abbr), function(nc, t, ca) {
      # This Gemeinde is 2010 treated and neighbors a control canton
      if (!t || !(ca %in% c("BE", "ZH"))) return(FALSE)
      any(nc %in% c("AG", "SO", "SG", "TG", "SZ", "ZG", "GL", "AR", "AI"))
    }),
    # Treatment boundary indicator
    near_treatment_boundary = borders_treated | borders_control
  )

message(paste("Border Gemeinden (any canton):", sum(border_gemeinden$is_border, na.rm = TRUE)))
message(paste("Near treatment boundary:", sum(border_gemeinden$near_treatment_boundary, na.rm = TRUE)))

# =============================================================================
# 6. Compute Distance to Treatment Border
# =============================================================================

message("\n=== COMPUTING DISTANCE TO BORDER ===")

# Create the treatment boundary line
# Aggregate treated (2010) cantons
treated_union <- canton_sf %>%
  filter(canton_abbr %in% c("BE", "ZH")) %>%
  st_union()

# Aggregate control cantons (excluding French/Italian)
control_union <- canton_sf %>%
  filter(!treated | !(canton_abbr %in% c("BE", "ZH"))) %>%
  filter(lang == "German") %>%
  st_union()

# Find the boundary between treated and control
# This is the intersection of the boundaries
treatment_border <- st_intersection(
  st_boundary(treated_union),
  st_boundary(control_union)
)

message(paste("Treatment border length:", round(as.numeric(st_length(treatment_border)) / 1000, 1), "km"))

# Compute centroid for each Gemeinde
gemeinde_centroids <- gemeinde_matched %>%
  mutate(centroid = st_centroid(geometry))

# Compute distance to treatment border
# Positive = treated side, Negative = control side
gemeinde_matched <- gemeinde_matched %>%
  mutate(
    centroid = st_centroid(geometry),
    dist_to_border = as.numeric(st_distance(centroid, treatment_border)) / 1000,  # km
    distance_to_border = ifelse(
      canton_abbr %in% c("BE", "ZH"),
      dist_to_border,   # Treated side positive
      -dist_to_border   # Control side negative
    )
  )

message(paste("Distance range:", round(min(gemeinde_matched$distance_to_border, na.rm = TRUE), 1),
              "to", round(max(gemeinde_matched$distance_to_border, na.rm = TRUE), 1), "km"))

# =============================================================================
# 7. Merge Voting Data as Outcomes
# =============================================================================

message("\n=== MERGING VOTING OUTCOMES ===")

# Clean family 2013 vote (outcome)
family_2013_clean <- family_2013 %>%
  filter(str_detect(tolower(name), "familie|family|familien")) %>%
  select(mun_id, yes_share_2013 = jaStimmenInProzent, turnout_2013 = stimmbeteiligungInProzent) %>%
  mutate(mun_id = as.integer(mun_id))

if (nrow(family_2013_clean) > 0) {
  gemeinde_matched <- gemeinde_matched %>%
    left_join(family_2013_clean, by = "mun_id")
  message(paste("Merged family 2013 vote:", sum(!is.na(gemeinde_matched$yes_share_2013)), "Gemeinden"))
}

# Clean childcare 2016 vote (outcome)
childcare_2016_clean <- childcare_2016 %>%
  filter(str_detect(tolower(name), "kind|child|service")) %>%
  select(mun_id, yes_share_2016 = jaStimmenInProzent, turnout_2016 = stimmbeteiligungInProzent) %>%
  mutate(mun_id = as.integer(mun_id))

if (nrow(childcare_2016_clean) > 0) {
  gemeinde_matched <- gemeinde_matched %>%
    left_join(childcare_2016_clean, by = "mun_id")
  message(paste("Merged childcare 2016 vote:", sum(!is.na(gemeinde_matched$yes_share_2016)), "Gemeinden"))
}

# Clean maternity 2004 vote (pre-treatment)
maternity_2004_clean <- maternity_2004 %>%
  filter(str_detect(tolower(name), "mutter|maternity|maternité")) %>%
  select(mun_id, yes_share_2004 = jaStimmenInProzent, turnout_2004 = stimmbeteiligungInProzent) %>%
  mutate(mun_id = as.integer(mun_id))

if (nrow(maternity_2004_clean) > 0) {
  gemeinde_matched <- gemeinde_matched %>%
    left_join(maternity_2004_clean, by = "mun_id")
  message(paste("Merged maternity 2004 vote:", sum(!is.na(gemeinde_matched$yes_share_2004)), "Gemeinden"))
}

# =============================================================================
# 8. Create RDD Sample (German-German Borders Only)
# =============================================================================

message("\n=== CREATING RDD SAMPLE ===")

# Restrict to German-speaking cantons and reasonable distance from border
rdd_sample <- gemeinde_matched %>%
  filter(lang == "German") %>%
  filter(abs(distance_to_border) <= 30)  # Within 30km of border

message(paste("RDD sample size:", nrow(rdd_sample), "Gemeinden"))
message(paste("  Treated:", sum(rdd_sample$canton_abbr %in% c("BE", "ZH"), na.rm = TRUE)))
message(paste("  Control:", sum(!(rdd_sample$canton_abbr %in% c("BE", "ZH")), na.rm = TRUE)))

# =============================================================================
# 9. Save Final Datasets
# =============================================================================

message("\n=== SAVING FINAL DATASETS ===")

saveRDS(gemeinde_matched, file.path(data_dir, "gemeinde_matched.rds"))
message("Saved: gemeinde_matched.rds")

saveRDS(rdd_sample, file.path(data_dir, "rdd_sample.rds"))
message("Saved: rdd_sample.rds")

saveRDS(border_pairs, file.path(data_dir, "border_pairs.rds"))
message("Saved: border_pairs.rds")

# Save treatment border for plotting
saveRDS(treatment_border, file.path(data_dir, "treatment_border.rds"))
message("Saved: treatment_border.rds")

message("\n=== DATA CLEANING COMPLETE ===")

# Summary statistics
message("\n=== SUMMARY ===")
summary_stats <- rdd_sample %>%
  st_drop_geometry() %>%
  group_by(treated_side = canton_abbr %in% c("BE", "ZH")) %>%
  summarise(
    n = n(),
    mean_dist = mean(distance_to_border, na.rm = TRUE),
    mean_yes_2013 = mean(yes_share_2013, na.rm = TRUE),
    mean_yes_2016 = mean(yes_share_2016, na.rm = TRUE),
    mean_yes_2004 = mean(yes_share_2004, na.rm = TRUE)
  )
print(summary_stats)
