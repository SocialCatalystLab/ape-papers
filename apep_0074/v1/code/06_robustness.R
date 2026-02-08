# ============================================================
# 06_robustness.R - Robustness and Sensitivity Checks
# ============================================================

source("00_packages.R")

cat("=== Robustness Checks ===\n\n")

# Load data
df <- readRDS("../data/analysis_data.rds")

# ============================================================
# 1. Not-Yet-Treated Control Group
# ============================================================

cat("=== 1. Not-Yet-Treated Controls ===\n")

cs_notyet <- att_gt(
  yname = "suicide_rate",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = df,
  control_group = "notyettreated",  # Different control group
  anticipation = 0,
  est_method = "dr",
  clustervars = "state_abbr",
  print_details = FALSE
)

agg_notyet <- aggte(cs_notyet, type = "simple")
cat("\nSimple ATT (not-yet-treated):\n")
print(summary(agg_notyet))

# ============================================================
# 2. Exclude CT and WA (main sample minus WA)
# ============================================================

cat("\n=== 2. Exclude CT and WA (Main Sample minus WA) ===\n")

# Main spec excludes CT; this also excludes WA
df_no_ct_wa <- df %>% filter(!(state_abbr %in% c("CT", "WA")))

cs_no_ct_wa <- att_gt(
  yname = "suicide_rate",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = df_no_ct_wa,
  control_group = "nevertreated",
  anticipation = 0,
  est_method = "dr",
  clustervars = "state_abbr",
  print_details = FALSE
)

agg_no_ct_wa <- aggte(cs_no_ct_wa, type = "simple")
cat("\nSimple ATT (excluding CT and WA):\n")
print(summary(agg_no_ct_wa))
cat(sprintf("N = %d, States = %d\n", nrow(df_no_ct_wa), n_distinct(df_no_ct_wa$state_abbr)))

# ============================================================
# 2b. Exclude Connecticut (contaminated pre-period)
# ============================================================

cat("\n=== 2b. Exclude Connecticut (Contaminated Pre-Period) ===\n")

df_no_ct <- df %>% filter(state_abbr != "CT")

cs_no_ct <- att_gt(
  yname = "suicide_rate",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = df_no_ct,
  control_group = "nevertreated",
  anticipation = 0,
  est_method = "dr",
  clustervars = "state_abbr",
  print_details = FALSE
)

agg_no_ct <- aggte(cs_no_ct, type = "simple")
cat("\nSimple ATT (excluding CT):\n")
print(summary(agg_no_ct))

# ============================================================
# 3. Inverse Probability Weighting (IPW) instead of DR (excl CT)
# ============================================================

cat("\n=== 3. IPW Estimation (excl CT) ===\n")

cs_ipw <- att_gt(
  yname = "suicide_rate",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = df_no_ct,  # Use CT-excluded sample to match main spec
  control_group = "nevertreated",
  anticipation = 0,
  est_method = "ipw",  # IPW instead of DR
  clustervars = "state_abbr",
  print_details = FALSE
)

agg_ipw <- aggte(cs_ipw, type = "simple")
cat("\nSimple ATT (IPW, excl CT):\n")
print(summary(agg_ipw))

# ============================================================
# 4. Outcome Regression (OR) instead of DR (excl CT)
# ============================================================

cat("\n=== 4. Outcome Regression Estimation (excl CT) ===\n")

cs_or <- att_gt(
  yname = "suicide_rate",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = df_no_ct,  # Use CT-excluded sample to match main spec
  control_group = "nevertreated",
  anticipation = 0,
  est_method = "reg",  # Outcome regression
  clustervars = "state_abbr",
  print_details = FALSE
)

agg_or <- aggte(cs_or, type = "simple")
cat("\nSimple ATT (OR, excl CT):\n")
print(summary(agg_or))

# ============================================================
# 5. Log Outcome (Semi-Elasticity) (excl CT)
# ============================================================

cat("\n=== 5. Log Outcome (excl CT) ===\n")

cs_log <- att_gt(
  yname = "log_suicide_rate",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = df_no_ct,  # Use CT-excluded sample to match main spec
  control_group = "nevertreated",
  anticipation = 0,
  est_method = "dr",
  clustervars = "state_abbr",
  print_details = FALSE
)

agg_log <- aggte(cs_log, type = "simple")
cat("\nSimple ATT (log outcome):\n")
print(summary(agg_log))

# Convert to percent
log_pct <- agg_log$overall.att * 100
log_pct_se <- agg_log$overall.se * 100
cat(sprintf("\nAs percent change: %.1f%% (SE: %.1f%%)\n", log_pct, log_pct_se))

# ============================================================
# 6. Placebo Test: Vary Treatment Timing
# ============================================================

cat("\n=== 6. Placebo: Shift Treatment 3 Years Earlier ===\n")

df_placebo <- df %>%
  mutate(
    first_treat_placebo = if_else(first_treat > 0, first_treat - 3, 0L),
    first_treat_placebo = as.integer(first_treat_placebo)
  )

cs_placebo <- tryCatch({
  att_gt(
    yname = "suicide_rate",
    tname = "year",
    idname = "state_id",
    gname = "first_treat_placebo",
    data = df_placebo,
    control_group = "nevertreated",
    anticipation = 0,
    est_method = "dr",
    clustervars = "state_abbr",
    print_details = FALSE
  )
}, error = function(e) {
  cat("Placebo test failed:", e$message, "\n")
  NULL
})

if (!is.null(cs_placebo)) {
  agg_placebo <- aggte(cs_placebo, type = "simple")
  cat("\nPlacebo ATT (treatment shifted 3 years earlier):\n")
  print(summary(agg_placebo))
}

# ============================================================
# 7. Pre-Trends F-Test
# ============================================================

cat("\n=== 7. Pre-Trends Joint Test ===\n")

results <- readRDS("../data/main_results.rds")
dyn <- results$agg_dynamic

# Extract pre-treatment coefficients and SEs
pre_df <- data.frame(
  event_time = dyn$egt,
  estimate = dyn$att.egt,
  se = dyn$se.egt
) %>%
  filter(event_time < 0, event_time >= -6)

cat("\nPre-treatment estimates (t-6 to t-1):\n")
print(pre_df)

# Simple test: are any pre-treatment CIs excluding zero?
pre_df <- pre_df %>%
  mutate(
    ci_lower = estimate - 1.96 * se,
    ci_upper = estimate + 1.96 * se,
    sig = ci_lower > 0 | ci_upper < 0
  )

cat(sprintf("\nNumber of significant pre-trends (t-6 to t-1): %d of %d\n",
            sum(pre_df$sig), nrow(pre_df)))

# ============================================================
# SAVE ROBUSTNESS RESULTS
# ============================================================

robustness <- list(
  notyet = agg_notyet,
  no_ct_wa = agg_no_ct_wa,
  no_ct = agg_no_ct,
  ipw = agg_ipw,
  or = agg_or,
  log = agg_log,
  placebo = if(!is.null(cs_placebo)) aggte(cs_placebo, type = "simple") else NULL,
  pretrends = pre_df
)

saveRDS(robustness, "../data/robustness_results.rds")

cat("\n=== Robustness Results Saved ===\n")

# ============================================================
# SUMMARY TABLE
# ============================================================

cat("\n=== ROBUSTNESS SUMMARY ===\n")
cat(sprintf("%-35s %8s %8s\n", "Specification", "ATT", "SE"))
cat(paste(rep("-", 53), collapse = ""), "\n")
cat(sprintf("%-35s %8.3f %8.3f\n", "Main (Excl CT, DR)",
            agg_no_ct$overall.att, agg_no_ct$overall.se))
cat(sprintf("%-35s %8.3f %8.3f\n", "Include Connecticut (all 4 cohorts)",
            results$agg_simple$overall.att, results$agg_simple$overall.se))
cat(sprintf("%-35s %8.3f %8.3f\n", "Not-yet-treated (control grp change)",
            agg_notyet$overall.att, agg_notyet$overall.se))
cat(sprintf("%-35s %8.3f %8.3f\n", "Exclude CT and WA (2 cohorts)",
            agg_no_ct_wa$overall.att, agg_no_ct_wa$overall.se))
cat(sprintf("%-35s %8.3f %8.3f\n", "IPW estimation (excl CT)",
            agg_ipw$overall.att, agg_ipw$overall.se))
cat(sprintf("%-35s %8.3f %8.3f\n", "Outcome regression (excl CT)",
            agg_or$overall.att, agg_or$overall.se))
cat(sprintf("%-35s %8.3f %8.3f\n", "Log outcome (excl CT)",
            agg_log$overall.att, agg_log$overall.se))
