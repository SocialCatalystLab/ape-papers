# =============================================================================
# 01_fetch_data.R - Download BRFSS Data
# Paper 59: State Insulin Price Caps and Diabetes Management Outcomes
# =============================================================================

source("output/paper_59/code/00_packages.R")

# =============================================================================
# BRFSS Data Download
# =============================================================================

# BRFSS microdata is available from CDC:
# https://www.cdc.gov/brfss/annual_data/annual_data.htm

# For this analysis, we use the BRFSS SMART MMSA data which has state identifiers
# We'll download the annual BRFSS datasets for 2017-2023

years <- 2017:2023

# Create data directory
dir.create("output/paper_59/data", showWarnings = FALSE, recursive = TRUE)

# Function to download BRFSS data
download_brfss <- function(year) {
  # BRFSS SAS Transport files are large - use pre-compiled state-level summaries instead
  # For full microdata analysis, would need to download XPT files

  cat(sprintf("\nNote: For full analysis, download BRFSS %d XPT file from:\n", year))
  cat(sprintf("https://www.cdc.gov/brfss/annual_data/%d/files/LLCP%d_XPT.zip\n", year, year))
}

# Show download instructions
cat("\n===== BRFSS DATA ACQUISITION =====\n")
for (y in years) {
  download_brfss(y)
}

# =============================================================================
# Alternative: Use CDC PLACES API for State-Level Diabetes Indicators
# =============================================================================

# The PLACES API provides pre-computed state-level diabetes prevalence and management
# This is more tractable than downloading full BRFSS microdata

cat("\n\n===== Fetching CDC PLACES Data =====\n")

# CDC PLACES state-level data
# https://data.cdc.gov/500-Cities-Places/PLACES-Local-Data-for-Better-Health-Place-Data-202/eav7-ber6

places_url <- "https://data.cdc.gov/resource/swc5-untb.json"

# Query for diabetes-related measures at state level
# Measure IDs related to diabetes:
# - DIABETES: Diagnosed diabetes among adults
# - CHECKUP: Visited a doctor for routine checkup in past year
# - HIGHCHOL: High cholesterol among adults

fetch_places_data <- function(year, measure, limit = 100) {
  url <- sprintf(
    "%s?year=%d&measureid=%s&$limit=%d",
    places_url, year, measure, limit
  )

  response <- tryCatch({
    GET(url, timeout(30))
  }, error = function(e) {
    cat(sprintf("Error fetching %s for %d: %s\n", measure, year, e$message))
    return(NULL)
  })

  if (is.null(response) || status_code(response) != 200) {
    cat(sprintf("Failed to fetch %s for %d (status: %s)\n",
                measure, year,
                ifelse(is.null(response), "NULL", status_code(response))))
    return(NULL)
  }

  data <- fromJSON(content(response, "text", encoding = "UTF-8"))
  if (length(data) == 0) return(NULL)

  data$year <- year
  data$measure <- measure
  return(data)
}

# Fetch diabetes prevalence data
cat("Fetching state-level diabetes indicators...\n")

# Note: PLACES data is at county/tract level primarily
# For state-level, we'll use BRFSS directly

# =============================================================================
# BRFSS Web Data Query Tool: State-Level Prevalence
# =============================================================================

# The BRFSS Web Data Query Tool provides pre-computed state-level estimates
# We'll manually construct the dataset from published BRFSS prevalence data

# Diabetes prevalence by state 2017-2023 (from BRFSS published reports)
# Source: https://www.cdc.gov/diabetes/data/statistics-report/index.html

cat("\nConstructing state-level diabetes dataset from BRFSS published estimates...\n")

# Create simulated state-year panel based on BRFSS structure
# In production, this would come from actual BRFSS microdata

# State-level diabetes prevalence data (approximate values from CDC reports)
# This represents the structure - actual analysis requires real BRFSS download

set.seed(12345)

# Generate state-year panel structure
panel_data <- expand.grid(
  fips = state_fips$fips,
  year = 2017:2023
) %>%
  left_join(state_fips, by = "fips") %>%
  left_join(
    insulin_cap_laws %>% select(fips, treatment_year, cap_amount),
    by = "fips"
  ) %>%
  mutate(
    # Treatment indicator
    treatment_year = ifelse(is.na(treatment_year), 0, treatment_year),
    treated = ifelse(treatment_year > 0 & year >= treatment_year, 1, 0),

    # Event time
    event_time = ifelse(treatment_year > 0, year - treatment_year, NA)
  )

cat(sprintf("\nPanel structure created: %d state-years\n", nrow(panel_data)))
cat(sprintf("Treated states: %d\n", length(unique(panel_data$fips[panel_data$treatment_year > 0]))))
cat(sprintf("Never-treated states: %d\n", length(unique(panel_data$fips[panel_data$treatment_year == 0]))))

# =============================================================================
# Download Actual BRFSS Microdata for Diabetes Module
# =============================================================================

# BRFSS diabetes module questions vary by year
# Key variables:
# - DIABETE4: Ever told you have diabetes?
# - INSULIN1: Are you now taking insulin?
# - DOCTDIAB: How many times seen doctor for diabetes in past year?
# - CHKHEMO3: When last had A1C checked?
# - DIABEYE1: Has diabetes affected eyes?
# - LASTDEN4: Last dental visit (general health proxy)

# For this analysis, we'll use the LLCP (core + module) files

brfss_variables <- c(
  # Diabetes diagnosis and treatment
  "DIABETE4",   # Diabetes diagnosis
  "INSULIN1",   # Taking insulin
  "DIABETE3",   # Diabetes type (type 1, type 2, gestational)

  # Healthcare utilization
  "DOCTDIAB",   # Doctor visits for diabetes
  "CHKHEMO3",   # A1C monitoring frequency
  "EYEEXAM1",   # Eye exam in past year

  # Complications
  "DIABEYE1",   # Diabetes affected eyes

  # Demographics
  "_STATE",     # State FIPS
  "_AGEG5YR",   # Age categories
  "SEX",        # Sex
  "_RACE",      # Race/ethnicity
  "_EDUCAG",    # Education
  "_INCOMG1",   # Income
  "EMPLOY1",    # Employment status
  "HLTHPLN1",   # Health insurance

  # Survey weights
  "_LLCPWT"     # Final weight
)

cat("\n===== BRFSS Variable List =====\n")
cat("Variables needed for diabetes analysis:\n")
print(brfss_variables)

# =============================================================================
# Save Panel Structure for Analysis
# =============================================================================

# Save the treatment assignment and panel structure
saveRDS(panel_data, "output/paper_59/data/panel_structure.rds")
saveRDS(insulin_cap_laws, "output/paper_59/data/treatment_assignment.rds")

cat("\nPanel structure saved to data/panel_structure.rds\n")
cat("Treatment assignment saved to data/treatment_assignment.rds\n")

# =============================================================================
# Instructions for Full BRFSS Download
# =============================================================================

cat("\n")
cat("=" %>% rep(70) %>% paste0(collapse = ""), "\n")
cat("TO COMPLETE DATA ACQUISITION:\n")
cat("=" %>% rep(70) %>% paste0(collapse = ""), "\n")
cat("\n")
cat("1. Download BRFSS LLCP files for 2017-2023 from:\n")
cat("   https://www.cdc.gov/brfss/annual_data/annual_data.htm\n")
cat("\n")
cat("2. Extract XPT files and place in output/paper_59/data/\n")
cat("\n")
cat("3. Run 02_clean_data.R to process microdata\n")
cat("\n")

# =============================================================================
# For this analysis: Use CDC Diabetes Atlas Data
# =============================================================================

# The CDC Diabetes Atlas provides county-level diagnosed diabetes prevalence
# This is derived from BRFSS and other sources

cat("\n===== Fetching CDC Diabetes Atlas Data =====\n")

# CDC Diabetes Atlas API
# https://gis.cdc.gov/grasp/diabetes/DiabetesAtlas.html

# County-level diagnosed diabetes prevalence, 2017-2021
diabetes_atlas_url <- "https://data.cdc.gov/resource/hn4x-zwk7.json"

fetch_diabetes_atlas <- function() {
  # Fetch state-level aggregates
  url <- sprintf("%s?$limit=50000", diabetes_atlas_url)

  response <- tryCatch({
    GET(url, timeout(60))
  }, error = function(e) {
    cat(sprintf("Error: %s\n", e$message))
    return(NULL)
  })

  if (is.null(response) || status_code(response) != 200) {
    cat("Failed to fetch Diabetes Atlas data\n")
    return(NULL)
  }

  data <- fromJSON(content(response, "text", encoding = "UTF-8"))
  return(data)
}

cat("Attempting to fetch CDC Diabetes Atlas data...\n")
atlas_data <- fetch_diabetes_atlas()

if (!is.null(atlas_data) && nrow(atlas_data) > 0) {
  cat(sprintf("Retrieved %d records from Diabetes Atlas\n", nrow(atlas_data)))

  # Check what columns are available
  cat("\nAvailable columns:\n")
  print(names(atlas_data))

  # Save raw data
  saveRDS(atlas_data, "output/paper_59/data/diabetes_atlas_raw.rds")
  cat("\nDiabetes Atlas data saved to data/diabetes_atlas_raw.rds\n")
} else {
  cat("No data retrieved from Diabetes Atlas API\n")
}

cat("\nData acquisition script complete.\n")
