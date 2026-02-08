###############################################################################
# 04_robustness.R
# Paper 112: EERS and Residential Electricity Consumption
# Robustness checks, placebo tests, sensitivity analysis
###############################################################################

source("00_packages.R")

data_dir <- "../data/"
fig_dir  <- "../figures/"
tab_dir  <- "../tables/"

panel <- readRDS(paste0(data_dir, "panel_clean.rds"))
cs_result <- readRDS(paste0(data_dir, "cs_result_main.rds"))

###############################################################################
# PART 1: Alternative Control Group — Not-Yet-Treated
###############################################################################

cat("\n=== CS WITH NOT-YET-TREATED CONTROL ===\n")

cs_data <- panel %>%
  filter(!is.na(log_res_elec_pc)) %>%
  mutate(first_treat = ifelse(eers_year == 0, 0L, as.integer(eers_year)))

cs_nyt <- att_gt(
  yname = "log_res_elec_pc",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = cs_data,
  control_group = "notyettreated",
  est_method = "dr",
  base_period = "universal"
)

cs_nyt_att <- aggte(cs_nyt, type = "simple")
cs_nyt_dynamic <- aggte(cs_nyt, type = "dynamic", min_e = -10, max_e = 15)

cat("Not-yet-treated ATT:", round(cs_nyt_att$overall.att, 4),
    " (SE:", round(cs_nyt_att$overall.se, 4), ")\n")

saveRDS(cs_nyt, paste0(data_dir, "cs_nyt_result.rds"))
saveRDS(cs_nyt_att, paste0(data_dir, "cs_nyt_att.rds"))
saveRDS(cs_nyt_dynamic, paste0(data_dir, "cs_nyt_dynamic.rds"))

###############################################################################
# PART 2: Placebo Outcome — Industrial Consumption
###############################################################################

cat("\n=== PLACEBO: INDUSTRIAL ELECTRICITY ===\n")

# Industrial consumption should be less affected by residential EERS
# (though some EERS include commercial/industrial targets)
placebo_data <- panel %>%
  filter(!is.na(ind_elec_pc), ind_elec_pc > 0) %>%
  mutate(
    log_ind_elec_pc = log(ind_elec_pc),
    first_treat = ifelse(eers_year == 0, 0L, as.integer(eers_year))
  )

cs_placebo_ind <- tryCatch({
  att_gt(
    yname = "log_ind_elec_pc",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = placebo_data,
    control_group = "nevertreated",
    est_method = "dr",
    base_period = "universal"
  )
}, error = function(e) {
  cat("Industrial placebo CS failed:", e$message, "\n")
  NULL
})

if (!is.null(cs_placebo_ind)) {
  placebo_att <- aggte(cs_placebo_ind, type = "simple")
  cat("Industrial placebo ATT:", round(placebo_att$overall.att, 4),
      " (SE:", round(placebo_att$overall.se, 4), ")\n")
  saveRDS(cs_placebo_ind, paste0(data_dir, "cs_placebo_industrial.rds"))
  saveRDS(placebo_att, paste0(data_dir, "cs_placebo_ind_att.rds"))
}

###############################################################################
# PART 3: Placebo Treatment Timing
###############################################################################

cat("\n=== PLACEBO: FAKE TREATMENT 5 YEARS EARLY ===\n")

# Shift treatment 5 years earlier
placebo_timing_data <- cs_data %>%
  mutate(
    fake_treat = ifelse(first_treat > 0, first_treat - 5L, 0L),
    # Only use pre-treatment data (before actual treatment)
    year_cutoff = ifelse(first_treat > 0, first_treat - 1L, 2023L)
  ) %>%
  filter(year <= year_cutoff)

cs_placebo_timing <- tryCatch({
  att_gt(
    yname = "log_res_elec_pc",
    tname = "year",
    idname = "state_id",
    gname = "fake_treat",
    data = placebo_timing_data,
    control_group = "nevertreated",
    est_method = "dr",
    base_period = "universal"
  )
}, error = function(e) {
  cat("Timing placebo failed:", e$message, "\n")
  NULL
})

if (!is.null(cs_placebo_timing)) {
  placebo_timing_att <- aggte(cs_placebo_timing, type = "simple")
  cat("Timing placebo ATT:", round(placebo_timing_att$overall.att, 4),
      " (SE:", round(placebo_timing_att$overall.se, 4), ")\n")
  saveRDS(cs_placebo_timing, paste0(data_dir, "cs_placebo_timing.rds"))
  # FIXED: Save the ATT summary (was missing - selective reporting issue)
  saveRDS(placebo_timing_att, paste0(data_dir, "cs_placebo_timing_att.rds"))
}

###############################################################################
# PART 4: Alternative Outcome — Total Electricity
###############################################################################

cat("\n=== ALTERNATIVE OUTCOME: TOTAL ELECTRICITY ===\n")

total_data <- panel %>%
  filter(!is.na(log_total_elec_pc)) %>%
  mutate(first_treat = ifelse(eers_year == 0, 0L, as.integer(eers_year)))

cs_total <- att_gt(
  yname = "log_total_elec_pc",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = total_data,
  control_group = "nevertreated",
  est_method = "dr",
  base_period = "universal"
)

cs_total_att <- aggte(cs_total, type = "simple")
cs_total_dynamic <- aggte(cs_total, type = "dynamic", min_e = -10, max_e = 15)

cat("Total electricity ATT:", round(cs_total_att$overall.att, 4),
    " (SE:", round(cs_total_att$overall.se, 4), ")\n")

saveRDS(cs_total, paste0(data_dir, "cs_total_result.rds"))
saveRDS(cs_total_att, paste0(data_dir, "cs_total_att.rds"))
saveRDS(cs_total_dynamic, paste0(data_dir, "cs_total_dynamic.rds"))

###############################################################################
# PART 5: Alternative Outcome — Electricity Prices
###############################################################################

cat("\n=== ALTERNATIVE OUTCOME: RESIDENTIAL PRICES ===\n")

price_data <- panel %>%
  filter(!is.na(log_res_price)) %>%
  mutate(first_treat = ifelse(eers_year == 0, 0L, as.integer(eers_year)))

cs_price <- tryCatch({
  att_gt(
    yname = "log_res_price",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = price_data,
    control_group = "nevertreated",
    est_method = "dr",
    base_period = "universal"
  )
}, error = function(e) {
  cat("Price CS failed:", e$message, "\n")
  NULL
})

if (!is.null(cs_price)) {
  cs_price_att <- aggte(cs_price, type = "simple")
  cs_price_dynamic <- aggte(cs_price, type = "dynamic", min_e = -10, max_e = 15)
  cat("Price ATT:", round(cs_price_att$overall.att, 4),
      " (SE:", round(cs_price_att$overall.se, 4), ")\n")
  saveRDS(cs_price, paste0(data_dir, "cs_price_result.rds"))
  saveRDS(cs_price_att, paste0(data_dir, "cs_price_att.rds"))
  saveRDS(cs_price_dynamic, paste0(data_dir, "cs_price_dynamic.rds"))
}

###############################################################################
# PART 6: Heterogeneity by EERS Stringency
###############################################################################

cat("\n=== HETEROGENEITY: EARLY vs. LATE ADOPTERS ===\n")

# Split into early (pre-2008) and late (2008+) adopters
early_states <- cs_data %>%
  filter(first_treat > 0 & first_treat < 2008) %>%
  distinct(state_abbr) %>%
  pull()

late_states <- cs_data %>%
  filter(first_treat >= 2008) %>%
  distinct(state_abbr) %>%
  pull()

cat("Early adopters (<2008):", length(early_states), "states\n")
cat("Late adopters (>=2008):", length(late_states), "states\n")

# Early adopters CS
# FIXED: Only keep never-treated states (first_treat == 0) and early adopters
# Do NOT recode late adopters as never-treated (that contaminates the control group)
cs_early_data <- cs_data %>%
  filter(first_treat == 0 | state_abbr %in% early_states)

cs_early <- tryCatch({
  att_gt(
    yname = "log_res_elec_pc",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = cs_early_data,
    control_group = "nevertreated",
    est_method = "dr",
    base_period = "universal"
  )
}, error = function(e) {
  cat("Early adopters CS failed:", e$message, "\n")
  NULL
})

if (!is.null(cs_early)) {
  early_att <- aggte(cs_early, type = "simple")
  cat("Early adopters ATT:", round(early_att$overall.att, 4),
      " (SE:", round(early_att$overall.se, 4), ")\n")
  saveRDS(cs_early, paste0(data_dir, "cs_early_result.rds"))
  # FIXED: Save early adopter ATT summary (was missing - selective reporting issue)
  saveRDS(early_att, paste0(data_dir, "cs_early_att.rds"))
}

# Late adopters CS
# FIXED: Only keep never-treated states (first_treat == 0) and late adopters
# Do NOT recode early adopters as never-treated (that contaminates the control group)
cs_late_data <- cs_data %>%
  filter(first_treat == 0 | state_abbr %in% late_states)

cs_late <- tryCatch({
  att_gt(
    yname = "log_res_elec_pc",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = cs_late_data,
    control_group = "nevertreated",
    est_method = "dr",
    base_period = "universal"
  )
}, error = function(e) {
  cat("Late adopters CS failed:", e$message, "\n")
  NULL
})

if (!is.null(cs_late)) {
  late_att <- aggte(cs_late, type = "simple")
  cat("Late adopters ATT:", round(late_att$overall.att, 4),
      " (SE:", round(late_att$overall.se, 4), ")\n")
  saveRDS(cs_late, paste0(data_dir, "cs_late_result.rds"))
  # FIXED: Save late adopter ATT summary (was missing - selective reporting issue)
  saveRDS(late_att, paste0(data_dir, "cs_late_att.rds"))
}

###############################################################################
# PART 7: HonestDiD Sensitivity Analysis
###############################################################################

cat("\n=== HONESTDID SENSITIVITY ANALYSIS ===\n")

# Apply Rambachan-Roth bounds to the CS event study
honest_result <- tryCatch({
  cs_dynamic_main <- readRDS(paste0(data_dir, "cs_att_dynamic.rds"))

  # Need to convert CS output to HonestDiD-compatible format
  # Extract pre and post coefficients
  es_coefs <- data.frame(
    event_time = cs_dynamic_main$egt,
    estimate = cs_dynamic_main$att.egt,
    se = cs_dynamic_main$se.egt
  )

  # HonestDiD requires the beta vector and variance-covariance matrix
  # Use the honest_did helper from the did package
  honest_out <- honest_did(
    cs_result,
    type = "smoothness",
    Mvec = seq(0, 0.05, by = 0.01)
  )
  honest_out
}, error = function(e) {
  cat("HonestDiD failed:", e$message, "\n")
  cat("This is common with state-level panels. Proceeding without.\n")
  NULL
})

if (!is.null(honest_result)) {
  saveRDS(honest_result, paste0(data_dir, "honest_did_result.rds"))
}

###############################################################################
# PART 8: TWFE with Region-Year Fixed Effects
###############################################################################

cat("\n=== TWFE WITH REGION-YEAR FE ===\n")

# Check if census_division is available
if ("census_division" %in% names(panel) && !all(is.na(panel$census_division))) {
  # Create region-year interaction
  panel_region <- panel %>%
    filter(!is.na(log_res_elec_pc), !is.na(census_division)) %>%
    mutate(
      region_year = paste0(census_division, "_", year),
      eers_post = as.integer(year >= eers_year & eers_year > 0)
    )

  # TWFE with region-year FE (addresses reviewer concern about regional trends)
  twfe_region <- feols(log_res_elec_pc ~ eers_post | state_id + region_year,
                       data = panel_region, cluster = ~state_id)

  cat("TWFE with Region-Year FE:\n")
  cat("  ATT:", round(coef(twfe_region)["eers_post"], 4),
      " (SE:", round(se(twfe_region)["eers_post"], 4), ")\n")

  saveRDS(twfe_region, paste0(data_dir, "twfe_region_year.rds"))
} else {
  cat("Census division not available. Run 01c_fetch_policy.R first.\n")
  twfe_region <- NULL
}

###############################################################################
# PART 9: TWFE with Policy Controls (RPS, Decoupling)
###############################################################################

cat("\n=== TWFE WITH POLICY CONTROLS ===\n")

# Check if policy controls are available
if ("has_rps" %in% names(panel) && !all(is.na(panel$has_rps))) {
  panel_policy <- panel %>%
    filter(!is.na(log_res_elec_pc), !is.na(has_rps), !is.na(has_decoupling)) %>%
    mutate(
      eers_post = as.integer(year >= eers_year & eers_year > 0)
    )

  # TWFE controlling for concurrent policies
  twfe_policy <- feols(log_res_elec_pc ~ eers_post + has_rps + has_decoupling | state_id + year,
                       data = panel_policy, cluster = ~state_id)

  cat("TWFE with Policy Controls (RPS, Decoupling):\n")
  cat("  EERS ATT:", round(coef(twfe_policy)["eers_post"], 4),
      " (SE:", round(se(twfe_policy)["eers_post"], 4), ")\n")
  cat("  RPS coef:", round(coef(twfe_policy)["has_rps"], 4), "\n")
  cat("  Decoupling coef:", round(coef(twfe_policy)["has_decoupling"], 4), "\n")

  saveRDS(twfe_policy, paste0(data_dir, "twfe_policy_controls.rds"))
} else {
  cat("Policy controls not available. Run 01c_fetch_policy.R first.\n")
  twfe_policy <- NULL
}

###############################################################################
# PART 10: TWFE with Weather Controls (HDD/CDD)
###############################################################################

cat("\n=== TWFE WITH WEATHER CONTROLS ===\n")

# Check if weather data is available
if ("hdd" %in% names(panel) && !all(is.na(panel$hdd))) {
  panel_weather <- panel %>%
    filter(!is.na(log_res_elec_pc), !is.na(hdd), !is.na(cdd)) %>%
    mutate(
      eers_post = as.integer(year >= eers_year & eers_year > 0)
    )

  # TWFE controlling for weather
  twfe_weather <- feols(log_res_elec_pc ~ eers_post + hdd + cdd | state_id + year,
                        data = panel_weather, cluster = ~state_id)

  cat("TWFE with Weather Controls (HDD/CDD):\n")
  cat("  EERS ATT:", round(coef(twfe_weather)["eers_post"], 4),
      " (SE:", round(se(twfe_weather)["eers_post"], 4), ")\n")
  cat("  HDD coef:", round(coef(twfe_weather)["hdd"], 6), "\n")
  cat("  CDD coef:", round(coef(twfe_weather)["cdd"], 6), "\n")

  saveRDS(twfe_weather, paste0(data_dir, "twfe_weather_controls.rds"))
} else {
  cat("Weather data not available. Run 01b_fetch_weather.R first.\n")
  twfe_weather <- NULL
}

###############################################################################
# PART 11: Wild Cluster Bootstrap for Inference
###############################################################################

cat("\n=== WILD CLUSTER BOOTSTRAP ===\n")

# Use fwildclusterboot for robust inference with 51 clusters
if (requireNamespace("fwildclusterboot", quietly = TRUE)) {
  library(fwildclusterboot)

  # Run basic TWFE for bootstrap
  panel_boot <- panel %>%
    filter(!is.na(log_res_elec_pc)) %>%
    mutate(eers_post = as.integer(year >= eers_year & eers_year > 0))

  twfe_base <- feols(log_res_elec_pc ~ eers_post | state_id + year,
                     data = panel_boot, cluster = ~state_id)

  # Set seed for reproducibility (AER replication standards)
  set.seed(20260201)

  boot_result <- tryCatch({
    boottest(twfe_base,
             param = "eers_post",
             clustid = "state_id",
             B = 999,
             type = "mammen")
  }, error = function(e) {
    cat("Wild cluster bootstrap failed:", e$message, "\n")
    NULL
  })

  if (!is.null(boot_result)) {
    cat("Wild Cluster Bootstrap (Mammen weights, 999 reps):\n")
    cat("  Point estimate:", round(boot_result$point_estimate, 4), "\n")
    cat("  Bootstrap p-value:", round(boot_result$p_val, 4), "\n")
    cat("  Bootstrap 95% CI: [", round(boot_result$conf_int[1], 4), ", ",
        round(boot_result$conf_int[2], 4), "]\n")
    saveRDS(boot_result, paste0(data_dir, "wild_bootstrap_result.rds"))
  }
} else {
  cat("Package fwildclusterboot not installed. Skipping bootstrap.\n")
  boot_result <- NULL
}

###############################################################################
# PART 12: Summary Table of All Results
###############################################################################

cat("\n\n========================================\n")
cat("ROBUSTNESS SUMMARY\n")
cat("========================================\n\n")

# FIXED: Include ALL specifications in summary (was missing placebo timing and heterogeneity)
# Now also includes new robustness checks: region-year FE, policy controls, weather controls

# FIXED: Initialize _att objects to NULL to avoid ifelse() evaluation errors
# when the estimation objects don't exist
if (!exists("cs_price_att")) cs_price_att <- NULL
if (!exists("placebo_att")) placebo_att <- NULL
if (!exists("placebo_timing_att")) placebo_timing_att <- NULL
if (!exists("early_att")) early_att <- NULL
if (!exists("late_att")) late_att <- NULL
if (!exists("twfe_region")) twfe_region <- NULL
if (!exists("twfe_policy")) twfe_policy <- NULL
if (!exists("twfe_weather")) twfe_weather <- NULL

# Helper function that safely extracts values from objects
safe_get <- function(obj, accessor_fn, default_val = NA) {
  if (is.null(obj)) return(default_val)
  tryCatch(accessor_fn(obj), error = function(e) default_val)
}

results_summary <- tibble(
  Specification = c(
    "Main: CS (never-treated control)",
    "Alt control: CS (not-yet-treated)",
    "Alt outcome: Total electricity",
    "Alt outcome: Residential prices",
    "Placebo: Industrial consumption",
    "Placebo: Timing (5 years early)",
    "Heterogeneity: Early adopters (<2008)",
    "Heterogeneity: Late adopters (>=2008)",
    "TWFE: Region-Year FE",
    "TWFE: Policy controls",
    "TWFE: Weather controls"
  ),
  ATT = c(
    round(readRDS(paste0(data_dir, "cs_att_simple.rds"))$overall.att, 4),
    round(cs_nyt_att$overall.att, 4),
    round(cs_total_att$overall.att, 4),
    safe_get(cs_price_att, function(x) round(x$overall.att, 4)),
    safe_get(placebo_att, function(x) round(x$overall.att, 4)),
    safe_get(placebo_timing_att, function(x) round(x$overall.att, 4)),
    safe_get(early_att, function(x) round(x$overall.att, 4)),
    safe_get(late_att, function(x) round(x$overall.att, 4)),
    safe_get(twfe_region, function(x) round(coef(x)["eers_post"], 4)),
    safe_get(twfe_policy, function(x) round(coef(x)["eers_post"], 4)),
    safe_get(twfe_weather, function(x) round(coef(x)["eers_post"], 4))
  ),
  SE = c(
    round(readRDS(paste0(data_dir, "cs_att_simple.rds"))$overall.se, 4),
    round(cs_nyt_att$overall.se, 4),
    round(cs_total_att$overall.se, 4),
    safe_get(cs_price_att, function(x) round(x$overall.se, 4)),
    safe_get(placebo_att, function(x) round(x$overall.se, 4)),
    safe_get(placebo_timing_att, function(x) round(x$overall.se, 4)),
    safe_get(early_att, function(x) round(x$overall.se, 4)),
    safe_get(late_att, function(x) round(x$overall.se, 4)),
    safe_get(twfe_region, function(x) round(se(x)["eers_post"], 4)),
    safe_get(twfe_policy, function(x) round(se(x)["eers_post"], 4)),
    safe_get(twfe_weather, function(x) round(se(x)["eers_post"], 4))
  )
)

print(results_summary)

saveRDS(results_summary, paste0(data_dir, "robustness_summary.rds"))
cat("\n========================================\n")
