# =============================================================================
# 05_robustness.R
# Robustness Checks and Sensitivity Analysis
# Paper 117: Sports Betting Employment Effects
# =============================================================================

source("00_packages.R")

# =============================================================================
# Load Data and Main Results
# =============================================================================

message("Loading data and main results...")
analysis_df <- read_csv("../data/analysis_sample.csv", show_col_types = FALSE)
cs_data <- read_csv("../data/cs_analysis_data.csv", show_col_types = FALSE)
main_results <- readRDS("../data/main_results.rds")

# =============================================================================
# 1. HonestDiD Sensitivity Analysis
# =============================================================================

message("\n", paste(rep("=", 70), collapse = ""))
message("1. HONESTDID SENSITIVITY ANALYSIS")
message(paste(rep("=", 70), collapse = ""), "\n")

# Get event study results from main analysis
cs_event <- main_results$cs_event

# Extract relevant info for HonestDiD
# We need the event study coefficients and variance-covariance matrix

tryCatch({
  # HonestDiD requires relative magnitudes for pre-trend violations
  # Mbar = bound on how much worse post-treatment violations can be relative to pre-trends

  # Create HonestDiD-compatible object
  honest_result <- honest_did(
    main_results$cs_result,
    type = "smoothness",
    Mvec = c(0, 0.5, 1, 2)  # Different bounds on M
  )

  message("HonestDiD Results (Smoothness Restriction):")
  print(honest_result)

  # Save for table
  honest_df <- data.frame(
    M = c(0, 0.5, 1, 2),
    lb = sapply(honest_result, function(x) x$lb),
    ub = sapply(honest_result, function(x) x$ub)
  )

  write_csv(honest_df, "../data/honestdid_results.csv")
  message("\nSaved: ../data/honestdid_results.csv")

}, error = function(e) {
  message("HonestDiD error: ", conditionMessage(e))
  message("Proceeding with other robustness checks...")
})

# =============================================================================
# 2. COVID Sensitivity: Exclude 2020-2021
# =============================================================================

message("\n", paste(rep("=", 70), collapse = ""))
message("2. COVID SENSITIVITY: EXCLUDE 2020-2021")
message(paste(rep("=", 70), collapse = ""), "\n")

cs_data_nocovid <- cs_data %>%
  filter(!(year %in% c(2020, 2021)))

cs_nocovid <- att_gt(
  yname = "log_employment",
  tname = "year",
  idname = "state_id",
  gname = "g",
  data = cs_data_nocovid,
  control_group = "notyettreated",
  anticipation = 0,
  est_method = "dr"
)

cs_nocovid_overall <- aggte(cs_nocovid, type = "simple")
message("ATT excluding 2020-2021:")
summary(cs_nocovid_overall)

# =============================================================================
# 3. Exclude iGaming States
# =============================================================================

message("\n", paste(rep("=", 70), collapse = ""))
message("3. EXCLUDE iGAMING STATES")
message(paste(rep("=", 70), collapse = ""), "\n")

igaming_states <- c("NJ", "DE", "NV", "PA", "WV", "MI", "CT", "RI")

cs_data_noigaming <- cs_data %>%
  filter(!(state_abbr %in% igaming_states))

message(sprintf("Excluding %d iGaming states: %s",
                length(igaming_states), paste(igaming_states, collapse = ", ")))
message(sprintf("Remaining observations: %d", nrow(cs_data_noigaming)))

cs_noigaming <- att_gt(
  yname = "log_employment",
  tname = "year",
  idname = "state_id",
  gname = "g",
  data = cs_data_noigaming,
  control_group = "notyettreated",
  anticipation = 0,
  est_method = "dr"
)

cs_noigaming_overall <- aggte(cs_noigaming, type = "simple")
message("ATT excluding iGaming states:")
summary(cs_noigaming_overall)

# =============================================================================
# 4. Exclude Pre-PASPA States (DE, MT, OR)
# =============================================================================

message("\n", paste(rep("=", 70), collapse = ""))
message("4. EXCLUDE PRE-PASPA EXPANSION STATES")
message(paste(rep("=", 70), collapse = ""), "\n")

prepaspa_states <- c("DE", "MT", "OR")

cs_data_noprepaspa <- cs_data %>%
  filter(!(state_abbr %in% prepaspa_states))

cs_noprepaspa <- att_gt(
  yname = "log_employment",
  tname = "year",
  idname = "state_id",
  gname = "g",
  data = cs_data_noprepaspa,
  control_group = "notyettreated",
  anticipation = 0,
  est_method = "dr"
)

cs_noprepaspa_overall <- aggte(cs_noprepaspa, type = "simple")
message("ATT excluding pre-PASPA states:")
summary(cs_noprepaspa_overall)

# =============================================================================
# 5. Leave-One-Out Analysis
# =============================================================================

message("\n", paste(rep("=", 70), collapse = ""))
message("5. LEAVE-ONE-OUT ANALYSIS")
message(paste(rep("=", 70), collapse = ""), "\n")

# Get list of treated states
treated_states <- cs_data %>%
  filter(g > 0) %>%
  pull(state_abbr) %>%
  unique()

message(sprintf("Running leave-one-out for %d treated states...", length(treated_states)))

loo_results <- map_dfr(treated_states, function(s) {
  message(sprintf("  Excluding %s...", s))

  cs_loo <- tryCatch({
    att_gt(
      yname = "log_employment",
      tname = "year",
      idname = "state_id",
      gname = "g",
      data = cs_data %>% filter(state_abbr != s),
      control_group = "notyettreated",
      anticipation = 0,
      est_method = "dr"
    )
  }, error = function(e) NULL)

  if (!is.null(cs_loo)) {
    cs_loo_agg <- aggte(cs_loo, type = "simple")
    tibble(
      excluded_state = s,
      att = cs_loo_agg$overall.att,
      se = cs_loo_agg$overall.se
    )
  } else {
    tibble(
      excluded_state = s,
      att = NA_real_,
      se = NA_real_
    )
  }
})

message("\nLeave-One-Out Results:")
print(loo_results)

write_csv(loo_results, "../data/leave_one_out.csv")
message("\nSaved: ../data/leave_one_out.csv")

# =============================================================================
# 6. Placebo Tests: Manufacturing and Agriculture
# =============================================================================

message("\n", paste(rep("=", 70), collapse = ""))
message("6. PLACEBO TESTS")
message(paste(rep("=", 70), collapse = ""), "\n")

# Load placebo industry data
qcew_all <- read_csv("../data/qcew_all_industries.csv", show_col_types = FALSE)
policy_panel <- read_csv("../data/policy_panel.csv", show_col_types = FALSE)

run_placebo <- function(naics_code, industry_name) {
  message(sprintf("\n--- Placebo: %s (NAICS %s) ---\n", industry_name, naics_code))

  placebo_data <- qcew_all %>%
    filter(industry_code == naics_code) %>%
    left_join(
      policy_panel %>% select(state_abbr, treatment_year),
      by = "state_abbr"
    ) %>%
    filter(!is.na(treatment_year)) %>%
    mutate(
      log_employment = log(employment + 1),
      state_id = as.integer(factor(state_abbr)),
      g = if_else(is.na(treatment_year), 0L, as.integer(treatment_year))
    ) %>%
    filter(!is.na(employment))

  if (nrow(placebo_data) == 0) {
    message("  No data available")
    return(NULL)
  }

  tryCatch({
    cs_placebo <- att_gt(
      yname = "log_employment",
      tname = "year",
      idname = "state_id",
      gname = "g",
      data = placebo_data,
      control_group = "notyettreated",
      anticipation = 0,
      est_method = "dr"
    )

    cs_placebo_overall <- aggte(cs_placebo, type = "simple")
    message(sprintf("  ATT: %.4f (SE = %.4f)", cs_placebo_overall$overall.att, cs_placebo_overall$overall.se))

    tibble(
      industry = industry_name,
      naics = naics_code,
      att = cs_placebo_overall$overall.att,
      se = cs_placebo_overall$overall.se,
      pvalue = 2 * pnorm(-abs(cs_placebo_overall$overall.att / cs_placebo_overall$overall.se))
    )
  }, error = function(e) {
    message("  Error: ", conditionMessage(e))
    NULL
  })
}

placebo_mfg <- run_placebo("31-33", "Manufacturing")
placebo_ag <- run_placebo("11", "Agriculture")

placebo_results <- bind_rows(placebo_mfg, placebo_ag)

if (nrow(placebo_results) > 0) {
  write_csv(placebo_results, "../data/placebo_results.csv")
  message("\nSaved: ../data/placebo_results.csv")
}

# =============================================================================
# Compile All Robustness Results
# =============================================================================

message("\n", paste(rep("=", 70), collapse = ""))
message("ROBUSTNESS SUMMARY")
message(paste(rep("=", 70), collapse = ""), "\n")

# Build robustness summary with error handling
get_att_safe <- function(obj) {
  tryCatch({
    val <- obj$overall.att
    if (is.null(val)) return(NA_real_)
    as.numeric(val)[1]
  }, error = function(e) NA_real_)
}
get_se_safe <- function(obj) {
  tryCatch({
    val <- obj$overall.se
    if (is.null(val)) return(NA_real_)
    as.numeric(val)[1]
  }, error = function(e) NA_real_)
}

# Debug: print values
message("Main ATT: ", get_att_safe(main_results$cs_overall))
message("Never-treated ATT: ", get_att_safe(main_results$cs_nevertreated))
message("No COVID ATT: ", get_att_safe(cs_nocovid_overall))
message("No iGaming ATT: ", get_att_safe(cs_noigaming_overall))
message("No pre-PASPA ATT: ", get_att_safe(cs_noprepaspa_overall))

robustness_summary <- tibble(
  specification = c("Main (not-yet-treated)", "Never-treated controls",
                    "Exclude COVID (2020-21)", "Exclude iGaming states",
                    "Exclude pre-PASPA states"),
  att = c(
    get_att_safe(main_results$cs_overall),
    get_att_safe(main_results$cs_nevertreated),
    get_att_safe(cs_nocovid_overall),
    get_att_safe(cs_noigaming_overall),
    get_att_safe(cs_noprepaspa_overall)
  ),
  se = c(
    get_se_safe(main_results$cs_overall),
    get_se_safe(main_results$cs_nevertreated),
    get_se_safe(cs_nocovid_overall),
    get_se_safe(cs_noigaming_overall),
    get_se_safe(cs_noprepaspa_overall)
  )
) %>%
  mutate(
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se,
    pct_change = (exp(att) - 1) * 100
  )

print(robustness_summary)

# Save all robustness results
robustness_results <- list(
  summary = robustness_summary,
  nocovid = if(exists("cs_nocovid_overall")) cs_nocovid_overall else NULL,
  noigaming = if(exists("cs_noigaming_overall")) cs_noigaming_overall else NULL,
  noprepaspa = if(exists("cs_noprepaspa_overall")) cs_noprepaspa_overall else NULL,
  leave_one_out = if(exists("loo_results")) loo_results else NULL,
  placebo = if(exists("placebo_results") && !is.null(placebo_results) && nrow(placebo_results) > 0) placebo_results else NULL
)

saveRDS(robustness_results, "../data/robustness_results.rds")
message("\nSaved: ../data/robustness_results.rds")

write_csv(robustness_summary, "../data/robustness_summary.csv")
message("Saved: ../data/robustness_summary.csv")

message("\n", paste(rep("=", 70), collapse = ""))
message("ROBUSTNESS CHECKS COMPLETE")
message(paste(rep("=", 70), collapse = ""))
