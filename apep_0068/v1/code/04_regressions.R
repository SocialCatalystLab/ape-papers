# ==============================================================================
# Paper 91: Credit, Social Networks, and Political Polarization
# 04_regressions.R - Regression analysis for Part 2
# ==============================================================================

source("00_packages.R")

# Load data
df <- readRDS("../data/analysis_data.rds")

# Variable labels for tables
setFixest_dict(c(
  credit_score_z = "Credit Score (Z)",
  ec_z = "Economic Connectedness (Z)",
  delinquency_z = "Delinquency Rate (Z)",
  student_loan_z = "Student Loan Balance (Z)",
  friending_bias = "Friending Bias",
  clustering = "Clustering",
  hhinc_median_2010 = "Median HH Income (\\$1000)",
  frac_coll_2010 = "College Share",
  share_white_2010 = "Share White",
  share_black_2010 = "Share Black",
  popdensity = "Pop. Density (log)",
  poor_share_2010 = "Poverty Share",
  gini_2010 = "Gini Coefficient",
  emp_2010 = "Employment Rate",
  pct_gop_2020 = "GOP Vote Share 2020",
  gop_change_16_24 = "GOP Shift 2016-24"
))

# Prepare data
df_reg <- df %>%
  filter(!is.na(pct_gop_2020) & !is.na(credit_score_z) & !is.na(ec_z)) %>%
  mutate(
    log_popdensity = log(popdensity + 1),
    hhinc_1000 = hhinc_median_2010 / 1000
  )

cat(sprintf("Regression sample: N = %d counties\n", nrow(df_reg)))

# ==============================================================================
# TABLE 3: CREDIT AND POLITICS
# ==============================================================================

cat("\nEstimating Table 3: Credit and Politics...\n")

# Model 1: Bivariate
m3_1 <- feols(pct_gop_2020 ~ credit_score_z, data = df_reg)

# Model 2: Add income
m3_2 <- feols(pct_gop_2020 ~ credit_score_z + hhinc_1000, data = df_reg)

# Model 3: Add education
m3_3 <- feols(pct_gop_2020 ~ credit_score_z + hhinc_1000 + frac_coll_2010, data = df_reg)

# Model 4: Add demographics
m3_4 <- feols(pct_gop_2020 ~ credit_score_z + hhinc_1000 + frac_coll_2010 +
                share_white_2010 + share_black_2010, data = df_reg)

# Model 5: Add urban/density
m3_5 <- feols(pct_gop_2020 ~ credit_score_z + hhinc_1000 + frac_coll_2010 +
                share_white_2010 + share_black_2010 + log_popdensity, data = df_reg)

# Model 6: Full specification
m3_6 <- feols(pct_gop_2020 ~ credit_score_z + hhinc_1000 + frac_coll_2010 +
                share_white_2010 + share_black_2010 + log_popdensity +
                poor_share_2010 + gini_2010 + emp_2010, data = df_reg)

# Print table
etable(m3_1, m3_2, m3_3, m3_4, m3_5, m3_6,
       fitstat = ~ r2 + n,
       se.below = TRUE,
       headers = c("(1)", "(2)", "(3)", "(4)", "(5)", "(6)"))

# Export to LaTeX
etable(m3_1, m3_2, m3_3, m3_4, m3_5, m3_6,
       tex = TRUE,
       style.tex = style.tex("aer"),
       fitstat = ~ r2 + n,
       title = "Credit Scores and Republican Vote Share, 2020",
       label = "tab:credit_politics",
       file = "../tables/tab3_credit_politics.tex")

# ==============================================================================
# TABLE 4: SOCIAL CAPITAL AND POLITICS
# ==============================================================================

cat("\nEstimating Table 4: Social Capital and Politics...\n")

# Model 1: Bivariate EC
m4_1 <- feols(pct_gop_2020 ~ ec_z, data = df_reg)

# Model 2: Add income
m4_2 <- feols(pct_gop_2020 ~ ec_z + hhinc_1000, data = df_reg)

# Model 3: Add education
m4_3 <- feols(pct_gop_2020 ~ ec_z + hhinc_1000 + frac_coll_2010, data = df_reg)

# Model 4: Add demographics
m4_4 <- feols(pct_gop_2020 ~ ec_z + hhinc_1000 + frac_coll_2010 +
                share_white_2010 + share_black_2010, data = df_reg)

# Model 5: Add urban/density
m4_5 <- feols(pct_gop_2020 ~ ec_z + hhinc_1000 + frac_coll_2010 +
                share_white_2010 + share_black_2010 + log_popdensity, data = df_reg)

# Model 6: Full specification
m4_6 <- feols(pct_gop_2020 ~ ec_z + hhinc_1000 + frac_coll_2010 +
                share_white_2010 + share_black_2010 + log_popdensity +
                poor_share_2010 + gini_2010 + emp_2010, data = df_reg)

etable(m4_1, m4_2, m4_3, m4_4, m4_5, m4_6,
       fitstat = ~ r2 + n,
       se.below = TRUE,
       headers = c("(1)", "(2)", "(3)", "(4)", "(5)", "(6)"))

etable(m4_1, m4_2, m4_3, m4_4, m4_5, m4_6,
       tex = TRUE,
       style.tex = style.tex("aer"),
       fitstat = ~ r2 + n,
       title = "Economic Connectedness and Republican Vote Share, 2020",
       label = "tab:ec_politics",
       file = "../tables/tab4_ec_politics.tex")

# ==============================================================================
# TABLE 5: COMBINED MODEL
# ==============================================================================

cat("\nEstimating Table 5: Combined Model...\n")

# Model 1: Credit only (full controls)
m5_1 <- feols(pct_gop_2020 ~ credit_score_z + hhinc_1000 + frac_coll_2010 +
                share_white_2010 + share_black_2010 + log_popdensity, data = df_reg)

# Model 2: EC only (full controls)
m5_2 <- feols(pct_gop_2020 ~ ec_z + hhinc_1000 + frac_coll_2010 +
                share_white_2010 + share_black_2010 + log_popdensity, data = df_reg)

# Model 3: Both credit and EC
m5_3 <- feols(pct_gop_2020 ~ credit_score_z + ec_z + hhinc_1000 + frac_coll_2010 +
                share_white_2010 + share_black_2010 + log_popdensity, data = df_reg)

# Model 4: Add delinquency
m5_4 <- feols(pct_gop_2020 ~ credit_score_z + ec_z + delinquency_z +
                hhinc_1000 + frac_coll_2010 +
                share_white_2010 + share_black_2010 + log_popdensity, data = df_reg)

# Model 5: Add friending bias
m5_5 <- feols(pct_gop_2020 ~ credit_score_z + ec_z + delinquency_z + friending_bias +
                hhinc_1000 + frac_coll_2010 +
                share_white_2010 + share_black_2010 + log_popdensity, data = df_reg)

# Model 6: Kitchen sink
m5_6 <- feols(pct_gop_2020 ~ credit_score_z + ec_z + delinquency_z + friending_bias +
                clustering + student_loan_z +
                hhinc_1000 + frac_coll_2010 +
                share_white_2010 + share_black_2010 + log_popdensity +
                poor_share_2010 + gini_2010 + emp_2010, data = df_reg)

etable(m5_1, m5_2, m5_3, m5_4, m5_5, m5_6,
       fitstat = ~ r2 + n,
       se.below = TRUE,
       headers = c("Credit", "EC", "Both", "+Delinq", "+Bias", "Full"))

etable(m5_1, m5_2, m5_3, m5_4, m5_5, m5_6,
       tex = TRUE,
       style.tex = style.tex("aer"),
       fitstat = ~ r2 + n,
       title = "Credit, Social Capital, and Republican Vote Share: Combined Models",
       label = "tab:combined",
       file = "../tables/tab5_combined.tex")

# ==============================================================================
# TABLE 6: POLARIZATION (CHANGE IN VOTE SHARE)
# ==============================================================================

cat("\nEstimating Table 6: Polarization Regressions...\n")

df_pol <- df_reg %>% filter(!is.na(gop_change_16_24))

# Model 1: Credit and change
m6_1 <- feols(gop_change_16_24 ~ credit_score_z, data = df_pol)

# Model 2: EC and change
m6_2 <- feols(gop_change_16_24 ~ ec_z, data = df_pol)

# Model 3: Both
m6_3 <- feols(gop_change_16_24 ~ credit_score_z + ec_z, data = df_pol)

# Model 4: With controls
m6_4 <- feols(gop_change_16_24 ~ credit_score_z + ec_z +
                hhinc_1000 + frac_coll_2010 +
                share_white_2010 + share_black_2010 + log_popdensity, data = df_pol)

# Model 5: Full controls
m6_5 <- feols(gop_change_16_24 ~ credit_score_z + ec_z + delinquency_z +
                hhinc_1000 + frac_coll_2010 +
                share_white_2010 + share_black_2010 + log_popdensity +
                poor_share_2010 + gini_2010, data = df_pol)

# Model 6: Controlling for 2016 baseline
m6_6 <- feols(gop_change_16_24 ~ credit_score_z + ec_z + delinquency_z +
                pct_gop_2016 +
                hhinc_1000 + frac_coll_2010 +
                share_white_2010 + share_black_2010 + log_popdensity, data = df_pol)

etable(m6_1, m6_2, m6_3, m6_4, m6_5, m6_6,
       fitstat = ~ r2 + n,
       se.below = TRUE,
       headers = c("Credit", "EC", "Both", "Controls", "Full", "Baseline"))

etable(m6_1, m6_2, m6_3, m6_4, m6_5, m6_6,
       tex = TRUE,
       style.tex = style.tex("aer"),
       fitstat = ~ r2 + n,
       title = "Credit, Social Capital, and Political Shift 2016--2024",
       label = "tab:polarization",
       file = "../tables/tab6_polarization.tex")

# ==============================================================================
# KEY RESULTS SUMMARY
# ==============================================================================

cat("\n\n=== KEY REGRESSION RESULTS ===\n\n")

# Credit effect
cat("TABLE 3 - Credit Score:\n")
cat(sprintf("  Bivariate: 1 SD higher credit score -> %.1f pp %s GOP\n",
            abs(coef(m3_1)["credit_score_z"]) * 100,
            ifelse(coef(m3_1)["credit_score_z"] > 0, "more", "less")))
cat(sprintf("  With full controls: %.1f pp\n",
            abs(coef(m3_6)["credit_score_z"]) * 100))

# EC effect
cat("\nTABLE 4 - Economic Connectedness:\n")
cat(sprintf("  Bivariate: 1 SD higher EC -> %.1f pp %s GOP\n",
            abs(coef(m4_1)["ec_z"]) * 100,
            ifelse(coef(m4_1)["ec_z"] > 0, "more", "less")))
cat(sprintf("  With full controls: %.1f pp\n",
            abs(coef(m4_6)["ec_z"]) * 100))

# Combined
cat("\nTABLE 5 - Horse Race:\n")
cat(sprintf("  Credit effect when both included: %.1f pp\n",
            abs(coef(m5_3)["credit_score_z"]) * 100))
cat(sprintf("  EC effect when both included: %.1f pp\n",
            abs(coef(m5_3)["ec_z"]) * 100))

# Polarization
cat("\nTABLE 6 - Polarization:\n")
cat(sprintf("  1 SD higher EC -> %.2f pp %s GOP shift 2016-24\n",
            abs(coef(m6_4)["ec_z"]) * 100,
            ifelse(coef(m6_4)["ec_z"] > 0, "more", "less")))

cat("\n=== TABLES SAVED ===\n")
cat("  ../tables/tab3_credit_politics.tex\n")
cat("  ../tables/tab4_ec_politics.tex\n")
cat("  ../tables/tab5_combined.tex\n")
cat("  ../tables/tab6_polarization.tex\n")
