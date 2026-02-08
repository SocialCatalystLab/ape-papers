# ============================================================================
# Paper 75: The Making of a City
# 03_process_data.R - Load and filter IPUMS data (memory-efficient)
# ============================================================================

# Load packages
source("output/paper_75/code/00_packages.R")

# ============================================================================
# Configuration
# ============================================================================

DATA_DIR <- "output/paper_75/data"

# City definitions (using COUNTYICP codes)
# COUNTYICP = FIPS code + 0 (e.g., SF FIPS=075 → COUNTYICP=750)
SF_STATEFIP <- 6
SF_COUNTYICP <- 750

LA_STATEFIP <- 6
LA_COUNTYICP <- 370

SEA_STATEFIP <- 53
SEA_COUNTYICP <- 330

# ============================================================================
# Chunked reading function - filters as it reads
# ============================================================================

process_ipums_chunked <- function(file_path, chunk_size = 5000000) {
  msg("Processing file in chunks: ", file_path)
  msg("Chunk size: ", fmt_num(chunk_size), " rows")

  # We'll use readr for chunked reading since data.table doesn't support it well for gz
  library(readr)

  # Define column types
  col_spec <- cols(
    YEAR = col_integer(),
    SERIAL = col_integer(),
    STATEFIP = col_integer(),
    COUNTYICP = col_integer(),
    PERNUM = col_integer(),
    AGE = col_integer(),
    SEX = col_integer(),
    RACE = col_integer(),
    MARST = col_integer(),
    BPL = col_integer(),
    NATIVITY = col_integer(),
    LIT = col_integer(),
    SCHOOL = col_integer(),
    LABFORCE = col_integer(),
    OCC1950 = col_integer(),
    CLASSWKR = col_integer(),
    OCCSCORE = col_integer(),
    MOMLOC = col_integer(),
    POPLOC = col_integer(),
    SPLOC = col_integer(),
    RELATE = col_integer(),
    NCHILD = col_integer(),
    HISTID = col_character(),
    .default = col_skip()  # Skip all other columns
  )

  # Initialize result list
  results <- list()
  chunk_num <- 0

  # Process callback function
  process_chunk <- function(chunk, pos) {
    chunk_num <<- chunk_num + 1

    # Filter to cities of interest
    filtered <- chunk %>%
      filter(
        (STATEFIP == SF_STATEFIP & COUNTYICP == SF_COUNTYICP) |
          (STATEFIP == LA_STATEFIP & COUNTYICP == LA_COUNTYICP) |
          (STATEFIP == SEA_STATEFIP & COUNTYICP == SEA_COUNTYICP)
      )

    if (nrow(filtered) > 0) {
      msg("  Chunk ", chunk_num, ": ", fmt_num(nrow(chunk)), " rows -> ",
          fmt_num(nrow(filtered)), " in target cities")
      results[[length(results) + 1]] <<- filtered
    } else {
      msg("  Chunk ", chunk_num, ": ", fmt_num(nrow(chunk)), " rows -> 0 in target cities")
    }
  }

  # Read in chunks
  read_csv_chunked(
    file_path,
    callback = SideEffectChunkCallback$new(process_chunk),
    chunk_size = chunk_size,
    col_types = col_spec,
    progress = FALSE
  )

  # Combine results
  msg("Combining ", length(results), " chunks...")
  combined <- bind_rows(results)

  # Add city name
  combined <- combined %>%
    mutate(
      city = case_when(
        STATEFIP == SF_STATEFIP & COUNTYICP == SF_COUNTYICP ~ "San Francisco",
        STATEFIP == LA_STATEFIP & COUNTYICP == LA_COUNTYICP ~ "Los Angeles",
        STATEFIP == SEA_STATEFIP & COUNTYICP == SEA_COUNTYICP ~ "Seattle",
        TRUE ~ "Unknown"
      )
    )

  msg("Total records in target cities: ", fmt_num(nrow(combined)))
  return(as.data.table(combined))
}

# ============================================================================
# Load 1900-1910 data (earthquake analysis)
# ============================================================================

msg("=" |> strrep(60))
msg("Loading 1900-1910 earthquake analysis data")
msg("=" |> strrep(60))

# Check if processed file exists
processed_1900_1910 <- file.path(DATA_DIR, "sf_la_sea_1900_1910.rds")

if (file.exists(processed_1900_1910)) {
  msg("Loading cached processed data...")
  dt_1900_1910 <- readRDS(processed_1900_1910)
  msg("Loaded ", fmt_num(nrow(dt_1900_1910)), " records from cache")
} else {
  # Check for raw IPUMS extract
  raw_file <- file.path(DATA_DIR, "usa_00142.csv.gz")

  if (!file.exists(raw_file)) {
    msg("No IPUMS data file found: ", raw_file)
    stop("Data not yet available")
  }

  # Load and filter using chunked processing
  dt_1900_1910 <- process_ipums_chunked(raw_file)

  # Save processed subset
  msg("Saving processed subset...")
  saveRDS(dt_1900_1910, processed_1900_1910)
  msg("Saved to: ", processed_1900_1910)
}

# ============================================================================
# Summary statistics
# ============================================================================

msg("\n", "=" |> strrep(60))
msg("Data Summary")
msg("=" |> strrep(60))

# Sample sizes by city and year
sample_summary <- dt_1900_1910 |>
  group_by(city, YEAR) |>
  summarize(
    n = n(),
    n_linked = sum(!is.na(HISTID) & HISTID != ""),
    pct_linked = mean(!is.na(HISTID) & HISTID != "") * 100,
    .groups = "drop"
  )

print(sample_summary)

# Demographics
demo_summary <- dt_1900_1910 |>
  group_by(city, YEAR) |>
  summarize(
    mean_age = mean(AGE, na.rm = TRUE),
    pct_male = mean(SEX == 1, na.rm = TRUE) * 100,
    pct_literate = mean(LIT == 2, na.rm = TRUE) * 100,
    pct_foreign = mean(NATIVITY > 0, na.rm = TRUE) * 100,
    .groups = "drop"
  )

print(demo_summary)

# ============================================================================
# Create analysis datasets
# ============================================================================

msg("\n", "=" |> strrep(60))
msg("Creating analysis datasets")
msg("=" |> strrep(60))

# 1. San Francisco 1900 population (base for tracking)
sf_1900 <- dt_1900_1910[city == "San Francisco" & YEAR == 1900]
msg("SF 1900 sample: ", fmt_num(nrow(sf_1900)), " individuals")

# 2. San Francisco 1910 population
sf_1910 <- dt_1900_1910[city == "San Francisco" & YEAR == 1910]
msg("SF 1910 sample: ", fmt_num(nrow(sf_1910)), " individuals")

# 3. Get all 1910 records for finding where SF 1900 residents went
all_1910 <- dt_1900_1910[YEAR == 1910]
msg("All cities 1910 sample: ", fmt_num(nrow(all_1910)), " individuals")

# 4. Link SF 1900 to 1910 using HISTID
msg("\nLinking SF 1900 residents to 1910...")

# Get SF 1900 with valid HISTID
sf_1900_linkable <- sf_1900[!is.na(HISTID) & HISTID != ""]
msg("SF 1900 with valid HISTID: ", fmt_num(nrow(sf_1900_linkable)))

# Find where they ended up in 1910
sf_linked <- merge(
  sf_1900_linkable[, .(HISTID, YEAR_1900 = YEAR, AGE_1900 = AGE, SEX, RACE,
                       BPL, NATIVITY, LIT, OCC1950_1900 = OCC1950, OCCSCORE_1900 = OCCSCORE)],
  all_1910[!is.na(HISTID) & HISTID != "", .(HISTID, city_1910 = city, YEAR_1910 = YEAR,
                                            AGE_1910 = AGE, OCC1950_1910 = OCC1950, OCCSCORE_1910 = OCCSCORE)],
  by = "HISTID",
  all.x = TRUE  # Keep all 1900 SF residents, linked or not
)

msg("SF 1900 residents tracked to 1910: ", fmt_num(sum(!is.na(sf_linked$city_1910))), " linked")
msg("SF 1900 residents not found in 1910: ", fmt_num(sum(is.na(sf_linked$city_1910))))

# 5. Categorize 1910 destination
sf_linked[, destination := fcase(
  is.na(city_1910), "Not linked",
  city_1910 == "San Francisco", "Stayed in SF",
  city_1910 == "Los Angeles", "Moved to LA",
  city_1910 == "Seattle", "Moved to Seattle",
  default = "Moved elsewhere"
)]

# Summary of destinations
msg("\nDestination summary:")
print(sf_linked[, .N, by = destination][order(-N)])

# Save analysis datasets
saveRDS(sf_linked, file.path(DATA_DIR, "sf_1900_linked.rds"))
msg("Saved SF 1900 linked dataset")

# ============================================================================
# Save summary statistics
# ============================================================================

write.csv(sample_summary, file.path(DATA_DIR, "sample_summary.csv"), row.names = FALSE)
write.csv(demo_summary, file.path(DATA_DIR, "demographic_summary.csv"), row.names = FALSE)

msg("\n", "=" |> strrep(60))
msg("Processing complete!")
msg("=" |> strrep(60))
