## =============================================================================
## 04_robustness.R — Robustness Checks
## APEP-0369: Click to Prescribe
## =============================================================================

source("00_packages.R")

cat("=== Running robustness checks ===\n")

set.seed(2024)  # Reproducible bootstrap inference

panel <- readRDS("../data/analysis_panel.rds")
cs_rx <- readRDS("../data/cs_rx_results.rds")

cs_data <- panel %>%
  filter(!is.na(rx_opioid_death_rate), !is.na(population)) %>%
  mutate(gname = epcs_mandate_year)

## ---------------------------------------------------------------------------
## 1. HonestDiD sensitivity analysis
## ---------------------------------------------------------------------------

cat("Running HonestDiD sensitivity analysis...\n")

es_rx <- aggte(cs_rx, type = "dynamic", min_e = -5, max_e = 3)

tryCatch({
  # Extract event-study coefficients for HonestDiD
  honest_es <- data.frame(
    e = es_rx$egt,
    att = es_rx$att.egt,
    se = es_rx$se.egt
  )

  # Separate pre and post periods
  pre <- honest_es %>% filter(e < 0)
  post <- honest_es %>% filter(e >= 0)

  if (nrow(pre) >= 2 && nrow(post) >= 1) {
    # Construct the beta and sigma objects HonestDiD needs
    betahat <- honest_es$att
    sigma <- diag(honest_es$se^2)

    # Number of pre-treatment periods
    numPrePeriods <- nrow(pre)
    numPostPeriods <- nrow(post)

    # Run HonestDiD with relative magnitudes approach
    honest_result <- HonestDiD::createSensitivityResults_relativeMagnitudes(
      betahat = betahat,
      sigma = sigma,
      numPrePeriods = numPrePeriods,
      numPostPeriods = numPostPeriods,
      Mbarvec = seq(0, 2, by = 0.5)
    )

    saveRDS(honest_result, "../data/honestdid_results.rds")
    cat("  HonestDiD sensitivity analysis complete.\n")
  } else {
    cat("  Insufficient pre/post periods for HonestDiD.\n")
  }
}, error = function(e) {
  cat(sprintf("  HonestDiD failed: %s\n", e$message))
  cat("  Continuing with other robustness checks.\n")
})

## ---------------------------------------------------------------------------
## 2. Not-yet-treated as control group
## ---------------------------------------------------------------------------

cat("\nRunning CS-DiD with not-yet-treated controls...\n")

cs_nyt <- att_gt(
  yname = "rx_opioid_death_rate",
  tname = "year",
  idname = "state_id",
  gname = "gname",
  data = cs_data,
  control_group = "notyettreated",
  anticipation = 1,
  base_period = "universal",
  est_method = "dr",
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000
)

agg_nyt <- aggte(cs_nyt, type = "simple")
es_nyt <- aggte(cs_nyt, type = "dynamic", min_e = -5, max_e = 3)

cat(sprintf("  ATT (not-yet-treated): %.3f (SE: %.3f)\n",
            agg_nyt$overall.att, agg_nyt$overall.se))

saveRDS(list(cs = cs_nyt, agg = agg_nyt, es = es_nyt),
        "../data/robustness_nyt.rds")

## ---------------------------------------------------------------------------
## 3. Anticipation sensitivity (0 and 2 years)
## ---------------------------------------------------------------------------

cat("\nRunning anticipation sensitivity...\n")

for (ant in c(0, 2)) {
  cs_ant <- att_gt(
    yname = "rx_opioid_death_rate",
    tname = "year",
    idname = "state_id",
    gname = "gname",
    data = cs_data,
    control_group = "nevertreated",
    anticipation = ant,
    base_period = "universal",
    est_method = "dr",
    bstrap = TRUE,
    biters = 1000
  )

  agg_ant <- aggte(cs_ant, type = "simple")
  cat(sprintf("  Anticipation = %d: ATT = %.3f (SE: %.3f)\n",
              ant, agg_ant$overall.att, agg_ant$overall.se))

  saveRDS(list(cs = cs_ant, agg = agg_ant),
          sprintf("../data/robustness_ant%d.rds", ant))
}

## ---------------------------------------------------------------------------
## 4. Bacon decomposition (TWFE diagnostics)
## ---------------------------------------------------------------------------

cat("\nRunning Bacon decomposition...\n")

# Need binary treatment for bacon
bacon_data <- cs_data %>%
  filter(gname > 0 | gname == 0) %>%
  mutate(treat_post = as.integer(epcs_treated))

tryCatch({
  bacon_out <- bacon(
    rx_opioid_death_rate ~ treat_post,
    data = bacon_data,
    id_var = "state_id",
    time_var = "year"
  )

  saveRDS(bacon_out, "../data/bacon_decomposition.rds")

  cat("\n  Bacon decomposition weights:\n")
  bacon_summary <- bacon_out %>%
    group_by(type) %>%
    summarise(
      weight = sum(weight),
      avg_estimate = weighted.mean(estimate, weight),
      .groups = "drop"
    )
  print(bacon_summary)
}, error = function(e) {
  cat(sprintf("  Bacon decomposition failed: %s\n", e$message))
})

## ---------------------------------------------------------------------------
## 5. Controlling for concurrent PDMP mandates
## ---------------------------------------------------------------------------

cat("\nRunning specification with PDMP controls...\n")

twfe_controlled <- feols(
  rx_opioid_death_rate ~ epcs_treated + pdmp_treated | state_id + year,
  data = cs_data,
  cluster = ~state_id
)

cat("\n  TWFE with PDMP control:\n")
print(summary(twfe_controlled))

saveRDS(twfe_controlled, "../data/robustness_pdmp_control.rds")

## ---------------------------------------------------------------------------
## 6. Heterogeneity by pre-treatment prescribing level
## ---------------------------------------------------------------------------

cat("\nAnalyzing heterogeneity by pre-treatment overdose level...\n")

# Classify states by pre-treatment rx opioid death rate
pre_rates <- cs_data %>%
  filter(year <= 2018) %>%
  group_by(state_abbr) %>%
  summarise(pre_rate = mean(rx_opioid_death_rate, na.rm = TRUE), .groups = "drop")

median_rate <- median(pre_rates$pre_rate, na.rm = TRUE)

cs_data <- cs_data %>%
  left_join(pre_rates, by = "state_abbr") %>%
  mutate(high_prescribing = as.integer(pre_rate >= median_rate))

# Run CS-DiD separately for high and low prescribing states
for (group in c(0, 1)) {
  group_label <- ifelse(group == 1, "High", "Low")
  cat(sprintf("\n  %s pre-treatment prescribing states:\n", group_label))

  sub_data <- cs_data %>% filter(high_prescribing == group)

  tryCatch({
    cs_sub <- att_gt(
      yname = "rx_opioid_death_rate",
      tname = "year",
      idname = "state_id",
      gname = "gname",
      data = sub_data,
      control_group = "nevertreated",
      anticipation = 1,
      base_period = "universal",
      est_method = "dr",
      bstrap = TRUE,
      biters = 1000
    )

    agg_sub <- aggte(cs_sub, type = "simple")
    cat(sprintf("    ATT: %.3f (SE: %.3f)\n", agg_sub$overall.att, agg_sub$overall.se))

    saveRDS(list(cs = cs_sub, agg = agg_sub),
            sprintf("../data/robustness_hetero_%s.rds", tolower(group_label)))
  }, error = function(e) {
    cat(sprintf("    Failed: %s\n", e$message))
  })
}

## ---------------------------------------------------------------------------
## 7. Log specification (semi-elasticity)
## ---------------------------------------------------------------------------

cat("\nRunning log specification...\n")

cs_log <- att_gt(
  yname = "log_rx_opioid_deaths",
  tname = "year",
  idname = "state_id",
  gname = "gname",
  data = cs_data,
  control_group = "nevertreated",
  anticipation = 1,
  base_period = "universal",
  est_method = "dr",
  bstrap = TRUE,
  biters = 1000
)

agg_log <- aggte(cs_log, type = "simple")
cat(sprintf("  ATT (log): %.3f (SE: %.3f) → ~%.1f%% change\n",
            agg_log$overall.att, agg_log$overall.se,
            (exp(agg_log$overall.att) - 1) * 100))

saveRDS(list(cs = cs_log, agg = agg_log), "../data/robustness_log.rds")

## ---------------------------------------------------------------------------
## 8. Wild cluster bootstrap inference
## ---------------------------------------------------------------------------

cat("\nRunning wild cluster bootstrap...\n")

if (requireNamespace("fwildclusterboot", quietly = TRUE)) {
  library(fwildclusterboot)
  tryCatch({
    twfe_data <- cs_data %>%
      filter(!is.na(rx_opioid_death_rate))

    twfe_model <- feols(
      rx_opioid_death_rate ~ epcs_treated | state_id + year,
      data = twfe_data,
      cluster = ~state_id
    )

    set.seed(2024)
    boot_result <- boottest(
      twfe_model,
      param = "epcs_treated",
      B = 9999,
      clustid = "state_id",
      type = "webb"
    )

    cat(sprintf("  Wild bootstrap p-value: %.4f\n", boot_result$p_val))
    cat(sprintf("  Bootstrap 95%% CI: [%.3f, %.3f]\n",
                boot_result$conf_int[1], boot_result$conf_int[2]))

    saveRDS(boot_result, "../data/robustness_bootstrap.rds")
  }, error = function(e) {
    cat(sprintf("  Wild bootstrap failed: %s\n", e$message))
  })
} else {
  cat("  Skipping: fwildclusterboot package not available for this R version.\n")
  cat("  Standard cluster-robust SEs and multiplier bootstrap from did package are reported instead.\n")
}

## ---------------------------------------------------------------------------
## 9. Compile robustness summary
## ---------------------------------------------------------------------------

cat("\n\n========================================\n")
cat("ROBUSTNESS SUMMARY\n")
cat("========================================\n")

robustness <- data.frame(
  specification = c(
    "Primary (never-treated)",
    "Not-yet-treated controls",
    "Anticipation = 0",
    "Anticipation = 2",
    "Log outcome",
    "TWFE + PDMP control"
  ),
  att = c(
    aggte(cs_rx, type = "simple")$overall.att,
    agg_nyt$overall.att,
    aggte(readRDS("../data/robustness_ant0.rds")$cs, type = "simple")$overall.att,
    aggte(readRDS("../data/robustness_ant2.rds")$cs, type = "simple")$overall.att,
    agg_log$overall.att,
    coef(twfe_controlled)["epcs_treated"]
  ),
  stringsAsFactors = FALSE
)

print(robustness, digits = 3)

saveRDS(robustness, "../data/robustness_summary.rds")

cat("\n=== Robustness checks complete ===\n")
