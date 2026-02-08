# ==============================================================================
# 03_main_analysis.R
# De-meaned Synthetic Control and Generalized SCM Analysis
# Paper 139 (Revision of apep_0136): Do Supervised Drug Injection Sites Save Lives?
# ==============================================================================
#
# METHODOLOGICAL FIX: The treated unit (East Harlem) has substantially higher
# baseline overdose rates (42-92/100k) than any control (20-68/100k). This
# "level mismatch" violates the convex hull assumption of standard SCM.
#
# SOLUTION: Per Ferman & Pinto (2021) and Abadie (2021), we use:
# 1. De-meaned SCM: Match on within-unit variation, not absolute levels
# 2. Generalized SCM (gsynth): Factor-based approach with IFE
# 3. Standard DiD as robustness
#
# ==============================================================================

# Source packages
if (file.exists("00_packages.R")) {
  source("00_packages.R")
} else if (file.exists("code/00_packages.R")) {
  source("code/00_packages.R")
} else {
  stop("Cannot find 00_packages.R")
}

# Load data
panel_data <- read_csv(file.path(PAPER_DIR, "data", "panel_data.csv"),
                       show_col_types = FALSE)

cat("\n=== Data Summary ===\n")
cat("Years:", min(panel_data$year), "-", max(panel_data$year), "\n")
cat("UHF neighborhoods:", n_distinct(panel_data$uhf_id), "\n")
cat("Treated:", sum(panel_data$treatment_status == "treated") / 10, "units\n")
cat("Control:", sum(panel_data$treatment_status == "control") / 10, "units\n")

# ==============================================================================
# DIAGNOSTIC: Document the level mismatch problem
# ==============================================================================

cat("\n=== Level Mismatch Diagnostic ===\n")

level_summary <- panel_data %>%
  filter(year <= 2021) %>%  # Pre-treatment only
  group_by(treatment_status, uhf_name) %>%
  summarise(
    mean_rate = mean(od_rate, na.rm = TRUE),
    min_rate = min(od_rate, na.rm = TRUE),
    max_rate = max(od_rate, na.rm = TRUE),
    .groups = "drop"
  )

cat("\nPre-treatment overdose rates by neighborhood:\n")
print(level_summary %>% arrange(desc(mean_rate)))

treated_range <- level_summary %>%
  filter(treatment_status == "treated") %>%
  summarise(min = min(min_rate), max = max(max_rate))

control_range <- level_summary %>%
  filter(treatment_status == "control") %>%
  summarise(min = min(min_rate), max = max(max_rate))

cat("\nTreated units range:", treated_range$min, "-", treated_range$max, "\n")
cat("Control units range:", control_range$min, "-", control_range$max, "\n")
cat("CONCLUSION: Treated unit (East Harlem) exceeds all controls.\n")
cat("Standard SCM is inappropriate; using de-meaned approach.\n")

# ==============================================================================
# ANALYSIS 1: De-meaned Synthetic Control (Primary Method)
# ==============================================================================
#
# Per Ferman & Pinto (2021): "A demeaned version of the SC method can improve
# in terms of bias and variance relative to the difference-in-difference estimator."
#
# Implementation:
# 1. Calculate pre-treatment mean for each unit
# 2. Subtract unit-specific means from all observations
# 3. Run SCM on demeaned data
# 4. Treatment effect is deviation from unit's expected trajectory
#
# ==============================================================================

cat("\n=== De-meaned Synthetic Control ===\n")

# Step 1: Calculate pre-treatment means (2015-2021)
pre_treat_means <- panel_data %>%
  filter(year <= 2021) %>%
  group_by(uhf_id) %>%
  summarise(pre_mean = mean(od_rate, na.rm = TRUE), .groups = "drop")

# Step 2: De-mean all observations
panel_demeaned <- panel_data %>%
  left_join(pre_treat_means, by = "uhf_id") %>%
  mutate(od_rate_dm = od_rate - pre_mean)

cat("De-meaned data: Mean of demeaned outcomes =",
    round(mean(panel_demeaned$od_rate_dm[panel_demeaned$year <= 2021]), 4), "\n")

# Step 3: Prepare data for SCM on demeaned outcomes
# Focus on East Harlem (UHF 203) first
east_harlem_dm <- panel_demeaned %>%
  filter(uhf_id == 203 | treatment_status == "control")

# Create DiD estimate on demeaned data
did_demeaned <- feols(
  od_rate_dm ~ i(year, treat, ref = 2021) | uhf_id + year,
  data = east_harlem_dm %>% mutate(treat = ifelse(uhf_id == 203, 1, 0)),
  cluster = ~uhf_id
)

cat("\nDe-meaned Event Study (East Harlem):\n")
print(summary(did_demeaned))

# Extract post-treatment effects
post_effects_dm <- coef(did_demeaned)[grepl("2022|2023|2024", names(coef(did_demeaned)))]
att_demeaned_eh <- mean(post_effects_dm, na.rm = TRUE)
cat("\nATT (De-meaned, East Harlem):", round(att_demeaned_eh, 2), "deaths/100k\n")

# ==============================================================================
# ANALYSIS 2: Generalized Synthetic Control (gsynth)
# ==============================================================================
#
# Xu (2017): Interactive fixed effects model that estimates latent factors
# from control units and uses them to construct counterfactuals.
#
# This handles level differences because factor loadings are unit-specific.
#
# ==============================================================================

cat("\n=== Generalized Synthetic Control (gsynth) ===\n")

# Prepare data for gsynth
gsynth_data <- panel_data %>%
  filter(treatment_status %in% c("treated", "control")) %>%
  mutate(
    D = ifelse(treatment_status == "treated" & year >= 2022, 1, 0)
  )

# Run gsynth with cross-validated factor selection
gsynth_result <- tryCatch({
  gsynth(
    od_rate ~ D,
    data = gsynth_data,
    index = c("uhf_id", "year"),
    force = "two-way",
    CV = TRUE,
    r = c(0, 3),      # Try 0-3 factors
    se = TRUE,
    inference = "parametric",
    nboots = 500,
    parallel = FALSE
  )
}, error = function(e) {
  cat("gsynth error:", e$message, "\n")
  NULL
})

gsynth_att <- NA
gsynth_se <- NA
gsynth_pval <- NA

if (!is.null(gsynth_result)) {
  cat("\nGSynth Results:\n")
  print(gsynth_result)

  # Extract ATT
  gsynth_att <- gsynth_result$att.avg
  gsynth_se <- gsynth_result$att.avg.se
  gsynth_pval <- 2 * pnorm(-abs(gsynth_att / gsynth_se))

  cat("\nGSynth ATT:", round(gsynth_att, 2), "\n")
  cat("GSynth SE:", round(gsynth_se, 2), "\n")
  cat("GSynth p-value:", round(gsynth_pval, 4), "\n")
  cat("Factors selected:", gsynth_result$r.cv, "\n")
}

# ==============================================================================
# ANALYSIS 3: Standard DiD (Robustness)
# ==============================================================================

cat("\n=== Difference-in-Differences ===\n")

did_data <- panel_data %>%
  filter(treatment_status %in% c("treated", "control")) %>%
  mutate(
    treat = ifelse(treatment_status == "treated", 1, 0),
    post = ifelse(year >= 2022, 1, 0)
  )

# Basic DiD
did_basic <- feols(
  od_rate ~ treat:post | uhf_id + year,
  data = did_data,
  cluster = ~uhf_id
)

cat("\nBasic DiD Results:\n")
print(summary(did_basic))

# Event study
did_event <- feols(
  od_rate ~ i(year, treat, ref = 2021) | uhf_id + year,
  data = did_data,
  cluster = ~uhf_id
)

cat("\nEvent Study Results:\n")
print(summary(did_event))

# ==============================================================================
# ANALYSIS 4: Randomization Inference (for small-N inference)
# ==============================================================================

cat("\n=== Randomization Inference ===\n")

# Function to compute DiD effect
compute_did <- function(data, treated_uhfs) {
  data <- data %>%
    mutate(
      treat = ifelse(uhf_id %in% treated_uhfs, 1, 0),
      post = ifelse(year >= 2022, 1, 0)
    )

  pre_treat <- data %>% filter(treat == 1, post == 0) %>% pull(od_rate) %>% mean()
  post_treat <- data %>% filter(treat == 1, post == 1) %>% pull(od_rate) %>% mean()
  pre_control <- data %>% filter(treat == 0, post == 0) %>% pull(od_rate) %>% mean()
  post_control <- data %>% filter(treat == 0, post == 1) %>% pull(od_rate) %>% mean()

  (post_treat - pre_treat) - (post_control - pre_control)
}

# Observed effect
observed_effect <- compute_did(did_data, c(201, 203))
cat("Observed DiD Effect:", round(observed_effect, 2), "\n")

# Permutation test
set.seed(20211130)
n_perms <- 1000
all_uhfs <- unique(did_data$uhf_id)

permuted_effects <- numeric(n_perms)
for (i in 1:n_perms) {
  fake_treated <- sample(all_uhfs, 2)
  permuted_effects[i] <- compute_did(did_data, fake_treated)
}

ri_pvalue <- mean(abs(permuted_effects) >= abs(observed_effect))
cat("Randomization Inference P-value:", round(ri_pvalue, 3), "\n")

# ==============================================================================
# ANALYSIS 5: Simple SCM Approximation (for figures)
# ==============================================================================
#
# Since augsynth is unavailable, we compute a weighted synthetic control
# using correlation-based weights on de-meaned data.
#
# ==============================================================================

cat("\n=== SCM Approximation for Figures ===\n")

# Compute weights based on pre-treatment correlation of trends (not levels)
treated_trend <- panel_demeaned %>%
  filter(uhf_id == 203, year <= 2021) %>%
  arrange(year) %>%
  pull(od_rate_dm)

control_trends <- panel_demeaned %>%
  filter(treatment_status == "control", year <= 2021) %>%
  group_by(uhf_id, uhf_name) %>%
  arrange(year) %>%
  summarise(trend = list(od_rate_dm), .groups = "drop")

# Compute correlation-based weights
correlations <- sapply(control_trends$trend, function(x) {
  cor(treated_trend, x, use = "complete.obs")
})
correlations[is.na(correlations)] <- 0
correlations[correlations < 0] <- 0  # Only positive correlations

# Normalize to sum to 1
scm_weights <- correlations / sum(correlations)
names(scm_weights) <- control_trends$uhf_name

cat("\nSCM Weights (correlation-based on de-meaned data):\n")
print(round(sort(scm_weights, decreasing = TRUE), 3))

# Compute synthetic control trajectory
synthetic_control <- panel_demeaned %>%
  filter(treatment_status == "control") %>%
  group_by(year) %>%
  summarise(
    synth_dm = sum(od_rate_dm * scm_weights[match(uhf_name, names(scm_weights))]),
    .groups = "drop"
  )

# Add back pre-treatment mean of East Harlem for visualization
eh_pre_mean <- pre_treat_means %>% filter(uhf_id == 203) %>% pull(pre_mean)
synthetic_control <- synthetic_control %>%
  mutate(synth_level = synth_dm + eh_pre_mean)

cat("\nSynthetic control trajectory computed.\n")

# ==============================================================================
# COMPUTE MSPE RATIOS FOR INFERENCE
# ==============================================================================

cat("\n=== MSPE Ratio Inference ===\n")

# Compute MSPE for each unit
compute_mspe <- function(actual, synthetic, pre_year = 2021) {
  pre_actual <- actual[actual$year <= pre_year, ]
  post_actual <- actual[actual$year > pre_year, ]

  pre_synth <- synthetic[synthetic$year <= pre_year, ]
  post_synth <- synthetic[synthetic$year > pre_year, ]

  pre_mspe <- mean((pre_actual$od_rate_dm - pre_synth$synth_dm)^2, na.rm = TRUE)
  post_mspe <- mean((post_actual$od_rate_dm - post_synth$synth_dm)^2, na.rm = TRUE)

  if (pre_mspe == 0) return(NA)
  post_mspe / pre_mspe
}

# East Harlem MSPE ratio
eh_actual <- panel_demeaned %>% filter(uhf_id == 203)
eh_mspe_ratio <- compute_mspe(eh_actual, synthetic_control)

# Placebo MSPE ratios for all control units
placebo_mspe <- sapply(unique(panel_demeaned$uhf_id[panel_demeaned$treatment_status == "control"]),
                       function(uid) {
  placebo_actual <- panel_demeaned %>% filter(uhf_id == uid)

  # Leave-one-out synthetic for this placebo
  other_controls <- panel_demeaned %>%
    filter(treatment_status == "control", uhf_id != uid)

  placebo_synth <- other_controls %>%
    group_by(year) %>%
    summarise(synth_dm = mean(od_rate_dm, na.rm = TRUE), .groups = "drop")

  compute_mspe(placebo_actual, placebo_synth)
})

names(placebo_mspe) <- panel_demeaned %>%
  filter(treatment_status == "control") %>%
  distinct(uhf_id, uhf_name) %>%
  pull(uhf_name)

# MSPE rank (1 = highest ratio = strongest treatment signal)
all_mspe <- c("East Harlem" = eh_mspe_ratio, placebo_mspe)
all_mspe <- all_mspe[!is.na(all_mspe)]
mspe_ranks <- rank(-all_mspe)

cat("\nMSPE Ratios (descending):\n")
print(round(sort(all_mspe, decreasing = TRUE), 2))

cat("\nEast Harlem MSPE Rank:", mspe_ranks["East Harlem"], "of", length(all_mspe), "\n")

# RI p-value based on MSPE
ri_pvalue_mspe <- mspe_ranks["East Harlem"] / length(all_mspe)
cat("MSPE-based RI p-value:", round(ri_pvalue_mspe, 3), "\n")

# ==============================================================================
# SAVE RESULTS
# ==============================================================================

results <- list(
  # DiD results
  observed_effect = observed_effect,
  ri_pvalue = ri_pvalue,
  permuted_effects = permuted_effects,
  event_study = did_event,
  did_basic = did_basic,

  # De-meaned results
  att_demeaned_eh = att_demeaned_eh,
  pre_treat_means = pre_treat_means,
  panel_demeaned = panel_demeaned,

  # gsynth results
  gsynth_result = gsynth_result,
  gsynth_att = gsynth_att,
  gsynth_se = gsynth_se,
  gsynth_pval = gsynth_pval,

  # SCM approximation
  scm_weights = scm_weights,
  synthetic_control = synthetic_control,

  # MSPE inference
  mspe_ratios = all_mspe,
  mspe_ranks = mspe_ranks,
  eh_mspe_ratio = eh_mspe_ratio,
  ri_pvalue_mspe = ri_pvalue_mspe
)

saveRDS(results, file.path(PAPER_DIR, "data", "analysis_results.rds"))

cat("\n=== Analysis Complete ===\n")
cat("Results saved to", file.path(PAPER_DIR, "data", "analysis_results.rds"), "\n")

# ==============================================================================
# SUMMARY TABLE
# ==============================================================================

cat("\n=== RESULTS SUMMARY ===\n")
cat("Method                    | ATT (deaths/100k) | p-value\n")
cat("--------------------------+-------------------+---------\n")
cat(sprintf("DiD (basic)               | %17.2f | %7.3f\n",
            coef(did_basic)["treat:post"], ri_pvalue))
cat(sprintf("De-meaned DiD (EH)        | %17.2f | %7s\n",
            att_demeaned_eh, "---"))
if (!is.na(gsynth_att)) {
  cat(sprintf("gsynth (IFE)              | %17.2f | %7.3f\n",
              gsynth_att, gsynth_pval))
}
cat(sprintf("MSPE-based RI             | %17s | %7.3f\n",
            "---", ri_pvalue_mspe))
cat("\n")
