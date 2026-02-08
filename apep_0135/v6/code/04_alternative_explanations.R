# ============================================================================
# Technology Obsolescence and Populist Voting - Revision
# 04_alternative_explanations.R - Mediation Analysis and Alternative Controls
# ============================================================================
#
# This script tests alternative explanations for the technology-voting
# relationship, following the conceptual framework:
#
# Technology Obsolescence → [Moral Values?] → Populist Voting
#
# Key analyses:
# 1. First stage: Does tech age predict moral communalism?
# 2. Mediation: Does controlling for moral values attenuate tech coefficient?
# 3. Education as confounder: Does education explain the tech-voting link?
# 4. Appendix analysis: "Bad control" discussion
#
# References:
# - Enke (2020) "Moral Values and Voting" JPE
# - Diamond (2016) "The Determinants and Welfare Implications of US Workers'
#   Diverging Location Choices by Skill: 1980-2000" AER
# - Angrist & Pischke (2009) "Mostly Harmless Econometrics" (on bad controls)
# ============================================================================

source("./00_packages.R")

# Load data with alternative controls
df <- readRDS("../data/analysis_data.rds")

cat("============================================\n")
cat("Alternative Explanations: Moral Values as Mechanism\n")
cat("============================================\n\n")

# ============================================================================
# 1. BASELINE: Reproduce main technology-voting relationship
# ============================================================================

cat("1. Baseline: Technology Age → Trump Vote Share\n")
cat("-----------------------------------------------\n\n")

# Main specification from original paper
m_baseline <- feols(trump_share ~ modal_age_mean + log_total_votes + is_metro | year,
                    data = df, cluster = ~cbsa)

cat("Baseline specification (from main analysis):\n")
etable(m_baseline,
       dict = c(modal_age_mean = "Modal Tech Age",
                log_total_votes = "Log Total Votes",
                is_metroTRUE = "Metropolitan"),
       se.below = TRUE)

cat(sprintf("\nBaseline tech coefficient: %.4f (SE = %.4f)\n",
            coef(m_baseline)["modal_age_mean"],
            se(m_baseline)["modal_age_mean"]))

# ============================================================================
# 2. FIRST STAGE: Does technology age predict moral communalism?
# ============================================================================

cat("\n\n2. First Stage: Technology Age → Moral Communalism\n")
cat("---------------------------------------------------\n\n")

cat("Testing whether technological obsolescence predicts moral values.\n")
cat("Enke (2020) hypothesis: Older-tech regions are more isolated from\n")
cat("cosmopolitan culture and have more communal/particularist values.\n\n")

# First stage: tech age → moral communalism proxy
m_first_stage <- feols(moral_communalism_proxy ~ modal_age_mean + log_total_votes | year,
                       data = df, cluster = ~cbsa)

# First stage with simple binary measure
m_first_stage_simple <- lm(moral_communalism_simple ~ modal_age_mean + log_total_votes,
                           data = df)

cat("First Stage Results:\n")
etable(m_first_stage,
       dict = c(modal_age_mean = "Modal Tech Age",
                log_total_votes = "Log Total Votes"),
       se.below = TRUE,
       title = "First Stage: Tech Age → Moral Communalism Proxy")

cat(sprintf("\nFirst stage coefficient: %.4f (SE = %.4f)\n",
            coef(m_first_stage)["modal_age_mean"],
            se(m_first_stage)["modal_age_mean"]))

first_stage_sig <- coef(m_first_stage)["modal_age_mean"] / se(m_first_stage)["modal_age_mean"]
cat(sprintf("t-statistic: %.2f\n", first_stage_sig))

if (abs(first_stage_sig) > 2) {
  cat("→ Technology age DOES predict moral communalism (first stage significant)\n")
} else {
  cat("→ Technology age does NOT predict moral communalism (first stage weak)\n")
}

# ============================================================================
# 3. MEDIATION ANALYSIS: Does moral values explain tech-voting relationship?
# ============================================================================

cat("\n\n3. Mediation Analysis: Adding Moral Values Control\n")
cat("---------------------------------------------------\n\n")

cat("If moral values MEDIATE the tech-voting relationship:\n")
cat("- Adding moral values should attenuate the tech coefficient\n")
cat("- The attenuation shows how much of the tech effect 'works through' values\n\n")

# Specification 1: Baseline (tech + controls)
m1 <- feols(trump_share ~ modal_age_mean + log_total_votes + is_metro | year,
            data = df, cluster = ~cbsa)

# Specification 2: Add moral communalism proxy
m2 <- feols(trump_share ~ modal_age_mean + moral_communalism_proxy + log_total_votes | year,
            data = df, cluster = ~cbsa)

# Specification 3: Add moral communalism simple (binary)
m3 <- feols(trump_share ~ modal_age_mean + moral_communalism_simple + log_total_votes | year,
            data = df, cluster = ~cbsa)

# Calculate attenuation
tech_coef_baseline <- coef(m1)["modal_age_mean"]
tech_coef_with_moral <- coef(m2)["modal_age_mean"]
attenuation_pct <- (tech_coef_baseline - tech_coef_with_moral) / tech_coef_baseline * 100

cat("Mediation Results:\n")
etable(m1, m2, m3,
       headers = c("Baseline", "+ Moral Proxy", "+ Non-Metro"),
       dict = c(modal_age_mean = "Modal Tech Age",
                moral_communalism_proxy = "Moral Communalism (proxy)",
                moral_communalism_simple = "Non-Metro (binary)",
                log_total_votes = "Log Total Votes",
                is_metroTRUE = "Metropolitan"),
       se.below = TRUE,
       title = "Mediation: Technology Age with Moral Values Control")

cat("\n--- Mediation Interpretation ---\n")
cat(sprintf("Tech coefficient (baseline): %.4f\n", tech_coef_baseline))
cat(sprintf("Tech coefficient (+ moral values): %.4f\n", tech_coef_with_moral))
cat(sprintf("Attenuation: %.1f%%\n", attenuation_pct))

if (attenuation_pct > 30) {
  cat("→ Substantial attenuation: Moral values appear to MEDIATE the tech-voting link\n")
} else if (attenuation_pct > 10) {
  cat("→ Moderate attenuation: Partial mediation through moral values\n")
} else {
  cat("→ Minimal attenuation: Technology has direct effect beyond moral values\n")
}

# ============================================================================
# 4. EDUCATION AS CONFOUNDER TEST
# ============================================================================

cat("\n\n4. Education as Confounder Test\n")
cat("-------------------------------\n\n")

cat("Unlike moral values (potential mechanism), education is a plausible\n")
cat("confounder - it may cause both tech adoption AND voting patterns.\n")
cat("(Diamond 2016: Workers sort into places based on education)\n\n")

# Check if college_share is available
if ("college_share" %in% names(df) && !all(is.na(df$college_share))) {

  # Specification with education control
  m_edu <- feols(trump_share ~ modal_age_mean + college_share + log_total_votes + is_metro | year,
                 data = filter(df, !is.na(college_share)), cluster = ~cbsa)

  # Compare baseline vs with education
  m_edu_baseline <- feols(trump_share ~ modal_age_mean + log_total_votes + is_metro | year,
                          data = filter(df, !is.na(college_share)), cluster = ~cbsa)

  tech_coef_edu_baseline <- coef(m_edu_baseline)["modal_age_mean"]
  tech_coef_with_edu <- coef(m_edu)["modal_age_mean"]
  edu_attenuation_pct <- (tech_coef_edu_baseline - tech_coef_with_edu) / tech_coef_edu_baseline * 100

  etable(m_edu_baseline, m_edu,
         headers = c("Without Education", "With Education"),
         dict = c(modal_age_mean = "Modal Tech Age",
                  college_share = "College Share",
                  log_total_votes = "Log Total Votes",
                  is_metroTRUE = "Metropolitan"),
         se.below = TRUE,
         title = "Education as Confounder")

  cat("\n--- Education Control Interpretation ---\n")
  cat(sprintf("Tech coefficient (without edu): %.4f\n", tech_coef_edu_baseline))
  cat(sprintf("Tech coefficient (with edu): %.4f\n", tech_coef_with_edu))
  cat(sprintf("Attenuation: %.1f%%\n", edu_attenuation_pct))

  if (edu_attenuation_pct > 50) {
    cat("→ Education largely explains the tech-voting correlation\n")
    cat("→ Interpretation: Geographic sorting by education (Diamond 2016)\n")
  } else {
    cat("→ Technology has explanatory power beyond education\n")
  }

} else {
  cat("Note: College share data not available. Using urban size as proxy.\n")
  cat("Larger CBSAs have higher education levels.\n\n")

  # The log_total_votes control already partially captures this
  cat("Log total votes (in baseline) partially controls for education composition.\n")
}

# ============================================================================
# 5. KITCHEN SINK: ALL CONTROLS
# ============================================================================

cat("\n\n5. Horse Race: All Controls Together\n")
cat("------------------------------------\n\n")

# Full specification with all available controls
if ("college_share" %in% names(df) && !all(is.na(df$college_share))) {
  m_full <- feols(trump_share ~ modal_age_mean + moral_communalism_proxy +
                    college_share + log_total_votes | year,
                  data = filter(df, !is.na(college_share)), cluster = ~cbsa)

  m_full_2008 <- feols(trump_share ~ modal_age_mean + moral_communalism_proxy +
                         college_share + gop_share_2008 + log_total_votes | year,
                       data = filter(df, !is.na(college_share) & !is.na(gop_share_2008)),
                       cluster = ~cbsa)
} else {
  m_full <- feols(trump_share ~ modal_age_mean + moral_communalism_proxy +
                    log_total_votes | year,
                  data = df, cluster = ~cbsa)

  m_full_2008 <- feols(trump_share ~ modal_age_mean + moral_communalism_proxy +
                         gop_share_2008 + log_total_votes | year,
                       data = filter(df, !is.na(gop_share_2008)),
                       cluster = ~cbsa)
}

cat("Full specification with all controls:\n")
etable(m1, m_full, m_full_2008,
       headers = c("Baseline", "All Controls", "+ 2008 Baseline"),
       se.below = TRUE,
       title = "Horse Race: Technology vs Alternative Explanations")

# ============================================================================
# 6. GAINS ANALYSIS WITH CONTROLS
# ============================================================================

cat("\n\n6. Gains Analysis: Does Tech Predict 2012→2016 Shift with Controls?\n")
cat("--------------------------------------------------------------------\n\n")

cat("The key finding from the parent paper: Tech age predicts the Romney→Trump\n")
cat("shift (2012→2016) but not subsequent changes. Does this survive controls?\n\n")

# Prepare gains data - need to handle the pivot carefully
df_gains <- df %>%
  select(cbsa, year, trump_share, modal_age_mean, moral_communalism_proxy,
         log_total_votes, is_metro) %>%
  # First get the constant controls (from any year, they don't change much)
  group_by(cbsa) %>%
  mutate(
    log_total_votes_const = first(log_total_votes),
    is_metro_const = first(is_metro)
  ) %>%
  ungroup() %>%
  select(-log_total_votes, -is_metro) %>%
  pivot_wider(names_from = year, values_from = c(trump_share, modal_age_mean,
                                                  moral_communalism_proxy)) %>%
  mutate(
    gop_gain_2012_2016 = trump_share_2016 - trump_share_2012
  ) %>%
  filter(!is.na(gop_gain_2012_2016))

# Gains regression without moral values
m_gains_base <- lm(gop_gain_2012_2016 ~ modal_age_mean_2012 + log_total_votes_const + is_metro_const,
                   data = df_gains)

# Gains regression with moral values proxy
m_gains_moral <- lm(gop_gain_2012_2016 ~ modal_age_mean_2012 + moral_communalism_proxy_2012 +
                      log_total_votes_const + is_metro_const,
                    data = df_gains)

cat("Romney→Trump Gains (2012→2016):\n")
cat("\nWithout moral values control:\n")
print(summary(m_gains_base)$coefficients[, c(1, 2, 4)])

cat("\nWith moral values control:\n")
print(summary(m_gains_moral)$coefficients[, c(1, 2, 4)])

gains_tech_baseline <- coef(m_gains_base)["modal_age_mean_2012"]
gains_tech_with_moral <- coef(m_gains_moral)["modal_age_mean_2012"]
gains_attenuation <- (gains_tech_baseline - gains_tech_with_moral) / gains_tech_baseline * 100

cat(sprintf("\n--- Gains Analysis Summary ---\n"))
cat(sprintf("Tech → 2012-2016 gains (baseline): %.4f\n", gains_tech_baseline))
cat(sprintf("Tech → 2012-2016 gains (+ moral values): %.4f\n", gains_tech_with_moral))
cat(sprintf("Attenuation: %.1f%%\n", gains_attenuation))

# ============================================================================
# 7. APPENDIX: "BAD CONTROL" DISCUSSION TABLE
# ============================================================================

cat("\n\n7. Appendix Analysis: 'Bad Control' Caveat\n")
cat("-------------------------------------------\n\n")

cat("IMPORTANT CAVEAT (Angrist & Pischke 2009):\n")
cat("If moral values are a MECHANISM (tech → values → voting),\n")
cat("then controlling for moral values may be a 'bad control' that\n")
cat("blocks the causal pathway we are trying to measure.\n\n")

cat("The attenuation when adding moral values could reflect:\n")
cat("(a) Moral values as genuine mediating mechanism, OR\n")
cat("(b) Over-controlling for a post-treatment variable\n\n")

cat("We present these results with appropriate caution.\n")

# Create summary table for appendix
appendix_table <- data.frame(
  Specification = c("(1) Baseline",
                    "(2) + Moral Values Proxy",
                    "(3) + Non-Metro Indicator",
                    "(4) + Education (if avail)"),
  Tech_Coefficient = c(
    round(coef(m1)["modal_age_mean"], 4),
    round(coef(m2)["modal_age_mean"], 4),
    round(coef(m3)["modal_age_mean"], 4),
    if (exists("m_edu")) round(coef(m_edu)["modal_age_mean"], 4) else NA
  ),
  SE = c(
    round(se(m1)["modal_age_mean"], 4),
    round(se(m2)["modal_age_mean"], 4),
    round(se(m3)["modal_age_mean"], 4),
    if (exists("m_edu")) round(se(m_edu)["modal_age_mean"], 4) else NA
  )
)

cat("\n--- Table for Appendix (Bad Control Analysis) ---\n")
print(appendix_table)

# ============================================================================
# 8. SUMMARY AND INTERPRETATION
# ============================================================================

cat("\n\n============================================\n")
cat("Summary: Alternative Explanations Analysis\n")
cat("============================================\n\n")

cat("KEY FINDINGS:\n\n")

cat("1. FIRST STAGE (Tech → Moral Values):\n")
cat(sprintf("   Coefficient: %.4f, t = %.2f\n",
            coef(m_first_stage)["modal_age_mean"], first_stage_sig))
if (abs(first_stage_sig) > 2) {
  cat("   → Technology age predicts communal moral values\n\n")
} else {
  cat("   → Weak first stage relationship\n\n")
}

cat("2. MEDIATION (Tech → Values → Voting):\n")
cat(sprintf("   Attenuation when adding moral values: %.1f%%\n", attenuation_pct))
if (attenuation_pct > 30) {
  cat("   → Suggests moral values MEDIATE the tech-voting relationship\n")
  cat("   → Caveat: Could also be 'bad control' if values are endogenous\n\n")
} else {
  cat("   → Technology has substantial direct effect beyond moral values\n\n")
}

cat("3. GAINS ANALYSIS (2012→2016 shift):\n")
cat(sprintf("   Tech still predicts Romney→Trump shift: %.4f",
            gains_tech_with_moral))
if (gains_tech_with_moral > 0 && summary(m_gains_moral)$coefficients["modal_age_mean_2012", 4] < 0.05) {
  cat(" (p < 0.05)\n")
  cat("   → Technology-specific effect on Trump emergence survives controls\n\n")
} else {
  cat("\n")
  cat("   → Effect attenuated or not significant with controls\n\n")
}

cat("4. INTERPRETATION:\n")
cat("   The technology-voting correlation appears to operate partly through\n")
cat("   moral values (or correlated factors like rurality and education).\n")
cat("   However, technology may capture something distinct - regions that\n")
cat("   have 'fallen behind' economically in ways that correlate with but\n")
cat("   are not reducible to cultural values.\n")

# ============================================================================
# 9. SAVE RESULTS FOR TABLES
# ============================================================================

cat("\nSaving results for paper tables...\n")

alternative_models <- list(
  baseline = m1,
  with_moral_proxy = m2,
  with_nonmetro = m3,
  full_controls = m_full,
  full_with_2008 = m_full_2008,
  first_stage = m_first_stage,
  gains_baseline = m_gains_base,
  gains_with_moral = m_gains_moral
)

if (exists("m_edu")) {
  alternative_models$with_education <- m_edu
}

saveRDS(alternative_models, "../data/alternative_models.rds")

cat("\nAlternative explanations analysis complete.\n")
cat("Results saved to ../data/alternative_models.rds\n")
