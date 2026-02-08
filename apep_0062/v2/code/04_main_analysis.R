# =============================================================================
# 04_main_analysis.R
# Main difference-in-differences analysis using Callaway-Sant'Anna
# ANNUAL data version
# =============================================================================

source("output/paper_84/code/00_packages.R")

# =============================================================================
# Load cleaned data
# =============================================================================

df <- read_csv("output/paper_84/data/analysis_panel.csv", show_col_types = FALSE)

cat("Analysis sample:\n")
cat(sprintf("  Observations: %d\n", nrow(df)))
cat(sprintf("  States: %d\n", n_distinct(df$state_fips)))
cat(sprintf("  Years: %d\n", n_distinct(df$year)))
cat(sprintf("  Treated states: %d\n", n_distinct(df$state_fips[df$G > 0])))
cat(sprintf("  Never-treated states: %d\n", n_distinct(df$state_fips[df$G == 0])))

# =============================================================================
# Prepare data for did package
# =============================================================================

# did package requires:
# - idname: panel unit identifier (state)
# - tname: time period (year)
# - gname: treatment cohort (first treated year, 0 for never-treated)
# - yname: outcome

# Ensure numeric state_id
df <- df %>%
  mutate(state_id = as.integer(factor(state_fips)))

# Check for missing employment values
cat(sprintf("\nMissing employment values: %d (%.1f%%)\n",
            sum(is.na(df$employment)), 100 * mean(is.na(df$employment))))

# For did package, we need non-missing outcomes
# Drop observations with missing employment
df_clean <- df %>%
  filter(!is.na(employment), employment > 0)

cat(sprintf("After dropping missing/zero: %d observations\n", nrow(df_clean)))

cat("\n=== Callaway-Sant'Anna Estimation ===\n\n")

# =============================================================================
# 1. Main specification: Never-treated controls
# =============================================================================

cat("Estimating ATT(g,t) with never-treated controls...\n")

cs_never <- att_gt(
  yname = "employment",
  tname = "year",
  idname = "state_id",
  gname = "G",
  data = df_clean,
  control_group = "nevertreated",
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000,
  base_period = "varying"  # Use g-1 as base period
)

# Summary
cat("\nGroup-time ATT summary:\n")
summary(cs_never)

# =============================================================================
# 2. Aggregate to overall ATT
# =============================================================================

cat("\n\n=== Overall ATT ===\n")

agg_overall <- aggte(cs_never, type = "simple")
summary(agg_overall)

# Store for later
overall_att <- agg_overall$overall.att
overall_se <- agg_overall$overall.se
overall_ci <- c(overall_att - 1.96 * overall_se, overall_att + 1.96 * overall_se)

cat(sprintf("\nOverall ATT: %.1f (SE = %.1f)\n", overall_att, overall_se))
cat(sprintf("95%% CI: [%.1f, %.1f]\n", overall_ci[1], overall_ci[2]))
cat(sprintf("p-value: %.3f\n", 2 * pnorm(-abs(overall_att / overall_se))))

# =============================================================================
# 3. Event study aggregation
# =============================================================================

cat("\n\n=== Event Study ===\n")

agg_es <- aggte(cs_never, type = "dynamic", min_e = -4, max_e = 5)
summary(agg_es)

# Extract coefficients
es_coefs <- tibble(
  event_time = agg_es$egt,
  att = agg_es$att.egt,
  se = agg_es$se.egt,
  ci_lower = att - 1.96 * se,
  ci_upper = att + 1.96 * se
)

cat("\nEvent study coefficients:\n")
print(es_coefs)

# Pre-trend test
pre_coefs <- es_coefs %>% filter(event_time < 0)
if (nrow(pre_coefs) > 0) {
  # Wald test of joint significance
  pre_att <- pre_coefs$att
  pre_se <- pre_coefs$se
  # Simple chi-squared test (assuming independence for approximation)
  chi2_stat <- sum((pre_att / pre_se)^2)
  df_test <- length(pre_att)
  p_pretrend <- pchisq(chi2_stat, df = df_test, lower.tail = FALSE)
  cat(sprintf("\nPre-trend test: chi2(%d) = %.2f, p = %.3f\n",
              df_test, chi2_stat, p_pretrend))
}

# =============================================================================
# 4. Group-specific ATT
# =============================================================================

cat("\n\n=== Group-specific ATT ===\n")

agg_group <- aggte(cs_never, type = "group")
summary(agg_group)

# =============================================================================
# 5. TWFE comparison
# =============================================================================

cat("\n\n=== TWFE Comparison ===\n")

twfe <- feols(employment ~ treated | state_id + year, data = df_clean,
              cluster = ~state_id)
cat("\nTWFE estimate (for comparison):\n")
print(summary(twfe))

twfe_att <- coef(twfe)["treated"]
twfe_se <- sqrt(vcov(twfe)["treated", "treated"])

cat(sprintf("\nTWFE ATT: %.1f (SE = %.1f)\n", twfe_att, twfe_se))
cat(sprintf("Note: TWFE may be biased under treatment effect heterogeneity\n"))

# =============================================================================
# Save results
# =============================================================================

cat("\n\n=== Saving Results ===\n")

# Save main results object
saveRDS(cs_never, "output/paper_84/data/main_results.rds")

# Save event study coefficients
write_csv(es_coefs, "output/paper_84/data/event_study_coefs.csv")

# Save summary statistics
results_summary <- tibble(
  estimator = c("Callaway-Sant'Anna", "TWFE"),
  att = c(overall_att, twfe_att),
  se = c(overall_se, twfe_se),
  ci_lower = c(overall_ci[1], twfe_att - 1.96 * twfe_se),
  ci_upper = c(overall_ci[2], twfe_att + 1.96 * twfe_se),
  p_value = c(2 * pnorm(-abs(overall_att / overall_se)),
              2 * pnorm(-abs(twfe_att / twfe_se))),
  n_obs = nrow(df_clean)
)

write_csv(results_summary, "output/paper_84/data/main_results_summary.csv")

cat("\nResults saved:\n")
cat("  - main_results.rds (CS object)\n")
cat("  - event_study_coefs.csv\n")
cat("  - main_results_summary.csv\n")

# =============================================================================
# Key findings summary
# =============================================================================

cat("\n\n========================================\n")
cat("KEY FINDINGS\n")
cat("========================================\n")
cat(sprintf("\nOverall ATT (Callaway-Sant'Anna): %.1f jobs\n", overall_att))
cat(sprintf("  Standard Error: %.1f\n", overall_se))
cat(sprintf("  95%% CI: [%.1f, %.1f]\n", overall_ci[1], overall_ci[2]))
cat(sprintf("  p-value: %.3f\n", 2 * pnorm(-abs(overall_att / overall_se))))

if (exists("p_pretrend")) {
  cat(sprintf("\nPre-trend test p-value: %.3f\n", p_pretrend))
  if (p_pretrend > 0.05) {
    cat("  -> Fails to reject parallel trends (good)\n")
  } else {
    cat("  -> Warning: Evidence against parallel trends\n")
  }
}

cat(sprintf("\nTWFE comparison: %.1f (SE = %.1f)\n", twfe_att, twfe_se))

if (abs(overall_att / overall_se) < 1.96) {
  cat("\n*** RESULT: NO SIGNIFICANT EMPLOYMENT EFFECT ***\n")
} else {
  cat("\n*** RESULT: SIGNIFICANT EMPLOYMENT EFFECT ***\n")
}

cat("========================================\n")
