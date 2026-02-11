# =============================================================================
# 04_main_analysis.R
# Main Difference-in-Differences Analysis
# Sports Betting Employment Effects - Revision of apep_0038 (v3)
# =============================================================================

source("00_packages.R")

# Set seed for reproducibility of bootstrap inference
set.seed(20240514)  # Murphy v. NCAA decision date

# -----------------------------------------------------------------------------
# Load Data
# -----------------------------------------------------------------------------

message("Loading analysis data...")
cs_data <- read_csv("../data/cs_analysis_data.csv", show_col_types = FALSE)
analysis_sample <- read_csv("../data/analysis_sample.csv", show_col_types = FALSE)

# Verify data structure
message(sprintf("Observations: %d", nrow(cs_data)))
message(sprintf("States: %d", n_distinct(cs_data$state_abbr)))
message(sprintf("Years: %d to %d", min(cs_data$year), max(cs_data$year)))
message(sprintf("Treated states: %d", sum(cs_data$G > 0 & !duplicated(cs_data$state_abbr))))
message(sprintf("Never-treated states: %d", sum(cs_data$G == 0 & !duplicated(cs_data$state_abbr))))

# Create numeric state ID (did package requires numeric idname)
cs_data <- cs_data %>%
  mutate(state_id = as.numeric(factor(state_abbr)))

# -----------------------------------------------------------------------------
# 1. Callaway-Sant'Anna Difference-in-Differences
# -----------------------------------------------------------------------------

message("\n", paste(rep("=", 60), collapse = ""))
message("Callaway-Sant'Anna DiD Estimation")
message(paste(rep("=", 60), collapse = ""))

cs_result <- att_gt(
  yname = "empl_7132",
  tname = "t",
  idname = "state_id",
  gname = "G",
  data = cs_data %>% filter(G > 0 | G == 0),
  control_group = "notyettreated",
  anticipation = 0,
  est_method = "dr",
  bstrap = TRUE,
  biters = 1000,
  clustervars = "state_id",
  print_details = FALSE
)

# Aggregate to overall ATT
att_overall <- aggte(cs_result, type = "simple", na.rm = TRUE)
message("\n--- Overall ATT (Simple) ---")
summary(att_overall)

# Aggregate to dynamic effects (event study)
att_dynamic <- aggte(cs_result, type = "dynamic", na.rm = TRUE)
message("\n--- Dynamic ATT (Event Study) ---")
summary(att_dynamic)

# Aggregate by cohort
att_cohort <- aggte(cs_result, type = "group", na.rm = TRUE)
message("\n--- ATT by Cohort ---")
summary(att_cohort)

# Aggregate by calendar time
att_calendar <- aggte(cs_result, type = "calendar", na.rm = TRUE)
message("\n--- ATT by Calendar Time ---")
summary(att_calendar)

# -----------------------------------------------------------------------------
# 2. Extract Key Results
# -----------------------------------------------------------------------------

# Overall ATT
overall_att <- att_overall$overall.att
overall_se <- att_overall$overall.se
overall_ci_low <- overall_att - 1.96 * overall_se
overall_ci_high <- overall_att + 1.96 * overall_se

message("\n", paste(rep("=", 60), collapse = ""))
message("MAIN RESULT")
message(paste(rep("=", 60), collapse = ""))
message(sprintf("Overall ATT: %.1f jobs (SE: %.1f)", overall_att, overall_se))
message(sprintf("95%% CI: [%.1f, %.1f]", overall_ci_low, overall_ci_high))
message(sprintf("t-statistic: %.2f", overall_att / overall_se))
message(sprintf("p-value: %.4f", 2 * pnorm(-abs(overall_att / overall_se))))

# Event study coefficients
event_study_results <- tibble(
  event_time = att_dynamic$egt,
  att = att_dynamic$att.egt,
  se = att_dynamic$se.egt,
  ci_low = att - 1.96 * se,
  ci_high = att + 1.96 * se,
  significant = abs(att / se) > 1.96
)

message("\n--- Event Study Coefficients ---")
print(event_study_results)

# -----------------------------------------------------------------------------
# 2b. Pre-trend test: Proper joint Wald test
# -----------------------------------------------------------------------------

# The aggte() function with type="dynamic" provides a proper Wald test
# that accounts for the covariance structure of the pre-treatment estimates.
# We use aggte()'s built-in Wald statistic from the pre-treatment coefficients.

pre_coeffs <- event_study_results %>% filter(event_time < 0)
n_pre <- nrow(pre_coeffs)

# Extract the variance-covariance matrix from the dynamic aggregation
# The att_dynamic object contains the full inf.function for all event times
# We need the VCV of the pre-treatment coefficients

# Get the influence function matrix for all event-time estimates
if (!is.null(att_dynamic$inf.function) && !is.null(att_dynamic$inf.function$dynamic.inf.func.e)) {
  inf_func <- att_dynamic$inf.function$dynamic.inf.func.e

  # Identify which columns correspond to pre-treatment event times
  all_event_times <- att_dynamic$egt
  pre_idx <- which(all_event_times < 0)

  if (length(pre_idx) > 0 && ncol(inf_func) >= max(pre_idx)) {
    # Extract pre-treatment influence functions
    pre_inf <- inf_func[, pre_idx, drop = FALSE]

    # Compute variance-covariance matrix
    n_units <- nrow(pre_inf)
    pre_vcv <- (t(pre_inf) %*% pre_inf) / (n_units^2)

    # Joint Wald test: beta' * Sigma^{-1} * beta
    pre_betas <- pre_coeffs$att
    wald_stat <- tryCatch({
      as.numeric(t(pre_betas) %*% solve(pre_vcv) %*% pre_betas)
    }, error = function(e) {
      # If VCV is singular, use pseudo-inverse
      message("Note: Using generalized inverse for Wald test (near-singular VCV)")
      as.numeric(t(pre_betas) %*% MASS::ginv(pre_vcv) %*% pre_betas)
    })

    pre_trend_fstat <- wald_stat / n_pre
    pre_trend_pval <- 1 - pf(pre_trend_fstat, n_pre, Inf)

    message(sprintf("\nPre-trend joint Wald test (proper VCV):"))
    message(sprintf("  Wald statistic: %.2f (df = %d)", wald_stat, n_pre))
    message(sprintf("  F-statistic: %.2f", pre_trend_fstat))
    message(sprintf("  p-value: %.4f", pre_trend_pval))
  } else {
    message("Could not extract pre-treatment influence functions; using marginal test")
    pre_trend_fstat <- sum((pre_coeffs$att / pre_coeffs$se)^2) / n_pre
    pre_trend_pval <- 1 - pf(pre_trend_fstat, n_pre, Inf)
  }
} else {
  message("No influence function available; using marginal test as fallback")
  pre_trend_fstat <- sum((pre_coeffs$att / pre_coeffs$se)^2) / n_pre
  pre_trend_pval <- 1 - pf(pre_trend_fstat, n_pre, Inf)
}

message(sprintf("\nPre-trend F-test: F = %.2f, p = %.3f", pre_trend_fstat, pre_trend_pval))

# -----------------------------------------------------------------------------
# 3. Robustness: Alternative Control Groups
# -----------------------------------------------------------------------------

message("\n", paste(rep("=", 60), collapse = ""))
message("Robustness: Never-Treated Control Group")
message(paste(rep("=", 60), collapse = ""))

cs_nevertreated <- att_gt(
  yname = "empl_7132",
  tname = "t",
  idname = "state_id",
  gname = "G",
  data = cs_data,
  control_group = "nevertreated",
  anticipation = 0,
  est_method = "dr",
  bstrap = TRUE,
  biters = 1000,
  clustervars = "state_id",
  print_details = FALSE
)

att_never_overall <- aggte(cs_nevertreated, type = "simple", na.rm = TRUE)
message(sprintf("ATT (never-treated control): %.1f (SE: %.1f)",
                att_never_overall$overall.att, att_never_overall$overall.se))

# -----------------------------------------------------------------------------
# 4. Robustness: TWFE Comparison
# -----------------------------------------------------------------------------

message("\n", paste(rep("=", 60), collapse = ""))
message("Comparison: Two-Way Fixed Effects (TWFE)")
message(paste(rep("=", 60), collapse = ""))

twfe_model <- feols(
  empl_7132 ~ treated | state_abbr + year,
  data = analysis_sample,
  cluster = ~state_abbr
)

message("TWFE results:")
print(summary(twfe_model))

twfe_att <- coef(twfe_model)["treated"]
twfe_se <- sqrt(vcov(twfe_model)["treated", "treated"])

message(sprintf("\nTWFE ATT: %.1f (SE: %.1f)", twfe_att, twfe_se))
message(sprintf("CS ATT:   %.1f (SE: %.1f)", overall_att, overall_se))
message("Note: TWFE may be biased with heterogeneous effects")

# -----------------------------------------------------------------------------
# 5. Heterogeneity: Mobile vs Retail-Only
# -----------------------------------------------------------------------------

message("\n", paste(rep("=", 60), collapse = ""))
message("Heterogeneity: Mobile Betting States")
message(paste(rep("=", 60), collapse = ""))

# Mobile states
mobile_states <- cs_data %>%
  filter(has_mobile == TRUE, G > 0) %>%
  pull(state_abbr) %>%
  unique()

# Retail-only states
retail_only <- cs_data %>%
  filter(has_mobile == FALSE, G > 0) %>%
  pull(state_abbr) %>%
  unique()

message(sprintf("Mobile states: %d", length(mobile_states)))
message(sprintf("Retail-only states: %d", length(retail_only)))

# Estimate for mobile states
if (length(mobile_states) >= 3) {
  cs_mobile <- att_gt(
    yname = "empl_7132",
    tname = "t",
    idname = "state_id",
    gname = "G",
    data = cs_data %>% filter(state_abbr %in% c(mobile_states, cs_data$state_abbr[cs_data$G == 0])),
    control_group = "notyettreated",
    anticipation = 0,
    bstrap = TRUE,
    biters = 500,
    print_details = FALSE
  )

  att_mobile <- aggte(cs_mobile, type = "simple", na.rm = TRUE)
  message(sprintf("\nMobile states ATT: %.1f (SE: %.1f)",
                  att_mobile$overall.att, att_mobile$overall.se))
}

# Estimate for retail-only states
if (length(retail_only) >= 3) {
  cs_retail <- att_gt(
    yname = "empl_7132",
    tname = "t",
    idname = "state_id",
    gname = "G",
    data = cs_data %>% filter(state_abbr %in% c(retail_only, cs_data$state_abbr[cs_data$G == 0])),
    control_group = "notyettreated",
    anticipation = 0,
    bstrap = TRUE,
    biters = 500,
    print_details = FALSE
  )

  att_retail <- aggte(cs_retail, type = "simple", na.rm = TRUE)
  message(sprintf("Retail-only ATT: %.1f (SE: %.1f)",
                  att_retail$overall.att, att_retail$overall.se))
}

# -----------------------------------------------------------------------------
# 6. Heterogeneity: Pre-COVID vs COVID Cohorts
# -----------------------------------------------------------------------------

message("\n", paste(rep("=", 60), collapse = ""))
message("Heterogeneity: Pre-COVID vs COVID-Era Cohorts")
message(paste(rep("=", 60), collapse = ""))

# Pre-COVID cohorts (2018-2019)
pre_covid_cohorts <- cs_data %>%
  filter(G > 0, G < 2020) %>%
  pull(state_abbr) %>%
  unique()

# COVID cohorts (2020+)
covid_cohorts <- cs_data %>%
  filter(G >= 2020) %>%
  pull(state_abbr) %>%
  unique()

message(sprintf("Pre-COVID cohort states: %d", length(pre_covid_cohorts)))
message(sprintf("COVID-era cohort states: %d", length(covid_cohorts)))

if (length(pre_covid_cohorts) >= 3) {
  cs_precovid <- att_gt(
    yname = "empl_7132",
    tname = "t",
    idname = "state_id",
    gname = "G",
    data = cs_data %>% filter(state_abbr %in% c(pre_covid_cohorts, cs_data$state_abbr[cs_data$G == 0])),
    control_group = "notyettreated",
    anticipation = 0,
    bstrap = TRUE,
    biters = 500,
    print_details = FALSE
  )

  att_precovid <- aggte(cs_precovid, type = "simple", na.rm = TRUE)
  message(sprintf("\nPre-COVID cohorts ATT: %.1f (SE: %.1f)",
                  att_precovid$overall.att, att_precovid$overall.se))
}

# -----------------------------------------------------------------------------
# 7. Wage Analysis (NEW in v3 — requested by all reviewers)
# -----------------------------------------------------------------------------

message("\n", paste(rep("=", 60), collapse = ""))
message("Wage Analysis: Effect on Weekly Wages")
message(paste(rep("=", 60), collapse = ""))

# DiD on log weekly wages
if ("log_wkly_wage" %in% names(cs_data) && sum(!is.na(cs_data$log_wkly_wage)) > 100) {

  cs_wage <- tryCatch({
    att_gt(
      yname = "log_wkly_wage",
      tname = "t",
      idname = "state_id",
      gname = "G",
      data = cs_data %>% filter(G >= 0, !is.na(log_wkly_wage), is.finite(log_wkly_wage)),
      control_group = "notyettreated",
      anticipation = 0,
      est_method = "dr",
      bstrap = TRUE,
      biters = 1000,
      clustervars = "state_id",
      print_details = FALSE
    )
  }, error = function(e) {
    message(sprintf("Wage CS estimation error: %s", e$message))
    NULL
  })

  if (!is.null(cs_wage)) {
    att_wage_overall <- aggte(cs_wage, type = "simple", na.rm = TRUE)
    att_wage_dynamic <- aggte(cs_wage, type = "dynamic", na.rm = TRUE)

    message(sprintf("Wage ATT (log weekly wage): %.4f (SE: %.4f)",
                    att_wage_overall$overall.att, att_wage_overall$overall.se))
    message(sprintf("  Implied %% change: %.1f%%", 100 * att_wage_overall$overall.att))

    # Wage event study
    wage_event_study <- tibble(
      event_time = att_wage_dynamic$egt,
      att = att_wage_dynamic$att.egt,
      se = att_wage_dynamic$se.egt,
      ci_low = att - 1.96 * se,
      ci_high = att + 1.96 * se
    )

    write_csv(wage_event_study, "../data/wage_event_study.csv")
    message("Saved: ../data/wage_event_study.csv")
  }

  # Descriptive: gambling wages vs state median
  wage_comparison <- analysis_sample %>%
    filter(year == 2023, !is.na(wkly_wage_7132)) %>%
    summarise(
      mean_gambling_wage = mean(wkly_wage_7132, na.rm = TRUE),
      median_gambling_wage = median(wkly_wage_7132, na.rm = TRUE),
      sd_gambling_wage = sd(wkly_wage_7132, na.rm = TRUE)
    )

  message(sprintf("\n2023 gambling industry wages:"))
  message(sprintf("  Mean weekly wage: $%.0f (~$%.0f annual)",
                  wage_comparison$mean_gambling_wage,
                  wage_comparison$mean_gambling_wage * 52))
  message(sprintf("  Median weekly wage: $%.0f (~$%.0f annual)",
                  wage_comparison$median_gambling_wage,
                  wage_comparison$median_gambling_wage * 52))

} else {
  message("Wage data not available in dataset")
  cs_wage <- NULL
  att_wage_overall <- NULL
}

# Also TWFE wage regression for comparison
twfe_wage <- tryCatch({
  feols(
    log_wkly_wage ~ treated | state_abbr + year,
    data = analysis_sample %>% filter(!is.na(log_wkly_wage), is.finite(log_wkly_wage)),
    cluster = ~state_abbr
  )
}, error = function(e) NULL)

if (!is.null(twfe_wage)) {
  message(sprintf("TWFE wage effect: %.4f (SE: %.4f)",
                  coef(twfe_wage)["treated"],
                  sqrt(vcov(twfe_wage)["treated", "treated"])))
}

# -----------------------------------------------------------------------------
# 8. Save Results
# -----------------------------------------------------------------------------

results <- list(
  overall = list(
    att = overall_att,
    se = overall_se,
    ci_low = overall_ci_low,
    ci_high = overall_ci_high,
    n_treated = sum(cs_data$G > 0 & !duplicated(cs_data$state_abbr)),
    n_control = sum(cs_data$G == 0 & !duplicated(cs_data$state_abbr))
  ),
  event_study = event_study_results,
  pre_trend_test = list(
    f_stat = pre_trend_fstat,
    p_value = pre_trend_pval
  ),
  twfe_comparison = list(
    att = twfe_att,
    se = twfe_se
  ),
  never_treated = list(
    att = att_never_overall$overall.att,
    se = att_never_overall$overall.se
  ),
  heterogeneity = list(
    mobile = if (exists("att_mobile")) list(att = att_mobile$overall.att, se = att_mobile$overall.se) else NULL,
    retail = if (exists("att_retail")) list(att = att_retail$overall.att, se = att_retail$overall.se) else NULL,
    precovid = if (exists("att_precovid")) list(att = att_precovid$overall.att, se = att_precovid$overall.se) else NULL
  ),
  wage = list(
    att = if (!is.null(att_wage_overall)) att_wage_overall$overall.att else NA,
    se = if (!is.null(att_wage_overall)) att_wage_overall$overall.se else NA,
    twfe_att = if (!is.null(twfe_wage)) coef(twfe_wage)["treated"] else NA,
    twfe_se = if (!is.null(twfe_wage)) sqrt(vcov(twfe_wage)["treated", "treated"]) else NA
  )
)

saveRDS(results, "../data/main_results.rds")
write_csv(event_study_results, "../data/event_study_coefficients.csv")

message("\n", paste(rep("=", 60), collapse = ""))
message("Results saved to ../data/main_results.rds")
message(paste(rep("=", 60), collapse = ""))
