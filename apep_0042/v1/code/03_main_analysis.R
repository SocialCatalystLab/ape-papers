# =============================================================================
# 03_main_analysis.R
# Main DiD Analysis: Effect of State Auto-IRA Mandates on Retirement Coverage
# =============================================================================

source("00_packages.R")

# -----------------------------------------------------------------------------
# Load Data
# -----------------------------------------------------------------------------

cat("Loading cleaned data...\n")
df <- readRDS(file.path(data_dir, "cps_asec_clean.rds"))

cat("Observations:", nrow(df), "\n")
cat("Years:", min(df$year), "-", max(df$year), "\n")
cat("States:", n_distinct(df$statefip), "\n")

# -----------------------------------------------------------------------------
# Collapse to State-Year Level for Main Analysis
# -----------------------------------------------------------------------------

cat("\nCollapsing to state-year level...\n")

df_state_year <- df %>%
  group_by(statefip, year, first_treat) %>%
  summarise(
    # Outcome: retirement coverage rate
    pension_rate = weighted.mean(has_pension, weight, na.rm = TRUE),

    # Demographics (for covariates)
    pct_female = weighted.mean(female, weight, na.rm = TRUE),
    pct_college = weighted.mean(college, weight, na.rm = TRUE),
    pct_married = weighted.mean(married, weight, na.rm = TRUE),
    pct_white_nh = weighted.mean(white_nh, weight, na.rm = TRUE),
    mean_age = weighted.mean(age, weight, na.rm = TRUE),
    pct_small_firm = weighted.mean(small_firm, weight, na.rm = TRUE),

    # Sample size
    n_obs = n(),
    sum_weight = sum(weight, na.rm = TRUE),

    .groups = "drop"
  ) %>%
  # Create numeric state ID for panel
  mutate(
    state_id = as.numeric(factor(statefip)),
    # Ensure first_treat is 0 for never-treated
    first_treat = replace_na(first_treat, 0)
  )

cat("State-year observations:", nrow(df_state_year), "\n")

# Check treatment timing
cat("\nTreatment timing:\n")
df_state_year %>%
  filter(first_treat > 0) %>%
  distinct(statefip, first_treat) %>%
  arrange(first_treat) %>%
  print()

# -----------------------------------------------------------------------------
# MAIN ANALYSIS: Callaway-Sant'Anna (2021)
# -----------------------------------------------------------------------------

cat("\n" , rep("=", 60), "\n")
cat("CALLAWAY-SANT'ANNA DIFFERENCE-IN-DIFFERENCES\n")
cat(rep("=", 60), "\n\n")

# Run Callaway-Sant'Anna with never-treated as control
cs_out <- att_gt(
  yname = "pension_rate",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = df_state_year,
  control_group = "nevertreated",  # Use never-treated states as control
  anticipation = 0,                 # No anticipation effects
  base_period = "universal",        # Universal base period
  est_method = "dr",                # Doubly robust
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000,
  clustervars = "statefip"          # Cluster at state level
)

# Print group-time ATTs
cat("Group-Time ATTs:\n")
summary(cs_out)

# -----------------------------------------------------------------------------
# Aggregate Effects
# -----------------------------------------------------------------------------

# Simple aggregate ATT
agg_simple <- aggte(cs_out, type = "simple")
cat("\n\nSimple Aggregate ATT:\n")
summary(agg_simple)

# Dynamic effects (event study)
agg_dynamic <- aggte(cs_out, type = "dynamic", min_e = -5, max_e = 5)
cat("\n\nDynamic (Event Study) Effects:\n")
summary(agg_dynamic)

# Group-specific effects
agg_group <- aggte(cs_out, type = "group")
cat("\n\nGroup-Specific (Cohort) Effects:\n")
summary(agg_group)

# Calendar time effects
agg_calendar <- aggte(cs_out, type = "calendar")
cat("\n\nCalendar Time Effects:\n")
summary(agg_calendar)

# -----------------------------------------------------------------------------
# Save Results
# -----------------------------------------------------------------------------

# Extract event study coefficients
es_coefs <- data.frame(
  event_time = agg_dynamic$egt,
  att = agg_dynamic$att.egt,
  se = agg_dynamic$se.egt,
  ci_lower = agg_dynamic$att.egt - 1.96 * agg_dynamic$se.egt,
  ci_upper = agg_dynamic$att.egt + 1.96 * agg_dynamic$se.egt
)

# Save results
saveRDS(cs_out, file.path(data_dir, "cs_results.rds"))
saveRDS(agg_dynamic, file.path(data_dir, "cs_dynamic.rds"))
saveRDS(agg_simple, file.path(data_dir, "cs_simple.rds"))
write_csv(es_coefs, file.path(data_dir, "event_study_coefs.csv"))

# -----------------------------------------------------------------------------
# Alternative: TWFE with Sun-Abraham (fixest)
# -----------------------------------------------------------------------------

cat("\n", rep("=", 60), "\n")
cat("SUN-ABRAHAM EVENT STUDY (TWFE ROBUST)\n")
cat(rep("=", 60), "\n\n")

# Create event time variable
df_state_year <- df_state_year %>%
  mutate(
    event_time = ifelse(first_treat > 0, year - first_treat, NA_integer_),
    # Cohort for sunab
    cohort = ifelse(first_treat > 0, first_treat, 10000)  # Never-treated gets large value
  )

# Sun-Abraham event study using fixest
sunab_out <- feols(
  pension_rate ~ sunab(cohort, year) | state_id + year,
  data = df_state_year,
  cluster = ~statefip
)

cat("Sun-Abraham Results:\n")
print(summary(sunab_out))

# Extract Sun-Abraham coefficients
sunab_coefs <- broom::tidy(sunab_out) %>%
  filter(str_detect(term, "year::")) %>%
  mutate(
    event_time = as.numeric(str_extract(term, "-?\\d+$")),
    att = estimate,
    se = std.error,
    ci_lower = estimate - 1.96 * std.error,
    ci_upper = estimate + 1.96 * std.error
  ) %>%
  select(event_time, att, se, ci_lower, ci_upper)

saveRDS(sunab_out, file.path(data_dir, "sunab_results.rds"))
write_csv(sunab_coefs, file.path(data_dir, "sunab_coefs.csv"))

# -----------------------------------------------------------------------------
# Standard TWFE (for comparison/bias illustration)
# -----------------------------------------------------------------------------

cat("\n", rep("=", 60), "\n")
cat("STANDARD TWFE (POTENTIALLY BIASED)\n")
cat(rep("=", 60), "\n\n")

df_state_year <- df_state_year %>%
  mutate(
    post = ifelse(first_treat > 0 & year >= first_treat, 1, 0),
    treated = ifelse(first_treat > 0, 1, 0)
  )

twfe_out <- feols(
  pension_rate ~ post | state_id + year,
  data = df_state_year,
  cluster = ~statefip
)

cat("Standard TWFE Results:\n")
print(summary(twfe_out))

saveRDS(twfe_out, file.path(data_dir, "twfe_results.rds"))

# -----------------------------------------------------------------------------
# Summary of Main Results
# -----------------------------------------------------------------------------

cat("\n", rep("=", 60), "\n")
cat("SUMMARY OF MAIN RESULTS\n")
cat(rep("=", 60), "\n\n")

cat("Callaway-Sant'Anna ATT:", round(agg_simple$overall.att, 4),
    "(SE:", round(agg_simple$overall.se, 4), ")\n")
cat("TWFE coefficient:", round(coef(twfe_out)["post"], 4),
    "(SE:", round(se(twfe_out)["post"], 4), ")\n")

cat("\nAnalysis complete. Results saved to:", data_dir, "\n")
cat("Next: Run 04_robustness.R for robustness checks\n")
cat("      Run 05_figures.R for publication figures\n")
