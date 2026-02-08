# =============================================================================
# 01g_fetch_bulk_working.R
# Fetch QWI via Bulk Download - Working Version
# =============================================================================

source("00_packages.R")

# =============================================================================
# Treatment Timing
# =============================================================================

treatment_dates <- tribble(
  ~state_fips, ~state_abbr, ~state_name, ~retail_date,
  "08", "CO", "Colorado", "2014-01-01",
  "53", "WA", "Washington", "2014-07-08"
) %>%
  mutate(
    retail_date = as.Date(retail_date),
    treat_year = year(retail_date),
    treat_qtr = quarter(retail_date),
    treat_qtr_num = treat_year * 4 + treat_qtr
  )

# =============================================================================
# Load Border Counties
# =============================================================================

border_counties <- readRDS(file.path(data_dir, "border_counties.rds"))
cat("Border counties loaded:", nrow(border_counties), "\n")

# =============================================================================
# Download QWI Bulk Files
# =============================================================================

download_qwi_bulk <- function(state_abbr) {
  state_lower <- tolower(state_abbr)

  # County-level data with sex/earnings indicators
  url <- sprintf(
    "https://lehd.ces.census.gov/data/qwi/latest_release/%s/qwi_%s_se_f_gc_ns_op_u.csv.gz",
    state_lower, state_lower
  )

  cat("Downloading:", state_abbr, "... ")

  temp_file <- tempfile(fileext = ".csv.gz")

  result <- tryCatch({
    download.file(url, temp_file, mode = "wb", quiet = TRUE, timeout = 120)

    # Read compressed file
    df <- read_csv(gzfile(temp_file), show_col_types = FALSE)

    # Filter to relevant data
    df <- df %>%
      filter(
        ownercode == "A05",  # Private sector
        sex == 0,            # Both sexes
        agegrp == "A00",     # All ages
        year >= 2010,
        year <= 2020
      ) %>%
      select(
        geography, industry, year, quarter,
        Emp, HirA, EarnHirAS, EarnS
      )

    unlink(temp_file)
    cat(nrow(df), "rows\n")
    return(df)
  }, error = function(e) {
    cat("Error:", conditionMessage(e), "\n")
    return(NULL)
  })

  return(result)
}

# States to download (CO + neighbors, WA + neighbors)
states_to_download <- list(
  "CO" = "08",
  "KS" = "20",
  "NE" = "31",
  "WY" = "56",
  "WA" = "53",
  "ID" = "16",
  "OR" = "41"
)

cat("\n=== Downloading QWI Bulk Files ===\n")

all_qwi <- list()

for (st in names(states_to_download)) {
  df <- download_qwi_bulk(st)
  if (!is.null(df)) {
    all_qwi[[st]] <- df
  }
}

# Combine
qwi_raw <- bind_rows(all_qwi)
cat("\nTotal rows:", nrow(qwi_raw), "\n")

if (nrow(qwi_raw) == 0) {
  stop("No data downloaded!")
}

# =============================================================================
# Clean Data
# =============================================================================

cat("\n=== Cleaning Data ===\n")

qwi_clean <- qwi_raw %>%
  mutate(
    EarnHirAS = as.numeric(EarnHirAS),
    EarnS = as.numeric(EarnS),
    HirA = as.numeric(HirA),
    Emp = as.numeric(Emp),
    year = as.numeric(year),
    quarter = as.numeric(quarter),
    # CRITICAL: Keep county_fips as CHARACTER (5-digit FIPS)
    county_fips = as.character(geography),
    state_fips = substr(as.character(geography), 1, 2),
    qtr_num = year * 4 + quarter,
    date = as.Date(paste0(year, "-", (quarter - 1) * 3 + 1, "-01"))
  ) %>%
  filter(!is.na(EarnHirAS), EarnHirAS > 0) %>%
  mutate(
    log_earn_hire = log(EarnHirAS),
    log_earn = log(EarnS),
    log_emp = log(Emp + 1),
    log_hires = log(HirA + 1)
  )

cat("Cleaned rows:", nrow(qwi_clean), "\n")
cat("Unique counties:", n_distinct(qwi_clean$county_fips), "\n")
cat("Type of county_fips:", class(qwi_clean$county_fips[1]), "\n")

# =============================================================================
# Merge with Border Data
# =============================================================================

cat("\n=== Merging with Border Data ===\n")

# Ensure county_fips is character in both datasets
border_counties <- border_counties %>%
  mutate(county_fips = as.character(county_fips))

cat("Border counties type:", class(border_counties$county_fips[1]), "\n")

# Sample values
cat("\nSample QWI county_fips:", head(unique(qwi_clean$county_fips), 5), "\n")
cat("Sample border county_fips:", head(unique(border_counties$county_fips), 5), "\n")

# Check for overlap
overlap <- intersect(qwi_clean$county_fips, border_counties$county_fips)
cat("\nOverlapping counties:", length(overlap), "\n")

# Merge
qwi_border <- qwi_clean %>%
  inner_join(
    border_counties %>%
      select(county_fips, county_name, border_pair, treated,
             treated_state, dist_to_border, dist_km),
    by = "county_fips"
  )

cat("After merge:", nrow(qwi_border), "rows\n")

# Add treatment timing
co_treat_time <- treatment_dates$treat_qtr_num[treatment_dates$state_abbr == "CO"]
wa_treat_time <- treatment_dates$treat_qtr_num[treatment_dates$state_abbr == "WA"]

qwi_border <- qwi_border %>%
  mutate(
    treat_qtr_num = case_when(
      grepl("^CO-", border_pair) ~ co_treat_time,
      grepl("^WA-", border_pair) ~ wa_treat_time,
      TRUE ~ NA_real_
    ),
    event_time = qtr_num - treat_qtr_num,
    post = event_time >= 0,
    in_bandwidth = dist_to_border <= 100
  )

# =============================================================================
# Summary
# =============================================================================

cat("\n=== Final Dataset ===\n")
cat("Rows:", nrow(qwi_border), "\n")
cat("Counties:", n_distinct(qwi_border$county_fips), "\n")
cat("Border pairs:", n_distinct(qwi_border$border_pair), "\n")
cat("Industries:", n_distinct(qwi_border$industry), "\n")
cat("Quarters:", n_distinct(qwi_border$qtr_num), "\n")

cat("\n=== By Border Pair (All Industries, in bandwidth) ===\n")
qwi_border %>%
  filter(industry == "00", in_bandwidth) %>%
  group_by(border_pair, treated) %>%
  summarise(
    n_counties = n_distinct(county_fips),
    n_obs = n(),
    mean_earn = mean(EarnHirAS, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(border_pair, treated) %>%
  print(n = 20)

# =============================================================================
# Save
# =============================================================================

saveRDS(qwi_border, file.path(data_dir, "qwi_border.rds"))
saveRDS(treatment_dates, file.path(data_dir, "treatment_dates.rds"))

cat("\n=== Data fetch complete! ===\n")
