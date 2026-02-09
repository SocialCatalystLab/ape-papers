# ============================================================================
# APEP-0049 v4 - Transit Funding Discontinuity
# 01b_fetch_fta_data.R - Fetch REAL FTA Section 5307 apportionment data
#
# Downloads actual FTA apportionment tables from transit.dot.gov (via
# Wayback Machine archive) and parses urbanized area funding amounts.
#
# Key output: data/fta_apportionments.csv with UZA-level 5307 funding
# ============================================================================

# Source packages
if (file.exists("00_packages.R")) {
  source("00_packages.R")
} else if (file.exists("code/00_packages.R")) {
  source("code/00_packages.R")
} else {
  stop("Cannot find 00_packages.R - run from code/ directory or paper root")
}

# ============================================================================
# 1. DOWNLOAD FTA TABLE 3 APPORTIONMENT FILES
# ============================================================================

cat("=== Fetching FTA Section 5307 Apportionment Data ===\n")
cat("Source: FTA Table 3 (Section 5307 + 5340 Urbanized Area Formula)\n")
cat("Archive: Wayback Machine (transit.dot.gov blocks programmatic access)\n\n")

# FTA Table 3 URLs by fiscal year (via Wayback Machine)
# These are the official FTA apportionment tables published annually
fta_urls <- list(
  FY2020 = "https://web.archive.org/web/2024/https://www.transit.dot.gov/sites/fta.dot.gov/files/docs/funding/apportionments/147146/fy-2020-full-year-apportionment-table-3-section-5307-urbanized-area-formula.xlsx",
  FY2021 = "https://web.archive.org/web/2024/https://www.transit.dot.gov/sites/fta.dot.gov/files/2021-01/Table-3-FY-2021-full-year-section-5307-urbanized-area-formula-01-19-2021.xlsx",
  FY2022 = "https://web.archive.org/web/2024/https://www.transit.dot.gov/sites/fta.dot.gov/files/2022-04/fy-2022-full-year-apportionment-table-3-section-5307-urbanized-area-formula.xlsx"
)

# ============================================================================
# 2. PARSE FTA TABLE 3 EXCEL FILES
# ============================================================================

parse_fta_table3 <- function(filepath) {
  # FTA Table 3 format:
  # - Header rows (skip ~7), then "URBANIZED AREA/STATE" | "APPORTIONMENT"
  # - Sections: "1,000,000 or more", "200,000-999,999", "50,000-199,999"
  # - Within each section, UZA names with funding amounts
  # - Multi-state UZAs have sub-rows for each state's share

  df <- read_excel(filepath, sheet = 1, skip = 7,
                   col_names = c("uza_name", "apportionment"))

  # Find section boundaries
  section_1m <- grep("Amounts.*1,000,000", df$uza_name)
  section_200k <- grep("Amounts.*200,000", df$uza_name)
  section_50k <- grep("Amounts.*50,000", df$uza_name)

  # Parse each section
  parse_section <- function(start_row, end_row, size_class) {
    section <- df[(start_row + 1):(end_row - 1), ] %>%
      filter(!is.na(apportionment), !is.na(uza_name)) %>%
      filter(!grepl("Total|Subtotal|Section|Amounts|Population|^\\s*$",
                    uza_name, ignore.case = TRUE)) %>%
      mutate(
        apportionment = as.numeric(apportionment),
        size_class = size_class,
        # Identify state sub-rows (indented or state-only names)
        is_state_subrow = !grepl(",", uza_name) &
          nchar(trimws(uza_name)) <= 20 &
          !grepl("\\d", uza_name)
      )
    return(section)
  }

  results <- list()

  if (length(section_1m) > 0 && length(section_200k) > 0) {
    results$large <- parse_section(section_1m[1], section_200k[1], "1M+")
  }
  if (length(section_200k) > 0 && length(section_50k) > 0) {
    results$medium <- parse_section(section_200k[1], section_50k[1], "200k-999k")
  }
  if (length(section_50k) > 0) {
    results$small <- parse_section(section_50k[1], nrow(df), "50k-199k")
  }

  all_uzas <- bind_rows(results)

  # Keep only UZA-level rows (not state sub-allocations)
  uza_level <- all_uzas %>%
    filter(!is_state_subrow) %>%
    select(uza_name, apportionment, size_class)

  return(uza_level)
}

# Download and parse each fiscal year
all_fy_data <- list()

for (fy_name in names(fta_urls)) {
  cat(sprintf("Downloading %s...\n", fy_name))

  tmp <- tempfile(fileext = ".xlsx")
  resp <- tryCatch(
    GET(fta_urls[[fy_name]], timeout(30)),
    error = function(e) NULL
  )

  if (is.null(resp) || status_code(resp) != 200) {
    cat(sprintf("  WARNING: Failed to download %s (skipping)\n", fy_name))
    next
  }

  # Check content type
  ct <- headers(resp)$"content-type"
  if (!grepl("spreadsheet|excel|octet", ct, ignore.case = TRUE)) {
    cat(sprintf("  WARNING: %s returned non-Excel content (skipping)\n", fy_name))
    next
  }

  writeBin(content(resp, "raw"), tmp)
  cat(sprintf("  Downloaded: %s bytes\n", file.info(tmp)$size))

  parsed <- tryCatch(
    parse_fta_table3(tmp),
    error = function(e) {
      cat(sprintf("  WARNING: Parse error for %s: %s\n", fy_name, e$message))
      return(NULL)
    }
  )

  if (!is.null(parsed)) {
    parsed$fiscal_year <- as.integer(gsub("FY", "", fy_name))
    all_fy_data[[fy_name]] <- parsed
    cat(sprintf("  Parsed: %d urbanized areas\n", nrow(parsed)))
  }

  unlink(tmp)
}

if (length(all_fy_data) == 0) {
  stop("Failed to download any FTA apportionment data. Check internet connection.")
}

fta_combined <- bind_rows(all_fy_data)

cat(sprintf("\nTotal FTA records: %d across %d fiscal years\n",
            nrow(fta_combined), length(all_fy_data)))

# ============================================================================
# 3. CLEAN AND STANDARDIZE UZA NAMES
# ============================================================================

cat("\n=== Cleaning UZA Names for Matching ===\n")

fta_combined <- fta_combined %>%
  mutate(
    # Extract primary city name and state(s)
    uza_name_clean = str_trim(uza_name),
    # Extract state abbreviations
    states_fta = str_extract(uza_name_clean, "[A-Z]{2}(-[A-Z]{2})*$"),
    # Extract city portion
    city_name = str_remove(uza_name_clean, ",\\s*[A-Z]{2}(-[A-Z]{2})*$"),
    city_name = str_trim(city_name),
    # Simplified matching key (lowercase first city)
    match_key = str_to_lower(city_name),
    match_key = str_remove(match_key, "-.*$"),  # Keep first city only
    match_key = str_trim(match_key)
  )

# ============================================================================
# 4. MATCH FTA DATA TO CENSUS URBANIZED AREAS
# ============================================================================

cat("\n=== Matching FTA Data to Census UZAs ===\n")

# Load the Census data from 01_fetch_data.R
ua_data <- read_csv(file.path(data_dir, "ua_analysis.csv"), show_col_types = FALSE)

cat("Census UZAs in analysis sample:", nrow(ua_data), "\n")

# Create matching key from Census names
ua_data <- ua_data %>%
  mutate(
    census_city = str_remove(name_clean, ",.*$"),
    match_key = str_to_lower(census_city),
    match_key = str_remove(match_key, "-.*$"),
    match_key = str_trim(match_key)
  )

# Use FY2020 as primary (matches our outcome period 2016-2020)
fta_fy2020 <- fta_combined %>%
  filter(fiscal_year == 2020) %>%
  group_by(match_key) %>%
  summarise(
    fta_apportionment_2020 = sum(apportionment, na.rm = TRUE),
    fta_uza_name = first(uza_name_clean),
    fta_size_class = first(size_class),
    .groups = "drop"
  )

# Match
ua_matched <- ua_data %>%
  left_join(fta_fy2020, by = "match_key")

matched_n <- sum(!is.na(ua_matched$fta_apportionment_2020))
cat("Matched to FTA FY2020:", matched_n, "of", nrow(ua_data), "UZAs\n")

# For UZAs below 50k threshold, they should have $0 (not eligible)
ua_matched <- ua_matched %>%
  mutate(
    fta_funding = case_when(
      eligible_5307 == 0 ~ 0,  # Below threshold = $0 by law
      !is.na(fta_apportionment_2020) ~ fta_apportionment_2020,
      eligible_5307 == 1 ~ NA_real_  # Above but unmatched
    ),
    fta_per_capita = ifelse(population_2010 > 0 & !is.na(fta_funding),
                            fta_funding / population_2010, NA_real_)
  )

cat("\nFunding summary for eligible UZAs (pop >= 50k):\n")
eligible_stats <- ua_matched %>%
  filter(eligible_5307 == 1, !is.na(fta_funding)) %>%
  summarise(
    n = n(),
    mean_funding = mean(fta_funding),
    median_funding = median(fta_funding),
    min_funding = min(fta_funding),
    max_funding = max(fta_funding),
    mean_per_capita = mean(fta_per_capita, na.rm = TRUE),
    median_per_capita = median(fta_per_capita, na.rm = TRUE)
  )

cat("  N matched:", eligible_stats$n, "\n")
cat("  Mean funding: $", format(round(eligible_stats$mean_funding), big.mark = ","), "\n")
cat("  Median funding: $", format(round(eligible_stats$median_funding), big.mark = ","), "\n")
cat("  Range: $", format(round(eligible_stats$min_funding), big.mark = ","),
    " to $", format(round(eligible_stats$max_funding), big.mark = ","), "\n")
cat("  Mean per capita: $", round(eligible_stats$mean_per_capita, 1), "\n")
cat("  Median per capita: $", round(eligible_stats$median_per_capita, 1), "\n")

# Also compute average across available fiscal years
if ("FY2021" %in% names(all_fy_data) || "FY2022" %in% names(all_fy_data)) {
  fta_avg <- fta_combined %>%
    group_by(match_key) %>%
    summarise(
      fta_mean_apportionment = mean(apportionment, na.rm = TRUE),
      n_years = n_distinct(fiscal_year),
      .groups = "drop"
    )

  ua_matched <- ua_matched %>%
    left_join(fta_avg, by = "match_key", suffix = c("", "_avg"))
}

# ============================================================================
# 5. SAVE DATA
# ============================================================================

cat("\n=== Saving FTA Data ===\n")

# Full FTA dataset (all years)
write_csv(fta_combined, file.path(data_dir, "fta_apportionments_raw.csv"))

# Matched analysis dataset with FTA funding
write_csv(
  ua_matched %>% select(-census_city, -match_key),
  file.path(data_dir, "ua_analysis_with_fta.csv")
)

# Summary table for the paper
fta_summary <- ua_matched %>%
  filter(!is.na(fta_funding)) %>%
  group_by(eligible_5307) %>%
  summarise(
    n = n(),
    mean_funding = mean(fta_funding),
    median_funding = median(fta_funding),
    mean_per_capita = mean(fta_per_capita, na.rm = TRUE),
    .groups = "drop"
  )
write_csv(fta_summary, file.path(data_dir, "fta_funding_summary.csv"))

cat("Files saved:\n")
cat("  - fta_apportionments_raw.csv (all FY data)\n")
cat("  - ua_analysis_with_fta.csv (analysis sample with FTA funding)\n")
cat("  - fta_funding_summary.csv (summary statistics)\n")

cat("\n=== FTA Data Fetch Complete ===\n")
