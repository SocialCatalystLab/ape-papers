################################################################################
# 01_fetch_data.R — Fetch ARC CIV data and county-level outcomes
# ARC Distressed County Designation RDD (apep_0217)
################################################################################

source("00_packages.R")

data_dir <- "../data"
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

################################################################################
# 1. ARC County Economic Status Data (CIV scores)
################################################################################

cat("=== Fetching ARC County Economic Status Data ===\n")

arc_years <- 2007:2017
arc_data_list <- list()

for (fy in arc_years) {
  cat(sprintf("  Downloading FY%d...\n", fy))

  url <- sprintf("https://www.arc.gov/wp-content/uploads/2020/06/County-Economic-Status_FY%d_Data-1.xls", fy)
  destfile <- file.path(data_dir, sprintf("arc_fy%d.xls", fy))

  tryCatch({
    download.file(url, destfile, mode = "wb", quiet = TRUE)
  }, error = function(e) {
    url2 <- sprintf("https://www.arc.gov/wp-content/uploads/2020/06/County-Economic-Status_FY%d_Data.xls", fy)
    tryCatch({
      download.file(url2, destfile, mode = "wb", quiet = TRUE)
    }, error = function(e2) {
      cat(sprintf("    FAILED to download FY%d\n", fy))
    })
  })

  if (!file.exists(destfile) || file.size(destfile) < 1000) {
    cat(sprintf("    Skipping FY%d (file missing or empty)\n", fy))
    next
  }

  tryCatch({
    sheets <- readxl::excel_sheets(destfile)
    arc_sheet <- sheets[grepl("ARC", sheets, ignore.case = TRUE)]
    if (length(arc_sheet) == 0) arc_sheet <- sheets[1]

    # Read raw without column names to find header row
    df_raw <- readxl::read_excel(destfile, sheet = arc_sheet[1], col_names = FALSE,
                                  .name_repair = "minimal")

    # Find the header row containing "FIPS"
    header_row <- NA
    for (r in 1:min(10, nrow(df_raw))) {
      row_vals <- as.character(df_raw[r, ])
      if (any(grepl("FIPS", row_vals, ignore.case = TRUE))) {
        header_row <- r
        break
      }
    }

    if (is.na(header_row)) {
      cat(sprintf("    Could not find FIPS header in FY%d\n", fy))
      next
    }

    # Use header_row as column names, data starts after
    col_names <- as.character(df_raw[header_row, ])
    col_names[is.na(col_names)] <- paste0("V", which(is.na(col_names)))

    df_data <- df_raw[(header_row + 1):nrow(df_raw), ]
    names(df_data) <- col_names

    # Remove empty rows
    df_data <- df_data %>% filter(!is.na(.[[1]]))

    # Find columns by partial matching
    find_col <- function(patterns) {
      for (p in patterns) {
        idx <- grep(p, col_names, ignore.case = TRUE)
        if (length(idx) > 0) return(idx[1])
      }
      return(NA)
    }

    fips_idx <- find_col(c("^FIPS"))
    state_idx <- find_col(c("^State"))
    county_idx <- find_col(c("^County$"))
    status_idx <- find_col(c("Economic Status", "Status"))
    unemp_idx <- find_col(c("Unemployment Rate"))
    pcmi_idx <- find_col(c("Per Capita Market"))
    pov_idx <- find_col(c("^Poverty Rate"))
    civ_idx <- find_col(c("Composite Index"))
    rank_idx <- find_col(c("Index Value Rank", "Rank"))

    if (is.na(fips_idx) || is.na(civ_idx)) {
      cat(sprintf("    Missing FIPS or CIV in FY%d\n", fy))
      next
    }

    df_clean <- tibble(
      fips = str_pad(as.character(df_data[[fips_idx]]), width = 5, pad = "0"),
      state_name = if (!is.na(state_idx)) as.character(df_data[[state_idx]]) else NA_character_,
      county_name = if (!is.na(county_idx)) as.character(df_data[[county_idx]]) else NA_character_,
      status = if (!is.na(status_idx)) as.character(df_data[[status_idx]]) else NA_character_,
      unemp_rate_arc = if (!is.na(unemp_idx)) as.numeric(df_data[[unemp_idx]]) else NA_real_,
      pcmi = if (!is.na(pcmi_idx)) as.numeric(df_data[[pcmi_idx]]) else NA_real_,
      poverty_rate_arc = if (!is.na(pov_idx)) as.numeric(df_data[[pov_idx]]) else NA_real_,
      civ = as.numeric(df_data[[civ_idx]]),
      rank = if (!is.na(rank_idx)) as.numeric(df_data[[rank_idx]]) else NA_real_,
      fiscal_year = fy
    )

    df_clean <- df_clean %>% filter(!is.na(civ), nchar(fips) == 5)

    arc_data_list[[as.character(fy)]] <- df_clean
    n_distressed <- sum(grepl("Distressed", df_clean$status, ignore.case = TRUE), na.rm = TRUE)
    cat(sprintf("    FY%d: %d counties, %d Distressed, CIV range [%.1f, %.1f]\n",
                fy, nrow(df_clean), n_distressed,
                min(df_clean$civ, na.rm = TRUE), max(df_clean$civ, na.rm = TRUE)))

  }, error = function(e) {
    cat(sprintf("    ERROR reading FY%d: %s\n", fy, e$message))
  })
}

arc_panel <- bind_rows(arc_data_list)
cat(sprintf("\nARC panel: %d county-years, %d unique counties, FY%d-FY%d\n",
            nrow(arc_panel), n_distinct(arc_panel$fips),
            min(arc_panel$fiscal_year), max(arc_panel$fiscal_year)))

saveRDS(arc_panel, file.path(data_dir, "arc_panel_raw.rds"))

################################################################################
# 2. BLS LAUS — County Unemployment Rates
################################################################################

cat("\n=== Fetching BLS LAUS County Unemployment ===\n")

laus_url <- "https://download.bls.gov/pub/time.series/la/la.data.64.County"
laus_dest <- file.path(data_dir, "laus_county.txt")

tryCatch({
  download.file(laus_url, laus_dest, quiet = TRUE)
  cat("  Downloaded LAUS county data\n")

  laus_raw <- read_tsv(laus_dest, col_types = cols(.default = "c"), show_col_types = FALSE)

  laus_clean <- laus_raw %>%
    mutate(
      series_id = str_trim(series_id),
      fips = str_sub(series_id, 6, 10),
      measure_code = str_sub(series_id, 19, 19),
      year = as.integer(str_trim(year)),
      period = str_trim(period),
      value = as.numeric(str_trim(value))
    ) %>%
    filter(period == "M13", measure_code == "3",
           year >= 2004, year <= 2020) %>%
    select(fips, year, laus_unemp_rate = value)

  cat(sprintf("  LAUS: %d county-years\n", nrow(laus_clean)))
  saveRDS(laus_clean, file.path(data_dir, "laus_county.rds"))
}, error = function(e) {
  cat(sprintf("  LAUS download failed: %s\n", e$message))
  cat("  Will use ARC's own unemployment data.\n")
})

################################################################################
# 3. Census SAIPE — Poverty and Median Income
################################################################################

cat("\n=== Fetching Census SAIPE Data ===\n")

saipe_list <- list()
saipe_years <- 2004:2020

for (yr in saipe_years) {
  cat(sprintf("  SAIPE %d...", yr))
  url <- sprintf(
    "https://api.census.gov/data/timeseries/poverty/saipe?get=SAEPOVRTALL,SAEMHI_PT,SAEPOVALL,NAME&for=county:*&time=%d",
    yr
  )

  tryCatch({
    resp <- fromJSON(url)
    df <- as_tibble(resp[-1, ], .name_repair = "minimal")
    names(df) <- resp[1, ]
    df <- df %>%
      mutate(
        fips = paste0(state, county),
        year = yr,
        poverty_rate_saipe = as.numeric(SAEPOVRTALL),
        median_income = as.numeric(SAEMHI_PT),
        poverty_count = as.numeric(SAEPOVALL)
      ) %>%
      select(fips, year, poverty_rate_saipe, median_income, poverty_count, county_name = NAME)

    saipe_list[[as.character(yr)]] <- df
    cat(sprintf(" %d counties\n", nrow(df)))
  }, error = function(e) {
    cat(sprintf(" FAILED: %s\n", e$message))
  })

  Sys.sleep(0.3)
}

saipe_panel <- bind_rows(saipe_list)
cat(sprintf("SAIPE: %d county-years\n", nrow(saipe_panel)))
saveRDS(saipe_panel, file.path(data_dir, "saipe_county.rds"))

################################################################################
# 4. Census Population Estimates
################################################################################

cat("\n=== Fetching Census Population Estimates ===\n")

pop_list <- list()

for (yr in 2005:2019) {
  cat(sprintf("  Pop estimates %d...", yr))
  url <- sprintf(
    "https://api.census.gov/data/%d/pep/population?get=POP,NAME&for=county:*",
    yr
  )

  tryCatch({
    resp <- fromJSON(url)
    df <- as_tibble(resp[-1, ], .name_repair = "minimal")
    names(df) <- resp[1, ]
    df <- df %>%
      mutate(
        fips = paste0(state, county),
        year = yr,
        population = as.numeric(POP)
      ) %>%
      select(fips, year, population)

    pop_list[[as.character(yr)]] <- df
    cat(sprintf(" %d counties\n", nrow(df)))
  }, error = function(e) {
    cat(sprintf(" FAILED: %s\n", e$message))
  })

  Sys.sleep(0.3)
}

pop_panel <- bind_rows(pop_list)
cat(sprintf("Population: %d county-years\n", nrow(pop_panel)))
saveRDS(pop_panel, file.path(data_dir, "pop_county.rds"))

################################################################################
# 5. BEA REIS — Personal Income and Employment
################################################################################

cat("\n=== Fetching BEA REIS Data ===\n")

bea_key <- Sys.getenv("BEA_API_KEY")

if (nchar(bea_key) > 0) {
  # Personal income (CA1, Line 1)
  bea_url <- sprintf(
    "https://apps.bea.gov/api/data/?UserID=%s&method=GetData&datasetname=Regional&TableName=CAINC1&LineCode=1&GeoFIPS=COUNTY&Year=ALL&ResultFormat=JSON",
    bea_key
  )

  tryCatch({
    bea_resp <- fromJSON(bea_url, flatten = TRUE)
    bea_data <- bea_resp$BEAAPI$Results$Data

    bea_clean <- bea_data %>%
      as_tibble() %>%
      mutate(
        fips = str_pad(GeoFips, width = 5, pad = "0"),
        year = as.integer(TimePeriod),
        personal_income_k = as.numeric(gsub("[,()]", "", DataValue))
      ) %>%
      filter(year >= 2004, year <= 2020, !is.na(personal_income_k)) %>%
      select(fips, year, personal_income_k)

    cat(sprintf("  BEA personal income: %d county-years\n", nrow(bea_clean)))
    saveRDS(bea_clean, file.path(data_dir, "bea_income.rds"))
  }, error = function(e) {
    cat(sprintf("  BEA income fetch failed: %s\n", e$message))
  })

  Sys.sleep(1)

  # Total employment (CA25N, Line 10)
  bea_emp_url <- sprintf(
    "https://apps.bea.gov/api/data/?UserID=%s&method=GetData&datasetname=Regional&TableName=CAEMP25N&LineCode=10&GeoFIPS=COUNTY&Year=ALL&ResultFormat=JSON",
    bea_key
  )

  tryCatch({
    bea_emp_resp <- fromJSON(bea_emp_url, flatten = TRUE)
    bea_emp_data <- bea_emp_resp$BEAAPI$Results$Data

    bea_emp_clean <- bea_emp_data %>%
      as_tibble() %>%
      mutate(
        fips = str_pad(GeoFips, width = 5, pad = "0"),
        year = as.integer(TimePeriod),
        total_employment = as.numeric(gsub("[,()]", "", DataValue))
      ) %>%
      filter(year >= 2004, year <= 2020, !is.na(total_employment)) %>%
      select(fips, year, total_employment)

    cat(sprintf("  BEA employment: %d county-years\n", nrow(bea_emp_clean)))
    saveRDS(bea_emp_clean, file.path(data_dir, "bea_employment.rds"))
  }, error = function(e) {
    cat(sprintf("  BEA employment fetch failed: %s\n", e$message))
  })
} else {
  cat("  BEA_API_KEY not set. Skipping BEA data.\n")
}

################################################################################
# Summary
################################################################################

cat("\n=== Data Fetch Complete ===\n")
cat("Files saved to:", data_dir, "\n")
saved_files <- list.files(data_dir, pattern = "\\.rds$")
for (f in saved_files) cat(sprintf("  %s (%.1f KB)\n", f, file.size(file.path(data_dir, f))/1024))
