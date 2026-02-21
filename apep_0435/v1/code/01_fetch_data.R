## ============================================================
## 01_fetch_data.R — Fetch Swiss referendum + BFS covariate data
## apep_0435: Convergence of Gender Attitudes in Swiss Municipalities
## ============================================================

source("00_packages.R")

DATA_DIR <- "../data"
dir.create(DATA_DIR, showWarnings = FALSE, recursive = TRUE)

## ---------------------------------------------------------------
## 1. Federal referendum results at Gemeinde level (swissdd)
## ---------------------------------------------------------------
cat("=== Fetching referendum data from swissdd ===\n")

library(swissdd)

# Gender-relevant referenda (vote dates)
gender_dates <- c(
  "1981-06-14",  # Gleichstellungsartikel (equal rights in constitution)
  "1984-12-02",  # Maternity insurance initiative (rejected ~84%)
  "1999-06-13",  # Maternity insurance (rejected ~61%)
  "2004-09-26",  # Maternity insurance (approved ~56%)
  "2020-09-27",  # Paternity leave (approved ~60%)
  "2021-09-26"   # Same-sex marriage (approved ~64%)
)

# Non-gender referenda for falsification
falsification_dates <- c(
  "2014-02-09",  # Masseneinwanderung (mass immigration initiative)
  "2020-09-27",  # Kampfflugzeuge (fighter jets - same date as paternity!)
  "2020-11-29",  # Konzernverantwortungsinitiative (corporate responsibility)
  "2021-03-07"   # Verhüllungsverbot (burqa ban)
)

all_dates <- unique(c(gender_dates, falsification_dates))

# Fetch all national vote results at municipality level
# swissdd's get_nationalvotes fetches from opendata.swiss
# Note: data is available from 1981 onwards at municipality level

cat("Fetching national votes (1981-2021) at municipality level...\n")
tryCatch({
  all_votes <- get_nationalvotes(
    from_date = "1981-01-01",
    to_date = "2022-01-01",
    geolevel = "municipality"
  )
  cat(sprintf("  Fetched %d rows covering %d unique vote dates\n",
              nrow(all_votes), length(unique(all_votes$votedate))))
  saveRDS(all_votes, file.path(DATA_DIR, "all_votes_raw.rds"))
}, error = function(e) {
  cat("swissdd fetch failed:", conditionMessage(e), "\n")
  cat("Trying direct JSON approach from opendata.swiss...\n")

  # Fallback: direct JSON from BFS
  fetch_vote_json <- function(date_str) {
    # Format: YYYYMMDD
    d <- gsub("-", "", date_str)
    url <- sprintf(
      "https://ogd-static.voteinfo-app.ch/v4/ogd/sd-t-17-02-%s-eidgAbstimmung.json", d
    )
    cat(sprintf("  Fetching %s from %s\n", date_str, url))
    resp <- tryCatch(GET(url, timeout(30)), error = function(e) NULL)
    if (is.null(resp) || status_code(resp) != 200) {
      cat(sprintf("  Failed for %s (status: %s)\n", date_str,
                  ifelse(is.null(resp), "timeout", status_code(resp))))
      return(NULL)
    }
    content(resp, as = "text", encoding = "UTF-8") |> fromJSON(flatten = TRUE)
  }

  results_list <- list()
  for (d in all_dates) {
    res <- fetch_vote_json(d)
    if (!is.null(res)) results_list[[d]] <- res
    Sys.sleep(1)
  }
  saveRDS(results_list, file.path(DATA_DIR, "votes_json_raw.rds"))
})

## ---------------------------------------------------------------
## 2. BFS population and demographic data at Gemeinde level
## ---------------------------------------------------------------
cat("\n=== Fetching BFS Gemeinde-level covariates ===\n")

library(BFS)

# Try to get catalog and find relevant datasets
cat("Fetching BFS data catalog...\n")
tryCatch({
  catalog <- bfs_get_catalog_data(language = "en")
  cat(sprintf("  Found %d datasets in BFS catalog\n", nrow(catalog)))

  # Search for population by municipality
  pop_datasets <- catalog |>
    filter(str_detect(tolower(title), "population|bevölkerung|gemeinde|municipality"))
  cat(sprintf("  Found %d potential population datasets\n", nrow(pop_datasets)))

  if (nrow(pop_datasets) > 0) {
    cat("  Top matches:\n")
    print(head(pop_datasets[, c("title", "number_bfs")], 10))
  }

  saveRDS(catalog, file.path(DATA_DIR, "bfs_catalog.rds"))
}, error = function(e) {
  cat("BFS catalog fetch failed:", conditionMessage(e), "\n")
})

# Fetch Gemeinde portrait data directly from BFS PXWeb API
cat("\nFetching Gemeinde portrait from BFS PXWeb...\n")
tryCatch({
  # Gemeindeporträt: key statistics per municipality
  # This includes population, language, religion, etc.
  base_url <- "https://www.pxweb.bfs.admin.ch/api/v1/de/"

  # List available databases
  resp <- GET(base_url, timeout(30))
  if (status_code(resp) == 200) {
    dbs <- content(resp, as = "text", encoding = "UTF-8") |> fromJSON()
    cat(sprintf("  Found %d PXWeb databases\n", length(dbs)))

    # Look for municipality-level population data
    pop_keywords <- c("px-x-0102", "px-x-0104", "px-x-0105")
    for (kw in pop_keywords) {
      url2 <- paste0(base_url, kw)
      r2 <- tryCatch(GET(url2, timeout(15)), error = function(e) NULL)
      if (!is.null(r2) && status_code(r2) == 200) {
        cat(sprintf("  Database %s accessible\n", kw))
      }
    }
  }
}, error = function(e) {
  cat("PXWeb fetch failed:", conditionMessage(e), "\n")
})

## ---------------------------------------------------------------
## 3. Gemeinde characteristics from opendata.swiss
## ---------------------------------------------------------------
cat("\n=== Fetching Gemeinde characteristics from opendata.swiss ===\n")

# BFS Gemeindeporträt - comprehensive municipality indicators
# Available as CSV download
gemeinde_portrait_url <- "https://www.atlas.bfs.admin.ch/core/projects/13/xc/csv/2024-AG-3-1-cc.csv"

tryCatch({
  resp <- GET(gemeinde_portrait_url, timeout(60))
  if (status_code(resp) == 200) {
    writeLines(content(resp, as = "text", encoding = "UTF-8"),
               file.path(DATA_DIR, "gemeinde_portrait.csv"))
    cat("  Downloaded Gemeindeporträt CSV\n")
  } else {
    cat(sprintf("  Gemeindeporträt download failed (status %d)\n", status_code(resp)))
  }
}, error = function(e) {
  cat("  Gemeindeporträt download failed:", conditionMessage(e), "\n")
})

# Also try the regional statistics database
regional_url <- "https://dam-api.bfs.admin.ch/hub/api/dam/assets/32007766/master"
tryCatch({
  resp <- GET(regional_url, timeout(60))
  if (status_code(resp) == 200) {
    writeBin(content(resp, "raw"), file.path(DATA_DIR, "regional_portraits.xlsx"))
    cat("  Downloaded regional portraits Excel\n")
  }
}, error = function(e) {
  cat("  Regional portraits download failed:", conditionMessage(e), "\n")
})

## ---------------------------------------------------------------
## 4. Language regions mapping
## ---------------------------------------------------------------
cat("\n=== Fetching language region mapping ===\n")

# BFS publishes language regions as spatial data
# Gemeinde → language region mapping
# French, German, Italian, Romansh language regions
# Let's create a mapping from known cantonal language regions

language_mapping <- tibble(
  canton = c("AG", "AI", "AR", "BE", "BL", "BS", "FR", "GE", "GL", "GR",
             "JU", "LU", "NE", "NW", "OW", "SG", "SH", "SO", "SZ", "TG",
             "TI", "UR", "VD", "VS", "ZG", "ZH"),
  primary_language = c("de", "de", "de", "de", "de", "de", "fr", "fr", "de", "de",
                       "fr", "de", "fr", "de", "de", "de", "de", "de", "de", "de",
                       "it", "de", "fr", "fr", "de", "de"),
  # Some cantons are bilingual
  bilingual = c(FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, TRUE, FALSE, FALSE, TRUE,
                FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE,
                FALSE, FALSE, FALSE, TRUE, FALSE, FALSE),
  # Women's suffrage adoption year (cantonal level)
  suffrage_year = c(1971, 1990, 1989, 1971, 1968, 1966, 1971, 1960, 1971, 1972,
                    1979, 1971, 1959, 1972, 1972, 1972, 1971, 1971, 1971, 1971,
                    1969, 1971, 1959, 1970, 1971, 1970),
  # Historically dominant religion
  hist_religion = c("mixed", "cath", "prot", "prot", "prot", "prot", "cath", "prot",
                    "prot", "mixed", "cath", "cath", "prot", "cath", "cath", "cath",
                    "prot", "cath", "cath", "prot", "cath", "cath", "prot", "cath",
                    "mixed", "prot")
)

saveRDS(language_mapping, file.path(DATA_DIR, "canton_characteristics.rds"))
cat(sprintf("  Created canton characteristics mapping (%d cantons)\n", nrow(language_mapping)))

## ---------------------------------------------------------------
## 5. Swissvotes metadata (complete federal vote database)
## ---------------------------------------------------------------
cat("\n=== Fetching Swissvotes metadata ===\n")

swissvotes_url <- "https://swissvotes.ch/page/dataset/swissvotes_dataset.csv"
tryCatch({
  resp <- GET(swissvotes_url, timeout(60))
  if (status_code(resp) == 200) {
    raw <- content(resp, as = "raw")
    writeBin(raw, file.path(DATA_DIR, "swissvotes_dataset.csv"))
    cat("  Downloaded Swissvotes dataset\n")

    # Try to read it (encoding may be tricky)
    sv <- tryCatch(
      read_csv(file.path(DATA_DIR, "swissvotes_dataset.csv"),
               locale = locale(encoding = "UTF-8"),
               show_col_types = FALSE),
      error = function(e) {
        read_csv(file.path(DATA_DIR, "swissvotes_dataset.csv"),
                 locale = locale(encoding = "latin1"),
                 show_col_types = FALSE)
      }
    )
    cat(sprintf("  Loaded %d votes from Swissvotes\n", nrow(sv)))
    saveRDS(sv, file.path(DATA_DIR, "swissvotes.rds"))
  }
}, error = function(e) {
  cat("  Swissvotes download failed:", conditionMessage(e), "\n")
})

cat("\n=== Data fetching complete ===\n")
cat("Files saved to:", normalizePath(DATA_DIR), "\n")
cat("Contents:\n")
for (f in list.files(DATA_DIR)) {
  size <- file.size(file.path(DATA_DIR, f))
  cat(sprintf("  %s (%s)\n", f, format(size, big.mark = ",")))
}
