# ============================================================================
# Paper 78: Dyslexia Screening Mandates and Fourth-Grade Reading Proficiency
# (Revision of apep_0069)
# 01_fetch_data.R - Data acquisition with corrected treatment timing
# ============================================================================
#
# KEY REVISIONS FROM apep_0069:
# 1. Treatment timing alignment: Laws effective July 1 cannot affect that year's
#    NAEP (administered Jan-Mar). first_naep_exposure maps to NEXT NAEP cycle.
# 2. Percentile outcomes: Fetch 10th and 25th percentile scores for distributional
#    analysis targeting struggling readers (bottom 5-10%).
# 3. Bundled state indicator: Flag MS, FL, TN, AL that bundled dyslexia screening
#    with comprehensive Science of Reading reforms.
# ============================================================================

source("00_packages.R")

# ============================================================================
# 1. NAEP Grade 4 Reading Scores (Primary Outcome - MEAN)
# ============================================================================

cat("\n=== Fetching NAEP Grade 4 Reading Data ===\n")

# All 50 states
states <- c("AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA",
            "HI","ID","IL","IN","IA","KS","KY","LA","ME","MD",
            "MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ",
            "NM","NY","NC","ND","OH","OK","OR","PA","RI","SC",
            "SD","TN","TX","UT","VT","VA","WA","WV","WI","WY")

# NAEP assessment years (Grade 4 reading)
years <- c(2003, 2005, 2007, 2009, 2011, 2013, 2015, 2017, 2019, 2022)

# Build NAEP API request
naep_url <- "https://www.nationsreportcard.gov/Dataservice/GetAdhocData.aspx"

# Function to fetch NAEP data (mean scores)
fetch_naep <- function(jurisdictions, years, grade = 4, subject = "reading") {
  params <- list(
    type = "data",
    subject = subject,
    grade = grade,
    subscale = "RRPCM",  # Reading composite
    variable = "TOTAL",
    jurisdiction = paste(jurisdictions, collapse = ","),
    stattype = "MN:MN",
    Year = paste(years, collapse = ",")
  )

  response <- GET(naep_url, query = params)

  if (status_code(response) != 200) {
    stop("NAEP API request failed with status ", status_code(response))
  }

  data <- fromJSON(content(response, "text"))

  if (is.null(data$result)) {
    stop("No results returned from NAEP API")
  }

  return(data$result)
}

# Fetch main outcome data (state means)
naep_raw <- fetch_naep(states, years)

# Clean and structure
naep_data <- naep_raw %>%
  as_tibble() %>%
  select(
    year,
    state_abbr = jurisdiction,
    state_name = jurisLabel,
    reading_score = value
  ) %>%
  mutate(
    year = as.integer(year),
    reading_score = as.numeric(reading_score)
  ) %>%
  arrange(state_abbr, year)

cat("Fetched", nrow(naep_data), "state-year observations for NAEP Grade 4 Reading (mean)\n")
cat("Years:", min(naep_data$year), "-", max(naep_data$year), "\n")
cat("States:", n_distinct(naep_data$state_abbr), "\n")

# ============================================================================
# 2. NAEP Percentile Data (Distributional Outcomes)
# ============================================================================

cat("\n=== Fetching NAEP Percentile Data ===\n")

# Function to fetch NAEP percentile data
fetch_naep_percentile <- function(jurisdictions, years, percentile, grade = 4) {
  # NAEP API uses different stattype codes for percentiles
  # PC:X where X is percentile (10, 25, 50, 75, 90)
  params <- list(
    type = "data",
    subject = "reading",
    grade = grade,
    subscale = "RRPCM",
    variable = "TOTAL",
    jurisdiction = paste(jurisdictions, collapse = ","),
    stattype = paste0("PC:", percentile),
    Year = paste(years, collapse = ",")
  )

  response <- GET(naep_url, query = params)

  if (status_code(response) != 200) {
    warning("NAEP percentile API request failed with status ", status_code(response))
    return(NULL)
  }

  data <- fromJSON(content(response, "text"))

  if (is.null(data$result)) {
    warning("No percentile results returned from NAEP API")
    return(NULL)
  }

  return(data$result)
}

# Function to fetch achievement level percentages
fetch_naep_achievement <- function(jurisdictions, years, grade = 4) {
  # Fetch percentage at each achievement level
  params <- list(
    type = "data",
    subject = "reading",
    grade = grade,
    subscale = "RRPCM",
    variable = "TOTAL",
    jurisdiction = paste(jurisdictions, collapse = ","),
    stattype = "AP:1,AP:2,AP:3,AP:4",  # Below Basic, Basic, Proficient, Advanced
    Year = paste(years, collapse = ",")
  )

  response <- GET(naep_url, query = params)

  if (status_code(response) != 200) {
    warning("NAEP achievement API request failed with status ", status_code(response))
    return(NULL)
  }

  data <- fromJSON(content(response, "text"))

  if (is.null(data$result)) {
    warning("No achievement results returned from NAEP API")
    return(NULL)
  }

  return(data$result)
}

# Try to fetch percentile data
cat("Attempting to fetch 10th percentile data...\n")
naep_p10_raw <- tryCatch(
  fetch_naep_percentile(states, years, 10),
  error = function(e) {
    cat("Note: Could not fetch percentile data. Error:", conditionMessage(e), "\n")
    NULL
  }
)

if (!is.null(naep_p10_raw)) {
  naep_p10 <- naep_p10_raw %>%
    as_tibble() %>%
    select(year, state_abbr = jurisdiction, reading_p10 = value) %>%
    mutate(
      year = as.integer(year),
      reading_p10 = as.numeric(reading_p10)
    )
  cat("  Successfully fetched 10th percentile data\n")
} else {
  cat("  10th percentile data not available via API\n")
  naep_p10 <- NULL
}

cat("Attempting to fetch 25th percentile data...\n")
naep_p25_raw <- tryCatch(
  fetch_naep_percentile(states, years, 25),
  error = function(e) {
    cat("Note: Could not fetch percentile data. Error:", conditionMessage(e), "\n")
    NULL
  }
)

if (!is.null(naep_p25_raw)) {
  naep_p25 <- naep_p25_raw %>%
    as_tibble() %>%
    select(year, state_abbr = jurisdiction, reading_p25 = value) %>%
    mutate(
      year = as.integer(year),
      reading_p25 = as.numeric(reading_p25)
    )
  cat("  Successfully fetched 25th percentile data\n")
} else {
  cat("  25th percentile data not available via API\n")
  naep_p25 <- NULL
}

# Try achievement levels
cat("Attempting to fetch achievement level data...\n")
naep_ach_raw <- tryCatch(
  fetch_naep_achievement(states, years),
  error = function(e) {
    cat("Note: Could not fetch achievement data. Error:", conditionMessage(e), "\n")
    NULL
  }
)

if (!is.null(naep_ach_raw)) {
  naep_ach <- naep_ach_raw %>%
    as_tibble() %>%
    select(year, state_abbr = jurisdiction, achievement_level = stattype, pct = value) %>%
    mutate(
      year = as.integer(year),
      pct = as.numeric(pct),
      level = case_when(
        grepl("AP:1", achievement_level) ~ "below_basic",
        grepl("AP:2", achievement_level) ~ "basic",
        grepl("AP:3", achievement_level) ~ "proficient",
        grepl("AP:4", achievement_level) ~ "advanced"
      )
    ) %>%
    select(-achievement_level) %>%
    pivot_wider(names_from = level, values_from = pct, names_prefix = "pct_")
  cat("  Successfully fetched achievement level data\n")
} else {
  cat("  Achievement level data not available via API\n")
  naep_ach <- NULL
}

# ============================================================================
# 3. Dyslexia Screening Mandate Dates (Treatment Variable)
#    WITH CORRECTED TREATMENT TIMING
# ============================================================================

cat("\n=== Creating Dyslexia Screening Mandate Database ===\n")
cat("    (With corrected NAEP exposure timing)\n")

# Compiled from: Dyslegia.com, State of Dyslexia, Education Week
# CRITICAL FIX: effective_month added to determine first NAEP exposure
# NAEP is administered Jan-Mar; laws effective after March don't affect that year's NAEP

dyslexia_mandates <- tribble(
  ~state_abbr, ~mandate_year, ~effective_month, ~mandate_type, ~universal, ~intervention_req, ~teacher_training, ~funding,
  # Early adopters (pre-2015)
  "TX", 1995, 9, "screening", TRUE, TRUE, TRUE, TRUE,  # Texas was early, strengthened 2019
  "VA", 2010, 7, "screening", FALSE, FALSE, FALSE, FALSE,  # Initial law, strengthened 2023
  "OH", 2012, 7, "screening", FALSE, TRUE, FALSE, FALSE,
  "NJ", 2013, 9, "screening", TRUE, TRUE, FALSE, FALSE,
  "MS", 2013, 7, "comprehensive", TRUE, TRUE, TRUE, TRUE,  # Part of Literacy-Based Promotion Act
  # 2015 wave
  "AZ", 2015, 7, "screening", FALSE, TRUE, FALSE, FALSE,
  "AR", 2015, 7, "screening", TRUE, TRUE, TRUE, FALSE,
  "CT", 2015, 7, "screening", TRUE, TRUE, FALSE, FALSE,
  "ME", 2015, 7, "screening", TRUE, TRUE, FALSE, FALSE,
  "NV", 2015, 7, "screening", TRUE, TRUE, FALSE, FALSE,
  # 2016-2017 wave
  "NH", 2016, 7, "screening", TRUE, TRUE, FALSE, FALSE,
  "MO", 2016, 8, "screening", TRUE, FALSE, FALSE, FALSE,
  "LA", 2017, 7, "screening", FALSE, TRUE, FALSE, FALSE,
  # 2018-2019 wave
  "NE", 2018, 7, "screening", TRUE, TRUE, FALSE, FALSE,
  "SC", 2018, 7, "screening", TRUE, TRUE, TRUE, FALSE,
  "GA", 2019, 7, "screening", TRUE, TRUE, FALSE, FALSE,
  "MD", 2019, 7, "screening", TRUE, TRUE, FALSE, FALSE,
  "MT", 2019, 7, "screening", TRUE, TRUE, FALSE, FALSE,
  "TN", 2019, 7, "comprehensive", TRUE, TRUE, TRUE, TRUE,
  "UT", 2019, 7, "screening", TRUE, TRUE, FALSE, FALSE,
  # 2020-2022 wave
  "OK", 2020, 7, "screening", TRUE, TRUE, FALSE, FALSE,
  "FL", 2021, 7, "screening", TRUE, TRUE, TRUE, TRUE,
  "AL", 2022, 7, "screening", TRUE, TRUE, TRUE, TRUE,  # From Alabama Literacy Act
  "AK", 2022, 7, "screening", TRUE, TRUE, TRUE, FALSE,  # Alaska Reads Act
  "DE", 2022, 7, "screening", TRUE, TRUE, FALSE, FALSE,
  "ID", 2022, 7, "screening", TRUE, TRUE, FALSE, FALSE,
  "WY", 2022, 7, "screening", TRUE, TRUE, FALSE, FALSE,
  # 2023 wave (no post-treatment NAEP data in sample)
  "CA", 2023, 7, "screening", TRUE, TRUE, FALSE, FALSE  # Implementation 2025-26
)

# CRITICAL FIX: Calculate first NAEP exposure based on effective date vs NAEP timing
# NAEP is administered Jan-Mar, so:
# - Laws effective Jan-Mar of year Y can affect year Y's NAEP
# - Laws effective Apr-Dec of year Y cannot affect year Y's NAEP; first exposure = next NAEP

naep_years <- c(2003, 2005, 2007, 2009, 2011, 2013, 2015, 2017, 2019, 2022)

# Function to find first NAEP year after a given date
find_first_naep_exposure <- function(mandate_year, effective_month) {
  if (effective_month <= 3) {
    # Law effective before NAEP administration - can affect that year's NAEP IF it's a NAEP year
    if (mandate_year %in% naep_years) {
      return(mandate_year)
    }
  }
  # Otherwise, first exposure is next NAEP year after mandate_year
  next_naep <- naep_years[naep_years > mandate_year]
  if (length(next_naep) == 0) {
    return(NA_integer_)  # No NAEP data after this year
  }
  return(min(next_naep))
}

dyslexia_mandates <- dyslexia_mandates %>%
  rowwise() %>%
  mutate(
    first_naep_exposure = find_first_naep_exposure(mandate_year, effective_month)
  ) %>%
  ungroup()

# Create mandate strength index (0-4)
dyslexia_mandates <- dyslexia_mandates %>%
  mutate(
    mandate_strength = universal + intervention_req + teacher_training + funding,
    mandate_strength_cat = case_when(
      mandate_strength >= 3 ~ "Strong",
      mandate_strength == 2 ~ "Moderate",
      mandate_strength <= 1 ~ "Weak"
    )
  )

# Flag bundled reform states (dyslexia law + comprehensive SoR reform)
# These states adopted dyslexia screening as part of broader literacy reform packages
bundled_reform_states <- c("MS", "FL", "TN", "AL")

dyslexia_mandates <- dyslexia_mandates %>%
  mutate(
    bundled_reform = state_abbr %in% bundled_reform_states
  )

# Handle California (2023 adoption - no post-treatment NAEP in sample)
# For estimation purposes, CA is treated as never-treated in 2003-2022 window

# Handle Virginia's two laws (use earlier for treatment timing)
dyslexia_mandates <- dyslexia_mandates %>%
  group_by(state_abbr) %>%
  filter(mandate_year == min(mandate_year)) %>%
  ungroup()

cat("Coded", nrow(dyslexia_mandates), "states with dyslexia screening mandates\n")
cat("\nMandate strength distribution:\n")
print(table(dyslexia_mandates$mandate_strength_cat))
cat("\nBundled reform states:", paste(bundled_reform_states, collapse = ", "), "\n")

# Print treatment timing verification table
cat("\n=== Treatment Timing Verification ===\n")
cat("(mandate_year = law effective; first_naep_exposure = first NAEP that could show effects)\n\n")
dyslexia_mandates %>%
  select(state_abbr, mandate_year, effective_month, first_naep_exposure, bundled_reform) %>%
  arrange(mandate_year) %>%
  print(n = 30)

# ============================================================================
# 4. Concurrent Policy Controls
# ============================================================================

cat("\n=== Creating Concurrent Policy Database ===\n")

# Science of Reading Laws (SoR)
# Source: Education Week tracker, ExcelInEd
sor_laws <- tribble(
  ~state_abbr, ~sor_year,
  "MS", 2013,  # Literacy-Based Promotion Act
  "FL", 2013,  # Just Read, Florida! strengthened
  "NC", 2015,  # Read to Achieve
  "TN", 2016,  # Reading 360
  "AR", 2017,
  "LA", 2017,
  "OH", 2018,
  "AL", 2019,
  "SC", 2019,
  "IN", 2020,
  "CO", 2020,
  "TX", 2021,  # HB 3 Reading Academies
  "GA", 2023,
  "WV", 2023
)

# Third-grade retention policies
# Source: ECS, ExcelInEd
retention_laws <- tribble(
  ~state_abbr, ~retention_year,
  "FL", 2002,
  "OH", 2012,
  "AZ", 2013,
  "MS", 2013,
  "NC", 2014,
  "GA", 2014,
  "IN", 2015,
  "SC", 2018,
  "TN", 2021,
  "AL", 2023
)

# Common Core adoption (most adopted 2010-2012)
common_core <- tribble(
  ~state_abbr, ~cc_adopted, ~cc_implemented, ~cc_withdrawn,
  "AL", 2010, 2012, NA,
  "AK", NA, NA, NA,  # Never adopted
  "AZ", 2010, 2012, NA,
  "AR", 2010, 2012, NA,
  "CA", 2010, 2013, NA,
  "CO", 2010, 2012, NA,
  "CT", 2010, 2013, NA,
  "DE", 2010, 2012, NA,
  "FL", 2010, 2014, NA,
  "GA", 2010, 2012, NA,
  "HI", 2010, 2012, NA,
  "ID", 2010, 2013, NA,
  "IL", 2010, 2013, NA,
  "IN", 2010, 2014, 2014,  # Withdrew
  "IA", 2010, 2012, NA,
  "KS", 2010, 2013, NA,
  "KY", 2010, 2011, NA,
  "LA", 2010, 2013, NA,
  "ME", 2010, 2013, NA,
  "MD", 2010, 2013, NA,
  "MA", 2010, 2013, NA,
  "MI", 2010, 2013, NA,
  "MN", 2010, 2013, NA,  # Partial adoption
  "MS", 2010, 2013, NA,
  "MO", 2010, 2014, NA,
  "MT", 2010, 2013, NA,
  "NE", NA, NA, NA,  # Never adopted
  "NV", 2010, 2013, NA,
  "NH", 2010, 2013, NA,
  "NJ", 2010, 2013, NA,
  "NM", 2010, 2013, NA,
  "NY", 2010, 2013, NA,
  "NC", 2010, 2012, NA,
  "ND", 2010, 2013, NA,
  "OH", 2010, 2013, NA,
  "OK", 2010, 2014, 2014,  # Withdrew
  "OR", 2010, 2013, NA,
  "PA", 2010, 2013, NA,
  "RI", 2010, 2013, NA,
  "SC", 2010, 2015, 2015,  # Withdrew
  "SD", 2010, 2014, NA,
  "TN", 2010, 2013, NA,
  "TX", NA, NA, NA,  # Never adopted
  "UT", 2010, 2013, NA,
  "VT", 2010, 2013, NA,
  "VA", NA, NA, NA,  # Never adopted
  "WA", 2010, 2013, NA,
  "WV", 2010, 2013, NA,
  "WI", 2010, 2013, NA,
  "WY", 2010, 2013, NA
)

cat("Created concurrent policy controls\n")

# ============================================================================
# 5. Merge All Data
# ============================================================================

cat("\n=== Merging Datasets ===\n")

# Start with NAEP data
analysis_data <- naep_data

# Merge percentile data if available
if (!is.null(naep_p10)) {
  analysis_data <- analysis_data %>%
    left_join(naep_p10, by = c("year", "state_abbr"))
  cat("  Merged 10th percentile data\n")
}

if (!is.null(naep_p25)) {
  analysis_data <- analysis_data %>%
    left_join(naep_p25, by = c("year", "state_abbr"))
  cat("  Merged 25th percentile data\n")
}

if (!is.null(naep_ach)) {
  analysis_data <- analysis_data %>%
    left_join(naep_ach, by = c("year", "state_abbr"))
  cat("  Merged achievement level data\n")
}

# Add dyslexia mandate treatment (USING CORRECTED TIMING)
analysis_data <- analysis_data %>%
  left_join(
    dyslexia_mandates %>%
      select(state_abbr, mandate_year, first_naep_exposure, mandate_strength,
             mandate_strength_cat, bundled_reform),
    by = "state_abbr"
  ) %>%
  mutate(
    # CRITICAL: Use first_naep_exposure for treatment timing, NOT mandate_year
    # This correctly accounts for NAEP administration timing
    first_treat = if_else(is.na(first_naep_exposure), 0L, as.integer(first_naep_exposure)),

    # Post-treatment indicator (based on corrected timing)
    post = if_else(!is.na(first_naep_exposure) & year >= first_naep_exposure, 1L, 0L),

    # Ever treated indicator (will eventually be treated)
    ever_treated = if_else(!is.na(mandate_year), 1L, 0L),

    # Bundled reform indicator
    bundled = if_else(!is.na(bundled_reform) & bundled_reform, 1L, 0L),

    # Dyslexia-only indicator (has mandate but not bundled)
    dyslexia_only = if_else(ever_treated == 1 & bundled == 0, 1L, 0L)
  )

# Add SoR controls
analysis_data <- analysis_data %>%
  left_join(sor_laws, by = "state_abbr") %>%
  mutate(
    sor_post = if_else(!is.na(sor_year) & year >= sor_year, 1L, 0L)
  )

# Add retention controls
analysis_data <- analysis_data %>%
  left_join(retention_laws, by = "state_abbr") %>%
  mutate(
    retention_post = if_else(!is.na(retention_year) & year >= retention_year, 1L, 0L)
  )

# Add Common Core controls
analysis_data <- analysis_data %>%
  left_join(common_core, by = "state_abbr") %>%
  mutate(
    cc_post = if_else(!is.na(cc_implemented) & year >= cc_implemented, 1L, 0L),
    cc_withdrew = if_else(!is.na(cc_withdrawn) & year >= cc_withdrawn, 1L, 0L)
  )

# Create state FIPS codes for mapping
state_fips <- tibble(
  state_abbr = c("AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA",
                 "HI","ID","IL","IN","IA","KS","KY","LA","ME","MD",
                 "MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ",
                 "NM","NY","NC","ND","OH","OK","OR","PA","RI","SC",
                 "SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"),
  fips = c("01","02","04","05","06","08","09","10","12","13",
           "15","16","17","18","19","20","21","22","23","24",
           "25","26","27","28","29","30","31","32","33","34",
           "35","36","37","38","39","40","41","42","44","45",
           "46","47","48","49","50","51","53","54","55","56")
)

analysis_data <- analysis_data %>%
  left_join(state_fips, by = "state_abbr")

cat("\nFinal analysis dataset:\n")
cat("  Observations:", nrow(analysis_data), "\n")
cat("  States:", n_distinct(analysis_data$state_abbr), "\n")
cat("  Years:", paste(range(analysis_data$year), collapse = "-"), "\n")
cat("  Ever-treated states:", sum(analysis_data$ever_treated == 1) / n_distinct(analysis_data$year), "\n")
cat("  Never-treated states:", sum(analysis_data$ever_treated == 0) / n_distinct(analysis_data$year), "\n")
cat("  Bundled reform states:", sum(analysis_data$bundled == 1) / n_distinct(analysis_data$year), "\n")
cat("  Dyslexia-only states:", sum(analysis_data$dyslexia_only == 1) / n_distinct(analysis_data$year), "\n")

# Verify treatment timing correction
cat("\n=== Treatment Timing Summary (Corrected) ===\n")
cat("first_treat == 0 means never-treated or no post-treatment NAEP in sample\n\n")
analysis_data %>%
  filter(year == 2003) %>%
  select(state_abbr, mandate_year, first_treat, bundled, dyslexia_only) %>%
  filter(first_treat > 0) %>%
  arrange(first_treat) %>%
  print(n = 30)

# ============================================================================
# 6. Save Data
# ============================================================================

# Save analysis dataset
saveRDS(analysis_data, file.path(data_dir, "analysis_data.rds"))
write_csv(analysis_data, file.path(data_dir, "analysis_data.csv"))

# Save raw NAEP data
saveRDS(naep_data, file.path(data_dir, "naep_raw.rds"))

# Save percentile data if available
if (!is.null(naep_p10)) saveRDS(naep_p10, file.path(data_dir, "naep_p10.rds"))
if (!is.null(naep_p25)) saveRDS(naep_p25, file.path(data_dir, "naep_p25.rds"))
if (!is.null(naep_ach)) saveRDS(naep_ach, file.path(data_dir, "naep_achievement.rds"))

# Save policy databases
saveRDS(dyslexia_mandates, file.path(data_dir, "dyslexia_mandates.rds"))
saveRDS(sor_laws, file.path(data_dir, "sor_laws.rds"))
saveRDS(retention_laws, file.path(data_dir, "retention_laws.rds"))
saveRDS(common_core, file.path(data_dir, "common_core.rds"))

cat("\n=== Data saved to", data_dir, "===\n")
cat("Files created:\n")
cat("  - analysis_data.rds (main analysis file with corrected timing)\n")
cat("  - analysis_data.csv\n")
cat("  - naep_raw.rds\n")
cat("  - naep_p10.rds (if available)\n")
cat("  - naep_p25.rds (if available)\n")
cat("  - dyslexia_mandates.rds\n")
cat("  - sor_laws.rds\n")
cat("  - retention_laws.rds\n")
cat("  - common_core.rds\n")
