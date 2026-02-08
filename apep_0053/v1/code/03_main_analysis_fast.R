# ============================================================================
# Paper 66: Automatic Voter Registration
# Script 03: Main DiD Analysis (State-Year Aggregates - FAST)
# ============================================================================

library(tidyverse)
library(fixest)

cat("============================================================\n")
cat("MAIN DiD ANALYSIS (State-Year Aggregates)\n")
cat("============================================================\n\n")

# Load state-year panel
df <- readRDS("data/state_year_panel.rds")

cat("State-year panel N:", nrow(df), "\n\n")

# ============================================================================
# TWFE DiD with State and Year Fixed Effects
# ============================================================================

cat("Running TWFE DiD...\n\n")

# Registration
m_reg <- feols(
  reg_rate ~ treated | state_fips + year,
  data = df,
  cluster = ~ state_fips
)

# Turnout
m_vote <- feols(
  vote_rate ~ treated | state_fips + year,
  data = df,
  cluster = ~ state_fips
)

cat("--- REGISTRATION RESULTS ---\n")
cat(sprintf("ATT: %.4f\n", coef(m_reg)["treated"]))
cat(sprintf("SE:  %.4f\n", se(m_reg)["treated"]))
cat(sprintf("p:   %.4f\n\n", pvalue(m_reg)["treated"]))

cat("--- TURNOUT RESULTS ---\n")
cat(sprintf("ATT: %.4f\n", coef(m_vote)["treated"]))
cat(sprintf("SE:  %.4f\n", se(m_vote)["treated"]))
cat(sprintf("p:   %.4f\n\n", pvalue(m_vote)["treated"]))

# ============================================================================
# Event Study (Leads and Lags)
# ============================================================================

cat("Running event study...\n\n")

# Create event time dummies
df_event <- df %>%
  mutate(
    event_time = if_else(ever_treated, year - cohort, NA_integer_),
    # Create dummies for t-3 to t+6
    t_minus3 = if_else(event_time == -3, 1, 0, missing = 0),
    t_minus2 = if_else(event_time == -2, 1, 0, missing = 0),
    # t_minus1 omitted (reference)
    t_0 = if_else(event_time == 0, 1, 0, missing = 0),
    t_1 = if_else(event_time == 1, 1, 0, missing = 0),
    t_2 = if_else(event_time == 2, 1, 0, missing = 0),
    t_3 = if_else(event_time == 3, 1, 0, missing = 0),
    t_4 = if_else(event_time == 4, 1, 0, missing = 0),
    t_5 = if_else(event_time == 5, 1, 0, missing = 0),
    t_6plus = if_else(event_time >= 6, 1, 0, missing = 0)
  )

# Event study regression
m_event_reg <- feols(
  reg_rate ~ t_minus3 + t_minus2 + t_0 + t_1 + t_2 + t_3 + t_4 + t_5 + t_6plus |
    state_fips + year,
  data = df_event,
  cluster = ~ state_fips
)

m_event_vote <- feols(
  vote_rate ~ t_minus3 + t_minus2 + t_0 + t_1 + t_2 + t_3 + t_4 + t_5 + t_6plus |
    state_fips + year,
  data = df_event,
  cluster = ~ state_fips
)

cat("Event study completed\n\n")

# ============================================================================
# Extract Event Study Coefficients
# ============================================================================

# Registration event study
es_reg <- tibble(
  event_time = c(-3, -2, -1, 0, 1, 2, 3, 4, 5, 6),
  coef = c(
    coef(m_event_reg)["t_minus3"],
    coef(m_event_reg)["t_minus2"],
    0,  # Reference period
    coef(m_event_reg)["t_0"],
    coef(m_event_reg)["t_1"],
    coef(m_event_reg)["t_2"],
    coef(m_event_reg)["t_3"],
    coef(m_event_reg)["t_4"],
    coef(m_event_reg)["t_5"],
    coef(m_event_reg)["t_6plus"]
  ),
  se = c(
    se(m_event_reg)["t_minus3"],
    se(m_event_reg)["t_minus2"],
    0,
    se(m_event_reg)["t_0"],
    se(m_event_reg)["t_1"],
    se(m_event_reg)["t_2"],
    se(m_event_reg)["t_3"],
    se(m_event_reg)["t_4"],
    se(m_event_reg)["t_5"],
    se(m_event_reg)["t_6plus"]
  ),
  ci_lower = coef - 1.96 * se,
  ci_upper = coef + 1.96 * se
)

# Turnout event study
es_vote <- tibble(
  event_time = c(-3, -2, -1, 0, 1, 2, 3, 4, 5, 6),
  coef = c(
    coef(m_event_vote)["t_minus3"],
    coef(m_event_vote)["t_minus2"],
    0,
    coef(m_event_vote)["t_0"],
    coef(m_event_vote)["t_1"],
    coef(m_event_vote)["t_2"],
    coef(m_event_vote)["t_3"],
    coef(m_event_vote)["t_4"],
    coef(m_event_vote)["t_5"],
    coef(m_event_vote)["t_6plus"]
  ),
  se = c(
    se(m_event_vote)["t_minus3"],
    se(m_event_vote)["t_minus2"],
    0,
    se(m_event_vote)["t_0"],
    se(m_event_vote)["t_1"],
    se(m_event_vote)["t_2"],
    se(m_event_vote)["t_3"],
    se(m_event_vote)["t_4"],
    se(m_event_vote)["t_5"],
    se(m_event_vote)["t_6plus"]
  ),
  ci_lower = coef - 1.96 * se,
  ci_upper = coef + 1.96 * se
)

# ============================================================================
# Summary Statistics by Treatment Group
# ============================================================================

cat("Calculating summary statistics...\n\n")

summ_stats <- df %>%
  filter(year <= 2014) %>%  # Pre-treatment period
  group_by(ever_treated) %>%
  summarize(
    n_states = n_distinct(state_fips),
    mean_reg = mean(reg_rate, na.rm = TRUE),
    mean_vote = mean(vote_rate, na.rm = TRUE),
    sd_reg = sd(reg_rate, na.rm = TRUE),
    sd_vote = sd(vote_rate, na.rm = TRUE)
  )

cat("Pre-treatment summary stats:\n")
print(summ_stats)
cat("\n")

# ============================================================================
# Save Results
# ============================================================================

results <- list(
  m_reg = m_reg,
  m_vote = m_vote,
  m_event_reg = m_event_reg,
  m_event_vote = m_event_vote,
  es_reg = es_reg,
  es_vote = es_vote,
  summ_stats = summ_stats,
  df_state_year = df
)

saveRDS(results, "data/did_results.rds")

cat("✓ Results saved to: data/did_results.rds\n\n")

# ============================================================================
# FINAL SUMMARY
# ============================================================================

cat("============================================================\n")
cat("MAIN RESULTS\n")
cat("============================================================\n\n")

cat("REGISTRATION EFFECT:\n")
cat(sprintf("  ATT:  %.4f (%.1f pp)\n", coef(m_reg)["treated"], coef(m_reg)["treated"] * 100))
cat(sprintf("  SE:   %.4f\n", se(m_reg)["treated"]))
cat(sprintf("  p:    %.4f %s\n\n", pvalue(m_reg)["treated"],
            if_else(pvalue(m_reg)["treated"] < 0.01, "***", if_else(pvalue(m_reg)["treated"] < 0.05, "**", if_else(pvalue(m_reg)["treated"] < 0.10, "*", "")))))

cat("TURNOUT EFFECT:\n")
cat(sprintf("  ATT:  %.4f (%.1f pp)\n", coef(m_vote)["treated"], coef(m_vote)["treated"] * 100))
cat(sprintf("  SE:   %.4f\n", se(m_vote)["treated"]))
cat(sprintf("  p:    %.4f %s\n\n", pvalue(m_vote)["treated"],
            if_else(pvalue(m_vote)["treated"] < 0.01, "***", if_else(pvalue(m_vote)["treated"] < 0.05, "**", if_else(pvalue(m_vote)["treated"] < 0.10, "*", "")))))

cat("PRE-TRENDS TEST (t=-3, t=-2):\n")
cat(sprintf("  t=-3: %.4f (p=%.4f)\n", coef(m_event_reg)["t_minus3"], pvalue(m_event_reg)["t_minus3"]))
cat(sprintf("  t=-2: %.4f (p=%.4f)\n\n", coef(m_event_reg)["t_minus2"], pvalue(m_event_reg)["t_minus2"]))

cat("============================================================\n")
cat("ANALYSIS COMPLETE\n")
cat("============================================================\n")
