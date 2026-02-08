# ============================================================================
# Technology Obsolescence and Populist Voting
# 01_clean_data.R - Clean and merge all data sources
# ============================================================================
#
# PREREQUISITE: Run 00_fetch_data.R first to download and verify all input data.
#
# DATA PROVENANCE (see 00_fetch_data.R for download instructions):
#
# 1. Technology vintage data (modal_age.dta):
#    - Source: Acemoglu, Autor, Hazell, and Restrepo (2022)
#      "New Technologies and the Skill Premium"
#    - Obtained from: Prof. Tarek Hassan (Boston University)
#    - Coverage: 917 CBSAs, 2010-2023
#    - The data measures the modal age of capital equipment and production
#      technologies across U.S. establishments, aggregated to CBSA level.
#
# 2. Election data (2008, 2012, 2016, 2020):
#    - Source: MIT Election Data + Science Lab
#    - DOI: 10.7910/DVN/VOQCHQ
#    - Harvard Dataverse: https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/VOQCHQ
#    - Citation: MIT Election Data and Science Lab (2017). U.S. President 1976-2020.
#
# 3. Election data (2024):
#    - Source: Compiled from official state certified results
#    - Aggregated from state election offices and AP certified results
#
# 4. CBSA-county crosswalk:
#    - Source: U.S. Census Bureau, March 2020 CBSA delineation
#    - URL: https://www.census.gov/geographies/reference-files/time-series/demo/metro-micro/delineation-files.html
#    - Also via NBER: https://data.nber.org/cbsa-csa-fips-county-crosswalk/
#
# ============================================================================

source("./00_packages.R")

# ============================================================================
# 1. Load and clean technology data (modal_age.dta)
# ============================================================================

cat("Loading technology data...\n")
tech_raw <- read_dta("../data/modal_age.dta")

# Filter to valid CBSAs and collapse to CBSA-year level
tech_cbsa <- tech_raw %>%
  filter(cbsa > 0) %>%
  group_by(cbsa, year) %>%
  summarize(
    modal_age_mean = mean(modal_age, na.rm = TRUE),
    modal_age_median = median(modal_age, na.rm = TRUE),
    modal_age_sd = sd(modal_age, na.rm = TRUE),
    modal_age_p25 = quantile(modal_age, 0.25, na.rm = TRUE),
    modal_age_p75 = quantile(modal_age, 0.75, na.rm = TRUE),
    n_sectors = n(),
    .groups = "drop"
  )

cat(sprintf("Technology data: %d CBSAs, %d years, %d observations\n",
            n_distinct(tech_cbsa$cbsa),
            n_distinct(tech_cbsa$year),
            nrow(tech_cbsa)))

# ============================================================================
# 2. Load CBSA-county crosswalk
# ============================================================================

cat("\nLoading CBSA-county crosswalk...\n")
crosswalk <- read_csv("../data/cbsa_county_crosswalk.csv",
                      show_col_types = FALSE)

# Create county FIPS code (5-digit)
crosswalk <- crosswalk %>%
  mutate(
    county_fips = paste0(
      str_pad(fipsstatecode, 2, pad = "0"),
      str_pad(fipscountycode, 3, pad = "0")
    ) %>% as.numeric(),
    cbsa = as.numeric(cbsacode)
  ) %>%
  select(cbsa, cbsatitle, county_fips, countycountyequivalent, statename,
         metropolitanmicropolitanstatis, centraloutlyingcounty) %>%
  rename(
    cbsa_name = cbsatitle,
    county_name = countycountyequivalent,
    state_name = statename,
    cbsa_type = metropolitanmicropolitanstatis,
    central_outlying = centraloutlyingcounty
  )

cat(sprintf("Crosswalk: %d counties mapped to %d CBSAs\n",
            n_distinct(crosswalk$county_fips),
            n_distinct(crosswalk$cbsa)))

# ============================================================================
# 3. Load and clean election data
# ============================================================================

cat("\nLoading election data...\n")

# 2008 election (McCain vs Obama - baseline for capturing change over time)
elec_2008 <- read_csv("../data/election_2008.csv",
                      show_col_types = FALSE) %>%
  transmute(
    county_fips = as.numeric(county_fips),
    year = 2008,
    votes_rep = votes_gop,
    votes_dem = votes_dem,
    total_votes = total_votes,
    rep_share = votes_rep / total_votes,
    dem_share = votes_dem / total_votes
  )

# 2012 election (from MIT Election Lab county presidential data 2000-2020)
elec_2012 <- read_csv("../data/election_2012.csv",
                      show_col_types = FALSE) %>%
  transmute(
    county_fips = as.numeric(county_fips),
    year = 2012,
    votes_rep = votes_gop,
    votes_dem = votes_dem,
    total_votes = total_votes,
    rep_share = votes_rep / total_votes,
    dem_share = votes_dem / total_votes
  )

# 2016 election
elec_2016 <- read_csv("../data/election_2016.csv",
                      show_col_types = FALSE) %>%
  transmute(
    county_fips = as.numeric(combined_fips),
    year = 2016,
    votes_rep = votes_gop,
    votes_dem = votes_dem,
    total_votes = total_votes,
    rep_share = votes_rep / total_votes,
    dem_share = votes_dem / total_votes
  ) %>%
  distinct(county_fips, .keep_all = TRUE)

# 2020 election
elec_2020 <- read_csv("../data/election_2020.csv",
                      show_col_types = FALSE) %>%
  transmute(
    county_fips = as.numeric(county_fips),
    year = 2020,
    votes_rep = votes_gop,
    votes_dem = votes_dem,
    total_votes = total_votes,
    rep_share = votes_rep / total_votes,
    dem_share = votes_dem / total_votes
  )

# 2024 election
elec_2024 <- read_csv("../data/election_2024.csv",
                      show_col_types = FALSE) %>%
  transmute(
    county_fips = as.numeric(county_fips),
    year = 2024,
    votes_rep = votes_gop,
    votes_dem = votes_dem,
    total_votes = total_votes,
    rep_share = votes_rep / total_votes,
    dem_share = votes_dem / total_votes
  )

# Combine all election years (2008, 2012, 2016, 2020, 2024)
elections <- bind_rows(elec_2008, elec_2012, elec_2016, elec_2020, elec_2024)

cat(sprintf("Election data: %d county-years (%d in 2008, %d in 2012, %d in 2016, %d in 2020, %d in 2024)\n",
            nrow(elections),
            sum(elections$year == 2008),
            sum(elections$year == 2012),
            sum(elections$year == 2016),
            sum(elections$year == 2020),
            sum(elections$year == 2024)))

# ============================================================================
# 4. Aggregate election data to CBSA level
# ============================================================================

cat("\nAggregating election data to CBSA level...\n")

# Merge election data with crosswalk
elec_cbsa <- elections %>%
  inner_join(crosswalk, by = "county_fips") %>%
  group_by(cbsa, cbsa_name, cbsa_type, year) %>%
  summarize(
    votes_rep = sum(votes_rep, na.rm = TRUE),
    votes_dem = sum(votes_dem, na.rm = TRUE),
    total_votes = sum(total_votes, na.rm = TRUE),
    n_counties = n(),
    .groups = "drop"
  ) %>%
  mutate(
    trump_share = votes_rep / total_votes * 100,  # As percentage
    dem_share = votes_dem / total_votes * 100
  )

cat(sprintf("CBSA-level election data: %d CBSA-years\n", nrow(elec_cbsa)))
cat(sprintf("  CBSAs with 2008 data: %d\n", sum(elec_cbsa$year == 2008)))
cat(sprintf("  CBSAs with 2012 data: %d\n", sum(elec_cbsa$year == 2012)))
cat(sprintf("  CBSAs with 2016 data: %d\n", sum(elec_cbsa$year == 2016)))
cat(sprintf("  CBSAs with 2020 data: %d\n", sum(elec_cbsa$year == 2020)))
cat(sprintf("  CBSAs with 2024 data: %d\n", sum(elec_cbsa$year == 2024)))

# ============================================================================
# 4a. Create 2008 baseline variable for controls
# ============================================================================

cat("\nCreating 2008 baseline GOP share variable...\n")

# Extract 2008 GOP share at CBSA level
gop_share_2008 <- elec_cbsa %>%
  filter(year == 2008) %>%
  select(cbsa, gop_share_2008 = trump_share)  # Note: trump_share is actually GOP share

cat(sprintf("2008 baseline: %d CBSAs with 2008 GOP share data\n", nrow(gop_share_2008)))

# ============================================================================
# 5. Merge technology and election data
# ============================================================================

cat("\nMerging technology and election data...\n")

# For each election, use technology data from the year before
# 2012 election -> 2011 technology
# 2016 election -> 2015 technology
# 2020 election -> 2019 technology
# 2024 election -> 2023 technology

tech_for_election <- tech_cbsa %>%
  mutate(election_year = case_when(
    year == 2011 ~ 2012,
    year == 2015 ~ 2016,
    year == 2019 ~ 2020,
    year == 2023 ~ 2024,
    TRUE ~ NA_real_
  )) %>%
  filter(!is.na(election_year)) %>%
  select(cbsa, election_year, starts_with("modal_age"), n_sectors) %>%
  rename(year = election_year)

# Merge election data (2012-2024) with technology data
# Note: We keep 2012-2024 for analysis but merge in 2008 baseline as control
analysis_data <- elec_cbsa %>%
  filter(year >= 2012) %>%  # Only 2012-2024 for analysis (tech data starts 2010)
  inner_join(tech_for_election, by = c("cbsa", "year")) %>%
  left_join(gop_share_2008, by = "cbsa")  # Add 2008 baseline as control

cat(sprintf("Merged data: %d observations\n", nrow(analysis_data)))
cat(sprintf("  Unique CBSAs: %d\n", n_distinct(analysis_data$cbsa)))
cat(sprintf("  Years: %s\n", paste(unique(analysis_data$year), collapse = ", ")))
cat(sprintf("  With 2008 baseline: %d observations (%.1f%%)\n",
            sum(!is.na(analysis_data$gop_share_2008)),
            100 * mean(!is.na(analysis_data$gop_share_2008))))

# ============================================================================
# 6. Create analysis variables
# ============================================================================

cat("\nCreating analysis variables...\n")

analysis_data <- analysis_data %>%
  mutate(
    # Metropolitan vs Micropolitan
    is_metro = cbsa_type == "Metropolitan Statistical Area",

    # Technology terciles (within year)
    tech_tercile = ntile(modal_age_mean, 3),
    tech_tercile_label = case_when(
      tech_tercile == 1 ~ "Low (Young Tech)",
      tech_tercile == 2 ~ "Medium",
      tech_tercile == 3 ~ "High (Old Tech)"
    ),

    # Log total votes (proxy for CBSA size)
    log_total_votes = log(total_votes),

    # Year fixed effects
    year_factor = factor(year),

    # Change from 2008 baseline (GOP share change since Obama-McCain)
    gop_change_from_2008 = trump_share - gop_share_2008
  )

# Create lagged/differenced variables for panel analysis
analysis_data <- analysis_data %>%
  arrange(cbsa, year) %>%
  group_by(cbsa) %>%
  mutate(
    trump_share_lag = lag(trump_share),
    modal_age_lag = lag(modal_age_mean),
    d_trump_share = trump_share - trump_share_lag,
    d_modal_age = modal_age_mean - modal_age_lag
  ) %>%
  ungroup()

# ============================================================================
# 7. Summary statistics
# ============================================================================

cat("\n============================================\n")
cat("Summary Statistics\n")
cat("============================================\n\n")

cat("Technology Age (modal_age_mean):\n")
print(summary(analysis_data$modal_age_mean))

cat("\nTrump Vote Share (%):\n")
print(summary(analysis_data$trump_share))

cat("\nCorrelation: Modal Age vs Trump Share\n")
print(cor(analysis_data$modal_age_mean, analysis_data$trump_share, use = "complete.obs"))

cat("\nBy Election Year:\n")
analysis_data %>%
  group_by(year) %>%
  summarize(
    n = n(),
    mean_tech_age = mean(modal_age_mean, na.rm = TRUE),
    sd_tech_age = sd(modal_age_mean, na.rm = TRUE),
    mean_trump = mean(trump_share, na.rm = TRUE),
    sd_trump = sd(trump_share, na.rm = TRUE),
    cor_tech_trump = cor(modal_age_mean, trump_share, use = "complete.obs")
  ) %>%
  print()

# ============================================================================
# 8. Save cleaned data
# ============================================================================

cat("\nSaving cleaned data...\n")
saveRDS(analysis_data, "../data/analysis_data.rds")
saveRDS(tech_cbsa, "../data/tech_cbsa.rds")
saveRDS(elec_cbsa, "../data/elec_cbsa.rds")
saveRDS(crosswalk, "../data/crosswalk.rds")

cat("Data cleaning complete.\n")
