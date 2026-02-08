# =============================================================================
# 07_revisions.R
# Additional Analysis for Round 1 Revisions
# =============================================================================

source("00_packages.R")

# -----------------------------------------------------------------------------
# Load Data
# -----------------------------------------------------------------------------

cat("Loading cleaned data...\n")
df <- readRDS(file.path(data_dir, "cps_asec_clean.rds"))

cat("Observations:", nrow(df), "\n")

# =============================================================================
# 1. HETEROGENEITY BY FIRM SIZE
# =============================================================================

cat("\n", rep("=", 60), "\n")
cat("HETEROGENEITY BY FIRM SIZE\n")
cat(rep("=", 60), "\n\n")

# Collapse to state-year-firmsize level
df_firm <- df %>%
  group_by(statefip, year, first_treat, small_firm) %>%
  summarise(
    pension_rate = weighted.mean(has_pension, weight, na.rm = TRUE),
    n_obs = n(),
    sum_weight = sum(weight, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(
    state_id = as.numeric(factor(statefip)),
    first_treat = replace_na(first_treat, 0)
  )

# Small firms analysis
cat("\n--- Small Firms (< 100 employees) ---\n")
df_small <- df_firm %>% filter(small_firm == 1)

cs_small <- att_gt(
  yname = "pension_rate",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = df_small,
  control_group = "nevertreated",
  anticipation = 0,
  base_period = "universal",
  est_method = "dr",
  bstrap = TRUE,
  biters = 1000,
  clustervars = "statefip"
)

agg_small <- aggte(cs_small, type = "simple")
cat("\nSmall Firms ATT:", round(agg_small$overall.att, 4),
    "(SE:", round(agg_small$overall.se, 4), ")\n")

# Large firms analysis
cat("\n--- Large Firms (100+ employees) ---\n")
df_large <- df_firm %>% filter(small_firm == 0)

cs_large <- att_gt(
  yname = "pension_rate",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = df_large,
  control_group = "nevertreated",
  anticipation = 0,
  base_period = "universal",
  est_method = "dr",
  bstrap = TRUE,
  biters = 1000,
  clustervars = "statefip"
)

agg_large <- aggte(cs_large, type = "simple")
cat("\nLarge Firms ATT:", round(agg_large$overall.att, 4),
    "(SE:", round(agg_large$overall.se, 4), ")\n")

# Save firm size results
firmsize_results <- data.frame(
  group = c("Small Firms (<100)", "Large Firms (100+)"),
  att = c(agg_small$overall.att, agg_large$overall.att),
  se = c(agg_small$overall.se, agg_large$overall.se)
) %>%
  mutate(
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se
  )

write_csv(firmsize_results, file.path(data_dir, "firmsize_heterogeneity.csv"))
cat("\nFirm size results saved.\n")

# =============================================================================
# 2. LEAVE-ONE-OUT SENSITIVITY (EXCLUDING OREGON)
# =============================================================================

cat("\n", rep("=", 60), "\n")
cat("LEAVE-ONE-OUT SENSITIVITY (EXCLUDING OREGON)\n")
cat(rep("=", 60), "\n\n")

# Oregon FIPS code is 41
df_no_oregon <- df %>%
  filter(statefip != 41)

# Collapse to state-year level
df_state_year_no_or <- df_no_oregon %>%
  group_by(statefip, year, first_treat) %>%
  summarise(
    pension_rate = weighted.mean(has_pension, weight, na.rm = TRUE),
    n_obs = n(),
    .groups = "drop"
  ) %>%
  mutate(
    state_id = as.numeric(factor(statefip)),
    first_treat = replace_na(first_treat, 0)
  )

cat("States remaining (excluding Oregon):", n_distinct(df_state_year_no_or$statefip), "\n")

cs_no_oregon <- att_gt(
  yname = "pension_rate",
  tname = "year",
  idname = "state_id",
  gname = "first_treat",
  data = df_state_year_no_or,
  control_group = "nevertreated",
  anticipation = 0,
  base_period = "universal",
  est_method = "dr",
  bstrap = TRUE,
  biters = 1000,
  clustervars = "statefip"
)

agg_no_oregon <- aggte(cs_no_oregon, type = "simple")
cat("\nATT (excluding Oregon):", round(agg_no_oregon$overall.att, 4),
    "(SE:", round(agg_no_oregon$overall.se, 4), ")\n")

# Dynamic effects without Oregon
agg_dynamic_no_or <- aggte(cs_no_oregon, type = "dynamic", min_e = -5, max_e = 5)
cat("\nDynamic effects (excluding Oregon):\n")
summary(agg_dynamic_no_or)

# Save results
leave_one_out <- data.frame(
  specification = c("Full Sample", "Excluding Oregon"),
  att = c(readRDS(file.path(data_dir, "cs_simple.rds"))$overall.att,
          agg_no_oregon$overall.att),
  se = c(readRDS(file.path(data_dir, "cs_simple.rds"))$overall.se,
         agg_no_oregon$overall.se)
)

write_csv(leave_one_out, file.path(data_dir, "leave_one_out.csv"))

# =============================================================================
# 3. OREGON SAMPLE SIZE ANALYSIS
# =============================================================================

cat("\n", rep("=", 60), "\n")
cat("OREGON SAMPLE SIZE ANALYSIS\n")
cat(rep("=", 60), "\n\n")

oregon_sample <- df %>%
  filter(statefip == 41) %>%
  group_by(year) %>%
  summarise(
    n_obs = n(),
    sum_weight = sum(weight, na.rm = TRUE),
    pension_rate = weighted.mean(has_pension, weight, na.rm = TRUE)
  )

cat("Oregon sample by year:\n")
print(oregon_sample)

cat("\nAverage Oregon sample per year:", round(mean(oregon_sample$n_obs), 0), "\n")

write_csv(oregon_sample, file.path(data_dir, "oregon_sample.csv"))

# =============================================================================
# 4. POWER ANALYSIS
# =============================================================================

cat("\n", rep("=", 60), "\n")
cat("POWER ANALYSIS\n")
cat(rep("=", 60), "\n\n")

# Load main results for SE
main_se <- readRDS(file.path(data_dir, "cs_simple.rds"))$overall.se

# Minimum detectable effect (MDE) at 80% power, alpha = 0.05
# MDE = (z_alpha/2 + z_beta) * SE = (1.96 + 0.84) * SE = 2.8 * SE
mde_80 <- 2.8 * main_se

# MDE at 50% power
mde_50 <- 1.96 * main_se

cat("Standard error of aggregate ATT:", round(main_se, 4), "\n")
cat("Minimum detectable effect (80% power):", round(mde_80, 4),
    "=", round(mde_80 * 100, 2), "pp\n")
cat("Minimum detectable effect (50% power):", round(mde_50, 4),
    "=", round(mde_50 * 100, 2), "pp\n")

# Context: baseline pension rate
baseline_rate <- df %>%
  filter(first_treat == 0 | year < first_treat) %>%
  summarise(rate = weighted.mean(has_pension, weight, na.rm = TRUE)) %>%
  pull(rate)

cat("\nBaseline pension coverage rate:", round(baseline_rate * 100, 1), "%\n")
cat("MDE (80% power) as % of baseline:", round((mde_80 / baseline_rate) * 100, 1), "%\n")

power_results <- data.frame(
  se = main_se,
  mde_80 = mde_80,
  mde_50 = mde_50,
  baseline = baseline_rate
)

write_csv(power_results, file.path(data_dir, "power_analysis.csv"))

# =============================================================================
# 5. SUMMARY TABLE FOR PAPER
# =============================================================================

cat("\n", rep("=", 60), "\n")
cat("SUMMARY FOR PAPER\n")
cat(rep("=", 60), "\n\n")

cat("FIRM SIZE HETEROGENEITY:\n")
cat("  Small firms ATT:", round(agg_small$overall.att * 100, 2), "pp",
    "(SE:", round(agg_small$overall.se * 100, 2), ")\n")
cat("  Large firms ATT:", round(agg_large$overall.att * 100, 2), "pp",
    "(SE:", round(agg_large$overall.se * 100, 2), ")\n")

cat("\nLEAVE-ONE-OUT:\n")
cat("  Full sample ATT:", round(leave_one_out$att[1] * 100, 2), "pp\n")
cat("  Excl. Oregon ATT:", round(leave_one_out$att[2] * 100, 2), "pp\n")

cat("\nPOWER:\n")
cat("  MDE (80% power):", round(mde_80 * 100, 2), "pp\n")

cat("\nAnalysis complete.\n")
