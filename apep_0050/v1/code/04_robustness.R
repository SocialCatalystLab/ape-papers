# ============================================================================
# Paper 66: Salary Transparency Laws and Wage Outcomes
# 04_robustness.R - Robustness Checks and Sensitivity Analysis
# ============================================================================

source("code/00_packages.R")

# ============================================================================
# Load Data and Main Results
# ============================================================================

message("Loading data and main results...")
cps <- readRDS("data/cps_analysis.rds")
results <- readRDS("data/main_results.rds")
cs_att <- results$cs_att

# ============================================================================
# 1) Alternative Control Groups
# ============================================================================

message("\n=== 1) Alternative Control Groups ===")

# Prepare data
cps_did <- cps %>%
  mutate(
    id = row_number(),
    G = treatment_year
  )

# 1a) Never-treated only as control
message("Running with never-treated only...")
cs_never <- att_gt(
  yname = "log_earnweek",
  tname = "year",
  idname = "id",
  gname = "G",
  data = cps_did,
  control_group = "nevertreated",  # Never-treated only
  weightsname = "earnwt",
  clustervars = "statefip",
  bstrap = TRUE,
  biters = 500
)

overall_never <- aggte(cs_never, type = "simple")
message("Never-treated control ATT: ", round(overall_never$overall.att, 4),
        " (SE: ", round(overall_never$overall.se, 4), ")")

# ============================================================================
# 2) Exclude Early Adopter (Colorado)
# ============================================================================

message("\n=== 2) Exclude Colorado ===")

cs_noco <- att_gt(
  yname = "log_earnweek",
  tname = "year",
  idname = "id",
  gname = "G",
  data = cps_did %>% filter(statefip != 8),  # Exclude Colorado
  control_group = "notyettreated",
  weightsname = "earnwt",
  clustervars = "statefip",
  bstrap = TRUE,
  biters = 500
)

overall_noco <- aggte(cs_noco, type = "simple")
message("Excluding Colorado ATT: ", round(overall_noco$overall.att, 4),
        " (SE: ", round(overall_noco$overall.se, 4), ")")

# ============================================================================
# 3) Balanced Panel Analysis
# ============================================================================

message("\n=== 3) Balanced Panel (States with All Years) ===")

# Keep only states with observations in all years
complete_states <- cps_did %>%
  group_by(statefip) %>%
  summarise(n_years = n_distinct(year)) %>%
  filter(n_years == max(n_years)) %>%
  pull(statefip)

cs_balanced <- att_gt(
  yname = "log_earnweek",
  tname = "year",
  idname = "id",
  gname = "G",
  data = cps_did %>% filter(statefip %in% complete_states),
  control_group = "notyettreated",
  weightsname = "earnwt",
  clustervars = "statefip",
  bstrap = TRUE,
  biters = 500
)

overall_balanced <- aggte(cs_balanced, type = "simple")
message("Balanced panel ATT: ", round(overall_balanced$overall.att, 4),
        " (SE: ", round(overall_balanced$overall.se, 4), ")")

# ============================================================================
# 4) Placebo Test: Self-Employment Earnings
# ============================================================================

message("\n=== 4) Placebo Test: Self-Employed ===")

# Load raw data and select self-employed
cps_raw <- readRDS("data/cps_morg_raw.rds")

cps_selfempl <- cps_raw %>%
  filter(
    age >= 18 & age <= 64,
    # Self-employed workers
    classwkr %in% c(10, 13, 14) | classwly %in% c(10:14),
    !is.na(earnweek) & earnweek > 0
  ) %>%
  mutate(
    log_earnweek = log(earnweek),
    id = row_number()
  ) %>%
  left_join(
    cps %>% distinct(statefip, treatment_year) %>%
      mutate(treatment_year = ifelse(is.na(treatment_year), 0, treatment_year)),
    by = "statefip"
  ) %>%
  mutate(G = treatment_year)

if (nrow(cps_selfempl) > 1000) {
  cs_placebo <- att_gt(
    yname = "log_earnweek",
    tname = "year",
    idname = "id",
    gname = "G",
    data = cps_selfempl,
    control_group = "notyettreated",
    clustervars = "statefip",
    bstrap = TRUE,
    biters = 500
  )

  overall_placebo <- aggte(cs_placebo, type = "simple")
  message("Self-employed placebo ATT: ", round(overall_placebo$overall.att, 4),
          " (SE: ", round(overall_placebo$overall.se, 4), ")")
} else {
  message("Insufficient self-employed observations for placebo test")
  overall_placebo <- NULL
}

# ============================================================================
# 5) HonestDiD Sensitivity Analysis
# ============================================================================

message("\n=== 5) HonestDiD Sensitivity Analysis ===")

# Get event study coefficients for HonestDiD
es_results <- aggte(cs_att, type = "dynamic", balance_e = -4)

# Extract coefficients and variance-covariance matrix
es_coefs <- es_results$att.egt
es_se <- es_results$se.egt
event_times <- es_results$egt

# Identify pre-treatment periods
pre_indices <- which(event_times < 0)
post_indices <- which(event_times >= 0)

if (length(pre_indices) >= 2 && length(post_indices) >= 1) {
  message("Running HonestDiD sensitivity analysis...")

  # HonestDiD requires the beta vector and sigma matrix
  # Approximate sigma from SEs (diagonal)
  sigma_diag <- es_se^2
  sigma <- diag(sigma_diag)

  # Run relative magnitudes sensitivity
  tryCatch({
    honest_rm <- HonestDiD::createSensitivityResults_relativeMagnitudes(
      betahat = es_coefs,
      sigma = sigma,
      numPrePeriods = length(pre_indices),
      numPostPeriods = length(post_indices),
      Mbarvec = seq(0, 2, by = 0.5),
      l_vec = c(rep(0, length(pre_indices)), 1, rep(0, length(post_indices) - 1))
    )

    message("HonestDiD sensitivity results saved")
    saveRDS(honest_rm, "data/honest_did_results.rds")
  }, error = function(e) {
    message("HonestDiD error: ", e$message)
  })
} else {
  message("Insufficient pre/post periods for HonestDiD")
}

# ============================================================================
# 6) State-Level Controls
# ============================================================================

message("\n=== 6) With State-Level Controls ===")

# Add state-level controls (unemployment rate, minimum wage)
# These would be merged from external data - placeholder
state_controls <- cps_did %>%
  distinct(statefip, year) %>%
  mutate(
    # Placeholder: would merge actual data here
    log_minwage = rnorm(n(), mean = 2.5, sd = 0.1),  # Placeholder
    unemployment = rnorm(n(), mean = 5, sd = 1)  # Placeholder
  )

cps_controls <- cps_did %>%
  left_join(state_controls, by = c("statefip", "year"))

# Run with controls using formula interface
message("Note: Using placeholder state controls - replace with actual data")

# ============================================================================
# 7) Alternative Specifications: TWFE for Comparison
# ============================================================================

message("\n=== 7) Traditional TWFE (for comparison) ===")

# Standard TWFE (known to be biased with staggered adoption)
twfe_model <- feols(
  log_earnweek ~ treated | statefip + year,
  data = cps_did,
  weights = ~earnwt,
  cluster = ~statefip
)

message("TWFE estimate: ", round(coef(twfe_model)["treated"], 4),
        " (SE: ", round(se(twfe_model)["treated"], 4), ")")

# ============================================================================
# 8) Wild Cluster Bootstrap (Few Clusters)
# ============================================================================

message("\n=== 8) Wild Cluster Bootstrap ===")

# With 13 treated states, we should use wild cluster bootstrap
# This is already handled by did package with bstrap = TRUE

# Additional inference using fwildclusterboot
if (requireNamespace("fwildclusterboot", quietly = TRUE)) {
  library(fwildclusterboot)

  # Simple TWFE for bootstrap
  boot_result <- boottest(
    twfe_model,
    param = "treated",
    clustid = "statefip",
    B = 999,
    type = "webb"
  )

  message("Wild cluster bootstrap p-value: ", round(boot_result$p_val, 4))
  message("Wild cluster bootstrap 95% CI: [",
          round(boot_result$conf_int[1], 4), ", ",
          round(boot_result$conf_int[2], 4), "]")
}

# ============================================================================
# 9) Summary of Robustness Results
# ============================================================================

message("\n=== Robustness Summary ===")

robustness_summary <- tibble(
  Specification = c(
    "Main (not-yet-treated control)",
    "Never-treated control only",
    "Excluding Colorado",
    "Balanced panel",
    "TWFE (biased comparison)"
  ),
  ATT = c(
    results$overall_att$overall.att,
    overall_never$overall.att,
    overall_noco$overall.att,
    overall_balanced$overall.att,
    coef(twfe_model)["treated"]
  ),
  SE = c(
    results$overall_att$overall.se,
    overall_never$overall.se,
    overall_noco$overall.se,
    overall_balanced$overall.se,
    se(twfe_model)["treated"]
  )
) %>%
  mutate(
    CI_lower = ATT - 1.96 * SE,
    CI_upper = ATT + 1.96 * SE
  )

print(robustness_summary)

# Save robustness results
robustness_results <- list(
  cs_never = cs_never,
  overall_never = overall_never,
  cs_noco = cs_noco,
  overall_noco = overall_noco,
  cs_balanced = cs_balanced,
  overall_balanced = overall_balanced,
  cs_placebo = if (exists("cs_placebo")) cs_placebo else NULL,
  overall_placebo = overall_placebo,
  twfe_model = twfe_model,
  robustness_summary = robustness_summary
)

saveRDS(robustness_results, "data/robustness_results.rds")
message("\nSaved robustness results to data/robustness_results.rds")

message("\n=== Robustness Analysis Complete ===")
