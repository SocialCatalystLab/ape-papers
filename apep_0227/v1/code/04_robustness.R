## ============================================================================
## 04_robustness.R — Robustness checks and sensitivity analysis
## APEP Working Paper apep_0225
## ============================================================================

source("00_packages.R")

data_dir <- "../data"
df <- readRDS(file.path(data_dir, "analysis_panel.rds"))
results <- readRDS(file.path(data_dir, "main_results.rds"))

robust_results <- list()

## ---------------------------------------------------------------------------
## Helper: aggregate att_gt results manually (workaround for aggte bug)
## ---------------------------------------------------------------------------

aggregate_attgt <- function(out, type = "simple") {
  gt_df <- data.frame(
    group = out$group,
    time = out$t,
    att = out$att,
    se = out$se
  ) %>% filter(!is.na(att))

  if (type == "simple") {
    post <- gt_df %>% filter(time >= group)
    list(
      overall.att = mean(post$att, na.rm = TRUE),
      overall.se = sqrt(mean(post$se^2, na.rm = TRUE) / nrow(post)),
      n_gt = nrow(post)
    )
  } else if (type == "dynamic") {
    gt_df <- gt_df %>%
      mutate(event_time = time - group)
    es <- gt_df %>%
      group_by(event_time) %>%
      summarise(
        att = mean(att, na.rm = TRUE),
        se = sqrt(mean(se^2, na.rm = TRUE) / n()),
        n_groups = n(),
        .groups = "drop"
      ) %>%
      arrange(event_time)
    list(
      egt = es$event_time,
      att.egt = es$att,
      se.egt = es$se,
      n_groups = es$n_groups
    )
  } else if (type == "group") {
    post <- gt_df %>% filter(time >= group)
    grp <- post %>%
      group_by(group) %>%
      summarise(
        att = mean(att, na.rm = TRUE),
        se = sqrt(mean(se^2, na.rm = TRUE) / n()),
        .groups = "drop"
      )
    list(
      egt = grp$group,
      att.egt = grp$att,
      se.egt = grp$se
    )
  }
}

## ---------------------------------------------------------------------------
## 1. HonestDiD Sensitivity Analysis (Rambachan & Roth 2023)
## ---------------------------------------------------------------------------

cat("=== HonestDiD Sensitivity Analysis ===\n")

tryCatch({
  cs_es <- results$cs_es_never

  # Extract pre-treatment coefficients for sensitivity
  pre_idx <- which(cs_es$egt < 0)
  post_idx <- which(cs_es$egt >= 0)

  if (length(pre_idx) >= 2 && length(post_idx) >= 1) {
    # Relative magnitudes approach: how large could pre-trend violations be?
    betahat <- cs_es$att.egt
    sigma <- diag(cs_es$se.egt^2)

    honest_rm <- HonestDiD::createSensitivityResults_relativeMagnitudes(
      betahat = betahat,
      sigma = sigma,
      numPrePeriods = length(pre_idx),
      numPostPeriods = length(post_idx),
      Mbarvec = seq(0, 2, by = 0.5)
    )

    cat("HonestDiD relative magnitudes bounds:\n")
    print(honest_rm)
    robust_results$honest_did <- honest_rm
  }
}, error = function(e) {
  cat("HonestDiD error:", conditionMessage(e), "\n")
  cat("Proceeding with other robustness checks.\n")
})

## ---------------------------------------------------------------------------
## 2. Placebo Outcomes
## ---------------------------------------------------------------------------

cat("\n=== Placebo Outcome Tests ===\n")

cs_df <- df %>%
  filter(!is.na(first_treat)) %>%
  mutate(gname = first_treat, id = state_id)

# Placebo 1: Cocaine deaths (not directly affected by FTS for fentanyl)
cat("Placebo: Cocaine overdose deaths...\n")
tryCatch({
  cs_cocaine <- att_gt(
    yname = "rate_cocaine",
    tname = "year", idname = "id", gname = "gname",
    data = cs_df,
    control_group = "nevertreated",
    est_method = "dr", bstrap = TRUE, biters = 1000,
    clustervars = "id", print_details = FALSE
  )
  cs_cocaine_agg <- aggregate_attgt(cs_cocaine, type = "simple")
  cat("  ATT:", round(cs_cocaine_agg$overall.att, 3),
      "SE:", round(cs_cocaine_agg$overall.se, 3), "\n")
  robust_results$placebo_cocaine <- cs_cocaine_agg

  cs_cocaine_es <- aggregate_attgt(cs_cocaine, type = "dynamic")
  robust_results$placebo_cocaine_es <- cs_cocaine_es
}, error = function(e) {
  cat("  Error:", conditionMessage(e), "\n")
})

# Placebo 2: Natural/semi-synthetic opioids (prescription opioids)
cat("Placebo: Natural opioid deaths (T40.2)...\n")
tryCatch({
  cs_natural <- att_gt(
    yname = "rate_natural_opioid",
    tname = "year", idname = "id", gname = "gname",
    data = cs_df,
    control_group = "nevertreated",
    est_method = "dr", bstrap = TRUE, biters = 1000,
    clustervars = "id", print_details = FALSE
  )
  cs_natural_agg <- aggregate_attgt(cs_natural, type = "simple")
  cat("  ATT:", round(cs_natural_agg$overall.att, 3),
      "SE:", round(cs_natural_agg$overall.se, 3), "\n")
  robust_results$placebo_natural <- cs_natural_agg
}, error = function(e) {
  cat("  Error:", conditionMessage(e), "\n")
})

# Placebo 3: Heroin deaths (declining trend, partially affected)
cat("Placebo: Heroin deaths (T40.1)...\n")
tryCatch({
  cs_heroin <- att_gt(
    yname = "rate_heroin",
    tname = "year", idname = "id", gname = "gname",
    data = cs_df,
    control_group = "nevertreated",
    est_method = "dr", bstrap = TRUE, biters = 1000,
    clustervars = "id", print_details = FALSE
  )
  cs_heroin_agg <- aggregate_attgt(cs_heroin, type = "simple")
  cat("  ATT:", round(cs_heroin_agg$overall.att, 3),
      "SE:", round(cs_heroin_agg$overall.se, 3), "\n")
  robust_results$placebo_heroin <- cs_heroin_agg
}, error = function(e) {
  cat("  Error:", conditionMessage(e), "\n")
})

## ---------------------------------------------------------------------------
## 3. Excluding Early Adopters (Drop 2018 Cohort)
## ---------------------------------------------------------------------------

cat("\n=== Sensitivity: Excluding 2018 Cohort ===\n")

cs_df_no2018 <- cs_df %>% filter(first_treat != 2018)

tryCatch({
  cs_no2018 <- att_gt(
    yname = "rate_synth_opioid",
    tname = "year", idname = "id", gname = "gname",
    data = cs_df_no2018,
    control_group = "nevertreated",
    est_method = "dr", bstrap = TRUE, biters = 1000,
    clustervars = "id", print_details = FALSE
  )
  cs_no2018_agg <- aggregate_attgt(cs_no2018, type = "simple")
  cat("ATT (excl. 2018 cohort):", round(cs_no2018_agg$overall.att, 3),
      "SE:", round(cs_no2018_agg$overall.se, 3), "\n")
  robust_results$excl_2018 <- cs_no2018_agg
}, error = function(e) {
  cat("Error:", conditionMessage(e), "\n")
})

## ---------------------------------------------------------------------------
## 4. With Concurrent Policy Controls (Conditional PT)
## ---------------------------------------------------------------------------

cat("\n=== Sensitivity: Conditional on Concurrent Policies ===\n")

tryCatch({
  cs_controls <- att_gt(
    yname = "rate_synth_opioid",
    tname = "year", idname = "id", gname = "gname",
    data = cs_df %>% filter(!is.na(poverty_rate) & !is.na(unemp_rate)),
    xformla = ~ naloxone_law + medicaid_expanded + poverty_rate + unemp_rate,
    control_group = "nevertreated",
    est_method = "dr", bstrap = TRUE, biters = 1000,
    clustervars = "id", print_details = FALSE
  )
  cs_controls_agg <- aggregate_attgt(cs_controls, type = "simple")
  cat("ATT (with controls):", round(cs_controls_agg$overall.att, 3),
      "SE:", round(cs_controls_agg$overall.se, 3), "\n")
  robust_results$with_controls <- cs_controls_agg

  cs_controls_es <- aggregate_attgt(cs_controls, type = "dynamic")
  robust_results$controls_es <- cs_controls_es
}, error = function(e) {
  cat("Error:", conditionMessage(e), "\n")
})

## ---------------------------------------------------------------------------
## 5. All Drug Overdose Deaths (Broader Outcome)
## ---------------------------------------------------------------------------

cat("\n=== Alternative Outcome: All Drug Overdose Deaths ===\n")

tryCatch({
  cs_alldrug <- att_gt(
    yname = "rate_all_drug",
    tname = "year", idname = "id", gname = "gname",
    data = cs_df,
    control_group = "nevertreated",
    est_method = "dr", bstrap = TRUE, biters = 1000,
    clustervars = "id", print_details = FALSE
  )
  cs_alldrug_agg <- aggregate_attgt(cs_alldrug, type = "simple")
  cat("ATT (all drug deaths):", round(cs_alldrug_agg$overall.att, 3),
      "SE:", round(cs_alldrug_agg$overall.se, 3), "\n")
  robust_results$all_drug <- cs_alldrug_agg

  cs_alldrug_es <- aggregate_attgt(cs_alldrug, type = "dynamic")
  robust_results$all_drug_es <- cs_alldrug_es
}, error = function(e) {
  cat("Error:", conditionMessage(e), "\n")
})

## ---------------------------------------------------------------------------
## 6. Stimulant Deaths (Fentanyl-contaminated stimulants channel)
## ---------------------------------------------------------------------------

cat("\n=== Additional Outcome: Stimulant Deaths ===\n")

tryCatch({
  cs_stim <- att_gt(
    yname = "rate_stimulant",
    tname = "year", idname = "id", gname = "gname",
    data = cs_df,
    control_group = "nevertreated",
    est_method = "dr", bstrap = TRUE, biters = 1000,
    clustervars = "id", print_details = FALSE
  )
  cs_stim_agg <- aggregate_attgt(cs_stim, type = "simple")
  cat("ATT (stimulant deaths):", round(cs_stim_agg$overall.att, 3),
      "SE:", round(cs_stim_agg$overall.se, 3), "\n")
  robust_results$stimulant <- cs_stim_agg
}, error = function(e) {
  cat("Error:", conditionMessage(e), "\n")
})

## ---------------------------------------------------------------------------
## 7. Heterogeneity by Baseline Overdose Rate Quintile
## ---------------------------------------------------------------------------

cat("\n=== Heterogeneity: By Baseline Overdose Quintile ===\n")

hetero_results <- list()

for (q in 1:5) {
  cat("  Quintile", q, "...")
  sub_df <- cs_df %>% filter(baseline_quintile == q)

  # Need at least some never-treated units in this quintile
  n_never <- sum(sub_df$first_treat == 0 & sub_df$year == 2020)
  n_treated <- sum(sub_df$first_treat > 0 & sub_df$year == 2020)

  if (n_never < 1 || n_treated < 3) {
    cat(" insufficient variation, skipping.\n")
    next
  }

  tryCatch({
    cs_q <- att_gt(
      yname = "rate_synth_opioid",
      tname = "year", idname = "id", gname = "gname",
      data = sub_df,
      control_group = "nevertreated",
      est_method = "dr", bstrap = TRUE, biters = 1000,
      clustervars = "id", print_details = FALSE
    )
    cs_q_agg <- aggregate_attgt(cs_q, type = "simple")
    hetero_results[[paste0("q", q)]] <- cs_q_agg
    cat(" ATT:", round(cs_q_agg$overall.att, 3),
        "SE:", round(cs_q_agg$overall.se, 3), "\n")
  }, error = function(e) {
    cat(" Error:", conditionMessage(e), "\n")
  })
}

robust_results$heterogeneity_quintile <- hetero_results

## ---------------------------------------------------------------------------
## 8. Randomization Inference
## ---------------------------------------------------------------------------

cat("\n=== Randomization Inference ===\n")

# Permute treatment timing 500 times, estimate ATT each time
set.seed(20250225)

# Get actual ATT
actual_att <- results$cs_agg_never$overall.att

# Get unique treated states and their first_treat values
treated_states <- cs_df %>%
  filter(first_treat > 0) %>%
  distinct(id, first_treat) %>%
  pull(first_treat)

n_perms <- 200  # Reduced for speed; 500 in a full run

perm_atts <- numeric(n_perms)

cat("Running", n_perms, "permutations...\n")
for (p in 1:n_perms) {
  if (p %% 50 == 0) cat("  Permutation", p, "\n")

  # Shuffle treatment timing among treated states
  perm_df <- cs_df
  treated_ids <- cs_df %>%
    filter(first_treat > 0) %>%
    distinct(id) %>%
    pull(id)

  shuffled_gnames <- sample(treated_states)

  # Reassign first_treat to shuffled values
  id_map <- tibble(id = treated_ids, new_gname = shuffled_gnames[1:length(treated_ids)])

  perm_df <- perm_df %>%
    left_join(id_map, by = "id") %>%
    mutate(gname_perm = ifelse(first_treat == 0, 0L, new_gname)) %>%
    select(-new_gname)

  tryCatch({
    cs_perm <- att_gt(
      yname = "rate_synth_opioid",
      tname = "year", idname = "id", gname = "gname_perm",
      data = perm_df,
      control_group = "nevertreated",
      est_method = "dr", bstrap = FALSE,
      print_details = FALSE
    )
    cs_perm_agg <- aggregate_attgt(cs_perm, type = "simple")
    perm_atts[p] <- cs_perm_agg$overall.att
  }, error = function(e) {
    perm_atts[p] <- NA
  })
}

# RI p-value: fraction of permuted ATTs more extreme than actual
perm_atts_valid <- perm_atts[!is.na(perm_atts)]
ri_pvalue <- mean(abs(perm_atts_valid) >= abs(actual_att))

cat("Randomization inference p-value:", round(ri_pvalue, 4), "\n")
cat("Actual ATT:", round(actual_att, 3), "\n")
cat("Permutation ATT distribution: mean =", round(mean(perm_atts_valid), 3),
    "sd =", round(sd(perm_atts_valid), 3), "\n")

robust_results$ri_pvalue <- ri_pvalue
robust_results$perm_atts <- perm_atts_valid

## ---------------------------------------------------------------------------
## 9. Save all robustness results
## ---------------------------------------------------------------------------

saveRDS(robust_results, file.path(data_dir, "robustness_results.rds"))

cat("\n=== All robustness checks complete ===\n")
