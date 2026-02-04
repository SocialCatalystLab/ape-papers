# =============================================================================
# 04d_industry_heterogeneity.R
# Industry Heterogeneity Analysis: Evidence by Bargaining Intensity
# =============================================================================

source("00_packages.R")

# =============================================================================
# Load Industry Data
# =============================================================================

# Check if industry data exists
if (!file.exists("data/qwi_industry.rds")) {
  cat("Industry data not found. Run 01b_fetch_qwi_industry.R first.\n")
  stop("Missing industry data")
}

qwi_industry <- readRDS("data/qwi_industry.rds")
industry_class <- readRDS("data/industry_classification.rds")

cat("=== Industry Heterogeneity Analysis ===\n")
cat("Testing Cullen-Pakzad-Hurson Prediction P3:\n")
cat("  Effects should be larger in high-bargaining industries\n")
cat("  where individual negotiation is common.\n\n")

cat("Loaded", nrow(qwi_industry), "observations across",
    length(unique(qwi_industry$industry_code)), "industries\n")

# =============================================================================
# Summary Statistics by Industry
# =============================================================================

cat("\n=== Summary by Industry ===\n")

industry_summary <- qwi_industry %>%
  group_by(industry_name, bargaining_type) %>%
  summarise(
    n_obs = n(),
    n_states = n_distinct(state_fips),
    mean_earn_hire = mean(EarnHirAS, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(bargaining_type, desc(mean_earn_hire))

print(industry_summary)

# =============================================================================
# DiD by Industry (TWFE at state-quarter level)
# =============================================================================

cat("\n=== DiD by Industry ===\n")

industry_results <- list()

for (ind in unique(qwi_industry$industry_code)) {
  ind_name <- qwi_industry %>%
    filter(industry_code == ind) %>%
    pull(industry_name) %>%
    unique()

  bargaining <- qwi_industry %>%
    filter(industry_code == ind) %>%
    pull(bargaining_type) %>%
    unique()

  cat("\nIndustry:", ind_name, "(", bargaining, "bargaining )\n")

  # Filter to this industry
  qwi_ind <- qwi_industry %>%
    filter(industry_code == ind, !is.na(log_earn_hire), is.finite(log_earn_hire)) %>%
    mutate(
      post = cohort > 0 & qtr_num >= cohort,
      state_id = as.numeric(factor(state_fips))
    )

  # Check sample size
  if (nrow(qwi_ind) < 100) {
    cat("  Insufficient observations:", nrow(qwi_ind), "\n")
    next
  }

  # TWFE
  twfe_ind <- tryCatch({
    feols(
      log_earn_hire ~ post | state_fips + qtr_num,
      data = qwi_ind,
      cluster = ~state_fips
    )
  }, error = function(e) {
    cat("  TWFE failed:", e$message, "\n")
    return(NULL)
  })

  if (!is.null(twfe_ind)) {
    industry_results[[ind]] <- list(
      industry_code = ind,
      industry_name = ind_name,
      bargaining_type = bargaining,
      coef = coef(twfe_ind)["postTRUE"],
      se = se(twfe_ind)["postTRUE"],
      n_obs = nrow(qwi_ind),
      n_states = n_distinct(qwi_ind$state_fips)
    )

    cat("  ATT:", round(industry_results[[ind]]$coef, 4),
        "  SE:", round(industry_results[[ind]]$se, 4), "\n")
  }
}

# =============================================================================
# Compile Results
# =============================================================================

cat("\n=== Industry Results Summary ===\n")

industry_results_df <- bind_rows(lapply(industry_results, as_tibble)) %>%
  mutate(
    t_stat = coef / se,
    p_value = 2 * pnorm(-abs(t_stat)),
    significant = p_value < 0.05,
    coef_pct = (exp(coef) - 1) * 100  # Convert to percentage
  ) %>%
  arrange(bargaining_type, industry_name)

print(industry_results_df %>% select(industry_name, bargaining_type, coef_pct, se, t_stat, p_value))

# =============================================================================
# Test P3: High vs Low Bargaining
# =============================================================================

cat("\n=== Testing Prediction P3: High vs Low Bargaining ===\n")

high_bargaining <- industry_results_df %>%
  filter(bargaining_type == "High")

low_bargaining <- industry_results_df %>%
  filter(bargaining_type == "Low")

if (nrow(high_bargaining) > 0 && nrow(low_bargaining) > 0) {
  mean_high <- mean(high_bargaining$coef, na.rm = TRUE)
  mean_low <- mean(low_bargaining$coef, na.rm = TRUE)

  cat("\nAverage ATT in high-bargaining industries:", round(mean_high, 4),
      "(", round((exp(mean_high) - 1) * 100, 1), "%)\n")
  cat("Average ATT in low-bargaining industries:", round(mean_low, 4),
      "(", round((exp(mean_low) - 1) * 100, 1), "%)\n")
  cat("Difference (High - Low):", round(mean_high - mean_low, 4), "\n")

  cat("\nPrediction P3 (effects larger in high-bargaining):\n")
  if (mean_high < mean_low) {
    cat("  SUPPORTED: Effects more negative in high-bargaining industries\n")
    cat("  (Consistent with commitment mechanism operating through negotiation)\n")
  } else if (abs(mean_high - mean_low) < 0.01) {
    cat("  NOT SUPPORTED: Effects similar across bargaining intensity\n")
    cat("  (Suggests commitment mechanism not the dominant channel)\n")
  } else {
    cat("  NOT SUPPORTED: Effects less negative in high-bargaining industries\n")
    cat("  (Inconsistent with commitment mechanism)\n")
  }
} else {
  cat("Insufficient data to test P3\n")
}

# =============================================================================
# Pooled Test: High vs Low Bargaining Interaction
# =============================================================================

cat("\n=== Pooled Interaction Test ===\n")

qwi_pooled <- qwi_industry %>%
  filter(!is.na(log_earn_hire), is.finite(log_earn_hire)) %>%
  mutate(
    post = cohort > 0 & qtr_num >= cohort,
    high_bargaining = bargaining_type == "High"
  )

pooled_test <- tryCatch({
  feols(
    log_earn_hire ~ post * high_bargaining | state_fips + qtr_num + industry_code,
    data = qwi_pooled,
    cluster = ~state_fips
  )
}, error = function(e) {
  cat("Pooled test failed:", e$message, "\n")
  return(NULL)
})

if (!is.null(pooled_test)) {
  cat("\nPooled regression with Post × High-Bargaining interaction:\n")
  print(summary(pooled_test))

  cat("\nInterpretation:\n")
  cat("  post:TRUE coefficient = ATT in low-bargaining industries\n")
  cat("  post:TRUE:high_bargainingTRUE = Additional effect in high-bargaining\n")
}

# =============================================================================
# Save Results
# =============================================================================

saveRDS(industry_results_df, "data/industry_results.rds")
if (!is.null(pooled_test)) {
  saveRDS(pooled_test, "data/pooled_industry_test.rds")
}

cat("\n=== Industry Heterogeneity Analysis Complete ===\n")
