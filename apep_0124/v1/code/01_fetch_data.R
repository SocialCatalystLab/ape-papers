# =============================================================================
# 01_fetch_data.R
# Fetch Swiss referendum data at municipality level
# =============================================================================

source("00_packages.R")

# =============================================================================
# 1. Fetch Swissvotes metadata (policy domains, dates, outcomes)
# =============================================================================

cat("Fetching Swissvotes metadata...\n")

# Direct CSV download - uses semicolon delimiter
swissvotes_url <- "https://swissvotes.ch/page/dataset/swissvotes_dataset.csv"
swissvotes_raw <- read_delim(swissvotes_url, delim = ";", show_col_types = FALSE)

# Select key columns (using actual column names from the file)
swissvotes <- swissvotes_raw %>%
  select(
    vote_id = anr,
    vote_date = datum,
    title_de = `titel_kurz_d`,
    title_fr = `titel_kurz_f`,
    vote_type = rechtsform,
    policy_domain = d1e1,  # Primary policy domain
    policy_domain2 = d1e2,  # Secondary domain
    policy_domain3 = d1e3,  # Tertiary domain
    result = annahme,  # 1 = accepted, 0 = rejected
    yes_pct_national = `volkja-proz`,
    turnout_national = bet,
    canton_majority = stand
  ) %>%
  mutate(
    vote_date = as.Date(vote_date, format = "%d.%m.%Y"),
    passed = result == 1
  ) %>%
  filter(vote_date >= "1981-01-01")  # Municipal data available from 1981

cat("Found", nrow(swissvotes), "federal referendums since 1981\n")

# Save metadata
write_csv(swissvotes, "../data/swissvotes_metadata.csv")

# =============================================================================
# 2. Get list of available vote dates with municipal data
# =============================================================================

cat("\nIdentifying referendum dates with municipal-level results...\n")

# Federal votes are held on specific dates
# URL pattern: https://ogd-static.voteinfo-app.ch/v1/ogd/sd-t-17-02-YYYYMMDD-eidgAbstimmung.json

# Get unique vote dates from swissvotes
vote_dates <- swissvotes %>%
  filter(passed == TRUE) %>%  # Focus on referendums that passed (for RDD)
  pull(vote_date) %>%
  unique() %>%
  sort()

cat("Found", length(vote_dates), "voting days with passed referendums\n")

# =============================================================================
# 3. Fetch municipal-level results for each vote date
# =============================================================================

fetch_vote_results <- function(vote_date) {
  date_str <- format(vote_date, "%Y%m%d")
  url <- paste0(
    "https://ogd-static.voteinfo-app.ch/v1/ogd/sd-t-17-02-",
    date_str, "-eidgAbstimmung.json"
  )

  tryCatch({
    resp <- GET(url, timeout(30))
    if (status_code(resp) != 200) {
      return(NULL)
    }

    data <- content(resp, as = "text", encoding = "UTF-8") %>%
      fromJSON(flatten = TRUE)

    # Extract municipal results for each proposal
    schweiz <- data$schweiz
    if (is.null(schweiz$vorlagen)) {
      return(NULL)
    }

    results <- map_dfr(schweiz$vorlagen, function(vorlage) {
      vorlage_id <- vorlage$vorlagenId
      vorlage_title <- vorlage$vorlagenTitel
      vorlage_accepted <- vorlage$vorlageAngenommen

      # Get all municipalities across cantons
      kantone <- vorlage$kantone
      if (is.null(kantone)) return(NULL)

      muni_results <- map_dfr(kantone, function(kanton) {
        kanton_id <- kanton$geoLevelnummer
        kanton_name <- kanton$geoLevelname
        gemeinden <- kanton$gemeinden

        if (is.null(gemeinden) || length(gemeinden) == 0) {
          return(NULL)
        }

        tibble(
          vote_date = vote_date,
          vorlage_id = vorlage_id,
          vorlage_title = vorlage_title,
          vorlage_accepted = vorlage_accepted,
          kanton_id = kanton_id,
          kanton_name = kanton_name,
          gemeinde_id = gemeinden$geoLevelnummer,
          gemeinde_name = gemeinden$geoLevelname,
          yes_pct = map_dbl(gemeinden$resultat, ~ .x$jaStimmenInProzent %||% NA_real_),
          yes_count = map_int(gemeinden$resultat, ~ .x$jaStimmenAbsolut %||% NA_integer_),
          no_count = map_int(gemeinden$resultat, ~ .x$neinStimmenAbsolut %||% NA_integer_),
          turnout_pct = map_dbl(gemeinden$resultat, ~ .x$stimmbeteiligungInProzent %||% NA_real_),
          eligible_voters = map_int(gemeinden$resultat, ~ .x$anzahlStimmberechtigte %||% NA_integer_),
          counted = map_lgl(gemeinden$resultat, ~ .x$gebietAusgezaehlt %||% FALSE)
        )
      })

      return(muni_results)
    })

    return(results)

  }, error = function(e) {
    cat("Error fetching", date_str, ":", e$message, "\n")
    return(NULL)
  })
}

# Fetch in parallel with progress
cat("\nFetching municipal results (this may take a while)...\n")

# Start with recent years (more complete data)
recent_dates <- vote_dates[vote_dates >= "2010-01-01"]
cat("Fetching", length(recent_dates), "recent vote dates (2010+)...\n")

results_list <- future_map(
  recent_dates,
  fetch_vote_results,
  .progress = TRUE,
  .options = furrr_options(seed = TRUE)
)

# Combine results
municipal_results <- bind_rows(results_list) %>%
  filter(!is.na(yes_pct), counted == TRUE)

cat("\nFetched", nrow(municipal_results), "municipality-proposal observations\n")
cat("Covering", n_distinct(municipal_results$vote_date), "vote dates\n")
cat("Covering", n_distinct(municipal_results$gemeinde_id), "unique municipalities\n")

# Save results
write_csv(municipal_results, "../data/municipal_results_raw.csv")

# =============================================================================
# 4. Summary statistics
# =============================================================================

cat("\n=== Summary Statistics ===\n")

municipal_results %>%
  summarise(
    n_obs = n(),
    n_votes = n_distinct(vote_date),
    n_proposals = n_distinct(vorlage_id),
    n_municipalities = n_distinct(gemeinde_id),
    mean_turnout = mean(turnout_pct, na.rm = TRUE),
    mean_yes_pct = mean(yes_pct, na.rm = TRUE),
    pct_close = mean(abs(yes_pct - 50) < 10, na.rm = TRUE) * 100
  ) %>%
  print()

cat("\nData saved to ../data/\n")
cat("Done.\n")
