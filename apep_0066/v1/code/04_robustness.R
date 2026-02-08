# =============================================================================
# 04_robustness.R - Robustness Checks
# Paper 85: Paid Family Leave and Female Entrepreneurship
# =============================================================================

source("00_packages.R")

# -----------------------------------------------------------------------------
# Load Data and Results
# -----------------------------------------------------------------------------

df <- readRDS("../data/analysis_data.rds")
cs_results <- readRDS("../data/cs_results.rds")

message("Running robustness checks...")

# -----------------------------------------------------------------------------
# 1. Placebo Test: Male Self-Employment
# -----------------------------------------------------------------------------

message("\n=== PLACEBO: MALE SELF-EMPLOYMENT ===")

cs_male <- att_gt(
  yname = "male_selfempl_rate",
  tname = "year",
  idname = "state_id",
  gname = "cohort_cs",
  data = df,
  control_group = "nevertreated",
  anticipation = 0,
  est_method = "reg",
  base_period = "universal"
)

cs_male_att <- aggte(cs_male, type = "simple", na.rm = TRUE)
message("Male SE placebo ATT: ", round(cs_male_att$overall.att, 3),
        " (SE: ", round(cs_male_att$overall.se, 3), ")")

# -----------------------------------------------------------------------------
# 2. Alternative Control Group: Not-Yet-Treated
# -----------------------------------------------------------------------------

message("\n=== NOT-YET-TREATED CONTROL GROUP ===")

cs_nyt <- att_gt(
  yname = "female_selfempl_rate",
  tname = "year",
  idname = "state_id",
  gname = "cohort_cs",
  data = df,
  control_group = "notyettreated",
  anticipation = 0,
  est_method = "reg",
  base_period = "universal"
)

cs_nyt_att <- aggte(cs_nyt, type = "simple", na.rm = TRUE)
message("Not-yet-treated ATT: ", round(cs_nyt_att$overall.att, 3),
        " (SE: ", round(cs_nyt_att$overall.se, 3), ")")

# -----------------------------------------------------------------------------
# 3. Exclude California (always-treated with no pre-period)
# -----------------------------------------------------------------------------

message("\n=== EXCLUDING CALIFORNIA ===")

df_no_ca <- df %>% filter(state_abbr != "CA")

cs_no_ca <- att_gt(
  yname = "female_selfempl_rate",
  tname = "year",
  idname = "state_id",
  gname = "cohort_cs",
  data = df_no_ca,
  control_group = "nevertreated",
  anticipation = 0,
  est_method = "reg",
  base_period = "universal"
)

cs_no_ca_att <- aggte(cs_no_ca, type = "simple", na.rm = TRUE)
message("Excluding CA ATT: ", round(cs_no_ca_att$overall.att, 3),
        " (SE: ", round(cs_no_ca_att$overall.se, 3), ")")

# -----------------------------------------------------------------------------
# 4. Incorporated vs Unincorporated Self-Employment
# -----------------------------------------------------------------------------

message("\n=== INCORPORATED VS UNINCORPORATED ===")

# Incorporated only
cs_inc <- att_gt(
  yname = "female_selfempl_inc_rate",
  tname = "year",
  idname = "state_id",
  gname = "cohort_cs",
  data = df,
  control_group = "nevertreated",
  anticipation = 0,
  est_method = "reg",
  base_period = "universal"
)
cs_inc_att <- aggte(cs_inc, type = "simple", na.rm = TRUE)

# Unincorporated only
cs_uninc <- att_gt(
  yname = "female_selfempl_uninc_rate",
  tname = "year",
  idname = "state_id",
  gname = "cohort_cs",
  data = df,
  control_group = "nevertreated",
  anticipation = 0,
  est_method = "reg",
  base_period = "universal"
)
cs_uninc_att <- aggte(cs_uninc, type = "simple", na.rm = TRUE)

message("Incorporated SE ATT: ", round(cs_inc_att$overall.att, 3),
        " (SE: ", round(cs_inc_att$overall.se, 3), ")")
message("Unincorporated SE ATT: ", round(cs_uninc_att$overall.att, 3),
        " (SE: ", round(cs_uninc_att$overall.se, 3), ")")

# -----------------------------------------------------------------------------
# 5. Triple-Difference: Female vs Male
# -----------------------------------------------------------------------------

message("\n=== TRIPLE-DIFFERENCE: FEMALE VS MALE ===")

# Calculate gender gap in self-employment
df <- df %>%
  mutate(gender_gap = female_selfempl_rate - male_selfempl_rate)

cs_gap <- att_gt(
  yname = "gender_gap",
  tname = "year",
  idname = "state_id",
  gname = "cohort_cs",
  data = df,
  control_group = "nevertreated",
  anticipation = 0,
  est_method = "reg",
  base_period = "universal"
)

cs_gap_att <- aggte(cs_gap, type = "simple", na.rm = TRUE)
message("Gender gap ATT (DDD): ", round(cs_gap_att$overall.att, 3),
        " (SE: ", round(cs_gap_att$overall.se, 3), ")")

# -----------------------------------------------------------------------------
# Summary Table
# -----------------------------------------------------------------------------

message("\n\n========================================")
message("ROBUSTNESS CHECK SUMMARY")
message("========================================\n")

robustness_table <- tibble(
  Specification = c(
    "Main (CS, never-treated)",
    "Placebo: Male SE",
    "Not-yet-treated control",
    "Excluding California",
    "Incorporated SE only",
    "Unincorporated SE only",
    "Triple-diff (female-male gap)"
  ),
  ATT = c(
    cs_results$att_simple$overall.att,
    cs_male_att$overall.att,
    cs_nyt_att$overall.att,
    cs_no_ca_att$overall.att,
    cs_inc_att$overall.att,
    cs_uninc_att$overall.att,
    cs_gap_att$overall.att
  ),
  SE = c(
    cs_results$att_simple$overall.se,
    cs_male_att$overall.se,
    cs_nyt_att$overall.se,
    cs_no_ca_att$overall.se,
    cs_inc_att$overall.se,
    cs_uninc_att$overall.se,
    cs_gap_att$overall.se
  )
) %>%
  mutate(
    t_stat = ATT / SE,
    sig = ifelse(abs(t_stat) > 1.96, "*", "")
  )

print(robustness_table)

# Save robustness results
robustness_results <- list(
  male_placebo = cs_male_att,
  nyt_control = cs_nyt_att,
  no_california = cs_no_ca_att,
  incorporated = cs_inc_att,
  unincorporated = cs_uninc_att,
  gender_gap = cs_gap_att,
  summary_table = robustness_table
)

saveRDS(robustness_results, "../data/robustness_results.rds")
write_csv(robustness_table, "../tables/robustness_summary.csv")

# -----------------------------------------------------------------------------
# 6. Power Analysis / Minimum Detectable Effect
# -----------------------------------------------------------------------------

message("\n=== POWER ANALYSIS ===")

# Calculate key statistics for power analysis
n_states <- n_distinct(df$state_abbr)
n_treated <- n_distinct(df$state_abbr[df$treated])
n_control <- n_states - n_treated
n_years <- n_distinct(df$year)
baseline_se_rate <- mean(df$female_selfempl_rate[!df$treated], na.rm = TRUE)
sd_outcome <- sd(df$female_selfempl_rate, na.rm = TRUE)

# SE from our main estimate
main_se <- cs_results$att_simple$overall.se

# MDE = 2.8 * SE (for 80% power at 5% significance)
# With few clusters, use t-distribution critical value
df_clusters <- n_treated + n_control - 2
t_crit <- qt(0.975, df_clusters)
mde_80 <- (t_crit + qt(0.80, df_clusters)) * main_se

message("\nPower Analysis Summary:")
message("   Number of states: ", n_states)
message("   Treated jurisdictions: ", n_treated)
message("   Control states: ", n_control)
message("   Years in panel: ", n_years)
message("   Baseline SE rate (control): ", round(baseline_se_rate, 2), "%")
message("   SD of outcome: ", round(sd_outcome, 2), " pp")
message("   Standard error of ATT: ", round(main_se, 3), " pp")
message("   MDE (80% power, 5% sig): ", round(mde_80, 2), " pp")
message("   MDE as % of baseline: ", round(100 * mde_80 / baseline_se_rate, 1), "%")

# What we can rule out
ci_95_lower <- cs_results$att_simple$overall.att - 1.96 * main_se
ci_95_upper <- cs_results$att_simple$overall.att + 1.96 * main_se
message("\n   95% CI: [", round(ci_95_lower, 2), ", ", round(ci_95_upper, 2), "] pp")
message("   Can rule out positive effects larger than: ", round(ci_95_upper, 2), " pp")

# Save power analysis
power_results <- list(
  n_states = n_states,
  n_treated = n_treated,
  n_control = n_control,
  n_years = n_years,
  baseline_rate = baseline_se_rate,
  sd_outcome = sd_outcome,
  main_se = main_se,
  mde_80 = mde_80,
  ci_lower = ci_95_lower,
  ci_upper = ci_95_upper
)
saveRDS(power_results, "../data/power_analysis.rds")

message("\nRobustness checks complete. Results saved to data/robustness_results.rds")
