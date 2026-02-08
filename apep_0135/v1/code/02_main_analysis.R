# ============================================================================
# Technology Obsolescence and Populist Voting
# 02_main_analysis.R - Main regression analysis
# ============================================================================

source("./00_packages.R")

# Load cleaned data
df <- readRDS("../data/analysis_data.rds")

cat("============================================\n")
cat("Main Regression Analysis\n")
cat("============================================\n\n")

# ============================================================================
# 1. Cross-sectional regressions (pooled)
# ============================================================================

cat("1. Cross-sectional Regressions (Pooled)\n")
cat("----------------------------------------\n\n")

# Model 1: Bivariate
m1 <- feols(trump_share ~ modal_age_mean, data = df, cluster = ~cbsa)

# Model 2: Add year fixed effects
m2 <- feols(trump_share ~ modal_age_mean | year, data = df, cluster = ~cbsa)

# Model 3: Add log total votes (CBSA size control)
m3 <- feols(trump_share ~ modal_age_mean + log_total_votes | year,
            data = df, cluster = ~cbsa)

# Model 4: Add metropolitan indicator
m4 <- feols(trump_share ~ modal_age_mean + log_total_votes + is_metro | year,
            data = df, cluster = ~cbsa)

# Display results
etable(m1, m2, m3, m4,
       dict = c(modal_age_mean = "Modal Tech Age (years)",
                log_total_votes = "Log Total Votes",
                is_metroTRUE = "Metropolitan"),
       se.below = TRUE,
       title = "Technology Age and Trump Vote Share")

cat("\nInterpretation: A 10-year increase in modal technology age is associated with")
cat(sprintf(" a %.2f percentage point increase in Trump vote share.\n\n",
            coef(m2)["modal_age_mean"] * 10))

# ============================================================================
# 2. CBSA Fixed Effects (within-CBSA variation)
# ============================================================================

cat("\n2. CBSA Fixed Effects (Within-CBSA Variation)\n")
cat("----------------------------------------------\n\n")

# Model 5: CBSA FE only
m5 <- feols(trump_share ~ modal_age_mean | cbsa, data = df, cluster = ~cbsa)

# Model 6: CBSA + Year FE (two-way)
m6 <- feols(trump_share ~ modal_age_mean | cbsa + year, data = df, cluster = ~cbsa)

etable(m5, m6,
       dict = c(modal_age_mean = "Modal Tech Age (years)"),
       se.below = TRUE,
       title = "CBSA Fixed Effects: Technology Age and Trump Vote Share")

cat("Note: With CBSA fixed effects, identification comes from within-CBSA")
cat(" changes in technology age over time.\n\n")

# ============================================================================
# 3. First-differences (changes in voting on changes in tech age)
# ============================================================================

cat("\n3. First-Difference Analysis\n")
cat("----------------------------\n\n")

# Filter to 2020 and 2024 (where we have lagged values)
df_diff <- df %>% filter(!is.na(d_trump_share) & !is.na(d_modal_age))

# Model 7: Change in Trump share on change in modal age
m7 <- feols(d_trump_share ~ d_modal_age, data = df_diff, cluster = ~cbsa)

# Model 8: Add year FE
m8 <- feols(d_trump_share ~ d_modal_age | year, data = df_diff, cluster = ~cbsa)

etable(m7, m8,
       dict = c(d_modal_age = "Change in Modal Tech Age"),
       se.below = TRUE,
       title = "First-Differences: Changes in Technology Age and Voting")

# ============================================================================
# 4. By-election analysis
# ============================================================================

cat("\n4. By-Election Year Analysis\n")
cat("----------------------------\n\n")

# Separate regressions for each election
m_2016 <- feols(trump_share ~ modal_age_mean + log_total_votes + is_metro,
                data = filter(df, year == 2016), vcov = "hetero")
m_2020 <- feols(trump_share ~ modal_age_mean + log_total_votes + is_metro,
                data = filter(df, year == 2020), vcov = "hetero")
m_2024 <- feols(trump_share ~ modal_age_mean + log_total_votes + is_metro,
                data = filter(df, year == 2024), vcov = "hetero")

etable(m_2016, m_2020, m_2024,
       headers = c("2016", "2020", "2024"),
       dict = c(modal_age_mean = "Modal Tech Age (years)",
                log_total_votes = "Log Total Votes",
                is_metroTRUE = "Metropolitan"),
       se.below = TRUE,
       title = "Technology Age Effect by Election Year")

# ============================================================================
# 5. Non-linear effects (technology terciles)
# ============================================================================

cat("\n5. Non-linear Effects (Technology Terciles)\n")
cat("--------------------------------------------\n\n")

# Create tercile dummies with "Low Tech Age" as reference
df <- df %>%
  mutate(
    tech_tercile_factor = factor(tech_tercile_label,
                                  levels = c("Low (Young Tech)", "Medium", "High (Old Tech)"))
  )

m_tercile <- feols(trump_share ~ tech_tercile_factor + log_total_votes + is_metro | year,
                   data = df, cluster = ~cbsa)

etable(m_tercile,
       dict = c("tech_tercile_factorMedium" = "Medium Tech Age",
                "tech_tercile_factorHigh (Old Tech)" = "High Tech Age",
                log_total_votes = "Log Total Votes",
                is_metroTRUE = "Metropolitan"),
       se.below = TRUE,
       title = "Technology Terciles and Trump Vote Share")

# ============================================================================
# 6. Summary of main results
# ============================================================================

cat("\n============================================\n")
cat("Summary of Main Results\n")
cat("============================================\n\n")

cat("Cross-sectional correlation:\n")
cat(sprintf("  - Raw correlation: r = %.3f\n",
            cor(df$modal_age_mean, df$trump_share, use = "complete.obs")))
cat(sprintf("  - Coefficient (with year FE): %.3f pp per year of tech age\n",
            coef(m2)["modal_age_mean"]))
cat(sprintf("  - A 10-year older tech base → +%.1f pp Trump vote share\n\n",
            coef(m2)["modal_age_mean"] * 10))

cat("Within-CBSA variation:\n")
cat(sprintf("  - CBSA + Year FE coefficient: %.3f\n", coef(m6)["modal_age_mean"]))
cat(sprintf("  - SE: %.3f, t = %.2f\n",
            se(m6)["modal_age_mean"],
            coef(m6)["modal_age_mean"] / se(m6)["modal_age_mean"]))

cat("\nTercile comparison (relative to Low Tech Age CBSAs):\n")
cat(sprintf("  - Medium Tech Age: +%.1f pp\n",
            coef(m_tercile)["tech_tercile_factorMedium"]))
cat(sprintf("  - High Tech Age: +%.1f pp\n",
            coef(m_tercile)["tech_tercile_factorHigh (Old Tech)"]))

# ============================================================================
# 7. Save models for later use
# ============================================================================

models <- list(
  bivariate = m1,
  year_fe = m2,
  with_controls = m4,
  cbsa_fe = m5,
  twoway_fe = m6,
  first_diff = m8,
  by_year_2016 = m_2016,
  by_year_2020 = m_2020,
  by_year_2024 = m_2024,
  terciles = m_tercile
)

saveRDS(models, "../data/main_models.rds")
saveRDS(df, "../data/analysis_data.rds")  # Updated with tercile factor

cat("\nModels saved to ../data/main_models.rds\n")
