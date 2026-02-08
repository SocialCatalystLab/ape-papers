################################################################################
# 04b_qwi_analysis.R
# Salary Transparency Laws and Labor Market Dynamics
#
# QWI-based DiD analysis: earnings, gender gap, dynamism, industry heterogeneity
#
# --- Input/Output Provenance ---
# INPUTS:
#   data/qwi_agg.rds          <- 02b_clean_qwi.R (state x quarter aggregate)
#   data/qwi_gender_gap.rds   <- 02b_clean_qwi.R (gender gap panel)
#   data/qwi_panel.rds        <- 02b_clean_qwi.R (full panel)
# OUTPUTS:
#   data/qwi_results.rds      (all DiD results)
#   data/qwi_event_study.rds  (quarterly event study coefficients)
################################################################################

source("code/00_packages.R")

cat("=== QWI Analysis: Labor Market Dynamics Under Transparency ===\n\n")

# ============================================================================
# Load Data
# ============================================================================

qwi_agg <- readRDS("data/qwi_agg.rds")
qwi_gap <- readRDS("data/qwi_gender_gap.rds")
qwi_full <- readRDS("data/qwi_panel.rds")

cat("Aggregate panel:", nrow(qwi_agg), "rows\n")
cat("Gender gap panel:", nrow(qwi_gap), "rows\n")
cat("Full panel:", nrow(qwi_full), "rows\n\n")

# ============================================================================
# Block A: Aggregate Earnings DiD (triangulates CPS null result)
# ============================================================================

cat("--- Block A: Aggregate Earnings DiD ---\n")

# Callaway-Sant'Anna on state-quarter panel
cs_earns <- att_gt(
  yname = "log_earns",
  tname = "quarter_num",
  idname = "statefip",
  gname = "g",
  data = qwi_agg %>% filter(!is.na(log_earns)),
  control_group = "nevertreated",
  est_method = "dr",
  bstrap = TRUE,
  cband = TRUE,
  biters = 1000
)

# Aggregate ATT
cs_earns_agg <- aggte(cs_earns, type = "simple")
cat("QWI Earnings ATT:", round(cs_earns_agg$overall.att, 4),
    "(SE:", round(cs_earns_agg$overall.se, 4), ")\n")

# Event study
cs_earns_es <- aggte(cs_earns, type = "dynamic",
                      min_e = -20, max_e = 12)

# Also run TWFE for comparison
twfe_earns <- feols(
  log_earns ~ treat_post | statefip + quarter_num,
  data = qwi_agg %>% filter(!is.na(log_earns)),
  cluster = ~statefip
)
cat("TWFE Earnings:", round(coef(twfe_earns)["treat_postTRUE"], 4),
    "(SE:", round(se(twfe_earns)["treat_postTRUE"], 4), ")\n\n")

# ============================================================================
# Block B: Gender Earnings Gap DiD
# ============================================================================

cat("--- Block B: Gender Earnings Gap DiD ---\n")

# Use aggregate industry only
qwi_gap_agg <- qwi_gap %>% filter(is_aggregate)

# C-S on earnings gap
cs_gap <- tryCatch({
  att_gt(
    yname = "earns_gap",
    tname = "quarter_num",
    idname = "statefip",
    gname = "g",
    data = qwi_gap_agg %>% filter(!is.na(earns_gap)),
    control_group = "nevertreated",
    est_method = "dr",
    bstrap = TRUE,
    biters = 1000
  )
}, error = function(e) {
  cat("  C-S for gender gap failed:", conditionMessage(e), "\n")
  NULL
})

if (!is.null(cs_gap)) {
  cs_gap_agg <- aggte(cs_gap, type = "simple")
  cat("QWI Gender Gap ATT:", round(cs_gap_agg$overall.att, 4),
      "(SE:", round(cs_gap_agg$overall.se, 4), ")\n")
  cat("  Interpretation: negative = gap narrowing (women gaining)\n")

  cs_gap_es <- aggte(cs_gap, type = "dynamic",
                      min_e = -20, max_e = 12)
}

# TWFE version
twfe_gap <- feols(
  earns_gap ~ treat_post | statefip + quarter_num,
  data = qwi_gap_agg %>% filter(!is.na(earns_gap)),
  cluster = ~statefip
)
cat("TWFE Gender Gap:", round(coef(twfe_gap)["treat_postTRUE"], 4),
    "(SE:", round(se(twfe_gap)["treat_postTRUE"], 4), ")\n\n")

# ============================================================================
# Block C: Labor Market Dynamism DiD
# ============================================================================

cat("--- Block C: Labor Market Dynamism ---\n")

# Outcomes: hire_rate, sep_rate, log_hira, log_sep, net_job_creation_rate
dynamism_outcomes <- c("hire_rate", "sep_rate", "log_hira", "log_sep",
                        "net_job_creation_rate")

dynamism_results <- list()

for (outcome in dynamism_outcomes) {
  cat("  ", outcome, ": ")
  df_tmp <- qwi_agg %>% filter(!is.na(.data[[outcome]]))

  # TWFE (simpler, more robust with quarterly data)
  fml <- as.formula(paste0(outcome, " ~ treat_post | statefip + quarter_num"))
  fit <- tryCatch(
    feols(fml, data = df_tmp, cluster = ~statefip),
    error = function(e) NULL
  )

  if (!is.null(fit)) {
    coef_val <- coef(fit)["treat_postTRUE"]
    se_val <- se(fit)["treat_postTRUE"]
    pval <- fixest::pvalue(fit)["treat_postTRUE"]
    cat(round(coef_val, 4), "(SE:", round(se_val, 4), ", p:", round(pval, 3), ")\n")
    dynamism_results[[outcome]] <- list(
      outcome = outcome,
      estimator = "TWFE",
      coef = coef_val, se = se_val, pval = pval,
      n = nobs(fit)
    )
  } else {
    cat("FAILED\n")
  }
}

# Also run C-S on key outcomes
for (outcome in c("hire_rate", "sep_rate")) {
  cat("  C-S ", outcome, ": ")
  df_tmp <- qwi_agg %>% filter(!is.na(.data[[outcome]]))

  cs_fit <- tryCatch({
    att_gt(
      yname = outcome,
      tname = "quarter_num",
      idname = "statefip",
      gname = "g",
      data = df_tmp,
      control_group = "nevertreated",
      est_method = "dr",
      bstrap = TRUE,
      biters = 1000
    )
  }, error = function(e) {
    cat("FAILED (", conditionMessage(e), ")\n")
    NULL
  })

  if (!is.null(cs_fit)) {
    cs_agg_fit <- aggte(cs_fit, type = "simple")
    cat(round(cs_agg_fit$overall.att, 4),
        "(SE:", round(cs_agg_fit$overall.se, 4), ")\n")
    dynamism_results[[paste0(outcome, "_cs")]] <- list(
      outcome = outcome,
      estimator = "C-S",
      coef = cs_agg_fit$overall.att,
      se = cs_agg_fit$overall.se
    )
  }
}
cat("\n")

# ============================================================================
# Block D: Quarterly Event Studies
# ============================================================================

cat("--- Block D: Quarterly Event Studies ---\n")

# Event study for earnings
es_earns_data <- data.frame(
  event_time = cs_earns_es$egt,
  att = cs_earns_es$att.egt,
  se = cs_earns_es$se.egt,
  outcome = "Log Earnings"
)

# Event study for gender gap
es_gap_data <- NULL
if (!is.null(cs_gap)) {
  es_gap_data <- data.frame(
    event_time = cs_gap_es$egt,
    att = cs_gap_es$att.egt,
    se = cs_gap_es$se.egt,
    outcome = "Gender Earnings Gap"
  )
}

# Event study for separations and hiring using fixest sunab
# (Faster and more stable for quarterly data with many periods)
es_sep <- tryCatch({
  feols(sep_rate ~ sunab(g, quarter_num) | statefip + quarter_num,
        data = qwi_agg %>% filter(!is.na(sep_rate), g > 0 | g == 0),
        cluster = ~statefip)
}, error = function(e) {
  cat("  Sunab sep_rate failed:", conditionMessage(e), "\n")
  NULL
})

es_hire <- tryCatch({
  feols(hire_rate ~ sunab(g, quarter_num) | statefip + quarter_num,
        data = qwi_agg %>% filter(!is.na(hire_rate), g > 0 | g == 0),
        cluster = ~statefip)
}, error = function(e) {
  cat("  Sunab hire_rate failed:", conditionMessage(e), "\n")
  NULL
})

cat("  Earnings event study: ", nrow(es_earns_data), "coefficients\n")
if (!is.null(es_gap_data)) cat("  Gender gap event study: ", nrow(es_gap_data), "coefficients\n")
cat("\n")

# ============================================================================
# Block E: Industry Heterogeneity
# ============================================================================

cat("--- Block E: Industry Heterogeneity ---\n")

# Use sex=0 (aggregate sex) panel by industry
qwi_ind <- qwi_full %>%
  filter(sex_code == 0, !is_aggregate, !is.na(earns))

industry_results <- list()

for (ind_label in unique(qwi_ind$industry_label)) {
  cat("  ", ind_label, ": ")
  df_ind <- qwi_ind %>% filter(industry_label == ind_label, !is.na(log_earns))

  fit <- tryCatch(
    feols(log_earns ~ treat_post | statefip + quarter_num,
          data = df_ind, cluster = ~statefip),
    error = function(e) NULL
  )

  if (!is.null(fit)) {
    cat(round(coef(fit)["treat_postTRUE"], 4),
        "(SE:", round(se(fit)["treat_postTRUE"], 4), ")\n")
    industry_results[[ind_label]] <- list(
      industry = ind_label,
      coef = coef(fit)["treat_postTRUE"],
      se = se(fit)["treat_postTRUE"],
      pval = fixest::pvalue(fit)["treat_postTRUE"],
      n = nobs(fit)
    )
  } else {
    cat("FAILED\n")
  }
}

# Industry x gender gap
cat("\n  Industry gender gap effects:\n")
for (ind_label in unique(qwi_gap$industry_label[!qwi_gap$is_aggregate])) {
  df_tmp <- qwi_gap %>%
    filter(industry_label == ind_label, !is.na(earns_gap))

  fit <- tryCatch(
    feols(earns_gap ~ treat_post | statefip + quarter_num,
          data = df_tmp, cluster = ~statefip),
    error = function(e) NULL
  )

  if (!is.null(fit)) {
    cat("    ", ind_label, ": ", round(coef(fit)["treat_postTRUE"], 4),
        "(SE:", round(se(fit)["treat_postTRUE"], 4), ")\n")
    industry_results[[paste0(ind_label, "_gap")]] <- list(
      industry = ind_label,
      outcome = "earnings_gap",
      coef = coef(fit)["treat_postTRUE"],
      se = se(fit)["treat_postTRUE"],
      pval = fixest::pvalue(fit)["treat_postTRUE"],
      n = nobs(fit)
    )
  }
}
cat("\n")

# ============================================================================
# Block F: Sex x Treatment DDD with QWI
# ============================================================================

cat("--- Block F: Sex x Treatment DDD ---\n")

# Use male (1) and female (2) data, aggregate industry
qwi_sex <- qwi_full %>%
  filter(sex_code %in% c(1, 2), is_aggregate, !is.na(log_earns)) %>%
  mutate(female = as.integer(sex_code == 2))

# DDD: treat_post x female with state-quarter FE
ddd_fit <- tryCatch(
  feols(log_earns ~ treat_post * female | statefip^quarter_num,
        data = qwi_sex, cluster = ~statefip),
  error = function(e) {
    cat("DDD failed:", conditionMessage(e), "\n")
    NULL
  }
)

if (!is.null(ddd_fit)) {
  cat("QWI DDD (treat_post x female):", round(coef(ddd_fit)["treat_postTRUE:female"], 4),
      "(SE:", round(se(ddd_fit)["treat_postTRUE:female"], 4), ")\n")
  cat("  Positive = women's earnings rose relative to men's\n")
}

# DDD by industry (high-bargaining vs low-bargaining)
cat("\n  DDD by bargaining intensity:\n")
for (barg in c(TRUE, FALSE)) {
  label <- ifelse(barg, "High-Bargaining", "Low-Bargaining")
  df_barg <- qwi_full %>%
    filter(sex_code %in% c(1, 2), high_bargaining == barg | low_bargaining == !barg,
           !is.na(log_earns)) %>%
    filter(if (barg) high_bargaining else low_bargaining) %>%
    mutate(female = as.integer(sex_code == 2))

  fit_barg <- tryCatch(
    feols(log_earns ~ treat_post * female | statefip^quarter_num,
          data = df_barg, cluster = ~statefip),
    error = function(e) NULL
  )

  if (!is.null(fit_barg)) {
    cat("    ", label, ": ", round(coef(fit_barg)["treat_postTRUE:female"], 4),
        "(SE:", round(se(fit_barg)["treat_postTRUE:female"], 4), ")\n")
  }
}

# ============================================================================
# Save Results
# ============================================================================

cat("\n=== Saving Results ===\n")

results <- list(
  # Aggregate earnings
  cs_earns_att = list(
    att = cs_earns_agg$overall.att,
    se = cs_earns_agg$overall.se
  ),
  twfe_earns = list(
    coef = coef(twfe_earns)["treat_postTRUE"],
    se = se(twfe_earns)["treat_postTRUE"]
  ),
  # Gender gap
  twfe_gap = list(
    coef = coef(twfe_gap)["treat_postTRUE"],
    se = se(twfe_gap)["treat_postTRUE"]
  ),
  # Dynamism
  dynamism = dynamism_results,
  # Industry
  industry = industry_results,
  # DDD
  ddd = if (!is.null(ddd_fit)) list(
    coef = coef(ddd_fit)["treat_postTRUE:female"],
    se = se(ddd_fit)["treat_postTRUE:female"]
  ) else NULL
)

if (!is.null(cs_gap)) {
  results$cs_gap_att <- list(
    att = cs_gap_agg$overall.att,
    se = cs_gap_agg$overall.se
  )
}

# Event studies
event_studies <- list(
  earnings = es_earns_data,
  gender_gap = es_gap_data
)

saveRDS(results, "data/qwi_results.rds")
saveRDS(event_studies, "data/qwi_event_study.rds")

# Save model objects for figures
saveRDS(cs_earns_es, "data/qwi_cs_earns_es.rds")
if (!is.null(cs_gap)) saveRDS(cs_gap_es, "data/qwi_cs_gap_es.rds")
if (!is.null(es_sep)) saveRDS(es_sep, "data/qwi_es_sep.rds")
if (!is.null(es_hire)) saveRDS(es_hire, "data/qwi_es_hire.rds")

cat("Saved data/qwi_results.rds\n")
cat("Saved data/qwi_event_study.rds\n")
cat("\n=== QWI Analysis Complete ===\n")
