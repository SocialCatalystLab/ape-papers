# =============================================================================
# 01_fetch_qwi_fast.R
# Fast QWI Fetch - Treated States + Border Controls Only
# =============================================================================

source("00_packages.R")

# =============================================================================
# Configuration - Critical States Only
# =============================================================================

# Treated states
treated_states <- c("08", "09", "32", "44", "06", "53")  # CO, CT, NV, RI, CA, WA

# Border control states (neighbors of treated states)
# NOTE: NY (36) is EXCLUDED because it adopted a law in Sept 2023 (within sample window)
# NY cannot serve as a never-treated control for Callaway-Sant'Anna
border_controls <- c(
  "04", "35", "56", "31", "20", "40",  # AZ, NM, WY, NE, KS, OK (CO borders)
  "25", "33",                           # MA, NH (CT borders) - NY excluded
  "04", "16", "49", "06",               # AZ, ID, UT (NV borders)
  "25", "09",                           # MA (RI borders)
  "04", "32", "41",                     # AZ, NV, OR (CA borders)
  "41", "16"                            # OR, ID (WA borders)
) %>% unique()

# Combine all critical states
critical_states <- unique(c(treated_states, border_controls))
cat("Fetching", length(critical_states), "critical states\n")

# Years: Focus on treatment window
years <- 2015:2023

# =============================================================================
# Fast QWI Fetch Function
# =============================================================================

fetch_qwi_state_year_sex <- function(state_fips, year, sex) {
  base_url <- "https://api.census.gov/data/timeseries/qwi/se"

  results <- list()

  for (qtr in 1:4) {
    url <- paste0(
      base_url,
      "?get=EarnHirAS,EarnS,HirA,Emp",
      "&for=county:*",
      "&in=state:", state_fips,
      "&year=", year,
      "&quarter=", qtr,
      "&ownercode=A05",
      "&industry=00",
      "&sex=", sex
    )

    response <- tryCatch({
      httr::GET(url, httr::timeout(60))
    }, error = function(e) NULL)

    if (is.null(response) || httr::status_code(response) != 200) next

    content <- httr::content(response, "text", encoding = "UTF-8")
    if (content == "" || nchar(content) < 10) next

    data <- tryCatch({
      jsonlite::fromJSON(content)
    }, error = function(e) NULL)

    if (is.null(data) || nrow(data) < 2) next

    df <- as.data.frame(data[-1, , drop = FALSE], stringsAsFactors = FALSE)
    colnames(df) <- data[1, ]

    df$year <- year
    df$quarter <- qtr
    df$state_fips <- state_fips
    df$sex <- sex

    results[[length(results) + 1]] <- df
  }

  if (length(results) == 0) return(NULL)
  bind_rows(results)
}

# =============================================================================
# Fetch Data
# =============================================================================

cat("\n=== Fetching QWI Data (Critical States Only) ===\n")

all_data <- list()

for (state in critical_states) {
  cat("Fetching state:", state, "...")

  state_data <- list()
  for (yr in years) {
    for (sx in c("1", "2")) {
      df <- fetch_qwi_state_year_sex(state, yr, sx)
      if (!is.null(df)) {
        state_data[[length(state_data) + 1]] <- df
      }
    }
    # Rate limit
    Sys.sleep(0.3)
  }

  if (length(state_data) > 0) {
    all_data[[state]] <- bind_rows(state_data)
    cat(" OK (", nrow(all_data[[state]]), " rows)\n", sep = "")
  } else {
    cat(" NO DATA\n")
  }
}

# Combine all data
qwi_raw <- bind_rows(all_data)

cat("\n=== Data Summary ===\n")
cat("Total rows:", nrow(qwi_raw), "\n")
cat("States:", length(unique(qwi_raw$state_fips)), "\n")

# =============================================================================
# Clean and Process
# =============================================================================

# Treatment timing
treat_timing <- tribble(
  ~state_fips, ~treat_qtr_num, ~state_abbr,
  "08", 2021 * 4 + 1, "CO",   # 2021Q1
  "09", 2021 * 4 + 4, "CT",   # 2021Q4
  "32", 2021 * 4 + 4, "NV",   # 2021Q4
  "44", 2023 * 4 + 1, "RI",   # 2023Q1
  "06", 2023 * 4 + 1, "CA",   # 2023Q1
  "53", 2023 * 4 + 1, "WA"    # 2023Q1
)

qwi_clean <- qwi_raw %>%
  mutate(
    EarnHirAS = as.numeric(EarnHirAS),
    EarnS = as.numeric(EarnS),
    HirA = as.numeric(HirA),
    Emp = as.numeric(Emp),
    year = as.numeric(year),
    quarter = as.numeric(quarter),
    county_fips = paste0(state_fips, county),
    qtr_num = year * 4 + quarter,
    sex_label = if_else(sex == "1", "Male", "Female")
  ) %>%
  left_join(treat_timing, by = "state_fips") %>%
  mutate(
    treated_state = !is.na(treat_qtr_num),
    post = qtr_num >= treat_qtr_num & treated_state,
    rel_qtr = if_else(treated_state, qtr_num - treat_qtr_num, NA_real_),
    cohort = if_else(treated_state, treat_qtr_num, 0)
  ) %>%
  filter(!is.na(EarnHirAS), EarnHirAS > 0) %>%
  mutate(
    log_earn_hire = log(EarnHirAS),
    log_earn = log(EarnS)
  )

cat("\n=== Cleaned Data Summary ===\n")
cat("Observations:", nrow(qwi_clean), "\n")
cat("Counties:", length(unique(qwi_clean$county_fips)), "\n")
cat("Treated counties:",
    length(unique(qwi_clean$county_fips[qwi_clean$treated_state])), "\n")
cat("Control counties:",
    length(unique(qwi_clean$county_fips[!qwi_clean$treated_state])), "\n")

# =============================================================================
# Save
# =============================================================================

saveRDS(qwi_clean, "data/qwi_county_sex.rds")
saveRDS(treat_timing, "data/transparency_laws.rds")

cat("\nSaved to data/qwi_county_sex.rds\n")

# Quick summary by treatment status
cat("\n=== Mean New Hire Earnings ===\n")
qwi_clean %>%
  group_by(treated_state, sex_label) %>%
  summarise(
    mean_earn = mean(EarnHirAS, na.rm = TRUE),
    n_obs = n(),
    .groups = "drop"
  ) %>%
  print()
