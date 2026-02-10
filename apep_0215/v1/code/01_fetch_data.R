## =============================================================================
## 01_fetch_data.R — Fetch QCEW and BFS data from public sources
## The Innovation Cost of Privacy
## =============================================================================

source(here::here("output", "apep_0214", "v1", "code", "00_packages.R"))

data_dir <- file.path(base_dir, "data")
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

# ==== State FIPS codes ====
state_fips <- tibble(
  fips = sprintf("%02d", c(1,2,4,5,6,8,9,10,11,12,13,15,16,17,18,19,20,
                            21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,
                            36,37,38,39,40,41,42,44,45,46,47,48,49,50,51,
                            53,54,55,56)),
  state_abbr = c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL","GA",
                  "HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA",
                  "MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY",
                  "NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX",
                  "UT","VT","VA","WA","WV","WI","WY")
)

# ==== 1. Fetch BLS QCEW Data via Bulk CSV Files ====
cat("=== Fetching BLS QCEW data (bulk CSV) ===\n")

target_industries <- c("10", "23", "31-33", "51", "5112", "518", "62")
years <- 2015:2025

all_qcew <- list()
idx <- 1

for (yr in years) {
  for (q in 1:4) {
    # Bulk CSV URL for each year-quarter
    # Format: https://data.bls.gov/cew/data/api/YEAR/QTR/industry/10.csv (all states)
    # Better: fetch by industry to get all states at once
    for (ind in target_industries) {
      url <- sprintf("https://data.bls.gov/cew/data/api/%d/%d/industry/%s.csv", yr, q, ind)
      cat(sprintf("\rFetching QCEW: year=%d Q%d industry=%s     ", yr, q, ind))

      df <- tryCatch({
        resp <- GET(url, timeout(60))
        if (status_code(resp) == 200) {
          txt <- content(resp, as = "text", encoding = "UTF-8")
          read_csv(txt, show_col_types = FALSE)
        } else {
          NULL
        }
      }, error = function(e) NULL)

      if (!is.null(df) && nrow(df) > 0) {
        # Filter to state-level, private ownership
        filtered <- df %>%
          filter(own_code == 5,
                 agglvl_code %in% c(50, 51, 52, 53, 54, 55, 56, 57, 58),
                 substr(area_fips, 3, 5) == "000",  # State-level only
                 area_fips != "US000") %>%
          select(area_fips, industry_code, year, qtr,
                 qtrly_estabs, month1_emplvl, month2_emplvl, month3_emplvl,
                 total_qtrly_wages, avg_wkly_wage)

        if (nrow(filtered) > 0) {
          all_qcew[[idx]] <- filtered
          idx <- idx + 1
        }
      }

      Sys.sleep(0.3)
    }
  }
}

cat("\nBinding QCEW results...\n")
qcew_raw <- bind_rows(all_qcew)

# Compute average quarterly employment
qcew_raw <- qcew_raw %>%
  mutate(
    avg_emp = (month1_emplvl + month2_emplvl + month3_emplvl) / 3,
    state_fips = substr(area_fips, 1, 2)
  )

cat(sprintf("QCEW: %d rows, %d unique states\n", nrow(qcew_raw), n_distinct(qcew_raw$state_fips)))

write_csv(qcew_raw, file.path(data_dir, "qcew_raw.csv"))
cat("Saved: qcew_raw.csv\n")


# ==== 2. Fetch Census Business Formation Statistics ====
cat("\n=== Fetching Census BFS data ===\n")

bfs_url <- "https://www.census.gov/econ/bfs/csv/bfs_quarterly.csv"
bfs_raw <- tryCatch({
  read_csv(bfs_url, show_col_types = FALSE)
}, error = function(e) {
  # Fallback: try downloading
  download.file(bfs_url, file.path(data_dir, "bfs_quarterly.csv"), quiet = TRUE)
  read_csv(file.path(data_dir, "bfs_quarterly.csv"), show_col_types = FALSE)
})

# BFS has columns: sa, series, geo, year, Q1, Q2, Q3, Q4
bfs_long <- bfs_raw %>%
  filter(series %in% c("BA_BA", "BA_HBA")) %>%
  pivot_longer(cols = starts_with("Q"), names_to = "quarter_str", values_to = "applications") %>%
  mutate(
    quarter = as.integer(str_extract(quarter_str, "\\d")),
    applications = as.numeric(applications)
  ) %>%
  filter(!is.na(applications), year >= 2015, year <= 2025) %>%
  select(sa, series, geo, year, quarter, applications)

# Filter to state-level only
bfs_states <- bfs_long %>%
  filter(geo %in% state_fips$state_abbr)

cat(sprintf("BFS: %d rows, %d unique states\n", nrow(bfs_states), n_distinct(bfs_states$geo)))

write_csv(bfs_states, file.path(data_dir, "bfs_raw.csv"))
cat("Saved: bfs_raw.csv\n")


cat("\n=== Data fetching complete ===\n")
cat(sprintf("QCEW: %d observations\n", nrow(qcew_raw)))
cat(sprintf("BFS:  %d observations\n", nrow(bfs_states)))
