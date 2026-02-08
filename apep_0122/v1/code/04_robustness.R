# 04_robustness.R — Robustness checks and sensitivity analysis
# Paper 113: RPS and Electricity Sector Employment

source("00_packages.R")

panel <- readRDS("../data/panel.rds")
cs_result <- readRDS("../data/cs_result.rds")

cat("=== Robustness Checks ===\n\n")

# ==============================================================================
# 1. BACON DECOMPOSITION — Diagnose TWFE bias
# ==============================================================================

cat("--- Bacon Decomposition ---\n")

bacon_data <- panel %>%
  filter(!is.na(elec_emp_rate)) %>%
  mutate(
    treat_time = ifelse(treatment_year == 0, 10000, treatment_year)
  )

tryCatch({
  bacon_out <- bacon(
    elec_emp_rate ~ treated,
    data = bacon_data,
    id_var = "state_fips",
    time_var = "year"
  )
  saveRDS(bacon_out, "../data/bacon_decomp.rds")
  cat("Bacon decomposition:\n")
  print(summary(bacon_out))
}, error = function(e) {
  cat(sprintf("Bacon decomposition error: %s\n", e$message))
})

# ==============================================================================
# 2. REGION × YEAR FIXED EFFECTS
# ==============================================================================

cat("\n--- Region × Year Fixed Effects ---\n")

region_fe <- feols(
  elec_emp_rate ~ treated | state_fips + region^year,
  data = panel %>% filter(!is.na(elec_emp_rate)),
  cluster = ~state_fips
)

saveRDS(region_fe, "../data/region_fe_result.rds")
cat("Region × Year FE:\n")
print(summary(region_fe))

# ==============================================================================
# 3. PLACEBO OUTCOME — Manufacturing employment (should show null)
# ==============================================================================

cat("\n--- Placebo: Manufacturing Employment ---\n")

cs_data <- panel %>%
  filter(!is.na(mfg_emp_rate)) %>%
  mutate(id = as.numeric(factor(state_fips)), G = treatment_year)

cs_placebo_mfg <- att_gt(
  yname = "mfg_emp_rate",
  tname = "year",
  idname = "id",
  gname = "G",
  data = cs_data,
  control_group = "notyettreated",
  est_method = "dr",
  bstrap = TRUE,
  biters = 1000
)

cs_agg_mfg <- aggte(cs_placebo_mfg, type = "simple")
cat(sprintf("Placebo ATT (manufacturing): %.4f (SE: %.4f, p: %.4f)\n",
            cs_agg_mfg$overall.att, cs_agg_mfg$overall.se,
            2 * pnorm(-abs(cs_agg_mfg$overall.att / cs_agg_mfg$overall.se))))

cs_event_mfg <- aggte(cs_placebo_mfg, type = "dynamic", min_e = -8, max_e = 10)
saveRDS(cs_event_mfg, "../data/cs_event_placebo_mfg.rds")

# ==============================================================================
# 4. PLACEBO OUTCOME — Total employment rate (should show null)
# ==============================================================================

cat("\n--- Placebo: Total Employment Rate ---\n")

cs_data_total <- panel %>%
  filter(!is.na(total_emp_rate)) %>%
  mutate(id = as.numeric(factor(state_fips)), G = treatment_year)

cs_placebo_total <- att_gt(
  yname = "total_emp_rate",
  tname = "year",
  idname = "id",
  gname = "G",
  data = cs_data_total,
  control_group = "notyettreated",
  est_method = "dr",
  bstrap = TRUE,
  biters = 1000
)

cs_agg_total <- aggte(cs_placebo_total, type = "simple")
cat(sprintf("Placebo ATT (total emp): %.4f (SE: %.4f, p: %.4f)\n",
            cs_agg_total$overall.att, cs_agg_total$overall.se,
            2 * pnorm(-abs(cs_agg_total$overall.att / cs_agg_total$overall.se))))

saveRDS(cs_placebo_total, "../data/cs_result_placebo_total.rds")

# ==============================================================================
# 5. ALTERNATIVE TREATMENT: First year target > 5%
# ==============================================================================

cat("\n--- Alternative Treatment: RPS target > 5% ---\n")

# Restrict to states where target eventually exceeded 5%
rps_policy <- readRDS("../data/rps_policy.rds")
high_rps <- rps_policy %>%
  filter(!is.na(rps_target_2025) & rps_target_2025 > 5)

panel_alt <- panel %>%
  mutate(
    # Alternative treatment: only count states with meaningful targets
    alt_treated = state_fips %in% high_rps$state_fips & treated == 1,
    alt_treatment_year = ifelse(state_fips %in% high_rps$state_fips, treatment_year, 0)
  )

cs_data_alt <- panel_alt %>%
  filter(!is.na(elec_emp_rate)) %>%
  mutate(id = as.numeric(factor(state_fips)), G = alt_treatment_year)

cs_result_alt <- att_gt(
  yname = "elec_emp_rate",
  tname = "year",
  idname = "id",
  gname = "G",
  data = cs_data_alt,
  control_group = "notyettreated",
  est_method = "dr",
  bstrap = TRUE,
  biters = 1000
)

cs_agg_alt <- aggte(cs_result_alt, type = "simple")
cat(sprintf("ATT (target>5%%): %.4f (SE: %.4f, p: %.4f)\n",
            cs_agg_alt$overall.att, cs_agg_alt$overall.se,
            2 * pnorm(-abs(cs_agg_alt$overall.att / cs_agg_alt$overall.se))))

saveRDS(cs_result_alt, "../data/cs_result_alt_treatment.rds")

# ==============================================================================
# 6. LATE ADOPTERS ONLY (2008+, clean pre-trends)
# ==============================================================================

cat("\n--- Late Adopters Only (2008+) ---\n")

panel_late <- panel %>%
  filter(treatment_year == 0 | treatment_year >= 2008)

cs_data_late <- panel_late %>%
  filter(!is.na(elec_emp_rate)) %>%
  mutate(id = as.numeric(factor(state_fips)), G = treatment_year)

cs_result_late <- att_gt(
  yname = "elec_emp_rate",
  tname = "year",
  idname = "id",
  gname = "G",
  data = cs_data_late,
  control_group = "notyettreated",
  est_method = "dr",
  bstrap = TRUE,
  biters = 1000
)

cs_agg_late <- aggte(cs_result_late, type = "simple")
cat(sprintf("ATT (late adopters): %.4f (SE: %.4f, p: %.4f)\n",
            cs_agg_late$overall.att, cs_agg_late$overall.se,
            2 * pnorm(-abs(cs_agg_late$overall.att / cs_agg_late$overall.se))))

cs_event_late <- aggte(cs_result_late, type = "dynamic", min_e = -5, max_e = 10)
saveRDS(cs_event_late, "../data/cs_event_late.rds")

# ==============================================================================
# 7. HONESTDID SENSITIVITY ANALYSIS
# ==============================================================================

cat("\n--- HonestDiD Sensitivity Analysis ---\n")

tryCatch({
  cs_event_for_honest <- aggte(cs_result, type = "dynamic")

  # Create original event study for HonestDiD
  honest_es <- honest_did(
    cs_event_for_honest,
    type = "smoothness",
    Mvec = seq(0, 0.05, by = 0.01)
  )

  saveRDS(honest_es, "../data/honest_did_result.rds")
  cat("HonestDiD bounds computed successfully.\n")
  cat("Breakdown value (M* where CI includes 0):\n")

  # Find breakdown value
  for (i in seq_along(honest_es$Mvec)) {
    ci <- honest_es$robust_ci[i, ]
    cat(sprintf("  M = %.3f: [%.4f, %.4f] %s\n",
                honest_es$Mvec[i], ci[1], ci[2],
                ifelse(ci[1] <= 0 & ci[2] >= 0, "<-- includes 0", "")))
  }
}, error = function(e) {
  cat(sprintf("HonestDiD error: %s\n", e$message))
  cat("Proceeding without HonestDiD sensitivity analysis.\n")
})

# ==============================================================================
# 8. WILD CLUSTER BOOTSTRAP
# ==============================================================================

cat("\n--- Wild Cluster Bootstrap ---\n")

tryCatch({
  twfe_result <- readRDS("../data/twfe_result.rds")
  boot_result <- boottest(
    twfe_result,
    param = "treated",
    B = 9999,
    clustid = "state_fips",
    type = "webb"
  )
  saveRDS(boot_result, "../data/wild_bootstrap.rds")
  cat(sprintf("Wild bootstrap p-value: %.4f\n", boot_result$p_val))
  cat(sprintf("Wild bootstrap CI: [%.4f, %.4f]\n",
              boot_result$conf_int[1], boot_result$conf_int[2]))
}, error = function(e) {
  cat(sprintf("Wild bootstrap error: %s\n", e$message))
})

# ==============================================================================
# 9. LEAVE-ONE-OUT ANALYSIS
# ==============================================================================

cat("\n--- Leave-One-Out Analysis ---\n")

treated_states <- unique(panel$state_fips[panel$ever_treated])
loo_results <- data.frame()

for (st in treated_states) {
  panel_loo <- panel %>% filter(state_fips != st)
  cs_loo <- panel_loo %>%
    filter(!is.na(elec_emp_rate)) %>%
    mutate(id = as.numeric(factor(state_fips)), G = treatment_year)

  tryCatch({
    res <- att_gt(
      yname = "elec_emp_rate", tname = "year", idname = "id", gname = "G",
      data = cs_loo, control_group = "notyettreated", est_method = "dr",
      bstrap = FALSE
    )
    agg <- aggte(res, type = "simple")
    loo_results <- rbind(loo_results, data.frame(
      excluded_state = st,
      state_name = panel$state_name[panel$state_fips == st][1],
      att = agg$overall.att,
      se = agg$overall.se,
      stringsAsFactors = FALSE
    ))
  }, error = function(e) {
    cat(sprintf("  LOO error for %s: %s\n", st, e$message))
  })
}

saveRDS(loo_results, "../data/loo_results.rds")
cat(sprintf("Leave-one-out: ATT range [%.4f, %.4f]\n",
            min(loo_results$att), max(loo_results$att)))

# ==============================================================================
# 10. EXCLUDE BORDERLINE STATES (voluntary/non-binding targets)
# ==============================================================================

cat("\n--- Exclude Borderline States (Voluntary/Non-Binding Targets) ---\n")

# States with potentially voluntary or non-binding standards:
# North Dakota (FIPS 38): Voluntary objective (10% by 2015)
# Utah (FIPS 49): Voluntary goal (20% by 2025)
# South Carolina (FIPS 45): No binding RPS mandate
# Louisiana (FIPS 22): Renewable pilot program, not binding RPS
borderline_fips <- c("38", "49", "45", "22")

panel_strict <- panel %>%
  mutate(
    # Reclassify borderline states as untreated
    strict_treated = ifelse(state_fips %in% borderline_fips, 0L, treated),
    strict_treatment_year = ifelse(state_fips %in% borderline_fips, 0L, treatment_year),
    strict_ever_treated = ifelse(state_fips %in% borderline_fips, FALSE, ever_treated)
  )

cs_data_strict <- panel_strict %>%
  filter(!is.na(elec_emp_rate)) %>%
  mutate(id = as.numeric(factor(state_fips)), G = strict_treatment_year)

cs_result_strict <- att_gt(
  yname = "elec_emp_rate",
  tname = "year",
  idname = "id",
  gname = "G",
  data = cs_data_strict,
  control_group = "notyettreated",
  est_method = "dr",
  bstrap = TRUE,
  biters = 1000
)

cs_agg_strict <- aggte(cs_result_strict, type = "simple")
cat(sprintf("ATT (excl. borderline): %.4f (SE: %.4f, p: %.4f)\n",
            cs_agg_strict$overall.att, cs_agg_strict$overall.se,
            2 * pnorm(-abs(cs_agg_strict$overall.att / cs_agg_strict$overall.se))))

saveRDS(cs_result_strict, "../data/cs_result_strict.rds")
saveRDS(cs_agg_strict, "../data/cs_agg_strict.rds")

cat(sprintf("  Treated states (strict): %d\n",
            length(unique(panel_strict$state_fips[panel_strict$strict_ever_treated]))))

# ==============================================================================
# 11. EXCLUDE VIRGINIA AND WEST VIRGINIA (contaminated controls)
# ==============================================================================

cat("\n--- Exclude Virginia & West Virginia from Control Group ---\n")

# Virginia (FIPS 51): VCEA enacted 2020, sample includes 2021-2023
# West Virginia (FIPS 54): AREPS 2009-2015, repealed but potentially contaminating
contam_fips <- c("51", "54")

panel_no_contam <- panel %>% filter(!(state_fips %in% contam_fips))

cs_data_no_contam <- panel_no_contam %>%
  filter(!is.na(elec_emp_rate)) %>%
  mutate(id = as.numeric(factor(state_fips)), G = treatment_year)

cs_result_no_contam <- att_gt(
  yname = "elec_emp_rate",
  tname = "year",
  idname = "id",
  gname = "G",
  data = cs_data_no_contam,
  control_group = "notyettreated",
  est_method = "dr",
  bstrap = TRUE,
  biters = 1000
)

cs_agg_no_contam <- aggte(cs_result_no_contam, type = "simple")
cat(sprintf("ATT (excl. VA & WV): %.4f (SE: %.4f, p: %.4f)\n",
            cs_agg_no_contam$overall.att, cs_agg_no_contam$overall.se,
            2 * pnorm(-abs(cs_agg_no_contam$overall.att / cs_agg_no_contam$overall.se))))

saveRDS(cs_agg_no_contam, "../data/cs_agg_no_contam.rds")

# ==============================================================================
# Save all robustness results summary
# ==============================================================================

robustness_summary <- tibble(
  check = c("Region × Year FE",
            "Placebo: Manufacturing",
            "Placebo: Total Employment",
            "Alt Treatment (target > 5%)",
            "Late Adopters Only (2008+)",
            "Excl. Borderline States",
            "Excl. VA & WV"),
  att = c(coef(region_fe),
          cs_agg_mfg$overall.att,
          cs_agg_total$overall.att,
          cs_agg_alt$overall.att,
          cs_agg_late$overall.att,
          cs_agg_strict$overall.att,
          cs_agg_no_contam$overall.att),
  se = c(summary(region_fe)$coeftable[1, 2],
         cs_agg_mfg$overall.se,
         cs_agg_total$overall.se,
         cs_agg_alt$overall.se,
         cs_agg_late$overall.se,
         cs_agg_strict$overall.se,
         cs_agg_no_contam$overall.se)
) %>%
  mutate(
    pvalue = 2 * pnorm(-abs(att / se)),
    sig = case_when(pvalue < 0.01 ~ "***", pvalue < 0.05 ~ "**",
                    pvalue < 0.10 ~ "*", TRUE ~ "")
  )

saveRDS(robustness_summary, "../data/robustness_summary.rds")
cat("\n=== Robustness Summary ===\n")
print(robustness_summary, width = 100)

cat("\n=== Robustness checks complete ===\n")
