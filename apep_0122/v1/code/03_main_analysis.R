# 03_main_analysis.R — Primary DiD analysis
# Paper 113: RPS and Electricity Sector Employment

source("00_packages.R")

panel <- readRDS("../data/panel.rds")

cat("=== Main Analysis: RPS and Electricity Sector Employment ===\n\n")

# ==============================================================================
# 1. CALLAWAY-SANT'ANNA (Primary Specification)
# ==============================================================================

cat("--- Callaway-Sant'Anna Estimation ---\n")

# Prepare data for CS-DiD
cs_data <- panel %>%
  filter(!is.na(elec_emp_rate)) %>%
  mutate(
    id = as.numeric(factor(state_fips)),
    G = treatment_year  # 0 = never treated
  )

# Main CS-DiD: ATT(g,t) with not-yet-treated comparison
cs_result <- att_gt(
  yname = "elec_emp_rate",
  tname = "year",
  idname = "id",
  gname = "G",
  data = cs_data,
  control_group = "notyettreated",
  est_method = "dr",  # Doubly robust
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000
)

# Save raw CS result
saveRDS(cs_result, "../data/cs_result.rds")

# Aggregate to overall ATT
cs_agg <- aggte(cs_result, type = "simple")
cat(sprintf("\nOverall ATT: %.4f (SE: %.4f, p: %.4f)\n",
            cs_agg$overall.att, cs_agg$overall.se,
            2 * pnorm(-abs(cs_agg$overall.att / cs_agg$overall.se))))

# Aggregate to event study
cs_event <- aggte(cs_result, type = "dynamic", min_e = -8, max_e = 10)
saveRDS(cs_event, "../data/cs_event.rds")

# Extract event study data
es_df <- data.frame(
  event_time = cs_event$egt,
  estimate = cs_event$att.egt,
  se = cs_event$se.egt,
  ci_lower = cs_event$att.egt - 1.96 * cs_event$se.egt,
  ci_upper = cs_event$att.egt + 1.96 * cs_event$se.egt
)
saveRDS(es_df, "../data/event_study_cs.rds")

cat("\nEvent Study (CS-DiD):\n")
print(es_df, digits = 4)

# Pre-trend test: joint significance of pre-treatment coefficients
pre_coefs <- es_df %>% filter(event_time < 0)
if (nrow(pre_coefs) > 0) {
  # Wald-type test
  pre_stat <- sum((pre_coefs$estimate / pre_coefs$se)^2)
  pre_pval <- 1 - pchisq(pre_stat, df = nrow(pre_coefs))
  cat(sprintf("\nPre-trend joint test: chi2(%d) = %.2f, p = %.4f\n",
              nrow(pre_coefs), pre_stat, pre_pval))
}

# ==============================================================================
# 2. CALLAWAY-SANT'ANNA with never-treated controls only
# ==============================================================================

cat("\n--- CS-DiD: Never-treated controls only ---\n")

cs_result_nt <- att_gt(
  yname = "elec_emp_rate",
  tname = "year",
  idname = "id",
  gname = "G",
  data = cs_data,
  control_group = "nevertreated",
  est_method = "dr",
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000
)

cs_agg_nt <- aggte(cs_result_nt, type = "simple")
cat(sprintf("Overall ATT (never-treated): %.4f (SE: %.4f, p: %.4f)\n",
            cs_agg_nt$overall.att, cs_agg_nt$overall.se,
            2 * pnorm(-abs(cs_agg_nt$overall.att / cs_agg_nt$overall.se))))

cs_event_nt <- aggte(cs_result_nt, type = "dynamic", min_e = -8, max_e = 10)
saveRDS(cs_event_nt, "../data/cs_event_nevertreated.rds")

# ==============================================================================
# 3. SUN-ABRAHAM (fixest) — Alternative heterogeneity-robust estimator
# ==============================================================================

cat("\n--- Sun-Abraham Estimation ---\n")

# Sun-Abraham via fixest
sa_result <- feols(
  elec_emp_rate ~ sunab(treatment_year, year) | state_fips + year,
  data = panel %>% filter(!is.na(elec_emp_rate)),
  cluster = ~state_fips
)

saveRDS(sa_result, "../data/sa_result.rds")

cat("Sun-Abraham aggregate ATT:\n")
summary(sa_result, agg = "att")

# ==============================================================================
# 4. STANDARD TWFE (for comparison — expected to be biased)
# ==============================================================================

cat("\n--- Standard TWFE (for comparison) ---\n")

twfe_result <- feols(
  elec_emp_rate ~ treated | state_fips + year,
  data = panel,
  cluster = ~state_fips
)

saveRDS(twfe_result, "../data/twfe_result.rds")
cat("TWFE ATT:\n")
print(summary(twfe_result))

# ==============================================================================
# 5. LOG EMPLOYMENT SPECIFICATION
# ==============================================================================

cat("\n--- Log Employment Specification ---\n")

cs_data_log <- cs_data %>%
  filter(!is.na(log_elec_emp), is.finite(log_elec_emp))

cs_result_log <- att_gt(
  yname = "log_elec_emp",
  tname = "year",
  idname = "id",
  gname = "G",
  data = cs_data_log,
  control_group = "notyettreated",
  est_method = "dr",
  bstrap = TRUE,
  biters = 1000
)

cs_agg_log <- aggte(cs_result_log, type = "simple")
cat(sprintf("Overall ATT (log emp): %.4f (SE: %.4f, p: %.4f)\n",
            cs_agg_log$overall.att, cs_agg_log$overall.se,
            2 * pnorm(-abs(cs_agg_log$overall.att / cs_agg_log$overall.se))))

saveRDS(cs_result_log, "../data/cs_result_log.rds")

# ==============================================================================
# 6. TOTAL UTILITY SECTOR (broader outcome)
# ==============================================================================

cat("\n--- Total Utility Sector ---\n")

cs_data_util <- cs_data %>%
  filter(!is.na(util_emp_rate))

cs_result_util <- att_gt(
  yname = "util_emp_rate",
  tname = "year",
  idname = "id",
  gname = "G",
  data = cs_data_util,
  control_group = "notyettreated",
  est_method = "dr",
  bstrap = TRUE,
  biters = 1000
)

cs_agg_util <- aggte(cs_result_util, type = "simple")
cat(sprintf("Overall ATT (utility sector): %.4f (SE: %.4f, p: %.4f)\n",
            cs_agg_util$overall.att, cs_agg_util$overall.se,
            2 * pnorm(-abs(cs_agg_util$overall.att / cs_agg_util$overall.se))))

saveRDS(cs_result_util, "../data/cs_result_util.rds")

# ==============================================================================
# Save summary of all main results
# ==============================================================================

main_results <- tibble(
  specification = c("CS-DiD (rate, not-yet-treated)",
                     "CS-DiD (rate, never-treated)",
                     "Sun-Abraham (rate)",
                     "TWFE (rate)",
                     "CS-DiD (log emp, not-yet-treated)",
                     "CS-DiD (utility rate, not-yet-treated)"),
  att = c(cs_agg$overall.att,
          cs_agg_nt$overall.att,
          coef(summary(sa_result, agg = "att"))[1],
          coef(twfe_result),
          cs_agg_log$overall.att,
          cs_agg_util$overall.att),
  se = c(cs_agg$overall.se,
         cs_agg_nt$overall.se,
         summary(sa_result, agg = "att")$coeftable[1, 2],
         summary(twfe_result)$coeftable[1, 2],
         cs_agg_log$overall.se,
         cs_agg_util$overall.se)
) %>%
  mutate(
    pvalue = 2 * pnorm(-abs(att / se)),
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se,
    sig = case_when(
      pvalue < 0.01 ~ "***",
      pvalue < 0.05 ~ "**",
      pvalue < 0.10 ~ "*",
      TRUE ~ ""
    )
  )

saveRDS(main_results, "../data/main_results.rds")
cat("\n=== Main Results Summary ===\n")
print(main_results, n = 10, width = 120)

cat("\n=== Main analysis complete ===\n")
