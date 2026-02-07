# ==============================================================================
# Paper 188: Moral Foundations Under Digital Pressure
# 02_clean_data.R - Sample Construction
#
# ONE sample. ONE clustering. ONE outcome scaling. Everywhere.
# Revision of apep_0052. Ground-up rebuild with Enke framing.
# ==============================================================================

source("00_packages.R")

cat("\n========================================\n")
cat("  02_clean_data.R - Sample Construction\n")
cat("========================================\n\n")

# ==============================================================================
# 0. HELPER: Safe file loader with flexible column name detection
# ==============================================================================

safe_load <- function(path, label, required = TRUE) {
  tryCatch({
    obj <- readRDS(path)
    cat(sprintf("  Loaded %s: %s rows, %d cols\n",
                label, format(nrow(obj), big.mark = ","), ncol(obj)))
    obj
  }, error = function(e) {
    if (required) {
      cat(sprintf("  ERROR loading %s from %s: %s\n", label, path, conditionMessage(e)))
      stop(sprintf("Required file missing: %s", path))
    } else {
      cat(sprintf("  WARNING: Could not load %s from %s: %s\n", label, path, conditionMessage(e)))
      NULL
    }
  })
}

# Helper: find column matching any of several candidates (case-insensitive)
find_col <- function(df, candidates, required = TRUE, label = "") {
  for (cand in candidates) {
    # exact match
    if (cand %in% names(df)) return(cand)
    # case-insensitive match
    idx <- which(tolower(names(df)) == tolower(cand))
    if (length(idx) > 0) return(names(df)[idx[1]])
  }
  if (required) {
    stop(sprintf("Could not find column for '%s'. Tried: %s. Available: %s",
                 label, paste(candidates, collapse = ", "),
                 paste(head(names(df), 20), collapse = ", ")))
  }
  return(NULL)
}

# ==============================================================================
# 1. LOAD ALL RAW DATA
# ==============================================================================
cat("=== 1. Loading Raw Data ===\n")

localview  <- safe_load("../data/raw_localview.rds",    "LocalView transcripts")
bb_5yr     <- safe_load("../data/raw_acs_broadband_5yr.rds", "ACS 5yr broadband")
demographics <- safe_load("../data/raw_acs_demographics.rds", "ACS demographics")
elections  <- tryCatch({
  safe_load("../data/raw_presidential_county.rds", "County elections")
}, error = function(e) {
  cat("  NOTE: Election data not found. Partisanship heterogeneity will be limited.\n")
  tibble(county_fips = character(), state_fips = character(),
         year = integer(), rep_share = numeric(), dem_share = numeric())
})
rucc       <- tryCatch({
  safe_load("../data/raw_rucc.rds",          "RUCC codes")
}, error = function(e) {
  cat("  NOTE: RUCC data not found. Rurality will use population-based classification.\n")
  tibble(county_fips = character(), rucc_code = integer(),
         is_metro = logical(), rurality = character())
})

# 1yr broadband is optional (large places only)
bb_1yr <- tryCatch({
  safe_load("../data/raw_acs_broadband_1yr.rds", "ACS 1yr broadband")
}, error = function(e) {
  cat("  NOTE: 1yr broadband data not found (optional). Using 5yr only.\n")
  NULL
})

n_start <- nrow(localview)
cat(sprintf("\n  Starting observation count: %s\n", format(n_start, big.mark = ",")))

# ==============================================================================
# 2. PARSE LOCALVIEW: FIPS, YEAR, WORD COUNT, MORAL FOUNDATIONS SCORING
# ==============================================================================
cat("\n=== 2. Parsing LocalView Data ===\n")

# LocalView uses st_fips as a combined state+place FIPS (e.g., "4841980" = TX 48 + place 41980)
# Some files may have 7 digits, some may have separate columns

if ("st_fips" %in% names(localview)) {
  # Combined FIPS: split into state (first 2) and place (remaining 5)
  localview <- localview %>%
    mutate(
      st_fips_str = as.character(st_fips),
      st_fips_str = str_pad(st_fips_str, 7, "left", "0"),
      state_fips = substr(st_fips_str, 1, 2),
      place_fips = substr(st_fips_str, 3, 7)
    ) %>%
    select(-st_fips_str)
  cat("  Split st_fips into state_fips + place_fips\n")
} else {
  # Already has separate columns — try to find them
  lv_st_col <- find_col(localview, c("state_fips", "statefp", "STATEFP"), label = "state_fips")
  lv_pl_col <- find_col(localview, c("place_fips", "placefp", "PLACEFP"), label = "place_fips")
  if (lv_st_col != "state_fips") localview <- localview %>% rename(state_fips = !!sym(lv_st_col))
  if (lv_pl_col != "place_fips") localview <- localview %>% rename(place_fips = !!sym(lv_pl_col))
}

# Ensure zero-padded FIPS
localview <- localview %>%
  mutate(
    state_fips = str_pad(as.character(state_fips), 2, "left", "0"),
    place_fips = str_pad(as.character(place_fips), 5, "left", "0")
  )

cat(sprintf("  State FIPS examples: %s\n", paste(head(unique(localview$state_fips), 5), collapse = ", ")))
cat(sprintf("  Place FIPS examples: %s\n", paste(head(unique(localview$place_fips), 5), collapse = ", ")))

# Extract year from meeting_date
if (!"year" %in% names(localview)) {
  date_col <- find_col(localview, c("meeting_date", "date", "vid_upload_date"),
                        label = "meeting_date")
  localview <- localview %>%
    mutate(year = as.integer(format(as.Date(.data[[date_col]]), "%Y")))
  cat(sprintf("  Extracted year from '%s'\n", date_col))
}

cat(sprintf("  Year range: %d - %d\n", min(localview$year, na.rm = TRUE),
            max(localview$year, na.rm = TRUE)))
cat(sprintf("  Meeting-level rows: %s\n", format(nrow(localview), big.mark = ",")))

# ---------- 2B. Word count from caption_text ----------
cat("\n  Computing word counts from caption_text...\n")

text_col <- find_col(localview, c("caption_text", "transcript_text", "text"),
                      label = "caption_text")

localview <- localview %>%
  mutate(
    # Simple word count: split on whitespace
    word_count = lengths(strsplit(.data[[text_col]], "\\s+"))
  )

cat(sprintf("  Median word count per meeting: %.0f\n", median(localview$word_count, na.rm = TRUE)))
cat(sprintf("  Total words across all meetings: %s\n",
            format(sum(localview$word_count, na.rm = TRUE), big.mark = ",")))

# ---------- 2C. Moral Foundations Dictionary Scoring ----------
cat("\n  Scoring moral foundations using MFD word stems...\n")

# Moral Foundations Dictionary (Graham, Haidt, Nosek 2009; Hopp et al. 2021)
# Each foundation is represented by core word stems. We count stem matches
# per 1,000 words. Using stems (not full words) following standard practice.

mfd_care <- c("safe", "peace", "compassion", "empath", "sympath", "care",
              "caring", "protect", "shield", "shelter", "amity", "secur",
              "benefit", "defen", "guard", "preserve", "harm", "suffer",
              "war", "wars", "warl", "fight", "violen", "hurt", "kill",
              "abuse", "damag", "ruin", "ravage", "cruel", "brutal",
              "destroy", "attack", "annihilat")

mfd_fairness <- c("fair", "balanc", "homolog", "equal", "justice", "justif",
                   "reciproc", "impartial", "egalitar", "rights", "equity",
                   "evenhand", "proportion", "unfair", "unequal", "unjust",
                   "injust", "bias", "bigot", "discriminat", "disproportion",
                   "inequit", "prejudic", "dishonest", "unscrupul", "exploit",
                   "cheat", "fraud", "deceiv", "deception")

mfd_loyalty <- c("together", "nation", "homeland", "family", "families",
                  "famili", "group", "loyal", "patriot", "communal", "united",
                  "communit", "communiti", "collectiv", "joint", "unison",
                  "tribe", "comrad", "cadre", "cohort", "ally", "allies",
                  "betray", "treason", "disloyal", "traitor", "treacher",
                  "sediti", "mutiny", "desert", "abandon")

mfd_authority <- c("obey", "obedi", "duty", "law", "lawful", "legal",
                    "order", "hierarchy", "subordin", "respect", "author",
                    "permit", "tradition", "custom", "submiss", "complian",
                    "defer", "revere", "mandator", "serve", "honor",
                    "subver", "disrespect", "disobe", "defian", "rebel",
                    "dissent", "chaos", "disrupt", "disorgan", "anarch",
                    "lawless", "illegal")

mfd_sanctity <- c("purity", "pure", "clean", "sterile", "sacred", "saint",
                   "wholesome", "celesti", "divine", "noble", "uplift",
                   "chast", "holy", "spiritual", "immacul", "innocent",
                   "abstinen", "disgust", "deprav", "sick", "disease",
                   "indecen", "sin", "perver", "profan", "gross", "repuls",
                   "impure", "slut", "whore", "dirt", "filth", "obscen",
                   "taint", "stain", "corrupt", "pollut", "desecrat")

# Build regex pattern for each foundation (stem matching with word boundaries)
make_pattern <- function(stems) {
  paste0("\\b(", paste(stems, collapse = "|"), ")\\w*\\b")
}

care_pat      <- make_pattern(mfd_care)
fairness_pat  <- make_pattern(mfd_fairness)
loyalty_pat   <- make_pattern(mfd_loyalty)
authority_pat <- make_pattern(mfd_authority)
sanctity_pat  <- make_pattern(mfd_sanctity)

# Count matches using stringi (vectorized, much faster than gregexpr)
cat("  Counting MFD matches using stringi (vectorized)...\n")
t0 <- proc.time()

# Lowercase text once
lv_text <- tolower(localview[[text_col]])

# stringi::stri_count_regex is vectorized and uses ICU regex engine (fast)
localview$care_count      <- stringi::stri_count_regex(lv_text, care_pat)
cat("    care done.\n")
localview$fairness_count  <- stringi::stri_count_regex(lv_text, fairness_pat)
cat("    fairness done.\n")
localview$loyalty_count   <- stringi::stri_count_regex(lv_text, loyalty_pat)
cat("    loyalty done.\n")
localview$authority_count <- stringi::stri_count_regex(lv_text, authority_pat)
cat("    authority done.\n")
localview$sanctity_count  <- stringi::stri_count_regex(lv_text, sanctity_pat)
cat("    sanctity done.\n")

rm(lv_text)
gc(verbose = FALSE)

elapsed <- (proc.time() - t0)["elapsed"]
cat(sprintf("  MFD scoring completed in %.1f seconds\n", elapsed))

# Compute proportions per 1000 words
localview <- localview %>%
  mutate(
    care_p      = ifelse(word_count > 0, care_count / word_count * 1000, NA_real_),
    fairness_p  = ifelse(word_count > 0, fairness_count / word_count * 1000, NA_real_),
    loyalty_p   = ifelse(word_count > 0, loyalty_count / word_count * 1000, NA_real_),
    authority_p = ifelse(word_count > 0, authority_count / word_count * 1000, NA_real_),
    sanctity_p  = ifelse(word_count > 0, sanctity_count / word_count * 1000, NA_real_),
    moral_word_count = care_count + fairness_count + loyalty_count +
                       authority_count + sanctity_count
  )

cat(sprintf("  Meeting-level MFD means (per 1000 words):\n"))
cat(sprintf("    Care:      %.2f\n", mean(localview$care_p, na.rm = TRUE)))
cat(sprintf("    Fairness:  %.2f\n", mean(localview$fairness_p, na.rm = TRUE)))
cat(sprintf("    Loyalty:   %.2f\n", mean(localview$loyalty_p, na.rm = TRUE)))
cat(sprintf("    Authority: %.2f\n", mean(localview$authority_p, na.rm = TRUE)))
cat(sprintf("    Sanctity:  %.2f\n", mean(localview$sanctity_p, na.rm = TRUE)))

# ==============================================================================
# 3. AGGREGATE LOCALVIEW TO PLACE-YEAR LEVEL
# ==============================================================================
cat("\n=== 3. Aggregating LocalView to Place-Year Level ===\n")

cat(sprintf("  Input rows (meeting-level): %s\n", format(nrow(localview), big.mark = ",")))

# Word-count-weighted means of moral foundations proportions
lv_agg <- localview %>%
  filter(!is.na(care_p) & !is.na(word_count) & word_count > 0) %>%
  group_by(state_fips, place_fips, year) %>%
  summarise(
    # Word-count-weighted means of each moral foundation
    care_p      = weighted.mean(care_p, w = word_count, na.rm = TRUE),
    fairness_p  = weighted.mean(fairness_p, w = word_count, na.rm = TRUE),
    loyalty_p   = weighted.mean(loyalty_p, w = word_count, na.rm = TRUE),
    authority_p = weighted.mean(authority_p, w = word_count, na.rm = TRUE),
    sanctity_p  = weighted.mean(sanctity_p, w = word_count, na.rm = TRUE),

    # Enke's universalism/communalism indices
    # (use already-computed weighted means, not recomputed ones)
    individualizing = (care_p + fairness_p) / 2,
    binding = (loyalty_p + authority_p + sanctity_p) / 3,

    # Moral intensity: moral words per 1000 total words
    moral_intensity = sum(moral_word_count, na.rm = TRUE) /
                      sum(word_count, na.rm = TRUE) * 1000,

    # Meeting and word count aggregates
    n_total_words = sum(word_count, na.rm = TRUE),
    n_meetings    = n(),

    .groups = "drop"
  ) %>%
  mutate(
    # Universalism index: individualizing - binding (following Enke 2020)
    universalism_index = individualizing - binding,

    # Log ratio (symmetric, better distributional properties)
    log_univ_comm = log(individualizing + 0.001) - log(binding + 0.001)
  )

# Free localview from memory
rm(localview)
gc(verbose = FALSE)

cat(sprintf("  Aggregated to %s place-years\n", format(nrow(lv_agg), big.mark = ",")))
cat(sprintf("  Unique places: %s\n", format(n_distinct(paste0(lv_agg$state_fips, lv_agg$place_fips)), big.mark = ",")))
cat(sprintf("  Year range: %d - %d\n", min(lv_agg$year), max(lv_agg$year)))
cat(sprintf("  Median meetings per place-year: %.0f\n", median(lv_agg$n_meetings)))

# Quick sanity check on moral foundations
cat("\n  Moral Foundation Means (place-year level):\n")
cat(sprintf("    Care:      %.4f\n", mean(lv_agg$care_p, na.rm = TRUE)))
cat(sprintf("    Fairness:  %.4f\n", mean(lv_agg$fairness_p, na.rm = TRUE)))
cat(sprintf("    Loyalty:   %.4f\n", mean(lv_agg$loyalty_p, na.rm = TRUE)))
cat(sprintf("    Authority: %.4f\n", mean(lv_agg$authority_p, na.rm = TRUE)))
cat(sprintf("    Sanctity:  %.4f\n", mean(lv_agg$sanctity_p, na.rm = TRUE)))
cat(sprintf("    Individualizing: %.4f\n", mean(lv_agg$individualizing, na.rm = TRUE)))
cat(sprintf("    Binding:         %.4f\n", mean(lv_agg$binding, na.rm = TRUE)))
cat(sprintf("    Univ. Index:     %.4f\n", mean(lv_agg$universalism_index, na.rm = TRUE)))

# ==============================================================================
# 4. MERGE WITH BROADBAND DATA (2013-2022 window)
# ==============================================================================
cat("\n=== 4. Merging with Broadband Data ===\n")

n_pre_merge <- nrow(lv_agg)

# Standardize broadband column names
# The ACS data has "state" (2-digit) and "place" (5-digit) as separate cols,
# plus "st_fips" which is the combined 7-digit. We need separate state/place.

if ("state" %in% names(bb_5yr) && "place" %in% names(bb_5yr)) {
  # Census API output: "state" and "place" are already separate
  bb_5yr <- bb_5yr %>%
    rename(state_fips = state, place_fips = place)
} else if ("st_fips" %in% names(bb_5yr)) {
  # Combined: split like LocalView
  bb_5yr <- bb_5yr %>%
    mutate(
      st_fips_str = str_pad(as.character(st_fips), 7, "left", "0"),
      state_fips = substr(st_fips_str, 1, 2),
      place_fips = substr(st_fips_str, 3, 7)
    ) %>%
    select(-st_fips_str)
} else {
  bb_st_col <- find_col(bb_5yr, c("state_fips", "statefp", "STATEFP"), label = "state_fips (broadband)")
  bb_pl_col <- find_col(bb_5yr, c("place_fips", "placefp", "PLACEFP"), label = "place_fips (broadband)")
  if (bb_st_col != "state_fips") bb_5yr <- bb_5yr %>% rename(state_fips = !!sym(bb_st_col))
  if (bb_pl_col != "place_fips") bb_5yr <- bb_5yr %>% rename(place_fips = !!sym(bb_pl_col))
}

bb_5yr <- bb_5yr %>%
  mutate(
    state_fips = str_pad(as.character(state_fips), 2, "left", "0"),
    place_fips = str_pad(as.character(place_fips), 5, "left", "0")
  )

# If 1yr broadband data exists, merge it to fill gaps for large places
if (!is.null(bb_1yr)) {
  # Standardize 1yr broadband columns the same way
  if ("state" %in% names(bb_1yr) && "place" %in% names(bb_1yr)) {
    bb_1yr <- bb_1yr %>% rename(state_fips = state, place_fips = place)
  } else if ("st_fips" %in% names(bb_1yr)) {
    bb_1yr <- bb_1yr %>%
      mutate(st_fips_str = str_pad(as.character(st_fips), 7, "left", "0"),
             state_fips = substr(st_fips_str, 1, 2),
             place_fips = substr(st_fips_str, 3, 7)) %>%
      select(-st_fips_str)
  }

  bb_1yr_rt_col <- find_col(bb_1yr, c("broadband_rate", "bb_rate", "pct_broadband"),
                             required = FALSE, label = "broadband_rate (bb_1yr)")

  if (!is.null(bb_1yr_rt_col) && "state_fips" %in% names(bb_1yr)) {
    if (bb_1yr_rt_col != "broadband_rate_1yr") {
      bb_1yr <- bb_1yr %>% rename(broadband_rate_1yr = !!sym(bb_1yr_rt_col))
    }
    bb_1yr <- bb_1yr %>%
      mutate(
        state_fips = str_pad(as.character(state_fips), 2, "left", "0"),
        place_fips = str_pad(as.character(place_fips), 5, "left", "0")
      ) %>%
      select(state_fips, place_fips, year, broadband_rate_1yr)

    # Merge 5yr and 1yr: prefer 1yr where available (more precise for large places)
    bb_merged <- bb_5yr %>%
      left_join(bb_1yr, by = c("state_fips", "place_fips", "year")) %>%
      mutate(
        broadband_rate = coalesce(broadband_rate_1yr, broadband_rate)
      ) %>%
      select(-broadband_rate_1yr)

    cat(sprintf("  Merged 5yr and 1yr broadband: %s rows\n",
                format(nrow(bb_merged), big.mark = ",")))
  } else {
    bb_merged <- bb_5yr
    cat("  Could not standardize 1yr broadband columns. Using 5yr only.\n")
  }
} else {
  bb_merged <- bb_5yr
}

# Merge LocalView with broadband on (state_fips, place_fips, year)
panel <- lv_agg %>%
  inner_join(
    bb_merged %>% select(state_fips, place_fips, year, broadband_rate),
    by = c("state_fips", "place_fips", "year")
  )

n_post_bb_merge <- nrow(panel)
cat(sprintf("  Before broadband merge: %s place-years\n", format(n_pre_merge, big.mark = ",")))
cat(sprintf("  After broadband merge:  %s place-years\n", format(n_post_bb_merge, big.mark = ",")))
cat(sprintf("  Match rate: %.1f%%\n", 100 * n_post_bb_merge / n_pre_merge))

# ==============================================================================
# 5. CONSTRUCT TREATMENT VARIABLE
# ==============================================================================
cat("\n=== 5. Constructing Treatment Variables ===\n")

# Restrict to 2013-2022 analysis window
panel <- panel %>% filter(year >= 2013, year <= 2022)

n_after_window <- nrow(panel)
cat(sprintf("  After restricting to 2013-2022: %s place-years\n",
            format(n_after_window, big.mark = ",")))

# Main threshold: 70% broadband adoption
THRESHOLD_MAIN <- 0.70

# Identify first year broadband_rate >= threshold for each place
treatment_timing <- panel %>%
  filter(broadband_rate >= THRESHOLD_MAIN) %>%
  group_by(state_fips, place_fips) %>%
  summarise(treat_year = min(year), .groups = "drop")

cat(sprintf("  Main threshold (%.0f%%): %d places ever treated\n",
            THRESHOLD_MAIN * 100, nrow(treatment_timing)))

# Merge treatment timing
panel <- panel %>%
  left_join(treatment_timing, by = c("state_fips", "place_fips")) %>%
  mutate(
    treated    = !is.na(treat_year),
    post       = !is.na(treat_year) & year >= treat_year,
    treat_post = treated & post,
    rel_year   = ifelse(treated, year - treat_year, NA_integer_),
    cohort     = ifelse(treated, treat_year, 0L)
  )

# Treatment timing distribution
cat("\n  Treatment cohort distribution:\n")
cohort_tab <- panel %>%
  filter(treated) %>%
  distinct(state_fips, place_fips, treat_year) %>%
  count(treat_year) %>%
  arrange(treat_year)
print(cohort_tab, n = Inf)

cat(sprintf("\n  Treated places: %d\n",
            n_distinct(paste0(panel$state_fips[panel$treated], panel$place_fips[panel$treated]))))
cat(sprintf("  Never-treated places: %d\n",
            n_distinct(paste0(panel$state_fips[!panel$treated], panel$place_fips[!panel$treated]))))

# Alternative thresholds for robustness
alt_thresholds <- c(0.60, 0.65, 0.75, 0.80)

for (thresh in alt_thresholds) {
  suffix <- gsub("\\.", "", as.character(thresh * 100))
  tvar <- paste0("treat_year_", suffix)
  bvar <- paste0("broadband_", suffix)

  timing_alt <- panel %>%
    filter(broadband_rate >= thresh) %>%
    group_by(state_fips, place_fips) %>%
    summarise(!!tvar := min(year), .groups = "drop")

  panel <- panel %>%
    left_join(timing_alt, by = c("state_fips", "place_fips"))

  # Binary: has this place ever crossed the threshold?
  panel[[bvar]] <- !is.na(panel[[tvar]])

  n_alt <- sum(!is.na(panel[[tvar]]) & !duplicated(paste0(panel$state_fips, panel$place_fips)))
  cat(sprintf("  Threshold %.0f%%: %d places treated (treat_year in '%s')\n",
              thresh * 100, nrow(timing_alt), tvar))
}

# ==============================================================================
# 6. MERGE DEMOGRAPHICS
# ==============================================================================
cat("\n=== 6. Merging Demographics ===\n")

n_pre_demo <- nrow(panel)

# Standardize demographic column names
# Same approach as broadband: handle separate state/place or combined st_fips
if ("state" %in% names(demographics) && "place" %in% names(demographics) &&
    !"state_fips" %in% names(demographics)) {
  demographics <- demographics %>% rename(state_fips = state, place_fips = place)
} else if ("st_fips" %in% names(demographics) && !"state_fips" %in% names(demographics)) {
  demographics <- demographics %>%
    mutate(st_fips_str = str_pad(as.character(st_fips), 7, "left", "0"),
           state_fips = substr(st_fips_str, 1, 2),
           place_fips = substr(st_fips_str, 3, 7)) %>%
    select(-st_fips_str)
} else {
  demo_st_col <- find_col(demographics, c("state_fips", "statefp", "STATEFP"), label = "state_fips (demographics)")
  demo_pl_col <- find_col(demographics, c("place_fips", "placefp", "PLACEFP"), label = "place_fips (demographics)")
  if (demo_st_col != "state_fips") demographics <- demographics %>% rename(state_fips = !!sym(demo_st_col))
  if (demo_pl_col != "place_fips") demographics <- demographics %>% rename(place_fips = !!sym(demo_pl_col))
}

demographics <- demographics %>%
  mutate(
    state_fips = str_pad(as.character(state_fips), 2, "left", "0"),
    place_fips = str_pad(as.character(place_fips), 5, "left", "0")
  )

# Check if demographics are year-varying or cross-sectional
demo_yr_col <- find_col(demographics, c("year", "Year", "YEAR"),
                         required = FALSE, label = "year (demographics)")

# Identify available demographic columns
demo_vars <- c()
pop_col <- find_col(demographics, c("population", "pop", "total_pop", "totpop"),
                     required = FALSE, label = "population")
inc_col <- find_col(demographics, c("median_income", "med_income", "medinc", "hhinc",
                                      "median_hh_income"), required = FALSE, label = "median_income")
edu_col <- find_col(demographics, c("pct_college", "college_pct", "pct_ba", "pct_bachelors",
                                      "college_share"), required = FALSE, label = "pct_college")
race_col <- find_col(demographics, c("pct_white", "white_pct", "pct_white_nh", "white_share"),
                      required = FALSE, label = "pct_white")
age_col <- find_col(demographics, c("median_age", "med_age", "medage"),
                     required = FALSE, label = "median_age")

# Build rename map for available columns
rename_map <- c()
if (!is.null(pop_col) && pop_col != "population") {
  rename_map <- c(rename_map, setNames(pop_col, "population"))
}
if (!is.null(inc_col) && inc_col != "median_income") {
  rename_map <- c(rename_map, setNames(inc_col, "median_income"))
}
if (!is.null(edu_col) && edu_col != "pct_college") {
  rename_map <- c(rename_map, setNames(edu_col, "pct_college"))
}
if (!is.null(race_col) && race_col != "pct_white") {
  rename_map <- c(rename_map, setNames(race_col, "pct_white"))
}
if (!is.null(age_col) && age_col != "median_age") {
  rename_map <- c(rename_map, setNames(age_col, "median_age"))
}

if (length(rename_map) > 0) {
  demographics <- demographics %>% rename(!!!rename_map)
}

# Select columns for merge
demo_select_cols <- c("state_fips", "place_fips")
if (!is.null(demo_yr_col)) demo_select_cols <- c(demo_select_cols, "year")
for (v in c("population", "median_income", "pct_college", "pct_white", "median_age")) {
  if (v %in% names(demographics)) demo_select_cols <- c(demo_select_cols, v)
}

demographics_sel <- demographics %>% select(any_of(demo_select_cols))

# Merge: year-varying if year exists, otherwise cross-sectional
if (!is.null(demo_yr_col)) {
  panel <- panel %>%
    left_join(demographics_sel, by = c("state_fips", "place_fips", "year"))
  cat("  Merged year-varying demographics\n")
} else {
  panel <- panel %>%
    left_join(demographics_sel, by = c("state_fips", "place_fips"))
  cat("  Merged cross-sectional demographics\n")
}

n_with_demo <- sum(!is.na(panel$population))
cat(sprintf("  Panel rows: %s\n", format(nrow(panel), big.mark = ",")))
cat(sprintf("  Rows with population data: %s (%.1f%%)\n",
            format(n_with_demo, big.mark = ","), 100 * n_with_demo / nrow(panel)))

# Create log transforms for covariates
if ("population" %in% names(panel)) {
  panel$log_pop <- log(panel$population + 1)
}
if ("median_income" %in% names(panel)) {
  panel$log_income <- log(panel$median_income + 1)
}

# ==============================================================================
# 7. MERGE ELECTION DATA + RUCC via Place-to-County Crosswalk
# ==============================================================================
cat("\n=== 7. Merging Election Data ===\n")

# Load place-to-county crosswalk (generated by tigris spatial join in 01_fetch)
crosswalk <- tryCatch({
  xw <- readRDS("../data/raw_place_county_crosswalk.rds")
  cat(sprintf("  Loaded crosswalk: %s place-county mappings\n",
              format(nrow(xw), big.mark = ",")))
  # Standardize: need state_fips + place_fips -> county_fips
  if ("st_fips" %in% names(xw) && !"state_fips" %in% names(xw)) {
    xw <- xw %>%
      mutate(st_fips_str = str_pad(as.character(st_fips), 7, "left", "0"),
             state_fips = substr(st_fips_str, 1, 2),
             place_fips = substr(st_fips_str, 3, 7)) %>%
      select(-st_fips_str)
  }
  if ("state_fips" %in% names(xw)) {
    xw <- xw %>%
      mutate(state_fips = str_pad(as.character(state_fips), 2, "left", "0"),
             place_fips = str_pad(as.character(place_fips), 5, "left", "0"),
             county_fips = str_pad(as.character(county_fips), 5, "left", "0"))
  }
  xw %>% distinct(state_fips, place_fips, county_fips)
}, error = function(e) {
  cat("  NOTE: Crosswalk not found. Will use state-level election averages.\n")
  NULL
})

# Add county_fips to panel via crosswalk
if (!is.null(crosswalk) && "county_fips" %in% names(crosswalk)) {
  panel <- panel %>%
    left_join(crosswalk %>% select(state_fips, place_fips, county_fips),
              by = c("state_fips", "place_fips"))
  n_with_county <- sum(!is.na(panel$county_fips))
  cat(sprintf("  Panel rows with county_fips: %s (%.1f%%)\n",
              format(n_with_county, big.mark = ","), 100 * n_with_county / nrow(panel)))
}

# Merge election data
if (nrow(elections) > 0 && "rep_share" %in% names(elections)) {
  elections <- elections %>%
    mutate(county_fips = str_pad(as.character(county_fips), 5, "left", "0"))

  if ("county_fips" %in% names(panel) && sum(!is.na(panel$county_fips)) > 0) {
    # County-level merge: use most recent election <= panel year
    election_years <- sort(unique(elections$year))

    panel <- panel %>%
      mutate(
        election_year = sapply(year, function(y) {
          ey <- election_years[election_years <= y]
          if (length(ey) > 0) max(ey) else min(election_years)
        })
      ) %>%
      left_join(
        elections %>% select(county_fips, year, rep_share),
        by = c("county_fips" = "county_fips", "election_year" = "year")
      ) %>%
      select(-election_year)

    cat(sprintf("  Merged county-level Republican vote share\n"))
  } else {
    # Fallback: state-level average
    elections <- elections %>%
      mutate(state_fips = substr(county_fips, 1, 2))

    state_rep <- elections %>%
      filter(year == max(year)) %>%
      group_by(state_fips) %>%
      summarise(rep_share = mean(rep_share, na.rm = TRUE), .groups = "drop")

    panel <- panel %>%
      left_join(state_rep, by = "state_fips")
    cat(sprintf("  Merged state-level Republican share for %d states\n", nrow(state_rep)))
  }

  n_with_rep <- sum(!is.na(panel$rep_share))
  cat(sprintf("  Rows with rep_share: %s (%.1f%%)\n",
              format(n_with_rep, big.mark = ","), 100 * n_with_rep / nrow(panel)))
} else {
  cat("  WARNING: No election data available. Skipping.\n")
  panel$rep_share <- NA_real_
}

# ==============================================================================
# 8. MERGE RUCC (Rural-Urban Continuum Codes)
# ==============================================================================
cat("\n=== 8. Merging RUCC Codes ===\n")

if (nrow(rucc) > 0 && "rucc_code" %in% names(rucc)) {
  rucc <- rucc %>%
    mutate(
      county_fips = str_pad(as.character(county_fips), 5, "left", "0"),
      rucc_code   = as.integer(rucc_code),
      metro       = rucc_code <= 3
    )

  if ("county_fips" %in% names(panel) && sum(!is.na(panel$county_fips)) > 0) {
    panel <- panel %>%
      left_join(rucc %>% select(county_fips, rucc_code, metro), by = "county_fips")
    cat(sprintf("  Merged RUCC for %d counties\n", n_distinct(rucc$county_fips)))
  } else {
    # Fallback: use state-level modal RUCC
    rucc_state <- rucc %>%
      mutate(state_fips = substr(county_fips, 1, 2)) %>%
      group_by(state_fips) %>%
      summarise(
        pct_metro = mean(metro, na.rm = TRUE),
        modal_rucc = as.integer(names(sort(table(rucc_code), decreasing = TRUE))[1]),
        .groups = "drop"
      ) %>%
      mutate(metro = pct_metro > 0.5)

    panel <- panel %>%
      left_join(rucc_state %>% select(state_fips, rucc_code = modal_rucc, metro),
                by = "state_fips")
    cat(sprintf("  Merged state-level RUCC (modal code) for %d states\n", nrow(rucc_state)))
  }

  n_metro <- sum(panel$metro, na.rm = TRUE)
  cat(sprintf("  Metro observations: %s (%.1f%%)\n",
              format(n_metro, big.mark = ","), 100 * n_metro / nrow(panel)))
} else {
  cat("  RUCC data not available. Using population-based metro proxy.\n")
  if ("population" %in% names(panel)) {
    panel$metro <- panel$population > 25000
    panel$rucc_code <- NA_integer_
    cat(sprintf("  Metro proxy (pop > 25000): %d obs\n", sum(panel$metro, na.rm = TRUE)))
  } else {
    panel$metro <- NA
    panel$rucc_code <- NA_integer_
  }
}

# ==============================================================================
# 9. APPLY SAMPLE RESTRICTIONS
# ==============================================================================
cat("\n=== 9. Applying Sample Restrictions ===\n")

n_0 <- nrow(panel)
cat(sprintf("  Starting: %s place-years\n", format(n_0, big.mark = ",")))

# 9a. Already restricted to 2013-2022 in step 5
cat(sprintf("  After 2013-2022 window: %s place-years\n", format(nrow(panel), big.mark = ",")))

# 9b. Require at least 3 years of data per place
place_year_count <- panel %>%
  group_by(state_fips, place_fips) %>%
  summarise(n_years = n(), .groups = "drop")

places_3plus <- place_year_count %>%
  filter(n_years >= 3) %>%
  select(state_fips, place_fips)

panel <- panel %>%
  semi_join(places_3plus, by = c("state_fips", "place_fips"))

n_after_3yr <- nrow(panel)
cat(sprintf("  After requiring >=3 years per place: %s place-years (%d places dropped)\n",
            format(n_after_3yr, big.mark = ","),
            n_distinct(paste0(place_year_count$state_fips, place_year_count$place_fips)) -
              n_distinct(paste0(places_3plus$state_fips, places_3plus$place_fips))))

# 9c. Drop missing population
if ("population" %in% names(panel)) {
  n_before_pop <- nrow(panel)
  panel <- panel %>% filter(!is.na(population))
  n_after_pop <- nrow(panel)
  cat(sprintf("  After dropping missing population: %s place-years (%d dropped)\n",
              format(n_after_pop, big.mark = ","), n_before_pop - n_after_pop))
}

# Create place_id (unique numeric identifier)
panel <- panel %>%
  mutate(
    place_key = paste0(state_fips, "_", place_fips),
    place_id  = as.numeric(factor(place_key))
  )

cat(sprintf("\n  FINAL SAMPLE:\n"))
cat(sprintf("    Place-years: %s\n", format(nrow(panel), big.mark = ",")))
cat(sprintf("    Unique places: %d\n", n_distinct(panel$place_id)))
cat(sprintf("    Unique states: %d\n", n_distinct(panel$state_fips)))

# ==============================================================================
# 10. CREATE SUBGROUP INDICATORS
# ==============================================================================
cat("\n=== 10. Creating Subgroup Indicators ===\n")

# 10a. Republican county (based on median split of rep_share)
if ("rep_share" %in% names(panel) && sum(!is.na(panel$rep_share)) > 0) {
  # Use place-level baseline (first observed year) for classification
  baseline_rep <- panel %>%
    filter(!is.na(rep_share)) %>%
    group_by(place_id) %>%
    summarise(rep_share_baseline = first(rep_share), .groups = "drop")

  med_rep <- median(baseline_rep$rep_share_baseline, na.rm = TRUE)

  panel <- panel %>%
    left_join(baseline_rep, by = "place_id") %>%
    mutate(republican_county = rep_share_baseline > med_rep)

  n_rep <- n_distinct(panel$place_id[panel$republican_county == TRUE])
  n_dem <- n_distinct(panel$place_id[panel$republican_county == FALSE])
  cat(sprintf("  Republican county (rep_share > %.3f median): %d places\n", med_rep, n_rep))
  cat(sprintf("  Democratic county: %d places\n", n_dem))
} else {
  panel$republican_county <- NA
  panel$rep_share_baseline <- NA_real_
  cat("  WARNING: rep_share not available. republican_county set to NA.\n")
}

# 10b. Metro indicator (already constructed in step 8)
if ("metro" %in% names(panel)) {
  n_metro_places <- n_distinct(panel$place_id[panel$metro == TRUE])
  n_nonmetro_places <- n_distinct(panel$place_id[panel$metro == FALSE])
  cat(sprintf("  Metro places: %d, Non-metro places: %d\n", n_metro_places, n_nonmetro_places))
}

# 10c. High universalism (pre-treatment universalism_index > median)
baseline_univ <- panel %>%
  filter(!treated | (treated & year < treat_year)) %>%
  group_by(place_id) %>%
  summarise(
    pre_universalism = mean(universalism_index, na.rm = TRUE),
    .groups = "drop"
  )

med_univ <- median(baseline_univ$pre_universalism, na.rm = TRUE)

panel <- panel %>%
  left_join(baseline_univ, by = "place_id") %>%
  mutate(high_universalism = pre_universalism > med_univ)

n_high_u <- n_distinct(panel$place_id[panel$high_universalism == TRUE])
n_low_u  <- n_distinct(panel$place_id[panel$high_universalism == FALSE])
cat(sprintf("  High universalism (pre-treatment > %.4f median): %d places\n",
            med_univ, n_high_u))
cat(sprintf("  Low universalism: %d places\n", n_low_u))

# ==============================================================================
# 11. STANDARDIZE OUTCOMES (z-scores based on full sample)
# ==============================================================================
cat("\n=== 11. Standardizing Outcomes ===\n")

outcome_vars <- c("individualizing", "binding", "universalism_index",
                   "care_p", "fairness_p", "loyalty_p", "authority_p", "sanctity_p",
                   "moral_intensity")

for (v in outcome_vars) {
  if (v %in% names(panel)) {
    z_name <- paste0(v, "_z")
    panel[[z_name]] <- (panel[[v]] - mean(panel[[v]], na.rm = TRUE)) /
                        sd(panel[[v]], na.rm = TRUE)
    cat(sprintf("  %s -> %s (mean=%.4f, sd=%.4f)\n",
                v, z_name, mean(panel[[v]], na.rm = TRUE), sd(panel[[v]], na.rm = TRUE)))
  }
}

# ==============================================================================
# 12. SAVE ANALYSIS PANEL
# ==============================================================================
cat("\n=== 12. Saving Analysis Panel ===\n")

# Create combined st_fips for backward compatibility with figure scripts
panel <- panel %>%
  mutate(st_fips = paste0(state_fips, place_fips))

# Ensure output directory exists
dir.create("../data", showWarnings = FALSE, recursive = TRUE)

# Save as parquet (primary format for downstream scripts)
arrow::write_parquet(panel, "../data/analysis_panel.parquet")
cat("  Saved: data/analysis_panel.parquet\n")

# Also save treatment timing separately
treatment_timing_final <- panel %>%
  filter(treated) %>%
  distinct(state_fips, place_fips, place_id, treat_year, cohort)

write_csv(treatment_timing_final, "../data/treatment_timing.csv")
cat(sprintf("  Saved: data/treatment_timing.csv (%d treated places)\n",
            nrow(treatment_timing_final)))

# Panel balance info
panel_balance <- panel %>%
  group_by(place_id) %>%
  summarise(
    n_years  = n(),
    min_year = min(year),
    max_year = max(year),
    treated  = first(treated),
    .groups  = "drop"
  )

write_csv(panel_balance, "../data/panel_balance.csv")
cat(sprintf("  Saved: data/panel_balance.csv\n"))

# ==============================================================================
# 13. COMPREHENSIVE SUMMARY
# ==============================================================================
cat("\n")
cat("╔══════════════════════════════════════════════════════════════╗\n")
cat("║          SAMPLE CONSTRUCTION COMPLETE                       ║\n")
cat("╚══════════════════════════════════════════════════════════════╝\n\n")

cat(sprintf("  Total observations:        %s\n", format(nrow(panel), big.mark = ",")))
cat(sprintf("  Unique places:             %d\n", n_distinct(panel$place_id)))
cat(sprintf("  Unique states:             %d\n", n_distinct(panel$state_fips)))
cat(sprintf("  Year range:                %d - %d\n", min(panel$year), max(panel$year)))
cat(sprintf("  Mean years per place:      %.1f\n", mean(panel_balance$n_years)))

cat(sprintf("\n  Treated places:            %d\n",
            n_distinct(panel$place_id[panel$treated])))
cat(sprintf("  Never-treated places:      %d\n",
            n_distinct(panel$place_id[!panel$treated])))
cat(sprintf("  Treatment rate:            %.1f%%\n",
            100 * mean(panel_balance$treated)))

cat("\n  Treatment cohort distribution:\n")
cohort_final <- panel %>%
  filter(treated) %>%
  distinct(place_id, treat_year) %>%
  count(treat_year, name = "n_places") %>%
  arrange(treat_year)
print(cohort_final, n = Inf)

cat("\n  Outcome variable summary:\n")
for (v in c("individualizing", "binding", "universalism_index", "log_univ_comm",
            "moral_intensity")) {
  if (v %in% names(panel)) {
    cat(sprintf("    %-25s mean=%.4f  sd=%.4f  [%.4f, %.4f]\n",
                v, mean(panel[[v]], na.rm = TRUE), sd(panel[[v]], na.rm = TRUE),
                min(panel[[v]], na.rm = TRUE), max(panel[[v]], na.rm = TRUE)))
  }
}

cat("\n  Control variable summary:\n")
for (v in c("broadband_rate", "population", "median_income", "pct_college",
            "pct_white", "median_age", "rep_share")) {
  if (v %in% names(panel) && sum(!is.na(panel[[v]])) > 0) {
    cat(sprintf("    %-25s mean=%.2f  sd=%.2f  non-missing=%s\n",
                v, mean(panel[[v]], na.rm = TRUE), sd(panel[[v]], na.rm = TRUE),
                format(sum(!is.na(panel[[v]])), big.mark = ",")))
  }
}

cat("\n  Subgroup coverage:\n")
if ("republican_county" %in% names(panel)) {
  cat(sprintf("    republican_county:  %s non-missing (%.1f%%)\n",
              format(sum(!is.na(panel$republican_county)), big.mark = ","),
              100 * mean(!is.na(panel$republican_county))))
}
if ("metro" %in% names(panel)) {
  cat(sprintf("    metro:              %s non-missing (%.1f%%)\n",
              format(sum(!is.na(panel$metro)), big.mark = ","),
              100 * mean(!is.na(panel$metro))))
}
if ("high_universalism" %in% names(panel)) {
  cat(sprintf("    high_universalism:  %s non-missing (%.1f%%)\n",
              format(sum(!is.na(panel$high_universalism)), big.mark = ","),
              100 * mean(!is.na(panel$high_universalism))))
}

cat("\n=== 02_clean_data.R Complete ===\n")
