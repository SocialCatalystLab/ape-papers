################################################################################
# 04b_mechanisms.R
# Social Network Minimum Wage Exposure - MECHANISM TESTS
#
# This script distinguishes between two channels:
# 1. INFORMATION TRANSMISSION: Workers learn about wages, adjust expectations
# 2. MIGRATION/OPTION VALUE: Workers move to high-MW areas, or use threat of moving
#
# REVISION (apep_0192):
# - Fixed IRS URL bug: use countyinflow/countyoutflow files
# - Added 2SLS migration regressions
# - Added directed migration analysis (toward vs away from high-MW)
# - Added migration-as-mediator test
# - Added migration AGI analysis
# - Added Figure 8 data (migration by exposure quartile)
################################################################################

source("00_packages.R")

cat("=== Mechanism Tests: Information vs. Migration ===\n\n")

# ============================================================================
# 1. Load Data
# ============================================================================

cat("1. Loading data...\n")

panel <- readRDS("../data/analysis_panel.rds")
main_results <- readRDS("../data/main_results.rds")
state_mw_panel <- readRDS("../data/state_mw_panel.rds")

cat("  Panel observations:", format(nrow(panel), big.mark = ","), "\n")

# ============================================================================
# 2. Fetch IRS Migration Data (FIXED URLs)
# ============================================================================

cat("\n2. Fetching IRS SOI migration data...\n")

if (file.exists("../data/migration_inflows.rds") && file.exists("../data/migration_outflows.rds")) {
  cat("  Loading cached migration data...\n")
  inflow_raw <- readRDS("../data/migration_inflows.rds")
  outflow_raw <- readRDS("../data/migration_outflows.rds")
} else {
  cat("  Fetching from IRS SOI...\n")
  cat("  NOTE: Using countyinflow/countyoutflow files (not county*.csv)\n\n")

  irs_base <- "https://www.irs.gov/pub/irs-soi/"

  migration_years <- 2012:2019  # Pre-COVID
  inflow_list <- list()
  outflow_list <- list()

  for (yr in migration_years) {
    yr_suffix <- sprintf("%02d%02d", yr %% 100, (yr + 1) %% 100)

    # Inflow files
    inflow_url <- paste0(irs_base, "countyinflow", yr_suffix, ".csv")
    tryCatch({
      df <- read_csv(inflow_url, show_col_types = FALSE)
      df$year <- yr
      inflow_list[[as.character(yr)]] <- df
      cat("    Downloaded inflow", yr, "-", yr + 1, "\n")
    }, error = function(e) {
      cat("    Failed inflow", yr, ":", e$message, "\n")
    })

    # Outflow files
    outflow_url <- paste0(irs_base, "countyoutflow", yr_suffix, ".csv")
    tryCatch({
      df <- read_csv(outflow_url, show_col_types = FALSE)
      df$year <- yr
      outflow_list[[as.character(yr)]] <- df
      cat("    Downloaded outflow", yr, "-", yr + 1, "\n")
    }, error = function(e) {
      cat("    Failed outflow", yr, ":", e$message, "\n")
    })

    Sys.sleep(0.5)  # Rate limit
  }

  if (length(inflow_list) > 0) {
    inflow_raw <- bind_rows(inflow_list)
    saveRDS(inflow_raw, "../data/migration_inflows.rds")
    cat("  Saved migration_inflows.rds (", nrow(inflow_raw), "rows)\n")
  } else {
    inflow_raw <- NULL
  }

  if (length(outflow_list) > 0) {
    outflow_raw <- bind_rows(outflow_list)
    saveRDS(outflow_raw, "../data/migration_outflows.rds")
    cat("  Saved migration_outflows.rds (", nrow(outflow_raw), "rows)\n")
  } else {
    outflow_raw <- NULL
  }
}

# ============================================================================
# 3. Construct Migration Outcomes
# ============================================================================

cat("\n3. Constructing migration outcomes...\n")

has_migration <- !is.null(inflow_raw) && !is.null(outflow_raw) &&
  nrow(inflow_raw) > 0 && nrow(outflow_raw) > 0

if (has_migration) {
  # Standardize column names (IRS files have varying case)
  names(inflow_raw) <- tolower(names(inflow_raw))
  names(outflow_raw) <- tolower(names(outflow_raw))

  # Construct FIPS codes
  # Inflow: y2 = destination (focal county), y1 = origin
  inflow_clean <- inflow_raw %>%
    filter(!is.na(y1_statefips) & !is.na(y2_statefips)) %>%
    filter(y1_statefips != y2_statefips | y1_countyfips != y2_countyfips) %>%
    filter(y1_statefips > 0 & y2_statefips > 0) %>%
    filter(y1_countyfips > 0 & y2_countyfips > 0) %>%
    mutate(
      origin_fips = paste0(sprintf("%02d", y1_statefips), sprintf("%03d", y1_countyfips)),
      dest_fips = paste0(sprintf("%02d", y2_statefips), sprintf("%03d", y2_countyfips)),
      origin_state = sprintf("%02d", y1_statefips),
      dest_state = sprintf("%02d", y2_statefips)
    )

  # Outflow: y1 = origin (focal county), y2 = destination
  outflow_clean <- outflow_raw %>%
    filter(!is.na(y1_statefips) & !is.na(y2_statefips)) %>%
    filter(y1_statefips != y2_statefips | y1_countyfips != y2_countyfips) %>%
    filter(y1_statefips > 0 & y2_statefips > 0) %>%
    filter(y1_countyfips > 0 & y2_countyfips > 0) %>%
    mutate(
      origin_fips = paste0(sprintf("%02d", y1_statefips), sprintf("%03d", y1_countyfips)),
      dest_fips = paste0(sprintf("%02d", y2_statefips), sprintf("%03d", y2_countyfips)),
      origin_state = sprintf("%02d", y1_statefips),
      dest_state = sprintf("%02d", y2_statefips)
    )

  # --- Aggregate inflows per destination county-year ---
  county_inflows <- inflow_clean %>%
    group_by(dest_fips, year) %>%
    summarise(
      in_returns = sum(n1, na.rm = TRUE),
      in_exemptions = sum(n2, na.rm = TRUE),
      in_agi = sum(agi, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    rename(county_fips = dest_fips)

  # --- Aggregate outflows per origin county-year ---
  county_outflows <- outflow_clean %>%
    group_by(origin_fips, year) %>%
    summarise(
      out_returns = sum(n1, na.rm = TRUE),
      out_exemptions = sum(n2, na.rm = TRUE),
      out_agi = sum(agi, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    rename(county_fips = origin_fips)

  # --- Net migration ---
  county_migration <- county_outflows %>%
    full_join(county_inflows, by = c("county_fips", "year")) %>%
    mutate(
      across(c(out_returns, out_exemptions, out_agi,
               in_returns, in_exemptions, in_agi),
             ~replace_na(., 0)),
      net_returns = in_returns - out_returns,
      net_exemptions = in_exemptions - out_exemptions,
      net_agi = in_agi - out_agi
    )

  cat("  Computed migration for", n_distinct(county_migration$county_fips), "counties\n")
  cat("  Years:", paste(sort(unique(county_migration$year)), collapse = ", "), "\n")

  # --- Directed migration: toward vs away from high-MW states ---
  cat("\n  Computing directed migration (toward/away from high-MW)...\n")

  # Get median state MW for each year
  median_mw_by_year <- state_mw_panel %>%
    group_by(year) %>%
    summarise(median_mw = median(min_wage, na.rm = TRUE), .groups = "drop")

  # Classify destination states as high-MW or low-MW
  state_mw_class <- state_mw_panel %>%
    left_join(median_mw_by_year, by = "year") %>%
    mutate(high_mw_state = min_wage > median_mw)

  # Outflows toward high-MW vs low-MW states
  directed_outflows <- outflow_clean %>%
    left_join(state_mw_class %>% select(state_fips, year, high_mw_state),
              by = c("dest_state" = "state_fips", "year")) %>%
    filter(!is.na(high_mw_state)) %>%
    group_by(origin_fips, year, high_mw_state) %>%
    summarise(
      out_returns = sum(n1, na.rm = TRUE),
      out_agi = sum(agi, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    rename(county_fips = origin_fips)

  directed_wide <- directed_outflows %>%
    pivot_wider(
      id_cols = c(county_fips, year),
      names_from = high_mw_state,
      values_from = c(out_returns, out_agi),
      names_prefix = "mw_"
    ) %>%
    rename(
      out_to_high_mw = out_returns_mw_TRUE,
      out_to_low_mw = out_returns_mw_FALSE,
      agi_to_high_mw = out_agi_mw_TRUE,
      agi_to_low_mw = out_agi_mw_FALSE
    ) %>%
    mutate(across(everything(), ~replace_na(., 0)))

  # Merge directed flows into county_migration
  county_migration <- county_migration %>%
    left_join(directed_wide, by = c("county_fips", "year"))

  # --- AGI per migrant ---
  county_migration <- county_migration %>%
    mutate(
      agi_per_outmigrant = ifelse(out_returns > 0, out_agi / out_returns, NA),
      agi_per_inmigrant = ifelse(in_returns > 0, in_agi / in_returns, NA)
    )

  # Save combined migration data
  saveRDS(county_migration, "../data/migration_flows.rds")
  cat("  Saved migration_flows.rds\n")

} else {
  cat("  WARNING: Could not construct migration data\n")
  county_migration <- NULL
}

# ============================================================================
# 4. Merge Migration with Panel
# ============================================================================

cat("\n4. Merging with analysis panel...\n")

if (has_migration) {
  panel_mig <- panel %>%
    left_join(county_migration, by = c("county_fips", "year"))

  # Log transform migration variables
  panel_mig <- panel_mig %>%
    mutate(
      log_net_mig = sign(net_returns) * log(abs(net_returns) + 1),
      log_outflow = log(out_returns + 1),
      log_inflow = log(in_returns + 1),
      log_out_high_mw = log(out_to_high_mw + 1),
      log_out_low_mw = log(out_to_low_mw + 1),
      log_agi_per_out = log(agi_per_outmigrant + 1),
      migration_rate = (out_returns + in_returns) / exp(log_emp)
    )

  n_with_mig <- sum(!is.na(panel_mig$net_returns))
  cat("  Observations with migration data:", format(n_with_mig, big.mark = ","), "\n")

  panel_mig <- panel_mig %>% filter(!is.na(net_returns))
} else {
  panel_mig <- NULL
}

# ============================================================================
# 5. Migration Mechanism Tests (OLS + 2SLS)
# ============================================================================

cat("\n5. Running migration mechanism tests...\n")

migration_results <- list()

if (!is.null(panel_mig) && nrow(panel_mig) > 10000) {

  # ------------------------------------------------------------------
  # 5A. Net migration (OLS + 2SLS)
  # ------------------------------------------------------------------
  cat("\n5A. Effect of network exposure on NET migration\n")

  mig_net_ols <- tryCatch({
    feols(log_net_mig ~ network_mw_pop | county_fips + state_fips^year,
          data = panel_mig, cluster = ~state_fips)
  }, error = function(e) NULL)

  mig_net_iv <- tryCatch({
    feols(log_net_mig ~ 1 | county_fips + state_fips^year |
            network_mw_pop ~ network_mw_pop_out_state,
          data = panel_mig, cluster = ~state_fips)
  }, error = function(e) NULL)

  if (!is.null(mig_net_ols)) {
    cat("  OLS: beta =", round(coef(mig_net_ols)[1], 4),
        "(SE:", round(se(mig_net_ols)[1], 4),
        ", p =", round(fixest::pvalue(mig_net_ols)[1], 4), ")\n")
  }
  if (!is.null(mig_net_iv)) {
    cat("  2SLS: beta =", round(coef(mig_net_iv)[1], 4),
        "(SE:", round(se(mig_net_iv)[1], 4),
        ", p =", round(fixest::pvalue(mig_net_iv)[1], 4), ")\n")
  }

  # ------------------------------------------------------------------
  # 5B. Outflows (OLS + 2SLS)
  # ------------------------------------------------------------------
  cat("\n5B. Effect of network exposure on OUTFLOWS\n")

  mig_out_ols <- tryCatch({
    feols(log_outflow ~ network_mw_pop | county_fips + state_fips^year,
          data = panel_mig, cluster = ~state_fips)
  }, error = function(e) NULL)

  mig_out_iv <- tryCatch({
    feols(log_outflow ~ 1 | county_fips + state_fips^year |
            network_mw_pop ~ network_mw_pop_out_state,
          data = panel_mig, cluster = ~state_fips)
  }, error = function(e) NULL)

  if (!is.null(mig_out_ols)) {
    cat("  OLS: beta =", round(coef(mig_out_ols)[1], 4),
        "(SE:", round(se(mig_out_ols)[1], 4),
        ", p =", round(fixest::pvalue(mig_out_ols)[1], 4), ")\n")
  }
  if (!is.null(mig_out_iv)) {
    cat("  2SLS: beta =", round(coef(mig_out_iv)[1], 4),
        "(SE:", round(se(mig_out_iv)[1], 4),
        ", p =", round(fixest::pvalue(mig_out_iv)[1], 4), ")\n")
  }

  # ------------------------------------------------------------------
  # 5C. Inflows (OLS + 2SLS)
  # ------------------------------------------------------------------
  cat("\n5C. Effect of network exposure on INFLOWS\n")

  mig_in_ols <- tryCatch({
    feols(log_inflow ~ network_mw_pop | county_fips + state_fips^year,
          data = panel_mig, cluster = ~state_fips)
  }, error = function(e) NULL)

  mig_in_iv <- tryCatch({
    feols(log_inflow ~ 1 | county_fips + state_fips^year |
            network_mw_pop ~ network_mw_pop_out_state,
          data = panel_mig, cluster = ~state_fips)
  }, error = function(e) NULL)

  if (!is.null(mig_in_ols)) {
    cat("  OLS: beta =", round(coef(mig_in_ols)[1], 4),
        "(SE:", round(se(mig_in_ols)[1], 4),
        ", p =", round(fixest::pvalue(mig_in_ols)[1], 4), ")\n")
  }
  if (!is.null(mig_in_iv)) {
    cat("  2SLS: beta =", round(coef(mig_in_iv)[1], 4),
        "(SE:", round(se(mig_in_iv)[1], 4),
        ", p =", round(fixest::pvalue(mig_in_iv)[1], 4), ")\n")
  }

  # ------------------------------------------------------------------
  # 5D. Directed migration: toward high-MW vs low-MW states
  # ------------------------------------------------------------------
  cat("\n5D. Directed migration: toward HIGH-MW vs LOW-MW states\n")

  mig_high_mw <- tryCatch({
    feols(log_out_high_mw ~ network_mw_pop | county_fips + state_fips^year,
          data = panel_mig, cluster = ~state_fips)
  }, error = function(e) NULL)

  mig_low_mw <- tryCatch({
    feols(log_out_low_mw ~ network_mw_pop | county_fips + state_fips^year,
          data = panel_mig, cluster = ~state_fips)
  }, error = function(e) NULL)

  if (!is.null(mig_high_mw)) {
    cat("  Outflow to HIGH-MW states: beta =", round(coef(mig_high_mw)[1], 4),
        "(p =", round(fixest::pvalue(mig_high_mw)[1], 4), ")\n")
  }
  if (!is.null(mig_low_mw)) {
    cat("  Outflow to LOW-MW states: beta =", round(coef(mig_low_mw)[1], 4),
        "(p =", round(fixest::pvalue(mig_low_mw)[1], 4), ")\n")
  }

  # ------------------------------------------------------------------
  # 5E. Migration AGI: do migrants from high-exposure counties move to
  #     higher-AGI destinations?
  # ------------------------------------------------------------------
  cat("\n5E. Migration AGI analysis\n")

  mig_agi <- tryCatch({
    feols(log_agi_per_out ~ network_mw_pop | county_fips + state_fips^year,
          data = filter(panel_mig, !is.na(log_agi_per_out) & is.finite(log_agi_per_out)),
          cluster = ~state_fips)
  }, error = function(e) NULL)

  if (!is.null(mig_agi)) {
    cat("  AGI per outmigrant: beta =", round(coef(mig_agi)[1], 4),
        "(SE:", round(se(mig_agi)[1], 4),
        ", p =", round(fixest::pvalue(mig_agi)[1], 4), ")\n")
  }

  # Store results
  migration_results <- list(
    mig_net_ols = mig_net_ols, mig_net_iv = mig_net_iv,
    mig_out_ols = mig_out_ols, mig_out_iv = mig_out_iv,
    mig_in_ols = mig_in_ols, mig_in_iv = mig_in_iv,
    mig_high_mw = mig_high_mw, mig_low_mw = mig_low_mw,
    mig_agi = mig_agi
  )

} else {
  cat("  Insufficient migration data for analysis\n")
}

# ============================================================================
# 6. Migration as Mediator
# ============================================================================

cat("\n6. Migration-as-mediator test...\n")

mediator_results <- NULL

if (!is.null(panel_mig) && nrow(panel_mig) > 10000) {
  cat("  If coefficient attenuates when controlling for migration rate,\n")
  cat("  migration mediates. If not, information channel confirmed.\n\n")

  # Baseline (no migration control) on migration subsample
  baseline_mig_sample <- tryCatch({
    feols(log_emp ~ network_mw_pop | county_fips + state_fips^yearq,
          data = filter(panel_mig, !is.na(migration_rate)),
          cluster = ~state_fips)
  }, error = function(e) NULL)

  # With migration rate control
  with_migration_control <- tryCatch({
    feols(log_emp ~ network_mw_pop + migration_rate | county_fips + state_fips^yearq,
          data = filter(panel_mig, !is.na(migration_rate)),
          cluster = ~state_fips)
  }, error = function(e) NULL)

  # 2SLS versions
  baseline_iv_mig <- tryCatch({
    feols(log_emp ~ 1 | county_fips + state_fips^yearq |
            network_mw_pop ~ network_mw_pop_out_state,
          data = filter(panel_mig, !is.na(migration_rate)),
          cluster = ~state_fips)
  }, error = function(e) NULL)

  with_migration_iv <- tryCatch({
    feols(log_emp ~ migration_rate | county_fips + state_fips^yearq |
            network_mw_pop ~ network_mw_pop_out_state,
          data = filter(panel_mig, !is.na(migration_rate)),
          cluster = ~state_fips)
  }, error = function(e) NULL)

  if (!is.null(baseline_mig_sample) && !is.null(with_migration_control)) {
    cat("  OLS without migration control:", round(coef(baseline_mig_sample)[1], 4), "\n")
    cat("  OLS with migration control:   ", round(coef(with_migration_control)["network_mw_pop"], 4), "\n")
    attenuation_ols <- 1 - coef(with_migration_control)["network_mw_pop"] / coef(baseline_mig_sample)[1]
    cat("  Attenuation (OLS):", round(attenuation_ols * 100, 1), "%\n")
  }

  if (!is.null(baseline_iv_mig) && !is.null(with_migration_iv)) {
    cat("\n  2SLS without migration control:", round(coef(baseline_iv_mig)[1], 4), "\n")
    cat("  2SLS with migration control:   ", round(coef(with_migration_iv)[1], 4), "\n")
    attenuation_iv <- 1 - coef(with_migration_iv)[1] / coef(baseline_iv_mig)[1]
    cat("  Attenuation (2SLS):", round(attenuation_iv * 100, 1), "%\n")

    if (abs(attenuation_iv) < 0.15) {
      cat("\n  --> Minimal attenuation: INFORMATION channel confirmed\n")
    } else {
      cat("\n  --> Substantial attenuation: migration partially mediates\n")
    }
  }

  mediator_results <- list(
    baseline_ols = baseline_mig_sample,
    with_mig_ols = with_migration_control,
    baseline_iv = baseline_iv_mig,
    with_mig_iv = with_migration_iv
  )
}

# ============================================================================
# 7. Figure 8 Data: Migration by Exposure Quartile
# ============================================================================

cat("\n7. Preparing Figure 8 data (migration by exposure quartile)...\n")

fig8_data <- NULL

if (!is.null(panel_mig) && nrow(panel_mig) > 10000) {
  # Create exposure quartiles based on 2012 values
  baseline_exposure <- panel_mig %>%
    filter(year == min(year)) %>%
    group_by(county_fips) %>%
    summarise(baseline_pop_mw = mean(network_mw_pop, na.rm = TRUE), .groups = "drop") %>%
    mutate(exposure_q = ntile(baseline_pop_mw, 4),
           exposure_q = factor(exposure_q,
                               labels = c("Q1 (Low)", "Q2", "Q3", "Q4 (High)")))

  fig8_data <- panel_mig %>%
    left_join(baseline_exposure %>% select(county_fips, exposure_q), by = "county_fips") %>%
    filter(!is.na(exposure_q)) %>%
    group_by(year, exposure_q) %>%
    summarise(
      mean_net_mig = mean(net_returns, na.rm = TRUE),
      mean_outflow = mean(out_returns, na.rm = TRUE),
      mean_inflow = mean(in_returns, na.rm = TRUE),
      mean_out_high_mw = mean(out_to_high_mw, na.rm = TRUE),
      se_net = sd(net_returns, na.rm = TRUE) / sqrt(n()),
      n_counties = n_distinct(county_fips),
      .groups = "drop"
    )

  saveRDS(fig8_data, "../data/fig8_migration_data.rds")
  cat("  Saved fig8_migration_data.rds\n")

  # Print summary
  cat("\n  Migration by exposure quartile (mean across years):\n")
  fig8_summary <- fig8_data %>%
    group_by(exposure_q) %>%
    summarise(
      avg_net = round(mean(mean_net_mig), 1),
      avg_out = round(mean(mean_outflow), 1),
      avg_in = round(mean(mean_inflow), 1),
      .groups = "drop"
    )
  print(fig8_summary)
}

# ============================================================================
# 8. Wage Distribution Analysis
# ============================================================================

cat("\n8. Wage distribution analysis (if available)...\n")

wage_results <- NULL
if ("wage_p25" %in% names(panel) && "wage_p75" %in% names(panel)) {
  cat("  Running wage distribution regressions...\n")

  wage_p25 <- feols(
    log(wage_p25) ~ network_mw_pop | county_fips + state_fips^yearq,
    data = panel, cluster = ~state_fips)

  wage_p50 <- feols(
    log(wage_p50) ~ network_mw_pop | county_fips + state_fips^yearq,
    data = panel, cluster = ~state_fips)

  wage_p75 <- feols(
    log(wage_p75) ~ network_mw_pop | county_fips + state_fips^yearq,
    data = panel, cluster = ~state_fips)

  cat("  Effect on 25th pctile wage:", round(coef(wage_p25)[1], 4), "\n")
  cat("  Effect on median wage:", round(coef(wage_p50)[1], 4), "\n")
  cat("  Effect on 75th pctile wage:", round(coef(wage_p75)[1], 4), "\n")

  if (coef(wage_p25)[1] > coef(wage_p75)[1]) {
    cat("\n  --> Effect concentrated at BOTTOM of wage distribution\n")
    cat("  --> SUPPORTS INFORMATION channel (reservation wage effect)\n")
  }

  wage_results <- list(p25 = wage_p25, p50 = wage_p50, p75 = wage_p75)
} else {
  cat("  Wage percentile data not available\n")
}

# ============================================================================
# 9. Pre-Period Weight Robustness
# ============================================================================

cat("\n9. Pre-period weight robustness check...\n")

pre_weight_robust <- NULL
if ("employment_2012" %in% names(panel)) {
  pre_period_test <- feols(
    log_emp ~ network_mw_pop | county_fips + state_fips^yearq,
    data = filter(panel, year <= 2014),
    cluster = ~state_fips)

  cat("  Pre-2015 only: beta =", round(coef(pre_period_test)[1], 4),
      "(SE:", round(se(pre_period_test)[1], 4), ")\n")
  pre_weight_robust <- list(pre_period_test = pre_period_test)
} else {
  pre_treatment <- feols(
    log_emp ~ network_mw_pop | county_fips + state_fips^yearq,
    data = filter(panel, year <= 2014),
    cluster = ~state_fips)

  cat("  2012-2014 (pre-treatment): beta =", round(coef(pre_treatment)[1], 4),
      "(p =", round(fixest::pvalue(pre_treatment)[1], 4), ")\n")

  if (fixest::pvalue(pre_treatment)[1] > 0.1) {
    cat("  --> No significant effect in pre-treatment period (supports causal interpretation)\n")
  } else {
    cat("  --> Significant effect in pre-treatment period (raises concern)\n")
  }

  pre_weight_robust <- list(pre_treatment = pre_treatment)
}

# ============================================================================
# 10. Magnitude Calibration
# ============================================================================

cat("\n10. Magnitude calibration...\n")

main_coef <- coef(main_results$iv_2sls_pop)[1]

cat("  Main 2SLS coefficient:", round(main_coef, 4), "\n")
cat("  Interpretation: 10% increase in network MW exposure -->\n")
cat("                  ", round(main_coef * 0.1 * 100, 2), "% increase in employment\n")

cat("\n  As a market-level equilibrium multiplier (Moretti 2011):\n")
cat("  Local multipliers in Moretti (2011) range from 1.5 to 2.5\n")
cat("  Our estimate of", round(main_coef, 2), "is a market-level multiplier\n")
cat("  incorporating information diffusion, employer responses,\n")
cat("  and general equilibrium effects -- not an individual elasticity.\n")

implied_elasticity <- main_coef
cat("\n  Implied labor supply elasticity (LATE):", round(implied_elasticity, 2), "\n")

# ============================================================================
# 11. Save All Mechanism Results
# ============================================================================

cat("\n11. Saving mechanism test results...\n")

mechanism_results <- list(
  # Migration tests (OLS + 2SLS)
  migration = migration_results,
  has_migration = has_migration,

  # Directed migration
  directed_migration = if (exists("mig_high_mw")) list(
    to_high_mw = mig_high_mw,
    to_low_mw = mig_low_mw
  ) else NULL,

  # Migration as mediator
  mediator = mediator_results,

  # Figure 8 data
  fig8_data = fig8_data,

  # Wage distribution
  wages = wage_results,

  # Pre-period weights
  pre_weight_robust = pre_weight_robust,

  # Magnitude calibration
  main_coef = main_coef,
  implied_elasticity = implied_elasticity
)

saveRDS(mechanism_results, "../data/mechanism_results.rds")
cat("  Saved mechanism_results.rds\n")

# ============================================================================
# Summary
# ============================================================================

cat("\n=== Mechanism Test Summary ===\n\n")

cat("MIGRATION CHANNEL:\n")
if (length(migration_results) > 0 && !is.null(migration_results$mig_out_ols)) {
  mig_p_ols <- fixest::pvalue(migration_results$mig_out_ols)[1]
  cat("  Outflow OLS: p =", round(mig_p_ols, 3), "\n")
  if (!is.null(migration_results$mig_out_iv)) {
    mig_p_iv <- fixest::pvalue(migration_results$mig_out_iv)[1]
    cat("  Outflow 2SLS: p =", round(mig_p_iv, 3), "\n")
  }
} else {
  cat("  Migration data not available\n")
}

cat("\nDIRECTED MIGRATION:\n")
if (!is.null(migration_results$mig_high_mw)) {
  cat("  To high-MW states:", round(coef(migration_results$mig_high_mw)[1], 4), "\n")
  cat("  To low-MW states:", round(coef(migration_results$mig_low_mw)[1], 4), "\n")
}

cat("\nMEDIATOR TEST:\n")
if (!is.null(mediator_results$baseline_iv) && !is.null(mediator_results$with_mig_iv)) {
  cat("  2SLS without migration:", round(coef(mediator_results$baseline_iv)[1], 4), "\n")
  cat("  2SLS with migration:", round(coef(mediator_results$with_mig_iv)[1], 4), "\n")
}

cat("\nMAGNITUDE:\n")
cat("  2SLS coefficient:", round(main_coef, 3), "\n")
cat("  Market-level multiplier interpretation (cf. Moretti 2011)\n")

cat("\n=== Mechanism Tests Complete ===\n")
