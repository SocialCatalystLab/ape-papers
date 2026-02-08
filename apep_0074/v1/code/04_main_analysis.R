# ============================================================
# 04_main_analysis.R - Callaway-Sant'Anna DiD Analysis
# ============================================================

source("00_packages.R")

cat("=== Main Analysis: Callaway-Sant'Anna DiD ===\n\n")

# Load analysis data
df <- readRDS("../data/analysis_data.rds")

# Verify data structure
cat("Data dimensions:", nrow(df), "x", ncol(df), "\n")
cat("Unique states:", n_distinct(df$state_abbr), "\n")
cat("Years:", min(df$year), "-", max(df$year), "\n")
cat("Treatment groups (first_treat):", sort(unique(df$first_treat)), "\n\n")

# ============================================================
# 1. CALLAWAY-SANT'ANNA ESTIMATION
# ============================================================

cat("=== Callaway-Sant'Anna Estimation ===\n\n")

# Main specification: ATT(g,t) using never-treated as control
# Note: Connecticut is EXCLUDED from main spec because it has no clean pre-period
# (law took effect Oct 1999, sample starts 1999). This yields 3 treated cohorts:
#   - first_treat = 2006 (Indiana only)
#   - first_treat = 2016 (California only)
#   - first_treat = 2017 (Washington only)
#   - first_treat = 0 (never treated by 2019)

# Exclude Connecticut (contaminated pre-period)
df_main <- df %>% filter(state_abbr != "CT")
cat("Main spec sample: N =", nrow(df_main), ", States =", n_distinct(df_main$state_abbr), "\n\n")

cs_result <- att_gt(
  yname = "suicide_rate",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = df_main,                    # Exclude CT from main spec
  control_group = "nevertreated",    # Use never-treated as controls
  anticipation = 0,                  # No anticipation effects
  est_method = "dr",                 # Doubly-robust estimation
  clustervars = "state_abbr",        # Cluster SEs at state level
  print_details = FALSE
)

# Print group-time ATTs
cat("Group-Time Average Treatment Effects:\n")
print(summary(cs_result))

# ============================================================
# 2. AGGREGATE TO OVERALL ATT
# ============================================================

cat("\n=== Aggregate ATT ===\n")

# Overall ATT (simple average across post-treatment)
agg_simple <- aggte(cs_result, type = "simple")
cat("\nSimple ATT (unweighted average):\n")
print(summary(agg_simple))

# Dynamic aggregation (event study)
agg_dynamic <- aggte(cs_result, type = "dynamic")
cat("\nDynamic ATT (event study):\n")
print(summary(agg_dynamic))

# Group-specific effects
agg_group <- aggte(cs_result, type = "group")
cat("\nGroup-specific ATT:\n")
print(summary(agg_group))

# ============================================================
# 3. TWFE COMPARISON (Biased under heterogeneity)
# ============================================================

cat("\n=== TWFE Comparison (For Reference) ===\n")

# TWFE on full sample (all 51 states)
twfe_full <- feols(suicide_rate ~ treated | state_id + year,
              data = df,
              cluster = ~state_abbr)

# TWFE on CT-excluded sample (50 states) - same sample as main C-S spec
df_no_ct <- df %>% filter(state_abbr != "CT")
twfe <- feols(suicide_rate ~ treated | state_id + year,
              data = df_no_ct,
              cluster = ~state_abbr)

cat("\nTWFE Results:\n")
print(summary(twfe))

# ============================================================
# 4. SAVE RESULTS
# ============================================================

results <- list(
  cs_result = cs_result,
  agg_simple = agg_simple,
  agg_dynamic = agg_dynamic,
  agg_group = agg_group,
  twfe = twfe
)

saveRDS(results, "../data/main_results.rds")

cat("\n=== Results Saved ===\n")
cat("File: data/main_results.rds\n")

# ============================================================
# 5. KEY ESTIMATES FOR PAPER
# ============================================================

cat("\n=== KEY ESTIMATES FOR PAPER ===\n")

# Simple ATT
simple_est <- agg_simple$overall.att
simple_se <- agg_simple$overall.se
cat(sprintf("\nSimple ATT: %.3f (SE: %.3f)\n", simple_est, simple_se))
cat(sprintf("95%% CI: [%.3f, %.3f]\n",
            simple_est - 1.96*simple_se,
            simple_est + 1.96*simple_se))

# As percentage of mean suicide rate
mean_rate <- mean(df$suicide_rate, na.rm = TRUE)
pct_effect <- (simple_est / mean_rate) * 100
cat(sprintf("\nAs %% of mean suicide rate (%.1f): %.1f%%\n",
            mean_rate, pct_effect))

# TWFE comparison
cat(sprintf("\nTWFE estimate: %.3f (SE: %.3f)\n",
            coef(twfe)["treated"],
            se(twfe)["treated"]))

cat("\n=== INTERPRETATION NOTES ===\n")
cat("1. Negative ATT = ERPO reduces suicide rate (intended effect)\n")
cat("2. Positive ATT = ERPO associated with higher suicide rate\n")
cat("3. Outcome is TOTAL suicide, not firearm-specific\n")
cat("4. Effect is likely attenuated vs firearm suicide\n")
