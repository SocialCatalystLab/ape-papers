# =============================================================================
# 01b_fetch_qwi_industry.R
# Fetch QWI Data by Industry for Heterogeneity Analysis
# =============================================================================

source("00_packages.R")

# =============================================================================
# Configuration
# =============================================================================

# Treated states
treated_states <- c("08", "09", "32", "44", "06", "53")  # CO, CT, NV, RI, CA, WA

# Border control states (neighbors of treated states)
border_controls <- c(
  "04", "35", "56", "31", "20", "40",  # AZ, NM, WY, NE, KS, OK (CO borders)
  "25", "33",                           # MA, NH (CT borders)
  "04", "16", "49",                     # AZ, ID, UT (NV borders)
  "25",                                 # MA (RI borders)
  "04", "32", "41",                     # AZ, NV, OR (CA borders)
  "41", "16"                            # OR, ID (WA borders)
) %>% unique()

critical_states <- unique(c(treated_states, border_controls))

# Years
years <- 2015:2023

# Industry sectors for heterogeneity analysis
# High-bargaining (professional, negotiation-intensive)
# Low-bargaining (retail, service, standardized pay)
industries <- list(
  # High-bargaining sectors
  "51" = "Information",
  "52" = "Finance and Insurance",
  "54" = "Professional Services",
  "55" = "Management",
  # Low-bargaining sectors
  "44-45" = "Retail Trade",
  "72" = "Accommodation and Food",
  "62" = "Health Care"
)

cat("Fetching", length(critical_states), "states across", length(industries), "industries\n")

# =============================================================================
# Fetch Function - Industry-Stratified (State-Quarter Level)
# =============================================================================

fetch_qwi_industry <- function(state_fips, year, industry_code) {
  base_url <- "https://api.census.gov/data/timeseries/qwi/se"

  results <- list()

  for (qtr in 1:4) {
    url <- paste0(
      base_url,
      "?get=EarnHirAS,EarnS,HirA,Emp",
      "&for=state:", state_fips,  # State-level for industry (less suppression)
      "&year=", year,
      "&quarter=", qtr,
      "&ownercode=A05",
      "&industry=", industry_code,
      "&sex=0"  # Both sexes combined for industry analysis
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
    df$industry_code <- industry_code

    results[[length(results) + 1]] <- df
  }

  if (length(results) == 0) return(NULL)
  bind_rows(results)
}

# =============================================================================
# Fetch All Industry Data
# =============================================================================

cat("\n=== Fetching QWI Industry Data ===\n")

all_data <- list()
total_calls <- length(critical_states) * length(years) * length(industries)
call_count <- 0

for (state in critical_states) {
  for (ind_code in names(industries)) {
    ind_name <- industries[[ind_code]]
    cat(sprintf("\rFetching %s - %s (%d/%d)", state, ind_name, call_count, total_calls))

    state_ind_data <- list()
    for (yr in years) {
      df <- fetch_qwi_industry(state, yr, ind_code)
      if (!is.null(df)) {
        state_ind_data[[length(state_ind_data) + 1]] <- df
      }
      call_count <- call_count + 1
      Sys.sleep(0.25)  # Rate limit
    }

    if (length(state_ind_data) > 0) {
      all_data[[paste(state, ind_code, sep = "_")]] <- bind_rows(state_ind_data)
    }
  }
}

cat("\n\nCombining data...\n")

# Combine all data
qwi_industry_raw <- bind_rows(all_data)

cat("Total rows:", nrow(qwi_industry_raw), "\n")

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

# Industry classification
industry_class <- tribble(
  ~industry_code, ~industry_name, ~bargaining_type,
  "51", "Information", "High",
  "52", "Finance", "High",
  "54", "Professional Services", "High",
  "55", "Management", "High",
  "44-45", "Retail Trade", "Low",
  "72", "Accommodation & Food", "Low",
  "62", "Health Care", "Low"
)

qwi_industry <- qwi_industry_raw %>%
  mutate(
    EarnHirAS = as.numeric(EarnHirAS),
    EarnS = as.numeric(EarnS),
    HirA = as.numeric(HirA),
    Emp = as.numeric(Emp),
    year = as.numeric(year),
    quarter = as.numeric(quarter),
    qtr_num = year * 4 + quarter
  ) %>%
  left_join(treat_timing, by = "state_fips") %>%
  left_join(industry_class, by = "industry_code") %>%
  mutate(
    treated_state = !is.na(treat_qtr_num),
    post = qtr_num >= treat_qtr_num & treated_state,
    rel_qtr = if_else(treated_state, qtr_num - treat_qtr_num, NA_real_),
    cohort = if_else(treated_state, treat_qtr_num, 0)
  ) %>%
  filter(!is.na(EarnHirAS), EarnHirAS > 0) %>%
  mutate(
    log_earn_hire = log(EarnHirAS)
  )

cat("\n=== Industry Data Summary ===\n")
cat("Observations:", nrow(qwi_industry), "\n")
cat("States:", length(unique(qwi_industry$state_fips)), "\n")
cat("\nBy industry:\n")
qwi_industry %>%
  group_by(industry_name, bargaining_type) %>%
  summarise(n = n(), mean_earn = mean(EarnHirAS, na.rm = TRUE), .groups = "drop") %>%
  arrange(bargaining_type, industry_name) %>%
  print()

# =============================================================================
# Save
# =============================================================================

saveRDS(qwi_industry, "data/qwi_industry.rds")
saveRDS(industry_class, "data/industry_classification.rds")

cat("\nSaved to data/qwi_industry.rds\n")

# Summary by bargaining type
cat("\n=== Mean New Hire Earnings by Bargaining Intensity ===\n")
qwi_industry %>%
  group_by(bargaining_type, treated_state) %>%
  summarise(
    mean_earn = mean(EarnHirAS, na.rm = TRUE),
    n_obs = n(),
    .groups = "drop"
  ) %>%
  print()

cat("\nIndustry data fetch complete.\n")
