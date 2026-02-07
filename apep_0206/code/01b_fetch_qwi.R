################################################################################
# 01b_fetch_qwi.R
# Salary Transparency Laws and Labor Market Dynamics
#
# Fetches Quarterly Workforce Indicators (QWI) from Census LEHD API
# Unit: state x quarter x sex x industry
#
# --- Input/Output Provenance ---
# INPUTS:
#   Census QWI API: https://api.census.gov/data/timeseries/qwi/sa
# OUTPUTS:
#   data/qwi_raw.rds (state x quarter x sex x industry panel)
#
# DATA SOURCE:
#   U.S. Census Bureau, LEHD Program, Quarterly Workforce Indicators
#   https://lehd.ces.census.gov/data/qwi/
################################################################################

source("code/00_packages.R")

cat("=== Fetching QWI Data for Salary Transparency Analysis ===\n\n")

# ============================================================================
# QWI API Configuration
# ============================================================================

qwi_base <- "https://api.census.gov/data/timeseries/qwi/sa"
qwi_vars <- "Emp,EarnS,HirA,Sep,FrmJbC,FrmJbLs,Payroll,TurnOvrS"

# Industries (must query one at a time)
industry_codes <- c("00", "44-45", "72", "52", "54")

# All 51 state FIPS as comma-separated string for batch query
all_states <- paste0(
  c("01", "02", "04", "05", "06", "08", "09", "10", "11", "12",
    "13", "15", "16", "17", "18", "19", "20", "21", "22", "23",
    "24", "25", "26", "27", "28", "29", "30", "31", "32", "33",
    "34", "35", "36", "37", "38", "39", "40", "41", "42", "44",
    "45", "46", "47", "48", "49", "50", "51", "53", "54", "55", "56"),
  collapse = ","
)

years <- 2012:2024
quarters <- 1:4
sex_codes <- c(0, 1, 2)

# ============================================================================
# Fetch Function (all states in one call)
# ============================================================================

fetch_qwi_batch <- function(year, quarter, sex_code, ind) {
  url <- paste0(
    qwi_base,
    "?get=", qwi_vars,
    "&for=state:", all_states,
    "&year=", year,
    "&quarter=", quarter,
    "&sex=", sex_code,
    "&industry=", ind,
    "&ownercode=A05",
    "&agegrp=A00"
  )

  tryCatch({
    resp <- GET(url, timeout(60))
    if (status_code(resp) == 200) {
      content_text <- content(resp, "text", encoding = "UTF-8")
      if (grepl("^\\[", content_text)) {
        data <- fromJSON(content_text, flatten = TRUE)
        if (length(data) > 1) {
          df <- as.data.frame(data[-1, , drop = FALSE], stringsAsFactors = FALSE)
          names(df) <- data[1, ]
          return(df)
        }
      }
    }
    return(NULL)
  }, error = function(e) {
    return(NULL)
  })
}

# ============================================================================
# Main Fetch Loop: year x quarter x sex x industry
# ============================================================================

total_calls <- length(years) * length(quarters) * length(sex_codes) * length(industry_codes)
cat("Planned API calls:", total_calls, "(each returns ~51 state rows)\n\n")

all_results <- list()
n_calls <- 0
n_success <- 0

for (yr in years) {
  yr_rows <- 0
  for (qtr in quarters) {
    for (sx in sex_codes) {
      for (ind in industry_codes) {
        n_calls <- n_calls + 1
        result <- fetch_qwi_batch(yr, qtr, sx, ind)
        if (!is.null(result) && nrow(result) > 0) {
          all_results[[length(all_results) + 1]] <- result
          n_success <- n_success + 1
          yr_rows <- yr_rows + nrow(result)
        }
        Sys.sleep(0.1)
      }
    }
  }
  cat("  Year", yr, ": ", yr_rows, "rows (", n_success, "/", n_calls, "calls ok)\n")
}

cat("\n=== Fetch Summary ===\n")
cat("Total API calls:", n_calls, "\n")
cat("Successful:", n_success, "\n")
cat("Failed:", n_calls - n_success, "\n")
cat("Success rate:", round(100 * n_success / n_calls, 1), "%\n")

if (n_success == 0) {
  stop("No QWI data fetched. Check API availability.")
}

# ============================================================================
# Combine and Save
# ============================================================================

qwi_raw <- bind_rows(all_results)

cat("\nRaw QWI data:", nrow(qwi_raw), "rows\n")
cat("Columns:", paste(names(qwi_raw), collapse = ", "), "\n")
cat("States:", n_distinct(qwi_raw$state), "\n")
cat("Year range:", min(as.integer(qwi_raw$year)), "-", max(as.integer(qwi_raw$year)), "\n")
cat("Industries:", n_distinct(qwi_raw$industry), "\n")
cat("Sex codes:", paste(sort(unique(qwi_raw$sex)), collapse = ", "), "\n")

saveRDS(qwi_raw, "data/qwi_raw.rds")
cat("\nSaved to data/qwi_raw.rds\n")
cat("=== QWI Fetch Complete ===\n")
