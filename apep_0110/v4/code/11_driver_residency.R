# =============================================================================
# 11_driver_residency.R
# Driver Residency Analysis: Strengthening the First Stage
#
# This analysis addresses the key reviewer concern: the weak first stage.
# By using driver license state instead of crash location, we create a
# cleaner treatment definition based on habitual cannabis access.
# =============================================================================

source("00_packages.R")

# Load analysis data
crashes_analysis <- readRDS("../data/crashes_analysis.rds")

cat("Driver Residency Analysis\n")
cat("=========================\n\n")

# Check if driver license data is available
if (!("driver_license_state" %in% names(crashes_analysis)) ||
    all(is.na(crashes_analysis$driver_license_state))) {
  stop("Driver license data not available. Run 01_fetch_data.R first.")
}

# Filter to crashes with driver license data
crashes_with_license <- crashes_analysis %>%
  filter(!is.na(driver_license_state)) %>%
  filter(!is.na(driver_legal_status))

cat(sprintf("Crashes with driver license data: %d (%.1f%% of analysis sample)\n",
            nrow(crashes_with_license),
            100 * nrow(crashes_with_license) / nrow(crashes_analysis)))

# =============================================================================
# ANALYSIS 1: In-State Driver RDD
# Restrict to crashes where driver license state = crash state
# This creates a sample where treatment assignment is cleaner
# =============================================================================

cat("\n=== ANALYSIS 1: In-State Driver RDD ===\n")

instate_crashes <- crashes_with_license %>%
  filter(is_instate_driver == 1)

cat(sprintf("In-state driver crashes: %d (%.1f%% of crashes with license data)\n",
            nrow(instate_crashes),
            100 * nrow(instate_crashes) / nrow(crashes_with_license)))

# Run RDD on in-state drivers only
if (nrow(instate_crashes) >= 100) {
  rdd_instate <- rdrobust(
    y = instate_crashes$alcohol_involved,
    x = instate_crashes$running_var,
    c = 0,
    kernel = "triangular",
    p = 1,
    bwselect = "mserd"
  )

  cat("\nIn-State Driver RDD Results:\n")
  cat(sprintf("  Bandwidth: %.1f km\n", rdd_instate$bws[1]))
  cat(sprintf("  Effective N (left): %d\n", rdd_instate$N_h[1]))
  cat(sprintf("  Effective N (right): %d\n", rdd_instate$N_h[2]))
  cat(sprintf("  Point estimate: %.3f\n", rdd_instate$coef[1]))
  cat(sprintf("  Robust SE: %.3f\n", rdd_instate$se[3]))
  cat(sprintf("  Robust p-value: %.3f\n", rdd_instate$pv[3]))
  cat(sprintf("  Robust 95%% CI: [%.3f, %.3f]\n", rdd_instate$ci[3,1], rdd_instate$ci[3,2]))

  # Store results
  instate_rdd_results <- list(
    estimate = rdd_instate$coef[1],
    se = rdd_instate$se[3],
    pvalue = rdd_instate$pv[3],
    ci_lower = rdd_instate$ci[3,1],
    ci_upper = rdd_instate$ci[3,2],
    bandwidth = rdd_instate$bws[1],
    n_left = rdd_instate$N_h[1],
    n_right = rdd_instate$N_h[2],
    n_total = sum(rdd_instate$N_h)
  )
} else {
  cat("Insufficient in-state driver crashes for RDD.\n")
  instate_rdd_results <- NULL
}

# =============================================================================
# ANALYSIS 2: Driver Residence-Based Treatment
# Define treatment by driver's home state, not crash location
# A Colorado resident crashing in Wyoming is TREATED (has easy cannabis access)
# A Wyoming resident crashing in Colorado is CONTROL (faces legal risk at home)
# =============================================================================

cat("\n=== ANALYSIS 2: Driver Residence-Based Treatment ===\n")

# Create new running variable based on where driver lives
# For drivers from legal states: negative distance (treated)
# For drivers from prohibition states: positive distance (control)
# Use distance from crash location to border (but sign based on residence)

residence_rdd_data <- crashes_with_license %>%
  mutate(
    # Running variable based on driver residence, not crash location
    running_var_residence = case_when(
      driver_legal_status == "Legal" ~ -abs(running_var),     # Negative = treated
      driver_legal_status == "Prohibition" ~ abs(running_var), # Positive = control
      TRUE ~ NA_real_
    )
  ) %>%
  filter(!is.na(running_var_residence))

cat(sprintf("Crashes for residence-based analysis: %d\n", nrow(residence_rdd_data)))
cat(sprintf("  Legal-state residents: %d (%.1f%%)\n",
            sum(residence_rdd_data$driver_legal_status == "Legal"),
            100 * mean(residence_rdd_data$driver_legal_status == "Legal")))
cat(sprintf("  Prohibition-state residents: %d (%.1f%%)\n",
            sum(residence_rdd_data$driver_legal_status == "Prohibition"),
            100 * mean(residence_rdd_data$driver_legal_status == "Prohibition")))

# Run RDD with residence-based treatment
if (nrow(residence_rdd_data) >= 100) {
  rdd_residence <- rdrobust(
    y = residence_rdd_data$alcohol_involved,
    x = residence_rdd_data$running_var_residence,
    c = 0,
    kernel = "triangular",
    p = 1,
    bwselect = "mserd"
  )

  cat("\nResidence-Based RDD Results:\n")
  cat(sprintf("  Bandwidth: %.1f km\n", rdd_residence$bws[1]))
  cat(sprintf("  Effective N (legal residents): %d\n", rdd_residence$N_h[1]))
  cat(sprintf("  Effective N (prohibition residents): %d\n", rdd_residence$N_h[2]))
  cat(sprintf("  Point estimate: %.3f\n", rdd_residence$coef[1]))
  cat(sprintf("  Robust SE: %.3f\n", rdd_residence$se[3]))
  cat(sprintf("  Robust p-value: %.3f\n", rdd_residence$pv[3]))
  cat(sprintf("  Robust 95%% CI: [%.3f, %.3f]\n", rdd_residence$ci[3,1], rdd_residence$ci[3,2]))

  residence_rdd_results <- list(
    estimate = rdd_residence$coef[1],
    se = rdd_residence$se[3],
    pvalue = rdd_residence$pv[3],
    ci_lower = rdd_residence$ci[3,1],
    ci_upper = rdd_residence$ci[3,2],
    bandwidth = rdd_residence$bws[1],
    n_left = rdd_residence$N_h[1],
    n_right = rdd_residence$N_h[2],
    n_total = sum(rdd_residence$N_h)
  )
} else {
  cat("Insufficient crashes for residence-based RDD.\n")
  residence_rdd_results <- NULL
}

# =============================================================================
# ANALYSIS 3: Cross-Border Driver Comparison
# Compare alcohol involvement for cross-border vs in-state drivers
# This tests whether border-crossing behavior affects outcomes
# =============================================================================

cat("\n=== ANALYSIS 3: Cross-Border Driver Analysis ===\n")

# Classify drivers by crash/residence match
crossborder_analysis <- crashes_with_license %>%
  mutate(
    driver_type = case_when(
      is_instate_driver == 1 & legal_status == "Legal" ~ "Local legal",
      is_instate_driver == 1 & legal_status == "Prohibition" ~ "Local prohibition",
      is_crossborder_driver == 1 & driver_legal_status == "Legal" ~ "Legal resident crossing",
      is_crossborder_driver == 1 & driver_legal_status == "Prohibition" ~ "Prohib resident crossing",
      TRUE ~ NA_character_
    )
  ) %>%
  filter(!is.na(driver_type))

# Summary by driver type
crossborder_summary <- crossborder_analysis %>%
  group_by(driver_type) %>%
  summarise(
    n = n(),
    alcohol_rate = mean(alcohol_involved),
    alcohol_se = sd(alcohol_involved) / sqrt(n()),
    mean_dist = mean(abs(running_var)),
    .groups = "drop"
  ) %>%
  arrange(desc(n))

cat("\nAlcohol involvement by driver type:\n")
print(crossborder_summary)

# Key comparison: Prohibition residents who cross vs stay
prohib_comparison <- crossborder_analysis %>%
  filter(driver_legal_status == "Prohibition") %>%
  mutate(
    crossed_to_legal = as.integer(legal_status == "Legal")
  )

if (nrow(prohib_comparison) >= 50) {
  cat("\nProhibition-state residents comparison:\n")
  prohib_by_crossing <- prohib_comparison %>%
    group_by(crossed_to_legal) %>%
    summarise(
      n = n(),
      alcohol_rate = mean(alcohol_involved),
      .groups = "drop"
    )
  cat(sprintf("  Crashed in prohibition state: %.1f%% alcohol (n=%d)\n",
              100 * prohib_by_crossing$alcohol_rate[prohib_by_crossing$crossed_to_legal == 0],
              prohib_by_crossing$n[prohib_by_crossing$crossed_to_legal == 0]))
  cat(sprintf("  Crossed into legal state: %.1f%% alcohol (n=%d)\n",
              100 * prohib_by_crossing$alcohol_rate[prohib_by_crossing$crossed_to_legal == 1],
              prohib_by_crossing$n[prohib_by_crossing$crossed_to_legal == 1]))

  # T-test for difference
  t_result <- t.test(alcohol_involved ~ crossed_to_legal, data = prohib_comparison)
  cat(sprintf("  Difference: %.1f pp (p = %.3f)\n",
              100 * diff(prohib_by_crossing$alcohol_rate),
              t_result$p.value))
}

# =============================================================================
# ANALYSIS 4: First-Stage Validation with Driver Residence
# Does habitual cannabis access (measured by residence) change at the border?
# =============================================================================

cat("\n=== ANALYSIS 4: First-Stage with Driver Residence ===\n")

# For crashes near the border, does the share of legal-state residents change?
# This tests whether the "treatment" (habitual access) varies at the border

# Use original running variable (crash location) but outcome is driver residence
firststage_data <- crashes_with_license %>%
  filter(abs(running_var) <= 100)  # Within 100km of border

if (nrow(firststage_data) >= 100) {
  rdd_firststage <- rdrobust(
    y = as.numeric(firststage_data$driver_legal_status == "Legal"),
    x = firststage_data$running_var,
    c = 0,
    kernel = "triangular",
    p = 1,
    bwselect = "mserd"
  )

  cat("\nFirst-Stage RDD (Outcome = Driver from legal state):\n")
  cat(sprintf("  Bandwidth: %.1f km\n", rdd_firststage$bws[1]))
  cat(sprintf("  Effective N: %d\n", sum(rdd_firststage$N_h)))
  cat(sprintf("  Point estimate: %.3f\n", rdd_firststage$coef[1]))
  cat(sprintf("  Robust SE: %.3f\n", rdd_firststage$se[3]))
  cat(sprintf("  Robust p-value: %.3f\n", rdd_firststage$pv[3]))

  # Interpretation: positive estimate means more legal-state residents crash
  # on the legal side of the border (expected if drivers stay near home)
  if (rdd_firststage$coef[1] > 0 && rdd_firststage$pv[3] < 0.05) {
    cat("  Interpretation: Legal-state residents more likely on legal side (strong first stage)\n")
  } else if (rdd_firststage$coef[1] > 0) {
    cat("  Interpretation: Positive but insignificant first stage\n")
  } else {
    cat("  Interpretation: Weak or null first stage\n")
  }

  firststage_results <- list(
    estimate = rdd_firststage$coef[1],
    se = rdd_firststage$se[3],
    pvalue = rdd_firststage$pv[3],
    bandwidth = rdd_firststage$bws[1],
    n_total = sum(rdd_firststage$N_h)
  )
} else {
  firststage_results <- NULL
}

# =============================================================================
# ANALYSIS 5: Comparison Table - All Specifications
# =============================================================================

cat("\n=== SUMMARY: All RDD Specifications ===\n")

# Load original crash-location RDD (if available)
orig_rdd <- tryCatch({
  crashes_all <- readRDS("../data/crashes_analysis.rds")
  rdrobust(
    y = crashes_all$alcohol_involved,
    x = crashes_all$running_var,
    c = 0, kernel = "triangular", p = 1, bwselect = "mserd"
  )
}, error = function(e) NULL)

results_table <- data.frame(
  Specification = character(),
  Estimate = numeric(),
  SE = numeric(),
  PValue = numeric(),
  CI_Lower = numeric(),
  CI_Upper = numeric(),
  Bandwidth = numeric(),
  N_Effective = integer(),
  stringsAsFactors = FALSE
)

# Original specification
if (!is.null(orig_rdd)) {
  results_table <- bind_rows(results_table, data.frame(
    Specification = "Original (crash location)",
    Estimate = orig_rdd$coef[1],
    SE = orig_rdd$se[3],
    PValue = orig_rdd$pv[3],
    CI_Lower = orig_rdd$ci[3,1],
    CI_Upper = orig_rdd$ci[3,2],
    Bandwidth = orig_rdd$bws[1],
    N_Effective = sum(orig_rdd$N_h)
  ))
}

# In-state drivers only
if (!is.null(instate_rdd_results)) {
  results_table <- bind_rows(results_table, data.frame(
    Specification = "In-state drivers only",
    Estimate = instate_rdd_results$estimate,
    SE = instate_rdd_results$se,
    PValue = instate_rdd_results$pvalue,
    CI_Lower = instate_rdd_results$ci_lower,
    CI_Upper = instate_rdd_results$ci_upper,
    Bandwidth = instate_rdd_results$bandwidth,
    N_Effective = instate_rdd_results$n_total
  ))
}

# Residence-based treatment
if (!is.null(residence_rdd_results)) {
  results_table <- bind_rows(results_table, data.frame(
    Specification = "Treatment by driver residence",
    Estimate = residence_rdd_results$estimate,
    SE = residence_rdd_results$se,
    PValue = residence_rdd_results$pvalue,
    CI_Lower = residence_rdd_results$ci_lower,
    CI_Upper = residence_rdd_results$ci_upper,
    Bandwidth = residence_rdd_results$bandwidth,
    N_Effective = residence_rdd_results$n_total
  ))
}

print(results_table, digits = 3)

# =============================================================================
# Save results
# =============================================================================

driver_residency_results <- list(
  instate_rdd = instate_rdd_results,
  residence_rdd = residence_rdd_results,
  firststage = firststage_results,
  crossborder_summary = crossborder_summary,
  results_table = results_table
)

saveRDS(driver_residency_results, "../data/driver_residency_results.rds")
saveRDS(crossborder_summary, "../data/crossborder_summary.rds")

cat("\nDriver residency analysis complete. Results saved to ../data/\n")

# =============================================================================
# Generate Figure: Driver Residency Forest Plot
# =============================================================================

cat("\nGenerating driver residency comparison figure...\n")

if (nrow(results_table) >= 2) {
  # Create forest plot data
  forest_data <- results_table %>%
    mutate(
      Specification = factor(Specification, levels = rev(Specification))
    )

  p_forest <- ggplot(forest_data, aes(x = Estimate, y = Specification)) +
    geom_vline(xintercept = 0, linetype = "dashed", color = "gray50") +
    geom_errorbarh(aes(xmin = CI_Lower, xmax = CI_Upper), height = 0.2, linewidth = 0.7) +
    geom_point(aes(size = N_Effective), shape = 18, color = "#2E7D32") +
    scale_size_continuous(name = "Effective N", range = c(3, 8)) +
    labs(
      title = "RDD Estimates by Treatment Definition",
      subtitle = "Effect of legal cannabis access on alcohol involvement in fatal crashes",
      x = "Point Estimate (percentage points)",
      y = NULL,
      caption = "Notes: 95% confidence intervals shown. Positive = higher alcohol on legal side."
    ) +
    theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold"),
      axis.text.y = element_text(size = 10),
      legend.position = "bottom"
    )

  ggsave("../figures/fig08_driver_residency_forest.pdf", p_forest, width = 8, height = 5)
  cat("Saved: fig08_driver_residency_forest.pdf\n")
}

cat("\n=== Driver Residency Analysis Complete ===\n")
