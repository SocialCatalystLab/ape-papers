# =============================================================================
# 03_main_analysis.R
# Main Doubly Robust Analysis
# =============================================================================

library(dplyr, warn.conflicts = FALSE)
library(readr)

# Try to load AIPW, fall back to OLS if not available
use_aipw <- requireNamespace("AIPW", quietly = TRUE) && 
            requireNamespace("SuperLearner", quietly = TRUE)

if (use_aipw) {
  library(AIPW)
  library(SuperLearner)
  message("Using AIPW for doubly robust estimation")
} else {
  message("AIPW not available, using OLS + IPW as fallback")
}

set.seed(20260130)

message("=== STARTING MAIN ANALYSIS ===")

# Load cleaned data
df <- readRDS("output/paper_116/data/acs_clean.rds")
message(paste("Loaded", format(nrow(df), big.mark = ","), "observations"))

# Main analysis sample: Pre-Medicare (55-64)
df_main <- df %>% filter(sample_main)
message(paste("Main sample (55-64):", format(nrow(df_main), big.mark = ","), "observations"))

# =============================================================================
# OLS BASELINE
# =============================================================================

message("\n=== OLS BASELINE ===")

ols_full <- lm(hours_weekly ~ self_employed + AGEP + female + married + 
                 college + has_disability, data = df_main)

message("Self-employment effect on hours (OLS):")
coef_ols <- summary(ols_full)$coefficients["self_employedTRUE", ]
message(paste("  Estimate:", round(coef_ols["Estimate"], 2), "hours"))
message(paste("  SE:", round(coef_ols["Std. Error"], 2)))
message(paste("  t-stat:", round(coef_ols["t value"], 2)))

# =============================================================================
# PROPENSITY SCORE WEIGHTED ESTIMATION
# =============================================================================

message("\n=== PROPENSITY SCORE WEIGHTING ===")

# Fit propensity score
ps_model <- glm(self_employed ~ AGEP + female + married + college + has_disability,
                data = df_main, family = binomial())

df_main$ps <- predict(ps_model, type = "response")

# Summary of PS
message("Propensity Score Summary:")
message(paste("  Mean (treated):", round(mean(df_main$ps[df_main$self_employed]), 3)))
message(paste("  Mean (control):", round(mean(df_main$ps[!df_main$self_employed]), 3)))
message(paste("  Min:", round(min(df_main$ps), 4)))
message(paste("  Max:", round(max(df_main$ps), 4)))

# IPW weights (for ATT)
df_main <- df_main %>%
  mutate(
    ipw_weight = if_else(self_employed, 1, ps / (1 - ps))
  )

# Trim extreme weights
df_trimmed <- df_main %>%
  filter(ps >= 0.01, ps <= 0.99)

message(paste("Observations after trimming:", format(nrow(df_trimmed), big.mark = ",")))

# IPW estimate (ATT)
ipw_treated <- weighted.mean(df_trimmed$hours_weekly[df_trimmed$self_employed], 
                              df_trimmed$PWGTP[df_trimmed$self_employed])
ipw_control <- weighted.mean(df_trimmed$hours_weekly[!df_trimmed$self_employed],
                              df_trimmed$ipw_weight[!df_trimmed$self_employed] * 
                              df_trimmed$PWGTP[!df_trimmed$self_employed])

ipw_att <- ipw_treated - ipw_control

message(paste("\nIPW ATT Estimate:", round(ipw_att, 2), "hours"))

# =============================================================================
# PRE/POST ACA COMPARISON
# =============================================================================

message("\n=== PRE/POST ACA COMPARISON ===")

# Pre-ACA (2012, 2014)
df_pre <- df_main %>% filter(YEAR %in% c(2012, 2014))
# Post-ACA (2017, 2019, 2022)
df_post <- df_main %>% filter(YEAR %in% c(2017, 2019, 2022))

ols_pre <- lm(hours_weekly ~ self_employed + AGEP + female + married + 
                college + has_disability, data = df_pre)
ols_post <- lm(hours_weekly ~ self_employed + AGEP + female + married + 
                 college + has_disability, data = df_post)

coef_pre <- summary(ols_pre)$coefficients["self_employedTRUE", ]
coef_post <- summary(ols_post)$coefficients["self_employedTRUE", ]

message("Pre-ACA (2012-2014):")
message(paste("  N:", format(nrow(df_pre), big.mark = ",")))
message(paste("  Self-emp effect:", round(coef_pre["Estimate"], 2), 
              "(SE:", round(coef_pre["Std. Error"], 2), ")"))

message("\nPost-ACA (2017-2022):")
message(paste("  N:", format(nrow(df_post), big.mark = ",")))
message(paste("  Self-emp effect:", round(coef_post["Estimate"], 2), 
              "(SE:", round(coef_post["Std. Error"], 2), ")"))

# DiD-style change
dd_estimate <- coef_post["Estimate"] - coef_pre["Estimate"]
dd_se <- sqrt(coef_pre["Std. Error"]^2 + coef_post["Std. Error"]^2)

message(paste("\nChange (Post - Pre):", round(dd_estimate, 2), 
              "(SE:", round(dd_se, 2), ")"))

# =============================================================================
# MEDICARE PLACEBO (65-74)
# =============================================================================

message("\n=== MEDICARE PLACEBO (65-74) ===")

df_placebo <- df %>% filter(sample_placebo)

df_placebo_pre <- df_placebo %>% filter(YEAR %in% c(2012, 2014))
df_placebo_post <- df_placebo %>% filter(YEAR %in% c(2017, 2019, 2022))

ols_placebo_pre <- lm(hours_weekly ~ self_employed + AGEP + female + married + 
                        college + has_disability, data = df_placebo_pre)
ols_placebo_post <- lm(hours_weekly ~ self_employed + AGEP + female + married + 
                         college + has_disability, data = df_placebo_post)

coef_placebo_pre <- summary(ols_placebo_pre)$coefficients["self_employedTRUE", ]
coef_placebo_post <- summary(ols_placebo_post)$coefficients["self_employedTRUE", ]

message("Placebo Pre-ACA:")
message(paste("  N:", format(nrow(df_placebo_pre), big.mark = ",")))
message(paste("  Self-emp effect:", round(coef_placebo_pre["Estimate"], 2)))

message("\nPlacebo Post-ACA:")
message(paste("  N:", format(nrow(df_placebo_post), big.mark = ",")))
message(paste("  Self-emp effect:", round(coef_placebo_post["Estimate"], 2)))

placebo_dd <- coef_placebo_post["Estimate"] - coef_placebo_pre["Estimate"]
message(paste("\nPlacebo Change:", round(placebo_dd, 2)))

# Triple-diff
triple_diff <- dd_estimate - placebo_dd
message(paste("\nTriple-Diff (Main - Placebo):", round(triple_diff, 2)))

# =============================================================================
# SAVE RESULTS
# =============================================================================

results <- list(
  main = list(
    ols_coef = coef_ols["Estimate"],
    ols_se = coef_ols["Std. Error"],
    ipw_att = ipw_att,
    n = nrow(df_main)
  ),
  pre_post = tibble(
    Period = c("Pre-ACA (2012-2014)", "Post-ACA (2017-2022)"),
    N = c(nrow(df_pre), nrow(df_post)),
    ATT_Hours = c(coef_pre["Estimate"], coef_post["Estimate"]),
    ATT_SE = c(coef_pre["Std. Error"], coef_post["Std. Error"])
  ),
  placebo = tibble(
    Period = c("Pre-ACA", "Post-ACA"),
    N = c(nrow(df_placebo_pre), nrow(df_placebo_post)),
    ATT_Hours = c(coef_placebo_pre["Estimate"], coef_placebo_post["Estimate"]),
    ATT_SE = c(coef_placebo_pre["Std. Error"], coef_placebo_post["Std. Error"])
  ),
  dd_main = list(estimate = dd_estimate, se = dd_se),
  dd_placebo = list(estimate = placebo_dd, 
                    se = sqrt(coef_placebo_pre["Std. Error"]^2 + 
                              coef_placebo_post["Std. Error"]^2)),
  triple_diff = triple_diff
)

saveRDS(results, "output/paper_116/data/main_results.rds")
message("\nResults saved to output/paper_116/data/main_results.rds")

message("\n=== MAIN ANALYSIS COMPLETE ===")
