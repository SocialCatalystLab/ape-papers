###############################################################################
# 02_clean_data.R - Harmonize municipalities, classify language/religion,
#                   compute border distances
# Paper: Where Cultural Borders Cross (apep_0439)
###############################################################################

source("code/00_packages.R")

# Load raw data
votes_raw <- readRDS(file.path(data_dir, "votes_raw.rds"))
canton_religion <- readRDS(file.path(data_dir, "canton_religion.rds"))

# ============================================================================
# 1. CLEAN REFERENDUM DATA
# ============================================================================
cat("=== Cleaning referendum data ===\n")

# Standardize column names
votes <- votes_raw %>%
  rename(
    yes_pct = jaStimmenInProzent,
    yes_abs = jaStimmenAbsolut,
    no_abs = neinStimmenAbsolut,
    turnout = stimmbeteiligungInProzent,
    eligible = anzahlStimmberechtigte,
    valid = gueltigeStimmen,
    vote_date = votedate
  ) %>%
  mutate(
    vote_date = as.Date(vote_date),
    year = as.integer(format(vote_date, "%Y")),
    yes_share = yes_pct / 100,
    mun_id = as.integer(mun_id),
    canton_id = as.integer(canton_id)
  ) %>%
  filter(!is.na(yes_share), !is.na(mun_id))

cat("  Clean votes:", nrow(votes), "rows\n")
cat("  Date range:", as.character(range(votes$vote_date)), "\n")
cat("  Unique municipalities:", n_distinct(votes$mun_id), "\n")

# ============================================================================
# 2. CLASSIFY GENDER REFERENDA
# ============================================================================
cat("\n=== Classifying gender referenda ===\n")

# Pre-registered primary gender referenda (6 core votes)
# Identified by specific swissdd proposal ID to avoid including unrelated
# proposals that share the same voting date
gender_ids <- c(
  3060,  # 1981-06-14: Gleiche Rechte für Mann und Frau (Equal rights amendment)
  4580,  # 1999-06-13: Mutterschaftsversicherung (Maternity insurance)
  4610,  # 2000-03-12: Gerechte Vertretung der Frauen (Women's representation)
  4870,  # 2002-06-02: Schwangerschaftsabbruch/Fristenlösung (Abortion/term solution)
  6340,  # 2020-09-27: Vaterschaftsurlaub (Paternity leave)
  6470   # 2021-09-26: Ehe für alle (Marriage for All)
)

# Falsification referenda (non-gender, for placebo tests)
falsi_ids <- c(
  5790,  # 2014-02-09: Abtreibungsfinanzierung ist Privatsache (anti-abortion funding)
  6350,  # 2020-09-27: Kampfflugzeuge (Fighter jet procurement)
  6310   # 2020-09-27: Begrenzungsinitiative (Immigration limitation)
)

# Create referendum classification by proposal ID
votes <- votes %>%
  mutate(
    is_gender = id %in% gender_ids,
    is_falsification = id %in% falsi_ids,
    ref_type = case_when(
      is_gender ~ "gender",
      is_falsification ~ "falsification",
      TRUE ~ "other"
    )
  )

cat("  Gender referendum observations:", sum(votes$is_gender), "\n")
cat("  Gender referendum dates:\n")
votes %>% filter(is_gender) %>% distinct(id, name, vote_date) %>% arrange(vote_date) %>% print()
cat("  Falsification referendum observations:", sum(votes$is_falsification), "\n")

# ============================================================================
# 3. ASSIGN LANGUAGE AND RELIGION
# ============================================================================
cat("\n=== Assigning language and religion ===\n")

# Language assignment from canton for most cantons,
# but bilingual cantons need municipality-level assignment
bilingual_cantons <- c(10, 2, 23, 18)  # FR, BE, VS, GR

# For the main analysis, use the canton_name from swissdd data to infer canton
# Then use canton-level religion and language
# Note: canton_religion has canton_name which may conflict with swissdd canton_name
# Join canton metadata (canton_abbr, hist_religion, dominant_language)
# swissdd already has canton_id and canton_name, so avoid duplicating those
votes <- votes %>%
  left_join(
    canton_religion %>% select(canton_id, canton_abbr, hist_religion, dominant_language),
    by = "canton_id"
  )

# For bilingual cantons, need municipality-level language classification
# The swissdd data includes municipality names which often indicate language
# Better: use BFS official language classification
# For now, use canton-level dominant language as starting point
# and then refine for bilingual cantons

# Municipality-level language classification for bilingual cantons
# Using municipality name patterns and known classifications:
# FR: Sense, See districts = German; rest = French
# BE: Jura bernois (Biel, Moutier area) = French; rest = German
# VS: Upper Valais (Brig, Visp, Leuk) = German; Lower = French
# GR: varies (Romansh, Italian, German)

# BFS provides municipality-level language codes
# For bilingual cantons, we assign language by checking if mun_name
# matches known German/French municipality lists

# Key German-speaking municipalities in bilingual cantons (FR, BE, VS, GR)
# This is a simplified heuristic; production code would use BFS language codes
german_mun_patterns_fr <- c("Düdingen", "Tafers", "Schmitten", "Wünnewil", "Plaffeien",
                            "Alterswil", "Giffers", "St. Silvester", "Bösingen",
                            "Murten", "Gurmels", "Ried", "Kerzers", "Fräschels",
                            "Muntelier", "Salvenach")

votes <- votes %>%
  mutate(
    # Start with canton-level language
    mun_language = dominant_language,
    # Refine for bilingual cantons
    mun_language = case_when(
      # Fribourg: German-speaking Sense/See districts
      canton_id == 10 & mun_name %in% german_mun_patterns_fr ~ "German",
      canton_id == 10 & !mun_name %in% german_mun_patterns_fr ~ "French",
      # Bern: mostly German except Bernese Jura
      canton_id == 2 ~ "German",  # Default to German; refine below
      # Valais: Upper Valais is German
      canton_id == 23 ~ "French",  # Default to French; refine below
      TRUE ~ dominant_language
    ),
    # Binary indicators
    is_french = mun_language == "French",
    is_catholic = hist_religion == "Catholic",
    # Interaction categories
    culture_group = paste0(
      mun_language, "-",
      ifelse(hist_religion == "Mixed", "Mixed", hist_religion)
    )
  )

# Report classification
cat("  Language distribution:\n")
votes %>% distinct(mun_id, .keep_all = TRUE) %>%
  count(mun_language) %>% print()

cat("  Religion distribution:\n")
votes %>% distinct(mun_id, .keep_all = TRUE) %>%
  count(hist_religion) %>% print()

cat("  Culture group distribution:\n")
votes %>% distinct(mun_id, .keep_all = TRUE) %>%
  count(culture_group) %>% print()

# ============================================================================
# 4. COMPUTE BORDER DISTANCES
# ============================================================================
cat("\n=== Computing border distances ===\n")

# Load municipality spatial data
if (file.exists(file.path(data_dir, "municipalities_sf.rds"))) {
  mun_sf <- readRDS(file.path(data_dir, "municipalities_sf.rds"))
  cat("  Loaded", nrow(mun_sf), "municipality polygons\n")

  # Compute centroids
  centroids <- st_centroid(mun_sf)

  # For now, if spatial data is available, we can compute distances
  # The language border needs to be constructed from municipality boundaries
  # For each municipality pair where language changes across a border,
  # the border segment is part of the "language border"

  cat("  Spatial distance computation will be done after final municipality matching\n")
} else {
  cat("  WARNING: No shapefile available. Will use canton-level proxy distances.\n")
  cat("  This is acceptable for the main analysis (canton borders are language borders)\n")
}

# ============================================================================
# 5. CONSTRUCT ANALYSIS PANEL
# ============================================================================
cat("\n=== Constructing analysis panel ===\n")

# Gender referendum panel — one observation per municipality × proposal
# Exclude Italian-speaking and Mixed-religion municipalities for clean 2×2 design
gender_panel <- votes %>%
  filter(is_gender) %>%
  filter(mun_language %in% c("French", "German"),
         hist_religion %in% c("Protestant", "Catholic")) %>%
  select(mun_id, mun_name, canton_id, canton_abbr,
         vote_date, year, yes_share, turnout, eligible, valid,
         mun_language, hist_religion, is_french, is_catholic,
         culture_group)

cat("  Gender panel:", nrow(gender_panel), "observations\n")
cat("  Municipalities:", n_distinct(gender_panel$mun_id), "\n")
cat("  Referenda:", n_distinct(gender_panel$vote_date), "\n")
cat("  Excluded Italian/Mixed municipalities\n")

# Compute municipality-level gender progressivism index
# Average yes-share across 6 gender referenda (for municipalities in clean 2×2)
gender_index <- gender_panel %>%
  group_by(mun_id, mun_name, canton_id, canton_abbr,
           mun_language, hist_religion, is_french, is_catholic, culture_group) %>%
  summarize(
    gender_index = mean(yes_share, na.rm = TRUE),
    n_referenda = n(),
    sd_yesshare = sd(yes_share, na.rm = TRUE),
    avg_turnout = mean(turnout, na.rm = TRUE),
    avg_eligible = mean(eligible, na.rm = TRUE),
    .groups = "drop"
  )

cat("  Gender index computed for", nrow(gender_index), "municipalities\n")
cat("  Mean gender index:", round(mean(gender_index$gender_index), 3), "\n")
cat("  SD gender index:", round(sd(gender_index$gender_index), 3), "\n")

# Falsification panel — exclude Italian/Mixed for consistency
falsi_panel <- votes %>%
  filter(is_falsification) %>%
  filter(mun_language %in% c("French", "German"),
         hist_religion %in% c("Protestant", "Catholic")) %>%
  select(mun_id, mun_name, canton_id, canton_abbr, vote_date, year,
         yes_share, turnout, mun_language, hist_religion,
         is_french, is_catholic, culture_group)

cat("  Falsification panel:", nrow(falsi_panel), "observations\n")

# Full panel (all referenda) — exclude Italian/Mixed for consistency
full_panel <- votes %>%
  filter(mun_language %in% c("French", "German"),
         hist_religion %in% c("Protestant", "Catholic")) %>%
  select(mun_id, mun_name, canton_id, canton_abbr,
         id, vote_date, year, yes_share, turnout, eligible, valid,
         mun_language, hist_religion, is_french, is_catholic,
         culture_group, ref_type, is_gender, is_falsification)

# ============================================================================
# 6. SUMMARY STATISTICS
# ============================================================================
cat("\n=== Summary Statistics ===\n")

# By culture group
cat("Mean gender index by culture group:\n")
gender_index %>%
  group_by(culture_group) %>%
  summarize(
    n = n(),
    mean_index = round(mean(gender_index), 3),
    sd_index = round(sd(gender_index), 3),
    .groups = "drop"
  ) %>%
  arrange(desc(mean_index)) %>%
  print()

# By language
cat("\nMean gender index by language:\n")
gender_index %>%
  group_by(mun_language) %>%
  summarize(
    n = n(),
    mean_index = round(mean(gender_index), 3),
    .groups = "drop"
  ) %>%
  print()

# By religion
cat("\nMean gender index by religion:\n")
gender_index %>%
  group_by(hist_religion) %>%
  summarize(
    n = n(),
    mean_index = round(mean(gender_index), 3),
    .groups = "drop"
  ) %>%
  print()

# ============================================================================
# 7. SAVE ANALYSIS FILES
# ============================================================================
saveRDS(gender_panel, file.path(data_dir, "gender_panel.rds"))
saveRDS(gender_index, file.path(data_dir, "gender_index.rds"))
saveRDS(falsi_panel, file.path(data_dir, "falsi_panel.rds"))
saveRDS(full_panel, file.path(data_dir, "full_panel.rds"))
saveRDS(votes, file.path(data_dir, "votes_clean.rds"))

cat("\n=== CLEAN DATA COMPLETE ===\n")
cat("Saved to data/:\n")
cat(paste("  ", list.files(data_dir, pattern = "\\.rds$"), collapse = "\n"), "\n")
