# =============================================================================
# 04_main_analysis.R
# Callaway-Sant'Anna Difference-in-Differences Analysis
# Paper 117: Sports Betting Employment Effects
# =============================================================================

source("00_packages.R")

# =============================================================================
# Load Analysis Data
# =============================================================================

message("Loading analysis data...")
analysis_df <- read_csv("../data/analysis_sample.csv", show_col_types = FALSE)
cs_data <- read_csv("../data/cs_analysis_data.csv", show_col_types = FALSE)

message(sprintf("  Analysis sample: %d observations", nrow(analysis_df)))
message(sprintf("  Treated cohorts: %s", paste(sort(unique(cs_data$g[cs_data$g > 0])), collapse = ", ")))

# =============================================================================
# Main Specification: Callaway-Sant'Anna
# =============================================================================

message("\n", paste(rep("=", 70), collapse = ""))
message("CALLAWAY-SANT'ANNA DIFFERENCE-IN-DIFFERENCES")
message(paste(rep("=", 70), collapse = ""), "\n")

# Estimate group-time ATTs
cs_result <- att_gt(
  yname = "log_employment",
  tname = "year",
  idname = "state_id",
  gname = "g",
  data = cs_data,
  control_group = "notyettreated",  # Use not-yet-treated as controls
  anticipation = 0,
  est_method = "dr",                # Doubly robust
  base_period = "varying"           # Use period before treatment for each group
)

message("\nGroup-Time ATT Estimates:")
summary(cs_result)

# Aggregate to overall ATT
cs_overall <- aggte(cs_result, type = "simple")
message("\nOverall ATT (Simple Average):")
summary(cs_overall)

# Event study aggregation
cs_event <- aggte(cs_result, type = "dynamic", min_e = -6, max_e = 5)
message("\nEvent Study (Dynamic Aggregation):")
summary(cs_event)

# Calendar time aggregation
cs_calendar <- aggte(cs_result, type = "calendar")
message("\nCalendar Time ATT:")
summary(cs_calendar)

# Group (cohort) aggregation
cs_group <- aggte(cs_result, type = "group")
message("\nCohort-Specific ATT:")
summary(cs_group)

# =============================================================================
# Alternative Control Group: Never-Treated Only
# =============================================================================

message("\n", paste(rep("=", 70), collapse = ""))
message("ROBUSTNESS: NEVER-TREATED CONTROL GROUP")
message(paste(rep("=", 70), collapse = ""), "\n")

cs_nevertreated <- att_gt(
  yname = "log_employment",
  tname = "year",
  idname = "state_id",
  gname = "g",
  data = cs_data,
  control_group = "nevertreated",
  anticipation = 0,
  est_method = "dr",
  base_period = "varying"
)

cs_nevertreated_overall <- aggte(cs_nevertreated, type = "simple")
message("Overall ATT (Never-Treated Controls):")
summary(cs_nevertreated_overall)

# =============================================================================
# TWFE Comparison (Potentially Biased)
# =============================================================================

message("\n", paste(rep("=", 70), collapse = ""))
message("COMPARISON: TWO-WAY FIXED EFFECTS (TWFE)")
message(paste(rep("=", 70), collapse = ""), "\n")

# Standard TWFE (for comparison - known to be biased with staggered adoption)
twfe_result <- feols(
  log_employment ~ treated_sb | state_id + year,
  data = analysis_df,
  cluster = ~state_id
)

message("TWFE Estimate (potentially biased with staggered adoption):")
summary(twfe_result)

# =============================================================================
# Pre-Trends Test
# =============================================================================

message("\n", paste(rep("=", 70), collapse = ""))
message("PRE-TRENDS TEST")
message(paste(rep("=", 70), collapse = ""), "\n")

# Extract pre-treatment event study coefficients
event_coefs <- data.frame(
  event_time = cs_event$egt,
  att = cs_event$att.egt,
  se = cs_event$se.egt
) %>%
  mutate(
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se
  )

# Pre-treatment coefficients
pre_coefs <- event_coefs %>% filter(event_time < 0)

message("Pre-treatment event study coefficients:")
print(pre_coefs)

# Joint test of pre-trends (F-test)
if (nrow(pre_coefs) > 0) {
  # Wald test: H0: all pre-treatment ATTs = 0
  pre_chi2 <- sum((pre_coefs$att / pre_coefs$se)^2)
  pre_df <- nrow(pre_coefs)
  pre_pvalue <- 1 - pchisq(pre_chi2, df = pre_df)

  message(sprintf("\nJoint test of pre-trends:"))
  message(sprintf("  Chi-squared(%d) = %.2f", pre_df, pre_chi2))
  message(sprintf("  p-value = %.4f", pre_pvalue))

  if (pre_pvalue > 0.05) {
    message("  --> Cannot reject parallel trends (p > 0.05)")
  } else {
    message("  --> WARNING: Potential violation of parallel trends (p < 0.05)")
  }
}

# =============================================================================
# Save Results
# =============================================================================

message("\n", paste(rep("=", 70), collapse = ""))
message("SAVING RESULTS")
message(paste(rep("=", 70), collapse = ""), "\n")

# Save main results
main_results <- list(
  cs_result = cs_result,
  cs_overall = cs_overall,
  cs_event = cs_event,
  cs_nevertreated = cs_nevertreated,
  twfe_result = twfe_result
)

saveRDS(main_results, "../data/main_results.rds")
message("Saved: ../data/main_results.rds")

# Save event study coefficients for plotting
write_csv(event_coefs, "../data/event_study_coefficients.csv")
message("Saved: ../data/event_study_coefficients.csv")

# Print key findings
message("\n", paste(rep("=", 70), collapse = ""))
message("KEY FINDINGS")
message(paste(rep("=", 70), collapse = ""), "\n")

att_estimate <- cs_overall$overall.att
att_se <- cs_overall$overall.se

message(sprintf("Overall ATT: %.4f (SE = %.4f)", att_estimate, att_se))
message(sprintf("95%% CI: [%.4f, %.4f]", att_estimate - 1.96*att_se, att_estimate + 1.96*att_se))

# Convert to percentage change
pct_change <- (exp(att_estimate) - 1) * 100
message(sprintf("Interpretation: Sports betting legalization associated with"))
message(sprintf("  %.1f%% change in gambling employment", pct_change))

message("\n", paste(rep("=", 70), collapse = ""))
message("MAIN ANALYSIS COMPLETE")
message(paste(rep("=", 70), collapse = ""))
