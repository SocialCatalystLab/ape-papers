# ============================================================
# 01c_fetch_medicaid_insulin.R - Fetch Medicaid insulin
#   utilization from CMS State Drug Utilization Data (SDUD)
# Paper 148: State Insulin Copay Caps and Working-Age
#             Diabetes Mortality (v5)
# Revision of apep_0161 (family apep_0150)
# ============================================================
# Data Source:
#   CMS Medicaid State Drug Utilization Data (SDUD)
#   URL: https://data.medicaid.gov/dataset/0217b6d6-3572-46cc-a883-04dba1366060
#   API: Socrata Open Data API (SODA)
#   Coverage: State-quarter insulin prescription counts
#   Years: 2015-2024
#
# Outputs (saved to data/):
#   - insulin_utilization.rds  <- State-year insulin Rx aggregates
#   - insulin_utilization.csv  <- Same in CSV for transparency
#
# Important Limitation:
#   Medicaid SDUD covers Medicaid beneficiaries, NOT commercial insurance.
#   State copay caps primarily target commercial plans. This makes the
#   Medicaid outcome either:
#     (a) A placebo-like test (Medicaid patients should NOT be affected
#         by commercial copay caps), OR
#     (b) A spillover test (states enacting copay caps may also improve
#         Medicaid insulin access through broader policy attention)
#   Either interpretation is scientifically valuable.
# ============================================================

source("code/00_packages.R")

dir.create("data", showWarnings = FALSE)

# ============================================================
# PART 1: Define Insulin NDC Prefixes
# ============================================================
# Insulin products are identified by NDC (National Drug Code).
# Major insulin manufacturers and product lines:
#   Eli Lilly: Humalog, Humulin
#   Novo Nordisk: Novolog, Levemir, Tresiba, Fiasp
#   Sanofi: Lantus, Toujeo, Apidra, Admelog
#
# We use product name matching rather than NDC prefixes because
# the SDUD API supports product name filtering.

cat("\n=== Fetching Medicaid Insulin Utilization Data (SDUD) ===\n")

# Insulin product name keywords for filtering
insulin_keywords <- c(
  "INSULIN", "HUMALOG", "HUMULIN", "NOVOLOG", "NOVOLIN",
  "LANTUS", "LEVEMIR", "TRESIBA", "TOUJEO", "BASAGLAR",
  "ADMELOG", "FIASP", "APIDRA", "SEMGLEE", "LYUMJEV",
  "AFREZZA"
)

# ============================================================
# PART 2: Query SDUD API
# ============================================================
# The SDUD API at data.medicaid.gov uses Socrata/SODA protocol.
# We query year-by-year to stay within row limits.

state_lookup <- readRDS("data/state_lookup.rds")

# Function to fetch one year of SDUD data
fetch_sdud_year <- function(year, max_retries = 3) {
  cat("  Fetching SDUD year", year, "...\n")

  # Build SoQL query: filter for insulin by product name
  # SDUD product_name field contains drug name
  # Use $where with UPPER() and LIKE for case-insensitive matching
  where_clauses <- paste0(
    "upper(product_name) like '%", insulin_keywords, "%'",
    collapse = " OR "
  )

  # The SDUD dataset ID on data.medicaid.gov
  base_url <- "https://data.medicaid.gov/resource/0217b6d6-3572-46cc-a883-04dba1366060.csv"

  all_rows <- list()
  offset <- 0
  page_size <- 50000

  repeat {
    resp <- NULL
    for (attempt in 1:max_retries) {
      resp <- tryCatch({
        GET(
          base_url,
          query = list(
            `$where` = paste0("year = ", year, " AND (", where_clauses, ")"),
            `$select` = "state,year,quarter,product_name,units_reimbursed,number_of_prescriptions,total_amount_reimbursed,ndc",
            `$limit` = page_size,
            `$offset` = offset,
            `$order` = "state,quarter"
          ),
          add_headers(
            `User-Agent` = "APEP-Research/1.0 (academic research)"
          ),
          timeout(120)
        )
      }, error = function(e) {
        cat("    HTTP error (attempt ", attempt, "):", e$message, "\n")
        Sys.sleep(5 * attempt)
        NULL
      })

      if (!is.null(resp) && status_code(resp) == 200) break
      if (attempt < max_retries) Sys.sleep(5 * attempt)
    }

    if (is.null(resp) || status_code(resp) != 200) {
      cat("    Failed to fetch year", year, "after", max_retries, "attempts\n")
      break
    }

    page_data <- tryCatch({
      read_csv(content(resp, "text", encoding = "UTF-8"), show_col_types = FALSE)
    }, error = function(e) {
      cat("    Parse error:", e$message, "\n")
      NULL
    })

    if (is.null(page_data) || nrow(page_data) == 0) break

    all_rows[[length(all_rows) + 1]] <- page_data
    cat("    Page:", offset, "-", offset + nrow(page_data), "rows\n")

    if (nrow(page_data) < page_size) break
    offset <- offset + page_size
    Sys.sleep(1)  # Rate limiting
  }

  if (length(all_rows) == 0) return(NULL)
  bind_rows(all_rows)
}

# Fetch years 2015-2024
sdud_raw <- list()
for (yr in 2015:2024) {
  result <- fetch_sdud_year(yr)
  if (!is.null(result)) {
    sdud_raw[[as.character(yr)]] <- result
    cat("    Year", yr, ":", nrow(result), "rows\n")
  } else {
    cat("    Year", yr, ": NO DATA\n")
  }
  Sys.sleep(2)  # Rate limit between years
}

# ============================================================
# PART 3: Process and Aggregate to State-Year
# ============================================================

cat("\n=== Processing SDUD Insulin Data ===\n")

if (length(sdud_raw) == 0) {
  cat("WARNING: No SDUD data retrieved. Insulin utilization analysis will be skipped.\n")
  cat("This may be due to API rate limits or network issues.\n")
  # Save empty placeholder so downstream scripts can check
  insulin_utilization <- data.frame(
    state_fips = integer(), state_abbr = character(), state_name = character(),
    year = integer(), total_prescriptions = numeric(), total_units = numeric(),
    total_reimbursed = numeric(), n_products = integer(),
    stringsAsFactors = FALSE
  )
} else {
  sdud_combined <- bind_rows(sdud_raw)
  cat("Total SDUD insulin rows:", nrow(sdud_combined), "\n")

  # Standardize column names
  names(sdud_combined) <- tolower(names(sdud_combined))

  # Clean numeric fields
  sdud_combined <- sdud_combined %>%
    mutate(
      year = as.integer(year),
      quarter = as.integer(quarter),
      units_reimbursed = suppressWarnings(as.numeric(units_reimbursed)),
      number_of_prescriptions = suppressWarnings(as.numeric(number_of_prescriptions)),
      total_amount_reimbursed = suppressWarnings(as.numeric(total_amount_reimbursed))
    )

  # Aggregate to state-year
  insulin_utilization <- sdud_combined %>%
    left_join(
      state_lookup %>% select(state_abbr, state_fips, state_name),
      by = c("state" = "state_abbr")
    ) %>%
    filter(!is.na(state_fips)) %>%
    group_by(state_fips, state_abbr = state, state_name, year) %>%
    summarise(
      total_prescriptions = sum(number_of_prescriptions, na.rm = TRUE),
      total_units = sum(units_reimbursed, na.rm = TRUE),
      total_reimbursed = sum(total_amount_reimbursed, na.rm = TRUE),
      n_products = n_distinct(ndc),
      .groups = "drop"
    ) %>%
    arrange(state_fips, year)

  cat("Aggregated insulin utilization:", nrow(insulin_utilization), "state-year obs\n")
  cat("  States:", n_distinct(insulin_utilization$state_fips), "\n")
  cat("  Year range:", min(insulin_utilization$year), "-", max(insulin_utilization$year), "\n")

  # Summary statistics
  cat("\nInsulin Utilization Summary:\n")
  insulin_utilization %>%
    group_by(year) %>%
    summarise(
      mean_rx = mean(total_prescriptions, na.rm = TRUE),
      median_rx = median(total_prescriptions, na.rm = TRUE),
      total_rx = sum(total_prescriptions, na.rm = TRUE),
      n_states = n(),
      .groups = "drop"
    ) %>%
    print(n = 20)
}

# ============================================================
# PART 4: Save Insulin Utilization Data
# ============================================================

cat("\n=== Saving Insulin Utilization Data ===\n")

saveRDS(insulin_utilization, "data/insulin_utilization.rds")
write_csv(insulin_utilization, "data/insulin_utilization.csv")
cat("Saved data/insulin_utilization.rds\n")
cat("  Rows:", nrow(insulin_utilization), "\n")

if (nrow(insulin_utilization) > 0) {
  cat("  Year range:", min(insulin_utilization$year), "-", max(insulin_utilization$year), "\n")
  cat("  States:", n_distinct(insulin_utilization$state_fips), "\n")
} else {
  cat("  WARNING: Empty insulin utilization dataset.\n")
  cat("  Downstream insulin analysis will produce null results.\n")
}

cat("\n=== Medicaid Insulin Data Fetch Complete ===\n")
