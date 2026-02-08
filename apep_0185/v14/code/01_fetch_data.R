# ==============================================================================
# Paper 188: Moral Foundations Under Digital Pressure
# 01_fetch_data.R - Data Acquisition
#
# Revision of apep_0052. Ground-up rebuild with Enke framing.
# ==============================================================================

source("00_packages.R")

cat("=== Paper 188: Fetching Data for Moral Foundations Under Digital Pressure ===\n")
cat("    Revision of apep_0052. Ground-up rebuild with Enke framing.\n\n")

# Create data directory if needed
if (!dir.exists("../data")) dir.create("../data", recursive = TRUE)
if (!dir.exists("../data/localview")) dir.create("../data/localview", recursive = TRUE)

# ==============================================================================
# 1. LOCALVIEW DATABASE (Harvard Dataverse DOI: 10.7910/DVN/NJTBEM)
#
# Local government meeting transcripts with pre-computed eMFD moral foundations
# scores. This is the primary outcome dataset.
#
# Key columns: place FIPS, year/month, moral foundations scores
# (care, fairness, loyalty, authority, sanctity proportions)
# ==============================================================================

cat("1. Fetching LocalView Database from Harvard Dataverse...\n")
cat("   DOI: 10.7910/DVN/NJTBEM\n")
cat("   Strategy: Download one year at a time to keep memory low.\n")

# Strategy: Query Dataverse API for file listing, identify ALL yearly
# meetings.YYYY.parquet files, download each one at a time, extract the
# columns we need, then delete the raw file to save disk/memory.

localview_doi <- "doi:10.7910/DVN/NJTBEM"
dataverse_base <- "https://dataverse.harvard.edu"

# Step 1: Query dataset metadata to get file listing
cat("   Querying Dataverse API for dataset file listing...\n")

dataset_url <- paste0(
  dataverse_base,
  "/api/datasets/:persistentId?persistentId=", localview_doi
)

dataset_resp <- tryCatch({
  httr::GET(dataset_url, httr::timeout(60))
}, error = function(e) {
  stop("Dataset metadata query failed: ", conditionMessage(e))
})

if (httr::status_code(dataset_resp) != 200) {
  stop("Dataverse API returned HTTP ", httr::status_code(dataset_resp))
}

dataset_meta <- jsonlite::fromJSON(
  httr::content(dataset_resp, "text", encoding = "UTF-8"),
  flatten = TRUE
)

files_df <- tryCatch({
  latest <- dataset_meta$data$latestVersion
  files_info <- latest$files
  data.frame(
    id = files_info$dataFile.id,
    filename = files_info$dataFile.filename,
    filesize = files_info$dataFile.filesize,
    stringsAsFactors = FALSE
  )
}, error = function(e) {
  stop("Could not parse Dataverse file listing: ", conditionMessage(e))
})

cat("   Found", nrow(files_df), "files in dataset.\n")

# Step 2: Identify all meetings.YYYY.parquet files
meeting_files <- files_df[grepl("^meetings\\.\\d{4}\\.parquet$", files_df$filename), ]
meeting_files <- meeting_files[order(meeting_files$filename), ]

cat("   Meeting parquet files:", nrow(meeting_files), "\n")
for (i in seq_len(nrow(meeting_files))) {
  cat(sprintf("      %s (%.0f MB)\n", meeting_files$filename[i],
              meeting_files$filesize[i] / 1e6))
}

if (nrow(meeting_files) == 0) {
  stop("No meetings.YYYY.parquet files found in LocalView dataset.")
}

# Step 3: Download one year at a time, extract needed columns, discard raw
# Columns we need from LocalView: FIPS identifiers, date, caption text
# The eMFD scoring will be done in 02_clean_data.R on the caption_text

localview_chunks <- list()

for (i in seq_len(nrow(meeting_files))) {
  fname <- meeting_files$filename[i]
  fid <- meeting_files$id[i]
  fsize_mb <- meeting_files$filesize[i] / 1e6

  cat(sprintf("   [%d/%d] Downloading %s (%.0f MB)...",
              i, nrow(meeting_files), fname, fsize_mb))

  dest_path <- file.path("../data/localview", fname)
  file_url <- paste0(dataverse_base, "/api/access/datafile/", fid)

  # Use longer timeout for large files; retry up to 2 times
  dl_timeout <- max(300, fsize_mb * 2)  # At least 5 min, or 2 sec/MB
  dl_ok <- FALSE
  for (attempt in 1:2) {
    dl_ok <- tryCatch({
      old_timeout <- getOption("timeout")
      options(timeout = dl_timeout)
      on.exit(options(timeout = old_timeout), add = TRUE)
      download.file(file_url, dest_path, mode = "wb", quiet = TRUE)
      TRUE
    }, error = function(e) {
      if (attempt < 2) {
        cat(sprintf(" attempt %d failed, retrying...", attempt))
        Sys.sleep(5)
      } else {
        cat(" DOWNLOAD FAILED:", conditionMessage(e))
      }
      FALSE
    })
    if (dl_ok) break
  }

  if (!dl_ok || !file.exists(dest_path)) {
    cat(" skipping.\n")
    next
  }

  # Read parquet, keep only columns we need, then delete the file
  chunk <- tryCatch({
    raw <- arrow::read_parquet(dest_path)
    cat(sprintf(" %s rows, %d cols.",
                format(nrow(raw), big.mark = ","), ncol(raw)))

    # Keep columns needed for analysis (flexible matching)
    all_cols <- tolower(names(raw))
    keep_cols <- c()

    # FIPS identifiers
    for (pat in c("st_fips", "state_fips", "statefp")) {
      m <- which(all_cols == pat)
      if (length(m) > 0) { keep_cols <- c(keep_cols, names(raw)[m[1]]); break }
    }
    for (pat in c("place_fips", "placefp", "place_name")) {
      m <- which(all_cols == pat)
      if (length(m) > 0) keep_cols <- c(keep_cols, names(raw)[m[1]])
    }
    # Meeting identifiers and text
    for (col in names(raw)) {
      cl <- tolower(col)
      if (cl %in% c("st_fips", "state_name", "place_name", "place_govt",
                     "vid_id", "vid_title", "meeting_date",
                     "caption_text", "vid_length_min",
                     "vid_upload_date", "vid_views")) {
        keep_cols <- c(keep_cols, col)
      }
    }
    keep_cols <- unique(keep_cols)

    # Also keep any eMFD / moral foundations columns if pre-computed
    mf_cols <- names(raw)[grepl("care|fairness|loyalty|authority|sanctity|moral|mfd|emfd|individual|binding",
                                 tolower(names(raw)))]
    keep_cols <- unique(c(keep_cols, mf_cols))

    # Keep whatever columns exist
    existing <- keep_cols[keep_cols %in% names(raw)]
    if (length(existing) == 0) {
      # Fallback: keep all columns (small enough after aggregation)
      existing <- names(raw)
    }

    result <- raw[, existing, drop = FALSE] %>% as_tibble()
    rm(raw)
    gc(verbose = FALSE)
    result
  }, error = function(e) {
    cat(" READ FAILED:", conditionMessage(e), "\n")
    NULL
  })

  # Delete the parquet file to free disk space
  unlink(dest_path)

  if (!is.null(chunk) && nrow(chunk) > 0) {
    localview_chunks[[fname]] <- chunk
    cat(sprintf(" Kept %s rows.\n", format(nrow(chunk), big.mark = ",")))
  } else {
    cat(" empty/failed.\n")
  }

  # Force garbage collection between large files
  gc(verbose = FALSE)
}

if (length(localview_chunks) == 0) {
  stop("FATAL: Could not download any LocalView meeting files.")
}

# Step 4: Combine all years
cat("   Combining all years...\n")
localview_raw <- bind_rows(localview_chunks)
rm(localview_chunks)
gc(verbose = FALSE)

cat("   LocalView combined: ", format(nrow(localview_raw), big.mark = ","),
    " rows x ", ncol(localview_raw), " cols\n", sep = "")
cat("   Column names:", paste(head(names(localview_raw), 20), collapse = ", "), "\n")

# Save as RDS for downstream use
saveRDS(localview_raw, "../data/raw_localview.rds")
cat("   Saved: ../data/raw_localview.rds\n")
rm(localview_raw)
gc(verbose = FALSE)


# ==============================================================================
# 2. ACS BROADBAND DATA (Table B28002) - Census API
#
# Place-level, 5-year ACS estimates, 2013-2022
# B28002_001E: Total households
# B28002_004E: Broadband subscription households
# broadband_rate = B28002_004E / B28002_001E
#
# Also fetch 1-year ACS for places with pop >= 65,000 (robustness)
# ==============================================================================

cat("\n2. Fetching ACS Broadband Data (Table B28002)...\n")

# Census API key (optional but recommended for higher rate limits)
census_key <- Sys.getenv("CENSUS_API_KEY")
has_api_key <- nchar(census_key) > 0
if (has_api_key) {
  cat("   CENSUS_API_KEY found in environment.\n")
} else {
  cat("   WARNING: No CENSUS_API_KEY found. Using unauthenticated requests (lower rate limits).\n")
}

#' Fetch ACS data from Census API
#'
#' @param year ACS year
#' @param variables Character vector of variable codes
#' @param state State FIPS code (or "*" for all)
#' @param geography Geographic level ("place", "county", etc.)
#' @param acs_type "acs5" for 5-year, "acs1" for 1-year
#' @return data.frame or NULL on failure
fetch_acs_data <- function(year, variables, state = "*",
                           geography = "place", acs_type = "acs5") {

  var_string <- paste(c("NAME", variables), collapse = ",")

  base_url <- sprintf(
    "https://api.census.gov/data/%d/acs/%s", year, acs_type
  )

  url <- paste0(
    base_url, "?get=", var_string,
    "&for=", geography, ":*",
    "&in=state:", state
  )

  if (has_api_key) {
    url <- paste0(url, "&key=", census_key)
  }

  tryCatch({
    resp <- httr::GET(url, httr::timeout(60))

    if (httr::status_code(resp) != 200) {
      warning(sprintf("ACS %s %d HTTP %d", acs_type, year,
                       httr::status_code(resp)))
      return(NULL)
    }

    content_text <- httr::content(resp, "text", encoding = "UTF-8")
    data <- jsonlite::fromJSON(content_text)

    if (length(data) <= 1) {
      warning(sprintf("ACS %s %d: empty response", acs_type, year))
      return(NULL)
    }

    df <- as.data.frame(data[-1, ], stringsAsFactors = FALSE)
    colnames(df) <- data[1, ]
    df$year <- year
    df$acs_type <- acs_type

    return(df)
  }, error = function(e) {
    warning(sprintf("ACS %s %d error: %s", acs_type, year,
                     conditionMessage(e)))
    return(NULL)
  })
}

# --- 2A. 5-year ACS broadband (all places, 2013-2022) ---
cat("   2A. Fetching 5-year ACS broadband (all places, 2013-2022)...\n")

broadband_vars <- c("B28002_001E", "B28002_004E")
broadband_5yr_list <- list()

for (yr in 2013:2022) {
  cat(sprintf("     ACS5 %d...", yr))
  df <- fetch_acs_data(yr, broadband_vars, state = "*",
                       geography = "place", acs_type = "acs5")
  if (!is.null(df)) {
    broadband_5yr_list[[as.character(yr)]] <- df
    cat(sprintf(" %s places\n", format(nrow(df), big.mark = ",")))
  } else {
    cat(" FAILED\n")
  }
  Sys.sleep(0.5)  # Rate limiting
}

if (length(broadband_5yr_list) == 0) {
  stop("FATAL: Could not fetch any 5-year ACS broadband data. Check Census API.")
}

broadband_5yr <- bind_rows(broadband_5yr_list) %>%
  mutate(
    total_hh = as.numeric(B28002_001E),
    broadband_hh = as.numeric(B28002_004E),
    broadband_rate = broadband_hh / total_hh,
    st_fips = paste0(state, place)
  ) %>%
  filter(!is.na(broadband_rate), total_hh > 0) %>%
  select(st_fips, state, place, NAME, year, acs_type,
         total_hh, broadband_hh, broadband_rate)

cat(sprintf("   ACS5 Broadband: %s observations across %d years\n",
            format(nrow(broadband_5yr), big.mark = ","),
            n_distinct(broadband_5yr$year)))

# --- 2B. 1-year ACS broadband (places >= 65K pop, robustness) ---
cat("   2B. Fetching 1-year ACS broadband (pop >= 65K, 2013-2022)...\n")

broadband_1yr_list <- list()

for (yr in 2013:2022) {
  cat(sprintf("     ACS1 %d...", yr))
  df <- fetch_acs_data(yr, broadband_vars, state = "*",
                       geography = "place", acs_type = "acs1")
  if (!is.null(df)) {
    broadband_1yr_list[[as.character(yr)]] <- df
    cat(sprintf(" %s places\n", format(nrow(df), big.mark = ",")))
  } else {
    cat(" FAILED (some years may not have 1-year data)\n")
  }
  Sys.sleep(0.5)
}

if (length(broadband_1yr_list) > 0) {
  broadband_1yr <- bind_rows(broadband_1yr_list) %>%
    mutate(
      total_hh = as.numeric(B28002_001E),
      broadband_hh = as.numeric(B28002_004E),
      broadband_rate = broadband_hh / total_hh,
      st_fips = paste0(state, place)
    ) %>%
    filter(!is.na(broadband_rate), total_hh > 0) %>%
    select(st_fips, state, place, NAME, year, acs_type,
           total_hh, broadband_hh, broadband_rate)

  cat(sprintf("   ACS1 Broadband: %s observations across %d years\n",
              format(nrow(broadband_1yr), big.mark = ","),
              n_distinct(broadband_1yr$year)))
} else {
  broadband_1yr <- tibble(
    st_fips = character(), state = character(), place = character(),
    NAME = character(), year = integer(), acs_type = character(),
    total_hh = numeric(), broadband_hh = numeric(), broadband_rate = numeric()
  )
  cat("   WARNING: No 1-year ACS broadband data retrieved.\n")
}

# Combine both
broadband_all <- bind_rows(broadband_5yr, broadband_1yr)

cat(sprintf("   Total broadband observations: %s\n",
            format(nrow(broadband_all), big.mark = ",")))

# Save
saveRDS(broadband_5yr, "../data/raw_acs_broadband_5yr.rds")
saveRDS(broadband_1yr, "../data/raw_acs_broadband_1yr.rds")
saveRDS(broadband_all, "../data/raw_acs_broadband_all.rds")
cat("   Saved: raw_acs_broadband_5yr.rds, raw_acs_broadband_1yr.rds, raw_acs_broadband_all.rds\n")


# ==============================================================================
# 3. ACS DEMOGRAPHICS - Time-Varying Place-Level Controls
#
# B01003_001E: Total population
# B19013_001E: Median household income
# B15003_022E-025E: Bachelor's, Master's, Professional, Doctorate degrees
# B15003_001E: Total (education denominator)
# B02001_001E: Total race, B02001_002E: White alone
# B01002_001E: Median age
# ==============================================================================

cat("\n3. Fetching ACS Demographics (time-varying controls)...\n")

demo_vars <- c(
  "B01003_001E",   # Total population
  "B19013_001E",   # Median household income
  "B15003_022E",   # Bachelor's degree
  "B15003_023E",   # Master's degree
  "B15003_024E",   # Professional degree
  "B15003_025E",   # Doctorate
  "B15003_001E",   # Total education denominator
  "B02001_001E",   # Total race
  "B02001_002E",   # White alone
  "B01002_001E"    # Median age
)

demo_list <- list()

for (yr in 2013:2022) {
  cat(sprintf("     ACS5 demographics %d...", yr))
  df <- fetch_acs_data(yr, demo_vars, state = "*",
                       geography = "place", acs_type = "acs5")
  if (!is.null(df)) {
    demo_list[[as.character(yr)]] <- df
    cat(sprintf(" %s places\n", format(nrow(df), big.mark = ",")))
  } else {
    cat(" FAILED\n")
  }
  Sys.sleep(0.5)
}

if (length(demo_list) == 0) {
  stop("FATAL: Could not fetch any ACS demographic data.")
}

demographics_raw <- bind_rows(demo_list) %>%
  mutate(
    st_fips = paste0(state, place),
    population = as.numeric(B01003_001E),
    median_income = as.numeric(B19013_001E),
    bachelors = as.numeric(B15003_022E),
    masters = as.numeric(B15003_023E),
    professional = as.numeric(B15003_024E),
    doctorate = as.numeric(B15003_025E),
    edu_total = as.numeric(B15003_001E),
    college_total = bachelors + masters + professional + doctorate,
    pct_college = ifelse(edu_total > 0, college_total / edu_total * 100, NA_real_),
    white = as.numeric(B02001_002E),
    race_total = as.numeric(B02001_001E),
    pct_white = ifelse(race_total > 0, white / race_total * 100, NA_real_),
    median_age = as.numeric(B01002_001E),
    log_pop = log(pmax(population, 1)),
    log_income = log(pmax(median_income, 1))
  ) %>%
  select(st_fips, state, place, NAME, year,
         population, log_pop, median_income, log_income,
         pct_college, pct_white, median_age)

cat(sprintf("   Demographics: %s place-years (%d years)\n",
            format(nrow(demographics_raw), big.mark = ","),
            n_distinct(demographics_raw$year)))

# Save
saveRDS(demographics_raw, "../data/raw_acs_demographics.rds")
cat("   Saved: raw_acs_demographics.rds\n")


# ==============================================================================
# 4. COUNTY PRESIDENTIAL ELECTION DATA (MIT Election Data Lab)
#
# 2000-2020 county-level presidential returns
# Used for partisanship classification (heterogeneity analysis)
# ==============================================================================

cat("\n4. Fetching County Presidential Election Data (MIT Election Data Lab)...\n")

# Helper: Parse election data robustly regardless of column naming
parse_election_data <- function(raw) {
  cn <- tolower(names(raw))
  names(raw) <- cn

  # Find the FIPS column (could be county_fips, FIPS, fips, countyfips, etc.)
  fips_col <- NULL
  for (pat in c("county_fips", "countyfips", "fips")) {
    m <- which(cn == pat)
    if (length(m) > 0) { fips_col <- cn[m[1]]; break }
  }
  if (is.null(fips_col)) {
    # Look for any column with "fips" in name
    m <- which(grepl("fips", cn))
    if (length(m) > 0) fips_col <- cn[m[1]]
  }
  if (is.null(fips_col)) stop("No FIPS column found. Columns: ", paste(cn, collapse = ", "))

  # Find year, party, office, candidatevotes columns
  year_col <- cn[cn == "year"][1]
  party_col <- cn[cn %in% c("party", "party_simplified", "party_detailed")][1]
  office_col <- cn[cn == "office"][1]
  votes_col <- cn[cn %in% c("candidatevotes", "candidate_votes", "votes")][1]

  cat("   Detected columns: fips=", fips_col, " year=", year_col,
      " party=", party_col, " office=", office_col, " votes=", votes_col, "\n")

  if (is.na(year_col) || is.na(votes_col)) {
    stop("Missing required columns (year or votes). Columns: ", paste(cn, collapse = ", "))
  }

  df <- raw

  # Filter to presidential elections if office column exists
  if (!is.na(office_col)) {
    df <- df[grepl("president", df[[office_col]], ignore.case = TRUE), ]
  }

  # Filter to target years
  df <- df[df[[year_col]] %in% c(2000, 2004, 2008, 2012, 2016, 2020), ]

  # Standardize FIPS
  df$county_fips_clean <- sprintf("%05d", as.integer(df[[fips_col]]))
  df$state_fips <- substr(df$county_fips_clean, 1, 2)

  # Standardize party
  if (!is.na(party_col)) {
    df$party_clean <- case_when(
      grepl("republican|rep", df[[party_col]], ignore.case = TRUE) ~ "REP",
      grepl("democrat|dem", df[[party_col]], ignore.case = TRUE) ~ "DEM",
      TRUE ~ "OTHER"
    )
  } else {
    df$party_clean <- "OTHER"
  }

  df$votes_num <- as.numeric(df[[votes_col]])

  # Filter valid
  df <- df[!is.na(df$county_fips_clean) & df$county_fips_clean != "   NA" &
           !is.na(df$votes_num), ]

  # Aggregate to county-year-party
  agg <- df %>%
    group_by(county_fips = county_fips_clean, state_fips,
             year = .data[[year_col]], party_clean) %>%
    summarise(votes = sum(votes_num, na.rm = TRUE), .groups = "drop")

  # Pivot wide
  wide <- agg %>%
    pivot_wider(names_from = party_clean, values_from = votes, values_fill = 0)

  # Ensure REP and DEM columns exist
  if (!"REP" %in% names(wide)) wide$REP <- 0
  if (!"DEM" %in% names(wide)) wide$DEM <- 0
  if (!"OTHER" %in% names(wide)) wide$OTHER <- 0

  wide %>%
    mutate(
      total_votes = REP + DEM + OTHER,
      rep_share = ifelse(total_votes > 0, REP / total_votes, NA_real_),
      dem_share = ifelse(total_votes > 0, DEM / total_votes, NA_real_)
    ) %>%
    filter(total_votes > 0)
}

# Try multiple sources
election_data <- tryCatch({
  cat("   Downloading county presidential returns (file ID 6104387)...\n")

  election_file <- tempfile(fileext = ".tab")
  download.file("https://dataverse.harvard.edu/api/access/datafile/6104387",
                election_file, mode = "wb", quiet = TRUE)

  election_raw <- data.table::fread(election_file, header = TRUE,
                                     fill = TRUE, select = 1:20) %>%
    as_tibble()

  cat("   Downloaded", format(nrow(election_raw), big.mark = ","), "rows,",
      ncol(election_raw), "cols\n")
  cat("   Columns:", paste(names(election_raw), collapse = ", "), "\n")

  result <- parse_election_data(election_raw)
  cat("   Processed:", n_distinct(result$county_fips), "counties,",
      n_distinct(result$year), "elections\n")
  result
}, error = function(e) {
  cat("   Primary source failed:", conditionMessage(e), "\n")
  cat("   Trying alternative URL...\n")

  tryCatch({
    alt_file <- tempfile(fileext = ".tab")
    download.file(
      "https://dataverse.harvard.edu/api/access/datafile/:persistentId?persistentId=doi:10.7910/DVN/VOQCHQ/HEIJCQ",
      alt_file, mode = "wb", quiet = TRUE
    )
    alt_raw <- data.table::fread(alt_file, header = TRUE, fill = TRUE) %>% as_tibble()
    cat("   Alternative:", format(nrow(alt_raw), big.mark = ","), "rows\n")
    cat("   Columns:", paste(names(alt_raw), collapse = ", "), "\n")
    parse_election_data(alt_raw)
  }, error = function(e2) {
    cat("   WARNING: Both election data sources failed.\n")
    cat("   Error:", conditionMessage(e2), "\n")
    cat("   Continuing without election data (heterogeneity by partisanship will be limited).\n")
    # Return empty tibble so script continues
    tibble(county_fips = character(), state_fips = character(),
           year = integer(), REP = numeric(), DEM = numeric(),
           OTHER = numeric(), total_votes = numeric(),
           rep_share = numeric(), dem_share = numeric())
  })
})

# Save (even if empty — downstream handles gracefully)
saveRDS(election_data, "../data/raw_presidential_county.rds")
cat("   Election data:", format(nrow(election_data), big.mark = ","), "rows saved.\n")


# ==============================================================================
# 5. USDA RURAL-URBAN CONTINUUM CODES
#
# For rurality classification in heterogeneity analysis
# Codes 1-3 = metro, 4-9 = nonmetro
# ==============================================================================

cat("\n5. Fetching USDA Rural-Urban Continuum Codes...\n")

rucc_data <- tryCatch({
  # USDA ERS moved their files; try the XLS download (2013 version)
  # If readxl is available use it, otherwise try CSV from alternative sources
  rucc_url_xls <- "https://www.ers.usda.gov/media/5769/2013-rural-urban-continuum-codes.xls"

  cat("   Trying USDA ERS XLS download...\n")
  rucc_file <- tempfile(fileext = ".xls")
  download.file(rucc_url_xls, rucc_file, mode = "wb", quiet = TRUE)

  rucc_raw <- tryCatch({
    if (requireNamespace("readxl", quietly = TRUE)) {
      readxl::read_excel(rucc_file) %>% as_tibble()
    } else {
      stop("readxl not available")
    }
  }, error = function(e) {
    # Try reading as tab-delimited in case it's actually text
    data.table::fread(rucc_file, header = TRUE) %>% as_tibble()
  })

  cat("   Downloaded", nrow(rucc_raw), "county RUCC records\n")
  cat("   Columns:", paste(names(rucc_raw), collapse = ", "), "\n")

  # Identify FIPS and RUCC columns dynamically
  rucc_clean <- rucc_raw %>% as_tibble()
  fips_col <- names(rucc_clean)[grepl("fips|FIPS", names(rucc_clean), ignore.case = TRUE)][1]
  rucc_col <- names(rucc_clean)[grepl("RUCC|rucc|continuum|code",
                                       names(rucc_clean), ignore.case = TRUE)]
  rucc_col <- rucc_col[!grepl("description|desc", rucc_col, ignore.case = TRUE)][1]

  if (is.na(fips_col) || is.na(rucc_col)) {
    fips_col <- names(rucc_clean)[1]
    rucc_col <- names(rucc_clean)[grepl("2013", names(rucc_clean))][1]
  }

  rucc_clean %>%
    mutate(
      county_fips = sprintf("%05d", as.integer(.data[[fips_col]])),
      rucc_code = as.integer(.data[[rucc_col]]),
      is_metro = rucc_code <= 3,
      rurality = case_when(
        rucc_code <= 3 ~ "Metro",
        rucc_code <= 6 ~ "Nonmetro Adjacent",
        rucc_code <= 9 ~ "Nonmetro Remote",
        TRUE ~ NA_character_
      )
    ) %>%
    select(county_fips, rucc_code, is_metro, rurality) %>%
    filter(!is.na(rucc_code))
}, error = function(e) {
  cat("   XLS download failed:", conditionMessage(e), "\n")
  cat("   Trying 2023 CSV version from USDA ERS...\n")

  tryCatch({
    # 2023 RUCC codes are available as CSV
    alt_url <- "https://www.ers.usda.gov/media/fao1pjjp/ruralurbancodes2023.csv"
    alt_file <- tempfile(fileext = ".csv")
    download.file(alt_url, alt_file, mode = "wb", quiet = TRUE)
    alt_raw <- read.csv(alt_file, stringsAsFactors = FALSE) %>% as_tibble()

    cat("   Downloaded 2023 RUCC:", nrow(alt_raw), "records\n")
    cat("   Columns:", paste(names(alt_raw), collapse = ", "), "\n")

    fips_col <- names(alt_raw)[grepl("fips|FIPS", names(alt_raw), ignore.case = TRUE)][1]
    rucc_col <- names(alt_raw)[grepl("RUCC|rucc|continuum|code", names(alt_raw), ignore.case = TRUE)]
    rucc_col <- rucc_col[!grepl("description|desc", rucc_col, ignore.case = TRUE)][1]

    alt_raw %>%
      mutate(
        county_fips = sprintf("%05d", as.integer(.data[[fips_col]])),
        rucc_code = as.integer(.data[[rucc_col]]),
        is_metro = rucc_code <= 3,
        rurality = case_when(
          rucc_code <= 3 ~ "Metro",
          rucc_code <= 6 ~ "Nonmetro Adjacent",
          rucc_code <= 9 ~ "Nonmetro Remote",
          TRUE ~ NA_character_
        )
      ) %>%
      select(county_fips, rucc_code, is_metro, rurality) %>%
      filter(!is.na(rucc_code))
  }, error = function(e2) {
    cat("   WARNING: All RUCC download attempts failed.\n")
    cat("   Heterogeneity by rurality will use population-based classification instead.\n")
    # Return empty tibble — downstream will handle gracefully
    tibble(county_fips = character(), rucc_code = integer(),
           is_metro = logical(), rurality = character())
  })
})

# Save
saveRDS(rucc_data, "../data/raw_rucc.rds")
cat("   Saved: raw_rucc.rds\n")


# ==============================================================================
# 6. TIGRIS STATE SHAPEFILES (for choropleth maps)
# ==============================================================================

cat("\n6. Fetching state boundary shapefiles via tigris...\n")

states_sf <- tryCatch({
  sf_data <- tigris::states(cb = TRUE, year = 2019)

  # Exclude territories
  sf_data <- sf_data %>%
    filter(!STATEFP %in% c("72", "78", "69", "66", "60"))

  cat("   Downloaded", nrow(sf_data), "state boundaries\n")
  sf_data
}, error = function(e) {
  cat("   WARNING: tigris state download failed:", conditionMessage(e), "\n")
  cat("   Maps will not be available.\n")
  NULL
})

if (!is.null(states_sf)) {
  saveRDS(states_sf, "../data/raw_states_sf.rds")
  cat("   Saved: raw_states_sf.rds\n")
}

# Also fetch county shapefiles (for place-to-county crosswalk)
cat("   Fetching county boundaries...\n")

counties_sf <- tryCatch({
  sf_data <- tigris::counties(cb = TRUE, year = 2019)

  sf_data <- sf_data %>%
    filter(!STATEFP %in% c("72", "78", "69", "66", "60")) %>%
    mutate(county_fips = paste0(STATEFP, COUNTYFP))

  cat("   Downloaded", nrow(sf_data), "county boundaries\n")
  sf_data
}, error = function(e) {
  cat("   WARNING: tigris county download failed:", conditionMessage(e), "\n")
  NULL
})

if (!is.null(counties_sf)) {
  saveRDS(counties_sf, "../data/raw_counties_sf.rds")
  cat("   Saved: raw_counties_sf.rds\n")
}

# Fetch place boundaries (for place-to-county spatial join)
cat("   Fetching place boundaries (for spatial crosswalk)...\n")

places_sf <- tryCatch({
  sf_data <- tigris::places(cb = TRUE, year = 2019)

  sf_data <- sf_data %>%
    mutate(st_fips = paste0(STATEFP, PLACEFP))

  cat("   Downloaded", nrow(sf_data), "place boundaries\n")
  sf_data
}, error = function(e) {
  cat("   WARNING: tigris place download failed:", conditionMessage(e), "\n")
  NULL
})

if (!is.null(places_sf)) {
  saveRDS(places_sf, "../data/raw_places_sf.rds")
  cat("   Saved: raw_places_sf.rds\n")
}


# ==============================================================================
# 7. PLACE-TO-COUNTY CROSSWALK (Spatial Join)
#
# Map Census places to counties using centroid-based spatial join.
# Needed for merging county-level data (election, RUCC) to place-level panel.
# ==============================================================================

cat("\n7. Creating place-to-county crosswalk...\n")

if (!is.null(places_sf) && !is.null(counties_sf)) {
  crosswalk <- tryCatch({
    # Join place centroids to county polygons
    place_centroids <- sf::st_centroid(places_sf)

    xwalk <- sf::st_join(
      place_centroids,
      counties_sf %>% select(COUNTYFP, county_name = NAME, county_state = STATEFP),
      left = TRUE
    ) %>%
      sf::st_drop_geometry() %>%
      mutate(county_fips = paste0(county_state, COUNTYFP)) %>%
      select(st_fips, county_fips, place_name = NAME, county_name,
             state_fips = STATEFP) %>%
      filter(!is.na(county_fips))

    cat("   Crosswalk created:", nrow(xwalk), "place-county mappings\n")
    xwalk
  }, error = function(e) {
    cat("   WARNING: Spatial crosswalk creation failed:", conditionMessage(e), "\n")
    NULL
  })

  if (!is.null(crosswalk)) {
    saveRDS(crosswalk, "../data/raw_place_county_crosswalk.rds")
    cat("   Saved: raw_place_county_crosswalk.rds\n")
  }
} else {
  cat("   Skipping crosswalk (place or county shapefiles unavailable).\n")
  crosswalk <- NULL
}


# ==============================================================================
# SUMMARY
# ==============================================================================

cat("\n")
cat("=" , rep("=", 60), "\n", sep = "")
cat("=== Data Fetch Complete ===\n")
cat("=" , rep("=", 60), "\n", sep = "")

cat("\nFiles saved to ../data/:\n")

saved_files <- list.files("../data", pattern = "\\.rds$", recursive = TRUE)
for (f in saved_files) {
  fsize <- file.size(file.path("../data", f))
  cat(sprintf("  - %s (%.1f MB)\n", f, fsize / 1e6))
}

cat("\nDatasets summary:\n")
lv_rds <- "../data/raw_localview.rds"
if (file.exists(lv_rds)) {
  lv_info <- file.info(lv_rds)
  cat(sprintf("  1. LocalView:      saved (%.0f MB on disk)\n", lv_info$size / 1e6))
} else {
  cat("  1. LocalView:      NOT FETCHED\n")
}
cat("  2. ACS Broadband: ", format(nrow(broadband_all), big.mark = ","),
    " observations (5yr:", format(nrow(broadband_5yr), big.mark = ","),
    ", 1yr:", format(nrow(broadband_1yr), big.mark = ","), ")\n")
cat("  3. ACS Demographics:", format(nrow(demographics_raw), big.mark = ","),
    " place-years\n")
cat("  4. Elections:     ", format(nrow(election_data), big.mark = ","),
    " county-year obs\n")
cat("  5. RUCC:          ", format(nrow(rucc_data), big.mark = ","),
    " counties\n")
cat("  6. Shapefiles:     states=", ifelse(!is.null(states_sf), nrow(states_sf), 0),
    ", counties=", ifelse(!is.null(counties_sf), nrow(counties_sf), 0),
    ", places=", ifelse(!is.null(places_sf), nrow(places_sf), 0), "\n")
cat("  7. Crosswalk:     ", ifelse(!is.null(crosswalk),
    paste(nrow(crosswalk), "place-county links"), "NOT CREATED"), "\n")

cat("\nNext step: Run 02_clean_data.R to merge and construct analysis panel.\n")
