# Data Validation Script for Swiss Intersectional Cultural Borders Paper
# Tests: swissdd referendum data, BFS population stats, SMMT municipality mapping

# 1. Test swissdd - referendum data
cat("=== Testing swissdd ===\n")
if (!require("swissdd")) install.packages("swissdd", repos="https://cloud.r-project.org")
library(swissdd)

# Try to fetch national vote data at municipality level
# Use a known referendum: September 26, 2021 "Marriage for All"
votes <- get_nationalvotes(votedates = "2021-09-26", geolevel = "municipality")
cat("swissdd rows:", nrow(votes), "\n")
cat("swissdd columns:", paste(names(votes), collapse=", "), "\n")
cat("Sample municipalities:", head(votes$mun_name, 5), "\n")
cat("Vote share range:", range(votes$ja_stimmen_in_prozent, na.rm=TRUE), "\n\n")

# 2. Test fetching multiple referendums over time
cat("=== Testing time series ===\n")
# Get all gender-related votes from 2020 onwards (paternity leave + marriage)
votes_multi <- get_nationalvotes(from_date = "2020-01-01", to_date = "2022-12-31", geolevel = "municipality")
cat("Multi-year rows:", nrow(votes_multi), "\n")
cat("Unique vote dates:", length(unique(votes_multi$datum)), "\n")
cat("Unique municipalities:", length(unique(votes_multi$mun_id)), "\n\n")

# 3. Test historical reach - how far back can we go?
cat("=== Testing historical data ===\n")
votes_1981 <- tryCatch({
  get_nationalvotes(votedates = "1981-06-14", geolevel = "municipality")
}, error = function(e) {
  cat("1981 data error:", e$message, "\n")
  NULL
})
if (!is.null(votes_1981)) {
  cat("1981 data rows:", nrow(votes_1981), "\n")
}

votes_1990 <- tryCatch({
  get_nationalvotes(from_date = "1990-01-01", to_date = "1990-12-31", geolevel = "municipality")
}, error = function(e) {
  cat("1990 data error:", e$message, "\n")
  NULL
})
if (!is.null(votes_1990)) {
  cat("1990 data rows:", nrow(votes_1990), "\n\n")
}

# 4. Test SMMT - municipality mapping
cat("=== Testing SMMT ===\n")
if (!require("SMMT")) install.packages("SMMT", repos="https://cloud.r-project.org")
library(SMMT)

# Check available functions
cat("SMMT functions:", paste(ls("package:SMMT"), collapse=", "), "\n")

# Try to get current municipality list
mun <- tryCatch({
  smmt_get_mutations(year = 2024)
}, error = function(e) {
  cat("SMMT mutations error:", e$message, "\n")
  NULL
})
if (!is.null(mun)) {
  cat("SMMT mutations rows:", nrow(mun), "\n")
}

# 5. Test BFS package
cat("\n=== Testing BFS ===\n")
if (!require("BFS")) install.packages("BFS", repos="https://cloud.r-project.org")
library(BFS)

# List available catalog entries
catalog <- tryCatch({
  bfs_get_catalog_data(language = "en")
}, error = function(e) {
  cat("BFS catalog error:", e$message, "\n")
  NULL
})
if (!is.null(catalog)) {
  cat("BFS catalog entries:", nrow(catalog), "\n")
  # Search for vital statistics (marriage/divorce)
  vital <- catalog[grepl("marriage|divorce|heirat|scheidung|mariage", catalog$title, ignore.case = TRUE), ]
  cat("Marriage/divorce datasets:", nrow(vital), "\n")
  if (nrow(vital) > 0) {
    cat("Titles:\n")
    print(head(vital$title, 10))
  }

  # Search for population by gender
  gender <- catalog[grepl("geschlecht|gender|sex|bevölkerung", catalog$title, ignore.case = TRUE), ]
  cat("\nGender/population datasets:", nrow(gender), "\n")
  if (nrow(gender) > 0) {
    cat("Titles:\n")
    print(head(gender$title, 10))
  }
}

cat("\n=== VALIDATION COMPLETE ===\n")
