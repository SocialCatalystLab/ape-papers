# =============================================================================
# 01d_fetch_bulk.R
# Fetch QWI via Bulk Download from LEHD
# =============================================================================

source("00_packages.R")

# =============================================================================
# Treatment Timing
# =============================================================================

treatment_dates <- tribble(
  ~state_fips, ~state_abbr, ~retail_date,
  "08", "CO", "2014-01-01",
  "53", "WA", "2014-07-08"
) %>%
  mutate(
    retail_date = as.Date(retail_date),
    treat_qtr_num = year(retail_date) * 4 + quarter(retail_date)
  )

# =============================================================================
# Geographic Data
# =============================================================================

border_counties <- readRDS(file.path(data_dir, "border_counties.rds"))

# Filter to CO and WA borders
analysis_borders <- border_counties %>%
  filter(grepl("^(CO|WA)-", border_pair))

cat("Analysis border counties:", nrow(analysis_borders), "\n")

# =============================================================================
# Download QWI Bulk Files
# =============================================================================

download_qwi <- function(state_abbr) {
  state_lower <- tolower(state_abbr)

  # County-level data with sex breakdown
  url <- sprintf(
    "https://lehd.ces.census.gov/data/qwi/latest_release/%s/qwi_%s_se_f_gc_ns_op_u.csv.gz",
    state_lower, state_lower
  )

  cat("Downloading:", url, "\n")

  temp_file <- tempfile(fileext = ".csv.gz")

  tryCatch({
    download.file(url, temp_file, mode = "wb", quiet = TRUE)

    # Read and decompress
    df <- read_csv(temp_file, show_col_types = FALSE)

    # Filter to relevant data
    df <- df %>%
      filter(
        ownercode == "A05",  # Private sector
        sex == 0,            # Both sexes
        agegrp == "A00",     # All ages
        year >= 2010,
        year <= 2023
      ) %>%
      select(
        geography, industry, year, quarter,
        Emp, HirA, EarnHirAS, EarnS
      )

    unlink(temp_file)
    return(df)
  }, error = function(e) {
    cat("  Error:", e$message, "\n")
    return(NULL)
  })
}

# States to download
states_to_download <- c(
  "CO", "KS", "NE", "WY", "UT", "NM", "OK",  # CO + neighbors
  "WA", "ID"  # WA + neighbor
)

cat("\n=== Downloading QWI Bulk Files ===\n")

all_qwi <- list()

for (st in states_to_download) {
  df <- download_qwi(st)
  if (!is.null(df)) {
    all_qwi[[st]] <- df
    cat("  ", st, ":", nrow(df), "rows\n")
  }
}

# Combine
qwi_raw <- bind_rows(all_qwi)
cat("\nTotal rows:", nrow(qwi_raw), "\n")

# =============================================================================
# Clean and Merge
# =============================================================================

# State FIPS lookup
state_fips <- tribble(
  ~state_abbr, ~state_fips,
  "CO", "08",
  "KS", "20",
  "NE", "31",
  "WY", "56",
  "UT", "49",
  "NM", "35",
  "OK", "40",
  "WA", "53",
  "ID", "16"
)

qwi_clean <- qwi_raw %>%
  mutate(
    EarnHirAS = as.numeric(EarnHirAS),
    EarnS = as.numeric(EarnS),
    HirA = as.numeric(HirA),
    Emp = as.numeric(Emp),
    year = as.numeric(year),
    quarter = as.numeric(quarter),
    county_fips = geography,
    state_fips_2 = substr(geography, 1, 2),
    qtr_num = year * 4 + quarter,
    date = as.Date(paste0(year, "-", (quarter - 1) * 3 + 1, "-01"))
  ) %>%
  left_join(state_fips, by = c("state_fips_2" = "state_fips")) %>%
  filter(!is.na(EarnHirAS), EarnHirAS > 0) %>%
  mutate(
    log_earn_hire = log(EarnHirAS),
    log_earn = log(EarnS),
    log_emp = log(Emp + 1),
    log_hires = log(HirA + 1)
  )

# Merge with border info
qwi_border <- qwi_clean %>%
  inner_join(analysis_borders, by = c("county_fips" = "GEOID"))

# Add treatment timing
qwi_border <- qwi_border %>%
  left_join(
    treatment_dates %>% select(state_fips, treat_qtr_num),
    by = c("treated_state" = "state_fips")
  ) %>%
  mutate(
    event_time = qtr_num - treat_qtr_num,
    post = event_time >= 0,
    in_bandwidth = dist_to_border <= 100
  )

cat("Final sample size:", nrow(qwi_border), "\n")
cat("Counties:", n_distinct(qwi_border$county_fips), "\n")
cat("Border pairs:", n_distinct(qwi_border$border_pair), "\n")
cat("Industries:", n_distinct(qwi_border$industry), "\n")

# =============================================================================
# Save
# =============================================================================

saveRDS(qwi_border, file.path(data_dir, "qwi_border.rds"))
saveRDS(treatment_dates, file.path(data_dir, "treatment_dates.rds"))

# Summary
cat("\n=== Summary ===\n")
qwi_border %>%
  filter(industry == "00", in_bandwidth) %>%
  group_by(border_pair, treated) %>%
  summarise(
    n = n(),
    mean_earn = mean(EarnHirAS, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  print()

cat("\nBulk data fetch complete!\n")
