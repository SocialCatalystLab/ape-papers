# 04_robustness.R
# Robustness checks for Promise Program analysis

source("00_packages.R")

# =============================================================================
# 1. LOAD DATA AND MAIN RESULTS
# =============================================================================

df <- readRDS("../data/clean_panel.rds")
cs_result <- readRDS("../data/cs_result.rds")
cs_aggregates <- readRDS("../data/cs_aggregates.rds")

message("Loaded main results")

# =============================================================================
# 2. ALTERNATIVE CONTROL GROUPS
# =============================================================================

message("\n=== ALTERNATIVE CONTROL GROUPS ===")

# Not-yet-treated as control
cs_data <- df %>%
  mutate(
    first_treat = ifelse(first_treat == 0, 0, first_treat),
    log_enroll = log(total_college_enrolled + 1)
  ) %>%
  filter(!is.na(log_enroll))

cs_notyet <- tryCatch({
  att_gt(
    yname = "log_enroll",
    tname = "year",
    idname = "state_id",
    gname = "first_treat",
    data = cs_data,
    control_group = "notyettreated",
    anticipation = 0,
    est_method = "dr",
    base_period = "universal",
    clustervars = "state_id",
    bstrap = TRUE,
    biters = 1000
  )
}, error = function(e) {
  message("Not-yet-treated estimation failed: ", e$message)
  NULL
})

if (!is.null(cs_notyet)) {
  att_notyet <- aggte(cs_notyet, type = "simple")
  message("Not-yet-treated ATT: ", round(att_notyet$overall.att, 4),
          " (SE: ", round(att_notyet$overall.se, 4), ")")
}

# =============================================================================
# 3. WILD CLUSTER BOOTSTRAP
# =============================================================================

message("\n=== WILD CLUSTER BOOTSTRAP ===")

# TWFE with wild cluster bootstrap
twfe_base <- feols(
  log_enroll ~ treated | state_id + year,
  data = cs_data,
  cluster = ~state_id
)

# Wild bootstrap p-value (using fwildclusterboot if available)
if (requireNamespace("fwildclusterboot", quietly = TRUE)) {
  library(fwildclusterboot)

  boot_result <- boottest(
    twfe_base,
    param = "treated",
    clustid = "state_id",
    B = 9999,
    type = "webb"  # Webb weights for few clusters
  )

  message("Wild Bootstrap p-value: ", round(boot_result$p_val, 4))
  message("Wild Bootstrap 95% CI: [", round(boot_result$conf_int[1], 4),
          ", ", round(boot_result$conf_int[2], 4), "]")

  saveRDS(boot_result, "../data/wild_bootstrap.rds")
} else {
  message("fwildclusterboot not available - skipping wild bootstrap")
}

# =============================================================================
# 4. RANDOMIZATION INFERENCE
# =============================================================================

message("\n=== RANDOMIZATION INFERENCE ===")

# Simple RI by permuting treatment across states
set.seed(42)
n_permutations <- 1000

# Get actual treatment effect
actual_effect <- coef(twfe_base)["treated"]

# Permutation distribution
ri_effects <- numeric(n_permutations)

for (i in 1:n_permutations) {
  # Permute treatment assignment across states
  perm_data <- cs_data %>%
    group_by(state_id) %>%
    mutate(
      perm_first_treat = sample(unique(cs_data$first_treat), 1)
    ) %>%
    ungroup() %>%
    mutate(
      perm_treated = perm_first_treat > 0 & year >= perm_first_treat
    )

  # Estimate effect
  perm_reg <- tryCatch({
    feols(log_enroll ~ perm_treated | state_id + year, data = perm_data)
  }, error = function(e) NULL)

  ri_effects[i] <- if (!is.null(perm_reg)) coef(perm_reg)["perm_treatedTRUE"] else NA
}

# Calculate RI p-value
ri_pvalue <- mean(abs(ri_effects) >= abs(actual_effect), na.rm = TRUE)

message("Actual effect: ", round(actual_effect, 4))
message("RI p-value (two-sided): ", round(ri_pvalue, 4))
message("RI 95% CI: [", round(quantile(ri_effects, 0.025, na.rm = TRUE), 4),
        ", ", round(quantile(ri_effects, 0.975, na.rm = TRUE), 4), "]")

# Save RI results
ri_results <- list(
  actual_effect = actual_effect,
  ri_distribution = ri_effects,
  ri_pvalue = ri_pvalue
)
saveRDS(ri_results, "../data/randomization_inference.rds")

# =============================================================================
# 5. HONESTDID SENSITIVITY ANALYSIS
# =============================================================================

message("\n=== HONESTDID SENSITIVITY ===")

if (requireNamespace("HonestDiD", quietly = TRUE)) {
  library(HonestDiD)

  # Get event study estimates
  att_dynamic <- cs_aggregates$dynamic

  # Extract coefficients and variance-covariance matrix
  # HonestDiD requires specific format
  tryCatch({
    # Run sensitivity analysis
    honest_results <- honest_did(
      es = att_dynamic,
      type = "smoothness",
      Mvec = seq(0, 0.5, by = 0.1)  # Range of M (violation magnitude)
    )

    message("HonestDiD bounds computed")
    saveRDS(honest_results, "../data/honestdid_results.rds")
  }, error = function(e) {
    message("HonestDiD failed: ", e$message)
  })
} else {
  message("HonestDiD not available")
}

# =============================================================================
# 6. PLACEBO TESTS
# =============================================================================

message("\n=== PLACEBO TESTS ===")

# Placebo 1: Pre-treatment pseudo-treatment (shift treatment back 3 years)
placebo_data <- cs_data %>%
  mutate(
    placebo_treat = ifelse(first_treat > 0, first_treat - 3, 0),
    placebo_treated = placebo_treat > 0 & year >= placebo_treat & year < first_treat
  )

placebo_reg <- feols(
  log_enroll ~ placebo_treated | state_id + year,
  data = placebo_data %>% filter(first_treat == 0 | year < first_treat),
  cluster = ~state_id
)

message("Placebo (pre-treatment) effect: ", round(coef(placebo_reg)["placebo_treatedTRUE"], 4),
        " (SE: ", round(se(placebo_reg)["placebo_treatedTRUE"], 4), ")")

# =============================================================================
# 7. STATE TRENDS
# =============================================================================

message("\n=== STATE-SPECIFIC TRENDS ===")

# Add state-specific linear trends
twfe_trends <- feols(
  log_enroll ~ treated | state_id[year] + year,
  data = cs_data,
  cluster = ~state_id
)

message("TWFE with state trends: ", round(coef(twfe_trends)["treated"], 4),
        " (SE: ", round(se(twfe_trends)["treated"], 4), ")")

# =============================================================================
# 8. COMPILE ROBUSTNESS TABLE
# =============================================================================

robustness_table <- tribble(
  ~Specification, ~Estimate, ~SE, ~Pvalue, ~Notes,
  "Main (CS DiD, never-treated)", cs_aggregates$overall$overall.att,
    cs_aggregates$overall$overall.se, NA, "Baseline",
  "CS DiD (not-yet-treated)", if(!is.null(cs_notyet)) att_notyet$overall.att else NA,
    if(!is.null(cs_notyet)) att_notyet$overall.se else NA, NA, "Alternative control",
  "TWFE", coef(twfe_base)["treated"], se(twfe_base)["treated"],
    pvalue(twfe_base)["treated"], "Standard estimator",
  "TWFE + state trends", coef(twfe_trends)["treated"], se(twfe_trends)["treated"],
    pvalue(twfe_trends)["treated"], "State-specific trends",
  "Randomization Inference", actual_effect, NA, ri_pvalue, "Permutation test",
  "Placebo (pre-treatment)", coef(placebo_reg)["placebo_treatedTRUE"],
    se(placebo_reg)["placebo_treatedTRUE"],
    pvalue(placebo_reg)["placebo_treatedTRUE"], "Should be zero"
) %>%
  mutate(across(where(is.numeric), ~round(.x, 4)))

write_csv(robustness_table, "../tables/robustness_table.csv")

message("\n=== ROBUSTNESS RESULTS SAVED ===")
message("Robustness table: ../tables/robustness_table.csv")
