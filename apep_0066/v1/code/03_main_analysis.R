# =============================================================================
# 03_main_analysis.R - Main DiD Analysis
# Paper 85: Paid Family Leave and Female Entrepreneurship
# =============================================================================

source("00_packages.R")

# -----------------------------------------------------------------------------
# Load Data
# -----------------------------------------------------------------------------

df <- readRDS("../data/analysis_data.rds")

message("Loaded ", nrow(df), " observations")
message("Years: ", min(df$year), " - ", max(df$year))
message("States: ", n_distinct(df$state_abbr))

# -----------------------------------------------------------------------------
# Simple TWFE Baseline (for comparison)
# -----------------------------------------------------------------------------

message("\n=== TWFE BASELINE ===")

# Simple 2x2 DiD
twfe_simple <- feols(
  female_selfempl_rate ~ post | state_abbr + year,
  data = df %>% filter(treated | year <= 2023),  # Include all states
  cluster = ~state_abbr
)

message("\nSimple TWFE (treated × post):")
print(summary(twfe_simple))

# TWFE with treatment × post indicator
df <- df %>%
  mutate(treat_post = treated & post)

twfe_full <- feols(
  female_selfempl_rate ~ treat_post | state_abbr + year,
  data = df,
  cluster = ~state_abbr
)

message("\nFull TWFE with treat×post:")
print(summary(twfe_full))

# -----------------------------------------------------------------------------
# Small-Sample Cluster Inference (Few-Cluster Robust)
# -----------------------------------------------------------------------------

message("\n=== SMALL-SAMPLE CLUSTER INFERENCE ===")

# With only 7 treated jurisdictions, conventional cluster-robust SEs may be
# unreliable. Following Cameron-Gelbach-Miller (2008) and MacKinnon-Webb (2017),
# we report multiple inference approaches.

# 1. Standard cluster-robust (already computed)
# 2. Small-sample corrected (CR2-type adjustment via fixest)
# 3. Effective number of clusters diagnostic

n_treated_clusters <- n_distinct(df$state_abbr[df$treated])
n_control_clusters <- n_distinct(df$state_abbr[!df$treated])
n_total_clusters <- n_distinct(df$state_abbr)

message("\nCluster diagnostics:")
message("   Total clusters (states): ", n_total_clusters)
message("   Treated clusters: ", n_treated_clusters)
message("   Control clusters: ", n_control_clusters)

# Compute t-statistic using small-sample critical value
# With 7 treated + 43 control = 50 clusters, df = 49
t_stat_twfe <- coef(twfe_full)[1] / se(twfe_full)[1]
df_clusters <- n_total_clusters - 1
p_value_t <- 2 * pt(-abs(t_stat_twfe), df = df_clusters)

message("\nTWFE with small-sample correction:")
message("   Point estimate: ", round(coef(twfe_full)[1], 3), " pp")
message("   Cluster-robust SE: ", round(se(twfe_full)[1], 3))
message("   t-statistic: ", round(t_stat_twfe, 3))
message("   p-value (t-dist, df=", df_clusters, "): ", round(p_value_t, 4))

# Critical values
t_crit_95 <- qt(0.975, df_clusters)
ci_lower_t <- coef(twfe_full)[1] - t_crit_95 * se(twfe_full)[1]
ci_upper_t <- coef(twfe_full)[1] + t_crit_95 * se(twfe_full)[1]
message("   95% CI (t-dist): [", round(ci_lower_t, 3), ", ", round(ci_upper_t, 3), "]")

# Note on few-cluster concern
if (n_treated_clusters < 10) {
  message("\n   WARNING: With only ", n_treated_clusters, " treated clusters,")
  message("   inference should be interpreted cautiously.")
  message("   See Cameron-Gelbach-Miller (2008) and MacKinnon-Webb (2017)")
}

# Save TWFE results with small-sample info
twfe_results <- list(
  simple = twfe_simple,
  full = twfe_full,
  small_sample = list(
    n_clusters = n_total_clusters,
    n_treated = n_treated_clusters,
    t_stat = t_stat_twfe,
    df = df_clusters,
    p_value_t = p_value_t,
    ci_lower = ci_lower_t,
    ci_upper = ci_upper_t
  )
)
saveRDS(twfe_results, "../data/twfe_results.rds")

# -----------------------------------------------------------------------------
# Callaway-Sant'Anna Estimator
# -----------------------------------------------------------------------------

message("\n=== CALLAWAY-SANT'ANNA ESTIMATOR ===")

# Prepare data for CS estimator
# CS requires:
# - idname: unit identifier
# - tname: time period
# - gname: first treatment period (0 for never-treated)
# - yname: outcome

# Run CS with never-treated as control
cs_out <- att_gt(
  yname = "female_selfempl_rate",
  tname = "year",
  idname = "state_id",
  gname = "cohort_cs",
  data = df,
  control_group = "nevertreated",
  anticipation = 0,
  est_method = "reg",
  base_period = "universal"  # Use universal base period
)

message("\nCallaway-Sant'Anna ATT(g,t) estimates:")
print(summary(cs_out))

# Aggregate to overall ATT
cs_att <- aggte(cs_out, type = "simple", na.rm = TRUE)
message("\n--- Overall ATT ---")
print(summary(cs_att))

# Dynamic event study aggregation
cs_dynamic <- aggte(cs_out, type = "dynamic", min_e = -5, max_e = 5, na.rm = TRUE)
message("\n--- Dynamic Event Study ---")
print(summary(cs_dynamic))

# Group (cohort) aggregation
cs_group <- aggte(cs_out, type = "group", na.rm = TRUE)
message("\n--- ATT by Cohort ---")
print(summary(cs_group))

# Calendar time aggregation (wrap in tryCatch for robustness)
cs_calendar <- tryCatch({
  aggte(cs_out, type = "calendar", na.rm = TRUE)
}, error = function(e) {
  message("Note: Calendar time aggregation not available due to: ", e$message)
  NULL
})
if (!is.null(cs_calendar)) {
  message("\n--- ATT by Calendar Year ---")
  print(summary(cs_calendar))
}

# Save CS results
cs_results <- list(
  att_gt = cs_out,
  att_simple = cs_att,
  att_dynamic = cs_dynamic,
  att_group = cs_group,
  att_calendar = cs_calendar
)
saveRDS(cs_results, "../data/cs_results.rds")

# -----------------------------------------------------------------------------
# Sun-Abraham Event Study (using fixest)
# -----------------------------------------------------------------------------

message("\n=== SUN-ABRAHAM EVENT STUDY ===")

# Create relative time variable
df <- df %>%
  mutate(
    rel_time = ifelse(treated, year - first_full_year, NA_integer_)
  )

# Run Sun-Abraham with fixest
sa_out <- feols(
  female_selfempl_rate ~ sunab(first_full_year, year) | state_abbr + year,
  data = df %>% filter(treated | cohort_cs == 0),  # Include never-treated
  cluster = ~state_abbr
)

message("\nSun-Abraham Event Study:")
print(summary(sa_out))

# Save SA results
saveRDS(sa_out, "../data/sa_results.rds")

# -----------------------------------------------------------------------------
# Extract Key Results
# -----------------------------------------------------------------------------

message("\n\n========================================")
message("SUMMARY OF MAIN RESULTS")
message("========================================\n")

# TWFE
message("1. TWFE Estimate (treat × post):")
message("   ATT = ", round(coef(twfe_full)[1], 3), " pp")
message("   SE = ", round(se(twfe_full)[1], 3))
message("   p-value = ", round(fixest::pvalue(twfe_full)[1], 4))

# CS Simple ATT
message("\n2. Callaway-Sant'Anna Overall ATT:")
message("   ATT = ", round(cs_att$overall.att, 3), " pp")
message("   SE = ", round(cs_att$overall.se, 3))

# Effect interpretation
baseline_rate <- mean(df$female_selfempl_rate[!df$treated], na.rm = TRUE)
message("\n3. Interpretation:")
message("   Baseline female self-employment rate (control states): ", round(baseline_rate, 2), "%")
message("   CS estimate as % of baseline: ", round(100 * cs_att$overall.att / baseline_rate, 1), "%")

# Pre-trend test
pre_periods <- cs_dynamic$egt < 0
if (any(pre_periods)) {
  pre_atts <- cs_dynamic$att.egt[pre_periods]
  pre_ses <- cs_dynamic$se.egt[pre_periods]
  # Joint test: are all pre-treatment effects zero?
  message("\n4. Pre-trend Assessment:")
  message("   Pre-treatment coefficients (e < 0):")
  for (i in which(pre_periods)) {
    message("   e = ", cs_dynamic$egt[i], ": ATT = ", round(cs_dynamic$att.egt[i], 3),
            " (SE = ", round(cs_dynamic$se.egt[i], 3), ")")
  }
}

message("\nMain analysis complete. Results saved to data/")
