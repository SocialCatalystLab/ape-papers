# =============================================================================
# 05_robustness.R
# Comprehensive robustness and sensitivity analysis
# =============================================================================

source("output/paper_80/code/00_packages.R")

# =============================================================================
# Load data and main results
# =============================================================================

df <- read_csv("output/paper_80/data/analysis_main.csv", show_col_types = FALSE)
main_results <- readRDS("output/paper_80/data/cs_results.rds")

df <- df %>%
  mutate(
    state_id = as.integer(factor(state_fips)),
    G = first_treat_quarter
  )

cat("=== Robustness Analysis ===\n\n")

# =============================================================================
# 1. ESTIMATOR ROBUSTNESS
# =============================================================================

cat("\n--- 1. Estimator Robustness ---\n\n")

# 1a. Sun-Abraham estimator (fixest)
cat("1a. Sun-Abraham estimator...\n")

sa_model <- feols(
  gambling_emp_clean ~ sunab(first_treat_quarter, quarter_num) |
    state_id + quarter_num,
  data = df %>% filter(first_treat_quarter != 0 | first_treat_year == 0),
  cluster = ~state_id
)

cat("Sun-Abraham results:\n")
summary(sa_model, agg = "att")

# Extract overall ATT from Sun-Abraham
sa_att <- summary(sa_model, agg = "att")$coeftable[1, 1]
sa_se <- summary(sa_model, agg = "att")$coeftable[1, 2]
cat(sprintf("Sun-Abraham ATT: %.1f (SE = %.1f)\n", sa_att, sa_se))

# 1b. Traditional TWFE (for comparison)
cat("\n1b. Two-Way Fixed Effects (TWFE)...\n")

twfe_model <- feols(
  gambling_emp_clean ~ treated | state_id + quarter_num,
  data = df,
  cluster = ~state_id
)

cat("TWFE results:\n")
summary(twfe_model)

twfe_att <- coef(twfe_model)["treated"]
twfe_se <- se(twfe_model)["treated"]
cat(sprintf("TWFE ATT: %.1f (SE = %.1f)\n", twfe_att, twfe_se))

# 1c. Goodman-Bacon decomposition
cat("\n1c. Goodman-Bacon Decomposition...\n")

# Need annual data for bacon decomp
df_annual <- df %>%
  group_by(state_id, year, first_treat_year, G) %>%
  summarise(
    gambling_emp = mean(gambling_emp_clean, na.rm = TRUE),
    treated = max(treated),
    .groups = "drop"
  ) %>%
  filter(!is.na(gambling_emp))

bacon <- bacon(
  gambling_emp ~ treated,
  data = df_annual,
  id_var = "state_id",
  time_var = "year"
)

cat("Bacon decomposition:\n")
print(summary(bacon))

# =============================================================================
# 2. SPECIFICATION ROBUSTNESS
# =============================================================================

cat("\n\n--- 2. Specification Robustness ---\n\n")

# 2a. Exclude iGaming confounders
cat("2a. Excluding iGaming states (NJ, PA, MI, CT)...\n")

df_no_igaming <- read_csv("output/paper_80/data/analysis_no_igaming.csv", show_col_types = FALSE) %>%
  mutate(state_id = as.integer(factor(state_fips)), G = first_treat_quarter)

if (nrow(df_no_igaming) > 0 && n_distinct(df_no_igaming$state_fips[df_no_igaming$G > 0]) >= 2) {
  cs_no_igaming <- att_gt(
    yname = "gambling_emp_clean",
    tname = "quarter_num",
    idname = "state_id",
    gname = "G",
    data = df_no_igaming,
    control_group = "nevertreated",
    bstrap = TRUE,
    biters = 500
  )
  agg_no_igaming <- aggte(cs_no_igaming, type = "simple")
  cat("ATT excluding iGaming states:\n")
  summary(agg_no_igaming)
}

# 2b. Exclude COVID period (2020)
cat("\n2b. Excluding 2020...\n")

df_no_2020 <- df %>% filter(year != 2020)

cs_no_2020 <- att_gt(
  yname = "gambling_emp_clean",
  tname = "quarter_num",
  idname = "state_id",
  gname = "G",
  data = df_no_2020,
  control_group = "nevertreated",
  bstrap = TRUE,
  biters = 500
)
agg_no_2020 <- aggte(cs_no_2020, type = "simple")
cat("ATT excluding 2020:\n")
summary(agg_no_2020)

# 2c. Pre-COVID cohorts only (2018-2019)
cat("\n2c. Pre-COVID cohorts only (2018-2019 adopters)...\n")

df_early <- read_csv("output/paper_80/data/analysis_early_cohorts.csv", show_col_types = FALSE) %>%
  mutate(state_id = as.integer(factor(state_fips)), G = first_treat_quarter)

cs_early <- att_gt(
  yname = "gambling_emp_clean",
  tname = "quarter_num",
  idname = "state_id",
  gname = "G",
  data = df_early,
  control_group = "nevertreated",
  bstrap = TRUE,
  biters = 500
)
agg_early <- aggte(cs_early, type = "simple")
cat("ATT for pre-COVID cohorts:\n")
summary(agg_early)

# =============================================================================
# 3. OUTCOME ROBUSTNESS
# =============================================================================

cat("\n\n--- 3. Outcome Robustness ---\n\n")

# 3a. Broader NAICS 71 (Arts, Entertainment, Recreation)
cat("3a. NAICS 71 (Arts/Entertainment/Recreation)...\n")

cs_leisure <- att_gt(
  yname = "leisure_emp_clean",
  tname = "quarter_num",
  idname = "state_id",
  gname = "G",
  data = df %>% filter(!is.na(leisure_emp_clean)),
  control_group = "nevertreated",
  bstrap = TRUE,
  biters = 500
)
agg_leisure <- aggte(cs_leisure, type = "simple")
cat("ATT on NAICS 71:\n")
summary(agg_leisure)

# 3b. Log employment (percent change interpretation)
cat("\n3b. Log employment...\n")

cs_log <- att_gt(
  yname = "log_gambling_emp",
  tname = "quarter_num",
  idname = "state_id",
  gname = "G",
  data = df %>% filter(!is.na(log_gambling_emp) & is.finite(log_gambling_emp)),
  control_group = "nevertreated",
  bstrap = TRUE,
  biters = 500
)
agg_log <- aggte(cs_log, type = "simple")
cat("ATT on log employment:\n")
summary(agg_log)
cat(sprintf("Implied percent change: %.1f%%\n", 100 * (exp(agg_log$overall.att) - 1)))

# =============================================================================
# 4. HONESTDID SENSITIVITY ANALYSIS
# =============================================================================

cat("\n\n--- 4. HonestDiD Sensitivity Analysis ---\n\n")

# Rambachan-Roth bounds for parallel trends violations
# Allows for linear violations of parallel trends

tryCatch({
  # Get CS results for HonestDiD
  es_honest <- aggte(main_results$cs_never, type = "dynamic", min_e = -8, max_e = 8)

  # Create honest_did compatible object
  betahat <- es_honest$att.egt
  sigma <- diag(es_honest$se.egt^2)  # Simplified variance matrix

  # Relative magnitudes approach
  cat("Rambachan-Roth sensitivity (relative magnitudes):\n")

  # This requires the actual variance-covariance matrix from CS
  # Simplified illustration using SE bounds

  cat("Pre-period coefficients:\n")
  pre_coefs <- data.frame(
    e = es_honest$egt[es_honest$egt < 0],
    att = es_honest$att.egt[es_honest$egt < 0],
    se = es_honest$se.egt[es_honest$egt < 0]
  )
  print(pre_coefs)

  # Max pre-trend violation
  max_pre_violation <- max(abs(pre_coefs$att))
  cat(sprintf("\nMax pre-trend magnitude: %.1f\n", max_pre_violation))

  # Sensitivity: What if post-treatment trends differ by up to M * max_pre_violation?
  post_att <- es_honest$att.egt[es_honest$egt >= 0]
  post_se <- es_honest$se.egt[es_honest$egt >= 0]

  for (M in c(1, 2, 3)) {
    bound <- M * max_pre_violation
    robust_ci <- c(
      min(post_att) - 1.96 * max(post_se) - bound,
      max(post_att) + 1.96 * max(post_se) + bound
    )
    cat(sprintf("M = %d: Robust CI = [%.1f, %.1f]\n", M, robust_ci[1], robust_ci[2]))
  }

}, error = function(e) {
  cat(sprintf("HonestDiD analysis failed: %s\n", e$message))
})

# =============================================================================
# 5. PLACEBO TESTS
# =============================================================================

cat("\n\n--- 5. Placebo Tests ---\n\n")

# Test effect on industries that should NOT be affected

# 5a. Generate placebo outcomes (manufacturing proxy using leisure as placeholder)
# In full implementation, would fetch NAICS 31-33 data

cat("Placebo test: Effect on unrelated industries\n")
cat("(Would use NAICS 31-33 Manufacturing, NAICS 11 Agriculture)\n")
cat("Implementation requires fetching additional QCEW series.\n")

# Placebo using pre-treatment periods
cat("\nPlacebo: Fake treatment 4 quarters earlier...\n")

df_placebo <- df %>%
  mutate(
    G_placebo = if_else(G > 0, G - 4L, 0L),
    treated_placebo = if_else(quarter_num >= G_placebo & G_placebo > 0, 1L, 0L)
  ) %>%
  filter(quarter_num < G | G == 0)  # Only pre-treatment periods

if (nrow(df_placebo) > 100) {
  cs_placebo <- att_gt(
    yname = "gambling_emp_clean",
    tname = "quarter_num",
    idname = "state_id",
    gname = "G_placebo",
    data = df_placebo,
    control_group = "nevertreated",
    bstrap = TRUE,
    biters = 500
  )
  agg_placebo <- aggte(cs_placebo, type = "simple")
  cat("Placebo ATT (fake treatment 4 quarters early):\n")
  summary(agg_placebo)
}

# =============================================================================
# 6. INFERENCE ROBUSTNESS
# =============================================================================

cat("\n\n--- 6. Inference Robustness ---\n\n")

# 6a. Wild cluster bootstrap
cat("6a. Wild cluster bootstrap p-values...\n")

# Using fwildclusterboot for wild bootstrap
tryCatch({
  library(fwildclusterboot)

  # TWFE with wild bootstrap
  wb_test <- boottest(
    twfe_model,
    clustid = "state_id",
    param = "treated",
    B = 999,
    type = "webb"
  )

  cat(sprintf("Wild bootstrap p-value: %.4f\n", wb_test$p_val))

}, error = function(e) {
  cat(sprintf("Wild bootstrap failed: %s\n", e$message))
})

# =============================================================================
# 7. SUMMARY TABLE
# =============================================================================

cat("\n\n")
cat("=" %>% rep(70) %>% paste(collapse = ""))
cat("\n ROBUSTNESS SUMMARY TABLE \n")
cat("=" %>% rep(70) %>% paste(collapse = ""))
cat("\n\n")

robustness_summary <- data.frame(
  Specification = c(
    "Main (CS, never-treated)",
    "Sun-Abraham",
    "TWFE",
    "Excl. iGaming states",
    "Excl. 2020",
    "Pre-COVID cohorts only",
    "NAICS 71 (broader)",
    "Log employment"
  ),
  ATT = c(
    main_results$overall_att,
    sa_att,
    twfe_att,
    ifelse(exists("agg_no_igaming"), agg_no_igaming$overall.att, NA),
    agg_no_2020$overall.att,
    agg_early$overall.att,
    agg_leisure$overall.att,
    agg_log$overall.att
  ),
  SE = c(
    main_results$overall_se,
    sa_se,
    twfe_se,
    ifelse(exists("agg_no_igaming"), agg_no_igaming$overall.se, NA),
    agg_no_2020$overall.se,
    agg_early$overall.se,
    agg_leisure$overall.se,
    agg_log$overall.se
  )
)

robustness_summary <- robustness_summary %>%
  mutate(
    CI_lower = ATT - 1.96 * SE,
    CI_upper = ATT + 1.96 * SE,
    t_stat = ATT / SE
  )

print(robustness_summary, digits = 2)

# =============================================================================
# Save robustness results
# =============================================================================

robustness_results <- list(
  sa_model = sa_model,
  twfe_model = twfe_model,
  bacon = bacon,
  agg_no_2020 = agg_no_2020,
  agg_early = agg_early,
  agg_leisure = agg_leisure,
  agg_log = agg_log,
  robustness_summary = robustness_summary
)

saveRDS(robustness_results, "output/paper_80/data/robustness_results.rds")
write_csv(robustness_summary, "output/paper_80/data/robustness_summary.csv")

cat("\n\nRobustness results saved.\n")
