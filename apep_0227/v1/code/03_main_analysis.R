## ============================================================================
## 03_main_analysis.R — Primary DiD estimation
## APEP Working Paper apep_0225
## ============================================================================

source("00_packages.R")

data_dir <- "../data"
df <- readRDS(file.path(data_dir, "analysis_panel.rds"))

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
    # Simple ATT: average of all post-treatment group-time ATTs
    post <- gt_df %>% filter(time >= group)
    list(
      overall.att = mean(post$att, na.rm = TRUE),
      overall.se = sqrt(mean(post$se^2, na.rm = TRUE) / nrow(post)),
      n_gt = nrow(post)
    )
  } else if (type == "dynamic") {
    # Event study: average by event time
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
    # Group-specific ATTs
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
## 1. Descriptive Statistics
## ---------------------------------------------------------------------------

cat("=== Descriptive Statistics ===\n\n")

rollout <- df %>%
  filter(first_treat > 0) %>%
  distinct(state_abb, first_treat) %>%
  count(first_treat, name = "n_states") %>%
  arrange(first_treat)

cat("Treatment rollout:\n")
print(rollout)

desc_stats <- df %>%
  group_by(treated_label = ifelse(treated == 1, "Post-Treatment", "Pre/Never-Treated")) %>%
  summarise(
    n = n(),
    mean_synth_rate = mean(rate_synth_opioid, na.rm = TRUE),
    sd_synth_rate = sd(rate_synth_opioid, na.rm = TRUE),
    mean_all_drug_rate = mean(rate_all_drug, na.rm = TRUE),
    mean_cocaine_rate = mean(rate_cocaine, na.rm = TRUE),
    mean_stimulant_rate = mean(rate_stimulant, na.rm = TRUE),
    mean_poverty = mean(poverty_rate, na.rm = TRUE),
    mean_unemp = mean(unemp_rate, na.rm = TRUE),
    .groups = "drop"
  )
cat("\nSummary by treatment status:\n")
print(desc_stats)

saveRDS(desc_stats, file.path(data_dir, "desc_stats.rds"))
saveRDS(rollout, file.path(data_dir, "rollout_summary.rds"))

## ---------------------------------------------------------------------------
## 2. TWFE Baseline
## ---------------------------------------------------------------------------

cat("\n=== TWFE Baseline ===\n")

twfe_basic <- feols(
  rate_synth_opioid ~ treated | state_abb + year,
  data = df, cluster = ~ state_abb
)

## Rescale proportion variables to percentage points for interpretable coefficients
df <- df %>%
  mutate(
    poverty_pct = poverty_rate * 100,
    unemp_pct = unemp_rate * 100
  )

twfe_controls <- feols(
  rate_synth_opioid ~ treated + naloxone_law + medicaid_expanded +
    poverty_pct + unemp_pct | state_abb + year,
  data = df, cluster = ~ state_abb
)

twfe_log <- feols(
  log_rate_synth ~ treated | state_abb + year,
  data = df, cluster = ~ state_abb
)

cat("TWFE (basic):", round(coef(twfe_basic)["treated"], 3), "\n")
cat("TWFE (controls):", round(coef(twfe_controls)["treated"], 3), "\n")
cat("TWFE (log):", round(coef(twfe_log)["treated"], 4), "\n")

## ---------------------------------------------------------------------------
## 3. Callaway-Sant'Anna (Primary Estimator)
## ---------------------------------------------------------------------------

cat("\n=== Callaway-Sant'Anna Estimator ===\n")

cs_df <- df %>%
  filter(!is.na(first_treat)) %>%
  mutate(
    gname = ifelse(first_treat == 0 | first_treat > 2023, 0L, as.integer(first_treat)),
    id = state_id
  ) %>%
  as.data.frame()

cat("CS-DiD data:", n_distinct(cs_df$id), "states,",
    sum(cs_df$gname == 0 & cs_df$year == 2020), "never-treated\n")

# 3a. Never-treated comparison group (primary)
cat("Running CS-DiD with never-treated comparison group...\n")

cs_never <- att_gt(
  yname = "rate_synth_opioid",
  tname = "year",
  idname = "id",
  gname = "gname",
  data = cs_df,
  control_group = "nevertreated",
  est_method = "dr",
  bstrap = TRUE,
  biters = 1000,
  clustervars = "id",
  print_details = FALSE
)

# Aggregate manually (workaround for aggte bug in did 2.3.0)
cs_agg_never <- aggregate_attgt(cs_never, "simple")
cs_es_never <- aggregate_attgt(cs_never, "dynamic")
cs_group <- aggregate_attgt(cs_never, "group")

cat("CS-DiD ATT (never-treated):", round(cs_agg_never$overall.att, 3),
    "SE:", round(cs_agg_never$overall.se, 3), "\n")

cat("\nEvent study (dynamic ATTs):\n")
for (i in seq_along(cs_es_never$egt)) {
  et <- cs_es_never$egt[i]
  star <- ifelse(abs(cs_es_never$att.egt[i]) > 1.96 * cs_es_never$se.egt[i], "*", "")
  cat("  e =", sprintf("%+d", et), ": ATT =",
      sprintf("%7.3f", cs_es_never$att.egt[i]),
      "(SE =", sprintf("%.3f", cs_es_never$se.egt[i]), ")", star, "\n")
}

# 3b. Not-yet-treated comparison group (robustness)
cat("\nRunning CS-DiD with not-yet-treated comparison group...\n")

cs_notyet <- att_gt(
  yname = "rate_synth_opioid",
  tname = "year",
  idname = "id",
  gname = "gname",
  data = cs_df,
  control_group = "notyettreated",
  est_method = "dr",
  bstrap = TRUE,
  biters = 1000,
  clustervars = "id",
  print_details = FALSE
)

cs_agg_notyet <- aggregate_attgt(cs_notyet, "simple")
cs_es_notyet <- aggregate_attgt(cs_notyet, "dynamic")

cat("CS-DiD ATT (not-yet-treated):", round(cs_agg_notyet$overall.att, 3),
    "SE:", round(cs_agg_notyet$overall.se, 3), "\n")

# 3c. Group-specific ATTs
cat("\nGroup-specific ATTs (by cohort):\n")
for (i in seq_along(cs_group$egt)) {
  cat("  Cohort", cs_group$egt[i], ": ATT =",
      round(cs_group$att.egt[i], 3),
      "(SE =", round(cs_group$se.egt[i], 3), ")\n")
}

## ---------------------------------------------------------------------------
## 4. Sun-Abraham (Alternative Estimator)
## ---------------------------------------------------------------------------

cat("\n=== Sun-Abraham Estimator ===\n")

sa_df <- df %>%
  filter(!is.na(first_treat)) %>%
  mutate(cohort = ifelse(first_treat == 0 | first_treat > 2023, 10000L, as.integer(first_treat)))

sa_out <- feols(
  rate_synth_opioid ~ sunab(cohort, year) | state_abb + year,
  data = sa_df,
  cluster = ~ state_abb
)

cat("Sun-Abraham ATT:\n")
sa_summary <- summary(sa_out, agg = "ATT")
print(sa_summary)

## ---------------------------------------------------------------------------
## 5. Log specification (semi-elasticity)
## ---------------------------------------------------------------------------

cat("\n=== CS-DiD in Logs ===\n")

cs_log <- att_gt(
  yname = "log_rate_synth",
  tname = "year",
  idname = "id",
  gname = "gname",
  data = cs_df,
  control_group = "nevertreated",
  est_method = "dr",
  bstrap = TRUE,
  biters = 1000,
  clustervars = "id",
  print_details = FALSE
)

cs_log_agg <- aggregate_attgt(cs_log, "simple")
cs_log_es <- aggregate_attgt(cs_log, "dynamic")

cat("CS-DiD ATT (log, never-treated):",
    round(cs_log_agg$overall.att, 4),
    "=> ~", round(100 * (exp(cs_log_agg$overall.att) - 1), 1), "% change\n")

## ---------------------------------------------------------------------------
## 6. Save all results
## ---------------------------------------------------------------------------

results <- list(
  twfe_basic = twfe_basic,
  twfe_controls = twfe_controls,
  twfe_log = twfe_log,
  cs_never = cs_never,
  cs_agg_never = cs_agg_never,
  cs_es_never = cs_es_never,
  cs_notyet = cs_notyet,
  cs_agg_notyet = cs_agg_notyet,
  cs_es_notyet = cs_es_notyet,
  cs_group = cs_group,
  sa_out = sa_out,
  cs_log = cs_log,
  cs_log_agg = cs_log_agg,
  cs_log_es = cs_log_es
)

saveRDS(results, file.path(data_dir, "main_results.rds"))

cat("\n=== Main analysis complete ===\n")
