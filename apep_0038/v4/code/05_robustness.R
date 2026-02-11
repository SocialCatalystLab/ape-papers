# =============================================================================
# 05_robustness.R
# Robustness Checks: HonestDiD, COVID Sensitivity, Placebos, Spillovers
# Sports Betting Employment Effects - Revision of apep_0038 (v3)
# =============================================================================

source("00_packages.R")

# Set seed for reproducibility of bootstrap inference
set.seed(20240514)  # Murphy v. NCAA decision date

# -----------------------------------------------------------------------------
# Load Data
# -----------------------------------------------------------------------------

cs_data <- read_csv("../data/cs_analysis_data.csv", show_col_types = FALSE)
analysis_sample <- read_csv("../data/analysis_sample.csv", show_col_types = FALSE)
main_results <- readRDS("../data/main_results.rds")

# Create numeric state ID (did package requires numeric idname)
cs_data <- cs_data %>%
  mutate(state_id = as.numeric(factor(state_abbr)))
analysis_sample <- analysis_sample %>%
  mutate(state_id = as.numeric(factor(state_abbr)))

# -----------------------------------------------------------------------------
# 1. HonestDiD Sensitivity Analysis (Rambachan-Roth) — PROPER implementation
# -----------------------------------------------------------------------------

message("\n", paste(rep("=", 60), collapse = ""))
message("HonestDiD Sensitivity Analysis")
message(paste(rep("=", 60), collapse = ""))

# Re-run Callaway-Sant'Anna for HonestDiD input
cs_result <- att_gt(
  yname = "empl_7132",
  tname = "t",
  idname = "state_id",
  gname = "G",
  data = cs_data %>% filter(G >= 0),
  control_group = "notyettreated",
  anticipation = 0,
  est_method = "dr",
  bstrap = TRUE,
  biters = 1000,
  clustervars = "state_id",
  print_details = FALSE
)

att_dynamic <- aggte(cs_result, type = "dynamic", na.rm = TRUE)

# HonestDiD sensitivity using the proper package functions
es_results <- tibble(
  e = att_dynamic$egt,
  estimate = att_dynamic$att.egt,
  se = att_dynamic$se.egt
)

pre_periods <- es_results %>% filter(e < 0)
post_periods <- es_results %>% filter(e >= 0)

honest_did_results <- NULL

if (nrow(pre_periods) >= 2 && nrow(post_periods) >= 1) {

  tryCatch({
    # Use HonestDiD package with the CS estimator output
    # We need betahat (event study coefficients) and sigma (VCV matrix)

    # Get all event-time estimates and their VCV
    all_event_times <- att_dynamic$egt
    n_periods <- length(all_event_times)
    betahat <- att_dynamic$att.egt

    # Construct VCV from influence function
    if (!is.null(att_dynamic$inf.function) &&
        !is.null(att_dynamic$inf.function$dynamic.inf.func.e)) {
      inf_func <- att_dynamic$inf.function$dynamic.inf.func.e
      n_units <- nrow(inf_func)
      sigma <- (t(inf_func) %*% inf_func) / (n_units^2)
    } else {
      # Fallback: diagonal VCV from SEs
      sigma <- diag(att_dynamic$se.egt^2)
    }

    # HonestDiD requires: betahat for all periods, sigma for all periods,
    # number of pre-treatment periods
    n_pre <- sum(all_event_times < 0)
    n_post <- sum(all_event_times >= 0)

    # Reorder so pre-treatment comes first (HonestDiD convention)
    pre_idx <- which(all_event_times < 0)
    post_idx <- which(all_event_times >= 0)
    reorder_idx <- c(pre_idx, post_idx)

    betahat_ordered <- betahat[reorder_idx]
    sigma_ordered <- sigma[reorder_idx, reorder_idx]

    message("\nRunning HonestDiD relative magnitudes sensitivity...")
    message(sprintf("  Pre-treatment periods: %d", n_pre))
    message(sprintf("  Post-treatment periods: %d", n_post))

    # Run sensitivity analysis using relative magnitudes
    # This asks: how large would post-treatment trend violations need
    # to be (relative to pre-treatment) to overturn conclusions?

    # Use createSensitivityResults_relativeMagnitudes for first post-treatment period
    honest_results <- tryCatch({
      HonestDiD::createSensitivityResults_relativeMagnitudes(
        betahat = betahat_ordered,
        sigma = sigma_ordered,
        numPrePeriods = n_pre,
        numPostPeriods = n_post,
        Mbarvec = c(0, 0.5, 1, 1.5, 2),
        l_vec = basisVector(1, n_post),  # First post-treatment period
        alpha = 0.05
      )
    }, error = function(e) {
      message(sprintf("  HonestDiD createSensitivityResults error: %s", e$message))
      NULL
    })

    if (!is.null(honest_results)) {
      message("\nRelative Magnitudes Sensitivity Results:")
      message("  (M-bar bounds on post-treatment trend deviation / max pre-treatment deviation)")

      honest_did_results <- as_tibble(honest_results)
      print(honest_did_results)

      # Also run for the overall ATT (average across post-periods)
      honest_avg <- tryCatch({
        HonestDiD::createSensitivityResults_relativeMagnitudes(
          betahat = betahat_ordered,
          sigma = sigma_ordered,
          numPrePeriods = n_pre,
          numPostPeriods = n_post,
          Mbarvec = c(0, 0.5, 1, 1.5, 2),
          l_vec = rep(1/n_post, n_post),  # Average across post-periods
          alpha = 0.05
        )
      }, error = function(e) {
        message(sprintf("  HonestDiD avg error: %s", e$message))
        NULL
      })

      if (!is.null(honest_avg)) {
        message("\nSensitivity for average post-treatment effect:")
        print(as_tibble(honest_avg))
        honest_did_results <- bind_rows(
          honest_did_results %>% mutate(target = "first_post"),
          as_tibble(honest_avg) %>% mutate(target = "average_post")
        )
      }
    }

  }, error = function(e) {
    message(sprintf("HonestDiD error: %s", e$message))
    message("Falling back to manual sensitivity calculation")

    # Manual fallback using proper VCV widening
    max_pre_coef <- max(abs(pre_periods$estimate))
    message(sprintf("Max pre-treatment |coefficient|: %.1f", max_pre_coef))

    honest_did_results <<- tibble(
      Mbar = c(0, 0.5, 1, 1.5, 2),
      ci_low = sapply(c(0, 0.5, 1, 1.5, 2), function(M) {
        adj_se <- sqrt(main_results$overall$se^2 + (M * max_pre_coef)^2)
        main_results$overall$att - 1.96 * adj_se
      }),
      ci_high = sapply(c(0, 0.5, 1, 1.5, 2), function(M) {
        adj_se <- sqrt(main_results$overall$se^2 + (M * max_pre_coef)^2)
        main_results$overall$att + 1.96 * adj_se
      }),
      method = "manual_fallback"
    )

    for (i in 1:nrow(honest_did_results)) {
      message(sprintf("  M = %.1f: ATT = %.1f [%.1f, %.1f]",
                      honest_did_results$Mbar[i],
                      main_results$overall$att,
                      honest_did_results$ci_low[i],
                      honest_did_results$ci_high[i]))
    }
  })

} else {
  message("Insufficient pre/post periods for HonestDiD analysis")
}

# -----------------------------------------------------------------------------
# 2. COVID Sensitivity
# -----------------------------------------------------------------------------

message("\n", paste(rep("=", 60), collapse = ""))
message("COVID-19 Sensitivity Analysis")
message(paste(rep("=", 60), collapse = ""))

# 2a. Exclude 2020-2021
message("\n--- Excluding 2020-2021 ---")

cs_nocovid <- att_gt(
  yname = "empl_7132",
  tname = "t",
  idname = "state_id",
  gname = "G",
  data = cs_data %>% filter(G >= 0, !(year %in% c(2020, 2021))),
  control_group = "notyettreated",
  anticipation = 0,
  bstrap = TRUE,
  biters = 500,
  print_details = FALSE
)

att_nocovid <- aggte(cs_nocovid, type = "simple", na.rm = TRUE)
message(sprintf("ATT (excluding 2020-2021): %.1f (SE: %.1f)",
                att_nocovid$overall.att, att_nocovid$overall.se))

# 2b. Pre-COVID cohorts only (2018-2019 adopters)
message("\n--- Pre-COVID Cohorts Only (2018-2019) ---")

pre_covid_states <- cs_data %>%
  filter(G > 0, G < 2020) %>%
  pull(state_abbr) %>%
  unique()

att_precohort <- NULL
if (length(pre_covid_states) >= 3) {
  cs_precohort <- att_gt(
    yname = "empl_7132",
    tname = "t",
    idname = "state_id",
    gname = "G",
    data = cs_data %>%
      filter(state_abbr %in% c(pre_covid_states, cs_data$state_abbr[cs_data$G == 0])) %>%
      filter(year <= 2019),
    control_group = "notyettreated",
    anticipation = 0,
    bstrap = TRUE,
    biters = 500,
    print_details = FALSE
  )

  att_precohort <- aggte(cs_precohort, type = "simple", na.rm = TRUE)
  message(sprintf("ATT (2018-2019 cohorts, pre-2020 data): %.1f (SE: %.1f)",
                  att_precohort$overall.att, att_precohort$overall.se))
}

# -----------------------------------------------------------------------------
# 3. Placebo Tests
# -----------------------------------------------------------------------------

message("\n", paste(rep("=", 60), collapse = ""))
message("Placebo Tests")
message(paste(rep("=", 60), collapse = ""))

att_mfg <- NULL
att_ag <- NULL

# Manufacturing placebo
if ("empl_mfg" %in% names(cs_data)) {
  message("\n--- Manufacturing Employment (NAICS 31-33) ---")

  cs_mfg <- tryCatch({
    att_gt(
      yname = "empl_mfg",
      tname = "t",
      idname = "state_id",
      gname = "G",
      data = cs_data %>% filter(!is.na(empl_mfg)),
      control_group = "notyettreated",
      anticipation = 0,
      bstrap = TRUE,
      biters = 500,
      print_details = FALSE
    )
  }, error = function(e) {
    message(sprintf("Manufacturing CS error: %s", e$message))
    NULL
  })

  if (!is.null(cs_mfg)) {
    att_mfg <- aggte(cs_mfg, type = "simple", na.rm = TRUE)
    message(sprintf("Manufacturing ATT: %.1f (SE: %.1f)",
                    att_mfg$overall.att, att_mfg$overall.se))
  }
}

# Agriculture placebo
if ("empl_ag" %in% names(cs_data)) {
  message("\n--- Agriculture Employment (NAICS 11) ---")

  cs_ag <- tryCatch({
    att_gt(
      yname = "empl_ag",
      tname = "t",
      idname = "state_id",
      gname = "G",
      data = cs_data %>% filter(!is.na(empl_ag)),
      control_group = "notyettreated",
      anticipation = 0,
      bstrap = TRUE,
      biters = 500,
      print_details = FALSE
    )
  }, error = function(e) {
    message(sprintf("Agriculture CS error: %s", e$message))
    NULL
  })

  if (!is.null(cs_ag)) {
    att_ag <- aggte(cs_ag, type = "simple", na.rm = TRUE)
    message(sprintf("Agriculture ATT: %.1f (SE: %.1f)",
                    att_ag$overall.att, att_ag$overall.se))
  }
}

# -----------------------------------------------------------------------------
# 4. Pre-2018 States Sensitivity
# -----------------------------------------------------------------------------

message("\n", paste(rep("=", 60), collapse = ""))
message("Pre-Murphy States Sensitivity")
message(paste(rep("=", 60), collapse = ""))

paspa_states <- c("DE", "MT", "OR")

cs_no_paspa <- att_gt(
  yname = "empl_7132",
  tname = "t",
  idname = "state_id",
  gname = "G",
  data = cs_data %>% filter(!(state_abbr %in% paspa_states)),
  control_group = "notyettreated",
  anticipation = 0,
  bstrap = TRUE,
  biters = 500,
  print_details = FALSE
)

att_no_paspa <- aggte(cs_no_paspa, type = "simple", na.rm = TRUE)
message(sprintf("ATT (excluding DE, MT, OR): %.1f (SE: %.1f)",
                att_no_paspa$overall.att, att_no_paspa$overall.se))

# -----------------------------------------------------------------------------
# 5. iGaming Control
# -----------------------------------------------------------------------------

message("\n", paste(rep("=", 60), collapse = ""))
message("iGaming Confound Analysis")
message(paste(rep("=", 60), collapse = ""))

igaming_states <- c("NJ", "PA", "MI", "WV", "CT")

# Exclude iGaming states
cs_no_igaming <- att_gt(
  yname = "empl_7132",
  tname = "t",
  idname = "state_id",
  gname = "G",
  data = cs_data %>% filter(!(state_abbr %in% igaming_states)),
  control_group = "notyettreated",
  anticipation = 0,
  bstrap = TRUE,
  biters = 500,
  print_details = FALSE
)

att_no_igaming <- aggte(cs_no_igaming, type = "simple", na.rm = TRUE)
message(sprintf("ATT (excluding iGaming states): %.1f (SE: %.1f)",
                att_no_igaming$overall.att, att_no_igaming$overall.se))

# iGaming-only states
cs_igaming_only <- tryCatch({
  att_gt(
    yname = "empl_7132",
    tname = "t",
    idname = "state_id",
    gname = "G",
    data = cs_data %>%
      filter(state_abbr %in% c(igaming_states, cs_data$state_abbr[cs_data$G == 0])),
    control_group = "notyettreated",
    anticipation = 0,
    bstrap = TRUE,
    biters = 500,
    print_details = FALSE
  )
}, error = function(e) NULL)

att_igaming_only <- NULL
if (!is.null(cs_igaming_only)) {
  att_igaming_only <- aggte(cs_igaming_only, type = "simple", na.rm = TRUE)
  message(sprintf("ATT (iGaming states only): %.1f (SE: %.1f)",
                  att_igaming_only$overall.att, att_igaming_only$overall.se))
}

# -----------------------------------------------------------------------------
# 6. Leave-One-Out Sensitivity — ALL treated states
# -----------------------------------------------------------------------------

message("\n", paste(rep("=", 60), collapse = ""))
message("Leave-One-Out State Sensitivity (ALL treated states)")
message(paste(rep("=", 60), collapse = ""))

treated_states <- cs_data %>%
  filter(G > 0) %>%
  pull(state_abbr) %>%
  unique() %>%
  sort()

message(sprintf("Running leave-one-out for all %d treated states...", length(treated_states)))

loo_results <- map_dfr(treated_states, function(drop_state) {
  tryCatch({
    cs_loo <- att_gt(
      yname = "empl_7132",
      tname = "t",
      idname = "state_id",
      gname = "G",
      data = cs_data %>% filter(state_abbr != drop_state),
      control_group = "notyettreated",
      anticipation = 0,
      bstrap = FALSE,
      print_details = FALSE
    )

    att_loo <- aggte(cs_loo, type = "simple", na.rm = TRUE)

    message(sprintf("  Dropped %s: ATT = %.1f (SE = %.1f)", drop_state,
                    att_loo$overall.att, att_loo$overall.se))

    tibble(
      dropped_state = drop_state,
      att = att_loo$overall.att,
      se = att_loo$overall.se
    )
  }, error = function(e) {
    message(sprintf("  Dropped %s: ERROR - %s", drop_state, e$message))
    tibble(dropped_state = drop_state, att = NA_real_, se = NA_real_)
  })
})

message(sprintf("\nLeave-one-out range: [%.1f, %.1f]",
                min(loo_results$att, na.rm = TRUE),
                max(loo_results$att, na.rm = TRUE)))

# Check for influential states
loo_results <- loo_results %>%
  mutate(
    z_score = (att - main_results$overall$att) / main_results$overall$se,
    influential = abs(z_score) > 1
  )

if (any(loo_results$influential, na.rm = TRUE)) {
  influential_states <- loo_results %>% filter(influential)
  message("\nInfluential states (|z| > 1):")
  print(influential_states)
} else {
  message("\nNo single state is influential (all |z| < 1)")
}

# -----------------------------------------------------------------------------
# 7. Spillover/Border Analysis (NEW in v3 — requested by all reviewers)
# -----------------------------------------------------------------------------

message("\n", paste(rep("=", 60), collapse = ""))
message("Spillover/Border Analysis")
message(paste(rep("=", 60), collapse = ""))

# Test whether neighbor legalization affects own-state employment
# TWFE: empl_7132 ~ treated + neighbor_exposure | state + year
if ("neighbor_exposure" %in% names(analysis_sample)) {

  spillover_model <- tryCatch({
    feols(
      empl_7132 ~ treated + neighbor_exposure | state_abbr + year,
      data = analysis_sample %>% filter(!is.na(neighbor_exposure)),
      cluster = ~state_abbr
    )
  }, error = function(e) {
    message(sprintf("Spillover TWFE error: %s", e$message))
    NULL
  })

  if (!is.null(spillover_model)) {
    message("\nSpillover regression (TWFE):")
    print(summary(spillover_model))

    spillover_att <- coef(spillover_model)["treated"]
    spillover_se_treated <- sqrt(vcov(spillover_model)["treated", "treated"])
    spillover_neighbor <- coef(spillover_model)["neighbor_exposure"]
    spillover_se_neighbor <- sqrt(vcov(spillover_model)["neighbor_exposure", "neighbor_exposure"])

    message(sprintf("\nOwn treatment effect: %.1f (SE: %.1f)", spillover_att, spillover_se_treated))
    message(sprintf("Neighbor exposure effect: %.1f (SE: %.1f)", spillover_neighbor, spillover_se_neighbor))
  }

  # Also test on never-treated states only (pure spillover)
  spillover_never <- tryCatch({
    feols(
      empl_7132 ~ neighbor_exposure | state_abbr + year,
      data = analysis_sample %>% filter(!ever_treated_sb, !is.na(neighbor_exposure)),
      cluster = ~state_abbr
    )
  }, error = function(e) NULL)

  if (!is.null(spillover_never)) {
    message("\nSpillover on never-treated states only:")
    print(summary(spillover_never))
  }

} else {
  message("Neighbor exposure variable not found in analysis sample")
  spillover_model <- NULL
}

# -----------------------------------------------------------------------------
# 8. Save Robustness Results
# -----------------------------------------------------------------------------

robustness_results <- list(
  main_att = main_results$overall$att,
  main_se = main_results$overall$se,
  covid_sensitivity = list(
    exclude_2020_2021 = list(att = att_nocovid$overall.att, se = att_nocovid$overall.se),
    pre_covid_cohorts = if (!is.null(att_precohort)) list(att = att_precohort$overall.att, se = att_precohort$overall.se) else NULL
  ),
  paspa_sensitivity = list(
    exclude_de_mt_or = list(att = att_no_paspa$overall.att, se = att_no_paspa$overall.se)
  ),
  igaming_sensitivity = list(
    exclude_igaming = list(att = att_no_igaming$overall.att, se = att_no_igaming$overall.se),
    igaming_only = if (!is.null(att_igaming_only)) list(att = att_igaming_only$overall.att, se = att_igaming_only$overall.se) else NULL
  ),
  placebo = list(
    manufacturing = if (!is.null(att_mfg)) list(att = att_mfg$overall.att, se = att_mfg$overall.se) else NULL,
    agriculture = if (!is.null(att_ag)) list(att = att_ag$overall.att, se = att_ag$overall.se) else NULL
  ),
  honest_did = honest_did_results,
  loo_results = loo_results,
  spillover = list(
    model = if (!is.null(spillover_model)) list(
      own_effect = coef(spillover_model)["treated"],
      own_se = sqrt(vcov(spillover_model)["treated", "treated"]),
      neighbor_effect = coef(spillover_model)["neighbor_exposure"],
      neighbor_se = sqrt(vcov(spillover_model)["neighbor_exposure", "neighbor_exposure"])
    ) else NULL
  )
)

saveRDS(robustness_results, "../data/robustness_results.rds")
write_csv(loo_results, "../data/leave_one_out.csv")

if (!is.null(honest_did_results)) {
  write_csv(honest_did_results, "../data/honest_did_results.csv")
}

message("\n", paste(rep("=", 60), collapse = ""))
message("Robustness results saved")
message(paste(rep("=", 60), collapse = ""))
