## =============================================================================
## 04_robustness.R — Robustness checks and heterogeneity analysis
## Anti-Cyberbullying Laws and Youth Mental Health
## =============================================================================

source("00_packages.R")

data_dir <- "../data"
tables_dir <- "../tables"
dir.create(tables_dir, showWarnings = FALSE, recursive = TRUE)

panel <- readRDS(file.path(data_dir, "yrbs_panel.rds"))
yrbs_by_sex <- readRDS(file.path(data_dir, "yrbs_by_sex.rds"))

## Resolve namespace conflict: fixest::pvalue masked by scales::pvalue
fpvalue <- fixest::pvalue

## -----------------------------------------------------------------------------
## 1. Randomization Inference (permutation test)
## -----------------------------------------------------------------------------

cat("=== Randomization Inference ===\n")

n_perms <- 1000

ri_results <- list()

for (outcome in c("suicide_ideation", "suicide_attempt", "depression")) {
  cat(sprintf("\nRI for %s (%d permutations)...\n", outcome, n_perms))

  df_est <- panel %>%
    filter(!is.na(.data[[outcome]])) %>%
    group_by(state_id) %>%
    filter(n() >= 3) %>%
    ungroup()

  # Actual estimate
  actual_fit <- feols(
    as.formula(paste(outcome, "~ treated | state_id + year")),
    data = df_est, cluster = ~state_id
  )
  actual_coef <- coef(actual_fit)[["treated"]]

  # Permutation distribution: shuffle treatment assignment across states
  # (preserve timing structure within each state)
  state_treatments <- df_est %>%
    distinct(state_id, first_treat_wave) %>%
    pull(first_treat_wave)

  perm_coefs <- numeric(n_perms)
  for (i in 1:n_perms) {
    # Randomly reassign treatment cohorts to states
    shuffled_treats <- sample(state_treatments)
    df_perm <- df_est %>%
      left_join(
        tibble(
          state_id = unique(df_est$state_id),
          perm_first_treat = shuffled_treats
        ),
        by = "state_id"
      ) %>%
      mutate(
        perm_treated = as.integer(
          perm_first_treat != 0 & year >= perm_first_treat
        )
      )

    perm_fit <- tryCatch(
      feols(
        as.formula(paste(outcome, "~ perm_treated | state_id + year")),
        data = df_perm, cluster = ~state_id
      ),
      error = function(e) NULL
    )

    perm_coefs[i] <- if (!is.null(perm_fit)) coef(perm_fit)[["perm_treated"]] else NA
  }

  perm_coefs <- perm_coefs[!is.na(perm_coefs)]
  ri_pvalue <- mean(abs(perm_coefs) >= abs(actual_coef))

  cat(sprintf("  Actual coef: %.4f\n", actual_coef))
  cat(sprintf("  RI p-value (two-sided): %.4f\n", ri_pvalue))
  cat(sprintf("  5th/95th percentiles of null: [%.4f, %.4f]\n",
              quantile(perm_coefs, 0.05), quantile(perm_coefs, 0.95)))

  ri_results[[outcome]] <- list(
    actual = actual_coef,
    perm_dist = perm_coefs,
    p_value = ri_pvalue
  )
}

saveRDS(ri_results, file.path(data_dir, "ri_results.rds"))

## -----------------------------------------------------------------------------
## 2. Sex heterogeneity
## -----------------------------------------------------------------------------

cat("\n=== Sex Heterogeneity ===\n")

sex_results <- list()

for (sx in c("Female", "Male")) {
  cat(sprintf("\nSex: %s\n", sx))
  df_sex <- yrbs_by_sex %>%
    filter(sex == sx) %>%
    group_by(state_id) %>%
    filter(n() >= 3) %>%
    ungroup()

  for (outcome in c("suicide_ideation", "suicide_attempt", "depression")) {
    df_est <- df_sex %>% filter(!is.na(.data[[outcome]]))
    if (nrow(df_est) < 20) next

    fit <- feols(
      as.formula(paste(outcome, "~ treated | state_id + year")),
      data = df_est, cluster = ~state_id
    )

    cat(sprintf("  %s: coef=%.3f, SE=%.3f, p=%.4f\n",
                outcome, coef(fit), se(fit), fpvalue(fit)))
    sex_results[[paste(sx, outcome, sep = "_")]] <- fit
  }
}

saveRDS(sex_results, file.path(data_dir, "sex_results.rds"))

## -----------------------------------------------------------------------------
## 3. Law type heterogeneity (criminal vs. school-policy only)
## -----------------------------------------------------------------------------

cat("\n=== Law Type Heterogeneity ===\n")

lawtype_results <- list()

for (outcome in c("suicide_ideation", "suicide_attempt", "depression")) {
  df_est <- panel %>%
    filter(!is.na(.data[[outcome]])) %>%
    group_by(state_id) %>%
    filter(n() >= 3) %>%
    ungroup()

  # Interact treatment with criminal penalty indicator
  df_est <- df_est %>%
    mutate(
      treated_criminal = treated * has_criminal,
      treated_school   = treated * (1 - has_criminal)
    )

  fit <- feols(
    as.formula(paste(outcome, "~ treated_criminal + treated_school | state_id + year")),
    data = df_est, cluster = ~state_id
  )

  cat(sprintf("\n%s:\n", outcome))
  cat(sprintf("  Criminal penalty states:    coef=%.3f, SE=%.3f\n",
              coef(fit)[["treated_criminal"]], se(fit)[["treated_criminal"]]))
  cat(sprintf("  School-policy-only states:  coef=%.3f, SE=%.3f\n",
              coef(fit)[["treated_school"]], se(fit)[["treated_school"]]))

  lawtype_results[[outcome]] <- fit
}

saveRDS(lawtype_results, file.path(data_dir, "lawtype_results.rds"))

## -----------------------------------------------------------------------------
## 4. Sun & Abraham (2021) alternative estimator
## -----------------------------------------------------------------------------

cat("\n=== Sun & Abraham Estimator ===\n")

sa_results <- list()

for (outcome in c("suicide_ideation", "suicide_attempt", "depression")) {
  df_est <- panel %>%
    filter(!is.na(.data[[outcome]])) %>%
    mutate(
      # sunab needs cohort year and never-treated as large number
      cohort = ifelse(first_treat_wave == 0, 10000, first_treat_wave)
    ) %>%
    group_by(state_id) %>%
    filter(n() >= 3) %>%
    ungroup()

  tryCatch({
    sa_fit <- feols(
      as.formula(paste(outcome, "~ sunab(cohort, year) | state_id + year")),
      data = df_est, cluster = ~state_id
    )

    sa_agg <- summary(sa_fit, agg = "ATT")
    cat(sprintf("\n%s (Sun-Abraham ATT): %.3f (SE: %.3f)\n",
                outcome, coef(sa_agg), se(sa_agg)))

    sa_results[[outcome]] <- sa_fit
  }, error = function(e) {
    cat(sprintf("  Sun-Abraham failed for %s: %s\n", outcome, e$message))
  })
}

saveRDS(sa_results, file.path(data_dir, "sa_results.rds"))

## -----------------------------------------------------------------------------
## 5. Placebo test: traditional bullying (should not be directly targeted)
## -----------------------------------------------------------------------------

cat("\n=== Placebo/Spillover: Traditional Bullying ===\n")

df_bully <- panel %>%
  filter(!is.na(bullying_school)) %>%
  group_by(state_id) %>%
  filter(n() >= 3) %>%
  ungroup()

bully_fit <- feols(
  bullying_school ~ treated | state_id + year,
  data = df_bully, cluster = ~state_id
)

cat(sprintf("Traditional bullying (spillover): coef=%.3f, SE=%.3f, p=%.4f\n",
            coef(bully_fit), se(bully_fit), fpvalue(bully_fit)))

## -----------------------------------------------------------------------------
## 6. Dose-response: years since law adoption
## -----------------------------------------------------------------------------

cat("\n=== Dose-Response: Years Since Adoption ===\n")

dose_results <- list()

for (outcome in c("suicide_ideation", "depression")) {
  df_est <- panel %>%
    filter(!is.na(.data[[outcome]])) %>%
    mutate(
      years_since = ifelse(is.na(law_year) | year < law_year, 0,
                           year - law_year)
    ) %>%
    group_by(state_id) %>%
    filter(n() >= 3) %>%
    ungroup()

  fit <- feols(
    as.formula(paste(outcome, "~ years_since | state_id + year")),
    data = df_est, cluster = ~state_id
  )

  cat(sprintf("\n%s (dose-response per year post-treatment): coef=%.4f, SE=%.4f\n",
              outcome, coef(fit), se(fit)))
  dose_results[[outcome]] <- fit
}

saveRDS(dose_results, file.path(data_dir, "dose_results.rds"))

## -----------------------------------------------------------------------------
## 7. Treatment timing sensitivity (shift ±1 wave)
## -----------------------------------------------------------------------------

cat("\n=== Treatment Timing Sensitivity ===\n")

timing_results <- list()

for (shift in c(-2, 2)) {
  label <- ifelse(shift < 0, "early", "late")
  cat(sprintf("\nShift = %+d years (%s):\n", shift, label))

  df_shifted <- panel %>%
    mutate(
      shifted_treat = case_when(
        is.na(law_year) ~ 0L,
        year >= (law_year + shift) ~ 1L,
        TRUE ~ 0L
      )
    )

  for (outcome in c("suicide_ideation", "depression")) {
    df_est <- df_shifted %>%
      filter(!is.na(.data[[outcome]])) %>%
      group_by(state_id) %>%
      filter(n() >= 3) %>%
      ungroup()

    fit <- feols(
      as.formula(paste(outcome, "~ shifted_treat | state_id + year")),
      data = df_est, cluster = ~state_id
    )

    cat(sprintf("  %s: coef=%.3f, SE=%.3f\n", outcome, coef(fit), se(fit)))
    timing_results[[paste(label, outcome, sep = "_")]] <- fit
  }
}

saveRDS(timing_results, file.path(data_dir, "timing_results.rds"))

cat("\n=== Robustness checks complete ===\n")
