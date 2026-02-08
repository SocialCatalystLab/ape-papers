# ==============================================================================
# 01_fetch_data.R
# Fetch all data for sub-national DiD analysis of Dutch nitrogen crisis
# Paper 184: Revision of apep_0128
# ==============================================================================

source("00_packages.R")

# Create data directories
dir.create("../data/raw", recursive = TRUE, showWarnings = FALSE)
dir.create("../data/processed", recursive = TRUE, showWarnings = FALSE)

# ==============================================================================
# Part A: CBS Municipality Housing Prices (table 83625ENG)
# Annual average purchase prices by municipality
# ==============================================================================
cat("\n=== Part A: CBS Municipality Housing Prices (83625ENG) ===\n")

tryCatch({
  cbs_housing <- cbs_get_data("83625ENG")
  cat(sprintf("  Raw rows: %d\n", nrow(cbs_housing)))
  cat(sprintf("  Columns: %s\n", paste(names(cbs_housing), collapse = ", ")))

  # Filter to municipalities (GM codes)
  cbs_housing$Regions <- trimws(cbs_housing$Regions)
  cbs_housing <- cbs_housing[grepl("^GM", cbs_housing$Regions), ]
  cat(sprintf("  Municipality rows: %d\n", nrow(cbs_housing)))
  cat(sprintf("  Unique municipalities: %d\n", length(unique(cbs_housing$Regions))))
  cat(sprintf("  Periods: %s\n", paste(sort(unique(cbs_housing$Periods)), collapse = ", ")))

  saveRDS(cbs_housing, "../data/raw/cbs_housing_prices.rds")
  cat("  Saved: data/raw/cbs_housing_prices.rds\n")
}, error = function(e) {
  cat("  ERROR fetching 83625ENG:", conditionMessage(e), "\n")
})

# ==============================================================================
# Part B: CBS Building Permits (table 83671NED)
# Building permits for dwellings by municipality, quarterly
# ==============================================================================
cat("\n=== Part B: CBS Building Permits (83671NED) ===\n")

tryCatch({
  # Fetch all data — filter by Opdrachtgever=Totaal, Eigendom=Totaal
  cbs_permits <- cbs_get_data("83671NED",
                               Opdrachtgever = "T001209",
                               Eigendom = "T001258")
  cat(sprintf("  Raw rows: %d\n", nrow(cbs_permits)))
  cat(sprintf("  Columns: %s\n", paste(names(cbs_permits), collapse = ", ")))

  # Filter to municipalities (GM codes)
  cbs_permits$RegioS <- trimws(cbs_permits$RegioS)
  cbs_permits <- cbs_permits[grepl("^GM", cbs_permits$RegioS), ]
  cat(sprintf("  Municipality rows: %d\n", nrow(cbs_permits)))
  cat(sprintf("  Unique municipalities: %d\n", length(unique(cbs_permits$RegioS))))
  cat(sprintf("  Sample periods: %s\n",
              paste(head(sort(unique(cbs_permits$Perioden)), 10), collapse = ", ")))

  saveRDS(cbs_permits, "../data/raw/cbs_building_permits.rds")
  cat("  Saved: data/raw/cbs_building_permits.rds\n")
}, error = function(e) {
  cat("  ERROR fetching 83671NED:", conditionMessage(e), "\n")
})

# ==============================================================================
# Part C: CBS COROP Quarterly Price Indices (table 85819ENG)
# Quarterly housing price index at COROP region level (~40 regions)
# ==============================================================================
cat("\n=== Part C: CBS COROP Quarterly Price Indices (85819ENG) ===\n")

tryCatch({
  cbs_corop <- cbs_get_data("85819ENG")
  cat(sprintf("  Raw rows: %d\n", nrow(cbs_corop)))
  cat(sprintf("  Columns: %s\n", paste(names(cbs_corop), collapse = ", ")))

  # Inspect region types
  cbs_corop$Regions <- trimws(cbs_corop$Regions)
  region_prefixes <- unique(substr(cbs_corop$Regions, 1, 2))
  cat(sprintf("  Region prefixes: %s\n", paste(region_prefixes, collapse = ", ")))
  cat(sprintf("  Unique regions: %d\n", length(unique(cbs_corop$Regions))))
  cat(sprintf("  Sample periods: %s\n",
              paste(head(sort(unique(cbs_corop$Periods)), 10), collapse = ", ")))

  saveRDS(cbs_corop, "../data/raw/cbs_corop_prices.rds")
  cat("  Saved: data/raw/cbs_corop_prices.rds\n")
}, error = function(e) {
  cat("  ERROR fetching 85819ENG:", conditionMessage(e), "\n")
})

# ==============================================================================
# Part D: CBS Dwelling Stock (table 81955NED)
# Housing stock changes by municipality
# ==============================================================================
cat("\n=== Part D: CBS Dwelling Stock (81955NED) ===\n")

tryCatch({
  cbs_stock <- cbs_get_data("81955NED")
  cat(sprintf("  Raw rows: %d\n", nrow(cbs_stock)))
  cat(sprintf("  Columns: %s\n", paste(names(cbs_stock), collapse = ", ")))

  # Filter to municipalities
  cbs_stock$RegioS <- trimws(cbs_stock$RegioS)
  cbs_stock <- cbs_stock[grepl("^GM", cbs_stock$RegioS), ]
  cat(sprintf("  Municipality rows: %d\n", nrow(cbs_stock)))
  cat(sprintf("  Unique municipalities: %d\n", length(unique(cbs_stock$RegioS))))

  saveRDS(cbs_stock, "../data/raw/cbs_dwelling_stock.rds")
  cat("  Saved: data/raw/cbs_dwelling_stock.rds\n")
}, error = function(e) {
  cat("  ERROR fetching 81955NED:", conditionMessage(e), "\n")
})

# ==============================================================================
# Part E: GIS Data — Natura 2000 Sites (PDOK WFS)
# ==============================================================================
cat("\n=== Part E: Natura 2000 GIS Data (PDOK WFS) ===\n")

tryCatch({
  # Total sites: 209 — fetch in batches of 200
  n2000_all <- list()
  start_idx <- 0
  batch_size <- 200
  page <- 1

  repeat {
    url <- paste0(
      "https://service.pdok.nl/rvo/natura2000/wfs/v1_0?",
      "service=WFS&version=2.0.0&request=GetFeature&",
      "typeName=natura2000:natura2000&outputFormat=application/json&",
      "count=", batch_size, "&startIndex=", start_idx
    )
    cat(sprintf("  Fetching page %d (startIndex=%d)...\n", page, start_idx))

    resp <- httr::GET(url, httr::timeout(120))
    if (httr::status_code(resp) != 200) {
      cat(sprintf("  HTTP %d — stopping pagination\n", httr::status_code(resp)))
      break
    }

    batch <- st_read(httr::content(resp, as = "text", encoding = "UTF-8"), quiet = TRUE)
    cat(sprintf("  Got %d features\n", nrow(batch)))

    if (nrow(batch) == 0) break
    n2000_all[[page]] <- batch

    if (nrow(batch) < batch_size) break
    start_idx <- start_idx + batch_size
    page <- page + 1
    Sys.sleep(1)
  }

  if (length(n2000_all) > 0) {
    n2000 <- do.call(rbind, n2000_all)
    cat(sprintf("  Total Natura 2000 sites: %d\n", nrow(n2000)))
    cat(sprintf("  CRS: %s\n", st_crs(n2000)$input))
    cat(sprintf("  Columns: %s\n", paste(names(n2000), collapse = ", ")))

    # Save as geopackage
    st_write(n2000, "../data/raw/natura2000_nl.gpkg", delete_dsn = TRUE, quiet = TRUE)
    cat("  Saved: data/raw/natura2000_nl.gpkg\n")
  }
}, error = function(e) {
  cat("  ERROR fetching Natura 2000:", conditionMessage(e), "\n")
})

# ==============================================================================
# Part F: GIS Data — Municipality Boundaries (PDOK WFS, 2023)
# ==============================================================================
cat("\n=== Part F: Municipality Boundaries (PDOK WFS) ===\n")

tryCatch({
  # Total municipalities: ~424 — fetch in batches of 500
  muni_all <- list()
  start_idx <- 0
  batch_size <- 500
  page <- 1

  repeat {
    url <- paste0(
      "https://service.pdok.nl/cbs/wijkenbuurten/2023/wfs/v1_0?",
      "service=WFS&version=2.0.0&request=GetFeature&",
      "typename=gemeenten&outputFormat=application/json&",
      "count=", batch_size, "&startIndex=", start_idx
    )
    cat(sprintf("  Fetching page %d (startIndex=%d)...\n", page, start_idx))

    resp <- httr::GET(url, httr::timeout(120))
    if (httr::status_code(resp) != 200) {
      cat(sprintf("  HTTP %d — stopping pagination\n", httr::status_code(resp)))
      break
    }

    batch <- st_read(httr::content(resp, as = "text", encoding = "UTF-8"), quiet = TRUE)
    cat(sprintf("  Got %d features\n", nrow(batch)))

    if (nrow(batch) == 0) break
    muni_all[[page]] <- batch

    if (nrow(batch) < batch_size) break
    start_idx <- start_idx + batch_size
    page <- page + 1
    Sys.sleep(1)
  }

  if (length(muni_all) > 0) {
    muni <- do.call(rbind, muni_all)

    # Remove "Buitenland" (foreign) and water-only codes
    muni <- muni[muni$gemeentecode != "GM0998", ]

    cat(sprintf("  Total municipalities: %d\n", nrow(muni)))
    cat(sprintf("  CRS: %s\n", st_crs(muni)$input))

    st_write(muni, "../data/raw/municipality_boundaries.gpkg", delete_dsn = TRUE, quiet = TRUE)
    cat("  Saved: data/raw/municipality_boundaries.gpkg\n")
  }
}, error = function(e) {
  cat("  ERROR fetching municipality boundaries:", conditionMessage(e), "\n")
})

# ==============================================================================
# Part G: FRED National HPI (BIS data for cross-country synthetic control)
# ==============================================================================
cat("\n=== Part G: FRED National HPI ===\n")

fred_api_key <- Sys.getenv("FRED_API_KEY")

if (fred_api_key == "") {
  cat("  WARNING: FRED_API_KEY not set. Skipping FRED data.\n")
} else {
  country_series <- tribble(
    ~country, ~series_id,
    "Netherlands", "QNLR628BIS",
    "Germany", "QDER628BIS",
    "Belgium", "QBER628BIS",
    "France", "QFRR628BIS",
    "Austria", "QATR628BIS",
    "United Kingdom", "QGBR628BIS",
    "Denmark", "QDKR628BIS",
    "Sweden", "QSER628BIS",
    "Finland", "QFIR628BIS",
    "Norway", "QNOR628BIS",
    "Switzerland", "QCHR628BIS",
    "Ireland", "QIER628BIS",
    "Italy", "QITR628BIS",
    "Spain", "QESR628BIS",
    "Portugal", "QPTR628BIS",
    "Luxembourg", "QLUR628BIS"
  )

  fetch_fred_series <- function(series_id, api_key) {
    url <- paste0(
      "https://api.stlouisfed.org/fred/series/observations?",
      "series_id=", series_id,
      "&api_key=", api_key,
      "&file_type=json",
      "&observation_start=2005-01-01"
    )
    response <- httr::GET(url, httr::timeout(60))
    if (httr::status_code(response) != 200) {
      warning("Failed to fetch ", series_id, ": HTTP ", httr::status_code(response))
      return(NULL)
    }
    content <- httr::content(response, as = "text", encoding = "UTF-8")
    data <- jsonlite::fromJSON(content)
    if (is.null(data$observations)) return(NULL)
    data$observations %>%
      mutate(
        date = ymd(date),
        value = as.numeric(value),
        series_id = series_id
      ) %>%
      filter(!is.na(value))
  }

  cat(sprintf("  Fetching data for %d countries...\n", nrow(country_series)))
  all_fred_data <- list()
  for (i in 1:nrow(country_series)) {
    country <- country_series$country[i]
    series_id <- country_series$series_id[i]
    cat(sprintf("    %s (%s)...", country, series_id))
    data <- fetch_fred_series(series_id, fred_api_key)
    if (!is.null(data)) {
      data$country <- country
      all_fred_data[[country]] <- data
      cat(sprintf(" %d obs\n", nrow(data)))
    } else {
      cat(" FAILED\n")
    }
    Sys.sleep(0.5)
  }

  fred_hpi <- bind_rows(all_fred_data) %>%
    select(country, date, value) %>%
    rename(hpi = value) %>%
    mutate(year = year(date), quarter = quarter(date))

  cat(sprintf("  FRED data: %d observations, %d countries\n",
              nrow(fred_hpi), n_distinct(fred_hpi$country)))

  saveRDS(fred_hpi, "../data/raw/fred_hpi_all_countries.rds")
  cat("  Saved: data/raw/fred_hpi_all_countries.rds\n")
}

# ==============================================================================
# Summary
# ==============================================================================
cat("\n=== Downloaded Files ===\n")
for (dir in c("../data/raw", "../data/processed")) {
  cat(sprintf("\n%s:\n", dir))
  data_files <- list.files(dir, full.names = TRUE)
  for (f in data_files) {
    info <- file.info(f)
    cat(sprintf("  %s: %.1f KB\n", basename(f), info$size / 1024))
  }
}

cat("\n=== Data fetch complete ===\n")
