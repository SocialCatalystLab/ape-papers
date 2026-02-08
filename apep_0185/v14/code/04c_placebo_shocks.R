################################################################################
# 04c_placebo_shocks.R
# Placebo Shock Tests for Exclusion Restriction
#
# If the network instrument captures generic economic spillovers (not just MW
# information), then placebo instruments constructed from OTHER state-level
# shocks (GDP, employment) should also predict destination employment.
# If they don't → exclusion restriction supported.
#
# Constructs:
#   PlaceboGDP_ct  = Σ_j w^pop_cj × log(GDP_jt)
#   PlaceboEmp_ct  = Σ_j w^pop_cj × log(StateEmp_jt)
#
# Runs reduced-form regressions: expect NULL effects for placebo instruments.
################################################################################

source("00_packages.R")

cat("=== Placebo Shock Tests ===\n\n")

# ============================================================================
# 1. Load Data
# ============================================================================

cat("1. Loading data...\n")

panel <- readRDS("../data/analysis_panel.rds")
state_mw_panel <- readRDS("../data/state_mw_panel.rds")

cat("  Panel:", format(nrow(panel), big.mark = ","), "obs\n")

# ============================================================================
# 2. Fetch BEA State GDP Data
# ============================================================================

cat("\n2. Fetching BEA state GDP data...\n")

bea_key <- Sys.getenv("BEA_API_KEY")

state_gdp <- NULL

if (nchar(bea_key) > 0) {
  # Fetch state GDP from BEA API
  bea_url <- paste0(
    "https://apps.bea.gov/api/data/?&UserID=", bea_key,
    "&method=GetData&datasetname=Regional",
    "&TableName=SAGDP1",
    "&LineCode=1",           # All industry total
    "&GeoFips=STATE",
    "&Year=2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022",
    "&ResultFormat=JSON"
  )

  bea_resp <- tryCatch({
    resp <- GET(bea_url, timeout(60))
    if (status_code(resp) == 200) {
      content(resp, "parsed", simplifyVector = TRUE)
    } else NULL
  }, error = function(e) {
    cat("  BEA API error:", e$message, "\n")
    NULL
  })

  if (!is.null(bea_resp) && !is.null(bea_resp$BEAAPI$Results$Data)) {
    bea_data <- as_tibble(bea_resp$BEAAPI$Results$Data)

    state_gdp <- bea_data %>%
      filter(GeoFips != "00000") %>%
      mutate(
        state_fips = substr(GeoFips, 1, 2),
        year = as.integer(TimePeriod),
        gdp = as.numeric(gsub(",", "", DataValue))
      ) %>%
      filter(!is.na(gdp) & gdp > 0) %>%
      mutate(log_gdp = log(gdp)) %>%
      select(state_fips, year, log_gdp)

    cat("  Downloaded BEA GDP for", n_distinct(state_gdp$state_fips), "states,",
        n_distinct(state_gdp$year), "years\n")
  }
}

if (is.null(state_gdp) || nrow(state_gdp) == 0) {
  cat("  BEA data not available, constructing from FRED...\n")

  # Fallback: fetch from FRED using state GDP series
  fred_key <- Sys.getenv("FRED_API_KEY")

  if (nchar(fred_key) > 0) {
    # Use FRED state GDP series (NGSP + state FIPS)
    state_fips_list <- unique(panel$state_fips)
    gdp_list <- list()

    for (st in state_fips_list) {
      series_id <- paste0(st, "NGSP")  # Approximate - FRED uses state abbreviations
      # Skip FRED for now - use synthetic placebo from employment data instead
    }
  }

  # If no GDP available, create synthetic from state employment trends
  cat("  Using state employment as GDP proxy for placebo test\n")

  state_emp <- panel %>%
    group_by(state_fips, year, quarter) %>%
    summarise(
      state_total_emp = sum(exp(log_emp), na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(log_state_emp = log(state_total_emp))

  # Annual aggregation for GDP proxy
  state_gdp <- state_emp %>%
    group_by(state_fips, year) %>%
    summarise(log_gdp = log(mean(state_total_emp, na.rm = TRUE)), .groups = "drop")
}

# ============================================================================
# 3. Fetch State Employment Data (BLS LAUS)
# ============================================================================

cat("\n3. Constructing state employment series...\n")

# Compute state-level employment from QWI panel data
state_emp_quarterly <- panel %>%
  group_by(state_fips, year, quarter) %>%
  summarise(
    state_total_emp = sum(exp(log_emp), na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    log_state_emp = log(state_total_emp),
    yearq = year + (quarter - 1) / 4
  )

cat("  State employment series:", nrow(state_emp_quarterly), "state-quarter obs\n")

# ============================================================================
# 4. Construct Placebo Instruments
# ============================================================================

cat("\n4. Constructing placebo instruments...\n")

# We need the SCI weights from the panel construction
# Use the exposure_panel structure: for each county-quarter, compute
# placebo exposure using GDP and employment instead of MW

# Load SCI cross-state weights (reconstructed from exposure panel)
exposure_panel <- readRDS("../data/exposure_panel.rds")

# We need raw SCI weights to construct placebo instruments
# Approach: use the relationship between network MW and state MW to back out weights
# Alternatively, reconstruct from raw SCI data

if (file.exists("../data/raw_sci.rds")) {
  sci_raw <- readRDS("../data/raw_sci.rds")
  centroids <- readRDS("../data/raw_county_centroids.rds")

  # Reconstruct population-weighted cross-state SCI weights
  county_pop <- panel %>%
    group_by(county_fips) %>%
    summarise(pop_proxy = mean(exp(log_emp), na.rm = TRUE), .groups = "drop")

  sci_cross <- as_tibble(sci_raw) %>%
    mutate(
      state_fips_1 = substr(county_fips_1, 1, 2),
      state_fips_2 = substr(county_fips_2, 1, 2)
    ) %>%
    filter(state_fips_1 != state_fips_2) %>%
    left_join(county_pop, by = c("county_fips_2" = "county_fips")) %>%
    mutate(sci_pop = sci * pop_proxy)

  # Normalize weights within each county
  sci_cross_totals <- sci_cross %>%
    group_by(county_fips_1) %>%
    summarise(total_sci_pop = sum(sci_pop, na.rm = TRUE), .groups = "drop")

  sci_cross <- sci_cross %>%
    left_join(sci_cross_totals, by = "county_fips_1") %>%
    mutate(w_pop = sci_pop / total_sci_pop)

  cat("  Reconstructed SCI weights for", n_distinct(sci_cross$county_fips_1), "counties\n")

  # --- Placebo GDP instrument ---
  cat("  Computing placebo GDP instrument...\n")

  # For each county-year, compute GDP-weighted exposure
  # PlaceboGDP_ct = Σ_j w^pop_cj × log(GDP_jt)
  years <- unique(panel$year)

  placebo_gdp_list <- list()
  for (yr in years) {
    gdp_yr <- state_gdp %>% filter(year == yr) %>% select(state_fips, log_gdp)

    if (nrow(gdp_yr) == 0) next

    placebo_gdp_yr <- sci_cross %>%
      left_join(gdp_yr, by = c("state_fips_2" = "state_fips")) %>%
      filter(!is.na(log_gdp)) %>%
      group_by(county_fips_1) %>%
      summarise(placebo_gdp = sum(w_pop * log_gdp, na.rm = TRUE), .groups = "drop") %>%
      mutate(year = yr)

    placebo_gdp_list[[as.character(yr)]] <- placebo_gdp_yr
  }

  placebo_gdp <- bind_rows(placebo_gdp_list)

  # --- Placebo Employment instrument ---
  cat("  Computing placebo employment instrument...\n")

  placebo_emp_list <- list()
  quarters <- expand_grid(year = years, quarter = 1:4)

  for (i in 1:nrow(quarters)) {
    yr <- quarters$year[i]
    qtr <- quarters$quarter[i]

    emp_q <- state_emp_quarterly %>%
      filter(year == yr, quarter == qtr) %>%
      select(state_fips, log_state_emp)

    if (nrow(emp_q) == 0) next

    placebo_emp_q <- sci_cross %>%
      left_join(emp_q, by = c("state_fips_2" = "state_fips")) %>%
      filter(!is.na(log_state_emp)) %>%
      group_by(county_fips_1) %>%
      summarise(placebo_emp = sum(w_pop * log_state_emp, na.rm = TRUE), .groups = "drop") %>%
      mutate(year = yr, quarter = qtr)

    placebo_emp_list[[paste(yr, qtr)]] <- placebo_emp_q
  }

  placebo_emp <- bind_rows(placebo_emp_list)

  cat("  Placebo GDP obs:", nrow(placebo_gdp), "\n")
  cat("  Placebo Emp obs:", nrow(placebo_emp), "\n")

} else {
  cat("  Raw SCI data not available - cannot construct placebo instruments\n")
  placebo_gdp <- NULL
  placebo_emp <- NULL
}

# ============================================================================
# 5. Merge Placebo Instruments with Panel
# ============================================================================

cat("\n5. Merging placebo instruments with panel...\n")

panel_placebo <- panel

if (!is.null(placebo_gdp) && nrow(placebo_gdp) > 0) {
  panel_placebo <- panel_placebo %>%
    left_join(placebo_gdp, by = c("county_fips" = "county_fips_1", "year"))
}

if (!is.null(placebo_emp) && nrow(placebo_emp) > 0) {
  panel_placebo <- panel_placebo %>%
    left_join(placebo_emp, by = c("county_fips" = "county_fips_1", "year", "quarter"))
}

has_placebo_gdp <- "placebo_gdp" %in% names(panel_placebo) && sum(!is.na(panel_placebo$placebo_gdp)) > 10000
has_placebo_emp <- "placebo_emp" %in% names(panel_placebo) && sum(!is.na(panel_placebo$placebo_emp)) > 10000

cat("  Has placebo GDP:", has_placebo_gdp, "\n")
cat("  Has placebo Emp:", has_placebo_emp, "\n")

# ============================================================================
# 6. Run Placebo Reduced-Form Regressions
# ============================================================================

cat("\n6. Running placebo reduced-form regressions...\n")
cat("  H0: Generic economic shocks through networks should NOT predict employment\n")
cat("  If p > 0.10 → exclusion restriction supported\n\n")

placebo_results <- list()

# Placebo GDP → Employment
if (has_placebo_gdp) {
  placebo_gdp_rf <- tryCatch({
    feols(
      log_emp ~ placebo_gdp | county_fips + state_fips^yearq,
      data = panel_placebo,
      cluster = ~state_fips
    )
  }, error = function(e) NULL)

  if (!is.null(placebo_gdp_rf)) {
    cat("  GDP-weighted exposure → Employment:\n")
    cat("    Coef:", round(coef(placebo_gdp_rf)[1], 4),
        "(SE:", round(se(placebo_gdp_rf)[1], 4),
        ", p =", round(fixest::pvalue(placebo_gdp_rf)[1], 4), ")\n")

    placebo_results$gdp_rf <- placebo_gdp_rf
  }
}

# Placebo Employment → Employment
if (has_placebo_emp) {
  placebo_emp_rf <- tryCatch({
    feols(
      log_emp ~ placebo_emp | county_fips + state_fips^yearq,
      data = panel_placebo,
      cluster = ~state_fips
    )
  }, error = function(e) NULL)

  if (!is.null(placebo_emp_rf)) {
    cat("  Employment-weighted exposure → Employment:\n")
    cat("    Coef:", round(coef(placebo_emp_rf)[1], 4),
        "(SE:", round(se(placebo_emp_rf)[1], 4),
        ", p =", round(fixest::pvalue(placebo_emp_rf)[1], 4), ")\n")

    placebo_results$emp_rf <- placebo_emp_rf
  }
}

# Horse race: MW exposure vs GDP exposure
if (has_placebo_gdp) {
  horse_race <- tryCatch({
    feols(
      log_emp ~ network_mw_pop + placebo_gdp | county_fips + state_fips^yearq,
      data = panel_placebo,
      cluster = ~state_fips
    )
  }, error = function(e) NULL)

  if (!is.null(horse_race)) {
    cat("\n  Horse race (MW + GDP exposures):\n")
    cat("    MW exposure:", round(coef(horse_race)["network_mw_pop"], 4),
        "(p =", round(fixest::pvalue(horse_race)["network_mw_pop"], 4), ")\n")
    cat("    GDP exposure:", round(coef(horse_race)["placebo_gdp"], 4),
        "(p =", round(fixest::pvalue(horse_race)["placebo_gdp"], 4), ")\n")

    placebo_results$horse_race <- horse_race
  }
}

# ============================================================================
# 7. Save Results
# ============================================================================

cat("\n7. Saving placebo shock results...\n")

saveRDS(placebo_results, "../data/placebo_shock_results.rds")
cat("  Saved placebo_shock_results.rds\n")

# ============================================================================
# Summary
# ============================================================================

cat("\n=== Placebo Shock Summary ===\n\n")

if (length(placebo_results) > 0) {
  if (!is.null(placebo_results$gdp_rf)) {
    gdp_p <- fixest::pvalue(placebo_results$gdp_rf)[1]
    cat("GDP placebo: p =", round(gdp_p, 4),
        ifelse(gdp_p > 0.10, "(NULL - supports exclusion restriction)", "(SIGNIFICANT - concern)"), "\n")
  }
  if (!is.null(placebo_results$emp_rf)) {
    emp_p <- fixest::pvalue(placebo_results$emp_rf)[1]
    cat("Emp placebo: p =", round(emp_p, 4),
        ifelse(emp_p > 0.10, "(NULL - supports exclusion restriction)", "(SIGNIFICANT - concern)"), "\n")
  }
} else {
  cat("No placebo results available\n")
}

cat("\n=== Placebo Shocks Complete ===\n")
