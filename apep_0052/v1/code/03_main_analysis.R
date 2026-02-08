# ==============================================================================
# Paper 68: Broadband Internet and Moral Foundations in Local Governance
# 03_main_analysis.R - Main DiD Analysis using Callaway-Sant'Anna
# ==============================================================================

source("code/00_packages.R")

# ==============================================================================
# 1. LOAD ANALYSIS DATA
# ==============================================================================
cat("=== Loading Analysis Data ===\n")

analysis <- arrow::read_parquet("data/analysis_panel.parquet")
cat(sprintf("  Loaded: %d place-years, %d places\n",
            nrow(analysis), n_distinct(analysis$st_fips)))

# Filter to places with sufficient data
# Require at least 3 years of data per place
places_keep <- analysis %>%
  group_by(st_fips) %>%
  filter(n() >= 3) %>%
  ungroup()

cat(sprintf("  After filtering (3+ years): %d place-years, %d places\n",
            nrow(places_keep), n_distinct(places_keep$st_fips)))

# Use filtered data
df <- places_keep

# ==============================================================================
# 2. CALLAWAY-SANT'ANNA: INDIVIDUALIZING FOUNDATIONS
# ==============================================================================
cat("\n=== C-S Estimation: Individualizing Foundations ===\n")

# Prepare data for did package
# Need: outcome (yname), time (tname), id (idname), treatment cohort (gname)
did_data <- df %>%
  mutate(
    # For did package, never-treated must have gname = 0
    gname = ifelse(treated, treat_year, 0)
  ) %>%
  # Ensure numeric ID
  mutate(id = as.numeric(factor(st_fips)))

# Run Callaway-Sant'Anna
cs_individual <- att_gt(
  yname = "individualizing",
  tname = "year",
  idname = "id",
  gname = "gname",
  data = did_data,
  control_group = "nevertreated",  # Use never-treated as control
  anticipation = 0,
  est_method = "dr",  # Doubly robust
  clustervars = "state_fips",  # Cluster at state level
  bstrap = TRUE,
  biters = 1000,
  print_details = FALSE
)

cat("\n  Group-Time ATT Summary:\n")
summary(cs_individual)

# Aggregate to event time
es_individual <- tryCatch({
  aggte(cs_individual, type = "dynamic", na.rm = TRUE)
}, error = function(e) {
  cat(sprintf("  Event study aggregation failed: %s\n", e$message))
  NULL
})

cat("\n  Event Study Aggregation (Individualizing):\n")
summary(es_individual)

# Aggregate to overall ATT
att_individual <- aggte(cs_individual, type = "simple", na.rm = TRUE)
cat(sprintf("\n  Overall ATT (Individualizing): %.4f (SE: %.4f)\n",
            att_individual$overall.att, att_individual$overall.se))

# ==============================================================================
# 3. CALLAWAY-SANT'ANNA: BINDING FOUNDATIONS
# ==============================================================================
cat("\n=== C-S Estimation: Binding Foundations ===\n")

cs_binding <- att_gt(
  yname = "binding",
  tname = "year",
  idname = "id",
  gname = "gname",
  data = did_data,
  control_group = "nevertreated",
  anticipation = 0,
  est_method = "dr",
  clustervars = "state_fips",
  bstrap = TRUE,
  biters = 1000,
  print_details = FALSE
)

es_binding <- aggte(cs_binding, type = "dynamic", na.rm = TRUE)
att_binding <- aggte(cs_binding, type = "simple", na.rm = TRUE)

cat(sprintf("\n  Overall ATT (Binding): %.4f (SE: %.4f)\n",
            att_binding$overall.att, att_binding$overall.se))

# ==============================================================================
# 4. CALLAWAY-SANT'ANNA: UNIVERSALISM/COMMUNAL RATIO
# ==============================================================================
cat("\n=== C-S Estimation: Universalism/Communal Ratio ===\n")

cs_ratio <- att_gt(
  yname = "log_univ_comm",  # Log difference for better properties
  tname = "year",
  idname = "id",
  gname = "gname",
  data = did_data,
  control_group = "nevertreated",
  anticipation = 0,
  est_method = "dr",
  clustervars = "state_fips",
  bstrap = TRUE,
  biters = 1000,
  print_details = FALSE
)

es_ratio <- aggte(cs_ratio, type = "dynamic", na.rm = TRUE)
att_ratio <- aggte(cs_ratio, type = "simple", na.rm = TRUE)

cat(sprintf("\n  Overall ATT (Log Univ/Comm): %.4f (SE: %.4f)\n",
            att_ratio$overall.att, att_ratio$overall.se))

# ==============================================================================
# 5. INDIVIDUAL FOUNDATION ESTIMATES
# ==============================================================================
cat("\n=== Individual Foundation Estimates ===\n")

foundations <- c("care_p", "fairness_p", "loyalty_p", "authority_p", "sanctity_p")
foundation_results <- list()

for (fnd in foundations) {
  cat(sprintf("  Estimating: %s...\n", fnd))

  cs_fnd <- att_gt(
    yname = fnd,
    tname = "year",
    idname = "id",
    gname = "gname",
    data = did_data,
    control_group = "nevertreated",
    anticipation = 0,
    est_method = "dr",
    clustervars = "state_fips",
    bstrap = TRUE,
    biters = 500,  # Fewer for speed
    print_details = FALSE
  )

  att_fnd <- aggte(cs_fnd, type = "simple", na.rm = TRUE)
  es_fnd <- aggte(cs_fnd, type = "dynamic", na.rm = TRUE)

  foundation_results[[fnd]] <- list(
    att = att_fnd$overall.att,
    se = att_fnd$overall.se,
    es = es_fnd
  )

  cat(sprintf("    ATT: %.4f (SE: %.4f)\n", att_fnd$overall.att, att_fnd$overall.se))
}

# ==============================================================================
# 6. PRE-TREND TESTS
# ==============================================================================
cat("\n=== Pre-Trend Tests ===\n")

# Extract pre-period coefficients and test joint significance
pretrend_test <- function(es_object) {
  # Get event study data frame
  es_df <- data.frame(
    time = es_object$egt,
    att = es_object$att.egt,
    se = es_object$se.egt
  ) %>%
    filter(time < 0)  # Pre-period only

  if (nrow(es_df) == 0) {
    return(list(chi2 = NA, pval = NA, n_pre = 0))
  }

  # Simple joint test: sum of squared t-stats
  t_stats <- es_df$att / es_df$se
  chi2 <- sum(t_stats^2, na.rm = TRUE)
  pval <- 1 - pchisq(chi2, df = sum(!is.na(t_stats)))

  return(list(chi2 = chi2, pval = pval, n_pre = nrow(es_df)))
}

pretrend_individual <- pretrend_test(es_individual)
pretrend_binding <- pretrend_test(es_binding)
pretrend_ratio <- pretrend_test(es_ratio)

cat(sprintf("  Individualizing: Chi2 = %.2f, p = %.3f (n_pre = %d)\n",
            pretrend_individual$chi2, pretrend_individual$pval, pretrend_individual$n_pre))
cat(sprintf("  Binding: Chi2 = %.2f, p = %.3f (n_pre = %d)\n",
            pretrend_binding$chi2, pretrend_binding$pval, pretrend_binding$n_pre))
cat(sprintf("  Log Univ/Comm: Chi2 = %.2f, p = %.3f (n_pre = %d)\n",
            pretrend_ratio$chi2, pretrend_ratio$pval, pretrend_ratio$n_pre))

# ==============================================================================
# 7. HONESTDID SENSITIVITY ANALYSIS
# ==============================================================================
cat("\n=== HonestDiD Sensitivity Analysis ===\n")

# Function to run HonestDiD on CS results
run_honestdid <- function(cs_object, outcome_name) {
  tryCatch({
    # Extract event study for HonestDiD
    es <- aggte(cs_object, type = "dynamic", na.rm = TRUE)

    # HonestDiD needs: l_vec (pre-period), betahat, sigma
    honest_results <- HonestDiD::createSensitivityResults(
      betahat = es$att.egt,
      sigma = diag(es$se.egt^2),
      numPrePeriods = sum(es$egt < 0),
      numPostPeriods = sum(es$egt >= 0),
      Mvec = seq(0, 0.3, by = 0.05),  # Grid of M values
      l_vec = rep(1, sum(es$egt >= 0))  # Equal weights on post-periods
    )

    cat(sprintf("  %s: HonestDiD computed for M in [0, 0.3]\n", outcome_name))
    return(honest_results)
  }, error = function(e) {
    cat(sprintf("  %s: HonestDiD failed - %s\n", outcome_name, e$message))
    return(NULL)
  })
}

# Run for main outcomes (if HonestDiD is available and works)
honest_individual <- run_honestdid(cs_individual, "Individualizing")
honest_binding <- run_honestdid(cs_binding, "Binding")

# ==============================================================================
# 8. TWFE COMPARISON (for reference)
# ==============================================================================
cat("\n=== TWFE Comparison (for reference) ===\n")

# Simple TWFE (potentially biased with heterogeneous effects)
twfe_individual <- feols(
  individualizing ~ treat_post | place_id + year,
  data = df,
  cluster = ~state_fips
)

twfe_binding <- feols(
  binding ~ treat_post | place_id + year,
  data = df,
  cluster = ~state_fips
)

twfe_ratio <- feols(
  log_univ_comm ~ treat_post | place_id + year,
  data = df,
  cluster = ~state_fips
)

cat("\n  TWFE Results:\n")
etable(twfe_individual, twfe_binding, twfe_ratio,
       headers = c("Individualizing", "Binding", "Log Univ/Comm"),
       fitstat = ~ r2 + n)

# ==============================================================================
# 9. BACON DECOMPOSITION (DIAGNOSTIC)
# ==============================================================================
cat("\n=== Bacon Decomposition ===\n")

# Check TWFE weights
bacon_individual <- bacon(
  individualizing ~ treat_post,
  data = df %>% filter(treated | !any(treated)),  # Need some variation
  id_var = "st_fips",
  time_var = "year"
)

cat("  Decomposition of TWFE estimator:\n")
print(bacon_individual)

# ==============================================================================
# 10. SAVE RESULTS
# ==============================================================================
cat("\n=== Saving Results ===\n")

# Create results summary
results_summary <- tibble(
  Outcome = c("Individualizing", "Binding", "Log Univ/Comm Ratio",
              "Care", "Fairness", "Loyalty", "Authority", "Sanctity"),
  ATT = c(att_individual$overall.att,
          att_binding$overall.att,
          att_ratio$overall.att,
          foundation_results$care_p$att,
          foundation_results$fairness_p$att,
          foundation_results$loyalty_p$att,
          foundation_results$authority_p$att,
          foundation_results$sanctity_p$att),
  SE = c(att_individual$overall.se,
         att_binding$overall.se,
         att_ratio$overall.se,
         foundation_results$care_p$se,
         foundation_results$fairness_p$se,
         foundation_results$loyalty_p$se,
         foundation_results$authority_p$se,
         foundation_results$sanctity_p$se),
  Estimator = "Callaway-Sant'Anna"
) %>%
  mutate(
    t_stat = ATT / SE,
    p_value = 2 * (1 - pnorm(abs(t_stat))),
    sig = case_when(
      p_value < 0.01 ~ "***",
      p_value < 0.05 ~ "**",
      p_value < 0.10 ~ "*",
      TRUE ~ ""
    )
  )

print(results_summary)
write_csv(results_summary, "tables/main_results.csv")

# Save event study data for figures
es_data <- bind_rows(
  data.frame(
    outcome = "Individualizing",
    time = es_individual$egt,
    att = es_individual$att.egt,
    se = es_individual$se.egt
  ),
  data.frame(
    outcome = "Binding",
    time = es_binding$egt,
    att = es_binding$att.egt,
    se = es_binding$se.egt
  ),
  data.frame(
    outcome = "Log Univ/Comm",
    time = es_ratio$egt,
    att = es_ratio$att.egt,
    se = es_ratio$se.egt
  )
)

write_csv(es_data, "data/event_study_data.csv")

# Save R objects for later use
save(cs_individual, cs_binding, cs_ratio,
     es_individual, es_binding, es_ratio,
     att_individual, att_binding, att_ratio,
     foundation_results,
     file = "data/cs_results.RData")

cat("\n=== Main Analysis Complete ===\n")
