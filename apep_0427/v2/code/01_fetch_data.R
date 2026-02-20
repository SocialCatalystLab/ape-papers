# =============================================================================
# 01_fetch_data.R — Data Acquisition
# apep_0427: France Apprenticeship Subsidy and Entry-Level Labor Markets
# =============================================================================

source("00_packages.R")

cat("=== Fetching data for apep_0427 ===\n")

# --------------------------------------------------
# 1. Eurostat: Youth Employment Rate (Quarterly)
#    Dataset: lfsi_emp_q
# --------------------------------------------------
cat("Fetching Eurostat youth employment data (lfsi_emp_q)...\n")

emp_q <- get_eurostat("lfsi_emp_q", time_format = "date")

countries <- c("FR", "BE", "NL", "ES", "IT", "PT", "DE", "AT")
age_groups <- c("Y15-24", "Y25-54", "Y15-64")

emp_filtered <- emp_q %>%
  filter(
    geo %in% countries,
    age %in% age_groups,
    sex == "T",
    unit == "PC_POP",
    s_adj == "SA",
    indic_em == "EMP_LFS"
  ) %>%
  select(geo, age, TIME_PERIOD, values) %>%
  rename(country = geo, age_group = age, date = TIME_PERIOD, emp_rate = values)

cat(sprintf("  Employment data: %d rows, %d countries, %s to %s\n",
            nrow(emp_filtered), n_distinct(emp_filtered$country),
            min(emp_filtered$date), max(emp_filtered$date)))

saveRDS(emp_filtered, "../data/eurostat_emp_q.rds")

# --------------------------------------------------
# 2. Eurostat: NEET Rate (Quarterly)
#    Dataset: lfsi_neet_q
# --------------------------------------------------
cat("Fetching Eurostat NEET rate data (lfsi_neet_q)...\n")

neet_q <- get_eurostat("lfsi_neet_q", time_format = "date")

cat(sprintf("  NEET columns: %s\n", paste(names(neet_q), collapse = ", ")))

neet_filtered <- neet_q %>%
  filter(
    geo %in% countries,
    sex == "T",
    unit == "PC_POP",
    s_adj == "SA"
  ) %>%
  select(geo, age, TIME_PERIOD, values) %>%
  rename(country = geo, age_group = age, date = TIME_PERIOD, neet_rate = values)

cat(sprintf("  NEET data: %d rows\n", nrow(neet_filtered)))

saveRDS(neet_filtered, "../data/eurostat_neet_q.rds")

# --------------------------------------------------
# 3. Eurostat: Employment by NACE Sector and Age (Quarterly)
#    Dataset: lfsq_egan2 (NACE Rev 2 sections)
# --------------------------------------------------
cat("Fetching Eurostat sector employment data...\n")

sector_emp <- tryCatch({
  cat("  Trying lfsq_egan2...\n")
  d <- get_eurostat("lfsq_egan2", time_format = "date")
  cat(sprintf("  Columns: %s\n", paste(names(d), collapse = ", ")))
  d
}, error = function(e) {
  cat(sprintf("  lfsq_egan2 failed: %s\n", e$message))
  cat("  Trying lfsq_egan22d...\n")
  tryCatch({
    d <- get_eurostat("lfsq_egan22d", time_format = "date")
    cat(sprintf("  Columns: %s\n", paste(names(d), collapse = ", ")))
    d
  }, error = function(e2) {
    cat(sprintf("  lfsq_egan22d failed: %s\n", e2$message))
    cat("  Trying lfsa_egan2 (annual)...\n")
    d <- get_eurostat("lfsa_egan2", time_format = "date")
    cat(sprintf("  Columns: %s\n", paste(names(d), collapse = ", ")))
    d
  })
})

# Find the NACE column
nace_col <- grep("nace", names(sector_emp), value = TRUE, ignore.case = TRUE)
if (length(nace_col) == 0) nace_col <- grep("econ", names(sector_emp), value = TRUE, ignore.case = TRUE)
cat(sprintf("  NACE column: %s\n", paste(nace_col, collapse = ", ")))

sector_filtered <- sector_emp %>%
  filter(
    geo == "FR",
    sex == "T",
    age %in% c("Y15-24", "Y25-54", "Y_GE15"),
    unit == "THS_PER"
  )

# Dynamically select columns
sel_cols <- c("geo", nace_col[1], "age", "TIME_PERIOD", "values")
sel_cols <- sel_cols[sel_cols %in% names(sector_filtered)]
sector_filtered <- sector_filtered %>%
  select(all_of(sel_cols)) %>%
  rename(country = geo, date = TIME_PERIOD, employment = values)

# Rename NACE column to 'sector'
if (nace_col[1] != "sector" & nace_col[1] %in% names(sector_filtered)) {
  sector_filtered <- sector_filtered %>%
    rename(sector = !!nace_col[1])
}

cat(sprintf("  Sector employment: %d rows, %d sectors\n",
            nrow(sector_filtered), n_distinct(sector_filtered$sector)))

saveRDS(sector_filtered, "../data/eurostat_sector_emp.rds")

# --------------------------------------------------
# 4. Eurostat: Temporary Employment by Age (Quarterly)
# --------------------------------------------------
cat("Fetching Eurostat temporary employment data...\n")

temp_emp <- tryCatch({
  d <- get_eurostat("lfsq_etpga", time_format = "date")
  cat(sprintf("  Columns: %s\n", paste(names(d), collapse = ", ")))
  d
}, error = function(e) {
  cat(sprintf("  lfsq_etpga failed: %s\n", e$message))
  d <- get_eurostat("lfsa_etpga", time_format = "date")
  cat(sprintf("  Using annual: %s\n", paste(names(d), collapse = ", ")))
  d
})

temp_filtered <- temp_emp %>%
  filter(
    geo %in% countries,
    sex == "T",
    age %in% c("Y15-24", "Y25-54")
  ) %>%
  select(geo, age, TIME_PERIOD, values) %>%
  rename(country = geo, age_group = age, date = TIME_PERIOD, temp_share = values)

cat(sprintf("  Temporary employment: %d rows\n", nrow(temp_filtered)))

saveRDS(temp_filtered, "../data/eurostat_temp_emp.rds")

# --------------------------------------------------
# 5. Indeed Hiring Lab: Job Postings Index
# --------------------------------------------------
cat("Fetching Indeed Hiring Lab job postings data...\n")

# Try multiple URL patterns
indeed_fr <- NULL
for (branch in c("master", "main")) {
  if (is.null(indeed_fr)) {
    indeed_fr <- tryCatch({
      read_csv(sprintf("https://raw.githubusercontent.com/hiring-lab/job_postings_tracker/%s/FR/aggregate_job_postings_FR.csv", branch),
               show_col_types = FALSE)
    }, error = function(e) NULL)
  }
}

if (is.null(indeed_fr)) {
  cat("  WARNING: Could not fetch Indeed France data. Trying lowercase...\n")
  for (branch in c("master", "main")) {
    if (is.null(indeed_fr)) {
      indeed_fr <- tryCatch({
        read_csv(sprintf("https://raw.githubusercontent.com/hiring-lab/job_postings_tracker/%s/FR/aggregate_job_postings_fr.csv", branch),
                 show_col_types = FALSE)
      }, error = function(e) NULL)
    }
  }
}

if (!is.null(indeed_fr)) {
  cat(sprintf("  Indeed France: %d rows\n", nrow(indeed_fr)))
  cat(sprintf("  Columns: %s\n", paste(names(indeed_fr), collapse = ", ")))
  saveRDS(indeed_fr, "../data/indeed_fr_aggregate.rds")
} else {
  cat("  ERROR: Could not fetch Indeed France data\n")
}

# Sector-level for France
indeed_sector <- NULL
for (branch in c("master", "main")) {
  if (is.null(indeed_sector)) {
    indeed_sector <- tryCatch({
      read_csv(sprintf("https://raw.githubusercontent.com/hiring-lab/job_postings_tracker/%s/FR/job_postings_by_sector_FR.csv", branch),
               show_col_types = FALSE)
    }, error = function(e) NULL)
  }
  if (is.null(indeed_sector)) {
    indeed_sector <- tryCatch({
      read_csv(sprintf("https://raw.githubusercontent.com/hiring-lab/job_postings_tracker/%s/FR/job_postings_by_sector_fr.csv", branch),
               show_col_types = FALSE)
    }, error = function(e) NULL)
  }
}

if (!is.null(indeed_sector)) {
  cat(sprintf("  Indeed sector: %d rows\n", nrow(indeed_sector)))
  saveRDS(indeed_sector, "../data/indeed_fr_sector.rds")
} else {
  cat("  WARNING: Could not fetch Indeed sector data\n")
}

# Comparison countries
for (cc in c("DE", "ES", "IT", "NL", "GB")) {
  indeed_cc <- NULL
  for (branch in c("master", "main")) {
    if (is.null(indeed_cc)) {
      indeed_cc <- tryCatch({
        read_csv(sprintf("https://raw.githubusercontent.com/hiring-lab/job_postings_tracker/%s/%s/aggregate_job_postings_%s.csv", branch, cc, cc),
                 show_col_types = FALSE)
      }, error = function(e) NULL)
    }
    if (is.null(indeed_cc)) {
      indeed_cc <- tryCatch({
        read_csv(sprintf("https://raw.githubusercontent.com/hiring-lab/job_postings_tracker/%s/%s/aggregate_job_postings_%s.csv", branch, cc, tolower(cc)),
                 show_col_types = FALSE)
      }, error = function(e) NULL)
    }
  }
  if (!is.null(indeed_cc)) {
    saveRDS(indeed_cc, sprintf("../data/indeed_%s_aggregate.rds", tolower(cc)))
    cat(sprintf("  Indeed %s: %d rows\n", cc, nrow(indeed_cc)))
  } else {
    cat(sprintf("  WARNING: Could not fetch Indeed data for %s\n", cc))
  }
}

# --------------------------------------------------
# 6. FRED: Macro Controls
# --------------------------------------------------
cat("Fetching FRED macro controls...\n")

fred_key <- Sys.getenv("FRED_API_KEY")
if (nchar(fred_key) > 0) {
  fredr_set_key(fred_key)

  fred_series <- c(
    "LRUN24TTFRQ156S",  # France youth unemployment
    "LRUN24TTDEQ156S",  # Germany
    "LRUN24TTESQ156S",  # Spain
    "LRUN24TTITQ156S",  # Italy
    "LRUN24TTNLQ156S",  # Netherlands
    "LRUN24TTBEQ156S",  # Belgium
    "LRHUTTTTFRQ156S",  # France total unemployment
    "CLVMNACSCAB1GQFR"  # France GDP
  )

  fred_data <- map_dfr(fred_series, function(s) {
    tryCatch({
      d <- fredr(series_id = s, observation_start = as.Date("2015-01-01"))
      d$series <- s
      return(d)
    }, error = function(e) {
      cat(sprintf("  WARNING: FRED series %s failed\n", s))
      return(NULL)
    })
  })

  cat(sprintf("  FRED data: %d rows\n", nrow(fred_data)))
  saveRDS(fred_data, "../data/fred_macro.rds")
} else {
  cat("  FRED API key not set — skipping\n")
}

# --------------------------------------------------
# 7. DARES Excel download
# --------------------------------------------------
cat("Fetching DARES apprenticeship statistics...\n")

dares_url <- "https://dares.travail-emploi.gouv.fr/sites/default/files/10c4009ace0158761fb86aadf60dce07/Dares_R%C3%A9sultats_apprentissage_2023.xlsx"
dares_file <- "../data/dares_apprentissage_2023.xlsx"

tryCatch({
  download.file(dares_url, dares_file, mode = "wb", quiet = TRUE)
  cat(sprintf("  DARES file downloaded\n"))
}, error = function(e) {
  cat(sprintf("  DARES download failed: %s\n", e$message))
})

cat("\n=== Data acquisition complete ===\n")
