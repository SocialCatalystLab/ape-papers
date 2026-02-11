##############################################################################
# 03_main_analysis.R — Primary DiD estimation
# APEP-0222 v2: Educational Content Restriction Laws and Teacher Labor Markets
# Revision: NAICS 6111 (K-12) primary panel + CS for female share
##############################################################################

source("00_packages.R")

cat("=== Main analysis ===\n")

# Load data
edu_panel <- readRDS("../data/edu_panel.rds")
triple_diff <- readRDS("../data/triple_diff.rds")
edu_hc_gap <- readRDS("../data/edu_hc_gap.rds")
treatment_laws <- readRDS("../data/treatment_laws.rds")

# ============================================================================
# A) TREATMENT ROLLOUT VISUALIZATION
# ============================================================================

# Cohort sizes
cohort_counts <- treatment_laws %>%
  count(cohort_label, name = "n_states") %>%
  arrange(cohort_label)
cat("Treatment cohort sizes:\n")
print(cohort_counts)
cat(sprintf("Never-treated states: %d\n",
            51 - nrow(treatment_laws)))

# ============================================================================
# B) CALLAWAY-SANT'ANNA ESTIMATION
# ============================================================================

# Prepare education panel for CS
cs_data <- edu_panel %>%
  filter(!is.na(Emp), Emp > 0) %>%
  select(state_id, time_int, first_treat_int, log_emp, log_earn, sep_rate, hire_rate,
         TurnOvrS, state_fips, year, quarter, treat, treated_state,
         stringency, stringency_score) %>%
  distinct(state_id, time_int, .keep_all = TRUE)

cat(sprintf("\nCS estimation data: %d obs, %d states, %d periods\n",
            nrow(cs_data), n_distinct(cs_data$state_id), n_distinct(cs_data$time_int)))

# --- CS: Log Employment ---
cat("\n--- Estimating CS ATT for Log Employment ---\n")
cs_emp <- att_gt(
  yname = "log_emp",
  tname = "time_int",
  idname = "state_id",
  gname = "first_treat_int",
  data = cs_data,
  control_group = "nevertreated",
  anticipation = 0,
  base_period = "universal"
)

# Aggregate to overall ATT
agg_emp <- aggte(cs_emp, type = "simple")
cat("Overall ATT (Log Employment):\n")
summary(agg_emp)

# Dynamic (event study) aggregation
es_emp <- aggte(cs_emp, type = "dynamic", min_e = -8, max_e = 12)
cat("\nEvent Study (Log Employment):\n")
summary(es_emp)

# --- CS: Separation Rate ---
cat("\n--- Estimating CS ATT for Separation Rate ---\n")
cs_sep <- att_gt(
  yname = "sep_rate",
  tname = "time_int",
  idname = "state_id",
  gname = "first_treat_int",
  data = cs_data,
  control_group = "nevertreated",
  anticipation = 0,
  base_period = "universal"
)

agg_sep <- aggte(cs_sep, type = "simple")
cat("Overall ATT (Separation Rate):\n")
summary(agg_sep)

es_sep <- aggte(cs_sep, type = "dynamic", min_e = -8, max_e = 12)

# --- CS: Log Earnings ---
cat("\n--- Estimating CS ATT for Log Earnings ---\n")
cs_earn <- att_gt(
  yname = "log_earn",
  tname = "time_int",
  idname = "state_id",
  gname = "first_treat_int",
  data = cs_data,
  control_group = "nevertreated",
  anticipation = 0,
  base_period = "universal"
)

agg_earn <- aggte(cs_earn, type = "simple")
cat("Overall ATT (Log Earnings):\n")
summary(agg_earn)

es_earn <- aggte(cs_earn, type = "dynamic", min_e = -8, max_e = 12)

# --- CS: Hire Rate ---
cat("\n--- Estimating CS ATT for Hire Rate ---\n")
cs_hire <- att_gt(
  yname = "hire_rate",
  tname = "time_int",
  idname = "state_id",
  gname = "first_treat_int",
  data = cs_data,
  control_group = "nevertreated",
  anticipation = 0,
  base_period = "universal"
)

agg_hire <- aggte(cs_hire, type = "simple")
cat("Overall ATT (Hire Rate):\n")
summary(agg_hire)

es_hire <- aggte(cs_hire, type = "dynamic", min_e = -8, max_e = 12)

# --- CS: Turnover Rate ---
cat("\n--- Estimating CS ATT for Turnover ---\n")
cs_turn <- att_gt(
  yname = "TurnOvrS",
  tname = "time_int",
  idname = "state_id",
  gname = "first_treat_int",
  data = cs_data,
  control_group = "nevertreated",
  anticipation = 0,
  base_period = "universal"
)

agg_turn <- aggte(cs_turn, type = "simple")
cat("Overall ATT (Turnover):\n")
summary(agg_turn)

es_turn <- aggte(cs_turn, type = "dynamic", min_e = -8, max_e = 12)

# ============================================================================
# B2) CS FOR FEMALE SHARE (from sex-disaggregated 6111 data)
# ============================================================================

cat("\n--- Estimating CS ATT for Female Share ---\n")

cs_female <- NULL
agg_female <- NULL
es_female <- NULL
twfe_female <- NULL

if (file.exists("../data/female_share_panel.rds")) {
  fs_panel <- readRDS("../data/female_share_panel.rds")
  fs_data <- fs_panel %>%
    filter(!is.na(female_share)) %>%
    distinct(state_id, time_int, .keep_all = TRUE)

  cat(sprintf("Female share data: %d obs, %d states\n",
              nrow(fs_data), n_distinct(fs_data$state_id)))

  tryCatch({
    cs_female <- att_gt(
      yname = "female_share",
      tname = "time_int",
      idname = "state_id",
      gname = "first_treat_int",
      data = fs_data,
      control_group = "nevertreated",
      anticipation = 0,
      base_period = "universal"
    )

    agg_female <- aggte(cs_female, type = "simple")
    cat("Overall ATT (Female Share, CS):\n")
    summary(agg_female)

    es_female <- aggte(cs_female, type = "dynamic", min_e = -8, max_e = 12)
    cat("\nEvent Study (Female Share, CS):\n")
    summary(es_female)
  }, error = function(e) {
    cat("CS female share error:", conditionMessage(e), "\n")
  })

  # TWFE for comparison
  tryCatch({
    twfe_female <- feols(female_share ~ treat | state_id + time_int,
                         data = fs_data, cluster = ~state_id)
    cat("TWFE Female Share:\n")
    summary(twfe_female)
  }, error = function(e) {
    cat("TWFE female share error:", conditionMessage(e), "\n")
  })
}

# ============================================================================
# C) TWFE WITH FIXEST (for comparison and decomposition)
# ============================================================================

cat("\n=== TWFE Estimation (fixest) ===\n")

# TWFE: Log Employment
twfe_emp <- feols(log_emp ~ treat | state_id + time_int,
                  data = cs_data, cluster = ~state_id)

# TWFE: Separation Rate
twfe_sep <- feols(sep_rate ~ treat | state_id + time_int,
                  data = cs_data, cluster = ~state_id)

# TWFE: Log Earnings
twfe_earn <- feols(log_earn ~ treat | state_id + time_int,
                   data = cs_data, cluster = ~state_id)

# TWFE: Hire Rate
twfe_hire <- feols(hire_rate ~ treat | state_id + time_int,
                   data = cs_data, cluster = ~state_id)

cat("TWFE Results:\n")
etable(twfe_emp, twfe_sep, twfe_earn, twfe_hire,
       headers = c("Log Emp", "Sep Rate", "Log Earn", "Hire Rate"))

# ============================================================================
# D) SUN-ABRAHAM ESTIMATION
# ============================================================================

cat("\n=== Sun-Abraham Estimation ===\n")

# Need to exclude never-treated from gname for sunab
cs_data_sa <- cs_data %>%
  mutate(cohort = ifelse(first_treat_int == 0, 10000, first_treat_int))

sa_emp <- feols(log_emp ~ sunab(cohort, time_int) | state_id + time_int,
                data = cs_data_sa, cluster = ~state_id)

sa_sep <- feols(sep_rate ~ sunab(cohort, time_int) | state_id + time_int,
                data = cs_data_sa, cluster = ~state_id)

sa_earn <- feols(log_earn ~ sunab(cohort, time_int) | state_id + time_int,
                 data = cs_data_sa, cluster = ~state_id)

cat("Sun-Abraham ATT (employment):\n")
summary(sa_emp, agg = "ATT")

# ============================================================================
# E) TRIPLE-DIFFERENCE: EDUCATION vs HEALTHCARE
# ============================================================================

cat("\n=== Triple-Difference Estimation ===\n")

# Prepare triple-diff data
td_data <- triple_diff %>%
  filter(!is.na(Emp), Emp > 0) %>%
  mutate(
    log_emp = log(Emp + 1),
    log_earn = log(EarnS + 1),
    sep_rate = Sep / (Emp + 1),
    hire_rate = HirA / (Emp + 1),
    state_ind = paste0(state_fips, "_", industry),
    state_ind_id = as.integer(factor(state_ind))
  )

# DDD specification: Y = state-industry FE + industry-time FE + state-time FE + treat*education + e
ddd_emp <- feols(log_emp ~ DDD | state_fips^industry + industry^time_int + state_fips^time_int,
                 data = td_data, cluster = ~state_fips)

ddd_sep <- feols(sep_rate ~ DDD | state_fips^industry + industry^time_int + state_fips^time_int,
                 data = td_data, cluster = ~state_fips)

ddd_earn <- feols(log_earn ~ DDD | state_fips^industry + industry^time_int + state_fips^time_int,
                  data = td_data, cluster = ~state_fips)

ddd_hire <- feols(hire_rate ~ DDD | state_fips^industry + industry^time_int + state_fips^time_int,
                  data = td_data, cluster = ~state_fips)

cat("Triple-Difference Results:\n")
etable(ddd_emp, ddd_sep, ddd_earn, ddd_hire,
       headers = c("Log Emp", "Sep Rate", "Log Earn", "Hire Rate"))

# ============================================================================
# F) GOODMAN-BACON DECOMPOSITION
# ============================================================================

cat("\n=== Goodman-Bacon Decomposition ===\n")

# Prepare for bacon decomposition (needs balanced panel, binary treat)
bacon_data <- cs_data %>%
  filter(!is.na(log_emp)) %>%
  # Balance panel
  group_by(state_id) %>%
  filter(n() == max(n_distinct(time_int))) %>%
  ungroup() %>%
  mutate(treat_bacon = as.integer(first_treat_int > 0 & time_int >= first_treat_int))

tryCatch({
  bacon_out <- bacon(log_emp ~ treat_bacon,
                     data = bacon_data,
                     id_var = "state_id",
                     time_var = "time_int")
  cat("Bacon Decomposition:\n")
  print(bacon_out %>%
    group_by(type) %>%
    summarise(
      n_comparisons = n(),
      avg_weight = mean(weight),
      avg_estimate = weighted.mean(estimate, weight),
      .groups = "drop"
    ))
  saveRDS(bacon_out, "../data/bacon_decomp.rds")
}, error = function(e) {
  cat("Bacon decomposition error:", conditionMessage(e), "\n")
  cat("Skipping — will use CS and Sun-Abraham instead.\n")
})

# ============================================================================
# SAVE ALL RESULTS
# ============================================================================

results <- list(
  # CS estimates
  cs_emp = cs_emp, cs_sep = cs_sep, cs_earn = cs_earn,
  cs_hire = cs_hire, cs_turn = cs_turn, cs_female = cs_female,
  # CS aggregated
  agg_emp = agg_emp, agg_sep = agg_sep, agg_earn = agg_earn,
  agg_hire = agg_hire, agg_turn = agg_turn, agg_female = agg_female,
  # CS event studies
  es_emp = es_emp, es_sep = es_sep, es_earn = es_earn,
  es_hire = es_hire, es_turn = es_turn, es_female = es_female,
  # TWFE
  twfe_emp = twfe_emp, twfe_sep = twfe_sep,
  twfe_earn = twfe_earn, twfe_hire = twfe_hire,
  twfe_female = twfe_female,
  # Sun-Abraham
  sa_emp = sa_emp, sa_sep = sa_sep, sa_earn = sa_earn,
  # Triple-diff
  ddd_emp = ddd_emp, ddd_sep = ddd_sep,
  ddd_earn = ddd_earn, ddd_hire = ddd_hire
)

saveRDS(results, "../data/main_results.rds")
cat("\n=== Main analysis complete. Results saved. ===\n")
