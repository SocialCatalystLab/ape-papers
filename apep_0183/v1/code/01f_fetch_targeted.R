# =============================================================================
# 01f_fetch_targeted.R
# Targeted QWI Fetch - Focus on CO borders with working API calls
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
cat("Border pairs:", paste(unique(border_counties$border_pair), collapse = ", "), "\n")

# Focus on key border pairs
focus_pairs <- c("CO-WY", "CO-KS", "CO-NE", "WA-ID")
border_focus <- border_counties %>%
  filter(border_pair %in% focus_pairs)

cat("\nFocused border counties:", nrow(border_focus), "\n")

# =============================================================================
# QWI Fetch Function
# =============================================================================

fetch_qwi_batch <- function(state_fips, years, industries) {
  base_url <- "https://api.census.gov/data/timeseries/qwi/se"
  all_data <- list()

  for (yr in years) {
    for (qtr in 1:4) {
      for (ind in industries) {
        url <- paste0(
          base_url,
          "?get=EarnHirAS,EarnS,Emp,HirA",
          "&for=county:*",
          "&in=state:", state_fips,
          "&year=", yr,
          "&quarter=", qtr,
          "&ownercode=A05",
          "&industry=", ind,
          "&sex=0"
        )

        response <- tryCatch({
          Sys.sleep(0.6)  # Rate limiting
          httr::GET(url, httr::timeout(60))
        }, error = function(e) NULL)

        if (!is.null(response) && httr::status_code(response) == 200) {
          content <- httr::content(response, "text", encoding = "UTF-8")
          if (nchar(content) > 50 && !grepl("error", tolower(content))) {
            data <- tryCatch(jsonlite::fromJSON(content), error = function(e) NULL)
            if (!is.null(data) && nrow(data) >= 2) {
              df <- as.data.frame(data[-1, , drop = FALSE], stringsAsFactors = FALSE)
              colnames(df) <- data[1, ]
              df$year <- yr
              df$quarter <- qtr
              df$industry <- ind
              all_data[[length(all_data) + 1]] <- df
            }
          }
        }
      }
    }
    cat(sprintf("\r  %s %d complete", state_fips, yr))
  }

  if (length(all_data) == 0) return(NULL)
  bind_rows(all_data)
}

# =============================================================================
# Fetch Data
# =============================================================================

# States needed
states_needed <- unique(border_focus$state_fips)
cat("\nStates to fetch:", paste(states_needed, collapse = ", "), "\n")

# Focused scope
years <- 2011:2018  # Pre/post for CO (2014)
industries <- c("00", "44-45", "72", "31-33", "62", "23", "48-49")  # Key sectors

cat("Years:", min(years), "-", max(years), "\n")
cat("Industries:", length(industries), "\n")

all_qwi <- list()

for (state in states_needed) {
  cat("\nFetching", state, "...\n")
  df <- fetch_qwi_batch(state, years, industries)
  if (!is.null(df)) {
    all_qwi[[state]] <- df
    cat("\n  ", state, "rows:", nrow(df), "\n")
  }
}

# Combine
qwi_raw <- bind_rows(all_qwi)
cat("\n\nTotal QWI rows:", nrow(qwi_raw), "\n")

if (nrow(qwi_raw) == 0) {
  stop("No data fetched!")
}

# =============================================================================
# Clean and Merge
# =============================================================================

cat("\n=== Cleaning Data ===\n")

qwi_clean <- qwi_raw %>%
  mutate(
    EarnHirAS = as.numeric(EarnHirAS),
    EarnS = as.numeric(EarnS),
    Emp = as.numeric(Emp),
    HirA = as.numeric(HirA),
    year = as.numeric(year),
    quarter = as.numeric(quarter),
    county_fips = paste0(state, county),  # Keep as character
    state_fips_code = state,
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

# Merge with border info
cat("\n=== Merging with Border Data ===\n")

# Ensure types match
border_focus <- border_focus %>%
  mutate(county_fips = as.character(county_fips))

qwi_border <- qwi_clean %>%
  inner_join(
    border_focus %>%
      select(county_fips, county_name, border_pair, treated,
             treated_state, dist_to_border, dist_km),
    by = "county_fips"
  )

cat("Merged rows:", nrow(qwi_border), "\n")

# Add treatment timing (CO only for now)
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

cat("\n=== By Border Pair (All Industries) ===\n")
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
