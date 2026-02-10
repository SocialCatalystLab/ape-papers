## =============================================================================
## 03_main_analysis.R — Primary DiD analysis
## Anti-Cyberbullying Laws and Youth Mental Health
## =============================================================================

source("00_packages.R")

data_dir <- "../data"
tables_dir <- "../tables"
dir.create(tables_dir, showWarnings = FALSE, recursive = TRUE)

panel <- readRDS(file.path(data_dir, "yrbs_panel.rds"))

## Resolve namespace conflict: fixest::pvalue masked by scales::pvalue
fpvalue <- fixest::pvalue

## -----------------------------------------------------------------------------
## 1. Treatment rollout (DiD checklist step 1)
## -----------------------------------------------------------------------------

cat("=== DiD Checklist: Treatment Rollout ===\n")

laws <- readRDS(file.path(data_dir, "cyberbullying_laws.rds"))
rollout <- laws %>%
  filter(!is.na(law_year)) %>%
  count(law_year, name = "n_states") %>%
  mutate(cum_states = cumsum(n_states))

cat("\nCumulative adoption:\n")
print(rollout)
cat(sprintf("Total treated states: %d\n", sum(rollout$n_states)))

## Add cohort group for visualization
panel <- panel %>%
  mutate(
    cohort_group = case_when(
      is.na(law_year) ~ "Never treated",
      law_year <= 2008 ~ "Early (2006-2008)",
      law_year <= 2011 ~ "Middle (2009-2011)",
      TRUE ~ "Late (2012-2015)"
    ),
    cohort_group = factor(cohort_group,
                          levels = c("Early (2006-2008)", "Middle (2009-2011)",
                                     "Late (2012-2015)", "Never treated")),
    # For sunab: cohort variable — never-treated gets large value
    cohort_sa = ifelse(first_treat_wave == 0, 10000, first_treat_wave)
  )

## -----------------------------------------------------------------------------
## 2. TWFE Baseline — All outcomes
## -----------------------------------------------------------------------------

cat("\n=== TWFE Baseline ===\n")

outcomes <- c("suicide_ideation", "suicide_attempt", "depression",
              "suicide_plan", "bullying_school", "cyberbullying")

twfe_results <- list()

for (outcome in outcomes) {
  df_est <- panel %>%
    filter(!is.na(.data[[outcome]])) %>%
    group_by(state_id) %>%
    filter(n() >= 2) %>%
    ungroup()

  if (nrow(df_est) < 20) {
    cat(sprintf("  %s: too few observations (%d), skipping\n", outcome, nrow(df_est)))
    next
  }

  fit <- feols(
    as.formula(paste(outcome, "~ treated | state_id + year")),
    data = df_est,
    cluster = ~state_id
  )

  twfe_results[[outcome]] <- fit

  cat(sprintf("\n%s (TWFE): coef=%.3f, SE=%.3f, p=%.4f, N=%d, R2w=%.3f\n",
              outcome, coef(fit)[1], se(fit)[1], fpvalue(fit)[1],
              nobs(fit), r2(fit, "wr2")[[1]]))
}

## -----------------------------------------------------------------------------
## 3. Sun & Abraham (2021) — Heterogeneity-robust estimator
## Primary method for staggered DiD (handles unbalanced panels)
## -----------------------------------------------------------------------------

cat("\n=== Sun & Abraham (2021) Estimator ===\n")

sa_results <- list()
sa_es_results <- list()

for (outcome in c("suicide_ideation", "suicide_attempt", "depression",
                   "suicide_plan", "bullying_school")) {
  df_est <- panel %>%
    filter(!is.na(.data[[outcome]])) %>%
    group_by(state_id) %>%
    filter(n() >= 2) %>%
    ungroup()

  if (nrow(df_est) < 20) next

  tryCatch({
    # Sun-Abraham event study
    sa_fit <- feols(
      as.formula(paste(outcome, "~ sunab(cohort_sa, year) | state_id + year")),
      data = df_est,
      cluster = ~state_id
    )

    sa_results[[outcome]] <- sa_fit

    # Aggregate to ATT
    sa_agg <- summary(sa_fit, agg = "ATT")
    cat(sprintf("\n%s (Sun-Abraham ATT): coef=%.3f, SE=%.3f, p=%.4f\n",
                outcome, coef(sa_agg)[1], se(sa_agg)[1], fpvalue(sa_agg)[1]))

    # Event study coefficients
    sa_es <- summary(sa_fit, agg = "period")
    sa_es_results[[outcome]] <- sa_es

    cat("  Event-study coefficients:\n")
    es_df <- data.frame(
      period = as.integer(names(coef(sa_es))),
      att = round(coef(sa_es), 3),
      se = round(se(sa_es), 3)
    )
    print(es_df[order(es_df$period), ])

  }, error = function(e) {
    cat(sprintf("  Sun-Abraham failed for %s: %s\n", outcome, e$message))
  })
}

## -----------------------------------------------------------------------------
## 4. Callaway-Sant'Anna (attempt on restricted sample)
## Restrict to states with ≥3 pre-treatment observations
## -----------------------------------------------------------------------------

cat("\n=== Callaway-Sant'Anna (Restricted Sample) ===\n")

cs_results <- list()
cs_es_results <- list()

for (outcome in c("suicide_ideation", "depression")) {
  cat(sprintf("\nAttempting CS-DiD for: %s\n", outcome))

  df_est <- panel %>%
    filter(!is.na(.data[[outcome]])) %>%
    # Only keep states with ≥3 observations
    group_by(state_id) %>%
    filter(n() >= 3) %>%
    ungroup()

  # Check how many states are never-treated or have pre-treatment data
  state_info <- df_est %>%
    group_by(state_id, first_treat_wave) %>%
    summarise(
      min_year = min(year),
      max_year = max(year),
      n_obs = n(),
      n_pre = sum(year < first_treat_wave | first_treat_wave == 0),
      .groups = "drop"
    )

  n_with_predata <- sum(state_info$n_pre > 0)
  cat(sprintf("  States with pre-treatment data: %d of %d\n",
              n_with_predata, nrow(state_info)))

  # Only attempt if enough states have pre-treatment data
  if (n_with_predata >= 10) {
    # Drop states with no pre-treatment data
    good_states <- state_info$state_id[state_info$n_pre > 0]
    df_cs <- df_est %>% filter(state_id %in% good_states)

    tryCatch({
      cs_out <- att_gt(
        yname = outcome,
        tname = "year",
        idname = "state_id",
        gname = "first_treat_wave",
        data = df_cs,
        control_group = "notyettreated",
        anticipation = 0,
        base_period = "varying"
      )

      cs_results[[outcome]] <- cs_out

      agg_overall <- aggte(cs_out, type = "simple")
      cat(sprintf("  CS-DiD ATT: %.3f (SE: %.3f)\n",
                  agg_overall$overall.att, agg_overall$overall.se))

      es_out <- aggte(cs_out, type = "dynamic")
      cs_es_results[[outcome]] <- es_out

    }, error = function(e) {
      cat(sprintf("  CS-DiD failed: %s\n", e$message))
    })
  } else {
    cat("  Not enough states with pre-treatment data for CS-DiD.\n")
  }
}

## -----------------------------------------------------------------------------
## 5. Bacon decomposition (diagnostic for TWFE)
## -----------------------------------------------------------------------------

cat("\n=== Bacon Decomposition ===\n")

bacon_results <- list()

for (outcome in c("suicide_ideation", "depression")) {
  df_est <- panel %>%
    filter(!is.na(.data[[outcome]])) %>%
    # Balanced panel needed: keep only years where most states have data
    filter(year >= 2003) %>%
    group_by(state_id) %>%
    filter(n() >= 5) %>%  # At least 5 of the 8 waves 2003-2017
    ungroup()

  # Need fully balanced for bacon
  all_years <- sort(unique(df_est$year))
  balanced_states <- df_est %>%
    group_by(state_id) %>%
    filter(n() == length(all_years)) %>%
    pull(state_id) %>%
    unique()

  df_bacon <- df_est %>% filter(state_id %in% balanced_states)

  cat(sprintf("\n%s — balanced panel: %d states × %d periods\n",
              outcome, n_distinct(df_bacon$state_id), length(all_years)))

  if (n_distinct(df_bacon$state_id) >= 10) {
    tryCatch({
      bacon_out <- bacon(
        as.formula(paste(outcome, "~ treated")),
        data = df_bacon,
        id_var = "state_id",
        time_var = "year"
      )

      bacon_results[[outcome]] <- bacon_out

      bacon_summary <- bacon_out %>%
        group_by(type) %>%
        summarise(
          n_comparisons = n(),
          weight = sum(weight),
          weighted_est = sum(estimate * weight) / sum(weight),
          .groups = "drop"
        )
      cat("  Decomposition:\n")
      print(bacon_summary)
    }, error = function(e) {
      cat(sprintf("  Bacon failed: %s\n", e$message))
    })
  }
}

## -----------------------------------------------------------------------------
## 6. Save all results
## -----------------------------------------------------------------------------

saveRDS(twfe_results, file.path(data_dir, "twfe_results.rds"))
saveRDS(sa_results, file.path(data_dir, "sa_results.rds"))
saveRDS(sa_es_results, file.path(data_dir, "sa_es_results.rds"))

## Save aggregated SA ATT values (portable, doesn't need original data)
sa_att_summary <- list()
for (nm in names(sa_results)) {
  sa_agg <- summary(sa_results[[nm]], agg = "ATT")
  sa_att_summary[[nm]] <- list(
    att = coef(sa_agg)[[1]],
    se = se(sa_agg)[[1]],
    p = fpvalue(sa_agg)[[1]]
  )
}
saveRDS(sa_att_summary, file.path(data_dir, "sa_att_summary.rds"))
saveRDS(cs_results, file.path(data_dir, "cs_results.rds"))
saveRDS(cs_es_results, file.path(data_dir, "cs_es_results.rds"))
if (length(bacon_results) > 0) saveRDS(bacon_results, file.path(data_dir, "bacon_results.rds"))

cat("\n=== Main analysis complete ===\n")
