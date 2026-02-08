# =============================================================================
# Modern DiD Methods - Proper Implementation
# Following Sant'Anna's DiD resources: https://psantanna.com/did-resources/
#
# Methods implemented:
# 1. Callaway-Sant'Anna (2021) - with panel=FALSE for repeated cross-sections
# 2. Gardner (2022) two-stage DiD via did2s
# 3. Borusyak-Jaravel-Spiess (2024) imputation via didimputation
# 4. Stacked DiD (manual implementation)
# =============================================================================

library(tidyverse)
library(fixest)
library(did)           # Callaway-Sant'Anna
library(data.table)
library(haven)

# Install packages if needed
if (!require("did2s")) {
  install.packages("did2s")
  library(did2s)
}
if (!require("didimputation")) {
  devtools::install_github("kylebutts/didimputation")
  library(didimputation)
}

cat("=============================================================================\n")
cat("MODERN DiD METHODS - PROPER IMPLEMENTATION\n")
cat("=============================================================================\n\n")

# -----------------------------------------------------------------------------
# 1. LOAD AND PREPARE DATA
# -----------------------------------------------------------------------------

data_dir <- "../data"
df <- readRDS(file.path(data_dir, "analysis_data.rds"))
df <- zap_labels(df)
df <- as.data.table(df)
df <- df[YEAR >= 2010 & YEAR < 2024]

cat("Data loaded:", nrow(df), "observations\n")
cat("Years:", min(df$YEAR), "-", max(df$YEAR), "\n\n")

# Create clean variables
df[, year := as.integer(YEAR)]
df[, month := as.integer(MONTH)]
df[, statefip := as.integer(STATEFIP)]
df[, treated := as.integer(mw_above_federal)]

# Create year-month time variable (for did package)
df[, time := year * 12 + month]

# Create a pseudo-ID for repeated cross-sections (just row number)
df[, id := .I]

# -----------------------------------------------------------------------------
# 2. IDENTIFY TREATMENT TIMING
# -----------------------------------------------------------------------------

# First identify which states are truly never-treated (no treated observations at all)
state_treatment_status <- df[, .(
  n_treated = sum(treated == 1),
  n_control = sum(treated == 0)
), by = statefip]

never_treated_states <- state_treatment_status[n_treated == 0, statefip]
cat("Truly never-treated states:", length(never_treated_states), "\n")

# For states with some treatment, find first treated YEAR
treated_obs <- df[treated == 1]
first_treat_by_state <- treated_obs[, .(first_treat_year = min(year)), by = statefip]

# Merge back
df <- merge(df, first_treat_by_state, by = "statefip", all.x = TRUE)

# For never-treated: set to 0 (Callaway-Sant'Anna convention)
df[statefip %in% never_treated_states, first_treat_year := 0]

# Classify states properly
df[, state_type := fcase(
  first_treat_year == 0, "never_treated",
  first_treat_year == 2010, "always_treated",  # Treated from start of sample
  default = "switcher"  # Switch after 2010
)]

cat("\n=== STATE CLASSIFICATION ===\n")
cat("Never-treated (g=0):", uniqueN(df[state_type == "never_treated", statefip]), "states\n")
cat("Always-treated (from 2010):", uniqueN(df[state_type == "always_treated", statefip]), "states\n")
cat("True switchers (after 2010):", uniqueN(df[state_type == "switcher", statefip]), "states\n\n")

# Show switcher details
switcher_info <- df[state_type == "switcher", .(
  first_treat_year = first(first_treat_year),
  n_obs = .N
), by = statefip][order(first_treat_year)]
cat("Switcher states (after 2010):\n")
print(switcher_info)
cat("\n")

# -----------------------------------------------------------------------------
# 3. PREPARE DATA FOR MODERN DiD
# -----------------------------------------------------------------------------

# For Callaway-Sant'Anna and others, we need:
# - Never-treated and TRUE switchers only (exclude always-treated for clean identification)
# - Always-treated states have no pre-treatment period, so CS cannot use them

df_clean <- df[state_type %in% c("never_treated", "switcher")]
cat("\nClean sample (never-treated + true switchers):", nrow(df_clean), "observations\n")
cat("States:", uniqueN(df_clean$statefip), "\n")
cat("  Never-treated:", uniqueN(df_clean[state_type == "never_treated", statefip]), "\n")
cat("  Switchers:", uniqueN(df_clean[state_type == "switcher", statefip]), "\n\n")

# For annual analysis (more stable than monthly with ATUS sample sizes)
df_annual <- df_clean[!is.na(work_time) & !is.na(weight), .(
  work_time = weighted.mean(work_time, w = weight, na.rm = TRUE),
  any_work = weighted.mean(work_time > 0, w = weight, na.rm = TRUE),
  n_obs = .N,
  first_treat_year = first(first_treat_year),
  state_type = first(state_type)
), by = .(statefip, year)]

# For Callaway-Sant'Anna: gname = 0 for never-treated, = first treatment year otherwise
df_annual[, g := fifelse(state_type == "never_treated", 0L, as.integer(first_treat_year))]

cat("Annual panel:", nrow(df_annual), "state-years\n")
cat("Treatment cohorts (g values):\n")
print(table(df_annual$g))
cat("\nNever-treated state-years (g=0):", sum(df_annual$g == 0), "\n")
cat("Switcher state-years (g>0):", sum(df_annual$g > 0), "\n\n")

# =============================================================================
# METHOD 1: CALLAWAY-SANT'ANNA (2021)
# =============================================================================

cat("\n=============================================================================\n")
cat("METHOD 1: CALLAWAY-SANT'ANNA (2021)\n")
cat("=============================================================================\n\n")

# Note: ATUS is repeated cross-sections, not panel
# But when aggregated to state-year, it becomes a balanced panel

# Ensure g is properly coded as integer with 0 for never-treated
df_annual[, g := as.integer(g)]
df_annual[is.na(g), g := 0L]

cat("Checking g values before CS:\n")
cat("  g=0 (never-treated):", sum(df_annual$g == 0), "obs\n")
cat("  g>0 (switchers):", sum(df_annual$g > 0), "obs\n")
cat("  g values:", paste(sort(unique(df_annual$g)), collapse = ", "), "\n\n")

# CS has numerical issues with very small cohorts (2011 has 1 state, 2012 has 1 state)
# Filter to cohorts with at least 2 states
cohort_state_counts <- df_annual[g > 0, .(n_states = uniqueN(statefip)), by = g]
cat("States per cohort:\n")
print(cohort_state_counts)

# Keep cohorts with >= 2 states
valid_cohorts <- cohort_state_counts[n_states >= 2, g]
cat("\nValid cohorts (>=2 states):", paste(valid_cohorts, collapse = ", "), "\n")

# Create CS-specific dataset
df_cs <- df_annual[g == 0 | g %in% valid_cohorts]
# Recode small cohorts to never-treated
df_cs[!(g == 0 | g %in% valid_cohorts), g := 0L]

cat("CS sample:", nrow(df_cs), "state-years,", uniqueN(df_cs$statefip), "states\n")
cat("CS treatment cohorts:\n")
print(table(df_cs$g))

cs_result <- tryCatch({
  att_gt(
    yname = "work_time",
    tname = "year",
    idname = "statefip",
    gname = "g",
    data = as.data.frame(df_cs),
    control_group = "nevertreated",
    anticipation = 0,
    base_period = "universal",
    bstrap = FALSE,
    allow_unbalanced_panel = TRUE
  )
}, error = function(e) {
  cat("CS estimation error:", e$message, "\n")
  NULL
})

if (!is.null(cs_result)) {
  cat("\n--- Group-Time ATTs ---\n")
  print(summary(cs_result))

  # Aggregate to simple ATT
  cs_simple <- aggte(cs_result, type = "simple")
  cat("\n--- Simple Aggregation (Overall ATT) ---\n")
  print(summary(cs_simple))

  # Dynamic effects (event study)
  cs_dynamic <- tryCatch({
    aggte(cs_result, type = "dynamic", min_e = -5, max_e = 8)
  }, error = function(e) NULL)

  if (!is.null(cs_dynamic)) {
    cat("\n--- Dynamic Effects (Event Study) ---\n")
    print(summary(cs_dynamic))

    # Save event study plot
    pdf("../figures/cs_event_study_proper.pdf", width = 8, height = 6)
    ggdid(cs_dynamic) +
      labs(title = "Callaway-Sant'Anna Event Study",
           subtitle = "Effect of MW > $7.25 on Teen Work Time",
           x = "Years Relative to Treatment",
           y = "ATT (minutes/day)") +
      theme_minimal(base_size = 12)
    dev.off()
    cat("\nEvent study figure saved to figures/cs_event_study_proper.pdf\n")
  }

  # Save results
  cs_summary <- data.frame(
    method = "Callaway-Sant'Anna",
    estimate = cs_simple$overall.att,
    se = cs_simple$overall.se,
    ci_lower = cs_simple$overall.att - 1.96 * cs_simple$overall.se,
    ci_upper = cs_simple$overall.att + 1.96 * cs_simple$overall.se,
    pvalue = 2 * pnorm(-abs(cs_simple$overall.att / cs_simple$overall.se))
  )
} else {
  cs_summary <- data.frame(
    method = "Callaway-Sant'Anna",
    estimate = NA, se = NA, ci_lower = NA, ci_upper = NA, pvalue = NA
  )
}

# =============================================================================
# METHOD 2: GARDNER (2022) TWO-STAGE DiD (did2s)
# =============================================================================

cat("\n=============================================================================\n")
cat("METHOD 2: GARDNER (2022) TWO-STAGE DiD\n")
cat("=============================================================================\n\n")

# did2s needs a treatment indicator and works with individual-level data
# Create relative time variable for event study
df_clean[first_treat_year > 0, rel_year := year - first_treat_year]
df_clean[first_treat_year == 0, rel_year := -Inf]  # Never-treated

# Bin relative years for event study
df_clean[, rel_year_binned := fcase(
  rel_year == -Inf, -1000L,  # Never-treated
  rel_year < -5, -5L,
  rel_year > 8, 8L,
  default = as.integer(rel_year)
)]

# Static DiD with did2s
did2s_static <- tryCatch({
  did2s(
    data = as.data.frame(df_clean),
    yname = "work_time",
    first_stage = ~ 0 | statefip + year,
    second_stage = ~ i(treated, ref = FALSE),
    treatment = "treated",
    cluster_var = "statefip",
    weights = "weight"
  )
}, error = function(e) {
  cat("did2s static error:", e$message, "\n")
  NULL
})

if (!is.null(did2s_static)) {
  cat("--- did2s Static Results ---\n")
  print(summary(did2s_static))

  # Get coefficient (name may vary)
  coef_name <- names(coef(did2s_static))[1]
  did2s_summary <- data.frame(
    method = "Gardner (did2s)",
    estimate = coef(did2s_static)[coef_name],
    se = sqrt(diag(vcov(did2s_static)))[coef_name],
    ci_lower = NA, ci_upper = NA, pvalue = NA
  )
  did2s_summary$ci_lower <- did2s_summary$estimate - 1.96 * did2s_summary$se
  did2s_summary$ci_upper <- did2s_summary$estimate + 1.96 * did2s_summary$se
  did2s_summary$pvalue <- 2 * pnorm(-abs(did2s_summary$estimate / did2s_summary$se))
} else {
  did2s_summary <- data.frame(
    method = "Gardner (did2s)",
    estimate = NA, se = NA, ci_lower = NA, ci_upper = NA, pvalue = NA
  )
}

# Event study with did2s
did2s_es <- tryCatch({
  # Only use observations with valid relative years
  df_es <- df_clean[rel_year_binned != -1000 | first_treat_year == 0]
  df_es[first_treat_year == 0, rel_year_binned := -1L]  # Reference period for never-treated

  did2s(
    data = as.data.frame(df_es),
    yname = "work_time",
    first_stage = ~ 0 | statefip + year,
    second_stage = ~ i(rel_year_binned, ref = -1),
    treatment = "treated",
    cluster_var = "statefip",
    weights = "weight"
  )
}, error = function(e) {
  cat("did2s event study error:", e$message, "\n")
  NULL
})

if (!is.null(did2s_es)) {
  cat("\n--- did2s Event Study Results ---\n")
  print(summary(did2s_es))
}

# =============================================================================
# METHOD 3: BORUSYAK-JARAVEL-SPIESS (2024) IMPUTATION
# =============================================================================

cat("\n=============================================================================\n")
cat("METHOD 3: BORUSYAK-JARAVEL-SPIESS (2024) IMPUTATION\n")
cat("=============================================================================\n\n")

# didimputation requires panel data with unit IDs
# We'll use the annual state-level panel

bjs_result <- tryCatch({
  did_imputation(
    data = as.data.frame(df_annual),
    yname = "work_time",
    gname = "g",
    tname = "year",
    idname = "statefip",
    first_stage = ~ 0 | statefip + year
  )
}, error = function(e) {
  cat("BJS imputation error:", e$message, "\n")
  NULL
})

if (!is.null(bjs_result)) {
  cat("--- Borusyak-Jaravel-Spiess Results ---\n")
  print(bjs_result)

  # BJS returns a data.table with estimate, std.error, conf.low, conf.high
  bjs_summary <- data.frame(
    method = "BJS Imputation",
    estimate = bjs_result$estimate[1],
    se = bjs_result$std.error[1],
    ci_lower = bjs_result$conf.low[1],
    ci_upper = bjs_result$conf.high[1],
    pvalue = 2 * pnorm(-abs(bjs_result$estimate[1] / bjs_result$std.error[1]))
  )
} else {
  bjs_summary <- data.frame(
    method = "BJS Imputation",
    estimate = NA, se = NA, ci_lower = NA, ci_upper = NA, pvalue = NA
  )
}

# =============================================================================
# METHOD 4: STACKED DiD
# =============================================================================

cat("\n=============================================================================\n")
cat("METHOD 4: STACKED DiD\n")
cat("=============================================================================\n\n")

# Stacked DiD: create cohort-specific datasets and stack them
# For each treatment cohort, create a window around treatment
# Use only never-treated or not-yet-treated as controls

cohorts <- sort(unique(df_annual[g > 0, g]))
cat("Treatment cohorts:", paste(cohorts, collapse = ", "), "\n")
cat("Number of cohorts:", length(cohorts), "\n\n")

stacked_list <- list()

for (coh in cohorts) {
  # Window: 5 years before to 5 years after
  window_start <- coh - 5
  window_end <- min(coh + 5, 2023)

  # Treated units in this cohort
  treated_units <- df_annual[g == coh, unique(statefip)]

  # Control units: never-treated OR not-yet-treated (g > window_end)
  control_units <- df_annual[g == 0 | g > window_end, unique(statefip)]

  # Subset data
  cohort_data <- df_annual[
    statefip %in% c(treated_units, control_units) &
    year >= window_start & year <= window_end
  ]

  # Create cohort-specific treatment indicator
  cohort_data[, cohort := coh]
  cohort_data[, post := as.integer(year >= coh)]
  cohort_data[, treat_unit := as.integer(g == coh)]
  cohort_data[, treat := post * treat_unit]

  stacked_list[[as.character(coh)]] <- cohort_data

  cat("Cohort", coh, ":", length(treated_units), "treated,",
      length(control_units), "control,", nrow(cohort_data), "obs\n")
}

# Stack all cohorts
stacked_df <- rbindlist(stacked_list)
cat("\nStacked data:", nrow(stacked_df), "observations\n")

# Estimate stacked DiD with cohort-specific fixed effects
stacked_result <- tryCatch({
  feols(work_time ~ treat | statefip^cohort + year^cohort,
        data = stacked_df, cluster = ~statefip)
}, error = function(e) {
  cat("Stacked DiD error:", e$message, "\n")
  NULL
})

if (!is.null(stacked_result)) {
  cat("\n--- Stacked DiD Results ---\n")
  print(summary(stacked_result))

  stacked_summary <- data.frame(
    method = "Stacked DiD",
    estimate = coef(stacked_result)["treat"],
    se = sqrt(diag(vcov(stacked_result)))["treat"],
    ci_lower = NA, ci_upper = NA, pvalue = NA
  )
  stacked_summary$ci_lower <- stacked_summary$estimate - 1.96 * stacked_summary$se
  stacked_summary$ci_upper <- stacked_summary$estimate + 1.96 * stacked_summary$se
  stacked_summary$pvalue <- summary(stacked_result)$coeftable["treat", "Pr(>|t|)"]
} else {
  stacked_summary <- data.frame(
    method = "Stacked DiD",
    estimate = NA, se = NA, ci_lower = NA, ci_upper = NA, pvalue = NA
  )
}

# =============================================================================
# COMPARISON: BASELINE TWFE
# =============================================================================

cat("\n=============================================================================\n")
cat("COMPARISON: BASELINE TWFE\n")
cat("=============================================================================\n\n")

# TWFE on annual data (same sample as modern methods)
twfe_annual <- feols(work_time ~ i(g > 0 & year >= g) | statefip + year,
                     data = df_annual)
cat("--- TWFE on Annual State Panel ---\n")
print(summary(twfe_annual))

twfe_summary <- data.frame(
  method = "TWFE (annual panel)",
  estimate = coef(twfe_annual)[1],
  se = sqrt(diag(vcov(twfe_annual)))[1],
  ci_lower = NA, ci_upper = NA, pvalue = NA
)
twfe_summary$ci_lower <- twfe_summary$estimate - 1.96 * twfe_summary$se
twfe_summary$ci_upper <- twfe_summary$estimate + 1.96 * twfe_summary$se
twfe_summary$pvalue <- summary(twfe_annual)$coeftable[1, "Pr(>|t|)"]

# =============================================================================
# SUMMARY TABLE
# =============================================================================

cat("\n=============================================================================\n")
cat("SUMMARY: ALL MODERN DiD METHODS\n")
cat("=============================================================================\n\n")

all_results <- rbind(
  twfe_summary,
  cs_summary,
  did2s_summary,
  bjs_summary,
  stacked_summary
)

# Round for display
all_results$estimate <- round(all_results$estimate, 3)
all_results$se <- round(all_results$se, 3)
all_results$ci_lower <- round(all_results$ci_lower, 3)
all_results$ci_upper <- round(all_results$ci_upper, 3)
all_results$pvalue <- round(all_results$pvalue, 4)

print(all_results)

# Save results
write.csv(all_results, "../tables/modern_did_comparison.csv", row.names = FALSE)
cat("\nResults saved to tables/modern_did_comparison.csv\n")

# =============================================================================
# CREATE COMPARISON FIGURE
# =============================================================================

pdf("../figures/modern_did_comparison.pdf", width = 10, height = 6)

# Filter to methods with results
plot_df <- all_results[!is.na(all_results$estimate), ]

ggplot(plot_df, aes(x = reorder(method, estimate), y = estimate)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = ci_lower, ymax = ci_upper), width = 0.2) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
  coord_flip() +
  labs(
    title = "Modern DiD Estimators: Effect of MW > $7.25 on Teen Work Time",
    subtitle = "All methods use never-treated as controls; annual state-level panel",
    x = "",
    y = "Effect (minutes per day)",
    caption = "Error bars show 95% confidence intervals. Dashed line at zero."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

dev.off()
cat("Comparison figure saved to figures/modern_did_comparison.pdf\n")

cat("\n=============================================================================\n")
cat("DONE\n")
cat("=============================================================================\n")
