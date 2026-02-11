##############################################################################
# 01_fetch_data.R — Fetch QWI data from Census API
# APEP-0222 v2: Educational Content Restriction Laws and Teacher Labor Markets
# Revision: adds NAICS 6111 (K-12 Schools) and 6112 (Colleges)
##############################################################################

source("00_packages.R")

cat("=== Fetching QWI data from Census Bureau API ===\n")

# All 51 state FIPS (50 states + DC)
all_states <- paste0(
  "01,02,04,05,06,08,09,10,11,12,13,15,16,17,18,19,20,21,22,23,24,25,",
  "26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,44,45,46,47,48,",
  "49,50,51,53,54,55,56"
)

# Variables to fetch
qwi_vars <- "Emp,EarnS,HirA,Sep,FrmJbC,FrmJbLs,Payroll,TurnOvrS"

# Industries: K-12 Schools (6111), Colleges (6112), Education broad (61),
#             Healthcare (62), All (00), Retail (44-45), Manufacturing (31-33)
industries <- c("6111", "6112", "61", "62", "00", "44-45", "31-33")
industry_labels <- c("K-12 Schools", "Colleges/Universities", "Education (Broad)",
                     "Healthcare", "All Industries", "Retail", "Manufacturing")

# Years and quarters
years <- 2015:2024
quarters <- 1:4

# Function to fetch one batch
fetch_qwi_batch <- function(year, quarter, industry, sex = "0") {
  url <- paste0(
    "https://api.census.gov/data/timeseries/qwi/sa",
    "?get=", qwi_vars,
    "&for=state:", all_states,
    "&year=", year,
    "&quarter=", quarter,
    "&sex=", sex,
    "&industry=", industry,
    "&ownercode=A05",
    "&agegrp=A00"
  )

  tryCatch({
    resp <- GET(url, timeout(60))
    if (status_code(resp) == 200) {
      content_text <- content(resp, "text", encoding = "UTF-8")
      data <- fromJSON(content_text, flatten = TRUE)
      if (length(data) > 1) {
        df <- as.data.frame(data[-1, , drop = FALSE], stringsAsFactors = FALSE)
        names(df) <- data[1, ]
        return(df)
      }
    }
    return(NULL)
  }, error = function(e) {
    return(NULL)
  })
}

# Fetch all combinations
all_data <- list()
total_calls <- length(years) * length(quarters) * length(industries)
call_num <- 0
success <- 0

for (ind in industries) {
  for (yr in years) {
    for (qtr in quarters) {
      call_num <- call_num + 1
      if (call_num %% 50 == 0) {
        cat(sprintf("  Progress: %d/%d calls (%.0f%%), %d successful\n",
                    call_num, total_calls, 100 * call_num / total_calls, success))
      }

      result <- fetch_qwi_batch(yr, qtr, ind)
      if (!is.null(result) && nrow(result) > 0) {
        all_data[[length(all_data) + 1]] <- result
        success <- success + 1
      }

      Sys.sleep(0.1)  # Rate limiting
    }
  }
}

cat(sprintf("\nFetch complete: %d/%d successful calls\n", success, total_calls))

# Combine all data
qwi_raw <- bind_rows(all_data)

# Convert numeric columns
numeric_cols <- c("Emp", "EarnS", "HirA", "Sep", "FrmJbC", "FrmJbLs", "Payroll", "TurnOvrS")
for (col in numeric_cols) {
  qwi_raw[[col]] <- as.numeric(qwi_raw[[col]])
}
qwi_raw$year <- as.integer(qwi_raw$year)
qwi_raw$quarter <- as.integer(qwi_raw$quarter)

# Create time variable (year-quarter as numeric)
qwi_raw <- qwi_raw %>%
  mutate(
    state_fips = state,
    time_q = year + (quarter - 1) / 4,
    yq = paste0(year, "Q", quarter)
  )

# Add industry labels
qwi_raw <- qwi_raw %>%
  mutate(industry_label = case_when(
    industry == "6111" ~ "K-12 Schools",
    industry == "6112" ~ "Colleges/Universities",
    industry == "61"   ~ "Education (Broad)",
    industry == "62"   ~ "Healthcare",
    industry == "00"   ~ "All Industries",
    industry == "44-45" ~ "Retail",
    industry == "31-33" ~ "Manufacturing",
    TRUE ~ industry
  ))

cat(sprintf("Raw QWI data: %d rows, %d states, %d industries\n",
            nrow(qwi_raw), n_distinct(qwi_raw$state_fips), n_distinct(qwi_raw$industry)))
cat(sprintf("Year range: %d-%d\n", min(qwi_raw$year), max(qwi_raw$year)))

# Report 4-digit suppression for NAICS 6111
k12_data <- qwi_raw %>% filter(industry == "6111")
n_suppressed_6111 <- sum(is.na(k12_data$Emp))
n_total_6111 <- nrow(k12_data)
cat(sprintf("\nNAICS 6111 suppression: %d/%d state-quarters (%.1f%%)\n",
            n_suppressed_6111, n_total_6111, 100 * n_suppressed_6111 / n_total_6111))

# Save raw data
saveRDS(qwi_raw, "../data/qwi_raw.rds")
cat("Saved: ../data/qwi_raw.rds\n")

# Also fetch QWI by sex for K-12 schools (NAICS 6111) — gender composition analysis
cat("\n=== Fetching QWI by sex for K-12 schools (NAICS 6111) ===\n")

sex_data <- list()
sex_calls <- 0
sex_success <- 0
for (yr in years) {
  for (qtr in quarters) {
    for (sx in c("1", "2")) {  # 1=Male, 2=Female
      sex_calls <- sex_calls + 1
      url <- paste0(
        "https://api.census.gov/data/timeseries/qwi/sa",
        "?get=Emp,EarnS,HirA,Sep",
        "&for=state:", all_states,
        "&year=", yr,
        "&quarter=", qtr,
        "&sex=", sx,
        "&industry=6111",
        "&ownercode=A05",
        "&agegrp=A00"
      )
      tryCatch({
        resp <- GET(url, timeout(60))
        if (status_code(resp) == 200) {
          content_text <- content(resp, "text", encoding = "UTF-8")
          data <- fromJSON(content_text, flatten = TRUE)
          if (length(data) > 1) {
            df <- as.data.frame(data[-1, , drop = FALSE], stringsAsFactors = FALSE)
            names(df) <- data[1, ]
            sex_data[[length(sex_data) + 1]] <- df
            sex_success <- sex_success + 1
          }
        }
      }, error = function(e) { })
      Sys.sleep(0.1)
    }
  }
}

cat(sprintf("Sex-disaggregated fetch: %d/%d successful\n", sex_success, sex_calls))

if (length(sex_data) > 0) {
  qwi_sex <- bind_rows(sex_data)
  for (col in c("Emp", "EarnS", "HirA", "Sep")) {
    qwi_sex[[col]] <- as.numeric(qwi_sex[[col]])
  }
  qwi_sex$year <- as.integer(qwi_sex$year)
  qwi_sex$quarter <- as.integer(qwi_sex$quarter)
  qwi_sex <- qwi_sex %>%
    mutate(
      state_fips = state,
      sex_label = ifelse(sex == "1", "Male", "Female"),
      time_q = year + (quarter - 1) / 4
    )

  # Report suppression in sex-disaggregated 6111 data
  n_sex_suppressed <- sum(is.na(qwi_sex$Emp))
  cat(sprintf("Sex-disaggregated 6111 suppression: %d/%d rows (%.1f%%)\n",
              n_sex_suppressed, nrow(qwi_sex), 100 * n_sex_suppressed / nrow(qwi_sex)))

  saveRDS(qwi_sex, "../data/qwi_k12_by_sex.rds")
  cat(sprintf("Saved sex-disaggregated K-12 data: %d rows\n", nrow(qwi_sex)))
}

cat("\n=== Data fetch complete ===\n")
