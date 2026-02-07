# ==============================================================================
# Paper 188: Moral Foundations Under Digital Pressure
# 04_main_analysis.R - Callaway-Sant'Anna DiD estimation
#
# Revision of apep_0052. Ground-up rebuild with Enke framing.
# ==============================================================================

source("code/00_packages.R")

cat("\n========================================\n")
cat("  04_main_analysis.R\n")
cat("========================================\n\n")

# ==============================================================================
# 1. LOAD DATA
# ==============================================================================
cat("=== Loading Analysis Panel ===\n")

df <- arrow::read_parquet("data/analysis_panel.parquet")
cat(sprintf("  Rows: %s\n", format(nrow(df), big.mark = ",")))
cat(sprintf("  Places: %s\n", format(n_distinct(df$place_id), big.mark = ",")))
cat(sprintf("  States (clusters): %d\n", n_distinct(df$state_fips)))
cat(sprintf("  Years: %d - %d\n", min(df$year), max(df$year)))

# Ensure output directories
dir.create("tables", showWarnings = FALSE, recursive = TRUE)
dir.create("data", showWarnings = FALSE, recursive = TRUE)

# Prepare data for did package
# gname = 0 for never-treated, = treat_year for treated
# CRITICAL: gname must be numeric (double), not integer
# did 2.3.0 internally assigns Inf to never-treated, which truncates if integer
did_data <- df %>%
  mutate(
    gname = as.numeric(ifelse(treated, treat_year, 0)),
    id = as.numeric(factor(place_id))
  ) %>%
  # Drop rows with NA in covariates (5 rows with missing log_income)
  filter(!is.na(log_income))

# Report treatment cohorts
cat("\n  Treatment cohorts:\n")
did_data %>%
  filter(gname > 0) %>%
  distinct(place_id, gname) %>%
  count(gname) %>%
  print(n = Inf)

n_treated <- n_distinct(did_data$place_id[did_data$treated])
n_control <- n_distinct(did_data$place_id[!did_data$treated])
n_clusters <- n_distinct(did_data$state_fips)
cat(sprintf("\n  Treated: %d places, Never-treated: %d places, Clusters: %d states\n",
            n_treated, n_control, n_clusters))

# ==============================================================================
# 2. CALLAWAY-SANT'ANNA: MAIN OUTCOMES
#    individualizing, binding, universalism_index, log_univ_comm
# ==============================================================================
cat("\n=== C-S Estimation: Main Outcomes ===\n")

# Covariates formula (doubly robust)
xformla <- ~ log_pop + log_income + pct_college + pct_white + median_age

main_outcomes <- c("individualizing", "binding", "universalism_index", "log_univ_comm")

# Verify all variables exist
for (v in c(main_outcomes, all.vars(xformla))) {
  if (!v %in% names(did_data)) {
    cat(sprintf("  WARNING: Variable '%s' not found in data. Creating if possible.\n", v))
    if (v == "log_pop" && "population" %in% names(did_data)) {
      did_data$log_pop <- log(did_data$population + 1)
    }
    if (v == "log_income" && "median_income" %in% names(did_data)) {
      did_data$log_income <- log(did_data$median_income + 1)
    }
  }
}

# Storage for results
cs_objects <- list()
es_objects <- list()
att_simple <- list()
att_group <- list()

for (outcome in main_outcomes) {
  cat(sprintf("\n--- Outcome: %s ---\n", outcome))

  # Check for NAs
  n_missing <- sum(is.na(did_data[[outcome]]))
  if (n_missing > 0) {
    cat(sprintf("  WARNING: %d missing values in %s (%.1f%%)\n",
                n_missing, outcome, n_missing / nrow(did_data) * 100))
  }

  # Use "notyettreated" as control group: only 9 never-treated places exist
  # (98.3% treatment rate), so not-yet-treated provides a much larger comparison pool
  # Use est_method = "reg" (outcome regression) because DR/IPW fails with
  # singular matrices for small late-adopter cohorts (2021: 5 units, 2022: 2 units)
  cs_objects[[outcome]] <- tryCatch({
    cs <- att_gt(
      yname = outcome,
      tname = "year",
      idname = "id",
      gname = "gname",
      data = did_data,
      control_group = "notyettreated",
      est_method = "reg",
      clustervars = "state_fips",
      anticipation = 1,
      bstrap = TRUE,
      biters = 1000,
      print_details = FALSE
    )
    cat(sprintf("  att_gt complete: %d group-time ATTs\n", length(cs$att)))
    cs
  }, error = function(e) {
    cat(sprintf("  ERROR in att_gt: %s\n", e$message))
    NULL
  })

  if (is.null(cs_objects[[outcome]])) {
    cat(sprintf("  SKIPPING %s (estimation failed)\n", outcome))
    next
  }

  # --- Dynamic aggregation (event study) ---
  es_objects[[outcome]] <- tryCatch({
    aggte(cs_objects[[outcome]], type = "dynamic", na.rm = TRUE)
  }, error = function(e) {
    cat(sprintf("  Event study aggregation failed: %s\n", e$message))
    NULL
  })

  if (!is.null(es_objects[[outcome]])) {
    cat(sprintf("  Event study: %d event-time periods\n",
                length(es_objects[[outcome]]$egt)))
  }

  # --- Simple aggregation (overall ATT) ---
  att_simple[[outcome]] <- tryCatch({
    aggte(cs_objects[[outcome]], type = "simple", na.rm = TRUE)
  }, error = function(e) {
    cat(sprintf("  Simple aggregation failed: %s\n", e$message))
    NULL
  })

  if (!is.null(att_simple[[outcome]])) {
    att_val <- att_simple[[outcome]]$overall.att
    se_val <- att_simple[[outcome]]$overall.se
    p_val <- 2 * (1 - pnorm(abs(att_val / se_val)))
    cat(sprintf("  Overall ATT: %.5f (SE: %.5f, p = %.4f)\n",
                att_val, se_val, p_val))
  }

  # --- Group (cohort-specific) aggregation ---
  att_group[[outcome]] <- tryCatch({
    aggte(cs_objects[[outcome]], type = "group", na.rm = TRUE)
  }, error = function(e) {
    cat(sprintf("  Group aggregation failed: %s\n", e$message))
    NULL
  })

  if (!is.null(att_group[[outcome]])) {
    cat(sprintf("  Cohort-specific ATTs: %d cohorts\n",
                length(att_group[[outcome]]$egt)))
  }
}

# ==============================================================================
# 3. INDIVIDUAL MORAL FOUNDATIONS
#    care_p, fairness_p, loyalty_p, authority_p, sanctity_p
# ==============================================================================
cat("\n=== C-S Estimation: Individual Foundations ===\n")

foundations <- c("care_p", "fairness_p", "loyalty_p", "authority_p", "sanctity_p")
foundation_cs <- list()
foundation_att <- list()
foundation_es <- list()

for (fnd in foundations) {
  cat(sprintf("  Estimating: %s... ", fnd))

  foundation_cs[[fnd]] <- tryCatch({
    att_gt(
      yname = fnd,
      tname = "year",
      idname = "id",
      gname = "gname",
      data = did_data,
      control_group = "notyettreated",
      est_method = "reg",
      clustervars = "state_fips",
      anticipation = 1,
      bstrap = TRUE,
      biters = 500,
      print_details = FALSE
    )
  }, error = function(e) {
    cat(sprintf("FAILED: %s", e$message))
    NULL
  })

  if (is.null(foundation_cs[[fnd]])) {
    cat("SKIPPED\n")
    next
  }

  foundation_att[[fnd]] <- tryCatch(
    aggte(foundation_cs[[fnd]], type = "simple", na.rm = TRUE),
    error = function(e) NULL
  )
  foundation_es[[fnd]] <- tryCatch(
    aggte(foundation_cs[[fnd]], type = "dynamic", na.rm = TRUE),
    error = function(e) NULL
  )

  if (!is.null(foundation_att[[fnd]])) {
    cat(sprintf("ATT = %.5f (SE = %.5f)\n",
                foundation_att[[fnd]]$overall.att,
                foundation_att[[fnd]]$overall.se))
  } else {
    cat("aggregation failed\n")
  }
}

# ==============================================================================
# 4. PRE-TREND TESTS (JOINT CHI-SQUARED)
# ==============================================================================
cat("\n=== Pre-Trend Tests ===\n")

pretrend_test <- function(es_object, name) {
  if (is.null(es_object)) {
    cat(sprintf("  %s: No event study object available\n", name))
    return(tibble(outcome = name, chi2 = NA, df = NA, p_value = NA, n_pre = 0))
  }

  # Extract pre-period coefficients
  pre_idx <- es_object$egt < 0
  pre_att <- es_object$att.egt[pre_idx]
  pre_se <- es_object$se.egt[pre_idx]

  # Remove NAs
  valid <- !is.na(pre_att) & !is.na(pre_se) & pre_se > 0
  pre_att <- pre_att[valid]
  pre_se <- pre_se[valid]

  n_pre <- length(pre_att)
  if (n_pre == 0) {
    cat(sprintf("  %s: No valid pre-period coefficients\n", name))
    return(tibble(outcome = name, chi2 = NA, df = NA, p_value = NA, n_pre = 0))
  }

  # Joint Wald test: sum of squared t-statistics ~ chi2(n_pre)
  t_stats <- pre_att / pre_se
  chi2 <- sum(t_stats^2)
  p_val <- 1 - pchisq(chi2, df = n_pre)

  cat(sprintf("  %s: chi2(%d) = %.3f, p = %.4f\n", name, n_pre, chi2, p_val))

  tibble(
    outcome = name,
    chi2 = chi2,
    df = n_pre,
    p_value = p_val,
    n_pre = n_pre,
    pass_05 = p_val > 0.05,
    pass_10 = p_val > 0.10
  )
}

pretrend_results <- bind_rows(
  map2_dfr(es_objects[main_outcomes], main_outcomes, pretrend_test),
  map2_dfr(foundation_es[foundations], foundations, pretrend_test)
)

cat("\n  Pre-trend test summary:\n")
print(pretrend_results, width = Inf)

write_csv(pretrend_results, "tables/pretrend_tests.csv")
cat("  Saved: tables/pretrend_tests.csv\n")

# ==============================================================================
# 5. TWFE COMPARISON (DIAGNOSTIC)
# ==============================================================================
cat("\n=== TWFE Comparison (Diagnostic) ===\n")

twfe_results_list <- list()

for (outcome in main_outcomes) {
  cat(sprintf("  TWFE: %s\n", outcome))

  fml <- as.formula(paste0(outcome, " ~ treat_post | place_id + year"))

  twfe_results_list[[outcome]] <- tryCatch({
    feols(fml, data = df, cluster = ~state_fips)
  }, error = function(e) {
    cat(sprintf("    FAILED: %s\n", e$message))
    NULL
  })
}

# Print TWFE comparison table
valid_twfe <- twfe_results_list[!sapply(twfe_results_list, is.null)]
if (length(valid_twfe) > 0) {
  cat("\n  TWFE Results:\n")
  etable(valid_twfe,
         headers = names(valid_twfe),
         fitstat = ~ r2 + n)
}

# Build TWFE comparison CSV
twfe_comparison <- map_dfr(names(twfe_results_list), function(outcome) {
  m <- twfe_results_list[[outcome]]
  if (is.null(m)) {
    return(tibble(outcome = outcome, twfe_coef = NA, twfe_se = NA,
                  twfe_pval = NA, cs_att = NA, cs_se = NA))
  }

  cs_att_val <- if (!is.null(att_simple[[outcome]])) att_simple[[outcome]]$overall.att else NA
  cs_se_val <- if (!is.null(att_simple[[outcome]])) att_simple[[outcome]]$overall.se else NA

  tibble(
    outcome = outcome,
    twfe_coef = coef(m)["treat_postTRUE"],
    twfe_se = se(m)["treat_postTRUE"],
    twfe_pval = fixest::pvalue(m)["treat_postTRUE"],
    twfe_r2 = fixest::r2(m, "wr2"),
    twfe_n = m$nobs,
    twfe_n_clusters = n_clusters,
    cs_att = cs_att_val,
    cs_se = cs_se_val,
    cs_pval = if (!is.na(cs_att_val) && !is.na(cs_se_val) && cs_se_val > 0)
      2 * (1 - pnorm(abs(cs_att_val / cs_se_val))) else NA
  )
})

write_csv(twfe_comparison, "tables/twfe_comparison.csv")
cat("  Saved: tables/twfe_comparison.csv\n")

# ==============================================================================
# 6. GOODMAN-BACON DECOMPOSITION
# ==============================================================================
cat("\n=== Goodman-Bacon Decomposition ===\n")

bacon_results <- list()

for (outcome in c("individualizing", "binding")) {
  cat(sprintf("  Bacon decomp: %s\n", outcome))

  bacon_results[[outcome]] <- tryCatch({
    # bacon() requires balanced panel or at least id + time + treatment
    fml <- as.formula(paste0(outcome, " ~ treat_post"))
    bacon(fml,
          data = df,
          id_var = "place_id",
          time_var = "year")
  }, error = function(e) {
    cat(sprintf("    FAILED: %s\n", e$message))
    # Try with string ID
    tryCatch({
      fml <- as.formula(paste0(outcome, " ~ treat_post"))
      bacon(fml,
            data = df %>% mutate(pid = as.character(place_id)),
            id_var = "pid",
            time_var = "year")
    }, error = function(e2) {
      cat(sprintf("    RETRY ALSO FAILED: %s\n", e2$message))
      NULL
    })
  })
}

# Save Bacon decomposition
bacon_table <- map_dfr(names(bacon_results), function(outcome) {
  b <- bacon_results[[outcome]]
  if (is.null(b)) return(tibble(outcome = outcome))

  if (is.data.frame(b)) {
    b %>% mutate(outcome = outcome)
  } else {
    tibble(outcome = outcome, note = "non-standard output")
  }
})

write_csv(bacon_table, "tables/bacon_decomp.csv")
cat("  Saved: tables/bacon_decomp.csv\n")

# ==============================================================================
# 7. COMPILE AND SAVE MAIN RESULTS TABLE
# ==============================================================================
cat("\n=== Compiling Main Results ===\n")

# Main outcomes
main_results <- map_dfr(main_outcomes, function(outcome) {
  att <- att_simple[[outcome]]
  if (is.null(att)) {
    return(tibble(outcome = outcome, estimator = "Callaway-Sant'Anna",
                  ATT = NA, SE = NA))
  }

  att_val <- att$overall.att
  se_val <- att$overall.se
  p_val <- 2 * (1 - pnorm(abs(att_val / se_val)))

  tibble(
    outcome = outcome,
    estimator = "Callaway-Sant'Anna",
    ATT = att_val,
    SE = se_val,
    CI_lower = att_val - 1.96 * se_val,
    CI_upper = att_val + 1.96 * se_val,
    p_value = p_val,
    N = nrow(did_data),
    N_clusters = n_clusters,
    N_treated = n_treated,
    N_control = n_control,
    sig = case_when(
      p_val < 0.01 ~ "***",
      p_val < 0.05 ~ "**",
      p_val < 0.10 ~ "*",
      TRUE ~ ""
    )
  )
})

# Individual foundations
foundation_results_table <- map_dfr(foundations, function(fnd) {
  att <- foundation_att[[fnd]]
  if (is.null(att)) {
    return(tibble(outcome = fnd, estimator = "Callaway-Sant'Anna",
                  ATT = NA, SE = NA))
  }

  att_val <- att$overall.att
  se_val <- att$overall.se
  p_val <- 2 * (1 - pnorm(abs(att_val / se_val)))

  tibble(
    outcome = fnd,
    estimator = "Callaway-Sant'Anna",
    ATT = att_val,
    SE = se_val,
    CI_lower = att_val - 1.96 * se_val,
    CI_upper = att_val + 1.96 * se_val,
    p_value = p_val,
    N = nrow(did_data),
    N_clusters = n_clusters,
    N_treated = n_treated,
    N_control = n_control,
    sig = case_when(
      p_val < 0.01 ~ "***",
      p_val < 0.05 ~ "**",
      p_val < 0.10 ~ "*",
      TRUE ~ ""
    )
  )
})

all_results <- bind_rows(main_results, foundation_results_table)

# Ensure all expected columns exist (some may be missing if all estimates are NULL)
expected_cols <- c("outcome", "estimator", "ATT", "SE", "CI_lower", "CI_upper",
                   "p_value", "N", "N_clusters", "N_treated", "N_control", "sig")
for (col in expected_cols) {
  if (!col %in% names(all_results)) all_results[[col]] <- NA
}

cat("\n  Main Results Table:\n")
all_results %>%
  select(outcome, ATT, SE, p_value, sig, N_treated) %>%
  mutate(
    ATT = round(ATT, 5),
    SE = round(SE, 5),
    p_value = round(p_value, 4)
  ) %>%
  print(n = Inf, width = Inf)

write_csv(all_results, "tables/main_results.csv")
cat("  Saved: tables/main_results.csv\n")

# ==============================================================================
# 8. SAVE EVENT STUDY DATA FOR FIGURES
# ==============================================================================
cat("\n=== Saving Event Study Data ===\n")

# Main outcomes
es_data <- map_dfr(names(es_objects), function(outcome) {
  es <- es_objects[[outcome]]
  if (is.null(es)) return(tibble())

  tibble(
    outcome = outcome,
    event_time = es$egt,
    att = es$att.egt,
    se = es$se.egt,
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se,
    pointwise_ci_lower = es$att.egt - 1.96 * es$se.egt,
    pointwise_ci_upper = es$att.egt + 1.96 * es$se.egt
  )
})

# Individual foundations
es_foundations <- map_dfr(names(foundation_es), function(fnd) {
  es <- foundation_es[[fnd]]
  if (is.null(es)) return(tibble())

  tibble(
    outcome = fnd,
    event_time = es$egt,
    att = es$att.egt,
    se = es$se.egt,
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se
  )
})

es_all <- bind_rows(es_data, es_foundations)

cat(sprintf("  Event study data: %d rows across %d outcomes\n",
            nrow(es_all), n_distinct(es_all$outcome)))

write_csv(es_all, "data/event_study_data.csv")
cat("  Saved: data/event_study_data.csv\n")

# ==============================================================================
# 9. COHORT-SPECIFIC RESULTS
# ==============================================================================
cat("\n=== Cohort-Specific ATTs ===\n")

cohort_data <- map_dfr(names(att_group), function(outcome) {
  grp <- att_group[[outcome]]
  if (is.null(grp)) return(tibble())

  tibble(
    outcome = outcome,
    cohort = grp$egt,
    att = grp$att.egt,
    se = grp$se.egt,
    ci_lower = att - 1.96 * se,
    ci_upper = att + 1.96 * se
  )
})

if (nrow(cohort_data) > 0) {
  write_csv(cohort_data, "data/cohort_specific_atts.csv")
  cat("  Saved: data/cohort_specific_atts.csv\n")
}

# ==============================================================================
# 10. SAVE FULL R OBJECTS
# ==============================================================================
cat("\n=== Saving R Objects ===\n")

save(
  cs_objects, es_objects, att_simple, att_group,
  foundation_cs, foundation_att, foundation_es,
  twfe_results_list, bacon_results,
  pretrend_results,
  did_data,
  file = "data/cs_results.RData"
)
cat("  Saved: data/cs_results.RData\n")

cat("\n========================================\n")
cat("  04_main_analysis.R COMPLETE\n")
cat("========================================\n")
