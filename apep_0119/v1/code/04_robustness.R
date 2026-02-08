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
cs_early_data <- cs_data %>%
  filter(state_abbr %in% c(early_states, cs_data$state_abbr[cs_data$first_treat == 0]) ) %>%
  mutate(first_treat = ifelse(eers_year == 0 | !(state_abbr %in% early_states), 0L, as.integer(eers_year)))

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
}

# Late adopters CS
cs_late_data <- cs_data %>%
  filter(state_abbr %in% c(late_states, cs_data$state_abbr[cs_data$first_treat == 0]) ) %>%
  mutate(first_treat = ifelse(eers_year == 0 | !(state_abbr %in% late_states), 0L, as.integer(eers_year)))

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
# PART 8: Summary Table of All Results
###############################################################################

cat("\n\n========================================\n")
cat("ROBUSTNESS SUMMARY\n")
cat("========================================\n\n")

results_summary <- tibble(
  Specification = c(
    "Main: CS (never-treated control)",
    "Alt control: CS (not-yet-treated)",
    "Alt outcome: Total electricity",
    "Alt outcome: Residential prices",
    "Placebo: Industrial consumption"
  ),
  ATT = c(
    round(readRDS(paste0(data_dir, "cs_att_simple.rds"))$overall.att, 4),
    round(cs_nyt_att$overall.att, 4),
    round(cs_total_att$overall.att, 4),
    ifelse(!is.null(cs_price), round(cs_price_att$overall.att, 4), NA),
    ifelse(!is.null(cs_placebo_ind), round(placebo_att$overall.att, 4), NA)
  ),
  SE = c(
    round(readRDS(paste0(data_dir, "cs_att_simple.rds"))$overall.se, 4),
    round(cs_nyt_att$overall.se, 4),
    round(cs_total_att$overall.se, 4),
    ifelse(!is.null(cs_price), round(cs_price_att$overall.se, 4), NA),
    ifelse(!is.null(cs_placebo_ind), round(placebo_att$overall.se, 4), NA)
  )
)

print(results_summary)

saveRDS(results_summary, paste0(data_dir, "robustness_summary.rds"))
cat("\n========================================\n")
