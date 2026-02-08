## 01_fetch_data.R — Download BFS data and construct treatment panel
## Paper 110: Recreational Marijuana and Business Formation

source("00_packages.R")

# ──────────────────────────────────────────────────────────────
# 1. Download Census Business Formation Statistics (BFS)
# ──────────────────────────────────────────────────────────────
cat("Downloading BFS monthly data from Census...\n")
bfs_url <- "https://www.census.gov/econ/bfs/csv/bfs_monthly.csv"
bfs_file <- file.path(DATA_DIR, "bfs_monthly.csv")
download.file(bfs_url, bfs_file, mode = "wb", quiet = TRUE)
cat("  Downloaded:", bfs_file, "\n")

# ──────────────────────────────────────────────────────────────
# 2. State population data from Census API (for per-capita rates)
# ──────────────────────────────────────────────────────────────
cat("Fetching state population data from Census ACS...\n")

# State FIPS codes
state_fips <- tibble(
  fips = c("01","02","04","05","06","08","09","10","11","12",
           "13","15","16","17","18","19","20","21","22","23",
           "24","25","26","27","28","29","30","31","32","33",
           "34","35","36","37","38","39","40","41","42","44",
           "45","46","47","48","49","50","51","53","54","55","56"),
  state_abbr = c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL",
                 "GA","HI","ID","IL","IN","IA","KS","KY","LA","ME",
                 "MD","MA","MI","MN","MS","MO","MT","NE","NV","NH",
                 "NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI",
                 "SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY")
)

pop_data <- list()
for (yr in 2005:2023) {
  url <- sprintf(
    "https://api.census.gov/data/%d/acs/acs1?get=NAME,B01003_001E&for=state:*",
    yr
  )
  tryCatch({
    raw <- jsonlite::fromJSON(url)
    df <- as_tibble(raw[-1, ], .name_repair = "minimal")
    names(df) <- raw[1, ]
    df <- df %>%
      mutate(year = yr, population = as.numeric(B01003_001E), fips = state) %>%
      select(year, fips, population)
    pop_data[[as.character(yr)]] <- df
    cat("  ACS", yr, "OK (", nrow(df), "states)\n")
  }, error = function(e) {
    cat("  ACS", yr, "FAILED:", conditionMessage(e), "\n")
  })
  Sys.sleep(0.3)
}
pop_all <- bind_rows(pop_data)

# Add state abbreviations
pop_all <- pop_all %>%
  left_join(state_fips, by = "fips") %>%
  filter(!is.na(state_abbr))

write_csv(pop_all, file.path(DATA_DIR, "state_population.csv"))
cat("Population data saved:", nrow(pop_all), "state-year obs\n")

# ──────────────────────────────────────────────────────────────
# 3. Treatment timing: first recreational retail sales
# ──────────────────────────────────────────────────────────────
cat("Creating treatment timing dataset...\n")

# First legal recreational retail sales dates
# Sources: NCSL Cannabis Overview, MJBizDaily, Ballotpedia
treatment <- tribble(
  ~state_abbr, ~legalization_date, ~first_retail_date, ~retail_year,
  "CO", "2012-12-10", "2014-01-01", 2014,
  "WA", "2012-12-06", "2014-07-08", 2014,
  "OR", "2015-07-01", "2015-10-01", 2015,
  "AK", "2015-02-24", "2016-10-29", 2016,
  "NV", "2017-01-01", "2017-07-01", 2017,
  "CA", "2016-11-09", "2018-01-01", 2018,
  "MA", "2016-12-15", "2018-11-20", 2018,
  "MI", "2018-12-06", "2019-12-01", 2019,
  "IL", "2020-01-01", "2020-01-01", 2020,
  "ME", "2017-01-31", "2020-10-09", 2020,
  "AZ", "2020-11-30", "2021-01-22", 2021,
  "MT", "2021-01-01", "2022-01-01", 2022,
  "NJ", "2021-02-22", "2022-04-21", 2022,
  "NM", "2021-06-29", "2022-04-01", 2022,
  "NY", "2021-03-31", "2022-12-29", 2022,
  "CT", "2021-07-01", "2023-01-10", 2023,
  "RI", "2022-05-25", "2022-12-01", 2022,
  "VT", "2018-07-01", "2022-10-01", 2022,
  "MD", "2023-07-01", "2023-07-01", 2023,
  "MO", "2022-12-08", "2023-02-03", 2023,
  "OH", "2023-12-07", "2024-08-06", 2024
)

# Medical marijuana timing (for control variable)
# Approximate year medical dispensaries opened
medical_mj <- tribble(
  ~state_abbr, ~medical_year,
  "CA", 1996, "OR", 1998, "WA", 1998, "ME", 1999, "CO", 2000,
  "HI", 2000, "NV", 2000, "MT", 2004, "VT", 2004, "RI", 2006,
  "NM", 2007, "MI", 2008, "AZ", 2010, "NJ", 2010, "DC", 2010,
  "CT", 2012, "MA", 2012, "NH", 2013, "IL", 2013, "MN", 2014,
  "NY", 2014, "MD", 2014, "FL", 2016, "OH", 2016, "PA", 2016,
  "AR", 2016, "ND", 2016, "WV", 2017, "OK", 2018, "MO", 2018,
  "UT", 2018, "LA", 2015, "VA", 2020, "MS", 2022, "AL", 2021,
  "DE", 2011, "AK", 1998, "SD", 2020, "KY", 2023
)

write_csv(treatment, file.path(DATA_DIR, "treatment_timing.csv"))
write_csv(medical_mj, file.path(DATA_DIR, "medical_marijuana.csv"))
cat("Treatment timing saved:", nrow(treatment), "treated states\n")
cat("Medical marijuana saved:", nrow(medical_mj), "states\n")

cat("\n=== Data fetch complete ===\n")
